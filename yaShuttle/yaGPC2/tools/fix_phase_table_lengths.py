#!/usr/bin/env python3
"""Correct a generated #PFCMGPT's load-block lengths against the tape.

    tools/fix_phase_table_lengths.py <gpt.bin> <volume.mmv> [--phase N] [-o OUT]

`ap101Utils.mmbstamp` reconstructs the ground Mass Memory Build's load-block
layout from the phase libraries and the CON80 cards.  The reconstruction is
heuristic in places -- `_extend_mc_bank_tails` and `_open_bank_tails` both
reshape a block's length from rules inferred about the MMB -- and it does not
always agree with the volume the blocks will actually be read from.  Measured
on OI340600 phase 3: seven of ten lengths are right, block 4 is 16 halfwords
too long, block 9 is 38 too short, and block 10 does not checksum at any
length.

A wrong length is not a cosmetic error.  The flight software reads the block,
sums it, compares against the tail, rejects it, re-reads the identical blocks
and gives up -- leaving the overlay PARTIALLY applied, which for a phase whose
first blocks land in PSA/CVT space means a corrupted FCOS and a machine that
takes an unwakeable masked wait shortly afterwards.

The tape itself is the authority, and it can be read directly: a load block is

    [content (L-2 halfwords)] [0] [checksum]     checksum == sum(content)

so for a known start there is essentially one length that verifies.  This
walks each phase's blocks from its mass-memory address, block-aligned, takes
the length the tape actually agrees with, and writes it back into the table.

Blocks that verify at no length are REPORTED, NOT INVENTED: that is a tape
content problem, not a table problem, and silently choosing a length would
turn a detectable fault into an undetectable one."""

import argparse, io, struct, sys

HW_PER_BLOCK = 512
GPT_SIZE = 1093
MIN_LB_HW = 8          # below this, a "match" is noise: 4 content halfwords
                       # summing to the tail happens by chance far too often


def hw_list(b):
    return list(struct.unpack(">%dH" % (len(b) // 2), b[:len(b) // 2 * 2]))


def block_of(mm):
    """CON80 ADDR=FTSBB packing: mm16 = F<<11 | T<<8 | S<<5 | BB."""
    return (mm >> 11), ((mm >> 8) & 7), ((mm >> 5) & 7), (mm & 31)


def checksums(w, s, L):
    return (0 < L and s + L <= len(w)
            and w[s + L - 2] == 0
            and (sum(w[s:s + L - 2]) & 0xffff) == w[s + L - 1])


def followed_by_fill(w, s, L, base):
    """A real load block is followed by C6C6 fill to the next 512 boundary.

    Without this the blind search is worthless whenever the generated length
    is far wrong: some short prefix almost always sums to whatever halfword
    follows it, so the first verifying length is spurious, the walk drifts,
    and every later block is nonsense.  Measured on OI340600 phase 8, the
    unguarded search "corrected" 19 of 27 lengths to values like 8, 13 and 14
    and cut NUM_CONT from 110 to 57.  A block that is not followed by fill has
    not been found; it has been guessed."""
    # Boundaries are RELATIVE to the phase's own base.  A phase does not
    # start on a 512-halfword boundary of the volume -- phase 3 begins at
    # 158088, which is 392 into a block -- so computing them absolutely
    # checks the wrong range.  Third time this session that an absolute/
    # relative alignment mix-up produced confident wrong output.
    end = s + L
    rel = end - base
    bnd = base + ((rel + HW_PER_BLOCK - 1) // HW_PER_BLOCK) * HW_PER_BLOCK
    if end == bnd:                     # ends exactly on the boundary
        return True
    return all(w[i] == 0xc6c6 for i in range(end, min(bnd, len(w))))


def true_length(w, s, want, base, span=12000):
    """The length the tape agrees with at s, preferring the generated one.

    MIN_LB_HW guards only the BLIND SEARCH.  The generated length is checked
    first and without it: phase 3's block 7 really is 6 halfwords, and a
    minimum that rejects a genuine short block is as wrong as one that
    accepts noise.  `span` has to be generous for the same reason in the
    other direction -- block 10 is 5654 halfwords, and a search bound of
    5632 reports "no length verifies" for a block that is simply longer
    than the window."""
    if checksums(w, s, want):
        return want
    cands = [L for L in range(MIN_LB_HW, min(span, len(w) - s))
             if checksums(w, s, L) and followed_by_fill(w, s, L, base)]
    if len(cands) == 1:
        return cands[0]
    return None                        # none, or ambiguous: do not guess


# CZ2COMMO's own initialiser for CZ2B_GRT_GPC_SET: ten halfwords, distinctive
# enough to locate the LIVE compool in an image by content alone.  Its offset
# inside #PCZ2COM is 776.
GRT_SIG = (0xf000, 0xc000, 0xf000, 0x1400, 0x1400,
           0x4400, 0x8400, 0xc000, 0xf000, 0x0000)
GRT_OFF = 776
CZ2_SIZE = 1514


def live_compool(img):
    """Where #PCZ2COM actually IS in a running image, by content.

    The link maps are not authority here: every PHASEnn map places #PCZ2COM at
    0x14ac, and in the image measured for this check that address holds C6C6 --
    never loaded -- while the compool PASS actually reads is at 0x23f4.  A load
    block whose destination was computed against the map therefore lands in the
    middle of live compool data, and phase 3's block 3 does exactly that:
    0x2662..0x2bab covers CZ2B_GRT_GPC_SET (0x26fc) and CZ2V_GRT_TAB (0x28ad),
    so applying that overlay zeroes the GPC reconfiguration table the OPS
    transition is in the middle of using.  The machine then halts, and nothing
    in the trace says why -- which is why this check exists."""
    for i in range(len(img) - len(GRT_SIG)):
        if tuple(img[i:i + len(GRT_SIG)]) == GRT_SIG:
            return i - GRT_OFF
    return None


def check_destinations(G, img):
    """Report load blocks whose destination overlaps the live compool."""
    base = live_compool(img)
    if base is None:
        print("\ncompool not located in the image; destination check skipped")
        return 0
    lo, hi = base, base + CZ2_SIZE
    print("\nDESTINATION CHECK -- live #PCZ2COM at 0x%05x..0x%05x" % (lo, hi - 1))
    bad = 0
    for p in range(3, 19):
        d = 4 * (p - 3)
        disp, nblks = G[d], G[d + 1]
        for i in range(nblks):
            k = disp + 3 * i
            addr, flags, L = G[k], G[k + 1], G[k + 2]
            sector = (flags >> 4) & 0xf
            start = sector * 0x8000 + (addr & 0x7fff)
            if start < hi and start + L > lo:
                print("  phase %d block %2d -> 0x%05x..0x%05x OVERLAPS the live "
                      "compool" % (p, i + 1, start, start + L - 1))
                print("     applying it destroys data PASS is using; the table's "
                      "addresses do not match this image")
                bad += 1
    if not bad:
        print("  no load block overlaps it")
    return bad


def main():
    ap = argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("gpt", help="the #PFCMGPT image mmbstamp generated")
    ap.add_argument("volume", help="the .mmv the blocks will be read from")
    ap.add_argument("--phase", type=int, action="append",
                    help="phase to correct (default: all with load blocks)")
    ap.add_argument("--tape-offset", type=int, required=True,
                    help="halfword offset in the volume of phase 3's first "
                         "block -- see the module note; volumes carry a "
                         "header, so this is measured, not assumed")
    ap.add_argument("-o", "--out", help="write the corrected table here")
    ap.add_argument("--check-image",
                    help="a YAGPC_SNAPSHOT image; verify no load-block "
                         "destination overlaps the live compool")
    a = ap.parse_args()

    G = hw_list(io.open(a.gpt, "rb").read())
    if len(G) != GPT_SIZE:
        sys.exit("%s is %d halfwords, expected %d" % (a.gpt, len(G), GPT_SIZE))
    V = hw_list(io.open(a.volume, "rb").read())

    phases = a.phase or [p for p in range(3, 19) if G[4 * (p - 3) + 1]]
    changed = unfixable = 0
    for p in phases:
        d = 4 * (p - 3)
        disp, nblks, mm, ncont = G[d:d + 4]
        if not nblks:
            continue
        print("phase %d: %d load blocks, mm %d = %d/%d/%d/%d"
              % (p, nblks, mm, *block_of(mm)))
        # Alignment is RELATIVE to the phase's own first block: the phase
        # base need not be a multiple of 512 in the volume, and rounding in
        # absolute coordinates walks off the blocks entirely.
        rel = 0
        for i in range(nblks):
            k = disp + 3 * i
            addr, flags, want = G[k], G[k + 1], G[k + 2]
            pos = a.tape_offset + rel
            got = true_length(V, pos, want, a.tape_offset)
            if got is None:
                print("    %2d: addr=0x%04x len=%5d  NO LENGTH VERIFIES at "
                      "tape %d -- tape content problem, left alone"
                      % (i + 1, addr, want, pos))
                unfixable += 1
                rel = ((rel + want + HW_PER_BLOCK - 1)
                       // HW_PER_BLOCK) * HW_PER_BLOCK
                continue
            if got != want:
                print("    %2d: addr=0x%04x len=%5d -> %5d  (%+d)"
                      % (i + 1, addr, want, got, got - want))
                G[k + 2] = got
                changed += 1
            rel = ((rel + got + HW_PER_BLOCK - 1)
                   // HW_PER_BLOCK) * HW_PER_BLOCK

        # NUM_CONT_MM_BLKS has to agree with the lengths, or the table is
        # internally inconsistent: correcting a length changes how many tape
        # blocks the phase spans, and leaving the count behind is a defect
        # this tool would otherwise INTRODUCE.
        rel = 0
        for i in range(nblks):
            rel = ((rel + G[disp + 3 * i + 2] + HW_PER_BLOCK - 1)
                   // HW_PER_BLOCK) * HW_PER_BLOCK
        span = rel // HW_PER_BLOCK
        flag = ncont & 0x8000                  # multi-track marker
        # A recovery that moves NUM_CONT far is not a recovery.  The walk
        # assumes each block starts at the next 512-halfword boundary after
        # the previous one, which only holds while the lengths are mostly
        # right: it self-corrects a few wrong ones (phase 3, three of ten)
        # and drifts hopelessly when most are wrong (phase 8, twenty-six of
        # twenty-seven, where it "recovered" a 110-block phase as 70).
        # Refuse rather than emit a table that looks authoritative.
        if abs((ncont & 0x7fff) - span) > max(2, (ncont & 0x7fff) // 8):
            print("    ncont %d -> %d is too large a move: the walk has "
                  "drifted, not recovered." % (ncont & 0x7fff, span))
            print("    phase %d NOT corrected -- its lengths need a source "
                  "this tool does not have." % p)
            sys.exit(3)
        if (ncont & 0x7fff) != span:
            print("    ncont: %d -> %d  (blocks the phase actually spans)"
                  % (ncont & 0x7fff, span))
            G[d + 3] = span | flag
            changed += 1

    print("\n%d correction(s), %d block(s) the tape cannot confirm"
          % (changed, unfixable))
    if a.check_image:
        bad = check_destinations(G, hw_list(io.open(a.check_image, "rb").read()))
        if bad:
            print("\n%d block(s) would corrupt live data -- NOT writing a table "
                  "that cannot be applied safely" % bad)
            sys.exit(2)
    if a.out:
        io.open(a.out, "wb").write(b"".join(struct.pack(">H", v) for v in G))
        print("wrote %s" % a.out)


if __name__ == "__main__":
    main()
