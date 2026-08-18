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

---

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
