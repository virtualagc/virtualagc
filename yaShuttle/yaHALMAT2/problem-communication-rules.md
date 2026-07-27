# How yaGPC2/yaHALMAT2 issue tracking works now

This supersedes the earlier `problems-yaHALMAT2.md` / prior version of
this file. Cross-project issues are now tracked in a **SQLite
database**, not Markdown:

    /home/rburkey/git/virtualagc/yaShuttle/yagpc2-yahalmat2-issues.db

(sibling to both `yaGPC2/` and `yaHALMAT2/`). Query it directly with
the `sqlite3` CLI — there is no document to read, parse, or sync.

## Why the change

The Markdown version worked but had two costs: reading it to check
status meant loading the whole file (or at least a whole section) into
context even for a one-line answer, and editing it required going
through the "Full Documentation Sync" ritual since it's a `.md` file
under the global no-md-edit-without-trigger-phrase rule. A SQLite
database sidesteps both: a status check is a narrow `SELECT` that
returns only the columns you ask for, and — importantly — **it isn't a
Markdown file at all, so the no-md-edit rule simply doesn't apply to
it**. Both projects can `INSERT`/`UPDATE` it directly, in real time, no
sync needed. (This is a different situation from the standing exception
that was tried and reverted for `.md` files — nothing is being excepted
here, the rule never covered this file type to begin with.)

## Schema

```sql
CREATE TABLE issues (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    key                TEXT UNIQUE NOT NULL,   -- stable slug, e.g. 'bit_integer_conversion'
    title              TEXT NOT NULL,          -- one-line summary
    status             TEXT NOT NULL CHECK (status IN
                         ('open','fixed','not_a_bug','deferred','wontfix')),
    found_in           TEXT NOT NULL CHECK (found_in IN ('yagpc2','yahalmat2')),
    found_date         TEXT NOT NULL,          -- ISO date
    resolved_in        TEXT CHECK (resolved_in IN ('yagpc2','yahalmat2')),
    resolved_date      TEXT,
    next_action_owner  TEXT CHECK (next_action_owner IN ('yagpc2','yahalmat2','either','none')),
    severity           TEXT CHECK (severity IN ('low','medium','high')),
    summary            TEXT NOT NULL,          -- 2-4 sentences; always cheap to read
    detail             TEXT,                   -- full repro/root-cause/citations; pull on demand only
    affected_tests     TEXT,                   -- space-separated test_* names sharing this root cause
    last_verified_date TEXT,                   -- last time someone actually re-ran and confirmed this
    updated_at         DATETIME DEFAULT CURRENT_TIMESTAMP  -- auto-updated by trigger on any UPDATE
);

CREATE TABLE project_status (
    project    TEXT PRIMARY KEY CHECK (project IN ('yagpc2','yahalmat2')),
    is_busy    INTEGER NOT NULL DEFAULT 0 CHECK (is_busy IN (0,1)),
    busy_note  TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

Run `sqlite3 yagpc2-yahalmat2-issues.db .schema` for the authoritative
definition (includes the `updated_at` triggers).

One issue = one root cause, not one test file — several tests often
turn out to share a single fix (see `affected_tests`), and giving each
its own row would mean updating N rows for one real change.

## Common operations

**What's open and needs my project's attention:**
```sql
SELECT key, title, summary FROM issues
WHERE status='open' AND next_action_owner IN ('yahalmat2','either');
```

**Full detail on one item** (only pull this when you're actually about
to work it):
```sql
SELECT * FROM issues WHERE key = 'compool_array_integer_type';
```

**Report a new issue found while testing the other project:**
```sql
INSERT INTO issues
  (key, title, status, found_in, found_date, next_action_owner, severity, summary, detail, affected_tests)
VALUES
  ('my_slug', 'one-line title', 'open', 'yagpc2', date('now'), 'yahalmat2', 'medium',
   '2-4 sentence summary', 'full repro/root-cause detail', 'test_whatever');
```

**Mark something resolved:**
```sql
UPDATE issues SET status='fixed', resolved_in='yahalmat2', resolved_date=date('now'),
  next_action_owner='none', summary='what actually changed, condensed'
WHERE key='my_slug';
```
(`detail` can stay as-is — nobody has to read it once `status != 'open'`,
so there's no need to shrink it the way the old Markdown convention
required.)

**Before trusting the other project's executable/behavior for
cross-testing:**
```sql
SELECT is_busy, busy_note FROM project_status WHERE project='yagpc2';
```
This is a cooperative signal, not an enforced lock — it's only as good
as whoever's mid-refactor remembering to set it. Also run `git status
--short` in the other project's directory; that check is fully
mechanical and catches incidental uncommitted state even if the flag
wasn't set.

**Setting your own busy flag** (do this yourself at the start of a
multi-step, uncommitted change to core interpreter/emulator logic;
clear it once committed and re-tested):
```sql
UPDATE project_status SET is_busy=1, busy_note='mid-refactor of X' WHERE project='yahalmat2';
-- ... later, once stable and committed:
UPDATE project_status SET is_busy=0, busy_note=NULL WHERE project='yahalmat2';
```

## `last_verified_date`

Set this whenever you actually re-run and confirm a `fixed`/`not_a_bug`
finding — not just when you edit an unrelated column. A finding that
hasn't been re-checked in a long time is worth re-verifying before
citing it as settled; this project's own history includes at least one
case (`bit_integer_conversion`) where a status was asserted without
re-running the test and turned out to be wrong.
