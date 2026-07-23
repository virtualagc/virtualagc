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

## Confirmed Runtime Behavior

**Session finding, correcting an earlier session's own runtime-dispatch
assumption** (that session only confirmed ERON's *compile-time* operand
format, not what the interpreter needs to *do* at runtime): the "`BC
7,L#1` unconditional branch skipping the handler code in normal flow"
shown in this file's own worked trace above is part of ERON's *own*
generated object code, not a separate BRA HALMAT instruction emitted
after it — no such separate branch exists anywhere in the HALMAT stream.
A user report against a modified `029-DATATYPES.hal` ([USA003087] Sec.
25's own worked example, PDF p. 315 et seq.) caught this directly: the
statement immediately after `ON ERROR$(4:27) GO TO SKIPPED;` was being
skipped even though no error had occurred yet, because yaHALMAT2's
`OP_ERON` was a complete no-op, letting the inline compiled handler body
(the `GO TO SKIPPED` itself) fall through and execute unconditionally
instead of being skipped past.

Fixed by having the user-statement (`TAG`=0) form perform that skip
itself: an unconditional jump to `state->label_pos[]`'s entry for
operand 2's bookkeeping-label number, identically to how [BRA](BRA.md)/
[FBRA](FBRA.md) already resolve their own label operands — confirmed
this works because `precompute_labels()` populates that table from
*every* `LBL` instruction regardless of whether its own operand is
`SYT`-qualified (an ordinary user-declared statement label, like
`SKIPPED:` in the trace above) or `INL`-qualified (the compiler's
internal "bookkeeping label" numbering used here); the two live in the
same flat numbering space with no observed collision.

This also required implementing an actual error-environment table (a
flat, un-scoped list of registered `group:member → action` entries,
`state.h`'s `halmat_error_handler_t`) so a *later* real occurrence of
the specified error can find the `GO TO` target and redirect there —
distinct from, and easy to conflate with, the bookkeeping-label skip
target above (the handler's own registered target is the position right
after ERON, where the inline handler body *starts*; the bookkeeping
label is where normal fall-through *lands after* that body — using the
same value for both, tried first, sends a real error back into the
"normal continuation" code instead of the handler, an infinite loop the
first time it actually fires).

**Follow-up session, per direct instruction ("implement ON ERROR for all
other runtime errors listed in Appendix C")**: every App. C "standard
fixup" this interpreter implements now consults this table before
applying its own fixup, not just error 27 (the one the original bug
report happened to exercise) -- `BFNC`'s shared arithmetic-function case
(errors 4/5/6/7/8/11/12, `EXP`/`LOG`/`SIN`/`COS`/`TAN`/`SQRT`), `BFNC`'s
`UNIT` selector (error 28), `MINV`'s `M**(-1)`/negative-`N` case (error
27, alongside `BFNC`'s `INVERSE`), `SEXP`/`SPEX`/`SIEX`/`IPEX` (errors
4/24), the combined `MSPR`/`MSDV`/`VSPR`/`VSDV` case (error 25), and
`STOI` (error 15) all share the one `arithmetic_error_should_apply_
fixup()` helper (`interp.c`), each passing its own App. C error-member
constant. `STOI`'s own site duplicates a small range check rather than
reading it back out of `halmat_scalar_to_integer()` (value.c) --that
function is a generic INTEGER coercion used by many unrelated call
sites (array subscripts, etc.) that aren't the HAL/S-level `STOI`
conversion error 15 is specifically about, so only the opcode itself
consults the table. See `STATUS.md`'s Class 0 section for the full
per-error trace; `src/tests/hal/test_eron_goto.hal` and
`test_eron_goto_appc.hal` are the regression fixtures (the latter
spot-checks four of the newly-wired sites across three different opcode
families).

`IGNORE`'s exact effect on a *value-producing* built-in (as opposed to a
procedural side-effect error) isn't spelled out by [USA003087]'s own
examples, so it's treated identically to `SYSTEM` pending a clearer
citation. `AND SET`/`RESET`/`SIGNAL` fails loudly rather than silently
dropping the event modification. [USA003087] Sec. 25.1's per-block
dynamic-scoping rule (a modification made inside a `PROCEDURE`/
`FUNCTION` is unwound on return from it) is not implemented — the
handler table is flat/global for the whole run.

## Unresolved Questions

- None remaining for the base `ON ERROR`/`OFF ERROR` *compile-time
  operand format* — all documented forms (`SYSTEM`, `IGNORE`, `AND SET`/
  `RESET`/`SIGNAL`, the user-statement form, `OFF`, and both subscripted
  specification forms) are now confirmed, all through this single
  opcode.
- **[ERSE](ERSE.md) never appeared in any of the 11 variations tested
  across two sessions** — see that file; it remains genuinely unresolved
  whether ERSE relates to error handling at all.
- *Runtime* dispatch gaps: dynamic scoping and `IGNORE`'s exact
  semantics for value-producing built-ins — see Confirmed Runtime
  Behavior above. Every App. C error this interpreter implements a
  standard fixup for now consults the handler table; errors for
  functions not yet implemented at all (`MOD`, `REMAINDER`, `LJUST`/
  `RJUST`, `ARCSIN`/`ARCCOS`/etc.) obviously don't.

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
