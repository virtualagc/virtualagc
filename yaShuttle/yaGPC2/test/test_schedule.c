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

int main(void) {
    test_priority_ordering_and_context_roundtrip();
    test_repeat_every_counter_and_virtual_time();
    if (failures == 0) {
        printf("all scheduler-mechanics tests passed\n");
    } else {
        printf("%d scheduler-mechanics test(s) FAILED\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
