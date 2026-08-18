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

/* A WAIT FOR / SCHEDULE ... ON event-expression descriptor (schedule.h's
 * own header comment documents the format, reverse-engineered from 7
 * real compiled signatures): [opcodeWord, reserved, PDE_1, ..., PDE_N].
 * connector: 0 = plain single operand (opcodeWord 0x0000, operandCount
 * must be 1), 1 = NOT single operand (0x1800, operandCount must be 1),
 * 2 = AND-chain, 3 = OR-chain (opcodeWord's top nibble = 2*(N-1), the
 * next nibble = 3 for AND / 1 for OR, repeated across the remaining
 * nibbles per the real encoding -- schedule.c's own decoder only reads
 * the second nibble, but this helper reproduces the full real pattern
 * for fidelity). Returns addr (the descriptor's own address). */
typedef enum { EVENT_PLAIN, EVENT_NOT, EVENT_AND, EVENT_OR } EventConnector;
static uint32_t build_event_desc(MCM *m, uint32_t addr, EventConnector connector,
                                  const uint32_t *operandPdes, int operandCount) {
    uint32_t opcode;
    if (connector == EVENT_PLAIN) {
        opcode = 0x0000;
    } else if (connector == EVENT_NOT) {
        opcode = 0x1800;
    } else {
        uint32_t code = (connector == EVENT_AND) ? 3 : 1;
        opcode = (uint32_t)(2 * (operandCount - 1)) << 12;
        for (int i = 0; i < operandCount - 1 && i < 3; i++) opcode |= code << (8 - 4 * i);
    }
    mcm_set16(m, addr, opcode, false);
    mcm_set16(m, addr + 1, 0, false);
    for (int i = 0; i < operandCount; i++) mcm_set16(m, addr + 2 + (uint32_t)i, operandPdes[i], false);
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
    CHECK(sched_handle_schedule_svc(sched, cpu, 10, lowPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE LOWTASK handled");
    CHECK(sched_handle_schedule_svc(sched, cpu, 200, hiPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE HITASK handled");
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

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, taskPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0 /* REPEAT EVERY 1.0s */, false, 0.0, false, false, 0, false),
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

    CHECK(sched_handle_schedule_svc(sched, cpu, 10, lowPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE LOWTASK(10) handled");
    CHECK(sched_handle_schedule_svc(sched, cpu, 90, hiPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE HITASK(90) handled");

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

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, repPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false), "SCHEDULE ... REPEAT EVERY 1.0 handled");
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

    CHECK(sched_handle_schedule_svc(sched2, cpu2, 80, selfPde, cpu2->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE (one-shot) handled");
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
    CHECK(sched_handle_schedule_svc(sched, cpu, 137, taskPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE (priority 137) handled");
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
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, pde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE (one-shot) handled");
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
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, pde2, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false), "SCHEDULE (REPEAT EVERY) handled");
    CHECK((mcm_get16(mem, pde2) & 1) == 1, "second task's PDE+0 bit 0 set after SCHEDULE");
    CHECK(sched_handle_terminate_named_svc(sched, cpu, &pde2, 1), "TERMINATE (named) handled");
    CHECK((mcm_get16(mem, pde2) & 1) == 0, "second task's PDE+0 bit 0 cleared after TERMINATE, despite being a REPEAT EVERY task");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 7. SCHEDULE ... IN (delayed initiation, halucp.c's FLAGS bit 0x0008)
 *    combined with REPEAT EVERY: the task's first firing must wait for
 *    the IN delay (not fire immediately like a plain SCHEDULE), and
 *    every subsequent REPEAT firing must be phase-anchored off that same
 *    delayed initialWakeDeadlineUs (1.5, 2.5, 3.5, ...), not off t=0
 *    (0.5, 1.5, 2.5, ... would be the wrong anchor). halucp.c itself
 *    only translates FLAGS/FPR0-1 into initialWakeDeadlineUs -- this
 *    calls sched_handle_schedule_svc directly with a hand-computed
 *    deadline, exercising exactly the same schedule.c logic
 *    deterministically. Cross-checked against a real compiled fixture
 *    (SCHEDULE NEXT IN 1.5 PRIORITY(80), REPEAT EVERY 1.0) matching
 *    yaHALMAT2's own output byte-for-byte -- see problems.md 7.7.
 * ------------------------------------------------------------------- */

static void test_schedule_in_delays_first_firing_and_anchors_repeat(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    const uint32_t counterDisp = 40;
    mcm_set16(mem, counterDisp, 0, false);

    uint32_t taskEntry = build_increment_and_close_task(mem, 0x200, counterDisp);
    uint32_t taskPde = build_pde(mem, 0x300, taskEntry);

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);

    /* SCHEDULE NEXT IN 1.5, REPEAT EVERY 1.0 -- initialWakeDeadlineUs is
     * elapsedTimeUs (0) + 1.5s, exactly what halucp.c's hasIn branch
     * would compute from FPR0-1. */
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, taskPde, cpu->elapsedTimeUs + 1500000.0, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false),
          "SCHEDULE ... IN, REPEAT EVERY handled");
    CHECK(sched_handle_wait_svc(sched, cpu, 5.0), "WAIT 5.0 handled");
    CHECK(psw_get_nia(&cpu->psw) == taskEntry, "first firing dispatched only once the IN delay elapses, not immediately");
    CHECK(close_to(cpu->elapsedTimeUs, 1500000.0), "elapsedTimeUs jumped straight to the IN deadline (1.5s), not t=0");

    /* Expected elapsedTimeUs after each firing's own CLOSE: firings 1-3
     * hand off to the next REPEAT firing, phase-anchored off 1.5s (2.5,
     * 3.5, 4.5); firing 4's CLOSE instead hands off to the primal (its
     * 5.0s WAIT deadline arrives before firing 5's would-be 5.5s). */
    const double expectedElapsedAfterFiring[] = {2500000.0, 3500000.0, 4500000.0, 5000000.0};
    const int expectedFirings = 4;
    int firing = 0;
    while (psw_get_nia(&cpu->psw) != primalResumeAddr && firing < 8) {
        for (int i = 0; i < 5; i++) ap101_exec1(&age.gpc);
        if (firing < expectedFirings) {
            char label[80];
            snprintf(label, sizeof label, "elapsedTimeUs approximately %.0f after firing %d",
                     expectedElapsedAfterFiring[firing], firing + 1);
            CHECK(close_to(cpu->elapsedTimeUs, expectedElapsedAfterFiring[firing]), label);
        }
        firing++;
    }

    CHECK(firing == expectedFirings, "exactly 4 firings occurred (at 1.5, 2.5, 3.5, 4.5) within the 5.0s WAIT");
    CHECK(mcm_get16(mem, counterDisp) == 4, "memory counter reached the expected value (4)");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed once its own WAIT deadline beat the 5th firing's");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 8. WAIT FOR <event-expression> (SVC #8, sched_handle_wait_for_svc):
 *    the already-TRUE no-op case (USA003087 24.6: "the statement has no
 *    effect"), a genuine block-and-resume case (NOT of an already-ACTIVE
 *    task, resolved only once that task later deactivates), and the
 *    AND-chain/OR-chain truth tables with a real mixed-truth operand set
 *    (one real compiled fixture per connector exists, but none exercise
 *    partial truth -- every fixture either has all operands ACTIVE, or
 *    none). No yaHALMAT2 oracle exists for any of this (a confirmed
 *    yaHALMAT2 bug -- see problems.md 7.8); verified directly against
 *    USA003087 24.6/24.8's own text instead.
 * ------------------------------------------------------------------- */

static void test_wait_for_event_expressions(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t aEntry = build_close_only_task(mem, 0x1000);
    uint32_t aPde = build_pde(mem, 0x1010, aEntry);
    uint32_t bEntry = build_close_only_task(mem, 0x1100);
    uint32_t bPde = build_pde(mem, 0x1110, bEntry);
    uint32_t cEntry = build_close_only_task(mem, 0x1200);
    uint32_t cPde = build_pde(mem, 0x1210, cEntry);
    (void)bEntry;
    (void)cEntry;

    /* --- already-TRUE no-op: A is ACTIVE (just SCHEDULEd), so "WAIT
     * FOR A" must have literally zero effect -- not even lazily
     * engaging the primal pseudo-task, since nothing was suspended. --- */
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, aPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE A handled");
    uint32_t plainA = build_event_desc(mem, 0x1300, EVENT_PLAIN, &aPde, 1);
    CHECK(sched_handle_wait_for_svc(sched, cpu, plainA), "WAIT FOR A (already TRUE) handled");
    CHECK(sched->runningIdx == -1, "already-TRUE WAIT FOR is a true no-op -- primal never even engaged");

    /* --- genuine block + resume: "WAIT FOR NOT A" is FALSE (A is still
     * ACTIVE), so the primal must block, A must be dispatched (nothing
     * else is ready), and once A reaches its own CLOSE (deactivating,
     * since it's one-shot) the primal must resume. --- */
    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);
    uint32_t notA = build_event_desc(mem, 0x1310, EVENT_NOT, &aPde, 1);
    CHECK(sched_handle_wait_for_svc(sched, cpu, notA), "WAIT FOR NOT A (initially FALSE) handled");
    CHECK(psw_get_nia(&cpu->psw) == aEntry, "A dispatched -- it's the only task whose event condition isn't blocking it");
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (CLOSE, no REPEAT -> deactivates, re-triggers dispatch) */
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr,
          "primal resumed once A's own CLOSE made NOT A true (event re-evaluated on the ACTIVE-flag transition)");

    /* --- AND-chain / OR-chain truth tables, mixed truth (A/B active,
     * C never scheduled -- INACTIVE): AND must be FALSE (blocks), OR
     * must be TRUE (no-op). --- */
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, aPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "re-SCHEDULE A handled");
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, bPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE B handled");
    /* C intentionally left never-SCHEDULEd -- INACTIVE. */

    uint32_t abcPdes[3] = {aPde, bPde, cPde};
    uint32_t andAbc = build_event_desc(mem, 0x1320, EVENT_AND, abcPdes, 3);
    uint32_t orAbc = build_event_desc(mem, 0x1330, EVENT_OR, abcPdes, 3);

    int beforeRunningIdx = sched->runningIdx;
    CHECK(sched_handle_wait_for_svc(sched, cpu, orAbc), "WAIT FOR A OR B OR C (TRUE: A and B active) handled");
    CHECK(sched->runningIdx == beforeRunningIdx, "OR already TRUE -- no dispatch, running context unchanged");

    psw_set_nia(&cpu->psw, primalResumeAddr);
    CHECK(sched_handle_wait_for_svc(sched, cpu, andAbc), "WAIT FOR A AND B AND C (FALSE: C inactive) handled");
    CHECK(psw_get_nia(&cpu->psw) != primalResumeAddr,
          "AND with one FALSE operand blocks -- primal does not simply continue");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 9. SCHEDULE ... ON <event-expression> (SVC #1, FLAGS=0x000d,
 *    sched_handle_schedule_on_svc): the target task is marked ACTIVE
 *    immediately (matching every other SCHEDULE variant's own "in the
 *    process queue" semantics) but must NOT actually be dispatched until
 *    its own trigger event becomes true -- verified here by forcing a
 *    real dispatch decision (a delta-time WAIT, which always dispatches
 *    unconditionally, unlike WAIT FOR) at a moment when a higher-
 *    priority ON-pending task's event is still FALSE, confirming the
 *    scheduler correctly skips it in favor of the one task that IS
 *    immediately eligible, then re-evaluates and dispatches it once its
 *    event becomes TRUE. Cross-checked against a real compiled fixture
 *    (SCHEDULE NEXT ON NOT A PRIORITY(80); SCHEDULE A PRIORITY(1);
 *    WAIT 0.001;) producing exactly this dispatch order -- problems.md
 *    7.8.
 * ------------------------------------------------------------------- */

static void test_schedule_on_deferred_dispatch(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t aEntry = build_close_only_task(mem, 0x1000);
    uint32_t aPde = build_pde(mem, 0x1010, aEntry);
    uint32_t nextEntry = build_close_only_task(mem, 0x1100);
    uint32_t nextPde = build_pde(mem, 0x1110, nextEntry);

    uint32_t notA = build_event_desc(mem, 0x1200, EVENT_NOT, &aPde, 1);

    /* NEXT (priority 80, higher than A's) is ON NOT A -- FALSE right
     * now, since A hasn't been SCHEDULEd/run yet -- so NEXT must NOT
     * preempt A despite outranking it. */
    CHECK(sched_handle_schedule_on_svc(sched, cpu, 80, nextPde, notA), "SCHEDULE NEXT ON NOT A handled");
    CHECK((mcm_get16(mem, nextPde) & 1) == 1, "NEXT marked ACTIVE immediately, before its trigger event ever fires");
    int nextIdx = find_task_by_pde(sched, nextPde);
    CHECK(nextIdx >= 0 && sched->tasks[nextIdx].eventDescAddr == notA, "NEXT's own slot records the event descriptor");

    CHECK(sched_handle_schedule_svc(sched, cpu, 1, aPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE A (priority 1, due now) handled");

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);
    CHECK(sched_handle_wait_svc(sched, cpu, 0.001), "primal WAIT 0.001 handled -- forces a real dispatch decision");
    CHECK(psw_get_nia(&cpu->psw) == aEntry,
          "A dispatched despite lower priority -- NEXT's own event is still FALSE, so it isn't a candidate at all");

    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (A's own CLOSE -- deactivates, makes NOT A true, re-dispatches) */
    CHECK(psw_get_nia(&cpu->psw) == nextEntry,
          "NEXT dispatched immediately once A's completion satisfied its ON condition");
    CHECK(nextIdx >= 0 && sched->tasks[nextIdx].eventDescAddr == 0,
          "eventDescAddr cleared once NEXT is actually dispatched -- no stale pointer left behind");

    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (NEXT's own CLOSE -- deactivates, primal's own WAIT deadline is next) */
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed once its own WAIT deadline was the next thing due");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 10. DEPENDENT (FLAGS bit 0x0020): a task's own CLOSE with a live
 *     DEPENDENT child blocks (TASK_STATE_WAITING_FOR_DEPENDENTS) instead
 *     of deactivating immediately, resuming (freeing) only once the
 *     dependent itself finishes (USA003087 13.3). Cross-checked against
 *     a real compiled fixture (DEPCLOSE.hal: PARENT SCHEDULEs A
 *     DEPENDENT then reaches its own bare CLOSE with no explicit WAIT --
 *     confirmed the real compiler emits the exact same bare SVC 0x0015
 *     regardless, so this really is this file's own runtime
 *     responsibility, not something compiler-inserted) producing
 *     "BEFORE / IN PARENT BEFORE / IN PARENT AFTER / IN A / DONE" -- see
 *     problems.md 7.9.
 * ------------------------------------------------------------------- */

static void test_dependent_close_blocks_until_dependent_finishes(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t aEntry = build_close_only_task(mem, 0x1000);
    uint32_t aPde = build_pde(mem, 0x1010, aEntry);
    uint32_t parentEntry = build_close_only_task(mem, 0x1100);
    uint32_t parentPde = build_pde(mem, 0x1110, parentEntry);

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, parentPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE PARENT handled");
    CHECK(sched_handle_wait_svc(sched, cpu, 0.001), "primal WAIT handled -- dispatches PARENT");
    CHECK(psw_get_nia(&cpu->psw) == parentEntry, "PARENT dispatched");

    /* Inside PARENT's own execution (s->runningIdx is now PARENT's own
     * slot), it SCHEDULEs A DEPENDENT -- A's own parentIdx should
     * therefore record PARENT, not the primal. */
    int parentIdx = find_task_by_pde(sched, parentPde);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, aPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, true), "SCHEDULE A DEPENDENT handled");
    int aIdx = find_task_by_pde(sched, aPde);
    CHECK(aIdx >= 0 && sched->tasks[aIdx].parentIdx == parentIdx, "A's own parentIdx records PARENT, the task that SCHEDULEd it");

    /* PARENT reaches its own CLOSE next -- A is still DORMANT (never
     * dispatched yet), so PARENT must block rather than deactivate. */
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (PARENT's own CLOSE) */
    CHECK(sched->tasks[parentIdx].state == TASK_STATE_WAITING_FOR_DEPENDENTS,
          "PARENT waits rather than deactivating -- A is still active");
    CHECK((mcm_get16(mem, parentPde) & 1) == 1, "PARENT's own PDE+0 ACTIVE bit stays set while waiting on A");
    CHECK(psw_get_nia(&cpu->psw) == aEntry, "A dispatched next (the only other eligible candidate)");

    /* A reaches its own CLOSE (no dependents of its own) -- frees A AND
     * cascade-releases PARENT, then dispatches whatever's next (the
     * primal, whose own 0.001s WAIT deadline is by now due). */
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (A's own CLOSE) */
    CHECK((mcm_get16(mem, aPde) & 1) == 0, "A deactivated");
    CHECK(sched->tasks[parentIdx].state == TASK_SLOT_FREE, "PARENT released once its last dependent finished");
    CHECK((mcm_get16(mem, parentPde) & 1) == 0, "PARENT's own PDE+0 ACTIVE bit cleared once released");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 11. WAIT FOR DEPENDENT (SVC #9, sched_handle_wait_for_dependent_svc):
 *     the no-dependents no-op case (USA003087 13.5: "If there are no
 *     dependents, the statement has no effect"), and a genuine block-
 *     and-resume case -- resumed as TASK_STATE_READY (execution
 *     continues), not freed, distinguishing this from the implicit
 *     CLOSE-with-dependents case above. Cross-checked against a real
 *     compiled fixture (WFDEP.hal) -- see problems.md 7.9.
 * ------------------------------------------------------------------- */

static void test_wait_for_dependent(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    CHECK(sched_handle_wait_for_dependent_svc(sched, cpu), "WAIT FOR DEPENDENT (no dependents) handled");
    CHECK(sched->runningIdx == -1, "no-dependents WAIT FOR DEPENDENT is a true no-op -- primal never even engaged");

    uint32_t aEntry = build_close_only_task(mem, 0x1000);
    uint32_t aPde = build_pde(mem, 0x1010, aEntry);

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, aPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, true), "SCHEDULE A DEPENDENT (on primal) handled");
    int primalIdx = sched->runningIdx;
    CHECK(primalIdx >= 0, "primal lazily engaged as A's own parent");

    CHECK(sched_handle_wait_for_dependent_svc(sched, cpu), "WAIT FOR DEPENDENT (A still active) handled");
    CHECK(sched->tasks[primalIdx].state == TASK_STATE_WAITING_FOR_DEPENDENTS, "primal blocked on A");
    CHECK(psw_get_nia(&cpu->psw) == aEntry, "A dispatched (the only other eligible candidate)");

    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (A's own CLOSE -- releases primal to
                             * TASK_STATE_READY, which the very same
                             * sched_dispatch() call then immediately
                             * picks up, landing it in TASK_STATE_RUNNING
                             * -- nothing else is competing for it) */
    CHECK(sched->tasks[primalIdx].state == TASK_STATE_RUNNING,
          "primal resumed (released to READY, then immediately dispatched -- not freed)");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed, execution continuing (not deactivated)");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 12. TERMINATE cascades to DEPENDENT descendants transitively
 *     (USA003087 13.3: "All dependents of the process are treated
 *     likewise"; 23.6 confirms this for cyclic processes specifically).
 *     Confirmed two levels deep: TERMINATE-ing GRANDPARENT also
 *     terminates PARENT (its own dependent) and, transitively, CHILD
 *     (PARENT's own dependent, never named directly). No real fixture
 *     exercises a 3-level chain (the real compiled fixtures in this
 *     item's own set only go one level deep) -- this is the
 *     deterministic regression test for the transitive case
 *     specifically.
 * ------------------------------------------------------------------- */

static void test_terminate_cascades_to_dependents_transitively(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t gpEntry = build_close_only_task(mem, 0x1000);
    uint32_t gpPde = build_pde(mem, 0x1010, gpEntry);
    uint32_t parentEntry = build_close_only_task(mem, 0x1100);
    uint32_t parentPde = build_pde(mem, 0x1110, parentEntry);
    uint32_t childEntry = build_close_only_task(mem, 0x1200);
    uint32_t childPde = build_pde(mem, 0x1210, childEntry);

    /* Each SCHEDULE ... DEPENDENT records whichever task is currently
     * "running" (s->runningIdx) as the new task's own parent -- forcing
     * runningIdx directly (rather than actually dispatching) is
     * sufficient to test that recording, and is safe here since
     * sched_handle_schedule_svc never reads anything else about the
     * running task's own state. */
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, gpPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE GRANDPARENT handled");
    int gpIdx = find_task_by_pde(sched, gpPde);
    sched->runningIdx = gpIdx;
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, parentPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, true), "SCHEDULE PARENT DEPENDENT (on GRANDPARENT) handled");
    int parentIdx = find_task_by_pde(sched, parentPde);
    sched->runningIdx = parentIdx;
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, childPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, true), "SCHEDULE CHILD DEPENDENT (on PARENT) handled");
    int childIdx = find_task_by_pde(sched, childPde);
    sched->runningIdx = -1;

    CHECK(sched->tasks[parentIdx].parentIdx == gpIdx, "PARENT's own parentIdx records GRANDPARENT");
    CHECK(sched->tasks[childIdx].parentIdx == parentIdx, "CHILD's own parentIdx records PARENT");

    CHECK(sched_handle_terminate_named_svc(sched, cpu, &gpPde, 1), "TERMINATE GRANDPARENT (named) handled");
    CHECK(sched->tasks[gpIdx].state == TASK_SLOT_FREE, "GRANDPARENT terminated");
    CHECK(sched->tasks[parentIdx].state == TASK_SLOT_FREE, "PARENT (GRANDPARENT's own dependent) also terminated");
    CHECK(sched->tasks[childIdx].state == TASK_SLOT_FREE,
          "CHILD (PARENT's own dependent, GRANDPARENT's grandchild) also terminated -- transitive cascade, never named directly");
    CHECK((mcm_get16(mem, gpPde) & 1) == 0, "GRANDPARENT's own PDE+0 ACTIVE bit cleared");
    CHECK((mcm_get16(mem, parentPde) & 1) == 0, "PARENT's own PDE+0 ACTIVE bit cleared");
    CHECK((mcm_get16(mem, childPde) & 1) == 0, "CHILD's own PDE+0 ACTIVE bit cleared");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 13. CANCEL (SVC #4 self / SVC #5 named). Three scenarios, none of
 *     which a real compiled fixture can fully exercise (combining
 *     CANCEL with DEPENDENT would need a multi-task program this
 *     session never built, and there's no yaHALMAT2 oracle for CANCEL
 *     at all -- it diverges from these traced/spec-derived semantics on
 *     all three real fixtures checked in alongside this item, see
 *     problems.md 7.11):
 *     (a) self-CANCEL defers to the end of the current cycle -- the
 *         cycle's own remaining code runs completely normally (already
 *         confirmed via a real compiled fixture, selfcancel.hal), and
 *         only the *next* re-arm is suppressed.
 *     (b) a named CANCEL of a DORMANT ("not yet initiated") target
 *         removes it immediately.
 *     (c) a named CANCEL of a DORMANT target with a still-active
 *         DEPENDENT child does not free it directly -- it waits
 *         (gracefully, the same TASK_STATE_WAITING_FOR_DEPENDENTS
 *         mechanism a natural CLOSE-with-dependents uses), and if that
 *         child happens to be RUNNING, cascading to it only flags it
 *         (cancelled=true) rather than force-freeing it, matching
 *         USA003087 23.6's own "cyclic dependents are allowed to finish
 *         their own current cycle of execution."
 * ------------------------------------------------------------------- */

static void test_cancel_self_defers_to_end_of_cycle(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    const uint32_t counterDisp = 40;
    mcm_set16(mem, counterDisp, 0, false);
    uint32_t taskEntry = build_increment_and_close_task(mem, 0x200, counterDisp);
    uint32_t taskPde = build_pde(mem, 0x300, taskEntry);

    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, taskPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false),
          "SCHEDULE ... REPEAT EVERY handled");
    CHECK(sched_handle_wait_svc(sched, cpu, 0.001), "primal WAIT handled -- dispatches the task");
    CHECK(psw_get_nia(&cpu->psw) == taskEntry, "task dispatched");

    /* Self-CANCEL, called directly mid-cycle (before the task's own
     * remaining LH/AHI/STH/LHI/SVC instructions run) -- must not touch
     * NIA, registers, or task state at all beyond the cancelled flag. */
    int taskIdx = sched->runningIdx;
    CHECK(sched_handle_cancel_self_svc(sched, cpu), "self-CANCEL handled");
    CHECK(sched->tasks[taskIdx].cancelled, "cancelled flag set");
    CHECK(sched->tasks[taskIdx].state == TASK_STATE_RUNNING, "task keeps running -- no control-flow change");
    CHECK(psw_get_nia(&cpu->psw) == taskEntry, "NIA unaffected by self-CANCEL");

    /* The rest of this cycle runs completely normally: LH, AHI, STH,
     * LHI, SVC (CLOSE) -- see build_increment_and_close_task. */
    for (int i = 0; i < 5; i++) ap101_exec1(&age.gpc);
    CHECK(mcm_get16(mem, counterDisp) == 1, "the cycle's own body ran to completion, incrementing the counter once");
    CHECK(sched->tasks[taskIdx].state == TASK_SLOT_FREE, "task deactivated -- cancelled REPEAT EVERY task does not re-arm");
    CHECK((mcm_get16(mem, taskPde) & 1) == 0, "task's own PDE+0 ACTIVE bit cleared");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal resumed (nothing else due)");

    ageharness_free(&age);
}

static void test_cancel_named_dormant_target_removed_immediately(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t aEntry = build_close_only_task(mem, 0x1000);
    uint32_t aPde = build_pde(mem, 0x1010, aEntry);
    uint32_t bEntry = build_close_only_task(mem, 0x1100);
    uint32_t bPde = build_pde(mem, 0x1110, bEntry);
    (void)aEntry;
    (void)bEntry;

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, aPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false), "SCHEDULE A handled");
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, bPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false), "SCHEDULE B handled");

    uint32_t targets[2] = {aPde, bPde};
    CHECK(sched_handle_cancel_named_svc(sched, cpu, targets, 2), "CANCEL A, B handled");

    int aIdx = find_task_by_pde(sched, aPde);
    int bIdx = find_task_by_pde(sched, bPde);
    CHECK(aIdx < 0, "A removed from the process queue -- never initiated");
    CHECK(bIdx < 0, "B removed from the process queue -- never initiated");
    CHECK((mcm_get16(mem, aPde) & 1) == 0, "A's own PDE+0 ACTIVE bit cleared");
    CHECK((mcm_get16(mem, bPde) & 1) == 0, "B's own PDE+0 ACTIVE bit cleared");

    ageharness_free(&age);
}

static void test_cancel_dormant_target_with_dependents_waits_gracefully(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    /* A 3-level chain: PARENT -> CHILD -> GRANDCHILD, GRANDCHILD is
     * RUNNING when PARENT gets CANCELed. A DORMANT dependent with no
     * active dependents of its own is always immediately freeable (see
     * this file's own sched_cancel_idx_and_dependents comment) -- so
     * genuinely testing "PARENT waits" needs the obstruction to be real,
     * not just DORMANT: only a RUNNING node (or one with its own
     * still-blocked dependent, recursively) resists immediate
     * cascade-free. This also confirms the wait propagates transitively
     * up the whole chain, not just one level. */
    uint32_t parentEntry = build_close_only_task(mem, 0x1000);
    uint32_t parentPde = build_pde(mem, 0x1010, parentEntry);
    uint32_t childEntry = build_close_only_task(mem, 0x1100);
    uint32_t childPde = build_pde(mem, 0x1110, childEntry);
    uint32_t grandchildEntry = build_close_only_task(mem, 0x1200);
    uint32_t grandchildPde = build_pde(mem, 0x1210, grandchildEntry);

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, parentPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false), "SCHEDULE PARENT handled");
    int parentIdx = find_task_by_pde(sched, parentPde);
    sched->runningIdx = parentIdx;
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, childPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, true), "SCHEDULE CHILD DEPENDENT (on PARENT) handled");
    int childIdx = find_task_by_pde(sched, childPde);
    sched->runningIdx = childIdx;
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, grandchildPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, true), "SCHEDULE GRANDCHILD DEPENDENT (on CHILD) handled");
    int grandchildIdx = find_task_by_pde(sched, grandchildPde);

    /* GRANDCHILD is RUNNING; CHILD and PARENT are both DORMANT (PARENT
     * "waiting between cycles", CHILD never yet initiated). */
    sched->tasks[grandchildIdx].state = TASK_STATE_RUNNING;
    sched->tasks[childIdx].state = TASK_STATE_DORMANT;
    sched->runningIdx = grandchildIdx;

    CHECK(sched_handle_cancel_named_svc(sched, cpu, &parentPde, 1), "CANCEL PARENT handled");
    CHECK(sched->tasks[grandchildIdx].state == TASK_STATE_RUNNING, "GRANDCHILD keeps running -- not force-freed mid-cycle");
    CHECK(sched->tasks[grandchildIdx].cancelled, "GRANDCHILD flagged cancelled");
    CHECK(sched->tasks[childIdx].state == TASK_STATE_WAITING_FOR_DEPENDENTS,
          "CHILD waits -- GRANDCHILD (its own dependent) is still active");
    CHECK(sched->tasks[parentIdx].state == TASK_STATE_WAITING_FOR_DEPENDENTS,
          "PARENT also waits -- the block propagates transitively up the whole chain");
    CHECK(sched->tasks[parentIdx].pendingCloseAfterDependents,
          "PARENT is waiting to be freed (not resumed) once satisfied -- this is CANCEL's own immediate-deactivation path, not an explicit WAIT FOR DEPENDENT");
    CHECK((mcm_get16(mem, parentPde) & 1) == 1, "PARENT's own PDE+0 ACTIVE bit stays set while waiting");
    CHECK((mcm_get16(mem, childPde) & 1) == 1, "CHILD's own PDE+0 ACTIVE bit stays set while waiting");

    /* GRANDCHILD now reaches its own natural CLOSE (no dependents of its
     * own, and cancelled -> no re-arm even though it's one-shot anyway)
     * -- frees GRANDCHILD and cascade-releases CHILD, which in turn
     * cascade-releases PARENT. */
    CHECK(sched_handle_task_close(sched, cpu), "GRANDCHILD's own CLOSE handled");
    CHECK(sched->tasks[childIdx].state == TASK_SLOT_FREE, "CHILD released once GRANDCHILD finished");
    CHECK(sched->tasks[parentIdx].state == TASK_SLOT_FREE, "PARENT released in the same cascade, transitively");
    CHECK((mcm_get16(mem, parentPde) & 1) == 0, "PARENT's own PDE+0 ACTIVE bit cleared once released");
    CHECK((mcm_get16(mem, childPde) & 1) == 0, "CHILD's own PDE+0 ACTIVE bit cleared once released");

    ageharness_free(&age);
}

static void test_cancel_cascades_to_running_dependent_by_flagging_not_freeing(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t parentEntry = build_close_only_task(mem, 0x1000);
    uint32_t parentPde = build_pde(mem, 0x1010, parentEntry);
    uint32_t childEntry = build_close_only_task(mem, 0x1100);
    uint32_t childPde = build_pde(mem, 0x1110, childEntry);

    CHECK(sched_handle_schedule_svc(sched, cpu, 80, parentPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, false), "SCHEDULE PARENT handled");
    int parentIdx = find_task_by_pde(sched, parentPde);
    sched->runningIdx = parentIdx;
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, childPde, cpu->elapsedTimeUs, SCHED_REPEAT_EVERY, 1000000.0, false, 0.0, false, false, 0, true), "SCHEDULE CHILD DEPENDENT (on PARENT), REPEAT EVERY, handled");
    int childIdx = find_task_by_pde(sched, childPde);

    /* CHILD is now RUNNING ("in a cycle of execution") when PARENT gets
     * CANCELed -- USA003087 23.6: "cyclic dependents are allowed to
     * finish their own current cycle of execution," so the cascade must
     * flag CHILD (cancelled=true), not force-free it mid-cycle. */
    sched->tasks[childIdx].state = TASK_STATE_RUNNING;
    sched->runningIdx = childIdx;
    sched->tasks[parentIdx].state = TASK_STATE_DORMANT; /* PARENT waiting between cycles */
    CHECK(sched_handle_cancel_named_svc(sched, cpu, &parentPde, 1), "CANCEL PARENT (cascading to running CHILD) handled");
    CHECK(sched->tasks[childIdx].state == TASK_STATE_RUNNING, "CHILD keeps running -- not force-freed mid-cycle");
    CHECK(sched->tasks[childIdx].cancelled, "CHILD flagged cancelled -- won't re-arm at its own next CLOSE");
    CHECK(sched->tasks[parentIdx].state == TASK_STATE_WAITING_FOR_DEPENDENTS,
          "PARENT waits -- CHILD (though flagged) is still technically active");

    /* CHILD reaches its own CLOSE: cancelled + hasRepeat -> does not
     * re-arm, falls through to free (no dependents of its own),
     * cascade-releasing PARENT in turn. */
    CHECK(sched_handle_task_close(sched, cpu), "CHILD's own CLOSE handled");
    CHECK(sched->tasks[childIdx].state == TASK_SLOT_FREE, "CHILD deactivated -- cancelled REPEAT EVERY task does not re-arm");
    CHECK(sched->tasks[parentIdx].state == TASK_SLOT_FREE, "PARENT released once CHILD (its last dependent) finished");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 14. EXCLUSIVE procedures/functions (SVC #15 reserve / #17 release,
 *     code block) and UPDATE blocks (SVC #16 reserve / #18 release,
 *     data area) -- USA003087 27.2/26.4, confirmed against
 *     IBM-76-SS-1110 4.2.2/4.2.2.3's own fully-documented reserve/
 *     release SVC family (see schedule.h's own header comment). The
 *     EXCLUSIVE case is cross-checked against a real compiled fixture
 *     with genuine cross-task contention (exclusivecontend.hal); the
 *     UPDATE-block case is deterministic-only -- compiling a real
 *     LOCK-group-using COMPOOL+PROGRAM pair needs a multi-module link
 *     this session didn't set up, but the underlying scheduler mechanics
 *     (blocking, grant-on-dispatch, fast-forward exclusion) are the
 *     exact same code paths the EXCLUSIVE case already exercises for
 *     real -- only the SVC numbers and the exact-match-vs-overlap
 *     comparison differ, both taken directly from the ICD's own table.
 * ------------------------------------------------------------------- */

static void test_exclusive_lock_blocks_and_releases_correctly(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    const uint32_t LOCK_ID = 0x9999; /* arbitrary -- real compiled code uses a CSECT-word address, but this file's own handlers never interpret the value, only compare it */

    uint32_t bEntry = build_close_only_task(mem, 0x1000);
    uint32_t bPde = build_pde(mem, 0x1010, bEntry);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, bPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE B handled");

    CHECK(sched_handle_reserve_code_svc(sched, cpu, LOCK_ID), "primal RESERVE (free) handled");
    CHECK(sched->runningIdx == -1, "immediately-granted RESERVE doesn't engage a scheduler slot");
    int lockSlot = -1;
    for (int i = 0; i < SCHED_MAX_CODE_LOCKS; i++) if (sched->codeLocks[i].lockId == LOCK_ID) lockSlot = i;
    CHECK(lockSlot >= 0 && sched->codeLocks[lockSlot].holderIdx == -1, "lock recorded as held by the (still-unengaged) primal");

    /* Primal WAITs (simulating work inside the reserved procedure) --
     * lazily engages the primal and dispatches B, the only other ready
     * candidate. */
    CHECK(sched_handle_wait_svc(sched, cpu, 1.0), "primal WAIT handled");
    int primalIdx = -1;
    for (int i = 0; i < sched->count; i++) if (sched->tasks[i].isPrimal) primalIdx = i;
    int bIdx = sched->runningIdx;
    CHECK(primalIdx >= 0 && bIdx >= 0 && bIdx != primalIdx, "B dispatched, primal now has a real slot");

    /* B tries to enter the same EXCLUSIVE region -- must block. */
    CHECK(sched_handle_reserve_code_svc(sched, cpu, LOCK_ID), "B's own RESERVE (contended) handled");
    CHECK(sched->tasks[bIdx].state == TASK_STATE_WAITING, "B blocks -- LOCK_ID is still held by the primal");
    CHECK(sched->tasks[bIdx].waitingOnCodeLockId == LOCK_ID, "B's own waitingOnCodeLockId records the contended lock");
    CHECK(sched->runningIdx == primalIdx, "primal resumed -- nothing else eligible (fast-forwarded to its own WAIT deadline)");

    /* Primal releases -- B is still blocked (release never forces a
     * dispatch, matching every other already-handled SVC's own "never
     * changes which context is live" contract). */
    CHECK(sched_handle_release_code_svc(sched, cpu, LOCK_ID), "primal RELEASE handled");
    lockSlot = -1;
    for (int i = 0; i < SCHED_MAX_CODE_LOCKS; i++) if (sched->codeLocks[i].lockId == LOCK_ID) lockSlot = i;
    CHECK(lockSlot < 0, "lock freed after RELEASE");
    CHECK(sched->tasks[bIdx].state == TASK_STATE_WAITING, "B still blocked -- RELEASE alone doesn't force a dispatch");

    /* Only once something actually forces a fresh dispatch decision does
     * B get picked up and granted the lock. */
    CHECK(sched_handle_wait_svc(sched, cpu, 0.001), "primal WAIT (forces a dispatch decision) handled");
    CHECK(sched->runningIdx == bIdx, "B dispatched -- its own contended RESERVE is now satisfied");
    CHECK(sched->tasks[bIdx].waitingOnCodeLockId == 0, "B's own waitingOnCodeLockId cleared once granted");
    lockSlot = -1;
    for (int i = 0; i < SCHED_MAX_CODE_LOCKS; i++) if (sched->codeLocks[i].lockId == LOCK_ID) lockSlot = i;
    CHECK(lockSlot >= 0 && sched->codeLocks[lockSlot].holderIdx == bIdx, "B now holds LOCK_ID, granted at dispatch time");

    ageharness_free(&age);
}

static void test_update_block_lock_groups_overlap_and_release(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t bEntry = build_close_only_task(mem, 0x1000);
    uint32_t bPde = build_pde(mem, 0x1010, bEntry);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, bPde, cpu->elapsedTimeUs, SCHED_REPEAT_NONE, 0.0, false, 0.0, false, false, 0, false), "SCHEDULE B handled");

    /* Primal reserves LOCK GROUPs {1,2} (mask 0x0003) -- unlike a
     * code-lock RESERVE, this always engages a real scheduler slot even
     * when granted immediately (see sched_handle_reserve_data_svc's own
     * header comment: per-task heldDataLockMask tracking needs it,
     * unlike the code-lock case's own global table). */
    CHECK(sched_handle_reserve_data_svc(sched, cpu, 0x0003), "primal RESERVE groups {1,2} handled");
    int primalIdx = -1;
    for (int i = 0; i < sched->count; i++) if (sched->tasks[i].isPrimal) primalIdx = i;
    CHECK(primalIdx >= 0 && sched->tasks[primalIdx].heldDataLockMask == 0x0003, "primal holds groups {1,2} immediately, already recorded");

    CHECK(sched_handle_wait_svc(sched, cpu, 1.0), "primal WAIT (simulating work inside the UPDATE block) handled");
    CHECK(primalIdx >= 0 && sched->tasks[primalIdx].heldDataLockMask == 0x0003,
          "primal's own held mask persists while it's blocked on something unrelated");
    int bIdx = sched->runningIdx;
    CHECK(bIdx >= 0 && bIdx != primalIdx, "B dispatched");

    /* B reserves groups {2,3} (mask 0x0006) -- overlaps only on group 2,
     * but a PARTIAL overlap is still a conflict; must block despite
     * group 3 alone being free. */
    CHECK(sched_handle_reserve_data_svc(sched, cpu, 0x0006), "B's own RESERVE groups {2,3} (partially overlapping) handled");
    CHECK(sched->tasks[bIdx].state == TASK_STATE_WAITING, "B blocks -- group 2 overlaps the primal's own held mask");
    CHECK(sched->tasks[bIdx].waitingOnDataLockMask == 0x0006, "B's own waitingOnDataLockMask records the full requested mask");
    CHECK(sched->runningIdx == primalIdx, "primal resumed -- nothing else eligible");

    /* Primal releases {1,2} -- frees group 2, resolving B's own overlap. */
    CHECK(sched_handle_release_data_svc(sched, cpu, 0x0003), "primal RELEASE groups {1,2} handled");
    CHECK(sched->tasks[primalIdx].heldDataLockMask == 0, "primal holds nothing now");

    CHECK(sched_handle_wait_svc(sched, cpu, 0.001), "primal WAIT (forces a dispatch decision) handled");
    CHECK(sched->runningIdx == bIdx, "B dispatched -- its own contended RESERVE is now satisfied");
    CHECK(sched->tasks[bIdx].waitingOnDataLockMask == 0, "B's own waitingOnDataLockMask cleared once granted");
    CHECK(sched->tasks[bIdx].heldDataLockMask == 0x0006, "B now holds groups {2,3}, granted at dispatch time");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 17. SCHEDULE ... REPEAT's remaining cadences (USA003087 23.5): bare
 *     REPEAT (immediate recycling -- re-arms to "now," not phase-
 *     anchored the way EVERY is) and REPEAT AFTER (constant intercycle
 *     delay measured from the END of the previous cycle, also not
 *     phase-anchored -- by construction it can't drift). Contrast with
 *     test_repeat_every_counter_and_virtual_time's own EVERY case above.
 * ------------------------------------------------------------------- */

static void test_repeat_bare_and_after_cadence(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    uint32_t bareEntry = build_close_only_task(mem, 0x1000);
    uint32_t barePde = build_pde(mem, 0x1010, bareEntry);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, barePde, cpu->elapsedTimeUs, SCHED_REPEAT_BARE, 0.0, false, 0.0, false, false, 0, false),
          "SCHEDULE ... REPEAT (bare) handled");
    int bareIdx = find_task_by_pde(sched, barePde);
    CHECK(bareIdx >= 0, "bare-REPEAT task tracked");
    CHECK(sched->tasks[bareIdx].repeatMode == SCHED_REPEAT_BARE, "repeatMode recorded as BARE");

    CHECK(sched_handle_wait_svc(sched, cpu, 5.0), "WAIT 5.0 handled");
    CHECK(psw_get_nia(&cpu->psw) == bareEntry, "bare-REPEAT task's first firing dispatched immediately");
    ap101_exec1(&age.gpc); /* LHI */
    double closeTimeUs = cpu->elapsedTimeUs; /* captured right before the CLOSE SVC itself runs */
    ap101_exec1(&age.gpc); /* SVC (CLOSE -- re-arms) */
    CHECK(close_to(sched->tasks[bareIdx].wakeDeadlineUs, closeTimeUs),
          "bare REPEAT re-arms to (approximately) its own CLOSE time, not a phase-anchored future deadline");

    uint32_t afterEntry = build_close_only_task(mem, 0x1100);
    uint32_t afterPde = build_pde(mem, 0x1110, afterEntry);
    CHECK(sched_handle_schedule_svc(sched, cpu, 90, afterPde, cpu->elapsedTimeUs, SCHED_REPEAT_AFTER, 2000000.0 /* AFTER 2.0s */, false, 0.0, false, false, 0, false),
          "SCHEDULE ... REPEAT AFTER handled");
    int afterIdx = find_task_by_pde(sched, afterPde);
    CHECK(afterIdx >= 0, "REPEAT AFTER task tracked");
    CHECK(sched->tasks[afterIdx].repeatMode == SCHED_REPEAT_AFTER, "repeatMode recorded as AFTER");
    CHECK(sched->tasks[afterIdx].priority == 90 && sched->tasks[afterIdx].priority > sched->tasks[bareIdx].priority,
          "AFTER task outranks the bare-REPEAT task -- dispatched at the next dispatch decision");
    /* SCHEDULE itself never forces a dispatch decision (its own header
     * comment: "never changes which context is live") -- the bare task,
     * already re-dispatched by its own prior CLOSE (which calls
     * sched_dispatch() internally) before this SCHEDULE call even ran,
     * is still the live context. Running IT to its own next CLOSE is
     * what forces the next real dispatch decision, at which point the
     * now-DORMANT-and-immediately-eligible, higher-priority AFTER task
     * wins. */
    CHECK(psw_get_nia(&cpu->psw) == bareEntry, "bare task still live -- SCHEDULE alone doesn't force a dispatch");
    ap101_exec1(&age.gpc); /* LHI (bare task's own SECOND firing) */
    ap101_exec1(&age.gpc); /* SVC (bare task's own CLOSE -- forces the next dispatch decision) */
    CHECK(psw_get_nia(&cpu->psw) == afterEntry, "higher-priority REPEAT AFTER task dispatched over the re-armed bare task");
    ap101_exec1(&age.gpc); /* LHI */
    closeTimeUs = cpu->elapsedTimeUs;
    ap101_exec1(&age.gpc); /* SVC (CLOSE -- re-arms) */
    CHECK(close_to(sched->tasks[afterIdx].wakeDeadlineUs, closeTimeUs + 2000000.0),
          "REPEAT AFTER re-arms to (approximately) its own CLOSE time plus the 2.0s delay");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 18. SCHEDULE ... REPEAT ... UNTIL time (USA003087 23.5): cancellation
 *     checked both "at the end of the first cycle which finishes later
 *     than the specified time" (at CLOSE) and, per the same section's
 *     own provision, immediately if the condition is met "in the
 *     interval between cycles" (while DORMANT, not waiting for the next
 *     cycle's own CLOSE). The second scenario is the direct regression
 *     test for a real internal bug: sched_dispatch's own virtual-time
 *     fast-forward wasn't originally considering a DORMANT task's own
 *     UNTIL time as a candidate deadline, so with nothing else pending
 *     in between, it would jump straight past the cancellation instant
 *     to the task's own next (much later) wake time -- invisible in the
 *     task's own dispatch/cancel outcome (correct either way) but wrong
 *     in cpu->elapsedTimeUs itself, directly observable via RUNTIME()/
 *     DATE()/CLOCKTIME(). See problems.md 7.16 and this same scenario's
 *     own real-fixture counterpart, test/fixtures/repeataftercancel.hal.
 * ------------------------------------------------------------------- */

static void test_repeat_until_time_cancels_at_close_and_between_cycles(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    /* Scenario 1: UNTIL time already reached by the time a cycle's own
     * CLOSE runs (small EVERY interval, small UNTIL) -- cancellation
     * happens right there, no between-cycles gap involved at all. */
    uint32_t everyEntry = build_close_only_task(mem, 0x1000);
    uint32_t everyPde = build_pde(mem, 0x1010, everyEntry);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, everyPde, cpu->elapsedTimeUs,
                                     SCHED_REPEAT_EVERY, 1000000.0 /* EVERY 1.0s -- never actually reached, cancelled first */,
                                     true, 1.0 /* UNTIL 1us after the real-time origin -- already in the past by the
                                                * time the WAIT 1.0 below lets this task's first CLOSE run */,
                                     false, false, 0, false),
          "SCHEDULE ... REPEAT EVERY ... UNTIL (already-passed) handled");
    int everyIdx = find_task_by_pde(sched, everyPde);
    CHECK(everyIdx >= 0, "EVERY+UNTIL task tracked before its first CLOSE");
    CHECK(sched_handle_wait_svc(sched, cpu, 1.0), "WAIT 1.0 handled");
    CHECK(psw_get_nia(&cpu->psw) == everyEntry, "EVERY+UNTIL task's first firing dispatched immediately");
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (CLOSE -- UNTIL already passed, does not re-arm) */
    CHECK(sched->tasks[everyIdx].state == TASK_SLOT_FREE, "cancelled at CLOSE -- slot freed, not re-armed DORMANT");

    /* Scenario 2: the between-cycles case -- REPEAT AFTER with a delay
     * (10s) much longer than UNTIL (3s), DEPENDENT + WAIT FOR DEPENDENT
     * so the primal's own resumption goes through sched_dispatch's
     * fast-forward (not some other, closer, unrelated deadline masking
     * the effect -- the primal has no numeric deadline of its own while
     * WAITING_FOR_DEPENDENTS). */
    uint32_t afterEntry = build_close_only_task(mem, 0x2000);
    uint32_t afterPde = build_pde(mem, 0x2010, afterEntry);
    const uint32_t primalResumeAddr = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, afterPde, cpu->elapsedTimeUs, SCHED_REPEAT_AFTER, 10000000.0 /* AFTER 10.0s */, true, 3000000.0 /* UNTIL 3.0s */, false, false, 0, true /* DEPENDENT */),
          "SCHEDULE ... REPEAT AFTER ... UNTIL (DEPENDENT) handled");
    int primalIdx = sched->runningIdx;
    CHECK(primalIdx >= 0, "primal lazily engaged as the AFTER task's own parent");
    int afterIdx = find_task_by_pde(sched, afterPde);
    CHECK(afterIdx >= 0, "REPEAT AFTER ... UNTIL task tracked");

    CHECK(sched_handle_wait_for_dependent_svc(sched, cpu), "WAIT FOR DEPENDENT handled");
    CHECK(sched->tasks[primalIdx].state == TASK_STATE_WAITING_FOR_DEPENDENTS, "primal blocked on the AFTER task");
    CHECK(psw_get_nia(&cpu->psw) == afterEntry, "AFTER task dispatched (the only other eligible candidate)");
    /* This CLOSE's own re-arm (UNTIL, 3.0s, is not yet reached at ~0s, so
     * it re-arms DORMANT rather than cancelling right here) AND the
     * between-cycles cancellation once sched_dispatch's own fast-forward
     * reaches 3.0s (sched_handle_task_close calls sched_dispatch()
     * internally, synchronously, as part of the very same CLOSE SVC) both
     * happen before control ever returns here -- there is no way to
     * observe the intermediate re-armed-DORMANT-at-10.0s state from
     * outside; only the final, already-resolved outcome. */
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (CLOSE -- re-arms, then immediately cancelled between cycles) */
    CHECK(sched->tasks[afterIdx].state == TASK_SLOT_FREE, "cancelled between cycles -- slot freed before its own 10.0s wake was ever reached");
    CHECK(sched->runningIdx == primalIdx, "primal resumed once its only dependent finished");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr, "primal's own execution continuing, not deactivated");
    CHECK(close_to(cpu->elapsedTimeUs, 3000000.0),
          "elapsedTimeUs landed on (approximately) the UNTIL time itself (3.0s), not overshot to the AFTER task's own next wake (10.0s)");

    ageharness_free(&age);
}

/* ---------------------------------------------------------------------
 * 19. SCHEDULE ... REPEAT's event-expression cancellation clauses
 *     (USA003087 24.5): "REPEAT cycle WHILE exp" and "REPEAT cycle
 *     UNTIL exp" (exp an event expression -- distinct from the numeric
 *     UNTIL-time clause tested above). WHILE is checked even before
 *     this task's very first dispatch (24.5: "if the value of exp
 *     becomes FALSE before the process is initiated, it is merely
 *     removed... without ever executing"); UNTIL explicitly guarantees
 *     "at least one cycle shall be executed" regardless of exp's
 *     initial value. The UNTIL scenario below is the direct regression
 *     test for a real bug caught while building the real-fixture
 *     counterpart (test/fixtures/repeatuntilevent.hal): an earlier
 *     draft gated the between-cycles check on ScheduledTask.hasRun,
 *     which is reset back to false by every re-arm (not just the
 *     first), so it couldn't distinguish "never run" from "between
 *     cycle 2 and 3" -- the event going TRUE between cycles 2 and 3
 *     was incorrectly ignored (treated as "still before the guaranteed
 *     first cycle"), letting a 3rd cycle run that should have been
 *     cancelled. Fixed with a dedicated completedFirstCycle field that,
 *     unlike hasRun, is never reset. See problems.md 7.17.
 * ------------------------------------------------------------------- */

static void test_repeat_while_until_event_cancellation(void) {
    AGEHarness age;
    ageharness_init(&age);
    CPU *cpu = &age.gpc.cpu;
    MCM *mem = &cpu->mainStorage;
    Scheduler *sched = &age.halUCP.scheduler;

    /* Scenario 1: WHILE, exp already FALSE before the very first
     * dispatch -- removed from the process queue without ever running
     * at all (24.5's own explicit provision for this case). */
    const uint32_t ev1Addr = 40;
    mcm_set16(mem, ev1Addr, 0, false); /* EV1 = FALSE */
    uint32_t whileDescAddr = build_event_desc(mem, 100, EVENT_PLAIN, &ev1Addr, 1);
    uint32_t whileEntry = build_close_only_task(mem, 0x1000);
    uint32_t whilePde = build_pde(mem, 0x1010, whileEntry);
    const uint32_t primalResumeAddr1 = 0x3000;
    psw_set_nia(&cpu->psw, primalResumeAddr1);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, whilePde, cpu->elapsedTimeUs,
                                     SCHED_REPEAT_EVERY, 1000000.0, false, 0.0,
                                     true, false /* WHILE */, whileDescAddr, false),
          "SCHEDULE ... REPEAT EVERY WHILE (already-FALSE) handled");
    int whileIdx = find_task_by_pde(sched, whilePde);
    CHECK(whileIdx >= 0, "WHILE task tracked immediately after SCHEDULE");
    CHECK(sched_handle_wait_svc(sched, cpu, 1.0), "WAIT 1.0 handled (forces the first dispatch decision)");
    CHECK(sched->tasks[whileIdx].state == TASK_SLOT_FREE, "removed without ever executing -- exp was already FALSE");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr1, "primal resumed directly, the WHILE task never dispatched at all");

    /* Scenario 2: UNTIL, exp FALSE through cycle 1 (guaranteed to run
     * regardless), then becomes TRUE while DORMANT between cycles 2 and
     * 3 -- must cancel before cycle 3 ever dispatches. NOT DEPENDENT --
     * the primal needs its own independent, genuinely-competing WAIT
     * deadlines (mirroring test/fixtures/repeatuntilevent.hal's own
     * primal control flow exactly: WAIT 1.5; SET EV1; WAIT 5.0;) so
     * there's always something else for sched_dispatch to pick besides
     * the cyclic task's own next cycle -- with DEPENDENT + WAIT FOR
     * DEPENDENT (as in the numeric-UNTIL overshoot test above), nothing
     * else would exist to dispatch to in between, so cycle 2's own
     * CLOSE would resolve the *entire* rest of dispatch synchronously
     * (including cycle 3) before this test ever got a chance to flip
     * the event externally. */
    const uint32_t ev2Addr = 42;
    mcm_set16(mem, ev2Addr, 0, false); /* EV2 = FALSE */
    uint32_t untilDescAddr = build_event_desc(mem, 110, EVENT_PLAIN, &ev2Addr, 1);
    uint32_t untilEntry = build_close_only_task(mem, 0x2000);
    uint32_t untilPde = build_pde(mem, 0x2010, untilEntry);
    const uint32_t primalResumeAddr2 = 0x4000;
    psw_set_nia(&cpu->psw, primalResumeAddr2);
    CHECK(sched_handle_schedule_svc(sched, cpu, 80, untilPde, cpu->elapsedTimeUs,
                                     SCHED_REPEAT_EVERY, 1000000.0 /* EVERY 1.0s */, false, 0.0,
                                     true, true /* UNTIL */, untilDescAddr, false),
          "SCHEDULE ... REPEAT EVERY UNTIL (event) handled");
    int untilIdx = find_task_by_pde(sched, untilPde);
    CHECK(untilIdx >= 0, "UNTIL task tracked");

    /* Primal's own WAIT 1.5 -- lazily engages the primal, then dispatches
     * cycle 1 (due now, the only immediately-eligible candidate). */
    CHECK(sched_handle_wait_svc(sched, cpu, 1.5), "primal WAIT 1.5 handled");
    int primalIdx = -1;
    for (int i = 0; i < sched->count; i++) if (sched->tasks[i].isPrimal) primalIdx = i;
    CHECK(primalIdx >= 0, "primal lazily engaged");
    CHECK(psw_get_nia(&cpu->psw) == untilEntry, "cycle 1 dispatched -- guaranteed regardless of exp's initial value");
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (cycle 1's own CLOSE -- exp still FALSE, re-arms to 1.0s; primal's own 1.5s deadline is later, so cycle 2 wins) */
    CHECK(psw_get_nia(&cpu->psw) == untilEntry, "cycle 2 dispatched -- exp still FALSE at cycle 1's own CLOSE");
    ap101_exec1(&age.gpc); /* LHI */
    ap101_exec1(&age.gpc); /* SVC (cycle 2's own CLOSE -- exp still FALSE, re-arms to 2.0s; primal's own 1.5s deadline is now earlier, so primal wins) */
    CHECK(sched->runningIdx == primalIdx, "primal resumed -- its own 1.5s deadline beat the UNTIL task's re-armed 2.0s one");
    CHECK(psw_get_nia(&cpu->psw) == primalResumeAddr2, "primal's own execution continuing at its WAIT 1.5's own return point");
    CHECK(sched->tasks[untilIdx].state == TASK_STATE_DORMANT, "UNTIL task re-armed DORMANT, waiting for cycle 3 at 2.0s");

    /* exp becomes TRUE while the UNTIL task sits DORMANT between cycles
     * 2 and 3 -- a plain SET-equivalent (this file has no SVC-level
     * SIGNAL/SET/RESET helper; schedule.c's own sched_task_active reads
     * bit 0 directly, the same convention every EVENT-variable-operand
     * fixture in this whole session relies on). Primal's own next WAIT
     * (5.0, mirroring the real fixture) is what forces the next
     * dispatch decision -- SET/RESET themselves never force one (see
     * apply_ignore_event_action's own comment in halucp.c). */
    mcm_set16(mem, ev2Addr, 1, false); /* EV2 = TRUE */
    CHECK(sched_handle_wait_svc(sched, cpu, 5.0), "primal WAIT 5.0 handled");
    CHECK(sched->tasks[untilIdx].state == TASK_SLOT_FREE,
          "cancelled between cycles once exp went TRUE -- cycle 3 never dispatches (the hasRun-vs-completedFirstCycle regression)");
    CHECK(sched->runningIdx == primalIdx, "primal is the only remaining candidate -- resumed once nothing else was left");

    ageharness_free(&age);
}

int main(void) {
    test_priority_ordering_and_context_roundtrip();
    test_repeat_every_counter_and_virtual_time();
    test_update_priority_flips_dispatch_order();
    test_terminate_named_and_self();
    test_runtime_and_prio_builtins();
    test_process_name_as_boolean();
    test_schedule_in_delays_first_firing_and_anchors_repeat();
    test_wait_for_event_expressions();
    test_schedule_on_deferred_dispatch();
    test_dependent_close_blocks_until_dependent_finishes();
    test_wait_for_dependent();
    test_terminate_cascades_to_dependents_transitively();
    test_cancel_self_defers_to_end_of_cycle();
    test_cancel_named_dormant_target_removed_immediately();
    test_cancel_dormant_target_with_dependents_waits_gracefully();
    test_cancel_cascades_to_running_dependent_by_flagging_not_freeing();
    test_exclusive_lock_blocks_and_releases_correctly();
    test_update_block_lock_groups_overlap_and_release();
    test_repeat_bare_and_after_cadence();
    test_repeat_until_time_cancels_at_close_and_between_cycles();
    test_repeat_while_until_event_cancellation();
    if (failures == 0) {
        printf("all scheduler-mechanics tests passed\n");
    } else {
        printf("%d scheduler-mechanics test(s) FAILED\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
