# BTOS

**Mnemonic:** BTOS

**Opcode:** 0x521

**Confidence:** High

## Behavioral Description

Bit string to scalar conversion. Converts a bit-string operand to its
scalar (floating-point) numeric value, per HAL/S's bit-to-numeric
conversion rules. Classed under Class 5 (scalar) because HALMAT classes
conversion operators by their *result* type — see the general note in
`STATUS.md`.

## Usage Context

Emitted wherever a bit-string value must be converted to scalar, including
via the HAL/S built-in conversion mechanism.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x521) confirmed primary-source: element 0 of the `XBTOS(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 BTOS opcode (0x521) exactly — one of
several conversion opcodes that carried over unchanged between the two
language versions.

Behavioral description is a straightforward reading of "bit string to
scalar conversion" corroborated by [MSC-01847] §2.20; no verbatim
operand-word prose transcribed yet.
