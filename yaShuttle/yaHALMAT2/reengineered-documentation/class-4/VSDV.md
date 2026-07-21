# VSDV

**Mnemonic:** VSDV

**Opcode:** 0x4A6

**Confidence:** High

## Behavioral Description

Vector divide-by-scalar. Computes the elementwise quotient of a vector
operand divided by a scalar operand, producing a vector result.

## Usage Context

Emitted for HAL/S expressions using `/` between a vector and a scalar
operand. Named explicitly (alongside MSDV) in the Optimizer HALMAT
inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x4A6) confirmed primary-source: `XVSDV BIT(16) INITIAL("04A6")`,
alongside `XMSDV`/`XSSDV` in the same declaration group, in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 VSDV opcode (0x4A6) exactly, and matches
[IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "vector
divide-by-scalar" corroborated by [MSC-01847] §2.19; no verbatim
operand-word prose transcribed yet.
