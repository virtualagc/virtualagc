# TDCL

**Mnemonic:** TDCL
**Opcode:** 0x033
**Confidence:** High

## Behavioral Description

Temporary declare. Marks a `TEMPORARY` data-item declaration
([USA003087] §26.3, "Declaring Temporary Data") — a scratch-pad data item
local to a `DO; ... END;` statement group, declared with the keyword
`TEMPORARY` in place of `DECLARE`: `TEMPORARY name attributes;`. Also
emitted for a `DO FOR` statement's control variable when prefixed with
`TEMPORARY` (`DO FOR TEMPORARY var = ...;`), which implicitly declares
the control variable as a single-precision integer scoped to the loop.
Carries no generated code of its own — like an ordinary `DECLARE`, it's
purely a compile-time declaration marker, but for a temporary item this
is significant because its storage is explicitly scoped to (and reusable
after) the enclosing `DO...END` group's boundaries.

## Usage Context

Appears immediately after the `DO;`/[DSMP](DSMP.md) header of a
statement group, one per `TEMPORARY` statement, before the first real
executable statement in the group. Also appears once for a `TEMPORARY`
`DO FOR` control variable, alongside the usual [DFOR](DFOR.md) header
construct.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=symbol-table index of the temporary data item,
`QUAL`=1=SYT. Confirmed by compiling both forms with
`HALSFC --parms="LSTALL"`:

```
DO;
    TEMPORARY I1 INTEGER;
    I1 = 5;
    S1 = S1 + I1;
END;

HALMAT: 031(0),1,0            <- EDCL
HALMAT: 013(1),0,0            <- DSMP (DO; header)
HALMAT: 033(1),0,0            <- TDCL
          3(1),0,0               <- I1, symbol index 3, QUAL=1=SYT
                                 <- (no generated code — pure declaration)

DO FOR TEMPORARY I2 = 1 TO 18 BY 2;
    S1 = S1 + I2;
END;

...                             <- DFOR header/loop-entry code
HALMAT: 033(1),0,0            <- TDCL
          4(1),0,0               <- I2, symbol index 4, QUAL=1=SYT
```

## Unresolved Questions

- Whether a `TEMPORARY` declaration with array/structure/other complex
  attributes changes TDCL's encoding (e.g. extra operands, as seen for
  ordinary multi-attribute declarations elsewhere) was not tested — only
  a plain `INTEGER` and an implicit-integer `DO FOR` control variable
  were compiled.
- Whether anything marks the *end* of a temporary's scope (at the
  group's `END;`) — e.g. reusing [ESMP](ESMP.md)/[EFOR](EFOR.md)'s
  existing closing role, or a dedicated marker — was not specifically
  investigated.

## Source Analysis & Reliability

Opcode (0x033) confirmed primary-source: `XTDCL BIT(16) INITIAL("033")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Statement syntax primary-
sourced from [USA003087] §26.3 (PDF pp. 336–337) — mnemonic and
triggering construct identified directly by the user, correcting an
earlier session's disproven structure-template hypothesis (structures,
`COMPOOL` blocks, and `EXTERNAL` templates had all been ruled out
without result). Full behavioral description and operand-word structure
confirmed directly against real compiled HALMAT this session.
