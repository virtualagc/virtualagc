# CTOQ

**Mnemonic:** CTOQ

**Opcode:** 0x142

**Confidence:** High

## Behavioral Description

`SUBBIT` pseudo-conversion, character argument. Implements HAL/S's
`SUBBIT` pseudo-conversion function ([USA003087] §21.5) for a `CHARACTER`
argument — see [ITOQ](ITOQ.md) for the full shared mechanism (reference
vs. assignment context, the `XBTOQ` family). Unlike
[BTOQ](BTOQ.md)/[ITOQ](ITOQ.md) (plain register loads), the
`CHARACTER`-argument case compiles to a runtime-library call (`#QCSLD`),
consistent with `CHARACTER`'s variable/non-register-resident internal
representation.

## Usage Context

Confirmed identical to [ITOQ](ITOQ.md)/[STOQ](STOQ.md): reference context
supplies a source value, assignment context supplies a receiver.
Confirmed by compiling `B3 = SUBBIT(C1);` (`C1` a `CHARACTER(10)`) with
`HALSFC --parms="LSTALL"`.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the argument, `QUAL`=1=SYT.
Trailing header field `0` for reference context, `1` for assignment
context — **now confirmed directly** (previously only inferred by
analogy with [ITOQ](ITOQ.md)) by compiling
`SUBBIT(C1) = BIN'1111000011110000';`:

```
HALMAT: 142(1),0,0            <- CTOQ, trailing field 0 = reference context
          4(1),0,0                <- C1, symbol index 4, QUAL=1=SYT
LA 2,C1 / SCAL 0,#QCSLD           <- runtime routine #QCSLD loads C1's bits
HALMAT: 101(2),0,0            <- BASN: B3 = <CTOQ's VAC result>

HALMAT: 142(1),1,0            <- CTOQ, trailing field 1 = assignment context
          4(1),0,0                <- C1, symbol index 4, QUAL=1=SYT (the receiver)
HALMAT: 101(2),0,0            <- BASN: <CTOQ's VAC result> = the literal
L 4,=F'61680' / LA 2,C1 / SCAL 0,#QCSST   <- runtime routine #QCSST stores the literal's
                                              bits into C1 (the store-side counterpart of
                                              the reference-context #QCSLD load)
```

## Unresolved Questions

- Exactly which bits `#QCSLD`/`#QCSST` read/write in a `CHARACTER` value
  by default (e.g. the first N bits of the character data, matching
  [USA003087] §21.5's general "no subscript" default-window rule) is not
  independently decoded from the trace alone.
- Subscripted forms were not tested.

## Source Analysis & Reliability

Opcode (0x142) confirmed primary-source: `XBTOQ(5)` array element 1 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Resolved in an earlier session
by grepping the full `PASS.REL32V0` compiler source tree for every site
referencing `XBTOQ`, which led to `PASS1.PROCS/ENDSUBBI.xpl`'s
`END_SUBBIT_FCN` procedure, directly identifying the `SUBBIT`
pseudo-conversion construct ([USA003087] §21.5). Full behavioral
description and operand-word structure now confirmed directly against
real compiled HALMAT this session (`B3 = SUBBIT(C1);`), resolving the
prior "Medium-High, inferred by analogy" state.
