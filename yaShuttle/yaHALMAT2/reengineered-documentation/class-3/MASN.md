# MASN

**Mnemonic:** MASN

**Opcode:** 0x301

**Confidence:** High

## Behavioral Description

Matrix assign. Assigns the matrix operand specified by one operand to the
matrix variable specified by another, following the general two-operand
assign pattern shared by every type's `xASN` operator (compare
[BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[VASN](../class-4/VASN.md), [SASN](../class-5/SASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a MATRIX
variable. Under Optimizer HALMAT, arrayed MASN operations are expected to
be bracketed by [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md)
arrayness-specifier pairs — MASN is explicitly named in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `QUAL`=3=VAC when the
right-hand side is an expression; operand 2 = **receiver**, ordinarily
`DATA`=its symbol-table index, `QUAL`=1=SYT — but see "Confirmed Runtime
Behavior" below for a second, `QUAL`=3=VAC receiver shape (a `MATRIX`
row/column-partition select or whole `VECTOR`, produced by
[DSUB](../class-0/DSUB.md)'s asterisk-partition handling) that's also
valid. **Order corrected in a later session** via a direct `unHALMAT.py`
binary read of `M3 = M1 + M2` (compiled with `HALSFC
--parms="LISTING2,LSTALL"`) — an earlier reading had receiver first,
source second; same correction applied to
[SASN](../class-5/SASN.md)/[IASN](../class-6/IASN.md)/[VASN](../class-4/VASN.md),
see [SASN](../class-5/SASN.md) for the general account.

## Unresolved Questions

- None remaining for the base matrix-assign case.

## Confirmed Runtime Behavior

**`QUAL`=3=`VAC` receiver — a `MATRIX` row/column-partition select or
whole `VECTOR` used as an assignment target.** User-reported
(`047-ROWS.hal`'s `M    = C MM   ;` / `S     I,*       I,*`
continuation-line form, i.e. `M$(I,*) = C * MM$(I,*);` — scaling one row
of a `MATRIX` by a constant, written directly into that row of a
*different* `MATRIX`): previously rejected outright with "MASN/VASN:
receiver must be SYT", since `OP_MASN`/`OP_VASN` (`interp.c`) only ever
accepted a plain whole-`SYT` destination operand. Fixed by having
[DSUB](../class-0/DSUB.md)'s asterisk-partition cases (`M$(i,*)`,
`M$(*,j)`, `V$(*)`) additionally mark their produced `VAC` result as a
live, writable view into the base `MATRIX`/`VECTOR`'s own element
storage — new `is_container_ref`/`container_ref_syt`/
`container_ref_offset`/`container_ref_stride` fields on the `VAC` slot
(`state.h`), set *in addition to* the existing `is_container` flag the
read direction already relies on, so that path is completely
unaffected. `MASN`/`VASN` now recognize this and write straight back
into the base container's storage instead of failing, via a
stride-aware loop (`container_ref_stride` is 1 for the genuinely-
contiguous row-select/whole-vector cases, the column count for a column
select — row-major storage places successive column entries `cols`
elements apart) rather than a flat `memcpy`, with a bounds check on the
*last* strided index actually touched
(`offset + (count-1)*stride < element_count`). All three asterisk-
partition shapes are covered, including column-select, which was
initially left read-only in a first pass and then generalized to writable
too, once a stride concept existed to express it correctly.

**`ARRAY`-of-`VECTOR` operand slicing** (Maintenance phase, part of the
same fix as [DSUB](../class-0/DSUB.md)'s own ARRAY-of-VECTOR shape-
support gap, user-reported via 117-EXAMPLE_8.hal): `resolve_container()`
— the shared read-side helper `MASN` and every other `xASN` opcode goes
through for a whole-container source operand — previously always
returned an `ARRAY`-of-`VECTOR` `SYT` operand's *whole* flat container
regardless of an active `ADLP`/`DLPE` replay's own `arrayed_index`,
correct only by coincidence when both operands of a same-shaped
whole-array expression happened to line up element-for-element. Fixed
by slicing to one `VECTOR` per `arrayed_index` instead — see
[DSUB](../class-0/DSUB.md)'s Unresolved Questions for the fuller
writeup (the read-side half of that fix; [VASN](../class-4/VASN.md)'s
own hand-rolled write side needed the matching companion fix).

Regression fixtures: `src/tests/hal/test_matrix_row_assign.hal`
(row-scale-by-constant and row-swap-via-temporary-vector, two of the
three idioms `047-ROWS.hal` itself demonstrates — the third,
add-a-scaled-row-to-another-row, is the same mechanism exercised twice
over, in the real program's own second `WRITE`) and
`src/tests/hal/test_matrix_col_assign.hal` (the column-select
generalization); both confirmed to fail on pre-fix code with the exact
"MASN/VASN: receiver must be SYT" error, and the row-select fixture
additionally confirmed against a real `047-ROWS.hal` run (all three of
its own worked examples produce correct matrices).

## Source Analysis & Reliability

Opcode (0x301) confirmed primary-source: `XMASN` (base of the `XXASN`
array) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 MASN opcode (0x301) exactly, and matches
[IR-60-5] A-113's mnemonic (opcode not given there). Operand-word format
independently confirmed against real compiled HALMAT in an earlier
session; operand order corrected in a later session via a direct
`unHALMAT.py` binary read (see Operand-Word Format above).

Behavioral description is a straightforward reading of "matrix assign"
corroborated by [MSC-01847] §2.18/2.19 (Matrix Operations); no verbatim
operand-word prose transcribed yet.
