# BASN

**Mnemonic:** BASN

**Opcode:** 0x101

**Confidence:** High

## Behavioral Description

Bit-string assign. Assigns the bit-string operand specified by one operand
to the bit-string variable specified by another. The operand count and
qualifier structure follow the general two-operand assign pattern shared
by every type's `xASN` operator (compare [MASN](../class-3/MASN.md),
[VASN](../class-4/VASN.md), [SASN](../class-5/SASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a BIT variable.
Under Optimizer HALMAT, arrayed BASN operations (assigning to/from an
arrayed BIT variable) are expected to be bracketed by
[ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md) arrayness-specifier
pairs, per the general pattern described in
[HALMAT.md](../HALMAT.md#optimizer-halmat).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `DATA`=symbol-table index (or
`VAC`/`LIT` for an expression/literal source), operand 2 = **receiver**,
`DATA`=its symbol-table index, `QUAL`=1=SYT — the same source-first,
receiver-second order confirmed for the rest of the `xASN` family (see
[SASN](../class-5/SASN.md) for the general account of how this order was
established via a direct `unHALMAT.py` binary read). Confirmed by
compiling `B1 = B2;` (both `BIT(16)`) with
`HALSFC --parms="LISTING2,LSTALL"`:

```
HALMAT: 101(2),0,0        <- BASN
          2(1),0,0          <- op 1: B2, symbol index 2, QUAL=1=SYT (source)
          3(1),0,0          <- op 2: B1, symbol index 3, QUAL=1=SYT (receiver)
```

## Unresolved Questions

- Exact qualifier encoding for arrayed/subscripted BIT operands is
  unconfirmed; see [STRI](../class-8/STRI.md) for the general caveat
  about the predecessor language's incompatible physical instruction
  encoding.

## Source Analysis & Reliability

Opcode (0x101) confirmed primary-source: `XBASN` is not itself a separate
declared constant, but appears as element 1 of the `XXASN` array in the
HAL/S-FC compiler source (`PASS1.PROCS/##DRIVER.xpl`, value `"0101"`) —
see [##DRIVER.xpl] in `STATUS.md`. This matches [MSC-01847]'s HAL-1971
BASN opcode (0x101) exactly. Operand-word structure confirmed directly
against real compiled HALMAT this session via a direct `unHALMAT.py`
binary read.

Behavioral description is a straightforward reading of "bit-string
assign" corroborated by [MSC-01847] §2.16 (p. 2-19 area); no verbatim
HAL/S or HAL-1971 operand-word prose has been transcribed for this
specific instruction in this project yet.
