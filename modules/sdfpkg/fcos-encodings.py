#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   fcos-encodings.py
Purpose:    Read the object code the ORIGINAL BUILD generated, statement by
            statement, out of the "as received" FCOS listings.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

WHY THIS EXISTS.  ~/workspace/PFS/"OI301700 as received"/SSSRC holds, for
every module, a listing giving the object code each statement assembled to
before relocation.  That is to FCOS what RUNLST is to RUNASM:  the only
primary evidence of what ASM101S ought to produce.  Until 2026-08-09 it had
never been used.

It has already settled two questions that neither the POO nor the source could
answer.  The '$' mnemonic suffix, which appears in no manual, was identified as
"force the long form" by comparing BC$ against ASM101S's own output for BC with
a large displacement.  CNOP's semantics -- operand counted in halfwords, target
its parity, and a different no-op for each processor -- were read off 111
instances.

WHAT IT IS FOR NEXT.  All 96 of the '@' (MSC) and '#' (BCE) instructions are
known to ASM101S by name with an opcode of -1, and it emits four zero bytes
for them.  75 of the 96 appear here WITH THEIR REAL ENCODINGS, many of them
hundreds of times, which is enough to derive most of the instruction set
empirically and to check the rest against the POO.

    fcos-encodings.py --mnemonic=@BU        every use, with its object code
    fcos-encodings.py --summary             all mnemonics, commonest codes
    fcos-encodings.py --summary --family=@  just the MSC set

LISTING FORMAT.  Column 1 is an ANSI carriage-control character -- blank, or
'1' for a page eject -- which RUNLST does not have, so everything sits one
column further right than in RUNLST.  After that:

    00C14 C7F2 0000      0000      6526 STM1392  BC$   7,0(R2)   comment
    addr  object code    eff addr  line statement

with the address and the effective address in HALFWORDS.
'''

import sys, os, re, glob, collections

LISTINGS = os.path.expanduser('~/workspace/PFS/OI301700 as received/SSSRC')

def readListing(path):
    '''Yield (address, objectCode, statement) for every line that generated
    object code.  `objectCode` is a hex string without spaces.'''
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\r\n')
        if not line:
            continue
        line = line[1:]                     # drop the carriage-control column
        if not re.match(r'[0-9A-F]{5} ', line):
            continue
        chunks = re.split(r'\s{2,}', line.strip())
        tokens = chunks[0].split()
        code = ''.join(tokens[1:])
        if not code or not re.fullmatch(r'[0-9A-F]+', code):
            continue
        yield int(tokens[0], 16), code, line

# The operation is the first field that is not a label.  A label starts in
# column 1 of the statement area, so a leading run of non-blanks followed by
# blanks is a label rather than the operation.
OPERATION = re.compile(r'(?:^|\s)([@#]?[A-Z][A-Z0-9@#$]*)\s')

def operationOf(line, statementColumn=36):
    tail = line[statementColumn:]
    m = OPERATION.search(' ' + tail)
    return m.group(1) if m else None

def main():
    mnemonic = family = None
    summary = False
    for a in sys.argv[1:]:
        if a.startswith('--mnemonic='): mnemonic = a.split('=', 1)[1]
        elif a.startswith('--family='): family = a.split('=', 1)[1]
        elif a == '--summary': summary = True
        else:
            print(__doc__); return 1
    if not os.path.isdir(LISTINGS):
        print("No listings at %s" % LISTINGS, file=sys.stderr); return 1
    if not (summary or mnemonic):
        print(__doc__); return 1

    found = collections.defaultdict(list)
    for path in sorted(glob.glob(os.path.join(LISTINGS, '*'))):
        if os.path.isdir(path): continue
        for addr, code, line in readListing(path):
            op = operationOf(line)
            if op is None: continue
            if family and not op.startswith(family): continue
            if mnemonic and op != mnemonic: continue
            found[op].append((os.path.basename(path), addr, code, line))

    if mnemonic:
        rows = found.get(mnemonic, [])
        print("%s: %d uses with object code\n" % (mnemonic, len(rows)))
        for mod, addr, code, line in rows[:60]:
            print("  %-10s %05X %-10s %s" % (mod, addr, code, line[36:96].rstrip()))
        if len(rows) > 60:
            print("  ... and %d more" % (len(rows) - 60))
        return 0

    print("%d mnemonics generated object code in the listings\n" % len(found))
    for op in sorted(found):
        codes = collections.Counter(c for _, _, c, _ in found[op])
        widths = sorted({len(c) // 2 for c in codes})
        print("  %-9s %5d uses  %s bytes  %s" % (
            op, len(found[op]), '/'.join(str(w) for w in widths),
            ', '.join('%s(%d)' % (c, n) for c, n in codes.most_common(3))))
    return 0

if __name__ == '__main__':
    sys.exit(main())
