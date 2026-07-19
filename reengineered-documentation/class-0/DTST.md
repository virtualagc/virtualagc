# DTST

**Mnemonic:** DTST
**Opcode:** 0x00E
**Confidence:** High

## Behavioral Description

"Do test" — header for a `DO WHILE condition;` or `DO UNTIL condition;`
statement group ([USA003087] §10.2). Marks the loop's test point (the
position each cycle returns to for re-evaluation) and, for `DO UNTIL`
specifically, generates an unconditional branch that skips the *first*
test — since `DO UNTIL` always executes its body at least once, while
`DO WHILE` tests before every cycle including the first. Carries one
operand identifying the construct, consumed again by [CTST](CTST.md)
(the actual condition-consuming/branching instruction, evaluated once
per cycle) and [ETST](ETST.md) (the closing instruction).

## Usage Context

Emitted for the opening of a `DO WHILE`/`DO UNTIL` group. Always followed
by the code evaluating `condition`, then a [CTST](CTST.md) instruction
that consumes the result and branches out of the loop if appropriate,
then the loop body, then a closing [ETST](ETST.md).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=an internal identifier for the enclosing loop
construct (matching [CTST](CTST.md)'s and [ETST](ETST.md)'s own operand),
`QUAL`=2=GLI/INL. The opcode line's own trailing header field
distinguishes `WHILE` (`0`) from `UNTIL` (`1`) — see the worked traces
below.

Confirmed by compiling both forms with `HALSFC --parms="LSTALL"`:

```
DO WHILE I1 > 0;              <- WHILE form
    I1 = I1 - 1;
END;
```
```
HALMAT: 00E(1),0,0            <- DTST, trailing field 0 = WHILE
          2(2),0,0              <- construct id 2, QUAL=2=GLI/INL
L#3 EQU *                      <- loop test point (re-entered each cycle)
HALMAT: 7C8(2),1,0            <- comparison (I1 > 0)
          2(1),0,0               <- I1, QUAL=1=SYT
          3(5),0,0               <- literal 0, QUAL=5=LIT
HALMAT: 016(1),0,0            <- CTST (see CTST.md), trailing field 0
         37(3),0,0               <- VAC ref to the comparison result
BC 6,L#2                       <- branch-on-false to loop exit
```

```
DO UNTIL I1 <= 0;              <- UNTIL form
    I1 = I1 - 1;
END;
```
```
HALMAT: 00E(1),1,0            <- DTST, trailing field 1 = UNTIL
          5(2),0,0               <- construct id 5, QUAL=2=GLI/INL
BC 7,L#7                       <- unconditional: skip the first test entirely
L#6 EQU *                      <- loop test point (re-entered on 2nd+ cycles)
HALMAT: 7C7(2),1,0            <- comparison (I1 <= 0)
          2(1),0,0               <- I1, QUAL=1=SYT
          5(5),0,0               <- literal 0, QUAL=5=LIT
HALMAT: 016(1),1,0            <- CTST, trailing field 1 = UNTIL
         58(3),0,0               <- VAC ref to the comparison result
BC 6,L#5                       <- branch-on-false to loop exit
L#7 EQU *                      <- first-cycle entry point (test skipped)
```

## Unresolved Questions

- Whether the trailing header field genuinely functions as a general
  "polarity"/flag bit elsewhere, or is specific to this WHILE/UNTIL
  distinction, is not confirmed — it's treated as an opaque flag matching
  observed behavior, not decoded at the bit level.

## Source Analysis & Reliability

Opcode (0x00E) confirmed primary-source: `XDTST BIT(16) INITIAL("00E")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax primary-sourced from [USA003087] §10.2 (PDF pp. 113–121). Full
behavioral description, operand-word structure, and machine-code
correlation (including the WHILE/UNTIL polarity distinction) confirmed
directly against real compiled HALMAT this session, prompted by direct
user suggestion that this opcode family relates to `DO FOR`/`WHILE`/
`UNTIL`.
