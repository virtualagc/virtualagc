# ITOI

**Mnemonic:** ITOI
**Opcode:** 0x6C1
**Confidence:** High

## Behavioral Description

Integer precision scale. The integer member of the same precision-scaling
family as [MTOM](../class-3/MTOM.md) — see that file for the full
mechanism. Also structurally the "self" slot of the `XBTOI` "convert to
integer" family (alongside [BTOI](BTOI.md), [CTOI](CTOI.md),
[STOI](STOI.md)) — for the same reason described in
[STOS](../class-5/STOS.md), this opcode serves both conceptual roles.
Confirmed trigger: the same postfix precision-qualifier syntax as
[STOS](../class-5/STOS.md), `exp$(@SINGLE)`/`exp$(@DOUBLE)`, applied to
an `INTEGER` expression.

## Usage Context

Emitted for `exp$(@DOUBLE)`/`exp$(@SINGLE)` applied to an `INTEGER`
expression — confirmed by compiling `I2 = I1$(@DOUBLE);` (`I1` a `SINGLE`
`INTEGER`, `I2` `DOUBLE`), in the same test program as
[STOS](../class-5/STOS.md)/[VTOV](../class-4/VTOV.md)/
[MTOM](../class-3/MTOM.md).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `INTEGER`
expression, `QUAL`=1=SYT. The operator word's `TAG` field carries the
requested precision as a bit flag (confirmed `2` for `@DOUBLE` —
`PRECSCAL.xpl`'s `DOUBLE_FLAG` constant). Confirmed trace:

```
HALMAT: 6C1(1),2,0            <- ITOI, TAG=2=DOUBLE_FLAG
          2(1),0,0                <- I1, symbol index 2, QUAL=1=SYT
LH 5,I1 / SRA 5,16                <- sign-extends I1's single-precision value into place
```

## Confirmed Bit-Level Mechanics

[USA00309] §8.2 gives the exact rules for integer precision conversion
(single = 16-bit signed, range -32,768 to 32,767; double = 32-bit signed
— rules 1–2):

- **Rule 8 (narrowing, double→single)**: eliminate the left-most 16 bits
  of the double-precision value.
- **Rule 11 (widening, single→double)**: sign-extend — propagate the sign
  bit of the single-precision value throughout the 16 high-order bit
  positions of the double-precision value (matches the observed `SRA
  5,16` arithmetic right-shift in the confirmed trace above).

## Unresolved Questions

- The `SINGLE_FLAG` value (narrowing direction, `exp$(@SINGLE)`) was not
  independently compiled this session — only `@DOUBLE` was tested.

## Source Analysis & Reliability

Opcode (0x6C1) confirmed primary-source: doubly — element 5 of the
`XBTOI(5)` "convert to integer" array, and element 3 of the `XMTOM(3)`
precision-scale array, both in `PASS1.PROCS/##DRIVER.xpl` — see
[##DRIVER.xpl] in `STATUS.md`. Not present in [MSC-01847]. Behavioral
role primary-sourced from `PASS1.PROCS/PRECSCAL.xpl`'s `PREC_SCALE`
procedure — see [STOS](../class-5/STOS.md)'s Source Analysis for how the
`$(@SINGLE)`/`$(@DOUBLE)` trigger construct was found. Full behavioral
description and operand-word structure now confirmed directly against
real compiled HALMAT. Bit-level mechanics primary-sourced from [USA00309]
§8.2 rules 8 and 11.
