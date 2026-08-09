# `pilotToIbm` — remaining problem

## Current problem

`pilotToIbm` converts a BFS `HALSFC --bfs` compile's PILOT object members
(`cards/`) into a PASS/OS360-style object deck that `lnk101` can link and
`yaGPC2` can run. Plain subroutine-calling programs (e.g. `HELLO.hal`) now
compile, link, and run correctly end to end — `synthesize_pass_stack_linkage()`
already handles the case where a program's entry is the "request a stack via
`SVC X'000f'`" pattern.

**Programs that use `ON ERROR` do not work.** Known failing case:
`197-P.hal` (in `../Programming in HAL-S/`). Its compiled entry point is not
the plain `SVC X'000f'` pattern — it's a `BC` (branch-on-condition)
instruction, presumably part of `ON ERROR`'s dispatch/setup sequence, and
`pilotToIbm` does not currently recognize or translate whatever relocation
this prologue shape needs. The branch target ends up pointing at an address
the linker never allocated anything for. Execution runs through unallocated
(zero-filled) memory, which happens to decode harmlessly as `A 0,X'0000'`
for tens of thousands of steps, until it reaches a byte pattern that decodes
as an `SVC`; nothing services that trap, and the run spins to `yaGPC2`'s
max-instruction safety cap instead of halting.

The equivalent PFS build of `197-P.hal` runs correctly (exit 0, correct
output), so this is specific to the BFS→`pilotToIbm` conversion, not a
defect in the source file.

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

- Determine what `197-P.hal`'s actual compiled entry sequence is supposed
  to do, and what relocation(s)/section(s) it needs that aren't currently
  synthesized.
- Extend `synthesize_pass_stack_linkage()` (or add a parallel handler) to
  recognize and correctly translate this entry-prologue shape, not just
  the plain `SVC X'000f'` one.
- Re-run the `197-P.hal` reproduction above, and re-check the rest of
  `../Programming in HAL-S/*.hal` once fixed — `ON ERROR` is a common
  HAL/S construct, so other files likely hit the same gap.
- Keep `HELLO.hal` passing as a regression check (same reproduction steps,
  substituting `HELLO.hal` for `197-P.hal` and dropping `--verbose`) — it's
  the case that already works and should stay working.
