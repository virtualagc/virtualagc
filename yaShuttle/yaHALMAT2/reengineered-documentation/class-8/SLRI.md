# SLRI

**Mnemonic:** SLRI

**Opcode:** 0x802

**Confidence:** High

## Behavioral Description

Start loop, repeated initialize. Opens a repeated-initial-value sequence
within a "static bypass block" (see [BINT](BINT.md) for the general
concept), used for the `n#value` repetition-factor form of an
`INITIAL(...)`/`CONSTANT(...)` specification ([USA003087] §16.2, "Use of
Repetition Factors") — e.g. `DECLARE S ARRAY(1000) SCALAR
INITIAL(1000#1.5);`. Follows [STRI](STRI.md) (the general
repeated-initialize header) and carries the repetition count.

## Usage Context

Appears once per repetition group, immediately after [STRI](STRI.md).
**Correction (later session, re-confirmed against a current HALSFC
build):** the compiler emits exactly one [SINT](SINT.md)/[ELRI](ELRI.md)
unit regardless of repetition count — confirmed for both a 3-element and
a 1000-element array (`DECLARE A ARRAY(1000) SCALAR
INITIAL(1000#1.5);`, both `--parms="LSTALL"` and plain compiles agree:
exactly one `SINT`/`ELRI` pair, not one per element). The originally
documented "999 more repetitions" trace below does not reproduce against
this build and is believed to have been a documentation error rather
than a genuine compiler-version difference (no other evidence of
compiler-version-dependent HALMAT shape has turned up elsewhere in this
project). The single unit is instead **replayed by the consuming
program** at runtime, driven by SLRI's own repetition-count operand — the
same "single-instance-plus-trailing-metadata, replayed by the consumer"
shape [ADLP](../class-0/ADLP.md)/[IDLP](../class-0/IDLP.md) use, except
SLRI *leads* the paragraph it describes (STRI names the target symbol,
SLRI opens the replay, the single SINT/ELRI unit is the body, ETRI
closes it) rather than trailing it. Consistent either way with `STATIC`
initialization ([USA003087] §16.4) being realized as compile-time-laid-
out data rather than executable code — a real runtime loop was never
required, whichever the compiler generates. The whole sequence is closed
by [ETRI](ETRI.md).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=the repetition count, `QUAL`=6=IMD;
operand 2 = `DATA`=the number of elements per repeated unit (`1` for a
simple `n#value` pattern; **confirmed**, not just presumed, this
session against a nested `n#(v1, m#v2)` group, where the outer SLRI's
operand 2 is the group's own element count — see the "factored form
nests" note below), `QUAL`=6=IMD. Confirmed by compiling
`DECLARE A ARRAY(3) SCALAR INITIAL(3#1.5);`:

```
HALMAT: 801(1),0,0            <- STRI: A, symbol index 2
HALMAT: 802(2),1,0            <- SLRI
          3(6),0,0               <- literal 3 (repetition count), QUAL=6=IMD
          1(6),0,0               <- literal 1 (values per unit), QUAL=6=IMD
HALMAT: 8A1(2),5,0            <- SINT (see SINT.md), single unit -- the runtime
                                  consumer replays this once per repetition
          0(10),0,0              <- DATA=0, QUAL=A=OFF (relative/sequential offset — see SINT.md)
          3(5),1,0               <- literal-table index 3 (the value 1.5), QUAL=5=LIT
HALMAT: 803(0),1,0            <- ELRI (see ELRI.md): end of this unit
HALMAT: 804(0),0,0            <- ETRI (see ETRI.md): end of the whole sequence
```

This confirms [SINT](SINT.md)'s previously-speculative "OFFSET-addressed
form... used for element-by-element matrix/vector initialization" —
here used for a scalar array instead, with `QUAL`=A=OFF and `DATA`=0 for
every element, implying the offset is *relative*/sequential (the
runtime replay's own iteration counter, not a literal encoded per
instance) rather than an explicit absolute index.

Note: SLRI/ELRI are specific to this `n#value` uniform-repetition case.
A plain, non-repeated `INITIAL(v1, v2, ...)` list on a VECTOR/MATRIX/
ARRAY uses a different, SLRI-free STRI/[SINT](SINT.md)/[ETRI](ETRI.md)
shape instead — see [SINT](SINT.md)'s Operand-Word Format section.

**A single `INITIAL(...)` list can mix both shapes freely** — confirmed
this session by a user-reported bug against `INITIAL(1, 3#0, 1, 3#0,
1)` (a `MATRIX(3,3)`, meant as a 3x3 identity matrix): this compiles to
one `STRI`, then an alternation of bare `SINT`s (the plain-literal
segments) and `SLRI`/`SINT`/`ELRI` triples (the `n#value` segments),
closed by one final `ETRI` — exactly the two shapes above, back to
back, sharing the one enclosing `STRI`/`ETRI` group. yaHALMAT2's own
runtime replay-boundary computation (`precompute_arrayed_paragraphs`,
interp.c) had a bug here, now fixed: it scanned forward from each SLRI
for the *outer* group's `ETRI` instead of this SLRI's own matching
`ELRI`, so the first `n#value` segment's replay swallowed every
following `SINT`/`SLRI`/`ELRI` up to the true end and replayed all of
it, corrupting every element after the first repeat group (the
identity matrix came out `1,1,0,0,1,1,1,0,1` instead of
`1,0,0,0,1,0,0,0,1`). Every previously-tested fixture had only one
`SLRI`...`ELRI` pair with nothing else before the group's `ETRI`, so
`ELRI` and `ETRI` were adjacent there and this had no observable
effect — see `src/tests/hal/test_matrix_identity_init.hal` for the
regression fixture.

**The factored form nests** ([USA003087] §16.2: "The factored form may
be nested if necessary... especially convenient in the initialization
of multi-dimensional arrays, or arrays of matrices and vectors") —
confirmed this session by a second, deeper user-reported bug against
`INITIAL(4#(1,5#0),1)` (a `MATRIX(5,5)`, meant as a 5x5 identity
matrix): the outer group's repeated unit is itself `(1, 5#0)`, so the
*outer* `SLRI`'s own bracketed body contains a *complete inner*
`SLRI`/`SINT`/`ELRI` triple (for the nested `5#0`), not just plain
`SINT`s. Confirmed operand-word values:

```
STRI: P5
SLRI tag=1: count=4, unit_size=6      <- outer: repeat "(1,5#0)" (6 elements) 4 times
  SINT OFF=0: 1.0                     <- the leading "1" of the group
  SLRI tag=2: count=5, unit_size=1    <- inner: repeat "0" (1 element) 5 times
    SINT OFF=1: 0.0
  ELRI tag=2                          <- closes the inner SLRI
ELRI tag=1                            <- closes the outer SLRI
SINT OFF=24: 1.0                      <- the final bare "1"
ETRI
```

This confirms SLRI's 2nd operand is exactly "elements per repeated
unit" (6 for the outer group, 1 for the inner) — resolving the
Unresolved Question below — and reveals **`ELRI`/`SLRI` are matched by
the operator word's own `TAG` field**, a 1-based nesting depth (`1`=
outermost, `2`=next level in, ...), not simply "the next `ELRI`
found": scanning for the first `ELRI` after the outer `SLRI` would
wrongly stop at the *inner* `ELRI` (tag 2) instead of the outer's own
(tag 1). yaHALMAT2's replay (`precompute_arrayed_paragraphs`/the new
`run_arrayed_paragraph`, interp.c) previously had no nesting support at
all -- a flat, single-level replay treats a nested `SLRI`/`ELRI` as
inert no-op markers (the same fallback behavior an unreplayed bare
`SLRI`/`ELRI` always has) and never replays the inner group, so the
nested `5#0`'s value was written once at the wrong offset instead of
five times at the right ones. Fixed by (1) matching `SLRI`↔`ELRI` pairs
by equal `TAG` rather than "next `ELRI`", and (2) making the replay
itself recurse into a nested `SLRI`-driven paragraph it encounters,
accumulating each active level's own `idx*unit_size` contribution into
the absolute `OFF`-write offset (confirmed exactly: outer_idx*6 +
inner_idx*1 + the instruction's own `OFF` operand reproduces every
element of the expected identity matrix) — see
`src/tests/hal/test_matrix_identity5_init.hal` for the regression
fixture. The recursion is not depth-limited, so a triple-or-deeper
nesting (`n#(m#(k#value))`) should work the same way in principle;
spot-checked with a 2-level `2#(3#(1,2))` during this fix but not
written up as its own permanent fixture.

## Unresolved Questions

- ~~Whether a non-uniform repeated pattern (e.g. `n#(v1, v2, v3)`,
  several distinct values repeated as a group) changes SLRI's second
  operand or produces a different `ELRI` count per group-repetition was
  not tested — only the simplest single-value `n#value` form was
  compiled.~~ **Resolved this session** — see the nested-repetition
  note above: operand 2 is confirmed to be the repeated unit's own
  element count (6 for a 6-element `(1,5#0)` unit), and each nesting
  level gets its own `SLRI`/`ELRI` pair (matched by `TAG`), not a
  different `ELRI` count.
- Whether `AUTOMATIC` initialization (re-run on every block entry, per
  §16.4) produces an actual runtime loop instead of this single-unit-
  replayed form was not tested.
- The exact meaning of operand 2 (observed value `1`) is inferred, not
  confirmed against a case where it would differ.

## Source Analysis & Reliability

Opcode (0x802) doubly confirmed (`XSLRI`) in `PASS1.PROCS/##DRIVER.xpl` —
see [##DRIVER.xpl] in `STATUS.md`. Slot matches HAL-1971's DLPI
("initialize loop header"); the mnemonic itself differs, so this remains
a plausibly-renamed version of the same concept rather than a confirmed
cross-language match. Statement syntax primary-sourced from [USA003087]
§16.2 (PDF p. 183ff). Full behavioral description and operand-word
structure confirmed directly against real compiled HALMAT this session.
