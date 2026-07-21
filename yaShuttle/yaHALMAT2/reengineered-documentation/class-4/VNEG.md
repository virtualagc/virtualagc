# VNEG

**Mnemonic:** VNEG

**Opcode:** 0x444

**Confidence:** High

## Behavioral Description

Vector negate. Computes the elementwise arithmetic negation of a single
vector operand.

## Usage Context

Emitted for HAL/S expressions using unary minus on a vector operand. Named
explicitly (alongside MNEG/SNEG/INEG) in the Optimizer HALMAT inline-
vector/matrix-loop note in [HALMAT.md](../HALMAT.md#optimizer-halmat),
sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x444) confirmed primary-source: part of the `XMNEG(3)` array
(element 1) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 VNEG opcode (0x444) exactly,
and matches [IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "vector negate"
corroborated by [MSC-01847] §2.19; no verbatim operand-word prose
transcribed yet.
