/* See vehicle.h. */
#include "vehicle.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"

#include "bcenet_transport.h"
#include "deumodel.h"
#include "mmumodel.h"
#include "discretes.h"
#include "mtumodel.h"
#include "iccmodel.h"

/* How far apart, in simulated microseconds, the machines are allowed to
 * drift.  Well inside FCOS's 3.85 ms sync timeout with room for the host's
 * scheduler, and coarse enough that the check costs nothing worth measuring.
 * YAGPC_BARRIER_US=0 turns the barrier off. */
#define BARRIER_DELTA_US 200.0

/* The longest a machine will wait on another's clock before deciding that
 * clock has stopped rather than merely fallen behind.  Far longer than any
 * legitimate hold -- a legitimate one is the delta divided by the rate. */
#define BARRIER_MAX_HOLD_SEC 0.25

void vehicle_init(Vehicle *v) {
    if (v == NULL) return;
    memset(v, 0, sizeof *v);
    for (int u = 0; u < 2; u++) v->mmuBus[u] = -1;
    v->barDeltaUs = BARRIER_DELTA_US;
    const char *e = getenv("YAGPC_BARRIER_US");
    if (e != NULL && *e != '\0') v->barDeltaUs = atof(e);
#ifdef HAVE_PTHREADS
    pthread_mutex_init(&v->barLock, NULL);
    for (int b = 0; b <= YAGPC_BUS_MAX; b++)
        pthread_mutex_init(&v->busLock[b], NULL);
#endif
}

static void barrier_lock(Vehicle *v) {
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->barLock);
#else
    (void)v;
#endif
}

static void barrier_unlock(Vehicle *v) {
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&v->barLock);
#else
    (void)v;
#endif
}

/* The slowest running machine's time in the shared frame, or this one's own
 * if it is alone -- which is what makes a single-computer run, and a vehicle
 * whose other computers are all in reset, cost one loop and no waiting. */
static double barrier_slowest(const Vehicle *v, int gpcId, double pub) {
    double slowest = pub;
    for (int m = 1; m <= 5; m++)
        if (m != gpcId && v->barActive[m] && v->barPubUs[m] < slowest)
            slowest = v->barPubUs[m];
    return slowest;
}

/* Bring a machine into the barrier at the group's pace.  A computer that has
 * been sitting in HALT has a clock minutes behind the others; it rejoins
 * level with the furthest advanced rather than dragging them back to it. */
static void barrier_join(Vehicle *v, int gpcId, double machineUs) {
    barrier_lock(v);
    double maxPub = 0.0;
    bool any = false;
    for (int m = 1; m <= 5; m++) {
        if (m == gpcId || !v->barActive[m]) continue;
        if (!any || v->barPubUs[m] > maxPub) { maxPub = v->barPubUs[m]; any = true; }
    }
    v->barOffsetUs[gpcId] = any ? (maxPub - machineUs) : 0.0;
    v->barPubUs[gpcId] = machineUs + v->barOffsetUs[gpcId];
    v->barActive[gpcId] = true;
    barrier_unlock(v);
}

void vehicle_dk_claim(Vehicle *v, int gpcId, bool claiming) {
    if (v == NULL || gpcId < 1 || gpcId > 5) return;
    if (claiming) {
        if (v->dkClaimant == gpcId) return;
        barrier_lock(v);
        if (v->dkClaimant != 0 && v->dkClaimant != gpcId) {
            v->dkDualClaims++;
            fprintf(stderr, "vehicle: GPC%d claims the display buses while "
                            "GPC%d still holds them -- dual commanders, which "
                            "USA005350 3.2.15.1 warns can fail a redundant "
                            "set to sync\n", gpcId, v->dkClaimant);
        }
        v->dkClaimant = gpcId;
        v->dkHandovers++;
        barrier_unlock(v);
        fprintf(stderr, "vehicle: GPC%d commands the display buses\n", gpcId);
    } else if (v->dkClaimant == gpcId) {
        barrier_lock(v);
        v->dkClaimant = 0;
        barrier_unlock(v);
        fprintf(stderr, "vehicle: GPC%d releases the display buses\n", gpcId);
    }
}

/* DK1.  The bootstrap's bus, and the only one a claim governs. */
#define YAGPC_DK_BOOTSTRAP_BUS 6

bool vehicle_dk_commands(const Vehicle *v, int gpcId, int staticOwner,
                         int busID) {
    if (v == NULL) return true;
    if (v->dkClaimant != 0 && busID == YAGPC_DK_BOOTSTRAP_BUS)
        return v->dkClaimant == gpcId;
    return staticOwner == 0 || staticOwner == gpcId;
}

void vehicle_bus_enter(Vehicle *v, int busID, int gpcId, bool inTransfer) {
    if (v == NULL || v->nMachines < 2 || busID < 1 || busID > YAGPC_BUS_MAX)
        return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->busLock[busID]);
#endif
    /* A HANDOFF IS ORDINARY; A HANDOFF MID-TRANSFER IS NOT.  Two computers
     * taking turns on an idle unit is just two computers taking turns.  A
     * second one arriving while the unit still owes the first its words has
     * overwritten a conversation, and neither computer is told. */
    if (gpcId >= 1 && gpcId <= 5) v->busCount[gpcId][busID]++;
    int prev = v->busOwner[busID];
    if (inTransfer && prev != 0 && prev != gpcId) v->busClash[busID]++;
    v->busOwner[busID] = gpcId;
}

void vehicle_bus_leave(Vehicle *v, int busID) {
    if (v == NULL || v->nMachines < 2 || busID < 1 || busID > YAGPC_BUS_MAX)
        return;
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&v->busLock[busID]);
#endif
}

void vehicle_barrier_leave(Vehicle *v, int gpcId) {
    if (v == NULL || gpcId < 1 || gpcId > 5 || !v->barActive[gpcId]) return;
    barrier_lock(v);
    v->barActive[gpcId] = false;
    barrier_unlock(v);
}

void vehicle_barrier_wait(Vehicle *v, int gpcId, double machineUs) {
    /* OFF unless there is somebody to wait for.  One computer is the case
     * every existing command line asks for, and it must not pay for this. */
    if (v == NULL || v->nMachines < 2 || v->barDeltaUs <= 0.0) return;
    if (gpcId < 1 || gpcId > 5) return;

    if (!v->barActive[gpcId]) barrier_join(v, gpcId, machineUs);

    double pub = machineUs + v->barOffsetUs[gpcId];
    v->barPubUs[gpcId] = pub;
    if (pub - barrier_slowest(v, gpcId, pub) <= v->barDeltaUs) return;

    /* AHEAD OF THE GROUP.  Wait for it, re-reading each pass: the machine
     * this one is waiting on may catch up, or may leave the barrier
     * altogether by being switched to HALT, and both release it.  The
     * sleep is short against the delta so the hold costs about what it
     * should and not a scheduler quantum more.  Nobody deadlocks: the
     * slowest machine never waits, and if every other machine leaves,
     * barrier_slowest() returns this machine's own time. */
    double t0 = yagpc_monotonic_seconds();
    v->barHolds++;
    while (pub - barrier_slowest(v, gpcId, pub) > v->barDeltaUs) {
        /* AND NEVER FOREVER.  Waiting on another machine's clock is only
         * safe while that clock is moving, and the ways it can stop are not
         * all ones this code gets told about -- a machine that has ended its
         * run, or is blocked on something of its own, is still marked
         * active until its thread tidies up.  The first version of this
         * loop had no way out and hung a two-computer run at shutdown: GPC1
         * stopped on SIGINT, GPC2 waited on its frozen clock, and the join
         * never returned.  Giving up after BARRIER_MAX_HOLD_SEC costs a
         * little accuracy in a situation that is already wrong, and the
         * count of them is reported. */
        if (yagpc_monotonic_seconds() - t0 > BARRIER_MAX_HOLD_SEC) {
            v->barAbandoned++;
            break;
        }
        yagpc_sleep_seconds(50e-6);
    }
    v->barHeldSec += yagpc_monotonic_seconds() - t0;
}

bool vehicle_multi(const Vehicle *v) { return v != NULL && v->nMachines > 1; }

/* ONE COMPUTER'S OUTPUT IS THE OTHERS' INPUT.  Its STBY/BFS RUN/RUN/SYNC
 * lines run to the other four, arriving at a bit that depends on who is
 * reading -- see discretes_rotate_out.  The three of them that form the sync
 * code are delivered together, because a half-applied code is a different
 * code with a different meaning. */
static void vehicle_route_out(void *ctx, int sourceGpc, uint32_t before,
                              uint32_t after) {
    Vehicle *v = (Vehicle *)ctx;
    uint32_t changed = before ^ after;
    if (v == NULL || changed == 0u) return;
    struct Discretes *from = (sourceGpc >= 1 && sourceGpc <= 5)
                                 ? v->lines[sourceGpc] : NULL;
    if (from == NULL) return;
    for (int m = 1; m <= 5; m++) {
        if (m == sourceGpc || v->lines[m] == NULL) continue;
        uint32_t set = discretes_rotate_out(sourceGpc, m, changed & after);
        uint32_t clr = discretes_rotate_out(sourceGpc, m, changed & ~after);
        /* IN PROCESS, DIRECTLY -- the sync lines have a 3.85 ms budget and the
         * socket cannot meet it (see discretes_apply_external).  The datagram
         * still goes out, because it is the only thing an external monitor
         * can see; it is no longer what the neighbour depends on. */
        if (set) {
            discretes_apply_external(v->lines[m], DISCRETES_REG_A, set, true);
            discretes_publish_to(from, m, DISCRETES_REG_A, set, true);
        }
        if (clr) {
            discretes_apply_external(v->lines[m], DISCRETES_REG_A, clr, false);
            discretes_publish_to(from, m, DISCRETES_REG_A, clr, false);
        }
    }
}

void vehicle_refresh_lines(Vehicle *v, int gpcId, uint32_t outValue) {
    if (v == NULL || v->nMachines < 2 || gpcId < 1 || gpcId > 5) return;
    for (int m = 1; m <= 5; m++) {
        if (m == gpcId || v->lines[m] == NULL) continue;
        /* The WHOLE code, set and clear together -- a half-applied code is a
         * different code, which is why this does not just re-send the set
         * bits.  No datagram: the wire carries changes for the monitors,
         * this is the level the neighbour must keep seeing. */
        uint32_t on = discretes_rotate_out(gpcId, m, outValue);
        uint32_t off = discretes_rotate_out(gpcId, m, ~outValue);
        if (on)  discretes_apply_external(v->lines[m], DISCRETES_REG_A, on, true);
        if (off) discretes_apply_external(v->lines[m], DISCRETES_REG_A, off, false);
    }
}

void vehicle_add_machine(Vehicle *v, int gpcId, struct Discretes *d) {
    if (v == NULL || d == NULL || gpcId < 1 || gpcId > 5) return;
    v->lines[gpcId] = d;
    discretes_set_out_hook(d, vehicle_route_out, v);
}

void vehicle_note_time(Vehicle *v, double machineUs) {
    /* Monotone, and deliberately unlocked: it is a double written by whichever
     * machine is furthest ahead and read by the device models, and the worst a
     * lost update can do is leave the tape a word time behind for one pass. */
    if (v != NULL && machineUs > v->clockUs) v->clockUs = machineUs;
}

void vehicle_free(Vehicle *v) {
    if (v == NULL) return;
    /* REPORT WHEN THE BARRIER BOUND.  Holding is how it works, not a sign of
     * trouble: a machine executes in bursts and then waits, so it reaches the
     * delta often, and measured over a 60 s two-computer run the holds cost
     * nothing -- simulated time came out 55.74 s with the barrier and 55.70 s
     * without.  What the numbers are for is the ABANDONED count, which means
     * a machine waited on a clock that had stopped, and the total, which is
     * worth comparing against the run if a vehicle ever does look slow. */
    if (getenv("YAGPC_BUSCENSUS") != NULL) {
        for (int b = 1; b <= YAGPC_BUS_MAX; b++) {
            unsigned long tot = 0;
            for (int g = 1; g <= 5; g++) tot += v->busCount[g][b];
            if (tot == 0) continue;
            fprintf(stderr, "vehicle: bus %2d transactions:", b);
            for (int g = 1; g <= 5; g++)
                if (v->busCount[g][b] > 0)
                    fprintf(stderr, "  GPC%d=%lu", g, v->busCount[g][b]);
            fprintf(stderr, "\n");
        }
    }
    if (v->barHolds > 0)
        fprintf(stderr, "vehicle: simulated-time barrier held %lu times, "
                        "%.3f s total, %lu abandoned (delta %.0f us)\n",
                v->barHolds, v->barHeldSec, v->barAbandoned, v->barDeltaUs);
    /* TWO COMPUTERS IN ONE CONVERSATION.  Not a condition to handle -- it
     * means the run asked two GPCs to use one unit at the same moment, which
     * the vehicle cannot do and a crew would not ask for. */
    for (int b = 0; b <= YAGPC_BUS_MAX; b++) {
        if (v->busClash[b] == 0) continue;
        fprintf(stderr, "vehicle: bus %d -- %lu command(s) from a second "
                        "computer while the device still owed words to the "
                        "first; they were sharing a unit that serves one at "
                        "a time\n", b, v->busClash[b]);
    }
#ifdef HAVE_PTHREADS
    pthread_mutex_destroy(&v->barLock);
    for (int b = 0; b <= YAGPC_BUS_MAX; b++)
        pthread_mutex_destroy(&v->busLock[b]);
#endif
    /* The models report on the way out, as they did when the BatchRunner
     * owned them -- the reports are of the vehicle's devices, not of any one
     * computer, and with several machines only one set should be printed. */
    for (int u = 0; u < 2; u++) {
        if (v->mmu[u] == NULL) continue;
        mmumodel_report(v->mmu[u]);
        mmumodel_free(v->mmu[u]);
        v->mmu[u] = NULL;
    }
    if (v->deu != NULL) {
        deumodel_report(v->deu);
        deumodel_free(v->deu);
        v->deu = NULL;
    }
    for (int d = 0; d < v->nDeuExtra; d++) {
        if (v->deuExtra[d] == NULL) continue;
        fprintf(stderr, "deu%d (bus %d): ", d + 2, v->deuExtraBus[d]);
        deumodel_report(v->deuExtra[d]);
        deumodel_free(v->deuExtra[d]);
        v->deuExtra[d] = NULL;
    }
    v->nDeuExtra = 0;
    if (v->icc != NULL) {
        iccmodel_report(v->icc);
        iccmodel_free(v->icc);
        v->icc = NULL;
    }
    if (v->mtu != NULL) {
        mtumodel_report(v->mtu);
        mtumodel_free(v->mtu);
        v->mtu = NULL;
    }
    /* After the models: the transmit thread sends on the transport's own
     * sockets and would otherwise be doing so as they went. */
    if (v->transport != NULL) {
        bcenet_transport_free(v->transport);
        v->transport = NULL;
    }
    v->built = false;
}
