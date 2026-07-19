# STOQ

**Mnemonic:** STOQ
**Opcode:** 0x1A2
**Confidence:** High

## Behavioral Description

`SUBBIT` pseudo-conversion, scalar argument. Implements HAL/S's `SUBBIT`
pseudo-conversion function ([USA003087] §21.5) for a `SCALAR` argument —
see [ITOQ](ITOQ.md) for the full mechanism (reference vs. assignment
context, the shared `XBTOQ` family). Classed under Class 1 (bit), like
its siblings, because HALMAT groups this family by its bit-string
intermediary rather than by argument type.

## Usage Context

Same as [ITOQ](ITOQ.md) — reference context supplies a source value,
assignment context supplies a receiver, distinguished by a trailing
header flag.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the argument, `QUAL`=1=SYT.
Confirmed by compiling `B1 = SUBBIT(S1);` (`S1` a single-precision
`SCALAR`, `B1` a `BIT(16)`) with `HALSFC --parms="LSTALL"`:

```
HALMAT: 1A2(1),0,0            <- STOQ, trailing field 0 = reference context
          3(1),0,0               <- S1, symbol index 3, QUAL=1=SYT
HALMAT: 101(2),0,0            <- BASN: B1 = <STOQ's VAC result>
L 5,S1 / SLL 5,16 / STH 5,B1     <- loads S1's full 32-bit pattern, keeps the upper 16
                                     bits (truncating to fit the 16-bit receiver B1)
```

The truncation-on-store (`SLL 5,16` keeping only the upper half before
the 16-bit `STH`) matches [USA003087] §21.5's documented "no subscript"
default window width for single-precision `SCALAR` (32 bits) being
truncated to fit a smaller receiving bit string, per the general
bit-string assignment truncation rules (§17.5).

## Unresolved Questions

- The assignment-context form (`SUBBIT(S1) = ...;`) was not directly
  tested for STOQ specifically (confirmed for [ITOQ](ITOQ.md) instead) —
  expected to be identical in shape by direct analogy.
- Subscripted forms and `DOUBLE`-precision arguments were not tested.

## Source Analysis & Reliability

Opcode (0x1A2) confirmed primary-source: `XBTOQ(5)` array element 4 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Statement syntax and
behavioral description confirmed directly against real compiled HALMAT
this session — see [ITOQ](ITOQ.md)'s Source Analysis for the full
account of how this opcode family was resolved (via a compiler-source
grep for `XBTOQ` leading to `ENDSUBBI.xpl`'s `END_SUBBIT_FCN`).
