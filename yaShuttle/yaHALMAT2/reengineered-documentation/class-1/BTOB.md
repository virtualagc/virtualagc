# BTOB

**Mnemonic:** BTOB

**Opcode:** 0x121

**Confidence:** High

## Behavioral Description

Bit string to bit string conversion — the "self" slot of the `XBTOB`
"convert to bit string" family (alongside [CTOB](CTOB.md),
[STOB](STOB.md), [ITOB](ITOB.md)), all triggered by HAL/S's `BIT(exp)`
shaping/conversion function ([USA003087] §21.2 — a plain length-adjusting
`BIT(exp)` conversion, distinct from the `SUBBIT(...)` pseudo-conversion
handled by [BTOQ](BTOQ.md)/etc.). Confirms the length-adjustment
hypothesis: applying `BIT(...)` to an already-`BIT`-typed argument
compiles to a direct register load-and-store with no runtime call (unlike
[CTOB](CTOB.md)'s `#QCTOB` runtime routine), consistent with a pure
length/positioning adjustment between differently-sized bit strings
rather than any real "conversion."

## Usage Context

Emitted for the `BIT(...)` shaping-function call ([USA003087] §21.2) when
the argument is itself `BIT`-typed. Selected via
`PASS1.PROCS/ENDANYFC.xpl`'s "STRING SHAPERS" dispatch:
`ARG#=XBTOB(PSEUDO_TYPE(MAXPTR)-BIT_TYPE)`, where element 0 (`BIT_TYPE`
offset 0) selects this self-conversion case.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the source `BIT` argument,
`QUAL`=1=SYT. Confirmed by compiling `B4 = BIT(B0);` (`B0` a `BIT(8)`,
`B4` a `BIT(32)`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 121(1),0,0            <- BTOB
          5(1),0,0                <- B0, symbol index 5, QUAL=1=SYT
LH 7,B0 / SRL 7,16 / ST 7,B4     <- loads B0, right-shifts into position, stores to B4
```

## Unresolved Questions

- The exact positioning rule for source bit strings shorter/longer than
  the destination (here, an 8-bit source into a 32-bit destination,
  right-aligned after a 16-bit shift) was observed but not systematically
  varied across other length combinations.

## Source Analysis & Reliability

Opcode (0x121) confirmed primary-source: element 0 of the `XBTOB(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Not present in [MSC-01847]. Found by grepping the full `PASS.REL32V0`
compiler source tree for every site referencing `XBTOB`, which led to
`PASS1.PROCS/ENDANYFC.xpl`'s `END_ANY_FCN` procedure's "STRING SHAPERS"
dispatch case, directly identifying the `BIT(...)` shaping-function
construct ([USA003087] §21.2). Full behavioral description and
operand-word structure confirmed directly against real compiled HALMAT
this session (alongside its siblings [STOB](STOB.md)/[ITOB](ITOB.md), and
cross-checked against the already-High-confidence [CTOB](CTOB.md)).
