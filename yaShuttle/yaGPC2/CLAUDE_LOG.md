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

### [2026-08-19] Target: problems.md
- Cross-checked Don Schmidt's actively-developed `~/donschmidt/nsts-sim-gpc`
  (the live `gpc`/JS project yaGPC2 was originally ported from, forked at
  commit 3c60088) against yaGPC2's own runtime, per the user's request to
  look for changes worth incorporating. Only 3 post-fork commits touch the
  core `gpc/` emulation code (everything else in its recent history predates
  the fork and is already in yaGPC2's baseline): `f4cf76d` (#RDL's operand is
  an address field, not a count — an assembler/RLD-relocation fix, not
  applicable to yaGPC2's own runtime, which never assembles/links);
  `4d68a61` (per-instruction timing/interval-timers/real-time mode — no
  action: yaGPC2's own `instr_time_us()` (src/timing.c) is independently
  ported from the real historical FCOS compiler source
  (`OBJECTGE.xpl`'s `EXECUTION_TIMES`), arguably more authoritative than
  Don's IBM-manual-derived tables, and yaGPC2 already has equivalent
  `--time-scale`/`--pacing` real-time mode); and `af9c4b9` (HAL error-handler
  dispatch + channel-input fixes), which found four real, confirmed gaps in
  yaGPC2 (all fixed 2026-08-19, all in `src/halucp.c`/`.h`):
  1. `TAB(n)` on a READ statement had zero effect on input at all (always
     mutated WRITE-side state `apply_read_positioning()` never reads) —
     given an `inReadIOInit` branch mirroring `COLUMN`'s own.
  2. `READALL` had no distinct runtime path — fell through to the same
     comma/blank/semicolon-delimited field extraction as an ordinary READ,
     silently truncating any raw column data containing an embedded
     delimiter. New `extract_readall_field()`/`readAllStatement`
     (USA003087 10.1.2: raw column transfer, up to the CHARACTER variable's
     declared length). `hal-runtime-features.db`'s
     `readall_statement_raw_character_stream_input` row was wrongly marked
     `implemented_via_cpu` ("no distinct runtime code needed") — corrected
     to `implemented`/`tested_dedicated`.
  3. `BIT` input silently stripped any non-0/1 character (including
     genuinely illegal ones) instead of raising ILLEGAL BIT STRING (error
     4:29, matching RUNASM/CTOB.asm's real accepted-character set).
     `hal-runtime-features.db`'s `conversion_data_errors_14_20_22_29_33_50`
     row narrowed/corrected for error 29 specifically (the other 5 bundled
     error numbers weren't re-examined).
  4. Found *while* fixing #1: `apply_read_positioning()`'s COLUMN/TAB
     target resolution silently gave up (clamped to whatever little was
     already buffered) whenever the target landed on data that hadn't been
     fetched yet — the common case for the first READ of a new line under
     `--interactive`. Now retries via a `readSkipApplied` guard once
     `halucp_provide_input()` delivers the awaited line, instead of
     dropping the positioning request for the rest of the statement.
  Also found independently while re-reading `try_on_error_dispatch()`'s own
  SCAL-frame-unwind fallback (the code path used when the "direct case"
  slot-scan above it finds no match): its own header comment already
  disclosed it was "matches halUCP.coffee's `_tryOnErrorDispatch` doc
  comment" — i.e. a faithful port of the *pre-fix* JS algorithm, using a
  computed "stack end" (`callerR0Hi + callerR0Lo`) to locate the FIXV/
  handler slots instead of the fixed `caller_stack_base + 18` the direct
  case (and Don's fix) both use. Fixed to match; not independently covered
  by a new test (no existing fixture drives an SVC-trapped I/O RTL routine
  into this specific fallback), but zero regression across the full suite
  and a direct match to the confirmed-correct formula used everywhere else
  in this function.
  New regression test: `test/test_io_read.sh` (`test/fixtures/ioreadfixes.hal`
  + `_stdin.txt` + `_golden.txt`), wired into `Makefile`'s `test` target.
  Separately: `nsts-sdl-dps`'s `lnk101` needed no rebuild (its own `HEAD` was
  already 0 commits behind `origin/master`, and its Python install is
  editable) — but yaGPC2's committed `.fcm` test fixtures were stale
  relative to 5 real `lnk101` correctness fixes that landed after they were
  last built (absent-section-relocs, PDE-stack-binding, ZCON sign bit,
  CSECT-address-without-X). Re-ran `build_hal_fixtures.sh`; 3 of 57
  fixtures actually changed bytes (`hello`/`read_write`/`read_eof_onerror`);
  updated `debugger_hello_golden.txt` to match (pure symbol-table display
  change). Committed separately (`abbaece05`) before this entry's own fixes.
  GitHub issue #1343 (GPC-to-peripheral networking design, discussed per
  the user's own pointer) is unrelated to any of the above — a separate,
  future servicer-extension discussion, not implemented or acted on here
  per the user's explicit instruction not to touch networking without
  discussion first.

### [2026-08-19] Target: problems.md
- Implemented the real UDP-multicast peripheral-bus bridge planned in the
  session's plan-mode discussion (see `~/.claude/plans/fluttering-
  dazzling-pine.md` for the full design rationale, superseding the
  earlier TASK/SCHEDULE/WAIT plan that file used to hold). New `--bce-
  network` CLI flag installs a `GpcServicerFn` implementation
  (`src/bcenet_framer.c`/`.h`, layer 2: buffers word-at-a-time
  `GPC_SVC_XMIT_WORD`/`XMIT_CMD` calls into whole messages, flushed once
  per CPU instruction tick rather than by decoding the BCE command
  word's own bit-level word-count field, which turned out inconsistent
  across instructions; `src/bcenet_transport.c`/`.h`, layer 3: real
  per-bus UDP multicast sockets matching `nsts-sim-gpc`'s own
  `com/bus.civet` wire format exactly) via the *existing*
  `servicer`/`servicerCtx` extension point -- zero changes to
  `yaGpcIntegration.h` or to either emulator's own engine code, per the
  plan's own key finding.
  Verified end-to-end, not just built: hand-assembled
  `test/fixtures/gen_bcenet_smoke_fcm.cjs` drives a real CPU->MSC->BCE6
  activation sequence (`PC`/`LBP`/`LI`/`SIO`, encodings derived by hand
  from the real `PackedBits` descriptors and confirmed via `--trace`
  register readback -- MSC's round-robin scheduler
  (`iopls_next_slice()`) gives each BCE exactly one turn per 33-slice
  major cycle, which the fixture's own filler-instruction count accounts
  for) issuing a real `#CMDI`+`#TDS`. The resulting UDP packet was
  received correctly both by a raw socket and by `nsts-sim-gpc`'s own
  real `com/bus.civet` `Bus` class directly (via
  `@danielx/civet/register`, not a JS stub of our own) -- confirmed
  byte-for-byte wire-format interop. The receive direction
  (`bcenet_transport_recv()`) was verified separately against a real
  `Bus#sendMsg()` call (a batch yaGPC2 run completes too fast to
  reliably race an external sender within one process's lifetime for a
  live `#RDS` test). New `test/bcenet_smoke.sh` +
  `test/bcenet_recv_check.c` capture both checks as a repeatable,
  opt-in script (skips cleanly if `nsts-sim-gpc` isn't checked out) --
  deliberately NOT part of `make test`'s own automated suite, since a
  real UDP multicast socket doesn't belong in the deterministic
  standing suite (port conflicts, environment multicast support). Full
  existing suite stays green throughout.
  Scope, per the plan: BCE/MIA peripheral-bus traffic only, not the
  broader "any SVC delegatable to a servicer" idea raised earlier in
  discussion -- the user clarified `SEND ERROR`/`RUNTIME`/`SCHEDULE`/
  `WAIT` etc. should stay native (they already work), and the callback
  is for what the emulator genuinely can't do itself. Also investigated
  and confirmed (via the yaHALMAT2 peer session): yaHALMAT2's `PMHD`/
  `PMAR`/`PMIN` opcodes are the real HALMAT encoding of `%SVC`/`%SVCI`
  (confirmed via `USA003090` 8.7: `%SVC(a)` generates `SVC a` where `a`
  is the operand's *address*, not an immediate SVC number -- matching
  `halucp.c`'s own `svcCode = mem[ea]` shape exactly), currently a
  deliberate hard-fail rather than an absence -- real, separate future
  work on their side, not blocking this one. TCP/shared-memory
  transport variants and discrete I/O (PCI/PCO) remain explicitly out
  of scope, structurally straightforward additions later (new layer-3
  implementations / a new servicer extension) given this layering.
