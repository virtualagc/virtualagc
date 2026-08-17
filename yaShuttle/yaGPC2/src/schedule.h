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
 *   WAIT is SVC #6 (delta-time -- the only variant this file handles),
 *   #7 (UNTIL), #8 (event-expression), or #9 (DEPENDENT); delta-time in
 *   FPR0-1.
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

    double wakeDeadlineUs;    /* meaningful when WAITING or DORMANT */

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
 * FLAGS word is recognized as the one signature this cut supports
 * (TASK, REPEAT EVERY, nothing else). priority/pdeAddr/repeatIntervalUs
 * are already decoded by the caller (priority from the SVC param byte,
 * pdeAddr via hal_get32, repeatIntervalUs from FPR2-3 via floatIBM.h).
 * Never changes which context is live -- the calling program's own NIA
 * just continues normally afterward, matching how every other
 * already-handled SVC (SEND ERROR, SIGNAL/SET/RESET) behaves. Always
 * returns true (this file only gets called once the FLAGS word is
 * already confirmed recognized). */
bool sched_handle_schedule_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr, double repeatIntervalUs);

/* Called from halucp.c's SVC dispatch for SVC #6 (delta-time WAIT).
 * Suspends the currently-running context (lazily creating the "primal"
 * pseudo-task on first use, if scheduling has never been engaged
 * before) and dispatches whatever's next. Always returns true. */
bool sched_handle_wait_svc(Scheduler *s, CPU *cpu, double deltaSeconds);

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

#endif
