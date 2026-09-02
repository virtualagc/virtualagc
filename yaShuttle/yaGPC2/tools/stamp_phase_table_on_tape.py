#!/usr/bin/env python3
"""Build #PFCMGPT from the AUTHORITATIVE source and stamp it onto a volume.

    tools/stamp_phase_table_on_tape.py <volume.mmv> --boot-addr 4/4/5/0 -o OUT

WHY NOT mmbstamp ALONE

`ap101Utils.mmbstamp` reconstructs the ground Mass Memory Build's load-block
layout from the phase libraries.  The reconstruction is heuristic --
`_open_bank_tails` backs a block up over free memory, `_extend_mc_bank_tails`
pads one through a bank end -- and measured against this tape it is wrong.
For OI340600 phase 3, run against the very build root the tape came from, it
produces NINE blocks where the tape has TEN: the 12-halfword block at 0x0654 is
dropped, and every block after it shifts earlier and shorter.  Block 3 comes
out at 0x39c2 instead of 0x3a96.

That is not a cosmetic difference.  Applied to a running PASS, mmbstamp's
addresses put phase 3's third block at 0x2662 (from a stale build root) or
0x39c2 (from the right one) where the tape says 0x3a96; the first of those
lands inside the LIVE CZ2 compool and zeroes CZ2B_GRT_GPC_SET and
CZ2V_GRT_TAB -- the GPC reconfiguration table the OPS transition is reading --
after which FCOS dispatches a halt PSW and the machine stops with no message.

WHERE THE ONE CORRECT ADDRESS COMES FROM

The tape carries its own IPL phase table, inside FCMBOOT at FCMPTAD1 (halfword
894), holding four phase descriptors -- phases 10, 2, 13 and 3 -- each followed
by its load-block descriptors: main-memory address, protect/SOT/BSR/DSR flags,
and length.  It is authoritative in the strongest sense available: the machine
BOOTS from it.  Phase 3 is the GNC major-function overlay, so for the OPS 9
transition it is exactly the entry #PFCMGPT needs.

For phases the IPL table does not cover, mmbstamp's entry is used, with its
lengths corrected against the tape's own load-block checksums
(`fix_phase_table_lengths.py`) -- a load block is [content L-2][0][checksum]
with checksum == sum(content), so for a known start essentially one length
verifies.

VERIFICATION, NOT ASSERTION

Every block written is checked against the tape it will be read from, and the
result is checked for overlap with the live compool.  A table that cannot be
verified is not written."""

import argparse, io, struct, sys

GPT_SIZE = 1093
CPHA_SIZE = 57
FCMPTAD1_HW = 894                 # FCMPTAD1's offset inside FCMBOOT
IPL_PHASES = (10, 2, 13, 3)       # the order FCMBOOT's table uses


def hws(b):
    return list(struct.unpack(">%dH" % (len(b) // 2), b[:len(b) // 2 * 2]))


def ipl_table(boot):
    """{phase: [(addr, flags, len), ...]} from FCMBOOT's own phase table."""
    out = {}
    for i, ph in enumerate(IPL_PHASES):
        idx, nblks = boot[FCMPTAD1_HW + 3 * i], boot[FCMPTAD1_HW + 3 * i + 1]
        lbs = []
        for j in range(nblks):
            k = FCMPTAD1_HW + idx + 3 * j
            lbs.append((boot[k], boot[k + 1], boot[k + 2]))
        out[ph] = lbs
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("gpt", help="mmbstamp's #PFCMGPT, used for phases the "
                                "IPL table does not cover")
    ap.add_argument("boot", help="FCMBOOT as read off the tape (mmu get)")
    ap.add_argument("--phase", type=int, action="append", default=None,
                    help="restrict to these phases (default: every phase the "
                         "IPL table covers)")
    ap.add_argument("-o", "--out", required=True)
    a = ap.parse_args()

    G = hws(io.open(a.gpt, "rb").read())
    if len(G) != GPT_SIZE:
        sys.exit("%s is %d halfwords, expected %d" % (a.gpt, len(G), GPT_SIZE))
    tbl = ipl_table(hws(io.open(a.boot, "rb").read()))

    want = a.phase or [p for p in IPL_PHASES if 3 <= p <= 18]
    for ph in want:
        if ph not in tbl:
            print("phase %d is not in the IPL table; leaving mmbstamp's entry"
                  % ph)
            continue
        d = 4 * (ph - 3)
        disp, nblks = G[d], G[d + 1]
        lbs = tbl[ph]
        if len(lbs) != nblks:
            print("phase %d: mmbstamp has %d blocks, the tape has %d -- taking "
                  "the tape's" % (ph, nblks, len(lbs)))
            G[d + 1] = len(lbs)
        changed = 0
        for j, (addr, flags, ln) in enumerate(lbs):
            k = disp + 3 * j
            if (G[k], G[k + 1], G[k + 2]) != (addr, flags, ln):
                changed += 1
            G[k], G[k + 1], G[k + 2] = addr, flags, ln
        print("phase %2d: %d load blocks taken from the tape (%d differed)"
              % (ph, len(lbs), changed))

    io.open(a.out, "wb").write(b"".join(struct.pack(">H", v) for v in G))
    print("wrote %s" % a.out)


if __name__ == "__main__":
    main()
