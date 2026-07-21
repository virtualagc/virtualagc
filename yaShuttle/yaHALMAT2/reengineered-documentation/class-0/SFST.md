# SFST

**Mnemonic:** SFST

**Opcode:** 0x045

**Confidence:** High

## Behavioral Description

Start of shaping function specification. Marks the beginning of the
HALMAT text specifying the invocation of a "shaping function" — a type
conversion or reshaping pseudo-function such as `BIT(...)`, `CHARACTER(...)`,
`VECTOR(...)`, `MATRIX(...)`, `INTEGER(...)`, `SCALAR(...)`, or the
`CONTENT` pseudo-variable. Carries the current function-nesting level (for
shaping functions nested inside other shaping functions) and an internal
flow number shared with the related [BFNC](BFNC.md)-or-equivalent
invocation instruction.

## Usage Context

Brackets, together with [SFAR](SFAR.md) (argument separator) and
[SFND](SFND.md) (end marker), the HALMAT text for each argument of a
shaping-function invocation. See the worked examples in [MSC-01847]
§3.6.3 and §3.7.2–3.7.3 (SIN/COS/TAN, DET, BIT/CHAR, VECTOR/MATRIX,
CONTENT usage).

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- The relationship between SFST/SFAR/SFND and [BFNC](BFNC.md) (HAL/S
  opcode 0x04A, "built-in function," per [IR-60-5] A-112's Optimizer-HALMAT
  SINCOS note) is presumed but not confirmed — in the predecessor language
  the analogous invocation instruction is FUNC, not a BFNC-named opcode.

## Source Analysis & Reliability

Opcode (0x045) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for SFST's own HAL/S description (target p. 59) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-17 ("2.14 Auxiliary
SHAPING FUNCTION SPECIFIERS"), describing the identically-named
predecessor-language instruction (HAL 1971 opcode 0x04A, differing from
HAL/S's 0x045). See [STRI](../class-8/STRI.md)'s Source Analysis section
for the general basis of this cross-language inference.
