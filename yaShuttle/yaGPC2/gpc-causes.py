#!/usr/bin/env python3
"""
License:    Public Domain, no restrictions believed to exist.
Filename:   gpc-causes.py
Purpose:    A searchable ledger of CAUSES INVESTIGATED and FIXES ATTEMPTED,
            with CAUSES.md as generated output.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      gpc-causes.py addr HEX               <-- FIRST, for an address
            gpc-causes.py search TEXT            <-- FIRST, for anything else
            gpc-causes.py list [--status=S] [--area=A]
            gpc-causes.py show ID [ID ...]
            gpc-causes.py fields                 what is searchable
            gpc-causes.py add --claim="..." [--FIELD=... ...]
            gpc-causes.py set ID [--FIELD=... ...]
            gpc-causes.py render | write | check

STATUS values:
    open        stated, not yet tested
    refuted     tested and found NOT to be the cause -- DO NOT RETEST
    confirmed   tested and found to be a real defect
    fixed       a real defect, corrected in the tree
    latent      a real defect, but not reachable in the workload under study
    superseded  replaced by a better statement of the same thing

WHY THIS EXISTS.  CLAUDE_LOG.md is chronological prose: everything is recorded
and nothing is recoverable.  Answering "did we already try bus pacing?" means
reading nine hundred lines, which is exactly what a compacted conversation no
longer has.  The observed failure mode is not forgetting a fact but
REDISCOVERING AND RE-REFUTING THE SAME CAUSE REPEATEDLY, each cycle costing
runs and ending in the same place.

The cure is the one this repository already applied to HANDOFF.md: put it in a
database, make the Markdown a generated artifact, and give it a search that
answers the only question that matters at the start of a session --

    "Has anyone already looked at this, and what happened?"

RECORD EVERY HANDLE YOU MIGHT LATER SEARCH BY, not just the prose.  A cause is
noticed at an address, in a CSECT, on a processor, under a flag, in a phase.
Any one of those may be the thing a later session has in hand, and an entry
that omits it is invisible to that session.  Addresses matter most: a cause is
nearly always seen AT one, and the same address resurfaces for months.  Ranges
answer point queries -- record 100f8-10129 once and `addr 1010d` finds it.

WRITE FOR THE SEARCHER'S VOCABULARY, NOT YOUR OWN.  This was caught within a
minute of first use: an entry filed as "serial-bus occupancy" was invisible to
`search "bus pacing"`.  If a term might be used later, put it in.

Same rule as the handoffs: A HAND EDIT TO CAUSES.md IS INVISIBLE HERE AND THE
NEXT COMMAND SILENTLY OVERWRITES IT.
"""

import os, sqlite3, sys, textwrap, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
DB   = os.path.join(HERE, "gpc-causes.db")
MD   = os.path.join(HERE, "CAUSES.md")

STATUSES = ("open", "refuted", "confirmed", "fixed", "latent", "superseded")

# (column, help).  Everything here is matched by `search`; `addrs` additionally
# supports range containment via `addr`.
FIELDS = [
    ("area",     "coarse bucket: iop, emulator, tape, flight-sw, method, goal"),
    ("status",   "one of %s" % (", ".join(STATUSES),)),
    ("claim",    "the hypothesis or finding, in the searcher's words"),
    ("evidence", "what settled it, with numbers"),
    ("addrs",    "hex addresses and RANGES, e.g. 1010d,100f8-10129"),
    ("csects",   "CSECT/routine names, e.g. FCMPMOD,FIOMGBOV,ARCGPC"),
    ("instrs",   "instructions, e.g. #DLY,@RAW,ISPB"),
    ("procs",    "processors/buses, e.g. CPU,MSC,BCE18,DK6"),
    ("phases",   "overlay phases, e.g. 8,18"),
    ("config",   "memory configuration, e.g. G9,P9,S2"),
    ("tape",     "which build, e.g. v36,v79,pass-910"),
    ("env",      "flags/hooks involved, e.g. YAGPC_BUS_WORD_US,DEUKEYS"),
    ("files",    "source touched, e.g. src/iop.c,SSSRC/AIGDEU.hal"),
    ("symptom",  "the observable, e.g. no 6/5/0/0,keys=0,pool overflow"),
    ("tsec",     "when in the run, e.g. 391-398"),
    ("doc",      "the document that settled it, e.g. BCE PoO sec 2.2"),
    ("run",      "run id(s), e.g. v66a"),
]
COLNAMES = [f[0] for f in FIELDS]
COLS = "id," + ",".join(COLNAMES) + ",added"

SCHEMA = ("CREATE TABLE IF NOT EXISTS cause (id INTEGER PRIMARY KEY, "
          + ", ".join("%s TEXT NOT NULL DEFAULT ''" % c for c in COLNAMES)
          + ", added TEXT NOT NULL DEFAULT '')")


def db():
    c = sqlite3.connect(DB)
    c.execute(SCHEMA)
    have = {r[1] for r in c.execute("PRAGMA table_info(cause)")}
    for col in COLNAMES + ["added"]:
        if col not in have:
            c.execute("ALTER TABLE cause ADD COLUMN %s TEXT NOT NULL DEFAULT ''"
                      % col)
    c.commit()
    return c


def _spans(text):
    """Parse 'A,B-C' into [(a,a),(b,c)] so a RANGE answers a POINT query."""
    out = []
    for part in (text or "").replace(" ", "").split(","):
        if not part:
            continue
        try:
            if "-" in part:
                a, b = part.split("-", 1)
                out.append((int(a, 16), int(b, 16)))
            else:
                v = int(part, 16)
                out.append((v, v))
        except ValueError:
            pass
    return out


def _rows(c, where="", args=()):
    return c.execute("SELECT " + COLS + " FROM cause " + where + " ORDER BY id",
                     args).fetchall()


def _d(r):
    return dict(zip(["id"] + COLNAMES + ["added"], r))


def _show(r):
    d = _d(r)
    mark = {"refuted": "REFUTED -- do not retest", "fixed": "FIXED",
            "confirmed": "CONFIRMED", "latent": "LATENT (real, unreachable)",
            "open": "open", "superseded": "superseded"}.get(d["status"],
                                                            d["status"])
    print("#%-3d [%s] %s" % (d["id"], d["area"] or "-", mark))
    for line in textwrap.wrap(d["claim"], 74):
        print("     " + line)
    if d["evidence"]:
        for line in textwrap.wrap("evidence: " + d["evidence"], 72):
            print("       " + line)
    tags = ["%s %s" % (k, d[k]) for k in
            ("addrs", "csects", "instrs", "procs", "phases", "config",
             "tape", "env", "files", "symptom", "tsec", "doc", "run")
            if d[k]]
    if tags:
        for line in textwrap.wrap("  |  ".join(tags), 72):
            print("       " + line)
    print()


def cmd_addr(c, terms):
    if not terms:
        print("addr needs a hex address"); return 1
    try:
        want = int(terms[0].lstrip("0x"), 16)
    except ValueError:
        print("not hex: %r" % terms[0]); return 1
    hits = [r for r in _rows(c)
            if any(lo <= want <= hi for lo, hi in _spans(_d(r)["addrs"]))]
    if not hits:
        print("no entry recorded against %05x -- new ground" % want); return 0
    print("%05x appears in %d recorded entr%s:\n"
          % (want, len(hits), "y" if len(hits) == 1 else "ies"))
    for r in hits:
        _show(r)
    return 0


def cmd_search(c, terms):
    if not terms:
        print("search needs a word"); return 1
    pat = "%" + " ".join(terms).lower() + "%"
    where = " OR ".join("lower(%s) LIKE ?" % c_ for c_ in COLNAMES)
    rows = _rows(c, "WHERE " + where, tuple([pat] * len(COLNAMES)))
    if not rows:
        print("no match -- nothing recorded on that yet"); return 0
    for r in rows:
        _show(r)
    return 0


def cmd_list(c, opts):
    where, args = [], []
    for k in ("status", "area", "config", "tape"):
        if opts.get(k):
            where.append("%s=?" % k); args.append(opts[k])
    w = ("WHERE " + " AND ".join(where)) if where else ""
    rows = _rows(c, w, tuple(args))
    for r in rows:
        d = _d(r)
        print("#%-3d %-9s %-10s %s" % (d["id"], d["area"][:9], d["status"],
                                       d["claim"][:52]))
    print("\n%d entr%s" % (len(rows), "y" if len(rows) == 1 else "ies"))
    return 0


def cmd_show(c, ids):
    for i in ids:
        r = _rows(c, "WHERE id=?", (int(i),))
        _show(r[0]) if r else print("no #%s" % i)
    return 0


def cmd_fields(c):
    print("Searchable fields (all matched by `search`):\n")
    for name, helptext in FIELDS:
        print("  --%-9s %s" % (name, helptext))
    print("\n  `addr HEX` additionally matches RANGES recorded in --addrs.")
    return 0


def cmd_add(c, opts, rest):
    claim = opts.get("claim") or (" ".join(rest) if rest else "")
    if not claim:
        print("add needs --claim"); return 1
    st = opts.get("status", "open")
    if st not in STATUSES:
        print("status must be one of %s" % (STATUSES,)); return 1
    opts = dict(opts); opts["claim"], opts["status"] = claim, st
    vals = [opts.get(k, "") for k in COLNAMES] + [datetime.date.today().isoformat()]
    c.execute("INSERT INTO cause (%s) VALUES (%s)"
              % (",".join(COLNAMES + ["added"]),
                 ",".join("?" * (len(COLNAMES) + 1))), vals)
    c.commit()
    print("added #%d" % c.execute("SELECT last_insert_rowid()").fetchone()[0])
    return cmd_write(c)


def cmd_set(c, ident, opts):
    for k in COLNAMES:
        if k in opts:
            if k == "status" and opts[k] not in STATUSES:
                print("status must be one of %s" % (STATUSES,)); return 1
            c.execute("UPDATE cause SET %s=? WHERE id=?" % k,
                      (opts[k], int(ident)))
    c.commit()
    return cmd_write(c)


def render(c):
    out = ["# Causes investigated, and what happened\n",
           "GENERATED FROM `gpc-causes.db` BY `gpc-causes.py` -- a hand edit here is\n"
           "invisible to the database and the next command silently overwrites it.\n\n"
           "Before spending a run on anything below, ask:\n\n"
           "    gpc-causes.py addr 1010d      # is this address already accounted for?\n"
           "    gpc-causes.py search pacing   # has this idea already been tried?\n"]
    for st, head in (("open", "Open"), ("confirmed", "Confirmed"),
                     ("fixed", "Fixed"),
                     ("latent", "Latent (real, but unreachable here)"),
                     ("refuted", "Refuted -- DO NOT RETEST"),
                     ("superseded", "Superseded")):
        rows = _rows(c, "WHERE status=?", (st,))
        if not rows:
            continue
        out.append("\n## %s\n" % head)
        for r in rows:
            d = _d(r)
            out.append("- **#%d** %s%s" % (d["id"],
                       ("*(%s)* " % d["area"]) if d["area"] else "", d["claim"]))
            if d["evidence"]:
                out.append("  - evidence: %s" % d["evidence"])
            tags = ["%s `%s`" % (k, d[k]) for k in
                    ("addrs", "csects", "instrs", "procs", "phases", "config",
                     "tape", "env", "files", "symptom", "tsec", "doc", "run")
                    if d[k]]
            if tags:
                out.append("  - " + " &middot; ".join(tags))
    return "\n".join(out) + "\n"


def cmd_render(c):
    sys.stdout.write(render(c)); return 0


def cmd_write(c):
    open(MD, "w").write(render(c)); print("wrote %s" % MD); return 0


def cmd_check(c):
    cur = open(MD).read() if os.path.exists(MD) else ""
    if cur == render(c):
        print("CAUSES.md matches the database"); return 0
    print("CAUSES.md DIFFERS from the database -- run `write`"); return 1


def main(argv):
    if len(argv) < 2 or argv[1] in ("-h", "--help"):
        print(__doc__); return 0
    opts, rest = {}, []
    for a in argv[2:]:
        if a.startswith("--") and "=" in a:
            k, v = a[2:].split("=", 1); opts[k] = v
        else:
            rest.append(a)
    c = db()
    cmd = argv[1]
    if cmd == "addr":   return cmd_addr(c, rest)
    if cmd == "search": return cmd_search(c, rest)
    if cmd == "list":   return cmd_list(c, opts)
    if cmd == "show":   return cmd_show(c, rest)
    if cmd == "fields": return cmd_fields(c)
    if cmd == "add":    return cmd_add(c, opts, rest)
    if cmd == "set":    return cmd_set(c, rest[0], opts) if rest else 1
    if cmd == "render": return cmd_render(c)
    if cmd == "write":  return cmd_write(c)
    if cmd == "check":  return cmd_check(c)
    print("unknown command %r" % cmd); return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
