# ETST

**Mnemonic:** ETST

**Opcode:** 0x00F

**Confidence:** High

## Behavioral Description

"End test" — closes a `DO WHILE`/`DO UNTIL` statement group opened by
[DTST](DTST.md). Generates the unconditional branch back to the loop's
test point (for the next cycle's re-evaluation) and defines the loop-exit
label referenced by [CTST](CTST.md)'s conditional branch.

## Usage Context

Emitted for the closing `END;` of a `DO WHILE`/`DO UNTIL` group. Its own
generated code and label placement are structurally identical for both
forms (the WHILE/UNTIL distinction is fully handled by
[DTST](DTST.md)/[CTST](CTST.md); ETST needs no polarity flag of its own).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the same construct identifier used by the
originating [DTST](DTST.md) and every [CTST](CTST.md) in between,
`QUAL`=2=GLI/INL. Confirmed by compiling both `DO WHILE`/`DO UNTIL` forms
with `HALSFC --parms="LSTALL"` — e.g. for the `DO WHILE I1 > 0;` case:

```
HALMAT: 00F(1),0,0            <- ETST
          2(2),0,0               <- construct id 2 (matches DTST/CTST), QUAL=2=GLI/INL
BC 7,L#3                       <- unconditional branch back to the test point
L#2 EQU *                      <- loop-exit label (matches CTST's branch target)
```

## Unresolved Questions

- None for the base case.

## Confirmed Runtime Behavior

**`EXIT loop-label;` targets this same construct id directly, found in a
later session via a user report against `037-ROOTS.hal`'s `EXIT
ROOTLOOP;`** — not just [CTST](CTST.md)'s own conditional exit branch as
the Behavioral Description above (written before this was checked)
implies. `interp.c`'s `precompute_labels()` now registers this label
number too, resolving to *this instruction's own position + 1* — not
this instruction's position itself, unlike an ordinary [LBL](LBL.md)
target. That distinction matters: `interp.c`'s `OP_ETST` handler, when
reached by ordinary fall-through at the bottom of a loop body, always
branches back to retest the condition (`etst_back_target`) rather than
continuing past itself, so landing exactly on ETST would send an EXIT
back into another iteration instead of leaving the loop — `+ 1` is the
identical "loop actually exited" position [CTST](CTST.md)'s own
`ctst_exit_target` already uses. See [BRA](BRA.md)'s own updated
"Confirmed Runtime Behavior" for the fuller trace;
`src/tests/hal/test_exit_loop.hal` is the regression fixture.

## Source Analysis & Reliability

Opcode (0x00F) confirmed primary-source: `XETST BIT(16) INITIAL("00F")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DTST](DTST.md)'s Source Analysis for the context of this investigation.
