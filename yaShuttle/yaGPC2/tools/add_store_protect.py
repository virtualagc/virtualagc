#!/usr/bin/env python3
"""Add a section-derived storeProtect map to a copy of a .sym.json.

Why this exists
---------------
The reference emulator (nsts-sim-gpc) takes storage protection from a
`storeProtect` map in the image's `.sym.json` as of its commit 0e275b1,
and protects NOTHING when the image carries none.  GPCIPL does not
survive that: with storage unprotected the Instruction Monitor fires the
moment the software sets PSW mask bit 34, because every instruction then
appears to be executing out of unprotected storage.  Measured, the
reference stops driving the bus entirely -- zero commands to a display
unit, against 492 on the commit before it.

`lnk101` does write the map (linker.py's storeProtectRangesHw), but
mmu2fcm's unionSym() composes the final .sym.json from an explicit key
list and never carries `storeProtect` across from the constituent
phases.  So a composed image such as IPL cannot get a real map by
relinking, which is what the reference's own warning advises.

That leaves the reference unusable on a composed image, and we need it
usable: it is the oracle every yaGPC2 trace comparison is measured
against.  This script supplies the map the only way available here --
from the section table the .sym.json already carries, protecting each
loaded section, which is exactly the policy the reference itself used
before 0e275b1 and the one yaGPC2's own apply_load_protection() uses
today.

What it is NOT
--------------
This is not what the linker would emit.  The linker's map honours
explicit PROT ranges and per-csect marks, so it protects LESS than a
whole-section sweep -- deliberately, since blanket section protection
locks the runtime's own IOCODE/IOBUF cells and the stack.  For booting
GPCIPL that difference does not matter (measured: the load completes and
the display reports itself initialised).  For anything that writes those
cells it will, so do not mistake this for the real map.

The input file is never modified; output goes somewhere else.
"""

import argparse
import json
import shutil
import sys
from pathlib import Path


def section_ranges_hw(sym):
    """Halfword [start, end) ranges covering every loaded section."""
    ranges = []
    for s in sym.get("sections", []):
        addr, size = s.get("address"), s.get("size")
        if addr is None or size is None or size <= 0:
            continue
        ranges.append([addr, addr + size])
    ranges.sort()
    merged = []
    for lo, hi in ranges:
        if merged and lo <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], hi)
        else:
            merged.append([lo, hi])
    return merged


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("sym", type=Path, help="input <NAME>.sym.json (not modified)")
    ap.add_argument("-o", "--out-dir", type=Path, required=True,
                    help="directory to write the patched pair into")
    ap.add_argument("--fcm", type=Path,
                    help="also copy this .fcm beside it (default: <NAME>.fcm "
                         "next to the input, when it exists)")
    ap.add_argument("-f", "--force", action="store_true",
                    help="overwrite an existing output")
    args = ap.parse_args(argv)

    sym = json.load(open(args.sym))
    if "storeProtect" in sym:
        print(f"{args.sym}: already carries a storeProtect map; nothing to do",
              file=sys.stderr)
        return 1

    ranges = section_ranges_hw(sym)
    if not ranges:
        print(f"{args.sym}: no sections with a size; nothing to derive a map from",
              file=sys.stderr)
        return 1
    sym["storeProtect"] = {"unit": "halfword", "ranges": ranges}

    args.out_dir.mkdir(parents=True, exist_ok=True)
    outSym = args.out_dir / args.sym.name
    if outSym.resolve() == args.sym.resolve():
        print("refusing to write over the input", file=sys.stderr)
        return 1
    if outSym.exists() and not args.force:
        print(f"{outSym} exists (use --force)", file=sys.stderr)
        return 1
    json.dump(sym, open(outSym, "w"))

    fcm = args.fcm
    if fcm is None:
        # <NAME>.sym.json -> <NAME>.fcm
        guess = args.sym.with_name(args.sym.name[: -len(".sym.json")] + ".fcm")
        fcm = guess if guess.exists() else None
    if fcm is not None:
        outFcm = args.out_dir / fcm.name
        if outFcm.exists() and not args.force:
            print(f"{outFcm} exists (use --force)", file=sys.stderr)
            return 1
        shutil.copy2(fcm, outFcm)

    covered = sum(hi - lo for lo, hi in ranges)
    print(f"{outSym}: {len(ranges)} ranges, {covered} halfwords protected"
          + (f"; copied {fcm.name}" if fcm is not None else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
