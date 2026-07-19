# BCAT

**Mnemonic:** BCAT

**Opcode:** 0x105

**Confidence:** High

## Behavioral Description

Bit-string catenate. Concatenates two bit-string operands into a single,
longer bit-string result.

## Usage Context

Emitted for HAL/S expressions using the bit-string concatenation operator
(`||` applied to BIT operands).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether the result length is carried in the instruction itself or
  derived entirely from the symbol table is unconfirmed.

## Source Analysis & Reliability

Opcode (0x105) confirmed primary-source: `XBCAT BIT(16) INITIAL("0105")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 BCAT opcode (0x105) exactly.

Behavioral description is a straightforward reading of "bit-string
catenate" corroborated by [MSC-01847] §2.16; no verbatim operand-word
prose transcribed yet.
