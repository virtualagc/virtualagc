# INEQ

**Mnemonic:** INEQ
**Opcode:** 0x7C5
**Confidence:** High

## Behavioral Description

Integer not equal. Computes whether two integer operands are unequal,
producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<>` comparison operator between
two INTEGER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7C5) confirmed primary-source: `XIEQU(5)` array element 1
(`XINEQ`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 INEQ opcode (0x7C5) exactly.

Behavioral description is a straightforward reading of "integer not
equal" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
