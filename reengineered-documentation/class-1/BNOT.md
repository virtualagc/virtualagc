# BNOT

**Mnemonic:** BNOT
**Opcode:** 0x104
**Confidence:** High

## Behavioral Description

Bit-string complement. Computes the bitwise logical NOT (one's complement)
of a single bit-string operand.

## Usage Context

Emitted for HAL/S expressions using the bit-string complement (`NOT`)
operator. Unlike the other Class 1 arithmetic operators, this is unary
(one source operand rather than two).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x104) confirmed primary-source: `XBNOT BIT(16) INITIAL("0104")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 BNOT opcode (0x104) exactly.

Behavioral description is a straightforward reading of "bit-string
complement" corroborated by [MSC-01847] §2.16; no verbatim operand-word
prose transcribed yet.
