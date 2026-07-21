# INEG

**Mnemonic:** INEG

**Opcode:** 0x6D0

**Confidence:** High

## Behavioral Description

Integer negate. Computes the arithmetic negation of a single integer
operand.

## Usage Context

Emitted for HAL/S expressions using unary minus on an integer operand.
Named explicitly (alongside MNEG/VNEG/SNEG) in the Optimizer HALMAT
inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x6D0) confirmed primary-source: part of the `XMNEG(3)` array
(element 3) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 INEG opcode (0x6D0) exactly,
and matches [IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "integer negate"
corroborated by [MSC-01847] §2.21; no verbatim operand-word prose
transcribed yet.
