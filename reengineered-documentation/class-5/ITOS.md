# ITOS

**Mnemonic:** ITOS
**Opcode:** 0x5C1
**Confidence:** High

## Behavioral Description

Integer to scalar conversion. Converts an integer operand to its scalar
(floating-point) representation. Classed under Class 5 (scalar) because
HALMAT classes conversion operators by their *result* type — see
[BTOS](BTOS.md) for the general pattern.

## Usage Context

Emitted wherever an integer value must be converted to scalar, e.g. in
mixed-type arithmetic expressions combining INTEGER and SCALAR operands.

## Confirmed Runtime Behavior

Per [USA00309] §8.2 rule 9: conversion is performed by first converting
the integer value to a **double**-precision scalar retaining all
significant digits; if the final result needs to be single-precision,
the standard double-to-single scalar conversion (see
[STOS](STOS.md)/[MTOM](../class-3/MTOM.md)'s rule 7 — truncate the
right-most 32 bits of the double-precision mantissa) is then applied to
that intermediate value. I.e. integer→scalar conversion never loses
precision directly; any precision loss is a side effect of a *subsequent*
double→single narrowing step.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Source Analysis & Reliability

Opcode (0x5C1) confirmed primary-source: element 5 of the `XBTOS(5)`
array in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 ITOS opcode (0x5C1) exactly.

Behavioral description is a straightforward reading of "integer to
scalar conversion" corroborated by [MSC-01847] §2.20. Precise conversion
mechanics primary-sourced from [USA00309] §8.2 rule 9 — see `STATUS.md`.
No verbatim operand-word (bit-level) prose transcribed yet.
