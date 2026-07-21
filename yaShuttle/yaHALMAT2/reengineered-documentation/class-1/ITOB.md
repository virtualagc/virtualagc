# ITOB

**Mnemonic:** ITOB

**Opcode:** 0x1C1

**Confidence:** High

## Behavioral Description

Integer to bit string conversion. Converts an integer operand to its raw
bit-string representation. Classed under Class 1 (bit) because HALMAT
classes conversion operators by their *result* type. Emitted for HAL/S's
`BIT(exp)` shaping/conversion function ([USA003087] §21.2) applied to an
`INTEGER` argument — compiles to an inline shift/store, no runtime call.

## Usage Context

Emitted for the `BIT(...)` shaping-function call when the argument is
`INTEGER`-typed. Selected via `PASS1.PROCS/ENDANYFC.xpl`'s "STRING
SHAPERS" dispatch: `ARG#=XBTOB(PSEUDO_TYPE(MAXPTR)-BIT_TYPE)`, where the
`INT_TYPE` offset selects this case (element 5 of the array).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `INTEGER` argument,
`QUAL`=1=SYT. Confirmed by compiling `B2 = BIT(I1);` (`I1` an `INTEGER`,
`B2` a `BIT(32)`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 1C1(1),0,0            <- ITOB
          3(1),0,0                <- I1, symbol index 3, QUAL=1=SYT
LH 6,I1 / SRL 6,16 / ST 6,B2     <- loads I1, right-shifts into position, stores to B2
```

## Unresolved Questions

- `DOUBLE`-precision integer arguments were not tested.

## Source Analysis & Reliability

Opcode (0x1C1) confirmed primary-source: element 5 of the `XBTOB(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Found by grepping the full `PASS.REL32V0`
compiler source tree for every site referencing `XBTOB`, which led to
`PASS1.PROCS/ENDANYFC.xpl`'s `END_ANY_FCN` procedure's "STRING SHAPERS"
dispatch case, directly identifying the `BIT(...)` shaping-function
construct ([USA003087] §21.2). Full behavioral description and
operand-word structure confirmed directly against real compiled HALMAT
this session.
