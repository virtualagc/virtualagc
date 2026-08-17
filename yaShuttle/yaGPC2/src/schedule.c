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
            if (t->state != TASK_STATE_READY && t->wakeDeadlineUs > cpu->elapsedTimeUs) continue;
            if (best == -1 || t->priority > s->tasks[best].priority) best = i;
        }
        if (best != -1) {
            ScheduledTask *t = &s->tasks[best];
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
            if (earliest < 0 || t->wakeDeadlineUs < earliest) earliest = t->wakeDeadlineUs;
        }
        if (earliest < 0) {
            /* Nothing scheduled or waiting anywhere -- leave whatever's
             * currently marked running (should be the primal task) live
             * as-is; nothing to dispatch, no time to advance. */
            return;
        }
        cpu->elapsedTimeUs = earliest;
    }
}

bool sched_handle_schedule_svc(Scheduler *s, CPU *cpu, int priority, uint32_t pdeAddr, double repeatIntervalUs) {
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
    t->hasRepeat = repeatIntervalUs > 0;
    t->repeatIntervalUs = repeatIntervalUs;
    t->repeatPhaseRefUs = cpu->elapsedTimeUs;
    /* REPEAT EVERY's first firing is due immediately at SCHEDULE time,
     * not after waiting one full interval -- confirmed against
     * yaHALMAT2's own output for the identical COUNTUP.hal (200 firings
     * of a REPEAT EVERY 1.0 task inside a 199.5-second WAIT: firings at
     * phaseRef+0, +1, ..., +199, i.e. 200 of them, not 199). Subsequent
     * firings (see sched_handle_task_close's re-arm) are still anchored
     * to this same phaseRef every +N*interval, so this only changes when
     * firing #1 happens, not the cadence after it. */
    t->wakeDeadlineUs = t->repeatPhaseRefUs;
    t->state = TASK_STATE_DORMANT;

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
    } else {
        t->state = TASK_SLOT_FREE;
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
        s->tasks[idx].state = TASK_SLOT_FREE; /* unconditional -- no REPEAT re-arm, unlike sched_handle_task_close */
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
