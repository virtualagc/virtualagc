# NEQU

**Mnemonic:** NEQU
**Opcode:** 0x056
**Confidence:** High

## Behavioral Description

NAME (pointer) equal comparison. Implements the `=` operator in a `NAME`
comparison ([USA003087] §28.8): `NAME(L) = NAME(R)` (or comparisons
against `NULL`), TRUE if both sides generate the same pointer value.

## Usage Context

Emitted for the `=` form of a `NAME` comparison, used the same way any
other comparison operator is (e.g. as the condition of an `IF`). See
[NNEQ](NNEQ.md) for the `¬=`/`NOT=` counterpart.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`-qualified: `DATA`=symbol-table index of each
compared `NAME` data item. Confirmed by compiling `IF NAME(NS1) =
NAME(NS2) THEN ...;` with `HALSFC --parms="LSTALL"`:

```
HALMAT: 056(2),0,0
          4(1),0,0       <- NS1, symbol index 4, QUAL=1=SYT
          5(1),0,0       <- NS2, symbol index 5, QUAL=1=SYT
LH 5,NS1 / LH 2,NS2 / CR 5,2   <- loads both pointer values and compares the registers directly
```

## Unresolved Questions

- Comparison against `NULL` specifically (rather than another `NAME`
  variable) was not tested — presumably an `IMD`-qualified operand with
  `DATA`=0, by analogy with [NINT](../class-8/NINT.md)'s confirmed
  NULL-initialization encoding, but unconfirmed for NEQU.
- Pointer-arrayness comparisons ([USA003087] §28.8's "Pointer Arrayness
  in NAME Comparisons") were not tested.

## Source Analysis & Reliability

Opcode (0x056) confirmed primary-source: `XNEQU` array element 0 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Statement/expression syntax
primary-sourced from [USA003087] §28.8 (PDF p. 381ff). Full behavioral
description and operand-word structure confirmed directly against real
compiled HALMAT this session, as part of a systematic sweep of
USA003087 syntax patterns against previously-untested HALMAT opcodes
(direct user suggestion).
