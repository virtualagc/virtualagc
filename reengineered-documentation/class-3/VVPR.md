# VVPR

**Mnemonic:** VVPR
**Opcode:** 0x387
**Confidence:** High

## Behavioral Description

Vector outer product. Computes the outer product of two vector operands,
producing a *matrix* result — classed under Class 3 (matrix) despite the
"V" mnemonic prefix, because HALMAT classes operators by their result
type (see the general note in `STATUS.md`).

## Usage Context

Emitted for HAL/S expressions using vector outer-product notation between
two vector operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- How the resulting matrix's dimensions (derived from the two input
  vectors' lengths) are communicated is unconfirmed.

## Source Analysis & Reliability

Opcode (0x387) confirmed primary-source: `XVVPR BIT(16) INITIAL("0387")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 VVPR opcode (0x387) exactly.

Behavioral description is a straightforward reading of "vector outer
product" corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word
prose transcribed yet.
