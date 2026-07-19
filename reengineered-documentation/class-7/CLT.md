# CLT

**Mnemonic:** CLT

**Opcode:** 0x74A

**Confidence:** High

## Behavioral Description

Character less than. Computes whether one character-string operand is
(lexicographically) less than another, producing a logical (TRUE/FALSE)
result.

## Usage Context

Emitted for HAL/S expressions using the `<` comparison operator between
two CHARACTER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x74A) confirmed primary-source: `XCEQU(5)` array element 5
(`XCLT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 CLT opcode (0x746).

Behavioral description is a straightforward reading of "character less
than" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
