#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MEDS2.py -- a Python 3 port of MEDS2, the Space Shuttle MEDS glass-cockpit
simulator (MDU displays + IDPs) that lives in this tree as an Electron/
CoffeeScript/Civet application launched by MEDS2.sh.

This is a work-alike, drop-in replacement:

  MEDS2.py <lru...>            -- launch LRUs, e.g. MEDS2.py crt1 idp1
  MEDS2.py --list              -- list available LRU names
  MEDS2.py --display AE_PFD crt1

LRU definitions live in config/meds.json (override with --config or the
NSTS_SIM_CONFIG env var), exactly as before.  The multicast bus wire format,
the DEU/IDP protocol, the format-control-word beam interpreter, the vector
fonts, the menus, the keyboard and every screen are ported one for one, so a
mixed run -- a Python MDU against a JavaScript IDP, or the other way about --
behaves the same as an all-JavaScript one.

Requires: PyQt6 (with QtOpenGLWidgets) and numpy.  The renderer is the same
SDF-stroke pipeline the original ran under three.js, ported to OpenGL 4.1
core through Qt's own GL function wrappers.
"""

import argparse
import ctypes
import heapq
import json
import math
import os
import re
import selectors
import socket
import struct
import sys
import threading
import crewscript
import time
import traceback
import xml.etree.ElementTree as ET

import numpy as np

from PyQt6 import QtCore, QtGui, QtWidgets
from PyQt6.QtCore import Qt, QTimer, QPoint, QPointF, QRectF, QSocketNotifier
from PyQt6.QtGui import QSurfaceFormat, QColor
from PyQt6.QtOpenGLWidgets import QOpenGLWidget
from PyQt6.QtOpenGL import (QOpenGLVersionProfile, QOpenGLVersionFunctionsFactory)

# ---------------------------------------------------------------------------
# NSTS_TOP -- the tree this file sits in, which is where config/ and data/ are.
# ---------------------------------------------------------------------------
NSTS_TOP = os.path.dirname(os.path.abspath(__file__)) + os.sep


# ---------------------------------------------------------------------------
# Small JavaScript-shaped helpers.
#
# The original is JavaScript, and a handful of its idioms have no Python
# spelling that behaves identically.  Rounding is the one that matters:
# JS Math.round breaks ties upward, Python's round() breaks them to even, and
# the beam interpreter rounds coordinates constantly.
# ---------------------------------------------------------------------------

def jsround(v):
    """Math.round: ties go toward +infinity."""
    return math.floor(v + 0.5)


def js_parse_int(s):
    """parseInt: leading integer, else NaN (returned here as None)."""
    if s is None:
        return None
    m = re.match(r'\s*([+-]?\d+)', str(s))
    return int(m.group(1)) if m else None


def js_parse_float(s):
    m = re.match(r'\s*([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)', str(s or ''))
    return float(m.group(1)) if m else float('nan')


def _js_uint16(v):
    """JavaScript's `v & 0xffff`: a value that is not a number reads as 0."""
    try:
        n = float(v)
    except (TypeError, ValueError):
        return 0
    if n != n or n in (float('inf'), float('-inf')):
        return 0
    return int(n) & 0xffff


def _numstr(v):
    """JavaScript's `"#{v}"` for a number: integral values lose the '.0'."""
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        if v == int(v) and abs(v) < 1e21:
            return str(int(v))
        return repr(v)
    return str(v)


class _Undefined(object):
    __slots__ = ()

    def __repr__(self):
        return 'undefined'

    def __bool__(self):
        return False


UNDEF = _Undefined()


def env(name, dflt=None):
    v = os.environ.get(name)
    return dflt if v is None or v == '' else v


def envnum(name, dflt=0):
    v = os.environ.get(name)
    if v is None or v == '':
        return dflt
    try:
        return float(v)
    except ValueError:
        return dflt


class AttrDict(dict):
    """Attribute access over a dict, so NSTS_EXEC strings written for the
    JavaScript build (`window.lrus.cdr1.screens.AE_PFD...`) still run."""

    def __getattr__(self, k):
        try:
            return self[k]
        except KeyError:
            raise AttributeError(k)

    def __setattr__(self, k, v):
        self[k] = v


# ---------------------------------------------------------------------------
# localStorage
#
# The reference-overlay tooling persists placements in the browser's
# localStorage.  There is no browser here, so it lives in one JSON file per
# user; the API is the browser's, so the callers are unchanged.
# ---------------------------------------------------------------------------
class LocalStorage(object):
    def __init__(self, path=None):
        if path is None:
            base = os.environ.get('XDG_STATE_HOME') or os.path.expanduser('~/.local/state')
            path = os.path.join(base, 'meds2-port', 'localStorage.json')
        self.path = path
        self._d = {}
        try:
            with open(self.path, 'r') as f:
                self._d = json.load(f)
        except Exception:
            self._d = {}

    def getItem(self, k):
        return self._d.get(k)

    def setItem(self, k, v):
        self._d[k] = v
        self._flush()

    def removeItem(self, k):
        self._d.pop(k, None)
        self._flush()

    def _flush(self):
        try:
            os.makedirs(os.path.dirname(self.path), exist_ok=True)
            tmp = self.path + '.tmp'
            with open(tmp, 'w') as f:
                json.dump(self._d, f)
            os.replace(tmp, self.path)
        except Exception as e:
            print("localStorage: cannot write %s: %s" % (self.path, e))


localStorage = LocalStorage()


def ls_json(key):
    """`try JSON.parse(localStorage.getItem(key))` -- undefined on anything bad."""
    s = localStorage.getItem(key)
    if s is None:
        return None
    try:
        return json.loads(s)
    except Exception:
        return None


# ===========================================================================
# com/bus.civet -- the simulated Shuttle busses
#
# Every LRU is a process on this machine, so a "bus" is a UDP multicast group
# on 239.255.1.1 with one port per bus.  Words go out big-endian (network
# order) and are swapped back on receipt.
# ===========================================================================

busConfig = {
    'IC1': {'gpcBceNum': 1, 'port': 6901, 'nom': "Intercomputer 1"},
    'IC2': {'gpcBceNum': 2, 'port': 6902, 'nom': "Intercomputer 2"},
    'IC3': {'gpcBceNum': 3, 'port': 6903, 'nom': "Intercomputer 3"},
    'IC4': {'gpcBceNum': 4, 'port': 6904, 'nom': "Intercomputer 4"},
    'IC5': {'gpcBceNum': 5, 'port': 6905, 'nom': "Intercomputer 5"},
    'DK1': {'gpcBceNum': 6, 'port': 6906, 'nom': "Display/Keyboard 1"},
    'DK2': {'gpcBceNum': 7, 'port': 6907, 'nom': "Display/Keyboard 2"},
    'DK3': {'gpcBceNum': 8, 'port': 6908, 'nom': "Display/Keyboard 3"},
    'DK4': {'gpcBceNum': 9, 'port': 6909, 'nom': "Display/Keyboard 4"},
    'PL1': {'gpcBceNum': 10, 'port': 6910, 'nom': "Payload 1"},
    'PL2': {'gpcBceNum': 11, 'port': 6911, 'nom': "Payload 2"},
    'LB1': {'gpcBceNum': 12, 'port': 6912, 'nom': "Launch Bus 1"},
    'LB2': {'gpcBceNum': 13, 'port': 6913, 'nom': "Launch Bus 2"},
    'FC5': {'gpcBceNum': 14, 'port': 6914, 'nom': "Flight Critical 5"},
    'FC6': {'gpcBceNum': 15, 'port': 6915, 'nom': "Flight Critical 6"},
    'FC7': {'gpcBceNum': 16, 'port': 6916, 'nom': "Flight Critical 7"},
    'FC8': {'gpcBceNum': 17, 'port': 6917, 'nom': "Flight Critical 8"},
    'MM1': {'gpcBceNum': 18, 'port': 6918, 'nom': "Mass Memory 1"},
    'MM2': {'gpcBceNum': 19, 'port': 6919, 'nom': "Mass Memory 2"},
    'FC1': {'gpcBceNum': 20, 'port': 6920, 'nom': "Flight Critical 1"},
    'FC2': {'gpcBceNum': 21, 'port': 6921, 'nom': "Flight Critical 2"},
    'FC3': {'gpcBceNum': 22, 'port': 6922, 'nom': "Flight Critical 3"},
    'FC4': {'gpcBceNum': 23, 'port': 6923, 'nom': "Flight Critical 4"},
    'IP1': {'gpcBceNum': 24, 'port': 6924, 'nom': "IP1", 'gpc': 1},
    'IP2': {'gpcBceNum': 24, 'port': 6925, 'nom': "IP2", 'gpc': 2},
    'IP3': {'gpcBceNum': 24, 'port': 6925, 'nom': "IP3", 'gpc': 3},
    'IP4': {'gpcBceNum': 24, 'port': 6926, 'nom': "IP4", 'gpc': 4},
    'IP5': {'gpcBceNum': 24, 'port': 6927, 'nom': "IP5", 'gpc': 5},

    '_KYBD1': {'port': 6931, 'nom': "DPS IDP Keyboard 1"},
    '_KYBD2': {'port': 6932, 'nom': "DPS IDP Keyboard 2"},
    '_KYBD3': {'port': 6933, 'nom': "DPS IDP Keyboard 3"},

    '_IDP1': {'port': 6941, 'nom': "MEDS IDP/MDU 1533B Bus 1"},
    '_IDP2': {'port': 6942, 'nom': "MEDS IDP/MDU 1533B Bus 2"},
    '_IDP3': {'port': 6943, 'nom': "MEDS IDP/MDU 1533B Bus 3"},
    '_IDP4': {'port': 6944, 'nom': "MEDS IDP/MDU 1533B Bus 4"},

    '_FF1_mdmIO': {'port': 6950, 'nom': "MDM FF1 I/O"},

    '_NSP1_data': {'port': 6960, 'nom': "NSP1 to PCMMU"},
    '_NSP2_data': {'port': 6960, 'nom': "NSP1 to PCMMU"},

    '_GSE_PCMMU_T0': {'port': 6970, 'nom': "PCCMU to GSE via T-0 umbilical"},

    '_LPS_FR1_CDBFR': {'port': 6501, 'nom': "LPS FR1 CDBFR"},

    '__SIMCONTROL': {'port': 6700, 'nom': 'Simulation Control'},
}

bceNumToBusConfig = {}
for _name, _cfg in busConfig.items():
    if 'gpcBceNum' in _cfg:
        bceNumToBusConfig[_cfg['gpcBceNum']] = _cfg
        _cfg['name'] = _name

MCAST_GROUP = "239.255.1.1"

# EVERY BUS PORT DERIVES FROM ONE BASE, so a second complete simulation can
# run beside the first without the two fighting over sockets.  busConfig's
# ports are written as the default base's (6900) gives them, and shifting
# the base moves all of them together -- the same rule, and the same
# NSTS_BUS_PORT_BASE, that yaGPC2 (--port-base) and discretePanel/ use.
# Ports outside the 69xx block move with it too, so nothing is left behind
# to collide.
PORT_BASE_DEFAULT = 6900
PORT_BASE = PORT_BASE_DEFAULT

# WHAT THE WINDOW IS CALLED, before the LRU's own name.  The orbiter has
# eleven MDUs (CRT1-4, CDR1-2, PLT1-2, MFD1-2, AFD1) and a given GPC talks
# only to some of them, so several may be on screen at once -- and with
# --port-base there may be two whole simulations' worth.  "CRT1" alone does
# not say which of those a window belongs to; --title does.
WINDOW_TITLE = "MEDS2 MDU"


def setPortBase(base):
    """Shift every bus port by base - 6900.  Call BEFORE any Bus exists."""
    global PORT_BASE
    base = int(base)
    shift = base - PORT_BASE
    if shift:
        for _cfg in busConfig.values():
            _cfg['port'] += shift
    PORT_BASE = base
    return PORT_BASE


setPortBase(int(os.environ.get("NSTS_BUS_PORT_BASE", PORT_BASE_DEFAULT)))


def _clock_log(text):
    """NSTS_CLOCK_LOG=<file>: one line per header-clock message, stamped with
    the host's wall time -- 'send' as the IDP forwards a GPC time fill, 'draw'
    as the MDU takes it -- so a header clock that runs fast or late can be set
    against what the GPC actually sent and when."""
    path = env('NSTS_CLOCK_LOG')
    if not path:
        return
    try:
        import time as _t
        with open(path, 'a') as fh:
            fh.write("%.3f %s\n" % (_t.time(), text))
    except Exception:
        pass


class BusMsg(object):
    """A bus message: `length16` halfwords, addressable as `data16`."""

    __slots__ = ('length16', 'data16')

    def __init__(self, length16):
        self.length16 = length16
        self.data16 = np.zeros(length16, dtype='<u2')

    @staticmethod
    def FromNetBuf(buf):
        n = (len(buf) + 1) // 2
        msg = BusMsg(n)
        raw = bytearray(n * 2)
        raw[0:len(buf)] = buf[0:min(len(buf), n * 2)]
        msg.data16 = np.frombuffer(bytes(raw), dtype='>u2').astype('<u2')
        return msg

    def getBytes(self):
        return self.data16.astype('>u2').tobytes()

    def __str__(self):
        return ' '.join('%04x' % w for w in self.data16)


class Bus(object):
    """One simulated bus.  `onReceive(cb, obj)` mirrors the original, whose
    callbacks are invoked as `cb(obj, busID, msg, remote)`."""

    # Which interface the simulated buses live on.  Every LRU is a process on
    # this machine, so the default is loopback; NSTS_BUS_IFACE takes a local
    # address to run a bus across a real network instead.  The interface MUST
    # be pinned -- joining the group without naming one delivers every
    # datagram twice on some platforms.
    IFACE = env('NSTS_BUS_IFACE', "127.0.0.1")
    SELF_ECHO_MAX = 1024

    _all = []

    def __init__(self, busID, busDesc, isShuttleBus=False, iua=0x00):
        self.busID = busID
        self.busDesc = busDesc
        self.isShuttleBus = isShuttleBus
        self.iua = iua
        self.recvCB = None
        self.cbObj = None
        self.selfEcho = []
        self.server = None
        self._notifier = None
        self._pumped = False             # serviced by BusPump, not Qt
        self._startMulticast()
        Bus._all.append(self)

    def _startMulticast(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
        except (AttributeError, OSError):
            pass
        s.bind(('', self.busDesc['port']))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 128)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                     socket.inet_aton(Bus.IFACE))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                     socket.inet_aton(MCAST_GROUP) + socket.inet_aton(Bus.IFACE))
        # A BIGGER RECEIVE BUFFER, because the default loses display fills.
        # GPCIPL sends its menu as one 509-halfword DISPLAY_FILL inside a burst
        # of seven such fills back to back, and the default buffer is not deep
        # enough to hold the burst while the display is busy drawing.  The OS
        # caps this at net.core.rmem_max and silently gives less than asked, so
        # the achieved size is logged rather than assumed.
        want = int(envnum('NSTS_BUS_RCVBUF', 4194304))
        try:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, want)
            got = s.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)
            print("bus %d: recv buffer %d bytes%s" % (
                self.busDesc['port'], got,
                (" (asked %d; raise net.core.rmem_max)" % want) if got < want else ""))
        except OSError as e:
            print("bus %d: could not set recv buffer: %s" % (self.busDesc['port'], e))
        s.setblocking(False)
        self.server = s
        self._notifier = QSocketNotifier(s.fileno(), QSocketNotifier.Type.Read)
        self._notifier.activated.connect(self._readable)

    def _readable(self, _fd):
        # Drain the socket: one activation may cover many datagrams.
        while True:
            try:
                message, remote = self.server.recvfrom(65536)
            except (BlockingIOError, InterruptedError):
                return
            except OSError:
                return
            self._recvMessage(message, remote)

    def onReceive(self, recvCB, cbObj=None):
        self.recvCB = recvCB
        self.cbObj = cbObj

    def serviceOffGuiThread(self):
        """Hear this bus on the BusPump thread instead of the GUI thread; the
        receive callback then runs there too.  See BusPump."""
        if self._pumped:
            return
        if self._notifier is not None:
            self._notifier.setEnabled(False)
            self._notifier = None
        self._pumped = True
        BusPump.get().add(self)

    def _isSelfEcho(self, message):
        for i, buf in enumerate(self.selfEcho):
            if buf == message:
                del self.selfEcho[i]
                return True
        return False

    def _noteSent(self, buf, ln):
        self.selfEcho.append(bytes(buf[0:ln]))
        while len(self.selfEcho) > Bus.SELF_ECHO_MAX:
            self.selfEcho.pop(0)

    def _recvMessage(self, message, remote):
        if self._isSelfEcho(message):
            return
        if self.isShuttleBus:
            if len(message) == 0 or message[0] != self.iua:
                return
            message = message[2:]
        msg = BusMsg.FromNetBuf(message)
        if self.recvCB:
            self.recvCB(self.cbObj, self.busID, msg, remote)
        else:
            print("RECV UNHANDLED", self.busID, msg)

    def send(self, data, ln=None):
        if ln is None:
            ln = len(data)
        self._noteSent(data, ln)
        try:
            self.server.sendto(bytes(data[0:ln]), (MCAST_GROUP, self.busDesc['port']))
        except OSError as e:
            print("bus %d: send failed: %s" % (self.busDesc['port'], e))

    def sendMsg(self, msg):
        body = msg.getBytes()
        if not self.isShuttleBus:
            self.send(body, len(body))
            return
        buf = bytearray(len(body) + 2)
        buf[0] = self.iua
        buf[2:] = body
        self.send(buf, len(buf))

    def close(self):
        if self._notifier is not None:
            self._notifier.setEnabled(False)
            self._notifier = None
        if self._pumped:
            # The pump may be reading the socket this moment: let it let go
            # of the socket first, on its own thread.
            self._pumped = False
            BusPump.get().remove(self, then=self._closeSocket)
            return
        self._closeSocket()

    def _closeSocket(self):
        if self.server is not None:
            try:
                self.server.close()
            except OSError:
                pass
            self.server = None


class BusPump(object):
    """A THREAD THAT ANSWERS THE BUS WHILE THE WINDOWS DRAW.

    A display unit's reply to a GPC poll is due within milliseconds (GPCIPL
    allows 5 ms), and the IDP used to hear its buses through QSocketNotifier,
    on the one thread that also draws every MDU.  Whatever held that thread
    held every reply with it: a long redraw, or a graphics driver throttling
    buffer swaps for windows nobody can see, as NVIDIA's does behind a locked
    screen.  The GPC then waits on its display, its simulated clock falls
    behind the wall, and I/O errors and fail-to-syncs follow -- an overnight
    two-GPC run lost 1h14m and its redundant set behind a screen lock
    (gpc-causes #144).

    An IDP draws nothing and reaches its MDUs only over UDP (the _IDPn bus),
    so its buses and its heartbeat are serviced here, on a thread of their
    own, while the MDUs keep theirs on the GUI thread.  From IDP.start() on,
    EVERYTHING an IDP does runs on this thread: its DEUUnit, its replies, its
    fills to the MDUs, IDP POWER and DEU LOAD (both arrive as bus messages).
    Nothing on the GUI thread touches an IDP after start() -- keep it that
    way, or take a lock.  NSTS_IDP_THREAD=0 puts the IDPs back on the GUI
    thread."""

    _instance = None
    _instanceLock = threading.Lock()

    @classmethod
    def get(cls):
        with cls._instanceLock:
            if cls._instance is None:
                cls._instance = BusPump()
            return cls._instance

    def __init__(self):
        self._sel = selectors.DefaultSelector()
        self._lock = threading.Lock()
        self._calls = []
        self._timers = []                # heap of [due, seq, periodS, fn, live]
        self._seq = 0
        self._wakeR, self._wakeW = os.pipe()
        os.set_blocking(self._wakeR, False)
        os.set_blocking(self._wakeW, False)
        self._sel.register(self._wakeR, selectors.EVENT_READ, None)
        # A thread that wants the GIL waits for the holder to give it up, and
        # CPython asks the holder only once per switch interval: 5 ms by
        # default, the whole of GPCIPL's reply window, while the GUI thread
        # runs a great deal of Python per frame.
        sys.setswitchinterval(0.001)
        self._thread = threading.Thread(target=self._run, name="BusPump",
                                        daemon=True)
        self._thread.start()

    def call(self, fn):
        """Run fn on the pump thread, soon.  Safe from any thread."""
        with self._lock:
            self._calls.append(fn)
        try:
            os.write(self._wakeW, b'x')
        except (BlockingIOError, InterruptedError):
            pass                         # full: a wake is already pending

    def callAndWait(self, fn, timeout=5.0):
        """Run fn on the pump thread and RETURN WHAT IT RETURNS.

        call() is fire-and-forget, which is right for everything that drives
        the bus -- nothing waits on a fill.  A snapshot is the exception:
        whoever asked for it is holding a file open, and reading an IDP from
        any other thread is the one thing this class exists to prevent.

        Never call this FROM the pump thread; it would wait for itself.
        """
        box = {}
        done = threading.Event()

        def run():
            try:
                box['value'] = fn()
            except BaseException as e:      # noqa: BLE001 - handed to the caller
                box['error'] = e
            finally:
                done.set()

        self.call(run)
        if not done.wait(timeout):
            raise TimeoutError("the bus pump did not answer within %.1f s"
                               % timeout)
        if 'error' in box:
            raise box['error']
        return box.get('value')

    def add(self, bus):
        self.call(lambda: self._sel.register(bus.server, selectors.EVENT_READ, bus))

    def remove(self, bus, then=None):
        def go():
            try:
                self._sel.unregister(bus.server)
            except (KeyError, ValueError):
                pass
            if then is not None:
                then()
        self.call(go)

    def every(self, ms, fn):
        """Call fn every `ms` milliseconds on the pump thread.  Returns a
        handle whose stop() cancels it, as the QTimer it stands in for."""
        entry = [0.0, 0, ms / 1000.0, fn, True]

        class Handle(object):
            def stop(self_):
                entry[4] = False

        def arm():
            self._seq += 1
            entry[0] = time.monotonic() + entry[2]
            entry[1] = self._seq
            heapq.heappush(self._timers, entry)
        self.call(arm)
        return Handle()

    @staticmethod
    def _guard(fn, *args):
        # As a Qt slot would: report the exception and keep serving.
        try:
            fn(*args)
        except Exception:
            traceback.print_exc()

    def _run(self):
        while True:
            timeout = None
            if self._timers:
                timeout = max(0.0, self._timers[0][0] - time.monotonic())
            try:
                events = self._sel.select(timeout)
            except OSError:
                events = []
            for key, _mask in events:
                if key.data is None:
                    try:
                        while os.read(self._wakeR, 4096):
                            pass
                    except (BlockingIOError, InterruptedError):
                        pass
                elif key.data.server is not None:
                    self._guard(key.data._readable, None)
            with self._lock:
                calls, self._calls = self._calls, []
            for fn in calls:
                self._guard(fn)
            now = time.monotonic()
            while self._timers and self._timers[0][0] <= now:
                entry = heapq.heappop(self._timers)
                if not entry[4]:
                    continue
                self._guard(entry[3])
                # Late is late: after a stall carry on from now rather than
                # firing every missed beat back to back.
                entry[0] = max(entry[0] + entry[2], now)
                self._seq += 1
                entry[1] = self._seq
                heapq.heappush(self._timers, entry)


class LRU(object):
    """com/lru.civet -- an LRU is a thing with busses on it."""

    def __init__(self, config):
        self.config = config
        self.id = config.get('id')
        self._setupSimControl()
        self._setupBuses()
        self._scReady()

    def _setupSimControl(self):
        cfg = busConfig['__SIMCONTROL']
        self.simControlBus = Bus('__SIMCONTROL', cfg)

    def _recvSimControl(self, busID, msg, remote):
        print("%s: CONTROL %s recv %s" % (self.id, busID, msg))

    def _scReady(self):
        pass

    def _setupBuses(self):
        self.bus = {}
        self.busRecvCB = {}
        for busName in self.config.get('busses', []):
            if busName not in busConfig:
                print("UNDEFINED BUS: ", busName)
            else:
                self.bus[busName] = Bus(busName, busConfig[busName])
        for bid, bus in self.bus.items():
            bus.onReceive(self.recvBus, self)
            self.busRecvCB[bid] = None

    def recvBus(self, t, busID, msg, remote):
        cb = self.busRecvCB.get(busID)
        if cb is not None:
            cb(busID, msg, remote)
        else:
            print("%s: %s recv %s" % (self.id, busID, msg))


# ===========================================================================
# gpc/util.coffee -- PackedBits
#
# Bit descriptors run MSB (bit 15) first; '_' is a don't-care bit, '0'/'1'
# are the fixed opcode bits, a letter names a field.
# ===========================================================================
class PackedBits(object):
    def __init__(self, descStr=None):
        self.descStr = descStr
        self.bitLen = 0
        self.desc = self.makeDesc(descStr) if descStr else None

    @staticmethod
    def _bin(s):
        return int(s, 2) if s else 0

    def makeDesc(self, s):
        self.bitLen = len(s)
        desc = {}
        fields = re.sub(r'[01]', '', re.sub(r'(.)\1+', r'\1', s))
        if '/' in fields:
            desc['len'] = 2
            tail = fields.split('/')[1]
            if tail.startswith('I'):
                desc['type'] = 'SI' if 'd' in fields else 'RI'
            elif tail.startswith('X'):
                desc['type'] = 'RS'
        else:
            desc['len'] = 1
            desc['type'] = 'SRS' if 'd' in fields else 'RR'
        desc['mask'] = self.getMask(s)
        desc['maskedVal'] = self.getMaskedDescVal(s)
        desc['f'] = self.makeAllFieldDescs(s)
        desc['origLen'] = desc['len']
        return desc

    def getMask(self, desc):
        w1 = desc.split('/')[0]
        mask = re.sub(r'[a-zA-Z_]', '0', re.sub(r'[01]', '1', w1))
        return self._bin(mask)

    def getMaskedDescVal(self, desc):
        w1 = desc.split('/')[0]
        return self._bin(re.sub(r'[a-zA-Z_]', '0', w1))

    def makeFieldDesc(self, s, fname):
        return {'f': fname,
                'mask': self.getFieldMask(s, fname),
                'shift': self.getFieldShft(s, fname),
                'bitlen': self.getFieldBitlen(s, fname)}

    def makeAllFieldDescs(self, s):
        ss = s.split('/')
        fields = re.sub(r'[01]', '', re.sub(r'(.)\1+', r'\1', ss[0]))
        fd = {}
        for f in fields:
            fd[f] = self.makeFieldDesc(ss[0], f)
        return fd

    @staticmethod
    def getFieldDesc(desc, f):
        return ''.join('1' if c == f else '0' for c in desc)

    def getFieldMask(self, desc, fld):
        return int(self.getFieldDesc(desc, fld), 2)

    def getFieldShft(self, desc, fld):
        d = self.getFieldDesc(desc, fld)
        return (len(d) - d.rfind('1')) - 1

    def getFieldBitlen(self, desc, fld):
        return self.getFieldDesc(desc, fld).count('1')

    @staticmethod
    def getField(data, field):
        return (data & field['mask']) >> field['shift']

    @staticmethod
    def fld(fd, v):
        if fd:
            return (int(v) << fd['shift']) & fd['mask']
        return 0

    def setFld(self, t, fd, v):
        tv = t & ((2 ** self.bitLen - 1) ^ fd['mask'])
        return tv | ((v << fd['shift']) & fd['mask'])


# ===========================================================================
# meds/deuFCW.coffee -- DEU Format Control Words
#
# The DEU drives a vector CRT display unit (and in the MEDS upgrade the MDUs
# emulate the vector drawing).  FCWs are the display list stored on the DEU
# and executed to produce the vector drawing instructions.
#
# Screen geometry: the beam sits on a modular grid -- the position field is
# eleven bits and the word above it writes the axis' reference register
# instead, so the coordinate wraps at the grid size.
# ===========================================================================

ANGLE_UNITS = 4096      # op 4 character-rotation units per full turn
ANGINC_UNITS = 32768    # op 5 angle-increment units per turn
AU_WIDTH = 1024
AU_HEIGHT = 731

# THERE ARE TWO COORDINATE SYSTEMS ON THIS BUS, and which one a word is in
# depends on WHO WROTE IT.  MEDS's constants were calibrated against captured
# display memory -- and the only display memory anyone could capture before
# PASS ran was GPCIPL's.  The DFG constants are the flight software's own.
GEOMS = {
    'gpcipl': {'grid': 2048, 'col0': 1573, 'row0': 364, 'absX': 1555, 'absY': 364},
    'dfg':    {'grid': 1536, 'col0': 1042, 'row0': 366, 'absX': 1024, 'absY': 1902},
}

# Start in GPCIPL's frame, because GPCIPL is what comes first in every run and
# its menu has to be readable to work the IPL sequence.
_geomName = 'dfg' if env('NSTS_DEU_GEOM') == 'dfg' else 'gpcipl'
_geom = GEOMS[_geomName]


def setGeom(name=None):
    """Live toggle (Shift+V in an MDU window).  GPCIPL's menu and PASS's
    displays are in different frames, and which you need depends on where you
    are in the run."""
    global _geomName, _geom
    if name is not None:
        _geomName = name
    else:
        _geomName = 'gpcipl' if _geomName == 'dfg' else 'dfg'
    _geom = GEOMS.get(_geomName, GEOMS['dfg'])
    return _geomName


def geomName():
    return _geomName


def geom():
    return _geom


COL_PITCH = 19          # screen units per character column (small characters)
ROW_PITCH = 27          # screen units per character row
COL_PITCH_L = 24        # ... large characters (SIZE=L)
ROW_PITCH_L = 32

# TELLING THE TWO COORDINATE CONVENTIONS APART.  This is a discriminator, NOT
# a legality test: what survives is that the +/-512 by +/-365 band separates
# the populations cleanly.
AU_X_LIMIT = 512
AU_Y_LIMIT = 365


def signed11(v):
    raw = v & 0x7ff
    return raw - 2048 if raw >= 1024 else raw


def inAUGrid(v, axis):
    s = signed11(v)
    lim = AU_Y_LIMIT if axis == 'y' else AU_X_LIMIT
    return -lim <= s <= lim


def screenX(x):
    return ((x - _geom['absX'] + _geom['grid']) % _geom['grid']) / COL_PITCH


def screenY(y):
    return ((_geom['absY'] - y + _geom['grid']) % _geom['grid']) / ROW_PITCH


def cellCol(x):
    return ((x - _geom['col0'] + _geom['grid']) % _geom['grid']) / COL_PITCH


def cellRow(y):
    return ((_geom['row0'] - y + _geom['grid']) % _geom['grid']) / ROW_PITCH


# Beam modes in FCW2's low three bits.  Bits 1-0 select the generator and bit
# 2 is the upright bit, which rotation clears.
MODE = {'VECTOR': 5, 'CHAR_SMALL': 6, 'CHAR_LARGE': 7}
GEN = {'VECTOR': 1, 'CHAR_SMALL': 2, 'CHAR_LARGE': 3}
UPRIGHT = 0x4

# The REPEAT word: the number of repeats is (REPT_BASE - <FCW>)
REPT_BASE = 0x0841


def wordsFromBytes(buf):
    """A `.dfb` file is the halfword stream as it goes over the bus: big
    endian, and the order the critical-format load module holds it in."""
    n = len(buf) // 2
    return [((buf[2 * i] << 8) | buf[2 * i + 1]) for i in range(n)]


def bytesFromWords(words):
    out = bytearray(len(words) * 2)
    for i, w in enumerate(words):
        out[2 * i] = (w >> 8) & 0xff
        out[2 * i + 1] = w & 0xff
    return bytes(out)


# The MEDS alternate character set, keyed by symbol number.  No alternate
# glyphs are loaded, so these draw their DEUCharset counterparts.
ALTCHARSET = {
    0x14: 'filled/shaded circle',
    0x15: 'filled/shaded diamond',
    0x16: 'cross, large',
    0x17: 'cross, small',
    0x18: 'Shuttle planform',
    0x19: 'Shuttle symbol',
    0x1c: 'heading arrow',
}

DEU_CHARSET = {
    0x00: '\0', 0x01: ']', 0x02: '[', 0x03: 'SELF TEST',
    0x04: '˙', 0x05: '¨', 0x06: '∇', 0x07: '·',
    0x08: '\b', 0x09: '÷', 0x0a: 'ߠ', 0x0b: '▷',
    0x0c: '◁', 0x0d: '\r', 0x0e: 'ߡ', 0x0f: 'ߟ',
    0x10: 'α', 0x11: 'β', 0x12: 'ρ', 0x13: 'ω',
    0x14: 'ε', 0x15: 'Ω', 0x16: '_', 0x17: '⎯',
    0x18: 'ˈ', 0x19: '◊', 0x1a: '¥', 0x1b: '°',
    0x1c: '↑', 0x1d: '↓', 0x1e: '→', 0x1f: '←',
    0x20: ' ', 0x21: '!', 0x22: '~', 0x23: '#', 0x24: '√', 0x25: '%',
    0x26: '&', 0x27: "'", 0x28: '(', 0x29: ')', 0x2a: '*', 0x2b: '+',
    0x2c: ',', 0x2d: '-', 0x2e: '.', 0x2f: '/',
    0x30: '0', 0x31: '1', 0x32: '2', 0x33: '3', 0x34: '4',
    0x35: '5', 0x36: '6', 0x37: '7', 0x38: '8', 0x39: '9',
    0x3a: ':', 0x3b: ';', 0x3c: '<', 0x3d: '=', 0x3e: '>', 0x3f: '?',
    0x40: 'γ',
    0x41: 'A', 0x42: 'B', 0x43: 'C', 0x44: 'D', 0x45: 'E', 0x46: 'F',
    0x47: 'G', 0x48: 'H', 0x49: 'I', 0x4a: 'J', 0x4b: 'K', 0x4c: 'L',
    0x4d: 'M', 0x4e: 'N', 0x4f: 'O', 0x50: 'P', 0x51: 'Q', 0x52: 'R',
    0x53: 'S', 0x54: 'T', 0x55: 'U', 0x56: 'V', 0x57: 'W', 0x58: 'X',
    0x59: 'Y', 0x5a: 'Z',
    0x5b: 'Σ', 0x5c: 'θ', 0x5d: '‾', 0x5e: 'π',
    0x5f: 'Ф', 0x60: 'Ψ',
    0x61: 'a', 0x62: 'b', 0x63: 'c', 0x64: 'd', 0x65: 'e', 0x66: 'f',
    0x67: 'g', 0x68: 'h', 0x69: 'i', 0x6a: 'j', 0x6b: 'k', 0x6c: 'l',
    0x6d: 'm', 0x6e: 'n', 0x6f: 'o', 0x70: 'p', 0x71: 'q', 0x72: 'r',
    0x73: 's', 0x74: 't', 0x75: 'u', 0x76: 'v', 0x77: 'w', 0x78: 'x',
    0x79: 'y', 0x7a: 'z',
    0x7b: 'σ', 0x7c: '|', 0x7d: '', 0x7e: 'λ', 0x7f: '∆',
}

# FCW Word Definitions.  See the notes in meds/deuFCW.coffee: op 0 no-op and
# REPEAT, op 1 branch, op 2 sublist, op 3 the mode registers, op 4 rotation,
# op 5 major step / angle increment, op 6 land-site label, op 7 circle /
# minor step, op 8/9 beam position, op A/B vectors, op C..F glyph pairs.
FCWS_DEFS = {
    'NOOP':    {'d': '0000000000000000', 'nom': {}},
    'REPT':    {'d': '0000nnnnnnnnnnnn', 'nom': {'n': 'raw'}},
    'BRANCH':  {'d': '0001aaaaaaaaaaaa', 'nom': {'a': 'addr12'}},
    'SUBLIST': {'d': '0010ssssnnnnnnnn', 'nom': {'s': 'sector', 'n': 'count'}},
    'FCW2':    {'d': '001100eidpqrrmmm',
                'nom': {'e': 'eor', 'i': 'incr', 'd': 'dly', 'p': 'polarX',
                        'q': 'polarY', 'r': 'xyRef', 'm': 'mode'}},
    'FCW3':    {'d': '001101_psqcccccc',
                'nom': {'p': 'spchar', 's': 'select', 'q': 'intensity',
                        'c': 'color'}},
    'FCW1':    {'d': '001110dbtoasik__',
                'nom': {'d': 'dash', 'b': 'blink', 't': 'typ', 'o': 'ocr',
                        'a': 'axisY', 's': 'sp', 'i': 'intensity',
                        'k': 'blank'}},
    'VDISP':   {'d': '001111vvvvvvvvvv', 'nom': {'v': 'vdisp'}},
    'ROT':     {'d': '0100aaaaaaaaaaaa', 'nom': {'a': 'angle'}},
    'MAJINC':  {'d': '0101_sssssssssss', 'nom': {'s': 'step'}},
    'MININC':  {'d': '011110__ssssssss', 'nom': {'s': 'step'}},
    'SPTYPE':  {'d': '011111__ssssssss', 'nom': {'s': 'step'}},
    'CIRCLE':  {'d': '011101rrrrrrrrr_', 'nom': {'r': 'radius'}},
    'LSITE1':  {'d': '01100aaaaaaabbbb', 'nom': {'a': 'char1', 'b': 'char2hi'}},
    'LSITE2':  {'d': '01101bbbccccccc_', 'nom': {'b': 'char2lo', 'c': 'char3'}},
    'XPOS':    {'d': '1000txxxxxxxxxxx', 'nom': {'t': 'translate', 'x': 'x'}},
    'YPOS':    {'d': '1001tyyyyyyyyyyy', 'nom': {'t': 'translate', 'y': 'y'}},
    'VECA':    {'d': '1010mjssssssssss',
                'nom': {'m': 'yMajor', 'j': 'signDiffer', 's': 'slope'}},
    'VECB':    {'d': '1011nlllllllllll', 'nom': {'n': 'negative', 'l': 'len'}},
    'CHAR2':   {'d': '11aaaaaaabbbbbbb', 'nom': {'a': 'char1', 'b': 'char2'}},
}


class FCW(PackedBits):
    DEUCharset = DEU_CHARSET
    FCWS = FCWS_DEFS

    def __init__(self):
        PackedBits.__init__(self)
        self.makeFCWTable()
        self.makeCharToDEU()

    # -- word <-> descriptor ------------------------------------------------
    def encodeFCW(self, desc):
        if desc.get('nm') == 'REPT':
            return (REPT_BASE - (desc.get('count') or 0)) & 0xffff
        d = desc
        if desc.get('nm') == 'CHAR2':
            d = dict(desc)
            d['char1'] = self.toGlyph(desc.get('char1'))
            d['char2'] = self.toGlyph(desc.get('char2'))
        return self.encode(d)

    def decodeFCW(self, hw):
        hw = hw & 0xffff
        desc = self.decode(hw)
        if desc is None:
            return None
        out = {'nm': desc['nm'], 'v': dict(desc['v']), 'word': hw}
        v = out['v']
        nm = out['nm']
        if nm == 'REPT':
            v['count'] = (REPT_BASE - hw) & 0xffff
        elif nm == 'MAJINC':
            v['step'] = self.signExtend(v['step'], 11)
        elif nm in ('MININC', 'SPTYPE'):
            v['step'] = self.signExtend(v['step'], 8)
        elif nm == 'ROT':
            v['degrees'] = v['angle'] * 360 / ANGLE_UNITS
        elif nm == 'BRANCH':
            # The word carries TWELVE address bits.  Bit 12 is not one of
            # them -- the sector that completes the address comes from an op 2
            # SUBLIST word ahead of the branch, and defaults to 1 because
            # display lists live in the upper half of the 8K.
            v['addr12'] = hw & 0x0fff
            v['addr'] = hw & 0x1fff
        elif nm == 'CHAR2':
            v['g1'] = v['char1']
            v['g2'] = v['char2']
            v['char1'] = self.DEUCharset.get(v['char1'])
            v['char2'] = self.DEUCharset.get(v['char2'])
        return out

    def lsiteText(self, w1, w2):
        """The three characters of a land-site label, from its op 6 pair."""
        a = (w1 >> 4) & 0x7f
        b = (((w1 & 0x0f) << 3) | ((w2 >> 8) & 0x07)) & 0x7f
        c = (w2 >> 1) & 0x7f
        return ''.join((self.DEUCharset.get(g) or ' ') for g in (a, b, c))

    @staticmethod
    def signExtend(v, bits):
        sign = 1 << (bits - 1)
        return v - (1 << bits) if (v & sign) else v

    def toGlyph(self, c):
        if isinstance(c, (int, float)) and not isinstance(c, bool):
            return int(c)
        g = self.chrToDEU.get(c)
        return int(g) if g is not None else 0x20

    # -- word constructors --------------------------------------------------
    def noop(self):
        return 0x0000

    def repeat(self, n):
        return (REPT_BASE - n) & 0xffff

    def branch(self, addr):
        return 0x1000 | (addr & 0x1fff)

    def subList(self, n, addr):
        return [self.subListWord(n, addr), self.branch(addr)]

    def subListWord(self, n, addr):
        return 0x2000 | ((((addr or 0) >> 12) & 0xf) << 8) | (n & 0x00ff)

    def attrMode(self, o=None):
        o = o or {}
        return (0x3800 | (0x200 if o.get('dash') else 0)
                | (0x100 if o.get('blink') else 0)
                | (0x020 if o.get('axisY') else 0)
                | (0x008 if o.get('intensity') else 0))

    def charMode(self, o=None):
        o = o or {}
        mode = MODE['CHAR_LARGE'] if o.get('large') else MODE['CHAR_SMALL']
        if o.get('rotated'):
            mode = mode & ~0x4
        return (0x3000 | mode | (0x40 if o.get('alt') else 0)
                | (0x20 if (o.get('alt') and o.get('rotated')) else 0))

    def vectorBegin(self):
        return 0x3000 | MODE['VECTOR']

    def endOfRefresh(self):
        return 0x3200

    def colorMode(self, code=None):
        if code is not None:
            return 0x3400 | 0x80 | (code & 0x3f)
        return 0x3400 | 40

    def colorClear(self):
        return 0x3400

    def intensityMode(self, hi, code=None):
        base = self.colorMode(code) if code is not None else self.colorClear()
        return base | (0x40 if hi else 0)

    def valueDisplay(self, n):
        return 0x3c00 | (n & 0x3ff)

    def rotation(self, deg):
        return self.angle(jsround(deg * ANGLE_UNITS / 360))

    def angle(self, a):
        return 0x4000 | (((a % ANGLE_UNITS) + ANGLE_UNITS) % ANGLE_UNITS)

    def majorInc(self, units):
        return 0x5000 | (units & 0x7ff)

    def minorInc(self, units):
        return 0x7800 | (units & 0xff)

    def specialType(self, units):
        return 0x7c00 | (units & 0xff)

    def circle(self, r):
        return 0x7400 | ((jsround(r) & 0x1ff) << 1)

    def circleRun(self, r, fcw2=None):
        fcw2 = (fcw2 if fcw2 is not None else self.charMode({})) & 0xffff
        return [fcw2 | 0x0005, self.circle(r), fcw2]

    def angleIncDeg(self, deg):
        return self.angleInc(jsround(deg * ANGINC_UNITS / 360))

    def angleInc(self, units):
        return 0x5000 | (jsround(units) & 0xfff)

    def lsiteWords(self, text):
        a, b, c = (self.toGlyph(text[i] if i < len(text) else ' ') for i in range(3))
        return [0x6000 | ((a & 0x7f) << 4) | ((b >> 3) & 0x0f),
                0x6800 | ((b & 0x07) << 8) | ((c & 0x7f) << 1)]

    def xPosition(self, x):
        return 0x8000 | (int(x) & 0x7ff)

    def yPosition(self, y):
        return 0x9000 | (int(y) & 0x7ff)

    def translateX(self, x=0):
        return 0x8800 | (x & 0x7ff)

    def translateY(self, y=0):
        return 0x9800 | (y & 0x7ff)

    def vecSlope(self, o=None):
        o = o or {}
        return (0xa000 | (0x800 if o.get('yMajor') else 0)
                | (0x400 if o.get('signDiffer') else 0)
                | (int(o.get('slope', 0)) & 0x3ff))

    def vecExtent(self, major):
        return 0xb000 | (0x800 if major < 0 else 0) | (int(abs(major)) & 0x7ff)

    def glyphPair(self, g1, g2):
        return 0xc000 | ((g1 & 0x7f) << 7) | (g2 & 0x7f)

    def glyphSingle(self, g):
        return 0xc000 | (g & 0x7f)

    def carrtn(self):
        return 0xc00d

    def deuReturn(self):
        return 0x19ee

    # Character cell -> beam register.  Rounded: a fractional cell is a real
    # beam position, and the position field is an integer.
    def cellX(self, col):
        return jsround(_geom['col0'] + COL_PITCH * col) % _geom['grid']

    def cellY(self, row):
        return jsround(_geom['row0'] - ROW_PITCH * row) % _geom['grid']

    def absX(self, n):
        return (_geom['absX'] + n) % _geom['grid']

    def absY(self, n):
        return (_geom['absY'] - n) % _geom['grid']

    def positionRun(self, col, row):
        return [self.noop(), self.xPosition(self.cellX(col)),
                self.yPosition(self.cellY(row))]

    def vector(self, x0, y0, x1, y1):
        """One straight segment in character-cell coordinates."""
        dx = COL_PITCH * (x1 - x0)
        dy = -ROW_PITCH * (y1 - y0)         # beam Y decreases going down
        yMajor = abs(dy) > abs(dx)
        major = jsround(dy if yMajor else dx)
        minor = jsround(abs(dx if yMajor else dy))
        am = abs(major)
        if minor and am:
            slope = 2 * min(math.floor((minor * 1024 + am) / (2 * am)), 511)
        else:
            slope = 0
        return [self.vectorBegin(), self.xPosition(self.cellX(x0)),
                self.yPosition(self.cellY(y0)),
                self.vecSlope({'yMajor': yMajor, 'signDiffer': dx * dy < 0,
                               'slope': slope}),
                self.vecExtent(major), self.charMode({})]

    def chars(self, t):
        """Text -> glyph-pair FCWs, two glyphs per word."""
        out = []
        i = 0
        while i < len(t):
            if i + 1 < len(t):
                out.append(self.glyphPair(self.toGlyph(t[i]), self.toGlyph(t[i + 1])))
            else:
                out.append(self.glyphSingle(self.toGlyph(t[i])))
            i += 2
        return out

    # -- table construction -------------------------------------------------
    def makeFCWTable(self):
        self.descByOp = {}
        self.opByMask = {}
        self.orderedMasks = []
        for nom, dfn in self.FCWS.items():
            desc = self.makeDesc(dfn['d'])
            desc['nm'] = nom
            desc['nom'] = dfn['nom']
            desc['revNom'] = {}
            for k, v in desc['nom'].items():
                desc['revNom'][v] = k
            self.descByOp[nom] = desc
            if desc['mask'] not in self.opByMask:
                self.orderedMasks.append(desc['mask'])
                self.opByMask[desc['mask']] = {}
            self.opByMask[desc['mask']][desc['maskedVal']] = desc
        # When matching a halfword we search from more to less specific, so
        # order the masks widest first.
        self.orderedMasks.sort(reverse=True)

    def makeCharToDEU(self):
        self.chrToDEU = {}
        for k, v in self.DEUCharset.items():
            self.chrToDEU[v] = k

    def encode(self, data):
        desc = self.descByOp[data['nm']]
        hw1 = desc['maskedVal']
        for k, v in data.items():
            rn = desc['revNom'].get(k)
            if rn is not None and rn in desc['f']:
                hw1 = hw1 | self.fld(desc['f'][rn], v)
        return hw1

    def decode(self, hw1):
        op = None
        for msk in self.orderedMasks:
            mTbl = self.opByMask[msk]
            hw1msk = hw1 & msk
            if hw1msk in mTbl:
                op = mTbl[hw1msk]
                break
        if not op:
            return None
        op['v'] = {}
        for k, fldd in op['f'].items():
            # A descriptor's don't-care runs ('_') come through as fields with
            # no name; JavaScript quietly parked them under `undefined`.
            nm = op['nom'].get(k)
            if nm is None:
                continue
            op['v'][nm] = self.getField(hw1, fldd)
        return op


# ===========================================================================
# meds/deuProto.coffee -- the DEU / IDP display-keyboard bus protocol
#
# A GPC talks to the four DEUs over the 4 DK buses (DK1..DK4 = BCE 6..9) using
# IUA=10.  Every transaction is one 24-bit command word from the GPC followed
# by data in whichever direction the command names.
#
# The MCDS->MEDS update did not change the basic protocol.  An IDP answers the
# same commands a DEU did; the additions are one new command (the 100-halfword
# MEDS DK buffer transfer) and a couple of new/updated FCWs.
# ===========================================================================

class NS(object):
    """A dot-accessible bag, so `DEU.FUNC.POLL` reads as it did."""

    def __init__(self, **kw):
        self.__dict__.update(kw)

    def items(self):
        return self.__dict__.items()

    def __contains__(self, k):
        return k in self.__dict__

    def get(self, k, d=None):
        return self.__dict__.get(k, d)


class DEU(object):
    # Interface unit address of the display units on the DK bus.
    IUA = 10

    # The 19 command bits are a 10-bit function and a 9-bit halfword count.
    FUNC_SHIFT = 9
    COUNT_MASK = 0x1ff

    FUNC = NS(
        TIME_FILL=0x380,     # the header clock: 7 halfwords
        DISPLAY_FILL=0x38c,  # display data fill -- AND the IPL memory-fill blocks
        FORMAT_FILL=0x394,   # format data fill (a critical-format background)
        MEDS_XFER=0x398,     # MEDS DK buffer transfer, always 100 halfwords
        DUMP=0x3a0,          # memory dump request
        POLL=0x010,          # poll / mode status request
        BITE=0x040,          # BITE status request
        RESET_SPL=0x080,     # reset the scratch pad line
    )
    FUNC_NAME = {}

    # How many halfwords the GPC reads back
    POLL_WORDS = 16          # header, key count, 10 keys, 3 BITE, checksum
    BITE_WORDS = 5
    # The same poll command serves two bus programs: the normal poll reads
    # sixteen halfwords, the mode-status check the DEU loader makes between
    # blocks of a load reads one.
    MODE_STATUS_WORDS = 1

    # The DEU loader's own terminating condition: of its table of fill blocks,
    # the one whose word count is 250 is the last.
    LAST_FILL_WORDS = 250
    DEU_ID_ADDR = 0x001d
    MEDS_XFER_WORDS = 100

    ADDR_MASK = 0x1fff
    MAX_TRANSFER_WORDS = 0x1ff              # 511
    MAX_FILL_PAYLOAD = MAX_TRANSFER_WORDS - 2

    # The DEU memory map: 8192 halfwords.
    DEU_MEMORY_WORDS = 8192
    ADDR = NS(
        CRITICAL_FORMAT=0x0100,   # the critical-format index table and backgrounds
        VAR_DATA_HDR=0x09ee,      # variable data, with a header
        VAR_DATA_NOHDR=0x0a06,    # variable data, no header
        CF_CHECKSUM=0x0f48,
        CONTROL_PROGRAM=0x0f49,   # where the DEU's own IPL load starts
        DISPLAY_HEADER=0x19ee,    # the display header -- where a refresh starts
        UPLINK_IND=0x1a06,
        DYNAMIC=0x1a0e,           # the dynamic portion of the display
        BACKGROUND_TOP=0x1fe4,    # a background is filled ENDING just below here
    )

    # CON80/CFSYSIN's `PAD=111E` -- the fill word of the critical-format
    # buffer, and the word every DFG-generated static format body ends with.
    CF_PAD = 0x111e

    # The poll response header's bits, numbered from the most significant.
    HDR = NS(
        MSG_RESET=0x0800,       # the MSG RESET key is down
        MAJOR_FUNC=0x00c0,      # the major function switch, bits 9-10
        ACK=0x0020,             # the ACK key is down
        KYBD_MSG=0x0008,        # a keyboard message is ready
        SELF_TEST=0x0004,       # stand-alone self test in progress
        BITE_CRITICAL=0x0002,   # critical BITE status present
        IPL_REQUIRED=0x0001,    # the unit needs an IPL
    )
    MAJOR_FUNC_SHIFT = 6
    KEY_COUNT_MASK = 0x003f
    KEY_WORDS = 10

    # THREE keystrokes to a halfword, 5 bits each, most significant first.
    KEYS_PER_WORD = 3
    KEY_BITS = 5
    KEY_COUNT_HIGH = 0xff00

    TIME_FILL_WORDS = 7

    MAX_KEYS = KEY_WORDS * KEYS_PER_WORD     # 30 the buffer can carry
    MAX_KEYS_IPL = 6                         # ...and 6 the monitor takes

    # The 5-bit key codes
    KEY = NS(**{
        '0': 0x00, '1': 0x01, '2': 0x02, '3': 0x03, '4': 0x04, '5': 0x05,
        '6': 0x06, '7': 0x07, '8': 0x08, '9': 0x09,
        'A': 0x0a, 'B': 0x0b, 'C': 0x0c, 'D': 0x0d, 'E': 0x0e, 'F': 0x0f,
        'SYS_SUMM': 0x10, 'OPS': 0x11, 'SPEC': 0x12, 'FAULT_SUMM': 0x13,
        'ITEM': 0x14, 'MINUS': 0x15, 'PLUS': 0x16, 'DECIMAL': 0x17,
        'IO_RESET': 0x18, 'GPC_CRT': 0x19, 'CLEAR': 0x1a, 'RESUME': 0x1b,
        'ACK': 0x1c, 'MSG_RESET': 0x1d, 'EXEC': 0x1e, 'PRO': 0x1f,
    })
    KEY_NAME = {}

    # BITE status register 1.  To communicate with the GPC we must return
    # BITE1_HEALTHY.
    BITE1 = NS(ALWAYS_ONE=0x8000, IPL_DONE=0x4000,
               IPL_ERROR=0x2000, IPL_CIRCUIT_ERROR=0x1000)
    BITE1_HEALTHY = 0x8000 | 0x4000

    # The unit's software status register -- poll response word 15.
    SWSTATUS = NS(INITIALIZED=0x2000, INT_MASK=0x2010)
    SWSTATUS_HEALTHY = 0x2000

    # -- command framing ----------------------------------------------------
    @staticmethod
    def decodeCommand(cmd24):
        cmd = cmd24 & 0xffffff
        func = (cmd >> DEU.FUNC_SHIFT) & 0x3ff
        return {'raw': cmd, 'iua': (cmd >> 19) & 0x1f, 'func': func,
                'count': cmd & DEU.COUNT_MASK,
                'name': DEU.FUNC_NAME.get(func, 'UNKNOWN')}

    @staticmethod
    def encodeCommand(func, count=0):
        return ((DEU.IUA << 19) | ((func & 0x3ff) << DEU.FUNC_SHIFT)
                | (count & DEU.COUNT_MASK)) & 0xffffffff

    # -- the memory-fill message -------------------------------------------
    @staticmethod
    def fillHeader(addr, nWords):
        return [nWords & 0xffff, addr & DEU.ADDR_MASK]

    @staticmethod
    def fillMessages(func, addr, words, limit=None):
        if limit is None:
            limit = DEU.MAX_FILL_PAYLOAD
        out = []
        i = 0
        while i < len(words):
            chunk = list(words[i:i + limit])
            body = DEU.fillHeader(addr + i, len(chunk)) + chunk
            out.append({'func': func, 'addr': addr + i, 'count': len(body),
                        'body': body})
            i += limit
        return out

    @staticmethod
    def parseFill(words):
        if len(words) < 2:
            return None
        n = words[0] & 0xffff
        short = (len(words) - 2) < n
        return {'addr': words[1] & DEU.ADDR_MASK, 'count': n,
                'payload': list(words[2:2 + n]), 'short': short}

    # -- the time fill ------------------------------------------------------
    @staticmethod
    def ibmFloat48(w0, w1, w2):
        """A 48-bit IBM extended float: sign, 7-bit exponent biased by 64, and
        a 40-bit fraction in base 16."""
        sign = -1 if (w0 & 0x8000) else 1
        exp = ((w0 >> 8) & 0x7f) - 64
        frac = ((w0 & 0xff) * 0x100000000) + (w1 * 0x10000) + w2
        return sign * (frac / 0x10000000000) * math.pow(16, exp)

    @staticmethod
    def encodeIbmFloat48(v):
        if not v:
            return [0x4100, 0x0000, 0x0000]
        sign = 0x8000 if v < 0 else 0
        a = abs(v)
        e = 0
        while a >= 1:
            a /= 16.0
            e += 1
        while a < 1.0 / 16:
            a *= 16.0
            e -= 1
        frac = jsround(a * 0x10000000000)
        if frac >= 0x10000000000:
            frac = math.floor(frac / 16)
            e += 1
        return [sign | (((e + 64) & 0x7f) << 8) | int(math.floor(frac / 0x100000000)),
                int(math.floor(frac / 0x10000)) & 0xffff,
                int(frac) & 0xffff]

    @staticmethod
    def timeFillWords(t=None):
        t = t or {}
        return (DEU.encodeIbmFloat48(t.get('mission', 0))
                + DEU.encodeIbmFloat48(t.get('event', 0))
                + [(t.get('conv', 1)) & 0xffff])

    @staticmethod
    def parseTimeFill(words):
        if len(words) != DEU.TIME_FILL_WORDS:
            return None
        return {'mission': DEU.ibmFloat48(words[0], words[1], words[2]),
                'event': DEU.ibmFloat48(words[3], words[4], words[5]),
                'conv': words[6] & 0xffff}

    # -- keystrokes ---------------------------------------------------------
    @staticmethod
    def packKeys(keys):
        words = [0] * DEU.KEY_WORDS
        for i, k in enumerate(list(keys)[:DEU.MAX_KEYS]):
            w = i // DEU.KEYS_PER_WORD
            slot = i % DEU.KEYS_PER_WORD          # 0 is the most significant
            shift = 16 - DEU.KEY_BITS * (slot + 1)
            words[w] |= (k & 0x1f) << shift
        return words

    @staticmethod
    def unpackKeys(words, count):
        out = []
        for i in range(count):
            idx = i // DEU.KEYS_PER_WORD
            w = words[idx] if idx < len(words) else 0
            shift = 16 - DEU.KEY_BITS * ((i % DEU.KEYS_PER_WORD) + 1)
            out.append((w >> shift) & 0x1f)
        return out

    # -- status -------------------------------------------------------------
    @staticmethod
    def checksum(words):
        s = 0
        for w in words:
            s = (s + (w & 0xffff)) & 0xffff
        return (-s) & 0xffff

    @staticmethod
    def pollResponse(o=None):
        o = o or {}
        words = [0] * DEU.POLL_WORDS
        words[0] = (o.get('header') or 0) & 0xffff
        keys = list(o.get('keys') or [])[:DEU.MAX_KEYS]
        words[1] = DEU.KEY_COUNT_HIGH | (len(keys) & DEU.KEY_COUNT_MASK)
        packed = DEU.packKeys(keys)
        for i in range(DEU.KEY_WORDS):
            words[2 + i] = packed[i]
        words[12] = (o['bite1'] if o.get('bite1') is not None else DEU.BITE1_HEALTHY) & 0xffff
        words[13] = (o.get('bite2') or 0) & 0xffff
        words[14] = (o['swStatus'] if o.get('swStatus') is not None else DEU.SWSTATUS_HEALTHY) & 0xffff
        words[15] = DEU.checksum(words[0:15])
        return words

    @staticmethod
    def biteResponse(o=None):
        o = o or {}
        words = [(o['bite1'] if o.get('bite1') is not None else DEU.BITE1_HEALTHY) & 0xffff,
                 (o.get('bite2') or 0) & 0xffff,
                 (o['swStatus'] if o.get('swStatus') is not None else DEU.SWSTATUS_HEALTHY) & 0xffff,
                 (o.get('software') or 0) & 0xffff, 0]
        words[4] = DEU.checksum(words[0:4])
        return words


for _k, _v in DEU.FUNC.items():
    DEU.FUNC_NAME[_v] = _k
for _k, _v in DEU.KEY.items():
    DEU.KEY_NAME[_v] = _k


# ===========================================================================
# meds/deuSPL.coffee -- the scratch pad line
#
# The SPL holds the entry being typed, echoes it locally, and transmits when
# it is complete.  The line is 51 characters and the first and last position
# are never filled; a single delimiter key (+ or -) generates five things at
# once -- a blank, an open parenthesis, the item number, a close parenthesis
# and the sign; at most 39 characters may be entered (29 when POLL FAIL is on
# the line), and exceeding it raises a FLASHING `ERR`.
#
# CLEAR takes back ONE KEYSTROKE, not the line.
# ===========================================================================

SPL_LENGTH = 51                 # positions 0..50
SPL_LAST = SPL_LENGTH - 1       # ...and the last is never filled
SPL_MAX = 39                    # characters, the leading blank included
SPL_MAX_POLL_FAIL = 29          # ...when POLL FAIL shares the line
ERR_TEXT = ' ERR '

# What each key draws.  ACK, MSG RESET and CLEAR have no entry.
KEY_LABEL = {}
for _k, _v in DEU.KEY.items():
    KEY_LABEL[_v] = _k
KEY_LABEL[DEU.KEY.SYS_SUMM] = 'SYS SUMM'
KEY_LABEL[DEU.KEY.FAULT_SUMM] = 'FAULT SUMM'
KEY_LABEL[DEU.KEY.IO_RESET] = 'I/O RESET'
KEY_LABEL[DEU.KEY.GPC_CRT] = 'GPC/CRT'
KEY_LABEL[DEU.KEY.MINUS] = '-'
KEY_LABEL[DEU.KEY.PLUS] = '+'
KEY_LABEL[DEU.KEY.DECIMAL] = '.'
del KEY_LABEL[DEU.KEY.ACK]
del KEY_LABEL[DEU.KEY.MSG_RESET]
del KEY_LABEL[DEU.KEY.CLEAR]

# Keys that begin an entry.  An initiator is legal in any position: it starts
# a new sequence, which is also the "reinitiate" way out of a syntax error.
INITIATORS = {
    DEU.KEY.ITEM: 'item',
    DEU.KEY.OPS: 'ops1',
    DEU.KEY.SPEC: 'spec1',
    DEU.KEY.GPC_CRT: 'gpc1',
    DEU.KEY.IO_RESET: 'ioreset',
}
DELIMITERS = [DEU.KEY.PLUS, DEU.KEY.MINUS]
COMMAND_KEYS = [DEU.KEY.SYS_SUMM, DEU.KEY.FAULT_SUMM, DEU.KEY.RESUME]
TERMINATORS = [DEU.KEY.EXEC, DEU.KEY.PRO]
VALUE_KEYS = [getattr(DEU.KEY, str(d)) for d in range(10)] + \
             [DEU.KEY.A, DEU.KEY.B, DEU.KEY.C, DEU.KEY.D, DEU.KEY.E, DEU.KEY.F]


def _isDigit(code):
    return getattr(DEU.KEY, '0') <= code <= getattr(DEU.KEY, '9')


def _isAlpha(code):
    return DEU.KEY.A <= code <= DEU.KEY.F


def _isData(code):
    return _isDigit(code) or _isAlpha(code) or code == DEU.KEY.DECIMAL


# Where EXEC and PRO are allowed to close an entry.  `start` is in the EXEC
# list because EXEC on its own IS an entry.
EXEC_STATES = ['start', 'ioreset', 'gpc3', 'itemNum1', 'itemNum2', 'itemData',
               'itemAlpha', 'alphaData']
PRO_STATES = ['ops4', 'spec2', 'spec3', 'spec4']

_DIGITS_RE = re.compile(r'[0-9A-F]$')


class SPL(object):
    def __init__(self, o=None):
        o = o or {}
        self.pollFail = o.get('pollFail', False)
        self.clear()

    def clear(self):
        self.line = ' '          # position 0 is always a space
        self.keys = []           # the codes that will go to the GPC
        self.err = False         # False | 'length' | 'syntax'
        self.complete = False
        self.lastKind = 'none'   # what the previous keystroke drew
        self.state = 'start'     # where the entry has got to in the grammar
        self.initSpan = None     # [start, end) of the initiator's label
        self.history = []        # one snapshot per keystroke, for CLEAR

    def _snapshot(self):
        return {'line': self.line, 'keys': self.keys[:], 'err': self.err,
                'complete': self.complete, 'lastKind': self.lastKind,
                'state': self.state, 'initSpan': self.initSpan}

    def _restore(self, s):
        self.line = s['line']
        self.err = s['err']
        self.complete = s['complete']
        self.lastKind = s['lastKind']
        self.state = s['state']
        self.initSpan = s['initSpan']
        self.keys = s['keys'][:]

    def limit(self):
        return SPL_MAX_POLL_FAIL if self.pollFail else SPL_MAX

    def text(self):
        """The line as drawn: ERR rides at the end, and it FLASHES, so the
        caller gets it separately rather than glued on."""
        return self.line + ERR_TEXT if self.err else self.line

    def _fits(self, n):
        return (len(self.line) + n + (len(ERR_TEXT) if self.err else 0)) <= SPL_LAST

    def _add(self, s, code, exempt=False, kind='value'):
        if not self._fits(len(s)):
            return False
        if kind == 'name':
            self.initSpan = [len(self.line), len(self.line) + len(s)]
        self.line += s
        self.lastKind = kind
        if code is not None:
            self.keys.append(code)
        if not exempt and not self.err and len(self.line) > self.limit():
            self.err = 'length'
        return True

    def _transition(self, code):
        if code in INITIATORS:
            return {'state': INITIATORS[code], 'restart': True}
        if code in COMMAND_KEYS:
            return {'state': 'start', 'done': True, 'restart': True}
        if code == DEU.KEY.EXEC:
            return {'state': 'start', 'done': True} if self.state in EXEC_STATES else None
        if code == DEU.KEY.PRO:
            return {'state': 'start', 'done': True} if self.state in PRO_STATES else None
        d = _isDigit(code)
        a = _isAlpha(code)
        delim = code in DELIMITERS
        dat = _isData(code)
        st = self.state
        if st == 'ops1':
            if d: return {'state': 'ops2'}
        elif st == 'ops2':
            if d: return {'state': 'ops3'}
        elif st == 'ops3':
            if d: return {'state': 'ops4'}
        elif st == 'spec1':
            if d: return {'state': 'spec2'}
        elif st == 'spec2':
            if d: return {'state': 'spec3'}
        elif st == 'spec3':
            if d: return {'state': 'spec4'}
        elif st == 'gpc1':
            if d: return {'state': 'gpc2'}
        elif st == 'gpc2':
            if d: return {'state': 'gpc3'}
        elif st == 'item':
            if d: return {'state': 'itemNum1'}
            if a: return {'state': 'itemAlpha'}
        elif st == 'itemNum1':
            if d: return {'state': 'itemNum2'}
            if delim: return {'state': 'itemData'}
        elif st == 'itemNum2':
            if delim: return {'state': 'itemData'}
        elif st == 'itemData':
            if dat or delim: return {'state': 'itemData'}
        elif st == 'itemAlpha':
            if delim: return {'state': 'alphaDelim'}
        elif st == 'alphaDelim':
            if dat: return {'state': 'alphaData'}
        elif st == 'alphaData':
            if dat: return {'state': 'alphaData'}
        return None

    def press(self, code):
        code = code & 0x1f
        if code == DEU.KEY.CLEAR:
            # One keystroke back, not the whole line.
            if self.history:
                self._restore(self.history.pop())
            else:
                self.clear()
            return 'cleared'
        if KEY_LABEL.get(code) is None:
            return 'silent'                       # ACK / MSG RESET
        snap = self._snapshot()
        if self.complete:
            self.clear()
        if self.err == 'syntax':
            if code in INITIATORS or code in COMMAND_KEYS:
                self.clear()
            else:
                return 'blocked'
        step = self._transition(code)
        label = KEY_LABEL[code]
        # An illegal keystroke is still drawn, but as itself: a delimiter with
        # no item number in front of it echoes as a bare sign.
        if step is None:
            if self.line[-1:] == ' ':
                sep = ''
            elif len(label) > 1 or self.lastKind == 'name':
                sep = ' '
            else:
                sep = ''
            if self._add(sep + label, code, True, 'value'):
                self.err = 'syntax'
                self.history.append(snap)
            return 'illegal'
        if step.get('restart') and len(self.line) > 1:
            self.clear()
        if code in DELIMITERS:
            ok = self._delimiter(label, code)
        elif code in TERMINATORS or code in COMMAND_KEYS:
            sep = '' if self.line[-1:] == ' ' else ' '
            ok = self._add(sep + label + ' ', code, True, 'term')
        elif code in INITIATORS:
            ok = self._add(label, code, False, 'name')
        else:
            sep = ' ' if self.lastKind == 'name' else ''
            ok = self._add(sep + label, code, False, 'value')
        if not ok:
            return 'full'
        self.history.append(snap)
        self.state = step['state']
        if step.get('done'):
            self.complete = True
            return 'complete'
        return 'echoed'

    def _delimiter(self, sign, code):
        head = self.line
        num = ''
        while len(num) < 2 and _DIGITS_RE.search(head):
            num = head[-1] + num
            head = head[0:-1]
        if len(num) > 0 and head[-1:] == ' ':
            head = head[0:-1]
        sep = '' if head[-1:] == ' ' else ' '
        group = sep + '(' + num.rjust(2, ' ') + ')' + sign
        if (len(head) + len(group) + (len(ERR_TEXT) if self.err else 0)) > SPL_LAST:
            return False
        self.line = head
        return self._add(group, code, False, 'delim')


# ===========================================================================
# meds/deuUnit.coffee -- the DEU behaviour definition
#
# This is the state machine a DEU / IDP presents to a GPC: 8192 halfwords of
# display memory, the transfer in progress, the keyboard queue, and the status
# the GPC polls out of it.
# ===========================================================================

class DEUUnit(object):
    def __init__(self, o=None):
        o = o or {}
        self.send = o.get('send') or (lambda w: None)
        self.onFill = o.get('fill') or (lambda a, w: None)
        self.onReset = o.get('reset') or (lambda: None)
        self.onTime = o.get('time') or (lambda t: None)
        self.onPoll = o.get('poll') or (lambda: None)   # the display's only clock
        self.log = o.get('log') or (lambda t: None)
        self.name = o.get('name', 'DEU')

        self.mem = np.zeros(DEU.DEU_MEMORY_WORDS, dtype=np.uint16)
        self.xfer = None                 # the transfer in progress, if any
        self.keyQueue = []               # completed entries (lists of codes)
        self.spl = SPL()                 # the scratch pad line
        # THE MAJOR FUNCTION SWITCH.  PASS reads it out of the poll header,
        # and a CHANGE in it is consequential: it sets up a two-keystroke MF
        # CHANGE message and calls ARY_MF_BUS_CHG to pick a new bus commander.
        mf = o.get('majorFunc')
        self.majorFunc = int(envnum('NSTS_MAJOR_FUNC', 0)) if mf is None else mf
        self.ipled = o.get('ipled', True)
        if self.ipled is None:
            self.ipled = True
        self.iplRunning = False
        # MSG RESET and ACK are not keystrokes.  A press latches a header bit
        # that rides out on the next poll and is cleared once reported.
        self.msgResetPending = False
        self.ackPending = False
        self.iplError = False
        self.iplCircuitError = False
        self.selfTest = False
        self.swStatus = o.get('swStatus', DEU.SWSTATUS_HEALTHY)
        self.timeWords = None
        self.time = None
        self.medsDK = None
        self.deuId = None
        self._lastMedsKey = None
        self._sameMedsCount = 0
        self._lastPollKey = None
        self._samePollCount = 0
        self.stats = {'commands': 0, 'fills': 0, 'timeFills': 0, 'headerless': 0,
                      'polls': 0, 'bite': 0, 'dumps': 0, 'resets': 0,
                      'unknown': 0, 'wordsIn': 0, 'wordsOut': 0, 'abandoned': 0,
                      'modeStatus': 0}

    # -- IDP POWER and DEU LOAD ----------------------------------------------
    def requestLoad(self):
        """DEU LOAD: the unit asks to be loaded again.  Its next poll reply
        carries IPL_REQUIRED, which is what makes GPCIPL load it -- and draw
        its menu -- or PASS's DEU loader reload it.  Display memory is cleared
        with it: the load writes only what it writes, and a background pointer
        PASS left at BACKGROUND_TOP would otherwise draw PASS's background
        under GPCIPL's menu."""
        self.xfer = None
        self.ipled = False
        self.iplRunning = False
        self.deuId = None
        self.mem[:] = 0

    def powerUp(self):
        """IDP POWER ON: a cold unit -- memory, keyboard queue, scratch pad and
        latches gone, and needing to be loaded.  The major function switch is
        a switch, not state, and keeps its position."""
        self.requestLoad()
        del self.keyQueue[:]
        self.spl.clear()
        self.msgResetPending = False
        self.ackPending = False
        self.iplError = False
        self.iplCircuitError = False
        self.selfTest = False
        self.timeWords = None
        self.time = None
        self.medsDK = None

    # -- DK bus handling ----------------------------------------------------
    def recv(self, words):
        """A BCE transmits a command as the 24 command bits left justified in
        two halfwords, and every data word on its own -- so the datagram
        length tells them apart."""
        if len(words) >= 2:
            return self.onCommand(((int(words[0]) & 0xffff) << 8)
                                  | ((int(words[1]) >> 8) & 0xff))
        r = None
        for w in words:
            r = self.onData(int(w))
        return r

    def onCommand(self, cmd24):
        c = DEU.decodeCommand(cmd24)
        if c['iua'] != DEU.IUA:
            return None                  # not addressed to a display unit
        self.stats['commands'] += 1
        # A new command abandons whatever transfer was part way through.
        if self.xfer is not None and self.xfer['left'] > 0:
            self.stats['abandoned'] += 1
            self.log("%s: transfer abandoned, %d halfwords short"
                     % (self.name, self.xfer['left']))
        self.xfer = None
        f = c['func']
        if f in (DEU.FUNC.TIME_FILL, DEU.FUNC.DISPLAY_FILL, DEU.FUNC.FORMAT_FILL):
            self.xfer = {'func': f, 'left': c['count'], 'words': []}
        elif f == DEU.FUNC.MEDS_XFER:
            self.xfer = {'func': f, 'left': DEU.MEDS_XFER_WORDS, 'words': []}
        elif f == DEU.FUNC.DUMP:
            self.xfer = {'func': f, 'left': c['count'], 'words': []}
        elif f == DEU.FUNC.POLL:
            self.stats['polls'] += 1
            self.onPoll()
            if self.iplRunning:
                self.stats['modeStatus'] += 1
                self._logPollReply('mode-status', self.header())
                self._reply([self.takeHeader()])
            else:
                self._logPollReply('poll', self.header())
                self._reply(self.pollResponse())
        elif f == DEU.FUNC.BITE:
            self.stats['bite'] += 1
            self._reply(DEU.biteResponse(self.biteState()))
        elif f == DEU.FUNC.RESET_SPL:
            self.stats['resets'] += 1
            del self.keyQueue[:]
            self.spl.clear()
            self.onReset()
        else:
            self.stats['unknown'] += 1
            self.log("%s: unknown command %s (function 0x%x, count %d)"
                     % (self.name, c['name'], c['func'], c['count']))
        return {'kind': 'command', 'cmd': c}

    def onData(self, w):
        if self.xfer is None:
            return None
        self.stats['wordsIn'] += 1
        self.xfer['words'].append(w & 0xffff)
        self.xfer['left'] -= 1
        if self.xfer['left'] > 0:
            return {'kind': 'data', 'left': self.xfer['left']}
        x = self.xfer
        self.xfer = None
        if x['func'] == DEU.FUNC.MEDS_XFER:
            self._logMedsXfer(x['words'])
            self.medsDK = x['words']
            return {'kind': 'meds', 'words': x['words']}
        if x['func'] == DEU.FUNC.DUMP:
            return self._dumpRequest(x['words'])
        if x['func'] == DEU.FUNC.TIME_FILL:
            return self._timeFill(x['words'])
        return self._fill(x['words'], x['func'])

    def _timeFill(self, words):
        """The header clock.  Seven halfwords: mission time, event time --
        both 48-bit IBM extended floats holding seconds -- and the conversion
        word."""
        self.stats['timeFills'] += 1
        self.timeWords = words
        self.time = DEU.parseTimeFill(words)
        if self.time is not None:
            self.onTime(self.time)
        return {'kind': 'time', 'time': self.time, 'words': words}

    def _fill(self, words, func):
        """A fill message: a word count, the DEU address it loads at, and the
        payload."""
        f = DEU.parseFill(words)
        if f is None or f['short'] or f['count'] + 2 != len(words):
            self.stats['headerless'] += 1
            self.log("%s: unheadered fill of %d halfwords, ignored"
                     % (self.name, len(words)))
            return {'kind': 'headerless', 'words': words}
        self.stats['fills'] += 1
        # Every accepted fill, so a run leaves a record of what ARRIVED.  The
        # menu is written once and never repeated; lose it and the page keeps
        # updating its clock over a blank screen for the rest of the run.
        self.log("%s: fill func=%s %d halfwords at 0x%x"
                 % (self.name, func, f['count'], f['addr']))
        if not self.ipled and not self.iplRunning:
            self.iplRunning = True
            self.log("%s: load started" % self.name)
        if self.iplRunning and f['count'] == DEU.LAST_FILL_WORDS:
            self.iplRunning = False
            self.ipled = True
            if f['addr'] <= DEU.DEU_ID_ADDR < f['addr'] + f['count']:
                self.deuId = f['payload'][DEU.DEU_ID_ADDR - f['addr']]
            self.log("%s: load complete (%d halfwords at 0x%x), reporting initialized%s"
                     % (self.name, f['count'], f['addr'],
                        (" as unit %s" % self.deuId) if self.deuId is not None else ""))
        for i, w in enumerate(f['payload']):
            self.mem[(f['addr'] + i) & (DEU.DEU_MEMORY_WORDS - 1)] = w & 0xffff
        self.onFill(f['addr'], f['payload'])
        return {'kind': 'fill', 'func': func, 'addr': f['addr'],
                'count': f['count'], 'payload': f['payload']}

    def _dumpRequest(self, words):
        addr = (words[1] if len(words) > 1 else 0) & DEU.ADDR_MASK
        n = (words[0] if len(words) > 0 else 0) & 0xffff
        self.stats['dumps'] += 1
        out = [int(self.mem[(addr + i) & (DEU.DEU_MEMORY_WORDS - 1)]) for i in range(n)]
        self._reply(out)
        return {'kind': 'dump', 'addr': addr, 'count': n}

    def _reply(self, words):
        if len(words) == 0:
            return
        self.stats['wordsOut'] += len(words)
        self.send(words)

    # -- what the GPC polls out of the unit --------------------------------
    def biteState(self):
        b1 = DEU.BITE1.ALWAYS_ONE
        if self.ipled:
            b1 |= DEU.BITE1.IPL_DONE
        if self.iplError:
            b1 |= DEU.BITE1.IPL_ERROR
        if self.iplCircuitError:
            b1 |= DEU.BITE1.IPL_CIRCUIT_ERROR
        return {'bite1': b1, 'swStatus': self.swStatus}

    def _logMedsXfer(self, words):
        """THE MEDS DK BUFFER, which nothing has ever looked inside.  Logged
        on change so the run shows the transitions rather than a thousand
        identical buffers."""
        key = ','.join(str(w) for w in words)
        if key == self._lastMedsKey:
            self._sameMedsCount = (self._sameMedsCount or 0) + 1
            return
        n = self._sameMedsCount or 0
        self._lastMedsKey = key
        self._sameMedsCount = 0
        nz = [i for i, w in enumerate(words) if w != 0]
        hexs = ' '.join('%04x' % w for w in words[0:24])
        self.log("%s: MEDS_XFER %d hw, %d non-zero%s%s\n    %s"
                 % (self.name, len(words), len(nz),
                    (" (first at %d)" % nz[0]) if nz else "",
                    (" [previous held %d]" % n) if n > 0 else "", hexs))

    def _logPollReply(self, kind, hdr):
        """WHAT THE UNIT TELLS THE GPC.  Logged ONLY WHEN IT CHANGES: a poll
        arrives every 40 ms, so logging each one buries the transition that
        matters in thousands of identical lines."""
        key = "%s %s" % (kind, hdr)
        if key == self._lastPollKey:
            self._samePollCount = (self._samePollCount or 0) + 1
            return
        n = self._samePollCount or 0
        self._lastPollKey = key
        self._samePollCount = 0
        bits = ','.join(nm for nm, m in DEU.HDR.items()
                        if nm != 'MAJOR_FUNC' and (hdr & m))
        self.log("%s: %s reply 0x%x major=%d [%s] ipled=%s iplRunning=%s%s"
                 % (self.name, kind, hdr,
                    (hdr & DEU.HDR.MAJOR_FUNC) >> DEU.MAJOR_FUNC_SHIFT,
                    bits or 'none', str(self.ipled).lower(),
                    str(self.iplRunning).lower(),
                    (" (previous held for %d polls)" % n) if n > 0 else ""))

    def header(self):
        hdr = (self.majorFunc << DEU.MAJOR_FUNC_SHIFT) & DEU.HDR.MAJOR_FUNC
        if self.selfTest:
            hdr |= DEU.HDR.SELF_TEST
        if not self.ipled:
            hdr |= DEU.HDR.IPL_REQUIRED
        if self.msgResetPending:
            hdr |= DEU.HDR.MSG_RESET
        if self.ackPending:
            hdr |= DEU.HDR.ACK
        # A response carrying MSG RESET or ACK does not carry a keyboard
        # message: the queued entry is not lost, it waits for the next poll.
        if len(self.keyQueue) > 0 and not (self.msgResetPending or self.ackPending):
            hdr |= DEU.HDR.KYBD_MSG
        return hdr

    def takeHeader(self):
        hdr = self.header()
        self.msgResetPending = False
        self.ackPending = False
        return hdr

    def pollResponse(self):
        # The header is taken before the queue is drained: it carries the "a
        # keyboard message is ready" bit, which is set from the queue depth.
        hdr = self.takeHeader()
        # One entry per message, never two concatenated.
        keys = self.keyQueue.pop(0) if (hdr & DEU.HDR.KYBD_MSG) else []
        o = {'header': hdr, 'keys': keys}
        o.update(self.biteState())
        return DEU.pollResponse(o)

    def pressKey(self, code):
        code = code & 0x1f
        if code == DEU.KEY.MSG_RESET:
            self.msgResetPending = True
            return
        if code == DEU.KEY.ACK:
            self.ackPending = True
            return
        if self.spl.press(code) != 'complete':
            return
        if not self.spl.err:
            self.keyQueue.append(self.spl.keys[0:DEU.MAX_KEYS_IPL])


# ===========================================================================
# meds/medsConf.coffee -- the IDP <-> MDU messages and the MEDS LRU table
#
# Word 0 is the tag; the tags are 0xFF00 and up so they cannot collide with a
# format control word.
# ===========================================================================

MDUMsg = NS(
    FILL=0xff00,       # a display-memory fill: DEU address, then the words
    RESET_SPL=0xff02,  # the GPC reset the scratch pad line
    CLOCK=0xff03,      # the header clock
    POLL=0xff04,       # a GPC polled this unit
    HEARTBEAT=0xffff,  # the IDP is alive

    # MDU -> IDP.  Everything above is the other direction; `recvMDU` already
    # treats anything BELOW `FILL` as inbound from an MDU.
    SET_MAJOR_FUNC=0x0001,   # the major function switch moved: one word, 0..3
    DEU_LOAD=0x0002,         # DEU LOAD pushed (Table 2-2 step 9): no words
    IDP_POWER=0x0003,        # IDP POWER switch moved: one word, 1 ON, 0 OFF
    # IDP/CRT SEL (panel C2), as panelO6.py sends it to each forward IDP: one
    # word, bit 0 the left keyboard is selected to this IDP, bit 1 the right.
    # The IDP echoes the word it acts on as word 2 of its HEARTBEAT, which is
    # what draws the keyboard bars beside the IDP identifier box.
    KYBD_SEL=0x0004,
)
MDUMsgName = {}
for _k, _v in MDUMsg.items():
    MDUMsgName[_v] = _k

MEDSConf = {
    'mdus': {
        'CRT1': {'lruID': 0x02, 'busses': ['_IDP1'],
                 'dataBus': {'P': "IDP1", 'S': None},
                 'powerBus': ["AB1", "MNA"], 'lightDimBus': "L/C", 'busAddr': 0x16},
        'CRT2': {'lruID': 0x02, 'busses': ['_IDP2'],
                 'dataBus': {'P': "IDP2", 'S': None},
                 'powerBus': ["BC2", "MNB"], 'lightDimBus': "L/C", 'busAddr': 0x07},
        'CRT3': {'lruID': 0x02, 'busses': ['_IDP3'],
                 'dataBus': {'P': "IDP3", 'S': None},
                 'powerBus': ["CA1", "MNC"], 'lightDimBus': "L/C", 'busAddr': 0x15},
        'CRT4': {'lruID': 0x02, 'busses': ['_IDP4'],
                 'dataBus': {'P': "IDP4", 'S': None},
                 'powerBus': ["CA2", "MNC"], 'lightDimBus': "MS", 'busAddr': 0x19},
        'CDR1': {'lruID': 0x03, 'busses': ['_IDP3', '_IDP1'],
                 'dataBus': {'P': "IDP3", 'S': "IDP1"},
                 'powerBus': ["MNC"], 'lightDimBus': "L/C", 'busAddr': 0x1A},
        'CDR2': {'lruID': 0x04, 'busses': ['_IDP1', '_IDP2'],
                 'dataBus': {'P': "IDP1", 'S': "IDP2"},
                 'powerBus': ["MNB"], 'lightDimBus': "L/C", 'busAddr': 0x0B},
        'PLT1': {'lruID': 0x05, 'busses': ['_IDP2', '_IDP1'],
                 'dataBus': {'P': "IDP2", 'S': "IDP1"},
                 'powerBus': ["MNA"], 'lightDimBus': "RT", 'busAddr': 0x1C},
        'PLT2': {'lruID': 0x06, 'busses': ['_IDP3', '_IDP2'],
                 'dataBus': {'P': "IDP3", 'S': "IDP2"},
                 'powerBus': ["MNC"], 'lightDimBus': "RT", 'busAddr': 0x0D},
        'MFD1': {'lruID': 0x07, 'busses': ['_IDP2', '_IDP3'],
                 'dataBus': {'P': "IDP2", 'S': "IDP3"},
                 'powerBus': ["MNB"], 'lightDimBus': "L/C", 'busAddr': 0x0E},
        'MFD2': {'lruID': 0x08, 'busses': ['_IDP1', '_IDP3'],
                 'dataBus': {'P': "IDP1", 'S': "IDP3"},
                 'powerBus': ["MNA"], 'lightDimBus': "L/C", 'busAddr': 0x13},
        'AFD1': {'lruID': 0x09, 'busses': ['_IDP4', '_IDP2'],
                 'dataBus': {'P': "IDP4", 'S': "IDP2"},
                 'powerBus': ["MNC"], 'lightDimBus': "MS", 'busAddr': 0x10},
    },
    'idps': {
        'IDP1': {'lruID': 0x00,
                 'busses': ['_IDP1', 'FC1', 'FC2', 'FC3', 'FC4', 'DK1', '_KYBD1'],
                 'powerBus': ["AB1", "MNA"], 'fcBus': ["FC1", "FC2", "FC3", "FC4"],
                 'dkBus': "DK1",
                 'errorMsgTarget': ["CRT1", "CDR1", "CDR2", "MFD2", "PLT1"],
                 'busAddr': 0x01},
        # No _KYBD3 on IDP 2, though MEDS had one: the aft keyboard "can
        # communicate only with IDP 4" (Crew Software Interface, USA006083
        # Rev B, 2.6), and the forward ones reach IDP 2 only through the
        # RIGHT IDP/CRT SEL switch (2.5).
        'IDP2': {'lruID': 0x00,
                 'busses': ['_IDP2', 'FC1', 'FC2', 'FC3', 'FC4', 'DK2', '_KYBD2'],
                 'powerBus': ["CA1", "MNC"], 'fcBus': ["FC1", "FC2", "FC3", "FC4"],
                 'dkBus': "DK2",
                 'errorMsgTarget': ["CRT2", "PLT2", "PLT1", "MFD1", "CDR2", "AFD1"],
                 'busAddr': 0x02},
        'IDP3': {'lruID': 0x00,
                 'busses': ['_IDP3', 'FC1', 'FC2', 'FC3', 'FC4', 'DK3', '_KYBD1', '_KYBD2'],
                 'powerBus': ["BC2", "MNB"], 'fcBus': ["FC1", "FC2", "FC3", "FC4"],
                 'dkBus': "DK3",
                 'errorMsgTarget': ["CRT3", "PLT2", "MFD2", "MFD1", "CDR1"],
                 'busAddr': 0x04},
        'IDP4': {'lruID': 0x00,
                 'busses': ['_IDP4', 'FC1', 'FC2', 'FC3', 'FC4', 'DK4', '_KYBD3'],
                 'powerBus': ["CA2", "MNC"], 'fcBus': ["FC1", "FC2", "FC3", "FC4"],
                 'dkBus': "DK4",
                 'errorMsgTarget': ["CRT4", "AFD1"],
                 'busAddr': 0x08},
    },
    'adcs': {
        'ADC1A': {'lruID': 0x0A, 'busses': ['_IDP1', '_IDP2'], 'powerBus': ["MNA"],
                  'dataBus': ["IDP1", "IDP2"], 'dataIn': ["MPS", "OMS", "SPI"],
                  'busAddr': 0x18},
        'ADC1B': {'lruID': 0x0A, 'busses': ['_IDP3', '_IDP4'], 'powerBus': ["MNB"],
                  'dataBus': ["IDP3", "IDP4"], 'dataIn': ["MPS", "OMS", "SPI"],
                  'busAddr': 0x12},
        'ADC2A': {'lruID': 0x0B, 'busses': ['_IDP1', '_IDP2'], 'powerBus': ["MNA"],
                  'dataBus': ["IDP1", "IDP2"], 'dataIn': ["HYD", "APU"],
                  'busAddr': 0x14},
        'ADC2B': {'lruID': 0x0B, 'busses': ['_IDP3', '_IDP4'], 'powerBus': ["MNB"],
                  'dataBus': ["IDP3", "IDP4"], 'dataIn': ["HYD", "APU"],
                  'busAddr': 0x11},
    },
}


# ===========================================================================
# meds/mduMenu.coffee -- the MDU edgekey menus
#
# USA-007587/p.250: the colour of the boxes and the labels normally are cyan,
# unless they correspond to the current MEDS display, in which case they are
# white.  A blank edgekey legend means no option is available for that
# edgekey; if the edgekey is pressed, the IDP ignores it.
# ===========================================================================

Menus = {
    'MAIN': {
        'id': 0x01,
        'title': " MAIN MENU   ",
        0: {'keyTitle': ""},
        1: {'keyTitle': "FLT \nINST", 'link': "FLT_INST"},
        2: {'keyTitle': "SUBSYS \nSTATUS ", 'link': "SUBSYS"},
        3: {'keyTitle': "DPS", 'link': "DPS"},
        4: {'keyTitle': "MEDS \nMAINT", 'link': "MAINT"},
        5: {'keyTitle': "VIDEO"},
    },
    'FLT_INST': {
        'id': 0x02,
        'title': "FLIGHT INSTRUMENT MENU ",
        0: {'keyTitle': "UP", 'link': 'MAIN'},
        1: {'keyTitle': " A/E\n PFD", 'action': lambda t: t.setCurrentDisplay("AE_PFD", 1)},
        2: {'keyTitle': " ORBIT\n PFD", 'action': lambda t: t.setCurrentDisplay("ORBIT_PFD", 2)},
        3: {'keyTitle': "DATA\n BUS", 'link': 'DATA_BUS'},
        4: {'keyTitle': " MEDS\nMSG RST"},
        5: {'keyTitle': " MEDS \n MSG ACK"},
    },
    # menu id 0x03-0x05 --SPARE--
    'AE_FLT_INST': {
        'title': "ASCENT/ENTRY FLIGHT INSTRUMENT MENU ",
        0: {'keyTitle': "UP", 'link': 'MAIN'},
        1: {'keyTitle': "ADI/\nAVVI", 'action': lambda t: t.setCurrentDisplay("AE_PFD", 1)},
        2: {'keyTitle': "HST/\nAMI", 'action': lambda t: t.setCurrentDisplay("ORBIT_PFD", 2)},
        3: {'keyTitle': "COMP\nADI/HST", 'action': lambda t: t.setCurrentDisplay("AE_PFD", 3)},
        4: {'keyTitle': "DATA\n BUS", 'link': 'DATA_BUS'},
        5: {'keyTitle': " MEDS\n MSG ACT"},
    },
    'DATA_BUS': {
        'id': 0x06,
        'title': "DATA BUS SELECT MENU",
        # highlight tracks the FC bus actually selected (edgekey n = FC bus n)
        'activeItem': lambda t: t.flightCritBus,
        0: {'keyTitle': "UP", 'link': 'FLT_INST'},
        1: {'keyTitle': "FC BUS\n1", 'action': lambda t: t.setFCBus(1)},
        2: {'keyTitle': "FC BUS\n2", 'action': lambda t: t.setFCBus(2)},
        3: {'keyTitle': "FC BUS\n3", 'action': lambda t: t.setFCBus(3)},
        4: {'keyTitle': "FC BUS\n4", 'action': lambda t: t.setFCBus(4)},
        5: {'keyTitle': ""},
    },
    'SUBSYS': {
        'id': 0x07,
        'title': "SUBSYSTEM MENU   ",
        0: {'keyTitle': "UP", 'link': 'MAIN'},
        1: {'keyTitle': "OMS/ \nMPS", 'action': lambda t: t.setCurrentDisplay("OMS_MPS", 1)},
        2: {'keyTitle': "HYD/ \nAPU", 'action': lambda t: t.setCurrentDisplay("HYD_APU", 2)},
        3: {'keyTitle': "SPI", 'action': lambda t: t.setCurrentDisplay("SPI", 3)},
        4: {'keyTitle': "PORT\nSELECT", 'action': lambda t: t.toggleCmdPort()},
        5: {'keyTitle': " MEDS \n MSG ACK"},
    },
    'DPS': {
        'id': 0x08,
        'title': "DPS MENU       ",
        'action': lambda t: t.setCurrentDisplay("DPS"),
        0: {'keyTitle': "UP", 'link': 'MAIN'},
        1: {'keyTitle': ""},
        2: {'keyTitle': ""},
        3: {'keyTitle': ""},
        4: {'keyTitle': "MEDS\nMSG RST"},
        5: {'keyTitle': "MEDS\nMSG ACK"},
    },
    'VIDEO': {
        'id': 0x09,
        'title': "VIDEO MENU",
        0: {'keyTitle': "UP", 'link': 'MAIN'},
    },
    'MAINT': {
        'id': 0x0C,
        'title': "MAINTENANCE MENU",
        'action': lambda t: t.setCurrentDisplay("MAINT"),
        0: {'keyTitle': "UP", 'link': "MAIN"},
        1: {'keyTitle': "FAULT\nSUMM", 'link': "FAULT_SUMM"},
        2: {'keyTitle': "CONFIG\nSTATUS", 'link': "CONFIG_STATUS"},
        3: {'keyTitle': "CST", 'link': "CST"},
        4: {'keyTitle': "MEMORY\nMGMT", 'link': 'MEM_MGMT'},
        5: {'keyTitle': ""},
    },
    'FAULT_SUMM': {
        'id': 0x0A,
        'title': "FAULT SUMMARY   ",
        'action': lambda t: t.setCurrentDisplay("FAULT_SUMM"),
        0: {'keyTitle': "UP", 'link': 'MAINT'},
        1: {'keyTitle': ""},
        2: {'keyTitle': ""},
        3: {'keyTitle': "CLEAR\nMSGS "},
        4: {'keyTitle': "MEDS\nMSG RST"},
        5: {'keyTitle': " MEDS\n MSG ACK"},
    },
    'CONFIG_STATUS': {
        # USA-007587/p.253: the configuration status submenu allows the viewer
        # to port select to the alternate IDP, change its reconfiguration mode
        # to either AUTO or MAN, or change the viewing mode.
        'id': 0x0D,
        'title': "MDU CONFIGURATION MENU",
        0: {'keyTitle': "UP", 'link': 'MAINT'},
        1: {'keyTitle': "PORT\nSELECT", 'action': lambda t: t.toggleCmdPort()},
        2: {'keyTitle': "AUTO/\nMANUAL", 'action': lambda t: t.toggleReconfigMode()},
        3: {'keyTitle': ""},
        4: {'keyTitle': ""},
        5: {'keyTitle': "CHANGE\nVIEW", 'action': lambda t: t.toggleNegView()},
    },
    'CST': {
        'id': 0x0E,
        'title': "CST MENU SELECTION",
        0: {'keyTitle': "UP", 'link': 'MAINT'},
        1: {'keyTitle': "START\nMDU", 'action': lambda t: t.seq_mdu_selftest()},
        2: {'keyTitle': "START\nIDP", 'link': 'INTER_CST'},
        3: {'keyTitle': "START\nADC1X"},
        4: {'keyTitle': "START\nADC2X"},
        5: {'keyTitle': ""},
    },
    'INTER_CST': {
        'id': 0x0B,
        'title': "INTERACTIVE CST",
        'action': lambda t: t.setCurrentDisplay("IDP_CST"),
        0: {'keyTitle': "UP", 'link': 'CST'},
        1: {'keyTitle': ""},
        2: {'keyTitle': ""},
        3: {'keyTitle': ""},
        4: {'keyTitle': ""},
        5: {'keyTitle': "HW\nCST"},
    },
    'MEM_MGMT': {
        'id': 0x0F,
        'title': "MEMORY MANAGEMENT SELECTION",
        0: {'keyTitle': "UP", 'link': 'MAINT'},
        1: {'keyTitle': "IDP", 'link': 'MEM_IDP'},
        2: {'keyTitle': "MDU", 'link': 'MEM_MDU'},
        3: {'keyTitle': "ADCXX", 'link': 'MEM_ADC'},
        4: {'keyTitle': "ADCXX", 'link': 'MEM_ADC'},
        5: {'keyTitle': "FILE\nPATCH", 'link': 'FILE_PATCH'},
    },
    'MEM_IDP': {
        'id': 0x10,
        'title': "XXXXX MEMORY MANAGEMENT SELECTION",
        0: {'keyTitle': "UP", 'link': 'MEM_MGMT'},
        1: {'keyTitle': "DUMP\nRAM"},
        2: {'keyTitle': "DUMP\nEEPROM"},
        3: {'keyTitle': "PROG\nLOAD", 'link': 'PROG_LOAD_IDP'},
        4: {'keyTitle': ""},
        5: {'keyTitle': ""},
    },
    'MEM_MDU': {
        'id': 0x10,
        'title': "XXXXX MEMORY MANAGEMENT SELECTION",
        0: {'keyTitle': "UP", 'link': 'MEM_MGMT'},
        1: {'keyTitle': "DUMP\nRAM"},
        2: {'keyTitle': "DUMP\nEEPROM"},
        3: {'keyTitle': "PROG\nLOAD", 'link': 'PROG_LOAD_MDU'},
        4: {'keyTitle': ""},
        5: {'keyTitle': ""},
    },
    'MEM_ADC': {
        'id': 0x10,
        'title': "XXXXX MEMORY MANAGEMENT SELECTION",
        0: {'keyTitle': "UP", 'link': 'MEM_MGMT'},
        1: {'keyTitle': "DUMP\nRAM"},
        2: {'keyTitle': ""},
        3: {'keyTitle': ""},
        4: {'keyTitle': ""},
        5: {'keyTitle': ""},
    },
    'PROG_LOAD_IDP': {
        'id': 0x11,
        'title': "XXXX MEMORY LOADING",
        0: {'keyTitle': "UP", 'link': 'MEM_IDP'},
        1: {'keyTitle': "PREV\nPROG"},
        2: {'keyTitle': "NEXT\nPROG"},
        3: {'keyTitle': "LOAD\nRAM"},
        4: {'keyTitle': "LOAD\nRAM/EE"},
        5: {'keyTitle': "SET\nCURNT"},
    },
    'PROG_LOAD_MDU': {
        'title': "XXXX MEMORY LOADING",
        0: {'keyTitle': "UP", 'link': 'MEM_IDP'},
        1: {'keyTitle': "PREV\nPROG"},
        2: {'keyTitle': "NEXT\nPROG"},
        3: {'keyTitle': ""},
        4: {'keyTitle': "LOAD\nRAM/EE"},
        5: {'keyTitle': ""},
    },
    'FILE_PATCH': {
        'id': 0x12,
        'title': "FILE PATCHING SELECTION",
        'action': lambda t: setattr(t, 'curDisplay', "FILE_PATCH"),
        0: {'keyTitle': "UP", 'link': 'MAINT'},
        1: {'keyTitle': "PREV\nFILE"},
        2: {'keyTitle': "NEXT\nFILE"},
        3: {'keyTitle': "SELECT", 'link': 'FILE_PATCH'},
        4: {'keyTitle': ""},
        5: {'keyTitle': ""},
    },
    'DO_FILE_PATCH': {
        'id': 0x13,
        'title': "XXXXXXXX XXX FILE PATCHING",
        0: {'keyTitle': "UP", 'link': 'MAIN'},
        1: {'keyTitle': ""},
        2: {'keyTitle': ""},
        3: {'keyTitle': ""},
        4: {'keyTitle': ""},
        5: {'keyTitle': ""},
    },
    'DISCONNECTED': {
        'title': "",
        0: {'keyTitle': "AUTO\nCONFIG"},
        1: {'keyTitle': "PRI\nMANUAL"},
        2: {'keyTitle': "SEC\nMANUAL"},
        3: {'keyTitle': ""},
        4: {'keyTitle': ""},
        5: {'keyTitle': ""},
    },
}


# ===========================================================================
# A three.js-shaped scene graph, and an OpenGL renderer for it.
#
# The original draws through three.js: an orthographic camera over a scene of
# Object3Ds, with two kinds of material -- a flat-colour MeshBasicMaterial for
# fills and a custom SDF-stroke ShaderMaterial for every line.  Both are
# reproduced here, including three.js's own draw ordering (opaque front to
# back, then transparent back to front, renderOrder first in both), its
# depth-write rules, and its clipping planes, because the displays are tuned
# against exactly those rules.
# ===========================================================================

# GL enumerants (Qt's function wrapper does not re-export them)
GL_DEPTH_TEST = 0x0B71
GL_BLEND = 0x0BE2
GL_CULL_FACE = 0x0B44
GL_TRIANGLES = 0x0004
GL_UNSIGNED_SHORT = 0x1403
GL_UNSIGNED_INT = 0x1405
GL_FLOAT = 0x1406
GL_COLOR_BUFFER_BIT = 0x4000
GL_DEPTH_BUFFER_BIT = 0x0100
GL_SRC_ALPHA = 0x0302
GL_ONE_MINUS_SRC_ALPHA = 0x0303
GL_ONE = 1
GL_FUNC_ADD = 0x8006
GL_LESS = 0x0201
GL_LEQUAL = 0x0203
GL_MULTISAMPLE = 0x809D

FrontSide = 0
BackSide = 1
DoubleSide = 2

_obj_seq = [0]


def _nextId():
    _obj_seq[0] += 1
    return _obj_seq[0]


class Vec3(object):
    __slots__ = ('x', 'y', 'z')

    def __init__(self, x=0.0, y=0.0, z=0.0):
        self.x = x
        self.y = y
        self.z = z

    def set(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z
        return self

    def copy(self):
        return Vec3(self.x, self.y, self.z)


class Euler(object):
    __slots__ = ('x', 'y', 'z', 'order')

    def __init__(self, x=0.0, y=0.0, z=0.0, order='XYZ'):
        self.x = x
        self.y = y
        self.z = z
        self.order = order

    def set(self, x, y, z, order=None):
        self.x = x
        self.y = y
        self.z = z
        if order is not None:
            self.order = order
        return self


def _rotMat(axis, a):
    c = math.cos(a)
    s = math.sin(a)
    m = np.eye(3, dtype=np.float64)
    if axis == 'X':
        m[1, 1] = c; m[1, 2] = -s; m[2, 1] = s; m[2, 2] = c
    elif axis == 'Y':
        m[0, 0] = c; m[0, 2] = s; m[2, 0] = -s; m[2, 2] = c
    else:
        m[0, 0] = c; m[0, 1] = -s; m[1, 0] = s; m[1, 1] = c
    return m


_IDENT4 = np.eye(4, dtype=np.float64)


class Object3D(object):
    isMesh = False

    def __init__(self):
        self.id = _nextId()
        self.position = Vec3()
        self.rotation = Euler()
        self.scale = Vec3(1.0, 1.0, 1.0)
        self.visible = True
        self.renderOrder = 0
        self.name = ''
        self.userData = {}
        self.children = []
        self.parent = None
        self.matrixWorld = _IDENT4

    def add(self, o):
        if o is None:
            return self
        if o.parent is not None:
            o.parent.remove(o)
        o.parent = self
        self.children.append(o)
        return self

    def remove(self, o):
        if o is None:
            return self
        try:
            self.children.remove(o)
            o.parent = None
        except ValueError:
            pass
        return self

    def traverse(self, fn):
        fn(self)
        for c in list(self.children):
            c.traverse(fn)

    def getObjectByName(self, name):
        if self.name == name:
            return self
        for c in self.children:
            r = c.getObjectByName(name)
            if r is not None:
                return r
        return None

    def localMatrix(self):
        p = self.position
        r = self.rotation
        s = self.scale
        if r.x == 0.0 and r.y == 0.0 and r.z == 0.0:
            rm = np.eye(3, dtype=np.float64)
        else:
            o = r.order
            ang = {'X': r.x, 'Y': r.y, 'Z': r.z}
            rm = _rotMat(o[0], ang[o[0]]) @ _rotMat(o[1], ang[o[1]]) @ _rotMat(o[2], ang[o[2]])
        m = np.eye(4, dtype=np.float64)
        m[0:3, 0] = rm[:, 0] * s.x
        m[0:3, 1] = rm[:, 1] * s.y
        m[0:3, 2] = rm[:, 2] * s.z
        m[0, 3] = p.x
        m[1, 3] = p.y
        m[2, 3] = p.z
        return m


class Scene(Object3D):
    def __init__(self):
        Object3D.__init__(self)
        self.background = None


class Color(object):
    __slots__ = ('r', 'g', 'b')

    def __init__(self, hexv=0xffffff):
        self.setHex(hexv)

    def setHex(self, hexv):
        hexv = int(hexv) & 0xffffff
        self.r = ((hexv >> 16) & 0xff) / 255.0
        self.g = ((hexv >> 8) & 0xff) / 255.0
        self.b = (hexv & 0xff) / 255.0
        return self


class Plane(object):
    __slots__ = ('normal', 'constant')

    def __init__(self, normal, constant):
        self.normal = normal
        self.constant = constant


class BufferAttribute(object):
    __slots__ = ('array', 'itemSize')

    def __init__(self, array, itemSize):
        if not isinstance(array, np.ndarray):
            array = np.asarray(array, dtype=np.float32)
        self.array = array
        self.itemSize = itemSize


def Float32BufferAttribute(array, itemSize):
    return BufferAttribute(np.asarray(array, dtype=np.float32), itemSize)


class BufferGeometry(object):
    def __init__(self):
        self.id = _nextId()
        self.attributes = {}
        self.index = None
        self._gl = None
        self._glinfo = None
        self._glowner = None
        self._disposed = False

    def setAttribute(self, name, attr):
        if not isinstance(attr, BufferAttribute):
            attr = BufferAttribute(attr, 3)
        self.attributes[name] = attr
        return self

    def setIndex(self, idx):
        if isinstance(idx, BufferAttribute):
            arr = idx.array
        else:
            arr = np.asarray(idx)
        if arr.dtype not in (np.uint16, np.uint32):
            arr = arr.astype(np.uint32 if (arr.size and int(arr.max()) > 65535) else np.uint16)
        self.index = arr
        return self

    def dispose(self):
        if self._disposed:
            return
        self._disposed = True
        if self._gl is not None:
            GLResources.retire(self._gl, self._glowner)
            self._gl = None


class Material(object):
    isMeshBasicMaterial = False
    isShaderMaterial = False

    def __init__(self):
        self.id = _nextId()
        self.transparent = False
        self.opacity = 1.0
        self.depthTest = True
        self.depthWrite = True
        self.side = FrontSide
        self.clippingPlanes = None
        self.clipping = False
        self.visible = True

    def dispose(self):
        pass


class MeshBasicMaterial(Material):
    isMeshBasicMaterial = True

    def __init__(self, o=None):
        Material.__init__(self)
        o = o or {}
        self.color = Color(o.get('color', 0xffffff))
        self.side = o.get('side', FrontSide)
        self.transparent = o.get('transparent', False)
        self.opacity = o.get('opacity', 1.0)
        self.wireframe = o.get('wireframe', False)
        if 'clippingPlanes' in o:
            self.clippingPlanes = o['clippingPlanes']

    def clone(self):
        m = MeshBasicMaterial({'color': 0})
        m.color = Color(0)
        m.color.r, m.color.g, m.color.b = self.color.r, self.color.g, self.color.b
        m.side = self.side
        m.transparent = self.transparent
        m.opacity = self.opacity
        m.depthTest = self.depthTest
        m.depthWrite = self.depthWrite
        m.clippingPlanes = self.clippingPlanes
        return m


class ShaderMaterial(Material):
    isShaderMaterial = True

    def __init__(self, o=None):
        Material.__init__(self)
        o = o or {}
        self.uniforms = o.get('uniforms', {})
        self.kind = o.get('kind', 'sdf')
        self.transparent = o.get('transparent', False)
        self.depthWrite = o.get('depthWrite', True)
        self.depthTest = o.get('depthTest', True)
        self.side = o.get('side', FrontSide)
        self.clipping = o.get('clipping', False)
        self._color = None

    def clone(self):
        m = ShaderMaterial({'kind': self.kind})
        # three.js's ShaderMaterial.clone() DEEP-COPIES the uniforms, which is
        # why the callers re-point the shared screen-size refs afterwards.
        m.uniforms = {}
        for k, v in self.uniforms.items():
            m.uniforms[k] = {'value': v['value']}
        m.transparent = self.transparent
        m.depthWrite = self.depthWrite
        m.depthTest = self.depthTest
        m.side = self.side
        m.clipping = self.clipping
        m.clippingPlanes = self.clippingPlanes
        m._color = self._color
        return m


class Mesh(Object3D):
    isMesh = True

    def __init__(self, geometry=None, material=None):
        Object3D.__init__(self)
        self.geometry = geometry
        self.material = material
        self.frustumCulled = True


class PlaneGeometry(BufferGeometry):
    def __init__(self, w=1.0, h=1.0):
        BufferGeometry.__init__(self)
        hw = w / 2.0
        hh = h / 2.0
        self.setAttribute('position', Float32BufferAttribute(
            [-hw, hh, 0, hw, hh, 0, -hw, -hh, 0, hw, -hh, 0], 3))
        self.setIndex([0, 2, 1, 2, 3, 1])


class RingGeometry(BufferGeometry):
    """three.js RingGeometry(innerRadius, outerRadius, thetaSegments)."""

    def __init__(self, inner=0.5, outer=1.0, segs=8):
        BufferGeometry.__init__(self)
        segs = max(3, int(segs))
        verts = []
        idx = []
        for i in range(segs + 1):
            a = 2 * math.pi * i / segs
            ca = math.cos(a)
            sa = math.sin(a)
            verts += [inner * ca, inner * sa, 0.0, outer * ca, outer * sa, 0.0]
        for i in range(segs):
            a = 2 * i
            idx += [a, a + 1, a + 2, a + 1, a + 3, a + 2]
        self.setAttribute('position', Float32BufferAttribute(verts, 3))
        self.setIndex(idx)


class OrthographicCamera(object):
    def __init__(self, left, right, top, bottom, near, far):
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.near = near
        self.far = far
        self.zoom = 1.0
        self.position = Vec3()
        self.projectionMatrix = np.eye(4, dtype=np.float64)
        self.updateProjectionMatrix()

    def lookAt(self, *_a):
        # The camera sits at the origin looking at the origin, which three.js
        # resolves to the identity rotation; nothing to do.
        return self

    def updateProjectionMatrix(self):
        dx = (self.right - self.left) / (2 * self.zoom)
        dy = (self.top - self.bottom) / (2 * self.zoom)
        cx = (self.right + self.left) / 2
        cy = (self.top + self.bottom) / 2
        left = cx - dx
        right = cx + dx
        top = cy + dy
        bottom = cy - dy
        w = 1.0 / (right - left)
        h = 1.0 / (top - bottom)
        p = 1.0 / (self.far - self.near)
        x = (right + left) * w
        y = (top + bottom) * h
        z = (self.far + self.near) * p
        m = np.zeros((4, 4), dtype=np.float64)
        m[0, 0] = 2 * w
        m[1, 1] = 2 * h
        m[2, 2] = -2 * p
        m[0, 3] = -x
        m[1, 3] = -y
        m[2, 3] = -z
        m[3, 3] = 1.0
        self.projectionMatrix = m
        return self

    def viewMatrix(self):
        m = np.eye(4, dtype=np.float64)
        m[0, 3] = -self.position.x
        m[1, 3] = -self.position.y
        m[2, 3] = -self.position.z
        return m


# ---------------------------------------------------------------------------
# GL resource bookkeeping
#
# Geometries come and go every time a screen rebuilds, so their buffers have
# to be released with a live context.  dispose() parks them here and the
# renderer sweeps the list at the top of each frame.
# ---------------------------------------------------------------------------
class GLResources(object):
    # Keyed by the renderer that made the buffers.  Several MDUs can share one
    # process, and each has its own GL context; destroying a buffer while a
    # different context is current corrupts the wrong display.
    _retired = {}

    @staticmethod
    def retire(res, owner):
        GLResources._retired.setdefault(id(owner), []).append(res)

    @staticmethod
    def sweep(owner):
        lst = GLResources._retired.get(id(owner))
        if not lst:
            return
        for res in lst:
            for b in res:
                try:
                    b.destroy()
                except Exception:
                    pass
        del lst[:]


# ---------------------------------------------------------------------------
# meds/shader/sdfLine.coffee -- SDF (signed-distance-field) polyline renderer
#
# Each segment of the polyline becomes one screen-aligned quad.  The vertex
# shader projects both endpoints, expands the quad in *screen pixel* space (so
# stroke width is uniform regardless of the display's anisotropic world-unit
# scales), and the fragment shader evaluates the exact distance from the pixel
# to the segment (capsule SDF), feathering the edge with smoothstep.  Result:
# smooth, thick, antialiased strokes with round caps and round joins at any
# angle.  Dashes ride a per-segment cumulative-distance attribute.
# ---------------------------------------------------------------------------

SDF_VERT = """#version 330 core
in vec3 position;
in vec3 endA;
in vec3 endB;
in vec2 corner;
in vec2 segDist;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform vec2 resolution;
uniform float halfWidthPx;
uniform float aaPx;
uniform float pxRatio;
out vec2 vA;
out vec2 vB;
out vec2 vDist;
out vec3 vClipPosition;

void main() {
  vec4 clipA = projectionMatrix * modelViewMatrix * vec4(endA, 1.0);
  vec4 clipB = projectionMatrix * modelViewMatrix * vec4(endB, 1.0);
  vec2 sA = (clipA.xy / clipA.w * 0.5 + 0.5) * resolution;
  vec2 sB = (clipB.xy / clipB.w * 0.5 + 0.5) * resolution;
  vec2 ab = sB - sA;
  float len = length(ab);
  // zero-length segment renders as a round dot via the cap expansion
  vec2 dir = len > 1e-6 ? ab / len : vec2(1.0, 0.0);
  vec2 nrm = vec2(-dir.y, dir.x);
  float ext = (halfWidthPx + aaPx) * pxRatio + 1.0;
  vec2 sP = mix(sA, sB, corner.x)
          + dir * (corner.x * 2.0 - 1.0) * ext   // extend past ends for caps
          + nrm * corner.y * ext;                // widen across the line
  float cw = mix(clipA.w, clipB.w, corner.x);
  float cz = mix(clipA.z, clipB.z, corner.x);
  gl_Position = vec4((sP / resolution * 2.0 - 1.0) * cw, cz, cw);
  vA = sA;
  vB = sB;
  vDist = segDist;
  // clip-test position of the ACTUAL expanded corner, not the segment
  // endpoint: convert the screen-px expansion back to view units via the
  // ortho projection scale (exact for these ortho displays).
  vec4 mvPosition = modelViewMatrix * vec4(mix(endA, endB, corner.x), 1.0);
  vec2 ndcOff = (sP - mix(sA, sB, corner.x)) / resolution * 2.0;
  mvPosition.xy += ndcOff / vec2(projectionMatrix[0][0], projectionMatrix[1][1]);
  vClipPosition = -mvPosition.xyz;
}
"""

SDF_FRAG = """#version 330 core
uniform vec3 diffuse;
uniform float opacity;
uniform float halfWidthPx;
uniform float aaPx;
uniform float pxRatio;
uniform float dashSize;
uniform float gapSize;
uniform int numClippingPlanes;
uniform vec4 clippingPlanes[4];
in vec2 vA;
in vec2 vB;
in vec2 vDist;
in vec3 vClipPosition;
out vec4 fragColor;

void main() {
  for (int i = 0; i < 4; i++) {
    if (i >= numClippingPlanes) break;
    vec4 plane = clippingPlanes[i];
    if (dot(vClipPosition, plane.xyz) > plane.w) discard;
  }
  vec2 ba = vB - vA;
  float l2 = dot(ba, ba);
  float t = l2 > 0.0 ? clamp(dot(gl_FragCoord.xy - vA, ba) / l2, 0.0, 1.0) : 0.0;
  float d = distance(gl_FragCoord.xy, vA + ba * t);
  float hw = halfWidthPx * pxRatio;
  float aa = max(aaPx * pxRatio, 1e-3);
  float alpha = 1.0 - smoothstep(hw - aa, hw + aa, d);
  if (gapSize > 0.0) {
    float lineD = mix(vDist.x, vDist.y, t);
    float period = dashSize + gapSize;
    float dw = mod(lineD, period);
    float hd = dashSize * 0.5;
    // soften dash ends by the same feather, converted to world units
    float soft = max(aa * (vDist.y - vDist.x) / max(sqrt(l2), 1e-3), 1e-4);
    alpha *= 1.0 - smoothstep(hd - soft, hd + soft, abs(dw - hd));
  }
  alpha *= opacity;
  if (alpha < 0.004) discard;
  fragColor = vec4(diffuse, alpha);
}
"""

BASIC_VERT = """#version 330 core
in vec3 position;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
out vec3 vClipPosition;
void main() {
  vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
  vClipPosition = -mvPosition.xyz;
  gl_Position = projectionMatrix * mvPosition;
}
"""

BASIC_FRAG = """#version 330 core
uniform vec3 diffuse;
uniform float opacity;
uniform int numClippingPlanes;
uniform vec4 clippingPlanes[4];
in vec3 vClipPosition;
out vec4 fragColor;
void main() {
  for (int i = 0; i < 4; i++) {
    if (i >= numClippingPlanes) break;
    vec4 plane = clippingPlanes[i];
    if (dot(vClipPosition, plane.xyz) > plane.w) discard;
  }
  fragColor = vec4(diffuse, opacity);
}
"""


def _sdfAttrs(coords_list, z=100.0):
    """Shared expansion: a list of polylines -> the five SDF attributes."""
    segs = []
    for pl in coords_list:
        if pl is None or len(pl) < 2:
            continue
        a = np.zeros((len(pl), 3), dtype=np.float64)
        for i, p in enumerate(pl):
            a[i, 0] = p[0]
            a[i, 1] = p[1]
            a[i, 2] = p[2] if (len(p) > 2 and p[2] is not None) else z
        segs.append(a)
    n = sum(len(a) - 1 for a in segs)
    pos = np.zeros((n * 4, 3), dtype=np.float32)
    endA = np.zeros((n * 4, 3), dtype=np.float32)
    endB = np.zeros((n * 4, 3), dtype=np.float32)
    corner = np.zeros((n * 4, 2), dtype=np.float32)
    segDist = np.zeros((n * 4, 2), dtype=np.float32)
    idx = np.zeros(n * 6, dtype=(np.uint32 if n * 4 > 65535 else np.uint16))
    s = 0
    for a in segs:
        A = a[:-1]
        B = a[1:]
        d = np.hypot(B[:, 0] - A[:, 0], B[:, 1] - A[:, 1])
        cum = np.concatenate(([0.0], np.cumsum(d)))
        m = len(A)
        sl = slice(s * 4, (s + m) * 4)
        # verts 0,1 sit at A; 2,3 at B; side -1/+1 across the line
        pv = np.empty((m, 4, 3), dtype=np.float32)
        pv[:, 0, :] = A
        pv[:, 1, :] = A
        pv[:, 2, :] = B
        pv[:, 3, :] = B
        pos[sl] = pv.reshape(-1, 3)
        endA[sl] = np.repeat(A, 4, axis=0)
        endB[sl] = np.repeat(B, 4, axis=0)
        cv = np.tile(np.array([[0, -1], [0, 1], [1, -1], [1, 1]], dtype=np.float32), (m, 1))
        corner[sl] = cv
        dv = np.empty((m, 4, 2), dtype=np.float32)
        dv[:, :, 0] = cum[:-1, None]
        dv[:, :, 1] = cum[1:, None]
        segDist[sl] = dv.reshape(-1, 2)
        base = (np.arange(m, dtype=np.int64) + s) * 4
        quad = np.array([0, 2, 1, 2, 3, 1], dtype=np.int64)
        idx[s * 6:(s + m) * 6] = (base[:, None] + quad[None, :]).reshape(-1)
        s += m
    return pos, endA, endB, corner, segDist, idx


def makeSDFLineGeometry(coords, z=100.0):
    """One quad (4 verts / 6 indices) per segment.  Endpoints ride along as
    attributes so the fragment shader can evaluate the true segment SDF."""
    return makeSDFLinesGeometry([coords], z)


def makeSDFLinesGeometry(polylines, z=100.0):
    """Batched variant: many disjoint polylines in one BufferGeometry (a
    single draw call).  Used for the ADI ball markings."""
    pos, endA, endB, corner, segDist, idx = _sdfAttrs(polylines, z)
    geom = BufferGeometry()
    geom.setAttribute('position', BufferAttribute(pos.reshape(-1), 3))
    geom.setAttribute('endA', BufferAttribute(endA.reshape(-1), 3))
    geom.setAttribute('endB', BufferAttribute(endB.reshape(-1), 3))
    geom.setAttribute('corner', BufferAttribute(corner.reshape(-1), 2))
    geom.setAttribute('segDist', BufferAttribute(segDist.reshape(-1), 2))
    geom.index = idx
    return geom


def makeSDFLineMaterial(opt=None):
    """opt: color, opacity, widthPx (full stroke width, display px), aaPx
    (edge feather half-width, display px), dashSize/gapSize (world units;
    gapSize<=0 means solid), resolution/pxRatio (shared uniform refs so one
    update reaches every material)."""
    opt = opt or {}
    uniforms = {
        'diffuse': {'value': Color(opt.get('color', 0xffffff))},
        'opacity': {'value': opt.get('opacity', 1.0)},
        'halfWidthPx': {'value': opt.get('widthPx', 2.0) / 2.0},
        'aaPx': {'value': opt.get('aaPx', 1.0)},
        'dashSize': {'value': opt.get('dashSize', 1.0)},
        'gapSize': {'value': opt.get('gapSize', 0.0)},
    }
    uniforms['resolution'] = opt.get('resolution') or {'value': [720.0, 720.0]}
    uniforms['pxRatio'] = opt.get('pxRatio') or {'value': 1.0}
    mat = ShaderMaterial({
        'kind': 'sdf',
        'uniforms': uniforms,
        'transparent': True,
        'depthWrite': False,     # AA fringe must not depth-block crossing lines
        'side': DoubleSide,
        'clipping': True,        # honour material.clippingPlanes (tape windows)
    })
    mat._color = opt.get('color')
    return mat


# ---------------------------------------------------------------------------
# The renderer
# ---------------------------------------------------------------------------
class _Program(object):
    def __init__(self, prog, attrs):
        self.prog = prog
        self.attrs = attrs
        self.loc = {}

    def u(self, name):
        l = self.loc.get(name)
        if l is None:
            l = self.prog.uniformLocation(name)
            self.loc[name] = l
        return l


class GLRenderer(object):
    """A small subset of THREE.WebGLRenderer: it draws Meshes with the two
    materials this application uses, in three.js's own order, with three.js's
    depth and clipping rules."""

    def __init__(self):
        self.f = None
        self.vao = None
        self.programs = {}
        self.clearColor = Color(0x000000)
        self.localClippingEnabled = False
        self._enabledAttrs = 0
        self._geomCache = {}

    def init(self, f):
        from PyQt6.QtOpenGL import (QOpenGLShaderProgram, QOpenGLShader,
                                    QOpenGLVertexArrayObject)
        self.f = f
        self.vao = QOpenGLVertexArrayObject()
        self.vao.create()
        self.vao.bind()

        def build(vsrc, fsrc, attrs):
            p = QOpenGLShaderProgram()
            if not p.addShaderFromSourceCode(QOpenGLShader.ShaderTypeBit.Vertex, vsrc):
                raise RuntimeError("vertex shader: " + p.log())
            if not p.addShaderFromSourceCode(QOpenGLShader.ShaderTypeBit.Fragment, fsrc):
                raise RuntimeError("fragment shader: " + p.log())
            for i, a in enumerate(attrs):
                p.bindAttributeLocation(a[0], i)
            if not p.link():
                raise RuntimeError("link: " + p.log())
            return _Program(p, attrs)

        self.programs['basic'] = build(BASIC_VERT, BASIC_FRAG, [('position', 3)])
        self.programs['sdf'] = build(SDF_VERT, SDF_FRAG,
                                     [('position', 3), ('endA', 3), ('endB', 3),
                                      ('corner', 2), ('segDist', 2)])
        f.glDisable(GL_CULL_FACE)
        f.glEnable(GL_MULTISAMPLE)
        # three.js's Material.depthFunc defaults to LessEqualDepth, and the
        # displays lean on it hard: tape faces, readout boxes, green pointer
        # arrows and the menu masks are all coplanar at z 0, and the one drawn
        # LAST is meant to win.  Under GL_LESS every one of them disappears
        # behind whatever was drawn first at the same depth.
        f.glDepthFunc(GL_LEQUAL)
        f.glBlendEquation(GL_FUNC_ADD)
        f.glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
                              GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

    # -- geometry buffers ---------------------------------------------------
    def _bufs(self, geom):
        from PyQt6.QtOpenGL import QOpenGLBuffer
        g = geom._gl
        if g is not None:
            return g
        bufs = {}
        keep = []
        for name, attr in geom.attributes.items():
            arr = np.ascontiguousarray(attr.array, dtype=np.float32)
            b = QOpenGLBuffer(QOpenGLBuffer.Type.VertexBuffer)
            b.create()
            b.bind()
            b.allocate(arr.tobytes(), arr.nbytes)
            bufs[name] = (b, attr.itemSize)
            keep.append(b)
        ib = None
        count = 0
        itype = GL_UNSIGNED_SHORT
        if geom.index is not None and geom.index.size:
            iarr = np.ascontiguousarray(geom.index)
            itype = GL_UNSIGNED_INT if iarr.dtype == np.uint32 else GL_UNSIGNED_SHORT
            ib = QOpenGLBuffer(QOpenGLBuffer.Type.IndexBuffer)
            ib.create()
            ib.bind()
            ib.allocate(iarr.tobytes(), iarr.nbytes)
            count = int(iarr.size)
            keep.append(ib)
        g = {'bufs': bufs, 'ib': ib, 'count': count, 'itype': itype, 'keep': keep}
        geom._gl = keep            # the sweep list wants the raw buffers
        geom._glinfo = g
        geom._glowner = self
        return keep

    def _geominfo(self, geom):
        if geom._gl is None:
            self._bufs(geom)
        return geom._glinfo

    # -- the frame ----------------------------------------------------------
    def render(self, scene, camera, fbw, fbh):
        f = self.f
        GLResources.sweep(self)
        f.glViewport(0, 0, int(fbw), int(fbh))
        c = self.clearColor
        f.glClearColor(c.r, c.g, c.b, 1.0)
        f.glDepthMask(True)
        f.glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        proj = camera.projectionMatrix
        view = camera.viewMatrix()
        projScreen = proj @ view

        opaque = []
        transparent = []

        def walk(o, pm):
            if not o.visible:
                return
            wm = pm @ o.localMatrix()
            o.matrixWorld = wm
            if o.isMesh and o.geometry is not None and o.material is not None \
                    and o.material.visible:
                p = projScreen @ np.array([wm[0, 3], wm[1, 3], wm[2, 3], 1.0])
                z = p[2] / p[3] if p[3] else p[2]
                item = (o, wm, z)
                (transparent if o.material.transparent else opaque).append(item)
            for ch in o.children:
                walk(ch, wm)

        walk(scene, np.eye(4, dtype=np.float64))

        # three.js painterSortStable / reversePainterSortStable
        opaque.sort(key=lambda it: (it[0].renderOrder, it[0].material.id,
                                    it[2], it[0].id))
        transparent.sort(key=lambda it: (it[0].renderOrder, -it[2], it[0].id))

        self._curProg = None
        self._curMat = None
        self._state = {}
        for lst in (opaque, transparent):
            for o, wm, _z in lst:
                self._draw(o, wm, proj, view)
        f.glDepthMask(True)

    def _setAttrs(self, pr, info):
        f = self.f
        bufs = info['bufs']
        for i, (name, size) in enumerate(pr.attrs):
            ent = bufs.get(name)
            if ent is None:
                f.glDisableVertexAttribArray(i)
                continue
            ent[0].bind()
            f.glEnableVertexAttribArray(i)
            f.glVertexAttribPointer(i, ent[1], GL_FLOAT, 0, 0, 0)
        n = len(pr.attrs)
        while n < self._enabledAttrs:
            f.glDisableVertexAttribArray(n)
            n += 1
        self._enabledAttrs = len(pr.attrs)

    def _draw(self, mesh, wm, proj, view):
        from PyQt6.QtGui import QMatrix4x4, QVector2D, QVector3D, QVector4D
        f = self.f
        mat = mesh.material
        geom = mesh.geometry
        if geom._disposed:
            return
        info = self._geominfo(geom)
        if info['count'] == 0:
            return
        kind = mat.kind if mat.isShaderMaterial else 'basic'
        pr = self.programs[kind]
        if self._curProg is not pr:
            pr.prog.bind()
            self._curProg = pr
            self._curMat = None
            self._projSet = None
            pr.prog.setUniformValue(pr.u('projectionMatrix'),
                                    QMatrix4x4(*[float(v) for v in proj.reshape(-1)]))
        # depth / blend state
        if mat.depthTest:
            f.glEnable(GL_DEPTH_TEST)
        else:
            f.glDisable(GL_DEPTH_TEST)
        f.glDepthMask(bool(mat.depthWrite))
        if mat.transparent:
            f.glEnable(GL_BLEND)
        else:
            f.glDisable(GL_BLEND)
        # material uniforms
        if self._curMat is not mat:
            self._curMat = mat
            if kind == 'sdf':
                u = mat.uniforms
                col = u['diffuse']['value']
                pr.prog.setUniformValue(pr.u('diffuse'), QVector3D(col.r, col.g, col.b))
                pr.prog.setUniformValue(pr.u('opacity'), float(u['opacity']['value']))
                pr.prog.setUniformValue(pr.u('halfWidthPx'), float(u['halfWidthPx']['value']))
                pr.prog.setUniformValue(pr.u('aaPx'), float(u['aaPx']['value']))
                pr.prog.setUniformValue(pr.u('dashSize'), float(u['dashSize']['value']))
                pr.prog.setUniformValue(pr.u('gapSize'), float(u['gapSize']['value']))
                res = u['resolution']['value']
                pr.prog.setUniformValue(pr.u('resolution'), QVector2D(res[0], res[1]))
                pr.prog.setUniformValue(pr.u('pxRatio'), float(u['pxRatio']['value']))
            else:
                col = mat.color
                pr.prog.setUniformValue(pr.u('diffuse'), QVector3D(col.r, col.g, col.b))
                pr.prog.setUniformValue(pr.u('opacity'), float(mat.opacity))
            planes = mat.clippingPlanes if self.localClippingEnabled else None
            if planes:
                pr.prog.setUniformValue(pr.u('numClippingPlanes'), int(len(planes)))
                pr.prog.setUniformValueArray(
                    pr.u('clippingPlanes'),
                    [QVector4D(p.normal.x, p.normal.y, p.normal.z, p.constant)
                     for p in planes[0:4]])
            else:
                pr.prog.setUniformValue(pr.u('numClippingPlanes'), 0)
        mv = view @ wm
        pr.prog.setUniformValue(pr.u('modelViewMatrix'),
                                QMatrix4x4(*[float(v) for v in mv.reshape(-1)]))
        self._setAttrs(pr, info)
        info['ib'].bind()
        f.glDrawElements(GL_TRIANGLES, info['count'], info['itype'], None)


# ===========================================================================
# meds/mduScreen_DPS.coffee -- the page-geometry adjustments
#
# ONE MUTABLE OBJECT so the param editor can drive them live.  Waiting five
# minutes for a relaunch to try a constant is not a way to find four
# constants.  Env vars still set the starting values; Shift+X (or a
# double-click outside the canvas) opens the sliders.
#
#   rowGap  spacing between text rows (1 = the measured-correct pitch)
#   textY   glyphs only
#   vecY    vectors only -- boxes, lines, the POLL FAIL cross
#   pageY   the whole page: text, vectors, furniture and the menu rule
#   menuX   the MAIN MENU area, horizontally
#   viewX/viewY  PAN the camera
# ===========================================================================

# NSTS_CELL_TRACE=<file> appends one line per drawn glyph -- which pass drew
# it, the character cell it landed in, and the character.  Capped: a refresh
# draws hundreds and there are two a second.
_cellTraceLeft = [0]

# SCREEN ANNOUNCEMENTS, for crew scripts that wait on a page (crewscript.py's
# 'wait crt N title TEXT' and 'wait crt N new-screen').  After each refresh a
# DPS screen takes its top two text lines and sends one UTF-8 datagram,
# "<mdu name>\n<line 1>\n<line 2>", to the bus group at port base +
# SCREEN_OFFSET: when the lines change (clocks aside) and the change has held
# for two refreshes, so a blinking field is not a new page, and otherwise at
# least every SCREEN_REANNOUNCE_S, so a listener started later soon knows.
SCREEN_OFFSET = 91
SCREEN_REANNOUNCE_S = 1.0
SCREEN_CLOCK = re.compile(r"(\d+/)?\d\d:\d\d:\d\d")
_screenSock = [None]


def announceScreen(name, lines):
    if _screenSock[0] is None:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                     socket.inet_aton(os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        _screenSock[0] = s
    try:
        _screenSock[0].sendto(("%s\n%s" % (name, "\n".join(lines))).encode('utf-8'),
                              (MCAST_GROUP, PORT_BASE + SCREEN_OFFSET))
    except OSError:
        pass
_gridTally = {'seen': 0, 'bad': 0}
CELL_TRACE_PER_FRAME = 4000

# Per-glyph vertical corrections, for characters the font itself puts in the
# wrong place.  The underscore's ink sits a full row below its anchor.
GLYPH_DY = {'_': -0.15}

ADJ = {
    'rowGap': envnum('NSTS_DPS_ROWGAP', 1),
    # -2.52, fitted against Don's video with the REAL frustum.
    'textY': envnum('NSTS_DPS_TEXTY', -2.52),
    # +0.50: the rules were landing exactly on the top strokes of the row
    # below, so centring them in the 0.30-row gap is 4 px up.
    'vecY': envnum('NSTS_DPS_VECY', 0.50),
    'textX': envnum('NSTS_DPS_TEXTX', -0.71),
    'vecX': envnum('NSTS_DPS_VECX', 0.41),
    'pageY': envnum('NSTS_DPS_YSHIFT', 1),
    'menuX': envnum('NSTS_MENU_DX', 0),
    'viewX': envnum('NSTS_VIEW_DX', 0),
    'viewY': envnum('NSTS_VIEW_DY', 0),
}


# ---------------------------------------------------------------------------
# CoffeeScript ranges
# ---------------------------------------------------------------------------
def crange(a, b, step=None, inclusive=True):
    """`[a..b]` / `[a...b]`, with an optional `by step`."""
    out = []
    if step is None:
        step = 1 if a <= b else -1
    if step == 0:
        return out
    i = a
    if step > 0:
        while (i <= b) if inclusive else (i < b):
            out.append(i)
            i += step
    else:
        while (i >= b) if inclusive else (i > b):
            out.append(i)
            i += step
    return out


def rad2deg(v):
    return v * (180 / math.pi)


def deg2rad(v):
    return v * (math.pi / 180)


class Vector4(object):
    __slots__ = ('x', 'y', 'z', 'w')

    def __init__(self, x=0.0, y=0.0, z=0.0, w=0.0):
        self.x = x
        self.y = y
        self.z = z
        self.w = w


# ===========================================================================
# The vector fonts
#
# `data/deu_font.svg` and `data/meds_font.svg` are stroke fonts: one SVG group
# per glyph, holding lines / polylines / polygons / paths.  A group's id is
# the character code less 33 (Illustrator prepends a 'c'), which is where
# `String.fromCharCode(parseInt(id) + 33)` comes from.
# ===========================================================================

def _svg_all_elements(path):
    """Every element in the document, in document order, less the root -- what
    jQuery's `$('*', svg)` walks."""
    tree = ET.parse(path)
    root = tree.getroot()
    out = []

    def walk(e):
        for c in list(e):
            out.append(c)
            walk(c)
    walk(root)
    return out


def _tag(e):
    return e.tag.split('}')[-1]


def _pointsAttr(s):
    nums = [float(v) for v in re.findall(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?', s or '')]
    return [(nums[i], nums[i + 1]) for i in range(0, len(nums) - 1, 2)]


_PATH_TOKEN = re.compile(r'([MmZzLlHhVvCcSsQqTtAa])|([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)')
_PATH_ARGC = {'M': 2, 'L': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'Q': 4, 'T': 2,
              'A': 7, 'Z': 0}


def _parsePathData(d):
    """getPathData(): the segments as authored, `{type, values}`."""
    toks = _PATH_TOKEN.findall(d or '')
    out = []
    cmd = None
    args = []
    i = 0
    vals = []
    for c, n in toks:
        if c:
            vals.append(('c', c))
        else:
            vals.append(('n', float(n)))
    while i < len(vals):
        kind, v = vals[i]
        if kind == 'c':
            cmd = v
            i += 1
        elif cmd is None:
            i += 1
            continue
        argc = _PATH_ARGC.get(cmd.upper(), 0)
        if argc == 0:
            out.append({'type': cmd, 'values': []})
            if kind == 'c':
                continue
            i += 1
            continue
        args = []
        while len(args) < argc and i < len(vals) and vals[i][0] == 'n':
            args.append(vals[i][1])
            i += 1
        if len(args) < argc:
            break
        out.append({'type': cmd, 'values': args})
        # An implicit repeat of M continues as L, per the SVG grammar; the
        # original leaned on the path-data polyfill, which does the same.
        if cmd == 'M':
            cmd = 'L'
        elif cmd == 'm':
            cmd = 'l'
    return out


class CharGen(object):
    def __init__(self, suffix, CONFIG=None):
        self.suffix = suffix
        self.CONFIG = CONFIG or {}
        self.chars = {' ': []}
        self.loadCharSVG()
        self.scaleGlyphs(float(self.CONFIG.get('textScale', 1.0)))

    def scaleGlyphs(self, k):
        """`--scale` / a config `textScale`: resize every glyph about the
        font's digit ink centre -- meds (1.368, 0.330), the same point as
        GXC/GYC -- so each glyph keeps its place and only its size changes.
        Advances, anchors and every non-text stroke are untouched, and because
        the SDF stroke width is in pixels, so is the weight of the lines."""
        if k == 1.0:
            return
        pts = [p for c in '0123456789' for s in self.chars.get(c, []) for p in s]
        cx = (min(p[0] for p in pts) + max(p[0] for p in pts)) / 2
        cy = (min(p[1] for p in pts) + max(p[1] for p in pts)) / 2
        for ch, strokes in self.chars.items():
            self.chars[ch] = [[[cx + (p[0] - cx) * k, cy + (p[1] - cy) * k]
                               for p in stroke] for stroke in strokes]

    def loadCharSVG(self):
        path = os.path.join(NSTS_TOP, 'data',
                            'meds_font.svg' if self.suffix == 'meds' else 'deu_font.svg')
        for desc in _svg_all_elements(path):
            self.makeGlyphMesh(desc)

    def makeGlyphMesh(self, svgDesc):
        eid = svgDesc.get('id') or ''
        if eid[0:1] == 'c':
            # Illustrator prepends a '_' if the layer starts with a number
            eid = eid[1:]
        n = js_parse_int(eid)
        if n is None:
            chrv = '\0'                    # String.fromCharCode(NaN)
        else:
            code = n + 33
            chrv = chr(code) if 0 <= code <= 0x10ffff else '\0'

        strokes = []
        # 0.9*(xoff + xc/s) with the font's own scale factors, then the cell
        # origin offsets; this is what puts a glyph inside its character cell.
        def scl(xc, xoff, s):
            return 0.9 * (xoff + xc / s)

        def xy(xc, yc):
            return [0.95 + scl(xc, 0, 512 / 43), 0.10 + scl(yc, 0, 512 / 30)]

        for stroke in _iter_descendants(svgDesc):
            tg = _tag(stroke)
            if tg == 'line':
                p1 = xy(js_parse_float(stroke.get('x1')), js_parse_float(stroke.get('y1')))
                p2 = xy(js_parse_float(stroke.get('x2')), js_parse_float(stroke.get('y2')))
                strokes.append([p1, p2])
            elif tg == 'polyline':
                pts = _pointsAttr(stroke.get('points'))
                strokes.append([xy(p[0], p[1]) for p in pts])
            elif tg == 'polygon':
                pts = _pointsAttr(stroke.get('points'))
                coords = [xy(p[0], p[1]) for p in pts]
                if pts:
                    coords.append(xy(pts[0][0], pts[0][1]))
                strokes.append(coords)
            elif tg == 'path':
                data = _parsePathData(stroke.get('d'))
                lastPt = [0.0, 0.0]
                coords = []
                for pt in data:
                    t = pt['type']
                    v = pt['values']
                    if t == 'M':
                        lastPt = list(v)
                        coords.append(xy(v[0], v[1]))
                    elif t == 'm':
                        lastPt = [lastPt[0] + v[0], lastPt[1] + v[1]]
                    elif t == 'V':
                        lastPt[1] = v[0]
                        coords.append(xy(lastPt[0], v[0]))
                    elif t == 'v':
                        newPt = [lastPt[0], lastPt[1] + v[0]]
                        coords.append(xy(newPt[0], newPt[1]))
                        lastPt = newPt
                    elif t == 'H':
                        lastPt[0] = v[0]
                        coords.append(xy(v[0], lastPt[1]))
                    elif t == 'h':
                        newPt = [lastPt[0] + v[0], lastPt[1]]
                        coords.append(xy(newPt[0], newPt[1]))
                        lastPt = newPt
                    elif t == 'L':
                        lastPt = list(v)
                        coords.append(xy(v[0], v[1]))
                    elif t == 'l':
                        newPt = [lastPt[0] + v[0], lastPt[1] + v[1]]
                        coords.append(xy(newPt[0], newPt[1]))
                        lastPt = newPt
                    elif t == 'Z':
                        if coords:
                            coords.append(coords[0])
                strokes.append(coords)
        self.chars[chrv] = strokes

    def drawGlyph(self, mdu, dl, glyphChar, x, y, c, scaleFactor=1.0, scalex=1.0,
                  rot=0, centered=False, clip=None):
        if glyphChar not in self.chars:
            return []
        strokes = self.chars[glyphChar]
        if not strokes:
            return []

        gcx = 0.0
        gcy = 0.0
        if rot or centered:
            # glyph bounding-box centre (used to spin and/or centre about it)
            minx = miny = 1e9
            maxx = maxy = -1e9
            for stroke in strokes:
                for p in stroke:
                    minx = min(minx, p[0])
                    maxx = max(maxx, p[0])
                    miny = min(miny, p[1])
                    maxy = max(maxy, p[1])
            gcx = (minx + maxx) / 2
            gcy = (miny + maxy) / 2

        if rot:
            # rotate in pixel-proportional space (cols and rows have different
            # px scales) so the glyph stays rigid instead of shearing
            cs = math.cos(rot)
            sn = math.sin(rot)
            AR = 18.789 / 13.783                      # pxRow/pxCol
            strokes = [[[gcx + (p[0] - gcx) * cs - (p[1] - gcy) * AR * sn,
                         gcy + (p[0] - gcx) * sn / AR + (p[1] - gcy) * cs]
                        for p in stroke] for stroke in strokes]

        # One batched mesh for the whole glyph: every stroke shares the
        # material and the transform, so this is the same picture in one draw.
        buffer = mdu.lines(strokes, c, 1.0, clip, mdu.TEXT_STROKE)
        if centered:
            buffer.position.set(x - scaleFactor * scalex * gcx,
                                y - scaleFactor * gcy, 0)
        else:
            buffer.position.set(x - 1, y, 0)
        buffer.scale.set(scaleFactor * scalex, scaleFactor, 1)
        return [buffer]


def _iter_descendants(e):
    out = []

    def walk(x):
        for c in list(x):
            out.append(c)
            walk(c)
    walk(e)
    return out


# ===========================================================================
# meds/mduVectorDisplay.coffee -- the MDU's vector display
#
# "Anti-aliasing filters are responsible for converting the 576x576 Video RAM
# image into the 1152x1152 addressability required by the LCD.  An active
# display area of 6.71x6.71 in. is achieved with 1152x1152 pixels resolution
# and 28 shades of gray per primary color."
#   ref. THESIS - The Space Shuttle Orbiter's Advanced Display Designs (1995)
#
# Display coordinate system: the 51x26 character grid plus borders and the
# menu area, so world units are character cells.
# ===========================================================================

class MDUGLWidget(QOpenGLWidget):
    def __init__(self, disp, parent=None):
        QOpenGLWidget.__init__(self, parent)
        self.disp = disp
        self.setMouseTracking(True)
        self.setFocusPolicy(Qt.FocusPolicy.NoFocus)

    def initializeGL(self):
        prof = QOpenGLVersionProfile()
        prof.setVersion(4, 1)
        prof.setProfile(QSurfaceFormat.OpenGLContextProfile.CoreProfile)
        f = QOpenGLVersionFunctionsFactory.get(prof, self.context())
        if f is None:
            raise RuntimeError(
                "MEDS2: an OpenGL 4.1 core profile is required "
                "(this display gave %d.%d)" % (self.context().format().majorVersion(),
                                               self.context().format().minorVersion()))
        f.initializeOpenGLFunctions()
        self.disp.renderer.init(f)
        self.disp.renderer.clearColor = Color(self.disp.c2h['black'])
        self.disp.renderer.localClippingEnabled = True
        self.disp.dirty = True

    def resizeGL(self, w, h):
        self.disp.dirty = True

    def paintGL(self):
        self.disp.renderFrame()


class VectorDisplay(object):
    # THE FRUSTUM HAS ONE DEFINITION.  It had two that disagreed, and
    # whichever ran last won, so calling resetCamera silently rescaled the
    # page by 2% horizontally and moved it.
    CAM_L = 0.20
    CAM_R = 52.442456
    CAM_T = 0.25 - 2 + 0.374
    # THE BOTTOM STOPS JUST UNDER THE MENU.  It was 38.57 - 2 + 0.374 (36.944),
    # 1.39 units below the lowest thing ever drawn -- the edgekey legend
    # frames, at 36.2 in a menu area placed 0.643 up (MDUMenuArea.build), so
    # 35.557 -- and with the edgekey strip under the display that band of blank
    # canvas sat between the menu and its keys.  It now ends CAM_B_GAP below
    # the frames, and MDUWindow makes the canvas shorter by the same fraction
    # (canvas_height_k), so nothing on the page moves or rescales.  Measured
    # on a 1016 px display: 36 rows of blank canvas between frames and strip.
    CAM_B_FULL = 38.57 - 2 + 0.374
    CAM_B_GAP = 0.3
    CAM_B = 36.2 - 0.643 + CAM_B_GAP

    @classmethod
    def canvas_height_k(cls):
        """The canvas height per unit of the configured (square) display size."""
        return (cls.CAM_B - cls.CAM_T) / (cls.CAM_B_FULL - cls.CAM_T)

    CHAR_WIDTH = 53
    CHAR_HEIGHT = 38

    def __init__(self, CONFIG):
        self.CONFIG = CONFIG
        self._overlays = {}
        self._leftInset = 0
        self.makeConstants()
        self.init()

    def makeConstants(self):
        self.c2h = {
            'black': 0x101336,
            'darkGray': 0x777780,
            'lightGray': 0x9999a0,
            'white': 0xffffff,
            'orange': 0xff8c06,
            'red': 0xff232b,
            'yellow': 0xfff600,
            'cyan': 0x2dfada,
            'magenta': 0xff43de,
            'lightGreen': 0x48f500,
            'green': 0x48f500,
            'darkGreen': 0x368524,
            'blue': 0x003ce0,
            'pink': 0xfff9d4,
            'brown': 0xff7049,
        }
        # SDF stroke settings, in display pixels: full stroke width and the
        # edge feather half-width.  Shared uniform refs let render() update
        # every line material at once when the framebuffer size changes.
        self.LINE_PX = self.CONFIG.get('lineWidthPx', 2.2)
        self.LINE_AA = self.CONFIG.get('lineSoftness', 1.1)
        # `--stroke-scale` / a config `textStrokeScale`: text strokes are
        # LINE_PX times this; every other line keeps LINE_PX.
        self.TEXT_STROKE = float(self.CONFIG.get('textStrokeScale', 1.0))
        self.wMats = {}             # (key, widthScale) -> width-scaled material
        self.resolutionU = {'value': [720.0, 720.0]}
        self.pxRatioU = {'value': 1.0}
        self.mats = [{}, {}]        # normal, blink
        self.dashMats = {}          # dashed line materials (DEU FEAT lineDash)
        self.bMats = {}
        for _c, v in self.c2h.items():
            self.mats[0][v] = makeSDFLineMaterial(self.sdfOpt({'color': v}))
            self.mats[1][v] = makeSDFLineMaterial(self.sdfOpt({'color': v}))
            self.dashMats[v] = makeSDFLineMaterial(
                self.sdfOpt({'color': v, 'dashSize': 1.0, 'gapSize': 0.35}))
        # graded-brightness green palette for DEU FEAT intensity (0..max).
        # Fade via opacity (not toward black) so whatever is behind shows.
        self.NINT = 32
        self.intMats = []
        for i in range(self.NINT):
            self.intMats.append(makeSDFLineMaterial(
                self.sdfOpt({'color': self.c2h['green'], 'opacity': i / (self.NINT - 1)})))
        self.NO_CLIP = Vector4(0, 100, 0, 100)

    def sdfOpt(self, o):
        d = {'resolution': self.resolutionU, 'pxRatio': self.pxRatioU,
             'widthPx': self.LINE_PX, 'aaPx': self.LINE_AA}
        d.update(o or {})
        return d

    def setZoomCamera(self, zoom, charX, charY):
        """Set the ortho camera to zoom in on a specific character."""
        if zoom == 1:
            self.resetCamera()
            return
        self.camera.left = charX - (self.CHAR_WIDTH / 2) * zoom
        self.camera.right = charX + (self.CHAR_WIDTH / 2) * zoom
        self.camera.top = charY - (self.CHAR_HEIGHT / 2) * zoom
        self.camera.bottom = charY + (self.CHAR_HEIGHT / 2) * zoom
        self.camera.updateProjectionMatrix()

    def resetCamera(self):
        # The pan is applied to BOTH edges of an axis, so the frustum's size
        # is unchanged and nothing rescales.
        dx = ADJ.get('viewX', 0)
        dy = ADJ.get('viewY', 0)
        self.camera.left = self.CAM_L + dx
        self.camera.right = self.CAM_R + dx
        self.camera.top = self.CAM_T + dy
        self.camera.bottom = self.CAM_B + dy
        self.camera.updateProjectionMatrix()

    def init(self):
        self.dirty = True
        self.deuFont = CharGen('deu', self.CONFIG)
        self.medsFont = CharGen('meds', self.CONFIG)
        self.objNorm = []
        self.objBlink = []

        self.widthPx = self.CONFIG['window']['width']
        self.heightPx = self.CONFIG['window']['height']

        # top/bottom +0.374 pans the view ~10px so content sits higher and the
        # menu fits above the bottom clip plane (extent unchanged)
        self.camera = OrthographicCamera(self.CAM_L, self.CAM_R,
                                         self.CAM_T, self.CAM_B, -100, 500)
        self.camera.position.z = 0
        self.superRatio = self.CONFIG.get('supersample', 1)

        self.scene = Scene()
        self.scene.background = Color(self.c2h['black'])
        self.camera.lookAt(self.scene)

        self.renderer = GLRenderer()
        self.widget = MDUGLWidget(self)
        self._dbSize = [0.0, 0.0]

    # -- the frame ----------------------------------------------------------
    def renderFrame(self):
        # keep the SDF line materials in sync with the framebuffer size so the
        # screen-space stroke width stays constant in display pixels
        dpr = self.widget.devicePixelRatioF()
        w = max(1.0, self.widget.width() * dpr)
        h = max(1.0, self.widget.height() * dpr)
        if [w, h] != self.resolutionU['value']:
            self.resolutionU['value'] = [w, h]
            self.pxRatioU['value'] = w / self.widthPx
            self.dirty = True
        self.renderer.clearColor = Color(self.c2h['black'])
        self.renderer.render(self.scene, self.camera, w, h)
        self.dirty = False

    def clear(self):
        for child in list(reversed(self.scene.children)):
            self.scene.remove(child)
            if getattr(child, 'geometry', None) is not None:
                child.geometry.dispose()

    def add(self, gl):
        # `for geom in gl` is CoffeeScript's INDEXED loop, so a caller that
        # hands over a bare Object3D (several do) drives it zero times and
        # nothing is added.  That is the original's behaviour and some screens
        # depend on it -- reproduce it rather than quietly "fixing" it.
        if not isinstance(gl, (list, tuple)):
            return
        for geom in gl:
            self.scene.add(geom)

    def delete(self, gl):
        if not isinstance(gl, (list, tuple)):
            return
        for geom in gl:
            self.scene.remove(geom)
            if getattr(geom, 'geometry', None) is not None:
                geom.geometry.dispose()

    # -- text ---------------------------------------------------------------
    def str(self, x, y, s, color=None, scale=1.0, advance=1.0, scalex=1.0,
            charGen=None, rot=0, centered=False, clip=None):
        if color is None:
            color = self.c2h['cyan']
        if charGen is None:
            charGen = self.deuFont
        xx = x
        group = Object3D()
        group.name = s
        for c in s:
            if c == '\n':
                y += 1 * scale
                xx = x - 1
            geoms = charGen.drawGlyph(self, None, c, xx, y, color, scale, scalex,
                                      rot, centered, clip)
            for geom in geoms:
                group.add(geom)
            xx = xx + advance
        return group

    def strMEDS(self, x, y, s, color=None, scale=1.0, advance=0.62, scalex=1.0,
                clip=None):
        if color is None:
            color = self.c2h['cyan']
        return self.str(x, y, s, color, scale, advance, scalex, self.medsFont,
                        0, False, clip)

    def strCond(self, x, y, s, color=None, scale=1.0, advance=1.0):
        if color is None:
            color = self.c2h['cyan']
        return self.str(x, y, s, color, scale, advance, 1.0, self.deuFont)

    def strCtrReg(self, x, y, s, color=None, scale=1.0, cw=51):
        if color is None:
            color = self.c2h['cyan']
        xx = (cw - len(s) - 1) / 2
        return self.str(x + xx, y, s, color, scale, 1.0, 1.0, self.deuFont)

    def strCtr(self, y, s, color=None, scale=1.0, cw=52):
        if color is None:
            color = self.c2h['cyan']
        xx = (cw - len(s)) / 2
        return self.strCond(xx, y, s, color, scale)

    def arrow(self, x, color=None):
        if color is None:
            color = self.c2h['cyan']
        return self.line([
            [x + 2.85, 36.25], [x + 2.85, 35.46], [x + 1.35, 35.46],
            [x + 4.10, 34.41], [x + 6.6, 35.46], [x + 5.28, 35.46],
            [x + 5.28, 36.25]], color)

    # -- clipping -----------------------------------------------------------
    def clipPlanes(self, cb):
        """Four clipping planes bounding a clipBox = Vector4(xMin,xMax,yMin,
        yMax) in display col/row coords."""
        return [
            Plane(Vec3(1, 0, 0), -cb.x),    # keep x >= xMin
            Plane(Vec3(-1, 0, 0), cb.y),    # keep x <= xMax
            Plane(Vec3(0, 1, 0), -cb.z),    # keep y >= yMin
            Plane(Vec3(0, -1, 0), cb.w),    # keep y <= yMax
        ]

    def _clipMat(self, material, clip):
        """Clip to a window (tape) by cloning a shared material."""
        if clip is None or clip is self.NO_CLIP:
            return material
        material = material.clone()
        material.clippingPlanes = self.clipPlanes(clip)
        # clone() deep-copies uniforms; re-share the screen-size refs
        material.uniforms['resolution'] = self.resolutionU
        material.uniforms['pxRatio'] = self.pxRatioU
        return material

    # -- strokes ------------------------------------------------------------
    def _scaledMat(self, key, widthScale, opt):
        """A stroke material LINE_PX x widthScale wide, built once per key."""
        k = (key, widthScale)
        material = self.wMats.get(k)
        if material is None:
            o = dict(opt)
            o['widthPx'] = self.LINE_PX * widthScale
            material = self.wMats[k] = makeSDFLineMaterial(self.sdfOpt(o))
        return material

    def solidMat(self, color, widthScale=1.0):
        """The shared solid material for `color`; at widthScale 1 it is the
        palette's own, so unscaled drawing is exactly what it always was."""
        if widthScale != 1.0:
            return self._scaledMat(color, widthScale, {'color': color})
        material = self.mats[0].get(color)
        if material is None:
            # colours outside the c2h palette get a material built on demand
            material = makeSDFLineMaterial(self.sdfOpt({'color': color}))
            self.mats[0][color] = material
        return material

    def lines(self, polylines, color=None, intensity=1.0, clip=None,
              widthScale=1.0):
        """The batched form of `line`: many polylines, one material, one draw.
        widthScale multiplies the stroke width (text uses TEXT_STROKE)."""
        if color is None:
            color = self.c2h['cyan']
        # legacy callers (menu edgekey titles) pass a material as the colour;
        # the old THREE.Line path silently ignored it and rendered the default
        # white hairline -- keep that look
        if isinstance(color, Material):
            color = self.c2h['white']
        # color may be a spec {c, border, borderPx}: the stroke is drawn twice
        # -- a widened underlay in the border colour, then the core on top.
        # Cores render at renderOrder 1 (above ALL borders) so crossing strokes
        # don't notch each other's halo.
        if isinstance(color, dict) and color.get('border') is not None:
            cc = color.get('c', self.c2h['white'])
            bp = color.get('borderPx', 0.9)
            # the halo stays bp px either side of however wide the core is
            key = "%s|%s|%s" % (cc, color['border'], bp)
            if widthScale != 1.0:
                key += "|%s" % widthScale
            bMat = self.bMats.get(key)
            if bMat is None:
                bMat = makeSDFLineMaterial(self.sdfOpt(
                    {'color': color['border'],
                     'widthPx': self.LINE_PX * widthScale + 2 * bp}))
                self.bMats[key] = bMat
            cMat = self.solidMat(cc, widthScale)
            geom = makeSDFLinesGeometry(polylines)      # shared by both passes
            g = Object3D()
            for mat, order in ((bMat, 0), (cMat, 1)):
                mesh = Mesh(geom, self._clipMat(mat, clip))
                mesh.frustumCulled = False
                mesh.renderOrder = order
                g.add(mesh)
            return g
        # intensity < 1 fades via opacity (green palette; DEU FEAT intensity)
        if intensity >= 0.999:
            material = self.solidMat(color, widthScale)
        else:
            i = max(0, min(self.NINT - 1, jsround(intensity * (self.NINT - 1))))
            material = self.intMats[i] if widthScale == 1.0 else self._scaledMat(
                ('int', i), widthScale,
                {'color': self.c2h['green'], 'opacity': i / (self.NINT - 1)})
        mesh = Mesh(makeSDFLinesGeometry(polylines), self._clipMat(material, clip))
        mesh.frustumCulled = False   # quads are expanded in the vertex shader
        return mesh

    def line(self, coords, color=None, intensity=1.0, clip=None):
        return self.lines([coords], color, intensity, clip)

    def dashedLine(self, coords, color=None):
        """Dashed variant of line() for DEU FEAT lineDash."""
        if color is None:
            color = self.c2h['cyan']
        material = self.dashMats.get(color) or self.mats[0].get(color)
        mesh = Mesh(makeSDFLineGeometry(coords), material)
        mesh.frustumCulled = False
        return mesh

    # -- fills --------------------------------------------------------------
    def box(self, x1, y1, x2, y2, color=UNDEF, fillColor=None, clip=None):
        # CoffeeScript 2 compiles parameter defaults to ES6 ones, so an
        # explicit `null` does NOT take the default -- it suppresses the
        # outline.  UNDEF is what "argument omitted" looks like here.
        if color is UNDEF:
            color = self.c2h['green']
        g = Object3D()
        if fillColor:
            fill = MeshBasicMaterial({'color': fillColor, 'side': DoubleSide})
            if clip is not None and clip is not self.NO_CLIP:
                fill.clippingPlanes = self.clipPlanes(clip)
            dl = BufferGeometry()
            dl.setAttribute('position', Float32BufferAttribute(
                [x1, y1, 0, x2, y1, 0, x2, y2, 0, x1, y2, 0], 3))
            dl.setIndex([0, 1, 2, 0, 2, 3])
            g.add(Mesh(dl, fill))
        if color:
            g.add(self.line([[x1, y1], [x2, y1], [x2, y2], [x1, y2], [x1, y1]],
                            color, 1.0, clip))
        return g

    def polyFill(self, pts, fillColor=None, borderColor=None, clip=None):
        """Filled convex polygon (triangle fan) with an optional border."""
        if fillColor is None:
            fillColor = self.c2h['darkGray']
        g = Object3D()
        verts = []
        for p in pts:
            verts += [p[0], p[1], 0]
        idx = []
        for i in range(1, len(pts) - 1):
            idx += [0, i, i + 1]
        geom = BufferGeometry()
        geom.setAttribute('position', Float32BufferAttribute(verts, 3))
        geom.setIndex(idx)
        mat = MeshBasicMaterial({'color': fillColor, 'side': DoubleSide})
        if clip is not None and clip is not self.NO_CLIP:
            mat.clippingPlanes = self.clipPlanes(clip)
        g.add(Mesh(geom, mat))
        if borderColor:
            g.add(self.line(list(pts) + [pts[0]], borderColor, 1.0, clip))
        return g

    def quad(self, v, color=None, fillColor=None):
        g = Object3D()
        if fillColor:
            fill = MeshBasicMaterial({'color': fillColor, 'side': DoubleSide})
            dl = BufferGeometry()
            dl.setAttribute('position', Float32BufferAttribute(v, 3))
            dl.setIndex([0, 1, 2, 0, 2, 3])
            g.add(Mesh(dl, fill))
        return g

    def tri(self, x1, y1, x2, y2, x3, y3, color=None, fillColor=None):
        if fillColor:
            fill = MeshBasicMaterial({'color': fillColor, 'side': DoubleSide})
            dl = BufferGeometry()
            dl.setAttribute('position', Float32BufferAttribute(
                [x1, y1, 0, x2, y2, 0, x3, y3, 0], 3))
            dl.setIndex([0, 1, 2])
            return Mesh(dl, fill)
        if color is None:
            color = self.c2h['green']
        return self.line([[x1, y1], [x2, y2], [x3, y3]], color)

    # -- arcs ---------------------------------------------------------------
    def arc(self, x, y, r, sa, ea, color=None, asp=1.47222):
        """asp: x aspect factor.  Default 1.47222 is the empirical row->col
        stretch matching the MEDS reference imagery.  Pass 1 when drawing
        inside a group that already applies its own x scale."""
        if color is None:
            color = self.c2h['darkGray']
        l = []
        for a in crange(sa, ea + 1, None, False):
            l.append([x + (r * math.cos(deg2rad(a))) * asp,
                      y + (r * math.sin(deg2rad(a))) * 1.00])
        return self.line(l, color)

    def filledArc(self, x, y, r, sa, ea, color=0x333333):
        pts = []
        for a in crange(sa, ea + 1, None, False):
            pts.append([x + (r * math.cos(deg2rad(a))) * 1.47222,
                        y + r * math.sin(deg2rad(a))])
        verts = []
        for p in pts:
            verts += [p[0], p[1], 0]
        idx = []
        for i in range(1, len(pts) - 1):
            idx += [0, i, i + 1]
        dl = BufferGeometry()
        dl.setAttribute('position', Float32BufferAttribute(verts, 3))
        dl.setIndex(idx)
        return Mesh(dl, MeshBasicMaterial({'color': color, 'side': DoubleSide}))

    def arcTicks(self, x, y, r, sa, ea, step, ln, color=None, asp=1.47222):
        if color is None:
            color = self.c2h['darkGray']
        ticks = Object3D()
        ticks.name = "ticks"
        for a in crange(sa, ea + 1, step, False):
            cp = [x + (r * math.cos(deg2rad(a))) * asp, y + r * math.sin(deg2rad(a))]
            cpn = [x + ((r + ln) * math.cos(deg2rad(a))) * asp,
                   y + (r + ln) * math.sin(deg2rad(a))]
            ticks.add(self.line([cp, cpn], color))
        return ticks

    def arcLabels(self, x, y, r, sa, ea, step, ln, labelTxt, color=None, scale=0.9):
        if color is None:
            color = self.c2h['darkGray']
        labels = Object3D()
        labels.name = "arcLabels"
        i = 0
        for a in crange(sa, ea + 1, step, False):
            cpn = [x + ((r + ln) * math.cos(deg2rad(a))) * 1.47222,
                   y + (r + ln) * math.sin(deg2rad(a))]
            labels.add(self.strMEDS(cpn[0], cpn[1], labelTxt[i], color, scale, 0.9, 1.0))
            i += 1
        return labels

    def arcArrow(self, x, y, r, a, color=None):
        return None

    def tickScale(self, x1, y1, x2, y2, step, ln, color=None):
        return None


# ---------------------------------------------------------------------------
# DEBUG: reference-screenshot overlays
#
# Images live in data/overlay_images/ and are selectable live from the param
# editor's 'reference overlay' group, which every screen carries.  Drag the
# body to move; drag any of the 4 green corner handles to distort (perspective
# warp for off-angle photos); the cyan edge diamonds move both of an edge's
# corners.  Double-click the image to set a rotation centre (small red cross)
# then type a signed angle; double-click a handle for the sub-pixel nudge
# tool.  Corners, opacity and the image choice persist per key.
# ---------------------------------------------------------------------------
OVERLAY_DIR = 'data/overlay_images/'
_OV_BW = 640
_OV_BH = 640


class OverlayWidget(QtWidgets.QWidget):
    HANDLE = 14
    EHANDLE = 12

    def __init__(self, disp, key, imgFile, parent):
        QtWidgets.QWidget.__init__(self, parent)
        self.disp = disp
        self.key = key
        self.pix = None
        self.curImg = imgFile
        self.opacity = 0.5
        self.corners = None
        self.rotCenter = None
        self.rotDeg = 0.0
        self.nudgeSel = None
        self._drag = None
        self.edges = [(0, 1), (2, 3), (0, 2), (1, 3)]   # top, bottom, left, right
        self.setMouseTracking(True)
        self.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents, False)
        self._load()
        self._buildTools()
        self.setGeometry(0, 0, parent.width(), parent.height())

    # -- persistence --------------------------------------------------------
    def _load(self):
        g = ls_json(self.key)
        if g:
            o = g.get('opacity')
            self.opacity = o if isinstance(o, (int, float)) else 0.5
            c = g.get('corners')
            if isinstance(c, list) and len(c) == 4:
                self.corners = [[p[0], p[1]] for p in c]
            elif all(isinstance(g.get(k), (int, float)) for k in ('left', 'width')):
                self.corners = [[g['left'], g['top']],
                                [g['left'] + g['width'], g['top']],
                                [g['left'], g['top'] + g['height']],
                                [g['left'] + g['width'], g['top'] + g['height']]]
            self.rotCenter = list(g['rotCenter']) if (
                isinstance(g.get('rotCenter'), list) and len(g['rotCenter']) == 2) else None
            self.rotDeg = g.get('rotDeg', 0) or 0
        self.loadImg((g or {}).get('img') or self.curImg)
        if self.corners:
            xs = [p[0] for p in self.corners]
            ys = [p[1] for p in self.corners]
            if not (max(xs) - min(xs) >= 40 and max(ys) - min(ys) >= 40):
                self.corners = None       # reject degenerate/collapsed saves
        if not self.corners:
            self.corners = [[40, 40], [40 + _OV_BW, 40],
                            [40, 40 + _OV_BH], [40 + _OV_BW, 40 + _OV_BH]]
        if g and g.get('corners') and g.get('ver') != 2:
            # one-time: contents moved up ~10px -> shift the overlay to match
            self.corners = [[cx, cy - 10] for cx, cy in self.corners]
            self.save()
        if not (g or {}).get('img'):
            self.save()

    def loadImg(self, name):
        if not name:
            return
        try:
            path = os.path.join(NSTS_TOP, OVERLAY_DIR, name)
            pix = QtGui.QPixmap(path)
            if pix.isNull():
                raise IOError("not an image")
            self.pix = pix
            self.curImg = name
        except Exception as e:
            print("overlay: can't read %s%s: %s" % (OVERLAY_DIR, name, e))

    def state(self):
        return {'corners': [list(c) for c in self.corners], 'opacity': self.opacity,
                'ver': 2, 'rotCenter': (list(self.rotCenter) if self.rotCenter else None),
                'rotDeg': self.rotDeg, 'img': self.curImg}

    def save(self):
        try:
            localStorage.setItem(self.key, json.dumps(self.state()))
        except Exception:
            pass

    def load(self, st):
        if not st or len(st.get('corners') or []) != 4:
            return
        if st.get('img') and st['img'] != self.curImg:
            self.loadImg(st['img'])
        self.corners = [[c[0], c[1]] for c in st['corners']]
        o = st.get('opacity')
        self.opacity = o if isinstance(o, (int, float)) else self.opacity
        rc = st.get('rotCenter')
        self.rotCenter = list(rc) if (isinstance(rc, list) and len(rc) == 2) else None
        self.rotDeg = st.get('rotDeg', 0) or 0
        self.update()
        self.save()

    def setImage(self, name):
        self.loadImg(name)
        self.save()
        self.update()

    # -- the rotate / nudge tools ------------------------------------------
    def _buildTools(self):
        css = ('background:#222; color:#7f7; font:12px monospace; '
               'border:1px solid #7f7;')
        self.rotBox = QtWidgets.QWidget(self)
        rl = QtWidgets.QHBoxLayout(self.rotBox)
        rl.setContentsMargins(4, 2, 4, 2)
        self.rotBox.setStyleSheet(css)
        rl.addWidget(QtWidgets.QLabel(u'rot°'))
        self.rotInput = QtWidgets.QLineEdit()
        self.rotInput.setFixedWidth(70)
        rl.addWidget(self.rotInput)
        self.rotTot = QtWidgets.QLabel('')
        rl.addWidget(self.rotTot)
        self.rotInput.returnPressed.connect(self._rotEnter)
        self.rotBox.hide()

        self.nudgeBox = QtWidgets.QWidget(self)
        nl = QtWidgets.QHBoxLayout(self.nudgeBox)
        nl.setContentsMargins(4, 2, 4, 2)
        self.nudgeBox.setStyleSheet(css)
        self.nTitle = QtWidgets.QLabel('')
        nl.addWidget(self.nTitle)
        self.nX = QtWidgets.QLineEdit(); self.nX.setFixedWidth(60)
        self.nY = QtWidgets.QLineEdit(); self.nY.setFixedWidth(60)
        self.nStep = QtWidgets.QLineEdit('0.25'); self.nStep.setFixedWidth(40)
        nl.addWidget(QtWidgets.QLabel('x')); nl.addWidget(self.nX)
        nl.addWidget(QtWidgets.QLabel('y')); nl.addWidget(self.nY)
        nl.addWidget(QtWidgets.QLabel('step')); nl.addWidget(self.nStep)
        for sym, ndx, ndy in ((u'◀', -1, 0), (u'▶', 1, 0),
                              (u'▲', 0, -1), (u'▼', 0, 1)):
            b = QtWidgets.QPushButton(sym)
            b.setFixedWidth(22)
            b.clicked.connect(lambda _c, dx=ndx, dy=ndy: self._nudgeStep(dx, dy))
            nl.addWidget(b)
        bc = QtWidgets.QPushButton(u'×')
        bc.setFixedWidth(22)
        bc.clicked.connect(lambda: self.selectHandle(None))
        nl.addWidget(bc)
        self.nX.returnPressed.connect(self._nudgeXY)
        self.nY.returnPressed.connect(self._nudgeXY)
        self.nudgeBox.hide()

    def _rotEnter(self):
        try:
            deg = float(self.rotInput.text())
        except ValueError:
            return
        if deg:
            self.rotateBy(deg)
        self.rotInput.setText('')

    def rotateBy(self, deg):
        if not self.rotCenter:
            return
        th = deg * math.pi / 180              # + = clockwise (y down)
        cs = math.cos(th)
        sn = math.sin(th)
        cx, cy = self.rotCenter
        for i, c in enumerate(self.corners):
            dx = c[0] - cx
            dy = c[1] - cy
            self.corners[i] = [cx + dx * cs - dy * sn, cy + dx * sn + dy * cs]
        self.rotDeg += deg
        self.update()
        self.save()

    def _nudgePos(self):
        if not self.nudgeSel:
            return None
        kind, i = self.nudgeSel
        if kind == 'corner':
            return list(self.corners[i])
        a, b = self.edges[i]
        return [(self.corners[a][0] + self.corners[b][0]) / 2,
                (self.corners[a][1] + self.corners[b][1]) / 2]

    def _nudgeBy(self, ndx, ndy):
        if not self.nudgeSel:
            return
        kind, i = self.nudgeSel
        idxs = [i] if kind == 'corner' else list(self.edges[i])
        for k in idxs:
            self.corners[k] = [self.corners[k][0] + ndx, self.corners[k][1] + ndy]
        self.update()
        self.save()
        self._nudgeUI()

    def _nudgeStep(self, dx, dy):
        try:
            s = float(self.nStep.text())
        except ValueError:
            s = 0.25
        if not s:
            s = 0.25
        self._nudgeBy(dx * s, dy * s)

    def _nudgeXY(self):
        if not self.nudgeSel:
            return
        try:
            x = float(self.nX.text())
            y = float(self.nY.text())
        except ValueError:
            return
        p = self._nudgePos()
        self._nudgeBy(x - p[0], y - p[1])

    def _nudgeUI(self):
        if not self.nudgeSel:
            return
        kind, i = self.nudgeSel
        names = ['TL', 'TR', 'BL', 'BR'] if kind == 'corner' else ['top', 'bottom', 'left', 'right']
        self.nTitle.setText("%s %s" % (kind, names[i]))
        p = self._nudgePos()
        self.nX.setText("%.2f" % p[0])
        self.nY.setText("%.2f" % p[1])

    def selectHandle(self, sel):
        self.nudgeSel = sel
        if sel is None:
            self.nudgeBox.hide()
            self.update()
            return
        self._nudgeUI()
        self.nudgeBox.show()
        self.nStep.setFocus()
        self.nStep.selectAll()
        self.update()

    # -- painting -----------------------------------------------------------
    def _handlePts(self):
        return list(self.corners)

    def _edgePts(self):
        return [[(self.corners[a][0] + self.corners[b][0]) / 2,
                 (self.corners[a][1] + self.corners[b][1]) / 2]
                for a, b in self.edges]

    def paintEvent(self, _ev):
        p = QtGui.QPainter(self)
        p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing, True)
        p.setRenderHint(QtGui.QPainter.RenderHint.SmoothPixmapTransform, True)
        ins = self.disp._leftInset or 0
        c = [[x + ins, y] for x, y in self.corners]
        if self.pix is not None:
            src = QtGui.QPolygonF([QPointF(0, 0), QPointF(_OV_BW, 0),
                                   QPointF(_OV_BW, _OV_BH), QPointF(0, _OV_BH)])
            dst = QtGui.QPolygonF([QPointF(*c[0]), QPointF(*c[1]),
                                   QPointF(*c[3]), QPointF(*c[2])])
            t = QtGui.QTransform()
            if QtGui.QTransform.quadToQuad(src, dst, t):
                p.save()
                p.setTransform(t, True)
                p.setOpacity(self.opacity)
                p.drawPixmap(QRectF(0, 0, _OV_BW, _OV_BH), self.pix,
                             QRectF(self.pix.rect()))
                p.restore()
            p.setOpacity(1.0)
        # green outline of the quad
        p.setPen(QtGui.QPen(QColor(0, 255, 0), 1))
        p.setBrush(Qt.BrushStyle.NoBrush)
        p.drawPolygon(QtGui.QPolygonF([QPointF(*c[0]), QPointF(*c[1]),
                                       QPointF(*c[3]), QPointF(*c[2])]))
        # corner handles (green squares) and edge handles (cyan diamonds)
        for i, (hx, hy) in enumerate([[x + ins, y] for x, y in self._handlePts()]):
            p.setBrush(QColor(0, 255, 0))
            p.setPen(QtGui.QPen(QColor(0, 0, 0), 1))
            p.drawRect(QRectF(hx - 7, hy - 7, self.HANDLE, self.HANDLE))
            if self.nudgeSel == ('corner', i):
                p.setPen(QtGui.QPen(QColor(255, 32, 32), 2))
                p.setBrush(Qt.BrushStyle.NoBrush)
                p.drawRect(QRectF(hx - 8, hy - 8, self.HANDLE + 2, self.HANDLE + 2))
        for i, (hx, hy) in enumerate([[x + ins, y] for x, y in self._edgePts()]):
            p.save()
            p.translate(hx, hy)
            p.rotate(45)
            p.setBrush(QColor(0, 255, 255))
            p.setPen(QtGui.QPen(QColor(0, 0, 0), 1))
            p.drawRect(QRectF(-self.EHANDLE / 2, -self.EHANDLE / 2,
                              self.EHANDLE, self.EHANDLE))
            p.restore()
            if self.nudgeSel == ('edge', i):
                p.setPen(QtGui.QPen(QColor(255, 32, 32), 2))
                p.setBrush(Qt.BrushStyle.NoBrush)
                p.drawRect(QRectF(hx - 8, hy - 8, self.EHANDLE + 4, self.EHANDLE + 4))
        if self.rotCenter:
            rx = self.rotCenter[0] + ins
            ry = self.rotCenter[1]
            p.setPen(Qt.PenStyle.NoPen)
            p.setBrush(QColor(255, 32, 32))
            p.drawRect(QRectF(rx - 7, ry - 1, 15, 3))
            p.drawRect(QRectF(rx - 1, ry - 7, 3, 15))
        self._placeTools(ins)

    def _placeTools(self, ins):
        xs = [p[0] + ins for p in self.corners]
        ys = [p[1] for p in self.corners]
        if self.rotCenter:
            self.rotBox.move(int(min(xs)), int(max(ys) + 12))
            self.rotBox.adjustSize()
            self.rotTot.setText(u"Σ %.2f°" % self.rotDeg)
            self.rotBox.show()
        else:
            self.rotBox.hide()
        if self.nudgeSel:
            self.nudgeBox.move(int(min(xs)), int(max(ys) + 44))
            self.nudgeBox.adjustSize()

    # -- mouse --------------------------------------------------------------
    def _hit(self, pos):
        ins = self.disp._leftInset or 0
        for i, (hx, hy) in enumerate(self._handlePts()):
            if abs(pos.x() - (hx + ins)) <= 8 and abs(pos.y() - hy) <= 8:
                return ('corner', i)
        for i, (hx, hy) in enumerate(self._edgePts()):
            if abs(pos.x() - (hx + ins)) <= 8 and abs(pos.y() - hy) <= 8:
                return ('edge', i)
        xs = [p[0] + ins for p in self.corners]
        ys = [p[1] for p in self.corners]
        if min(xs) <= pos.x() <= max(xs) and min(ys) <= pos.y() <= max(ys):
            return ('body', -1)
        return None

    def mousePressEvent(self, ev):
        h = self._hit(ev.position())
        if h is None:
            ev.ignore()
            return
        self._drag = {'what': h, 'x': ev.position().x(), 'y': ev.position().y(),
                      'start': [list(c) for c in self.corners]}
        ev.accept()

    def mouseMoveEvent(self, ev):
        if self._drag is None:
            return
        dx = ev.position().x() - self._drag['x']
        dy = ev.position().y() - self._drag['y']
        kind, i = self._drag['what']
        st = self._drag['start']
        if kind == 'corner':
            self.corners[i] = [st[i][0] + dx, st[i][1] + dy]
        elif kind == 'edge':
            a, b = self.edges[i]
            self.corners[a] = [st[a][0] + dx, st[a][1] + dy]
            self.corners[b] = [st[b][0] + dx, st[b][1] + dy]
        else:
            for k in range(4):
                self.corners[k] = [st[k][0] + dx, st[k][1] + dy]
        self.update()

    def mouseReleaseEvent(self, _ev):
        if self._drag is not None:
            self._drag = None
            self.save()

    def mouseDoubleClickEvent(self, ev):
        h = self._hit(ev.position())
        if h is None:
            ev.ignore()
            return
        if h[0] == 'body':
            ins = self.disp._leftInset or 0
            self.rotCenter = [ev.position().x() - ins, ev.position().y()]
            self.update()
            self.save()
            self.rotInput.setFocus()
        else:
            self.selectHandle(h)
        ev.accept()

    def keyPressEvent(self, ev):
        dd = {Qt.Key.Key_Left: (-1, 0), Qt.Key.Key_Right: (1, 0),
              Qt.Key.Key_Up: (0, -1), Qt.Key.Key_Down: (0, 1)}.get(ev.key())
        if dd is not None and self.nudgeSel:
            self._nudgeStep(dd[0], dd[1])
            ev.accept()
            return
        ev.ignore()


def _vd_overlay_methods():
    """Bolted onto VectorDisplay below -- kept apart only for readability."""

    def toggleOverlay(self, imgFile, key):
        o = self._overlays.get(key)
        if o is not None:
            o.setVisible(not o.isVisible())
            return
        parent = getattr(self, 'window', None) or self.widget.parent() or self.widget
        o = OverlayWidget(self, key, imgFile, parent)
        self._overlays[key] = o
        o.show()
        o.raise_()
        print("overlay %s: drag body to move, green corners to distort, cyan "
              "edges to resize; Shift cycles opacity; dbl-click sets the rotate "
              "centre, then enter +/- degrees below" % o.curImg)

    def cycleOverlayOpacity(self, key):
        o = self._overlays.get(key)
        if o is None:
            return
        steps = [0.25, 0.5, 0.75, 1.0]
        cur = o.opacity or 0.5
        nxt = next((s for s in steps if s > cur + 0.01), steps[0])
        o.opacity = nxt
        o.update()
        o.save()

    def overlayImageNames(self):
        try:
            return sorted(f for f in os.listdir(os.path.join(NSTS_TOP, OVERLAY_DIR))
                          if re.search(r'\.(png|jpe?g|gif|webp)$', f, re.I))
        except Exception as e:
            print("overlay: can't list %s: %s" % (OVERLAY_DIR, e))
            return []

    def overlayImageCur(self, key, dflt=None):
        o = self._overlays.get(key)
        if o is not None:
            return o.curImg
        return (ls_json(key) or {}).get('img') or dflt

    def overlayImageSelect(self, key, name):
        o = self._overlays.get(key)
        if o is not None:
            o.setImage(name)
        else:
            # overlay not built yet: bind the choice into the stored state
            st = ls_json(key) or {}
            st['img'] = name
            try:
                localStorage.setItem(key, json.dumps(st))
            except Exception:
                pass
        return name

    def overlayVisible(self, key):
        o = self._overlays.get(key)
        return o is not None and o.isVisible()

    # -- placement slots ----------------------------------------------------
    def _ovSlots(self, key):
        idx = ls_json("%s:slots" % key)
        if not isinstance(idx, dict):
            idx = {}
        if not idx.get('names'):
            idx['names'] = ['1']
        if idx.get('cur') not in idx['names']:
            idx['cur'] = idx['names'][0]
        return idx

    def overlaySlotNames(self, key):
        return self._ovSlots(key)['names'] + ['new']

    def overlaySlotCur(self, key):
        return self._ovSlots(key)['cur']

    def overlaySlotSelect(self, key, name, hooks=None):
        idx = self._ovSlots(key)
        o = self._overlays.get(key)
        live = o.state() if o is not None else ls_json(key)
        if live is not None and hooks and hooks.get('getData'):
            live['data'] = hooks['getData']()
        if name == 'new':
            n = 1
            while str(n) in idx['names']:
                n += 1
            name = str(n)
            idx['names'].append(name)
            if live is not None:
                localStorage.setItem("%s#%s" % (key, name), json.dumps(live))
            print("overlay %s: new slot %s (copy of %s)" % (key, name, idx['cur']))
        else:
            if name not in idx['names']:
                return idx['cur']
            if name != idx['cur']:
                if live is not None:
                    localStorage.setItem("%s#%s" % (key, idx['cur']), json.dumps(live))
                st = ls_json("%s#%s" % (key, name))
                if st is not None:
                    if o is not None:
                        o.load(st)
                    else:
                        localStorage.setItem(key, json.dumps(st))
                    if st.get('data') and hooks and hooks.get('setData') \
                            and self.overlayApplyVals(key):
                        hooks['setData'](st['data'])
        idx['cur'] = name
        localStorage.setItem("%s:slots" % key, json.dumps(idx))
        return name

    def overlayApplyVals(self, key):
        return localStorage.getItem("%s:applyVals" % key) == '1'

    def overlayApplyValsSet(self, key, v, hooks=None):
        localStorage.setItem("%s:applyVals" % key, '1' if v else '0')
        if v and hooks and hooks.get('setData'):
            st = ls_json("%s#%s" % (key, self.overlaySlotCur(key)))
            if st and st.get('data'):
                hooks['setData'](st['data'])
        return bool(v)

    return locals()


for _n, _fn in _vd_overlay_methods().items():
    setattr(VectorDisplay, _n, _fn)


# ===========================================================================
# meds/mduScreen.coffee -- the screen base class and the vertical gauge
# ===========================================================================

def dispose3D(obj):
    if obj is None:
        return
    for c in list(getattr(obj, 'children', []) or []):
        dispose3D(c)
    g = getattr(obj, 'geometry', None)
    if g is not None:
        g.dispose()
    m = getattr(obj, 'material', None)
    if m is not None:
        m.dispose()


class VertGauge(object):
    def __init__(self, x, y, config, dataSrc):
        self.x = x
        self.y = y
        self.config = config
        self.dataSrc = dataSrc
        self.value = 0
        self.width = 2
        self.validData = True
        self.group = None
        self.dyn = None

    def build(self, t):
        self.group = Object3D()
        yy = self.y - self.config['up'] if self.config.get('up') is not None else self.y
        self.group.add(t.strCtrReg(self.x + 0.5, yy - 1.25 - (self.config.get('labelUp') or 0),
                                   self.config['label'], t.c2h['white'], 1,
                                   self.config['digits']))
        self.dyn = None
        return self.group

    # Everything value/validity-dependent -- digital box+text, meter frame,
    # fill -- rebuilds wholesale on each draw.
    def draw(self, t):
        if self.group is None:
            self.build(t)
        data = self.dataSrc.data()
        v = data.get(self.config['src'])
        # negative value = invalid/'missing' data -> red invalid state
        self.validData = v is not None and v >= 0
        self.value = v if self.validData else 0
        if self.dyn is not None:
            self.group.remove(self.dyn)
            dispose3D(self.dyn)
        self.dyn = Object3D()
        self._drawDigital(t)
        self._drawMeter(t)
        self.group.add(self.dyn)
        return self.group

    def _drawDigital(self, t):
        width = self.config['digits']
        yy = self.y - self.config['up'] if self.config.get('up') is not None else self.y
        boxC = t.c2h['lightGreen'] if self.validData else t.c2h['red']
        # digital box (+ its centred digits) sits ~2px low in the gauge;
        # boxDy: per-gauge extra vertical shift on top of that
        dOff = 0.11 + (self.config.get('boxDy') or 0)
        if self.config.get('medsFont'):
            self.dyn.add(t.box(self.x - 0.1, yy - 0.1, self.x + width + .35, yy + 1.55, boxC))
        else:
            # boxTop: shift the digital box's top edge down (bottom stays put)
            self.dyn.add(t.box(self.x - 0.25, yy - 0.15 + dOff + (self.config.get('boxTop') or 0),
                               self.x + width + 0.25, yy + 1.15 + dOff, boxC))
        # invalid data: meds-font gauges show the digits red, the rest blank
        if not self.validData and not self.config.get('medsFont'):
            return
        txtC = t.c2h['white'] if self.validData else t.c2h['red']
        vStr = ("0000%d" % jsround(self.value))[-self.config['digits']:]
        # digits glyph-bbox-centred on the digital box's centre
        if self.config.get('medsFont'):
            adv = 0.9
            cx = self.x + width / 2 + 0.125
            cy = yy + 0.725
            self.dyn.add(t.str(cx - (len(vStr) - 1) * adv / 2, cy, vStr, txtC, 1.3,
                               adv, 1.1, t.medsFont, 0, True))
        else:
            adv = 0.92
            cx = self.x + width / 2
            cy = yy + 0.5 + dOff + (self.config.get('boxTop') or 0) / 2
            self.dyn.add(t.str(cx - (len(vStr) - 1) * adv / 2, cy, vStr, txtC, 0.94,
                               adv, 1.0, t.deuFont, 0, True))

    def _drawMeter(self, t):
        if self.config.get('medsFont'):
            mx = self.x + (self.config['digits'] / 2) - 1 + .25
            my = self.y + 2.0
        else:
            mx = self.x + (self.config['digits'] / 2) - 1
            my = self.y + 1.8
        my += self.config.get('meterDn') or 0     # meterDn: whole meter down
        rng = self.config['range']
        height = self.config['height'] + .2
        rSize = rng[1] - rng[0]
        # frame (red when invalid) + right-side ticks
        self.dyn.add(t.box(mx, my, mx + 2, my + height,
                           t.c2h['white'] if self.validData else t.c2h['red']))
        for tick in self.config['ticks']:
            frac = (tick - rng[0]) / rSize
            mY = (my + height) - frac * height
            self.dyn.add(t.line([[mx + 2, mY], [mx + 2.95, mY]], t.c2h['white']))
        if not self.validData:
            return                                # invalid: meter blanked
        # value fill: frame bottom up to the value line, status-band coloured
        v = max(rng[0], min(rng[1], self.value))
        yV = my + ((rng[1] - v) / rSize) * height
        if yV < my + height - 0.02:
            self.dyn.add(t.box(mx, yV, mx + 2, my + height, None,
                               self._valueToColor(t, self.value)))

    def _valueToColor(self, t, v):
        c = t.c2h['white']
        # numeric ascending -- Object.keys sorts lexically ('291' before '45')
        for bp in sorted(int(k) for k in self.config['status'].keys()):
            if v >= bp:
                c = t.c2h[self.config['status'][bp]]
        return c


class MDUScreen(object):
    def __init__(self, d):
        self.d = d
        self.group = None
        self.curData = None
        self.build()

    def setData(self, curData=None):
        self.curData = curData

    def draw(self):
        pass

    def build(self):
        pass

    def refreshFeed(self):
        """Debug parameter editor hook: repaint after live curData pokes.  The
        default rebuilds the screen wholesale and swaps the fresh group into
        the scene."""
        old = self.group
        self.build()
        self.draw()
        if old is not None and self.group is not None and self.group is not old \
                and old.parent is not None:
            p = old.parent
            p.remove(old)
            p.add(self.group)
            dispose3D(old)

    def ovHooks(self):
        """Reference-overlay slot hooks: each overlay image shows the MEDS
        screen in a particular configuration, so slot snapshots also capture
        this screen's feed values."""
        def getData():
            try:
                return json.loads(json.dumps(self.curData or {}))
            except Exception:
                return {}

        def setData(d):
            if self.curData is None:
                self.curData = {}
            self.curData.update(d)
            self.refreshFeed()
        return {'getData': getData, 'setData': setData}

    def testControls(self):
        return []

    def vx(self, x):
        return x * (51 / 1152)

    def vy(self, y):
        return y * (30 / 1008)

    def drawHorizGauge(self, value, tickLeft, tickRight, tickBot, sLen, lLen,
                       count, top=True):
        group = Object3D()
        if top:
            sTickTop = tickBot - sLen
            lTickTop = tickBot - lLen
            tTickBot = tickBot + .5
            tTickTop = tickBot - .7
            arrowC = self.d.c2h['yellow']
        else:
            sTickTop = tickBot + sLen
            lTickTop = tickBot + lLen
            tTickBot = tickBot - .5
            tTickTop = tickBot + .7
            arrowC = self.d.c2h['cyan']
        scaleLen = tickRight - tickLeft
        group.add(self.d.line([[tickLeft, tickBot], [tickRight, tickBot]],
                              self.d.c2h['white']))
        for i in range(0, count + 1):
            x = i * (scaleLen / count)
            x2 = sTickTop if (i % 2) else lTickTop
            group.add(self.d.line([[tickLeft + x, tickBot], [tickLeft + x, x2]],
                                  self.d.c2h['white']))
        if value is not None:
            x = tickLeft + (value * (scaleLen / count))
            ptr = self.d.tri(x - .9, tTickBot, x, tTickTop, x + 0.9, tTickBot,
                             None, arrowC)
            # SDF ticks are transparent-pass quads; join that pass above the
            # line cores (renderOrder 1) so the pointer always paints on top
            ptr.material.transparent = True
            ptr.material.depthTest = False
            ptr.renderOrder = 2
            group.add(ptr)
        return group

    def drawVertGauge(self, value, tickTop, tickBot, tickLeft, sLen, lLen,
                      count, left=True):
        group = Object3D()
        if left:
            sTickRight = tickLeft - sLen
            lTickRight = tickLeft - lLen
            tTickLeft = tickLeft + .75
            tTickRight = tickLeft - .85
        else:
            sTickRight = tickLeft + sLen
            lTickRight = tickLeft + lLen
            tTickLeft = tickLeft - .75
            tTickRight = tickLeft + .85
        scaleLen = tickBot - tickTop
        group.add(self.d.line([[tickLeft, tickTop], [tickLeft, tickBot]],
                              self.d.c2h['white']))
        for i in range(0, count + 1):
            x = i * (scaleLen / count)
            x2 = sTickRight if (i % 2) else lTickRight
            group.add(self.d.line([[tickLeft, tickTop + x], [x2, tickTop + x]],
                                  self.d.c2h['white']))
        if value is not None:
            x = tickTop + (value * (scaleLen / count))
            ptr = self.d.tri(tTickLeft, x - .6, tTickRight, x, tTickLeft, x + 0.6,
                             None, self.d.c2h['yellow'])
            ptr.material.transparent = True
            ptr.material.depthTest = False
            ptr.renderOrder = 2
            group.add(ptr)
        return group


# ===========================================================================
# meds/mduScreen_DPS.coffee -- the DPS page and the DEU beam interpreter
#
# An FCW stream is a program for a stroke-writing beam.  Mode-register writes
# latch drawing state, position words move the beam, a glyph word draws one or
# two characters and advances the beam by the MAJOR step, and a carriage
# return sends it back to the start of the line and on by the MINOR step.  A
# vector is a run of six words; a circle is one word inside the same mode
# bracket, and a land-site label is a pair of words holding three characters.
#
# A section ends at the end-of-refresh bit in an FCW2, or at a BRANCH with
# nowhere left to go.
# ===========================================================================

# THE IDP IDENTIFIER BOX AND KEYBOARD BARS at the foot of a DPS page.  "Located
# toward the bottom of each DPS display is a box with its commanding IDP
# number inside it" (Crew Software Interface, USA006083 Rev B, 2.2); the red
# bar left of the box is the commander's (left) keyboard and the yellow bar
# right of it the pilot's (right) keyboard, drawn on whichever IDP each
# IDP/CRT SEL switch has selected (2.5).  IDP 4's display has the box and never
# a bar.  MEDS carried the assembly as 'gpcNo', a placeholder "1" and a red
# left bar that nothing changed.  The number is now the IDP driving the MDU
# and the bars come from the IDP's heartbeat (MDUMsg.KYBD_SEL).  (A photograph
# of seven MEDS displays, gigapan.com/gigapans/102753, shows it on one: CRT1
# with "2" and a yellow right bar -- IDP 2 with the pilot's keyboard, not
# GPC 4, which drove it.)  --no-idp-box or NSTS_DPS_IDP_BOX=0 hides it.
SHOW_IDP_BOX = str(env('NSTS_DPS_IDP_BOX', '1')) not in ('', '0')


class Screen_DPS(MDUScreen):
    POLL_FAIL_COLOR = 48
    POLL_FAIL_X = [[0, 1, 52, 27], [52, 1, 0, 27]]
    POLL_FAIL_AT = [41, 26]

    MAX_FCW_STEPS = 40000     # a runaway branch loop must not hang the frame
    # THE GEOMETRY DISCRIMINATOR.  The two conventions are BOTH historical, so
    # this is not a legality test: walk the list, count the position words
    # outside GPCIPL's +/-512 by +/-365 window, and if the answer is "most of
    # them" the other geometry is the one this list is in.
    GEOM_BAD_FRACTION = 0.15

    # "The flash rate for characters is 1 Hz with 5/8 sec 'on' time and 3/8
    # second 'off' time".  The IDP beats eight times a second, so a phase is
    # five beats lit and three dark.
    BLINK_ON_BEATS = 5
    BLINK_OFF_BEATS = 3

    # DEU self-test slot sizes (the layout in enterSelfTest depends on them)
    ST_CHAR_WORDS = 3
    ST_CHARROT_WORDS = 4
    ST_VECTOR_WORDS = 6

    def __init__(self, d):
        self.fcw = None
        self.spl = None
        self.bgFCWS = None
        self._blinkOn = None
        self._blinkBeats = 0
        self._clock = None
        self._dfbFiles = None
        self._dfbIndex = None
        self.selfTestOn = False
        self._stTimer = None
        self._stLayout = None
        self.gpcNo = None
        self.kybd = None
        self.geo_pollFail = None
        self.geo_dps_scratch_err = None
        MDUScreen.__init__(self, d)

    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {'kybd': 'left', 'gpcNo': 1, 'pollFail': False,
                            'syntaxError': False}
        self.init()

    def data(self):
        return self.curData

    def setGPCNo(self, gpcNo):
        """The number in the identifier box: the IDP, despite the name."""
        self.gpcNo = gpcNo
        if self.curData is not None:
            self.curData['gpcNo'] = gpcNo
        if self.group is None:
            return                       # build() draws it from curData
        self.group.remove(self.geo_gpcNo)
        # where build() puts it
        self.geo_gpcNo = self.d.str(24.48, 28.735, "%s" % self.gpcNo,
                                    self.d.c2h['green'], 1.75)
        if SHOW_IDP_BOX:
            self.group.add(self.geo_gpcNo)
        self.d.dirty = True

    def setKybd(self, kybd):
        """The keyboard bars: 'left', 'right', 'both' or None."""
        self.kybd = kybd
        if self.curData is not None:
            self.curData['kybd'] = kybd
        if self.group is None:
            return
        self.group.remove(self.geo_kybd_left)
        self.group.remove(self.geo_kybd_right)
        if SHOW_IDP_BOX:
            if self.kybd in ('left', 'both'):
                self.group.add(self.geo_kybd_left)
            if self.kybd in ('right', 'both'):
                self.group.add(self.geo_kybd_right)
        self.d.dirty = True

    KYBD_OF_MASK = {0: None, 1: 'left', 2: 'right', 3: 'both'}

    def setIdpBox(self, idpNo, mask):
        """The identifier box and bars from the MDU: which IDP drives it, and
        which forward keyboards that IDP takes (bit 0 left, bit 1 right).
        Cheap when nothing changed, since the heartbeat calls it."""
        if idpNo is not None and idpNo != self.gpcNo:
            self.setGPCNo(idpNo)
        kybd = self.KYBD_OF_MASK[mask & 3]
        if kybd != self.kybd:
            self.setKybd(kybd)

    def _pollFailFCWs(self):
        fcws = [self.fcw.colorMode(self.POLL_FAIL_COLOR),
                self.fcw.attrMode({'intensity': True})]
        for seg in self.POLL_FAIL_X:
            fcws = fcws + self.fcw.vector(*seg)
        return fcws + self.makeDFB("POLL FAIL", {'xy': self.POLL_FAIL_AT})

    def setPollFail(self, fail):
        if self.curData is not None:
            self.curData['pollFail'] = fail
        # POLL FAIL shares the scratch pad line, and takes 10 characters off
        # what may be entered on it: 29 rather than 39.
        if self.spl is not None:
            self.spl.pollFail = fail
        if self.fcw is None or self.geo_pollFail is None:
            return
        self.geo_pollFail = self.drawFCWS(self._pollFailFCWs() if fail else [],
                                          self.geo_pollFail)

    def setSyntaxError(self, err):
        if self.curData is not None:
            self.curData['syntaxError'] = err
        if self.geo_dps_scratch_err is not None:
            self.group.remove(self.geo_dps_scratch_err)
            dispose3D(self.geo_dps_scratch_err)
            self.geo_dps_scratch_err = None
        if err:
            self.geo_dps_scratch_err = self.d.str(48, 27, "ERR", self.d.c2h['red'])
            self.group.add(self.geo_dps_scratch_err)
        self.d.dirty = True

    def applyFill(self, addr, words):
        """A fill of the unit's display memory: `words` load at `addr`, and the
        screen redraws from the refresh entry point afterwards."""
        n = len(self.bgFCWS)
        for i, w in enumerate(words):
            self.bgFCWS[(addr + i) & (n - 1)] = w & 0xffff
        self.refresh()

    def refresh(self):
        """Redraw the display from display memory.  The refresh starts at the
        display header and follows the branch words from there."""
        global _gridTally
        _gridTally = {'seen': 0, 'bad': 0}
        self._drawPasses()
        if _gridTally['seen'] == 0:
            return
        # AN ABSOLUTE CHOICE, NOT A TOGGLE: `inAUGrid` tests the RAW halfword,
        # so the tally is the same whichever geometry the walk just used.
        # Deciding which geometry the words belong to is a pure function of
        # the words, so decide that and set it.
        if _gridTally['bad'] > _gridTally['seen'] * self.GEOM_BAD_FRACTION:
            want = 'dfg'
        else:
            want = 'gpcipl'
        if want == geomName():
            return
        print("DEU geometry -> %s (%d/%d position words outside GPCIPL's "
              "+/-512 window)" % (want, _gridTally['bad'], _gridTally['seen']))
        setGeom(want)
        _gridTally = {'seen': 0, 'bad': 0}
        self._drawPasses()
        self.d.dirty = True

    def _drawPasses(self):
        self._frameRows = {}          # row -> {column: character}, for announceScreen
        # The trace holds ONE frame -- the most recent.
        if env('NSTS_CELL_TRACE'):
            try:
                open(env('NSTS_CELL_TRACE'), 'w').close()
            except Exception:
                pass
            _cellTraceLeft[0] = CELL_TRACE_PER_FRAME
        # TWO passes.  A DFG-generated display is not one list: its background
        # is resident -- downloaded once during the unit's IPL, into the
        # critical-format buffer at 0x0100 -- and at call-up the GPC writes
        # only a pointer to it, at the top of memory.  The per-cycle list at
        # DISPLAY_HEADER never mentions it.
        d = self.fcw.decodeFCW(int(self.bgFCWS[DEU.ADDR.BACKGROUND_TOP]))
        if d is not None and d['nm'] == 'BRANCH':
            self.geo_dps_bg = self.drawFCWS(
                self.bgFCWS, self.geo_dps_bg,
                {'memory': self.bgFCWS, 'start': DEU.ADDR.BACKGROUND_TOP,
                 'stopAt': DEU.CF_PAD, 'rowScale': ADJ['rowGap']})
        else:
            # NO POINTER, NO BACKGROUND.  A display unit draws what its memory
            # says on every refresh, so a background whose branch has gone is
            # gone with it.  Skipping the pass instead left the last one drawn
            # -- PASS's GPC MEMORY page stayed on screen under GPCIPL's menu
            # after a re-IPL, the two lists superimposed.
            self.geo_dps_bg = self.drawFCWS([], self.geo_dps_bg)
        self.geo_dps_fcws = self.drawFCWS(
            self.bgFCWS, self.geo_dps_fcws,
            {'memory': self.bgFCWS, 'start': DEU.ADDR.DISPLAY_HEADER,
             'rowScale': ADJ['rowGap']})
        self._announceTopLines()

    def _announceTopLines(self):
        """The top two text lines to crew scripts (see announceScreen)."""
        rows, self._frameRows = self._frameRows, None
        name = getattr(self, 'mduName', None)
        if not name or rows is None:
            return
        # NSTS_ANNOUNCE_ROWS=all sends the WHOLE frame, not just the top two.
        # A crew script only ever needs the title, but a question about what
        # the flight software itself believes -- which GPC commands which bus,
        # on SPEC 6 -- is answered in the BODY of a display, and reading it
        # off a photograph is not evidence anybody can re-check.
        howMany = None if os.environ.get('NSTS_ANNOUNCE_ROWS') == 'all' else 2
        lines = []
        for r in sorted(rows)[:howMany]:
            cols = rows[r]
            lines.append("".join(cols.get(c, ' ')
                                 for c in range(min(0, min(cols)), max(cols) + 1)).rstrip())
        while len(lines) < 2:
            lines.append("")
        if howMany is None:
            announceScreen(name, lines)      # every frame, unfiltered
            return
        key = SCREEN_CLOCK.sub('#', " ".join(" ".join(lines).split()))
        now = time.monotonic()
        if key != getattr(self, '_scrKey', None):
            if key == getattr(self, '_scrCand', None):
                self._scrCandN += 1
            else:
                self._scrCand, self._scrCandN = key, 1
            if self._scrCandN < 2:
                return
            self._scrKey = key
        elif now - getattr(self, '_scrSent', 0.0) < SCREEN_REANNOUNCE_S:
            return
        self._scrSent = now
        announceScreen(name, lines)

    def setBGDFB(self, words):
        """Load a bare format control word stream at the refresh entry point --
        the debug path for a captured display, and what dev mode uses."""
        self.bgFCWS.fill(0)
        self.applyFill(DEU.ADDR.DISPLAY_HEADER, words)

    # -----------------------------------------------------------------------
    # The DEU beam interpreter
    # -----------------------------------------------------------------------
    def drawFCWS(self, fcws, targetGroup, opts=None):
        opts = opts or {}
        self.group.remove(targetGroup)
        dispose3D(targetGroup)
        targetGroup = Object3D()

        # Beam and mode registers.  LIVE geometry, not the load-time
        # constants: these are the origin and wrap the whole walk is built on.
        _g = geom()
        st = {'beamX': _g['col0'], 'beamY': _g['row0'],
              'tx': 0, 'ty': 0, 'xyRef': False,
              'homeX': _g['col0'], 'homeY': _g['row0'],
              'majorStep': COL_PITCH, 'minorStep': -ROW_PITCH,
              'axisY': False, 'blink': False, 'dash': False,
              'fcw1Bright': False, 'fcw3Bright': False,
              'large': False, 'angle': 0.0, 'angleStep': 0.0,
              'incrOn': False, 'vecRotate': False, 'altchar': False,
              'colorCode': None, 'slope': None, 'lsiteHi': None,
              'repeatCount': 0}
        sector = opts.get('sector', 1)                # branch page
        cellTraceFile = env('NSTS_CELL_TRACE')
        passLabel = 'BG' if opts.get('start') == DEU.ADDR.BACKGROUND_TOP else 'FG'

        # A glyph is drawn at the beam, in the character-cell coordinates the
        # rest of the display is laid out in.  The +1 on each axis is the DPS
        # format area's own origin.  The reference registers are NOT added
        # here -- the position words below fold them in.
        def penX():
            return cellCol(st['beamX']) + 1 + ADJ['textX']

        # `rowScale` spreads the ROWS, not the glyphs.  It multiplies where a
        # row is placed and touches nothing about the character.
        rowScale = opts.get('rowScale', 1)

        def penY():
            return cellRow(st['beamY']) * rowScale + 1 + ADJ['textY']

        blinkGroup = Object3D()
        blinkGroup.userData['deuBlink'] = True
        blinkGroup.visible = self._blinkOn if self._blinkOn is not None else True
        targetGroup.add(blinkGroup)

        def add(o):
            (blinkGroup if st['blink'] else targetGroup).add(o)

        traceOn = env('NSTS_FCW_TRACE')

        def trace(kind, extra=''):
            if not traceOn:
                return
            print("FCW %s  beam %d,%d tr %s,%s  cell %.2f,%.2f  %s"
                  % (kind, jsround(st['beamX']), jsround(st['beamY']),
                     st['tx'], st['ty'], penX(), penY(), extra))

        def penColor():
            if st['colorCode'] is not None:
                return self._deuColor(st['colorCode'])
            return self.d.c2h['green']

        def penIntensity():
            # Double intensity arrives as either FCW1 bit 3 or FCW3 bit 6.
            return 1.0 if (st['fcw1Bright'] or st['fcw3Bright']) else 0.72

        def rot(dx, dy):
            """Rotate a beam-space delta by the character angle.  `angle` runs
            opposite to the beam's Y, so a quarter turn advances up."""
            if not st['angle']:
                return [dx, dy]
            cs = math.cos(st['angle'])
            sn = math.sin(st['angle'])
            return [dx * cs + dy * sn, -dx * sn + dy * cs]

        def advance():
            if st['axisY']:
                dx, dy = rot(0, st['majorStep'])
            else:
                dx, dy = rot(st['majorStep'], 0)
            st['beamX'] += dx
            st['beamY'] += dy
            if st['angleStep']:
                st['angle'] += st['angleStep']     # letters strung on an arc

        def carriageReturn():
            if st['axisY']:
                st['beamY'] = st['homeY']
                st['beamX'] += st['minorStep']
            else:
                st['beamX'] = st['homeX']
                st['beamY'] += st['minorStep']

        def drawGlyph(g):
            if g == 0x0d:                          # carriage return
                carriageReturn()
            elif g == 0x08:                        # backspace: undo one advance
                if st['axisY']:
                    st['beamY'] -= st['majorStep']
                else:
                    st['beamX'] -= st['majorStep']
            elif g == 0x00:
                # The empty half of a single-glyph word draws nothing AND does
                # not advance.
                pass
            else:
                ch = self.fcw.DEUCharset.get(g)
                if ch is not None and ch != ' ':
                    # `data/deu_font.svg` holds no alternate glyphs, so an
                    # ALTCHAR symbol draws its `DEUCharset` counterpart.
                    if traceOn:
                        trace('GLYPH', "'%s'%s" % (ch, ' ALTCHAR' if st['altchar'] else ''))
                    frameRows = getattr(self, '_frameRows', None)
                    if frameRows is not None:
                        frameRows.setdefault(int(round(penY())), {})[int(round(penX()))] = ch
                    if cellTraceFile and _cellTraceLeft[0] > 0:
                        _cellTraceLeft[0] -= 1
                        try:
                            with open(cellTraceFile, 'a') as fh:
                                fh.write("%s %.2f %.2f %s%s\n"
                                         % (passLabel, penY(), penX(), ch,
                                            ' BLINK' if st['blink'] else ''))
                        except Exception:
                            pass
                    add(self.d.str(penX(), penY() + (GLYPH_DY.get(ch) or 0), ch,
                                   penColor(),
                                   (COL_PITCH_L / COL_PITCH) if st['large'] else 1.0,
                                   1.0, 1.0, self.d.deuFont, st['angle'], False))
                advance()

        def drawCircle(r):
            """Radius in beam units about the beam, which the circle does not
            move.  Beam units are square, so in character cells this is an
            ellipse."""
            if not (r > 0):
                return
            cx = penX() + ADJ['vecX']
            cy = penY() + ADJ['vecY']
            n = max(24, min(96, jsround(2 * r)))
            pts = [[cx + r * math.cos(2 * math.pi * i / n) / COL_PITCH,
                    cy - r * math.sin(2 * math.pi * i / n) / ROW_PITCH]
                   for i in range(0, n + 1)]
            if traceOn:
                trace('CIRCLE', "r %s at %.2f,%.2f" % (r, cx, cy))
            if st['dash']:
                add(self.d.dashedLine(pts, penColor()))
            else:
                add(self.d.line(pts, penColor(), penIntensity()))

        def drawVector(a, b):
            """A vector's two words carry the extent along the major axis and
            the minor/major ratio; reconstruct both deltas in beam units and
            draw from the beam to the far end, leaving the beam there."""
            major = -b['len'] if b['negative'] else b['len']
            minor = jsround((a['slope'] / 2) * b['len'] / 512)
            if a['yMajor']:
                dy = major
                dx = minor * (-1 if a['signDiffer'] else 1) * (-1 if dy < 0 else 1)
            else:
                dx = major
                dy = minor * (-1 if a['signDiffer'] else 1) * (-1 if dx < 0 else 1)
            if st['vecRotate']:
                dx, dy = rot(dx, dy)
            x0 = penX() + ADJ['vecX']
            y0 = penY() + ADJ['vecY']
            if traceOn:
                trace('VECTOR', "d %s,%s major=%s minor=%s yMajor=%s signDiffer=%s slope=%s"
                      % (dx, dy, major, minor, a['yMajor'], a['signDiffer'], a['slope']))
            st['beamX'] += dx
            st['beamY'] += dy
            seg = [[x0, y0], [penX() + ADJ['vecX'], penY() + ADJ['vecY']]]
            if st['dash']:
                add(self.d.dashedLine(seg, penColor()))
            else:
                add(self.d.line(seg, penColor(), penIntensity()))

        # The walk is by index, not by iteration, because a BRANCH moves the
        # program counter.
        src = opts.get('memory') if opts.get('memory') is not None else fcws
        pc = opts.get('start', 0)
        visited = {}
        splice = None                 # the SUBLIST frame: {left, ret}
        done = False
        steps = 0
        srclen = len(src)
        stopAt = opts.get('stopAt')
        while (not done) and 0 <= pc < srclen and steps < self.MAX_FCW_STEPS:
            steps += 1
            # A spliced run ends when its word count runs out -- it has no
            # terminator of its own -- so the return is checked before the
            # fetch.
            if splice is not None and splice['left'] <= 0:
                pc = splice['ret']
                splice = None
                continue
            word = int(src[pc])
            # CFSYSIN declares `PAD=111E`, and every static format body DFG
            # generates ends with that word.  It is the section's terminator,
            # not a branch.
            if stopAt is not None and word == stopAt:
                done = True
                continue
            pc += 1
            if splice is not None:
                splice['left'] -= 1
            desc = self.fcw.decodeFCW(word)
            if desc is None:
                continue
            v = desc['v']
            nm = desc['nm']
            if nm == 'NOOP':
                pass                        # position-run lead / buffer fill
            elif nm == 'REPT':
                st['repeatCount'] = v['count']
            elif nm == 'BRANCH':
                # twelve bits from the word, four from the sector register
                tgt = ((sector & 0xf) << 12) | (v.get('addr12', v['addr'] & 0xfff))
                if splice is not None:
                    pass                    # a branch inside a spliced run is
                                            # data, not a jump
                elif opts.get('memory') is not None and not visited.get(tgt):
                    visited[tgt] = True
                    pc = tgt
                else:
                    done = True             # nowhere to go: end of the section
            elif nm == 'SUBLIST':
                # `SUBLIST count` + `BRANCH addr`: draw `count` words from
                # `addr`, then carry on after the branch word.  One frame deep.
                # op 2 carries the sector for the branch that follows it.
                if v.get('sector') is not None:
                    sector = v['sector']
                nxt = self.fcw.decodeFCW(int(src[pc])) if pc < srclen else None
                if splice is not None:
                    if nxt is not None and nxt['nm'] == 'BRANCH':
                        pc += 1
                        splice['left'] -= 1   # the skipped word is still ours
                elif nxt is not None and nxt['nm'] == 'BRANCH' and v['count'] > 0:
                    splice = {'left': v['count'], 'ret': pc + 1}
                    pc = nxt['v']['addr']
            elif nm == 'FCW1':
                st['dash'] = v['dash'] == 1
                # Every attribute word is traced, not just the ones that
                # change: which word turned an attribute on is the whole
                # question when something flashes that should not.
                if cellTraceFile and _cellTraceLeft[0] > 0:
                    _cellTraceLeft[0] -= 1
                    try:
                        with open(cellTraceFile, 'a') as fh:
                            fh.write("%s FCW1 @%x %x blink=%s dash=%s typ=%s ocr=%s"
                                     " axisY=%s sp=%s int=%s blank=%s\n"
                                     % (passLabel, pc - 1, int(src[pc - 1]),
                                        v['blink'], v['dash'], v['typ'], v['ocr'],
                                        v['axisY'], v['sp'], v['intensity'],
                                        v['blank']))
                    except Exception:
                        pass
                st['blink'] = v['blink'] == 1
                st['fcw1Bright'] = v['intensity'] == 1
                st['axisY'] = v['axisY'] == 1
            elif nm == 'FCW2':
                # AC5+AC4 gate the X/Y reference registers: while they are
                # clear the registers are held but not applied.
                st['xyRef'] = v['xyRef'] == 3
                st['incrOn'] = v['incr'] == 1
                if not st['incrOn']:
                    st['angleStep'] = 0
                if v['eor'] == 1:
                    done = True             # end of refresh
                else:
                    gen = v['mode'] & 0x3
                    if gen == GEN['VECTOR']:
                        st['vecRotate'] = (v['mode'] & UPRIGHT) == 0
                    elif gen in (GEN['CHAR_SMALL'], GEN['CHAR_LARGE']):
                        st['large'] = (v['mode'] & 0x3) == GEN['CHAR_LARGE']
                        st['altchar'] = v['polarX'] == 1   # where ALTCHAR lives
                        # the upright bit is cleared while a rotation is on
                        if (v['mode'] & UPRIGHT) != 0:
                            st['angle'] = 0
            elif nm == 'FCW3':
                st['colorCode'] = v['color'] if v['select'] == 1 else None
                st['fcw3Bright'] = v['intensity'] == 1
            elif nm == 'ROT':
                st['angle'] = -2 * math.pi * v['angle'] / 4096
            elif nm == 'MAJINC':
                if st['incrOn']:
                    # 12 unsigned bits of 360/32768 degrees, not MAJINC's
                    # signed 11, so the field is read from the word.
                    st['angleStep'] = -2 * math.pi * (desc['word'] & 0x0fff) / 32768
                else:
                    st['majorStep'] = v['step']
            elif nm in ('MININC', 'SPTYPE'):
                st['minorStep'] = v['step']
            elif nm == 'XPOS':
                # An X position word starts a new block: it re-homes the beam
                # vertically as well as setting the column.
                if v['translate'] == 1:
                    st['tx'] = v['x']
                else:
                    _gridTally['seen'] += 1
                    if not inAUGrid(v['x'], 'x'):
                        _gridTally['bad'] += 1
                    st['beamX'] = (v['x'] + (st['tx'] if st['xyRef'] else 0)) % _g['grid']
                    st['homeX'] = st['beamX']
                    st['beamY'] = st['homeY']
            elif nm == 'YPOS':
                if v['translate'] == 1:
                    st['ty'] = v['y']
                else:
                    _gridTally['seen'] += 1
                    if not inAUGrid(v['y'], 'y'):
                        _gridTally['bad'] += 1
                    st['beamY'] = (v['y'] + (st['ty'] if st['xyRef'] else 0)) % _g['grid']
                    st['homeY'] = st['beamY']
            elif nm == 'CIRCLE':
                drawCircle(v['radius'])
            elif nm == 'LSITE1':
                st['lsiteHi'] = word          # drawn when the pair completes
            elif nm == 'LSITE2':
                if st['lsiteHi'] is not None:
                    for c in self.fcw.lsiteText(st['lsiteHi'], word):
                        drawGlyph(self.fcw.toGlyph(c))
                    st['lsiteHi'] = None
            elif nm == 'VECA':
                st['slope'] = v
            elif nm == 'VECB':
                if st['slope'] is not None:
                    drawVector(st['slope'], v)
                st['slope'] = None
            elif nm == 'CHAR2':
                n = st['repeatCount'] if st['repeatCount'] > 0 else 1
                st['repeatCount'] = 0
                for _ in range(n):
                    drawGlyph(v['g1'])
                    drawGlyph(v['g2'])
            # VDISP latches state this renderer does not draw.

        self.group.add(targetGroup)
        self.d.dirty = True
        return targetGroup

    def blinkTick(self):
        self._blinkBeats = (self._blinkBeats or 0) + 1
        if self._blinkBeats < (self.BLINK_ON_BEATS if self._blinkOn else self.BLINK_OFF_BEATS):
            return
        self._blinkBeats = 0
        self._blinkOn = not self._blinkOn
        showing = [0]

        def visit(o):
            if not o.userData.get('deuBlink'):
                return
            o.visible = self._blinkOn
            if len(o.children) > 0:
                showing[0] += 1
        self.group.traverse(visit)
        # Only ask for a frame when something is actually blinking.
        if showing[0] > 0:
            self.d.dirty = True

    def _deuColor(self, code):
        """The FCW3 palette index -> an RGB colour.  Every COLOR= value the
        display decks use reads consistently as three 2-bit channels."""
        lvl = [0x00, 0x60, 0xb0, 0xff]
        r = lvl[(code >> 4) & 3]
        g = lvl[(code >> 2) & 3]
        b = lvl[code & 3]
        return (r << 16) | (g << 8) | b

    def draw(self):
        pass

    def build(self):
        if self.curData is None:
            self.setData()
        self.group = Object3D()
        # The whole DPS page sat one text row too high -- the top of the
        # header clock clipped, a row of slack at the bottom.  One cell is one
        # world unit, so this nudges everything the screen draws by one row.
        self.group.position.y = -0.75 + ADJ['pageY']

        self.geo_gpcNo = self.d.str(24.48, 28.735, "%s" % self.data()['gpcNo'],
                                    self.d.c2h['green'], 1.75)
        # The whole GPC-number assembly -- box, digit and the two kybd-active
        # bars -- moves up one text row with the rest of the page.  Built
        # always, drawn only with SHOW_IDP_BOX.
        self.geo_gpcBox = self.d.box(24.33, 28.335, 28.13, 30.985)
        if SHOW_IDP_BOX:
            self.group.add(self.geo_gpcNo)
            self.group.add(self.geo_gpcBox)

        # kybd-active bar: 2px-tall filled quad, 1/4 up from the GPC box
        # bottom, ending just clear of the box sides
        kbY = 30.32
        self.geo_kybd_right = self.d.box(28.18, kbY - 0.053, 41.13, kbY + 0.053,
                                         None, self.d.c2h['yellow'])
        self.geo_kybd_left = self.d.box(11.73, kbY - 0.053, 24.28, kbY + 0.053,
                                        None, self.d.c2h['red'])
        self.setKybd(self.data()['kybd'])

        self.geo_dps_time = Object3D()
        self._clockDrawn = None
        self.group.add(self.geo_dps_time)

        self.geo_scratchpad = Object3D()
        self.group.add(self.geo_scratchpad)

        self.geo_pollFail = Object3D()
        self.group.add(self.geo_pollFail)

        # fresh group: stale refs from a previous build must not be removed
        self.geo_dps_scratch_err = None
        self.setPollFail(self.data()['pollFail'])
        self.setSyntaxError(self.data()['syntaxError'])

        self.geo_dps_fcws = Object3D()
        self.group.add(self.geo_dps_fcws)
        self.geo_dps_bg = Object3D()      # the resident background
        self.group.add(self.geo_dps_bg)

        if self._blinkOn is None:
            self._blinkOn = True

        # dev mode: preload the DEU self-test critical format locally.
        # Otherwise the display stays blank until an IDP delivers a background.
        if self.d.CONFIG.get('dev'):
            self.dispCritFormat(0)

    # -- the header clock ---------------------------------------------------
    def _clockText(self, secs):
        secs = max(0, int(math.floor(secs)))
        return "%s/%s:%s:%s" % (str(secs // 86400).rjust(3, '0'),
                                str((secs // 3600) % 24).rjust(2, '0'),
                                str((secs // 60) % 60).rjust(2, '0'),
                                str(secs % 60).rjust(2, '0'))

    def setClock(self, missionSecs, eventSecs, conv=1):
        # The GPC sends a time fill with every poll -- twice a second from
        # GPCIPL -- so every other one carries the same whole second as the
        # last.  Redrawing those re-paints the header's digits with nothing
        # changed, twice a second, and to the eye a clock that ticks twice
        # a second is a clock running fast.  Draw only when the text moves.
        self._clock = {'mission': missionSecs, 'event': eventSecs, 'conv': conv}
        text = (self._clockText(missionSecs), self._clockText(eventSecs))
        if self.geo_dps_time is not None and getattr(self, '_clockDrawn', None) == text:
            return False
        # A time fill can arrive before this screen has ever been built.
        if self.fcw is None or self.geo_dps_time is None:
            return
        # rows 1 and 2, not 0 and 1.  The mission clock belongs on the same
        # text row as the display title.
        fcws = (self.makeDFB(self._clockText(missionSecs), {'xy': [39, 1]})
                + self.makeDFB(self._clockText(eventSecs), {'xy': [39, 2]}))
        self.geo_dps_time = self.drawFCWS(fcws, self.geo_dps_time)
        # What the header now shows.  Cleared wherever geo_dps_time is made
        # afresh, so a rebuilt screen always gets its clock drawn.
        self._clockDrawn = text
        return True

    def makeDFB(self, s, opt=None):
        """Text at a character cell -> the FCWs that draw it."""
        opt = opt or {}
        dfb = self.fcw.positionRun(opt['xy'][0], opt['xy'][1]) if opt.get('xy') else []
        return dfb + self.fcw.chars(s)

    # -- SPL: the scratch pad line -----------------------------------------
    def updateScratchpad(self):
        if self.spl is None:
            self.spl = SPL({'pollFail': self.data()['pollFail']})
        fcws = self.fcw.positionRun(0, 27)
        # The command initiator flashes until the command is complete.  ERR
        # flashes.  The blink attribute is a mode register, not a property of
        # the text, so it has to be turned off again after each run.
        span = self.spl.initSpan
        if span is not None and not self.spl.complete:
            fcws = fcws + self.makeDFB(self.spl.line[0:span[0]])
            fcws.append(self.fcw.attrMode({'blink': True}))
            fcws = fcws + self.makeDFB(self.spl.line[span[0]:span[1]])
            fcws.append(self.fcw.attrMode({}))
            fcws = fcws + self.makeDFB(self.spl.line[span[1]:])
        else:
            fcws = fcws + self.makeDFB(self.spl.line)
        if self.spl.err:
            fcws.append(self.fcw.attrMode({'blink': True}))
            fcws = fcws + self.makeDFB(ERR_TEXT)
            fcws.append(self.fcw.attrMode({}))
        self.geo_scratchpad = self.drawFCWS(fcws, self.geo_scratchpad)
        self.d.dirty = True

    def recvKey(self, k):
        if self.spl is None:
            self.spl = SPL({'pollFail': self.data()['pollFail']})
        self.spl.press(k['gpcCode'])
        self.updateScratchpad()

    def init(self):
        self.fcw = FCW()
        self.bgFCWS = np.zeros(DEU.DEU_MEMORY_WORDS, dtype=np.uint16)
        self.loadCritFormats()
        self.spl = SPL({'pollFail': self.data()['pollFail']})
        self.syntaxError = False

    def loadCritFormats(self):
        self.critFormats = {}
        pth = os.path.join(self.d.CONFIG['NSTS_TOP'], 'data')
        self.critFormats[0] = self.loadBGDFBFile(
            os.path.join(pth, '0000-DEU_STAND_ALONE_SELF_TEST.dfb'))

    def dispCritFormat(self, fmtNum):
        self.setBGDFB(self.critFormats[0])

    def loadBGDFBFile(self, path):
        with open(path, 'rb') as f:
            return wordsFromBytes(f.read())

    def _dfbList(self):
        pth = os.path.join(self.d.CONFIG['NSTS_TOP'], 'data')
        if self._dfbFiles is None:
            self._dfbFiles = sorted(f for f in os.listdir(pth)
                                    if re.search(r'\.dfb$', f, re.I))
            self._dfbIndex = -1        # nothing selected yet
        return self._dfbFiles

    def setBGDFBByName(self, fname):
        lst = self._dfbList()
        if fname not in lst:
            return
        self._dfbIndex = lst.index(fname)
        self.setBGDFB(self.loadBGDFBFile(
            os.path.join(self.d.CONFIG['NSTS_TOP'], 'data', fname)))
        print("DPS bg DFB: %s" % fname)

    def _adjust(self, k, v):
        ADJ[k] = v
        self.group.position.y = -0.75 + ADJ['pageY']
        m = self.d.scene.getObjectByName('MDUMenuArea')
        if m is not None:
            # x only: the menu area does not follow pageY (MDUMenuArea.build),
            # and the frustum now ends just under it (VectorDisplay.CAM_B).
            m.position.x = ADJ['menuX']
        self.d.resetCamera()
        self.refresh()
        self.d.dirty = True
        print("MEDS2 geometry: " + "  ".join("%s=%.2f" % (kk, float(vv))
                                             for kk, vv in ADJ.items()))

    def testControls(self):
        def mk(label, key, rng):
            return {'label': label, 'range': rng,
                    'get': (lambda k=key: ADJ[k]),
                    'set': (lambda v, k=key: self._adjust(k, v))}
        return [
            {'header': 'geometry (live)'},
            mk('row gap', 'rowGap', [0.80, 1.40, 0.01]),
            mk('text dY', 'textY', [-4.0, 3.0, 0.05]),
            mk('text dX', 'textX', [-2.0, 2.0, 0.02]),
            mk('vector dY', 'vecY', [-3.0, 3.0, 0.05]),
            mk('vector dX', 'vecX', [-2.0, 2.0, 0.02]),
            mk('page dY', 'pageY', [-4.0, 4.0, 0.05]),
            mk('menu dX', 'menuX', [-1.0, 2.0, 0.02]),
            mk('view dX', 'viewX', [-3.0, 3.0, 0.02]),
            mk('view dY', 'viewY', [-3.0, 3.0, 0.02]),
            {'label': 'DEU self test',
             'get': (lambda: bool(self.selfTestOn)),
             'set': (lambda v: self.enterSelfTest() if v else self.exitSelfTest())},
            {'label': 'BG DFB', 'options': [u'—'] + self._dfbList(),
             'get': (lambda: self._dfbFiles[self._dfbIndex]
                     if (self._dfbIndex is not None and self._dfbIndex >= 0)
                     else u'—'),
             'set': (lambda f: self.setBGDFBByName(f))},
            {'label': 'Kybd', 'options': ['left', 'right', 'both', 'none'],
             'get': (lambda: (self.curData or {}).get('kybd') or 'none'),
             'set': (lambda v: self.setKybd(None if v == 'none' else v))},
            {'label': 'POLL FAIL',
             'get': (lambda: bool((self.curData or {}).get('pollFail'))),
             'set': (lambda v: self.setPollFail(v))},
            {'label': 'Syntax err',
             'get': (lambda: bool((self.curData or {}).get('syntaxError'))),
             'set': (lambda v: self.setSyntaxError(v))},
        ]

    def cycleBGDFB(self, direction):
        """Debug: cycle the DPS background through every data/*.dfb."""
        self._dfbList()
        pth = os.path.join(self.d.CONFIG['NSTS_TOP'], 'data')
        if len(self._dfbFiles) == 0:
            return
        n = len(self._dfbFiles)
        self._dfbIndex = ((self._dfbIndex + direction) % n + n) % n
        fname = self._dfbFiles[self._dfbIndex]
        print("DPS bg DFB [%d/%d]: %s" % (self._dfbIndex + 1, n, fname))
        self.setBGDFB(self.loadBGDFBFile(os.path.join(pth, fname)))
        return fname

    # -----------------------------------------------------------------------
    # DEU stand-alone self-test animation (debug mode).
    #
    # Loads the static 0000 self-test format, overwrites its terminating
    # branch with animated elements, and rewrites their FCWs on a timer to
    # animate the elements the DEU updated live (boxed vectors, revolving
    # letters, the two travelling squares, and the spinning "bug").
    #
    # Written in DEU FCWs, so it is limited to what the DEU can express:
    # characters rotate in quarter turns only and come in two sizes only, and
    # intensity is one bit.
    # -----------------------------------------------------------------------
    def _stXY(self, idx, cx, cy):
        self.bgFCWS[idx] = self.fcw.xPosition(self.fcw.cellX(cx))
        self.bgFCWS[idx + 1] = self.fcw.yPosition(self.fcw.cellY(cy))

    def _stChar(self, idx, cx, cy, ch):
        self._stXY(idx, cx, cy)
        self.bgFCWS[idx + 2] = self.fcw.glyphSingle(self.fcw.toGlyph(ch))

    def _stCharRot(self, idx, cx, cy, ch, rot):
        self.bgFCWS[idx] = self.fcw.rotation(rot * 180 / math.pi)   # rot in rad
        self._stChar(idx + 1, cx, cy, ch)

    def _stLine(self, idx, x0, y0, x1, y1):
        for i, w in enumerate(self.fcw.vector(x0, y0, x1, y1)):
            self.bgFCWS[idx + i] = w

    def _stBoxRay(self, idx, cx, cy, x0, y0, x1, y1, a):
        dc = math.cos(a)
        dr = math.sin(a) * 0.733
        t = 1e9
        if dc > 1e-6:
            t = min(t, (x1 - cx) / dc)
        if dc < -1e-6:
            t = min(t, (x0 - cx) / dc)
        if dr > 1e-6:
            t = min(t, (y1 - cy) / dr)
        if dr < -1e-6:
            t = min(t, (y0 - cy) / dr)
        self._stLine(idx, cx, cy, cx + dc * t, cy + dr * t)

    def enterSelfTest(self):
        if self.selfTestOn:
            return
        pth = os.path.join(self.d.CONFIG['NSTS_TOP'], 'data')
        self.setBGDFB(self.loadBGDFBFile(
            os.path.join(pth, '0000-DEU_STAND_ALONE_SELF_TEST.dfb')))
        base = 0
        n = len(self.bgFCWS)
        while base < n:
            d = self.fcw.decodeFCW(int(self.bgFCWS[base]))
            if d is not None and d['nm'] == 'BRANCH':
                break
            base += 1
        if base >= n:
            base = 0
        o = base
        # leading attribute reset so animated elements draw normal/solid
        self.bgFCWS[o] = self.fcw.attrMode({})
        o += 1
        SV = self.ST_VECTOR_WORDS
        SC = self.ST_CHAR_WORDS
        SR = self.ST_CHARROT_WORDS
        self._stLayout = {}
        self._stLayout['boxVec'] = o; o += 4 * SV     # (2) windmill: 4 half-lines
        self._stLayout['letters'] = o; o += 5 * SR + 1  # (3) A,B,C,D,X + reset
        self._stLayout['sqH'] = o; o += SC            # (9A) travelling square
        self._stLayout['sqV'] = o; o += SC            # (9B) travelling square
        self._stLayout['bug'] = o; o += 16 * SV       # (10) 16 vectors
        # (8) 5 short + attributes + 5 long + attributes + connector
        self._stLayout['eight'] = o; o += 11 * SV + 2
        self.selfTestOn = True
        self._stT0 = time.time() * 1000.0
        self.tickSelfTest()
        self._stTimer = QTimer()
        self._stTimer.timeout.connect(self.tickSelfTest)
        self._stTimer.start(50)
        print("DEU self-test animation ON")

    def exitSelfTest(self):
        if not self.selfTestOn:
            return
        if self._stTimer is not None:
            self._stTimer.stop()
        self._stTimer = None
        self.selfTestOn = False
        self.setBGDFB(self.critFormats[0])   # back to the static self-test
        print("DEU self-test animation OFF")

    def toggleSelfTest(self):
        if self.selfTestOn:
            self.exitSelfTest()
        else:
            self.enterSelfTest()

    def tickSelfTest(self):
        if not self.selfTestOn:
            return
        t = (time.time() * 1000.0 - self._stT0) / 1000.0
        L = self._stLayout
        SV = self.ST_VECTOR_WORDS
        SC = self.ST_CHAR_WORDS
        SR = self.ST_CHARROT_WORDS

        # (2) box windmill: two crossed lines through the box centre, clipped
        # to the box borders as they rotate (drawn as 4 half-lines).
        bx0 = 19; by0 = 5; bx1 = 24.274; by1 = 8.866
        bcx = (bx0 + bx1) / 2
        bcy = (by0 + by1) / 2
        spin2 = t * 0.9
        for i in range(4):
            self._stBoxRay(L['boxVec'] + i * SV, bcx, bcy, bx0, by0, bx1, by1,
                           spin2 + i * (math.pi / 2))

        # (3) AB & CD patterns + X revolving about the circle centre
        # (~33.84 deg/s clockwise, ~10.64 s).
        lcx = 9; lcy = 12; Rorb = 7.0; rpair = 0.7; ASP = 0.733
        wlet = t * (33.84 * math.pi / 180)
        pab = wlet                         # clockwise (screen)
        abx = lcx + Rorb * math.cos(pab)
        aby = lcy + Rorb * ASP * math.sin(pab)
        tabc = -math.sin(pab)
        tabr = ASP * math.cos(pab)         # tangent = clockwise travel dir
        self._stCharRot(L['letters'] + 0 * SR, abx - rpair * tabc, aby - rpair * tabr, 'A', 0)
        self._stCharRot(L['letters'] + 1 * SR, abx + rpair * tabc, aby + rpair * tabr, 'B', 0)
        pcd = wlet + math.pi
        cdx = lcx + Rorb * math.cos(pcd)
        cdy = lcy + Rorb * ASP * math.sin(pcd)
        tcdc = -math.sin(pcd)
        tcdr = ASP * math.cos(pcd)
        rcd = pcd + math.pi / 2            # base toward centre
        self._stCharRot(L['letters'] + 2 * SR, cdx - rpair * tcdc, cdy - rpair * tcdr, 'C', rcd)
        self._stCharRot(L['letters'] + 3 * SR, cdx + rpair * tcdc, cdy + rpair * tcdr, 'D', rcd)
        self._stCharRot(L['letters'] + 4 * SR, lcx, lcy, 'X', wlet)
        self.bgFCWS[L['letters'] + 5 * SR] = self.fcw.rotation(0)

        # Both squares start at the same point (col 50.27, row 16) at t=0.
        triA = 2 * abs((t / 18.62) % 1 - 0.5)          # 1 at t=0 (rightmost)
        self._stChar(L['sqH'], 26 + triA * (3.3975 * 7.143), 16.5, u'\xa5')
        triB = 1 - 2 * abs((t / (18.62 / 4)) % 1 - 0.5)  # 0 at t=0 (lowest)
        self._stChar(L['sqV'], 26 + 3.3975 * 7.143, 16.5 - triB * 6, u'\xa5')

        # (10) spinning 16-line "bug" (spec measurements).
        CPI = 7.143; RPI = 5.236           # cols/in, rows/in
        r0 = 0.2051; r1 = 0.4102           # 0.8204" dia, hole of 0.4102" dia
        scx = 26; scy = 13.5               # screen centre of the 51x26 grid
        diag = 35.54 * math.pi / 180
        amp = 0.9                          # inches of travel each way
        s = amp * (1 - 2 * abs(2 * ((t / 26.48) % 1) - 1))
        gx = scx + s * math.cos(diag) * CPI
        gy = scy - s * math.sin(diag) * RPI
        spinB = t * (53.17 * math.pi / 180)
        for i in range(16):
            a = spinB + i * (2 * math.pi / 16)
            ca = math.cos(a)
            sa = math.sin(a)
            self._stLine(L['bug'] + i * SV,
                         gx + r0 * ca * CPI, gy - r0 * sa * RPI,
                         gx + r1 * ca * CPI, gy - r1 * sa * RPI)

        # (8) ten varying-brightness lines, right-aligned, with a vertical
        # connector.  The DEU has ONE intensity bit, so the ramp is a switch
        # between normal and double intensity.
        LEN8 = [0.0068, 0.0137, 0.0273, 0.0547, 0.1094, 0.2188, 0.4375,
                0.8750, 1.7500, 3.5000]
        rightCol = 51; topRow = 19.5; sp8 = 0.45
        flashOn = (math.floor(t / 0.35) % 2) == 0
        bright = ((1 - math.cos(2 * math.pi * t / 2.33)) / 2) > 0.5   # ~2.33 s
        for k in range(5):
            y = topRow + k * sp8
            if flashOn:
                self._stLine(L['eight'] + k * SV, rightCol - LEN8[k] * CPI, y,
                             rightCol, y)
            else:
                self._stLine(L['eight'] + k * SV, rightCol, y, rightCol, y)
        o8 = L['eight'] + 5 * SV
        self.bgFCWS[o8] = self.fcw.attrMode({'intensity': bright})
        for k in range(5, 10):
            y = topRow + k * sp8
            self._stLine(o8 + 1 + (k - 5) * SV, rightCol - LEN8[k] * CPI, y,
                         rightCol, y)
        # back to normal intensity, then the vertical connector
        o8b = o8 + 1 + 5 * SV
        self.bgFCWS[o8b] = self.fcw.attrMode({})
        self._stLine(o8b + 1, rightCol, topRow, rightCol, topRow + 9 * sp8)

        self.refresh()


# ===========================================================================
# meds/mduScreen_AUTONOMOUS.coffee
# ===========================================================================
class Screen_AUTONOMOUS(MDUScreen):
    def __init__(self, d):
        self.priTimeout = None
        self.secTimeout = None
        self.geo_msg = None
        MDUScreen.__init__(self, d)

    def build(self):
        self.group = Object3D()
        self.group.add(self.d.str(18, 15, "MDU IS AUTONOMOUS", self.d.c2h['red']))
        self.geo_msg = None
        self._drawMsg()

    def setTimeouts(self, pri, sec):
        """Which port(s) timed out -- the MDU updates this while autonomous.
        Returns True when the displayed message changed."""
        if pri == self.priTimeout and sec == self.secTimeout:
            return False
        self.priTimeout = pri
        self.secTimeout = sec
        if self.group is not None:
            self._drawMsg()
        return True

    def _drawMsg(self):
        if self.geo_msg is not None:
            self.group.remove(self.geo_msg)
        if self.priTimeout and self.secTimeout:
            msg = "Pri/Sec Port Timeout"
        elif self.secTimeout:
            msg = "Sec Port Timeout"
        else:
            msg = "Pri Port Timeout"
        # centre under the AUTONOMOUS line ("Pri/Sec..." spans cols 15-35)
        x = jsround(15 + (20 - len(msg)) / 2)
        self.geo_msg = self.d.str(x, 17, msg, self.d.c2h['red'])
        self.group.add(self.geo_msg)


# ===========================================================================
# meds/mduScreen_FAULT_SUMM.coffee
# ===========================================================================
class Screen_FAULT_SUMM(MDUScreen):
    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {'faults': [
                {'msg': 'MEDS I/O ERROR ADC2B', 'time': '000/00:00:00'},
                {'msg': 'MEDS I/O ERROR ADC1B', 'time': '000/00:00:00'},
                {'msg': 'MEDS I/O ERROR PLT2', 'time': '000/00:00:00'},
                {'msg': 'MEDS I/O ERROR MFD2', 'time': '000/00:00:00'},
                {'msg': 'MEDS I/O ERROR MFD1', 'time': '000/00:00:00'},
                {'msg': 'MEDS I/O ERROR CDR1', 'time': '000/00:00:00'},
            ] + [{'msg': '', 'time': ''} for _ in range(10)]}

    def data(self):
        return self.curData

    def build(self):
        self.bg = Object3D()
        self.bg.add(self.d.line([[2, 4.5], [33, 4.5]], self.d.c2h['white']))
        self.bg.add(self.d.line([[37, 4.5], [49, 4.5]], self.d.c2h['white']))
        self.bg.add(self.d.strMEDS(14, 3, "FAULT", self.d.c2h['white'], 1.5, 1.0, .75))
        self.bg.add(self.d.strMEDS(41, 3, "TIME", self.d.c2h['white'], 1.5, 1.0, .75))
        self.errors = Object3D()
        self.errorTxt = []
        self.group = Object3D()
        self.group.add(self.bg)
        self.group.add(self.errors)

    def draw(self):
        if self.curData is None:
            self.setData()
        for x in self.errorTxt:
            self.errors.remove(x)
        self.errorTxt = []
        for i in range(15):
            msg = self.d.str(2, (i * 1.5) + 5, self.curData['faults'][i]['msg'],
                             self.d.c2h['white'])
            tme = self.d.str(37, (i * 1.5) + 5, self.curData['faults'][i]['time'],
                             self.d.c2h['white'])
            self.errors.add(msg)
            self.errors.add(tme)
            self.errorTxt.append(msg)
            self.errorTxt.append(tme)


# ===========================================================================
# meds/mduScreen_FILE_PATCH.coffee
# ===========================================================================
class Screen_FILE_PATCH(MDUScreen):
    def draw(self):
        labels = [
            [4, 1, "ITEM A START ADDRESS"],
            [4, 2, "ITEM B DESIRED PATCH"],
            [33, 1, "ITEM C WRITE"],
            [4, 4, "ADD ID    DESIRED  ACTUAL     ADD ID    DESIRED   ACTUAL"],
        ] + [[4, r, "XXXXXX    XXXX     XXXX       XXXXXX    XXXX      XXXX"]
             for r in range(6, 19)] + [
            [1, 22, "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0123456789"],
        ]
        self.d.add([self.d.line([[4, 3], [50, 3]], self.d.c2h['white'])])
        for label in labels:
            # ... and these do not reach the scene, exactly as before: `add`
            # is handed one object, not a list of them.
            self.d.add(self.d.strMEDS(label[0], label[1], label[2],
                                      self.d.c2h['white'], 1.2, 0.82, 0.85))


# ===========================================================================
# meds/mduScreen_HYD_APU.coffee
# ===========================================================================
class Screen_HYD_APU(MDUScreen):
    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {
                'apuFuelQty_1': -1, 'apuFuelQty_2': 0, 'apuFuelQty_3': 0,
                'apuH2OQty_1': 0, 'apuH2OQty_2': 0, 'apuH2OQty_3': 0,
                'apuFuelP_1': 0, 'apuFuelP_2': 18, 'apuFuelP_3': 18,
                'apuOilTmp_1': 74, 'apuOilTmp_2': 72, 'apuOilTmp_3': 70,
                'hydQty_1': 0, 'hydQty_2': 0, 'hydQty_3': 0,
                'hydPress_1': 2103, 'hydPress_2': -1, 'hydPress_3': 1050,
            }
        self.draw()

    def data(self):
        return self.curData

    def build(self):
        self.bg = Object3D()
        lines = [
            # APU Header
            [[4.25, 2.8], [4.25, 1.5], [24.43, 1.5]],
            [[28.43, 1.5], [48.5, 1.5], [48.5, 2.8]],
            # HYDRAULIC Header
            [[2.25, 21], [2.25, 19.75], [21.5, 19.75]],
            [[31.5, 19.75], [48.5, 19.75], [48.5, 21]],
        ]
        for line in lines:
            self.bg.add(self.d.line(line, self.d.c2h['green']))
        self.bg.add(self.d.strMEDS(25, 1.11, "APU", self.d.c2h['green'], 1.3, .9, .7))
        self.bg.add(self.d.strMEDS(22.47, 19.45, "HYDRAULIC", self.d.c2h['green'],
                                   1.3, .9, .75))
        labels = [
            [3.78, 6.91, "FUEL"], [4.03, 7.91, "QTY"], [5.1, 9.02, "%"],
            [4.15, 13.52, "H"], [6.4, 13.52, "O"], [5.47, 13.88, "2"],
            [4.22, 14.63, "QTY"], [5.15, 15.82, "%"],
            [27.43, 6.91, "FUEL"], [29, 7.96, "P"],
            [26.68, 13.52, "OIL"], [24.68, 14.67, "IN TEMP"], [26.43, 15.77, u"\xb0F"],
            [4.3, 25.1, "QTY", 0.9, 0.9], [5.3, 26.1, '%', 0.9, 0.9],
            [36.35, 27.39, 'L'], [41.36, 27.39, 'L'], [46.72, 27.34, 'L'],
            [27.05, 25.75, 'PRESS', 0.9, 0.9],
        ]
        for label in labels:
            l = self.d.str(label[0], label[1], label[2], self.d.c2h['white'],
                           (label[3] if len(label) > 3 else 1),
                           (label[4] if len(label) > 4 else 1))
            self.bg.add(l)

        defs = [
            {'src': "apuFuelQty_1", 'x': 7.9, 'y': 4, 'l': '1', 'd': 3, 'h': 4, 'bt': 0.16, 'md': 0.11, 'mf': False, 'r': [0, 100], 't': [20], 's': {0: 'red', 20: 'green'}},
            {'src': "apuFuelQty_2", 'x': 13.25, 'y': 4, 'l': '2', 'd': 3, 'h': 4, 'bt': 0.16, 'md': 0.11, 'mf': False, 'r': [0, 100], 't': [20], 's': {0: 'red', 20: 'green'}},
            {'src': "apuFuelQty_3", 'x': 18.6, 'y': 4, 'l': '3', 'd': 3, 'h': 4, 'bt': 0.16, 'md': 0.11, 'mf': False, 'r': [0, 100], 't': [20], 's': {0: 'red', 20: 'green'}},
            {'src': "apuH2OQty_1", 'x': 7.9, 'y': 11.16, 'l': '', 'd': 3, 'h': 4, 'bt': 0.16, 'md': 0.11, 'mf': False, 'r': [0, 100], 't': [40], 's': {0: 'red', 40: 'green'}},
            {'src': "apuH2OQty_2", 'x': 13.25, 'y': 11.16, 'l': '', 'd': 3, 'h': 4, 'bt': 0.16, 'md': 0.11, 'mf': False, 'r': [0, 100], 't': [40], 's': {0: 'red', 40: 'green'}},
            {'src': "apuH2OQty_3", 'x': 18.6, 'y': 11.16, 'l': '', 'd': 3, 'h': 4, 'bt': 0.16, 'md': 0.11, 'mf': False, 'r': [0, 100], 't': [40], 's': {0: 'red', 40: 'green'}},
            {'src': "apuFuelP_1", 'x': 31.4, 'y': 4, 'l': '1', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 500], 't': [], 's': {0: 'green'}},
            {'src': "apuFuelP_2", 'x': 36.75, 'y': 4, 'l': '2', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 500], 't': [], 's': {0: 'green'}},
            {'src': "apuFuelP_3", 'x': 42.1, 'y': 4, 'l': '3', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 500], 't': [], 's': {0: 'green'}},
            {'src': "apuOilTmp_1", 'x': 31.4, 'y': 11.16, 'l': '', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 500], 't': [45, 290], 's': {0: 'red', 45: 'green', 291: 'red'}},
            {'src': "apuOilTmp_2", 'x': 36.75, 'y': 11.16, 'l': '', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 500], 't': [45, 290], 's': {0: 'red', 45: 'green', 291: 'red'}},
            {'src': "apuOilTmp_3", 'x': 42.1, 'y': 11.16, 'l': '', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 500], 't': [45, 290], 's': {0: 'red', 45: 'green', 291: 'red'}},
            {'src': "hydQty_1", 'x': 7.9, 'y': 22.61, 'l': '1', 'd': 3, 'h': 3.79, 'lu': 0.16, 'md': 0.05, 'mf': False, 'r': [0, 100], 't': [40, 95], 's': {0: 'red', 40: 'green', 96: 'red'}},
            {'src': "hydQty_2", 'x': 13.25, 'y': 22.61, 'l': '2', 'd': 3, 'h': 3.79, 'lu': 0.16, 'md': 0.05, 'mf': False, 'r': [0, 100], 't': [40, 95], 's': {0: 'red', 40: 'green', 96: 'red'}},
            {'src': "hydQty_3", 'x': 18.6, 'y': 22.61, 'l': '3', 'd': 3, 'h': 3.79, 'lu': 0.16, 'md': 0.05, 'mf': False, 'r': [0, 100], 't': [40, 95], 's': {0: 'red', 40: 'green', 96: 'red'}},
            {'src': "hydPress_1", 'x': 31.4, 'y': 22.61, 'l': '1', 'd': 4, 'h': 3.79, 'lu': 0.16, 'md': 0.05, 'mf': False, 'r': [0, 4000], 't': [500, 1000, 2400], 's': {0: 'red', 501: 'green', 1001: 'red'}},
            {'src': "hydPress_2", 'x': 36.75, 'y': 22.61, 'l': '2', 'd': 4, 'h': 3.79, 'lu': 0.16, 'md': 0.05, 'mf': False, 'r': [0, 4000], 't': [500, 1000, 2400], 's': {0: 'red', 501: 'green', 1001: 'red'}},
            {'src': "hydPress_3", 'x': 42.1, 'y': 22.61, 'l': '3', 'd': 4, 'h': 3.79, 'lu': 0.16, 'md': 0.05, 'mf': False, 'r': [0, 4000], 't': [500, 1000, 2400], 's': {0: 'red', 501: 'green', 1001: 'red'}},
        ]
        self.instr = Object3D()
        self.gauges = []
        for dd in defs:
            g = VertGauge(dd['x'], dd['y'], {
                'src': dd['src'], 'label': dd['l'], 'digits': dd['d'],
                'height': dd['h'], 'medsFont': dd['mf'], 'range': dd['r'],
                'ticks': dd['t'], 'status': dd['s'], 'up': dd.get('up'),
                'labelUp': dd.get('lu'), 'boxTop': dd.get('bt'),
                'meterDn': dd.get('md')}, self)
            self.gauges.append(g)
            self.instr.add(g.build(self.d))
        self.group = Object3D()
        self.group.add(self.bg)
        self.group.add(self.instr)

    def draw(self):
        if self.curData is None:
            self.setData()
        for instr in self.gauges:
            instr.draw(self.d)


# ===========================================================================
# meds/mduScreen_OMS_MPS.coffee
# ===========================================================================
class Screen_OMS_MPS(MDUScreen):
    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {
                'omsHeTKP_L': 2500, 'omsHeTKP_R': 0,
                'omsN2TKP_L': 0, 'omsN2TKP_R': -1,
                'omsPcL': 105, 'omsPcR': -1,
                'mpsPneuTK_P': 0, 'mpsREG_P': 0,
                'mpsEngManf_LO2': 2, 'mpsEngManf_LH2': 27,
                'mpsHeTKP_L': 100, 'mpsHeTKP_C': 0, 'mpsHeTKP_R': 140,
                'mpsHeREGAP_L': 20, 'mpsHeREGAP_C': 44, 'mpsHeREGAP_R': 40,
                'mpsPc_L': 67, 'mpsPc_C': 67, 'mpsPc_R': 67,
            }
        self.draw()

    def data(self):
        return self.curData

    def build(self):
        self.bg = Object3D()
        lines = [
            [[3, 3.25], [3, 1], [6, 1]],
            [[12, 1], [31, 1]],
            [[35, 1], [50, 1], [50, 3.25]],
            [[17, 1], [17, 28.5]],
        ]
        for line in lines:
            self.bg.add(self.d.line(line, self.d.c2h['green']))
        self.bg.add(self.d.strMEDS(7.9, .36, "OMS", self.d.c2h['green'], 1.5, 1.0, .75))
        self.bg.add(self.d.strMEDS(31.57, .36, "MPS", self.d.c2h['green'], 1.5, 1.0, .75))
        labels = [
            [3.5, 5, "He"], [3.5, 6.25, "TK"], [4, 7.5, "P"],
            [3.5, 13.75, "N"], [4.5, 13.90, "2"], [3.5, 14.75, "TK"], [4, 16, "P"],
            [3.75, 24.25, "Pc"], [4.25, 25.75, "%"],
            [18, 6.75, "TANK"], [19.5, 8, "P"],
            [30, 5, "He"], [29, 6.25, "TANK"], [30.25, 7.5, "P"],
            [19, 13.75, "REG"], [20, 15, "P"],
            [29, 13.5, "He"], [28, 14.75, "REG A"], [30, 16, "P"],
            [19, 19, "ENG MANF"], [22.5, 22.9, "P"], [22.5, 24, "S"],
            [22.5, 25.1, "I"], [22.5, 26.2, "A"],
            [35.75, 24.46, "Pc"], [36.5, 25.46, "%"],
            [41.5, 24.46, "Pc"], [42, 25.46, "%"],
            [18.75, 20.25, "LO2"], [24.2, 20.25, "LH2"],
        ]
        for label in labels:
            self.bg.add(self.d.str(label[0], label[1], label[2], self.d.c2h['white']))

        defs = [
            # L(R) OMS He TK PRESS meter / psia / 0-5000 / red:0-1499, green:1500+
            {'src': 'omsHeTKP_L', 'x': 6.2, 'y': 3.5, 'l': 'L', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [0, 5000], 't': [1500], 's': {0: 'red', 1500: 'green'}},
            {'src': 'omsHeTKP_R', 'x': 11.6, 'y': 3.5, 'l': 'R', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [0, 5000], 't': [1500], 's': {0: 'red', 1500: 'green'}},
            # L(R) OMS N2 TK PRESS meter / psia / 0-3000 / red:0-1199 green:1200+
            {'src': 'omsN2TKP_L', 'x': 6.2, 'y': 11.5, 'l': '', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 3000], 't': [1200], 's': {0: 'red', 1200: 'green'}},
            {'src': 'omsN2TKP_R', 'x': 11.6, 'y': 11.5, 'l': '', 'd': 4, 'h': 4, 'mf': False, 'r': [0, 3000], 't': [1200], 's': {0: 'red', 1200: 'green'}},
            # L(R) OMS Pc meter / % / 0-120 / black:0-3 red:4-79 white:80+
            {'src': 'omsPcL', 'x': 6.2, 'y': 20.41, 'l': 'L', 'd': 3, 'h': 6.5, 'mf': True, 'r': [0, 120], 't': [80], 's': {0: 'black', 4: 'red', 80: 'white'}},
            {'src': 'omsPcR', 'x': 11.75, 'y': 20.41, 'l': 'R', 'd': 3, 'h': 6.5, 'mf': True, 'r': [0, 120], 't': [80], 's': {0: 'black', 4: 'red', 80: 'white'}},
            # PNEU He TK PRESS meter / psia
            {'src': 'mpsREG_P', 'x': 22.25, 'y': 3.5, 'l': 'PNEU', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [3000, 5000], 't': [3800], 's': {0: 'red', 3800: 'green'}},
            # L(C,R) ENG He TK PRESS meter / psia
            {'src': 'mpsHeTKP_L', 'x': 32.5, 'y': 3.5, 'l': 'L/2', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [1000, 5000], 't': [1150], 's': {0: 'red', 680: 'green', 811: 'red'}},
            {'src': 'mpsHeTKP_C', 'x': 38.25, 'y': 3.5, 'l': 'C/1', 'd': 4, 'h': 4, 'mf': False, 'r': [1000, 5000], 't': [1150], 's': {0: 'red', 680: 'green', 811: 'red'}, 'up': .50},
            {'src': 'mpsHeTKP_R', 'x': 44, 'y': 3.5, 'l': 'R/3', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [1000, 5000], 't': [1150], 's': {0: 'red', 680: 'green', 811: 'red'}},
            # PNEU He REG PRESS meter / psia
            {'src': 'mpsREG_P', 'x': 22.5, 'y': 11.66, 'l': '', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [600, 900], 't': [680, 810], 's': {0: 'red', 680: 'green', 811: 'red'}},
            # L(C,R) ENG He REG PRESS meter / psia
            {'src': 'mpsHeREGAP_L', 'x': 32.5, 'y': 11.66, 'l': '', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [600, 900], 't': [680, 810], 's': {0: 'red', 680: 'green', 811: 'red'}},
            {'src': 'mpsHeREGAP_C', 'x': 38.25, 'y': 11.66, 'l': '', 'd': 4, 'h': 4, 'mf': False, 'r': [600, 900], 't': [680, 810], 's': {0: 'red', 680: 'green', 811: 'red'}, 'up': .50},
            {'src': 'mpsHeREGAP_R', 'x': 44, 'y': 11.66, 'l': '', 'd': 4, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [600, 900], 't': [680, 810], 's': {0: 'red', 680: 'green', 811: 'red'}},
            # LO2 ENG MANF PRESS meter / psia
            {'src': 'mpsEngManf_LO2', 'x': 18.75, 'y': 21.96, 'l': '', 'd': 3, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [0, 300], 't': [249], 's': {0: 'red', 1200: 'green'}},
            # LH2 ENG MANF PRESS meter / psia
            {'src': 'mpsEngManf_LH2', 'x': 24.1, 'y': 21.96, 'l': '', 'd': 3, 'h': 4, 'bd': -0.11, 'mf': False, 'r': [0, 100], 't': [65], 's': {0: 'green', 66: 'red'}},
            # L(C,R) ENG Pc meter / %
            {'src': 'mpsPc_L', 'x': 32.4, 'y': 20.46, 'l': 'L/2', 'd': 3, 'h': 6.5, 'mf': True, 'r': [45, 109], 't': [67, 104], 's': {0: 'red', 66: 'white'}},
            {'src': 'mpsPc_C', 'x': 37.9, 'y': 20.46, 'l': 'C/1', 'd': 3, 'h': 6.5, 'mf': True, 'r': [45, 109], 't': [67, 104], 's': {0: 'red', 66: 'white'}, 'up': .75},
            {'src': 'mpsPc_R', 'x': 43.75, 'y': 20.46, 'l': 'R/3', 'd': 3, 'h': 6.5, 'mf': True, 'r': [45, 109], 't': [67, 104], 's': {0: 'red', 66: 'white'}},
        ]
        self.instr = Object3D()
        self.gauges = []
        for dd in defs:
            g = VertGauge(dd['x'], dd['y'], {
                'src': dd['src'], 'label': dd['l'], 'digits': dd['d'],
                'height': dd['h'], 'medsFont': dd['mf'], 'range': dd['r'],
                'ticks': dd['t'], 'status': dd['s'], 'up': dd.get('up'),
                'boxDy': dd.get('bd')}, self)
            self.gauges.append(g)
            self.instr.add(g.build(self.d))
        self.group = Object3D()
        self.group.add(self.bg)
        self.group.add(self.instr)

    def draw(self):
        if self.curData is None:
            self.setData()
        for instr in self.gauges:
            instr.draw(self.d)


# ===========================================================================
# meds/mduScreen_SPI.coffee
# ===========================================================================
class Screen_SPI(MDUScreen):
    ST_TICK = 100          # ms; refreshFeed() is a full rebuild, keep modest
    ST_SWEEPS = [
        # [field,             min, max, period s]
        ['elevonDeg_LL', -35, 20, 8],
        ['elevonDeg_LR', -35, 20, 9],
        ['elevonDeg_RL', -35, 20, 10],
        ['elevonDeg_RR', -35, 20, 11],
        ['bodyFlapPc', 0, 100, 12],
        ['rudderDeg', -30, 30, 7],
        ['aileronDeg', -5, 5, 6],
        ['speedbrakePc_ACT', 0, 100, 13],
        ['speedbrakePc_CMD', 0, 100, 15],
    ]

    def __init__(self, d):
        self._stTimer = None
        self._st0 = None
        MDUScreen.__init__(self, d)

    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {
                'elevonDeg_LL': -25, 'elevonDeg_LR': -30,
                'elevonDeg_RL': -20, 'elevonDeg_RR': -15,
                'bodyFlapPc': 20, 'rudderDeg': -10, 'aileronDeg': -1,
                'speedbrakePc_ACT': 30, 'speedbrakePc_CMD': 40,
            }
        self.draw()

    def data(self):
        return self.curData

    def build(self):
        self.setData(self.curData)   # preserve live edits across rebuilds
        self.bg = Object3D()
        C = self.d.c2h
        labels = [
            [3, 2.5, "ELEVONS"], [5, 3.5, "DEG"],
            [14.65, 2.5, "BODY FLAP"], [18.65, 3.5, "%"],
            [33.75, 2.90, "RUDDER-DEG"],
            [33.75, 10.9, "AILERON-DEG"],
            [32.32, 18.1, "SPEEDBRAKE  %"],
            [26.85, 4.60, "30"], [30.75, 4.60, "20"], [34.5, 4.60, "10"],
            [39, 4.60, "0", C['yellow']],
            [42, 4.60, "10"], [46, 4.60, "20"], [49.75, 4.60, "30"],
            [6.9, 8.27, "-30"], [6.9, 11.11, "-20"], [6.9, 14.21, "-10"],
            [8.3, 17.15, "0", C['yellow']],
            [6.9, 19.84, "+10"], [6.9, 22.67, "+20"],
            [23.10, 7.14, "0"], [23.10, 10.34, "20"], [23.10, 13.43, "40"],
            [23.10, 16.79, "60"], [23.10, 19.89, "80"], [23.10, 22.98, "100"],
            [26.9, 8.46, "L RUD", C['green']], [47.25, 8.46, "R RUD", C['green']],
            [26.9, 15.6, "L AIL", C['green']], [47.25, 15.6, "R AIL", C['green']],
            [27.5, 11.9, "5"], [38.95, 11.9, "0", C['yellow']], [50.25, 11.9, "5"],
            [27.57, 20.9, "0"], [31.57, 20.9, "20"], [36.07, 20.9, "40"],
            [40.57, 20.9, "60"], [45.07, 20.9, "80"], [49.32, 20.9, "100"],
            [36.17, 19.25, "ACTUAL", C['yellow']],
            [36.47, 26.46, "COMMAND", C['cyan']],
            [7.75, 4.25, "  TE UP", C['green']],
            [7.65, 25.64, "  TE DN", C['green']],
        ]
        for label in labels:
            m = label[3] if len(label) > 3 else C['white']
            self.bg.add(self.d.str(label[0], label[1], label[2], m, 0.96, 1.01, 1.111))

        lines = [
            [[0.5, 6], [0.5, 4.75], [8, 4.75]],
            [[16.5, 4.75], [24, 4.75], [24, 6]],
            [[0.55, 24.66], [0.5, 25.91], [8, 25.91]],
            [[16.5, 25.91], [24, 25.91], [24, 24.66]],
        ]
        for line in lines:
            self.bg.add(self.d.line(line, C['green']))

        grayBar = C['darkGray']
        self.bg.add(self.d.box(47.17, 19.1, 50.67, 20.15, C['white']))
        self.bg.add(self.d.box(47.17, 26.1, 50.67, 27.15, C['white']))

        dat = self.data()
        # Elevons Deg L
        ellVal = elrVal = None
        if dat.get('elevonDeg_LL') is not None:
            ellVal = (dat['elevonDeg_LL'] + 35) / (55 / 11)
        if dat.get('elevonDeg_LR') is not None:
            elrVal = (dat['elevonDeg_LR'] + 35) / (55 / 11)
        self.bg.add(self.drawVertGauge(ellVal, 7.6, 23.5, 3.75, 1.25, .75, 11))
        self.bg.add(self.d.box(4.05, 7.2, 5.45, 24.0, None, grayBar))
        self.bg.add(self.drawVertGauge(elrVal, 7.6, 23.5, 5.75, 1.25, .75, 11, False))

        # Elevons Deg R
        erlVal = errVal = None
        if dat.get('elevonDeg_RL') is not None:
            erlVal = (dat['elevonDeg_RL'] + 35) / (55 / 11)
        if dat.get('elevonDeg_RR') is not None:
            errVal = (dat['elevonDeg_RR'] + 35) / (55 / 11)
        self.bg.add(self.drawVertGauge(erlVal, 7.6, 23.5, 12, 1.25, .75, 11))
        self.bg.add(self.d.box(12.25, 7.2, 13.75, 24.0, None, grayBar))
        self.bg.add(self.drawVertGauge(errVal, 7.6, 23.5, 14, 1.25, .75, 11, False))

        # Body Flap %
        bfpVal = None
        if dat.get('bodyFlapPc') is not None:
            bfpVal = dat['bodyFlapPc'] / (100 / 10)
        self.bg.add(self.d.box(19.5, 7.2, 20.75, 24.0, None, grayBar))
        self.bg.add(self.drawVertGauge(bfpVal, 7.6, 23.5, 21.10, .75, 1.25, 10, False))
        self.bg.add(self.flpPointer(21.9, 12.85, C['yellow']))

        # Rudder-Deg
        rdVal = None
        if dat.get('rudderDeg') is not None:
            rdVal = (dat['rudderDeg'] + 30) / (60 / 12)
        self.bg.add(self.drawHorizGauge(rdVal, 28.30, 50.95, 6.5, .55, .9, 12))
        self.bg.add(self.d.box(27.45, 6.7, 51.75, 7.6, None, grayBar))

        # Aileron-Deg
        alVal = None
        if dat.get('aileronDeg') is not None:
            alVal = (dat['aileronDeg'] + 5) / (10 / 20)
        self.bg.add(self.drawHorizGauge(alVal, 28.30, 50.95, 13.75, .6, .85, 20))
        self.bg.add(self.d.box(27.45, 13.95, 51.75, 14.85, None, grayBar))

        # Speedbrake %
        spaVal = spcVal = None
        if dat.get('speedbrakePc_ACT') is not None:
            spaVal = dat['speedbrakePc_ACT'] / (100 / 10)
        if dat.get('speedbrakePc_CMD') is not None:
            spcVal = dat['speedbrakePc_CMD'] / (100 / 10)
        self.bg.add(self.drawHorizGauge(spaVal, 28.37, 51.02, 22.75, .55, .9, 10))
        self.bg.add(self.d.box(27.52, 22.95, 51.82, 23.8, None, grayBar))
        self.bg.add(self.drawHorizGauge(spcVal, 28.37, 51.02, 24.05, .55, .9, 10, False))

        self.bg.add(self.d.str(47.32, 19.15, ("00%s" % dat['speedbrakePc_ACT'])[-3:],
                               C['yellow'], 0.96, 1.01, 1.111))
        self.bg.add(self.d.str(47.32, 26.15, ("00%s" % dat['speedbrakePc_CMD'])[-3:],
                               C['cyan'], 0.96, 1.01, 1.111))

        self.group = Object3D()
        self.group.add(self.bg)

    def flpPointer(self, x, y, color):
        fill = MeshBasicMaterial({'color': color, 'side': DoubleSide})
        dl = BufferGeometry()
        dl.setAttribute('position', Float32BufferAttribute([
            x, y, 1,
            x + 1, y + 0.37, 1,
            x + 1.85, y + 0.37, 1,
            x + 1.85, y - 0.37, 1,
            x + 1, y - 0.37, 1], 3))
        dl.setIndex([0, 1, 4, 1, 2, 3, 3, 1, 4])
        fill.transparent = True
        fill.depthTest = False
        m = Mesh(dl, fill)
        m.renderOrder = 2      # above the SDF tick strokes (cores at 1)
        return m

    # live-feed indicator test: sweeps every surface through its full range as
    # a triangle wave; each channel gets its own period so the arrows move
    # visibly out of phase.  Statics are restored on exit.
    def enterSweepTest(self):
        if self._stTimer is not None:
            return
        self._st0 = dict(self.curData)
        self._stT0 = time.time() * 1000.0
        self._stTimer = QTimer()
        self._stTimer.timeout.connect(self.tickSweepTest)
        self._stTimer.start(self.ST_TICK)
        self.tickSweepTest()
        print("SPI sweep test ON")

    def exitSweepTest(self):
        if self._stTimer is None:
            return
        self._stTimer.stop()
        self._stTimer = None
        if self._st0 is not None:
            self.curData.update(self._st0)
        self._st0 = None
        self.refreshFeed()
        print("SPI sweep test OFF")

    def tickSweepTest(self):
        t = (time.time() * 1000.0 - self._stT0) / 1000.0
        for k, lo, hi, period in self.ST_SWEEPS:
            ph = (t % period) / period
            tri = 2 * ph if ph < 0.5 else 2 - 2 * ph        # 0..1..0
            self.curData[k] = jsround(lo + tri * (hi - lo))
        self.refreshFeed()

    def testControls(self):
        return [
            {'label': 'SPI sweep test',
             'get': (lambda: self._stTimer is not None),
             'set': (lambda v: self.enterSweepTest() if v else self.exitSweepTest())},
        ]


# ===========================================================================
# meds/mduScreen_MAINT.coffee
# ===========================================================================
class Screen_MAINT(MDUScreen):
    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {}
        self.draw()

    def data(self):
        return self.curData

    def build(self):
        self.bg = Object3D()
        self.buildMEDSMaint()
        self.group = Object3D()
        self.group.add(self.bg)
        return self.group

    def draw(self):
        if self.curData is None:
            self.setData()

    def buildMEDSMaint(self):
        self.geo_maint = []
        step = 147.25
        base = 53.625
        self.bg.add(self.buildMDUBox("CDR1", base + 0 * step, 187.6875))
        self.bg.add(self.buildMDUBox("CDR2", base + 1 * step, 187.6875))
        self.bg.add(self.buildMDUBox("CRT1", base + 2 * step, 40.0000))
        self.bg.add(self.buildMDUBox("MFD1", base + 2 * step, 285.0000))
        self.bg.add(self.buildMDUBox("CRT3", base + 3 * step, 187.6875))
        self.bg.add(self.buildMDUBox("CRT2", base + 4 * step, 40.0000))
        self.bg.add(self.buildMDUBox("MFD2", base + 4 * step, 285.0000))
        self.bg.add(self.buildMDUBox("PLT1", base + 5 * step, 187.6875))
        self.bg.add(self.buildMDUBox("PLT2", base + 6 * step, 187.6875))
        self.bg.add(self.buildMDUBox("CRT4", base + 5 * step, 700))
        self.bg.add(self.buildMDUBox("AFD1", base + 6 * step, 700))
        self.bg.add(self.buildIDPBox(1, base + .9 * step, 500))
        self.bg.add(self.buildIDPBox(2, base + 2.2 * step, 500))
        self.bg.add(self.buildIDPBox(3, base + 3.5 * step, 500))
        self.bg.add(self.buildIDPBox(4, base + 4.8 * step, 500))
        self.bg.add(self.buildADCBox("ADC1A", base + 0 * step, 700))
        self.bg.add(self.buildADCBox("ADC1B", base + 1 * step, 700))
        self.bg.add(self.buildADCBox("ADC2A", base + 2 * step, 700))
        self.bg.add(self.buildADCBox("ADC2B", base + 3 * step, 700))

    def buildMDUBox(self, mduName, x, y):
        mduData = MEDSConf['mdus'][mduName]
        priPortIDP = int(mduData['dataBus']['P'][-1:])
        secPortIDP = " "
        if mduData['dataBus'].get('S') is not None:
            secPortIDP = int(mduData['dataBus']['S'][-1:])
        return self.buildMaintBox(x, y, 7, 6, 6, [
            mduName, "%s %s" % (priPortIDP, secPortIDP), "    ", "AUTO",
            "    ", "    "], False, True)

    def buildIDPBox(self, idpNum, x, y):
        return self.buildMaintBox(x, y, 9, 4.55, 4, [
            "IDP%d" % idpNum, "    ", "      ", "1 2 3 4"], False, False, .833)

    def buildADCBox(self, adcId, x, y):
        return self.buildMaintBox(x, y, 7, 4, 3, [
            adcId, "    ", "      "], False, False, .8333)

    def buildMaintBox(self, xb, yb, width, height, lines, text, current=False,
                      isMDU=False, ls=1):
        boxGroup = Object3D()
        xb = self.vx(xb)
        yb = self.vy(yb)
        xw = width - 1
        yh = height
        lh = yh / (lines - 1) * ls
        fillBlue = MeshBasicMaterial({'color': self.d.c2h['blue'], 'side': DoubleSide})
        boxGroup.add(self.d.box(xb, yb, xb + xw, yb + yh, self.d.c2h['white']))
        if current:
            boxGroup.add(self.d.box(xb, yb, xb + xw, yb + yh, UNDEF, fillBlue))
        for l in range(lines):
            boxGroup.add(self.d.line([[xb, yb + l * lh * .8333],
                                      [xb + xw, yb + l * lh * .8333]],
                                     self.d.c2h['white']))
        if isMDU:
            boxGroup.add(self.d.line([[xb + xw / 2, yb + 1 * lh * .8333],
                                      [xb + xw / 2, yb + 2 * lh * .8333]],
                                     self.d.c2h['white']))
        for i, t in enumerate(text):
            boxGroup.add(self.d.strCtrReg(xb, yb + i * .8333 * lh + .05, t,
                                          self.d.c2h['white'], .8333, width))
        return boxGroup


# ===========================================================================
# meds/mduScreen_IDP_CST.coffee
#
# JSC-48025/p.230, PERFORM IDP SELF-TEST -- the interactive CST page.
# ===========================================================================
class Screen_IDP_CST(MDUScreen):
    def __init__(self, d):
        self.txt = None
        self.sequence = None
        MDUScreen.__init__(self, d)

    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {
                'majorFunc': 'GNC', 'idpLoad': '', 'activeKybd': '2',
                'keystroke': '', 'leftIdpSel': '1', 'rightIdpSel': '3',
                'kybdSelA': 'OFF', 'kybdSelB': 'ON',
            }
        self.draw()

    def data(self):
        return self.curData

    def build(self):
        self.group = Object3D()

    def draw(self):
        if self.curData is None:
            self.setData()
        if self.txt is not None:
            self.group.remove(self.txt)
            dispose3D(self.txt)
        self.txt = Object3D()
        c = self.curData
        W = self.d.c2h['white']
        self.txt.add(self.d.str(6, 28, "MAJOR FUNC:%s" % c['majorFunc'], W, .75, .75))
        self.txt.add(self.d.str(6, 29, "IDP LOAD  :%s" % c['idpLoad'], W, .75, .75))
        self.txt.add(self.d.str(10.5, 30, "ACTIVE KYBD:%s" % c['activeKybd'], W, .75, .75))
        self.txt.add(self.d.str(25, 30, "KEYSTROKE:%s" % c['keystroke'], W, .75, .75))
        self.txt.add(self.d.str(18, 28, "LEFT IDP SEL:%s" % c['leftIdpSel'], W, .75, .75))
        self.txt.add(self.d.str(18, 29, "RIGHT IDP SEL: %s" % c['rightIdpSel'], W, .75, .75))
        self.txt.add(self.d.str(32, 28, "KYBD SEL A:%s" % c['kybdSelA'], W, .75, .75))
        self.txt.add(self.d.str(32, 29, "KYBD SEL B:%s" % c['kybdSelB'], W, .75, .75))
        self.group.add(self.txt)

    def _handle_CST_test(self, state):
        def fillMat(color):
            return MeshBasicMaterial({'color': color, 'side': DoubleSide})
        colors = {'mdu_cst_blank': 'black', 'mdu_cst_red': 'red',
                  'mdu_cst_green': 'green', 'mdu_cst_blue': 'blue',
                  'mdu_cst_white': 'white', 'mdu_cst_test': 'black'}
        c = colors.get(state)
        if c is not None:
            self.d.add(self.d.box(0, 0, 53, 36.25, UNDEF, fillMat(self.d.c2h[c])))

    def seq_mdu_selftest(self, mdu=None):
        """JSC-48025/p.246, PERFORM MDU SELF-TEST: blank, red, green, blue,
        white and the graphics test pattern, ~10 sec each."""
        mdu = mdu if mdu is not None else self
        print('seq_mdu_selftest')
        steps = ["mdu_cst_blank", "mdu_cst_red", "mdu_cst_green", "mdu_cst_blue",
                 "mdu_cst_white", "mdu_cst_test", "Maint"]

        def enter(i):
            mdu.curDisplay = steps[i]
            if hasattr(mdu, 'draw'):
                mdu.draw()
            if i + 1 < len(steps):
                QTimer.singleShot(10000, lambda: enter(i + 1))
        self.sequence = enter
        enter(0)


# ===========================================================================
# meds/mduScreen_AE_PFD.coffee -- the Ascent/Entry Primary Flight Display
# ===========================================================================

def zpad(s):
    return ("000%s" % s)[-3:]


def spad(s):
    return ("    %s" % s)[-4:]


# inches of physical tape -> display units.  The tape geometry in the spec is
# given in inches of tape face; the MDU active display area is 6.7 in square
# and the screen coordinate grid is 52.2425 cols x 38.32 rows.
TAPE_IN_ROWS = 38.32 / 6.7      # rows per inch (vertical, along the tape)
TAPE_IN_COLS = 52.2425 / 6.7    # cols per inch (tick widths)
NM_FT = 6076.115                # feet per nautical mile

# AVVI altitude tape segments, straight from the spec: each row is
# [vLo, vHi, inches-of-tape, labelStep, tickStep, tickWidth-in, tickSide].
ALT_SEGS = [
    [-1000, 0, 6.36, 200, 100, 0.3, 'c'],
    [0, 200, 2.8, 50, 10, 0.2, 'c'],
    [200, 2000, 3.6, 200, 100, 0.3, 'c'],
    [2000, 30000, 14.0, 1000, 500, 0.3, 'c'],
    [30000, 100000, 17.5, 5000, 1000, 0.2, 'c'],
    [100000, 400000, 12.0, 50000, 10000, 0.2, 'l'],
    [400000, 165 * NM_FT, 24.12, 5 * NM_FT, NM_FT, 0.1, 'r'],
]
_ALT_POS = []           # each segment's tape position (inches above 0 ft)
_ALT_IPS = []
_p = -ALT_SEGS[0][2]
for _s in ALT_SEGS:
    _ALT_POS.append(_p)
    _ALT_IPS.append(_s[2] / (_s[1] - _s[0]))
    _p += _s[2]
ALT_MIN = ALT_SEGS[0][0]
ALT_LAST = ALT_SEGS[len(ALT_SEGS) - 1]
ALT_MAX = ALT_LAST[1]


def altMapRows(v):
    """altitude -> tape rows above the 0-ft datum (clamped at the tape ends)"""
    v = max(ALT_MIN, min(ALT_MAX, v))
    for i, s in enumerate(ALT_SEGS):
        if v <= s[1] + 1e-9:
            return (_ALT_POS[i] + (v - s[0]) * _ALT_IPS[i]) * TAPE_IN_ROWS
    return (_ALT_POS[-1] + ALT_LAST[2]) * TAPE_IN_ROWS


def altInvRows(r):
    """inverse (rows -> altitude): tests sweep here so the tape moves at a
    constant rows/s through every segment"""
    p = r / TAPE_IN_ROWS
    for i, s in enumerate(ALT_SEGS):
        if p <= _ALT_POS[i] + s[2] + 1e-9:
            return s[0] + (p - _ALT_POS[i]) / _ALT_IPS[i]
    return ALT_MAX


# Hdot tape legend scale (rows/fps) and type size, solved from reference
# imagery captured at hdot = -164.
HD_H = 15.57
PXY = 38.32 / 1024                            # one display pixel in row units
HD_F0 = 0.95 * (32 * ((HD_H / 2 + 0.8 * 0.85) / 88.8) - 1.7)
HD_S = (HD_H / 2 - 0.409 * HD_F0 - 2 * PXY) / 76   # rows per fps, |hdot|<=1000
HD_F = 0.95 * HD_F0                           # label type size
# above 1000 fps the spec compresses to 500-fps labels with 100-fps centre
# marks; the compressed scale keeps the mark rhythm: s/10
HD_SHI = HD_S / 10
HDOT_MAX = 3000

# ball geometry
BALL_R = 9.405
LINE_R = BALL_R * 1.012
WIN_R = 6.69       # ball window / roll gauge ring radius
ERR_R = 7.65       # attitude error scale radius
COL_W = 3.75       # fill strip width, deg yaw
# meds-font ink metrics (measured from meds_font.svg; see scrollTape)
PFD_GXC = 1.368
PFD_GYC = 0.330
# ball label type: size in degrees of arc per glyph-cell unit, advance in cell
# units, and an x narrowing that reproduces the meds font's screen aspect
LBL_DEG = 5.4
LBL_ADV = 0.78
LBL_SX = 0.66
# the near-pole '0' pair (yaw +/-45) sits in tabs whose arc width shrinks by
# cos(yaw), so it rides this much higher into the white for clearance
ZERO_LIFT = 3

# green pointer arrows: rim thickness (rows, ~2px) and overall scale
GA_RIM = 2 * 38.32 / 1024
GA_SCL = 1.25

AT_TICK = 50          # ms, the ADI test cadence
AT_RATE = 12          # deg/s sweep rate
AT_MODES = ['pitch sweep', 'yaw sweep (gimbal protect at 90)',
            'roll sweep', 'combined tumble', 'freeze']
GT_TICK = 100
GT_MODES = [['Accel sweep (MM 102)', 102], ['Nz sweep (MM 305)', 305],
            ['Nz + target (MM 602)', 602]]
TT_PERIOD = 300           # s, one full min->max->min loop
TT_TICK = 50              # ms
AT2_PERIOD = 300
ATP_TICK = 100
VT_TICK = 100
VT_SEGS = [[1, 30], [1, 15], [25, 55]]   # one-way legs [tape units, seconds]


def ballPt(p, w, r):
    cp = math.cos(deg2rad(p))
    sp = math.sin(deg2rad(p))
    cw = math.cos(deg2rad(w))
    sw = math.sin(deg2rad(w))
    return [r * sw, -r * cw * sp, r * cw * cp]


class Screen_AE_PFD(MDUScreen):
    # G-meter placement, shared by build/refreshFeed/the G-meter test
    ACC_ARGS = [7.6, 28.25, 2.55, -1, 4]

    # "A Max L/D diamond indicates the optimum alpha value for maximum lift
    # over drag flying techniques, and is displayed when M < 3.0."
    ALPHA_MAXLD = [[0.95, 10.5], [1.0, 12.0], [2.0, 15.0], [3.0, 17.0]]
    # green maximum and minimum alpha bar; rows: [mach, alphaMax, alphaMin]
    ALPHA_LIM_ENTRY = [                    # Table 8-7, MM 304 & 305
        [0.0, 20.0, -4.0], [0.2, 20.0, -4.0], [0.5, 20.0, 0.0], [0.6, 20.0, 0.7],
        [0.8, 15.0, 2.0], [1.1, 15.8, 4.0], [2.0, 18.3, 4.0], [2.5, 19.6, 6.0],
        [3.0, 21.0, 7.6], [3.2, 21.4, 8.2], [3.5, 22.0, 12.0], [5.0, 28.0, 16.0],
        [8.0, 40.0, 28.9], [9.6, 44.0, 33.0], [11.4, 44.0, 36.0], [27.0, 44.0, 36.0],
    ]
    ALPHA_LIM_GRTLS = [                    # Table 8-8, MM 602 & 603
        [0.0, 20.0, -4.0], [0.2, 20.0, -4.0], [0.5, 20.0, 0.0], [0.6, 20.0, 0.7],
        [0.8, 15.0, 2.0], [1.1, 15.8, 4.0], [2.0, 18.3, 4.0], [2.5, 19.6, 6.0],
        [3.0, 21.0, 8.2], [3.4, 21.0, 10.0], [4.0, 21.0, 10.0], [5.1, 50.0, 10.0],
        [6.0, 53.0, 10.0], [8.0, 53.0, 10.0],
    ]

    def __init__(self, d):
        self._ttTimer = None
        self._altTimer = None
        self._atTimer = None
        self._gtTimer = None
        self._apTimer = None
        self._vtTimer = None
        self._atMode = None
        self._gtMode = None
        self._at0 = None
        self._gt0 = None
        self._ap0 = None
        self._vt0 = None
        self._alt0 = None
        self._adiFrz = None
        self._adiLast = None
        self._tapeCache = None
        self._accCache = None
        self._adiBugG = None
        self._adiRateScales = None
        self._adiDynC = None
        self._adiDynS = None
        self._tickBlkMat = None
        self._tickClipMats = None
        self._diaMats = None
        self._ndlMats = None
        self._uOutlineMat = None
        self._vthickMat = None
        self._wingBMat = None
        self._rollTickMat = None
        self._ballBMat = None
        self.adi = None
        self.avviGrp = None
        self.fcsConfig = None
        self.majorMode = None
        self.ami = None
        self.accMeter = None
        MDUScreen.__init__(self, d)

    def setData(self, curData=None):
        self.curData = curData
        if self.curData is None:
            self.curData = {
                'majorMode': 305,
                'abortMode': "TAL",
                'fcsConfDAPAuto': True,
                'fcsConfThrotAuto': True,
                'adiRolRate': -1.05,   # -5 -> +5
                'adiYawRate': 0,
                'adiPchRate': -0.1,
                # errors default centred; roll sits a touch left so the top
                # needle overlaps the left half of the belly band
                'adiRolErr': -0.25,
                'adiYawErr': 0,
                'adiPchErr': 0,
                # False = ADI OFF: ball locks, needles/pointers stow, digitals
                # blank, red OFF flag shows
                'adiValid': True,
                'adiRol': 315,
                'adiPch': 315,
                'adiYaw': 316,
                'vehicleAcceleration': 1.0,
                'targetNZ': 1.8,      # MM 602 magenta target NZ line
                'keas': 304,          # velocity (KEAS) tape value
                'alpha': 6.0,         # angle-of-attack tape value
                'mach': 0.48,         # velocity tape + limit bar + L/D diamond
                'vel': 480,           # VR/VI, fps
                'ppa': False,         # RTLS powered pitch-around done
                'altitude': 2105,     # altitude (H) tape value, ft
                'altValid': True,
                'hdot': -164,         # altitude rate (H-dot) tape value, fps
                'hdotValid': True,
                'radarAlt': 1950,     # radar altitude, ft
                'radarValid': False,  # radar altimeter lock
            }
        self.draw()

    def data(self):
        return self.curData

    def T_setRPY(self, rpy):
        self.curData['adiRol'] = rpy[0]
        self.curData['adiPch'] = rpy[1]
        self.curData['adiYaw'] = rpy[2]

    # -- group bookkeeping --------------------------------------------------
    def _disposeGroup(self, grp):
        """Dispose a rebuilt group's geometry, sparing cached (keepAlive)
        subtrees: those are detached for reuse on the next build.  Geometries
        are per-build; materials are shared/cached -- never disposed."""
        if grp is None:
            return
        keeps = []
        grp.traverse(lambda o: keeps.append(o) if o.userData.get('keepAlive') else None)
        for k in keeps:
            if k.parent is not None:
                k.parent.remove(k)

        def walk(o):
            if getattr(o, 'geometry', None) is not None:
                o.geometry.dispose()
            for c in list(o.children):
                walk(c)
        walk(grp)

    def _redo(self, grp, builder):
        """Swap one data-driven group for a freshly built one."""
        if grp is not None:
            self.group.remove(grp)
            self._disposeGroup(grp)
        ng = builder()
        if ng is not None:
            self.group.add(ng)
        self.d.dirty = True
        return ng

    def _redrawAVVI(self):
        if self.avviGrp is not None:
            self.group.remove(self.avviGrp)
            self._disposeGroup(self.avviGrp)
        self.avviGrp = self.drawAVVI()
        self.group.add(self.avviGrp)
        self.d.dirty = True

    def _tapeLayer(self, tid, fp, value, mapFn, scale, builder):
        """Cache/reuse one tape's expensive content (label glyphs + ticks)
        across scrollTape rebuilds.  Between rebuilds the cached layer just
        translates.  It rebuilds only when `fp` (the visible-mark fingerprint)
        changes."""
        if tid is None:
            return builder()                    # uncached fallback
        if self._tapeCache is None:
            self._tapeCache = {}
        c = self._tapeCache.get(tid)
        if c is None or c['fp'] != fp:
            if c is not None and c.get('layer') is not None:
                dispose3D(c['layer'])
            layer = builder()
            layer.userData['keepAlive'] = True
            c = {'fp': fp, 'layer': layer, 'anchor': value,
                 'm0': (mapFn(value) if mapFn is not None else None)}
            self._tapeCache[tid] = c
        if c['m0'] is not None:
            c['layer'].position.y = mapFn(value) - c['m0']
        else:
            c['layer'].position.y = (value - c['anchor']) * scale
        return c['layer']

    def refreshFeed(self):
        """Rebuild every data-driven element from curData: used by the debug
        parameter editor after live pokes."""
        self.fcsConfig = self._redo(self.fcsConfig, lambda: self.drawFCSConfig())
        self.majorMode = self._redo(self.majorMode, lambda: self.drawMajorMode())
        self.ami = self._redo(self.ami, lambda: self.drawAMI())
        self.accMeter = self._redo(self.accMeter,
                                   lambda: self.drawAccMeter(*self.ACC_ARGS))
        self._redrawAVVI()
        self.updateADI()

    # -- live-feed tests ----------------------------------------------------
    def toggleTapeTest(self):
        if self._ttTimer is not None:
            self.exitTapeTest()
        else:
            self.enterTapeTest()

    def _mkTimer(self, ms, fn):
        t = QTimer()
        t.timeout.connect(fn)
        t.start(ms)
        return t

    def enterTapeTest(self):
        if self._ttTimer is not None:
            return
        self._ttHdot0 = self.curData['hdot']    # restore the static on exit
        self._ttT0 = time.time() * 1000.0
        self.tickTapeTest()
        self._ttTimer = self._mkTimer(TT_TICK, self.tickTapeTest)
        print("PFD tape feed test ON")

    def exitTapeTest(self):
        if self._ttTimer is None:
            return
        self._ttTimer.stop()
        self._ttTimer = None
        self.curData['hdot'] = self._ttHdot0
        self._redrawAVVI()
        print("PFD tape feed test OFF")

    def tickTapeTest(self):
        ph = ((time.time() * 1000.0 - self._ttT0) / 1000.0 % TT_PERIOD) / TT_PERIOD
        tri = 2 * ph if ph < 0.5 else 2 - 2 * ph
        posMax = 1000 * HD_S + (HDOT_MAX - 1000) * HD_SHI
        pos = -posMax + tri * 2 * posMax
        a = abs(pos)
        v = a / HD_S if a <= 1000 * HD_S else 1000 + (a - 1000 * HD_S) / HD_SHI
        self.curData['hdot'] = jsround(v) * (-1 if pos < 0 else 1)
        self._redrawAVVI()

    def enterAltTest(self):
        if self._altTimer is not None:
            return
        self._alt0 = [self.curData['altitude'], self.curData['radarAlt'],
                      self.curData['radarValid']]
        self._altT0 = time.time() * 1000.0
        self._altTimer = self._mkTimer(TT_TICK, self.tickAltTest)
        self.tickAltTest()
        print("PFD altitude tape test ON")

    def exitAltTest(self):
        if self._altTimer is None:
            return
        self._altTimer.stop()
        self._altTimer = None
        if self._alt0 is not None:
            (self.curData['altitude'], self.curData['radarAlt'],
             self.curData['radarValid']) = self._alt0
        self._alt0 = None
        self._redrawAVVI()
        print("PFD altitude tape test OFF")

    def tickAltTest(self):
        ph = ((time.time() * 1000.0 - self._altT0) / 1000.0 % AT2_PERIOD) / AT2_PERIOD
        tri = 2 * ph if ph < 0.5 else 2 - 2 * ph
        p0 = altMapRows(ALT_MIN)
        p1 = altMapRows(ALT_MAX)
        alt = altInvRows(p0 + tri * (p1 - p0))
        self.curData['altitude'] = jsround(alt)
        # radar locks only in the tape's 0..5000 band
        self.curData['radarValid'] = 0 <= alt < 5000
        self.curData['radarAlt'] = max(0, jsround(alt * 0.92 - 40))
        self._redrawAVVI()

    def adiTestMode(self):
        return AT_MODES[self._atMode] if self._atMode is not None else 'off'

    def setAdiTestMode(self, name):
        i = AT_MODES.index(name) if name in AT_MODES else -1
        if i == (self._atMode if self._atMode is not None else -1):
            return
        d = self.curData
        if i < 0:                                   # off
            if self._atTimer is not None:
                self._atTimer.stop()
            self._atTimer = None
            if self._at0 is not None:
                (d['adiRol'], d['adiPch'], d['adiYaw'], d['adiRolErr'],
                 d['adiPchErr'], d['adiYawErr'], d['adiRolRate'],
                 d['adiPchRate'], d['adiYawRate']) = self._at0
                self._at0 = None
            self._atMode = None
            self.updateADI()
        else:
            # save the static defaults once, when the test first engages
            if self._at0 is None:
                self._at0 = [d['adiRol'], d['adiPch'], d['adiYaw'], d['adiRolErr'],
                             d['adiPchErr'], d['adiYawErr'], d['adiRolRate'],
                             d['adiPchRate'], d['adiYawRate']]
            self._atMode = i
            if i == 4:                              # freeze: hold data as-is
                if self._atTimer is not None:
                    self._atTimer.stop()
                self._atTimer = None
            else:
                self._atT0 = time.time() * 1000.0   # each sweep starts at zero
                if self._atTimer is None:
                    self._atTimer = self._mkTimer(AT_TICK, self.tickAdiTest)
                self.tickAdiTest()
        print("PFD ADI test: %s" % self.adiTestMode())

    def tickAdiTest(self):
        if self._atMode is None or self._atMode >= 4:
            return
        t = (time.time() * 1000.0 - self._atT0) / 1000.0
        d = self.curData
        d['adiRol'] = 0
        d['adiPch'] = 0
        d['adiYaw'] = 0
        if self._atMode == 0:
            d['adiPch'] = (AT_RATE * t) % 360
        elif self._atMode == 1:
            u = (AT_RATE * t) % 380
            d['adiYaw'] = u if u < 95 else (190 - u if u < 285 else u - 380)
        elif self._atMode == 2:
            d['adiRol'] = (AT_RATE * t) % 360
        elif self._atMode == 3:
            d['adiRol'] = (AT_RATE * t) % 360
            d['adiPch'] = 25 * math.sin(2 * math.pi * t / 37)
            d['adiYaw'] = 40 * math.sin(2 * math.pi * t / 23)
        d['adiRolErr'] = 5 * math.sin(2 * math.pi * t / 9)
        d['adiPchErr'] = 5 * math.sin(2 * math.pi * t / 11)
        d['adiYawErr'] = 5 * math.sin(2 * math.pi * t / 13)
        d['adiRolRate'] = 5 * math.sin(2 * math.pi * t / 15)
        d['adiPchRate'] = 5 * math.sin(2 * math.pi * t / 17)
        d['adiYawRate'] = 5 * math.sin(2 * math.pi * t / 19)
        self.updateADI()

    def gTestMode(self):
        return GT_MODES[self._gtMode][0] if self._gtMode is not None else 'off'

    def setGTestMode(self, name):
        names = [m[0] for m in GT_MODES]
        i = names.index(name) if name in names else -1
        if i == (self._gtMode if self._gtMode is not None else -1):
            return
        d = self.curData
        if i < 0:                                   # off
            if self._gtTimer is not None:
                self._gtTimer.stop()
            self._gtTimer = None
            if self._gt0 is not None:
                d['majorMode'], d['vehicleAcceleration'], d['targetNZ'] = self._gt0
            self._gt0 = None
            self._gtMode = None
            self._redrawGMeter()
        else:
            if self._gt0 is None:
                self._gt0 = [d['majorMode'], d['vehicleAcceleration'], d['targetNZ']]
            self._gtMode = i
            d['majorMode'] = GT_MODES[i][1]
            self._gtT0 = time.time() * 1000.0
            if self._gtTimer is None:
                self._gtTimer = self._mkTimer(GT_TICK, self.tickGTest)
            self.tickGTest()
        print("PFD G-meter test: %s" % self.gTestMode())

    def tickGTest(self):
        if self._gtMode is None:
            return
        t = (time.time() * 1000.0 - self._gtT0) / 1000.0
        d = self.curData
        ph = (t % 12) / 12
        tri = 2 * ph if ph < 0.5 else 2 - 2 * ph          # 0..1..0
        d['vehicleAcceleration'] = jsround((-1 + tri * 5) * 10) / 10
        if GT_MODES[self._gtMode][1] == 602:
            ph = (t % 31) / 31
            tri = 2 * ph if ph < 0.5 else 2 - 2 * ph
            d['targetNZ'] = jsround((4 - tri * 5) * 10) / 10
        self._redrawGMeter()

    def _redrawGMeter(self):
        self.accMeter = self._redo(self.accMeter,
                                   lambda: self.drawAccMeter(*self.ACC_ARGS))
        self.majorMode = self._redo(self.majorMode, lambda: self.drawMajorMode())

    def enterAlphaTest(self):
        if self._apTimer is not None:
            return
        self._ap0 = [self.curData['alpha'], self.curData['mach']]
        self._apT0 = time.time() * 1000.0
        self._apTimer = self._mkTimer(ATP_TICK, self.tickAlphaTest)
        self.tickAlphaTest()
        print("PFD alpha tape test ON")

    def exitAlphaTest(self):
        if self._apTimer is None:
            return
        self._apTimer.stop()
        self._apTimer = None
        if self._ap0 is not None:
            self.curData['alpha'], self.curData['mach'] = self._ap0
        self._ap0 = None
        self.ami = self._redo(self.ami, lambda: self.drawAMI())
        print("PFD alpha tape test OFF")

    def tickAlphaTest(self):
        t = (time.time() * 1000.0 - self._apT0) / 1000.0

        def tri(p):
            ph = (t % p) / p
            return 2 * ph if ph < 0.5 else 2 - 2 * ph
        self.curData['alpha'] = jsround((-8 + tri(11) * 32) * 10) / 10
        self.curData['mach'] = jsround((0.3 + tri(17) * 2.9) * 100) / 100
        self.ami = self._redo(self.ami, lambda: self.drawAMI())

    def enterVelTest(self):
        if self._vtTimer is not None:
            return
        self._vt0 = [self.curData['mach'], self.curData['vel'], self.curData['keas']]
        self._vtT0 = time.time() * 1000.0
        self._vtTimer = self._mkTimer(VT_TICK, self.tickVelTest)
        self.tickVelTest()
        print("PFD velocity tape test ON")

    def exitVelTest(self):
        if self._vtTimer is None:
            return
        self._vtTimer.stop()
        self._vtTimer = None
        if self._vt0 is not None:
            self.curData['mach'], self.curData['vel'], self.curData['keas'] = self._vt0
        self._vt0 = None
        self.ami = self._redo(self.ami, lambda: self.drawAMI())
        print("PFD velocity tape test OFF")

    def tickVelTest(self):
        t = (time.time() * 1000.0 - self._vtT0) / 1000.0

        def tri(p):
            ph = (t % p) / p
            return 2 * ph if ph < 0.5 else 2 - 2 * ph
        # triangle over the piecewise legs: up the segment table, then back
        legT = 0
        for s in VT_SEGS:
            legT += s[1]
        ph = t % (2 * legT)
        if ph > legT:
            ph = 2 * legT - ph
        u = 0
        for du, dt in VT_SEGS:
            if ph >= dt:
                u += du
                ph -= dt
            else:
                u += du * ph / dt
                break
        self.curData['mach'] = jsround(min(u, 4) * 100) / 100
        self.curData['vel'] = jsround(u * 1000)
        self.curData['keas'] = jsround(tri(23) * 500)
        self.ami = self._redo(self.ami, lambda: self.drawAMI())

    def testControls(self):
        """Descriptors for the parameter editor's test-control section:
        `options` renders as a pulldown, plain get/set as an on/off checkbox."""
        return [
            {'label': 'ADI test', 'options': ['off'] + AT_MODES,
             'get': (lambda: self.adiTestMode()),
             'set': (lambda m: self.setAdiTestMode(m))},
            {'label': 'Hdot tape test',
             'get': (lambda: self._ttTimer is not None),
             'set': (lambda v: self.enterTapeTest() if v else self.exitTapeTest())},
            {'label': 'Alt tape test',
             'get': (lambda: self._altTimer is not None),
             'set': (lambda v: self.enterAltTest() if v else self.exitAltTest())},
            {'label': 'G-meter test', 'options': ['off'] + [m[0] for m in GT_MODES],
             'get': (lambda: self.gTestMode()),
             'set': (lambda m: self.setGTestMode(m))},
            {'label': 'Alpha tape test',
             'get': (lambda: self._apTimer is not None),
             'set': (lambda v: self.enterAlphaTest() if v else self.exitAlphaTest())},
            {'label': 'Vel tape test',
             'get': (lambda: self._vtTimer is not None),
             'set': (lambda v: self.enterVelTest() if v else self.exitVelTest())},
        ]

    # -- the page -----------------------------------------------------------
    def build(self):
        self.setData()
        self.T_RPY_TOP = [0, 89, 271]
        self.T_RPY_1 = [331, 348, 0]
        self.T_RPY_2 = [0, 348, 0]
        self.T_setRPY([0.5, 348.5, 0.25])
        self.group = Object3D()
        self.group.name = "AE_PFD"

        self.group.add(self.drawFCSConfig())
        self.group.add(self.drawMajorMode())
        self.group.add(self.drawAMI())

        self.avviGrp = self.drawAVVI()
        self.group.add(self.avviGrp)
        self.d.dirty = True

        MRN_X = 37.62
        MRN_Y = 26.88
        self.group.add(self.d.box(MRN_X, MRN_Y + 0.95, MRN_X + 4.0, MRN_Y + 2,
                                  self.d.c2h['darkGray']))
        self.group.add(self.d.str(MRN_X + 0.15, MRN_Y, "MRN20",
                                  self.d.c2h['darkGray'], 0.85, 0.90, 1.10))
        self.group.add(self.d.strMEDS(MRN_X + 1.99, MRN_Y + 1.16, "2.4",
                                      self.d.c2h['white'], 0.85, 0.70))

        self.group.add(self.drawAccMeter(*self.ACC_ARGS))
        self.group.add(self.drawADI(24.90, 12.0))
        self.group.add(self.drawHSI(25, 30))

        self.drawAttAcc()
        self.drawGSI()
        self.drawRange()

    def drawFCSConfig(self):
        """FCS Configuration -- DAP and throttle mode.  [JSC-48017/p.279]"""
        self.fcsConfig = Object3D()
        C = self.d.c2h
        mm = self.data()['majorMode']
        F = self.fcsConfig
        if mm in (101, 102, 103, 601):
            F.add(self.d.str(2, 0.75, "  DAP:", C['darkGray'], 1, .9))
            F.add(self.d.str(2, 1.75, "Throt:", C['darkGray'], 1, .9))
            F.add(self.d.str(8, 0.75, "Auto" if self.data().get('fcsConfDAPAuto') else " CSS",
                             C['white'], 1, .9))
            F.add(self.d.str(8, 1.75, "Auto" if self.data().get('fcsConfThrotAuto') else "MAN",
                             C['white'], 1, .9))
        elif mm in (104, 105, 106):
            F.add(self.d.str(2, 0.75, "  DAP:", C['darkGray'], 1, .9))
            F.add(self.d.str(8, 0.75, "Auto" if self.data().get('fcsConfDAPAuto') else "INRTL",
                             C['white'], 1, .9))
        elif mm in (301, 302, 303):
            F.add(self.d.str(2, 0.75, "  DAP:", C['darkGray'], 1, .9))
            F.add(self.d.str(8, 0.75, "Auto" if self.data().get('fcsConfDAPAuto') else "INRTL",
                             C['white'], 1, .9))
        elif mm in (304, 305, 602, 603):
            F.add(self.d.str(3, 0.9, "Pitch:", C['darkGray'], 1, .9))
            F.add(self.d.str(3, 1.9, "  R/Y:", C['darkGray'], 1, .9))
            F.add(self.d.str(8.5, 0.90, "Auto" if self.data().get('fcsConfPitchAuto') else " CSS",
                             C['white'], 1, .9))
            F.add(self.d.str(8.5, 1.90, "Auto" if self.data().get('fcsConfRYAuto') else " CSS",
                             C['white'], 1, .9))
        if self.data().get('fcsConfDAPSel'):
            F.add(self.d.box(2, 0.75, 12.75, 1.75, C['yellow']))
        F.add(self.d.str(42, 2, " SB:", C['darkGray'], 1, .9))
        F.add(self.d.str(45.78, 2, " Auto", C['white'], 1, .9))
        return F

    def drawMajorMode(self):
        """The current major mode, upper right; with an abort declared, an
        indicator verifies the abort mode selected."""
        self.majorMode = Object3D()
        am = self.data().get('abortMode')
        abt = {"RTLS": "R", "TAL": "T", "AOA": "AOA", "ATO": "ATO",
               "Contingency": "CA"}.get(am, "")
        mmStr = " %s%s" % (self.data()['majorMode'], abt)
        self.majorMode.add(self.d.str(42, .95, " MM:", self.d.c2h['darkGray'], 1, .9))
        self.majorMode.add(self.d.str(45.78, .95, mmStr, self.d.c2h['white'], 1, .9))
        return self.majorMode

    def buildHdotTape(self):
        pass

    def drawTape(self, x0, y0, pointer=False, value=None):
        group = Object3D()
        if value is not None:
            matW = self.d.c2h['white']
            matG = self.d.c2h['darkGray']
        else:
            matW = self.d.c2h['red']
            matG = self.d.c2h['red']
        group.add(self.d.box(x0, y0, x0 + 4.75, y0 + 15.15, matW, 0))
        clipBox = Vector4(x0, x0 + 4.75, y0, y0 + 15.15)
        if pointer:
            dl = BufferGeometry()
            dl.setAttribute('position', Float32BufferAttribute([
                x0 - .5, 11, 1, x0 + 4.0, 11, 1, x0 + 4.7, 11.875, 1,
                x0 + 4.0, 12.75, 1, x0 - .5, 12.75, 1], 3))
            dl.setIndex([0, 1, 3, 1, 2, 3, 3, 4, 0])
            fill = MeshBasicMaterial({'color': self.d.c2h['black'], 'side': DoubleSide})
            group.add(Mesh(dl, fill))
            group.add(self.d.line([[x0 - .5, 11], [x0 + 4.0, 11],
                                   [x0 + 4.7, 11.875], [x0 + 4.0, 12.75],
                                   [x0 - .5, 12.75], [x0 - .5, 11]], matG, 1.0, clipBox))
        else:
            group.add(self.d.box(x0, 11, x0 + 4.75, 12.75, self.d.c2h['lightGray'],
                                 self.d.c2h['black'], self.d.NO_CLIP))
        return group

    def _thinTick(self, pts, clip):
        """Thin (1.5px) background-colour tick stroke, clipped: the clip planes
        ride on cloned materials, so the clones are cached per clip rect."""
        if self._tickBlkMat is None:
            self._tickBlkMat = makeSDFLineMaterial(
                self.d.sdfOpt({'color': self.d.c2h['black'], 'widthPx': 1.5}))
        if self._tickClipMats is None:
            self._tickClipMats = {}
        key = "%s,%s,%s,%s" % (clip.x, clip.y, clip.z, clip.w)
        m = self._tickClipMats.get(key)
        if m is None:
            m = self.d._clipMat(self._tickBlkMat, clip)
            self._tickClipMats[key] = m
        t = Mesh(makeSDFLineGeometry(pts), m)
        t.frustumCulled = False
        t.renderOrder = -1        # tuck tick ends under the frame stroke
        return t

    def _lerpTable(self, tbl, m, col):
        """Linear interpolation down a [mach, ...] table column, clamped."""
        if m <= tbl[0][0]:
            return tbl[0][col]
        for i in range(1, len(tbl)):
            if m <= tbl[i][0]:
                f = (m - tbl[i - 1][0]) / (tbl[i][0] - tbl[i - 1][0])
                return tbl[i - 1][col] + f * (tbl[i][col] - tbl[i - 1][col])
        return tbl[len(tbl) - 1][col]

    # -----------------------------------------------------------------------
    # Vertical scrolling tape
    #
    # Window (x0,y0)-(x0+w,y0+h), current `value` centred, labels every `step`
    # at `scale` rows/unit, all clipped to the window.  A fixed white-on-black
    # digital readout sits at the centre (drawn in front, unclipped).
    # -----------------------------------------------------------------------
    def scrollTape(self, x0, y0, w, h, value, step, scale, opts=None):
        opts = opts or {}
        C = self.d.c2h
        digits = opts.get('digits', 0)
        tickW = opts.get('tickW', 2)
        tickColor = opts.get('tickColor', C['white'])
        pointer = opts.get('pointer', False)
        signed = opts.get('signed', False)
        center = opts.get('center', False)
        lblScale = opts.get('lblScale', 1.0)          # legend type size
        MADV = 0.8                                    # meds digit advance
        adv = opts.get('advF', MADV) * lblScale       # legend advance
        rdScale = opts.get('rdScale', 1.1)            # centre readout type size
        # meds digit ink metrics, measured from the meds_font.svg geometry
        GXC = 1.368   # digit ink centre, x
        GXL = 1.009   # digit ink left edge, x
        GXR = 1.726   # digit ink right edge (the '4' tail is the widest)
        GYC = 0.330   # digit ink centre below the draw origin, y
        grp = Object3D()
        cy = y0 + h / 2
        cx = x0 + w / 2
        bandH = 0.85                                  # half-height of readout box
        # opts.boxDy shifts the readout box off the tape centre; the
        # value->row mapping stays anchored on cy
        bcy = cy + opts.get('boxDy', 0)
        # opts.clipOff: the owning group's world offset.  Clip planes live in
        # WORLD space and ignore group transforms, so tapes drawn in a shifted
        # group must shift their clip rects to match.
        cOx, cOy = opts.get('clipOff', [0, 0])
        clipTop = Vector4(x0 + cOx, x0 + w + cOx, y0 + cOy, bcy - bandH + cOy)
        clipBot = Vector4(x0 + cOx, x0 + w + cOx, bcy + bandH + cOy, y0 + h + cOy)
        # opts.map: nonlinear/piecewise value->rows mapping (rows above the
        # tape datum, monotonic).  `scale` is ignored wherever a map is given.
        mapFn = opts.get('map')
        map0 = mapFn(value) if mapFn is not None else 0

        def dpos(v):
            return (mapFn(v) - map0) if mapFn is not None else (v - value) * scale

        vMin = vMax = None
        # opts.range [vMin, vMax]: bounded unsigned tape.  The white face spans
        # just the value range -- padded ~a label half-height past each end --
        # with black labels and thin black ticks; past the tape ends the window
        # shows bare background (the physical tape has run out).
        if opts.get('range') is not None:
            vMin, vMax = opts['range']
            fPad = 0.55 * lblScale
            yT = max(y0, min(y0 + h, cy - dpos(vMax) - fPad))
            yB = max(y0, min(y0 + h, cy - dpos(vMin) + fPad))
            if yB > yT:
                grp.add(self.d.box(x0, yT, x0 + w, yB, None, C['white']))
        # signed tapes: white background where value>=0, grey where value<0
        if signed:
            yZ = max(y0, min(y0 + h, cy - dpos(0)))   # y of the value=0 boundary
            if opts.get('marks') is None:             # marks tapes bring faces
                grp.add(self.d.box(x0, y0, x0 + w, yZ, None, C['white']))
                grp.add(self.d.box(x0, yZ, x0 + w, y0 + h, None,
                                   opts.get('grayFace', C['darkGray'])))
            # a background-blue rule separates the white (>=0) and grey (<0)
            # tape faces; clipped like the labels so it slides behind the box
            if opts.get('border') and y0 < yZ < y0 + h:
                zl = self.d.line([[x0, yZ], [x0 + w, yZ]], C['black'], 1.0,
                                 (clipTop if yZ < bcy else clipBot))
                # under the right-lane ticks (-1): the white 0 tick rides OVER
                # this boundary rule, per spec
                zl.renderOrder = -2
                grp.add(zl)
        # green min/max limit bar riding the right tick lane, under the ticks
        if opts.get('greenBar') is not None and opts.get('rightTicks') is not None:
            vLo, vHi = opts['greenBar']
            yHi = max(y0, min(y0 + h, cy - dpos(vHi)))
            yLo = max(y0, min(y0 + h, cy - dpos(vLo)))
            gtl = opts['rightTicks'].get('len', 0.75)
            if yLo > yHi:
                grp.add(self.d.box(x0 + w - gtl - 0.15, yHi, x0 + w, yLo, None,
                                   C['green']))
        grp.add(self.d.box(x0, y0, x0 + w, y0 + h, C['white']))   # window frame

        # opts.border: white-on-grey content gets a thin background-blue halo
        # (SDF border) to set it off from the grey band, like the real MEDS.
        def lblClr(v):
            if opts.get('range') is not None:
                return C['black']         # range tapes: black on the white face
            if not signed:
                return C['white']
            if v > 0 or (v == 0 and not opts.get('border')):
                return C['black']
            if opts.get('border'):
                return {'c': C['white'], 'border': C['black']}
            return C['white']

        # label x-anchor: ink-true centring on cx via GXC, or ink-true LEFT
        # anchoring: left ink edge at x0+lblPad regardless of type size
        def lblAt(txt):
            if center:
                return cx - (len(txt) - 1) * adv / 2 - (GXC * lblScale - 1)
            return x0 + opts.get('lblPad', 0.41) + 1 - GXL * lblScale

        if opts.get('marks') is not None:
            # opts.marks(value) -> {faces, labels, ticks}: explicit mark lists
            # for piecewise tapes (AVVI altitude / altitude-rate).
            mk = opts['marks'](value)
            fPad = 0.55 * lblScale
            # faces are a few clamped quads -- cheap, rebuilt every call
            for f in (mk.get('faces') or []):
                yFT = max(y0, min(y0 + h, cy - dpos(f['v1']) - (fPad if f.get('padHi') else 0)))
                yFB = max(y0, min(y0 + h, cy - dpos(f['v0']) + (fPad if f.get('padLo') else 0)))
                if yFB > yFT:
                    grp.add(self.d.box(x0, yFT, x0 + w, yFB, None, f['fill']))
            # labels + ticks: the expensive glyph/stroke content rides a cached
            # layer -- kept with a margin past the window so a rebuild happens
            # before anything scrolls on.
            MMARG = 3
            visLabels = [L for L in (mk.get('labels') or [])
                         if y0 - 1.5 - MMARG <= cy - dpos(L['v']) <= y0 + h + 1.5 + MMARG]
            visTicks = [T for T in (mk.get('ticks') or [])
                        if y0 - 0.5 - MMARG <= cy - dpos(T['v']) <= y0 + h + 0.5 + MMARG]
            fp = (','.join("%s~%s~%d" % (L['v'], L['txt'], 1 if (cy - dpos(L['v']) < cy) else 0)
                           for L in visLabels) + '|'
                  + ','.join("%s~%s~%s~%d~%d" % (T['v'], T['x0'], T['x1'],
                                                 1 if T.get('thin') else 0,
                                                 1 if (cy - dpos(T['v']) < cy) else 0)
                             for T in visTicks))

            def buildMarks():
                lg = Object3D()
                for L in visLabels:
                    yV = cy - dpos(L['v'])
                    # y = yV - GYC*lblScale puts the measured ink centre on the
                    # value line; clips end at the readout box edges so labels
                    # slide behind it
                    lg.add(self.d.strMEDS(lblAt(L['txt']), yV - GYC * lblScale,
                                          L['txt'], L['c'], lblScale, adv, 1.0,
                                          (clipTop if yV < cy else clipBot)))
                for T in visTicks:
                    yVt = cy - dpos(T['v'])
                    tclip = clipTop if yVt < cy else clipBot
                    if T.get('thin'):
                        lg.add(self._thinTick([[T['x0'], yVt], [T['x1'], yVt]], tclip))
                    else:
                        lg.add(self.d.line([[T['x0'], yVt], [T['x1'], yVt]],
                                           T['c'], 1.0, tclip))
                return lg
            grp.add(self._tapeLayer(opts.get('id'), fp, value, mapFn, scale, buildMarks))
        else:
            nEach = int(math.ceil((h / 2) / (scale * step))) + 1
            vC = jsround(value / step) * step
            eps = step / 1000            # float-noise guard at the range ends

            def inRng(v):
                return opts.get('range') is None or (vMin - eps <= v <= vMax + eps)
            # cached layer: the mark window is anchored on vC, so the
            # fingerprint is vC plus each mark's side of the tape centre
            fp = "%s|" % vC + ''.join(
                "%d%d" % (1 if dpos(vC + k * step) > 0 else 0,
                          1 if dpos(vC + (k + 0.5) * step) > 0 else 0)
                for k in range(-nEach, nEach + 1))

            def buildTicks():
                lg = Object3D()
                for k in range(-nEach, nEach + 1):
                    V = vC + k * step
                    yV = cy - dpos(V)                # higher value -> higher up
                    if inRng(V):
                        # opts.lblFn formats the legend
                        txt = opts['lblFn'](V) if opts.get('lblFn') else _numstr(V)
                        lg.add(self.d.strMEDS(lblAt(txt), yV - GYC * lblScale, txt,
                                              lblClr(V), lblScale, adv, 1.0,
                                              (clipTop if yV < cy else clipBot)))
                    if tickW > 0:                    # minor tick at the half-step
                        Vt = V + step / 2
                        yVt = cy - dpos(Vt)
                        if inRng(Vt):
                            # opts.tickFn overrides the centred extent; None
                            # skips the tick
                            ext = opts['tickFn'](Vt) if opts.get('tickFn') \
                                else [cx - tickW / 2, cx + tickW / 2]
                            if ext is not None:
                                tclip = clipTop if yVt < cy else clipBot
                                if opts.get('range') is not None:
                                    lg.add(self._thinTick([[ext[0], yVt], [ext[1], yVt]],
                                                          tclip))
                                else:
                                    lg.add(self.d.line([[ext[0], yVt], [ext[1], yVt]],
                                                       (lblClr(Vt) if signed else tickColor),
                                                       1.0, tclip))
                return lg
            grp.add(self._tapeLayer(opts.get('id'), fp, value, mapFn, scale, buildTicks))

        # right-lane unit ticks: black on the white (positive) face, white with
        # the dark halo on the grey face; the 0 tick is white and rides OVER
        # the face-boundary rule
        if opts.get('rightTicks') is not None:
            ts = opts['rightTicks'].get('step', 1)
            tl = opts['rightTicks'].get('len', 0.75)
            if self._tickBlkMat is None:
                self._tickBlkMat = makeSDFLineMaterial(
                    self.d.sdfOpt({'color': C['black'], 'widthPx': 1.5}))
            vT0 = math.ceil((value - (h / 2) / scale) / ts) * ts
            vT1 = math.floor((value + (h / 2) / scale) / ts) * ts
            for V in crange(vT0, vT1, ts):
                yV = cy - dpos(V)
                if yV < y0 or yV > y0 + h:
                    continue
                if V > 0:
                    t = Mesh(makeSDFLineGeometry([[x0 + w - tl, yV], [x0 + w, yV]]),
                             self._tickBlkMat)
                    t.frustumCulled = False
                else:
                    t = self.d.line([[x0 + w - tl, yV], [x0 + w, yV]],
                                    {'c': C['white'], 'border': C['black']})
                # renderOrder -1: the tick's right end tucks UNDER the frame
                t.traverse(lambda o: setattr(o, 'renderOrder', -1) if o.isMesh else None)
                grp.add(t)

        # Max L/D diamond riding the tick lane at opts.diamond's value
        if opts.get('diamond') is not None:
            yD = cy - dpos(opts['diamond'])
            dw = 0.44
            dh = dw * 13.783 / 18.79
            # draw while any part is inside the window; the clip rect trims it
            if y0 - dh < yD < y0 + h + dh:
                dcx = x0 + w - ((opts['rightTicks'].get('len', 0.75)
                                 if opts.get('rightTicks') else 0.75) / 2)
                dclip = Vector4(x0 + cOx, x0 + w + cOx, y0 + cOy, y0 + h + cOy)
                dpts = [[dcx - dw, yD], [dcx, yD - dh], [dcx + dw, yD], [dcx, yD + dh]]
                grp.add(self.d.polyFill(dpts, C['black'], None, dclip))
                # heavier outline than d.line's default, rounding out the shape
                if self._diaMats is None:
                    self._diaMats = [
                        self.d._clipMat(makeSDFLineMaterial(self.d.sdfOpt(
                            {'color': C['black'], 'widthPx': 3 + 1.8})), dclip),
                        self.d._clipMat(makeSDFLineMaterial(self.d.sdfOpt(
                            {'color': C['magenta'], 'widthPx': 3})), dclip)]
                dgeom = makeSDFLineGeometry(dpts + [dpts[0]])
                for dm, dord in ((self._diaMats[0], 0), (self._diaMats[1], 1)):
                    dmesh = Mesh(dgeom, dm)
                    dmesh.frustumCulled = False
                    dmesh.renderOrder = dord
                    grp.add(dmesh)

        # centre digital readout: always grey border, dark/bg fill, white text
        if pointer:
            # square part reaches the tick lane; arrow tapers to the point from
            # there.  Opaque over the frame/tick strokes.
            lx = x0 - 0.35
            px = x0 + w - 0.24
            mx = (x0 + w - opts['rightTicks'].get('len', 0.75) - 0.15) \
                if opts.get('rightTicks') else (px - 1.3)
            pf = self.d.polyFill([[lx, bcy - bandH], [mx, bcy - bandH], [px, bcy],
                                  [mx, bcy + bandH], [lx, bcy + bandH]],
                                 C['black'], {'c': C['darkGray'], 'border': C['black']})

            def _pfSet(o):
                if o.isMesh:
                    o.renderOrder = 2
                    if o.material.isMeshBasicMaterial:
                        o.material.transparent = True
            pf.traverse(_pfSet)
            grp.add(pf)
        else:
            grp.add(self.d.box(x0, bcy - bandH, x0 + w, bcy + bandH,
                               C['darkGray'], C['black']))
        # opts.rdStr overrides the readout text outright (radar 'R')
        if opts.get('rdStr') is not None:
            vstr = opts['rdStr']
        elif digits > 0:
            vstr = "%.*f" % (digits, value)
        else:
            vstr = "%d" % jsround(value)
        # readout advance tracks its type size, else narrow glyphs crowd
        rAdv = opts.get('rdAdv', (MADV * rdScale) if opts.get('rdScale') is not None
                        else MADV)
        # rjust: right ink edge flush against the box's right side
        if opts.get('rjust'):
            rX = x0 + w - ((len(vstr) - 1) * rAdv + GXR * rdScale - 1)
        elif center:
            rX = cx - (len(vstr) * rAdv) / 2
        else:
            rX = x0 + 0.3
        # ink-centre the readout vertically when rdScale is explicit
        rY = (bcy - GYC * rdScale) if opts.get('rdScale') is not None else (bcy - 0.45)
        rX += opts.get('rdDx', 0)
        rY += opts.get('rdDy', 0)
        # opts.rdLeadUp: the reference shows the leading chars of the readout
        # riding slightly high of the final digit
        leadUp = opts.get('rdLeadUp', 0)
        rTxt = Object3D()
        if opts.get('rjust') and leadUp:
            rTxt.add(self.d.strMEDS(rX, rY - leadUp, vstr[:-1], C['white'],
                                    rdScale, rAdv, 1.0))
            rTxt.add(self.d.strMEDS(rX + (len(vstr) - 1) * rAdv, rY, vstr[-1:],
                                    C['white'], rdScale, rAdv, 1.0))
        else:
            rTxt.add(self.d.strMEDS(rX, rY, vstr, C['white'], rdScale, rAdv, 1.0))
        # readout text rides above the pointer-box fill (renderOrder 2)
        rTxt.traverse(lambda o: setattr(o, 'renderOrder', 3) if o.isMesh else None)
        grp.add(rTxt)
        return grp

    # -----------------------------------------------------------------------
    # Alpha/Mach Indicator (AMI)
    #
    # NAV-derived and barometric angle of attack in degrees, and velocity in
    # Knots Equivalent Airspeed or Mach number.  Both tapes scroll within their
    # windows, with the tape digital value in a white-on-black box at the
    # tape's centre.  The tape shows mach except in MM 305/603 below M 0.9,
    # where the tape and the digital readout below it swap.
    # -----------------------------------------------------------------------
    def drawAMI(self):
        self.ami = Object3D()
        C = self.d.c2h
        AMI_OFF = [0.075, 0.187]     # group nudge (right ~2px, down ~5px)
        mm = self.data()['majorMode']
        mach = self.data().get('mach') or 0
        keas = self.data().get('keas') or 0
        swap = mm in (305, 603) and mach < 0.9
        velLbl = "M/VI" if (mm in (103, 104)
                            or (mm == 601 and not self.data().get('ppa'))) else "M/VR"
        vx0 = 1.8
        vw = 4.75
        vcx = vx0 + vw / 2
        vOpts = {'center': True, 'lblScale': 1.2, 'rdScale': 1.2, 'clipOff': AMI_OFF}
        if swap:
            self.ami.add(self.d.str(2.25, 3.24, "KEAS", C['darkGray'], 1, .9))
            o = dict(vOpts)
            o.update({'id': 'ami-keas', 'tickW': 0.27 * TAPE_IN_COLS, 'range': [0, 500]})
            self.ami.add(self.scrollTape(vx0, 4.4, vw, 15.57, keas, 10,
                                         0.1 * TAPE_IN_ROWS, o))
        else:
            # above M 4 the tape value is velocity in Kfps, continuing
            # seamlessly from the mach face
            tapeV = mach if mach < 4 else max(4, (self.data().get('vel') or 0) / 1000)

            def machLbl(V):
                v = jsround(V * 10) / 10
                s = "%.1f" % v
                if v == jsround(v):
                    return s + ("K" if v >= 4 else "M")
                return s

            def machTick(Vt):
                if Vt < 4:
                    return [vcx - 0.125 * TAPE_IN_COLS, vcx + 0.125 * TAPE_IN_COLS]
                return [vx0, vx0 + 0.17 * TAPE_IN_COLS]
            self.ami.add(self.d.str(2.25, 3.24, velLbl, C['darkGray'], 1, .9))
            o = dict(vOpts)
            o.update({'id': 'ami-mach', 'digits': (2 if tapeV < 4 else 1),
                      'tickW': 1, 'lblFn': machLbl, 'tickFn': machTick,
                      'range': [0, 27]})
            self.ami.add(self.scrollTape(vx0, 4.4, vw, 15.57, tapeV, 0.2,
                                         4 * TAPE_IN_ROWS, o))

        # digital readout below the tape: KEAS normally; the mach/velocity
        # value when swapped.  Positions were pixel-tuned in unshifted screen
        # coords, so the child group backs the AMI nudge out.
        blo = Object3D()
        blo.position.set(-AMI_OFF[0], -AMI_OFF[1], 0)
        bloVal = ("%.2f" % mach) if swap else ("%d" % jsround(keas))
        blo.add(self.d.box(1.925, 20.911, 6.625, 22.661, C['darkGray']))
        blo.add(self.d.str(2.69, 23.011, (velLbl if swap else "KEAS"),
                           C['darkGray'], 0.9, 0.9))
        # value anchor tuned on the 4-char "0.48"; shorter strings centre on it
        blo.add(self.d.strMEDS(2.41 + (4 - len(bloVal)) * 0.94 / 2, 21.43, bloVal,
                               C['white'], 1.25, 0.94))
        self.ami.add(blo)

        # alpha tape -- just left of tape centre, baseline to the KEAS label
        self.ami.add(self.d.str(8.85, 3.28, u"α", C['darkGray'], 1.2))
        # Range: -180..180 deg.  Positive face white w/ background-colour
        # labels and ticks; negative face grey w/ white halo'd labels and
        # ticks; the 0 tick is white and rides over the face boundary.
        aOpts = {'digits': 1, 'tickW': 0, 'pointer': True, 'signed': True,
                 'center': True, 'border': True, 'lblScale': 1.2, 'rdScale': 1.2,
                 'rdAdv': 0.9, 'rjust': True, 'rdDx': -0.43, 'rdDy': -0.05,
                 'grayFace': C['lightGray'],
                 'rightTicks': {'step': 1, 'len': 0.75}, 'clipOff': AMI_OFF}
        if mm in (304, 305):
            aTbl = self.ALPHA_LIM_ENTRY
        elif mm in (602, 603):
            aTbl = self.ALPHA_LIM_GRTLS
        else:
            aTbl = None
        if aTbl is not None:
            aOpts['greenBar'] = [self._lerpTable(aTbl, mach, 2),
                                 self._lerpTable(aTbl, mach, 1)]
        if mach < 3.0:
            aOpts['diamond'] = self._lerpTable(self.ALPHA_MAXLD, mach, 1)
        aOpts['id'] = 'alpha'
        self.ami.add(self.scrollTape(7.4, 4.4, 4.75, 15.57, self.data()['alpha'],
                                     5, 0.685, aOpts))
        self.ami.position.set(AMI_OFF[0], AMI_OFF[1], 0)
        return self.ami

    def makeClipWin(self, clipBox):
        m = MeshBasicMaterial({'side': DoubleSide, 'color': self.d.c2h['black']})
        g = BufferGeometry()
        v = [0, 0, 0, clipBox.x, 0, 0, clipBox.y, 0, 0, 53, 0, 0,
             0, clipBox.z, 0, clipBox.x, clipBox.z, 0, clipBox.y, clipBox.z, 0,
             53, clipBox.z, 0,
             0, clipBox.w, 0, clipBox.x, clipBox.w, 0, clipBox.y, clipBox.w, 0,
             53, clipBox.w, 0,
             0, 37, 0, clipBox.x, 37, 0, clipBox.y, 37, 0, 53, 37, 0]
        i = [0, 1, 12, 12, 1, 13, 1, 2, 5, 5, 2, 6, 2, 3, 14, 14, 3, 15,
             9, 10, 13, 13, 10, 14]
        g.setIndex(i)
        g.setAttribute('position', Float32BufferAttribute(v, 3))
        mesh = Mesh(g, m)
        mesh.position.z = 98
        return mesh

    def _greenArrow(self, pts, axr=1.0):
        """Green pointer arrows, shared by the ADI-case gauges and the
        radar-alt pointer: green fill with the dark halo on the OUTSIDE only.
        Each vertex pulls in along its angle bisector by rim/sin(half-angle),
        so the rim runs constant-width along every edge."""
        # arrows scale about their TIP (pts[1] at every call site), so the
        # point keeps indicating the exact value position as the body grows
        tip = pts[1]
        pts = [[tip[0] + (p[0] - tip[0]) * GA_SCL, tip[1] + (p[1] - tip[1]) * GA_SCL]
               for p in pts]
        n = len(pts)
        inner = []
        for i in range(n):
            p = pts[i]
            a = pts[(i + n - 1) % n]
            b = pts[(i + 1) % n]
            d1 = [(a[0] - p[0]) * axr, a[1] - p[1]]
            l1 = math.hypot(d1[0], d1[1])
            d2 = [(b[0] - p[0]) * axr, b[1] - p[1]]
            l2 = math.hypot(d2[0], d2[1])
            d1 = [d1[0] / l1, d1[1] / l1]
            d2 = [d2[0] / l2, d2[1] / l2]
            bis = [d1[0] + d2[0], d1[1] + d2[1]]
            lb = math.hypot(bis[0], bis[1])
            cosT = d1[0] * d2[0] + d1[1] * d2[1]
            m = GA_RIM / max(0.1, math.sqrt(max(0.001, (1 - cosT) / 2)))
            inner.append([p[0] + bis[0] / lb * m / axr, p[1] + bis[1] / lb * m])
        g = Object3D()
        for pp, clr, ord_ in ((pts, self.d.c2h['black'], 2),
                              (inner, self.d.c2h['green'], 3)):
            t = self.d.tri(pp[0][0], pp[0][1], pp[1][0], pp[1][1],
                           pp[2][0], pp[2][1], None, clr)
            t.material.transparent = True
            t.renderOrder = ord_
            g.add(t)
        return g

    def _redTape(self, x0, y0, w, h, boxDy=0):
        """Invalid-data presentation: the tape keeps its window-frame and
        readout-box geometry but both render as empty red outlines."""
        g = Object3D()
        g.add(self.d.box(x0, y0, x0 + w, y0 + h, self.d.c2h['red']))
        bcy = y0 + h / 2 + boxDy
        g.add(self.d.box(x0, bcy - 0.85, x0 + w, bcy + 0.85, self.d.c2h['red']))
        return g

    def _altMarks(self, x0, w, entry):
        """Marks provider for the piecewise altitude tape: label/tick grids
        straight off ALT_SEGS."""
        C = self.d.c2h
        cx = x0 + w / 2

        def fmt(si, v):
            if si == 6:
                return "%dM" % jsround(v / NM_FT)
            if v >= 5000:
                return "%dK" % jsround(v / 1000)
            return "%d" % jsround(v)
        grayLbl = {'c': C['white'], 'border': C['black']}

        def marks(value):
            labels = {}
            for si, s in enumerate(ALT_SEGS):
                st = s[3]
                for k in crange(int(math.ceil((s[0] - 1) / st)),
                                int(math.floor((s[1] + 1) / st))):
                    v = k * st
                    if v < s[0] - 1 or v > s[1] + 1:
                        continue
                    labels[jsround(v)] = {'v': v, 'txt': fmt(si, v),
                                          'c': (grayLbl if v < 0 else C['black'])}
            ticks = []
            for s in ALT_SEGS:
                st = s[4]
                tw = s[5] * TAPE_IN_COLS
                if s[6] == 'l':
                    xa, xb = x0, x0 + tw               # left edge of the tape
                elif s[6] == 'r':
                    xa, xb = x0 + w - tw, x0 + w       # right edge
                else:
                    xa, xb = cx - tw / 2, cx + tw / 2  # centred
                for k in crange(int(math.ceil((s[0] - 1) / st)),
                                int(math.floor((s[1] + 1) / st))):
                    v = k * st
                    if v < s[0] - 1 or v > s[1] + 1 or labels.get(jsround(v)) is not None:
                        continue
                    ticks.append({'v': v, 'x0': xa, 'x1': xb, 'thin': v >= 0,
                                  'c': (grayLbl if v < 0 else None)})
            faces = [
                {'v0': ALT_MIN, 'v1': 0, 'fill': C['darkGray'], 'padLo': True},
                {'v0': 0, 'v1': 2000, 'fill': (C['yellow'] if entry else C['white'])},
                {'v0': 2000, 'v1': ALT_MAX, 'fill': C['white'], 'padHi': True},
            ]
            return {'faces': faces, 'labels': list(labels.values()), 'ticks': ticks}
        return marks

    def _hdotTape(self, x0, w):
        """Map + marks for the piecewise Hdot tape (odd-symmetric about 0):
        20-fps labels / 10-fps centre marks to +/-1000, then 500-fps labels /
        100-fps centre marks to +/-3000 at the compressed HD_SHI scale."""
        C = self.d.c2h

        def mp(v):
            a = abs(v)
            sg = -1 if v < 0 else 1
            return sg * (min(a, 1000) * HD_S + max(0, a - 1000) * HD_SHI)
        cx = x0 + w / 2

        def fmtK(v):
            return "%s%sK" % ('-' if v < 0 else '',
                              ("%.1f" % (abs(v) / 1000)).replace('.0', ''))

        def lclr(v):
            return C['black'] if v > 0 else {'c': C['white'], 'border': C['black']}

        def marks(value):
            labels = []
            ticks = []
            for v in crange(-980, 980, 20):
                labels.append({'v': v, 'txt': "%d" % v, 'c': lclr(v)})
            for a in crange(1000, HDOT_MAX, 500):
                labels.append({'v': a, 'txt': fmtK(a), 'c': lclr(a)})
                labels.append({'v': -a, 'txt': fmtK(-a), 'c': lclr(-a)})
            for v in crange(-990, 990, 10):
                if v % 20 != 0:
                    ticks.append({'v': v, 'x0': cx - 1, 'x1': cx + 1, 'c': lclr(v)})
            for a in crange(1100, HDOT_MAX, 100, False):
                if a % 500 != 0:
                    for v in (a, -a):
                        ticks.append({'v': v, 'x0': cx - 1, 'x1': cx + 1, 'c': lclr(v)})
            faces = [
                {'v0': -HDOT_MAX, 'v1': 0, 'fill': C['darkGray'], 'padLo': True},
                {'v0': 0, 'v1': HDOT_MAX, 'fill': C['white'], 'padHi': True},
            ]
            return {'faces': faces, 'labels': labels, 'ticks': ticks}
        return {'map': mp, 'marks': marks}

    def drawAVVI(self):
        """Altitude/Vertical Velocity Indicator: NAV-derived or barometric
        altitude in feet, and altitude rate in feet/second.  Invalid data is
        indicated when a tape is replaced by a blank red box."""
        avvi = Object3D()
        C = self.d.c2h
        avvi.add(self.d.str(43, 3.25, "H", C['darkGray'], 1, .9))
        hx0 = 40.75
        hy0 = 4.4
        hw = 4.75
        hh = 15.57
        alt = self.data().get('altitude') or 0
        entry = self.data()['majorMode'] in (304, 305, 602, 603)
        altValid = self.data().get('altValid')
        if altValid is None:
            altValid = True
        if altValid:
            ra = self.data().get('radarAlt')
            ra = -1 if ra is None else ra
            radarOK = bool(entry and self.data().get('radarValid') and 0 <= ra < 5000)
            # digital: same abbreviation + precision as the tape labels
            if radarOK:
                rdStr = "%d" % jsround(self.data()['radarAlt'])
            elif alt >= 400000:
                rdStr = "%dM" % jsround(alt / NM_FT)
            elif alt >= 5000:
                rdStr = "%dK" % jsround(alt / 1000)
            else:
                rdStr = "%d" % jsround(alt)
            hOpts = {'id': "avvi-h%s" % ('-e' if entry else ''), 'center': True,
                     'lblScale': 1.15, 'rdScale': 1.25, 'rdStr': rdStr,
                     'map': altMapRows, 'marks': self._altMarks(hx0, hw, entry)}
            # in the region where the radar 'R' may engage, pack the readout
            # digits tighter and to the left so they clear the R
            if entry and alt < 5000:
                hOpts['rdDx'] = -0.45
                hOpts['rdAdv'] = 0.85
            avvi.add(self.scrollTape(hx0, hy0, hw, hh, alt, 1, 0, hOpts))
            if radarOK:
                # light-grey 'R' at 3/4 readout size: right ink edge against
                # the tape border, vertically centred on the readout line
                rs = 1.25 * 0.75
                rg = self.d.strMEDS(hx0 + hw - 0.08 + 1 - 1.726 * rs,
                                    hy0 + hh / 2 - 0.33 * rs, "R", C['lightGray'], rs)
                rg.traverse(lambda o: setattr(o, 'renderOrder', 3) if o.isMesh else None)
                avvi.add(rg)
                # radar-altitude pointer, rides the tape's RIGHT edge pushed
                # outward, pointing left at the radar altitude on the NAV tape
                yR = hy0 + hh / 2 - (altMapRows(self.data()['radarAlt']) - altMapRows(alt))
                if hy0 + 0.2 < yR < hy0 + hh - 0.2:
                    xe = hx0 + hw
                    avvi.add(self._greenArrow(
                        [[xe + 0.96, yR - 0.6], [xe - 0.26, yR], [xe + 0.96, yR + 0.6]],
                        TAPE_IN_ROWS / TAPE_IN_COLS))
        else:
            avvi.add(self._redTape(hx0, hy0, hw, hh))

        # Altitude-rate (Hdot) piecewise scrolling tape
        px = 52.2425 / 1024                        # one display pixel in columns
        hdX = 47.4 - 3 * px
        hdW = 4.5 + 3 * px
        # title: 'H' overstruck with the DEU upper-centered-dot glyph to mark
        # the derivative; the deu glyph cell spans x-0.05..x+0.85 so the visual
        # centre sits at x+0.4
        for hc in ("H", u"˙"):
            avvi.add(self.d.str(hdX + hdW / 2 - 0.4, 3.25, hc, C['darkGray'], 1, .9))
        hdValid = self.data().get('hdotValid')
        if hdValid is None:
            hdValid = True
        if hdValid:
            hd = self._hdotTape(hdX, hdW)
            avvi.add(self.scrollTape(hdX, 4.4, hdW, HD_H, self.data()['hdot'], 20,
                                     HD_S,
                                     {'id': 'avvi-hdot', 'signed': True,
                                      'border': True, 'lblScale': HD_F,
                                      'center': True, 'advF': 0.75, 'rdScale': 1.3,
                                      'rdAdv': 1.0, 'rdLeadUp': PXY, 'rjust': True,
                                      'boxDy': -2 * PXY, 'map': hd['map'],
                                      'marks': hd['marks']}))
        else:
            avvi.add(self._redTape(hdX, 4.4, hdW, HD_H, -2 * PXY))
        return avvi

    def drawAccMeter(self, xc, yc, rad, mn, mx):
        """Vehicle Acceleration Meter (G-meter), PASS MM 102, 103, 304, 305,
        601, 602 & 603.  In powered flight the meter reflects IMU-derived
        vehicle acceleration and is labelled "Accel"; during glided flight it
        displays the RM selected AA NZ value and is labelled "Nz".  Range -1
        to 4 g."""
        self.accMeter = Object3D()
        self.accMeter.name = "accMeter"
        C = self.d.c2h
        mm = self.data()['majorMode']
        if mm not in (102, 103, 304, 305, 601, 602, 603):
            return None

        mat = C['darkGray']
        ASP = 1.47222        # d.arc/arcTicks' default row->col stretch
        # the circular scale -- and with it the needle's rotation centre --
        # rides 2px above and 2px left of the label reference centre
        xS = xc - 2 / 13.783
        yS = yc - 2 / 18.79

        def ang(v):
            # scale geometry: min (-1g) at 45 deg, max (4g) at 270, y-down
            return deg2rad(45 + (270 - 45) * (v - mn) / (mx - mn))

        def pt(v, r):
            a = ang(v)
            return [xS + r * math.cos(a) * ASP, yS + r * math.sin(a)]

        bx0 = xc + 0.60
        by0 = yc - 2.06
        bx1 = xc + 5.48
        by1 = yc - 0.41
        bcx = (bx0 + bx1) / 2

        # The scale is static per mode label -- built once, kept alive across
        # rebuilds; only the needle, target-NZ line and digital are per-update.
        key = 'accel' if mm in (102, 103) else 'nz'
        if self._accCache is None:
            self._accCache = {}
        if self._accCache.get(key) is None:
            sg = Object3D()
            sg.userData['keepAlive'] = True
            sg.add(self.d.arc(xS, yS, rad, 45, 270, mat))
            sg.add(self.d.arcTicks(xS, yS, rad, 45, 270, 45, .33, mat))
            # scale labels, individually photo-nudged off their nominal spots
            sg.add(self.d.strMEDS(xc - 0.23, yc + 3.09, "0", mat, 0.8, 0.9, 1.0))
            sg.add(self.d.strMEDS(xc - 3.92, yc + 1.96, "1", mat, 0.8, 0.9, 1.0))
            sg.add(self.d.strMEDS(xc - 5.42, yc - 0.40, "2", mat, 0.8, 0.9, 1.0))
            sg.add(self.d.strMEDS(xc - 3.92, yc - 3.02, "3", mat, 0.8, 0.9, 1.0))
            sg.add(self.d.strMEDS(xc + 3.07, yc + 2.20, "-1", mat, 0.8, 0.55, 1.0))
            sg.add(self.d.box(bx0, by0, bx1, by1, mat))
            sg.add(self.d.str(bx1 - 0.82, by0 + 0.29, "g", mat, .75, .75))
            if mm in (102, 103):
                sg.add(self.d.str(bcx - 1.9, by1 + 0.15, "Accel", mat, .75, .75))
            else:
                # small-caps z: the meds font has no lowercase.  The PAIR is
                # centred under the value box, small z bottom-aligned to the N.
                sg.add(self.d.str(bcx - 0.68, by1 + 0.20, "N", mat, .90, .90, 1.05))
                sg.add(self.d.str(bcx + 0.72, by1 + 0.45, "Z", mat, .65, .65))
            self._accCache[key] = sg
        self.accMeter.add(self._accCache[key])

        # MM 602 only: magenta target NZ line, from the hub out past the arc
        if mm == 602 and self.data().get('targetNZ') is not None:
            self.accMeter.add(self.d.line([pt(self.data()['targetNZ'], 0),
                                           pt(self.data()['targetNZ'], rad + 0.5)],
                                          C['magenta']))
        val = self.data().get('vehicleAcceleration')
        if val is not None:
            v = max(mn, min(mx, val))
            # green needle, no outline: one filled polygon -- a stem rectangle
            # plus the head triangle, its base 3px proud of the stem each side
            STEM_PX = 5
            a = ang(v)
            sw = (STEM_PX / 2) / 18.79
            hw = (STEM_PX / 2 + 4) / 18.79
            pxu = -math.sin(a) * ASP
            pyu = math.cos(a)                     # perpendicular direction
            c0 = pt(v, -0.15)     # tail runs past the pivot
            bb = pt(v, rad - 0.94)
            tp = pt(v, rad - 0.25)
            ageom = BufferGeometry()
            ageom.setAttribute('position', Float32BufferAttribute([
                c0[0] + pxu * sw, c0[1] + pyu * sw, 0,
                bb[0] + pxu * sw, bb[1] + pyu * sw, 0,
                bb[0] - pxu * sw, bb[1] - pyu * sw, 0,
                c0[0] - pxu * sw, c0[1] - pyu * sw, 0,
                bb[0] + pxu * hw, bb[1] + pyu * hw, 0,
                bb[0] - pxu * hw, bb[1] - pyu * hw, 0,
                tp[0], tp[1], 0], 3))
            ageom.setIndex([0, 1, 2, 0, 2, 3, 4, 6, 5])
            self.accMeter.add(Mesh(ageom, MeshBasicMaterial(
                {'color': C['green'], 'side': DoubleSide})))
            self.accMeter.add(self.d.strMEDS(bx0 + 0.10, by0 + 0.35,
                                             spad("%.1f" % val), C['white'], 1.2, .82))
        self.accMeter.position.y = 0.374   # shift acc meter down ~10px
        return self.accMeter

    # -----------------------------------------------------------------------
    # Attitude Determination Indicator (ADI)
    # -----------------------------------------------------------------------
    def drawADI(self, xc, yc, valid=True):
        self.adi = Object3D()
        self.adi.name = "ADI"
        C = self.d.c2h

        # ADI circular space: children of @adiC are authored in a circular
        # frame -- origin at the ball centre, BOTH axes in row units, so a
        # radius means the same thing in x and y and circles are round by
        # construction.  The group transform then stretches x.
        ADI_STRETCH = 1.08
        AX = 1.3632 * ADI_STRETCH
        self.adiC = Object3D()
        self.adiC.name = "ADIcircular"
        self.adiC.scale.x = AX
        self.adiC.position.set(xc, yc, 0)
        self.adi.add(self.adiC)

        # text in local coords with unstretched glyph shapes: undo AX on the
        # glyph geometry and on drawGlyph's baked-in x-1 origin offset
        def ltxt(lx, ly, s, color, scale=1.0, advance=0.62, scalex=1.0):
            return self.d.strMEDS(lx + 1 - 1 / AX, ly, s, color, scale,
                                  advance / AX, scalex / AX)
        self.adiLtxt = ltxt

        # Vehicle reference symbol -- fixed to the centre of the ADI window.
        VC = 2.85
        VTIP = 0.58     # horizontal half-span: wings + cross bar
        VCV = 2.55      # the vertical cross arm keeps its old reach
        varmB = VCV - (2.0 / 3) * VTIP - 0.15
        varmT = varmB + 0.15
        # error needle inner ends run a little short of the cross/arm tips
        NSET = 0.25
        self.adiNIN = VCV - (2.0 / 3) * VTIP + NSET     # pitch needle (right)
        self.adiNINv = self.adiNIN - 0.15               # yaw needle (bottom)
        self.adiNINtop = self.adiNINv + 0.15            # roll needle (top)
        gBorder = {'c': C['green'], 'border': C['black']}
        veh = Object3D()
        for ln in (self.d.line([[0, -varmT], [0, varmB]], gBorder),
                   self.d.line([[-(VC - VTIP), 0], [VC - VTIP, 0]], gBorder)):
            ln.children[0].renderOrder = 4   # black halo
            ln.children[1].renderOrder = 5   # green core
            veh.add(ln)
        # the 'U': filled half-annulus index bowl under the centre
        UR0 = 0.55
        UR1 = 0.95
        outer = []
        inner = []
        for a in range(0, 19):
            th = deg2rad(a * 10)
            outer.append([UR1 * math.cos(th), UR1 * math.sin(th)])
            inner.append([UR0 * math.cos(th), UR0 * math.sin(th)])
        uverts = []
        for i in range(18):
            uverts += [outer[i][0], outer[i][1], 0, outer[i + 1][0], outer[i + 1][1], 0,
                       inner[i + 1][0], inner[i + 1][1], 0]
            uverts += [outer[i][0], outer[i][1], 0, inner[i + 1][0], inner[i + 1][1], 0,
                       inner[i][0], inner[i][1], 0]
        ug = BufferGeometry()
        ug.setAttribute('position', Float32BufferAttribute(uverts, 3))
        ug.setIndex(list(range(len(uverts) // 3)))
        uGrp = Object3D()
        uGrp.add(Mesh(ug, MeshBasicMaterial({'color': C['green'], 'side': DoubleSide})))
        # thin dark outline so the joint against the cross bar stays subtle
        if self._uOutlineMat is None:
            self._uOutlineMat = makeSDFLineMaterial(
                self.d.sdfOpt({'color': C['black'], 'widthPx': 1.4}))
        om = Mesh(makeSDFLineGeometry(outer + list(reversed(inner)) + [outer[0]]),
                  self._uOutlineMat)
        om.frustumCulled = False
        om.renderOrder = 2
        uGrp.add(om)
        # wing bars: the U continues outward under the cross to the arm tips
        wingW = self.d.LINE_PX + 2.4
        if self._vthickMat is None:
            self._vthickMat = makeSDFLineMaterial(
                self.d.sdfOpt({'color': C['green'], 'widthPx': wingW}))
        if self._wingBMat is None:
            self._wingBMat = makeSDFLineMaterial(
                self.d.sdfOpt({'color': C['black'], 'widthPx': wingW + 1.8}))
        for s in (-1, 1):
            wgeom = makeSDFLineGeometry([[s * UR0, 0], [s * VC, 0]])
            for matw, order in ((self._wingBMat, 2), (self._vthickMat, 3)):
                m = Mesh(wgeom, matw)
                m.frustumCulled = False
                m.renderOrder = order
                uGrp.add(m)
        uGrp.position.z = -0.5    # under the cross
        veh.add(uGrp)
        self.adiC.add(veh)
        self.adiC.add(self.d.arc(0, 0, 8.13, 0, 360, C['lightGray'], 1))
        self.adiC.add(self.d.arc(0, 0, WIN_R, 0, 360, C['lightGray'], 1))
        self.adiC.add(self.d.arcTicks(0, 0, WIN_R, 0, 360, 5.0, .24, C['lightGray'], 1))
        # the 30 deg (long) roll ticks run slightly thicker than the 5 deg ones
        if self._rollTickMat is None:
            self._rollTickMat = makeSDFLineMaterial(self.d.sdfOpt(
                {'color': C['lightGray'], 'widthPx': self.d.LINE_PX + 1.2}))
        for a in range(0, 360, 30):
            ca = math.cos(deg2rad(a))
            sa = math.sin(deg2rad(a))
            mt = Mesh(makeSDFLineGeometry([[WIN_R * ca, WIN_R * sa],
                                           [(WIN_R + 0.6) * ca, (WIN_R + 0.6) * sa]]),
                      self._rollTickMat)
            mt.frustumCulled = False
            self.adiC.add(mt)

        # Roll labels around the outer ring, in ADI-local circular coords
        outerLabels = [
            [6.05, 3.71, "24"], [3.82, 5.93, "21"], [-4.54, 5.92, "15"],
            [-6.73, 3.70, "12"], [-6.66, -4.33, "06"], [-4.57, -6.57, "03"],
            [3.73, -6.61, "33"], [5.99, -4.36, "30"],
        ]
        for x, y, l in outerLabels:
            self.adiC.add(ltxt(x, y, l, C['lightGray'], 0.85, 0.7, 1.0))

        # Roll index marks: equal diamonds at the 0/90/180/270 roll positions
        for ux, uy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            self.adiC.add(self.d.quad([
                6.77 * ux, 6.77 * uy, 0.0,
                7.26 * ux - 0.42 * uy, 7.26 * uy + 0.42 * ux, 0.0,
                7.95 * ux, 7.95 * uy, 0.0,
                7.26 * ux + 0.42 * uy, 7.26 * uy - 0.42 * ux, 0.0],
                UNDEF, C['lightGray']))

        # error scales: magenta arcs +/-25 deg about the top (roll), right
        # (pitch) and bottom (yaw) cardinals; short uniform ticks every 5 deg.
        errScl = Object3D()
        errScl.position.z = -0.5
        mScl = {'c': C['magenta'], 'border': C['black']}

        def reorder(o):
            o.children[0].renderOrder = -2   # border
            o.children[1].renderOrder = -1   # core
            return o
        for base, tkx, tky in ((270, 0, 1), (90, 0, -1), (0, -1, 0)):
            errScl.add(reorder(self.d.arc(0, 0, ERR_R, base - 25, base + 25, mScl, 1)))
            for a in crange(base - 25, base + 25, 5):
                ca = math.cos(deg2rad(a))
                sa = math.sin(deg2rad(a))
                errScl.add(reorder(self.d.line(
                    [[ERR_R * ca, ERR_R * sa],
                     [ERR_R * ca + 0.28 * tkx, ERR_R * sa + 0.28 * tky]], mScl)))
        self.adiC.add(errScl)
        # TAEM (MM 305/603): the pitch error scale reads in g's
        if self.data()['majorMode'] in (305, 603):
            sy = ERR_R * math.sin(deg2rad(25))
            self.adiC.add(ltxt(7.05, -sy - 0.74 * 0.8 - 0.05, "1.2g", C['magenta'],
                               0.8, 0.7, 1.0))
            self.adiC.add(ltxt(7.05, sy - 0.08 * 0.8 + 0.05, "1.2g", C['magenta'],
                               0.8, 0.7, 1.0))

        # ADI rate-needle '0' and '5' scale labels
        self.adiC.add(ltxt(-0.11, -9.88, "0", C['darkGray'], 0.85))
        self.adiC.add(ltxt(-0.11, 9.37, "0", C['darkGray'], 0.85))
        self.adiC.add(ltxt(9.55, -0.28, "0", C['darkGray'], 0.85))
        self.adiC.add(ltxt(-6.42, -9.10, "5", C['white'], 0.85, 0.62, 1.18))
        self.adiC.add(ltxt(-6.51, 8.48, "5", C['white'], 0.85, 0.62, 1.18))
        self.adiC.add(ltxt(8.27, -6.83, "5", C['white'], 0.85, 0.62, 1.18))
        self.adiC.add(ltxt(6.03, -9.10, "5", C['white'], 0.85, 0.62, 1.18))
        self.adiC.add(ltxt(6.06, 8.48, "5", C['white'], 0.85, 0.62, 1.18))
        self.adiC.add(ltxt(8.27, 6.30, "5", C['white'], 0.85, 0.62, 1.18))

        # the ball itself: static geometry, rotated per attitude by updateADI()
        self.adiC.add(self.adiBall())
        self.adi.position.y = 0.374   # shift ADI down ~10px
        self.updateADI()
        return self.adi

    def adiBall(self):
        g = Object3D()
        g.name = "adiBall"
        # rotor: everything painted on the ball; updateADI() sets its rotation
        self.adiBallRot = Object3D()
        self.adiBallRot.add(self._ballFills())
        self.adiBallRot.add(self._ballMarkMeshes(self._ballMarks()))
        g.add(self.adiBallRot)
        # circular window: opaque background-colour ring just behind the case
        # plane depth-masks the ball outside r 6.6
        mask = Mesh(RingGeometry(WIN_R, 50, 100),
                    MeshBasicMaterial({'side': DoubleSide, 'color': self.d.c2h['black']}))
        mask.position.z = 9.99
        g.add(mask)
        g.position.z = -10
        return g

    def _ballFills(self):
        """Hemisphere fills: white pitch 0..180, grey 180..360, smooth
        horizon.  White cut-out tabs sit just below the front horizon around
        each pitch-0 label position."""
        white = []
        gray = []

        def quad(arr, p0, p1, w0, w1, r=BALL_R):
            a = ballPt(p0, w0, r)
            b = ballPt(p0, w1, r)
            c = ballPt(p1, w1, r)
            e = ballPt(p1, w0, r)
            arr += a + b + c
            arr += a + c + e

        def band(arr, pa, pb, w0, w1, r=BALL_R):
            n = max(1, int(math.ceil((pb - pa) / 7.5)))
            for i in range(n):
                quad(arr, pa + (pb - pa) * i / n, pa + (pb - pa) * (i + 1) / n,
                     w0, w1, r)
        for j in range(jsround(180 / COL_W)):
            w0 = -90 + j * COL_W
            # grey pulled back ~a stroke width (0.5 deg) from the nominal
            # horizon at both boundaries; white extends underneath
            band(white, -0.5, 180.5, w0, w0 + COL_W)
            band(gray, 180.5, 359.5, w0, w0 + COL_W)
        # cut-outs: '0'-label height tall, ~3 label-widths wide
        CUT_H = 4.5
        CUT_W = 7.0
        for wc in (-45, -15, 15, 45):
            for wa, wb in ((wc - CUT_W / 2, wc), (wc, wc + CUT_W / 2)):
                band(white, 359.5 - CUT_H, 359.5, wa, wb, BALL_R + 0.03)
        g = Object3D()
        for arr, c in ((white, self.d.c2h['white']), (gray, self.d.c2h['darkGray'])):
            geom = BufferGeometry()
            geom.setAttribute('position', Float32BufferAttribute(arr, 3))
            geom.setIndex(list(range(len(arr) // 3)))
            g.add(Mesh(geom, MeshBasicMaterial({'color': c, 'side': DoubleSide})))
        return g

    def _ballMarks(self):
        """Ball markings, batched into a few polyline buckets by colour:
        w  - white strokes on the grey hemisphere
        d  - grey strokes on the white hemisphere
        dt - grey labels on the white hemisphere (d's colour, text's width)
        wb - white with dark halo (labels on grey / straddling a horizon)"""
        b = {'w': [], 'd': [], 'dt': [], 'wb': []}

        def onWhite(pp):
            pp = ((pp % 360) + 360) % 360
            return 0 < pp < 180

        def mseg(p, wa, wb_):
            n = max(1, int(math.ceil((wb_ - wa) / 5)))
            return [ballPt(p, wa + (wb_ - wa) * i / n, LINE_R) for i in range(n + 1)]

        def cseg(w, pa, pb):
            n = max(1, int(math.ceil((pb - pa) / 5)))
            return [ballPt(pa + (pb - pa) * i / n, w, LINE_R) for i in range(n + 1)]

        # label clearance: solid lines break around the painted numbers
        def lgapW(s):
            return (((len(s) - 1) * LBL_ADV + 0.72) / 2) * LBL_DEG * LBL_SX + 1.8
        LGAP = 0.41 * LBL_DEG + 1.8      # label half-height + margin, deg pitch

        # pitch great circles every 30 deg (0/180 are shown by the horizon
        # boundary), broken around their labels at yaw +/-15 and +/-45
        for p in crange(30, 330, 30):
            if p == 180:
                continue
            key = 'd' if onWhite(p) else 'w'
            gp = lgapW(_numstr(p / 10))
            for s0, s1 in ((-85, -45 - gp), (-45 + gp, -15 - gp), (-15 + gp, 15 - gp),
                           (15 + gp, 45 - gp), (45 + gp, 85)):
                b[key].append(mseg(p, s0, s1))

        # yaw circle runs, split at the horizons so each hemisphere gets its
        # contrasting colour
        def pushC(w, pa, pb):
            cuts = [pa]
            for c in (180, 360):
                if pa < c < pb:
                    cuts.append(c)
            cuts.append(pb)
            for i in range(len(cuts) - 1):
                bk = 'd' if onWhite((cuts[i] + cuts[i + 1]) / 2) else 'w'
                b[bk].append(cseg(w, cuts[i], cuts[i + 1]))

        # belly band (three lines) runs unbroken
        for w in (-1.3, 0, 1.3):
            pushC(w, 0, 360)
        # latitude rings framing the pole caps
        for w in (-75, 75, -85, 85):
            pushC(w, 0, 360)
        # short ticks on the equator side of the +/-75 ring, every 10 deg of
        # pitch; the horizon rows ride the exposed white strip so they stay dark
        POLE_TICK = 2.0
        for p in range(0, 360, 10):
            key = 'd' if (onWhite(p) or p % 180 == 0) else 'w'
            b[key].append([ballPt(p, 75 - POLE_TICK, LINE_R), ballPt(p, 75, LINE_R)])
            b[key].append([ballPt(p, -75, LINE_R), ballPt(p, -75 + POLE_TICK, LINE_R)])
        # between the rings, a single abbreviated tick marks each dashed-row
        # meridian (pitch 15+30k) that isn't drawn out there
        MID_TICK = 1.0
        for pb in crange(0, 330, 30):
            pp = pb + 15
            key = 'd' if onWhite(pp) else 'w'
            for s in (-1, 1):
                b[key].append([ballPt(pp - MID_TICK, s * 80, LINE_R),
                               ballPt(pp + MID_TICK, s * 80, LINE_R)])
        for w in (-60, -30, 30, 60):
            gy = LGAP / math.cos(deg2rad(w))
            for k in range(12):
                pushC(w, 15 + 30 * k + gy, 45 + 30 * k - gy)
        # minor grid, drawn as perpendicular tick series, one dashed line
        # centred in every gap between solid lines
        TICK = 1.6         # latitude-column tick half-length, deg
        LTICK = 1.45       # dashed-longitude (row) tick half-length, deg
        BELLY_T = 2.34     # belly tick half-length (long rows double it)
        for pb in crange(0, 330, 30):
            for dp in crange(5, 25, 5):
                pp = pb + dp
                key = 'd' if onWhite(pp) else 'w'
                # pp 355 would sit right under the '0' cut-out tabs -- skip it
                if pp != 355:
                    for ww in (-45, -15, 15, 45):
                        b[key].append([ballPt(pp, ww - TICK, LINE_R),
                                       ballPt(pp, ww + TICK, LINE_R)])
                # belly ticks run wider than the grid ticks
                tl = (2 if dp % 10 == 0 else 1) * BELLY_T
                b[key].append([ballPt(pp, -tl, LINE_R), ballPt(pp, -1.3, LINE_R)])
                b[key].append([ballPt(pp, 1.3, LINE_R), ballPt(pp, tl, LINE_R)])
            pp = pb + 15
            key = 'd' if onWhite(pp) else 'w'
            # tick rows run out to the +/-75 ring (last tick at +/-70)
            for j in crange(-14, 14):
                if j != 0 and (j * 5) % 30 != 0:
                    b[key].append([ballPt(pp - LTICK, j * 5, LINE_R),
                                   ballPt(pp + LTICK, j * 5, LINE_R)])
        # horizon gauge ticks between the '33' and '3' circles
        for j in crange(1, 5):
            hlen = 3.4 if j % 2 == 0 else 2.2
            for ww in (-j * 5, j * 5):
                b['d'].append([ballPt(-0.5, ww, LINE_R), ballPt(hlen, ww, LINE_R)])
                b['d'].append([ballPt(180 - hlen, ww, LINE_R),
                               ballPt(180.5, ww, LINE_R)])
        # the horizon rows carry a long belly tick too
        for pp in (0, 180):
            b['d'].append([ballPt(pp, -2 * BELLY_T, LINE_R), ballPt(pp, -1.3, LINE_R)])
            b['d'].append([ballPt(pp, 1.3, LINE_R), ballPt(pp, 2 * BELLY_T, LINE_R)])

        # labels: angle magnitudes with the trailing zero deleted
        def lbl(p, w, s):
            self._ballText(b['dt' if onWhite(p) else 'wb'], p, w, s)
        for p in crange(0, 330, 30):
            for w in (-45, -15, 15, 45):
                if p == 0:
                    # the '0' rides just below the horizon, grey, inside its
                    # white cut-out tab; the near-pole pair lifts further
                    lift = ZERO_LIFT if abs(w) == 45 else 0
                    self._ballText(b['dt'], -2.8 + lift, w, "0")
                else:
                    lbl(p, w, _numstr(p / 10))
        for w, s in ((30, "3"), (60, "6"), (-30, "33"), (-60, "30")):
            for k in range(12):
                lbl(15 + k * 30, w, s)
        return b

    def _ballText(self, out, p, w, s):
        """Paint `s` onto the ball surface at pitch p / yaw w: meds-font
        strokes -> degrees of arc -> tangent-plane offsets at (p,w),
        renormalised back onto the marking radius."""
        n = len(s)
        cp = math.cos(deg2rad(p))
        sp = math.sin(deg2rad(p))
        cw = math.cos(deg2rad(w))
        sw = math.sin(deg2rad(w))
        sc = [sw, -cw * sp, cw * cp]         # unit surface point
        ew = [cw, sw * sp, -sw * cp]         # +yaw tangent (screen right)
        ep = [0, -cp, -sp]                   # +pitch tangent (screen up)
        for k, c in enumerate(s):
            for stroke in (self.d.medsFont.chars.get(c) or []):
                pl = []
                for gx, gy in stroke:
                    du = deg2rad((gx + k * LBL_ADV - (PFD_GXC + (n - 1) * LBL_ADV / 2))
                                 * LBL_DEG * LBL_SX)
                    dv = deg2rad((gy - PFD_GYC) * LBL_DEG)
                    vx = sc[0] + du * ew[0] - dv * ep[0]
                    vy = sc[1] + du * ew[1] - dv * ep[1]
                    vz = sc[2] + du * ew[2] - dv * ep[2]
                    m = LINE_R / math.hypot(vx, vy, vz)
                    pl.append([vx * m, vy * m, vz * m])
                out.append(pl)

    def _ballMarkMeshes(self, b):
        """One draw call per colour bucket (the border'd bucket gets two).
        Negative renderOrder keeps the transparent ball strokes underneath the
        needles and case symbology drawn at order >= 0."""
        g = Object3D()

        def mk(geom, mat, order):
            m = Mesh(geom, mat)
            m.frustumCulled = False
            m.renderOrder = order
            g.add(m)
        if b['w']:
            mk(makeSDFLinesGeometry(b['w']), self.d.mats[0][self.d.c2h['white']], -1)
        if b['d']:
            mk(makeSDFLinesGeometry(b['d']), self.d.mats[0][self.d.c2h['darkGray']], -1)
        # the labels: made after `d`, so at the default width they draw in
        # the same order as when they were the tail of that bucket
        ts = self.d.TEXT_STROKE
        if b['dt']:
            mk(makeSDFLinesGeometry(b['dt']),
               self.d.solidMat(self.d.c2h['darkGray'], ts), -1)
        if b['wb']:
            geom = makeSDFLinesGeometry(b['wb'])
            if self._ballBMat is None:
                self._ballBMat = makeSDFLineMaterial(self.d.sdfOpt(
                    {'color': self.d.c2h['black'],
                     'widthPx': self.d.LINE_PX * ts + 2.5}))
            mk(geom, self._ballBMat, -2)
            mk(geom, self.d.solidMat(self.d.c2h['white'], ts), -1)
        return g

    def updateADI(self):
        """Re-derive every data-driven ADI element.  The ball geometry is
        static; attitude only updates the rotor's rotation."""
        if self.adi is None:
            return
        d = self.data()
        # ADI OFF mode (curData.adiValid = False): the ball locks at its last
        # driven orientation, the needles and rate pointers stow, the digital
        # readout blanks, and the red OFF flag shows at the left of the case.
        valid = d.get('adiValid')
        if valid is None:
            valid = True
        if valid:
            r, p, y = self._adiProtect(d.get('adiRol') or 0, d.get('adiPch') or 0,
                                       d.get('adiYaw') or 0)
            self._adiLast = [r, p, y]
            # The ball turns opposite the causative rotation (fly-to
            # indicator), composed as Rz(-R).Ry(-Y).Rx(-P) = 'ZYX' Euler with
            # angles (-P,-Y,-R).  This is the order that keeps the marking at
            # the ball's front centre equal to the vehicle's current (pitch,
            # yaw) at ANY attitude.
            if self.adiBallRot is not None:
                self.adiBallRot.rotation.set(deg2rad(-p), deg2rad(-y), deg2rad(-r), 'ZYX')
        else:
            # static ball: rotation untouched; overlays use the last attitude
            r, p, y = self._adiLast or [0, 0, 0]
        if self._adiDynC is not None:
            self.adiC.remove(self._adiDynC)
            self._disposeGroup(self._adiDynC)
        if self._adiDynS is not None:
            self.adi.remove(self._adiDynS)
            self._disposeGroup(self._adiDynS)
        self._adiDynC = self._drawADIDyn(r, p, y, valid)
        self.adiC.add(self._adiDynC)
        self._adiDynS = self.drawADIDigitals(r, p, y, valid)
        self.adi.add(self._adiDynS)
        self.d.dirty = True

    def _adiProtect(self, r, p, y):
        """PYR-gimballed ADIs coalign the pitch and roll axes at yaw 90/270;
        the attitude processor protects the region by freezing roll and pitch
        while yaw is within +/-1.7 deg of either singularity."""
        def wrap(v):
            return ((v % 360) + 360) % 360
        r = wrap(r)
        p = wrap(p)
        y = wrap(y)
        if abs(y - 90) < 1.7 or abs(y - 270) < 1.7:
            if self._adiFrz is not None:
                r, p = self._adiFrz
        else:
            self._adiFrz = [r, p]
        return [r, p, y]

    def _drawADIDyn(self, r, p, y, valid=True):
        """Dynamic overlay in ADI circular space: roll bug, attitude error
        needles, rate pointers (with their scales)."""
        d = self.data()
        C = self.d.c2h
        g = Object3D()
        g.name = "ADIdyn"
        # roll bug: reads the case roll scale, counterclockwise from 0 at top,
        # driven with respect to the MDU regardless of ball orientation.
        # Geometry built once at roll 0 and rotated into place per update.
        if self._adiBugG is None:
            a0 = deg2rad(270)
            ca = math.cos(a0)
            sa = math.sin(a0)
            pts = [[rad * ca - tg * sa, rad * sa + tg * ca]
                   for rad, tg in ((WIN_R, 0), (WIN_R - 0.58, 0.40),
                                   (WIN_R - 0.72, 0.22), (WIN_R - 0.72, -0.22),
                                   (WIN_R - 0.58, -0.40))]
            self._adiBugG = Object3D()
            self._adiBugG.userData['keepAlive'] = True
            self._adiBugG.add(self.d.polyFill(pts, C['green']))
            if self._uOutlineMat is None:
                self._uOutlineMat = makeSDFLineMaterial(
                    self.d.sdfOpt({'color': C['black'], 'widthPx': 1.4}))
            bm = Mesh(makeSDFLineGeometry(pts + [pts[0]]), self._uOutlineMat)
            bm.frustumCulled = False
            self._adiBugG.add(bm)
        self._adiBugG.rotation.z = deg2rad(-r)
        g.add(self._adiBugG)
        if valid:
            # attitude error needles: fly-to, +/-5 (MED scale) full range
            fs = ERR_R * math.sin(deg2rad(25))

            def defl(e):
                return fs * max(-1, min(1, (e or 0) / 5))
            if self._ndlMats is None:
                self._ndlMats = [
                    makeSDFLineMaterial(self.d.sdfOpt(
                        {'color': C['black'],
                         'widthPx': 1.5 * (self.d.LINE_PX + 0.8) + 1.8})),
                    makeSDFLineMaterial(self.d.sdfOpt(
                        {'color': C['magenta'], 'widthPx': 1.5 * (self.d.LINE_PX + 0.8)}))]

            def nd(p0, p1):
                gg = Object3D()
                geom = makeSDFLineGeometry([p0, p1])
                for mat, order in ((self._ndlMats[0], 0), (self._ndlMats[1], 1)):
                    m = Mesh(geom, mat)
                    m.frustumCulled = False
                    m.renderOrder = order
                    gg.add(m)
                gg.position.z = -0.2
                return gg
            # outer end pulls EOUT inside the curved scale arc
            EOUT = 0.15
            nin = self.adiNIN if self.adiNIN is not None else 2.16
            ninV = self.adiNINv if self.adiNINv is not None else 2.0
            ninT = self.adiNINtop if self.adiNINtop is not None else 2.15
            xr = defl(d.get('adiRolErr'))            # top:    + error -> right
            g.add(nd([xr, -math.sqrt(ERR_R ** 2 - xr * xr) + EOUT], [xr, -ninT]))
            yp = -defl(d.get('adiPchErr'))           # right:  + error -> up
            g.add(nd([math.sqrt(ERR_R ** 2 - yp * yp) - EOUT, yp], [nin, yp]))
            xy = defl(d.get('adiYawErr'))            # bottom: + error -> right
            g.add(nd([xy, math.sqrt(ERR_R ** 2 - xy * xy) - EOUT], [xy, ninV]))
        # rate pointers, -5..+5 onto the fixed scales; they stow when invalid
        rolV = (d['adiRolRate'] + 5) if (valid and d.get('adiRolRate') is not None) else None
        yawV = (d['adiYawRate'] + 5) if (valid and d.get('adiYawRate') is not None) else None
        pchV = (10 - (d['adiPchRate'] + 5)) if (valid and d.get('adiPchRate') is not None) else None
        # scales built once, kept alive; only the pointer arrows rebuild
        if self._adiRateScales is None:
            s = Object3D()
            s.userData['keepAlive'] = True
            s.add(self.drawHorizGauge(None, "5", "0", "5", -5.81, 5.88, -9.1,
                                      .55, .55, 10, False))
            s.add(self.drawHorizGauge(None, "5", "0", "5", -5.81, 5.88, 9.15,
                                      .55, .55, 10))
            s.add(self.drawVertGauge(None, "5", "0", "5", -5.95, 5.95, 9.13,
                                     .41, .41, 10))
            self._adiRateScales = s
        g.add(self._adiRateScales)
        g.add(self.drawHorizGauge(rolV, "5", "0", "5", -5.81, 5.88, -9.1,
                                  .55, .55, 10, False, True))
        g.add(self.drawHorizGauge(yawV, "5", "0", "5", -5.81, 5.88, 9.15,
                                  .55, .55, 10, True, True))
        g.add(self.drawVertGauge(pchV, "5", "0", "5", -5.95, 5.95, 9.13,
                                 .41, .41, 10, True, True))
        if not valid:
            # ADI OFF Flag -- a remnant of the mechanical dedicated displays:
            # valid GPC data is not driving the ADI; red flag at the left of
            # the case between the rings.
            fb = self.d.box(-7.81, -2, -6.96, 2, None, C['red'])

            def _fbSet(o):
                if getattr(o, 'material', None) is not None:
                    o.material.transparent = True
                    o.renderOrder = 3
            fb.traverse(_fbSet)
            g.add(fb)
            for ty, ch in ((-1.75, "O"), (-.45, "F"), (.75, "F")):
                t = self.adiLtxt(-7.64, ty, ch, C['black'])

                def _tSet(o):
                    if getattr(o, 'material', None) is not None:
                        o.renderOrder = 4
                t.traverse(_tSet)
                g.add(t)
        return g

    def drawHSI(self, xc, yc):
        """Horizontal Situation Indicator -- the compass card ring."""
        C = self.d.c2h
        hsiGroup = Object3D()
        hsiGroup.name = "HSI"
        ringGroup = Object3D()
        ringGroup.name = "HSI_ring"
        c = [25, 30.75]
        ringGroup.add(self.d.arc(c[0], c[1], 7.3, 0, 360))
        ringGroup.add(self.d.arc(c[0], c[1], 6.6, 0, 360, C['white']))
        ringGroup.add(self.d.arc(c[0], c[1], 4.4, 0, 360, C['white']))
        ringGroup.add(self.d.arcTicks(c[0], c[1], 6.6, 0, 360, 5, -.4, C['white']))
        ringGroup.add(self.d.arcTicks(c[0], c[1], 6.6, 0, 360, 10, -.6, C['white']))
        ringGroup.position.z = -2
        hsiGroup.add(ringGroup)

        ring = RingGeometry(4.4, 6.6, 100)
        ringMat = MeshBasicMaterial({'side': DoubleSide, 'color': C['darkGray']})
        mRing = Mesh(ring, ringMat)
        mRing.scale.x = 1.47222
        mRing.position.x = c[0]
        mRing.position.y = c[1]
        mRing.position.z = 0
        hsiGroup.add(mRing)

        # Menu area mask: must sit strictly between the HSI lines (~97.999)
        # and the menu content (~100).  SDF lines are transparent (drawn after
        # opaque), so only the depth test can mask them.
        menuMask = PlaneGeometry(52, 5)
        matMenuMask = MeshBasicMaterial({'side': DoubleSide, 'color': C['black']})
        mMenuMask = Mesh(menuMask, matMenuMask)
        mMenuMask.position.x = 25.5
        mMenuMask.position.y = 34.5
        mMenuMask.position.z = 99
        hsiGroup.add(mMenuMask)
        hsiGroup.position.z = -.001
        hsiGroup.position.y = 0.374   # shift HSI down ~10px
        return hsiGroup

    def drawADIDigitals(self, r=None, p=None, y=None, valid=True):
        """Digital attitude readout, R/P/Y order (FDF convention, not the PYR
        Euler sequence)."""
        C = self.d.c2h
        if r is None:
            r = self.data()['adiRol']
        if p is None:
            p = self.data()['adiPch']
        if y is None:
            y = self.data()['adiYaw']

        def wrap(v):
            return (jsround(v or 0) % 360 + 360) % 360
        group = Object3D()
        group.add(self.d.strMEDS(36.65, 1.7, "R", C['darkGray'], 0.85, .85, 0.85))
        group.add(self.d.strMEDS(36.65, 2.7, "P", C['darkGray'], 0.85, .85, 0.85))
        group.add(self.d.strMEDS(36.65, 3.7, "Y", C['darkGray'], 0.85, .85, 0.85))
        if valid:   # value fields blank in OFF mode
            group.add(self.d.strMEDS(37.80, 1.7, zpad(wrap(r)), C['white'], 0.85, .71))
            group.add(self.d.strMEDS(37.80, 2.7, zpad(wrap(p)), C['white'], 0.85, .71))
            group.add(self.d.strMEDS(37.80, 3.7, zpad(wrap(y)), C['white'], 0.85, .71))
        return group

    def drawAttAcc(self, x0=None, y0=None):
        pass

    def drawGSI(self, x0=None, y0=None):
        self.d.add(self.d.box(45, 20.874, 46.75, 31.374, self.d.c2h['darkGray']))

    def drawRange(self):
        C = self.d.c2h
        self.d.add(self.d.strMEDS(39, 26.634, "PRI", C['darkGray'], 1.0, .95))
        self.d.add(self.d.box(38.5, 27.674, 41.75, 28.674, C['darkGray']))
        self.d.add(self.d.strMEDS(39, 29.374, "SEC", C['darkGray'], 1.0, .95))
        self.d.add(self.d.box(38.5, 30.374, 41.75, 31.424, C['darkGray']))

    def drawHorizGauge(self, value, rangeMin, rangeMid, rangeMax, tickLeft,
                       tickRight, tickBot, sLen, lLen, count, top=True,
                       pointerOnly=False):
        C = self.d.c2h
        gauge = Object3D()
        if top:
            sTickTop = tickBot - sLen
            lTickTop = tickBot - lLen
            eTickTop = tickBot - 1.3 * lLen
            tTickBot = tickBot + .5 + .6
            tTickTop = tickBot - .7 + .6
        else:
            sTickTop = tickBot + sLen
            lTickTop = tickBot + lLen
            eTickTop = tickBot + 1.3 * lLen
            tTickBot = tickBot - .5 - .6
            tTickTop = tickBot + .7 - .6
        scaleLen = tickRight - tickLeft
        if not pointerOnly:
            gauge.add(self.d.line([[tickLeft, tickBot], [tickRight, tickBot]],
                                  C['darkGray']))
            for i in range(count + 1):
                x = i * (scaleLen / count)
                # end and centre ('0') ticks run slightly longer
                if i == 0 or i == count or i * 2 == count:
                    x2 = eTickTop
                elif i % 2:
                    x2 = sTickTop
                else:
                    x2 = lTickTop
                gauge.add(self.d.line([[tickLeft + x, tickBot], [tickLeft + x, x2]],
                                      C['darkGray']))
        if value is not None:
            x = tickLeft + (value * (scaleLen / count))
            # x half-width .61 = .9 cols unstretched (drawn inside adiC)
            gauge.add(self._greenArrow([[x - .61, tTickBot], [x, tTickTop],
                                        [x + .61, tTickBot]], 1.08))
        return gauge

    def drawVertGauge(self, value, rangeMin, rangeMid, rangeMax, tickTop,
                      tickBot, tickLeft, sLen, lLen, count, left=True,
                      pointerOnly=False):
        C = self.d.c2h
        gauge = Object3D()
        # pointer x offsets in unstretched (row) units (drawn inside adiC)
        if left:
            sTickRight = tickLeft - sLen
            lTickRight = tickLeft - lLen
            eTickRight = tickLeft - 1.3 * lLen
            tTickLeft = tickLeft + .51 + .48
            tTickRight = tickLeft - .58 + .48
        else:
            sTickRight = tickLeft + sLen
            lTickRight = tickLeft + lLen
            eTickRight = tickLeft + 1.3 * lLen
            tTickLeft = tickLeft - .51 - .48
            tTickRight = tickLeft + .58 - .48
        scaleLen = tickBot - tickTop
        if not pointerOnly:
            gauge.add(self.d.line([[tickLeft, tickTop], [tickLeft, tickBot]],
                                  C['darkGray']))
            for i in range(count + 1):
                x = i * (scaleLen / count)
                if i == 0 or i == count or i * 2 == count:
                    x2 = eTickRight
                elif i % 2:
                    x2 = sTickRight
                else:
                    x2 = lTickRight
                gauge.add(self.d.line([[tickLeft, tickTop + x], [x2, tickTop + x]],
                                      C['darkGray']))
        if value is not None:
            x = tickTop + (value * (scaleLen / count))
            gauge.add(self._greenArrow([[tTickLeft, x - .6], [tTickRight, x],
                                        [tTickLeft, x + .6]], 1.08))
        return gauge


class Screen_ORBIT_PFD(Screen_AE_PFD):
    pass


# ===========================================================================
# meds/mduMenuArea.coffee -- the MEDS generic screen format
#
# USA-007587/p.250: the top portion of the screen is the MEDS display format;
# the lower portion carries the MEDS internal configuration information, with
# a horizontal cyan line between them.  At the bottom the legends for the
# edgekeys sit in six boxes aligned with their respective edgekeys.  The menu
# title is displayed above the edgekey boxes; the MEDS fault message line is
# the line above the menu title.
# ===========================================================================

class MDUMenuArea(object):
    def __init__(self, d, CONFIG=None):
        self.d = d
        self.CONFIG = CONFIG or {}
        self.menuItemTxt = [None] * 6
        self.edgekeyFailed = [False] * 6
        self.activeMenuItem = None
        self.currentMenu = None
        self.faultLineMsg = ""
        self.faultLineBlink = None
        self.priPortIDP = None
        self.secPortIDP = None
        self.cmdPort = None
        self.flightCritBus = None
        self.portReconfigureModeAuto = None
        self.modNegView = None
        self.modeNegView = None
        self.mduModeNegView = None
        self.curIDP = None
        self.menuTitle = None
        self.group = None

    def setData(self, data):
        self.data = data
        self.priPortIDP = data['priPortIDP']
        self.secPortIDP = data['secPortIDP']
        self.cmdPort = data['cmdPort']
        self.flightCritBus = data['flightCritBus']
        self.portReconfigureModeAuto = data['portReconfigureModeAuto']
        self.modNegView = data.get('modeNegView')
        self.faultLineMsg = data['faultLineMsg']
        self.curIDP = data['curIDP']

    def setFaultLine(self, msg, blink=True):
        if msg != self.faultLineMsg or blink != self.faultLineBlink:
            self.group.remove(self.faultLine)
            self.faultLineMsg = msg
            self.faultLineBlink = blink
            # TODO: implement blink support for fault line text
            color = self.d.c2h['white']
            self.faultLine = self.d.str(3, 32, self.faultLineMsg, color, 1, .9)
            self.group.add(self.faultLine)
            self.d.dirty = True

    def setCurPort(self, newCmdPort):
        if newCmdPort != self.cmdPort:
            self.cmdPort = newCmdPort
            self.mduStatGrp.remove(self.curIDPStarP)
            self.mduStatGrp.remove(self.curIDPStarS)
            if self.cmdPort == 0:
                self.mduStatGrp.add(self.curIDPStarP)
            elif self.cmdPort == 1:
                self.mduStatGrp.add(self.curIDPStarS)
            self.d.dirty = True

    def _drawFCBusLabel(self):
        """Single draw path for the FC bus status label -- build() and later
        bus changes must render identically."""
        if self.FCBusLabel is not None:
            self.mduStatGrp.remove(self.FCBusLabel)
            dispose3D(self.FCBusLabel)
        # 49.55, not 49.75: three characters at advance 0.85 put the last ink
        # at 52.400 with the frustum edge at 52.442 -- 0.8 px of margin against
        # a stroke drawn 2.2 px wide and CENTRED on the geometry.
        self.FCBusLabel = self.d.strCond(49.55, 34.15, "FC%s" % self.flightCritBus,
                                         self.d.c2h['cyan'], 1.0, 0.85)
        self.mduStatGrp.add(self.FCBusLabel)
        self.d.dirty = True

    def setFCBus(self, newFlightCritBus):
        if newFlightCritBus != self.flightCritBus:
            self.flightCritBus = newFlightCritBus
            self._drawFCBusLabel()

    def setNegView(self, newMduModeNegView):
        if newMduModeNegView != self.mduModeNegView:
            self.mduStatGrp.remove(self.mduModeNegView)
            if self.modeNegView is True:
                self.mduStatGrp.add(self.mduModeNegView)
            self.d.dirty = True

    def setReconfModeAuto(self, newReconfModeAuto):
        print("setReconfModeAuto", newReconfModeAuto, self.portReconfigureModeAuto)
        if newReconfModeAuto != self.portReconfigureModeAuto:
            self.mduStatGrp.remove(self.mduReconfigAut)
            self.mduStatGrp.remove(self.mduReconfigMan)
            self.portReconfigureModeAuto = newReconfModeAuto
            if self.portReconfigureModeAuto is True:
                self.mduStatGrp.add(self.mduReconfigAut)
            else:
                self.mduStatGrp.add(self.mduReconfigMan)
            self.d.dirty = True

    def setCurrentMenu(self, currentMenu):
        self.currentMenu = currentMenu
        title = self.currentMenu['title']
        self.group.remove(self.menuTitle)
        adv = 8.0 / 9                              # title ~8/9 its former width
        tx = 13.90
        ty = 33.16
        if title.strip() == 'SUBSYSTEM MENU':      # right ~3 cells, down ~1px
            tx += 3 - 0.15
            ty += 0.05
        # grow slightly, anchored bottom-left
        self.menuTitle = self.d.str(tx, ty, title, self.d.c2h['cyan'], 1.05,
                                    adv + 0.007, 0.91)
        self.group.add(self.menuTitle)
        # a new menu starts with no active edgekey
        prev = self.activeMenuItem
        self.activeMenuItem = None
        if prev is not None:
            self._drawKeyBox(prev)
        for i in range(6):
            self._drawKeyItem(i)

    def _keyColor(self, i):
        """The edgekey for the currently active page is white (text and
        frame); every other edgekey is cyan."""
        return self.d.c2h['white'] if i == self.activeMenuItem else self.d.c2h['cyan']

    def _drawKeyBox(self, i):
        if self.menuBoxGeo[i] is not None:
            self.menuGrp.remove(self.menuBoxGeo[i])
            dispose3D(self.menuBoxGeo[i])
        xl, xr = self.menuBoxX[i]
        self.menuBoxGeo[i] = self.d.line([[xl, 36.2], [xl, 34.30],
                                          [xr, 34.30], [xr, 36.2]], self._keyColor(i))
        self.menuGrp.add(self.menuBoxGeo[i])
        self.d.dirty = True

    def _drawKeyItem(self, i):
        if self.currentMenu is None:
            return
        if self.menuItemTxt[i] is not None:
            self.group.remove(self.menuItemTxt[i])
            dispose3D(self.menuItemTxt[i])
        # a menu that declares fewer than six edgekeys leaves the rest blank
        item = self.currentMenu.get(i) or {'keyTitle': ''}
        self.menuItemTxt[i] = self.buildMenu(i, item['keyTitle'], self._keyColor(i))
        self.group.add(self.menuItemTxt[i])
        self.d.dirty = True

    def setActiveMenuItem(self, i):
        if i is None or i == self.activeMenuItem:
            return
        prev = self.activeMenuItem
        self.activeMenuItem = i
        for k in (prev, i):
            if k is not None:
                self._drawKeyBox(k)
                self._drawKeyItem(k)

    def setEdgekeyFailed(self, key, failed=True):
        # Other indications of loss of communication between the IDP and GPC
        # are the big "X" and POLL FAIL.  Big "X" appears when the IDP does not
        # receive display update data for 3 seconds.
        self.edgekeyFailed[key] = failed
        for i in range(6):
            if self.edgekeyFailed[i]:
                self.group.add(self.menuRedXs[i])
            else:
                self.group.remove(self.menuRedXs[i])
        self.d.dirty = True

    def build(self):
        self.group = Object3D()
        self.group.name = "MDUMenuArea"
        # Dividing line between app area and menu area, drawn to the EDGES OF
        # THE WORLD, not to 53: the frustum's right edge is cell 52.442, so a
        # rule drawn to 53 has its last half-cell outside the world.
        self.group.add(self.d.line([[self.d.camera.left, 32.2],
                                    [self.d.camera.right, 32.2]], self.d.c2h['cyan']))
        self.faultLine = self.d.str(3, 32, self.faultLineMsg, self.d.c2h['white'], 1, .9)
        self.group.add(self.faultLine)

        self.menuGrp = Object3D()
        self.menuBoxX = []              # per-key frame x extents
        self.menuBoxGeo = []            # per-key frame geometry
        self.menuRedXs = []
        for x in range(6):
            x0 = 3.3 + x * 7.75
            if x >= 3:
                x0 += 0.05              # right 3 edgekey boxes: right ~1px
            lo = 0.10
            ro = 7.40                   # per-box left/right side offsets
            if x == 3:
                ro = 7.45               # 4th edgekey: right side +1px
            if x == 4:                  # 5th edgekey: both sides +2px
                lo = 0.20
                ro = 7.50
            if x == 5:
                lo = 0.20               # 6th edgekey: left side +2px
            self.menuBoxX.append([x0 + lo, x0 + ro])
            self.menuBoxGeo.append(None)
            self._drawKeyBox(x)
            redX = Object3D()
            redX.add(self.d.line([[x0 + lo, 36.2], [x0 + ro, 34.30]], self.d.c2h['red']))
            redX.add(self.d.line([[x0 + lo, 34.30], [x0 + ro, 36.2]], self.d.c2h['red']))
            redX.position.set(0, 0, -0.99)
            self.menuRedXs.append(redX)
        self.group.add(self.menuGrp)

        SADV = 0.85                     # narrower spacing for status labels
        self.mduStatGrp = Object3D()
        self.mduStatGrp.add(self.d.strCond(0.41, 34.185, "P%s" % self.priPortIDP,
                                           self.d.c2h['cyan'], 1.0, SADV))
        if self.secPortIDP is not None:
            self.mduStatGrp.add(self.d.strCond(0.41, 35.185, "S%s" % self.secPortIDP,
                                               self.d.c2h['cyan'], 1.0, SADV))
        self.curIDPStarP = self.d.strCond(2.15, 34.15, "*")
        self.curIDPStarS = self.d.strCond(2.15, 35.15, "*")
        self.FCBusLabel = None
        self._drawFCBusLabel()
        self.mduReconfigAut = self.d.strCond(49.55, 35.11, "AUT",
                                             self.d.c2h['cyan'], 1.0, SADV)
        self.mduReconfigMan = self.d.strCond(49.55, 35.11, "MAN",
                                             self.d.c2h['cyan'], 1.0, SADV)
        if self.portReconfigureModeAuto is True:
            self.mduStatGrp.add(self.mduReconfigAut)
        else:
            self.mduStatGrp.add(self.mduReconfigMan)
        # 'NEG VIEW' started at x 44.5 and is 8 characters, so it ended at
        # 52.5 -- a sixteenth of a cell past the frustum's 52.442.
        self.mduModeNegView = self.d.strCond(44.0, 33, 'NEG VIEW')
        if self.modeNegView is True:
            self.mduStatGrp.add(self.mduModeNegView)
        self.group.add(self.mduStatGrp)

        # Background-coloured fill for the menu strip: masks display geometry
        # that bleeds into the menu area.  The mask spans THE WORLD, not 52
        # centred on 25.5.
        maskW = self.d.camera.right - self.d.camera.left
        menuMask = PlaneGeometry(maskW, 5)
        matMenuMask = MeshBasicMaterial({'side': DoubleSide, 'color': self.d.c2h['black']})
        mMenuMask = Mesh(menuMask, matMenuMask)
        mMenuMask.position.set((self.d.camera.left + self.d.camera.right) / 2,
                               34.5, -1.0)
        maskGroup = Object3D()
        maskGroup.add(mMenuMask)
        self.group.add(maskGroup)

        # The menu area does NOT follow ADJ.pageY: coupling it there put its
        # bottom outside the frustum, and it is the fixed furniture everything
        # else is judged against.  menuX still applies.
        # -0.643 = 0.307 - 0.95, the fitted offset for the MAIN MENU rule.
        self.group.position.set(ADJ['menuX'], -0.643, -0.9)
        self.d.add([self.group])

    def buildMenu(self, i, s, color):
        txtGrp = Object3D()
        x = 3 + i * 7.9
        strs = s.split('\n')
        if len(strs) == 1:
            strs = [strs[0], ""]
        edx = 0.32
        edy = 0.11        # nudge all edgekey titles right ~6px, down ~2px
        if strs[0] == 'UP':
            txtGrp.add(self.d.arrow(x))
            txtGrp.add(self.d.str(x + 3 + edx - 0.22, 34.6 + edy, "UP", color))
        else:
            xup = 3 + i * 8
            if i == 1:                # FLT INST: right ~1 cell
                xup = xup + 1
            if i == 2:                # SUBSYS STATUS: right ~0.48 cell
                xup = xup + 0.48
            if i == 3:                # DPS: right ~2px
                xup = xup + 0.10
            if i == 4:
                xup = math.floor(xup)
            if i == 5:
                xup = xup - 0.5
            if strs[0] == 'OMS/ ':    # OMS/MPS: left ~3px
                xup = xup - 0.22
            if strs[0] == 'PORT':     # PORT SELECT: left ~4px
                xup = xup - 0.29
            eadv = 0.92               # slightly tighter edgekey-title spacing
            eyi = -0.01 if i == 2 else 0
            if strs[0]:
                ctr = (6 - len(strs[0])) / 2
                txtGrp.add(self.d.strCond(xup + ctr + edx, 34.25 + edy + eyi,
                                          strs[0], color, 1.0, eadv))
            if strs[1]:
                ctr = (6 - len(strs[1])) / 2
                txtGrp.add(self.d.strCond(xup + ctr + edx, 35.32 + edy + eyi,
                                          strs[1], color, 1.0, eadv))
        return txtGrp


# ===========================================================================
# Browser-shaped key events
#
# The keyboard code below was written against DOM `keydown` events, so the
# adapter hands it the same shape: `key`, `keyCode`, the modifier flags and
# `preventDefault()`.
# ===========================================================================

_QT_KEYCODE = {
    Qt.Key.Key_Escape: 27, Qt.Key.Key_Backspace: 8, Qt.Key.Key_Tab: 9,
    Qt.Key.Key_Return: 13, Qt.Key.Key_Enter: 13, Qt.Key.Key_Shift: 16,
    Qt.Key.Key_Control: 17, Qt.Key.Key_Alt: 18, Qt.Key.Key_Space: 32,
    Qt.Key.Key_Left: 37, Qt.Key.Key_Up: 38, Qt.Key.Key_Right: 39,
    Qt.Key.Key_Down: 40, Qt.Key.Key_Delete: 46,
    Qt.Key.Key_Equal: 187, Qt.Key.Key_Plus: 187,
    Qt.Key.Key_Minus: 189, Qt.Key.Key_Underscore: 189,
    Qt.Key.Key_Period: 190, Qt.Key.Key_Greater: 190,
    Qt.Key.Key_Comma: 188, Qt.Key.Key_Less: 188,
    Qt.Key.Key_Slash: 191, Qt.Key.Key_Question: 191,
    Qt.Key.Key_Semicolon: 186, Qt.Key.Key_Colon: 186,
    Qt.Key.Key_Apostrophe: 222, Qt.Key.Key_QuoteDbl: 222,
    Qt.Key.Key_BracketLeft: 219, Qt.Key.Key_BracketRight: 221,
    Qt.Key.Key_Backslash: 220, Qt.Key.Key_QuoteLeft: 192,
}
_QT_KEYNAME = {
    Qt.Key.Key_Escape: 'Escape', Qt.Key.Key_Backspace: 'Backspace',
    Qt.Key.Key_Tab: 'Tab', Qt.Key.Key_Return: 'Enter', Qt.Key.Key_Enter: 'Enter',
    Qt.Key.Key_Shift: 'Shift', Qt.Key.Key_Control: 'Control',
    Qt.Key.Key_Alt: 'Alt', Qt.Key.Key_Meta: 'Meta', Qt.Key.Key_Space: ' ',
    Qt.Key.Key_Left: 'ArrowLeft', Qt.Key.Key_Up: 'ArrowUp',
    Qt.Key.Key_Right: 'ArrowRight', Qt.Key.Key_Down: 'ArrowDown',
    Qt.Key.Key_Delete: 'Delete', Qt.Key.Key_Home: 'Home', Qt.Key.Key_End: 'End',
}
for _i in range(1, 25):
    _QT_KEYCODE[Qt.Key(int(Qt.Key.Key_F1) + _i - 1)] = 111 + _i
    _QT_KEYNAME[Qt.Key(int(Qt.Key.Key_F1) + _i - 1)] = 'F%d' % _i


class KeyEvent(object):
    __slots__ = ('key', 'keyCode', 'ctrlKey', 'shiftKey', 'altKey', 'metaKey',
                 'target', 'defaultPrevented')

    def __init__(self, qev, target=None):
        k = qev.key()
        mods = qev.modifiers()
        self.ctrlKey = bool(mods & Qt.KeyboardModifier.ControlModifier)
        self.shiftKey = bool(mods & Qt.KeyboardModifier.ShiftModifier)
        self.altKey = bool(mods & Qt.KeyboardModifier.AltModifier)
        self.metaKey = bool(mods & Qt.KeyboardModifier.MetaModifier)
        self.target = target
        self.defaultPrevented = False
        name = _QT_KEYNAME.get(k)
        txt = qev.text()
        if name is not None:
            self.key = name
        elif txt and txt.isprintable():
            self.key = txt
        elif 0x20 <= k <= 0x7e:
            self.key = chr(k) if self.shiftKey else chr(k).lower()
        else:
            self.key = ''
        kc = _QT_KEYCODE.get(k)
        if kc is None:
            if Qt.Key.Key_A <= k <= Qt.Key.Key_Z or Qt.Key.Key_0 <= k <= Qt.Key.Key_9:
                kc = int(k)
            elif txt:
                kc = ord(txt[0].upper())
            else:
                kc = int(k) & 0xff
        self.keyCode = kc

    def preventDefault(self):
        self.defaultPrevented = True


# ===========================================================================
# meds/kybd.coffee -- the DEU keyboard
# ===========================================================================

class KYBD(object):
    DEUKey = {'keys': {
        'ACK':        {'sw': 1, 'ascii': 'ACK', 'gpcCode': 0x1c, 'deuCode': 0xfff9},
        'MSG_RESET':  {'sw': 2, 'ascii': 'MSG RESET', 'gpcCode': 0x1d, 'deuCode': 0xfff1},
        'SYS_SUMM':   {'sw': 3, 'ascii': 'SYS SUMM', 'gpcCode': 0x10, 'deuCode': 0xffe9},
        'FAULT_SUMM': {'sw': 4, 'ascii': 'FAULT SUMM', 'gpcCode': 0x13, 'deuCode': 0xffe1},
        'C':          {'sw': 5, 'ascii': 'C', 'gpcCode': 0x0c, 'deuCode': 0xffd9},
        'B':          {'sw': 6, 'ascii': 'B', 'gpcCode': 0x0b, 'deuCode': 0xffd1},
        'A':          {'sw': 7, 'ascii': 'A', 'gpcCode': 0x0a, 'deuCode': 0xffc9},
        'GPC_CRT':    {'sw': 8, 'ascii': 'GPC/CRT', 'gpcCode': 0x19, 'deuCode': 0xffc1},

        'F':          {'sw': 9, 'ascii': 'F', 'gpcCode': 0x0f, 'deuCode': 0xfffa},
        'E':          {'sw': 10, 'ascii': 'E', 'gpcCode': 0x0e, 'deuCode': 0xffba},
        'D':          {'sw': 11, 'ascii': 'D', 'gpcCode': 0x0d, 'deuCode': 0xff7a},
        'IO_RESET':   {'sw': 12, 'ascii': 'I/O RESET', 'gpcCode': 0x18, 'deuCode': 0xff3a},
        '3':          {'sw': 13, 'ascii': '3', 'gpcCode': 0x03, 'deuCode': 0xfefa},
        '2':          {'sw': 14, 'ascii': '2', 'gpcCode': 0x02, 'deuCode': 0xfefb},
        '1':          {'sw': 15, 'ascii': '1', 'gpcCode': 0x01, 'deuCode': 0xfe7a},
        'ITEM':       {'sw': 16, 'ascii': 'ITEM', 'gpcCode': 0x14, 'deuCode': 0xfe3a},

        '6':          {'sw': 17, 'ascii': '6', 'gpcCode': 0x06, 'deuCode': 0xfffb},
        '5':          {'sw': 18, 'ascii': '5', 'gpcCode': 0x05, 'deuCode': 0xfdfb},
        '4':          {'sw': 19, 'ascii': '4', 'gpcCode': 0x04, 'deuCode': 0xfbfb},
        'EXEC':       {'sw': 20, 'ascii': 'EXEC', 'gpcCode': 0x1e, 'deuCode': 0xf9fb},
        '9':          {'sw': 21, 'ascii': '9', 'gpcCode': 0x09, 'deuCode': 0xf7fb},
        '8':          {'sw': 22, 'ascii': '8', 'gpcCode': 0x08, 'deuCode': 0xf5fb},
        '7':          {'sw': 23, 'ascii': '7', 'gpcCode': 0x07, 'deuCode': 0xf3fb},
        'OPS':        {'sw': 24, 'ascii': 'OPS ', 'gpcCode': 0x11, 'deuCode': 0xf1fb},

        'PLUS':       {'sw': 25, 'ascii': '+', 'gpcCode': 0x16, 'deuCode': 0xfffc},
        '0':          {'sw': 26, 'ascii': '0', 'gpcCode': 0x00, 'deuCode': 0xeffc},
        'MINUS':      {'sw': 27, 'ascii': '-', 'gpcCode': 0x15, 'deuCode': 0xdffc},
        'SPEC':       {'sw': 28, 'ascii': 'SPEC', 'gpcCode': 0x12, 'deuCode': 0xcffc},
        'PRO':        {'sw': 29, 'ascii': 'PRO', 'gpcCode': 0x1f, 'deuCode': 0xbffc},
        'DECIMAL':    {'sw': 30, 'ascii': '.', 'gpcCode': 0x17, 'deuCode': 0xaffc},
        'CLEAR':      {'sw': 31, 'ascii': 'CLEAR', 'gpcCode': 0x1a, 'deuCode': 0x9ffc},
        'RESUME':     {'sw': 32, 'ascii': 'RESUME', 'gpcCode': 0x1b, 'deuCode': 0x8ffc},
    }}

    _scanToKey = None

    @classmethod
    def byScan(cls, scan):
        """Keyboard scan code -> the key it names, built on first use.  The
        scan codes are the row/column strobe pattern the keyboard puts on the
        bus; `gpcCode` is the 5-bit code the DEU protocol carries."""
        if cls._scanToKey is None:
            cls._scanToKey = {}
            for _n, k in cls.DEUKey['keys'].items():
                cls._scanToKey[k['deuCode']] = k
        return cls._scanToKey.get(scan & 0xffff)

    @staticmethod
    def isEditable(el):
        if el is None:
            return False
        return isinstance(el, (QtWidgets.QLineEdit, QtWidgets.QTextEdit,
                               QtWidgets.QComboBox, QtWidgets.QAbstractSpinBox))

    @classmethod
    def deuKeyFor(cls, ev):
        # don't steal Mod+Keys or when we're focused on a text box
        if ev is None:
            return None
        if cls.isEditable(ev.target):
            return None
        if ev.ctrlKey or ev.metaKey or ev.altKey:
            return None
        return cls.DPSKeys.get(ev.keyCode)

    def __init__(self, kybdBus, mdu=None):
        self.kybdBus = kybdBus
        self.mdu = mdu
        self._setupBus()
        if mdu is not None and getattr(mdu, 'win', None) is not None:
            mdu.win.onKeyDown(self._onKeyDown)

    def _onKeyDown(self, ev):
        if KYBD.isEditable(ev.target):
            return
        mdu = self.mdu
        if ev.key == 'S' and mdu is not None:
            ev.preventDefault()
            mdu.screenshot()
            return
        if ev.key in ('F12', 'F11') and not ev.ctrlKey and mdu is not None:
            # Debug: F12 / F11 cycle the DPS background through every data/*.dfb
            ev.preventDefault()
            mdu.setCurrentDisplay('DPS')
            scr = mdu.screens.get('DPS')
            if scr is not None:
                scr.cycleBGDFB(1 if ev.key == 'F12' else -1)
            mdu.redraw()
            return
        # Debug: reference-screenshot overlays (Shift = cycle opacity).
        # F8 = the CURRENT screen's overlay, F7 = the DPS overlay always.
        if ev.key == 'F8' and mdu is not None:
            ev.preventDefault()
            ident = mdu.ovIdent()
            if ev.shiftKey:
                mdu.disp.cycleOverlayOpacity(ident['key'])
            else:
                mdu.disp.toggleOverlay(ident['dflt'], ident['key'])
            return
        if ev.key == 'F7' and mdu is not None:
            ev.preventDefault()
            if ev.shiftKey:
                mdu.disp.cycleOverlayOpacity('dpsOverlayGeom')
            else:
                mdu.disp.toggleOverlay('dpsscreen.png', 'dpsOverlayGeom')
            return
        # Shift+X opens the parameter panel, which is where the live geometry
        # sliders are.  The panel's own double-click opener needs window space
        # OUTSIDE the canvas, and at --size 512 the canvas fills the window.
        if ev.key == 'X' and mdu is not None:
            ev.preventDefault()
            mdu._toggleParamEditor(None)
            return
        # Shift+V switches the beam-coordinate frame live.  GPCIPL writes
        # display memory in one frame and everything PASS sends is in another.
        if ev.key == 'V' and mdu is not None:
            ev.preventDefault()
            print("MEDS2: beam geometry -> %s" % setGeom())
            # The FCWs have to be WALKED again -- redraw() only repaints the
            # geometry already built.
            scr = mdu.screens.get('DPS')
            if scr is not None:
                scr.refresh()
            mdu.redraw()
            return
        # Shift+M cycles the MAJOR FUNCTION switch -- PL, GNC, SM, and the
        # ILLEGAL position, which is in the cycle because PASS tests for it.
        if ev.key == 'M' and mdu is not None:
            ev.preventDefault()
            mdu.cycleMajorFunc()
            return
        # Shift+1..4 select a position DIRECTLY -- PL, GNC, SM, ILLEGAL.  The
        # shifted digits arrive as '!@#$', which are not DEU keys.
        mf = '!@#$'.find(ev.key) if len(ev.key) == 1 else -1
        if mf >= 0 and mdu is not None:
            ev.preventDefault()
            mdu.setMajorFunc(mf)
            return
        # Debug: F9 toggles the animated DEU self-test mode
        if ev.key == 'F9' and mdu is not None:
            ev.preventDefault()
            mdu.setCurrentDisplay('DPS')
            scr = mdu.screens.get('DPS')
            if scr is not None:
                scr.toggleSelfTest()
            mdu.redraw()
            return
        k = KYBD.deuKeyFor(ev)
        if k is not None:
            self.keyPress(k)

    def _setupBus(self):
        self.busName = "_KYBD%s" % self.kybdBus
        self.bus = Bus(self.busName, busConfig[self.busName])
        self.bus.onReceive(self.recvKYBD)

    def recvKYBD(self, _obj, busID, msg, remote):
        # Another keyboard on this bus -- stsKeyboard.py, or a second MDU
        # window.  The IDP hears the same datagram and queues the key for the
        # GPC; this only echoes it on the scratch pad, as a press in this
        # window does.  This window's own sends never get here: the bus drops
        # them as self-echo.  And only while this keyboard is selected to the
        # IDP (IDP/CRT SEL): the IDP ignores it otherwise, so the scratch pad
        # must too.
        mask = getattr(self.mdu, 'kybdMask', None) if self.mdu else None
        bit = {'1': 1, '2': 2}.get(str(self.kybdBus))
        if mask is not None and bit is not None and not (mask & bit):
            return
        for w in msg.data16:
            k = KYBD.byScan(int(w))
            if k is None:
                print("KYBD%s: unknown keyboard scan code 0x%x"
                      % (self.kybdBus, int(w) & 0xffff))
                continue
            print("KYBD%s: %s recv %s" % (self.kybdBus, busID, k['ascii']))
            self._echo(k)

    def keyPress(self, k):
        print("KYBD keyPress", k)
        kybdMsg = BusMsg(1)
        kybdMsg.data16[0] = k['deuCode']
        self.bus.sendMsg(kybdMsg)
        self._echo(k)

    def _echo(self, k):
        if self.mdu:
            scr = self.mdu.screens.get('DPS')
            if scr is not None:
                scr.recvKey(k)


_K = KYBD.DEUKey['keys']
KYBD.DPSKeys = {
    27: _K['MSG_RESET'], 8: _K['CLEAR'],
    48: _K['0'], 49: _K['1'], 50: _K['2'], 51: _K['3'], 52: _K['4'],
    53: _K['5'], 54: _K['6'], 55: _K['7'], 56: _K['8'], 57: _K['9'],
    65: _K['A'], 66: _K['B'], 67: _K['C'], 68: _K['D'], 69: _K['E'], 70: _K['F'],
    84: _K['IO_RESET'],      # T
    79: _K['OPS'],           # O
    83: _K['SPEC'],
    73: _K['ITEM'],
    13: _K['EXEC'],
    80: _K['PRO'],
    82: _K['RESUME'],
    187: _K['PLUS'], 189: _K['MINUS'], 190: _K['DECIMAL'],
    75: _K['ACK'],
    89: _K['SYS_SUMM'],      # Y
    85: _K['FAULT_SUMM'],    # U
    71: _K['GPC_CRT'],       # G
}


# ===========================================================================
# meds/mduEdgeKeys.coffee
#
# MDU edgekeys are F1..F6 (keyCodes 112..117).  A key held longer than
# STUCK_MS is declared stuck: it is failed (red-X'ed via the fail callback)
# and ignored from then on.  A normal press fires the handler on release.
# ===========================================================================
STUCK_MS = 2000


class MDUEdgeKeys(object):
    def __init__(self, win=None):
        self.failed = [False] * 6
        self.downTimers = {}     # keyIdx -> pending stuck-detection timeout
        self.cb = None
        self.cbFail = None
        if win is not None:
            win.onKeyDown(self._down)
            win.onKeyUp(self._up)
            win.onBlur(self._blur)

    def _down(self, ev):
        if KYBD.isEditable(ev.target):
            return
        if not (112 <= ev.keyCode <= 117):
            return
        ev.preventDefault()
        self.press(ev.keyCode - 112)

    def _up(self, ev):
        if KYBD.isEditable(ev.target):
            return
        if not (112 <= ev.keyCode <= 117):
            return
        ev.preventDefault()
        self.release(ev.keyCode - 112)

    # THE ONE PATH FOR A PRESS, whether it came from F1..F6 or from a click on
    # the pushbuttons under the display (MDUEdgeKeyStrip), so both are held,
    # released and declared stuck by the same rule.
    def press(self, i):
        if not 0 <= i < 6 or self.failed[i]:
            return
        if self.downTimers.get(i) is not None:   # already armed (auto-repeat)
            return
        t = QTimer()
        t.setSingleShot(True)
        t.timeout.connect(lambda idx=i: self._stuck(idx))
        t.start(STUCK_MS)
        self.downTimers[i] = t

    def release(self, i):
        if not 0 <= i < 6 or self.failed[i]:
            return
        t = self.downTimers.get(i)
        if t is not None:                        # released in time
            t.stop()
            del self.downTimers[i]
            if self.cb:
                self.cb(i)

    def _blur(self):
        # Focus loss eats keyup events; cancel pending detections rather than
        # spuriously failing keys that were released while we couldn't see it.
        for t in self.downTimers.values():
            t.stop()
        self.downTimers = {}

    def _stuck(self, i):
        self.downTimers.pop(i, None)
        self.failed[i] = True
        if self.cbFail:
            self.cbFail(i)

    def setHandler(self, cb, cbFail=None):
        self.cb = cb
        self.cbFail = cbFail


# ===========================================================================
# meds/mdu.coffee -- the Multifunction Display Unit
# ===========================================================================

# The four MAJOR FUNCTION switch positions.  ILLEGAL is a real position, not a
# placeholder: PASS tests for it, so it stays in the cycle.
MF_NAMES = ['PL', 'GNC', 'SM', 'ILLEGAL']

ScreenMods = {
    'AE_PFD': Screen_AE_PFD,
    'AUTONOMOUS': Screen_AUTONOMOUS,
    'DPS': Screen_DPS,
    'FAULT_SUMM': Screen_FAULT_SUMM,
    'FILE_PATCH': Screen_FILE_PATCH,
    'HYD_APU': Screen_HYD_APU,
    'IDP_CST': Screen_IDP_CST,
    'MAINT': Screen_MAINT,
    'OMS_MPS': Screen_OMS_MPS,
    'ORBIT_PFD': Screen_ORBIT_PFD,
    'SPI': Screen_SPI,
}

# per-screen reference-overlay identity: localStorage key + default image.
# AE_PFD/DPS keep their legacy keys -- the long-tuned placements live under
# them; every other screen gets '<name>OverlayGeom'.
OV_LEGACY = {'AE_PFD': ['pfdOverlayGeom', 'meds_font2.png'],
             'DPS': ['dpsOverlayGeom', 'dpsscreen.png']}

POLL_FAIL_MS = 4000       # DPS poll fail timer
IDP_LOST_MS = 2000        # 'MDU Autonomous' fail timer (16 missed beats)
STARTUP_MS = 10000        # ...but allow for an IDP that starts up slowly


class MDU(LRU):
    Menus = Menus

    def __init__(self, CONFIG):
        config = MEDSConf['mdus'][CONFIG['config']['lru']]
        priPortIDP = secPortIDP = None
        if config['dataBus'].get('P'):
            priPortIDP = int(config['dataBus']['P'][-1:])
        if config['dataBus'].get('S'):
            secPortIDP = int(config['dataBus']['S'][-1:])

        lruConfig = {'id': "MDU", 'nom': "MEDS MDU", 'busses': []}
        lruConfig['busses'].append("_IDP%d" % priPortIDP)
        if secPortIDP is not None:
            lruConfig['busses'].append("_IDP%d" % secPortIDP)
        LRU.__init__(self, lruConfig)

        self.win = None
        self.disp = None
        self.screens = {}
        self.screenMods = ScreenMods
        self._pollWatchdog = None    # POLL FAIL: re-armed by the GPC's poll
        self._idpWatchdog = None     # the port: re-armed by the IDP's heartbeat
        self._idpWatchdogSec = None
        # Assumed alive until the watchdog says otherwise -- `_idpLost` has to
        # be able to fire the FIRST time, when nothing has been heard at all.
        self._idpUp = True
        self._secTimedOut = False
        self._paramPanel = None
        self.CONFIG = CONFIG
        # Mirror DEUUnit's default so the title reports the real position
        # before the switch has ever been moved, not a guess.
        self.majorFunc = int(envnum('NSTS_MAJOR_FUNC', 0)) & 3
        # The IDP POWER switch as the pane shows it -- the same default the
        # IDP itself starts with (see MedsRunner.startLRUsIn).
        self.idpPower = bool(CONFIG.get('powerOn', True))
        self.pane = None
        # Which forward keyboards the primary IDP takes, from its heartbeat
        # (bit 0 left, bit 1 right); None until one says.  See recvFromPri.
        self.kybdMask = None
        self.config = config
        self.priPortIDP = priPortIDP
        self.secPortIDP = secPortIDP
        self.lruConfig = lruConfig

        self.bus["_IDP%d" % self.priPortIDP].onReceive(self.recvFromPri, self)
        if self.secPortIDP is not None:
            self.bus["_IDP%d" % self.secPortIDP].onReceive(self.recvFromSec, self)
        self.curBus = self.bus["_IDP%d" % self.priPortIDP]

        self.mduConfig = {
            'priPortIDP': self.priPortIDP,
            'secPortIDP': self.secPortIDP,
            'cmdPort': 1,
            'flightCritBus': getattr(self, 'flightCritBus', None),
            'modeNegView': False,
            'portReconfigureModeAuto': True,
        }
        self.cmdPort = 0
        self.flightCritBus = 3
        self.gpcNo = 3
        self.kybd = 'left'
        self.portReconfigureModeAuto = False
        self.portReconfigModeAuto = False
        self.modeNegView = False
        self.faultLineMsg = ""
        self.curDisplay = "BLANK"
        self.prevDisplay = None
        self.prevMenuName = None
        self.currentMenu = None
        self.currentMenuName = None
        self.dps_poll_fail = True

        self._edgeKeys = None

    # -- startup ------------------------------------------------------------
    def start(self):
        self._edgeKeys = MDUEdgeKeys(self.win)
        self._edgeKeys.setHandler(self.handleEdgekey, self.handleEdgekeyFail)

        self.disp = VectorDisplay(self.CONFIG)
        self.disp.attachTo(self.win)
        self.mdu_menuArea = MDUMenuArea(self.disp, self.CONFIG)
        self.updateMduData()
        self.mdu_menuArea.build()

        self.screens = {}
        self.mdu_menuArea.setCurPort(self.cmdPort)
        self.mdu_menuArea.setFCBus(self.flightCritBus)
        self.mdu_menuArea.setNegView(self.modeNegView)
        self.mdu_menuArea.setReconfModeAuto(self.portReconfigureModeAuto)

        self.setCurrentMenu(self.CONFIG['init']['menu'])
        self.setCurrentDisplay(self.CONFIG['init']['display'])

        self.watchIDP()
        self.redraw()

        self.kybd = KYBD(self.kybdBus(), self)

        # Debug: double-click outside the display canvas toggles a live
        # feed-parameter editor
        if self.win is not None:
            self.win.onDblClick(self._toggleParamEditor)

    # THE MAJOR FUNCTION SWITCH -- PL / GNC / SM on the MCDS keyboard unit, not
    # a crew discrete.  It lives on the IDP's DEUUnit, in another process, so
    # the MDU SENDS it rather than setting it.
    #
    # 0=PL, 1=GNC, 2=SM, 3=ILLEGAL, which is the flight software's own encoding
    # from SSSRC/CZ1COM.  3 is in the cycle deliberately: it is the position
    # PASS explicitly tests for.
    def setMajorFunc(self, mf):
        self.majorFunc = mf & 3
        msg = BusMsg(2)
        msg.data16[0] = MDUMsg.SET_MAJOR_FUNC
        msg.data16[1] = self.majorFunc
        if self.curBus is not None:
            self.curBus.sendMsg(msg)
        name = self.showMajorFunc()
        print("MEDS2: major function switch -> %d (%s)" % (self.majorFunc, name))
        if self.pane is not None:
            self.pane.update()      # Shift+M and Shift+1..4 move the paddle too
        return self.majorFunc

    # IDP POWER and DEU LOAD, from the pane.  Like the major function switch
    # they belong to the IDP, which may be in another process, so they go to
    # it as MDU -> IDP messages.
    def setIdpPower(self, on):
        self.idpPower = bool(on)
        msg = BusMsg(2)
        msg.data16[0] = MDUMsg.IDP_POWER
        msg.data16[1] = 1 if self.idpPower else 0
        if self.curBus is not None:
            self.curBus.sendMsg(msg)
        print("MEDS2: IDP%s POWER -> %s" % (self.priPortIDP, "ON" if on else "OFF"))
        if self.pane is not None:
            self.pane.update()

    def deuLoad(self):
        msg = BusMsg(1)
        msg.data16[0] = MDUMsg.DEU_LOAD
        if self.curBus is not None:
            self.curBus.sendMsg(msg)
        print("MEDS2: DEU LOAD -> IDP%s" % self.priPortIDP)

    def _majorFuncHeard(self, mf):
        """Someone else moved this IDP's MAJ FUNC switch -- panelO6.py's C2, or
        another window on the same IDP.  Follow it; send nothing back."""
        if mf == self.majorFunc:
            return
        self.majorFunc = mf
        name = self.showMajorFunc()
        print("MEDS2: major function switch -> %d (%s), heard on the bus"
              % (mf, name))
        if self.pane is not None:
            self.pane.update()

    def _idpPowerHeard(self, on):
        """IDP POWER moved elsewhere (panelO6.py's C2); the pane follows."""
        if bool(on) == self.idpPower:
            return
        self.idpPower = bool(on)
        if self.pane is not None:
            self.pane.update()

    def showMajorFunc(self):
        """ON SCREEN -- on the IDP pane's MAJ FUNC paddle, which shows the
        position and sets it.

        It used to be appended to the window title instead, because there is
        nowhere on the DPS page to put it without disturbing a layout that
        took a long time to fit, and the switch was invisible otherwise.  The
        pane says it better, so the title no longer has to.  WITHOUT the pane
        (--no-pane) there is still nowhere else for it, so it goes back to
        the title bar rather than disappearing."""
        name = MF_NAMES[(self.majorFunc or 0) & 3]
        lru = self.CONFIG.get('config', {}).get('lru')
        if self.pane is None:
            t = "%s / %s - MF %s" % (WINDOW_TITLE, lru, name)
        else:
            t = "%s / %s" % (WINDOW_TITLE, lru)
        try:
            if self.win is not None:
                self.win.setWindowTitle(t)
                self.win.setChromeTitle(t)
        except Exception:
            pass
        return name

    def cycleMajorFunc(self):
        return self.setMajorFunc(((self.majorFunc or 0) + 1) % 4)

    def kybdBus(self):
        """Which keyboard drives this display.  An MDU has no keyboard of its
        own: a keystroke reaches a GPC through the IDP that owns the DK bus, so
        it has to go to a keyboard that IDP is listening to."""
        idp = MEDSConf['idps'].get("IDP%d" % self.priPortIDP) or {}
        for b in idp.get('busses', []):
            m = re.match(r'^_KYBD(\d)$', b)
            if m:
                return int(m.group(1))
        return 1

    def updateMduData(self):
        self.mdu_menuArea.setData({
            'priPortIDP': self.priPortIDP,
            'secPortIDP': self.secPortIDP,
            'cmdPort': 1,
            'flightCritBus': self.flightCritBus,
            'portReconfigureModeAuto': self.portReconfigureModeAuto,
            'modNegView': self.modeNegView,
            'faultLineMsg': self.faultLineMsg,
            'curIDP': self.priPortIDP,
        })

    # -- watchdogs ----------------------------------------------------------
    def _rearm(self, name, ms, expired):
        t = getattr(self, name, None)
        if t is not None:
            t.stop()
        t = QTimer()
        t.setSingleShot(True)

        def fire():
            setattr(self, name, None)
            expired()
        t.timeout.connect(fire)
        t.start(ms)
        setattr(self, name, t)

    def _pollLost(self):
        if self.dps_poll_fail:
            return
        self.dps_poll_fail = True
        scr = self.screens.get('DPS')
        if scr is not None:
            scr.setPollFail(True)
        self.redraw()

    def recvFromPri(self, t, busID, msg, remote):
        tag = int(msg.data16[0])
        # MDU -> IDP traffic on this bus -- panelO6.py's C2 and O6 switches,
        # simulatePASS's tokens, another window on the same IDP -- is not the
        # IDP talking, so it must not count as a live port (the panel
        # re-asserts IDP POWER OFF every second, and the MDU must still go
        # AUTONOMOUS).  The switch positions it reports are followed.
        if tag < MDUMsg.FILL:
            if tag == MDUMsg.SET_MAJOR_FUNC and len(msg.data16) > 1:
                t._majorFuncHeard(int(msg.data16[1]) & 3)
            elif tag == MDUMsg.IDP_POWER and len(msg.data16) > 1:
                t._idpPowerHeard(int(msg.data16[1]) != 0)
            return
        # Any traffic at all says the port is alive; only a POLL says a GPC is.
        t._idpHeard()
        t._rearm('_idpWatchdog', IDP_LOST_MS, t._idpLost)
        scr = t.screens.get('DPS')
        if tag == MDUMsg.HEARTBEAT:
            # The DEU's flashing attribute is local: it advances one phase per
            # heartbeat, so it keeps flashing with no GPC on the bus.  Word 2,
            # when there is one, is which forward keyboards the IDP takes.
            t.kybdMask = (int(msg.data16[2]) & 3) if len(msg.data16) > 2 else None
            if scr is not None:
                scr.blinkTick()
                scr.setIdpBox(t.priPortIDP, t.kybdMask or 0)
        elif tag == MDUMsg.POLL:
            t._rearm('_pollWatchdog', POLL_FAIL_MS, t._pollLost)
            t._pollHeard()
        elif tag == MDUMsg.FILL:
            if scr is not None:
                scr.applyFill(int(msg.data16[1]),
                              [int(w) for w in msg.data16[2:]])
                t.redraw()
        elif tag == MDUMsg.CLOCK:
            if scr is not None:
                mis, evt = int(msg.data16[1]), int(msg.data16[2])
                if len(msg.data16) >= 6:      # the high halves (_sendClock)
                    mis |= int(msg.data16[4]) << 16
                    evt |= int(msg.data16[5]) << 16
                if scr.setClock(mis, evt, int(msg.data16[3])) is not False:
                    _clock_log("draw mission=%d" % mis)
                    t.redraw()
        elif tag == MDUMsg.RESET_SPL:
            if scr is not None:
                if scr.spl is not None:
                    scr.spl.clear()
                scr.setSyntaxError(False)
                scr.updateScratchpad()
            t.redraw()

    def _pollHeard(self):
        """A GPC is polling us again."""
        if not self.dps_poll_fail:
            return
        self.dps_poll_fail = False
        scr = self.screens.get('DPS')
        if scr is not None:
            scr.setPollFail(False)
        self.redraw()

    def recvFromSec(self, t, busID, msg, remote):
        """The secondary port has a heartbeat of its own, so it can drop
        independently of the primary."""
        if int(msg.data16[0]) < MDUMsg.FILL:
            return                       # MDU -> IDP traffic; see recvFromPri
        if t._secTimedOut:
            t._secTimedOut = False
            if t.curDisplay == "AUTONOMOUS":
                t._autonomous()

        def expired():
            t._secTimedOut = True
            if t.curDisplay == "AUTONOMOUS":
                t._autonomous()
        t._rearm('_idpWatchdogSec', IDP_LOST_MS, expired)

    def redraw(self):
        if self.disp is not None:
            self.disp.dirty = True

    # -- edgekeys and menus -------------------------------------------------
    def handleEdgekey(self, keyId):
        print("handleEdgekey", keyId, self.currentMenu.get(keyId))
        item = self.currentMenu.get(keyId)
        if item is None:
            return
        if item.get('action') is not None:
            item['action'](self)
            print("action", self.curDisplay)
            self.redraw()
        if item.get('link') is not None:
            self.setCurrentMenu(item['link'])
            self.redraw()

    def handleEdgekeyFail(self, keyId):
        self.mdu_menuArea.setEdgekeyFailed(keyId)

    def setCurrentMenu(self, menuName):
        self.currentMenuName = menuName
        self.currentMenu = self.Menus[menuName]
        self.mdu_menuArea.setCurrentMenu(self.currentMenu)
        # menus that reflect a persistent setting declare activeItem to
        # pre-highlight the edgekey matching the current state
        if self.currentMenu.get('activeItem') is not None:
            self.mdu_menuArea.setActiveMenuItem(self.currentMenu['activeItem'](self))
        if self.currentMenu.get('action') is not None:
            self.currentMenu['action'](self)

    def setCurrentDisplay(self, newCurDisplay, curMenuItem=None):
        print("setCurrentDisplay %s -> %s" % (self.curDisplay, newCurDisplay))
        self.mdu_menuArea.setActiveMenuItem(curMenuItem)
        if newCurDisplay != self.curDisplay:
            if self.screens.get(self.curDisplay):
                self.disp.scene.remove(self.screens[self.curDisplay].group)
            self.curDisplay = newCurDisplay
            if self.curDisplay not in self.screens:
                cls = ScreenMods[self.curDisplay]
                self.screens[self.curDisplay] = cls(self.disp)
                # Which display this is, for the screen announcements: crt1.
                self.screens[self.curDisplay].mduName = str(
                    self.CONFIG.get('config', {}).get('lru', '')).lower()
            cd = self.screens[self.curDisplay]
            cd.draw()
            if self.curDisplay == 'DPS':
                cd.setPollFail(self.dps_poll_fail)
            if cd.group is not None:
                self.disp.scene.add(cd.group)
                self.redraw()

    def setFCBus(self, bus):
        self.flightCritBus = bus
        self.mdu_menuArea.setFCBus(self.flightCritBus)
        # keep the DATA BUS SELECT highlight in sync however the bus was set
        if self.currentMenu is not None and self.currentMenu.get('activeItem'):
            self.mdu_menuArea.setActiveMenuItem(self.currentMenu['activeItem'](self))

    def toggleCmdPort(self):
        self.cmdPort = (self.cmdPort + 1) % 2
        self.mdu_menuArea.setCurPort(self.cmdPort)

    def toggleReconfigMode(self):
        self.portReconfigModeAuto = not self.portReconfigModeAuto
        self.mdu_menuArea.setReconfModeAuto(self.portReconfigModeAuto)

    def toggleNegView(self):
        self.modeNegView = not self.modeNegView
        self.mdu_menuArea.setNegView(self.modeNegView)

    def seq_mdu_selftest(self):
        scr = self.screens.get('IDP_CST')
        if scr is not None:
            scr.seq_mdu_selftest(self)

    def watchIDP(self):
        if self.CONFIG.get('dev'):
            return
        # A longer grace at startup than mid-run: the IDP's process may still
        # be coming up.
        self._rearm('_idpWatchdog', STARTUP_MS, self._idpLost)
        if self.secPortIDP is not None:
            def expired():
                self._secTimedOut = True
                if self.curDisplay == "AUTONOMOUS":
                    self._autonomous()
            self._rearm('_idpWatchdogSec', STARTUP_MS, expired)

    def _autonomous(self):
        if self.curDisplay != "AUTONOMOUS":
            self.prevDisplay = self.curDisplay
            self.prevMenuName = self.currentMenuName
            self.setCurrentDisplay('AUTONOMOUS')
            self.setCurrentMenu('DISCONNECTED')
            print("AUTO", self.prevMenuName)
            self.redraw()
        # keep the timeout-reason line current: the sec port can drop after
        # the pri port did, and each has its own heartbeat
        scr = self.screens.get('AUTONOMOUS')
        if scr is not None and scr.setTimeouts(not self._idpUp, self._secTimedOut):
            self.redraw()

    def _idpLost(self):
        if not self._idpUp:
            return
        self._idpUp = False
        print("MDU%s: port timeout -- no IDP heartbeat" % self.id)
        self._autonomous()

    def _idpHeard(self):
        if self._idpUp:
            return
        self._idpUp = True
        if self.curDisplay == "AUTONOMOUS":
            self.setCurrentDisplay(self.prevDisplay)
            print("RESTORE", self.prevMenuName)
            self.setCurrentMenu(self.prevMenuName)
            self.redraw()

    # -- the reference-overlay controls -------------------------------------
    def ovIdent(self, name=None):
        if name is None:
            name = self.curDisplay
        key, dflt = OV_LEGACY.get(name, ["%sOverlayGeom" % name, None])
        if dflt is None:
            names = self.disp.overlayImageNames()
            dflt = names[0] if names else None
        return {'key': key, 'dflt': dflt}

    def _ovControls(self):
        """Reference-overlay control descriptors, appended to EVERY screen's
        param editor."""
        scr = self.screens.get(self.curDisplay)
        if scr is None:
            return []
        ident = self.ovIdent()
        key = ident['key']
        dflt = ident['dflt']
        d = self.disp

        def _showSet(v):
            if v != d.overlayVisible(key):
                d.toggleOverlay(dflt, key)
        return [
            {'header': 'reference overlay'},
            {'label': 'show', 'get': (lambda: d.overlayVisible(key)),
             'set': _showSet},
            {'label': 'image', 'options': (lambda: d.overlayImageNames()),
             'get': (lambda: d.overlayImageCur(key, dflt)),
             'set': (lambda n: d.overlayImageSelect(key, n))},
            {'label': 'slot', 'options': (lambda: d.overlaySlotNames(key)),
             'get': (lambda: d.overlaySlotCur(key)),
             'set': (lambda n: d.overlaySlotSelect(key, n, scr.ovHooks()))},
            # slots capture the feed values shown in their photo; this
            # re-applies them on slot select (and immediately when checked)
            {'label': 'apply values', 'get': (lambda: d.overlayApplyVals(key)),
             'set': (lambda v: d.overlayApplyValsSet(key, v, scr.ovHooks()))},
        ]

    def _toggleParamEditor(self, ev=None):
        """Live feed-parameter editor (debug).

        Double-click outside the display canvas (or Shift+X) toggles a panel
        listing the current screen's curData fields; edits apply live via the
        screen's refreshFeed() (numbers, strings and booleans), and each
        screen's own test controls and the reference-overlay group ride along.
        """
        if ev is not None:
            # a click inside the panel is the panel's own; a click inside the
            # canvas belongs to the display.  At the stock size the canvas IS
            # the window, which is why Shift+X exists.
            if self._paramPanel is not None and \
                    self._paramPanel.geometry().contains(ev.position().toPoint()):
                return
            if self.disp is not None and \
                    self.disp.widget.geometry().contains(ev.position().toPoint()):
                return
        if self._paramPanel is not None:
            self._paramPanel.close()
            self._paramPanel.deleteLater()
            self._paramPanel = None
            return
        scr = self.screens.get(self.curDisplay)
        data = scr.curData if scr is not None else None
        tcs = list(scr.testControls() if scr is not None else []) + self._ovControls()
        if data is None and len(tcs) == 0:
            print("param editor: %s has no feed data or test controls" % self.curDisplay)
            return
        self._paramPanel = ParamPanel(self, scr, data, tcs)
        self._paramPanel.show()

    def screenshot(self):
        print("SCREENSHOT")
        try:
            img = self.disp.widget.grabFramebuffer()
            name = "mduScreenshot-%d.png" % int(time.time() * 1000)
            img.save(name)
            print(name)
        except Exception as e:
            print("screenshot failed: %s" % e)


def mdu_start(CONFIG):
    mdu = MDU(CONFIG)
    # The window title carries the MAJOR FUNCTION switch position; set it once
    # the window has actually mounted, so the setting is visible from the start
    QTimer.singleShot(250, mdu.showMajorFunc)
    # dev mode preloads test screens, so the DPS skips POLL FAIL; otherwise
    # the flag stays set until an IDP delivers a background DFB
    if CONFIG.get('dev'):
        mdu.dps_poll_fail = False
    return mdu


# ===========================================================================
# meds/idp.coffee -- the Interface/Display Processor
#
# DEU Display Control Program (DCP) info (DCP 8.07).  The DEU has 8192x17bit
# words (16+1 parity).  Ref SSSH Dwg.8.6:
#   0x0000  Low Core            0x19BC  Message Line Buffer
#   0x0100  Critical Format Buffer      0x19EE  Display Buffer
#   0x0F48  Format Checksum     0x1FE5  I/O Buffer
#   0x0F49  DEU Control Program
# ===========================================================================

HEARTBEAT_MS = 125


class IDP(LRU):
    def __init__(self, CONFIG):
        idpConfig = MEDSConf['idps'][CONFIG['config']['lru']]
        idpConfig['id'] = CONFIG['config']['lru']
        LRU.__init__(self, idpConfig)

        self.CONFIG = CONFIG
        self.idpConfig = idpConfig
        self.keyBuf = []
        self.fcw = FCW()
        self.mduCmdBus = self.bus.get("_%s" % self.id)
        self.dkBus = self.bus.get(self.idpConfig['dkBus'])
        self.running = False
        self._hbTimer = None
        self.bgDFB = None
        # The IDP POWER switch; see setPower and MedsRunner.startLRUsIn.
        self.powered = bool(CONFIG.get('powerOn', True))
        # Whether this unit's buses and heartbeat run on the BusPump thread
        # (the default) or, as they used to, on the GUI thread.
        self.threaded = str(env('NSTS_IDP_THREAD', '1')) != '0'
        # IDP/CRT SEL: which forward keyboards this unit takes keys from, bit 0
        # the left (_KYBD1) and bit 1 the right (_KYBD2), as panelO6.py's C2
        # sends it.  None until one arrives, and then every keyboard bus the
        # unit is wired to is heard, as before there were switches.  _KYBD3,
        # the aft keyboard, has no switch and is always heard.
        self.kybdSel = None

        deulog = env('NSTS_DEU_LOG')

        def log(text):
            # NSTS_DEU_LOG=<path> puts this on DISK as well.  It used to go
            # only to the devtools console -- so the one record that says
            # whether a fill arrived was thrown away on every run.
            print(text)
            if deulog:
                try:
                    with open(deulog, 'a') as fh:
                        fh.write("%s %s\n" % (getattr(self, 'name', 'deu'), text))
                except Exception:
                    pass

        self.unit = DEUUnit({
            'name': "IDP%s" % self.id,
            'ipled': CONFIG.get('config', {}).get('ipled'),
            'send': (lambda words: self._send(words)),
            'fill': (lambda addr, words: self._sendToMDUs(addr, words)),
            'reset': (lambda: self._resetScratchPad()),
            'time': (lambda t: self._sendClock(t)),
            'poll': (lambda: self._sendPollTick()),
            'log': log,
        })

        for bid, bus in self.bus.items():
            print("|||", bid, bus)
            if re.search('FC', bid):
                bus.onReceive(self.recvFC, self)
            elif re.search('DK', bid):
                bus.onReceive(self.recvDK, self)
            elif re.search('IDP', bid):
                bus.onReceive(self.recvMDU, self)
            elif re.search('KYBD', bid):
                bus.onReceive(self.recvKYBD, self)
            else:
                print("Bad bus name %s" % bid)

    def start(self):
        self.running = True
        self.exec_()
        # Only now, so that everything exec_() does is done before the pump
        # can deliver a datagram: from here on the unit belongs to the pump
        # thread.  Anything that arrived meanwhile is waiting in the socket.
        if self.threaded:
            for bus in self.bus.values():
                bus.serviceOffGuiThread()

    # The FC1-4 busses carry flight instrument ("steam gauge") data from the
    # ADC.  Not yet implemented.
    def recvFC(self, t, busID, msg, remote):
        pass

    # Display/Keyboard (DK) busses
    def recvDK(self, t, busID, msg, remote):
        if not t.powered:
            return               # an unpowered unit hears nothing, answers nothing
        t.unit.recv(msg.data16)

    def _send(self, words):
        """`DEUUnit` has already counted these in `stats.wordsOut`."""
        if self.dkBus is None or len(words) == 0:
            return
        msg = BusMsg(len(words))
        for i, w in enumerate(words):
            msg.data16[i] = w & 0xffff
        self.dkBus.sendMsg(msg)

    def _sendMDU(self, tag, words=None):
        """The IDP -> MDU messages; the tags are `MDUMsg` in meds/medsConf."""
        words = words or []
        if self.mduCmdBus is None:
            return
        msg = BusMsg(1 + len(words))
        msg.data16[0] = tag
        for i, w in enumerate(words):
            msg.data16[1 + i] = int(w) & 0xffff
        self.mduCmdBus.sendMsg(msg)

    def _sendToMDUs(self, addr, words):
        self._sendMDU(MDUMsg.FILL, [addr] + list(words))

    def _sendPollTick(self):
        """The GPC polled this unit.  This drives POLL FAIL on the MDU's DPS
        display, and nothing else."""
        self._sendMDU(MDUMsg.POLL, [self._idNum()])

    def _idNum(self):
        # `@id` is the LRU NAME ("IDP1"), and the original writes it straight
        # into the halfword: `"IDP1" & 0xffff` is 0 in JavaScript, so that is
        # what goes on the wire.  Nothing reads it; matching it keeps a Python
        # IDP indistinguishable from the JavaScript one.
        return _js_uint16(self.id)

    def _kybdBars(self):
        """The forward keyboards this unit takes keys from, bit 0 left and
        bit 1 right: what its MDUs draw as keyboard bars."""
        if self.kybdSel is not None:
            return self.kybdSel & 3
        return ((1 if '_KYBD1' in self.bus else 0) |
                (2 if '_KYBD2' in self.bus else 0))

    def _heartbeat(self):
        """The IDP's own heartbeat, free-running.  An MDU is autonomous when
        its port goes quiet, and a port is quiet only when the IDP has stopped
        -- not when a GPC has.  Eight beats a second is what lets the MDU hold
        the DEU flash's 5/8 : 3/8 duty cycle."""
        if self._hbTimer is not None:
            return
        beat = lambda: self._sendMDU(MDUMsg.HEARTBEAT,
                                     [self._idNum(), self._kybdBars()])
        if self.threaded:
            # IDP POWER ON arrives on the pump thread, which has no Qt event
            # loop for a QTimer to run in.
            self._hbTimer = BusPump.get().every(HEARTBEAT_MS, beat)
            return
        self._hbTimer = QTimer()
        self._hbTimer.timeout.connect(beat)
        self._hbTimer.start(HEARTBEAT_MS)

    def _sendClock(self, t):
        """The header clock, straight from the GPC.  It does NOT go into
        display memory: the GPC's own variable-data fill covers 0x19EE..0x1AB2,
        so drawing there would overwrite the fields the GPC is updating."""
        if t is None:
            return
        # THE WORDS ARE HALFWORDS, and a time of day is more seconds than
        # one holds: 16 bits wrapped at 65536 s, so a GMT of day 1 00:00:03
        # (86403 s) reached the display as 000/05:47:47, and the clock seemed
        # to start at a fixed five-and-three-quarter hours.  The high halves
        # ride AFTER the original three words, so an MDU that reads only
        # those -- the Electron one -- still sees what it always did.
        mis = max(0, jsround(t['mission']))
        evt = max(0, jsround(t['event']))
        _clock_log("send IDP%s mission=%d" % (self.id, mis))
        self._sendMDU(MDUMsg.CLOCK, [mis & 0xffff, evt & 0xffff, t['conv'],
                                     (mis >> 16) & 0xffff, (evt >> 16) & 0xffff])

    def _resetScratchPad(self):
        self._sendMDU(MDUMsg.RESET_SPL)

    def recvMDU(self, t, busID, msg, remote):
        # THE MAJOR FUNCTION SWITCH.  It lives on the MCDS keyboard unit, not
        # on the crew discretes panel, and PASS reads it from the poll header.
        # What matters is the CHANGE: a major function change is what calls
        # ARY_MF_BUS_CHG to pick a DK bus commander.
        if int(msg.data16[0]) == MDUMsg.SET_MAJOR_FUNC:
            mf = int(msg.data16[1]) & 3
            was = t.unit.majorFunc if t.unit is not None else None
            # Logged on a change only: panelO6.py re-asserts it every second.
            if t.unit is not None and mf != was:
                t.unit.majorFunc = mf
                t.unit.log("IDP%s: major function %s -> %s%s"
                           % (t.id, was, mf,
                              " (the INVALID position)" if mf == 3 else ""))
            return
        if int(msg.data16[0]) == MDUMsg.KYBD_SEL:
            sel = (int(msg.data16[1]) & 3) if len(msg.data16) > 1 else 0
            if sel != t.kybdSel:
                names = {None: "every wired keyboard", 0: "no forward keyboard",
                         1: "the left keyboard", 2: "the right keyboard",
                         3: "both forward keyboards"}
                t.unit.log("IDP%s: IDP/CRT SEL -> %s" % (t.id, names[sel]))
                t.kybdSel = sel
            return
        if int(msg.data16[0]) == MDUMsg.IDP_POWER:
            t.setPower(len(msg.data16) > 1 and int(msg.data16[1]) != 0)
            return
        if int(msg.data16[0]) == MDUMsg.DEU_LOAD:
            t.deuLoad()
            return
        if int(msg.data16[0]) < MDUMsg.FILL:
            print("IDP%s: %s recv %s" % (t.id, busID, msg))

    # -- the display's own state, for a snapshot ----------------------------
    #
    # DISPLAY MEMORY *IS* THE PICTURE.  Everything an MDU draws it draws from
    # DEUUnit.mem, so saving that array and pushing it back is the whole of
    # restoring a display -- no geometry, no glyph state, no Screen_DPS
    # internals, all of which refresh() derives from the words.
    #
    # It has to be saved, not re-derived.  The static format text arrives
    # ONCE, at DEU load time, as a format fill: measured at 8 in a whole
    # 420-second run, against 367 display fills of the changing fields.  So a
    # restore that waits for PASS to repaint gets the foreground and never
    # the background -- which is exactly what a restored display looked like
    # before this: live numbers on an empty screen (gpc-causes #174).
    #
    # BOTH HALVES RUN ON THE PUMP THREAD.  From IDP.start() on, everything an
    # IDP does runs there and nothing else may touch it without a lock -- see
    # BusPump.  The callers hand these to BusPump.call.

    def snapshotNumber(self):
        """The unit's NUMBER, for a snapshot file name.

        `self.id` is the LRU name -- "IDP1", not "1" -- so naming files after
        it gave idpIDP1.json, while everything asking for them wanted
        idp1.json.  The save worked, wrote both files and reported success;
        only the name was wrong, so the wait timed out and the failure said
        "missing idp1.json" while idpIDP1.json sat beside it.
        """
        digits = "".join(c for c in str(self.id) if c.isdigit())
        return digits or str(self.id)

    def snapshotState(self):
        """Everything about this unit that a memory image does not carry."""
        u = self.unit
        return {
            'id': str(self.id),
            'powered': bool(self.powered),
            'majorFunc': int(u.majorFunc),
            'ipled': bool(u.ipled),
            'iplRunning': bool(u.iplRunning),
            'msgResetPending': bool(u.msgResetPending),
            'ackPending': bool(u.ackPending),
            'iplError': bool(u.iplError),
            'iplCircuitError': bool(u.iplCircuitError),
            'selfTest': bool(u.selfTest),
            'swStatus': int(u.swStatus),
            'deuId': u.deuId,
            'kybdSel': self.kybdSel,
            # The scratch pad, which is crew-paced and so may be half-typed at
            # any moment; waiting for it to be empty would be an unbounded
            # wait, so it travels.
            'spl': u.spl._snapshot(),
            'keyQueue': [list(k) for k in u.keyQueue],
            # A transfer in progress is NOT saved: it is a few milliseconds
            # long and the next command clears it anyway.  Recorded so a
            # reader knows whether one was cut across.
            'xferInFlight': u.xfer is not None,
        }

    def restoreState(self, state, mem):
        """Put the unit back, and repaint every MDU from the words."""
        u = self.unit
        if mem is not None and len(mem) == DEU.DEU_MEMORY_WORDS:
            u.mem[:] = mem
        u.majorFunc = int(state.get('majorFunc', u.majorFunc))
        u.ipled = bool(state.get('ipled', u.ipled))
        u.iplRunning = bool(state.get('iplRunning', False))
        u.msgResetPending = bool(state.get('msgResetPending', False))
        u.ackPending = bool(state.get('ackPending', False))
        u.iplError = bool(state.get('iplError', False))
        u.iplCircuitError = bool(state.get('iplCircuitError', False))
        u.selfTest = bool(state.get('selfTest', False))
        u.swStatus = int(state.get('swStatus', u.swStatus))
        u.deuId = state.get('deuId', u.deuId)
        if state.get('kybdSel') is not None:
            self.kybdSel = int(state['kybdSel'])
        spl = state.get('spl')
        if spl:
            try:
                u.spl._restore(spl)
            except Exception:
                pass
        del u.keyQueue[:]
        u.keyQueue.extend(list(k) for k in state.get('keyQueue', []))
        u.xfer = None
        # NOT powerUp(), which clears the memory just restored.  The switch
        # position is set directly and the heartbeat started if it is on.
        self.powered = bool(state.get('powered', True))
        if self.powered:
            self._heartbeat()
            # The same one message _clearMDUs uses, with the words instead of
            # zeros: the whole of display memory in one fill.
            self._sendToMDUs(0, [int(w) for w in u.mem])
        self.unit.log("IDP%s: restored %d word(s) of display memory%s"
                      % (self.id, DEU.DEU_MEMORY_WORDS,
                         "" if self.powered else " (unit is powered off)"))

    def _clearMDUs(self):
        """The unit's memory was cleared; so is every MDU's copy of it."""
        self._sendToMDUs(0, [0] * DEU.DEU_MEMORY_WORDS)

    def setPower(self, on):
        """IDP POWER.  OFF: the unit stops answering the DK bus and its
        heartbeat stops, so its MDUs go AUTONOMOUS after IDP_LOST_MS exactly
        as they do for a dead IDP.  ON: a cold unit that needs loading."""
        if bool(on) == self.powered:
            return
        self.powered = bool(on)
        if not self.powered:
            if self._hbTimer is not None:
                self._hbTimer.stop()
                self._hbTimer = None
            self.unit.xfer = None
            self.unit.log("IDP%s: POWER OFF" % self.id)
            return
        self.unit.powerUp()
        self.unit.log("IDP%s: POWER ON -- memory cleared, requesting IPL" % self.id)
        self._heartbeat()
        self._clearMDUs()

    def deuLoad(self):
        """DEU LOAD pushed.  Nothing happens to an unpowered unit."""
        if not self.powered:
            self.unit.log("IDP%s: DEU LOAD ignored -- IDP POWER is OFF" % self.id)
            return
        self.unit.requestLoad()
        self.unit.log("IDP%s: DEU LOAD -- memory cleared, requesting IPL" % self.id)
        self._clearMDUs()

    def recvKYBD(self, t, busID, msg, remote):
        if not t.powered:
            return
        bit = {'_KYBD1': 1, '_KYBD2': 2}.get(busID)
        if t.kybdSel is not None and bit is not None and not (t.kybdSel & bit):
            return                       # IDP/CRT SEL has that keyboard elsewhere
        for w in msg.data16:
            k = KYBD.byScan(int(w))
            if k is not None:
                t.unit.pressKey(k['gpcCode'])
            else:
                print("IDP%s: unknown keyboard scan code 0x%x"
                      % (t.id, int(w) & 0xffff))

    # -- dev/testing (only with --dev) --------------------------------------
    def loadFCWs(self, words, addr=None):
        """Load a raw format control word stream into display memory at the
        display header address, which is where a refresh starts."""
        if addr is None:
            addr = DEU.ADDR.DISPLAY_HEADER
        for i, w in enumerate(words):
            self.unit.mem[(addr + i) & (DEU.DEU_MEMORY_WORDS - 1)] = w & 0xffff
        self._sendToMDUs(addr, list(words))

    def execDPS(self):
        with open(os.path.join(self.CONFIG['NSTS_TOP'], 'data',
                               'TEST-9011-GPC_MEMORY.dfb'), 'rb') as f:
            self.bgDFB = f.read()
        self.loadFCWs(wordsFromBytes(self.bgDFB))

    def exec_(self):
        if not self.powered:
            # Off at start-up: no heartbeat, so the MDU goes AUTONOMOUS until
            # IDP POWER is switched ON -- and a unit then comes up cold and
            # asks to be loaded, as it would on the vehicle.
            self.unit.log("IDP%s: POWER OFF -- switch IDP POWER ON on the MDU's pane"
                          % self.id)
            self.unit.ipled = False
            return
        self._heartbeat()
        # dev mode has no GPC at all, so the test background is loaded once
        # here rather than driven from the bus.
        if self.CONFIG.get('dev') and not self.bgDFB:
            self.execDPS()


def idp_start(CONFIG):
    print("start IDP", CONFIG.get('config'))
    return IDP(CONFIG)


# ===========================================================================
# The live feed-parameter editor (debug)
#
# Double-click outside the display canvas -- or Shift+X -- opens a panel to
# the right of the active area listing the current screen's curData fields;
# edits apply live via the screen's refreshFeed().  Screen-provided test
# controls render as sliders, pulldowns or checkboxes above them, and every
# screen gets the reference-overlay group appended.
# ===========================================================================

_PANEL_CSS = """
QWidget#paramPanel { background: rgba(16,19,54,225); border: 1px solid #7f7; }
QLabel { color: #7f7; font: 12px monospace; }
QCheckBox::indicator { width: 12px; height: 12px; background: #000;
                       border: 1px solid #575; }
QCheckBox::indicator:checked { background: #7f7; }
QScrollBar:vertical { background: #101336; width: 10px; }
QScrollBar::handle:vertical { background: #575; min-height: 20px; }
QSlider::groove:horizontal { height: 4px; background: #234; }
QSlider::handle:horizontal { width: 9px; background: #7f7; margin: -5px 0; }
QLabel#hdr { color: #2df; font: bold 12px monospace; }
QLabel#grp { color: #2df; font: bold 12px monospace; border-top: 1px solid #345; }
QLabel#lab { color: #fd6; font: 12px monospace; }
QLabel#rdo { color: #7f7; font: 12px monospace; }
QLineEdit { background: #000; color: #7f7; border: 1px solid #575; font: 12px monospace; }
QComboBox { background: #000; color: #fd6; border: 1px solid #a83; font: 12px monospace; }
QComboBox QAbstractItemView { background: #000; color: #fd6; selection-background-color: #234; }
QPushButton { font: 12px monospace; }
"""


class ParamPanel(QtWidgets.QWidget):
    PW = 320

    def __init__(self, mdu, scr, data, tcs):
        parent = mdu.win
        QtWidgets.QWidget.__init__(self, parent)
        self.setObjectName('paramPanel')
        # a plain QWidget ignores a stylesheet background unless it is told to
        # honour one, which is what left the panel see-through
        self.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)
        self.setStyleSheet(_PANEL_CSS)
        self.mdu = mdu
        self.scr = scr
        self.inputs = {}
        self.tcSyncs = []
        self._drag = None

        outer = QtWidgets.QVBoxLayout(self)
        outer.setContentsMargins(8, 6, 8, 6)
        outer.setSpacing(2)

        self.hdr = QtWidgets.QLabel("%s feed  (drag me)" % mdu.curDisplay)
        self.hdr.setObjectName('hdr')
        self.hdr.setCursor(Qt.CursorShape.SizeAllCursor)
        outer.addWidget(self.hdr)

        area = QtWidgets.QScrollArea()
        area.setWidgetResizable(True)
        area.setFrameShape(QtWidgets.QFrame.Shape.NoFrame)
        area.setStyleSheet("background: transparent;")
        inner = QtWidgets.QWidget()
        inner.setStyleSheet("background: transparent;")
        self.form = QtWidgets.QVBoxLayout(inner)
        self.form.setContentsMargins(0, 0, 0, 0)
        self.form.setSpacing(2)
        area.setWidget(inner)
        outer.addWidget(area, 1)

        for tc in tcs:
            self._addControl(tc)
        # scalar fields only: nested objects/arrays are not editable here
        for k, v in list((data or {}).items()):
            if isinstance(v, bool) or isinstance(v, (int, float)) or isinstance(v, str):
                self._addField(k, v)

        btn = QtWidgets.QPushButton('reload')
        btn.clicked.connect(self.reloadVals)
        outer.addWidget(btn)

        # placed to the right of the active area, falling back to overlaying
        # the canvas when there is no room beside it
        r = mdu.disp.widget.geometry()
        left = r.right() + 12
        if left + self.PW > parent.width():
            left = max(4, parent.width() - self.PW - 4)
        maxH = max(120, parent.height() - r.top() - 24)
        self.setGeometry(left, r.top() + 8, self.PW - 20, maxH)

    # -- construction helpers ----------------------------------------------
    def _row(self, labelText):
        row = QtWidgets.QWidget()
        row.setStyleSheet("background: transparent;")
        h = QtWidgets.QHBoxLayout(row)
        h.setContentsMargins(0, 1, 0, 1)
        h.setSpacing(3)
        lab = QtWidgets.QLabel(labelText)
        lab.setObjectName('lab')
        lab.setFixedWidth(112)
        h.addWidget(lab)
        self.form.addWidget(row)
        return h

    def _addControl(self, tc):
        # {header: '...'} descriptors start a titled group
        if tc.get('header') is not None:
            gh = QtWidgets.QLabel(tc['header'])
            gh.setObjectName('grp')
            self.form.addWidget(gh)
            return
        # {range: [min, max, step]} renders a SLIDER with a live readout, so
        # the screen follows the thumb -- finding a geometry constant by
        # relaunching with an environment variable costs five minutes a guess.
        if tc.get('range') is not None:
            rlo, rhi, rstep = tc['range']
            h = self._row(tc['label'])
            sl = QtWidgets.QSlider(Qt.Orientation.Horizontal)
            steps = max(1, int(round((rhi - rlo) / rstep)))
            sl.setMinimum(0)
            sl.setMaximum(steps)
            sl.setFixedWidth(112)
            sl.setValue(int(round((float(tc['get']()) - rlo) / rstep)))
            rdo = QtWidgets.QLabel("%.2f" % float(tc['get']()))
            rdo.setObjectName('rdo')
            rdo.setFixedWidth(46)
            rdo.setAlignment(Qt.AlignmentFlag.AlignRight)

            def onMove(iv, tc=tc, rdo=rdo, rlo=rlo, rstep=rstep):
                v = rlo + iv * rstep
                rdo.setText("%.2f" % v)
                tc['set'](v)
                self.mdu.redraw()
            sl.valueChanged.connect(onMove)
            h.addWidget(sl)
            h.addWidget(rdo)
            h.addStretch(1)

            def sync(tc=tc, sl=sl, rdo=rdo, rlo=rlo, rstep=rstep):
                sl.blockSignals(True)
                sl.setValue(int(round((float(tc['get']()) - rlo) / rstep)))
                sl.blockSignals(False)
                rdo.setText("%.2f" % float(tc['get']()))
            self.tcSyncs.append(sync)
            return
        if tc.get('options') is not None:
            h = self._row(tc['label'])
            cb = QtWidgets.QComboBox()

            def fill(tc=tc, cb=cb):
                opts = tc['options']() if callable(tc['options']) else tc['options']
                cb.blockSignals(True)
                cb.clear()
                for o in opts:
                    cb.addItem(str(o))
                cb.blockSignals(False)
            fill()
            cur = tc['get']()
            i = cb.findText(str(cur))
            if i >= 0:
                cb.setCurrentIndex(i)

            def onChange(_i, tc=tc, cb=cb, fill=fill):
                tc['set'](cb.currentText())
                self.mdu.redraw()
                self.reloadVals()
                fill()
                j = cb.findText(str(tc['get']()))
                if j >= 0:
                    cb.blockSignals(True)
                    cb.setCurrentIndex(j)
                    cb.blockSignals(False)
            cb.currentIndexChanged.connect(onChange)
            h.addWidget(cb)
            h.addStretch(1)

            def sync(tc=tc, cb=cb, fill=fill):
                fill()
                j = cb.findText(str(tc['get']()))
                if j >= 0:
                    cb.blockSignals(True)
                    cb.setCurrentIndex(j)
                    cb.blockSignals(False)
            self.tcSyncs.append(sync)
            return
        h = self._row(tc['label'])
        ck = QtWidgets.QCheckBox()
        ck.setChecked(bool(tc['get']()))

        def onToggle(_s, tc=tc, ck=ck):
            tc['set'](ck.isChecked())
            self.mdu.redraw()
            self.reloadVals()
        ck.stateChanged.connect(onToggle)
        h.addWidget(ck)
        h.addStretch(1)
        self.tcSyncs.append(lambda tc=tc, ck=ck: ck.setChecked(bool(tc['get']())))

    def _addField(self, k, v):
        h = self._row(k)
        if isinstance(v, bool):
            ck = QtWidgets.QCheckBox()
            ck.setChecked(v)

            def onT(_s, k=k, ck=ck):
                self.mdu.screens[self.mdu.curDisplay].curData[k] = ck.isChecked()
                self._refresh()
            ck.stateChanged.connect(onT)
            h.addWidget(ck)
            h.addStretch(1)
            self.inputs[k] = ck
        else:
            t = 'number' if isinstance(v, (int, float)) else 'string'
            inp = QtWidgets.QLineEdit(_numstr(v) if t == 'number' else str(v))
            inp.setFixedWidth(80)

            def commit(k=k, inp=inp, t=t):
                d = self.mdu.screens[self.mdu.curDisplay].curData
                if t == 'number':
                    try:
                        n = float(inp.text())
                    except ValueError:
                        return
                    if n != n:
                        return
                    d[k] = n
                else:
                    d[k] = inp.text()
                self._refresh()
            inp.editingFinished.connect(commit)
            inp.returnPressed.connect(commit)
            h.addWidget(inp)
            h.addStretch(1)
            self.inputs[k] = inp

    def _refresh(self):
        s = self.mdu.screens.get(self.mdu.curDisplay)
        if s is not None:
            s.refreshFeed()
        self.mdu.redraw()

    def reloadVals(self):
        s = self.mdu.screens.get(self.mdu.curDisplay)
        d2 = (s.curData if s is not None else None) or {}
        for k, inp in self.inputs.items():
            if isinstance(inp, QtWidgets.QCheckBox):
                inp.blockSignals(True)
                inp.setChecked(bool(d2.get(k)))
                inp.blockSignals(False)
            else:
                inp.blockSignals(True)
                inp.setText(_numstr(d2.get(k)) if isinstance(d2.get(k), (int, float))
                            else str(d2.get(k)))
                inp.blockSignals(False)
        for sfn in self.tcSyncs:
            sfn()

    # -- draggable by the header -------------------------------------------
    def mousePressEvent(self, ev):
        if self.hdr.geometry().contains(ev.position().toPoint()):
            self._drag = ev.globalPosition().toPoint() - self.pos()
            ev.accept()

    def mouseMoveEvent(self, ev):
        if self._drag is not None:
            self.move(ev.globalPosition().toPoint() - self._drag)
            ev.accept()

    def mouseReleaseEvent(self, _ev):
        self._drag = None


# ===========================================================================
# The MDU window
#
# The Electron build made this a frameless BrowserWindow whose content area is
# EXACTLY the canvas, so a screenshot of the window is a screenshot of the
# display, 1:1.  NSTS_MDU_CHROME=<px> puts a title bar back and tells the
# display how much room to leave for it.
# ===========================================================================

# ===========================================================================
# The IDP control pane
#
# A strip down the right side of an MDU window carrying three IDP controls
# MEDS had no way to operate:
#
#   IDP POWER     2-position paddle, ON (up) / OFF (down)
#   IDP MAJ FUNC  3-position paddle, GNC (up) / SM (middle) / PL (down) --
#                 the same switch Shift+M and Shift+1..4 move
#   DEU LOAD      momentary pushbutton: PASS User's Guide Table 2-2 step 9,
#                 the push-and-release that makes a display unit ask to be
#                 loaded.  A unit asks by itself only when it is powered on,
#                 so without this a re-IPL can never bring GPCIPL's menu back
#                 to a unit PASS has already loaded -- GPCIPL loads a unit,
#                 and draws its menu, only when the unit's poll reply asks.
#
# They act on this display's PRIMARY IDP, over the same MDU -> IDP bus the
# major function switch already used, so the IDP may be in another process.
#
# DRAWN AS panelO6.py IS DRAWN, AT THE SAME SIZE -- its palette, its
# bat-handle paddles on a well and nut, its bezelled pushbutton, its Helvetica
# legends, and its arithmetic.  panelO6 at --size N draws N/768 PHYSICAL
# pixels per reference unit (Tk is not scaled by the desktop) and sizes text
# in points, round(size * N/768), which Tk renders through Xft at the
# desktop's Xft.dpi.  An MDU at --size N is N LOGICAL pixels high.  So the
# pane takes N/768 physical pixels per unit -- its canvas height over
# PANE_FULL, divided by the device pixel ratio -- and sets the same point
# sizes as Qt points, which on a desktop where Xft.dpi is Qt's logical dpi
# times the pixel ratio (192 = 96 x 2 here) come out as Tk's do.  The first
# version scaled by the canvas at 96 dpi and came out with paddles half as
# big again as panelO6's and text a quarter to a half too small.
#
# Line spacing follows Tk's metrics for Nimbus Sans rather than Qt's, which
# are taller: a linespace of 1.05 em, stacked letters ascent (0.75 em) plus
# 2 px apart.  The titles are two lines, "IDP/" over "POWER" and "IDP/" over
# "MAJ FUNC", as the orbiter's panels mark them, which keeps the pane narrow.
# HIDDEN BY DEFAULT: those switches are on panelO6.py now, panel C2 (IDP/CRT
# POWER, MAJ FUNC) and O6 (INTEGRATED DISPLAY PROCESSOR LOAD), where the
# orbiter has them.  --pane (or NSTS_MDU_PANE=1) puts the pane back.
# ===========================================================================

PANE_REF_W = 180                 # reference units across
PANE_FULL = 768                  # panelO6's --size unit: 768 is full size
PANE_SETTING = 8                 # panelO6's SETTING_SIZE
PANE_LINESPACE_EM = 1.05         # Tk's linespace for Nimbus Sans Bold
PANE_ASCENT_EM = 0.75            # and its ascent
# panelO6.py's palette, by the same names.
P_WINDOW = "#2a2a2a"
P_PANEL = "#c6c3b6"
P_PANEL_HI = "#dddaca"
P_PANEL_LO = "#8e8b7e"
P_INK = "#1b1b1b"
P_INK_DIM = "#3a3a3a"
P_GUARD = "#d9d6c9"
P_GUARD_LO = "#6a675c"
P_PADDLE = "#eceadf"
P_PADDLE_LO = "#8a877c"
P_PADDLE_GROOVE = "#4a4a46"
P_WELL = "#d9d6cb"
P_BTN = "#d5d2c6"
P_BTN_DOWN = "#8f8c80"
P_SHADOW = "#2a2a22"


class IDPPane(QtWidgets.QWidget):
    POWER_POS = ("ON", "OFF")                  # up, down
    MF_POS = ("GNC", "SM", "PL")               # up, middle, down
    MF_OF_POS = (1, 2, 0)                      # MF_NAMES indices
    POS_OF_MF = {1: 0, 2: 1, 0: 2}

    def __init__(self, mdu, parent):
        QtWidgets.QWidget.__init__(self, parent)
        self.mdu = mdu
        self.deuDown = False
        self._hits = []
        self.s = 1.0      # LOGICAL pixels per reference unit
        self.sp = 1.0     # PHYSICAL pixels per reference unit, panelO6's `s`
        self.dpr = 1.0
        self.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        self.setMouseTracking(True)
        self.setAutoFillBackground(False)
        self.setToolTip("IDP%s -- this display's primary IDP" % mdu.priPortIDP)

    # -- geometry: reference units -> widget pixels ---------------------------
    def X(self, x):
        return x * self.s

    def Y(self, y):
        return y * self.s

    def _ow(self, k=1.0):
        """panelO6's line widths, max(1, int(k * s)) physical pixels."""
        return max(1, int(k * self.sp)) / self.dpr

    def _pts(self, size):
        return max(1, int(round(size * self.sp)))

    def _font(self, size):
        f = QtGui.QFont("Helvetica")
        f.setBold(True)
        f.setPointSize(self._pts(size))
        return f

    def _em(self, size):
        """The em of a caption, in logical pixels."""
        return self._pts(size) * self.logicalDpiY() / 72.0

    def _th(self, size):
        """Half-height of a centred caption, in reference units -- half of
        Tk's linespace, as panelO6's _th is."""
        return 0.5 * PANE_LINESPACE_EM * self._em(size) / max(self.s, 0.01)

    # -- primitives, as panelO6's --------------------------------------------
    def _pen(self, color, w):
        if color is None:
            return QtGui.QPen(Qt.PenStyle.NoPen)
        pen = QtGui.QPen(QColor(color))
        pen.setWidthF(w)
        return pen

    def _brush(self, color):
        return QtGui.QBrush(QColor(color)) if color else QtGui.QBrush(Qt.BrushStyle.NoBrush)

    def _rect(self, p, x1, y1, x2, y2, fill=None, outline=None, width=1):
        p.setPen(self._pen(outline, width))
        p.setBrush(self._brush(fill))
        p.drawRect(QRectF(self.X(x1), self.Y(y1), self.X(x2) - self.X(x1),
                          self.Y(y2) - self.Y(y1)))

    def _oval(self, p, x1, y1, x2, y2, fill=None, outline=None, width=1):
        p.setPen(self._pen(outline, width))
        p.setBrush(self._brush(fill))
        p.drawEllipse(QRectF(self.X(x1), self.Y(y1), self.X(x2) - self.X(x1),
                             self.Y(y2) - self.Y(y1)))

    def _poly(self, p, pts, fill=None, outline=None, width=1):
        p.setPen(self._pen(outline, width))
        p.setBrush(self._brush(fill))
        p.drawPolygon(QtGui.QPolygonF([QPointF(self.X(x), self.Y(y)) for x, y in pts]))

    def _line(self, p, x1, y1, x2, y2, color, width=1):
        p.setPen(self._pen(color, width))
        p.drawLine(QPointF(self.X(x1), self.Y(y1)), QPointF(self.X(x2), self.Y(y2)))

    def _text(self, p, x, y, text, size, color=P_INK):
        p.setFont(self._font(size))
        p.setPen(QColor(color))
        w = self.X(PANE_REF_W)
        p.drawText(QRectF(self.X(x) - w, self.Y(y) - w, 2 * w, 2 * w),
                   Qt.AlignmentFlag.AlignCenter, text)

    def _vtext(self, p, x, y, text, size=PANE_SETTING, color=P_INK):
        """Stacked caption: ascent plus a 2 px gutter per letter, as panelO6."""
        f = self._font(size)
        fh = PANE_ASCENT_EM * self._em(size) + 2.0 / self.dpr
        chars = [ch for ch in text if not ch.isspace()]
        total = len(chars) * fh
        y0 = self.Y(y) - total / 2.0 + fh / 2.0
        p.setFont(f)
        p.setPen(QColor(color))
        for i, ch in enumerate(chars):
            cy = y0 + i * fh
            p.drawText(QRectF(self.X(x) - fh, cy - fh, 2 * fh, 2 * fh),
                       Qt.AlignmentFlag.AlignCenter, ch)

    def _rect_panel(self, p, x0, y0, x1, y1):
        """A rectangular crew-panel body, same surface as O6."""
        ow = max(2, int(2 * self.sp)) / self.dpr
        self._poly(p, [(x0 + 5, y0 + 6), (x1 + 5, y0 + 6),
                       (x1 + 5, y1 + 6), (x0 + 5, y1 + 6)], fill="#1a1a1a")
        self._rect(p, x0, y0, x1, y1, fill=P_PANEL, outline=P_INK, width=ow)
        self._line(p, x0, y0, x1, y0, P_PANEL_HI, ow)
        self._line(p, x0, y0, x0, y1, P_PANEL_HI, ow)
        self._line(p, x0, y1, x1, y1, P_PANEL_LO, ow)
        self._line(p, x1, y0, x1, y1, P_PANEL_LO, ow)

    def _switch_disk(self, p, cx, cy, r):
        self._oval(p, cx - r, cy - r, cx + r, cy + r, fill=P_WELL,
                   outline="#4a4840", width=self._ow())

    def _bushing(self, p, cx, cy, r):
        ow = self._ow()
        self._oval(p, cx - r * 1.25, cy - r * 1.25, cx + r * 1.25, cy + r * 1.25,
                   fill="#6e6b60", outline="#3a3830", width=ow)
        self._oval(p, cx - r, cy - r, cx + r, cy + r,
                   fill="#b0ada0", outline="#5a584c", width=ow)
        self._oval(p, cx - r * 0.55, cy - r * 0.55, cx + r * 0.55, cy + r * 0.55,
                   fill="#3a3830", outline="#1a1a18", width=1)

    def _bat_face(self, p, cx, cy, thick, ring=None):
        """End-on paddle: the handle is pointing at the viewer."""
        rx, ry = thick * 0.40, thick * 0.36
        ow = self._ow()
        self._oval(p, cx - rx + 1.5, cy - ry + 2, cx + rx + 1.5, cy + ry + 2,
                   fill=P_SHADOW)
        self._oval(p, cx - rx, cy - ry, cx + rx, cy + ry,
                   fill=P_PADDLE, outline=ring or P_PADDLE_LO,
                   width=ow if ring is None else max(2, int(2.5 * self.sp)) / self.dpr)
        self._oval(p, cx - rx * 0.55, cy - ry * 0.65, cx + rx * 0.05, cy - ry * 0.05,
                   fill="#ffffff")
        irx, iry = rx * 0.55, ry * 0.55
        self._oval(p, cx - irx, cy - iry, cx + irx, cy + iry,
                   outline=P_PADDLE_GROOVE, width=ow)

    def _bat_thrown(self, p, cx, cy, thick, span, sign, br):
        """Paddle thrown along y: sign -1 is up, +1 is down."""
        length = span * 0.40
        base_h = thick * 0.13
        tip_h = thick * 0.30
        along = tip_h * 0.70
        ow = self._ow()
        neck = br * 0.35
        y0 = cy + sign * neck
        y1 = cy + sign * length
        y_join = y1 - sign * along * 0.95
        pts = [(cx - base_h, y0), (cx + base_h, y0),
               (cx + tip_h, y_join), (cx - tip_h, y_join)]
        self._poly(p, [(x + 1.2, y + 1.8 * sign) for x, y in pts], fill=P_SHADOW)
        self._poly(p, pts, fill=P_PADDLE, outline=P_PADDLE_LO, width=ow)
        self._oval(p, cx - tip_h, y1 - along, cx + tip_h, y1 + along,
                   fill=P_PADDLE, outline=P_PADDLE_LO, width=ow)
        self._line(p, cx - base_h * 0.45, y0, cx - tip_h * 0.55, y_join,
                   "#ffffff", self._ow(1.5))
        self._oval(p, cx - tip_h * 0.55, y1 - along * 0.70,
                   cx + tip_h * 0.05, y1 - along * 0.05, fill="#ffffff")

    def _paddle(self, p, x1, y1, x2, y2, pos, npos, ring=None):
        """Vertical bat-handle paddle switch on a circular well."""
        cx, cy = (x1 + x2) / 2.0, (y1 + y2) / 2.0
        thick, span = x2 - x1, y2 - y1
        self._switch_disk(p, cx, cy, thick * 0.60 * 0.90)
        br = thick * 0.20
        self._bushing(p, cx, cy, br)
        if pos is None or (npos == 3 and pos == 1):
            self._bat_face(p, cx, cy, thick, ring)
            return
        t = pos / float(npos - 1) if npos > 1 else 0.0
        self._bat_thrown(p, cx, cy, thick, span, -1.0 if t < 0.5 else 1.0, br)

    def _pushbutton(self, p, x1, y1, x2, y2, down=False):
        fill = P_BTN_DOWN if down else P_BTN
        dx = 2 if down else 0
        self._rect(p, x1, y1, x2, y2, fill=P_GUARD, outline=P_GUARD_LO,
                   width=max(2, int(1.5 * self.sp)) / self.dpr)
        m = 6
        self._rect(p, x1 + m + dx, y1 + m + dx, x2 - m + dx, y2 - m + dx,
                   fill=fill, outline=P_PADDLE_LO, width=1.0 / self.dpr)

    # -- the pane --------------------------------------------------------------
    @staticmethod
    def _layout(top, pad, th10, ths):
        """Caption centres and control tops, in reference units, from `top`:
        panelO6's rhythm -- PAD of air above and below every caption."""
        L = {}
        y = top + pad + th10
        L['pt'] = y
        y += 2 * th10                       # the title's second line
        L['pt2'] = y
        y += th10 + pad + ths
        L['on'] = y
        L['psw'] = y + ths + pad
        y = L['psw'] + 124 + pad + ths
        L['off'] = y
        L['sep1'] = y + ths + pad
        y = L['sep1'] + pad + th10
        L['mt'] = y
        y += 2 * th10
        L['mt2'] = y
        y += th10 + pad + ths
        L['gnc'] = y
        L['msw'] = y + ths + pad
        y = L['msw'] + 136 + pad + ths
        L['pl'] = y
        L['sep2'] = y + ths + pad
        y = L['sep2'] + pad + th10
        L['dt'] = y
        L['dbtn'] = y + th10 + pad
        L['bottom'] = L['dbtn'] + 50 + pad
        return L

    def paintEvent(self, _ev):
        self.dpr = self.devicePixelRatioF() or 1.0
        self.sp = self.height() / float(PANE_FULL) if self.height() > 0 else 1.0
        self.s = self.sp / self.dpr
        p = QtGui.QPainter(self)
        p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing, True)
        p.fillRect(self.rect(), QColor(P_WINDOW))
        self._hits = []
        pad = 10
        th10, ths = self._th(10), self._th(PANE_SETTING)
        gw = 58
        # The panel body runs to the pane's right edge -- the window border --
        # leaving only the dark strip on the left as a divider from the
        # display.  A margin on the right too read as a stray black line
        # between the panel and the frame.  The controls centre in the body.
        x0 = 10
        x1 = self.width() / max(self.s, 0.01) + 2
        cx = (x0 + min(x1, PANE_REF_W)) / 2.0
        # The control block is centred in the pane's height, and the panel
        # body runs the full height of the pane, as the user asked: the
        # block's height is its layout from 0, so lay it out once for that
        # and again from where it has to start.
        paneH = self.height() / max(self.s, 0.01)
        L = self._layout(0.0, pad, th10, ths)
        L = self._layout(max(0.0, (paneH - L['bottom']) / 2.0), pad, th10, ths)
        yPowerTitle, yPowerTitle2, yOn, powerTop, yOff, ySep1 = (
            L['pt'], L['pt2'], L['on'], L['psw'], L['off'], L['sep1'])
        yMfTitle, yMfTitle2, yGnc, mfTop, yPl, ySep2 = (
            L['mt'], L['mt2'], L['gnc'], L['msw'], L['pl'], L['sep2'])
        yDeuTitle, deuTop = L['dt'], L['dbtn']
        self._rect_panel(p, x0, 0, x1, paneH)

        # IDP POWER
        self._text(p, cx, yPowerTitle, "IDP/", 10)
        self._text(p, cx, yPowerTitle2, "POWER", 10)
        self._text(p, cx, yOn, "ON", PANE_SETTING)
        on = getattr(self.mdu, 'idpPower', True)
        self._paddle(p, cx - gw / 2, powerTop, cx + gw / 2, powerTop + 124,
                     0 if on else 1, 2)
        self._hits.append(('power', cx - gw / 2, powerTop, cx + gw / 2, powerTop + 124))
        self._text(p, cx, yOff, "OFF", PANE_SETTING)
        self._line(p, x0 + 6, ySep1, x1 - 6, ySep1, P_INK_DIM, 1)

        # IDP MAJ FUNC.  ILLEGAL (Shift+4) is not a place the paddle can be;
        # it shows the handle end-on, ringed in red, rather than lying about it.
        self._text(p, cx, yMfTitle, "IDP/", 10)
        self._text(p, cx, yMfTitle2, "MAJ FUNC", 10)
        self._text(p, cx, yGnc, "GNC", PANE_SETTING)
        mf = (getattr(self.mdu, 'majorFunc', 0) or 0) & 3
        if mf == 3:
            self._paddle(p, cx - gw / 2, mfTop, cx + gw / 2, mfTop + 136, None, 3,
                         ring="#c0201a")
        else:
            self._paddle(p, cx - gw / 2, mfTop, cx + gw / 2, mfTop + 136,
                         self.POS_OF_MF[mf], 3)
        self._hits.append(('mf', cx - gw / 2, mfTop, cx + gw / 2, mfTop + 136))
        self._vtext(p, cx + gw / 2 + 14 + PANE_SETTING * 2 / 3.0,
                    mfTop + 136 / 2.0, "SM")
        self._text(p, cx, yPl, "PL", PANE_SETTING)
        self._line(p, x0 + 6, ySep2, x1 - 6, ySep2, P_INK_DIM, 1)

        # DEU LOAD
        self._text(p, cx, yDeuTitle, "DEU LOAD", 10)
        self._pushbutton(p, cx - 25, deuTop, cx + 25, deuTop + 50, self.deuDown)
        self._hits.append(('deu', cx - 25, deuTop, cx + 25, deuTop + 50))
        p.end()

    # -- mouse -----------------------------------------------------------------
    def _find(self, pos):
        x, y = pos.x() / max(self.s, 0.01), pos.y() / max(self.s, 0.01)
        for kind, x1, y1, x2, y2 in self._hits:
            if x1 <= x <= x2 and y1 <= y <= y2:
                return kind, y1, y2, y
        return None

    @staticmethod
    def _zone(y, y1, y2, npos):
        """Which of npos vertical slots was clicked?  0 = up."""
        t = (y - y1) / float(y2 - y1) if y2 != y1 else 0.5
        t = 0.0 if t < 0 else 1.0 if t > 1 else t
        return min(npos - 1, int(t * npos))

    def mousePressEvent(self, ev):
        ev.accept()
        if ev.button() != Qt.MouseButton.LeftButton:
            return
        hit = self._find(ev.position())
        if hit is None:
            return
        kind, y1, y2, y = hit
        if kind == 'power':
            on = self.POWER_POS[self._zone(y, y1, y2, 2)] == "ON"
            if on != getattr(self.mdu, 'idpPower', True):
                self.mdu.setIdpPower(on)
        elif kind == 'mf':
            mf = self.MF_OF_POS[self._zone(y, y1, y2, 3)]
            if mf != self.mdu.majorFunc:
                self.mdu.setMajorFunc(mf)
        elif kind == 'deu':
            self.deuDown = True
            self.mdu.deuLoad()
        self.update()

    def mouseDoubleClickEvent(self, ev):
        # A double click here is two presses on a control, not the window's
        # parameter-editor gesture.
        self.mousePressEvent(ev)

    def mouseReleaseEvent(self, ev):
        ev.accept()
        if self.deuDown:
            self.deuDown = False
            self.update()

    def mouseMoveEvent(self, ev):
        want = self._find(ev.position()) is not None
        self.setCursor(Qt.CursorShape.PointingHandCursor if want
                       else Qt.CursorShape.ArrowCursor)


# ===========================================================================
# The edgekeys themselves: six pushbuttons in the bezel under the display.
#
# On the orbiter they are hardware, not screen: DPS Workbook USA005350 Rev B
# figure 2-26 (p. 2-33) and the photograph in yaShuttle/MDU.jpg both show six
# square keys in a row in the bottom bezel, below the glass, a rounded rib at
# either end and between each pair, each key directly under the legend box
# the menu area draws for it (the photograph's key pitch is 0.149 of the
# display's width; the legend boxes' is 7.75 of 52.24 display units, 0.148).
# The logic was always here -- F1..F6 press them -- and a click on a key goes
# through the same MDUEdgeKeys.press/release, so holding one down for
# STUCK_MS fails it exactly as holding F-key does.  The strip is as wide as
# the canvas and EDGE_STRIP_K of that high, and the window grows by that
# much.  --no-edgekeys or NSTS_MDU_EDGEKEYS=0 leaves it off.
# ===========================================================================

EDGE_STRIP_K = 0.09              # strip height per unit of canvas width
E_BEZEL = "#a9a9a6"              # the MDU's grey bezel (MDU.jpg)
E_BEZEL_LO = "#5f5f5c"
E_RIB = "#c2c2bf"
E_RIB_LO = "#6b6b68"
E_KEY = "#141414"
E_KEY_FACE = "#f0f0f0"
E_KEY_DOWN = "#8c8c8c"


def _edgekeys_wanted(opts):
    """The edgekey pushbuttons: on unless --no-edgekeys; NSTS_MDU_EDGEKEYS=0
    turns them off and =1 on, whatever the option."""
    e = str(env('NSTS_MDU_EDGEKEYS', '')).strip()
    if e in ('0', '1'):
        return e == '1'
    return bool(opts.get('edgekeys', True))


class MDUEdgeKeyStrip(QtWidgets.QWidget):
    def __init__(self, mdu, parent):
        QtWidgets.QWidget.__init__(self, parent)
        self.mdu = mdu
        self.down = None
        self._keys = []
        self.setFocusPolicy(Qt.FocusPolicy.NoFocus)   # the keyboard stays with the MDU
        self.setMouseTracking(True)
        self.setAutoFillBackground(False)

    def _centres(self):
        """Each key's centre in display units: the middle of its legend box."""
        area = getattr(self.mdu, 'mdu_menuArea', None)
        boxes = getattr(area, 'menuBoxX', None) if area is not None else None
        if boxes and len(boxes) == 6:
            return [(a + b) / 2.0 for a, b in boxes]
        return [3.3 + i * 7.75 + (0.05 if i >= 3 else 0.0) + 3.75 for i in range(6)]

    def _layout(self):
        disp = getattr(self.mdu, 'disp', None)
        left = getattr(disp, 'CAM_L', 0.20)
        right = getattr(disp, 'CAM_R', 52.442456)
        W, H = float(self.width()), float(self.height())
        u = W / (right - left)                 # pixels per display unit
        pitch = 7.75 * u
        side = min(0.42 * pitch, 0.66 * H)
        cy = H / 2.0
        keys = [QRectF((c - left) * u - side / 2.0, cy - side / 2.0, side, side)
                for c in self._centres()]
        ribW = max(2.0, 0.09 * pitch)
        ribH = 0.84 * H
        xs = [(c - left) * u for c in self._centres()]
        ribX = [xs[0] - pitch / 2.0] + [(a + b) / 2.0 for a, b in zip(xs, xs[1:])] \
            + [xs[-1] + pitch / 2.0]
        ribs = [QRectF(x - ribW / 2.0, cy - ribH / 2.0, ribW, ribH) for x in ribX]
        return keys, ribs

    def paintEvent(self, _ev):
        keys, ribs = self._layout()
        self._keys = keys
        p = QtGui.QPainter(self)
        p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing, True)
        p.fillRect(self.rect(), QColor(E_BEZEL))
        p.setPen(QtGui.QPen(QColor(E_BEZEL_LO), 1.0))
        p.drawLine(QPointF(0, 0.5), QPointF(self.width(), 0.5))
        for r in ribs:
            p.setPen(QtGui.QPen(QColor(E_RIB_LO), 1.0))
            p.setBrush(QColor(E_RIB))
            p.drawRoundedRect(r, r.width() / 2.0, r.width() / 2.0)
        for i, r in enumerate(keys):
            down = (i == self.down)
            if down:
                r = r.translated(0, 1.0)
            p.setPen(QtGui.QPen(QColor(E_BEZEL_LO), 1.0))
            p.setBrush(QColor(E_KEY))
            p.drawRect(r)
            m = r.width() * 0.16
            pen = QtGui.QPen(QColor(E_KEY_DOWN if down else E_KEY_FACE),
                             max(1.0, r.width() * 0.07))
            p.setPen(pen)
            p.setBrush(Qt.BrushStyle.NoBrush)
            p.drawRect(r.adjusted(m, m, -m, -m))
        p.end()

    def _keyAt(self, pos):
        for i, r in enumerate(self._keys):
            if r.contains(pos):
                return i
        return None

    def mousePressEvent(self, ev):
        ev.accept()
        if ev.button() != Qt.MouseButton.LeftButton:
            return
        i = self._keyAt(ev.position())
        if i is None:
            return
        self.down = i
        keys = getattr(self.mdu, '_edgeKeys', None)
        if keys is not None:
            keys.press(i)
        self.update()

    def mouseDoubleClickEvent(self, ev):
        # two presses on a key, not the window's parameter-editor gesture
        self.mousePressEvent(ev)

    def mouseReleaseEvent(self, ev):
        ev.accept()
        if self.down is None:
            return
        i, self.down = self.down, None
        keys = getattr(self.mdu, '_edgeKeys', None)
        if keys is not None:
            keys.release(i)
        self.update()

    def mouseMoveEvent(self, ev):
        want = self._keyAt(ev.position()) is not None
        self.setCursor(Qt.CursorShape.PointingHandCursor if want
                       else Qt.CursorShape.ArrowCursor)


class MDUWindow(QtWidgets.QWidget):
    def __init__(self, name, lruConf, dev=False):
        QtWidgets.QWidget.__init__(self)
        self.lruName = name
        self.lruConf = lruConf
        self._keydown = []
        self._keyup = []
        self._blurcb = []
        self._dblclick = []
        self._drag = None
        self.chrome = int(envnum('NSTS_MDU_CHROME', 0))
        self.chromeInset = int(envnum('NSTS_MDU_CHROME_X', 8)) if self.chrome > 0 else 0
        self.titleBar = None
        self.sidePane = None     # the IDP control pane, when there is one
        self.edgeStrip = None    # the edgekey pushbuttons under the display

        win = lruConf.get('window') or {}
        # A REAL WINDOW FRAME BY DEFAULT.  The Electron build asked for
        # `frame: false` and painted its own bar over the canvas when it
        # wanted one, which is why the display area and the surround are the
        # same flat colour and neither can be told from the desktop.  A
        # window-manager frame costs the display nothing: it sits outside the
        # client area, so the canvas keeps every pixel it had, and nothing the
        # renderer draws can paint over it.  NSTS_MDU_FRAMELESS=1 restores the
        # original's borderless window -- the content area is then exactly the
        # canvas again, which is what makes a window grab a 1:1 screenshot of
        # the display.
        self.frameless = bool(envnum('NSTS_MDU_FRAMELESS', 0)) or bool(win.get('fullscreen'))
        self.setWindowFlag(Qt.WindowType.FramelessWindowHint, self.frameless)
        bg = win.get('backgroundColor') or "#101336"
        self.setAutoFillBackground(True)
        pal = self.palette()
        pal.setColor(QtGui.QPalette.ColorRole.Window, QColor(bg))
        self.setPalette(pal)
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

        w = int(win.get('displayPx') or win.get('width') or 1024)
        # Shorter than the configured size by exactly the frustum's trim below
        # the menu (VectorDisplay.canvas_height_k), so the page keeps its scale.
        h = int(round(int(win.get('displayPx') or win.get('height') or 1024)
                      * VectorDisplay.canvas_height_k()))
        self.canvasW = w
        self.canvasH = h
        if self.chrome > 0:
            self.titleBar = QtWidgets.QLabel("", self)
            self.titleBar.setStyleSheet(
                "background:#1b2040; color:#9cf; font: bold 12px sans-serif;"
                " padding-left:6px;")
            self.titleBar.setGeometry(0, 0, w + 2 * self.chromeInset, self.chrome)
        # THE DISPLAY RESIZES WITH THE WINDOW, keeping its aspect ratio.  The
        # render resolution is fixed by the config, so growing the window does
        # not redraw anything at a finer grain -- but it does scale the stroke
        # weights with it, because `pxRatio` is the framebuffer size over the
        # config width, which is the same arithmetic `--size` uses to shrink
        # them.  The canvas is letterboxed in `backgroundColor` while a drag
        # is in flight, then the window snaps back to the exact ratio.
        self.canvas = None
        self._aspect = float(w) / float(h) if h else 1.0
        self.resize(w + 2 * self.chromeInset, h + self.chrome)
        self.setMinimumSize(160 + 2 * self.chromeInset, 160 + self.chrome)
        self._snapTimer = QTimer(self)
        self._snapTimer.setSingleShot(True)
        self._snapTimer.timeout.connect(self._snapToAspect)
        pos = self._envPos()
        if pos is not None:
            self.move(pos[0], pos[1])
        elif win.get('x') is not None:
            self.move(int(win['x']), int(win['y']))
        if win.get('fullscreen'):
            self.showFullScreen()
        self.setWindowTitle("%s / %s" % (WINDOW_TITLE,
                                         lruConf.get('config', {}).get('lru')
                                         or name))

    @staticmethod
    def _envPos():
        """NSTS_MDU_POS=<x>,<y> places this window, overriding the config.
        Two windows that default to the same spot land exactly on top of each
        other and the one underneath is the one you need to watch."""
        spec = env('NSTS_MDU_POS')
        if not spec:
            return None
        m = re.match(r'^\s*(-?\d+)\s*,\s*(-?\d+)\s*$', spec)
        if not m:
            return None
        return [int(m.group(1)), int(m.group(2))]

    def setChromeTitle(self, t):
        if self.titleBar is not None:
            self.titleBar.setText(t)

    # -- the canvas keeps the config's aspect ratio inside whatever room the
    #    window has, centred, with `backgroundColor` showing either side ----
    def setCanvas(self, widget):
        self.canvas = widget
        self.layoutCanvas()

    def _paneK(self):
        """The pane's width per unit of canvas height; 0 with no pane.  Its
        scale is canvas/PANE_FULL PHYSICAL pixels per reference unit (see
        IDPPane), so in logical pixels it depends on the pixel ratio."""
        if self.sidePane is None:
            return 0.0
        return PANE_REF_W / (float(PANE_FULL) * (self.devicePixelRatioF() or 1.0))

    def _stripK(self):
        """The edgekey strip's height per unit of canvas width; 0 with none."""
        return EDGE_STRIP_K if self.edgeStrip is not None else 0.0

    def setEdgeStrip(self, strip):
        """Put the edgekey pushbuttons under the display, making the window
        taller by exactly the strip so the canvas keeps every pixel it had."""
        self.edgeStrip = strip
        _x, _y, cw, _ch = self.canvasBox()
        self.resize(self.width(), self.height() + int(round(EDGE_STRIP_K * cw)))
        strip.show()
        self.layoutCanvas()

    def stripBox(self):
        x, y, cw, ch = self.canvasBox()
        return (x, y + ch, cw, max(1, int(round(self._stripK() * cw))))

    def setSidePane(self, pane):
        """Put the IDP control pane down the right-hand side, widening the
        window by exactly its width so the canvas keeps every pixel it had."""
        self.sidePane = pane
        _x, _y, _cw, ch = self.canvasBox()
        self.resize(self.width() + int(round(self._paneK() * ch)), self.height())
        pane.show()
        self.layoutCanvas()

    def _layoutBox(self):
        """The canvas and the pane beside it, as one block centred in the
        room the window has: the canvas keeps its aspect ratio, and the pane
        is as tall as the canvas and _paneK() times that wide."""
        availW = max(1, self.width() - 2 * self.chromeInset)
        availH = max(1, self.height() - self.chrome)
        k = self._paneK()
        sk = self._stripK() * self._aspect     # strip height per unit canvas height
        tall = availH / (1.0 + sk)
        ch = min(tall, availW / (self._aspect + k)) if (self._aspect + k) else tall
        cw = ch * self._aspect
        pw = ch * k
        x = self.chromeInset + (availW - (cw + pw)) / 2.0
        y = self.chrome + (availH - ch * (1.0 + sk)) / 2.0
        return x, y, cw, ch, pw

    def canvasBox(self):
        x, y, cw, ch, _pw = self._layoutBox()
        return (int(round(x)), int(round(y)), max(1, int(round(cw))),
                max(1, int(round(ch))))

    def paneBox(self):
        x, y, cw, ch, pw = self._layoutBox()
        return (int(round(x + cw)), int(round(y)), max(1, int(round(pw))),
                max(1, int(round(ch))))

    def layoutCanvas(self):
        if self.canvas is None:
            return
        x, y, cw, ch = self.canvasBox()
        self.canvas.setGeometry(x, y, cw, ch)
        if self.sidePane is not None:
            # To the window's right edge, whatever the rounding: a pixel of
            # window background between pane and frame shows as a dark line.
            px, py, _pw, ph = self.paneBox()
            self.sidePane.setGeometry(px, py, max(1, self.width() - self.chromeInset - px), ph)
        if self.edgeStrip is not None:
            self.edgeStrip.setGeometry(*self.stripBox())
        if self.titleBar is not None:
            self.titleBar.setGeometry(0, 0, self.width(), self.chrome)
        disp = getattr(getattr(self, 'lru', None), 'disp', None)
        if disp is not None:
            for o in disp._overlays.values():
                o.setGeometry(0, 0, self.width(), self.height())
        # keep the param editor inside the window when it shrinks
        panel = getattr(getattr(self, 'lru', None), '_paramPanel', None)
        if panel is not None:
            panel.move(max(0, min(panel.x(), self.width() - panel.width())),
                       max(0, min(panel.y(), self.height() - panel.height())))

    def resizeEvent(self, ev):
        self.layoutCanvas()
        # Snap the window itself to the ratio once the drag settles, so the
        # letterbox bars close up rather than becoming permanent furniture.
        self._snapTimer.start(250)
        QtWidgets.QWidget.resizeEvent(self, ev)

    def _snapToAspect(self):
        if self.isFullScreen() or self.isMaximized():
            return
        _x, _y, cw, ch = self.canvasBox()
        pw = self.paneBox()[2] if self.sidePane is not None else 0
        sh = self.stripBox()[3] if self.edgeStrip is not None else 0
        want = QtCore.QSize(cw + pw + 2 * self.chromeInset, ch + sh + self.chrome)
        if want != self.size():
            self.resize(want)

    # -- 'document' event plumbing -----------------------------------------
    def onKeyDown(self, fn):
        self._keydown.append(fn)

    def onKeyUp(self, fn):
        self._keyup.append(fn)

    def onBlur(self, fn):
        self._blurcb.append(fn)

    def onDblClick(self, fn):
        self._dblclick.append(fn)

    def _focusTarget(self):
        fw = QtWidgets.QApplication.focusWidget()
        return fw

    def keyPressEvent(self, qev):
        ev = KeyEvent(qev, self._focusTarget())
        # Ctrl+Q quits, Ctrl+R reloads, Ctrl+Shift+D would open devtools
        if ev.ctrlKey and ev.key.lower() == 'q':
            QtWidgets.QApplication.instance().quit()
            return
        if ev.ctrlKey and not ev.shiftKey and ev.key.lower() == 'r':
            print("MEDS2: reload requested (Ctrl+R)")
            mdu = getattr(self, 'lru', None)
            if mdu is not None and getattr(mdu, 'disp', None) is not None:
                mdu.disp.dirty = True
            return
        for fn in list(self._keydown):
            fn(ev)
        if not ev.defaultPrevented:
            QtWidgets.QWidget.keyPressEvent(self, qev)

    def keyReleaseEvent(self, qev):
        if qev.isAutoRepeat():
            return
        ev = KeyEvent(qev, self._focusTarget())
        for fn in list(self._keyup):
            fn(ev)
        if not ev.defaultPrevented:
            QtWidgets.QWidget.keyReleaseEvent(self, qev)

    def focusOutEvent(self, qev):
        for fn in list(self._blurcb):
            fn()
        QtWidgets.QWidget.focusOutEvent(self, qev)

    def mouseDoubleClickEvent(self, ev):
        for fn in list(self._dblclick):
            fn(ev)

    # With no frame the window is dragged by its body, which is what
    # meds/style.css's `-webkit-app-region: drag` did.  With a real titlebar
    # that would fight the window manager, so it is left to the frame.
    def mousePressEvent(self, ev):
        if self.frameless and ev.button() == Qt.MouseButton.LeftButton:
            self._drag = ev.globalPosition().toPoint() - self.frameGeometry().topLeft()
            ev.accept()

    def mouseMoveEvent(self, ev):
        if self._drag is not None:
            self.move(ev.globalPosition().toPoint() - self._drag)
            ev.accept()

    def mouseReleaseEvent(self, _ev):
        self._drag = None

    def closeEvent(self, ev):
        # Electron quits on 'window-all-closed', not on the first close; Qt's
        # quitOnLastWindowClosed does the same, so just let the window go.
        ev.accept()


def _vd_attach(self, win):
    """Put the GL canvas in its window, at the render resolution, and start
    the redraw pump.  `--size` renders at the config resolution and scales the
    canvas down, so stroke weights shrink with it."""
    self.window = win
    if win is None:
        return
    self.widget.setParent(win)
    win.setCanvas(self.widget)
    # the canvas never takes the mouse: the window drags and the param editor
    # opens on a double-click anywhere over it
    self.widget.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents, True)
    self.widget.show()
    self._pump = QTimer(win)
    self._pump.timeout.connect(self._tick)
    self._pump.start(16)


# NSTS_GUI_STALL_MS=<ms>: A TEST OF BusPump.  Every redraw tick holds the GUI
# thread this long, standing in for a graphics driver that holds buffer swaps
# (a locked or hidden screen); NSTS_GUI_STALL_BUSY=1 spins instead of
# sleeping, so the GIL is held too, as a long Python redraw holds it.  The
# IDPs must go on answering the GPC through either; with NSTS_IDP_THREAD=0
# they cannot.
_GUI_STALL_S = envnum('NSTS_GUI_STALL_MS', 0) / 1000.0
_GUI_STALL_BUSY = str(env('NSTS_GUI_STALL_BUSY', '0')) not in ('', '0')


def _vd_tick(self):
    if _GUI_STALL_S > 0:
        if _GUI_STALL_BUSY:
            end = time.monotonic() + _GUI_STALL_S
            while time.monotonic() < end:
                pass
        else:
            time.sleep(_GUI_STALL_S)
    if self.dirty:
        self.widget.update()


VectorDisplay.attachTo = _vd_attach
VectorDisplay._tick = _vd_tick


# ===========================================================================
# The MEDS runner -- multi-window LRU launcher
#
# Ported from simRunner/main/main.civet's MedsRunner.  Each windowed LRU (an
# MDU display) gets its own frameless window; headless "shared" LRUs (IDPs)
# are bundled into the first windowed LRU, since they only need to join the
# UDP bus mesh and MUST NOT render.
# ===========================================================================

class MedsRunner(object):
    def __init__(self, opts):
        self.opts = opts
        self.windows = {}
        self.lrus = {}
        self.CONFIG = {}

    @staticmethod
    def deepMerge(target, source):
        for key in source.keys():
            v = source[key]
            if isinstance(v, dict):
                if not isinstance(target.get(key), dict):
                    target[key] = {}
                MedsRunner.deepMerge(target[key], v)
            else:
                target[key] = v
        return target

    def loadConfig(self):
        configPath = self.opts.get('configFile') or os.path.join(NSTS_TOP, 'config',
                                                                 'meds.json')
        with open(configPath, 'r') as f:
            c = json.load(f)

        # Optional override config via NSTS_SIM_CONFIG, deep-merged
        overridePath = env('NSTS_SIM_CONFIG')
        if overridePath:
            try:
                p = overridePath if os.path.isabs(overridePath) \
                    else os.path.join(NSTS_TOP, overridePath)
                with open(p, 'r') as f:
                    self.deepMerge(c, json.load(f))
                print("[meds] loaded config override from %s" % overridePath)
            except Exception as e:
                print("[meds] failed to load config override: %s" % overridePath, e)

        c['NSTS_TOP'] = NSTS_TOP
        # dev mode: LRUs run standalone with test feeds (CLI flag, or a
        # `"dev": true` in the config file)
        c['dev'] = bool(self.opts.get('dev') or c.get('dev', False))

        # CLI LRU list replaces the config's start list; names are
        # case-insensitive (config keys are lowercase)
        if self.opts.get('lrus'):
            c['start'] = [n.lower() for n in self.opts['lrus']]

        available = [n for n in (c.get('lrus') or {}).keys() if n != 'shared']
        unknown = [n for n in (c.get('start') or []) if n not in (c.get('lrus') or {})]
        if unknown:
            sys.stderr.write("meds: unknown LRU name(s): %s\n" % ', '.join(unknown))
            sys.stderr.write("available: %s\n" % ', '.join(available))
            sys.exit(2)

        # An MDU is square, so one dimension does it.  DISPLAY size only: the
        # render resolution stays put, so pixel-denominated strokes scale too.
        size = 0
        if self.opts.get('size') is not None:
            try:
                size = float(self.opts['size'])
            except (TypeError, ValueError):
                size = float('nan')
            if not (size == size) or size <= 0:
                sys.stderr.write("meds: --size wants a positive pixel count, got '%s'\n"
                                 % self.opts['size'])
                sys.exit(2)

        def factor(opt, flag):
            """A positive float from the command line, or 0 when absent."""
            if self.opts.get(opt) is None:
                return 0
            try:
                v = float(self.opts[opt])
            except (TypeError, ValueError):
                v = float('nan')
            if not (v == v) or v <= 0:
                sys.stderr.write("meds: %s wants a positive number, got '%s'\n"
                                 % (flag, self.opts[opt]))
                sys.exit(2)
            return v
        textScale = factor('scale', '--scale')
        strokeScale = factor('strokeScale', '--stroke-scale')

        # CLI --display/--menu/--size/--scale/--stroke-scale apply to every
        # launched MDU
        for name in c['start']:
            lruConf = c['lrus'][name]
            if lruConf.get('module') == 'meds/mdu':
                lruConf.setdefault('init', {})
                if self.opts.get('display'):
                    lruConf['init']['display'] = self.opts['display']
                if self.opts.get('menu'):
                    lruConf['init']['menu'] = self.opts['menu']
                if size > 0 and lruConf.get('window') is not None:
                    lruConf['window']['displayPx'] = size
                if textScale > 0:
                    lruConf['textScale'] = textScale
                if strokeScale > 0:
                    lruConf['textStrokeScale'] = strokeScale
        return c

    def startLRU(self, CONFIG, lruName, thisStart):
        lruConf = CONFIG['lrus'][lruName]
        if 'window' not in lruConf:
            return None
        newWindow = MDUWindow(lruName, lruConf, CONFIG.get('dev'))
        # per-window config copy: each renderer gets its own thisStart
        winConfig = dict(CONFIG)
        winConfig['thisStart'] = thisStart
        self.startLRUsIn(newWindow, winConfig)
        # `show: true` steals focus -- Electron used showInactive()
        newWindow.setAttribute(Qt.WidgetAttribute.WA_ShowWithoutActivating, True)
        newWindow.show()
        return newWindow

    def startLRUsIn(self, win, CONFIG):
        """simRunner/renderer/startup.civet: one window per windowed LRU, with
        headless "shared" LRUs bundled in for bus comms only."""
        lruMap = {'meds/mdu': mdu_start, 'meds/idp': idp_start}
        # IDP POWER STARTS OFF when there is a pane to turn it on with: a
        # display unit is not powered until the crew powers it (PASS User's
        # Guide Table 2-2 step 8, "DEU(s) Power - ON").  Without the pane
        # (the default), and in --dev, it starts powered, and panelO6.py's C2
        # IDP/CRT POWER switch -- OFF until thrown -- takes it from there.
        # NSTS_IDP_POWER=on|off overrides.
        _pw = str(env('NSTS_IDP_POWER', '')).lower()
        if _pw in ('on', '1'):
            powerOn = True
        elif _pw in ('off', '0'):
            powerOn = False
        else:
            powerOn = bool(CONFIG.get('dev')) or not _pane_wanted(self.opts)
        for lruName in CONFIG['thisStart']:
            lruConf = dict(CONFIG['lrus'][lruName])
            lruConf['NSTS_TOP'] = CONFIG['NSTS_TOP']
            lruConf['dev'] = CONFIG.get('dev')
            lruConf['powerOn'] = powerOn
            mod = lruMap.get(lruConf.get('module'))
            if mod is None:
                sys.stderr.write("startup: no renderer module for %s (LRU %s)\n"
                                 % (lruConf.get('module'), lruName))
                continue
            lru = mod(lruConf)
            if isinstance(lru, MDU) and not lruConf.get('shared'):
                lru.win = win
                win.lru = lru
            lru.start()
            if isinstance(lru, MDU) and not lruConf.get('shared') \
                    and _pane_wanted(self.opts):
                lru.pane = IDPPane(lru, win)
                win.setSidePane(lru.pane)
            if isinstance(lru, MDU) and not lruConf.get('shared') \
                    and _edgekeys_wanted(self.opts):
                lru.edgeStrip = MDUEdgeKeyStrip(lru, win)
                win.setEdgeStrip(lru.edgeStrip)
            self.lrus[lruName] = lru
        # console access: window.lru is the last LRU started in this window
        _EXEC_NS['lru'] = self.lrus.get(CONFIG['thisStart'][-1]) if CONFIG['thisStart'] else None
        _EXEC_NS['lrus'] = AttrDict(self.lrus)
        # The display state of a snapshot, if this run was started from one,
        # and the listener that lets a later Save ask for it.
        self._restoreIDPs()
        self._startSnapshotListener()

        # dev/test hook: NSTS_EXEC runs once the LRUs are up (2s after load)
        if env('NSTS_EXEC'):
            QTimer.singleShot(2000, _runNstsExec)

    # -- display state, saved and restored ----------------------------------

    def _idps(self):
        return [l for l in self.lrus.values() if isinstance(l, IDP)]

    def _saveIDPs(self, where):
        """Write idp<N>.json and idp<N>.mem.bin for every unit in THIS
        process.  A run has one of these per CRT and they own different
        units, so each writes its own and the set is complete between them."""
        import json as _json
        done = []
        for idp in self._idps():
            # ON THE PUMP THREAD: both the state and the memory are read
            # there, together, so a save cannot catch a fill half-applied.
            state, mem = BusPump.get().callAndWait(lambda idp=idp: (
                idp.snapshotState(), bytes(idp.unit.mem.tobytes())))
            jname, mname = crewscript.idp_snapshot_files(idp.snapshotNumber())
            try:
                with open(os.path.join(where, mname), "wb") as fh:
                    fh.write(mem)
                with open(os.path.join(where, jname), "w") as fh:
                    _json.dump(state, fh, indent=1, sort_keys=True)
                    fh.write("\n")
            except OSError as e:
                sys.stderr.write("meds: cannot save IDP%s: %s\n" % (idp.id, e))
                continue
            done.append(idp.snapshotNumber())
        if done:
            print("meds: saved display state for IDP %s to %s"
                  % (", ".join(done), where), flush=True)

    def _restoreIDPs(self):
        """--idp-restore DIR: put each unit's display memory back."""
        where = self.opts.get('idpRestore')
        if not where:
            return
        import json as _json
        for idp in self._idps():
            jname, mname = crewscript.idp_snapshot_files(idp.snapshotNumber())
            jpath = os.path.join(where, jname)
            mpath = os.path.join(where, mname)
            if not (os.path.isfile(jpath) and os.path.isfile(mpath)):
                sys.stderr.write("meds: no saved display state for IDP%s in "
                                 "%s\n" % (idp.id, where))
                continue
            try:
                with open(jpath) as fh:
                    state = _json.load(fh)
                mem = np.frombuffer(open(mpath, "rb").read(), dtype=np.uint16)
            except (OSError, ValueError) as e:
                sys.stderr.write("meds: cannot read IDP%s state: %s\n"
                                 % (idp.id, e))
                continue
            BusPump.get().call(
                lambda idp=idp, st=state, m=mem: idp.restoreState(st, m))

    def _startSnapshotListener(self):
        """'save DIR' on port base + 95, from simulatePASS."""
        try:
            # THIS RUN'S PORT BASE, NOT THE DEFAULT.  crewscript falls back to
            # the discretes module's base, which MEDS2 does not set -- so on
            # any port base but 6900 the listener bound 6995 while simulatePASS
            # sent to <base>+95, and a Save lost the displays with no error
            # anywhere (seen on port base 7300, 2026-09-19).
            sock = crewscript.meds_receiver(PORT_BASE)
        except Exception as e:
            sys.stderr.write("meds: no snapshot listener (%s)\n" % e)
            return

        def listen():
            while True:
                try:
                    data, _a = sock.recvfrom(4096)
                except OSError:
                    return
                text = data.decode("utf-8", errors="replace").strip()
                word, _, rest = text.partition(" ")
                if word.lower() == "save" and rest.strip():
                    try:
                        self._saveIDPs(rest.strip())
                    except Exception as e:
                        sys.stderr.write("meds: snapshot failed: %s\n" % e)

        threading.Thread(target=listen, daemon=True).start()

    def createWindows(self):
        C = self.CONFIG
        # Collect shared (headless) LRUs from the start list
        sharedLRUs = [x for x in C['start'] if (C['lrus'].get(x) or {}).get('shared')]
        windowed = [x for x in C['start'] if not (C['lrus'].get(x) or {}).get('shared')]
        # A start list of only headless LRUs (e.g. `meds idp1`) still needs one
        # host window
        startSharedWindow = C.get('startSharedWindow') or \
            (len(windowed) == 0 and len(sharedLRUs) > 0)
        if startSharedWindow:
            self.startLRU(C, 'shared', sharedLRUs)
            sharedLRUs = []
        for startName in windowed:
            # Bundle shared LRUs into the first windowed LRU
            thisStart = [startName]
            if sharedLRUs:
                thisStart = thisStart + sharedLRUs
                sharedLRUs = []
            self.windows[startName] = self.startLRU(C, startName, thisStart)

    def start(self):
        self.CONFIG = self.loadConfig()
        if self.opts.get('list'):
            names = [n for n in self.CONFIG['lrus'].keys() if n != 'shared']
            for name in names:
                lruConf = self.CONFIG['lrus'][name]
                if lruConf.get('shared'):
                    kind = 'headless'
                else:
                    w = lruConf.get('window') or {}
                    kind = 'window %sx%s' % (w.get('width'), w.get('height'))
                print("%s %s %s  (%s)" % (name.ljust(8),
                                          str((lruConf.get('config') or {}).get('lru') or '').ljust(6),
                                          lruConf.get('module'), kind))
            sys.exit(0)
        self.createWindows()


def _pane_wanted(opts):
    """The IDP pane: --pane or NSTS_MDU_PANE=1; NSTS_MDU_PANE=0 wins."""
    e = str(env('NSTS_MDU_PANE', '')).strip()
    if e == '0':
        return False
    return e == '1' or bool(opts.get('pane', False))


# The namespace NSTS_EXEC runs in.  The JavaScript build evaluated its string
# in the renderer, where `window.lrus.cdr1.screens.AE_PFD.enterTapeTest()` is
# ordinary member access; AttrDict keeps that spelling working here.
_EXEC_NS = AttrDict()


def _runNstsExec():
    src = env('NSTS_EXEC')
    if not src:
        return
    ns = dict(_EXEC_NS)
    ns['window'] = _EXEC_NS
    ns['lrus'] = _EXEC_NS.get('lrus')
    ns['lru'] = _EXEC_NS.get('lru')
    try:
        v = eval(compile(src, '<NSTS_EXEC>', 'eval'), ns)
        print("[meds] NSTS_EXEC ->", v)
    except SyntaxError:
        try:
            exec(compile(src, '<NSTS_EXEC>', 'exec'), ns)
        except Exception as e:
            print("[meds] NSTS_EXEC failed:", e)
    except Exception as e:
        print("[meds] NSTS_EXEC failed:", e)


# ===========================================================================
# Entry point
# ===========================================================================

def buildParser():
    p = argparse.ArgumentParser(
        prog='MEDS2.py',
        description='MEDS glass cockpit -- launch MDU display / IDP LRUs',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""examples:
  MEDS2.py --list                 list available LRU names
  MEDS2.py crt1 idp1              a center CRT MDU fed by IDP1
  MEDS2.py cdr1 plt1 idp1 idp2    commander + pilot MDUs
  MEDS2.py --display AE_PFD crt2  override the initial display
  MEDS2.py --dev crt1             developer mode (standalone MDU)
""")
    p.add_argument('lrus', nargs='*',
                   help='LRU names from config/meds.json (e.g. crt1 idp1 cdr1); '
                        'default: the config "start" list')
    p.add_argument('--idp-restore', dest='idpRestore', metavar='<dir>',
                   help='restore each IDP\'s display memory from a snapshot '
                        'directory (idp<N>.json and idp<N>.mem.bin)')
    p.add_argument('--title', metavar='<text>',
                   help='what to call the windows, before each LRU\'s own '
                        'name: "<text> / CRT1".  The orbiter has eleven MDUs '
                        'and a GPC talks only to some of them, so several may '
                        'be on screen at once -- and with --port-base there '
                        'may be two simulations\' worth.  Default "MEDS2 MDU".')
    p.add_argument('--port-base', dest='portBase', type=int, metavar='<n>',
                   help='base of the UDP port range the buses use: every bus '
                        'port moves with the base (default 6900).  The same option '
                        'as on yaGPC2, panelO6.py and stsKeyboard.py -- give a '
                        'second simulation its own base and the two run side '
                        'by side.  NSTS_BUS_PORT_BASE sets it too.')
    p.add_argument('--config', dest='config', metavar='<file>',
                   help='alternate LRU config JSON (default: config/meds.json)')
    p.add_argument('--display', metavar='<name>',
                   help='initial display for launched MDUs (DPS, AE_PFD, HYD_APU, '
                        'OMS_MPS, SPI, ...)')
    p.add_argument('--menu', metavar='<name>',
                   help='initial MDU menu (MAIN, FLT_INST, ...)')
    p.add_argument('--size', metavar='<px>',
                   help='MDU window size in pixels, square (default: the config '
                        'width/height)')
    p.add_argument('--scale', metavar='<x>',
                   help='text size factor, e.g. 0.9: every glyph shrinks or grows '
                        'about its own centre, and nothing moves (default: 1, or '
                        'the config "textScale")')
    p.add_argument('--stroke-scale', dest='strokeScale', metavar='<x>',
                   help='text stroke width factor, e.g. 0.8: thins or thickens the '
                        'lines glyphs are drawn with, and no other lines (default: '
                        '1, or the config "textStrokeScale")')
    p.add_argument('--pane', dest='pane', action='store_true',
                   help='an IDP control pane (IDP POWER, IDP MAJ FUNC, DEU LOAD) '
                        'down the right side of each MDU window.  Off by '
                        'default: those switches are panelO6.py\'s C2 and O6 '
                        'IDP LOAD.  Also NSTS_MDU_PANE=1')
    p.add_argument('--no-pane', dest='noPane', action='store_true',
                   help=argparse.SUPPRESS)          # the old default, now a no-op
    p.add_argument('--no-edgekeys', dest='noEdgekeys', action='store_true',
                   help='no edgekey pushbuttons under each display (F1-F6 still '
                        'press the edgekeys); also NSTS_MDU_EDGEKEYS=0')
    p.add_argument('--no-idp-box', dest='noIdpBox', action='store_true',
                   help='hide the IDP identifier box and keyboard bars at the '
                        'foot of DPS pages; also NSTS_DPS_IDP_BOX=0')
    p.add_argument('--dev', action='store_true',
                   help='developer mode: MDUs run standalone (no IDP heartbeat '
                        'gating, preloaded DPS test formats)')
    p.add_argument('--list', action='store_true',
                   help='list available LRU names and exit')
    p.add_argument('--version', action='version', version='MEDS2 1.0.0')
    return p


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    # The packaged product shares this entry point with `gpc meds ...`, so a
    # leading `meds` subcommand is accepted and ignored.
    if argv and argv[0] == 'meds':
        argv = argv[1:]
    # Chromium switches the Electron launcher used to inject
    argv = [a for a in argv if a not in ('--no-sandbox', '--disable-gpu-sandbox',
                                         '--disable-setuid-sandbox')]
    args = buildParser().parse_args(argv)
    # Before any Bus is constructed.
    if args.portBase is not None:
        setPortBase(args.portBase)
    if args.title:
        global WINDOW_TITLE
        WINDOW_TITLE = args.title
    if args.noIdpBox:
        global SHOW_IDP_BOX
        SHOW_IDP_BOX = False
    opts = {
        'lrus': args.lrus,
        'configFile': os.path.abspath(args.config) if args.config else None,
        'display': args.display,
        'menu': args.menu,
        'size': args.size,
        'scale': args.scale,
        'strokeScale': args.strokeScale,
        'dev': args.dev,
        'list': args.list,
        'pane': args.pane and not args.noPane,
        'edgekeys': not args.noEdgekeys,
        'idpRestore': args.idpRestore,
    }

    # --list needs no window system at all.
    if args.list:
        MedsRunner(opts).start()
        return 0

    fmt = QSurfaceFormat()
    fmt.setVersion(4, 1)
    fmt.setProfile(QSurfaceFormat.OpenGLContextProfile.CoreProfile)
    fmt.setDepthBufferSize(24)
    fmt.setStencilBufferSize(8)
    fmt.setSamples(4)                 # three.js's `antialias: true`
    fmt.setSwapBehavior(QSurfaceFormat.SwapBehavior.DoubleBuffer)
    QSurfaceFormat.setDefaultFormat(fmt)

    app = QtWidgets.QApplication(sys.argv[:1])
    app.setApplicationName('MEDS2')
    app.setQuitOnLastWindowClosed(True)

    runner = MedsRunner(opts)
    runner.start()

    if not runner.windows and not runner.lrus:
        sys.stderr.write("meds: nothing to launch\n")
        return 2
    return app.exec()


if __name__ == '__main__':
    sys.exit(main())
