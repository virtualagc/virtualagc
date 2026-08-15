#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-versions.py
Purpose:    Record, as no-claim exceptions, the differences attributable to the
            source being a release older than the memory dumps.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-versions.py --config=SSW --link-dir=work
                             [--exceptions=BASE.txt] [--out=F.txt] [--report]

WHAT WE ARE COMPARING.  PFS/OI340600 is OI-34.06.  The MAFGEN listings say
"AT RELEASE 034    VERSION 070", so the memory images are OI-34.07.  Source is
said to be identical across OI-34.xx with only post-build patches differing,
and that is very nearly true but not quite.

It can be measured, because HALSTAT records each unit's revision level (RVL)
and every card of our source carries a two-letter revision code in columns
79-80.  Over SSW's 137 HAL/S files:

    at the SAME revision as the OI-34.07 build:  21 files, 0 differ
    at a LATER revision in the OI-34.07 build:  116 files, 6 differ

So a revision bump changes what we can see about 5% of the time -- and every
file that differs is one the later release revised.  Not one same-revision file
gives any trouble.

WHY -1 AND NOT A VALUE.  fcmcmp's exceptions file normally carries the value a
location is expected to hold, and checks it: that is what stops the mechanism
from being a way to silence anything inconvenient.  A version difference cannot
be stated that way honestly.  We do not know what OI-34.07's source said, only
that it was revised, so writing the dump's own value into the file would
"verify" trivially and would be claiming knowledge we do not have.

-1 says exactly what is true: ignore this address, a difference here is
expected because the unit was revised between our source and the dump, and
nothing is asserted about the contents.  The evidence is per FILE -- a revision
level -- so the claim made here is per file too; the addresses are only how it
is expressed to a tool that works in addresses.

WHAT THIS DOES NOT COVER.  A unit at the same revision gets no entries, however
much it differs, because there would be no justification for them.  If a
revised unit later turns out to differ for a reason of ours as well, these
entries would hide it -- so the report names every unit and revision gap it
acted on, and the count is small enough to re-examine by hand.
'''

import sys
import os
import re
import json
import bisect
import struct
import collections
from pathlib import Path

DEFAULT_HALSTAT = Path("~/workspace/PFS/HALSTAT.ASC").expanduser()
DEFAULT_MAFGEN = Path("~/workspace/PFS/mafgen").expanduser()

UNIT_RE = re.compile(r"S T A T I S T I C S   F O R   U N I T   (\S+)")
TITLE_RE = re.compile(r"^\s*TITLE:\s+\S+?\.(?:SS|APPL)\.SRC\((\S+?)\)RVL=(\S+)")
REVISION_RE = re.compile(r"[A-Z]{2}")
FILL = {0xC9FB, 0xC6C6}


def halstatRevisions(path):
    '''source file stem -> the revision level of the unit in the dumped build.'''
    revisions = {}
    unit = None
    for line in open(path, errors="replace"):
        m = UNIT_RE.search(line)
        if m:
            unit = m.group(1)
            continue
        m = TITLE_RE.match(line)
        if m and unit:
            revisions.setdefault(m.group(1), m.group(2))
    return revisions


CSECT_ROW_RE = re.compile(
    r"\(CSECT: (\S+) OFFSET: ([0-9A-F]+)\) SIZE: \d+\((\d+)\)")


def halstatExtents(path):
    '''CSECT -> the number of halfwords the compiler assigned to it.

    HALSTAT records an offset and size for every item it placed, so the
    largest offset+size is the CSECT's true extent.  MAFGEN's index gives only
    the part of the CSECT its disassembly walked, which understates several
    COMPOOLs badly -- #PCPGSPL's references run 4000 halfwords past its index
    entry.  Using this in place of a proximity guess keeps the attribution on
    primary evidence.
    '''
    extents = collections.Counter()
    for line in open(path, errors="replace"):
        m = CSECT_ROW_RE.search(line)
        if m:
            reach = int(m.group(2), 16) + int(m.group(3))
            if reach > extents[m.group(1)]:
                extents[m.group(1)] = reach
    return extents


def sourceRevision(path):
    '''The highest revision code in a source file: columns 79-80 of each card.'''
    best = None
    for line in open(path, errors="replace"):
        line = line.rstrip("\n")
        if len(line) >= 80:
            code = line[78:80]
            if REVISION_RE.fullmatch(code) and (best is None or code > best):
                best = code
    return best


# A MAFGEN instruction line, which resolves the operand for us:
#
#  010C16    $0SPSPSP+0136   A1B6   00A859   ZH   X'002D'(R2)   CSPB_GCIL_CMD_SENT
#  ^address                  ^value ^effective    ^operand      ^what it names
#
# The effective address is the discriminator this file needs and cannot get any
# other way.  lnk101's RLDs cover only relocated halfwords; a base-register
# reference into a COMPOOL needs no relocation, so nothing in the object file
# says what it points at -- but the disassembly says outright.
#
# A two-halfword instruction prints both halfwords and covers an address range:
#
#  010D48-010D49  A6SPSPSP+0040  B2B6 0001  00A859  SB  X'002D'(R2),1  CSPB_...
#  010CE8-010CE9  A5SPSPSP+002A  68F6 A02E  00A85A  DE  F0,X'002E'(R5,R2) ? #PCSPCLB+108
#
# Both halfwords are recorded, because the differing one is often the second --
# where the whole halfword is operand data rather than opcode.  A '?' in the
# name column means MAFGEN resolved the address but had no symbol for it; the
# effective address is still good, so it is kept with no name.
# EQU pseudo-lines carry no value at all and do not match.
DASS_OPERAND = re.compile(
    r"^\s*([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+\S+\s+"
    r"([0-9A-F]{4})(?:\s+([0-9A-F]{4}))?\s+([0-9A-F]{6})\s+(\S+)\s+(\S+)\s*(\S*)")


def parseDassOperands(path):
    '''halfword address -> (value MAFGEN read there, effective address, what it
    names, whether this is a continuation halfword).  The value is kept so the
    caller can insist the listing and the image agree before believing the
    resolution.'''
    out = {}
    for line in open(path, errors="replace"):
        m = DASS_OPERAND.match(line)
        if not m:
            continue
        first, last, v0, v1, effective, _mnem, _operand, names = m.groups()
        if names == "?":
            names = None
        effective = int(effective, 16)
        out[int(first, 16)] = (int(v0, 16), effective, names, False)
        if last is not None and v1 is not None:
            out[int(last, 16)] = (int(v1, 16), effective, names, True)
    return out


def main():
    config = "SSW"
    halstat = DEFAULT_HALSTAT
    mafgen = DEFAULT_MAFGEN
    dassPath = None
    linkDir = "work"
    baseExceptions = None
    out = None
    report = False
    for p in sys.argv[1:]:
        if p.startswith("--config="):
            config = p.partition("=")[2]
        elif p.startswith("--halstat="):
            halstat = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--mafgen="):
            mafgen = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--dass="):
            dassPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--link-dir="):
            linkDir = p.partition("=")[2]
        elif p.startswith("--exceptions="):
            baseExceptions = p.partition("=")[2]
        elif p.startswith("--out="):
            out = p.partition("=")[2]
        elif p == "--report":
            report = True
        else:
            print(__doc__)
            sys.exit(1)
    if out is None:
        out = f"exceptions-{config}-with-versions.txt"

    # SSW's listing is DASS_SSW_(PostIPL).ASC, so glob rather than assume.
    if dassPath is None:
        candidates = sorted(mafgen.glob(f"DASS_{config}.ASC")) \
                     or sorted(mafgen.glob(f"DASS_{config}_*.ASC"))
        dassPath = candidates[0] if candidates else None
    dass = parseDassOperands(dassPath) if dassPath else {}
    if dassPath:
        print(f"{config}: {len(dass)} resolved operand(s) from {dassPath.name}")
    else:
        print(f"{config}: no DASS listing found; operand resolution disabled")

    revisions = halstatRevisions(halstat)
    # Only CSECTs this configuration really contains.  A module also
    # contributes sections that live in another configuration's overlay; those
    # get placed at their foreign address and compared against unrelated
    # memory, which is noise excluded from the scoring elsewhere and must not
    # be recorded here either -- doing so added entries for four units that
    # match perfectly.
    index = json.load(open(mafgen / f"csects-{config}.json"))
    reference = open(mafgen / f"{config}.fcm", "rb").read()
    patched = Path(f"{config}.literals.fcm")
    if patched.is_file():
        reference = open(patched, "rb").read()

    def halfword(image, address):
        byte = address * 2
        return struct.unpack_from(">H", image, byte)[0] \
               if byte + 1 < len(image) else None

    already = set()
    lines = []
    if baseExceptions:
        for line in open(baseExceptions):
            lines.append(line.rstrip("\n"))
            text = line.split("#", 1)[0].split()
            if text:
                already.add(int(text[0], 16))

    # Which unit was revised, for the CSECTs of this configuration.  A CSECT
    # name is the descored unit name truncated to six characters, so the map is
    # from CSECT to the source stem, and only where the stem is unambiguous.
    def unitOf(csect):
        body = csect[2:] if csect[:1] in "#$@" else csect
        return body

    def revisionOf(csect):
        '''(stem, our revision, the build's) if the build revised this unit
        since our source, else None.  Works for a CSECT this configuration does
        not contain, which matters because an unresolved relocation names one.'''
        stem = unitOf(csect)
        theirs = revisions.get(stem)
        if theirs is None:
            return None
        ours = None
        for d in ("APPLSRC", "SSSRC"):
            p = Path(d) / f"{stem}.hal"
            if p.is_file():
                ours = sourceRevision(p)
                break
        return (stem, ours, theirs) if ours is not None and theirs > ours \
               else None

    revisedUnits = {}
    for csect in index:
        r = revisionOf(csect)
        if r is not None:
            revisedUnits[csect] = r

    # Sizes from HALSTAT's own offset table, for bounding an offset into a
    # CSECT this configuration does not contain.
    halstatRows = halstatExtents(halstat)

    # A CSECT's extent, widened by HALSTAT's own offset table where it reaches
    # past the index entry.  MAFGEN labels only the part of a CSECT it walked,
    # so the index understates several COMPOOLs; HALSTAT records every offset
    # the compiler assigned, which is primary evidence rather than a guess at
    # how far a CSECT "probably" runs.
    extents = {}
    for csect, entry in index.items():
        extents[csect] = [entry["start"], entry["end"]]
    for csect, rows in halstatExtents(halstat).items():
        if csect in extents:
            base = extents[csect][0]
            reach = base + rows - 1
            if reach > extents[csect][1]:
                extents[csect][1] = reach
    spans = sorted((s, e, k) for k, (s, e) in extents.items())
    starts = [s for s, _, _ in spans]
    widest = max((e - s for s, e, _ in spans), default=0)

    def owner(address):
        '''The narrowest CSECT containing an address, or None.

        Containment only -- no nearest-preceding fallback, which attributed a
        difference to a CSECT 4000 halfwords away and produced deltas of 18396
        and 55948.

        Narrowest, because spans genuinely nest: a COMPOOL whose storage is
        owned by an assembly module has no CSECT of its own and lives inside
        the assembly CSECT that contains it, which is the whole reason
        dass-syms.py exists.  Returning the first match found scanning back
        from the address returns whichever span happens to start latest, and
        where two overlap without nesting -- S2 has #PCVTTCS at 0xBE1A-0xD718
        across #PCSAPDT at 0xB040-0xC6BB -- that is the wrong one.  The
        narrowest is the most specific claim about what the address belongs to.
        '''
        best = None
        i = bisect.bisect_right(starts, address) - 1
        while i >= 0 and spans[i][0] >= address - widest:
            s, e, k = spans[i]
            if address <= e and (best is None or e - s < best[0]):
                best = (e - s, k)
            i -= 1
        return None if best is None else best[1]

    entries = []
    acted = []
    referenced = collections.Counter()
    for f in sorted(Path(linkDir).glob("*.json")):
        if f.name.endswith(".repro.json"):
            continue
        stem = f.name[:-5]
        theirs = revisions.get(stem)
        ours = None
        for d in ("APPLSRC", "SSSRC"):
            p = Path(d) / f"{stem}.hal"
            if p.is_file():
                ours = sourceRevision(p)
                break
        selfRevised = (ours is not None and theirs is not None
                       and theirs > ours)
        try:
            symbols = json.load(open(f))
            image = open(f.with_suffix(".fcm"), "rb").read()
        except Exception:
            continue

        # Where lnk101 resolved a relocation, it says outright which CSECT the
        # halfword points at and what address it resolved to.  That is primary
        # evidence and beats inferring the target from the value: a ZCON's HW0
        # is sector-encoded, so owner() on the raw halfword lands somewhere
        # else entirely -- S2's references to #PCSASAT read 9148, which
        # decodes to 0x31148 but looks up as FIOCBLKS, an FCOS CSECT with no
        # revision level and nothing to say.  The difference between what
        # lnk101 wrote and what it resolved to is exactly that decoding, so
        # applying it to the dump's halfword puts both on the same footing
        # without reimplementing the sector rules here.
        relocated = {}
        for r in symbols.get("relocations") or []:
            if r.get("targetName") and "target" in r:
                relocated[r["address"]] = (r["targetName"], r["target"])

        # An UNRESOLVED relocation is evidence too, and of an unusually direct
        # kind.  lnk101 leaves the addend in place, so the halfword holds a bare
        # offset into the named symbol -- and where the original build could not
        # resolve it either, the dump holds the build's offset into the same
        # symbol.  Both sides are then offsets into one CSECT, and any
        # difference between them IS the layout change.
        #
        # G9's #PCSDMD1 is the case: 24 halfwords, every one an unresolved
        # reference to #PCSAPDT, whose CSA_PDT the build revised CC->CD.  The
        # differences are 0x31A, 0x330, 0x329 and 0xC1, and all four appear in
        # the name-matched offset comparison between our SDF and HALSTAT as
        # shifts that revision really produced.  Nothing else could see this:
        # the values are offsets, not addresses, so owner() reads them as
        # pointers into whatever happens to live at 0x15B8 and 0x129E -- in G9,
        # @0ARBIDL and #DVKISAC, two unrelated modules.
        unresolvedAt = {}
        for r in symbols.get("unresolvedRelocations") or []:
            unresolvedAt[r["imageOffsetHW"]] = r["symbol"]
        n = 0
        for section in symbols.get("sections", []):
            if section.get("module") in ("<external-syms>",):
                continue
            if section.get("name") not in index:
                continue
            for i in range(section.get("size", 0)):
                address = section["address"] + i
                if address in already:
                    continue
                a, b = halfword(image, address), halfword(reference, address)
                if a is None or b is None or a == b or b in FILL:
                    continue
                if selfRevised:
                    entries.append((address,
                                    f"{stem}-revised-{ours}-to-{theirs}"))
                    already.add(address)
                    n += 1
                    continue
                # This unit is at the build's own revision, but a unit it
                # REFERENCES was revised, and the revision moved the variable
                # within it.  Both halfwords must resolve into the SAME CSECT:
                # that is the layout-shift signature, and it is much narrower
                # than "the value looks like an address into a revised unit",
                # which any coincidence could satisfy.
                if address in unresolvedAt:
                    sym = unresolvedAt[address]
                    rev = revisionOf(sym)
                    size = halstatRows.get(sym)
                    # Both halfwords must be offsets the symbol could really
                    # hold.  Without the bound this would accept any difference
                    # at an unresolved site, which is far too much.
                    if rev is not None and size and a < size and b < size:
                        tstem, tours, ttheirs = rev
                        entries.append(
                            (address,
                             f"{stem}-references-{sym}"
                             f"-revised-{tours}-to-{ttheirs}"))
                        already.add(address)
                        referenced[(stem, tstem, tours, ttheirs)] += 1
                        continue

                named = None
                if address in dass:
                    value, effective, symbol, continuation = dass[address]
                    # The listing must agree with the image about what is at
                    # this address before its resolution is worth anything.
                    ok = value == b
                    # On the first halfword the operand shares the halfword
                    # with the opcode and register, so ours must be the SAME
                    # instruction with a moved operand rather than different
                    # code: opcode byte and register field both have to match.
                    # A continuation halfword is operand data end to end and
                    # has no opcode to compare, so that test does not apply --
                    # G9's 010CE9 is the second halfword of a DE at 010CE8 and
                    # would be refused by it for no reason.
                    if ok and not continuation:
                        ok = a >> 8 == b >> 8 and a & 3 == b & 3
                    if ok:
                        named = (owner(effective), symbol)

                if named is not None and named[0] in revisedUnits:
                    target, symbol = named
                    tstem, tours, ttheirs = revisedUnits[target]
                    entries.append(
                        (address,
                         f"{stem}-references-{symbol or target}-in-{tstem}"
                         f"-revised-{tours}-to-{ttheirs}"))
                    already.add(address)
                    referenced[(stem, tstem, tours, ttheirs)] += 1
                    continue

                if address in relocated:
                    # lnk101 named the target, so there is nothing to infer for
                    # our side.  Ask only whether the dump's halfword, decoded
                    # the same way, lands in that same CSECT.  Containment must
                    # be judged against the DUMP's extent, which is the build's
                    # own; our copy of a revised COMPOOL is a different size,
                    # and #PCSSSPA's references run 0x305 past where the build
                    # put the same variables in #PCSAPDT.
                    target, resolved = relocated[address]
                    span = extents.get(target)
                    if span is None:
                        continue
                    decoded = b + (resolved - a)
                    if not span[0] <= decoded <= span[1]:
                        continue
                else:
                    target = owner(b)
                    if target is None or target != owner(a):
                        continue
                if target not in revisedUnits:
                    continue
                tstem, tours, ttheirs = revisedUnits[target]
                entries.append(
                    (address,
                     f"{stem}-references-{tstem}-revised-{tours}-to-{ttheirs}"))
                already.add(address)
                referenced[(stem, tstem, tours, ttheirs)] += 1
        if n:
            acted.append((stem, ours, theirs, n))

    with open(out, "w") as f:
        for line in lines:
            f.write(line + "\n")
        if entries:
            # The "-n = text" line is a declaration fcmcmp reads: it prints
            # that text against the count instead of "known discrepancy of
            # type -1".  Older fcmcmp strips comments and simply ignores it,
            # so writing it costs nothing either way.
            f.write(f"\n# Differences attributable to the source being OI-34.06 "
                    f"where the dump is OI-34.07.\n"
                    f"# Value -1: ignore the address, no claim about its "
                    f"contents.  The evidence is the unit's\n"
                    f"# revision level, which is per file; see "
                    f"dass-versions.py.\n"
                    f"# -1 = Probable version-change related difference\n")

        # Suspected defects in the ORIGINAL compiler, from mafgen/defects.txt.
        # These cannot be derived: each is a judgement that our output is right
        # and the dump wrong, made per location on evidence recorded in that
        # file.  Keeping them in a tracked file rather than in this script means
        # the claim can be reviewed; keeping them out of the generated sections
        # means a sweep cannot quietly invent one.
        defects = mafgen / "defects.txt"
        rows = []
        if defects.is_file():
            for line in open(defects, errors="replace"):
                # A comment is a line that STARTS with '#'.  Notes routinely
                # contain '#' as part of a CSECT name -- "#DGO8ORB" -- and
                # treating that as a comment truncated every one of them.
                if line.lstrip().startswith("#"):
                    continue
                fields = line.split()
                if len(fields) >= 3 and fields[0] == config:
                    rows.append((int(fields[1], 16), fields[2],
                                 "-".join(fields[3:])))
        if rows:
            f.write("\n# Suspected defects in the ORIGINAL compiler; see "
                    "mafgen/defects.txt for the evidence.\n"
                    "# -2 = Probable floating-point bug in original compiler\n")
            for address, marker, note in sorted(rows):
                f.write(f"{address:05X} {marker} {note}\n")
            for address, name in sorted(entries):
                f.write(f"{address:05X} -1 {name}\n")

        # Locations the RUNNING system overwrote, from mafgen/runtime-overlay.txt.
        # Not a defect on either side: the source assembles to what the build
        # loaded and the dump was taken after something ran over it.  FIOGPSPG's
        # BCE bypass is the case -- the source labels the very sites "OVERLAID
        # BY BCE BYPASS CODE" -- and MAFGEN does not mark them with '*', so
        # dass-literals.py cannot find them and they have to be curated.
        #
        # A VALUE, NOT A MARKER.  fcmcmp honours one of these only where the
        # dumped image really holds that value and calls the file stale if it
        # does not, so the claim checks itself; a marker could not be caught if
        # it were wrong.  Same format and same reviewability as defects.txt.
        overlay = mafgen / "runtime-overlay.txt"
        orows = []
        if overlay.is_file():
            for line in open(overlay, errors="replace"):
                if line.lstrip().startswith("#"):
                    continue
                fields = line.split()
                if len(fields) >= 3 and fields[0] == config:
                    orows.append((int(fields[1], 16), fields[2],
                                  " ".join(fields[3:])))
        if orows:
            f.write("\n# Locations the running system overwrote; see "
                    "mafgen/runtime-overlay.txt for the evidence.\n")
            for address, value, note in sorted(orows):
                f.write(f"{address:05X} {value} {note}\n")

    print(f"{config}: {len(acted)} unit(s) revised since our source, "
          f"{len(entries)} halfword(s) recorded as no-claim -> {out}")
    for stem, ours, theirs, n in sorted(acted, key=lambda r: -r[3]):
        print(f"   {stem:10s} revision {ours} -> {theirs}   {n:5d} halfword(s)")
    if referenced:
        print(f"   -- and {sum(referenced.values())} halfword(s) in unrevised "
              f"units, referencing a unit that was revised:")
        for (stem, tstem, tours, ttheirs), n in referenced.most_common():
            print(f"   {stem:10s} -> {tstem:8s} revision {tours} -> {ttheirs}"
                  f"   {n:5d} halfword(s)")


if __name__ == "__main__":
    main()
