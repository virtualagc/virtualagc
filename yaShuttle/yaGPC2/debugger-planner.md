# yaGPC2 `--debug` mode — planning document

**Status: planned, not started.** This work is intentionally deferred
until the current, higher-priority goal — bringing `yaHALMAT2` and
`yaGPC2` to parity absent any debugger — is achieved (see
`yagpc2-yahalmat2-issues.db` / `problems.md` for that effort's own
tracking). This document exists so the evaluation the user asked for
isn't lost or has to be redone later; nothing below has been
implemented.

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

### Address → HAL/S source-line mapping — SDF is the right approach, and it works

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

**Stage 0 (prerequisite refactor)**: unify the two `run.c` loops, as
above. No behavior change.

**Stage 1 (skeleton + port core `cmd_debug.coffee` commands)**: new
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
`backtrace`/`bt`.

**Stage 2**: `watch`/`unwatch`/`mw`/`mwc`/`mwl`/`wl` (memory
watchpoints) and `set` (register/memory alteration), if not already
folded into Stage 1 — these are already-designed features in
`cmd_debug.coffee`, just a matter of porting effort/priority.

**Stage 3 (separate, later, only if actually wanted)**: HAL/S
source-line display at stops, via SDF (confirmed working — see above:
compile debug targets without `NOTABLES`, parse with `modules/sdf`/
`modules/sdfpkg`). Real, separable work — building the address→statement
lookup and integrating it into the debugger's stop-display — but no
longer gated on any unresolved compiler-side question.

## Verification (once this work actually starts)

- Stage 0: existing corpus/unit test output must be byte-identical
  before/after the loop unification.
- Stage 1+: a new `test/test_debugger.c` (breakpoint add/delete/ID
  stability, address-walking logic) added to the `Makefile`'s existing
  `UNIT_TESTS` pattern, plus an end-to-end scripted-stdin transcript
  test in the style of `test/run_all.sh`/`compare.sh`.
- Where a `cmd_debug.coffee` command is being ported, cross-check
  behavior directly against `nsts-sim-gpc`'s own debugger output for the
  same fixture where practical, the same "run both, diff" discipline
  used throughout this whole project's development.
- Manual exercise of `yaGPC2 run --debug ...` against a real corpus
  fixture, not just unit tests, before considering any stage done.
