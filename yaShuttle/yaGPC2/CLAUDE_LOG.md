# CLAUDE_LOG.md

(Cleared 2026-08-16 by Full Documentation Sync — the pending 2026-07-30 entry
was applied to `debugger-planner.md`: the Stage 3 SDF/SRN finding corrected to
say the blank `srn` was the test source's doing rather than a compiler-port
gap, and that the HAL/S statement number was the right key all along; and the
"Multi-unit memory images" section's "still open" update rewritten as resolved,
covering `--unit`, `symtable_get_module_at()`, the `TIME:`-annotation route to
CSECT code/data classification, the per-module statement-number fix, and the
`compileLinkRun --filename=@F` driver. Every file, flag and identifier the
entry named was verified present before it was written down.

The entry's remaining item, the gdb-style no-space repeat count (`step5`), was
deliberately not added: it is a debugger UX detail with no home among this
document's planning stages, and it is already in the code as
`split_digit_suffix()`.)

### [2026-08-17] Target: tools.md
- In the "`gpc run` / `yaGPC2`" section (currently ends ~line 158 with
  "Common invocation flags..."), add a new subsection documenting
  `--time-scale <factor>` and `--pacing <burst|signal>` (src/opts.c/.h,
  src/run.c's batchrunner_pace()): wall-clock pacing for SCHEDULE/WAIT,
  yaGPC2-specific (not part of `gpc run`'s own option set), mirroring
  yaHALMAT2's own flags of the same name/semantics/default
  (`--time-scale` default 1.0 = genuine real time; `--pacing` default
  "burst", alternative "signal" requires the build's HAVE_POSIX_TIMERS
  probe to have succeeded, see the Makefile). Note both flags are inert
  for any program with no TASK/SCHEDULE/WAIT (never enough virtual time
  accumulates between pacing checks to trigger a sleep). See
  problems.md 2.7 for the full implementation writeup/verification this
  should link to or summarize.

### [2026-08-17] Target: README.md
- Add a short capability note (near the top, after the existing
  intro paragraphs describing yaGPC2's scope/purpose) that yaGPC2 now
  supports real-time wall-clock pacing for TASK/SCHEDULE/WAIT programs
  via `--time-scale`/`--pacing`, matching yaHALMAT2's own flags of the
  same name (a partial walk-back of the README's own existing claim,
  line 3, that "an earlier goal of also matching yaHALMAT2's
  command-line-option surface was considered and dropped as
  impractical" -- these two flags are a deliberate, exact exception to
  that, not a reversal of it: point the reader to tools.md's
  `gpc run`/`yaGPC2` section for the full flag documentation rather
  than duplicating it here.

### [2026-08-17] Target: tools.md
- In the same "`gpc run` / `yaGPC2`" section as the `--time-scale`/
  `--pacing` entry above, also document `--date-time-epoch <seconds>`
  (src/opts.c/.h, src/ageharness.c, src/cpu.h's dateTimeAnchorEpochSec):
  Unix epoch seconds overriding `DATE()`/`CLOCKTIME()`'s own wall-clock
  anchor for reproducible runs (yaGPC2-specific, not part of `gpc run`'s
  own option set). Default: the real host machine's current wall-clock
  time (its own configured timezone) at program start; both built-ins
  then progress via emulated/virtual time from that anchor. Note the
  flag is intentionally not identically shaped to yaHALMAT2's own
  `--start-time` (that one also accepts local date/time strings, this
  one accepts only bare epoch seconds) — flagged to yaHALMAT2 as a
  possible future unification, not resolved. See problems.md 7.15 for
  the full implementation writeup/verification this should link to or
  summarize.

### [2026-08-18] Target: problems.md
- 7.15 (`DATE()`/`CLOCKTIME()`) needs a follow-up paragraph: the
  embedding contract (`../yaGpcIntegration/yaGpcIntegration.h`) had a
  real architectural gap the CLI-only fix above didn't close —
  `ageharness_init_minimal()`/`yagpc2_initializer()` (the path any
  Shuttle-sim-style embedder uses via `GpcOps`) never touched
  `cpu.dateTimeAnchorEpochSec` at all, so an embedded instance always
  silently ran with `DATE()`/`CLOCKTIME()` anchored at epoch 0, with no
  way for the embedding "main program" to supply its own starting
  time/date. Per the user's explicit design ("the initializer should
  take this time/date as an argument, and store it in the state
  structure... rather than relying on... some implementation-dependent
  global location"), fixed by adding a `startEpochSeconds` parameter to
  `GpcInitializerFn` and a matching `GpcState.startEpochSeconds` field
  (both in the shared header, alongside `elapsedTime`'s own precedent),
  threaded through `ageharness_init_minimal()`'s new parameter into
  `cpu.dateTimeAnchorEpochSec`, and set on `GpcState` by
  `yagpc2_initializer()` (`src/gpcops.c`). `ageharness_configure_from_opts()`
  (the CLI path) needed no change — it already implements the correct
  policy independently. New regression test
  `test_start_epoch_via_initializer` (`test/test_gpcops.c`) reproduces
  the CLI's own `--date-time-epoch` golden (`datetimefn.fcm`, epoch
  951912000, TZ=UTC) through the embedding path instead, confirming the
  two paths agree. `../yaGpcIntegration/yaGpcIntegration.h` changed —
  since it must stay byte-for-byte identical between yaGPC2 and
  yaHALMAT2, the yaHALMAT2 peer session needs to make the matching
  change on its side (message sent 2026-08-18; check its reply before
  treating the two repos' copies as back in sync).
