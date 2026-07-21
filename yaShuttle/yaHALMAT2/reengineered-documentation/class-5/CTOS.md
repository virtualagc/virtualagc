# CTOS

**Mnemonic:** CTOS

**Opcode:** 0x541

**Confidence:** High

## Behavioral Description

Character to scalar conversion. Converts a character-string operand to
its scalar (floating-point) numeric value (presumably parsing the string
as a decimal literal). Classed under Class 5 (scalar) because HALMAT
classes conversion operators by their *result* type — see
[BTOS](BTOS.md) for the general pattern.

## Usage Context

Emitted for the HAL/S built-in shaping function `SCALAR(...)` applied to
a CHARACTER argument, and presumably wherever a character value is
otherwise coerced to scalar.

## Confirmed Input Format

Per [USA00309] §6.1.2/§8.2 rule 16 — same standard input formats as
[CTOI](../class-6/CTOI.md) (whole-number or `ddd.ddddE±dd`/`B±dd`/`H±dd`
floating-point forms; see that file for the full detail). Unlike
INTEGER, SCALAR has no rounding step — the string converts directly to
its floating-point value.

## Unresolved Questions

- Exact error behavior for non-conforming input strings is unconfirmed —
  see [CTOI](../class-6/CTOI.md)'s identical caveat.

## Source Analysis & Reliability

Opcode (0x541) confirmed primary-source: element 1 of the `XBTOS(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
**Also empirically confirmed** this session: compiling `S1 = SCALAR(C1);`
(C1 a CHARACTER(4) variable) with `HALSFC --parms="LSTALL"` produced
`HALMAT: 541(1),0,0` at exactly this opcode — see `STATUS.md`'s
"Empirical Verification" section. Not present in [MSC-01847] (a genuinely
new find for HAL/S). Input-format rules primary-sourced from [USA00309]
§6.1.2/§8.2 — see `STATUS.md`.
