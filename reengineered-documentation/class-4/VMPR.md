# VMPR

**Mnemonic:** VMPR
**Opcode:** 0x46D
**Confidence:** High

## Behavioral Description

Vector-matrix product. Computes the product of a vector operand and a
matrix operand (vector premultiplying matrix), producing a vector result
— distinct from [MVPR](MVPR.md) (matrix premultiplying vector).

## Usage Context

Emitted for HAL/S expressions computing a vector-matrix product.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed, including which operand
  position holds the vector vs. the matrix; see
  [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

**Correction to an earlier session's inference**: this project previously
inferred VMPR's HAL/S opcode as 0x4CD, carried over directly from
[MSC-01847]'s HAL-1971 value. Reading the actual compiler source this
session found `XVMPR BIT(16) INITIAL("046D")` in
`PASS1.PROCS/##DRIVER.xpl`, immediately following `XMVPR`("046C") — see
[##DRIVER.xpl] in `STATUS.md`. HAL/S's VMPR is therefore at 0x46D, *not*
0x4CD; the two language versions assign this particular opcode
differently (unlike most Class 3/4 arithmetic mnemonics, which matched
exactly — see `STATUS.md`'s Class 4 table).

Behavioral description is a straightforward reading of "vector-matrix
product" corroborated by [MSC-01847] §2.19; no verbatim operand-word
prose transcribed yet.
