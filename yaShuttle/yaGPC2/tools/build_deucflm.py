#!/usr/bin/env python3
"""Build DEUCFLM, the DEU critical-format load module, from CON80/CFSYSIN.

WHY THIS EXISTS

Sixteen display backgrounds live permanently in the display unit's own
memory rather than being sent on each call-up: the "critical formats".
`CON80/CFSYSIN` names them and gives the layout --

    CRTFMTCU=(#PXD0990,#PXG0500,...)   the CFIT slots, in order
    ORIGIN=0100  CFITSIZE=20  CFBSIZE=0E48  PAD=111E  CRTFMTLM=DEUCFLM

-- and `CON80/MMUSYS5B/5E/5H` stage the linked image onto the tape as
`DMACDFT1/2/3`, three copies of SYS5.  GPCIPL reads a copy at IPL
(`GPCRTOPT.asm`: GRPTO3 is `X'B1000E49'`, 3657 halfwords, and GRPFRM4 is
`DCPSTART+X'100'`) and downloads it to the unit as seven FORMAT_FILLs.

Our build never made it.  The phase build generates the `CD****` COMPOOL
half of each display deck and not the `XD****`/`XG****` static half, and
nothing called `dfg deucflm`, so the tape carried no SYS5 at all and the
unit's critical-format buffer was all zeros.  Every critical-format
display then draws its variable data over a blank background -- clocks,
the GPC indicator and a scatter of characters, with no title and no menu.
That is the whole of the "garbage menu" on CRT2.

WHAT IT DOES

Runs `dfg` once per member to generate the static format module, takes
that module's halfwords, and lays the image out with `dfg`'s own
`deucflm.build`: the CFIT of branch FCWs, the bodies in first-use order,
PAD to CFBSIZE, then the checksum halfword.

A static format module is a single `ARRAY(n) BIT(16) INITIAL(HEX'....')`
and nothing else -- no `NAME(...)` address constant anywhere in the
sixteen -- so its `HEX'....'` constants ARE its csect image and no HAL/S
compile is needed to link it.  Checked against the historical DFG output
where OI301700 still carries it: XD0001 is 463 halfwords and XD0990 is
40, both identical to `OI301700/SSSRC/*.hal` halfword for halfword.

Members with no `.dfg` deck are taken from `SSSRC/<name>.hal`, which is
where `XD0000` -- the shared "NO CFMT BKGD" body every SPARE slot
branches to -- lives.

Then put it on the tape:

    tools/build_deucflm.py --con80 <CON80> --deck-root <release> -o DEUCFLM.bin
    tools/add_sysid_allocs.py V.mmv --con80 <CON80> \
        --content DMACDFT1=DEUCFLM.bin \
        --content DMACDFT2=DEUCFLM.bin \
        --content DMACDFT3=DEUCFLM.bin
"""
import argparse
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

_HEX = re.compile(r"HEX'([0-9A-Fa-f]{4})'")


def module_words(path):
    """The halfwords a static format module declares.  Comment lines start
    with `C` in column 1; everything else is the INITIAL list."""
    out = []
    for line in open(path, errors="replace"):
        if line.startswith("C"):
            continue
        out += [int(x, 16) for x in _HEX.findall(line)]
    return out


def generate(name, dfg, deck_root, outdir, verbose):
    """`dfg <name>` into outdir, or the release's own .hal when no deck."""
    hal = outdir / (name + ".hal")
    r = subprocess.run([dfg, name, "--deck-root", str(deck_root),
                        "-o", str(hal)],
                       capture_output=True, text=True)
    if r.returncode == 0 and hal.is_file():
        return hal, "dfg"
    for sub in ("SSSRC", "APPLSRC"):
        p = Path(deck_root, sub, name + ".hal")
        if p.is_file():
            return p, str(Path(sub, p.name))
    tail = ((r.stderr or "").strip().splitlines()[-1:] or ["?"])[0]
    sys.exit("cannot build %s: dfg says %s, and no %s.hal in the release"
             % (name, tail, name))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--con80", required=True,
                    help="CON80 directory holding CFSYSIN")
    ap.add_argument("--deck-root", required=True,
                    help="release root the decks are resolved under "
                         "(e.g. .../PFS/OI340600)")
    ap.add_argument("--dfg", default=os.environ.get("DFG", "dfg"),
                    help="the dfg executable [$DFG, else `dfg` on PATH]")
    ap.add_argument("--sdl", default=os.environ.get("NSTS_SDL_DPS"),
                    help="nsts-sdl-dps checkout, for dfg's own modules "
                         "[$NSTS_SDL_DPS]")
    ap.add_argument("-o", "--output", default="DEUCFLM.bin")
    ap.add_argument("--keep", help="keep the generated .hal files here")
    ap.add_argument("-v", "--verbose", action="store_true")
    a = ap.parse_args()

    sdl = a.sdl or str(Path(a.dfg).resolve().parent.parent.parent / "src")
    sys.path.insert(0, sdl if sdl.endswith("src") else str(Path(sdl, "src")))
    try:
        from dfg import deucflm
    except ImportError as e:
        sys.exit("cannot import dfg.deucflm from %s (%s); pass --sdl or set "
                 "NSTS_SDL_DPS, and run under the venv dfg itself uses" % (sdl, e))

    cfsysin = Path(a.con80, "CFSYSIN")
    if not cfsysin.is_file():
        sys.exit("no CFSYSIN in %s" % a.con80)
    slots, params = deucflm.parse_cfsysin(cfsysin)

    outdir = Path(a.keep) if a.keep else Path(tempfile.mkdtemp(prefix="cflm."))
    outdir.mkdir(parents=True, exist_ok=True)
    try:
        bodies = {}
        for csect in dict.fromkeys(slots):
            name = csect[2:] if csect.startswith("#P") else csect
            hal, how = generate(name, a.dfg, a.deck_root, outdir, a.verbose)
            bodies[csect] = module_words(hal)
            if not bodies[csect]:
                sys.exit("%s generated no halfwords (%s)" % (name, hal))
            print("  %-9s %4d halfwords  (%s)" % (csect, len(bodies[csect]), how))
        image = deucflm.build(slots, params, bodies)
    finally:
        if not a.keep:
            shutil.rmtree(outdir, ignore_errors=True)

    Path(a.output).write_bytes(struct.pack(">%dH" % len(image), *image))
    used = sum(len(bodies[m]) for m in dict.fromkeys(slots))
    print("  CFIT %d slots + %d body halfwords + PAD -> %d halfwords "
          "(CFBSIZE %d + checksum %04X) -> %s"
          % (params["CFITSIZE"], used, len(image), params["CFBSIZE"],
             image[-1], a.output))


if __name__ == "__main__":
    main()
