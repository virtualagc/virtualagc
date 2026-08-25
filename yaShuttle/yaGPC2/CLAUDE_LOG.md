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

### [2026-08-24] Target: problems.md
- WHY --deu-model does no bus I/O, traced to the instruction: the IOP
  halts at 4,409,948 us of simulated time -- the SAME instant in a 45 s
  and a 120 s run, so stuck, not slow -- with BCE18 spinning forever at
  03600 on f300 0001, which is #RDLI, a receive.  BCE18 is MM1, the MASS
  MEMORY.  Its receive never completes and never times out, so the MSC's
  @RAI X'64' at 014b9 -- which waits for ALL 24 BCE indicators, ACC
  7fffff80 -- never gets BCE18's, stays parked in early init, and never
  reaches the display code.  The CPU is not deadlocked: it spins at
  01df8 reading 36C2/36C4 and takes 1,651 clk1 interrupts waiting for
  the IOP.
- THE ASYMMETRY TO EXPLAIN: under --bce-network BCE18 has no peer either
  -- no MMU process has ever been running in any of these runs -- yet
  the machine gets past it (BCE18 8,713 lines, BCE6 109,683).  So the
  same starved receive blocks under one GpcServicerFn and not the other.
  Suspect iop_bce_receive's timeout path: it error-terminates 20 ms
  after the receive starts, which sets the BCE's indicator and is
  presumably what releases the @RAI.  Find why that fires with the
  framer installed and not with the model.
- Method note: the earlier reading "the machine is just slow under
  --deu-model" was wrong.  Two runs of different length reaching the
  identical simulated timestamp is the signature of a stall, and it was
  visible in the first measurement had I compared the two endpoints.

### [2026-08-24] Target: problems.md
- THE BIG ONE, and it invalidates the baseline this whole display
  investigation rested on: there is a MASS MEMORY UNIT peripheral in
  nsts-sim-gpc (mmu/, `node dist/mmu.js run --unit 1`, bus MM1 = BCE18)
  and it had NEVER been run in any of these sessions.  GPCIPL is the IPL
  program; it loads from mass memory.  With MMU1 up it is plainly driven:
  "cmd READ ... track 4 subfile 4 block 8 count 7", "read 8 block(s) from
  4/4/4/8", BITE_STATUS, POSITION_REQ.
- What that changes at the display, same 90 s run, --bce-network:
  timeFills 71 where it had been 1 to 4; commands 358, fills 75, polls
  146.  Still no "load complete" and 73 unheadered 8-halfword fills, but
  the machine is in a visibly different and healthier state.
- HOW WE GOT AWAY WITHOUT ONE, and it is not good: with --bce-network and
  NO peer at all the machine still reaches 57.7 s of sim and runs BCE6
  124,140 times, because BCE18's receive COMPLETES in 100 us on a bus
  with nothing on it.  That is our own multicast echo being read back as
  mass-memory data.  Under --deu-model, which cannot echo, the same
  receive correctly times out and retries -- which is why the model
  looked "stuck" when it was in fact the only configuration behaving
  honestly.
- CORRECTION to the previous entry: --deu-model does NOT stall on BCE18.
  It arms, times out at 20 ms, error-terminates and retries cleanly --
  visible once YAGPC_TIMEOUT_TRACE reported arms as well as expiries.
  The "stuck at 4409948 us" reading came from a trace cut off mid-spin by
  the wall-clock timeout; two runs ending at the same simulated instant
  had a duller explanation than a stall.
- FIXED: the 20 ms receive-timeout floor is a socket concession and is
  now iop_set_recv_timeout_floor_us(), set to 0 for --deu-model.  GPCIPL
  asks the mass memory for 0.25 ms (MTO 15) and we were giving it 20.
- STILL OPEN: the UDP-versus-TCP question CANNOT be answered from any
  measurement taken so far, because every --bce-network run in the record
  was made without a mass memory and partly on phantom echo data.  Rerun
  the comparison with MMU1 up before drawing any conclusion.

### [2026-08-24] Target: problems.md
- CORRECTION of my own sloppy wording: GPCIPL does NOT load GPCIPL.  It
  is already resident -- it is the image being run.  What it does is READ
  from the mass memory (observed: track 4, subfile 4, block 8, count 7)
  and load the DISPLAY's control program into the DEU.  The MMU matters
  only because GPCIPL talks to it while doing that, and with no MMU
  running our BCE18 receives were being satisfied by our own echoed
  packets rather than by a device.
- THE UDP-VERSUS-TCP TEST, run at last on a sound baseline.  Same UDP
  transport, same two peripherals (MMU1 + display unit), same image,
  90 s each:
      reference : load COMPLETE, 436 commands, 152 fills, 138 timeFills,
                  0 headerless, modeStatus 4, 37 MMU commands
      yaGPC2    : no load,       345 commands,  81 fills,  62 timeFills,
                  59 headerless, modeStatus 142, 37 MMU commands
- CONCLUSION: UDP is SUFFICIENT.  The reference completes the display
  load over exactly the transport we call fragile, against the same
  peripherals, on the same machine.  The transport is not what stops
  yaGPC2; the remaining fault is ours.  Everything earlier in this
  session that attributed the failure to UDP was reasoning from a
  baseline with no mass memory and phantom echo data in it.
- Note the MMU command counts are IDENTICAL, 37 and 37.  The mass-memory
  path matches the reference exactly; the divergence is entirely on the
  display side, where we produce 59 unheadered fills and 142 mode-status
  polls against the reference's 0 and 4.

### [2026-08-24] Target: problems.md
- THE 8-HALFWORD FILLS, cause established with the MMU running so the
  baseline is sound.  Mechanism, caught in one instance at 8241698 us:
      03276 @LH X'3622'      loads 0
      03278 @BC X'4',X'7'    TAKEN -> bypasses @XAX/@LBP@/@LBB@
      03280 -> 03294 -> 0329c @L X'3B1' -> ACC 02000000 (BCE6)
      0329d @SIO             starts BCE6 with no dispatch in this pass
      BCE6 03578 f500 0007   resumes its STALE parked PC, BASE 0b302
  #WAT at 03577 leaves the PC on 03578 (the reference's #WAT is
  identical), so a start without a fresh @LBP@ re-sends the first eight
  halfwords of the 511-word fill buffer -- 01fd 0f49 0000..., that
  buffer's own header -- and the display rejects it.
- 0x3622 is the MSC's "next device to service" index, the same values the
  @XAX at 03279 takes.  Reference: 0x0a 160, 0x18 159, 0 36, plus 0x22,
  0x14, 0x16.  Ours: 0x0a 78 and 0 113, NOTHING ELSE.  So the reference
  alternates between two service slots and we only ever have one, and
  when the index is 0 the MSC skips the dispatch.
- The bypass itself is NORMAL -- the reference takes it 36 times of 379.
  It is harmless there because its BCE6 is parked in its steady-state
  program (#WAT at 0359e, 156 times), not at 03578.  We are parked at
  03578 because we are still running the 03572 IPL program: BCE6 03572
  82 times here against the reference's 6, and 03592 78 against its 162.
- Confirmed the reference NEVER executes 03578 (0 against our 77), and
  never 0357c/0357d (0 against 2002/77), with MMU + display both up.
- So the fills are fully explained and the question upstream of them is
  now one line: why does 0x3622 never take the value 0x18 here?  Its
  writers are 032f2 (ours 196, ref 366), 03358 and 0336e (ours 82 each,
  ref 7 each -- the IPL block loop we cannot leave).

### [2026-08-24] Target: problems.md
- ROOT CAUSE CHAIN, found with cmp4.py on a sound baseline (MMU +
  display both up), which is the tool I should have used at the start.
  4,154,388 CPU instructions match EXACTLY, zero phase slips.  Then at
  instruction 4,154,388, both on the same instruction
  0030b6 C 6,X'0034'(1), the reference swaps PSW to 1ed6 -- an External 2
  through PSA 008c -- and we do not.
- It is LATE, not missing.  Both take ext2 exactly 12 times.  Ours trail
  consistently: 4,154,918 against 4,154,388 (530 instructions), then
  4,158,655 against 4,157,923 (732), then 4,162,372 against 4,161,623
  (749).  About 1.3 ms each time.  cmp4.py calls it a real divergence
  because an interrupt reroutes execution and it cannot resync through
  one.
- EVERYTHING ELSE IS DOWNSTREAM OF THAT LAG, and now ordered:
  after it the CPU paths separate -- the reference executes 02a32
  (STH 4,X'0bec'(0), which writes 0x18 into 3622) 54 times and we
  execute it ZERO times; we instead execute SHW at 0210e 49 times
  against its 1.  So 3622 never reaches 0x18 here, the MSC's branch at
  03278 takes the no-dispatch path, @SIO restarts BCE6 on its stale PC
  03578, and that emits the malformed 8-halfword fill.  Our spurious
  @INTs at 032ae (77) and 032ee (82), which the reference never
  executes, are downstream too -- they all occur AFTER the divergence,
  which is why 4.15M instructions could match before it.
- RULED OUT as the cause of the lag: MSC per-instruction timing.  The
  step distributions match -- 2.0, 0.5, 1.0, 9.2, 9.3 us dominant in
  both.  We simply execute more MSC instructions, and that is itself
  downstream (the @RAW spin).
- STILL UNFIXED: why our External 2 arrives ~530 instructions late.  That
  is the whole remaining question; everything else in the display
  investigation reduces to it.

### [2026-08-24] Target: problems.md
- SCALE OF THE LATE EXTERNAL 2, measured rather than estimated.  The
  interrupt period is 3,717 instructions and 5,997 us of simulated time,
  so 1.61 us per instruction (the whole-run average of 10.3 us/instr is
  meaningless here -- it includes wait states).  Therefore 530
  instructions is:
      emulated time   ~0.85 ms
      real time       ~0.95 ms  (pacing rate 0.895)
      bus words       ~43 halfwords, i.e. 43 datagrams at 20 us each
      as a fraction of one 511-word display fill (10.2 ms):  ~8%
      as a fraction of the 40 ms MSC service tick:           ~2%
  So it is FAR below bus scale, which makes the transport an unlikely
  cause; a fill takes twelve times as long as the whole discrepancy.
- IT IS NOT JITTER, controlled for by running ours twice: our own two
  runs put the first ext2 at 4,154,918 and 4,154,956 -- 38 instructions
  apart, and 1 apart for every one after that.  The gap to the reference
  is 530, 732, 749, 806, 769, 786.  An order of magnitude larger and
  systematic.
- Nor is it a RATE error: instructions per interrupt period match well
  (ours 3737/3717/3737/3700..., reference 3535/3700/3680/3737...), and
  the offset does not grow.  It is a fixed phase error in WHEN External 2
  reaches the CPU, worth about 0.85 ms.
- So the remaining question is narrower than "why is the IOP late": it is
  why interrupt DELIVERY from IOP to CPU sits ~0.85 ms out of phase, at a
  scale well below anything the bus does.  Slice granularity and when the
  IOP is stepped relative to the CPU are the places to look.

### [2026-08-24] Target: problems.md
- IS THE ~6 ms MEANINGFUL?  Yes, and as a GOOD sign.  Both emulators show
  the same two alternating MSC @INT periods, 5997.2/5997.3 us and
  6007.2/6007.3 us -- identical to a tenth of a microsecond.  It is the
  flight software's own MSC service-loop period, emergent from summed
  instruction timings, not a constant either emulator injects.  That we
  reproduce it that exactly is evidence our MSC instruction timing is
  right.
- AND IT SHARPENS THE PROBLEM: if the PERIOD matches to 0.1 us, the
  0.85 ms offset cannot be accumulated drift.  It must be a phase STEP,
  taken once.  Located it:
      * MSC first-executions agree to +-0.1 us up to sim 148,710 us.
      * Both then park for an IDENTICAL 4001.1 ms and both resume at
        03266 at exactly 4,149,811.8 us -- so the wake is not the cause.
      * From that common instant the MSC PC sequences run 1,214
        instructions in lockstep, then part at 03445 @RAI X'64':
            ours 03444 03445 03447 ...  condition MET, incrNIA(2)
            ref  03444 03445 03446 ...  NOT met,      incrNIA(1)
- WHY: @RAI waits for ALL BCE indicators (ACC 7fffff80).  An indicator is
  set by #SIB or by iop_bce_error_terminate, and a receive TIMEOUT
  error-terminates.  Measured with MMU and display both up:
      BCE6 receive timeouts -- ours 95, reference 4.  BCE18 -- ours 1, ref 0.
  So the display BCE's starved receives set its indicator over and over,
  @RAI is satisfied ~3.6 ms early, and the MSC's whole service loop runs
  out of phase from there.
- @RBI is NOT the culprit; ours matches the reference exactly, including
  the ACC-relative BCE selection fixed earlier.
- So the bus-level symptom (starved 16-word polls) feeds BACK into MSC
  control flow through the indicator bits.  That is the coupling that
  makes this look circular, and BCE6's 95-vs-4 timeouts is the place to
  break it.

### [2026-08-24] Target: problems.md
- FIXED, AND THE DISPLAY NOW COMPLETES ITS IPL.  The receive timeout
  floor was 20 ms; the flight software loads the display BCE an MTO of
  303, which is 5.0 ms.  So the floor was not a floor, it was an
  override, and every starved receive cost four times what the software
  allowed -- more than three whole 6 ms MSC service periods.
- The coupling that made this look circular for so long: a timed-out
  receive error-terminates its BCE, which SETS the BCE's indicator, so
  the MSC's @RAI is satisfied early, the service loop slips out of
  phase, the MSC skips its @LBP@/@LBB@ dispatch, restarts BCE6 on a
  stale PC (03578), and the display gets a fill carrying another
  transfer's header.  Every symptom chased this session -- the 8-halfword
  fills, 3622 never reaching 0x18, the 530-instruction late External 2,
  the stale-PC restarts -- hangs off that one number.
- Swept with MMU1 and a display unit both up, changing only the floor:
      20 ms  no load,  97 BCE6 timeouts, 27 unheadered
       5 ms  LOADS,    14 timeouts,       0 unheadered
       2 ms  LOADS,     6 timeouts,       0 unheadered
     0.5 ms  LOADS,     6 timeouts,       0 unheadered
  Settled on 2 ms: still a real floor for the mass memory's own 0.25 ms
  MTO, which no socket peer answers inside, but under anything the
  software sets deliberately and 20x the ~100 us a peer really takes.
- Standing beside the reference at the default now: load complete both;
  commands 462 vs 480, fills 160 vs 166, timeFills 145 vs 153,
  unheadered 0 vs 0, polls 157 vs 159.
- YAGPC_RECV_FLOOR_US overrides it, which is how the sweep was taken.
- NOTE for the UDP question: this was NOT a transport fault.  It was our
  own timeout policy distorting the software's timing.  The earlier
  conclusion stands and is now doubly supported -- UDP carries the
  display fine, in both emulators.

### [2026-08-24] Target: problems.md
- RETRACTION.  I wrote that the Mass Memory Unit "had NEVER been run in
  any of these sessions".  That is false and the record says so plainly.
  Earlier entries in this very log describe running it -- "Control run on
  the same live MMU instance: gpc --real-time = 37 commands in 45 s",
  "yaGPC2 NOW DRIVES DON'S MMU. Against a live MMU.sh run", "yaGPC2 now
  follows gpc's MMU sequence exactly" -- and commit 6312e5a61 of
  2026-08-23 is titled "@RBI takes its BCE from the accumulator too; MMU
  load completes", a fix found by measuring 76,266 mass-memory block-loop
  iterations against the reference's 33.  None of that is possible
  without the MMU running.  The 37 commands I "discovered" today is the
  same 37 recorded then.
- What was actually true, and all I was entitled to say: I did not start
  the MMU when I set up THIS session's harness, so every measurement I
  took before noticing lacked a peripheral the project had long since
  been exercising.  That is my process failure, not a project gap.
- The part that does stand: with no MMU running, BCE18's receives are
  satisfied in ~100 us by our OWN multicast echo rather than by a device,
  which is what let a peripheral-less run look healthy and hid the
  omission from me.
- PATTERN TO WATCH, twice in one session: I asserted a strong negative
  from local absence of evidence.  First "IPL.fcm has no .sym.json"
  without running ls -- the file was there.  Then "the MMU has never been
  run" without grepping this log -- it had.  Check the record before
  claiming something has never happened.

### [2026-08-24] Target: problems.md
- MEDS NOW WORKS.  With the 2 ms receive floor, MMU1 and MEDS all up,
  yaGPC2 drives the real display through a completed IPL and renders the
  GPCIPL MENU correctly -- BOTH pages, per the user "even down to the
  exact register values, ERROR codes and counts" against Don's video.
  ITEM 18 (start self test), ITEM 19 (stop), ITEM 27+n, ITEM 28 all
  behave as the video does.  Our text is arguably BETTER: we render
  "ILLEGAL KYBD ENTRY WHILE SELF TEST IN PROGRESS" where the video shows
  a corrupted "ILLEGAL KYBD ENTRY WHSELF TEST     IN PROGRESS".
- gpcmd has a `key` subcommand that injects keystrokes on the keyboard
  bus ("gpcmd key --idp 1 SYS_SUMM"), so the display can be driven
  headlessly.  Host key map lives in meds/kybd.coffee: I=ITEM,
  Enter=EXEC, O=OPS, P=PRO, S=SPEC, R=RESUME, K=ACK, Esc=MSG RESET,
  Backspace=CLEAR, T=I/O RESET, Y=SYS SUMM, U=FAULT SUMM, G=GPC/CRT.
- OPEN, AND THE SHARPEST REMAINING DIVERGENCE: the MMU1 erase sweeps far
  too much.  The video's MMU messages run position 0/0/0 through 4/0/0 --
  FIVE positions -- and then the display auto-advances to ITEM 29 (erase
  stop).  Ours walks 64: first field 0-7, then the second field
  increments, through 7/7, and then starts a second pass instead of
  stopping.  About thirteen times too many writes.
- So the erase's slowness was a red herring of mine.  The arithmetic is
  right -- 512 halfwords a block, 256 blocks a write, 131,072 halfwords,
  measured 28,961 words/s on MM1, hence 4.53 s per write and ~4.8 min a
  pass -- but the fault is the 64 positions, not the 4.53 s.  Our pacing
  of 20 us a word IS the real 1 Mbps bus rate; the reference paces not at
  all and is therefore faster than a real bus could be.
- NEXT: drive the reference headlessly through the same key sequence with
  gpcmd key and compare its MMU position list against ours.  That is a
  direct comparison needing no GUI and no user in the loop.

### [2026-08-24] Target: problems.md
- THE ERASE DIVERGENCE IS NOW A HEADLESS, REPRODUCIBLE TEST -- no GUI, no
  user in the loop.  Drive either emulator with a real MMU1 and a
  headless display unit, wait for "load complete", then inject with
  gpcmd key --idp 1:
      ITEM 1 8 EXEC        (start GPC self test)
      ITEM 1 9 EXEC        (stop)
      ITEM 2 7 PLUS 1 EXEC (DEU erase option 1)
      ITEM 2 7 PLUS 3 EXEC (MMU1 erase option 3)
      ITEM 2 8 EXEC        (START)
  and watch the MMU's write positions.  Script kept at scratchpad/refseq.sh.
- RESULT, identical stimulus, 150 s each:
      reference : 4 writes, ONE position (0/0/0/0), static from t=30 on
      yaGPC2    : 39 writes, 36 positions, growing ~8 writes per 30 s,
                  sweeping 0/0 1/0 ... 7/0, 0/1 ... 7/1, ... 3/4
  The reference writes four blocks at one position and stops; we sweep
  the tape and keep going.
- CAVEAT, stated so nobody over-reads it: this key sequence does NOT
  reproduce the video exactly -- the video's MMU walks 0/0/0 through
  4/0/0, five positions, and my reference run shows only one.  So the
  sequence is not precisely Don's.  What the test DOES establish is a
  divergence under identical stimulus, which is what makes it useful.
- Display IPL completes in 12 s for both, headless.  That is the fix from
  earlier today holding up under an independent harness.

### [2026-08-24] Target: problems.md
- RETRACTION of "the erase sweeps 13x too much".  That compared the
  video's EIGHT SECOND window (0:35-0:43, five positions) against our
  multi-minute run (64 positions).  Different durations; the comparison
  was meaningless.  Per unit time: video 5 positions in 8 s = 0.63/s,
  ours 13 positions in 57 s = 0.23/s.  We sweep SLOWER, not more.
- Also retracted: "the reference auto-advances to ITEM 29".  The user's
  reading of his own timings is that Don pressed it manually at 0:43,
  having got bored -- 0:43 shows both the apparent ITEM 29 and the actual
  stop.  So there may be no automatic termination to reproduce.
- MATCHED PAIR, Don's exact key timings, identical blank tape:
      t=43s   ref 2 writes/1 position   ours 2 writes/1 position
      t=60s   ref 4 writes/1 position   ours 6 writes/5 positions
      t=90s   ref 4 writes/1 position   ours 14 writes/13 positions
  They START IDENTICALLY and then the reference stalls at 0/0/0/0 while
  we advance 1/0, 2/0, 3/0 ...
- BUT THE VIDEO ADVANCES TOO, 0/0/0 through 4/0/0.  So on this behaviour
  OURS resembles Don's video and my headless reference is the odd one
  out.  Most likely because I run the MMU with a blank tape ("0 block(s)")
  where his run probably had a real --volume.  Do not treat the headless
  reference as a stand-in for the video on this point until that is
  settled.
- What survives: our sweep RATE is about 2.7x slower than the video's,
  which is consistent with our pacing at the real 1 Mbps bus rate
  (20 us a halfword) while the reference paces not at all.  That is a
  known and deliberate difference, not a defect.
- METHOD NOTE: three claims this session died the same way -- comparing
  measurements taken over different windows, or against a setup that
  differed in a way I had not checked.  Match the durations and the
  configuration before comparing counts.

### [2026-08-24] Target: problems.md
- TERMINOLOGY, since it caused confusion: "the reference" always means
  DON'S EMULATOR, gpc.  "Ours" means yaGPC2.  It has never meant two
  different flight images.
- There ARE two image paths, and the pairing is forced, not chosen:
      ~/Desktop/IPL/IPL.fcm  + original IPL.sym.json  -> yaGPC2
      scratchpad/iplref/IPL.fcm + patched IPL.sym.json -> gpc
  The .fcm files are BYTE-IDENTICAL, md5 ddd623fc2aafee71a7277b32511f330f.
  The sym.json differ by exactly ONE key, storeProtect, present only in
  gpc's; all ten shared keys are identical.  yaGPC2 reads storeProtect
  zero times.
- The four combinations, all now established rather than assumed:
      gpc    + patched   works  (the reference in every comparison)
      gpc    + original  DOES NOT BOOT (the 0e275b1 store-protect issue)
      yaGPC2 + original  works  (ours in every comparison)
      yaGPC2 + patched   works, VERIFIED identical -- load complete,
                         0 unheadered, modeStatus 12, same as its usual
                         image
  So only three are runnable and the two yaGPC2 cells are equivalent;
  the comparisons drawn this session are sound.
- Care taken: the raw counters of that verification run (267 commands)
  are lower than the earlier one (509) ONLY because the run was 70 s
  against 90 s.  Do not read a difference into that -- the same
  duration-mismatch error invalidated three claims earlier today.

### [2026-08-24] Target: problems.md
- WE CAN BUILD OUR OWN FLIGHT IMAGE, and it works on both emulators.
  tools/build_ipl_fcm.sh: eleven modules assembled from OI340600/SSSRC
  with asm101, linked by lnk101 under the CON80 deck's own layout
  (--concard CON80 --concard-root PHASE10 --allow-undefined).
- Verified against Don's: all twelve sections at IDENTICAL addresses and
  sizes, entry point identical at 18195, and of the 65,024 shared bytes
  the only in-section differences are SIX in FCMINSSL -- halfwords 29534
  and 29536, the two unrelocated FIOMUWB2 references (0x3032a).  Eleven
  of twelve sections byte-identical.  This settles the BILDNEW5 link that
  HANDOFF-OI340600 records as unvalidated for want of a dump.
- Runs on both, with real MMU1 and a real display unit:
      yaGPC2    load complete, 268 commands, 93 fills, 81 timeFills,
                0 unheadered, 37 MMU commands
      reference load complete, 267 commands, 96 fills, 82 timeFills,
                0 unheadered, 37 MMU commands
- CORRECTION to my own alarm earlier today: I called DEUIPLCP "the worst
  possible blocker" because the name reads as DEU IPL Control Program and
  the display load transmits exactly that.  It is not a blocker.  The DEU
  model never EXECUTES the control program -- deuUnit.coffee stores it in
  @mem, has no opcodes or program counter, and gates completion solely on
  a final block whose count is 250.  The picture comes from the format
  control words in the fills that follow, and MENU12 draws those; MENU12
  is one of the eleven we build.
- Also corrected earlier today: my claim that no CON80 deck directory
  existed under ~.  It is at ~/workspace/PFS/OI340600/CON80 with 194
  decks, four levels down, and a timed-out find had reported its absence.
- lnk101 here does NOT emit storeProtect (nor does mmu2fcm's unionSym),
  so an image built this way needs tools/add_store_protect.py before the
  reference emulator will boot it.  Its section-derived map came to 7
  ranges, 26,779 halfwords.
- STILL OPEN if byte-exactness is ever wanted: FIOMUWB2 needs DEUIPLCP,
  which needs OPS0/phase 2; and PCH10TXT has no source anywhere.

### [2026-08-24] Target: [HANDOFF-yaGPC2-MEDS.md]
- FCMBOOT boot-chain feasibility surveyed.  PHASE01 (CON80 deck: FCMBOOT +
  LOADTBL + dummy SSL + FCMSSLPT) assembles and links with ZERO undefined
  symbols -- cleaner than PHASE10, which needs --allow-undefined for
  FIOMUWB2.  Sections land at the deck's OVERLAY addresses: FCMBOOT 0x00000
  (1864 hw), LOADTBLE 0x06FBC (32), FCMSSLPT 0x07C00 (768).  Built in
  scratchpad/boot/BOOT.fcm.
- On-tape format is fully specified in FCMBOOT.asm's own header: 3-hw phase
  descriptors (index to 1st load block, # load blocks, MM address of 1st LB)
  for phases 10/2/13/3, and 3-hw load-block descriptors (MM address;
  protect/reserve/sector flags; length in hw).  Table lives in CSECT
  FCMSSLPT, which is `DC 768H'0'` -- reserved space the Mass Memory Build
  stamps over, so in our image it is all zeros.
- Toolchain already covers the tape: nsts-sdl-dps/src/tools/mmu2mmv.py writes
  a .mmv volume in the same geometry Don's MMU model uses (8 files x 8 tracks
  x 8 subfiles x 32 blocks x 512 hw, header + block-index directory, and a
  writeProtect flag matching `mmu create --write-protect`); mmubuild.py
  parses the real MM build cards; mmbstamp.py stamps in-core phase tables.
  Cards are in the corpus: CON80/MMUDAT*, MMUSYS*, MMLOAD.  MMLOAD carries
  `IPL,PH=(10,2,13,3)` -- exactly the phase set FCMBOOT's header names --
  and `FMAIPL2 COPY,IPL; ALLOC,ADDR=44500,BLKS=72` is the bootstrap's own
  tape allocation; MM directory at 44000.
- THE ONE GAP: nothing emulates the IOP microcode that loads FCMBOOT off the
  tape at IPL initiation.  yaGPC2's --ipl does cold-IPL memory init only
  (fill+protect, Sec 2.5.3.3) and still loads the .fcm from a file; gpc is
  the same.  Sidestep: FCMBOOT's header says it "RECEIVES CONTROL FROM THE
  MICRO CODE LOADER VIA THE SYSTEM RESET PSW", which is exactly what
  --power-on already does, so loading BOOT.fcm as the boot image and letting
  FCMBOOT do its own MMU reads tests the real question without any microcode.
- Caveats for that experiment: mmbstamp's two csects are #PFCMGPT/#PCDCPHA
  (the SSL's tables); neither FCMSSLPT nor BRSSLPT appears in the MMU cards,
  so the IPL phase table may have to be built by hand (format is documented,
  and we know phase 10's load blocks).  And we can build only phases 1 and
  10 of IPL,PH=(10,2,13,3) -- phase 2 is where DEUIPLCP/FIOMUWB2 live -- so
  a complete IPL is out of reach; the question is whether FCMBOOT gets
  phase 10 in.
- REVISION to the above, after measuring rather than assuming.  (a) A full
  set of linked phase load modules ALREADY EXISTS in scratchpad/phase_build/
  OI340600/PHASEnn/PHASEnn.lib -- 25 phases, built 2026-08-22/23 -- INCLUDING
  PHASE02.lib (252 KB).  So "we can build only phases 1 and 10" was wrong.
  (b) mmu2mmv --report against our own CON80 and those libs writes 17 of 52
  allocated phases, 1086 blocks / 556032 hw, and ALL FOUR IPL-set phases fit
  comfortably: phase 2 uses 154 of 256 blocks, 3 uses 37 of 64, 10 uses 55 of
  64, 13 uses 5 of 16, each marked `written`.  The single overflow is phase
  21 (needs 42, allocated 41), which is not in the IPL set.
- So the gap is three well-scoped items, not a vague one:
  1. The IPL phase table in FCMSSLPT.  mmbstamp generates #PFCMGPT (in-core
     phase table, 16 4-hw descriptors, phases 3..18) and #PCDCPHA (alternate
     MM area) -- NEITHER is FCMBOOT's table, which is 3-hw descriptors for
     the IPL set 10/2/13/3.  Must be generated by us; but mmbstamp's
     derive_load_blocks already computes exactly the raw material (each LB's
     MM address, protect/reserve/sector flags, length in hw).
  2. FMAIPL2 at tape 44500, 72 blocks -- the GPC IPL BOOTSTRAP COPY.
     mmu2mmv names it explicitly under "not generated -- the ground build's
     own data".  This is what the IOP microcode reads at IPL initiation.
     We now have PHASE01.lib, so it is a matter of laying it in.
  3. MMDIR at tape 44000, the mass memory directory.  Also "not generated";
     mmu2mmv warns "a GPC reads the directory to find everything else, so a
     volume from here serves the phases but nothing that points at them."
     FCMBOOT's documented input is the phase table, not MMDIR, so it may not
     block the first experiment -- the SSL will want it.
- PHASE21 oversize CAUSE FOUND, and it is not compool size and not SDL.  The
  phase carries a fourth csect the deck never INSERTs: #PCGMIMU, 510 hw, which
  PHASE22's deck INSERTs (phase 22's own allocation is 2 blocks / 1024 hw,
  ample).  PHASE21 has no NOCALLER card, and our harness handed CGMIMU.obj to
  phase 21's link as an explicit input -- it sits in PHASE21/obj/ and is named
  in PHASE21.lnk101.repro.json's file list.  Measured:
      with    #PCGMIMU  21496 hw csect -> 42 tape blocks (allocation 41) OVERSIZE
      without #PCGMIMU  20986 hw csect -> 41 tape blocks exactly       written
  Whole-tape total falls 1086 -> 1085 blocks and the "1 of them do not fit"
  line disappears; every allocated phase now fits.  Fix belongs upstream in
  whatever assembles each phase's object set: phase 21 gets CSTCPT, CS2CPT,
  CS4CPT and nothing else.
- Note on mmu2mmv's paths, which cost a wrong measurement first time round:
  it reads the phase image from mmuRoot/PHASEnn.lib (TOP LEVEL) but the sym
  from mmuRoot/PHASEnn/PHASEnn.sym.json (SUBDIRECTORY).  Editing the subdir
  .lib changes nothing.  Original top-level PHASE21.lib backed up to
  scratchpad/boot/PHASE21.lib.ORIGINAL; corrected one is in place.
- CORRECTION to the earlier SDL note: SDL is not a diagnostic switch.  Per the
  user it selects whether object code targets the Shuttle onboard computers or
  the Software Development Lab machines, and it generates extra code.  It was
  enabled deliberately, to match the compiler options used in the DASS
  disassemblies.  The two SDL_OPTION sites found in EMITEXTE.xpl/SYNTHESI.xpl
  are error paths only and are NOT the whole of what the option does.
- PHASE21 FIXED, and the harness itself turned out not to need changing.
  con80build's current source already scopes the link correctly:
  resolve_worklist -> concard.build_graph('PHASE21').object_modules() returns
  exactly ['#PCS2CPT','#PCS4CPT','#PCSTCPT'] (verified by running it), and
  worklist_objects() therefore selects CS2CPT/CS4CPT/CSTCPT.obj only.  The bad
  PHASE21.lib came from link()'s FALLBACK path -- `objs = sorted(objdir.glob(
  "*.obj")) if objs is None` -- which sweeps in every object in the directory.
  A stray CGMIMU.obj was sitting there (a template-closure product that should
  have been segregated to gen/tmpl_obj, which is empty), so the glob linked 4.
  Don's own comment at the correct call site names the exact hazard: "Scope the
  link to this root's modules so a partial build (e.g. one phase) doesn't pull
  other phases' csects out of the shared obj dir" (landed 2026-08-05, before
  the db49693 the build recorded, which was marked dirty).
  Fix applied: CGMIMU.obj moved to scratchpad/boot/quarantine/, and the
  corrected 3-csect PHASE21.lib put in place at the TOP LEVEL where mmu2mmv
  reads it.  Both selection paths now yield the same three objects.  Verified:
  phase 21 = 41 blocks of 41 allocated, `written`; no WARNING line; no phase
  fails to fit; whole tape 1085 blocks / 555520 hw.  Original lib preserved at
  scratchpad/boot/PHASE21.lib.ORIGINAL.  NOTHING in Don's repo was modified.
- MMDIR CONFIRMED NOT NEEDED to load GPCIPL, now verified rather than assumed.
  FCMBOOT.asm's header lists exactly one external reference -- FCMSSLPT -- and
  the code walks the table directly (`LA R4,FCMPTAD1  START OF THE PHASE
  TABLE`).  Grepping the whole module for MMDIR / DIRECTOR / 44000 finds no
  reference at all.  MMDIR is what a RUNNING GPC uses to find datasets;
  FCMBOOT navigates purely by the stamped IPL phase table.  The three entry
  points FCMPTAD1/2/3 are one per redundant PASS area -- matching the SYS1/
  SYS2/SYS3 allocations (SMACKPT1/2/3 at tape 30000/20000/10000) and
  FCMBOOT's documented output "AREA # THAT THE GPCIPL/SSL WAS LOADED FROM IN
  HALFWORD THREE".  Unstamped, FCMPTAD1 is `DC H'-1'`, not zero.
  So the ONE genuine blocker is the phase table itself, not the directory.
- FIDELITY NOTE: FCMBOOT's header says four assembly errors are EXPECTED --
  IEV072 "DATA ITEM TOO LARGE", severity 8, at SRNs 98700/102900/103000/103100,
  concerning sector 6 addressability.  Our asm101 assembly raised NONE of them.
  Unexamined; could be asm101 handling sector-6 addressability differently.

### [2026-08-24] Target: [HANDOFF-yaGPC2-MEDS.md]
- TOOL POLICY (user-stated, standing).  Don's `asm101` and `halsc` must NOT be
  used for builds -- only for extremely temporary diagnostics.  `asm101` is a
  REIMPLEMENTATION (`exec python -m asm101`, package in nsts-sdl-dps/src/
  asm101); the official assembler is ~/git/virtualagc/ASM101S/ASM101S.py (also
  ASM101Sa).  `halsc` is a WRAPPER driving the real HALSFC pipeline (PASS1 ->
  FLO -> OPT -> AUXP -> PASS2), but a wrapper exists precisely because its API
  differs from the official compiler, so end-user write-ups cannot be based on
  it either.  Drive HALSFC directly.
- ASM101S.py usage that works: run from ~/workspace/PFS/OI340600 with
  `--library=MLIB80 --tolerable=8 --object=OUT/M.obj SSSRC/M.asm`.  Only MLIB80
  is needed (it has the MACROFILES.txt index; SSSRC and INCL80 do not, and do
  not need one).  Default --tolerable is 7; FCMBOOT's header documents expected
  severity-8 errors, hence 8.
- PHASE01 REBUILT with the official assembler.  FCMBOOT 5920, LOADTBL 320,
  FCMSSLPT 2400 bytes -- byte-for-byte the same SIZES asm101 gave.  Relinked:
  same three sections at the deck's OVERLAY addresses, 0 undefined.
- asm101 vs ASM101S, measured with the OFFICIAL objDump.py --data:
  1. ESD ORDERING differs -- ASM101S iterates Python `set`s.  Sorted, the ESD
     sets are IDENTICAL.  RLD `R=` indices differ only because they name ESD
     entries by position (R=2 vs R=8 for the same symbol).  Not a defect.
  2. END-record tool stamp: objectWriter.py writes "ASM101S 0.00"; asm101
     writes its own.  Accounts for the whole FCMSSLPT delta.  Not a defect.
  3. A REAL CONTENT DIFFERENCE: asm101 emits C9FB in three halfwords where
     ASM101S emits 0000 -- C9FB being the AP-101S IPL background fill for hw
     0x00000-0x1FFFF, i.e. a LOADER pattern appearing inside an object file.
     In the linked PHASE01 image this is the entire delta: 6 bytes of 65024,
     at hw 0x0023B, 0x0024B, 0x00741.  ASM101S is the reference; treat
     asm101's C9FB as the deviation.
- CORRECTION recorded against myself: I reported "TEXT records byte-identical"
  after md5-ing objdump's TXT record HEADERS (address + length), which do not
  include the data.  They were not identical.  Compare with `objDump.py --data`
  (the official dumper), not record headers.
- objcanon.py (~/git/virtualagc/ASM101S/objcanon.py) is THE tool for comparing
  AP-101S object modules, and supersedes byte-diffing them.  It decodes the
  80-byte card image, re-expresses every record that cites an ESD id by the
  NAME that id denotes, and sorts -- so modules that MEAN the same compare
  equal.  Needed because ASM101S.py holds ENTRY/EXTRN symbols in Python SETs,
  whose iteration order is randomised per process: its own header records that
  between 174 and 181 of 271 OI340600 objects differed run-to-run on that
  account alone.  Usage: diff <(objcanon.py a.obj) <(objcanon.py b.obj)
- Re-ran the PHASE01 comparison through it.  Canonical diff lines, asm101 vs
  ASM101S:  FCMSSLPT 0,  LOADTBL 2,  FCMBOOT 6.  So the ESD-ordering and
  END-stamp noise I chased by hand vanishes, and only two real things remain:
  1. THE BLANK-END FALSE POSITIVE.  objcanon does
       elif typ == "END": sd.append(("END", be(body[1:4]), be(body[10:12])))
       out.append("END addr=%d sect=%s" % (e[1], named(e[2])))
     A bare END leaves those fields EBCDIC-BLANK, so be() reads 0x404040 =
     4210752 and 0x4040 = 16448, printing `END addr=4210752 sect=?16448`.
     That is objcanon decoding spaces as integers, not a defect in ASM101S --
     objectWriter.py's writeEND(f, None, None, ...) deliberately writes no
     entry point.  It is LOADTBL's ONLY canonical difference and 1 of
     FCMBOOT's 6, i.e. a false positive on essentially every module.  A guard
     printing "END (no entry point)" for blank fields would remove it.
     Wrinkle: asm101 is inconsistent -- blank form for FCMSSLPT, but
     "END addr=0 sect=<NAME>" for FCMBOOT and LOADTBL.
  2. The C9FB-vs-0000 content difference already logged (3 halfwords).
- Queried peer session ASM101S-port about (1) the blank-END rendering, (2)
  which of C9FB/0000 is correct, (3) the four expected IEV072 severity-8
  sector-6 errors that NEITHER assembler raised, and (4) whether objcanon is
  meant for cross-assembler use or only ASM101S-vs-ASM101S.  Reply pending.
- ASM101S-port answered all four, and I verified each rather than relaying.
  1. BLANK END: confirmed a real objcanon bug, now FIXED upstream (objcanon.py
     line 108 prints "END (no entry point)" when addr==0x404040 and id==0x4040).
     BUT its prediction that LOADTBL would then compare clean is WRONG, and the
     counts are unchanged: FCMBOOT 6, LOADTBL 2, FCMSSLPT 0.  The fix corrects
     the ASM101S side only; asm101 really does write `END addr=0 sect=<NAME>',
     so a difference is still reported -- correctly.  The finding is
     REATTRIBUTED, not removed: asm101 INVENTS an entry point.  ASM101S is
     right, per commit 105ad9afb -- the old code wrote an arbitrary member of a
     Python SET into END (FIOCBLKS came out 1196/2120/316 on three runs) and
     the value reached the linked image; every module writes a bare END, 702 of
     702 across OI340600/OI301700/RUNASM.  asm101's own inconsistency (blank
     for FCMSSLPT, invented for FCMBOOT and LOADTBL) is the tell.
  2. C9FB: all three halfwords are FULLWORD ALIGNMENT PADDING; zero is correct.
     Verified in the listing: `LPS X'0014'' occupies 0x239-0x23A and
     `FCMBMSCA DS 0F' lands at 0x23C, so 0x23B is the gap; likewise 0x24B
     (after `#WAT 0', before `FCMBMMRT DS 0F') and 0x741 (between FCMBCSER
     `DC H'0'' at 0x740 and FCMBBUSM `DC F'0'' at 0x742 -- 0742 confirmed by
     its own references).  asm101 initialised its CSECT image with the loader's
     IPL fill and dumped padding the source never asked for.  RUNTIME IMPACT
     NONE: 0x23B follows an LPS and 0x24B a WAT (both transfer control), and
     0x741 lies between two data constants nothing addresses.
  3. IEV072: a MISSING DIAGNOSTIC, not a wrong value.  The four are
     `DC Y(sym+X'8000')', and Y-type is 2 bytes (-32768..32767), so 0x8180,
     0x837E, 0x847E, 0x857E all overflow -- which is what IEV072 reported; the
     original truncated to the low 16 bits, the high bit BEING sector-6
     addressability, i.e. the wanted pattern.  VERIFIED in our listing: 8180,
     837E, 847E, 857E at lines 1667/1715/1716/1717.  ASM101S simply omits the
     Y-type range check.  Log as an ASM101S gap, not a build problem.
  4. objcanon is fine cross-assembler (written for ASM101S-vs-itself and for
     the C port vs Python, but it decodes standard OS/360 format and re-keys by
     name).  CAVEAT TO REMEMBER: it normalises ESD ordering and record order
     and NOTHING ELSE, so any other legitimate representational difference --
     alignment padding exactly -- shows through.  Do not read "canonical
     difference" as "semantic difference" without looking at what it is.
  Also confirmed incidentally: hw 0x037E/0x047E/0x057E read FFFF in the linked
  image, independently corroborating that FCMPTAD1/2/3 are unstamped DC H'-1'.
- `make test` FIXED: it was one recipe line per stage, so make stopped at the
  first failure.  test_debugger.sh fails on four disassembly-format fixtures,
  which meant the ENTIRE 17-test unit suite behind it never executed -- the
  target had been silently reporting on a fraction of itself, and no unit
  regression could have been caught.  Stages are now collected and reported
  together at the end; exit status still means "everything passed".  Verified:
  all six scripts plus all 17 unit tests plus example_gpcops_paced_run now run,
  and the summary names the four genuinely failing stages (test_debugger.sh,
  test_cpu_instr_exec, test_iop_bce_exec, test_iop_msc_exec), all pre-existing.
- CAVEAT ON THE READY DISCRETE, stated plainly: it is a PROXY, not the real
  signal.  On real hardware READY is a line driven BY the mass memory; here it
  tracks whether our own bus controller is running.  The two coincide only
  while the BCE stays busy for the duration of the MMU's work -- if the MMU
  were still positioning after our BCE went idle, READY would rise early.
  Sufficient for FCMBOOT, which only needs to see busy-then-ready.  True
  fidelity would require the MMU to report its own state, i.e. MMU-side work
  and a protocol change.
- DISCRETES FRAMEWORK BUILT (user confirmed Don has nothing in place).
  Branch `yagpc2-discretes` in ~/donschmidt/nsts-sim-gpc, one commit off
  origin/main, 6 files, +417/-11.  NOT PUSHED -- PR text awaiting review at
  scratchpad/PR-discretes.md.
  * com/discretes.coffee (new): wire format, 4x16-bit words -- op(SET=1/
    RESET=2), register(A=1/B=2), 32-bit mask in two halves, IBM numbering.
    Follows Don's #1343 plan verbatim: set/reset BIT messages, not whole
    words, so devices owning different bits of one register coexist.
  * com/bus.civet: _gpcDiscretes on port 6980.
  * mmu/mmu.coffee: @busy was declared in reset() and NEVER ASSIGNED -- made
    real, with an in-flight-operations count so the line stays down across a
    write awaiting data.  MM1 owns IBM bit 6, MM2 bit 7.  Publishes on change
    plus a 250 ms heartbeat (opts.discreteRepublishMs; 0 disables).
  * gpc/ap101.coffee: subscribes, applies set/reset to regDiscreteInA/B.
  * com/lru.civet: REQUIRED BUG FIX.  Bus.onReceive hands (cbObj,busID,msg,
    remote) unbound, but _setupBuses passed @recvBus with no cbObj -- `this`
    was the Bus and arity off by one, so the first datagram on a bus with no
    handler threw on this.busRecvCB[undefined].  Unreachable until the MMU
    gained a second bus.  Also dropped a per-message console.log.
  * test/test_discretes.cjs (new): 25 checks, all pass.
- yaShuttle/discretePanel/ (new, ours): discretes.py (same wire format in
  Python) + discretePanel.py (Tk checkboxes/radios for the crew switches,
  GPC ID, BFS engage, CRT select; observes device-driven bits; republishes
  every 250 ms).  Python encode is BYTE-IDENTICAL to the MMU's output
  (0001000102000000 for SET MM1 READY), verified against captured traffic.
- VERIFIED: on the wire with --reply-delay 600, READY drops, stays down
  across two heartbeats, returns 600 ms later.  End to end, a Python publish
  moved a running GPC's regDiscreteInA 0x0a000000 -> 0x48000000 (STANDBY on,
  MM1 READY off, untouched IPL-source bit preserved).
  test_floatIBM/test_meds_deu/test_mmu fail on stock origin/main too.
- MISHAP TO REMEMBER: `git stash push <paths>` then `git stash pop` in
  nsts-sim-gpc left the changes in the INDEX with the WORKTREE reverted to
  HEAD -- looked like total loss.  Recovered with `git checkout-index -f`.
  Check `git diff --cached` before believing work is gone.  That repo also
  holds a pre-existing stash `af9c4b9 WIP on main: gpc: HAL error-handler
  dispatch and channel-input fixes` that is NOT ours -- left untouched.
- yaGPC2 NOW SUBSCRIBES to the discrete bus (--discretes, default off).
  src/discretes.c/.h: multicast receiver on 239.255.1.1:6980, same four-word
  format as com/discretes.coffee and yaShuttle/discretePanel/discretes.py.
  iop.c's iop_discrete_in_a()/in_b() overlay it: a bit somebody PUBLISHES
  beats the locally derived value, a bit nobody publishes keeps it.  So a
  real mass memory takes over READY once attached, and a run with nothing
  attached still works off the BCE-derived proxy.
  * Poll happens ON THE READ, from the READ DISCRETE INPUT PCIs -- exactly
    when the value must be current, and the flight software polls those in
    tight loops while waiting.  No thread, no loop changes.
  * Per-BIT staleness (DISCRETES_STALE_SEC 1.5s, YAGPC_DISCRETES_STALE_SEC
    overrides).  Per bit, not per register: a crew panel republishing the
    switches must not make a departed mass memory's READY look fresh.
    Without it a publisher killed mid-transfer strands READY low forever.
  * Makefile: IOP_TEST_DEPS and IOP_DEPS both gained discretes.c + compat.c,
    since iop.c now references them -- test_cpu_ea caught that immediately.
- VERIFIED: yaGPC2 --discretes reported "2 message(s) applied" against a live
  publisher; test_iop_discretes gained a networked overlay case (published
  READY beats the derivation, published STANDBY reaches the register, an
  unpublished bit keeps its local value, and closing gives the derivation
  back).  Skips rather than fails if the socket cannot open.  Unit suite back
  to exactly the 3 pre-existing failures.
- Made the discrete path WATCHABLE, which is what "see it in action" needed.
  * YAGPC_DISCRETETRACE=1 prints each discrete that CHANGES a register, with
    the bit named ("HALT", "MM1 READY", "BFS engage 1"...).  Only changes, so
    the publishers' 250 ms heartbeat does not drown it.
  * run.c now also drains the bus every 1024 steps.  Polling had been purely
    read-driven (iop.c, on the READ DISCRETE INPUT PCIs) which is right for
    freshness, but an image that seldom reads discretes let datagrams pile up
    between reads and showed NOTHING under the trace while switches were being
    thrown -- so the demo appeared dead when it was working.
  * Long-running invocation for a live demo (from the MEDS-era flags):
      YAGPC_DISCRETETRACE=1 ./yaGPC2 run --discretes --power-on \
         --real-time --rt-factor 1 --max-steps 0 --rt-idle-timeout 900 IPL.fcm
    Verified against a publisher: HALT set/cleared, STANDBY set/cleared, RUN
    set, BFS engage 1 on register B -- all six transitions traced.
- TWO SELF-INFLICTED WASTES worth remembering:
  1. `timeout N cmd | grep` LOSES ALL OUTPUT when the timeout fires -- the
     project rule says exactly this and I did it anyway; the first live demo
     looked like a total failure and was actually working.  Redirect to a file.
  2. Tool output is NOT reliably shown to the user.  Two drafts were "delivered"
     via Write + a file path and the user never saw either.  Outward-facing text
     must be pasted into the reply itself.
- Trace prints only on CHANGE, so a RESET of a bit already 0 prints nothing --
  looks like a miss but is correct; the shadow state starts at 0.
- GPC MODE SWITCH (HALT/STBY/RUN) now modelled, as the user asked: not as a
  discrete the software reads -- FCMBOOT never tests those bits, the whole
  module mentions them only in one comment -- but as the RESET LINE it is,
  carried on the discrete bus so its state is KNOWABLE to yaGPC2 instead of
  being implicit in a CLI flag.  PASS User's Guide 2.3 is explicit: 3.1 HALT
  = "hardware RESET controlled state.  No software can be executed"; 3.2 STBY
  "entered from HALT ... causes the hardware to be released from the RESET
  state giving control to the software.  If IPL occurred, control will be
  given to the Bootstrap Loader program."
  * run.c: mode_switch_held() reads discrete A bits 0/1/2, holds the CPU out
    of execution entirely while HALT is asserted, and on the HALT->STBY EDGE
    calls cpu_reset() -- reloading the PSW pair from the System Reset vector,
    which is what hands control to FCMBOOT.  The edge matters, not the level.
  * Backward compatible: nothing publishes those bits by default, all three
    read zero, no position asserted, machine runs exactly as before.
  * VERIFIED end to end from a separate process:
        MODE: HALT; CPU held in reset
        MODE: HALT -> STBY; reset released, starting at 0x0014b
    0x14b is FCMBMOVR, exactly where FCMBSYRS (PSA 0x0014) points.
- CORRECTED MYSELF twice here, both worth keeping:
  1. I ran FCMBOOT with --power-on and got silence, then called it a puzzle.
     It was correct: FCMBOOT's power-on vector (PSA 0x0004) is address 0000
     with the WAIT STATE BIT set -- at power-on it deliberately parks.  Only
     System Reset (0x0014 -> FCMBMOVR) starts the bootstrap.  Use --ipl.
  2. I called the stalled 2-second delay a yaGPC2 "bug".  It is not.  The
     POO makes Load/Start/Stop Counter 1 explicit ICR functions, so counters
     do not free-run; FCMBOOT reads the PC1 clock without ever starting it,
     assuming something already did.  That something is the firmware IPL
     (Table 2-2 step 10, "GPC IPL - P/R ... Bootstrap loader read in from
     MMU"), which we do not emulate.  Same missing microcode as the tape
     load, showing up a second way -- not a defect in our CPU.
- FCMBOOT still stalls in that delay: verified at 300,000 steps it visits
  only 000155/000156/000157/000159 with R06 stuck at 62 and R05 unchanged.

### [2026-08-25] Target: [HANDOFF-yaGPC2-MEDS.md]
FCMBOOT now RUNS.  Where it gets to, and the one thing stopping it.

- SEQUENCE ESTABLISHED, all verified by trace:
  1. `--ipl` takes the PSW pair from FCMBSYRS (PSA 0x0014) -> FCMBMOVR at
     0x014B.  (--power-on is WRONG for this: FCMBOOT's power-on vector at
     PSA 0x0004 is address 0000 with the WAIT STATE BIT set -- at power-on
     it deliberately parks.  That is why an earlier --power-on run was
     silent; nothing was broken.)
  2. Starts the watchdog (PC with X'8804').
  3. Clears its 2-second mode-switch settling delay in ~1,285,000 steps,
     now that --ipl leaves counter 1 running (commit b292bb8a6).
  4. UNPROTECTS the sector-6 receiving area (ISPB M1=1, 740 fullwords,
     R5 = FCMBMVLT = 0x05C8 stepping -2), MVHs its own 1864 halfwords up
     there, re-protects (ISPB M1=3), and LPSs into sector 6.
  5. Executes exactly ONE instruction there -- `LR 1,2` at 0x30180 -- and
     stops.
- THE BLOCKER, precisely:
      INT  old=0070 new=0074  atNIA=30181  newPSW=00000000
  0070/0074 is the INSTRUCTION MONITOR -- the "executing out of
  unprotected storage" interrupt.  FCMBOOT's own vectors are deliberately
  wait-state PSWs (FCMBC1N at 0x64: address 0000, and 0x66 = X'0002'
  "... WAIT STATE"), so any unexpected interrupt halts the machine.  Hence
  exit 0 and silence: run.c treats stopReason "wait state" as a normal
  ending and prints no ERROR (batchrunner_report_stop).
- WHAT IS RULED OUT: memory content is fine.  Watchpoints show the MVH
  correctly wrote 0x30180=19e2, 0x30181=ecf3, 0x30185, 0x30199, 0x301ff,
  0x302ff -- all over C6C6 fill, all correct.  Clock 1 is not the culprit
  either: PSA 0x00B0 = 0xFFFF so counter 1's period is ~71 minutes.
- WHERE TO LOOK NEXT: why sector 6 is still unprotected at 0x30181 after
  FCMBOOT's own re-protect loop (0x179-0x17d).  One unexplained
  observation to start from: at step 1285000 the dump shows R02=01800000,
  i.e. WITHOUT the X'8000' sector-6 bit that FCMBRSPW (=0x8180) carries
  and that the source comment calls "STARTING ADDRESS WITH HIGH BIT ON TO
  USE SECT 6 BSR AND DSR".  If the re-protect loop's EA lost that bit it
  would have protected sector 0, not sector 6 -- but the MVH plainly did
  reach sector 6, so the two do not yet add up.  DO NOT trust this
  paragraph as a diagnosis; it is a lead, not a conclusion.
- TAPE IS BUILT AND VALID: scratchpad/tape/mmu.mmv, 1085 blocks /
  1,115,412 bytes, written by mmu2mmv from our own CON80 + phase libs and
  read back cleanly by Don's own `mmu ls`.  Phase 10 (GPCIPL) is on it at
  2/4/3/0 .. 2/4/4/22, 55 blocks.  Still NOT on it (mmu2mmv does not
  generate them): MMDIR at 44000, and FMAIPL2 at 44500 (the bootstrap
  copy).  And FCMPTAD1/2/3 inside FCMBOOT remain the FFFF "never mass
  memory built" sentinel.
- USEFUL MECHANICS LEARNED:
  * Breakpoints match the FULL address including sector (0x30180), but the
    hit message formats only 4 hex digits, so it prints "0x0180".  That
    cost me a wrong conclusion.
  * A "wait state" stop exits 0 and prints NOTHING without --trace.
    Silence is a result, not a failure to run.
  * YAGPC_INTTRACE=1 prints interrupt dispatches; it is what identified
    the Instruction Monitor in one line after a lot of guessing.
  * `timeout N cmd | grep` loses ALL output when the timeout fires.  I did
    this THREE more times tonight.  Redirect to a file.
  * The Bash tool's own default timeout is 2 minutes regardless of the
    `timeout` given to the shell; long runs need the tool timeout raised.
- INSTRUCTION MONITOR SOLVED, and it was OUR BUG, in MVH.  exec_MVH wrote
  back `destAddr << 16` -- the EXPANDED destination.  destAddr is 19 bits
  after expansion, so the shift overflowed and threw the sector away:
  FCMBOOT's move into sector 6 left R2 = 0x01800000 where the source put
  0x81800000, destroying the X'8000' "use sector 6 BSR/DSR" bit.  FCMBOOT
  then re-protects its relocated copy with `ISPB 3,0(R5,R2)`, so the
  protection landed on SECTOR 0.  Jumping into sector 6 therefore executed
  out of unprotected storage -> Instruction Monitor -> its own wait-state
  vector -> silent halt after one instruction.
  The POO settles what MVH should do: "will not modify the DSR", and "the
  count in R1 is modified [to] the number of halfwords remaining to be
  moved" -- the COUNT, not the address.  Necessarily so: MVH is
  interruptible, copies from the end backwards, and restart works only
  because the address still points at the start.  Fixed to
  `r1val & 0xffff0000u` (commit 10eec897a).  No fixture change:
  test_cpu_instr_exec is 111192/111358 with AND without.
- WITH THAT FIXED, FCMBOOT RUNS ITS WHOLE LOGIC.  Verified by breakpoint:
  0x30181 and 0x30185 execute; it does NOT take the "NO MASS MEMORY" wait
  at 0x30199; it reaches 0x3019d "SAVE THE BCE NUMBER" (so the MM1
  IPL-source discrete is read correctly); enables BCE transmitter
  (X'8504'), receiver (X'8508') and processor (X'8720'); loads the max
  timeout; then walks the three mass-memory areas at 0x301c4.
- IT STOPS FOR THE RIGHT REASON.  At 0x301ca it does `LH R4,0(R0)` on the
  area's phase table and branches away at 0x301cb.  Every table is the
  FFFF "THIS AREA HAS NOT BEEN MASS MEMORY BUILT (DOESN'T EXIST)"
  sentinel, so after three areas it lands in FCMBSSM3, the documented
  give-up wait state.  PROVEN by patching hw 0x037E from FFFF to 0001:
  execution then goes PAST 0x301cb to 0x301cd and 0x301d3, reading the
  load-block count and starting MM address.  (It stops before @SIO
  because the rest of that probe descriptor was deliberate garbage.)
- SO THE ONLY REMAINING BLOCKER IS THE PHASE TABLE.  Stamp FCMPTAD1 with a
  real descriptor -- 3-hw phase descriptors (index to 1st load block,
  number of load blocks, MM address of 1st LB) then 3-hw load-block
  descriptors (MM address; protect/reserve/sector flags; length in hw),
  per FCMBOOT's own prolog -- and it will start issuing MMU commands.
  The tape to point it at already exists: scratchpad/tape/mmu.mmv, with
  GPCIPL at 2/4/3/0.
- PROBE TECHNIQUE THAT PAID OFF, worth reusing: breakpoints on SECTOR-6
  addresses (0x30000+offset) to bisect where execution diverges.  Two
  traps: the hit message prints only 4 hex digits so it LOOKS like a
  sector-0 address, and probing an address that is the SECOND halfword of
  a 2-halfword instruction never hits (0x1c0 is inside the instruction at
  0x1bf).  Take instruction starts from the listing, not round numbers.
- TOOLCHAIN UPDATED to Don's latest, and our IPL build reworked onto it.
  nsts-sdl-dps was 7 commits behind on master (12 from the branch we sat
  on); now at 0846b59.  nsts-sim-gpc origin/main advanced 0e275b1 -> 04b2cc4.
  * 7fff229 lnk101: carry store-protect ranges into .sym.json
  * 0846b59 tools: union the store-protect map into the composed image
  Together these OBSOLETE tools/add_store_protect.py, which existed only
  because mmu2fcm's unionSym never carried storeProtect across.  Deleted.
  The real map honours PROT ranges and per-csect marks: phase 10 gets 9
  halfword ranges / 27,275 hw, where ours was a blanket section sweep its
  own docstring admitted was "not what the linker would emit".
  * tools/build_ipl_fcm.sh rewritten to the composition route Don's own
    tools/mkfcm.sh uses: relink the phase with a current lnk101 (--lib +
    --json-symbols), then mmu2fcm --config IPL --phases 10
    --stamp-checksums.  mmu2fcm emulates the loader (fill, load blocks,
    overlay) and emits a whole 512K-halfword memory image, not just the
    loaded extents.  NOTE it needs PHASE02.lib present: phase 10's parent
    Z1 pool is resolved from it.
- RESULT, measured: our image is 1,048,576 bytes and differs from the
  reference IPL.fcm in SIX BYTES -- four halfwords in FCMINSSL at 0x0735E,
  reference 832A 0006 / A32A 0006 vs ours 8000 0000 / A000 0000.  Those
  are the two unrelocated FIOMUWB2 address constants; FIOMUWB2 lives in
  DEUIPLCP, which phase 2 builds as an OVERLAY.  Nothing else differs.
- RETRACTED: I called Don's build "canonical".  That was authority, not
  evidence.  What is defensible is that his route goes through mmu2fcm,
  which MODELS the loader chain, where ours linked phase 10 directly and
  leaned on the CON80 deck for placement.  Neither has been checked
  against an original-build artifact, and the reference IPL.fcm is his
  output too, so agreeing with it is not independent confirmation.
- gpc STILL HAS THE MVH BUG: none of the three new commits touch it,
  `t.r(v.x).set32((destAddr << 16) | 0)` is live at cpu_instr.coffee:5461.
  JS bitwise ops are 32-bit too, so the same overflow applies.  a7c2b7e
  fixed BCT (branch address computed before R1 is decremented) and @LAR
  (iop.coffee bceCompanionCommand); CVFX omitted, as he said in #27.
- --stamp-phase-tables does NOT help our blocker: it covers #PFCMGPT,
  #PCDCPHA and FCMG3DAT -- the SSL's in-core tables -- not FCMPTAD.
  FCMBOOT's own IPL bootstrap table is still ungenerated by any tool.

### [2026-08-25b] Target: [HANDOFF-yaGPC2-MEDS.md]
FCMBOOT NOW READS THE TAPE.  One thing left: the load-block checksum.

- READ DON'S NEW COMMENTS (12 commits on nsts-sdl-dps).  Relevant ones:
  * 7fff229 lnk101 carries store-protect into .sym.json; '#R', the
    compiler's REMOTE data csect, joins the unprotected prefixes ("it was
    classing as code, so a program could not write its own REMOTE array").
  * 0846b59 mmu2fcm unions the map into the composed image.
  * 54cd372 mmubuild grew the DIRECTRY/DMMD pass it had been discarding.
    CHECKED for our blocker: the only DMMD directories in the OI340600
    cards are SMARDD2A/SMARDD4A.  FCMPTAD is NOT among them, so that pass
    does not stamp FCMBOOT's table either.  Second independent
    confirmation that nothing generates it.
  * 608a029 lnk101 relocation recording, --lib-dir, --repair-manifest;
    TEXT extents end at any gap; generated stacks emit C6C6 not zeros.
  * 8fd775f cksstamp (new) re-stamps TAPE load-block checksums after the
    UPF/I-load patch chain.  Not our case (we have no patches) but it
    states the rule: the slot is "(0000, sum16 of the block), summed over
    the block as written to tape".
- NEW TOOL: tools/stamp_ipl_phase_table.py.  Builds FCMBOOT's IPL phase
  table and stamps it into a PHASE01 image at FCMPTAD1/2/3 (0x37E, 0x47E,
  0x57E -- confirmed from the sym.json symbol list).  Layout from the
  prolog AND from the code that reads it (LH R4,0(R0) / LH R5,1(R0) /
  LH R6,2(R0) / LA R2,0(R4,R0)): four 3-hw phase descriptors for phases
  10, 2, 13, 3, then 3-hw load-block descriptors in the same order.  The
  LB descriptors come from mmbstamp.LoadBlock.words(), which already
  emits exactly FCMBOOT's documented bit layout (bit 0 protect, bits 4-7
  always 0110, bits 8-11 sector) -- borrowed, not reinvented, so the IPL
  table and the SSL's #PFCMGPT cannot drift apart.  135 halfwords used of
  256 per area; per-area MM addresses differ (area 1/2/3 phase 10 =
  0x2260 / 0x22C0 / 0x03BE).
- RESULT: FCMBOOT gets all the way to the bus.  With the table stamped,
  every breakpoint from 0x301cb through 0x302b6 hits, INCLUDING @SIO at
  0x3023e.  Against a real MMU serving our own tape it issues the full
  sequence -- the MMU logs 6x POSITION, 6x EXTENDED_BLOCK, 6x READ, 6x
  BITE_STATUS, zero faults, zero dropouts (5 load blocks + 1).
- AND THE DATA IS CORRECT.  Watchpoint: hw 0x01000 changed 0x0000 ->
  0x8000 during the transfer, and the composed IPL image holds 0x8000 at
  that exact halfword.  The tape -> bus -> main storage path works.
- THE ONE REMAINING FAILURE: the load-block checksum.  Breakpoints prove
  it: 0x30332 (checksum loop) HIT, 0x3034E ("CLEAR GOOD READ TO SHOW
  ERROR") HIT, 0x30352 (the pass path) NEVER.  So every block is read and
  then rejected, FCMBGRD is cleared, all three areas are tried, and it
  lands in FCMBSSM3.
  Ruled out so far:
   * The arithmetic matches.  FCMBOOT sums indices 0..length-2 (BCT loop
     from length-2 down to 1, then index 0 at 0x346) and compares against
     index length-1.  mmu2mmv sums 0..length-3 and stores at length-1,
     writing 0x0000 at length-2 -- so the extra term FCMBOOT adds is zero
     and the two agree.
   * Not a stale tape: rewrote mmu.mmv from the relinked libs (the old one
     WAS inconsistent -- I had relinked PHASE10.lib after writing it) and
     the failure is unchanged.
   * Not queue overflow: with --block-delay 8.2 (the real ~8.2 ms per
     512-hw block, and mmu.coffee's own constructor default, though the
     CLI defaults to 0) there are ZERO drops.  Without it the framer's
     16384-word queue overflows -- phase 10 is 27,292 hw.
   * Not the discretes: rerun with --discretes and the MMU publishing (24
     ready-off / 24 ready-on transitions observed) behaves identically.
  NOT ruled out, and where I would look first: whether FCMBOOT checksums
  before the whole block has landed.  LB1 is 15,394 hw, which is NOT a
  whole number of 512-hw tape blocks (30.07), yet mmu2mmv's own comment
  says "a load block is a whole number of tape blocks".  Worth checking
  that assumption against the merge rule before suspecting the transfer.
- Phase 10's five load blocks, for reference:
      start=0x00000 len=15394 prot=1   words=(0000,8600,3C22)
      start=0x03C22 len= 9632 prot=1   words=(3C22,8600,25A0)
      start=0x06DC0 len=  502 prot=0   words=(6DC0,0600,01F6)
      start=0x06FBC len=  994 prot=1   words=(6FBC,8600,03E2)
      start=0x07C00 len=  770 prot=1   words=(7C00,8600,0302)
- REPO CHECK: nsts-sdl-dps advanced 0846b59 -> b14293b, but the two
  substantive commits are Don MERGING OUR OWN PRs (#37
  fcmcmp-rld-annotation-halfword, #39 objdump-normalize -- the latter adds
  ibmobjdump --normalize, a canonical object form, i.e. upstream now has
  its own objcanon equivalent).  No new analysis of his to read.
  nsts-sim-gpc origin/main unchanged at 04b2cc4; our yagpc2-discretes
  branch REBASED onto it cleanly, rebuilt, test_discretes still 25/25.
- CHECKSUM HUNT -- narrowed hard, NOT solved.  What is now established:
  * THE TAPE IS RIGHT.  Read phase 10's LB1 back off mmu2.mmv with Don's
    own `mmu get 2/4/3/0 --blocks 31` and applied FCMBOOT's exact rule:
    slot[-2]=0000, stored=D779, computed=D779.  OK.
    (NOTE the address form: `mmu get`/`dump` take t/f/s/b SLASH form,
    NOT the ALLOC card's 42300 -- 42300 silently reads 5/4/1/28, which is
    blank tape.  That cost me a wrong reading.)
  * THE DATA REACHES MEMORY, INCLUDING THE CHECKSUM SLOT.  Watchpoint in
    a clean run: HW 0x03C21 changed 0x0000 -> 0xD779, the exact stored
    value.  Earlier, HW 0x01000 -> 0x8000, matching the composed image.
  * THE COMPOSED IMAGE IS THE WRONG REFERENCE for checksums: its slots
    hold C9FB C9FB (background fill).  Tape LB1 vs composed image differ
    in EXACTLY the 2 checksum halfwords and nowhere else across 15,394.
    The slot is a tape artifact; mmu2fcm does not put it in memory.
  * THE ALGORITHMS AGREE.  FCMBOOT sums indices 0..length-2 (BCT loop
    from length-2 down to 1, then index 0 at 0x346) and compares against
    index length-1; mmu2mmv sums 0..length-3 and stores at length-1,
    writing 0x0000 at length-2, so FCMBOOT's extra term is zero.
  * mmu2mmv PADS each LB to a whole tape block with C6C6 -- so the "whole
    number of tape blocks" comment is about the tape RECORD, not the
    block length.  LB1 is 15,394 hw in 31 tape blocks; the 478 hw of pad
    land past the checksummed region.  That hypothesis is dead.
  * AND YET the clean run takes the failure path: 0x30332 (checksum loop)
    HIT, 0x3034E ("CLEAR GOOD READ TO SHOW ERROR") HIT, 0x30352 (pass)
    never.
  * INSTRUMENTATION CHANGES THE OUTCOME.  With --trace (358 MB) or
    --debug, the breakpoints that hit in a clean run are NOT reached and
    the machine ends in FCMBSSM3 by a different route.  The live-bus run
    is timing-fragile, so the failing moment cannot be inspected directly
    with either tool.  Any future attempt needs a way to observe without
    perturbing -- a targeted trace gate, or a deterministic in-process
    mass memory the way --deu-model stands in for the display.
  BEST REMAINING HYPOTHESIS: a race -- the checksum runs before the last
  words land.  Our MMU publishes READY-on when it hands the datagram to
  the socket, but the words still have to cross UDP and be DMA'd, so
  READY-on can precede the data being in memory.  On real hardware the
  line reflects the transport, by which time the BCE physically has the
  words.  UNPROVEN; the watchpoint shows only that D779 arrives, not that
  it arrives before the sum is taken.
- IN-PROCESS MASS MEMORY BUILT: src/mmumodel.c/.h, --mmu-model <volume>
  (+ --mmu-unit).  Ports mmu.coffee / mmuConf.coffee / volume.coffee into
  C -- same command decode, position model, block sequencing, status
  latching and .mmv volume format -- answering synchronously in the same
  call, no socket, no drops, no pacing.  Unlike --deu-model it takes ONE
  bus and leaves the rest alone (run.c's new bus_router_service), so it
  composes with --bce-network and --deu-model: a run can have a
  reproducible tape AND a real display.
  IT WORKS AND IT IS REPRODUCIBLE: three identical runs, byte-identical
  reports -- 24 commands, 330 blocks read, 168,972 words out.  That was
  the whole point; the networked runs disagreed with themselves.
- WITH DETERMINISM, THE CHECKSUM FELL IN ONE SITTING.  And the transport
  is exonerated: with NO socket involved the checksum still failed, so it
  was never the bus.
  ROOT CAUSE, and it is MINE: PSA 0x00B0 is COUNTER 1's HIGH HALFWORD, and
  it lies inside the region FCMBOOT checksums.  Phase 10's LB1 is
  start=0x00000 len=15394, i.e. 0x0000..0x3C21.  The tape writes FFFF
  there; tick_counter (cpu.c) decrements that cell on every borrow,
  bypassing store protection.  Five borrows separate the load from the
  checksum, so the sum came out five short.
  MEASURED, not inferred: at the compare (breakpoint 0x3034b, reachable
  now that runs are deterministic) R04=D774 against a stored D779, R05=
  0x3C21 = length-1, R06=5 blocks; and `x 0xb0 2` reads FFFA where the
  tape has FFFF.  FFFF-FFFA = 5 = D779-D774.
  PROVED by experiment: suppressing the writeback made 0x30352 -- the
  checksum ACCEPT path -- hit for the first time.  Experiment reverted;
  it falsifies hardware behaviour and is not a fix.
- THE OPEN QUESTION, which needs evidence I do not have.  FCMBOOT reads
  the PC1 clock in SIX places and never starts or stops it, so a clock
  must be running throughout -- including at 0x2C4/0x2C7, after the load.
  But any running counter rewrites 0x00B0 every ~65.5 ms, and a load
  block covering the PSA can then never checksum reliably.  Both cannot
  be true of the real machine.  Candidates, weakest link first:
   1. MY RECONSTRUCTED LB1 IS WRONG.  A sane ground build would not put
      volatile PSA cells inside a checksummed load block.  I derived the
      blocks with mmbstamp.derive_load_blocks, which is written for the
      SSL's #PFCMGPT table, and I flagged the contiguous-layout
      assumption when I wrote the stamper.  This is the most likely
      culprit and the cheapest to test.
   2. Counter 1 is not actually running during the load -- but then
      FCMBOOT's own 2-second delay never expires.
   3. The high-half writeback does not work as cpu.c models it.
  yaGPC2's own --ipl counter-1 arming (commit b292bb8a6) was already
  labelled a MODEL OF ASSUMED FIRMWARE BEHAVIOUR; this is the first
  evidence bearing on it, and it cuts against.
- **FCMBOOT LOADS GPCIPL.**  Breakpoint 0x4713 -- GPCIPL's entry point --
  HITS.  The bootstrap reads the phase off our own tape, checksums it,
  accepts it and passes control.  Reproducible: two runs, 16 commands and
  220 blocks read, identical (down from 24/330, because it now succeeds on
  the first area instead of retrying all three).
- THE LAST BUG WAS OURS, IN THE INTERVAL TIMER, AND THE POO SETTLES IT.
  tick_counter() carried the low halfword's borrow into the high halfword
  UNCONDITIONALLY.  AP-101S POO 2.5.2 (Figure 2-21 / the interval-timer
  text) says it must not:
     "When the low halfword (in the hardware counter) passes from 0000
      [to FFFF] an interrupt occurs which CAN CAUSE the high halfword in
      main store [via] microcode to be decremented by one. ...  [If the]
      interrupt is masked the high halfword will not be decremented by
      [the microcode and the] low halfword continues to count down."
  The high halfwords are PSA cells 00B0/00B1 in low store.  FCMBOOT reads
  GPCIPL's first load block -- 0x0000..0x3C21, which CONTAINS 00B0 because
  GPCIPL supplies its own PSA -- then checksums it with clock interrupts
  masked (its Clock 1 vector is a deliberate wait-state PSW).  Carrying
  the borrow anyway drifted 00B0 five counts from the value the tape had
  recorded, so the sum came out five short and a perfect block was
  rejected.  Fixed: the borrow is carried only when the corresponding
  clock interrupt is unmasked (Clock 1 = PSW mask 0x80, Clock 2 = 0x40,
  the same bits cpu_check_interrupts tests).
- HYPOTHESIS 1 FROM YESTERDAY WAS WRONG, and checking it is what led here:
  my reconstructed LB1 is NOT over-extended.  PHASE10.lib really does
  carry a TEXT extent 0x00000..0x03C1F, so the load block legitimately
  covers the PSA and derive_load_blocks is right.  That left the counter
  model as the only candidate, and the POO had the answer.
- No regressions: the same 3 pre-existing unit failures, and run_all,
  scheduler, rtl and random all pass.
- STILL OPEN: what GPCIPL does once it has control -- the run ends without
  reaching a display load.  That is the next thing, and it is now a
  reproducible experiment rather than a timing lottery.
- **CORRECTION: "FCMBOOT loads GPCIPL" WAS A FALSE POSITIVE.**  I claimed
  it because breakpoint 0x4713 (GPCIPL's entry) hit.  It hit because the
  machine was RUNNING AWAY THROUGH ZEROS from address 0 and slid through
  0x4713 on the way -- the trace shows `004713: 0000  A 0,X'0000'(0)`,
  i.e. it executed a zero halfword there, not GPCIPL's first instruction.
  A breakpoint on an address a runaway traverses proves nothing.  Lesson:
  when a breakpoint "proves" success, check the INSTRUCTION at it.
- WHAT IS ACTUALLY TRUE, and it is still real progress.  With the timer
  fix, FCMBOOT gets all the way through its load sequence and reaches the
  handover: at 0x30239 it executes `LPS X'0014'` -- its own "ISSUE THE
  SYSTEM RESET" -- which is how it gives control to GPCIPL, by loading the
  PSW from PSA 0x0014 where GPCIPL's own reset vector should now be.
  The PSW it loads is 0x00000000.  Execution therefore starts at address
  0 and slides through empty store for ~32,000 instructions until it
  reaches FCMSSLPT and hits an invalid opcode: "invalid instruction
  0xc99c at 0x7c3c".  2,707,470 steps, reproducible.
- THE PUZZLE, unresolved.  The tape has the right vector: LB1 carries
  0x0014 = 013F 0011 0008, which is GPCIPL's SRESINTN -> IOPHISAM, and
  the composed IPL image agrees.  But at the moment of the LPS, memory
  holds:
        addr    memory   tape
        0x0004  0000     0235
        0x0014  0000     013F
        0x0044  0000     08A6
        0x1000  8000     8000   <- matches
        0x3C21  D779     D779   <- matches
  So the PSA end of LB1 did not take while the rest of it did.  Ruled
  out: store protection.  iop_write_main16() does enforce it and raises
  External 1 (DMA store protect violation, code 0004) on refusal, and
  YAGPC_INTTRACE reports ZERO interrupts dispatched for the whole run --
  nothing was refused.
  Also unexplained alongside it: breakpoint 0x3034e (checksum FAILURE)
  still hits in this run as well as 0x30352 (pass), so some load block is
  still being rejected.  If LB1's PSA really is zeros in memory while the
  tape has content there, LB1's checksum could not pass -- so the two
  observations need reconciling before either is trusted.  Do that first.
- FCMSSLPT IS being written: memory at 0x7C00 reads 000c 0005, which is
  our own phase descriptor (index 12, 5 load blocks).  So FCMBOOT does
  copy its table there for the SSL, as its prolog says.

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- The "checksum pass and fail both hit" contradiction was not one. FCMBCKSM
  (0x0334) sums each load block in turn and on a mismatch branches to 0x034E
  and EXITS the loop (`B #@LB74`), so one call hits 0x30352 once per passing
  block and 0x3034E at most once. Both firing = "blocks 1..n-1 passed, n
  failed". §2's note read them as mutually exclusive; that was wrong about
  the control flow, not evidence of anything.
- Register state at 0x3034E named the failing block: R6 = blocks remaining,
  R0 = descriptor pointer (0x838A = FCMPTAD1+12, past the four 3-hw phase
  descriptors; 0x848A = same offset into FCMPTAD2). Four calls, three
  failures, then a pass -- FCMBOOT re-read the tape each time (220 blocks =
  4 passes over phase 10's 55).
- Compared memory against the tape directly rather than eyeballing dumps.
  LB1 was byte-perfect INCLUDING the PSA (0x0014 = 013F). The "holes" at
  0x0200/0x3800/0x3C00 recorded in §2 were real tape content, not holes, and
  the PSA zeros seen at the LPS were from a LATER, worse attempt. LB2..LB5
  were displaced by 477/572/581/610 halfwords.
- Cause: FCMBOOT skips a partial block's unread tail by DELAYING over it
  (#DLYI, 2*(639-partial) counts; book says 2 counts = one 33 us word time,
  source says 128 = half a block gap). The model queued whole transfers and
  lost nothing, so the delay skipped nothing. Second halfword of the same
  displacement: FCMBOOT emits a one-hw #RDLI to "CLEAR THE MIA BUFFER"
  (FCMBBLDR+0x18, gated on FCMBMIAC which the partial-block path sets) to
  discard the stale word a delay leaves latched -- with nothing latched it
  ate a live word.
- Fixed in 14a7b7581. All five LBs now match the tape (27,292 hw, 0 wrong),
  the checksum passes first time, and LPS X'0014' hands control to GPCIPL at
  013F/0011. GPCIPL runs.
- Dead end worth recording: a first cut had mmumodel expire words on its own
  ("a word not collected in its window is gone"). Wrong -- an armed receive
  is a DMA that loses nothing, and a BCE gets a slice only every 33 CPU
  instructions (~50 us) against a 33 us bus, so it discarded 41% of live
  data (69,210 of 168,972 words) and the load never completed at all. The
  loss belongs to the delay, which is the only thing that knows nobody is
  listening.
- NEW, open: GPCIPL is now running but taking unrecognized SVCs -- halucp's
  HAL/S SVC intercept is firing on GPCIPL's assembly SVCs (ea=0x0, code=0x0)
  at 0x1153/0x1B57/0x1CDA/0x2DED and it loops. That is the next thread.
- Not verified: the delay-discard applies to every bus, not just the mass
  memory. Correct in hardware (a delay always loses bus data), but the DEU
  path has no test that exercises #DLYI, so a regression there would not
  have shown up. `make test` has the same four pre-existing failures with
  and without the change (test_debugger.sh, test_cpu_instr_exec,
  test_iop_bce_exec, test_iop_msc_exec).

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- MEDS end-to-end attempted with the boot. Measured, not inferred: over
  60,000,000 steps (4,229 s of emulated time) the in-process DEU on bus 6
  logged `commands:0, polls:0, wordsIn:0, wordsOut:0`. GPCIPL never drives the
  display bus, so MEDS necessarily shows nothing. (The MDU's own menus --
  y = SYS SUMM etc. -- are the IDP's local behaviour and work with no GPC.)
- Where GPCIPL actually gets to: NIA 0x1DE7, inside `STMM0010` (0x1DE1), with
  `STMMAIN1` @0x1DEE and `STMWAIT` @0x1DF6 next and R01 = `JOBTABLE` (0x1E84).
  That is the self-test monitor's job-dispatch loop idling, NOT a crash and
  NOT a hang. MMU shows 16 commands but still only 55 blocksRead, so GPCIPL
  issued 12 further mass-memory commands that returned no data blocks.
- RETRACTED, twice over, both from bad method:
  (a) "GPCIPL parks after three SVCs" -- it does not. The quiet period is
      MEMTST22, a DIAGNOSE-based memory test looping 0x077A-0x0795 that walks
      R2 up two halfwords at a time across the whole 512K-halfword space,
      ~19 instructions per step, ~5-6M instructions in total. R2 = 0 at
      2.59M steps, 0x0006F168 at 6M. A 6M-step cutoff lands ~87% through it.
  (b) "the process died / it's gone" -- it was running the whole time. My
      `ps ... | grep` probes were unreliable (one reported 3 instances while
      another reported none, seconds apart), and several `pkill -f` patterns
      matched the tool call's OWN command line, including the heredoc text,
      and killed the launching shell. Use a pidfile; never pkill on a pattern
      that appears in the command issuing it.
- `--size 512` on MEDS works; I wrongly called it swallowed by Electron. The
  display reports device pixels at 2x, so a 512 window measures 1044 across
  and I read that as the 1024 default, which I had never actually measured.
  A 300px test returning 620 settled it.
- PRACTICAL: the CLI paces to REAL TIME by default (--pacing=burst,
  --time-scale 1.0), sleeping so emulated time tracks the wall clock -- 3%
  CPU. For investigation use `--time-scale 200`. It only affects wall-clock
  sleeping, not the emulated clock the MMU pacing depends on.
- NEXT LEAD: GPCIPL's symbols include `SWTCHDKB`, `DEUMODE`, `IPLSELFL` --
  it does have DK-bus and IPL-select code that is not being reached. Worth
  trying the crew panel's MODE switch in RUN (and the IPL SOURCE bits) with
  --discretes, since the real sequence is HALT -> STBY -> IPL -> RUN, and
  checking whether the STM job loop is polling a discrete we never assert.

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- Traced WHY GPCIPL never drives the display. GPCIPL is healthy: it is
  cycling REALEXEC's STMMAIN job dispatcher over minor/major cycles
  (STMM0010 0x1DE1, STMWAIT 0x1DF6 "LET'S CATCH A SNOOZE", JOBTABLE 0x1E84).
  Confirmed by R05 = 0xC8727FE0 at 60M steps == JOBTABLE[8] from
  MLIB80/REALEXEC.asm exactly.
- Jobs run only where SCHEDWRD ("requested jobs") AND JOBTABLE[minor cycle]
  is set. JOBADDR: 0 DEUIPL (a Y(STMWAIT) stub in this build), 3 CM4POLL,
  4 POLLRSP, 5 CM4UPDT, 6 CM4MENU, 7 CM4FMAT, 8 LOADCHK, 10 DBCNTL.
- SCHEDWRD (0x036C2) history, via `--watch 36c2:2 --watch-log`:
    1,905,806  0000 -> 1c20  DMA, i.e. straight off the tape
    2,554,339  1c20 -> 1020  STH at 0x00548  = INIT08     (clears POLLRSP, CM4UPDT)
    6,526,206  1020 -> 00a0  XST at 0x0201f  = POLL30     (clears CM4POLL, sets LOADCHK)
    6,535,940  00a0 -> 0020  XST at 0x02d04  = LOADCHK5
    6,666,468/6,690,729 via BSL1UPTA / BSLRSET6, settling at 0020
  So it ends as 0x00200000 -- bit 10, DBCNTL -- and the display jobs were
  unscheduled by GPCIPL's OWN code, not lost.
- DKBUS (0x03BA1) is NEVER written in 9M steps, so POLL60 is never reached;
  and FAZ2STRT+4 (0x05788), the "SAVE LOC FOR OLDDKB FROM PHASE 1" that
  CM4POLL reads as "LEGAL DKBUS FOR POLLING", stays 0. Nothing ever selects
  a display bus, which is why BCE 6 sees nothing.
- CAUTION on attribution: POLL10/POLL30 are NOT in FAZ2DEU.asm (which has
  only POLL03/05/06/60) -- they are in MLIB80/GPCRTOPT.asm. The early part
  of CM4POLL I first read from FAZ2DEU.asm is a DIFFERENT routine from the
  code actually at 0x201f. Re-read GPCRTOPT.asm before building on this.
- LIKELY ROOT CAUSE, not yet confirmed: GPCRTOPT's POLL30 is headed "HAS THE
  DCP BEEN LOADED INTO CORE" and does `TH DCPLDFL / BNZ POLL60` -- it only
  goes on to select a bus if the Display Control Program is in core. Our
  tape gives GPCIPL nothing beyond phase 10 (MMU: 16 commands, still only
  the original 55 blocksRead), and tools/stamp_ipl_phase_table.py builds a
  table for phases 10, 2, 13, 3 of which only 10 was ever verified. Next
  step is the phase loading, not the display bus.
- Also confirmed: `--watch <addr>:<n> --watch-log` works in the FAST path
  (no --debug), which is the practical way to answer "what wrote this?"
  without paying the debugger's ~4.5K steps/s.

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- The user asked whether a discrete we now DRIVE might have had a different
  default before the panel existed. It did, and it mattered. Register B
  bits 6-7 are not two switches, they are the DEU_ID field: GPCRTOPT.asm
  extracts them with `NHI R3,X'0300'` / `SRL R3,8`, and POLL30 ("IS THE
  DEU_ID 1, 2, 3, OR 4", `LR R3,R3` / `BZ POLL45`) reads zero as "no display
  unit". discretePanel started every toggle broken, so it published
  DEU_ID = 0 and GPCIPL stopped looking for a display bus before choosing
  one. yaGPC2's own DISCRETE_IN_B_DEFAULT is 0x21000000 -- GPC 1 and CRT 1.
  Measured with a headless publisher: CRT field 0 reaches POLL45, CRT field
  1 does not. Fixed in 58bf14106 (DEFAULT_ON).
- GENERAL LESSON worth keeping: a panel's resting position must be the
  position the hardware is in, or running the panel is itself a change to
  the machine. Check every panel-owned bit against the corresponding
  DISCRETE_IN_*_DEFAULT before adding it.
- The fix does NOT reach POLL60: the next gate is `TH DCPLDFL / BNZ POLL60`
  and the Display Control Program is not in core, so DKBUS is still never
  written and the DEU still sees 0 commands over 9M steps. Phase loading
  remains the blocker.
- discretePanel cosmetics (a9a6799c7), all user-requested and approved:
  per-column frames with untitled filler panes so no bare window shows
  between a short pane and a tall one; one fixed-width font via ttk.Style
  with the pad width taken from the widest label in either group, so the
  bit captions form one column; "Publishing on ..." in its own full-width
  pane; ON/OFF rather than ON/off, with "--" still meaning undriven.

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- ERROR 118 "MMU ERROR" run to ground, and it was OURS. GPCIPL's BSL1 was
  reporting a mass memory status error the model had never raised. Watching
  MMSTATUS (0x03660) showed it receiving 0x14A0 by DMA -- exactly the packed
  POSITION word for 2/4/5, (2<<11)|(4<<8)|(5<<5). MMERCKMK is X'F800FFFF',
  so 0x14A00000 & mask != 0 -> ERROR 118 -> BSLRESET, every time.
- Cause: the MIA latch I added with the delay-discard earlier the same day
  was delivered AHEAD of newer traffic. A word actually arriving overwrites
  the adapter buffer; the latch is only what is left when nothing newer has
  come. FCMBOOT's LAST load block ends in a delay like the others, but the
  "CLEAR THE MIA BUFFER" #RDLI is emitted only ahead of a load block that
  FOLLOWED a delay, and LB5 is the last -- so the latched word survived into
  GPCIPL's first BITE STATUS and shifted every later reply by one.
- The measurement that found it: added wordsTaken to the model's report
  beside wordsOut. 28182 queued, 28181 taken -- exactly one of the 22 reply
  words never collected. Without that counter this would have been guesswork.
- Fixed in 82fb09d3b. GPCIPL now gets on with it: MMU commands 16 -> 50,
  blocksRead 55 -> 80, transport 2/4/5 -> 4/4/0, and BSLRQP10 (the success
  path that sets DCPLDFL and reschedules the display jobs) is REACHED where
  it never was. Tape load unchanged, all five LBs byte for byte.
- STILL OPEN: BSLRESET is reached again later and POLL60 still is not, so a
  further failure follows. wordsOut 41026 vs wordsTaken 40666 now -- 360
  uncollected, worth checking whether that is legitimate partial-block tail
  or the same class of bug again. DCPLDFL still never written at 40M steps.
- Method note: the reference mmu.coffee has a busy/@_busyOps state machine
  our model has no equivalent of, and drives READY from it. Suspected but
  NOT the cause here; still an unported difference worth closing.

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- GPCIPL NOW DRIVES THE DISPLAY. End to end: FCMBOOT -> GPCIPL -> BSL1
  loads the DCP -> DCPLDFL set (0000 -> ffff by SHW at 0x02E8C) -> POLL30
  passes -> POLL60 REACHED -> CM4POLL polls the DEU -> the DEU's own
  program load completes ("load complete ... reporting initialized",
  ipled true). Measured on the in-process DEU: commands 6648, fills 2224,
  polls 2215, wordsIn 460207, wordsOut 35350. Against MEDS over
  --bce-network the user sees the mission-time clock ticking on the MDU.
- The second MMU bug (629694ebf): the queue never lost anything, so a bus
  program that took what it wanted from a transfer and stopped left the
  rest queued and every later reply was read that many words late. GPCIPL's
  loader left 360 unread words of a 4096-word transfer, so BSL1 read a
  leftover tape word as the transport position -> ERROR 116 INVALID
  POSITION. Fixed with TWO rules: a new command ends the last transfer and
  its unread stream is dropped (definite, no timing argument), plus a
  block-gap-grace ageing rule for a stream nothing follows.
- LOAD-BEARING DETAIL: only STREAMED words are ever dropped. A reply is not
  paced and so never ages out -- the timing rule alone left two orphaned
  status words at the head of the queue for the rest of the run, and the
  sequence never recovered. `pending N` in the MMUTRACE command log is the
  thing to watch; it must be 0 at every command.
- Both MMU bugs were found by adding counters, not by reading code:
  wordsOut vs wordsTaken exposed the one-word MIA latch leak, and
  `pending` at each command exposed the 360-word tail. Worth reaching for
  first next time.
- STILL OPEN: the MDU shows the clock and little else. Our DEU model
  rejects func-896 fills as "unheadered" (2209 of them) -- those are the
  mission time and MEDS parses them fine, so that is a defect in OUR model
  (timeFills has read 0 throughout), not the cause of the blank screen.
  What GPCIPL actually intends to display at this point is the open
  question. BSLRESET is still reached somewhere too.

### [2026-08-25] Target: HANDOFF-FCMBOOT.md
- WHY MEDS SHOWED ONLY THE CLOCK, and it was not a yaGPC2 bug at all: MEDS
  RETAINS ITS IPLed STATE between GPC runs. Its poll reply, captured off the
  wire (32-byte datagram from :6906), reads
  `0000 ff00 ... c000 0000 2000 2100` -- w0 bit 0 (IPL REQUIRED) CLEAR and
  w12 = 0xc000 (BITE1_ALWAYS_ONE | BITE1_IPL_DONE), i.e. "already loaded".
  GPCIPL therefore skips the DEU load, and the display FORMATS are part of
  that load, so the screen has nothing to draw but the clock. Our in-process
  deumodel starts un-IPLed every time, which is exactly why it saw all 518
  displayFills while the wire saw none. RESTART MEDS BEFORE EACH RUN.
  After a fresh MEDS: POLL 84, TIME_FILL 79, DISPLAY_FILL 4 in 40 s --
  matching the 2026-08-23 reference rate (14 DISPLAY_FILL in ~105 s).
- ALSO REQUIRED, and the reason my first reproduction attempts looked dead:
  GPCIPL needs the MASS MEMORY ATTACHED even when the whole composed
  IPL.fcm is already in memory. `--power-on ... IPL.fcm` alone gives ZERO
  display traffic; add `--mmu-model` and it comes alive. Checked against a
  worktree build of the pre-today commit -- same zero -- so this was never a
  regression from today's work, and the 08-23 session had Don's MMU running.
- Wire format, for the next person: IUA byte + reserved byte + 16-bit words,
  ONE WORD PER DATAGRAM (deliberate, see bcenet_framer.c -- batching was
  tried and broke the peer). Command func is (w0 >> 1) & 0x3ff on the WIRE
  word; deumodel uses (cmd24 >> 9) on the 24-bit internal form. Do not mix
  the two, as I did.
- SELF-CORRECTION worth keeping: I told the user the clock was real GPC data,
  then retracted it on seeing one-word datagrams, then had to un-retract when
  the user pointed out it read 000/00:05:02 -- mission-elapsed, counting from
  IPL, not wall time. The first answer was right. Retracting on weaker
  evidence than the original claim is its own failure mode.
