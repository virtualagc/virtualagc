# CGT

**Mnemonic:** CGT

**Opcode:** 0x748

**Confidence:** High

## Behavioral Description

Character greater than. Computes whether one character-string operand is
(lexicographically, presumably by underlying byte/collation value)
greater than another, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `>` comparison operator between
two CHARACTER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Exact collation rule (byte value, EBCDIC vs. ASCII ordering, length
  handling) is unconfirmed.

## Source Analysis & Reliability

Opcode (0x748) confirmed primary-source: `XCEQU(5)` array element 3
(`XCGT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 CGT opcode (0x744).

Behavioral description is a straightforward reading of "character greater
than" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
