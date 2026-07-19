# MNEQ

**Mnemonic:** MNEQ
**Opcode:** 0x765
**Confidence:** High

## Behavioral Description

Matrix not equal. Computes whether two matrix operands are not
elementwise equal, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<>` comparison operator between
two MATRIX operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x765) confirmed primary-source: `XMEQU(1)` array element 1
(`XMNEQ`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 MNEQ opcode (0x761).

Behavioral description is a straightforward reading of "matrix not equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
