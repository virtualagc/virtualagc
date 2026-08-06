#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-syms.py
Purpose:    Recover CSECT addresses that unlinkMAFGEN2 could not, from HALSTAT,
            and emit an augmented external-symbol table for lnk101.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-syms.py --config=SSW [--base=F.json] [--out=F.json] [--report]
            --base carries a previous augmented table forward; see main().

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
and each configuration adds overlays on top of it.  Matching each phase's
addresses against each configuration's index gives, approximately: G16 phase 4,
G2 phase 5, G3 phase 6, G8 phase 7, G9 phase 8, P9 phase 12, S2 phases 14 and
15.  Treat that as a rough guide and not as a fact: it is inferred from
agreement counts, several phases serve more than one configuration, and some
phases (16, 18) correspond to configurations we have no dump for at all.
Nothing in this script relies on it -- every address is accepted on direct
evidence, never on a phase label.

The CSECT name usually names the configuration too -- DCDDG1 for G1, DCDDS2 for
S2 -- which is a good sanity check but not a rule: #CDCDDS8 lives in P9's
index, and #CDGNLIG ("GN", generic) is in all five GNC configurations at one
address.  IBM-82-SS-4556 (Programming Standards, Rev 4) section 2.1.1.1 says
why: a block label is ABB_C...C, where only A (the subsystem ID) and BB are
structured, and everything after is "an alphanumeric ID descriptive of the
purpose of the code block" chosen by the programmer.  Downlist units take a DCD
prefix, so DCDDS8 is DCD + the descriptive "DS8" -- the trailing digits are
convention, not a binding to a memory configuration, and there is no S8
configuration at all.

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


# lnk101 prints this for a symbol it cannot resolve and will not tolerate.
# An undefined #P (COMPOOL) is only a warning, but anything else -- notably a
# #E, the process directory entry a SCHEDULE refers to -- fails the link, and a
# failed link leaves no symbol JSON, so the log is the only record of what was
# missing.
# Two wordings: lnk101 errors on an undefined symbol it will not tolerate,
# and warns on an undefined #P COMPOOL, which it links at zero instead.
# Both are worth recovering -- the warning cost DGRGSERO two halfwords
# that were otherwise invisible, because a link that fails on the errors
# never writes the symbol JSON the relocation pass reads.
UNDEFINED_RE = re.compile(r"Undefined (?:symbol|COMPOOL):\s*(\S+?),")


def collectUndefined(logDir):
    """Every symbol lnk101 reported as undefined, from a sweep's logs."""
    out = set()
    for f in sorted(Path(logDir).glob("*.log")):
        for line in open(f, errors="replace"):
            m = UNDEFINED_RE.search(line)
            if m:
                out.add(m.group(1))
    return out


def recoverForeignSymbols(undefined, index, phases, otherConfigs, report):
    """Addresses for symbols this configuration does not contain at all.

    A module can SCHEDULE a program that lives in another configuration's
    overlay.  The reference is to that program's process directory entry, and
    lnk101 treats an undefined #E as fatal -- so the link produces nothing and
    the file drops out of the comparison entirely, which is worse than a
    difference.  Two of SSW's files failed this way, CVJFDECP on seven such
    symbols and DGRGSERO on two.

    Same standard of evidence as everywhere else here: an address is taken only
    where the other configurations' CSECT indexes and HALSTAT agree on it
    independently, and only where every source that has the symbol gives the
    same answer.  All nine of SSW's are unambiguous -- #EV01TCS is in G9 and in
    HALSTAT phase 8, both at 0xE26E, and in no other configuration.
    """
    recovered = {}
    for symbol in sorted(undefined):
        if symbol in index:
            continue
        candidates = {}
        for name, other in (otherConfigs or {}).items():
            e = other.get(symbol)
            if e and "start" in e:
                candidates[f"config {name}"] = (
                    e["start"], e["end"] - e["start"] + 1)
        for phase, d in phases.items():
            if symbol in d:
                candidates[f"HALSTAT phase {phase}"] = d[symbol]
        if not candidates:
            report.append((symbol, "in no other configuration and no HALSTAT phase"))
            continue
        addresses = {a for a, _n in candidates.values()}
        if len(addresses) != 1:
            report.append((symbol, "sources disagree: "
                           + ", ".join(f"{k}={v[0]:#x}"
                                       for k, v in sorted(candidates.items()))))
            continue
        source = sorted(candidates)[0]
        recovered[symbol] = candidates[source] + (
            f"{source}, {len(candidates)} source(s) agree",)
    return recovered


def sectorDecode(hw, sector):
    '''A 16-bit sector-encoded halfword to an absolute halfword address.  Bit 15
    means "apply the sector register"; otherwise the address is in sector 0.
    The same rule as lnk101's addrcon.sector_decode, reimplemented in three
    lines rather than imported, so this script does not depend on the nsts-sdl-
    dps tree being present.'''
    return ((sector << 15) | (hw & 0x7FFF)) if hw & 0x8000 else hw


def recoverCrossConfigCsects(index, phases, halfword, report, otherConfigs=None):
    '''Addresses of code that lives in a DIFFERENT memory configuration.

    A configuration can carry a module's ZCON without carrying the module.  The
    per-flight-phase variants are all like this in SSW: #ZDCDDG1 is present but
    #CDCDDG1 and #DDCDDG1 are not, because DCDDG1's code belongs to the GNC
    OPS-1 overlay.  The ZCON is a cross-configuration pointer, and it holds the
    address the code has in the configuration where that overlay IS loaded --
    so linking for SSW still needs that foreign address, and without it lnk101
    puts the code at its default 0x10000 and the ZCON comes out wrong.

    A ZCON is two halfwords: HW0 a sector-encoded address, HW1 carrying the
    sector registers (BSR bits 7-4 for code, DSR bits 3-0 for data) among other
    flags.  Decoding the dump's own ZCON therefore yields the code address the
    original build used, and that is the discriminator: a HALSTAT candidate is
    accepted only when it equals what the dump decodes to.  Over SSW's 18 such
    ZCONs, 15 have a HALSTAT entry and all 15 agree exactly -- #ZDCDDG1 decodes
    to 0x1DE62 and HALSTAT's phase 4 gives #CDCDDG1 at 0x1DE62, and so on
    through phases 5, 7, 8, 12, 15, 16 and 18.  The other three are absent from
    HALSTAT altogether and are left alone.

    Both #C and #D are supplied, from the same phase.  #C alone is not enough:
    it fixes HW0 but leaves HW1's sector fields wrong, so the ZCON still
    differs by one halfword.
    '''
    recovered = {}
    for name, entry in index.items():
        if entry.get("type") != "ZCON" or "start" not in entry:
            continue
        base = name[2:]
        code, data = "#C" + base, "#D" + base
        if code in index:               # the module is in this configuration
            continue
        hw0 = halfword(entry["start"])
        hw1 = halfword(entry["start"] + 1)
        if hw0 is None or hw1 is None:
            continue
        target = sectorDecode(hw0, (hw1 >> 4) & 0xF)

        # Candidate sources, best first.  Another configuration's own CSECT
        # index beats HALSTAT: it is the same unlinkMAFGEN2 scrape we already
        # trust for this configuration, it carries the size, and it covers
        # cases HALSTAT misses -- #CDCDDG3 and #CDKFCM9 appear in no HALSTAT
        # phase at all, but sit in the G3 and G9 indexes at exactly the address
        # SSW's own ZCON decodes to.  HALSTAT is the fallback, and it earns its
        # place: #CDCDDS4 is in none of the eight configurations we have dumps
        # for, and only HALSTAT has it.
        #
        # The CSECT name usually says which configuration it belongs to -- G1,
        # G2, G3, G8, G9, S2 -- and that is a useful sanity check, but it is
        # NOT the discriminator and is not relied on here.  It does not always
        # hold: #CDCDDS8 lives in P9's index, and #CDGNLIG ("GN", generic) is
        # in all five GNC configurations at one address.  What decides is the
        # address the dump's own ZCON decodes to.
        found = None
        for cfgName, cfgIndex in (otherConfigs or {}).items():
            entry2 = cfgIndex.get(code)
            if entry2 and entry2.get("start") == target:
                found = (f"config {cfgName}",
                         {c: (cfgIndex[c]["start"],
                              cfgIndex[c]["end"] - cfgIndex[c]["start"] + 1)
                          for c in (code, data) if c in cfgIndex})
                break
        if found is None:
            hits = [p for p in phases
                    if code in phases[p] and phases[p][code][0] == target]
            if len(hits) == 1:
                found = (f"HALSTAT phase {hits[0]}",
                         {c: phases[hits[0]][c]
                          for c in (code, data) if c in phases[hits[0]]})
        if found is None:
            report.append((name, f"decodes to {target:#07x}, "
                                 f"no configuration or HALSTAT phase has "
                                 f"{code} there"))
            continue
        source, addresses = found
        for csect, (a, n) in addresses.items():
            if csect not in index:
                recovered[csect] = (a, n, source, target)
    return recovered


def main():
    config = "SSW"
    halstat = DEFAULT_HALSTAT
    mafgen = DEFAULT_MAFGEN
    linkDir = "work"
    logDir = "logs"
    base = None
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
        elif p.startswith("--log-dir="):
            logDir = p.partition("=")[2]
        elif p.startswith("--base="):
            base = p.partition("=")[2]
        elif p.startswith("--out="):
            out = p.partition("=")[2]
        elif p == "--report":
            report = True
        else:
            print(__doc__)
            sys.exit(1)
    if out is None:
        out = f"csects-{config}-augmented.json"

    # The relocation-evidence pass can only see a symbol that was unresolved in
    # the sweep it reads, so re-running it against a sweep that already had the
    # augmented table finds nothing and would silently drop what the first run
    # recovered.  --base carries a previous result forward.  (The
    # cross-configuration pass below has no such dependency: it works from the
    # index and the dump, so it is reproducible from scratch every time.)
    index = json.load(open(mafgen / f"csects-{config}.json"))
    if base is not None:
        previous = json.load(open(base))
        for name, entry in previous.items():
            if name not in index:
                index[name] = entry
        print(f"carried {len(index) - len(json.load(open(mafgen / f'csects-{config}.json')))} "
              f"entries forward from {base}")
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

    # The other configurations' own indexes, used by both passes below.
    others = {}
    for f in sorted(Path(mafgen).glob("csects-*.json")):
        name = f.stem[len("csects-"):]
        if name != config:
            try:
                others[name] = json.load(open(f))
            except Exception:
                pass

    # Second class: symbols this configuration does not contain at all, which
    # lnk101 will not tolerate for anything but a COMPOOL.  Read from the sweep
    # LOGS rather than the symbol JSONs, because a link that fails this way
    # produces no JSON at all.
    foreignReport = []
    foreign = recoverForeignSymbols(collectUndefined(logDir), index, phases,
                                    others, foreignReport)
    for symbol, (address, n, why) in foreign.items():
        augmented[symbol] = {"start": address, "end": address + n - 1,
                             "type": "HALSTAT", "hal": None}

    # Third class: code that lives in another configuration but whose ZCON is
    # carried here.  Independent of the evidence above, so it works from the
    # index and the dump rather than from lnk101's output.
    zconReport = []
    crossConfig = recoverCrossConfigCsects(index, phases, halfword, zconReport,
                                           others)
    for symbol, (address, n, phase, target) in crossConfig.items():
        augmented[symbol] = {"start": address, "end": address + n - 1,
                             "type": "HALSTAT", "hal": None}
    json.dump(augmented, open(out, "w"))

    print(f"{config}: {len(index)} CSECTs in the index, "
          f"{len(seen)} symbols unresolved by lnk101, "
          f"{len(accepted)} recovered from relocation evidence, "
          f"{len(crossConfig)} from cross-configuration ZCONs, "
          f"{len(foreign)} symbols absent from this configuration -> {out}")
    if report:
        print("\nACCEPTED, from lnk101's unresolved relocations")
        for s, (a, p, why) in sorted(accepted.items()):
            print(f"   {s:10s} {a:#07x}  phase {str(p):<3s} {why}")
        print("\nACCEPTED, from cross-configuration ZCONs")
        for s, (a, n, p, t) in sorted(crossConfig.items()):
            print(f"   {s:10s} {a:#07x}  size {n:5d}  "
                  f"ZCON decodes to {t:#07x}  from {p}")
        print("\nACCEPTED, symbols absent from this configuration")
        for sym, (a_, n_, why) in sorted(foreign.items()):
            print(f"   {sym:10s} {a_:#07x}  size {n_:5d}  {why}")
        print("\nLEFT UNRESOLVED")
        for sym, why in foreignReport:
            print(f"   {sym:10s}   absent  {why}")
        for s, n, why in rejected:
            print(f"   {s:10s} {n:5d} refs  {why}")
        for s, why in zconReport:
            print(f"   {s:10s}       ZCON  {why}")


if __name__ == "__main__":
    main()
