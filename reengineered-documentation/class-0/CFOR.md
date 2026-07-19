# CFOR

**Mnemonic:** CFOR
**Opcode:** 0x012
**Confidence:** High

## Behavioral Description

"Condition for" — consumes the boolean/relational result of a `DO FOR`
statement's *supplementary* `WHILE`/`UNTIL` clause ([USA003087] §10.2:
"this DO FOR statement may possess a WHILE or UNTIL clause which
furnishes a supplementary stopping condition") and generates the
conditional branch that exits the loop when that extra condition fails.
The direct [DFOR](DFOR.md)/[CFOR](CFOR.md) analog of
[DTST](DTST.md)/[CTST](CTST.md) for plain `WHILE`/`UNTIL` loops — CFOR
plays the same role as [CTST](CTST.md), just attached to a range-form
`DO FOR`'s own index-range test rather than being the loop's only
condition.

## Usage Context

Only appears when a `DO FOR` statement carries an explicit `WHILE`/
`UNTIL` clause — absent from the base `DO FOR` tests without one (see
[DFOR](DFOR.md)). Positioned once per cycle, after the code evaluating
the supplementary condition and after the index-range check, immediately
before the loop body.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=the stream position of the comparison instruction
that produced the supplementary condition's boolean result, `QUAL`=3=VAC.
Confirmed by compiling:

```
DO FOR I1 = 1 TO 10 WHILE S1 < 5.0;
    S1 = I1;
END;
```

with `HALSFC --parms="LSTALL"`:

```
HALMAT: 010(4),1,0            <- DFOR (index range 1..10)
LFXI 7,3
BC   7,L#10
L#8 EQU *                      <- loop top
HALMAT: 5C1(1),0,0            <- scalar-literal load (prepares 5.0 for comparison)
          7(5),0,0
HALMAT: 7AA(2),1,0            <- SLT comparison: S1 < 5.0
          3(1),0,0               <- S1, QUAL=1=SYT
         33(3),0,0               <- VAC ref to the 5C1 literal-load instruction
LE 0,S1  /  CE 0,=5.0          <- the actual comparison in machine code
HALMAT: 012(1),0,0            <- CFOR
         35(3),0,0               <- VAC ref to the 7AA comparison's result
BC 5,L#6                       <- branch-on-false to loop exit (bypassing EFOR's own test)
```

## Unresolved Questions

- Whether `UNTIL` (as opposed to `WHILE`) as the supplementary clause
  changes CFOR's own encoding (a polarity flag, as with
  [DTST](DTST.md)/[CTST](CTST.md)) or is handled entirely by how the
  comparison itself is compiled (e.g. `>=` instead of `<`) is untested —
  only the `WHILE` form was compiled.
- Interaction with the list form of `DO FOR` (which also permits a
  supplementary clause per [USA003087] §10.2) is untested — only the
  range form was compiled with a `WHILE` clause.

## Source Analysis & Reliability

Opcode (0x012) confirmed primary-source: `XCFOR BIT(16) INITIAL("012")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Full behavioral
description confirmed this session via direct empirical testing — see
[DFOR](DFOR.md)'s Source Analysis for the context of this investigation.
