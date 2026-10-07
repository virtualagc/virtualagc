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
    dolilu FILE [--only OP,...] [--dry-run]
                             the DAY-OF-LAUNCH I-LOAD UPDATE: each message in
                             FILE (JSON, see below) as a two-stage load and
                             its execute, in order, in GNC OPS 9 (GMESTA.hal
                             takes 11-15, 24, 25, 37, 39, 40, 96, 98, 99)
    clear                    two-stage buffer clear
    hello                    power the NSP without sending a command
    raw H H H [H H H ...]    command words as hex halfword triples
    downlink [--log FILE] [--show N] [--seconds S]
                             receive the GPCs' downlist frames: one line a
                             second per GPC (format ID, frame number, words),
                             every frame to FILE (JSON lines: GPC, toggle
                             buffer, simulated time, frame number, format ID,
                             the words in hex), and with --show N the words of
                             every Nth frame
    downlink --decode [--match REGEX] [--changes] [--csv FILE] [--table T]
                             ... and decode them into named measurements
                             (downlist.py, with the table dltable.py made from
                             the flight source, downlist-OI340700.json): a
                             listing of the latest values refreshed once a
                             second, or with --changes a line per value as it
                             changes; --match keeps the MSIDs and names that
                             match; --csv logs every decoded value (simulated
                             time, GPC, format, frame, word, MSID, name, value,
                             units, discrete label)

THE DOWNLINK.  yaGPC2 watches each GPC's IP bus (BCE 24) and sends every
downlist frame PASS writes to the PCM master unit, at its end of message, on
port base + 88 ("DNL1", GPC, toggle buffer, word count, simulated time in
us, the words).  A frame describes itself (CDWDOWNL.hal, DCDDOW.hal): word 1
the sync EB90; word 2 a 2-bit counter, the 6-bit frame number 0-49 and the
8-bit format ID; in frames 0 and 25, word 3 the vehicle, GPC and mission IDs
and words 4-6 the GPC's time (TFCMLTQM half-hours, TFCMLTQH microseconds).
--decode names the rest: see downlist.py and dltable.py.

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

DOLILU FILES.  {"messages": [{"op": 15, "name": "...", "fields": [...]}]};
a field is {"D": x} an IBM long float (HAL DOUBLE), {"E": x} an IBM short
(SINGLE), {"I": n} a signed halfword (INTEGER), {"H": "ABCD"} a raw
halfword, each value or a list of them, laid out in the order GMESTA's
%COPY takes them from CDUV_2STAGE_IN$(2:) (GMESTA.hal, the uplink cases;
STS 83-0002-34 4.2.3 and Tables 4.12-1/2).  Other keys are comments.

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
DOWNLINK_OFFSET = 88
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


def dolilu_halfwords(fields):
    """A DOLILU message's buffer after its header, from its fields."""
    hw = []
    for f in fields:
        (kind, val), = [(k, v) for k, v in f.items() if k in ("D", "E", "I", "H")]
        for x in (val if isinstance(val, list) else [val]):
            if kind == "D":
                hw += ibm_long(float(x))
            elif kind == "E":
                hw += ibm_short(float(x))
            elif kind == "I":
                hw.append(int(x) & 0xffff)
            else:
                hw.append(int(x, 16) & 0xffff)
    return hw


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
            out = {'t': v[0], 'gmt': v[1], 'r': v[9:12], 'v': v[12:15]}
            if len(d) >= 4 + 8 * 17:                    # wheel height (ft), ground speed (kt)
                out['wheel_ft'], out['gs_kt'] = struct.unpack(">2d", d[4 + 8 * 15:4 + 8 * 17])
            return out
    return None


def mcast_listen(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    s.bind(('', port))
    iface = os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton(MCAST_GROUP) + socket.inet_aton(iface))
    s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1 << 20)
    return s


def parse_downlist(d):
    """A DNL1 datagram as {gpc, tb, t_us, words}, or None."""
    if len(d) < 18 or d[:4] != b"DNL1":
        return None
    gpc, tb, n = struct.unpack(">3H", d[4:10])
    (t_us,) = struct.unpack(">d", d[10:18])
    if len(d) < 18 + 2 * n:
        return None
    words = list(struct.unpack(">%dH" % n, d[18:18 + 2 * n]))
    return {'gpc': gpc, 'tb': tb, 't_us': t_us, 'words': words}


def frame_header(words):
    """Sync, frame number, format ID -- and, in frames 0 and 25, the IDs and
    the time words -- of a downlist frame."""
    h = {'sync': words[0] == 0xEB90 if words else False}
    if len(words) >= 2:
        h['counter'] = words[1] >> 14
        h['frame'] = (words[1] >> 8) & 0x3f
        h['format'] = words[1] & 0xff
    if len(words) >= 6 and h.get('frame') in (0, 25):
        # INTEGER(CDUV_NSP_VEHICLE_ILOAD BIT(3) || SUBBIT$(3 AT 14)(TFCMID)
        # || MISSION_ID BIT(8)): 14 bits, right-justified (DCDDOW 012600)
        h['vehicle'] = (words[2] >> 11) & 7
        h['gpc'] = (words[2] >> 8) & 7
        h['mission'] = words[2] & 0xff
        h['time_words'] = words[3:6]
    return h


def downlink(base, log=None, show=0, seconds=0, decode=None, match=None,
             changes=False, csv_path=None):
    import json
    s = mcast_listen(base + DOWNLINK_OFFSET)
    s.settimeout(1.0)
    out = open(log, "a") if log else None
    view = DecodedView(decode, match, changes, csv_path) if decode is not None else None
    t0 = time.time()
    last = {}
    count = {}
    nframes = 0
    try:
        while not seconds or time.time() - t0 < seconds:
            try:
                d = s.recv(512)
            except socket.timeout:
                if view:
                    view.tick()
                continue
            f = parse_downlist(d)
            if f is None:
                continue
            h = frame_header(f['words'])
            nframes += 1
            g = f['gpc']
            count[g] = count.get(g, 0) + 1
            if out:
                out.write(json.dumps({'gpc': g, 'tb': f['tb'], 't_us': f['t_us'],
                                      'frame': h.get('frame'), 'format': h.get('format'),
                                      'words': ["%04X" % w for w in f['words']]}) + "\n")
            if view:
                view.frame(f, h)
                continue
            if show and nframes % show == 0:
                print("GPC%d TB%d t=%.3f frame %s format %s:" % (
                    g, f['tb'], f['t_us'] / 1e6, h.get('frame'), h.get('format')))
                for i in range(0, len(f['words']), 16):
                    print("   %3d: %s" % (i, " ".join("%04X" % w for w in f['words'][i:i + 16])))
            now = time.time()
            if now - last.get(g, 0) >= 1.0:
                last[g] = now
                extra = ""
                if 'mission' in h:
                    extra = "  vehicle %d GPC %d mission %d" % (h['vehicle'], h['gpc'], h['mission'])
                print("GPC%d TB%d t=%9.3f s  %s  format %3s  frame %2s  %3d words  %d frames%s" % (
                    g, f['tb'], f['t_us'] / 1e6, "EB90" if h['sync'] else "NO SYNC",
                    h.get('format'), h.get('frame'), len(f['words']), count[g], extra), flush=True)
    except KeyboardInterrupt:
        pass
    finally:
        if out:
            out.close()
        if view:
            view.close()


class DecodedView:
    """Decoded downlist values: the latest of each, shown as a listing
    refreshed once a second (or a line per change), and every value to CSV."""

    def __init__(self, table_path, match=None, changes=False, csv_path=None):
        import re
        import downlist
        self.dl = downlist
        self.table = downlist.load_table(table_path or None)
        self.match = re.compile(match, re.I) if match else None
        self.changes = changes
        self.latest = {}              # (gpc, msid, name) -> (t, value text, units, fmt, frame, word)
        self.status = {}
        self.unknown = set()
        self.next_draw = 0.0
        self.csv = None
        if csv_path:
            import csv
            new = not os.path.exists(csv_path) or os.path.getsize(csv_path) == 0
            self._csvf = open(csv_path, "a", newline="")
            self.csv = csv.writer(self._csvf)
            if new:
                self.csv.writerow(["time_s", "gpc", "format", "frame", "word", "msid",
                                   "name", "value", "units", "text"])
        print("groundstation: decoding with %s (%s), %d formats"
              % (table_path or downlist.DEFAULT_TABLE, self.table.release,
                 len(self.table.formats)), flush=True)

    def frame(self, f, h):
        fmt, fr, g, t = h.get('format'), h.get('frame'), f['gpc'], f['t_us'] / 1e6
        self.status[g] = (t, fmt, fr, h)
        if fmt not in self.table.formats:
            if fmt not in self.unknown:
                self.unknown.add(fmt)
                print("groundstation: format %s is not in the decode table" % fmt, flush=True)
            return
        for d in self.dl.decode_full(f['words'], fmt, fr, self.table):
            if self.match and not (self.match.search(d["name"]) or self.match.search(d["msid"])):
                continue
            txt = self.dl.fmt_value(d)
            key = (g, d["msid"], d["name"])
            old = self.latest.get(key)
            self.latest[key] = (t, txt, d["units"], fmt, fr, d["word"])
            if self.csv:
                v = d["value"]
                self.csv.writerow(["%.6f" % t, g, fmt, fr, d["word"], d["msid"], d["name"],
                                   repr(v) if isinstance(v, float) else v, d["units"],
                                   d["text"] or ""])
            if self.changes and (old is None or old[1] != txt):
                print("%10.3f GPC%d %-10s %-44s %s %s" % (t, g, d["msid"], d["name"], txt,
                                                         d["units"]), flush=True)
        self.tick()

    def tick(self):
        if self.changes:
            return
        now = time.time()
        if now < self.next_draw:
            return
        self.next_draw = now + 1.0
        import shutil
        cols, rows = shutil.get_terminal_size((120, 40))
        lines = []
        for g, (t, fmt, fr, h) in sorted(self.status.items()):
            lines.append("GPC%d  t=%.3f s  format %s  frame %s%s" % (
                g, t, fmt, fr, "  GPC time %.3f s" % (h['time_words'][0] * 1800.0 + (
                    (h['time_words'][1] << 16) | h['time_words'][2]) * 1e-6)
                if 'time_words' in h else ""))
        lines.append("%-4s %-10s %-44s %-24s %-8s %9s" % ("GPC", "MSID", "NAME", "VALUE",
                                                       "UNITS", "AGE s"))
        tnow = {g: st[0] for g, st in self.status.items()}
        items = sorted(self.latest.items(), key=lambda kv: (kv[0][0], kv[0][2], kv[0][1]))
        room = max(rows - len(lines) - 2, 5)
        for (g, msid, name), (t, txt, u, fmt, fr, w) in items[:room]:
            lines.append(("%-4d %-10s %-44s %-24s %-8s %9.1f" % (
                g, msid, name[:44], txt, u, tnow.get(g, t) - t))[:cols - 1])
        if len(items) > room:
            lines.append("... %d more (narrow with --match)" % (len(items) - room))
        sys.stdout.write("\x1b[H\x1b[2J" + "\n".join(lines) + "\n")
        sys.stdout.flush()

    def close(self):
        if self.csv:
            self._csvf.close()


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
    dn = sub.add_parser("downlink", help="receive, show and log the GPCs' downlist frames")
    dn.add_argument("--log", metavar="FILE", help="append every frame, JSON lines")
    dn.add_argument("--show", type=int, default=0, metavar="N", help="print every Nth frame's words")
    dn.add_argument("--seconds", type=float, default=0, help="stop after this long")
    dn.add_argument("--decode", action="store_true",
                    help="decode the frames into named measurements (downlist.py)")
    dn.add_argument("--table", metavar="JSON", default=None,
                    help="decode table (default downlist-OI340700.json beside this program)")
    dn.add_argument("--match", metavar="REGEX",
                    help="with --decode: only MSIDs/names matching (case-insensitive)")
    dn.add_argument("--changes", action="store_true",
                    help="with --decode: a line per value as it changes, not a refreshing listing")
    dn.add_argument("--csv", metavar="FILE", help="with --decode: append every decoded value")
    dl = sub.add_parser("dolilu", help="uplink day-of-launch I-loads from a JSON file")
    dl.add_argument("file")
    dl.add_argument("--only", metavar="OP,...", help="send only these opcodes")
    dl.add_argument("--dry-run", action="store_true", help="print the command words, send nothing")
    dl.add_argument("--gap", type=float, default=0.5, help="seconds between buffers (default 0.5)")
    raw = sub.add_parser("raw", help="command words as hex halfword triples")
    raw.add_argument("halfwords", nargs="+")
    args = ap.parse_args()
    if args.cmd == "downlink":
        if (args.match or args.changes or args.csv or args.table) and not args.decode:
            args.decode = True
        downlink(args.port_base, args.log, args.show, args.seconds,
                 (args.table or "") if args.decode else None, args.match,
                 args.changes, args.csv)
        return
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
    elif args.cmd == "dolilu":
        import json
        with open(args.file) as fh:
            msgs = json.load(fh)["messages"]
        only = {int(x) for x in args.only.split(",")} if args.only else None
        for m in msgs:
            if only is not None and m["op"] not in only:
                continue
            hw = dolilu_halfwords(m["fields"])
            if len(hw) > 66:
                sys.exit("groundstation: message %d is %d halfwords; CDUV_2STAGE_IN holds 66"
                         % (m["op"], len(hw)))
            words = two_stage(m["op"], hw, vehicle=args.vehicle)
            print("message %d (%s): %d halfwords, %d command words"
                  % (m["op"], m.get("name", ""), len(hw), len(words)))
            if args.dry_run:
                for w in words:
                    print("  %04X %04X %04X" % tuple(w))
                continue
            link.send_message(words, gap=args.gap)
            time.sleep(2.0)            # GMESTA takes it on its next pass
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
