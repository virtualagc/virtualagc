#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   halstat-sizes.py
Purpose:    Check a section whose size differs from the CSECT table against
            what the ORIGINAL compiler said that section's size was.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      halstat-sizes.py --config=S2 FCMCMP-REPORT.txt
                             [--halstat=F] [--mafgen=D] [--dass=F]

WHY THE MEMORY MAP IS NOT ENOUGH.  fcmcmp ends a run with the sections whose
size differs from the CSECT table, and the table's sizes come from MAFGEN's
memory map.  Reading a small map entry as "the build declared less than we do"
assumes the map states a size rather than a stub, and the map does carry
annotations -- INCLUDE REMOTE, DATA REMOTE -- that look like they might mean
the storage is somewhere else.  They do not settle it: S2's #PCSASAT is marked
INCLUDE REMOTE and its 3508 halfwords are within 218 of ours.

WHAT DOES SETTLE IT.  HALSTAT prints a CSECT INFORMATION table for every unit,
one row per PHASE, each row a list of CSECT-class/address/size triples.  That
is the compiler's own statement about what it emitted, made before the linker
placed anything, so it is independent of the map.

    A UNIT IS COMPILED ONCE PER PHASE AND MAY COME OUT A DIFFERENT SIZE IN
    EACH, so a size means nothing until the phase is pinned.  CVN_MM_UTILITY
    is 16393 halfwords in phase 2, 4105 in phase 8 and 13321 in phase 14.  The
    ADDRESS pins it: the phase whose address matches where this configuration's
    map places the section is the compilation this configuration loaded.

TWO THINGS THE FORMAT WILL DO TO A READER THAT ASSUMES OTHERWISE.  Column 1 of
HALSTAT is CARRIAGE CONTROL, so a row can read `0PHASE 15:` with no space.  And
a phase row lists every CSECT CLASS the unit emitted -- #C code, #D data, #Z
the ZCON, #X, A1 -- while only one of them carries the unit's name in the
COMPILATION LAYOUT line, so a remote data half like #DPGPPLD is reachable by
address and by nothing else.

Measured 2026-08-14 over the three configurations under comparison: 35 of 35
oversized sections in S2, 5 of 5 undersized, 6 of 6 in G9 and the one section
SSW's map places -- every one CONFIRMED.  SSW's other four size rows are
sections its map never places at all.
'''

import os
import re
import sys
from pathlib import Path

DEFAULT_HALSTAT = Path("~/workspace/PFS/HALSTAT.ASC").expanduser()
DEFAULT_MAFGEN = Path("~/workspace/PFS/mafgen").expanduser()
SRCDIRS = ["APPLSRC", "SSSRC"]

UNIT = re.compile(r"S T A T I S T I C S   F O R   U N I T   (\S+)")
TITLE = re.compile(r"^\s*TITLE:\s+\S+?\.(?:SS|APPL)\.SRC\((\S+?)\)RVL=(\S+)")
LAYOUT = re.compile(r"^[01+\- ]?\s*\((#\S+)\)\s")
PHASE = re.compile(r"^[01+\- ]?\s*PHASE\s+(\d+):\s+(.*)$")
TRIPLE = re.compile(r"#?\S{1,2}\s+([0-9A-F]{6})\s+(\d+)")
MAPENTRY = re.compile(r"^\s*([0-9A-F]{6})-([0-9A-F]{6})\s+(\S+)\s+\*+\s+"
                      r"[0-9A-F]{4}\(\s*(\d+)\)")
SIZEROW = re.compile(r"^\s*(\S+): (\d+) halfwords, table says (\d+) "
                     r"\(([-+]\d+)\)")


def readHalstat(path):
    '''-> (CSECT -> unit, unit -> (stem, rvl), unit -> {addr: (phase, size)},
           address -> [(unit, phase, size)])

    AN ADDRESS IS NOT A KEY BY ITSELF and using it as one gets wrong answers
    quietly.  Different phases lay different units down at the same place --
    S2's #PCVNMMU at 020022 is also where AIG_DEU_LOADER's phase 2 put 610
    halfwords -- so the unit named in the COMPILATION LAYOUT line decides
    first, and the address is only the fallback for the CSECT classes that
    line never names.
    '''
    unit = None
    csect, title, phases, byAddress = {}, {}, {}, {}
    for line in open(path, errors="replace"):
        m = UNIT.search(line)
        if m:
            unit = m.group(1)
            continue
        if unit is None:
            continue
        m = TITLE.match(line)
        if m:
            title.setdefault(unit, (m.group(1), m.group(2)))
            continue
        m = LAYOUT.match(line)
        if m:
            csect.setdefault(m.group(1), unit)
            continue
        m = PHASE.match(line)
        if m:
            for addr, size in TRIPLE.findall(m.group(2)):
                row = (unit, int(m.group(1)), int(size))
                phases.setdefault(unit, {})[int(addr, 16)] = row[1:]
                byAddress.setdefault(int(addr, 16), []).append(row)
    return csect, title, phases, byAddress


def sourceRevision(stem, work):
    '''The highest revision code in our copy of the unit, columns 79-80.'''
    for d in SRCDIRS:
        p = Path(work) / d / (stem + ".hal")
        if p.is_file():
            best = None
            for line in open(p, errors="replace"):
                r = line.rstrip("\n")[78:80]
                if re.fullmatch("[A-Z]{2}", r) and (best is None or r > best):
                    best = r
            return best
    return None


def main():
    config = None
    halstat = DEFAULT_HALSTAT
    mafgen = DEFAULT_MAFGEN
    dassPath = None
    work = Path("~/workspace/PFS/OI340600").expanduser()
    report = None
    for p in sys.argv[1:]:
        if p.startswith("--config="):
            config = p.partition("=")[2]
        elif p.startswith("--halstat="):
            halstat = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--mafgen="):
            mafgen = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--dass="):
            dassPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--work="):
            work = Path(p.partition("=")[2]).expanduser()
        elif not p.startswith("-") and report is None:
            report = p
        else:
            print(__doc__)
            sys.exit(1)
    if report is None or (config is None and dassPath is None):
        print(__doc__)
        sys.exit(1)

    if dassPath is None:
        candidates = sorted(mafgen.glob(f"DASS_{config}.ASC")) \
                     or sorted(mafgen.glob(f"DASS_{config}_*.ASC"))
        if not candidates:
            sys.exit(f"no DASS listing for {config} in {mafgen}")
        dassPath = candidates[0]

    csect, title, phases, byAddress = readHalstat(halstat)

    placed = {}
    for line in open(dassPath, errors="replace"):
        m = MAPENTRY.match(line)
        if m:
            placed.setdefault(m.group(3), (int(m.group(1), 16),
                                           int(m.group(4)),
                                           "INCLUDE REMOTE" in line
                                           or "DATA REMOTE" in line))

    rows = [m.groups() for m in
            (SIZEROW.match(l) for l in open(report, errors="replace")) if m]
    if not rows:
        sys.exit(f"{report}: no 'differ in size from the CSECT table' rows")

    print(f"{'section':10s} {'ours':>6s} {'map':>6s} {'HALSTAT':>7s} {'ph':>3s} "
          f"{'unit':18s} {'bld':3s} {'src':3s} rem verdict")
    confirmed = total = 0
    for name, ours, tab, _ in rows:
        ours, tab = int(ours), int(tab)
        total += 1
        start, mapsize, remote = placed.get(name, (None, None, False))
        if start is None:
            print(f"{name:10s} {ours:6d} {tab:6d} {'-':>7s} {'-':>3s} "
                  f"{'-':18s} {'-':3s} {'-':3s} {'-':3s} "
                  f"the map does not place this section")
            continue
        unit = csect.get(name)
        ph, size = phases.get(unit, {}).get(start, (None, None))
        ambiguous = False
        if size is None:
            here = byAddress.get(start, [])
            if len(here) == 1:
                unit, ph, size = here[0]
            elif here:
                ambiguous = True
        stem, rv = title.get(unit, ("?", "?"))
        if ambiguous:
            verdict = "several units place a CSECT here; unit not named"
        elif size is None:
            verdict = "no phase at this address"
        elif size == mapsize:
            verdict = "map CONFIRMED by compiler"
            confirmed += 1
        else:
            verdict = f"map DISAGREES with compiler ({size})"
        print(f"{name:10s} {ours:6d} {tab:6d} "
              f"{size if size is not None else -1:7d} "
              f"{ph if ph is not None else -1:3d} {unit or '?':18s} {rv:3s} "
              f"{sourceRevision(stem, work) or '?':3s} "
              f"{'R' if remote else '-':3s} {verdict}")
    print(f"\n{confirmed} of {total} size row(s) confirmed by HALSTAT")


if __name__ == "__main__":
    main()
