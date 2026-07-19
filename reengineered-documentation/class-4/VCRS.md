# VCRS

**Mnemonic:** VCRS
**Opcode:** 0x48B
**Confidence:** High

## Behavioral Description

Vector cross product. Computes the (3-element) vector cross product of two
vector operands, producing a vector result.

## Usage Context

Emitted for HAL/S expressions using cross-product notation between two
vector operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether/how a dimension check (cross product is only defined for
  3-vectors) is enforced at this instruction vs. earlier is unconfirmed.

## Source Analysis & Reliability

Opcode (0x48B) confirmed primary-source: `XVCRS BIT(16) INITIAL("048B")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 VCRS opcode (0x48B) exactly.

Behavioral description is a straightforward reading of "vector cross
product" corroborated by [MSC-01847] §2.19; no verbatim operand-word
prose transcribed yet.
