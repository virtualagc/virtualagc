# MSHP

**Mnemonic:** MSHP
**Opcode:** 0x040
**Confidence:** High

## Behavioral Description

Matrix shaping-function marker. Identifies the "matrix-result" case of
the general shaping-function bracketing mechanism ([SFST](SFST.md)/
[SFAR](SFAR.md)/[SFND](SFND.md)) — emitted for a `MATRIX(vec1, vec2,
...)` conversion function invocation, one of the `XMSHP` family alongside
[VSHP](VSHP.md) (vector), [SSHP](SSHP.md) (scalar), and [ISHP](ISHP.md)
(integer). Unlike the flat-scalar-list hypothesis previously recorded
here, `MATRIX(...)`'s arguments are themselves full `VECTOR`s, one per
row of the resulting matrix (found via a real worked example in the
compiler's own regression-test corpus, `Source Code/Programming in
HAL-S/044-ORTHONORMAL.hal`: `DETERMINANT = DET(MATRIX(X, Y, Z));` and `V
= MATRIX(A1, A2, A3) V;`, constructing a 3×3 matrix from three
`VECTOR(3)`s and using it directly in a matrix-vector product). No
explicit `n1,n2` dimension subscript on the `MATRIX` keyword is needed or
accepted in this form — the shape is inferred from the argument count
(row count) and each vector's own length (column count).

## Usage Context

Appears once per `MATRIX(...)` shaping-function call, positioned between
the last [SFAR](SFAR.md) (one per row-vector argument) and the closing
[SFND](SFND.md) — confirmed by compiling `M1 = MATRIX(X,Y,Z);` (`X`,
`Y`, `Z` each `VECTOR(3)`, `M1` a `MATRIX(3,3)`) with
`HALSFC --parms="LSTALL"`.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=an encoded length/dimension descriptor (decimal
`771` = hex `0x303` for a 3×3 result — **corrected this session**: an
earlier reading mislabeled this decimal value as hex `0x771`, a
transcription slip, not a real encoding error; exact bit layout still
not decoded, but structurally the same `PSEUDO_LENGTH`-derived field used
by [VSHP](VSHP.md)'s simpler single-dimension case), `QUAL`=6=IMD.
Confirmed trace, cross-checked directly against the compiled binary with
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

- The exact bit layout of the `771`/`0x303` dimension-descriptor operand
  (presumably packing "3 rows × 3 columns" plus possibly a type/flag
  nibble) is not decoded.
- Whether `MATRIX(...)` also accepts a flat scalar-element-list form
  (as originally hypothesized, by analogy with `VECTOR(exp1,exp2,...)`)
  in addition to the row-vector form was not re-tested after finding the
  row-vector form works — the earlier flat-scalar attempts this project
  made failed with `QD1`/`AV2` errors ("dimensions... do not agree" /
  "matrix dimensions disagree across assignment"), which may mean that
  form genuinely isn't supported, or may simply reflect a different,
  unfound argument-count/shape convention.
- Non-square matrices and matrices built from mismatched-length vectors
  were not tested.

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
