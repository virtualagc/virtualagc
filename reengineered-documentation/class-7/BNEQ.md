# BNEQ

**Mnemonic:** BNEQ

**Opcode:** 0x725

**Confidence:** High

## Behavioral Description

Bit string not equal. Computes whether two bit-string operands are
unequal, producing a logical (TRUE/FALSE) result.

## Usage Context

Emitted for HAL/S expressions using the `<>` (not equal) comparison
operator between two BIT operands. Notable as the opcode [IR-60-5] A-111
cites as the lower bound of Class 7's opcode range (0x725–0x7CA) — now
confirmed exactly by [##DRIVER.xpl] (see [ILT](ILT.md) for the upper
bound).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x725) confirmed primary-source: `XBEQU(1)` array element 1
(`XBNEQ`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. **Differs** from [MSC-01847]'s HAL-1971 BNEQ opcode (0x721).
Also independently corroborated by [IR-60-5] A-111, which cites 0x725 as
the start of the Class 7 opcode range without naming the mnemonic — this
session's primary-source reading confirms both the opcode and the
mnemonic together.

Behavioral description is a straightforward reading of "bit string not
equal" corroborated by [MSC-01847] §2.22; no verbatim operand-word prose
transcribed yet.
