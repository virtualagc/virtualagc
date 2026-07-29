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

## Key finding: the encapsulation requirement is already mostly satisfied

`AGEHarness` (`src/ageharness.h`) already holds essentially all
simulator state in one struct: `AP101 gpc` (which itself contains `CPU
cpu`, `IOP iop`, the shared `MemoryBus`), `HalUCP halUCP` (the HAL/S
runtime layer), and `SymbolTable sym` (linker symbol table), plus
bookkeeping. Grepping the tree found exactly one unrelated global (a
`sig_atomic_t` SIGINT flag in `run.c`, appropriate as a global since
signal handlers can't take arguments). The debugger can be threaded
through entirely via an `AGEHarness *` — no new state-encapsulation
refactor is needed for that part of the requirement.

Also already present and directly reusable:
- **Disassembly**: `instr_to_str(hw1, hw2, out, outSize)`
  (`src/cpu_instr.c`/`.h`), fixture-tested against 20,000 cases.
  `instr_decode()` reports each instruction's length in halfwords
  (`InstrDesc.pb.origLen`), needed to walk sequential addresses for a
  multi-instruction disassembly range.
- **Register snapshot/diff**: `ageharness_snapshot_regs()` /
  `ageharness_diff_regs()` (`src/ageharness.h`/`.c`), already used by
  `--trace`. `trace_format_reg_dump()` (`src/trace.h`) already formats
  every register/PSW field for display — directly reusable for an
  `info registers` command.

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

### Address → HAL/S source-line mapping (corrected approach)

An initial pass at this plan proposed chaining two HALSFC compiler
reports (`pass1.rpt` for statement→source-text, `pass2.rpt` for
statement→address) — **the address half of that is wrong and has been
corrected**: `pass2.rpt`'s assembly listing is generated *before*
linking, so its operand/address fields don't reflect final, linked
addresses. Per the user's correction:

- **`pass1.rpt` is the right, and a reasonably reliable, source for
  source-line text.** It is not free-form text — it has a distinct,
  detectable fixed-column format using vertical bars, the same format
  both `yaHALMAT2`'s own `src/srcmap.c` and `unHALMAT.py` already parse
  successfully. Reusing/porting that parser (rather than inventing a
  new one) is the right move when this work actually starts.
- **Addresses must come from a true (post-link) disassembly**, not
  `pass2.rpt` — i.e. `yaGPC2`'s own `instr_to_str`/`instr_decode` walking
  the real, loaded memory image, the same mechanism the debugger already
  needs for `disassemble`/`x/Ni` anyway.
- **Correlating a real address back to a HAL/S statement number** needs
  a compiler-provided symbol table the debugger hasn't had reason to
  look at yet (something beyond the `.sym.json`/`.symtypes.json` files
  `src/symboltable.h` currently loads) — per the user, this data exists
  and "is no problem," just not yet investigated. **This is the one
  open item to actually dig into when this work begins** — find and
  read the format of whatever compiler output file carries statement↔
  address correlation, rather than trying to derive it from `pass2.rpt`.

### Backtrace — revised: recent-instruction history, not a call tree

The original evaluation recommended against `backtrace` entirely,
reasoning that AP-101S/HAL/S's actual link-register/stack-frame save
convention would need to be reverse-engineered to walk a real call
stack. **Per the user, a simplified version is still worth having**: a
`backtrace`/`bt` (or similarly-named) command that shows the last *N*
instructions actually executed (address + disassembly), not a
call-tree walk. This needs only a small circular buffer of recent
(NIA, disassembly) pairs updated every step — cheap, low-risk, and
useful for "how did I get here" orientation without needing to
understand the runtime's calling convention at all. Worth including in
an early stage.

## Recommended command set and staged rollout

**Stage 0 (prerequisite refactor)**: unify the two `run.c` loops, as
above. No behavior change.

**Stage 1 (skeleton)**: new `src/debugger.h`/`src/debugger.c`, opaque
`Debugger` type owning its own REPL state (breakpoint list keyed by ID,
one-shot step-mode flag, htrace flag, last-command-repeat buffer, and
now a recent-instruction ring buffer for the simplified backtrace) —
*not* bolted onto `AGEHarness`/`Options`, since it's session state, not
simulator state. One integration function:

```c
bool debugger_hook(Debugger *dbg, AGEHarness *age, uint32_t nia,
                    uint32_t hw1, uint32_t hw2, long step);
```

called once per instruction (immediately before `ap101_exec1()`,
before the existing HalUCP trap check), returning `true` to proceed or
`false` to stop — mirroring the existing breakpoint-hit path, which
this absorbs (the current single `--break`/`hasBreakpoint` field is
seeded into the debugger's own list and the old ad hoc check retired
under `--debug`). Zero cost when `--debug` isn't passed: the hook is
simply never called.

`--debug` (new `Options.debug` bool, `src/opts.h`/`.c`, parsed like the
existing `trace`/`interactive` flags) implies interactive mode, reusing
`batchrunner_run_interactive`'s existing stdin/SIGINT handling rather
than adding a second blocking-I/O path to the batch runner.

Commands: `break ADDR`, `delete [N]`, `step`/`stepi`/`next` (all the
same operation — AP-101S has no call-boundary distinction the way
HALMAT does, so there's no real "step over" to implement separately;
all three names are provided for gdb muscle-memory), `continue`/`run`,
`quit`/`q`, `help`, and the recent-instruction `backtrace`/`bt` (cheap,
folded in here rather than deferred).

**Stage 2 (memory — the explicitly required, currently entirely
missing capability)**: `x/NFU ADDR` (examine), `disassemble
ADDR[,COUNT]` / `x/Ni ADDR` (walks `instr_decode`'s reported length,
same as the main loop), `set ADDR = VALUE` (alter, via
`membus_set16`/`_set32`) — all operating on `age->gpc.ram`, the
combined CPU+IOP address space `NIA` already lives in.

**Stage 3 (registers)**: `set $Rn = VALUE` / `set $FPn = VALUE` (via
`cpu_r`/`cpu_f`), `info registers` (thin wrapper over the already-
existing `trace_format_reg_dump()`), `htrace on|off` if not already
folded in earlier.

**Stage 4 (separate, later, only if actually wanted)**: HAL/S
source-line display at stops, per the corrected approach above — real,
separable work, gated on finding and reading the compiler's own
statement↔address symbol data first.

## Verification (once this work actually starts)

- Stage 0: existing corpus/unit test output must be byte-identical
  before/after the loop unification.
- Stage 1+: a new `test/test_debugger.c` (breakpoint add/delete/ID
  stability, address-walking logic) added to the `Makefile`'s existing
  `UNIT_TESTS` pattern, plus an end-to-end scripted-stdin transcript
  test in the style of `test/run_all.sh`/`compare.sh`.
- Manual exercise of `yaGPC2 run --debug ...` against a real corpus
  fixture, not just unit tests, before considering any stage done.
