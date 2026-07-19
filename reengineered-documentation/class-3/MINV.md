# MINV

**Mnemonic:** MINV

**Opcode:** 0x3CA

**Confidence:** High

## Behavioral Description

Matrix invert. Computes the matrix inverse of a single square matrix
operand, producing a matrix result. Unary.

## Usage Context

Emitted for HAL/S expressions using matrix-inverse notation (e.g. `M**(-1)`
or the built-in inverse mechanism) on a matrix operand.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Runtime behavior for singular (non-invertible) matrices (error handling
  vs. undefined result) is unconfirmed.

## Source Analysis & Reliability

Opcode (0x3CA) confirmed primary-source: `XMINV BIT(16) INITIAL("03CA")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MINV opcode (0x3CA) exactly.

Behavioral description is a straightforward reading of "matrix invert"
corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word prose
transcribed yet.
