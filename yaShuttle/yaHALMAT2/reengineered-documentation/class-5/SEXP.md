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

## Confirmed Runtime Behavior

Two of [USA003090] Appendix C's group-4 "standard fixups" apply here
(implemented in a later session; see `STATUS.md`'s Class 0 section for
the fuller citation):

- Error 24 ("negative base in exponentiation," `A**B` where `A<0`):
  result is `|A|**B` — applied unconditionally whenever the base is
  negative, not just for the fractional-exponent cases where `pow()`'s
  underlying log/exp implementation would otherwise return `NaN`.
- Error 4 ("exponentiation of zero to a power <= 0," `A**B` where `A=0`
  and `B<=0`): result is zero — not the ordinary `0**0=1` convention
  `pow()` follows, and critically not `pow(0, negative)`'s C99 `+Inf`
  result either, which would otherwise feed a non-finite value into
  `halmat_scalar_from_double`'s normalization loop and hang.

Both consult [ERON](../class-0/ERON.md)'s registered `ON ERROR` handler
table before applying the fixup (follow-up session) — a `GO TO` handler
registered for the matching error redirects execution there instead.

## Source Analysis & Reliability

Opcode (0x5AF) confirmed primary-source: `XSEXP BIT(16) INITIAL("05AF")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 SEXP opcode (0x5AF) exactly.

Behavioral description is a straightforward reading of "scalar
exponentiation-by-scalar" corroborated by [MSC-01847] §2.20; no verbatim
operand-word prose transcribed yet.
