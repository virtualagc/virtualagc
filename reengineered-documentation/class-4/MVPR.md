# MVPR

**Mnemonic:** MVPR
**Opcode:** 0x46C
**Confidence:** High

## Behavioral Description

Matrix-vector product. Computes the product of a matrix operand and a
vector operand (matrix premultiplying vector), producing a vector result
— classed under Class 4 (vector) despite the "M" mnemonic prefix, because
HALMAT classes operators by their result type. Compare
[VMPR](VMPR.md) (vector premultiplying matrix, also vector-valued) and
[MMPR](../class-3/MMPR.md) (matrix-matrix product, matrix-valued).

## Usage Context

Emitted for HAL/S expressions computing a matrix-vector product.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed, including which operand
  position holds the matrix vs. the vector; see
  [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x46C) confirmed primary-source: `XMVPR BIT(16) INITIAL("046C")`
in `PASS1.PROCS/##DRIVER.xpl`, declared immediately before `XVMPR` (see
[VMPR](VMPR.md)) — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MVPR opcode (0x46C) exactly.

Behavioral description is a straightforward reading of "matrix-vector
product" corroborated by [MSC-01847] §2.19; no verbatim operand-word
prose transcribed yet.
