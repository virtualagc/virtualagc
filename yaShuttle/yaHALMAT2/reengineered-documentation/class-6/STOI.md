# STOI

**Mnemonic:** STOI

**Opcode:** 0x6A1

**Confidence:** High

## Behavioral Description

Scalar to integer conversion. Converts a scalar (floating-point) operand
to its integer representation, **rounding to nearest (ties away from
zero) — empirically confirmed this session** (see Confirmed Runtime
Behavior below), not truncation. Classed under Class 6 (integer) because
HALMAT classes conversion operators by their *result* type — see
[BTOI](BTOI.md) for the general pattern.

## Usage Context

Emitted wherever a scalar value must be converted to integer, e.g. in
mixed-type arithmetic expressions or explicit HAL/S `INTEGER(...)`
shaping-function invocations (see [SFST](../class-0/SFST.md)).

## Confirmed Runtime Behavior

Per [USA00309] §8.2 rule 10: **runtime conversion from scalar to integer
results in an ERROR CONDITION if the scalar value cannot be represented
in the integer form** (i.e. out of INTEGER's representable range, and
plausibly also if not exactly integral — the source doesn't fully
disambiguate "cannot be represented" beyond range). This resolves the
"zero-value edge case" flagged earlier: the leading-space/padding
behavior the original secondhand summary described turned out to belong
to [STOC](../class-2/STOC.md)'s character-output formatting (§6.1.3), not
to this instruction — see that file for the full resolution. STOI itself
has no special zero-handling; it simply errors or succeeds per the range
rule above.

**Overflow's exact ERROR CONDITION response, implemented in a later
session**: [USA003090] Appendix C error 15 ("SCALAR too large for
INTEGER conversion") gives the standard fixup as "the maximum
representable integer value (32767 or -32768)" — HAL/S's 16-bit
single-precision INTEGER halfword bounds. This project has never modeled
an INTEGER SINGLE/DOUBLE precision distinction (every INTEGER is a plain
`int32_t` throughout `interp.c`/`state.h`, with IADD/ISUB/etc. treating
values above 32767 as ordinary unclamped 32-bit integers), so
`halmat_scalar_to_integer` (value.c) clamps to `INT32_MAX`/`INT32_MIN`
instead — this emulator's own actual representable range, consistent
with every other INTEGER opcode, rather than the primary source's
literal 16-bit bounds. Also fixes a latent undefined-behavior bug: the
previous plain `(int32_t)round(...)` cast was UB in C for any double
outside `int32_t`'s range. See `STATUS.md`'s Class 0 section;
`src/tests/hal/test_errfix_trig.hal` is the regression fixture.
`OP_STOI` also consults [ERON](../class-0/ERON.md)'s registered `ON
ERROR` handler table before applying this fixup (follow-up session), via
its own duplicated range check rather than reading it back out of
`halmat_scalar_to_integer()` itself -- that function is a generic
INTEGER coercion used by many unrelated call sites (array subscripts,
etc.) that aren't the HAL/S-level `STOI` conversion error 15 is
specifically about.

**Rounding rule for in-range fractional values, empirically confirmed
this session** against the reference yaHALMAT emulator (yaHALMAT2's own
Phase 3 implementation work): compiling `I1 = INTEGER(S1);` for
S1 = 7.2, 7.5, -7.5, -7.2 in turn (via HAL/S's `INTEGER(...)` shaping-
function conversion, which compiles to a plain STOI, `6A1(1),1,0`) and
running the resulting HALMAT on the reference emulator produces
I1 = 7, 8, -8, -7 respectively — i.e. **round to nearest, ties away from
zero**, not truncation (truncation would give 7, 7, -7, -7). A ties-to-
even reading can't be distinguished from this data alone (-8 is itself
even), but "ties away from zero" already matches every case with no
counterexample, so there's no evidence favoring the more complex rule.
Note the tested construct used tag=1 on the STOI operator word (vs. the
tag=0 form seen for implicit narrowing coercions elsewhere in this
project) — whether the tag distinguishes a rounding mode is unconfirmed
(see Unresolved Questions).

## Unresolved Questions

- HAL/S operand-word format beyond the single SYT source operand is
  unconfirmed; see [STRI](../class-8/STRI.md).
- Whether STOI's `TAG` field selects between rounding and truncation (the
  one confirmed case above used `TAG`=1) is unconfirmed — no compiled
  example with `TAG`=0 and a fractional operand has been checked yet.

## Source Analysis & Reliability

Opcode (0x6A1) confirmed primary-source: element 4 of the `XBTOI(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 STOI opcode (0x6A1) exactly.

Behavioral description is a straightforward reading of "scalar to integer
conversion" corroborated by [MSC-01847] §2.21. Error-condition behavior
is primary-sourced from [USA00309] §8.2 rule 10 — see `STATUS.md` for the
full citation. No verbatim operand-word (bit-level) prose transcribed
yet.
