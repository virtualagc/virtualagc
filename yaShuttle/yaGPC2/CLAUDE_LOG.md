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

### [2026-08-22] Target: [ASM101S/ASM101Sa-notes.md]
- `asm101` (nsts-sdl-dps) MIS-ASSEMBLES `B disp(reg)`; our ASM101S.py does
  not.  `B 1(2)` -> `DF04`, the one-halfword SRS short form, silently
  DISCARDING the register; ASM101S.py -> `C7F2 0001`, the RS form.
  Decoded against Figure 2-11 (RS: Op|R1|..|AM(13)|B2(14-15)|AddrSpec):
  `C7F2` has B2=10=register 2 and AM=0, displacement `0001`, so the
  target is R2+1 -- what `D(B)` means in S/360 operand syntax, and what
  a subroutine return needs.  `DF04` is BCF mask 7 disp 1, and the
  manual is explicit that BCF adds "the Disp to the updated IC", so the
  register never participates.  `B 1(0,2)` and `B 1(2,0)` DO assemble
  correctly in both, so it is specifically the one-register form.
- WHY IT WAS NEVER CAUGHT: the idiom appears in exactly four places in
  the whole corpus -- `BUMP64C`/`DEC64C` in MLIB80/SVCALT.asm and
  `BUMP56C`/`BUMPMLTD` in MLIB80/SVCHNDLR.asm, all four the
  "OTHERWISE, GET OUT OF TOWN" returns of the BUMP subroutines.  Neither
  file has a standalone object in any byte-verified corpus (both are
  COPY fragments), so RUNASM 205/205 and OI301700 272/272 never
  exercised it.
- CONSEQUENCE, and it is the whole reason GPCIPL never boots: SVCALT's
  `BUMPWRDN DC Y(BUMP64C),Y(DEC64C)` are the power-fail executive's
  dispatch switches.  `BALR 7,7` calls one, the callee cannot return
  because its return branch lost the base register, and control loops
  forever in the eight halfwords around `BUMPWRDN`.  Both yaGPC2 and
  Don's gpc sit in that loop with identical iteration counts, because
  both are running the same mis-assembled image -- which is why the
  simulator-vs-simulator comparison could never find it.

### [2026-08-23] Target: [ASM101S/ASM101Sa-notes.md]
- CONFIRMED END TO END.  Reassembled BILDNEW5 with ASM101S.py (via
  modules/sdfpkg/assemble-one.sh, which builds the combined
  MLIB80+INCL80+INCLIB library the assembler needs -- pointing --library
  at MLIB80 alone is not enough).  22 minutes, exit 0.  The new listing
  has `01C20 C7F2 0001  BUMP64C  B  1(B2)` where asm101 emitted `DF04`.
- Swapped that one object into PHASE10/obj, relinked PHASE10 (0
  unresolved) and recomposed.  GPCIPL LEAVES THE LOOP: where every
  previous run sat on the same eight halfwords around BUMPWRDN forever,
  it now runs 172 distinct addresses and lands in BSL1UNPT/MEMPATRN
  executing `ISPB 0,X'0000'(2,)` -- Insert Storage Protect Bits, walking
  memory a halfword at a time with the address register incrementing.
  That is the "unprotects its writable data" step of Don's own account
  of a good boot.  At 40M instructions it is still in that walk but has
  moved to another bank (BSR 1 -> 0), so it is progressing, not stuck.
- OPEN: whether the unprotect walk terminates, and what follows it.
  Comparing the corrected image against gpc to see whether the two still
  agree now that the image is right.

### [2026-08-23] Target: [modules/sdfpkg/HANDOFF-OI340600.md]
- WE NOW RUN PAST THE REFERENCE.  On the corrected image gpc STOPS at
  37,985 steps, "wait state" -- GPCIPL enters WAIT at 01df8 after an SSM
  unmasks interrupts and nothing ever wakes it; with Don's own real-time
  flags (--real-time --rt-factor 0.35 --max-steps 0) it still gives up,
  "wait state (timeout)", after 6.8 SECONDS of simulated time.  yaGPC2
  never reaches that WAIT: the two take different paths from the
  divergence at ~20,773, where the software polls STAT4 (BUSY/WAIT) in a
  bounded BCTB retry loop and the answer depends on how far the BCEs have
  got.  yaGPC2's path continues into BSL1UNPT's unprotect walk, which is
  the step Don's account of a good boot describes; gpc's dead-ends.
- So the 20,773 divergence is NOT merely a timing artifact after all --
  it selects between two different control-flow paths.  Which of the two
  is right is unresolved: yaGPC2's is the one that matches the narrative,
  gpc's is the one that stops.  Note gpc is not authoritative on timing,
  and this difference is downstream of interval-timer pacing.
- The unprotect loop itself is bounded where we can see it (R3 = 0x2141
  counting down at step ~37,985), but a later pass shows R3 negative and
  decrementing, which cannot terminate.  Running long to see whether the
  walk completes or wedges.

### [2026-08-23] Target: [ASM101S/ASM101Sa-notes.md]
- DON FIXED THE SAME ASSEMBLER BUG INDEPENDENTLY.  nsts-sdl-dps
  2228e1e "asm101: SRS/USING addressing, IOP encodings, and
  section-correct relocation" -- which we had NOT cherry-picked -- makes
  `B 1(2)` assemble to `C7F2 0001`, byte-identical to ASM101S.py's own
  output, where the older asm101 emitted the one-halfword `DF04`.  The
  fix appears to fall out of his SRS form-selection work rather than
  being aimed at this idiom.
- REBUILT PROPERLY.  Cherry-picked 2228e1e onto con80build-pch-extension-v2
  and re-ran `con80build --phase 10 --assemble --link`; both BUMPWRDN
  dispatch targets now hold C7F2 in the composed image.  The hand-placed
  ASM101S object is no longer needed -- con80build produces a correct
  BILDNEW5 on its own, so the fragile swap is retired.
- AND OUR IMAGE NOW MATCHES DON'S BIT FOR BIT IN BEHAVIOUR.  yaGPC2 runs
  our rebuilt PHASE10 and his IPL.fcm to the same 21,883 instructions
  with ZERO divergences and zero phase slips, ending in the same wait at
  01df8 with identical registers.  Our build pipeline is validated
  against a build he confirms boots.
- STILL EXCLUDED: 002c521 (con80build parallel builds).  Master's
  halsc.in still has no --templib-out while con80build.py still passes
  it, so that mismatch is unfixed upstream and the commit remains
  unusable.

### [2026-08-23] Target: [problems.md]
- GPCIPL/IPL.fcm trace agreement vs. current `gpc` went 20,917 -> 35,036
  matched instructions, 0 phase slips; the run now executes the full
  300,000 steps instead of parking at 21,899.  Fifteen defects, each
  confirmed against the POO (`ASM101S/AP-101S-instruction-set.txt`)
  and/or nsts-sim-gpc before changing anything:
  MSC `@BC`/`@BXC` branch displacement is relative to the UPDATED PC
  (was one halfword early, so the MSC missed `@INT` and went idle);
  MSC `@INT` never loaded IOP Interrupt Register C; `ME`/`MER` dropped
  the low half of the double-length product; `MED`/`MEDR` used the
  AP-101 C/M multiply (`mulQeE`) instead of the AP-101S's own
  (`mulQeS`, newly ported) and `mulQeE` itself was 1 ulp high on
  postnormalising products; Figure 2-20 note '#' (machine check /
  store protect force old-PSW CC to 10, clear carry+overflow) was
  missing; the fixed-point overflow INDICATOR was never set and never
  re-tested after SPM/LPS; program-check codes for fixed-point overflow
  (0004, was 0002) and address specification (0002, was 0003 -- not a
  program check at all); External 0/1 did not write their own 0000
  interrupt code; TEST INTERRUPTS set the registers but raised none of
  the four levels; RM status was handed back raw -- no voter state and
  the GO/NO-GO watchdog was not modelled at all (ported: counter,
  0.768 ms tick, timeout latch, LOAD TEST REGISTER voter);
  CONFIGURE TERMINATION CONTROL LATCHES wrote the timer latch to bit 19
  instead of 18; POO 14.1 index alignment (LM/STM/LPS take a halfword
  index despite fullword operands) was not modelled and SSM/TS were
  marked fullword; auto storage modification used the POST-incremented
  address for its own access; LDM/STDM read the four DSEs as nibbles of
  the high halfword instead of the low nibble of each byte; only 4 DSEs
  were kept where the machine has 8 (LXA on R4-R7 aliased onto R0-R3);
  STXA/STXAR were empty stubs; and instruction decode ranked candidate
  patterns by mask VALUE rather than by how many bits they fix, so
  `STXA` with R1=010 decoded as `SHW`.
- Disassembly now renders the extended-addressing markers (`@`, `@@`,
  `*+`, `*-`, trailing `+`) and omits the dangling comma of an elided
  base.
- Fixture tooling: `gen_cpu_ea_fixtures.cjs` never set `indexWidth`, so
  the oracle evaluated `x << (undefined - 1)` -- a shift by NaN, i.e. by
  0 -- and every indexed EA fixture silently asserted halfword
  alignment.  `gen_iop_instr_exec_fixtures.cjs` still used the
  reference's old `regHalt` name (now `regProcEnable`) and could not run
  at all.  Suites now: decode 4620/4620, floatIBM 75500/75500,
  instr_tostr 20000/20000.
- STILL OPEN, all pre-existing and measured: `g_EXPAND` drops sector
  bits (+0x8000/0x10000/0x18000) in ~900 EA cases; the DIAG command
  family is a stub beyond one command; the IU store-conflict model
  (POO 15/16.8 -- DIAG 7100/7101, `iuShadow`) is absent, which is
  exactly where the trace now diverges at 35,036; MSC fixture suite
  fails ~12k on what looks like local-store width.

### [2026-08-23] Target: [problems.md]
- IU store-conflict model ported (POO 15/16.8): DIAG 7100/7101 toggle
  detection, and with it OFF a store into the IC-1..IC+23 window keeps
  the pre-store halfword in an `iuShadow` the fetch prefers, flushed at
  every discontinuity.  GPCIPL's self test stores an instruction over
  itself and requires the STALE one to run.  35,036 -> 43,311 matched
  instructions, 0 phase slips.
- DIAG took its command from the HALFWORD AT the effective address; the
  command IS the effective address.  Every DIAG had been decoding
  whatever happened to be in storage.  Whole family ported (1000, 7000/
  7001 + the H-BUS IIO commands, 7100/7101, 9100, C000, D100, E300/E301,
  F300, and the sect.15 self-test EA list); 9014 now clears the pending
  register first and gates the two timers on 00B0/00B1 being zero.
- AGE implemented: the twelfth interrupt, External 1's vector and mask
  bit with its own latch and interrupt code 0006, LOWEST priority.  The
  interrupt-priority self test requires it eighth.
- Masked machine check / instruction monitor no longer stay pending
  (POO 2.5.2.3) -- only the system class waits for an unmask.
- ICR: counter reads come back TWO counts high; the PSA half of a
  counter write goes past store protect and resets the clock latch;
  per-command execution times (POO p.10-3); channel reset zeroes the
  IOP interrupt registers; undefined commands are illegal ops.
- Store path: every instruction store now goes through cpu_store_hw/
  cpu_store_fw, which test BOTH halfwords' protect bits before writing
  either, honour storeProtectOverride (left ON by an ISPB with an
  illegal M1 -- dismissed before as a no-op because nothing read it),
  and feed the IU shadow.
- IOP: MSC @STP and BCE #STP self tests were stubs; both copy fixed PSA
  fullwords (0106->0108, and 010a+2(n-1) -> +1) and the MSC leaves its
  signature in processor 25's local store -- which did not exist, the
  page array being one short.  MSC @STP's pattern was a bare literal so
  OPX never decoded.  Data-flow parity ported whole: four generators,
  four checkers, the priority-encoded register-B code, and the
  halt-everything response.
- **Pattern parser**: getMask/getMaskedDescVal replaced only LOWERCASE
  field letters, leaving an uppercase one in the string for parseInt to
  truncate on.  Faithful to an old reference; the current one replaces
  [a-zA-Z_].  It wrecked the mask of every pattern with an uppercase
  field in its first halfword -- the MSC's "0011Illlllllllll" and the
  BCE's "#STP", whose I bit selects the MIA-transmit form.
- Suites: packedbits 216/216, decode 4620/4620, floatIBM 75500/75500,
  instr_tostr 20000/20000, cpu_instr_exec +300.
- STILL OPEN: g_EXPAND sector bits (~900 EA fixtures); MSC fixture suite
  ~12k on what looks like local-store width; MVH does not apply R1's DSE
  to its destination (our own timing code already does); DIAG OPX=3 and
  MIA/local-store parity tagging beyond the H-BUS path.

### [2026-08-23] Target: [problems.md]
- 43,311 -> 299,984 of 300,000 matched instructions, ONE phase slip.
  Four defects, found by diffing IOP instruction streams:
  - Ten of the twelve LONG-FORMAT MSC instructions (@LF @LH @STF @STH
    @CI @C @TMI @TM @LBB @LBP) advanced the PC by one halfword too few,
    so every one of them was followed by executing its own operand word
    as an instruction.
  - LOAD MSC BUSY (PCO 92040000) set the STAT4 bit but not the copy the
    MSC reads back with @LMS (bit 17 of its status register, addressed
    BY REGION so a CPU-side PCO does not hit whichever page is being
    sliced).  The MSC read zero and stored a zero status where the
    flight software expects 1.
  - ISPB masked its EA with 0xfffe to drop the low bit -- but that EA is
    already EXPANDED to 19 bits, so the mask threw the SECTOR away and
    protected/unprotected the same offset in sector 0.  GPCIPL
    unprotects a fullword in sector 6 and then writes it, and took a
    store-protect check every time.  (cpu.c's own 0xfffe masks are
    applied to the 16-bit EA before expansion and are correct.)
  - IOP writes to main storage went past store protect entirely, so the
    DMA store protect violation -- External 1 code 0004, Figure 2-20
    priority 51 with the note '##' anomaly -- could never occur.  The
    self test provokes it deliberately.
- Added YAGPC_IOPTRACE: one line per IOP instruction to stderr.  The
  CPU-side --trace says nothing about the MSC/BCEs and every remaining
  divergence has been on that side; diffing this against gpc's own
  --iop-trace is what found all four.
- The single remaining slip is at ya[299970], 15 instructions from the
  end of the compared window, in a memory-scan loop.

### [2026-08-23] Target: [problems.md]
- Added --real-time / --rt-factor / --rt-idle-timeout (src/rtpacer.c),
  mirroring `gpc run`'s own.  This is NOT the same thing as --time-scale
  and the header says why: --time-scale sleeps off a lead a program
  builds by fast-forwarding, and never makes simulated time advance on
  its own.  A machine in the AP-101S wait state needs the opposite --
  there are no instructions to pace, and the thing that ends the wait is
  an interrupt from a timer, the IOP or a peripheral, so the simulated
  clock has to keep moving.  Free-running it (what the wait loop did)
  advances simulated time as fast as the host manages, and a bus receive
  time out is measured in SIMULATED time -- so a reply a millisecond
  away in wall-clock terms arrives to a transaction that timed out
  "hours" ago.  Sharing a speed-up FACTOR is not enough; the clocks have
  to be re-tied often enough to stay inside the protocol's tolerance.
  Under --real-time the wait state converts elapsed WALL time into
  simulated time (capped at 5 ms a lump) and spends it on the timers and
  the IOP's 500 ns slices, via the new cpu_advance_idle_ns().
- Host stalls are re-based, not repaid (STALL_REBASE_MS, and
  rtpacer_resync() on leaving the debugger).  A debugger halt loses the
  peripheral's datagrams outright -- UDP has no retransmission and a full
  socket buffer just drops what arrives next -- so replaying the missing
  wall time as simulated time would only run every outstanding
  transaction past its receive time out: a host pause turned into a storm
  of bus errors.  The transport now also asks for a 1 MiB SO_RCVBUF,
  which absorbs ordinary jitter but cannot absorb a halt, and nothing at
  that layer can.
- --max-steps 0 now means "no limit", as gpc's does; that is how a
  real-time run against live peripherals is started.
- VERIFIED: pacing holds (200,000 instructions = 257.479 ms simulated in
  265 ms wall at factor 1), the 1,490,000-instruction trace comparison
  still matches with no divergence, and no suite moved.
- NOT YET WORKING: yaGPC2 still drives no MMU traffic.  Control run on
  the same live MMU instance: gpc --real-time = 37 commands in 45 s,
  yaGPC2 --real-time --bce-network = 0.  The transmit path itself
  matches gpc's (#CMD/#CMDI -> mia_xmit_cmd -> servicer, gated on
  regXmitEna for the current BCE), and MM1 = BCE 18 -> port 6918 is in
  the transport's table, so the question is whether BCE 18 is ever
  driven -- i.e. whether the divergence is further out than the
  1.5M instructions compared so far.

### [2026-08-23] Target: [problems.md]
- yaGPC2 NOW DRIVES DON'S MMU.  Against a live `MMU.sh run`:
  BITE_STATUS, POSITION_REQ and POSITION (track/subfile decoded), and the
  MMU acts on them ("position -> 4/4/2") -- so the receive path works
  too, not just transmit.
- The bug was in bcenet_framer.c: GPC_SVC_XMIT_CMD recorded the IUA,
  flushed any pending transmit burst and reported ok -- and never sent
  the command word.  Every command the machine generated was dropped on
  the floor.  It goes out as its own two-word message with the 24-bit
  command left-justified across them, as the reference's MIA does.  A
  command also now discards any stale queued RECEIVE words, since a
  command begins a new transaction (the reference's own reasoning: a
  subsystem cannot know how many words the bus program will read, so a
  leftover word is normal and real hardware never captures it).
- Diagnosis path worth recording: an env-gated print in mia_xmit_cmd
  showed 28 commands, all on BCE 18 (the MM bus), with the servicer
  installed -- and cmd=588000 is exactly the raw BITE_STATUS value the
  MMU logs from gpc (5799936).  So the CPU/IOP side was already right
  and only the bridge was at fault.  Confirming the commands were
  correct BEFORE looking at the transport is what made this quick.
- Also fixed: the --real-time paced wait swallowed Ctrl-C.  The pacer's
  two halves (rtpacer_enter_idle/rtpacer_advance_idle) are now exposed
  so run.c owns the poll loop and can check for it.  NOTE the plain
  batchrunner_run path never installs a SIGINT handler at all -- only
  the interactive path does -- so Ctrl-C there still kills the process
  outright without a report.  Separate, pre-existing.
- Under --real-time the instruction stream is NOT reproducible: the
  paced wait spends wall-clock-derived time, so how many simulated
  microseconds a wait consumes varies run to run.  Exact trace
  comparison against gpc is therefore only meaningful WITHOUT
  --real-time, which is also the mode gpc can be compared in at all (it
  refuses to advance through a wait without a pacer and stops at
  3,987,845).

### [2026-08-23] Target: [problems.md]
- WHY WE WENT QUIET AFTER POSITION: a bus RECEIVE instruction does not
  complete in one slice.  The reference holds the BCE at the instruction,
  taking whatever words the MIA has each time round, until the count is
  satisfied or the transfer times out -- #RDS/#RDL/#RDLI/#MIN/#MIN@ only
  advance the PC when bceReceive() returns true.  Ours queued the words
  as DMA and advanced unconditionally, so the bus program ran past a
  reply that had not arrived and every transaction after it was one step
  out of step with the subsystem.  Ported iop_bce_receive() (per-BCE
  state keyed on PC; message time out from local store bank 1 word 3 in
  16.5 us ticks with a 20 ms floor) and iop_bce_error_terminate().
  Surplus words are deliberately NOT flushed on completion -- flushing
  breaks the mass memory path, where a block arrives as one datagram of
  512 halfwords.
- Two transport bugs found on the way:
  - NO SELF-ECHO FILTER.  Multicast loopback is on, so every datagram we
    send comes straight back to our own socket, and for a shuttle bus it
    carries the very IUA byte the receive filter accepts.  We read our
    own transmissions back as replies.  The reference keeps a list of
    sent datagrams and drops the first byte-identical copy; ported, with
    the same 1024 bound and the same consuming match.
  - Data words were BATCHED into one datagram and flushed once a tick.
    The reference sends each as its own one-word message, which is what a
    peripheral parses.  (Inert at the point we were stuck, but wrong.)
- RESULT: yaGPC2 now follows gpc's MMU sequence exactly -- POSITION
  4/4/2, EXTENDED_BLOCK count 16, READ track 4 subfile 3 block 8 count
  15, "read 17 block(s) from 4/4/3/8", "read done, position 4/4/4".
- Regenerated iop_bce_exec_fixtures.h against current gpc; the receive
  rewiring is neutral on it (68734/74699 both before and after), and the
  GPCIPL trace still matches all 3,987,845 instructions with 0 slips.
- Note for future sessions: `pkill -f "mmu.js"` MATCHES ITS OWN SHELL and
  kills the running command.  Use a bracket pattern: pkill -f "[m]mu\.js"

### [2026-08-23] Target: [problems.md]
- MEDS run (MMU + MEDS crt1 idp1 + yaGPC2 --real-time --bce-network):
  THE MENU DOES NOT APPEAR.  The mass memory load starts correctly and
  identically to gpc -- POSITION 4/4/2, EXTENDED_BLOCK count 16, READ
  track 4 subfile 3 block 8 count 15, "read 17 block(s) from 4/4/3/8" --
  and then the block-transfer loop never terminates.
- Evidence, in order:
  - BCE18 floods "unknown instruction" (113k of them), always at PC
    035e8, reading f204/f205/.../f29a where a valid #LBR is f200.
  - Those words are written by the MSC (pe=0) from its @ST X'1A4',X at
    034 3d: it BUILDS BCE18's bus program in memory, an #LBR whose
    operand is the next block's buffer address, advancing 0x200 (512
    halfwords, one block) per iteration.
  - gpc's MSC executes that store 33 times, accumulator f200a000 ->
    f200ee00: the high halfword stays f200 throughout.  Ours executes it
    51,124 times, so the low halfword wraps and carries into the opcode
    field -- f201, f202, ... f29a -- which is no longer a decodable
    instruction, which is what BCE18 then chokes on.
  - So the runaway pointer is a SYMPTOM: our loop does not terminate
    after the first block, and the MSC keeps advancing the buffer.
  - Consequence: BCE6 (DK1, MEDS) never runs a display program at all --
    only its 6-instruction self test.  gpc's BCE6 runs 1210 instructions
    (#MOUT / #LBR / #DLYI / #LTOI / #MIN / #WAT, the display poll loop).
    So MEDS has nothing to show, and no amount of waiting will change
    that until the mass memory load completes.
- NEXT: find what ends gpc's block loop after the first block and does
  not end ours.  The MMU sees exactly one READ from us and the right
  one, so the failure is in what happens AFTER the 512-halfword block
  arrives, not in requesting it.
- Improved the BCE unknown-instruction message to name the processor and
  the PC (it printed only the opcode, to stdout).  An unknown opcode is
  almost always a runaway PC rather than a missing instruction, and the
  address is what tells those apart -- it is what localised this.

### [2026-08-23] Target: [problems.md]
- CORRECTION to the previous entry: the block loop DOES end in ours.  The
  earlier diagnosis ("the loop never terminates after the first block")
  was wrong -- it came from a truncated listing that showed only the
  first 8 of 17 blocks.  Measured properly: 17 datagrams of 1024 bytes
  arrive on bus 18, all 17 512-halfword receives complete, and BCE18's
  instruction stream is IDENTICAL to gpc's, PC for PC, through the whole
  per-block loop (035e6 -> 035f4).  The runaway #LBR operand is a
  downstream symptom, not the fault.
- What actually differs is AFTER the transfer.  gpc issues 3 READs and
  moves the MSC on to 0x3268-0x330a; we issue 1 READ and re-enter the
  block loop without commanding another, so the BCE waits out its
  message time out (which is at the POO maximum, 262143 x 16.5 us =
  4.325 s) once per attempt while the MSC keeps advancing the buffer
  pointer until it overflows into the #LBR opcode field.
- On the "interrupt at the end of the block" idea: there IS a completion
  signal, two of them.  Per block, the BCE sets its INDICATOR bit and
  the MSC polls it with @RAI ("repeat until all indicators", (indicator
  & accMask) == accMask).  For the transfer, the MSC signals the CPU
  with @INT (External 2).  Neither is the differentiator here: @INT at
  0x3483 has I=1 and X=0 in BOTH emulators, so its level is 0 and
  neither raises anything.
- The measurable difference is RATE.  gpc executes 0x3483 33 times, ~6 ms
  apart; ours executes it 76,266 times, continuously.  So our MSC is not
  being held where gpc's is.  Checked and RULED OUT as the cause: the
  MSC's @DLY is a no-op in both; iop_msc_repeat matches gpc's mscRepeat
  line for line; the ACC accessors, @SIO, @N/@X and #LBR all match.
- NEXT: find what paces gpc's MSC loop to ~6 ms per iteration.  It is not
  @DLY and not mscRepeat's own timing, so it is something the loop waits
  ON -- most likely a BCE busy/indicator transition arriving later in
  gpc than in ours, i.e. our BCE finishing its program sooner than it
  should.

### [2026-08-23] Target: [problems.md]
- FOUND IT: @RBI (RESET BCE INDICATOR, MSC) names its processor as the
  instruction's own BCE field PLUS the low five bits of the accumulator
  -- `p = (v.b + (ACC & 0x1f)) & 0x1f` -- the same accumulator-relative
  convention @LBB/@LBP already used correctly here.  We took the field
  alone, so every reset went to BCE 0 (the MSC) and the BCE's own
  indicator, once set by #SIB, was NEVER cleared.
- Consequence: @RAI ("repeat until all indicators", (indicator & accMask)
  == accMask) was satisfied immediately every time, so the MSC never
  waited for a block.  Measured at the branch that proves it -- @RAI at
  0x3445 skips to 0x3447 when met: gpc exits there 33 times and loops
  14,927 times waiting; ours exited 76,266 times and looped 66.  The MSC
  therefore built block programs flat out until the buffer pointer
  overflowed out of the #LBR operand field into its opcode, which is the
  f204/f205/... BCE18 was choking on.
- The per-block pacing that made the rates comparable in the first place
  is #DLYI X'15E' at 035f2 -- 350 x 16.5 us = 5.775 ms, matching gpc's
  ~6 ms per iteration.  Ours honoured it correctly all along (5,506
  executions), which is what made the 76,266-vs-33 gap so conspicuous.
- RESULT: mass memory load now completes and matches gpc command for
  command -- 3 READs, ending exactly as Don's own expected output does:
  "read 8 block(s) from 4/4/4/8", "read done, position 4/4/5".  Zero
  unknown-instruction reports.  BCE6 (DK1, MEDS) now runs its display
  program -- 8,573 instructions, gpc's own 3592/3596/3598/3599/359a/359e
  sequence -- where before it only ran its 6-instruction self test.
- GPCIPL trace still matches all 3,987,845 instructions, 0 phase slips;
  no suite moved.

### [2026-08-23] Target: [problems.md]
- MEDS MILESTONE, CONFIRMED VISUALLY BY THE USER WITH gpc STOPPED:
  yaGPC2 alone drives the MEDS display.  Flashing "GPCIPL
  09.05.00.00.00 LOADED", the header clock counting, and Mode/BSR1
  fields updating.  (An earlier "stuff has appeared" arrived while a gpc
  run happened to be live, so it was NOT evidence for us; the run above
  was made with gpc killed first, specifically to settle that.)
- DK1 bus traffic from us, measured over ~105 s: 707 poll commands, 14
  DISPLAY_FILL, 3 TIME_FILL (func codes per meds/deuProto.coffee:
  0x380 TIME_FILL, 0x38c DISPLAY_FILL, 0x394 FORMAT_FILL, extracted from
  the command word as (w0 >> 1) & 0x3ff).
- BCE6's program loop runs 211 iterations in ~110 s against the
  reference's 189 over the same span -- same order, ours slightly
  faster.
- The header clock is a TIME_FILL message carrying mission time as a
  48-bit IBM extended float in SECONDS (deuProto's ibmFloat48).  The
  "000/00:00:01" first seen was simply the value early in the run; it
  counts up once the load finishes.  Standalone MEDS drives that field
  from wall time instead, which is why it looked different.

### [2026-08-22] Target: [problems.md]
- `#MIN`/`#MIN@` issued their companion bus command on every execution, but a
  waiting receive re-fetches its own instruction each slice, so one transaction
  put its command on the bus thousands of times.  Measured on the display bus
  (DK1) against nsts-sim-gpc: 76,735 polls in 60 s against its 176, which
  starved the DISPLAY_FILL and TIME_FILL traffic behind them.  Guarded with a
  new `iop_bce_receive_starting()` (mirrors gpc's `bceReceiveStarting`, keyed on
  the receive's own PC): polls 76,735 -> 110, TIME_FILL 8 -> 22 (gpc 16),
  DISPLAY_FILL 211 (gpc 360).  GPCIPL trace still matches gpc for all 3,987,845
  instructions with no divergence; all suites unchanged.

### [2026-08-23] Target: [problems.md]
- The bus transport told our own multicast loopback from a peer's traffic by
  matching bytes, as the reference's `Bus` does.  That cannot work on the
  display bus: a DEU answers a poll with ONE halfword (0x0009), while a display
  fill puts 511 halfwords on the bus as 511 separate datagrams, most of them
  0x0000 and one of them 0x0001.  A short reply is byte-identical to words we
  ourselves just sent, and the filter consumed it -- measured, 13 of 78 poll
  replies survived.  `#MIN` at 035a2 then never completed, BCE6
  error-terminated twice per cycle, and the display got one buffer of seven.
- Fixed by attributing on identity, not content: a separate transmit socket
  bound to an ephemeral port, so our own datagrams arrive with a source port
  nothing else on the host uses.  Measured after: 176 of 176 peer datagrams
  kept, 144 of 144 of ours dropped, error-terminations 26 -> 0, and the 16-word
  `#MIN` completes.  The byte-exact list is kept only as a fallback for when
  the transmit socket cannot be created.
- `exec_MOUT` had been given `#MIN`'s new receive-starting guard by mistake;
  the reference guards only `#MIN` (a transmit advances its NIA on the spot and
  has no receive state).  Reverted.
- `YAGPC_BUSTRACE` added: one line per received datagram -- bus, ours/peer's,
  source address:port, leading words.
- STILL OPEN: against a freshly restarted MEDS the DEU answers with its 16-word
  poll response (header 0x0000) and our BCE6 sits in a TIME_FILL+POLL loop,
  never starting the DEU's own IPL fills, so nothing is drawn.  Not yet
  established whether gpc starts those fills from an equally fresh DEU -- that
  comparison was invalidated when gpc turned out to have still been running
  during the first post-fix measurements (`ps -C node` misses it: its process
  name is `node-MainThread`).

### [2026-08-23] Target: [problems.md]
- Display clock runs at half speed.  Measured rather than inferred, and the
  first two suspects are both exonerated:
  * REAL-TIME PACING is fine.  `YAGPC_PACETRACE` (new) reports sim/wall = 0.914
    with zero capped idle advances; nsts-sim-gpc measures 0.923 on the same
    host.  The host is 8% CPU-loaded, not compute-bound.
  * THE INTERVAL TIMER is fine.  `YAGPC_CLKTRACE` (new) shows counter 1 armed
    with 0x9c34 (39.988 ms) firing at 39.989 and 40.003 ms -- an accurate 25 Hz
    tick.
  The defect is the BCE6 display cycle's CADENCE: both emulators send TIME_FILL
  carrying a 0.500 s increment, but gpc sends one every 0.500 s of SIMULATED
  time and we send one every 1.026 s -- 2.05x too slow, which is exactly the
  half-speed clock on the MDU.  Next: find what gates the cycle, MSC dispatch
  of BCE6 being the obvious candidate (our MSC also spins at 032a4, a PC gpc
  never reaches, and falls through at 032a2 `@BC X'4',X'4D'` where gpc
  branches to 032f0).

### [2026-08-23] Target: [problems.md]
- CORRECTION to the MSC lead logged earlier today: it was wrong, and came from a
  trace taken while a stale `gpc` was still on the buses.  In a clean run our
  MSC branches correctly at 032a2 (ACC = 0 in all 147 samples), executes
  032f0..0330a 150 times, and never spins at 032a4 (677,377 spins in the
  contaminated trace, 0 in the clean one).  Its hot PCs match the reference
  almost exactly: 03444/03445 14,865 vs 14,960, 03446/03490/03492 14,832 vs
  14,927.  The MSC is not implicated.
- The live divergence, both emulators against a FRESHLY restarted MEDS:
  gpc's BCE6 cycle is TIME_FILL + POLL + DISPLAY_FILL (196 hw at 0x19ee) + BITE
  every 0.500 s of simulated time; ours is TIME_FILL + POLL only, every 1.026 s.
  Both now succeed at the 16-word poll and reach the `#WAT` at 0359e; the BCE
  is then restarted at 03592 for us and at the display-fill path for gpc.
- Process hygiene: `ps -C node` does NOT find a running gpc -- its process name
  is `node-MainThread`.  Two measurements this session were silently taken with
  a second emulator on the buses because of it.  Enumerate /proc/*/cmdline
  instead, and skip $$ or a pattern matches the checking shell itself.

### [2026-08-23] Target: [problems.md]
- Traced the missing display fills to a single CPU-side value.  BCE6's program
  is chosen by the MSC at 0327c, `@LBP@ X'0',X'354C',X`, which is INDIRECT:
  PC <- memory[0x354C + X].  The table in the IPL image is a list of BCE6 entry
  points -- X=0 -> 03572, 2 -> 03578, 4 -> 03584, 6 -> 035a0, 8 -> 0358a,
  10 -> 03592 -- and 03572/03578/03584 are the display fills.
- X comes from `@XAX` at 03279 fed by `@LH X'3622'` at 03276, so halfword
  0x3622 is the program selector.  In our run it only ever holds 0x0000 or
  0x000a, written by `STH 4,X'3622'` at NIA=0x020cf and cleared by an IOP DMA
  write.  Zero means "nothing to do" (the `@BC X'4',X'7'` at 03278 branches
  past the dispatch), so index 10 (03592, the TIME_FILL+POLL program) is the
  only one we EVER run -- 171 of 171 dispatches.  That is precisely why no
  DISPLAY_FILL is sent and why the cycle is half the reference's length.
  Next: why GPCIPL computes 10 rather than 0/2/4, at NIA=0x020cf (the stored
  value is R4, which the watch line does not print).
- Two dead leads, both recorded so they are not re-walked:
  * `@XAX`/X is NOT wrong.  Our exec_XAX is identical to the reference's, and
    the reference's own trace prints X as `r16(0,3)`, which returns the HIGH 16
    bits -- its `X=0000` is consistent with X actually being 0x0a, same as ours.
  * The dispatch table is static.  Nothing writes 0x354C..0x3556 in either
    emulator; the varying entry points come from the selector, not the table.
- `--watch` verified working before trusting an empty result: 1,727 hits on a
  control location (0x00B0) in the same run that reported none on 0x3556.

### [2026-08-23] Target: [problems.md]
- CORRECTION, twice over, both from unrepresentative samples:
  * "We never send DISPLAY_FILL" was wrong.  Against a fresh MEDS we send 157
    DISPLAY_FILL events in 45 s, 34 of them 509-halfword blocks at 0xf49.  The
    earlier null was sampled before the display program had started.
  * The 0x3622 selector chain is NOT our bug.  gpc's selector takes exactly the
    same two values (0x0000 / 0x000a) from exactly the same instruction
    (`STH 4,X'3622'` at NIA=0x020cf) at nearly the same step, and against a
    shared DEU state gpc's BCE6 loop is instruction-identical to ours
    (03592 -> 03596 -> 03598 -> 03599 -> 0359a -> 0359e -> 03592, poll
    succeeding 176 times).  Index 10 is all gpc dispatches for BCE6 too.
- The DEU's own state dominates these comparisons and must be controlled: a DEU
  that another emulator already IPLed answers a poll with 16 words, one that is
  mid-IPL answers with 1, and the BCE takes a different path in each case.
  Restart MEDS between runs or the comparison is meaningless.
- CLEAN A/B, each against a freshly restarted MEDS, 45 s:
      gpc : TIME_FILL 166  POLL 166  DISPLAY_FILL 166  BITE 83   196 hw @ 0x19ee
      ours: TIME_FILL  82  POLL  82  DISPLAY_FILL 157  BITE  0   509 hw @ 0xf49
  Three real differences remain: our cycle runs at half the reference's rate, we
  fill a different buffer (509 halfwords at 0xf49 vs 196 at 0x19ee), and we
  never send BITE.  Neither emulator sends the 250-halfword LAST_FILL that would
  complete the DEU's own IPL.

### [2026-08-23] Target: [problems.md]
- ROOT CAUSE of the display-bus failures: we OVERFLOW the peer's UDP receive
  buffer.  Measured over the same 45 s window against a freshly restarted MEDS:
      gpc  : 0 datagrams dropped on the DK1 port
      ours : 7,823 dropped
  /proc/net/udp shows the drops on BOTH sockets bound to 6906 (ours ~11k,
  MEDS's ~15k) and ZERO on every other bus port (6918, 6920-6923).
- The mechanism, traced end to end.  Per BCE6 cycle we ISSUE five companion
  commands but only three reach the wire:
      03572 5719ff issued 81, sent 81   03592 570007 issued 79, sent 79
      03578 571808 issued 78, sent  0   0359a 502000 issued 79, sent 79
      035a2 502000 issued 81, sent  0
  `bce_process_mio_command` is called and NOT gated for all five (the
  transmit-enable gate was checked and is innocent), and `sendto` never reports
  an error -- the datagrams are dropped in transit.  MEDS therefore never sees
  the 035a2 poll, so that receive always times out (0 of 83 reach 035a6 where
  the reference reaches it 673 times), and never sees the 571808 fill.
- Why ours overflows and the reference does not: a transmit burst is emitted as
  ONE DATAGRAM PER WORD with nothing between them.  `iop_exec_dma_queue`
  recurses through the whole queue in a single call (dmaBurst, on by default),
  so a 511-word #MOUT fires 511 synchronous sendto()s microseconds apart.  The
  reference's execDMAQueue is structurally identical and also bursts, but its
  fill is 196 words where ours is 511 -- and a default receive buffer holds
  roughly 276 of these tiny datagrams, so its burst fits and ours does not.
  The real MIA bus is ~1 Mbps, ~16 us per halfword, so a 511-word fill should
  occupy ~8 ms rather than microseconds.  Pacing the DMA drain to the bus word
  rate is the faithful fix; it needs care because it also paces the mass-memory
  path (which currently drops nothing).

### [2026-08-23] Target: [problems.md]
- ANSWER to "does gpc transmit only complete buffers?": no.  Its `xmitWord`
  sends `new BusMsg(1)` -- one halfword per datagram, exactly as we did.  It
  escapes the overflow only because its display fill is 196 words and ours is
  511, and a default UDP receive buffer holds roughly 276 of them.
- But the RECEIVERS all take multi-word datagrams: meds/deuUnit.coffee's
  `(@onData(w) for w in words)` and mmu/mmu.coffee's `self._onData(w) for w in
  words` both loop over every word, and both answer with whole multi-word
  messages (a poll reply arrives as one 16-word datagram).  So batching a
  transfer into one datagram is safe, and it is what fixes this.
- Deliberate deviation from the reference, and measured:
      per-word (was) : 7,823 datagrams dropped in 45 s
      paced 20 us/wd : 4,882   (tried first, insufficient, reverted)
      per-transfer   : 0       -- same as the reference
  With it, `#MIN` at 035a2 COMPLETES for the first time (035a2 -> 035a6, 12
  times; it had been 0 of 83), we finally issue `03584 cmd=5718fc` -- the
  250-halfword LAST_FILL that completes the display unit's own IPL, previously
  never sent at all -- and BCE6's transition graph now has the reference's
  exact shape: 035a6 -> 03572 and 035a6 -> 03584, 03584 -> 03588 -> 03589 ->
  03592.
- NEWLY EXPOSED, not a regression of the above but the next problem: about 90 s
  in, after the display unit's IPL completes, BCE6 stops at the `#WAT` at 0359e
  and is never dispatched again; the MSC spins at 032a4 (`@RAW`, waiting on
  busy bits) and DK1 goes silent.  Confirmed NOT a tracing artifact -- it
  happens with all traces off.  The reference keeps driving DK1 indefinitely at
  this stage.  The display therefore goes blank after ~90 s, which is
  user-visibly worse than before even though the bus behavior is now correct.

### [2026-08-23] Target: [problems.md]
- Pacing, corrected understanding (user's point, and it is the right one): the
  unit a receiver loses when overrun is not a datagram but a whole BUFFER --
  everything after its socket fills -- which is exactly why the COMMANDS queued
  behind bulk data were what vanished.  So the interval to honour is between
  complete MESSAGES, each holding the bus for its own length (20 us/halfword,
  so a 511-halfword fill occupies ~10 ms).  Spacing individual datagrams is the
  wrong granularity and measured as such: 7,823 -> 4,882 drops per 45 s, versus
  0 for one-datagram-per-transfer.
- ATTEMPTED and REVERTED: message-granularity pacing in the framer (per-bus
  outbound message FIFO + busFreeAtUs, spaced by wordCount * 20 us).  It made
  things worse, twice over:
  * With the queue drained only from the per-CPU-instruction flush_tick, the
    data messages stopped going out entirely (POLL 166 and BITE 83 appeared,
    matching the reference for the first time, but DISPLAY_FILL and the
    TIME_FILL payload went to zero) -- because during a WAIT, which is where
    the machine spends most of its time, that flush is never reached.
  * Adding a flush to the idle loop silenced every bus.
  Reverted to the committed batching.  The idea is sound; the implementation
  needs the outbound queue drained from wherever simulated time advances,
  without splitting a transfer mid-burst, and that needs designing rather than
  patching.
- THE BLOCKER remains the post-IPL stall, and it is independent of pacing: with
  the committed batching alone, DK1 goes silent after some tens of seconds
  (timing varies run to run), BCE6 parked on the `#WAT` at 0359e and the MSC
  spinning at 032a4.  032a4 is `@RAW`, which per exec_RAW repeats until every
  BCE in its ACC mask is OUT of Busy/Wait.  BCE6 at a #WAT is not busy, so the
  next question is which BCE in that mask is stuck busy.

### [2026-08-23] Target: [problems.md]
- REVERTED the batching commit (11c0e4dda).  It was wrong at the protocol
  level, and the code comment I overrode had been right all along.
  meds/deuUnit.coffee's `recv` reads:
      # ...a command as the 24 command bits left justified in two halfwords,
      # and every data word on its own -- so the DATAGRAM LENGTH tells them apart
      recv: (words) ->
        if words.length >= 2 then @onCommand ... else (@onData(w) for w in words)
  So a datagram of 2 or more halfwords IS a command.  Our batched 7-word time
  fill was parsed as a garbage command and the payload never became data at
  all.  The `(@onData(w) for w in words)` loop I cited as proof that multi-word
  datagrams are accepted is only ever reached with ONE word.
- Caught by running `gpcmd unit --idp 1 --stats-interval 10`, a HEADLESS DEU
  that speaks the same state machine as MEDS and logs what it sees.  It said
  so immediately and unambiguously: 314 commands, 157 polls, `wordsIn: 0`, and
  "transfer abandoned, 7 halfwords short" on every single fill.  Use this
  rather than the Electron GUI for any bus work -- it is the instrument that
  was missing all session.
- So one datagram per halfword is REQUIRED, and the overflow has to be solved
  by pacing after all.  Why the earlier simulated-time pacing only got drops
  from 7,823 to 4,882: it paced in SIMULATED time, but the peer is a real
  process living in WALL time, and `cpu_advance_idle_ns` advances up to
  IDLE_CATCHUP_MAX_NS (5 ms) of simulated time inside a single call with no
  wall time passing at all.  A burst therefore still left the socket in one
  instantaneous rush.  Pacing has to be against the WALL clock.
- The DEU is separable from the display: `DEUUnit` (meds/deuUnit.coffee, plus
  deuProto/deuSPL/deuFCW) is constructed both by meds/idp.coffee inside the GUI
  and standalone by meds/gpcmd.coffee.  The rendering (mdu.coffee,
  mduScreen_*.coffee) is a separate layer.

### [2026-08-23] Target: [problems.md]
- REPRODUCIBLE HARNESS for all bus work, and it should have been used from the
  start:
      node dist/gpcmd.js unit --idp 1 --ipl-request --stats-interval 10
  A headless DEU running the same state machine as MEDS, logging every command
  and a running count of fills / headerless / abandoned / wordsIn.  Note
  `--ipl-request`: without it the unit reports itself ALREADY initialized and
  the GPC never sends display fills at all, so the 511-halfword path -- the
  only one that overflows -- is never exercised.  Drop counts come from
  /proc/net/udp (column 13) for port 6906.
- The overflow, measured DEU-side over 40 s with fills flowing:
      2,948 datagrams dropped
      fills 68 completed, HEADERLESS 75, abandoned 8
  More than half the display fills are ruined, and the failure mode is exactly
  the "whole buffer-load" one: a fill whose leading words are lost fails
  parseFill and is logged "unheadered fill of N halfwords, ignored", while one
  cut off later is "transfer abandoned, 27/77 halfwords short".  A 7-halfword
  time fill always survives; a 511-halfword display fill usually does not.
- The fix must therefore pace per-word datagrams against the WALL clock -- not
  simulated time, and not by batching, which the protocol forbids.

### [2026-08-23] Target: [problems.md]
- WALL-CLOCK PACING implemented in the transport, and it works.  One FIFO per
  bus plus a token bucket: credit accrues at one halfword per 20 us of WALL
  time (the 1 Mbps bus rate), capped at 64 words so a gap between pumps cannot
  bank enough credit to release a whole transfer at once.  Datagrams stay one
  halfword each, as the protocol requires.  Pumped from
  bcenet_framer_flush_tick(), which is now called from the idle loop as well --
  the per-instruction call is never reached during a wait.
- Verified with the headless DEU harness, 100 s each:
                        unpaced   paced
      fills completed        68     122
      headerless             75      33   (the rest are the legitimate 8-word
      abandoned               8       0    trailer fills; gpc sends those too)
      wordsIn            39,454  62,844
  And the number that matters: DROPS ON THE PEER'S SOCKET are now ZERO.  Every
  remaining drop is on OUR receive socket (8,978), discarding our own loopback
  echoes -- harmless, though it is a small standing risk that a DEU reply could
  be lost among them.  Per-socket attribution via /proc/net/udp inode -> owning
  process; do that rather than reading the port total, which conflates the two.
- No regressions: all suites unchanged, GPCIPL matches for all 3,987,845 traced
  instructions, and the mass memory load still completes end to end (POSITION
  4/4/2, EXTENDED_BLOCK, READ 17 blocks from 4/4/3/8, read done 4/4/4).

### [2026-08-23] Target: [problems.md]
- Added a simulated timestamp to YAGPC_IOPTRACE lines, so our IOP trace is
  directly comparable with the reference's (which has always been timestamped).
  That immediately localized the slow display.
- WHERE THE CYCLE TIME GOES.  One BCE6 cycle against MEDS:
      03572 #MOUT       16 us
      03576 #DLYI    10.75 ms   (x650 -- a real programmed delay)
      03577 #WAT        82 us
      035a0/035a1       35 us
      035a2 #MIN      6.2 ms    (the poll receive)
      035a6 #WAT    462-503 ms  <-- the whole cycle
  The reference re-dispatches that same `+35a6 #WAT` in ~116 us.  Ours parks
  for ~480 ms, so our display cycle is ~40x the reference's, which is the
  slow clock the user sees.
- AND THE IOP IS ENTIRELY DORMANT for it: during one 480 ms park the MSC
  executed 171 instructions and the BCEs 2, with all 171 falling inside the
  LAST 347 us.  So nothing is spinning or waiting on a bus -- the IOP simply is
  not being run, then bursts into life for ~350 us and dispatches BCE6.  The
  question is what wakes it, and why that happens roughly twice a second for us
  and continuously for the reference.  This is CPU-side, not transport.
- Note for whoever picks this up: ACC at the 032a2 branch was 0x00009c20 in
  this run (branch NOT taken), where an earlier run had 0x00000000 in all 147
  samples (branch taken).  That branch reads halfword 0x34E6 and its value is
  phase-dependent, so do not treat either reading as the settled answer.

### [2026-08-23] Target: [problems.md]
- CLEAN like-for-like cycle measurement, both emulators against a freshly
  restarted MEDS, gpc's run-length "... N times" lines EXCLUDED from the
  arithmetic (including them is what produced a spurious "gpc also parks for
  480 ms" reading earlier):
      gpc  BCE6 cycle period: median 11,996 us  (n=5, range 11-15 ms)
      ours BCE6 cycle period:        520,000 us
  So our display cycle is ~43x the reference's, and that is the slow clock.
- Where ours goes: the `#WAT` at 035a6 parks 462-503 ms of the 520 ms, and the
  IOP is DORMANT throughout -- 171 MSC instructions and 2 BCE instructions in
  one whole park, with all 171 inside the final 347 us.  Nothing is spinning or
  timing out; the IOP simply is not being run.
- The MSC is restarted by a CPU-side PCO (iop.c, regBusyWait PROC_MSC <- 1),
  and both `@WAT` and the execProcessors busy/halt gating are identical to the
  reference's.  So the question is narrow and CPU-side: what issues that PCO,
  and why ours issues it about twice a second where the reference's issues it
  ~83 times a second.

### [2026-08-23] Target: [problems.md]
- A/B against the SAME headless DEU (gpcmd unit --ipl-request), 105 s each,
  and this is the sharpest statement of the remaining defect yet:
                              gpc      ours
      DEU IPL completes       YES       no      "load complete (250 halfwords
                              (13.4 s)             at 0x2), reporting
                                                   initialized as unit 1"
      unheadered fills          0        37
      DISPLAY_FILL count 8      0        41
      modeStatus replies        5       162
      fills / timeFills    184/169   120/43
- So: the reference finishes initializing the display unit in 13 s by sending a
  final 250-halfword fill at address 0x2.  WE NEVER SEND IT, so the unit stays
  in "IPL in progress" forever (162 one-word mode-status replies against the
  reference's 5) and renders only whatever partial fills landed.  That is the
  "displaying stuff, but not the right stuff" the user sees.
- The error counts the user sees are OURS ALONE: the reference emits zero
  8-halfword DISPLAY_FILLs; we emit 41, and every one lands as "unheadered fill
  of 8 halfwords" (audited 1:1 -- 41 commands, 41 events, all of size 8).  No
  511-halfword fill arrives unusable, so the pacing fix is holding; this is a
  program-path symptom, not a transport one.
- NEXT: why BCE6 almost never reaches 03584, which is where `5718fc` (count
  252 = the 250-halfword LAST_FILL + 2 header words) is issued.  It was seen
  exactly once during the batching experiment, so the path is reachable.

### [2026-08-23] Target: [problems.md]
- THE DISPLAY DEFECT, now traced end to end.  The display unit asks to be
  IPLed (poll header bit HDR.IPL_REQUIRED = 0x0001, set while `not @ipled`),
  and we DO react -- 0x0f49 is DEU.CONTROL_PROGRAM, "where the DEU's own IPL
  load starts", and the unit logs "load started" for us.  But we then re-send
  that FIRST BLOCK forever.  The reference walks the whole image --
  0xf49, 0x1146, 0x1343, 0x1540, 0x173d, 0x193a -- and finishes with the
  250-halfword fill at 0x2, at which point the unit reports itself initialized.
- The block's source address is the BCE's BASE, loaded by the MSC's
  `@LBB@ X'0',X'3526',X` (indirect: BASE <- memory[0x3526 + X]).  The reference
  uses seven different BASEs 0x200 apart (0b302, 0b502, 0b702, 0b902, 0bb02,
  0bd02, 0bf02); ours is 020ee on all 171 dispatches.  Halfword 0x3530 -- the
  slot X=0x0a selects -- is NEVER WRITTEN, so the address is not being advanced
  in place; the walk must come from varying X.
- X comes from `@XAX` at 03279 fed by `@LH X'3622'`, so 0x3622 is the program
  selector, written by the CPU at NIA=0x020cf (`STH 4,X'3622'`, the value in
  R4).  Correction to an earlier entry: it takes MORE than 0x0000/0x000a -- a
  longer sample shows 0x0000, 0x000a, 0x0006 and 0xffff.  But every dispatch
  observed used 0x0a, the steady-state display program, where the IPL blocks
  need 0/2/4.
- SO THE QUESTION IS CPU-SIDE AND SPECIFIC: why does GPCIPL compute selector 10
  at 0x020cf while the unit is still requesting an IPL, instead of stepping
  0/2/4 through the load?  That single value explains the wrong screen
  contents, the 8-halfword fills the reference never sends, and the unit never
  reporting itself initialized.

### [2026-08-23] Target: [problems.md]
- Disassembled the selector's writers, which corrects the model above.  The CPU
  touches halfword 0x3622 in exactly TWO places in the whole image:
      0020cd: LHI  4,X'000a'      <- a LITERAL 10, not a computed value
      0020cf: STH  4,X'3622'
      00210e: SHW  X'3622'        <- sets it to all-ones (the 0xffff observed)
  So "why does the CPU compute 10" was the wrong question: on that path it is
  hard-coded, and no CPU code anywhere writes 0, 2, 4 or 6.
- The walk is MSC-driven.  The MSC writes 0x3622 itself at 032f2, 03358 and
  0336e (all `@STH X'3622'`), and 032f2 sits inside the 032f0..0330a block --
  which is exactly where the MSC lands when the branch at 032a2 IS taken
  (selector == 0, "nothing pending").  We do execute that block.
- So the live question is now: of the values our MSC writes there, we see
  0x0000, 0x0006, 0x000a and 0xffff, but never 0x0002 or 0x0004 -- the indices
  that select the IPL-block programs at 03578 and 03584.  Whatever the MSC
  reduces to those two indices in the reference is what to chase next.
- Useful addresses gathered along the way: 0x3621/0x3623/0x3624/0x3626 are all
  written or read by the same MSC region; 0x361F feeds the `@LH X'361F'` just
  before the dispatch and is loaded from 0x3BA1 by the CPU at 0020d1.

### [2026-08-23] Target: [problems.md]
- DIFFED the MSC's 032f0..0330a block, ours vs the reference, both against an
  identically fresh headless DEU.  THE MSC IS NOT THE DIVERGENCE: identical
  PCs, identical relative frequencies (03303/03304 exactly 3x in each), and the
  same value -- 0 -- written to the selector at 032f2 in both.  Ours runs the
  block 223 times to the reference's 429, which is just our slower cycle.
  Neither emulator executes 03358 or 0336e at all.
- THE DIVERGENCE IS A CPU ROUTINE WE NEVER REACH.  The reference writes the
  selector from NIA=0x02a32 (`STH 4,X'0bec'(0)`) 215 times, and that is what
  queues index 0x18 -- the display-fill program.  Our CPU reaches 0x02a32 ZERO
  times.  Its selector therefore alternates 0x0a <-> 0x18 in equal measure
  (169 each, plus 0x14/0x16/0x22 occasionally); ours only ever sees 0x0a.
- Second difference from the same comparison: we execute `SHW X'3622'` at
  0x0210e 208 times where the reference executes it ONCE.  We keep re-asserting
  "no request" where it asserts once and moves on.  Same region of logic.
- METHOD NOTE, and it cost real time: grepping the disassembly for X'3622'
  found only literal-address references and MISSED the writer that matters,
  because 0x02a32 reaches it base-relative as X'0bec'(0).  Use the reference's
  own `--watch <addr> --watch-log`, which names the writing instruction and its
  NIA, instead of trusting a static search for an address.
- NEXT: what leads to 0x02a32 in the reference and why our CPU never gets
  there.  That is a CPU-side path question, and the tool for it is a traced
  comparison WITH peripherals attached, since both emulators agree for all
  3,987,845 instructions without them.

### [2026-08-23] Target: [problems.md]
- Walked back from the selector write.  The routine is a table walk whose two
  exits both land on the write:
      002a0e: LH   2,@X'0000'(0)+     walk a list, auto-increment
      002a10: BCF  2,X'001f'          exit -> 002a30
      002a2f: BCB  7,X'0022'          loop back to 002a0e
      002a30: LHI  4,X'0018'          queue the display-fill program
      002a32: STH  4,X'0bec'(0)       -> halfword 0x3622
  and it is entered from `0029cc: BC 4,X'2a06'`, a conditional branch taken
  after `0029ca: LH 5,X'0cb8'(0)`.
- Breakpoint tests, ours with --bce-network and MEDS live, 90-100 s each:
      --break 2a0e : never taken (the reference DOES break there)
      --break 29cc : never taken
  So we do not merely take the branch the other way -- we never reach the
  branch at all, and the divergence is further upstream again.
- Landmarks for the next attempt, since walking the call graph backwards by
  hand is slow: the reference writes the selector at 0x02a32 on STEP 4326399,
  and we write it at 0x020cf on step 4302055.  Both emulators print a step
  count in --watch-log output, and both agree exactly for the first 3,987,845
  instructions with no peripherals.  So the divergence is bounded to roughly
  steps 3.99M..4.33M, and a step-indexed comparison over that window will
  localize it far faster than another backwards walk.
- Practical note: the reference cannot --trace to a file that far (it aborts
  building it), and tracing slows it enough that it no longer reaches the
  breakpoint within a couple of minutes.  Use step-indexed breakpoints and
  --watch-log rather than a full trace.

### [2026-08-23] Target: [problems.md]
- FOUND AND FIXED, by step-indexed trace comparison: `@LBP@` and `@LBB@`
  advanced NIA by ONE halfword instead of two.  Both are long-format
  (1111i01Xbbbbb1aaaaaaaaaaaaaaaaaa, 32 bits), and the reference advances by 2
  for all four LBB/LBP forms.  The non-@ forms had already been fixed for
  exactly this reason; these two were missed.
- The consequence was not a lost instruction but an EXECUTED one: the PC landed
  on the instruction's own address word, and 0x354c / 0x3526 both decode as
  `@INT` with a non-zero level, so every BCE dispatch raised TWO spurious IOP
  Program interrupts (External 2) at the CPU.  That is what diverted GPCIPL out
  of its display path.
- HOW IT WAS FOUND, and this is the method to reuse: trace both emulators to a
  fixed step count with peripherals attached (4.4M steps, 458 MB each), extract
  the PC per step, and `cmp` the two sequences.  First difference at step
  4,133,468, on `001dee: LH 1,X'36c8'` -- where the reference sets CC and
  continues, and we swapped PSW (all eight registers reloaded, PSW1
  1dee0011->1ed60011).  A new YAGPC_INTTRACE then named the vector pair
  (0088/008c = iopProg), and the MSC trace showed us executing PC 0327d and
  0327f, which are operand words.
- Verified: operand words no longer executed (0 occurrences of 0327d/0327f),
  all suites unchanged, GPCIPL still matches for all 3,987,845 traced
  instructions.  Against the headless DEU the fix measurably helps --
  fills 120 -> 155, halfwords accepted 62,288 -> 79,392, abandoned 0 -- but the
  unit STILL does not complete its IPL.
- STILL OPEN: a second divergence.  We execute MSC PCs 032d0..032ef (166 times
  each) that the reference NEVER enters, reached via 032dc -> 032e8, and one of
  them (032ee, `@INT` with the I bit set) still raises External 2 202 times.
  Same technique should localize it: the traces are already captured.

### [2026-08-23] Target: [problems.md]
- THE FIXTURE SUITES WERE BLIND, and one 18-bit mask fixed them.  `iop_set_nia`
  did not mask the PC to 0x3ffff (the reference's setNIA masks with
  LS_WORD_MASK).  Read sites mostly masked for themselves, so the machine ran --
  but every MSC fixture compared ls[0][2] (the PC) and saw a full 32-bit value
  where an 18-bit one belonged.  ALL 11,959 MSC failures were that one thing.
  After the fix:
      MSC  133,787/145,746 -> 145,146/145,746   (+11,359)
      BCE   68,734/74,699  ->  74,083/74,699    (+5,349)
  16,708 fixtures unmasked by an eight-character change, and every genuine
  per-instruction discrepancy they had been hiding is now visible.
- What remains, and it is small and specific:
      @LAR   300 -- OURS IS RIGHT, THE REFERENCE IS WRONG.  The POO lists @LAR
                    as SHORT format (II-101, "Load IOP Status Register ...
                    Short"), so NIA advances by 1.  The reference uses
                    incrNIA(2) for @LAR alone and incrNIA(1) for every other
                    short register op (@SFD @LMS @XAX @SEC @RBI @RFD).  The
                    fixtures encode its bug; do NOT "fix" ours to match.
      @INT   300 -- real, unresolved: fixture expects iopProg=0 where we raise
                    it.  Directly related to the 202 spurious External 2s still
                    outstanding.
      #MOUT@/#MIN@ 600 -- the deliberate documented deviation (incrNIA 2 vs the
                    reference's 3), previously verified against BFS.SRC.
      #MOUT 15, #MIN 1 -- not yet examined.
- METHOD CONCLUSION for "should we audit every instruction against the POO":
  we already HAVE an automated differential audit covering every instruction --
  the fixture suites.  It was blinded by one systemic bug, and the failures had
  been triaged as "known" and carried all session.  The lesson is not to hand
  audit 200 instructions but to keep the suite AT ZERO, and to treat the POO as
  the tiebreaker whenever it and the reference disagree -- @LAR is proof the
  fixtures can encode the reference's own bugs.

### [2026-08-23] Target: [problems.md]
- WHO DEFERRED THE FIXTURES: the record says I did.  "MSC fixture suite ~12k on
  what looks like local-store width" is my own log entry, a guess, repeated as
  "unchanged" in every status since.  There is no ruling from the user to
  ignore them; the standing instruction is the opposite.
- @INT RESOLVED -- WRONG ORACLE, not a defect.  The generator read
  `gpc.cpu.intPending.iopProg`, but the reference's PendingInterrupts defines
  properties by spec.key and External 2's key is `ext2`; there is no `iopProg`
  property anywhere in it.  So the read returned undefined and the write
  created a stray own-property that never reached intPendingReg -- every @INT
  fixture recorded "no interrupt" no matter what the reference did.  Generator
  fixed to use `ext2`, fixtures regenerated: exactly 600 lines changed, all in
  the contiguous @INT block, all the trailing iopProgAfter flipping false ->
  true.  MSC 145,146 -> 145,446/145,746.  Our @INT was correct throughout.
- @LAR (300) stands as the reference's bug, not ours -- POO II-101 lists it
  Short format.  Do not "fix" ours to match the fixtures.
- #MOUT/#MIN (16 of 74,699) LOCALIZED, NOT RESOLVED: every one is
  ls[6][13] -- the IUA register (bank 2, word 5) -- reading 0 where the
  reference has 13, after a companion command.  Both implementations gate
  IUAR's write behind regXmitEna identically, and the fixture rows do not make
  the baseline unambiguous, so the next step is to instrument the gate rather
  than reason from the header.
- Suite state now: MSC 145,446/145,746 (300 @LAR, reference's bug);
  BCE 74,083/74,699 (600 #MOUT@/#MIN@ documented deviation + 16 above);
  CPU exec 108,766/111,358 and EA 19,550/20,447 still untouched and NOT yet
  triaged -- the same mistake could be hiding there.

### [2026-08-23] Target: [problems.md]
- TRIAGED the two suites that had never been examined, and neither is "known":
- CPU EA (897 failures, all in g_EA; the separate g_EXPAND and g_EXPAND_DSE
  fixture sets all PASS, so expansion itself is correct):
  * The differences are exact SECTOR multiples -- expected-minus-actual is
    0x18000 (x200), 0x8000 (x155), 0x10000 (x132), 0x38000 (x46), -0x10000
    (x37), plus 32-bit-wrap forms of the same.
  * EVERY failing case has niaIncr=2 and hasI=false, and NO failing case has
    hasI=true.  That is precisely the reference's first branch,
    `if v.niaIncr == 2 and not v.I?` -- RS extended/indexed addressing.  So the
    defect is confined to that path and is data-dependent within it (failures
    and passes share the same opType/ia/ii/hasIdx combinations), which points
    at which sector register gets applied rather than at which branch is taken.
- CPU exec (3,576 FAIL lines): concentrated on RS-format memory instructions --
  LM 207, MR 143, M 141, LH 138, ICR 136, CVFX 136, L 134, LE 130, STM 99 -- and
  the failures are psw1 (1,692) and register-bank values.  One LM case expects
  every register zeroed and we load garbage, i.e. we read from a DIFFERENT
  ADDRESS.  These look downstream of the g_EA defect above rather than
  independent; fix EA first and re-measure before triaging further.
- The CPU exec generator is NOT exposed to the hand-built-decode hazard: it
  calls the reference's real `inst.decode(hw1, hw2)`.  It does carry only
  single-character v fields (FIELD_CHARS), so the reference's multi-character
  ones (dx dy xa ia ii eaFlg xtbs xtc xtcs xts) are dropped -- checked, and all
  of those are read only by disassembly/timing helpers, never by an `e:`
  handler, so the oracle is sound on that point.

### [2026-08-23] Target: [problems.md]
- EA BUG FIXED -- 20,447/20,447, all 897 gone.  TWO causes, both in the RS
  extended/indexed branch of cpu_g_ea:
  1. THE BASE REGISTER'S DSE WAS NEVER APPLIED.  The reference computes
     `dseVal = g_BASE_DSE(v, true)` once at the top of that branch and passes
     it to EVERY g_EXPAND inside it; ours called the non-DSE cpu_g_expand
     throughout, using the DSE only in the SRS branch.  A DSE selects a 32K
     sector, which is exactly why every difference was a multiple of 0x8000.
  2. IC-RELATIVE ADDRESSES WERE NEVER EXPANDED.  The reference forms
     `g_EXPAND(getIC16() +/- pea, OPTYPE_BRCH)` -- the RAW 16-bit IC, with the
     RESULT expanded.  Ours added psw_get_nia(), which is ALREADY expanded
     (BSR applied), and then expanded nothing, so the answer was a sector out
     whenever the IC's own high bit was set.  Added psw_get_ic16() for the raw
     field.
- CPU EXEC re-measured: 108,766 -> 109,553 of 111,358; FAIL lines 3,576 ->
  2,202.  So roughly a third of them WERE downstream of the EA defect, as
  predicted, and the rest are not.
- What is left there, by mnemonic: MR 143, M 139, ICR 136, CVFX 136, LH 134,
  LE 130, L 128, N 96, TB 84, ZB 82, SLDL 80, TSB 76, TH 67, MH 64.  The
  multiply group (MR/M/MH), the bit-test group (TB/ZB/TSB/TH) and the shift
  (SLDL) look like distinct families rather than one cause; triage each on its
  own rather than assuming a shared root.
- No regressions: every other suite unchanged and GPCIPL still matches for all
  3,987,845 traced instructions.

### [2026-08-23] Target: [problems.md]
- The user's instinct was right: there WAS a common thread, and it was
  addressing again.  Two more defects, and CPU exec went 109,553 -> 110,934 of
  111,358 (FAIL lines 2,202 -> 496):
  1. MULTIPLY with an ODD R1 did the wrong operation.  POO 4.21 is explicit:
     "Both multiplier and multiplicand are 32-bit signed twos complement
     fractions.  The product is a 64-bit ... fraction ... When R1 is odd, only
     the most significant 32 bits of the product is saved in general register
     R1."  So it is a FULL 32x32 multiply either way; only the saving differs.
     Ours did a 16x16 q15_mul of the two upper halves -- that is MULTIPLY
     HALFWORD (4.22), a different instruction.  Affected MR and M.  MR 143 -> 0.
  2. SRS ADDRESSING EXCLUDED BASE REGISTER 3 FROM ITS DSE.  "When B2 equals 11,
     base addressing is not performed" is an RS-format rule; in SRS, register 3
     is an ordinary base register and its DSE applies like any other's.  The
     reference passes g_BASE_DSE(v, FALSE) there -- no exclusion -- and ours
     excluded b==3.  Every SRS reference through R3 landed a sector out.  This
     alone was +1,209 fixtures and cleared M, MH, LH, LE, L, N, TB, ZB, TSB,
     TH, ME, NIST, S, D, SH, AE, SE, TD, MSTH, AH, C, CIST, A, CH outright.
- WHAT REMAINS, 496 FAIL lines over 7 mnemonics and no longer addressing:
      ICR 136, CVFX 136, SLDL 80, SRDR 52, BCTR 35, SRDL 33, SRDA 24
  The four shifts (SLDL/SRDR/SRDL/SRDA, 189) are one family and should be
  triaged together; ICR and CVFX are their own.
- No regressions: EA still 20,447/20,447, every other suite unchanged, GPCIPL
  still matches for all 3,987,845 traced instructions.

### [2026-08-23] Target: [problems.md]
- SHIFT FAMILY TRIAGED AND FIXED, all 189 in one defect.  The four double
  shifts took their partner register as plain R1+1; the POO says
  (R1+1) MOD 8 -- 6.6 verbatim: "the pair of general registers (R1 and
  (R1+1)mod8) are shifted right as a 64-bit register ... entered into bit
  position 0 of general register (R1 + 1)mod8".  With R1 = 7 we addressed a
  ninth register the machine does not have, so the partner's half of the shift
  went nowhere and register 0 -- its real partner -- was left untouched.  Every
  failing case showed reg[1][0] still holding its baseline 106917440.
  SLDL 80, SRDR 52, SRDL 33, SRDA 24 -> all zero.  CPU exec 110,934 ->
  111,051/111,358.
- REMAINING: 307 FAIL lines over three mnemonics -- ICR 136, CVFX 136,
  BCTR 35.  None of them addressing, and BCTR is small enough to be worth
  checking for the same mod-8 pair issue first.
- No regressions: EA 20,447/20,447, every other suite unchanged, GPCIPL still
  matches for all 3,987,845 traced instructions.

### [2026-08-23] Target: [problems.md]
- BCTR was NOT the mod-8 pair issue -- it was EVALUATION ORDER, and the failing
  opcodes said so: d4e4, d3e3, d5e5, d1e1 all have x == y, i.e. R1 and R2 are
  the SAME register.  POO: "First, the branch address is computed. ... Then,
  the contents of bits 0 through 15 of general register R1 are reduced by one."
  We read R2 after the decrement and so branched one short.  35 -> 0, and the
  reference already had this right.
- BCT has the SAME defect and the reference SHARES it, so the fixtures assert
  the wrong order.  Fixed ours to the POO anyway -- the @LAR call again -- at a
  cost of 30 of its 300 fixtures now failing against a wrong oracle.  38 of the
  300 have R1 == B2, which is when the order is observable.
  VERIFIED SAFE: GPCIPL still matches for all 3,987,845 traced instructions, so
  no flight code in the corpus depends on the reference's order.
- BCTB checked and is correct as it stands: its address comes from the
  instruction counter and displacement, never from R1, so the order cannot be
  observed there.
- CPU exec now 111,056/111,358.  Remaining: ICR 136, CVFX 136, and the 30
  deliberate BCT.  Neither ICR nor CVFX has been looked at yet.

### [2026-08-23] Target: [problems.md]
- ICR (136) FIXED: the interval counters came up ZERO where the reference brings
  them up ALL ONES (it sets 0xffff at construction and at both resets).  Decoded
  straight out of the failure: ours gave hi=0xc733 lo=0x0000 (+2 = 0xc7330002),
  the reference hi=0xc733 lo=0xffff (+2 = 0xc7340001) -- the constant 0xFFFF
  difference every failing case showed.  With zero, the very next tick borrowed
  from PSA 00B0/00B1 immediately, so a Read Counter before the first Write
  Counter came back a full count out.  The POO does not state the reset value;
  this follows the reference, and it is also the only way these fixtures CAN
  agree, because the fixture baseline carries regs/dse/mem/psw but NOT the
  counters.  136 -> 0, CPU exec 111,056 -> 111,192/111,358.
- CVFX (136) IS NOT A BUG and needs no change -- already investigated and
  resolved, issue `cvfx_convert_overflow_fixture_cc_stale` (2026-08-01,
  next_action_owner=none): the fixtures assert the PRE-fix reference behavior
  (CC left stale on CONVERT_OVERFLOW, because its fp_dispatch_exc returns false
  and exec_CVFX bails before writing CC), while ours was corrected by issue #9
  to always compute and set CC.  Regenerating would re-encode the reference's
  bug, so they stay failing deliberately -- the same call as @LAR and BCT.
- SO THE CPU SUITE IS NOW FULLY ACCOUNTED FOR.  Of 111,358 fixtures, 111,192
  pass and every one of the remaining 166 is a KNOWN-WRONG ORACLE, not a defect:
  136 CVFX (stale) + 30 BCT (reference's evaluation order).  Nothing left there
  is unexplained.

### [2026-08-23] Target: [problems.md]
- BCE SUITE TRIAGED, now 74,099/74,699 and fully accounted for.
- The 16 #MOUT/#MIN failures FIXED: `bce_process_mio_command` fetched the
  companion command from an UNMASKED PC.  The reference uses
  (PC + 2) & LS_WORD_MASK.  The PC is an 18-bit register, and the fixture
  baseline loads ls[6][2] = 0xbb440f7a, whose low 18 bits are 3962 -- exactly
  the pre-execution PC the fixture expects.  Unmasked, our fetch address was
  3,141,799,804, far outside main storage, so it read zero and the IUA register
  stayed 0 where the reference had 13.  All 16 pass now.
  (At runtime this could not bite since iop_set_nia masks on write, but the
  mask is correct on its own terms and matches the reference.)
- The remaining 600 (#MOUT@ 300, #MIN@ 300) are THE REFERENCE'S BUG, and this
  is now PRIMARY-SOURCE PROVEN rather than inferred.  The original IBM build's
  own assembly listing, PFS/BFS.rpts/ASMLIB-BOS.rpts:
      013A8  F900 1AF2   #MIN@  DKDISP-12
      013AA  0800        #WAT  0
      013B2  FD00 1B78   #MOUT@ DEUDISP2-12
      013B4  C002        #DLYI 2
  Both occupy exactly TWO halfwords.  Our incrNIA(2) is right; the reference's
  incrNIA(3) is wrong.  Structural corroboration from ASM101S/model101tables.py:
  #MINC/#MOUTC "are not instructions at all but the parameter word that follows
  a #MIN or #MOUT" -- the non-@ forms are 2 + 2 = 4 halfwords (our incrNIA(4)),
  while the @ forms take an ADDRESS operand and carry no such word.
- SO EVERY SUITE IS NOW FULLY ACCOUNTED FOR.  Nothing anywhere is unexplained:
      EA        20,447/20,447
      CPU exec 111,192/111,358   166 = 136 CVFX stale + 30 BCT (reference)
      MSC     145,446/145,746   300 = @LAR (reference)
      BCE      74,099/74,699    600 = #MOUT@/#MIN@ (reference)
  All 1,066 remaining failures are a known-wrong oracle; none is a defect.
- WORTH FILING: #MOUT@/#MIN@ incrNIA is a fourth nsts-sim-gpc issue, and the
  strongest-evidenced of the lot -- it has the original build's listing behind
  it.  Not yet filed; needs the user's review of the text first.

### [2026-08-23] Target: problems.md
- gpc POO fixes verified not to disturb MEDS.  `~/donschmidt/nsts-sim-gpc`
  branch `yagpc2-local-poo-fixes` = e12ac63 + cd1c945 (@LAR incrNIA 2->1,
  BCT branch-before-decrement, CVFX store-on-overflow, #MOUT@/#MIN@
  incrNIA 3->2).  Fresh-MEDS A/B: stock gave 137/1/3 then 132/1/2; patched
  gave 132/1/2 -- stock varied more between its own runs than patched
  varied from stock.  Clock normal, y/k/I keys live, DK1 identical at
  2299 datagrams / 2497 words per 6 s.
- UPSTREAM REGRESSION: nsts-sim-gpc main (0e275b1, "take store protection
  from the linker's map") does not boot GPCIPL at all -- zero bus traffic,
  ~46% CPU spin, no DEU IPL.  Bisected against unpatched builds: e12ac63
  IPLs the DEU at 20.1 s (492 commands / 169 fills), 0e275b1 never does.
  IPL.fcm has no .sym.json, which should take the `protectWarning`
  "running unprotected" branch.  Not yet filed with Don.

### [2026-08-23] Target: problems.md
- The 032d0-032ef MSC divergence is a SYMPTOM, not a cause.  Chain, each
  step measured against gpc under an identical headless-DEU run:
  032d0 is entered from @RAW's timeout exit at 032a5 (032a6 is its
  condition-met exit; both are legitimate, it is not a length bug)
  <- halfword 34E6, written at 0331a
  <- halfword 3B7A = the DEU's reply word, 1 for us and 0 for gpc
  <- 0x0001 is HDR.IPL_REQUIRED: the display never finishes its IPL.
- The display is handed the same block forever: 259 x "fill 509 hw at
  0xf49 (0 non-zero)", where gpc walks 0x1146, 0x1343, 0x1540, 0x173d,
  0x193a and reports load complete.
- BCE6's BASE is frozen at 0b302; gpc's walks 0b302, 0b502, 0b702,
  0b902.  BASE is a fullword from a table @LBB@ indexes by X: X=0 is
  03526 (fill buffer), X=6 is 0352c (receive), X=0xa is 03530 (normal
  operation).  Slot contents are CONSTANT -- watchpoints prove neither
  emulator ever writes 03526 -- so a block advances by advancing X.
  Block index at 03279: gpc 0x0a 207, 0x18 206, 0x00 6, 0x06 6, plus
  0x04/0x14/0x16/0x22; ours 0x00 259 and 0x06 259 and nothing else.
- Ruled OUT by measurement, not assumed: the CPU is not diverging (the
  2^18 memory sweep at 077c-0795 is identical, 4.94M vs 4.77M
  instructions and 301,465 interrupt excursions each), and the receive
  path is correct (the wire shows the DEU really does reply 0001).
- Open: gpc pushes 6 IPL blocks per MSC wake, we push one and park.  The
  CPU's LOAD MSC BUSY arrives at a median 480 ms, which matches the 45 s
  of a 54 s run that BCE6's #WAT at 035a6 accounts for.
- Pre-existing, NOT mine: make test fails four debugger golden cases
  (halmat, multiunit, srcmap, wrap) on SCAL operand formatting --
  X'014a'(1,) in the golden vs @@X'014a'(1) produced.  Same four with
  my changes stashed.

### [2026-08-23] Target: problems.md
- ROOT CAUSE of the display IPL, one level below the 034DE counter: the
  MSC's search loop at 03392-0339c walks an IPL block-pointer table and
  stops on the first live entry.  The fullword it tests at 0339a holds,
  in the reference, all seven blocks -- 0b302 0b502 0b702 0b902 0bb02
  0bd02 0bf02 -- and here it holds ONLY 0b302, with every other slot
  zero (ours: 2590 zeros and 259 x 0b302; reference: 10 zeros and one
  each of the seven).  So the search returns block 0 every time, 034DE
  never reaches 4, the reset block at 0331c-0332e re-runs and rezeroes
  it, and the display is re-sent block 0 forever.  A data-construction
  problem, not control flow: both sides run the marking store at 033a9
  the same way.
- NOT yet located: who builds that table.  @L X'168',X is short format,
  so the displacement is relative to the MSC's own base, NOT absolute
  0x168 -- a watchpoint on 0x168 therefore proves nothing and the one I
  ran is void.  The long-format @LBB@ literals (03526) ARE absolute;
  do not mix the two up when placing the next watchpoint.

### [2026-08-23] Target: problems.md
- CORRECTION to the previous entry: the IPL block table is NOT short of
  entries.  It is built correctly here -- a watchpoint at the properly
  resolved address catches all seven going in from one CPU store loop at
  NIA 01f74: 03519<-b302 0351b<-b502 0351d<-b702 0351f<-b902 03521<-bb02
  03523<-bd02 03525<-bf02.  What differs is the SCAN CURSOR at 034E3,
  which the search at 03392-0339c advances and the reset block at 0332a
  zeroes.  The @L X'168',X that reads the table is PC-relative, not
  base-relative: ea = (PC+1) + disp + X = 0339a + 168 + X = 03502 + X.
- ROOT CAUSE: a block takes 500 ms here against the reference's 12 ms.
  The reference's whole seven-block IPL (84 ms) fits between two reads
  of the DEU status word, so its reset runs once and its cursor
  survives; ours does not, so the reset runs between every block,
  rezeroes 034E3, and the search returns block 0 forever.  Everything
  downstream -- 034DE never reaching 4, 34E6, @RAW's timeout, 032d0 --
  is correct behaviour responding to that.
- The DEU is behaving correctly and identically for both: deuUnit.coffee
  sets @ipled only on a fill whose count == LAST_FILL_WORDS (250), so
  IPL_REQUIRED stays asserted until the final short block, which we
  never send.  Its 0001 replies are honest.
- NOT the cause, each measured: the CPU wakes the MSC at the SAME rate
  on both sides (the LOAD MSC BUSY site 03259 runs 77 times here and 66
  there over 35 s), the receive timeout floors are both 20 ms, and the
  PCO site sets are identical but for one entry below.
- NEW LEAD: 01eff issues RESET STATUS1 (0x92000000) with data 02000000,
  the BCE6 bit, four times here and NEVER in the reference -- BCE6's
  NO-GO recovery path, entered off a status compare against 0x5000 at
  01ee9 that never matches there.  Something drives our BCE6 to a
  program exception; iop_bce_error_terminate is the obvious suspect
  since it is what sets ProgExcept to 0.

### [2026-08-23] Target: problems.md
- CORRECTION: the MSC does NOT resume at 0330c after its @WAT here.  It
  resumes at 03266, 295 times out of 296, exactly as the reference does
  458 of 459.  The earlier reading came from grep -A1 over a MIXED
  MSC/BCE trace compared against an MSC-ONLY one, so "the next line"
  meant different things on the two sides.  Filter to MSC lines before
  taking any successor or predecessor count.  The CPU's aiming write
  lands 96 times against 108 wakes; that mechanism is fine.
- The block loop 03356 -> 033b4 -> 03356 has NO park in it on either
  side; each @CALL X'2',X'3262' spans one, dispatch -> @WAT -> the CPU
  re-aims the MSC to 03266 -> 03316 @BU@ X'3262' returns.  So the block
  rate IS the MSC wake rate.
- THE NUMBER: MSC park intervals.  The reference runs a clean 40.0 ms
  cadence, which is the display's own poll rate (deuUnit's comment says
  a queued message "waits for the next poll 40 ms later"); min 1.9,
  median 205.7, max 446.4.  Ours alternates 480/520 ms with no 40 ms
  tick at all; min 20.4, median 480.1, max 520.1.  480/40 = 12 exactly.
- Our interrupt profile over one run: clk1 847 (about 28/s, so the
  timer tick itself is roughly right), clk2 316, External 2 / iopProg
  94, External 1 16, External 0 7.  The 94 matches our 108 MSC wakes,
  so MSC service here is paced by External 2 at about 3/s rather than
  by the 40 ms tick.  That is the gap to close.
- The LOAD MSC BUSY site 03259 runs 77 times here and 66 there over the
  same 35 s, so the CPU is NOT issuing the wake less often; the
  reference must get its MSC moving 40 ms at a time some other way.
  Unresolved, and the next thing to chase.

### [2026-08-23] Target: problems.md
- CORRECTION to the "40 ms there, 480 ms here" entry: the MSC park
  cadence is IDENTICAL for the first 37 parks -- 39.9 39.9 40.0 39.8
  39.9 39.9 119.9 239.9 20.4 ... matching to a tenth of a millisecond,
  and park 37 lands on 7190151.0 us on both.  It COLLAPSES at park 38,
  where the reference dwells 1.8 ms and we dwell 503.6, and from there
  we alternate 463/503 for ever.  The steady-state medians (205 vs 463)
  hid this; look at the ordered sequence, not the distribution.
- WHAT HAPPENS AT PARK 38: BCE6 is at 0359a executing the SIXTEEN word
  #MIN and only one word ever arrives, so it sits out its whole 20 ms
  timeout, error terminates, and goes NO-GO, while the MSC spins in
  @RAW at 032a4 waiting for a BCE6 that will never reach WAIT.  That is
  the left=15 gotAny=1 timeout, and it is not a side issue -- it is what
  breaks the cadence.
- WHY ONE WORD: deuUnit.coffee's POLL handler replies with a single
  header word, not the sixteen word poll response, while @iplRunning is
  set.  The reference is only briefly in that state (its load completes
  about 56 ms after it starts, modeStatus 5); we are in it permanently
  (modeStatus 259), so every sixteen word #MIN we issue starves.
- STILL OPEN, and the one thing left: our display fills are 540 ms apart
  from the very FIRST one (19.761, 20.335, 20.872) where the reference's
  are 11 ms (20.301, 20.312, 20.324) -- even while the park cadence
  still matched.  The reference sends several fills per park; we send
  one per thirteen.  Fill rate is NOT park rate, and that is what to
  measure next.
- METHOD NOTE: a plain cmp of the two MSC streams reports its first
  difference at instruction 14, @RAI X'64' at 014b9, where we test 18
  times and the reference once.  Both then go to 014bb.  That is a phase
  difference, not a defect -- our BCEs set their indicator bits a few
  slices later.  Use cmp4.py, which resynchronises, rather than cmp.

### [2026-08-23] Target: problems.md
- The display IPL fails on a 1.28 ms miss.  In the gap between fill 1 and
  fill 2 the MSC's @RAW at 032a4 spins 8705 times and gives up at
  7246388.3 us; BCE6 does not reach WAIT (035a6) until 7247667.4.  So the
  @RAW takes its TIMEOUT exit at 032a5 into the mode-status block instead
  of its condition-met exit at 032a6, and everything follows.  The two
  emulators issue their FIRST fill 8 us apart (7230356.0 vs 7230348.0)
  and diverge immediately after it.
- Where the 1.28 ms comes from: our one-word #MIN at 035a2 takes 6.44 ms
  (7241229.5 -> 7247667.4) where the reference's takes 0.38 ms.  Our
  #DLYI is right (10.76 ms against its 650 x 16.5 us = 10.73), so the
  receive is the whole difference.
- NEGATIVE RESULT, so nobody repeats it: outbound pacing is NOT the
  cause.  YAGPC_BUS_WORD_US now makes the rate sweepable; at 20/8/4/2 us
  per word the load never completes, and the faster settings make
  unheadered fills worse.  The reference's com/bus.civet sendMsg does no
  pacing at all, which is what suggested the theory.  The remaining
  suspect is when we DRAIN the socket, not when we fill it.
- METHOD NOTE, second time this has bitten: the reference's IOP trace
  COLLAPSES repeats into "... N times" summary lines, so a grep that
  counts full trace lines undercounts it wildly and makes it look like it
  executes a delay once where we execute it 652 times.  Compare
  TIMESTAMPS, not line counts.

### [2026-08-23] Target: problems.md
- CONFIRMED MECHANISM for the 6.4 ms receive: the transport keeps ONE
  in-order FIFO per bus, so the poll command that asks the display to
  answer cannot overtake the fill ahead of it.  37 of 56 commands queue
  behind 257 datagrams; at 20 us a word that is 5.1 ms, which with the
  display's own turnaround is the 6.4 ms, which is the 1.28 ms by which
  the MSC's @RAW misses BCE6 reaching WAIT.
- THREE HYPOTHESES DISPROVEN, all by measurement, so nobody retries them:
  (1) the word rate -- swept 20/8/4/2 us, the load never completes at any
      of them and the fast settings make unheadered fills worse;
  (2) the burst cap -- 64/128/256 give 5/24/22 unheadered fills, so the
      default 64 is the best of them and raising it hurts.  The peer
      absorbs about 64 datagrams back to back but not 128;
  (3) the pump call rate -- about 15,000 a second, mean gap 0.066 ms,
      far above the 1.3 ms a 511-word fill needs.
- OPEN, and the sharpest lead: those numbers do not reconcile.  At that
  call rate the token bucket should sustain 50k words/s and clear 511
  words in 10.2 ms, but 257 are still queued 10.7 ms in -- an actual
  drain of about 24k words/s, half the configured rate.  The 15k/s is a
  two-second average; the suspicion is that the pump is NOT reached
  while the CPU is inside a long non-idle stretch, which is precisely
  when a fill is in flight.  Measure the drain rate WITHIN a fill
  window, not averaged over seconds.

### [2026-08-23] Target: problems.md
- THE CEILING, measured at last.  Per-fill drain rate is bimodal: a few
  clear 513 datagrams in 10.6 ms (48k words/s, inside the 10.7 ms the
  display's bus program allows) but most take 17-19 ms (27-30k words/s).
  The cause is the cost of the sends themselves -- 8.5 to 9.0 us each,
  against a 20 us word time.  511 synchronous multicast sends cannot
  clear in 10.7 ms while the same thread is also emulating in real time;
  that would need about 45% of a core on sendto alone.
- Ruled out as the cause of that cost: the self-echo bookkeeping is
  already skipped whenever the transmit socket exists (txFd >= 0), and
  multicast loopback CANNOT be turned off -- the peer is on this host and
  loopback is how it receives anything at all.  The datagram count cannot
  be reduced either: deuUnit's recv treats any datagram of two or more
  halfwords as a COMMAND, so payload really is one word per datagram.
- FIXED ANYWAY, because it was a real defect even though it was not the
  binding one: the token bucket used one constant for both the per-call
  release and the banked credit, so any pump gap past 64 words x 20 us =
  1.28 ms threw the rest away, and gaps reach 3.9 ms.  313 to 1864 words
  of credit were being dropped every two seconds.  Banked credit now has
  its own cap.  Drain rate did NOT improve, which is the evidence that
  the send cost is the real ceiling.
- DIRECTION for whoever picks this up: the sends need to come off the
  emulation thread.  The reference gets this free from node's async
  dgram -- its event loop interleaves sends with everything else, which
  is also why it needs no pacing at all.  A dedicated transmit thread
  draining the existing FIFO is the equivalent, and the FIFO and pacing
  built here are already the right shape for it.

### [2026-08-23] Target: problems.md
- Removed the malloc/free pair every bus datagram was paying in
  transport_send_now; it now builds the six bytes on the frame.  Send
  cost 8.5-9.0 us -> 8.2-8.3, and several fills now clear at 37-54k
  words/s where all of them used to sit at 27-30k.  The display still
  does not finish its load, so this is an improvement and not a fix: the
  remaining ~8 us is the multicast sendto itself.
- Considered and NOT done, with the reasoning, so it is not re-derived:
  sendmmsg would batch the syscall entry but not the kernel's per-
  datagram multicast loopback delivery, which is where most of the 8 us
  goes, so it buys a fraction of one microsecond of the twenty available
  and does not change the verdict.  Disabling IP_MULTICAST_LOOP is not
  available at all -- the peer is on this host and loopback is how it
  receives.
- NEW OBSERVATION, unchased: the display now logs "unheadered fill of 8
  halfwords, ignored" ten to eighteen times a run.  An eight-halfword
  fragment of a transfer arriving on its own looks like datagram loss
  splitting a fill, which is worth its own look -- the count rose as the
  drain got faster, which fits.

### [2026-08-23] Target: problems.md
- The 0e275b1 regression is pinned to an exact instruction.  Both builds
  are deterministic without the network, so their --trace output diffs
  directly: they agree for 20,461 instructions and part company at step
  20462, on the instruction right after GPCIPL's SSM X'006c' at 061b
  unmasks interrupts.  e12ac63 executes the LHI; 0e275b1 reloads the
  whole register file and swaps PSW1 to 0a26, which is an interrupt
  taken through vector 0074 -- cpu_intr.coffee's instrMonitor, "CPU
  Breakpoint (Instruction Monitor)".  GPCIPL never returns from it.
- Mechanism, as a hypothesis and labelled as one: IPL.fcm has no
  .sym.json and cannot be relinked to get one, so the commit's mapless
  fallback protects NOTHING where applyLoadProtection used to protect
  every loaded section.  A store that used to be dropped now lands and
  arms the monitor.
- Issue text drafted at scratchpad/issue-storeprotect.md and shown to
  the user; NOT filed, per the review-before-publishing rule.
- Don's repo left on branch yagpc2-local-poo-fixes at cd1c945, clean,
  dist rebuilt.  origin/main is still 0e275b1; the two commits after our
  branch point are meds fixes (#15, and a meds #27 unrelated to ours).

### [2026-08-24] Target: problems.md
- CORRECTION, user-flagged: I wrote that IPL.fcm "has no .sym.json and
  cannot be relinked".  Both files are in ~/Desktop/IPL/ -- IPL.fcm 1.0M
  and IPL.sym.json 674K -- and gpc loads the sym.json fine, resolving
  GPCIPL +offset symbols from it throughout.  I asserted an absence
  without running ls.
- The accurate reading: IPL.sym.json HAS no `storeProtect` KEY.  Its
  top-level keys are version, imageSize, entryPoint, sections, symbols,
  modules, relocations, unresolvedRelocations, repro, ownerPhaseRunsHW.
  Its repro block says it was built 2026-08-19 by mmu2fcm (config IPL,
  phase 10) with lnk101, both at 6e0a232(2026-08-19) (dirty).  So gpc's
  warning is literally accurate and its advice is the fix.
- BUT the relink is not available: no lnk101 anywhere here emits
  storeProtect, and nsts-sdl-dps has NO commit mentioning store
  protection in its whole history.  So this is cross-repo version skew,
  not a gpc bug -- gpc main landed a dependency on a linker field that
  the linker does not yet write.  The issue draft is rewritten as a
  question to Don about which revision writes it, keeping the measured
  bisect and trace.  Still NOT filed.
- nsts-sdl-dps was inspected READ-ONLY and not touched.  It is on branch
  con80build-pch-extension-v2 at 1350a86 with one dirty file, i.e. mid
  work by another instance; leave it alone.
- The step-20462 instruction-monitor finding is unaffected and stands.

### [2026-08-24] Target: problems.md
- RESOLVED, and there is NO gpc bug: 0e275b1 boots GPCIPL perfectly well
  once the .sym.json carries a store-protect map.  Proved without a
  relink -- copied IPL.fcm and IPL.sym.json to scratch, synthesised
  storeProtect {unit: halfword, ranges: every section} into the copy, and
  ran 0e275b1 against it: no warning, "load complete (250 halfwords at
  0x2), reporting initialized as unit 1", 256 commands / 93 fills /
  78 timeFills / 0 headerless / modeStatus 5.  Do not file an issue.
- The real fault was ours: IPL.sym.json is STALE, built 2026-08-19 before
  lnk101 emitted the map.  Upstream (ColanderCombo/nsts-sdl-dps, the
  parent of our rburkey2005 fork) src/lnk101/linker.py has
  storeProtectRangesHw() at line 809 and writes
  "storeProtect": {"unit": "halfword", "ranges": ...} at 2842, exactly
  the shape gpc reads.  ACTION: regenerate IPL.sym.json with the current
  lnk101 via mmu2fcm (config IPL, phase 10) and gpc main works.
- Why the earlier searches missed it: our nsts-sdl-dps clone has NO
  upstream remote at all -- only `fork` -> rburkey2005/nsts-sdl-dps -- so
  there is no origin/main and a working-tree grep finds nothing.  Read
  upstream files with `gh api repos/ColanderCombo/nsts-sdl-dps/contents/
  <path> -H "Accept: application/vnd.github.raw"` rather than adding a
  remote to that checkout, which belongs to another instance.
- MUTUAL CONFIRMATION: yaGPC2's own apply_load_protection() comment in
  ageharness.c already describes this exact failure -- "protect nothing
  and the Instruction Monitor fires the moment the software sets PSW mask
  bit 34".  yaGPC2 is NOT running unprotected; it protects the loaded
  sections from the section map.
- NEW LEAD from all this: yaGPC2 protects whole SECTIONS, which is what
  gpc did before 0e275b1 and what Don removed because it "locks the
  runtime's own IOCODE/IOBUF cells and the stack" so stores are dropped
  silently.  If yaGPC2 is over-protecting the same way, stores that
  should land are being dropped -- worth checking against the display
  path once IPL.sym.json carries the real ranges.

### [2026-08-24] Target: problems.md
- REGENERATING IPL.sym.json WOULD NOT HELP, and this is the real bug:
  mmu2fcm's unionSym() (src/tools/mmu2fcm.py ~line 632) builds the
  composed sym.json from an EXPLICIT key list -- version, imageSize,
  entryPoint, sections, symbols, modules, relocations,
  unresolvedRelocations, repro -- and never merges storeProtect from the
  constituent phases.  lnk101 writes the map into each PHASEnn.sym.json
  (linker.py:2842) and mmu2fcm then drops it.  So gpc 0e275b1's advice,
  "relink to regenerate .sym.json", holds for a plain lnk101 output but
  NOT for an mmu2fcm-composed image like IPL, which is what we have.
  The fix belongs in unionSym: union the phases' storeProtect ranges,
  offset by each phase's placement delta, same as it already does for
  sections and symbols.
- Nor can the regeneration be run here at all: nsts-sdl-dps build/mmu is
  EMPTY (no PHASEnn.lib, no PHASEnn/PHASEnn.sym.json), and there is no
  CON80 deck directory anywhere under ~ within 4 levels.  mmu2fcm needs
  both (--mmu and --con80), so the whole con80build -> asm101 -> lnk101
  -> mmu chain would have to run first.  No fcm diff is therefore
  possible either -- nothing was regenerated to diff against.
- Current upstream was cloned READ-ONLY into scratch/dps at d8e01ed to
  establish the above; the user's own checkout was not switched or built.
- Interim that DOES work, already proven: a synthesised whole-section
  storeProtect map added to a COPY of the sym.json boots gpc 0e275b1
  fully.  That is the same policy as gpc's pre-0e275b1
  applyLoadProtection and as yaGPC2's own apply_load_protection, so it
  is a defensible stopgap -- but it is not what the linker would emit,
  which is the point of the real map.

### [2026-08-24] Target: problems.md
- TRANSMIT THREAD LANDED, and it fixed what it targeted.  Per display
  fill, before 513 datagrams in 17-19 ms (27-30k halfwords/s), after 512
  in 9.5-10.6 ms (48-54k) -- the bus rate, inside the 10.7 ms the
  display's bus program allows.  Sends are off the emulation thread; the
  lock covers the FIFO and bucket only, never a send.  pthreads probed
  in the Makefile like HAVE_POSIX_TIMERS; the thread starts on the first
  bus opened, so a run without --bce-network never makes one.
- Banked credit went back to one burst.  With 256 banked the thread
  emptied a fill in 5.3 ms, twice the bus rate, and the display logged
  22 unheadered fills.  Raising it had only ever been a workaround for
  pump gaps that the thread removes.
- The display STILL does not complete its load, and the blocker is now a
  different, older fault: a spurious "DISPLAY_FILL count 8" command
  arrives immediately behind a good 511-word fill, and the eight words
  behind it are that fill's OWN header -- 01fd 0f49 0000 ... , i.e. 509
  and 0xf49.  So we emit a command whose count field says 8 and then
  send header words as data.  It is not the thread's doing: the same
  "unheadered fill of 8 halfwords" appeared 10-18 times a run before it,
  and it is not a FIFO ordering problem either -- flush_bus/xmitBuf in
  bcenet_framer.c is DEAD CODE (xmitCount is only read and zeroed, never
  incremented), so commands and data both go straight into the one
  ordered queue.
- Store-protect over-protection is ruled out as a display cause: four
  violations in a whole run (YAGPC_PROTTRACE), at NIA 00bfa, 01058 and
  01107 twice.

### [2026-08-24] Target: problems.md
- CORRECTION to commit 332e571fb's message: the count-8 DISPLAY_FILL is
  NOT "a different and older fault".  It predates the transmit thread,
  but it is a SYMPTOM of the same stuck state, not independent of it.
- What it actually is: the bus program really does have two fills back to
  back -- 03572 #MOUT X'0',X'1FE' (511 words) then, after its #WAT at
  03577, 03578 #MOUT X'0',X'7' (8 words) -- and BOTH send from BASE+0.
  #WAT leaves the PC on 03578 (the reference's #WAT is identical, clear
  busy and incrNIA(1)), so an @SIO that starts BCE6 without a fresh
  @LBP@ resumes it there and re-sends the first 8 halfwords of the fill
  buffer: 01fd 0f49 0000..., which is that buffer's own header, and the
  display rejects it as unheadered.
- Start-without-dispatch is NOT itself abnormal -- the reference starts
  BCE6 436 times at 0329d, we start it 143.  The difference is only
  WHERE the BCE is parked: it has moved on to its steady-state display
  program, we are still in the IPL one, so our restarts land on 03578.
- The clearest single statement of where we still are, from the display's
  own command counts.  Reference: 259 DISPLAY_FILL count 198 (the real
  display data), 7 count 511 (the IPL blocks), 0 count 8.  Ours: 37 count
  511, 34 count 8, and NO count 198 at all -- we never reach steady state.
- The @RAW at 032a4 still times out, though far less: 032a5 (timeout) 37
  and 032a6 (met) 71, against the reference's 0 and 14.  The transport is
  no longer the reason -- fills clear in 9.5-10.6 ms now -- so what keeps
  BCE6 busy past the window is the spurious second fill itself, which is
  the loop closing on itself again.

### [2026-08-24] Target: problems.md
- BUILT: --deu-model, a display unit modelled in process (src/deumodel.c),
  ported from meds/deuUnit.coffee and meds/deuProto.coffee.  Synchronous,
  lossless, no socket, no pacing.  Installed INSTEAD of --bce-network.
  YAGPC_DEUTRACE reports servicer calls by bus.
- THE EXPERIMENT DID NOT ANSWER ITS QUESTION.  Under --deu-model the
  machine does essentially no bus I/O: under 5000 servicer calls in 100 s
  wall, and ZERO commands addressed to the unit over 234 s of SIMULATED
  time at pacing rate 0.984.  The same image under --bce-network is
  filling the display by 7.2 s of simulated time.
- It is NOT the model failing to install: it prints on creation, a
  --max-steps 1 run shows it wired in and reporting, and its counters are
  all zero rather than absent.  The emulator never asks it anything.
- Ruled out while chasing that: the run is not merely slow (234 s of sim
  reached, rate 0.984), and the real unit does NOT initiate -- gpcmd's
  --ipl-request only sets ipled:false, so the unit is purely reactive,
  exactly as the model is.
- SO THE NEXT QUESTION IS SHARPER THAN THE OLD ONE: why does the machine
  drive the bus with one GpcServicerFn installed and not with another,
  when the interface is the same four calls?  Something other than the
  servicer's replies differs between the two configurations -- the
  framer's per-instruction bcenet_framer_flush_tick from run.c is the
  obvious candidate, since the model has no equivalent, but that should
  be transport-side only.  Answer that before drawing any conclusion
  about UDP versus TCP; the experiment cannot speak until it does.
