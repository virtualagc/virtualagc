#!/usr/bin/env python3
"""THE FLOWN FLIGHT'S I-LOADS, ALL OF THEM, ON A VOLUME AND IN A CAPTURE.

    tools/flown_iloads.py --config G2 --config G3 --volume IN.mmv --out OUT.mmv [--dry-run]
    tools/flown_iloads.py --config G2 --capture DIR [--tape OUT.mmv] [--dry-run]

WHAT.  ~/workspace/PFS/mafgen/pure-<cfg>.fcm is STS-134's own build of one memory configuration (DASS GNC2 / GNC3 /
...: the real flight's load) and <cfg>.fcm is the generic one the source gives.  Both are as-built dumps, nothing
has run in them, so every halfword in which they differ is the flight's own: an I-load, a table, a display vector.
G3 differs in 7,645 halfwords, G2 in 2,981, G16 in 7,845.  tools/mission_reconfig.py has been patching these a
few cells at a time from tools/sites/*.json (about 1,350 of G3's); this applies the rest.

WHICH.  Compool data only: csects '#PC*' (and not the landing-site table '#PCGN13R' -- tools/landing_sites.py makes
those, one site at a time -- nor the mass-memory load-block table '#PFCMGPT').  The '#DG*' csects and everything
else (code, the FCOS) are left alone; --include/--exclude change that.

HOW, ON A VOLUME.  Neighbouring differing cells are merged into runs.  A run is found on the volume by its generic
neighbourhood (12 halfwords either side, the other differing cells wildcarded, so a run next to an already patched
cell still matches), must lie in a load block whose checksum verifies, and its cells must hold the generic value
(or already the flown one).  Anything else is refused and counted, never written.  Each touched block is
re-stamped.  Where two configurations share a block and disagree about a cell the first one wins and the clash is
printed.

HOW, IN A CAPTURE.  The same cells by memory address: a cell is set to the flown value if the capture holds the
generic value or the flown one; any other value means the flight software changed it since it was loaded, so it
is left and counted.  With --tape the capture's recorded volume digest is updated to that volume's, so that
simulatePASS restores it: the patched memory is then what a load from the patched volume would have produced.
"""
import argparse
import fnmatch
import hashlib
import json
import os
import re
import struct
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from patch_unresolved import load, find_lb   # noqa: E402

MAFGEN = os.path.expanduser("~/workspace/PFS/mafgen/")
CTX = 12
MIN_ANCHOR = 6
GAP = 3


def dumps(cfg):
    a = np.frombuffer(open(MAFGEN + cfg + ".fcm", "rb").read(), dtype=">u2").astype(np.int64)
    b = np.frombuffer(open(MAFGEN + "pure-" + cfg + ".fcm", "rb").read(), dtype=">u2").astype(np.int64)
    return a, b, json.load(open(MAFGEN + "csects-%s.json" % cfg))


# CELLS THE FLOWN DUMP HOLDS BUT A FLIGHT'S LOAD MUST NOT SET HERE, each found by a run that failed:
#   CGGB_EF_PLANE_SW      the dump's OFF makes guidance take the orbit plane from CGGS_T_GMTLO_REF, which the dump
#                         holds as a placeholder (day 210); the day-of-launch uplink supplies the real plane.  Applied,
#                         the ascent dives (run flown1) -- left generic (ON) it flies normally (bisect T1).
#   CDUV_NSP_VEHICLE_ILOAD  2 -> 5, a downlink header word.  Applied, the OMS-2 burn never fires, cause not understood
#                         (bisect K1; every run that held it failed, every one that did not, burned).
#   CGNS_T_GPS_OFFSET_SECS  504403200 -> 946252800, the GPS-seconds origin PASS subtracts to turn a receiver's time into GMT
#                         (GPBGPS.hal:926-932).  mdmdev.c's receivers send GPS_OFFSET_S (504403200 + 11), so with the flown
#                         value PASS reads every fix as 14 years off, fails the 0.48 s time-tag test and takes no GPS at all:
#                         navigation then runs on the last fix plus the IMU, arrives at TAEM 6-9 kft low in altitude and dives
#                         (the entry captures that crashed, ledger "stale GPS entry").  Probe: the shared tig1 with only this
#                         cell put back keeps GPS live.  Left generic here; YAGPC_GPS_T_OFFSET_SECS makes the receivers match
#                         a memory that already carries the flown value.
NEVER_SET = ("CGGB_EF_PLANE_SW", "CDUV_NSP_VEHICLE_ILOAD", "CGNS_T_GPS_OFFSET_SECS")


def cells(cfg, include, exclude):
    """[(start, generic words, flown words, csect)] -- runs of differing halfwords inside the chosen csects."""
    a, b, cs = dumps(cfg)
    n = min(len(a), len(b))
    ranges = sorted((v["start"], v["end"], k) for k, v in cs.items())
    keep = np.zeros(n, dtype=bool)
    name = [None] * n
    for s, e, k in ranges:
        if any(fnmatch.fnmatch(k, p) for p in exclude) or not any(fnmatch.fnmatch(k, p) for p in include):
            continue
        keep[s:min(e, n - 1) + 1] = True
        for i in range(s, min(e, n - 1) + 1):
            name[i] = k
    diff = np.nonzero((a[:n] != b[:n]) & keep)[0]
    runs, cur = [], None
    for i in diff:
        i = int(i)
        if cur and i - cur[1] <= GAP and name[i] == cur[2]:
            cur[1] = i
        else:
            if cur:
                runs.append(cur)
            cur = [i, i, name[i]]
    if cur:
        runs.append(cur)
    out = []
    nm = None
    for s, e, k in runs:
        was, new = a[s:e + 1].copy(), b[s:e + 1].copy()
        if k.startswith("#P"):
            if nm is None:
                nm = var_resolver(MAFGEN + "pure-" + cfg + ".fcm", cfg, None)
            for i in range(len(new)):
                if was[i] != new[i] and nm(s + i, k) in NEVER_SET:
                    new[i] = was[i]
        if any(was[i] != new[i] for i in range(len(new))):
            out.append((s, was, new, k))
    return out, a, b


def digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def patch_volume(args, cfgs, include, exclude):
    raw, hw, off, F = load(args.volume)
    F = F.copy()
    P = np.concatenate(([0], np.cumsum(F)))
    blob = F.astype(">u2").tobytes()
    touched, owner = {}, {}
    total = refused = already = 0
    reasons = {}

    def why(k):
        reasons[k] = reasons.get(k, 0) + 1

    for cfg in cfgs:
        runs, a, b = cells(cfg, include, exclude)
        diffset = set(int(i) for i in np.nonzero(a[:len(b)] != b[:len(a)])[0])
        # pass 1: runs the volume holds in exactly one place fix the offset between a memory address and a flat
        # position there (it is constant inside one load block's worth of a csect image)
        anchors, hits_of = [], {}
        for s, was, new, csect in runs:
            n = len(was)
            ctx, anchor = [], 0
            lo = max(0, s - CTX)
            for i in range(lo, s + n + CTX):
                if i >= len(a):
                    break
                if s <= i < s + n or i in diffset:
                    ctx.append(b"..")
                else:
                    ctx.append(re.escape(struct.pack(">H", int(a[i]))))
                    if int(a[i]) not in (0, 0xC6C6):
                        anchor += 1
            hits = []
            if anchor >= MIN_ANCHOR:
                pat = re.compile(b"(?=" + b"".join(ctx) + b")", re.DOTALL)
                hits = [m.start() // 2 + (s - lo) for m in pat.finditer(blob) if m.start() % 2 == 0]
            hits_of[s] = hits
            if len(hits) == 1:
                anchors.append((s, hits[0] - s))
        # windows all over the image fix the offset where the differing cells alone are too few
        for w0 in range(0, len(a) - 24, 96):
            win = a[w0:w0 + 24]
            if sum(1 for v in win if int(v) not in (0, 0xC6C6)) < 14 or any((w0 + k) in diffset for k in range(24)):
                continue
            pat = re.compile(b"(?=" + b"".join(re.escape(struct.pack(">H", int(v))) for v in win) + b")", re.DOTALL)
            hh = [m.start() // 2 for m in pat.finditer(blob) if m.start() % 2 == 0]
            if len(hh) == 1:
                anchors.append((w0, hh[0] - w0))
        anchors.sort()
        astart = [x[0] for x in anchors]
        import bisect
        for s, was, new, csect in runs:
            total += 1
            n = len(was)
            cand = []
            if len(hits_of[s]) == 1:
                cand.append(hits_of[s][0] - s)
            j = bisect.bisect_left(astart, s)
            near = sorted(anchors[max(0, j - 8):j + 8], key=lambda t: abs(t[0] - s))
            for t in near:
                if t[1] not in cand:
                    cand.append(t[1])
            placed = []
            for d in cand[:10]:
                p = s + d
                if p < 0 or p + n > len(F):
                    continue
                here = [int(x) for x in F[p:p + n]]
                if not (all(here[i] == int(was[i]) for i in range(n)) or all(here[i] == int(new[i]) for i in range(n))):
                    continue
                # the generic neighbourhood must be there too (the cells that differ aside)
                tot = good = 0
                for k in range(-8, n + 8):
                    if 0 <= s + k < len(a) and 0 <= p + k < len(F) and (s + k) not in diffset and not (0 <= k < n):
                        tot += 1
                        good += int(F[p + k]) == int(a[s + k])
                if tot and good < 0.75 * tot:
                    continue
                lb = find_lb(F, P, hw, p)
                if lb is None or p + n > lb[0] + lb[1]:
                    continue
                placed.append((p, lb))
                break
            if hits_of[s] and len(hits_of[s]) > 1:
                # several matches of its own context: take every one that checks out (a table's entries repeat)
                pass
            if not placed:
                refused += 1
                why("no consistent place" if cand else "no anchor near")
                if getattr(args, "verbose", False):
                    print("  refused %s %s at %#x (%d cells) own hits %d, candidates %d" % (cfg, csect, s, n, len(hits_of[s]), len(cand)))
                continue
            for p, lb in placed:
                prev = owner.get(p)
                if prev and prev[1] != [int(x) for x in new]:
                    print("  clash at flat %d: %s wants %s, %s set %s" % (p, cfg, [int(x) for x in new], prev[0], prev[1]))
                    continue
                if all(int(F[p + i]) == int(new[i]) for i in range(n)):
                    already += 1
                    continue
                owner[p] = (cfg, [int(x) for x in new])
                touched.setdefault(lb, []).append((p, new))
    ncopies = 0
    for (S, L), lst in sorted(touched.items()):
        for p, new in lst:
            for i, x in enumerate(new):
                F[p + i] = int(x)
            ncopies += 1
        F[S + L + 1] = int(F[S:S + L].sum()) & 0xFFFF
    print("%d runs asked; %d written in %d load blocks; %d already flown; %d refused %s" %
          (total, ncopies, len(touched), already, refused, reasons))
    if args.dry_run:
        print("(dry run: nothing written)")
        return None
    raw[off:off + 2 * len(F)] = F.astype(">u2").tobytes()
    open(args.out, "wb").write(bytes(raw))
    print("wrote", args.out)
    return args.out


def var_resolver(capture_mem, cfg, csect_ranges):
    """addr -> variable name, from tools/pasvar.py's compool listings (cached per csect)."""
    import subprocess
    import bisect
    cache = {}

    def listing(comp):
        if comp in cache:
            return cache[comp]
        o = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "pasvar.py"),
                            capture_mem, "--list-compool", comp, "--config", cfg],
                           capture_output=True, text=True).stdout
        L = []
        for l in o.splitlines():
            m = re.match(r"\s+(\d+)\s+@([0-9a-f]+)\s+(\d+) hw\s+(\S+)", l)
            if m:
                L.append((int(m[2], 16), m[4]))
        L.sort()
        cache[comp] = (L, [x[0] for x in L])
        return cache[comp]

    def name(addr, csect):
        if not csect.startswith("#P"):
            return ""
        L, st = listing(csect[2:])
        j = bisect.bisect_right(st, addr) - 1
        return L[j][1] if j >= 0 else ""
    return name


def patch_capture(args, cfgs, include, exclude):
    revert = getattr(args, "revert", False)
    varpats = getattr(args, "var", None)
    novar = getattr(args, "novar", None)
    memfiles = sorted(f for f in os.listdir(args.capture) if re.match(r"gpc\d+\.mem\.bin$", f))
    for mf in memfiles:
        path = os.path.join(args.capture, mf)
        mem = bytearray(open(path, "rb").read())
        M = np.frombuffer(bytes(mem), dtype=">u2").astype(np.int64)
        setn = skip = same = 0
        for cfg in cfgs:
            runs, a, b = cells(cfg, include, exclude)
            vname = var_resolver(path, cfg, None) if (varpats or novar) else None
            for s, was, new, csect in runs:
                for i in range(len(was)):
                    if int(was[i]) == int(new[i]):
                        continue
                    if varpats or novar:
                        nm = vname(s + i, csect)
                        if varpats and not any(fnmatch.fnmatch(nm, p) for p in varpats):
                            continue
                        if novar and any(fnmatch.fnmatch(nm, p) for p in novar):
                            continue
                    v = int(M[s + i])
                    if revert:
                        if v == int(new[i]):
                            M[s + i] = int(was[i])
                            setn += 1
                        elif v == int(was[i]):
                            same += 1
                        else:
                            skip += 1
                    elif v == int(new[i]):
                        same += 1
                    elif v == int(was[i]):
                        M[s + i] = int(new[i])
                        setn += 1
                    else:
                        skip += 1
        print("%s: %d cells set, %d already flown, %d left (changed at run time)" % (mf, setn, same, skip))
        if not args.dry_run:
            open(path, "wb").write(M.astype(">u2").tobytes())
    if args.tape and not args.dry_run:
        vj = os.path.join(args.capture, "vehicle.json")
        v = json.load(open(vj))
        v["tapeSha256"] = digest(args.tape)
        v["tape"] = args.tape
        json.dump(v, open(vj, "w"), indent=1)
        print("recorded volume", args.tape)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--config", action="append", required=True)
    ap.add_argument("--volume")
    ap.add_argument("--out")
    ap.add_argument("--capture")
    ap.add_argument("--tape")
    ap.add_argument("--include", action="append", default=None)
    ap.add_argument("--exclude", action="append", default=None)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--var", action="append", help="with --capture: only cells of variables matching these patterns")
    ap.add_argument("--novar", action="append", help="with --capture: skip cells of variables matching these patterns (CGGB_EF_PLANE_SW is the first: see the ledger)")
    ap.add_argument("--revert", action="store_true", help="with --capture: put the GENERIC value back (bisecting which csects matter)")
    a = ap.parse_args()
    include = a.include or ["#PC*"]
    exclude = a.exclude if a.exclude is not None else ["#PCGN13R", "#PFCMGPT"]
    if a.volume:
        if not a.out and not a.dry_run:
            ap.error("--out")
        patch_volume(a, a.config, include, exclude)
    if a.capture:
        patch_capture(a, a.config, include, exclude)


if __name__ == "__main__":
    main()
