#!/usr/bin/env python3
"""The layers between compilePASS's objects and the link, each a stated rule.

    derive.py TREE WORK ASM101Sa

Every rule here was established by regenerating the layer that built the v36
volume and comparing it byte for byte (2026-09-10).  Before this file they
existed only as the unexplained contents of ~/pass-build/OI340700 and of
/tmp/claude-1000, which is why no one could rebuild the tape.

  TREE/SYSLIBL1/   one entry per section (SD) an object defines, a hard link
                   to that object; objects taken in NAME ORDER, first definer
                   wins (true of all 63 names defined more than once), and
                   START excluded -- it is the NOSDL stack csect.  Reproduces
                   all 4,275 linked entries of the staged library.
  TREE/lib/runtime/RUN/   every RUNASM/*.asm assembled with --fill=C6C6.
                   compilePASS now assembles with C9FB -- deliberately, since
                   the DASS dumps' assembler csects are C9FB -- but the runtime
                   library v36 linked was assembled before that change, and 94
                   of its 205 modules differ in fill halfwords only.  C6C6 is
                   kept to reproduce the verified volume; it is a padding
                   deviation from the flight machine, recorded, not endorsed.
  TREE/lib/runtime/ZCON/  compilePASS's object for every ZCONASM/*.asm
                   (fill does not reach them: 284 of 284 identical).
  WORK/sdfpad/     TREE/SDFLIB with each 3,360-byte SDF extended by one zero
                   byte: con80build accepts a prebuilt SDF only if it is
                   LARGER than 3,360 bytes, and 132 are exactly that.
  WORK/pchsrc/     SSSRC/PCH*.asm with the extension removed: con80build's
                   _PATCH_SRC_RE assumes an extensionless member name.
  WORK/extsyms/extsyms-phNN.json   the csect table of the configuration each
                   phase belongs to, from PFS/mafgen/csects-<CFG>.json keeping
                   start/end/type only; byte-identical to the 11 tables v36
                   used.  The configuration was chosen per phase by counting
                   how many of the phase's linked csects each DASS dump holds;
                   the answer was unambiguous every time.
"""
import json
import os
import shutil
import subprocess
import sys

TREE, WORK, ASM = sys.argv[1], sys.argv[2], sys.argv[3]
PFS = os.environ.get("PFS", os.path.expanduser("~/workspace/PFS"))
PHASE_CONFIG = {"03": "G9", "04": "G16", "05": "G2", "06": "G3", "07": "G8",
                "08": "G9", "09": "P9", "12": "P9", "14": "S2", "15": "S2",
                "18": "G9"}


def ebcdic(b):
    return b.decode("cp037", errors="replace")


def section_defs(path):
    d = open(path, "rb").read()
    out = []
    for i in range(0, len(d) - 79, 80):
        c = d[i:i + 80]
        if ebcdic(c[1:4]) != "ESD":
            continue
        n = int.from_bytes(c[10:12], "big")
        off, k = 16, 0
        while k < n:
            if c[off + 8] == 0:                      # SD
                out.append(ebcdic(c[off:off + 8]).strip())
            off += 16
            k += 16
    return out


objs = os.path.join(TREE, "objects")

# SYSLIBL1
lib = os.path.join(TREE, "SYSLIBL1")
shutil.rmtree(lib, ignore_errors=True)
os.makedirs(lib)
n = 0
for f in sorted(os.listdir(objs)):
    for name in section_defs(os.path.join(objs, f)):
        if not name or name == "START":
            continue
        dst = os.path.join(lib, name + ".obj")
        if not os.path.exists(dst):
            os.link(os.path.join(objs, f), dst)
            n += 1
print("  SYSLIBL1: %d entries" % n)

# lib/runtime
run = os.path.join(TREE, "lib", "runtime", "RUN")
zcon = os.path.join(TREE, "lib", "runtime", "ZCON")
for d in (run, zcon):
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
bad = 0
for f in sorted(os.listdir(os.path.join(TREE, "RUNASM"))):
    if not f.endswith(".asm"):
        continue
    stem = f[:-4]
    r = subprocess.run([ASM, "--object=" + os.path.join(run, stem + ".obj"),
                        "--library=RUNMAC", "--tolerable=4", "--fill=C6C6",
                        "--no-rtl-fixes", os.path.join("RUNASM", f)],
                       cwd=TREE, stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)
    if r.returncode != 0 or not os.path.exists(os.path.join(run, stem + ".obj")):
        bad += 1
for f in sorted(os.listdir(os.path.join(TREE, "ZCONASM"))):
    if f.endswith(".asm"):
        shutil.copy2(os.path.join(objs, f[:-4] + ".obj"), zcon)
print("  lib/runtime: RUN %d (%d failed), ZCON %d"
      % (len(os.listdir(run)), bad, len(os.listdir(zcon))))
if bad:
    sys.exit("runtime assembly failed")

# sdfpad
pad = os.path.join(WORK, "sdfpad")
shutil.rmtree(pad, ignore_errors=True)
shutil.copytree(os.path.join(TREE, "SDFLIB"), pad)
np = 0
for f in os.listdir(pad):
    p = os.path.join(pad, f)
    if os.path.getsize(p) == 3360:
        with open(p, "ab") as fh:
            fh.write(b"\0")
        np += 1
print("  sdfpad: %d SDFs, %d padded" % (len(os.listdir(pad)), np))

# pchsrc
pch = os.path.join(WORK, "pchsrc")
shutil.rmtree(pch, ignore_errors=True)
os.makedirs(pch)
for f in os.listdir(os.path.join(TREE, "SSSRC")):
    if f.startswith("PCH") and f.endswith(".asm"):
        shutil.copy2(os.path.join(TREE, "SSSRC", f), os.path.join(pch, f[:-4]))
print("  pchsrc: %d" % len(os.listdir(pch)))

# per-phase csect tables
xs = os.path.join(WORK, "extsyms")
os.makedirs(xs, exist_ok=True)
for ph, cfg in PHASE_CONFIG.items():
    src = json.load(open(os.path.join(PFS, "mafgen", "csects-%s.json" % cfg)))
    tab = {k: {f: v[f] for f in ("start", "end", "type") if f in v}
           for k, v in src.items()}
    open(os.path.join(xs, "extsyms-ph%s.json" % ph), "w").write(json.dumps(tab))
print("  extsyms: %d per-phase tables" % len(PHASE_CONFIG))
