# DSUB

**Mnemonic:** DSUB
**Opcode:** 0x019
**Confidence:** High

## Behavioral Description

Regular subscript specifier. DSUB carries both array and component
subscripting information for a data reference, following a variable
(reference) operand with a list of one to five subscript-specification
operand groups.

```
 31         24 23         16 15      12 11         4  3    1 0
+------------+------------+---------+------------+------+---+
|    TYPE    |     n      |   019   |     0      |  0   | 0 |
+------------+------------+---------+------------+------+---+
```

- **TAG (TYPE)** — the result type of the data item, after any modification
  by component subscripts.
- **NUMOP (n)** — number of following operand words; n ≥ 2.
- **OPCODE** — 0x019.

First operand word:

```
 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
|     reference    |(unused) |  ESV   |  δ   | 1 |
+-----------------+---------+--------+------+---+
```

- **DATA (reference)** — a direct or indirect reference to the data item
  being subscripted.
- **QUAL (ESV)** — either SYT or XPT.
- **TAG2 (δ)** — 1 if this reference occurs in an assignment ("assign")
  context.

Following the reference operand are between one and five subscript-group
operand words (one per subscripting operation, left-to-right in the
subscript list), each shaped:

```
 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
|      operand     |    α    |  qual  |  β   | 1 |
+-----------------+---------+--------+------+---+
```

The meaning of `α`, `qual`, and `β` (TAG1/QUAL/TAG2 in this document's
general field naming) depends on the kind of subscript:

| Kind of subscript | # operands | α | β | qual |
|---|---|---|---|---|
| `*` (asterisk) | 1 | 8 | — | AST |
| index | 1 | 9 | — | EEV |
| to-partition `[① to ②]` | 2 | A / A | 1 / 0 | IMD / IMD |
| at-partition `[① AT ②]` | 2 | B / B | 1 / 0 | IMD / EEV |

A second, more detailed table (also primary-sourced, [IR-60-5] p. A-94)
gives separate α values depending on whether the subscript applies to the
array dimension or to a component, and separate qual values depending on
whether the component is character type or another type:

| Kind of subscript | # operands | α (array) | α (component) | β | qual (array) | qual (char. component) | qual (other component) |
|---|---|---|---|---|---|---|---|
| `*` | 1 | 4 | 0 | — | AST | AST | AST |
| index | 1 | 5 | 1 | — | EEV, ASZ | EEV, CSZ | EEV |
| to-partition | 2 | 6 / 6 | 2 / 2 | 1 / 0 | IMD | EEV, CSZ / EEV, CSZ | IMD |
| at-partition | 2 | 7 / 7 | 3 / 3 | 1 / 0 | IMD / EEV, ASZ | EEV | EEV |

If an operand's `qual` is CSZ or ASZ, it may be immediately followed by one
extra subsidiary operand word specifying `# ± expression` (a size given
relative to a compile-time-unknown character-string or array length):

```
 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
|        0        |    α    |CSZ/ASZ |  β   | 1 |     (a) "#" alone
+-----------------+---------+--------+------+---+

 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
|       tag        |    α    |CSZ/ASZ |  β   | 1 |     (b) "# ± expression"
+-----------------+---------+--------+------+---+
 31              16 15       8 7      4 3    1 0
+-----------------+---------+--------+------+---+
|      operand      |(unused) |  EEV  |(unused)| 1 |    extra subsidiary operand
+-----------------+---------+--------+------+---+
```

For case (b), `tag` = 1 + expression, or 2 − expression, and the extra
subsidiary operand's DATA gives the expression reference.

## Usage Context

DSUB is emitted for any data reference that involves array subscripting,
component subscripting, or both. Under Optimizer HALMAT, DSUB may gain a
further final operand (α=5, β=1, a subscript common expression addend) —
see "Optimizer HALMAT" in [HALMAT.md](../HALMAT.md#optimizer-halmat).

**First empirical confirmation this session**, for the plain "index"
subscript kind against a 1-D array: compiling `S2 = S1(3);` (`S1` a
`ARRAY(10) SCALAR`) with `HALSFC --parms="LISTING2,LSTALL"` — note the
subscript had to be written on its own `S`-prefixed continuation line
(`S1              ;` then a following line `S             3`), the same
fixed-column convention already found necessary for subscripted `ERROR`
specifications ([ERON](ERON.md)) and structure-copy subscripts
([TSUB](TSUB.md)); a same-line `S1(3)` form was rejected by this
compiler build. Result, read directly from the binary with
`unHALMAT.py`:

```
HALMAT: 019(2),5,0        <- DSUB, TAG=5
          2(1),0,0           <- op 1: S1, symbol index 2, QUAL=1=SYT (the reference)
          3(6),5,0           <- op 2: literal 3 (the index), QUAL=6=IMD, TAG1=5
```

This **matches** the primary-source "detailed" subscript-kind table
below exactly for `α` (`5`, the array-dimension "index" row) — but at
first looked like it **diverged** on `qual`: the table lists `EEV` (any
of SYT/LIT/VAC) for this case, while the compiled *literal* subscript
here is `IMD`-qualified. Two follow-up compiles resolved this instead of
leaving it as a discrepancy:

- **Variable index** (`S1(I1)`, `I1` an `INTEGER`): same `α`=5, but
  `qual`=`SYT` this time — squarely inside `EEV` as the table predicts:
  ```
  HALMAT: 019(2),5,0
            2(1),0,0           <- op 1: S1, QUAL=1=SYT (the reference)
            3(1),5,0           <- op 2: I1, QUAL=1=SYT, TAG1=5 (the index)
  ```
- **Asterisk** (`S1(*)`, both `S1`/the receiver arrayed): `α`=4, `qual`=
  `AST` — again matching the table's asterisk row exactly:
  ```
  HALMAT: 019(2),5,0
            2(1),0,0           <- op 1: S1, QUAL=1=SYT (the reference)
            0(7),4,0           <- op 2: QUAL=7=AST, TAG1=4 (the asterisk)
  ```

So the table is fully confirmed for both the "index" and "asterisk"
rows; `IMD` for a compile-time-constant literal index is simply an
*additional* encoding HAL/S allows beyond the table's `EEV` (itself
already a generic "any of SYT/LIT/VAC" category) — consistent with the
same literal-folding-to-immediate pattern already seen elsewhere in this
project (e.g. [XXST](XXST.md)'s/[READ](READ.md)'s device numbers), not a
correction to the primary source.

See also [TSUB](../STATUS.md) (not yet documented), which appears alongside
DSUB in the source material's subscripting discussion and is presumably a
related, simpler subscript-specifier form.

The predecessor language HAL (1971) achieves the same effect via nine
separate, narrower instructions instead of one unified DSUB: a subscript
*allocator* header (ALC for ordinary references, RALC for assignment
receivers, both terminated by ALCE) followed by one *specifier* per
subscript, drawn from three parallel families depending on what's being
subscripted — terminal (TASB/TIDX/TTSB), array (AASB/AIDX/ATSB), or
structure (SASB/SIDX/STSB) — each family providing an at-subscript, index,
and to-subscript variant. HAL/S's single DSUB instruction, with its
kind-of-subscript table (§ above) distinguishing array vs. component
subscripting and asterisk/index/to/at forms, appears to be a consolidation
of this entire nine-instruction predecessor mechanism into one opcode; see
[MSC-01847] §2.5–2.8 (pp. 2-5–2-9). None of ALC/ALCE/RALC/TASB/TIDX/TTSB/
AASB/AIDX/ATSB/SASB/SIDX/STSB have a corresponding entry in [IR-60-5]'s
Class 0 mnemonic index, consistent with this consolidation (i.e. they were
not simply renamed and kept as separate HAL/S opcodes).

## Unresolved Questions

- The precise distinction between DSUB and TSUB is not yet established;
  TSUB's own description page has not been located. Given the consolidation
  noted above, TSUB may correspond to only one or two of the predecessor's
  nine specifier instructions (a "simpler" subset), while DSUB covers the
  rest — speculative. ([TSUB](TSUB.md) is now separately, fully
  empirically confirmed — see that file — and is structurally simpler:
  no array-dimension-vs-component distinction, just single-copy-select
  and range-select forms.)
- The exact semantics of `α`/`β` are given only as index values into what
  appears to be a lookup/dispatch table in the compiler; their operational
  meaning beyond "selects a subscript-handling code path" is unconfirmed.
  Given the consolidation noted above, `α` plausibly encodes which of the
  nine predecessor specifier-kinds applies. **Partially resolved this
  session**: `α`=5 (index)/`α`=4 (asterisk) both empirically confirmed
  against real compiled HALMAT for the array-dimension case (see Usage
  Context) — the remaining unconfirmed rows are the *component*-subscript
  values and the to-/at-partition forms (2 operands each), none tested
  yet.
- The to-partition/at-partition (2-operand) subscript kinds, component
  (rather than array-dimension) subscripting, and the CSZ/ASZ subsidiary-
  operand mechanism were not tested this session — only single-operand
  array-dimension index/asterisk forms were compiled.

## Source Analysis & Reliability

Primary-sourced from [IR-60-5] pp. A-93–A-94 (operator/operand diagrams,
both subscript-kind tables, and the CSZ/ASZ subsidiary-operand notes). This
is one of the few Class 0 instructions for which the full primary-source
description survives in the available partial copy. The
predecessor-language consolidation note above is drawn from [MSC-01847]
§2.5–2.8, at Medium confidence per the general cross-language caveats in
[STRI](../class-8/STRI.md)'s Source Analysis section.

**First empirical confirmation this session** (previously primary-source
only, never independently compiled): the array-dimension "index" and
"asterisk" subscript-kind rows of the primary-source table were directly
confirmed against real compiled HALMAT via `unHALMAT.py`, including
discovering the array-subscript source syntax requires the same
`S`-prefixed continuation-line convention already established for
[ERON](ERON.md)/[TSUB](TSUB.md) — a same-line `var(subscript)` form was
rejected by this compiler build. See Usage Context above for the traces.
