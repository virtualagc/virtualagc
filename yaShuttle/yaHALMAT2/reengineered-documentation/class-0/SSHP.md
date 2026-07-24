# SSHP

**Mnemonic:** SSHP

**Opcode:** 0x042

**Confidence:** High

## Behavioral Description

Scalar shaping-function marker. Identifies the "scalar-array-result"
list-form case of the general shaping-function bracketing mechanism
([SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md)) — emitted for a
`SCALAR(exp1, exp2, ...)` conversion function invocation in its
multi-argument list form ([USA003087] §21.2; the single-argument simple
form instead compiles through [BTOS](../class-5/BTOS.md)/
[CTOS](../class-5/CTOS.md)/[ITOS](../class-5/ITOS.md), by analogy with
those already-documented simple conversions). Its own operand carries
the resulting array's length.

## Usage Context

Appears once per list-form `SCALAR(...)` shaping-function call,
positioned between the last [SFAR](SFAR.md) and the closing
[SFND](SFND.md). One of a 4-member family sharing the `XMSHP` array
alongside [MSHP](MSHP.md) (matrix), [VSHP](VSHP.md) (vector), and
[ISHP](ISHP.md) (integer) — see those files.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the resulting array's length (a literal integer),
`QUAL`=6=IMD. Confirmed by compiling `SA1 = SCALAR(S1, S2);` (`SA1` an
`ARRAY(2) SCALAR`) with `HALSFC --parms="LSTALL"` — same shape as
[VSHP](VSHP.md)'s confirmed trace, with opcode `042` in place of `041`
and a result length of `2`.

## Unresolved Questions

- The `@SINGLE`/`@DOUBLE` precision-forcing forms ([USA003087] §21.2)
  were not tested — whether they change SSHP's own encoding, or are
  handled entirely by the preceding [SFAR](SFAR.md) arguments' own
  conversion, is unconfirmed.

## Confirmed Runtime Behavior

**A pending SFAR argument may itself be a whole VECTOR/MATRIX, not just
a plain scalar/integer expression — confirmed in a later session** (a
latent gap caught while fixing [MSHP](MSHP.md)'s "not yet implemented"
stub, not user-reported directly for SSHP specifically): [USA003088]
Sec. 6.5.1's general `<arith conversion>` rule ("[t]he data elements in
each `<expression>` are unraveled in their natural sequence") applies to
`SCALAR(...)`'s list form the same as it does to `MATRIX(...)`'s — a
whole-container argument contributes its own elements to the flat
result, not just one. yaHALMAT2's `OP_SSHP` handler previously only
handled plain-scalar `SFAR` arguments (silently wrong for a
whole-container one); it now shares `MSHP`'s `unravel_shaping_argument()`
helper (`interp.c`), correctly unraveling either shape into the
resulting flat array.

## Source Analysis & Reliability

Opcode (0x042) confirmed primary-source: `XMSHP` array element 2 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §21.2 (PDF p. 256ff). Full
behavioral description and operand-word structure confirmed directly
against real compiled HALMAT this session, as part of a systematic
sweep of USA003087 syntax patterns against previously-untested HALMAT
opcodes (direct user suggestion).
