# SEQU

**Mnemonic:** SEQU

**Opcode:** 0x7A6

**Confidence:** High

## Behavioral Description

Scalar equal. Computes whether two scalar (floating-point) operands are
equal, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `=` comparison operator between
two SCALAR operands — one of the most frequently-emitted comparison
operators.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Floating-point equality semantics (exact bit comparison vs. tolerance)
  is unconfirmed.

## Source Analysis & Reliability

Opcode (0x7A6) confirmed primary-source: `XSEQU(5)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 SEQU opcode (0x7A6) exactly — this scalar
comparison sub-family is one of the two (along with integer) that
carried over unchanged, unlike bit/character/matrix/vector.

Behavioral description is a straightforward reading of "scalar equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
