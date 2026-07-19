# MSUB

**Mnemonic:** MSUB

**Opcode:** 0x363

**Confidence:** High

## Behavioral Description

Matrix subtract. Computes the elementwise difference of two matrix
operands of matching dimensions, producing a matrix result.

## Usage Context

Emitted for HAL/S expressions using the `-` operator between two matrix
operands. Named explicitly (alongside VSUB/SSUB/ISUB) in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = minuend,
operand 2 = subtrahend. No destination operand — consumed by a following
[MASN](MASN.md) via a `VAC`-qualified operand. Confirmed by compiling
`M3 = M1 - M2` with `HALSFC --parms="LSTALL"`; see `STATUS.md`'s
"Empirical Verification" section.

## Unresolved Questions

- None remaining for the base two-matrix-operand case.

## Source Analysis & Reliability

Opcode (0x363) confirmed primary-source: part of the `XMSUB(1)` array
(element 0) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 MSUB opcode (0x363) exactly,
and matches [IR-60-5] A-113's mnemonic. Operand-word format independently
confirmed against real compiled HALMAT this session.

Behavioral description is a straightforward reading of "matrix subtract"
corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word prose
transcribed yet.
