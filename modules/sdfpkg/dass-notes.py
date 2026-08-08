#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-notes.py
Purpose:    The documentation staging log, as a database rather than a flat file.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-notes.py add --target=FILE.md [--supersedes=N] "text"
            dass-notes.py pending [--target=FILE.md]
            dass-notes.py done N [N ...]
            dass-notes.py supersede NEWER OLDER
            dass-notes.py render [--pending] [--target=FILE.md]
            dass-notes.py import CLAUDE_LOG.md
            dass-notes.py targets

WHY.  Notes accumulate between documentation syncs, and the flat file has three
costs that grow with it.  Applying a sync means reading the whole log plus every
target file -- 96 KB of log in one case -- and hand-sorting entries by target.
Entries that SUPERSEDE earlier ones are the real hazard: in one day the SPSPSP
analysis was rewritten twice and an SDF finding reversed outright, so applying
the log in order would have written three contradictory accounts into the same
document.  Nothing in a flat file records that entry 9 replaces entry 4.  And
"which of these did I already apply?" has no answer at all beyond re-reading.

A table answers all three.  Capture is an INSERT, a sync is a SELECT of what is
pending for one target, marking one applied is an UPDATE, and superseded entries
are excluded from `pending` automatically so only the surviving account is read.

WHAT THIS IS NOT.  It does not replace prose, and the documents remain the
product.  It replaces the staging file, which is a queue and was never prose.
`render` writes the queue back out as Markdown whenever a human wants to read
it that way, so nothing is locked inside a binary.
'''

import sys
import os
import re
import sqlite3
import datetime
from pathlib import Path

DEFAULT_DB = Path(__file__).resolve().parent / "dass-notes.db"

SCHEMA = '''
CREATE TABLE IF NOT EXISTS note (
    id          INTEGER PRIMARY KEY,
    stamp       TEXT NOT NULL,      -- ISO date the note was captured
    target      TEXT NOT NULL,      -- the .md file it is to be applied to
    body        TEXT NOT NULL,
    applied     TEXT,               -- ISO date, or NULL while pending
    supersedes  INTEGER REFERENCES note(id)
);
CREATE INDEX IF NOT EXISTS note_target ON note(target, applied);
'''


def connect(path):
    db = sqlite3.connect(path, timeout = 120.0)
    db.row_factory = sqlite3.Row
    db.executescript(SCHEMA)
    db.execute("PRAGMA journal_mode = WAL")
    return db


def today():
    return datetime.date.today().isoformat()


def add(db, target, body, supersedes = None):
    if supersedes is not None:
        row = db.execute("SELECT id FROM note WHERE id=?", (supersedes,)).fetchone()
        if row is None:
            raise SystemExit(f"no note {supersedes} to supersede")
    cur = db.execute("INSERT INTO note (stamp, target, body, supersedes) "
                     "VALUES (?,?,?,?)", (today(), target, body.strip(),
                                          supersedes))
    db.commit()
    return cur.lastrowid


def supersede(db, newer, older):
    '''Record that note `newer` replaces note `older`.

    Supersession is usually noticed after the fact -- you write an entry, and
    only later find it wrong -- so declaring it at insert time is not enough.
    '''
    for i in (newer, older):
        if db.execute("SELECT id FROM note WHERE id=?", (i,)).fetchone() is None:
            raise SystemExit(f"no note {i}")
    db.execute("UPDATE note SET supersedes=? WHERE id=?", (older, newer))
    db.commit()


def pending(db, target = None):
    '''Unapplied notes that nothing later supersedes.

    Excluding superseded entries is the point of the table: reading them would
    reproduce exactly the contradiction the flat file could not prevent.'''
    q = ("SELECT n.* FROM note n WHERE n.applied IS NULL "
         "AND NOT EXISTS (SELECT 1 FROM note s WHERE s.supersedes = n.id) ")
    args = []
    if target:
        q += "AND n.target = ? "
        args.append(target)
    return db.execute(q + "ORDER BY n.target, n.id", args).fetchall()


def markDone(db, ids):
    db.executemany("UPDATE note SET applied=? WHERE id=?",
                   [(today(), i) for i in ids])
    db.commit()


def render(db, target = None, onlyPending = False):
    q = "SELECT * FROM note"
    where, args = [], []
    if onlyPending:
        where.append("applied IS NULL")
    if target:
        where.append("target = ?")
        args.append(target)
    if where:
        q += " WHERE " + " AND ".join(where)
    rows = db.execute(q + " ORDER BY target, id", args).fetchall()
    out, seen = [], None
    for r in rows:
        if r["target"] != seen:
            seen = r["target"]
            out.append(f"\n## {seen}\n")
        flags = []
        if r["applied"]:
            flags.append(f"applied {r['applied']}")
        if r["supersedes"]:
            flags.append(f"supersedes #{r['supersedes']}")
        sup = db.execute("SELECT id FROM note WHERE supersedes=?",
                         (r["id"],)).fetchone()
        if sup:
            flags.append(f"SUPERSEDED by #{sup['id']}")
        tag = f"  ({', '.join(flags)})" if flags else ""
        out.append(f"### [{r['stamp']}] #{r['id']}{tag}\n{r['body']}\n")
    return "\n".join(out)


HEADER_RE = re.compile(r"^###\s*\[(\d{4}-\d\d-\d\d)\]\s*Target:\s*\[([^\]]+)\]")


def importLog(db, path):
    '''Read an existing CLAUDE_LOG.md.  Entries are left PENDING: whether one
    was already applied is not recorded in the file, and guessing would be
    worse than asking.'''
    stamp = target = None
    body = []
    n = 0

    def flush():
        nonlocal n, body
        if target and any(line.strip() for line in body):
            db.execute("INSERT INTO note (stamp, target, body) VALUES (?,?,?)",
                       (stamp, target, "\n".join(body).strip()))
            n += 1
        body = []

    for line in Path(path).read_text().splitlines():
        m = HEADER_RE.match(line)
        if m:
            flush()
            stamp, target = m.group(1), m.group(2)
        else:
            body.append(line)
    flush()
    db.commit()
    return n


def main():
    dbPath = DEFAULT_DB
    args, target, supersedes, onlyPending = [], None, None, False
    for p in sys.argv[1:]:
        if p.startswith("--db="):
            dbPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--target="):
            target = p.partition("=")[2]
        elif p.startswith("--supersedes="):
            supersedes = int(p.partition("=")[2])
        elif p == "--pending":
            onlyPending = True
        elif p.startswith("--"):
            print(__doc__)
            sys.exit(1)
        else:
            args.append(p)

    db = connect(dbPath)
    command = args[0] if args else "pending"

    if command == "add":
        if not target or len(args) < 2:
            raise SystemExit("add needs --target=FILE.md and a body")
        print(f"note {add(db, target, ' '.join(args[1:]), supersedes)} added")
    elif command == "pending":
        rows = pending(db, target)
        if not rows:
            print("nothing pending")
        seen = None
        for r in rows:
            if r["target"] != seen:
                seen = r["target"]
                print(f"\n{seen}:")
            first = r["body"].strip().splitlines()[0][:100]
            print(f"  #{r['id']:<4} [{r['stamp']}] {first}")
        if rows:
            byTarget = {}
            for r in rows:
                byTarget[r["target"]] = byTarget.get(r["target"], 0) + 1
            print("\n" + ", ".join(f"{k}: {v}" for k, v in byTarget.items()))
    elif command == "supersede":
        if len(args) < 3:
            raise SystemExit("supersede needs: NEWER OLDER")
        supersede(db, int(args[1]), int(args[2]))
        print(f"note {args[1]} now supersedes note {args[2]}")
    elif command == "done":
        ids = [int(a) for a in args[1:]]
        if not ids:
            raise SystemExit("done needs at least one note id")
        markDone(db, ids)
        print(f"marked applied: {', '.join(str(i) for i in ids)}")
    elif command == "render":
        print(render(db, target, onlyPending))
    elif command == "import":
        if len(args) < 2:
            raise SystemExit("import needs a path")
        print(f"{importLog(db, args[1])} note(s) imported, all pending")
    elif command == "targets":
        for r in db.execute(
                "SELECT target, COUNT(*) n, SUM(applied IS NULL) p "
                "FROM note GROUP BY target ORDER BY target"):
            print(f"  {r['target']:34s} {r['n']:4d} total  {r['p'] or 0:4d} pending")
    else:
        print(__doc__)
        sys.exit(1)
    db.close()


if __name__ == "__main__":
    main()
