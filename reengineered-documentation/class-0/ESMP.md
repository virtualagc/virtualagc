# ESMP

**Mnemonic:** ESMP

**Opcode:** 0x014

**Confidence:** High

## Behavioral Description

"End simple" — closes a plain, unconditional `DO; ... END;` statement
group opened by [DSMP](DSMP.md) ([USA003087] §9). Carries one operand
identifying the construct, matching [DSMP](DSMP.md)'s. Generates no
branch or other code — like `DSMP`, it's purely a bracketing marker (the
group's statements simply execute in sequence; there is no loop-back or
conditional skip to generate).

## Usage Context

Emitted for the closing `END;` of any plain `DO; ... END;` group.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=an internal identifier for the enclosing `DO...END`
construct, `QUAL`=2=GLI/INL (compare the analogous construct-id operands
on [DCAS](DCAS.md)/[CLBL](CLBL.md)/[ECAS](ECAS.md) for `DO CASE`).
Confirmed by compiling:

```
DO;
    S1 = 1;
END;
```

with `HALSFC --parms="LSTALL"`, which produced `HALMAT: 014(1),0,0`
followed by operand `1(2),0,0` (construct id 1), with no generated
machine code at this point — the statement immediately following `END;`
begins right after.

## Unresolved Questions

- None for the base case.

## Source Analysis & Reliability

Opcode (0x014) confirmed primary-source: `XESMP BIT(16) INITIAL("014")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DSMP](DSMP.md)'s Source Analysis for the context of this investigation.
