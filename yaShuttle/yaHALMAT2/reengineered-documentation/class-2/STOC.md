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

**Phase 3 follow-up — internal inconsistency found, not yet resolved
against [USA00309] itself**: this file's own two claims don't agree.
"14 characters" total, with `s`(1) + `d`(1) + `.`(1) + `E`(1) + sign(1)
+ 2 exponent digits = 7 fixed characters, leaves exactly **7** fractional
digits for single precision (23 total - 7 fixed = 16 for double) — not
the "8"/"17" stated in the field-by-field description just above. Given
a real compiled `SADD` result (`1.5 + 2.25 = 3.75`) was cross-checked
against the reference `yaHALMAT` emulator's own `WRITE` output this
session and it printed `" 3.7500000E+00"` — 14 characters, 7 fractional
digits, **and** a leading nonzero digit (standard normalized scientific
notation, not the "always leading zero" reading this file's zero-value
worked example (`" 0.00000000E+00"`, itself 15 characters as written)
suggested) — `yaHALMAT2`'s implementation (`value.c`) now follows the
7/16-fractional-digit, standard-normalized-leading-digit convention,
matching the reference tool and this file's own total-width claim. This
hasn't been independently re-verified against [USA00309] §6.1.3's actual
text yet (not available in this project's extracted sources this
session) — flagged here rather than silently changed, since the
reference tool is generally not treated as authoritative in this
project (see `YERRORS.md` for two confirmed bugs found in it elsewhere).
If [USA00309] is consulted directly in a future session, re-verify
against its primary text rather than trusting this note indefinitely.

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
