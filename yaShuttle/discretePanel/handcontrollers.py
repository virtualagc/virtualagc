#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""The orbiter's hand controllers, from a physical joystick.

A hand controller is not something a 2-D window can stand in for, so this
program has none: it reads a joystick through pygame (SDL2's joystick
support, the same on Linux, macOS and Windows) and drives the controller's
contacts on the forward MDMs the way panelO6.py drives the panel switches --
datagrams on each MDM's hardware-side bus, the reference's `_FFk_mdmIO`
(port base + 100 + k - 1), five big-endian halfwords: op (1 SET, 2 RESET),
card type, card << 8 | channel, count (1), the bits.  yaGPC2's mdmdev.c ORs
them into the FF DSCRT words PASS reads.

THE TRANSLATIONAL HAND CONTROLLER (THC).  Six contacts, +/-X, +/-Y, +/-Z,
three of each (A/B/C on FF1/FF2/FF3), voted 2 of 3 (crew-switches-OPS2.md,
section A; GR2ORB.hal 188-210, CGBIH1.hal 2567-2578 and 2902-2913):

    forward THC   DSCRT4  = DIL card 6  channel 0, bits 8-13
    aft THC       DSCRT12 = DIL card 15 channel 0, bits 8-13
    +X 0x0100  -X 0x0080  +Y 0x0040  -Y 0x0020  +Z 0x0010  -Z 0x0008

+ and - on one axis at once zeroes the whole THC (GR0ORB.hal 67-104), so
the mapping never asserts both.  The aft THC is transformed by the A6U SENSE
switch inside PASS (GP0THC.hal 58-60); nothing here knows about it.

THE ROTATIONAL HAND CONTROLLER (RHC) is analog: each axis is three
transducers on three MDMs' AID cards, read in the HFE PROM read at words
21-35 (CGBIH1.hal 555-594, 1949-1987, 2950-2975; GR6ORB.hal 82-94):

    LH (CDR)  roll/pitch/yaw  FF1 FF2 FF3   AID card 1  ch 0/1/2
    RH (PLT)  roll/pitch/yaw  FF2 FF3 FF4   AID card 14 ch 0/1/2
    aft       roll            FF1 FF4 FF3   AID card 1  ch 5
              pitch / yaw     FF1 FF2 FF3   AID card 1  ch 6 / 7

A word is a signed halfword at 6400 counts a volt.  PASS turns it into
degrees at 4.762 deg/V (roll, pitch) and 2.777 deg/V (yaw), works out
detent (out at 1.725 / 0.975 deg) and softstop (21.17 / 11.41 deg, about
4.4 V) itself, mid-value selects the three, and zeroes an RHC whose
transducers disagree (GP2ORB.hal 131-347, GRGFIX.hal, GRQRHC.hal).  So a
full-throw stick is sent as about 5 V -- past softstop near the end of its
travel, as the real one goes -- and 0 at rest, which is in detent.  They go
as op 4 VALUE records of type 6 (AID), every 50 ms and at once on a change.

Default mapping (Logitech Extreme 3D Pro; every entry overridable with
--config FILE, a JSON object of the same keys):

    hat left / right        THC -Y / +Y
    hat up / down           THC -Z / +Z      (THC up is -Z in orbiter axes)
    button 5 / button 3     THC +X / -X      (the upper thumb buttons)

Buttons are numbered as printed on the stick, 1-12 (pygame counts from 0).

The joystick may be connected or disconnected while this runs; while there
is none both controllers are held in detent.  An axis or the hat that has
not moved since the stick was opened is ALSO held in detent: SDL has no
value for it until the stick sends one, and this stick sends only changes,
so until then it reads -1 (seen on Linux and macOS alike).  On macOS the
app running this may also need Input Monitoring permission (System
Settings, Privacy & Security) for the stick's input to arrive.

    python3 handcontrollers.py --thc fwd
    python3 handcontrollers.py --thc aft --port-base 7300
    python3 handcontrollers.py --thc fwd --test "+X 2"    (no joystick:
                                     hold +X for 2 s, release, and exit)
    python3 handcontrollers.py --rhc lh --test-rhc "roll 0.5 3"
                                    (no joystick: half right roll for 3 s)

The stick's axes: 0 = X (roll), 1 = Y (pitch), 2 = twist (yaw).  Which sign
of each is the RHC's positive one is in "rhc_sign" (the source does not say;
it is set by flying it).
"""
import argparse
import json
import math
import os
import socket
import struct
import sys
import time

import discretes as D

MDM_IO_OFFSET = 100
OP_SET, OP_RESET = 1, 2
TYPE_DIL = 1
THC_CARD = {"fwd": (6, 0), "aft": (15, 0)}
THC_UNITS = (1, 2, 3)                       # contacts A, B, C
THC_BITS = {"+X": 0x0100, "-X": 0x0080, "+Y": 0x0040,
            "-Y": 0x0020, "+Z": 0x0010, "-Z": 0x0008}
THC_MASK = 0x01F8
REPUBLISH_S = 0.25
TYPE_AID, OP_VALUE = 6, 4
RHC_FULL = 32000                 # counts at full throw: 5.0 V
RHC_SEND_S = 0.05
RHC_AXES = ("roll", "pitch", "yaw")
RHC_CHANNELS = {   # axis: [(MDM unit, AID card, channel)] for the 3 transducers
    "lh":  {"roll": [(1, 1, 0), (2, 1, 0), (3, 1, 0)],
            "pitch": [(1, 1, 1), (2, 1, 1), (3, 1, 1)],
            "yaw": [(1, 1, 2), (2, 1, 2), (3, 1, 2)]},
    "rh":  {"roll": [(2, 14, 0), (3, 14, 0), (4, 14, 0)],
            "pitch": [(2, 14, 1), (3, 14, 1), (4, 14, 1)],
            "yaw": [(2, 14, 2), (3, 14, 2), (4, 14, 2)]},
    "aft": {"roll": [(1, 1, 5), (4, 1, 5), (3, 1, 5)],
            "pitch": [(1, 1, 6), (2, 1, 6), (3, 1, 6)],
            "yaw": [(1, 1, 7), (2, 1, 7), (3, 1, 7)]},
}

DEFAULT_MAP = {
    "hat_x": ["-Y", "+Y"],        # hat value -1, +1
    "hat_y": ["+Z", "-Z"],        # SDL hat y: -1 is DOWN, +1 is UP
    "buttons": {"5": "+X", "3": "-X"},     # printed button numbers
    "rhc_axis": {"roll": 0, "pitch": 1, "yaw": 2},
    "rhc_sign": {"roll": 1, "pitch": 1, "yaw": 1},
    "rhc_deadband": 0.05,        # of full throw; the Extreme 3D Pro rests within 0.04
}


# PASS's own conversion, AID counts to degrees: 6400 counts a volt, then
# 4.762 deg/V roll and pitch, 2.777 yaw (CGCFL3.hal 102-107).
RHC_DEG_PER_COUNT = {"roll": 4.762 / 6400, "pitch": 4.762 / 6400, "yaw": 2.777 / 6400}
STATUS_S = 0.2


class Status:
    """What the joystick is commanding, in PASS's terms, so the settings can
    be checked by eye.  On a terminal one line, rewritten in place; when
    stdout is not a terminal (simulatePASS's log) a line only on a change."""

    def __init__(self, rhc, thc, enabled):
        self.rhc, self.thc = rhc, thc
        self.tty = sys.stdout.isatty()
        self.enabled = enabled
        self.last = None
        self.when = 0.0

    HAT = {(0, 1): "UP", (0, -1): "DOWN", (-1, 0): "LEFT", (1, 0): "RIGHT",
           (-1, 1): "UP-LEFT", (1, 1): "UP-RIGHT", (-1, -1): "DOWN-LEFT",
           (1, -1): "DOWN-RIGHT"}

    def show(self, counts, thc_bits, js=None):
        if not self.enabled:
            return
        raw = ""
        if js is not None:
            btns = [str(i + 1) for i in range(js.get_numbuttons()) if js.get_button(i)]
            hat = self.HAT.get(js.get_hat(0), "-") if js.get_numhats() else "-"
            raw = "   [buttons %s  hat %s]" % (",".join(btns) or "-", hat)
        rhc = "  ".join("%s %+6.1f" % (a.upper(), counts[a] * RHC_DEG_PER_COUNT[a])
                        for a in RHC_AXES)
        thc = " ".join(d for d, b in THC_BITS.items() if thc_bits & b) or "-"
        line = "RHC %s  %s deg" % (self.rhc.upper(), rhc)
        if self.thc:
            line += "   THC %s  %s" % (self.thc.upper(), thc)
        line += raw
        now = time.monotonic()
        if self.tty:
            if line != self.last and now - self.when >= STATUS_S:
                sys.stdout.write("\r" + line + "   ")
                sys.stdout.flush()
                self.last, self.when = line, now
        else:
            coarse = (tuple(round(counts[a] * RHC_DEG_PER_COUNT[a]) for a in RHC_AXES),
                      thc_bits, raw)
            if coarse != self.last:
                print("handcontrollers: " + line, flush=True)
                self.last = coarse


def log(msg):
    print("handcontrollers: %s" % msg, flush=True)


class Publisher:
    """The THC's contacts; station None (the PLT's, who has no THC) sends
    nothing."""
    def __init__(self, station):
        self.station = station
        self.card, self.ch = THC_CARD[station] if station else (None, None)
        self.sock = D.sender()
        self.bits = 0
        self.sent = None
        self.last_send = 0.0

    def send(self, force=False):
        if self.station is None:
            return
        now = time.monotonic()
        if not force and self.bits == self.sent and now - self.last_send < REPUBLISH_S:
            return
        for u in THC_UNITS:
            port = D.PORT_BASE + MDM_IO_OFFSET + u - 1
            for op, w in ((OP_RESET, THC_MASK & ~self.bits), (OP_SET, self.bits)):
                if w:
                    self.sock.sendto(struct.pack(">HHHHH", op, TYPE_DIL,
                                                 (self.card << 8) | self.ch, 1, w),
                                     (D.GROUP, port))
        if self.bits != self.sent and not sys.stdout.isatty():
            on = [k for k, b in THC_BITS.items() if self.bits & b]
            log("%s THC %s" % (self.station.upper(), " ".join(on) or "in detent"))
        self.sent = self.bits
        self.last_send = now


class RhcPublisher:
    def __init__(self, which, sock):
        self.which = which
        self.sock = sock
        self.counts = dict((a, 0) for a in RHC_AXES)
        self.sent = None
        self.last_send = 0.0

    def send(self, force=False):
        now = time.monotonic()
        if not force and self.counts == self.sent and now - self.last_send < RHC_SEND_S:
            return
        for axis in RHC_AXES:
            v = max(-32767, min(32767, int(self.counts[axis])))
            for u, card, ch in RHC_CHANNELS[self.which][axis]:
                self.sock.sendto(struct.pack(">HHHHh", OP_VALUE, TYPE_AID,
                                             (card << 8) | ch, 1, v),
                                 (D.GROUP, D.PORT_BASE + MDM_IO_OFFSET + u - 1))
        out = dict((a, self.counts[a] != 0) for a in RHC_AXES)
        was = dict((a, (self.sent or {}).get(a, 0) != 0) for a in RHC_AXES)
        if out != was and not sys.stdout.isatty():
            log("%s RHC %s" % (self.which.upper(),
                               " ".join(a for a in RHC_AXES if out[a]) or "in detent"))
        self.sent = dict(self.counts)
        self.last_send = now


def rhc_counts(js, mapping, seen=None):
    """The stick's deflection, as AID counts per RHC axis.  An axis not in
    `seen` -- no motion reported since the stick was opened -- is in detent."""
    out = {}
    db = mapping["rhc_deadband"]
    for axis in RHC_AXES:
        i = mapping["rhc_axis"][axis]
        v = js.get_axis(i) if i < js.get_numaxes() and (seen is None or i in seen) else 0.0
        if abs(v) < db:
            v = 0.0
        else:            # rescale so the deadband's edge is 0, not a step
            v = (abs(v) - db) / (1.0 - db) * (1 if v > 0 else -1)
        out[axis] = round(v * mapping["rhc_sign"][axis] * RHC_FULL)
    return out


def thc_bits(js, mapping, hat_seen=True):
    """The THC contacts the joystick is asking for, never + and - together.
    The hat counts only once it has reported a motion."""
    want = set()
    if js.get_numhats() > 0 and hat_seen:
        hx, hy = js.get_hat(0)
        if hx:
            want.add(mapping["hat_x"][0 if hx < 0 else 1])
        if hy:
            want.add(mapping["hat_y"][0 if hy < 0 else 1])
    for b, d in mapping["buttons"].items():
        i = int(b) - 1                     # printed number -> pygame index
        if 0 <= i < js.get_numbuttons() and js.get_button(i):
            want.add(d)
    for axis in "XYZ":
        if "+" + axis in want and "-" + axis in want:
            want -= {"+" + axis, "-" + axis}
    bits = 0
    for d in want:
        bits |= THC_BITS[d]
    return bits


def run_test_rhc(rp, spec):
    axis, frac, secs = spec.split()
    rp.counts[axis.lower()] = round(float(frac) * RHC_FULL)
    t_end = time.monotonic() + float(secs)
    while time.monotonic() < t_end:
        rp.send()
        time.sleep(0.02)
    rp.counts = dict((a, 0) for a in RHC_AXES)
    for _ in range(10):
        rp.send(force=True)
        time.sleep(RHC_SEND_S)


def run_test(pub, spec):
    direction, secs = spec.split()
    pub.bits = THC_BITS[direction.upper()]
    t_end = time.monotonic() + float(secs)
    while time.monotonic() < t_end:
        pub.send()
        time.sleep(0.05)
    pub.bits = 0
    for _ in range(4):
        pub.send(force=True)
        time.sleep(REPUBLISH_S)


# ---- THE VIRTUAL HAND CONTROLLERS ------------------------------------------
#
# When there is no joystick (or --input virtual), one window stands in for
# both controllers: the design WSL-integration drew up with Ron (2026-10-01).
#
#   RHC, --style split (touch): a knob for pitch/roll and a ring round it for
#     yaw, worked by separate fingers -- SDL's per-finger events, so two
#     fingers give all three axes at once.  Each springs back when lifted.
#   RHC, --style gimbal (mouse): left-drag is pitch/roll, right-drag is yaw,
#     by relative motion; the pointer is grabbed and hidden ONLY while a
#     button is held, and the axes spring back on release.
#   RHC from the keyboard, either style: arrows pitch/roll, Q / E yaw, a
#     fixed third of full throw -- past detent, short of softstop, which on
#     orbit is what the DAP's DISC RATE and PULSE modes respond to.
#   THC from the keyboard: on/off contacts, as the real THC is -- W/S +X/-X,
#     D/A +Y/-Y, Space -Z (up), C +Z (down).  Opposite keys cancel.
#
# Signs: stick right is +roll, stick forward (pushed) is -pitch (nose down),
# twist right is +yaw, as the joystick path sends them (roll checked against
# PASS's rates).  Detent and softstop are drawn at PASS's own thresholds.
# Without keyboard focus the window says so and its keys count as released.

FULL_SIZE = 768        # --size units: 768 is the design (full) window, as in panelO6.py
VIRTUAL_KEY_DEFLECT = 1.0 / 3.0
VIRTUAL_DRAG_FULL = 160.0          # pointer pixels (at scale 1) for full throw
VIRTUAL_RING_FULL_DEG = 60.0       # ring rotation for full yaw
# PASS's thresholds as fractions of full throw (RHC_FULL counts, about 5 V).
_FULL_DEG = dict((a, RHC_FULL * RHC_DEG_PER_COUNT[a]) for a in RHC_AXES)
DETENT_FRAC = {"roll": 1.725 / _FULL_DEG["roll"], "pitch": 1.725 / _FULL_DEG["pitch"],
               "yaw": 0.975 / _FULL_DEG["yaw"]}
SOFTSTOP_FRAC = {"roll": 21.17 / _FULL_DEG["roll"], "pitch": 21.17 / _FULL_DEG["pitch"],
                 "yaw": 11.41 / _FULL_DEG["yaw"]}
THC_KEYS = (("w", "+X"), ("s", "-X"), ("d", "+Y"), ("a", "-Y"),
            ("space", "-Z"), ("c", "+Z"))
# The window's title names the controllers it stands in for -- "THC FWD /
# RHC LH" -- so two instances (the CDR's and the aft station's) can be told
# apart, on screen and by windowLayout (role "hc_fwd_lh" etc.).
def window_title(thc, rhc):
    if not thc:
        return "RHC %s" % rhc.upper()
    return "THC %s / RHC %s" % (thc.upper(), rhc.upper())


def _clip(v, lo=-1.0, hi=1.0):
    return lo if v < lo else hi if v > hi else v


class VirtualControls:
    """State and drawing of the virtual RHC and THC; pygame passed in."""

    def __init__(self, pg, style, scale, rhc_name, thc_name):
        self.pg = pg
        self.style = style
        self.k = scale
        self.rhc_name, self.thc_name = rhc_name, thc_name
        # The PLT's station has no THC, and its window no THC panel: only as
        # wide as the RHC (Ron, 2026-10-01).
        self.W, self.H = int((560 if thc_name else 300) * scale), int(380 * scale)
        self.screen = pg.display.set_mode((self.W, self.H), pg.RESIZABLE)
        pg.display.set_caption(window_title(thc_name, rhc_name))
        self.font = pg.font.SysFont("dejavusans,helvetica,arial", max(9, int(13 * scale)))
        self.small = pg.font.SysFont("dejavusans,helvetica,arial", max(8, int(11 * scale)))
        self.ptr = {"roll": 0.0, "pitch": 0.0, "yaw": 0.0}   # pointer/touch part
        self.drag = None                     # gimbal: "pr" or "yaw" while held
        self.fingers = {}                    # split: finger id -> ("knob"|"ring", data)
        # The REAL keyboard focus, not an assumption: a window that never had
        # it gets no WINDOWFOCUSLOST, so "focused until told otherwise" showed
        # no red border at start-up from a terminal that kept the keyboard
        # (Mac-integrate, 2026-10-01).  sync_focus() re-reads it every frame.
        self.focused = bool(pg.key.get_focused())
        self._layout()

    def _layout(self):
        k = self.k
        self.cx, self.cy = int(150 * k), int(170 * k)
        self.R = int(110 * k)                # pitch/roll field radius = full throw
        self.ring_in, self.ring_out = int(118 * k), int(140 * k)

    # -- input --------------------------------------------------------------
    def handle(self, e):
        pg = self.pg
        if e.type in (pg.WINDOWFOCUSLOST,) or (e.type == pg.ACTIVEEVENT and
                                                getattr(e, "state", 0) & 2 and not e.gain):
            self.focused = False
            self._release_drag()
        elif e.type in (pg.WINDOWFOCUSGAINED,) or (e.type == pg.ACTIVEEVENT and
                                                   getattr(e, "state", 0) & 2 and e.gain):
            self.focused = True
        elif e.type == pg.VIDEORESIZE:
            self.W, self.H = e.w, e.h
        # Touch: per-finger, never the synthesised mouse.
        elif e.type == pg.FINGERDOWN:
            self._finger_down(e)
        elif e.type == pg.FINGERMOTION:
            self._finger_move(e)
        elif e.type == pg.FINGERUP:
            f = self.fingers.pop(e.finger_id, None)
            if f:
                self._spring(f[0])
        elif e.type == pg.MOUSEBUTTONDOWN and not getattr(e, "touch", False):
            if self.style == "gimbal":
                if e.button in (1, 3):
                    self.drag = "pr" if e.button == 1 else "yaw"
                    pg.event.set_grab(True)
                    pg.mouse.set_visible(False)
                    if hasattr(pg.mouse, "get_rel"):
                        pg.mouse.get_rel()
            elif e.button == 1:
                self._finger_down(None, e.pos)          # split, by mouse
        elif e.type == pg.MOUSEBUTTONUP and not getattr(e, "touch", False):
            if self.style == "gimbal":
                self._release_drag()
            else:
                f = self.fingers.pop("mouse", None)
                if f:
                    self._spring(f[0])
        elif e.type == pg.MOUSEMOTION and not getattr(e, "touch", False):
            if self.style == "gimbal" and self.drag:
                dx, dy = e.rel
                full = VIRTUAL_DRAG_FULL * self.k
                if self.drag == "pr":
                    self.ptr["roll"] = _clip(self.ptr["roll"] + dx / full)
                    self.ptr["pitch"] = _clip(self.ptr["pitch"] + dy / full)
                else:
                    self.ptr["yaw"] = _clip(self.ptr["yaw"] + dx / full)
            elif self.style == "split" and "mouse" in self.fingers:
                self._finger_move(None, e.pos)

    def sync_focus(self):
        """Keyboard focus as SDL has it now; losing it releases a drag."""
        now = bool(self.pg.key.get_focused())
        if self.focused and not now:
            self._release_drag()
        self.focused = now

    def _release_drag(self):
        if self.drag:
            self._spring("knob" if self.drag == "pr" else "ring")
            self.drag = None
            self.pg.event.set_grab(False)
            self.pg.mouse.set_visible(True)

    def _spring(self, which):
        if which == "knob":
            self.ptr["roll"] = self.ptr["pitch"] = 0.0
        else:
            self.ptr["yaw"] = 0.0

    def _pos(self, e, pos):
        if pos is not None:
            return pos
        return (e.x * self.W, e.y * self.H)          # touch is normalised

    def _finger_down(self, e, pos=None):
        x, y = self._pos(e, pos)
        r = math.hypot(x - self.cx, y - self.cy)
        fid = "mouse" if e is None else e.finger_id
        if r <= self.R:
            self.fingers[fid] = ("knob", None)
            self._finger_move(e, pos)
        elif self.ring_in - 6 <= r <= self.ring_out + 6:
            self.fingers[fid] = ("ring", math.atan2(y - self.cy, x - self.cx))

    def _finger_move(self, e, pos=None):
        fid = "mouse" if e is None else e.finger_id
        f = self.fingers.get(fid)
        if not f:
            return
        x, y = self._pos(e, pos)
        if f[0] == "knob":
            self.ptr["roll"] = _clip((x - self.cx) / self.R)
            self.ptr["pitch"] = _clip((y - self.cy) / self.R)
        else:
            a = math.atan2(y - self.cy, x - self.cx)
            d = math.degrees((a - f[1] + math.pi) % (2 * math.pi) - math.pi)
            self.ptr["yaw"] = _clip(d / VIRTUAL_RING_FULL_DEG)

    # -- what the controllers command ---------------------------------------
    def deflection(self):
        """Fractions of full throw per RHC axis, pointer/touch plus keys."""
        keys = self.pg.key.get_pressed() if self.focused else None
        out = dict(self.ptr)
        if keys is not None:
            K, kd = self.pg, VIRTUAL_KEY_DEFLECT
            out["pitch"] += kd * (keys[K.K_DOWN] - keys[K.K_UP])
            out["roll"] += kd * (keys[K.K_RIGHT] - keys[K.K_LEFT])
            out["yaw"] += kd * (keys[K.K_e] - keys[K.K_q])
        return dict((a, _clip(v)) for a, v in out.items())

    def thc_bits(self):
        if not self.focused or not self.thc_name:
            return 0
        keys = self.pg.key.get_pressed()
        want = set(d for name, d in THC_KEYS if keys[self.pg.key.key_code(name)])
        for axis in "XYZ":
            if "+" + axis in want and "-" + axis in want:
                want -= {"+" + axis, "-" + axis}
        bits = 0
        for d in want:
            bits |= THC_BITS[d]
        return bits

    # -- drawing ------------------------------------------------------------
    def draw(self, defl, bits):
        pg, s, k = self.pg, self.screen, self.k
        s.fill((40, 42, 44))
        ink, dim = (220, 220, 210), (120, 120, 112)
        # RHC field: softstop and detent circles, the stick's position.
        pg.draw.circle(s, (70, 72, 74), (self.cx, self.cy), self.R)
        for frac, col in ((SOFTSTOP_FRAC["roll"], (190, 140, 60)),
                          (DETENT_FRAC["roll"], (90, 170, 90))):
            pg.draw.circle(s, col, (self.cx, self.cy), max(2, int(self.R * frac)), 1)
        pg.draw.line(s, dim, (self.cx - self.R, self.cy), (self.cx + self.R, self.cy))
        pg.draw.line(s, dim, (self.cx, self.cy - self.R), (self.cx, self.cy + self.R))
        kx = self.cx + int(defl["roll"] * self.R)
        ky = self.cy + int(defl["pitch"] * self.R)
        pg.draw.circle(s, (230, 230, 220), (kx, ky), int(14 * k))
        # Yaw ring, with the deflection as an arc from the top.
        pg.draw.circle(s, (70, 72, 74), (self.cx, self.cy), self.ring_out,
                       self.ring_out - self.ring_in)
        ang = defl["yaw"] * VIRTUAL_RING_FULL_DEG
        if abs(ang) > 0.5:
            rect = pg.Rect(0, 0, 2 * self.ring_out, 2 * self.ring_out)
            rect.center = (self.cx, self.cy)
            a0 = math.radians(90 - max(0, ang))
            a1 = math.radians(90 - min(0, ang))
            pg.draw.arc(s, (230, 230, 220), rect, a0, a1, self.ring_out - self.ring_in)
        for frac in (DETENT_FRAC["yaw"], SOFTSTOP_FRAC["yaw"]):
            for sg in (-1, 1):
                a = math.radians(90 - sg * frac * VIRTUAL_RING_FULL_DEG)
                x0 = self.cx + self.ring_in * math.cos(a)
                y0 = self.cy - self.ring_in * math.sin(a)
                x1 = self.cx + self.ring_out * math.cos(a)
                y1 = self.cy - self.ring_out * math.sin(a)
                pg.draw.line(s, (190, 140, 60) if frac > 0.5 else (90, 170, 90),
                             (x0, y0), (x1, y1), 1)

        def text(t, x, y, f=None, col=ink):
            img = (f or self.small).render(t, True, col)
            s.blit(img, (x, y))
            return img.get_height()

        text("RHC %s" % self.rhc_name.upper(), int(10 * k), int(6 * k), self.font)
        hint = ("drag knob: pitch/roll   drag ring: yaw" if self.style == "split" else
                "left-drag: pitch/roll   right-drag: yaw")
        text(hint, int(10 * k), self.H - int(52 * k))
        text("keys: arrows, Q/E", int(10 * k), self.H - int(36 * k))
        degs = "  ".join("%s %+5.1f" % (a.upper(), defl[a] * _FULL_DEG[a]) for a in RHC_AXES)
        text(degs + " deg", int(10 * k), self.H - int(20 * k))
        # THC: six contacts, lit when closed, with their keys -- at the CDR's
        # and the aft station; the PLT has none.
        x0, y0 = int(330 * k), int(40 * k)
        if self.thc_name:
            text("THC %s" % self.thc_name.upper(), x0, int(6 * k), self.font)
        for i, (name, d) in enumerate(THC_KEYS if self.thc_name else ()):
            on = bool(bits & THC_BITS[d])
            r = pg.Rect(x0, y0 + i * int(34 * k), int(200 * k), int(28 * k))
            pg.draw.rect(s, (225, 190, 70) if on else (70, 72, 74), r, border_radius=4)
            label = "%s   %s" % (d, name.upper() if name != "space" else "SPACE")
            text(label, r.x + int(10 * k), r.y + int(6 * k), self.font,
                 (20, 20, 20) if on else ink)
        if not self.focused:
            pg.draw.rect(s, (200, 40, 40), s.get_rect(), max(3, int(4 * k)))
            msg = self.font.render("NO KEYBOARD FOCUS -- click here; keys inactive",
                                   True, (255, 90, 90))
            s.blit(msg, ((self.W - msg.get_width()) // 2, int(6 * k) + self.font.get_height()))
        pg.display.flip()


def run_virtual(pg, args, pub, rp, status):
    """The window loop: publish what the virtual controllers command."""
    style = args.style
    if style is None:
        try:
            from pygame._sdl2 import touch as _touch
            style = "split" if _touch.get_num_devices() > 0 else "gimbal"
        except Exception:
            style = "gimbal"
    # --size as panelO6 and stsKeyboard mean it, so simulatePASS can hand
    # every widget the same number (and halve it on macOS, where SDL, like
    # Tk, measures windows in points).  This window's layout is drawn at
    # --size 384, so that is scale 1.
    vc = VirtualControls(pg, style, args.size / 384.0, args.rhc, args.thc)
    log("virtual hand controllers, style %s, window '%s'"
        % (style, window_title(args.thc, args.rhc)))
    clock = pg.time.Clock()
    while True:
        for e in pg.event.get():
            if e.type == pg.QUIT:
                return 0
            vc.handle(e)
        vc.sync_focus()
        defl = vc.deflection()
        rp.counts = dict((a, round(defl[a] * RHC_FULL)) for a in RHC_AXES)
        pub.bits = vc.thc_bits()
        pub.send()
        rp.send()
        status.show(rp.counts, pub.bits)
        vc.draw(defl, pub.bits)
        clock.tick(50)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--thc", choices=sorted(THC_CARD), default=None,
                    help="which THC: fwd (the CDR's) or aft; follows --rhc when omitted")
    ap.add_argument("--rhc", choices=sorted(RHC_CHANNELS), default=None,
                    help="which RHC: lh (CDR), rh (PLT) or aft; follows --thc when omitted")
    ap.add_argument("--quiet", action="store_true",
                    help="no running display of what the joystick commands")
    ap.add_argument("--test-rhc", metavar="'AXIS FRACTION SECONDS'",
                    help="no joystick: deflect one RHC axis, e.g. 'roll 0.5 3'")
    ap.add_argument("--port-base", type=int, default=None)
    ap.add_argument("--joystick", type=int, default=0, help="SDL joystick index")
    ap.add_argument("--config", help="JSON mapping overriding the defaults")
    ap.add_argument("--input", choices=("auto", "joystick", "virtual"), default="auto",
                    help="auto (default): the joystick if there is one at start-up, "
                         "else a window of virtual controllers")
    ap.add_argument("--style", choices=("split", "gimbal"), default=None,
                    help="virtual RHC: split (touch) or gimbal (mouse); default "
                         "split if a touchscreen is found, else gimbal")
    ap.add_argument("--size", type=int, default=FULL_SIZE, metavar="N",
                    help="virtual window size, in the other widgets' --size units: "
                         "%d is the design (full) size, simulatePASS's usual 384 "
                         "half of it (default %d)" % (FULL_SIZE, FULL_SIZE))
    ap.add_argument("--test", metavar="'DIR SECONDS'",
                    help="no joystick: hold one THC direction, e.g. '+X 2'")
    args = ap.parse_args(argv)
    # THE STATIONS, the only combinations there are (Ron, 2026-10-01): the
    # forward THC is the CDR's alone, so --thc fwd --rhc lh; the aft station
    # --thc aft --rhc aft; the PLT --rhc rh with no THC.  Either option
    # implies the other; no option is the CDR's station.
    if args.rhc is None:
        args.rhc = "aft" if args.thc == "aft" else "lh"
    if args.thc is None and "--thc" not in (argv if argv is not None else sys.argv[1:]):
        args.thc = {"lh": "fwd", "aft": "aft", "rh": None}[args.rhc]
    if (args.thc, args.rhc) not in (("fwd", "lh"), ("aft", "aft"), (None, "rh")):
        ap.error("the stations are --thc fwd --rhc lh (CDR), --thc aft --rhc aft "
                 "(aft), and --rhc rh (PLT, who has no THC); not --thc %s --rhc %s"
                 % (args.thc, args.rhc))
    if args.test and not args.thc:
        ap.error("--test needs a THC, and the PLT (--rhc rh) has none")
    if args.port_base is not None:
        D.set_port_base(args.port_base)
    mapping = dict(DEFAULT_MAP)
    if args.config:
        with open(args.config) as f:
            mapping.update(json.load(f))
    pub = Publisher(args.thc)
    rp = RhcPublisher(args.rhc, pub.sock)
    if args.thc:
        log("THC %s on FF1-3 card %d channel %d, ports %d-%d"
            % (args.thc.upper(), pub.card, pub.ch, D.PORT_BASE + MDM_IO_OFFSET,
               D.PORT_BASE + MDM_IO_OFFSET + 2))
    else:
        log("no THC: the PLT's station has none")
    log("RHC %s on AID card %s" % (args.rhc.upper(),
        "/".join(sorted(set("%d ch %d" % (c, h) for ax in RHC_CHANNELS[args.rhc].values()
                                                 for _, c, h in ax)))))
    if args.test or args.test_rhc:
        if args.test_rhc:
            run_test_rhc(rp, args.test_rhc)
        if args.test:
            run_test(pub, args.test)
        return 0

    os.environ.setdefault("PYGAME_HIDE_SUPPORT_PROMPT", "1")
    # SDL otherwise takes SIGINT and SIGTERM for itself and turns them into a
    # quit event, so neither Ctrl-C nor simulatePASS's shutdown stopped this.
    os.environ.setdefault("SDL_NO_SIGNAL_HANDLERS", "1")
    # macOS: SDL 2.32's GameController (MFi) backend takes the joystick and
    # then never reports it -- get_count() stays 0 (Mac-integrate, with an
    # Extreme 3D Pro, 2026-10-01).  Overridable; Linux and Windows untouched.
    if sys.platform == "darwin":
        os.environ.setdefault("SDL_JOYSTICK_MFI", "0")
    import pygame
    status = Status(args.rhc, args.thc, not args.quiet)
    # WHICH CONTROLS, decided once: the joystick subsystem alone answers
    # whether a stick is there, before any video driver is chosen -- the
    # joystick path stays windowless (the dummy driver), the virtual one
    # needs a real window.
    pygame.joystick.init()
    mode = args.input
    if mode == "auto":
        mode = "joystick" if pygame.joystick.get_count() > args.joystick else "virtual"
    if mode == "virtual":
        # X11 on Linux, so --layout (windowLayout, which works through X)
        # can find and place it -- under WSLg too.
        if sys.platform.startswith("linux") and os.environ.get("DISPLAY"):
            os.environ.setdefault("SDL_VIDEODRIVER", "x11")
        # macOS: SDL reports Ctrl-click as button 1, so the usual one-button
        # right-click would have been pitch/roll, not yaw (Mac-integrate).
        if sys.platform == "darwin":
            os.environ.setdefault("SDL_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK", "1")
        pygame.init()
        return run_virtual(pygame, args, pub, rp, status)
    os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
    pygame.init()

    def open_stick():
        if pygame.joystick.get_count() <= args.joystick:
            return None
        js = pygame.joystick.Joystick(args.joystick)
        if not hasattr(pygame, "IS_CE"):     # pygame-ce opens it already, and
            js.init()                        # deprecates init()
        log("joystick %d: %s, %d axes, %d buttons, %d hat(s)"
            % (args.joystick, js.get_name(), js.get_numaxes(), js.get_numbuttons(),
               js.get_numhats()))
        return js

    # HOT-PLUG, BOTH WAYS.  A stick connected after start-up is opened when
    # SDL says so, and one that goes away -- unplugged, or switched away by a
    # KVM -- puts both controllers back in detent rather than leaving its
    # last deflection latched, and is waited for again.
    js = open_stick()
    seen_axes, hat_seen = set(), False      # what has reported since opening
    if js is None:
        log("no joystick %d yet; holding the THC and RHC in detent" % args.joystick)
    while True:
        for e in pygame.event.get():
            if e.type == pygame.QUIT:
                return 0
            if e.type == pygame.JOYDEVICEADDED and js is None:
                js = open_stick()
                seen_axes, hat_seen = set(), False
            elif e.type == pygame.JOYDEVICEREMOVED and js is not None and \
                    getattr(e, "instance_id", None) == js.get_instance_id():
                log("joystick %d gone; THC and RHC back in detent" % args.joystick)
                js = None
                seen_axes, hat_seen = set(), False
            elif e.type == pygame.JOYAXISMOTION:
                seen_axes.add(e.axis)
            elif e.type == pygame.JOYHATMOTION:
                hat_seen = True
        if js is None:
            pub.bits = 0
            rp.counts = dict((a, 0) for a in RHC_AXES)
            pub.send()
            rp.send()
            time.sleep(0.1)
            continue
        pub.bits = thc_bits(js, mapping, hat_seen)
        pub.send()
        rp.counts = rhc_counts(js, mapping, seen_axes)
        rp.send()
        status.show(rp.counts, pub.bits, js)
        time.sleep(0.02)

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        if sys.stdout.isatty():
            print()
        sys.exit(0)
