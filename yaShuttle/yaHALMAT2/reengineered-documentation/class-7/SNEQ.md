# SNEQ

**Mnemonic:** SNEQ

**Opcode:** 0x7A5

**Confidence:** High

## Behavioral Description

Scalar not equal. Computes whether two scalar operands are unequal,
producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<>` comparison operator between
two SCALAR operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7A5) confirmed primary-source: `XSEQU(5)` array element 1
(`XSNEQ`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SNEQ opcode (0x7A5) exactly.

Behavioral description is a straightforward reading of "scalar not equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
