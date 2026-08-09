# `pilotToIbm` — remaining problem

## Current problem

`pilotToIbm` converts a BFS `HALSFC --bfs` compile's PILOT object members
(`cards/`) into a PASS/OS360-style object deck that `lnk101` can link and
`yaGPC2` can run. Plain subroutine-calling programs (e.g. `HELLO.hal`) now
compile, link, and run correctly end to end — `synthesize_pass_stack_linkage()`
already handles the case where a program's entry is the "request a stack via
`SVC X'000f'`" pattern.

**`197-P.hal` (below) is now fixed** — verified directly, output matches
its PFS build exactly. Keep it as a regression check. `ON ERROR` is not
fully solved, though: **`193-TEST_X.hal`** still fails the same way
`197-P.hal` used to. Its `ON ERROR` has an explicit `GOTO` target
(`ON ERROR GO TO DONE;`, vs. `197-P.hal`'s plain `DO; ...; END;` form) and
the program also has a nested `PROCEDURE X` — whatever now handles
`197-P.hal`'s shape doesn't recognize this one. Symptom is the same:
`*** HAL/S SVC trapped (ea=0x0, ...)` then `ERROR: max steps reached
(100000)`, `out6.txt` empty, while PFS's build prints
`RESULTS OF TESTING X ...` correctly. Reproduce the same way as below,
substituting `193-TEST_X` for `197-P` throughout (add `--verbose` to the
`pilotToIbm` call to see what it recognizes).

There's also a second, apparently unrelated failure: **`037-ROOTS.hal`**
has no `ON ERROR` at all — it's a `READ`-driven interactive program (reads
`A,B,C` via `READ(5)` in a loop, reports complex roots). With real stdin
piped in (e.g. `printf "1,2,3\n0,0,0\n" | yaGPC2 ...` — without real input
both builds just print the prompt and stop, which looks misleadingly like
success), PFS computes the correct result; BFS fails differently from the
`ON ERROR` cases:

```
*** HAL/S SVC trapped (ea=0x6, R1=0x2448000, code=0x0)

ERROR: invalid instruction 0xc0bd at 0x023f
[IOCODE=6?]     [IOCODE=6?]     [IOCODE=5?]     [IOCODE=5?] ...
```

An actual invalid-instruction decode, not a trap-then-spin — treat as a
separate investigation. A `--trace` disassembly around address `0x023f`
(the reported invalid-instruction address) would be the way to see what
`pilotToIbm`'s conversion actually produced there.

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
# *** HAL/S SVC trapped (ea=0x0, ...) then ERROR: max steps reached (100000)
```

Use `--trace` in place of `--no-trace` (with `--max-steps N` to keep the
output short) to see the decoded instruction stream from address 0,
including the wayward branch target.

For comparison, the PFS build of the same file (`HALSFC 197-P.hal
--parms="$PARMS" -o 197-P.obj --force --clean --archive`, then the same
`lnk101`/`yaGPC2` invocations, skipping `pilotToIbm`) runs to completion
with exit 0 and correct output.

## Likely cause / where to look

`synthesize_pass_stack_linkage()` in `pilotToIbm` only rewrites a program's
entry when the text chunk at `address_hw == 0` starts with exactly the
2-byte opcode `C9 FB` (the plain stack-request pattern). `197-P.hal`'s
compiled entry is a different instruction shape entirely, most likely
because `ON ERROR` inserts its own dispatch/setup code ahead of (or instead
of) the plain stack-request prologue. That shape isn't recognized, so
whatever relocation/setup it needs is never synthesized.

- Hand-decode the raw PILOT member for `$P` (`current.results/cards/$P` in
  the reproduction above) the same way `parse_pilot_member()` does, and
  compare its ESD/RLD/TXT records against the equivalent PFS-compiled `$0P`
  module (dump the PFS `.obj` with
  `/home/rburkey/git/virtualagc/ASM101S/readObject101S.py`) to see what
  PFS's compiler does differently for an `ON ERROR` program's entry.
- `../PASS2.PROCS/OBJECTGE.xpl` is the original historical PASS2
  object-emission source (`?P`/`?B`-conditionalized for PASS vs. BFS, no
  Python port exists yet) — worth checking for how `ON ERROR` affects
  entry-point/prologue generation on either side.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` (someone else's repo,
  read-only) — `stackCsectNames()` and `patchStackPDEs()` document what
  triggers stack-section generation and PDE binding, in case the `ON
  ERROR` prologue needs something from that same mechanism.

## Next steps

- Extend whatever now handles `197-P.hal`'s `ON ERROR` entry shape to also
  cover `193-TEST_X.hal`'s (`GOTO`-target `ON ERROR` + nested `PROCEDURE`).
- Investigate `037-ROOTS.hal` separately — it isn't an `ON ERROR` case and
  fails with a different symptom (invalid-instruction decode, not
  trap-then-spin).
- Once both are fixed, sweep the rest of `../Programming in HAL-S/*.hal`
  (98 files, ~90 standalone single-unit `PROGRAM`s) rather than
  hand-picking further cases — `ON ERROR` and `READ`-driven I/O are both
  common enough that a fix for one file's shape risks missing siblings
  with slightly different shapes, the same way `197-P.hal`'s fix didn't
  cover `193-TEST_X.hal`.
- Keep `HELLO.hal` and `197-P.hal` passing as regression checks (same
  reproduction steps as below, dropping `--verbose`) — they already work
  and should stay working.
