# VSPR

**Mnemonic:** VSPR
**Opcode:** 0x4A5
**Confidence:** High

## Behavioral Description

Vector multiply-by-scalar. Computes the elementwise product of a vector
operand and a scalar operand, producing a vector result.

## Usage Context

Emitted for HAL/S expressions using `*` between a vector and a scalar
operand. Named explicitly (alongside MSPR) in the Optimizer HALMAT
inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed, including which operand
  position holds the vector vs. the scalar; see
  [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x4A5) confirmed primary-source: `XVSPR BIT(16) INITIAL("04A5")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 VSPR opcode (0x4A5) exactly, and matches
[IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "vector
multiply-by-scalar" corroborated by [MSC-01847] §2.19; no verbatim
operand-word prose transcribed yet.
