# MINV

**Mnemonic:** MINV

**Opcode:** 0x3CA

**Confidence:** High

## Behavioral Description

Matrix invert. Computes the matrix inverse of a single square matrix
operand, producing a matrix result. Conceptually unary (one logical
input matrix), but see Operand-Word Format below -- it carries two
operand words, not one.

## Usage Context

Emitted for HAL/S expressions using matrix-inverse notation (e.g. `M**(-1)`
or the built-in inverse mechanism) on a matrix operand. Confirmed by
compiling `B = A**(-1);` (`A`/`B` both `MATRIX(2,2)`) with
`HALSFC --parms="LSTALL"`.

## Operand-Word Format (empirically observed this session, not fully decoded)

Two operands: operand 1 = `DATA`=symbol-table index of the input matrix,
`QUAL`=1=SYT; operand 2 = `DATA`=18 (in the one compiled example checked),
`QUAL`=5=LIT. The second operand's role is not understood -- the
generated object code loads its `DATA` value via a bare `LA` (load-
address) instruction rather than a literal-table dereference (`LFLI`,
used elsewhere in the same object code for genuine literal values),
suggesting it's a compile-time constant or runtime-routine selector
rather than a numeric input to the inversion itself. `yaHALMAT2` ignores
it and computes the inverse from operand 1 alone, which already matches
hand-derived expected values exactly for the one case tested (a 2x2
matrix) -- but this operand's true meaning, and whether it might matter
for other matrix sizes, is unresolved.

## Unresolved Questions

- The second operand's exact role (see Operand-Word Format above) is
  unresolved.
- Runtime behavior for singular (non-invertible) matrices (error handling
  vs. undefined result) is unconfirmed against a primary source -- USA003090
  Appendix C is understood to document HAL/S's general execution-time-error
  response conventions, but wasn't available to consult directly this
  session. `yaHALMAT2` treats it as a runtime failure (matching SSDV's
  divide-by-zero disposition) rather than guessing at a specific response.

## Source Analysis & Reliability

Opcode (0x3CA) confirmed primary-source: `XMINV BIT(16) INITIAL("03CA")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MINV opcode (0x3CA) exactly.

Behavioral description is a straightforward reading of "matrix invert"
corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word prose
transcribed yet.
