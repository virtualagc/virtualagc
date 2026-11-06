#!/usr/bin/env python3
"""ONE VOLUME FROM SEVERAL: the union of what each volume changed from a common base.

    tools/merge_volumes.py BASE.mmv SRC1.mmv [SRC2.mmv ...] --out OUT.mmv [--dry-run]

Every source was made from BASE by patching I-loads (tools/mission_reconfig.py, tools/flown_iloads.py), so the
set of halfwords a source changed is what that source ADDS.  A real flight had ONE volume holding every flight
phase's loads; ours grew one per phase.  This puts the additions of all the sources on one copy of BASE.

A changed halfword is DATA if the source's load block around it verifies (tools/patch_unresolved.find_lb), and a
load block's own checksum word otherwise.  Data changes are unioned; two sources that set the same halfword to
different values are a CLASH, listed and (unless --first-wins, which lets the first listed source decide) fatal.
A source that merely left the base value did not touch the halfword, so a cell one source deliberately dropped from an
older build (flown -> flown2 dropped CGGB_EF_PLANE_SW) must be handled by not listing the older tape.  Every load block holding a data change is
then re-stamped from the merged contents, which is the only thing that happens to the checksum words.
"""
import argparse
import os
import struct
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from patch_unresolved import load, find_lb   # noqa: E402


def prefix(F):
    return np.concatenate(([0], np.cumsum(F)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("base")
    ap.add_argument("sources", nargs="+")
    ap.add_argument("--out", required=True)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--first-wins", action="store_true",
                    help="on a clash the FIRST listed source decides (list the newest build first)")
    a = ap.parse_args()
    raw, hw, off, F0 = load(a.base)
    P0 = prefix(F0)
    srcs = []
    for path in a.sources:
        _, hw2, off2, F = load(path)
        if len(F) != len(F0) or hw2 != hw:
            sys.exit("%s is not the same shape as the base" % path)
        srcs.append((os.path.basename(path), F, prefix(F)))
    # data positions each source changed
    union, blocks = {}, {}
    for name, F, P in srcs:
        diff = np.nonzero(F != F0)[0]
        data = nck = 0
        for p in diff.tolist():
            lb = find_lb(F, P, hw, p)
            if lb is None:
                nck += 1                       # a block's checksum word, restamped below
                continue
            data += 1
            blocks[lb[0]] = lb[1]
            union[p] = True
        print("%-44s changes %6d  data %6d  checksum words %4d" % (name, len(diff), data, nck))
    merged = F0.copy()
    clashes = []
    for p in sorted(union):
        # only a source that CHANGED the halfword speaks for it: one that left the base value just did not touch it
        vals = [(name, int(F[p])) for name, F, _ in srcs if F[p] != F0[p]]
        if len({v for _, v in vals}) > 1:
            clashes.append((p, vals, int(F0[p])))
        merged[p] = vals[0][1]                 # the first listed source wins a clash
    print("clashes (sources disagree on a halfword):", len(clashes))
    for p, vals, b0 in clashes[:40]:
        print("  halfword %d (block %d +%d) base=%04x  %s" % (p, p // 512, p % 512, b0,
              "  ".join("%s=%04x" % (n[:14], v) for n, v in vals)))
    if clashes and not a.first_wins:
        sys.exit("clashes: not writing; list the winning source FIRST and pass --first-wins")
    P = prefix(merged)
    bad = 0
    for S, n in sorted(blocks.items()):
        end = S + n
        if merged[end] != 0:
            bad += 1
            continue
        merged[end + 1] = (P[end] - P[S]) & 0xFFFF
    print("blocks restamped:", len(blocks), " malformed:", bad)
    Pm = prefix(merged)
    vbad = sum(1 for S, n in blocks.items() if find_lb(merged, Pm, hw, S + 1) is None)
    print("blocks that fail find_lb after the merge:", vbad)
    if a.dry_run:
        return
    out = bytearray(raw)
    out[off:off + 2 * len(merged)] = merged.astype(">u2").tobytes()
    with open(a.out, "wb") as fh:
        fh.write(out)
    print("wrote", a.out)


if __name__ == "__main__":
    main()
