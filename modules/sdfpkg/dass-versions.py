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


def main():
    config = "SSW"
    halstat = DEFAULT_HALSTAT
    mafgen = DEFAULT_MAFGEN
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

    revisedUnits = {}
    for csect in index:
        stem = unitOf(csect)
        theirs = revisions.get(stem)
        if theirs is None:
            continue
        ours = None
        for d in ("APPLSRC", "SSSRC"):
            p = Path(d) / f"{stem}.hal"
            if p.is_file():
                ours = sourceRevision(p)
                break
        if ours is not None and theirs > ours:
            revisedUnits[csect] = (stem, ours, theirs)

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

    def owner(address):
        '''The CSECT containing an address, or None.  Containment only -- no
        nearest-preceding fallback, which attributed a difference to a CSECT
        4000 halfwords away and produced deltas of 18396 and 55948.'''
        i = bisect.bisect_right(starts, address) - 1
        while i >= 0 and spans[i][0] <= address:
            if address <= spans[i][1]:
                return spans[i][2]
            i -= 1
        return None

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
            f.write(f"\n# Differences attributable to the source being OI-34.06 "
                    f"where the dump is OI-34.07.\n"
                    f"# Value -1: ignore the address, no claim about its "
                    f"contents.  The evidence is the unit's\n"
                    f"# revision level, which is per file; see "
                    f"dass-versions.py.\n")
            for address, name in sorted(entries):
                f.write(f"{address:05X} -1 {name}\n")

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
