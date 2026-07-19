# VDOT

**Mnemonic:** VDOT
**Opcode:** 0x58E
**Confidence:** High

## Behavioral Description

Vector dot product. Computes the dot (inner) product of two vector
operands, producing a *scalar* result — classed under Class 5 (scalar)
despite the "V" mnemonic prefix, because HALMAT classes operators by
their result type.

## Usage Context

Emitted for HAL/S expressions using dot-product notation between two
vector operands.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

**Correction to an earlier session's inference**: this project previously
inferred VDOT's HAL/S opcode as 0x581, carried over directly from
[MSC-01847]'s HAL-1971 value. Reading the actual compiler source this
session found `XVDOT BIT(16) INITIAL("058E")` in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. HAL/S's
VDOT is therefore at 0x58E, *not* 0x581.

Behavioral description is a straightforward reading of "vector dot
product" corroborated by [MSC-01847] §2.19–2.20; no verbatim operand-word
prose transcribed yet.
