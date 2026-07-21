# MSPR

**Mnemonic:** MSPR

**Opcode:** 0x3A5

**Confidence:** High

## Behavioral Description

Matrix multiply-by-scalar. Computes the elementwise product of a matrix
operand and a scalar operand, producing a matrix result.

## Usage Context

Emitted for HAL/S expressions using `*` between a matrix and a scalar
operand. Named explicitly (alongside VSPR) in the Optimizer HALMAT
inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed, including which operand
  position holds the matrix vs. the scalar; see
  [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x3A5) confirmed primary-source: `XMSPR BIT(16) INITIAL("03A5")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MSPR opcode (0x3A5) exactly, and matches
[IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "matrix
multiply-by-scalar" corroborated by [MSC-01847] §2.18/2.19; no verbatim
operand-word prose transcribed yet.
