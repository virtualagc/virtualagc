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
longer crash/trap at all — both now exit 0, and both have since been
root-caused (`130-EXAMPLE_N.hal` below; `222-MULTI.hal` fixed at the
source level):

- **`130-EXAMPLE_N.hal`**: a real, small numeric discrepancy — PFS prints
  `THE ANSWER IS      2.4990000E+05`; BFS prints
  `THE ANSWER IS      2.4989994E+05`. **Root-caused, see below** — same
  bug as the 7-file regression in the next section.
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

## Root cause found: hardcoded halt-SVC displacement corrupts real data

This explains both `130-EXAMPLE_N.hal`'s discrepancy and the 7-file
regression below — they're the same bug, **fully confirmed, with an
exact fix identified.**

`pilotToIbm`'s halt-code synthesis (whatever superseded
`synthesize_pass_stack_linkage()`) appends a `C9 F9 00 00` halt SVC to
every program's code and unconditionally writes `0x0015` into
`#D<char>[0:2]` (displacement 0), matching what it observed in
`HELLO.hal` and `197-P.hal`. **But displacement 0 is not a universal
constant — it's specific to those two files' particular data layout.**
Confirmed directly by dumping PFS's own real object files with
`readObject101S.py`:

- `HELLO.hal` PFS: halt SVC is `C9 F9 00 00` — displacement 0.
- `197-P.hal` PFS: halt SVC is `C9 F9 00 00` — displacement 0.
- `130-EXAMPLE_N.hal` PFS: halt SVC is **`C9 F9 00 02`** — displacement
  **2**, not 0.

So for any file where the real slot isn't at offset 0 (like
`130-EXAMPLE_N.hal`), `pilotToIbm`'s write lands on top of whatever real
data happens to be there instead — and the write doesn't even need to
happen: `130-EXAMPLE_N.hal` still halts correctly (exit 0) with the
"wrong"-displacement `C9F9 0000` and no `0x0015` at `#D+0`, meaning
`yaGPC2`'s halt detection doesn't actually check the referenced memory
value — it's triggered by the `C9F9`-pattern SVC instruction itself. **The
`0x0015` write is pure damage with no corresponding benefit.**

Traced `130-EXAMPLE_N.hal`'s exact discrepancy to this directly
(`yaGPC2 --trace`): the `-100.0` step-constant in its `DO FOR` loop is
stored at `#DEXAMPL[0:2]` — clean `C2 64 00 00` under PFS, corrupted to
`C2 64 00 15` under BFS, i.e. exactly the halt code overwriting the
constant's low mantissa bytes. `-100.0000032...` instead of exactly
`-100.0` (both should be bit-identical, since 250000 and all `DO FOR`
step values here are small integers exactly representable in IBM hex
float — this is corruption, not rounding).

The same mechanism explains most of the 7-file regression below —
verified numerically for several by reconstructing "clean value, low 2
mantissa bytes forced to `0x0015`" and matching the observed BFS output
exactly:

- `031-DECLARE3.hal`: `3.0` → `41300015` = `3.0000200271606445` — matches
  observed `3.0000200E+00` exactly.
- `177-P.hal`: same `...0015` pattern, matches `9.0000200E+00` exactly.
- `052-TABLE.hal`: `1073741824` → `+21` — **`0x0015` = 21 decimal**,
  matches the observed exact-integer offset precisely.
- `080-EXAMPLE_4A.hal`: `400.0` → `43190015` = `400.005126953125` —
  matches observed `4.0000513E+02` closely (rounding in the printed
  digits).
- `137-STATISTICS.hal`, `138-FILTER.hal`: didn't match a naive
  "corrupt-the-displayed-literal-directly" reconstruction — these values
  are *computed* (a mean, a running average), so the corruption is
  probably hitting a different literal (a divisor, an accumulator) that
  then propagates through arithmetic rather than appearing verbatim in
  the output. Same root cause is still the leading hypothesis; not
  independently confirmed byte-for-byte the way the others were.
- `GOOGLE-PARALLAX.hal`: **doesn't fit this pattern** — its `pilotToIbm
  --verbose` log shows no `set #D...` line at all (meaning `#D[0:2]` was
  already `0x0015` before this step, so nothing was written), yet its
  output is wrong by 5 orders of magnitude. Needs its own investigation;
  don't assume it's covered by the fix below.

`031-DECLARE3.hal` and `177-P.hal` both corrupting their vector's *last
element* to the exact same value is not a coincidence — it's the same
fixed-displacement-0 write landing on the same relative position in
both files' data layout.

Two more `DIFF` rows from the sweep, `097-SAMPLE_FLOW.hal` and
`184-EXAMPLE_N.hal`, are **not** part of this regression — both already
mismatched before this round of fixes too; not investigated yet either
way.

### The fix

Given the halt SVC works regardless of its displacement or of what's in
memory there, the simplest correct fix is almost certainly to **stop
writing `0x0015` into `#D<char>` at all** — it was reverse-engineered
from two files where it happened to be harmless, isn't actually needed
for `yaGPC2` to detect the halt, and actively corrupts real data in every
other file's layout. If full fidelity to PFS's exact halt-SVC
displacement is wanted for some other reason, the real displacement
would need to be computed from the program's actual data layout (visible
in PFS's own compiled output per file), not hardcoded — but given the
write isn't required for correct behavior, removing it outright is
probably the right call rather than trying to compute the "real"
offset.

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
# 130-EXAMPLE_N / 031-DECLARE3 / 052-TABLE / 080-EXAMPLE_4A / 177-P to
# reproduce the now-root-caused halt-SVC-displacement bug below, or
# GOOGLE-PARALLAX (still unexplained) or 137-STATISTICS / 138-FILTER
# (same root cause suspected, not independently confirmed).
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
compare + `--trace` approach that found both is also what found the
halt-SVC-displacement bug above.)

For `GOOGLE-PARALLAX.hal`, the one case the halt-SVC fix above doesn't
explain:

- Same approach as before: `readObject101S.py`-dump the PFS `.obj`,
  hand-decode the BFS PILOT member, compare ESD/RLD/TXT, and use
  `yaGPC2 --trace` to find exactly where the two builds' instruction
  streams or register values diverge — this worked for every case so far
  and there's no reason to expect it won't here too.
- Since the halt-SVC write wasn't the cause here (confirmed — no
  `set #D...` line in `pilotToIbm --verbose`'s output for this file),
  look elsewhere in whatever synthesizes stack/PDE/halt linkage for
  another place a fixed offset might be assumed instead of computed.

## Next steps

- **Remove the `#D<char>[0:2] = 0x0015` write** (see "The fix" above) —
  root-caused and fixes `130-EXAMPLE_N.hal` plus most/all of the 7-file
  regression in one change. Re-verify `HELLO.hal`/`197-P.hal`/etc. still
  halt correctly afterward (they should, since the write was never what
  made them halt).
- After that fix, re-check `137-STATISTICS.hal` and `138-FILTER.hal`
  specifically — same root cause suspected but not independently
  confirmed byte-for-byte the way the others were.
- `GOOGLE-PARALLAX.hal` is not covered by the fix above — investigate
  separately (see "Likely cause" above).
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
