# TSUB

**Mnemonic:** TSUB

**Opcode:** 0x01B

**Confidence:** High

## Behavioral Description

Structure (copy) subscript specifier. Implements HAL/S structure-copy
subscripting ([USA003087] §19.6): `TREEα;` (select copy `α`) or
`TREEα TO β;` (select the range of copies `α` through `β`) on a
multi-copy structure data item. Analogous to [DSUB](DSUB.md) (ordinary
array/component subscripting) but specific to structure-copy selection.

## Usage Context

Appears wherever a multi-copy structure (or minor structure node) is
subscripted to select one or a range of its copies — e.g. as the
receiver or source of a [TASN](TASN.md) structure assignment. A
range-select subscript additionally triggers the general array-
processing loop bracket ([ADLP](ADLP.md)/[DLPE](DLPE.md)), since it
produces arrayed (multi-copy) results.

## Operand-Word Format (confirmed empirically)

**Single-copy-select form** (`ZQ3(copy 2)`): two operands — `DATA`=
symbol-table index of the structure, `QUAL`=1=SYT; `DATA`=the literal
copy number, `QUAL`=6=IMD.

**Range-select form** (`ZQ3(copies 2 TO 3)`): three operands — the same
symbol-table operand, followed by two `IMD`-qualified operands for the
range's start and end.

Confirmed by compiling both forms with `HALSFC --parms="LSTALL"`:

```
ZQ3              = ZQ1;       <- single-copy-select receiver
S             2
HALMAT: 01B(2),10,0
          7(1),0,1              <- ZQ3, symbol index 7, QUAL=1=SYT
          2(6),9,0               <- literal 2 (copy number), QUAL=6=IMD

ZQ4 = ZQ3              ;      <- range-select source
S             2 TO 3
HALMAT: 01B(3),10,0
          5(1),0,0              <- ZQ3, symbol index 5, QUAL=1=SYT
          2(6),10,1              <- literal 2 (range start), QUAL=6=IMD
          3(6),10,0              <- literal 3 (range end), QUAL=6=IMD
```

In both cases, TSUB's result is subsequently consumed by an
[EXTN](EXTN.md) instruction (via a `VAC`-qualified reference) that
resolves the final structure pointer used by [TASN](TASN.md)/
[TEQU](TEQU.md)/etc.

## Unresolved Questions

- The exact meaning of the recurring trailing header value (`10`) is not
  decoded.
- Whether an expression (rather than a literal) as the copy-select index
  changes the operand's `QUAL` from `IMD` to `VAC` was not tested — per
  [USA003087] §19.6, `α` in the single-copy form may be a general
  integer expression, but the case tested here used a literal.
- Structure-and-terminal subscripting (combining a structure-copy
  subscript with a terminal's own type/array subscript, per
  [USA003087] §19.6) was not tested — only bare structure-copy selection.

## Source Analysis & Reliability

Opcode (0x01B) confirmed primary-source: `XTSUB BIT(16) INITIAL("01B")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`; noted
there as appearing alongside [DSUB](DSUB.md) in the subscripting
discussion, now confirmed correct. No [MSC-01847] (HAL-1971) analog
identified (HAL 1971 predates the structure facility in its current
form). Statement syntax primary-sourced from [USA003087] §19.6 (PDF pp.
220–224). Full behavioral description and operand-word structure (both
forms) confirmed directly against real compiled HALMAT this session, as
part of a systematic sweep of USA003087 syntax patterns against
previously-untested HALMAT opcodes (direct user suggestion).
