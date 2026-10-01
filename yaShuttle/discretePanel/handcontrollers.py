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
        line = "RHC %s  %s deg   THC %s  %s%s" % (self.rhc.upper(), rhc,
                                                   self.thc.upper(), thc, raw)
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
    def __init__(self, station):
        self.station = station
        self.card, self.ch = THC_CARD[station]
        self.sock = D.sender()
        self.bits = 0
        self.sent = None
        self.last_send = 0.0

    def send(self, force=False):
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


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--thc", choices=sorted(THC_CARD), default="fwd",
                    help="which THC the joystick is (default fwd)")
    ap.add_argument("--rhc", choices=sorted(RHC_CHANNELS), default="lh",
                    help="which RHC the joystick is (default lh, the CDR's)")
    ap.add_argument("--quiet", action="store_true",
                    help="no running display of what the joystick commands")
    ap.add_argument("--test-rhc", metavar="'AXIS FRACTION SECONDS'",
                    help="no joystick: deflect one RHC axis, e.g. 'roll 0.5 3'")
    ap.add_argument("--port-base", type=int, default=None)
    ap.add_argument("--joystick", type=int, default=0, help="SDL joystick index")
    ap.add_argument("--config", help="JSON mapping overriding the defaults")
    ap.add_argument("--test", metavar="'DIR SECONDS'",
                    help="no joystick: hold one THC direction, e.g. '+X 2'")
    args = ap.parse_args(argv)
    if args.port_base is not None:
        D.set_port_base(args.port_base)
    mapping = dict(DEFAULT_MAP)
    if args.config:
        with open(args.config) as f:
            mapping.update(json.load(f))
    pub = Publisher(args.thc)
    rp = RhcPublisher(args.rhc, pub.sock)
    log("THC %s on FF1-3 card %d channel %d, ports %d-%d"
        % (args.thc.upper(), pub.card, pub.ch, D.PORT_BASE + MDM_IO_OFFSET,
           D.PORT_BASE + MDM_IO_OFFSET + 2))
    log("RHC %s on AID card %s" % (args.rhc.upper(),
        "/".join(sorted(set("%d ch %d" % (c, h) for ax in RHC_CHANNELS[args.rhc].values()
                                                 for _, c, h in ax)))))
    if args.test or args.test_rhc:
        if args.test_rhc:
            run_test_rhc(rp, args.test_rhc)
        if args.test:
            run_test(pub, args.test)
        return 0

    os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
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
    pygame.init()
    pygame.joystick.init()
    status = Status(args.rhc, args.thc, not args.quiet)

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
