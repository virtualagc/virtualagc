# yaGPC2 problems.txt — candidate bugs inherited from `gpc`

This is a lead list, not a verdict list. Every item below is either (a)
a bug in `gpc` (and therefore in `yaGPC`, which deliberately ports it
byte-for-byte) confirmed directly against the `gpc` CoffeeScript source
and/or its live behavior, or (b) a discrepancy between `yaGPC` and
`yaHALMAT2` found by running `yaHALMAT2`'s test suite through both,
which needs primary-source triage before assuming either side is wrong.
Section 1 items are the former (high confidence, precise repro steps).
Section 2 items are the latter (real discrepancies, cause not yet
determined). See the closing "Methodology and caveats" section for how
these were found and how to read them.

**Section 8 is different in kind and was added later.** Sections 1–7 were
found by running *test programs*; Section 8 is what running **real Shuttle
flight software against real peripherals** turned up — GPCIPL, the UDP bus
bridge to Don Schmidt's MMU and MEDS, the OI340600 rebuild, and the
OI340700 source recoveries. It carries its own method notes, because that
instrument fails in ways the earlier one does not.

All `gpc`/CoffeeScript line references are against
`/mnt/STORAGE/home/rburkey/git/yaGPC/gpc/*.coffee` (the yaGPC port's
source checkout of `gpc`) as of yaGPC commit `8f06c0e`. All "confirmed
against yaGPC" claims can be re-checked with the `yaGPC` binary built
from that same repo (`cd yaGPC && make`) or against the live JS
reference (`node dist/gpc.js run ...` from the repo root, after `npm
install` + `node esbuild/esbuild.gpc.config.js`).

**Status (2026-07-29): every item in Section 1 and Section 2 has now
been individually triaged, Section 3's "Programming in HAL/S" corpus
has been fully swept and completed, `DEMO.hal` (Section 4) has had its
own sweep, and a full corpus re-sweep run directly against `yaHALMAT2`
(Section 5) has now superseded the old `yaGPC`-as-reference sweep
methodology for good.** All confirmed yaGPC2 bugs are fixed — see the
"Status in yaGPC2" note at the end of each subsection below.
Cross-project findings (both directions) are tracked in a shared
SQLite database, not this file — see
`yaShuttle/yagpc2-yahalmat2-issues.db` and
`yaShuttle/yaHALMAT2/problem-communication-rules.txt` for the
schema/workflow. **As of this writing (2026-07-29) the database has 67
entries: 49 `fixed`, 9 `open` (all currently `yahalmat2`-owned — see
Section 5 for the 7 found by the latest sweep, plus the pre-existing
`multi_item_write_truncated_with_bareword_array_of_matrix` (§4) and
`random_reference_f1_chain_disrupted_by_other_float_ops`, the latter
corrected from `deferred` back to `open` per the standing rule that a
real fix path existing, however substantial, means it can't sit
indefinitely — see §2.6), 7 `not_a_bug` (`ext_double_methodology_artifact`,
`gtbyte_sibling_routines_scale_audit`,
`array_oob_subscript_returns_zero_unconfirmed_guarantee`,
`assortedio_svc_macro_scope_gap`,
`runtime_svc_miscategorized_as_wallclock_nondeterminism`,
`datatypes_repeated_singular_inverse_unstable_result`, and
`write_first_write_inside_do_for_loop_missing_skip` — all "investigated,
confirmed nothing wrong" records kept so the same ground isn't
re-covered), and 2 `suspected` (`yahalmat2_nint_mint_vint_offset_form`,
`yahalmat2_read_line_page_unimplemented` — yaHALMAT2-side watchlist
items with no known triggering HAL/S source yet, not yaGPC2's to chase).
Query the database directly for the full, current list rather than
trusting a stale count here later — this file records *how* things were
found and root-caused, not a live status board.

**Standing policy, established 2026-07-28/29**: `yaGPC2` is now the
authoritative cross-check target for `yaHALMAT2`'s real-hardware
fidelity, superseding the historical `gpc`/`yaGPC` reference (which only
ever achieved partial hex-float authenticity — basic arithmetic only,
never the transcendental/matrix-inversion RTL routines `yaGPC2`
faithfully executes as real compiled AP-101S code). Development is not
considered complete until the two reach parity on numerical results,
including cases where `yaHALMAT2`'s output must now *diverge* from old
`gpc`/`yaGPC` once it also adopts genuine hex-float semantics for
operations `gpc` only ever approximated. Both projects are expected to
clear their own `open` queues before any full corpus sweep is treated as
meaningful — a real, demonstrated concern (see §3's `wildcard_subscript_matrix_write_loses_row_forcing`
finding, which showed a premature sweep can look clean purely because
the corpus doesn't yet exercise a buggy construct, not because of real
parity).

Since the last update: `cindex_not_found_overrun` (the real `CINDEX.asm`
`INDEX()` bug, §2.9's `test_bfnc_char`) is no longer just a documented,
accepted-as-is hardware quirk — it's now **fixed directly in the real,
historical flight-software RTL source**, via a deliberately reversible
mechanism invisible to any assembler but this project's own (see §2.9).
`RANDOM`/`RANDOMG` (§2.6) turned out to be fully deterministic real
hardware, not wall-clock-dependent, and a bit-exact reference
implementation now exists for `yaHALMAT2` to adopt. `130-EXAMPLE_N`'s
long-standing `no_return_function_undefined_behavior_diverges`/
`examplen130_cfor_pretest_hardware_divergence` puzzle (§3.5) is fully
resolved — a documented HAL/S language rule (`DO ... UNTIL` is
post-tested), not hardware-specific undefined behavior. `mmwsnp_vector_forces_newline`,
`read_array_early_termination_stale_iobuf`, and
`integer_exponentiation_overflow_needs_fcos` (§3.1/§3.5) were briefly
mis-filed as accepted non-bugs/deferred items in an earlier pass of this
file — corrected below, and now resolved for real.
`schedule_priority_out_of_documented_range` (§3.5) turned out to be
fixable after all (the "documented range" was implementation-defined,
not a hard textbook-fidelity constraint) and is now fixed. `compool_array_integer_type`
was fixed asynchronously in yaHALMAT2 between two earlier sessions,
discovered only by querying the database — no document report was ever
sent or needed. `test_eron_goto` (§2.1's third example program) turned
out not to be a bug at all — a different, real, faithfully-reproduced
hardware/RTL quirk (register-pair history in `MM14SN.asm`'s singularity
check), fully explained. **Start here** if picking this file back up —
or Section 3/4 if the interest is the HAL/S example corpora
specifically, or Section 5 for the latest full-corpus parity sweep.

**Since the 2026-07-28 sync**: `inverse_singular_matrix_not_detected`
(§2.1/§3.1, id 46) is now genuinely, fully fixed — not the false
retraction logged in an earlier pass of this file. Confidential FCOS
source (`FPMSDERR.asm`, the real SEND ERROR SVC handler) proved the
OS/SVC level never dispatches to a user `ON ERROR` handler for *any*
error; real GOTO dispatch instead works because the compiler emits its
own redundant, statically-known re-check of the error condition
directly in the calling code, which doesn't exist for matrix-inverse
singularity (confirmed by disassembling `$0P`'s real compiled code —
no check follows its call to `MM14S3`). `yaGPC2`'s `try_on_error_dispatch()`
now correctly never dispatches for this one error condition, matching
real hardware (197-P.hal/198-P.hal both now show the identity matrix,
not zero). `datatypes_repeated_singular_inverse_unstable_result` (§3.1,
id 53) is now confirmed `not_a_bug` directly from `MM14SN.asm`'s own
source — the same register-pair-history fragility class as
`test_eron_goto`, not a separate mystery.
`runtime_svc_miscategorized_as_wallclock_nondeterminism` (§2.6, id 54)
is likewise confirmed `not_a_bug` — `RUNTIME()` needs the same missing
real-time task-executive infrastructure §2.7 already accepted as a
scope boundary for `SCHEDULE`/`WAIT`. A full corpus re-sweep run
directly against `yaHALMAT2` (not the frozen `yaGPC` predecessor) is now
in Section 5, under the new standing policy that `yaGPC2` is the
authoritative parity target going forward.

**Methodology note for anyone extending this list**: when comparing two
tools' output, capture and diff stdout and stderr *separately*. Merging
them with `2>&1` produces spurious mismatches purely from interleaving
order, not real discrepancies — this exact false positive was hit twice
during the work that produced this file (once during `yaGPC`'s own
Phase 11 validation, and again while building the sweep behind Section
2 below, which had to be stopped and rerun after the mistake was
caught). Don't repeat it a third time.

---

## 1. Confirmed `gpc` bugs (high confidence, precise repro)

### 1.1 `IOPLocalStore#ls` — missing call parens, crashes real `gpc run`

**File**: `gpc/iop.coffee:54`
```coffee
ls: (bank,word) -> @cp.r(bank*4+word)
```
`@cp` is itself a method (`cp: () -> @storePage[@curPage]`, `iop.coffee:52`),
not a value — this should read `@cp().r(bank*4+word)`. Since almost
every BCE/MSC instruction reaches `ls()` (directly, or indirectly via
`incrNIA`/`setNIA`, which route through `PC()`), this throws `TypeError:
this.cp.r is not a function` on essentially any executed BCE/MSC
instruction, crashing the whole `gpc run` process (no try/catch between
here and the top-level command loop).

**Why nobody ever saw this in typical use**: `IOP.regBusyWait` (the
"is this processor active" bitmask) starts all-zero at reset, and
`IOP#execProcessors()` no-ops for every processor (MSC + all 24 BCEs)
until something explicitly sets a busy bit — a CPU `PC` (Programmed
Control I/O) instruction, or an MSC `@SIO`. No batch `.fcm` in the
existing `gpc/gen/` corpus, and no HAL/S program compiled through the
normal `HALSFC`/`lnk101` pipeline in ordinary testing, happens to do
this — so the crash was latent, not caught, for the whole life of the
`gpc` project until this port went looking for it.

**Reproduction** (hand-assembled AP-101 machine code — no compiler
needed): `/mnt/STORAGE/home/rburkey/git/yaGPC/yaGPC/test/fixtures/iop_msc_sio.fcm`,
built by `/mnt/STORAGE/home/rburkey/git/yaGPC/yaGPC/test/fixtures/gen_iop_msc_sio_fcm.cjs`.
The program: `LHI R1,0x9204` + `PC R1,R0` (sets the MSC busy bit via
`IOP#recvFromCPU`'s `0x92040000` "LOAD MSC BUSY" command), two filler
instructions to let the IOP's round-robin scheduler reach the MSC's
slice, then reads the busy bit back via `0x10040000` ("READ
STATUS4(BUSY/WAIT)"). Run it:
```
node dist/gpc.js run --start 0x10 --verbose --trace --max-steps 10 \
  yaGPC/test/fixtures/iop_msc_sio.fcm
```
from the `yaGPC` repo root — crashes with the `TypeError` above, from
inside `IOP2.execProcessors` (the MSC's first slice, fetching and
executing a real `@SIO` instruction pre-placed at address 0). `yaGPC`
runs the identical fixture to completion correctly (see
`yaGPC/src/iop.h`'s `IOPLocalStore` comment and `yaGPC/src/iop.c`'s
`iopls_ls()` for how it implements the evidently-intended `@cp().r(...)`
behavior instead).

**For yaGPC2**: the actual fix in `gpc` is a one-character change
(`@cp.r(...)` → `@cp().r(...)`); the C side (`yaGPC`'s `iopls_ls()`
already does this correctly) needs no change, just confirm it's still
there once `yaGPC2` diverges from `yaGPC`.

**Status in yaGPC2 (2026-07-26): confirmed correct, no change needed.**
`iopls_ls()` already implements `@cp().r(...)`'s evidently-intended
behavior.

### 1.2 `gpc run --interactive` never detects real stdin EOF

**File**: `gpc/cmd_run.coffee`, `runInteractive`/`promptInput`
(around lines 333–397).

Two compounding issues:

1. `IOHost#hasFileInput(channel)` (`gpc/iohost.coffee`) returns
   `inStreams[ch]?.length > 0` — true only while a `--infileN` channel
   still has buffered lines. Once exhausted, it's indistinguishable from
   "no file was ever configured for this channel," so
   `runInteractive`'s `inputCallback` falls through to the
   terminal-prompt branch (`promptInput`) instead of detecting file-EOF
   and calling `HalUCP#provideEof()`.
2. `promptInput` creates a `readline.createInterface(...)` and calls
   `rl.question(prompt, cb)` — but `cb` only fires on a `'line'` event.
   If stdin actually reaches EOF (piped input exhausted, or a real
   terminal's Ctrl-D) with no trailing unterminated line, the callback
   never fires and `provideEof()` is never called. The process then just
   idles until Node's event loop has nothing left to do and exits
   quietly with code 0 — no crash, no error message, just silent
   truncation.

**Effect**: any interactive HAL/S program using the standard "`READ`
until EOF, `ON ERROR GO TO` handler" idiom (a documented pattern
straight from "Programming in HAL/S" p.193 — see
`gpc/gen/../../"Source Code"` or `yaHALMAT2`'s own
`test_read_eof_onerror.hal`) silently truncates under `gpc run
--interactive` instead of ever reaching its `ON ERROR` handler or
subsequent `WRITE` output. Confirmed this is specific to
`--interactive` mode — batch (non-interactive) `run()` mode's
`inputCallback` always treats every channel as file-based and
unconditionally calls `provideEof()` on exhaustion, with no
terminal-prompt fallback, so it does NOT have this bug.

**Reproduction**: compile `yaHALMAT2`'s
`~/git/virtualagc/yaShuttle/yaHALMAT2/src/tests/hal/test_read_eof_onerror.hal`
via the real toolchain (see `yaGPC/tools.md` for `HALSFC`/`lnk101`
invocation, or just reuse the checked-in
`yaGPC/test/fixtures/read_eof_onerror.fcm` +
`read_eof_onerror-lnk101.json`, built by
`yaGPC/test/fixtures/build_hal_fixtures.sh`), then:
```
printf "1, 1\n2, 2\n3, 4\n" | node dist/gpc.js run --interactive \
  --no-trace --no-verbose --symbols yaGPC/test/fixtures/read_eof_onerror-lnk101.json \
  --line-width 240 yaGPC/test/fixtures/read_eof_onerror.fcm
```
produces **zero output**, exit code 0. `yaGPC` run the same way
completes the program correctly (prints `RESULTS OF TESTING X` /
`0 SAMPLES CORRECT, 3 SAMPLES INCORRECT` and halts) — see
`yaGPC/src/run.c`'s `interactive_input_cb` comment for the full
writeup, and `run_matrix.sh`'s `read_eof_onerror` check (which asserts
`yaGPC`'s own correct output directly, since diffing against `gpc`
would never pass here by design).

**For yaGPC2**: fixing this in `gpc` properly means either (a) making
`hasFileInput`/`hasFileConfigured` distinguishable so exhaustion is
detected before falling through to the terminal prompt, and (b) giving
`promptInput` a real EOF path (e.g. handling `readline`'s `'close'`
event, not just `'line'`). `yaGPC`'s C port already does the right
thing (`prompt_and_provide_input` in `run.c` uses a blocking `fgets()`
that correctly returns EOF) — nothing to port from `gpc` here, just
keep it working.

**Status in yaGPC2 (2026-07-26): fixed.** `interactive_input_cb` (in
`src/halucp.c`) now checks `iohost_has_file_configured` before falling
through to `prompt_and_provide_input`, matching (a) above — this had
not, in fact, already been correct in `yaGPC` as originally assumed;
an actual code change was needed.

### 1.3 `#MOUTC`/`#MINC` BCE instruction dict collision — `#MOUTC` permanently unreachable

**File**: `gpc/iop_bce_instr.coffee` (BCE instruction table).

`BCEInstruction` builds a `mask -> maskedVal -> desc` dispatch dict at
startup. `#MOUTC`'s bit pattern (`________uuuuummmmmmmmmmmmmmmmmmm`) and
`#MINC`'s both parse to `mask=0, maskedVal=0` (neither pattern has a
single literal `0`/`1` bit). Since `#MINC` is defined later in the
source, it silently overwrites `#MOUTC`'s dict entry — `#MOUTC` can
never be dispatched to again, for any input. Confirmed directly against
the live CoffeeScript: `opByMask[0][0].nm === '#MINC'`.

**Reproduction**: in a Node REPL with the bundled `gpc` module loaded
(or via a small script), inspect `BCEInstruction.prototype.opByMask[0][0].nm`
— it reads `'#MINC'`, never `'#MOUTC'`. `yaGPC` replicates this exactly
(byte-for-byte fidelity was the whole point of that port) — see
`yaGPC/src/iop_bce_instr.c`'s `bce_instr_table_init()` comment.

**For yaGPC2**: this is very likely an actual authoring bug in `gpc`
(two instructions should almost certainly not share a mask/maskedVal —
check whether `#MOUTC`'s intended bit pattern was supposed to have a
literal bit somewhere that's missing, by cross-checking the AP-101S
instruction set reference). If `yaGPC2` fixes the pattern, `#MOUTC`
becomes reachable and needs its own exec-body validation (135+29+49
instructions were fixture-tested in the original port — `#MOUTC` was
the one BCE instruction that could NOT be, for the reason above; see
`yaGPC`'s Phase 6 notes for "28/29 BCE instructions pass 76,312 generic
exec fixtures").

**Status in yaGPC2 (2026-07-26): fixed, but not the way originally
guessed above.** Root cause turned out to be a genuine misunderstanding
of the ISA, not a missing bit in the mask: per the real IOP hardware
manual (IBM-74-A31-016, Fig. 2-6 / Table 2-10) and real assembled
Shuttle flight-software object code (`workspace/PFS/BFS.SRC as
received/COMPILED/BCE`), `#MOUTC`/`#MINC` are **not independently
dispatched opcodes at all** — they're just the raw 2nd word of
`#MOUT`/`#MIN`'s own two-word instruction format (8 zero bits + 5-bit
IUA + 19-bit command), bit-for-bit identical to each other by
construction, meaningful only in the context of the preceding word.
Fix: removed both from the BCE dispatch table entirely; `#MOUT`/`#MIN`
now decode and act on that 2nd word directly (setting `IUAR` and
issuing the command via `mia_xmit_cmd`, matching `#CMD`/`#CMDI`'s
analogous behavior — something the original `gpc`/`yaGPC` reference
never did, i.e. this was actually a second, related bug beyond the
dict-collision itself). Also corrected `#MOUT`/`#MIN`'s NIA increment
from 3 to 4 halfwords, and separately found and fixed the same kind of
off-by-one for `#MOUT@`/`#MIN@` (2 halfwords, not 3) — both confirmed
against real flight-code address deltas. See `src/iop_bce_instr.c`'s
`bce_process_mio_command()` and `bce_instr_table_init()`'s comment.
Fixtures regenerated; all 75,600 BCE exec fixtures pass.

### 1.4 `SVC_ERROR_MESSAGES[22]` — corrupted message text

**File**: `gpc/halUCP.coffee:34`
```coffee
22: "CHARACTER TO INTEGEgpc/halUCP.coffeegpc/halUCP.coffeeR CONVERSION"
```
Almost certainly an accidental file-path paste during editing of the
original source (the string `gpc/halUCP.coffee` is literally embedded,
twice, in the middle of what should read "CHARACTER TO INTEGER
CONVERSION"). This is the message HAL/S's `AERROR` runtime error
mechanism (`SVC SEND ERROR`) would print for group/message code 22 —
reachable from a real running program under the right runtime error
condition (character-to-integer conversion failure).

**Reproduction**: grep `gpc/halUCP.coffee` for `SVC_ERROR_MESSAGES`; the
`22:` entry is right there, line 34. `yaGPC` preserves it byte-for-byte
in `yaGPC/src/halucp.c` (`SVC_ERROR_MESSAGES[22]` or equivalent) per the
port's fidelity mandate — grep for `"CHARACTER TO INTEGE"` there to find
it. Not independently triggered end-to-end via a real HAL/S program in
this port's testing (would need a program that deliberately triggers a
character-to-integer runtime conversion error), but the string itself
is unambiguous — no execution needed to see the bug.

**For yaGPC2**: trivial one-line fix once the intended text is
confirmed (almost certainly "CHARACTER TO INTEGER CONVERSION" — cross-check
against `USA003090`, the HAL/S-FC User's Manual, Appendix C's
execution-time-error "standard fixups" table, available in
`yaHALMAT2`'s `source-documentation/USA003090.txt`).

**Status in yaGPC2 (2026-07-26): fixed.** `SVC_ERROR_MESSAGES[22]` in
`src/halucp.c` corrected to "CHARACTER TO INTEGER CONVERSION",
cross-checked against `USA003090.txt` Appendix C as suggested above.

### 1.5 `IOP.curPE` never reassigned after construction

**File**: `gpc/iop.coffee:105` (`@curPE = 0  # MSC = 0, BCE = 1-24`),
used throughout `gpc/iop_bce_instr.coffee` (e.g. lines 113, 132, 158,
186, 189, 214, 244, 290, 370, 374, 471, 482, 484, 523, 552, 561, 606 —
grep `t.curPE` there for the full list) for addressing offsets like
`addr = v.a + 2*t.curPE` and register-bit indexing like
`t.regBusyWait.setbit32(t.curPE, 0)`.

`curPE` is initialized to `0` in the `IOP` constructor and — grep-verified
across the whole source tree — *never reassigned anywhere*. The
comment ("MSC=0, BCE=1-24") strongly implies it's meant to track which
processing element (which BCE, 1-24) is currently executing, but nothing
ever sets it to a nonzero value. Every BCE instruction that uses
`t.curPE` for a "2× BCE number" addressing offset or a per-BCE status
bit index is therefore always computing that offset/index as if it were
BCE 0 (or MSC), regardless of which BCE (1-24) is actually running.

**Not the same as `curBCE`**: `IOPLocalStore#curBCE`/`curPage` (used by
`iop.coffee`'s `nextSlice()`/`execProcessors()` to select which BCE's
local-store page is active) *is* correctly kept current by the
round-robin scheduler — this bug is specifically about the separate
`curPE` field used only inside individual BCE instruction exec bodies.

**Reproduction**: `grep -n "curPE" gpc/iop.coffee gpc/iop_bce_instr.coffee`
— confirms the single assignment (constructor) and the many read sites,
with no other assignment anywhere. To observe the effect: activate BCE2
or higher (not BCE1) via an MSC `@SIO` with the appropriate ACC bit set,
and execute one of the `t.curPE`-using instructions (e.g. whatever's at
`iop_bce_instr.coffee:113`) — the addressing offset will be computed as
if BCE were number 0, not 2. Not yet reproduced end-to-end against a
running `gpc`/`yaGPC` in this port's testing (activating a *specific*
BCE beyond BCE1, as opposed to just the MSC, was not attempted — see
`iop_msc_sio.fcm`'s generator script for the "how to activate a
processor via `PC`" technique, which would need extending to select a
specific BCE for a full repro).

**For yaGPC2**: this looks like a genuine, real latent bug (a "should be
per-BCE state but never wired up" oversight), worth prioritizing —
BCE-addressing correctness beyond BCE1 seems like it would be
observably wrong for any real program that uses more than one BCE. Needs
someone to determine what `curPE` *should* track (likely `curBCE`'s
value, or a copy of it) and where it should be set (probably inside
`execProcessors()`, alongside where `curBCE`/`curPage` are already
updated).

**Status in yaGPC2 (2026-07-26): fixed**, exactly as guessed above.
`iop_exec_processors()` (`src/iop.c`) now sets `iop->curPE = page`
right after computing which page the round-robin scheduler selected.
New integration test `test_bce_curpe_addressing` (in
`test/test_iop_exec_processors.c`) exercises BCE #3 specifically with
distinct memory markers distinguishing correct- from
incorrect-`curPE` addressing — this end-to-end scenario (a BCE beyond
#1 using `curPE`-based addressing) had never been exercised by any
prior fixture.

### 1.6 CPU instruction table: `ICR`'s illegal-command path calls a nonexistent method

**File**: `gpc/cpu_instr.coffee`, `ICR` instruction's exec body.

The illegal-command path calls `t.i_ILLEGAL()` — grep-verified, this
method does not exist anywhere in `gpc/cpu.coffee` or elsewhere; if this
path were ever actually reached in the live reference, it would throw.
`yaGPC`'s `cpu_instr.c` implements the evidently-intended behavior
(`signalIllegalOp`, matching what every *other* illegal-opcode path in
the same file actually calls) instead of replicating a crash — see the
inline comment in `yaGPC/src/cpu_instr.c` near `ICR`'s C implementation.

**For yaGPC2**: straightforward fix — `t.i_ILLEGAL()` should presumably
be whatever the analogous call is elsewhere in `cpu_instr.coffee` for
signaling an illegal/privileged-instruction exception (search for how
other instructions with an illegal-command check handle it, e.g. grep
`signalIllegalOp`-equivalent in the CoffeeScript, if a name like that
exists, or check what real "illegal operation" program-interrupt
handling looks like in `cpu.coffee`).

**Status in yaGPC2 (2026-07-26): confirmed correct, no change needed.**
`yaGPC2`'s C port already implements the evidently-intended
`signalIllegalOp`-equivalent behavior, matching what every other
illegal-opcode path in the same file does — this was already fixed
during the original `yaGPC` port, not something that needed
re-fixing.

### 1.7 Two related genuine no-ops (lower priority — dead code, not wrong output)

- `ISPB`'s illegal-M1 path and `ICR`'s "Write Discretes" path
  (`gpc/cpu_instr.coffee`) each set a JS object property that is never
  read anywhere else in the source (grep-verified). Not a bug in the
  sense of producing wrong *output*, just dead code — `yaGPC` omits the
  equivalent no-op writes. Not necessarily worth yaGPC2's time unless a
  cleanup pass through `cpu_instr.coffee` is already underway for other
  reasons.
- `gpc/cpu.coffee`'s `INT_*` named interrupt handlers (`INT_addressSpec`
  and siblings) are dead code — grep-verified never called; the actual
  interrupt dispatch (`checkInterrupts`) has its own inline `swapPSW`
  logic instead of calling these. Worth noting only because it means
  the `INT_*` methods' *documentation comments* (which look authoritative
  — e.g. "Interrupt Priority: 7, Class: PE, Old PSW: 0048...") are
  disconnected from what the code actually does; if `checkInterrupts`'s
  inline logic ever diverges from what the `INT_*` comments describe,
  there'd be no test coverage catching it since the commented code never
  runs. Worth a side-by-side read if yaGPC2 touches interrupt handling.

**Status in yaGPC2 (2026-07-26): confirmed as-is, no change needed.**
Both are dead-code no-ops in `gpc`, and `yaGPC2`'s C port already
omits the equivalent no-op writes (same as `yaGPC` before it) — no
observable-output difference either way.

### 1.8 Source-formatting gotcha (not a runtime bug — a tooling trap)

`gpc/cpu_instr.coffee` has a stray space in one instruction's key:
`MVS :` instead of `MVS:` (grep `"MVS :"` to find it — it's the only
CPU instruction definition with a space before its colon). This means
naive tooling that greps for `^\s*[A-Z][A-Z0-9]*:\s*{` to enumerate/count
instruction definitions (as this port's own `extract_instr_defs.cjs`
descendant tooling, or any future yaGPC2 tooling, might do) will
undercount by one — the real CPU instruction count is **135**, not 134.
Not a functional bug (the JS object literal parses fine either way,
`MVS :` is valid CoffeeScript), just a trap for anyone writing
source-scraping tools against `cpu_instr.coffee`.

**Status in yaGPC2 (2026-07-26): no action needed.** This is a
tooling/documentation note about the JS reference source's own
formatting, not something that applies to the C port (nothing in
`yaGPC2`'s own tooling string-scrapes `cpu_instr.c`'s `OPS[]` table
this way).

### 1.9 (found during yaGPC2 development) `iop_exec_processors()`: PC read via the wrong accessor width, plus an NIA-override bug — both silently defeated BCE branching and multi-word instructions

**File**: `src/iop.c`, `iop_exec_processors()` (the per-tick
fetch/dispatch loop `run()` actually uses — not covered by any prior
exec-fixture test, which test instruction *bodies* in isolation, not
the fetch loop that drives them). Both bugs were inherited verbatim
from `gpc/iop.coffee`, not introduced during porting.

Two compounding issues:

1. PC was fetched via `register_get16`/`set16` (only the register's
   first backing halfword), while every instruction's own NIA update
   (`iop_set_nia`/`iop_incr_nia`, used by e.g. `#BU`/`#BU@`) uses
   `register_get32`/`set32` (spans both halfwords) on the *same*
   register. For any address under `0x10000` (every real address in
   this system), the two accessors read/write different halfwords, so
   the fetch loop never actually saw what an instruction had just set.
   (`gpc` source: `@ls.PC().get16()` vs. `setNIA`/`incrNIA`'s
   `.get32()`.)
2. Independently, this function forced BCE's PC to
   `(pre-dispatch PC)+1` unconditionally after every dispatch,
   discarding whatever the matched instruction had actually set — so
   even with (1) fixed, branches/multi-word instructions still
   wouldn't take effect. (`gpc` source: `@ls.PC().set16(pc + 1) #
   Default NIA increment for BCE`.)

**Effect**: no BCE branch or multi-halfword instruction, and no MSC
instruction sequencing at all, could ever actually work through the
full simulation loop — only single-halfword, non-branching
instructions appeared to "work," and only by accident (the broken PC
write happened to leave PC in roughly the right place for the *next*
sequential single-word instruction).

**Status in yaGPC2: fixed.** Both reads/writes now go through
`register_get32`/`set32`; the unconditional override is removed
entirely, trusting each instruction's own NIA handling. This also
correctly preserves `#WIX`'s intentional "stay parked while waiting
for a Listen command" behavior, and BCE's documented (deliberately
asymmetric vs. MSC's) "stall on unrecognized opcode" behavior. New
integration test suite added: `test/test_iop_exec_processors.c`
(wired into `Makefile`/`NMakefile`), covering branch-taking,
sequential MSC/BCE advancement, `#WIX` waiting, and the
unrecognized-opcode stall — none of which any prior fixture actually
exercised, since they all test instruction *bodies*, not the fetch
loop driving them.

### 1.10 (found during yaGPC2 development) `#MOUT@`/`#MIN@` NIA increment off-by-one

**File**: `src/iop_bce_instr.c`, `exec_MOUT_at`/`exec_MIN_at`.

These used `incrNIA(3)` despite being single-word (Long Format 1)
instructions like `#LBR`/`#CMD`/`#TDL` (which correctly use
`incrNIA(2)`). Confirmed as a genuine off-by-one via three independent
real flight-code address deltas (`workspace/PFS/BFS.SRC as
received/COMPILED/BCE`), each `#MOUT@`/`#MIN@` spanning exactly 2
halfwords between its surrounding instructions.

**Status in yaGPC2: fixed** — both now use `incrNIA(2)`. Fixtures
regenerated the same way as the 1.3 fix; all 14 unit test suites still
pass.

---

## 2. Discrepancies found: `yaGPC` (== `gpc`, confirmed identical) vs. `yaHALMAT2`

**IMPORTANT CAVEAT** (see also "Methodology" below): `yaGPC`/`gpc`
execute real, compiled AP-101S machine code — full `HALSFC` PASS2
codegen, `lnk101` linking, actual CPU/IOP hardware-level simulation.
`yaHALMAT2` interprets HALMAT (PASS1's output) directly, one layer
*before* codegen and linking. A discrepancy between them could mean a
real `gpc`-inherited bug worth fixing in `yaGPC2` — or it could mean
`yaHALMAT2` has its own gap (it's a separate, independently-developed
tool with its own scope boundaries — see its own `YERRORS.md`/`ZERROR.md`
for the kinds of gaps it has found in *its* reference points) — or it
could mean the two are simply modeling different things (runtime-library
linkage overhead, hardware timing) that don't have a shared ground truth
at all. **Every item below needs primary-source triage
(`yaHALMAT2/reengineered-documentation/`, `USA003087`/`USA003088`/
`USA003090` extracted text under `yaHALMAT2/source-documentation/`)
before assuming either implementation is "the bug."**

Ruled out first, for context — two specific bugs `yaHALMAT2`'s own
`YERRORS.md` documents in yet a *third* tool (the older, admittedly
"very immature and buggy" `yaHALMAT`, not `yaHALMAT2` — per the repo
owner) were checked directly against `gpc`/`yaGPC` and are **not**
present there:
- `YERRORS.md` finding 1 (`DCAS`/`DO CASE` 0-indexed vs. 1-indexed):
  compiled `/mnt/STORAGE/home/rburkey/git/Halmat/data/test_case.hal`
  (`SEL=2` should select the *second* case per `USA003087` §10.3) through
  both `gpc run` and `yaGPC` — both correctly produce `RESULT=20` (the
  1-indexed, spec-correct answer). Not a `gpc` bug.
- `YERRORS.md` finding 2 (nested `DO FOR` iteration miscounting):
  compiled `/mnt/STORAGE/home/rburkey/git/Halmat/data/test_nested.hal`
  (hand-derived expected `K=150`) through both — both correctly produce
  `K=150`. Not a `gpc` bug.

Both are recorded here only so a future session doesn't re-spend time
re-checking them.

**Sweep results**: ran all 169 of `yaHALMAT2/src/tests/hal/test_*.hal`
through this pipeline. 4 failed to compile standalone (`test_exit_dfor_label`,
`test_ext_charfunc_prog`, `test_ext_mytable`, `test_ext_pcal_prog` — all
external-function/multi-file tests, need `run_ext_func_fixture.sh`'s
approach instead), 1 failed to link (`test_file`). Of the remaining 164:
91 agreed across all three tools; 15 showed a `gpc`-vs-`yaGPC` difference
(all 15 are more instances of bug 1.2 above — every one is a program with
a `READ(5)` that hits immediate EOF against this sweep's `/dev/null`
stdin; full list: `test_bit_index`, `test_char_subscript`, `test_rdal`,
`test_read_array`, `test_read_comma`, `test_read_eof_onerror`,
`test_read_leading_comma`, `test_read_semicolon`,
`test_read_semicolon_loop`, `test_read_skip_column`, `test_read_structure`,
`test_read_vecmat_edge`, `test_read_vecmat`, `test_read_write`,
`test_tasn_array_terminal` — not investigated further individually, not
listed as a distinct bug); 73 showed a `yaGPC`-vs-`yaHALMAT2` discrepancy.
Full raw output (every discrepancy's exact stdout, both sides) is in
`sweep_raw_results.txt` alongside this file. The 73 break down as follows:

### 2.1 TOP FINDING — `ON ERROR` trap does not stop the trapping statement's own remaining execution

Three tests show `gpc`/`yaGPC` printing text and/or computing values that
the test source itself labels as things that should NOT happen once an
error is trapped:

- **`test_eron_goto_appc`**: source writes `'SHOULD NOT PRINT (SQRT)'`
  immediately before a `SQRT` call expected to trigger a domain-error
  trap; `yaGPC` output includes `SHOULD NOT PRINT (SQRT)      2.0000000E+00`
  (i.e. it printed the "should not print" text *and* a computed SQRT
  result) before `AFTER SQRT TRAP`, and the same pattern repeats for
  `(UNIT)`, `(MDIV)`, `(ZEROPOW)` later in the same program.
  `yaHALMAT2`'s output has none of the four "SHOULD NOT PRINT" lines —
  just the four `AFTER ... TRAP` lines, back to back.
- **`test_eron_goto`**: `gpc`/`yaGPC` prints `SHOULD NOT PRINT` followed by
  a matrix inverse computed from what looks like garbage/overflowed
  intermediate values (`1.6503236E+07  -8.2516180E+06 ...`); `yaHALMAT2`
  has no such line at all.
  Also note a smaller, separate-looking formatting difference in the same
  test's non-error-path lines (`BEFORE TRAP` on its own line in `yaGPC`
  vs. `BEFORE TRAP` sharing a line with the first matrix row in
  `yaHALMAT2`) — likely just the same leading-newline/WRITE-continuation
  quirk noted in 2.4 below, secondary to the main finding here.
- **`test_eron_event`**: `EV1 NOT SET` / `EV3 NOT SET` from `yaGPC` where
  `yaHALMAT2` reports `EV1 SET` / `EV3 SET` — consistent with the same
  family of issue (an event/error condition not being recognized as
  having fired/trapped).

**Working hypothesis** (not yet confirmed against primary source or
`gpc`'s `_tryOnErrorDispatch`/SCAL-frame-unwind code in detail): when a
runtime-error trap (`ON ERROR`/`ON ERROR$(...)`) fires mid-statement in
`gpc`, the statement that triggered the trap keeps executing to
completion (computing and even `WRITE`ing its result) *in addition to*
the trap handler running afterward, rather than the trap immediately
aborting the rest of that statement's evaluation the way `yaHALMAT2`
does and the way the "SHOULD NOT PRINT"-labeled source comments clearly
expect. If confirmed, this would be a significant, real `gpc` bug in
`halUCP.coffee`'s ON ERROR dispatch (the SCAL-frame-unwind path
mentioned in `yaGPC`'s own Phase 8 notes as "translated directly...
but has NOT been fixture-tested against the JS the way CPU/IOP were").

**Reproduction**: `~/git/virtualagc/yaShuttle/yaHALMAT2/src/tests/hal/test_eron_goto_appc.hal`
(and `test_eron_goto.hal`, `test_eron_event.hal`), compiled+linked via
`HALSFC`/`lnk101` per `yaGPC/tools.md`, run with
`--interactive --no-trace --no-verbose --line-width 240` on both `gpc
run` and `yaGPC` (they agree with each other) vs. `yaHALMAT2
halmat.bin` (the `halmat.bin` HALSFC leaves in the compile directory).
**Highest-priority item in this whole file** — start here.

**Status in yaGPC2 (2026-07-26/27): fixed for `test_eron_goto_appc`
specifically** (all 4 of its error types — SQRT, UNIT null-vector,
`#MDIV` zero-divide, `ZERO**0` — now correctly trap; none of its
"SHOULD NOT PRINT" lines appear). `test_eron_goto` and `test_eron_event`
have now also been independently investigated (2026-07-27) — **neither
turns out to be the same ON-ERROR-dispatch bug**, both are distinct
findings in their own right:

- **`test_eron_goto` — NOT a yaGPC2 bug; a genuine real-hardware
  floating-point-register-pair-history fragility in the actual compiled
  RTL, faithfully executed.** Its `SHOULD NOT PRINT` line isn't a
  dispatch failure at all — the SVC for `SEND ERROR` is never even
  reached a second time. Traced via `--trace` instruction-by-instruction:
  `INVERSE`'s real runtime routine (`RUNASM/MM14SN.asm`, 2x2 direct-
  computation path) detects singularity via `SEDR F0,F2` (Subtract Long
  — confirmed against the AP-101S Software Model manual, Sec. 8.26: this
  operates on the **full 64-bit register pair** F0:F1 and F2:F3, not
  just F0/F2) immediately after loading F0/F2 via `LE` (Load Short,
  Sec. 8.18 — confirmed the manual describes this as affecting *only*
  the target register, consistent with `exec_LE` in `src/cpu_instr.c`
  not touching the paired register). Nothing in `MM14SN.asm`, `AMAIN`'s
  prologue, or the architecture manual ever clears F1/F3, so `SEDR`'s
  "long" comparison picks up whatever garbage is left in the paired
  extension registers from earlier, unrelated double-precision
  arithmetic (the `WRITE` statement's own float-formatting code, in this
  test). First call happens to see a clean zero (correctly detects
  singularity); the second/third calls see leftover nonzero garbage in
  the low half, so the "determinant" reads as a tiny nonzero value
  instead of exactly zero, and the singularity check silently fails to
  fire. **Confirmed present in the original `gpc.js`, in `yaGPC`, and in
  `yaGPC2` identically** (all three give the same garbage matrix) — a
  real, inherited compiled-RTL fragility, not a yaGPC2 regression.
  Cross-checked against `yaHALMAT2`, which correctly avoids this every
  time (no register-pair-history model at that level of abstraction) —
  confirming the discrepancy is fully explained, not concerning. No
  yaGPC2 change made or warranted; nothing to fix here without
  deliberately *deviating* from real hardware fidelity.
- **`test_eron_event` — a genuine, confirmed, different omission: the
  `ON ERROR ... IGNORE AND SIGNAL/SET/RESET <event>` disposition's
  event-signaling side effect is entirely unimplemented.** Confirmed via
  temporary FIXV-dump instrumentation that the compiler *does* install a
  real FIXV entry at the expected direct slot for each of this test's
  three `ON ERROR$(4:5) IGNORE AND ... EVn` statements — but with `TAG`
  values of `0xF` and `0x7` (not `0x0`/`0x1`/`0x3`, the only three this
  session's earlier work had ever observed and hard-coded for). Given
  `match_error_handler()` in `src/halucp.c` only ever recognizes `TAG=0`
  (`0x3F` group/num wildcards) and unconditionally rejects everything
  else, these dispositions are never matched at all — the `SEND ERROR`
  falls through unhandled every time (confirmed via `--verbose`: the
  fallback SCAL-unwind path is reached and computes a nonsense address,
  `0xfffffffe`, since this isn't actually a SCAL context), and no event
  ever gets signaled/set/reset. The differing tag values between
  `SIGNAL`/`RESET` statements strongly suggest the compiler assigns a
  distinct tag per statement, indexing some separate compiler-emitted
  table (event address + action-type) that hasn't been located yet.

  **Update (2026-07-27): FIXED.** Root-caused via three isolated
  single-statement compiles (one each for `IGNORE AND
  SIGNAL`/`SET`/`RESET`, `LSTALL` listings): all three use the
  identical `FIXV` layout as the existing `TAG=0` `GO TO` case
  (group/num in the low 12 bits), differing only in `TAG`
  (`SIGNAL=0xF`, `SET=0x7`, `RESET=0xB` — no bit relationship found
  between them, matched by direct enumeration since only 3 data points
  were confirmed), with the paired "handler" slot holding the **EVENT
  variable's own address directly** (`LA R4,EVn` / `STH R4,slot+1`),
  not a jump target. Fixed in `src/halucp.c`: `match_ignore_event_handler()`
  recognizes the three tags (checked in `try_on_error_dispatch()`'s
  existing slot-scan loop, before the `TAG=0` check);
  `apply_ignore_event_action()` sets/clears bit 0 (mask 1) of the
  halfword at the event's address — confirmed as the "is this event
  set" bit via the matching `IF EVn THEN` compiled check (`TB 0(Rn),1`).
  No jump or `R0`/`R1`/`R3` fixup needed for this disposition — the
  erroring routine's own epilogue runs completely normally afterward,
  exactly as an unhandled error already would; only the event's bit
  changes. `test_eron_event.hal` now gives `EV1 SET` / `EV2 NOT SET` /
  `EV3 SET`, exactly matching yaHALMAT2. A directly related, separate
  gap found in the same investigation: plain (non-`ON ERROR`)
  `SIGNAL`/`SET`/`RESET <event>` statements were *also* unhandled
  (generic "SVC trapped"). These compile to fixed SVC codes
  `0x000C`/`0x000D`/`0x000E`, with the event's address as the SVC's
  second operand halfword (`mem[ea+1]`) — the exact same convention
  `SEND ERROR` (`0x0014`) uses for its own group/num data. Fixed in
  `halucp_handle_svc`, reusing the same `apply_ignore_event_action()`
  helper. Verified: all 14 unit test suites pass;
  `test_eron_goto_appc`/`read_eof_onerror.fcm` re-checked unaffected.

Root cause, confirmed against a real HALSFC-compiled listing plus
`RUNMAC/AEXIT.asm`/`ERRPARMS.asm`/`AERROR.asm`/`AMAIN.asm`
(`~/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/RUNMAC/`):
`gpc`/`yaGPC`'s original single-mechanism "SCAL-frame-unwind" ON ERROR
dispatch (reading FIXV/handler via one level of indirection through a
caller-saved-R0 chain) only covers routines entered via the heavier
`SCAL@#` convention. Two more cases exist and neither was previously
handled:
- RTL intrinsics entered via a plain `BAL@#` that never reassigns R0
  (e.g. `SQRT`) — for these, the ON ERROR statement's FIXV/handler
  live directly in the current frame at a range of offsets starting at
  18 (one 2-halfword slot per distinct `ON ERROR` statement in the
  routine, allocated sequentially by the compiler's `SET_ERRLOC` —
  `HALINCL/GENCLAS0.xpl`).
- RTL routines that are *also* entered via plain `BAL@#` but
  themselves make further nested calls (e.g. `UNIT`'s `VV10S3`, which
  internally calls `SQRT`) are declared `AMAIN ACALL=YES`
  (`RUNMAC/AMAIN.asm`) and so bump R0 forward via `IAL
  0,STACKEND-STACK` to claim their own scratch frame, *without* using
  `SCAL@#`. Such a routine has no `ON ERROR` statement of its own, so
  its own frame's slots are always empty — the real FIXV/handler is
  one level up, in the enclosing routine's frame, recoverable by
  walking `mem[current_frame_sa + 2]` (the caller's original R0,
  saved as a hi/lo halfword pair — the same convention the original
  SCAL-unwind path already relied on for its own single level of
  indirection).

Fix, in `src/halucp.c`'s `try_on_error_dispatch()`: the direct-slot
scan is now retried at each ancestor frame (walking up via the
above-mentioned R0-recovery, bounded to 8 levels) before falling back
to the original SCAL-unwind logic (kept, structurally unreached in
every case checked so far, as a safety net for any other calling
convention not yet seen). Two non-obvious details, both caught via
empirical re-testing rather than derived purely from the manual: (1)
the R1/R3 data-base-register restore-before-dispatch (needed because
jumping away bypasses the erroring routine's own `AEXIT` epilogue)
must use the *matched* ancestor frame's own save slots, not the
originally-erroring frame's (usually unpopulated in a callee like
`VV10S3`); (2) R0 itself must also be restored to the reconstructed
ancestor value when dispatching from a level > 0 — omitting this
produced a real regression (a later, same-program error whose
dispatch *should* have worked at level 0 instead spuriously matched
garbage in the abandoned child frame's stale, reused stack memory).
Verified no regressions: all 14 unit test suites pass, plus
`read_eof_onerror.fcm` (which exercises the true-SCAL path) unchanged.

**A fourth case, `inverse_singular_matrix_not_detected` (197-P.hal/198-P.hal,
also cross-referenced in §3.1), turned out to be architecturally
different from all three above and took a false start before being
root-caused for real.** Initial testing (2026-07-28) found 197-P/198-P
agreeing byte-for-byte with `yaHALMAT2` (both all-zero, i.e. both honor
the registered `ON ERROR$(4:27) DO; M=0; GO TO L1; END;` handler) and
the finding was retracted as a side effect of an unrelated `WRITE`
buffering fix. That retraction was wrong: the frozen, hardware-faithful
`yaGPC` predecessor binary shows the **identity matrix**, not zero, for
this exact file — even with the `GO TO` handler registered — an
unexplained real-hardware mechanism that needed its own investigation.

Root-caused via the confidential real FCOS source
(`~/workspace/PFS/OI340600/SSSRC/FPMSDERR.asm`, the actual SEND ERROR
SVC handler — access authorized for this analysis; findings summarized
here, not the source quoted verbatim): the OS/SVC level **never**
dispatches to a user's `ON ERROR` handler for *any* error, ever — it
only logs, runs system-default action (`FPMSYSAC`, which only ever
special-cases a handful of severe errors like illegal opcode/CPU store
protect for process closure), and returns. `try_on_error_dispatch()`'s
entire SVC-time FIXV-walk-and-jump architecture (all three cases
above) does not match how real FCOS actually works — it happens to
produce correct-looking results for the cases already fixed, but not
because the OS is doing what that architecture assumes.

Traced how real GOTO dispatch actually works instead, using
`test_eron_goto_appc.hal` (the already-verified-correct SQRT/UNIT/MDIV/ZEROPOW
cases) and 197-P.hal side by side, disassembling the real compiled
instructions on both sides of each call: the **compiler** emits its own
redundant, statically-known re-check of the error condition directly in
the calling code immediately after the call — e.g. `$0TESTER`'s compiled
code re-tests "is the SQRT argument negative" via a leftover condition
code right after the call, and branches around the "should not print"
statement accordingly. `$0P`'s real compiled code, traced the same way
immediately after its call to `MM14S3` (197-P.hal's 3×3
cofactor-expansion matrix inverse), has **no such check at all** — it
falls straight through unconditionally to the next statement
(`WRITE(6) M`). This is presumably because matrix-inverse singularity
can't be cheaply re-verified at the call site the way "is this argument
negative" can (it would require redoing the whole cofactor expansion) —
so the compiler simply never generates a check for this error
condition, meaning the `ON ERROR GO TO`/DO-block registration for group
4:27 is syntactically valid but **never actually dispatches on real
hardware**, regardless of implementation.

**Fixed** (2026-07-28): `try_on_error_dispatch()` (`src/halucp.c`) now
returns immediately (no dispatch, any disposition) for the specific
case `errGroup==4 && errNum==27`, narrowly scoped — confirmed via grep
that no other corpus file registers this exact group/num except
197-P.hal, 198-P.hal, and 029-DATATYPES.hal (a wholly different code
path, `MM14SN` not `MM14S3`, where this error is confirmed to never even
fire — see §3.1's `datatypes_repeated_singular_inverse_unstable_result`
— so inert there). Verified 197-P.hal now matches frozen `yaGPC` byte
for byte (identity matrix, not zeros); 198-P.hal's content (10 looped
identity matrices) matches exactly too; `test_eron_goto_appc.hal`
re-verified unaffected. Full unit test suite re-run: identical pass/fail
counts before and after (one pre-existing, unrelated `CVFX`-fixture
failure in `test_cpu_instr_exec`, confirmed via `git stash` to predate
this work entirely).

**This is a real, cleanly-characterizable — not a "these will just
always differ" — parity gap on `yaHALMAT2`'s side**, logged as
`yahalmat2_dispatches_goto_for_undispatchable_matrix_inverse_error`
(§5): unlike the `test_eron_goto`/`MM14SN.asm` register-garbage class
(genuinely non-deterministic, nothing to replicate), this one is a
simple, deterministic special case `yaHALMAT2` could adopt symmetrically
to `yaGPC2`'s own fix above.

### 2.2 Systematic: `BIT`-pattern-to-`INTEGER` conversion sign interpretation

Four independent test programs show the exact same numeric relationship
— `gpc`/`yaGPC`'s answer and `yaHALMAT2`'s answer are the same bit
pattern, one read as signed two's-complement, the other as unsigned:

| test | yaGPC (signed) | yaHALMAT2 (unsigned) | width |
|---|---|---|---|
| `test_bit` (`I3=INTEGER(NOT B1)`, `B1` is `BIT(8)`) | `-13` | `243` | 8-bit |
| `test_bit_at_partition` | `-9011` | `56525` | 16-bit |
| `test_subbit_assign` | `-3856` | `61680` | 16-bit |
| `test_init8` | `-21846` | `43690` | 16-bit |

(`243 = 256-13`; `56525 = 65536-9011`; `61680 = 65536-3856`;
`43690 = 65536-21846` — confirmed by hand, not a coincidence.)

`yaGPC`/`gpc` sign-extend the declared-width `BIT` value's high bit when
converting to `INTEGER`; `yaHALMAT2` zero-extends (treats it as
unsigned). **This needs primary-source resolution** — check
`USA003087`/`USA003088`'s `BIT`→`INTEGER` conversion rules (`class-6`
docs in `yaHALMAT2/reengineered-documentation/` likely already cover the
`BTOI`/`CTOI`-family opcodes this compiles down to) for which is
actually correct. Given how consistent and mechanical the pattern is
across 4 unrelated test programs, whichever way it goes, it's very
likely a single root-cause fix (one conversion routine) rather than four
separate bugs.

**Reproduction**: `~/git/virtualagc/yaShuttle/yaHALMAT2/src/tests/hal/test_bit.hal`
is the simplest repro — see the `test_bit` example already worked
through in this file's own methodology section (`I3 = INTEGER(NOT B1)`
with `B1 = BIT(12)` truncated into a `BIT(8)` field).

**Status (2026-07-26, corrected 2026-07-27): resolved — not a yaGPC2
bug, and now fixed in yaHALMAT2 — but the original "spec-correct across
all 4 tests" claim below was wrong for `test_bit` itself; correcting
the record.** `USA003087.txt` Appendix A ("STANDARD CONVERSION
FORMATS" / "CONVERSIONS TO INTEGER TYPE") states a bit type converts
to integer "by regarding it as the bit pattern of a **signed** integer
of the desired precision," and on 2026-07-26 this was assumed to settle
all 4 rows of the table above in `yaGPC`'s favor without re-running
`test_bit` itself to check — an error caught on 2026-07-27 by directly
re-compiling and re-running all 4 tests through current `yaGPC2`:
`test_bit_at_partition` (`-9011`), `test_subbit_assign` (`-3856`), and
`test_init8` (`-21846`) all directly reproduce, confirming the table's
"yaGPC (signed)" column for those three — but `test_bit`'s own `I3`
comes out **`243`, not `-13`** (i.e. `yaGPC2` itself currently agrees
with the table's "yaHALMAT2 (unsigned)" column for this one row, not
its own). Root cause (confirmed by reading `test_bit.hal`'s compiled
listing): `INTEGER(bit-expression)` doesn't invoke any explicit
sign/zero-extension instruction at all — it's a bare `STH` of whatever
the immediately-preceding bitwise operation (`NR`/`OR` for
`AND`/`OR`/`NOT`) left in the register's upper halfword, with no
separate conversion step. For `test_bit_at_partition`/
`test_subbit_assign`/`test_init8`, the source `BIT` value's width
matches the register position such that the top bit lands exactly on
the halfword's sign bit — not really "sign extension" as an operation,
just direct reinterpretation of a same-width pattern. `test_bit`'s
`NOT B1` (an 8-bit-declared operand) doesn't get that same alignment,
and empirically doesn't yield a sign-extended result in real compiled
code. **yaHALMAT2 independently rediscovered this exact fact** (see
`problems-yaHALMAT2.md`, yaHALMAT2 directory, `test_bit` entry, FIXED
2026-07-27) via its own real-`gpc` probing, and fixed both root causes
on its side: `BNOT` now masks to the operand's declared `BIT(n)` width
instead of complementing the full register, and non-`DOUBLE` `INTEGER`
values now truncate/reinterpret as signed 16-bit at `WRITE` time
(matching real hardware) instead of keeping a full 32-bit value —
which incidentally also resolved `test_bit_at_partition`,
`test_subbit_assign`, `test_init8`, and 2.9's `test_subbit_scalar` for
free, all via the same underlying mechanism. No yaGPC2 change was ever
needed here; the only actual bug was in yaHALMAT2, now fixed on that
side, plus one factual error in this file's own 2026-07-26 write-up,
also now fixed.

### 2.3 `SCALAR`→`INTEGER` conversion: exact-.5 tie-breaking rule differs

`test_stoi.hal`: `S2=7.5` → `yaGPC`/`gpc` gives `I2=7`, `yaHALMAT2` gives
`8`. `S3=-7.5` → `yaGPC`/`gpc` gives `-7`, `yaHALMAT2` gives `-8`.
(Non-tie cases — `7.2`→`7`, `-7.2`→`-7` — agree on both sides.) Reads as
`gpc` rounding an exact `.5` toward zero, `yaHALMAT2` rounding away from
zero (or possibly round-half-to-even — `7.5`→`8` and `-7.5`→`-8` are
also consistent with round-half-away-from-zero specifically; would need
a `.5` case landing on an *odd* target to distinguish round-half-even
from round-half-away-from-zero, which `test_stoi.hal` doesn't happen to
exercise). `test_bfnc_rounding.hal`'s last value (`ROUND()` of something
landing on a tie) shows the same family of disagreement (`8.0` vs
`5.0` — different magnitude so less directly comparable, but worth
checking together). **Primary-source check needed**: `USA003087`'s
`INTEGER()`/`ROUND()` conversion rules should state the tie-breaking
convention explicitly.

**Reproduction**: `~/git/virtualagc/yaShuttle/yaHALMAT2/src/tests/hal/test_stoi.hal`,
same compile+link+run recipe as above.

**Status (2026-07-26): resolved — not a yaGPC2 bug, a yaHALMAT2 bug.**
Compiled and traced to a real, linked-in RTL module call (`BAL` to
`ETOH`), then read `Source Code/PASS.REL32V0/RUNASM/ETOH.asm` (public-
domain Shuttle flight-software runtime library source): the conversion
is `CVFX` (truncating float-to-fixed) followed by a hand-coded
rounding-bias sequence (`A R5,=X'7FFF'` / conditional `A R5,=X'1'` /
`NHI R5,X'FFFF'`) — real, authentic flight-software rounding logic
that `yaGPC2` just executes as compiled AP-101S machine code (via its
already-fixture-validated CPU instructions), not something it
reimplements. `gpc`/`yaGPC`'s "round toward zero at exact .5" is
therefore the authentic result of running the real algorithm;
`yaHALMAT2`'s "round away from zero" is the divergent behavior. No
yaGPC2 change made. **Resolved: fixed in yaHALMAT2 (2026-07-27)** —
exact-.5 ties now round toward zero, confirmed via yaHALMAT2's own
24-point real-`gpc` probe across magnitudes/signs (their prior "away
from zero" behavior had itself been copied from a different,
unverified reference emulator rather than checked against real
hardware). See `problems-yaHALMAT2.md`, `test_stoi`, FIXED.

### 2.4 Formatting: leading blank line before the first `WRITE` in `--interactive` mode

At least 9 of the 73 (`test_array_double`, `test_matrix_identity_init`,
`test_matrix_identity5_init`, `test_matrix_col_assign`,
`test_matrix_row_assign`, `test_bfnc_matrix2`, `test_nest_call`,
`test_vecmat_null_assign`, `test_proc_matrix_precision`, and part of
`test_eron_goto` above) differ *only* in a single leading `\n` that
`yaGPC`/`gpc` emit before the very first `WRITE(6)` output and
`yaHALMAT2` doesn't — every other character matches exactly. This is
very likely specific to `--interactive` mode's column/newline-tracking
logic (`gpc/halUCP.coffee`'s `notifyInteractiveInput`/column-6 tracking,
already touched on in `yaGPC`'s own `run.c` comments around
`prompt_and_provide_input`) rather than a `yaHALMAT2` comparison issue
proper — low priority, but confirm it's really `--interactive`-specific
(try the same programs in batch/non-interactive mode) before spending
time on it, since it may just be expected/correct `--interactive`-mode
behavior that `yaHALMAT2` doesn't replicate (rather than a `gpc` bug).

**Status (2026-07-26): resolved — not a bug on either side.** Compiled
`test_array_double.hal` and compared yaGPC2 interactive vs. batch
(byte-identical, no leading-newline difference at all) and yaGPC2 vs.
yaHALMAT2 with **matched** `--line-width`/`--line-length` settings on
the same compiled `halmat.bin` (also byte-identical). Confirms this
was purely an artifact of the original sweep's mismatched
configuration (yaHALMAT2 defaulted to 132 columns, gpc/yaGPC used
240) — see the parity-testing caveat now in `tools.md`. No change
needed on either side.

### 2.5 Formatting: output line-wrap / `PAGE`/`SKIP`/`TAB`/`COLUMN` positioning

`test_write_wrap`, `test_dots`, `test_tabcol`, `test_skipline`,
`test_page`, `test_write_vector`, `test_vsum` all show wrapping/column-
position differences. **Caveat that likely invalidates most of these as
real findings**: this sweep ran `gpc`/`yaGPC` with `--line-width 240`
but ran `yaHALMAT2 halmat.bin` with no `--line-length`/`--page-length`
override at all (its own defaults: 132/80 per device type, 66
lines/page) — an unmatched configuration, not a controlled comparison.
**Before trusting any of these**: rerun with matched settings
(`yaHALMAT2 --line-length 240 --page-length <whatever gpc uses>
halmat.bin`) and see if the discrepancy survives. `test_tabcol`'s
difference (`FIRSTSECOND THIRD` vs. `SECOND THIRD FIRST` — a genuinely
different *ordering* of fields, not just wrapping) looks less likely to
be a pure line-width artifact and more likely a real `TAB`/`COLUMN`
positioning-logic difference — worth checking first if only one item
from this bucket gets attention.

**Status (2026-07-26): `test_tabcol` confirmed as a genuine yaGPC2/gpc
bug and fixed. The other 6 tests in this bucket
(`test_write_wrap`, `test_dots`, `test_skipline`, `test_page`,
`test_write_vector`, `test_vsum`) were never individually re-checked
with matched line-width settings** — given this caveat's own warning
above, some or all of them may turn out to be the same
mismatched-configuration artifact as 2.4, but this has not been
verified either way; re-run them with matched settings before assuming
they're either fixed-by-the-2.5-fix or still-open.

`test_tabcol`'s root cause: `src/halucp.c`'s TAB handler explicitly
logged "negative tab, unimplemented" and no-op'd instead of correctly
handling `TAB(negative)`/backward `COLUMN()` values — confirmed
against the HAL/S Programmer's Guide's own worked example
(`USA003087.txt` lines 6106-6150, using this exact test's WRITE
statement as its illustration). The real fix turned out to be
architectural, not a formula tweak: `yaGPC2` streamed WRITE output
directly to the output callback as each field was processed, which
structurally cannot place a later-column field before an
earlier-column one on the same line (a real stream can't move
backward). Ported yaHALMAT2's own already-correct model (its
`interp.c`'s `dm_write_at`/`dm_emit_field`/`dm_finalize_line`): buffer
each channel's current (not-yet-newline-terminated) line in memory
(`HalUCP.lineBuf[]` etc., `src/halucp.h`), write fields into it at
their target column in any order via `buf_write_at()` (mirroring
`dm_write_at`'s "overstrike, not replace-to-end-of-line" semantics),
and flush to real output only when the line actually advances. Added a
`positioned[ch]` flag (reset at IOINIT, set by any of
TAB/COLUMN/SKIP/LINE/PAGE) so a *leading* TAB in a WRITE statement
correctly uses the column the mechanism was already at *before* the
statement's default line-advance (matching `USA003087` Fig. 12-5's own
worked example), not column 1. Verified byte-for-byte identical to
yaHALMAT2 on `test_tabcol` with matched line-width settings.

Two regressions were caught and fixed during implementation, both
worth knowing about if this code is touched again: (1) the SVC `0x0015`
program-halt handler emitted a bare trailing `"\n"` per channel
directly, bypassing the new buffer and silently discarding the last
line's content — fixed by routing it through `hal_newline()` instead.
(2) A compiled WRITE statement issues a fresh IOINIT call *per field*,
not once per statement — IOINIT's "no real line movement" branches
were hardcoding `toCol=1` (harmless under the old streaming model, but
exposed once the new buffering model no longer had the old
accidentally-compensating guard), corrupting every multi-field WRITE
statement's output; fixed by only resetting `toCol` to 1 on a genuine
new line, otherwise carrying the current column forward. Given this
was a substantial rewrite of the core WRITE-output mechanism (affects
every HAL/S program's output, not just TAB/COLUMN users), it deserves
extra scrutiny before being considered fully settled — a broader sweep
re-run against the full yaHALMAT2 test corpus (with matched settings)
would be worthwhile if this file is revisited.

### 2.6 `RUNTIME()`/`DATE()`/`CLOCKTIME()` not comparable; `RANDOM()`/`RANDOMG()` are actually deterministic

`test_random`, `test_runtime`, `test_date_clocktime` all differ.
`RUNTIME()`/`DATE()`/`CLOCKTIME()` are genuinely wall-clock-dependent —
`gpc` and `yaHALMAT2` have no simulated master clock in common, so these
remain not meaningfully comparable, expected to differ, not evidence of
a bug on either side.

**Status (2026-07-26): confirmed as-is for `RUNTIME`/`DATE`/`CLOCKTIME`,
no action possible or needed.**

**Correction (2026-07-28): `test_random`'s premise was wrong — `RANDOM()`
and `RANDOMG()` are fully deterministic on real hardware, not
PRNG-non-comparable at all.** Per direct reading of `RUNASM/RANDOM.asm`:
the generator is a classic IBM System/360 SSP "RANDU"-family linear
congruential generator (`X(n+1) = 65539*X(n) mod 2^32`), seeded from a
fixed `SEED=1435` constant baked directly into the object code — no
wall-clock or hardware entropy anywhere. `yaGPC2` (executing the real
compiled routine) is 100% run-to-run reproducible for any program using
`RANDOM`/`RANDOMG`; `yaHALMAT2` previously used its own unrelated
method and couldn't be compared against it at all.

Produced and rigorously verified a bit-exact C reference implementation
(`yaGPC2/reference-impls/hal_random.{h,c}`, untracked scratch files, not
committed) for `yaHALMAT2` to adopt. Two real bugs were found and fixed
in the reference *during* its own verification (both caught only by
diffing against `yaGPC2`'s actual `--trace` execution, never by static
reading of the assembly alone):
1. `M R6,SEED` is not a plain S/360 signed multiply on this CPU —
   `exec_M` routes even-register multiplies through `q31_mul32()`,
   which left-shifts the 64-bit product by 1 bit before splitting into
   the register pair (a Q31 fixed-point convention), and the following
   `SRDA R6,1` exactly cancels that shift; net effect of `M`+`SRDA`+`LR`
   together is a *plain* truncating 32-bit multiply.
2. `CVFL F0,R6` never touches its paired register `F1` (confirmed
   against `exec_CVFL` — no `F(x+1)` store at all), so `F1` holds
   whatever the *previous* floating-point op on that pair left behind
   when the following `MED` reads `F0:F1` as an extended pair. This
   resolves to a fully deterministic chain (not garbage), since exactly
   two instructions ever write `F1`: `MED` itself every call, and
   `RANDOMG`'s own epilogue (`LER F0,F2`/`LER F1,F3`), which repackages
   the Gaussian accumulator into `F0:F1` as the declared return value
   and, as a side effect, overwrites the chain with *that* result's low
   word instead of the 12th internal draw's.
3. Also corrected along the way: the correct built-in name is
   `RANDOMG` (`USA003088.txt` Sec. 9397/9399), not `RANDG` as originally
   guessed from the RTL routine's own internal label.

Verification: bit-exact match confirmed for 5 consecutive `RANDOM()`
calls interleaved with `WRITE`s, 3 consecutive `RANDOMG()` calls with
nothing in between, and a 20-call sequence mixing both in arbitrary
order — all diffed against `yaGPC2` actually compiling and running real
HAL/S test programs, not derived from static analysis alone. Logged as
`yahalmat2_random_not_deterministic` — **now `fixed`** on yaHALMAT2's
side, adopting this algorithm.

**Known scope limitation, tracked as its own entry
(`random_reference_f1_chain_disrupted_by_other_float_ops`, `status=deferred`):**
the F1-chaining model above was only verified for back-to-back
`RANDOM`/`RANDOMG` calls with nothing but `WRITE`s in between. Real
corpus code doesn't look like that — `071-DARTBOARD_APPROXIMATION.hal`
computes with drawn values (`X**2+Y**2`-style) before drawing again. A
direct repro (`X=RANDOM; Y=RANDOM; Z=X**2+Y**2; V=RANDOM;`) confirms `X`
and `Y` match the isolated-chain prediction exactly, but `V` (the 3rd
draw) diverges once `Z`'s computation has touched `F0`/`F1` in between —
`yaGPC2` gets this right for free (real register-level execution);
`yaHALMAT2` and the reference model `RANDOM`/`RANDOMG` in isolation with
no representation of the rest of the program's floating-point register
state. Bit-exact matching for any program computing anything with a
drawn value before the next call isn't achievable without `yaHALMAT2`
tracking F-register low-order-bit state across *every* floating-point
op, not just `RANDOM`/`RANDOMG` — a much bigger undertaking than
adopting the self-contained algorithm. The core algorithm/determinism
finding above remains correct and useful; this only narrows what
"fixed" covers.

**Status corrected `deferred` → `open` (2026-07-28), per a clarified
standing rule**: `deferred` means "doesn't need fixing *right now*, but
must be fixed before the next project phase" — not indefinite
"someday, not this phase." A real fix path exists here in principle
(tracking F-register state more generally), so it can't sit
indefinitely just because it's substantial engineering; still open, now
tracked at `medium` severity.

**`RUNTIME()`/`DATE()`/`CLOCKTIME()` — resolved for real (2026-07-29),
correcting an intermediate mischaracterization.** An earlier pass of
this file corrected the framing from "genuinely wall-clock-dependent"
to "simply SVC-trapped/unimplemented" (confirmed: no `RUNTIME`-handling
code in `halucp.c`, no `RUNASM/` source backing them), speculating
`RUNTIME()` specifically might mean a simple, implementable "simulated
elapsed mission time." Reading the real, confidential FCOS source for
SVC 22 (`FPMTMHAL.asm`, "HAL/FCOS TIME MANAGEMENT INTERFACE") settled
it: `RUNTIME()` calls `FPMGMTIM` (a continuously-updating GMT-style
clock, driven by a periodic hardware timer interrupt at the OS level),
while `CLOCKTIME()` uses the task scheduler's own TQE tick machinery —
the *same* real-time task-executive infrastructure §2.7 already
confirmed has no backing implementation anywhere in this toolchain
(checked `120-EXAMPLE_A.hal`'s own `.fcm.LIST`: only the single `START`
module is linked, the identical "nothing to link against" signature
§2.7 already used to accept `SCHEDULE`/`WAIT` as a genuine scope
boundary). `RUNTIME()` therefore folds into that same already-accepted
boundary, not a separately-fixable gap. `DATE()`/`CLOCKTIME()` remain a
different, separate case: confirmed via `yaHALMAT2`'s own `interp.c`
that it deliberately implements them via real OS wall-clock time
(`time()`/`localtime()`) — genuinely non-deterministic/non-comparable
across runs by design, confirming the *original* framing was right for
these two specifically. Logged as
`runtime_svc_miscategorized_as_wallclock_nondeterminism`,
`status=not_a_bug` — no code change, not fixable without the same new
periodic-timer/interrupt subsystem §2.7 already declined to build.

**`RUNTIME()` — implemented for real (2026-08-17), correcting the
"folds into the same boundary" conclusion above.** §2.7's own scope
boundary got superseded by a real `TASK`/`SCHEDULE`/`WAIT` implementation
this session, and with it came exactly the missing piece this entry
assumed `RUNTIME()` needed: `cpu->elapsedTimeUs`, a real, working
virtual-time clock (`schedule.c` already uses it for every dispatch
decision). `RUNTIME()`'s own SVC number, confirmed here independently
back in July from `FPMTMHAL.asm` (SVC 22, i.e. `0x16` hex) and now
re-confirmed empirically by compiling and tracing a real `T = RUNTIME;`
program, is simply that clock, converted from microseconds to seconds
and written into FP0-FP1 — it never needed `FPMGMTIM`'s real hardware-
timer-interrupt machinery in the first place, only *a* monotonically-
advancing clock, which `cpu->elapsedTimeUs` already is. Implemented as
the `svcCode == 0x0016` case in `halucp.c` (`hal-runtime-features.db`
id 28, `not_implemented` → `implemented`). `RUNTIME()`'s *value* still
isn't comparable against `yaHALMAT2`'s own output, same as before — but
now because two independently-invented instruction-timing models can't
agree at that precision (§7.4/§7.5), not because the feature is
missing; verified in isolation instead via `test_schedule.c`'s scenario
5. `CLOCKTIME()`/`DATE()` remain unimplemented and out of scope for this
pass — `CLOCKTIME()`'s own TQE-tick-machinery tie is a materially
different (and more involved) mechanism than `RUNTIME()`'s simple clock
read, not yet investigated for whether the same shortcut applies.

### 2.7 Real-time task model (`SCHEDULE`/`WAIT`/`TASK`/priority): was a scope boundary, now implemented (2026-08-17)

27 of the 73 are `SCHEDULE`/`WAIT`/task-related:
`test_canc_control`, `test_countup2`, `test_mshp`,
`test_nested_task_schedule`, `test_prio`, `test_sched_after`,
`test_sched_at`, `test_sched_every`, `test_sched_every_wait`,
`test_sched_high`, `test_sched_in`, `test_sched_low`,
`test_sched_on_compound`, `test_sched_on_compound_or`, `test_sched_on`,
`test_sched_self_on`, `test_sched_stopping_only`,
`test_sched_until_compound`, `test_sched_while`, `test_sshp_ishp`,
`test_wait_dependent`, `test_wait_for_compound`, `test_wait_for_event`,
`test_wait_until`. Most show `yaHALMAT2` timing out (exit code 124 in
the raw log) under this sweep's generic 10-second timeout and plain
invocation — `yaHALMAT2` almost certainly needs its own
`run_realtime_fixture.sh`/`run_walltime_fixture.sh`-style invocation
(simulated-time acceleration options) for these, which this generic
sweep didn't use. Where `yaGPC`/`gpc` *did* produce output (e.g.
`test_countup2`/`test_canc_control` showing `N=0`, i.e. the scheduled
task body appears to never have actually run), that's consistent with
`gpc`'s bare CPU/IOP simulation genuinely having no real-time task
executive/scheduler at all — plausibly a hard scope boundary (`gpc`
simulates the AP-101 hardware, not a flight-software OS layer), not a
fixable "bug," but worth a primary-source check on what `SCHEDULE`
actually compiles down to (an HALMAT-level `SCHD` opcode presumably
calling into a runtime task-management library that would need to be
*linked in* — check whether `lnk101`'s output for these programs even
includes such a library, the way `IOINIT`/`HIN`/`COUT` are linked in
for I/O) before concluding it's unfixable rather than just unlinked.

**Status (2026-07-26): confirmed as a genuine scope boundary, not a
fixable bug.** Compiled and linked `test_sched_on.hal` and inspected
the `.fcm.LIST` module table directly: only I/O support modules get
linked (IOINIT/COUTP/CASPV/CASV/`#Q*`-trap-stubs) — no SCHD/task-
scheduling runtime module appears anywhere. This toolchain has no
backing implementation for real-time task semantics to link against at
all; `gpc`'s bare CPU/IOP simulation genuinely has no task executive.
Not fixable within yaGPC2's current scope without building an entirely
new runtime subsystem — no action taken.

**Superseded (2026-08-17): a minimal task executive is now
implemented in `yaGPC2` itself, at the same SVC-trap level it already
substitutes for FCOS's SEND ERROR/QUIT/EVENT handling.** The
"nothing to link against" finding above was correct and remains the
reason this can't be solved by *linking* anything — real hardware
never links a task-scheduling module into a compiled program at all
(confirmed again: no such module in any `.fcm.LIST` for a
`TASK`-using program). But tracing a real compiled program's exact SVC
traffic (a user-provided `COUNTUP.hal`: one `TASK`, `SCHEDULE ...
REPEAT EVERY`, one `WAIT`) showed the SVC protocol matches the real
Space Shuttle FCOS interface precisely, documented in `IBM-76-SS-1110
Rev 5` (the HAL/FCOS Interface Control Document) — SCHEDULE is always
SVC #1 with a well-defined parameter block, WAIT is SVC #6/7/8/9 by
variant, and a task's own `CLOSE` reuses the same SVC #`0x15` the main
program's `CLOSE` does. That's a real, well-scoped protocol to
implement a substitute for, the same way `halucp.c` already
substitutes for FCOS's other SVCs — it no longer needed "an entirely
new runtime subsystem" in the open-ended sense the note above meant,
just one more SVC-trap handler alongside the existing ones.

New files `src/schedule.h`/`schedule.c` implement a minimal,
cooperative-only (non-preemptive) task executive: `SCHEDULE ...
PRIORITY(n), REPEAT EVERY <seconds>;`, delta-time `WAIT <seconds>;`,
and priority-ordered dispatch among simultaneously-due tasks, wired
into `halucp_handle_svc()`'s existing SVC dispatch (`src/halucp.c`/
`.h`) with zero changes needed to `gpcops.c`'s or `run.c`'s own
instruction-step loops (every task switch happens synchronously inside
an SVC handler, matching `yaHALMAT2`'s own non-preemptive scheduling
model). `AT`/`IN`/`ON`/event-expression scheduling, `DEPENDENT`,
`UPDATE PRIORITY`, `CANCEL`, `TERMINATE`, and register-bank-1 context
save/restore are explicitly out of scope for this cut (real FCOS itself
didn't support `DEPENDENT`/`UPDATE PRIORITY` either, so this isn't a
new gap relative to the real system).

Verified end-to-end against `COUNTUP.hal` two ways: (1) zero regression
— the full existing unit-test suite and `test/test_debugger.sh`'s
golden-transcript tests pass unchanged, since `sched_handle_task_close`
returns `false` immediately whenever scheduling was never engaged,
guaranteeing every fixture with no `TASK`/`SCHEDULE` behaves exactly as
before; (2) output correctness — `yaGPC2`'s output for `COUNTUP.hal` is
byte-identical to `yaHALMAT2`'s own output for the same source (both
print `1` through `200`, one per line, then halt cleanly), used as the
independent oracle in the absence of any `gpc`-side implementation to
compare against.

Permanent regression coverage, both run as part of `make test`:

- **Tier 2 — `test/test_scheduler.sh`**: a golden-transcript test in the
  same style as `test_debugger.sh`, running the real
  HALSFC/lnk101-compiled `COUNTUP.hal` fixture end-to-end and diffing
  its output against the yaHALMAT2-oracle golden file above. Fixture
  sources at `test/fixtures/countup.hal`/`.fcm`/`-lnk101.json` (rebuild
  via `test/fixtures/build_hal_fixtures.sh`).
- **Tier 1 — `test/test_schedule.c`**: hand-assembled AP-101 task
  bodies at flat (non-extended) addresses, driven through `ap101_exec1()`
  directly (no HAL/S compile step), asserting scheduler internals a
  compiled fixture's stdout can't show: which of two simultaneously-due
  tasks the scheduler actually picks by priority, that a suspended
  task's full register/FP state round-trips exactly across a `WAIT`,
  and that `elapsedTimeUs` advances in discrete per-firing jumps to each
  deadline (not free-running with instruction count) across a `REPEAT
  EVERY` + `WAIT` scenario.

Not added to `test/run_matrix.sh`: that script's whole design is
diffing `yaGPC2` against the frozen pre-rename `yaGPC` snapshot and the
original Node.js `gpc` (see this file's own "authoritative parity
target going forward" policy note near the top) — both permanently
absent from this checkout by design, not a gap to fix, and neither ever
had any task-executive code to diff against in the first place (this
section's own history above). The `test_scheduler.sh`/`test_schedule.c`
coverage above is authoritative for this feature instead.

**Wall-clock pacing added (2026-08-17), standalone CLI only.** The
implementation above deliberately only tracks *virtual* time
(`cpu->elapsedTimeUs`, purely instruction-derived) — `sched_dispatch()`'s
idle fast-forward jumps straight to the next deadline with no real
sleeping at all, so `COUNTUP.hal`'s ~199.5 program-seconds originally
ran in a fraction of a real second, unlike `yaHALMAT2`, which paces
itself against real wall-clock time by default. That asymmetry was
correct for `yaGpcIntegration.h`'s embeddable `GpcEngineFn` (a future
Space Shuttle simulator integrator owns its own pacing against
`GpcState.elapsedTime`; the engine itself must stay wall-clock-unaware,
matching `yaHALMAT2`'s own `interp_step()`/`debug_run()` split) but left
the standalone `gpc run` CLI with no real-time behavior at all, unlike
`yaHALMAT2`'s CLI.

Fixed by adding `--time-scale <factor>` to `yaGPC2`'s CLI, mirroring
`yaHALMAT2`'s own flag byte-for-byte (name, semantics, default 1.0 =
genuine real time). Implemented as a burst-execute-then-check pacing
loop in `run.c` (`batchrunner_pace()`, called from both
`batchrunner_run()` and `batchrunner_run_interactive()`'s step loops,
skipped entirely under `--debug` so time blocked on a debugger prompt
never counts against real time) — the same design `yaHALMAT2`'s
`interp_run_burst()` already uses, right down to the ~50ms polling
window. Deliberately layered *outside* `batchrunner_step()`/
`ap101_exec1()` rather than inside either: the CLI's own loop is just
another consumer of the same pure-virtual-time engine an embedding
integrator would use, pacing itself against the identical clock
(`cpu->elapsedTimeUs`, exposed to an integrator as `GpcState.elapsedTime`)
an integrator is expected to pace against — demonstrating that pattern
rather than giving the engine (`ap101_exec1()`, `gpcops.c`'s
`yagpc2_engine()`) any wall-clock awareness of its own. Confirmed the
engine layer is untouched: `test_gpcops`/`test_schedule` (which call
`ap101_exec1()`/`yaGPC2_ops.engine()` directly, never through `run.c`)
still complete instantly regardless of `--time-scale`.

Verified against `COUNTUP.hal`: `--time-scale 100` completed in 2.012s
real time against an expected 1.995s (199.5 program-seconds / 100),
output byte-identical to the unpaced run; the default (no flag, i.e.
1.0) was confirmed to genuinely pace output roughly one `WRITE` line
per real second rather than completing instantly. `test_scheduler.sh`
now passes `--time-scale 1000000` explicitly (matching how the
`yaHALMAT2` oracle capture itself was sped up) so `make test` isn't a
199.5-real-second test — this doesn't change the golden file, since
`--time-scale` never touches program output, only how much real time
elapses alongside it.

**`--pacing=signal` added (2026-08-17), matching `yaHALMAT2`'s own
alternative implementation.** `--time-scale`'s pacing above (now named
`--pacing=burst`, the default) is a polling design: periodically ask
"how much wall-clock time has elapsed?" `yaHALMAT2` also ships a second
implementation, `interp_run_signal()` — a POSIX real-time-timer
(`timer_create`/`SIGRTMIN+2`) plus `sigsuspend()`-driven design that's
*notified* on a fixed schedule instead of asking, added there purely
for side-by-side comparison against its own burst mode ("both implement
the same pacing contract and produce identical program output, only
wall-clock jitter/precision differs"). Ported to `run.c` essentially
line-for-line as `batchrunner_pace_signal()`/
`batchrunner_pace_signal_setup()`/`_teardown()`, selected via
`--pacing burst`/`--pacing signal`, gated on a new `HAVE_POSIX_TIMERS`
build-time probe in the `Makefile` (mirroring `yaHALMAT2`'s own probe
byte-for-byte — `timer_create`/`timer_settime` have historically been
unreliable or absent on some BSD-family systems, including macOS) —
without it, `--pacing=signal` fails loudly at startup with a clear
message rather than silently falling back to burst mode or crashing.
Verified against `COUNTUP.hal`: `--pacing signal --time-scale 100`
completed in 2.004s real time (burst: 2.012s; expected 1.995s), output
byte-identical to both the unpaced and burst-paced runs.
`test_scheduler.sh` now runs both `--pacing` modes against the same
golden file.

### 2.8 Floating-point LSB-level precision differences (likely not bugs)

`test_errfix_scalar`, `test_bfnc_hyperbolic`, `test_bfnc_invtrig`,
`test_errfix_matrix`, `test_vec`, `test_vec_atpartition`,
`test_array_of_vector`, `test_multi_assign_mixed`, `test_scalar_double`
all show tiny last-significant-digit differences in transcendental
function results (`LOG`, `SINH`/`COSH`/`TANH`, `ARCSIN`/`ARCCOS`, matrix
inverse) or double-precision arithmetic. Most plausible explanation:
`gpc` emulates real IBM hex (base-16 exponent) floating point
(`floatIBM.coffee`, ported faithfully in `yaGPC`'s `floatIBM.c`) while
`yaHALMAT2` almost certainly uses native IEEE double throughout — these
are two different, both "correct," floating-point representations with
different rounding characteristics, not necessarily a bug in either.
Lowest priority in this file unless a specific one turns out to matter
for some downstream computation.

**Status (2026-07-26): confirmed as-is, no action needed.** — **superseded,
this framing was wrong (2026-07-28).** The user's own assessment: "`yaHALMAT2`
should be using IBM Hex Float, and if it is not, it's probably a
failure on my part to specify it. I consider that a very big bug, even
if I'm the one who caused it." Confirmed via `yaHALMAT2 --help`: no
`--float-format`/`--hex-float`/`--ieee` flag exists at all, ruling out
"forgot to pass a flag" and pointing to native IEEE double being used
throughout with no IBM hex float mode available — logged
`yahalmat2_uses_ieee_double_not_ibm_hex_float`, `open`, high severity,
as the likely single largest remaining source of this file's whole §2.8
bucket.

**Correction (2026-07-28): the "uses native IEEE double throughout"
framing was itself not accurate**, per direct inspection of
`yaHALMAT2`'s `value.c`/`interp.c` (not just `--help` output). Verified
independently (not just taken from `yaHALMAT2`'s own claim):
`halmat_scalar_add()` genuinely performs IBM System/360-style hex-float
arithmetic — real sign/characteristic/fraction extraction (7-bit
base-16 exponent, 24/56-bit hex fraction), hex-digit-aligned shifts, a
signed-magnitude add, and postnormalization — wired into every core
`SCALAR`/`MATRIX`/`VECTOR` arithmetic opcode, not a native-double
approximation. The real, much narrower gap: roughly 50 call sites
(transcendental/special functions, matrix inversion's Gauss-Jordan
elimination, `RANDOM`/`RANDOMG`, `DFOR`/`CFOR` loop-control increment
arithmetic, `READ`-statement decimal-text parsing) went through a
native-double intermediate, for functions with no available
primary-source hex-float RTL algorithm to port instead — not a
blanket architectural fidelity gap needing a full floating-point-core
rewrite.

**Further correction (2026-07-29), per direct user clarification: the
authoritative target for `yaHALMAT2`'s numerical fidelity is real
AP-101S flight hardware/software, not real `gpc`/`yaGPC`** — `gpc`
itself only ever achieved *partial* hex-float authenticity (basic
arithmetic only). `yaGPC2` is this project's newer, fully-authentic
reimplementation (genuine hex-float for `SQRT`/transcendentals/matrix-inversion,
not just the four basic ops, simply by virtue of executing the real
compiled AP-101S RTL machine code rather than reimplementing each
function — see §5's introduction for why that asymmetry exists
structurally) and is now the correct cross-check target. Per the user's
explicit standing rule (see the standing policy note near the top of
this file): development cannot proceed until
`yaHALMAT2` and `yaGPC2` reach parity, including cases where that means
`yaHALMAT2`'s output must now *diverge* from old `gpc`/`yaGPC`.

**Closed out (2026-07-29)**: every RUNASM transcendental/matrix routine
identified as needing a genuine hex-float port (`EXP`, `LOG`, `ATANH`,
`ASINH`, `SQRT`, `ATAN`, `ATAN2` single+double, `COSH`, `SINH`, `TANH`,
`ARCCOSH`, and `MATRIX**-1` single+double for every N) has been ported
and independently verified bit-for-bit against `yaGPC2`'s own real
execution — `status=fixed`, high severity, closing out the whole
finding. Two narrower, explicitly-out-of-scope-for-now residual gaps
remain documented on `yaHALMAT2`'s own side (MMWSNP/assignment-copy
odd-companion-register leakage; `MATRIX(...)`-literal-constructor
leakage) — neither affects the RTL ports themselves, only the accuracy
of entering FPU state at certain mainline call sites. **However, §5's
fresh full-corpus sweep against this "closed" state still found real,
concrete residual gaps** (`double_to_single_scalar_assignment_narrowing_mismatch`,
`array_of_vector_element_write_precision_format_mismatch`,
`tan_function_possibly_missed_by_hex_float_port` — plain `TAN` notably
absent from the ported-function list just above) — a good illustration
of this project's own standing rule that a narrower root cause doesn't
by itself justify a severity/urgency downgrade without independently
confirming it actually explains the originally-observed evidence.

### 2.9 Not yet characterized — needs individual follow-up

Originally: `test_bfnc_char` (`13` vs `0` for a character built-in
function — possibly a `yaHALMAT2` scope gap analogous to
`YERRORS.md`'s finding 3 about the older `yaHALMAT`, or possibly
real), `test_bit_conv` (`CHARACTER(BIT)` conversion: `yaGPC` renders
the literal bit pattern `"00001100"`, `yaHALMAT2` renders `"12"` — a
real, checkable semantic question about what `CHARACTER()` of a `BIT`
value should produce), `test_bit_write` (a bare `HEX'1234'` literal's
default bit-width in `WRITE`: `yaGPC` treats it as 16 bits,
`yaHALMAT2` as 32), `test_tint_null_terminal` (bit-width again: 4
groups of 4 vs. 8 groups of 4 — likely related to 2.2/the
`test_bit_conv` family), `test_link_prog_array` (integer-style vs.
scalar-style `0` formatting — possibly an artifact of this sweep's
simplified single-file link not matching what this multi-file-linking
test actually needs), `test_errgrp_errnum` (`3,3` vs `4,5`) and
`test_errfix_trig` (`3` vs `2147483647` — the latter being
`INT32_MAX`, likely an error/overflow sentinel value, so probably
related to the same error-group/error-number reporting as
`test_errgrp_errnum` and to the 2.1 `ON ERROR` finding above),
`test_subbit_scalar` (`0` vs `1093140480` — note `1093140480 =
0x41200000`, the IEEE-754 bit pattern for `10.0f`, suggesting a
type-confused/uninitialized-memory read on one side rather than a
"both answers are plausible" case), `test_ext_double` (both sides
effectively broken — `yaGPC` prints all-zero garbage, `yaHALMAT2`
prints nothing, both exit 1 — likely this sweep's simplified
single-file compile not providing whatever external declaration this
test needs, not a real finding). See `sweep_raw_results.txt` for each
one's exact original output.

**Per-item status as of 2026-07-27:**

- **`test_bfnc_char`** — **investigated 2026-07-27: a confirmed, real,
  inherited bug — but in the actual 1980s HAL/S runtime library itself
  (`CINDEX.asm`), not in yaGPC2, yaGPC, or `gpc`, all three of which
  faithfully execute it as-is.** `I1 = INDEX(C1, 'ZZZ')` (`C1 =
  'HELLOWORLD'`, no `'ZZZ'` substring present) gives `13` from
  `gpc.js`/`yaGPC`/`yaGPC2` identically (confirmed by running all three
  directly), but `USA003088.txt` (Language Specification) explicitly
  states `INDEX` "otherwise zero is returned" when not found — and
  `yaHALMAT2` correctly gives `0`. This is the first finding in this
  whole file where the *real, compiled runtime library code itself* is
  the confirmed bug, not a comparison artifact or a real-but-authentic
  hardware quirk. Traced via `--trace`, and a bogus 3-byte "match"
  turns up in whatever's just past the string's real data (checking
  position 13 in a 10-character string against a 3-character key),
  which then gets returned as if it were a genuine index.

  **Correction (2026-07-27, prompted by a user challenge to the
  mechanism below): the original write-up's claimed mechanism was
  wrong.** It had concluded `CINDEX`'s outer bounds check (`AR R2,R1` /
  `CR R2,R5` / `BH NO`) itself "never fires" — checked directly against
  `yaGPC2`'s own (fixture-validated) `exec_BCF`/`exec_CR`/
  `cpu_compute_cc_arith` rather than assumed: `BH` (compiled to `BCF`,
  mask=1) correctly branches only on `CC==1` ("greater"), and at every
  sampled iteration the compared values genuinely did satisfy "still
  fits" (`CC==3`) — the branch was behaving completely correctly on its
  actual inputs. **The real, corrected mechanism, one level up:**
  `CINDEX`'s `END_OF_COMPARE` setup (`LH R6,0(R2)` / `NHI R6,X'00FF'` /
  `AR R2,R6`) adds `CURRENT_LENGTH(C1)` scaled as `N*0x10000`, but the
  same routine's own per-character `GTBYTE`-based address stepping
  (used everywhere else in it) advances one character via `+0x8000` —
  exactly double the correct address-space span for a 10-character
  string, confirmed numerically (`LH`'s raw descriptor value
  `0x0a0a0000` → masked `0x000a0000` = 10, added directly to
  `NAME(C1)`). `GTBYTE` itself remains internally consistent and not
  the culprit — the 2× unit-scale mismatch is entirely in `CINDEX`'s
  own one-time `END_OF_COMPARE` setup arithmetic. This still leaves
  `CINDEX.asm` (the real, public-domain 1980s runtime library) as the
  confirmed bug location, just via a different, now-verified mechanism —
  not a `yaGPC2`/`gpc` mnemonic-decoding issue.

  **Update (2026-07-28): FIXED — directly in the real, historical
  `CINDEX.asm` source, via a deliberately reversible mechanism.** The
  user was, understandably, very reluctant to touch real 1980s Shuttle
  flight-software RTL source irreversibly. Design worked out
  collaboratively: `ASM101S.py` (the modern reimplementation of the
  AP-101S assembler this project uses,
  `~/git/virtualagc/ASM101S/`) now unconditionally pre-defines a global
  `SETB &ASM101S=True` before reading any source file — no build-flag
  needed anywhere. `CINDEX.asm` declares `GBLB &ASM101S` itself (a
  completely standard, zero-object-code pseudo-op) and gates the fix
  behind `AIF (&ASM101S)...`: under `ASM101S.py` the symbol already
  exists (`True`), so the `GBLB` is a no-op and the fixed logic
  assembles; under any *other*/historical assembler that's never heard
  of `&ASM101S`, the same `GBLB` line freshly declares it defaulting to
  binary false, and the *original*, byte-for-byte-unmodified historical
  logic assembles instead. Confirmed via direct object-code comparison
  against a pristine, unmodified `CINDEX.asm` (`cmp`: identical) that
  this holds exactly — someone using a real historical assembler never
  has to touch or even notice the source changed.

  The actual fix covers **two** occurrences of the identical 2×
  address-scale bug, not one — a first attempt fixed only the outer
  `END_OF_COMPARE` occurrence described above, which is strictly *worse*
  than fixing neither: it desynchronized the two bounds calculations and
  broke a previously-working case (`INDEX(C1,'WORLD')`, a genuine match,
  started returning `0` instead of `6`), caught only by actually running
  the fixed build end-to-end before declaring it done. The second,
  previously-unnoticed occurrence is in the `NEWK:` retry-loop's own
  bounds check (`AR R2,R1`/`SR R2,R1`, the same un-rescaled address
  arithmetic on `CURRENT_LENGTH(C2)`) — fixed via a second `AIF`-gated
  branch computing a rescaled *copy* of `R1` into free register `R6`
  (`LR R6,R1`/`SRL R6,1`) for just that add/compare/subtract, leaving
  the real `R1` untouched since `BCTB` immediately afterward still needs
  it as a plain, unscaled loop counter. After both fixes, `yaGPC2` gives
  `6`/`0` for `INDEX(C1,'WORLD')`/`INDEX(C1,'ZZZ')` (was `6`/`13`),
  byte-for-byte matching `yaHALMAT2`.

  **Follow-up audit (2026-07-28, `gtbyte_sibling_routines_scale_audit`,
  `status=not_a_bug`):** checked the 9 other RTL routines sharing
  `CINDEX`'s GTBYTE/STBYTE-based string-traversal pattern (`CLJSTV`,
  `CPAS`, `CPASR`, `CRJSTV`, `CTOB`, `CTOE`, `CTOI`, `CTOX`, `CTRIMV`)
  for the same missing-rescale mistake — none found. Every manual
  pointer-displacement site in all 9 files already does the correct
  `SRL`/`SRA` #1 rescale before adding a count to a byte-pointer
  register (including `CRJSTV`'s `TRUNCATE` path, which is essentially
  the exact maneuver `CINDEX` needed and got wrong, done right); the
  rest never touch pointers manually at all. `CINDEX`'s bug looks like
  an isolated authoring mistake in one unusually tricky backward-search
  routine, not a systemic pattern.
- **`test_bit_conv`** — **resolved: was a yaHALMAT2 bug, now fixed on
  that side (2026-07-27).** `USA003087` Sec. 21.4's own worked example
  (a 4-bit string `0101` converting via simple-form `CHARACTER()` to
  the literal string `'0101'`) matches `gpc`/`yaGPC2`'s observed
  `"00001100"` output exactly — `yaHALMAT2`'s `BTOC` now maps each bit
  to a literal `'0'`/`'1'` character instead of formatting the pattern
  as decimal, matching. No yaGPC2 change was needed. See
  `problems-yaHALMAT2.md`, `test_bit_conv`, FIXED.
- **`test_bit_write`** — **resolved: was a yaHALMAT2 bug, now fixed on
  that side (2026-07-27).** The general rule was fully characterized
  empirically (compiled 15 `WRITE(6) <radix-literal>` variations
  through the real HALSFC compiler and read each one's compiled `LHI
  R6,<N>` width parameter): width = (bits-per-digit for that radix) ×
  (digit-count in source), leading zeros counted. This is baked into
  the compiled AP-101S machine code by the real compiler —
  `gpc`/`yaGPC2` just executes it; `yaHALMAT2` now reads its own
  litfile's width cell instead of discarding it. No yaGPC2 change was
  needed. See `problems-yaHALMAT2.md`, `test_bit_write`, FIXED.
- **`test_tint_null_terminal`** — **resolved: was the same yaHALMAT2
  bug category as `test_bit_write`, now fixed on that side
  (2026-07-27), confirmed as its own distinct code path.** The test
  declares `STATUS BIT(16)` explicitly, so `WRITE(6)
  FWDSENSORS.STATUS` should use the *declared* field's width, not a
  literal's own digit count — `yaHALMAT2` wasn't looking up a
  structure field's declared `BIT(n)` width for this kind of WRITE
  argument at all (defaulting to 32 bits), a genuinely separate fix
  from `test_bit_write`'s (which also, in fixing it, silently fixed
  the identical bug in two other fixtures). No yaGPC2 change was
  needed. See `problems-yaHALMAT2.md`, `test_tint_null_terminal`,
  FIXED.
- **`test_link_prog_array`, `test_errgrp_errnum`, `test_errfix_trig`,
  `test_ext_double`** — investigated 2026-07-27; see the dedicated
  write-up immediately below.
- **`test_subbit_scalar`** — **resolved: was the same yaHALMAT2 bug as
  §2.2/`test_bit` above, now fixed for free by that fix (2026-07-27),
  not actually a separate ambiguous case as originally assessed here.**
  This entry's own original "genuinely unresolved which is more
  correct" framing turned out to be too generous to `yaHALMAT2`'s
  side: once `yaHALMAT2` implemented real hardware's actual rule (a
  non-`DOUBLE` `INTEGER` truncates/reinterprets as signed 16-bit at
  `WRITE` time, confirmed via §2.2's `test_bit` investigation), this
  test's own divergence resolved automatically — it was never actually
  a precision-inference ambiguity, just the same missing truncation.
  No yaGPC2 change was needed. See `problems-yaHALMAT2.md`,
  `test_subbit_scalar`, FIXED.

### 2.9 `test_link_prog_array`, `test_errgrp_errnum`, `test_errfix_trig`, `test_ext_double` — investigated 2026-07-27

All four were properly re-tested with real multi-file compiling+linking
(the original sweep only ever attempted single-file compiles, which
cannot work for any of these — they all require a second unit/companion
file). Results:

- **`test_errgrp_errnum` — FIXED, a genuine yaGPC2/`gpc` omission, not
  a yaHALMAT2 discrepancy at all.** `I1 = ERRGRP;`/`I2 = ERRNUM;`
  compile to fixed SVC codes `0x0117`/`0x0217` (confirmed identical at
  every call site via a real compiled listing), which neither `gpc`
  nor `yaGPC` ever implemented (grep-verified against `gpc/halUCP.coffee`
  — it only ever handled SVC `0x0014`/`0x0015`). Fixed in
  `src/halucp.c`/`halucp.h`: `HalUCP.lastErrGroup`/`lastErrNum` track
  the most recent SEND ERROR (updated regardless of whether a handler
  was found), and the two SVC codes now write them into R5's upper
  halfword (the calling convention every compiled call site expects —
  confirmed via the compiled listing's invariant `STH 5,<dest>`
  immediately following each SVC). `test_errgrp_errnum` now outputs
  `0/0/2.0/4/5`, exactly matching yaHALMAT2. All 14 unit test suites
  still pass.
- **`test_errfix_trig` — now fully resolved (`cvfx_overflow_truncation_rule`,
  `status=fixed`).** `TAN`/`SIN`/`COS` agree already (not actually part
  of this discrepancy). The remaining line, `IRESULT =
  INTEGER(HUGESCALAR)` with `HUGESCALAR=5e10` (far outside `INTEGER`
  range): read `RUNMAC/ETOH.asm` (the real linked-in RTL conversion
  routine) and confirmed it has **no overflow check or `AERROR` call at
  all** — just `CVFX` + rounding-bias + `NHI R5,X'FFFF'` (mask to 16
  bits). `USA003090` App. C's documented "overflow errors may occur"
  fixup is aspirational here; the real routine just wraps silently.
  `gpc`/`yaGPC2`'s bare-hardware result is the authentic result of that
  real algorithm on this input — not a yaGPC2 bug, same "executes real
  compiled code faithfully" pattern as §2.3. **Update (2026-07-27): the
  real architectural split is now understood.** Space Shuttle flight
  software has an FCOS interrupt handler (`FPMCVFX`, in the real
  flight-software source
  `workspace/PFS/OI340600/SSSRC/FPMSDERR.asm`) that clamps a `CVFX`
  convert-overflow to +32767/-32767; a standalone HAL/S program with no
  real OS underneath it (i.e. everything this file tests) never gets
  that ISR, and instead sees whatever the bare `CVFX` instruction
  itself produces. `yaHALMAT2` (modeling "the whole system including
  FCOS") clamps; `yaGPC2` (a bare hardware emulator with no OS)
  shouldn't, by default — not a bug on either side, two different, both
  legitimate things being modeled. Added a new **`--fcos`** command-line
  flag to yaGPC2 (`src/opts.h`/`opts.c`, `src/cpu.h`'s new
  `CPU.fcosMode`, wired via `ageharness_configure_from_opts`) that
  simulates known FCOS/flight-OS behaviors a bare-hardware program
  doesn't get — so far exactly one case: `exec_CVFX` (`src/cpu_instr.c`)
  now clamps to +32767/-32767 by the source float's sign when `--fcos`
  is passed, reproducing `FPMCVFX` exactly. Also found and fixed, in
  the same investigation, a real, separate, previously-undiagnosed bug:
  `exec_CVFX` had been discarding its destination-register store
  *entirely* whenever `fibm_cvfx` signaled `FP_EXC_CONVERT_OVERFLOW`
  (the shared exc-then-bail pattern used by every other FP instruction
  in `cpu_instr.c`), leaving the register as stale, unrelated garbage —
  this, not a deliberate "bare hardware truncates" semantic, was the
  actual root cause of the old unreliable `3` result. Real `CVFX`
  always completes and stores *some* result before any interrupt is
  taken; `exec_CVFX` now always stores `fibm_cvfx`'s computed result
  (still signaling the exception for logging) instead of bailing before
  the store. Also confirmed along the way (tracing a normal in-range
  conversion): `CVFX`'s result is a **Q16.16 fixed-point value**, not a
  plain integer — `ETOH.asm`'s subsequent `+0x7FFF` bias and `NHI
  ...,X'FFFF'` mask/keep the *upper* 16 bits to extract the final
  rounded integer; the `--fcos` clamp values had to be pre-scaled by
  `0x10000` (`0x7FFF0000`/`0x80010000`) accordingly. Verified against
  `test_errfix_trig.hal` and ad hoc overflow test cases in both
  directions; all unit test suites pass. **Resolved on yaHALMAT2's side
  too (2026-07-27)**, independently, once this FCOS/no-FCOS split was
  understood — see `problems-yaHALMAT2.md`, `test_errfix_trig`, FIXED.
  **Additional confirmed trigger found 2026-07-28** (prompted by a
  possible-concern audit of runtime `INTEGER**INTEGER` exponentiation
  overflow, not a new bug): `B**E` for two genuinely runtime-valued
  `INTEGER SP` operands (forced non-foldable via `DO FOR` loops, e.g.
  `3**11`) compiles not to the integer-only `IPWRI`/`HPWRH` routines but
  to `EPWRI`/`EPWRH` (the *scalar*-to-integral-power routine, computed
  in floating point) followed by `#0ETOH`'s `CVFX`-based scalar→integer
  conversion — landing squarely on this same Q16.16-overflow mechanism.
  Not a new bug; just confirms the fix (bare default: silent truncation;
  `--fcos`: clamps to ±32767) applies correctly via a previously-untested
  call path.
- **`test_ext_double` — CONFIRMED as a pure sweep-methodology artifact,
  not a real bug.** Properly compiled+linked as a 2-unit program (the
  `DOUBLE_IT` procedure unit with `--parms=TEMPLATE`, then the calling
  `PROGRAM` unit via `D INCLUDE TEMPLATE`, then both `cards.bin`s
  linked together) — yaGPC2 outputs `5  10`, exactly matching
  yaHALMAT2's own expected value. The original "both sides broken"
  result was purely from compiling the bare `PROCEDURE` (no entry
  point) standalone, which can't work in any tool. No discrepancy
  exists.
- **`test_link_prog_array` — was a real yaHALMAT2 bug, now fixed on
  that side (2026-07-27, found asynchronously via the shared issue
  database rather than a document report).** Properly compiled+linked
  as a 2-unit program, yaGPC2 correctly outputs `10  20  30`
  (INTEGER-style) for the `EXTERNAL COMPOOL`-shared `SHARED_ARR
  ARRAY(3) INTEGER`. Turned out not to be COMPOOL-specific at all: per
  yaHALMAT2's own root-cause (`yagpc2-yahalmat2-issues.db`, key
  `compool_array_integer_type`), any whole `ARRAY(n) INTEGER` `WRITE`
  argument (local or `EXTERNAL COMPOOL`) went through a code path that
  always reported it as `SCALAR` regardless of declared type; fixed by
  broadening the WRITE-argument type-reclassification check to cover
  array-element reads, not just bare literals. No yaGPC2 change needed.

---

## 3. "Programming in HAL/S" worked examples — corpus sweep and completion

`~/git/virtualagc/yaShuttle/"Source Code"/"Programming in HAL-S"/` has
**98** `.hal` files (`NNN-NAME.hal`, `NNN` = the PDF page number in the
book where the original version of the code appears) — the worked
examples from the "Programming in HAL/S" textbook (Sept. 1978), the
same source `yaGPC`'s own port used for its `gpc/gen/A3GRESCH.fcm`-style
example corpus provenance. Unlike `yaHALMAT2`'s `src/tests/hal/`, there
was no `run_all.sh`-style harness or hardcoded expected output here.
**Status (2026-07-27): fully swept and completed.** This section covers
both passes: the initial yaGPC2-vs-yaHALMAT2 comparison sweep, and the
subsequent file-by-file completion of every "currently broken" file
(per the user's direction below).

**Important context, from the user, that reframes this whole corpus**:
the code in these files was taken from the book to illustrate HAL/S
language *syntax*, not to actually run — many never acquired usable
output, some are deliberately incomplete (omitted "..." sections, empty
function bodies) precisely because the book's point was the syntax
being shown, not the computation. Treating them as a runnable parity
corpus (as Section 2 treats `yaHALMAT2`'s `test_*.hal` suite) required
first bringing each file up to a state where it actually produces
comparable output — adding `WRITE` statements and/or termination
conditions, guided by each file's own code logic and, where that wasn't
enough, the corresponding book page's surrounding text (extracted to
`yaHALMAT2/source-documentation/ProgrammingInHALS.txt`, page-navigable
via `awk 'BEGIN{RS="\f"} NR==<page>{print}'`).

### 3.1 Initial sweep (all 98 files, before any corpus edits)

Same methodology as Section 2 (`--interactive --no-trace --no-verbose
--line-width 240`, stdout/stderr captured separately, `yaHALMAT2` run
with matched `--line-length 240`), with a per-file `timeout 10` and
`--max-steps 500000` (needed — see below). Results: **61 AGREE, 25
DISCREPANCY, 10 SKIP-COMPILE, 2 TIMEOUT**.

The 2 `TIMEOUT`s (`194-TEST_X.hal`, `250-BITS.hal`) were both confirmed
non-bugs: textbook excerpts with the illustrative loop body
*deliberately* omitted, leaving a genuine `DO WHILE TRUE;`/`DO WHILE
ON;` infinite loop with nothing in it — not a real finding, just needed
the per-file `timeout` (now permanently in the sweep script). The 10
`SKIP-COMPILE` files all needed the `TEMPLATE` compiler option and a
shared template library — see §3.5.

**Two real, confirmed `yaGPC2` bugs found and fixed** during this sweep
(both regressions from the earlier §2.5 line-buffering rewrite not
being fully propagated to every halt/prompt path — full detail in
`yagpc2-yahalmat2-issues.db` keys `read_eof_flush_missing` and
`interactive_prompt_raw_newline`): (1) the unhandled-READ-EOF halt path
in `halucp_provide_eof()` never flushed pending buffered output,
silently losing the last `WRITE`'d line in ~13 of the 25 discrepancies;
(2) `run.c`'s interactive-mode prompt logic used a raw `fputs("\n",
stdout)` (predating the §2.5 buffering model) instead of flushing the
actual buffer, corrupting output between consecutive `WRITE` statements
before a `READ`. Both fixed; re-running the full sweep after each
dropped the discrepancy count from 35 → 25. All unit test suites
re-verified passing after each fix.

**A confirmed real hardware behavior `yaHALMAT2` didn't model, affecting
7 files**: vector/matrix `WRITE` arguments always force a fresh output
line in real hardware (`RUNASM/MMWSNP.asm` unconditionally does `ACALL
SKIP`/`ACALL COLUMN` before each row) — `yaGPC2` executes this
faithfully; `yaHALMAT2` didn't model it and kept everything on one line.
Database key `mmwsnp_vector_forces_newline` (`029-DATATYPES`,
`106-EXAMPLE_2`, `117-EXAMPLE_8`, `119-EXAMPLE_9`, `134-DOTS`,
`136-DOTS`, `141-VSUM`) — **status corrected 2026-07-27 from
`not_a_bug` to `open`** (once a discrepancy is confirmed authentic
real-hardware behavior rather than a `yaGPC2`-only artifact, the
expected resolution is for `yaHALMAT2` to replicate it for fidelity, not
keep a "two legitimately different models" framing) — **now `fixed`**
on yaHALMAT2's side.

**Five `yaHALMAT2`-side findings** logged, all now `fixed`:
`function_result_scalar_integer_confusion` (a `FUNCTION(...) SCALAR`'s
call-result printed as `INTEGER`), `partition_array_shift_wrong` (a
sliding-window filter's partition-range array-shift assignment computed
a wrong result from the 3rd iteration onward — `yaGPC2` confirmed
correct by hand-computation), `radix_qualified_character_bit_ignored`
(`CHARACTER(bit)@HEX`/`@DEC`/`@OCT`/`@BIN` all gave the identical
`@BIN`-style answer, ignoring the qualifier), `bit_partition_extraction_mismatch`
(a single-bit `SUBBIT`-style extraction disagreed for one specific
index), and `integer_exponentiation_overflow_needs_fcos` — **the
original framing here was wrong, corrected 2026-07-27**: `052-TABLE.hal`'s
`2**(N-1)` has a literal compile-time-constant `N` at every call site,
so the real compiler constant-folds the whole exponentiation — there is
no runtime instruction and no program-interrupt involved, so `--fcos`
was never going to be relevant. `yaGPC2`'s wide output
(`128/2048/.../2147483647`) is simply that real compiled constant,
faithfully executed; `yaHALMAT2` clamped every one of these to `32767` —
*that* was the actual, sole bug, now fixed by honoring the HALMAT-level
width indicator instead of a blanket 16-bit clamp.

The remaining ~12 discrepancies were already-known, non-actionable
categories: the §2.4 leading-blank-line artifact (`047-ROWS`, `197-P`,
`198-P`), `RUNTIME()` non-determinism and — per §2.6's correction —
`RANDOM()`'s determinism now addressed via the reference algorithm
(`071-DARTBOARD_APPROXIMATION`, `134-ROLL`, `104-EXAMPLE_1`,
`120-EXAMPLE_A`), tiny IBM-hex-vs-IEEE floating-point precision (§2.8:
`205-LOG10`, `129-ALMOST_EQUAL`, `GOOGLE-PARALLAX`), and one
incomplete-textbook-excerpt case with empty function bodies
(`130-EXAMPLE_N`, revisited on its own terms in §3.4 below).

**`029-DATATYPES.hal`'s real divergence (not the leading-blank-line
artifact it was briefly filed under in an earlier pass — both tools
actually agree on that) is a matrix-inverse instability, confirmed
`not_a_bug`.** Three identical, back-to-back `A4I=INVERSE(A4A)` calls on
an unchanged, genuinely-singular 4×4 matrix give three *different*
results under `yaGPC2` (near-identity / wild ~1E12–1E13-magnitude
garbage / near-identity again). Traced via `--trace`: the underlying
`MM14SN` routine's own singularity-check branch (`AOUT`, which calls
`AERROR 27`) never executes for any of the three calls, even though the
matrix is exactly, provably singular — the divergence isn't about `ON
ERROR` dispatch at all, but about `MM14SN`'s own floating-point
pivot/determinant check never landing on exactly zero. Confirmed
directly from the real RTL source (`Source Code/PASS.REL32V0/RUNASM/MM14SN.asm`,
public domain): the general (N≠2) pivot-search singularity check loads
the running-largest pivot magnitude via `LE F0,0(R1,R2)` (single-precision,
never clears its extended-pair partner `F1`), then, after the full
pivot search, `LER F0,F0` / `BE AOUT` is an *extended* (register-pair,
`F0:F1`) self-compare-and-branch — the identical bug class the same
file's own N==2 special case demonstrates a few lines earlier verbatim
(`LE F0,2(R1)` / `LE F2,4(R1)` / `SEDR F0,F2` / `BZ AOUT`), and the same
class already accepted for `test_eron_goto`'s `MM14SN.asm` finding
(§2.1). `F1` retains whatever garbage the immediately preceding
floating-point work left behind — here, each `WRITE(6) A4I;`'s own
formatting work between the three `INVERSE()` calls. Logged as
`datatypes_repeated_singular_inverse_unstable_result`,
`status=not_a_bug` — genuine, faithfully-reproduced real hardware
fragility, confirmed via direct primary-source reading rather than an
independent JS reference.

**A brief false lead worth recording so it isn't rediscovered**: while
fixing §2.1's `inverse_singular_matrix_not_detected`, 198-P.hal (the
same `WRITE(6) M;` inside a `DO FOR` loop) appeared to be missing one
leading blank line that frozen `yaGPC` shows before its first output —
initially logged as `write_first_write_inside_do_for_loop_missing_skip`,
suspected to be a `yaGPC2` bug specific to loop bodies. Re-investigation
found the loop was never the differentiator (197-P.hal, no loop, has
the exact same discrepancy against frozen `yaGPC` — an earlier
diff had been mis-read as an exact match) and that frozen `yaGPC`'s own
`src/halucp.c` simply has no true-first-write suppression logic at all
in its `SKIP` handler — it predates this project's own already-validated
`write_first_ever_positioning_clobbered_by_internal_skip` fix (§3.1
below). `yaGPC2`'s current behavior is correct; the frozen reference is
just stale here. Logged `not_a_bug`. **Lesson**: frozen `yaGPC` is
reliable where independently confirmed against real FCOS/compiled-trace
evidence (as with `inverse_singular_matrix_not_detected` above) — but it
is not automatically authoritative for every mechanism, since it can
itself be out of date relative to `yaGPC2`'s own, more carefully
validated fixes.

### 3.2 The `TEMPLATE`/`D INCLUDE TEMPLATE` mechanism (resolves all 10 `SKIP-COMPILE` files)

A few corpus files contain lines like `D INCLUDE TEMPLATE xxxxx`
(column 1) — `xxxxx` names another `.hal` file (or a mangled form of
its name) that must be pre-compiled into a "template library" before
it can be `INCLUDE`d, analogous to a C header needing to exist before
`#include`. To compile a file that needs this, `HALSFC`'s `--parms`
must include the compiler option `TEMPLATE` — usable unconditionally
for *every* file with no downside, whether or not it's actually acting
as a template consumer/provider. The template library is a `TEMPLIB/`
directory plus a `TEMPLIB.json` file (`{}` if empty); both must exist
before compiling anything that needs `TEMPLATE`.

Dependency chain traced and resolved for all 10 files: 4 template
providers (`269-PROCESS_CONTROL` → `264-TQE` → `189-IMU_DATA` →
`176.0-SUPER_VECTOR`, compiled in that order into a shared `TEMPLIB/`)
unblock the 10 consumers, all of which now compile.
`176.1-READ_ACC`/`265-ENQUEUE`/`269-STALL` turned out to be pure
`FUNCTION`/`PROCEDURE` library files (no `PROGRAM` — like a `.c` file
with no `main()`) and were excluded from the completion pass below;
`176-P` needed no content edit at all, just `176.1-READ_ACC.obj` linked
alongside it (`lnk101 176-P.obj 176.1-READ_ACC.obj -o 176-P.fcm ...`) —
`yaGPC2` then runs it correctly. `yaHALMAT2`'s own `@list`-based
multi-unit linking mechanism hits a different wall for this same file
(`EXTN: expected 2 operands`) even once the template-provider unit is
also included in its list — logged as `yahalmat2_extn_multifile_template`,
`status=open`, appears to be a genuine `yaHALMAT2` multi-file-linking
limitation outside `yaGPC2`'s scope.

### 3.3 Completing the "currently broken" files

Per the user's direction, only files that currently produce no output,
don't terminate, or fail to compile/link were edited (not the whole
corpus, and not files that are pure library code with no `PROGRAM`).
For each: read the file's own logic (and, when that alone didn't make
the intent obvious, the corresponding book page), added `WRITE`
statement(s) and/or a termination condition, then individually verified
compile+link+run against both tools. All ~30 identified files are now
done:

`194-TEST_X`, `250-BITS` (filled in the two deliberately-omitted loop
bodies from §3.1's `TIMEOUT` pair), `031-DECLARE3`,
`032-INITIAL_AND_CONSTANT`, `072-EXAMPLE_2`, `076-EXAMPLE_3`,
`097-SAMPLE_FLOW`, `164-OUTER`, `167-ASSORTEDIO`, `169-OUTER`,
`170-OUTER`, `177-P`, `180-EXAMPLE_N`, `184-EXAMPLE_N`, `186-P`,
`199-P`, `203-A`, `219-P`, `222-BETTER`, `222-MULTI`, `224-GNC_POOL`,
`230-STARTUP`, `234-X`, `237-STARTUP`, `238-P`, `239-STARTUP`, `241-P`,
`242-P`, `245-P`, `254-TEST1`, `254-TEST2`, `257-TEST4` all got `WRITE`
statements (and, for a couple of loop-based files, a real termination
condition) added. `154-ADD`, `172-OUTER`, `176-P` (see §3.2), and
`130-EXAMPLE_N` needed **no edit at all** — each was already complete
as written and just needed the correct build procedure or sample input
data (`130-EXAMPLE_N` already has a `WRITE` and terminates, via its
deliberately-incomplete-per-the-book `MASS`/`TAU` stub bodies — see
§3.4).

A few files needed input data supplied at runtime (matching the book's
own worked examples where one exists, e.g. `154-ADD`'s sample
`-3.95, -17.31, ..., +7.50;` from p.154) rather than a content edit —
this is an established, pre-existing convention in this corpus (e.g.
`194-TEST_X` already used it), not new.

### 3.4 Two more real `yaGPC2` bugs found and fixed during completion

**`read_skip_column_not_wired_to_input`** (found completing
`164-OUTER`, now `status=fixed`): `READ ... SKIP(n), COLUMN(n)` control
specifiers (the standard idiom for re-parsing a value from a specific
column of a line a preceding `READALL` already consumed — a
name/value initialization-file reader, per `USA003087` Sec. 10.1.1) had
**zero effect on input parsing**. `COLUMN`/`SKIP`'s `handle_control`
cases only ever wrote to `column[ch]`/`deferred[ch]` (output-only state
read exclusively by the `WRITE`-side formatter), while `IOINIT`
unconditionally wiped `inputBuffer` at the start of every
`READ`/`READALL` statement regardless of what `SKIP`/`COLUMN`
(processed afterward, per compiled HALMAT order) would go on to
request — so any `SKIP(0)` (stay on the current line) statement crashed
with a spurious "READ exhausted input... no ON ERROR handler" abort
instead of re-reading the still-buffered line. Fixed in
`src/halucp.c`/`src/halucp.h`: `IOINIT` (READ variant) no longer wipes
the buffer immediately; a new `apply_read_positioning()` (called once
per statement, right before its first argument is read) honors an
explicit `SKIP(0)` by keeping the buffered line and applies `COLUMN(n)`
by advancing (forward-only — no corpus need yet for backward rewind)
`inputBuffer`'s consumption cursor, tracked via a new `inputColumn`
field maintained incrementally in `ib_consume_prefix`/`ib_reset`.
Verified via an isolated minimal repro and the full `164-OUTER.hal`
file (`PHI`/`ALPHA`/`I_POSN`/`MODE`/`PRINT` all correctly parsed,
matching `yaHALMAT2` exactly for the fields it supports — see §3.5).

**`stale_suppress_next_advance_merges_writes`** (found completing
`254-TEST2`, now `status=fixed`): two independent, back-to-back
`WRITE(6)` statements (each the sole statement of its own `IF-THEN`, no
shared `DO` block) printed with no newline between them. Root cause:
`halucp_notify_interactive_input()` (called after a `READ` provides
input, to avoid a spurious blank line before the next `WRITE`) sets
`suppressNextAdvance[ch]=true`, but `handle_control`'s WRITE `IOINIT`
only cleared that flag in its `suppressNextAdvance` branch — if the
very next `WRITE` on that channel happened to *also* be the channel's
first-ever (taking the sibling `!hasWrittenBefore` branch instead), the
flag was left dangling `true` and wrongly suppressed the newline
advance of whichever `WRITE` came after *that* one instead. Fixed in
`src/halucp.c`: the `!hasWrittenBefore` branch now also clears
`suppressNextAdvance[ch]`. Verified via `cat -A` showing a real newline
between the two lines; all unrelated unit test suites re-run clean, and
the whole batch of previously-fixed corpus files spot-re-verified
unaffected.

### 3.5 New `yaHALMAT2`-side findings from the completion pass

Eleven more findings logged to the shared database, all discovered by
completing individual corpus files (full repro/detail in the database;
`status=open` and `next_action_owner=yahalmat2` unless noted):
`yahalmat2_structure_param_vector_return` (can't `RETURN` a `VECTOR`
field of a `STRUCTURE`-typed function parameter, `170-OUTER`),
`yahalmat2_structure_read_write_all_zero` (a whole-`STRUCTURE`
natural-sequence `READ`/`WRITE` silently gives all zeros regardless of
input, `172-OUTER`), `yahalmat2_nested_structure_vector_field_assign`
(can't assign a `VECTOR` field nested two `STRUCTURE` levels deep,
`177-P`), `yahalmat2_assign_array_struct_element` (can't `ASSIGN()`
into a single array-indexed element of a `STRUCTURE`-typed `ARRAY`
output parameter, `180-EXAMPLE_N`/`184-EXAMPLE_N`),
`yahalmat2_send_error_no_dispatch` (a plain `SEND ERROR$(group:num)`
statement silently no-ops instead of dispatching to the active `ON
ERROR` handler, `199-P`), `yahalmat2_update_block_no_output` (a program
containing an `UPDATE` block on a `LOCK`ed variable produces zero
output at all, `222-BETTER`/`224-GNC_POOL`), `yahalmat2_read_vector_unimplemented`
(any `READ` targeting a `VECTOR` aborts immediately, `164-OUTER`), and
`yahalmat2_bit_concat_sum_expression` (a `BIT$`-concatenation-of-`SUM(INTEGER(...))`
expression can't be evaluated, `257-TEST4`).

**`schedule_priority_out_of_documented_range` — now FIXED, not a
corpus-fidelity trade-off after all.** Two corpus files use `SCHEDULE
PRIORITY` values above the range `yaHALMAT2` enforces (`0<P<255`); the
original framing here treated this as an intentional, unfixable
textbook-fidelity artifact (`241-P`'s `PRIORITY(999)` is verbatim from
the book, `239-STARTUP`'s `PRIORITY(776)` is the corpus transcriber's
own fabricated addition). Corrected: `USA003087` p.166 states
`PRIORITY`'s argument "must lie in the legal range for a given
implementation" — the range is explicitly *implementation-defined*, so
neither number ever had real portable numeric significance beyond "some
big/distinct number." Fixed by editing both corpus files to valid values
for this implementation's actual enforced range: `241-P.hal` →
`PRIORITY(254)` (preserving the book's "since it is of such a high
priority" framing), `239-STARTUP.hal` → `PRIORITY(240)` (non-colliding
with the file's other priorities). Both files now agree exactly between
`yaGPC2` and `yaHALMAT2`.

**`no_return_function_undefined_behavior_diverges` — fully resolved,
not undefined behavior at all.** `130-EXAMPLE_N`'s deliberately-incomplete
`MASS` function (no `RETURN` statement, per the book's own "..."
omission) triggers real HAL/S error #14 ("NO RETURN STATEMENT IN
FUNCTION"); `yaGPC2` and `yaHALMAT2` originally disagreed on the
resulting value (`249900` vs. `32767` for "THE ANSWER IS"), filed here
as "undefined-by-construction, not root-caused further." That framing
was wrong. `USA003090.txt` Appendix C documents error #14's standard
fixup as literally **"Continue"** — proceed as if `RETURN` had been
reached, leaving whatever was already in the result register/slot
untouched, no substituted value (distinct from the adjacent error #15,
"SCALAR too large for INTEGER conversion," whose fixup really is
"32767/-32768"). `yaGPC2`'s `249900` (preceded by a genuine `SEND ERROR
#14` log line) is the *authentic* real-hardware "Continue" behavior.
`yaHALMAT2`'s bare `32767`, no error logged at all, was a real,
actionable gap: its `OP_CLOS` "implicit return" path never detected or
reported the missing-`RETURN` condition, silently popping the call
frame without touching the result slot. Database entry corrected
(`deferred`→`open`, owner→`yahalmat2`) and, once yaHALMAT2 investigated
further, the actual proximate cause of the `32767` symptom was found
and fixed on their side: `OP_DFOR`/`OP_EFOR` unconditionally typed the
`DO FOR` loop control variable `INTEGER` and forced its value through
the SCALAR→INTEGER overflow fixup regardless of the variable's own
declared type, even though HAL/S `DO FOR` control variables can be
declared `SCALAR` (`USA003087` Sec. 10.2) — output is now correctly
SCALAR-formatted (`250000`).

A close remaining mismatch (`250000` vs. `yaGPC2`'s `249900`) turned out
to be its own separate, fully-resolved finding
(`examplen130_cfor_pretest_hardware_divergence`): **`DO FOR ... UNTIL`
is simply post-tested, a documented HAL/S language rule, nothing
hardware- or error-14-specific.** `USA003087` states plainly, for `DO
... UNTIL` generally, "the group is always executed at least once...the
[UNTIL] expression is evaluated at the beginning of each cycle [after
the first]...until the result becomes TRUE." Confirmed independently via
two clean, `MASS`-free repros: `DO FOR V=250000 TO 0 BY -100 UNTIL
TRUE;` (a compile-time-constant, unconditionally-true condition, zero
function calls) still gives final `V=249900`, not `250000` — the body
runs once for `V=250000`, the step is applied (`V→249900`), and only
*then* is `UNTIL` checked (trivially true, exits). Traced the compiled
instructions: a `TS` (Test-and-Set) instruction against a dedicated
"first pass" flag jumps straight into the body on cycle 1 (skipping the
bounds/`UNTIL` check entirely), only applying that check from cycle 2
onward using the already-stepped value. For `130-EXAMPLE_N.hal`:
`MASS`/`ALMOST_EQUAL` are therefore called exactly once, evaluating
`UNTIL` for `V=249900` (post-step), never for `V=250000` — fully
explaining `yaGPC2`'s real `249900` result with no error-14 involvement
whatsoever. Fixed on yaHALMAT2's side: `OP_DFOR`/`OP_CFOR`'s body now
runs unconditionally for the starting value before either the `UNTIL`
or `TO`-bound check ever runs, matching this documented, portable
control-flow rule.

**`read_array_early_termination_stale_iobuf` (`154-ADD`) — corrected
from `deferred` to `open`, now `fixed`.** A confirmed, real AP-101S RTL
quirk: when a semicolon-terminated `READ` into an `ARRAY` supplies fewer
values than the array has elements, the real AP-101S RTL
(`RUNASM/HIN.asm`'s `EIN`/`HIN`/`IIN`/`DIN`/`BIN` routines)
unconditionally re-stores the last-read value into every remaining
iteration of the compiled fixed-count `READ` loop, overwriting the
`DECLARE...INITIAL` value in every unread element — `yaGPC2` faithfully
replicates this (confirmed byte-identical against the golden `gpc run`
reference); `yaHALMAT2` originally left unread elements at their
initialized value instead, matching the textbook's own idealized worked
answer rather than real hardware. The earlier `deferred` status
reflected only a subjective "is this actually desirable" judgment call,
not any real attempted work or a confirmed hard blocker — corrected per
this project's established convention (`cvfx_overflow_truncation_rule`,
`test_stoi`'s rounding rule, `mmwsnp` above): once a discrepancy is
confirmed authentic real-hardware behavior, the expected resolution is
for `yaHALMAT2` to replicate it for fidelity. Now fixed on yaHALMAT2's
side.

---

## 4. "HAL-S-360 Users Manual" corpus — `DEMO.hal`, a new sweep candidate

`~/git/virtualagc/yaShuttle/"Source Code"/"HAL-S-360 Users Manual"/DEMO.hal`
is a second, separate HAL/S example source, outside the "Programming in
HAL/S" corpus Section 3 covers — it's the *compiler manual's* own
syntax-showcase demo (structures, matrices, vectors, `DO CASE`, `DO
FOR`), included here to show off the listing the HAL/S-360 compiler
produces, not originally written to run meaningfully. A stale build
artifact alongside it (dated October 25, 2023, long predating this
project's current HALSFC/`yaGPC2` tooling) shows 9 phase-1 compile
errors from some unrelated prior tool/era — not indicative of current
behavior.

**Prepared as a real cross-tool test (2026-07-28):** the user modified
the file to compile cleanly and gave its variables real initial values.
An initial sanity-check pass found the resulting output fully explained
by the source (not a bug): `K=0;` runs immediately before the main
`WRITE`, so `K`'s `INITIAL` values never actually print; `PROC1`'s
original loop reused the *global* `I` as its `DO FOR` counter (only `A`
was locally redeclared), so `I` ended up at the loop's post-exit value
rather than its `INITIAL` — both since fixed (`DO FOR TEMPORARY I`/`J`
now used instead, so the globals survive `CALL PROC1` correctly).

This investigation also surfaced and resolved
**`array_oob_subscript_returns_zero_unconfirmed_guarantee`**
(`status=not_a_bug`) — a `yaHALMAT2`-side open question from their own,
separate crash investigation of this same file, about the original
`DO FOR C = 1 TO 100; D=K$(C:2,3); END;` (`K` only `ARRAY(5)`, deliberately
walked far out of bounds). Traced the compiled instructions for a
minimal repro via `--trace`: there is no bounds-check instruction
anywhere between computing the index and the load that uses it —
straight-line, unconditional address arithmetic. The result is **not**
a stable 0: consecutive out-of-range reads gave `0.0`, a denormalized
garbage float, `0.0` again, and a different nonzero garbage value —
exactly what raw, unchecked reads of whatever memory sits past the
array would produce, not a deliberate "OOB returns 0" convention.
Cross-checked against the real HALSFC PASS2 compiler-internals source
(`GENERATExSUBSCRIPTuRANGEuCHECK.c`): despite its name, this has nothing
to do with HAL/S-level array-bounds checking — it's purely about
whether a computed address offset fits an S/360-style instruction's
displacement-field addressing range; its only error call is a
compile-time internal-consistency check, not a runtime `SEND ERROR`.
This compiler generates **zero** runtime array-bounds checking — an
out-of-range subscript is genuine undefined behavior dependent on the
compiler's static memory layout, exactly like an out-of-bounds C array
access. `yaGPC2` is already doing the right (bare-hardware-faithful)
thing by not adding a check; `yaHALMAT2`'s modulo-wrap convention
doesn't match real hardware either, but matching isn't achievable in
principle here (no equivalent real memory layout to replicate) — a
reasonable, deliberate choice for a symbolic interpreter facing genuine
UB, not a bug on either side.

Per the user's direction, the out-of-range loop was kept exactly as-is
(deliberately, to prove neither tool traps the overrun — a real,
reproducible-per-build property worth testing for, not avoiding), and
its result (`D`) was moved into its own isolated `WRITE(PRINTER) D;`
statement so it doesn't contaminate an otherwise fully-deterministic
comparison target.

The file's two remaining dead code paths were then also brought to
life, so the test exercises as much of the demo's showcased
functionality as possible: `PROC1`'s local `A` now has `INITIAL(1)`
(matching global `B`), so its `IF A=B THEN DO;...END;` branch actually
runs, performing a real cross-structure `MATRIX` slice assignment
(`EE$(*;3:2,*) = CC$(*;*,2)`); `CC` was given real, per-structure-element
values via the `MATRIX$(m,n)(...)` conversion builtin (`USA003087`'s
"matrix conversion" — a bare literal list or `MATRIX(m,n)(...)` without
the `$` both fail to compile); and a duplicated `DO CASE A;` block (with
`A` set to a different value first) exercises the previously-dead
second branch too. `MY_STRUCTURE.RR.SS` (`CHARACTER(5)`, the one
remaining never-assigned field) was likewise given distinct per-element
values. Every field is now genuinely exercised except `D` (deliberately
left as real, undefined out-of-range-read behavior, as above).
Compiles and runs clean end-to-end. Not yet run through `yaHALMAT2` for
a cross-tool comparison — that's the natural next step whenever this
corpus gets its own sweep pass, analogous to Section 3's.

Two dialect notes worth remembering, both confirmed by direct
experiment while preparing this file: this compiler's fixed-column card
format caps lines around 72 columns — a too-long statement doesn't
necessarily error on its own line, but can silently desync the parser
into confusing cascading errors on *later*, unrelated statements.
Scalar-broadcast assignment (`X = 5;` or `X$(*,*) = 5;`) works for
`ARRAY`-of-`MATRIX` targets (like `K=0;`) but is rejected for a plain
`MATRIX`/`VECTOR` target ("TYPE OF X IS ILLEGAL FOR ASSIGNMENT") — a
real `MATRIX`/`VECTOR` value needs the `MATRIX$(m,n)(...)`/`VECTOR$(n)(...)`
conversion builtin instead.

---

## 5. Full corpus re-sweep against `yaHALMAT2` directly (2026-07-29)

Once both projects' `open` queues were cleared (per the standing policy
in the header above), a full 99-file sweep (the 98 "Programming in
HAL/S" files plus `GOOGLE-PARALLAX.hal`/`HELLO.hal`, which turned out to
already be part of the corpus directory alongside the numbered textbook
files) was run **directly against `yaHALMAT2`, not the frozen `yaGPC`
predecessor** — the first sweep under the new policy that `yaGPC2` is
the authoritative parity target. **Result: 76 AGREE, 15 DISCREPANCY, 8
SKIP-LIBRARY (expected — the same 8 template-provider/pure-library files
as §3.2), 0 SKIP-COMPILE/SKIP-LINK/TIMEOUT.**

**Sweep-script bugs found and worked around, not real findings**: the
reused sweep script pointed at the frozen `~/bin/yaGPC` symlink instead
of `yaGPC2`'s own binary (the same stale-binary trap noted earlier in
this file — fixed: full path + the `run` subcommand `yaGPC2`'s current
CLI requires). Separately, compiling a main file and its multi-file
companion (176-P/176.1-READ_ACC, 224-GNC_POOL/213-GNC_POOL) back-to-back
sometimes left the compiler's `current.results` symlink pointing at the
wrong archive directory, producing a bogus "multiple PROGRAM units
found" crash on `yaHALMAT2`'s side. Manually rebuilding each pair with
distinct archive directories resolved 224-GNC_POOL to an exact match
(confirmed not a real issue); 176-P did not resolve the same way — see
below.

**7 new findings, all `yaHALMAT2`-owned**, each personally re-verified
(not taken from the raw diff alone) — correcting a miscount given
verbally at the time (said as "9," which conflated these 7 with the 2
already-open entries the sweep also touched on):

- **`yahalmat2_dispatches_goto_for_undispatchable_matrix_inverse_error`**
  (medium) — covered in full under §2.1 above: `yaHALMAT2` still honors
  the `GO TO` handler for the matrix-inverse-singularity error §2.1/§3.1
  proved real hardware never dispatches for. A real, actionable parity
  gap, not a permanent divergence.
- **`multi_item_write_drops_nested_structure_vector_field`** (**high** —
  a confirmed regression) — 176-P.hal's `WRITE(6) 'ACCEL=',
  STATE2.STATE.ACCEL.V;` prints only the label on `yaHALMAT2`, dropping
  the vector's three components entirely. Confirmed via a from-scratch
  3-way `@list` rebuild (176-P + 176.0-SUPER_VECTOR + 176.1-READ_ACC,
  the same repro §3.2's `yahalmat2_extn_multifile_template` fix used)
  that this is not a sweep-script artifact — `yaGPC2` correctly shows
  every value (matching that same fix's own previously-recorded
  real-`gpc`-confirmed numbers). Something since that fix landed has
  broken this specific case: a multi-item `WRITE` combining a plain
  string literal with a container item reached via a multi-level
  `STRUCTURE` path. Structurally related to (but not identical to) the
  next finding below — 072-EXAMPLE_2.hal's `WRITE(6) 'V_PRIME=',
  V_PRIME;` (string + a *plain bareword* `VECTOR`, no structure nesting)
  prints correctly, ruling out "any container item in a multi-item
  WRITE" as the trigger and narrowing it to structure-nested field
  paths specifically.
- **`multi_item_write_truncated_with_bareword_array_of_matrix`** (medium,
  already open from §4/`DEMO.hal`) — likely the same general class as
  the finding above (a container item vanishing from multi-item `WRITE`
  output), but with a different trigger shape (bareword `ARRAY(5)
  MATRIX(3,4)` vs. a nested-structure `VECTOR` field) — logged
  separately until root-caused, since it isn't yet safe to assume one
  fix covers both.
- **`double_to_single_scalar_assignment_narrowing_mismatch`** (medium) —
  108-EXAMPLE_5.hal computes `SQRT(3383.5)` two ways: assigned into a
  plain (single-precision) `SCALAR` via `RMS = SQRT(TOTAL/COUNT);
  WRITE(6) RMS;` (`TOTAL` is `SCALAR DOUBLE`), vs. computed inline as a
  `WRITE` argument with no intermediate variable. `yaGPC2` gives the
  identical answer either way (as it must — `SQRT` doesn't care how its
  argument arrived); `yaHALMAT2` only matches via the second path. This
  isolates the bug to the DOUBLE→SINGLE assignment-narrowing step, not
  `SQRT`'s own hex-float port, despite `yahalmat2_uses_ieee_double_not_ibm_hex_float`'s
  (§2.8) claim of comprehensive, bit-exact-verified transcendental
  coverage.
- **`array_of_vector_element_write_precision_format_mismatch`** (medium)
  — `vector_write_precision_format_mismatch`'s fix (§2.8, `VASN`/`MASN`'s
  plain-SYT destination write) only covered a bare `VECTOR` symbol;
  119-EXAMPLE_9.hal assigns/reads exclusively via subscripted
  `ARRAY(999) VECTOR(3)` elements (`V$(I:) = VECTOR(RANDOM, RANDOM,
  RANDOM);`), which still prints in full ~17-digit double-precision
  format on `yaHALMAT2` instead of the correct ~7-digit single-precision
  `yaGPC2` uses — a genuinely different code path the original fix never
  reached.
- **`vector_cross_product_diverges_on_exact_inputs`** (low) —
  072-EXAMPLE_2.hal's `RESULT2 = V_PRIME * E` (cross product) diverges
  from `yaGPC2` even though every input and intermediate value is a
  small, exactly-representable integer (`V_PRIME=(14,32,50)`,
  `E=(3,2,1)`, exact answer `(-68,136,-68)` by hand) — ruling out a
  precision-*representation* explanation entirely (there is no rounding
  a genuine hex-float multiply-then-subtract of clean small integers
  should ever introduce) and implicating the cross-product
  formula/algorithm itself. `yaGPC2` (running the real RTL) shows a tiny
  (~2e-7) residual on the two components involving a subtraction of two
  nonzero products — plausibly the real RTL's own faithfully-reproduced
  quirk (the same general class as `MM14SN.asm`'s documented
  workarounds), which `yaHALMAT2`'s more direct formula doesn't
  replicate.
- **`tan_function_possibly_missed_by_hex_float_port`** (low) —
  GOOGLE-PARALLAX.hal's all-`DOUBLE` `TAN()` call diverges from
  `yaGPC2` by the classic hex-float-vs-double signature (agreement to
  ~7 significant digits, divergence beyond). Every variable in the file
  is `DOUBLE`, ruling out the assignment-narrowing bug above. Notably,
  plain `TAN` (as opposed to `ATAN`/`TANH`) does not appear in
  `yahalmat2_uses_ieee_double_not_ibm_hex_float`'s own list of ported
  functions (§2.8) — worth checking whether it was simply overlooked
  before assuming a deeper algorithmic cause.
- **`empty_character_write_padded_to_declared_length`** (low) —
  186-P.hal's empty-initialized `CHARACTER(5)` field writes 5 trailing
  blank spaces on `yaHALMAT2` (padded to the declared maximum length)
  vs. zero characters on `yaGPC2` (the real hardware's actual-length
  behavior).

**6 of the 15 discrepancies were already fully explained, no new
action**: `029-DATATYPES` (§3.1's register-pair fragility),
`104-EXAMPLE_1` and `120-EXAMPLE_A` (§2.6's `RUNTIME()` scope boundary
— `104-EXAMPLE_1` specifically uses `RUNTIME` to *time* 100 matrix
inversions, so its `TMEAN`/`TMAX`/`TMIN` output is statistics computed
*from* an already-non-comparable quantity), `167-ASSORTEDIO` (the
`%SVC`-macro scope boundary), `DEMO.hal` (the already-open
`multi_item_write_truncated_with_bareword_array_of_matrix` above), and
117-EXAMPLE_8 (its `DISTANCE`/`APPROACH_RATE` residuals are consistent
with a combination of the already-known `ABVAL`/`UNIT` transcendental
imprecision and the dot-product sibling of the cross-product finding
above — not cleanly separable from the `SQRT`-derived imprecision, so
not filed as its own repro).

*(Later correction, §6: `029-DATATYPES`'s "register-pair fragility" and
the cross-product/dot-product residuals mentioned here turned out to be
genuine, fixable RTL defects after all, not intentional hardware
fidelity — see §6.3/§6.4 for the full story and the eventual
`MM14SN.asm`/`VX6S3.asm`/`VV6S3.asm` fixes.)*

`yaGPC2`'s own side stayed clean this round — every one of the 15
discrepancies traced to either an already-accepted `yaGPC2`-side finding
or a `yaHALMAT2`-side gap; nothing new for `yaGPC2` to fix.

---

## 6. Second and third full re-sweeps; the `MM14SN.asm`/id-53 register-pair-leak saga (2026-07-29)

### 6.1 Second full re-sweep: two premature `not_a_bug` reclassifications caught and corrected

Once both projects' `open` queues were cleared again, a second full
99-file sweep ran (triggered automatically once a polling job detected
zero open issues): **81 AGREE, 10 DISCREPANCY, 8 SKIP-LIBRARY, 0
SKIP-COMPILE/SKIP-LINK/TIMEOUT** — up from 76/15/8 the first time (5 of
the prior sweep's findings had genuinely resolved: 108-EXAMPLE_5,
119-EXAMPLE_9, 197-P, 198-P, GOOGLE-PARALLAX).

Two of the remaining "fixed but still shows a diff" cases turned out to
be premature reclassifications, caught by re-deriving the primary
evidence directly rather than trusting either side's own summary of it:

- **`multi_item_write_drops_nested_structure_vector_field`** (176-P.hal,
  **high**, a confirmed regression) had been marked `not_a_bug` on the
  strength of three "could not reproduce" attempts, all of which used
  `run_ext_struct_fixture.sh` — a fixture script that compiles with **no
  `--parms` at all**, a materially different compiler configuration than
  the standard sweep methodology's full parms string
  (`NOTABLES,SRN,TEMPLATE,NOLFXI,REGOPT,VARSYM,CARDTYPE=...`). Using the
  correct (standard-parms) compile against a freshly rebuilt
  `yaHALMAT2`, the original bug reproduced exactly as first found —
  reverted to `open`/high, with a concrete next step (bisect which
  specific parm token flips the behavior) the original investigation
  lacked.
- **`empty_character_write_padded_to_declared_length`** (186-P.hal) had
  been reclassified `not_a_bug` because `yaHALMAT2`'s padded output
  "matches a fresh real-`gpc` run" — true, but reading the actual
  historical RTL source (`RUNASM/CASV.asm`, "CHARACTER ASSIGN") and
  tracing the real compiled instructions with actual register/memory
  values shows the algorithm is unambiguously
  `MIN(sourceCurrLen, destMaxLen)`, never padding. The source string's
  own baked-in descriptor genuinely has `currLen=0` for this file's
  `INITIAL('')`, and the instruction trace confirms the real algorithm
  computes a final `currLen=0` — **0 characters is the correct,
  hardware-faithful answer**, exactly what `yaGPC2` already produces.
  Frozen `yaGPC`'s matching-`yaHALMAT2` padded output is therefore
  itself a bug in that deliberately-frozen predecessor (not explored
  further) — agreement with it wasn't evidence of correctness here.
  Reopened as a real, medium-severity, `yaHALMAT2`-owned gap.

The other two "still shows a diff" cases checked out as legitimate,
already-understood residuals: `vector_cross_product_diverges_on_exact_inputs`
(072-EXAMPLE_2, its own remaining residual explicitly caveated against
the F1-register-chain class, id 40, still open at the time) and
`multi_item_write_truncated_with_bareword_array_of_matrix` (DEMO.hal,
whose own residual lines up exactly with the separate, already-accepted
`array_oob_subscript_returns_zero_unconfirmed_guarantee` undefined
behavior). A stray form-feed noticed during that same DEMO.hal fix was
given its own entry (`demo_recursive_structure_write_spurious_form_feed`,
low), fixed in §6.2 below. Net DB state after this round: 58 `fixed`, 7
`not_a_bug`, 3 `open` (all `yahalmat2`-owned), 2 `suspected`.

### 6.2 Automatic page-turn-on-overflow: a real `yaGPC2` gap the whole project had been trusting the absence of

`yaGPC2`'s `hal_newline()` (`src/halucp.c`) only ever turned a page via
*explicit* `LINE`/`PAGE` pseudo-functions — it had no automatic
page-turn when a `PAGED` device's line count simply overflowed
`linesPerPage` from ordinary `WRITE` advances alone. `yaHALMAT2`'s own
`interp.c` had this behavior correctly implemented (`dm_advance_lines`,
emitting a form-feed on overflow), then removed it the same day,
reasoning from reading `yaGPC2`'s own (incomplete) `halucp.c` that its
absence there meant real hardware doesn't do this — treating a missing
feature as authoritative evidence about real hardware, when it was just
an oversight.

Confirmed via the actual language spec (`USA003087.txt` Sec. 12.4 rule
2): an explicit `SKIP(alpha)` may cross page boundaries ("SKIPs over
page boundaries are allowed"), with no documented reason the *default*
one-line advance (functionally an implicit `SKIP(1)`) would behave any
differently — same "device mechanism," different trigger. The manual
never spells out the overflow case explicitly because that's just how a
physical line printer behaves, obvious enough not to need stating.

Fixed by adding the check directly in `hal_newline()` — the single
choke point every ordinary line advance (implicit default, `SKIP(n)`,
and `LINE`/`PAGE`'s own delta loops) already funnels through — so it
uniformly covers all cases and naturally reproduces `PAGE(beta)`'s own
"relative line number unchanged" behavior as a side effect. Also
corrected `linesPerPage`'s own default from an unexplained `60` to `66`
(the IBM 1403 line printer's documented lines-per-page, matching
`yaHALMAT2`'s independently-researched same default). Verified against
`yaHALMAT2`'s own regression fixture spec (70 sequential `WRITE(6) I;`
statements, form-feed lands exactly between lines 66 and 67) and a full
corpus re-sweep showing no new discrepancies — all three previously-open
issues from §6.1 were resolved this round (the other two independently,
by `yaHALMAT2`'s own session), bringing the database back to zero open
issues.

### 6.3 The `MM14SN.asm`/id-53 register-pair-leak saga: two false starts, then the real fix

`datatypes_repeated_singular_inverse_unstable_result` (id 53,
029-DATATYPES.hal: three back-to-back, bit-identical `A4I=INVERSE(A4A)`
calls on the same singular matrix give three different results) had a
long, twisting investigation before landing on its final, correct
disposition — recorded here in full because each wrong turn taught
something the next attempt needed.

**First attempt (disproven).** The singularity check (`LER F0,F0`/
`BE AOUT`) was suspected of reading leftover garbage in F0's uncleared
companion register F1. A `&ASM101S`-gated `SER F1,F1` fix (the same
conditional-assembly technique as `CINDEX.asm`, id 10) was implemented,
verified clean at the assembler level (historical path byte-identical,
full regression clean) — but end-to-end, the three `INVERSE(A4A)`
outputs came out bit-for-bit identical to the unfixed run. **Root
cause of the false lead**: re-deriving the AP-101S mnemonic semantics
precisely from `yaGPC2`'s own `src/cpu_instr.c` (its
20,000-fixture-tested emulator ground truth) showed the "ER" suffix
(`LER`/`DER`/`CER`/`AER`/`SER`/`MER`) is plain single-precision
register-to-register, **not** extended — only "ED"/"EDR" mnemonics are
genuinely paired. `LER F0,F0` never reads F1 at all; the fix was
reverted.

**Second attempt (the real fix, briefly reclassified away, then
correctly reinstated).** Tracing the real divergence to `QLOOP`'s
reduction-loop `AEDR F4,F2` (`A(I,J)+=A(I,K)*A(K,J)`): F2 and F4 are
both loaded via single-precision `LE` (never clearing companions F3/F5),
yet `AEDR` is a genuine 64-bit extended add. Instruction trace confirmed
F4's companion F5 holds different leftover garbage across the three
bit-identical calls, producing three different results that cascade
through the rest of the elimination (and explain why `AERROR 27`
sometimes fails to fire — corrupted intermediate values simply never
land on an exact-zero pivot). A `&ASM101S`-gated `SER F3,F3`/`SER F5,F5`
fix immediately before this `AEDR` made all three calls produce an
identical, correct result.

This fix was then **briefly reverted** on the reasoning that
`yaHALMAT2/src/hal_matrix.c` had already independently investigated the
same question via its own real-execution trace and concluded F1/F3/F5
are genuinely never reset anywhere in real `MM14SN.asm` — correct as a
description of the *historical* RTL, and corroborated by running the
actual compiled file through `yaHALMAT2`, which reproduced the same
"wild garbage" symptom byte-for-byte. But **this reasoning was wrong**:
"both tools faithfully reproduce the same historical behavior" is
evidence of authenticity, not correctness. A matrix-inversion result
that silently depends on unrelated prior floating-point call history
(leftover garbage from a completely unrelated `WRITE(6)` statement) is
a genuine RTL defect regardless of how faithfully it has been
replicated — the same class of finding as `cindex_not_found_overrun`
(id 10), and a direct generalization of the earlier F0/F1
false-lead reasoning to this routine's actual reduction step.

The fix was reinstated and finalized: **two `SER F1,F1` insertions**
(`ALOOP`/`CTSW`, the singularity-check pivot pair — harmless but
consistent with the file's own established companion-clearing
convention) plus **`SER F3,F3`+`SER F5,F5` before `QLOOP`'s
`AEDR F4,F2`** (the actually-effectual fix). Verified: historical
(`&ASM101S`-false) path byte-for-byte identical to `RUNLST/MM14SN.txt`;
full `regressionASM101S.sh` corpus run clean (only the expected
CINDEX/MM14SN divergence anywhere in the corpus); end-to-end, all three
repeated `INVERSE(A4A)` calls produce an identical, correct identity
result every time, non-singular cases unaffected.

**A follow-up correction narrowed the fix to a single instruction.**
Re-deriving the mnemonic semantics (see above) meant the two `SER F1,F1`
insertions never had any effect (`LER F0,F0` doesn't read F1) and the
`SER F3,F3` before the `AEDR` was redundant (`DIVLOOP`'s own
pre-existing `SER F3,F3` already guarantees F3 is zero by the time
`QLOOP` runs — confirmed via trace, which never once showed F3 changing
across the three otherwise-divergent calls, only F5). The committed fix
is a single `SER F5,F5` before `QLOOP`'s `AEDR F4,F2`, re-verified
end-to-end with identical, correct results to the broader version.

Database disposition: `datatypes_repeated_singular_inverse_unstable_result`
is `fixed`/`yagpc2`. A follow-up issue
(`yahalmat2_matrix_leak_model_should_match_corrected_rtl`) is open for
`yaHALMAT2` to update its own `f5_accum` model to match the corrected
RTL (freshly zeroed at each step) instead of continuing to replicate
the historical leak; the `MM14S3.asm` 3x3 cofactor path's own,
separate `SEDR`-based F1/F3 threading is unaffected by this narrowing
and not yet independently re-verified. The `nsts-sdl-dps` build
pipeline's own embedded `asm101` package was found to predate the
`&ASM101S` convention entirely (silently produces the historical/
unfixed object code regardless of source changes) — a pre-existing gap
that equally affects `CINDEX.asm`'s own already-accepted fix, not yet
addressed.

### 6.4 `--no-rtl-fixes`, and two more RTL register-pair-leak fixes (`VX6S3.asm` cross product, `VV6S3.asm` dot product)

`ASM101S.py` gained a `--no-rtl-fixes` switch: forces `&ASM101S` to
false (matching a genuine historical assembler) so a build can
reproduce an exact historical memory image — including the underlying
bugs — when that matters more than having the fixes (RTL fixes change
object-code size, which cascades into the linker's memory layout).
Checked via a pre-scan of `sys.argv` before any source file is read, so
it takes effect regardless of argument order relative to the source
files.

Applying the same corrected mnemonic understanding and the same
reasoning established in §6.3 (a result silently depending on unrelated
prior floating-point history is a genuine RTL defect, not intentional
design, regardless of how faithfully it's been reproduced elsewhere),
two more instances of the same bug class were found and fixed, scoped
to the dot-product/sqrt-class residuals from §5's own sweep
(`vector_cross_product_diverges_on_exact_inputs` and 117-EXAMPLE_8's
dot-product-derived `APPROACH_RATE`):

- **`RUNASM/VX6S3.asm`** (VECTOR cross product): its three components
  are mathematically independent, so `SEDR`'s own F1 chaining
  component-to-component (and F3, never written at all) has no
  legitimate purpose — a plain register-clearing omission. Fixed with
  `SER F1,F1`/`SER F3,F3` before each of the three `SEDR` calls.
  072-EXAMPLE_2.hal's `RESULT2` now reads exactly `-68.0/136.0/-68.0`
  (was `-6.7999985E+01/1.3600000E+02/-6.7999985E+01`), matching
  `yaHALMAT2` bit-for-bit; `RESULT1` (`UNIT(V_PRIME)`) also now matches
  exactly. This supersedes `vector_cross_product_diverges_on_exact_inputs`'s
  prior disposition (which had `yaHALMAT2` replicate the leak instead
  of fixing the RTL) — reclassified `fixed`/`yagpc2`, with a follow-up
  issue (`yahalmat2_vcrs_leak_model_should_match_corrected_rtl`) logged
  for `yaHALMAT2` to match the corrected RTL.
- **`RUNASM/VV6S3.asm`** (VECTOR dot product): a different shape — the
  second `AEDR` call is a legitimate, intentional running-sum
  accumulation (F0:F1 correctly carries the first `AEDR`'s own real
  result forward), so only the *first* `AEDR` needed a fix (F1/F3 both
  start as pure external garbage before any accumulation begins).
  Single `SER F1,F1`/`SER F3,F3` pair, once, before the first `AEDR`
  only. 117-EXAMPLE_8.hal's `APPROACH_RATE` now reads
  `0.0/-1.6712570E+00/0.0/5.0137711E+00/6.8649292E+00`, matching
  `yaHALMAT2` bit-for-bit (`DISTANCE`, the `ABVAL`/sqrt-derived value in
  the same file, was already bit-exact). Logged and closed in the same
  pass as `vv6s3_dot_product_leading_companion_register_uncleared`,
  `fixed`/`yagpc2`, no `yaHALMAT2` follow-up needed.

All three RTL fixes (`MM14SN`, `VX6S3`, `VV6S3`) were verified together:
each historical (`--no-rtl-fixes`) path byte-for-byte identical to its
own `RUNLST/*.txt`; full `regressionASM101S.sh` clean (only the four
now-expected `CINDEX`/`MM14SN`/`VX6S3`/`VV6S3` divergences anywhere in
the ~190-file RTL corpus).

### 6.5 Third full re-sweep: sweep-script fixes, and one residual proven isolated to a display-only routine

A third full 98-file "Programming in HAL/S" sweep (yaGPC2 vs.
`yaHALMAT2` directly): **84 AGREE, 4 DISCREPANCY, 10 SKIP** (8
template-provider files + 176-P/176.1 needing multi-file linking), 0
SKIP-LINK/TIMEOUT. Three sweep-script methodology bugs were found and
fixed along the way, not real findings: `yaHALMAT2` needs its own
`--line-length` flag passed explicitly (its default of 80 doesn't match
`yaGPC2`'s `--line-width 240`, causing 4 spurious line-wrap
"discrepancies"); `yaGPC2`'s default `--max-steps 100000` is too low
for two long-running files (071-DARTBOARD_APPROXIMATION,
104-EXAMPLE_1's own 100-inversion timing loop), raised to 5000000
matching established precedent; 176-P needs per-file `HALSFC` compiles
linked together via a single multi-object `lnk101` call (`lnk101`
accepts multiple object files on one command line), not a
`--test`/`@list`-style multi-file `HALSFC` invocation.

The 4 real discrepancies were all already-explained or newly resolved:
104-EXAMPLE_1/120-EXAMPLE_A (`RUNTIME()` scope boundary) and
167-ASSORTEDIO (`%SVC` macro scope boundary) are unchanged from prior
sweeps. 029-DATATYPES showed two new residuals not previously examined:

- **DETERMINANT residual (`MM12SN.asm`)**: traced the whole routine —
  single-precision throughout (`LE`/`ME`/`MER`/`AE`/`LECR`), no genuine
  extended operation anywhere in the general-N path. Not the
  register-leak bug class; logged as issue 76
  (`mm12sn_determinant_algorithm_fidelity_gap`, `open`,
  `next_action_owner=yahalmat2`) — a `yaHALMAT2`-owned algorithm-fidelity
  gap (its own determinant implementation doesn't bit-exactly replicate
  this specific single-precision elimination order), no `yaGPC2` action
  needed. *(This DB row wasn't actually created until a later pass — see
  §6.6 — despite being described in prose here at the time; a reminder
  that "documented in prose" and "logged in the DB" are not the same
  thing in this project's workflow.)*
- **Non-singular INVERSE residual (A4B/A5A)**: a long investigation that
  ended by **proving `MM14SN.asm`'s fix (§6.3) is fully correct**. Every
  step of A4B's forward elimination (K=0 through K=3: pivot search, row/
  column exchange, column-divide, reduce, row-divide, reciprocal) was
  independently verified bit-exact against the real instruction trace,
  via a from-scratch Python port of `yaGPC2`'s own `fibm_addE`/
  `fibm_mulE`/`fibm_divE` (`floatIBM.c`) — after finding and fixing two
  bugs in that verification port itself (a wrong exponent-alignment
  branch in the add/subtract logic; a missing single-precision
  truncation after every store, matching real `STE`/`.msw` semantics).
  `INVERSE()` itself has no remaining defect. The residual was isolated
  to `RUNASM/MM6SN.asm` (a display-only matrix-multiply used just for
  the "should be identity" printout, not part of `INVERSE()`'s own
  result) — confirmed this routine has the same latent
  uncleared-F3-before-`AEDR` pattern as `VX6S3`/`VV6S3` (line 51's
  single-precision `LE`+`ME` load of an M2 element, never clearing its
  companion F3, before line 53's genuine extended `AEDR F0,F2`), but the
  real trace showed F3 never changes throughout this specific run, so
  that latent bug wasn't the active cause. Logged at the time as
  `mm6sn_display_multiply_residual_source_unidentified`, `open`/`yagpc2`
  — **since fully resolved, see §6.6 for the actual root cause and fix.**

---

### 6.6 Issue 75 resolved: the real cause was `yaHALMAT2`'s truncate-every-term modeling gap, not `MM6SN.asm`'s F3

The `mm6sn_display_multiply_residual_source_unidentified` residual (§6.5)
was fully resolved. The suspected `MM6SN.asm` companion-register leak
(F3 uncleared before `AEDR F0,F2`, same class as `MM14SN.asm`/`VX6S3.asm`/
`VV6S3.asm`) was real and got its own `&ASM101S`-gated `SER F3,F3` fix on
the RTL side — but instruction-trace verification confirmed F3 was
already zero throughout every `MM6SN.asm` call in this specific test, so
it was **not** the active cause of the observed residual.

The actual root cause was found by direct comparison against
`yaHALMAT2`'s `interp.c`: real RTL (`MM6SN.asm` and its siblings
`MV6SN.asm`/`VM6SN.asm`/`VV6S3.asm`/`VV6SN.asm`) accumulates an entire
N-term dot product in a genuine EXTENDED (56-bit, register-pair) running
sum via `SEDR`/`AEDR`, truncating to single precision only **once**, at
the final `STE`. `yaHALMAT2`'s `OP_MMPR`/`OP_MVPR`/`OP_VMPR`/`OP_VDOT`
instead truncated to single precision after **every** term — discarding
low-order bits N times instead of once, producing a different (larger,
differently-patterned) rounding residual than real hardware, even though
both sides were computing the same mathematically-correct dot product.
Fixed by switching all four opcodes to accumulate via the extended
`hrfp_addE` primitive and truncate only once at the end, matching real
hardware's own accumulation order.

While auditing `MM6SN.asm`'s sibling routines for the same
companion-register-leak class (the investigation's original hypothesis),
found a second, distinct, genuine `yaGPC2`-side defect: `MV6SN.asm`
(MATRIX\*VECTOR multiply) clears its accumulator with the
single-precision `SER F0,F0` instead of the extended `SEDR F0,F0` that
`MM6SN.asm`/`VM6SN.asm`/`VV6SN.asm` all correctly use — leaving
companion register F1 with leftover floating-point garbage from
unrelated prior work throughout the whole accumulation. Fixed via an
added, `&ASM101S`-gated `SER F1,F1` (purely additive; byte-identical
historical object code confirmed preserved under `--no-rtl-fixes`).
Logged as issue 77 (`mv6sn_accumulator_leak_uninitialized_companion_register`,
fixed, `yagpc2`) — no HAL/S corpus test currently exercises this specific
latent path, but the defect follows the exact reasoning already
established for id-53/72/73/74.

Also created the DB row for issue 76
(`mm12sn_determinant_algorithm_fidelity_gap`) at this point — see the
note in §6.5 above: this finding had only ever been described in prose,
never actually logged as a DB issue, until the gap was caught.

**A serious build-pipeline gotcha, discovered while deploying the
`MV6SN.asm`/`MM6SN.asm` fixes**: the separate `nsts-sdl-dps` project
(which actually supplies the `lnk101`/`HALSFC`-adjacent toolchain used
throughout this whole sweep methodology) has its own from-scratch
reimplementation of the AP-101 assembler (Python package `asm101`,
*not* `ASM101S.py`), built via its own `make runtime` CMake target. That
reimplementation does not pre-define `&ASM101S` and silently drops
`GBLB`/`AIF`/`AGO` conditional-assembly blocks entirely — no error, no
warning, clean exit — always producing the historical/buggy object code
regardless of source intent. Running `make runtime` there silently
reverted the already-deployed `MM14SN.asm`/`VX6S3.asm`/`VV6S3.asm` fixes
(id-53/72/73) back to their original buggy object code mid-session,
causing a severe regression (garbage, `E+12`-magnitude "should be
identity" results) before being traced back to this root cause. The
correct fix: reassemble by hand with the real `ASM101S.py` and copy the
resulting `.obj` files directly into
`nsts-sdl-dps/build/lib/runtime/RUN/`, bypassing that project's own
build tooling entirely for any RTL file gated by `&ASM101S`.

A fourth full 98-file corpus sweep (yaGPC2 vs. `yaHALMAT2` directly,
after all of the above): **85 AGREE, 3 DISCREPANCY** (up from 84/4) —
029-DATATYPES.hal now matches bit-for-bit. Zero regressions; the
remaining 3 discrepancies (104-EXAMPLE_1, 120-EXAMPLE_A, 167-ASSORTEDIO)
are the same pre-existing, already-tracked findings from earlier
sweeps (§5, §6.5), still open.

### 6.7 DB issue 78: spurious `HAL/S PROGRAM HALT` message on every normal
termination, and an over-broad `--no-trap-svc-error`

Found by the user running `yaGPC2` directly against `hello.fcm`
(compiled from `ported/PASS1.PROCS/HELLO.hal` — no explicit `%SVCI`
call, just falls off the end via `CLOSE`): stderr always showed `***
HAL/S PROGRAM HALT (SVC 0)`, which `yaHALMAT2` never prints for the same
program. Root cause: SVC 0x0015 is HAL/S-FC's universal,
successful end-of-program call — every compiled `CLOSE` reaches it, not
just abnormal exits — but `halucp_handle_svc()` (`halucp.c`) printed
this message unconditionally via the error-report channel, regardless
of `--verbose`. `yaHALMAT2` has no machine-code abstraction to trap at
all, so it simply exits silently on normal termination. Fixed by gating
the message on `h->verbose`, matching the existing `SVC DEBUG` trace-line
convention in the same function. Verified via direct cross-check
(`compileLinkRun`'s `yaHALMAT2 halmat.bin` run against `yaGPC2
hello.fcm`): stdout is now byte-identical by default.

While investigating, the user reported that trying to work around the
message themselves via `--no-trap-svc-error` made the message disappear
but also silently dropped the program's final buffered `WRITE` line
(`THE END`) — real data loss, not cosmetic. Root cause: `--no-trap-svc-error`'s
own name and `--help` text ("intercept HAL/S SEND ERROR SVCs") document
its scope as SVC 0x0014 (SEND ERROR) only, but the code gated `halucp_handle_svc()`'s
*entire* SVC layer — QUIT (0x0015), ERRGRP/ERRNUM (0x0117/0x0217),
SIGNAL/SET/RESET (0x000C-E), and the unknown-code fallback — behind one
top-level `trapSvcError` check. With the flag set, QUIT's own
channel-flush-then-halt logic (the substitute for what a real OS would
do on shutdown) never ran; since these bare/no-OS test images have no
real interrupt-vector code for the SVC to usefully fall through to
either, the machine just ran on into nothing, losing the pending output.
Fixed by narrowing the `trapSvcError` gate to only the 0x0014 branch, so
the flag now does exactly what its own documentation always said and
nothing more. Verified against the hand-assembled `svc_halt.fcm`/
`svc_senderror.fcm`/`svc_unknown.fcm` fixtures (`test/fixtures/gen_svc_fcms.cjs`):
SEND ERROR trapping is still the only thing `--no-trap-svc-error`
disables; QUIT/unknown-code handling is unaffected by the flag either
way. Full `yaGPC2` unit test suite re-run showed zero regressions (the
one pre-existing `test_cpu_instr_exec` CVFX failure, 114650/114801, is
unrelated and identical before/after this fix). The old `compare.sh`/
`run_matrix.sh` `gpc.js`-reference suite could not even be run in this
environment (`dist/gpc.js` and `yaGPC/yaGPC` both absent) — a pre-existing,
unrelated infra gap; that comparison axis was already superseded by the
`yaHALMAT2` cross-check (see Methodology below). Fixed in commit
`55bf9d7a5`; DB issue 78.

---

## 7. HAL/S runtime-feature coverage survey (2026-08-17)

A systematic survey of `yaGPC2`'s coverage of HAL/S *runtime* features
(as opposed to compile-time syntax), requested directly rather than
found via corpus sweeping. Six parallel research passes extracted every
distinct runtime feature documented in `USA003090` (HAL/S-FC User's
Manual) and `USA003087` (HAL/S Programmer's Guide), cross-referenced
against `src/halucp.c`/`src/schedule.c` and this file's own sections 2/3/5
for test evidence. Full itemized result (143 features, implementation
status, test status, source citations): `yaGPC2/hal-runtime-features.db`
(query via `hal-runtime-features.py list`/`show`/`search`/`stats`).

Most of the survey confirmed existing knowledge (the §2.7/§6 SCHEDULE/
WAIT/TASK scope-out list, the RUNTIME/CLOCKTIME/RANDOM gaps already in
§2.6, built-in math/vector/matrix functions working "for free" via
correct CPU execution of the real linked AP-101S runtime library). Two
findings were new:

### 7.1 `EXCLUSIVE` procedures and `LOCK`/`UPDATE`-block compool protection: unimplemented, not previously tracked

`USA003087` §27.2 (`EXCLUSIVE` procedures/functions: at most one process
may be executing inside one at a time, others `WAIT`) and §26.4
(`LOCK(n)`/`LOCK(*)` compool data + `UPDATE` blocks: the RTE enforces
mutual exclusion across processes contending for overlapping lock
groups) are both genuine real-time-executive mutual-exclusion
mechanisms — the same category of OS substitution work as `TASK`/
`SCHEDULE`/`WAIT` (§2.7/§6), described in nearly identical process-state
terms (`WAITING`, priority-influenced wake order).

`grep -rln "EXCLUSIVE\|UPDATE.*block\|LOCK(" src/*.c src/*.h` returns
nothing. Neither mechanism has any implementation anywhere in
`yaGPC2` — not a partial/scoped-down version, no SVC handler, nothing.
Whether the real compiled entry/exit sequence for either construct
traps via an SVC at all (and if so, which code) was not determined by
this survey; if it does, a program using either construct currently
falls through to `halucp.c`'s generic unhandled-SVC-trap path today.
No known fixture in this project's corpus exercises either construct,
so this has never surfaced as a corpus-sweep discrepancy — status
`suspected` in spirit (a real risk identified by reading the spec, not
by a failing repro), same caveat the DB issue tracker's own `suspected`
status describes.

### 7.2 `SCHEDULE ... REPEAT EVERY` cycle-overrun: silently absorbed instead of raising the documented runtime error

`USA003087` §23.5: if a `REPEAT EVERY interval` cyclic process's own
cycle execution takes longer than `interval`, the language defines this
as a runtime error condition ("the next cycle cannot start on time and
a run time error occurs") — not a silently-skipped/caught-up cycle.

`src/schedule.c`'s re-arm logic (`sched_handle_task_close`, added this
session for §2.7/§6) reads:
```c
double next = t->wakeDeadlineUs;
while (next <= cpu->elapsedTimeUs) next += t->repeatIntervalUs;
```
which silently advances past however many intervals were missed with
no error raised — a deliberate, documented design choice at the time
("drift-free... in case a firing ran long enough to miss more than
one"), but one that doesn't match the language spec's own runtime-error
contract for this case. `COUNTUP.hal` and `test/test_schedule.c` both
only exercise the non-overrunning case (each firing's own body is far
shorter than its 1-second interval), so this has never been exercised
by any existing test either.

Not fixed as part of this survey (a survey, not a fix pass) — logged
here as a confirmed, citable discrepancy for whoever picks up further
`SCHEDULE`/`WAIT` work. Whether it's worth fixing depends on whether
any real flight-software use case actually relies on the overrun
being reported (real FCOS itself is the authoritative precedent to
check, the same way `DEPENDENT`/`UPDATE PRIORITY`/combined process-event
expressions turned out to be language-spec features FCOS itself didn't
fully support — see §2.7/§6's own findings on that pattern).

**Resolved by §7.10** (item #9 of the implementation-order pass): checked
against real FCOS's own documented precedent as suggested above, and
confirmed this is exactly that same pattern — a genuine spec-vs-real-
implementation gap, not something to fix. See §7.10 for the full
research trail.

### 7.3 Implementation order for the survey's remaining gaps (2026-08-17, ongoing)

Working through `hal-runtime-features.db`'s `not_implemented`/`partial`/
`unresolved`/untested rows one at a time, in an order chosen for
dependency and value (smallest well-specified extensions of working
code first; the one genuinely new subsystem — an event-expression
evaluator — deliberately placed where it unlocks several other rows at
once). Each item gets implemented, verified against a real
HALSFC-compiled fixture cross-checked against `yaHALMAT2` as the
independent oracle (the same discipline `TASK`/`SCHEDULE`/`WAIT`
itself used), and the database updated in place — see
`hal-runtime-features.py show <id>` for the current status of any
specific row rather than duplicating it here.

**`WAIT UNTIL <time>` (SVC #7) — done.** Confirmed via a real compiled
`WAITUNTIL.hal` (`WRITE; WAIT UNTIL 2.5; WRITE;`) that the absolute-time
argument loads into the same FPR0-1 pair delta-time `WAIT` (SVC #6)
already uses. Implemented as `sched_handle_wait_until_svc`
(`src/schedule.c`), which computes `absoluteSeconds -
cpu->elapsedTimeUs/1e6` (clamped at zero for an already-past target,
matching `USA003087` §13.5's "does not leave READY") and delegates to
the existing `sched_handle_wait_svc` — no new state machine needed.
Output byte-identical to `yaHALMAT2`'s own run of the same source (once
a real invocation mistake was caught: `yaHALMAT2`'s `--litfile`/
`--memory` both default to auto-discovery alongside the HALMAT file;
passing them explicitly pointing at the same file silently corrupts
CHARACTER-literal output while still exiting 0 — cost an hour chasing a
phantom "yaGPC2 vs. yaHALMAT2 discrepancy" that was actually a bad CLI
invocation. Noted directly in `test/test_scheduler.sh`'s own header
comment so it isn't rediscovered.). New fixture
`test/fixtures/waituntil.hal`/`.fcm`/`-lnk101.json`/`_golden.txt`,
exercised by `test/test_scheduler.sh` under both `--pacing` modes.

**`TERMINATE` (SVC #2 self / SVC #3 named) — done.** Traced two real
compiled programs: `TERMTEST.hal` (a `REPEAT EVERY`-scheduled task
`TERMINATE`d by name from the primal, mid-stream) and `SELFTERM.hal` (a
task that `TERMINATE`s itself). Confirmed the named form's SVC parameter
word is `(count<<8)|3` followed by `count` PDE-address halfwords (a
relocation in the linker JSON directly ties the parameter word to
`#ETERMTE+6`, the target task's own PDE, in the same flat units
`SCHEDULE`'s own `PROCESS` field already uses — no `decode_pde_far_pointer`
extension needed); the bare/self form is SVC #2 with no parameters at
all. Implemented as `sched_handle_terminate_named_svc`/
`sched_handle_terminate_self_svc` (`src/schedule.c`) — both deactivate
their target(s) *unconditionally*, with no `REPEAT` re-arm, unlike
reaching `CLOSE` naturally (a real behavioral distinction the language
draws between the two exit paths). The self form is implemented in
terms of the named form (a task naming its own PDE), and both share a
`selfTerminated` check so naming the currently-running task (whether via
the bare form or by a task naming itself in the list form) correctly
switches context and dispatches the next ready task, while `TERMINATE`
of some *other* task leaves the caller running unchanged (matching
`SCHEDULE`'s own "never changes which context is live" contract).

This also **fixes a real, confirmed bug**: before this change, self-
`TERMINATE` was an unhandled SVC that silently fell through and let the
task's own remaining statements keep executing — `SELFTERM.hal`'s
`WRITE(6) 'UNREACHABLE';` right after its own `TERMINATE;` used to
print. Verified against `yaHALMAT2` as the independent oracle for both
fixtures; output byte-identical (and confirms `yaHALMAT2` never had
this bug — its own output already stopped at `TERMINATE`). New fixtures
`test/fixtures/terminate.hal`/`selfterminate.hal` (+`.fcm`/
`-lnk101.json`/`_golden.txt`), exercised by `test/test_scheduler.sh`
under both `--pacing` modes. Dependent-cascading (a `TERMINATE`d
process must also terminate its own dependents) remains out of scope,
same as it's been for `CLOSE`/`WAIT FOR DEPENDENT` all along — `DEPENDENT`
itself is still never recognized by `SCHEDULE`'s own FLAGS-word gate,
so no task is ever created as anyone's dependent in the first place.

**`UPDATE PRIORITY label TO alpha` (SVC #11, named-target form) — done.**
Traced a real compiled program to confirm the protocol: the SVC
parameter word is `(newPriority<<8)|11`, followed by the target task's
own PDE address — the same shape `TERMINATE`'s own named-target field
already established, and directly confirmed via the linker JSON's own
relocation entries the same way. Implemented as
`sched_handle_update_priority_svc` (`src/schedule.c`): mutates the
target's `priority` field in place, with no dispatch or context change
(the new priority simply takes effect whenever a future tie next
considers that task — matching `SCHEDULE`/`TERMINATE`-of-another-task's
own "never changes which context is live" contract). The bare/self form
(`UPDATE PRIORITY TO alpha;`, no label) could not be implemented or even
protocol-traced: every attempt to compile a real test case for it hit a
genuine HAL/S-FC PASS2 compiler limitation —
`***** BS122 ERROR ... INDIRECT STACK USAGE CONFLICT ***** CONVERSION ABANDONED`
— regardless of where in the task body the statement appeared. This is
the real 1980s-vintage compiler itself rejecting the construct, not a
`yaGPC2` gap; there is no compiled program to trace an SVC encoding
from, so the self form is left unhandled rather than guessed at.

Verified with `test_schedule.c`'s scenario 3: two hand-assembled
`REPEAT EVERY` tasks `SCHEDULE`d simultaneously (priorities 10 and 90),
`UPDATE PRIORITY`-raising the lower one to 200, and confirming dispatch
order actually flips. A real compiled fixture
(`test/fixtures/updatepriority.hal`, two competing `REPEAT EVERY` tasks
with `UPDATE PRIORITY` mid-run) exists for toolchain-encoding
provenance and runs without an unhandled-SVC trap, but is deliberately
**not** added to `test_scheduler.sh`'s byte-diff suite — see the next
finding.

### 7.4 Simultaneously-due `REPEAT EVERY` tasks: firing order can diverge from `yaHALMAT2` — expected, not a bug (found incidentally while verifying `UPDATE PRIORITY`)

While building a real-compiled-program regression test for `UPDATE
PRIORITY`, `yaGPC2` and `yaHALMAT2` disagreed on the exact interleaving
of two competing `REPEAT EVERY 1.0` tasks (priorities 10 and 90, no
`UPDATE PRIORITY` involved at all — confirmed with a stripped-down
`NOPRIO.hal` that reproduces it independent of this session's other
work): `yaHALMAT2` gives a perfectly clean `HI,LOW,HI,LOW,HI,LOW,...`
alternation every cycle; `yaGPC2` shows the same alternation for the
first tie, then a swap (`HI,LOW,LOW,HI,LOW,HI,...`) from the second tie
onward.

Mechanism: `SCHEDULE`ing two tasks takes two separate real SVC calls, a
few real AP-101S instructions apart — so each task's own
`repeatPhaseRefUs` (`src/schedule.c`, captured as `cpu->elapsedTimeUs`
at *that specific task's own* `SCHEDULE` call) is not bit-identical
between the two tasks, only very close. Since `REPEAT EVERY`'s re-arm
is phase-anchored (`phaseRef + N*interval`, not "now + interval" —
deliberately, to avoid drift from any *single* firing running long),
this tiny initial per-task offset is preserved and compounds
identically every cycle rather than averaging out, until it crosses
whatever tie-break margin `yaHALMAT2`'s own timing doesn't cross the
same way.

**Status (corrected by the user, 2026-08-17): not a fidelity gap to
close, and not fixable even in principle.** `yaHALMAT2` interprets
HALMAT — an artificial intermediate language with no hardware timing
semantics of its own and no guarantee any given HALMAT instruction
takes any particular amount of time. Whatever per-instruction "cost"
`yaHALMAT2` charges against `virtual_time` is necessarily a convention
`yaHALMAT2` itself invented, not a measurement of anything real.
`yaGPC2`, by contrast, executes real AP-101S machine code against
`timing.c`'s documented real per-instruction costs. Two independently-
invented timing models can agree on the *broad* shape of elapsed time
(which is all `--time-scale`/wall-clock pacing or a single WAIT's
duration ever needed) but have no basis for agreeing at the
sub-microsecond precision needed to keep two simultaneously-`SCHEDULE`d
tasks' phase references bit-identical over many cycles — this is the
same category of finding §2.8 already documents for floating-point
LSB-level differences, not a new open investigation. `test_schedule.c`'s
own hand-assembled scenario 3 sidesteps the whole question by
`SCHEDULE`ing both tasks via direct C calls at the exact same
`elapsedTimeUs` (bit-identical phase references by construction), which
is exactly why it, not the real compiled fixture, is this project's
regression test for `UPDATE PRIORITY` itself.

### 7.5 `RUNTIME()`/`PRIO()` built-ins — done

Fourth item in the runtime-feature-survey implementation order. See
§2.6's own correction above for the full `RUNTIME()` writeup (SVC 22 /
`0x0016`, converts `cpu->elapsedTimeUs` to seconds into FP0-FP1, no
longer blocked on the periodic-timer machinery once assumed necessary).

`PRIO()` (SVC `0x0317`) was traced the same way: a real compiled
`P = PRIO;` inside a dispatched `TASK` always stores its result via
general register 5's upper 16 bits, confirmed across two independently
compiled contexts with different surrounding register pressure — and
corroborated by `ERRGRP`/`ERRNUM` (`SVC 0x0117`/`0x0217`) already using
that exact same register for their own INTEGER results, a real
precedent rather than a one-off coincidence. Implemented as the
`svcCode == 0x0317` case in `halucp.c`: reads the currently-running
`ScheduledTask`'s own `priority` field directly (no new scheduler state
needed). `PRIO()` called with scheduling never engaged (no running task
at all) returns 0 — a defined, non-crashing default, not confirmed
against any real fixture since nothing calls `PRIO()` outside a `TASK`
in practice.

Unlike `RUNTIME()`, `PRIO()`'s result is an exact INTEGER with no timing
dependency at all — fully deterministic and byte-diffable against
`yaHALMAT2`. New fixture `test/fixtures/prio.hal` (`PRIO()` from within
a dispatched task, exact match confirmed), exercised by
`test_scheduler.sh` under both `--pacing` modes. A second fixture,
`test/fixtures/runtimeprio.hal` (both built-ins together), is kept for
toolchain-encoding provenance only, same non-diffed treatment as
`updatepriority.hal` (§7.3) — its `RUNTIME()` line inherits that
built-in's own value/ordering incomparability. `test_schedule.c`'s new
scenario 5 drives both SVCs directly (no hand-assembly needed — neither
built-in depends on CPU instruction execution, just a single SVC-code
halfword and a direct `halucp_handle_svc()` call) as the deterministic
regression test for both.

### 7.6 Process name as Boolean (`IF <task> THEN`) — done, plus a real `yaHALMAT2` gap found along the way

Fifth item in the runtime-feature-survey implementation order. Unlike
every other real-time construct implemented so far, this one produced
**no SVC trap at all** when traced against a real compiled program —
tracing the exact instruction sequence instead of an SVC parameter word
showed `IF NEXT THEN` compiles to a plain `TB <pdeAddr>(0),X'0001'`
(test bit) directly against the task's own PDE, no runtime-library call
in sight. This confirms `schedule.h`'s own PDE-layout comment, written
back when the PDE format was first reverse-engineered for `TASK`/
`SCHEDULE`/`WAIT`: "`+0`: PROCESS EVENT (true while scheduled/running)
— not modeled by this file; HAL/S programs practically never read a
task's own PDE directly, and nothing in this cut needs it written." One
now does.

Implemented as `sched_set_active_flag` (`src/schedule.c`), which sets
bit 0 of PDE+0 when a task becomes `SCHEDULE`d and clears it when it
goes back to `INACTIVE` — reaching its own `CLOSE` with no `REPEAT`, or
being `TERMINATE`d (even a `REPEAT EVERY` task, which `CLOSE`'s own
re-arm path would otherwise leave `ACTIVE`, so this needed independent
verification, not just "task no longer running"). Ordinary `RUNNING`↔
`WAITING`↔`DORMANT` transitions never touch it, matching `USA003087`
§13.1's own definition of `ACTIVE` as "in the process queue" (which
`DORMANT`-between-firings and `WAITING` both still are).

**Found along the way**: `yaHALMAT2` itself doesn't support this
construct at all — compiling and running the identical test program
through it produces `yaHALMAT2: SYT index 2 is a whole ARRAY/VECTOR/
MATRIX referenced outside an arrayed-paragraph replay` and halts. A
real `yaHALMAT2` gap (it appears to misinterpret a task-name reference
as an arrayed-data reference), not a `yaGPC2` one — but it means there
is no cross-tool oracle available for this fixture at all, unlike every
other feature implemented so far in this pass. Verified instead by
direct reasoning from the compiled instruction semantics (`TB`'s own
`exec_TB`: a plain AND-and-compare against the tested mask, no
ambiguity in which bit or which sense) plus two independent real
compiled test cases (`ACTIVE` right after `SCHEDULE`, `INACTIVE` right
after `TERMINATE`) both producing the expected, self-consistent output,
plus `test_schedule.c`'s new scenario 6 covering all three transition
paths deterministically at the C level.

New fixture `test/fixtures/processboolean.hal`, exercised by
`test_scheduler.sh` under both `--pacing` modes.

### 7.7 `SCHEDULE ... IN`/`AT` (delayed initiation) — done

Sixth item in the runtime-feature-survey implementation order. Tracing
`SCHEDULE NEXT IN 1.5 PRIORITY(80);` and `SCHEDULE NEXT AT 1.5
PRIORITY(80);` against the real compiled programs showed both compile to
the same `SVC #1` as plain immediate `SCHEDULE`, distinguished only by
the FLAGS word (`mem[ea+1]`): `IN` sets bit `0x0008`, `AT` sets bit
`0x0004` (plain immediate `SCHEDULE` sets neither). In both cases an `LED
F0,...` immediately before the `SVC` loads the time value into FPR0-1 —
the identical register pair delta-time `WAIT` and `WAIT UNTIL` already
use, not a new dedicated pair.

`halucp.c`'s `SCHEDULE` branch (previously an exact match against the
single signature `0x0081`, the only case needed before this item) was
generalized to decode the recognized FLAGS bits independently (`TASK`,
`AT`, `IN`, `REPEAT EVERY`) and reject anything else (still an
unhandled-SVC trap, same as before — `DEPENDENT`/`ON`/`CANCEL` remain
out of scope). `sched_handle_schedule_svc` (`schedule.h`/`.c`) gained a
new `initialWakeDeadlineUs` parameter — an absolute `cpu->elapsedTimeUs`
value, computed by `halucp.c` per case (`IN`: `elapsedTimeUs + interval`;
`AT`: the absolute time itself, clamped up to `elapsedTimeUs` if already
past, mirroring `sched_handle_wait_until_svc`'s existing precedent for a
past `WAIT UNTIL` deadline; plain `SCHEDULE`: `elapsedTimeUs`, i.e. due
now, unchanged behavior) — that seeds both the task's first
`wakeDeadlineUs` and, when combined with `REPEAT EVERY`, its
`repeatPhaseRefUs`. This was the one design question worth checking
empirically rather than assuming: does a delayed first firing shift the
whole repeat cycle's phase, or does the cycle stay anchored to `t=0`
regardless? A dedicated fixture (`SCHEDULE NEXT IN 1.5 PRIORITY(80),
REPEAT EVERY 1.0;`) settled it — firings land at 1.5, 2.5, 3.5, 4.5, not
0.5, 1.5, 2.5, 3.5 — i.e. the repeat phase is anchored to the delayed
initiation deadline, not to `t=0`. `test_schedule.c`'s new
`test_schedule_in_delays_first_firing_and_anchors_repeat` is the
deterministic regression test for this specific interaction.

Three new fixtures, all byte-diffed against `yaHALMAT2` (unlike
`RUNTIME()`/`UPDATE PRIORITY`'s own timing-sensitive fixtures in 7.4/7.5,
these are fully deterministic — the wake-up ordering and firing counts
don't depend on real-instruction-count drift the way two independently
`SCHEDULE`d, simultaneously-due `REPEAT EVERY` tasks do):
`test/fixtures/schedulein.hal`, `scheduleat.hal`, `schedulerepeat.hal`,
each exercised by `test_scheduler.sh` under both `--pacing` modes.

### 7.8 `WAIT FOR`/`SCHEDULE ... ON` event expressions — done, no working `yaHALMAT2` oracle, a real `yaHALMAT2` bug found along the way

Seventh item in the runtime-feature-survey implementation order, and the
one item this whole pass's original plan flagged in advance as the
genuinely new subsystem: an event-expression evaluator, rather than an
extension of an already-working one. Traced `WAIT FOR A;` against a real
compiled program and found SVC #8's own parameter word is a pointer to a
compact "event descriptor" in static data — `[opcodeWord, reserved,
PDE_1, ..., PDE_N]` — not a PDE address directly the way every other SVC
target field in this file is. Decoding the descriptor's `opcodeWord`
took 7 separate real compiled signatures (N=1 plain, N=1 `NOT`, N=2/3/4
`AND`-chains, N=2/3 `OR`-chains) to nail down precisely: top nibble =
`2*(N-1)`, remaining nibbles repeat a connector code (`3`=`AND`,
`1`=`OR`) `N-1` times, zero-padded; `NOT <single>` is the one fixed,
unrelated opcode `0x1800`. Along the way, three attempts at a *mixed*
expression — `(A AND B) OR C`, `A AND NOT B` — all hit the real
1980s-vintage HAL/S-FC PASS2 compiler's own `E102 ... INVALID EVENT
EXPRESSION` error, confirming the decoded format is the *entire* legal
design space, not a partial case of something bigger left unhandled.
`SCHEDULE ... ON` reuses the identical descriptor, referenced from
`SVC #1`'s own parameter block whenever FLAGS has both the `AT` bit
(`0x0004`) and the `IN` bit (`0x0008`) set together — confirmed
empirically that the real compiler reuses those two existing bits
combined as the `ON` marker rather than allocating a dedicated bit.

**The one real semantic surprise this item produced**: my first
assumption, formed from watching `SCHEDULE A PRIORITY(80); WAIT FOR A;`
run (`A` printing before the primal's own trailing `WRITE`), was that
`WAIT FOR` always defers to any ready higher-priority task before
resuming, the same way delta-time `WAIT` does. Reading `USA003087` 24.6
directly disproved this: *"If exp is already TRUE when the WAIT
statement is executed, the statement has no effect."* Since `SCHEDULE A`
already marks `A` `ACTIVE` (`TRUE` in event-expression terms —
`USA003087` 24.8's same `ACTIVE`↔`TRUE` polarity process-name-as-Boolean
already uses) before `WAIT FOR A` ever executes, the spec-correct
behavior is a *complete* no-op: no context save, no dispatch, not even a
momentary handoff to `A` — the primal continues straight through,
and `A` never runs at all if the primal happens to reach its own `CLOSE`
first (confirmed: `test/fixtures/waitfor.hal` produces `BEFORE` / `DONE`
only, `A` never printing `IN A`, because the primal's own `CLOSE` halts
the whole program before the scheduler ever gets a chance to dispatch
the now-abandoned, still-`DORMANT` `A`). This is implemented as an
early-return truth check in `sched_handle_wait_for_svc`, *before* even
the lazy primal-pseudo-task allocation every other `WAIT`-family SVC
does unconditionally.

**Real `yaHALMAT2` bug found, relayed upstream, not yet fixed**: the
identical test program (`SCHEDULE A PRIORITY(80); WAIT FOR A;`) run
through `yaHALMAT2` prints `BEFORE` / `IN A` and then exits 0 —
`DONE` never prints, at any priority (confirmed with `A` at both
`PRIORITY(80)` and `PRIORITY(1)`, ruling out a priority-specific fluke).
The primal is simply never resumed. This means there is **no working
cross-tool oracle for this feature at all** — the same situation
7.6 already established for process name as Boolean, but this time
`yaHALMAT2`'s own gap is a genuine behavioral bug (silently swallowing
the primal's continuation) rather than an outright unsupported-construct
error. Relayed to the user for the `yaHALMAT2` agent (with the full
reverse-engineered SVC/descriptor encoding included, so that side
doesn't have to re-derive it independently) rather than attempting any
fix in this repository. Verified instead purely from `USA003087`
24.6/24.8's own text, cross-checked against 8 real compiled programs
(the already-`TRUE` no-op case across single/`AND`/`OR`/`N`=3/`N`=4
forms, the one genuinely-`FALSE`-at-entry case — `WAIT FOR NOT
<already-ACTIVE task>` — which correctly blocks and resumes once that
task completes and deactivates, and a `SCHEDULE ... ON` case forcing a
real deferred-dispatch decision: a higher-priority `ON`-pending task
correctly does *not* preempt a lower-priority immediately-eligible one,
and is dispatched only once its own trigger event fires).

Five new fixtures — `test/fixtures/waitfor.hal` (already-`TRUE` no-op),
`waitfornot.hal` (genuine block+resume), `waitforand.hal`,
`waitforor.hal`, `scheduleon.hal` (real deferred dispatch) — all
exercised by `test_scheduler.sh` under both `--pacing` modes, with
goldens generated from `yaGPC2`'s own output (self-consistency
regression guards, not cross-tool-verified, same category as
`processboolean.hal` in 7.6) since no oracle exists. Two new
`test_schedule.c` scenarios (`test_wait_for_event_expressions`,
`test_schedule_on_deferred_dispatch`) cover what stdout alone can't:
the already-`TRUE` no-op's *zero side effects* (asserted via
`Scheduler.runningIdx` staying `-1`, proving the primal pseudo-task
isn't even lazily allocated), a mixed-truth 3-operand `AND`/`OR` chain
neither real fixture exercises, and `eventDescAddr` getting cleared the
moment a task is actually dispatched (no stale pointer left behind for
that slot's next use).

### 7.9 `SCHEDULE ... DEPENDENT`, `WAIT FOR DEPENDENT`, `TERMINATE` cascading — done, larger scope than originally planned

Eighth item in the runtime-feature-survey implementation order. The
original plan described this item as three coupled features; reading
`USA003087` §13.3 directly (rather than just §13.4/13.5's own SCHEDULE/
WAIT statement descriptions) surfaced a fourth, unplanned piece: *"If
execution ends on a CLOSE or RETURN statement, the process goes into
the inactive state directly only if it has no dependents. Otherwise, it
goes into a waiting state until the dependents have in their turn
terminated."* A task reaching its own **plain, unconditional `CLOSE`**
with a still-active `DEPENDENT` child does not deactivate — it blocks,
implicitly, until every one of its dependents has itself terminated.
Confirmed this is genuinely this file's own runtime responsibility, not
something the real compiler inserts extra instructions for: a real
compiled parent task (`SCHEDULE A PRIORITY(80) DEPENDENT;` followed
immediately by a bare `CLOSE`, no explicit `WAIT`) emits the exact same
`SVC 0x0015` every other `CLOSE` does — traced directly, confirmed no
compiler-inserted `WAIT FOR DEPENDENT` or anything else precedes it.

Traced `SCHEDULE A PRIORITY(80) DEPENDENT;` against a real compiled
program and found `DEPENDENT` is FLAGS bit `0x0020` — a clean, dedicated
bit, unlike `ON`'s reuse of two existing bits combined — confirmed to
compose additively with `AT`/`IN`/`REPEAT EVERY` exactly like every
other bit (`SCHEDULE A IN 1.0 PRIORITY(80) DEPENDENT;` → `0x0029`;
`SCHEDULE A PRIORITY(80) DEPENDENT, REPEAT EVERY 1.0;` → `0x00a1`).
`WAIT FOR DEPENDENT` (traced separately) is SVC `#9` with no parameters
of its own — it tests the calling task's own dependents, needing
nothing else.

**Design**: added `int parentIdx` to `ScheduledTask` (`-1` = independent,
set once at `SCHEDULE` time from whichever task is currently running —
`USA003087` §13.4: dependency is on the *executing* process, never a
separately-named one, so no extra SVC field carries it) and a new
`TASK_STATE_WAITING_FOR_DEPENDENTS` state, deliberately excluded from
`sched_dispatch()`'s own ready-scan (a task there is invisible to normal
dispatch — nothing to poll, unlike an event-expression wait, which *is*
re-evaluated on every dispatch pass) until explicitly released by
`sched_notify_dependent_finished`, called every time some task fully
deactivates for *any* reason (natural `CLOSE`, cascade-release one level
up, or `TERMINATE`). `pendingCloseAfterDependents` distinguishes the two
ways a released parent can be resolved: freed (the implicit
`CLOSE`-with-dependents case) or restored to `TASK_STATE_READY` to
resume execution (the explicit `WAIT FOR DEPENDENT` case) — both funnel
through the exact same "is this parent still waiting, are there still
active dependents" check, so the cascade composes correctly in either
direction (down through `TERMINATE`'s own recursive
`sched_terminate_idx_and_dependents`, or up through a chain of waiting
parents) without any code needing to know which triggered it.

`TERMINATE`'s own cascade (`USA003087` §13.3: *"All dependents of the
process are treated likewise"*; §23.6 confirms this for cyclic processes
specifically) is unconditional and immediate, transitively down the
*whole* dependency subtree — deliberately not graceful the way `CANCEL`
(out of scope, item #10) is documented to be. No real fixture goes more
than one dependency level deep (compiling a real multi-level chain
would need little beyond what `dependentclose.hal` already does, but
wasn't worth the extra fixture given `test_schedule.c`'s own
deterministic 3-level chain — grandparent → parent → child — already
proves the transitive case precisely, confirming `TERMINATE`-ing the
grandparent also frees the child even though it's never named directly).

Six new fixtures — `dependent.hal`, `dependentin.hal`,
`dependentrepeat.hal` (the `DEPENDENT` bit composing with `IN`/`REPEAT
EVERY`), `dependentclose.hal` (the key `CLOSE`-blocks-on-a-live-
dependent case), `waitfordependent.hal` — all exercised by
`test_scheduler.sh` under both `--pacing` modes, goldens generated from
`yaGPC2`'s own output (no `yaHALMAT2` oracle attempted, same category as
7.8's own finding). Three new `test_schedule.c` scenarios cover what
stdout can't show directly:
`test_dependent_close_blocks_until_dependent_finishes` (internal state —
`TASK_STATE_WAITING_FOR_DEPENDENTS`, the `PDE+0` `ACTIVE` bit staying set
throughout the wait), `test_wait_for_dependent` (the no-dependents no-op
and a genuine block+resume, restored to `TASK_STATE_READY` not freed),
and `test_terminate_cascades_to_dependents_transitively` (the 3-level
chain above).

### 7.10 `SCHEDULE ... REPEAT EVERY` cycle-overrun runtime error — researched, confirmed a real spec-vs-implementation gap, deliberately left unimplemented

Ninth item in the runtime-feature-survey implementation order. §7.2
already found the discrepancy (`schedule.c`'s re-arm loop silently skips
missed cycles instead of raising the `USA003087` §23.5-documented "a run
time error occurs") but explicitly deferred the question of whether it
was worth fixing to "whether real FCOS itself is the authoritative
precedent" — this item is that research, not a fix.

`USA003087` §25.1 states plainly that error-group/code *assignment* is
**"implementation dependent — see appropriate User's Manual"** — the
generic language guide never claims real FCOS actually implements every
abstractly-described runtime error. So the generic guide alone can't
settle this; the Shuttle-specific implementation documents have to.
Checked both available ones:

- **`USA003090`** (the HAL/S-FC User's Manual, Shuttle-specific) §8.4/
  Appendix C enumerate exactly **one** runtime error group in full — group
  4, entirely compiler-emitted arithmetic/library checks (division by
  zero, `SQRT` of a negative argument, domain errors, etc., 33 entries,
  none about timing or scheduling). No group 1/2/3/5/6 content appears
  anywhere in the document. More tellingly, its own §8.3, titled "Real-
  Time Statements," reads in full: *"This section was deleted by
  CR13613."* — the Shuttle-specific real-time-statement documentation
  was itself struck from this manual at some point in its revision
  history.
- **`IBM-76-SS-1110` Rev 5** (the HAL/FCOS Interface Control Document —
  already this whole implementation's own primary source for the entire
  SVC protocol, cited throughout `schedule.h`) confirms FCOS's error
  numbering scheme has *six* groups: group 2 "FCOS software defined
  errors" and group 5 "other FCOS defined system errors" both exist and
  are the natural home for an RTE-detected condition like a cycle
  overrun — but **neither group's own contents are ever enumerated**
  anywhere in the document. Only group 4's table is given (§4.2.3.4),
  and it's byte-for-byte the identical table `USA003090`'s own Appendix C
  has. Searched the full extracted text of both documents for "cyclic,"
  "overrun," "late," "missed," and "deadline" — zero matches in either,
  outside of the one syntax-diagram mention of the `REPEAT EVERY` keyword
  itself.

Structurally, this is doubly unfounded even setting the documentation
gap aside: there is no SVC-level mechanism through which FCOS *could*
report this back into a running program in the first place. A cyclic
task's own `CLOSE` compiles to the identical `SVC 0x0015` every other
`CLOSE` does (confirmed directly, `schedule.h`'s own header comment,
and re-confirmed this session for the `DEPENDENT` work in §7.9) — no
separate "cycle overrun" SVC has ever appeared in any protocol traced
this entire session, across roughly 30 real compiled test programs.

**Conclusion**: this is a genuine spec-vs-real-implementation gap, the
same category as `DEPENDENT`'s bare self-form and `UPDATE PRIORITY`'s
bare self-form both hitting real HAL/S-FC compiler limitations earlier
in this pass — not a `yaGPC2` to-do. `schedule.c`'s re-arm loop is left
exactly as it was, now with a confirmed rationale rather than an open
question. `hal-runtime-features.db` row 11 updated accordingly
(`impl_status` stays `not_implemented`, matching the existing precedent
for other confirmed-dead-end language-spec features like the `FILE`
statement; `test_status` set to `not_applicable` — there is nothing to
test against).

### 7.11 `CANCEL` statement — done, a real `yaHALMAT2` divergence found along the way

Tenth item in the runtime-feature-survey implementation order, `TERMINATE`'s
graceful sibling (`USA003087` §13.5/§23.6). Traced `CANCEL A;` against a
real compiled program and found SVC #5 (named form) with the identical
count-then-PDE-list parameter encoding `TERMINATE`'s own SVC #3 already
uses; bare `CANCEL;` (self form) is the separate, parameterless SVC #4,
mirroring `TERMINATE`'s own #2/#3 split exactly.

**One genuinely surprising result, worth tracing a full instruction
trace over rather than trusting the coarse SVC-only summary**: a real
compiled task —

    A: TASK;
       CANCEL;
       WRITE(6) 'UNREACHABLE';
    CLOSE A;

— actually prints `'UNREACHABLE'`. A bare self-`CANCEL` does **not**
alter control flow at all; the rest of the current cycle's own code
runs completely normally, including its own `WRITE` call. This exactly
matches `USA003087` §23.6's literal text — *"If the process is in a
cycle of execution, it is canceled at the end of the cycle"* — not
immediately, unlike `TERMINATE`. The label `UNREACHABLE` in the test
source was a bad guess on my own part before tracing the full
instruction stream (not just the SVC summary) settled it; documented
here so it isn't second-guessed again.

**Design**: a new `ScheduledTask.cancelled` flag, set only when the
target is currently RUNNING (which, in this cooperative single-CPU
model, can only ever be the calling context itself — a named `CANCEL`
can never observe a *different* task as RUNNING). `sched_handle_task_close`
checks it alongside `hasRepeat`: a cancelled `REPEAT EVERY` task falls
through to the same has-active-dependents-or-free path a non-repeating
task already uses, exactly matching the graceful, end-of-cycle
semantics. A DORMANT target (`USA003087` §23.6's other two cases — "not
yet initiated" and "waiting between cycles" — produce the *identical*
outcome, so both are handled by one code path) is canceled immediately,
reusing the exact `TASK_STATE_WAITING_FOR_DEPENDENTS` mechanism §7.9's
`CLOSE`-with-dependents case built, with the cascade to `DEPENDENT`
children applying CANCEL's own graceful semantics recursively at every
node (§23.6: *"cyclic dependents are allowed to finish their own
current cycle of execution"*) rather than `TERMINATE`'s
unconditional-immediate one. A `test_schedule.c` scenario confirms this
propagates transitively through a 3-level chain — a `RUNNING`
grandchild correctly blocks both its parent and grandparent from
deactivating until it finishes its own cycle.

**Real `yaHALMAT2` divergence found, not yet relayed**: none of the
three real fixtures checked in for this item match `yaHALMAT2`'s own
output. `cancel.hal`/`cancelnamed.hal` (`CANCEL`-ing a target before its
first cycle) still let it run once in `yaHALMAT2` — the "not yet
initiated → removed" rule isn't implemented there. `selfcancel.hal`
(bare self-`CANCEL`) does the *opposite* of the surprising finding
above: `yaHALMAT2` skips the rest of the current cycle entirely (`DONE`
prints with no `UNREACHABLE` at all), as if self-`CANCEL` behaved like
self-`TERMINATE`. Both readings are internally consistent with
`yaHALMAT2` simply not having a distinct `CANCEL` implementation yet
(one behaving as a no-op, the other as `TERMINATE`) rather than a subtle
disagreement — worth relaying the same way the `WAIT FOR` finding was,
but not yet done as of this writing.

Three new fixtures — `cancel.hal`, `selfcancel.hal`, `cancelnamed.hal` —
all exercised by `test_scheduler.sh` under both `--pacing` modes, goldens
generated from `yaGPC2`'s own output (no oracle, same category as
§7.8/§7.9). Four new `test_schedule.c` scenarios cover what stdout can't
show and no real fixture combines `CANCEL` with `DEPENDENT` at all:
self-`CANCEL`'s own zero-control-flow-effect (`NIA`/registers unchanged,
only the `cancelled` flag set), immediate removal of a DORMANT named
target, the 3-level transitive graceful-wait chain above, and a `RUNNING`
dependent being flagged rather than force-freed mid-cycle when its
parent is `CANCEL`ed.

### 7.12 `EXCLUSIVE` procedures/functions and `UPDATE` blocks — done, one real scheduler bug found by its own test, one more `yaHALMAT2` divergence

Eleventh item in the runtime-feature-survey implementation order. Unlike
almost everything else in this pass, the SVC protocol here didn't need
reverse-engineering at all — `IBM-76-SS-1110` Rev 5 §4.2.2/§4.2.2.3
documents the reserve/release SVC family in full: `SVC #15`
(RESERVE, code block) on entering an `EXCLUSIVE` procedure/function,
`SVC #17` (RELEASE) on its `CLOSE`; `SVC #16`/`#18` for the same on
`UPDATE`-block entry/`CLOSE`. All four read a shared 3-halfword
parameter block, addressed one halfword apart (confirmed empirically: a
real compiled `RESERVE`'s own `ea` and the matching `RELEASE`'s own `ea`
differ by exactly 1). Traced a real `EXCLUSIVE` procedure and found the
ICD's documentation matched byte-for-byte, including that a `PROCEDURE`'s
own `CLOSE` — unlike a `TASK`/`PROGRAM`'s — does **not** compile to
`SVC 0x0015` at all; it returns via an ordinary subroutine `RETURN`,
entirely outside this file's existing task-`CLOSE` handling.

**Design**: `EXCLUSIVE` (code-block) locks are exact-match, tracked in a
small scheduler-level table (`Scheduler.codeLocks`) since at most one
process holds a given procedure at a time. `UPDATE`-block (data-area)
locks are bitmask-overlap, per `USA003087` §26.4's own group-based
protection — disjoint `LOCK` groups can be held by different processes
simultaneously — so holds live per-task (`ScheduledTask.heldDataLockMask`)
rather than in one global table. Both reuse the exact same blocking
mechanism `WAIT FOR`'s event expressions and `WAIT FOR DEPENDENT`
established: a contended `RESERVE` suspends the calling task
(`TASK_STATE_WAITING`), polled by `sched_dispatch()`'s own eligibility
scan; a released lock doesn't force a dispatch itself — the waiter is
only actually granted once *something* forces a fresh dispatch decision,
at which point the winner (by priority, same as every other candidate)
gets the lock recorded as part of being dispatched, transparent to the
resumed code.

**A real scheduler bug, caught by its own deterministic test before it
ever reached a real fixture**: the first draft of `sched_handle_reserve_data_svc`
copied `EXCLUSIVE`'s own "don't bother allocating a scheduler slot for
an immediately-granted, non-contended `RESERVE`" optimization. That's
safe for code locks (the holder is recorded in the scheduler-level
table, self-consistent even under the `-1` "primal, never engaged"
sentinel) but not for data locks (the holder lives on a *per-task*
field that doesn't exist yet for an unengaged primal) — an immediately-
granted, unrecorded hold would be silently lost the instant the primal
was later engaged for an unrelated reason while still holding it
(exactly what `exclusivecontend.hal`'s own pattern does for real:
`RESERVE`, then `WAIT` while still "inside"). `test_update_block_lock_groups_overlap_and_release`
caught this immediately (four assertions failed) before any of this
reached a real fixture or, worse, shipped silently broken for a case no
fixture happens to exercise. Fixed by always engaging a real scheduler
slot on data-lock `RESERVE`, even when granted immediately — the one
place this feature's design deliberately diverges from `EXCLUSIVE`'s own.

**Real `yaHALMAT2` divergence found**: `exclusivecontend.hal` (the
primal enters `P`, `WAIT`s mid-procedure, and a separately `SCHEDULE`d
task's own attempt to enter the same `P` should block until the primal
releases it) produces `A ENTER P` **twice** on `yaHALMAT2` — it doesn't
enforce mutual exclusion at all, letting the second task barge straight
into `P` while the first is still inside. Relayed upstream separately
from the `CANCEL` finding, not fixed here.

**Not independently verified against a real compiled `UPDATE`-block
fixture**: doing so needs a genuine multi-module `COMPOOL`+`PROGRAM`
link this pass didn't set up (confirmed a real one is required —
`LOCK` is explicitly compool-only per §26.4), and confirmed separately
that a real `UPDATE` block can't even contain `WRITE`/I/O statements at
all (a real PASS1 compiler error: *"I/O STATEMENTS ARE ILLEGAL INSIDE
UPDATE BLOCKS"*), so even a successful compile wouldn't produce the
kind of easy stdout-based confirmation every other fixture in this
codebase relies on. Confidence instead rests on the ICD's own
documentation (the same table already confirmed byte-for-byte accurate
for the `EXCLUSIVE`/code-lock case) plus the fact that the overlap-
detection logic never needs to interpret *which* bit means *which* lock
group — only compiler-guaranteed self-consistency between a program's
own `RESERVE` and `RELEASE` for the same `LOCK(n)` attribute, which
holds regardless of bit-ordering convention. `test_update_block_lock_groups_overlap_and_release`
is this feature's *only* coverage as a result — genuinely deterministic
(disjoint groups granted immediately, partial overlap blocks, release-
then-redispatch grants correctly), but not real-fixture-cross-checked
the way `EXCLUSIVE` is.

Three new fixtures — `exclusive.hal` (non-contended), `exclusivetwo.hal`
(two distinct procedures, confirming independent, stable `LOCK ID`s),
`exclusivecontend.hal` (genuine cross-task contention) — all exercised
by `test_scheduler.sh` under both `--pacing` modes, goldens generated
from `yaGPC2`'s own output.

### 7.13 Closing out the implementation-order pass: `FILE`, `NEXTIME()`, Program Processes, `RANDOM()`/`RANDOMG()`

Twelfth and final item. Unlike every other item in this pass, none of
these needed new code — each resolves to either a confirmed permanent
dead end (real FCOS never supported it, matching the precedent already
established for `SCHEDULE`'s own cycle-overrun runtime error in §7.10)
or a genuinely different kind of gap this scheduler-substitution pass
was never going to close.

**`FILE` (random-access I/O) — reconfirmed, not new research.** An
earlier session (2026-08-01, preserved in this agent's own memory)
already settled this: `USA003090` §6.2 states plainly, *"File I/O is
not supported by the HAL/S-FC runtime library. If a FILE I/O statement
is compiled, unresolved external references will occur at link edit
time."* Unlike `WRITE`/`READ` (self-contained inline code trapping into
`OUTRAP`/`INTRAP`/`CNTRAP`), `FILE` compiles to a call to an RTL routine
that never existed for the AP-101S-targeted compiler — a real program
using it could never even be linked into a working binary. `Programming
in HAL/S` still documents it because that textbook predates the
AP-101S/RTL toolchain both emulators target. Re-verified the citation
directly this session (it hadn't drifted) and updated
`hal-runtime-features.db` rows 35/36/49 from `not_implemented` to
`not_applicable` to reflect that this was already settled, not still
open.

**`NEXTIME(<label>)` — newly confirmed as the same category of dead
end.** `IBM-76-SS-1110` §4.2.4.1's own `RUNTIME`/`CLOCKTIME`/`DATE`/
`NEXTIME` parameter-list table lists all four request types together
(0-3), then states outright: *"FCOS will not support the NEXTIME
function."* The old `hal-runtime-features.db` note cited `RUNTIME()`
and `SCHEDULE...IN`/`AT` as blockers — both are now implemented (items
#4/#6 of this same pass) — but it wouldn't have mattered either way,
since the real RTE itself rejects request type 3 regardless. Updated to
`not_applicable`.

**Program Processes (`SCHEDULE` targeting a separate compiled
`PROGRAM`) — reconfirmed out of scope, but *not* a dead end.** Unlike
`FILE`/`NEXTIME`, real FCOS genuinely did support this. The gap is
architectural, not historical: `schedule.c` only ever decodes a PDE
reached from the one already-loaded linked image, and supporting a
second, independently-compiled `PROGRAM` as a `SCHEDULE` target needs
multi-image loading at the `AGEHarness`/`main.c` level (linking more
than one `.fcm` into one address space at once) — infrastructure this
whole scheduler-substitution pass never touches. Left `not_implemented`,
with the distinction from `FILE`/`NEXTIME` now made explicit in its own
notes.

**`RANDOM()`/`RANDOMG()` — confirmed out of this pass's scope
specifically, not a dead end either.** Checked `IBM-76-SS-1110`'s own
§4.2.4 "HAL/S Functions" section directly: `RUNTIME`/`CLOCKTIME`/`DATE`/
`NEXTIME` (SVC #22) and `PRIO`/`ERRGRP`/`ERRNUM` (SVC #23) both have
real, documented SVC parameter lists — `RANDOM`/`RANDOMG` appear nowhere
in that section at all. This confirms they compile to a plain
math-library call with no RTE/SVC involvement whatsoever, the same
category as `SIN`/`COS`/`SQRT` (Appendix C's own "group 4" HAL/S-FC
library) rather than anything this session's real-time-executive
substitution work (`schedule.h`/`.c`, `halucp.c`'s SVC dispatch) is
positioned to implement. A real gap (no PRNG/seed mechanism exists
anywhere in `yaGPC2`, per the original §2.6 finding), but for a
different subsystem to pick up, not this one.

With this, all twelve items of the implementation-order plan (§7.3) are
now resolved — nine implemented and tested (#1-8, #11 as separate
commits; `WAIT UNTIL`, `TERMINATE`, `UPDATE PRIORITY`, `RUNTIME()`/
`PRIO()`, process-name-as-Boolean, `SCHEDULE...IN`/`AT`, `WAIT FOR`/
`SCHEDULE...ON`, `DEPENDENT`/`WAIT FOR DEPENDENT`/cascading `TERMINATE`,
`CANCEL`, `EXCLUSIVE`/`UPDATE` blocks), three resolved as confirmed
out-of-scope with primary-source citations rather than code (#9's cycle
overrun, and this section's `FILE`/`NEXTIME`/Program Processes/
`RANDOM`/`RANDOMG`).

### 7.14 `hal-runtime-features.db` sweep: `EVENT`-variable operands in event expressions confirmed working, three stale entries corrected

With the twelve-item plan closed out, swept the rest of
`hal-runtime-features.db` for anything else this pass's own work might
have already resolved without the database being updated to match — the
same kind of drift already caught once this session (§7.5's `RUNTIME()`
correction). Found three real cases, one worth its own investigation.

**Rows 22/24 (event-expression evaluation; process names as
operands) were stale, and checking them surfaced a real, previously
untested gap: item #7's `WAIT FOR`/`SCHEDULE ... ON` work was only ever
traced and tested against *process-name* operands (`WAIT FOR A;` and
friends) — never against a genuine `EVENT`-typed variable (`DECLARE EV1
EVENT LATCHED; ... SET EV1; WAIT FOR EV1;`), which is the more literal
reading of both rows' own descriptions.** Traced a real compiled `SET
EV1; WAIT FOR EV1;` program and found the descriptor format and `SVC`
protocol are *identical* to the process-name case — down to the exact
same `SVC #8`, the same 3-halfword descriptor, the same single-operand
opcode `0x0000`. The only difference is what the operand address
*means*: for a process, it's the PDE's own `+0` halfword (bit 0 =
`ACTIVE`); for an `EVENT LATCHED` variable, it's the variable's own
storage cell, using the identical bit-0-is-the-boolean-value convention.
Since `schedule.c`'s own `sched_task_active()` never interprets *why* a
given address holds a 1 or a 0 — it only ever reads bit 0 of whatever
address a descriptor entry points to — this meant **zero source changes
were needed**: running the real fixture against the already-committed
binary produced exactly the spec-predicted output immediately. Verified
three cases for real: an already-`TRUE` no-op, a genuine cross-task
`SET`-then-block-then-resume (a `WAIT FOR`ing primal blocked on `EV1`,
a `SCHEDULE`d task that `SET`s it, matching the exact shape
`waitfor.hal`'s own process-name test already used), and a 2-operand
`AND`-chain of two `EVENT` variables — all three byte-identical to
`yaHALMAT2`'s own output (whose independent preemption fix, landed
earlier in this same conversation via the direct cross-session channel,
made this comparison possible at all).

Along the way, also tested the mixed-operand-type case `USA003087`'s
own footnote 42 example describes (`WAIT FOR EV1 & (¬ALPHA);`, an
`EVENT` variable combined with a negated process name) and confirmed
it hits the *same* `E102 INVALID EVENT EXPRESSION` compiler rejection
already established in §7.8 for pure-process mixed expressions like
`A AND NOT B` — the restriction is about mixing `NOT` with `AND`/`OR`
at all, not specifically about combining operand *types*. This
corrects a misreading in row 24's own old notes, which had cited that
same footnote as evidence the language spec and real FCOS specifically
disagreed about combining events with process names — they don't; the
real restriction is orthogonal to operand type entirely.

**Row 25 (`TERMINATE`) was independently stale** in an unrelated way:
its own notes still said "dependent-cascading not implemented (`DEPENDENT`
itself out of scope)," written before item #8 implemented both.
Corrected to `implemented`, pointing at
`test_terminate_cascades_to_dependents_transitively` for coverage.

Three new fixtures — `waitforeventvar.hal`, `waitforeventvarblock.hal`,
`waitforeventvarand.hal` — exercised by `test_scheduler.sh` under both
`--pacing` modes, byte-diffed directly against `yaHALMAT2` (a genuine
working oracle this time, unlike most of this pass's later items).

### 7.15 `DATE()`/`CLOCKTIME()` — done, format/anchor convention settled with the user and `yaHALMAT2`, one real register-convention bug found via a real fixture

The §7.14 sweep flagged `DATE()`/`CLOCKTIME()` (rows 96/97) as
never specifically checked despite sharing `RUNTIME()`'s own `SVC #22`
family — picked up as the next task per the user's go-ahead.

**Design, decided with the user (not guessed):** yaGPC2 has no real
mission epoch the way real FCOS would (an actual launch GMT). The user's
explicit direction: by default use the real host date/time in the
process's own local timezone as a start-of-run anchor, then progress
using emulated (virtual) time thereafter; provide a CLI override for
reproducible runs; and consult `yaHALMAT2` for alignment. `yaHALMAT2`
independently reached the identical design with its own user and had
already implemented it (`--start-time`, accepting a local wall-clock
string or bare epoch seconds) by the time this session asked — both
emulators now share the same anchor-plus-virtual-progression model,
communicated and confirmed over the direct cross-session channel.

**Format**, verified against documentation rather than accepted from
either peer's guess: `USA003090` §8.2 item 17 states `DATE()` returns
`YYDDD` (`(year%100)*1000 + day-of-year`, `DDD` 1-indexed) as an
`INTEGER` — confirmed as *this* implementation's authoritative source
since `USA003087`'s own generic Appendix B table leaves the format
"implementation dependent." `CLOCKTIME()`'s unit is undocumented
anywhere searched (`USA003087`, `USA003090`, `IBM-76-SS-1110` — no hit
for "centisecond"/"hundredth"/"0.01 second"); the user's own initial
recollection of centiseconds was retracted once shown the negative
search result (likely conflated with the unrelated XPL/I compiler's own
runtime library). Implemented as seconds since local midnight — the
only reading consistent with `USA003090`'s "double precision scalar"
description and the name itself, delivered in FP0-FP1 exactly like
`RUNTIME()`'s own convention.

**Mechanics**, traced from a real compiled `T=CLOCKTIME; D=DATE;`:
both share `RUNTIME`/`NEXTIME`'s own `SVC #22` (low byte `0x16`),
distinguished by a `TYPE` field in the high byte (`mem[ea]=0x0116` for
`CLOCKTIME`, `0x0216` for `DATE` — 0=RUNTIME, 1=CLOCKTIME, 2=DATE,
3=NEXTIME, matching `IBM-76-SS-1110` 4.2.4.1's documented layout
exactly). `TYPE=3` (NEXTIME) is deliberately left unrecognized, per
§7.13's own confirmed dead end. Both derive their result from
`cpu->dateTimeAnchorEpochSec + cpu->elapsedTimeUs/1e6`, decomposed via
`localtime_r()` at query time — `dateTimeAnchorEpochSec` defaults to a
fixed, deterministic `0` in `cpu_init()` (so direct/embedded/test
construction of a CPU never depends on real wall-clock time, matching
`fcosMode`'s own precedent), with the CLI's own default (the real host
clock at program start) applied one layer up in
`ageharness_configure_from_opts()`; a new `--date-time-epoch <seconds>`
flag overrides it for reproducible runs (mirrors `yaHALMAT2`'s own
`--start-time`, though not identically named or shaped — `yaHALMAT2`
also accepts flexible date/time strings, this side accepts only raw
epoch seconds; flagged to `yaHALMAT2` as a possible follow-up
unification, not resolved this session).

**A real bug, caught by tracing the actual compiled instruction stream,
not just the `SVC` summary:** the first implementation copied
`PRIO()`/`ERRGRP()`/`ERRNUM()`'s own convention of pre-shifting an
`INTEGER` result into R5's upper 16 bits (their own real fixtures show
a bare `STH 5,<dest>` immediately after the `SVC`, confirming *their*
raw hardware result is already upper-half). `DATE()`'s own real
compiled sequence for `D = DATE;` is different: `SVC`, then
`SLL 5,X'0010'`, then `STH 5,<dest>` — an extra shift with no
counterpart in the `PRIO`/`ERRGRP`/`ERRNUM` fixtures. Storing
pre-shifted-upper produced `0` (the `SLL` shifted the already-upper
value entirely out of the 32-bit register) — caught immediately by a
real fixture assigning `DATE()` into a plain (single-precision)
`INTEGER`, not a synthetic unit test. The `SLL` is `USA003090` 8.2 item
8's own documented double-to-single `INTEGER` conversion ("eliminating
the left-most 16 bits of the double precision value"), which only makes
sense if R5 holds the *raw, right-justified* 32-bit value beforehand —
i.e. `DATE()`'s true hardware result is an `INTEGER DOUBLE` (32-bit),
unlike `PRIO`/`ERRGRP`/`ERRNUM`'s small values that already fit
`INTEGER SINGLE` directly. This tracks: `YYDDD` reaches up to 99366,
overflowing `INTEGER SINGLE`'s 16-bit signed range (`USA003090` 8.2 item
1, `-32768..32767`) — a plain `DECLARE D INTEGER;` silently truncates
`DATE()`'s value per item 8's own documented (not erroneous) conversion
rule, confirmed directly: `--date-time-epoch` anchored at 1978-02-01
06:00 gave the correct double-precision value 78032 when `D` was
declared `INTEGER DOUBLE`, but silently truncated to 12496 (78032's low
16 bits) when `D` was left as plain `INTEGER` — both are *correct*
per spec, not a bug, once the register convention itself was fixed.
Fixed by delivering the raw, unshifted 32-bit value in R5 for `DATE()`
specifically, leaving `PRIO`/`ERRGRP`/`ERRNUM`'s own pre-shifted
convention untouched (real, fixture-confirmed, and no longer assumed to
generalize to every `INTEGER`-returning built-in `SVC`).

New fixture `datetimefn.hal` (`D` declared `INTEGER DOUBLE`, a `WAIT
3600` before reading `CLOCKTIME`/`DATE` so both reflect real
virtual-time progression past the anchor, not just the anchor itself),
exercised by `test_scheduler.sh` under both `--pacing` modes with
`TZ=UTC` and a fixed literal `--date-time-epoch` (not computed via
`date` at test time, so the golden file stays reproducible regardless
of the host's own timezone database) — byte-diffed against `yaHALMAT2`
(`--start-time`, same epoch, same `TZ=UTC`), matching exactly. Also spot
-checked by hand (not committed as a fixture): a midnight-rollover case
(anchor 30 minutes before local midnight, `WAIT 3600`) correctly
produced the next day's `DATE()` and a small positive `CLOCKTIME()`.
`hal-runtime-features.db` rows 96/97 updated from `not_implemented` to
`implemented`/`tested_dedicated`.

**Follow-up (2026-08-18): the embedding contract had the same gap, and the
CLI-only fix above did not close it.**  `ageharness_init_minimal()` /
`yagpc2_initializer()` — the path any Shuttle-sim-style embedder takes through
`GpcOps` — never touched `cpu.dateTimeAnchorEpochSec` at all, so an embedded
instance always ran silently with `DATE()`/`CLOCKTIME()` anchored at epoch 0,
with no way for the embedding main program to supply a starting time at all.
Per the user's explicit design ("the initializer should take this time/date as
an argument, and store it in the state structure ... rather than relying on ...
some implementation-dependent global location"), fixed by adding a
`startEpochSeconds` parameter to `GpcInitializerFn` and a matching
`GpcState.startEpochSeconds` field — both in the shared header, alongside
`elapsedTime`'s own precedent — threaded through a new
`ageharness_init_minimal()` parameter into `cpu.dateTimeAnchorEpochSec`, and set
on `GpcState` by `yagpc2_initializer()` (`src/gpcops.c`).
`ageharness_configure_from_opts()`, the CLI path, needed no change: it already
implements the correct policy independently.  New regression test
`test_start_epoch_via_initializer` (`test/test_gpcops.c`) drives the CLI's own
`--date-time-epoch` golden (`datetimefn.fcm`, epoch 951912000, `TZ=UTC`)
through the embedding path instead, confirming the two agree.  Because
`../yaGpcIntegration/yaGpcIntegration.h` must stay byte-for-byte identical
between yaGPC2 and yaHALMAT2, the matching change was requested of the
yaHALMAT2 peer session (message sent 2026-08-18); check its reply before
treating the two repos' copies as back in sync.

### 7.16 `SCHEDULE ... REPEAT`'s remaining cadences (bare, AFTER) and UNTIL-time cancellation — done, one real fast-forward bug found and independently confirmed on `yaHALMAT2`'s own side too

Self-selected from the survey (rows 7/8/10 of `hal-runtime-features.db`):
only `REPEAT EVERY` had ever been implemented (item #6, long before this
session's later items); bare `REPEAT` (immediate recycling), `REPEAT
AFTER` (constant intercycle delay), and any `UNTIL`-time cancellation
clause were all still `not_implemented`, despite `schedule.h`'s own
header comment flagging `REPEAT AFTER` specifically as a "mechanically
similar follow-on once EVERY works." `REPEAT ... WHILE/UNTIL event-expr`
(row 13, a materially different mechanism needing the event-expression
evaluator) was deliberately left out of this pass's scope.

**FLAGS-word bits traced empirically** against four real compiled
programs (bare `REPEAT UNTIL`, `REPEAT AFTER` alone, `REPEAT EVERY ...
UNTIL`, and `REPEAT AFTER ... UNTIL`): bits 6-7 (mask `0x00C0`) encode
the cycling mode as a 2-bit field — `0x00`=none, `0x40`=bare, `0x80`=
EVERY (already known), `0xC0`=AFTER — confirming the top-of-file header
comment's own long-standing "REPEAT none/REPEAT/EVERY/AFTER" prediction
was a real 2-bit field, not four independent bits. Bit 8 (`0x0100`)
marks an `UNTIL`-time clause present, composing freely with every
`REPEAT` variant. `REPEAT AFTER`'s own delay value shares `REPEAT
EVERY`'s FPR2-3 pair exactly (confirmed via instruction trace: `REPEAT
AFTER 2.0` loads FP2-3 identically to `REPEAT EVERY 1.0`). `UNTIL`'s own
value is in FPR4-5, and — like `AT` — is an absolute "seconds after the
real time origin," not a delta from "now."

**Re-arm semantics**, each cadence distinct (`RepeatMode` enum,
`schedule.h`): `EVERY` keeps its existing phase-anchored re-arm
(`phaseRef + N*interval`, never drifting from however late a firing
ran); `AFTER` re-arms to `elapsedTimeUs + delay` at CLOSE time — no
phase anchor needed, since by definition it's always measured from
*this* cycle's own end, so it can't drift; `BARE` re-arms to
`elapsedTimeUs` itself (the CLOSE instant) — no numeric parameter at
all, the next cycle is due immediately.

**`UNTIL`-time cancellation checked at two sites**, matching
`USA003087` §23.5's own two-part rule verbatim: (1) at CLOSE
(`sched_handle_task_close`) — "cancellation actually takes place at the
end of the first cycle which finishes later than the specified time";
(2) on every `sched_dispatch()` call, for any `DORMANT` task
(`sched_dispatch`'s own new pre-pass) — "if the cancellation condition
is met in the interval between cycles, cancellation takes place
immediately." Both reuse `sched_cancel_idx_and_dependents` verbatim, the
same mechanism the explicit `CANCEL` statement already uses — `§23.6`
describes `REPEAT...UNTIL` and `CANCEL` as the same underlying
cancellation mechanism, differing only in what triggers it ("cancellation
conditions in SCHEDULE statements cannot be dynamically modified; to
cancel a cyclic process arbitrarily, the CANCEL statement must therefore
be used"), so this correctly inherits the same RUNNING-vs-DORMANT
asymmetry already established for `CANCEL` (a `RUNNING` target's own
dependents are naturally waited for, not force-cancelled; only a
`DORMANT` target's between-cycles cancellation cascades immediately —
see `ScheduledTask.cancelled`'s own comment).

**A real internal bug, caught while verifying the between-cycles case
specifically, not by inspection:** `sched_dispatch`'s own virtual-time
fast-forward step (advances `cpu->elapsedTimeUs` to "whatever's next"
when nothing is immediately ready) only ever considered each pending
task's own `wakeDeadlineUs` as a candidate, never a `DORMANT` task's own
`UNTIL` time. Whenever `UNTIL` fell strictly between a cycle's own CLOSE
and that same task's next `wakeDeadlineUs` — e.g. `REPEAT AFTER 10.0
UNTIL 3.0`, with nothing else in the whole program scheduled in that
8-second gap — the fast-forward jumped straight past the cancellation
instant to the task's own next (much later) wake time before the
pre-pass's own check ever got a chance to run at the *correct* instant.
The cancel/no-cancel *outcome* was unaffected (still correctly
cancelled, just later than it should have registered), which is exactly
why this needed a fixture built specifically to expose it rather than
just checking cycle counts: `DECLARE ... DEPENDENT`, `WAIT FOR
DEPENDENT`, then `RUNTIME()` immediately after — since a
dependent-satisfied wakeup goes through `TASK_STATE_READY`, bypassing
any further fast-forward, whatever `cpu->elapsedTimeUs` the cancellation
left behind is exactly what `RUNTIME()` reports. Reverting the fix
locally and re-running that exact fixture confirmed the bug directly:
`RUNTIME()` read `10.0` (the overshot wake time) without the fix, `3.0`
(the correct `UNTIL` instant) with it. Fixed by adding a `DORMANT`
task's own `untilTimeUs` as an additional fast-forward candidate,
alongside `wakeDeadlineUs`.

**Independently confirmed on `yaHALMAT2`'s own side too**, over the
direct cross-session channel: cross-checking the same fixture against
their binary first showed a *different* result (2 firings, `RUNTIME()`≈
10.0, i.e. the same overshoot) — rather than assume either side was
right, both of us re-verified against `USA003087` §23.5's own text
directly. They confirmed my reading was correct and reproduced the
identical root cause on their own side (their own fast-forward/advance-
to-next-wake also never treated a `DORMANT` cyclic task's `UNTIL` time
as a candidate), and are fixing theirs to match. A genuine case of two
independent implementations converging on the same real bug from the
same underlying design gap, caught by cross-checking rather than either
side's own test suite alone.

Four new fixtures — `repeatbare.hal`, `repeatafter.hal`,
`repeateveryuntil.hal`, `repeataftercancel.hal` (the last one is the
direct regression test for the fast-forward-overshoot bug) — exercised
by `test_scheduler.sh` under both `--pacing` modes; two new deterministic
`test_schedule.c` scenarios (`test_repeat_bare_and_after_cadence`,
`test_repeat_until_time_cancels_at_close_and_between_cycles`).
`hal-runtime-features.db` rows for bare `REPEAT`, `REPEAT AFTER`, and
`REPEAT ... UNTIL time` updated from `not_implemented` to
`implemented`/`tested_dedicated`.

### 7.17 `SCHEDULE ... REPEAT ... WHILE / UNTIL event-expr` — done, closes out the SCHEDULE...REPEAT family, one real bug found (reusing a field with the wrong reset semantics), no working `yaHALMAT2` oracle

Self-selected from the survey, closing out row 13 — the last remaining
`Real-Time: SCHEDULE` gap after §7.16's bare/AFTER/numeric-UNTIL work
(`REPEAT ... WHILE/UNTIL exp`, `exp` an *event* expression, `USA003087`
§24.5 — distinct from the numeric UNTIL-time clause just implemented).
The two genuinely out-of-scope rows left (`RANDOM()`/`RANDOMG()`, needing
a C-level PRNG; Program Processes, needing multi-image loading) stay
`not_implemented` for the same confirmed reasons as before.

**FLAGS bits traced empirically** against three real compiled programs
(`REPEAT EVERY 1.0 WHILE EV1`, `REPEAT EVERY 1.0 UNTIL EV1`, and a plain
`SET`/`RESET` control to confirm the base case): bit 9 (`0x0200`) marks
an event-expression cancellation clause present, composing with bit 8
(`0x0100`, the same bit the numeric-UNTIL clause uses on its own) to
distinguish `WHILE` (`0x0200` alone) from `UNTIL` (`0x0200|0x0100`) —
the numeric and event forms are mutually exclusive in the real grammar
(the compiler never sets both). The descriptor pointer occupies `ea+4`,
the identical parameter-block slot the numeric `UNTIL` clause's own
FPR4-5 value would otherwise use — confirmed by hex-dumping a linked
`.fcm` directly (not just tracing SVC summaries) that it resolves to the
exact same `[opcodeWord, reserved, PDE...]` descriptor format `WAIT
FOR`/`SCHEDULE ... ON` already use, letting this reuse
`sched_event_expr_true` verbatim with zero new descriptor-parsing code.

**Semantics, matching `§24.5`'s own two-part text precisely:** `WHILE`
cycles while `exp` stays `TRUE`, cancelling once it goes `FALSE` —
checked *even before this task's very first dispatch* ("if the value of
`exp` becomes FALSE before the process is initiated, it is merely
removed... without ever executing"), confirmed via a real fixture
(`repeatwhilefalse.hal`, `EV1` forced `FALSE` before the `SCHEDULE`
itself) that produces zero `TICK` output at all. `UNTIL` cycles until
`exp` becomes `TRUE`, but explicitly guarantees "at least one cycle
shall be executed" regardless of `exp`'s initial value — the one place
`WHILE` and event-`UNTIL` genuinely differ in mechanism, not just
polarity. Both are otherwise checked exactly like the numeric-`UNTIL`
clause from §7.16: at CLOSE (`sched_handle_task_close`) and immediately
during the intercycle `DORMANT` gap (`sched_dispatch`'s own pre-pass),
reusing the identical `sched_cancel_idx_and_dependents` machinery.

**A real bug, caught building the `UNTIL` fixture, not by inspection:**
the first draft gated event-`UNTIL`'s own "at least one cycle" guarantee
on `ScheduledTask.hasRun` — but `hasRun` is reset back to `false` by
*every* re-arm, not just the first (it exists to tell `sched_dispatch`
whether the *next* firing needs a fresh dispatch to the entry point or a
context restore, a per-firing question, not a "has this task ever run at
all" one). This meant the between-cycles check couldn't distinguish
"never run" from "between cycle 2 and 3": an event going `TRUE` in the
gap between the 2nd and 3rd cycles was wrongly treated as still-before-
the-guaranteed-first-cycle, and a 3rd cycle ran that should have been
cancelled. Caught directly: `repeatuntilevent.hal`'s own primal resets
`EV1` `FALSE`, `SCHEDULE`s `REPEAT EVERY 1.0 UNTIL EV1`, waits 1.5s
(letting 2 cycles complete), sets `EV1` `TRUE`, waits 5 more seconds —
expected 2 `TICK`s (cycle 1 guaranteed, cycle 2 still before the flip,
cycle 3 cancelled), got 3 with the `hasRun`-gated draft. Fixed with a
dedicated `completedFirstCycle` field, set once at this task's first
`CLOSE` and never reset afterward — confirmed both directions: reverting
locally and re-running the same fixture reproduced the extra cycle, and
the same regression is now pinned as a deterministic
`test_schedule.c` scenario (`test_repeat_while_until_event_cancellation`),
verified to actually fail against the reverted code before being fixed
again (a stale incremental `make` build masked the failure on the first
attempt — a clean rebuild was needed to see it, worth remembering for
next time this kind of quick revert-and-check comes up).

**No working `yaHALMAT2` oracle for this specific variant**, unlike
§7.16's numeric-`UNTIL` work: cross-checked all three fixtures against
their binary and got results inconsistent with `§24.5`'s own text (the
already-`FALSE`-before-scheduling `WHILE` case ran 6 cycles instead of
zero; the mid-run `WHILE`-goes-`FALSE` case ran 8 instead of 3) —
confirmed (informationally, not urgently) over the cross-session channel
that this variant isn't wired up on their side yet, falling back to
treating the clause as absent (plain `REPEAT EVERY`). Verified instead
by the primary source directly plus internal consistency across the
three fixtures' own predicted-vs-actual cycle counts, the same fallback
methodology already established for `WAIT FOR`/`SCHEDULE ... ON` in
§7.8 when no working oracle existed there either.

Three new fixtures — `repeatwhile.hal`, `repeatuntilevent.hal` (the
direct regression fixture for the `hasRun`/`completedFirstCycle` bug),
`repeatwhilefalse.hal` — exercised by `test_scheduler.sh` under both
`--pacing` modes; one new deterministic `test_schedule.c` scenario
(`test_repeat_while_until_event_cancellation`, covering both `WHILE`'s
pre-first-cycle removal and `UNTIL`'s guaranteed-first-cycle/between-
cycles-cancellation). `hal-runtime-features.db` row 13 updated from
`not_implemented` to `implemented`/`tested_dedicated`, closing out the
entire `SCHEDULE ... REPEAT` family (§7.7 `AT`/`IN`, item #6 `EVERY`,
§7.16 bare/`AFTER`/numeric-`UNTIL`, this section's `WHILE`/event-`UNTIL`)
except the two confirmed-out-of-scope rows noted above.

### 7.18 `OFF ERROR`, per-process error environments, dynamic scoping — all three already correctly implemented with zero new code, two real `yaHALMAT2` bugs found

Self-selected from the survey's three `unresolved` `Error Handling` rows
(55, 57, 58 — genuinely unassessed, not known-missing, unlike this
section's other work): `OFF ERROR` (`USA003087` §25.2), per-process
error environments, and dynamic (call-depth) scoping of `ON ERROR`
modifications (§25.1). Row 57's own old notes had specifically flagged
per-process isolation as worth re-checking "now that TASK/SCHEDULE/WAIT
is real" — this is that check.

**All three turn out to already be correctly implemented, for free, by
the existing `ON ERROR` dispatch mechanism's own design** — reading
`try_on_error_dispatch()` (`halucp.c`) closely (not just grepping for
`OFF ERROR`, which finds nothing at all) shows it never consults any
kind of global or persistent "which handlers are currently active"
table. Instead, at the exact moment a `SEND ERROR` fires, it reads the
*live* `R0` register (the AP-101S stack-area/frame pointer) and scans
the compiler-emitted `FIXV`/handler slots physically present in the
erroring routine's own compiled stack frame, walking up through saved
caller `R0` values (at `SA+2`) as needed. This has three consequences,
none requiring a single line of new `yaGPC2` code:

- **`OFF ERROR`** is a pure compile-time bookkeeping construct: `HALSFC`
  itself simply stops emitting a `FIXV` registration for code textually
  after an `OFF ERROR` statement, so there is nothing live left for the
  scan to find there. Confirmed via a real compiled program (`ON
  ERROR$(4:5) GO TO CAUGHT; ...SQRT(neg)...; OFF ERROR$(4:5);
  ...SQRT(neg)... `): the first domain error jumps to `CAUGHT`, the
  second falls straight through with the default fixup value — byte-
  identical to `yaHALMAT2`'s own output for the same program.
- **Per-process isolation** falls out of `R0` being part of the full
  register bank (`R0`-`R7`) `schedule.c`'s `sched_save_context`/
  `sched_restore_context` already save and restore on every scheduler
  context switch — a `TASK`'s own `ON ERROR` environment is
  automatically isolated from every other task's with zero extra
  bookkeeping, since each task's own `R0` (and hence its own compiled
  stack frame and `FIXV` slots) is preserved independently.
- **Dynamic scoping** falls out of the scan being over the *live* call
  chain at the exact instant of the error, not a static table: once a
  `PROCEDURE`/`FUNCTION` returns, its own frame's `FIXV` slots simply
  fall out of reach of that walk (the caller's own `R0` is restored to
  its own frame by the callee's epilogue) — nothing needs to be
  explicitly "removed."

**Two real `yaHALMAT2` bugs found confirming both of the latter two
empirically**, not just by code inspection — cross-checking is what
this session repeatedly relies on, and here it caught something
`yaGPC2`'s own correctness couldn't be validated *against* `yaHALMAT2`
for, only *contrasted* with it:
- **Cross-task leak**: a `TASK` with its own `ON ERROR$(4:5) GO TO
  TASKCAUGHT;` catches its own `SQRT` domain error and closes; the
  primal (no `ON ERROR` of its own) later triggers the identical error.
  `yaGPC2`: falls through correctly to the default fixup (`PRIMAL
  UNCAUGHT 2.0`). `yaHALMAT2`: incorrectly re-triggers the closed
  task's own `GO TO` a second time.
- **Stale-after-return leak**: a `FUNCTION P` with its own `ON
  ERROR$(4:5) GO TO PCAUGHT;` catches its own domain error and
  `RETURN`s; the calling main line later triggers the identical error
  (`P` has already returned, no `ON ERROR` of its own in force at that
  point). `yaGPC2`: falls through correctly. `yaHALMAT2`: incorrectly
  re-triggers `P`'s own (already-returned) `GO TO` again.

Reported both to `yaHALMAT2` over the direct cross-session channel; they
confirmed the same root cause explains both (their own `ON ERROR`
dispatch almost certainly keys off "last handler installed wins" global
state rather than the live call chain, so a handler is never unwound
when its installing block returns) — the same architectural family as
the shared-interpreter-call-stack `REENTRANT` concern raised earlier
this session, now shown to affect `ON ERROR` scoping too, not just
local-variable storage. Queued on their side pending their own user's
prioritization; not blocking here, since `yaHALMAT2` was never a valid
oracle for either of these two fixtures in the first place (its own bug
*is* the thing each fixture is checking for) — `yaGPC2`'s own
correctness rests on the `R0`/`SA`-walk code-level reasoning above, not
on matching `yaHALMAT2`'s (wrong, in these two cases) output.

Three new fixtures — `offerror.hal`, `errorpertask.hal`,
`errordynscope.hal` — exercised by `test_scheduler.sh` under both
`--pacing` modes via a new `run_case_with_stderr` helper (these three
deliberately trigger a real `SEND ERROR`, so unlike every other case in
this file they have real, expected stderr content — `hal_report_error()`
reports every `SEND ERROR` unconditionally, not gated on `--verbose` the
way `hal_log()`'s own diagnostic messages are — diffed against its own
golden rather than required empty). `hal-runtime-features.db` rows 55,
57, 58 updated from `unresolved` to `implemented`/`tested_dedicated`.

### 7.19 `AUTOMATIC` local data in `REENTRANT` blocks — already correctly implemented via the CPU alone, a real, live `yaHALMAT2` bug confirmed (not just theoretical)

Self-selected from the survey's last easily-tractable `unresolved` row
(136): `USA003087` §27.3's `AUTOMATIC` keyword, which gives each
concurrent invocation of a `REENTRANT` procedure/function its own
private copy of a local data item (as opposed to the default `STATIC`
behavior, one shared copy for all invocations). The old notes had
explicitly flagged the open question: is this ordinary compiled stack-
frame code, or a real RTE-provided allocation service `yaGPC2` would
need to implement?

**Resolved empirically as the former** — `AUTOMATIC`'s own stack-
relative addressing is entirely `HALSFC`'s own compile-time concern;
`yaGPC2` needs nothing beyond what it already unconditionally provides
every `TASK`/`PROGRAM` block: a genuinely independent linker-generated
stack region (visible in every real fixture's own section map all
session, confirmed safe for `REENTRANT` specifically back in the
`DATE()`/`CLOCKTIME()` work's own reentrancy digression). Confirmed
directly with a real compiled program: a `REENTRANT PROCEDURE P(X)
ASSIGN(Y)` with `DECLARE SCALAR AUTOMATIC, LOCAL;` sets `LOCAL = X`,
`WAIT`s 1.0s (so a second, later invocation genuinely overlaps the
first, not just textually "reentrant" but actually concurrently live),
then returns `LOCAL`. Two tasks call it with different arguments
(`10.0`/`20.0`, 0.5s apart) — `yaGPC2` returns the correct value to
each (`10.0`/`20.0`), zero cross-contamination, zero new code.

**A real, live `yaHALMAT2` bug confirmed via this same fixture** — not
just their own earlier-flagged theoretical concern
(`RELAY-FROM-YAHALMAT2-Reentrancy.txt`, raised mid-session when they
asked about `yaGPC2`'s own stack architecture): their side returns
`20.0` for *both* tasks, meaning the first task's own `AUTOMATIC` local
got clobbered by the second task's concurrent invocation, exactly the
shared-interpreter-call-stack risk they'd already reasoned through but
not yet demonstrated failing. They've since confirmed (cross-session)
this is the same underlying root cause as the `ON ERROR`-scoping bug
from §7.18 — a single global call/handler context rather than one
scoped per task/call-frame — and are treating a foundational per-task-
context fix as the one change that would resolve both.

One new fixture, `reentrantautomatic.hal`, exercised by `test_scheduler.sh`
under both `--pacing` modes (plain `run_case`, no `SEND ERROR` involved
here unlike §7.18's fixtures). `hal-runtime-features.db` row 136 updated
from `unresolved` to `implemented_via_cpu`/`tested_dedicated`.

### 7.20 `RANDOM()`/`RANDOMG()` — already fully implemented and correct, a genuine error in this session's own earlier research corrected

Requested explicitly by the user (used in two real "Programming in
HAL/S" sample programs, `071-DARTBOARD_APPROXIMATION.hal` and
`134-ROLL.hal`), overriding this session's own earlier "out of scope"
categorization (§7.13/item #12: "needs a C-level PRNG implementation...
a different subsystem's work"). That categorization turns out to have
been a genuine research error, not a real scope boundary — caught only
because the user asked for the concrete feature rather than accepting
the earlier assessment.

**The error, precisely:** item #12's own research correctly established
that `RANDOM`/`RANDOMG` involve no `SVC` at all (confirmed via
`IBM-76-SS-1110` 4.2.4), unlike every other built-in this whole session
substituted for. It then concluded this meant "needs a C-level PRNG
implementation" — but a missing `SVC` is exactly the signature of a
*plain math-library call* (the same category as `SIN`/`COS`/`SQRT`),
not a runtime-service gap: no `SVC` means no OS/RTE involvement is
expected at all, the call is pure CPU-executed library code. The
correct conclusion was the opposite of what got written down. Worse,
`problems.md` §2.6 (this same file, written 2026-07-28, well before
item #12's own 2026-08-17 recheck) had *already* established the exact
algorithm and confirmed it deterministic for `gpc`/`yaGPC` — apparently
never cross-referenced.

**Directly tested rather than re-reasoned about:** compiled a minimal
`X = RANDOM;` program via real `HALSFC`/`lnk101` and confirmed `RANDOM`
`RANDG` (the real `RUNASM/RANDOM.obj` library routine) link successfully
and execute cleanly under `yaGPC2` — no unhandled-`SVC` trap, a
plausible `[0,1)` value, byte-identical across repeated runs (confirming
§2.6's own "fixed compiled-in `SEED=1435`, no wall-clock entropy"
finding holds), and byte-identical to `yaHALMAT2`'s own output (which
independently adopted the same reference algorithm per §2.6's own
handoff). Extended to a 5-call mixed `RANDOM`/`RANDOMG` sequence — still
byte-identical both tools. Then ran both real "Programming in HAL/S"
sample programs end-to-end: `071-DARTBOARD_APPROXIMATION.hal` (a
10,000-iteration Monte Carlo `pi` estimate, ~400K CPU steps, computing
with drawn values — `X**2+Y**2` — before drawing again, exactly the
case §2.6's own "F1-chaining disrupted by other float ops" caveat
flagged as a *`yaHALMAT2`-only* limitation, not `yaGPC2`'s, since
`yaGPC2` "gets this right for free" via real register-level execution)
gives `3.1507998` (a plausible `pi` estimate), byte-identical between
both tools; `134-ROLL.hal` (a dice-roll simulator, `5 RANDOM + 1`
truncated to `INTEGER`) gives an identical roll sequence on both.

Three new fixtures — `randomsequence.hal` (a minimal, fast, isolated
5-call sequence), plus `071-DARTBOARD_APPROXIMATION.hal`/`134-ROLL.hal`
themselves, referenced directly from the `Source Code/Programming in
HAL-S/` tree rather than copied (matching `hello.fcm`'s own precedent)
— exercised by a new `test/test_random.sh` (no `TASK`/`SCHEDULE`
involved in any of these, so no `--pacing`/`--time-scale` matrix needed,
unlike `test_scheduler.sh`), wired into `make test`.
`hal-runtime-features.db` rows 98/99 updated from `not_implemented` to
`implemented_via_cpu`/`tested_dedicated`.

### 7.21 The survey's last two `unresolved` rows — resolved by reading the real historical RUNASM source directly; all `implemented_via_cpu`, zero new code, one real `yaHALMAT2` gap found

Closes out `hal-runtime-features.db`'s last two `unresolved` rows (131,
133): "Compool/remote-access subroutines (CAS/CASP/CASR/CPAS/CPR
families)" and "Unlabeled CSECT families (VR*, MSTR, OUTER1, CSTRUC,
CSLD/CSST/CSHAPQ/QSHAPQ)," both from `USA003090` Appendix D's own
runtime-library name table. Both rows' own old notes said the same
thing: "purpose inferred from naming convention only" / "Appendix D
itself gives no prose description... would need Language Spec
cross-reference." That premise was avoidable — the real historical
`RUNASM/*.asm` source for every one of these routines is available
locally (`/home/rburkey/donschmidt/nsts-sdl-dps/.../RUNASM/`) and each
file self-documents its own purpose in a `TITLE` line, no
cross-referencing needed at all.

**Row 131's own premise was wrong**: `CAS`/`CASP`/`CASR`/`CPAS`/`CPR`
are not a Compool/REMOTE-access family. `CPR.asm`'s own `TITLE` reads
"CHARACTER COMPARE"; `CPAS.asm` reads "CHARACTER ASSIGN, PARTITIONED
OUTPUT" — an ordinary `CHARACTER`-type comparison/assignment family.
`CAS` itself is simply Appendix D's own alias name for `CASV`
("CHARACTER ASSIGN," already confirmed and in daily use throughout this
entire session's own `WRITE`-with-string-literal support, long before
this row was ever written — its own real purpose was hiding in plain
sight, already identified once, just never connected back to this row).

**Row 133's genuine REMOTE-data-movement family** turns out to be `VR*`
(VECTOR) + `MSTR` (STRUCTURE), each self-titled ("VR1SN--SCALAR TO
REMOTE VECTOR MOVE, SP," "MSTR- STRUCTURE MOVE,REMOTE"), and confirmed
against `USA003090` §8.2's own `%COPY` documentation as the real
implementation `%COPY(dest,source,count)` compiles to when `dest` is
`REMOTE`. `OUTER1` is simply Appendix D's own alias of `IOINIT`
(already confirmed, used by every fixture this whole session). `CSTRUC`
is "STRUCTURE COMPARE"; `CSLD` is "CHARACTER SUBBIT LOAD AND STORE
ROUTINES" (with `CSST` as one of its own internal linked labels,
resolving that mystery member too); `CSHAPQ` is "ARRAYED CHARACTER TO
INTEGER, SCALAR SHAPING FUNCTION" (an array-conversion routine, not a
Compool/REMOTE mechanism despite the superficial naming worry).

**All confirmed `implemented_via_cpu`** — ordinary CPU-executed RTL
calls, no `SVC` involved, the exact same category as every math builtin
and `RANDOM()`/`RANDOMG()` above, needing nothing from `yaGPC2` beyond a
correct CPU emulator. Verified directly, not just by reading titles:
- `charactercompare.hal` (`IF C1 = C2 THEN`) links and correctly
  executes `CPR`, byte-identical to `yaHALMAT2`.
- `remotevectorcopy.hal` (`RV = V;`, `RV` declared `REMOTE`) links and
  correctly executes `VR1SN`, byte-identical to `yaHALMAT2`.
- `structurecompare.hal` (`IF A = B THEN` on two `STRUCTURE`s) links
  and correctly executes `CSTRUC`, byte-identical to `yaHALMAT2`.
- `charactersubbit.hal` (`SUBBIT(C1) = BIN'...'; B1 = SUBBIT(C1);`)
  links and correctly executes `CSLD`, round-tripping the exact bit
  pattern of the literal — hand-verified, not diffed against
  `yaHALMAT2`, since **a real gap was found on their side**: their own
  binary explicitly errors ("`SUBBIT assignment: target type has no
  confirmed raw-bit-pattern mapping (only INTEGER/BIT/SINGLE-precision
  SCALAR are implemented)`") rather than executing it at all — reported
  over the cross-session channel, not blocking here.
- `CSHAPQ` alone stays undemonstrated by a dedicated fixture — its own
  `WIDTH`-in-halfwords stride parameter suggests it's only reached for
  non-densely-packed arrayed `CHARACTER`-to-numeric conversions, and a
  quick real attempt (a plain `ARRAY(3) CHARACTER(4)` to `ARRAY(3)
  INTEGER` conversion) didn't happen to trigger it (no library call
  linked at all — the compiler resolved it some simpler way for that
  specific case). Left as "confirmed same category by source reading,
  not independently fixture-verified" rather than claiming false
  certainty.

Four new fixtures — `charactercompare.hal`, `remotevectorcopy.hal`,
`structurecompare.hal`, `charactersubbit.hal` — exercised by a new
`test/test_rtl.sh`, wired into `make test`. `hal-runtime-features.db`
rows 131/133 updated from `unresolved` to `implemented_via_cpu`/
`tested_dedicated` — **zero `unresolved` rows remain in the survey.**

### 7.22 Program Processes (`SCHEDULE` targeting a separately-compiled `PROGRAM`) — implemented, correcting a scope assessment that was simply wrong; the survey's last real gap closed

Requested by the user directly ("continue until all bugs and in-scope
features are addressed"), reopening row 14 — previously marked
`not_implemented` under an explicit "needs multi-image loading support
at the `AGEHarness`/`main.c` level... infrastructure this whole
scheduler-substitution pass never touches" assessment (§7.13). That
assessment was wrong, in the same family as the `RANDOM()`/`RANDOMG()`
and Appendix D research errors earlier in this section: it assumed
"separately compiled" meant "separately loaded at runtime," when
`USA003087` §23.1's own footnote 33 says plainly the object modules
"have to be link-edited to produce a single executable load module" —
an ordinary link-time concern, not a runtime one.

**Confirmed directly, not just re-read:** built a real two-unit
example — `PRIMARY2: PROGRAM;` containing `SECOND: EXTERNAL PROGRAM;`
(a program template) and a genuine `SECOND: PROGRAM;` compiled
separately — and found `lnk101` already merges both `.obj` files into
one `.fcm` on request (`lnk101 primary.obj second.obj -o combined.fcm`)
exactly the way it already merges every RTL library object this whole
codebase depends on; no new linker capability was needed at all.

**The SVC protocol traced from the merged image turned out
byte-identical to the already-implemented `TASK` case**, with exactly
one difference: `FLAGS` bit `0x0001` (the "TASK" marker, previously
assumed mandatory on every recognized `SCHEDULE` signature) is *clear*
for a Program Process target instead of set. The target's own PDE lives
in *its own* compiled unit's own `#E<name>` data area — confirmed via a
direct `.fcm` hex-dump (`#ESECOND`, sized identically to every `TASK`
PDE slot already established this session) — rather than the caller's,
since a Program Process, unlike a `TASK`, is a real independently-
linkable unit any caller could `SCHEDULE`, so it can't reuse the
caller's own private data area the way a nested `TASK` block does. Its
own entry-point far-pointer decodes via the *exact same*
`decode_pde_far_pointer()` already used for every `TASK` PDE, with no
changes. **The entire fix was a single FLAGS-bit gate relaxation in
`halucp.c`** — dropping the `hasTask &&` requirement from the main
`SCHEDULE` branch's own condition — **zero changes to `schedule.c` at
all**, since `sched_handle_schedule_svc()` never cared whether a PDE
belonged to a `TASK` or a `PROGRAM` in the first place; it only ever
decoded and dispatched an address.

**Verified against the full `USA003087` §23.3 checklist**, not just the
bare case, using two real compiled fixtures: `SCHEDULE` (bare and
`DEPENDENT`), `WAIT FOR DEPENDENT`, `TERMINATE`, `UPDATE PRIORITY`,
`REPEAT EVERY`, and the target's own name used as a `Boolean` both
before and after scheduling it — all correct, all needing zero
additional code beyond the one gate relaxation, since `TERMINATE`/
`UPDATE PRIORITY`/process-name-as-`Boolean` already operated purely on
PDE addresses with no `TASK`-specific assumptions anywhere in their own
code paths.

**No working `yaHALMAT2` oracle exists for this feature either** —
attempted a cross-check via their own `@list`/`--entry` multi-unit
mechanism and got `"only COMPOOL/FUNCTION/PROCEDURE auxiliary units are
supported (not the PROGRAM entry point)"`: a real, symmetric gap on
their side, not merely a historical one on this side. Verified instead
via direct SVC/PDE tracing against the identical, already-extensively-
validated mechanism `TASK`-based `SCHEDULE` already uses.

Two new fixtures — `programprocess.hal`/`programprocess_second.hal` and
`programprocessrepeat.hal`/`programprocessrepeat_second.hal` — built via
a new `build_multi()` helper in `build_hal_fixtures.sh` (two independent
`HALSFC` compiles, one `lnk101` link taking both `.obj` files at once),
exercised by `test_scheduler.sh` under both `--pacing` modes.
`hal-runtime-features.db` row 14 updated from `not_implemented` to
`implemented`/`tested_dedicated`.

**With this, the entire 143-row survey is closed.** Every row is either
implemented and tested, or has a genuine, documented, unfixable-from-
`yaGPC2`'s-side blocker — re-confirmed once more here, independently,
rather than taken on faith from earlier passes: `SCHEDULE`'s cycle-
overrun runtime error (row 11) stays `not_applicable` (re-searched the
confidential FCOS source tree directly for any cycle/overrun/late-
scheduling error handling; found none, and `USA003090` §8.3's own
"This section was deleted by CR13613" remains the strongest possible
confirmation real FCOS never implemented this promised-but-withdrawn
language feature); `UPDATE PRIORITY`'s bare/self form (row 27) stays
`partial` (re-tried with the simplest possible minimal trigger — a
`TASK` whose only statement is `UPDATE PRIORITY TO 99;` — and
reproduced the identical real `HALSFC` PASS2 compiler defect,
`BS122 INDIRECT STACK USAGE CONFLICT`, confirming it's not an artifact
of any particular surrounding code shape).

---

## 8. Real flight software: GPCIPL, the peripheral bus, and the OI340600/OI340700 corpora (2026-08-17 → 2026-08-31)

Sections 1–7 were found by running *test programs* — `yaHALMAT2`'s suite, the
worked examples, hand-cut fixtures. This section is what running **real Shuttle
flight software against real peripherals** turned up, which is a different
instrument and finds different things. The single most important methodological
result is negative and is stated first:

> **Comparing two emulators against each other cannot find a bug in their shared
> input.** yaGPC2 and `gpc` sat in the same infinite loop, at the same address,
> with *identical iteration counts*, for days — because both were faithfully
> executing the same mis-assembled image. Agreement between independent
> implementations is evidence about the implementations, not about the program
> they are both running.

### 8.1 Real peripheral I/O: the `--bce-network` bridge

`--bce-network` installs a `GpcServicerFn` that puts BCE/MIA bus traffic on
real UDP multicast, matching `nsts-sim-gpc`'s own `com/bus.civet` wire format,
so yaGPC2 drives Don Schmidt's real MMU and MEDS processes. Two new files
(`src/bcenet_framer.c`, layer 2, word-at-a-time buffering; `src/bcenet_transport.c`,
layer 3, one socket per bus) and **no change to `yaGpcIntegration.h` or to either
emulator's engine** — the extension point already existed.

Wire-format bugs found, each by testing against the *real* peer rather than a
stub of our own:

- **`FRAMER_IS_SHUTTLE_BUS` was hardcoded true**, adding an IUA+reserved header
  the peer never strips, shifting every word by one. `nsts-sim-gpc` builds every
  bus with `new Bus(name, busConfig[name])` — two arguments, so `isShuttleBus`
  defaults false. Every earlier "verified against the real `Bus` class" check
  had been made against a listener *we* constructed with the same wrong
  assumption. **A test peer you configure yourself is not an independent check.**
- **Buffers hardcoded to 64 words**, silently truncating a real display frame
  buffer (542 words). Both raised to 1024.
- **`GPC_SVC_XMIT_CMD` never sent the command word at all** — it recorded the
  IUA, flushed the burst, and reported success. Every command the machine
  generated was dropped. It goes out as its own two-word message with the
  24-bit command left-justified, as the reference's MIA does.
- **No self-echo filter.** Multicast loopback returns our own datagrams, and on
  a shuttle bus they carry the very IUA the receive filter accepts. Fixed first
  by byte-matching (as the reference does) and then properly: **that cannot work
  on the display bus**, where a DEU answers a poll with one halfword and a fill
  puts 511 mostly-identical halfwords out, so a real reply is byte-identical to
  something we just sent. 13 of 78 poll replies survived. Now attributed by
  *identity* — a separate transmit socket on an ephemeral port — 176 of 176 peer
  datagrams kept, 144 of 144 of ours dropped, error-terminations 26 → 0.
- **Batching words into one datagram was wrong** at the protocol level and was
  reverted; the reference sends each word as its own message, which is what a
  peripheral parses.

Two upstream `nsts-sim-gpc` renderer bugs were found live via Chrome DevTools
Protocol and fixed there with the user's go-ahead: an inclusive-vs-exclusive
range in `setBGDFB()` reading one word out of bounds, and `decodeFCW()` crashing
the whole render on the first unrecognised halfword. Its `@FCWS` table
implements only single-halfword opcodes, so a whole category (POSITION variants,
LINE, VPARM, RTC, TEST, DASH ON) goes unrendered — genuinely `nsts-sim-gpc`'s
own unfinished territory, not fixable from here.

**Real-time pacing** (`--real-time`/`--rt-factor`/`--rt-idle-timeout`,
`src/rtpacer.c`) is *not* the same thing as `--time-scale`, and the distinction
matters: `--time-scale` sleeps off a lead a program builds by running fast, and
never advances simulated time on its own. A machine in the AP-101S wait state
needs the opposite — there are no instructions to pace, and what ends the wait
is an interrupt. Free-running the wait advances simulated time as fast as the
host manages, so a bus reply a millisecond away in wall-clock terms arrives to a
transaction that timed out "hours" ago in simulated time. Host stalls are
**re-based, not repaid**: a debugger halt loses the peripheral's datagrams
outright (UDP does not retransmit), so replaying the lost wall time as simulated
time would only run every outstanding transaction past its timeout. Note that
under `--real-time` the instruction stream is **not reproducible**, so exact
trace comparison against `gpc` is only meaningful without it.

### 8.2 Emulator defects found by running GPCIPL

Trace agreement against `gpc` on the real `IPL.fcm` went
**20,917 → 35,036 → 43,311 → 299,984/300,000 → all 3,987,845 instructions with
zero phase slips.** Every fix below was confirmed against the POO
(`ASM101S/AP-101S-instruction-set.txt`) and/or `nsts-sim-gpc` before changing
anything. Roughly grouped:

*CPU.* `ME`/`MER` dropped the low half of the double-length product;
`MED`/`MEDR` used the AP-101 C/M multiply instead of the AP-101S's own, and that
routine was itself 1 ulp high on postnormalising products; Figure 2-20 note `#`
(machine check / store protect force the old PSW's CC to 10 and clear
carry+overflow) was missing; the fixed-point overflow *indicator* was never set
and never re-tested after `SPM`/`LPS`; program-check codes were wrong for
fixed-point overflow (0004, was 0002) and address specification (0002, was 0003
— not a program check at all); External 0/1 never wrote their own interrupt
code; TEST INTERRUPTS set the registers but raised none of the four levels; POO
14.1 index alignment (`LM`/`STM`/`LPS` take a *halfword* index despite fullword
operands) was unmodelled and `SSM`/`TS` were wrongly marked fullword; auto
storage modification used the post-incremented address for its own access;
`LDM`/`STDM` read the four DSEs as nibbles of the high halfword rather than the
low nibble of each byte; only 4 DSEs were kept where the machine has 8, so `LXA`
on R4–R7 aliased onto R0–R3; `STXA`/`STXAR` were empty stubs.

*Store protection and the IU.* Every instruction store now goes through
`cpu_store_hw`/`cpu_store_fw`, which test **both** halfwords' protect bits before
writing either and honour `storeProtectOverride` (left on by an `ISPB` with an
illegal M1 — previously dismissed as a no-op because nothing read it). `ISPB`
masked its EA with `0xfffe` to drop the low bit, but that EA is already expanded
to 19 bits, so the mask threw the **sector** away and protected the same offset
in sector 0. IOP writes to main storage bypassed store protect entirely, so the
DMA store-protect violation the self test deliberately provokes could never
occur. The IU store-conflict model (POO 15/16.8) was absent: with DIAG 7100/7101
off, a store into the IC−1..IC+23 window must keep the pre-store halfword in a
shadow the fetch prefers — **GPCIPL's self test stores an instruction over itself
and requires the stale one to run.**

*DIAG.* The whole family took its command from the halfword *at* the effective
address; **the command is the effective address**. Every DIAG had been decoding
whatever happened to be in storage.

*Interrupts and timers.* AGE — the twelfth interrupt, External 1's vector and
mask bit with its own latch, code 0006, lowest priority — was missing, and the
interrupt-priority self test requires it eighth. Masked machine check and
instruction monitor no longer stay pending (POO 2.5.2.3); only the system class
waits for an unmask. `ICR` counter reads come back two counts high; the PSA half
of a counter write goes past store protect and resets the clock latch. An
interval timer's **masked borrow is owed, not forgotten** — but a timeout must
still wrap through, or the boot dies in a masked wait state (`62f23ad21`; this is
GPCIPL ITEM 18's error 206, "CLOCK2 CANNOT BE SET TO ZEROS").

*IOP.* Ten of the twelve long-format MSC instructions advanced the PC one
halfword too few, so each was followed by executing its own operand word.
MSC `@BC`/`@BXC` displacement is relative to the *updated* PC. `@INT` never
loaded IOP Interrupt Register C. LOAD MSC BUSY set the STAT4 bit but not the
copy the MSC reads back with `@LMS`. `@STP`/`#STP` self tests were stubs, and
the MSC leaves its signature in processor 25's local store — which did not exist,
the page array being one short. **`@RBI` names its processor as the instruction's
BCE field plus the low five bits of the accumulator**; taking the field alone sent
every reset to BCE 0, so a BCE's indicator once set by `#SIB` was never cleared,
`@RAI` was satisfied immediately, and the MSC built block programs flat out until
the buffer pointer overflowed out of the `#LBR` operand field into its opcode.
A bus **receive does not complete in one slice**: the reference holds the BCE at
the instruction until the count is satisfied or it times out, where ours queued
the words as DMA and advanced unconditionally. `#MIN`/`#MIN@` reissued their
companion bus command on every execution, and since a waiting receive re-fetches
its own instruction each slice, one transaction put its command on the bus
thousands of times — 76,735 polls in 60 s against the reference's 176.

*Decode.* Instruction decode ranked candidate patterns by mask **value** rather
than by how many bits they fix, so `STXA` with R1=010 decoded as `SHW`. The
pattern parser's `getMask` replaced only lowercase field letters, leaving an
uppercase one for `parseInt` to truncate on — faithful to an old reference, and
it wrecked the mask of every pattern with an uppercase field in its first
halfword.

### 8.3 The fixture suites were blind

Two generator defects meant whole suites had been asserting nothing:

- `gen_cpu_ea_fixtures.cjs` never set `indexWidth`, so the oracle evaluated
  `x << (undefined - 1)` — **a shift by NaN, i.e. by 0** — and every indexed-EA
  fixture silently asserted halfword alignment.
- `gen_iop_instr_exec_fixtures.cjs` still used the reference's old `regHalt`
  name (now `regProcEnable`) and could not run at all.
- `iop_set_nia` needed one 18-bit mask before the IOP suites tested anything.

Once they could see, every remaining failure was triaged rather than deferred.
The EA suite's 897 failures were **two causes in the RS extended/indexed branch
of `cpu_g_ea`**, the first being that the base register's DSE was never applied
(the reference computes it once at the top and passes it to every `g_EXPAND`
inside). The shift family's 189 failures were **one defect**: the four double
shifts took their partner as plain R1+1 where POO 6.6 says `(R1+1) mod 8`.
`BCTR` was an evaluation-order bug, not the mod-8 pair issue. Final state, with
nothing anywhere unexplained:

| Suite | Result | Remainder |
| --- | --- | --- |
| EA | 20,447 / 20,447 | — |
| CPU exec | 111,192 / 111,358 | 166 = 136 stale CVFX + 30 BCT (reference's) |
| MSC | 145,446 / 145,746 | 300 = `@LAR` (reference's) |
| BCE | 74,099 / 74,699 | 600 = `#MOUT@`/`#MIN@` (reference's) |

**All 1,066 remaining failures are a known-wrong oracle, not a defect.**

Note the standing rule this exposed: **a fixture suite is regenerated, so
editing a fixture is not a fix.** When the oracle is wrong, the suite is *recut*
against a corrected reference — the generators take `YAGPC_REF_ROOT` to name
which `gpc` is the oracle, and `gen_cpu_instr_decode_fixtures.cjs` documents the
precedent in its own header.

### 8.4 The display IPL, and a receive floor

The display unit's IPL failed on **a 1.28 ms miss**, and the chain took a long
time because it was genuinely circular: a timed-out receive starves the poll,
the starved poll feeds back into MSC pacing via `@RAI` waiting for *all* BCE
indicators, and the delayed MSC makes the next receive later still. The
transport kept only one datagram per drain, so a one-word `#MIN` took 6.44 ms.
Fixed with a receive floor (2 ms; `YAGPC_RECV_FLOOR_US` overrides it, which is
how the sweep was taken).

**This was not a transport fault** — it was our own drain rate. Also removed:
the `malloc`/`free` pair every bus datagram was paying.

**MEDS then worked.** With the floor, MMU1 and MEDS up, yaGPC2 drives the real
display through a completed IPL and renders the GPCIPL MENU correctly — both
pages, per the user "even down to the exact register values, ERROR codes and
counts" against Don's video. ITEM 18/19/27+n/28 all behave as the video does.
Our text is arguably better: we render "ILLEGAL KYBD ENTRY WHILE SELF TEST IN
PROGRESS" where the video shows a corrupted "ILLEGAL KYBD ENTRY WHSELF TEST
IN PROGRESS".

### 8.5 Building our own flight image

`tools/build_ipl_fcm.sh` assembles eleven modules from `OI340600/SSSRC` and links
them under the CON80 deck's own layout. Verified against Don's `IPL.fcm`: **all
twelve sections at identical addresses and sizes, identical entry point (18195),
and of the 65,024 shared bytes only six differ** — halfwords 29534 and 29536 in
`FCMINSSL`, the two unrelocated `FIOMUWB2` references. Eleven of twelve sections
are byte-identical. This settles the BILDNEW5 link that `HANDOFF-OI340600`
recorded as unvalidated for want of a dump.

The full boot chain — FCMBOOT reading the tape, GPCIPL, MEDS — is documented
separately in **`HANDOFF-FCMBOOT.md`**, including the two mass-memory model bugs
(a MIA latch delivered ahead of live traffic, and a transfer's unread tail never
dropped), both of which were found by **adding a counter rather than reading
code**: `wordsOut` vs `wordsTaken` exposed the one-word leak, and `pending` per
command exposed a 360-word tail.

### 8.6 Rebuilding OI340600, and the bug that found

A full rebuild from source now succeeds — **25/25 phases, 821/821 HAL, 285/285
ASM** — after three upstream fixes in `nsts-sdl-dps`. Phase 21 needing 42 blocks
against an allocation of 41 turned out not to be a defect: `CGMIMU` finally *has*
content.

The important result came from the all-ours tape **not** booting ("invalid
instruction 0xd054 at 0x4a03"). An RLD hypothesis was wrong, but chasing it to a
specific field found a real yaGPC2 bug instead. At `GPCIPL+0x285`
(`LA R4,STMWAIT`), `asm101` emits `ECF3 1DF6` and ours `ECF0 1988`; `USING
FAILDATA,B0` is active and `0x1DF6 − 0x46E = 0x1988`, so **ours resolves the
USING and `asm101` ignores it** — and the original contemporary listing reads
`00285 ECF0 1988`, ours exactly. Scored over all 1,165 differing halfwords in
PHASE10: 1,071 are covered by the original listing, **ours matches 1,062 and
`asm101` matches 0.**

So the non-booting tape was the *faithful* one and the fault was ours:
**`LDM`/`STDM` decode patterns fixed the register bits at 000**, so a real
`LDM R1` (`69F8`) never matched and `DE` took it as a two-byte instruction,
desynchronising every later fetch. Fixed in `249669d91`. The POO says bits 5–7
of that family are identically zero; the *original* assembler encoded a spurious
register operand there anyway, **so the emulator must ignore them and a modern
assembler must reproduce them.** Filed as `nsts-sim-gpc` PR #31 and
`nsts-sdl-dps` issues #44 and #45.

This is the bug that could only be found by assembling the source correctly — see
this section's opening note.

### 8.7 The DASS comparison, and DFG

The `.dfg` phase of the DASS comparison is no longer blocked (`d30c2c959`).
Three independent gates had to go, one per file: `compileLinkCompare`'s "Step
−1" hook printed "DFG preprocessing not yet implemented" and died, `dass-db.py`
marked every `ext='dfg'` row skipped, and `dass-run.py`'s work query filtered
`AND s.ext = 'hal'`. **124 of 139 membership rows match.**

A cost estimate of mine was wrong by an order of magnitude — I said "hours",
anchored on the 4-hour figure for a *full* sweep of all 2,558 units three times
over. The `.dfg` work is 139 rows over 69 distinct decks and took about four
minutes at `--jobs=4`. **Divide the sweep figure by the work before quoting it.**

Of the 15 differing sections, four are not revisions of the same display at all
but **wholly different displays** — ours Spacelab/IUS/TDRS-era, the dump's
ISS-era (`CS2000` → APCU STATUS, `CS2050` → ISS MCS MODING, `CS2110` → ISS C&W,
`CS2120` → OIU). They cluster by phase, and the phase is 15. This bears out the
user's reading that these are mission-dependent I/O programs.

### 8.8 Decompiling the dump: `dfgmap.py`

`modules/sdfpkg/dfgmap.py` maps dumped halfwords back to the deck statements
that produced them. It works because **DFG already writes the mapping down**:
its generated `.hal` is self-annotating (`C -- <statement>` names the deck
statement, `C - <text>` explains a field), so no reverse-engineering of the
generator was needed. It runs forwards (`--dump`/`--address`: which of our
statements a memory image corresponds to) and backwards (`--find`, `--corpus`).

Everything below was derived from the corpus and *validated against it*:

- **DEU character encoding** — two 7-bit characters per halfword, the first
  character's low bit displaced into the second byte's top bit
  (`hi = (c1>>1)|0xC0`, `lo = ((c1&1)<<7)|c2`). **4,169 of 4,172 CHAR runs**
  decode to the statement DFG annotated.
- **Cursor FCWs** — 19 raster units per column, 27 per row, two bases per axis
  0x600 apart, plus absolute raster coordinates falling between cells.
  **4,051 of 4,051** coordinate statements convert correctly.
- **The screen is 51 × 26**, independently derived and user-confirmed.
- **Displays come in X/C pairs** — same name, leading `X` = background (fixed
  labels and item numbers), `C` = foreground — and only the XD/XG families have
  them, never XS/XV. Compositing the pair is what makes a rendering legible.
- `--bounded` bounds the display list by `[background, DDT)` from the DFT header.
  Measured rather than asserted: on the 126 sections that match the dump byte for
  byte it loses 1,290 cells against the full view's 173, so **both views are
  kept** and the header carries the measurement rather than an adjective.

Two real findings came out of it. `CDAP15` renders as nonsense because **it is
not a display**: `PMF=`/`AMTx=` decks are AMT moding tables, detectable by their
compool name (`CDA_Pnn_AMT`), and all eight `CDAPnn` decks are the same. And a
genuine defect **in our source**: `OI340600/APPLSRC/CV1000.dfg` carried `\br`, an
anonymization error, which the user fixed; with it corrected CV1000 matches both
dumps exactly.

Renderings of all 133 decks are written to `~/ipl-demo/dfg2/all-displays.txt`.

### 8.9 Recovering OI340700 source from the dump

Where a CSECT differs between our OI340600 source and the OI340700 DASS dumps,
the dump is enough to recover the source. Two files are written (uncommitted, in
`~/workspace/PFS/OI340700/APPLSRC/`, which is managed elsewhere), each carrying a
Virtual AGC header saying it is a reverse-engineering rather than an original:

- **`CS2PDT.hal`** — 86 structures plus the pad. Most of OI340600's file is
  reusable: the nine structure templates in `INCL80/STRPDT.hal` are unchanged
  between releases and are `D INCLUDE`d rather than restated, and even the
  trailing `CSAS_PDT2_PAD ARRAY(116)` is the same size. Only the instance list
  and its values are new. Each structure was matched to a template by member
  signature, and the match verified independently: **the spacing between
  consecutive structures equals the template's computed size at all 85
  boundaries.** Compiled, the CSECT is **376 halfwords, exactly the dump's size**,
  and **260 of the 260 halfwords the dump states a value for match** (the other
  116 are the pad, which the dump states nothing for).
- **`CS2110.dfg`** — round-trips through `dfg` and HALSFC to **all 144 halfwords**
  of the dumped `#PCS2110`.

Three things are worth keeping from how those were done:

1. **Scalars are IBM S/360 short hex float, and the DASS report gives the raw
   bits** in the column immediately before the decimal — `C518 69FF
   -9.9999937E+04`. The decimal is only for human readability: it is that value
   (exactly −99999.9375) *truncated* to eight digits, so re-encoding it lands one
   ULP low. Emit from the raw hex.
2. **But the exact decimal is not always the right literal either.** HALSFC loses
   precision on a long one: `-4.39999866485595703125` is exactly `C1466665` and
   comes back as `C1466664`. Emit the **shortest decimal that lands on the
   intended bits under either rounding mode** — truncation brackets the magnitude
   at `[exact, next)`, round-to-nearest at `[exact±½ULP]`, so choose from the
   intersection `[exact, exact+½ULP]`. This is a general rule for recovering any
   HAL/S SCALAR initializer from a dump.
3. **The BLT bit indices needed no fitting.** The encoding is stated outright in
   `nsts-sdl-dps/src/dfg/resolve.py`: `w0 = 0x0400 | bitpos1<<5 | bitpos2`, with
   `bitpos(field,bit) = (-n) % 16 + (bit-1)`. Both fields are `BIT(16)`, so
   `bitpos = bit-1`. An earlier formula of mine, fitted to OI340600's annotated
   BLT statements, accounted for 27 of 57 — wasted effort against a documented
   encoding.

The two recoveries confirm each other: `CS2PDT.hal` places `CSAS_PDT_6020017` at
+228 and its `_FDA` at +230, i.e. `D594`/`D596`, which are precisely the
addresses the dumped `CS2110` BLT entries carry — and the compool was recovered
from its own structure listing with no reference to that deck.

**Compile these with `halsParms.getParms(stem)`, never a hand-written CARDTYPE.**
CARDTYPE is per-stem (`CS2110` takes `FCRMUDXCVMWCYCZM`, `CS2PDT` takes
`FCRCUDXCVMWCYCZM` — a `C` where most take `M`), a wrong one does not fail the
compile, and using CS2110's for CS2PDT silently added ten halfwords of
conditionally-compiled declarations at the front of the compool, displacing every
offset in it and every external reference to it. See §8.10.

### 8.10 Method failures worth keeping

These cost real time and several produced confident, wrong, *written-down*
conclusions. They are recorded because the failure modes recur.

**Never write your explanation into the measurement.** Seeing a uniform
10-halfword offset between our compool and the dump, I explained it as "an object
prologue the linker drops" and then encoded that into the comparison as a map
scoring *ours-plus-10* as a match. The comparison could then no longer detect the
thing it existed to check. The control disproved it in one command:
`~/ForClaude/OI340600-clc/S2work3` holds both the object and the linked image for
OI340600's own CS2PDT, and `object[h] == linked[D4B0+h]` for all 2,573 halfwords
with no shift at all. **A uniform offset means suspect the build options, not
invent a mechanism.**

**Two emulators agreeing is not evidence about the input they share** — the
opening note of this section, and the reason the `asm101` `B disp(reg)` bug
survived RUNASM 205/205 and OI301700 272/272.

**A test peer you configure yourself is not an independent check** (§8.1's
`isShuttleBus`).

**Change one variable at a time.** "Our tape is deficient, 4 DISPLAY_FILL against
the reference's 87" compared two runs using *different pacing flags*; the
comparison measured the flags. `--deu-model` had already said the images agreed
(518 vs 690) and I did not believe the instrument.

**Check whether the label you are calling an error is on the error path.**
"BSLRESET is still reached, so something fails" — `BSLRQP15` is the *success*
path.

**Measure before asserting a negative.** I wrote that the Mass Memory Unit "had
never been run", when all I was entitled to say was that I had not started one.
Twice in one session a strong negative was asserted from a failure to observe.

**Retracting on weaker evidence than the original claim is its own failure
mode.** I told the user the MEDS clock was real GPC data, retracted on seeing
one-word datagrams, and had to un-retract when the user pointed out it read
`000/00:05:02` — mission-elapsed, counting from IPL. The first answer was right.

**Process hygiene.** `ps -C node` does not find a running `gpc`: its process name
is `node-MainThread`. Two measurements were silently taken with a second emulator
on the buses because of it. `pkill -f "mmu.js"` **matches its own shell** and
kills the launching command — use a bracket pattern, or a pidfile.

**Check where a probe sits relative to the write it measures.** My first
DEU-image measurement ran before the store loop and read zeros regardless.

**A control that agrees to the digit with the thing it is controlling for is a
control that did not run.** I told the user that 300 `#BU@` fixtures "were
already failing, 300 with and without the change, verified by stashing", and
reported it three different ways over two days. All three were wrong. The
stash comparison produced identical numbers because **the rebuild between the
two halves did not take**, so I measured one binary twice. The verified answer,
from a forced-rebuild A/B, is that both candidate behaviours give 74099/74699
with zero `#BU@` failures — the fixtures do not discriminate at all. `touch`
the source, or check the timestamp, before believing any A/B in this tree.

**A results row's summary fields are not the row.** I reported that the DASS
comparison database held a "match" that was not one, citing `#PCSDRTC` as
verdict `ok` with 0 differing halfwords against a rebuild showing 75. The
database was right: the same row's `detail` column reads `[75 ignored] [43 no
reference data]`. I read `n_diffs` and `verdict` and not the field beside them,
in a row I had already printed.

**An explanation that fits the arithmetic is not a reproduction.** The
over-broad exclusion in §8.12 spans exactly 1379 halfwords, which matches an
unclamped walk of a 1379-halfword section to the digit — and the code path I
inferred from that fit turned out not to be the one, because re-running the tool
did not reproduce the span at all. The "fix" the fit implied then discarded
13,418 legitimate entries across eleven units. Twice in one investigation.

**Grep for the success line, not for the absence of a failure line.** A sweep
that greps for "N halfwords differ" and prints 0 when the line is absent prints
0 for a *failed compile* too. `CS2000` and `CS2110` both showed "0 diffs" while
failing to compile.

**Your own test processes are on the user's bus.** The discretes bus is
machine-wide multicast, and several of my test scripts hold RUN for minutes at a
time. A stray one drives RUN into every emulator on the machine, including the
one the user is looking at — which is half of the mode-flapping report in §8.14.
A sending socket is not bound to the port, so `ss` cannot see a publisher; only
`ps` can, and it must be checked *before* concluding anything about discretes.

**Read the whole character class.** A regex over the BCE decode table that
omitted `_` missed `#RIB`, `#SIB` and `#WAT`, and made me claim `#WAT` was
undecoded when it is right there at `iop_bce_instr.c:440`. One that omitted
uppercase `X` made me call `0xc7f3` undecoded when it is `BC`. I published a
count of 21 BCE opcodes, corrected it to 24, and both were wrong: **the table
has 27**, measured by listing the mnemonics rather than counting matches.


**Read the manual for the processor you are emulating.** Most of a session was
spent defending an addressing rule cited to POO Figure 2-8, which is the
AP-101 **C/M** — the previous machine. The AP-101S says the opposite in as many
words, flagged as an explicit change. The wrong-manual error then produced four
successive confident conclusions, each disproved by measurement, each a
downstream symptom of the same root (§8.16). What forced the recheck was a
*reductio* from the user rather than any measurement: software that flew for
decades cannot fail to boot.

**A null result from a run that never reached the code under test is not a null
result.** "`FCMSNCSV` is never written" was reported from a `WATCHHW` run killed
at about four minutes — but `FCMSSYNC` does not execute until PASS is up at
~220 s of simulated time. Likewise "zero DMA protect violations" was reported
from a truncated run and a correct explanation withdrawn on the strength of it;
run to completion, there were 7,170.

**A counter that reads zero because the feature was switched off is not a
measurement of the feature.** Headless runs all used `--discrete-b 20000000` —
GPC 1 with *no CRT selected* — so "deu: commands 0" was a property of the test
configuration, and it was then quoted as evidence the display was dead.

**Verify a control by a functional difference the change must produce, not by
rebuilding and trusting the build.** The `#BU@` fixture counts were misreported
**four times** before `wordsTaken` (98,820 vs 28,164) was used as the check that
the binary had actually changed. It had been available the whole time.

**Check the binary exists before believing its silence, and capture the count in
a variable.** An upstream blocker was declared on the strength of running
`build/bin/HALSFC-PASS1`, which does not exist (the binaries are in
`build/halsfc/`), plus `$P --help | grep sdfi | head -3 && echo ACCEPTS`, where
the `&&` sees `head`'s exit status rather than `grep`'s. Two invalid tests in a
row, both pointing the same way.

**Measure, do not recall.** A 96.6% placement figure was quoted from memory
into a later argument; re-measured against `mafgen/csects-SSW.json` the build
actually in use scored 83.79%. The number had been recalled from a
differently-configured build. Worse, the volume under test **predated its own
pins** — `linkorder.json` timestamped 06:36, the tape 06:31 — so every run in
that thread used an image built without them.

**Check the whole distribution, not the head of it.** "135 allocations and zero
returns" over a pool came from a histogram truncated to the top 8 NIAs; the full
histogram has 25 distinct writers, and the conclusion built on it (a leak) was
wrong.

**Kill every leftover process and verify by PID before any bus measurement.**
Five stray yaGPC2 processes were live on the multicast bus during one reported
measurement, and four `discretePanel` instances — one launched per iteration
without killing the previous — each republishing conflicting mode levels from
its own script clock, made a deterministic crash look nondeterministic. Related
harness bug: `pgrep -f 'discretePane[l]' | grep -c python3` always counts 0
because `pgrep -f` prints only PIDs, so an overlap guard built on it never
fired; use `pgrep -fc`. And `pkill -f` cannot be used here at all — the
pattern text appears in the shell's own command line, so it matches and kills
the shell (exit 144, five times in one day). Use a bracket pattern
(`discrete[P]anel`) **and** keep kills in a separate invocation.

**Sample the time course; a single window on a ramp is meaningless.** Two 45 s
datagram counts taken 8 s after launch straddled different points of a rising
curve and were reported as a difference between two tapes. Retracted.

**A stale binary can survive a newer timestamp.** The `sections` protection mode
"never made any difference" for three reported results because `make` had not
rebuilt `ageharness.c`; `touch` + `make` fixed it and the mode then reported its
work. Separately, `make` does not rebuild the *test* binaries at all and does
not track `test/cpu_ea_fixtures.h`, so an edited fixture header is silently
re-run against the old binary.

**Section containment is suggestive, not conclusive.** A 102-halfword mismatch
cluster was attributed to a release difference because it falls inside a
changed CSECT; the change lands elsewhere entirely, and in that phase
`FCMSAVE`, `FIOADCNS` and `FIOCBLKS` all cover the same address anyway.

**Do not compare two mechanisms at the granularity only one of them can
express.** "SPON/SPOFF is redundant" was argued from CSECT-level agreement,
which is exactly the granularity the coarse mechanism can express and the
fine-grained one exceeds. A comparison made at the coarser granularity cannot
detect information that lives below it.

**Two pieces of evidence drawn from the same source are one piece of
evidence.** The BCE-opcode clustering and the name-prefix clustering were
presented as independent corroboration; 72% of BCE-opcode files share the same
prefix, so the second table largely restated the first. Hold the confounder
constant and re-measure.

**When a claim rests on one unchecked link, name it.** "Latent defect in the
flight software" was concluded from a chain in which every link was checked
against a primary source *except* the HIMEM-block count, which came from our
own reconstruction and was never checked against anything — and the artefacts
in it (16- and 4-halfword blocks) had already been noticed and walked past.

**`grep` that returns nothing is not `grep` that matched.** An `ls` in the same
command printed filenames afterwards, and the empty match was read as a hit —
crediting a MAFGEN annotation from the original 2010 report to our own modern
imitation of it.

**A probe placed on the wrong path looks like a negative result.** The first
version of `YAGPC_NIAPROBE` went into `gpcops.c` beside its `ap101_exec1()`
call — the GpcOps embedding path — while the CLI runs `run.c`'s
`batchrunner_step()`. It never fired, which was nearly read as "the code is
never executed". `ap101_exec1()` in `ap101.c` is the one chokepoint both go
through. What saved it was scanning the image for the instruction's own object
code and finding it exactly where the address arithmetic said.

**Watch the address the software actually writes.** Three attempts at the
keystroke bug theorised about delivery timing, major-function bits and a
checksum; the defect was visible in one halfword, at `KEY1` rather than at
`ITEMNO` — which is the same address as a structure base and therefore showed
only unrelated traffic.

**Diff the loaded memory image, not the link metadata.** Reasoning from
`sym.json` chased Z-con holes and CSECT overlaps for hours; stopping two runs
at the same step count and diffing memory named the fault — unrelocated address
constants — in one run.

**Read the tools before chasing the bug.** `tools/` already contained
`stamp_ipl_phase_table.py` and `stamp_ssl_checksum.py`, each with a docstring
naming verbatim the symptom then spent hours rediscovering from memory dumps.
Twice.

**Fix exactly what the evidence covers.** One instruction, `#TDL`, had a
measured count table; four were changed on the family argument (§8.27). Two of
the four were wrong and broke a working path — `ITEM 1 EXEC` stopped loading —
so a verified fix arrived carrying a regression. The bisect that recovered it
took longer than the original diagnosis. A family argument is a reason to *look
at* the other members, not a licence to change them in the same commit.

**Question the peer's accumulated state, not just its replies.** Seven GPC
restarts in a row produced stale displays behind a red X while the tape side
worked perfectly, and each one was met by measuring the GPC's side of the wire
again. The MEDS instances had simply been IPLed once and stop asking
afterwards, which §8.25 already records. **A long-lived peer is a stateful
peer**; restart it with the thing under test, and when a symptom appears only
after repeated runs, suspect what accumulates across them.

**A hand-placed instrumentation patch can land on a different function.**
`exec_MOUT_at` and `exec_TDLI` have identical code shape, so a patch matched by
text went into the wrong one and printed its output under the other's name; the
first trace showed a display fill with no transmit instruction at all. Where a
family of functions shares a shape, put the counter at the **chokepoint they
all pass through** — `iop_queue_dma`, in that case — rather than on each one.

**`make` reports test binaries "up to date" after their sources change.**
Recorded above for `ageharness.c`; hit again in the `@`-family A/B, where the
first before-and-after comparison ran the same binary twice and reported a
byte-identical result that meant nothing. `touch` the source and rebuild before
believing any fixture comparison.

**A relative path can write into somebody else's repository.** The shell's
working directory PERSISTS between Bash calls, so a `cd ~/donschmidt/...` in one
invocation was still in force in the next and `cat > tools/dksniff.py` created
it *there*. It had not vanished; it was never in yaGPC2. The same thing
swallowed a `CLAUDE_LOG.md` append, which became a new file in Don's tree. Both
were found as untracked files while preparing a PR. Use an absolute path, or
`cd` at the start of every invocation — and note that this is a way to modify
another project silently, which is exactly what the standing rule about other
people's repositories exists to prevent.

**A fit is only as good as the frame it is anchored in.** Glyph measurements
were converted to cells using the GPC box as the reference frame — after moving
that assembly up one row a few commits earlier. The reference frame therefore
disagreed with the measurement's frame by exactly the row I had introduced, and
a confident "the text sits 1.43 rows low" fell straight out of it. Anchoring a
fit on your own recent edit is circular.

**An offline model of somebody else's interpreter is a hypothesis generator,
not an oracle.** Three separate times a number derived offline looked decisive
and was incomplete because the model left something out — the sector, the
second coordinate frame, and the X/Y reference registers. Instrument the real
thing; `NSTS_CELL_TRACE` records what the renderer computed, not what the model
says it should have.

**A knob is not automatically a safe way to let somebody else find a number.**
`@group.scale.y` stretched the glyphs rather than the gaps and carried the POLL
FAIL cross and the boxed GPC number down into the menu area, because they are
drawn in the same group and the same units. It could only be wrong in ways that
looked like progress.

**Change one thing per round.** Four rounds in a row, two or three constants
moved at once and no result could be attributed. One knob per symptom —
`NSTS_DPS_YSHIFT` (whole page), `NSTS_DPS_TEXTY` (glyphs), `NSTS_DPS_VECY`
(vectors), `NSTS_MENU_DX` (menu area) — so a single relaunch settles a single
question.

**When someone reports the same symptom a third time, the model is wrong, not
the measurement.** The user said three times that the viewing area *plus the
chrome* was 2048 square, and each round tested whether the canvas was cropped.
It never was: `cde-window`'s chrome is drawn OVER the canvas, so every
measurement agreed — viewport 1024, canvas 1024 at (0,0), overflow 0,0 — while
the display was obscured anyway.

**A change that improves the case you are watching and quietly breaks the case
you are not is indistinguishable from a fix until somebody looks at both.** A
single-constant "fix" to the beam geometry was verified against one deck — a
real oracle, but one, and every format in that corpus shares a producer. The
user's report that GPCIPL got *worse* at the same moment PASS got better is what
exposed it.

**Check the primary source before acting on an inference.** A conclusion that
`dfg`'s coordinate origin was wrong was assembled from a calibrated decoder and
a capture file, stated across two turns, and acted on — before anyone looked at
the historical DFG output that `build_deucflm.py` names in its own docstring.
That artifact overturned it in one command. Worse, the user's independent
evidence (an overlay of our render against Don's screen) pointed the other way
and was under-weighted.

**A consequence nobody would accept is a test you can run against your own
claim.** The same wrong conclusion implied that whole fields of a flown display
were off the screen. That should have been checked against the historical
output immediately rather than left for the user to ask "so they really are not
visible?".

**A uniform result across a whole set means suspect the harness — including
when the set is three runs, not three hundred.** This document's own standing
rule, not applied when it mattered. GPC 1, GPC 2 and GPC 4 all refused the OPS
request identically, and that identity was read as evidence about the flight
software rather than as the signature of a shared input. The shared input was
the harness: the DEU model's major-function switch, which reported PAYLOAD
regardless of anything, because it was never assigned from anywhere.

**A retry that is harmless on one screen is input on another.** A repeated
`ITEM 1 EXEC` was left in every headless measurement because it is a no-op on
GPCIPL's menu. Once PASS owns the page it is not: `ITEM 1` is invalid there and
raises `ILLEGAL ENTRY`, which then got attributed to the OPS request. It
contaminated two conclusions and produced one written-down finding — "PASS
ignores our item entries" — that had to be withdrawn.

**Never edit a shell script while an instance of it is running.** Bash reads a
script incrementally from a byte offset, so an edit under a running instance
makes it resume in the middle of a different line. Patching
`headless-gpcmem.sh` during a trace run gave `line 85: 900: command not found`,
a second emulator launched on the same port base, a timeout kill, and the run's
own log re-truncated — destroying the trace it had just produced, which
survived only because a tool cache happened to hold a copy. Copy the script, or
wait.

**A diagnostic that fails silently on a malformed argument will be trusted.**
`YAGPC_SNAPSHOT` wants `<t1>[,<t2>...]:<prefix>` and, given a bare prefix,
looks for the colon, finds none, and does nothing at all. Two full runs
completed and produced no snapshots before anyone checked why.

**A backgrounded subshell does not inherit a `cd` that was `&&`-chained to its
sibling.** `cd X && ( A ) & ( B ) &` runs B in the *original* directory. B died
instantly, wrote its log into the repository, and the pair of runs it was half
of had to be redone.

### 8.11 Finishing the OI340700 `.dfg` recovery

§8.9 recovered two files. All twelve differing decks are now accounted for, and
the shape of the answer is not what the halfword counts suggested.

**Most of them did not need recovering at all.** Five deck/config pairs —
`CS0620` in both S2 and G9, `CS0940`, `CS2011`, `CS2021` — go from 51/51/44/27/52
differing halfwords to **zero** once they are linked against recovered compools.
Their OI340600 decks already *are* the OI340700 decks; what changed was the data
they point into. Of 3,855 differing halfwords across the whole set, **944 are
relocation targets** — pointers into a compool whose internal layout moved. That
number was invisible at first because `compileLinkCompare` hardcodes
`--max-hw-diffs 10`, so classifying from the diff table undercounts by design.

**Five compools were recovered exactly**, each from the DASS report's own
structure listing: `CSA_PDT` 5640/5640 (2,059 structures, CSECT 5,756 halfwords —
the dump's own size), `CS2_MDT` 755/755, `CS2_PDT` 260/260, `CSD_RTC` 197/197,
`CSP_CLB` 60/60. `CSA_PDT` used the same template-matching method as §8.9, with
the same independent check: **structure spacing equals the matched template's
computed size at all 2,058 boundaries, zero mismatched**, and the last structure
ends at +5640, exactly where the pad begins.

Two parser bugs had to be fixed first and both were silent:

- **The raw-hex field must be taken by fixed column** (`[65:88]`, decimal
  `[88:113]`). A greedy hex regex swallows a decimal that happens to be four
  digits — `6400` — leaving nothing to parse, and the member renders as zero.
  180 integers were wrong that way.
- **An array of copies** (`+++ COPY 1 OF 2 +++`) must be matched on one copy and
  re-emitted as `-STRUCTURE(n)`. 66 structures failed to match without it.
- And in `CS2_MDT`: an `ARRAY` member's values sit on their own line with no
  name, so the name column holds the first hex value and the line reads as a
  phantom member; the second value is past the raw-hex column entirely.

`CSP_CLB` is worth its own note. It is OI340600's file plus one change: three
GCIL command masks are wrapped in structures whose first member is a 2-halfword
`SCALAR` dummy — presumably how the "MUST BE ON FULLWORD BOUNDARY" its own
comment demands was finally *guaranteed* rather than asserted. Three structures
of two halfwords each is the six-halfword displacement that made `CS0620`'s
pointers into `#PCSPCLB` wrong by 6.

**The decompiler encoding was learned from the corpus, not guessed.** DFG
annotates its generated `.hal` with the deck statement that produced each run of
halfwords, so running `dfg` over OI340600's 133 decks yields **31,517 labelled
statement instances** — every statement kind's opcode and length, and for about
65% of a display's statements an exact sequence lookup. `HEADER=nnnnS` is
`0xC000|n` (checked against 0620S/1000S/2011S/2021S), and `VCORDA`'s first point
is `x = fcw-0x8400` or `-0x7E00`, `y = 0x916E-fcw` or `0x976E-fcw`, in raster
units, validated on all 352 corpus instances. Its **second** point is *not* a
signed delta — sign-magnitude on bit 11 gets 162 of 352 and fails on horizontal
vectors — so it is left uninverted rather than shipped half-right. The tool is
`~/workspace/PFS/decompileDFG.py`, deliberately self-contained (its own DEU
charset, cursor geometry and corpus reader) so it does not reach into virtualagc.

**`SPCHAR` was the last big decode and it took two wrong rules.** Only
`0x20..0x5B` is writable inside `CHAR=( )`; everything else is addressed by
index, `c<=0x1E` as `c+11` and `c>=0x5C` as `c-45`. But the *code* does not
decide: `0x16` is packed with its neighbours in `CS2120` and stands alone as
`SPCHAR=33` elsewhere, so a code-only rule fixed `CS0780` and broke `CS2120` by
623 halfwords. Nor does the *packing* decide alone: `0x08` has no printable
glyph and must be `SPCHAR` even as an odd-length tail, which a packing-only rule
got wrong in seven places. **The rule is both**: no printable glyph → always
`SPCHAR`; otherwise alone-in-a-halfword mid-run → `SPCHAR`, the same shape at the
end → an ordinary tail.

Three traps cost real time. `3400` is the opcode of **both** `SBC` and a
display-list preamble FCW, told apart only by the preamble's null operand.
`PAD=n`'s `F000` terminator **ends the statement stream** — without handling it
the DDT decodes as spurious statements and `F000` itself reads as a character.
And a deck line is read only to **column 72**: my first `CS2000` deck had
83-character `VPARM` lines, so `dfg` saw truncated statements and failed to
parse. The corpus wraps them.

**Ten more anonymization tags were corrected in OI301700** (`CG0500`, `CS0870`,
`CS2000`), each a display label rather than a name: `^G`→`RN`, `^U`→`MG`,
`^vk`→`SRM`. These files are *original build artifacts*, so anonymizing the
source left the compiled FCWs beside it intact and each file states its own
original text a few lines below the tag. Found only because the user asked
whether OI301700 had the same error: my earlier sweep looked for backslash
sequences only, and `CV1130`'s was a caret. `CV1130` was never an OI340700
difference at all — with `R/SB` restored its deck matches the G9 dump exactly.
Both corpora are now clean of tags inside `CHAR=( )`.

**Recovered source has a column budget, and it is 70 for a `.dfg`, not 72.** A
deck comment is re-commented into the generated HAL/S under the
`**** DFG INPUT ****` banner with a `C ` prefix — **two** characters, measured —
so a 71-character deck line becomes a 73-character HAL/S comment and spills into
the SRN area at columns 73–80. When reflowing to fit, **preserve existing
inter-word spacing**: `textwrap`'s `fix_sentence_endings` rewrote the standard
Virtual AGC header's "None. Believed" into "None.  Believed", which would have
made that block differ from every other file carrying it. And a
paragraph-continuation test must require the label to start *at the label
column*, not merely match `word:` — a colon in running prose ("human
readability:") otherwise ends the paragraph early and silently leaves the rest
unwrapped.

**Three halfwords remain, and they are `dfg`'s, not ours.** Word 1 of a `RATE`
entry is the group's worst-case FCW draw, which `dfg` computes rather than
reads. Tracing its own `_content_draw` over `CS2050`'s group gives every
directive's budget, and **every one is a function of the emitted words alone** —
83 from the content directives plus 34 from thirteen `IMMED` groups, 117, where
the dump has 118. `CS2120`'s two groups come to 207 and 77 against 213 and 78.
The emitted words match the dump everywhere else, so the original DFG budgeted
more for byte-identical content: a gap in `dfg`'s model of the original's
allowances. `ddt.py` itself says the original's budgets sometimes exceed the
runtime draw and lists the allowances it models; none of these groups uses one.
Ruled out **by experiment, not argument**: all ten corpus spellings of the
ambiguous `VPARM` format 1412/4018; raising each of the three `TEST` and three
`BR` operands (all make it worse, by changing the emitted displacement); the
`CONV=S`-versus-`CONV=I` ambiguity, which cannot apply since all three `VPARM`s
carry sign code 7; and `dfg`'s `HEX` model, since `CS0710` uses 15 `HEX`
directives and matches the dump exactly.

### 8.12 The `-full` exceptions lists cannot be regenerated

This one is unresolved and the honest summary is that **at least one entry in a
shipped exceptions list is demonstrably wrong and the file cannot be
reproduced.**

The chain is real and was run down: `dass-literals.py` writes the base
`exceptions-XXX.txt` — the locations MAFGEN marks with `*`, changed after the
build. `dass-versions.py` then *appends* the differences attributable to our
source being an older release, taking `--exceptions=BASE.txt` and emitting the
`-full` variant, the extra entries carrying value `-1` and a reason in the name
field (`DCDDG9-revised-CM-to-CN`). The plain file is a strict subset: 1,262
entries become 46,385. Separately, `dass-syms.py` recovers a compool's CSECT
address into `augmented-XXX.json` and `dass-fields.py` — "`dass-syms.py`'s
problem one level finer" — adds the addresses of fields *inside* those compools,
which `dass-versions.py` consumes via `--fields`, precisely because a reference
from an assembly module into a revised compool is otherwise invisible.

**The wrong exclusion.** In `exceptions-S2-full.txt` the reason
`CSAPCT-revised-BX-to-BY` covers 1,210 addresses spanning `00C6BC..00CC1E`.
`#PCSAPCT` is `00C6BC..00CB56` and `#PCSDRTC` is `00CB5A..00CC37`, adjacent.
1,013 of those addresses are inside `CSAPCT` and legitimately excused; **197 are
inside `CSDRTC` — the whole of its stated halfwords — and are not.** The marking
starts at `CSAPCT`'s own base and runs past its end into the next CSECT. It is
demonstrably wrong rather than merely suspect: the recovered OI340700
`CSDRTCCM.hal` compiles to match all 197. A difference attributable to *another*
unit's revision is by definition not something our own source can reproduce;
these are reproducible, so they are `CSD_RTC`'s own source difference and the
exclusion mis-attributes them. That is the kind of exclusion that hides work —
the stated purpose of the list is "locations changed after the build (I-LOADs,
patches, checksums), which no compilation or link can reproduce".

**But the over-run does not reproduce.** Re-running with `--config=S2
--link-dir=work --exceptions=exceptions-S2.txt
--fields=augmented-S2-fields.json` gives **zero** entries in `#PCSDRTC`'s range
and zero `CSAPCT-revised-BX-to-BY` entries at all, and 17,336 entries against
the shipped file's 46,385. The option I did not supply is `--asm-link`, a
full-configuration link whose `.fcm` must sit beside it, and no such file is on
disk. So the shipped file was made from inputs that no longer exist, and **I
cannot attribute the over-run to a code path.**

The fix I inferred from reading that code path anyway was wrong, and instructive.
Requiring `owner(address) == section` in the self-revised branch discarded
**13,418 legitimate entries across 11 units** — `CVNMMUTI` 7,150, `DMPMMMSG`
3,691, `DCDDS2` 1,904 — because **a compool whose storage is owned by an assembly
module has no CSECT of its own**, so `owner()` returns the enclosing assembly
CSECT and the clamp rejects every address the compool legitimately claims. That
is the very case `dass-syms.py` exists to handle, and `owner()`'s own docstring
says so. Reverted; `dass-versions.py` is unchanged from its committed state.

Two loose threads, not chased. `exceptions-S2.txt` (1,265 lines) has **zero**
entries in that range where `exceptions-S2-full.txt` (46,393 lines) has 197, yet
both carry the identical header claiming to be the locations MAFGEN marks with
`*` — they cannot both be that. And `dass-literals.py` has no `--full` option,
so how the `-full` variants were produced is not accounted for by the tool that
claims to produce them. **Until the `--asm-link` inputs are found or rebuilt, the
`-full` exceptions lists should be treated as unverified.**

### 8.13 Booting from the real tape, and why `ITEM 1` loaded nothing

`gpc run` no longer requires an `fcm-file`. Omit it and the GPC IPL pushbutton
reads FCMBOOT off the mass memory, exactly as Table 2-2 step 10 has the firmware
do, and the HALT→STBY release runs it. With an `fcm-file` nothing changes.
Details are in `HANDOFF-FCMBOOT.md`; three things belong here.

**Which vector: always the system-reset PSW at 0x14**, first release and every
later one. `FCMBOOT.asm:38` says so outright ("RECEIVES CONTROL FROM THE MICRO
CODE LOADER VIA THE SYSTEM RESET PSW"), and the image agrees — `0x0004` holds
`0000 0000 0002 0000`, address 0 with the WAIT bit, a deliberate park, while
`0x0014` holds `014B 0066 0008 0000`, FCMBMOVR in sector 6 with register set 1.

**Reload is load-bearing, not housekeeping.** FCMBOOT's External Zero handler
does `OST R5,FCMBSYRS+2`, setting the WAIT bit in its own system-reset PSW. An
already-booted in-memory FCMBOOT therefore *parks* on the next release;
re-execution works only because a fresh IPL puts a pristine copy back. That is
what makes keeping step 10 and step 11 apart matter.

**CON80 card addresses are FTSBB** — file, track, subfile, two-digit block. I
had written TFSBB in both the bootstrap tool and `run.c`. The phase manifest
settles it: card 43000 is address 3/4/0/0, and the manifest's address string is
track/file/subfile/block — **the only reading under which all 1,085 blocks of a
built volume are accounted for**, checked over all 24 permutations. The same
arithmetic retracted a claim of mine that the tape's phase 2 was truncated at
114 of 154 blocks. It is not: the manifest claims 1,085 blocks and the volume
holds exactly 1,085. Count what the manifest claims and count what the file
holds — that is the check to run *first*, before reading anything into which
blocks appear missing.

**Why `ITEM 1 EXEC` loaded nothing.** The user reported the item being accepted —
an asterisk appears beside it — with no mass-memory activity following. The chain
is `CM4KYBD` (items 1–17) → `LOADCHCK` (minor cycle 1) → `SSLCHECK` (minor cycles
2–11, 24) → the SSL. Breakpoints put the failure squarely at `SSLCHECK`:
`LOADCHK 0x2c8b` **hit**, `SSLCHECK 0x2d10` **hit**, `CM4FMAT 0x271f` not hit,
`FCMINSSL 0x6fbc` not hit — and the last mass-memory command of a whole run is at
t=13.7 s against a keypress at t=97.2 s, ninety-nine seconds of silence.

The cause is that **`SSLENGTH` and `SSLCKSUM` are zero, and a zero length hangs
the check rather than failing it.** `SSLCHECK`'s `BCT R3,SSL30` decrements
*before* testing, so a count of 0 underflows and the checksum loop never
terminates: measured deterministically, `SSL30` hit, `SSL60` — the instruction
after the `BCT` — **never**. The comparison is not reached at all, so `SSL70`,
the path that master-resets and passes control to the loader, cannot be taken.

They are zero because **the checksum is a build product and our reconstruction
does not produce it.** `FCMCKSUM.asm` says so: "FCMCKSUM WILL CONTAIN THE LENGTH
OF THE SSL AND ITS ASSOCIATED CHECKSUM. THE CHECKSUM WILL BE GENERATED BY THE
MASS MEMORY BUILD PROGRAM." Declared `DC H'0'` and filled in when the phase is
written to tape. `tools/stamp_ssl_checksum.py` stamps them and the whole chain
completes — `SSL30`, `SSL60`, `SSL70`, `FCMINSSL` all hit, and the mass memory
issues `POSITION 3/4/0` / `EXTENDED BLOCK` / `READ`, **154 blocks, PASS area 1
phase 2**. That read had never occurred on any earlier run.

**The span is `SSLSTART..SSLEND`, 806 halfwords**, from the link's own `SSLEND`
equ at `0x72E2` — not `SSLSTART..FCMCKSUM` (988), which I tried first. `SSLEND`
*is* `FCMDATA`, the same address, so the sum covers code and constants and
excludes the dynamic work area, which is the principled reason. **Caution for
anyone revisiting: the checksum cannot validate its own span**, because the value
is computed *from* the span, so any choice is self-consistent and will pass.
`SSLEND` is the principled basis, not the passing test; only a real MMB-built
tape would settle it.

Two corrections on the way to that. I claimed the checksum *was* present at
`0x739D` and that `lnk101` misplaced `FCMCKSUM` by two halfwords — wrong:
`mmbstamp.py`'s own docstring says every load block carries a 2-halfword checksum
tail that the block's length **includes**, so `0x2958` is the *load block's*
checksum, not the SSL's, and `lnk101`'s placement at `0x7398..0x739B` is correct.
Then I retracted too far and concluded stamping could not be the answer at all;
the original reading was right. And `CH`/`AH` put halfwords in the **high half**
(`exec_AH`/`exec_CH` shift by 16), so the sum accumulates in R4's top 16 bits
with carries falling off and `CH R4,SSLCKSUM` reduces to `(sum mod 2^16) ==
SSLCKSUM` — a plain 16-bit sum. An earlier worry that no 16-bit value could match
came from assuming sign extension into the low half.

**Why the earlier stamping attempts "did not work" is the methodological
finding.** They were tested on the networked, real-time, `gpcmd`-driven vehicle,
which is **not deterministic** — `SSLCHECK 0x2d10` hit on one run and missed on a
later identical one. Every conclusion drawn before the deterministic harness
existed should be treated as unproven. The harness is the reusable part:

    ./yaGPC2 run --ipl --deu-model --mmu-model TAPE --discrete-b 20000000 \
        --max-steps N [--break=ADDR] BOOT-stamped.fcm

No crew panel, no `gpcmd`, no `--real-time`: two runs are byte-identical.
`--discrete-b 20000000` is GPC 1 with **no CRT selected**, and it is what makes
the non-menu path reachable — per Table 2-2, without step 6 the SSL loads PASS
area 1 phase 2 by itself and goes straight to step 13, so the whole question can
be studied with no keyboard and no MEDS.

### 8.14 Emulator defects found by running the SSL

**Silence was being read as a switch position.** `run.c` substituted `MODE_HALT`
whenever nothing was published on the discretes bus and then ran the edge tests
against it, so one lost datagram — or a Tk panel falling behind
`DISCRETES_STALE_SEC` once — read as HALT, and the panel's return read as a
HALT→STBY *release*, which calls `cpu_reset()`. Repeatedly. A machine reset every
second or two never gets anywhere, which is exactly the user's report that
"GPCIPL does not run" with RUN and STBY flapping in the terminal. Edges are now
taken only between positions the panel actually published; a gap leaves the last
one standing. Measured: 4 deliberate 2.5 s dropouts produce **1** release, where
they produced one per dropout before. The no-position instant between "clear the
old bit" and "set the new one" was also being reported as a mode change, which is
where pairs of MODE lines for a switch nobody touched came from; it is now held,
not reported. `YAGPC_MODETRACE=1` prints driven/value/mode/prev on every change
and is what separated this from the stray-test-panel half of the same report.

**I dismissed this oscillation twice as a test-harness artifact, in my own logs,
before the user reported it from the GUI.** It was in front of me both times.

**`#BU@` was not indirecting**, and settling it took two wrong answers. The SSL's
MMU read program ends with `#BU@ FCMBCEBT`, which is how it chains to the receive
sequence that collects the tape data; with the branch taken *to* the table entry
rather than *through* it, BCE 18 landed on `0x72CC`, decoded its `0000` as an
unknown instruction, never advanced, and spun there for the rest of the run.

The POO's wording is "the next instruction is found at the address specified by
the operand, plus twice the BCE number", which reads as direct — and on that
reading I first reverted the fix, then invented a BCE opcode 0 meaning "branch",
which the user disposed of immediately (`0x0000` is `ADD R0,0(R0)`). **The flight
software settles it, and the decisive case is not `FCMBCEBT` at all.**
`FIOMUWP9.asm:92` does `#BU@ FIOBBM`, and `FIOCBLKS.asm:537` declares `FIOBBM`:

    ENTRY FIOBBM / DS 0F / FIOBBM EQU *-36 / DC 2F'0'

— two fullwords of **zero**, with the same `-36 = -2*18` bias — so an entry
cannot be a static instruction. And `FIOMGDSP.asm:750` fills it in at run time
(`LA R2,FIOBBM+2` / `ST R7,0(R3,R2)`, "STORE ADDRESS IN BCE ENTRY"), with the
module header calling `FIOBBM` a "MM BRANCH ADDRESS TABLE". Entries are computed
addresses. `FCMBCEBT` is the same construct with addresses known at assembly
time, hence `DC A(FCMIBLK1)`. So the POO wording *is* the indirection, read as
"the next instruction is found at the address **held at** operand + 2×BCE#", and
no new opcode is needed. Effect, measured on the deterministic harness:
unknown-instruction spins **3,369,393 → 0**, `wordsTaken` **28,164 → 98,820** of
107,012, `wordsLost` 0.

**And the answer explains itself once you see how `FCMIBLK1` is filled in: the
SSL writes its BCE program at run time, instruction by instruction.**
`FCMINSSL.asm:616-624` ORs bare opcode skeletons — `FCMMLBR EQU X'F200'`
(`#LBR`), `FCMMRDLI EQU X'F300'` (`#RDLI`), `FCMMWAT EQU X'0800'` (`#WAT`) — with
computed operands (a load block's base address, its 512-halfword block count) and
stores them through `FCMRSADD`, which points at `FCMIBLK1` then `FCMIBLK2`
alternately so the two areas double-buffer. `FCMIBLK1` is `DS 10F` in the
"DYNAMIC WORK AREA", all zero until then. A branch table into scratch that is
written at run time **has** to hold addresses.

**`FIOMUWB2` is a link-input gap, not a compiler gap.** `IPL.map`'s one undefined
symbol is `FIOMUWB2`, referenced by `FCMINSSL.obj`, which declares its temp-buffer
address as a Z-CON over it (`FCMB1ZCN DC Z(,FIOMUWB2,0)`). Undefined resolves to
zero, so the buffer address is 0, and the chain from there is exact:
`FCMLBRTB` elem#1 = 0 and elem#2 = `0 + FCMBF1CT(8192)` = `0x2000` → `FCMMOVE`
gets src=0, dest=0, count=4096 → `MVH` stores into protected low memory. The
symbol is a HAL/S equate — `APPLSRC/CVNMMUTI.hal:44`,
`EQUATE EXTERNAL FIOMUWB2 TO CDHV_BLOCKS$(1,1);`, which `HALSTAT.ASC:384169`
confirms at `PHASE 2 ADDR: 03032A` — and **our own toolchain emits it**:
`PHASE03.sym.json` has `FIOMUWB2 = 0x3032a`, matching HALSTAT exactly. The defect
is only that the IPL link does not have the defining compool among its inputs.
**Fixing the link inputs is the real repair**; `tools/patch_ssl_zcon.py` writes
the value the link should have produced, as a stopgap so the rest of the boot can
be exercised. The Z-CON format was derived from the code that consumes it and
then *checked*: halfword 0 = `0x8000|(addr&0x7FFF)`, halfword 1 = `addr>>15`, and
running `FCMINSSL`'s own `LH/SLL/LH/SRL/SRDL` sequence over `832A/0006`
reconstructs `0x0003032A`.

**A "wild branch" that was nothing of the kind.** With those fixed, the boot died
at `ERROR: invalid instruction 0xc2d9 at 0x8a2d`, reached from
`0072ac FCMINSSL+02f0: 6bed MVH 3,5`. Full-width tracing shows R0–R7 **all**
changing at once with a new PSW — that is an interrupt with a register-set
switch, not a move. `MVH` faulted, the trap dispatched through PSA `0x0048`/
`0x004C`, and landed at `0x0a3b`, which is `PCH` in `BILDNEW5` — GPCIPL's own
program check handler — except that phase 2's LB2 (`0x676..0x2ea5`) has by then
**overlaid it**, so the "handler" is PASS data, which promptly executes
`BC 7,X'8a2d'` into the error-environment stack and dies on `0xc2d9`. Chasing
`0x8a2d` or `0xc2d9` as a missing opcode is chasing the wrong end: `0xc2d9` is
data, legitimately written by the SSL's own move loop (watchpoint: `c9fb → c2d9`
at NIA `0x071bd`). Two traps here for anyone reading a post-load trace: **after a
phase-2 load the low-memory symbol names are stale** — the trace labelled PASS
code "GPCIPL+0a3b" only because GPCIPL's symbols were the ones loaded — and
**sectors are 32K, not 64K** (`psw_get_nia` does `(BSR << 15) | (nia16 &
0x7FFF)`), which is what put real data at `0x8a2d` and made the wrong reading
plausible.

`YAGPC_INTTRACE` (every interrupt with its PSA slots and new PSW) and
`YAGPC_PROTTRACE` (protection violations with the faulting NIA and address)
together turned that into a one-line diagnosis and should be the first thing
reached for next time.

### 8.15 The fullword alignment mask — an unresolved conflict (RESOLVED, see §8.16)

> **Resolved 2026-08-27.** The conflict below is real and every measurement in
> it stands, but the whole argument was conducted from the wrong manual: the
> AP-101 C/M masks bit 15 for fullword operands and the **AP-101S does not**.
> §8.16 has the quotation, the matching `ISPB` change, and the four successive
> wrong conclusions this one error produced. The account below is kept because
> the facts it establishes — the struct layout in the original build, the
> phase-2 load-block list, the three alternating pairs — all survive the
> conclusion they were gathered for.

This is where the boot stood when it was written, and it is written up in full
because four plausible explanations had been ruled out and the remaining
question needed the POO rather than more measurement.

**The symptom.** `FCMMOVE` (`0x72a1`) reads its move parameters from a BCE
context struct with `L 3,X'0000'(0)`, and the load returns zero where memory
plainly holds `0x00000008`. `CC` confirms it independently of the register
display — the load sets CC 1→0, and `0x00000008` would set CC=1. `CC` itself is
not broken and needed no fix: `exec_L` computes CC on whatever it loaded, and it
loaded zero. The defect is one instruction earlier, in forming the address.

**The mechanism.** `cpu.c`'s SRS path does `ea = base + disp;` then
`if (v->addrWidth == 2) ea = ea & 0xfffe;`. R0 holds `0x733f` — `FCMCTXT2` — so
the fullword load is forced down to `0x733e` and reads `FCMCTXT1`'s last halfword
joined to `FCMCTXT2`'s first, which is `0x00000000`. Exactly the observed value.
The fullword load is deliberate: it grabs struct offsets 0 and 1 together,
`TFCMTGTA` (address) and `TFCMTGTS` (sector), because that pair **is** the
address-constant format `LXAR` then splits into a register plus a DSE. With
`TFCMTGTS = 8`, DSE(R3) should be 8 and the destination `0x40000`; reading zero
gives `LXAR` a zero constant, from which it correctly derives a zero DSE, and the
move goes to 0.

**What has been ruled out:**

1. **That the real build places the structs differently.** It cannot. Computing
   the work area from `FCMINSSL`'s own declarations — `FCMSVR0..7` 8F,
   `FCMIBLK1` and `FCMIBLK2` 10F each, the INSST/IZCON/MBASE trio, `FCMRSADD`'s
   2Y + 3F + three address pairs, four status halfwords, `FCMLBRTB` 2F — puts
   `FCMCTXT1` at offset 86 and `FCMCTXT2` at offset **93** from `FCMDATA`, which
   is `DS 0F` and therefore always even. **`FCMCTXT2` is at an odd halfword in
   any build there has ever been.** Our link's `0x7338`/`0x733F` match exactly.
2. **That our sequence count reaches the odd struct when the real flow would
   not.** `FCMNEXTS`/`FCMCURRS` toggle 0↔1 normally via `XIST X'0000'(0),X'0001'`,
   so every other above-128K sequence legitimately lands on the odd struct.
3. **That the interrupt path mishandles the fault.** It does not, and the flight
   software *validates* it rather than merely tolerating it — see below.
4. **That the load is happening before a self-test that should precede it.**
   Table 2-2 step 11 does make STP a precondition, so it was worth checking, but
   the ordering is not close: STP's cycle ends at step 6,521,569 (`STPCYCNT` 0→1
   at NIA `0x00835`), `REALTIME` (`0x36c9`) is set at step 6,522,288, and
   `FCMMOVE`'s failing `MVH` is at step **22,762,631** — sixteen million
   instructions later. `STPCYCNT` is a count, not a verdict (incremented
   unconditionally); what gates the path is `TH X'36c9'`. And Table 2-2's
   1 m 25 s is a *duration* — STBY to RUN talkback for a default load — not a
   delay before starting one. Our run reaches the phase-2 read at 18.6 s of
   emulated time, so there is no evidence of racing ahead of a timed wait.

**On (3), because it was asked directly and is now measured.** All five
protection violations in a boot dispatch identically and correctly: old PSW →
`0x0048` (`FCMBPCO`), new PSW ← `0x004C` (`FCMBPCN`), `newPSW = 0a3b0011`, and
the store is suppressed as well (`exec_MVH` aborts on `!cpu_store_hw`, the POO's
forced ENDOP). The four deliberate ones sit at `SVC076`, `SVC194` and
`CLCK2000+0xA` and the boot continues past every one — but "it continued" is weak
evidence and the user was right to push on it. The strong version is the full
cycle, traced:

    000bf5  LA  3,X'00db'(0)   R3 = 0x0c01     plant a resume address
    000bf7  STH 3,X'0005'(1)                   store it at [R1+5]
    000bf8  STH 5,X'02de'(1)                   DELIBERATE VIOLATION
    000a3b  PCH ... 18 instructions ...
    000a3d  LH  6,X'0005'(1)   R6 = 0x0c01     handler reads the plant back
    000a43  STH 6,X'0048'                      patch the OLD PSW's address
    000a47  NST 4,X'0048'      &= 0xffffefff   clear a flag in it
    000a58  LH  4,X'004b'      R4 = 7          the PROGRAM CHECK CODE
    000a5a  STH 4,X'000f'(1)                   stash it for the test
    000aaa  LPS X'0048'                        return via the patched PSW
    000c01  LH  7,X'000f'(1)                   resumes EXACTLY at the plant
    000c02  CHI 7,X'0007'      CC 1->0         code == 7, EQUAL

The self test plants a resume address, faults on purpose, and then **checks that
the program check code was 7**. Our old-PSW save, the code we report and the
resume address all satisfy it. That is the flight software validating this
emulator's interrupt behaviour, four times over. The fifth violation is fatal for
an unrelated reason: by then LB2 has overlaid `PCH` itself. The trap is not
mishandled — the trap should not be occurring.

**Why the mask cannot simply go.** Removing it — in both places, and in the data
path alone — stops the boot *earlier*: only 55 blocks read, phase 2 never loaded.
The fixtures cannot arbitrate either way: `test_cpu_instr_exec` gives
111180/111358 with and without, identical, so it does not exercise the mask at
all. And the mask's provenance is no help — `git log -S` puts it in "Initial
yaGPC2 commit, only at yaGPC level", inherited from `gpc` with no POO citation,
the same provenance the DSE rule carries.

**How it survived so long, measured rather than asserted.** Instrumented
(`YAGPC_ALIGNTRACE`, which prints every address the mask actually changes), it
changes an address **185 times in a whole boot** of ~22.7 million instructions,
and they cluster:

    40 each at 0x07b8, 0x07b9, 0x07c0
    16 each at 0x0072e, 0x0074e, 0x0074f, 0x00756
     1     at 0x072a4   <- FCMMOVE's load, the one that matters

It takes a deliberately odd-sized structure — `DS 7H` twice — to put a fullword
operand on an odd base. Everything else in the flight software is naturally
aligned, so nothing ever noticed. **And all 176 of the clustered resolves are
inside GPCIPL's own memory test** (`MEMTST12/14/15/33/34` in `BILDNEW5`), which
walks odd addresses on purpose and provokes protection violations on purpose.

**The faulting address is what sharpened this**, and it is why
`YAGPC_PROTTRACE` now prints `cpu->lastProtFaultAddr` alongside the NIA:

    WITH the mask:     PROTVIOL #5  NIA=072ad  addr=0051d
    WITHOUT the mask:  PROTVIOL #5  NIA=0074e  addr=000b1

`0x051D` is one halfword below `0x051E`, where phase 2's LB1 begins — so
`FCMMOVE`'s bad move had been **writing over the freshly loaded PASS image** from
`0x0FFF` downwards before faulting just beneath it. The boot was not merely
stalling; it was destroying the load.

The unmasked fault at `0x00B1` is *not* over-protection on our side, which was
the obvious suspicion. `ageharness.c`'s `psaRanges` carves out `{0x00b0, 0x00b1}`
("Counter 1 & 2 high halfword") as unprotected at IPL fill, so they start
writable; GPCIPL re-protects them itself, and violations #3/#4 at `CLCK2000+0xA`
are the clock test deliberately probing that it did.

**So the conflict is genuine.** `FCMMOVE` requires this SRS fullword form **not**
to align, GPCIPL's memory test appears to require that it **does**, and both use
the identical encoding — so no rule keyed on the instruction can separate them.
The narrow question for the POO is: *in SRS format with a fullword operand, does
the AP-101S force the effective address even, and if it does, how is `FCMMOVE`
meant to read a context struct that begins at an odd halfword?* One untried idea
is recorded rather than implemented: **masking the displacement term rather than
`base+disp`**, which would leave an odd base intact while still aligning a scaled
displacement. It is untested, and after reverting two changes made on
plausibility alone in this same investigation — making `MVH`'s destination honour
the destination register's DSE (premise false: `dse=0` was measured at the
failing move) and reading the fault as a missing `0xc2d9` opcode (it is data) — a
third variant was not worth trying on plausibility either.

**Do not remove the mask without resolving `0x074E` first.** With the data-path
mask removed, that is where PROTVIOL #5 moves to, and until it is known whether
that access is a genuine odd-base access the real machine aligns, or an address
computed one halfword short with the mask hiding it, removing the mask trades one
defect for another.

### 8.16 The wrong manual — the AP-101S does *not* mask bit 15

§8.15's conflict was real, every measurement in it stands, and the resolution
is that **the whole of it was argued from the wrong manual.** AP-101S
instruction set, section 2:

> "Unlike previous versions of this architecture, bit 15 of a base register is
> significant when addressing fullword data. **Fullword storage operands may
> now be located on odd address boundaries.** Programs which utilize this
> feature will not be downward compatible."

Everything cited for the mask — POO Figure 2-8 and its "the same fullword
address is obtained regardless of base bit 15" — is the **AP-101 C/M**, the
previous machine. The document is
`~/Desktop/sandroid.org/public_html/apollo/Shuttle/IBM-6246156 - Space Shuttle
Model AP-101 C, M Principles of Operation.pdf`; it OCRs usably with
`pdftotext -layout`, section 2 addressing running from about line 1250 to 2200
of the extraction and section 14 covering Automatic Index Alignment. It is an
excellent source for the wrong processor.

**`ISPB` changed with it, and that is why removing the mask alone broke the
memory test.** AP-101S 9.2, M1=001: "Reset the storage protection bits for
BOTH HALFWORDS IN THE FULLWORD SECOND OPERAND." On the S that fullword may
start odd, so the pair is EA and EA+1. `exec_ISPB` was using the C/M's "the
low-order bit of the EA should be 0 and will be ignored" and doing `ea & ~1`,
so GPCIPL's `MEMTST14` unprotected `0x00B0`/`0x00B1` and then stored to
`0x00B1`/`0x00B2` — faulting on a halfword it had never unprotected. The two
rules are a matched pair and had to move together.

Fixed together, the boot stops crashing:

| | before | after |
|---|---|---|
| stop | `invalid instruction 0xc6c6 at 0x0a3b` | `max steps reached` |
| `FCMMOVE` entries | 1, on the odd struct, corrupting | 2 — **both** structs complete |
| PROTVIOLs | 5 | 4, all deliberate self-test ones |
| blocksRead / wordsTaken | — | 280 / 116,666 |

**The fixture cost, and why correcting it was not "making the test pass".**
`test_cpu_ea` went 20447/20447 → 20181/20447. Every one of the 266 failures
was verified *first* to be a pure mask off-by-one — got == expected + 1, got
odd, expected even, 133 in `EA_FIXTURES` and the same 133 in `EA16_FIXTURES`,
with nothing else in any entry differing. Only then were those exact indices'
expected values corrected, by script rather than by hand. A note in
`test/cpu_ea_fixtures.h` records the AP-101S quotation and warns that the
generator (`test/gen_cpu_ea_fixtures.cjs`) derives from `gpc` and will
**reintroduce** the C/M values if it is ever re-run.

**Trap:** `make` does not rebuild the test binaries and does not track
`test/cpu_ea_fixtures.h` at all. After editing a fixture header the old binary
is silently re-run and reports the old numbers. Use `make test`, and compare
timestamps before believing an unchanged fixture count.

**The chain of wrong conclusions this one manual error produced**, recorded
because each was written down confidently at the time: the odd-struct read was
blamed on `lnk101` misplacing `FCMCTXT2`; then on the tape's load-block ordinal
parity; then on a latent defect in `FCMINSSL`; then on phase 2's content being
short. Each was disproved by measurement and each was a downstream symptom of
reading the C/M for an S. What forced the manual to be rechecked was the user's
reductio — software that flew for decades cannot fail to boot, and no machine
would copy three load blocks to address 0.

**Worth keeping from the wrong turns**, because the facts survive the
conclusions they were marshalled for:

- The struct layout is genuinely odd in the real build. OI301700's "as
  received" `SSSRC/FCMINSSL` is an original-build listing *with object code*
  (only OI301700 ships listings): `FCMLBRTB 0378`, `FCMNEXTB 038A`,
  `FCMNEXTS 038B`, `FCMCURRS 038C`, `FCMMOVRG 038E`, `FCMBF1CT 039E`,
  `FCMBCTXT 03A0`; `0037C FCMCTXT1 DS 7H`, `00383 FCMCTXT2 DS 7H`,
  `003A0 DC Y(FCMCTXT1)`, `003A1 DC Y(FCMCTXT2) = 0383`, `002E7 1B00
  L R3,TFCMTGTA`. Walking the DS chain reproduces every address, including a
  one-halfword pad before `FCMMOVRG` — which proves the original assembler
  aligns `DS F` exactly as ours does. With CSECT base `0x6FBC` that is
  `FCMCTXT1 = 0x7338`, `FCMCTXT2 = 0x733F`, **the exact addresses our link
  produces.**
- Three separate alternating pairs live in this code and conflating them is
  the trap: `FCMCTXT1`/`FCMCTXT2` (context structs, one per load block, chosen
  by `FCMNEXTS`/`FCMCURRS`); `FCMIBLK1`/`FCMIBLK2` (BCE receive-sequence *code*
  areas, via `FCMRSADD`); and the two 8K staging buffers (`FCMB1ZCN`/
  `FCMB2ZCN`, indexed by `TFCMSRC`). `FCMMOVE` spans the **third**.
- "Odd" was used for two unrelated things and the confusion was ours:
  `FCMCTXT2` sits at an odd *address*; load blocks have odd or even
  *ordinals*. Every load-block address is even — all 24 of the then-current
  phase 2 verified. Say "ordinal" and "address" explicitly, never just "odd".
- `FCMINSSL`'s top level is a loop over **phases** (`LFXI R4,FCMNUMPH`), and
  `FCMNEXTS`/`FCMCURRS` live in a work area zeroed **once before that loop**,
  not per phase — so the struct alternation runs continuously across all
  phases. `FCMNUMPH` differs by release: OI301700 = 2, OI340600 = 3.
- The `RS` extended branch is *not* masked, and an A/B settled that it cannot
  be decided from here: cpu EA/CC fixtures 20447/20447 either way, instr exec
  111180/111358 either way, boot byte-identical, with the control verified
  functionally (the probe went 53 hits → 0 with the mask and back to 53
  without). `YAGPC_RSALIGNTRACE` is kept so a discriminating case can be found
  cheaply if one ever turns up.
- A separate real bug was conflated with the mask and is worth keeping
  distinct: `ea & 0xfffe` is a **16-bit** mask applied to an EA already
  expanded to 19 bits, so it destroyed the sector (`3032a` → `0032a`).
  Whatever else is decided, do not reintroduce `0xfffe`; `ea & ~1u` would have
  been the sector-safe spelling.
- `ISPB`'s **halfword** forms are correct as written — over a full IPL, M1=0
  splits 204567 even / 204564 odd and M1=2 splits 145557 / 145546, so they
  genuinely address individual halfwords. Its index handling already matches
  the POO ("excluded from automatic index alignment"; `addrWidth=1` so the
  scaling is `<< 0`). The **fullword** forms remain an open conflict, gated as
  `YAGPC_ISPB_ALIGN=1` and **not** the default: aligning breaks the boot (55
  blocks instead of 281). Only 60 of 34,271 fullword-form ISPBs have odd EAs,
  all from three GPCIPL instructions, and a sector's last fullword
  (`x7ffe`/`x7fff`) is reachable from `x7ffd` under *neither* reading — which
  is why this is logged rather than decided.

### 8.17 The BCE `@`-family, and the one instruction where `gpc` and yaGPC2 diverge

**`#BU@` semantics, stated exactly:** compute `a + 2*BCE#`, fetch the
**fullword** there, mask to 18 bits, load it into the BCE's program counter. A
branch, no increment. For BCE 18: `0x72A8 + 36 = 0x72CC`, fullword
`0x000072F2`, PC = `0x72F2` = `FCMIBLK1`. `DC A(x)` assembles to a fullword —
the original listing shows `00310 00000336` against `00314 0336` for the
matching Y-con — so the entry is `0000 72F2` as two halfwords, and that leading
`0000` is exactly what `gpc` executes and cannot decode when it branches *to*
the entry instead of *through* it.

**Measured, this is the only instruction at which the two emulators differ in
a whole boot.** `YAGPC_BUATTRACE` prints both candidate targets:

    BU@ #1 bce=18 table=072cc entry->072f2 (gpc would go to 072cc)

Total `#BU@` executions in a boot: **one**. Before it, nothing differs — memory
test, `REALEXEC`'s dispatcher, the display IPL, the DK-bus traffic all run
identically. After it, `wordsTaken` is 98,820 against 28,164 of 107,012:
yaGPC2 collects the blocks, `gpc` spins on a constant it cannot decode while
the transfer streams past. The CPU keeps running in both — the BCE is a
separate processor — so `gpc` does not crash; the load simply never completes.
That is precisely the old "same infinite loop, same address, identical
iteration counts" observation, seen from the other side.

**And the divergence is gated behind the SSL checksum**, which is why it
survived so long: unstamped tape (`SSLENGTH = 0`) gives 0 `#BU@` executions and
`wordsTaken` 28,162 — both emulators hang identically inside `SSLCHECK`'s
checksum loop, upstream of the only instruction at which they differ. **No
`#BU@` had ever executed in this project** until the checksum was stamped. A
comparison that stops short of the divergence cannot see it; that is a sharper
form of §8's opening lesson than "two emulators agreeing proves nothing".

**Four independent witnesses from the flight software**, which is what carries
the decision, since the POO's prose reads as direct and the 300 `#BU@` fixtures
encode a *third* behaviour (NIA = `a`, no bus offset) that neither
implementation produces:

1. `FIOBBM` is declared `DC 2F'0'` with the same `-36` bias — an array of
   fullwords, not code;
2. `FIOMGDSP.asm:750` writes addresses into it at run time, under a header
   calling it "MM BRANCH ADDRESS TABLE" ("STORE ADDRESS IN BCE ENTRY");
3. `MLIB80/BTBCEGEN.asm:564` comments its own `#BU@ FIOBTFLX` as
   **"INDIRECT BRANCH"** — the software naming the semantics outright;
4. `FCMBCEBT`'s `DC A(FCMIBLK1)` points at `DS 10F` scratch.

Scope: `#BU@` appears at 57 non-comment sites in OI340600, but all the MLIB80
ones (`FIOMFBCE`, `FIOHFBCE`, `BTBCEGEN`) are PASS code; in the IPL only
`SSSRC/FCMINBCE.asm:82` is reachable.

**`#LBR@` is the same defect and was fixed the same way.** `FCMBCEST` and
`FCMBCEBT` are the *same address* — the original listing has
`1169: 00002EC FCMBCEST EQU *-36` and `1172: 00002EC FCMBCEBT EQU *-36` — and
`FCMINBCE` uses both forms on it, `#LBR@ FCMBCEST` at line 67 and
`#BU@ FCMBCEBT` at line 82. Both must fetch through the table. Without the
fetch, BCE 18's base became `072cc`, the branch-table entry itself, and its
`#RDLI` wrote the received word over the `A(FCMIBLK1)` that the `#BU@` ten
halfwords later was about to read. Store protection had been refusing that
write all along (`072cc` is below `FCMDATA`, so the SSL's unprotect sweep never
reaches it), which preserved the entry and hid the bug — unprotecting those
four halfwords *without* the fix sends BCE 18 to `pc=00000`.
`test_iop_bce_exec` is 73499/74699 with and without, measured both ways, so
the fixtures cannot arbitrate here either.

**The same defect is in the count fetch, and that is §8.27.** `#BU@` and
`#LBR@` fetch a *branch target* through the table; `#TDL` and its relatives
fetch a *word count* from a table of the same shape, and were reading it as a
halfword. Fixing the branch forms did not fix the count forms, and the count
form is what was blocking PASS's displays.

**What the receive sequence does, dumped live at the moment `#BU@` fires:**

    FCMIBLK1 @072f2  #LBR 051e / #RDLI 344 / #DLYI 592 / #SST +22 / #BU FCMIBLK2
    FCMIBLK2 @07306  #LBR 0676 / #RDLI 1 / #RDLI 10240 / #LBR 2e76 / #RDLI 48
                     / #DLYI 1184 / #SST +08 / #WAT

Both terminators are in the source: `FCMINSSL.asm:752` `OHI R5,FCMMBU`
(`X'F000'`, unconditional branch) ends a sequence with a successor, and `:727`
/`:760` `LHI R4,FCMMWAT` (`X'0800'`) ends the last. So the two buffers chain to
each other alternately and `#BU@` is a **one-time entry point, not part of the
loop** — which is why exactly one executes despite 21 load blocks and 209
blocks read. The `#LBR` operands `0x051E` and `0x0676` are phase 2's first two
load-block start addresses, an independent cross-check that the decode is real.
`c250 5022` is *two* single-halfword instructions packed in one fullword
(`#DLYI` + `#SST`), which is why `FCMINSSL` writes the fullword with
`ST R4,0(R2)` and then patches only the second halfword with `STH R4,1(R2)` —
deliberate, not suspicious.

**After `#WAT` the BCE stops.** BCE POO §2.2 (the AP-101S manual carries it as
Part III) states both the halt and the PC behaviour our code already had:

> "a BCE's Program Counter need not always be set before the MSC sets the BCE
> to busy, since the BCE Wait instruction (#WAT) when executed, leaves the PC
> pointing to the next sequential instruction. This next instruction may be
> programmed as a simple branch to the beginning of the next BCE program
> segment. In this case, the MSC need only execute an SIO instruction to
> restart the BCE at the next segment."

So `exec_WAT` was already right and is now cited: clearing `regBusyWait` is
what stops execution, and `iop_incr_nia(t,1)` is the *defined* behaviour that
makes the restart idiom work. Also from the same section: "While a BCE is in
the Wait state, the CPU may perform PCI/O activity without disturbing the BCE";
"The Busy state may be entered only from the Wait state"; and "The CPU cannot,
however, directly set a BCE's Busy/Wait bit" — only the MSC's `SIO`. That last
sentence is what makes a parked BCE with a parked MSC a genuine deadlock.

The SSL does **not** use the restart idiom — the halfword after its `#WAT` is
`0000` — so the PC is reloaded per program. `YAGPC_PCTRACE` shows BCE 18's PC
loaded five times in a whole boot: `30240` and `3024c` (FCMBOOT, t=2.11 s and
2.31 s), `014d4` (GPCIPL's all-BCE sweep, t=4.30 s), then `07362` and `0736c`
at t=18.46/18.62 s, which are `FCMINBCE` and `FCMINBCE+10` — matching
`FCMBCEAD`'s own pair of `DC A(FCMBCMMR)` and `DC A(FCMINMMP)`.

**Why no `gpc`-vs-yaGPC2 differential harness was built** — asked for, assessed,
and declined with reasons, because the user's principle (force two supposedly
identical programs to contend) is right and the refusal needs to be more than
cost. Fixing `gpc`'s `#BU@` buys exactly *one instruction*: the next thing the
receive sequence executes is `#DLYI 592`, and `gpc`'s `#DLYI`/`#DLY` are
explicit no-ops — the exact defect that broke FCMBOOT's phase-10 load until
`14a7b7581`, where the SSL skips each partial block's unread tail *by delaying
over it*. `gpc` also lacks the MIA-latch ordering fix (`82fb09d3b`), the
unread-transfer-tail fix (`629694ebf`), and any `--mmu-model` at all (its mass
memory is a separate device process on the multicast bus). The decisive reason
is not the cost but that **we would be writing the oracle**: to reach the
failure, `gpc` needs `#DLYI` with bus-data discard and a progressive bus —
the exact behaviours under test. Implement them as yaGPC2 does and agreement
proves nothing; implement them differently and disagreement only shows two
different things were written. Differential testing earns its power from
independence, and yaGPC2 is a *port* of `gpc`: their disagreements are
precisely our changelog. `yaHALMAT2`, which genuinely is independent and is the
real bug-finder elsewhere, executes HALMAT rather than AP-101S machine code and
cannot run GPCIPL at all. So the primary documents have had to be the oracle,
and the ledger supports it — POO Figure 2-8, the OI301700 listing, `FIOBBM` and
`BTBCEGEN`, the `0x710b` probe, the `FCMIBLK` dump, the BCE POO. Every wrong
turn came from trusting *derived* artifacts: fixtures, stale builds, our own
notes. **Condition for reversing this:** if the build-side line runs dry *and*
the next question turns out to be about emulator behaviour rather than the
tape, on a case where the two could genuinely disagree.

### 8.18 Completing phase 2 — a stale compiler and two extensionless-member traps

Phase 2 was short of the real build's upper-memory content, and every
explanation offered for it was wrong until the cause turned out to be the
compiler binary.

**51 of 274 modules were being abandoned at compile time.** The SSW CON80 deck
*is* phase 2's definition ("PHASE 2 APPLICATION PDE'S", "PHASE 2 PROG'S",
"PHASE 2 STACKS"): 285 INSERT members, 213 present, 72 missing, of which 38 had
sources (23 distinct modules) and 34 did not. The 23 are exactly the sector-8
occupants the DASS dump has and we lacked: `AIESIP ARBIDL ARCGPC ASMAUX DMCSUP
DMIMCD DMTERR DUPNSP DM1KEY DM2APP DM3DIS DM4DEU DM5NEW DM6OPS DM7REQ DMNNEW
DMMMCD DNXBMS DXXCSE ARGREC DISPLA DCDDOW ASISPE`. The failures were real
compile errors, not tooling noise — `ARCGPC` gave 13 severity-2 errors ending
"COMPILATION ABANDONED" over an undefined `CANB_ANN_MSG_BITS`.

**Root cause: `halsc` runs a stale compiler by default.** Line 57 is

    HALSFC_BINDIR="${HALSFC_BINDIR:-/home/rburkey/donschmidt/nsts-sdl-dps/build/halsfc}"

so it uses Don's own pass binaries (dated 2026-07-21) rather than the Virtual
AGC archive's `Source Code/PASS.REL32V0` (2026-08-07), which is upstream of
them and *does* accept `--sdfi`. Setting `HALSFC_BINDIR` to the archive builds
the whole phase. The A/B has one variable — identical `con80build` command,
same `--root`, same cleaned `--out`: without it, 70 zero-length objects and a
failed link; with it, 0 zero-length, 6/6 displays, 239 objects linked.

Two corrections attach to this. First, **an upstream blocker was declared on
the strength of tests that never ran** — `build/bin/HALSFC-PASS1` does not
exist (the binaries are in `build/halsfc/`), and `grep -c` returning 0 on a
nonexistent binary was read as evidence; then
`$P --help | grep sdfi | head -3 && echo ACCEPTS` fired the `&&` branch because
the exit status is `head`'s, not `grep`'s. Two invalid tests in a row, both
pointing the same way, produced a confident "blocked on Don" that was wrong.
Second, **the `REL32V0` banner is worthless as a version**: it comes from the
original 2008 XPL/I source, so every port of the compiler prints it. Only the
build date distinguishes copies, and by provenance a build from Don's repo can
never be ahead of the archive's. (Recorded in memory as
`feedback_halsfc_bindir_use_virtualagc_archive`.)

**Two extensionless-member traps, in two different places in `con80build`.**
This is the recorded SDL-tooling hazard — the tools assume extensionless
members and PFS added `.asm`/`.hal`/`.dfg` — and it bites twice:

- `_PATCH_SRC_RE = re.compile(r"^PCH\d+SRC$")` is anchored with no extension,
  so `PCH02SRC.asm` never matches, patch decks are never indexed, the plan
  reports "0 patch", and 10 members go unresolved. The machinery works —
  `patch_member("PCH02SRC")` → `PCH02TXT` and `patch_csects()` finds all 29
  names — the index simply never reaches it.
- `SourceIndex.by_name` is keyed on the **full filename**, so
  `resolve("FCMBMASK")` never matches `FCMBMASK.asm` and every module falls
  through to a **6-character stem index** built with `setdefault` over a sorted
  listing. Where two files share six characters the alphabetically first wins,
  and the wrong path is then dropped by the `if path in seen` dedup, so the
  real module is never built. All 13 then-missing modules were such
  collisions, verified one by one: `FCMBMASK/FCMBMAN`, `FCMBUSPC/FCMBUSCM`,
  `FIOERRLB`+`FIOERRLC/FIOERRLA`, `FIOMGCV/FIOMGCMP`, `FIOMGSTR/FIOMGSNC`,
  `FIOSVCP/FIOSVC`, `FPMCVTFX/FPMCVTFL`, `FPMIHPGM`+`FPMIHPC2/FPMIHPC1`,
  `FPMRESET/FPMRES`, `FIOPDISP/FIOPDIPG`, `FPMMTURM/FPMMTUFX`.

Both are fixed without touching Don's repo, by scratch trees of extensionless
**symlinks** — every `SSSRC` (423) and `APPLSRC` (1149) member, plus all 47
`PCHnnSRC` decks — passed as extra `--src` directories ahead of the real ones.
`resolve()` then hits `by_name` exactly and never reaches the stem index. A
first attempt that *stripped* `--sdfi` with a path shim made things worse (119
members lost objects instead of 5) and was removed: `halsc:257` falls back to
the `--sdf` directory when `--sdfi` is absent, and `con80build` passes that as
the per-compile *output* dir, so stripping the switch repointed template
resolution at an empty directory rather than removing it.

Two more invocation facts: use `--phase 2`, **not** the bare `SSW` target
(`--phase` builds PROLOGUE + PHASE SEGMENT and writes `PHASE02.lib`; the bare
target builds only the segment and drops all the `FCM*`/`FIO*`/`FPM*` prologue
modules), and the link needs `PHASE01.lib` present in `--out` for the deck's
MAP cards.

**Result — phase 2 complete for the first time:** 155 ASM, 120 HAL, 7 displays,
1 patch, 0 unresolved; 314 objects linked; 660 sections; 340 modules; deck
members unaccounted **0**, having gone 72 → 22 → 13 → 0.

Along the way, the **unbuilt phases** question was answered precisely: 35 of
the 52 in the manifest are "not built", but they are almost nothing — PHASE 22
(`GMAIMUC1`, card 42506) at 2 blocks, and phases 27–60, all `SMARDPnn` at 3
blocks each, every one carrying `SUBSYS=RID` on its ALLOC card: Reconfigurable
Item Data patch slots, data rather than code. Total unbuilt: 104 blocks against
1085 then on the tape. Separately, phases 23/24/25 have `.lib` files and PHASE
cards but never appear in the manifest (they are `MOVE=NO` with explicit
`LBLN`/`LBNO`); phase 26 has a `.lib` and no PHASE card; phases 11, 17 and 19
have `.lib` files and no PHASE card; and phase 1 is not a program phase at all
but the MM directory (`VMARPLDU DIRECTRY,SIZE=2,ENTRIES=510,DMMD=NO,PH=1`).

### 8.19 What the ground Mass Memory Build wrote, and our toolchain did not

A family of four defects, all the same shape: our toolchain reproduces the
assembly and the link faithfully, but not the ground Mass Memory Build's own
choices about **what becomes a load block**. Each was found by a different
route and each blocked the boot in a different place.

**1. `FCMPSA` — PASS's own PSA CSECT — was dropped.** `SSSRC/FCMPSA.asm`
declares the whole interrupt vector table:

    FCMPSA   CSECT
             TFPSA CSECT,PON=0,POF=0,SR=FCMINSSL,MC=0,PC=FPMIHPGM,
                   SVC=FPMSVC,PC1=FPMIHPC1,PC2=FPMIHPC2,IM=FPMIHIM,
                   EI0=FIOERRLA,EI1=FIOERRLB,EI2=FIOCMPLT,EI3=0,
                   SI=FCMLINIT,DSR=0,BSR=0,PD=NO,

It is at halfword 0, 422 halfwords, present in `PHASE02.lib` and byte-identical
to the flown article. `mmbstamp`'s `derive_load_blocks` discarded any extent
ending at or below the phase's Z1 pool cursor — a rule that exists to drop Z1
ZCON pool re-supplies from a parent phase — and a CSECT that legitimately lives
at address 0 is caught by the same `e <= pool` test.

That one drop accounted for **four** symptoms that had been chased separately
for days: `0009c` staying protected (the missing block is exactly what
`FCMUPROT` would have unprotected before loading it); `TPSASINP` still holding
GPCIPL's own `Y(EX4)` instead of `SI=FCMLINIT`; every PSA vector keeping
GPCIPL's addresses (`004c = 0a3b` instead of `ad5c = FPMIHPGM`); and the
`invalid instruction 0xc6c6 at 0x0a3b` crash, which is the third symptom being
dispatched through. **The "missing MM-build stamp" hypothesis was wrong** —
nothing stamps `TPSASINP`; it is simply assembled into a CSECT we failed to
load.

The vectors are the strongest single validation of our phase-2 addresses.
Resolving the DASS dump's interrupt vectors (16-bit, BSR=3 when the high bit is
set) against our own `PHASE02.lib` symbol table hits a symbol at **offset +0
every time**: ProgChk `ad5c` → `FPMIHPGM`; SVC `b13a` → `FPMSVC`; Clk1 `ad24` →
`FPMIHPC1`; Clk2 `bed6` → `FPMIHPC2`; EX0 `9a30` → `FIOERRLA`; EX1 `9a58` →
`FIOERRLB`; EX2 `b480` → `FIOCMPLT`; SpecInt `47e0` → `FCMLINIT`. Nine vectors,
nine exact symbol starts.

**2. `FCMRESRV` — reserved load blocks carry no tape data.**
`FCMINSSL.asm:1111` `FCMRESRV EQU X'2000'  RESERVE LOADBLOCK MASK`, and the SSL
tests it three times, skipping the block each time: the MM block count (`:496`,
"RESERVE FLAG OFF (LB DATA ON MM)?"), the BCE transfer setup (`:584`) and the
checksum pass (`:842`). So a reserved load block **reads no tape, transfers
nothing and is not checksummed** — it is purely a descriptor carrying address,
length and protection, and it is still walked by `FCMUPROT`/`FCMRPROT`, which
is what clears the store-protect bit `GPCERAS` set. `LoadBlock.words()` built
its flags as `0x0600 | sector<<4` plus `0x8000`/`0x4000` and had **no way to
express `0x2000` at all**.

The flown article confirms the block to the halfword.
`DASS_SSW_(PostIPL).ASC:1277-1280` brackets `#PCVNMMU` with
`*** BEGIN RESERVED CSECT ***` / `*** END RESERVED CSECT ***` and shows a
load-block checksum tail at `03432C-03432D` immediately after it; a block
synthesised from the deck card and CSECT size alone gives start `030322`,
length 16396, tail `03432C..03432D`, next block at `03432E` — exactly where
phase 3's observed block starts. Four independent lines converge: the deck's
`RESERVE` card, the era-original MAFGEN annotation, the image's checksum
boundary, and the arithmetic. (That annotation is from the **original 2010
MAFGEN report**, not our own `mafgen/` imitation of it — a `grep` that returned
nothing was misread as having matched because an `ls` in the same command
printed filenames after it.)

With `LoadBlock.reserved` added and `pack_mm` charging a reserved block **zero**
MM blocks, the acceptance test passes with no injection and no patches, tape
unchanged at 2500 blocks: blocksRead 281 → **400**; `wordsTaken/wordsOut`
117178/143876 → 204812/204812; words lost 26698 → **0**; DMA violations 7170 →
1 (an unrelated early `addr=00002`). Phase 2 goes to 28 descriptors with
`ncont=226, crossed=False` — no budget overflow, because the reserved block
costs no MM blocks. Every earlier explanation of the 58-block failure was
wrong for one root reason: the descriptor was emitted **without** the flag, so
the SSL tried to read 33 tape blocks that do not exist. Specifically withdrawn:
"budget overflow → layout corrupt" (`crossed` is a *track*-boundary flag from
`pack_mm`, handled by setting `sot`, not a budget signal) and "the tape carries
no content" (a correct observation with the wrong significance — it should not
carry any).

**3. Phase 2's Z1 ZCON pool was never emitted**, so PASS ran with GPCIPL's
Z-cons. `derive_load_blocks` emits the pool as `[pool_start, pool-2]` but only
sets `pool_start` when `s >= parent_pool`; `POOL_PARENT` has no entry for 2, so
`.get(2, 2)` makes **phase 2 its own pool parent** and `parent_pool` becomes
phase 2's own cursor (`0024a`). Its own pool starts at `001a8`, below that, so
the test was never true. Child phases were unaffected, their pools sitting
above the parent's cursor.

This one needed a new instrument. A wild branch is invisible to every other
trace — the interrupt log shows only where execution *arrived*, and `--trace`
over ~200M instructions is unusable — so `YAGPC_NIARING=<n>` was added, a ring
of recent instruction addresses dumped at the Instruction Monitor and at the
invalid-instruction stop. It gave `... 40078 40079 4007a | 44723 ...`, so
`0x4007a` had branched into `#CDCDDOW`, a data CSECT. `0x4007a` holds
`D0FF 39CC`, which the emulator's own disassembler renders as
`SCAL 0,@@X'01cc'(1)` — a call fetching its target *through* a Z-con at `01cc`,
inside the Z1 pool, and the only load block covering it belonged to phase 10.
The same region had been flagged hours earlier as a 158-halfword mismatch
against the DASS dump, "our values and DASS's, the same values in a different
order"; two symptoms of one cause, not connected until the ring named the
instruction.

**4. `parent_pool_lo` was passed by one caller and not the others — and that
one was ours.** After the `FCMPSA` fix, phase 3 got 11 blocks on tape against
10 in the phase table, so the SSL read the tape displaced from that block
onward and every following block failed its checksum. Sweeping for callers
rather than assuming found three sites, two of them missing it:

    ap101Utils/mmbstamp.py  phase_load_blocks   had it (the FCMPSA fix)
    tools/mmu2mmv.py        phaseRecord         MISSING -> fixed
    ap101Utils/fcmImage.py  _lb_slots           MISSING -> fixed

`fcmImage`'s own docstring states the invariant the omission broke —
"`mmbstamp.derive_load_blocks` is the single definition of the partition" —
which holds only if every caller passes the same arguments; and it feeds
checksum-slot detection, so it would have skewed the very tooling used to
verify the tape. All four phases now agree table-vs-tape: 27/27, 10/10, 5/5,
2/2. **Design smell worth fixing properly:** `parent_pool_lo` is derivable from
what every caller already has (`pool_low_hw(parent_lib, parent_pool)`), so
making it the caller's responsibility guarantees this drift.
`derive_load_blocks` should take the parent LIB and compute both itself. Not
done — a wider change to Don's code.

**The systematic check that would have caught all three drops on day one**, and
which is three lines: list the extents present in a phase's `.lib` but covered
by no load block of that phase. After the fixes it reads PHASE10 0, PHASE02 0,
PHASE13 0, PHASE03 1 (`001fe..001ff`, 2 halfwords). Re-run it after any change
to `derive_load_blocks`.

**Where these fixes live.** All three are **local, uncommitted** changes in
`~/donschmidt/nsts-sdl-dps` (HEAD `755a372`), by the user's instruction — no
commit there and no PR. Verified still present: `parent_pool_lo` in
`src/ap101Utils/mmbstamp.py` and `src/ap101Utils/fcmImage.py` and
`src/tools/mmu2mmv.py`, and `reserved` in `mmbstamp.py`. Note the path:
`mmu2mmv` is under `src/tools/`, not `src/ap101Utils/`.

**The volume recipe is FIVE steps, not two.** Two were being omitted, and each
omission produced a *bit-identical wrong answer* rather than an error:

    1. mmu2mmv --con80 <CON80> --mmu <tree> --out V.mmv
    2. stamp_ipl_phase_table.py <tree>/PHASE01/PHASE01.fcm --mmu <tree>
       --con80 <CON80> --sdl <dps> -o BOOT.fcm
    3. stamp_ssl_checksum.py V.mmv
    4. stamp_bootstrap_on_tape.py V.mmv BOOT.fcm
    5. add_sysid_allocs.py V.mmv --con80 <CON80> --sysid SYS8

Step 2 matters because `BOOT-stamped.fcm` carries FCMBOOT's own map
(`FCMPTAD1/2/3`), so a rebuilt tape without a re-stamped table is navigated by
the **old** layout; a PHASE01 built from source leaves all three 256-halfword
areas holding the `X'FFFF'` "never mass-memory built" sentinel, and the tool's
own docstring predicts the result exactly — "walks all three areas, finds FFFF
in each, and lands in its documented give-up wait state having never touched
the bus", which is precisely the measured wait state at `30220` after 13.8 s
with zero tape reads. Step 3 matters for the same reason at the SSL level.
`stamp_ipl_phase_table.py` needs `--sym`, and the image to stamp is
`<tree>/PHASE01/PHASE01.fcm` with `PHASE01.sym.json` beside it.

**The lesson, and it is the same one twice: `tools/` already contained the fix,
with a docstring naming the exact symptom.** Both `stamp_ipl_phase_table.py`
and `stamp_ssl_checksum.py` were written for precisely the failures that were
then rediscovered from memory dumps over hours. Read the tools before chasing
the bug.

The `FCMCKSUM` case is worth keeping for its method: a matched-simulated-time
memory diff showed only 109 differing halfwords, two of them in `FCMCKSUM`
(`07398 ref=0326 mine=0000`, `0739b ref=cb2c mine=0000`); searching the
reference's own image for a region whose 16-bit sum equals `cb2c` found exactly
one, 806 halfwords at `06fbc`, which is `FCMINSSL`. Our own `FCMINSSL` sums to
`cb2c` too — the SSL was always correct, only the stamp was missing.

**Two build facts that cost time and are easy to get wrong.** `BOOT-*.fcm` is
**not** `PHASEnn.fcm` — the sizes match (65024 bytes) and they are not the same
artifact; `BOOT-900.fcm` is a *stamped* PHASE01, which the stamper reproduces
exactly when fed the same tree. And decode load-block addresses as
`(sector<<15) | (addr & 0x7fff)`, **not** `(sector<<15) | addr`, which shifts
every sector≥2 block by `0x8000`.

**Withdrawn along the way, and worth recording because the reasoning was
circular:** a load block was ruled out for `#PCVNMMU` on the grounds that the
DASS dump shows the region 100% `C6C6`. But `C6C6` **is the tape's own fill**
(`STACK_FILL_BYTE = 0xC6`, `INIT=C6C6` on every `MMUDATn` ALLOC card,
`lnk101 linker.py:59-63`), so a load block carrying fill produces exactly the
dump content used as evidence against one. The dump cannot distinguish the two
cases. Relatedly, `latest.unlinkSSW_(PostIPL)` is an **unlink of the DASS
reports** — a reconstruction of the *loaded image*, not a live RAM snapshot —
so it can never testify about what execution wrote.

### 8.20 The IOP must be paced by simulated time, not by CPU instruction

`ap101_exec1` ran one `iop_exec` per CPU instruction. `FCMMOVE`'s
7,654-halfword `MVH` is a *single* emulator instruction that charges about
6.7 ms of POO time, so it froze the IOP while the simulated clock ran:

    BCE18 #SST                       t=23664142.0
    MVH dest=41c00 src=3232a c=7654  t=23664144.8
    BCE18 next instruction (#BU)     t=23670877.3   <- 6732 us later

That loses a halfword because **the SSL positions the BCE mid-gap on purpose.**
`FCMSSLBS` computes its delay as `639 - partial = (511 - partial) + 128`, its
own comment naming the constant: "128 = ONE HALF THE MMU BLOCK GAP IN HALF
WORDS". The one-word "CLEAR THE MIA BUFFER" `#RDLI` that follows is therefore
*meant* to execute inside the gap, with nothing on the bus, and take the stale
latch. Resuming 6.7 ms late, it took block 796's first real word instead, so
the block landed one halfword out of phase and failed its checksum.

**The rate is derived, not fitted.** `iopls_next_slice` cycles 33 slices so
each BCE gets one per cycle, and the AP-101S manual's Part III (the BCE POO)
§3.4.1 says a BCE samples its MIA buffer "at most once every 16.5 usec".
16.5 / 33 = 0.5 exactly, and 16.5 µs is already `MTO_TICK_US` in the code.

**What actually does the work is the back-dating, not the rate.** Each slice is
taken with `cpu.elapsedTimeUs` **set to the time that slice falls at**, and the
CPU's value restored afterwards — catching up in slice *count* alone fixes
nothing, because what the bus cares about is *when*. Verified: the outcome is
identical for pass intervals of 0.16, 0.25, 0.35 and 0.5 µs.

Result, same tape and command:

| | before | after |
|---|---|---|
| clear-reads that stole a real word | 3 | **0** |
| `FCMECNT` / `FCMCKERR` | 3 / `ffff` | 0 / 0 |
| outcome | three checksum retries, halt at `FCMSSLEX` (`SSM FCMWAIT`) | **phase loop exits normally, handoff begins** |
| blocksRead | 730 (inflated *by* the retries) | 321 |

The apparent drop 730 → 321 is not a regression: the old figure was three
attempts at a block that never checksummed. Reversible two ways —
`git revert` (it touches only `ap101.c`/`ap101.h`), or `YAGPC_IOP_PER_INSTR=1`
at runtime, which reproduces the old behaviour bit for bit;
`YAGPC_IOP_PASS_US=<f>` overrides the interval.

**Two things ruled out first, each by measurement.** The MIA model is *not* at
fault: `YAGPC_CLEARTRACE` shows almost every clear-read taking `c6c6` — fill,
i.e. a genuinely stale word, which is the point of the instruction — and the
one that took a real word completed *the instant it was armed*. The AP-101S
manual's Part III §3.4.1 settles the semantics in our favour: "once an entry is
placed in the MIA buffer it stays there until either the BCE removes it **or
the MIA overwrites it with a new value**", which is exactly `mia_get_data`'s
live-over-latch rule. And "missing MMU read latency" was not the problem
either: `YAGPC_MMUTRACE` with timestamps shows only **two** read commands in a
whole boot — 55 blocks at t=2.34 s and 225 blocks at t=18.93 s — with the
entire PASS load streaming from that single 225-block transfer, the failing
clear-read 4.7 s into it. A one-block-gap lead-in for fresh bursts was tried
and reverted: principled, but the read command precedes the clear-read by about
20 ms and the gap is only 8.45 ms. (`mm_log` now timestamps every line. Every
question about this unit has turned out to be a question about *when*, and an
untimed log cannot answer one — the two-read-commands finding was invisible
without it.)

### 8.21 Store protection, traced end to end

The SSL's DMA into its own staging buffer was being silently refused, and the
chase for it produced more withdrawn conclusions than any other thread in this
section. The answer is that **the flight software protects everything itself**,
so our loader's protection model turned out to be irrelevant.

**The chain, each link measured:**

1. `GPCERAS` (`GPCERAS.asm:257-261`, the `GPCWR20` loop) unprotects, fills and
   **re-protects** every halfword of sectors 0-15 at t≈11.35 s:
   `ISPB 0,0(R5,Z3)` / `STH R6,0(R5,Z3)` / `ISPB# 2,0(R5,Z3)` / `BCT`.
   `DSRLIMIT DC X'000F'` (`STPDATA.asm:1027`) = 15, so sector 6 is legitimately
   inside its range — our emulation is **not** overrunning.
2. The SSL's BCE DMAs into `#PCVNMMU` at t≈22.96 s.
3. Nothing between them unprotects it. `FCMUPROT` only ever opens **load-block
   destinations** — it takes a 3-halfword descriptor in R1, builds a Z-con from
   it and walks `ISPB@# 0,0(R2,R1)` down the length (`FCMINSSL.asm:1140`
   `FCMIZCON DS F   CHECKUM/UNPROTECT/PROTECT ZCON`) — and the staging buffer
   is not a destination.
4. A load block covering the buffer with protect=0 *would* unprotect it in
   exactly that window, because `FCMRPROT` re-protects only per the block's own
   flag.
5. `mmbstamp` emitted no such block, because the CSECT has no data extent — see
   §8.19's `FCMRESRV` fix, which is what finally supplied it.

**Confirmed by prediction rather than by fitting**, which is what turned an
apparently absurd "timing-sensitive protection bit" into a window: unprotecting
at t=12,000,000 and at t=18,765,000 — 6.7 s apart, both inside the window —
gives *bit-identical* outcomes (400 blocks, `wordsTaken == wordsOut == 204812`,
same halt); outside it (t=1000, t=60,000,000) both give 281 blocks with 26,698
words dropped.

**What `FIOMUWB2` actually is**, since it was repeatedly mis-sized:
`APPLSRC/CVNMMUTI.hal:51` `EQUATE EXTERNAL FIOMUWB2 TO CDHV_BLOCKS$(1,1)`, and
`INCL80/CSMCOM.hal:58` `1 CDHV_BLOCKS ARRAY(CSM_ROWS,CSM_COLUMNS) INTEGER`
inside `STRUCTURE CDHV_RW_BUFR RIGID`. `CVNMMUTI.hal:29-31` sets `CSM_ROWS 32`,
`CSM_COLUMNS 512`, `CSM_ARRAY_SIZE 16384` — 32 × 512 = 16384 halfwords = thirty-
two MMU blocks of 512. **Other compools size it differently** (`CVQMMUTI` 8
rows/4096, `CSAMMU` 26 rows/13312), so never assume the size; read the compool
in question. It is reached almost entirely through the HAL/S `NAME` construct,
i.e. as a pointer to the whole array, and the equate to `$(1,1)` merely yields
the base address — which is why `FCMB1ZCN` and `FCMB2ZCN` are two pointers, to
offsets 0 and 8192. Walking the declaration gives 8 halfwords of header, then
16384, then a checksum halfword, and `PHASE02.sym.json` gives `#PCVNMMU`
(module `CVNMMUTI`) as `30322..3432a`, 16393 hw, with `FIOMUWB2` at `3032a` =
base + 8. Exact agreement, two independent ways. (Recorded in memory as
`project_fiomuwb2_is_a_name_pointer_to_cdhv_blocks`, which formerly carried
"do not fix mmbstamp here" as a directive and has been corrected.)

**A real bug in our own tooling, found here:** `patch_ssl_zcon.py` patched only
`FCMB1ZCN`. With `FIOMUWB2` unresolved, `FCMB2ZCN` held `A000/0000`, which
`MVH`'s R2 arm resolves to `02000`, so the *second* move sourced 7,654
halfwords of sector-0 rubbish — the destination matched the tape in exactly its
first 7,168 halfwords and was zero after. Patching both (`A000/0000` →
`A32A/0006` = `3232a`) makes the sector-8 block checksum. `YAGPC_MVHTRACE` was
added for this: a move that stops early on a store-protect leaves R1's count
intact by design, so from outside it is indistinguishable from one that never
ran. (The workaround is now obsolete — a correctly built SSL resolves
`FIOMUWB2` on its own, and `patch_ssl_zcon.py` reports `832A 0006 -> 832A
0006`.)

**The authoritative oracle for protection questions is the link, not the load
blocks and not the dump.** `PHASE0n.sym.json` carries a `storeProtect` map —
`{"unit":"halfword","ranges":[[lo,hi],...]}`, 161 ranges for phase 2 spanning
`001aa..48889` — and none of them overlaps `#PCVNMMU`. Use it.

**Our loader's protection strategy is irrelevant to this failure**, established
after a harness bug of our own invalidated three reported results (the
`sections` mode never actually ran: the binary was stale for `ageharness.c`
despite a newer timestamp; `touch src/ageharness.c && make` fixed it). With the
mode genuinely applied the result is *identical* to the blanket default — 7170
DMA violations, 281 blocks, the same word counts — because `GPCERAS` protects
everything itself regardless. `YAGPC_IPL_PROTECT=0` is separately refuted, not
merely suspected: the boot dies immediately at `nia=00000` with nothing loaded,
exactly as `ipl_fill()`'s existing comment predicts, because the Instruction
Monitor fires once the software sets PSW mask bit 34 and every instruction then
looks like it is executing from unprotected storage. Keep the flag as a
diagnostic; do not make it the default.

**Masking is not involved.** `SSLCHECK` does `SSM 7  MASK ALL INTRPS` before
`B$ SSLSTART`, so the SSL runs fully masked — but Figure 2-20 gives the Store
Protect Violation (code 0007, row 33) a mask column of "--", i.e. no mask bit
at all. Maskable program checks carry one: Fixed Point Overflow 20, FP
Underflow 22, Significance 23, Instruction Monitor 34. So store protect is
unmaskable and our unconditional handling is right. **A real gap surfaced
alongside it, unrelated to this bug:** we never consult a mask for program
checks at all — `cpu_check_interrupts` honours `psw_get_mach_check_mask` for
machine checks and `intMask` bit `0x20` for the instruction monitor, but
`if (cpu->intPending.programCheck)` is taken unconditionally, so Fixed Point
Overflow, FP Underflow and Significance are delivered even when their mask bits
say they should be ignored. POO 2.5.2.3, already quoted in that function, says
masked program interrupts do not stay pending. Nothing in this boot depends on
it; worth fixing on its own merits.

**Masked DMA violations are invisible by design**, which is why several passes
over this looked like there was no interrupt at all: per AP-101S Fig 2-20 note
`##`, `cpu_signal_dma_protect_violation` sets CC to binary 10 **without** taking
an interrupt. `YAGPC_DMAPROT` exists precisely to see them. And **do not trust
a violation count from a truncated run** — one such count was reported as zero
and a correct explanation withdrawn on the strength of it; run to completion,
`YAGPC_DMAPROT` reports 7170, of which 7169 are in `#PCVNMMU`.

**`0009c` (`TPSASINP`) is protected by design**, and that thread is closed. The
unprotect table is built by the `$POF`/`$PON` macro pair (`MACSMITH.asm:508`
and `:540`) and walked by `STM0.asm:118-146` (`UNPTRTN`/`UNPT`,
`ISPB# 0,0(X3,B3)` + `BCT R7,UNPT`) — our `nia=00507`. `PSA.asm` contains
exactly one bracket, `$POF` at line 107 immediately *after* `PSA EX4`, running
to `$PON` at line 176; that bracket is `00a0..0013f`, which is precisely what
we observe, and the table read out of memory steps straight over `0009c..0009f`
(`@05131 start=00098 count=4`, `@05133 start=000a0 count=154`). The stray
single-halfword entry at `00087` is real and explained verbatim in `PSA.asm`:
"LOCATION 87 IS USED BY UCODE-MUST BE 0 & UNPRT". A table precise to one
halfword for a documented microcode requirement does not omit `0009c` by
accident. The `$POF`/`$PON` convention was settled independently on
`SSLCHECK.asm`'s minimal bracket (`$POF / SSLRTN DC H'0' / $PON`, `SSLRTN =
02d72`, assembled entry `start=02d72 count=1`): **the marker labels where the
region begins**, i.e. the item after it. AP-101S 2.5.2.1 lists only OLD PSW
locations, so a NEW PSW may legitimately be protected. The software's actual
convention is exact — **unprotect precisely what you are about to write**:
GPCIPL's restore deliberately leaves `0014..0017` protected (its groups run
`00008..00013` then `00018..00043`, straddling it) and the SSL unprotects
exactly those four halfwords itself, immediately before storing the System
Reset PSW.

Also closed here, each by measurement rather than argument: **`FCMSYSID = 000e`
is correct** — `SSLCHECK.asm:145-150` does `LH G7,BSLTPNTR+1 / SHI G7,1`, so
the "system ID" is the DEU menu item number minus one; `COMDATA.asm:130-131`
initialises `BSLTPNTR+1` to 17, `BCE 18` writes it from tape, and GPCRTOPT's
`POLL45` ("IPL DEFAULT LOAD -- NO DEU SELECTED") overwrites it with 15, the
documented default, giving 14. **Removing the blanket PSA protect from
`ipl_fill` changes nothing**, structurally: GPCIPL's own sweep re-protects
`00000..07f02` at t=4.16 s, so whatever IPL leaves behind is irrelevant by the
time the SSL runs. And **making the PSA carve-out permanent was tried and
reverted**: it removed the spurious faults at `000b0`/`000b1` but wrecked the
early boot (simulated time ran away to 4187 s in 60M steps with blocksRead
stuck at 55), because "must not be store protected" is a rule for *software*,
not a hardware interlock — GPCIPL's memory test sets those bits and reads them
back. `ageharness.c`'s comment calling it "a permanent hardware carve-out" is
an over-reading of the same sentence; it happens to work only because it is
applied once, at IPL.

**"Three voted storage protection bits" is not a second protection level.**
There is one *logical* bit per halfword, held in three redundant physical cells
and majority-voted: POO 2-1.1 ("The AP-101S/G has two storage protect bits per
halfword" — a 3-vote/2-compare reliability trade, not a change in the number of
levels); the D100 `READSP` diagnose naming "Bits 13-15 **REDUNDANT** Store
Protect Bits" and "Bits 22-24 REDUNDANT..."; and status register bit 6, "MMP
Store Protect Bits MISCOMPARE", a fault raised when the copies *disagree*. Our
model is already right — `mcm.h`'s `bool *protData` is one entry per halfword
and `cpu_instr.c`'s D100 already synthesises the triples, active low, with a
comment explaining the voting. The only thing it cannot express is a
miscompare, which is hardware-failure injection rather than function.

**`SPON`/`SPOFF`: a design settled with the ASM101S-port session and the user.**
Forty files use them. An early conclusion — "redundant, do not implement",
argued from 42 of 45 bracketed CSECTs already being unprotected in the linker's
map — was withdrawn as a **non-sequitur**: it compared the two mechanisms at
*CSECT granularity*, which is exactly the granularity the wholesale mechanism
can express and the fine-grained one exceeds. Eight of the 40 files bracket
sub-CSECT regions, and the case that settles it is `MLIB80/TFPSA.asm`, which
emits `SPOFF` **conditionally** (`AIF ('&X' EQ 'DS').NOSPOFF`) immediately
before `TPSASTRT` — that is the AP-101S 2.5.2.1 carve-out which `ageharness.c`
hand-codes from the manual, and being macro-conditional, a fixed hand-coded
range cannot reproduce it.

The interpretation was resolved by the user rather than by either agent: **the
authors did not know what the protection defaults would be and simply added a
mark where they had a specific block they cared about.** That retires the
delta-vs-fixed-default argument instead of deciding it, since the source never
encoded a global scheme — and it predicts *clustering* on hazard-prone code
where a global scheme predicts none. Measured across all 549 `.asm` in
OI340600 `SSSRC`+`MLIB80`: overall marking rate 40/549 = 7.3%; files containing
BCE opcodes 17/39 = 44%; files with none 23/510 = 4.5% — a tenfold enrichment
on exactly the code that contains DMA targets. A confound was then caught by
ASM101S-port and confirmed: 72% of BCE-opcode files are `FIO`, so the
name-prefix table largely *restated* the opcode table rather than corroborating
it. Stratified within `FIO` the effect survives, and the two agents' counts
bracket it: `FIO` with BCE 17/28 (60.7%) vs 19/30 (63%), `FIO` without 9/86
(10.5%) vs 7/84 (8.3%) — a stratified ratio of **5.8× to 7.6×**. Quote the
range; that two heuristics both land well above 1 with the family fixed is
itself part of the evidence.

Decisions recorded, and the reasons matter as much as the decisions:

- **No diagnostics on unbalanced brackets.** Census across the 40 files:
  balanced 4 (10%), `SPOFF` with no `SPON` 31 (78%), `SPON` with no `SPOFF` 5
  (12%), mismatched-both-present 0. The obvious diagnostic would fire on **36
  of 40 files** — unbalanced is the normal case, not the error case. That is a
  stronger reason than "the semantics are inferred", and it also protects the
  bit-identical-listing property.
- **The assembler records and reconciles nothing**, stated as a decision with
  its reason attached rather than as a gap: the source contains no answer to
  reconcile toward, so inventing one would have the assembler assert something
  nobody can source. Reconciliation belongs in `lnk101`, where it is visible.
- **Two command-line options**, per Ron: a switch disabling only *the embedding
  in object files* (not the tracking), and a second for the CSECT-start
  protection state, kept lexically far apart — `--no-store-protect` and
  `--protect-default=on|off`, since `--no-csect-protect` beside
  `--no-store-protect` would be a script-level footgun. `ASM101S.py`'s
  convention is opt-out/default-enabled (`--no-rtl-fixes` at line 1234,
  `--no-force-d` at 1286), though note those are read *before* the option loop
  for a specific reason — source files are read in place as the loop
  encounters them — which a flag consulted only at `writeObjectModule` time
  does not need. Copying that pattern would be cargo-culting.
- **Acceptance criterion, not a nice-to-have:** sweeping both releases with
  `--no-store-protect --protect-default=off` must reproduce the stored objects
  **bit for bit**. That specific combination is the strong form — default off
  with suppression on is the configuration whose output would differ most if
  protect state leaked through a path ignoring the suppression.

The port session declined to implement it in `ASM101Sa` and was right to:
that C port's entire value is being a verified drop-in replacement (542 modules
byte-identical across OI340600/OI301700, plus 205 RUNASM against 1980s
listings), and adding a record type turns every comparison from "identical"
into "identical except the thing I added". It has to land in `ASM101S.py` first
and be carried into the port in a parity pass.

**The container format was got wrong and then settled by Don's existing code.**
`libModule.py`'s `0xA1 PROT` is a **load module** record, raw binary; an object
module is 80-byte EBCDIC card images (`objectWriter.py:27-33`, `card[0]=0x02`,
EBCDIC type in columns 1-4, payload capped at 68 bytes, sequence in 72-80).
`objectWriter.py:140`'s existing `writePRT()` emits a `0x02` record that
`lnk101` never sees — `objModule.py:1001` routes `card[0] == 0x02` to module
records and `linker.py:319` scans only `controlStatements`, so `protManaged`
stays empty, the tape comes out byte-identical and **no error is raised**. The
ruling is to use Don's format: a control card, column 1 blank, text
`" PROT <csect> <s>-<e>[,<s>-<e>]..."`, ranges CSECT-relative halfword offsets,
hex, **end-exclusive**, listing the *protected* regions — the same convention
as HAL/S-FC PASS2's `" STACK <csect>"` cards. Critically
(`linker.py:169-172`), **a CSECT named on a PROT card is fully specified**: an
empty range list means nothing in it is protected, so emitting a card takes
that CSECT out of the deck scheme entirely. That settles the precedence
question both agents speculated about — Don has it as **override**, not modify.
Two related traps the port session verified: `objcanon.py` dispatches
`if typ == "ESD" / elif` with no `else`, so it **silently passes** unknown card
types until taught; and `model101.py` has `repeatPass`, so location-counter
transitions must be re-collected per pass or they double.

Don had in fact already implemented the consumer side five days earlier —
`7fff229` "lnk101: carry store-protect ranges into .sym.json", 2026-08-23 —
reaching the same reading independently. `lnk101` needs no changes:
`linker.py:333-334` reads the cards into `mod.protManaged`/`protRangesHw`, and
`storeProtectRangesHw()` (`linker.py:810`) applies the precedence "explicit
PROT ranges when the assembler captured SPON/SPOFF, else the CSECT's SET/CLEAR
mark, else the name-class default", feeding both the `.lib` PROT records and
the `.sym.json` map. (`.lib` files are `lnk101`'s doing — `--lib`/`saveLib()` —
"an AP-101 loadable module: CESD, per-extent text, RLD, store-protection,
overlay/phase metadata"; the `.fcm` is the flat image of the same link and has
no room for metadata. All 235 extents in our `PHASE02.lib` already carry a
per-halfword `protect` array and real `0xA1` records.)

**The remaining gap is `mmbstamp`, and it must not be switched yet.**
`protection_lookup()` (`mmbstamp.py:228`) builds intervals from
`sym["sections"]` plus the deck map and `patch_aware_default(name)`; it never
reads `sym["storeProtect"]["ranges"]`. That switch was predicted to be a no-op
and **is not**: it changes the tape from 2500 to 2514 blocks. With no PROT
cards yet, the disagreement is between *two independent implementations of what
the deck's SET/CLEAR says* — `mmbstamp`'s `deck_protection()` (436 entries for
phase 2) versus `lnk101`'s `placement.protected` as carried into
`storeProtect`. 110 sections and 11,947 halfwords differ, in both directions:
`FCMINSSL`, `FCMSSLPT` and `FCMLINIT` go protected → **unprotected** (which is
exactly the condition `ipl_fill()`'s comment warns about, and would very likely
have broken the boot), while `#PCDTANN` and `#PCV2LIN` go unprotected →
protected, the `#P*` flips being the class-default prefix overridden by a deck
mark on one side and not the other. One of the two deck readers is wrong, and
that is worth settling on its own merits **before** anything is switched over —
otherwise the assembler's data will arrive on top of an already-divergent base
and the two faults will be indistinguishable. The experiment was reverted; the
tape rebuilds byte-identical.

### 8.22 Placement fidelity — pinning CSECTs to the flown article

Separate axis from correctness, and it is important to keep them separate: the
link is self-consistent, so CSECT placement is a **fidelity** measure against
the flown article, not a behavioural one. The `zconPool` experiment settled
that principle early — pinning took the Z1 pool from 2/80 to 80/80 at the flown
addresses and the boot produced *byte-identical* symptoms.

**The Z1 pool order is recoverable and now pinned.** `lnk101` takes
`--link-order <linkorder.json>`, whose `zconPool` is an ordered list of CSECT
names (`ap101Utils/linkorder.py:70`, `zcon_sort_key`). No such file existed
anywhere, so our ordering was unpinned. `mafgen/csects-SSW.json` gives each
CSECT's address in the flown image, so sorting the 80 pool CSECTs by address
yields the pins directly: PHASE02 sector-0 match against DASS went 97.359% →
98.061% (305 → 224 mismatches). Checked at the user's prompting against the
*original* `DASS_SSW_(PostIPL).ASC` rather than trusting the derived artifact:
656 CSECT-header lines against 660 json entries, **zero** address differences
on shared names, the four extra all present in the report but as source-listing
or cross-reference lines rather than headers — so the json is a superset drawn
from more of the report, consistent wherever both carry an address. Within the
Z1 pool it is exact: 80 header lines, 80 entries, same names, zero differences.
(Method note: a first extraction matched 239 "entries" in the pool alone
because the pattern also caught symbol-detail lines like `#ZFIOCGR+0000`.
Require the `****` field and reject names containing `+`.)

**`--external-syms` pins placement, not just resolution** — read in
`linker.py` `loadExternalSyms` rather than assumed: after resolving externals
it runs "Pre-assign addresses for locally-defined sections found in the JSON",
setting `section.baseAddress` for every SD section named in the pin file. The
docstring's "without loading the actual object modules" undersells it.
`con80build` has no passthrough for it, so it was shimmed rather than editing
Don's repo: `shimbin/` symlinks every wrapper from `<dps>/build/bin` and
replaces `lnk101` with a four-line script appending
`--external-syms $YAGPC_EXTERNAL_SYMS`; `con80build` resolves its tools from
`_BINDIR = dirname(--halsc)`, so `--halsc shimbin/halsc` redirects all of them.

**The pin file is per memory configuration, not global**, and the CON80 decks
carry the mapping in machine-readable form — each `PHASEnn` deck names the
configuration deck it pulls in, and those names match the `csects-*.json` names
one for one:

    PHASE02 OPS0,SSW  -> SSW      PHASE08 GNC9      -> G9
    PHASE04 GNC1,GNC6 -> G16      PHASE09 MFB9,PL9  -> P9
    PHASE05 GNC2      -> G2       PHASE12 PL9       -> P9
    PHASE06 GNC3      -> G3       PHASE15 SM2       -> S2
    PHASE07 GNC8      -> G8       PHASE16 SM4       -> (no csects-S4.json)
    PHASE03 GNC2,MFB3 (declares configurations 1,2,3,8,9) -> no single table
    PHASE14 MFB14 -> none;  PHASE18 names no configuration deck -> none

`G16` is configurations 1 *and* 6, which is why PHASE04 pulls both GNC1 and
GNC6. This corrects the prose mapping in two places: PHASE09 is P9, not G16,
and configuration 9 is PHASE08, not PHASE18. Available in `PFS/mafgen/`: G16,
G2, G3, G8, G9, P9, S2, SSW; `-augmented` variants exist only for SSW and P9.
Applying SSW globally moved 316 CSECTs in PHASE03 to SSW addresses and 2 in
PHASE13; PHASE01 and PHASE10 were untouched.

**A build that is both accurate and runs.** PHASE02 against DASS_SSW went from
553/660 (83.79%, 100 misplaced, 7 absent, 638 unresolved) to **652/660 =
98.79%, 0 misplaced, 2 absent, 6 unresolved** — and it boots. Three things had
to be true *together*; every earlier attempt had two:

1. **Pin PHASE02 only.** Pinning PHASE10 is catastrophic — it strips 97% of
   GPCIPL's relocations (1788 → 56), so its address constants stay zero;
   PHASE03 loses 18% the same way. PHASE02 is the one phase where pinning
   *improves* resolution (638 unresolved → 6, relocations 10470 → 11094).
2. **Drop the 58 `#Z*` entries from the pin file.** `--external-syms` runs
   *before* `lnk101`'s Z-con generator and satisfies undefined `#Z*` with
   content-less synthetic sections, **suppressing** the generator: `#ZDCDDG2`
   went from `<generated-zcons>` (a real pointer) to `<external-syms>` (empty),
   punching holes in the load blocks. `linkorder.json`'s `zconPool` places them
   properly on its own.
3. **Run `--resolve-phases` afterwards.** Per-phase `--link` skips what
   `--build-all` does at the end; PHASE02 alone had 367 sites to patch.

**The lesson: diff the loaded memory image, not the link metadata.** Both
volumes were stopped at the same step count with `YAGPC_MEMDUMP=0-7fff`; 375
halfwords differed, and the distribution named the fault — `FCMSSLPT` merely
shifted by 6 halfwords (two extra descriptors, benign), and in GPCIPL a scatter
of **zeros where the working image had addresses** (`01bc8 3610->0000`,
`01be8 1d3a->0000`, `01bf0 1ce4->0000`): unrelocated address constants.
Reasoning from `sym.json` had chased Z-con holes and CSECT overlaps for hours;
the memory diff named it in one run.

**For Don, if it is worth reporting:** `lnk101 --external-syms` pre-assigns
`section.baseAddress` for locally-defined sections, and on PHASE10 that drops
1732 of 1788 relocations — a section arriving with a `baseAddress` already set
appears to be treated as needing no relocation. And `--external-syms` should
not pre-empt the Z-con generator.

**Per-phase pinning results** (real content at the flown address, unpinned →
pinned): PHASE04 11.21% → 91.92%; PHASE05 14.26% → 88.99%; PHASE06 12.58% →
91.16%; PHASE07 16.46% → 86.15%; PHASE15 18.09% → 91.44%; PHASE02 83.79% →
96.06% (then 98.79% with the `#Z*` correction). High "absent" counts on
PHASE09/PHASE14 are expected — a configuration table describes a whole memory
image that several phases jointly supply. Noted and unexplained: pinning
PHASE12 to P9 makes it oversize on tape (224 blocks against 216 allocated).

**What is still unpinned, and named:** besides `zconPool`, `linkorder.py`'s
header documents `orphanFlush` (cross-module orphan program-flush order) and
per-memory-configuration `mc.{name}.codeOrder`, `streams`, `floors`,
`wave1Order` and `compoolOrder`. Those govern where whole *programs* land,
which is exactly what differed before pinning: the 22 unpinned misplacements
were four whole programs each moving as a unit — `DMPMMM` +592 (18 CSECTs),
`VMELOA` +268 (3), `$0ASCTIM` −3730, `$0ASGCYC` −4358, with flown order
DMPMMM → ASCTIM → VMELOA → ASGCYC against ours ASCTIM → ASGCYC → DMPMMM →
VMELOA. They cannot be derived from an address sort alone; they need the `mc`
anchor structure.

**Cross-release caveat on all of these numbers.** Everything is built from
`OI340600/CON80`, but `PFS/OI340700/README.md` states the DASS reports are
**OI34.07**, so `latest.unlinkSSW_(PostIPL)` is a different release from the
thing being measured. The overlay is 17 files (four `MLIB80` COPY/macro
members, `SSSRC/FIOCBLKS.asm`, `CDAP15.dfg`, and 11 `APPLSRC` HAL/S files), of
which only `FIOCBLKS` is a *linked* module in phase 2 — and for phase 2 the
whole release delta is **one halfword**, at `08f39`, which OI340700 gets right.
So the release difference does **not** explain the residual mismatches. Two
attributions were withdrawn on that basis: the 102-halfword `04b48` cluster was
credited to `FIOCBLKS` because it falls inside that section, but `FIOCBLKS`'s
change lands elsewhere entirely — section containment was suggestive and was
treated as conclusive, and CSECT spans in PHASE02 overlap anyway (`FCMSAVE`,
`FIOADCNS` and `FIOCBLKS` all cover `04b48`). Note also that `CON80` is the
**linkage decks** (194 extensionless members), not source; source is
`APPLSRC`/`MLIB80`/`SSSRC`.

Two measurement corrections worth keeping. Counting fill-vs-fill as mismatch
understated PHASE02 sector 0 as "60.1%": the dump has *two* fill patterns,
`C6C6` (49.3%) and `C9FB` (21.4%), and excluding halfwords the dump left as
`C9FB` gives 11245/11550 = **97.4%**. And phases 10, 13 and 3 match the
post-IPL dump at only 3.3%, 3.3% and 9.4% of their own extents against phase
2's 97.4% — the resident post-IPL image is essentially phase 2 alone, so that
is not evidence those builds are wrong; overlays are not expected to be
resident.

**The build recipe that reproduces these numbers**, recovered from the objects'
own `.asmg.json` repro records rather than guessed, and the two ingredients
that decide it: `--src <scratch>/srcnoext/{SSSRC,APPLSRC}`, the extensionless
mirror — with `.asm`/`.hal`/`.dfg` names CON80 resolves *different modules*
(`FCMBMT02`, `FIOACT02`, `FIOCYC02` instead of `FCMBMTPG`, `FIOACTMD`,
`FIOCYCTB`) and the build silently scores 28% against the dump instead of 97% —
and `--src <scratch>/patchsrc`, the patch decks, since `PCH02TXT` supplies
`OPSZFILL`, `MFBZFILL`, `#T020000`, `PCH2SAIL` and `$X020001` and without it
the link has 10 unresolved symbols. Plus `--incl <scratch>/INCL80_fixed`
(extensionless symlinks), `--mlib`, `--linklib <dps>/build/lib/runtime/{RUN,
ZCON}` and `--pass-rel32` at the Virtual AGC archive. **All of `--pass-rel32`,
`--linklib` and `--runlib` default CWD-relative**, so they must be given
explicitly from anywhere else. One line, from `nsts-sdl-dps`:

    HALSFC_BINDIR=<archive>/PASS.REL32V0 YAGPC_EXTERNAL_SYMS=<PFS>/mafgen/csects-SSW-augmented.json PYTHONPATH=<dps>/src python3 -u -m con80.con80build --root <PFS>/OI340600 --out <scratch>/pin --src <scratch>/srcnoext/SSSRC --src <scratch>/srcnoext/APPLSRC --src <scratch>/patchsrc --incl <scratch>/INCL80_fixed --halsc <scratch>/shimbin/halsc --pass-rel32 <archive>/PASS.REL32V0 --link-order <scratch>/linkorder.json --build-all

Stale trees are **not** salvageable by relinking: `newphase/PHASE02/obj`
contains no `AIBGPCLO.obj` at all yet its `sym.json` carries `$0AIBGPC`, so
that tree is internally inconsistent. A full `--build-all` is the only sound
route. And `mmu2mmv` wants the whole per-phase tree (`PHASEnn/PHASEnn.sym.json`,
not just `.lib` files) — it produced a 227-block volume from a lib-only
directory before failing.

**A blocker that was never real**, recorded because it consumed a day: "phase 3
destroys `FCMLINIT`". It was an artifact of a badly built `newphase/PHASE03.lib`
carrying a 6979-halfword extent at `03336` that swallowed `047e0`. Rebuilt
correctly, PHASE03 has 26 extents and **nothing below `04c70`** — it begins
exactly where `FCMLINIT` ends (`04c6b`), leaving the same four-halfword gap
`04c6c..04c6f` the DASS dump shows as fill. Two independently derived layouts
agreeing on that boundary. Against the dump, PHASE03 goes from 12.9% to 77.53%.
The `0xc6c6 at 0x48bf` crash, the failed phase reorder, and "phase 3 genuinely
overwrites FCMLINIT" all trace to that one bad library — `newphase` was
internally inconsistent, its PHASE02 built correctly and its PHASE03 not. The
phase-reorder experiment it motivated (patching `FCMSSLPT` so phase 2 loads
last) is therefore **not** a proposed fix and should not be pursued: it
contradicts `IPL_PHASE_ORDER = (10, 2, 13, 3)`, which
`stamp_ipl_phase_table.py` takes from FCMBOOT's prolog and MMLOAD's
`IPL,PH=(10,2,13,3)` card, and with `FCMPSA` loaded the question is moot
anyway.

**`SYS5` must be written as proper load blocks, not raw fill** — the cards say
so (`LOADBLK=1/2/3`). The layout, from `mmbstamp`'s writer and the SSL's
reader, is `[0..L-3]` content, `[L-2]` zero, `[L-1]` the sum of the content mod
2^16 — exactly what `patch_ssl_zcon.py` recomputes after an edit. Raw
`INIT=C6C6` is not a valid load block: with it `FMADEU13` was read four times
and stuck; as proper blocks it is read once and passes. `SYS8`
(`MMDIR1/2/3`, the `FFFF` not-mass-memory-built sentinel) is harmless and
stays. Separately, `SSSRC/MMULDTBL.asm` shows the DEU load is **one transaction
of three raw DMA transfers**, not SSL load blocks — `2468 'DCP'` 17 blocks ×
512 words to GPC `A000`, `2418 'DST'` 8 × 76 to `D000`, `2488 'CRTFMT'` 8 × 76
to `E000`, decoding BLK CNT-1 / WD CNT-1 as bits 15-11 / 10-2 — so a
whole-allocation checksum tail is never even read there. (`FMADEU21`/`DMACDFT1`
in that file are the transaction's "END n OF 3" markers, **not** the tape
allocations of the same name.)

### 8.23 Three context-switch defects that only running PASS could find

None of these is visible to a per-instruction fixture, and the test suite has
**no multi-process coverage at all** — nothing but running PASS exercises them.
Each was found by the NIA ring, and each was confirmed against the flight
software's own stated contract rather than against `gpc`.

**1. RS extended form, B2=11: the displacement *is* the effective address.**
POO §2.2.8, second numbered difference from SRS addressing: "When B2 equals 11,
base addressing is not performed. In this case, the displacement is instead
used directly as the effective address." `cpu_g_ea` was routing it through
`ea_expand`, so any operand with bit 15 set had its sector replaced by DSR.
§2.9 does not apply: it turns a 16-bit *address* into a 19-bit EA, and here the
displacement already **is** the EA.

The symptom was a coin-flip. `ST R7,X'8252'` at `FCMSSYNC`'s entry worked *by
luck* — DSR=1 gave `(1<<15)+0x252 = 0x8252` — while the matching
`L R7,X'8252'` at its exit ran with DSR=0, read `0x0252`, and put `0x0001` in
R7's high half, so the `BCR 7,R7` return branched to address 1. That is the
recurring `invalid instruction 0xc6c6 at 0x6b8f`.

Corroboration from three directions: six `FCMSSYNC` operands equal their symbol
addresses exactly, three with bit 15 set (`FCMSNCSV 8252`, `FCMPLDSE 8bba`,
`FCMSVCNM 8209`, `TCVTRSSM 0166`, `TPSASOP 0058`, `TCVTSVCS 016a`);
`FCMSNCSV` is an **EXTRN** (`FCMSSYNC.asm:150`), so the linker plugs an
absolute address into the displacement field, which only works if the
displacement is the EA — a linker cannot know what DSR holds at each call site,
so any EXTRN resolving above `0x8000` would be unaddressable under expansion;
and the POO names expansion explicitly each time it applies — "(This EA is then
expanded to a 19-bit EA...)" occurs exactly four times, all in the *indexed*
forms, while §2.2.8's B2=11 case has no such clause and yields the EA outright.
**Branches are excluded, measured not assumed:** applying §2.2.8 literally to
branch operands costs `test_scheduler`, `test_random` and `test_rtl` outright
and drops 111116 → 111036 fixtures; a branch target must still reach sector 3
(`0x197ab` needs more than 16 bits), so it expands with BSR per §2.9. Widening
the rule to *all* extended operands breaks the boot outright at `nia=00156`.
Cost: 64 `cpu_instr_exec` fixtures (111180 → 111116) across 23 mnemonics, all
data-operand, none branch — `gpc`-generated and encoding the expansion, so they
cannot adjudicate.

**2. `BAL` and `SCAL` saved the *callee's* BSR/DSR instead of the caller's.**
Both computed their target with `cpu_g_ea()` **before** snapshotting `psw1`,
and `cpu_g_ea()` modifies the PSW when the target is reached through a fullword
indirect pointer with C=1 (POO Fig. 2-17, "MODIFY PSW ACTION": DSR=DSV,
BSR=BSV) — which is precisely how `BAL@# R7,...ZCON` calls into another sector.
The fix is ordering only: read `psw1` first. (`cpu_incr_nia()` already runs
before the exec dispatch, so the link's address half is unaffected.) The flight
software states the contract itself, in `FCMTRACE`'s exit: `BCRE 7,R7  RETURN
TO CALLING ROUTINE (BSR/DSR OF CALLING ROUTINE WILL BE RESTORED BY THIS
INSTRUCTION)`.

The chain it broke is worth keeping because it looked like a scheduler bug for
days. `FCMSSYNC` calls `FCMTRACE` via the PSA trace Z-con at `0x0000c` =
`98a0 0f33` (DSV=3, CD=1; byte-identical to the DASS reference, so the Z-con is
right). DSR went 1→3 and **stayed** 3. `FPMCLOSE` then read `TPCTFLGS` through
`USING TFPCT,R0` with R0=`827c`: bit 15 set, so DSR expands it, and DSR=3 read
`0x182ab` instead of `0x82ab`. The true flags are `0000`; the wrong address
gave bits in the `0x00C0` mask, so `IF (TB,TPCTFLGS,X'00C0',Z),OR,...` took its
ELSE, the PCT was never freed, and `FPMDISP` re-dispatched it on `FPMFCLOS`'s
**re-issue PSW** — `FPMDPSW`, the fallback constant
`DC Z(FPMSVCL+2,FPMSVC21,8)` stored by `ST R4,TPCTPSW  IN CASE CLOSE MUST RE
ISSUE CLOSE SVC` immediately before a `CALL FPMCLOSE` marked **(NO RETURN)**,
so normally never dispatched. Its NIA `0xac14` expands to `0x1ac14` =
`FPMDPSW` *itself*, so the CPU executed the constant, ran off the end of
`FPMFCLOS` and fell into `FPMFRPCT` with garbage in R0, whose `FPMRLPCT`
("REMOVE PCT FROM RUN QUEUE") has **no end-of-list test** —
`DO WHILE=(CR,R5,NE,R0) / LR R1,R0 / LH R0,TPCTNXT / ENDDO` — and spun forever.
Our link is not at fault: `1ac12..1ac15` is byte-identical to the DASS
reference (`c9fb 8146 ac14 0831`). Result: 900 s / 505,713,872 steps with
**zero** invalid instructions, and the NIA sampler finding the CPU spread
across `FPMIDLE` instead of `FPMRLPCT`'s runaway.

**3. `SVC` never saved the EA's 4-bit extension.** POO §2.5.1.1: "EA-High — For
an SVC instruction, the 4-bit extension to make the 19-bit effective address is
saved in the old PSW bits 40-43." `exec_SVC` wrote only
`psw_set_int_code(ea)`, truncating to 16 bits; the field existed in
`PSW_DESC2` as `'e'` but had no accessor and was never written by anything.
`FPMSVC` rebuilds the SVC parameter-list address from exactly those bits
(`LH$ R1,TPSASOP+2 / SRL R1,4 / NHI R1,X'000F' / XUL / OR / OHI X'8000'`), so a
stale extension fetched the SVC number from the wrong sector, and a wrong number
indexes `FPMSVCEP`, whose seven empty slots dispatch to address 0. `FPMSVCEP`
itself is byte-identical to the DASS reference, so the build is right. Measured:
branches into the PSA at `00000`, caught by the Instruction Monitor, fell from
**5302 to 36** in a 450 s run (99.3%), the DK display task `$0DDKHCT` stopped
failing entirely, and real application code (`$0ARAGPC`, `#CARYMFB`,
`A2ARDCSB`, `FIOPDISP`, `FPMMTURM`) appeared in the traces where only `FPMIDLE`
had before. Costs 249 `gpc` fixtures (111114 → 110865); `gpc` does not write
EA-High either, so they encode its absence. **This fix was only half right and
was completed on 2026-08-31 — see §8.26.**

**Concurrency began working here, and that is the headline.** Dispatch counts
(entries into each program, not instructions) over a full run:
`ARA_GPC_SWITCH` 25, `DDKHCT` 164, `FPMIDLE` 831 — PASS's FCOS interleaving
HAL/S programs correctly, which was **not** true before these three fixes.

Two related findings that fell out of the same work. The **HAL/S error message
table was group-blind**: `AIBGPCLO.hal:630`'s `SEND ERROR$(6:6)` — its own
comment `/* RUNTIME USED INSTEAD OF PCMMU */ /* TIME TO CALCULATE TSIP */`,
raised by the guard `IF (AIBV_GMTOI > AIBV_TC) OR ((AIBV_TC - AIBV_GMTOI) >
1.02)` — was printed as "EXP FUNCTION HAS ARGUMENT > 174.673". USA003090
Appendix C states the runtime table's scope in as many words: these errors "are
detected by the HAL/S-FC library and emitted code. They are classified as GROUP
4 errors within the HAL/S error grouping scheme", and §8.1.3 item 14 gives
1..127 as the range for user-defined errors. So `(group, number)` is the
identity, the table is group 4 only, and group 6 number 6 has no relation to
number 6 in group 4. Inherited verbatim from `gpc` (`halUCP.coffee:7-14` maps
groups 1..6 all to "RUNTIME" and picks the message from `SVC_ERROR_MESSAGES
[errNum]` alone). Measured, group 6 is the **only** group PASS uses for its own
`SEND ERROR` — numbers 1,2,3,6,7 across `AIBGPCLO`, `AIESIP` (×5), `DMIMCD`,
`GKTUNI`, `GG8PWC`, `PGEPCI`, `GKEKIP`, `GSDFIR`, `SAFACQ` — so the misreport
was the common case in this corpus. Fixed in `src/halucp.c`:
`HAL_S_LIBRARY_ERROR_GROUP 4`, `svc_error_group_name` names only group 4
"RUNTIME", and `svc_error_message` takes the group and returns `USER-DEFINED
ERROR g:n` for anything else. **Still open, and a shared-contract defect:**
`yaGpcIntegration.h:131` encodes `GPC_ENGINE_WARNING_HAL_S_ERROR_BASE = 1000`
plus `lastErrNum` **only** (`gpcops.c:115`), so the group is dropped on the way
out and an integrator asking `gpc_engine_status_message(1006)` still gets the
EXP text; `yaHALMAT2/src/yaGpcEngineStatus.c` carries the identical table, so
this needs a relay to that session before either side changes the enum.

And **the DEU display list is not EBCDIC**. `YAGPC_DEUIMAGE` read each halfword
as two EBCDIC bytes and produced pure noise, which made a correctly rendered
screen look like garbage. Display text rides in the DEU's own character set
inside a Format Control Word — op C, `11aaaaaaabbbbbbb`, two 7-bit glyphs, and
from `0x20` up the set is ASCII (USA-003090 p.104; `nsts-sim-gpc`
`meds/deuFCW.coffee`, `DEUCharset` and the FCW table). Decoded properly, the
post-IPL image is the real GPC IPL menu: "GPCIPL 09.05.00.00.01 / 1 GPC _
MEMORY PURGE / PASS1 1 BFS1 2 PASS2 / 27 OPTION START 28 STOP 29 / OLD PSW MAJ=
MIN= SCHEDWRD= CLOCK1= / 17 DEU FORMAT LOAD / IPL MENU / STP/PURGE CYC CNT
ERROR/MSG / MCDS BITE MODE BSR1 BSR2". Note for judging future runs: **a frozen
DEU image is not by itself a fault** — `deu_complete_fill` counts a time fill
and then discards it, so the clock never reaches `d->mem`, and a static format
refreshed every cycle writes identical words.

### 8.24 Driving the crew station headlessly, and the BFC CRT discrete's double duty

**The crew sequence is a sequence, not a state.** Register A bits 0-3 are
HALT/STANDBY/RUN/IPL, and IPL is a **momentary pushbutton asserted on top of
HALT**, not a fourth position — `discretePanel.py`'s own comment says a panel
that made IPL a fourth exclusive position could not express the real sequence
at all. A static `--discrete-a` asserts a final state the software never
*transitioned into*, so `--discrete-a 28000000` (RUN + MM1 source) produces a
run with no DEU activity and no mode lines whatsoever. That, not the keyboard,
was the missing capability.

**`--script FILE` and `--quit-after MS` were added to `discretePanel.py`**, at
the user's suggestion and in the right home: the panel already owns the bit
layout and the momentary-pushbutton semantics. Script lines are
`<ms> <command>`: `mode HALT|STANDBY|RUN`, `ipl` (press, release
`IPL_HOLD_MS` later), `source MM1|MM2|OFF`, `gpcid <n>`,
`bit <A|B> <n> <on|off>`. `bit` sets the toggle **variable**, not just the
wire, because `_republish` re-asserts from the variables and a direct send
would be undone on the next tick. With it the whole IPL runs headless with **no
`fcm-file` argument at all** — the bootstrap is read from the tape over the bus,
which had previously been short-circuited by handing `--ipl` a pre-built
`.fcm`. **Order matters: start yaGPC2 first.** The panel republishes *levels*
on a timer, but the IPL pushbutton is momentary — start the panel first and the
pulse is missed and the machine never IPLs.

**`YAGPC_DEUKEYS` delivers a keystroke sequence**, plus
`YAGPC_DEUKEYS_AFTER=<n>` (default 400 polls) to hold them until GPCIPL's menu
is up. `deumodel.c` had said it plainly — "No keyboard here" — so the
menu-selected load path was unreachable without a human at a real MEDS, and no
headless test had ever exercised it. The encoding, from `meds/deuProto.coffee`:
the header carries `KYBD_MSG` `0x0008`; the count word is
`KEY_COUNT_HIGH | count`; the buffer packs **three keys to a halfword, 5 bits
each**, in `w[2..11]`; `MAX_KEYS_IPL` is 6. Keycodes: digits `0x00-0x09`,
`ITEM` `0x14`, `EXEC` `0x1e`, `OPS` `0x11`, `SPEC` `0x12`, `PRO` `0x1f`.

**The packing bug, and the lesson about which address to watch.**
`deuProto.coffee:157` says it exactly — "bits 15-11 are the first key, 10-6 the
second, 5-1 the third, **bit 0 spare**" — and the shifts used were 10/5/0
instead of 11/6/1, so `ITEM,1,EXEC` packed to `503E` whose top five bits are
`0x0a`. The software decodes with `SLDL R4,5` from the *top* of the halfword
(`GPCRTOPT.asm` `KYBD01`), so a one-bit error silently becomes a different key.
Three earlier attempts theorised about delivery timing, major-function bits and
the `CM4KYBD` checksum — all wrong, and all avoidable by measuring one
halfword. The trap was watching the *wrong* address: `ITEMNO` (`0251e`) is the
same address as `KYBDCON`, a structure base, so it showed only the tape loader
writing. `KYSTRKS` is `DEUMODE+1` (`03b7b`), where the count lands, and `KEY1`
is `02621`, where decoded keystrokes go — watching `KEY1` showed `0x0a` where
`0x14` was sent and named the defect immediately. Fixed, `ITEM,1,EXEC` packs to
`A07C` and `KEY1..KEY3` read `0x14 / 0x01 / 0x1e`.

Ruled out along the way and worth not re-checking: `CM4KYBD`
(`GPCRTOPT.asm:1001`) checksums the whole 16-halfword buffer and requires the
sum to be **zero** (`LHI R3,16 / AH# R0,0(X2,Z3) / BZ CHKSUC / ERROR 150`), and
that check runs *only* for keyed messages — `RSP60` calls it only when the
header's `X'08'` is set, which is why ordinary polls always passed. Our model
already satisfies it: `deu_checksum` returns the negated sum and `w[15]` is
computed after the keys are inserted.

With all of that, **the crash was reproduced headlessly and deterministically**,
matching the user's own run exactly: `commands 56, blocksRead 429, wordsOut
219707, wordsTaken 218987, wordsLost 720`, ending `invalid instruction 0xc9a4
at 0x0008`. (`wordsLost 720` is **not** a defect — `mmumodel.c:211-214` records
that GPCIPL's loader "takes what it wants and stops", and the observed losses
are exact multiples of 360. The headless SSL runs lose zero because the SSL
takes everything. Different loader, not different pacing. This was twice called
"the thread to pull".)

**The BFC CRT discrete does double duty, and that is the real bind.** Register
B bits 6-7 are read by *both* programs for *different* purposes:
`MLIB80/GPCRTOPT.asm:327` `NHI R3,X'0300'   R3 BITS 6-7=EXTRACTED BFC CRT
DISCREETS`, then `SRL R3,8` right-justifies it as **DEU_ID** — which display
GPCIPL runs its IPL menu on, with `POLL30`'s `LR R3,R3 / BZ POLL45` taking the
no-CRT path when it is zero. PASS reads the same bits as the **BFC CRT switch**
— which CRT the *BFS* owns. So `--discrete-b 20000000` is GPC 1 + DEU_ID 0 and
`21000000` is GPC 1 + DEU_ID 1; that one digit was the difference between "the
display is dead" and 265 polls / 266 display fills / 8 format fills over 10,000
seconds of simulated time.

The consequence is a genuine bind rather than a bug:

- **bits set** → GPCIPL shows its menu, `ITEM 1 EXEC` works, the applications
  start — but PASS gives that DK bus to the BFS;
- **bits clear** → PASS keeps every DK bus, but GPCIPL takes `POLL45`'s "IPL
  DEFAULT LOAD -- NO DEU SELECTED", and the applications never start.

**The DK1 masking is correct behaviour, not a defect**, and hours were spent
treating it as one. `ARAGPCSW.hal`:

    ARAB_MASK_ARRAY ARRAY(8) BIT(3) INITIAL(
      BIN'000',BIN'100',BIN'010',BIN'001', BIN'110',BIN'110',BIN'011',BIN'101');
    I = INTEGER(ARAB_OLD_DISC$(1 TO 2));    /* BFC CRT switch */
    ARAB_NEW_DEU_MASK = ARAB_MASK_ARRAY$(I+1:);

Index 1 (I=0) is `BIN'000'`, nothing masked; index 2 (I=1) is `BIN'100'` — DK1
masked. The panel's `DEFAULT_ON = {(REG_B,7)}` sets BFC CRT = 1, which tells
PASS the BFS owns CRT 1, so PASS masks DK1 and leaves DK2/DK3 alone — precisely
the measured masks, `xmit=43bfff80 recv=41bfff80`, differing by exactly bus 6.
Traced to its source: `FCMBMASK` (+0x9e enables, +0x81 disables) with the
requester from the SVC old PSW resolving to `0x402a5 = A1AIBGPC (AIBGPCLO)
+0x95`, doing `DO FOR I = 6 TO 8; RECONFIG(AIBV_ASGN_BUS); END` — "REASSIGN DK
BUSES 6-8 TO THIS GPC". `TFCMXMSK` (`09c74`) and `TFCMRMSK` (`09c76`) are both
loaded as `00003000` (mass memory only) and byte-identical to the DASS
reference; the masks *grow* at runtime, so the loss happens when the mask is
applied, not in the mask. The reconfiguration machinery runs only during
initialisation and then stops for good (`FCMBMAN` 48, `FCMBMASK` 36,
`FCMBUSCM` 50, all last at t≈230.911 s, with DK1 masked at t=230.911045 inside
that same millisecond).

**And the whole DK1 chain turned out to be an artifact of running the wrong IPL
sequence.** The user re-read PASS User's Guide Table 2-2 (pp. 52-54): if step 6
(BFC CRT switch ON) is **not** done, step 11 says go to step 13, *skipping*
step 12 (`ITEM 1 EXEC`); step 11 (STBY) itself loads PHASE02 into PASS area 1
and shows mode TB-RUN, taking about 1 m 25 s. Measured with bits 6 and 7 clear
and no keystroke: blocksRead 398, `wordsLost` **0** (720 on every previous
run), `recv=43bfff80` with DK1 **not** masked, and PASS itself driving the DEU
(96 commands, 48 polls, 48 time fills).

**Both IPL paths load identical PASS software**, which kills the "load table 15
loads something else" assumption: default 72 + 55 + 228 + 5 + 38 = 398 blocks;
menu the same *plus* 17 + 8 + 8 = 33 DEU-control-program blocks = 431. Every
structural explanation for the applications not starting on the default path
was eliminated by measurement — the LOADTBL entry (item 15 names the *same*
load area as item 1, `7c00`, and `LOADCHCK` takes both to the PASS-load path),
`FCMAOT` (`TAOTPDE=06f6`, `TAOTPRIO=0032`, same on both), the bootstrap PDE at
`06f6` (same on both), and `FCMLINIT`'s own instruction trace (4000
instructions, differing by a single extra loop iteration). The only differing
input is the BFC CRT discrete and the keystroke it enables. **The
Application Bootstrap Program thread was itself invalid:** PDE `06f6`'s
`TPDEPCT` is `0000` on *both* paths although `FCMLINIT`'s AOT code does
`STH R2,TPDEPCT`, so that is not how `AIB_GPC_LOCATOR` starts on either. (PDE
layout, halfword offsets: +0 `TPDEVENT`, +1 `TPDEPCT`, +2/+3 `TPDEP`, +4
`TPDESTAK`, +5 `TPDEFLGS`.)

`AIB_GPC_LOCATOR` (= `AIBGPCLO`) **is** the program that schedules every cyclic
process — `SCHEDULE DMC_SUPER`, `DMI_MCDS_IN`, `DCICYC`, `ARA_GPC_SWITCH`,
`DDK_HCT_TRANSFER`, `DUP_NSP_MSG_PROC` — so "cyclic processes are not running"
and "AIBGPCLO never runs" are the same fact, not two. On the default path
execution goes `FCMINSSL → FCMLINIT → FCMINIOP → FIOPC1DL → FCMLINIT →
FCMSWMON → FPMIDLE` and stops, with exactly three block transitions between
t=29.7 s and t=45.0 s; `A1AIBGPC` is never entered. That follows from GPCIPL's
own documented behaviour on that route and is **by design, not a defect**.

**Cyclic processing itself measures correct on the path that matters.** On the
menu path: CLK2 3170 fires from t=6.118 s to run end, 772 of them after
t=200 s with a **median gap of 40.0 ms = 25 Hz**, armed once per cycle from a
single address. Clock constants are byte-identical to the DASS reference
(`FPMMTOXH` = `6b49d200` = 1800 s, `FPMMPC1V` = `001fffff` = 2.097 s) and
measured CLK1 period is 2097.2 ms exactly. A 3,648,340-arms-for-668-fires ratio
that looked like a spurious re-arm is GPCIPL's early phase alone.

**Two display observations that were wrong and are worth not repeating.** The
display has no intrinsic "~30 second warm-up" — that figure came from a
panel-less run's wall-clock timing and was generalised from; with
`discretePanel.py` attached the screen appears at MET 00:00:13 on the display's
own ticking clock. And a single-window datagram count is meaningless while
anything is ramping: two 45 s samples starting 8 s after launch straddled
different points of a rising curve and were reported as a difference *between
the tapes* ("B renders, A does not"), then retracted. Sample the time course,
or wait out the ramp before counting anything. An earlier contaminated
measurement in the same thread had **five stray yaGPC2 processes of mine live
on the multicast bus**; the risk was noticed, written down, and the number
reported anyway.

### 8.25 Real peripherals — `--real-time`, the MTU, the intercomputer bus, MM READY

**`--bce-network` requires `--real-time`, and its own help says so.** Every run
in a long thread omitted it, and the resulting failure was silent, remote from
its cause, and cost days: a 511-word display fill queues 511 datagrams, the
POLL behind them lands ~16 ms of *wall* time later (queue depth measured to
819), and `iop.c`'s receive timeout is in *emulated* time — a 5.02 ms MTO that
expires almost instantly. The receive times out with `gotAny=0`,
`iop_bce_error_terminate()` puts the BCE NO-GO, the flight software takes RESET
STATUS1, and the DEU load restarts forever while the DEU correctly keeps
asserting IPL-REQUIRED. With `--real-time` at the default bus word rate the
load completes: all seven FILLTBL blocks, then 309 display refreshes of 196
words at `0x19ee` decoding as "GPCIPL ... LOADED".

This also explains the 2026-08-23 regression window. `a59c9e203` ("pace bus
transmissions against the wall clock") introduced the token bucket to stop the
peer's socket overrunning; before it, datagrams left as fast as `sendto()`
allowed and nothing could ever be queued behind a transfer, so the load
completed even without pacing the wait state. After it, wall-clock pacing only
works if the emulator also *spends* wall time — which is precisely what
`--real-time` does. That commit's own message already warned against the fix
that was attempted here: pacing on simulated time "was tried first and barely
helped, because `cpu_advance_idle_ns()` advances up to 5 ms of simulated time
inside a single call with no wall time passing at all". **yaGPC2 now warns when
`--bce-network` is given without `--real-time`** (`710ae8dd2`).

**Tried and reverted:** holding the BCE receive clock while the soliciting
command is still in the transport's send queue. It cut timeouts 455 → 48 but
*broke* the case that previously worked, and the reason is instructive —
mid-IPL the DEU answers a 16-word poll with **one** word, so that receive is
*supposed* to time out; the timeout is how the bus program learns "still
loading, send the next block", with `gotAny` as the discriminator (1 = advance,
0 = the DEU never heard the poll, restart). Suppressing the timeout removes the
event the sequencing depends on. Note also that **`--deu-model` masked all of
this**: its help says it "answers in the same call", so every solicited reply is
present before the poll asks — and it cannot answer bus questions at all (it
once reported 518 fills while the wire saw none). MEDS was never at fault: a
freshly started MEDS asserts IPL-REQUIRED, and its single-word reply during a
load is the documented mid-IPL rule `deumodel.c` implements identically.

**A DEU peer over the wire** now exists at `/tmp/claude-1000/deustub.py`,
implementing `deumodel.c`'s rules with the same constants and names, so the
whole IPL reproduces headlessly with no MEDS and no GUI. It takes a port base,
a bus number (6/7/8 = DK1/2/3) and an optional `nokeys`/`latekeys`, and can
deliver `ITEM 1 EXEC` itself.

**Three peripheral fixes, all committed**, that took PASS from loading to
running:

- `38e2fcd6d` — **an in-process mass memory must assert its own READY
  discrete.** This is what blocked `ITEM 1 EXEC`: BSL1's `BSRDYDI` spun on
  `NR R6,R5 / BNZ BSRDY08` with `R5=48000000` — BCE 18 selected (`X'0800'`) but
  MMU 1 READY (`X'0200'`) never set — heading for `ERROR 115 MMU WILL NOT GO
  READY`. `iop_discrete_in_a()` computes the ready bits only for a unit whose
  *stored* bit is set, and only `--discrete-a` ever wrote that word; the model's
  own published READY cannot inform us, because `discretes_driven_mask()`
  excludes a publisher's own bits by design — which is why the crew panel showed
  MM1 READY steady while the GPC saw nothing. Unnoticed for so long because the
  harness reads the IPL bootstrap itself instead of executing FCMBOOT, and
  GPCIPL never asks.
- `d7cda7736` — **map the intercomputer bus (BCE 24) by GPC identity**
  (`--gpc-id`), which selecting PFS needs.
- `2331c5e3e` — **the MTU reply is SEVEN words, not six.** `FIOPRMPG`'s
  commander reads the MTU with `#MIN 0,6` and its listener with `#RDLI 6`, and
  the Principles of Operation is explicit that the field is one less than the
  transfer: "The number of bus words actually sent is 1 more than the number in
  the Count Field." So the BCE arms a seven-word receive — observed directly as
  `BCE20 RECV ARM count=7` — and a six-word reply leaves it one short,
  whereupon it times out with `left=1` and error-terminates the BCE onto its
  NO-GO path.

**The MTU is a device on three buses, not a bus.** `FIOCBLKS` names it device
22 (`FIO22020/1/2`) but that is FCOS's device number; the bus address comes from
the BCE program that reads it, and the only six-word command seen on buses
20-22 is IUA 10. Documentation (user): USA005350, *Data Processing System
(Hardware and System Software) Workbook*, §2.6 pp. 54-56 — two oscillators
(OSC1/OSC2) selected by a panel switch feed **three identical accumulators**,
each preparing GMT **and MET** and dumping them onto FC1(FC5), FC2(FC6),
FC3(FC7) for accumulators 1/2/3 respectively, and any GPC may take them from
any of the three. That confirms `--mtu-model`'s targeting — FC1/FC2/FC3 are
BCE 20/21/22, exactly the buses `FIO22020/1/2` name. **The wire format is not
given in the document**, and the GMT-and-MET pairing may well explain the
transfer as 3+3 rather than the header-plus-time shape the model assumes.

**PASS's software clock reads 24 hours, and that is the flight software's own
rule, not an emulator bug.** `FPMMTURM.asm:457`:

    IF    (CHI,R5,LT,X'0030')   GMT IS LESS THAN 1 DAY
    LHI   R5,X'0030'            DEFAULT GMT TO 1 DAY

R5 is the half-hour count, so any GMT under 48 half-hours is discarded and
replaced by exactly 24 h. `--mtu-model` reports GMT counted from zero at
power-on, always under that floor. Two corrections attempt were tried and both
reverted: anchoring GMT to a real day of year (243) *does* remove the defect it
targets — `TCVTSWCM` never written `0x30`, fatal store-protects 5 → 0, CLK2 815
→ 2596 lasting the whole run, DK1 7,919 → 92,655 datagrams with 413 display
fills — but PASS then never starts at all, with 2594 of 2596 CLK2 fires at
`nia=01dbe` on a 0.2 ms median gap and no bus traffic; and day 1 exactly (48
half-hours) is indistinguishable from baseline, since `TCVTSWCM` is `0x30`
either way — **which also disproves the "clock jump invalidates the TQE
deadlines" theory** that had been built on it.

**What the crew actually sees is that 24 h floor plus a 16-bit truncation, and
the truncation is MEDS's.** With PASS driving CRT2 the mission clock always
starts near `000/05:47:40` whatever the wall time — noticed by the user, who
also noticed CRT1 starts at `000/00:00:00`. The time fill is two IBM 48-bit
floats and a conversion word — `deuProto.coffee`'s `timeFillWords` builds it
and `parseTimeFill` reads it back; ours carries
`4515 1f7e84c0 …`, which decodes to **86,519.9 s = exactly 24 h plus the run
time** — the floor above, since `--mtu-model` counts from power-on and never
reaches it. MEDS's own `ibmFloat48` is byte-identical to that decode and gets
86,520 correctly, yet renders `000/05:49:44` = 20,984 s = **86,520 − 65,536**.
So the seconds count is truncated to 16 bits *downstream of the decode*, in the
DPS header rendering, and every observation matches. CRT1 is unaffected because
GPCIPL's own CLOCK1 never approaches 2^16. Cosmetic, and it blocks nothing —
but note that the untried GMT setting (day **1** plus the real time of day)
would clear the half-hour floor by the smallest possible margin *and* bring the
value back under 2^16, fixing the display as a side effect.

**The PCMMU is identified but deliberately not modelled.** `PMUDEV = 10`
(`INCL80/IOMACS.hal:89`); `AIBB_PMU_CW = HEX'006CFF62'` (`AIBGPCLO.hal:262`) →
IUA 13; `FIOPMUBS DC X'00000080'` (`FIOCBLKS.asm:1145`) → BCE 24, the IP bus;
`PMUOIPL1(...,3,AIBV_GMTOI_MTU$(1),...)` → a 3-word reply, and the name
`AIBV_GMTOI_MTU` says it is in MTU format, i.e. the same BCD triple
`mtumodel.c` already builds. Not built, because two details remain unmeasured:
the BCE arms `count=1` at `pc=1ccd2 addr=007a8` (not 3), and the only
read-shaped command on the IP wire is `iua=15 func=0x221 count=480`, while the
IUA 13 traffic is four 31-word *writes* per cycle. Those do not add up to a
coherent transaction, and a model guessed into that gap would answer for the
wrong reason. Note also that the `SEND ERROR$(6:6)` chain which motivated this
was an **artifact of the `--no-halucp-svc` regression** (below) and is not a
live symptom.

**A regression of our own, and how it was recovered.** `git checkout --
src/ageharness.c` destroyed hours of uncommitted work; the lost change was a
single line in `ageharness_configure_from_opts`, `age->halUCP.svcEnabled =
opts->halucpSvc;`. `halucp.c`/`.h` carried the gate and `opts.c` the switch, but
nothing connected them, so **`--no-halucp-svc` did nothing** and HalUCP
intercepted every SVC — including PASS's own, whose numbers collide (13/14/20
are `FPMSET`/`FPMRESET`/`FPMSDERR`). Restored as `fd8d76771` and measured back
to baseline: CLK2 175 → 815, IP 133 → 81,795 datagrams, HAL/S SEND ERROR 1 → 0.
It was recovered from the session transcript at
`~/.claude/projects/<project>/<session-id>.jsonl`, which records every Edit's
`old_string`/`new_string` and every Bash heredoc — that is the recovery route
if it happens again, but the rule is **commit before reverting**.

### 8.26 Why PASS went idle after 26 seconds — the SVC address extension, completed

With everything above in place, PASS IPLed, loaded, started, painted a display
and did real cyclic flight I/O — for about 26 seconds of simulated time
(t≈73 → t≈101), after which Clock 2 stopped and the CPU sat in `FPMIDLE`
permanently. No crash, no fault, no wait state, no hang: the scheduler simply
had nothing left to run. **The cause is one line in `exec_SVC`, and it is the
other half of the fix in §8.23.**

`exec_SVC` saved the effective address's extension as `(ea >> 16) & 0xf`. It
has to be `(ea >> 15) & 0xf`. A sector on this machine is `0x8000` halfwords —
every expansion in `cpu.c` is `sector << 15` — and the 16-bit address field's
own bit 15 is the "expand me" flag that the sector **replaces**, so the four
bits that turn the 16-bit interrupt code back into a 19-bit address begin at
bit **15**, not 16. The flight software settles it: `FPMSVC` ORs this nibble
into a ZCON as a **DSE**, and `FIOSVC`'s `LXAR R3,R3` masks the address with
`0x7fff` and expands it by `dse << 15`. Taken from bit 16 the nibble arrives
**halved** — `0x3832b` was rebuilt as `0x1832b`.

Scale, measured: **6,387 of 33,961 SVCs in one run come from sector 7**, which
is where PASS's applications live (`0x38xxx`). Every one of them handed FCOS a
parameter-list address four sectors low, inside FCOS's own code. Low-memory
SVCs — sector 0, which is all of GPCIPL and the SSL — round-trip correctly
under either formula, which is exactly why this survived every earlier stage.

**The death chain, each link measured:**

1. `FIOSVC`/`FIOINITQ` builds an IOQE out of the "parameter list" at `0x1832b`,
   which is code: `FLGS=b5e2 OPCD=dc0c WDCD=8271 PRI=a2f3 EVNT=9af3`, device
   id 9. `FIOINITQ` copies faithfully; the list itself is rubbish.
2. `FIOBCD[9]` = `0x0f00`, so the phantom request wants buses 20-23 — FF1-4.
3. `FIOPDISP` toggles those four busy in `TCVTBCEB` (`XST`, an **exclusive-or**
   store) and enables the BCEs — then the device-dependent `CASENTRY` indexes a
   table with the garbage op code, branches to `0x04081` (unloaded data
   storage) and takes a program check.
4. The transaction is abandoned **before** `ST R2,TCVTSIOM`, so no `@SIO` is
   ever issued, the BCEs never run, `FIOCMPLT` never toggles the bits back, and
   `TCVTBCEB` keeps `0x0f00` **forever**.
5. `FPMIHPC2`'s wait-queue scan starts a queued IOQE only when all the buses it
   needs are idle (`IF (N,R5,TCVTBCEB,Z)`), so every later MTU read — mask
   `0x0e00`, buses 20-22 — queues behind it: exactly **one IOQE leaked per
   second**, against a pool of 26.
6. Pool dry → `TCVTIOFP` runs off the end to `0x080ce` → the store to that
   "IOQE"'s `TIOQINDX` at `0x080d6` hits protected code → store protect →
   Clock 2 never re-armed → `FPMIDLE` for good.

Before and after, same headless rig:

| | before | after |
|---|---|---|
| PASS stops | t≈101 s | still running at t=316 s |
| `TCVTBCEB` | `0x00000f00` (buses 20-23 stuck busy) | `0x00000000` |
| free IOQE pool | 0 | 26 of 26, at t=120 and t=300 |
| I/O wait queue | 25 stranded | 0 |
| Clock 2 | dead after t=98.88 | arming and firing every 39.5 ms at t=320 |
| software clock | — | 61.9 s → 241.2 s over 180 s of sim: exactly 1:1 |
| idle fraction, t=98.00-98.12 | 95.0% | 92.5% |
| DK2/DK3 | time fills only | display fills too |

**The eight theories this displaced**, each tested and excluded by measurement
before the real cause was found, and all of them looking at t≈98-101 — which is
the *pool draining*, forty seconds downstream of the single I/O dispatch at
t≈60 that never happens: TQE free-pool size (25, 28 and 82 entries all stop at
≈100 s, so enlarging it removes only the store-protect symptom); a corrupt
chain link at `09262`; `AIBGPCLO`'s `SEND ERROR$(6:6)`; the 24-hour software
clock; the `080d6` store-protect as sole cause; crew input delivered during the
live window; PCT cancellation; and the TSIP half-hour time base. The reframing
that finally worked was to stop chasing symptoms at the stop instant and ask
what was scheduled *at the start* with a ~27 s horizon.

**Two map corrections that had misdirected the search**, both recorded because
the earlier identifications were confidently wrong:

- The stride-`0x12` table at `090b2` is the **IOQE** table (`TFIOQ`, 18
  halfwords), **not** the TQEs. The TQEs are the stride-6 chain (`TFTQE`, 6
  halfwords) and the EQEs the stride-`0x0a` one (`TFEQE`, 10). So "TQE
  enqueueing stops at t=98.09" was really I/O-queue activity stopping.
- **The CVT base is `0x140`**, anchored by `TCVTCID` (+0x51) reading 1 for
  `--gpc-id 1` and by the PCT/EQE/TQE/IOE free-pool group at +0x0a..+0x0d.
  `TCVTSIPI` is a **fullword**, so every field past it sits two halfwords later
  than a naive parse of `MLIB80/TFCVT.asm` puts it — which is what made
  `TCVTSWCH` appear at +0x52 rather than +0x54. PCTs are at `0x0827c`, stride
  `0x32` (50 halfwords, exactly `TPCTLNTH`).

**Method, and it is the reusable part.** Everything above came from
`YAGPC_SNAPSHOT=<t1>[,<t2>...]:<prefix>`, which writes the whole of main
storage to a file the first time simulated time passes each of those seconds.
A raw image is what lets the FCOS control blocks — PCTs, TQEs, EQEs, IOQEs, the
CVT, the compools — be read **offline with a script** instead of guessed at
from a trace, and it is what made the leak visible as a table. The
supporting instruments added with it: `YAGPC_TRACEWIN=<from>-<to>:<path>` and
`YAGPC_TRACETRIG=<addr>:<value>:<count>:<path>` (per-instruction traces with
registers, the second armed by a *state* rather than a time, because the event
moved by a third of a second between runs); `YAGPC_EATRACE=<nia>[,...]`
(effective address and contents for named instructions — a register dump says
*what* a wild branch went to, only the EA says *where the address came from*);
`YAGPC_RINGTRIG=<addr>:<value>` (dump the NIA ring when a halfword takes a
value); `YAGPC_SVCTRACE=<path>` (every SVC: site, parameter-list address, base
register, DSE, list contents — which is what made the halved nibble visible);
and `YAGPC_SIOTRACE` (every MSC START I/O, the only place a dispatched
transaction becomes a running BCE). `iop_dump_procs` now also prints each BCE's
receive state and is called at every snapshot: a BCE parked mid-transfer looks
identical to a running one until `recvActive`/`recvLeft` are printed beside
`halt`/`busy`.

**Regression status.** `make test`'s non-SVC failure set is byte-identical
before and after. The SVC exec fixtures expect a constant `2108` for `mem[90]`
**whatever the EA** — the signature of the reference `gpc` never writing the
EA-High field at all — so they were already failing and are the same accepted
divergence §8.23 records.

### 8.27 The count tables are fullwords too — CRT2's missing menu, and a bisect that halved the fix

§8.17 fixed the `@`-family's *branch* forms. Its *count* forms had the same
defect and it was still there: `#TDL`, `#MIN@`, `#MOUT@` and `#RDL` fetched
their word count with `iop_g_eah` — a **halfword** — from a per-bus table at
the same `2*BCE#` bias. Those tables are arrays of `A()` **fullwords**, which is
the shape `#BU@` and `#LBR@` were already fixed to fetch through and the one
`EQU *-36` implies. A halfword read at an even entry returns the fullword's
**high** half, which for any realistic count is zero, so every one of these
instructions moved exactly **one word regardless of the count**. Fixed as
`96ab01cc4`.

**Measured in PASS's own display path.** A DEU display fill is a 2-word header
from the `#TDS` at `0x199ae` plus data from the `#TDL` at `0x199b2`; the DK2
count table at `0x08c94` holds `0000 0016` for BCE 7. Before: **commanded 360
halfwords, 3 sent, every time** — 21 truncations in 40 s on the wire and 0
complete fills. After, with PASS genuinely loaded: **14 of 14 fills complete at
360 halfwords, 0 truncated, 333 of 358 words non-zero**, decoding through MEDS's
own `DEUCharset` to exactly the glyphs on the screen. TIME_FILL is 7 halfwords
sent by `#MOUT`, which takes an immediate count and no table, and always
worked — which is precisely why the symptom was *"a counting clock and no
menu"*.

**Why it had never been isolated: our own stub made a total failure look like a
rounding error.** A fill whose data is one word is commanded as 3 and
*completes*, so the small fills `deumodel.c` and `deustub.py` elicit mostly
work; the worst the stub ever showed was "abandoned 2 halfwords short" on a
count of 5. Real MEDS asks for a whole screen and the shortfall becomes 357.
That is §8.10's "a test peer you configure yourself is not an independent
check", in its most expensive form yet — the crude peer did not merely fail to
find the bug, it *rescaled* it below notice.

**The instrument is the reusable part.** `YAGPC_XMITTRACE=<bus>` prints one
line per bus command with the count it **declares**, against the words actually
**queued** and actually **sent** before the next command. Queued-versus-sent is
the discriminator: short at queue time means the bus program asked for too
little, short at send time means the emulator lost words in flight. **The peer
cannot tell you which** — it can only report that a transfer ended short, which
is why the symptom survived so long against MEDS. The DMA-read counter is taken
in `iop_queue_dma`, the chokepoint, so none of the five instructions that can
start a transmit (`#TDS`, `#TDL`, `#TDLI`, `#MOUT`, `#MOUT@`) is missed.
`YAGPC_DMATRACE` prints `MOUT`/`QDMA`/`DMADROP` beside it.

**False leads, each killed by a measurement rather than by an argument:** the
transport's outbound queue (4,096 deep, with an explicit "dropping a datagram"
message that never appeared); the DMA queue (growable, verified); and
`dmaq_drop_for_bce` on an error terminate, where `YAGPC_DMATRACE` counted
**zero** drops. The words were never queued in the first place.

**Then the fix proved too wide, and the bisect is the record.** `96ab01cc4`
changed all four instructions; only `#TDL` had a measured table. The two
**receive**-side members broke GPCIPL's own menu, and the failure was clean:
`ITEM 1 EXEC` arrived on the wire correctly (header `0008`, count `ff03`, keys
`a07c`, the 16-halfword sum **zero**, so `CM4KYBD`'s checksum was satisfied) and
GPCIPL did nothing with it — `KEY1..KEY3` took no CPU write at all, and the load
stalled at 160 blocks against the 431 a working run reads. Reverting `#MIN@` and `#RDL`
(`5e663c3f5`) restored it: `KEY1=0014 KEY2=0001 KEY3=001e` written at
`nia=021f6`, and 431 blocks read, with the display fills still fixed.

So **`#TDL` alone is the fix**. `#MOUT@` is left converted — it is a transmit,
it does not execute in this workload, and it shares `#TDL`'s direction.
`#MIN@`'s BCE 24 table entry does read `0000 0002`, which is why it looked
right, but the empirical result outranks the reading: **whether the two
reverted forms want the fullword count is open again**, and settling it needs
the flight software's own use of them, the way `FIOBBM` and `BTBCEGEN` settled
`#BU@`.

**The fixtures cannot arbitrate, measured properly this time.**
`test_iop_bce_exec` is 73499/74699 both ways and the failing set is
byte-identical, 1,200 lines either way. Getting that number took forcing a
rebuild: `make` reported the test binary "up to date" after the source changed,
so the first A/B compared the same binary with itself (§8.10).

**Two things seen while measuring and not chased.** `func=005 count=254` to
IUA 8 on DK2 is issued 118 times and transmits nothing — nothing queues for it,
MEDS never replies to IUA 8, and BCE 7 takes **zero** receive timeouts, so it
is consistent with a control- or receive-shaped command rather than a second
truncation, but it has not been identified. And the rendered CRT2 screen is
sparse: clocks, the GPC indicator, the MEDS menu bar and a scatter of F/M
characters. The truncation is fixed and verified; whether that is the *correct*
PASS display for this state is a separate question, and there is no reference
image here to judge it against.

**Two peer-side facts that cost a whole session between them.** MEDS keystrokes
do **not** come from the MDU window: `meds/idp.coffee:93` routes a bus named
`/KYBD/` to `recvKYBD`, so the IDP takes keys from a separate `_KYBD<n>` bus,
and typing into the CRT2 window produced **zero** keyed replies in 348 polls.
`gpcmd key --idp 2 OPS 1 0 1 PRO` puts them on `_KYBD2` and they arrive
correctly (header `0008`, count `ff05`, keys `11/01/00/01/1f`, sum zero). And
with a valid request so delivered, **PASS declines OPS 101 outright**: the
display list is byte-identical either side of it (sha1 `f8536acb6c44`) and no
tape read follows, where a real OPS 1 transition would have to load the G1
major function from mass memory. Phase 2 is `OPS0,SSW`, so whether that
transition exists in this configuration at all is the first thing to establish.
Not chased.

**Still open on the display side:** CRT1's menu **flashes** — a blank/drawn
alternation — with its top section, the `PASS1 1 BFS1 2 PASS2` lines, missing,
while the GPC's own output is provably correct: 41 of 41 fills complete, an
identical 196-word screen written to `0x19ee` every 0.57 s, which is the rate
Don's known-good reference `IPL.fcm` runs at (87 display fills in 45 s). Whatever this is, it is downstream of the wire.


---

### 8.28 Making CRT2 draw GPC MEMORY — an empty format buffer, a renderer that could not reach it, two coordinate frames, and one emulator defect

The "garbage menu" on CRT2 turned out to be four defects in series, in three
different code bases. Each had to be fixed before the next was even visible,
and three of the four were mine to fix.

**The buffer was empty because nothing ever built it.** PASS's entire display
command for the CRT it drives is THREE halfwords — `0003 1fe2 | 2000 1107
1fe2`. `0x2000` is op 2 SUBLIST with sector 0; `0x1107` is op 1 BRANCH to
`0x107`, CFIT slot 7, which `CON80/CFSYSIN`'s `CRTFMTCU=` list gives as
`#PXD0001` = GPC MEMORY. A critical format is *resident* in the display unit,
so no background is sent; ours was 3563 halfwords of zeros and only the
per-cycle variable data drew. `CD0001.dfg:89` confirms the address
independently: `DEULOC=000263`, and 263 decimal is `0x107`.

Three omissions in a row had left it empty. The phase build generated the
`CD****` COMPOOL half of a display deck and not the `XD****`/`XG****` static
half; nothing ever called `dfg deucflm`; and the volume recipe ran
`--sysid SYS8` only, so `DMACDFT1/2/3` were absent from the tape and read back
as zeros. Fixed in `3c232e041`: `tools/build_deucflm.py` runs `dfg` over
CFSYSIN's sixteen members and lays the image out with `dfg`'s own
`deucflm.build`. A static format module is one `ARRAY(n) BIT(16)
INITIAL(HEX'....')` with no address constant, so its constants *are* its csect
image and no HAL/S compile is needed — checked against the historical DFG
output OI301700 still carries, XD0001 463 halfwords and XD0990 40, identical
halfword for halfword.

**The load block's length is the SYSTEM card's `HWDS=`, not the allocation's**,
and getting that wrong cost a bisect. DMACDFT1 is an 8-block (4096 halfword)
allocation holding an `HWDS=E4C` (3660) module, and `MMULDTBL.asm:196` reads
exactly 3660. A checksum written at the end of the 4096 is never seen: the
reader checks the 3660 it read, rejects it and re-reads — four reads of
`4/4/4/8` against the baseline's one, and GPCIPL then never reaches the display
at all. Writing the whole of SYS5 (the FMADEU\* DEU control program included)
hangs GPCIPL the same way, so `--member DMACDFT1/2/3` is the recipe.

**The unit PASS drives is never IPLed.** GPCIPL loads the DEU on the
BFC-selected CRT, and PASS then masks exactly that bus and drives the others,
which nobody has loaded. Demonstrated both ways round. The workaround is a flip
of the BFC switch: select CRT 2 through the IPL so GPCIPL loads that unit, then
flip to CRT 1 after the SSL load and before RUN. Measured, DK2 then takes 92
polls, 172 TIME_FILLs and 86 DISPLAY_FILLs against 6 tiny fills and 2 polls.

**CRT2's keystrokes never left the window.** `meds/mdu.coffee` had
`new KYBD(1,@)` hardcoded, so every MDU window published on `_KYBD1` while
IDP2 listened on `_KYBD2` — keys typed at CRT2 went to the one bus PASS masks.
Deriving the number from the MDU's own primary IDP fixed it; user-confirmed,
and upstream as PR #33.

#### The renderer could not reach the format

Two things in the beam interpreter stopped it drawing, and both had to be right
at once. `deuFCW` resolved a BRANCH as `hw & 0x1fff`, so `1107` became `0x1107`
— empty memory — when the sector comes from the op 2 SUBLIST word ahead of it
and the address is **twelve** bits. And `refresh()` walked only from
`DISPLAY_HEADER`, where the 382-halfword list contains no branch to `0x1fe2` at
all.

Why two passes is the answer to "why is this a MEDS problem": a DFG display is
not one list. Its background is resident, downloaded once during the unit's
IPL, and at call-up the GPC writes only a pointer to it at the top of memory.
GPCIPL's screen, by contrast, is one self-contained 196-halfword block at
`0x19ee` whose single branch stays inside itself — which is exactly why GPCIPL
always looked right and the DFG displays never did.

`CF_PAD = 0x111e` (CFSYSIN's own `PAD=`) terminates the background pass, and
following it is a trap: `111e` under sector 0 is CFIT slot `0x11E`, which is
SPARE and points at `XD0000`, sixteen halfwords drawing "NO CFMT BKGD". That
body is what an empty slot is for; painting it over a background that just drew
correctly is not a return path, and the walker's `visited` guard would have
hidden the mistake by stopping after the damage.

**The drawn lines needed a constant nobody could derive.** `GPC/BUS STATUS`
draws rules between rows, and the deck gives their position as a ROW offset
(CD0060, `VCORDA=(28,95,815,95)`); converting that to a SCREEN offset needs to
know where glyph ink sits inside its cell, which the deck does not say. My own
attempt at `ADJ.vecY = 0` was wrong by more than twice the whole gap. The user
measured it instead — 8 px between one row's bottom strokes and the next row's
top strokes at 1024×1024, so the ink fills 0.70 of a row and the gap 0.30, and
centring a rule in that gap is 4 px = 0.15 row off the old 0.65. **0.50**,
confirmed on screen with no other page regressed.

This work is in **MEDS2** (`~/workspace/MEDS2`), a clone on a branch whose push
remote is the literal string `DISABLED-never-push-MEDS2-upstream`. It is a
deliberate stopgap, superseded the moment Don's own MEDS lands: point
`retest-crt2.sh`'s `SIM=` back at `~/donschmidt/nsts-sim-gpc` and drop the `2`.

#### Two coordinate frames, and what they are not

There are two beam-coordinate conventions on this bus, differing by exactly
**512 in X and 2 in Y**, and which one a word is in depends on who wrote it:

| | GRID | COL_ORIGIN | ROW_ORIGIN | ABS X/Y |
|---|---|---|---|---|
| MEDS (GPCIPL's) | 2048 | 1573 | 364 | 1555 / 364 |
| DFG's | 1536 | 1042 | 366 | 1024 / 1902 |

**Both are historical and genuine, and `dfg` is faithful.** That took three
retractions to establish. `OI301700/SSSRC/XD0001.hal` — original DFG output,
463 halfwords — runs from signed X −987 to +456, sits on the DFG grid 26/31
against 11/31 on the other, has first XPOS 1384 = DFG column 18.00 exactly, and
appears **verbatim at 0x3fc** in the DEUCFLM `dfg` builds today.

MEDS's constants are equally real. Its own comment says they are "calibrated
against captured display memory", and `data/0001-O-GPC_MEMORY.dfb` decodes
under them with **201 of 201** integer columns *and* rows. `MLIB80/MACROS`
lines 7–57 is where they come from — the `PDEF` table GPCIPL's own screen uses,
column 1 at −475 (= 1573 mod 2048), rows +337 stepping −27 — and
`MLIB80/XPOS` emits `DC BL.5'10000',FL.11'&X'`, a signed eleven-bit
coordinate, refusing anything outside ±512 with `MNOTE 8`. That bound
constrains GPCIPL's *own* usage only; it is not a machine-wide legality rule,
which is what two of the retracted conclusions assumed.

**How the DEU distinguishes them is still unknown.** It is not the translate
registers: every XTRN on the wire reads 0 (YTRN 0 or 216), `dfg`'s generated
DEUCFLM contains zero XTRN/YTRN words and zero FCW2s enabling the gate, and it
is loaded into the unit verbatim — 3584 of 3584 halfwords unchanged. GPCIPL's
`MENU12` does use the gate (`FCW2 ANCTL5=1,ANCTL4=1` then `XTRN 0` / `YTRN 0`),
but to zero.

MEDS2 now chooses the geometry **from the list** rather than from a keystroke,
by counting position words outside GPCIPL's ±512 window. A discriminator, not a
legality test; what makes it work is that the populations do not overlap — 0
of 201 and 0 of 250 on Don's captures against 155/272 X and 99/252 Y on DFG
formats. The first cut *toggled* and so alternated every two or three seconds:
the test reads the raw halfword, so the second walk scored identically and
"not worse" kept the flip. Deciding which convention a list is in is a pure
function of the words in it, so it is an absolute choice now.

#### The garbage in the fields was an emulator defect

With the page finally drawing, its data fields read `-0602` where the display
number belongs, `-50`, and rows of `FFFFFFFFFF`, and PASS bracketed the label
`CODE` with a blink FCW1 (`3900`). The path was traced end to end —
`DCIBHDR` at 0x42345 builds the header, sets up a pseudo DDT at `CLOCDDTP`,
and calls `DCI#CON` at 0x42495 — and every candidate along it was eliminated by
measurement: the compool's address constants (99 of 99 correct as halfwords),
the DDT (our generated `CD0001` byte-identical to the historical output, 477 of
477), and the memory itself (`YAGPC_WATCHHW` over a whole run caught ten
stores, all IOP writes from BCE 18 off the tape, and none after; when the
display drew, `CZ2V_MC_REQ` held 0 and `CZ2V_MF_MC` held `0202 2020`).

The defect was in `cpu_g_ea`'s fullword-indirect path: **it shifted a sector
onto every pointer**, including one whose own high bit is clear and which
therefore addresses sector 0. Figure 2-17 names bit 0 MSB, "determines type of
address expansion", and the expansion flowchart's fourth leaf is EXPAND USING
**0000**. Measured at 0x42845 the pointer reads `26f80801` — address `0x26f8`,
DSV=1 — from the ZCON `DCI#DATA` declares as `DC Z(,FCMCBLKS,8)`. `0x26f8`'s
high bit is clear, so the datum is at `0x026f8` where the tape put
`CZ2V_MC_REQ`; applying DSV read `0x0a6f8`, which nothing had written, and
returned the C6C6 IPL fill. Sign-extended by the following `SRA`, that is
−14650. The index sum is also 16-bit and includes the high bit ("all EA/BA
address calculations involve 16-bit operands and bit 0 of the fullword indirect
address pointer is included in these calculations"), so masking to 15 bits
first threw away a carry that decides the expansion.

Verified on a headless boot: `-0602` → ` 0001`, `-50` → ` 0`, `FFFFFFFFFF` →
blank, plus a block of the page that had never drawn at all (`BFS7 14`,
`PASS8 15`, `27 OPTION`, `START 28`, `STOP 29`). The flashing `CODE` went with
it — PASS was bracketing that label with blink because it could not fill the
field, and now emits `3800`.

Three candidates were eliminated first, all wrongly suspected: `exec_D`'s
missing `% 8` (not a bug — for even R1, R1+1 ≤ 7, and for odd R1 the POO says
append 32 zeros, which is what it does); the register-variable shift form
(implemented in `cpu_g_shift_cnt`, and matching PASS's own `SLL`/`AHI`/`CHI`
guard exactly); and `CHARCONV`'s decimal conversion, executed offline against
this emulator's own `q31_div`/`q31_mul32`/SRDL/SLDL over 2006 values with no
mismatch (`ITEN` is `F'0.625'` = 0x50000000, and the 4-bit pre-shift is the
scaling).

`test_cpu_ea`'s fixtures come from `gpc`, which has the same defect; 62 of
20447 disagreed. They are recorded as a known divergence matched **by shape**
— fullword-indirect-with-index, ours below 0x8000, theirs the same address
with a nonzero sector — so regenerating the table cannot silently re-arm the
exception, and anything else in that mode still fails.

#### The clock-only and the flashing screen were one fault, and it was packet loss

Two symptoms that looked unrelated — GPCIPL coming up with only its clock about
half the time, and a rarer variant where everything but the clock flashed —
were the same fault, and it was neither in the flight software nor in the beam
interpreter.

GPCIPL's menu is written **once**: 509 halfwords at `0x19ee` then 254 at
`0x1beb`, 0.05 s apart, never repeated; thereafter only the first 196 words at
`0x19ee`, twice a second. Lose either one-shot fill and there is nothing left
to redraw from.

Proven with two observers on the same multicast group. `dksniff` saw the
509-halfword fill arrive **complete** while MEDS2 received 423 of 509 and
discarded the partial transfer — `transfer abandoned, 86 halfwords short`,
three abandons in that run (54, 30, 86). *Where* the loss falls decides which
symptom appears. Lose the menu body and the walk from DISPLAY_HEADER starts on
a stray `FCW1 3900` — blink on, with nothing after it to clear it — so 318 of
319 glyphs land in the blink group and the whole screen flashes; lose it
elsewhere and the clock updates over a blank screen.

**Why so small a payload overran so large a buffer: the cost is per DATAGRAM,
not per byte.** A 509-halfword fill is about a kilobyte of data spread over
hundreds of bus messages, each charged its own skb overhead, so a burst of
seven fills is nearer 400 KB than 7 KB. `dksniff` survives it because it does
nothing but drain the socket; Electron is rendering when the burst lands.

Fixed in two parts, and confirmed by the user at **0 abandoned transfers across
137 fills** against 3 before. `com/bus.civet` now asks for a 4 MB receive
buffer (`NSTS_BUS_RCVBUF`) and logs what it was actually *granted*, and
`net.core.rmem_max` has to be raised from its 212992 default — a root action.
`sysctl -w` does not persist, so `retest-crt2.sh` checks the value at startup
and prints both the temporary and the permanent fix rather than leaving it to
be remembered.

Finding it needed the log to reach disk. MEDS2 had detected the case all along,
but IDP handed the logger `console.log` — the renderer's devtools — so no
failing run ever left a record. `NSTS_DEU_LOG=<path>` now writes it to a file,
which set against `dk.log` separates "lost on the way" from "arrived and
mishandled".

One earlier clock-only capture showed **no** abandons and no menu on the wire
at all. There the GPC never sent it, and that remains a second, distinct
failure.

#### Still open

- The second clock-only failure above, where the menu never goes out at all.
- How the DEU tells the two coordinate conventions apart. MEDS2 no longer needs
  the answer in order to render — it scores the list and picks the frame — but
  how the real hardware did it is still unanswered.
- The CRT hand-over: GPCIPL follows the BFC switch, replaying its entire init
  on the newly selected unit (zeroing sweep `0x0f49`/`1146`/`1343`/`1540`/
  `173d`/`193a`/`0002`, then 509@`0x19ee` + 254@`0x1beb`) and no longer polling
  the old one, whose POLL FAIL is just that. Measured on a live run. The PASS
  load had completed 11 s earlier and no second load appears before RUN, so the
  repeat `ITEM 1 EXEC` was unnecessary. The user reports the hand-over is
  conspicuous and yet rare, so the *normal* case must be GPCIPL not following
  the switch — something intermittent in when it re-reads the BFC discrete.
- One column: our title starts one column right of Don's capture (deck XC=18
  against his 17). Left alone deliberately.
- The vertical proportion. The cell rows are right — the glyph trace matches
  XD0001's deck and Don's capture row for row — but a real MCDS CRT gives its
  26 lines the whole screen and an MDU gives them the area above its menu bar.
  Closing that is an MDU *layout* change, not a rendering fix, and it is
  cosmetic.


### 8.29 Why `OPS 901 PRO` did nothing — a major function nobody could see

With GPC MEMORY drawing correctly, every OPS transition typed at it was
ignored. `OPS 901 PRO`, `OPS 201 PRO`: no screen change, no scratch-pad
complaint, nothing read from the tape. The standing explanation was that the
GNC9 and PL9 overlays are not on our tape. That is true, and it was not the
reason.

#### PASS was not failing silently

Which is what the user doubted, and was right to. `SSSRC/DM6OPS` enumerates
nine refusal reasons in `DM6V_ERR_TYPE` — 0 none, 1 NO TARGETS IN RUN, 2 no
target GPCs from the GRT, 3 not overlay initiator and not in main memory, 4
mode recall from application, 5 mode-to-mode illegal, 6 from keyboard and not
requested to target GPC/RS, 7 from application and not in main memory, 8
illegal transition, and an undocumented 9 where `DM6_T_VALIDITY` fails. It
writes each to `DMZ_LOG` and calls `FMPT_UI_OPERR` (ILLEGAL ENTRY) only for
anything **above** 1; ERR_TYPE 1 raises a GPC CONFIG fault *message* instead,
which is why nothing appeared on the scratch pad. We had simply never looked at
the log.

`SSSRC/DMZLOG` is 150 two-halfword sets, filled `FFFF`, with
`DMZB_LOG_ALIGNMENT INITIAL(HEX'0C5C')` beside it as a findable marker and
`DMZV_SET_NBR` as the next slot. The array **follows** the marker — declaration
order is not layout order. Our request had written two entries:

    d609 0001    LOG ON OPS/MODE   -> OPS 9, mode 1
    d6f1 0001    D6F1 = NON MODE RECALL, ERR_TYPE = 1, "NO TARGETS IN RUN"

So the request reached the OPS processor, passed the transition table, and
stopped at the target check. That is why it never touched the tape.

#### Four wrong answers first

Each was measured, and each was wrong.

*The GPC sets are empty.* `CZ2B_CS` and `CZ2B_RS` are both `0000`, so
`RUN_GPC` looked unpopulated. Half right, and the wrong half mattered:
`DMCSUP` runs on every MCDS event and does `CDMB_RSALL = CZ2B_RS$(TFCMID;) OR
CDMB_RSCS_MSK$(TFCMID:*)`, so RS_ALL carries **self** even when both sets are
empty. `RUN_GPC` reduces to `SELF AND TARGET_GPC`.

*Assign a memory configuration first.* GPC MEMORY's `45 CONFIG` / `46 GPC` /
`STORE 47` is the crew's route to one. Keyed headless, `CZ2V_MC_REQ` stayed
`0000` and the refusal reproduced exactly.

*We must be the wrong GPC.* The GRT sets between them name GPCs 1, 2 and 4, we
had failed as 1 and 2, so GPC 4 was the falsifiable test. **It failed
identically.** At that point GPC 1, 2 and 4 all gave ERR_TYPE 1 — a uniform
result across the whole set, which by this document's own standing rule should
have pointed straight at the harness. It did not, and that cost the most.

*PASS ignores our item entries.* Withdrawn the same session. Two attempts had
produced no change and an `ILLEGAL ENTRY` on screen — but the ILLEGAL ENTRY was
mine. A repeated `ITEM 1 EXEC`, harmless on GPCIPL's own menu, is *input* once
PASS owns the page, where `ITEM 1` is not valid. With the retry removed,
`ITEM 53 +1 EXEC` is accepted with no complaint. **A retry that is harmless on
one screen is input on another; do not leave one in a measurement.**

#### The answer: the GRT lookup is keyed on the major function

`DM6_AMT_GRT_SEARCH` finds the GRT row whose major function *and* OPS number
match the request and whose memory-configuration number equals its own index;
`DM6_TARGET_RUN_GPC` then turns that row's GPC set into `TARGET_GPC` via
`TARGET_GPC$(12 TO 16) = TSET$(1 TO 5)`. Read out of the loaded image —
`CZ2V_GRT_TAB` at `0x28ad`, `CZ2B_GRT_GPC_SET` at `0x26fc`, compool `#PCZ2COM`
at `0x23f4`:

| request | GRT index | GPC set | TARGET_GPC | targets |
|---|---|---|---|---|
| MF 1 **PL** OPS 9 | 6 | `4400` | `0008` | **GPC 2 alone** |
| MF 2 **GNC** OPS 9 | 9 | `f000` | `001e` | GPCs 1–4 |

We ran as GPC 1 with the switch at PL. `TARGET_GPC` was GPC 2, SELF's bit
`0x0010` was not in it, `RUN_GPC = ... AND TARGET_GPC` was zero, and
`DM6_TARGET_RUN_GPC` set ERR_TYPE 1. There is no contradiction left in the
earlier measurements: SELF's mask *was* computed correctly and the GRT sets
*were* populated, and both facts were beside the point, because the request was
aimed at a different computer.

**The switch was stuck at PL because it was never settable.** `DeuModel`'s
`majorFunc` was declared, used to build every poll header, and assigned from
nowhere at all, so the in-process DEU reported PAYLOAD forever and every
headless OPS request was a PL request. `YAGPC_DEUMF=<0..3>` now sets it.

It also explains the GPC-4 result, which had looked like a refutation of
everything: `0x0002` is not in `0x0008` either. And the clue was in plain sight
the whole time — the user pointed twice at Don's screens reading GPC **2**,
first on the header line and then on `44 DOWNLIST GPC`. At PL, GPC 2 is the
only computer an OPS 9 request targets.

#### Confirmed by experiment, not by argument

Three runs, one variable moved, PASS's own log read back:

| run | `DMZ_LOG` | verdict |
|---|---|---|
| GPC 1, MF PL (control) | `d6f1 0001` | ERR_TYPE 1, NO TARGETS IN RUN |
| GPC 2, MF PL | `d6f1 0000` | **accepted** |
| GPC 1, MF GNC | `d6f1 0000` | **accepted** |

`CZ2V_REC_OPS` says the same from the other end: **0** in the control, where
the reconfiguration was never requested at all, and **9** in both accepted
runs. The request now propagates into `ARC_GPC_RECONFIG`, which is the
machinery that loads an overlay.

#### Does PASS ever try to read the tape? No

All three runs have identical mass-memory activity — 92 trace lines, every one
from the IPL at t=10.3 s, none after. The accepted runs reach GPC
reconfiguration and fail *before* any tape access is attempted. The tape gap is
real, but it is downstream of everything above and is not what is stopping us.

#### The next blocker: no memory configuration

Both accepted runs return `CZ2V_REC_XERR = 1`, which `DM2APP` logs as
`d2ff 0001` and treats as an error. `ARC_OPS_ZERO` (`ARCGPC.hal:1112`) says
where it comes from:

    IF  CZ2V_MC$(ARC_GPC_ID;)=0  THEN  CZ2V_REC_XERR=1;  ELSE  CZ2V_REC_XERR=0;

This GPC has no memory configuration assigned. That is the same missing thing
the user identified twice from Don's video, from the other side: his
`STORE MC=09` against our `MC=__`, and his `MM AREA / PL 52 1 / GNC 53 1 /
SM 54 1` against our three zeroes. One cause, three symptoms.

`SSSRC/AIBGPCLO:441` is where the MM AREA fields come from — during start-up it
matches where PASS was *actually* loaded from against the per-area phase table:

    IF CDJV_MM_AREA$(1:) = 0 THEN
       DO FOR TEMPORARY I = 1 TO 3;
          IF FCMMGPT_STARTING_MM_ADD$(1;) = CDCV_PHASES$(1,I:) THEN
             CDJV_MM_AREA$(1 TO 3:) = I;

Ours stays 0, so the match fails: either the tape puts PASS somewhere
`CDCV_PHASES` does not name, or `CDCV_PHASES` is not populated. Tape-build
shaped, like DEUCFLM and MMDIR before it.

#### What made any of this readable

- **`YAGPC_EAWATCH=lo-hi[,max[,afterSec]]`** (`src/cpu.c`) is `EATRACE` run
  backwards: *which instruction touched this address*, rather than *which
  address did this instruction touch*. That is the question you have when a
  structure was located by searching memory for its contents and no link map
  says what code owns it. It found `DM6OPS`'s transition-table search at NIA
  `0x455f6`/`0x455fc`, with `0x45613` reading the matched entry's
  `DM6B_TRANS_DATA`, starting from nothing but `DM6V_TR_TAB`'s own initial
  values at `0x2c38`.
- **`tools/opsdiag.py`** reads the whole chain out of a snapshot: the GRT rows
  with the GPCs each targets, the GPC sets, and `DMZ_LOG`'s decoded verdict.
  One command instead of a day.
- **Multi-batch `YAGPC_DEUKEYS`** — `@150:ITEM,1,EXEC;@480:OPS,9,0,1,PRO`,
  each batch at its own poll count — makes the whole sequence reproducible
  unattended.
- **The differential-GPC technique**, which needs no symbols at all: run the
  same scenario as two different GPCs and diff the snapshots. GPC 1 against
  GPC 4 gives 22 halfwords holding the GPC ID and 15 holding a per-GPC bit mask
  (`0x0010` vs `0x0002`).
- **Symbols without a link map.** The SDF (`modules/sdfpkg` over
  `PFS/OI340600/SDFLIB`) resolves compool offsets; `#PCZ2COM` sits at `0x23f4`
  in the tape's build, confirmed by `CZ2B_GRT_GPC_SET` matching `CZ2COMMO`'s
  own initialiser halfword for halfword. Names in the SDF are EBCDIC and
  **truncated to 8 characters**, so a grep for `CZ2B_GRT_GPC_SET` finds
  nothing — search `CZ2B_GRT`. What the SDF cannot give is anything resolved at
  LINK time: `TFCMID` has `addr=0` in every unit that names it, and there is no
  `PHASEnn.sym.json` for the tape's PASS build anywhere on this machine.

Recorded and not chased: the tape image's GRT row 5 carries `MC=5` where
OI340600's `CZ2COMMO` source has `MC=0`. Row 7 (SM OPS 9, set `8400`,
targeting GPC 1) has `MC=0` in both and so can never equal its own index, which
is what the search requires.


## Methodology and caveats

**Section 1** items were found during `yaGPC`'s original CoffeeScript→C
port (a byte-for-byte-fidelity port of `gpc run`, not a from-scratch
reimplementation) — every one was confirmed either by direct source
inspection (grep-verified dead code, missing method, corrupted string)
or by hand-assembling a minimal AP-101 machine-code program and running
it against the live `gpc` JS reference before ever trusting the result
(the same discipline used throughout that port: never assume, always
run it and look). All are precisely reproducible via the file paths and
commands given above.

**Section 2** items come from running `yaHALMAT2`'s `~169`-fixture
`test_*.hal` regression suite through `gpc`/`yaGPC` (compiled+linked via
the real `HALSFC`/`lnk101` toolchain — see `yaGPC/tools.md`) and
`yaHALMAT2` itself (built from
`~/git/virtualagc/yaShuttle/yaHALMAT2/src/`, `make clean all`), then
diffing `yaGPC`'s output against `yaHALMAT2`'s. `gpc` and `yaGPC` were
*also* diffed against each other on the same corpus, as a sanity check
that the two haven't drifted apart since the last `yaGPC`
Phase-11 validation — any such drift would itself be a `yaGPC` porting
bug (not a `gpc`-inherited one) and is called out separately if found.

Run configuration for every program: `--interactive --no-trace
--no-verbose --line-width 240 --max-steps 500000`, stdin `/dev/null`
(so any program that actually blocks on real `READ(5)` terminal input
mid-run will hit EOF immediately rather than hang — this means some
discrepancies below may be *specifically about EOF/error-path behavior*
rather than the program's "main line" logic; check each one's HAL/S
source before assuming it reflects normal execution). stdout and stderr
were captured and compared *separately* for every tool (merging them
with `2>&1` produces spurious mismatches purely from interleaving
order — this port hit that exact false-positive twice, once during the
original `yaGPC` Phase 11 validation and once again while building this
sweep; do not repeat it a third time).

Programs that failed to compile standalone via single-file `HALSFC`
(multi-file linking, external functions, container arguments, real-time
task primitives — several of `yaHALMAT2`'s `run_*_fixture.sh` variants
exist specifically because not every test is a simple single-file
compile) are listed as `SKIP-COMPILE`/`SKIP-LINK` in the raw sweep
output (`sweep_raw_results.txt`, checked in alongside this file) rather
than silently dropped. That file has one block per test: `AGREE name`,
`SKIP-COMPILE name`, `SKIP-LINK name`, or a `MISMATCH-GPC-YAGPC`/
`DISCREPANCY-YAGPC-YAHALMAT2` block with the exact (shell-quoted) stdout
from each tool — it's the primary source Section 2 above was
summarized from; consult it directly for any test not given its own
writeup above. To regenerate or extend it: compile+link each
`test_*.hal` via `HALSFC test_NAME.hal --parms=LIST,NOTABLES,SRN,TEMPLATE,NOLFXI,REGOPT,VARSYM,CARDTYPE=FCRMYCZM`
then `lnk101 cards.bin -o test_NAME.fcm --json-symbols test_NAME-lnk101.json`
(see `yaGPC/tools.md`), then run all three tools
(`node dist/gpc.js run`/`yaGPC`/`yaHALMAT2`) with
`--interactive --no-trace --no-verbose --line-width 240 --max-steps 500000`
(the two `gpc`-family tools) or no extra flags (`yaHALMAT2`, though per
2.5 above matching `--line-length`/`--page-length` would be a real
improvement), stdin `/dev/null`, comparing stdout and stderr
*separately* for each pair.
