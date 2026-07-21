# SSUB

**Mnemonic:** SSUB

**Opcode:** 0x5AC

**Confidence:** High

## Behavioral Description

Scalar subtract. Computes the arithmetic difference of two scalar
operands.

## Usage Context

Emitted for HAL/S expressions using the `-` operator between two scalar
operands. Named explicitly (alongside MSUB/VSUB/ISUB) in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = minuend,
operand 2 = subtrahend. No destination operand — the result is consumed
by a following [SASN](SASN.md) via a `VAC`-qualified operand referencing
this instruction's stream position. Confirmed by compiling `S3 = S1 - S2`
with `HALSFC --parms="LSTALL"`; see `STATUS.md`'s "Empirical
Verification" section (the SADD trace there is directly analogous).

## Unresolved Questions

- None remaining for the base two-scalar-operand case.

## Source Analysis & Reliability

Opcode (0x5AC) confirmed primary-source: part of the `XSSUB(1)` array
(element 0) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SSUB opcode (0x5AC) exactly,
and matches [IR-60-5] A-113's mnemonic. Operand-word format independently
confirmed against real compiled HALMAT this session (see above).

Behavioral description is a straightforward reading of "scalar subtract"
corroborated by [MSC-01847] §2.20; no verbatim operand-word prose
transcribed yet.
