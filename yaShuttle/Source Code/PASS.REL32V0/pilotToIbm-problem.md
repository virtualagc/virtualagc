# `pilotToIbm` — remaining problem

## Status

`pilotToIbm` converts a BFS `HALSFC --bfs` compile's PILOT object members
(`cards/`) into a PASS/OS360-style object deck that `lnk101` can link and
`yaGPC2` can run. A full corpus sweep (95 standalone `PROGRAM` files in
`../Programming in HAL-S/`, both pipelines, `--outfile6` capture + run
status) now shows **63/95 halting cleanly under BFS, 64/95 matching PFS's
output exactly** — every known category of bug chased in this document
(stack/PDE linkage for plain programs, `ON ERROR` entry shapes, `TASK`
per-task stacks, and a halt-code write that corrupted real program data)
is fixed and verified. What's left is small and separately scoped — see
"Open items" below.

**Fixed and verified** (regression checks — same steps as below,
substituting the filename, dropping `--verbose`): `HELLO.hal`,
`197-P.hal`, `193-TEST_X.hal`, `037-ROOTS.hal`, `219-P.hal`,
`222-MULTI.hal` (fixed at the *source* level — see below),
`130-EXAMPLE_N.hal`, `031-DECLARE3.hal`, `052-TABLE.hal`,
`080-EXAMPLE_4A.hal`, `137-STATISTICS.hal`, `138-FILTER.hal`,
`177-P.hal`, `GOOGLE-PARALLAX.hal`.

## Fixed: halt-code write corrupting real program data

`pilotToIbm` appends a halt SVC to every program and needs a `0x0015`
marker halfword somewhere in `#D<char>` for it. An earlier revision wrote
it by **overwriting** `#D<char>[0:2]` — reverse-engineered from
`HELLO.hal`/`197-P.hal`, where that offset happened to be unused padding.
For any other file, BFS's own compiled code never reserved that space at
all (confirmed directly: BFS's raw PILOT data for a file's `#D` section
starts real, load-bearing data at byte 0, with no gap — unlike PFS, which
does reserve a slot there, at a file-dependent offset PFS's own code
accounts for). So the overwrite silently corrupted real data in every
file where that first halfword held something meaningful — small
floating-point/integer drift in most cases (traced and confirmed
byte-for-byte for several, e.g. `031-DECLARE3.hal`'s `3.0` becoming
`3.0000200271606445` — exactly `0x0015` landing in the low mantissa
bytes), and a severe, indirect failure in `GOOGLE-PARALLAX.hal`: the
corrupted byte hit a double-precision scaling constant feeding the
`DTAN` library routine, turning a multiply into a silent no-op and
ultimately making `TAN(...)` evaluate to exactly `0.5` instead of a tiny
radian value (`EOR / 0.5` matched the wrong output exactly).

Confirmed the write to memory isn't even required for `yaGPC2` to detect
the halt (`130-EXAMPLE_N.hal` halted correctly with the "wrong" value
there) — the fix that landed **appends** the halt marker as new space at
the *end* of `#D<char>` (growing the section) rather than overwriting
existing bytes, so nothing real ever gets clobbered. Verified directly
against all 14 files listed above, then confirmed with a full corpus
sweep: no regressions, and the match count (64/95) is now slightly above
the pre-regression baseline (63/95).

`222-MULTI.hal` needed a separate, source-level fix alongside this: its
`DECLARE SCALAR, A, B, C INITIAL(20);` only initializes `C` in real
HAL/S semantics, leaving `A`/`B` genuinely uninitialized — differing
incidentally between PFS's and BFS's stack garbage regardless of the
`pilotToIbm` bug. The real book source (NASA-CR-... "Programming in
HAL/S" p.222) has no `INITIAL` at all; the example deliberately
illustrates an unprotected race condition between the program and its
`TASK`, not something with one correct answer. Gave `A` a real
`INITIAL(1)` so the file is deterministic; both builds now print
identical output.

## Open items

- **`097-SAMPLE_FLOW.hal` and `184-EXAMPLE_N.hal`**: both exit 0 under
  both PFS and BFS, but output differs. Predate all the fixes above (not
  a new regression) and haven't been investigated — unknown whether
  they're a real `pilotToIbm` bug or something else (e.g. another
  uninitialized-variable case like the original `222-MULTI.hal`).
- **6 files fail to compile under `HALSFC --bfs` itself**
  (`029-DATATYPES.hal`, `198-P.hal`, `199-P.hal`, `200-A.hal`,
  `203-A.hal`, `205-LOG10.hal`) — PASS2 rejects them with `ONLY ONE
  <ON ERROR> ALTERNATE ENTRY POINT IS ALLOWED PER TASK OR PROGRAM` /
  `INDIRECT STACK USAGE CONFLICT` (they use more than one
  `ON ERROR$(...)` alternate entry point). This is a genuine BFS-compiler
  limitation, not a `pilotToIbm` bug — `pilotToIbm` never even runs.
  Out of scope for this document.
- The rest of the sweep's `DIFF`/non-clean rows are files that already
  fail or trap under **PFS** too (need a multi-unit manifest link, not a
  single-file compile) — not a meaningful BFS-vs-PFS comparison, not
  investigated further here.

## How to reproduce (regression check / investigating an open item)

```
export PATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0:$PATH"
export PYTHONPATH="/home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0"
cd /tmp/repro && mkdir bfs && cd bfs
cp "/home/rburkey/git/virtualagc/yaShuttle/Source Code/Programming in HAL-S/<FILE>.hal" .
PARMS=$(python3 -c "import halsParms; print(halsParms.getParms('<STEM>'))")
HALSFC <FILE>.hal --parms="$PARMS" --bfs --force --clean --archive
pilotToIbm -o <STEM>.obj current.results/cards/ --verbose
lnk101 <STEM>.obj -o <STEM>.fcm --json-symbols <STEM>-lnk101.json
yaGPC2 --interactive --no-trace --no-verbose --symbols <STEM>-lnk101.json \
       --line-width 240 --outfile6 out6.txt <STEM>.fcm
```

For comparison, the PFS build of the same file (`HALSFC <FILE>.hal
--parms="$PARMS" -o <STEM>.obj --force --clean --archive`, then the same
`lnk101`/`yaGPC2` invocations, skipping `pilotToIbm`) is the reference to
diff `out6.txt` against.

Useful tools used throughout this investigation:
- `yaGPC2 --trace` (in place of `--no-trace`, with `--max-steps N` to
  keep output short) prints the decoded instruction stream, including
  register/FP changes — this is what found every root cause in this
  document; a raw `diff` of two `--trace` runs (one per build) surfaces
  exactly where the two builds' instruction streams or register values
  first diverge.
- `/home/rburkey/git/virtualagc/ASM101S/readObject101S.py` dumps a PASS
  object deck's cards/ESD/SYM/RLD/TXT structure — used to compare PFS's
  real compiled layout against BFS's.
- `parse_pilot_member()` (inside `pilotToIbm` itself, importable via
  `importlib.machinery.SourceFileLoader`) parses a raw BFS PILOT member
  the same way `pilotToIbm` does, for inspecting what BFS's compiler
  actually produced before any conversion.

## Relevant files

- `pilotToIbm` (this directory) — the conversion tool itself.
- `compileLinkRun` (this directory) — orchestrates
  `HALSFC [--bfs]` → `[pilotToIbm]` → `lnk101` → `yaGPC2`.
- `halsParms.py` (this directory) — default `--parms`.
- `~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py` — someone else's repo,
  read-only: `stackCsectNames()`/`patchStackPDEs()` document what
  triggers stack-section generation and PDE binding.
- `../Programming in HAL-S/*.hal` — the corpus; `097-SAMPLE_FLOW.hal` and
  `184-EXAMPLE_N.hal` are the only known open cases.
