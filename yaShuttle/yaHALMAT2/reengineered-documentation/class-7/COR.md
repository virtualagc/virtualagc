# COR

**Mnemonic:** COR

**Opcode:** 0x7E3

**Confidence:** High

## Behavioral Description

Logical OR. Computes the logical disjunction of two logical (TRUE/FALSE)
operands, producing a logical result. Distinct from
[BOR](../class-1/BOR.md) (bitwise OR of bit-strings, Class 1).

## Usage Context

Emitted for HAL/S expressions combining two conditions with `|` (HAL/S's
logical OR operator).

## Operand-Word Format (confirmed empirically)

Two operands, in left-to-right source order, both `QUAL`=3=VAC (`DATA`=
stream position of the producing comparison instruction) — same shape as
[CAND](CAND.md). Confirmed by compiling `IF (X>1) OR (Y<5) THEN ...;`
(HAL/S accepted the `OR` keyword form here, not just `|`) with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 7C8(2),0,0        <- IGT: X > 1
HALMAT: 7CA(2),0,0        <- ILT: Y < 5
HALMAT: 7E3(2),0,0        <- COR
          51(3),0,0          <- op 1: VAC ref to the IGT result (left operand)
          54(3),0,0          <- op 2: VAC ref to the ILT result (right operand)
```

Both operands are fully evaluated before COR runs (no short-circuit
skip of the second comparison), same as [CAND](CAND.md).

## Unresolved Questions

- Whether short-circuit evaluation ever occurs for more complex/nested
  logical expressions is untested; see [CAND](CAND.md).

## Source Analysis & Reliability

Opcode (0x7E3) confirmed primary-source: `XCOR BIT(16) INITIAL("07E3")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 COR opcode (0x7E3) exactly. Operand-word structure
confirmed directly against real compiled HALMAT this session via a
direct `unHALMAT.py` binary read.

Behavioral description is a straightforward reading of "logical or"
corroborated by [MSC-01847] §2.22.
