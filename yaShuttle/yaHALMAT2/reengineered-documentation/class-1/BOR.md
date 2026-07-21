# BOR

**Mnemonic:** BOR

**Opcode:** 0x103

**Confidence:** High

## Behavioral Description

Bit-string OR. Computes the bitwise logical OR of two bit-string operands.

## Usage Context

Emitted for HAL/S expressions using the bit-string OR operator.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x103) confirmed primary-source: `XBOR BIT(16) INITIAL("0103")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 BOR opcode (0x103) exactly.

Behavioral description is a straightforward reading of "bit-string or"
corroborated by [MSC-01847] §2.16; no verbatim operand-word prose
transcribed yet.
