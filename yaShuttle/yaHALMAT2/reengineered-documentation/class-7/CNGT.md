# CNGT

**Mnemonic:** CNGT

**Opcode:** 0x747

**Confidence:** High

## Behavioral Description

Character not greater than. Computes whether one character-string operand
is not greater than another (i.e. less-than-or-equal), producing a
logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<=` comparison operator between
two CHARACTER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x747) confirmed primary-source: `XCEQU(5)` array element 2
(`XCNGT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 CNGT opcode (0x743).

Behavioral description is a straightforward reading of "character not
greater than" corroborated by [MSC-01847] §2.22; no verbatim operand-word
prose transcribed yet.
