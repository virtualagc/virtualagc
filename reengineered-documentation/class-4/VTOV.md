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
`exp$(@SINGLE)`/`exp$(@DOUBLE)`, applied to a `VECTOR` expression. Unlike
the scalar/integer members, `VTOV` converts one element at a time and is
therefore wrapped in an [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md)
arrayness loop (the general per-element arrayed-expression bracket, not
the [SLRI](../class-8/SLRI.md)/[ELRI](../class-8/ELRI.md)/
[ETRI](../class-8/ETRI.md) static-initialization-only family) — a single
`VTOV` instruction inside the loop body converts each element in turn.

## Usage Context

Emitted for `exp$(@DOUBLE)`/`exp$(@SINGLE)` applied to a `VECTOR`
expression — confirmed by compiling `V2 = V1$(@DOUBLE);` (`V1` a `SINGLE`
`VECTOR(2)`, `V2` `DOUBLE`), in the same test program as
[STOS](../class-5/STOS.md)/[ITOI](../class-6/ITOI.md)/
[MTOM](../class-3/MTOM.md).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `VECTOR`,
`QUAL`=1=SYT, with a non-zero trailing tag (observed `2`) on this operand
(index/element-count related, not decoded). The operator word's own `TAG`
carries the requested precision as a bit flag (confirmed `2` for
`@DOUBLE`, same `DOUBLE_FLAG` convention as [STOS](../class-5/STOS.md)/
[ITOI](../class-6/ITOI.md)). Confirmed trace:

```
HALMAT: 017(1),0,4            <- ADLP (opens the per-element arrayness loop)
          2(6),1,0
          2(6),1,0
          2(6),1,0
L 7,=F'65537'                    <- loop-control literal (packed count/step, e.g. 0x10001)
HALMAT: 441(1),2,0            <- VTOV, TAG=2=DOUBLE_FLAG
          4(1),0,2                <- V1, symbol index 4, QUAL=1=SYT, trailing tag 2
LE 0,V1(7) / SER 1,1              <- indexed load (index register 7 = loop counter),
                                      widens into place
STED 0,V2(7)                      <- indexed store to V2
HALMAT: 018(0),0,4            <- DLPE (closes the loop)
BIX 7,P#3                         <- branch-index, loops back
```

## Unresolved Questions

- The `ADLP` operand's own encoding (`2(6),1,0` repeated three times) and
  the `L 7,=F'65537'` loop-control literal's exact bit packing are not
  decoded — consistent with [ADLP](../class-0/ADLP.md)'s general
  arrayed-loop role being established, but its fine operand details
  remaining open across this whole project.
- The `SINGLE_FLAG` value (narrowing direction) was not independently
  compiled this session — only `@DOUBLE` was tested.
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
