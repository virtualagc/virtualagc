# STOC

**Mnemonic:** STOC

**Opcode:** 0x2A1

**Confidence:** High

## Behavioral Description

Scalar to character conversion. Converts a scalar (floating-point)
operand to its character-string representation, per HAL/S's implicit or
explicit (`CHARACTER(...)`) type-conversion rules. Classed under Class 2
(character) because HALMAT classes conversion operators by their *result*
type rather than their operand type — a pattern confirmed throughout
Classes 1–7 (see `STATUS.md`).

## Usage Context

Emitted wherever a scalar value must be converted to character, including
inside shaping-function invocations (see [SFST](../class-0/SFST.md)) for
the HAL/S built-in `CHAR(...)` function applied to a scalar argument.

## Confirmed Output Format

Per [USA00309] §6.1.3 ("Output Data Formats," which §8.2 rules 13–14
explicitly cite as governing this conversion too, not just `WRITE`
output): the character result is a **fixed-width field**, right-aligned
scientific notation:

- **Single precision**: 14 characters: `sd.ddddddddE±dd` — `s` is a
  blank (not a `+`) for non-negative values or `-` for negative, `d`
  (before the point) is one integer digit, 8 fractional digits, `E`
  literal, then a mandatory `+`/`-` and 2 exponent digits.
- **Double precision**: 23 characters, same pattern with 17 fractional
  digits.
- A double-precision scalar *literal* converts to a **single**-precision
  character result unless the literal's precision is explicitly pinned
  (`CONSTANT` declare, or a shaping function).

**This resolves the "zero-value edge case" flagged earlier**: `0.0` is
*not* a special case at all — it's simply a non-negative value, so it
gets the ordinary blank sign character (`s`=blank) like any other
non-negative scalar, followed by the full fixed-digit-count scientific
notation (e.g. single-precision `0.0` renders as `" 0.00000000E+00"`,
not merely `" 0.0"` — the earlier secondhand summary's `" 0.0"` was
evidently a shorthand paraphrase, not the literal output). No
zero-specific branch or padding rule is needed beyond the uniform
sign/field-width rule that applies to every value.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether this fixed-width format applies identically for STOC used
  outside a `WRITE` statement (e.g. assignment to a CHARACTER variable
  via the `CHAR(...)` shaping function) as it does for `WRITE`-statement
  output, or whether the two contexts diverge, is not yet independently
  confirmed — [USA00309] describes both under the same section, which is
  suggestive but not conclusive.

## Source Analysis & Reliability

Opcode (0x2A1) confirmed primary-source: element 4 of the `XBTOS`-pattern
array — specifically `XBTOC(5) BIT(16) INITIAL(..., /* XSTOC */ "02A1", ...)`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 STOC opcode (0x2A1) exactly — one of several
conversion opcodes that carried over unchanged between the two language
versions despite most Class 0 and Class 7 opcodes being renumbered.

Behavioral description is a straightforward reading of "scalar to
character conversion" corroborated by [MSC-01847] §2.17. The exact output
format above is primary-sourced from [USA00309] ("HAL/S-FC User's
Manual") §6.1.3 and §8.2 rules 13–14 — see `STATUS.md` for the full
citation and page references. No verbatim operand-word (bit-level)
prose transcribed yet.
