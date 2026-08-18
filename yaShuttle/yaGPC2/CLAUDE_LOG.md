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

### [2026-08-19] Target: problems.md
- Follow-up to the `--bce-network` bridge work above: the user asked
  whether a linked, runnable copy of `PFS/OI340600/SSSRC/BILDNEW5.asm`
  (real GPCIPL boot/IPL assembly, hand-written, not HAL/S-compiled)
  existed to actually drive MEDS. It doesn't -- the only trace is an
  empty (0-byte) leftover `tempAsmLogs/BILDNEW5.asm.log`, and the module
  declares 14 `EXTRN` symbols (`MENU`, `MSGTABLE`, `SSLCKSUM`, etc.) it
  doesn't itself define, meaning it's one CSECT of a larger real
  load-module build whose full composition isn't resolved anywhere I
  found (`CON80/MMBUILD` is just a bare `BUILD;` control card). Real
  future work if pursued, not attempted.
  Instead, found a much more tractable path by reading
  `nsts-sim-gpc/meds/idp.coffee`'s own `recvDK` handler directly: DK-bus
  messages are tagged by their own first word (`op = msg.data16[0]`),
  and `op=1` ("DATA FILL") relays the rest of the message to the MDU as
  a real display frame buffer -- exactly matching a real test fixture
  already checked into `nsts-sim-gpc` itself,
  `data/TEST-9011-GPC_MEMORY.dfb` (541 words). Built
  `test/fixtures/gen_bcenet_dfb_relay_fcm.cjs` (extends the earlier
  smoke-test's CPU->MSC->BCE6 activation sequence with an `LBB`
  (Load BCE Base) MSC instruction and `#TDLI`, the long-transmit-with-
  immediate-count BCE instruction, since a real DFB is hundreds of
  words -- `#TDS`'s 5-bit count field only reaches 32). This uncovered
  a real bug found via this new fixture, not the earlier one: both
  `bcenet_framer.c`'s `FRAMER_MAX_WORDS` and
  `bcenet_transport.c`'s own receive buffer were hardcoded to 64 words
  ("generous headroom over any real BCE long-form transfer" -- wrong,
  confirmed empirically), silently truncating anything longer; bumped
  both to 1024. Verified end-to-end against `nsts-sim-gpc`'s own real
  `Bus` class: the full 542-word message (op word + all 541 DFB words)
  arrives byte-for-byte identical to the source file, shaped exactly as
  `recvDK` expects. Added as a third check in `test/bcenet_smoke.sh`.
  This is now the more meaningful artifact to try against a live
  `MEDS.sh` Electron session -- unlike the earlier single-arbitrary-word
  smoke test, a real MEDS/IDP instance receiving this should actually
  show visible content, not just accept the packet. Still the user's own
  check to make (GUI, not visually inspectable from here). Full existing
  suite stays green throughout.

### [2026-08-19] Target: problems.md
- `MEDS.sh` itself turned out blocked on missing `npm` deps (`jquery`,
  `three` -- declared in `nsts-sim-gpc`'s `package.json` but never
  actually installed; `SETUP.sh`'s own `npm install` step apparently
  never ran to completion there). Fixed with the user's explicit go-
  ahead (`cd ~/donschmidt/nsts-sim-gpc && npm install`, external repo,
  git status clean before and after -- only `node_modules` changed).
  `MEDS.sh crt1 idp1` then built and launched cleanly -- the user
  confirmed the window itself opened correctly (Claude's own bare
  `timeout 20 ./MEDS.sh` launch, no BCE traffic driving it at all).
  **Correction: this does NOT yet confirm the `bcenet_dfb_relay.fcm`
  live test itself** -- an earlier version of this entry claimed the
  user had run that specific test and confirmed correct display output,
  which was wrong (a real over-claim on Claude's part, caught and
  corrected by the user in the same conversation). Only "MEDS launches
  and renders a window at all" is confirmed so far; the actual
  end-to-end `--bce-network`/DFB-relay validation is still pending the
  user's own run.

### [2026-08-19] Target: problems.md
- The user did run `bcenet_dfb_relay.fcm` against a live MEDS session:
  the command completed (two harmless "BCE: unknown instruction 0"
  messages -- BCE6 running past its own 2-instruction program into
  unfilled memory after finishing real work, `iop_bce_instr.c`'s own
  unrecognized-opcode path never advances NIA so it just repeats;
  expected, not a bug), and MEDS's clock kept counting -- but nothing
  else changed, and the user confirmed the clock runs regardless
  (unrelated to the test).
  Root cause, found by reading `com/lru.civet`'s `_setupBuses()`
  directly: `nsts-sim-gpc` constructs every one of its own real buses
  (DK1 included) via `new Bus(busName, busConfig[busName])` -- exactly
  2 arguments, so `isShuttleBus` defaults to `false`, meaning NO 2-byte
  IUA-prefix header on the wire. `bcenet_framer.c` hardcoded
  `FRAMER_IS_SHUTTLE_BUS = true`. Confirmed directly: a `Bus`
  constructed the *real* way (`new Bus('DK1', busConfig['DK1'])`)
  receiving the bridge's old output saw `[0x0100, 0xbeef]` instead of
  `[0xbeef]` -- the IUA+reserved header bytes, never stripped, shifted
  every real word by one position. All of this session's own
  "verified against the real `Bus` class" checks had been testing
  against a listener Claude itself built with `isShuttleBus=true` --
  consistent with the bridge's own (wrong) assumption, not with what
  `nsts-sim-gpc` actually does.
  Fixed: `FRAMER_IS_SHUTTLE_BUS` is now `false`. `test/bcenet_smoke.sh`
  and `test/bcenet_recv_check.c` updated to construct their own test
  `Bus` instances the same real way (`busConfig[name]`, 2 args) instead
  of the old 4-arg shuttle-framed form. All three `bcenet_smoke.sh`
  checks re-verified passing against the corrected construction. Full
  existing suite stays green. The live MEDS test is worth trying again
  now that the actual framing bug is fixed.

### [2026-08-19] Target: problems.md
- **Live MEDS confirmation, for real this time.** Still no visible
  change after the framing fix (same 2x "BCE: unknown instruction 0" as
  before -- confirmed harmless/expected, unrelated). Debugged live using
  Chrome DevTools Protocol (Electron's `--remote-debugging-port`,
  temporarily added to `nsts-sim-gpc`'s `main.civet` -- a real user
  needed for a real diagnosis here, not guessing): the message *was*
  reaching `idp1`'s real `recvDK` handler correctly (`"IDPIDP1: DK1 DATA
  FILL (1082 bytes)"`, matching the fixture's real payload size exactly)
  and the bridge's own wire-protocol fix (2026-08-19, earlier entry) is
  now fully confirmed correct, live. The remaining blocker was entirely
  on `nsts-sim-gpc`'s own side, two real bugs in its DFB/FCW renderer,
  found and fixed there (with the user's explicit go-ahead) via CDP-
  captured stack traces:
  1. `meds/mduScreen_DPS.coffee`'s `setBGDFB()` used CoffeeScript/Civet's
     *inclusive* range (`[1..msg.data16.length]`) instead of exclusive
     (`[1...msg.data16.length]`, matching the correctly-written `setTime()`
     right below it) -- read one word out of bounds, writing `undefined`
     into the FCW buffer.
  2. `meds/deuFCW.coffee`'s `decodeFCW()` didn't guard against
     `@decode()` returning `undefined` for an unrecognized halfword,
     crashing the whole render on the first one; `drawFCWS()` didn't
     guard its own caller-side use either. Fixed both (return early /
     `continue unless desc?`) -- turns "one bad word crashes everything"
     into "skip that word, keep going."
  Root cause of *why* words go unrecognized: `nsts-sim-gpc`'s own
  `@FCWS` table only implements single-halfword opcodes; its own
  comments document several real historical multi-halfword FCW types
  (POSITION variants, LINE, VPARM, RTC, TEST, DASH ON, etc.) as not yet
  built -- confirmed a whole missing opcode category (every unmatched
  word in the real DFB fixture starts with binary `1001`/`0x9x`, which
  no current `@FCWS` entry's prefix matches). Real, substantial,
  genuinely `nsts-sim-gpc`'s own unfinished territory -- not something
  fixed or fixable from yaGPC2's side, and not attempted further here.
  **User confirmation, verbatim: "Stuff appeared. It's goofy looking,
  but it appeared."** -- exactly consistent with ~32% (172/541) of the
  real DFB's FCWs being silently skipped rather than rendered. This is
  the real, live, end-to-end confirmation the whole `--bce-network`
  bridge was built for. The temporary CDP debugging switch in
  `main.civet` and the diagnostic `console.log` in `deuFCW.coffee` are
  still present in `nsts-sim-gpc`'s own working tree (not committed
  anywhere) -- the two real fixes (off-by-one, undefined-guard) are
  worth keeping/upstreaming to Don; the CDP switch was purely a
  debugging aid and should probably be reverted once no longer needed.
