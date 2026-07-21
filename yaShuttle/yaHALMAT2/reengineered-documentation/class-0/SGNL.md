# SGNL

**Mnemonic:** SGNL

**Opcode:** 0x035

**Confidence:** High

## Behavioral Description

`SIGNAL` statement — a real-time programming statement ([USA003087]
§24.4, referenced from §13.5's list of real-time features) causing an
`EVENT` data item's value to become transiently `TRUE` (or, for a
latched event, to be transiently complemented).

## Usage Context

Emitted wherever a `SIGNAL var;` statement occurs, `var` being an `EVENT`
data item (see [USA003087] §24.4 for the declaration and array-
subscripting rules).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the `EVENT` variable being
signaled, `QUAL`=1=SYT. Confirmed by compiling `SIGNAL EV1;` with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 035(1),0,0          <- SGNL
          2(1),0,0            <- EV1, symbol index 2, QUAL=1=SYT
SVC 0,12(0,9)                 <- runtime signal routine
```

## Unresolved Questions

- Arrayed/subscripted `EVENT` targets (per §24.4's "must possess array
  subscripting causing the selection of one and only one array element")
  were not tested — only a plain scalar `EVENT` variable.
- Whether `SET`/`RESET` (the companion statements for latched events,
  §24.4) share this same opcode or use a distinct one is unresolved —
  not tested this session.

## Source Analysis & Reliability

Opcode (0x035) confirmed primary-source: `XSGNL BIT(16) INITIAL("035")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog expected (multitasking postdates HAL 1971).
Statement syntax primary-sourced from [USA003087] §24.4 (referenced via
§13.5, PDF p. 168). Full behavioral description and operand-word
structure confirmed directly against real compiled HALMAT this session,
prompted by direct user suggestion that this opcode relates to HAL/S's
real-time programming statements.
