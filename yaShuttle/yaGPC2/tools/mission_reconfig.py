#!/usr/bin/env python3
"""A FLIGHT'S OWN I-LOADS ON A VOLUME: the mission reconfiguration that the
day-of-launch uplink cannot reach.

    tools/mission_reconfig.py SPEC.json VOLUME --mem MEM.bin --out OUT.mmv
                              [--dry-run]

SPEC.json: {"flight": "...", "cells": [{"name": "CGGS_V_MAG_MECO_NOM",
"config": "G16", "addr": "0f102", "E": 25819.0, "was": 25668.0}, ...]} --
addr in halfwords, as tools/pasvar.py prints it; the value as "E" (IBM short
float), "D" (long) or "H" (hex halfwords, a string); "was" the value the
volume is expected to hold, so that a different build is refused rather than
written over.

WHY.  Each flight flew its own software load: the generic OI release plus
the mission's I-loads (the "flight-specific reconfiguration").  Most of the
ascent's I-loads are in the GNC common block and the ground could still
change them on the day of launch (groundstation.py dolilu, GMESTA's OPS 9
cases); but some live only in the OPS 1 overlay -- the nominal MECO
targets among them (CGGC01: CGGS_V_MAG_MECO_NOM, _FPA_, _RAD_) -- where no
uplink reaches (DGM_WRT is not resident in G1).  Those have to be on the
volume the GPCs load OPS 1 from.

HOW A CELL IS FOUND.  The overlay is not in memory until OPS 1 is loaded,
and a volume has no symbol table, so --mem gives a memory image with the
configuration loaded (a capture's gpcN.mem.bin taken in OPS 1): the cell's
neighbours there -- eight halfwords either side -- are the context searched
for on the volume.  Every copy is changed (a volume may carry the overlay
more than once), each load block's checksum restamped (tools/
patch_unresolved.py's block finder: a block is the nearest 512-halfword
boundary before the cell whose two-halfword tail 0000,sum verifies and is
followed by C6C6 padding).
"""
import argparse
import json
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from patch_unresolved import load, find_lb   # noqa: E402

import numpy as np   # noqa: E402

CTX = 8


def ibm_short(x):
    if x == 0:
        return [0, 0]
    s = 0x80 if x < 0 else 0
    x, e = abs(x), 64
    while x >= 1:
        x /= 16
        e += 1
    while x < 1 / 16:
        x *= 16
        e -= 1
    m = int(round(x * 16 ** 6))
    if m >= 16 ** 6:
        m //= 16
        e += 1
    w = ((s | e) << 24) | m
    return [w >> 16, w & 0xFFFF]


def ibm_long(x):
    if x == 0:
        return [0, 0, 0, 0]
    s = 0x80 if x < 0 else 0
    x, e = abs(x), 64
    while x >= 1:
        x /= 16
        e += 1
    while x < 1 / 16:
        x *= 16
        e -= 1
    m = int(round(x * 16 ** 14))
    if m >= 16 ** 14:
        m //= 16
        e += 1
    w = ((s | e) << 56) | m
    return [(w >> (48 - 16 * i)) & 0xFFFF for i in range(4)]


def encode(cell, value):
    if "E" in cell:
        return ibm_short(float(value))
    if "D" in cell:
        return ibm_long(float(value))
    v = value if isinstance(value, str) else "%04X" % value
    return [int(v[i:i + 4], 16) for i in range(0, len(v), 4)]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("spec")
    ap.add_argument("volume")
    ap.add_argument("--mem", required=True, help="memory image with the configuration loaded")
    ap.add_argument("--out", required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    spec = json.load(open(a.spec))
    mem = np.frombuffer(open(a.mem, "rb").read(), dtype=">u2").astype(np.int64)
    raw, hw, off, F = load(a.volume)
    F = F.copy()
    P = np.concatenate(([0], np.cumsum(F)))
    blob = F.astype(">u2").tobytes()
    touched, bad = {}, 0
    for c in spec["cells"]:
        addr = int(c["addr"], 16)
        new = encode(c, c.get("E", c.get("D", c.get("H"))))
        was = encode(c, c["was"])
        n = len(new)
        here = [int(x) for x in mem[addr:addr + n]]
        if here != was:
            print("  %-26s memory image holds %s, not %s -- refused"
                  % (c["name"], " ".join("%04X" % x for x in here), " ".join("%04X" % x for x in was)))
            bad += 1
            continue
        # both sides first; then one side, then the other -- an overlay's
        # neighbours can be working variables the flight software has
        # changed since it was loaded.  The cell itself must hold "was".
        hits = []
        for lo, hi in ((CTX, CTX), (CTX, 0), (0, CTX), (2 * CTX, 0), (0, 2 * CTX)):
            ctx = [int(x) for x in mem[addr - lo:addr]] + was + [int(x) for x in mem[addr + n:addr + n + hi]]
            pat = re.compile(b"(?=" + b"".join(re.escape(struct.pack(">H", v)) for v in ctx) + b")", re.DOTALL)
            hits = [m.start() // 2 + lo for m in pat.finditer(blob) if m.start() % 2 == 0]
            if hits:
                if len(hits) > 1 and (lo == 0 or hi == 0):
                    # more than one: the copy that agrees best with the whole
                    # neighbourhood in memory (+/-256), if clearly the best --
                    # another configuration can share a few lines of layout
                    def agree(p):
                        return sum(int(F[p + k]) == int(mem[addr + k]) for k in range(-256, 256)
                                   if 0 <= p + k < len(F) and 0 <= addr + k < len(mem))
                    score = sorted(((agree(p), p) for p in hits), reverse=True)
                    if score[0][0] - score[1][0] >= 32:
                        print("  %-26s %d matches on a one-sided context; the copy agreeing on %d of 512"
                              " (next %d) is the configuration's" % (c["name"], len(hits), score[0][0], score[1][0]))
                        hits = [score[0][1]]
                    else:
                        print("  %-26s %d matches on a one-sided context, none clearly the one -- refused"
                              % (c["name"], len(hits)))
                        hits = []
                break
        if not hits:
            print("  %-26s NOT FOUND on the volume -- a different build; refused" % c["name"])
            bad += 1
            continue
        for p in hits:
            lb = find_lb(F, P, hw, p)
            if lb is None or p + n > lb[0] + lb[1]:
                print("  %-26s no verifiable load block at flat %d -- refused" % (c["name"], p))
                bad += 1
                continue
            touched.setdefault(lb, []).append((p, new, c["name"]))
    for (S, L), cells in sorted(touched.items()):
        for p, new, name in cells:
            print("  %-26s %s -> %s   block @%d len %d" % (
                name, " ".join("%04X" % int(F[p + i]) for i in range(len(new))),
                " ".join("%04X" % x for x in new), S, L))
            for i, x in enumerate(new):
                F[p + i] = x
        F[S + L + 1] = int(F[S:S + L].sum()) & 0xFFFF
    print("%d cell copies in %d load blocks; %d refused" %
          (sum(len(v) for v in touched.values()), len(touched), bad))
    if a.dry_run or bad:
        print("(nothing written)")
        return 1 if bad else 0
    raw[off:off + 2 * len(F)] = F.astype(">u2").tobytes()
    open(a.out, "wb").write(bytes(raw))
    print("wrote %s" % a.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
