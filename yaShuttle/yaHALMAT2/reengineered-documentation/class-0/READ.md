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
by a comma and/or at least one blank." [USA003088] Sec. 10.1.1 rule 6
(PDF p. 10-3) gives the more precise mechanism: "a null field is
transmitted whenever a comma or semicolon is detected when data is
expected. This occurs when a comma or semicolon is: preceded by a comma
or semicolon; [or] preceded by one or more blanks following the last
comma or semicolon. ... A null field causes the corresponding variable
element to remain unchanged following transmission." yaHALMAT2's
`OP_READ`/`OP_RDAL` handler (`interp.c`) reads each field with a plain
`fscanf("%lf"/"%ld"/"%s", ...)` — those conversions skip leading
whitespace on their own, but not a leading comma, so any comma-
involving input (`"1,2,3"`, `"1, 2, 3"`, etc. — anything other than
pure blank-separated) failed outright with "end of input or malformed
SCALAR/INTEGER" the moment `fscanf` hit the comma. Found via a user
report against `037-ROOTS.hal`'s `READ(5) A, B, C;`. Fixed with a
`read_skip_separator()` helper implementing rule 6's null-field
mechanism directly, called before *every* field of the list (see its
own comment for the two distinct call shapes this needs — a doubled
mid-list comma like `"1,,3"` and a *leading* comma before the very
first field like `",2,3"` both null the field they precede, but a naive
single-shape implementation that just consumed one comma unconditionally
before every item shifted the whole remaining list over by one instead
of nulling only the first item — caught before the fix was considered
done). See `STATUS.md`'s Class 0 section for the fuller trace;
`src/tests/hal/test_read_comma.hal` (mid-list) and
`test_read_leading_comma.hal` (leading) are the regression fixtures.

**Semicolon list-terminator, fixed in a follow-up session.** Distinct
from (and a stronger effect than) a comma's null-field behavior above:
[USA003088] Sec. 10.1.1 rule 5 (PDF p. 10-3) — "a semicolon field
separator encountered during a normal sequential scan to fill a
variable element terminates the READ statement...[t]he current
`<variable>` element is left unchanged; [a]ll remaining `<variable>`s in
the statement are unchanged." Independently confirmed by ["Programming
in HAL/S"] Sec. 8.3 (p. 153, user-supplied, not previously extracted —
a non-primary but influential textbook, "generally the first HAL/S
material encountered by students"), whose own worked example is this
project's regression fixture almost verbatim: `READ(5) A,B,C;` fed
`"1.5, 2.6;"` reads only `A`/`B`, leaving `C` untouched — "This fact can
be useful when a program must process a variable number of input
values," illustrated there with an `ARRAY`-sum idiom that reads a
semicolon-terminated list into an array, leaving its unfilled tail at
initial value. Previously a hard parse error in yaHALMAT2 (`fscanf`
choking on `;` as invalid numeric/token data) — user-reported.
Implemented by widening `read_skip_separator()`'s return from a bool
into `halmat_read_field_t` (`DATA`/`NULL`/`TERMINATE`); getting this
right took two passes — the first attempt's "no comma found, must be
space-only separation" early-return path skipped the semicolon check
entirely, so a comma-then-semicolon input (`"1.5, 2.6;"`, the exact
regression fixture) still failed even though a *bare* leading semicolon
alone already worked, caught by testing the primary source's own
worked example directly rather than a simplified toy case.
`src/tests/hal/test_read_semicolon.hal` is the regression fixture.

**Missing default line-advance between statements, fixed in a follow-up
session.** User-reported against `037-ROOTS.hal`'s real `DO WHILE TRUE`
input loop: feeding a semicolon-terminated list (e.g. `"1,2;"`) to one
iteration's `READ(5) A, B, C;` correctly left `C` unchanged per the
semicolon fix above, but every *subsequent* iteration's `READ` then
silently reused the same stale `A`/`B`/`C` forever, never blocking for
more user input — an infinite loop with no visible read failure.
Root cause: `read_skip_separator()` deliberately leaves a terminating
semicolon unconsumed in the stream (needed so a later statement, not
itself, can decide what to do with it — see that function's own
comment), but nothing was ever discarding it before the next `READ`
began; that next `READ`'s first field scan saw the leftover semicolon
immediately and terminated instantly, without reading any of the new
line the user had just typed. [USA003087] Sec. 12.3 (PDF p. 12-7) gives
the exact rule that was missing: "If the READ statement is the first to
be executed for the specified device, the device mechanism positions
itself at column 1 of line 1. Otherwise, the device mechanism moves down
one line from its current position and repositions itself at column 1."
["Programming in HAL/S"] Sec. 8.3 (p. 154) independently states the same
default as "a `SKIP(1), COLUMN(1)` operation is implied at the beginning
of each READ statement," overridable by an explicit `SKIP(0)`/`TAB(0)`
to read data positioned after a semicolon that terminated the previous
READ — not reachable in yaHALMAT2 today since I/O control specifiers
(`TAB`/`COLUMN`/`SKIP`/`LINE`/`PAGE`) aren't implemented (`OP_READ` fails
loudly if one appears), making the default line-advance unconditional
for every `READ`/`READALL` but a device's first. Fixed with a
`discard_to_eol()` helper (`interp.c`), called at the start of
`OP_READ`/`OP_RDAL` whenever `state->device_read_started[device]` is
already true (a new per-device flag, `state.h`, false until a device's
first READ/READALL) — discards whatever the previous statement left
unconsumed on the current line (the leftover semicolon, or any
un-listed trailing values) before the new statement's own field scan
begins. `src/tests/hal/test_read_semicolon_loop.hal` (two loop
iterations, the second semicolon-terminated) is the regression fixture;
confirmed additionally against a real `037-ROOTS.hal` run reproducing
the user's exact reported sequence.

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
