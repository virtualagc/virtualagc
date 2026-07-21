# SSDV

**Mnemonic:** SSDV

**Opcode:** 0x5AE

**Confidence:** High

## Behavioral Description

Scalar divide. Computes the arithmetic quotient of two scalar operands.

## Usage Context

Emitted for HAL/S expressions using the `/` operator between two scalar
operands.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = dividend,
operand 2 = divisor. No destination operand — the quotient is consumed by
a following [SASN](SASN.md) via a `VAC`-qualified operand. Confirmed by
compiling `S3 = S1 / S2` with `HALSFC --parms="LSTALL"`; see
`STATUS.md`'s "Empirical Verification" section.

## Unresolved Questions

- Division-by-zero handling (trap vs. defined result) is unconfirmed.

## Source Analysis & Reliability

Opcode (0x5AE) confirmed primary-source: `XSSDV`, part of the same
declaration group as `XMSDV`/`XVSDV`, in `PASS1.PROCS/##DRIVER.xpl` — see
[##DRIVER.xpl] in `STATUS.md`. Matches [MSC-01847]'s HAL-1971 SSDV opcode
(0x5AE) exactly. Operand-word format independently confirmed against real
compiled HALMAT this session (see above).

Behavioral description is a straightforward reading of "scalar divide"
corroborated by [MSC-01847] §2.20; no verbatim operand-word prose
transcribed yet.
