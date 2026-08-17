/* Tier-1 scheduler-mechanics unit tests for src/schedule.h/.c (HAL/S
 * TASK/SCHEDULE/WAIT -- see problems.md 2.7 and src/schedule.h's own
 * header comment for the SVC protocol this substitutes for).
 *
 * Unlike test/fixtures/countup.hal (a real HALSFC-compiled program,
 * checked via test_scheduler.sh against yaHALMAT2's own output as an
 * oracle), these are hand-assembled task bodies at flat, non-extended
 * (no 0x8000 far-pointer bit) addresses we pick ourselves -- following
 * test/fixtures/gen_svc_fcms.cjs's own LHI+SVC hand-assembly pattern
 * (its own header comment documents that encoding's derivation and
 * verification) plus LH/AHI/STH for the one scenario that needs a real
 * memory counter. This lets each test assert on internals a compiled
 * fixture's stdout can't show directly: exact register round-trip
 * across a suspend/resume, which task the scheduler actually picked
 * when two are simultaneously due, and the exact virtual-time value
 * after each step (proving elapsedTimeUs jumps discretely to the next
 * deadline rather than free-running).
 *
 * All addressing here deliberately stays flat: cpu_g_expand() (called
 * by schedule.c's decode_pde_far_pointer()) only extends a raw pointer
 * when its 0x8000 bit is set, so leaving that bit clear -- true for
 * every address below, all well under 0x8000 -- means entry points are
 * used exactly as written, with no BSR dependency to set up. Likewise
 * every hand-assembled LH/STH below uses base register R0 (always zero
 * -- nothing here ever loads R0) with a small 6-bit displacement, so
 * cpu_g_expand_dse() never sees its own 0x8000 bit set either and the
 * effective address is always exactly the displacement itself.
 *
 * Run from the repo root (as `make test` does) -- no fixture files
 * needed; every program is built directly into MCM by this file. */
#include <stdio.h>

#include "../src/ageharness.h"
#include "../src/floatIBM.h"
#include "../src/mcm.h"
#include "../src/regmem.h"
#include "../src/schedule.h"

static int failures = 0;

#define CHECK(cond, msg)                                          \
    do {                                                          \
        if (!(cond)) {                                            \
            printf("FAIL: %s\n", msg);                            \
            failures++;                                           \
        }                                                         \
    } while (0)

/* sched_dispatch()'s fast-forward (schedule.c) sets cpu->elapsedTimeUs
 * to exactly the target deadline as part of executing the *triggering*
 * instruction (the SVC that closed the previous task) -- but cpu.c's
 * own step loop adds that same instruction's own timing cost on top
 * immediately afterward (exec first, then "elapsedTimeUs +=
 * instr_time_us(...)" -- see cpu.c's cpu_exec1), so the value observed
 * right after a dispatch is always the deadline plus one instruction's
 * worth of timing, not the deadline exactly. A few hundred microseconds
 * of tolerance comfortably covers any single instruction's cost while
 * still being tight enough to prove this is a discrete jump to the next
 * deadline, not free-running with total instruction count. */
#define TIME_TOLERANCE_US 1000.0
static bool close_to(double actual, double expected) {
    return actual >= expected && actual < expected + TIME_TOLERANCE_US;
}

/* ---------------------------------------------------------------------
 * Hand-assembly helpers -- see this file's own header comment for the
 * encodings' derivation (cross-checked against src/cpu_instr.c's own
 * OPS table entries for LHI/SVC/LH/AHI/STH, and against
 * gen_svc_fcms.cjs's already-shipped, independently-verified LHI+SVC
 * pair for the two of those five this file shares with it).
 * ------------------------------------------------------------------- */

/* LHI Rx,I -- load I into Rx's own upper 16 bits (register_set32(Rx, I
 * << 16), see exec_LHI) -- 2 halfwords: opcode, then I itself. */
static uint32_t emit_lhi(MCM *m, uint32_t addr, int reg, uint32_t imm) {
    mcm_set16(m, addr, 0xE8F3 | ((uint32_t)reg << 8), false);
    mcm_set16(m, addr + 1, imm, false);
    return addr + 2;
}

/* AHI Ry,I -- Ry += (I << 16) (see exec_AHI) -- 2 halfwords. */
static uint32_t emit_ahi(MCM *m, uint32_t addr, int reg, uint32_t imm) {
    mcm_set16(m, addr, 0xB0E0 | (uint32_t)reg, false);
    mcm_set16(m, addr + 1, imm, false);
    return addr + 2;
}

/* LH Rx,D(B0) -- load mem[D] into Rx's upper 16 bits (see exec_LH,
 * cpu_g_eah) -- 1 halfword, D must fit in 6 bits (0-63). */
static uint32_t emit_lh(MCM *m, uint32_t addr, int reg, uint32_t disp) {
    mcm_set16(m, addr, 0x9800 | ((uint32_t)reg << 8) | (disp << 2), false);
    return addr + 1;
}

/* STH Rx,D(B0) -- store Rx's upper 16 bits to mem[D] (see exec_STH) --
 * 1 halfword, D must fit in 6 bits (0-63). */
static uint32_t emit_sth(MCM *m, uint32_t addr, int reg, uint32_t disp) {
    mcm_set16(m, addr, 0xB800 | ((uint32_t)reg << 8) | (disp << 2), false);
    return addr + 1;
}

/* SVC D2(B2=2),a=0 -- non-indexed extended addressing, EA = R2 (already
 * loaded via emit_lhi) -- 2 halfwords: opcode, then D2=0. Matches
 * gen_svc_fcms.cjs's own "0xC9F8 | 2" byte-for-byte. */
static uint32_t emit_svc_extended(MCM *m, uint32_t addr) {
    mcm_set16(m, addr, 0xC9F8 | 2, false);
    mcm_set16(m, addr + 1, 0, false);
    return addr + 2;
}

/* A task body that does nothing but CLOSE (SVC 0x0015) -- LHI R2,<data
 * addr right after this sequence> ; SVC 0(R2) ; <data addr>: 0x0015.
 * Returns the entry point (== addr). */
static uint32_t build_close_only_task(MCM *m, uint32_t addr) {
    uint32_t entry = addr;
    uint32_t dataAddr = addr + 4; /* LHI (2hw) + SVC (2hw) */
    addr = emit_lhi(m, addr, 2, dataAddr);
    addr = emit_svc_extended(m, addr);
    mcm_set16(m, dataAddr, 0x0015, false);
    (void)addr;
    return entry;
}

/* A task body that increments mem[counterDisp] by 1, then CLOSEs --
 * for the REPEAT EVERY scenario, where the "memory counter" IS the
 * thing under test. counterDisp must fit in 6 bits (0-63, see emit_lh/
 * emit_sth above). Returns the entry point (== addr). */
static uint32_t build_increment_and_close_task(MCM *m, uint32_t addr, uint32_t counterDisp) {
    uint32_t entry = addr;
    addr = emit_lh(m, addr, 1, counterDisp);
    addr = emit_ahi(m, addr, 1, 1);
    addr = emit_sth(m, addr, 1, counterDisp);
    uint32_t dataAddr = addr + 4;
    addr = emit_lhi(m, addr, 2, dataAddr);
    addr = emit_svc_extended(m, addr);
    mcm_set16(m, dataAddr, 0x0015, false);
    (void)addr;
    return entry;
}

/* A task's own 6-halfword PDE -- only +2 (the entry-point far-pointer)
 * matters to schedule.c's decode_pde_far_pointer() in this cut (see
 * schedule.h's PDE-layout comment); the rest are zeroed, matching
 * fields this cut never reads. */
static uint32_t build_pde(MCM *m, uint32_t addr, uint32_t entryPoint) {
    for (int i = 0; i < 6; i++) mcm_set16(m, addr + i, 0, false);
    mcm_set16(m, addr + 2, entryPoint, false);
    return addr;
}

/* ---------------------------------------------------------------------
 * 1. Two simultaneously-due tasks: the higher-priority one runs first,
 *    and the primal program's own register/PSW state round-trips
 *    exactly across the WAIT that suspends it.
 * ------------------------------------------------------------------- */

static void test_priority_ordering_and_context_roundtrip(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t lowEntry = build_close_only_task(mem, 0x1000);
    uint32_t lowPde = build_pde(mem, 0x1010, lowEntry);
    uint32_t hiEntry = build_close_only_task(mem, 0x2000);
    uint32_t hiPde = build_pde(mem, 0x2010, hiEntry);

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);

    /* Sentinel register/FP values to prove round-trip across the WAIT
     * below -- distinct per index so a swapped/misindexed restore would
     * be caught, not just a wholesale-zeroed one. */
    uint32_t sentR[8], sentFp[8];
    for (int i = 0; i < 8; i++) {
        sentR[i] = 0xA0000000u + ((uint32_t)i << 16) + 0x1111u;
        sentFp[i] = 0xB0000000u + ((uint32_t)i << 16) + 0x2222u;
        register_set32(registerfile_r(&cpu->regFiles[0], i), sentR[i]);
        register_set32(registerfile_r(&cpu->regFiles[2], i), sentFp[i]);
    }

    /* Two one-shot SCHEDULEs (repeatIntervalUs=0), both due immediately
     * (elapsedTimeUs is still 0.0 -- freshly zeroed by ageharness_init --
     * so both phaseRefs land on the same instant). */
    CHECK(sched_handle_schedule_svc(sched, cpu, 10, lowPde, 0.0), "SCHEDULE LOWTASK handled");
    CHECK(sched_handle_schedule_svc(sched, cpu, 200, hiPde, 0.0), "SCHEDULE HITASK handled");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr,
          "SCHEDULE never changes which context is live (NIA still the primal's)");

    CHECK(sched_handle_wait_svc(sched, cpu, 1.0), "WAIT handled");
    CHECK(psw_get_nia(&cpu->psw) == hiEntry, "higher-priority HITASK dispatched first, not LOWTASK");
    CHECK(sched->runningIdx >= 0 && sched->tasks[sched->runningIdx].priority == 200,
          "scheduler's own runningIdx/priority agree with HITASK having been picked");

    /* Run HITASK to its own CLOSE (LHI + SVC = 2 instructions). */
    ap101_exec1(&age.gpc);
    ap101_exec1(&age.gpc);
    CHECK(psw_get_nia(&cpu->psw) == lowEntry, "LOWTASK dispatched next, after HITASK's CLOSE");

    /* Run LOWTASK to its own CLOSE the same way -- nothing else is due,
     * so this should fast-forward straight to the primal's WAIT
     * deadline and resume it. */
    ap101_exec1(&age.gpc);
    ap101_exec1(&age.gpc);
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed at its own saved NIA after both tasks closed");
    CHECK(close_to(cpu->elapsedTimeUs, 1000000.0), "elapsedTimeUs fast-forwarded to (approximately) the 1.0s WAIT deadline");
    CHECK(sched->runningIdx >= 0 && sched->tasks[sched->runningIdx].isPrimal,
          "scheduler's runningIdx is back on the primal pseudo-task");

    bool regsOk = true, fpsOk = true;
    for (int i = 0; i < 8; i++) {
        if (register_get32(registerfile_r(&cpu->regFiles[0], i)) != sentR[i]) regsOk = false;
        if (register_get32(registerfile_r(&cpu->regFiles[2], i)) != sentFp[i]) fpsOk = false;
    }
    CHECK(regsOk, "primal's R0-R7 round-tripped exactly across the WAIT suspend/resume");
    CHECK(fpsOk, "primal's FP0-FP7 round-tripped exactly across the WAIT suspend/resume");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 2. One REPEAT EVERY task + a WAIT spanning several intervals: the
 *    memory counter it increments reaches the expected count, and
 *    elapsedTimeUs advances in discrete ~1-second jumps to each firing
 *    (not free-running with instruction count).
 * ------------------------------------------------------------------- */

static void test_repeat_every_counter_and_virtual_time(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    const uint32_t counterDisp = 40; /* mem[40], well within LH/STH's 6-bit displacement */
    mcm_set16(mem, counterDisp, 0, false);

    uint32_t taskEntry = build_increment_and_close_task(mem, 0x200, counterDisp);
    uint32_t taskPde = build_pde(mem, 0x300, taskEntry);

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, taskPde, 1000000.0 /* REPEAT EVERY 1.0s */),
          "SCHEDULE ... REPEAT EVERY handled");
    CHECK(sched_handle_wait_svc(sched, cpu, 3.5), "WAIT 3.5 handled");
    CHECK(psw_get_nia(&cpu->psw) == taskEntry, "REPEAT task's first firing is dispatched immediately (t=0), not after one full interval");

    /* Expected elapsedTimeUs (within close_to()'s tolerance -- see its
     * own comment for why it's not exact equality) immediately after
     * each firing's own CLOSE dispatches whatever comes next: firings
     * 1-3 hand off to the next firing (fast-forwarding to 1e6/2e6/3e6,
     * the REPEAT interval's own phase-anchored deadlines); firing 4's
     * CLOSE instead hands off to the primal (its WAIT deadline, 3.5e6,
     * arrives before firing 5's would-be 4e6) -- proving the advance is
     * deadline-driven, not a function of how many instructions ran. */
    const double expectedElapsedAfterFiring[] = {1000000.0, 2000000.0, 3000000.0, 3500000.0};
    const int expectedFirings = 4;
    int firing = 0;
    while (psw_get_nia(&cpu->psw) != primalResumeAddr && firing < 8) {
        /* LH, AHI, STH, LHI, SVC == 5 instructions per firing (see
         * build_increment_and_close_task). */
        for (int i = 0; i < 5; i++) ap101_exec1(&age.gpc);
        if (firing < expectedFirings) {
            char label[64];
            snprintf(label, sizeof label, "elapsedTimeUs approximately %.0f after firing %d",
                     expectedElapsedAfterFiring[firing], firing + 1);
            CHECK(close_to(cpu->elapsedTimeUs, expectedElapsedAfterFiring[firing]), label);
        }
        firing++;
    }

    CHECK(firing == expectedFirings, "exactly 4 firings occurred within the 3.5s WAIT (t=0,1,2,3)");
    CHECK(mcm_get16(mem, counterDisp) == 4, "memory counter reached the expected value (4)");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed once its own WAIT deadline beat the 5th firing's");
    CHECK(close_to(cpu->elapsedTimeUs, 3500000.0), "elapsedTimeUs landed on (approximately) the primal's 3.5s WAIT deadline");

    ageharness_free(&age);
}

/* sched_find_by_pde() (schedule.c) is private; Scheduler/ScheduledTask's
 * own fields are public (schedule.h), so tests can just re-derive the
 * same lookup directly rather than needing a testing-only export. */
static int find_task_by_pde(const Scheduler *s, uint32_t pdeAddr) {
    for (int i = 0; i < s->count; i++) {
        if (s->tasks[i].state != TASK_SLOT_FREE && s->tasks[i].pdeAddr == pdeAddr) return i;
    }
    return -1;
}

/* ---------------------------------------------------------------------
 * 3. UPDATE PRIORITY (SVC #11, sched_handle_update_priority_svc): a
 *    real compiled program's own tie-breaking order between two
 *    simultaneously-due REPEAT EVERY tasks turned out to be too
 *    sensitive to per-firing instruction-timing drift (each task's own
 *    phaseRef is captured at its own real SCHEDULE call, a few real
 *    instructions apart -- see problems.md's writeup) to make a clean,
 *    deterministic assertion from a compiled fixture's stdout. Hand-
 *    assembling both tasks and SCHEDULEing them via direct C calls (so
 *    both phaseRefs are bit-identical, captured at the same
 *    elapsedTimeUs) sidesteps that confound entirely.
 * ------------------------------------------------------------------- */

static void test_update_priority_flips_dispatch_order(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t lowEntry = build_close_only_task(mem, 0x1000);
    uint32_t lowPde = build_pde(mem, 0x1010, lowEntry);
    uint32_t hiEntry = build_close_only_task(mem, 0x2000);
    uint32_t hiPde = build_pde(mem, 0x2010, hiEntry);

    CHECK(sched_handle_schedule_svc(sched, cpu, 10, lowPde, 0.0), "SCHEDULE LOWTASK(10) handled");
    CHECK(sched_handle_schedule_svc(sched, cpu, 90, hiPde, 0.0), "SCHEDULE HITASK(90) handled");

    /* A pdeAddr matching no active task is a documented silent no-op --
     * confirm it doesn't corrupt anything before the real update. */
    CHECK(sched_handle_update_priority_svc(sched, cpu, 255, 0xdead), "UPDATE PRIORITY of an unknown PDE is a harmless no-op");

    CHECK(sched_handle_update_priority_svc(sched, cpu, 200, lowPde), "UPDATE PRIORITY LOWTASK TO 200 handled");
    CHECK(sched->tasks[find_task_by_pde(sched, lowPde)].priority == 200, "LOWTASK's own priority actually mutated to 200");

    CHECK(sched_handle_wait_svc(sched, cpu, 1.0), "WAIT handled");
    CHECK(psw_get_nia(&cpu->psw) == lowEntry, "LOWTASK (now priority 200) dispatched first, ahead of HITASK (90)");

    ap101_exec1(&age.gpc);
    ap101_exec1(&age.gpc);
    CHECK(psw_get_nia(&cpu->psw) == hiEntry, "HITASK dispatched second, after LOWTASK's own CLOSE");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 4. TERMINATE (SVC #2 self / SVC #3 named,
 *    sched_handle_terminate_self_svc/_named_svc): a REPEATing task
 *    TERMINATEd by name must stop repeating (unlike merely reaching its
 *    own CLOSE, which re-arms it), and a task that TERMINATEs itself
 *    must switch context away immediately rather than continuing to
 *    execute its own remaining instructions.
 * ------------------------------------------------------------------- */

static void test_terminate_named_and_self(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    /* Named form: a REPEATing task, TERMINATEd by the primal instead of
     * being allowed to reach its own next CLOSE-triggered re-arm. */
    uint32_t repEntry = build_close_only_task(mem, 0x1000);
    uint32_t repPde = build_pde(mem, 0x1010, repEntry);
    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, repPde, 1000000.0), "SCHEDULE ... REPEAT EVERY 1.0 handled");
    CHECK(sched_handle_wait_svc(sched, cpu, 0.5), "WAIT 0.5 handled (before the task's first firing)");
    /* WAIT 0.5 doesn't reach the task's own t=0 firing yet (WAIT's own
     * deadline, 0.5s, is earlier than the task's t=0 firing -- both are
     * "due now" from elapsedTimeUs=0, so the primal's own WAIT state
     * itself isn't what's being tested here; what matters is that
     * TERMINATE below removes the task before it can ever fire again). */
    CHECK(sched_handle_terminate_named_svc(sched, cpu, &repPde, 1), "TERMINATE (named) handled");
    CHECK(find_task_by_pde(sched, repPde) < 0, "TERMINATEd task's slot is fully freed, not just marked WAITING/DORMANT");

    /* Self form, via a fresh independent scheduler instance: a task
     * that TERMINATEs itself must not execute anything past that SVC. */
    AGEHarness age2;
    ageharness_init(&age2);
    CPU *cpu2 = &age2.gpc.cpu;
    MCM *mem2 = &cpu2->mainStorage;
    Scheduler *sched2 = &age2.halUCP.scheduler;

    uint32_t selfEntry = build_close_only_task(mem2, 0x1000); /* body is irrelevant; only reached via direct sched_handle_terminate_self_svc below */
    uint32_t selfPde = build_pde(mem2, 0x1010, selfEntry);
    psw_set_nia(&cpu2->psw, 0x3000);

    CHECK(sched_handle_schedule_svc(sched2, cpu2, 80, selfPde, 0.0), "SCHEDULE (one-shot) handled");
    CHECK(sched_handle_wait_svc(sched2, cpu2, 0.0), "WAIT 0 dispatches the task immediately");
    CHECK(psw_get_nia(&cpu2->psw) == selfEntry, "task dispatched (sanity check before self-TERMINATE)");
    CHECK(sched_handle_terminate_self_svc(sched2, cpu2), "self-TERMINATE handled");
    CHECK(psw_get_nia(&cpu2->psw) == 0x3000, "context switched back to the primal's own saved NIA, not left at the terminating task's own NIA");
    CHECK(sched2->tasks[sched2->runningIdx].isPrimal, "runningIdx is back on the primal pseudo-task after self-TERMINATE");

    ageharness_free(&age);
    ageharness_free(&age2);
}

/* ---------------------------------------------------------------------
 * 5. RUNTIME() (SVC 0x0016) and PRIO() (SVC 0x0317, halucp.c): neither
 *    is scheduler state (RUNTIME() is a pure cpu->elapsedTimeUs read;
 *    PRIO() a pure read of the running ScheduledTask's own priority),
 *    so these are driven directly via halucp_handle_svc() -- no hand-
 *    assembled machine code needed, just a single SVC-code halfword in
 *    memory and a direct C call. Deliberately NOT compared against
 *    yaHALMAT2's own RUNTIME() output anywhere in this project (see
 *    problems.md 7.4/7.5): two independently-invented instruction-
 *    timing models can't be expected to agree on an elapsed-time value,
 *    only that yaGPC2's own conversion from cpu->elapsedTimeUs is
 *    correct in isolation, which is exactly what this scenario checks.
 * ------------------------------------------------------------------- */

static void test_runtime_and_prio_builtins(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;

    const uint32_t svcAddr = 0x100;

    /* RUNTIME(): cpu->elapsedTimeUs (microseconds) -> FP0-FP1 as a
     * double-precision IBM float of seconds. */
    cpu->elapsedTimeUs = 2500000.0; /* 2.5s */
    mcm_set16(mem, svcAddr, 0x0016, false);
    CHECK(halucp_handle_svc(&age.halUCP, svcAddr, 0), "RUNTIME SVC handled");
    FloatIBM rt = fibm_from64(register_get32(registerfile_r(&cpu->regFiles[2], 0)),
                               register_get32(registerfile_r(&cpu->regFiles[2], 1)));
    double rtSeconds = fibm_to_float(&rt);
    CHECK(rtSeconds > 2.4999 && rtSeconds < 2.5001, "RUNTIME() returned ~2.5 seconds in FP0-FP1");

    /* PRIO(): the running ScheduledTask's own priority -> R5's upper 16
     * bits (same register ERRGRP/ERRNUM already use for their own
     * INTEGER results, halucp.c). */
    Scheduler *sched = &age.halUCP.scheduler;
    uint32_t taskEntry = build_close_only_task(mem, 0x1000);
    uint32_t taskPde = build_pde(mem, 0x1010, taskEntry);
    CHECK(sched_handle_schedule_svc(sched, cpu, 137, taskPde, 0.0), "SCHEDULE (priority 137) handled");
    CHECK(sched_handle_wait_svc(sched, cpu, 0.0), "WAIT 0 dispatches the task immediately");
    CHECK(psw_get_nia(&cpu->psw) == taskEntry, "task dispatched (sanity check before PRIO SVC)");

    mcm_set16(mem, svcAddr, 0x0317, false);
    CHECK(halucp_handle_svc(&age.halUCP, svcAddr, 0), "PRIO SVC handled");
    uint32_t prio = register_get32(registerfile_r(&cpu->regFiles[0], 5)) >> 16;
    CHECK(prio == 137, "PRIO() returned the running task's own priority (137)");

    /* PRIO() called with scheduling never engaged (no running task at
     * all) is documented here as returning 0 -- not confirmed against
     * any real fixture, but a defined, non-crashing default. */
    AGEHarness age2;
    ageharness_init(&age2);
    mcm_set16(&age2.gpc.cpu.mainStorage, svcAddr, 0x0317, false);
    CHECK(halucp_handle_svc(&age2.halUCP, svcAddr, 0), "PRIO SVC handled with no task ever scheduled");
    uint32_t prio2 = register_get32(registerfile_r(&age2.gpc.cpu.regFiles[0], 5)) >> 16;
    CHECK(prio2 == 0, "PRIO() with scheduling never engaged defaults to 0");

    ageharness_free(&age);
    ageharness_free(&age2);
}

/* ---------------------------------------------------------------------
 * 6. Process name as Boolean (USA003087 13.5): a task's own PDE+0 bit 0
 *    (compiled "IF <task> THEN" reads this directly, no SVC -- see
 *    sched_set_active_flag's own comment, src/schedule.c). Checks all
 *    three transitions: SCHEDULE sets it, TERMINATE clears it, and
 *    CLOSE-with-no-REPEAT (a one-shot task reaching its own natural end)
 *    also clears it -- distinct code paths in schedule.c, all three
 *    need independent coverage.
 * ------------------------------------------------------------------- */

static void test_process_name_as_boolean(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t entry = build_close_only_task(mem, 0x1000); /* one-shot: no REPEAT */
    uint32_t pde = build_pde(mem, 0x1010, entry);

    CHECK((mcm_get16(mem, pde) & 1) == 0, "PDE+0 bit 0 starts clear (never SCHEDULEd yet)");
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, pde, 0.0), "SCHEDULE (one-shot) handled");
    CHECK((mcm_get16(mem, pde) & 1) == 1, "PDE+0 bit 0 set immediately after SCHEDULE (ACTIVE)");

    CHECK(sched_handle_wait_svc(sched, cpu, 0.0), "WAIT 0 dispatches the task immediately");
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (CLOSE, no REPEAT -> deactivates) */
    CHECK((mcm_get16(mem, pde) & 1) == 0, "PDE+0 bit 0 cleared after reaching its own CLOSE with no REPEAT (INACTIVE)");

    /* Independently: TERMINATE's own deactivation path (a REPEATing
     * task, so CLOSE's own re-arm path would otherwise leave it ACTIVE
     * -- proving TERMINATE, not just "task no longer running", is what
     * clears the flag here). */
    uint32_t entry2 = build_close_only_task(mem, 0x2000);
    uint32_t pde2 = build_pde(mem, 0x2010, entry2);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, pde2, 1000000.0), "SCHEDULE (REPEAT EVERY) handled");
    CHECK((mcm_get16(mem, pde2) & 1) == 1, "second task's PDE+0 bit 0 set after SCHEDULE");
    CHECK(sched_handle_terminate_named_svc(sched, cpu, &pde2, 1), "TERMINATE (named) handled");
    CHECK((mcm_get16(mem, pde2) & 1) == 0, "second task's PDE+0 bit 0 cleared after TERMINATE, despite being a REPEAT EVERY task");

    ageharness_free(&age);
}

int main(void) {
    test_priority_ordering_and_context_roundtrip();
    test_repeat_every_counter_and_virtual_time();
    test_update_priority_flips_dispatch_order();
    test_terminate_named_and_self();
    test_runtime_and_prio_builtins();
    test_process_name_as_boolean();
    if (failures == 0) {
        printf("all scheduler-mechanics tests passed\n");
    } else {
        printf("%d scheduler-mechanics test(s) FAILED\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
