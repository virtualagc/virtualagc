#!/usr/bin/env python3
'''Survey the last editing date of each source file, from its ORIGINAL comments.

Usage:  source-dates.py DIR [DIR ...] [--csv=F.csv] [--report]

WHY.  The source we hold predates HALSTAT.ASC, which predates the DASS dumps, so
where a linked module does not match the dump the difference may be a change
made to the source AFTER our copy was taken rather than a defect in ASM101S or
lnk101.  Knowing when each file was last edited bounds that: a module whose
comments stop in 1984 is a poor candidate for having been revised into the 2010
build, while one edited late is a good one.

WHAT COUNTS AS EVIDENCE.  Only the ORIGINAL comments.  The Virtual AGC headers
prefix every line with `*/` and carry ISO dates of their own preparation
(`2024-12-10 RSB  Prepared from original source module.`); counting those would
date every file to the same recent day and say nothing.  They are skipped.

The originals date themselves in two ways, both read here:

    *              ^hq            08/28/78  PCR28989.EFFICIENCY REDESIGN.
    * UPDATE  - PROGRAMMER  CHANGE DATE  PURPOSE

a MM/DD/YY change-record column, and occasional inline dates in the same form.
Two-digit years are read against the programme's own span: 70-99 as 19xx and
00-19 as 20xx, since nothing here predates the mid-1970s or follows 2011.

WHAT IT DOES NOT DO.  It reports the latest date it can SEE, which is a lower
bound on the true last edit -- a change made without a comment is invisible.
That asymmetry is the point: a late date is evidence, an early one is only the
absence of it.
'''

import sys, os, re, glob, csv, collections

DATE = re.compile(r"\b(\d{2})/(\d{2})/(\d{2})\b")

def isOriginalComment(card):
    body = card[:72]
    if body.startswith("*/") or body.startswith(".*/"):
        return False                      # Virtual AGC's own header
    return body.startswith("*") or body.startswith(".*")

def scan(path):
    latest = None
    count = 0
    for line in open(path, errors="replace"):
        card = line.rstrip("\r\n")
        if not isOriginalComment(card):
            continue
        for mm, dd, yy in DATE.findall(card[:72]):
            m, d, y = int(mm), int(dd), int(yy)
            if not (1 <= m <= 12 and 1 <= d <= 31):
                continue
            year = 1900 + y if y >= 70 else 2000 + y
            if not (1975 <= year <= 2011):
                continue
            count += 1
            iso = (year, m, d)
            if latest is None or iso > latest:
                latest = iso
    return latest, count

dirs = [a for a in sys.argv[1:] if not a.startswith("--")]
csvOut = next((a.partition("=")[2] for a in sys.argv[1:]
               if a.startswith("--csv=")), None)
report = "--report" in sys.argv
if not dirs:
    print(__doc__); sys.exit(1)

rows = []
for d in dirs:
    for ext in ("asm", "hal", "dfg"):
        for p in sorted(glob.glob(os.path.join(d, "*." + ext))):
            latest, count = scan(p)
            rows.append({"file": os.path.basename(p),
                         "dir": os.path.basename(os.path.dirname(p)),
                         "type": ext,
                         "last_dated_comment":
                             "%04d-%02d-%02d" % latest if latest else "",
                         "dated_comments": count})

if csvOut:
    with open(csvOut, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)

byYear = collections.Counter(r["last_dated_comment"][:4] or "(none)"
                             for r in rows)
print("%d file(s) surveyed; latest dated ORIGINAL comment by year:" % len(rows))
for y in sorted(byYear):
    print("   %-7s %4d" % (y, byYear[y]))
undated = [r["file"] for r in rows if not r["last_dated_comment"]]
if undated:
    print("   %d file(s) carry no dated original comment, e.g. %s"
          % (len(undated), " ".join(undated[:6])))
if report:
    print("\nlatest first:")
    for r in sorted(rows, key=lambda r: r["last_dated_comment"], reverse=True)[:25]:
        print("   %-12s %-6s %s  (%d dated comment(s))"
              % (r["file"], r["type"], r["last_dated_comment"] or "-",
                 r["dated_comments"]))
if csvOut:
    print("\n-> %s" % csvOut)
