# ISUB

**Mnemonic:** ISUB

**Opcode:** 0x6CC

**Confidence:** High

## Behavioral Description

Integer subtract. Computes the arithmetic difference of two integer
operands.

## Usage Context

Emitted for HAL/S expressions using the `-` operator between two integer
operands. Named explicitly (alongside MSUB/VSUB/SSUB) in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = minuend,
operand 2 = subtrahend. No destination operand — the result is consumed
by a following [IASN](../class-6/IASN.md) via a `VAC`-qualified operand.
Confirmed by compiling `I3 = I1 - I2` with `HALSFC --parms="LSTALL"`; see
`STATUS.md`'s "Empirical Verification" section.

## Unresolved Questions

- Overflow/underflow behavior is unconfirmed.

## Source Analysis & Reliability

Opcode (0x6CC) confirmed primary-source: part of the `XSSUB(1)` array
(element 1, `XISUB`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl]
in `STATUS.md`. Matches [MSC-01847]'s HAL-1971 ISUB opcode (0x6CC)
exactly, and matches [IR-60-5] A-113's mnemonic. Operand-word format
independently confirmed against real compiled HALMAT this session.

Behavioral description is a straightforward reading of "integer subtract"
corroborated by [MSC-01847] §2.21; no verbatim operand-word prose
transcribed yet.
