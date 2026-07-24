# MSHP

**Mnemonic:** MSHP

**Opcode:** 0x040

**Confidence:** High

## Behavioral Description

Matrix shaping-function marker. Identifies the "matrix-result" case of
the general shaping-function bracketing mechanism ([SFST](SFST.md)/
[SFAR](SFAR.md)/[SFND](SFND.md)) — emitted for a `MATRIX(exp1, exp2,
...)` conversion function invocation, one of the `XMSHP` family alongside
[VSHP](VSHP.md) (vector), [SSHP](SSHP.md) (scalar), and [ISHP](ISHP.md)
(integer).

**Corrected in a later session: the row-vector-only model below (and
its "unlike the flat-scalar-list hypothesis" framing) was itself
incomplete, not the final answer.** [USA003087] Sec. 7.5 ("Some Explicit
Conversions," PDF p. 7-19ff, "MATRIX CONVERSION") and [USA003088] Sec.
6.5.1 ("Arithmetic Conversion Functions," the formal grammar/semantic-
rule version) both confirm `MATRIX(...)`'s real, more general rule:
every argument is "unraveled" into a flat sequence of scalar elements —
a plain scalar/integer expression contributes one element, but a whole
`VECTOR`/`MATRIX` expression contributes its own elements in turn
(`MATRIX` "may have arguments of integer, scalar, vector, and matrix
types," [USA003088] Sec. 6.5.1 semantic rule 5) — which is then
"reraveled" into the result shape. So `MATRIX(1,2,3,4,5,6,7,8,9)` (a
flat list of 9 scalar literals) and `MATRIX(X,Y,Z)` (044-ORTHONORMAL.hal's
actual row-vector call site, three whole `VECTOR(3)` arguments) are
*both* valid and produce the identical 3×3 result — confirmed
empirically: the two forms compile to the **identical** MSHP operand
value (decimal 771 = 0x0303), which is only possible if the interpreter
treats them the same way rather than inferring shape from the SFAR
list's own count/shape. This also settles the row/column question left
open below: absent an explicit dimension subscript, [USA003088] Sec.
6.5.1 semantic rule 1 states "MATRIX produces a single 3-by-3 matrix"
by default (matching [VSHP](VSHP.md)'s own analogous "VECTOR produces a
single 3-vector" default) — not something inferred from the argument
list at all.

## Usage Context

Appears once per `MATRIX(...)` shaping-function call, positioned between
the last [SFAR](SFAR.md) (one per row-vector argument) and the closing
[SFND](SFND.md) — confirmed by compiling `M1 = MATRIX(X,Y,Z);` (`X`,
`Y`, `Z` each `VECTOR(3)`, `M1` a `MATRIX(3,3)`) with
`HALSFC --parms="LSTALL"`.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=an encoded dimension descriptor (decimal `771` =
hex `0x303` for a 3×3 result — **corrected this session**: an earlier
reading mislabeled this decimal value as hex `0x771`, a transcription
slip, not a real encoding error), `QUAL`=6=IMD. **Bit layout decoded in
a later session**: high byte = row count, low byte = column count
(`0x03`,`0x03` → 3,3) — the cleanest reading of a value that's obviously
an intentional byte-packed pair, and consistent with
[USA003088] Sec. 6.5.1's documented unsubscripted "3 by 3" default
(Behavioral Description above). Only independently confirmed for this
one default-3×3 data point, though — see Unresolved Questions below for
why a non-default shape couldn't be tested to verify the decode
generalizes. Confirmed trace, cross-checked directly against the compiled binary with
`unHALMAT.py` (`HALSFC --parms="LISTING2,LSTALL"`), which also confirms
the SFAR argument order (X, Y, Z, matching source order) and operand
attribution (each SFAR's own single operand, no misattachment to a
neighboring instruction):

```
HALMAT: 031(0),1,0            <- EDCL
HALMAT: 045(0),1,0            <- SFST
HALMAT: 047(1),1,0            <- SFAR: X (row 1)
          2(1),4,0
HALMAT: 047(1),1,0            <- SFAR: Y (row 2)
          3(1),4,0
HALMAT: 047(1),1,0            <- SFAR: Z (row 3)
          4(1),4,0
HALMAT: 040(1),1,0            <- MSHP
        771(6),0,0               <- encoded dimension descriptor (decimal 771 = 0x303), QUAL=6=IMD
HALMAT: 046(0),1,0            <- SFND
```

## Unresolved Questions

- ~~The exact bit layout of the `771`/`0x303` dimension-descriptor
  operand is not decoded.~~ **Resolved in a later session** — see
  Operand-Word Format above (high-byte=rows/low-byte=cols).
- ~~Whether `MATRIX(...)` also accepts a flat scalar-element-list form
  in addition to the row-vector form.~~ **Resolved in a later session**
  — both forms work (Behavioral Description above); the earlier `QD1`/
  `AV2` compile errors that seemed to rule out the flat form were from
  testing it with the *wrong element count* (fewer than the required 9
  for an unsubscripted default-3×3 result), not because the form itself
  is unsupported.
- The explicit `MATRIXm,n(...)` subscript form's real HAL/S-FC source
  syntax remains unconfirmed. [USA003088] Sec. 6.5.1's own typeset
  grammar figure (Figure 6-19: `INTEGER 2,2 (4#I + J)`, a space then the
  subscript then a space before the parenthesized argument list) was
  tried verbatim against the real compiler in a later session, along
  with the no-space `MATRIX2,3(...)` spelling — both rejected (the
  former: "symbol 2 syntactically illegal"; the latter: "undeclared
  identifier MATRIX2," the lexer merging the keyword and the digit into
  one token). Left unresolved rather than guessed further; the decoded
  operand format above is confirmed only for the unsubscripted
  default-3×3 case as a result.
- Non-square matrices and matrices built from mismatched-length vectors
  were not independently tested via the row-vector form specifically
  (the flat-scalar-list form's own 3×3 default was tested instead) —
  the general unraveling rule ([USA003088] Sec. 6.5.1) implies a
  mismatched total element count would simply be a compile-time error,
  same as the flat form, but this wasn't directly confirmed for
  row-vectors of unequal length.

## Confirmed Runtime Behavior

**Implemented in a later session** (user-asked follow-up to
044-ORTHONORMAL.hal's `READ`/`VECTOR` work, "fix the pre-existing gap
you mentioned"): previously a hard "not yet implemented" stub in
`interp.c`. Fixed with a shared `unravel_shaping_argument()` helper
(also used by [VSHP](VSHP.md)/[SSHP](SSHP.md)/[ISHP](ISHP.md), which had
the identical latent gap — see those files) that unravels each pending
`SFAR` argument (a plain scalar/integer expression, or a whole
`VECTOR`/`MATRIX` via `resolve_container`) into a flat buffer; `OP_MSHP`
decodes the dimension operand (Operand-Word Format above) and reravels
the flat buffer into the row-major 2-D result. Regression fixture:
`src/tests/hal/test_mshp.hal` (both the flat-scalar and row-vector
forms, into the same 3×3 result); confirmed against a real
`044-ORTHONORMAL.hal` run with two different bases, including a
non-trivial/non-identity one, producing correct `DETERMINANT`/basis-
vector/change-of-basis output.

## Source Analysis & Reliability

Opcode (0x040) confirmed primary-source: `XMSHP` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. The underlying
`SFST`/`SFAR`/`MSHP`/`SFND` bracketing mechanism was already established
via [VSHP](VSHP.md)/[SSHP](SSHP.md)/[ISHP](ISHP.md)'s prior confirmation;
what remained was finding correct `MATRIX(...)` call syntax. Resolved not
via the compiler-source-constant-grep technique (which had already found
everything findable — the opcode itself, and the shared bracketing
mechanism) but via a related technique: grepping the compiler's own
*regression-test corpus* (`Source Code/Programming in HAL-S/*.hal`) for
real-world `MATRIX(...)` call sites, which surfaced the row-vector
argument form directly. Full behavioral description and operand-word
structure now confirmed directly against real compiled HALMAT.
