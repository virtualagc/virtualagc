# WRIT

**Mnemonic:** WRIT

**Opcode:** 0x021

**Confidence:** High

## Behavioral Description

Write header. Marks the point, inside a `WRITE` statement's HALMAT
construct, where the actual write operation is performed, **and carries
the statement's logical device number as its own operand** — same
`NUMOP`=1, single-`IMD`-operand pattern as [READ](READ.md)/[RDAL](RDAL.md).

## Usage Context

**Corrected this session** (superseding an earlier, incorrect correction
from a previous session): the device number for a `WRITE` statement is
**not** on the preceding [XXST](XXST.md) instruction — it's WRIT's own
operand. The earlier claim came from a misreading of `pass2.rpt`'s text
report (which visually prints an operand under the wrong instruction);
cross-checking with a direct `unHALMAT.py` binary read of `WRITE(6) S1;`
(compiled alongside `READ(5) I1;` in the same test program, with
`HALSFC --parms="LISTING2,LSTALL"`) resolved it:

```
HALMAT #23 (0x025, XXST)   op: DATA=2 (WRITE), QUAL=6=IMD     <- XXST's only operand: the kind code
HALMAT #25 (0x027, XXAR)   op: S1, symbol index 3, QUAL=1=SYT
HALMAT #27 (0x021, WRIT)   op: DATA=6, QUAL=6=IMD             <- WRIT's own operand: the device number
HALMAT #29 (0x026, XXND)
```

See [XXST](XXST.md) for the full account of how the original
misattribution happened and was caught, and [READ](READ.md) for the
identical pattern on the read side. WRIT sits between the argument's
[XXAR](XXAR.md) entries and the closing [XXND](XXND.md), same as READ.

**Multi-valued argument data-field layout** (yaHALMAT2 implementation,
this session): a whole `VECTOR`/`MATRIX` argument, or a `MATRIX` row/
column partition select ([XXAR](XXAR.md)'s whole-container handling,
[DSUB](DSUB.md)'s asterisk-subscript result), is expanded into one
data field per element rather than written as a single value, per
USA003087 Sec. 12.2's "DATA FORMATS": a `VECTOR`/`ARRAY` argument lays
its elements out sequentially; a `MATRIX` argument lays its elements
out row by row, with the second and subsequent rows forced onto a new
line, aligned under the first row's own starting column, regardless of
whether the line has room for more. Every WRITE data field, across the
whole statement's argument list (not per-argument), also now wraps onto
a new line once it would exceed the interpreter's line-length limit
(default 80 columns, matching that section's "unpaged output: [80
columns/line]" — overridable with `--line-length`, main.c). Previously,
a whole `VECTOR`/`MATRIX`/plain-`ARRAY`-shaped argument failed outright
("... referenced outside an arrayed-paragraph replay") rather than
producing any output at all, and no line-wrapping existed regardless of
line length.

## Unresolved Questions

- None remaining specific to this instruction. The device-number
  operand and the I/O-control-specifier mechanism (`TAB`/`COLUMN`/
  `SKIP`/`LINE`/`PAGE`, ordinary [XXAR](XXAR.md) entries distinguished
  by a field on that instruction — confirmed by compiling
  `WRITE(6) TAB(2), S1;` and the COLUMN/SKIP/LINE/PAGE equivalents) are
  both resolved; see [XXAR](XXAR.md)'s Usage Context.

## Source Analysis & Reliability

Opcode (0x021) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for WRIT's own HAL/S description (target p. 63) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-13, describing the
identically-named predecessor-language instruction (HAL 1971 opcode 0x02B,
differing from HAL/S's 0x021) — which also carries the device number on
its own operand, consistent with HAL/S's behavior confirmed here. See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general
basis of this cross-language inference. Operand-word structure directly
confirmed against real compiled HALMAT this session via both `pass2.rpt`
(position-tag-verified) and an independent `unHALMAT.py` binary read —
see [XXST](XXST.md) for the full account of the earlier misreading.
