#!/usr/bin/env python3
'''
Run compileLinkCompare over every in-scope module of one PASS configuration and
report, one TSV row per module: module, tree, status, sections matched, sections
differing, HALFWORDS differing, detail.

WHY THIS EXISTS.  OI340600 has no assembly listings, so "does it assemble" is
not a result -- the result is whether the LINKED image matches the DASS memory
dump.  compileLinkCompare does one module; this drives it over a whole
configuration and reduces the reports to something countable.

HALFWORDS, NOT BYTES, is the reporting unit, which costs nothing here because
fcmcmp already reports that way.  Byte granularity actively misled the OI301700
phase: `EDF3 1580` against `EDF1 00A6` is ONE wrong halfword pair, not three
wrong bytes.

SCOPE IS THE CSECT TABLE, not the source directory.  A configuration is built
from a subset of the sources, and augmented-XXX.json names the CSECTs that are
in it -- so a module absent from that table was not in the build and cannot be
compared against it.  BILDNEW5 is one of those.  Modules are matched to CSECTs
by name here, which is an approximation: a module whose CSECT is named
differently from its file looks out of scope when it is not, so `--scope-report`
prints what was excluded rather than leaving it silent.

THE NOISE IN A REPORT THAT IS NOT A RESULT, per the user, 2026-08-12: the note
that the two images differ in SIZE (they always do -- one module against a whole
memory), and the closing git commit/hashcode/checksum block.  Both are dropped.
'''

import sys, os, json, glob, subprocess, re
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

def usage():
    print(__doc__)
    print("Usage: clc-sweep.py --work=DIR --config=XXX [--out=FILE] [--jobs=N]")
    print("                    [--tree=SSSRC|RUNASM|both] [--only=M1,M2,...]")
    print("                    [--scope-report] [--reports=DIR]")
    sys.exit(1)

work = None; config = "SSW"; out = None; jobs = 6; tree = "both"
only = None; scopeReport = False; reports = None; fromReports = None
for p in sys.argv[1:]:
    if p.startswith("--work="): work = p.partition("=")[2]
    elif p.startswith("--config="): config = p.partition("=")[2]
    elif p.startswith("--out="): out = p.partition("=")[2]
    elif p.startswith("--jobs="): jobs = int(p.partition("=")[2])
    elif p.startswith("--tree="): tree = p.partition("=")[2]
    elif p.startswith("--only="): only = set(p.partition("=")[2].split(","))
    elif p.startswith("--reports="): reports = p.partition("=")[2]
    elif p.startswith("--from-reports="): fromReports = p.partition("=")[2]
    elif p == "--scope-report": scopeReport = True
    else: usage()
if work is None: usage()

work = Path(work).expanduser()
if not (work / "SSSRC").is_dir(): sys.exit(f"no SSSRC in {work}")
csectTable = work.parent / "mafgen" / f"augmented-{config}.json"
if not csectTable.is_file(): sys.exit(f"missing {csectTable}")
inConfig = set(json.load(open(csectTable)))

# The macro library is per tree and they are not interchangeable: MLIB80 is the
# FCOS library, RUNMAC the runtime library's.  INCL80 and INCLIB belong to the
# HAL/S compiler and are not assembler libraries at all.
TREES = {"SSSRC": "MLIB80", "RUNASM": "RUNMAC"}
if tree != "both": TREES = {tree: TREES[tree]}

work_items, excluded = [], []
for t, lib in TREES.items():
    if not (work / t).is_dir(): continue
    for path in sorted(glob.glob(str(work / t / "*.asm"))):
        m = Path(path).stem
        if only is not None and m not in only: continue
        if m in inConfig: work_items.append((m, t, lib))
        else: excluded.append((m, t))

if scopeReport:
    print(f"config {config}: {len(work_items)} in scope, {len(excluded)} excluded")
    for m, t in excluded: print(f"  excluded {t}/{m}")

if reports: os.makedirs(reports, exist_ok = True)
outDir = str(work / f"clc-{config}")

# The three lines fcmcmp states a result on.  A per-section line carries the
# section, its address, its size and -- only when it differs -- how many
# halfwords do.
# THREE line forms, not one, and the third was silently dropped: a section
# whose size disagrees with the CSECT table reads
#     FAIL: FPMFXMTU @ 1AC58 (128 halfwords vs 130 expected) - 34 halfwords differ
# so a pattern ending at `halfwords)` matched neither it nor its difference
# count, and such a module counted 0 sections of 0.  A size disagreement is a
# finding in its own right -- we laid down 128 halfwords where the original
# build had 130 -- so it is counted, not merely parsed.
reSect = re.compile(r"^\s*(OK|FAIL|SKIP|WARN|NOTE):\s+(\S+)\s+@\s+([0-9A-F]+)"
                    r"\s+\((\d+) halfwords?(?: vs (\d+) expected)?\)(.*)$")
reDiff = re.compile(r"(\d+) halfwords? differ")
# fcmcmp writes "all 1 sections match" but "1/1 section(s) differ" -- with
# LITERAL PARENTHESES.  A `sections?` here matched the PASS line and missed
# every FAIL line, so each failing module was classified NOCOMPARE, i.e. as a
# harness problem rather than as the result it actually was.
reTotal = re.compile(r"^(PASS|FAIL):\s+(?:all (\d+) section\(?s\)? match"
                     r"|(\d+)/(\d+) section\(?s\)? differ)")

def classify(m, t, txt):
    '''Reduce one compileLinkCompare report to a row.  This is the ONLY
    classifier: a live run and a --from-reports pass both come through here, so
    the two cannot disagree.  Two derivations of one quantity disagreeing was
    the cause of most defects in the OI301700 phase.'''
    ok = differ = hwDiff = badSize = 0
    for line in txt.splitlines():
        mo = reSect.match(line)
        if mo:
            if mo.group(5) is not None and mo.group(5) != mo.group(4):
                badSize += 1
            if mo.group(1) == "OK": ok += 1
            else:
                differ += 1
                d = reDiff.search(mo.group(6))
                hwDiff += int(d.group(1)) if d else 0
    forced = "FORCED LINK:" in txt
    if "Assembly failed with exit code" in txt:
        why = [l for l in txt.splitlines() if "intolerable line" in l]
        return (m, t, "ASMFAIL", ok, differ, hwDiff,
                (why[-1] if why else "see report"), txt)
    tot = None
    for line in txt.splitlines():
        mo = reTotal.match(line)
        if mo: tot = mo
    if tot is None:
        first = [l for l in txt.splitlines()
                 if "Linking failed" in l or "nothing to compare" in l
                 or "no image" in l]
        return (m, t, "NOCOMPARE", ok, differ, hwDiff,
                (first[0] if first else "no fcmcmp verdict"), txt)
    status = "PASS" if tot.group(1) == "PASS" else "FAIL"
    if forced: status += "-FORCED"
    return (m, t, status, ok, differ, hwDiff,
            (f"{badSize} section(s) sized differently from the CSECT table"
             if badSize else ""), txt)

def runOne(item):
    m, t, lib = item
    clc = subprocess.run(["which", "compileLinkCompare"], capture_output = True,
                         text = True).stdout.strip() or "compileLinkCompare"
    cmd = ["python3", "-u", clc, f"--config={config}", f"--library={lib}",
           f"--filename={t}/{m}.asm", f"--out-dir={outDir}"]
    # A TIMEOUT, because one module that never returns otherwise stops the whole
    # run and it reports success with a row missing.  PIPED OUTPUT IS LOST WHEN A
    # COMMAND IS KILLED, which is why the report is written out per module.
    try:
        r = subprocess.run(cmd, cwd = work, capture_output = True, text = True,
                           timeout = 1800)
        txt = r.stdout + r.stderr
    except subprocess.TimeoutExpired as e:
        out = e.stdout or ""
        txt = out.decode(errors = "replace") if isinstance(out, bytes) else out
        if reports: open(Path(reports) / f"{m}.rpt", "w").write(txt)
        return (m, t, "HANG", 0, 0, 0, "exceeded 1800s", txt)
    if reports:
        open(Path(reports) / f"{m}.rpt", "w").write(txt)
    return classify(m, t, txt)

rows = []
if fromReports:
    # Reclassify reports a previous run saved.  A --reports directory is what
    # makes a classifier defect cost nothing: the evidence is on disk, so the
    # 30-minute sweep is not repeated to correct how it was counted.
    trees = {m: t for m, t, _ in work_items}
    for i, path in enumerate(sorted(glob.glob(str(Path(fromReports) / "*.rpt"))), 1):
        m = Path(path).stem
        r = classify(m, trees.get(m, "?"), open(path).read())
        rows.append(r[:7])
        print(f"[{i}] {r[1]}/{r[0]}\t{r[2]}\t{r[4]} of {r[3]+r[4]} sections "
              f"differ\t{r[5]} halfwords", flush = True)
else:
  with ThreadPoolExecutor(max_workers = jobs) as ex:
    for i, r in enumerate(ex.map(runOne, work_items), 1):
        rows.append(r[:7])
        print(f"[{i}/{len(work_items)}] {r[1]}/{r[0]}\t{r[2]}\t"
              f"{r[4]} of {r[3]+r[4]} sections differ\t{r[5]} halfwords",
              flush = True)

if out:
    with open(out, "w") as f:
        for r in rows:
            f.write("\t".join(str(x) for x in r) + "\n")

byStatus = {}
for r in rows: byStatus[r[2]] = byStatus.get(r[2], 0) + 1
print(f"\n=== {config}: {len(rows)} modules")
for k in sorted(byStatus, key = lambda k: -byStatus[k]):
    print(f"  {byStatus[k]:4d}  {k}")
print(f"  sections differing: {sum(r[4] for r in rows)} of "
      f"{sum(r[3] + r[4] for r in rows)}")
print(f"  halfwords differing: {sum(r[5] for r in rows)}")
