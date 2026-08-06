#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-literals.py
Purpose:    Recover memory contents that unlinkMAFGEN2 did not scrape, from
            MAFGEN's own literal annotations, and patch them into the .fcm.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-literals.py --config=SSW [--out=F.fcm] [--report]

THE PROBLEM.  MAFGEN's data listing does not print every halfword of a CSECT.
For a #D it prints the "??? ADCONS,LITERALS,ETC. ???" region it recognises and
the named variables, and skips what lies between.  unlinkMAFGEN2 leaves those
halfwords at -1, "not explicitly initialized", and then SYNTHESISES a value for
the .fcm purely from the address -- 0xC9FB below 0x20000 and 0xC6C6 above
(unlinkMAFGEN2.py:481-488).  Those are guesses, not observations, and comparing
against them manufactures differences: in SSW they accounted for most of the
differing DATA CSECTs.

fcmcmp's --no-data option stops counting such halfwords as differences.  But it
also means a genuine disagreement in that region is invisible, because there is
nothing to disagree with.  This script supplies the missing data where MAFGEN
in fact reported it.

THE SOURCE.  A literal is data, but MAFGEN prints it against the INSTRUCTION
that references it, not in the data listing:

    $0AIBGPC+0073   0459  000728   A R4,X'002C'(R1)
                                     LITERAL: =F'-2132803578', =X'80E00006'

The effective-address column gives 0x000728, which is #DAIBGPC+0x2C, and
=X'80E00006' is the halfword pair 80E0 0006 that lives there.  Over
DASS_SSW_(PostIPL).ASC this recovers 356 addresses with ZERO conflicting
values, which is itself good evidence the reading is right -- the same literal
is usually referenced from several places, and they always agree.

WHAT IT IS WORTH.  Of those 356, 33 fall where the scrape had nothing.  Patched
in, they turn a region that could only be skipped into one that can be checked,
and the check is not vacuous: over SSW our image agrees with 22 of them and
disagrees with 10.  The disagreements are the real finding underneath -- small
constant offsets in pointers to remote COMPOOLs, almost always exactly two
halfwords.

This does not touch PFS/mafgen.  It writes a patched copy, to be passed to
compileLinkCompare as --memory=F.fcm.  Teaching unlinkMAFGEN2 to scrape the
annotations itself would be the tidier fix, but that means regenerating every
.fcm, and this keeps the recovered data separable from the original scrape.
'''

import sys
import re
import json
import struct
from pathlib import Path

DEFAULT_MAFGEN = Path("~/workspace/PFS/mafgen").expanduser()

# The values unlinkMAFGEN2 synthesises for a halfword the listing never
# reported.  Only these may be overwritten: anything else is data MAFGEN
# actually stated, and this script must not contradict it.
SYNTHESISED = {0xC9FB, 0xC6C6}

# "  0006FC-000701  $0AIBGPC+0073   0459  000728   A  R4,..  LITERAL: ..=X'80E00006'"
# The second six-hex-digit group is the effective address -- where the literal
# lives -- and the =X'...' is its value.  Eight hex digits is two halfwords;
# four is one.
LITERAL_RE = re.compile(
    r"^\s*[0-9A-F]{6}(?:-[0-9A-F]{6})?\s+\S+\+[0-9A-F]{4}\s+"
    r"[0-9A-F ]+?\s([0-9A-F]{6})\s+.*LITERAL:.*?=X'([0-9A-F]{4}(?:[0-9A-F]{4})?)'")


def dassPath(mafgen, config):
    name = "DASS_SSW_(PostIPL).ASC" if config == "SSW" else f"DASS_{config}.ASC"
    return mafgen / name


def recoverLiterals(path):
    '''address -> tuple of halfwords, plus a count of contradictions.'''
    values = {}
    conflicts = 0
    for line in open(path, errors="replace"):
        m = LITERAL_RE.search(line)
        if not m:
            continue
        address = int(m.group(1), 16)
        text = m.group(2)
        halfwords = tuple(int(text[i:i + 4], 16) for i in range(0, len(text), 4))
        if address in values and values[address] != halfwords:
            conflicts += 1
            continue        # keep the first reading and count the disagreement
        values[address] = halfwords
    return values, conflicts


def main():
    config = "SSW"
    mafgen = DEFAULT_MAFGEN
    out = None
    report = False
    for p in sys.argv[1:]:
        if p.startswith("--config="):
            config = p.partition("=")[2]
        elif p.startswith("--mafgen="):
            mafgen = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--out="):
            out = p.partition("=")[2]
        elif p == "--report":
            report = True
        else:
            print(__doc__)
            sys.exit(1)
    if out is None:
        out = f"{config}.literals.fcm"

    values, conflicts = recoverLiterals(dassPath(mafgen, config))
    image = bytearray(open(mafgen / f"{config}.fcm", "rb").read())

    patched = agreed = occupied = beyond = 0
    details = []
    for address, halfwords in sorted(values.items()):
        for i, v in enumerate(halfwords):
            byte = (address + i) * 2
            if byte + 1 >= len(image):
                beyond += 1
                continue
            existing = struct.unpack_from(">H", image, byte)[0]
            if existing == v:
                agreed += 1
            elif existing in SYNTHESISED:
                struct.pack_into(">H", image, byte, v)
                patched += 1
                details.append((address + i, existing, v))
            else:
                # MAFGEN stated a value here in its data listing AND as a
                # literal, and they disagree.  Leave the data listing alone and
                # say so: this would mean the two readings of the DASS are
                # inconsistent, which has not been observed.
                occupied += 1
                details.append((address + i, existing, v))

    open(out, "wb").write(image)
    print(f"{config}: {len(values)} literal addresses recovered from "
          f"{dassPath(mafgen, config).name}, {conflicts} contradicting")
    print(f"   patched into halfwords the scrape had synthesised: {patched}")
    print(f"   already present and agreeing:                      {agreed}")
    print(f"   already present and DISAGREEING (left alone):      {occupied}")
    if beyond:
        print(f"   beyond the end of the image:                       {beyond}")
    print(f"-> {out}")
    if report:
        for address, was, now in details:
            print(f"   @{address:05X}  scrape {was:04X} -> literal {now:04X}")


if __name__ == "__main__":
    main()
