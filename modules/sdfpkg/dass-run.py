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
import fcntl
import queue
import signal
import contextlib
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
    # N/A carries a slash, so it must be spelled out rather than folded into the
    # \w-ish alternation above it.
    r"^\s*(OK|FAIL|MISSING|N/A):\s+(\S+)\s+@\s+([0-9A-Fa-f]+)\s+"
    r"\((\d+)\s+halfwords(?:\s+vs\s+(\d+)\s+expected)?\)"
    # Any bracketed note, parsed afterwards rather than matched literally.
    # fcmcmp has twice gained a new one -- "[N no reference data]", then
    # "[N patched after build]" -- and each time a regex that spelled out the
    # previous wording silently stopped matching those section lines, so they
    # vanished from the database and the totals improved for the wrong reason.
    r"(?:\s*\[([^\]]*)\])?"
    r"\s*(?:[-‐-―]\s*(.*))?$")
# Any "N phrase" note fcmcmp puts in the bracket.  Spelling the phrases out
# meant a new one -- "N ignored" -- was silently not recorded, so the
# database showed nothing suppressed while the report showed plenty.
NOTE_RE = re.compile(r"(\d+)\s+([a-z][a-z ]*?)(?=,|$)")
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
    # "Linking failed" alone is no longer the end of the story: compileLinkCompare
    # re-links with -f and compares the forced image, which is legitimate now
    # that lnk101 leaves a relocation to an absent section unpatched rather than
    # inventing an address.  Such a run is scored on its sections like any
    # other; its log carries the FORCED LINK banner, so it stays identifiable.
    if "Linking failed" in text and "FORCED LINK:" not in text:
        return "link_failed", [], None

    sections = []
    for line in text.split("\n"):
        m = SECTION_RE.match(line)
        if m:
            verdict, name, addr, halfwords, expected, note, tail = m.groups()
            counts = {k: int(v) for v, k in NOTE_RE.findall(note or "")}
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
                "no_data": counts.get("no reference data", 0),
                # Locations changed after the original build -- I-LOAD, patch
                # or checksum -- which no compilation or link can reproduce.
                "patched": counts.get("patched after build", 0),
                # Locations declared -1 in the exceptions file: a difference is
                # expected on grounds recorded elsewhere and nothing is claimed
                # about the contents.  Here, the four units OI-34.07 revised.
                "ignored": counts.get("ignored", 0),
                # NULL for N/A, and deliberately so.  0 would read as "compared
                # and identical" and a count would read as a failure; the truth
                # is that nothing was claimed.  It falls out of the parse anyway,
                # there being no "N halfwords differ" phrase to find, but leaving
                # that to chance would be an accident waiting to be tidied away.
                "n_diffs": 0 if verdict == "OK"
                           else None if verdict == "N/A" else n,
                "verdict": {"OK": "ok", "FAIL": "differ",
                            "MISSING": "missing",
                            # Differs, but is not in this configuration and its
                            # span belongs to another section, so fcmcmp makes no
                            # claim.  Recorded rather than dropped: a section that
                            # vanishes from the database is how this file has been
                            # misled twice before.
                            "N/A": "not_in_config"}[verdict],
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
    # "not_in_config" is not a difference.  fcmcmp reports it for a section that
    # is not in this configuration and whose span demonstrably belongs to
    # another, so it prints PASS on the sections that remain; treating the
    # verdict as differing would contradict fcmcmp and drop a matching unit out
    # of the score.  It is not a match either -- no claim was made about it -- so
    # it is simply not consulted here, exactly as "no_data" is not.
    outcome = "match" if all(s["verdict"] in ("ok", "not_in_config")
                             for s in sections) else "differ"
    return outcome, sections, None


# The pool of source trees a parallel run may compile in.  A worker takes one
# for the duration of a compile and puts it back afterwards, so at most one
# compile is ever running in a given tree.
#
# The obvious thing -- handing job i the tree i % N -- is NOT enough, and this
# is the bug that produced 60 spurious failures across a configuration before
# it was noticed.  With four workers and four trees, a slow job in tree 1 is
# still running when job 5 starts, and job 5 was also assigned tree 1: two
# compiles in one directory, which corrupt each other's halmat.bin, litfile.bin
# and COMMON*.out and end in "Unable to open COMMON input file".  Exactly the
# failure HANDOFF.md section 3 describes, and exactly what this option exists
# to prevent.  Exclusion has to be by possession, not by arithmetic.
#
# AND POSSESSION HAS TO BE ACROSS PROCESSES.  treePool is a queue inside ONE
# interpreter, so it excludes this run's own threads and nothing else.  Every
# sweep computes the same tree list -- jobs-root/1 .. jobs-root/N -- so two
# concurrent sweeps hand the SAME directory to a compile each, and the guard
# below ("--jobs=N but only M tree(s)") only ever checks its own arithmetic.
# Six sweeps were once started before earlier ones had finished: 24 compiles
# over four trees, six per directory, each overwriting the others' halmat.bin,
# litfile.bin and COMMON*.out under fixed names while they were being read.
# Six compiles hung for the full hour that day and none has since.
#
# So the tree is also locked on the filesystem, which is the only lock every
# process can see.  It is held for the whole compile and released in the same
# `finally` that returns the tree to the queue.
treePool = None


@contextlib.contextmanager
def heldTree(cwd):
    '''Hold `cwd` against every other process for the duration of a compile.

    Blocking, deliberately.  Returning "busy" would mean either failing a file
    that is perfectly good or silently compiling in a shared directory, and the
    second is the bug this exists to prevent.  Waiting makes two concurrent
    sweeps take turns: slower than either alone, which is honest, and the
    alternative is two sweeps that both produce nonsense quickly.

    The lock file lives in the tree and is never removed -- an empty lock file
    is cheap, and unlinking one is a race in itself.  run-configs.sh's
    inter-sweep cleanup only deletes archive.results and current*.results, so
    it does not disturb this.
    '''
    lockPath = Path(cwd) / ".dass-tree.lock"
    fd = os.open(str(lockPath), os.O_CREAT | os.O_WRONLY, 0o644)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX)
        yield cwd
    finally:
        # Released by the close in any case; explicit for the reader's sake.
        try:
            fcntl.flock(fd, fcntl.LOCK_UN)
        except OSError:
            pass
        os.close(fd)


def runOne(job):
    '''Compile/link/compare one source file.  Returns a record to be inserted.

    Everything here is subprocess and file I/O; nothing touches the database,
    so this is safe to run in a thread pool while the main thread does the
    inserts serially.  (sqlite3 connections are not shareable across threads,
    and a single writer avoids lock contention besides.)
    '''
    sourceId, path, config, _unused, outDir, logDir, extra = job
    cwd = treePool.get() if treePool is not None else _unused
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
    # start_new_session puts the child in its own process group, so a timeout
    # can kill the whole tree rather than just the process we launched.
    # subprocess.run's timeout kills only the direct child: compileLinkCompare
    # died, and HALSFC and its PASS2 grandchild carried on, orphaned, spinning
    # at 100% of a core until the machine was rebooted or someone noticed.  Six
    # such orphans accumulated in one day, two of them running over three hours,
    # and the sweep they were stealing cores from took three times as long as it
    # should.
    #
    # Worse than the waste: HALSFC writes halmat.bin, litfile.bin and COMMON*.out
    # into its working directory under FIXED names, and that directory goes back
    # into the tree pool the moment the timeout is handled.  An orphan still
    # running there is writing those files underneath whichever compile is handed
    # the tree next.
    try:
        with heldTree(cwd):
            proc = subprocess.Popen(command, cwd = cwd, env = env,
                                    stdout = subprocess.PIPE,
                                    stderr = subprocess.PIPE,
                                    text = True, start_new_session = True)
            try:
                out, err = proc.communicate(timeout = 3600)
                text = out + "\n" + err
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                except (ProcessLookupError, PermissionError):
                    proc.kill()
                out, err = proc.communicate()
                text = ("TIMEOUT after 3600 seconds; process group killed\n"
                        + (out or "") + "\n" + (err or ""))
    finally:
        if treePool is not None:
            treePool.put(cwd)
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
    # The run's totals count only the sections a claim was made about, which is
    # what fcmcmp's own "PASS: all N sections match" counts.  A not_in_config
    # section left in the denominator would reproduce, inside the database, the
    # very arithmetic that made G3's DKFCM2 report read "FAIL: 2/3" while the
    # score said 2905/2905.  Every section still gets a row below; only the
    # summary excludes them.
    claimed = [s for s in rec["sections"] if s["verdict"] != "not_in_config"]
    n_ok = sum(1 for s in claimed if s["verdict"] == "ok")
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
         rec["outcome"], len(claimed), n_ok, rec["log"],
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
             (s["detail"] + (f" [{s['ignored']} ignored]"
                             if s["ignored"] else "")
                            + (f" [{s['patched']} patched after build]"
                               if s["patched"] else "")
                            + (f" [{s['no_data']} no reference data]"
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


NSTS = Path("~/donschmidt/nsts-sdl-dps").expanduser()


def checkToolchainBranch():
    """Warn if lnk101/fcmcmp lack any of the fixes this comparison depends on.

    Building a toolchain that is missing one of them silently reports an
    already-fixed mechanism as live again.  That happened three times; the most
    expensive was a sweep whose differing sections jumped from 4 to 33, which
    looked like a regression in the change under test and was in fact a build
    predating two of the fixes.

    This used to test that the checkout was on our local `integration` branch,
    which merged the four fixes while they were still separate feature branches
    under review.  Upstream has since merged all four, so `master` is now the
    correct branch and the branch test warned on every sweep -- 21 spurious
    warnings in one run, which is how a check stops being read at all.

    Test the capabilities instead.  A feature is what the sweep actually
    depends on; which branch supplies it is upstream's business, not ours.
    """
    required = [
        (Path("src/tools/fcmcmp.py"), "--no-data",
         "differences against fill words"),
        (Path("src/tools/fcmcmp.py"), "--exceptions",
         "post-build patches and no-claim locations"),
        (Path("src/lnk101/cli.py"), "--external-syms",
         "placing sections at their DASS addresses"),
        (Path("src/lnk101/linker.py"), "patchStackPDEs",
         "stack addresses in process directory entries"),
        (Path("src/ap101Utils/addrcon.py"), "flags: int | None",
         "the sign bit on negative-displacement ZCONs"),
    ]
    missing = []
    for relative, token, purpose in required:
        path = NSTS / relative
        try:
            if token not in path.read_text(errors = "replace"):
                missing.append((relative, token, purpose))
        except OSError:
            missing.append((relative, token, purpose))
    if missing:
        print(f"WARNING: {NSTS.name} is missing "
              f"{len(missing)} fix(es) this sweep depends on; its results "
              f"will not be comparable.  Pull and rebuild.\n",
              file = sys.stderr)
        for relative, token, purpose in missing:
            print(f"    {relative}: no '{token}' -- {purpose}",
                  file = sys.stderr)
        print(file = sys.stderr)


def main():
    checkToolchainBranch()
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
             # .dfg decks are compiled too, since compileLinkCompare now
             # preprocesses them into HAL/S first.  .asm is still excluded:
             # its six-character key is not unique, so the CSECT join cannot
             # identify the source (see dass-db.py's header).
             " WHERE m.config = ? AND s.ext IN ('hal', 'dfg')")
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

    if jobs > len(cwds):
        print(f"--jobs={jobs} but only {len(cwds)} tree(s) under {jobsRoot}; "
              f"two compiles would share a directory and corrupt each other.")
        sys.exit(1)
    global treePool
    if len(cwds) > 1:
        treePool = queue.Queue()
        for c in cwds:
            treePool.put(c)

    jobList = []
    for r in rows:
        jobList.append((r["source_id"], r["path"], config, cwds[0],
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
