# INGT

**Mnemonic:** INGT

**Opcode:** 0x7C7

**Confidence:** High

## Behavioral Description

Integer not greater than. Computes whether one integer operand is not
greater than another (i.e. less-than-or-equal), producing a logical
(TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<=` comparison operator between
two INTEGER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7C7) confirmed primary-source: `XIEQU(5)` array element 2
(`XINGT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 INGT opcode (0x7C7) exactly.

Behavioral description is a straightforward reading of "integer not
greater than" corroborated by [MSC-01847] §2.22; no verbatim operand-word
prose transcribed yet.
