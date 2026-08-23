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
