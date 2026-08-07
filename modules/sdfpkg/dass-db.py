#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-db.py
Purpose:    Build and query the DASS-comparison database.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

The permanent record for the phase described in compileLinkCompare.md: which
HAL/S source files make up each GPC memory configuration, what happened the
last time each was compiled/linked/compared against the MAFGEN memory dump,
and which root cause each surviving discrepancy has been traced to.

The database is modules/sdfpkg/dass-compare.db unless --db says otherwise.

Subcommands:
    init [--config=XXX ...]   Create the schema and populate the CSECT index
                              and source-file mapping for the named
                              configurations (default: all eight).
    reset [--config=XXX ...]  Put a configuration back to "not yet swept":
                              drop its runs, sections and diffs and mark its
                              membership todo.  What run-configs.sh does
                              between sweeps; also what a killed sweep needs,
                              since it leaves rows that make the next sweep
                              skip those files.
    files --config=XXX        List the source files that make up XXX.
    status [--config=XXX]     Summarise what has been compared and how it went.

HOW A CSECT IS MATCHED TO ITS SOURCE FILE.  unlinkMAFGEN2.py records, for every
CSECT derived from HAL/S, a "hal" field holding the block name as it appears in
the source -- "ARD_CS_BUS_CHG" for #CARDCSB.  That is what distinguishes a
HAL/S CSECT from an assembly one (type NONHAL, MSC, BCE, PATCH) and from a
HAL/S runtime library routine (type HAL_LIBRARY_*), neither of which carries
it, and it is more reliable than reasoning from the name.

The block name does NOT give the file name: ARD_CS_BUS_CHG descores to
ARDCSBUSCHG and the file is ARDCSBUS.hal, but AID_DEU_LOGGER descores to
AIDDEULOGGER and the file is not AIDDEULO.hal.  The join that does work is the
one compileLinkCompare.md describes: strip the two-character CSECT prefix and
match the remaining six characters against the descored source stem's first
six.  Over SSW that maps all 401 HAL/S CSECTs onto 145 source files with no
ambiguity and nothing left over; the six-character key is unique across every
.hal and .dfg file in APPLSRC and SSSRC, so the join cannot silently pick the
wrong file.  (It is NOT unique across .asm files -- FCMBMT02 through FCMBMTS4
all share FCMBMT -- which is why only HAL/S CSECTs are matched this way.)
'''

import sys
import os
import json
import sqlite3
from pathlib import Path

CONFIGS = ["SSW", "P9", "G8", "S2", "G9", "G2", "G3", "G16"]

# unlinkMAFGEN2.py's own type names, grouped the way compileLinkCompare.md
# groups them.  Only the first group is ours to fix.
LIBRARY_TYPES = {"HAL_LIBRARY_CODE", "HAL_LIBRARY_ZCON", "HAL_LIBRARY_DATA"}

DEFAULT_DB = Path(__file__).resolve().parent / "dass-compare.db"
DEFAULT_SRC = Path("~/workspace/PFS/OI340600").expanduser()
DEFAULT_MAFGEN = Path("~/workspace/PFS/mafgen").expanduser()

SCHEMA = '''
CREATE TABLE IF NOT EXISTS config (
    name        TEXT PRIMARY KEY,   -- SSW, P9, ...
    dass        TEXT,               -- the MAFGEN listing it all comes from
    fcm         TEXT,               -- memory image scraped from it
    csect_json  TEXT                -- CSECT index scraped from it
);

CREATE TABLE IF NOT EXISTS source (
    id          INTEGER PRIMARY KEY,
    path        TEXT UNIQUE,        -- APPLSRC/GSRRSL.hal, relative to the tree
    stem        TEXT,               -- GSRRSL
    ext         TEXT,               -- hal, dfg, asm
    key6        TEXT                -- descored stem, first six characters
);

CREATE TABLE IF NOT EXISTS csect (
    id          INTEGER PRIMARY KEY,
    config      TEXT REFERENCES config(name),
    name        TEXT,               -- #CARDCSB
    type        TEXT,               -- PROCEDURE, DATA, ZCON, NONHAL, ...
    start       INTEGER,            -- halfword address, inclusive
    end         INTEGER,            -- halfword address, inclusive
    hal         TEXT,               -- ARD_CS_BUS_CHG, or NULL if not HAL/S
    origin      TEXT,               -- 'hal', 'library', 'other'
    source_id   INTEGER REFERENCES source(id),
    UNIQUE(config, name)
);

-- One row per (source file, configuration) pair that we intend to compare.
CREATE TABLE IF NOT EXISTS membership (
    config      TEXT REFERENCES config(name),
    source_id   INTEGER REFERENCES source(id),
    n_csects    INTEGER,
    status      TEXT DEFAULT 'todo',    -- todo, match, differ, error, skipped
    note        TEXT,
    PRIMARY KEY (config, source_id)
);

-- One row per compileLinkCompare invocation.
CREATE TABLE IF NOT EXISTS run (
    id          INTEGER PRIMARY KEY,
    config      TEXT,
    source_id   INTEGER REFERENCES source(id),
    started     TEXT,
    seconds     REAL,
    outcome     TEXT,               -- match, differ, compile_failed,
                                    -- link_failed, compare_failed
    n_sections  INTEGER,
    n_ok        INTEGER,
    log         TEXT,               -- path to the captured console output
    results_dir TEXT                -- the HALSFC archive.results folder
);

-- One row per CSECT per run.
--
-- shift/after_shift record fcmcmp's own displacement analysis, which is the
-- single most useful thing it reports: "shift +2: 2 halfword(s) inserted in
-- first image near 44448 ... after shift, all halfwords match" says the
-- section's whole content is right and only its length is wrong, which is one
-- root cause rather than the dozens of differing halfwords it produces.  Not
-- recording it was how the first survey made the SSW result look far worse
-- than it is.
CREATE TABLE IF NOT EXISTS section (
    id          INTEGER PRIMARY KEY,
    run_id      INTEGER REFERENCES run(id),
    name        TEXT,
    address     INTEGER,
    halfwords   INTEGER,            -- as we linked it
    expected    INTEGER,            -- as the memory dump has it, when stated
    n_diffs     INTEGER,            -- NULL when fcmcmp reported no count
    verdict     TEXT,               -- ok, differ, missing
    shift       INTEGER,            -- halfwords inserted (+) or deleted (-)
    shifted_in  TEXT,               -- the inserted halfwords themselves
    after_shift INTEGER,            -- diffs remaining once the shift is
                                    -- allowed for; 0 means content identical
    in_index    INTEGER,            -- 1 if this CSECT is in the config's own
                                    -- index; 0 means the comparison is
                                    -- meaningless (see below)
    detail      TEXT                -- fcmcmp's own words, verbatim
);

-- The differing halfwords fcmcmp chose to print.  Not exhaustive: fcmcmp
-- elides past --max-hw-diffs, and that limit is deliberately low because a
-- single displaced instruction makes every later halfword differ.  Count root
-- causes, not halfwords.
CREATE TABLE IF NOT EXISTS diff (
    section_id  INTEGER REFERENCES section(id),
    address     INTEGER,
    ours        TEXT,
    theirs      TEXT,
    annotation  TEXT                -- fcmcmp's own "; RLD #PCZ2COM (+2E0)",
                                    -- which says the halfword is a relocated
                                    -- address rather than an instruction, and
                                    -- names what it points at
);

-- A root cause, in the sense compileLinkCompare.md means it: the thing that
-- has to be fixed, as against the many halfwords it makes differ.
CREATE TABLE IF NOT EXISTS mechanism (
    id          INTEGER PRIMARY KEY,
    name        TEXT UNIQUE,
    kind        TEXT,               -- halsfc, linker, options, scraping, other
    status      TEXT,               -- open, understood, fixed, wontfix
    summary     TEXT,
    detail      TEXT
);

CREATE TABLE IF NOT EXISTS attribution (
    mechanism_id INTEGER REFERENCES mechanism(id),
    config       TEXT,
    csect_name   TEXT,
    source_id    INTEGER REFERENCES source(id),
    note         TEXT
);

CREATE INDEX IF NOT EXISTS ix_csect_source ON csect(source_id);
CREATE INDEX IF NOT EXISTS ix_section_run ON section(run_id);
CREATE INDEX IF NOT EXISTS ix_run_source ON run(config, source_id);
'''


def connect(dbPath):
    '''Open the database for concurrent use.

    A sweep writes for three and a half hours while other things read: another
    dass-*.py, an interactive query, the next configuration's reset.  Under the
    default rollback journal any writer blocks every reader, and the default
    five-second timeout is easily exceeded by a DELETE over a configuration's
    rows -- which is not a wait but an OperationalError.  One such failure hit
    dass-run.py while it was reading its work list, and P9's entire sweep
    produced nothing: "database is locked", no results, and a RESULT line that
    simply never appeared.

    WAL lets readers proceed while a writer works, and the long busy timeout
    turns the remaining writer-writer collisions into a wait.  journal_mode is
    a property of the file and persists once set.
    '''
    db = sqlite3.connect(dbPath, timeout = 120.0)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    db.execute("PRAGMA journal_mode = WAL")
    db.execute("PRAGMA busy_timeout = 120000")
    return db


def scanSources(srcTree):
    '''Every source file in the tree, keyed for the six-character join.'''
    out = []
    for d in ("APPLSRC", "SSSRC"):
        dirPath = srcTree / d
        if not dirPath.is_dir():
            continue
        for f in sorted(os.listdir(dirPath)):
            if (dirPath / f).is_dir():
                continue
            stem, dot, ext = f.rpartition(".")
            if not dot:
                stem, ext = f, ""
            out.append((f"{d}/{f}", stem, ext, stem.replace("_", "")[:6]))
    return out


def doInit(db, configs, srcTree, mafgen):
    db.executescript(SCHEMA)

    sources = scanSources(srcTree)
    db.executemany("INSERT OR IGNORE INTO source(path, stem, ext, key6) "
                   "VALUES (?,?,?,?)", sources)

    # Only .hal and .dfg participate in the six-character join; .asm stems are
    # not unique in six characters and no HAL/S CSECT comes from one anyway.
    key6ToSource = {}
    ambiguous = set()
    for row in db.execute("SELECT id, key6, ext FROM source "
                          "WHERE ext IN ('hal','dfg')"):
        if row["key6"] in key6ToSource:
            ambiguous.add(row["key6"])
        key6ToSource[row["key6"]] = row["id"]
    if ambiguous:
        print(f"WARNING: ambiguous six-character keys: {sorted(ambiguous)}",
              file = sys.stderr)

    for config in configs:
        dass = "DASS_SSW_(PostIPL).ASC" if config == "SSW" \
               else f"DASS_{config}.ASC"
        csectJson = mafgen / f"csects-{config}.json"
        if not csectJson.is_file():
            print(f"WARNING: no {csectJson}, skipping {config}",
                  file = sys.stderr)
            continue
        db.execute("INSERT OR REPLACE INTO config(name, dass, fcm, csect_json) "
                   "VALUES (?,?,?,?)",
                   (config, str(mafgen / dass), str(mafgen / f"{config}.fcm"),
                    str(csectJson)))
        index = json.load(open(csectJson))
        db.execute("DELETE FROM csect WHERE config = ?", (config,))
        unmatched = []
        for name, v in sorted(index.items()):
            hal = v.get("hal")
            if hal:
                origin = "hal"
                sourceId = key6ToSource.get(name[2:])
                if sourceId is None:
                    unmatched.append(name)
            else:
                origin = "library" if v["type"] in LIBRARY_TYPES else "other"
                sourceId = None
            db.execute("INSERT INTO csect(config, name, type, start, end, hal,"
                       " origin, source_id) VALUES (?,?,?,?,?,?,?,?)",
                       (config, name, v["type"], v["start"], v["end"], hal,
                        origin, sourceId))
        if unmatched:
            print(f"WARNING: {config}: {len(unmatched)} HAL/S CSECTs matched no "
                  f"source file: {unmatched[:10]}", file = sys.stderr)

        db.execute("DELETE FROM membership WHERE config = ?", (config,))
        db.execute(
            "INSERT INTO membership(config, source_id, n_csects, status) "
            "  SELECT config, source_id, COUNT(*), "
            "         CASE WHEN (SELECT ext FROM source WHERE id = source_id)"
            "              = 'dfg' THEN 'skipped' ELSE 'todo' END "
            "    FROM csect WHERE config = ? AND source_id IS NOT NULL "
            "   GROUP BY config, source_id", (config,))
        db.execute(
            "UPDATE membership SET note = 'DFG preprocessing not implemented' "
            " WHERE config = ? AND status = 'skipped'", (config,))

        n = db.execute("SELECT COUNT(*) FROM membership WHERE config = ?",
                       (config,)).fetchone()[0]
        byOrigin = dict(db.execute(
            "SELECT origin, COUNT(*) FROM csect WHERE config = ? "
            "GROUP BY origin", (config,)).fetchall())
        print(f"{config:4s} {len(index):5d} CSECTs  "
              f"hal={byOrigin.get('hal',0):4d} "
              f"library={byOrigin.get('library',0):4d} "
              f"other={byOrigin.get('other',0):4d}  -> {n} source files")
    db.commit()


def doFiles(db, configs):
    for config in configs:
        for row in db.execute(
                "SELECT s.path, m.n_csects, m.status, m.note FROM membership m "
                "  JOIN source s ON s.id = m.source_id "
                " WHERE m.config = ? ORDER BY s.path", (config,)):
            print(f"{config:4s} {row['path']:24s} {row['n_csects']:3d} "
                  f"{row['status']:9s} {row['note'] or ''}")


def doStatus(db, configs):
    for config in configs:
        rows = dict(db.execute(
            "SELECT status, COUNT(*) FROM membership WHERE config = ? "
            "GROUP BY status", (config,)).fetchall())
        total = sum(rows.values())
        if not total:
            continue
        print(f"{config:4s} {total:4d} files: " +
              "  ".join(f"{k}={v}" for k, v in sorted(rows.items())))


def doReset(db, configs):
    '''Put a configuration back to "not yet swept": drop its runs, sections and
    diffs, and mark its membership todo again.

    This is what run-configs.sh does between sweeps, and it had been written out
    by hand every time it was needed outside the script -- three times, wrongly
    twice.  Killing a sweep mid-configuration leaves rows behind for the one it
    was working on, and those rows mark files done, so the next sweep 1 silently
    skips them.  "skipped" membership is left alone: that is a standing decision
    about a file, not sweep state.
    '''
    for config in configs:
        n = db.execute("SELECT COUNT(*) FROM run WHERE config=?",
                       (config,)).fetchone()[0]
        db.execute("DELETE FROM diff WHERE section_id IN "
                   "(SELECT s.id FROM section s JOIN run r ON r.id=s.run_id "
                   " WHERE r.config=?)", (config,))
        db.execute("DELETE FROM section WHERE run_id IN "
                   "(SELECT id FROM run WHERE config=?)", (config,))
        db.execute("DELETE FROM run WHERE config=?", (config,))
        db.execute("UPDATE membership SET status='todo', note=NULL "
                   "WHERE config=? AND status!='skipped'", (config,))
        todo = db.execute("SELECT COUNT(*) FROM membership "
                          "WHERE config=? AND status='todo'",
                          (config,)).fetchone()[0]
        print(f"{config}: dropped {n} run(s), {todo} file(s) now todo")
    db.commit()


def main():
    dbPath = DEFAULT_DB
    srcTree = DEFAULT_SRC
    mafgen = DEFAULT_MAFGEN
    configs = []
    args = []
    for p in sys.argv[1:]:
        if p.startswith("--db="):
            dbPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--config="):
            configs.append(p.partition("=")[2])
        elif p.startswith("--src="):
            srcTree = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--mafgen="):
            mafgen = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--"):
            print(__doc__)
            sys.exit(1)
        else:
            args.append(p)
    if not configs:
        configs = CONFIGS
    command = args[0] if args else "status"
    db = connect(dbPath)
    if command == "init":
        doInit(db, configs, srcTree, mafgen)
    elif command == "reset":
        doReset(db, configs)
    elif command == "files":
        doFiles(db, configs)
    elif command == "status":
        doStatus(db, configs)
    else:
        print(__doc__)
        sys.exit(1)
    db.close()


if __name__ == "__main__":
    main()
