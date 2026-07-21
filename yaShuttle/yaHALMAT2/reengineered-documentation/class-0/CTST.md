# CTST

**Mnemonic:** CTST

**Opcode:** 0x016

**Confidence:** High

## Behavioral Description

"Condition test" — consumes the boolean/relational result of a `DO
WHILE`/`DO UNTIL` loop's condition expression (see [DTST](DTST.md)) and
generates the conditional branch that exits the loop when the condition
fails. Evaluated once per cycle (unlike [DTST](DTST.md), which only fires
once, at loop entry).

## Usage Context

Appears immediately after the code evaluating a `DO WHILE`/`DO UNTIL`
condition, once per loop (at the position re-executed every cycle,
between [DTST](DTST.md)'s test label and the loop body).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the stream position of the comparison instruction
that produced the boolean result, `QUAL`=3=VAC. The opcode line's own
trailing header field carries the same WHILE(`0`)/UNTIL(`1`) polarity
flag as the enclosing [DTST](DTST.md) — see that file for full worked
traces of both forms.

## Unresolved Questions

- Same open question as [DTST](DTST.md) regarding the trailing polarity
  flag's exact bit-level meaning.

## Source Analysis & Reliability

Opcode (0x016) confirmed primary-source: `XCTST BIT(16) INITIAL("016")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DTST](DTST.md)'s Source Analysis for the context of this investigation.
