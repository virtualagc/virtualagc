#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MEDS2 — Python 3 work-alike of the Electron MEDS2 glass-cockpit runner.

Port of ~/workspace/MEDS2 (the `meds2` branch of nsts-sim-gpc): MDU display
units and IDPs talking to GPCs over the simulated UDP-multicast DK / IDP /
keyboard buses.  Same CLI shape as MEDS2.sh:

    python3 MEDS2.py
    python3 MEDS2.py crt1 idp1
    python3 MEDS2.py --list
    python3 MEDS2.py --display DPS --size 512 crt1 idp1
    python3 MEDS2.py --dev crt1 idp1

LRU definitions: config/meds.json next to this file, or NSTS_SIM_CONFIG, or
~/workspace/MEDS2/config/meds.json.

This is the DPS/IDP path used with yaGPC2 (GPCIPL → PASS).  Steam-gauge
screens (AE_PFD, SPI, …) open a window but do not draw those instruments.

MEDS2-specific behaviour preserved: NSTS_MAJOR_FUNC, Shift+M / Shift+1..4
major-function switch, Shift+V beam geometry (gpcipl/dfg), frameless MDU
whose content is the canvas, NSTS_MDU_POS, NSTS_BUS_IFACE, NSTS_BUS_RCVBUF,
NSTS_DEU_LOG, NSTS_DEU_GEOM.
"""

from __future__ import print_function

import argparse
import json
import math
import os
import socket
import struct
import sys
import threading
import time
import tkinter as tk

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

HERE = os.path.dirname(os.path.abspath(__file__))


def nsts_top():
    env = os.environ.get("NSTS_TOP")
    if env and os.path.isdir(env):
        return env
    cand = os.path.expanduser("~/workspace/MEDS2")
    if os.path.isdir(cand):
        return cand
    return HERE


def default_config_path():
    for p in (
        os.environ.get("NSTS_SIM_CONFIG"),
        os.path.join(HERE, "meds.json"),
        os.path.join(nsts_top(), "config", "meds.json"),
    ):
        if p and os.path.isfile(p):
            return p
    return os.path.join(HERE, "meds.json")


def log(msg):
    print("MEDS2: %s" % msg, flush=True)


# ---------------------------------------------------------------------------
# Bus map  (com/bus.civet)
# ---------------------------------------------------------------------------

GROUP = "239.255.1.1"
BUS_IFACE = os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")
RCVBUF = int(os.environ.get("NSTS_BUS_RCVBUF", "4194304"))

BUS_CONFIG = {
    "IC1": {"gpcBceNum": 1, "port": 6901},
    "IC2": {"gpcBceNum": 2, "port": 6902},
    "IC3": {"gpcBceNum": 3, "port": 6903},
    "IC4": {"gpcBceNum": 4, "port": 6904},
    "IC5": {"gpcBceNum": 5, "port": 6905},
    "DK1": {"gpcBceNum": 6, "port": 6906},
    "DK2": {"gpcBceNum": 7, "port": 6907},
    "DK3": {"gpcBceNum": 8, "port": 6908},
    "DK4": {"gpcBceNum": 9, "port": 6909},
    "PL1": {"gpcBceNum": 10, "port": 6910},
    "PL2": {"gpcBceNum": 11, "port": 6911},
    "LB1": {"gpcBceNum": 12, "port": 6912},
    "LB2": {"gpcBceNum": 13, "port": 6913},
    "FC5": {"gpcBceNum": 14, "port": 6914},
    "FC6": {"gpcBceNum": 15, "port": 6915},
    "FC7": {"gpcBceNum": 16, "port": 6916},
    "FC8": {"gpcBceNum": 17, "port": 6917},
    "MM1": {"gpcBceNum": 18, "port": 6918},
    "MM2": {"gpcBceNum": 19, "port": 6919},
    "FC1": {"gpcBceNum": 20, "port": 6920},
    "FC2": {"gpcBceNum": 21, "port": 6921},
    "FC3": {"gpcBceNum": 22, "port": 6922},
    "FC4": {"gpcBceNum": 23, "port": 6923},
    "_KYBD1": {"port": 6931},
    "_KYBD2": {"port": 6932},
    "_KYBD3": {"port": 6933},
    "_IDP1": {"port": 6941},
    "_IDP2": {"port": 6942},
    "_IDP3": {"port": 6943},
    "_IDP4": {"port": 6944},
    "__SIMCONTROL": {"port": 6700},
}

MDU_MSG = {
    "FILL": 0xFF00,
    "RESET_SPL": 0xFF02,
    "CLOCK": 0xFF03,
    "POLL": 0xFF04,
    "HEARTBEAT": 0xFFFF,
    "SET_MAJOR_FUNC": 0x0001,
}

MEDS_IDPS = {
    "IDP1": {"busses": ["_IDP1", "FC1", "FC2", "FC3", "FC4", "DK1", "_KYBD1"],
             "dkBus": "DK1"},
    "IDP2": {"busses": ["_IDP2", "FC1", "FC2", "FC3", "FC4", "DK2", "_KYBD2", "_KYBD3"],
             "dkBus": "DK2"},
    "IDP3": {"busses": ["_IDP3", "FC1", "FC2", "FC3", "FC4", "DK3", "_KYBD1", "_KYBD2"],
             "dkBus": "DK3"},
    "IDP4": {"busses": ["_IDP4", "FC1", "FC2", "FC3", "FC4", "DK4", "_KYBD3"],
             "dkBus": "DK4"},
}

MEDS_MDUS = {
    "CRT1": {"busses": ["_IDP1"], "dataBus": {"P": "IDP1", "S": None}},
    "CRT2": {"busses": ["_IDP2"], "dataBus": {"P": "IDP2", "S": None}},
    "CRT3": {"busses": ["_IDP3"], "dataBus": {"P": "IDP3", "S": None}},
    "CRT4": {"busses": ["_IDP4"], "dataBus": {"P": "IDP4", "S": None}},
    "CDR1": {"busses": ["_IDP3", "_IDP1"], "dataBus": {"P": "IDP3", "S": "IDP1"}},
    "CDR2": {"busses": ["_IDP1", "_IDP2"], "dataBus": {"P": "IDP1", "S": "IDP2"}},
    "PLT1": {"busses": ["_IDP2", "_IDP1"], "dataBus": {"P": "IDP2", "S": "IDP1"}},
    "PLT2": {"busses": ["_IDP3", "_IDP2"], "dataBus": {"P": "IDP3", "S": "IDP2"}},
}

MF_NAMES = ("PL", "GNC", "SM", "ILLEGAL")


def _swap16_bytes(b):
    ba = bytearray(b)
    if len(ba) & 1:
        ba.append(0)
    for i in range(0, len(ba), 2):
        ba[i], ba[i + 1] = ba[i + 1], ba[i]
    return bytes(ba)


class BusMsg(object):
    def __init__(self, length16):
        self.length16 = length16
        self.data16 = [0] * length16

    @classmethod
    def from_net(cls, buf):
        raw = _swap16_bytes(buf)
        n = len(raw) // 2
        m = cls(n)
        for i in range(n):
            m.data16[i] = (raw[2 * i] << 8) | raw[2 * i + 1]
        return m

    def to_net(self):
        parts = []
        for w in self.data16:
            w &= 0xFFFF
            parts.append(bytes(((w >> 8) & 0xFF, w & 0xFF)))
        return _swap16_bytes(b"".join(parts))


class Bus(object):
    SELF_ECHO_MAX = 1024

    def __init__(self, bus_id):
        self.bus_id = bus_id
        cfg = BUS_CONFIG[bus_id]
        self.port = cfg["port"]
        self._cb = None
        self._echo = []
        self._lock = threading.Lock()
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
        except (AttributeError, OSError):
            pass
        self.sock.bind(("", self.port))
        try:
            self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RCVBUF)
        except OSError:
            pass
        mreq = struct.pack("4s4s", socket.inet_aton(GROUP),
                           socket.inet_aton(BUS_IFACE))
        self.sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)
        try:
            self.sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                                 socket.inet_aton(BUS_IFACE))
        except OSError:
            pass
        self.sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 128)
        self.sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        self.sock.setblocking(False)
        log("bus %s port %d recvbuf %s" % (
            bus_id, self.port,
            self.sock.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)))

    def on_receive(self, cb):
        self._cb = cb

    def _is_echo(self, data):
        with self._lock:
            for i, b in enumerate(self._echo):
                if b == data:
                    del self._echo[i]
                    return True
        return False

    def _note_sent(self, data):
        with self._lock:
            self._echo.append(data)
            while len(self._echo) > self.SELF_ECHO_MAX:
                self._echo.pop(0)

    def poll(self):
        while True:
            try:
                data, _addr = self.sock.recvfrom(65536)
            except BlockingIOError:
                return
            except OSError:
                return
            if self._is_echo(data):
                continue
            if self._cb:
                self._cb(self.bus_id, BusMsg.from_net(data))

    def send_msg(self, msg):
        body = msg.to_net()
        self._note_sent(body)
        try:
            self.sock.sendto(body, (GROUP, self.port))
        except OSError as e:
            log("send %s: %s" % (self.bus_id, e))


# ---------------------------------------------------------------------------
# DEU protocol  (meds/deuProto.coffee)
# ---------------------------------------------------------------------------

IUA = 10
FUNC_SHIFT = 9
COUNT_MASK = 0x1FF
FUNC = {
    "TIME_FILL": 0x380, "DISPLAY_FILL": 0x38C, "FORMAT_FILL": 0x394,
    "MEDS_XFER": 0x398, "DUMP": 0x3A0, "POLL": 0x010, "BITE": 0x040,
    "RESET_SPL": 0x080,
}
FUNC_NAME = dict((v, k) for k, v in FUNC.items())
POLL_WORDS = 16
BITE_WORDS = 5
LAST_FILL_WORDS = 250
DEU_ID_ADDR = 0x001D
MEDS_XFER_WORDS = 100
ADDR_MASK = 0x1FFF
DEU_MEMORY_WORDS = 8192
ADDR = {
    "CRITICAL_FORMAT": 0x0100,
    "DISPLAY_HEADER": 0x19EE,
    "BACKGROUND_TOP": 0x1FE4,
}
CF_PAD = 0x111E
HDR = {
    "MSG_RESET": 0x0800, "MAJOR_FUNC": 0x00C0, "ACK": 0x0020,
    "KYBD_MSG": 0x0008, "SELF_TEST": 0x0004, "BITE_CRITICAL": 0x0002,
    "IPL_REQUIRED": 0x0001,
}
MAJOR_FUNC_SHIFT = 6
KEY_COUNT_MASK = 0x003F
KEY_WORDS = 10
KEYS_PER_WORD = 3
KEY_BITS = 5
KEY_COUNT_HIGH = 0xFF00
TIME_FILL_WORDS = 7
MAX_KEYS = 30
MAX_KEYS_IPL = 6

KEY = {
    "0": 0x00, "1": 0x01, "2": 0x02, "3": 0x03, "4": 0x04, "5": 0x05,
    "6": 0x06, "7": 0x07, "8": 0x08, "9": 0x09,
    "A": 0x0A, "B": 0x0B, "C": 0x0C, "D": 0x0D, "E": 0x0E, "F": 0x0F,
    "SYS_SUMM": 0x10, "OPS": 0x11, "SPEC": 0x12, "FAULT_SUMM": 0x13,
    "ITEM": 0x14, "MINUS": 0x15, "PLUS": 0x16, "DECIMAL": 0x17,
    "IO_RESET": 0x18, "GPC_CRT": 0x19, "CLEAR": 0x1A, "RESUME": 0x1B,
    "ACK": 0x1C, "MSG_RESET": 0x1D, "EXEC": 0x1E, "PRO": 0x1F,
}

BITE1_ALWAYS_ONE = 0x8000
BITE1_IPL_DONE = 0x4000
BITE1_HEALTHY = BITE1_ALWAYS_ONE | BITE1_IPL_DONE
SWSTATUS_HEALTHY = 0x2000


def decode_command(cmd24):
    cmd = cmd24 & 0xFFFFFF
    func = (cmd >> FUNC_SHIFT) & 0x3FF
    return {
        "raw": cmd,
        "iua": (cmd >> 19) & 0x1F,
        "func": func,
        "count": cmd & COUNT_MASK,
        "name": FUNC_NAME.get(func, "UNKNOWN"),
    }


def parse_fill(words):
    if len(words) < 2:
        return None
    n = words[0] & 0xFFFF
    return {
        "addr": words[1] & ADDR_MASK,
        "count": n,
        "payload": words[2:2 + n],
        "short": (len(words) - 2) < n,
    }


def ibm_float48(w0, w1, w2):
    sign = -1 if (w0 & 0x8000) else 1
    exp = ((w0 >> 8) & 0x7F) - 64
    frac = ((w0 & 0xFF) * 0x100000000) + (w1 * 0x10000) + w2
    return sign * (frac / float(0x10000000000)) * (16.0 ** exp)


def parse_time_fill(words):
    if len(words) != TIME_FILL_WORDS:
        return None
    return {
        "mission": ibm_float48(words[0], words[1], words[2]),
        "event": ibm_float48(words[3], words[4], words[5]),
        "conv": words[6] & 0xFFFF,
    }


def checksum(words):
    s = 0
    for w in words:
        s = (s + (w & 0xFFFF)) & 0xFFFF
    return (-s) & 0xFFFF


def pack_keys(keys):
    words = [0] * KEY_WORDS
    for i, k in enumerate(keys[:MAX_KEYS]):
        w = i // KEYS_PER_WORD
        slot = i % KEYS_PER_WORD
        shift = 16 - KEY_BITS * (slot + 1)
        words[w] |= (k & 0x1F) << shift
    return words


def poll_response(header, keys, bite1=BITE1_HEALTHY, sw_status=SWSTATUS_HEALTHY):
    words = [0] * POLL_WORDS
    words[0] = header & 0xFFFF
    keys = list(keys[:MAX_KEYS])
    words[1] = KEY_COUNT_HIGH | (len(keys) & KEY_COUNT_MASK)
    packed = pack_keys(keys)
    for i in range(KEY_WORDS):
        words[2 + i] = packed[i]
    words[12] = bite1 & 0xFFFF
    words[13] = 0
    words[14] = sw_status & 0xFFFF
    words[15] = checksum(words[:15])
    return words


def bite_response(bite1=BITE1_HEALTHY, sw_status=SWSTATUS_HEALTHY):
    words = [bite1 & 0xFFFF, 0, sw_status & 0xFFFF, 0, 0]
    words[4] = checksum(words[:4])
    return words


# ---------------------------------------------------------------------------
# Scratch pad (simplified acceptor — terminators complete an entry)
# ---------------------------------------------------------------------------

class SPL(object):
    def __init__(self):
        self.keys = []
        self.err = False

    def clear(self):
        self.keys = []
        self.err = False

    def press(self, code):
        code &= 0x1F
        if code == KEY["CLEAR"]:
            if self.keys:
                self.keys.pop()
            self.err = False
            return "edit"
        if code in (KEY["ACK"], KEY["MSG_RESET"]):
            return "ignore"
        self.keys.append(code)
        if code in (KEY["EXEC"], KEY["PRO"], KEY["RESUME"],
                    KEY["SYS_SUMM"], KEY["FAULT_SUMM"]):
            return "complete"
        return "edit"


# ---------------------------------------------------------------------------
# DEUUnit  (meds/deuUnit.coffee)
# ---------------------------------------------------------------------------

class DEUUnit(object):
    def __init__(self, name="DEU", send=None, on_fill=None, on_reset=None,
                 on_time=None, on_poll=None, ipled=True, major_func=None):
        self.name = name
        self.send = send or (lambda words: None)
        self.on_fill = on_fill or (lambda addr, payload: None)
        self.on_reset = on_reset or (lambda: None)
        self.on_time = on_time or (lambda t: None)
        self.on_poll = on_poll or (lambda: None)
        self.mem = [0] * DEU_MEMORY_WORDS
        self.xfer = None
        self.key_queue = []
        self.spl = SPL()
        if major_func is None:
            major_func = int(os.environ.get("NSTS_MAJOR_FUNC", "0"))
        self.major_func = major_func & 3
        self.ipled = ipled
        self.ipl_running = False
        self.msg_reset_pending = False
        self.ack_pending = False
        self.ipl_error = False
        self.ipl_circuit_error = False
        self.self_test = False
        self.sw_status = SWSTATUS_HEALTHY
        self.deu_id = None
        self.stats = dict(commands=0, fills=0, time_fills=0, headerless=0,
                          polls=0, abandoned=0, words_in=0, words_out=0)
        self._last_poll_key = None
        self._same_poll = 0
        self._log_path = os.environ.get("NSTS_DEU_LOG")

    def log(self, text):
        log("%s %s" % (self.name, text))
        if self._log_path:
            try:
                with open(self._log_path, "a") as f:
                    f.write("%s %s\n" % (self.name, text))
            except OSError:
                pass

    def recv(self, words):
        if len(words) >= 2:
            cmd24 = ((words[0] & 0xFFFF) << 8) | ((words[1] >> 8) & 0xFF)
            self.on_command(cmd24)
        else:
            for w in words:
                self.on_data(w)

    def on_command(self, cmd24):
        c = decode_command(cmd24)
        if c["iua"] != IUA:
            return
        self.stats["commands"] += 1
        if self.xfer and self.xfer["left"] > 0:
            self.stats["abandoned"] += 1
            self.log("transfer abandoned, %d halfwords short" % self.xfer["left"])
        self.xfer = None
        fn = c["func"]
        if fn in (FUNC["TIME_FILL"], FUNC["DISPLAY_FILL"], FUNC["FORMAT_FILL"]):
            self.xfer = {"func": fn, "left": c["count"], "words": []}
        elif fn == FUNC["MEDS_XFER"]:
            self.xfer = {"func": fn, "left": MEDS_XFER_WORDS, "words": []}
        elif fn == FUNC["DUMP"]:
            self.xfer = {"func": fn, "left": c["count"], "words": []}
        elif fn == FUNC["POLL"]:
            self.stats["polls"] += 1
            self.on_poll()
            if self.ipl_running:
                self._reply([self.take_header()])
            else:
                self._reply(self.poll_response())
        elif fn == FUNC["BITE"]:
            self._reply(bite_response(self.bite1(), self.sw_status))
        elif fn == FUNC["RESET_SPL"]:
            self.key_queue[:] = []
            self.spl.clear()
            self.on_reset()

    def on_data(self, w):
        if not self.xfer:
            return
        self.stats["words_in"] += 1
        self.xfer["words"].append(w & 0xFFFF)
        self.xfer["left"] -= 1
        if self.xfer["left"] > 0:
            return
        x = self.xfer
        self.xfer = None
        if x["func"] == FUNC["DUMP"]:
            addr = (x["words"][1] if len(x["words"]) > 1 else 0) & ADDR_MASK
            n = (x["words"][0] if x["words"] else 0) & 0xFFFF
            out = [self.mem[(addr + i) & (DEU_MEMORY_WORDS - 1)] for i in range(n)]
            self._reply(out)
        elif x["func"] == FUNC["TIME_FILL"]:
            self.stats["time_fills"] += 1
            t = parse_time_fill(x["words"])
            if t:
                self.on_time(t)
        elif x["func"] == FUNC["MEDS_XFER"]:
            pass
        else:
            self._fill(x["words"], x["func"])

    def _fill(self, words, func):
        f = parse_fill(words)
        if not f or f["short"] or f["count"] + 2 != len(words):
            self.stats["headerless"] += 1
            self.log("unheadered fill of %d halfwords, ignored" % len(words))
            return
        self.stats["fills"] += 1
        self.log("fill func=%s %d halfwords at 0x%04x" % (
            FUNC_NAME.get(func, hex(func)), f["count"], f["addr"]))
        if not self.ipled and not self.ipl_running:
            self.ipl_running = True
            self.log("load started")
        if self.ipl_running and f["count"] == LAST_FILL_WORDS:
            self.ipl_running = False
            self.ipled = True
            self.log("load complete (%d halfwords at 0x%04x), reporting initialized"
                     % (f["count"], f["addr"]))
        for i, w in enumerate(f["payload"]):
            self.mem[(f["addr"] + i) & (DEU_MEMORY_WORDS - 1)] = w & 0xFFFF
        self.on_fill(f["addr"], f["payload"])

    def _reply(self, words):
        if not words:
            return
        self.stats["words_out"] += len(words)
        self.send(words)

    def bite1(self):
        b = BITE1_ALWAYS_ONE
        if self.ipled:
            b |= BITE1_IPL_DONE
        return b

    def header(self):
        hdr = (self.major_func << MAJOR_FUNC_SHIFT) & HDR["MAJOR_FUNC"]
        if self.self_test:
            hdr |= HDR["SELF_TEST"]
        if not self.ipled:
            hdr |= HDR["IPL_REQUIRED"]
        if self.msg_reset_pending:
            hdr |= HDR["MSG_RESET"]
        if self.ack_pending:
            hdr |= HDR["ACK"]
        if (self.key_queue and not
                (self.msg_reset_pending or self.ack_pending)):
            hdr |= HDR["KYBD_MSG"]
        return hdr

    def take_header(self):
        hdr = self.header()
        self.msg_reset_pending = False
        self.ack_pending = False
        return hdr

    def poll_response(self):
        hdr = self.take_header()
        keys = []
        if hdr & HDR["KYBD_MSG"] and self.key_queue:
            keys = self.key_queue.pop(0)
        return poll_response(hdr, keys, self.bite1(), self.sw_status)

    def press_key(self, code):
        code &= 0x1F
        if code == KEY["MSG_RESET"]:
            self.msg_reset_pending = True
            return
        if code == KEY["ACK"]:
            self.ack_pending = True
            return
        if self.spl.press(code) != "complete":
            return
        if not self.spl.err:
            self.key_queue.append(list(self.spl.keys[:MAX_KEYS_IPL]))
        self.spl.clear()


# ---------------------------------------------------------------------------
# FCW decoder + beam walk  (meds/deuFCW.coffee, mduScreen_DPS.coffee)
# ---------------------------------------------------------------------------

GEOMS = {
    "gpcipl": {"grid": 2048, "col0": 1573, "row0": 364, "absX": 1555, "absY": 364},
    "dfg":    {"grid": 1536, "col0": 1042, "row0": 366, "absX": 1024, "absY": 1902},
}
COL_PITCH, ROW_PITCH = 19, 27
COL_PITCH_L, ROW_PITCH_L = 24, 32
REPT_BASE = 0x0841
GEN_VECTOR, GEN_CHAR_SMALL, GEN_CHAR_LARGE = 1, 2, 3
UPRIGHT = 0x4
AU_X_LIMIT, AU_Y_LIMIT = 512, 365
MAX_FCW_STEPS = 40000

_geom_name = "dfg" if os.environ.get("NSTS_DEU_GEOM") == "dfg" else "gpcipl"
_geom = GEOMS[_geom_name]


def set_geom(name=None):
    global _geom_name, _geom
    if name is None:
        _geom_name = "dfg" if _geom_name == "gpcipl" else "gpcipl"
    else:
        _geom_name = name
    _geom = GEOMS[_geom_name]
    return _geom_name


def geom():
    return _geom


def signed11(v):
    raw = v & 0x7FF
    return raw - 2048 if raw >= 1024 else raw


def in_au_grid(v, axis):
    s = signed11(v)
    lim = AU_Y_LIMIT if axis == "y" else AU_X_LIMIT
    return -lim <= s <= lim


def cell_col(x):
    g = _geom["grid"]
    return ((x - _geom["col0"] + g) % g) / float(COL_PITCH)


def cell_row(y):
    g = _geom["grid"]
    return ((_geom["row0"] - y + g) % g) / float(ROW_PITCH)


DEU_CHARSET = {}
for i, ch in enumerate(" !\"#$%&'()*+,-./0123456789:;<=>?"):
    DEU_CHARSET[0x20 + i] = ch
for i, ch in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
    DEU_CHARSET[0x41 + i] = ch
for i, ch in enumerate("abcdefghijklmnopqrstuvwxyz"):
    DEU_CHARSET[0x61 + i] = ch
DEU_CHARSET[0x5D] = "_"
DEU_CHARSET[0x7C] = "|"
DEU_CHARSET[0x7D] = "_"

# opcode table: name -> (mask, val, fields{name: (lsb, width)}, extra)
def _pat(d, names):
    """Build mask/val/fields from a 16-char bit descriptor (MSB first)."""
    mask = val = 0
    fields = {}
    i = 0
    while i < 16:
        c = d[i]
        bit = 15 - i
        if c == "0":
            mask |= 1 << bit
            i += 1
        elif c == "1":
            mask |= 1 << bit
            val |= 1 << bit
            i += 1
        elif c == "_":
            i += 1
        else:
            j = i
            while j < 16 and d[j] == c:
                j += 1
            width = j - i
            lsb = 15 - (j - 1)
            nm = names.get(c, c)
            fields[nm] = (lsb, width)
            i = j
    return mask, val, fields


FCW_OPS = []  # list of (name, mask, val, fields) widest mask first


def _add_op(name, d, nom):
    FCW_OPS.append((name,) + _pat(d, nom))


_add_op("NOOP", "0000000000000000", {})
_add_op("REPT", "0000nnnnnnnnnnnn", {"n": "raw"})
_add_op("BRANCH", "0001aaaaaaaaaaaa", {"a": "addr12"})
_add_op("SUBLIST", "0010ssssnnnnnnnn", {"s": "sector", "n": "count"})
_add_op("FCW2", "001100eidpqrrmmm",
        {"e": "eor", "i": "incr", "d": "dly", "p": "polarX", "q": "polarY",
         "r": "xyRef", "m": "mode"})
_add_op("FCW3", "001101_psqcccccc",
        {"p": "spchar", "s": "select", "q": "intensity", "c": "color"})
_add_op("FCW1", "001110dbtoasik__",
        {"d": "dash", "b": "blink", "t": "typ", "o": "ocr", "a": "axisY",
         "s": "sp", "i": "intensity", "k": "blank"})
_add_op("VDISP", "001111vvvvvvvvvv", {"v": "vdisp"})
_add_op("ROT", "0100aaaaaaaaaaaa", {"a": "angle"})
_add_op("MAJINC", "0101_sssssssssss", {"s": "step"})
_add_op("CIRCLE", "011101rrrrrrrrr_", {"r": "radius"})
_add_op("MININC", "011110__ssssssss", {"s": "step"})
_add_op("SPTYPE", "011111__ssssssss", {"s": "step"})
_add_op("LSITE1", "01100aaaaaaabbbb", {"a": "char1", "b": "char2hi"})
_add_op("LSITE2", "01101bbbccccccc_", {"b": "char2lo", "c": "char3"})
_add_op("XPOS", "1000txxxxxxxxxxx", {"t": "translate", "x": "x"})
_add_op("YPOS", "1001tyyyyyyyyyyy", {"t": "translate", "y": "y"})
_add_op("VECA", "1010mjssssssssss",
        {"m": "yMajor", "j": "signDiffer", "s": "slope"})
_add_op("VECB", "1011nlllllllllll", {"n": "negative", "l": "len"})
_add_op("CHAR2", "11aaaaaaabbbbbbb", {"a": "char1", "b": "char2"})
FCW_OPS.sort(key=lambda t: -bin(t[1]).count("1"))


def _sx(v, bits):
    sign = 1 << (bits - 1)
    return v - (1 << bits) if v & sign else v


def decode_fcw(hw):
    hw &= 0xFFFF
    for name, mask, val, fields in FCW_OPS:
        if (hw & mask) == val:
            v = {}
            for nm, (lsb, width) in fields.items():
                v[nm] = (hw >> lsb) & ((1 << width) - 1)
            if name == "REPT":
                v["count"] = (REPT_BASE - hw) & 0xFFFF
            elif name == "MAJINC":
                v["step"] = _sx(v["step"], 11)
            elif name in ("MININC", "SPTYPE"):
                v["step"] = _sx(v["step"], 8)
            elif name == "CHAR2":
                v["g1"] = v["char1"]
                v["g2"] = v["char2"]
            return name, v, hw
    return None, {}, hw


ADJ = {
    "rowGap": float(os.environ.get("NSTS_DPS_ROWGAP", "1")),
    "textY": float(os.environ.get("NSTS_DPS_TEXTY", "-2.52")),
    "vecY": float(os.environ.get("NSTS_DPS_VECY", "0.50")),
    "textX": float(os.environ.get("NSTS_DPS_TEXTX", "-0.71")),
    "vecX": float(os.environ.get("NSTS_DPS_VECX", "0.41")),
    "pageY": float(os.environ.get("NSTS_DPS_YSHIFT", "1")),
}

# Frustum in character cells (MEDS2 fitted).
FRUSTUM = (0.20, 52.442456, -1.376, 36.944)
BG = "#101336"
GREEN = "#48f500"
WHITE = "#ffffff"
YELLOW = "#fff600"
ORANGE = "#ff8c06"
RED = "#ff232b"
CYAN = "#2dfada"


def _color(code):
    # MEDS 6-bit palette, a few named defaults; unknown -> green.
    table = {
        None: GREEN, 0: GREEN, 1: WHITE, 2: YELLOW, 3: ORANGE, 4: RED,
        5: CYAN, 6: "#003ce0", 7: "#ff43de",
    }
    return table.get(code, GREEN)


# ---------------------------------------------------------------------------
# MDU window + beam interpreter
# ---------------------------------------------------------------------------

class MDUWindow(object):
    def __init__(self, name, lru_name, size, xy, pri_idp, on_key, on_mf, on_geom):
        self.name = name
        self.lru_name = lru_name
        self.pri_idp = pri_idp
        self.on_key = on_key
        self.on_mf = on_mf
        self.on_geom = on_geom
        self.size = int(size)
        self.mem = [0] * DEU_MEMORY_WORDS
        self.poll_fail = True
        self.clock = None
        self.blink_on = True
        self.major_func = int(os.environ.get("NSTS_MAJOR_FUNC", "0")) & 3
        self._grid_tally = [0, 0]  # seen, bad

        self.root = tk.Toplevel()
        self.root.title(self._title())
        self.root.configure(bg=BG)
        self.root.geometry("%dx%d+%d+%d" % (
            self.size, self.size, xy[0], xy[1]))
        self.root.resizable(False, False)
        try:
            self.root.overrideredirect(True)
        except tk.TclError:
            pass
        self.cv = tk.Canvas(self.root, bg=BG, highlightthickness=0,
                            width=self.size, height=self.size)
        self.cv.pack(fill="both", expand=True)
        self.root.bind("<KeyPress>", self._key)
        self.root.bind("<Control-q>", lambda e: self.root.quit())
        self.root.protocol("WM_DELETE_WINDOW", self.root.quit)
        self._dont_steal()

    def _title(self):
        return "MEDS2 MDU / %s - MF %s" % (
            self.lru_name, MF_NAMES[self.major_func & 3])

    def show_mf(self, mf):
        self.major_func = mf & 3
        try:
            self.root.title(self._title())
        except tk.TclError:
            pass

    def _dont_steal(self):
        try:
            self.root.attributes("-topmost", False)
        except tk.TclError:
            pass
        self.root.withdraw()
        self.root.update_idletasks()
        self.root.deiconify()
        try:
            self.root.lower()
            self.root.lift()
        except tk.TclError:
            pass

    def _key(self, ev):
        # Shift+V geometry, Shift+M MF cycle, Shift+1..4 via !@#$
        if ev.state & 0x0001:  # Shift
            if ev.keysym in ("v", "V"):
                g = set_geom()
                log("beam geometry -> %s" % g)
                self.on_geom()
                self.redraw()
                return
            if ev.keysym in ("m", "M"):
                self.on_mf((self.major_func + 1) & 3)
                return
            if ev.char in "!@#$":
                self.on_mf("!@#$".index(ev.char))
                return
        k = _key_from_event(ev)
        if k is not None:
            self.on_key(k)

    def apply_fill(self, addr, payload):
        for i, w in enumerate(payload):
            self.mem[(addr + i) & (DEU_MEMORY_WORDS - 1)] = w & 0xFFFF

    def set_clock(self, mission, event, conv):
        self.clock = (mission, event, conv)

    def set_poll_fail(self, fail):
        self.poll_fail = fail

    def blink_tick(self):
        self.blink_on = not self.blink_on

    def redraw(self):
        self.cv.delete("all")
        w = int(self.cv.winfo_width() or self.size)
        h = int(self.cv.winfo_height() or self.size)
        fx0, fx1, fy0, fy1 = FRUSTUM
        self._sx = w / (fx1 - fx0)
        self._sy = h / (fy1 - fy0)
        self._ox = fx0
        self._oy = fy0
        self._drawn = []
        # background pass then foreground
        if decode_fcw(self.mem[ADDR["BACKGROUND_TOP"]])[0] == "BRANCH":
            self._walk(ADDR["BACKGROUND_TOP"], stop_at=CF_PAD)
        self._walk(ADDR["DISPLAY_HEADER"], stop_at=None)
        if self.poll_fail:
            self._text_cell(20, 12, "POLL FAIL", RED, 1.4)
        if self.clock:
            mt = int(self.clock[0])
            hh, rem = divmod(mt, 3600)
            mm, ss = divmod(rem, 60)
            self._text_cell(40, 0, "%03d/%02d:%02d:%02d" % (hh // 24, hh % 24, mm, ss),
                            GREEN, 1.0)

    def _px(self, col, row):
        x = (col - self._ox) * self._sx
        y = (row - self._oy) * self._sy
        return x, y

    def _line(self, pts, color, width=2):
        if len(pts) < 2:
            return
        flat = []
        for c, r in pts:
            x, y = self._px(c, r)
            flat.extend((x, y))
        self.cv.create_line(*flat, fill=color, width=width)

    def _text_cell(self, col, row, s, color, scale=1.0):
        x, y = self._px(col, row)
        px = max(6, int(round(self._sy * 0.72 * scale)))
        self.cv.create_text(x, y, text=s, fill=color, anchor="nw",
                            font=("Courier", px, "bold"))

    def _walk(self, start, stop_at):
        _g = geom()
        grid = _g["grid"]
        beam_x, beam_y = _g["col0"], _g["row0"]
        tx = ty = 0
        xy_ref = False
        home_x, home_y = beam_x, beam_y
        sector = 1
        major = COL_PITCH
        minor = -ROW_PITCH
        axis_y = blink = dash = False
        fcw1_b = fcw3_b = False
        large = False
        angle = 0.0
        angle_step = 0.0
        incr_on = False
        vec_rotate = False
        color_code = None
        slope = None
        lsite_hi = None
        repeat = 0
        row_scale = ADJ["rowGap"]
        src = self.mem
        pc = start
        visited = set()
        splice = None
        steps = 0

        def pen_x():
            return cell_col(beam_x) + 1 + ADJ["textX"]

        def pen_y():
            return cell_row(beam_y) * row_scale + 1 + ADJ["textY"] + ADJ["pageY"]

        def pen_color():
            return _color(color_code)

        def rot(dx, dy):
            if not angle:
                return dx, dy
            cs, sn = math.cos(angle), math.sin(angle)
            return dx * cs + dy * sn, -dx * sn + dy * cs

        def advance():
            nonlocal beam_x, beam_y, angle
            if axis_y:
                dx, dy = rot(0, major)
            else:
                dx, dy = rot(major, 0)
            beam_x += dx
            beam_y += dy
            if angle_step:
                angle += angle_step

        def cr():
            nonlocal beam_x, beam_y
            if axis_y:
                beam_y = home_y
                beam_x += minor
            else:
                beam_x = home_x
                beam_y += minor

        def draw_glyph(g):
            nonlocal beam_x, beam_y
            if g == 0x0D:
                cr()
                return
            if g == 0x08:
                if axis_y:
                    beam_y -= major
                else:
                    beam_x -= major
                return
            if g == 0x00:
                return
            ch = DEU_CHARSET.get(g)
            if ch and ch != " ":
                if not blink or self.blink_on:
                    sc = (COL_PITCH_L / float(COL_PITCH)) if large else 1.0
                    self._text_cell(pen_x(), pen_y(), ch, pen_color(), sc)
            advance()

        def draw_vector(a, b):
            nonlocal beam_x, beam_y, slope
            major_e = -b["len"] if a and b["negative"] else b["len"]
            minor_e = int(round((a["slope"] / 2.0) * b["len"] / 512.0))
            if a["yMajor"]:
                dy = major_e
                dx = minor_e * (-1 if a["signDiffer"] else 1) * (-1 if dy < 0 else 1)
            else:
                dx = major_e
                dy = minor_e * (-1 if a["signDiffer"] else 1) * (-1 if dx < 0 else 1)
            if vec_rotate:
                dx, dy = rot(dx, dy)
            x0, y0 = pen_x() + ADJ["vecX"], pen_y() + ADJ["vecY"]
            beam_x += dx
            beam_y += dy
            x1, y1 = pen_x() + ADJ["vecX"], pen_y() + ADJ["vecY"]
            if not blink or self.blink_on:
                self._line([(x0, y0), (x1, y1)], pen_color())

        def draw_circle(r):
            if r <= 0:
                return
            cx, cy = pen_x() + ADJ["vecX"], pen_y() + ADJ["vecY"]
            n = max(24, min(96, int(round(2 * r))))
            pts = []
            for i in range(n + 1):
                ang = 2 * math.pi * i / n
                pts.append((cx + r * math.cos(ang) / COL_PITCH,
                            cy - r * math.sin(ang) / ROW_PITCH))
            if not blink or self.blink_on:
                self._line(pts, pen_color())

        while steps < MAX_FCW_STEPS and 0 <= pc < len(src):
            steps += 1
            if splice is not None and splice[0] <= 0:
                pc = splice[1]
                splice = None
                continue
            word = src[pc] & 0xFFFF
            if stop_at is not None and word == stop_at:
                break
            pc += 1
            if splice is not None:
                splice = (splice[0] - 1, splice[1])
            name, v, hw = decode_fcw(word)
            if name is None:
                continue
            if name == "NOOP":
                pass
            elif name == "REPT":
                repeat = v["count"]
            elif name == "BRANCH":
                tgt = ((sector & 0xF) << 12) | (v.get("addr12", 0) & 0xFFF)
                if splice is not None:
                    pass
                elif tgt not in visited:
                    visited.add(tgt)
                    pc = tgt
                else:
                    break
            elif name == "SUBLIST":
                if "sector" in v:
                    sector = v["sector"]
                nxt_name, nxt_v, _ = decode_fcw(src[pc] if pc < len(src) else 0)
                if splice is not None:
                    if nxt_name == "BRANCH":
                        pc += 1
                        splice = (splice[0] - 1, splice[1])
                elif nxt_name == "BRANCH" and v["count"] > 0:
                    splice = (v["count"], pc + 1)
                    pc = ((sector & 0xF) << 12) | (nxt_v.get("addr12", 0) & 0xFFF)
            elif name == "FCW1":
                dash = v.get("dash") == 1
                blink = v.get("blink") == 1
                fcw1_b = v.get("intensity") == 1
                axis_y = v.get("axisY") == 1
            elif name == "FCW2":
                xy_ref = v.get("xyRef") == 3
                incr_on = v.get("incr") == 1
                if not incr_on:
                    angle_step = 0.0
                if v.get("eor") == 1:
                    break
                mode = v.get("mode", 0)
                g = mode & 3
                if g == GEN_VECTOR:
                    vec_rotate = (mode & UPRIGHT) == 0
                elif g in (GEN_CHAR_SMALL, GEN_CHAR_LARGE):
                    large = g == GEN_CHAR_LARGE
                    if mode & UPRIGHT:
                        angle = 0.0
            elif name == "FCW3":
                color_code = v["color"] if v.get("select") == 1 else None
                fcw3_b = v.get("intensity") == 1
            elif name == "ROT":
                angle = -2 * math.pi * v["angle"] / 4096.0
            elif name == "MAJINC":
                if incr_on:
                    angle_step = -2 * math.pi * (hw & 0x0FFF) / 32768.0
                else:
                    major = v["step"]
            elif name in ("MININC", "SPTYPE"):
                minor = v["step"]
            elif name == "XPOS":
                if v.get("translate") == 1:
                    tx = v["x"]
                else:
                    self._grid_tally[0] += 1
                    if not in_au_grid(v["x"], "x"):
                        self._grid_tally[1] += 1
                    beam_x = (v["x"] + (tx if xy_ref else 0)) % grid
                    home_x = beam_x
                    beam_y = home_y
            elif name == "YPOS":
                if v.get("translate") == 1:
                    ty = v["y"]
                else:
                    self._grid_tally[0] += 1
                    if not in_au_grid(v["y"], "y"):
                        self._grid_tally[1] += 1
                    beam_y = (v["y"] + (ty if xy_ref else 0)) % grid
                    home_y = beam_y
            elif name == "CIRCLE":
                draw_circle(v["radius"])
            elif name == "LSITE1":
                lsite_hi = hw
            elif name == "LSITE2":
                if lsite_hi is not None:
                    a = (lsite_hi >> 4) & 0x7F
                    b = (((lsite_hi & 0x0F) << 3) | ((hw >> 8) & 0x07)) & 0x7F
                    c = (hw >> 1) & 0x7F
                    for g in (a, b, c):
                        draw_glyph(g)
                    lsite_hi = None
            elif name == "VECA":
                slope = v
            elif name == "VECB":
                if slope is not None:
                    draw_vector(slope, v)
                slope = None
            elif name == "CHAR2":
                n = repeat if repeat > 0 else 1
                repeat = 0
                for _ in range(n):
                    draw_glyph(v["g1"])
                    draw_glyph(v["g2"])
        # geometry chooser
        seen, bad = self._grid_tally
        if seen > 8:
            want = "dfg" if bad > seen * 0.35 else "gpcipl"
            if want != _geom_name:
                log("DEU geometry -> %s (%d/%d position words outside GPCIPL window)"
                    % (want, bad, seen))
                set_geom(want)
                self._grid_tally = [0, 0]


# keyCode map from kybd.coffee DPSKeys
_KEYSYM = {
    "0": "0", "1": "1", "2": "2", "3": "3", "4": "4", "5": "5",
    "6": "6", "7": "7", "8": "8", "9": "9",
    "a": "A", "b": "B", "c": "C", "d": "D", "e": "E", "f": "F",
    "A": "A", "B": "B", "C": "C", "D": "D", "E": "E", "F": "F",
    "plus": "PLUS", "equal": "PLUS", "minus": "MINUS", "period": "DECIMAL",
    "Return": "EXEC", "KP_Enter": "EXEC",
    "p": "PRO", "P": "PRO", "r": "RESUME", "R": "RESUME",
    "o": "OPS", "O": "OPS", "s": "SPEC", "S": "SPEC",
    "i": "ITEM", "I": "ITEM", "k": "ACK", "K": "ACK",
    "y": "SYS_SUMM", "Y": "SYS_SUMM", "u": "FAULT_SUMM", "U": "FAULT_SUMM",
    "g": "GPC_CRT", "G": "GPC_CRT", "t": "IO_RESET", "T": "IO_RESET",
    "BackSpace": "CLEAR", "Escape": "CLEAR",
}


def _key_from_event(ev):
    name = _KEYSYM.get(ev.keysym) or _KEYSYM.get(ev.char)
    if name is None:
        return None
    return KEY.get(name)


# Keyboard scan codes (deuCode) as sent on _KYBDn
DEU_SCAN = {
    "ACK": 0xFFF9, "MSG_RESET": 0xFFF1, "SYS_SUMM": 0xFFE9,
    "FAULT_SUMM": 0xFFE1, "C": 0xFFD9, "B": 0xFFD1, "A": 0xFFC9,
    "GPC_CRT": 0xFFC1, "F": 0xFFFA, "E": 0xFFBA, "D": 0xFF7A,
    "IO_RESET": 0xFF3A, "3": 0xFEFA, "2": 0xFEFB, "1": 0xFE7A,
    "ITEM": 0xFE3A, "6": 0xFFFB, "5": 0xFDFB, "4": 0xFBFB,
    "EXEC": 0xF9FB, "9": 0xF7FB, "8": 0xF5FB, "7": 0xF3FB,
    "OPS": 0xF1FB, "PLUS": 0xFFFC, "0": 0xEFFC, "MINUS": 0xDFFC,
    "SPEC": 0xCFFC, "PRO": 0xBFFC, "DECIMAL": 0xAFFC,
    "CLEAR": 0x9FFC, "RESUME": 0x8FFC,
}
SCAN_TO_GPC = {}
for _nm, _scan in DEU_SCAN.items():
    SCAN_TO_GPC[_scan] = KEY[_nm]


# ---------------------------------------------------------------------------
# IDP + MDU processes in one interpreter
# ---------------------------------------------------------------------------

class IDP(object):
    HEARTBEAT_MS = 125

    def __init__(self, lru_name, ipled=False):
        self.id = lru_name  # IDP1
        conf = MEDS_IDPS[lru_name]
        self.dk_name = conf["dkBus"]
        self.buses = {}
        for b in conf["busses"]:
            if b in BUS_CONFIG:
                self.buses[b] = Bus(b)
        self.dk = self.buses[self.dk_name]
        self.mdu_bus = self.buses.get("_" + lru_name)
        self.mdus = []
        self.unit = DEUUnit(
            name="IDP%s" % lru_name[-1],
            send=self._send_dk,
            on_fill=self._fill_mdus,
            on_reset=self._reset_mdus,
            on_time=self._clock_mdus,
            on_poll=self._poll_mdus,
            ipled=ipled,
        )
        self.dk.on_receive(self._recv_dk)
        if self.mdu_bus:
            self.mdu_bus.on_receive(self._recv_mdu)
        for bname, bus in self.buses.items():
            if bname.startswith("_KYBD"):
                bus.on_receive(self._recv_kybd)
        self._hb_due = 0.0

    def attach_mdu(self, mdu):
        self.mdus.append(mdu)

    def _send_dk(self, words):
        msg = BusMsg(len(words))
        msg.data16 = list(words)
        self.dk.send_msg(msg)

    def _send_mdu(self, tag, words=None):
        words = words or []
        if not self.mdu_bus:
            return
        msg = BusMsg(1 + len(words))
        msg.data16[0] = tag
        for i, w in enumerate(words):
            msg.data16[1 + i] = w & 0xFFFF
        self.mdu_bus.send_msg(msg)

    def _fill_mdus(self, addr, payload):
        self._send_mdu(MDU_MSG["FILL"], [addr] + list(payload))
        for m in self.mdus:
            m.apply_fill(addr, payload)
            m.redraw()

    def _reset_mdus(self):
        self._send_mdu(MDU_MSG["RESET_SPL"])

    def _clock_mdus(self, t):
        self._send_mdu(MDU_MSG["CLOCK"], [
            max(0, int(round(t["mission"]))),
            max(0, int(round(t["event"]))),
            t["conv"],
        ])
        for m in self.mdus:
            m.set_clock(t["mission"], t["event"], t["conv"])
            m.redraw()

    def _poll_mdus(self):
        self._send_mdu(MDU_MSG["POLL"], [int(self.id[-1])])
        for m in self.mdus:
            if m.poll_fail:
                m.set_poll_fail(False)
                m.redraw()

    def _recv_dk(self, bus_id, msg):
        self.unit.recv(msg.data16)

    def _recv_mdu(self, bus_id, msg):
        if not msg.data16:
            return
        tag = msg.data16[0]
        if tag == MDU_MSG["SET_MAJOR_FUNC"] and len(msg.data16) > 1:
            mf = msg.data16[1] & 3
            was = self.unit.major_func
            self.unit.major_func = mf
            self.unit.log("major function %s -> %s" % (was, mf))
            for m in self.mdus:
                m.show_mf(mf)

    def _recv_kybd(self, bus_id, msg):
        for w in msg.data16:
            gpc = SCAN_TO_GPC.get(w & 0xFFFF)
            if gpc is not None:
                self.unit.press_key(gpc)
            else:
                log("%s unknown keyboard scan 0x%04x" % (self.id, w & 0xFFFF))

    def heartbeat(self, now):
        if now >= self._hb_due:
            self._send_mdu(MDU_MSG["HEARTBEAT"], [int(self.id[-1])])
            for m in self.mdus:
                m.blink_tick()
                m.redraw()
            self._hb_due = now + self.HEARTBEAT_MS / 1000.0

    def poll_socks(self):
        for b in self.buses.values():
            b.poll()

    def set_major_func(self, mf):
        self.unit.major_func = mf & 3
        for m in self.mdus:
            m.show_mf(mf)

    def load_dev_dfb(self, path):
        with open(path, "rb") as f:
            buf = f.read()
        words = []
        for i in range(0, len(buf) - 1, 2):
            words.append((buf[i] << 8) | buf[i + 1])
        addr = ADDR["DISPLAY_HEADER"]
        for i, w in enumerate(words):
            self.unit.mem[(addr + i) & (DEU_MEMORY_WORDS - 1)] = w & 0xFFFF
        self._fill_mdus(addr, words)


class App(object):
    POLL_FAIL_S = 4.0

    def __init__(self, cfg, opts):
        self.cfg = cfg
        self.opts = opts
        self.idps = {}
        self.mdus = []
        self._poll_heard = {}
        self.root = tk.Tk()
        self.root.withdraw()
        self.root.title("MEDS2")

    def start(self):
        start = self.cfg.get("start") or ["crt1", "idp1"]
        # IDPs first (headless)
        for name in start:
            lru = self.cfg["lrus"].get(name, {})
            if lru.get("module") == "meds/idp":
                lru_id = lru.get("config", {}).get("lru", "IDP1")
                ipled_opt = lru.get("config", {}).get("ipled")
                ipled = True if ipled_opt is None else bool(ipled_opt)
                idp = IDP(lru_id, ipled=ipled)
                self.idps[lru_id] = idp
                log("started %s (%s) ipled=%s" % (name, lru_id, ipled))
        # MDUs
        for name in start:
            lru = self.cfg["lrus"].get(name, {})
            if lru.get("module") != "meds/mdu":
                continue
            lru_id = lru.get("config", {}).get("lru", "CRT1")
            mconf = MEDS_MDUS.get(lru_id, MEDS_MDUS["CRT1"])
            pri = mconf["dataBus"]["P"]  # IDP1
            win = lru.get("window") or {}
            size = win.get("displayPx") or win.get("width") or 1024
            xy = (win.get("x", 50), win.get("y", 50))
            envpos = os.environ.get("NSTS_MDU_POS")
            if envpos:
                try:
                    x, y = envpos.split(",")
                    xy = (int(x), int(y))
                except ValueError:
                    pass
            idp = self.idps.get(pri)
            if idp is None:
                idp = IDP(pri, ipled=False)
                self.idps[pri] = idp
                log("started implied %s" % pri)

            def on_key(code, idp=idp):
                idp.unit.press_key(code)

            def on_mf(mf, idp=idp):
                idp.set_major_func(mf)
                msg = BusMsg(2)
                msg.data16[0] = MDU_MSG["SET_MAJOR_FUNC"]
                msg.data16[1] = mf & 3
                if idp.mdu_bus:
                    idp.mdu_bus.send_msg(msg)

            def on_geom():
                pass

            mdu = MDUWindow(name, lru_id, size, xy, pri, on_key, on_mf, on_geom)
            idp.attach_mdu(mdu)
            self.mdus.append(mdu)
            log("started %s (%s) %dx%d at %s" % (name, lru_id, size, size, xy))
            init = lru.get("init") or {}
            if (self.opts.display or init.get("display") or "DPS") != "DPS":
                log("display %s: DPS renderer only in this port" %
                    (self.opts.display or init.get("display")))

        if self.opts.dev:
            dfb = os.path.join(nsts_top(), "data", "TEST-9011-GPC_MEMORY.dfb")
            if os.path.isfile(dfb):
                for idp in self.idps.values():
                    idp.load_dev_dfb(dfb)
                    log("dev: loaded %s" % dfb)

        self._tick()
        self.root.mainloop()

    def _tick(self):
        now = time.time()
        for idp in self.idps.values():
            idp.poll_socks()
            idp.heartbeat(now)
        for mdu in self.mdus:
            # local poll-fail: if IDP has not polled recently
            pass
        self.root.after(20, self._tick)


def load_config(path, opts):
    with open(path, "r") as f:
        cfg = json.load(f)
    override = os.environ.get("NSTS_SIM_CONFIG")
    if override and os.path.isfile(override) and os.path.abspath(override) != os.path.abspath(path):
        with open(override, "r") as f:
            ov = json.load(f)
        # shallow-deep merge of lrus
        if "lrus" in ov:
            cfg.setdefault("lrus", {}).update(ov["lrus"])
        cfg.update((k, v) for k, v in ov.items() if k != "lrus")
        log("loaded config override from %s" % override)
    if opts.lrus:
        cfg["start"] = [n.lower() for n in opts.lrus]
    size = 0
    if opts.size:
        size = int(opts.size)
        if size <= 0:
            sys.exit("MEDS2: --size wants a positive pixel count")
    for name in cfg.get("start") or []:
        lru = cfg.get("lrus", {}).get(name)
        if not lru:
            continue
        if lru.get("module") == "meds/mdu":
            lru.setdefault("init", {})
            if opts.display:
                lru["init"]["display"] = opts.display
            if opts.menu:
                lru["init"]["menu"] = opts.menu
            if size > 0:
                lru.setdefault("window", {})["displayPx"] = size
    return cfg


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="MEDS2 glass cockpit — MDU display / IDP LRUs (Python)")
    ap.add_argument("lrus", nargs="*",
                    help="LRU names from meds.json (e.g. crt1 idp1)")
    ap.add_argument("--config", default=None,
                    help="alternate LRU config JSON")
    ap.add_argument("--display", default=None,
                    help="initial MDU display (DPS, AE_PFD, ...)")
    ap.add_argument("--menu", default=None, help="initial MDU menu")
    ap.add_argument("--size", default=None,
                    help="MDU window size in pixels, square")
    ap.add_argument("--dev", action="store_true",
                    help="standalone: no GPC, preload a test DPS format")
    ap.add_argument("--list", action="store_true",
                    help="list available LRU names and exit")
    args = ap.parse_args(argv)

    path = args.config or default_config_path()
    if not os.path.isfile(path):
        sys.exit("MEDS2: no config at %s" % path)
    with open(path) as f:
        raw = json.load(f)
    available = [n for n in (raw.get("lrus") or {}) if n != "shared"]
    if args.list:
        print("available LRUs:")
        for n in sorted(available):
            l = raw["lrus"][n]
            print("  %-8s  %s  %s" % (n, l.get("module"), l.get("config", {}).get("lru", "")))
        return
    unknown = [n.lower() for n in args.lrus if n.lower() not in raw.get("lrus", {})]
    if unknown:
        sys.exit("MEDS2: unknown LRU name(s): %s\navailable: %s" % (
            ", ".join(unknown), ", ".join(available)))
    cfg = load_config(path, args)
    log("config %s  start %s" % (path, cfg.get("start")))
    App(cfg, args).start()


if __name__ == "__main__":
    main()
