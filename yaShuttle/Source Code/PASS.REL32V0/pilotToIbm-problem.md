# `pilotToIbm` — remaining problem

## Current problem

`pilotToIbm` converts a BFS `HALSFC --bfs` compile's PILOT object members
(`cards/`) into a PASS/OS360-style object deck that `lnk101` can link and
`yaGPC2` can run. Plain subroutine-calling programs (e.g. `HELLO.hal`) now
compile, link, and run correctly end to end — `synthesize_pass_stack_linkage()`
already handles the case where a program's entry is the "request a stack via
`SVC X'000f'`" pattern.

**`197-P.hal`, `193-TEST_X.hal` (a `GOTO`-target `ON ERROR` + nested
`PROCEDURE` shape), and `037-ROOTS.hal` (a `READ`-driven interactive
program, no `ON ERROR` at all) are now all fixed** — verified directly
with real stdin where needed, output matches PFS exactly in each case.
Keep all three as regression checks (same steps as below, substituting
the filename).

A full corpus sweep (95 standalone `PROGRAM` files in
`../Programming in HAL-S/`, both pipelines, `--outfile6` capture +
run status) now shows **60/95 halting cleanly under BFS**, up from
essentially 0 before the fixes above landed. 9 files still have PFS
clean / BFS not clean:

- **6 are not a `pilotToIbm` problem at all**: `029-DATATYPES.hal`,
  `198-P.hal`, `199-P.hal`, `200-A.hal`, `203-A.hal`, `205-LOG10.hal`
  fail to compile under `HALSFC --bfs` itself (PASS2 rejects them before
  `pilotToIbm` ever runs) with `ONLY ONE <ON ERROR> ALTERNATE ENTRY POINT
  IS ALLOWED PER TASK OR PROGRAM` / `INDIRECT STACK USAGE CONFLICT` —
  a genuine BFS-compiler-level limitation (these files use more than one
  `ON ERROR$(...)` alternate entry point), not a conversion bug. Out of
  scope for this document.
- **`130-EXAMPLE_N.hal` and `219-P.hal`**: output is byte-correct
  (`THE ANSWER IS ...` / `P: TASKS DEFINED` respectively), but a trailing
  `SVC trapped` still happens after the real work is done. `219-P.hal` is
  notable: it's a multi-tasking program (hence "TASKS DEFINED"), and its
  trap (`ea=0x14a, R1=0x14a0000, code=0x1`) repeats identically three
  times in a row rather than spinning through zeroed memory — worth
  checking whether the stack-linkage synthesis only handles a
  `PROGRAM`'s own `@0<char>` stack and not the `@1<char>`, `@2<char>`, …
  per-`TASK` stacks (`lnk101`'s own comment on `STACK_SEQUENCE`,
  `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` ~1850, documents this
  `@`+sequence-char+characteristic naming for exactly that case).
- **`222-MULTI.hal`**: a more serious, distinct failure — `out6.txt` is
  completely empty under BFS (PFS prints
  `A=... B=... C=...` correctly), and the run hits a genuine
  `*** HAL/S SEND ERROR: RUNTIME: #17 ILLEGAL CHARACTER SUBSCRIPT`
  before spinning to the step cap. This is runtime corruption during
  actual execution, not just a tail-end halt-sequence gap — treat as a
  separate bug from the trailing-trap cases above.

## How to reproduce

```
export PATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0:$PATH"
export PYTHONPATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0"
cd /tmp/repro && mkdir bfs && cd bfs
cp "/home/rburkey/git/virtualagc/yaShuttle/Source Code/Programming in HAL-S/197-P.hal" .
PARMS=$(python3 -c "import halsParms; print(halsParms.getParms('197-P'))")
HALSFC 197-P.hal --parms="$PARMS" --bfs --force --clean --archive
pilotToIbm -o 197-P.obj current.results/cards/ --verbose
lnk101 197-P.obj -o 197-P.fcm --json-symbols 197-P-lnk101.json
yaGPC2 --interactive --no-trace --no-verbose --symbols 197-P-lnk101.json \
       --line-width 240 --outfile6 out6.txt 197-P.fcm
# now exits 0 with correct output -- this file is fixed; substitute
# 130-EXAMPLE_N, 219-P, or 222-MULTI for 197-P to reproduce the open
# problems below instead.
```

Use `--trace` in place of `--no-trace` (with `--max-steps N` to keep the
output short) to see the decoded instruction stream from address 0,
including the wayward branch target.

For comparison, the PFS build of the same file (`HALSFC 197-P.hal
--parms="$PARMS" -o 197-P.obj --force --clean --archive`, then the same
`lnk101`/`yaGPC2` invocations, skipping `pilotToIbm`) runs to completion
with exit 0 and correct output.

## Likely cause / where to look

(This section originally covered `197-P.hal`'s now-fixed entry-prologue
gap; the hand-decode/compare approach below is the same one that found
that fix and is the natural starting point for the open cases too.)

For the trailing-trap cases (`130-EXAMPLE_N.hal`, `219-P.hal`) and
`222-MULTI.hal`'s runtime corruption:

- Hand-decode the raw PILOT member the same way `parse_pilot_member()`
  does, and compare its ESD/RLD/TXT records against the equivalent
  PFS-compiled module (dump the PFS `.obj` with
  `/home/rburkey/git/virtualagc/ASM101S/readObject101S.py`) — this is
  what found the original `@0<prog>` ER / `#E<prog>` PDE gap.
- For `219-P.hal` specifically: check whether `synthesize_pass_stack_linkage()`
  (or whatever superseded it) only synthesizes the `@0<char>` stack for
  the `PROGRAM` itself, and not `@1<char>`, `@2<char>`, … for each `TASK`
  — see `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py`'s
  `STACK_SEQUENCE` comment (~1850) for the naming convention a multi-task
  program needs.
- `../PASS2.PROCS/OBJECTGE.xpl` is the original historical PASS2
  object-emission source (`?P`/`?B`-conditionalized for PASS vs. BFS, no
  Python port exists yet) — worth checking for how `ON ERROR`/`TASK`
  affect entry-point/prologue generation on either side.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` (someone else's repo,
  read-only) — `stackCsectNames()` and `patchStackPDEs()` document what
  triggers stack-section generation and PDE binding.

## Next steps

- Investigate `219-P.hal`'s per-`TASK` stack linkage (see above) —
  probably the highest-value next fix, since multi-tasking is likely
  common across the corpus, not a one-off shape like some earlier cases.
- Investigate `130-EXAMPLE_N.hal`'s trailing trap — it does *not* use
  `TASK`/`SCHEDULE` (checked directly), so it's a different shape from
  `219-P.hal` despite the similar symptom; don't assume the same fix
  covers both.
- Investigate `222-MULTI.hal` separately — it *does* use `TASK` (checked
  directly), so it may share a root cause with `219-P.hal`'s per-`TASK`
  stack gap even though its symptom (runtime corruption, not a trailing
  trap) looks different; worth checking after `219-P.hal` rather than
  assuming it's unrelated.
- Once those are fixed, rerun the full corpus sweep (95 standalone
  `PROGRAM` files in `../Programming in HAL-S/`, both pipelines,
  compare `--outfile6` + run status) rather than hand-picking further
  cases — it's what found `219-P.hal`/`130-EXAMPLE_N.hal`/`222-MULTI.hal`
  after the earlier fixes looked complete from a handful of manual
  checks alone. Current baseline: 60/95 clean under BFS.
- Keep `HELLO.hal`, `197-P.hal`, `193-TEST_X.hal`, and `037-ROOTS.hal`
  passing as regression checks (same reproduction steps as below,
  dropping `--verbose`) — they already work and should stay working.
- The 6 BFS-compile-rejected files (`029-DATATYPES.hal` etc., see above)
  are not this document's problem — don't spend time on them here.
