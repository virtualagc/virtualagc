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
(default 80 columns, overridable with `--line-length`, main.c —
**correction, a later session**: this default was previously mis-cited
to USA003087 Sec. 12.2's *unpaged* 80-column figure; see "PAGED vs
UNPAGED" below for why that citation doesn't actually apply to this
project's own fixtures, and `src/state.h`'s `line_length` comment for
the fuller correction). Previously,
a whole `VECTOR`/`MATRIX`/plain-`ARRAY`-shaped argument failed outright
("... referenced outside an arrayed-paragraph replay") rather than
producing any output at all, and no line-wrapping existed regardless of
line length.

## No "newline before a multi-valued argument" exception

User-reported discrepancy (044-ORTHONORMAL.hal): `compileLinkRun`/a real
AP-101S emulator inserts a newline before a `VECTOR` `WRITE` argument
(`WRITE(6) 'First basis vector:', A1;` prints the label, a newline,
*then* `A1`'s elements) that `yaHALMAT2` doesn't. Checked thoroughly
against both primary sources — **no such exception exists**. [USA003087]'s
own Figure 12-3 shows a `CHARACTER` literal immediately followed by a
`MATRIX`'s first row on the *same* line, no forced break; ["Programming
in HAL/S"] Sec. 8.1 states directly: "In the absence of the I/O control
functions..., all of the output from a single WRITE statement is placed
on as few lines as possible, with only spaces separating the operands
and the elements of each operand." `yaHALMAT2`'s behavior (pack onto as
few lines as possible) is correct and matches both sources precisely —
confirmed against the real 044-ORTHONORMAL.hal output (the label plus
three SCALAR fields, comfortably under the 80-column wrap point, not a
lucky overflow-avoidance). The `compileLinkRun` newline is most likely a
quirk/limitation of that specific AP-101S emulator tool, not documented
HAL/S behavior.

## PAGED vs UNPAGED, and `--unpaged N`

[USA003090] Sec. 5.2 ("Compiler Directives"): a channel's I/O format
mode (whether `CHARACTER`/`BIT` output gets apostrophe-quoted) is
normally chosen via a compile-time `D DEVICE CHANNEL=n [UN]PAGED`
source directive, falling back to a default if none is given: "[c]hannels
used only in WRITE statements are presumed to be PAGED, while those used
in READ or READALL statements are presumed to be UNPAGED." Every fixture
in this project uses channel 6 write-only with no `DEVICE` directive, so
`PAGED`-by-default applies uniformly — confirming `yaHALMAT2`'s existing
unquoted `CHARACTER` output was already correct (briefly suspected
otherwise while investigating the newline question above, before finding
this rule). `PAGED` output has no quotes around `CHARACTER`/`BIT`
strings; `UNPAGED` does, with embedded apostrophes doubled — both
[USA003087] Appendix F and [USA003090] Sec. 6.1.3 agree, independently
confirmed by ["Programming in HAL/S"] Sec. 8.1's own direct worked
example: `WRITE(6) 'THE ANSWER IS', V;` prints `THE ANSWER IS
7.5836210E+05` on a `PAGED` channel but `'THE ANSWER IS' 7.5836210E+05`
on `UNPAGED`. `PAGED`'s own documented default record length is 133
(Sec. 6.1.4), not the 80 this project actually uses by default — see
`src/state.h`'s `line_length` comment for why that value was
deliberately left as-is despite the citation correction above.

Since this interpreter only ever sees compiled HALMAT (never the
original HAL/S source), it has no way to see a `DEVICE` directive even
if the compiled program had one — added `--unpaged N` (main.c,
repeatable, one device number per invocation, **independent per
device**: a real program can mix `PAGED` and `UNPAGED` channels, e.g. an
`UNPAGED` channel feeding data to a later `READ` alongside a `PAGED` one
for human-readable diagnostics) as the runtime substitute. New
`device_unpaged[HALMAT_DEVICE_MAX]` state field (default false = `PAGED`
everywhere) threaded through every run-mode entry point in `main.c`;
`flush_write` (`interp.c`) applies the apostrophe-quoting rule to
`CHARACTER` fields via `quote_character_for_unpaged()` when the target
device is marked `UNPAGED`. Verified with an explicit two-device test in
one run (device 6 left at the `PAGED` default, device 7 marked
`--unpaged 7`): device 6 stayed unquoted, device 7 got quoted, in the
same execution. `src/tests/hal/test_unpaged.hal` (run twice in
`run_all.sh`, once default and once `--unpaged 6`) is the regression
fixture, matching ["Programming in HAL/S"] Sec. 8.1's own worked example
above almost verbatim.

## WRITE of a raw BIT value

A related, previously-undiscovered gap found while implementing
`--unpaged` above: `WRITE` of a `BIT`-typed expression (not first
converted via a shaping function) silently misformatted as decimal
`INTEGER` instead of [USA003087] Appendix F's documented format — "a
series of binary digits... [l]eading binary zeroes are not suppressed[;]
the field width is equal to the number of binary digits in the string
plus an inserted blank following every fourth digit (to enhance
readability)" (confirmed via ["Programming in HAL/S"] Sec. 8.1's own
`HEX'1234'` → `"0001 0010 0011 0100"` worked example — the blank is a
readability grouping between groups, not a trailing separator), quoted
on `UNPAGED` channels the same way `CHARACTER` is. Root cause:
`resolved_value_t`'s `RV_BITS` carries no declared-width tracking, and
formatting the binary-digit string needs the value's declared `BIT(n)`
width. Per direct user citation (["Programming in HAL/S"] p. 255: "The
value returned by the BIT function is always of the maximum legal
length for bit strings" — 32, per [USA003090] Sec. 8.2 rule 6's
documented range for this compiler): a plain declared `BIT(n)` variable
used directly as a `WRITE` argument now looks up its real declared width
via the symbol table first (reusing [BCAT](../class-1/BCAT.md)'s own
established technique for this identical "no width in
`resolved_value_t`" problem), falling back to 32 only when no declared
width is available (an expression result or a bare literal).
`src/tests/hal/test_bit_write.hal` (both a declared `BIT(8)` and a bare
`HEX'1234'` literal, in both `PAGED`/`UNPAGED` forms) is the regression
fixture. Building it also caught a separate, pre-existing `symtab.c` bug
— see [BCAT](../class-1/BCAT.md)'s own "Confirmed Runtime Behavior" for
that account.

## Whole BIT/CHARACTER ARRAY WRITE and CALL/ASSIGN arguments

User-reported (`120-EXAMPLE_A.hal`): a whole `BIT ARRAY`/`CHARACTER
ARRAY` `WRITE` argument, or the same as a `CALL ... ASSIGN(...)`
argument, failed with "whole BIT/CHARACTER ARRAY WRITE/call arguments
are not yet implemented." [XXAR](XXAR.md) already documented that such
an argument compiles as a single unreplayed entry (`TAG1`=1 for `BIT
ARRAY`, `2` for `CHARACTER ARRAY`) — the same shape already handled for
numeric whole-container arguments — but the runtime side wasn't done
for these two element kinds. Fixed with a new sub-branch (`OP_XXAR`'s
`WRIT`/`CALL` whole-container handling) that uses `ensure_container()`
+ direct `bit_elements`/`char_elements` access, mirroring the existing
numeric path; `flush_write()` gained matching `is_bit_array`/
`is_char_array` VAC-slot branches (`format_bit_field`/plain string
emission, both `UNPAGED`-quoting-aware per the `--unpaged` section
above). The `ASSIGN` side needed a companion fix at [XXND](XXND.md):
whole-array `ASSIGN` parameter write-back was missing from its per-item
write-back loop entirely (added, with a bulk `memcpy`/`dup_string`-loop
copy keyed on the parameter's storage kind). Fixtures:
`src/tests/hal/test_write_bit_array.hal`, `test_assign_array.hal`.

Chasing this surfaced a separate, pre-existing bug in
`precompute_arrayed_paragraphs()` (`interp.c`) — the function that
determines an [ADLP](ADLP.md)/[IDLP](IDLP.md)/[DLPE](DLPE.md)-bracketed
"paragraph"'s replay range. The original rule (always the whole
enclosing statement, back to the last `SMRK`) broke
`WRITE(6) AVERAGE, FLAGS;` (a plain scalar followed by a `BIT ARRAY`,
`AVERAGE` incorrectly re-emitted once per `FLAGS` element) whenever an
arrayed reference wasn't the *first* thing in its statement. The
correct rule, arrived at after three iterations (see the function's own
`interp.c` comment for the full account of what each intermediate fix
broke): the paragraph start is the single instruction immediately
preceding the `ADLP`/`IDLP` chain, extended backward only through
confirmed same-statement `QUAL_VAC` operand dependencies (so a computed
expression like `A3 = A1 + A2;`'s `SADD` gets pulled in behind its own
`SASN`), and excluding a chain preceded by [SFAR](SFAR.md) entirely
(`SFAR` must never itself be replayed — it's `MAX`/`MIN`/`SUM`/`PROD`/
`SIZE`'s own declarative element-count metadata, not a "replay N times"
directive, when wrapped in `ADLP`/`DLPE` around a single occurrence).
Resolving a `QUAL_VAC` operand's target required converting its raw
HALMAT *word position* (`.index`) into the matching `instrs[]` *logical
index* via each candidate instruction's own `.index` field — the two
are different numbering schemes (confirmed via `fail()`'s own error
messages, which report `.index`), and comparing them directly silently
made the whole backward-walk never trigger. After this fix, the full
regression suite passed with no further regressions.

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
