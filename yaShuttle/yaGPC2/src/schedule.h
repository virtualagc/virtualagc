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
 * substitute, scoped to what real FCOS itself supported: no DEPENDENT,
 * no UPDATE PRIORITY (see below).
 *
 * SVC protocol (confirmed against a real compiled/linked program,
 * cross-checked against IBM-76-SS-1110 Rev 5 S4.2.1, the HAL/FCOS
 * Interface Control Document):
 *   SCHEDULE is always SVC #1. Parameter block at the SVC's own
 *   effective address (halfword-addressed, matching mcm_get16's own
 *   convention throughout this codebase):
 *     ea+0: high byte = PRIORITY (1-255), low byte = SVC# (1)
 *     ea+1: FLAGS word (2-bit fields -- PROGRAM/TASK, AT/IN/ON/none,
 *           DEPENDENT, REPEAT none/REPEAT/EVERY/AFTER, CANCEL variant).
 *           This file only recognizes the one signature needed so far
 *           (TASK, REPEAT EVERY, nothing else set) -- anything else
 *           falls through to the existing unhandled-SVC-trap path,
 *           which is always safe (matches today's behavior for any
 *           SCHEDULE variant this file doesn't yet understand).
 *     ea+2/+3: PROCESS -- the target task's 6-halfword PDE address
 *           (32-bit, hal_get32 convention)
 *     ea+4/+5: up to two Event Expression addresses (not read by this
 *           file -- AT/IN/ON/event-expression scheduling is out of
 *           scope for now)
 *   Time values arrive in floating-point register pairs, IBM
 *   double-precision seconds: AT/IN in FPR0-1 (unused here), REPEAT
 *   EVERY/AFTER in FPR2-3, UNTIL in FPR4-5 (unused here).
 *
 *   WAIT is SVC #6 (delta-time), #7 (UNTIL), #8 (event-expression), or
 *   #9 (DEPENDENT, out of scope -- no task is ever created as anyone's
 *   dependent, since SCHEDULE's own FLAGS-word gate never recognizes
 *   DEPENDENT); delta-time in FPR0-1.
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
    TASK_STATE_READY,    /* scheduled once, not repeating, not yet due (not
                           * currently produced by anything in this cut --
                           * REPEAT EVERY tasks go straight to DORMANT --
                           * kept for a future one-shot SCHEDULE, AT/IN). */
    TASK_STATE_RUNNING,  /* this is the live CPU context right now */
    TASK_STATE_WAITING,  /* blocked in WAIT, wakeDeadlineUs is when it resumes */
    TASK_STATE_DORMANT,  /* a REPEATing task between firings */
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
    double repeatIntervalUs;  /* 0 if one-shot (TASK_STATE_READY, not yet used) */
    double repeatPhaseRefUs;  /* anchor for drift-free EVERY re-arming: next
                                * deadline is always phaseRef + N*interval for
                                * the smallest N putting it in the future,
                                * never "now + interval" (which would drift by
                                * however late the previous firing ran) */

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

    TaskContext ctx;      /* saved whenever this task is not RUNNING */
} ScheduledTask;

typedef struct {
    ScheduledTask tasks[SCHED_MAX_TASKS];
    int count;
    int runningIdx; /* index of the TASK_STATE_RUNNING slot, or -1 if the
                      * scheduler has never been engaged (the common case
                      * for every fixture with no TASK/SCHEDULE at all) */
} Scheduler;

void sched_init(Scheduler *s);

/* Called from halucp.c's SVC dispatch for SVC #1 (SCHEDULE) once its
 * FLAGS word is recognized as one of the signatures this cut supports
 * (TASK, with any combination of a plain/AT/IN initiation and a plain/
 * REPEAT EVERY cycling -- see halucp.c's own FLAGS-bit decode).
 * priority/pdeAddr/repeatIntervalUs are already decoded by the caller
 * (priority from the SVC param byte, pdeAddr via mcm_get16,
 * repeatIntervalUs from FPR2-3 via floatIBM.h). initialWakeDeadlineUs is
 * the absolute cpu->elapsedTimeUs value at which the task should first
 * become ready -- plain SCHEDULE passes cpu->elapsedTimeUs itself (due
 * now, unchanged from this function's original due-immediately-only
 * behavior); AT/IN pass an already-computed absolute deadline (already
 * clamped to not be in the past, matching sched_handle_wait_until_svc's
 * "does not leave READY" precedent for an AT time already passed). This
 * same value anchors REPEAT EVERY's own phase reference too, so
 * "SCHEDULE X IN 1.5, REPEAT EVERY 1.0" fires at 1.5, 2.5, 3.5, ...
 * (anchored to the actual first-due time), not 0, 1, 2, ... Never
 * changes which context is live -- the calling program's own NIA just
 * continues normally afterward, matching how every other already-
 * handled SVC (SEND ERROR, SIGNAL/SET/RESET) behaves. Always returns
 * true (this file only gets called once the FLAGS word is already
 * confirmed recognized). */
bool sched_handle_schedule_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr,
                                double initialWakeDeadlineUs, double repeatIntervalUs);

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
 * CLOSE (already fully handled here -- re-armed if REPEATing, freed
 * otherwise, and the next ready task already dispatched; caller should
 * return without doing anything else). Returns false iff the currently
 * running context is the primal program (or the scheduler has never
 * been engaged at all) -- caller's existing halt-the-CPU behavior must
 * run completely unchanged in that case. This is the whole backward-
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
 * Always returns true. */
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

#endif
