# How `problems-yaHALMAT2.md` works

This file explains the convention for `problems-yaHALMAT2.md` (same
directory) — a shared, ongoing issue tracker between the `yaGPC2` and
`yaHALMAT2` projects. `yaGPC2` is a from-scratch AP-101S CPU emulator;
`yaHALMAT2` is a HALMAT bytecode interpreter. Both aim for
byte-identical `WRITE`/`FILE` output given the same HAL/S source, and
each project's own Claude Code sessions occasionally find real bugs or
discrepancies in the *other* project while testing that parity. This
file is where those findings get written down and tracked to
resolution, by whichever side is best positioned to act on them.

## Per-item format

Every item's write-up starts with a status line:

```
**Status:** OPEN — found in yaGPC2 dev, 2026-07-26
**Status:** FIXED — 2026-07-27 (yaHALMAT2)
**Status:** DEFERRED — 2026-07-27 (yaHALMAT2): <one-line reason>
```

- **OPEN** — reported, not yet acted on. Full detail (repro steps,
  primary-source citations, root-cause analysis) belongs here — this
  is the state where a future session needs enough to actually
  investigate and fix it.
- **FIXED** — resolved. See "Condensing resolved items" below.
- **DEFERRED** — looked at and deliberately not fixed (e.g. spec is
  ambiguous, or it's out of scope). Give the reason; condense like
  FIXED once the reasoning is captured.

**Origin tag** (`found in yaGPC2 dev` / `found in yaHALMAT2 dev`):
which project's testing surfaced the item. Whichever project's session
resolves it updates the status line to say so, with the date and which
project made the fix — the origin and resolver are often different
projects, and both are worth keeping.

Use the test's own name (e.g. `test_bit`, `test_stoi`) as the item's
stable identifier — both projects' regression suites already share
these names, so it doubles as the cross-reference.

## Condensing resolved items

Once an item is marked FIXED or DEFERRED, shrink its write-up to
roughly 2-4 lines: what was wrong, what changed (or why it's staying
as-is), and the status line itself. Drop the repro recipe, compiled-
listing excerpts, and any hypothesis-chasing narrative — that detail's
job was to get the fix made or the decision reached; keeping it around
afterward is just future token cost with no remaining use. Move
condensed items below a `## Resolved` heading (or similar) so the
`## Open` items — the ones someone actually needs to act on — stay at
the top of the file and cheap to read.

Once the file has enough resolved items that skimming them costs real
tokens, add a top-of-file index table (`Item | Status | Found in |
One-liner`) so old items can be scanned without reading their full
(even condensed) write-ups.

## Editing this file

`problems-yaHALMAT2.md` is a `.md` file, so it falls under the
standing rule (each project's own `CLAUDE.md`) against editing
Markdown files except via a "Full Documentation Sync": routine
findings/status changes get appended as a dated bullet to that
project's own `./CLAUDE_LOG.md` first, then actually applied to this
file only when the user says the exact phrase "Full Documentation
Sync" in that conversation. A sync can cover just one item — it
doesn't need to wait for a backlog.

This is deliberate, not an oversight: a **standing, permanent**
exception to that rule was tried once before, for this exact project,
and reverted — see `yaHALMAT2`'s own git history around the removal of
a self-granted "CLAUDE.md exception" (committed 2026-07-23) for what
went wrong (a one-time authorization got turned into a rule that
silently applied across all future conversations). Please don't
recreate that pattern here — if a standing exception is ever wanted,
that's something the user would add to a `CLAUDE.md` themselves, not
something either project's Claude session should self-authorize.
