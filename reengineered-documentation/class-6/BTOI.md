# BTOI

**Mnemonic:** BTOI
**Opcode:** 0x621
**Confidence:** High

## Behavioral Description

Bit to integer conversion. Converts a bit-string operand to its integer
numeric value. Classed under Class 6 (integer) because HALMAT classes
conversion operators by their *result* type — see the general note in
`STATUS.md`.

## Usage Context

Emitted wherever a bit-string value must be converted to integer.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x621) confirmed primary-source: element 0 of the `XBTOI(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 BTOI opcode (0x621) exactly.

Behavioral description is a straightforward reading of "bit to integer
conversion" corroborated by [MSC-01847] §2.21; no verbatim operand-word
prose transcribed yet.
