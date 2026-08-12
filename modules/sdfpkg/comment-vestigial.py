#!/usr/bin/env python3
"""Comment out the vestigial macro invocations -- the ones whose EXPANSION is
already in the file.

This is the treatment commit 5c35b774 applied by hand to ten SSSRC modules,
374 cards, and its reasoning applies unchanged to the MLIB80 members BILDNEW5
copies: the extraction kept each macro's expansion, which the listing prints
right underneath the call, so expanding the call again emits the code twice.

    ITEM1         XPOS  -285                  01-POS      the invocation
    ITEM1    EQU    *,0+1,0+1                 02-XPOS     its expansion
             DC    BL.5'10000',FL.11'-285'    02-XPOS

RECOGNISED BY THE CARD THAT FOLLOWS, not by the call itself.  A first attempt
asked whether the INVOCATION carried an `nn-MACRO` stamp, which is true of the
5276 DCHAR/XPOS/YPOS calls that the original build generated in turn -- but
CHRESET's ten calls are ordinary source cards with ordinary SRNs and their
expansions are present just the same, and so are single calls of CLRMACRO, PSA
and UNPRT.  Asking instead whether the NEXT card carries a stamp deeper than
this one's finds all 5289.

$POF AND $PON ARE EXCLUDED, and they are the whole reason this needs a list of
exceptions.  Both wrap their generated `DS 0H` in PRINT NOGEN, so the DS never
reached the listing and was never extracted; what follows the call is the
PRINT NOGEN card itself, stamped, which makes them look expanded when nothing
of substance survived.  Their calls have to stay -- see restore-pofpon.py,
which puts back the 35 the extraction dropped outright.

The commenting convention is 5c35b774's: a `*` in column 1, the statement
shifted one column right, and columns 72-80 -- the sequence numbers and the
expansion markers -- left exactly where they were.  That is only possible when
column 71 is blank, so a card where it is not is refused rather than mangled.

Usage:  comment-vestigial.py DIRECTORY [--apply]
"""
import os, sys, glob, collections

KEEP = {"$POF", "$PON"}

def macroNames(mlib):
    names = set()
    for path in glob.glob(os.path.join(mlib, "*.asm")):
        lines = open(path, errors="replace").read().split("\n")
        for i, line in enumerate(lines):
            if line[:1] in ("*", "."):
                continue
            if line[:71].split()[:1] == ["MACRO"] and i + 1 < len(lines):
                proto = lines[i+1][:71]
                fields = proto.split()
                if not fields or (proto[:1] != " " and len(fields) < 2):
                    continue
                op = fields[1] if proto[:1] != " " else fields[0]
                if op and op[:1] not in ("&", "*"):
                    names.add(op)
    return names

def level(card):
    s = "%-80s" % card[:80]
    return int(s[72:74]) if (s[72].isdigit() and s[73].isdigit() and
                             s[74] == "-") else 0

def operation(card):
    fields = card[:71].split()
    if not fields or (card[:1] != " " and len(fields) < 2):
        return None
    return fields[1] if card[:1] != " " else fields[0]

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    apply = "--apply" in sys.argv
    if not args:
        print(__doc__)
        return 1
    mlib = args[0]
    macros = macroNames(mlib)
    print("%d macro definitions in %s" % (len(macros), mlib))
    total = 0
    kept = collections.Counter()
    byMacro = collections.Counter()
    for path in sorted(glob.glob(os.path.join(mlib, "*.asm"))):
        lines = open(path, errors="replace").read().split("\n")
        changed = 0
        for i, card in enumerate(lines):
            if card[:1] in ("*", ".") or card[1:2] == "/":
                continue
            op = operation(card)
            if op is None or op not in macros:
                continue
            # A PRINT card is not evidence of anything: it emits no object
            # code, and the one place it turns up as the card after a call is
            # where it belongs to a DIFFERENT call whose own output was
            # suppressed.  PSA.asm has exactly that -- `PSA EX4`, then the
            # dropped `$POF`, then $POF's PRINT NOGEN/GEN pair with the `DS`
            # gone from between them -- and reading the pair as PSA's
            # expansion commented out a call the original build really did
            # make.  Skip PRINT and judge by the next card that could carry
            # object code.
            nxt = None
            for j in range(i + 1, min(i + 6, len(lines))):
                if not lines[j].strip():
                    continue
                if operation(lines[j]) == "PRINT":
                    continue
                nxt = lines[j]
                break
            if nxt is None or level(nxt) <= level(card):
                continue
            if op in KEEP:
                kept[op] += 1
                continue
            padded = "%-80s" % card[:80]
            if padded[70] != " ":
                print("  REFUSED %s:%d -- column 71 is not blank" %
                      (os.path.basename(path), i + 1))
                continue
            lines[i] = ("*" + padded[:70] + padded[71:]).rstrip()
            changed += 1
            byMacro[op] += 1
        if changed:
            total += changed
            print("  %-30s %6d" % (os.path.basename(path), changed))
            if apply:
                open(path, "w").write("\n".join(lines))
    print("by macro: %s" % dict(byMacro.most_common()))
    print("kept (expansion suppressed by PRINT NOGEN): %s" % dict(kept))
    print("TOTAL %d cards%s" % (total, "" if apply else "  (dry run)"))
    return 0

sys.exit(main())
