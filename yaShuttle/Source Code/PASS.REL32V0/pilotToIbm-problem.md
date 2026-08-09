# `pilotToIbm` — remaining problem

## Current problem

`pilotToIbm` converts a BFS `HALSFC --bfs` compile's PILOT object members
(`cards/`) into a PASS/OS360-style object deck that `lnk101` can link and
`yaGPC2` can run. Plain subroutine-calling programs (e.g. `HELLO.hal`) now
compile, link, and run correctly end to end — `synthesize_pass_stack_linkage()`
already handles the case where a program's entry is the "request a stack via
`SVC X'000f'`" pattern.

**`197-P.hal`, `193-TEST_X.hal` (a `GOTO`-target `ON ERROR` + nested
`PROCEDURE` shape), `037-ROOTS.hal` (a `READ`-driven interactive
program, no `ON ERROR` at all), and `219-P.hal` (a multi-tasking
program) are now all fixed** — verified directly with real stdin where
needed, output matches PFS exactly in each case, including no more
trailing traps for `219-P.hal`. Keep all four as regression checks (same
steps as below, substituting the filename).

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
**Update after the `TASK`-stack fix landed**: `219-P.hal` is now clean
(moved above). The other two no longer crash/trap at all — both now exit
0 — but still produce *wrong output*, a more subtle class of remaining
bug:

- **`130-EXAMPLE_N.hal`**: a real, small numeric discrepancy. PFS prints
  `THE ANSWER IS      2.4990000E+05`; BFS prints
  `THE ANSWER IS      2.4989994E+05` — off by ~0.06. The program is a
  `DO FOR V = 250000 TO 0 BY -100 UNTIL ...` loop whose `ALMOST_EQUAL`
  condition is unconditionally `TRUE`, so it should run exactly one
  iteration and exit with `V` at exactly `249900` — PFS gets that
  exactly, BFS doesn't. Does not use `TASK`/`SCHEDULE` (checked), so this
  is unrelated to the stack-linkage work — looks like a genuine
  floating-point/loop-control codegen difference somewhere in the
  BFS→PILOT→`pilotToIbm` path, not a linkage gap.
- **`222-MULTI.hal`**: **likely not a real bug at all.** Its `A`/`B`/`C`
  are declared `DECLARE SCALAR, A, B, C INITIAL(20);` — in HAL/S,
  `INITIAL` binds only to the immediately-preceding name, so only `C`
  is actually initialized; `A` and `B` are genuinely uninitialized. PFS's
  build happens to leave nonzero garbage in `A` (so the `IF A NOT = 0`
  branch runs, computing a real `B`); BFS's build happens to leave `A`
  zeroed (so that branch is skipped, `B` stays at its own garbage-now-
  zero value). Both are "correct" readings of an uninitialized variable —
  there's no reference answer for this file to converge to. Don't spend
  further effort chasing this one; if anything, it's a candidate to drop
  from the regression corpus rather than a target to fix.

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
gap, then `219-P.hal`'s now-fixed per-`TASK` stack gap; the hand-decode/
compare approach below is the same one that found both and is the
natural starting point for `130-EXAMPLE_N.hal` too.)

For `130-EXAMPLE_N.hal`'s numeric discrepancy (the only case left that
looks like a real `pilotToIbm`/BFS-codegen bug — see above for why
`222-MULTI.hal` probably isn't one):

- Hand-decode the raw PILOT member the same way `parse_pilot_member()`
  does, and compare its ESD/RLD/TXT records against the equivalent
  PFS-compiled module (dump the PFS `.obj` with
  `/home/rburkey/git/virtualagc/ASM101S/readObject101S.py`) — this is
  what found the original `@0<prog>` ER / `#E<prog>` PDE gap and the
  per-`TASK` one.
- Since output is only *slightly* off (not garbage), a `--trace`
  disassembly of the `DO FOR ... BY -100` loop's step/compare
  instructions (both builds, side by side) is probably more direct here
  than the ESD/RLD comparison — look for where the loop-control
  arithmetic diverges between the two builds.
- `../PASS2.PROCS/OBJECTGE.xpl` is the original historical PASS2
  object-emission source (`?P`/`?B`-conditionalized for PASS vs. BFS, no
  Python port exists yet) — may or may not be relevant here since this
  isn't obviously a linkage issue; worth a quick check for `DO FOR`
  step-arithmetic codegen differences between the two conditionals.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` (someone else's repo,
  read-only) — `stackCsectNames()` and `patchStackPDEs()` document what
  triggers stack-section generation and PDE binding; kept for reference
  in case `130-EXAMPLE_N.hal` turns out to be linkage-related after all,
  but the symptom doesn't point that way.

## Next steps

- Investigate `130-EXAMPLE_N.hal`'s small numeric discrepancy (see
  above) — the one remaining case that's plausibly still a real
  `pilotToIbm`/BFS-codegen bug.
- Don't chase `222-MULTI.hal` further without first confirming the
  uninitialized-variable read above is wrong — as analyzed, its
  mismatch looks like inherent nondeterminism in the test file itself,
  not something fixable in `pilotToIbm`.
- Rerun the full corpus sweep (95 standalone `PROGRAM` files in
  `../Programming in HAL-S/`, both pipelines, compare `--outfile6` +
  run status) after any further fix, rather than hand-picking further
  cases — it's what found `219-P.hal`/`130-EXAMPLE_N.hal`/`222-MULTI.hal`
  after earlier fixes looked complete from a handful of manual checks
  alone, and then found that `219-P.hal` needed a second look after the
  first "fix" claim for it too. Baseline before the `TASK`-stack fix:
  60/95 clean under BFS; expect that number to have moved with `219-P.hal`
  now fixed — get a fresh count rather than assuming.
- Keep `HELLO.hal`, `197-P.hal`, `193-TEST_X.hal`, `037-ROOTS.hal`, and
  `219-P.hal` passing as regression checks (same reproduction steps as
  below, dropping `--verbose`) — they already work and should stay
  working.
- The 6 BFS-compile-rejected files (`029-DATATYPES.hal` etc., see above)
  are not this document's problem — don't spend time on them here.
