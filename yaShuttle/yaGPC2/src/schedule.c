#include "schedule.h"

#include <string.h>

#include "mcm.h"
#include "regmem.h"

void sched_init(Scheduler *s) {
    memset(s, 0, sizeof(*s));
    s->runningIdx = -1;
}

static int sched_alloc_slot(Scheduler *s) {
    for (int i = 0; i < SCHED_MAX_TASKS; i++) {
        if (s->tasks[i].state == TASK_SLOT_FREE) {
            if (i >= s->count) s->count = i + 1;
            return i;
        }
    }
    return -1; /* corpus fixtures never exercise more than a handful of
                * tasks at once; silently dropping a SCHEDULE beyond this
                * cap would be worse than a clear failure, but there is
                * nowhere better to report one from here -- callers with
                * real headroom concerns should raise SCHED_MAX_TASKS. */
}

/* pdeAddr identifies a task uniquely (its own PDE never moves), so
 * re-SCHEDULE-ing an already-scheduled task reuses its existing slot
 * rather than leaking a new one -- real HAL/S allows re-SCHEDULE of an
 * already-scheduled task; this cut doesn't need to handle that richly,
 * just not leak slots over it. */
static int sched_find_by_pde(Scheduler *s, uint32_t pdeAddr) {
    for (int i = 0; i < s->count; i++) {
        if (s->tasks[i].state != TASK_SLOT_FREE && s->tasks[i].pdeAddr == pdeAddr) return i;
    }
    return -1;
}

/* PDE halfword +0 ("PROCESS EVENT" per schedule.h's own PDE-layout
 * comment) bit 0 -- confirmed empirically that "IF <task-name> THEN"
 * (USA003087 13.5's process-name-as-Boolean) compiles to a direct `TB
 * <pdeAddr>(0),X'0001'` reading this bit, no SVC/runtime-library call
 * at all (real hardware never gets an OS to maintain this for a no-OS
 * program either, same "yaGPC2 substitutes here" reasoning as every
 * other SVC-trap substitution in this file -- except this one isn't
 * SVC-trap-shaped, it's a plain memory location the compiled program
 * reads directly, so the scheduler has to keep it correct proactively
 * rather than reactively on a trap). Set true whenever a task becomes
 * ACTIVE (SCHEDULEd, in USA003087 13.1's sense: EXECUTING/READY/
 * WAITING/DORMANT-between-REPEAT-firings all count), cleared only when
 * it goes back to INACTIVE (CLOSE with no REPEAT, or TERMINATE) -- not
 * touched on ordinary RUNNING<->WAITING<->DORMANT transitions, since
 * all of those stay ACTIVE. */
static void sched_set_active_flag(CPU *cpu, uint32_t pdeAddr, bool active) {
    uint32_t hw = mcm_get16(&cpu->mainStorage, pdeAddr);
    if (active) {
        hw |= 0x0001u;
    } else {
        hw &= ~0x0001u;
    }
    mcm_set16(&cpu->mainStorage, pdeAddr, hw, false);
}

/* Reads the same bit sched_set_active_flag writes -- the getter half of
 * process-name-as-Boolean, and the truth value of a process used as an
 * operand in an event expression (USA003087 24.8: ACTIVE<->TRUE). */
static bool sched_task_active(CPU *cpu, uint32_t pdeAddr) {
    return (mcm_get16(&cpu->mainStorage, pdeAddr) & 0x0001u) != 0;
}

/* Evaluates a WAIT FOR / SCHEDULE ... ON event-expression descriptor
 * (format documented in schedule.h's own header comment) against the
 * current ACTIVE state of its operand PDE(s). */
static bool sched_event_expr_true(CPU *cpu, uint32_t descAddr) {
    uint32_t opcode = mcm_get16(&cpu->mainStorage, descAddr);

    if (opcode == 0x1800) {
        /* NOT <single task> -- the one fixed opcode unrelated to the
         * count/connector scheme below (never combines with AND/OR or
         * N>1; the compiler itself forbids it). */
        uint32_t pde = mcm_get16(&cpu->mainStorage, descAddr + 2);
        return !sched_task_active(cpu, pde);
    }
    if (opcode == 0x0000) {
        /* plain <single task>, no connector. */
        uint32_t pde = mcm_get16(&cpu->mainStorage, descAddr + 2);
        return sched_task_active(cpu, pde);
    }

    /* AND-chain / OR-chain: top nibble = 2*(N-1); the connector code (3
     * = AND, 1 = OR) in the next nibble is redundant with -- but cross-
     * checked against -- the same code repeated N-1 times total, so
     * reading it once from the second nibble is sufficient. */
    int n = (int)(((opcode >> 12) & 0xF) / 2) + 1;
    bool isAnd = ((opcode >> 8) & 0xF) == 3;

    for (int i = 0; i < n; i++) {
        uint32_t pde = mcm_get16(&cpu->mainStorage, descAddr + 2 + (uint32_t)i);
        bool active = sched_task_active(cpu, pde);
        if (isAnd && !active) return false; /* AND: any FALSE operand makes the whole expression FALSE */
        if (!isAnd && active) return true;  /* OR: any TRUE operand makes the whole expression TRUE */
    }
    return isAnd; /* AND: every operand was TRUE; OR: every operand was FALSE */
}

/* Snapshot/restore the live CPU context -- same field set and access
 * pattern as ageharness.c's ageharness_snapshot_regs() (bank chosen via
 * psw_get_reg_set(), FP always bank 2), duplicated rather than shared
 * because schedule.h/.c sit below the AGEHarness layer and must not
 * depend on it (see schedule.h's own header comment). Restoring psw1/2
 * via psw_load() (not individual psw_set_nia/psw_set_cc/psw_set_reg_set
 * calls) re-derives NIA/CC/reg-set/BSR/DSR atomically from the two
 * packed words, the same way a real hardware PSW swap (cpu_swap_psw)
 * works -- so the register bank a task's own r[] gets written back into
 * always matches whatever reg-set bit its own saved PSW encodes, even
 * though nothing in this cut's own scope (see schedule.h) ever actually
 * changes it from bank 0. */
/* Whether task idx currently has any live DEPENDENT child (a task whose
 * own parentIdx points back at it, still occupying a non-FREE slot).
 * USA003087 13.3/13.5: this is exactly the condition both a natural
 * CLOSE-with-dependents and an explicit WAIT FOR DEPENDENT need to
 * check. */
static bool sched_has_active_dependents(Scheduler *s, int idx) {
    for (int i = 0; i < s->count; i++) {
        if (s->tasks[i].state != TASK_SLOT_FREE && s->tasks[i].parentIdx == idx) return true;
    }
    return false;
}

/* Called every time some task fully deactivates (frees its own slot),
 * for any reason -- a natural CLOSE with no remaining dependents of its
 * own, a cascade-free triggered by this same function one level down,
 * or a TERMINATE. Checks whether finishedIdx's own parent (if any) was
 * sitting in TASK_STATE_WAITING_FOR_DEPENDENTS waiting specifically on
 * this, and if finishedIdx was the LAST such dependent, releases the
 * parent: freed too (cascading further up in turn) if it was itself
 * only waiting to CLOSE, or made TASK_STATE_READY (a normal dispatch
 * candidate, picked up by whatever sched_dispatch() call happens next)
 * if it was blocked in an explicit WAIT FOR DEPENDENT instead. */
static void sched_notify_dependent_finished(Scheduler *s, CPU *cpu, int finishedIdx) {
    int parentIdx = s->tasks[finishedIdx].parentIdx;
    if (parentIdx < 0) return;
    ScheduledTask *parent = &s->tasks[parentIdx];
    if (parent->state != TASK_STATE_WAITING_FOR_DEPENDENTS) return;
    if (sched_has_active_dependents(s, parentIdx)) return; /* others still pending */

    if (parent->pendingCloseAfterDependents) {
        parent->state = TASK_SLOT_FREE;
        sched_set_active_flag(cpu, parent->pdeAddr, false);
        sched_notify_dependent_finished(s, cpu, parentIdx); /* cascade further up */
    } else {
        parent->state = TASK_STATE_READY; /* explicit WAIT FOR DEPENDENT satisfied */
    }
}

/* Terminates task idx and, transitively, every one of its DEPENDENT
 * descendants (USA003087 13.3: "All dependents of the process are
 * treated likewise"; 23.6: "both the process and its dependents are
 * terminated") -- unconditional and immediate, unlike a natural CLOSE's
 * own graceful wait-for-dependents. Children are terminated before their
 * parent (order is functionally immaterial here since every step is
 * unconditional, but avoids a live task ever briefly appearing
 * dependent-less mid-cascade). Also notifies idx's own parent in case
 * idx itself was someone else's last pending dependent. Does NOT touch
 * s->runningIdx or call sched_dispatch() -- that's the caller's job,
 * exactly like sched_handle_terminate_named_svc's own pre-existing
 * per-target loop. */
static void sched_terminate_idx_and_dependents(Scheduler *s, CPU *cpu, int idx) {
    for (int i = 0; i < s->count; i++) {
        if (s->tasks[i].state != TASK_SLOT_FREE && s->tasks[i].parentIdx == idx) {
            sched_terminate_idx_and_dependents(s, cpu, i);
        }
    }
    s->tasks[idx].state = TASK_SLOT_FREE;
    sched_set_active_flag(cpu, s->tasks[idx].pdeAddr, false);
    sched_notify_dependent_finished(s, cpu, idx);
}

static void sched_save_context(CPU *cpu, TaskContext *ctx) {
    uint32_t grSet = psw_get_reg_set(&cpu->psw);
    for (int i = 0; i <= 7; i++) ctx->r[i] = register_get32(registerfile_r(&cpu->regFiles[grSet], i));
    for (int i = 0; i <= 7; i++) ctx->fp[i] = register_get32(registerfile_r(&cpu->regFiles[2], i));
    ctx->nia = psw_get_nia(&cpu->psw);
    ctx->cc = psw_get_cc(&cpu->psw);
    ctx->psw1 = register_get32(&cpu->psw.psw1);
    ctx->psw2 = register_get32(&cpu->psw.psw2);
}

static void sched_restore_context(CPU *cpu, const TaskContext *ctx) {
    psw_load(&cpu->psw, ctx->psw1, ctx->psw2);
    uint32_t grSet = psw_get_reg_set(&cpu->psw);
    for (int i = 0; i <= 7; i++) register_set32(registerfile_r(&cpu->regFiles[grSet], i), ctx->r[i]);
    for (int i = 0; i <= 7; i++) register_set32(registerfile_r(&cpu->regFiles[2], i), ctx->fp[i]);
}

/* Decodes a PDE's own entry-point far-pointer (halfword +2, see
 * schedule.h's header comment): the low 15 bits plus the BSR-relative
 * "sector" the CURRENTLY RUNNING code lives in (psw_get_bsr()) -- this
 * is cpu_g_expand()'s own general instruction-operand extension formula
 * after all -- an earlier version of this function reinvented a
 * different (wrong) formula by hand-deriving it from the linker JSON's
 * address/size fields under the mistaken belief that those are byte
 * addresses needing a further /2 to reach mcm_get16's halfword-indexed
 * units. They aren't: confirmed directly that the JSON's own reported
 * address for a section (e.g. 65536 for $0COUNTU) matches that same
 * section's live traced NIA exactly, with no conversion factor at all
 * -- so this function is now nothing more than cpu_g_expand() itself,
 * called with OPTYPE_BRCH (a code/branch target, so BSR-relative, not
 * DSR-relative -- see cpu_g_expand's own dispatch on bsrdsr). Verified
 * against a real compiled/linked program's actual PDE contents: with
 * the live BSR value at SCHEDULE time (2 in that program), this
 * correctly reproduces both $0COUNTU's (65536) and $1COUNTU's (65556)
 * real addresses from their respective PDEs' raw hw2 far-pointer values
 * (0x8000 and 0x8014). This assumes the whole linked program -- main
 * line and every one of its TASKs -- lives in one BSR sector, true for
 * any small, non-overlaid program (every fixture this cut targets); a
 * program spanning more than one BSR sector would need the per-task BSR
 * captured at SCHEDULE time instead of read fresh at dispatch time,
 * which this cut doesn't do. */
static uint32_t decode_pde_far_pointer(CPU *cpu, uint32_t raw) {
    return cpu_g_expand(cpu, raw, OPTYPE_BRCH);
}

/* Picks the highest-priority task among READY/DORMANT tasks whose
 * wakeDeadlineUs has arrived, and makes it live. If nothing is
 * immediately ready but something is WAITING/DORMANT with a future
 * deadline, fast-forwards cpu->elapsedTimeUs to the earliest one and
 * retries -- this only moves the virtual-time bookkeeping forward,
 * never skips actual instruction execution (mirrors yaHALMAT2's own
 * virtual-time model: time is purely a function of what's already run
 * plus how far a scheduler needs to look ahead to find the next thing
 * to run, never real wall-clock). If truly nothing is ready anywhere
 * (every task WAITING with the primal task itself among them and no
 * deadline earlier than its own), the primal task is simply left/made
 * live with no time advance -- this is the case that shouldn't arise in
 * practice for a well-formed program that always has *something*
 * eventually due, but is handled safely rather than looping forever. */
static void sched_dispatch(Scheduler *s, CPU *cpu) {
    for (;;) {
        int best = -1;
        for (int i = 0; i < s->count; i++) {
            ScheduledTask *t = &s->tasks[i];
            if (t->state != TASK_STATE_READY && t->state != TASK_STATE_DORMANT && t->state != TASK_STATE_WAITING)
                continue;
            if (t->state != TASK_STATE_READY) {
                /* An event-gated task (WAIT FOR's own waiter, or a
                 * SCHEDULE ... ON target still pending) is eligible
                 * exactly when its event expression is currently true --
                 * wakeDeadlineUs is meaningless for it (see schedule.h's
                 * own ScheduledTask.eventDescAddr comment). */
                if (t->eventDescAddr != 0) {
                    if (!sched_event_expr_true(cpu, t->eventDescAddr)) continue;
                } else if (t->wakeDeadlineUs > cpu->elapsedTimeUs) {
                    continue;
                }
            }
            if (best == -1 || t->priority > s->tasks[best].priority) best = i;
        }
        if (best != -1) {
            ScheduledTask *t = &s->tasks[best];
            t->eventDescAddr = 0; /* about to run -- don't leave a stale pointer for this slot's next use */
            if (!t->hasRun) {
                /* Never dispatched before -- a freshly-SCHEDULEd
                 * REPEAT-EVERY task goes straight to DORMANT without
                 * ever passing through a first RUNNING dispatch, so its
                 * ctx has never been populated. Dispatch fresh to its
                 * own entry point instead of restoring a meaningless
                 * all-zero saved context; its own compiled prologue
                 * self-initializes its registers (confirmed directly
                 * from a real compiled listing), so nothing else needs
                 * setting here. */
                psw_set_nia(&cpu->psw, t->entryPoint);
                t->hasRun = true;
            } else {
                sched_restore_context(cpu, &t->ctx);
            }
            t->state = TASK_STATE_RUNNING;
            s->runningIdx = best;
            return;
        }
        /* Nothing immediately ready: find the earliest pending deadline
         * among WAITING/DORMANT tasks and fast-forward to it. */
        double earliest = -1;
        for (int i = 0; i < s->count; i++) {
            ScheduledTask *t = &s->tasks[i];
            if (t->state != TASK_STATE_WAITING && t->state != TASK_STATE_DORMANT) continue;
            if (t->eventDescAddr != 0) continue; /* event-gated: no amount of elapsed time alone can satisfy it */
            if (earliest < 0 || t->wakeDeadlineUs < earliest) earliest = t->wakeDeadlineUs;
        }
        if (earliest < 0) {
            /* Nothing scheduled or waiting anywhere that time alone can
             * satisfy -- leave whatever's currently marked running
             * (should be the primal task) live as-is; nothing to
             * dispatch, no time to advance. Any purely event-gated
             * task(s) left pending here will become eligible the next
             * time sched_dispatch() runs after some other context flips
             * the relevant ACTIVE flag(s), not from this loop. */
            return;
        }
        cpu->elapsedTimeUs = earliest;
    }
}

bool sched_handle_schedule_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr,
                                double initialWakeDeadlineUs, double repeatIntervalUs, bool dependent) {
    /* DEPENDENT's own parent is whichever task is executing this
     * SCHEDULE statement (USA003087 13.4) -- lazily engage the primal
     * first if scheduling has never been engaged before (same pattern as
     * sched_handle_wait_svc), so there's always a real caller index to
     * record. Only done when actually needed (dependent==true) so a
     * program that never uses DEPENDENT never pays for a primal slot it
     * doesn't otherwise need. */
    if (dependent && s->runningIdx < 0) {
        int primalIdx = sched_alloc_slot(s);
        s->tasks[primalIdx].isPrimal = true;
        s->tasks[primalIdx].parentIdx = -1;
        s->tasks[primalIdx].state = TASK_STATE_RUNNING;
        s->tasks[primalIdx].hasRun = true;
        s->runningIdx = primalIdx;
    }

    int idx = sched_find_by_pde(s, pdeAddr);
    if (idx < 0) idx = sched_alloc_slot(s);
    if (idx < 0) return true; /* out of task slots -- nothing sensible to
                                * do but not corrupt anything; SVC is
                                * still considered handled */

    ScheduledTask *t = &s->tasks[idx];
    memset(t, 0, sizeof(*t));
    t->pdeAddr = pdeAddr;
    uint32_t raw = mcm_get16(&cpu->mainStorage, pdeAddr + 2);
    t->entryPoint = decode_pde_far_pointer(cpu, raw);
    t->priority = priority;
    t->isPrimal = false;
    t->parentIdx = dependent ? s->runningIdx : -1;
    t->hasRepeat = repeatIntervalUs > 0;
    t->repeatIntervalUs = repeatIntervalUs;
    /* Plain SCHEDULE's first firing is due immediately at SCHEDULE time
     * (caller passes cpu->elapsedTimeUs itself as initialWakeDeadlineUs
     * in that case) -- confirmed against yaHALMAT2's own output for the
     * identical COUNTUP.hal (200 firings of a REPEAT EVERY 1.0 task
     * inside a 199.5-second WAIT: firings at phaseRef+0, +1, ..., +199,
     * i.e. 200 of them, not 199). SCHEDULE...AT/IN instead pass an
     * already-computed, already-clamped-to-the-future absolute deadline
     * as initialWakeDeadlineUs (see this function's own header comment
     * in schedule.h). Either way, REPEAT EVERY's own re-arm (see
     * sched_handle_task_close) stays anchored to this same phaseRef
     * every +N*interval, so this only changes when firing #1 happens,
     * not the cadence after it. */
    t->repeatPhaseRefUs = initialWakeDeadlineUs;
    t->wakeDeadlineUs = initialWakeDeadlineUs;
    t->state = TASK_STATE_DORMANT;
    sched_set_active_flag(cpu, pdeAddr, true);

    return true;
}

bool sched_handle_wait_svc(Scheduler *s, CPU *cpu, double deltaSeconds) {
    if (s->runningIdx < 0) {
        /* First time scheduling has ever been engaged: lazily allocate
         * the "primal" pseudo-task representing the main program, and
         * mark it (implicitly) running -- its context doesn't need
         * saving yet since it's about to be saved for real, below. */
        int idx = sched_alloc_slot(s);
        s->tasks[idx].isPrimal = true;
        s->tasks[idx].parentIdx = -1; /* a reused (previously-freed) slot
                                        * could otherwise carry a stale
                                        * value from its last occupant */
        s->tasks[idx].state = TASK_STATE_RUNNING;
        /* The primal task is never dispatched via entryPoint (it has
         * none -- it's simply whatever was already executing when
         * scheduling was first engaged), only ever resumed from ctx.
         * Mark it as already-run up front so sched_dispatch() always
         * takes the restore-from-ctx branch for it, never the fresh-
         * dispatch-to-entryPoint(0) branch. */
        s->tasks[idx].hasRun = true;
        s->runningIdx = idx;
    }

    ScheduledTask *waiter = &s->tasks[s->runningIdx];
    sched_save_context(cpu, &waiter->ctx);
    waiter->state = TASK_STATE_WAITING;
    waiter->wakeDeadlineUs = cpu->elapsedTimeUs + deltaSeconds * 1e6;

    sched_dispatch(s, cpu);
    return true;
}

bool sched_handle_wait_until_svc(Scheduler *s, CPU *cpu, double absoluteSeconds) {
    double deltaSeconds = absoluteSeconds - cpu->elapsedTimeUs / 1e6;
    if (deltaSeconds < 0.0) deltaSeconds = 0.0;
    return sched_handle_wait_svc(s, cpu, deltaSeconds);
}

bool sched_handle_task_close(Scheduler *s, CPU *cpu) {
    if (s->runningIdx < 0) return false; /* scheduling never engaged */

    ScheduledTask *t = &s->tasks[s->runningIdx];
    if (t->isPrimal) return false; /* the main program's own CLOSE: real halt */

    if (t->hasRepeat) {
        /* Re-arm from the fixed phase reference, not "now" -- avoids
         * drift from however late this particular firing ran (matches
         * yaHALMAT2's own REPEAT EVERY policy). Advance by whole
         * intervals until back in the future relative to elapsedTimeUs,
         * in case a firing ran long enough to miss more than one. */
        double next = t->wakeDeadlineUs;
        while (next <= cpu->elapsedTimeUs) next += t->repeatIntervalUs;
        t->wakeDeadlineUs = next;
        t->state = TASK_STATE_DORMANT;
        /* A task's own CLOSE means this firing ran to completion -- there
         * is no internal suspend to resume from (nothing in this cut's
         * scope has a TASK itself execute a WAIT), so the *next* firing
         * is logically a fresh dispatch to entryPoint again, exactly like
         * the first one, not a resume from ctx (which was never saved
         * for this task and would otherwise be stale garbage from
         * whichever iteration last populated it, or all-zero if this was
         * the first). */
        t->hasRun = false;
    } else if (sched_has_active_dependents(s, s->runningIdx)) {
        /* USA003087 13.3: reaching CLOSE/RETURN with a still-active
         * DEPENDENT child does not deactivate directly -- wait until it
         * (and any others) have themselves terminated. ACTIVE stays set
         * (still "in the process queue" per 13.1) until that happens. */
        t->state = TASK_STATE_WAITING_FOR_DEPENDENTS;
        t->pendingCloseAfterDependents = true;
    } else {
        t->state = TASK_SLOT_FREE;
        sched_set_active_flag(cpu, t->pdeAddr, false);
        sched_notify_dependent_finished(s, cpu, s->runningIdx);
    }
    s->runningIdx = -1;

    sched_dispatch(s, cpu);
    return true;
}

bool sched_handle_terminate_named_svc(Scheduler *s, CPU *cpu, const uint32_t *pdeAddrs, int count) {
    bool selfTerminated = false;
    for (int i = 0; i < count; i++) {
        int idx = sched_find_by_pde(s, pdeAddrs[i]);
        if (idx < 0) continue; /* not currently active -- silent no-op */
        if (idx == s->runningIdx) selfTerminated = true;
        sched_terminate_idx_and_dependents(s, cpu, idx); /* unconditional -- no REPEAT re-arm, unlike sched_handle_task_close; cascades to dependents too */
    }
    if (selfTerminated) {
        s->runningIdx = -1;
        sched_dispatch(s, cpu);
    }
    return true;
}

bool sched_handle_terminate_self_svc(Scheduler *s, CPU *cpu) {
    if (s->runningIdx < 0 || s->tasks[s->runningIdx].isPrimal) return false;
    uint32_t ownPde = s->tasks[s->runningIdx].pdeAddr;
    return sched_handle_terminate_named_svc(s, cpu, &ownPde, 1);
}

bool sched_handle_update_priority_svc(Scheduler *s, CPU *cpu, int newPriority, uint32_t pdeAddr) {
    (void)cpu; /* no dispatch/context change -- see this function's own header comment */
    int idx = sched_find_by_pde(s, pdeAddr);
    if (idx >= 0) s->tasks[idx].priority = newPriority;
    return true;
}

bool sched_handle_wait_for_svc(Scheduler *s, CPU *cpu, uint32_t eventDescAddr) {
    /* USA003087 24.6: "If exp is already TRUE when the WAIT statement is
     * executed, the statement has no effect" -- checked before even the
     * lazy primal allocation below, so this really is a complete no-op
     * (no context save, no dispatch, nothing) when already satisfied,
     * unlike delta-time WAIT which always hands off to sched_dispatch()
     * unconditionally. */
    if (sched_event_expr_true(cpu, eventDescAddr)) return true;

    if (s->runningIdx < 0) {
        /* First time scheduling has ever been engaged -- see
         * sched_handle_wait_svc's own identical lazy-primal-allocation
         * comment for the reasoning; duplicated rather than factored out
         * since the two callers' surrounding logic differs enough
         * (this one's own already-true early-return above) that sharing
         * would need its own parameter to suppress that check. */
        int idx = sched_alloc_slot(s);
        s->tasks[idx].isPrimal = true;
        s->tasks[idx].parentIdx = -1;
        s->tasks[idx].state = TASK_STATE_RUNNING;
        s->tasks[idx].hasRun = true;
        s->runningIdx = idx;
    }

    ScheduledTask *waiter = &s->tasks[s->runningIdx];
    sched_save_context(cpu, &waiter->ctx);
    waiter->state = TASK_STATE_WAITING;
    waiter->eventDescAddr = eventDescAddr;

    sched_dispatch(s, cpu);
    return true;
}

bool sched_handle_schedule_on_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr, uint32_t eventDescAddr) {
    int idx = sched_find_by_pde(s, pdeAddr);
    if (idx < 0) idx = sched_alloc_slot(s);
    if (idx < 0) return true; /* out of task slots -- see sched_handle_schedule_svc's own comment */

    ScheduledTask *t = &s->tasks[idx];
    memset(t, 0, sizeof(*t));
    t->pdeAddr = pdeAddr;
    uint32_t raw = mcm_get16(&cpu->mainStorage, pdeAddr + 2);
    t->entryPoint = decode_pde_far_pointer(cpu, raw);
    t->priority = priority;
    t->isPrimal = false;
    t->parentIdx = -1; /* DEPENDENT combined with ON is not empirically confirmed -- see schedule.h */
    t->eventDescAddr = eventDescAddr;
    t->state = TASK_STATE_DORMANT;
    /* Marked ACTIVE immediately, exactly like every other SCHEDULE
     * variant (USA003087 13.1: ACTIVE means "in the process queue,"
     * which this task already is even before its trigger event fires --
     * see sched_handle_schedule_svc's own AT/IN precedent for the same
     * reasoning). */
    sched_set_active_flag(cpu, pdeAddr, true);

    return true;
}

bool sched_handle_wait_for_dependent_svc(Scheduler *s, CPU *cpu) {
    if (s->runningIdx < 0 || !sched_has_active_dependents(s, s->runningIdx)) {
        /* USA003087 13.5: "If there are no dependents, the statement has
         * no effect" -- same "already-satisfied is a true no-op"
         * precedent as sched_handle_wait_for_svc. Also correctly covers
         * "scheduling never engaged" (runningIdx < 0 -> no dependents
         * could possibly exist either), so the lazy primal allocation
         * below is only ever reached when there's something real to
         * wait for. */
        return true;
    }

    ScheduledTask *waiter = &s->tasks[s->runningIdx];
    sched_save_context(cpu, &waiter->ctx);
    waiter->state = TASK_STATE_WAITING_FOR_DEPENDENTS;
    waiter->pendingCloseAfterDependents = false; /* resume execution once satisfied, don't free the slot */

    s->runningIdx = -1;
    sched_dispatch(s, cpu);
    return true;
}
