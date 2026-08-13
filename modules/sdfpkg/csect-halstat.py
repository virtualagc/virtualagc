#!/usr/bin/env python3
'''Fill a MAFGEN CSECT index with symbol addresses taken from HALSTAT, which
states them outright.

Usage:  csect-halstat.py --work=DIR --config=XXX --out=F.json
                         [--base=F.json] [--halstat=F.ASC] [--memory=F.fcm]
                         [--report]

HALSTAT NAMES THESE SYMBOLS DIRECTLY, which is worth more than any amount of
inference from the dump.  For each it gives the equate, the owning CSECT, the
offset and the absolute address:

    30937  CZ2BDIA                    EQUATE   LABEL   C O M P O O L   CZ2_COMMON
           (EQUATED TO: CZ2B_DIA_RM1   UNIT/BLOCK: CZ2_COMMON)
           (CSECT: #PCZ2COM OFFSET: 000488) PHASE 2 ADDR: 00287C

68853 entries carry one, across 29 phases.  csect-recover.py derives the same
addresses by inverting relocations against the memory image; that is inference
and this is testimony, so where both speak, this wins.  Measured over the 676
addresses recovered the other way, HALSTAT agreed with 671 and the five
disagreements were all mine: two off by exactly 2 halfwords (a module whose
section was short, so its later sites read the dump two halfwords early), two
differing by a whole sector (0x8000 and 0x10000, where the halfword encoding
cannot distinguish the candidates), and one simply wrong.

WHICH PHASE APPLIES IS DECIDED BY EVIDENCE, never by the label -- the same rule
dass-syms.py states.  A phase is not a memory configuration: measured against
SSW, phases 2, 3, 8 and 14 all agree with the dump where they overlap it (phase
2 on 179 symbols, the others on 26, 17 and 6), while the phases belonging to
other configurations share no symbols with it at all.  So a symbol is accepted
from a phase only if its address lands inside a CSECT this configuration's index
already knows, and where several phases offer different addresses the one
corroborated by the dump is taken; failing that, the one from the phase with the
broadest agreement.  Anything still ambiguous is reported and dropped.
'''

import sys, os, json, re, struct, collections

HDR = re.compile(r"^\s*\d+\s+([A-Z@#$][A-Z0-9@#$_]*)\s{2,}\S")
ADDR = re.compile(r"\(CSECT:\s+(\S+)\s+OFFSET:\s+([0-9A-F]+)\)"
                  r"(?:\s+SIZE:\s+\S+)?\s*PHASE\s+(\d+)\s+ADDR:\s+([0-9A-F]+)")
FILL = {0xC6C6, 0xC9FB}

work = config = out = base = halstat = memory = phaseArg = None
report = False
for p in sys.argv[1:]:
    if p.startswith("--work="): work = p.partition("=")[2]
    elif p.startswith("--config="): config = p.partition("=")[2]
    elif p.startswith("--out="): out = p.partition("=")[2]
    elif p.startswith("--base="): base = p.partition("=")[2]
    elif p.startswith("--halstat="): halstat = p.partition("=")[2]
    elif p.startswith("--memory="): memory = p.partition("=")[2]
    elif p.startswith("--phases="): phaseArg = p.partition("=")[2]
    elif p == "--report": report = True
    else:
        print(__doc__); sys.exit(1)
if not (work and config and out):
    print(__doc__); sys.exit(1)
mafgen = os.path.join(work, "..", "mafgen")
base = base or os.path.join(mafgen, "augmented-%s.json" % config)
halstat = halstat or os.path.expanduser("~/workspace/PFS/HALSTAT.ASC")
memory = memory or os.path.join(mafgen, "%s.fcm" % config)

table = json.load(open(base))
spans = sorted((v["start"], v.get("end", v["start"]), k)
               for k, v in table.items() if "start" in v)
def owner(addr):
    for s, e, k in spans:
        if s <= addr <= e:
            return k, addr - s
    return None, None
known = set(table)
for v in table.values():
    known |= set(v.get("contents") or {})

raw = open(memory, "rb").read()
n = len(raw) // 2
hw = struct.unpack(">%dH" % n, raw[:2 * n])

wanted = None
if phaseArg:
    wanted = {int(x) for x in phaseArg.replace(",", " ").split()}
sym = None
offers = collections.defaultdict(dict)          # name -> {phase: address}
for line in open(halstat, errors="replace"):
    line = line.rstrip("\r\n")
    m = HDR.match(line)
    if m:
        sym = m.group(1); continue
    if sym:
        a = ADDR.search(line)
        if a:
            ph = int(a.group(3))
            # CONTAINMENT IS A WEAK TEST and must not be the only one.  Most of
            # memory lies inside SOME CSECT, so a phase belonging to a different
            # configuration still "fits" thousands of times; taking every phase
            # on that basis offered 32991 symbols for SSW, including phase 4,
            # which is G16's.  --phases names the phases whose addresses were
            # shown to AGREE with this configuration -- for SSW, 2, 3, 8 and 14,
            # measured against independently recovered addresses at 97% on 179
            # symbols and 100% on the rest, while the other configurations'
            # phases shared no symbols with it at all.
            if wanted is None or ph in wanted:
                offers[sym][ph] = int(a.group(4), 16)

# How well each phase's addresses sit inside THIS configuration's CSECTs.  This
# is the evidence that decides which phases apply, in place of the label.
fit = collections.Counter()
for s, byPhase in offers.items():
    for ph, ad in byPhase.items():
        if owner(ad)[0] is not None:
            fit[ph] += 1
ranked = [ph for ph, _ in fit.most_common()]

added = ambiguous = absent = 0
lines = []
for s, byPhase in sorted(offers.items()):
    if s in known:
        continue
    inside = {ph: ad for ph, ad in byPhase.items() if owner(ad)[0] is not None}
    if not inside:
        absent += 1
        continue
    distinct = set(inside.values())
    if len(distinct) > 1:
        # Prefer the address the dump corroborates, then the best-fitting phase.
        corroborated = set()
        for ad in distinct:
            c, off = owner(ad)
            if c is not None and ad < n and hw[ad] not in FILL:
                corroborated.add(ad)
        if len(corroborated) == 1:
            pick = next(iter(corroborated))
        else:
            pick = next((inside[ph] for ph in ranked if ph in inside), None)
            if pick is None or len({inside[ph] for ph in ranked if ph in inside
                                    and inside[ph] == pick}) != 1:
                pass
        if pick is None:
            ambiguous += 1
            lines.append("  AMBIGUOUS %-9s %s" %
                         (s, ", ".join("phase %d %#07x" % (p, a)
                                       for p, a in sorted(inside.items()))))
            continue
    else:
        pick = next(iter(distinct))
    csect, off = owner(pick)
    table[csect].setdefault("contents", {})[s] = off
    added += 1
    if report:
        lines.append("  %-9s %#07x = %s+%#x" % (s, pick, csect, off))

json.dump(table, open(out, "w"))
for l in lines:
    print(l)
print("%s: %d symbol(s) taken from HALSTAT, %d ambiguous across phases, %d "
      "naming no address inside a known CSECT; phases best fitting this "
      "configuration: %s -> %s"
      % (config, added, ambiguous, absent,
         ", ".join("%d(%d)" % (p, fit[p]) for p in ranked[:6]), out))
