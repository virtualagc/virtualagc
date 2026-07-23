# MSDV

**Mnemonic:** MSDV

**Opcode:** 0x3A6

**Confidence:** High

## Behavioral Description

Matrix divide-by-scalar. Computes the elementwise quotient of a matrix
operand divided by a scalar operand, producing a matrix result.

## Usage Context

Emitted for HAL/S expressions using `/` between a matrix and a scalar
operand. Named explicitly (alongside VSDV) in the Optimizer HALMAT
inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Unresolved Questions

- HAL/S operand-word format is unconfirmed; see [STRI](../class-8/STRI.md).

## Confirmed Runtime Behavior

[USA003090] Appendix C error 25 ("VECTOR/MATRIX division by zero"):
result is the original matrix, unchanged — not a runtime abort. Shares
its implementation (and this same fixup) with [VSDV](../class-4/VSDV.md)
in `interp.c`'s combined `OP_MSPR`/`OP_MSDV`/`OP_VSPR`/`OP_VSDV` case.
Implemented in a later session; see `STATUS.md`'s Class 0 section.
Consults [ERON](../class-0/ERON.md)'s registered `ON ERROR` handler
table before applying the fixup (follow-up session) — a `GO TO` handler
registered for error 4:25 redirects execution there instead.

## Source Analysis & Reliability

Opcode (0x3A6) confirmed primary-source: part of the `XMSDV(2)` array
(element 0) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 MSDV opcode (0x3A6) exactly,
and matches [IR-60-5] A-113's mnemonic.

Behavioral description is a straightforward reading of "matrix
divide-by-scalar" corroborated by [MSC-01847] §2.18/2.19; no verbatim
operand-word prose transcribed yet.
