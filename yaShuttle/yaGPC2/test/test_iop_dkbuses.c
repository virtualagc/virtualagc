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
 * WHY A UNIT TEST RATHER THAN A RUN.  Provoking the real thing means a
 * deliberately mis-ordered four-GPC IPL, minutes of wall clock, and a
 * vehicle; and a run that comes back quiet cannot distinguish "the guard is
 * silent because the vehicle is healthy" from "the guard never fires".  The
 * warning is a pure function of the transmit-enable register, so it can be
 * driven directly.
 *
 * The guard applies only to a MULTI-GPC vehicle, since one computer
 * commanding two displays is correct when it is the only computer there.  A
 * test IOP has no vehicle at all, so vehicle_stub.c's yagpc_test_vehicle_multi
 * stands in for that decision. */
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

/* Run one command with stderr captured, and say whether `want` appears. */
static bool says(const char *path, uint32_t cmd, uint32_t data,
                 const char *want) {
    fflush(stderr);
    FILE *f = freopen(path, "w", stderr);
    if (f == NULL) return false;
    iop_recv_from_cpu(&iop, cmd, data);
    fflush(stderr);

    char buf[8192];
    size_t n = 0;
    FILE *r = fopen(path, "r");
    if (r != NULL) {
        n = fread(buf, 1, sizeof buf - 1, r);
        fclose(r);
    }
    buf[n] = '\0';
    /* Put stderr back on the terminal so failures can be seen. */
    f = freopen("/dev/stderr", "w", stderr);
    (void)f;
    return strstr(buf, want) != NULL;
}

static void check(bool ok, const char *what) {
    if (ok) return;
    failures++;
    printf("FAIL [dkbuses/%s]\n", what);
}

int main(void) {
    const char *tmp = "/tmp/yagpc2-dkbuses-stderr.txt";
    const int one[]   = { 6 };
    const int two[]   = { 6, 7 };
    const int three[] = { 6, 7, 8 };

    cpu_init(&cpu);
    bus = membus_create(&cpu.mainStorage);
    cpu.ram = &bus;
    cpu.gpcId = 1;
    iop_init(&iop, &cpu);
    cpu.iop = &iop;

    /* A SINGLE-COMPUTER VEHICLE SAYS NOTHING, however many displays it
     * drives -- that is the normal one-GPC configuration, not a defect. */
    yagpc_test_vehicle_multi = false;
    check(!says(tmp, MIA_XMIT_ENABLE, dk_mask(three, 3), "display buses"),
          "silent when the vehicle is one computer");

    /* Clear it again before the real case. */
    iop_recv_from_cpu(&iop, MIA_XMIT_DISABLE, dk_mask(three, 3));
    iop.dkBusesCommanded = 0;

    yagpc_test_vehicle_multi = true;

    /* One display bus in a multi-GPC vehicle is the healthy state. */
    check(!says(tmp, MIA_XMIT_ENABLE, dk_mask(one, 1), "display buses"),
          "silent on one display bus");

    /* Two is the state that costs the rate, and it must name the computer
     * and the count. */
    check(says(tmp, MIA_XMIT_ENABLE, dk_mask(two, 2),
               "GPC1 transmits on 2 display buses"),
          "reports two display buses");

    /* Three: the count changed, so it says so again rather than falling
     * silent after the first report. */
    check(says(tmp, MIA_XMIT_ENABLE, dk_mask(three, 3),
               "GPC1 transmits on 3 display buses"),
          "reports the count changing");

    /* Handing two of them over is the recovery, and is worth a line of its
     * own -- when it stops is as interesting as when it starts. */
    check(says(tmp, MIA_XMIT_DISABLE, dk_mask(two, 2),
               "GPC1 now transmits on 1 display bus"),
          "reports the recovery");

    /* And once recovered it is quiet again. */
    check(!says(tmp, MIA_XMIT_DISABLE, dk_mask(one, 1), "display bus"),
          "silent after recovering");

    remove(tmp);

    if (failures == 0) {
        printf("6/6 display-bus guard checks passed\n");
        return 0;
    }
    printf("%d display-bus guard check(s) failed\n", failures);
    return 1;
}
