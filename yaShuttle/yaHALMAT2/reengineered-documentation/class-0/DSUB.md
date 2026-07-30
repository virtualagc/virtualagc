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

**Empirically confirmed in a later session**: the "component" column
isn't limited to structure-terminal (`CHARACTER`) component access — it
is also exactly what `VECTOR`/`MATRIX` element subscripting uses (`V1(3)`,
`M1(1,2)`, `M1(1,*)`, `V1(2 TO 3)`, `M1(2 AT 1,1)`, etc., all give the
`α`=0/1/2/3 "component" values, never the `α`=4/5/6/7 "array" values —
see Unresolved Questions for the full worked confirmation). The table's
real axis is "subscripting an `ARRAY` dimension" vs. "subscripting
anything else" (structure component *or* `VECTOR`/`MATRIX` element),
not "array vs. component" read literally.

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
**empirically confirmed in a later session**: compiling `S2 = S1(I1,I2);`
for a 2-D `ARRAY(3,4) SCALAR S1` with runtime `INTEGER` subscripts shows
OPT synthesizing the row-major index-flattening arithmetic (a new `IIPR`
computing `I1 × 4`, `IADD`ed with `I2`) and appending its result to `DSUB`
as exactly this operand (`NUMOP` growing 3→4, `α`=5, `β`=1) — while the
original two per-dimension index operands are zeroed but left in place.
See "Optimizer HALMAT" in [HALMAT.md](../HALMAT.md#optimizer-halmat) for
the full trace.

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

**Remaining rows confirmed in a later session** — to-partition,
at-partition, component (`CHARACTER`) subscripting, and the `CSZ`
subsidiary-operand mechanism, closing out every row of the "detailed"
table above:

- **Array to-partition** (`S1(2 TO 5)`, an `ARRAY(10) SCALAR` sliced into
  an `ARRAY(4)` receiver): confirms `α`=6/6, `β`=1/0 exactly:
  ```
  HALMAT: 019(3),5,0
            2(1),0,0             <- op 1: S1, QUAL=1=SYT
            2(6),6,1             <- op 2: literal 2 (range start), QUAL=6=IMD, α=6, β=1
            5(6),6,0             <- op 3: literal 5 (range end), QUAL=6=IMD, α=6, β=0
  ```
- **Array at-partition** (`S1(2 AT 4)`): note the argument order is
  **length AT position** (`2 AT 4"` = 2 elements starting at position 4),
  not "position AT length" — confirmed by the arrayness-mismatch error
  produced by the other reading. Confirms `α`=7/7, `β`=1/0 exactly:
  ```
  HALMAT: 019(3),5,0
            2(1),0,0             <- op 1: S1, QUAL=1=SYT
            2(6),7,1             <- op 2: literal 2 (the length), QUAL=6=IMD, α=7, β=1
            4(6),7,0             <- op 3: literal 4 (the position), QUAL=6=IMD, α=7, β=0
  ```
- **Component (`CHARACTER`) to-partition** (`C1(2 TO 5)`, a substring):
  confirms `α`=2/2 (the *component* column, distinct from the
  array-dimension `α`=6 above), `β`=1/0, and — notably — the operator
  word's own `TAG` (2, not 5) directly signals "component" vs.
  "array-dimension" subscripting:
  ```
  HALMAT: 019(3),2,0            <- TAG=2 (component), vs. TAG=5 for array-dimension cases
            2(1),0,0               <- op 1: C1, QUAL=1=SYT
            2(6),2,1               <- op 2: literal 2 (start), QUAL=6=IMD, α=2, β=1
            5(6),2,0               <- op 3: literal 5 (end), QUAL=6=IMD, α=2, β=0
  ```
- **`CSZ`, case (a) — bare `#`** (`C1(2 TO #)`, "from position 2 to the
  string's actual current length"): the second range operand becomes
  `QUAL`=8=`CSZ` with `DATA`=0 and no subsidiary operand, exactly
  matching the primary-source diagram:
  ```
  HALMAT: 019(3),2,0
            2(1),0,0               <- op 1: C1, QUAL=1=SYT
            2(6),2,1               <- op 2: literal 2 (start), QUAL=6=IMD
            0(8),2,0               <- op 3: DATA=0, QUAL=8=CSZ, α=2 (bare "#")
  ```
- **`CSZ`, case (b) — `# ± expression`** (`C1(2 TO # - 2)`): the `CSZ`
  operand gains a **fourth** operand word immediately after it, holding
  the expression's own value — `NUMOP` grows from 3 to 4 accordingly:
  ```
  HALMAT: 019(4),2,0
            2(1),0,0               <- op 1: C1, QUAL=1=SYT
            2(6),2,1               <- op 2: literal 2 (start), QUAL=6=IMD
            2(8),2,0               <- op 3: DATA=2, QUAL=8=CSZ, α=2 ("# - expression")
            2(6),0,0               <- op 4: literal 2 (the subsidiary expression value), QUAL=6=IMD
  ```
  The primary-source formula ("`tag` = 1 + expression, or 2 − expression")
  is confirmed structurally (a nonzero `DATA` appears on the `CSZ`
  operand precisely when a `±expression` is present, `0` when bare `#`
  alone) but not fully pinned down bit-for-bit — `DATA`=2 was observed
  for `# - 2`; testing `# + n` and a non-literal expression would be
  needed to fully separate the `+`-vs-`−` encoding from the "is this a
  literal" encoding.
- **`ASZ` — genuinely does not appear in DSUB for the case tested**:
  `S1(2 TO #)` for a fixed-size `ARRAY(10)` resolves `#` directly to the
  compile-time-known literal bound (`10`, plain `IMD`), never to an
  `ASZ`-qualified operand — unlike `CHARACTER`'s `CSZ`, `#` for an
  `ARRAY` never needs a *runtime* length lookup, since HAL/S array bounds
  are always compile-time-fixed (arrays have no "current vs. declared
  length" distinction the way `CHARACTER` strings do). Tracing
  `PASS1.PROCS/EMITARRA.xpl`'s `EMIT_ARRAYNESS` procedure shows `XASZ`
  actually used in a **different** context entirely — as an operand
  qualifier in [ADLP](ADLP.md)'s own operand list, for a negative
  `CURRENT_ARRAYNESS(I)` sentinel value (presumably an
  externally/symbolically-sized dimension, e.g. a `COMPOOL` array with an
  `EXTERNAL`-defined bound) — not something DSUB's own subscript operands
  ever carry in the cases tested here.

See also [TSUB](TSUB.md), which appears alongside DSUB in the source
material's subscripting discussion and is a related, simpler
subscript-specifier form — now separately, fully empirically confirmed
(no array-dimension-vs-component distinction, just single-copy-select
and range-select forms).

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

**yaHALMAT2 implementation status**: the asterisk partition kind is
interpreted, not just recognized in the wire format — `V$(*)` (whole
`VECTOR`), `M$(i,*)` (a `MATRIX` row), and `M$(*,j)` (a `MATRIX` column)
all produce a `VECTOR`-shaped `VAC` container result (the same mechanism
`MADD`/`VADD`/etc. already use for their own computed results), consumed
by a following `WRITE` argument ([XXAR](XXAR.md)'s whole-container
handling) or `MASN`/`VASN` the same way. Motivated by `WRITE(6) M$(1,*);`
previously failing outright (no asterisk handling existed at all). The
plain "index" subscript kind (single-element access) was already
implemented and is unaffected.

**Asterisk-partition write-back** (later session, user-reported
`047-ROWS.hal`): all three asterisk-partition cases — `V$(*)`, `M$(i,*)`,
and `M$(*,j)` — can now also be used as an assignment *receiver*
(`M$(I,*) = C * MM$(I,*);`), not just a readable value, by additionally
marking the produced `VAC` result a live, writable view into the base
`MATRIX`/`VECTOR`'s own storage (`is_container_ref`/`container_ref_syt`/
`container_ref_offset`/`container_ref_stride`, `state.h`) that
[MASN](../class-3/MASN.md)/[VASN](../class-4/VASN.md) recognize and
write straight back into. `V$(*)`/`M$(i,*)` are genuinely contiguous in
row-major storage (stride 1); `M$(*,j)` is not (stride = column count) —
generalized to a per-element stride specifically to cover it too, not
left read-only. See [MASN](../class-3/MASN.md)'s own "Confirmed Runtime
Behavior" section for the fuller writable-view mechanism.

**Full-wildcard `M$(*,*)` (both `MATRIX` axes asterisked at once)** is
also implemented, a genuinely 2-D result distinct from the three
single-axis asterisk-partition cases above (task DB id 56,
`wildcard_subscript_matrix_write_loses_row_forcing`). The shared tail
that builds the result shape for every asterisk-select case
(`store_container_result`, `interp.c`) previously hardcoded `rows=0` for
all of them — correct for the three genuinely `VECTOR`-shaped results
(`V$(*)`/`M$(i,*)`/`M$(*,j)`) but wrong for `M$(*,*)`, which needs its
own row count preserved. Fixing this also surfaced a real, confirmed-
both-ways distinction in `WRITE`'s own row-per-line forced-newline
layout (the `MMWSNP.asm` RTL mechanism, `mmwsnp_vector_forces_newline`
finding): `M$(*,*)` on a **plain declared `MATRIX` variable**
(a `SYT` base) gets that row-forced layout, matching bareword
`WRITE(6) X;` — but the identical `$(*,*)` wildcard on a `MATRIX`
**structure-field terminal** (an `XPT` base, e.g. a structure's own
`CC$(1;*,*)` field) does **not** get row-forcing and stays flat, even
though both compile through the same `DSUB` asterisk shape. The fix
gates the row-forced shape on `base_syt < HALMAT_SYT_MAX` (plain `SYT`
vs. `XPT`-resolved structure field) to match this real hardware
distinction.

**Component at-partition** (`V1(2 AT 1)`, a `VECTOR`/`ARRAY` slice) is
also now interpreted, not just confirmed in the wire format — produces a
`VECTOR`-shaped `VAC` container result via the same mechanism as the
asterisk cases above. **Deliberately left read-only**, unlike the
asterisk-partition cases: confirmed via a direct `HALSFC` compile that
real HAL/S rejects `V$(n AT p) = ...;` as an assignment target outright
at compile time (`QD1`/`AV3` errors), regardless of the source's shape —
it type-checks the partition against the *whole* vector's declared
length, not the slice, so no real compiled program can ever reach a
writable form of it; not a gap, a confirmed limit of the language
construct itself. Only the single-dimension `VECTOR`/`ARRAY` case
(`base->rows == 0`) is implemented — a `MATRIX` at-partition
(`M1(2 AT 1,1)`) needs a third operand for the other, plainly-indexed
dimension and isn't handled, so it deliberately falls through to fail
loudly rather than misreading length/position as raw indices.

**Component at-partition and single-index on a plain scalar base**
(Maintenance phase): the `VECTOR`/`ARRAY`-shaped at-partition branch
above originally also (wrongly) matched a plain scalar `BIT` base's own
at-partition subscript (`B$(4 AT I)`, `B` a `BIT(24)`) and single-bit
index (`B$(1)`), since both shapes structurally coincide with the
`VECTOR` case at the operand level — distinguished only by this
instruction's own operator-word `TAG` (`4`=`VECTOR` vs. `1`=`BIT`),
now correctly gated on it. Two new branches read/write a plain
`BIT`/`INTEGER`/`SCALAR` symbol's own raw bit pattern directly (no
container/`ensure_container()` involvement at all, unlike the
`VECTOR`/`ARRAY` case): `B$(width AT position)` (native `BIT`
at-partition) and `B$(n)` (single-bit index, implicit width 1) — both
using the same MSB-first bit-numbering formula
`format_bit_field`/`SUBBIT` already establish elsewhere in `interp.c`.
The single-index form is now also a writable receiver (`B$(1) = ON;`),
via a new deferred `is_bitpart_ref` `VAC`-slot kind (`state.h`) that
re-derives the target's *current* raw value at write time rather than
capturing a stale snapshot — the same "produced by `DSUB`, consumed by
whichever operand position uses it" pattern `is_ref` already
establishes. Similarly, plain (non-`ARRAY`) `CHARACTER` to-partition
(`C$(start TO end)`) and single-index (`C$(n)`) substrings are now
implemented, read directly from the base's own `char_value` string
storage — the `#`-relative `CSZ` bound form is handled the same way for
the to-partition case (see below).

**Component to-partition** (`V1(4 TO 7)`, a `VECTOR`/`ARRAY` slice, and
`C1(a TO b)`, a `CHARACTER` substring) is now interpreted for both
result classes. `VECTOR`/`ARRAY` to-partition (`TAG`=4) produces a
`VECTOR`-shaped `VAC` container result via the same mechanism as the
asterisk/at-partition cases above, and — unlike at-partition — *is*
writable (`V(4 TO 7) = SUBV;`, `SUBV` itself a `VECTOR`): confirmed via
a direct `HALSFC` compile that a plain `SCALAR` RHS on a to-partition
slice is rejected outright at compile time ("`AV1`: TYPE OF V IS
ILLEGAL FOR ASSIGNMENT FROM GIVEN RIGHT-HAND SIDE" — no HALMAT is even
produced), so a genuinely `VECTOR`-shaped source is the only real
trigger, unlike at-partition's own confirmed-always-read-only limit.
Only the single-dimension `VECTOR`/`ARRAY` case (`base->rows == 0`) is
implemented; a `MATRIX` to-partition isn't handled. `CHARACTER`
to-partition (`TAG`=2) reads directly from the base's own `char_value`
string storage, and now also resolves the `#`-relative `CSZ` bound form
(`C(1 TO #-DECIMALS)`) via a shared `resolve_to_partition_bound()`
helper: `DATA`=0 is a bare `#` (the base's own current working length);
`DATA`=2 is `# − subsidiary`, consuming the operand word immediately
following. `DSUB` also gained a narrow `QUAL_LIT`-base case for this
same to-partition shape, needed when the base itself is a compile-time
`CONSTANT` (`ZEROS(1 TO DECIMALS-LENGTH(C))`, `ZEROS` a `CHARACTER
CONSTANT` — a compile-time `CONSTANT` has no `SYT` storage of its own
to look up). `ASZ` remains uninterpreted — see its own note above (never
observed as a `DSUB` subscript operand in any traced case, array bounds
always resolving to a compile-time-known literal instead).

## `yaHALMAT2` Implementation Notes (Maintenance phase)

- **Genuinely 2-dimensional `ARRAY(r,c)` subscripting** (user-reported,
  107-EXAMPLE_3.hal: `DECLARE ARRAY(3,3), M1...;`, subscripted as
  `M1(ROW,COL)`/`M1$(ROW,*)`): `ensure_container()` only ever read
  `array_dims[0]` for *any* `ARRAY` shape (`symtab.c` already parsed
  every dimension correctly — an `interp.c` consumption bug), leaving
  `rows`/`cols` at 0. This silently broke the *plain* 2-index case too
  (a placeholder-stride offset instead of real row-major addressing),
  not just the asterisk-partition `WRITE` that failed loudly. Fixed by
  giving a confirmed-2D `ARRAY` the same `rows`/`cols` treatment
  `MATRIX` gets, so this file's own `MATRIX`-shaped `DSUB` logic
  (`base->rows > 0`) picks it up for free. 3+ dimensional `ARRAY`s still
  fall through to the single-dimension/placeholder-stride path
  unchanged — `MATRIX`'s own 2-index convention has no defined
  generalization beyond 2D. Fixture: `test_array2d.hal`, output
  independently verified against numpy.
- **A `BIT`/`BOOLEAN` (or `CHARACTER`) `ARRAY` subscript wrongly treated
  as a container-producing select** (user-reported, 120-EXAMPLE_A.hal's
  `DATA_VALID$(J:) = FALSE;`, `DATA_VALID` an `ARRAY(4) BOOLEAN`):
  "DSUB: asterisk subscript with 2 indices not yet implemented". This
  subscript compiles through the identical "index + trailing asterisk"
  shape `M$(i,*)` uses (this file's own `α`=4/0 asterisk row), but
  unlike `VECTOR`/`MATRIX` the asterisk here selects no sub-range — a
  `BIT`/`CHARACTER` element has nothing further to select "all of"; it's
  just how the compiler always spells this particular subscript. Fixed
  by treating it as an ordinary single-element writable reference (the
  same generic per-dimension `is_ref` `VAC`-slot mechanism `DSUB`
  already uses for the plain index case), not a container-producing
  partition select. Fixture: `test_bit_array_dsub.hal`.
- **An `INTEGER ARRAY` `WRITE` argument formatted as `SCALAR`**
  (user-reported, 113-EXAMPLE_7.hal's `MISMATCH$(I,*)`, `MISMATCH` a
  confirmed-2D `ARRAY INTEGER`): `container_is_integer` (the `VAC`-slot
  flag that selects the 11-column `INTEGER` field format) was only ever
  set for a plain whole-`SYT` reference, and `resolve_operand()`'s
  per-element container read had no `INTEGER` awareness at all. Fixed
  with a new per-`VAC`-slot `container_is_integer` flag sourced from
  this instruction's own operator-word `TAG` (already documented above
  as "the HALMAT class number of the subscripted result's type" — `6`
  for `INTEGER`). Fixture: `test_mismatch_array.hal`.
- **`VECTOR` at-partition wrongly also matching a scalar `BIT` at-partition
  or single-index subscript** (user-reported, 254-TEST1.hal's `INTEGER
  (INPUT$(4 AT I))`, `INPUT` a plain `BIT(24)`; 254-TEST2.hal's
  `IF B$(1) THEN ...;`, `B` a plain `BIT(16)`): both structurally coincide
  with the `VECTOR`/`ARRAY` at-partition/index shape at the operand
  level, previously read through `base->elements` even though a scalar
  `BIT` symbol has none (`ensure_container()`'s generic "unknown shape"
  fallback silently allocated a bogus placeholder container regardless).
  Fixed by gating the `VECTOR` branch on this instruction's own
  operator-word `TAG`==4, and adding two new branches for `TAG`==1
  (`BIT`) that read/write the base's own raw bit pattern directly, no
  container involved — see "Component at-partition and single-index on a
  plain scalar base" in Usage Context above. Fixtures:
  `test_bit_at_partition.hal`, `test_bit_index.hal`, `test_bit_index_assign.hal`.
- **`CHARACTER` to-partition/single-index substrings on a plain scalar
  base** (user-reported, 159-AGE.hal's `CASE_NUM = INTEGER(C$(1 TO 3));`,
  `C` a plain `CHARACTER(80)`): previously fell through to the generic
  per-dimension index loop, misreading the (start, end) pair as two
  unrelated plain indices into a scalar `CHARACTER` symbol's own
  nonexistent element array. Fixed with two new branches reading
  directly from the base's own `char_value` string storage — see
  "Component to-partition" in Usage Context above, which also covers the
  later `CSZ`-bound and `QUAL_LIT`-base extensions to this same code
  path. Fixtures: `test_char_subscript.hal`, `test_reformat_csz.hal`.
- **`VECTOR` to-partition not usable as an assignment receiver**
  (user-reported, `V(4 TO 7) = SUBV;`, `V` a `VECTOR(10)`, `SUBV` a
  `VECTOR(4)`): "MASN/VASN: receiver must be SYT" — the to-partition
  branch only ever produced a *readable* `VAC` container result; nothing
  marked it `is_container_ref` the way the sibling asterisk-partition
  case (`M$(I,*) = ...;`) already does. Fixed by adding the same
  writable-view marking, scoped to the single-dimension `VECTOR`/`ARRAY`
  case. Fixture: `test_vector_to_partition_write.hal`.

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
  nine predecessor specifier-kinds applies. **Fully resolved across two
  sessions**: every row of the "detailed" table — index (`α`=5/1),
  asterisk (`α`=4/0), array to-partition (`α`=6/6), array at-partition
  (`α`=7/7), component to-partition (`α`=2/2), and the `CSZ` bare-`#` and
  `# ± expression` cases — is now empirically confirmed against real
  compiled HALMAT (see Usage Context). `ASZ` was traced to a different
  instruction ([ADLP](ADLP.md)) entirely rather than confirmed as a DSUB
  operand qualifier — see that row's note below.
- ~~The to-partition/at-partition (2-operand) subscript kinds, component
  (rather than array-dimension) subscripting, and the CSZ/ASZ subsidiary-
  operand mechanism were not tested this session — only single-operand
  array-dimension index/asterisk forms were compiled.~~ **Resolved in a
  later session**: all of these are now confirmed — see Usage Context.
  ~~The one open item is the exact bit encoding distinguishing `+`
  vs. `−` in the `CSZ`/`# ± expression` case.~~ **Fully resolved
  (Maintenance phase, across two follow-up passes)**: `DATA`=0 is a
  bare `#` (no subsidiary); `DATA`=2 is `# − subsidiary`, the subsidiary
  being whatever operand word immediately follows (a plain `SYT`, or a
  computed `VAC` result — need not be a literal). An intermediate pass
  investigating `160-REFORMAT.hal`'s `RETURN RJUST(S||C(1 TO
  #-DECIMALS)||'.'||C(#-DECIMALS-1 TO #), WIDTH);` seemed to find a
  contradiction (`C(#-DECIMALS-1 TO #)`'s own subsidiary, a computed
  `IADD(DECIMALS, 1)`, appeared to disagree with hand-deriving the
  textbook's own separately-quoted worked example, `REFORMAT(SQRT(2),3,
  5)` → `'1.414'`) — this turned out to be a dead end rather than a real
  ambiguity: the corpus file doesn't actually call `REFORMAT` with those
  textbook values at all (it uses three different, unrelated test
  cases), so that reverse-engineering was never checkable against real
  behavior in the first place, and the `DATA`=2 formula reconciles
  algebraically with the corpus file's own compiled expression exactly.
  The `#-DECIMALS-1` formula itself was independently re-verified
  letter-for-letter identical against *both* the 1st (NASA-CR-151872,
  Sept. 1978) and 2nd editions of "Programming in HAL/S", ruling out an
  OCR scanning artifact in either copy as the source of the apparent
  disagreement. `DATA`=1 (a `# + expression` form) remains inferred only
  by symmetry with the primary source's own documented formula ("`tag` =
  1 + expression, or 2 − expression") — never independently observed in
  any real or synthetic trace. DSUB opcode dispatch for the to-partition
  subscript kind, including `CSZ`, is now implemented in `yaHALMAT2` —
  see `interp.c`'s `resolve_to_partition_bound()` and the CHARACTER/
  VECTOR to-partition branches of `OP_DSUB`, and the Implementation
  Notes below. All three of `160-REFORMAT.hal`'s own real `WRITE(6)
  REFORMAT(...)` calls now produce output independently verified
  digit-by-digit by hand.
- ~~The "detailed" table's array/component split may not be the whole
  picture — `α` for at least the "index" kind may also depend on the
  container type (`ARRAY` vs `MATRIX`/`VECTOR`).~~ **Resolved in a full
  sweep**: `VECTOR`/`MATRIX` subscripting doesn't need a third `α`
  column at all — it simply **reuses the primary source's existing
  "component" column** (`α`=0/1/2/3 for asterisk/index/to-partition/
  at-partition), the same column previously confirmed only for
  `CHARACTER` structure-terminal subscripting. Confirmed for every kind,
  on both `VECTOR(3)` and `MATRIX(3,3)`:
  - **Asterisk** (`V1(*)`, whole-vector select; `M1(1,*)`, row select):
    `α`=0 in both cases (matches the component column's `*` row exactly).
  - **Index** (`V1(3)`/`V1(I1)`; `M1(1,2)`/`M1(I1,I2)`): `α`=1 in every
    case, literal or variable (this is the row that first surfaced the
    discrepancy — see Halmat.pdf's own `MATRIX(3,3)` examples, which
    independently show the same `α`=1).
  - **To-partition** (`V1(2 TO 3)`; `M1(1 TO 2,1)`, partial-column
    select): `α`=2/2 in both cases.
  - **At-partition** (`V1(2 AT 2)`; `M1(2 AT 1,1)`): `α`=3/3 in both
    cases.
  So the real distinction the primary source's table draws is not
  "array vs. component" but "`ARRAY`-dimension subscripting" (`α`=4–7)
  vs. "everything else" (`α`=0–3) — structure-terminal component access
  and `VECTOR`/`MATRIX` element access both fall in the latter bucket
  and share its numbering exactly. `DSUB`'s own operator-word `TAG` was
  also confirmed in the same sweep to simply be **the HALMAT class
  number of the subscripted *result*'s type** (`5`=`SCALAR` for every
  single-element access tested earlier; `4`=`VECTOR` for `V1(*)` and
  `M1(1,*)`, which don't reduce dimensionality) — not a
  subscript-kind-specific tag as earlier phrasing implied.
- **`yaHALMAT2` implementation gap, now fixed**: an `ARRAY(n) VECTOR(m)`-
  declared variable (an *array of vectors*, distinct from a
  `MATRIX(n,m)`) compiles `V(i)` (select the whole `i`-th vector) to the
  identical "one plain index + one asterisk" two-operand `DSUB` shape as
  `M(i,*)` (row select) — but `yaHALMAT2`'s own container model
  (`halmat_syt_entry_t`'s `elements`/`rows`/`cols`, `state.h`) had no way
  to distinguish the two cases: both ended up `rows==cols==0` via
  `ensure_container()`, since only a true `MATRIX` symbol got real shape
  metadata from the symbol table. User-reported real-corpus trigger,
  117-EXAMPLE_8.hal (`POSITIONS ARRAY(5) VECTOR`, indexed
  `POSITIONS$(I:*)`): "DSUB: asterisk subscript with 2 indices not yet
  implemented". Root cause: `symtab.c` discarded a `VECTOR`/`MATRIX`
  symbol's own `SYM_LENGTH`-encoded element shape whenever `SYM_ARRAY`
  also made it `ARRAY`-shaped. Fixed by decoding `SYM_LENGTH` into the
  `ARRAY` branch too, and giving `ensure_container()` a new
  `array_of_vector`-flagged `rows`/`cols` treatment (the same convention
  as the 2D-`ARRAY`-of-`SCALAR` fix two bullets below) so `DSUB`'s
  existing `MATRIX`-shaped logic ("`base->rows > 0`") picks it up for
  free. A companion bug surfaced verifying the file's own whole-array
  vector arithmetic (`[VELOCITY]=([POSITIONS]-[OLD_POSN])/DELTA_T;`,
  ADLP/DLPE-replayed): `resolve_container()` always returned an
  `ARRAY`-of-`VECTOR` operand's *whole* flat container regardless of the
  replay's own `arrayed_index`, correct only when both operands happened
  to be same-shaped; fixed by slicing to one `VECTOR` per
  `arrayed_index` (both `resolve_container`'s read side and `VASN`'s own
  hand-rolled write side). `ARRAY(*)` assumed-size `VECTOR` parameters
  (`141-VSUM.hal`'s `VSUM: FUNCTION(V) VECTOR; DECLARE V ARRAY(*)
  VECTOR;`) are now also fixed (Maintenance phase): the root cause was
  two compounding bugs unrelated to this container-shape one — `symtab.c`'s
  own `EXT_ARRAY` dimension-bound parsing never sign-extended from the
  field's real 16-bit width (an assumed-size parameter's own bound is
  encoded as a *negative* 16-bit sentinel, confirmed against two
  different real files' own differing magnitudes — 0xFFF9=-7 and
  0xFFFC=-4 — ruling out one fixed constant), and `ensure_container()`
  had no way to represent "this parameter's real size isn't known until
  a call actually supplies one." Fixed by correctly sign-extending the
  bound, leaving an assumed-size `ARRAY` parameter unallocated until a
  real call supplies its shape, and having `bind_call_argument()`
  allocate directly from the caller's own actual argument shape.
  Uncovered a second, independent bug in the same investigation: `LFNC`'s
  `SIZE` selector returned an `array_of_vector`-shaped argument's *flat
  scalar* count rather than the `VECTOR` count USA003087 Appendix B's own
  SIZE FUNCTION table specifies — see [LFNC](LFNC.md). `ARRAY`-of-`MATRIX`
  parameters remain unhandled (no real corpus trigger found). The
  whole-`VECTOR`/`MATRIX` `RETURN` half of the "ARRAY-of-VECTOR/MATRIX"
  architecture this bullet used to describe as jointly deferred is now
  also fixed, see
  [RTRN](RTRN.md). Fixture: `test_array_of_vector.hal`.

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

**Remaining rows confirmed in a later session**: the to-partition,
at-partition, component (`CHARACTER`) subscripting, and `CSZ`
subsidiary-operand rows were all directly confirmed via `unHALMAT.py`
against real compiled HALMAT, closing out every row of the primary
source's "detailed" table. `ASZ` was not found in DSUB's own operand
list for the array case tested (`#` resolves directly to a compile-time
literal for arrays); source tracing via `EMITARRA.xpl` located `XASZ`
use instead in [ADLP](ADLP.md)'s operand list, for a negative
`CURRENT_ARRAYNESS(I)` sentinel — a different instruction and context
than DSUB's own subscript operands. This makes DSUB one of the most
thoroughly empirically-confirmed Class 0 instructions in this corpus.
See Usage Context above for the full traces.
