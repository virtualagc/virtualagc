#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-syms.py
Purpose:    Recover CSECT addresses that unlinkMAFGEN2 could not, from HALSTAT,
            and emit an augmented external-symbol table for lnk101.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-syms.py --config=SSW [--out=F.json] [--report]

THE PROBLEM.  csects-XXX.json is incomplete.  A HAL/S COMPOOL whose storage is
owned by an assembly module has no CSECT of its own in the MAFGEN listing --
the memory is attributed to the assembly CSECT that contains it -- so lnk101
has nothing to resolve the reference to, links it at zero, and every reference
comes out as a bare offset.  Over SSW, 90 external symbols were unresolved this
way and they cost 26 CSECTs, including every differing PROCEDURE.

    #PCDHMMU (COMPOOL CDH_MM_UTILITY) is the type case.  It appears nowhere in
    DASS_SSW_(PostIPL).ASC.  Its storage is at 0xABB8, inside FCMBMTPG, an
    assembly CSECT running 0xA7EE-0xAC81.

THE SOURCE.  PFS/HALSTAT.ASC carries, per compilation unit, a "CSECT
INFORMATION" block giving the address and size of each of that unit's CSECTs in
each memory phase:

    (#PCDHMMU)              CDH_MM_UTILITY:  COMPOOL
             **** C S E C T   I N F O R M A T I O N ****
                  ADDR    SIZE         ADDR    SIZE ...
     PHASE 12:   #P  00ABB8    788
     PHASE 14:   #P  00511A    788

A phase is not a memory configuration.  Phase 2 is the resident portion shared
by every configuration -- all 358 of its CSECTs agree with csects-SSW.json --
and each configuration adds overlays on top of it: G16 takes phase 4, G2 phase
5, G3 phase 6, G8 phase 7, G9 phase 8, P9 phase 12, S2 phases 14 and 15.  So a
unit present in several phases offers several candidate addresses and the phase
alone does not say which one a given configuration uses.

THE DISCRIMINATOR, and why this is not fitting a number to the answer.  lnk101
reports every relocation it could not resolve, with the site and the addend.
Reading the memory dump at that site and subtracting the addend yields the base
the original build must have used -- one equation per reference.  An address is
accepted only when the dump-derived base and a HALSTAT candidate agree
independently.  For #PCDHMMU that is 170 agreeing references out of 184 usable
ones, all giving 0xABB8, which is exactly HALSTAT's phase-12 figure: one
unknown satisfying 170 equations, corroborated by a document that never saw our
compiler.  A symbol offered by exactly one phase and with no contrary dump
evidence is also accepted; anything else is left unresolved and reported.

Being conservative here matters more than coverage.  Of SSW's 90 unresolved
symbols only 9 are accepted, and those 9 fix 26 CSECTs and break none.  Most of
the remaining 81 are compools belonging to other configurations, whose
references in an SSW module point into memory SSW does not contain; their
dump-derived bases do not converge (ratios like 1/57), which is precisely the
signal that there is nothing there to find.
'''

import sys
import os
import re
import json
import struct
import collections
from pathlib import Path

DEFAULT_HALSTAT = Path("~/workspace/PFS/HALSTAT.ASC").expanduser()
DEFAULT_MAFGEN = Path("~/workspace/PFS/mafgen").expanduser()

# Values the dump uses for memory that was never initialised.  A relocation
# site holding one of these tells us nothing, so it gets no vote.
FILL = {0xC9FB, 0xC6C6}

UNIT_RE = re.compile(r"S T A T I S T I C S   F O R   U N I T   (\S+)")
CSECT_INFO = "**** C S E C T   I N F O R M A T I O N ****"
PHASE_RE = re.compile(r"^\s*PHASE\s+(\d+):\s*(.*)$")
# "#P  00ABB8    788", up to five per line, continued on unlabelled lines.
PAIR_RE = re.compile(r"([#$@A-Z][0-9A-Z])\s+([0-9A-F]{6})\s+(\d+)")


def characteristicName(unit):
    '''The six-character name a CSECT is built from: underscores removed, then
    truncated.  PASS2/PROGNAME.xpl does exactly this, and USA003090 section 8.9
    documents it.'''
    return unit.replace("_", "")[:6]


def parseHalstat(path):
    '''phase -> {csect name: (address, size)}.'''
    phases = collections.defaultdict(dict)
    unit = None
    inBlock = False
    phase = None
    for line in open(path, errors="replace"):
        m = UNIT_RE.search(line)
        if m:
            unit, inBlock, phase = m.group(1), False, None
            continue
        if CSECT_INFO in line:
            inBlock = True
            phase = None
            continue
        if not inBlock or unit is None:
            continue
        if "S T M T   F R E Q" in line or "C O M P I L A T I O N   L A Y" in line:
            inBlock = False
            continue
        m = PHASE_RE.match(line)
        if m:
            phase, body = int(m.group(1)), m.group(2)
        elif phase is not None and line.strip() \
                and not line.startswith(("1", "0", "+")) \
                and "CODE:" not in line and "ADDR" not in line:
            body = line          # continuation of the previous PHASE line
        else:
            if "CODE:" in line:
                phase = None
            continue
        for prefix, addr, size in PAIR_RE.findall(body):
            phases[phase][prefix + characteristicName(unit)] = \
                (int(addr, 16), int(size))
    return phases


def collectUnresolved(linkDir):
    '''Every unresolved relocation lnk101 reported, from the symbol JSONs a
    sweep left behind.  Returns [(symbol, halfword address, addend)].'''
    out = []
    for f in sorted(Path(linkDir).glob("*.json")):
        if f.name.endswith(".repro.json"):
            continue
        try:
            sym = json.load(open(f))
        except Exception:
            continue
        for r in sym.get("unresolvedRelocations") or []:
            out.append((r["symbol"], r["imageOffsetHW"], r["existing"]))
    return out


def main():
    config = "SSW"
    halstat = DEFAULT_HALSTAT
    mafgen = DEFAULT_MAFGEN
    linkDir = "work"
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
        elif p.startswith("--out="):
            out = p.partition("=")[2]
        elif p == "--report":
            report = True
        else:
            print(__doc__)
            sys.exit(1)
    if out is None:
        out = f"csects-{config}-augmented.json"

    index = json.load(open(mafgen / f"csects-{config}.json"))
    memory = open(mafgen / f"{config}.fcm", "rb").read()

    def halfword(a):
        return struct.unpack_from(">H", memory, a * 2)[0] \
               if a * 2 + 1 < len(memory) else None

    phases = parseHalstat(halstat)
    relocations = collectUnresolved(linkDir)
    if not relocations:
        print(f"No unresolved relocations found under {linkDir}/.  Run a sweep "
              f"with --out-dir={linkDir} first; this needs lnk101's symbol "
              f"JSONs to know which symbols went unresolved and where.")
        sys.exit(1)

    votes = collections.defaultdict(collections.Counter)
    seen = collections.Counter()
    for symbol, address, addend in relocations:
        seen[symbol] += 1
        v = halfword(address)
        if v is None or v in FILL:
            continue
        votes[symbol][(v - addend) & 0xFFFF] += 1

    sizeOf = {}
    for phase, d in phases.items():
        for name, (a, n) in d.items():
            sizeOf.setdefault((name, a), n)

    accepted = {}
    rejected = []
    for symbol in sorted(seen):
        candidates = {p: phases[p][symbol][0]
                      for p in phases if symbol in phases[p]}
        if votes[symbol]:
            base, n = votes[symbol].most_common(1)[0]
            total = sum(votes[symbol].values())
            # The dump stores an address above 64K in a paged form, so compare
            # the low half and the bit-15 variant as well as the plain value.
            hit = [p for p, a in candidates.items()
                   if base in (a, a & 0xFFFF, (a | 0x8000) & 0xFFFF)]
            if hit and n / total >= 0.6:
                phase = sorted(hit, key=int)[0]
                accepted[symbol] = (candidates[phase], phase,
                                    f"{n}/{total} references agree")
                continue
            rejected.append((symbol, seen[symbol],
                             f"dump-derived {base:#07x} ({n}/{total}) matches "
                             f"no candidate" if candidates
                             else "not in HALSTAT"))
        elif len(candidates) == 1:
            phase = list(candidates)[0]
            accepted[symbol] = (candidates[phase], phase,
                                "sole HALSTAT candidate, no contrary evidence")
        else:
            rejected.append((symbol, seen[symbol],
                             "no usable dump evidence and several candidates"
                             if candidates else "not in HALSTAT"))

    augmented = dict(index)
    for symbol, (address, phase, why) in accepted.items():
        n = sizeOf.get((symbol, address), 1)
        augmented[symbol] = {"start": address, "end": address + n - 1,
                             "type": "HALSTAT", "hal": None}
    json.dump(augmented, open(out, "w"))

    print(f"{config}: {len(index)} CSECTs in the index, "
          f"{len(seen)} symbols unresolved by lnk101, "
          f"{len(accepted)} recovered -> {out}")
    if report:
        print("\nACCEPTED")
        for s, (a, p, why) in sorted(accepted.items()):
            print(f"   {s:10s} {a:#07x}  phase {str(p):<3s} {why}")
        print("\nLEFT UNRESOLVED")
        for s, n, why in rejected:
            print(f"   {s:10s} {n:5d} refs  {why}")


if __name__ == "__main__":
    main()
