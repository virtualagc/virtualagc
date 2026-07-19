# SASN

**Mnemonic:** SASN

**Opcode:** 0x501

**Confidence:** High

## Behavioral Description

Scalar assign. Assigns the scalar (floating-point) operand specified by
one operand to the scalar variable specified by another, following the
general two-operand assign pattern shared by every type's `xASN` operator
(compare [BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[MASN](../class-3/MASN.md), [VASN](../class-4/VASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a SCALAR
variable — the single most common assignment type in typical HAL/S code.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, typically `QUAL`=3=VAC
(`DATA`=the stream position of the instruction that produced the value
being assigned) when the right-hand side is itself an expression, or
`QUAL`=6=IMD / 5=LIT for a direct literal; operand 2 = **receiver**,
`DATA`=its symbol-table index, `QUAL`=1=SYT. **Order corrected in a
later session**: an earlier reading (from `pass2.rpt`'s `LSTALL` text
report) had this backwards (receiver first, source second) — the same
report print-ordering artifact already found for [READ](../class-0/READ.md)/
[DFOR](../class-0/DFOR.md)/[SCHD](../class-0/SCHD.md) (see
[XXST](../class-0/XXST.md)). A direct `unHALMAT.py` binary read of
`S3 = S1 + S2` (compiled with `HALSFC --parms="LISTING2,LSTALL"`) settles
it unambiguously: the VAC operand referencing the producing `SADD`
instruction comes first, `S3`'s `SYT` operand second.

## Unresolved Questions

- None remaining for the base scalar-assign case, **except**: a SCALAR
  receiver assigned a literal whose *numeric value* is a whole number
  (e.g. `S1 = 4;` **or** `S1 = 1.0;` — the presence/absence of a decimal
  point in the source text turns out not to matter) does **not** produce
  SASN — it produces [IASN](../class-6/IASN.md) (0x601) instead, even
  though the generated machine code correctly stores the value as a
  float (`LFLI`/`STE`). Confirmed across two separate test sessions:
  `S1 = 4;` and `S1 = 1.0;`/`S1 = 2.0;`/(multiple-assignment) `S1, S2 =
  5.0;` all → 0x601, while `S1 = 4.5;` and `S1 = S2;` → 0x501 as
  expected. This means the assign-opcode class is apparently selected by
  whether the literal's *value* is integral, not by the receiver's
  declared type or the literal's written form — presumably PASS1 folds
  whole-valued literals into a shared integer-literal representation
  before the type-specific assign opcode is chosen, and that shared
  representation's own type leaks through as IASN regardless of the
  receiver. See [IASN](../class-6/IASN.md)'s Unresolved Questions for
  the same note from the other side.

## Source Analysis & Reliability

Opcode (0x501) confirmed primary-source: base of the `XSASN`/array
declaration group in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 SASN opcode (0x501) exactly.
Operand-word format independently confirmed against real compiled HALMAT
in an earlier session; operand *order* corrected in a later session via
a direct `unHALMAT.py` binary read (see Operand-Word Format above).

Behavioral description is a straightforward reading of "scalar assign"
corroborated by [MSC-01847] §2.20 (Scalar Operations); no verbatim
operand-word prose transcribed yet.
