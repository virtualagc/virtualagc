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

## Source Analysis & Reliability

Opcode (0x00F) confirmed primary-source: `XETST BIT(16) INITIAL("00F")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DTST](DTST.md)'s Source Analysis for the context of this investigation.
