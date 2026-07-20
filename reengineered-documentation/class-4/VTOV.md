# VTOV

**Mnemonic:** VTOV

**Opcode:** 0x441

**Confidence:** High

## Behavioral Description

Vector precision scale. The vector member of the same precision-scaling
family as [MTOM](../class-3/MTOM.md) — see that file for the full
mechanism (confirmed via `PASS1.PROCS/PRECSCAL.xpl`'s `PREC_SCALE`
procedure, which selects among this family's members by operand type and
emits the precision-adjustment mask as `TAG`). Confirmed trigger: the
same postfix precision-qualifier syntax as [STOS](../class-5/STOS.md),
`exp$(@SINGLE)`/`exp$(@DOUBLE)`, applied to a `VECTOR` expression.
**Correction (later session, re-confirmed against a current HALSFC
build):** `VTOV` compiles as a single whole-vector instruction, *not*
wrapped in an [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md)
per-element loop as originally documented below — see
[MTOM](../class-3/MTOM.md)'s identical correction this same session.
`VTOV` converts every element at once and is consumed by a following
`VASN` via its own VAC slot, matching [VADD](../class-4/VADD.md)/
[VSUB](../class-4/VSUB.md)'s "no destination operand" pattern.

## Usage Context

Emitted for `exp$(@DOUBLE)`/`exp$(@SINGLE)` applied to a `VECTOR`
expression — confirmed by compiling `V2 = V1$(@DOUBLE);` (`V1` a `SINGLE`
`VECTOR(2)`, `V2` `DOUBLE`), in the same test program as
[STOS](../class-5/STOS.md)/[ITOI](../class-6/ITOI.md)/
[MTOM](../class-3/MTOM.md).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `VECTOR`,
`QUAL`=1=SYT. The instruction's own `TAG` carries the target precision:
confirmed `2`=`@DOUBLE`, `1`=`@SINGLE` (`SINGLE_FLAG`, cross-confirmed
against [STOS](../class-5/STOS.md)'s identical convention). Confirmed
trace, compiling `V2 = V1$(@DOUBLE);` (both `VECTOR(2)`, `V1` single,
`V2` double):

```
HALMAT: 441(1),2,0            <- VTOV, TAG=2=DOUBLE_FLAG
          2(1),0,0                <- V1, symbol index 2, QUAL=1=SYT
HALMAT: 401(2),0,0            <- VASN (see VASN.md)
          ?(1),0,0                <- VTOV's own VAC slot (source)
          3(1),0,0                <- V2, symbol index 3, QUAL=1=SYT (destination)
```

No `ADLP`/`DLPE` wrapping and no per-operand trailing tag appear in this
build's output — see the correction note above.

## Unresolved Questions

- Longer vectors, and vectors nested inside arrays/structures, were not
  tested.

## Source Analysis & Reliability

Opcode (0x441) confirmed primary-source: element 1 of the `XMTOM(3)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Behavioral role primary-sourced from
`PASS1.PROCS/PRECSCAL.xpl`'s `PREC_SCALE` procedure — see
[STOS](../class-5/STOS.md)'s Source Analysis for how the
`$(@SINGLE)`/`$(@DOUBLE)` trigger construct was found. Full behavioral
description and operand-word structure now confirmed directly against
real compiled HALMAT.
