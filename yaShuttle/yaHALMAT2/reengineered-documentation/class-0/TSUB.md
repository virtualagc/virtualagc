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
- The range-select form's runtime semantics (how the resulting arrayed
  copies are actually consumed downstream, and its interaction with
  ADLP/DLPE) were not implemented or tested this session — only the
  single-copy-select form is confirmed working end-to-end.

## Confirmed later: working source syntax and end-to-end runtime behavior

The single-copy-select form's card-column source syntax (a real gotcha,
initially mistaken for `TREE(copy)`-select-*of-the-source*, when it's
actually the *destination*/receiver being subscripted, exactly as this
file's own trace comment already said): given a multi-copy structure
`ZQ3` (`TEMPLATE-STRUCTURE(3)`) and a single-instance `ZQ1`
(`TEMPLATE-STRUCTURE`), `ZQ3 = ZQ1;` with a continuation `S` line whose
non-blank subscript digit(s) align to the column *immediately following*
where the receiver (`ZQ3`, not the source `ZQ1`) ends on the `M` line —
the same "one past the variable's own end column" convention already
established for `DSUB`'s array/matrix element subscripts, just applied
to the assignment's left-hand side instead of a read. E.g. for
`M   ZQ3 = ZQ1;`, `ZQ3` ends at column 7, so the `S` line's copy number
must start at column 8 (`ZQ3` at columns 5–7; column 9 is `=`, and a
subscript landing there — one column too late — trips a "S-LINE
OVERLAPS M-LINE" compile error, since it collides with a real character
still on the M line at that position).

Copy numbers are 1-based in HAL/S source (`copy 2`, `copy 3`, ...) but
this interpreter's own internal copy-index bookkeeping (mirroring
`arrayed_index`'s existing 0-based convention for ADLP/IDLP-driven
array replay) is 0-based — `yaHALMAT2` subtracts 1 from `TSUB`'s literal
copy operand.

**Confirmed: the single-copy-select assignment itself is *not* wrapped
in `ADLP`/`DLPE`** — unlike the whole-copy-count-matching case
(`ZQ4 = ZQ1;` between two same-count multi-copy structures, no `TSUB`
involved, which *is* `ADLP`-wrapped per `STATUS.md`'s finding), a single
specific copy is a scalar (non-arrayed) selection, so `TASN` executes
exactly once. However, **reading back an unsubscripted field of a
multi-copy structure (e.g. `WRITE(6) ZQ3.QI;`) *is* `ADLP`-wrapped**
(one read per copy, broadcasting all copies' values) — confirmed
end-to-end: `ZQ1.QI = 9; ZQ3 = ZQ1; S <copy 2>; WRITE(6) ZQ3.QI;`
(`ZQ3` a 3-copy structure) prints `0  9  0` — copy 2 (1-indexed) holds
the assigned value, copies 1 and 3 remain at their zero default,
confirming both the copy-selection mechanism itself and that distinct
copies of a multi-copy structure are genuinely independent storage
(not aliased to each other).

This end-to-end runtime trace also surfaced a previously-latent,
unrelated interpreter bug (now fixed, not a HALMAT-level finding): a
`WRITE` statement whose argument computation is `ADLP`-wrapped includes
the statement's own `XXST` (I/O-list-open, class-0/XXST.md) *inside*
the replayed paragraph, not just the argument-fetching `XXAR`. Blindly
re-running `XXST`'s original behavior (reset the pending-item list) on
every replay iteration wiped every item but the last one before the
single post-loop `WRIT` ever got to flush them. Fixed by making `XXST`
a no-op when an I/O list is already open (i.e. being re-entered
mid-replay) rather than unconditionally resetting.

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
