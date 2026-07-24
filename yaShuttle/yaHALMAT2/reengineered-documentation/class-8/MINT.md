# MINT

**Mnemonic:** MINT

**Opcode:** 0x861

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
- **The predecessor-language "OFFSET" operand form: investigated
  (Maintenance phase), still no confirmed real-HAL/S trigger.** The
  "(or OFFSET)" mention above traces to the HAL 1971 instruction only —
  never independently confirmed for HAL/S. Compile-probed both
  plausible real triggers: `ARRAY(n) VECTOR(m) INITIAL(uniform-value)`
  compiles to a plain-`SYT` `VINT`/`MINT` wrapped in
  [IDLP](../class-0/IDLP.md)/[DLPE](../class-0/DLPE.md) replay (no
  `OFFSET` involved); `ARRAY(n) VECTOR(m) INITIAL(v1,v2,...)` with
  distinct per-element values compiles to [STRI](STRI.md) + repeated
  [SINT](SINT.md) with `OFFSET` addressing across the flattened element
  run (also not `MINT`/`VINT`) — matching this file's own note above
  that per-element initialization uses repeated `SINT`, not `MINT`.
  `MINT`/`VINT` never appeared with anything but `QUAL`=`SYT` in either
  trace. `yaHALMAT2`'s `OP_MINT`/`OP_VINT` still fails loudly on a
  non-`SYT` first operand — no primary-source or empirical basis exists
  to implement against yet.

## Source Analysis & Reliability

Opcode (0x861) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-109); no page content for MINT's own HAL/S description (target p. 87) is
present in the available partial copy.

Behavioral description drawn from [MSC-01847] p. 2-40, describing the
identically-numbered-within-its-scheme predecessor-language instruction
(HAL 1971 opcode 0x861). See [STRI](STRI.md)'s Source Analysis section for
the general basis of this cross-language inference.
