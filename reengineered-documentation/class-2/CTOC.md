# CTOC

**Mnemonic:** CTOC
**Opcode:** 0x241
**Confidence:** High

## Behavioral Description

Character to character conversion — the "self" slot of the `XBTOC`
"convert to character" family (alongside [BTOC](BTOC.md), [STOC](STOC.md),
[ITOC](ITOC.md)). Confirmed to be triggered by HAL/S's `CHARACTER(exp)`
shaping/conversion function ([USA003087] §21.2) applied to an
already-`CHARACTER`-typed argument — i.e. this is exactly the
length-adjustment case originally hypothesized (analogous to
[BTOB](../class-1/BTOB.md)'s bit-string self-conversion), triggered by an
explicit `CHARACTER(...)` call rather than by plain assignment between
differently-sized `CHARACTER` variables (plain assignment was not
directly retested this session, but the triggering mechanism is now
confirmed to at minimum include the explicit shaping-function form).

## Usage Context

Emitted for the `CHARACTER(...)` shaping-function call when the argument
is `CHARACTER`-typed. Selected via `PASS1.PROCS/ENDANYFC.xpl`'s "STRING
SHAPERS" dispatch (the same dispatch site as [BTOC](BTOC.md); the
`CHAR_TYPE`-offset element 1 of `XBTOC` selects this self-conversion
case).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `CHARACTER`
argument, `QUAL`=1=SYT. Confirmed by compiling `C2 = CHARACTER(C0);`
(`C0` a `CHARACTER(10)`, `C2` a `CHARACTER(20)`) with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 241(1),0,0            <- CTOC
          3(1),0,0                <- C0, symbol index 3, QUAL=1=SYT
```

## Unresolved Questions

- Whether plain `C2 = C1;` assignment between differently-lengthed
  `CHARACTER` variables (without an explicit `CHARACTER(...)` call) also
  triggers `CTOC`, or is instead handled implicitly like the
  [MTOM](../class-3/MTOM.md) precision family's simple-assignment
  negative result, was not retested this session.
- The exact runtime mechanism (padding vs. truncation rule, fixed-length
  vs. `VARYING` interaction) is not decoded from the trace alone — the
  operator word carries no visible length/truncation-mode tag beyond the
  single source operand.

## Source Analysis & Reliability

Opcode (0x241) confirmed primary-source: element 1 of the `XBTOC(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Found by grepping the full `PASS.REL32V0`
compiler source tree for every site referencing `XBTOC`, which led to
`PASS1.PROCS/ENDANYFC.xpl`'s `END_ANY_FCN` procedure's "STRING SHAPERS"
dispatch case, directly identifying the `CHARACTER(...)` shaping-function
construct ([USA003087] §21.2). Full behavioral description and
operand-word structure confirmed directly against real compiled HALMAT
this session, resolving the previously-speculative length-adjustment
hypothesis into a confirmed fact.
