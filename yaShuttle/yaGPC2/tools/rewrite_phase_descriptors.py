#!/usr/bin/env python3
"""Replace one phase's load-block descriptors in #PFCMGPT, IN PLACE.

    tools/rewrite_phase_descriptors.py VOL --phase 8 --descriptors D.json -o OUT
    tools/rewrite_phase_descriptors.py VOL --phase 8 --verify-identity

WHY IN PLACE, AND NOT IN THE FREE SPACE AT THE END

`#PFCMGPT` is `FCMMGPT` STRUCTURE(16) (four halfwords per phase, 64 total)
followed by `FCMMGPT_LOAD_BLKS ARRAY(1029)`, and `FCMGPT.hal` draws the
load-block area as laid out in phase order -- "PHASE 3 1ST LOAD BLOCK ...
PHASE 18 NTH LOAD BLOCK".  On this volume it is exactly that: contiguous from
offset 64, phases 3 through 18 in order, ending at 775.

Moving a phase's descriptors into the free space after 775 and pointing its
`disp` there DOES NOT WORK, even though `disp` is a plain offset and nothing in
the documented format forbids it.  Measured: with the ORIGINAL 27 phase-8
descriptors and the ORIGINAL `y`, moving `disp` from 313 to 775 and changing
nothing else makes the OPS 9 transition fail with no mass-memory read at all.
Three earlier tapes were built that way and all three failed for this reason
rather than for anything to do with their descriptor content.

WORSE: NO `disp` MAY CHANGE AT ALL.  Three tests, each on an otherwise
byte-identical copy of the known-good `pass-stamped.mmv`, with the enclosing
checksum repaired and verified every time:

    phase 8's disp 313 -> 775, phases 9-18 untouched        -> FAILS
    phases 8-18's disp all +3, descriptors identical        -> FAILS
    phases 9-18's disp +3, phase 8 left at 313              -> FAILS
    (baseline, nothing changed)                             -> works

The third is the one that matters, because it is exactly what GROWING phase 8
does to the layout: `disp` is the START of a phase's descriptors, so adding
descriptors leaves phase 8's own `disp` at 313 and moves only the phases after
it.  A raw diff confirms that tape carried nothing else: ten changed `disp`
fields, a clean +3 shift of the load-block region, phase 8's descriptors
untouched.  Phases 9, 10, 11, 12, 14, 15, 16 and 17 are not even in GNC OPS 9's
memory configuration (3, 8 and 18 are), and moving them still breaks it.

MECHANISM UNKNOWN.  `FCMMGBOV:186-196` reads `disp` as a plain index off the
`FIOMGPTZ` base -- `R4 = (phase-3)*4`, `R5 = table[R4]`, `TDBGPTIX = R5` -- with
nothing constraining its value, and start-up (`AIBGPCLO:895`) writes only
`FCMMGPT_STARTING_MM_ADD`, never `disp`.  Six modules reference `FIOMGPTZ`
(FCMMGBOV, FCMMGPOV, FCMUPLOD, FCMZCONS, FIOMGCV, FIOMGDSP) and only the first
two have been read.  Ruled out: the tail of the load-block area is genuinely all
zeros in the known-good tape, so zeroing it is a no-op; and the original
stamping touched only the GPT, #PCDCPHA and the two enclosing checksums, so
there is no fifth thing this tool is failing to update.

CONSEQUENCE: a phase's descriptor COUNT is frozen.  Its descriptors can be
rewritten in place -- addresses, flags and lengths -- but there must be exactly
as many as before, or a later phase's `disp` moves.  For phase 8 that means
exactly 27, and the tape's phase 8 does not appear to fit in 27: a checksum
walk finds 35 unambiguous blocks in just the first 87 of its 110 MM blocks.
The shifting logic below is therefore correct but currently unusable; it is
kept because the constraint is unexplained and may yet turn out to be
conditional.

TWO OTHER THINGS THAT MUST BE RIGHT, BOTH LEARNED THE HARD WAY

`y` (`NUM_CONT_MM_BLKS`) is not free.  `FCMMGPOV.asm:405-416` loads it into
`TIOSWDCD`, so it IS the I/O block count: the number of mass-memory blocks the
transfer fetches.  For phase 8, `y`=110 is known good and `y`=128 and `y`=250
are both rejected, so it is the phase's TAPE EXTENT and does not change when
the descriptors are re-carved out of that same extent.

**`y` is NOT sum(ceil(len/512)).**  That formula reproduces only 8 of the 16
phases on this volume — phase 3 has `y`=37 where the formula gives 38, phase 4
37 against 57, phase 15 90 against 115 — so whatever rule the ground build uses
is not that, and it is not known.  It happens to be right for phase 8, which is
exactly why an identity test on phase 8 alone does not catch it.  This tool
therefore PRESERVES `y` by default and only changes it if `--y` is given.

The GPT lives INSIDE a load block on the tape, so editing it breaks that
block's checksum.  Omitting the repair halts the machine at 115 s, BEFORE the
OPS request -- the signature of a broken SSL load, not a bad phase table.  This
tool finds the enclosing block from the tape's own IPL phase table and repairs
it, then verifies.

VERIFICATION

`--verify-identity` rebuilds the area from the descriptors already present and
requires the result to be byte-identical to the input.  That exercises the
whole path -- parse, re-lay-out, preserve `y`, repair the checksum -- against
a known answer, and it is the first thing to run after touching this file."""

import argparse, io, json, struct, sys

GPT_HW = 616158          # #PFCMGPT on this volume, halfword offset
GPT_SIZE = 1093          # STRUCTURE(16)*4 + ARRAY(1029)
DESC_BASE = 64           # first load-block halfword, after the 16 descriptors
LB_CAPACITY = 1029
ENCLOSING = (615304, 8410)   # phase 2's block 18, from the tape's IPL table


def read_vol(path):
    b = io.open(path, "rb").read()
    n = len(b) // 2
    return list(struct.unpack(">%dH" % n, b[:2 * n])), len(b)


def write_vol(path, V, nbytes):
    out = b"".join(struct.pack(">H", v) for v in V)
    assert len(out) == nbytes, "volume size changed: %d != %d" % (len(out), nbytes)
    io.open(path, "wb").write(out)


def phases(V):
    """{phase: (disp, nblks, x, y)}"""
    return {ph: tuple(V[GPT_HW + 4 * (ph - 3) + k] for k in range(4))
            for ph in range(3, 19)}


def descriptors(V, disp, nblks):
    return [tuple(V[GPT_HW + disp + 3 * j + k] for k in range(3))
            for j in range(nblks)]


def mm_blocks(descs):
    """MM blocks a descriptor list consumes: each block starts on a boundary."""
    return sum((L + 511) // 512 for _, _, L in descs)


def rebuild(V, phase, new_descs, new_y=None):
    ph = phases(V)
    lists = {p: descriptors(V, ph[p][0], ph[p][1]) for p in range(3, 19)}
    if new_descs is not None:
        lists[phase] = new_descs

    need = sum(3 * len(lists[p]) for p in range(3, 19))
    if need > LB_CAPACITY:
        sys.exit("descriptors need %d halfwords, FCMMGPT_LOAD_BLKS holds %d"
                 % (need, LB_CAPACITY))

    off = DESC_BASE
    for p in range(3, 19):
        d = GPT_HW + 4 * (p - 3)
        V[d] = off                      # disp
        V[d + 1] = len(lists[p])        # nblks
        if p == phase and new_y is not None:
            V[d + 3] = new_y                 # y: only on an explicit request
        for j, (a, f, L) in enumerate(lists[p]):
            k = GPT_HW + off + 3 * j
            V[k], V[k + 1], V[k + 2] = a, f, L
        off += 3 * len(lists[p])
    for i in range(off, GPT_SIZE):       # tail of the load-block area
        V[GPT_HW + i] = 0
    return off


def repair_enclosing(V):
    t, L = ENCLOSING
    V[t + L - 2] = 0
    V[t + L - 1] = sum(V[t:t + L - 2]) & 0xffff
    return V[t + L - 1]


def check_enclosing(V):
    t, L = ENCLOSING
    return V[t + L - 2] == 0 and V[t + L - 1] == (sum(V[t:t + L - 2]) & 0xffff)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("volume")
    ap.add_argument("--phase", type=int, required=True)
    ap.add_argument("--descriptors",
                    help="JSON list of [addr, flags, length] triples")
    ap.add_argument("--y", type=int,
                    help="set NUM_CONT_MM_BLKS; omitted, it is PRESERVED.  It "
                         "is the phase's tape extent, not a function of the "
                         "descriptors -- see the module docstring")
    ap.add_argument("--verify-identity", action="store_true",
                    help="rebuild from what is already there; require the "
                         "output to be byte-identical to the input")
    ap.add_argument("-o", "--out")
    a = ap.parse_args()

    V, nbytes = read_vol(a.volume)
    before = list(V)
    ph0 = phases(V)

    if not check_enclosing(V):
        sys.exit("input volume's enclosing load block %s does not verify; "
                 "refusing to build on it" % (ENCLOSING,))

    new = None
    if a.descriptors:
        raw = json.load(io.open(a.descriptors))
        new = [tuple(int(x) for x in row) for row in raw]
        for aa, ff, LL in new:
            if not (0 <= aa <= 0xffff and 0 <= ff <= 0xffff and 4 <= LL):
                sys.exit("descriptor out of range: %r" % ((aa, ff, LL),))

    end = rebuild(V, a.phase, new, a.y)
    repair_enclosing(V)

    if a.verify_identity:
        if V == before:
            print("IDENTITY OK: rebuild reproduced the volume byte for byte")
            return 0
        diff = [i for i in range(len(V)) if V[i] != before[i]]
        print("IDENTITY FAILED: %d halfwords differ, first at %d"
              % (len(diff), diff[0] if diff else -1))
        for i in diff[:12]:
            print("   hw %7d  %04x -> %04x" % (i, before[i], V[i]))
        return 1

    ph1 = phases(V)
    print("phase %d: %d -> %d descriptors, y %d -> %d"
          % (a.phase, ph0[a.phase][1], ph1[a.phase][1],
             ph0[a.phase][3], ph1[a.phase][3]))
    moved = [p for p in range(3, 19) if ph0[p][0] != ph1[p][0]]
    for p in moved:
        print("   phase %2d disp %4d -> %4d" % (p, ph0[p][0], ph1[p][0]))
    print("load-block area now ends at %d of %d" % (end, GPT_SIZE))
    print("enclosing block %s: %s" % (ENCLOSING,
                                      "OK" if check_enclosing(V) else "BROKEN"))
    if not a.out:
        sys.exit("nothing written: pass -o OUT")
    write_vol(a.out, V, nbytes)
    print("wrote %s" % a.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
