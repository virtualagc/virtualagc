# MINV

**Mnemonic:** MINV

**Opcode:** 0x3CA

**Confidence:** High

## Behavioral Description

**General matrix exponentiation** (`M**N`), not INVERSE-only despite the
`MINV` mnemonic -- a later session resolved the "second operand" question
below by decoding real compiled HALMAT for `A2B**2`, `A2B**(-1)`, and
`A2B**0` (`029-DATATYPES.hal` from "Programming in HAL/S," p. 29), which
all emit this same opcode with the literal exponent (`2.0`/`-1.0`/`0.0`)
as operand 2. `N=-1` is matrix inverse (the case this file previously
assumed was the opcode's *only* job); `N=0` is the identity matrix; `N>0`
is `N`-fold self-multiplication; other negative `N` (inverse-then-power)
follow by the same integer-exponent rule but aren't independently
confirmed against a real compile. Conceptually still one logical input
matrix plus an exponent, but the two are carried as separate operand
words, not one.

## Usage Context

Emitted for HAL/S expressions using matrix-exponentiation notation
(`M**N`, for any integer `N` including `-1`, the inverse case, and `0`,
the identity case) on a `MATRIX` operand. Confirmed by compiling
`B = A**(-1);` (`A`/`B` both `MATRIX(2,2)`) with `HALSFC
--parms="LSTALL"`, and by `029-DATATYPES.hal`'s `A2B**2`/`A2B**(-1)`/
`A2B**0`/`SNG**(-1)` (`SNG` deliberately singular).

## Operand-Word Format (empirically confirmed)

Two operands: operand 1 = `DATA`=symbol-table index of the input matrix,
`QUAL`=1=SYT; operand 2 = `DATA`=literal-table index of the exponent
`N`, `QUAL`=5=LIT (a `FIXED`-type literal, e.g. `2.000000000000000E+00`
for `A2B**2`). An earlier session's single tested case (`A**(-1)`, `DATA`
=18) mistook this `DATA` field -- the literal table *index* -- for the
operand's actual numeric value, and since 18 didn't look like -1,
concluded the operand's role was some compile-time constant or routine
selector unrelated to the exponent. It's an ordinary `QUAL`=5=`LIT`
operand like any other in this project: `DATA` is which literal-table
slot to read, and that slot holds the real exponent value, exactly as
`029-DATATYPES.hal`'s multi-value trace (`2.0`/`-1.0`/`0.0` across three
separate calls) now confirms directly.

## Unresolved Questions

- Negative exponents other than -1 (e.g. `M**(-2)`, inverse-then-square)
  aren't confirmed against a real compile -- `yaHALMAT2` computes them as
  `(M**(-1))**|N|` by analogy with the confirmed `N=-1`/`N>0` cases and
  MATRIX exponentiation's documented integer-power restriction, but this
  hasn't been checked against real compiled HALMAT.
- Whether a non-integer or non-literal (`QUAL`≠5) exponent is even legal
  HAL/S for a `MATRIX` operand (as opposed to `SCALAR`, where [SEXP](SEXP.md)
  covers the general non-literal case) is unconfirmed; no primary source
  or compile has been checked for this.

## Confirmed Runtime Behavior

Singular-matrix inversion (`N=-1` or any negative `N`, where the
inverse-computing first step encounters a singular matrix): per
[USA003090] Appendix C error 27 ("argument of INVERSE is a singular
matrix"), the standard fixup is the identity matrix, not a runtime abort
-- confirmed via `029-DATATYPES.hal`'s `SNG**(-1)` (`SNG` a deliberately
singular 2x2) and `src/tests/hal/test_errfix_matrix.hal`. Same
disposition as [BFNC](../class-0/BFNC.md)'s `INVERSE` selector (49),
since both spellings route through the same `matrix_invert()` routine
and singular-matrix case -- including consulting [ERON](../class-0/ERON.md)'s
registered `ON ERROR` handler table before applying the fixup, so a `GO
TO` handler registered for error 4:27 redirects execution there instead.

## Source Analysis & Reliability

Opcode (0x3CA) confirmed primary-source: `XMINV BIT(16) INITIAL("03CA")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MINV opcode (0x3CA) exactly.

Behavioral description is a straightforward reading of "matrix invert"
corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word prose
transcribed yet.
