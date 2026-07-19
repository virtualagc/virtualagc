# MTOM

**Mnemonic:** MTOM

**Opcode:** 0x341

**Confidence:** High

## Behavioral Description

Matrix precision scale. Converts a matrix operand from its current
precision (`SINGLE` vs. `DOUBLE`) to a different required precision.
Unlike most conversion operators, this is *not* a cross-type conversion
(matrix stays matrix) — it adjusts the internal numeric representation
only. Confirmed trigger: HAL/S's postfix precision-qualifier syntax,
`exp$(@SINGLE)`/`exp$(@DOUBLE)` (`PASS1.PROCS/SYNTHESI.xpl`'s grammar
rule `<QUALIFIER> ::= <$> ( @ <PREC SPEC> )`, `<PREC SPEC> ::= SINGLE |
DOUBLE`) — an explicit request to force an expression's result to a
specific precision. Like [VTOV](../class-4/VTOV.md), `MTOM` converts one
element at a time and is wrapped in an [ADLP](../class-0/ADLP.md)/
[DLPE](../class-0/DLPE.md) arrayness loop.

The instruction's operator-word `TAG` field carries the precision request
directly: confirmed `2` for `@DOUBLE` (`PRECSCAL.xpl`'s `DOUBLE_FLAG`
constant, tested against `PSEUDO_FORM`'s low 4 bits and passed straight
through as `TAG` — `CALL HALMAT_TUPLE(XMTOM(P_TYPE-MAT_TYPE),0,MP,0,
P_TEMP&"F")`).

## Usage Context

Emitted for `exp$(@DOUBLE)`/`exp$(@SINGLE)` applied to a `MATRIX`
expression — confirmed by compiling `M2 = M1$(@DOUBLE);` (`M1` a `SINGLE`
`MATRIX(2,2)`, `M2` `DOUBLE`), in the same test program as
[STOS](../class-5/STOS.md)/[ITOI](../class-6/ITOI.md)/
[VTOV](../class-4/VTOV.md). Called from `PREC_SCALE`, itself called from
`SETUP_NO_ARG_FCN` and `SYNTHESIZE` — i.e. during general expression
synthesis, triggered specifically by the qualifier, not by plain
variable-to-variable assignment (an earlier empirical test this project,
`S2 = S1;` between differently-precision scalars, did *not* trigger this
family — the precision adjustment for simple assignment is instead
handled implicitly by the generated object code).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `MATRIX`,
`QUAL`=1=SYT, with a non-zero trailing tag (observed `2`) not decoded
(same pattern as [VTOV](../class-4/VTOV.md)'s operand). Confirmed trace:

```
HALMAT: 017(1),0,4            <- ADLP (opens the per-element arrayness loop)
          4(6),1,0
          4(6),1,0
          4(6),1,0
L 7,=F'65539'                    <- loop-control literal (packed count/step)
HALMAT: 341(1),2,0            <- MTOM, TAG=2=DOUBLE_FLAG
          6(1),0,2                <- M1, symbol index 6, QUAL=1=SYT, trailing tag 2
LE 0,M1(7) / SER 1,1              <- indexed load (index register 7 = loop counter),
                                      widens into place
STED 0,M2(7)                      <- indexed store to M2
HALMAT: 018(0),0,4            <- DLPE (closes the loop)
BIX 7,P#4                         <- branch-index, loops back
```

## Unresolved Questions

- The `ADLP` operand's own encoding and the `L 7,=F'65539'` loop-control
  literal's exact bit packing are not decoded (same open question as
  [VTOV](../class-4/VTOV.md)).
- The `SINGLE_FLAG` value (narrowing direction) was not independently
  compiled this session — only `@DOUBLE` was tested.
- Non-square matrices were not tested.

## Source Analysis & Reliability

Opcode (0x341) confirmed primary-source: element 0 of the `XMTOM(3)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Behavioral role primary-sourced from
`PASS1.PROCS/PRECSCAL.xpl`'s `PREC_SCALE` procedure. The trigger
construct (`$(@SINGLE)`/`$(@DOUBLE)`) was found by tracing `PREC_SCALE`'s
callers back to `SYNTHESI.xpl`'s `<QUALIFIER> ::= <$> ( @ <PREC SPEC> )`
grammar rule and its `SINGLE`/`DOUBLE` alternatives — a case where the
compiler-source grep technique (finding every site referencing `XMTOM`)
had already succeeded in an earlier session, but pinning the exact
triggering *syntax* required additionally tracing the calling procedure's
own grammar-rule context, one level further than the direct constant
grep. Full behavioral description and operand-word structure now
confirmed directly against real compiled HALMAT, resolving the prior
"Medium confidence, mechanism known but syntax unconfirmed" state.
