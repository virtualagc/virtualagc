# BFNC

**Mnemonic:** BFNC

**Opcode:** 0x04A

**Confidence:** High

## Behavioral Description

Built-in function call. The general-purpose opcode invoking most of
HAL/S's built-in/library functions ([USA003087] §7.6) — confirmed this
session for the real-time `PRIO` function and 14 of the arithmetic/
algebraic/vector-matrix/character functions from §7.6 (see the selector
table below) — with a trailing header field on the instruction selecting
*which* function. Two built-ins, `MAX`/`MIN`, use a separate opcode
instead — see [LFNC](LFNC.md). Speculated in this project (before this
session) to be HAL/S's split-off of HAL 1971's combined `FUNC`
instruction (which handled both user-defined and built-in function
invocation together) — see [FCAL](FCAL.md) for the user-defined-function
counterpart, now kept separate in HAL/S.

Also carries an Optimizer-HALMAT-era special case: when BFNC's `TAG`
field is `0x39` or `0x3A`, it represents a combined sine/cosine
computation (`SINCOS`) — **empirically confirmed in a later session**
(`S1 = SIN(X); C1 = COS(X);` collapses to a single post-optimization
`BFNC` with `TAG`=`0x39`) — see `HALMAT.md`'s Optimizer HALMAT section
for the full trace.

## Usage Context

Emitted for any built-in-function call other than `MAX`/`MIN`. Confirmed
across three sessions for `PRIO` (no arguments) and 15 single-argument
functions (arguments passed directly as BFNC's own operand — no
[SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md) bracket is used, unlike
[LFNC](LFNC.md)/[MSHP](MSHP.md)/etc.).

## Operand-Word Format (confirmed empirically)

**No-argument form** (e.g. `PRIO`): no operands; the opcode line's
trailing header field alone carries the selector value.

**Single-argument form**: one operand — the argument, `QUAL`=1=SYT (a
plain variable) or presumably `QUAL`=3=VAC (an expression result, not
directly tested) — with the selector still on the opcode line's trailing
header field. The call's result is consumed by the following instruction
via a `VAC`-qualified reference to BFNC's own stream position, same as
any other value-producing instruction.

Confirmed by compiling `I1 = PRIO;` and, separately, each of 15 built-in
functions applied to a plain `SCALAR`/`VECTOR`/`CHARACTER` argument, with
`HALSFC --parms="LSTALL"`:

```
I1 = PRIO;
HALMAT: 04A(0),19,0         <- BFNC, selector 19 = PRIO, no operands
SVC 0,=H'791'                 <- runtime call retrieving the process's own priority

S2 = ROUND(S1);
HALMAT: 04A(1),33,0         <- BFNC, selector 33 = ROUND
          2(1),5,0             <- S1, symbol index 2, QUAL=1=SYT
BAL 4,ROUND                    <- runtime call to a routine literally named ROUND
```

Confirmed selector table (all Class 0 opcode-line trailing-field values):

| Selector | Function | Selector | Function | Selector | Function |
|---|---|---|---|---|---|
| 1 | `ABS` | 15 | `TAN` | 28 | `ABVAL` |
| 2 | `COS` | 19 | `PRIO` | 33 | `ROUND` |
| 3 | `DET` | 21 | `SIGN` | 40 | `LENGTH` |
| 5 | `EXP` | 24 | `SQRT` | 49 | `INVERSE` |
| 6 | `LOG` | 26 | `TRIM` | | |
| 13 | `SIN` | 27 | `UNIT` | | |

(Selector 3 = `DET` confirmed by the alphabetical `BI_NAME`/`BI_INDX` array in
`PASS1.PROCS/##DRIVER.xpl` -- `ABS`=1, `COS`=2, `DET`=3, `DIV`=4, `EXP`=5,
`LOG`=6, ... -- which independently cross-checks `unHALMAT.py`'s own
hardcoded `bfncTypes` selector-name table, rather than a fresh compiled-
argument test like the other 14. `DET` takes a whole `MATRIX` argument and
returns its determinant as a `SCALAR`, the same operand shape as `INVERSE`
below, not the plain-`SCALAR`-argument shape the "Single-argument form"
text above describes for the other functions.)

(`0x39`/`0x3A` = `SINCOS`, an Optimizer-HALMAT-era special case —
empirically confirmed for the `0x39` case in a later session — see
`HALMAT.md`'s Optimizer HALMAT section.)

## Unresolved Questions

- The full selector-value table is still not exhaustive — untested
  built-ins include `DIV` (2 arguments), `ODD`, `DATE`, `RANDOMG`, and
  the "Additional" functions in [USA003087] Appendix B not covered by
  §7.6's summary list.
- Whether a `VAC`-qualified (expression-result) argument is handled
  identically to the `SYT`-qualified (plain-variable) case tested is
  presumed but not directly confirmed.

## Confirmed Runtime Behavior

[USA003090] Appendix C's group-4 execution-time-error "standard fixups"
apply to several of these selectors — a later session implemented the
ones this project's existing functions can actually hit (matching
functions not yet implemented, e.g. `SINH`/`COSH`/`ARCSIN`/`ARCCOS`, are
out of scope until those selectors exist):

- `INVERSE` (49, error 27, singular matrix): result is the identity
  matrix, not a runtime abort — same disposition as [MINV](../class-3/MINV.md)'s
  `M**(-1)` form, since both route through the identical `matrix_invert()`
  singular-matrix case.
- `UNIT` (27, error 28, null vector): result is the input vector
  unchanged (every component already zero), not a runtime abort.
- `SQRT` (24, error 5, argument < 0): result is `sqrt(|argument|)`.
- `EXP` (5, error 6, argument > 174.673): result is the maximum
  representable value (~7.237×10^75).
- `LOG` (6, error 7, argument <= 0): zero argument → maximum
  representable *negative* value; negative argument → `log(|argument|)`.
- `SIN`/`COS` (13/2, error 8, `|argument|` > ~823,296): result is
  `sqrt(2)/2`.
- `TAN` (15, errors 11/12): `|argument|` too large → result is `1`;
  argument too close to an odd multiple of π/2 → result is the maximum
  representable value (detected by the practical proxy of the underlying
  `tan()` call itself returning a non-finite value, rather than
  replicating the primary source's own proximity-to-singularity test).

**Follow-up session**: every one of the fixups above now consults
[ERON](ERON.md)'s registered `ON ERROR` handler table first — a `GO TO`
handler registered for the matching error redirects execution there
instead of applying the fixup, per [ERON](ERON.md)'s own "Confirmed
Runtime Behavior" section (which also covers every other App. C fixup
site this project implements, not just this opcode's).

See `STATUS.md`'s Class 0 section for the fuller citation and per-error
trace; `src/tests/hal/test_errfix_matrix.hal`/`test_errfix_scalar.hal`/
`test_errfix_trig.hal` are the regression fixtures.

## Source Analysis & Reliability

Opcode (0x04A) confirmed primary-source: `XBFNC BIT(16) INITIAL("04A")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Optimizer-HALMAT-era `SINCOS` special case primary-sourced from
[IR-60-5] A-112 (documented in an earlier session), and empirically
confirmed against real compiled HALMAT (`halmat.bin`-vs-`optmat.bin`
diffing) in a later session — see `HALMAT.md`'s Optimizer HALMAT
section. `PRIO` case
confirmed directly against real compiled HALMAT in an earlier session
(a byproduct of investigating [PRIO](PRIO.md), 0x038). The 14-function
selector table confirmed this session by testing every single-argument
built-in function listed in [USA003087] §7.6 against real compiled
HALMAT, prompted by a search for [LFNC](LFNC.md)'s trigger condition
(which turned out to be the two functions, `MAX`/`MIN`, that this sweep
found *not* using BFNC). `DET`'s selector (3) added in a later session,
found via a user bug report (`WRITE(6) DET(A2A);` failing, `029-
DATATYPES.hal` from "Programming in HAL/S" p. 29) — see `STATUS.md`'s
Class 0 section for the fix's own root-cause narrative.
