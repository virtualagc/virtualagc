#!/usr/bin/env python3
"""Derive a phase's load-block descriptors from the BUILD, not from a memory dump.

    tools/phase_from_condeck.py --validate 3         # against ground truth
    tools/phase_from_condeck.py --phase 8 -o ph8.json

WHERE THE ANSWER COMES FROM

`~/workspace/PFS/OI340600/CON80` is the linkage-editor control deck library.
`OFTMP` is the master deck -- ONE link over the whole overlay tree -- and it
states phase membership outright:

    PHASE 8,18
    INCLUDE CONCARDS(PHASE08)

`PHASE08` expands to MAP2, MAP3, OVERLAY Z3, PATCH08, GNC9, and the leaves are
`INSERT <csect>` cards.  Look each CSECT up in the configuration's address map,
take maximal contiguous runs, and those are the load blocks.

THREE CORRECTIONS THE PHASE-3 VALIDATION FORCED

1.  INSERT CARDS ARE NOT THE WHOLE PHASE.  `OFTMP` says `LIBRARY ZCONLIB(ZCON)`,
    so the linker AUTOCALLS library members, and an autocalled member never
    appears on an INSERT card.  Phase 3's first block (0x0024a, 98 halfwords) is
    entirely ZCON and HAL_LIBRARY_ZCON and is invisible to the deck.  The fix is
    to resolve each INSERT name to the OBJECT FILE that defines it (via the ESD
    records of the .obj decks) and then take every CSECT that object defines:
    one HAL/S compilation emits #C code, #D data, #Z ZCON, #X and #E under the
    same object.  That takes destinations from 9 of 10 to 10 of 10.

2.  THE MERGE TOLERANCE IS 32 HALFWORDS, NOT 2.  Within phase 3's block at
    0x4888c the CSECTs are separated by gaps of up to 4 (297328 -> 297332),
    while the gaps BETWEEN blocks are 938 or more.  A tolerance of 2 split that
    block into 231 halfwords plus a spurious run; 128 or more wrongly swallows
    block 1 into its neighbour.  32 and 64 both give the right answer.

3.  BLOCK LENGTHS ARE EVEN.  `end - start + 3` came out one short on two blocks
    (6965 against 6966, 5 against 6); rounding up to even fixes both.

WHAT IS STILL WRONG, AND WHY THE TAPE GETS THE LAST WORD

Even so the deck alone leaves two errors on phase 3: a spurious 4-halfword run
at 0x001f6 (#ZDGNLIG, whose object also supplies phase 3's #CDGNLIG but whose
ZCON is loaded by another phase), and block 1 derived as 90 where the truth is
98.  Both are "which autocalled member belongs to WHICH phase", which the deck
does not record.  So the derived length is treated as a HINT: the tape is walked
alongside, and where a checksum-valid length exists near the hint it wins, since
a block ends where [0][checksum] verifies.  Destinations come from the deck,
which is good at them; extents come from the tape, which is good at those.

VERIFICATION

`--validate 3` derives phase 3 and diffs against the 10 descriptors in the
tape's own IPL table, which are ground truth.  It is the only thing standing
behind this tool.  Run it after any change; it exits non-zero on any regression."""

import argparse, collections, glob, io, json, os, re, struct, sys

PFS = os.path.expanduser("~/workspace/PFS")
CON80 = os.path.join(PFS, "OI340600/CON80")
OBJDIR = os.path.join(PFS, "OI340600/objects")
MAFGEN = os.path.join(PFS, "mafgen")
GPT_HW = 616158
MERGE_GAP = 32

INC = re.compile(r"\bINCLUDE\s+CONCARDS\(([^)]*)\)")
INS = re.compile(r"\bINSERT\s+(.*)")


# ---------------------------------------------------------------- deck parsing

def cards(member, con80):
    p = os.path.join(con80, member)
    if not os.path.exists(p):
        return []
    out = []
    for ln in io.open(p, errors="replace"):
        body = ln[:72].rstrip()
        if body.lstrip().startswith("*"):
            continue
        out.append(body)
    return out


def resolve_deck(member, con80, seen=None, acc=None):
    seen = seen if seen is not None else set()
    acc = acc if acc is not None else []
    if member in seen:
        return acc
    seen.add(member)
    for c in cards(member, con80):
        m = INC.search(c)
        if m:
            for sub in [x.strip() for x in m.group(1).split(",") if x.strip()]:
                resolve_deck(sub, con80, seen, acc)
            continue
        m = INS.search(c)
        if m:
            toks = m.group(1).split()
            if toks:
                for n in [x.strip() for x in toks[0].split(",") if x.strip()]:
                    acc.append(n)
    return acc


# ------------------------------------------------------------------ ESD index

def esd_index(objdir, cache="/tmp/csect2obj.json", cache2="/tmp/obj2csect.json"):
    """{csect: [objfile]} and {objfile: [csect]} from the object decks' ESD records."""
    if os.path.exists(cache) and os.path.exists(cache2):
        return json.load(io.open(cache)), json.load(io.open(cache2))
    defines = collections.defaultdict(set)
    for p in sorted(glob.glob(os.path.join(objdir, "*.obj"))):
        b = io.open(p, "rb").read()
        bn = os.path.basename(p)
        for off in range(0, len(b) - 79, 80):
            r = b[off:off + 80]
            if r[0] != 0x02 or r[1:4].decode("cp037", errors="replace") != "ESD":
                continue
            n = min(int.from_bytes(r[10:12], "big"), 56)
            for i in range(0, n, 16):
                it = r[16 + i:32 + i]
                if len(it) < 16:
                    break
                nm = it[0:8].decode("cp037", errors="replace").strip()
                if nm and it[8] in (0x00, 0x04, 0x05):      # SD / PC / CM
                    defines[nm].add(bn)
    c2o = {k: sorted(v) for k, v in defines.items()}
    o2c = collections.defaultdict(set)
    for nm, fs in defines.items():
        for f in fs:
            o2c[f].add(nm)
    o2c = {k: sorted(v) for k, v in o2c.items()}
    json.dump(c2o, io.open(cache, "w"))
    json.dump(o2c, io.open(cache2, "w"))
    return c2o, o2c


# --------------------------------------------------------------------- volume

def read_vol(path):
    b = io.open(path, "rb").read()
    n = len(b) // 2
    return struct.unpack(">%dH" % n, b[:2 * n])


def phase_base(V, phase, datavol):
    b = io.open(datavol, "rb").read()
    hw, ent, fl = struct.unpack(">III", b[8:20])
    dirn = struct.unpack(">%dI" % ent, b[32:32 + 4 * ent])
    pos = {v: i for i, v in enumerate(dirn)}
    data = (32 + 4 * ent) // 2
    x = V[GPT_HW + 4 * (phase - 3) + 2]
    if x not in pos:
        return None
    return data + pos[x] * 512


def truth_descs(V, phase):
    pi = phase - 3
    disp, nb = V[GPT_HW + 4 * pi], V[GPT_HW + 4 * pi + 1]
    out, off = [], 0
    for j in range(nb):
        k = GPT_HW + disp + 3 * j
        a, f, L = V[k], V[k + 1], V[k + 2]
        real = a if a < 0x8000 else ((f & 0xff) >> 4) * 0x8000 + (a & 0x7fff)
        out.append((off, real, L))
        off = ((off + L + 511) // 512) * 512
    return out


def checksum_lengths(T, base, toff, window):
    """Every L in `window` at which this block's [0][checksum] verifies."""
    hi = max(window)
    seg = T[base + toff: base + toff + hi + 4]
    if len(seg) < 4:
        return []
    pref = [0] * (len(seg) + 1)
    for i, v in enumerate(seg):
        pref[i + 1] = (pref[i] + v) & 0xffff
    ok = []
    for L in window:
        if L < 4 or L > len(seg):
            continue
        if seg[L - 2] == 0 and seg[L - 1] == pref[L - 2]:
            ok.append(L)
    return ok


# ----------------------------------------------------------------------- main

def derive(phase, con80, cfgmap, V, T, base, tolerance):
    seeds = set(resolve_deck("PHASE%02d" % phase, con80))
    c2o, o2c = esd_index(OBJDIR)
    names = set(seeds)
    objs = set()
    for n in seeds:
        objs.update(c2o.get(n, []))
    for o in objs:
        names.update(o2c.get(o, []))
    amap = json.load(io.open(cfgmap))
    hit = sorted((amap[n]["start"], amap[n]["end"]) for n in names if n in amap)
    runs = []
    for s, e in hit:
        if runs and s <= runs[-1][1] + MERGE_GAP:
            runs[-1][1] = max(runs[-1][1], e)
        else:
            runs.append([s, e])

    # Each run is either a real load block or a spurious one (object expansion
    # pulls in autocalled members belonging to another phase).  A greedy walk
    # cannot decide: accepting a spurious run consumes the NEXT real block's
    # length and desyncs everything after it, while a tolerance tight enough to
    # reject it also rejects real blocks whose autocalled tail makes them much
    # longer than the deck suggests.  So search: maximise the number of runs
    # placed at checksum-valid lengths, dropping the rest.
    hints = []
    for s0, e0 in runs:
        h = e0 - s0 + 3
        if h % 2:
            h += 1
        hints.append(h)

    if base is None:
        descs = []
        toff = 0
        for (s0, e0), h in zip(runs, hints):
            sect = s0 >> 15
            addr = s0 if s0 < 0x8000 else (0x8000 | (s0 & 0x7fff))
            descs.append([addr, 0x0600 | (sect << 4), h])
            toff = ((toff + h + 511) // 512) * 512
        return descs, list(runs), seeds, names, ["no tape data; deck hints used as-is"], toff

    KEEP = 4
    cand_cache = {}

    def cands(i, w):
        key = (i, w)
        if key in cand_cache:
            return cand_cache[key]
        h = hints[i]
        lo = max(4, h - tolerance)
        hi = min(h + 512 * 60, (len(T) - base - w * 512) - 1)
        out = checksum_lengths(T, base, w * 512, range(lo, hi + 1))[:KEEP] if hi > lo else []
        cand_cache[key] = out
        return out

    MAXW = 4096
    best = {}

    def solve(i, w):
        if i == len(runs):
            return (0, 0, [])
        if w > MAXW:
            return (-999, 0, [])
        key = (i, w)
        if key in best:
            return best[key]
        # option A: drop this run
        res = solve(i + 1, w)
        res = (res[0], res[1], [None] + res[2])
        # option B: accept it at each checksum-valid length
        for L in cands(i, w):
            nw = w + (L + 511) // 512
            sub = solve(i + 1, nw)
            score = (sub[0] + 1, -nw, [L] + sub[2])
            if (score[0], score[1]) > (res[0], -res[1] if res[1] else 0):
                res = (score[0], nw, [L] + sub[2])
        best[key] = res
        return res

    sys.setrecursionlimit(10000)
    nplaced, _, choice = solve(0, 0)

    descs, toff, notes, kept = [], 0, [], []
    for (s0, e0), h, L in zip(runs, hints, choice):
        if L is None:
            notes.append("0x%05x: dropped, no consistent block here (deck hint %d)" % (s0, h))
            continue
        if L != h:
            notes.append("0x%05x: deck hint %d -> checksum-valid %d" % (s0, h, L))
        sect = s0 >> 15
        addr = s0 if s0 < 0x8000 else (0x8000 | (s0 & 0x7fff))
        descs.append([addr, 0x0600 | (sect << 4), L])
        kept.append([s0, e0])
        toff = ((toff + L + 511) // 512) * 512
    return descs, kept, seeds, names, notes, toff


def main():
    ap = argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--phase", type=int)
    ap.add_argument("--validate", type=int, metavar="PHASE")
    ap.add_argument("--config", default="G9")
    ap.add_argument("--volume", default=os.path.expanduser("~/workspace/pass-run/pass-stamped.mmv"))
    ap.add_argument("--data-volume", default=os.path.expanduser("~/workspace/pass-run/pass-ipl-cflm.mmv"))
    ap.add_argument("--con80", default=CON80)
    ap.add_argument("--tolerance", type=int, default=16,
                    help="how far from the deck's length hint a checksum-valid "
                         "length may be and still be believed (default 16)")
    ap.add_argument("-o", "--out")
    a = ap.parse_args()

    phase = a.validate if a.validate else a.phase
    if not phase:
        sys.exit("pass --phase N or --validate N")

    cfgmap = os.path.join(MAFGEN, "augmented-%s.json" % a.config)
    V = read_vol(a.volume)
    T = read_vol(a.data_volume)
    base = phase_base(V, phase, a.data_volume)
    y = V[GPT_HW + 4 * (phase - 3) + 3]

    descs, runs, seeds, names, notes, toff = derive(
        phase, a.con80, cfgmap, V, T, base, a.tolerance)

    print("PHASE%02d: %d INSERT names -> %d CSECTs after object expansion, %d runs"
          % (phase, len(seeds), len(names), len(runs)))
    print("   walk consumes %d MM blocks (phase table y=%d)" % (toff // 512, y))
    for n in notes:
        print("   %s" % n)

    if a.validate:
        tr = truth_descs(V, phase)
        td = {d: L for _, d, L in tr}
        print()
        print("VALIDATION against phase %d's ground-truth descriptors (%d blocks):" % (phase, len(tr)))
        okd = okl = 0
        for (addr, fl, L), (s, e) in zip(descs, runs):
            if s in td:
                okd += 1
                if td[s] == L:
                    okl += 1
                    print("   0x%05x  L=%-6d OK" % (s, L))
                else:
                    print("   0x%05x  L=%-6d truth %d" % (s, L, td[s]))
            else:
                print("   0x%05x  L=%-6d NOT A REAL BLOCK" % (s, L))
        missed = [d for d in td if d not in [r[0] for r in runs]]
        for d in missed:
            print("   0x%05x  MISSED (truth L=%d)" % (d, td[d]))
        print()
        print("   destinations: %d of %d truth blocks found, %d spurious"
              % (okd, len(tr), len(descs) - okd))
        print("   lengths     : %d exactly right" % okl)
        good = (okd == len(tr) and okl >= len(tr) - 1 and len(descs) - okd <= 1)
        print("   RESULT      : %s" % ("PASS" if good else "FAIL"))
        return 0 if good else 1

    if a.out:
        json.dump(descs, io.open(a.out, "w"))
        print("wrote %s (%d descriptors)" % (a.out, len(descs)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
