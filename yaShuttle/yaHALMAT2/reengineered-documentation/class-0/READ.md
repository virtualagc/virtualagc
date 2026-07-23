# READ

**Mnemonic:** READ

**Opcode:** 0x01F

**Confidence:** High

## Behavioral Description

Read header. Marks the point, inside a `READ` statement's HALMAT
construct, where the actual read operation is performed, **and carries
the statement's logical device number as its own operand** — corrected
this session (see Usage Context for how this was previously
misattributed to the preceding [XXST](XXST.md) instruction, and how the
error was caught). `NUMOP`=1: a single `IMD`-qualified operand giving the
device number (e.g. `5` for `READ(5) ...;`).

## Usage Context

**Corrected twice now.** This file originally assumed (by analogy with
the HAL-1971 predecessor) that READ's own operand carries the device
number and an argument count — an earlier session's empirical test then
*appeared* to disprove this, concluding the device number was on
[XXST](XXST.md) instead and that READ carried no operand at all. That
second conclusion was itself wrong: it came from `pass2.rpt`'s `LSTALL`
text report, which prints each operand line directly below the
instruction it visually follows rather than the one it actually belongs
to (only the operand's own `:0.N` stream-position tag reveals the true
owner). Cross-checking the same compiled binary this session with
`unHALMAT.py` (run with `HALSFC --parms="LISTING2,LSTALL"` so
`unHALMAT.py` can embed source/symbol names) removed the ambiguity:
compiling `READ(5) I1;` gives

```
HALMAT #14 (0x025, XXST)   op: DATA=0 (READ), QUAL=6=IMD      <- XXST's only operand: the kind code
HALMAT #16 (0x027, XXAR)   op: I1, symbol index 2, QUAL=1=SYT
HALMAT #18 (0x01F, READ)   op: DATA=5, QUAL=6=IMD             <- READ's own operand: the device number
HALMAT #20 (0x026, XXND)
```

So the actual structure is: [XXST](XXST.md) carries only the
I/O-statement-kind code, one [XXAR](XXAR.md) per argument follows, then
READ itself carries the device number, and the whole construct is closed
by [XXND](XXND.md). Compare [RDAL](RDAL.md) (read-all header) and
[WRIT](WRIT.md) (write header) — structurally identical, sharing the
same XXST/XXAR/.../WRIT-or-READ/XXND bracketing, each also corrected
this session.

This holds even with I/O control specifiers present: compiling
`READ(5) TAB(2), I1;` (and the COLUMN/SKIP/LINE/PAGE equivalents) still
shows exactly one device-number operand on READ itself, with the I/O
control specifier occupying its own [XXAR](XXAR.md) slot ahead of the
transferred variable — see [XXAR](XXAR.md)'s Usage Context for the full
worked traces (its own operand-level content is unaffected by this
correction, only the earlier claim about which instruction the *device
number* sits on).

## Unresolved Questions

- None remaining specific to this instruction; the operand-carrying
  question is now resolved for both the simple and I/O-control-specifier
  cases.

## Confirmed Runtime Behavior

**Data-field separator, fixed in a later session.** [USA003087] Sec.
12.3 (PDF p. 12-7): "Data fields are read from left to right along the
line. The device expects each data field to be separated from the next
by a comma and/or at least one blank." yaHALMAT2's `OP_READ`/`OP_RDAL`
handler (`interp.c`) reads each field with a plain `fscanf("%lf"/"%ld"/
"%s", ...)` — those conversions skip leading whitespace on their own,
but not a leading comma, so any comma-involving input (`"1,2,3"`,
`"1, 2, 3"`, etc. — anything other than pure blank-separated) failed
outright with "end of input or malformed SCALAR/INTEGER" the moment
`fscanf` hit the comma. Found via a user report against
`037-ROOTS.hal`'s `READ(5) A, B, C;`. Fixed with a small
`read_skip_separator()` helper, called before every field except the
first, that consumes optional whitespace, then at most one comma, then
whitespace again. Also implements that same section's "two consecutive
separating commas" rule ("the value of the data item which would have
been changed by reading a data field between the commas, is instead
left untouched"): a second comma immediately following the first (no
value in between) leaves the current item's destination unmodified and
is pushed back for the *next* field's own separator to consume. See
`STATUS.md`'s Class 0 section for the fuller trace;
`src/tests/hal/test_read_comma.hal` is the regression fixture (covers
both the plain-comma case and the double-comma "leave unchanged" rule).

## Source Analysis & Reliability

Opcode (0x01F) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for READ's own HAL/S description (target p. 62) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-13 ("2.12 I/O
SPECIFIERS"), describing the identically-named predecessor-language
instruction (HAL 1971 opcode 0x02A, differing from HAL/S's 0x01F) — which
also carries the device number on its own operand, meaning HAL/S did
**not** diverge from HAL-1971's convention here after all, contrary to
what an intermediate (now-corrected) session concluded. See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general
basis of the HAL-1971 cross-language inference. Operand-word structure
directly confirmed against real compiled HALMAT this session, using both
`pass2.rpt`'s `LSTALL` report (position-tag-verified) and an independent
`unHALMAT.py` binary read — see [XXST](XXST.md) for the full account of
the earlier misreading and how it was caught.
