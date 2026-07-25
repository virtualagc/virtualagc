# EFOR

**Mnemonic:** EFOR

**Opcode:** 0x011

**Confidence:** High

## Behavioral Description

"End for" — closes a `DO FOR` statement group opened by [DFOR](DFOR.md),
in both its range and list forms. Generates the per-cycle
increment/re-test/branch-back logic (range form) or the computed-return
dispatch back into [AFOR](AFOR.md)'s saved return address (list form).

## Usage Context

Emitted for the closing `END;` of any `DO FOR` group.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the same construct identifier used by the
originating [DFOR](DFOR.md), `QUAL`=2=GLI/INL. Confirmed by compiling
both forms with `HALSFC --parms="LSTALL"`:

**Range form** (`DO FOR I1 = 1 TO 10; ... END;`):
```
HALMAT: 011(1),0,0
          8(2),0,0               <- construct id 8 (matches DFOR), QUAL=2=GLI/INL
LFXI 7,3                          <- reload the increment constant (implicit +1 here)
AH   7,I1                         <- R7 (increment) + memory I1 -> R7 (new control-var value)
L#10 EQU *                        <- loop-top label (target of DFOR's initial skip-branch)
STH  7,I1                         <- store the new value back to I1
CHI  7,10                         <- compare against the final value
BC   6,L#10                       <- branch back to loop top if still in range
L#8 EQU *                         <- loop-exit label
```

**List form** (`DO FOR I1 = 1, 2, 3; ... END;`):
```
HALMAT: 011(1),0,0
         13(2),0,0               <- construct id 13 (matches DFOR), QUAL=2=GLI/INL
LH  4,18(0,0)                     <- reload the saved return address (see AFOR.md)
BCR 7,4                           <- branch to it: continues the loop (next AFOR)
                                      or falls through to exit, per which value was last
L#13 EQU *                        <- loop-exit label
```

## `yaHALMAT2` Implementation Notes (Maintenance phase)

- **DFOR's own missing initial bounds check** (user-reported,
  113-EXAMPLE_7.hal): range-form `DO FOR` never checked whether its
  *initial* value was already out of range (`DO FOR J=I+1 TO 4;` with
  `I=4` ran once with `J=5` anyway), silently corrupting an unrelated
  array element via a wrapped out-of-bounds [DSUB](DSUB.md) offset. This
  traced directly to [DFOR](DFOR.md)'s own corrected Behavioral
  Description above (an earlier claim, since fixed, that the range form
  "always executes at least its first in-range cycle without a
  pre-test") — the real trace shows DFOR's initial branch lands on
  *this* instruction's own store+compare code, only skipping the
  increment. Fixed by giving DFOR that same store+compare check up
  front (new `dfor_efor_pos[]` reverse mapping, `interp.c`, letting
  DFOR find its own matching EFOR to reuse its bounds-check logic).
  Independently confirmed against `compileLinkRun`. Fixture:
  `test_dfor_zero.hal`.
- **`EXIT <label>;` targeting a labeled `DO FOR`** (user-reported,
  119-EXAMPLE_9.hal's `INNER: DO FOR TEMPORARY J = 1 TO 3; ... EXIT
  INNER; ... END INNER;`): "branch to undefined label 11". `EXIT`
  compiles to a plain `BRA` whose `INL` operand is the same
  construct-id number this instruction and [DFOR](DFOR.md) both carry
  (matching the already-handled `EXIT`-of-`DTST`/`ETST` case), but
  `yaHALMAT2`'s label-precomputation pass only ever registered
  [LBL](LBL.md) and `ETST`, never this instruction's own label. Fixed
  by registering it from here (this instruction already carries the
  label directly in both range and list forms, per the traces above),
  landing at this instruction's own position + 1 — the same "just past
  this instruction" convention `ETST` uses, not landing on this
  instruction itself, which would just re-run its own increment/
  re-test. See [LBL](LBL.md)'s own Implementation Notes for a second,
  independent bug this fixture surfaced (a labeled-statement/ordinary-
  join-point numbering-space collision). Fixture:
  `test_exit_dfor_label.hal`.

## Unresolved Questions

- None for the base cases tested.

**Phase 3 cross-check note** (superseded by the DFOR bounds-check fix
above — kept for historical record; a real DFOR now does still check
the initial value before falling through, contrary to the "falling
through...without a pre-test" description below): an independent
yaHALMAT2 implementation of range-form DFOR/EFOR (control variable set
directly by DFOR, falling through into the body without a pre-test;
EFOR increments, compares against the final value per the increment's
sign, and branches back to just past DFOR or falls through on exit) was
verified by hand against
`test_nested.hal` (nested `DO WHILE`/range-form `DO FOR`/`IF`-`ELSE`):
10 outer-loop passes × (5 cycles `K=K+2` + 5 cycles `K=K+1`) = `K=150`,
matching a plain arithmetic derivation with no interpretive ambiguity.
The reference `yaHALMAT` emulator produces `K=40` for the same input
(with or without `--symtab`) — its `--trace` output shows far fewer
`DFOR`/`EFOR` events than a correct 10-outer × 11-inner nesting would
produce, indicating its inner loop exits early. Not fully root-caused
(not investigated further, consistent with this project's existing
stance that the reference tool isn't authoritative) — don't use it as
a cross-check for range-form `DO FOR` without independently verifying
the expected iteration count by hand first.

## Source Analysis & Reliability

Opcode (0x011) confirmed primary-source: `XEFOR BIT(16) INITIAL("011")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DFOR](DFOR.md)'s Source Analysis for the context of this investigation.
