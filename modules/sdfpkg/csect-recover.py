#!/usr/bin/env python3
'''Recover addresses for symbols the MAFGEN CSECT index does not record, from
the memory dump's own value at each relocation site.

Usage:  csect-recover.py --work=DIR --config=XXX --out=F.json
                         [--memory=F.fcm] [--base=F.json] [--report]

THE PROBLEM.  augmented-CONFIG.json records CSECTs and, inside them, the
symbols MAFGEN happened to recover.  It does not reach FIELD granularity: a
label inside a COMPOOL, or inside an assembly CSECT whose container the index
knows, is simply absent.  lnk101 then cannot resolve an EXTRN naming it and the
link fails.  Over SSW that is 114 modules, 1901 relocation sites and 738
distinct symbols.  (dass-syms.py recovers the COMPOOL CSECTS themselves from
HALSTAT; this is one level finer and its input is different.)

THE EVIDENCE IS THE DUMP AT THE SITE.  A relocation ADDS -- lnk101 computes
`existing + target` and masks to the length (ap101Utils/addrcon.py,
AddrCon.apply) -- so the original build's value at that halfword is
`addend + address`, and the address falls straight out:

    address = (dump value - existing) & mask

`unresolvedRelocations` in the link's symbol JSON gives the site, the length,
the addend and the sign/direction for every one, which is why this is
arithmetic rather than a search.  It only became possible once the missing
relocations were emitted: before that the sites were not recorded at all.

WHAT MAKES IT SAFE IS AGREEMENT.  Most of these symbols are referenced from
several places, and every site must yield the SAME address or the symbol is
rejected and reported.  A symbol seen once is accepted but counted separately,
since it carries no cross-check.  A site where the dump holds C6C6 or C9FB is
skipped: unlinkMAFGEN2 synthesises those for a halfword the listing never
reported, so there is no observation there to invert.

WHAT IT DOES NOT DO.  It does not invent a CSECT.  A recovered address must
fall inside a CSECT the index already knows, and the symbol is added to that
CSECT's `contents` at the offset implied.  An address landing outside every
known CSECT is reported and dropped -- that is the signature of a pointer into
nowhere, which this phase has independent reason to expect.
'''

import sys, os, json, glob, struct, collections

FILL = {0xC6C6, 0xC9FB}

work = config = out = memory = base = None
report = False
for p in sys.argv[1:]:
    if p.startswith("--work="): work = p.partition("=")[2]
    elif p.startswith("--config="): config = p.partition("=")[2]
    elif p.startswith("--out="): out = p.partition("=")[2]
    elif p.startswith("--memory="): memory = p.partition("=")[2]
    elif p.startswith("--base="): base = p.partition("=")[2]
    elif p == "--report": report = True
    else:
        print(__doc__); sys.exit(1)
if not (work and config and out):
    print(__doc__); sys.exit(1)

mafgen = os.path.join(work, "..", "mafgen")
if memory is None:
    memory = os.path.join(mafgen, "%s.fcm" % config)
if base is None:
    base = os.path.join(mafgen, "augmented-%s.json" % config)

raw = open(memory, "rb").read()
n = len(raw) // 2
hw = struct.unpack(">%dH" % n, raw[:2 * n])
table = json.load(open(base))

# Every span the index knows, for attributing a recovered address to a CSECT.
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

# symbol -> {address: [sites]}
seen = collections.defaultdict(lambda: collections.defaultdict(list))
sites = skippedFill = outside = 0
for f in sorted(glob.glob(os.path.join(work, "clc-%s" % config, "*.json"))):
    if ".repro." in f:
        continue
    try:
        d = json.load(open(f))
    except Exception:
        continue                      # a truncated product of a killed run
    for u in d.get("unresolvedRelocations") or []:
        sym, off, ln = u["symbol"], u["imageOffsetHW"], u.get("length", 2)
        if sym in known or off + (ln // 2) > n:
            continue
        sites += 1
        if ln == 4:
            value = (hw[off] << 16) | hw[off + 1]
            mask = 0xFFFFFFFF
            if hw[off] in FILL or hw[off + 1] in FILL:
                skippedFill += 1
                continue
        else:
            value = hw[off]
            mask = 0xFFFF
            if value in FILL:
                skippedFill += 1
                continue
        existing = u.get("existing", 0)
        signed = -existing if u.get("sign") else existing
        target = (value - signed) & mask
        if u.get("direction"):
            target = (-target) & mask
        seen[sym][target].append((u["module"], ln))

# A HALFWORD SITE DETERMINES THE ADDRESS ONLY MODULO 0x10000.  The BCE and MSC
# address fields are 18 and 24 bits and are relocated with a 4-byte ACON, but an
# ordinary Y constant is two bytes, so inverting one of those recovers the low
# 16 bits and nothing more.  FIOSICCM appeared to disagree with itself -- 0x099CE
# from five sites and 0x199CE from five others -- when both are the same address
# and only one of them is complete.  So a 4-byte site is believed outright, and a
# symbol seen only through halfword sites is lifted by whole 0x10000s until
# exactly one candidate lands inside a CSECT the index knows.  Anything still
# genuinely divided is reported and dropped.
def reconcile(byAddr):
    long4 = sorted({a for a, ms in byAddr.items() if any(l == 4 for _, l in ms)})
    if len(long4) == 1:
        return long4[0], byAddr[long4[0]]
    if len(long4) > 1:
        return None, None
    lows = {a & 0xFFFF for a in byAddr}
    if len(lows) != 1:
        return None, None
    low = next(iter(lows))
    lifted = [low + k * 0x10000 for k in range(0, (n >> 16) + 2)
              if owner(low + k * 0x10000)[0] is not None]
    if len(lifted) != 1:
        return None, None
    mods = [m for ms in byAddr.values() for m in ms]
    return lifted[0], mods

added = conflicted = single = lifted = 0
report_lines = []
for sym, byAddr in sorted(seen.items()):
    addr, mods = reconcile(byAddr)
    if addr is None:
        conflicted += 1
        report_lines.append("  CONFLICT %-9s %s -- left out"
                            % (sym, ", ".join("%#07x from %d site(s)" % (a, len(m))
                                              for a, m in sorted(byAddr.items()))))
        continue
    if addr not in byAddr:
        lifted += 1
    csect, offset = owner(addr)
    if csect is None:
        outside += 1
        report_lines.append("  OUTSIDE  %-9s %#07x in no known CSECT -- left out"
                            % (sym, addr))
        continue
    table[csect].setdefault("contents", {})[sym] = offset
    added += 1
    if len(mods) == 1:
        single += 1
    if report:
        report_lines.append("  %-9s %#07x = %s+%#x  (%d site(s))"
                            % (sym, addr, csect, offset, len(mods)))

json.dump(table, open(out, "w"))
for l in report_lines:
    print(l)
print("%s: %d site(s) examined, %d symbol(s) recovered (%d of them from a "
      "single site, so uncorroborated; %d lifted past a halfword site's 16-bit "
      "horizon), %d conflicting, %d outside every known CSECT, %d site(s) "
      "skipped as fill -> %s"
      % (config, sites, added, single, lifted, conflicted, outside, skippedFill,
         out))
