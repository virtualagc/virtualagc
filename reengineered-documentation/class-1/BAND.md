# BAND

**Mnemonic:** BAND

**Opcode:** 0x102

**Confidence:** High

## Behavioral Description

Bit-string AND. Computes the bitwise logical AND of two bit-string
operands, producing a bit-string result (referenced by later instructions
as a VAC — see [HALMAT.md](../HALMAT.md#word-format)).

## Usage Context

Emitted for HAL/S expressions using the bit-string AND operator.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).
- Whether bit-strings of unequal length are padded/truncated at this
  instruction or handled earlier in expression compilation is unconfirmed.

## Source Analysis & Reliability

Opcode (0x102) confirmed primary-source: `XBAND BIT(16) INITIAL("0102")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 BAND opcode (0x102) exactly.

Behavioral description is a straightforward reading of "bit-string and"
corroborated by [MSC-01847] §2.16; no verbatim operand-word prose
transcribed yet.
