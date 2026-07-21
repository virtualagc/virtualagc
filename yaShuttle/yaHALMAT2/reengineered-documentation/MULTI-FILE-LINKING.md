# Multi-file HAL/S linking (Phase 3 finding)

Plan.md's Phase 3 called for discovering, documenting, and implementing
how `yaHALMAT2` should link multiple independently-compiled HALMAT files
into one running program, since — confirmed during Phase 2 research —
the real HAL/S-FC toolchain has **no HALMAT-level linking mechanism at
all**: only post-HALMAT AP-101S object code is linked (by a separate
linker, `lnk101`), and `COMMON0.out`→`COMMON5.out` is purely an
intra-unit pipeline state chain (PASS1→FLO→OPT→AUXP→PASS2→PASS3), never
a mechanism for combining two different `.hal` source files.

## The real mechanism: `EXTERNAL COMPOOL` block templates

HAL/S's actual cross-unit data sharing is source-level, via `COMPOOL`
blocks and their **templates** ([USA003087] §15.4): a template is a
byte-for-byte mirror of the real `COMPOOL`'s own declarations, with the
opening keyword changed to `EXTERNAL COMPOOL`:

```
real block (compiled separately, e.g. pool_out/):
  POOL:
  COMPOOL;
     DECLARE INTEGER, SHARED_X INITIAL(42);
  CLOSE POOL;

referencing unit (compiled separately, e.g. prog_out/):
  POOL:
  EXTERNAL COMPOOL;
     DECLARE INTEGER, SHARED_X INITIAL(42);      <- must textually mirror the real block
  CLOSE POOL;

  MAINPROG:
  PROGRAM;
     DECLARE INTEGER, Y;
     Y = SHARED_X + 1;
     WRITE(6) 'Y=', Y;
  CLOSE MAINPROG;
```

Compiled and run independently (`HALSFC pool.hal`, `HALSFC main.hal`),
each produces its own complete, self-contained `halmat.bin` + companion
files, with **independently 0-based `SYT`/literal-table numbering** —
confirming Plan.md's design note that these must never be naively
concatenated.

## Where the `EXTERNAL` flag actually lands (empirically confirmed)

**Not** on the individual shared variable. Compiling the example above
and reading both units' `COMMON0.out` symbol-table dumps directly shows
`SHARED_X`'s `SYM_FLAGS` are **identical** (`0x00804808`) in both the
real block and the referencing template — no distinguishing bit on the
variable itself.

The `EXTERNAL` flag (`SYM_FLAGS` bit `0x00100000`, matching
`unHALMAT.py`'s `symbolFlags` table) instead lands on the **COMPOOL
block's own name** (`POOL`) in the referencing unit's symbol table:
`POOL` → `0x00100040` (includes `0x00100000`) in the referencing unit,
vs. `0x00000040` (no `EXTERNAL` bit) for the real block's own name in
its own unit.

This makes linking a two-step, name-based match:
1. For each auxiliary unit, find its own `COMPOOL` header (`CDEF`,
   opcode `0x02F`) and the block name it declares.
2. Check whether the primary (executing `PROGRAM`, `MDEF`-headed) unit's
   own symbol table has an entry with that **same block name**, flagged
   `EXTERNAL`. If so, every other symbol name in the auxiliary unit's
   table (its actual declared variables) is matched by name against the
   primary's table and imported.

An `EXTERNAL`-flagged block name in the primary with no matching
auxiliary unit is treated as an unresolved external — a hard error at
startup, mirroring a normal linker, not a silent zero-default at
runtime.

## Execution model: `COMPOOL` units don't need real concurrency

Compiling a real, standalone `COMPOOL` and inspecting its HALMAT
confirms it's a trivial, non-looping, non-branching, non-task-spawning
prologue: `CDEF` → (`IINT`/`SINT`-family init per `INITIAL(...)` value)
→ `EDCL` → `CLOS`. This means `yaHALMAT2` doesn't need per-unit
`VAC`/program-counter/scheduler plumbing to support linking — each
auxiliary unit can simply be run to completion, once, using the
same single-unit interpreter machinery used for a standalone program,
with its resulting `SYT` values harvested by name afterward and seeded
into the primary unit's matching `SYT` slots before the primary itself
runs normally.

## `yaHALMAT2` scope (current)

- One executing `PROGRAM` (`MDEF`-headed) unit, selected via `--entry
  <directory>` or auto-detected (exactly one `MDEF`-headed directory in
  the `@list`).
- Any number of `COMPOOL` (`CDEF`-headed) auxiliary units.
- `--opt` loads `optmat.bin` (+ its own companion convention:
  `litfile2.bin`, `COMMON2.out.bin[.gz]`, `COMMON3.out`) instead of
  `halmat.bin` for every unit in the list.

**Not yet supported** (explicit scope boundary, not silently wrong):
- Multiple concurrently-*executing* `PROGRAM` units sharing live,
  mutable `COMPOOL` state (each would need to observe the others'
  writes as they happen — full per-unit scheduler integration, not
  attempted yet).
- `ARRAY`/`MATRIX`-typed `EXTERNAL COMPOOL` variables (only plain
  `INTEGER`/`SCALAR` values are imported; safely transferring an element
  buffer's ownership across the auxiliary unit's cleanup needs more than
  a struct copy).
- `EXTERNAL PROCEDURE`/`FUNCTION` blocks (comsubs, [USA003087] §15.3) —
  only `COMPOOL` auxiliary units are recognized; a comsub-headed (`FDEF`/
  `PDEF`) auxiliary unit is rejected with an explicit error rather than
  silently mishandled.

Validated end-to-end with `src/tests/hal/test_link_pool.hal` +
`test_link_prog.hal` (`src/tests/run_link_fixture.sh`): the linked run
produces `Y=43` (`SHARED_X`=42, imported from the separately-compiled
`COMPOOL`, `+1`), and omitting the `COMPOOL` unit from the `@list`
correctly fails with `unresolved external 'POOL'` rather than silently
defaulting `SHARED_X` to `0`.
