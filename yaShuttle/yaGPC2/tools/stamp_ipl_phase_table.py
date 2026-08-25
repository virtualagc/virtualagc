#!/usr/bin/env python3
"""Stamp FCMBOOT's IPL phase table into a PHASE01 image.

WHY THIS EXISTS

FCMBOOT is the IPL bootstrap loader the IOP microcode fetches from the
mass memory.  Its job is to read the GPCIPL/SSL phase in from the tape,
and it navigates by a table it does not build for itself:

    FCMPTAD1 DC  H'-1'      THE MASS MEMORY BUILD PROGRAM
             DS  255H       EACH ENTRY POINT REFLECTS
    FCMPTAD2 DC  H'-1'      OF THE STP/SSL LOAD AND THE PHASE
             DS  255H       2 LOAD.  ANALOGOUS TO THE MASS
    FCMPTAD3 DC  H'-1'      MEMORY AREA.  THE X'FFFF' SIGNALS
             DS  255H       THAT THIS AREA HAS NOT BEEN MASS
    *                       MEMORY BUILT (DOESN'T EXIST).
    *                       MMB PGM WILL STORE ON TOP OF IT.

Three 256-halfword areas, one per redundant PASS copy, each left holding
X'FFFF' -- the documented "this area was never built" sentinel -- for the
ground Mass Memory Build to stamp over.  Nothing in the toolchain does
that: mmu2fcm's --stamp-phase-tables covers #PFCMGPT, #PCDCPHA and
FCMG3DAT, which are the SSL's in-core tables, not this one; mmubuild's
DIRECTRY/DMMD pass does not name it either (checked: the only DMMD
directories in the OI340600 cards are SMARDD2A and SMARDD4A).  So a
FCMBOOT built from source walks all three areas, finds FFFF in each, and
lands in its documented give-up wait state having never touched the bus.

WHAT THE TABLE LOOKS LIKE

From FCMBOOT's own prolog, and confirmed against the code that reads it:

    001CA  LH R4,0(R0)     hw 0 -> index to 1st load block
    001CD  LH R5,1(R0)     hw 1 -> number of load blocks
    001D0  LH R6,2(R0)     hw 2 -> MM address of 1st load block
    001D3  LA R2,0(R4,R0)  the LB array sits at table base + index

So each area holds four 3-halfword PHASE descriptors, for phases X, 2,
13 and 3 in that order (X is 10, the GPCIPL/SSL phase), followed by the
3-halfword LOAD BLOCK descriptors for each in the same order.  A load
block descriptor is

    hw 0   main memory address of this LB
    hw 1   P.R.....B/DR....   bit 0 storage protect, bit 2 reserve,
                              bits 4-7 always 0110, bits 8-11 sector
    hw 2   length of the load block in halfwords

which is precisely what ap101Utils.mmbstamp.LoadBlock.words() already
emits for the SSL's table -- so the derivation is borrowed rather than
reinvented, and the two tables cannot drift apart.

WHAT IS ASSUMED, AND WHAT IS NOT

Not assumed: the load-block partition, the descriptor bit layout, the
per-area MM addresses and the IPL phase set all come from the toolchain
and the CON80 cards (MMLOAD's `IPL,PH=(10,2,13,3)`).

Assumed: that the ground Mass Memory Build laid the four phases' load
blocks out in this order, contiguously, starting immediately after the
twelve halfwords of phase descriptors.  The prolog's diagram shows that
order and nothing contradicts it, but no original stamped table has been
seen, so this is a reconstruction rather than a reproduction.  It is
enough to get FCMBOOT reading the tape; it is not evidence about what
the real table's bytes were.
"""

import argparse
import json
import sys
from pathlib import Path

# Phase order within the table, from FCMBOOT's prolog: "PHASES X, 2, 13,
# & 3 DESCRIPTORS ARE AS FOLLOWS: X CURRENTLY = 10 (GPCIPL/SSL)".
IPL_PHASE_ORDER = (10, 2, 13, 3)

AREA_HW = 256                    # each FCMPTADn area
NOT_BUILT = 0xFFFF               # the sentinel the areas come up holding


def build_area(lbs_by_phase, mm_by_phase):
    """One area's table, as a list of AREA_HW halfwords."""
    words = [0] * AREA_HW
    disp = 3 * len(IPL_PHASE_ORDER)          # LBs start after the descriptors
    for i, p in enumerate(IPL_PHASE_ORDER):
        lbs = lbs_by_phase[p]
        words[3 * i: 3 * i + 3] = [disp, len(lbs), mm_by_phase[p] & 0xFFFF]
        for lb in lbs:
            if disp + 3 > AREA_HW:
                raise SystemExit("IPL phase table overflows %d halfwords at "
                                 "phase %d" % (AREA_HW, p))
            words[disp:disp + 3] = [w & 0xFFFF for w in lb.words()]
            disp += 3
    return words


def main(argv=None):
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("image", type=Path, help="PHASE01 .fcm to stamp")
    ap.add_argument("--sym", type=Path,
                    help="its .sym.json (default: alongside the image)")
    ap.add_argument("--mmu", type=Path, required=True,
                    help="phase-lib root holding PHASEnn.lib")
    ap.add_argument("--con80", type=Path, required=True,
                    help="CON80 deck directory")
    ap.add_argument("--sdl", type=Path,
                    default=Path.home() / "donschmidt/nsts-sdl-dps",
                    help="nsts-sdl-dps checkout (for ap101Utils)")
    ap.add_argument("-o", "--out", type=Path, required=True,
                    help="where to write the stamped image")
    ap.add_argument("--areas", default="1,2,3",
                    help="which PASS areas to stamp (default all three); an "
                         "area left out keeps its FFFF not-built sentinel")
    args = ap.parse_args(argv)

    sys.path.insert(0, str(args.sdl / "src"))
    from ap101Utils import mmbstamp

    sym = args.sym or args.image.with_name(
        args.image.name[:-4] + ".sym.json")
    symDoc = json.load(open(sym))
    # FCMPTAD1/2/3 are ENTRY points inside FCMBOOT, not sections of their
    # own, so they live in the flat symbol list rather than "sections".
    at = {s["name"]: s["address"]
          for s in symDoc.get("symbols", [])
          if isinstance(s, dict) and "name" in s and "address" in s}

    src = mmbstamp.load_phase_source(args.con80)

    # The load-block partition is a property of the phase, not of the area;
    # only the MM (tape) address differs between the redundant copies.
    lbs_by_phase = {}
    for p in IPL_PHASE_ORDER:
        lbs, _mm, _ncont, _crossed = mmbstamp.phase_load_blocks(
            args.mmu, p, src)
        lbs_by_phase[p] = lbs

    image = bytearray(open(args.image, "rb").read())
    wanted = [int(a) for a in args.areas.split(",") if a.strip()]

    for area in (1, 2, 3):
        name = "FCMPTAD%d" % area
        addr = at.get(name)
        if addr is None:
            raise SystemExit("%s not found in %s" % (name, sym))

        if area not in wanted:
            print("  %s at 0x%05X: left as FFFF (not built)" % (name, addr))
            continue

        mm_by_phase = {p: src.areas[area].mm_of_phase.get(p, 0)
                       for p in IPL_PHASE_ORDER}
        words = build_area(lbs_by_phase, mm_by_phase)
        for i, w in enumerate(words):
            image[2 * (addr + i)] = (w >> 8) & 0xFF
            image[2 * (addr + i) + 1] = w & 0xFF
        used = 3 * len(IPL_PHASE_ORDER) + 3 * sum(
            len(lbs_by_phase[p]) for p in IPL_PHASE_ORDER)
        print("  %s at 0x%05X: %d halfwords used of %d; phases %s"
              % (name, addr, used, AREA_HW,
                 ", ".join("%d:%dLB@%04X" % (p, len(lbs_by_phase[p]),
                                             mm_by_phase[p])
                           for p in IPL_PHASE_ORDER)))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    open(args.out, "wb").write(bytes(image))
    print("wrote %s (%d bytes)" % (args.out, len(image)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
