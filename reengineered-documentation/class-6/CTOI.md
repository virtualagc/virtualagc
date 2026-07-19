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

- Exact error behavior for a string that is *not* in one of the standard
  input formats (§8.2 rule 16 just says conversion "can take place only
  if" the format matches, implying failure/error otherwise, but the
  precise error condition isn't spelled out here) is unconfirmed.
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
