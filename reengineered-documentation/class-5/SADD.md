# SADD

**Mnemonic:** SADD

**Opcode:** 0x5AB

**Confidence:** High

## Behavioral Description

Scalar add. Computes the arithmetic sum of two scalar operands.

## Usage Context

Emitted for HAL/S expressions using the `+` operator between two scalar
operands — one of the most frequently-emitted arithmetic operators. Named
explicitly (alongside MADD/VADD/IADD) in the Optimizer HALMAT inline-
vector/matrix-loop note in [HALMAT.md](../HALMAT.md#optimizer-halmat),
sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = first addend,
operand 2 = second addend. No destination operand — the sum is consumed
by a following [SASN](SASN.md) instruction via a `VAC`-qualified operand
whose `DATA` field is this instruction's own stream position. Confirmed
by compiling `S3 = S1 + S2` with `HALSFC --parms="LSTALL"`; see
`STATUS.md`'s "Empirical Verification" section for the full trace.

## Unresolved Questions

- None remaining for the base two-scalar-operand case.

## Source Analysis & Reliability

Opcode (0x5AB) confirmed primary-source: part of the `XSADD(1)` array
(element 0) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SADD opcode (0x5AB) exactly,
and matches [IR-60-5] A-113's mnemonic. Operand-word format independently
confirmed against real compiled HALMAT this session (see above).

Behavioral description is a straightforward reading of "scalar add"
corroborated by [MSC-01847] §2.20; no verbatim operand-word prose
transcribed yet.
