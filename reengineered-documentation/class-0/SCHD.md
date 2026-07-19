# SCHD

**Mnemonic:** SCHD

**Opcode:** 0x039

**Confidence:** High

## Behavioral Description

`SCHEDULE` statement — a real-time programming statement ([USA003087]
§13.4, PDF pp. 165–167) that places a new process in the process queue
("initiates" it), optionally with a delayed or cyclic initiation
condition and/or a stopping condition. The base form previously tested
was the "immediate initiation" variant: `SCHEDULE label PRIORITY(α)
DEPENDENT;`. The operator word's trailing tag is a confirmed bitmask
(see below), and the operand count (`NUMOP`) grows by one for every
optional clause present (`AT`/`IN`/`ON`, `PRIORITY`, `EVERY`/`AFTER`,
`WHILE`/`UNTIL`), each contributing its own expression's value as an
operand.

## Usage Context

Emitted wherever a `SCHEDULE` statement occurs, built from
`PASS1.PROCS/SYNTHESI.xpl`'s `<SCHEDULE HEAD>`/`<SCHEDULE
PHRASE>`/`<SCHEDULE CONTROL>` grammar-rule family:

```
<SCHEDULE HEAD>    ::= SCHEDULE <LABEL VAR>
                      | <SCHEDULE HEAD> AT <ARITH EXP>
                      | <SCHEDULE HEAD> IN <ARITH EXP>
                      | <SCHEDULE HEAD> ON <BIT EXP>
<SCHEDULE PHRASE>  ::= <SCHEDULE HEAD>
                      | <SCHEDULE HEAD> PRIORITY (<ARITH EXP>)
                      | <SCHEDULE PHRASE> DEPENDENT
<SCHEDULE CONTROL> ::= <STOPPING> | <TIMING> | <TIMING> <STOPPING>
<TIMING>           ::= <REPEAT> EVERY <ARITH EXP>
                      | <REPEAT> AFTER <ARITH EXP>
                      | <REPEAT>
<STOPPING>         ::= <WHILE KEY> <ARITH EXP>   (UNTIL <time-valued exp>)
                      | <WHILE KEY> <BIT EXP>    (WHILE/UNTIL <event/bit exp>)
```

**All variants now empirically confirmed**, including the delayed
(`AT`/`IN`/`ON`) and cyclic (`REPEAT EVERY`/`AFTER`, `WHILE`/`UNTIL`)
forms — see Operand-Word Format below. One syntax note found along the
way: the `<REPEAT>` grammar nonterminal is literally `, REPEAT` (a
leading comma) — `SCHEDULE MYTASK PRIORITY(50), REPEAT EVERY 2.0;`, not
`PRIORITY(50) REPEAT EVERY 2.0;` (rejected by this compiler build).

## Operand-Word Format (bitmask now confirmed via primary source)

The trailing tag on the `SCHD` operator word is built as
`INX(REFER_LOC)`, accumulated with bitwise-OR across the clauses actually
present in the statement:

| Bits | Value | Clause |
|---|---|---|
| low 2 bits (exclusive, not OR'd) | `1` | `AT` |
| | `2` | `IN` |
| | `3` | `ON` |
| bit 2 | `4` | `PRIORITY(...)` present |
| bit 3 | `8` | `DEPENDENT` present |
| bits 4–5 (exclusive) | `0x10` | `REPEAT` (bare, no EVERY/AFTER) |
| | `0x20` | `REPEAT EVERY <exp>` |
| | `0x30` | `REPEAT AFTER <exp>` |
| bit 6 | `0x40` | `WHILE`/`UNTIL <ARITH EXP>` (time-valued stopping condition) |
| bits 6+ (variable) | `SHL(FIXL(MP)+2,6)` | `WHILE`/`UNTIL <BIT EXP>` (event/bit stopping condition) — exact `FIXL(MP)` values not enumerated |

This confirms and fully decodes the previously-observed value `12` =
`0x0C` = `4` (`PRIORITY`) `| 8` (`DEPENDENT`) for the tested
`PRIORITY(50) DEPENDENT` case, with no further compilation needed.

Two operands were confirmed by compiling `SCHEDULE MYTASK PRIORITY(50)
DEPENDENT;` with `HALSFC --parms="LSTALL"`. **Operand order corrected in
a later session**, after cross-checking with a direct `unHALMAT.py`
binary read (`HALSFC --parms="LISTING2,LSTALL"`) — the same
`pass2.rpt`-print-ordering caveat already found for [READ](READ.md)/
[DFOR](DFOR.md) (see [XXST](XXST.md)) applied here too. True order:
operand 1 = `DATA`=symbol-table index of the task being scheduled,
`QUAL`=1=SYT (the `<LABEL VAR>` from the grammar, matching source order:
the task name appears before `PRIORITY(...)` in `SCHEDULE MYTASK
PRIORITY(50) DEPENDENT;`); operand 2 = `DATA`=literal-table index of the
priority value, `QUAL`=5=LIT.

```
HALMAT: 039(2),12,0         <- SCHD, trailing field 12 = PRIORITY|DEPENDENT
          4(1),0,0            <- MYTASK, symbol index 4, QUAL=1=SYT
          3(5),0,0            <- literal idx 3 (priority value 50), QUAL=5=LIT
SVC 0,16(0,9)                  <- runtime schedule routine
```

**General rule, confirmed across all delayed/cyclic variants in a later
session**: `NUMOP` equals one (the task) plus one more for *every*
clause that carries its own expression value, and — like the base case
above — **operands appear in strict left-to-right source order**, not
grouped by clause kind. Bare `REPEAT` (no `EVERY`/`AFTER`) contributes
only to the tag, no operand of its own. Confirmed by compiling all of
`AT`/`IN`/`ON` (each with `PRIORITY(50)`) and `PRIORITY(50), REPEAT
EVERY/AFTER/WHILE/UNTIL` with `HALSFC --parms="LISTING2,LSTALL"`,
cross-checked directly with `unHALMAT.py`:

```
SCHEDULE MYTASK AT 5.0 PRIORITY(50);
HALMAT: 039(3),5,0           <- tag 5 = 1(AT) | 4(PRIORITY)
          3(1),0,0              <- op 1: MYTASK, QUAL=1=SYT
         21(3),0,0              <- op 2: VAC ref to AT's own expression (5.0, ITOS'd)
          2(5),0,0              <- op 3: literal (priority 50), QUAL=5=LIT

SCHEDULE MYTASK ON EV1 PRIORITY(50);
HALMAT: 039(3),7,0           <- tag 7 = 3(ON) | 4(PRIORITY)
          3(1),0,0              <- op 1: MYTASK
          2(1),0,0              <- op 2: EV1 (the ON bit-exp), QUAL=1=SYT (plain EVENT ref, no VAC needed)
          5(5),0,0              <- op 3: literal (priority 50)

SCHEDULE MYTASK PRIORITY(50), REPEAT EVERY 2.0;
HALMAT: 039(3),24,0          <- tag 0x24 = 4(PRIORITY) | 0x20(REPEAT EVERY)
          3(1),0,0              <- op 1: MYTASK
          6(5),0,0              <- op 2: literal (priority 50) — PRIORITY comes before REPEAT in source
         43(3),0,0              <- op 3: VAC ref to EVERY's own expression (2.0, ITOS'd)

SCHEDULE MYTASK PRIORITY(50), REPEAT WHILE EV1;
HALMAT: 039(3),94,0          <- tag 0x94 = 4(PRIORITY) | 0x10(bare REPEAT) | 0x80(WHILE <BIT EXP>, FIXL(MP)=0)
          3(1),0,0              <- op 1: MYTASK
         10(5),0,0              <- op 2: literal (priority 50)
          2(1),0,0              <- op 3: EV1 (the WHILE stopping bit-exp), QUAL=1=SYT

SCHEDULE MYTASK PRIORITY(50), REPEAT UNTIL 10.0;
HALMAT: 039(3),54,0          <- tag 0x54 = 4(PRIORITY) | 0x10(bare REPEAT) | 0x40(UNTIL <ARITH EXP>)
          3(1),0,0              <- op 1: MYTASK
         11(5),0,0              <- op 2: literal (priority 50)
         65(3),0,0              <- op 3: VAC ref to UNTIL's own expression (10.0, ITOS'd)
```

Every tag value matches the primary-source-derived bitmask table exactly
(`AT`=1, `ON`=3, `PRIORITY`=4, `REPEAT EVERY`=0x20, bare-`REPEAT`=0x10,
time-valued `STOPPING`=0x40), confirming the table needed no correction.
`IN`/`REPEAT AFTER` variants were also compiled and match the table's
`IN`=2/`0x30` values identically (not shown above for brevity).

## Unresolved Questions

- `SHL(FIXL(MP)+2,6)` for the `WHILE <BIT EXP>` case: confirmed `FIXL(MP)=0`
  for a plain (unsubscripted, unlatched) `EVENT` variable, giving
  `SHL(2,6)=0x80` — the observed tag-0x94 case above. Other `FIXL(MP)`
  values (e.g. for a subscripted or latched-event bit expression) remain
  unconfirmed.
- Whether `α` (the priority expression) may be a general integer
  expression (rather than the literal tested here), changing that
  operand's `QUAL` to `VAC`, is untested.

## Source Analysis & Reliability

Opcode (0x039) confirmed primary-source: `XSCHD BIT(16) INITIAL("039")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog expected (multitasking postdates HAL 1971).
Statement syntax primary-sourced from [USA003087] §13.4 (PDF pp.
165–167). Base behavioral description and operand-word structure for the
simplest form confirmed against real compiled HALMAT in an earlier
session (operand order corrected in a later session via `unHALMAT.py` —
see Operand-Word Format above). The trailing-tag bitmask — the item that
had capped this file at Medium confidence — was decoded by grepping the
full `PASS.REL32V0` compiler source tree for every site referencing
`XSCHD`, which led directly to `PASS1.PROCS/SYNTHESI.xpl`'s `<SCHEDULE
HEAD>`/`<SCHEDULE PHRASE>`/`<SCHEDULE CONTROL>` grammar-rule family and
its explicit bit-by-bit construction of `INX(REFER_LOC)`; the source
alone gave the complete, unambiguous bit-assignment table, and a later
session then independently compiled every variant (`AT`/`IN`/`ON`,
`REPEAT EVERY`/`AFTER`, `REPEAT WHILE`/`UNTIL`) and cross-checked each
against a direct `unHALMAT.py` binary read, confirming the
source-derived table exactly with no corrections needed.
