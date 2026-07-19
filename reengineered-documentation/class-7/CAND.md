# CAND

**Mnemonic:** CAND
**Opcode:** 0x7E2
**Confidence:** High

## Behavioral Description

Logical AND. Computes the logical conjunction of two logical (TRUE/FALSE)
operands — typically the results of two prior comparison operators —
producing a logical result. Distinct from [BAND](../class-1/BAND.md)
(bitwise AND of bit-strings, Class 1).

## Usage Context

Emitted for HAL/S expressions combining two conditions with `&` (HAL/S's
logical AND operator), e.g. `IF (X>1) & (Y<5) THEN ...`.

## Operand-Word Format (confirmed empirically)

Two operands, in left-to-right source order, both `QUAL`=3=VAC (`DATA`=
stream position of the producing comparison instruction). Confirmed by
compiling `IF (X>1) & (Y<5) THEN ...;` with
`HALSFC --parms="LISTING2,LSTALL"`, cross-checked directly with
`unHALMAT.py`:

```
HALMAT: 7C8(2),0,0        <- IGT: X > 1
HALMAT: 7CA(2),0,0        <- ILT: Y < 5
HALMAT: 7E2(2),0,0        <- CAND
          20(3),0,0          <- op 1: VAC ref to the IGT result (left operand)
          23(3),0,0          <- op 2: VAC ref to the ILT result (right operand)
HALMAT: 00A(2),0,0        <- FBRA, consumes CAND's result
```

Both operands are fully evaluated (their comparison instructions both
appear in the HALMAT stream, and both corresponding object-code
sequences execute) before CAND itself runs — the generated object code
shows no branch skipping the second comparison, i.e. **no short-circuit
evaluation** at the HALMAT/object-code level for this simple two-term
case.

## Unresolved Questions

- Whether short-circuit evaluation ever occurs for more complex/nested
  logical expressions (as opposed to the simple two-comparison case
  tested, which evaluates both sides unconditionally) is untested.

## Source Analysis & Reliability

Opcode (0x7E2) confirmed primary-source: `XCAND BIT(16) INITIAL("07E2")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 CAND opcode (0x7E2) exactly.

Behavioral description is a straightforward reading of "logical and"
corroborated by [MSC-01847] §2.22 and its worked complex-IF example
(§3.3.2, which uses CAND to combine two conditions). Operand-word
structure confirmed directly against real compiled HALMAT this session
via a direct `unHALMAT.py` binary read.
