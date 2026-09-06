#!/usr/bin/env python3
'''Resolve duplicate symbol names in a MAFGEN CSECT index, using the sources'
own ENTRY declarations as the authority.

Usage:  csect-disambig.py WORKDIR CONFIG OUT.json
        WORKDIR is the working copy of OI340600 -- the one holding SSSRC and
        RUNASM -- and ../mafgen/augmented-CONFIG.json is read beside it.  Pass
        the result to compileLinkCompare as --ext-syms, or to clc-sweep.py the
        same way; fcmcmp is handed the same file as its --csect-table, so both
        halves of the comparison see the corrected index.

augmented-CONFIG.json records a CSECT's `contents` -- the symbols MAFGEN
recovered inside it -- WITHOUT distinguishing an entry point from a private
label.  Where the same name occurs in two CSECTs, lnk101 has no way to choose
and may resolve an EXTRN to the wrong one.  FPMDISP is the case in point: it
declares `EXTRN FPMAREGS`, FCMCBLKS declares `ENTRY FPMAREGS` and defines it,
and FPMSDERR happens to have a private `FPMAREGS DC X'8000'`.  lnk101 took
FPMSDERR's 0x1B070; DASS_SSW has FCMCBLKS's 0x821E.

Only an ENTRY is visible to the linker, so where exactly one of the competing
CSECTs exports the name, the others' copies are private labels and are dropped.
Anything still ambiguous is left alone and REPORTED, never guessed -- in SSW
that leaves 79 names, and every one of them is exported by nothing we have, so
they are private in both CSECTs and no EXTRN can ever need them.

THIS IS A WORKAROUND AND NOT THE FIX.  The index is built by unlinkMAFGEN2.py in
PFS, and recording which of a CSECT's recovered symbols were ENTRY points is
something it could do at the source, which would spare every downstream
consumer this reconstruction.  Doing it here keeps the change out of somebody
else's repository and out of lnk101, which is fed the ambiguous data and cannot
be blamed for choosing wrongly.
'''
import sys, os, json, glob, re

def entriesOf(path):
    '''Symbols a source exports.  ENTRY takes a comma-separated list and may be
    continued, so the operand is taken from columns 16-71 and any card with a
    non-blank column 72 carries the list onto the next.'''
    out, pending = set(), False
    for line in open(path, errors="replace"):
        card = "%-80s" % line.rstrip("\n")[:80]
        body, cont = card[:71], card[71] != " "
        if card[0] in "*." and not pending:
            continue
        fields = body.split()
        if pending:
            operand = body[15:].strip()
        elif len(fields) >= 2 and fields[0] == "ENTRY":
            operand = body[body.index("ENTRY") + 5:].strip()
        elif len(fields) >= 3 and fields[1] == "ENTRY":
            operand = body[body.index("ENTRY") + 5:].strip()
        else:
            pending = False
            continue
        operand = operand.split()[0] if operand.split() else ""
        for s in operand.split(","):
            if s and re.fullmatch(r"[A-Z@#$][A-Z0-9@#$]*", s):
                out.add(s)
        pending = cont
    return out

work, config, out = sys.argv[1], sys.argv[2], sys.argv[3]
exporters = {}
for tree in ("SSSRC", "RUNASM"):
    for p in glob.glob(os.path.join(work, tree, "*.asm")):
        m = os.path.basename(p)[:-4]
        for s in entriesOf(p):
            exporters.setdefault(s, set()).add(m)

table = json.load(open(os.path.join(work, "..", "mafgen",
                                    "augmented-%s.json" % config)))
owners = {}
for k, v in table.items():
    for s in (v.get("contents") or {}):
        owners.setdefault(s, []).append(k)

dropped = kept = unresolved = 0
for s, cs in owners.items():
    if len(cs) < 2:
        continue
    exp = exporters.get(s, set())
    winners = [c for c in cs if c in exp]
    if len(winners) != 1:
        unresolved += 1
        print("  ambiguous, left alone: %-9s in %s (exported by %s)"
              % (s, ",".join(cs), ",".join(sorted(exp)) or "nothing we have"))
        continue
    for c in cs:
        if c != winners[0]:
            del table[c]["contents"][s]
            dropped += 1
    kept += 1
json.dump(table, open(out, "w"))
print("%s: %d name(s) resolved to their ENTRY, %d private copy(ies) dropped, "
      "%d left ambiguous -> %s" % (config, kept, dropped, unresolved, out))
