#!/usr/bin/env python3
"""THE GROUND STATION: Mission Control's uplink to the simulated Orbiter.

    python3 groundstation.py [--port-base N] COMMAND ...

    sv                       uplink an ORBITER STATE VECTOR (message 9) taken
                             from the vehicle dynamics' truth state, as the
                             ground did to initialise PASS's navigation
    sv --state GMT X Y Z VX VY VZ
                             ... from a given state instead: PASS GMT seconds
                             (day-of-year x 86400 + seconds of day), M50 feet
                             and feet per second
    rnp YEAR DAY             the RNP epoch (message 59: CGNS_LAUNCH_YEAR and
                             CGNS_RNP_DAY; accepted only in MM 201)
    clear                    two-stage buffer clear
    hello                    power the NSP without sending a command
    raw H H H [H H H ...]    command words as hex halfword triples

HOW IT GETS THERE.  yaGPC2 models NSP1 behind FF MDM 1 (src/mdmdev.c,
nsp_reply); this program sends it each poll's buffer -- up to ten 48-bit
command words -- as one datagram on port base + 99 ("UPL1", a count, the
words), and PASS reads one buffer every 160 ms (FIONSPPG, AIESIP).  Until a
ground has sent something the NSP reads as unpowered, as before.

THE PROTOCOL (SSSRC/DUPNSP.hal, CDULNK.hal, APPLSRC/GTBUPL.hal).  A command
word's first halfword is the vehicle code (3 bits; the I-load
CDUV_NSP_VEHICLE_ILOAD is BIN'010'), the GPC or major function (4 bits; 7
GNC), the opcode (7 bits) and first/last-word flags (2 bits: 2 first, 0
intermediate, 1 last, 3 a single word); the other two halfwords are data.  A
two-stage message is loaded word by word into CDUV_2STAGE_IN -- the first
word's three halfwords, then two from each later word -- and acts only when
an EXECUTE (single-stage opcode X'43' with halfword 2 = X'FEF0') follows.
There is no checksum in the GPC; the NSP's BCH check is not modelled.

Message 9 is 23 halfwords: the header, the time tag as one HAL DOUBLE (an
IBM long hexadecimal float, GMT seconds), the position as three DOUBLEs in
feet, the velocity as three SINGLEs (IBM short floats) in feet per second --
GTBUPL.hal:303-305, 470-485 -- into CGNV_T_GND, CGNV_R_GND, CGNV_V_GND.  PASS
then predicts it to its own current navigation time and installs it as its
state (GELORB, GL1ORB, GL2AUT, GV6STA): it must be within 54,000 s.  The
frame is M50, the frame of PASS's orbit navigation (inferred: the words go
straight into that state).

The truth state comes from yaGPC2's truth feed (port base + 98, "TRU1"),
which needs YAGPC_MDM_DEVICES=1 YAGPC_VEHDYN=1 and a panel.
"""
import argparse
import math
import os
import socket
import struct
import sys
import time

MCAST_GROUP = "239.255.1.1"
UPLINK_OFFSET = 99
TRUTH_OFFSET = 98
FT_M = 0.3048

VEHICLE = 0b010           # CDUV_NSP_VEHICLE_ILOAD
MF_GNC = 7
FIRST, MIDDLE, LAST, SINGLE = 2, 0, 1, 3
OP_STATE_VECTOR = 9
OP_RNP = 59
OP_CLEAR = 0x41
OP_EXECUTE = 0x43
EXECUTE_KEY = 0xFEF0


# --- IBM System/360 hexadecimal floating point --------------------------

def ibm_long(x):
    """A double as the IBM 64-bit form: sign, 7-bit excess-64 exponent of
    16, 56-bit fraction -- four big-endian halfwords."""
    if x == 0.0:
        return [0, 0, 0, 0]
    sign = 0x80 if x < 0 else 0
    x = abs(x)
    e = 0
    while x >= 1.0:
        x /= 16.0
        e += 1
    while x < 0.0625:
        x *= 16.0
        e -= 1
    frac = int(round(x * (1 << 56)))
    if frac >= (1 << 56):                 # rounding carried into a new digit
        frac >>= 4
        e += 1
    word = ((sign | (e + 64)) << 56) | frac
    return [(word >> s) & 0xffff for s in (48, 32, 16, 0)]


def ibm_short(x):
    """A single as the IBM 32-bit form -- two big-endian halfwords."""
    if x == 0.0:
        return [0, 0]
    sign = 0x80 if x < 0 else 0
    x = abs(x)
    e = 0
    while x >= 1.0:
        x /= 16.0
        e += 1
    while x < 0.0625:
        x *= 16.0
        e -= 1
    frac = int(round(x * (1 << 24)))
    if frac >= (1 << 24):
        frac >>= 4
        e += 1
    word = ((sign | (e + 64)) << 24) | frac
    return [(word >> 16) & 0xffff, word & 0xffff]


def from_ibm_long(h):
    w = (h[0] << 48) | (h[1] << 32) | (h[2] << 16) | h[3]
    if w & ((1 << 63) - 1) == 0:
        return 0.0
    s = -1.0 if w >> 63 else 1.0
    e = ((w >> 56) & 0x7f) - 64
    return s * (w & ((1 << 56) - 1)) / float(1 << 56) * 16.0 ** e


def from_ibm_short(h):
    w = (h[0] << 16) | h[1]
    if w & 0x7fffffff == 0:
        return 0.0
    s = -1.0 if w >> 31 else 1.0
    e = ((w >> 24) & 0x7f) - 64
    return s * (w & 0xffffff) / float(1 << 24) * 16.0 ** e


# --- command words --------------------------------------------------------

def header(opcode, fwlw, mf=MF_GNC, vehicle=VEHICLE):
    return ((vehicle & 7) << 13) | ((mf & 0xf) << 9) | ((opcode & 0x7f) << 2) | (fwlw & 3)


def two_stage(opcode, halfwords, mf=MF_GNC, vehicle=VEHICLE):
    """The command words of a two-stage message whose buffer, after its
    header, is `halfwords`: the first word carries the first two, every
    later word two more."""
    data = list(halfwords)
    if len(data) % 2:
        data.append(0)
    pairs = [data[i:i + 2] for i in range(0, len(data), 2)]
    words = []
    for i, p in enumerate(pairs):
        if len(pairs) == 1:
            f = SINGLE
        elif i == 0:
            f = FIRST
        elif i == len(pairs) - 1:
            f = LAST
        else:
            f = MIDDLE
        words.append([header(opcode, f, mf, vehicle), p[0], p[1]])
    return words


def execute(mf=MF_GNC, vehicle=VEHICLE):
    return [header(OP_EXECUTE, SINGLE, mf, vehicle), EXECUTE_KEY, 0]


def clear(mf=MF_GNC, vehicle=VEHICLE):
    return [header(OP_CLEAR, SINGLE, mf, vehicle), 0, 0]


def state_vector_words(gmt, r_ft, v_fts, vehicle=VEHICLE):
    hw = ibm_long(gmt)
    for x in r_ft:
        hw += ibm_long(x)
    for x in v_fts:
        hw += ibm_short(x)
    assert len(hw) == 22
    return two_stage(OP_STATE_VECTOR, hw, vehicle=vehicle)


# --- the link -------------------------------------------------------------

class Link(object):
    def __init__(self, base):
        self.base = base
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        iface = os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(iface))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        self.sock = s

    def send_buffer(self, words):
        """One NSP poll's worth: up to ten command words."""
        assert len(words) <= 10
        b = b"UPL1" + struct.pack(">H", len(words))
        for w in words:
            b += struct.pack(">3H", *w)
        self.sock.sendto(b, (MCAST_GROUP, self.base + UPLINK_OFFSET))

    def send_message(self, words, gap=0.5):
        """A two-stage load in buffers of ten, then the execute on its own
        -- a later poll, as the ground's procedure kept them (TD1004)."""
        self.send_buffer([])                       # power the NSP
        time.sleep(gap)
        for i in range(0, len(words), 10):
            self.send_buffer(words[i:i + 10])
            time.sleep(gap)
        self.send_buffer([execute()])


def truth_state(base, timeout=5.0):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    s.bind(('', base + TRUTH_OFFSET))
    iface = os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton(MCAST_GROUP) + socket.inet_aton(iface))
    s.settimeout(timeout)
    end = time.time() + timeout
    while time.time() < end:
        try:
            d = s.recv(256)
        except socket.timeout:
            break
        if len(d) >= 4 + 8 * 15 and d[:4] == b"TRU1":
            v = struct.unpack(">15d", d[4:4 + 8 * 15])
            return {'t': v[0], 'gmt': v[1], 'r': v[9:12], 'v': v[12:15]}
    return None


def main():
    ap = argparse.ArgumentParser(description="Mission Control's uplink to the simulated Orbiter.")
    ap.add_argument("--port-base", type=int,
                    default=int(os.environ.get("NSTS_BUS_PORT_BASE", "6900")))
    ap.add_argument("--vehicle", type=lambda s: int(s, 0), default=VEHICLE,
                    help="vehicle code in each command word (default BIN'010', the I-load)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sv = sub.add_parser("sv", help="uplink an orbiter state vector (message 9)")
    sv.add_argument("--state", nargs=7, type=float, metavar=("GMT", "X", "Y", "Z", "VX", "VY", "VZ"))
    rnp = sub.add_parser("rnp", help="uplink the RNP epoch (message 59)")
    rnp.add_argument("year", type=int)
    rnp.add_argument("day", type=int)
    sub.add_parser("clear", help="two-stage buffer clear")
    sub.add_parser("hello", help="power the NSP")
    raw = sub.add_parser("raw", help="command words as hex halfword triples")
    raw.add_argument("halfwords", nargs="+")
    args = ap.parse_args()
    link = Link(args.port_base)

    if args.cmd == "sv":
        if args.state:
            gmt, x, y, z, vx, vy, vz = args.state
            r, v = (x, y, z), (vx, vy, vz)
        else:
            tr = truth_state(args.port_base)
            if tr is None:
                sys.exit("groundstation: no truth state on port %d (YAGPC_MDM_DEVICES=1 "
                         "YAGPC_VEHDYN=1, with a panel)" % (args.port_base + TRUTH_OFFSET))
            gmt = tr['gmt']
            r = tuple(c / FT_M for c in tr['r'])
            v = tuple(c / FT_M for c in tr['v'])
        words = state_vector_words(gmt, r, v, args.vehicle)
        d = int(gmt // 86400)
        sod = gmt - 86400 * d
        print("state vector at GMT %03d/%02d:%02d:%06.3f  R %.1f %.1f %.1f ft  V %.3f %.3f %.3f ft/s"
              % (d, sod // 3600, sod % 3600 // 60, sod % 60, r[0], r[1], r[2], v[0], v[1], v[2]))
        for w in words:
            print("  %04X %04X %04X" % tuple(w))
        print("  %04X %04X %04X  execute" % tuple(execute(vehicle=args.vehicle)))
        link.send_message(words)
    elif args.cmd == "rnp":
        words = two_stage(OP_RNP, [args.year & 0xffff, args.day & 0xffff], vehicle=args.vehicle)
        link.send_message(words)
    elif args.cmd == "clear":
        link.send_buffer([])
        time.sleep(0.5)
        link.send_buffer([clear(vehicle=args.vehicle)])
    elif args.cmd == "hello":
        link.send_buffer([])
    elif args.cmd == "raw":
        h = [int(x, 16) for x in args.halfwords]
        if len(h) % 3:
            sys.exit("groundstation: raw takes halfwords in threes")
        words = [h[i:i + 3] for i in range(0, len(h), 3)]
        link.send_buffer([])
        time.sleep(0.5)
        for i in range(0, len(words), 10):
            link.send_buffer(words[i:i + 10])
            time.sleep(0.5)


if __name__ == "__main__":
    main()
