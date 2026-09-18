# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Filename.md]
    - note

and they are applied to their targets on the next "Full Documentation Sync".

For CAUSES INVESTIGATED and FIXES ATTEMPTED use `gpc-causes.py` instead --
that is a database with an `addr`/`search` front end, not prose, precisely
because this file records everything and recovers nothing.

### [2026-09-17] Target: [README.md]
- New `src/envcache.c` / `src/envcache.h`: a memoised `getenv` keyed on the
  call site's string-literal ADDRESS, so a repeat costs one pointer compare.
  All 165 literal `getenv` call sites in `src/*.c` now call `yagpc_getenv`.
  Safe because nothing in the tree calls `setenv`, `putenv` or touches
  `environ`. Per-thread tables, so the GPC threads neither share nor lock.
- `Makefile`: `src/envcache.c` added to `IOP_DEPS`, `IOP_TEST_DEPS` and the
  three standalone test recipes that link `src/*.c` directly.

### [2026-09-18] Target: [HANDOFF-PERSISTENCE.md]
- Superseded by the rewritten plan (manual-only capture; mid-run save from
  manager.py; simulatePASS owns the mechanism).  Corrections to the old text:
  its `vehicle.c:189-262`, `run.c:2021/2150/1590` have drifted to
  `vehicle.c:186-268`, `run.c:2218/2347/1743`; `cfailLatched` no longer exists
  (deleted c35af840c); `simulatePASS.py` lives in `discretePanel/`, not at the
  yaShuttle top level; `--no-halucp-svc` is already passed (`:750`), so HalUCP
  and Scheduler are out of scope; `--date-time-epoch` already exists
  (`opts.c:429`), so GMT continuity needs no C.
