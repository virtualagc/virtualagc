/* Minimal HAL/S TASK/SCHEDULE/WAIT task executive.
 *
 * Real AP-101S hardware has no such thing built in -- SCHEDULE/WAIT trap
 * via SVC directly into FCOS (the Shuttle flight-software OS), which is
 * firmware/ROM-resident and never linked into a compiled HAL/S program
 * (confirmed: no SCHD/task-scheduling module appears in any .fcm.LIST
 * for a program that uses TASK -- problems.md 2.7). Since yaGPC2 never
 * loads an OS, it has to substitute for FCOS's task-management SVCs
 * itself, at exactly the same level it already substitutes for FCOS's
 * SEND ERROR/QUIT/EVENT SVCs in halucp.c -- this file is that
 * substitute.
 *
 * SVC protocol (confirmed against a real compiled/linked program,
 * cross-checked against IBM-76-SS-1110 Rev 5 S4.2.1, the HAL/FCOS
 * Interface Control Document):
 *   SCHEDULE is always SVC #1. Parameter block at the SVC's own
 *   effective address (halfword-addressed, matching mcm_get16's own
 *   convention throughout this codebase):
 *     ea+0: high byte = PRIORITY (1-255), low byte = SVC# (1)
 *     ea+1: FLAGS word (2-bit fields -- PROGRAM/TASK, AT/IN/ON/none,
 *           DEPENDENT, REPEAT none(0x00)/BARE(0x40)/EVERY(0x80)/
 *           AFTER(0xC0) [bits 6-7], UNTIL-time-clause-present (0x0100)
 *           [bit 8, empirically confirmed alongside the REPEAT bits --
 *           see RepeatMode's own comment], CANCEL variant [not decoded
 *           by this file at all -- CANCEL is its own separate SVC, #4/
 *           #5, not a SCHEDULE FLAGS bit]. Any bit combination outside
 *           what this file explicitly recognizes falls through to the
 *           existing unhandled-SVC-trap path, which is always safe
 *           (matches today's behavior for any SCHEDULE variant this
 *           file doesn't yet understand) -- REPEAT ... WHILE/UNTIL
 *           event-expr (USA003087 24.5) remains one such unrecognized
 *           variant, out of scope for now.
 *     ea+2/+3: PROCESS -- the target task's 6-halfword PDE address
 *           (32-bit, hal_get32 convention)
 *     ea+4/+5: up to two Event Expression addresses (not read by this
 *           file -- AT/IN/ON/event-expression scheduling is out of
 *           scope for now)
 *   Time values arrive in floating-point register pairs, IBM
 *   double-precision seconds: AT/IN in FPR0-1 (unused here), REPEAT
 *   EVERY/AFTER in FPR2-3 (AFTER's own delay and EVERY's own interval
 *   share this same pair -- confirmed empirically), UNTIL in FPR4-5.
 *
 *   WAIT is SVC #6 (delta-time), #7 (UNTIL), #8 (event-expression), or
 *   #9 (DEPENDENT -- USA003087 13.5: "WAITING until all its dependent
 *   processes have terminated;" no parameters of its own, tests the
 *   calling task's own dependents); delta-time in FPR0-1.
 *
 * DEPENDENT (FLAGS bit 0x0020, confirmed empirically -- composes
 * additively with AT/IN/REPEAT EVERY exactly like every other FLAGS
 * bit): "SCHEDULE label PRIORITY(a) DEPENDENT;" makes the newly-created
 * process dependent on whichever process is executing the SCHEDULE
 * statement (USA003087 13.4) -- not on some separately-named parent, so
 * no extra SVC parameter is needed for it, only the one bit. Two
 * consequences, both confirmed directly from USA003087 13.3/13.5/23.6
 * (no compiler-inserted instructions accompany either -- confirmed
 * empirically that a parent task reaching its own bare CLOSE with a
 * still-active DEPENDENT child emits the exact same bare SVC 0x0015 as
 * every other CLOSE; this is entirely this file's own runtime
 * responsibility, the same "yaGPC2 substitutes for FCOS" reasoning as
 * everything else here):
 *   1. A task reaching its own natural CLOSE/RETURN with any DEPENDENT
 *      child still active does NOT deactivate immediately -- it goes
 *      into a waiting state (TASK_STATE_WAITING_FOR_DEPENDENTS) until
 *      every one of its DEPENDENT children has itself terminated, THEN
 *      deactivates (13.3: "the process goes into the inactive state
 *      directly only if it has no dependents. Otherwise, it goes into a
 *      waiting state until the dependents have in their turn
 *      terminated"). This is on top of, not instead of, the "does this
 *      exact CLOSE re-arm a REPEAT EVERY task" question
 *      sched_handle_task_close already answers -- it only applies to a
 *      non-REPEATing CLOSE that would otherwise free the slot.
 *   2. TERMINATE-ing a task (self or named) unconditionally terminates
 *      every one of its DEPENDENT descendants too, transitively down the
 *      whole dependency subtree, at the same time (13.3: "All dependents
 *      of the process are treated likewise"; 23.6 confirms this for
 *      cyclic processes specifically: "both the process and its
 *      dependents are terminated, possibly in mid-cycle"). Unlike case 1
 *      above, this is unconditional and immediate -- no graceful
 *      waiting; CANCEL is the graceful alternative -- see below.
 *
 * CANCEL (SVC #4 self / SVC #5 named -- confirmed empirically, mirroring
 * TERMINATE's own #2 self / #3 named split exactly, including the named
 * form's identical count-then-PDE-list encoding): the graceful sibling
 * of TERMINATE, described by USA003087 23.6. Effect depends on the
 * target's current state at the moment CANCEL executes:
 *   - RUNNING ("in a cycle of execution"): does NOT interrupt anything --
 *     confirmed empirically that a real compiled task's own statements
 *     immediately after a bare CANCEL; still execute completely normally
 *     (including their own WRITE calls -- this was surprising enough to
 *     be worth tracing a full instruction trace over, not just the SVC
 *     summary, before believing it). Only marks ScheduledTask.cancelled,
 *     checked by sched_handle_task_close at this task's own next CLOSE:
 *     a cancelled REPEAT EVERY task does not re-arm.
 *   - DORMANT (never yet initiated, OR waiting between cycles -- both
 *     produce the identical outcome per 23.6's own text): canceled
 *     immediately, via the same graceful "wait for any active
 *     DEPENDENT children to finish on their own, then deactivate"
 *     mechanism sched_handle_task_close's own CLOSE-with-dependents case
 *     uses (TASK_STATE_WAITING_FOR_DEPENDENTS / pendingCloseAfterDependents
 *     -- see schedule.c's sched_cancel_idx_and_dependents), rather than
 *     TERMINATE's unconditional-immediate free. Cascades to DEPENDENT
 *     descendants transitively too, but with CANCEL's own graceful
 *     semantics applied at every node (not TERMINATE's immediate one):
 *     23.6 -- "non-cyclic dependents are allowed to execute until their
 *     normal termination; cyclic dependents are allowed to finish their
 *     own current cycle of execution."
 *   - Not currently active at all (already terminated/completed, or the
 *     PDE was never SCHEDULEd): silent no-op, same precedent as
 *     TERMINATE's own named form for an unmatched target (23.6: "unless
 *     the process has not yet initiated they have no effect").
 * A task blocked in its own internal WAIT/WAIT FOR (TASK_STATE_WAITING,
 * mid-cycle rather than between cycles) is deliberately scoped OUT of
 * the "in a cycle of execution" bucket above and instead treated as
 * DORMANT -- no real fixture in this whole session has a TASK call WAIT
 * internally, so there's nothing to empirically confirm which reading
 * is correct, and the DORMANT-side outcome (immediate graceful cancel)
 * is the simpler, more conservative one to guess if this ever comes up.
 * REPEAT ... WHILE/UNTIL event-expr cancellation conditions remain out
 * of scope (no FLAGS bit for either is recognized), as does DEPENDENT
 * combined with ON (FLAGS 0x000d | 0x0020 = 0x002d is not empirically
 * confirmed and is left unrecognized, falling through
 * safely like any other unconfirmed combination).
 *
 * EXCLUSIVE procedures/functions (USA003087 27.2) and UPDATE blocks
 * (26.4) share one "reserve/release" SVC family, confirmed against
 * IBM-76-SS-1110 4.2.2/4.2.2.3 (the HAL/FCOS ICD documents this in full,
 * unlike most of this file's other protocol pieces, which had to be
 * reverse-engineered from traces alone) and then verified empirically:
 *   Entering an EXCLUSIVE procedure/function executes a RESERVE svc
 *   (code block, SVC #15); its own CLOSE executes RELEASE (SVC #17).
 *   Entering an UPDATE block executes RESERVE (data area, SVC #16); its
 *   own CLOSE executes RELEASE (SVC #18). Confirmed empirically that a
 *   PROCEDURE/FUNCTION's own CLOSE, unlike a TASK/PROGRAM's, does NOT
 *   compile to SVC 0x0015 at all -- it returns via an ordinary
 *   subroutine RETURN, entirely outside this file's existing CLOSE
 *   handling, so the release SVC is the only hook available or needed.
 *   All four share one 3-halfword parameter block, addressed differently
 *   by each of the two SVCs that read from it (confirmed empirically: a
 *   real compiled RESERVE's own ea and the matching RELEASE's own ea
 *   differ by exactly 1, i.e. RELEASE reads from halfword 1 of the same
 *   block RESERVE read from halfword 0):
 *     ea+0 (RESERVE's own ea): high bit (0x8000) = TYP (data-area
 *           RESERVE only: 1 = read-only, 0 = written; always 0 for a
 *           code-block RESERVE), low byte = RESERVE SVC# (15 or 16)
 *     ea+1 (RELEASE's own ea, i.e. RESERVE's ea+1): low byte = RELEASE
 *           SVC# (17 or 18)
 *     ea+2 (== RELEASE's own ea+1): LOCK ID -- for a code block, the
 *           address of the compiler-generated CSECT word reserved for
 *           that specific EXCLUSIVE procedure/function (confirmed
 *           empirically stable and distinct per procedure across
 *           repeated calls -- an exact-match key). For a data area, a
 *           bitmask of LOCK GROUPs (bit N-1 <-> group N, 1<=N<=15;
 *           LOCK(*) sets every bit) -- an overlap-match key, since
 *           USA003087 26.4's own group-based protection lets disjoint
 *           groups be held by different processes simultaneously.
 * A task blocked trying to RESERVE something already held is placed in
 * TASK_STATE_WAITING (ScheduledTask.waitingOnCodeLockId /
 * waitingOnDataLockMask -- see their own comments), polled by
 * sched_dispatch() the same way event expressions are, and its own
 * reserve SVC handler simply returns true once granted -- from the
 * blocked code's own perspective, RESERVE always eventually "just
 * succeeds," identical to how an event-expression WAIT FOR looks from
 * the inside. RELEASE never changes which context is live or forces a
 * dispatch (matching SCHEDULE/TERMINATE-of-another-task's own "never
 * changes which context is live" contract) -- any newly-eligible waiter
 * is picked up whenever the releasing context itself next blocks, not
 * immediately. A task that vanishes (TERMINATE/CANCEL) while still
 * holding a reservation is out of scope -- no real fixture exercises it,
 * and USA003087 doesn't define the behavior either.
 *
 * Event expressions (WAIT FOR SVC #8, and SCHEDULE ... ON, which reuses
 * the same descriptor format via the FLAGS-word AT+IN-bits-combined
 * signature below) -- confirmed empirically against 7 real compiled
 * signatures (N=1 plain, N=1 NOT, N=2/3/4 AND-chains, N=2/3 OR-chains),
 * and against the real HAL/S-FC PASS2 compiler's own behavior: it
 * rejects any *mixed* expression -- (A AND B) OR C, A AND NOT B -- with
 * "E102 ... INVALID EVENT EXPRESSION", so a single process name, a
 * single negated process name, or a flat homogeneous AND-chain/OR-chain
 * are the *entire* legal design space, not a partial case of something
 * bigger this file is choosing not to support yet.
 *   SVC #8's own parameter word (mem[ea+1]) is a pointer to a compact
 *   "event descriptor" living in the program's own static data:
 *     descAddr+0: opcodeWord -- encodes both operand count and
 *       AND/OR-ness. Top nibble (bits 12-15) = 2*(N-1), N = operand
 *       count; each of the remaining three nibbles is a connector code
 *       (3 = AND, 1 = OR) repeated N-1 times, zero-padded after that.
 *       N=1 with no connector at all is the literal 0x0000; N=1 negated
 *       (NOT <task>) is the distinct fixed value 0x1800, unrelated to
 *       the count/connector scheme above (NOT never combines with
 *       AND/OR or with N>1 -- the compiler itself forbids it).
 *     descAddr+1: reserved, always observed 0x0000.
 *     descAddr+2 .. descAddr+1+N: the N operand PDE addresses, flat
 *       units (same convention as SCHEDULE/TERMINATE's own PROCESS/
 *       target fields -- no decode_pde_far_pointer extension needed).
 *   Each operand's truth value is its own PDE+0 bit 0 (ACTIVE), the
 *   exact same bit "process name as Boolean" (USA003087 13.5) reads
 *   directly -- see sched_set_active_flag's own comment in schedule.c.
 *   USA003087 24.6 governs WAIT FOR's own semantics precisely: "If exp
 *   is already TRUE when the WAIT statement is executed, the statement
 *   has no effect" -- i.e. a WAIT FOR whose expression is already
 *   satisfied does NOT suspend the caller at all, even briefly, and
 *   does NOT give any other ready task a chance to run first (unlike
 *   delta-time WAIT, which always hands off to sched_dispatch()
 *   unconditionally). This is a real, spec-mandated behavioral
 *   difference from every other WAIT-family SVC this file implements --
 *   verified from the primary source text directly since no working
 *   cross-tool oracle exists for this feature (yaHALMAT2 itself has a
 *   confirmed bug here: it runs the awaited task and then simply never
 *   resumes the waiting context, for the identical test program, at any
 *   priority -- relayed upstream, not yet fixed).
 *   SCHEDULE ... ON reuses the identical descriptor format, referenced
 *   from SVC #1's own parameter block (ea+3, right after ea+2's PROCESS
 *   field) whenever FLAGS has the AT bit (0x0004) AND the IN bit
 *   (0x0008) both set together -- confirmed empirically that the real
 *   compiler reuses those two existing bits combined as the ON marker,
 *   rather than allocating ON a dedicated bit of its own. Unlike WAIT
 *   FOR, SCHEDULE ... ON never blocks the calling context at all (like
 *   every other SCHEDULE variant) -- it just marks the *target* task's
 *   own readiness as event-gated instead of deadline-gated, until the
 *   event fires. Combined with REPEAT EVERY is not empirically
 *   confirmed and is left unrecognized (falls through to the unhandled-
 *   SVC-trap path, same as any other FLAGS combination this file
 *   doesn't understand) -- see halucp.c's own FLAGS decode.
 *
 *   A task's own CLOSE compiles to the exact same SVC 0x0015 ("quit")
 *   the main program's CLOSE does -- confirmed directly (both compile
 *   to identical `SVC 0(R1)` with parameter word 0x0015). This means
 *   halucp.c's existing SVC 0x0015 handler can no longer unconditionally
 *   halt the CPU: it must ask sched_handle_task_close() first, and only
 *   fall through to its own halt logic when that returns false (meaning
 *   "this was the primal program's own CLOSE, or scheduling was never
 *   engaged at all" -- the exact condition under which every existing,
 *   TASK-less fixture must behave exactly as it does today).
 *
 * PDE layout (6 halfwords, confirmed against the same real linked
 * program via its RLD relocation table, matching the ICD's documented
 * layout):
 *   +0: PROCESS EVENT (true while scheduled/running) -- not modeled by
 *       this file; HAL/S programs practically never read a task's own
 *       PDE directly, and nothing in this cut needs it written.
 *   +1: FCOS-internal scratch -- unused by this file.
 *   +2: entry-point address, low-15-bits-plus-0x8000-extension-flag
 *       form (see decode_pde_far_pointer() below) -- the only PDE field
 *       this file actually reads.
 *   +3: empirically a second, un-flagged halfword identical across
 *       every task in the one program checked so far (hypothesized:
 *       related to the task's own data-segment base) -- not decoded or
 *       used by this file; not needed for entry-point dispatch.
 *   +4: stack address/size -- not read; the task's own compiled
 *       prologue self-initializes its own stack pointer from link-time
 *       constants (confirmed directly from the real compiled listing),
 *       so a freshly-dispatched task needs nothing from its saved
 *       context at all beyond NIA.
 *   +5: flags (stack-preallocated bit, MFID) -- not read.
 *
 * Cooperative-only dispatch: every context switch in this design
 * happens synchronously inside a SCHEDULE/WAIT/task-CLOSE SVC handler,
 * never mid-instruction-stream. This is sufficient for what HAL/S
 * TASK/SCHEDULE/WAIT actually need (yaHALMAT2's own scheduler is
 * equally non-preemptive) and means no changes are needed anywhere in
 * gpcops.c's or run.c's own step loops -- a switch is just "overwrite
 * psw.nia/registers with a different task's saved context before
 * returning true," and the very next fetch (in whichever driver's loop)
 * picks it up transparently, the same way halucp_handle_svc()'s other
 * SVC 0x0015 halt-via-wait-state already works today.
 */
#ifndef YAGPC_SCHEDULE_H
#define YAGPC_SCHEDULE_H

#include <stdbool.h>
#include <stdint.h>

#include "cpu.h"

#define SCHED_MAX_TASKS 32

typedef enum {
    TASK_SLOT_FREE = 0,
    TASK_STATE_READY,    /* immediately eligible, no deadline/event check
                           * needed -- previously never produced by anything
                           * in this cut (one-shot SCHEDULE/AT/IN go through
                           * DORMANT with a deadline instead); now also the
                           * state a task lands in once an explicit WAIT FOR
                           * DEPENDENT it was blocked on is satisfied (see
                           * sched_notify_dependent_finished), so it can be
                           * picked up by the very next sched_dispatch() call
                           * respecting normal priority ordering against
                           * whatever else is also eligible at that moment. */
    TASK_STATE_RUNNING,  /* this is the live CPU context right now */
    TASK_STATE_WAITING,  /* blocked in WAIT/WAIT FOR, wakeDeadlineUs or
                           * eventDescAddr is what it's waiting on */
    TASK_STATE_DORMANT,  /* a REPEATing task between firings, or a
                           * SCHEDULE ... ON target still pending its
                           * trigger event */
    TASK_STATE_WAITING_FOR_DEPENDENTS, /* reached its own CLOSE/RETURN, or
                           * hit an explicit WAIT FOR DEPENDENT, while at
                           * least one DEPENDENT child was still active
                           * (USA003087 13.3: "the process goes into a
                           * waiting state until the dependents have in
                           * their turn terminated"). Deliberately NOT one
                           * of the states sched_dispatch()'s own ready-scan
                           * recognizes (see its own loop condition) -- a
                           * task here is invisible to normal dispatch, not
                           * a candidate for anything, until
                           * sched_notify_dependent_finished's own cascade
                           * check (triggered whenever some other task
                           * fully deactivates) finds it has zero remaining
                           * active dependents and moves it on:
                           * pendingCloseAfterDependents decides whether
                           * that means freeing the slot (the implicit
                           * CLOSE-with-dependents case) or becoming
                           * TASK_STATE_READY to resume execution (the
                           * explicit WAIT FOR DEPENDENT case). */
} TaskState;

/* Saved AP-101 execution context. Mirrors ageharness.h's RegSnapshot
 * shape deliberately (same fields, same meaning) but is not the same
 * type: schedule.h sits below the AGEHarness layer and must not #include
 * ageharness.h (that would be a layering inversion -- the harness is
 * built on top of the core runtime, not the other way around). Only
 * register bank 0 (R0-R7) is saved/restored, not bank 1 (R8-R15):
 * confirmed nothing in COUNTUP.hal or any installed interrupt vector
 * (none are installed -- no OS is loaded) ever touches bank 1 or the
 * PSW's register-set-select bit, so this is a deliberate, documented
 * simplification for this cut, not a silent gap. */
typedef struct {
    uint32_t r[8];
    uint32_t fp[8];
    uint32_t nia;
    uint32_t cc;
    uint32_t psw1, psw2;
} TaskContext;

/* SCHEDULE's cyclic-recycling mode -- the FLAGS word's own 2-bit field
 * (bits 6-7, values 0x00/0x40/0x80/0xC0 -- see halucp.c's own FLAGS-bit
 * decode and this file's SVC-protocol header comment), confirmed
 * empirically against three real compiled programs (REPEAT bare,
 * REPEAT AFTER, and the already-known REPEAT EVERY): USA003087 23.5's
 * "IMMEDIATE RECYCLING" (bare REPEAT, no numeric parameter -- next cycle
 * starts the instant the previous one's CLOSE runs), "RECYCLING AT
 * SPECIFIED INTERVALS" (REPEAT EVERY, already implemented -- fixed
 * interval measured from the START of the previous cycle, phase-
 * anchored to avoid drift), and "CONSTANT INTERCYCLE DELAY" (REPEAT
 * AFTER, a fixed delay measured from the END of the previous cycle --
 * no phase anchor needed, by definition it can never drift). */
typedef enum {
    SCHED_REPEAT_NONE = 0,
    SCHED_REPEAT_BARE,   /* FLAGS 0x0040 */
    SCHED_REPEAT_EVERY,  /* FLAGS 0x0080 */
    SCHED_REPEAT_AFTER,  /* FLAGS 0x00C0 */
} RepeatMode;

typedef struct {
    TaskState state;
    uint32_t pdeAddr;    /* halfword address of this task's 6-halfword PDE */
    uint32_t entryPoint; /* decoded from PDE+2 at (re-)dispatch time */
    int priority;        /* 0-255, from the SCHEDULE SVC's own priority byte */
    bool isPrimal;        /* true for the one "main program" pseudo-task */

    /* Whether ctx (below) holds a real saved context yet. A freshly-
     * SCHEDULEd REPEAT-EVERY task goes straight to DORMANT without ever
     * passing through a first RUNNING dispatch, so TaskState alone can't
     * distinguish "never run, dispatch fresh to entryPoint" from "has
     * run before, resume from ctx" -- this field is what does. */
    bool hasRun;

    bool hasRepeat;
    RepeatMode repeatMode;    /* SCHED_REPEAT_NONE whenever !hasRepeat; the
                                * cadence used to re-arm at CLOSE (see
                                * sched_handle_task_close) -- BARE/AFTER
                                * ignore repeatPhaseRefUs entirely (no phase
                                * anchor, see RepeatMode's own comment) */
    double repeatIntervalUs;  /* 0 if one-shot (TASK_STATE_READY, not yet used) */
    double repeatPhaseRefUs;  /* anchor for drift-free EVERY re-arming: next
                                * deadline is always phaseRef + N*interval for
                                * the smallest N putting it in the future,
                                * never "now + interval" (which would drift by
                                * however late the previous firing ran) --
                                * meaningless for BARE/AFTER, see above */

    /* USA003087 23.5's UNTIL-time cancellation clause (any of the three
     * cyclic SCHEDULE forms may carry one, FLAGS bit 0x0100, value in
     * FPR4-5 -- confirmed empirically alongside the REPEAT-mode bits
     * above): an absolute cpu->elapsedTimeUs value (same units/origin as
     * wakeDeadlineUs) past which this task cancels instead of re-arming.
     * "Cancellation actually takes place at the end of the first cycle
     * which finishes later than the specified time" (checked at CLOSE,
     * sched_handle_task_close) "...with the provision that if the
     * cancellation condition is met in the interval between cycles,
     * cancellation takes place immediately" (checked every DORMANT task
     * on every sched_dispatch() call, see its own pre-pass) -- both
     * checks reuse the exact same cancelled-at-CLOSE /
     * sched_cancel_idx_and_dependents machinery CANCEL itself uses,
     * since USA003087 23.6 describes this as the same underlying
     * cancellation mechanism, not a separate one ("cancellation
     * conditions in SCHEDULE statements cannot be dynamically modified;
     * to cancel a cyclic process arbitrarily, the CANCEL statement must
     * therefore be used" -- implying REPEAT...UNTIL and CANCEL differ
     * only in how cancellation is *triggered*, not in what it *does*). */
    bool hasUntilTime;
    double untilTimeUs;

    /* USA003087 24.5's event-expression cancellation clauses -- "REPEAT
     * cycle WHILE exp" and "REPEAT cycle UNTIL exp" (exp an event
     * expression, not to be confused with the numeric UNTIL-time clause
     * above; FLAGS bit 0x0200 confirmed empirically, composing with bit
     * 0x0100 to distinguish WHILE (0x0200 alone) from UNTIL (0x0200 |
     * 0x0100) -- see halucp.c's own FLAGS-bit decode). descAddr points
     * to the identical event-expression descriptor format WAIT FOR/
     * SCHEDULE ... ON already use (this file's own header comment) --
     * confirmed via a real compiled program that FLAGS 0x0200's own
     * pointer field (ea+4, the same slot the numeric-UNTIL value would
     * otherwise occupy in FPR4-5 -- these two clauses are mutually
     * exclusive in the real grammar, never combined) resolves to that
     * exact [opcodeWord, reserved, PDE...] shape.
     *
     * WHILE (isUntilForm == false): cycling continues while exp is TRUE;
     * cancels once exp is FALSE -- checked BOTH at CLOSE and, per 24.5's
     * own "if the value of exp becomes FALSE before the process is
     * initiated, it is merely removed... without ever executing," even
     * before this task's very first dispatch (sched_dispatch's own
     * pre-pass applies this check unconditionally, hasRun or not).
     *
     * UNTIL (isUntilForm == true): cycling continues until exp becomes
     * TRUE; cancels once exp is TRUE -- but 24.5 explicitly guarantees
     * "at least one cycle shall be executed" regardless of exp's initial
     * value, unlike WHILE -- so sched_dispatch's own pre-pass only
     * applies this check once completedFirstCycle is already true (i.e.
     * never before this task's own first CLOSE, only from its second
     * DORMANT period onward -- NOT gated on hasRun, which is reset back
     * to false by every re-arm, including the first one, so it can't
     * distinguish "never run" from "between cycle 2 and 3"; a real,
     * caught-by-testing bug in an earlier draft of this feature).
     * Both forms are otherwise checked exactly like hasUntilTime above:
     * at CLOSE (sched_handle_task_close) and immediately during the
     * intercycle DORMANT gap (sched_dispatch's own pre-pass), reusing
     * the same sched_cancel_idx_and_dependents machinery CANCEL and the
     * numeric UNTIL-time clause both already use. Unlike hasUntilTime,
     * this is never a fast-forward candidate -- no amount of virtual-
     * time advancement alone can resolve an event condition (same
     * reasoning as eventDescAddr below), so sched_dispatch's pre-pass
     * re-checks it on every call it makes regardless of what (if
     * anything) time advanced to satisfy. */
    bool hasUntilEvent;
    bool untilEventIsUntilForm;
    uint32_t untilEventDescAddr;
    bool completedFirstCycle; /* set true the first time this task's own
                                * CLOSE is ever processed (sched_handle_
                                * task_close), regardless of whether that
                                * CLOSE goes on to re-arm or cancel --
                                * unlike hasRun (above), never reset back
                                * to false; exists purely for
                                * untilEventIsUntilForm's own "at least
                                * one cycle" gate. */

    double wakeDeadlineUs;    /* meaningful when WAITING or DORMANT, and
                                * only when eventDescAddr is 0 -- see below */

    /* Nonzero when this task's own readiness is gated by an event
     * expression rather than (or in addition to being alongside) a
     * deadline: either it's blocked in a WAIT FOR (state WAITING,
     * set by sched_handle_wait_for_svc) or it's a SCHEDULE ... ON
     * target still pending its trigger event (state DORMANT, set by
     * sched_handle_schedule_on_svc). Halfword address of the event
     * descriptor (see the "Event expressions" section of this file's
     * own header comment); wakeDeadlineUs is meaningless while this is
     * set -- sched_dispatch() tests the event expression instead, and
     * never fast-forwards virtual time on this task's account, since no
     * amount of elapsed time alone can satisfy an event condition.
     * Cleared by sched_dispatch() the moment this task is actually
     * dispatched, so a later re-SCHEDULE/WAIT of the same slot never
     * inherits a stale pointer from this task's previous use of it. */
    uint32_t eventDescAddr;

    /* Index of the task this one is DEPENDENT on (the task that was
     * RUNNING when this one's own SCHEDULE ... DEPENDENT executed), or
     * -1 if independent (USA003087 13.4: "In its absence, the processes
     * are independent" -- the default, so every SCHEDULE-family function
     * must explicitly set this, never rely on memset's 0 default, since
     * 0 is itself a valid slot index). Always -1 for the primal
     * pseudo-task (it has no parent). */
    int parentIdx;

    /* Meaningful only in TASK_STATE_WAITING_FOR_DEPENDENTS: true if this
     * task reached its own natural CLOSE/RETURN and is only waiting to
     * be freed (the implicit case, USA003087 13.3), false if it hit an
     * explicit WAIT FOR DEPENDENT mid-execution and should resume
     * (become TASK_STATE_READY, restored from ctx) once satisfied
     * instead. */
    bool pendingCloseAfterDependents;

    /* Set by CANCEL (self or named) when the target is currently RUNNING
     * -- "in a cycle of execution" per USA003087 13.5/23.6 -- meaning
     * cancellation can't take effect until this cycle finishes naturally.
     * Confirmed empirically that a bare self-CANCEL does NOT alter
     * control flow at all (a real compiled task's own statements *after*
     * a bare CANCEL; still execute completely normally, including their
     * own WRITE calls) -- so this flag is purely a marker
     * sched_handle_task_close checks at the task's own next CLOSE: a
     * cancelled REPEAT-EVERY task does not re-arm (falls through to the
     * same has-active-dependents-or-free path a non-repeating task
     * already uses), exactly matching CANCEL's own graceful,
     * end-of-cycle semantics. Never set for a target that's DORMANT (not
     * currently executing) -- USA003087 23.6: "waiting between cycles...
     * canceled immediately," handled directly by
     * sched_cancel_idx_and_dependents instead, with no flag involved. */
    bool cancelled;

    /* EXCLUSIVE procedures/functions (USA003087 27.2) and UPDATE blocks
     * (26.4) -- see this file's own header comment for the SVC protocol
     * (confirmed against IBM-76-SS-1110 4.2.2/4.2.2.3, then verified
     * empirically). Nonzero iff this task is currently WAITING to
     * acquire a code-block lock (an EXCLUSIVE procedure/function someone
     * else is already inside) -- schedule.c's Scheduler.codeLocks is the
     * source of truth for who currently holds what; this is purely the
     * dispatch-eligibility gate sched_dispatch() polls, mirroring
     * eventDescAddr's own pattern. */
    uint32_t waitingOnCodeLockId;

    /* Nonzero iff this task is currently WAITING to acquire a data-area
     * lock (UPDATE block) whose LOCK GROUP bitmask overlaps one or more
     * groups some other task currently holds. */
    uint32_t waitingOnDataLockMask;

    /* Bitmask (bit N-1 <-> lock group N, 1<=N<=15; LOCK(*) sets every
     * bit) of the LOCK GROUPs this task currently holds via one or more
     * still-open UPDATE blocks. Unlike code-block locks (exclusive,
     * exact-match, tracked in Scheduler.codeLocks below), multiple tasks
     * can simultaneously hold *disjoint* lock groups at once -- USA003087
     * 26.4's own "protection... on a group basis" -- so this lives per-
     * task rather than in a single global holder table; sched_dispatch()
     * treats the OR of every active task's own heldDataLockMask as "what's
     * currently locked" when checking a waiter's own requested mask for
     * overlap. */
    uint32_t heldDataLockMask;

    TaskContext ctx;      /* saved whenever this task is not RUNNING */
} ScheduledTask;

/* One EXCLUSIVE procedure/function's own reservation state. lockId is the
 * compiler-generated CSECT word's own address (USA003087/ICD: "one word
 * ... compiled as zero and reserved for FCOS use" per EXCLUSIVE block,
 * confirmed empirically stable and distinct per procedure/function across
 * repeated calls) -- an exact-match key, unlike UPDATE blocks' own
 * bitmask-overlap semantics (see ScheduledTask.heldDataLockMask above).
 * lockId == 0 means this slot is free (never used, or last release
 * cleared it) -- a real CSECT word's own address is never actually 0 in
 * any linked program this codebase has ever seen, so this is a safe
 * sentinel. */
typedef struct {
    uint32_t lockId;
    int holderIdx; /* meaningful only when lockId != 0 */
} CodeLock;

#define SCHED_MAX_CODE_LOCKS 16

typedef struct {
    ScheduledTask tasks[SCHED_MAX_TASKS];
    int count;
    int runningIdx; /* index of the TASK_STATE_RUNNING slot, or -1 if the
                      * scheduler has never been engaged (the common case
                      * for every fixture with no TASK/SCHEDULE at all) */
    CodeLock codeLocks[SCHED_MAX_CODE_LOCKS];
} Scheduler;

void sched_init(Scheduler *s);

/* Called from halucp.c's SVC dispatch for SVC #1 (SCHEDULE) once its
 * FLAGS word is recognized as one of the signatures this cut supports
 * (TASK, with any combination of a plain/AT/IN initiation, a plain/
 * BARE/EVERY/AFTER cycling, and a numeric-UNTIL-time or event-expr
 * WHILE/UNTIL cancellation clause -- see halucp.c's own FLAGS-bit
 * decode; the numeric and event-expr cancellation clauses are mutually
 * exclusive in the real grammar, never combined, so hasUntilTime and
 * hasUntilEvent are never both true). priority/pdeAddr/repeatMode/
 * repeatIntervalUs/untilTimeUs/untilEventDescAddr are already decoded
 * by the caller (priority from the SVC param byte, pdeAddr via
 * mcm_get16, repeatMode from FLAGS bits 6-7, repeatIntervalUs from
 * FPR2-3 when repeatMode is EVERY or AFTER, untilTimeUs from FPR4-5
 * when hasUntilTime, untilEventDescAddr from ea+4 when hasUntilEvent,
 * all via floatIBM.h/mcm_get16). initialWakeDeadlineUs is the absolute cpu->elapsedTimeUs
 * value at which the task should first become ready -- plain SCHEDULE
 * passes cpu->elapsedTimeUs itself (due now, unchanged from this
 * function's original due-immediately-only behavior); AT/IN pass an
 * already-computed absolute deadline (already clamped to not be in the
 * past, matching sched_handle_wait_until_svc's "does not leave READY"
 * precedent for an AT time already passed). This same value anchors
 * REPEAT EVERY's own phase reference too, so "SCHEDULE X IN 1.5, REPEAT
 * EVERY 1.0" fires at 1.5, 2.5, 3.5, ... (anchored to the actual
 * first-due time), not 0, 1, 2, ... -- meaningless for BARE/AFTER (see
 * RepeatMode's own comment). Never changes which context is live -- the
 * calling program's own NIA just continues normally afterward, matching
 * how every other already-handled SVC (SEND ERROR, SIGNAL/SET/RESET)
 * behaves. dependent is whether FLAGS' 0x0020 bit was set (USA003087
 * 13.4's DEPENDENT keyword): if true, the new task's own parentIdx
 * becomes whichever task is currently running (lazily engaging the
 * primal pseudo-task first, same as sched_handle_wait_svc's own lazy-
 * allocation, if scheduling has never been engaged before -- a
 * program's very first statement can legally be a DEPENDENT SCHEDULE).
 * Always returns true (this file only gets called once the FLAGS word
 * is already confirmed recognized). */
bool sched_handle_schedule_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr,
                                double initialWakeDeadlineUs, RepeatMode repeatMode,
                                double repeatIntervalUs, bool hasUntilTime, double untilTimeUs,
                                bool hasUntilEvent, bool untilEventIsUntilForm, uint32_t untilEventDescAddr,
                                bool dependent);

/* Called from halucp.c's SVC dispatch for SVC #6 (delta-time WAIT).
 * Suspends the currently-running context (lazily creating the "primal"
 * pseudo-task on first use, if scheduling has never been engaged
 * before) and dispatches whatever's next. Always returns true. */
bool sched_handle_wait_svc(Scheduler *s, CPU *cpu, double deltaSeconds);

/* Called from halucp.c's SVC dispatch for SVC #7 (WAIT UNTIL, absolute
 * time). USA003087 13.5: "a time already in the past... does not leave
 * READY" -- i.e. WAIT UNTIL is defined purely in terms of the same
 * delta-time semantics sched_handle_wait_svc already implements, with
 * the delta computed here (absoluteSeconds minus the current virtual
 * time, floored at zero so an already-past target is a zero-length
 * wait rather than a negative one) and handed off to it -- this file's
 * "absolute time origin" is simply cpu->elapsedTimeUs's own t=0 (program
 * start), matching the Guide's own "normally coincident with the
 * initiation of the primal process" default for implementations that
 * don't otherwise define one (confirmed empirically: a real compiled
 * WAIT UNTIL loads its argument into FPR0-1, the exact same register
 * pair delta-time WAIT uses -- there is no separate "AT" register pair
 * reserved for it the way SCHEDULE's own AT/IN/EVERY/AFTER/UNTIL
 * parameters each get their own FPR pair per schedule.c's header
 * comment). Always returns true. */
bool sched_handle_wait_until_svc(Scheduler *s, CPU *cpu, double absoluteSeconds);

/* Called from halucp.c's existing SVC 0x0015 case, before any of its
 * current halt logic. Returns true iff this was a scheduled task's own
 * CLOSE (already fully handled here -- re-armed if REPEATing; otherwise
 * freed immediately if it has no currently-active DEPENDENT children, or
 * parked in TASK_STATE_WAITING_FOR_DEPENDENTS until they all finish if
 * it does (USA003087 13.3 -- see this file's own header comment); either
 * way the next ready task is already dispatched; caller should return
 * without doing anything else). Returns false iff the currently running
 * context is the primal program (or the scheduler has never been
 * engaged at all) -- caller's existing halt-the-CPU behavior must run
 * completely unchanged in that case. This is the whole backward-
 * compatibility guarantee for every fixture that never uses
 * TASK/SCHEDULE. */
bool sched_handle_task_close(Scheduler *s, CPU *cpu);

/* Called from halucp.c's SVC dispatch for SVC #2 (bare "TERMINATE;",
 * self-targeting -- USA003087 13.5: "self, if label omitted"). Unlike
 * sched_handle_task_close(), TERMINATE always deactivates immediately
 * regardless of REPEAT status -- a REPEATing task that TERMINATEs
 * itself does NOT get re-armed, unlike one that simply reaches its own
 * CLOSE. Returns false (falls through to the caller's own unhandled-SVC
 * path) if the running context is the primal program or scheduling was
 * never engaged -- a primal process terminating *itself* is out of
 * scope for this cut (no real fixture exercises it; real flight
 * software's primal process ends via its own CLOSE, not self-
 * TERMINATE). Otherwise always returns true. */
bool sched_handle_terminate_self_svc(Scheduler *s, CPU *cpu);

/* Called from halucp.c's SVC dispatch for SVC #3 ("TERMINATE
 * label[,label...];", named-target form). pdeAddrs/count are already
 * decoded by the caller (each pdeAddr already in the same flat, native
 * units sched_handle_schedule_svc's own PROCESS field uses). Each named
 * task, if currently active, is deactivated immediately (same
 * unconditional-regardless-of-REPEAT semantics as the self form above);
 * a name that doesn't match any active task is silently ignored (USA003087
 * 13.5 doesn't define an error for this, and it's a natural no-op --
 * nothing to terminate). If one of the named targets turns out to be the
 * task currently running (TERMINATE naming itself, or one process
 * TERMINATEing another that then turns out to be itself -- both legal
 * per the Guide), the currently-running context changes and the next
 * ready task is dispatched, exactly like the self form; otherwise the
 * calling context is left running unchanged, exactly like SCHEDULE.
 * Every named target's own DEPENDENT descendants (if any) are also
 * unconditionally terminated, transitively down the whole subtree
 * (USA003087 13.3/23.6 -- see this file's own header comment), and if
 * terminating a target leaves ITS OWN parent (if any) with zero
 * remaining active dependents, that parent is released from
 * TASK_STATE_WAITING_FOR_DEPENDENTS too (sched_notify_dependent_finished
 * -- the same mechanism a natural CLOSE-with-dependents uses). Always
 * returns true. */
bool sched_handle_terminate_named_svc(Scheduler *s, CPU *cpu, const uint32_t *pdeAddrs, int count);

/* Called from halucp.c's SVC dispatch for SVC #11 (UPDATE PRIORITY
 * label TO alpha, named-target form only -- USA003087 13.5's bare/self
 * form, "UPDATE PRIORITY TO alpha;" with no label, is not covered: a
 * real compiled test case for it hits a genuine HAL/S-FC PASS2 compiler
 * limitation ("INDIRECT STACK USAGE CONFLICT", statement conversion
 * abandoned) unrelated to yaGPC2 -- there is no compiled program to
 * trace its SVC encoding from, so it's left unhandled rather than
 * guessed at). Confirmed empirically: the SVC parameter word is
 * (newPriority<<8)|11, followed by the target task's own PDE address
 * (flat units, same as SCHEDULE/TERMINATE's own PROCESS/target
 * fields). Mutates the target's priority in place and does NOT
 * change which context is live or trigger a dispatch -- the new
 * priority simply takes effect at whatever future dispatch decision
 * next considers that task, matching how SCHEDULE/TERMINATE-of-another-
 * task both leave the calling context running unchanged. A pdeAddr not
 * matching any currently-active task is a silent no-op (same precedent
 * as sched_handle_terminate_named_svc). Always returns true. */
bool sched_handle_update_priority_svc(Scheduler *s, CPU *cpu, int newPriority, uint32_t pdeAddr);

/* Called from halucp.c's SVC dispatch for SVC #8 (WAIT FOR <event-
 * expression>). eventDescAddr is the descriptor's own halfword address
 * (already decoded by the caller from the SVC's own parameter word --
 * see this file's own header comment for the descriptor format).
 * USA003087 24.6: "If exp is already TRUE when the WAIT statement is
 * executed, the statement has no effect" -- checked FIRST, before any
 * lazy primal allocation or dispatch, so an already-true WAIT FOR is a
 * true no-op with zero side effects, not even a context save/restore.
 * Otherwise behaves like sched_handle_wait_svc: suspends the calling
 * context (lazily creating the primal pseudo-task on first use, same as
 * that function) and dispatches whatever's next -- except the suspended
 * task's own resumption is gated on the event expression becoming true
 * (re-evaluated by sched_dispatch() itself, not on a fixed deadline).
 * Always returns true. */
bool sched_handle_wait_for_svc(Scheduler *s, CPU *cpu, uint32_t eventDescAddr);

/* Called from halucp.c's SVC dispatch for SVC #1 (SCHEDULE) once its
 * FLAGS word is recognized as the ON signature (TASK + AT-and-IN-bits-
 * combined, no REPEAT EVERY -- see this file's own header comment).
 * Unlike sched_handle_schedule_svc, never blocks or changes which
 * context is live (matches every other SCHEDULE variant's own "never
 * changes which context is live" contract) -- it registers the target
 * task exactly as an immediate SCHEDULE would (PDE decoded, marked
 * ACTIVE immediately, matching USA003087 13.1's "in the process queue"
 * definition of ACTIVE, same as AT/IN's own already-established
 * precedent), except its readiness is gated on eventDescAddr's
 * expression becoming true instead of a deadline. Always returns
 * true. */
bool sched_handle_schedule_on_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr, uint32_t eventDescAddr);

/* Called from halucp.c's SVC dispatch for SVC #9 (WAIT FOR DEPENDENT).
 * USA003087 13.5: "the process is to be placed in the waiting [state]
 * until all its dependent processes have terminated. If there are no
 * dependents, the statement has no effect" -- the same "already-
 * satisfied is a true no-op" precedent sched_handle_wait_for_svc
 * established for event expressions, checked here first (lazily
 * engaging the primal pseudo-task only if there's something to actually
 * wait for, same reasoning). Otherwise suspends the calling context in
 * TASK_STATE_WAITING_FOR_DEPENDENTS with pendingCloseAfterDependents
 * false (resume execution once satisfied, not free the slot -- see this
 * file's own header comment) and dispatches whatever's next. Always
 * returns true. */
bool sched_handle_wait_for_dependent_svc(Scheduler *s, CPU *cpu);

/* Called from halucp.c's SVC dispatch for SVC #4 (bare "CANCEL;",
 * self-targeting -- USA003087 13.5/23.6: "self, if label omitted", same
 * convention as bare TERMINATE). Since CANCEL of the RUNNING context
 * only ever flags ScheduledTask.cancelled (see this file's own header
 * comment) and never changes control flow, this is implemented directly
 * in terms of the named form naming its own PDE -- sched_cancel_idx's
 * own idx == s->runningIdx check always matches for the self case.
 * Returns false (falls through to the caller's own unhandled-SVC path)
 * if the running context is the primal program or scheduling was never
 * engaged -- same out-of-scope reasoning as
 * sched_handle_terminate_self_svc. Otherwise always returns true. */
bool sched_handle_cancel_self_svc(Scheduler *s, CPU *cpu);

/* Called from halucp.c's SVC dispatch for SVC #5 ("CANCEL
 * label[,label...];", named-target form). pdeAddrs/count are already
 * decoded by the caller, identical convention to
 * sched_handle_terminate_named_svc's own count-then-PDE-list encoding.
 * Each named target is canceled per this file's own header comment
 * (flagged if RUNNING, gracefully deactivated immediately -- cascading
 * to its own DEPENDENT descendants the same way -- if DORMANT, silently
 * ignored if not currently active). Never changes which context is live
 * or triggers a dispatch (a target that's RUNNING is, by construction,
 * always the calling context itself -- see this file's own header
 * comment -- and flagging it doesn't change control flow; a target
 * that's immediately, gracefully deactivated is by definition not the
 * calling context, matching SCHEDULE/TERMINATE-of-another-task's own
 * "never changes which context is live" contract). Always returns
 * true. */
bool sched_handle_cancel_named_svc(Scheduler *s, CPU *cpu, const uint32_t *pdeAddrs, int count);

/* Called from halucp.c's SVC dispatch for SVC #15 (RESERVE, code block
 * -- entering an EXCLUSIVE procedure/function). lockId is the target
 * procedure/function's own CSECT-word address (already decoded by the
 * caller). If unheld, grants it to the calling context immediately (no
 * blocking, no dispatch -- matches every other already-handled SVC's
 * "never changes which context is live" contract when nothing contends).
 * If already held by a different task, suspends the calling context
 * (lazily creating the primal pseudo-task on first use, same pattern as
 * sched_handle_wait_svc, only reached on this specific path since the
 * immediately-granted case never needs a real scheduler slot at all --
 * even the primal, un-engaged, can legitimately "hold" a lock via the
 * sentinel runningIdx value -1) and dispatches whatever's next; the
 * blocked task's own RESERVE simply returns true once
 * sched_dispatch() later grants it the lock (see this file's own header
 * comment). Always returns true. */
bool sched_handle_reserve_code_svc(Scheduler *s, CPU *cpu, uint32_t lockId);

/* Called from halucp.c's SVC dispatch for SVC #17 (RELEASE, code block
 * -- CLOSE of an EXCLUSIVE procedure/function). Clears the calling
 * context's own hold on lockId. Never changes which context is live or
 * triggers a dispatch -- see this file's own header comment for why.
 * Always returns true. */
bool sched_handle_release_code_svc(Scheduler *s, CPU *cpu, uint32_t lockId);

/* Called from halucp.c's SVC dispatch for SVC #16 (RESERVE, data area --
 * entering an UPDATE block). lockGroupMask is the requested LOCK GROUP
 * bitmask (already decoded by the caller). If it doesn't overlap any
 * lock group currently held by any other active task, grants it
 * immediately (added to the calling context's own
 * ScheduledTask.heldDataLockMask, no blocking). Otherwise suspends the
 * calling context exactly like sched_handle_reserve_code_svc, polled by
 * sched_dispatch() for the overlap to clear. Always returns true. */
bool sched_handle_reserve_data_svc(Scheduler *s, CPU *cpu, uint32_t lockGroupMask);

/* Called from halucp.c's SVC dispatch for SVC #18 (RELEASE, data area --
 * CLOSE of an UPDATE block). Clears lockGroupMask's own bits from the
 * calling context's own heldDataLockMask. Never changes which context
 * is live or triggers a dispatch. Always returns true. */
bool sched_handle_release_data_svc(Scheduler *s, CPU *cpu, uint32_t lockGroupMask);

#endif
