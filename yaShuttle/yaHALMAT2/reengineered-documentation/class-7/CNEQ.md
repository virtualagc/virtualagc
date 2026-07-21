# CNEQ

**Mnemonic:** CNEQ

**Opcode:** 0x745

**Confidence:** High

## Behavioral Description

Character not equal. Computes whether two character-string operands are
unequal, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<>` comparison operator between
two CHARACTER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x745) confirmed primary-source: `XCEQU(5)` array element 1
(`XCNEQ`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 CNEQ opcode (0x741).

Behavioral description is a straightforward reading of "character not
equal" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
