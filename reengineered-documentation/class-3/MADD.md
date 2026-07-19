# MADD

**Mnemonic:** MADD
**Opcode:** 0x362
**Confidence:** High

## Behavioral Description

Matrix add. Computes the elementwise sum of two matrix operands of
matching dimensions, producing a matrix result.

## Usage Context

Emitted for HAL/S expressions using the `+` operator between two matrix
operands. Named explicitly (alongside VADD/SADD/IADD) in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = first addend,
operand 2 = second addend. No destination operand — consumed by a
following [MASN](MASN.md) via a `VAC`-qualified operand. Confirmed by
compiling `M3 = M1 + M2` with `HALSFC --parms="LSTALL"`; see
`STATUS.md`'s "Empirical Verification" section.

## Unresolved Questions

- None remaining for the base two-matrix-operand case.

## Source Analysis & Reliability

Opcode (0x362) confirmed primary-source: part of the `XMADD(1)` array
(element 0) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 MADD opcode (0x362) exactly,
and matches [IR-60-5] A-113's mnemonic. Operand-word format independently
confirmed against real compiled HALMAT this session.

Behavioral description is a straightforward reading of "matrix add"
corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word prose
transcribed yet.
