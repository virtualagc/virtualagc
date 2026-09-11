#!/usr/bin/env python3
"""Fill the UNRESOLVED RELOCATIONS our per-phase links leave on a volume.

EXPERIMENTAL, AND A WORKAROUND FOR A BUILD DEFECT -- not a fix.  The real
repair is in the links (see HANDOFF-OPS9.md section 7b); this exists because
it is what makes OPS 201/301/801 and 901 keep polling the displays, and a
bootable volume is needed while the build is repaired.  It supersedes
patch_root_zcons.py, whose 18 Z-CONs are the first group below.

    patch_unresolved.py VOLUME [--out OUT] [--dry-run] [--group G ...]

WHAT IS BEING FILLED

Our per-phase links resolve only what is in the phase being linked, so every
reference that crosses a phase boundary is left as the assembler emitted it
-- 0000, an offset within the target section, or 8000 0E00 for a Z-CON --
and reaches the volume that way.  The real machine resolves them all; the
eight DASS dumps show the values.  The data file beside this script,
patch_unresolved.fills.json, lists each cell with the value our build has,
the value it should have, and the surrounding halfwords as our build lays
them out, which is how a copy is found.  Four groups, all measured on
OI340700-v36boot.mmv (ledger entries #56-#73):

  zcon      18 Z-CONs in the root, 0x1d6-0x243: calls into overlay-resident
            HAL/S procedures.  Unfilled, a SCAL through #ZDCDDG9 lands at
            0x648da ('invalid instruction 0xc6c6 at 0x48da').
  resident  six operands in resident FCOS I/O code -- BAL R7 to ADDRESS 0 in
            FIOSVCP, FIOCMPLT and FIOPDISP, and three in $0DGRGSE/#DDGRGSE.
            Unfilled, OPS 201 and OPS 301 stop ALL bus traffic seconds after
            drawing the new major mode's display: the POLL FAIL.
  phase8    45 operands in phase 8's copies of FIOPDSMU, FIOG9ADB and
            FIOPDG9, all references into the root's FIOCDATS.  Unfilled, OPS
            901 starts the MSC at ADDRESS 0 and the G9 MDM A/D BITE processor
            saves its caller's registers at address 0.

HOW A CELL IS FOUND, WITHOUT A PHASE TABLE

Every load block on these volumes starts on a 512-halfword boundary and ends
with its two-halfword checksum tail (0000, sum of the content mod 2**16),
followed by C6C6 padding up to the next boundary.  So the block holding a
cell is the nearest aligned start at or before it whose tail verifies AND is
followed by clean padding -- a test a random tail practically never passes.
A cell whose current value is neither the expected broken value nor the fill
is REFUSED rather than overwritten: that means a different build, and the
table does not apply to it.  Every touched block's checksum is restamped.
"""

import argparse
import json
import os
import re
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
FILLS = os.path.join(HERE, "patch_unresolved.fills.json")
PAD = 0xC6C6
MAX_LB = 16384


def load(path):
    raw = bytearray(open(path, "rb").read())
    if raw[:8] != b"MMUVOL01":
        sys.exit("%s is not an MMUVOL01 volume" % path)
    hw, ent, _ = struct.unpack(">III", raw[8:20])
    off = 32 + 4 * ent
    F = np.frombuffer(bytes(raw[off:off + 2 * ent * hw]), dtype=">u2").astype(np.int64)
    return raw, hw, off, F


def find_lb(F, P, hw, p):
    """(start, content) of the load block holding flat halfword p, or None."""
    b = (p // hw) * hw
    for S in range(b, max(-1, b - (MAX_LB // hw + 2) * hw), -hw):
        lo, hi = p + 1, min(S + MAX_LB, len(F) - 2)
        if lo > hi:
            continue
        e = np.arange(lo, hi + 1)
        ok = (F[e] == 0) & (((P[e] - P[S]) & 0xFFFF) == F[e + 1])
        for end in e[ok]:
            nxt = end + 2
            nb = ((nxt + hw - 1) // hw) * hw
            if np.all(F[nxt:nb] == PAD):
                return S, int(end - S)
    return None


MIN_ANCHOR = 6      # distinctive halfwords a context must keep after wildcarding


def pattern_for(f, addrs):
    """(compiled regex, number of distinctive halfwords) for one table entry.

    Neighbouring table cells are WILDCARDS: the Z-CONs and FIOPDSMU's operands
    sit in clusters, so once any are filled a literal context stops matching,
    which made a second run report every clustered cell as refused.  But a
    wildcard costs distinctiveness -- a Z-CON context inside the C6C6 hole
    collapsed to a few C6C6s plus wildcards, matched fill inside an UNRELATED
    load block, and wrote a Z-CON value there.  So what is left must still
    carry MIN_ANCHOR halfwords that are neither 0000 nor C6C6."""
    ctx, at = f["ctx"], f["at"]
    parts, anchor = [], 0
    for i, v in enumerate(ctx):
        if i == at:
            parts.append(b"..")
        elif (f["addr"] - at + i) in addrs:
            parts.append(b"..")
        else:
            parts.append(re.escape(struct.pack(">H", v)))
            if v not in (0, PAD):
                anchor += 1
    return re.compile(b"(?=" + b"".join(parts) + b")", re.DOTALL), anchor


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("volume")
    ap.add_argument("--out", help="write here instead of in place")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--group", action="append",
                    help="only these groups (zcon, resident, phase8)")
    ap.add_argument("--fills", default=FILLS)
    a = ap.parse_args()

    fills = json.load(open(a.fills))
    if a.group:
        fills = [f for f in fills if f["group"] in a.group]
    raw, hw, off, F = load(a.volume)
    F = F.copy()
    P = np.concatenate(([0], np.cumsum(F)))
    blob = F.astype(">u2").tobytes()

    # Neighbouring table cells inside a context are WILDCARDS: the Z-CONs and
    # FIOPDSMU's operands sit in clusters, so once any are filled, a literal
    # context no longer matches -- which made a second run report every
    # clustered cell as "refused".  Only the cell itself is then judged, by
    # its current value.
    addrs = {f["addr"] for f in fills}
    touched, n_fill, n_done, bad = {}, 0, 0, 0
    for f in fills:
        at = f["at"]
        pat, anchor = pattern_for(f, addrs)
        if anchor < MIN_ANCHOR:
            print("  %05x %-8s context too weak after wildcarding (%d anchors) -- refused"
                  % (f["addr"], f["group"], anchor))
            bad += 1
            continue
        found = 0
        for mt in pat.finditer(blob):
            if mt.start() % 2:
                continue
            p = mt.start() // 2 + at
            cur = int(F[p])
            if cur == f["fill"]:
                n_done += 1
                found += 1
                continue
            if cur != f["was"]:
                continue
            found += 1
            lb = find_lb(F, P, hw, p)
            if lb is None:
                print("  %05x %-8s no verifiable load block at flat %d -- refused"
                      % (f["addr"], f["group"], p))
                bad += 1
                continue
            touched.setdefault(lb, []).append((p, f))
        if not found:
            print("  %05x %-8s NOT FOUND -- a different build; not applied"
                  % (f["addr"], f["group"]))
            bad += 1
    for (S, L), cells in sorted(touched.items()):
        for p, f in cells:
            F[p] = f["fill"]
            n_fill += 1
            print("  %05x %-8s %04X -> %04X   block @%d len %d"
                  % (f["addr"], f["group"], f["was"], f["fill"], S, L))
        F[S + L + 1] = int(F[S:S + L].sum()) & 0xFFFF
    print("%d filled in %d load blocks, %d found already correct, %d refused"
          % (n_fill, len(touched), n_done, bad))
    if a.dry_run:
        print("(dry run, nothing written)")
        return 1 if bad else 0
    raw[off:off + 2 * len(F)] = F.astype(">u2").tobytes()
    out = a.out or a.volume
    open(out, "wb").write(bytes(raw))
    print("wrote %s" % out)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
