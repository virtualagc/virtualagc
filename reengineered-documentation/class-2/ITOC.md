# ITOC

**Mnemonic:** ITOC

**Opcode:** 0x2C1

**Confidence:** High

## Behavioral Description

Integer to character conversion. Converts an integer operand to its
character-string representation. Classed under Class 2 (character)
because HALMAT classes conversion operators by their *result* type — see
[STOC](STOC.md) for the general pattern.

## Usage Context

Emitted wherever an integer value must be converted to character,
including inside shaping-function invocations (see
[SFST](../class-0/SFST.md)) for the HAL/S built-in `CHAR(...)` function
applied to an integer argument.

## Confirmed Output Format

Per [USA00309] §8.2 rule 15 (citing §6.1.3 for format): converting a
single- or double-precision integer to character produces a
**variable-length field of up to 11 characters** — matching §6.1.3's
`WRITE`-statement integer format: right-justified, leading zeros
suppressed, with a leading minus sign if negative (no sign character at
all for non-negative values, unlike the scalar conversions — see
[STOC](STOC.md)).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x2C1) confirmed primary-source: element 5 of the `XBTOC` array in
`PASS1.PROCS/##DRIVER.xpl` (value `"02C1"`) — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 ITOC opcode (0x2C1) exactly.

Behavioral description is a straightforward reading of "integer to
character conversion" corroborated by [MSC-01847] §2.17. Output format
primary-sourced from [USA00309] §8.2/§6.1.3 — see `STATUS.md`. No
verbatim operand-word (bit-level) prose transcribed yet.
