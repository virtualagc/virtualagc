# CTOI

**Mnemonic:** CTOI

**Opcode:** 0x641

**Confidence:** High

## Behavioral Description

Character to integer conversion. Converts a character-string operand to
its integer numeric value (presumably parsing the string as a decimal
integer literal). Classed under Class 6 (integer) because HALMAT classes
conversion operators by their *result* type — see [BTOI](BTOI.md) for the
general pattern.

## Usage Context

Emitted for the HAL/S built-in shaping function `INTEGER(...)` applied to
a CHARACTER argument (see [SFST](../class-0/SFST.md) for the general
shaping-function bracketing mechanism), and presumably wherever a
character value is otherwise coerced to integer.

## Confirmed Input Format

Per [USA00309] §6.1.2 ("Input Data Formats") and §8.2 rule 16 (which
cites it): a character string converts to INTEGER (or SCALAR) only if it
is in one of the standard input formats — either a whole-number form
(decimal digits with an optional leading `-`) or a floating-point form
`ddd.ddddE±dd` / `ddd.ddddB±dd` / `ddd.ddddH±dd` (`E`/`B`/`H` selecting
powers of 10, 2, or 16 respectively; unlimited digit counts, though
runtime errors can occur if the value is unrepresentable). For INTEGER
specifically, the parsed representation is rounded to the nearest
integral value. A value with no explicit sign is assumed positive.

## Unresolved Questions

- ~~Exact error behavior for a string that is *not* in one of the
  standard input formats~~ **Resolved** (DB id 55,
  `ctoi_invalid_digit_substring_wrong_result`): confirmed against real
  `gpc` across a 10-case matrix (`159-AGE.hal`'s
  `X = INTEGER(C(7 TO 10));`) that an invalid string converts to `0`,
  and — critically — that validation is **whole-string**, not
  prefix-based: any interior non-blank, non-digit character anywhere
  invalidates the entire conversion (e.g. `"7AAA"`→`0`, not `7` the way
  a `strtod()`-style partial parse would give), and a *leading* blank
  before an otherwise-valid digit also invalidates it (`"  9 "`→`0`, not
  `9`) — only *trailing* blanks after a complete number are tolerated
  (`"7   "`→`7`). `yaHALMAT2`'s own `OP_CTOI`/`OP_CTOS` previously used
  plain `strtod()` (silently prefix-parsing); fixed via a new strict
  `ctoi_parse_scalar()` helper (`interp.c`). This was only independently
  reconfirmed for `CTOI`/`INTEGER` specifically — `CTOS`/`SCALAR` is
  assumed to share it per this doc's own "same parse" framing (§8.2 rule
  16 covers both), not separately verified against real `gpc`.
- HAL/S operand-word format details beyond the basic single-operand
  pattern (see Source Analysis) are unconfirmed.

## Source Analysis & Reliability

Opcode (0x641) confirmed primary-source: element 1 of the `XBTOI(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
**Also empirically confirmed** this session: compiling
`I1 = INTEGER(C1);` (C1 a CHARACTER(4) variable) with
`HALSFC --parms="LSTALL"` produced `HALMAT: 641(1),0,0` at exactly this
opcode — see `STATUS.md`'s "Empirical Verification" section. Not present
in [MSC-01847] (a genuinely new find for HAL/S, absent from the HAL-1971
predecessor's instruction set). Input-format rules primary-sourced from
[USA00309] §6.1.2/§8.2 — see `STATUS.md`.
