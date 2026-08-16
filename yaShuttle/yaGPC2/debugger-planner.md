# yaGPC2 `--debug` mode — planning document

**Status: implemented (Stages 0–3 complete).** Parity between
`yaHALMAT2` and `yaGPC2` was reached first (see
`yagpc2-yahalmat2-issues.db` / `problems.md`), then this work was done in
full — commits `ca1e9784a` (Stages 0–2) and `466b8c5ac` (Stage 3). This
document is kept as the historical planning/evaluation record; see
"Recommended staged rollout" below for what actually shipped in each
stage. One correction from the original evaluation: the "Address →
HAL/S source-line mapping" section's SDF recommendation turned out not
to pan out once Stage 3 actually started — see that section's own
update, and Stage 3's entry below.

## Original request

> yaHALMAT2 has a debugging mode, activated by the `--debug`
> command-line option. This debugging mode is based on gdb (the GNU
> debugger), and uses a subset of gdb commands, tailored to the
> differences between HALMAT's model machine versus a normal CPU, such
> as the fact that HALMAT doesn't have a memory model as such. Plus, it
> has an additional command ("htrace") that's lacking in gdb. Most
> importantly, it has the "help" command so that you can see what gdb
> commands it supports. The debugger, when stopped at a prompt for user
> input, in addition to showing status information about the HALMAT
> "CPU", such as the current location counter and the "instruction" it
> points to, also shows the current HAL/S source line, although it
> doesn't show that every stop for input, but only if the HAL/S source
> line differs from the last one the debugger showed you.
>
> I would like to add a `--debug` mode to yaGPC2, based on the one in
> yaHALMAT2, but adapted to the different characteristics of the
> AP-101S model vs the HALMAT model machine. The nature of the data
> displayed at stops for user input would be different, the number of
> gdb commands supported would be greater. The extent of the
> command-set supported does depend on the effort vs benefit and would
> depend on what initial planning and analysis told us. At the very
> least, the ability to see and alter the contents of memory would be
> needed, as well as the ability to disassemble the machine code enough
> to display assembly language at the current stop for input, and for
> user-selected memory ranges.
>
> One requirement: Rather than spreading the source code for the
> debugger throughout yaGPC2's source-code, it should be isolated into a
> separate set of source-code files dedicated to the debugger alone,
> and should be integrated into the yaGPC2 source code proper as just a
> small number of function calls, preferably a single call to the
> debugger between each AP-101S instruction executed. To achieve that,
> the state of the AP-101S virtual machine would need to be encapsulated
> entirely within a single structure (rather than global variables)
> that probably does not exist yet in yaGPC2 source code, so that the
> state of the AP-101S could be passed back and forth between yaGPC2
> proper and the debugger entirely through this state structure.

## Major finding: a working debugger for this exact machine model already exists

`~/donschmidt/nsts-sim-gpc/gpc/cmd_debug.coffee` (979 lines) is a
complete, already-functioning gdb-style debugger (`GPCDebugger` class)
operating on `AGEHarness`/`IOHost`/`Instruction`/`HalUCP`/`trace` — the
*exact same* CoffeeScript modules `yaGPC2`'s own `ageharness.c`,
`cpu_instr.c`, `halucp.c`, `trace.c` were themselves ported from
(confirmed: every one of those files' header comments cite the matching
`.coffee` source, the same porting relationship this whole project has
used throughout its development). `cmd_run.coffee`'s `disasm(startAddr,
endAddr)` method (used by the separate, thin `cmd_disasm.coffee` CLI
wrapper) is a working, ~50-line range-disassembler built from
`Instruction.decode`/`Instruction.toStr` plus section/symbol
annotations — the direct CoffeeScript analog of `yaGPC2`'s own
`instr_decode`/`instr_to_str`/`symtable_get_section_at`.

**This changes the recommended approach**: rather than designing a new
command set from scratch inspired only by `yaHALMAT2`'s (very
differently-shaped, HALMAT-level) debugger, the lower-risk, higher-
fidelity path is to **port `cmd_debug.coffee` and the `disasm()` method
to C**, the same way every other `yaGPC2` subsystem was built —
`yaHALMAT2`'s debugger remains useful for cross-checking UX conventions
(like `htrace`) but is no longer the primary template.

`cmd_debug.coffee`'s full command set, enumerated directly from its
source: `step`, `next`, `run`, `reset`, `load`, `break`, `clear`, `bd`
(breakpoint disable), `be` (breakpoint enable), `bl` (breakpoint list),
`mw` (memory watch), `mwc` (memory watch clear), `mwl` (memory watch
list), `watch`, `unwatch`, `wl` (watch list), `reg` (registers), `set`,
`disasm`, `mem`, `xw` (examine word), `deposit`, `sym`, `sections`,
`trace`, `info`, `where`/`loc`/`here` (show current location — *not* a
history/backtrace), `steps` (show step count), `help`/`h`/`?`, `quit`.
Already covers, essentially for free once ported: memory
examine/alter/watch (`mem`/`xw`/`deposit`/`watch`/`mw`), register
examine/alter (`reg`/`set`), disassembly (`disasm`), and symbol/section
introspection (`sym`/`sections`) — i.e. most of the explicitly-required
minimum bar already exists as proven, working logic.

**Confirmed not present there either**: no history/backtrace-of-recent-
instructions command (`where` only shows the *current* location, not a
trail) — the simplified backtrace discussed below is still genuinely
new work, not something to port.

## Key finding: the encapsulation requirement is already mostly satisfied

`AGEHarness` (`src/ageharness.h`) already holds essentially all
simulator state in one struct: `AP101 gpc` (which itself contains `CPU
cpu`, `IOP iop`, the shared `MemoryBus`), `HalUCP halUCP` (the HAL/S
runtime layer), and `SymbolTable sym` (linker symbol table), plus
bookkeeping. Grepping the tree found exactly one unrelated global (a
`sig_atomic_t` SIGINT flag in `run.c`, appropriate as a global since
signal handlers can't take arguments). The debugger can be threaded
through entirely via an `AGEHarness *` — no new state-encapsulation
refactor is needed for that part of the requirement, and it matches
`cmd_debug.coffee`'s own `@age` (an `AGEHarness` instance) being the
thing nearly every one of its commands operates on.

Also already present and directly reusable on the C side:
- **Disassembly**: `instr_to_str(hw1, hw2, out, outSize)`
  (`src/cpu_instr.c`/`.h`), fixture-tested against 20,000 cases —
  the C-side counterpart of `Instruction.toStr`. `instr_decode()`
  reports each instruction's length in halfwords (`InstrDesc.pb.origLen`),
  needed to walk sequential addresses, matching `cmd_run.coffee`'s
  `disasm()` walking `d.len`.
- **Register snapshot/diff**: `ageharness_snapshot_regs()` /
  `ageharness_diff_regs()` (`src/ageharness.h`/`.c`), already used by
  `--trace`. `trace_format_reg_dump()` (`src/trace.h`) already formats
  every register/PSW field for display — directly reusable for `reg`.

## What's genuinely missing and needs new work

### Two near-duplicate execution loops

`src/run.c` has `batchrunner_run()` (batch) and
`batchrunner_run_interactive()` (interactive) — both do, per
instruction: snapshot regs, get NIA, check the single existing
breakpoint, fetch/disassemble/decode, check watchpoints/HalUCP traps,
call `ap101_exec1()`, diff regs, optionally trace-print. **Recommend
unifying these into one shared step function both loops call**, as a
separate, behavior-preserving refactor commit before the debugger
itself — this is *why* the debugger can have one integration point
instead of two pasted-in hook calls, and it's cheaply verifiable in
isolation (existing fixtures should produce byte-identical output
before/after).

### Address → HAL/S source-line mapping — SDF looked right, but wasn't (see update below)

Simulation Data Files (SDF), produced by PASS3 of the HAL/S compiler,
contain a full symbol table (real memory addresses), a mapping of HAL/S
statements to memory addresses, and (if compiled with the `HALMAT` parm)
a mapping of HALMAT instructions to memory addresses too — precisely
the data this feature needs, confirmed directly in the parser's own
source (`sdf.py`'s `statement`/`statementIndexTable`/`srn`/
`pStatementData` handling, matching document USA001556's documented SDF
layout). SDFs do **not** include AP-101S disassembly — only the
symbol/statement/address data — so `yaGPC2`'s own `instr_to_str` is
still needed for the instruction text itself either way.

**The correct parser to use is `virtualagc/modules/sdf/`** (a proper
pip-installable package, `sdf.py`, ~1270 lines) together with
`virtualagc/modules/sdfpkg/` (the higher-level access package) — *not*
`yaShuttle/ported/sdfpkg/sdfParser.py`, an earlier, now-obsoleted
approach an earlier pass of this document pointed to by mistake.

**SDF generation is confirmed working, not a gap.** An earlier pass of
this document reported (based on two failed test compiles) that PASS3
wasn't actually writing SDFs in this project's pipeline — that finding
was an artifact of using this project's own established sweep/test
`--parms` convention, which always includes `NOTABLES`. **`HALSFC` only
runs PASS3 at all when `NOTABLES` is *not* in `--parms`** — `TABLES`
(the default) is what's needed. Verified directly: compiling
`HELLO.hal` with `--parms="LIST,SRN,NOLFXI,REGOPT,VARSYM,CARDTYPE=..."`
(no `NOTABLES`) produced a real `SDFLIB/##HELLO .sdf` file. So: **no
new compiler work is needed** — only a small, cheap workflow change
(compile debug targets without `NOTABLES`), and adopting the
`modules/sdf`/`modules/sdfpkg` parser when this stage is reached. This
meaningfully de-risks Stage 3 below — it's no longer gated on an unknown
compiler-side fix, just on writing the C-side (or shelling out to the
Python) integration once this stage actually starts.

**Update (Stage 3 implementation): SDF was dropped as Stage 3's data
source — but not for the reason first recorded here.** Compiling
`HELLO.hal` without `NOTABLES` and loading the resulting SDF directly via
`modules/sdf` + `modules/sdfpkg` (bypassing the `MONITOR(22)`/`COMMTABL`
emulation layer by driving `cmem`'s mode-0/mode-4 init/select calls
directly, then calling `sdf.parseSDF()` against the result) confirmed the
SDF loads and parses cleanly, and `statementIndexTable` is populated with
14 real per-statement entries — but every entry's `srn` field came back as
six EBCDIC blanks (`b'@@@@@@'`).

**Correction (2026-07-30, commit `4467cfa54`): that blank field was not a
compiler-port gap, and it was never the field to key off anyway.** The
SDF's `srn` is the *source* SRN, source columns 73–78, which is a
different and far less reliable thing than the **HAL/S statement
number** — the 1-based position within `statementIndexTable`, restarting
at 1 in each SDF. It came back blank simply because `HELLO.hal` carries
nothing in columns 73–78, not because `HAL_S_FC.py` fails to fill it in.
A source that does use SRNs populates it.

The practical consequence is small, because the route actually taken was
right all along: `pass1.rpt`'s leftmost column already **is** the HAL/S
statement number. It was merely mislabelled `srn` throughout
(`tools/gen_source_map.py`, `src/sourcemap.h`/`.c`, `src/debugger.c`,
`test/fixtures/hello.srcmap.json`), and has been renamed to `stmt` with no
change in logic and no test disturbed.

One real bug hid behind the mislabelling. When a source *does* populate
columns 73–78, `pass1.rpt` prints the SRN as an **extra leading column**
ahead of the statement number — `000010    1 M|…` rather than
`     1 M|…` — which `parse_pass1()`'s anchored regex did not allow for.
It would not have mislabelled such a file; it would have matched nothing
and silently dropped every statement line in it. Fixed with an optional
non-capturing leading digit-run, verified against real SRN-bearing lines,
with the existing no-SRN fixture unchanged.

**What was used instead: `pass1.rpt`/`pass2.rpt` text reports.**
`pass1.rpt`'s per-statement listing lines (`SRN M|SOURCE_TEXT|SCOPE`)
give the actual HAL/S source text for every statement, keyed by the same
SRN. `pass2.rpt`'s assembly listing has an `ST#N EQU *` pseudo-label at
each statement's code-generation boundary, giving statement `N`'s
CSECT-relative address directly — added to the linker's own section base
address (from `-lnk101.json`), that's the full address→statement map,
with no need for SDF, `modules/sdf`, or `modules/sdfpkg` at all. New
`tools/gen_source_map.py` implements this, with two wrinkles found only
by testing against a real compile: HAL/S's `||` concatenation operator
means source text can't be delimited by the *first* `|` on a listing
line (must use the last); and a statement's `ST#N` marker can land in a
*non-code* CSECT (a zero-code `DECLARE` statement's marker ends up
inside a data-literal CSECT the compiler interleaves into the listing)
and must be bound to the code CSECT's *next* resumption point rather
than discarded, or the debugger shows a stale source line lingering over
code that's really implementing a later statement.

### Multi-unit memory images

A single running `yaGPC2` memory image is very often the *linked*
result of several separately-compiled units (e.g. `176-P.hal` +
`176.1-READ_ACC.hal` in this project's own test corpus) — each with its
own SDF from its own individual `HALSFC` compile (an SDF's "member"
concept, inherited from the underlying Partitioned Data Set format,
plausibly lines up with compilation units directly, worth confirming
when this stage starts). `yaHALMAT2` doesn't face this: it loads each
compilation unit separately and can track which compile's own metadata
belongs to which set of HALMAT instructions directly. `yaGPC2` has no
equivalent built in today — once linked, it's one flat address space
with no unit boundaries visible to the CPU itself.

**Good news, confirmed by inspecting a real `-lnk101.json`
(`176-P-lnk101.json`, from this project's own test corpus)**: the
linker *already* tags every section with the exact compilation-unit
name it came from. Each entry in the JSON's top-level `sections` array
has a `module` field (e.g. `"module": "176-P"` vs. `"module":
"176.1-READ_ACC"`), and `src/symboltable.h`'s existing
`symtable_get_section_at(addr)` already resolves any address to its
owning section — so **"which compilation unit does this address belong
to" is already solved, for free, with data yaGPC2 already loads**,
regardless of which source-mapping route (SDF or `pass1.rpt`) ends up
used for the "what source line is this" half.

Since SDF is confirmed working (see above), this problem likely
dissolves on its own once this stage starts, provided SDF "members" are
indeed keyed by compilation-unit name the same way the linker's own
`module` field already is — worth confirming directly against a
multi-unit compile's own set of SDFs when this stage begins.

**Update (Stage 3 implementation): resolved.** The reasoning above was
built around SDF's own "member" concept, which is moot now that SDF isn't
used at all (see the pivot noted above). The wiring it called for has since
been built, and along exactly the line this section originally proposed:
`tools/gen_source_map.py --unit MODULE=PASS1:PASS2` (repeatable, or via an
`@argsfile` when there are hundreds of units) builds one JSON covering
every compiled unit in a linked image, `src/symboltable.c` gained
`symtable_get_module_at()`, and `src/sourcemap.h`/`.c` dispatch lookups by
that module name.

Two things had to be got right that the proposal did not anticipate.

The **code/data classification of a CSECT** — which `parse_pass2()` needs —
is not a name-prefix question at all. Reading `lnk101`'s own
`_ZONE_BY_PREFIX` rule settles it: `#C…` names are code only because CODE
is the *default* zone, so keying off the prefix would be reading a
coincidence. It is resolved instead from each CSECT run's own `TIME:`
instruction annotations, which are self-contained within `pass2.rpt`.

And **statement numbers are only unique within a compilation unit**, so the
debugger's "only reprint the source line when the statement changes"
tracking had to carry the module name alongside the number. Without it,
two different units' own statement *N* look like no change at all.

Verified end to end against a real two-unit link already in this repo's
corpus — `176-P.hal` calling `176.1-READ_ACC.hal` via `SCAL` and back —
with new `test/fixtures/debugger_multiunit_*` alongside
`176-P.fcm`/`176-P-lnk101.json`/`176-P.srcmap.json`.

**A driver for it:** `compileLinkRun --filename=@F`, where `F` lists HAL/S
file paths one per line in compile order. It loops `HALSFC` over each file,
links every resulting `.obj` in one `lnk101` call — `lnk101` already
supports `@LISTFILE` expansion, which is real but undocumented in its
`--help` — and builds one multi-unit source map through
`gen_source_map.py`'s own `@argsfile`. A COMPOOL or template-only file such
as `176.0-SUPER_VECTOR.hal` produces an object with no executable code, and
including it in the manifest is harmless: `lnk101` links it in as one
zero-size section and changes nothing else. `build_unit()` now skips such a
unit with a warning rather than failing the whole build over it. A fresh
end-to-end run through this path reproduced the checked-in source map
byte-identically, module order aside, and the linked program ran to
completion with correct physics output.

### Backtrace — simplified: recent-instruction history, not a call tree

Neither `yaHALMAT2`'s debugger nor `cmd_debug.coffee` (which only has
`where`/`loc`/`here`, showing the *current* location, not a trail) has
anything like this today — it's genuinely new. Per the user, a
simplified version is worth having: a `backtrace`/`bt` command showing
the last *N* instructions actually executed (address + disassembly),
not a call-tree walk. Needs only a small circular buffer of recent
(NIA, disassembly) pairs updated every step — cheap, low-risk, useful
for "how did I get here" orientation without needing to understand the
runtime's calling convention at all.

## Recommended staged rollout

**Stage 0 (prerequisite refactor, done — commit `ca1e9784a`)**: unify
the two `run.c` loops, as above. No behavior change (verified
byte-identical against a pre-refactor baseline across a batch/
interactive/trace/watch/break argument matrix).

**Stage 1 (done — commit `ca1e9784a`)**: skeleton + port core
`cmd_debug.coffee` commands. New
`src/debugger.h`/`src/debugger.c`, opaque `Debugger` type owning its own
REPL state (breakpoint list, one-shot step-mode flag, htrace-equivalent
flag, last-command-repeat buffer, recent-instruction ring buffer for the
simplified backtrace) — *not* bolted onto `AGEHarness`/`Options`, since
it's session state, not simulator state. One integration function:

```c
bool debugger_hook(Debugger *dbg, AGEHarness *age, uint32_t nia,
                    uint32_t hw1, uint32_t hw2, long step);
```

called once per instruction (immediately before `ap101_exec1()`, before
the existing HalUCP trap check), returning `true` to proceed or `false`
to stop — mirroring, and absorbing, the existing single-breakpoint check
(`--break`/`hasBreakpoint`). Zero cost when `--debug` isn't passed: the
hook is simply never called.

`--debug` (new `Options.debug` bool, `src/opts.h`/`.c`) implies
interactive mode, reusing `batchrunner_run_interactive`'s existing
stdin/SIGINT handling.

Port from `cmd_debug.coffee`: `step`/`next`, `run`/`continue`, `break`,
`clear`/`delete`, `bd`/`be`/`bl`, `reg`, `disasm` (using `cmd_run.coffee`'s
`disasm()` as the direct model), `mem`/`xw`/`deposit`, `sym`, `sections`,
`where`, `steps`, `help`, `quit`. Add the new recent-instruction
`backtrace`/`bt`. All shipped as designed, plus `trace`/`htrace` and
`info` (with `breakpoints`/`registers`/`sections`/`watches`/`memwatch`
subcommands) folded into Stage 1 rather than left implicit.

One real bug found only by testing against a real fixture, not obvious
from the design alone: the breakpoint-recheck guard on the instruction
immediately after a `next`/`step N` resume was mistranslated from
`cmd_debug.coffee`'s `_execLoop` (whose `ran > 0` skip exists to avoid
re-triggering the breakpoint the loop is *already sitting on* for its
first iteration) — this hook's architecture only ever calls
`debugger_hook` once per address, so there's no equivalent "already
sitting on it" case to guard against, and copying the skip anyway caused
`next`'s own one-shot temp breakpoint to be silently skipped on exactly
the call meant to detect it. Fixed by checking every call unconditionally
and fixing `step N`'s off-by-one at the same time (`stepsRemaining =
count - 1`, since the currently-displayed instruction always executes
"for free" as part of resuming).

**Stage 2 (done — commit `ca1e9784a`)**: `watch`/`unwatch`/`wl` (display-
on-stop expressions) and `mw`/`mwc`/`mwl` (memory write-watchpoints, fed
by a before/after snapshot split across two consecutive `debugger_hook`
calls rather than bracketing `ap101_exec1()` in one place, since the
hook only runs *before* execution) and `set` (register alteration —
`deposit`, from Stage 1, already covers memory alteration). Verifying
`mw` against a real fixture surfaced a real addressing-model gotcha:
`STH 1,X'0005'(0)`'s `(0)` names base register R0, not "no base" — the
actual effective address is register-relative (`R0`'s value + the
displacement), not the literal displacement shown in the disassembly.

**Stage 3 (done — commit `466b8c5ac`)**: HAL/S source-line display at
stops, via `pass1.rpt`/`pass2.rpt` text reports — *not* SDF; see the
updated finding in "Address → HAL/S source-line mapping" above. New
`src/sourcemap.h`/`.c` (JSON loader + address→statement lookup, reusing
the existing `src/json.c` parser) and `tools/gen_source_map.py` (the
`pass1.rpt`/`pass2.rpt`/`-lnk101.json` → JSON export). New
`--source-map <file>` CLI flag; a source line is shown automatically at
each stop only when it differs from the last one shown (matching
`yaHALMAT2`'s behavior from the original request), plus an on-demand
`source`/`src` command. Only handles a single-module compile for
now — see the multi-unit note above.

## Verification (as actually done)

- Stage 0: confirmed byte-identical against a pre-refactor baseline
  build across a batch/interactive/trace/watch/break argument matrix
  (the corpus test harness itself needs external `../yaGPC` and
  `../dist/gpc.js` reference builds that aren't present in every
  environment, so this ran as a direct old-vs-new binary comparison
  instead where the harness itself couldn't run).
- Stage 1+: `test/test_debugger.sh` — three golden-transcript,
  scripted-stdin end-to-end cases (`hello`/`watch`/`srcmap`) against
  `test/fixtures/hello.fcm`, in the style of `test/run_all.sh`/
  `compare.sh`, wired into `make test`. A separate `test/test_debugger.c`
  white-box unit test (as originally planned) wasn't added — it would
  have meant breaking the debugger's intentional opaque-state
  encapsulation for no real benefit over the behavioral end-to-end
  coverage the golden-transcript tests already give.
- Cross-checking ported commands directly against `nsts-sim-gpc`'s own
  debugger output wasn't done in practice (no run-both-and-diff harness
  for it exists) — verification instead relied on direct manual exercise
  against real fixtures, which is what actually caught the two real bugs
  noted above (the `next`/`step N` breakpoint-recheck guard in Stage 1,
  the base-register-relative addressing gotcha in Stage 2's `mw` tests).
- Manual exercise of `yaGPC2 --debug ...` against real HAL/S-compiled
  fixtures (`hello.fcm`, `021-SIMPLE.fcm`) was done throughout every
  stage, not just via automated tests.
