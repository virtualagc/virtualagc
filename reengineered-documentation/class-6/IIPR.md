# IIPR

**Mnemonic:** IIPR
**Opcode:** 0x6CD
**Confidence:** High

## Behavioral Description

Integer multiply. Computes the arithmetic product of two integer
operands.

## Usage Context

Emitted for HAL/S expressions multiplying two integer operands —
via **juxtaposition** (e.g. `I3 = I1 I2`), not `*`, which is reserved for
vector cross product and produces a compile error between two integers
(see `STATUS.md`'s "Empirical Verification" section). Under Optimizer
HALMAT, the optimizer may itself generate an IIPR instruction as part of
a subscript-address computation, with TAG=1 distinguishing that case —
see [HALMAT.md](../HALMAT.md#optimizer-halmat).

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`- or `VAC`-qualified: operand 1 = first factor,
operand 2 = second factor. No destination operand — the product is
consumed by a following [IASN](../class-6/IASN.md) via a `VAC`-qualified
operand. Confirmed by compiling `I3 = I1 I2` with
`HALSFC --parms="LSTALL"`.

## Unresolved Questions

- Overflow behavior is unconfirmed.

## Source Analysis & Reliability

Opcode (0x6CD) is the most independently-corroborated opcode in this
project: primary-sourced three separate ways — (1) [IR-60-5] A-112's
Optimizer-HALMAT note names the opcode 0x6CD for the "Integer Integer
Product" operator without giving its mnemonic; (2) [MSC-01847]'s HAL-1971
Appendix B/C independently gives the identical opcode 0x6CD for its own
"IIPR"/"integer multiply" instruction, supplying the mnemonic [IR-60-5]
omitted; (3) this session, `PASS1.PROCS/##DRIVER.xpl`'s `XSSPR(1)` array
(element 1, `XIIPR`) confirms both the opcode and mnemonic directly from
the HAL/S-FC compiler source itself — see [##DRIVER.xpl] in `STATUS.md`.
Operand-word format independently confirmed against real compiled HALMAT
this session.

Behavioral description is a straightforward reading of "integer multiply"
corroborated by [MSC-01847] §2.21; no verbatim operand-word prose
transcribed yet.
