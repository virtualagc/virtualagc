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
run status) shows **61/95 halting cleanly under BFS**, up from
essentially 0 before the fixes above landed. **But watch the other
number, not just the clean-halt count**: the number of files whose
*output actually matches PFS* dropped from 63/95 to 53/95 across the
same two sweeps — some previously-correct files regressed to producing
wrong-but-non-crashing output. See "New regression" below before trusting
a rising clean-halt count as proof of progress.

9 files still have PFS clean / BFS not clean:

- **6 are not a `pilotToIbm` problem at all**: `029-DATATYPES.hal`,
  `198-P.hal`, `199-P.hal`, `200-A.hal`, `203-A.hal`, `205-LOG10.hal`
  fail to compile under `HALSFC --bfs` itself (PASS2 rejects them before
  `pilotToIbm` ever runs) with `ONLY ONE <ON ERROR> ALTERNATE ENTRY POINT
  IS ALLOWED PER TASK OR PROGRAM` / `INDIRECT STACK USAGE CONFLICT` —
  a genuine BFS-compiler-level limitation (these files use more than one
  `ON ERROR$(...)` alternate entry point), not a conversion bug. Out of
  scope for this document.

The other 2 (of the original 9 — `219-P.hal` moved to fixed above) no
longer crash/trap at all — both now exit 0, and one has since been fixed
at the source-file level:

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
- **`222-MULTI.hal`**: **fixed at the source-file level, not a
  `pilotToIbm` bug.** It was `DECLARE SCALAR, A, B, C INITIAL(20);` —
  `INITIAL` binds only to the immediately-preceding name in HAL/S, so
  only `C` was actually initialized; `A`/`B` were genuinely uninitialized
  stack garbage, differing incidentally between PFS's and BFS's memory
  layouts. Checked the real book source (NASA-CR-... "Programming in
  HAL/S" p.222): the original has no `INITIAL` at all — the example is
  deliberately illustrating an *unprotected race condition* (task `T`
  sets `A=0` asynchronously; the book's whole point is that this file's
  behavior is inherently timing-dependent, contrasted with a
  `LOCK`/`UPDATE`-block fix shown right after it). Whoever adapted it
  into a standalone `.hal` file left `A`/`B` uninitialized rather than
  reproducing that race with real concurrency, which just made the file
  useless as a byte-exact regression check. Fixed by giving `A` a real
  `INITIAL(1)` (see git history for `222-MULTI.hal`) — verified both
  builds now print `A= 1.0000000E+00 B= 2.0000000E+01 C= 2.0000000E+01`
  identically, and this also confirms `219-P.hal`'s per-`TASK`-stack fix
  (`@1MULTI`) is structurally correct, since `222-MULTI.hal` uses the
  same `@1<char>` mechanism. Moved to the fixed list above.

## New regression: several previously-correct files now produce wrong output

Comparing the sweep that found the fixes above against a fresh sweep of
the *current* `pilotToIbm`: 7 files that previously matched PFS exactly
now produce silently wrong (but non-crashing) output. Symptoms range from
tiny to severe:

- Small floating-point drift: `031-DECLARE3.hal` (`3.0000000E+00` →
  `3.0000200E+00`), `080-EXAMPLE_4A.hal` (`4.0000000E+02` →
  `4.0000513E+02`), `137-STATISTICS.hal` (`5.0500000E+01` →
  `5.0499832E+01`), `138-FILTER.hal` (two values, both off by ~1e-5
  relative), `177-P.hal` (`9.0000000E+00` → `9.0000200E+00`).
- Exact-integer drift: `052-TABLE.hal` — `1073741824` (2^30, part of a
  doubling sequence) → `1073741845`, off by exactly 21.
- Severe: `GOOGLE-PARALLAX.hal` — `6.2814549896283003E+13` →
  `1.8600000000000001E+08`, a completely different magnitude, not a
  rounding error.

Note `031-DECLARE3.hal` and `177-P.hal` both end in the exact same
suffix, `...0000200E+00` — both are the *last element of a 3-vector*
being printed, which may be a real clue (a fixed-offset corruption
pattern rather than random noise). None of these 7 files use `TASK`;
whatever changed between the sweep that found the `TASK`-stack fix and
this one appears to have introduced a new, distinct bug — possibly in
how much stack space gets allocated/laid out for non-`TASK` programs now
that the `TASK`-stack code path exists, since several of the affected
files use vectors/arrays (more stack-resident temporaries) rather than
plain scalars. **Not yet root-caused — flagging so it doesn't get missed
under the "clean-halt count went up" headline number.**

Two more `DIFF` rows in the fresh sweep, `097-SAMPLE_FLOW.hal` and
`184-EXAMPLE_N.hal`, are **not** new — both already mismatched before
this round of fixes too; not investigated yet either way.

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
# 130-EXAMPLE_N to reproduce that open problem, or 031-DECLARE3 /
# 052-TABLE / 080-EXAMPLE_4A / 137-STATISTICS / 138-FILTER / 177-P /
# GOOGLE-PARALLAX to reproduce the new regression below.
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
natural starting point for the open cases too.)

**For the new regression (7 files, see above) — probably the
higher-priority investigation now**, since it affects files that used to
work: whatever change fixed `219-P.hal`'s per-`TASK` stack likely also
touched how stack space is computed/laid out for plain (non-`TASK`)
programs. Compare `lnk101`'s section-table output (stack section size,
`#D<char>` size/placement) for one regressed file, e.g. `031-DECLARE3.hal`,
against a git-stashed prior version of `pilotToIbm` (or against a file
that still works, e.g. `HELLO.hal`) to see what's different about how
its stack/data sections are now sized or placed. The repeated
`...0000200E+00` suffix on two unrelated files' *last vector element* is
worth chasing specifically — sounds like a fixed-offset write landing one
element past where it should.

For `130-EXAMPLE_N.hal`'s numeric discrepancy (unrelated to the above —
it was already wrong before this round of fixes):

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

- **Root-cause the new 7-file regression first** — it's the highest
  priority: real, previously-working files broke. Start with
  `031-DECLARE3.hal` or `177-P.hal` (small, single vectors, easy to
  hand-trace) rather than `GOOGLE-PARALLAX.hal` (bigger discrepancy but
  a bigger program).
- Investigate `130-EXAMPLE_N.hal`'s small numeric discrepancy (see
  above) — unrelated to the regression, was already wrong before this
  round of fixes.
- Track `out6`-match count, not just clean-halt count, on every future
  sweep — this round is exactly why: clean-halt count went up (60→61)
  while match count went down (63→53) in the same comparison. A rising
  clean-halt number alone is not evidence of progress.
- Rerun the full corpus sweep (95 standalone `PROGRAM` files in
  `../Programming in HAL-S/`, both pipelines, compare `--outfile6` +
  run status) after any further fix, rather than hand-picking further
  cases or trusting a single number — every fix so far has been
  confirmed genuine only by rerunning the whole corpus, not by trusting
  the specific case it was aimed at.
- Keep `HELLO.hal`, `197-P.hal`, `193-TEST_X.hal`, `037-ROOTS.hal`,
  `219-P.hal`, and `222-MULTI.hal` passing as regression checks (same
  reproduction steps as below, dropping `--verbose`) — they already work
  and should stay working. Also watch the 7 regressed files above: once
  fixed, add them too.
- The 6 BFS-compile-rejected files (`029-DATATYPES.hal` etc., see above)
  are not this document's problem — don't spend time on them here.
