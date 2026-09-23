/* ONE COMPUTER DRIVING SEVERAL DISPLAYS: the guard in iop.c's
 * MIA TRANSMITTER ENABLE/DISABLE case (ledger #159, and the plan's Phase C2).
 *
 * A GPC's emulation is serial -- one thread, one core -- so a computer that
 * ends up commanding every display bus delivers a fraction of real time, the
 * barrier paces the whole vehicle down to it, and MEDS2's wall-clock
 * watchdogs then fire against a vehicle that is healthy but slow.  What is
 * really an ordering mistake in a startup script (a display powered before
 * the NBAT names its commander, so whoever is already in RUN captures it)
 * reads instead as a sync defect, and rediscovering that cost the runs of
 * #158 before #159 settled it.  Nothing in the tree reported the state, so
 * it is now reported -- and this holds it reported.
 *
 * WHAT MOVED, AND WHY THIS TESTS THE HALF IT DOES.  The guard used to print
 * from iop.c the instant the count changed, and that was useless: GPCIPL
 * enables every transmitter for a moment during each IPL, so a five-computer
 * run produced eleven identical reports for EVERY machine -- and a uniform
 * result across every machine is the signature of a broken measurement.  The
 * recording stayed here; the judging moved to run.c, which can ask how long
 * the state has been HELD, and prints with the time so a line can be set
 * beside a vote.  This holds the recording honest: the count, and the moment
 * it was reached.
 */
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "../src/iop.h"
#include "../src/cpu.h"

extern bool yagpc_test_vehicle_multi;

static CPU cpu;
static IOP iop;
static MemoryBus bus;
static int failures;

#define MIA_XMIT_ENABLE  0x85040000u
#define MIA_XMIT_DISABLE 0x84040000u

/* The transmit-enable register is addressed by processor number, so the
 * data word for a set of display buses is built the same way the IOP reads
 * it back. */
static uint32_t dk_mask(const int *buses, int n) {
    Register r;
    register_init(&r);
    for (int i = 0; i < n; i++) iop_proc_set(&r, buses[i], 1);
    return register_get32(&r);
}

/* Run one command and return: the guard no longer prints from here. */
static void issue(uint32_t cmd, uint32_t data) {
    iop_recv_from_cpu(&iop, cmd, data);
}

static void check(bool ok, const char *what) {
    if (ok) return;
    failures++;
    printf("FAIL [dkbuses/%s]\n", what);
}

int main(void) {
    const int one[]   = { 6 };
    const int two[]   = { 6, 7 };
    const int three[] = { 6, 7, 8 };

    cpu_init(&cpu);
    bus = membus_create(&cpu.mainStorage);
    cpu.ram = &bus;
    cpu.gpcId = 1;
    iop_init(&iop, &cpu);
    cpu.iop = &iop;

    /* A SINGLE-COMPUTER VEHICLE RECORDS NOTHING, however many displays it
     * drives: that is the ordinary one-GPC configuration, not a defect. */
    yagpc_test_vehicle_multi = false;
    issue(MIA_XMIT_ENABLE, dk_mask(three, 3));
    check(iop.dkBusesCommanded == 0, "nothing recorded for a lone computer");

    issue(MIA_XMIT_DISABLE, dk_mask(three, 3));
    iop.dkBusesCommanded = 0;
    yagpc_test_vehicle_multi = true;

    /* The count follows the transmit-enable register. */
    issue(MIA_XMIT_ENABLE, dk_mask(one, 1));
    check(iop.dkBusesCommanded == 1, "one display bus counted");

    cpu.elapsedTimeUs = 1000.0;
    issue(MIA_XMIT_ENABLE, dk_mask(two, 2));
    check(iop.dkBusesCommanded == 2, "two display buses counted");
    check(iop.dkSinceUs == 1000.0, "the moment it reached two is remembered");

    /* AND THE MOMENT IS RE-STAMPED WHEN THE COUNT CHANGES, because the
     * question run.c asks is how long THIS state has been held. */
    cpu.elapsedTimeUs = 2000.0;
    issue(MIA_XMIT_ENABLE, dk_mask(three, 3));
    check(iop.dkBusesCommanded == 3, "three display buses counted");
    check(iop.dkSinceUs == 2000.0, "the moment is re-stamped on a change");

    /* Handing them back drops the count, which is what clears the report. */
    cpu.elapsedTimeUs = 3000.0;
    issue(MIA_XMIT_DISABLE, dk_mask(two, 2));
    check(iop.dkBusesCommanded == 1, "handing two back leaves one");

    if (failures == 0) {
        printf("7/7 display-bus guard checks passed\n");
        return 0;
    }
    printf("%d display-bus guard check(s) failed\n", failures);
    return 1;
}
