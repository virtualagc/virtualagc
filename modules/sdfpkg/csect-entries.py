#!/usr/bin/env python3
'''Index the ENTRY points of every module that already matches the dump, from
our own object files.

Usage:  csect-entries.py --work=DIR --config=XXX --out=F.json
                        [--base=F.json] [--results=F.tsv] [--report]

WHY THIS IS THE BEST SOURCE OF THE THREE.  An assembly module's entry points are
not in HALSTAT, which describes HAL/S compilation units, and recovering them by
inverting relocations against the dump is inference.  But the object file states
each one's offset within its control section outright, and the CSECT index gives
that section's address, so the absolute address is arithmetic on two things we
already trust -- PROVIDED the module's own bytes are right.

That proviso is the whole of the method.  An entry offset is only as good as the
assembly that produced it, so only modules whose comparison against the dump
PASSES are harvested; a module that differs may have its labels in the wrong
places, and indexing those would inject exactly the sort of confident, wrong
address this phase keeps having to undo.  clc-sweep.py's TSV says which modules
passed.

WHAT IT IS FOR.  The save areas are the case that prompted it.  RETURN names a
program's GPR save area `'&PMCSECT'(1,2).'$'.'&PMCSECT'(4,5)` -- FC$BUSPC for
FCMBUSPC -- and every one of them is defined in FCMSAVE.asm and declared ENTRY
there.  Once ASM101S stopped losing the `LM` that restores the registers, every
module referenced its own save area and 458 symbols of this kind became the
largest single class of unresolved reference in G16.  FCMSAVE passes, so its
offsets are exact.
'''

import sys, os, json, glob, subprocess, re

work = config = out = base = results = None
report = False
for p in sys.argv[1:]:
    if p.startswith("--work="): work = p.partition("=")[2]
    elif p.startswith("--config="): config = p.partition("=")[2]
    elif p.startswith("--out="): out = p.partition("=")[2]
    elif p.startswith("--base="): base = p.partition("=")[2]
    elif p.startswith("--results="): results = p.partition("=")[2]
    elif p == "--report": report = True
    else:
        print(__doc__); sys.exit(1)
if not (work and config and out and results):
    print(__doc__); sys.exit(1)
base = base or os.path.join(work, "..", "mafgen", "augmented-%s.json" % config)

passed = set()
for line in open(results):
    f = line.rstrip("\n").split("\t")
    if len(f) > 2 and f[2] == "PASS":
        passed.add(f[0])

table = json.load(open(base))
known = set(table)
for v in table.values():
    known |= set(v.get("contents") or {})

# objDump.py prints the ESD as
#     ESD#1   SD  FCMSAVE   addr=000000  len=  2096
#     ESD#2   LD  FP$COMSA  addr=0000A4  len=     0
# with addresses in BYTES, the object format's unit; the index works in
# halfwords, which is the /2 below.
ESD = re.compile(r"ESD#(\d+)\s+(SD|LD)\s+(\S+)\s+addr=([0-9A-F]+)")
objdump = os.path.expanduser("~/git/virtualagc/ASM101S/objDump.py")

added = skipped = noSect = 0
lines = []
for obj in sorted(glob.glob(os.path.join(work, "clc-%s" % config, "*.obj"))):
    module = os.path.basename(obj)[:-4]
    if module not in passed:
        skipped += 1
        continue
    try:
        txt = subprocess.run(["python3", objdump, obj], capture_output=True,
                             text=True, timeout=120).stdout
    except Exception:
        continue
    sect = None
    for m in ESD.finditer(txt):
        kind, name, addr = m.group(2), m.group(3), int(m.group(4), 16)
        if kind == "SD":
            sect = name
            continue
        if sect is None or sect not in table or name in known:
            continue
        start = table[sect].get("start")
        if start is None:
            noSect += 1
            continue
        table[sect].setdefault("contents", {})[name] = addr // 2
        added += 1
        if report:
            lines.append("  %-9s %#07x = %s+%#x"
                         % (name, start + addr // 2, sect, addr // 2))

json.dump(table, open(out, "w"))
for l in lines:
    print(l)
print("%s: %d entry point(s) indexed from %d passing module(s); %d module(s) "
      "skipped as not yet matching, %d entry(ies) in a section the index does "
      "not place -> %s"
      % (config, added, len(passed), skipped, noSect, out))
