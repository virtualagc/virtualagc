# AFOR

**Mnemonic:** AFOR
**Opcode:** 0x015
**Confidence:** High

## Behavioral Description

"Alternate for" — carries one value of the list-form `DO FOR var = exp1,
exp2, ...expn;` statement ([USA003087] §10.2's "second form" of `DO
FOR`, used when "the values of the control variable do not form a
regular progression"). One AFOR instruction is emitted per value in the
list; each generates code loading that value and dispatching into the
loop body via a call-and-computed-return mechanism (rather than the
increment/re-test loop used by the range form — see [DFOR](DFOR.md)/
[EFOR](EFOR.md)).

## Usage Context

Appears once per value, immediately after the (reduced, operand-count-2)
[DFOR](DFOR.md) header of a list-form `DO FOR` statement. The final AFOR
in the list is distinguished by a trailing header flag (see Operand-Word
Format) and additionally sets up the loop's exit address, since after the
last value's cycle the loop must fall through to [EFOR](EFOR.md)'s exit
rather than dispatch to another value.

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=a literal-table index for this value, `QUAL`=5=LIT.
The opcode line's trailing header field is `0` for every value except the
last in the list, where it is `1` (an end-of-list flag).

Confirmed by compiling `DO FOR I1 = 1, 2, 3; S1 = I1; END;` with
`HALSFC --parms="LSTALL"`:

```
HALMAT: 010(2),0,0            <- DFOR (list-form header, no literal operands of its own)
          1(2),0,0               <- construct id 1, QUAL=2=GLI/INL
          2(1),0,0               <- control var I1, QUAL=1=SYT (see DFOR.md — operand
                                      order corrected in a later session)
HALMAT: 015(1),0,0            <- AFOR, value 1 of 3
          9(5),0,0               <- literal idx 9 (value 1), QUAL=5=LIT
LFXI 7,3
BAL  4,L#15                       <- branch-and-link into the shared dispatch routine
L#18 EQU *                        <- return point after this cycle
HALMAT: 015(1),0,0            <- AFOR, value 2 of 3
         10(5),0,0               <- literal idx 10 (value 2), QUAL=5=LIT
LFXI 7,4
BAL  4,L#15
L#19 EQU *                        <- return point after this cycle
HALMAT: 015(1),1,0            <- AFOR, value 3 of 3 — trailing field 1 = last value
         11(5),0,0               <- literal idx 11 (value 3), QUAL=5=LIT
LFXI 7,5
LA   4,L#13                       <- prepare the LOOP-EXIT address instead of a return point
L#15 EQU *                        <- shared dispatch routine entry (reached via each BAL above)
STH  4,18(0,0)                    <- save the prepared return/exit address
STH  7,I1                         <- store this cycle's value into the control variable
```

The body (`S1 = I1;`) executes after each `STH 7,I1`, then falls through
to [EFOR](EFOR.md), which reloads the saved address and branches to it —
either back to `L#18`/`L#19` (continuing with the next value) or to
`L#13` (the loop exit, after the third/last value's cycle).

## Unresolved Questions

- None for the base case tested (a 3-value integer list).

## Source Analysis & Reliability

Opcode (0x015) confirmed primary-source: `XAFOR BIT(16) INITIAL("015")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified under this name. Statement
syntax (list-form `DO FOR`) primary-sourced from [USA003087] §10.2 (PDF
pp. 113–121). Full behavioral description, operand-word structure, and
the call/computed-return machine-code mechanism confirmed directly
against real compiled HALMAT this session, prompted by direct user
suggestion that this opcode family relates to `DO FOR`/`WHILE`/`UNTIL`.
