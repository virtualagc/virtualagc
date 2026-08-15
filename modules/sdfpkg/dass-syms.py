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
compiler.  Anything else is left unresolved and reported.  There WAS a weaker rule --
accept a symbol offered by exactly one phase, with no dump evidence either way
-- and it has been withdrawn: over SSW it accepted 18 symbols and changed
nothing measurable, and over S2 it supplied a wrong address for #PCSPCLB that
put several CODE sections out by five halfwords.  --sole-candidates restores
it for experiment.

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

# What an address field holds when the build did NOT patch it.  0000 belongs
# here and NOT in FILL above: to the votes pass 0000 is a possible address and
# must not be read as absence, but markFromEvidence is asking the opposite
# question -- did the build write an address here at all -- and there a zero
# address field is the answer "no".  G9's TFCMPFD1 and TFCMPFD2 are 0000 in the
# raw MAFGEN scrape, not C9FB, so the listing states them.
UNPATCHED = {0x0000, 0xC9FB, 0xC6C6}

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
    sweep left behind.  Returns [(symbol, halfword address, addend, section,
    section base as a halfword address)].'''
    out = []
    for f in sorted(Path(linkDir).glob("*.json")):
        if f.name.endswith(".repro.json"):
            continue
        try:
            sym = json.load(open(f))
        except Exception:
            continue
        for r in sym.get("unresolvedRelocations") or []:
            out.append((r["symbol"], r["imageOffsetHW"], r["existing"],
                        (r.get("section") or "").strip(),
                        r["imageOffsetHW"] - r.get("sectionOffset", 0) // 2,
                        r.get("flags", 0)))
    return out


def basesFrom(value, addend, flags, companion=None):
    '''What base addresses a halfword could have been patched from, given the
    RLD flags.  Bit 7 is the sign, so a negative displacement was subtracted
    rather than added; and a ZCON's address halfword is sector-encoded, so bit
    15 may have been set over it.  Returns an empty set for a relocation that
    patches a register field rather than an address -- BSR-only and DSR-only
    touch four bits of an instruction, and reading them as addresses derives
    nonsense (S2 has three that yield 0xFE5A against a real base of 0x7D78).

    `companion` is the halfword after this one.  For a ZCON that is HW1, whose
    low nibble is the DSR and next nibble the BSR, and applying it is the only
    way to reach a base above 64K: S2's #PCSAPXT sits at 0x338C2, which no
    16-bit reading of B8C0 can produce.  Both registers are offered as
    candidates rather than choosing between them by flag type, since the
    exact-CSECT-start test downstream is what decides.'''
    if flags & 0x70 in (0x20, 0x40):
        return set()
    signed = -addend if flags & 0x80 else addend
    out = {(value - signed) & 0xFFFF, ((value & 0x7FFF) - signed) & 0xFFFF}
    if companion is not None and value & 0x8000 and flags & 0x70 in (0x04, 0x10, 0x50):
        for sector in (companion & 0xF, (companion >> 4) & 0xF):
            if sector:
                out.add(((sector << 15) | (value & 0x7FFF)) - signed)
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


def recoverForeignSymbols(undefined, index, phases, otherConfigs, relocations,
                          halfword, report):
    """Addresses for symbols this configuration does not contain at all.

    A module can SCHEDULE a program that lives in another configuration's
    overlay.  The reference is to that program's process directory entry, and
    lnk101 treats an undefined #E as fatal.  Another configuration's index and
    HALSTAT will usually offer an address for such a symbol -- but offering one
    is not evidence that the original build used it, and mostly it did not: a
    section absent from the configuration had nothing to resolve against, so
    the build left the slot alone.  Borrowing the address unconditionally wrote
    0x456A into G3's #DGZ1ALT where the dump holds 0000, and G8's #PCGA2MC came
    out 0xE3C5 where the dump holds the bare addend 0x0019.

    Withdrawing the borrowing outright is no better.  The dump has #EASCTIM
    resolved at 0x40D4 in both G3 and G16, where eight other configurations
    independently place it, and suppressing that lost a halfword in #PCDMUIC in
    each.  The two cases are inverse, and the dump distinguishes them, so the
    decision is made per symbol from what the dump holds at the sites that
    reference it.

    A site counts only if it is ANCHORED: its own section must be in the CSECT
    index at exactly the address lnk101 placed it, so that the dump halfword at
    that image offset really is the corresponding location.  Without this most
    references read unrelated memory -- a section lnk101 could not place sits
    at the 0x10000 fallback -- and derive meaningless addresses.  G3's second
    #EASCTIM reference is one of these, implying 0x00EA against the anchored
    one's 0x40D4.

    An anchored site says "the build did not resolve this" when it holds the
    bare addend, or the addend with bit 15 set: that is the documented
    absent-section signature, HW0's sector flag set over an unpatched address.
    Otherwise it implies `dump - addend`.  The symbol is recovered only when a
    strict majority of anchored sites are resolved, every resolved site implies
    the SAME address, and an independent source -- another configuration's
    index or a HALSTAT phase -- offers that same address.  Corroboration is
    what makes it evidence rather than arithmetic: S2 has seven distinct #ZP
    symbols whose lone references each imply 0x298, which no two symbols can
    share and no candidate confirms.
    """
    sites = collections.defaultdict(list)
    for symbol, address, addend, section, base, flags in relocations:
        e = index.get(section)
        if e is not None and e.get("start") == base:
            sites[symbol].append((address, addend, flags))
    startsHere = {}
    for name, e in index.items():
        if "start" in e:
            startsHere.setdefault(e["start"], name)

    # Two CSECTs cannot begin at the same address, so an address several
    # symbols derive is one none of them may claim.  S2 has seven distinct #ZP
    # symbols whose lone references each derive 0x298 -- where #ZSMNCLN really
    # does begin, which is why the corroboration below would otherwise accept
    # all seven.  Whatever those references mean, at most one can be an alias
    # for #ZSMNCLN, and nothing here says which.
    claims = collections.Counter()
    for symbol in undefined:
        if symbol in index:
            continue
        derived = None
        for address, addend, flags in sites.get(symbol, []):
            v = halfword(address)
            if v is None or v in FILL or v == addend or v == (addend | 0x8000):
                continue
            b = basesFrom(v, addend, flags, halfword(address + 1))
            derived = b if derived is None else derived & b
        for a in (derived or ()):
            claims[a] += 1

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

        usable, implied, common = [], collections.Counter(), None
        for address, addend, flags in sites.get(symbol, []):
            v = halfword(address)
            if v is None or v in FILL:
                continue
            bases = basesFrom(v, addend, flags, halfword(address + 1))
            if not bases:
                continue
            usable.append(address)
            if v != addend and v != (addend | 0x8000):
                implied[(v - addend) & 0xFFFF] += 1
                common = bases if common is None else common & bases

        if not usable:
            report.append((symbol, "no anchored reference, so nothing in the "
                                   "dump says whether the build resolved it"))
            continue
        n = sum(implied.values())
        if n * 2 <= len(usable):
            report.append((symbol, f"the dump leaves {len(usable) - n} of "
                                   f"{len(usable)} anchored references "
                                   f"unpatched: the build did not resolve it "
                                   f"either"))
            continue
        # A base every anchored reference could have been patched from.  Taking
        # the intersection rather than a majority vote means one reference in a
        # form we read wrongly refuses the symbol instead of being outvoted.
        if not common:
            report.append((symbol, "anchored references cannot share a base: "
                           + ", ".join(f"{a:#07x}x{c}"
                                       for a, c in implied.most_common(4))))
            continue

        # Corroboration.  Another configuration's index or a HALSTAT phase
        # naming this symbol is the usual source.  Failing that, an address
        # that is exactly where a CSECT in THIS configuration begins is
        # evidence in its own right, and it is what the NONHAL COMPOOLs need:
        # S2's SAFACQ references #PCSADAR, #PCSAINB, #PCSAIXP and #PCSAPAR --
        # the four its HALSTAT compilation layout marks NONHAL -- and the
        # storage for them in this configuration is #PCS2DAR, #PCS2INB,
        # #PCS2IXP and #PCS2PAR.  All thirteen address references land exactly
        # on those four CSECT starts, including two negative displacements and
        # one sector-encoded ZCON.  The alias is reported, not assumed: nothing
        # here infers it from the names.
        taken = None
        for address in sorted(common):
            agreeing = {k: v for k, v in candidates.items() if v[0] == address}
            if agreeing:
                source = sorted(agreeing)[0]
                taken = (agreeing[source], address,
                         f"{len(agreeing)} source(s) corroborate ({source})")
                break
            alias = startsHere.get(address)
            if alias is None:
                continue
            if claims[address] > 1:
                report.append((symbol, f"derives {address:#07x}, where "
                               f"{alias} begins, but so do "
                               f"{claims[address] - 1} other symbol(s)"))
                break
            e = index[alias]
            taken = ((address, e["end"] - address + 1), address,
                     f"{alias} begins there in this configuration")
            break
        else:
            report.append((symbol, f"{n}/{len(usable)} anchored references "
                           f"imply {sorted(common)[0]:#07x}, corroborated by "
                           f"nothing"
                           + (": " + ", ".join(f"{k}={v[0]:#x}" for k, v
                                               in sorted(candidates.items()))
                              if candidates else "")))
        if taken is None:
            continue
        entry, address, why = taken
        recovered[symbol] = entry + (
            f"{n}/{len(usable)} anchored references imply {address:#07x}, "
            + why,)
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


# What an address field holds when the build did NOT patch it.  0000 belongs
# here and not in FILL: FILL answers "does this site imply an address", where a
# zero is a possible answer; this asks "did the build write one at all", where
# it is the answer no.
UNPATCHED_SITE = {0x0000, 0xC9FB, 0xC6C6}

# `target` means different things per RLD flag byte: for ACON it is the 32-bit
# word at `address`, for YCON the halfword there.  The rest patch register
# fields or sector-encoded halves and cannot be compared against a plain
# address, so they do not vote.
TARGET_IS_WORD = {0x1C, 0x9C}
TARGET_IS_HALFWORD = {0x00, 0x80}


def verifyResolved(spec, index, mafgen, config):
    '''--verify=LINK.json:DUMP.fcm -- check the addresses this table SUPPLIED,
    at the sites that used them.

    recoverForeignSymbols decides from the dump, but only over sites lnk101
    left UNRESOLVED: once the table carries an address the reference resolves
    and the evidence never runs again.  So an address that got in early -- from
    a HALSTAT phase, say -- is never revisited, and nothing says it is wrong.
    Unlike a missing definition, a wrong one is silent.

    S2 is the case.  FIOG9ADB and FIOCHECK are both `inConfig: false` there,
    both were given HALSTAT addresses, and both are EXACTLY 0x18000 below what
    the build used -- a systematic phase-base offset, not two coincidences.
    FIOG9ADB's right answer was on disk the whole time: G9's own index places
    it at 01DE90, which is precisely where S2's FIOCMPLT points.

    The comparison is against what the LINK stored, so a reference's addend
    cancels out, and bit 15 is allowed because a sector-encoded halfword
    carries it.  What is reported is the address the dump IMPLIES.
    '''
    linkPath, _, imagePath = spec.partition(":")
    if not imagePath:
        sys.exit("--verify needs LINK.json:DUMP.fcm")
    link = json.load(open(linkPath))
    image = open(imagePath, "rb").read()

    # WHAT ANOTHER CONFIGURATION'S INDEX PLACES A SYMBOL AT.  A site gives only
    # sixteen bits, so it can never distinguish 00DE90 from 01DE90 by itself --
    # but an index that names the symbol outright can, and that is what turns
    # an ambiguous reading into a corroborated one.
    elsewhere = collections.defaultdict(set)
    for f in sorted(Path(mafgen).glob("csects-*.json")):
        if f.stem.endswith(("-augmented", f"-{config}")) or f.stem == f"csects-{config}":
            continue
        try:
            other = json.load(open(f))
        except Exception:
            continue
        for n, v in other.items():
            if isinstance(v, dict) and isinstance(v.get("start"), int):
                elsewhere[n].add(v["start"])

    def hw(a):
        return struct.unpack_from(">H", image, a * 2)[0] \
               if 0 <= a * 2 + 1 < len(image) else None

    agree = 0
    wrong = {}
    ambiguous = {}
    for r in link.get("relocations") or []:
        name = r.get("symbol")
        entry = index.get(name)
        if not isinstance(entry, dict) or not isinstance(entry.get("start"), int):
            continue
        flags = r.get("flags", 0)
        if flags in TARGET_IS_WORD:
            stored = hw(r["address"] + 1)
        elif flags in TARGET_IS_HALFWORD:
            stored = hw(r["address"])
        else:
            continue
        if stored is None:
            continue
        want = r["target"] & 0xFFFF
        if stored == want:
            agree += 1
        elif stored == (want | 0x8000):
            # BIT 15 IS AMBIGUOUS AND MUST NOT BE ABSORBED.  It is the sector
            # flag a sector-encoded halfword carries -- and it is also what a
            # genuine address difference of 0x8000 looks like in sixteen bits.
            # Treating it as agreement hid the very case this check was written
            # for: S2's FIOG9ADB is at 005E90 in the table and 01DE90 in G9's
            # own index, and 5E90 | 8000 is DE90, so it scored as a match.
            # CORROBORATED ONLY IF AN INDEX SAYS SO.  Most of these really are
            # the sector flag -- S2 has 115, nearly all A1* PROCEDUREs above
            # 040000 -- and reporting them all would bury the few that are a
            # real address.  Another configuration's index whose low sixteen
            # bits match the site is the discriminator that separates them.
            alt = sorted(a for a in elsewhere.get(name, ())
                         if (a & 0xFFFF) == stored and a != entry["start"])
            if alt:
                ambiguous.setdefault(name, (entry["start"], alt,
                                            entry.get("type"),
                                            entry.get("inConfig")))
        elif stored in UNPATCHED_SITE:
            continue
        else:
            implied = (entry["start"] + (stored - want)) & 0xFFFFF
            wrong.setdefault(name, (entry["start"], implied, entry.get("type"),
                                    entry.get("inConfig")))
    print(f"\nverify {linkPath}", file=sys.stderr)
    print(f"   {agree} site(s) agree with the table", file=sys.stderr)
    print(f"   {len(wrong)} symbol(s) the dump CONTRADICTS", file=sys.stderr)
    if ambiguous:
        print(f"   {len(ambiguous)} symbol(s) whose site matches ANOTHER "
              f"configuration's index, not this table's address", file=sys.stderr)
        for name, (start, alt, typ, inConfig) in sorted(ambiguous.items()):
            note = f" type={typ}" + ("" if inConfig is None else
                                     f" inConfig={inConfig}")
            where = " ".join(f"{a:06X}" for a in alt)
            print(f"      {name:10} table {start:06X}, an index says {where}"
                  f"{note}", file=sys.stderr)
    for name, (start, implied, typ, inConfig) in sorted(wrong.items()):
        note = f" type={typ}" + ("" if inConfig is None else f" inConfig={inConfig}")
        print(f"      {name:10} table {start:06X}, the dump implies "
              f"{implied:06X}  ({implied - start:+#x}){note}", file=sys.stderr)
    return 1 if wrong else 0


def main():
    config = "SSW"
    halstat = DEFAULT_HALSTAT
    mafgen = DEFAULT_MAFGEN
    linkDir = "work"
    logDir = "logs"
    # Accepting a symbol because exactly one HALSTAT phase offers it, with no
    # dump evidence either way, is NOT evidence that the address is right --
    # and it has been shown to supply wrong ones.  #PCSPCLB was rejected in SSW
    # for want of agreement (2 of 23 references) and then accepted in S2 by
    # this rule at HALSTAT phase 14's 0xAF6E, where the dump implies 0xAF73;
    # that put $0SPSPSP and several other CODE sections out by five halfwords.
    # In SSW, where it accepted 18 symbols, it changed nothing measurable at
    # all.  So it costs correctness and buys nothing, and is off unless asked
    # for.
    permitSoleCandidate = False
    # Giving a symbol this configuration does not contain an address borrowed
    # from one that does.  This used to be unconditional, and then off
    # altogether; both were wrong, in opposite directions and by the same two
    # halfwords.  recoverForeignSymbols now decides per symbol, from what the
    # dump holds at the sites that reference it, so there is nothing left to
    # switch off -- the flag survives only to disable the pass wholesale if a
    # configuration ever needs it.
    recoverForeignAddresses = True
    base = None
    out = None
    report = False
    verify = None
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
        elif p == "--sole-candidates":
            permitSoleCandidate = True
        elif p == "--no-foreign-symbols":
            recoverForeignAddresses = False
        elif p.startswith("--verify="):
            verify = p.partition("=")[2]
        elif p == "--report":
            report = True
        else:
            print(__doc__)
            sys.exit(1)
    if out is None:
        # Deliberately not csects-<config>-augmented.json.  That name matches the
        # csects-*.json glob used above to find the other configurations, so
        # writing it into the MAFGEN directory would make this script's output an
        # input to its next run, under a configuration name that does not exist.
        out = f"augmented-{config}.json"

    # The relocation-evidence pass can only see a symbol that was unresolved in
    # the sweep it reads, so re-running it against a sweep that already had the
    # augmented table finds nothing and would silently drop what the first run
    # recovered.  --base carries a previous result forward.  (The
    # cross-configuration pass below has no such dependency: it works from the
    # index and the dump, so it is reproducible from scratch every time.)
    # --verify checks a table that already EXISTS, so it needs no recovery pass
    # and must not run one: the point is to audit what was published.
    if verify:
        base = base or (mafgen / f"augmented-{config}.json")
        sys.exit(verifyResolved(verify, json.load(open(base)),
                                mafgen, config))

    index = json.load(open(mafgen / f"csects-{config}.json"))
    if base is not None:
        previous = json.load(open(base))
        for name, entry in previous.items():
            if name not in index:
                index[name] = entry
        print(f"carried {len(index) - len(json.load(open(mafgen / f'csects-{config}.json')))} "
              f"entries forward from {base}")
    # Prefer the literals-patched image, as dass-versions.py and the comparison
    # itself do.  unlinkMAFGEN2 synthesises C9FB for a halfword the listing
    # never reported, and dass-literals.py then recovers many of them from
    # MAFGEN's own annotations -- 177 of them in S2.  Reading the raw scrape
    # here made every one of those look like fill and threw the evidence away:
    # S2's #PCSAPXT and #PCSACAT have sixteen and six references apiece whose
    # halfwords are all recovered values, so both were reported as having "no
    # usable dump evidence" when the dump states them plainly.
    patched = Path(f"{config}.literals.fcm")
    memory = open(patched if patched.is_file()
                  else mafgen / f"{config}.fcm", "rb").read()

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
    for symbol, address, addend, _section, _base, _flags in relocations:
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
            def matching(value):
                return [p for p, a in candidates.items()
                        if value in (a, a & 0xFFFF, (a | 0x8000) & 0xFFFF)]

            hit = matching(base)
            if hit and n / total >= 0.6:
                phase = sorted(hit, key=int)[0]
                accepted[symbol] = (candidates[phase], phase,
                                    f"{n}/{total} references agree")
                continue

            # A true address can be outvoted by noise.  A reference sitting in
            # a section that is NOT at its own true address reads unrelated
            # memory, so it derives a meaningless base -- and several such
            # references disagree with each OTHER, while the real ones agree.
            # #PCSZICC went 2 votes for 0A77C against three lone values, so the
            # majority rule rejected an address HALSTAT gives outright and
            # another configuration's index confirms.
            #
            # So: take a value that HALSTAT corroborates, at least two
            # references agree on, and that is the ONLY corroborated value --
            # ambiguity still refuses.  This is not the withdrawn sole-candidate
            # rule, which accepted HALSTAT with NO dump evidence at all; here
            # the dump and HALSTAT must independently agree.
            corroborated = [(v, c) for v, c in votes[symbol].items()
                            if c >= 2 and matching(v)]
            if len(corroborated) == 1:
                value, c = corroborated[0]
                phase = sorted(matching(value), key=int)[0]
                accepted[symbol] = (
                    candidates[phase], phase,
                    f"{c}/{total} references agree and HALSTAT corroborates; "
                    f"the others disagree with each other")
                continue

            if not candidates:
                why = "not in HALSTAT"
            elif hit:
                why = (f"dump-derived {base:#07x} matches a candidate but only "
                       f"{n}/{total} references agree")
            else:
                why = (f"dump-derived {base:#07x} ({n}/{total}) matches "
                       f"no candidate")
            rejected.append((symbol, seen[symbol], why))
        elif len(candidates) == 1 and permitSoleCandidate:
            phase = list(candidates)[0]
            accepted[symbol] = (candidates[phase], phase,
                                "sole HALSTAT candidate, no contrary evidence")
        else:
            rejected.append((symbol, seen[symbol],
                             ("no usable dump evidence, "
                              + (f"{len(candidates)} candidate(s)"
                                 if candidates else "not in HALSTAT"))))

    # The scrape's index plus every address recovered below.  A recovered
    # address does NOT imply the section is in this configuration -- a
    # configuration can carry a module's ZCON without carrying the module -- so
    # the two questions are answered separately: this dictionary says where a
    # name lives, while the "inConfig" and "spanOwner" fields added at the end
    # say how much reason there is to think it is not here.  See the note there;
    # neither field is proof of absence, and one of them is much weaker.
    augmented = dict(index)
    for symbol, (address, phase, why) in accepted.items():
        n = sizeOf.get((symbol, address), 1)
        augmented[symbol] = {"start": address, "end": address + n - 1,
                             "type": "HALSTAT", "hal": None}

    # The other configurations' own indexes, used by both passes below.
    others = {}
    # A configuration name, and nothing else.  The glob is the whole reason this
    # is here: anything called csects-SOMETHING.json in the MAFGEN directory is
    # otherwise read as a configuration named SOMETHING, and this script's own
    # default output was csects-<config>-augmented.json, so one hand-run in that
    # directory would have introduced a phantom "G3-augmented" configuration
    # holding a superset of G3's own sections.  Measured, it changed nothing
    # today -- the augmented tables published alongside are called
    # augmented-<config>.json precisely so the glob cannot see them -- but a rule
    # that happens to be harmless is not a rule.  Real names are SSW, P9, G8, S2,
    # G9, G2, G3, G16: capitals and digits, never a hyphen.
    for f in sorted(Path(mafgen).glob("csects-*.json")):
        name = f.stem[len("csects-"):]
        if not re.fullmatch(r"[A-Z0-9]+", name):
            continue
        if name != config:
            try:
                others[name] = json.load(open(f))
            except Exception:
                pass

    # Second class: symbols this configuration does not contain at all, which
    # lnk101 will not tolerate for anything but a COMPOOL.  Read from the sweep
    # LOGS rather than the symbol JSONs, because a link that fails this way
    # produces no JSON at all.
    # lnk101 announces a symbol as undefined only when it has nowhere to put
    # it; a NONHAL COMPOOL simply goes unresolved, with no message.  S2's
    # #PCSADAR is one -- SAFACQ's HALSTAT compilation layout marks CSA_DART
    # NONHAL -- so drive the pass from the relocations as well, minus whatever
    # the evidence pass above already accounted for.
    foreignReport = []
    absent = collectUndefined(logDir) | (set(seen) - set(accepted)
                                         - set(augmented))
    foreign = recoverForeignSymbols(absent, index, phases,
                                    others, relocations, halfword,
                                    foreignReport) \
              if recoverForeignAddresses else {}
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
    # Mark the sections this configuration does NOT contain, so fcmcmp need not
    # report a meaningless difference as a failure -- which is what G3's DKFCM2
    # did, reporting "FAIL: 2/3" for two sections that are not in G3 at all
    # while the scoring, correctly, had already excluded them.
    #
    # Two things are recorded, and the second is what makes the first safe to
    # act on.
    #
    # "inConfig": false says only where the ADDRESS came from: one of the two
    # foreign passes, rather than the relocation-evidence pass.  That is weak
    # evidence of absence and must not be treated as proof.  #PCDHMMU shows why
    # in one direction -- absent from the scrape, yet genuinely present, its 788
    # halfwords inside FCMBMTPG with 170 agreeing references -- so the
    # relocation-evidence pass marks nothing.  But the foreign passes are not
    # safe either.  A configuration can carry both the ZCON and the module, and
    # across the eight configurations 79 marked sections MATCH the dump, 59 of
    # them verifying content the --no-data patterns do not cover -- up to 477
    # halfwords, in SSW's #DDCDDG3.  Acting on the mark alone would have hidden
    # 36 of those agreements.
    #
    # "spanOwner" is the positive evidence: the name of a DIFFERENT section in
    # this configuration's own index that covers the same address.  Where one
    # exists, we can say what the memory actually belongs to, and a difference
    # against it means nothing.  In G3, 0xB728 lies inside #PCGZFLD, so the
    # foreign #DDKFCM2 was compared against unrelated code; in SSW the same
    # address is unclaimed, and there #DDKFCM2 matches.  Every one of the 231
    # spurious failures has such an owner, which is why naming it is enough.
    for name in list(foreign) + [c for c in crossConfig]:
        if name not in augmented:
            continue
        augmented[name]["inConfig"] = False
        start = augmented[name].get("start")
        if start is None:
            continue
        # Narrowest containing span, so a nested CSECT is named in preference to
        # whatever encloses it -- the same rule dass-versions.py owner() uses.
        best = None
        for other, info in index.items():
            if other == name or not isinstance(info, dict):
                continue
            s, e = info.get("start"), info.get("end")
            if s is None or e is None or not s <= start <= e:
                continue
            if best is None or (e - s) < best[1]:
                best = (other, e - s)
        if best:
            augmented[name]["spanOwner"] = best[0]

    # "linkInfo": "placement" -- THE MEMORY MAP SAYS WHICH SECTIONS ARE HERE,
    # and it says so positively.  "inConfig" above is an inference from where
    # the ADDRESS came from, which is why the comment there calls it weak
    # evidence; the DASS listing's own
    #
    #     M E M O R Y   M A P ---  GNC9
    #     000000-0001A5  FCMPSA   **** 01A6(  422)  N O N H A L
    #
    # is one line per section the build actually placed.  A section named there
    # is in this configuration; one that is not, is not.
    #
    # WHAT THE MARK LICENSES IS NARROW.  lnk101 goes on placing such a section
    # and defining its contents, so the symbol table it writes is unchanged --
    # the AP-101S emulators read that table.  What it stops doing is RESOLVING
    # a relocation against those contents, because no module supplied them and
    # the original link left the site alone.  GNC9's FIOPDSPG names TFCMPFD1
    # and TFCMPFD2, fields of #DDPLLIG, which that configuration does not load;
    # the flight image holds 0000 and we were producing 05C0 and 05C4.
    #
    # THE SECTION'S OWN ADDRESS IS STILL PUBLISHED, because a configuration can
    # carry a module's ZCON without carrying the module and that ZCON has to
    # point where the code lives in the configuration that does load it.  Only
    # the contents are withheld, and only from RESOLUTION.
    #
    # THE MEMORY MAP WAS TRIED FOR THIS AND IS THE WRONG AUTHORITY, 2026-08-14.
    # Marking every map-absent section looked right on G9 and S2 and is WRONG
    # on SSW, which it makes worse.  #DDG9LIG and #DDPLLIG are overlay siblings
    # at 0005A2 and the configurations swap which is resident; FIOPDSPG is
    # compiled per configuration and in each names the fields of the sibling
    # that is NOT resident.  G9's build left those references at 0000 and SSW's
    # build RESOLVED its equivalents, to 05A4 05AC 05B0 05B8 -- same structure,
    # opposite outcome.  (The 0000 is real: the raw MAFGEN scrape holds it, not
    # the C9FB unlinkMAFGEN2 synthesises for a halfword never reported.)  So
    # absence from the map does not predict whether the build resolved a site,
    # and no tuning of a map-derived rule can fix that.
    #
    # THE SITE PREDICTS IT, and the test is not which name owns the address.
    # Overlaid sections need not share names -- these two do not -- so name
    # identity is the wrong question entirely.  Resolve everything, then ask
    # what the flight image holds where the reference landed:
    #
    #     it holds what resolution produced   -> the build resolved it.  A
    #                                            match against ANY known
    #                                            symbol's address is a match,
    #                                            whichever sibling's name it
    #                                            was written under.
    #     it holds fill where an address
    #     would be                            -> the build left it alone: MARK.
    #
    # THE CRITERION IS PER SITE; the grouping by section below is only how the
    # mark can currently be EXPRESSED, because "linkInfo" attaches to a table
    # entry and lnk101 withholds that entry's contents as a unit.  It happens
    # to cost nothing here -- each configuration reduces to a single section --
    # but a per-symbol mark would be the faithful form.
    #
    # ONLY UNAMBIGUOUS RELOCATIONS VOTE.  `target` means different things per
    # flag byte: for ACON (0x1C, 0x9C) it is the 32-bit word at `address`, for
    # YCON (0x00, 0x80) the halfword there.  0x10, 0x50 and 0xD0 patch register
    # fields or sector-encoded halves and `target` is not what gets stored, so
    # they are SKIPPED rather than guessed at -- silence is the safe direction.
    #
    # Measured, collision-filtered full-configuration links, best of the three
    # in every case where the map-derived rule was best in only two:
    #     G9   39/1116 (map 39, unmarked 40)   marks #DDPLLIG
    #     S2  123/1090 (map 123, unmarked 124) marks #DDG9LIG
    #     SSW  33/570  (map 34,  unmarked 33)  marks #0ITOE
    # THE MARKING MOVED TO dass-fields.py --mark, and the memory-map rule this
    # script briefly carried is GONE rather than merely unused: it was wrong.
    # See that function's comment for the evidence.  It lives there because the
    # evidence is read at references to a section's FIELDS, and `contents` --
    # the field names -- is what dass-fields.py adds AFTER this script has run;
    # marking here saw no contents and marked nothing.
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
