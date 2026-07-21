# MTRA

**Mnemonic:** MTRA

**Opcode:** 0x329

**Confidence:** High

## Behavioral Description

Matrix transpose. Computes the transpose of a single matrix operand
(swapping row and column dimensions), producing a matrix result.

## Usage Context

Emitted for HAL/S expressions using the transpose operator (`*` postfix
notation on a matrix/vector operand, e.g. `M*`). Unary — one source
operand.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether/how the result's swapped dimensions are carried in the
  instruction versus derived from the symbol table is unconfirmed.

## Source Analysis & Reliability

Opcode (0x329) confirmed primary-source: `XMTRA BIT(16) INITIAL("0329")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 MTRA opcode (0x329) exactly.

Behavioral description is a straightforward reading of "matrix transpose"
corroborated by [MSC-01847] §2.18/2.19; no verbatim operand-word prose
transcribed yet.
