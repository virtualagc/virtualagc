#!/usr/bin/env python3
"""Merge two branches' gpc-causes.db (the ledger) by row, for a git merge conflict.

    merge_ledger_dbs.py BASE.db OURS.db THEIRS.db OUT.db

A text merge of an SQLite file is meaningless, and the ledger is the one file every branch appends to, so every
merge of two branches that both added entries conflicts.  This does what git cannot: the union of the rows.

  - a row that only one side added or changed is taken as it is;
  - a row both sides changed identically is taken once;
  - a row both sides changed (or added under the same id) DIFFERENTLY is two different entries that happened to get
    the same number: OURS keeps the number, and THEIRS's row is renumbered to the next free id.  "#N" in the text of
    the renumbered rows is rewritten to the new number, and every renumbering is printed, because other documents
    (the generated CAUSES.md is regenerated, but prose in other files and in commit messages is not) may still use the
    old number for the entry as THEIRS knew it.

After the merge run `gpc-causes.py render` (or `write`) to regenerate CAUSES.md.  Only the `cause` table is merged;
the other tables, if there are any, are taken from OURS.
"""
import re
import shutil
import sqlite3
import sys


def rows(path):
    c = sqlite3.connect(path)
    c.row_factory = sqlite3.Row
    r = {x["id"]: dict(x) for x in c.execute("select * from cause")}
    c.close()
    return r


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    base_p, ours_p, theirs_p, out_p = sys.argv[1:]
    base, ours, theirs = rows(base_p), rows(ours_p), rows(theirs_p)
    merged = dict(ours)
    renumbered = {}
    nxt = max(list(ours) + list(theirs)) + 1
    for i, t in sorted(theirs.items()):
        if i in ours and ours[i] == t:
            continue                                          # the same on both sides
        if i in base and ours.get(i) == base[i]:
            merged[i] = t                                     # only THEIRS changed it
            continue
        if i in base and t == base[i]:
            continue                                          # only OURS changed it
        if i not in ours:
            merged[i] = t                                     # added only by THEIRS
            continue
        renumbered[i] = nxt                                   # same number, different entries
        nxt += 1
    for old, new in renumbered.items():
        row = dict(theirs[old])
        row["id"] = new
        for k, v in row.items():
            if isinstance(v, str):
                row[k] = re.sub(r"#%d\b" % old, "#%d" % new, v)
        merged[new] = row
    shutil.copyfile(ours_p, out_p)
    c = sqlite3.connect(out_p)
    cols = [x[1] for x in c.execute("pragma table_info(cause)")]
    c.execute("delete from cause")
    for i in sorted(merged):
        c.execute("insert into cause (%s) values (%s)" % (",".join(cols), ",".join("?" * len(cols))),
                  [merged[i][k] for k in cols])
    c.commit()
    c.execute("vacuum")
    c.close()
    print("merged: %d rows (ours %d, theirs %d)" % (len(merged), len(ours), len(theirs)))
    for old, new in sorted(renumbered.items()):
        print("  THEIRS #%d renumbered to #%d: %s" % (old, new, theirs[old]["claim"][:90].replace("\n", " ")))


if __name__ == "__main__":
    main()
