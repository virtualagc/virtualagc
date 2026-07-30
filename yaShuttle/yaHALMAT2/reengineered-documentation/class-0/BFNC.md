# BFNC

**Mnemonic:** BFNC

**Opcode:** 0x04A

**Confidence:** High

## Behavioral Description

Built-in function call. The general-purpose opcode invoking most of
HAL/S's built-in/library functions ([USA003087] Appendix B) — confirmed
across several sessions for the real-time `PRIO` function and 46 of the
arithmetic/algebraic/vector-matrix/miscellaneous/character/bit functions
in Appendix B's catalog (see the selector table below) — with a trailing
header field on the instruction selecting *which* function. Five
built-ins that reduce an *array* argument to a single value —
`MAX`/`MIN`/`SUM`/`PROD`/`SIZE` — use a separate opcode instead: see
[LFNC](LFNC.md), whose own selector table shares these exact same
`BI_NAME`-position numbers (7/8/14/20/23) despite the different opcode.
Speculated in this project (before the first BFNC session) to be HAL/S's
split-off of HAL 1971's combined `FUNC` instruction (which handled both
user-defined and built-in function invocation together) — see
[FCAL](FCAL.md) for the user-defined-function counterpart, now kept
separate in HAL/S.

Also carries an Optimizer-HALMAT-era special case: when BFNC's `TAG`
field is `0x39` or `0x3A`, it represents a combined sine/cosine
computation (`SINCOS`) — **empirically confirmed in a later session**
(`S1 = SIN(X); C1 = COS(X);` collapses to a single post-optimization
`BFNC` with `TAG`=`0x39`) — see `HALMAT.md`'s Optimizer HALMAT section
for the full trace.

## Usage Context

Emitted for any built-in-function call other than the five array-
reduction functions [LFNC](LFNC.md) handles. Confirmed across several
sessions for six no-argument functions (`PRIO`/`RANDOM`/`RANDOMG`/
`RUNTIME`/`ERRGRP`/`ERRNUM`), 30 single-argument functions, and 11
two-or-three-argument functions (arguments passed directly as BFNC's own
operands — no [SFST](SFST.md)/[SFAR](SFAR.md)/[SFND](SFND.md) bracket is
used, unlike [LFNC](LFNC.md)/[MSHP](MSHP.md)/etc.).

## Operand-Word Format (confirmed empirically)

**No-argument form** (e.g. `PRIO`): no operands; the opcode line's
trailing header field alone carries the selector value.

**Single-argument form**: one operand — the argument, `QUAL`=1=SYT (a
plain variable) or presumably `QUAL`=3=VAC (an expression result, not
directly tested) — with the selector still on the opcode line's trailing
header field. The call's result is consumed by the following instruction
via a `VAC`-qualified reference to BFNC's own stream position, same as
any other value-producing instruction.

**Two/three-argument form** (`DIV`/`MOD`/`REMAINDER`/`MIDVAL`/`ARCTAN2`/
`SHL`/`SHR`/`XOR`/`INDEX`/`LJUST`/`RJUST`, confirmed via `interp.c`'s own
handling rather than a fresh `--disasm` trace of each individually): the
same shape as the single-argument form, just with 2 or 3 operands instead
of 1, each an ordinary argument (no `SFST`/`SFAR`/`SFND` bracket, same as
the single-argument case). Not independently reconfirmed via a dedicated
compile+`--disasm` probe the way the single-argument functions below
were — implemented directly from [USA003087] Appendix B's documented
argument counts on the strength of the single-argument form's already-
confirmed pattern (a plain operand per argument, no special bracketing),
consistent with every one compiling and running correctly against real
`HALSFC` output.

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

Confirmed selector table (all Class 0 opcode-line trailing-field values;
every value is that function's fixed position in the compiler's own
alphabetical `BI_NAME` array, `PASS1.PROCS/##DRIVER.xpl` — the same
"count the array in order" technique first used to confirm `DET`=3,
reused throughout to confirm every selector added in the later batch
session):

| Selector | Function | Selector | Function | Selector | Function |
|---|---|---|---|---|---|
| 1 | `ABS` | 21 | `SIGN` | 40 | `LENGTH` |
| 2 | `COS` | 22 | `SINH` | 41 | `MIDVAL` |
| 3 | `DET` | 24 | `SQRT` | 42 | `RANDOM` |
| 4 | `DIV` | 25 | `TANH` | 43 | `SIGNUM` |
| 5 | `EXP` | 26 | `TRIM` | 44 | `ARCCOSH` |
| 6 | `LOG` | 27 | `UNIT` | 45 | `ARCSINH` |
| 9 | `MOD` | 28 | `ABVAL` | 46 | `ARCTANH` |
| 10 | `ODD` | 29 | `FLOOR` | 47 | `ARCTAN2` |
| 11 | `SHL` | 30 | `INDEX` | 48 | `CEILING` |
| 12 | `SHR` | 31 | `LJUST` | 49 | `INVERSE` |
| 13 | `SIN` | 32 | `RJUST` | 51 | `RANDOMG` |
| 15 | `TAN` | 33 | `ROUND` | 52 | `RUNTIME` |
| 16 | `XOR` | 34 | `TRACE` | 53 | `TRUNCATE` |
| 17 | `COSH` | 35 | `ARCCOS` | 54 | `CLOCKTIME` |
| 18 | `DATE` | 36 | `ARCSIN` | 55 | `REMAINDER` |
| 19 | `PRIO` | 37 | `ARCTAN` | 56 | `TRANSPOSE` |
|  |  | 38 | `ERRGRP` |  |  |
|  |  | 39 | `ERRNUM` |  |  |

(`DET`(3) takes a whole `MATRIX` argument and returns its determinant as
a `SCALAR`, the same operand shape as `INVERSE`(49)/`TRANSPOSE`(56)/
`TRACE`(34) — not the plain-`SCALAR`-argument shape the "Single-argument
form" text above describes for most other functions in this table.
Selectors 7/8/14/20/23 — `MAX`/`MIN`/`SUM`/`PROD`/`SIZE` — occupy these
same `BI_NAME` positions but do **not** appear in this table: confirmed
via direct `HALSFC` compile+`--disasm` probes (a later, "batch" session)
that all five instead compile through the separate [LFNC](LFNC.md)
opcode. Selector 50 (`NEXTIME`) and 57–63 (`BIT`/`SUBBIT`/`INTEGER`/
`SCALAR`/`VECTOR`/`MATRIX`/`CHARACTER`) remain unconfirmed — see
Unresolved Questions below.)

(`0x39`/`0x3A` = `SINCOS`, an Optimizer-HALMAT-era special case —
empirically confirmed for the `0x39` case in a later session — see
`HALMAT.md`'s Optimizer HALMAT section.)

## Unresolved Questions

- Selector 50 (`NEXTIME`) is confirmed by `BI_NAME` position but not
  implemented — would need `state->tasks[]` scheduler-internals
  introspection (its own IN/AT-scheduled wake time) not undertaken as of
  the batch session that filled in most of this table.
- Selectors 57–63 (`BIT`/`SUBBIT`/`INTEGER`/`SCALAR`/`VECTOR`/`MATRIX`/
  `CHARACTER`) are unconfirmed and unimplemented — these `BI_NAME` slots
  almost certainly back the explicit-conversion/shaping-function
  *syntax* (`SCALAR(...)`/`VECTOR(...)`/etc.), which this project's own
  extensive prior work already confirmed compiles to dedicated opcodes
  (`STOI`/`CTOS`/[MSHP](MSHP.md)/[VSHP](VSHP.md)/[SSHP](SSHP.md)/
  [ISHP](ISHP.md)/`BASN`/`ITOQ` and friends), not a raw `BFNC` call — but
  no real compiled HALMAT has actually been observed hitting `BFNC` with
  any of these selectors, so this remains an inference, not a
  confirmation.
- Whether a `VAC`-qualified (expression-result) argument is handled
  identically to the `SYT`-qualified (plain-variable) case tested is
  presumed but not directly confirmed.
- The two/three-argument selectors' operand-word format (see above) was
  implemented from Appendix B's documented argument counts and the
  already-confirmed single-argument shape, rather than independently
  reconfirmed via a dedicated `--disasm` trace of each one.

## Confirmed Runtime Behavior

[USA003090] Appendix C's group-4 execution-time-error "standard fixups"
apply to several of these selectors — implemented for every one this
project's functions can actually hit, across two sessions (the second
adding the fixups that only became reachable once the corresponding
selector itself was implemented):

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
- `ARCTAN` (37): no App. C entry exists for it (only `ARCTANH`/`ARCTAN2`
  have one) and no restricted domain either ([USA003087] Appendix B:
  `ARCTAN(α) = tan⁻¹α`, unlike `ARCSIN`/`ARCCOS`/`ARCTANH`'s documented
  `|α|<1` limits) — a plain `atan()` via libm is total over every
  representable double, no guard needed.
- `COSH`/`SINH` (17/22, error 9, `|argument|` > 175.366 — **corrected**;
  the scanned `USA003090` text's "175,366" is almost certainly a decimal
  point mangled by OCR, not a thousands separator, confirmed against the
  real `RUNASM/SINH.asm` `MAX` constant `X'42AF5DC0'`, which hand-decodes
  to 175.366, not 175366.0 — task 108/id 51): result is the
  maximum representable value (sign-preserved for `SINH`, an odd
  function; `COSH` is even, always positive).
- `ARCCOS`/`ARCSIN` (35/36, error 10, `|argument|` > 1): `ARCCOS(>1)=0`,
  `ARCCOS(<-1)=π`, `ARCSIN(>1)=π/2`, `ARCSIN(<-1)=-π/2`.
- `REMAINDER` (55, error 16, divisor = 0): result is the (integer-
  rounded) dividend, unchanged.
- `LJUST`/`RJUST` (31/32, error 18, requested length < source string
  length): truncates to the requested length, dropping characters on the
  right (`LJUST`, keeping the left portion) or the left (`RJUST`,
  keeping the right portion).
- `MOD` (9, error 19, divisor = 0 and dividend < 0): result is `0` (a
  nonnegative dividend with a zero divisor isn't an App. C error at all
  — no row covers it — and returns the dividend unchanged, the natural
  `a mod 0 = a` limit).
- `MOD` (9, error 33, `|dividend/divisor|` too large — ~16^6 single
  precision / ~16^14 double precision): result is `0`.
- `ARCCOSH` (44, error 59, argument < 1): result is `0`.
- `ARCTANH` (46, error 60, `|argument|` > 1): result is `0` — this
  implementation's own guard actually triggers at `|argument| >= 1`, not
  the documented strict `> 1`, deliberately widened by one boundary
  value to avoid feeding libm's `atanh()` an exact ±1 (which returns
  `Inf`, and this project has already hit — and fixed — a real
  interpreter hang from an unguarded `Inf` reaching
  `halmat_scalar_from_double`'s normalization loop, via `SEXP`'s own
  error-4 fixup; see `STATUS.md`).
- `ARCTAN2` (47, error 62, both arguments zero): result is `0` — already
  satisfied by libm's own `atan2(0,0)=0` with no extra code, but still
  routed through the same fixup-consulting choke point so `ERRGRP`/
  `ERRNUM` and any registered `ON ERROR$(4:62)` handler still see/react
  to it.
- `DIV` (4, divisor = 0): **not** an App. C row — no standard fixup is
  documented for this specific case (unlike `MOD`/`REMAINDER`, which
  both have one), so this fails loudly rather than guessing a fixup
  value.

**Follow-up session**: every one of the fixups above now consults
[ERON](ERON.md)'s registered `ON ERROR` handler table first — a `GO TO`
handler registered for the matching error redirects execution there
instead of applying the fixup, per [ERON](ERON.md)'s own "Confirmed
Runtime Behavior" section (which also covers every other App. C fixup
site this project implements, not just this opcode's). The same choke
point (`arithmetic_error_should_apply_fixup`, `interp.c`) also now
updates `ERRGRP`(38)/`ERRNUM`(39)'s backing state on every error it
sees, whether or not a fixup/`GOTO` ends up applying — "last error
detected" per Appendix B means *detected*, not merely unhandled.

**`RANDOM`(42)/`RANDOMG`(51)**: no primary source documents the real
AP-101S runtime library's actual algorithm (the same situation as
`DET`/`INVERSE`'s Gaussian elimination, or [MINV](../class-3/MINV.md)'s
matrix exponentiation) — implemented as a from-scratch Park-Miller
"minimal standard" Lehmer generator (`state = state*16807 mod 2^31-1`),
seeded to a fixed non-zero value rather than a real entropy source, so
every interpreter run is exactly reproducible. `RANDOMG` layers a
Box-Muller transform over two `RANDOM` draws for its Gaussian
distribution (mean 0, variance 1, per Appendix B). Neither is a
confirmed match to the real HAL/S-FC runtime's own generator, just a
documented, fully-specified compromise.

**`DATE`(18)/`CLOCKTIME`(54)**: read the real OS wall-clock (`time()`/
`localtime()`), not this interpreter's own simulated virtual clock —
`localtime()` honors the process's `TZ`/the OS's configured timezone
directly, per direct user clarification that these functions mean
actual calendar time, not something needing a fabricated model.
[USA00309] Sec. 8.2 rule 17 pins `DATE`'s format down precisely: "a
double precision integer whose decimal value is YYDDD where YY are the
year and DDD represents the day of the year (i.e., February 1,
1978=78032)" — this project's ordinary 32-bit `INTEGER` (no `INTEGER`
`SINGLE`/`DOUBLE` distinction is modeled anywhere, per the error-15
fixup note below). `CLOCKTIME`'s unit isn't pinned down by any primary
source beyond rule 18's "double precision scalar" and Appendix B's
"time of day" — seconds-since-local-midnight was chosen as a documented
judgment call, consistent with `RUNTIME`'s own seconds convention.

**`RUNTIME`(52)**: the interpreter's simulated `virtual_time` (`state.h`,
ticks) converted to seconds via `HALMAT_TICKS_PER_SECOND`, per rule 18's
"RUNTIME returns the simulated elapsed time" (distinguishing it from
`DATE`/`CLOCKTIME`'s *real* wall-clock reading just above). Also fixed,
same session as `DATE`/`CLOCKTIME`: previously returned single
precision despite rule 18 explicitly calling `RUNTIME` "double precision
scalar" too.

**Error 15** (`SCALAR` too large for `INTEGER` conversion): the maximum
representable value used is `INT32_MAX`/`INT32_MIN`, not the primary
source's literal 16-bit `INTEGER SINGLE` bounds (32767/-32768) — see
`value.c`'s `halmat_scalar_to_integer()` and `STATUS.md`'s fuller note
on why (this project's `INTEGER` is always a plain, unclamped 32-bit
value elsewhere too, for consistency).

See `STATUS.md`'s Class 0 section for the fuller citation and per-error
trace; `src/tests/hal/test_errfix_matrix.hal`/`test_errfix_scalar.hal`/
`test_errfix_trig.hal`/`test_bfnc_hyperbolic.hal`/`test_bfnc_invtrig.hal`/
`test_bfnc_intops.hal`/`test_bfnc_char.hal`/`test_errgrp_errnum.hal` are
the regression fixtures for the fixups above; `test_random.hal`/
`test_runtime.hal`/`test_date_clocktime.hal` cover `RANDOM`/`RANDOMG`/
`RUNTIME`/`DATE`/`CLOCKTIME` themselves (the last via a dedicated
bounds-checking runner, `run_walltime_fixture.sh`, since a real wall-
clock reading can't be pinned to a fixed expected string).

## Source Analysis & Reliability

Opcode (0x04A) confirmed primary-source: `XBFNC BIT(16) INITIAL("04A")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Optimizer-HALMAT-era `SINCOS` special case primary-sourced from
[IR-60-5] A-112 (documented in an earlier session), and empirically
confirmed against real compiled HALMAT (`halmat.bin`-vs-`optmat.bin`
diffing) in a later session — see `HALMAT.md`'s Optimizer HALMAT
section. `PRIO` case
confirmed directly against real compiled HALMAT in an earlier session
(a byproduct of investigating [PRIO](PRIO.md), 0x038). The original
14-function selector table confirmed by testing every single-argument
built-in function listed in [USA003087] §7.6 against real compiled
HALMAT, prompted by a search for [LFNC](LFNC.md)'s trigger condition
(which turned out to be the two functions, `MAX`/`MIN`, that this sweep
found *not* using BFNC). `DET`'s selector (3) added in a later session,
found via a user bug report (`WRITE(6) DET(A2A);` failing, `029-
DATATYPES.hal` from "Programming in HAL/S" p. 29) — see `STATUS.md`'s
Class 0 section for the fix's own root-cause narrative. `ARCTAN`(37)
added following a user bug report against `046-XYZ_TO_POLAR.hal`.

**Batch session**: the table's remaining ~30 selectors were added in one
pass, after a `RANDOM` bug report (`071-DARTBOARD_APPROXIMATION.hal`)
was followed by an explicit request to stop fixing `BFNC` selectors one
report at a time and instead sweep every gap in [USA003087] Appendix B's
full built-in-function catalog against this file's own confirmed
`BI_NAME`-position numbering. Every selector added has either a real
corpus program exercising it (`071-DARTBOARD_APPROXIMATION.hal` for
`RANDOM`, `134-ROLL.hal` for `RANDOM` again, `234-X.hal` for `RUNTIME`,
`141-VSUM.hal` for the `LFNC`-side `SIZE` discovery below) or a
hand-written fixture compiled through real `HALSFC` and cross-checked by
hand/against known math facts. This same sweep is what found selectors
7/8/14/20/23 (`MAX`/`MIN`/`SUM`/`PROD`/`SIZE`) don't actually reach
`BFNC` at all: `141-VSUM.hal`'s own `SIZE(V)` call unexpectedly hit
[LFNC](LFNC.md)'s "unknown selector 23" failure instead, and two direct
`HALSFC` compile+`--disasm` probes confirmed `SUM`/`PROD` do too (`MAX`/
`MIN` were already known to, from an earlier session) while `TRANSPOSE`/
`TRACE` — initially suspected of the same thing, since both also reduce
a whole container to a value — genuinely do compile through `BFNC`. A
`DATE`/`CLOCKTIME` follow-up in the same session, prompted by a direct
user clarification that these mean real OS wall-clock time rather than
something needing an invented calendar model, found [USA00309] Sec. 8.2
rule 17's precise `DATE` format (missed in the first pass) and also
caught `RUNTIME` returning the wrong precision.
