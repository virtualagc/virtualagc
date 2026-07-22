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

## Real-Time Calibration (yaHALMAT2's interpreter, not HALSFC)

The sections above are about how HALSFC *compiles* `SCHEDULE` into HALMAT.
This section is about a different question: once `yaHALMAT2` executes that
HALMAT, what does `AT`/`IN`/`EVERY`/`AFTER`/a time-valued `UNTIL`'s
numeric-seconds expression (and `WAIT`'s own interval, class-0/WAIT.md)
actually mean in real elapsed time? Earlier interpreter work (see
`state.h`'s scheduler comment, `interp.c`'s `OP_SCHD`/`OP_WAIT`) ticked
`virtual_time` 1:1 per HALMAT instruction executed and used a resolved
`SCHEDULE`/`WAIT` seconds value directly as a tick count with no unit
conversion at all — a documented stopgap ("not a calibration to real
seconds"), not a real timing model. This section documents the real one,
sourced from the AP-101S Software Model PDF ("the POO",
<https://www.ibiblio.org/apollo/Shuttle/Shuttle%20GPC%20Software%20Model%20AP-101S.pdf>)
plus an empirical HALMAT-to-AP-101S-instruction-count sample, so a future
session can verify or refine `HALMAT_TICKS_PER_SECOND` (`state.h`) without
redoing the PDF research from scratch.

**Primary-source facts used:**

- Sec. 16.1 ("Instruction Execution — Pipeline Basics") states directly:
  > "For the AP-101S computer, the pipeline cycle time is 0.250
  > microseconds."
- Sec. 17.0 ("AP-101S Instruction Execution Times") is a per-mnemonic
  table in microseconds. The two entries that matter most for real
  HAL/S-compiled code are `SCAL` (subroutine call) = **18.125 µs** and
  `SVC` (supervisor call) = **20.25 µs** — both large, unambiguous, high-
  confidence reads, and both dominant in practice: runtime-library calls
  (I/O formatting, matrix/scalar math support routines) are a major real
  cost on this architecture, not just explicit HAL/S `CALL` statements.

**What was still missing**: how many AP-101S instructions a typical
HALMAT instruction expands into. To get that, 7 representative existing
test fixtures — `src/tests/hal/test_int_arith2.hal`, `test_pcal.hal`,
`test_scalar_arith.hal`, `test_write_lit.hal`, `test_bit.hal`,
`test_matrix_sub.hal`, `test_cfor.hal` — were compiled with `HALSFC
--parms="LSTALL"` (the `LSTALL` technique documented in
`reengineered-documentation/STATUS.md`), and the resulting `pass2.rpt`'s
interleaved `HALMAT: <opcode>(...)` / generated-AP-101S-assembly-line
listing was parsed for each.

**Result, aggregated across all 7 fixtures**: **230 HALMAT instructions
generated 188 AP-101S instructions**, with the mnemonic mix dominated by
`SCAL` (34 occurrences) and `SVC` (7); the remainder were simple
`RR`/`RS`/`RI` loads/stores/arithmetic, priced via Sec. 16's format-class
averages (`RR`=0.25µs, `SRS`=0.375µs, `RS`=0.5µs steady-state pipelined
cycles — ~0.4µs was used as a single representative "simple instruction"
figure rather than chasing every individual mnemonic through an
OCR'd/hand-transcribed table). This works out to **≈3.62 µs per HALMAT
instruction**, aggregate — per-fixture range was 2.45–6.05 µs (i.e.
~165,000–408,000 ticks/sec depending on program mix: arithmetic-heavy
code is cheaper per instruction, call/I-O-heavy code pricier). The
aggregate figure was adopted as a single project-wide constant:

```c
#define HALMAT_TICKS_PER_SECOND 276000
```

This is deliberately rough — HAL/S source doesn't determine exact AP-101S
code shape, and a single global constant can't track per-program
mix — but it is sourced, not asserted: every number above traces to either
the PDF's own text/tables or a real, reproducible compiled-code sample.
To redo or refine it: recompile the 7 fixtures above (or a larger/
different sample) with `HALSFC --parms="LSTALL"`, re-tally the
`pass2.rpt` HALMAT-vs-AP-101S-instruction counts and mnemonic mix, and
re-price against Sec. 16/17's tables the same way.

**How it's applied**: `interp.c`'s `schd_seconds_to_ticks()` converts a
resolved `SCHEDULE`/`WAIT` seconds value (as a raw double, before any
rounding) to a tick count via this constant, used at all four sites that
resolve a HAL/S numeric-seconds expression (`OP_SCHD`'s `AT`/`IN`,
`EVERY`/`AFTER`, time-valued `UNTIL`, and `OP_WAIT`'s interval).
`interp_run()` then paces real execution against a monotonic wall clock
using this same constant (`HALMAT_REALTIME_BURST_MS`-sized bursts,
`state.h`'s scheduler comment) — so a real run of, e.g., `SCHEDULE WORKER
PRIORITY(80), REPEAT EVERY 1.0;` now genuinely re-triggers `WORKER`
roughly once per real second, rather than roughly once per instruction. A
`--time-scale FACTOR` option (`main.c`) divides only that pacing layer's
*sleep* duration — never `HALMAT_TICKS_PER_SECOND` or the tick arithmetic
itself — so existing fixtures' tick counts/interleaving/output are
unaffected by it; it exists purely so tests and interactive use aren't
forced to wait out real HAL/S-modeled seconds.

## Self-Rescheduling Tasks (a task's own body targeting itself)

A user-reported bug: `NEST: TASK; ...; SCHEDULE NEST IN 1.0 PRIORITY(80);
CLOSE NEST;` (a task rescheduling *itself* from inside its own body, the
natural idiom for a periodic/recurring task written imperatively rather
than via the declarative `REPEAT` clause) failed with "task already
active (concurrent re-scheduling of the same task not yet implemented)".
The user pushed back citing [USA003087] p. 160 (printed p. 13-2), and
correctly: that page defines a process as "active" **if and only if it
is in the process queue**, with `EXECUTING`/`READY`/`WAITING` as three
*minor states* of that one active condition — and a task rescheduling
itself doesn't add a second entry to the queue, it changes its own (sole)
entry's minor state from `EXECUTING` to `WAITING` (or `READY`, for an
immediate reschedule). Sec. 13.4's "only one process derived from a
given task block may be active at any given time" is therefore not
violated by this pattern at all — it's exactly the same "rearm the same
queue entry in place" transition already implemented (correctly) for a
*declaratively* cyclic task (`SCHEDULE label REPEAT EVERY/AFTER ...`,
handled at `CLOS` when such a task falls through to its own end,
interp.c) — a self-`SCHEDULE` from inside the body is that identical
mechanism spelled imperatively, and yaHALMAT2's original code simply
didn't recognize the two as the same thing.

**Fix**: `OP_SCHD` now detects a task scheduling itself (the target
task's sole active-task-table slot is the *currently-executing* task) and
routes it into updating that same task's own rearm parameters
(`priority`, `dependent`, `repeat_kind`/`repeat_interval`,
`stop_kind`/`stop_deadline`/`stop_event_syt`) rather than either failing
or creating a second task-table entry — `CLOS`'s existing, *unmodified*
rearm switch then picks these up naturally when this same task falls
through to its own `CLOSE` right after, exactly as it already does for an
externally-declared `REPEAT`. A self-`SCHEDULE` with no explicit `REPEAT`
clause (the common case, matching the bug report) synthesizes the
equivalent one-shot rearm from its plain immediate/`AT`/`IN` form, via
`SCHD_REPEAT_BARE` (immediate) or `SCHD_REPEAT_AFTER` (delayed) — chosen
because `AFTER`'s own documented semantics, "delay measured from this
cycle's completion", is exactly what a self-scheduled `IN`/`AT`, executed
right before this same cycle's own completion, means. Confirmed against
a real compile: `NEST` now correctly re-triggers itself repeatedly (every
1.0s) for as long as the primal process's own `WAIT` keeps the whole
program alive, and correctly stops when the primal reaches its own
`CLOSE` (per Sec. 13.1's "all other processes are always dependent on
the primal process for their existence" — an overriding rule regardless
of `DEPENDENT`/independent status between the tasks themselves).

Genuinely still unsupported, and still correctly rejected: a *different*
process targeting a task that's still active (not self-rescheduling) —
there's no "rearm in place" reading available there, since the calling
process isn't the one occupying that task's sole queue entry; and
self-rescheduling with an `ON <event>` condition (rather than a
time-based `AT`/`IN`/immediate/`REPEAT`), which doesn't cleanly map onto
the existing time-based rearm mechanism. See
`src/tests/hal/test_nested_task_schedule.hal` for the regression fixture.

## Waiting For Dependents At CLOSE

A second, related user-reported bug, this time against `COUNTUP2.hal`: a
`PROGRAM` (`COUNTUP2`) with **no** `WAIT` at all reaches its own `CLOSE`
immediately after `SCHEDULE NEXT PRIORITY(80) DEPENDENT, REPEAT EVERY
1.0;` — `NEXT` is scheduled `DEPENDENT`, meant to keep incrementing and
`WRITE`ing a counter, self-`CANCEL`ing once it exceeds 10. yaHALMAT2
previously ended the *whole program* the instant the primal reached
`CLOSE`, so `NEXT` got at most one execution in.

USA003087 Sec. 13.3 (p. 165/13-6, quoted directly by the user) draws a
distinction the code hadn't implemented: *"If execution ends on a CLOSE
or RETURN statement, the process goes into the inactive state directly
only if it has no dependents. Otherwise, it goes into a waiting state
until the dependents have in their turn terminated."* This is a
different, more specific rule than Sec. 13.1's *overriding* "all other
processes are always dependent on the primal process for their
existence" (which the original code's own comment cited) — that
overriding rule bounds how long anything else can possibly outlive the
primal, but says nothing about *when* the primal itself actually goes
inactive. The user initially wondered whether this CLOSE-specific rule
was meant only for multiple concurrently-scheduled `PROGRAM`s rather
than an ordinary `PROGRAM`/`TASK` relationship — but Sec. 13.3 opens with
*"Programs and tasks are treated together since their representations at
run time are in both cases real time processes,"* under the heading
"FLOW OF EXECUTION IN PROGRAM AND TASK BLOCKS" — an explicit statement
that this rule applies uniformly to both, not a program-to-program-only
concept. (Some residual uncertainty remains: the one worked real-time
example in this Guide, Sec. 13.6's SUPERVISOR/TIMER/CALCULATOR program,
sidesteps this exact case entirely — its tasks are scheduled *without*
`DEPENDENT`, and the primal ends via explicit `TERMINATE` (which
cascades unconditionally via the Sec. 13.1 override) rather than a
natural `CLOSE` fallthrough with active dependents, so there's no worked
example directly confirming this specific rule's runtime behavior.)

**Fix**: `halmat_task_t` gained a `parent_task` field (`state.h`), set at
task-creation time in `OP_SCHD` to whichever task executed the
`SCHEDULE` (self-rescheduling, above, reuses the same slot and leaves it
unchanged). A new `has_active_dependents()` helper (interp.c) checks
whether any task still has a given process as `parent_task`, is marked
`dependent`, and hasn't yet reached `TASK_TERMINATED`. `OP_CLOS`'s two
termination paths (the primal's own exit, and an ordinary task's
fallthrough-with-no-rearm) both now check this first: if there are
active dependents, the process transitions to a new
`TASK_WAITING_FOR_DEPENDENTS` state instead of terminating/halting
immediately (`symbol_active_task` is deliberately left pointing at it in
the meantime — it's still the sole active process for its own task
symbol, just in a different minor state, so a fresh `SCHEDULE` of the
same symbol must still be rejected). A new `sched_wake_dependents()`
scheduler function, polled every tick alongside `sched_wake_waiting()`/
`sched_wake_on_events()` (no fixed deadline to fast-forward to, same
reasoning as `TASK_WAITING_ON`), finalizes any such task once its
dependents have all terminated — halting the whole interpreter if it was
the primal (Sec. 13.1's override finally taking effect), or completing
an ordinary task's own deferred termination otherwise.

Confirmed against a real compile of the user's exact program: `NEXT` now
runs the full 10 iterations (`I`=1 through 10) and self-`CANCEL`s before
the program ends, rather than running once. This also **corrected an
existing fixture whose expected output had baked in the old, buggy
behavior**: `test_sched_low.hal` schedules a `DEPENDENT` `WORKER` at a
*lower* priority than the primal with no `WAIT`, so `WORKER` previously
never got to run at all before the (incorrectly) immediately-halting
primal ended everything; it now correctly runs (after the primal's own
remaining statements, since it's lower-priority, but before the whole
program actually ends) — see `src/tests/run_all.sh`'s updated
`sched_low` entry. See `src/tests/hal/test_countup2.hal` for the new
regression fixture matching the user's own program.

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
