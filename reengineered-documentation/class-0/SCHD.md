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

- `SHL(FIXL(MP)+2,6)` for the `WHILE <BIT EXP>`/`UNTIL <BIT EXP>` case:
  **resolved this session, both empirically and structurally.**
  `FIXL(MP)=0` for `WHILE <event>` (a plain, unsubscripted, unlatched
  `EVENT` variable), giving `SHL(2,6)=0x80` — the previously-observed
  tag-0x94 case above. Compiling the same expression with `UNTIL`
  instead of `WHILE` (`SCHEDULE MYTASK PRIORITY(50), REPEAT UNTIL EV1;`)
  gives tag `0xD4` = `4(PRIORITY) | 0x10(bare REPEAT) | 0xC0`, i.e.
  `FIXL(MP)=1`, `SHL(3,6)=0xC0` — so `WHILE` vs `UNTIL` for a bit
  expression *do* get distinct tags after all (this file previously only
  had the `WHILE` case on record and had flagged `UNTIL`'s own tag as
  unconfirmed). Further, `FIXL(MP)` **cannot** take any value beyond
  `{0,1}` within this encoding: the tag is an 8-bit trailing field (`tag
  = (w >> 24) & 0xFF` in this project's own loader), and bits 0–5 are
  already spent on the `AT/IN/ON` (2), `PRIORITY` (1), `DEPENDENT` (1),
  and `REPEAT` (2) sub-fields, leaving only bits 6–7 (2 bits, values
  0–3) for `SHL(FIXL(MP)+2,6)` — `FIXL(MP)=2` would require `SHL(4,6) =
  0x100`, which doesn't fit. So the previously-open question of what a
  subscripted/latched-event bit expression's `FIXL(MP)` might be is now
  moot, not just untested: whatever `FIXL(MP)` structurally represents
  in the compiler's own source, it is bounded to exactly the two values
  needed to distinguish `WHILE` from `UNTIL`, with no room left for a
  third case to exist in this tag encoding at all.
- Relatedly: `WHILE <ARITH EXP>` (the time-valued form) was compiled
  this session and rejected outright by HALSFC — `***** WHILE EXPRESSION
  MAY NOT BE A TIMING EXPRESSION *****` (severity-2 error at the
  `SCHEDULE` statement). Only `UNTIL <ARITH EXP>` is legal for a
  time-valued stopping condition; the grammar section's parenthetical
  `(UNTIL <time-valued exp>)` note beside the `<ARITH EXP>` alternative
  was hinting at exactly this, now confirmed directly rather than left
  as a hint. This also explains, independently of the bit-width argument
  above, why the time-valued case needs only one tag bit (`0x40`) with
  no `WHILE`/`UNTIL` distinction: there is no `WHILE`-with-a-deadline
  variant to distinguish it from.
- Whether `α` (the priority expression) may be a general integer
  expression (rather than the literal tested here), changing that
  operand's `QUAL` to `VAC`, is untested.
- A `WHILE`/`UNTIL` stopping condition with no `REPEAT` clause at all
  (grammatically permitted per `<SCHEDULE CONTROL> ::= <STOPPING>`
  above, with no `<TIMING>`) — **investigated in a later session, still
  left unimplemented, but now for a documented reason rather than just
  "not compiled yet".** `HALSFC` does accept the syntax: compiling
  `SCHEDULE WORKER AT 100.0 PRIORITY(50) UNTIL 50.0;`, `SCHEDULE WORKER
  ON EV1 PRIORITY(50) WHILE EV2;`, and `SCHEDULE WORKER PRIORITY(50)
  WHILE EV1;` (immediate initiation, no delay at all) all compiled
  cleanly, producing tags `0x45`, `0x87`, `0x84` respectively — each
  decodes as `repeat_bits=0`/`stop_bits!=0` exactly as this file's
  bitmask table predicts, with operand order (`task`,
  `[AT/IN-exp|ON-event]`, `[priority]`, `stop-exp-or-event`) matching
  the existing left-to-right rule with no surprises; cross-checked with
  `unHALMAT.py`. (Aside: all three needed an explicit `PRIORITY(...)`
  to compile at all — `SCHEDULE WORKER;` with no clauses and no
  `PRIORITY` *also* failed the same `RT4`/"PRIORITY EXPRESSION...
  ABSENT OR ILLEGAL" check, so this looks like a blanket requirement of
  this compiler build unrelated to `STOPPING` specifically, not a new
  finding about this gap — `interp.c`'s default-`50`-priority code path
  remains as untested as before.)

  What's still missing is the *runtime* semantics, and this session's
  research indicates that's not just an oversight on this project's
  part — it looks genuinely undocumented in the primary source. Two
  independent checks:
  1. `PASS1.PROCS/SYNTHESI.xpl`'s own semantic action for `<SCHEDULE
     CONTROL>::=<STOPPING>` (line 5786-5787) is a bare `;` — no
     validation, no distinct code path from the `<TIMING><STOPPING>`
     case right below it. The compiler doesn't even notice this
     combination is unusual; it just ORs in whatever bits `<STOPPING>`
     contributes, same as it would for a cyclic schedule. That's
     consistent with the grammar simply not bothering to exclude the
     combination (parser-generality), not with a deliberately designed
     independent language feature.
  2. [USA003087] discusses `WHILE`/`UNTIL` stopping conditions in
     exactly one place, §23.5 ("SCHEDULE STATEMENT FOR CYCLIC
     PROCESSES"), and every single form and example given there pairs
     `UNTIL`/`WHILE` with `REPEAT` — e.g. `SCHEDULE label initiation,
     REPEAT UNTIL time;`. §13.4's own text introducing the plain
     (non-cyclic) `SCHEDULE` forms explicitly defers stopping
     conditions to those cyclic sections ("SCHEDULE statements can also
     specify the cyclic execution of a process until a stopping
     criterion is met... See: Guide/23.4 & 23.5") rather than describing
     any non-cyclic use. §23.4's own conceptual model reinforces this:
     a non-cyclic process reaching `RETURN`/`CLOSE` goes straight to the
     *terminated* inactive state (§13.3); "cancellation" (the thing a
     stopping condition triggers) is a concept `23.4` defines
     specifically for a cyclic process choosing *not to begin its next
     cycle* — a non-cyclic process has no next cycle to cancel. The
     previous session's "presumably cancels a still-pending delayed
     `AT`/`IN`/`ON` activation" theory also doesn't generalize to the
     immediate-initiation case tested here (`SCHEDULE WORKER
     PRIORITY(50) WHILE EV1;` has no delayed activation pending at all
     — the process is placed `READY` immediately), so that theory isn't
     even self-consistent across the three `SCHEDULE HEAD` variants.

  Net: the compiler's grammar is more permissive than the language
  guide's documented behavior here, and nothing in either source
  defines what should happen at runtime. Per this project's standing
  discipline, `yaHALMAT2` continues to fail loudly on this tag
  combination (`repeat_bits==0 && stop_bits!=0`) in `OP_SCHD` rather
  than guessing — this is now a confirmed-open question, not an
  unexplored one.

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
