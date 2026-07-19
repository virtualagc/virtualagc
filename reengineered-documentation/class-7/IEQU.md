# IEQU

**Mnemonic:** IEQU

**Opcode:** 0x7C6

**Confidence:** High

## Behavioral Description

Integer equal. Computes whether two integer operands are equal, producing
a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `=` comparison operator between
two INTEGER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7C6) confirmed primary-source: `XIEQU(5)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 IEQU opcode (0x7C6) exactly — this integer
comparison sub-family is one of the two (along with scalar) that carried
over unchanged, unlike bit/character/matrix/vector.

Behavioral description is a straightforward reading of "integer equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
