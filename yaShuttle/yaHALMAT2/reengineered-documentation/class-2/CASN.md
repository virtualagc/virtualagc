# CASN

**Mnemonic:** CASN

**Opcode:** 0x201

**Confidence:** High

## Behavioral Description

Character assign. Assigns the character-string operand specified by one
operand to the character variable specified by another, following the
general two-operand assign pattern shared by every type's `xASN` operator
(compare [BASN](../class-1/BASN.md), [MASN](../class-3/MASN.md),
[VASN](../class-4/VASN.md), [SASN](../class-5/SASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a CHARACTER
variable.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `DATA`=symbol-table index,
`QUAL`=1=SYT; operand 2 = **receiver**, `DATA`=its symbol-table index,
`QUAL`=1=SYT — the same source-first, receiver-second order confirmed
for the rest of the `xASN` family (see [SASN](../class-5/SASN.md) for
the general account). Confirmed by compiling `C1 = C2;` (both
`CHARACTER(10)`) with `HALSFC --parms="LISTING2,LSTALL"`:

```
HALMAT: 201(2),0,0        <- CASN
          5(1),0,0          <- op 1: C2, symbol index 5, QUAL=1=SYT (source)
          4(1),0,0          <- op 2: C1, symbol index 4, QUAL=1=SYT (receiver)
```

## Unresolved Questions

- How fixed-length vs. VARYING character assignment (including truncation/
  padding) is distinguished at this instruction, if at all, is unconfirmed.

## Source Analysis & Reliability

Opcode (0x201) confirmed primary-source: element 2 of the `XXASN` array in
`PASS1.PROCS/##DRIVER.xpl` (value `"0201"`) — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 CASN opcode (0x201) exactly.
Operand-word structure confirmed directly against real compiled HALMAT
this session via a direct `unHALMAT.py` binary read.

Behavioral description is a straightforward reading of "character assign"
corroborated by [MSC-01847] §2.17; no verbatim operand-word prose
transcribed yet.
