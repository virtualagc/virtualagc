#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-run.py
Purpose:    Drive compileLinkCompare over a memory configuration's source files
            and record the results in the DASS-comparison database.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      cd ~/ForClaude/OI340600-clc && dass-run.py --config=SSW [OPTIONS]

OPTIONs:
    --config=XXX    Memory configuration.  Default SSW.
    --db=F          The database.  Default modules/sdfpkg/dass-compare.db.
    --out-dir=D     Passed to compileLinkCompare.  Default "work".
    --log-dir=D     Where the console output of each run is kept.  Default
                    "logs".  One file per source file, overwritten each time.
    --status=S      Only process files whose membership status is S; repeatable.
                    Default: todo and error.  "--status=all" for everything.
    --only=STEM     Only this source file; repeatable.  Implies --status=all.
    --limit=N       Stop after N files.
    --jobs=N        Run N at once.  Requires --jobs-root; see below.
    --jobs-root=D   Parent directory of the per-job source trees, which must be
                    named D/1, D/2, ... D/N.  HALSFC writes halmat.bin,
                    litfile.bin and COMMON*.out into its current directory and
                    they are not per-compilation names, so two compilations in
                    one directory corrupt each other -- the very failure §3 of
                    HANDOFF.md describes.  Separate trees are the only safe way
                    to run in parallel.
    --dry-run       Print what would be run and stop.
    --reparse       Do not compile anything.  Re-read the saved console output
                    of the last run of each selected file and rebuild its
                    database rows from that.  fcmcmp's report is the whole
                    result, so improving the parser costs nothing but a
                    re-read; the first survey of SSW had to be redone twice
                    because the parser missed fcmcmp's shift analysis, and
                    recompiling 132 files to learn that would have been waste.

This is the driver compileLinkCompare.md says to build *after* the first
mechanism falls, not before it, so that it measures how far a fix reached
rather than hunts for work.  It is written to be re-run: a file already
recorded as matching is not touched again unless asked for by name.
'''

import sys
import os
import re
import json
import time
import sqlite3
import subprocess
import datetime
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, str(Path(__file__).resolve().parent))
import importlib
dassDb = importlib.import_module("dass-db")

# fcmcmp's report, in full.  A worked example, from logs/GI1GPS.log:
#
#     Note: images differ in size (279635 vs 330394 halfwords)
#       FAIL: #EGI1GPS @ 0139E (6 halfwords) — 2 halfwords differ
#                      @ 013A2 0000 vs 199E
#                      @ 013A3 0003 vs 8003
#       OK:   #DGI1GPS @ 013A4 (6 halfwords)
#       FAIL: START    @ 10000 (2 halfwords) — 2 halfwords differ
#                      @ 10000 E4F3 vs C6C6  ; START
#                      @ 10001 C448 vs C6C6  ; RLD $0GI1GPS -> 44448
#       FAIL: $0GI1GPS @ 44448 (11 halfwords vs 9 expected) — 11 halfwords differ
#                      @ 44448 E8F3 vs E9F3  ; $0GI1GPS
#                      ...
#                        ... and 1 more
#                        ** shift +2: 2 halfword(s) inserted in first image near 44448
#                           inserted: E8F3 199E
#                           after shift, all halfwords match
#
#     FAIL: 3/4 section(s) differ
#
# Three things here are easy to lose and expensive to lose.  The dash before
# "N halfwords differ" is an EM DASH, not the hyphen compileLinkCompare.md's
# example shows.  A section line may carry "vs N expected", so the closing
# parenthesis does not always follow "halfwords".  And the shift block is the
# whole diagnosis for this file: eleven differing halfwords, one cause.
SECTION_RE = re.compile(
    r"^\s*(OK|FAIL|MISSING):\s+(\S+)\s+@\s+([0-9A-Fa-f]+)\s+"
    r"\((\d+)\s+halfwords(?:\s+vs\s+(\d+)\s+expected)?\)"
    r"(?:\s*\[(\d+)\s+no reference data\])?"
    r"\s*(?:[-‐-―]\s*(.*))?$")
DIFF_RE = re.compile(r"^\s*@\s*([0-9A-Fa-f]+)\s+(\S+)\s+vs\s+(\S+)"
                     r"\s*(?:;\s*(.*?))?\s*$")
SHIFT_RE = re.compile(r"\*\*\s*shift\s*([+-]\d+):")
INSERTED_RE = re.compile(r"^\s*(?:inserted|deleted):\s*(.*?)\s*$")
AFTER_SHIFT_RE = re.compile(
    r"after shift,\s*(?:(all) halfwords match|(\d+) halfwords? still differ)")
SUMMARY_PASS_RE = re.compile(r"^PASS:\s+all\s+(\d+)\s+sections?\s+match")
SUMMARY_FAIL_RE = re.compile(r"^FAIL:\s+(\d+)/(\d+)\s+section")
NDIFF_RE = re.compile(r"(\d+)\s+halfwords?\s+differ")
RESULTS_RE = re.compile(r'Results stored in the folder "([^"]+)"')


def parseOutput(text):
    '''What fcmcmp said, as (outcome, sections).  sections is a list of dicts.

    outcome is one of match, differ, compile_failed, link_failed,
    compare_failed -- the last meaning fcmcmp produced no section lines at all,
    which is different from producing them and finding differences.
    '''
    if "Compilation failed" in text and "object file was created anyway" \
            not in text:
        return "compile_failed", [], None
    if "Linking failed" in text:
        return "link_failed", [], None

    sections = []
    for line in text.split("\n"):
        m = SECTION_RE.match(line)
        if m:
            verdict, name, addr, halfwords, expected, noData, tail = m.groups()
            n = None
            if tail:
                mm = NDIFF_RE.search(tail)
                if mm:
                    n = int(mm.group(1))
            sections.append({
                "name": name,
                "address": int(addr, 16),
                "halfwords": int(halfwords),
                "expected": int(expected) if expected else None,
                # Halfwords the reference image never stated a value for; see
                # fcmcmp's --no-data.  Neither matched nor differing, so they
                # are recorded rather than folded into either count.
                "no_data": int(noData) if noData else 0,
                "n_diffs": 0 if verdict == "OK" else n,
                "verdict": {"OK": "ok", "FAIL": "differ",
                            "MISSING": "missing"}[verdict],
                "shift": None, "shifted_in": None, "after_shift": None,
                "detail": (tail or "").strip(),
                "diffs": [],
                })
            continue
        if not sections:
            continue
        s = sections[-1]
        m = SHIFT_RE.search(line)
        if m:
            s["shift"] = int(m.group(1))
            continue
        m = AFTER_SHIFT_RE.search(line)
        if m:
            s["after_shift"] = 0 if m.group(1) else int(m.group(2))
            continue
        # Must come after the shift tests: the "inserted:" line sits inside the
        # shift block, and its payload looks nothing like a diff line anyway.
        m = INSERTED_RE.match(line)
        if m and s["shift"] is not None and s["shifted_in"] is None:
            s["shifted_in"] = m.group(1)
            continue
        m = DIFF_RE.match(line)
        if m:
            addr, ours, theirs, annotation = m.groups()
            s["diffs"].append((int(addr, 16), ours, theirs, annotation))

    if not sections:
        return "compare_failed", [], None
    outcome = "match" if all(s["verdict"] == "ok" for s in sections) \
              else "differ"
    return outcome, sections, None


def runOne(job):
    '''Compile/link/compare one source file.  Returns a record to be inserted.

    Everything here is subprocess and file I/O; nothing touches the database,
    so this is safe to run in a thread pool while the main thread does the
    inserts serially.  (sqlite3 connections are not shareable across threads,
    and a single writer avoids lock contention besides.)
    '''
    sourceId, path, config, cwd, outDir, logDir, extra = job
    stem = Path(path).stem
    logPath = Path(logDir) / f"{stem}.log"
    command = ["compileLinkCompare", f"--config={config}",
               f"--out-dir={outDir}", f"--filename={path}"] + extra
    started = datetime.datetime.now().isoformat(timespec = "seconds")
    t0 = time.monotonic()
    env = dict(os.environ)
    # compileLinkCompare's failure paths end in os._exit(), which discards
    # whatever is still in stdout's buffer.  That is fixed in the script now,
    # but any *other* tool in the chain that does the same would lose its
    # diagnostic here too, and an unbuffered child costs nothing.
    env["PYTHONUNBUFFERED"] = "1"
    try:
        result = subprocess.run(command, cwd = cwd, env = env,
                                capture_output = True, text = True,
                                timeout = 3600)
        text = result.stdout + "\n" + result.stderr
    except subprocess.TimeoutExpired as e:
        text = "TIMEOUT after 3600 seconds\n" + str(e.stdout or "")
    seconds = time.monotonic() - t0
    Path(logDir).mkdir(parents = True, exist_ok = True)
    logPath.write_text(text)

    outcome, sections, _ = parseOutput(text)
    m = RESULTS_RE.search(text)
    return {
        "source_id": sourceId, "path": path, "config": config,
        "started": started, "seconds": seconds, "outcome": outcome,
        "sections": sections, "log": str(logPath),
        "results_dir": m.group(1) if m else None,
        }


def record(db, rec):
    n_ok = sum(1 for s in rec["sections"] if s["verdict"] == "ok")
    # Which CSECTs the target configuration actually contains.  A section we
    # linked that is absent from the index was placed wherever the linker chose
    # and compared against whatever the dump happens to hold there, so its
    # verdict means nothing.  DCDDG1's ZCON is in SSW but its code and data are
    # not -- SSW carries only the ZCONs of the per-phase DCDD/DKFCM variants --
    # and comparing #CDCDDG1 produced 2946 differing halfwords of pure noise.
    inIndex = set(r[0] for r in db.execute(
        "SELECT name FROM csect WHERE config = ?", (rec["config"],)))
    cur = db.execute(
        "INSERT INTO run(config, source_id, started, seconds, outcome,"
        " n_sections, n_ok, log, results_dir) VALUES (?,?,?,?,?,?,?,?,?)",
        (rec["config"], rec["source_id"], rec["started"], rec["seconds"],
         rec["outcome"], len(rec["sections"]), n_ok, rec["log"],
         rec["results_dir"]))
    runId = cur.lastrowid
    for s in rec["sections"]:
        cur = db.execute(
            "INSERT INTO section(run_id, name, address, halfwords, expected,"
            " n_diffs, verdict, shift, shifted_in, after_shift, in_index,"
            " detail) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            (runId, s["name"], s["address"], s["halfwords"], s["expected"],
             s["n_diffs"], s["verdict"], s["shift"], s["shifted_in"],
             s["after_shift"], 1 if s["name"] in inIndex else 0,
             (s["detail"] + (f" [{s['no_data']} no reference data]"
                             if s["no_data"] else "")).strip()))
        sectionId = cur.lastrowid
        db.executemany(
            "INSERT INTO diff(section_id, address, ours, theirs, annotation) "
            "VALUES (?,?,?,?,?)",
            [(sectionId, a, o, t, n) for a, o, t, n in s["diffs"]])
    # A file's status reflects only the sections that are really in this
    # configuration; see the note above.
    real = [s for s in rec["sections"] if s["name"] in inIndex]
    if rec["outcome"] in ("match", "differ"):
        status = "match" if all(s["verdict"] == "ok" for s in real) \
                 else "differ"
        note = None if real else "no section of this file is in the index"
    else:
        status, note = "error", rec["outcome"]
    db.execute("UPDATE membership SET status = ?, note = ? "
               " WHERE config = ? AND source_id = ?",
               (status, note, rec["config"], rec["source_id"]))
    db.commit()
    return runId, n_ok


def main():
    config = "SSW"
    dbPath = dassDb.DEFAULT_DB
    outDir = "work"
    logDir = "logs"
    statuses = []
    only = []
    limit = None
    jobs = 1
    jobsRoot = None
    dryRun = False
    reparse = False
    extra = []
    for p in sys.argv[1:]:
        if p.startswith("--config="):
            config = p.partition("=")[2]
        elif p.startswith("--db="):
            dbPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--out-dir="):
            outDir = p.partition("=")[2]
        elif p.startswith("--log-dir="):
            logDir = p.partition("=")[2]
        elif p.startswith("--status="):
            statuses.append(p.partition("=")[2])
        elif p.startswith("--only="):
            only.append(p.partition("=")[2])
        elif p.startswith("--limit="):
            limit = int(p.partition("=")[2])
        elif p.startswith("--jobs="):
            jobs = int(p.partition("=")[2])
        elif p.startswith("--jobs-root="):
            jobsRoot = p.partition("=")[2]
        elif p == "--dry-run":
            dryRun = True
        elif p == "--reparse":
            reparse = True
        elif p.startswith("--extra="):
            extra.append(p.partition("=")[2])
        else:
            print(__doc__)
            sys.exit(1)
    if only or reparse:
        statuses = ["all"]
    if not statuses:
        statuses = ["todo", "error"]

    db = dassDb.connect(dbPath)
    query = ("SELECT m.source_id, s.path, m.status FROM membership m "
             "  JOIN source s ON s.id = m.source_id "
             " WHERE m.config = ? AND s.ext = 'hal'")
    params = [config]
    if "all" not in statuses:
        query += " AND m.status IN (%s)" % ",".join("?" * len(statuses))
        params += statuses
    if only:
        query += " AND s.stem IN (%s)" % ",".join("?" * len(only))
        params += only
    query += " ORDER BY s.path"
    rows = db.execute(query, params).fetchall()
    if limit:
        rows = rows[:limit]
    if not rows:
        print("Nothing to do.")
        return

    if reparse:
        # Rebuild every row from the saved output, and throw away the rows the
        # old parser produced -- keeping them would leave two runs of the same
        # file disagreeing, with no way to tell which reading is current.
        done = 0
        for r in rows:
            stem = Path(r["path"]).stem
            logPath = Path(logDir) / f"{stem}.log"
            if not logPath.is_file():
                continue
            db.execute(
                "DELETE FROM diff WHERE section_id IN (SELECT s.id FROM"
                " section s JOIN run n ON n.id = s.run_id"
                " WHERE n.config = ? AND n.source_id = ?)",
                (config, r["source_id"]))
            db.execute(
                "DELETE FROM section WHERE run_id IN (SELECT id FROM run"
                " WHERE config = ? AND source_id = ?)",
                (config, r["source_id"]))
            db.execute("DELETE FROM run WHERE config = ? AND source_id = ?",
                       (config, r["source_id"]))
            text = logPath.read_text()
            outcome, sections, _ = parseOutput(text)
            m = RESULTS_RE.search(text)
            record(db, {
                "source_id": r["source_id"], "path": r["path"],
                "config": config,
                "started": datetime.datetime.fromtimestamp(
                    logPath.stat().st_mtime).isoformat(timespec = "seconds"),
                "seconds": None, "outcome": outcome, "sections": sections,
                "log": str(logPath),
                "results_dir": m.group(1) if m else None,
                })
            done += 1
        print(f"Re-parsed {done} log(s).")
        dassDb.doStatus(db, [config])
        db.close()
        return

    if jobs > 1 and not jobsRoot:
        print("--jobs=N requires --jobs-root=D; see the usage text.")
        sys.exit(1)
    cwds = [os.getcwd()] if jobs == 1 \
           else [os.path.join(jobsRoot, str(i + 1)) for i in range(jobs)]
    for c in cwds:
        if not Path(c).is_dir():
            print(f"No such job directory: {c}")
            sys.exit(1)

    print(f"{len(rows)} file(s) for {config}, {jobs} job(s).")
    if dryRun:
        for r in rows:
            print(f"  {r['path']} ({r['status']})")
        return

    # Each worker keeps to one directory for the whole run, so the per-job
    # trees stay independent.
    jobList = []
    for i, r in enumerate(rows):
        jobList.append((r["source_id"], r["path"], config, cwds[i % len(cwds)],
                        outDir, logDir, extra))

    done = 0
    t0 = time.monotonic()
    with ThreadPoolExecutor(max_workers = jobs) as pool:
        for rec in pool.map(runOne, jobList):
            runId, n_ok = record(db, rec)
            done += 1
            n = len(rec["sections"])
            print(f"[{done}/{len(rows)}] {rec['path']:26s} "
                  f"{rec['outcome']:14s} {n_ok}/{n} sections  "
                  f"{rec['seconds']:6.1f}s", flush = True)
    print(f"Elapsed {time.monotonic() - t0:.0f}s.")
    dassDb.doStatus(db, [config])
    db.close()


if __name__ == "__main__":
    main()
