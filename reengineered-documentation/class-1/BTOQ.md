# BTOQ

**Mnemonic:** BTOQ
**Opcode:** 0x122
**Confidence:** High

## Behavioral Description

`SUBBIT` pseudo-conversion, bit-string argument. Implements HAL/S's
`SUBBIT` pseudo-conversion function ([USA003087] §21.5) for a `BIT
STRING` (or `BOOLEAN`) argument — see [ITOQ](ITOQ.md) for the full shared
mechanism (reference vs. assignment context, the `XBTOQ` family). Now
directly confirmed rather than inferred by analogy: a bit-string
argument's `SUBBIT` reference is indeed close to a no-op component-copy
(`STH 5,B2`, a plain register store, no runtime call), consistent with
the "self-type" slot of the family.

## Usage Context

Confirmed identical to [ITOQ](ITOQ.md)/[STOQ](STOQ.md): reference context
supplies a source value, assignment context supplies a receiver.
Confirmed by compiling `B2 = SUBBIT(B1);` (both `BIT(16)`) with
`HALSFC --parms="LSTALL"`.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the argument, `QUAL`=1=SYT.
Trailing header field `0` for reference context, `1` for assignment
context — **now confirmed directly** (previously only inferred by
analogy with [ITOQ](ITOQ.md)) by compiling
`SUBBIT(B1) = BIN'1111000011110000';`:

```
HALMAT: 122(1),0,0            <- BTOQ, trailing field 0 = reference context
          2(1),0,0                <- B1, symbol index 2, QUAL=1=SYT
HALMAT: 101(2),0,0            <- BASN: B2 = <BTOQ's VAC result>
STH 5,B2                          <- B1's bit pattern (already in a register) stored to B2

HALMAT: 122(1),1,0            <- BTOQ, trailing field 1 = assignment context
          2(1),0,0                <- B1, symbol index 2, QUAL=1=SYT (the receiver)
HALMAT: 101(2),0,0            <- BASN: <BTOQ's VAC result> = the literal
LHI 5,-3856 / STH 5,B1            <- the literal's bit pattern stored directly into B1
```

## Unresolved Questions

- Subscripted forms were not tested.

## Source Analysis & Reliability

Opcode (0x122) confirmed primary-source: `XBTOQ(5)` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Resolved in an earlier session
by grepping the full `PASS.REL32V0` compiler source tree for every site
referencing `XBTOQ`, which led to `PASS1.PROCS/ENDSUBBI.xpl`'s
`END_SUBBIT_FCN` procedure, directly identifying the `SUBBIT`
pseudo-conversion construct ([USA003087] §21.5). Full behavioral
description and operand-word structure now confirmed directly against
real compiled HALMAT this session (`B2 = SUBBIT(B1);`), resolving the
prior "Medium-High, inferred by analogy" state.
