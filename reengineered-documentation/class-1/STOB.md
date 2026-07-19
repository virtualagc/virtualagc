# STOB

**Mnemonic:** STOB
**Opcode:** 0x1A1
**Confidence:** High

## Behavioral Description

Scalar to bit string conversion. Converts a scalar (floating-point)
operand to its raw bit-string representation. Classed under Class 1 (bit)
because HALMAT classes conversion operators by their *result* type.
Emitted for HAL/S's `BIT(exp)` shaping/conversion function ([USA003087]
§21.2) applied to a `SCALAR` argument — compiles to a runtime-library call
(`ETOI`) rather than an inline instruction, unlike the plain register
shuffle seen for [BTOB](BTOB.md).

## Usage Context

Emitted for the `BIT(...)` shaping-function call when the argument is
`SCALAR`-typed. Selected via `PASS1.PROCS/ENDANYFC.xpl`'s "STRING
SHAPERS" dispatch: `ARG#=XBTOB(PSEUDO_TYPE(MAXPTR)-BIT_TYPE)`, where the
`SCALAR_TYPE` offset selects this case (element 4 of the array).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `SCALAR` argument,
`QUAL`=1=SYT. Confirmed by compiling `B1 = BIT(S1);` (`S1` a `SCALAR`,
`B1` a `BIT(32)`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 1A1(1),0,0            <- STOB
          2(1),0,0                <- S1, symbol index 2, QUAL=1=SYT
LE 0,S1 / BAL 4,ETOI             <- runtime routine ETOI converts the scalar's
                                     raw representation to the result bit pattern
ST 5,B1
```

## Unresolved Questions

- Exact bit-pattern semantics of the `ETOI` runtime routine's output
  (e.g. whether it's a raw IEEE-754-like representation or some other
  AP-101S-specific floating-point encoding) are unconfirmed.
- `DOUBLE`-precision scalar arguments were not tested.

## Source Analysis & Reliability

Opcode (0x1A1) confirmed primary-source: element 4 of the `XBTOB(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Found by grepping the full `PASS.REL32V0`
compiler source tree for every site referencing `XBTOB`, which led to
`PASS1.PROCS/ENDANYFC.xpl`'s `END_ANY_FCN` procedure's "STRING SHAPERS"
dispatch case, directly identifying the `BIT(...)` shaping-function
construct ([USA003087] §21.2). Full behavioral description and
operand-word structure confirmed directly against real compiled HALMAT
this session.
