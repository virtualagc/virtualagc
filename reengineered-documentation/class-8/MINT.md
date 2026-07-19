# MINT

**Mnemonic:** MINT

**Opcode:** 0x61

**Confidence:** High

## Behavioral Description

Matrix initialize. Initializes every element of the specified matrix
operand with a single literal value.

In the predecessor language HAL (1971), the analogous instruction (there
opcode 0x861) takes a symbol-table (or OFFSET) operand naming the matrix,
a literal-table pointer for the fill value, and a sign bit (in the
instruction's TAG2-equivalent field) indicating whether the literal must
be negated before use.

## Usage Context

Appears within a "static bypass block" alongside the other initialization
operators; see [BINT](BINT.md) for the general pattern. Per the
predecessor-language documentation, per-element (rather than uniform)
matrix initialization instead uses repeated [SINT](SINT.md) instructions,
one per element.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](STRI.md).

## Source Analysis & Reliability

Opcode (0x61) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for MINT's own HAL/S description (target p. 87) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-40, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x861). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
