# NNEQ

**Mnemonic:** NNEQ
**Opcode:** 0x055
**Confidence:** High

## Behavioral Description

NAME (pointer) not-equal comparison. Implements the `¬=`/`NOT=` operator
in a `NAME` comparison ([USA003087] §28.8) — the negated counterpart of
[NEQU](NEQU.md).

## Usage Context

Emitted for the `¬=`/`NOT=` form of a `NAME` comparison.

## Operand-Word Format (confirmed empirically)

Two operands, both `SYT`-qualified: `DATA`=symbol-table index of each
compared `NAME` data item — same layout as [NEQU](NEQU.md). Confirmed
by compiling `IF NAME(NS1) ¬= NAME(NS2) THEN ...;` with
`HALSFC --parms="LSTALL"`, which produced `HALMAT: 055(2),0,0` with the
same two-`SYT`-operand structure as [NEQU](NEQU.md)'s confirmed `=` case.

## Unresolved Questions

- Same as [NEQU](NEQU.md): comparison against `NULL` and pointer-arrayness
  comparisons were not separately tested.

## Source Analysis & Reliability

Opcode (0x055) confirmed primary-source: `XNEQU` array element 1 in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Statement/expression syntax
primary-sourced from [USA003087] §28.8 (PDF p. 381ff). Full behavioral
description and operand-word structure confirmed directly against real
compiled HALMAT this session, as part of a systematic sweep of
USA003087 syntax patterns against previously-untested HALMAT opcodes
(direct user suggestion).
