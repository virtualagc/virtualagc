# ILT

**Mnemonic:** ILT
**Opcode:** 0x7CA
**Confidence:** High

## Behavioral Description

Integer less than. Computes whether one integer operand is less than
another, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<` comparison operator between
two INTEGER operands. Notable as the opcode [IR-60-5] A-111 cites as the
upper bound of Class 7's opcode range (0x725–0x7CA) — now confirmed
exactly by [##DRIVER.xpl] (see [BNEQ](BNEQ.md) for the lower bound).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x7CA) confirmed primary-source: `XIEQU(5)` array element 4
(`XILT`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 ILT opcode (0x7CA) exactly.
Also independently corroborated by [IR-60-5] A-111, which cites 0x7CA as
the end of the Class 7 opcode range without naming the mnemonic — this
session's primary-source reading confirms both the opcode and the
mnemonic together.

Behavioral description is a straightforward reading of "integer less
than" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
