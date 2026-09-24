#!/usr/bin/env python3
"""Build a background MEDS draws for itself, from the release that still drew it.

WHY THIS EXISTS

One display in the vehicle has no background on screen, and it is not a
defect in the display unit or in our loader: the flight software stopped
drawing it.  `CR93220A  01/23/08  OI3404  MOVE DPS UTILITY BACKGROUND TO
MEDS` deletes the whole static drawing from `SSSRC/CD0010.dfg` --
`DELETE=(002000-005446)` -- and adds two lines in its place:

    */ DRAW DPS UTILITY BACKGROUND,
    VDISP=158,

So from OI34 on, the GPC only NAMES the background and MEDS draws it.
CD0010.dfg is the only deck in the flight source that uses VDISP, which is
why DPS UTILITY is the one screen with nothing behind its data.  MEDS2.py
decoded the command and drew nothing; now it draws this file.

WHERE THE CONTENT COMES FROM

The release BEFORE the change still draws it, in DEU commands with their own
coordinates: `OI301700 as received/SSSRC/CD0010`, sequence numbers 006900
through 012500 -- XC=18,YC=1,CHAR=(DPS UTILITY), MMU ASSIGN, PORT ASSIGN,
VAR PARAM ID LIST, GROUND OPS, G3 ARCHIVE, the rules and the underscores.
They are lifted verbatim into a static format deck of the shape the sixteen
critical formats use (CRTFMT/STAT/END), run through `dfg` -- the same
generator, from the same tree, that builds those -- and the halfwords it
emits are written out as a `.dfb`, the stream as it would go over the bus.

Nothing is drawn by hand and nothing is transcribed from a figure: what ends
up on screen is what the flight software itself used to send.  Compare it
with PASS User's Guide USA002869 (OI32) figure 3.001 to check it.

    build_meds_background.py --deck "$PFS/OI301700 as received/SSSRC/CD0010" \
        --lines 006900-012500 --format 0010 \
        --dfg ~/donschmidt/nsts-sdl-dps/build/bin/dfg \
        -o ../discretePanel/data/0010-D-DPS_UTILITY.dfb
"""
import argparse
import os
import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

# A line of an as-received listing: a change flag, the sequence number, the
# deck's own column marks, then the card.
CARD = re.compile(r"^.(\d{6})\s+C\|(.*?)\s*\|")
HEX = re.compile(r"HEX'([0-9A-Fa-f]{4})'")


def cards(deck, lo, hi):
    """The cards of `deck` whose sequence numbers fall in [lo, hi]."""
    out = []
    for raw in open(deck, errors="replace"):
        m = CARD.match(raw.rstrip("\r\n"))
        if m is not None and lo <= m.group(1) <= hi:
            out.append(m.group(2).strip())
    return out


def module_words(path):
    """The halfwords a generated static format module declares.  Comment
    lines start with `C` in column 1; everything else is the INITIAL list.
    The same reading build_deucflm.py does of the same kind of file."""
    out = []
    for line in open(path, errors="replace"):
        if line.startswith("C"):
            continue
        out += [int(x, 16) for x in HEX.findall(line)]
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--deck", required=True,
                    help="the as-received deck that still draws it")
    ap.add_argument("--lines", required=True,
                    help="sequence range of the static drawing, LO-HI")
    ap.add_argument("--format", required=True,
                    help="the display number, e.g. 0010")
    ap.add_argument("--dfg", default=os.environ.get("DFG", "dfg"),
                    help="the dfg executable [$DFG, else `dfg` on PATH]")
    ap.add_argument("-o", "--output", required=True)
    ap.add_argument("--keep", help="keep the deck and module here")
    a = ap.parse_args()

    lo, _, hi = a.lines.partition("-")
    if not hi:
        sys.exit("--lines wants a range, LO-HI")
    body = cards(a.deck, lo, hi)
    if not body:
        sys.exit("no cards in %s between %s and %s" % (a.deck, lo, hi))

    work = Path(a.keep) if a.keep else Path(tempfile.mkdtemp(prefix="medsbg."))
    (work / "SSSRC").mkdir(parents=True, exist_ok=True)
    name = "XD" + a.format
    deck = work / "SSSRC" / (name + ".dfg")
    deck.write_text("\n".join(["CRTFMT=%sC," % a.format, "STAT,"]
                              + body + ["END"]) + "\n")

    hal = work / (name + ".hal")
    r = subprocess.run([a.dfg, name, "--deck-root", str(work), "-o", str(hal)],
                       capture_output=True, text=True)
    if r.returncode != 0 or not hal.is_file():
        sys.exit("dfg could not build %s: %s"
                 % (name, (r.stderr or r.stdout or "?").strip()[-400:]))

    words = module_words(hal)
    if not words:
        sys.exit("%s generated no halfwords" % name)
    Path(a.output).write_bytes(struct.pack(">%dH" % len(words), *words))
    print("%s: %d card(s) -> %d halfwords -> %s"
          % (name, len(body), len(words), a.output))


if __name__ == "__main__":
    main()
