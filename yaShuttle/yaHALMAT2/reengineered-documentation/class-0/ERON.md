# ERON

**Mnemonic:** ERON

**Opcode:** 0x03C

**Confidence:** High

## Behavioral Description

`ON ERROR` / `OFF ERROR` statement — the single opcode handling **all**
forms of HAL/S's error-environment-modification statements
([USA003087] §25.2, PDF pp. 318, 322):

- `ON specification SYSTEM;` — revert to standard system recovery action.
- `ON specification IGNORE;` — ignore the specified error(s).
- `ON specification IGNORE/SYSTEM AND SET/RESET/SIGNAL var;` — as above,
  plus modify an event.
- `ON specification statement;` — branch to user-supplied HAL/S code on
  the specified error's occurrence (the statement may be a `DO...END`
  group).
- `OFF specification;` — remove a previously-applied `ON ERROR`
  modification with the same specification.

All five are the *same* HALMAT opcode, distinguished by operand count and
an opcode-line trailing header flag (see Operand-Word Format). No
separate opcode was found for `OFF ERROR` or the `AND SET/RESET/SIGNAL`
clause, even after exhaustively testing every documented variation
(11 total across two sessions) — see [ERSE](ERSE.md), whose sibling
opcode remains genuinely unaccounted for.

## Usage Context

Emitted for every `ON ERROR`/`OFF ERROR` statement. The error
specification itself (`ERROR`, `ERRORm`, or `ERRORm:n`, per §25.2) is
carried on ERON's first operand as a packed group/member value: `DATA`=
group number (`255`=an "all groups" sentinel for the unsubscripted form),
trailing sub-field=member number (`63`=an "all members" sentinel),
confirmed against both the wildcard and specific-group/specific-member
forms — see Operand-Word Format.

## Operand-Word Format (confirmed empirically)

Confirmed by compiling all of `ON ERROR SYSTEM;`, `ON ERROR IGNORE;`,
`ON ERROR IGNORE AND SET EV1;`, `ON ERROR I1 = 1;` (user-statement form),
and `OFF ERROR;` (all with the unsubscripted "all errors" specification)
with `HALSFC --parms="LSTALL"`:

```
ON ERROR SYSTEM;
HALMAT: 03C(1),1,0          <- trailing field 1 = SYSTEM
        255(6),63,0           <- op: DATA=255 (all groups), QUAL=6=IMD, sub-field 63 (all members)
LHI 4,4159 / STH 4,18(0,0)    <- packs the spec into a fixed error-control-block slot

ON ERROR IGNORE;
HALMAT: 03C(1),2,0          <- trailing field 2 = IGNORE
        255(6),63,0

ON ERROR IGNORE AND SET EV1;
HALMAT: 03C(2),2,0          <- trailing field 2 = IGNORE, now 2 operands
        255(6),63,0
          3(1),0,1            <- op 2: EV1, symbol index 3, QUAL=1=SYT, sub-flag 1 = SET

ON ERROR SYSTEM AND RESET EV1;
HALMAT: 03C(2),1,0
        255(6),63,0
          2(1),0,2            <- op 2: EV1, sub-flag 2 = RESET

ON ERROR SYSTEM AND SIGNAL EV2;
HALMAT: 03C(2),1,0
        255(6),63,0
          3(1),0,0            <- op 2: EV2, sub-flag 0 = SIGNAL

ON ERROR                      <- group:member subscripted form (ERRORm:n)
S             1:4
    IGNORE;
HALMAT: 03C(1),2,0
          1(6),4,0             <- DATA=1 (group 1), QUAL=6=IMD, sub-field 4 (member 4)

ON ERROR                      <- group-only subscripted form (ERRORm)
S             3
    SYSTEM;
HALMAT: 03C(1),1,0
          3(6),63,0            <- DATA=3 (group 3), sub-field 63 (all members in that group)

ON ERROR I1 = 1;              <- user-supplied-statement form (CASE 3)
HALMAT: 03C(2),0,0          <- trailing field 0 = user-statement, 2 operands
        255(6),63,0
          1(2),0,0             <- op 2: DATA=1 (a branch-target/construct id), QUAL=2=GLI/INL
BC 7,L#1                       <- unconditional branch skipping the handler code in normal flow
...                             <- I1 = 1; (the handler statement itself) sits here
L#1 EQU *                      <- normal-flow continuation point

OFF ERROR;
HALMAT: 03C(1),3,0          <- trailing field 3 = OFF
        255(6),63,0
ZH 0,18(0,0)                   <- zeroes the error-control-block slot set by a prior ON ERROR

OFF ERROR                     <- OFF also accepts a group:member specification
S             1:4
   ;
HALMAT: 03C(1),3,0
          1(6),4,0             <- same group/member encoding as the ON forms above
```

So the opcode-line trailing field is a 4-way discriminant: `0`=user-
statement, `1`=SYSTEM, `2`=IGNORE, `3`=OFF. When a second (event) operand
is present, its own trailing sub-field is a 3-way discriminant:
`0`=SIGNAL, `1`=SET, `2`=RESET.

**Subscript source syntax note**: getting `ERRORm`/`ERRORm:n` to compile
required splitting `ON`/`OFF` `ERROR` onto its own physical line with the
subscript continuation immediately following, *before* the `SYSTEM`/
`IGNORE`/`;` — placing the subscript after the complete statement (as a
literal reading of the Guide's typeset examples suggests) instead
produces "S-LINE OVERLAPS M-LINE" / mis-tokenization errors, apparently
because `ERROR` is a keyword rather than an ordinary subscriptable
identifier.

## Unresolved Questions

- None remaining for the base `ON ERROR`/`OFF ERROR` mechanism — all
  documented forms (`SYSTEM`, `IGNORE`, `AND SET`/`RESET`/`SIGNAL`, the
  user-statement form, `OFF`, and both subscripted specification forms)
  are now confirmed, all through this single opcode.
- **[ERSE](ERSE.md) never appeared in any of the 11 variations tested
  across two sessions** — see that file; it remains genuinely unresolved
  whether ERSE relates to error handling at all.

## Source Analysis & Reliability

Opcode (0x03C) confirmed primary-source: `XERON BIT(16) INITIAL("03C")`
in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Statement syntax primary-
sourced from [USA003087] §25.2 (PDF pp. 318, 322). Full behavioral
description, the 4-way opcode-trailing-field encoding, the 3-way event-
operand sub-flag encoding, and both subscripted-specification forms
confirmed directly against real compiled HALMAT across two sessions,
prompted by direct user suggestion that this opcode relates to HAL/S's
`ON ERROR`/`OFF ERROR` statements.
