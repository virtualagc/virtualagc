# `pilotToIbm` does not reproduce runnable stack/task linkage

## Summary

`pilotToIbm` (this directory) converts a BFS `HALSFC --bfs` compile's PILOT
object members (`cards/`) into a PASS/OS360-style object deck that `lnk101`
can link. The conversion is *structurally* successful — `HALSFC --bfs` →
`pilotToIbm` → `lnk101` completes with no errors, produces a linked `.fcm`,
and the program runs and produces **correct WRITE(6) output**. But almost
no converted program then halts cleanly: right after finishing its real
work, execution traps and spins until the emulator's instruction-count
safety cap kills it. A full corpus sweep (below) found this in effectively
every program that makes a subroutine call — i.e. nearly all of them.

This is a real, currently-open gap, not a corpus-selection artifact or a
downstream `lnk101`/`yaGPC2` bug — see "What's been ruled out" below.
**Root cause is now confirmed** (see "Confirmed: BFS asks its own
runtime for the stack via SVC, PFS doesn't"): BFS-compiled code acquires
its stack via a supervisor call (`SVC X'000f'`) that `pilotToIbm` copies
through verbatim, but which nothing in this pipeline services. A concrete
fix direction is proposed there; it has not been implemented yet.

## How to reproduce

```
export PATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0:$PATH"
export PYTHONPATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0:$PYTHONPATH"
cd /tmp/repro && mkdir bfs && cd bfs
cp "/home/rburkey/git/virtualagc/yaShuttle/Source Code/Programming in HAL-S/HELLO.hal" .
python3 -c "import halsParms; print(halsParms.getParms('HELLO'))"
# SREF,LIST,LISTING2,SRN,TEMPLATE,NOLFXI,REGOPT,LITSTRINGS=3000,CARDTYPE=FCRMUDXCVMWCYCZM
HALSFC HELLO.hal --parms="<parms above>" --bfs --force --clean --archive
pilotToIbm -o HELLO.obj current.results/cards/
lnk101 HELLO.obj -o HELLO.fcm --json-symbols HELLO-lnk101.json
yaGPC2 --interactive --no-trace --no-verbose --symbols HELLO-lnk101.json \
       --line-width 240 --outfile6 out6.txt HELLO.fcm
cat out6.txt   # "HELLO, WORLD!" -- correct
```

The run itself prints:

```
*** HAL/S SVC trapped (ea=0xf, R1=0x0, code=0x0)

*** HAL/S SVC trapped (ea=0x7f0d, R1=0x0, code=0x0)

ERROR: max steps reached (100000)
```

For comparison, the equivalent PFS pipeline (`HALSFC HELLO.hal --parms="..."
-o HELLO.obj --force --clean --archive`, then `lnk101 HELLO.obj -o HELLO.fcm
--json-symbols HELLO-lnk101.json`, then the same `yaGPC2 ...` invocation)
produces the same `out6.txt` content and exits 0 with no trap.

**Prerequisite already fixed**: `HALSFC --bfs` used to crash outright on any
explicit numeric `--parms` override (e.g. the `LITSTRINGS=3000` that
`halsParms.getParms()` supplies by default) with `TypeError: can only
concatenate str (not "int") to str` in
`../../ported/PASS1.PROCS/INITIALI.py` line 292. Fixed in commit
`88783285b` — if you land on a checkout before that commit, apply it first
or nothing below will even compile.

## Corpus sweep

95 standalone `.hal` files from `../Programming in HAL-S/` (files
containing the word `PROGRAM`), each run through both pipelines, comparing
`--outfile6` capture and final run status. Sweep script and raw
`results.json` were scratch artifacts (not checked in); the numbers:

- PFS: 70/95 halt cleanly (the other 25 are mostly files that need a
  multi-unit manifest link — a COMPOOL or a companion file — not a
  single-file compile, so they're not representative of the PFS
  path's own reliability; not investigated further here).
- BFS: sweep script reported 2/95 halting cleanly, but that number is
  itself wrong — see the correction near the end of this document. The
  real figure is 1/95 (`213-GNC_POOL.hal`, a `COMPOOL` with no executable
  code and no stack requirement — it doesn't exercise this bug at all,
  so it isn't a real success either). **Every genuine `PROGRAM` in the
  corpus that needs a stack frame fails identically.**
- WRITE(6) output matched between the two pipelines for 48/95 files —
  but this is a weak signal: most of those "matches" are BFS runs that
  still trapped and hit the step cap *after* producing correct output
  (the trap only happens once real work is already finished), not full
  round-trip successes.

Conclusion: this isn't a per-file quirk. It's a systemic gap that hits
essentially every program that calls a subroutine (which in practice is
almost every program, since even `WRITE` goes through library routines
like `COUTP`/`IOINIT`).

## Root-cause investigation (HELLO.hal case study)

### The linker never allocates a stack section for the BFS build

Comparing `lnk101`'s own section-table output for the two `HELLO.fcm`
links:

- PFS: 12 modules, and the linker log explicitly says `Generating stack
  sections...` / `Generated stack section '@0HELLO' (56 HW / 112 bytes,
  chain)` / `Patched 1 PDE slot(s) with preallocated stack addresses`.
  The section table includes `@0HELLO @ 0x0003CC (112 bytes) [DATA]`.
- BFS (via `pilotToIbm`): 11 modules. No such log lines. No `@0HELLO`
  (or any `@`-prefixed) section anywhere in the table.

### What PFS's object has that the PILOT-converted object doesn't

Dumped both `HELLO.obj` files with `readObject101S.py` (from
`~/git/virtualagc/ASM101S/`). PFS's `$0HELLO` module's ESD list:

```
$0HELLO   SD  CODE  40 bytes
#EHELLO   SD  DATA  12 bytes   <- a "PDE" (Program/Task Descriptor Entry)
#DHELLO   SD  DATA  30 bytes
@0HELLO   ER                   <- external ref to the stack, resolved by the linker
#QIOINIT  ER
#QCOUT    ER
```

`pilotToIbm`'s converted `HELLO.obj` ESD list (parsed straight from the
PILOT member — confirmed by hand-decoding the raw bytes of
`current.results/cards/$HELLO`, not just trusting the script's own
parser):

```
$HELLO    SD  CODE  36 bytes,  stacksize_hw=20 (i.e. CSD's own stack field = 40 bytes)
#DHELLO   SD  DATA  22 bytes
#QIOINIT  ER
#QCOUT    ER
```

**`#EHELLO` (the PDE) and `@0HELLO` (the stack ER) are simply absent.**
`pilotToIbm` *does* already have machinery that looks like it's trying to
produce the PASS-side stack markers — `stack_frame_sym_payload()` emits a
`CONTROL <csect>` / `DUMMY STACK` / `DATA STACKEND` SYM triple, and
`write_pass_module()` emits a free-format `" STACK <csect>"` CTL card
after the module, both gated on `esd.stacksize_hw > 0` (see
`emit_stack_sym` / `emit_ctl_stack` in `pilotToIbm`). Both of those *are*
present, byte-correct, in the converted object (verified with
`readObject101S.py`) — but **neither one is what actually triggers stack
generation in `lnk101` for a NOSDL build** (see next section), so they're
currently dead weight.

### What actually triggers `lnk101`'s stack generation

Read (read-only — this lives in `~/donschmidt/nsts-sdl-dps`, someone
else's repo) `src/lnk101/linker.py`, `stackCsectNames()` (~line 1892) and
its docstring:

> "@-stack CSECTs this link must create ... Primary source: the CON80 `
> STACK $0<prog>` cards ($ maps to @) -- **SDL-mode objects carry no
> stack ERs at all, the cards are the only trigger.** Also **any
> undefined @xxx ERs (NOSDL objects reference their own stack** ...)."

`compileLinkRun` never passes `--concard` to `lnk101`, so the CON80-card
path is dead for this pipeline regardless — meaning `pilotToIbm`'s CTL
`" STACK <csect>"` card (mimicking that path) can't be doing anything
useful here either. The path that's actually live is the **NOSDL** one:
an *undefined `@xxx` ER* is the only thing that makes `lnk101` synthesize
a stack CSECT. PFS's compiler emits exactly that (`@0HELLO` as an ER,
referenced by a relocation in the code). `pilotToIbm`'s output has no
`@`-anything ER at all, so `lnk101` has nothing to trigger on.

Separately, `patchStackPDEs()` (~line 1864) binds the resolved stack
address into a `#E<name>` PDE section's data — which also can't happen
here since `#EHELLO` doesn't exist in the converted object either.

### The compiler-emitted stack SIZE is correct; only the LINKAGE is missing

Read (read-only, original historical XPL, no Python port exists yet)
`../PASS2.PROCS/OBJECTGE.xpl`. It's `?P`/`?B`-conditionalized for
PASS/BFS. The PASS-only (`?P`) block `EMIT_SYM_CARDS` (~line 1452) is
literally where PFS's `STACKEND` SYM entry comes from:

```
CALL EMIT_SYM('STACKEND', MAXTEMP(I), "80");
```

The BFS-only (`?B`) block `EMIT_CSD_CARD` (~line 1705) sets the PILOT
CSD's own stack field the same way:

```
IF (TEMP_TYPE & "C0") = CODE_CSECT_TYPE THEN
   CSD_STACK_SIZE = MAXTEMP(ESD#);
```

Same source value (`MAXTEMP`), two different encodings. This confirms
`pilotToIbm` is reading the right *number* out of the PILOT CSD
(`stacksize_hw`) — the gap is entirely in reproducing the *linkage*
(the `@0<prog>` ER + `#E<prog>` PDE + a relocation in the code that
actually uses the resolved stack address), which `EMIT_ESD_CARDS`'s BFS
half apparently doesn't need to do the PASS way at all, because BFS's
own native linker must resolve this differently. That native mechanism
has **not been identified yet** — see below.

## What's been ruled out

- **Not the RLD-parsing "grouped short form" heuristic** in
  `parse_pilot_member()` (the code path with the comment "Full ACD ...
  Grouped short form (flags, addr only) follows an entry whose flag
  bit0=1"). Hand-decoded the raw RLD record for `$HELLO` byte-for-byte
  independent of the parser (12 halfwords, exactly 3 whole 4-halfword
  entries, nothing left over) — the parser's 3-entry result is complete
  and correct for this file. Whatever's missing was never emitted by the
  BFS compiler into this member's RLD record at all, not dropped in
  translation.
- **Not simply a missing declared-length field.** Tested the hypothesis
  that the CSECT's own SD length should include its stack frame (i.e.
  `data[o+13:o+16] = be24((e.length_hw + e.stacksize_hw) * 2)` instead of
  `e.length_hw * 2` alone, in `write_pass_module`'s ESD-emission loop) —
  patched a scratch copy and reran the full HELLO.hal pipeline. Result:
  the failure mode *changed* (a different, earlier trap: `ERROR: invalid
  instruction 0xc6c6 at 0x0012`, and the *first* trap's `ea=0xf` stayed
  byte-identical to the unpatched run) but did not fix anything. This
  rules out "just make the CSECT bigger" as the fix; whatever's broken is
  about how the stack gets *referenced*, not how much space is reserved for it.

## Confirmed: BFS asks its own runtime for the stack via SVC, PFS doesn't

`GPC.sh disasm` doesn't exist in this checkout (no `yaGPC` sibling
directory, no `GPC.sh` anywhere under `yaShuttle/`) — but `yaGPC2` itself
has a real disassembler: run any `.fcm` with `--trace` (instead of
`--no-trace`) and every executed instruction prints its decoded mnemonic.
Using that against both `HELLO.fcm` builds settles this completely:

```
$ yaGPC2 --interactive --trace --no-verbose --symbols HELLO-lnk101.json \
         --line-width 240 --max-steps 5 HELLO.fcm     # PFS build
[1] 010000 $0HELLO +0000: e8f3 01e6  LHI 0,X'01e6'   R00: 00000000->01e60000

$ yaGPC2 --interactive --trace --no-verbose --symbols HELLO-lnk101.json \
         --line-width 240 --max-steps 5 HELLO.fcm     # BFS build (via pilotToIbm)
*** HAL/S SVC trapped (ea=0xf, R1=0x0, code=0x0)
[1] 010000 $HELLO  +0000: c9fb 000f  SVC X'000f'
```

PFS's very first instruction loads register 0 with `0x01E6` — the
halfword address of the `@0HELLO` stack section the linker generated
(`0x0003CC / 2 = 0x01E6`, confirmed by direct arithmetic against the
section table). This is the `LHI` + `@0<prog>`-ER-relocation mechanism
described above, now confirmed at the instruction level, not just from
the RLD table.

BFS's very first instruction — at the exact same offset, same 4-byte
length — is a **genuine `SVC X'000f'`**, not an unpatched load. It is not
a placeholder waiting for a relocation that never arrived; it's a
deliberate supervisor call the BFS compiler emits to (presumably) ask its
own native runtime for a stack. `yaGPC2` doesn't implement whatever
service `SVC 0x0F` denotes (it isn't in the FCOS/standalone service set
this harness models), so it traps immediately, before the program body
ever runs — hypothesis 1 in the earlier draft of this section was right,
hypothesis 2 (self-relative addressing) is dead.

This reframes the fix. **`pilotToIbm` cannot make BFS-compiled code work
by patching relocations or CTL cards around it** — the object it's
converting was compiled assuming a *different runtime contract* for
stack acquisition than the PASS/standalone one `lnk101`+`yaGPC2` support.
The two realistic directions:

1. **Rewrite the instruction.** When converting a program CSECT with
   `stacksize_hw > 0`, detect this specific leading `SVC X'000f'` pattern
   (verify it's *always* exactly this opcode/operand across other
   examples — `104-EXAMPLE_1.hal`, `071-DARTBOARD_APPROXIMATION.hal`, and
   others in the sweep also `pfs=trap` for unrelated reasons and are
   already-linked PROGRAMs worth checking too) and replace it with the
   4-byte PFS-equivalent (`LHI 0,<halfword-addr-placeholder>`) plus a
   real `@0<prog>` ER and an RLD entry targeting byte offset 2 of this
   CSECT — i.e. literally synthesize what `EMIT_SYM_CARDS`/
   `EMIT_ESD_CARDS`'s PASS-side code would have produced, using the
   `stacksize_hw` value `pilotToIbm` is already extracting correctly, and
   also emit the missing `#E<prog>` PDE SD section so
   `lnk101`'s `patchStackPDEs()` has somewhere to bind the resolved
   address (see `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` around
   line 1864 for the PDE's expected 12-byte-per-slot layout). This keeps
   the whole thing working through the existing PASS-format linker with
   no changes to `lnk101` or `yaGPC2`.
2. **Implement `SVC 0x0F`'s real semantics** in `yaGPC2` instead, if it
   turns out to be a documented, general BFS runtime service rather than
   a linker-era artifact (check `USA003090`/BFS-specific HAL/S-FC
   documentation, and the SVC-number tables already used by
   `halucp_check_trap()`/`halucp_is_trap_addr()` in `yaGPC2/src/halucp.c`
   for the existing SVC-interception convention). More invasive, but
   might be the more correct long-term answer if BFS-format objects are
   meant to be a first-class target rather than always converted through
   `pilotToIbm`.

Direction 1 is almost certainly less work and doesn't touch `yaGPC2` or
`lnk101` at all — start there.

## Correction to the corpus sweep: real BFS clean-halt rate is 0/95, not 2/95

`197-P.hal` was originally reported as the one non-COMPOOL BFS success.
That was a **bug in the sweep script**, not a real exception. Rerunning
it by hand:

```
Generating stack sections...
Generated stack section '@0P' (80 HW / 160 bytes, chain)
...
*** HAL/S SVC trapped (ea=0x0, R1=0x0, code=0x0)
ERROR: max steps reached (100000)
```

— it fails exactly the same way as `HELLO.hal` (its `$P` CSD does have
`stacksize_hw=44`, i.e. a real, nonzero stack requirement; `lnk101`
*does* generate `@0P` for it, because — unlike `HELLO.hal` — some other
code in this file evidently *does* emit an `@`-something ER that
triggers `stackCsectNames()`'s NOSDL path even without `pilotToIbm`
producing one for the SVC-stack CSECT itself; worth understanding why,
but it doesn't change the outcome). The sweep script's `subprocess.run(...,
timeout=30)` handler discarded `e.stdout`/`e.stderr` entirely on a
timeout (`except subprocess.TimeoutExpired: return R with stdout="",
stderr="TIMEOUT"`), and `197-P.hal` runs long enough (matrix ops,
100000-step cap) to cross that 30s wall on this machine — so its real
"trapped, then hit the step cap" outcome got silently reclassified as
"clean" by the sweep's own bug. **Every genuine `PROGRAM` unit in the
95-file corpus that needs a nonzero stack fails identically.** The only
sweep row that's a real success is `213-GNC_POOL.hal`, and only because
it's a `COMPOOL` with no executable code and no stack requirement at
all — i.e. it was never exercising this code path in the first place.

## Relevant files

- `pilotToIbm` (this directory) — the conversion tool itself.
- `compileLinkRun` (this directory) — orchestrates
  `HALSFC [--bfs]` → `[pilotToIbm]` → `lnk101` → `yaGPC2`; the `--bfs`
  support here is currently uncommitted in the working tree.
- `halsParms.py` (this directory) — default `--parms`, shared by
  `compileLinkRun`/`compilePASS`/`compileLinkCompare`.
- `PASS2.PROCS/OBJECTGE.xpl` — original historical PASS2 object-emission
  source, `?P`/`?B`-conditionalized for PASS vs. BFS; not yet ported to
  Python, only readable as reference. `EMIT_SYM_CARDS`/`EMIT_ESD_CARDS`
  (PASS side, ~1452-1680) and `EMIT_CSD_CARD` (BFS side, ~1705) are the
  relevant procedures.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` — **someone else's
  repo, read-only**: `stackCsectNames()` (~1892), `patchStackPDEs()`
  (~1864), `_deckStackNames()` (~1392) document exactly what triggers
  stack-section generation.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/stacksizer.py` — how a generated
  stack CSECT's size is computed from `STACKEND` (`MAXTEMP`) values.
- `/home/rburkey/git/virtualagc/ASM101S/readObject101S.py` — dumps a PASS
  object deck's cards/ESD/SYM/RLD structure; used throughout this
  investigation to compare the two builds' `HELLO.obj`.
- `../Programming in HAL-S/*.hal` — the corpus used for the sweep; ~90 of
  98 files are standalone single-unit `PROGRAM`s suitable for
  `compileLinkRun`/this kind of pipeline test without a manifest.
