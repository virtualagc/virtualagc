# VASN

**Mnemonic:** VASN
**Opcode:** 0x401
**Confidence:** High

## Behavioral Description

Vector assign. Assigns the vector operand specified by one operand to the
vector variable specified by another, following the general two-operand
assign pattern shared by every type's `xASN` operator (compare
[BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[MASN](../class-3/MASN.md), [SASN](../class-5/SASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a VECTOR
variable. Named explicitly in the Optimizer HALMAT inline-vector/matrix-
loop note in [HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from
[IR-60-5] A-113, where arrayed VASN operations are expected to be
bracketed by [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `QUAL`=3=VAC when the
right-hand side is an expression; operand 2 = **receiver**, `DATA`=its
symbol-table index, `QUAL`=1=SYT. **Order corrected in a later session**
via a direct `unHALMAT.py` binary read of `V3 = V1 + V2` (compiled with
`HALSFC --parms="LISTING2,LSTALL"`) — an earlier reading had receiver
first, source second; same correction applied to
[SASN](../class-5/SASN.md)/[IASN](../class-6/IASN.md)/[MASN](../class-3/MASN.md),
see [SASN](../class-5/SASN.md) for the general account.

## Unresolved Questions

- None remaining for the base vector-assign case.

## Source Analysis & Reliability

Opcode (0x401) confirmed primary-source: `XVASN` (base of an array) in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 VASN opcode (0x401) exactly, and matches
[IR-60-5] A-113's mnemonic. Operand-word format independently confirmed
against real compiled HALMAT in an earlier session; operand order
corrected in a later session via a direct `unHALMAT.py` binary read (see
Operand-Word Format above).

Behavioral description is a straightforward reading of "vector assign"
corroborated by [MSC-01847] §2.19 (Vector Operations); no verbatim
operand-word prose transcribed yet.
