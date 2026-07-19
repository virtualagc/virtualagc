# IADD

**Mnemonic:** IADD
**Opcode:** 0x6CB
**Confidence:** High

## Behavioral Description

Integer add. Computes the arithmetic sum of two integer operands.

## Usage Context

Emitted for HAL/S expressions using the `+` operator between two integer
operands, and for loop-index increments in `DO FOR` constructs. Named
explicitly (alongside MADD/VADD/SADD) in the Optimizer HALMAT inline-
vector/matrix-loop note in [HALMAT.md](../HALMAT.md#optimizer-halmat),
sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = first addend,
operand 2 = second addend. No destination operand — the sum is consumed
by a following [IASN](../class-6/IASN.md) via a `VAC`-qualified operand
referencing this instruction's stream position. Confirmed by compiling
`I3 = I1 + I2` with `HALSFC --parms="LSTALL"`; see `STATUS.md`'s
"Empirical Verification" section.

## Unresolved Questions

- Overflow behavior (trap, wraparound, or undefined) is unconfirmed.

## Source Analysis & Reliability

Opcode (0x6CB) confirmed primary-source: part of the `XSADD(1)` array
(element 1, `XIADD`) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl]
in `STATUS.md`. Matches [MSC-01847]'s HAL-1971 IADD opcode (0x6CB)
exactly, and matches [IR-60-5] A-113's mnemonic. Operand-word format
independently confirmed against real compiled HALMAT this session.

Behavioral description is a straightforward reading of "integer add"
corroborated by [MSC-01847] §2.21; no verbatim operand-word prose
transcribed yet.
