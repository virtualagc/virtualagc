# MEQU

**Mnemonic:** MEQU
**Opcode:** 0x766
**Confidence:** High

## Behavioral Description

Matrix equal. Computes whether two matrix operands are elementwise equal,
producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `=` comparison operator between
two MATRIX operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x766) confirmed primary-source: `XMEQU(1)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. **Differs**
from [MSC-01847]'s HAL-1971 MEQU opcode (0x762).

Behavioral description is a straightforward reading of "matrix equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
