# MASN

**Mnemonic:** MASN

**Opcode:** 0x301

**Confidence:** High

## Behavioral Description

Matrix assign. Assigns the matrix operand specified by one operand to the
matrix variable specified by another, following the general two-operand
assign pattern shared by every type's `xASN` operator (compare
[BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[VASN](../class-4/VASN.md), [SASN](../class-5/SASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a MATRIX
variable. Under Optimizer HALMAT, arrayed MASN operations are expected to
be bracketed by [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md)
arrayness-specifier pairs — MASN is explicitly named in the Optimizer
HALMAT inline-vector/matrix-loop note in
[HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from [IR-60-5] A-113.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `QUAL`=3=VAC when the
right-hand side is an expression; operand 2 = **receiver**, `DATA`=its
symbol-table index, `QUAL`=1=SYT. **Order corrected in a later session**
via a direct `unHALMAT.py` binary read of `M3 = M1 + M2` (compiled with
`HALSFC --parms="LISTING2,LSTALL"`) — an earlier reading had receiver
first, source second; same correction applied to
[SASN](../class-5/SASN.md)/[IASN](../class-6/IASN.md)/[VASN](../class-4/VASN.md),
see [SASN](../class-5/SASN.md) for the general account.

## Unresolved Questions

- None remaining for the base matrix-assign case.

## Source Analysis & Reliability

Opcode (0x301) confirmed primary-source: `XMASN` (base of the `XXASN`
array) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`.
Matches [MSC-01847]'s HAL-1971 MASN opcode (0x301) exactly, and matches
[IR-60-5] A-113's mnemonic (opcode not given there). Operand-word format
independently confirmed against real compiled HALMAT in an earlier
session; operand order corrected in a later session via a direct
`unHALMAT.py` binary read (see Operand-Word Format above).

Behavioral description is a straightforward reading of "matrix assign"
corroborated by [MSC-01847] §2.18/2.19 (Matrix Operations); no verbatim
operand-word prose transcribed yet.
