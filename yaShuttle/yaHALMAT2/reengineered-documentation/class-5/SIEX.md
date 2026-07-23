# SIEX

**Mnemonic:** SIEX

**Opcode:** 0x571

**Confidence:** High

## Behavioral Description

Scalar exponentiation by integer. Raises a scalar operand to a power given
by an integer operand (which may be negative). See [SEXP](SEXP.md) for
the general exponentiation-opcode-selection pattern.

## Usage Context

Emitted for HAL/S expressions using the `**` operator where the exponent
is statically known to be of integer type (sign not statically known —
compare [SPEX](SPEX.md), used when the exponent is additionally known to
be positive).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Confirmed Runtime Behavior

[USA003090] Appendix C error 4 ("exponentiation of zero to a power <=
0"): both reachable `B<=0` cases here (`0**0` and `0**negative`) give a
result of zero — not the ordinary `0**0=1` convention, and critically
not an aborting division-by-zero either, since a negative-exponent SIEX
computes `1/base**|B|` and `base=0` would otherwise divide by zero.
Implemented in a later session; see `STATUS.md`'s Class 0 section.

## Source Analysis & Reliability

Opcode (0x571) confirmed primary-source: `XSIEX BIT(16) INITIAL("0571")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 SIEX opcode (0x571) exactly.

Behavioral description is a straightforward reading of "scalar
exponentiation by integer" corroborated by [MSC-01847] §2.20; no verbatim
operand-word prose transcribed yet.
