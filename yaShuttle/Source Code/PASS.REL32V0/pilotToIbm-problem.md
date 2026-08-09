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
downstream `lnk101`/`yaGPC2` bug — see "What's been ruled out" below. It
needs someone (or some agent) to pin down BFS's actual stack/task-linkage
convention at the object-code level, which this investigation did not
finish doing.

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
- BFS: **2/95** halt cleanly. One of those two (`213-GNC_POOL.hal`) is a
  `COMPOOL`, not a `PROGRAM` — it has no executable code and no stack
  requirement, so it doesn't count as a real success. The other
  (`197-P.hal`) is a genuine, unexplained exception — see "Open
  questions" below.
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

## The most promising unfollowed lead

Compared the raw bytes of the program CSECT's own first instruction
between the two builds (`readObject101S.py` dump for PFS, hand-decoded
PILOT TXT record for BFS):

```
PFS  $0HELLO @ offset 0: E8 F3 00 00   (opcode E8)
BFS  $HELLO  @ offset 0: C9 FB 00 0F   (opcode C9)
```

PFS's RLD table has an entry relocating **exactly this operand**
(`rel=@0HELLO pos=$0HELLO addr=000002`, i.e. bytes 2-3 of this same
instruction get patched with the stack section's resolved address).
BFS's RLD record — confirmed by the hand-decode above — has **no
relocation at byte offset 2 of `$HELLO` at all**. The operand `00 0F` is
never touched by anything; it's whatever the BFS compiler wrote verbatim.

Two live hypotheses, neither confirmed:

1. `C9 FB` is a different opcode from `E8 F3` entirely (not "the same
   instruction with an unpatched operand") — possibly an SVC-class
   instruction that, under a real BFS-hosted runtime, asks a supervisor
   service for a stack rather than referencing a linker-resolved address.
   If so, the `ea=0xf` trap on the very *first* instruction executed is
   the harness faithfully executing exactly what's there, and
   `yaGPC2`/the BFS runtime model would need to *service* that call, not
   just have `pilotToIbm` patch bytes around it.
2. `C9 FB 00 0F` is a self-relative addressing form (a displacement
   computed under BFS's own addressing convention, valid only if the
   CSECT ends up at the address BFS's own native linker would have put
   it) that breaks once `lnk101` places the CSECT somewhere else using
   PASS's absolute-addressing convention — in which case `pilotToIbm`
   would need to recognize and rewrite this specific instruction form
   into the PASS-style relocatable form (ER + RLD), not merely copy it
   through.

**This wasn't resolved because a disassembler for the linked `.fcm`
couldn't be gotten to run in this session** (`GPC.sh disasm` — script not
found under the paths tried; the `gpc`-style subcommand set documented in
`../../yaGPC2/tools.md` around "GPC.sh run/debug/gui/dump/disasm" may live
somewhere not yet located, or may need the JS bundle built first). Getting
a real mnemonic decode of opcode `C9 FB` (and PFS's `E8 F3` for
comparison) against the AP-101S ISA is the single highest-value next
step — it would likely settle which of the two hypotheses above is right
without further guessing.

## Open question

`197-P.hal` is the one real (non-COMPOOL) program in the 95-file sweep
that halts cleanly under BFS despite calling `WRITE(6)` (which, like
`HELLO.hal`, should route through the same `COUTP`/`IOINIT` library
chain). Worth checking early: does its compiled `$P` CSD actually have
`stacksize_hw == 0` (i.e. the compiler decided it needs no stack frame at
all, so the whole missing-linkage problem is simply not triggered for
this one file), or is something else going on? If `stacksize_hw == 0`
there, it's not a counterexample to anything above — just confirmation
that the bug only bites when a nonzero stack frame is actually needed,
which is true for nearly everything.

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
