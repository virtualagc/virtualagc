#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   fcos-diagnostics.py
Purpose:    Count ASM101S's diagnostics across the whole FCOS corpus, so that
            the common ones can be seen at all.
Reference:  Reads the directory written by fcos-diagnostics.sh.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

WHAT THIS IS FOR.  Classifying a module by exit status was the right
instrument while most of the corpus was crashing.  It is the wrong one now
that most modules assemble far enough to complain, because "ERRORS" says
nothing about whether a module produced two diagnostics or three hundred, nor
which.  This counts them.

TWO NUMBERS ARE REPORTED FOR EACH MESSAGE AND THEY MEAN DIFFERENT THINGS.
BREADTH is how many modules produce it at all, and is what to prioritise by:
a message from 90 modules is one defect worth fixing, whatever its volume.
VOLUME is the total number of occurrences, and is mostly a measure of how
often the offending construct appears -- one module with a 300-line table can
dominate it entirely and mean nothing.

EACH DIAGNOSTIC IS EMITTED ONCE PER ASSEMBLY PASS, so the same complaint
appears with Pass 1, Pass 2 and Pass 3 prefixes.  Counting all of them would
treble every number.  Pass -1 is macro-expansion time and does not repeat.
This counts the highest-numbered pass present plus all of Pass -1.

Usage:
    fcos-diagnostics.py DIR [--top=N] [--raw] [--message=TEXT]

    --top=N        show N messages, default 25
    --raw          do not normalise identifiers out of the messages
    --message=TEXT show the modules producing messages matching TEXT, and
                   stop; use it to drill into one finding
'''

import sys, os, re, collections

def normalise(msg):
    '''Replace the parts of a message that vary from one occurrence to the
    next, so that occurrences of the same complaint group together.  The
    order matters: quoted text first, since it may contain anything.'''
    s = msg
    s = re.sub(r"'[^']*'", "'...'", s)
    s = re.sub(r'"[^"]*"', '"..."', s)
    s = re.sub(r'&[A-Z#$@][A-Z#$@0-9]*', '&VAR', s)
    s = re.sub(r'\b[0-9]+\b', 'N', s)
    # A bare symbol is upper case and at least two characters.  Done last, and
    # only where the message names one at the end, which is the common shape.
    s = re.sub(r'\b[A-Z#$@][A-Z#$@0-9]{2,}\b', 'SYM', s)
    return s.strip()

LINE = re.compile(r'^\(Pass (-?\d+), Severity (\d+)\)\s*(.*)$')

def readModule(path):
    '''Return the diagnostics of one module as a list of (severity, message),
    counting each complaint once rather than once per pass.'''
    byPass = collections.defaultdict(list)
    try:
        for line in open(path, errors='replace'):
            m = LINE.match(line.rstrip('\n'))
            if m:
                byPass[int(m.group(1))].append((int(m.group(2)), m.group(3)))
    except OSError:
        return []
    if not byPass:
        return []
    out = list(byPass.get(-1, []))
    numbered = [p for p in byPass if p >= 0]
    if numbered:
        out += byPass[max(numbered)]
    return out

def main():
    args = [a for a in sys.argv[1:]]
    top, raw, drill = 25, False, None
    positional = []
    for a in args:
        if a.startswith('--top='):
            top = int(a.split('=', 1)[1])
        elif a == '--raw':
            raw = True
        elif a.startswith('--message='):
            drill = a.split('=', 1)[1]
        else:
            positional.append(a)
    if not positional:
        print(__doc__)
        return 1
    directory = positional[0]

    volume = collections.Counter()
    breadth = collections.defaultdict(set)
    severity = {}
    perModule = collections.Counter()
    modules = 0
    silent = []
    for name in sorted(os.listdir(directory)):
        if not name.endswith('.diag'):
            continue
        modules += 1
        module = name[:-5]
        diags = readModule(os.path.join(directory, name))
        if not diags:
            silent.append(module)
            continue
        perModule[module] = len(diags)
        for sev, msg in diags:
            key = msg if raw else normalise(msg)
            volume[key] += 1
            breadth[key].add(module)
            severity.setdefault(key, set()).add(sev)

    if drill:
        print('Modules producing a message matching %r:\n' % drill)
        for name in sorted(os.listdir(directory)):
            if not name.endswith('.diag'):
                continue
            hits = [m for s, m in readModule(os.path.join(directory, name))
                    if drill in m]
            if hits:
                sample = collections.Counter(hits).most_common(2)
                print('  %-28s %4d   %s' % (name[:-5], len(hits), sample[0][0][:70]))
        return 0

    print('%d modules examined, %d produced no diagnostics at all.' %
          (modules, len(silent)))
    print('%d distinct messages, %d occurrences in total.\n' %
          (len(volume), sum(volume.values())))

    print('BY BREADTH -- how many modules produce it.  Prioritise by this.\n')
    print('  %-6s %-8s %-6s  %s' % ('mods', 'occurs', 'sev', 'message'))
    for key in sorted(volume, key=lambda k: (-len(breadth[k]), -volume[k]))[:top]:
        sev = ','.join(str(s) for s in sorted(severity[key]))
        print('  %-6d %-8d %-6s  %s' % (len(breadth[key]), volume[key], sev, key[:96]))

    print('\nBY VOLUME -- total occurrences.  A single big table can dominate.\n')
    print('  %-6s %-8s %-6s  %s' % ('occurs', 'mods', 'sev', 'message'))
    for key in sorted(volume, key=lambda k: -volume[k])[:top]:
        sev = ','.join(str(s) for s in sorted(severity[key]))
        print('  %-6d %-8d %-6s  %s' % (volume[key], len(breadth[key]), sev, key[:96]))

    print('\nNOISIEST MODULES\n')
    for module, n in perModule.most_common(10):
        print('  %-28s %d' % (module, n))
    return 0

if __name__ == '__main__':
    sys.exit(main())
