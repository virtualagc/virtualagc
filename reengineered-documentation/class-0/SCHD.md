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

Only the simplest (immediate-initiation, `PRIORITY(...) DEPENDENT`)
variant has been empirically compiled; the delayed (`AT`/`IN`/`ON`) and
cyclic (`REPEAT EVERY`/`AFTER`...`WHILE`/`UNTIL`) variants were not
independently compiled this session, but their operand-count and
tag-bitmask contributions are now fully decoded directly from the
grammar-rule source (see below) rather than left as an open question.

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

Per the grammar-rule loop (`DO WHILE REFER_LOC<=PTR_TOP; CALL
HALMAT_PIP(...); REFER_LOC=REFER_LOC+1; END;`), `NUMOP` equals one plus
the count of `AT`/`IN`/`ON`/`PRIORITY`/`EVERY`/`AFTER`/`WHILE`/`UNTIL`
expression operands actually present — the base `<LABEL VAR>` itself
contributes the first slot, and each additional clause's `<ARITH EXP>`/
`<BIT EXP>` contributes one more, confirming this project's prior
hypothesis that "delayed/cyclic forms likely add further operands."

## Unresolved Questions

- The exact `FIXL(MP)` values feeding `SHL(FIXL(MP)+2,6)` for the
  `WHILE`/`UNTIL <BIT EXP>` stopping-condition case are not enumerated —
  would require compiling that specific variant.
- No variant beyond `PRIORITY(...) DEPENDENT` was independently compiled
  this session — the bitmask table above is derived from primary source
  (the grammar rules themselves), not cross-checked against additional
  real compiled traces.
- Whether `α` (the priority expression) may be a general integer
  expression (rather than the literal tested here), changing the first
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
had capped this file at Medium confidence — was fully decoded this
session by grepping the full
`PASS.REL32V0` compiler source tree for every site referencing `XSCHD`,
which led directly to `PASS1.PROCS/SYNTHESI.xpl`'s `<SCHEDULE
HEAD>`/`<SCHEDULE PHRASE>`/`<SCHEDULE CONTROL>` grammar-rule family and
its explicit bit-by-bit construction of `INX(REFER_LOC)` — no new
compilation was needed to resolve this particular open question, since
the source itself gives the complete, unambiguous bit-assignment table.
