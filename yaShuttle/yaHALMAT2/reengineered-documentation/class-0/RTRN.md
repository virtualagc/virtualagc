# RTRN

**Mnemonic:** RTRN

**Opcode:** 0x032

**Confidence:** High

## Behavioral Description

Subprogram return. Specifies a return from a subprogram. In the
predecessor language HAL, this instruction has two forms: one used for
tasks and procedures (no return value), and one used for functions (which
carries the returned operand, of any type, as its `a` field). Both forms'
`b` field points to the name of the enclosing subprogram in the symbol
table.

Per [MSC-01847] §3.5.1's worked example, the close of a procedure or
function always generates a RTRN instruction, even when the last
executable statement in the body was itself an explicit RETURN — i.e.
every subprogram body is HALMAT-terminated by RTRN regardless of how many
explicit `RETURN;` statements the source contained.

## Usage Context

Appears once per explicit `RETURN` statement in a subprogram body, and
again (redundantly, as an error/fallthrough exit) at the CLOS-equivalent
end of the subprogram body. See [PDEF](PDEF.md)/[FDEF](FDEF.md)/
[TDEF](TDEF.md)/[MDEF](MDEF.md) for the corresponding definition headers.

## `yaHALMAT2` Implementation Notes

The genuine same-unit call-frame branch of `OP_RTRN` (`interp.c`,
`state->call_return_sp > 0`, as distinct from the inline-`FUNCTION` and
external-call forms handled just above it in the same `case`) went
through three fixes this project:

- **Return type discarded entirely** (user-reported, 128-MASS.hal's
  `MASS` — a same-unit, non-inline `SCALAR`-returning `FUNCTION` —
  always printed a constant `INTEGER` `1` regardless of input): this
  branch unconditionally forced the return value through
  `rv_to_integer()` and stored only `.integer` on the caller's `VAC`
  slot, discarding the function's real declared return type for *every*
  same-unit `FUNCTION` call in the interpreter — apparently never
  exercised before, since every prior `SCALAR`/`CHARACTER`-returning
  `FUNCTION` fixture was either `EXTERNAL` or `INLINE` (both already
  correct via a different path). Fixed by routing through
  `store_resolved_to_vac()` instead (kind-preserving: `RV_SCALAR`/
  `RV_STRING`/`RV_BITS`/`RV_INTEGER` each land in their own `VAC` slot
  field).
- **`BOOLEAN`/`BIT` return width lost** (user-reported, 129-ALMOST_EQUAL.hal's
  `ALMOST_EQUAL`, declared `BOOLEAN` — a synonym for `BIT(1)`):
  printed as a full 32-bit binary field instead of the single digit it
  actually is. Fixed by having this branch stamp the callee's own
  symtab-declared `bit_width` onto the `VAC` slot (new `bit_width`
  field on `halmat_vac_slot_t`, `state.h`) whenever the return value is
  `BIT`-typed, re-deriving the callee's symbol via the `FCAL`
  instruction's own first operand.
- **Whole `VECTOR`/`MATRIX`/`ARRAY` `RETURN` value** (user-reported,
  134-DOTS.hal's `RETURN RESULT;`, `RESULT` a `MATRIX(10,10)`): this
  branch had no case at all for a whole-container return —
  `store_resolved_to_vac()` only ever handles `RV_SCALAR`/`RV_STRING`/
  `RV_BITS`/`RV_INTEGER` — so it fell through to the ordinary
  `resolve_operand()` path and failed loudly ("SYT index N is a whole
  ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph replay").
  Fixed by detecting a whole `VECTOR`/`MATRIX` (`syt_is_vector_or_
  matrix_shaped`) or `VAC`-container `RETURN` operand up front and
  routing it through `resolve_container()`/`store_container_result()`
  instead, mirroring the WRITE-argument whole-container capture's own
  established pattern ([XXAR](XXAR.md)). Getting DOTS's own output
  *correct* (not just non-crashing) additionally required a fix on the
  CALL-argument-binding side — see [XXAR](XXAR.md)/[XXST](XXST.md)'s
  own notes on the `call_array_replay` mechanism.

Fixtures: `test_fcal_scalar_return.hal`, `test_fcal_boolean_return.hal`,
`test_dots.hal`. `ARRAY(*)` assumed-size parameter binding (140-STATISTICS.hal's
`CALL STATISTICS(DATA) ASSIGN(LO, HI, MN);`, `DATA` declared `ARRAY(*)
SCALAR`) is now fixed too — two compounding bugs, `symtab.c`'s missing
sign-extension of the negative-sentinel assumed-size bound and
`ensure_container()`/`bind_call_argument()`'s inability to allocate such
a parameter from the caller's own actual argument shape — see
[DSUB](DSUB.md)'s Unresolved Questions for the full trace. Fixture:
`test_statistics.hal`.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether HAL/S retains the two-version (task/procedure vs. function)
  structure is unconfirmed.

## Source Analysis & Reliability

Opcode (0x032) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for RTRN's own HAL/S description (target p. 11) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-16 and the worked
example at p. 3-19, describing the identically-named predecessor-language
instruction (HAL 1971 opcode 0x030, differing from HAL/S's 0x032). See
[STRI](../class-8/STRI.md)'s Source Analysis section for the general basis
of this cross-language inference.
