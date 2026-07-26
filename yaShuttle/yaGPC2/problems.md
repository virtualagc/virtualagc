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

**Start here**: of everything in this file, **Section 2.1** (`ON ERROR`
apparently not stopping the trapping statement's own remaining
execution) looks like the most significant finding — bigger than
anything already known and listed in Section 1. Look at that one first.

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

### 2.6 Not meaningfully comparable: wall-clock/timing/PRNG built-ins

`test_random`, `test_runtime`, `test_date_clocktime` all differ, but
`RANDOM()`, `RUNTIME()`, `DATE()`/`CLOCKTIME()` are inherently
non-deterministic or wall-clock-dependent — `gpc` and `yaHALMAT2` have no
shared PRNG seed convention or simulated master clock, so these are
expected to differ and are not evidence of a bug on either side. Listed
only so a future session doesn't waste time on them.

### 2.7 Real-time task model (`SCHEDULE`/`WAIT`/`TASK`/priority): likely a scope/methodology gap, not a semantic bug

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

### 2.9 Not yet characterized — needs individual follow-up

`test_bfnc_char` (`13` vs `0` for a character built-in function —
possibly a `yaHALMAT2` scope gap analogous to `YERRORS.md`'s finding 3
about the older `yaHALMAT`, or possibly real), `test_bit_conv`
(`CHARACTER(BIT)` conversion: `yaGPC` renders the literal bit pattern
`"00001100"`, `yaHALMAT2` renders `"12"` — a real, checkable semantic
question about what `CHARACTER()` of a `BIT` value should produce),
`test_bit_write` (a bare `HEX'1234'` literal's default bit-width in
`WRITE`: `yaGPC` treats it as 16 bits, `yaHALMAT2` as 32),
`test_tint_null_terminal` (bit-width again: 4 groups of 4 vs. 8 groups
of 4 — likely related to 2.2/the `test_bit_conv` family), `test_link_prog_array`
(integer-style vs. scalar-style `0` formatting — possibly an artifact of
this sweep's simplified single-file link not matching what this
multi-file-linking test actually needs), `test_errgrp_errnum` (`3,3` vs
`4,5`) and `test_errfix_trig` (`3` vs `2147483647` — the latter being
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
test needs, not a real finding). None of these were root-caused in this
pass; see `sweep_raw_results.txt` for each one's exact output.

---

## 3. Additional untapped source: "Programming in HAL/S" worked examples

`~/git/virtualagc/yaShuttle/"Source Code"/"Programming in HAL-S"/` has
**98** `.hal` files (`NNN-NAME.hal`, each with a matching `.hal.lst`
compiler-listing file from a prior compile) — the worked examples from
the "Programming in HAL/S" textbook (Sept. 1978), the same source
`yaGPC`'s own port used for its `gpc/gen/A3GRESCH.fcm`-style example
corpus provenance. As the user noted, **no test fixtures/expected
outputs have been devised for these** — unlike `yaHALMAT2`'s
`src/tests/hal/`, there's no `run_all.sh`-style harness or hardcoded
expected strings here.

This is a large additional pool of real HAL/S programs that could be
run through the same three-way comparison (`gpc`/`yaGPC` vs.
`yaHALMAT2`) as Section 2 above, but doing so usefully would need either
(a) hand-deriving expected output per program (slow, but same rigor as
this file's Section 2 discrepancies), or (b) treating `gpc`-vs-`yaGPC`
agreement as the "known-good" baseline (already established elsewhere)
and only using `yaHALMAT2` divergence as a lead-generator the same way
Section 2 does. Not attempted in this pass — flagged for discussion per
the user's request, not yet executed.

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
