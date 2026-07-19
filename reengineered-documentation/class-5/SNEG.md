# SNEG

**Mnemonic:** SNEG

**Opcode:** 0x5B0

**Confidence:** High

## Behavioral Description

Scalar negate. Computes the arithmetic negation of a single scalar
operand.

## Usage Context

Emitted for HAL/S expressions using unary minus on a scalar operand. Named
explicitly (alongside MNEG/VNEG/INEG) in the Optimizer HALMAT inline-
vector/matrix-loop note in [HALMAT.md](../HALMAT.md#optimizer-halmat),
sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x5B0) confirmed primary-source: part of the `XMNEG(3)` array
(element 2) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SNEG opcode (0x5B0) exactly,
and matches [IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "scalar negate"
corroborated by [MSC-01847] §2.20; no verbatim operand-word prose
transcribed yet.
