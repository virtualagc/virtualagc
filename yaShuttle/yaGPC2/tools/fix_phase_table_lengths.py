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


def true_length(w, s, want, span=12000):
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
    for L in range(MIN_LB_HW, min(span, len(w) - s)):
        if checksums(w, s, L):
            return L
    return None


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
            got = true_length(V, pos, want)
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
        if (ncont & 0x7fff) != span:
            print("    ncont: %d -> %d  (blocks the phase actually spans)"
                  % (ncont & 0x7fff, span))
            G[d + 3] = span | flag
            changed += 1

    print("\n%d correction(s), %d block(s) the tape cannot confirm"
          % (changed, unfixable))
    if a.out:
        io.open(a.out, "wb").write(b"".join(struct.pack(">H", v) for v in G))
        print("wrote %s" % a.out)


if __name__ == "__main__":
    main()
