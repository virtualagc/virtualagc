# `pilotToIbm` — remaining problems

## Fixed, keep as regression checks

`HELLO.hal` (plain subroutine calls) and `197-P.hal` (`ON ERROR` as a plain
`DO; ...; END;` block, no explicit `GOTO` target, no nested `PROCEDURE`)
both now compile, link, and run correctly through
`HALSFC --bfs` → `pilotToIbm` → `lnk101` → `yaGPC2`, matching their PFS
builds' output exactly. Don't regress these:

```
export PATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0:$PATH"
export PYTHONPATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0"
cd /tmp/repro && mkdir bfs && cd bfs
cp "/home/rburkey/git/virtualagc/yaShuttle/Source Code/Programming in HAL-S/<FILE>.hal" .
PARMS=$(python3 -c "import halsParms; print(halsParms.getParms('<STEM>'))")
HALSFC <FILE>.hal --parms="$PARMS" --bfs --force --clean --archive
pilotToIbm -o <STEM>.obj current.results/cards/
lnk101 <STEM>.obj -o <STEM>.fcm --json-symbols <STEM>-lnk101.json
yaGPC2 --interactive --no-trace --no-verbose --symbols <STEM>-lnk101.json \
       --line-width 240 --outfile6 out6.txt <STEM>.fcm
```

(`<FILE>`/`<STEM>` = `HELLO`/`HELLO` or `197-P.hal`/`197-P`.) Both should
exit 0 with `out6.txt` matching the equivalent PFS build (same steps,
`HALSFC` without `--bfs`, `-o <STEM>.obj` instead of `--bfs`, skip
`pilotToIbm`).

## Current problem 1: other `ON ERROR` shapes still fail

Known failing case: `193-TEST_X.hal`. Unlike `197-P.hal`, its `ON ERROR`
has an explicit `GOTO` target (`ON ERROR GO TO DONE;`) and the program
also has a nested `PROCEDURE X`. Fails the same way `197-P.hal` used to
before its fix: `*** HAL/S SVC trapped (ea=0x0, ...)` then
`ERROR: max steps reached (100000)`, `out6.txt` empty. PFS's build of the
same file runs correctly (prints `RESULTS OF TESTING X ...`).

Reproduce with the steps above, substituting `193-TEST_X`/`193-TEST_X`
(and add `--verbose` to the `pilotToIbm` call to see what it recognized).

Likely cause: whatever entry-prologue synthesis now handles `197-P.hal`'s
plain-`DO`-block `ON ERROR` shape doesn't recognize this `GOTO`-target
form and/or doesn't yet do the right thing when a nested `PROCEDURE` is
also present. Compare the raw PILOT member's ESD/RLD/TXT records for `$P`
(197-P, working) against `$TEST_X` (193-TEST_X, broken) the same way the
`197-P.hal` fix was presumably worked out, and against the PFS-compiled
equivalents (dump with
`/home/rburkey/git/virtualagc/ASM101S/readObject101S.py`).

## Current problem 2: READ-driven / interactive-I/O programs

Known failing case: `037-ROOTS.hal` — no `ON ERROR` at all; reads `A,B,C`
via `READ(5)` in a loop and reports complex roots. With real stdin
(e.g. `printf "1,2,3\n0,0,0\n" | yaGPC2 ...`), PFS computes and prints the
correct result. BFS instead fails differently from problems above:

```
*** HAL/S SVC trapped (ea=0x6, R1=0x2448000, code=0x0)

ERROR: invalid instruction 0xc0bd at 0x023f
[IOCODE=6?]     [IOCODE=6?]     [IOCODE=5?]     [IOCODE=5?]     [IOCODE=5?] ...
```

This is a distinct symptom (an actual invalid-instruction decode, not a
trap-then-spin) and is not obviously related to the stack/`ON ERROR`
entry-prologue work above — treat it as a separate investigation. Needs
real stdin piped in to reproduce meaningfully (without it, both builds
just print the prompt and stop, which looks misleadingly like success).

## Next steps

- Extend whatever now handles `197-P.hal`'s `ON ERROR` entry shape to also
  cover `193-TEST_X.hal`'s (`GOTO`-target `ON ERROR` + nested `PROCEDURE`).
- Investigate `037-ROOTS.hal` as a separate problem — get a `--trace`
  disassembly around address `0x023f` (the reported invalid-instruction
  address) to see what code `pilotToIbm`'s conversion actually produced
  there and how it diverges from the PFS build's equivalent.
- Once both are fixed, sweep the rest of `../Programming in HAL-S/*.hal`
  (98 files, ~90 standalone single-unit `PROGRAM`s) rather than
  hand-picking further cases — `ON ERROR` and `READ`-driven I/O are both
  common enough that isolated fixes for one file each risk missing
  siblings with slightly different shapes, the same way `197-P.hal`'s fix
  didn't cover `193-TEST_X.hal`.

## Relevant files

- `pilotToIbm` (this directory) — the conversion tool itself.
- `compileLinkRun` (this directory) — orchestrates
  `HALSFC [--bfs]` → `[pilotToIbm]` → `lnk101` → `yaGPC2`.
- `halsParms.py` (this directory) — default `--parms`.
- `../PASS2.PROCS/OBJECTGE.xpl` — original historical PASS2
  object-emission source, `?P`/`?B`-conditionalized for PASS vs. BFS; no
  Python port exists yet, readable as reference only.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` — someone else's repo,
  read-only: `stackCsectNames()`/`patchStackPDEs()` document what
  triggers stack-section generation and PDE binding.
- `/home/rburkey/git/virtualagc/ASM101S/readObject101S.py` — dumps a PASS
  object deck's cards/ESD/SYM/RLD structure.
- `../Programming in HAL-S/*.hal` — the corpus; `197-P.hal`/`HELLO.hal`
  are known-passing regression checks, `193-TEST_X.hal`/`037-ROOTS.hal`
  are the known-failing cases above.
