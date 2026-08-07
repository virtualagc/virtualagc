#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-literals.py
Purpose:    Recover memory contents that unlinkMAFGEN2 did not scrape, from
            MAFGEN's own literal annotations, and patch them into the .fcm.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-literals.py --config=SSW [--out=F.fcm]
                            [--exceptions=F.txt] [--report]

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


# MAFGEN prefixes a value with '*' where the location does not hold what the
# build put there -- an I-LOAD, a patch, or a checksum, all applied afterwards.
# Two line shapes carry them, and both must be read:
#
#   named variable, one value, belonging to the address at the left:
#     00304A         #PCDULNK+004C   CDUV_NSP_VEHICLE_ILOAD   *0005  BIN'101'
#
#   hex dump, several values, consecutive from the address at the left:
#     0001A6-0001A7  --------+0000      *0000 *1381
#
# Reading the second shape as though it were the first put the wrong value at
# the wrong address, which the self-check below caught.
#   named variable spanning several halfwords, only some of them starred:
#     004F64-004F65  #PCGGCOM+0116  CGGV_V_MAG_MECO   4464 *DB00   SP SCALAR
#     005B2C-005B2F  #PCGNCOM+0104  CGGS_NAVBASE_LAT  407F *D2DB *03C7 *34DD
#
# The third shape is the one that took two attempts.  Reading it as the first
# shape put its first STARRED value at the leading address, when the values are
# positional there too: *DB00 belongs to 004F65, and 004F64 holds the unstarred
# 4464.  The address range says how many halfwords the row carries, which is
# both how the values are placed and how the glued-name case below is settled.
STARRED_LINE_RE = re.compile(
    r"^\s*([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+(\S+)\s+(.*)$")
HEXWORD_RE = re.compile(r"^(\*?)([0-9A-F]{4})$")
# A name wide enough to fill its column runs into the first value.  Where the
# value is starred the split is unambiguous -- it begins at the '*' -- and that
# is the case worth getting right, because a starred value is an exception we
# must record.  The older single pattern demanded a non-hex character before the
# value, which silently failed for every name ending in one:
# GFK_FWD_RCS_RTLS_DUMP_START_TIME*0000 and CDUV_NSP_VEHICLE_ILOAD*0005 both end
# in a hex letter, so their patches went unrecorded and counted as differences
# against locations the build never wrote.  Unstarred glue stays on the stricter
# rule, since nothing marks where the name ends there.
GLUED_STAR_RE = re.compile(r"^(.+?)(\*[0-9A-F]{4})$")
GLUED_PLAIN_RE = re.compile(r"^(.*[^0-9A-F*])([0-9A-F]{4})$")


def gluedSplit(token):
    return GLUED_STAR_RE.match(token) or GLUED_PLAIN_RE.match(token)


def leadingRun(tokens, limit):
    '''The maximal leading run of halfword tokens, at most limit of them.

    Stopping at the first non-halfword keeps the trailing engineering-units
    and type columns ("4.4000000E+03  SP SCALAR VARIABLE") out of the values.
    '''
    words = []
    for t in tokens:
        if len(words) >= limit:
            break
        w = HEXWORD_RE.match(t)
        if not w:
            break
        words.append(w)
    return words


def recoverStarred(path):
    """address -> (value, name) for every location MAFGEN marks with '*'.

    No compilation or link can reproduce these: they were written after the
    build by a separate step -- mission and vehicle constants, patches, and
    checksums.  Over SSW, of the starred locations falling inside a section we
    link, our build matches the starred value 0 times and differs at every one,
    which is the evidence that the marker means what it appears to mean.

    They are not defects to chase but bookkeeping to record, so that they stop
    appearing in comparison reports as differences needing to be explained away
    again every time somebody reads one.
    """
    starred = {}
    for line in open(path, errors="replace"):
        m = STARRED_LINE_RE.match(line)
        if not m or "*" not in m.group(4):
            continue
        start, end, _csect, rest = m.groups()
        address = int(start, 16)
        span = (int(end, 16) - address + 1) if end else 1
        tokens = rest.split()

        name = ""
        if tokens and not HEXWORD_RE.match(tokens[0]):
            name = tokens[0]
            # A name wide enough to fill its column runs into the first value
            # with no space between them:
            #   CGGS_FD_THRUST_ANG_COEF_SWITCH_V*4411 *3000
            # Split it only where doing so supplies the number of halfwords
            # the address range says the row carries, so the split validates
            # itself rather than guessing where a name ends.
            glued = gluedSplit(name)
            if glued and len(leadingRun(tokens[1:], span)) < span:
                name = glued.group(1)
                tokens = [glued.group(2)] + tokens[1:]
            else:
                tokens = tokens[1:]
            # The first token is sometimes the CSECT+offset field rather
            # than an identifier; that is not a name worth recording.
            if name.startswith("+") or set(name) <= set("-"):
                name = ""

        # The halfwords are positional -- consecutive from the leading address
        # -- in every shape of row, named or not.
        for i, w in enumerate(leadingRun(tokens, span)):
            if w.group(1):
                starred.setdefault(address + i, (int(w.group(2), 16), name))
    return starred


def main():
    config = "SSW"
    mafgen = DEFAULT_MAFGEN
    out = None
    exceptionsOut = None
    report = False
    for p in sys.argv[1:]:
        if p.startswith("--config="):
            config = p.partition("=")[2]
        elif p.startswith("--mafgen="):
            mafgen = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--out="):
            out = p.partition("=")[2]
        elif p.startswith("--exceptions="):
            exceptionsOut = p.partition("=")[2]
        elif p == "--report":
            report = True
        else:
            print(__doc__)
            sys.exit(1)
    if out is None:
        out = f"{config}.literals.fcm"

    if exceptionsOut is None:
        exceptionsOut = f"exceptions-{config}.txt"
    starred = recoverStarred(dassPath(mafgen, config))
    with open(exceptionsOut, "w") as f:
        f.write(f"# exceptions-{config}.txt -- locations changed after the "
                f"build, scraped from\n# {dassPath(mafgen, config).name}, "
                f"where MAFGEN marks the value with '*'.\n"
                f"# address value name\n")
        for address, (value, name) in sorted(starred.items()):
            f.write(f"{address:05X} {value:04X} {name}\n".rstrip() + "\n")
    print(f"{config}: {len(starred)} location(s) marked as changed after the "
          f"build -> {exceptionsOut}")
    # Self-check: every entry must match the reference image, since
    # unlinkMAFGEN2 scraped the starred value into it.  A mismatch means the
    # line was parsed wrongly, not that the image is wrong.
    check = bytearray(open(mafgen / f"{config}.fcm", "rb").read())
    good = bad = 0
    for address, (value, _name) in starred.items():
        byte = address * 2
        if byte + 1 >= len(check):
            continue
        if struct.unpack_from(">H", check, byte)[0] == value:
            good += 1
        else:
            bad += 1
    print(f"   self-check against {config}.fcm: {good} agree, {bad} DISAGREE"
          + ("" if not bad else "  <-- parse error, do not use"))

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
