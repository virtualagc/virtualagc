#!/usr/bin/env python3
'''Re-emit an AP-101 object module carrying only the control sections a
configuration actually loads.

WHY THIS EXISTS.  A full-configuration link is fed every compiled HAL/S object,
and some of those objects hold an OVERLAY the configuration does not load.
Linking them anyway writes the overlay body on top of resident code: in
OI340600's GNC9, twelve addresses carried more than one section --  #DDPLLIG
landed on #DDG9LIG at 0005A2, #CDCDDG2/3/8 on FIOSRBPG at 01DDCC, and #CDCDDG1
on FIOPDG9 at 01DE62.  Whichever object linked last won the bytes.

OBJECT GRANULARITY CANNOT EXPRESS THE ANSWER, which is why this works on
sections.  The typical object is MIXED:

    DPLLIGHT.obj    1 ER #PCDLANN
                    2 SD #CDPLLIG   146 bytes    the overlay's code   -- out
                    3 SD #ZDPLLIG     4 bytes    the resident ZCON    -- IN
                    4 SD #DDPLLIG    84 bytes    the overlay's data   -- out
                    5 LD TFCMPFD2 @68 in 4
                    6 LD TFCMPFD1 @60 in 4

The configuration keeps the ZCON, which has to point at the overlay, and not
the overlay.  Dropping the whole object stops the overwriting and throws the
ZCON away with it; keeping it does the reverse.  Only a section-level filter
does both, and lnk101 has no option for one -- hence a rewritten deck.

WHAT IS REBUILT AND WHAT IS NOT.  ESD and RLD cards are re-encoded from their
filtered entry lists; TXT, SYM and END cards are copied VERBATIM, byte for
byte, because nothing in them changes.

ESD IDs ARE NEVER RENUMBERED.  TXT, RLD and END all reference sections by ESD
ID, so renumbering would mean rewriting all of them and every mistake would be
silent.  Kept entries keep their original IDs and the ESD cards are emitted in
runs of CONSECUTIVE ids -- EsdRecord stores only the first id per card and the
reader assigns the rest positionally, so a run is the unit that can be encoded.
Gaps between runs are fine: every consumer looks an id up rather than counting.

WHAT ELSE FOLLOWS A DROPPED SECTION OUT:
  - an LD whose owning section (ldid) is dropped;
  - a TXT card addressed to a dropped section;
  - an RLD entry sited in a dropped section (posId), or naming a dropped
    section or LD (relId);
  - an ER left referenced by nothing, so the link does not go looking for a
    library member to satisfy a reference that no longer exists;
  - a " STACK <csect>" control statement whose csect is gone.

Usage:
    obj-sections.py --keep=FILE OBJ... --out-dir=DIR
    obj-sections.py --dass=DASS.ASC OBJ... --out-dir=DIR

--keep names a file of section names, one per line.  --dass reads them from a
DASS listing's memory map instead, which is the same rule dass-syms.py's
`linkInfo: "placement"` mark uses: a section the map names is in the build, one
it does not is not.  An object left with no section at all is not written, and
is reported.
'''

import sys, os, re
from pathlib import Path

sys.path.insert(0, str(Path("~/donschmidt/nsts-sdl-dps/src").expanduser()))
try:
    from ap101Utils.objModule import (ObjectFile, EsdRecord, RldRecord,
                                      EsdType, ControlRecord, EsdRecord as _E)
    from ap101Utils import objModule
except ImportError as e:
    sys.exit(f"cannot import ap101Utils from nsts-sdl-dps/src: {e}")

MEMORY_MAP_SECTION = re.compile(r"^ [0-9A-F]{6}-[0-9A-F]{6}  (\S+)\s+\*\*\*\*")


def memoryMapSections(path):
    '''Sections the DASS listing's memory map places.  The `****` is what
    separates a SECTION line from the field lines of the same shape, and a
    `--------` row is checksum filler rather than a section.'''
    placed = set()
    with open(path, errors="replace") as f:
        for line in f:
            m = MEMORY_MAP_SECTION.match(line)
            if m and not m.group(1).startswith("-"):
                placed.add(m.group(1))
    return placed


def runs(entries):
    '''Split ESD entries into maximal runs of consecutive esdId, then into
    cards of at most EsdRecord.MAX_ENTRIES.  A card records only the first
    id, so a run is the largest thing that can be encoded without renumbering.'''
    out, run = [], []
    for e in entries:
        if run and e.esdId != run[-1].esdId + 1:
            out.append(run)
            run = []
        run.append(e)
    if run:
        out.append(run)
    cards = []
    for r in out:
        for i in range(0, len(r), EsdRecord.MAX_ENTRIES):
            cards.append(r[i:i + EsdRecord.MAX_ENTRIES])
    return cards


def filterModule(module, keep, seq):
    '''Cards for one module, carrying only the sections named in `keep`.
    Returns (cards, keptSectionNames, droppedSectionNames).'''
    dropped, kept = set(), set()
    for e in module.esdEntries:
        if e.type in (EsdType.SD, EsdType.PC, EsdType.CM):
            (kept if e.name.strip() in keep else dropped).add(e.esdId)

    if not dropped:
        return (list(module.records), None, set())

    # An LD goes with its owning section.
    deadLd = {e.esdId for e in module.esdEntries
              if e.type == EsdType.LD and e.ldid in dropped}

    # A relocation SITED in a dropped section goes; one that merely NAMES a
    # dropped section stays, because the site itself survives and still has to
    # be patched.  #ZDPLLIG is the whole reason this matters: the ZCON the
    # configuration keeps is four bytes pointing at #CDPLLIG, the overlay it
    # does NOT keep, and the pointer has to go on saying where that code lives
    # in the configuration that loads it.
    rlds = [r for r in module.relocations if r.posId not in dropped]

    # So a dropped definition that something still names becomes an EXTERNAL
    # REFERENCE of the same name and the same ESD id.  The address then comes
    # from the CSECT table, which publishes it precisely for this case -- and
    # where the table marks the section `linkInfo: "placement"`, it stays
    # unresolved, which is what the original build did.
    externalised = {r.relId for r in rlds} & (dropped | deadLd)
    # An ER nothing references any more is dropped, so the link does not go
    # looking for a library member to satisfy a reference that is gone.
    referenced = {r.relId for r in rlds}
    if module.end is not None:
        referenced.add(getattr(module.end, "esdId", None))

    esd = []
    for e in module.esdEntries:
        if e.esdId in externalised:
            esd.append(objModule.EsdEntry.er(e.esdId, e.name))
            continue
        if e.esdId in dropped or e.esdId in deadLd:
            continue
        if e.type in (EsdType.ER, EsdType.WX) and e.esdId not in referenced:
            continue
        esd.append(e)

    keptNames = {e.name.strip() for e in esd
                 if e.type in (EsdType.SD, EsdType.PC, EsdType.CM)}
    if not keptNames:
        return ([], set(), dropped)

    cards = []
    for group in runs(esd):
        cards.append(objModule.Record.from_image(EsdRecord.encode(group, seq)))
        seq += 1
    # TXT, SYM and END are copied verbatim -- nothing in them changes.
    for rec in module.records:
        cls = type(rec).__name__
        if cls == "TxtRecord":
            if rec.textRecord.esdId not in dropped:
                cards.append(rec)
        elif cls in ("SymRecord", "EndRecord"):
            cards.append(rec)
    if rlds:
        # RLD cards go before END, which the loop above already appended.
        end = cards.pop() if type(cards[-1]).__name__ == "EndRecord" else None
        for i in range(0, len(rlds), RldRecord.MAX_ENTRIES):
            chunk = rlds[i:i + RldRecord.MAX_ENTRIES]
            # to_bytes() writes the full 8-byte form, so clear the
            # continuation bit that the short form would have implied.
            for r in chunk:
                r.flags &= ~1
            cards.append(objModule.Record.from_image(
                RldRecord.encode(chunk, seq)))
            seq += 1
        if end is not None:
            cards.append(end)
    return (cards, keptNames, dropped)


def main():
    keepFile = dass = outDir = None
    objs = []
    for p in sys.argv[1:]:
        if p.startswith("--keep="):
            keepFile = p.partition("=")[2]
        elif p.startswith("--dass="):
            dass = p.partition("=")[2]
        elif p.startswith("--out-dir="):
            outDir = p.partition("=")[2]
        elif p.startswith("--"):
            print(__doc__)
            sys.exit(1)
        else:
            objs.append(p)
    if not objs or outDir is None or (keepFile is None) == (dass is None):
        print(__doc__)
        sys.exit(1)

    keep = (set(l.strip() for l in open(keepFile) if l.strip())
            if keepFile else memoryMapSections(dass))
    print(f"{len(keep)} section name(s) kept")

    os.makedirs(outDir, exist_ok=True)
    nUnchanged = nRewritten = nEmpty = 0
    droppedNames = []
    for path in objs:
        of = ObjectFile(path)
        out, changed, empty = [], False, True
        seq = 1
        for module in of.modules:
            cards, keptNames, dropped = filterModule(module, keep, seq)
            seq += 200
            if keptNames is not None:
                changed = True
                for e in module.esdEntries:
                    if (e.type in (EsdType.SD, EsdType.PC, EsdType.CM)
                            and e.esdId in dropped):
                        droppedNames.append((Path(path).name, e.name.strip()))
            if cards:
                empty = False
            out.extend(cards)
        # Control statements belong to no module; keep one only if the csect
        # it names survived.
        for c in of.controlStatements:
            parts = c.text.split()
            if len(parts) >= 2 and parts[0] == "STACK" and parts[1] not in keep:
                continue
            out.append(c)
        if empty:
            nEmpty += 1
            print(f"   {Path(path).name}: no section survives, not written")
            continue
        if changed:
            nRewritten += 1
        else:
            nUnchanged += 1
        with open(Path(outDir) / Path(path).name, "wb") as f:
            for rec in out:
                f.write(bytes(rec.image))

    print(f"{nUnchanged} object(s) copied unchanged, {nRewritten} rewritten, "
          f"{nEmpty} dropped entirely -> {outDir}")
    if droppedNames:
        print(f"{len(droppedNames)} section(s) removed:")
        for name, sect in droppedNames:
            print(f"   {name:16} {sect}")


if __name__ == "__main__":
    main()
