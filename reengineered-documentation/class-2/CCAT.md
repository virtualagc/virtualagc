# CCAT

**Mnemonic:** CCAT
**Opcode:** 0x202
**Confidence:** High

## Behavioral Description

Character catenate. Concatenates two character-string operands into a
single, longer character-string result.

## Usage Context

Emitted for HAL/S expressions using the character concatenation operator
(`||` applied to CHARACTER operands).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Interaction with VARYING-length results (does the result length live in
  the instruction, or purely in the symbol table) is unconfirmed.

## Source Analysis & Reliability

Opcode (0x202) confirmed primary-source: `XCCAT BIT(16) INITIAL("0202")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 CCAT opcode (0x202) exactly.

Behavioral description is a straightforward reading of "character
catenate" corroborated by [MSC-01847] §2.17; no verbatim operand-word
prose transcribed yet.
