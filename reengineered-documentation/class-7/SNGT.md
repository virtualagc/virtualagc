# SNGT

**Mnemonic:** SNGT

**Opcode:** 0x7A7

**Confidence:** High

## Behavioral Description

Scalar not greater than. Computes whether one scalar operand is not
greater than another (i.e. less-than-or-equal), producing a logical
(TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<=` comparison operator between
two SCALAR operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7A7) confirmed primary-source: `XSEQU(5)` array element 2
(`XSNGT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SNGT opcode (0x7A7) exactly.

Behavioral description is a straightforward reading of "scalar not
greater than" corroborated by [MSC-01847] §2.22; no verbatim operand-word
prose transcribed yet.
