# MMPR

**Mnemonic:** MMPR
**Opcode:** 0x368
**Confidence:** High

## Behavioral Description

Matrix-matrix product. Computes the matrix product of two conformable
matrix operands, producing a matrix result.

## Usage Context

Emitted for HAL/S expressions multiplying two matrix operands — via
**juxtaposition** (e.g. `M3 = M1 M2`), *not* `*`, which is reserved for
vector cross product and produces compile error `E4` ("DOT OR CROSS
PRODUCT SYMBOL (. OR *) USED IN A PRODUCT NOT INVOLVING VECTORS") when
used between two matrices — confirmed empirically this session (see
`STATUS.md`'s "Empirical Verification" section); this corrects an
earlier assumption in this file that `*` was the operator. Compare
[MVPR](../class-4/MVPR.md)/[VMPR](../class-4/VMPR.md) (matrix-vector and
vector-matrix products, both vector-valued) and
[VVPR](VVPR.md) (vector outer product, matrix-valued).

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = left (pre-)
matrix factor, operand 2 = right (post-) matrix factor. No destination
operand — consumed by a following [MASN](MASN.md) via a `VAC`-qualified
operand. Confirmed by compiling `M3 = M1 M2` with
`HALSFC --parms="LSTALL"`.

## Unresolved Questions

- Dimension-compatibility checking (compile-time vs. deferred to runtime)
  is unconfirmed.

## Source Analysis & Reliability

Opcode (0x368) confirmed primary-source: `XMMPR BIT(16) INITIAL("0368")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MMPR opcode (0x368) exactly. Operand-word format
independently confirmed against real compiled HALMAT this session.

Behavioral description is a straightforward reading of "matrix-matrix
product" corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word
prose transcribed yet.
