# STOI

**Mnemonic:** STOI
**Opcode:** 0x6A1
**Confidence:** High

## Behavioral Description

Scalar to integer conversion. Converts a scalar (floating-point) operand
to its integer representation (presumably truncating or rounding — exact
rule unconfirmed). Classed under Class 6 (integer) because HALMAT classes
conversion operators by their *result* type — see [BTOI](BTOI.md) for the
general pattern.

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

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether a non-integral (fractional) in-range scalar is truncated,
  rounded, or also triggers the error condition is not fully
  disambiguated by [USA00309] rule 10's wording alone.

## Source Analysis & Reliability

Opcode (0x6A1) confirmed primary-source: element 4 of the `XBTOI(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 STOI opcode (0x6A1) exactly.

Behavioral description is a straightforward reading of "scalar to integer
conversion" corroborated by [MSC-01847] §2.21. Error-condition behavior
is primary-sourced from [USA00309] §8.2 rule 10 — see `STATUS.md` for the
full citation. No verbatim operand-word (bit-level) prose transcribed
yet.
