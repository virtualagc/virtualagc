# IGT

**Mnemonic:** IGT
**Opcode:** 0x7C8
**Confidence:** High

## Behavioral Description

Integer greater than. Computes whether one integer operand is greater
than another, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `>` comparison operator between
two INTEGER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7C8) confirmed primary-source: `XIEQU(5)` array element 3
(`XIGT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 IGT opcode (0x7C8) exactly.

Behavioral description is a straightforward reading of "integer greater
than" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
