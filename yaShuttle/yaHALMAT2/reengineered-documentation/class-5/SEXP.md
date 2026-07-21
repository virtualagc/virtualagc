# SEXP

**Mnemonic:** SEXP

**Opcode:** 0x5AF

**Confidence:** High

## Behavioral Description

Scalar exponentiation-by-scalar. Raises a scalar operand to a power given
by another scalar operand (both floating-point). Compare
[SIEX](SIEX.md) (exponent is an integer) and [SPEX](SPEX.md) (exponent is
a positive integer) — HAL/S appears to select among these three
exponentiation opcodes based on the compile-time-known type/sign of the
exponent, presumably for efficiency (integer and positive-integer
exponents can use cheaper algorithms than general scalar exponentiation).

## Usage Context

Emitted for HAL/S expressions using the `**` operator where the exponent's
type is scalar (not statically known to be integer).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x5AF) confirmed primary-source: `XSEXP BIT(16) INITIAL("05AF")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 SEXP opcode (0x5AF) exactly.

Behavioral description is a straightforward reading of "scalar
exponentiation-by-scalar" corroborated by [MSC-01847] §2.20; no verbatim
operand-word prose transcribed yet.
