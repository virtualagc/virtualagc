# BEQU

**Mnemonic:** BEQU

**Opcode:** 0x726

**Confidence:** High

## Behavioral Description

Bit string equal. Computes whether two bit-string operands are equal,
producing a logical (TRUE/FALSE) result — classed under Class 7
(conditional) because HALMAT classes comparison operators by their result
type, regardless of operand type.

## Usage Context

Emitted for HAL/S expressions using the `=` comparison operator between
two BIT operands, typically as the test of an `IF`, `DO WHILE`, or `DO
UNTIL` statement (directly, or via a following
[FBRA](../class-0/FBRA.md)/[BBRA](../STATUS.md)-family branch consuming
the result).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether BEQU's result is computed independently or as the logical
  complement of [BNEQ](BNEQ.md) is unconfirmed.

## Source Analysis & Reliability

Opcode (0x726) confirmed primary-source: `XBEQU(1)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. **Differs**
from [MSC-01847]'s HAL-1971 BEQU opcode (0x722) — one of several
comparison-operator families renumbered between the two language
versions (see the general note in `STATUS.md`'s Class 7 table).

Behavioral description is a straightforward reading of "bit string equal"
corroborated by [MSC-01847] §2.22 (Conditional Operations); no verbatim
operand-word prose transcribed yet.
