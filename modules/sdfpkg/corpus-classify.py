#!/usr/bin/env python3
'''
Classify the failures in a compilePASS log.

    corpus-classify.py .../compilePASS.log

Counting failures by grepping ": Compiling" against "Compilation successful"
does not work: the log carries two phase headers ("Compiling independent
templates ...", "... dependent ...") that inflate the attempt count, and the
filenames differ depending on whether the preprocessor ran -- APPLSRC/X.hal
without it, ./_X.hal with it.  Both traps produced false alarms.
'''

import re
import sys
import collections

if len(sys.argv) != 2:
    print(__doc__)
    sys.exit(1)

HEADERS = ("dependent", "independent")   # phase banners, not compilation units

current = None
succeeded = False
buffered = []
groups = collections.defaultdict(list)
attempted = 0


def flush():
    if current is None or current in HEADERS:
        return
    if succeeded:
        return
    text = "\n".join(buffered)
    found = re.findall(r'PASS1 errors \(([^)]*)\)'
                       r'|([A-Z]{1,3}\d{1,3}) error in (\w+)', text)
    key = ";".join(sorted({a or "%s in %s" % (b, c) for a, b, c in found}))
    groups[key or "unknown"].append(current)


for line in open(sys.argv[1], errors="replace"):
    match = re.search(r'\d+: Compiling (\S+)', line)
    if match:
        flush()
        current = re.sub(r'^.*/|\.hal$', '', match.group(1))
        succeeded = False
        buffered = []
        if current not in HEADERS:
            attempted += 1
    buffered.append(line)
    if "Compilation successful" in line:
        succeeded = True
flush()

failures = sum(len(v) for v in groups.values())
print("  attempted %d, successful %d, failures %d"
      % (attempted, attempted - failures, failures))
for key, units in sorted(groups.items(), key=lambda kv: -len(kv[1])):
    print("    %3d  %s" % (len(units), key))
    print("         %s" % " ".join(sorted(units))[:250])
