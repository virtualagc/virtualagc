# DSMP

**Mnemonic:** DSMP
**Opcode:** 0x013
**Confidence:** High

## Behavioral Description

"Do simple" — header for a plain, unconditional `DO; ... END;` statement
group ([USA003087] §9, the basic compound-statement form used to bracket
multiple statements for conditional execution, e.g. as the "true part" of
an `IF`). Marks the start of the group; carries no operands and generates
no code of its own — it's purely a bracketing marker, closed by
[ESMP](ESMP.md).

## Usage Context

Emitted for the opening of any `DO; ... END;` group that isn't a `WHILE`/
`UNTIL`/`FOR`/`CASE` loop — i.e. a group used only for statement grouping
(conditional execution under `IF`, or simply to scope a sequence of
statements).

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling:

```
DO;
    S1 = 1;
END;
```

with `HALSFC --parms="LSTALL"`, which produced `HALMAT: 013(1),0,0` with
no following operand line, generating no machine code of its own — the
body's own statements follow directly. See [ESMP](ESMP.md) for the
closing half.

## Unresolved Questions

- None for the base case.

## Source Analysis & Reliability

Opcode (0x013) confirmed primary-source: `XDSMP BIT(16) INITIAL("013")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Mnemonic
expansion ("DO simple"/"end simple") and full behavioral description
determined this session via direct empirical testing, part of a
systematic sweep of the `DTST`/`ETST`/`DFOR`/`EFOR`/`CFOR`/`DSMP`/`ESMP`/
`AFOR`/`CTST` group prompted by direct user suggestion that these relate
to HAL/S's `DO FOR`/`WHILE`/`UNTIL` statements ([USA003087] §10.2, PDF
pp. 113–121).
