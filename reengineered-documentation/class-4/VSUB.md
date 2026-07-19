# VSUB

**Mnemonic:** VSUB
**Opcode:** 0x483
**Confidence:** High

## Behavioral Description

Vector subtract. Computes the elementwise difference of two vector
operands of matching dimension, producing a vector result.

## Usage Context

Emitted for HAL/S expressions using the `-` operator between two vector
operands. Named explicitly (alongside MSUB/SSUB/ISUB) in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = minuend,
operand 2 = subtrahend. No destination operand — consumed by a following
[VASN](../class-4/VASN.md) via a `VAC`-qualified operand. Confirmed by
compiling `V3 = V1 - V2` with `HALSFC --parms="LSTALL"`; see
`STATUS.md`'s "Empirical Verification" section.

## Unresolved Questions

- None remaining for the base two-vector-operand case.

## Source Analysis & Reliability

Opcode (0x483) confirmed primary-source: part of the `XMSUB(1)` array
(element 1, `XVSUB`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl]
in `STATUS.md`. Matches [MSC-01847]'s HAL-1971 VSUB opcode (0x483)
exactly, and matches [IR-60-5] A-113's mnemonic. Operand-word format
independently confirmed against real compiled HALMAT this session.

Behavioral description is a straightforward reading of "vector subtract"
corroborated by [MSC-01847] §2.19; no verbatim operand-word prose
transcribed yet.
