#!/usr/bin/env python3
"""Classify a module's SECOND-BYTE mismatches -- the byte carrying the
addressing mode and the base register -- from an ASM101S listing produced with
--compare.

    classes.py LISTING [CLASS ...]

With no CLASS, prints the counts.  With one or more (e.g. `F8->FB`), prints
every card in those classes.

TWO THINGS THAT HAVE GONE WRONG HERE BEFORE AND ARE GUARDED AGAINST:

  - `Comparison mismatch: XX vs YY` prints OURS FIRST.  Confirmed against a
    card whose bytes were known independently.  Read it backwards and every
    conclusion about which side is doing what inverts.

  - THE CARD FOLLOWS ITS MISMATCHES.  The assembler emits the mismatch lines
    and then the card they belong to, so a mismatch is attached to the NEXT
    card line, never the previous one.  `grep -B` shows the cards a mismatch
    does NOT belong to.

Do not point this at a listing that is currently being written -- `one.sh`
writes BILDNEW5.lst in place, and reading it mid-run yields nothing at all
rather than an error.  Snapshot it first.
"""
import re, sys, collections

MM = re.compile(r'^Comparison mismatch: ([0-9A-F]{2}) vs ([0-9A-F]{2})\s*$')
CARD = re.compile(r'^([0-9A-F]{5}) ')

def rows(path):
    pend = []
    out = []
    for line in open(path, errors='replace'):
        m = MM.match(line)
        if m:
            pend.append((m.group(1), m.group(2)))
            continue
        c = CARD.match(line)
        if c:
            for a, b in pend:
                # Only the addressing/base byte: both sides in the F0-FF range.
                if a[0] == 'F' and b[0] == 'F':
                    out.append((a + "->" + b, int(c.group(1), 16),
                                line[6:30].strip(), line[40:96].rstrip()))
            pend = []
    return out

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    r = rows(sys.argv[1])
    wanted = sys.argv[2:]
    by = collections.defaultdict(list)
    for k, addr, obj, txt in r:
        by[k].append((addr, obj, txt))
    if not r:
        print("NO second-byte mismatches found -- check the listing is complete "
              "and was produced with --compare")
        return 0
    print("second-byte mismatches: %d in %d classes" % (len(r), len(by)))
    for k in sorted(by, key=lambda k: -len(by[k])):
        print("   %-9s %d" % (k, len(by[k])))
    for k in wanted:
        print("\n=== %s (%d)" % (k, len(by.get(k, []))))
        for addr, obj, txt in by.get(k, []):
            print("   %05X  %-20s %s" % (addr, obj, txt))
    return 0

sys.exit(main())
