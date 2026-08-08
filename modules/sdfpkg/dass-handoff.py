#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-handoff.py
Purpose:    HANDOFF.md as a database, with the Markdown as generated output.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-handoff.py list [--section=TEXT]
            dass-handoff.py show ID [ID ...]
            dass-handoff.py search TEXT
            dass-handoff.py add --after=ID [--title=T] [--why=TEXT] "body"
            dass-handoff.py set ID "body"          replace an entry's text
            dass-handoff.py why ID "text"          set or replace the reasoning
            dass-handoff.py title ID "text"
            dass-handoff.py move ID --after=ID     reorder
            dass-handoff.py status ID current|superseded|dropped [--by=ID]
            dass-handoff.py render                 to stdout
            dass-handoff.py write                  regenerate HANDOFF.md
            dass-handoff.py check                  does HANDOFF.md match?
            dass-handoff.py import HANDOFF.md      one-time, verifies round-trip

WHY.  HANDOFF.md was one file doing two jobs.  Measured over the twelve commits
before this change, eleven began their first edit at line 589 or later: the
first 562 lines were frozen reference material and the tail was a live
workspace.  The frozen half is what made the live half expensive, because a
rule that protects documentation from casual rewriting has to treat the whole
file as documentation.  Every small status change therefore queued a note and
waited for a sync, and the queue itself became a standing reason to call one.

Entries are records here and HANDOFF.md is GENERATED, so editing state costs an
UPDATE rather than a document rewrite.  Order is explicit (`ord`), so an entry
can be inserted between two others without renumbering, and reasoning that
spans several entries survives as their sequence rather than as a note in one.

WHAT THIS IS NOT.  It does not turn prose into fields.  An entry's `body` is
verbatim text, and `render` concatenates bodies in order, so the document keeps
its voice and paragraph structure.  The `why` field exists for entries written
from now on, where the reasoning belongs to one entry and would otherwise be
lost; imported prose already carries its reasoning inline and is left alone.

THE SAFETY PROPERTY.  `import` refuses unless render(import(FILE)) reproduces
FILE byte for byte.  A chunker that loses a blank line or reorders a paragraph
is then a caught error rather than a silent edit to 60 KB of prose, and every
mutating command rewrites HANDOFF.md so the two cannot drift apart.
'''

import sys
import os
import re
import sqlite3
import datetime
import difflib
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_DB = HERE / "dass-handoff.db"
DEFAULT_MD = HERE / "HANDOFF.md"

SCHEMA = '''
CREATE TABLE IF NOT EXISTS entry (
    id          INTEGER PRIMARY KEY,
    ord         REAL NOT NULL,      -- render order; REAL so inserts fit between
    section     TEXT,               -- owning section title, for grouping
    kind        TEXT NOT NULL,      -- banner | rule | prose
    title       TEXT,               -- lead-in, for listing; not rendered
    body        TEXT NOT NULL,      -- VERBATIM, including its trailing newlines
    why         TEXT,               -- reasoning, rendered after the body
    status      TEXT NOT NULL DEFAULT 'current',
    superseded_by INTEGER REFERENCES entry(id),
    stamp       TEXT,
    updated     TEXT
);
CREATE INDEX IF NOT EXISTS entry_ord ON entry(ord);
'''

RULE_RE = re.compile(r"^(-{20,}|={20,})\s*$")
# A new entry starts at an unindented line, or at a list item indented no more
# than four columns.  Anything more deeply indented -- the tables and the
# figures -- stays attached to the paragraph that introduces it.
LEAD_RE = re.compile(r"^(\S|\s{1,4}(\d+\.|-|\*)\s)")


def connect(path):
    db = sqlite3.connect(path, timeout = 120.0)
    db.row_factory = sqlite3.Row
    db.executescript(SCHEMA)
    db.execute("PRAGMA journal_mode = WAL")
    return db


def today():
    return datetime.date.today().isoformat()


def chunk(text):
    '''Split a document into verbatim entries.

    The only hard requirement is that concatenating what comes back reproduces
    the input exactly; `import` checks it rather than trusting it.  Boundaries
    are placed at a dashed-rule section header, and at a paragraph that begins
    after a blank line at the left margin.
    '''
    lines = text.splitlines(keepends = True)
    starts = set([0])
    section = None
    sections = {}
    i = 0
    while i < len(lines):
        # A section header is a rule, a NON-BLANK title, and a rule.  Requiring
        # the title is not pedantry: HANDOFF.md carried a stray rule followed by
        # a blank line, which otherwise reads as a header with no name and
        # swallows the real one three lines below it.
        if (RULE_RE.match(lines[i]) and i + 2 < len(lines)
                and RULE_RE.match(lines[i + 2])
                and lines[i + 1].strip()
                and not RULE_RE.match(lines[i + 1])):
            starts.add(i)
            sections[i] = lines[i + 1].strip()
            if i + 3 < len(lines):
                starts.add(i + 3)
            i += 3
            continue
        if (i > 0 and lines[i].strip() and not lines[i - 1].strip()
                and LEAD_RE.match(lines[i])):
            starts.add(i)
        i += 1

    out = []
    order = sorted(starts)
    for n, s in enumerate(order):
        e = order[n + 1] if n + 1 < len(order) else len(lines)
        body = "".join(lines[s:e])
        if s in sections:
            section = sections[s]
            kind = "rule"
        elif s == 0:
            kind = "banner"
        else:
            kind = "prose"
        out.append({"body": body, "section": section, "kind": kind,
                    "title": leadIn(body)})
    return out


def leadIn(body):
    '''A short label for listings.  Prefers the document's own idiom, an
    ALL-CAPS lead-in ending in a full stop, and otherwise the first line.'''
    for line in body.splitlines():
        line = line.strip()
        if not line or RULE_RE.match(line):
            continue
        m = re.match(r"^([A-Z][A-Z0-9 ,'\"()/-]{6,}[.,])", line)
        if m:
            return m.group(1).rstrip(".,")[:70]
        return line[:70]
    return ""


def render(db):
    rows = db.execute("SELECT * FROM entry WHERE status != 'dropped' "
                      "ORDER BY ord").fetchall()
    out = []
    for r in rows:
        out.append(r["body"])
        if r["why"]:
            # Bodies written through `add` always end in a blank line, so the
            # reasoning reads as the paragraph that follows.
            out.append(f"WHY.  {r['why'].strip()}\n\n")
    return "".join(out)


def writeOut(db, path = DEFAULT_MD, quiet = False):
    text = render(db)
    Path(path).write_text(text)
    if not quiet:
        # Bytes, not len(): the document uses em dashes, so the two differ and
        # a byte count is what `wc -c` and `cmp` will agree with.
        print(f"wrote {path} ({len(text.encode())} bytes, "
              f"{text.count(chr(10))} lines)")


def importFile(db, path):
    '''One-time load.  Refuses unless the round trip is byte-identical.'''
    if db.execute("SELECT COUNT(*) c FROM entry").fetchone()["c"]:
        raise SystemExit("database already has entries; refusing to import")
    original = Path(path).read_text()
    parts = chunk(original)
    rebuilt = "".join(p["body"] for p in parts)
    if rebuilt != original:
        sys.stderr.write("REFUSING: the round trip is not byte-identical.\n")
        diff = difflib.unified_diff(original.splitlines(True),
                                    rebuilt.splitlines(True),
                                    "original", "rebuilt", n = 1)
        sys.stderr.writelines(list(diff)[:40])
        raise SystemExit(1)
    stamp = today()
    for n, p in enumerate(parts, start = 1):
        db.execute("INSERT INTO entry (ord, section, kind, title, body, stamp,"
                   " updated) VALUES (?,?,?,?,?,?,?)",
                   (n * 1000.0, p["section"], p["kind"], p["title"],
                    p["body"], stamp, stamp))
    db.commit()
    return len(parts)


def nextOrd(db, after):
    '''An ord between `after` and whatever follows it, so inserting never
    renumbers anything else.'''
    row = db.execute("SELECT ord FROM entry WHERE id=?", (after,)).fetchone()
    if row is None:
        raise SystemExit(f"no entry {after}")
    lo = row["ord"]
    nxt = db.execute("SELECT MIN(ord) o FROM entry WHERE ord > ?",
                     (lo,)).fetchone()["o"]
    return lo + 1000.0 if nxt is None else (lo + nxt) / 2.0


def add(db, after, body, title = None, why = None):
    body = body.rstrip("\n") + "\n\n"
    ord_ = nextOrd(db, after)
    sec = db.execute("SELECT section FROM entry WHERE id=?",
                     (after,)).fetchone()["section"]
    cur = db.execute("INSERT INTO entry (ord, section, kind, title, body, why,"
                     " stamp, updated) VALUES (?,?,'prose',?,?,?,?,?)",
                     (ord_, sec, title or leadIn(body), body, why,
                      today(), today()))
    db.commit()
    return cur.lastrowid


def setField(db, ident, field, value):
    if db.execute("SELECT id FROM entry WHERE id=?", (ident,)).fetchone() is None:
        raise SystemExit(f"no entry {ident}")
    if field == "body":
        value = value.rstrip("\n") + "\n\n"
    db.execute(f"UPDATE entry SET {field}=?, updated=? WHERE id=?",
               (value, today(), ident))
    db.commit()


def main():
    dbPath, mdPath = DEFAULT_DB, DEFAULT_MD
    args, after, title, why, section, by, noWrite = [], None, None, None, None, None, False
    for p in sys.argv[1:]:
        if p.startswith("--db="):
            dbPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--md="):
            mdPath = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--after="):
            after = int(p.partition("=")[2])
        elif p.startswith("--title="):
            title = p.partition("=")[2]
        elif p.startswith("--why="):
            why = p.partition("=")[2]
        elif p.startswith("--section="):
            section = p.partition("=")[2]
        elif p.startswith("--by="):
            by = int(p.partition("=")[2])
        elif p == "--no-write":
            noWrite = True
        elif p.startswith("--"):
            print(__doc__)
            sys.exit(1)
        else:
            args.append(p)

    db = connect(dbPath)
    command = args[0] if args else "list"
    mutated = False

    if command == "import":
        if len(args) < 2:
            raise SystemExit("import needs a path")
        n = importFile(db, args[1])
        print(f"{n} entries imported, round trip verified byte-identical")
    elif command == "list":
        q = "SELECT * FROM entry WHERE status != 'dropped'"
        a = []
        if section:
            q += " AND section LIKE ?"
            a.append(f"%{section}%")
        seen = None
        for r in db.execute(q + " ORDER BY ord", a):
            if r["section"] != seen:
                seen = r["section"]
                print(f"\n== {seen or '(preamble)'}")
            flag = "" if r["status"] == "current" else f"  [{r['status']}]"
            star = " *" if r["why"] else "  "
            print(f"  #{r['id']:<4}{star} {r['title'][:66]}{flag}")
    elif command == "show":
        for i in args[1:]:
            r = db.execute("SELECT * FROM entry WHERE id=?", (int(i),)).fetchone()
            if r is None:
                print(f"no entry {i}")
                continue
            print(f"--- #{r['id']}  ord={r['ord']}  section={r['section']!r}"
                  f"  status={r['status']}  updated={r['updated']}")
            sys.stdout.write(r["body"])
            if r["why"]:
                print(f"[why] {r['why']}")
    elif command == "search":
        if len(args) < 2:
            raise SystemExit("search needs text")
        pat = f"%{' '.join(args[1:])}%"
        for r in db.execute("SELECT * FROM entry WHERE (body LIKE ? OR why "
                            "LIKE ?) AND status != 'dropped' ORDER BY ord",
                            (pat, pat)):
            print(f"  #{r['id']:<4} [{r['section'] or '-'}] {r['title'][:60]}")
    elif command == "add":
        if after is None or len(args) < 2:
            raise SystemExit("add needs --after=ID and a body")
        print(f"entry {add(db, after, ' '.join(args[1:]), title, why)} added")
        mutated = True
    elif command in ("set", "why", "title"):
        if len(args) < 3:
            raise SystemExit(f"{command} needs an id and text")
        field = {"set": "body", "why": "why", "title": "title"}[command]
        setField(db, int(args[1]), field, " ".join(args[2:]))
        print(f"entry {args[1]} {field} updated")
        mutated = True
    elif command == "move":
        if after is None or len(args) < 2:
            raise SystemExit("move needs an id and --after=ID")
        db.execute("UPDATE entry SET ord=?, updated=? WHERE id=?",
                   (nextOrd(db, after), today(), int(args[1])))
        db.commit()
        print(f"entry {args[1]} moved")
        mutated = True
    elif command == "status":
        if len(args) < 3 or args[2] not in ("current", "superseded", "dropped"):
            raise SystemExit("status needs an id and current|superseded|dropped")
        db.execute("UPDATE entry SET status=?, superseded_by=?, updated=? "
                   "WHERE id=?", (args[2], by, today(), int(args[1])))
        db.commit()
        print(f"entry {args[1]} is now {args[2]}")
        mutated = True
    elif command == "render":
        sys.stdout.write(render(db))
    elif command == "write":
        writeOut(db, mdPath)
    elif command == "check":
        cur = Path(mdPath).read_text() if Path(mdPath).exists() else ""
        want = render(db)
        if cur == want:
            print(f"{mdPath} matches the database")
        else:
            print(f"{mdPath} DIFFERS from the database; run `write`")
            sys.stdout.writelines(
                list(difflib.unified_diff(cur.splitlines(True),
                                          want.splitlines(True),
                                          "HANDOFF.md", "render", n = 1))[:40])
            sys.exit(1)
    else:
        print(__doc__)
        sys.exit(1)

    # Regenerating on every mutation is what keeps the file from drifting away
    # from the database.  A step that has to be remembered is a step that gets
    # forgotten, and the failure here is silent.
    if mutated and not noWrite:
        writeOut(db, mdPath)
    db.close()


if __name__ == "__main__":
    main()
