/* Coverage for iop_discrete_in_a() (src/iop.c) -- the MASS MEMORY READY
 * bits of discrete input A, which are computed per read rather than stored.
 *
 * What this is protecting.  FCMBOOT, the IPL bootstrap loader the IOP
 * microcode fetches from the mass memory, does not sample MM READY once.
 * Having chosen its mass memory from the IPL-source bits it HANDSHAKES on
 * the ready bit, in three stages (FCMBOOT.asm):
 *
 *     "LOOP UNTIL MASS MEMORY IS READY"          DO UNTIL=(NZ)
 *     "LOOP UNTIL THE MASS MEMORY IS BUSY"       DO UNTIL=(Z)
 *     "LOOP UNTIL POSITION OR READ IS COMPLETE"  DO UNTIL=(NZ)
 *
 * all three reading discrete A and masking with the same bus mask.  This
 * port used to hold the whole register constant, with MM1 READY permanently
 * set.  That satisfies stage 1 and then spins forever in stage 2, because
 * the mass memory never appears to go busy -- so the bootstrap can never
 * reach stage 3, and never loads anything.  The bit therefore has to fall
 * while the channel is working and rise again when it stops.
 *
 * The masks are the flight software's own: FCMBOOT holds FCMBBS18 EQU
 * X'2000' for MM1 and shifts left 12 before testing, giving 0x02000000
 * (IBM bit 6); FCMBBS19 EQU X'1000' likewise gives 0x01000000 (bit 7).
 * "DEFAULT TO BUS 18 (MMU1)" fixes the channels as BCE 18 and BCE 19.
 *
 * The stored bit is kept as "this mass memory is attached at all" -- the
 * emulator's default attaches MM1 and not MM2 -- so an absent mass memory
 * stays absent rather than being reported ready the moment its (idle,
 * nonexistent) channel is polled.
 */
#include <stdio.h>

#include "../src/cpu.h"
#include "../src/iop.h"

/* cpu.c references instr_decode() (normally cpu_instr.c) but nothing here
 * executes CPU instructions -- stub it out, matching the other IOP tests. */
const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v) {
    (void)hw1; (void)hw2; (void)v;
    return NULL;
}

#define MM1_READY 0x02000000u   /* IBM bit 6 */
#define MM2_READY 0x01000000u   /* IBM bit 7 */
#define MM1_IPL_SRC 0x08000000u /* IBM bit 4 */
#define MM1_BCE 18
#define MM2_BCE 19

static int failures = 0;

static void check(const char *label, uint32_t got, uint32_t want) {
    if (got != want) {
        printf("FAIL %s: got 0x%08x, want 0x%08x\n", label, got, want);
        failures++;
    }
}

/* A processor is RUNNING only when enabled (regHalt, which is the enable
 * direction) and busy (regBusyWait) -- so drive both. */
static void set_running(IOP *iop, int p, int running) {
    iop_proc_set(&iop->regHalt, p, (uint32_t)running);
    iop_proc_set(&iop->regBusyWait, p, (uint32_t)running);
}

static void setup(CPU *cpu, IOP *iop) {
    cpu_init(cpu);
    iop_init(iop, cpu);
}

/* Nothing running: the default configuration, reported unchanged. */
static void test_idle_reports_default(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    check("idle == default", iop_discrete_in_a(&iop), 0x0a000000u);
}

/* The stage-2 wait: MM1 READY must FALL while BCE 18 runs. */
static void test_mm1_ready_falls_while_busy(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    set_running(&iop, MM1_BCE, 1);
    check("MM1 ready clear while busy", iop_discrete_in_a(&iop) & MM1_READY, 0u);
    check("IPL-source bit untouched", iop_discrete_in_a(&iop) & MM1_IPL_SRC, MM1_IPL_SRC);
}

/* The full handshake FCMBOOT performs: ready, then busy, then ready again.
 * A constant bit passes the first and third and fails the second. */
static void test_handshake_round_trip(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    check("stage 1 ready", iop_discrete_in_a(&iop) & MM1_READY, MM1_READY);
    set_running(&iop, MM1_BCE, 1);
    check("stage 2 busy", iop_discrete_in_a(&iop) & MM1_READY, 0u);
    set_running(&iop, MM1_BCE, 0);
    check("stage 3 complete", iop_discrete_in_a(&iop) & MM1_READY, MM1_READY);
}

/* Enabled but not busy, and busy but not enabled, are both "not running":
 * the channel is idle, so the mass memory reports ready. */
static void test_half_states_are_idle(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    iop_proc_set(&iop.regHalt, MM1_BCE, 1);
    check("enabled, not busy", iop_discrete_in_a(&iop) & MM1_READY, MM1_READY);

    setup(&cpu, &iop);
    iop_proc_set(&iop.regBusyWait, MM1_BCE, 1);
    check("busy, not enabled", iop_discrete_in_a(&iop) & MM1_READY, MM1_READY);
}

/* MM2 is not attached in the default configuration, so its idle channel
 * must NOT be reported ready -- absence is not readiness. */
static void test_absent_mm2_never_ready(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    check("MM2 absent while idle", iop_discrete_in_a(&iop) & MM2_READY, 0u);
    set_running(&iop, MM2_BCE, 1);
    check("MM2 absent while busy", iop_discrete_in_a(&iop) & MM2_READY, 0u);
}

/* An attached MM2 does track its own channel, and independently of MM1 --
 * the two bits must not be wired to the same controller. */
static void test_attached_mm2_tracks_bce19(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    register_set32(&iop.regDiscreteInA, register_get32(&iop.regDiscreteInA) | MM2_READY);
    check("MM2 ready when idle", iop_discrete_in_a(&iop) & MM2_READY, MM2_READY);
    set_running(&iop, MM2_BCE, 1);
    check("MM2 clear when BCE19 busy", iop_discrete_in_a(&iop) & MM2_READY, 0u);
    check("MM1 unaffected by BCE19", iop_discrete_in_a(&iop) & MM1_READY, MM1_READY);
    set_running(&iop, MM2_BCE, 0);
    set_running(&iop, MM1_BCE, 1);
    check("MM2 unaffected by BCE18", iop_discrete_in_a(&iop) & MM2_READY, MM2_READY);
}

/* Discrete input B carries no computed bits and must be reported verbatim. */
static void test_discrete_b_unchanged(void) {
    CPU cpu; IOP iop;
    setup(&cpu, &iop);
    set_running(&iop, MM1_BCE, 1);
    check("B verbatim", register_get32(&iop.regDiscreteInB), 0x21000000u);
}

int main(void) {
    test_idle_reports_default();
    test_mm1_ready_falls_while_busy();
    test_handshake_round_trip();
    test_half_states_are_idle();
    test_absent_mm2_never_ready();
    test_attached_mm2_tracks_bce19();
    test_discrete_b_unchanged();
    if (failures) {
        printf("test_iop_discretes: %d failure(s)\n", failures);
        return 1;
    }
    printf("test_iop_discretes: all checks passed\n");
    return 0;
}
