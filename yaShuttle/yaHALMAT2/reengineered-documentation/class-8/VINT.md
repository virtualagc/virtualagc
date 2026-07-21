# VINT

**Mnemonic:** VINT

**Opcode:** 0x881

**Confidence:** High

## Behavioral Description

Vector initialize. Initializes every element of the specified vector
operand with a single literal value.

In the predecessor language HAL (1971), the analogous instruction (there
opcode 0x881) takes a symbol-table (or OFFSET) operand naming the vector,
a literal-table pointer for the fill value, and a sign bit indicating
whether the literal must be negated before use — structurally identical to
[MINT](MINT.md), differing only in operand type.

## Usage Context

Appears within a "static bypass block" alongside the other initialization
operators; see [BINT](BINT.md) for the general pattern. Per-element (rather
than uniform) vector initialization instead uses repeated [SINT](SINT.md)
instructions.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](STRI.md).

## Source Analysis & Reliability

Opcode (0x881) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for VINT's own HAL/S description (target p. 87) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-41, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x881). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
