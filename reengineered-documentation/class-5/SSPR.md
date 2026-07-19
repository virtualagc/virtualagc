# SSPR

**Mnemonic:** SSPR
**Opcode:** 0x5AD
**Confidence:** High

## Behavioral Description

Scalar-scalar multiply. Computes the arithmetic product of two scalar
operands.

## Usage Context

Emitted for HAL/S expressions using the `*` operator between two scalar
operands.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = first factor,
operand 2 = second factor. No destination operand — the product is
consumed by a following [SASN](SASN.md) via a `VAC`-qualified operand.
Confirmed by compiling `S3 = S1 S2` (juxtaposition — see `STATUS.md`'s
"Empirical Verification" section for why `*` is not used here) with
`HALSFC --parms="LSTALL"`.

## Unresolved Questions

- None remaining for the base two-scalar-operand case.

## Source Analysis & Reliability

Opcode (0x5AD) confirmed primary-source: part of the `XSSPR(1)` array
(element 0), declared alongside `XIIPR` in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 SSPR opcode (0x5AD) exactly. Operand-word format
independently confirmed against real compiled HALMAT this session (see
above).

Behavioral description is a straightforward reading of "scalar-scalar
multiply" corroborated by [MSC-01847] §2.20; no verbatim operand-word
prose transcribed yet.
