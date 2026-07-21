# CEQU

**Mnemonic:** CEQU

**Opcode:** 0x746

**Confidence:** High

## Behavioral Description

Character equal. Computes whether two character-string operands are
equal, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `=` comparison operator between
two CHARACTER operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- String comparison semantics for unequal-length operands (padding rule)
  is unconfirmed.

## Source Analysis & Reliability

Opcode (0x746) confirmed primary-source: `XCEQU(5)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. **Differs**
from [MSC-01847]'s HAL-1971 CEQU opcode (0x742).

Behavioral description is a straightforward reading of "character equal"
corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
