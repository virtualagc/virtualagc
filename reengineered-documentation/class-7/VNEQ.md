# VNEQ

**Mnemonic:** VNEQ
**Opcode:** 0x785
**Confidence:** High

## Behavioral Description

Vector not equal. Computes whether two vector operands are not
elementwise equal, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<>` comparison operator between
two VECTOR operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x785) confirmed primary-source: `XVEQU(1)` array element 1
(`XVNEQ`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 VNEQ opcode (0x781).

Behavioral description is a straightforward reading of "vector not equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
