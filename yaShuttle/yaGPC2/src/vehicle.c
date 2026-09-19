/* See vehicle.h. */
#include "vehicle.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "compat.h"

#include "bcenet_transport.h"
#include "deumodel.h"
#include "mmumodel.h"
#include "discretes.h"
#include "mtumodel.h"
#include "iccmodel.h"

#include "envcache.h"
/* How far apart, in simulated microseconds, the machines are allowed to
 * drift.  Well inside FCOS's 3.85 ms sync timeout with room for the host's
 * scheduler, and coarse enough that the check costs nothing worth measuring.
 * YAGPC_BARRIER_US=0 turns the barrier off. */
#define BARRIER_DELTA_US 200.0

/* The longest a machine will wait on another's clock before deciding that
 * clock has stopped rather than merely fallen behind.  Far longer than any
 * legitimate hold -- a legitimate one is the delta divided by the rate. */
#define BARRIER_MAX_HOLD_SEC 0.25
/* Wall time a held machine re-checks before it sleeps, and the longest it
 * sleeps before re-checking without being woken -- a safety net only. */
#define BARRIER_SPIN_US 200.0
#define BARRIER_SLEEP_SEC 0.002

void vehicle_init(Vehicle *v) {
    if (v == NULL) return;
    memset(v, 0, sizeof *v);
    for (int u = 0; u < 2; u++) v->mmuBus[u] = -1;
    v->barDeltaUs = BARRIER_DELTA_US;
    const char *e = yagpc_getenv("YAGPC_BARRIER_US");
    if (e != NULL && *e != '\0') v->barDeltaUs = atof(e);
    v->barSpinUs = BARRIER_SPIN_US;
    const char *sp = yagpc_getenv("YAGPC_BARRIER_SPIN_US");
    if (sp != NULL && *sp != '\0') v->barSpinUs = atof(sp);
    v->barWakeAtUs = 1e300;
#ifdef HAVE_PTHREADS
    pthread_mutex_init(&v->barLock, NULL);
    pthread_cond_init(&v->barCond, NULL);
    pthread_mutex_init(&v->pauseLock, NULL);
    pthread_cond_init(&v->pauseCond, NULL);
    for (int b = 0; b <= YAGPC_BUS_MAX; b++)
        pthread_mutex_init(&v->busLock[b], NULL);
#endif
}

/* Defined below vehicle_barrier_leave's first use; see its comment. */
static void barrier_wake(Vehicle *v);

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
    /* The offset is what turns a machine's OWN time -- the t= on every
     * WATCHHW and RT line -- into shared time, the t= on SYNCORDER.  Without
     * it a window chosen on one clock lands in the wrong place on the other,
     * which is exactly how an AIESIP probe came to look after the event it
     * was aimed at. */
    if (yagpc_getenv("YAGPC_SYNCORDER") != NULL)
        fprintf(stderr, "SYNCORDER-JOIN gpc=%d own=%.1f shared=%.1f offset_us=%.1f\n",
                gpcId, machineUs, v->barPubUs[gpcId], v->barOffsetUs[gpcId]);
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
    if (v == NULL || !vehicle_multi(v) || busID < 1 || busID > YAGPC_BUS_MAX)
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
    if (v == NULL || !vehicle_multi(v) || busID < 1 || busID > YAGPC_BUS_MAX)
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
    /* Whoever was waiting on this machine is waiting on nothing now. */
    barrier_wake(v);
}

/* Release every machine asleep in the barrier so each re-evaluates.  Called
 * by a machine whose clock has reached the earliest sleeper's release time,
 * and by one leaving the barrier -- either can end a hold. */
static void barrier_wake(Vehicle *v) {
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->barLock);
    v->barWakeAtUs = 1e300;
    pthread_cond_broadcast(&v->barCond);
    pthread_mutex_unlock(&v->barLock);
#else
    (void)v;
#endif
}

void vehicle_barrier_wait(Vehicle *v, int gpcId, double machineUs) {
    /* OFF unless there is somebody to wait for.  One computer is the case
     * every existing command line asks for, and it must not pay for this. */
    if (v == NULL || !vehicle_multi(v) || v->barDeltaUs <= 0.0) return;
    if (gpcId < 1 || gpcId > 5) return;

    if (!v->barActive[gpcId]) barrier_join(v, gpcId, machineUs);

    double pub = machineUs + v->barOffsetUs[gpcId];
    v->barPubUs[gpcId] = pub;

    /* WAKE ANYONE THIS MACHINE'S PROGRESS HAS RELEASED.  The ORDER matters:
     * the time is published above BEFORE the sleepers are looked at here,
     * and a sleeper registers itself BEFORE its final re-check below.  So
     * either this sees the sleeper and wakes it, or the sleeper's re-check
     * sees this time and never sleeps; neither can miss the other.  The
     * reads are unlocked, which at worst costs one BARRIER_SLEEP_SEC. */
    if (v->barWaiters > 0 && pub >= v->barWakeAtUs) barrier_wake(v);

    if (pub - barrier_slowest(v, gpcId, pub) <= v->barDeltaUs) return;

    /* AHEAD OF THE GROUP.  Nobody deadlocks: the slowest machine never
     * waits, and if every other machine leaves, barrier_slowest() returns
     * this machine's own time. */
    double t0 = yagpc_monotonic_seconds();
    v->barHolds++;

    /* 1. RE-CHECK WITHOUT SLEEPING, briefly.  A hold normally ends within
     * a few tens of microseconds -- the partner has only to run 25-200 us of
     * simulated time -- and any OS sleep is rounded up past that. */
    if (v->barSpinUs > 0.0) {
        double until = t0 + v->barSpinUs * 1e-6;
        for (unsigned i = 0;; i++) {
            if (pub - barrier_slowest(v, gpcId, pub) <= v->barDeltaUs) {
                v->barSpinReleases++;
                v->barHeldSec += yagpc_monotonic_seconds() - t0;
                return;
            }
            if ((i & 63u) == 63u && yagpc_monotonic_seconds() >= until) break;
        }
    }

#ifdef HAVE_PTHREADS
    /* 2. SLEEP UNTIL WOKEN BY PROGRESS. */
    pthread_mutex_lock(&v->barLock);
    v->barWaiters++;
    for (;;) {
        double need = pub - v->barDeltaUs;
        if (need < v->barWakeAtUs) v->barWakeAtUs = need;
        if (pub - barrier_slowest(v, gpcId, pub) <= v->barDeltaUs) break;
        /* AND NEVER FOREVER.  Waiting on another machine's clock is only
         * safe while that clock is moving, and a machine that has ended its
         * run is still marked active until its thread tidies up -- the first
         * version of this loop had no way out and hung a two-computer run at
         * shutdown.  The count of these is reported. */
        if (yagpc_monotonic_seconds() - t0 > BARRIER_MAX_HOLD_SEC) {
            v->barAbandoned++;
            break;
        }
        v->barSleeps++;
        struct timespec ts;
        clock_gettime(CLOCK_REALTIME, &ts);
        long ns = ts.tv_nsec + (long)(BARRIER_SLEEP_SEC * 1e9);
        ts.tv_sec += ns / 1000000000L;
        ts.tv_nsec = ns % 1000000000L;
        pthread_cond_timedwait(&v->barCond, &v->barLock, &ts);
    }
    v->barWaiters--;
    pthread_mutex_unlock(&v->barLock);
#else
    while (pub - barrier_slowest(v, gpcId, pub) > v->barDeltaUs) {
        if (yagpc_monotonic_seconds() - t0 > BARRIER_MAX_HOLD_SEC) {
            v->barAbandoned++;
            break;
        }
        yagpc_sleep_seconds(50e-6);
    }
#endif
    v->barHeldSec += yagpc_monotonic_seconds() - t0;
}


/* ---- the stop-the-world -------------------------------------------------
 *
 * See the pause fields in vehicle.h for why this is not the barrier.
 */

/* The longest the vehicle will wait for a machine to reach its next pause
 * check before abandoning the snapshot.  See vehicle.h: wall time, sized at
 * about ten times the worst legitimate case (a 200 ms display peer hold). */
#define PAUSE_MAX_WAIT_SEC 2.0
/* How often a parked machine re-checks if nobody wakes it.  A safety net:
 * every release broadcasts. */
#define PAUSE_SLEEP_SEC 0.002

void vehicle_join_pause_group(Vehicle *v, int gpcId) {
    if (v == NULL || gpcId < 1 || gpcId > 5) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->pauseLock);
    if (!v->pauseMember[gpcId]) { v->pauseMember[gpcId] = true; v->pauseGroup++; }
    pthread_mutex_unlock(&v->pauseLock);
#else
    if (!v->pauseMember[gpcId]) { v->pauseMember[gpcId] = true; v->pauseGroup++; }
#endif
}

void vehicle_leave_pause_group(Vehicle *v, int gpcId) {
    if (v == NULL || gpcId < 1 || gpcId > 5) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->pauseLock);
    if (v->pauseMember[gpcId]) { v->pauseMember[gpcId] = false; v->pauseGroup--; }
    /* A machine that has ended its run must not be waited for.  Whoever is
     * parked re-tests the count against the new, smaller group. */
    pthread_cond_broadcast(&v->pauseCond);
    pthread_mutex_unlock(&v->pauseLock);
#else
    if (v->pauseMember[gpcId]) { v->pauseMember[gpcId] = false; v->pauseGroup--; }
#endif
}

void vehicle_bootstrap_enter(Vehicle *v) {
    if (v == NULL) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->pauseLock);
    v->bootstrapping++;
    pthread_mutex_unlock(&v->pauseLock);
#else
    v->bootstrapping++;
#endif
}

void vehicle_bootstrap_leave(Vehicle *v) {
    if (v == NULL) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->pauseLock);
    if (v->bootstrapping > 0) v->bootstrapping--;
    pthread_mutex_unlock(&v->pauseLock);
#else
    if (v->bootstrapping > 0) v->bootstrapping--;
#endif
}

/* False means the request was REFUSED and nothing will be written. */
bool vehicle_pause_request(Vehicle *v, const char *tag) {
    if (v == NULL) return false;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&v->pauseLock);
#endif
    /* FIRST REQUEST WINS.  Two machines can reach a trigger in the same
     * instant -- the same landmark, or two YAGPC_DUMPSTATE_AT times a
     * microsecond apart -- and the second must not rename the capture the
     * first is already parking for. */
    bool ok = true;
    if (v->bootstrapping > 0) {
        /* Refused, not deferred: whoever asked is waiting for files, and a
         * silent wait that ends in a timeout tells them nothing about why. */
        fprintf(stderr, "vehicle: snapshot REFUSED -- %d computer(s) are "
                        "reading the bootstrap off the tape, and a machine "
                        "caught there cannot be restored (the transfer's own "
                        "buffer is not part of any capture).  Try again once "
                        "the IPL is done.\n", v->bootstrapping);
        ok = false;
    } else if (!v->pauseRequest) {
        snprintf(v->pauseTag, sizeof v->pauseTag, "%s", tag ? tag : "");
        v->pauseRequest = 1;
    }
#ifdef HAVE_PTHREADS
    pthread_cond_broadcast(&v->pauseCond);
    pthread_mutex_unlock(&v->pauseLock);
#endif
    return ok;
}

/* Read while parked, so no lock: every member is stopped and the tag was
 * written before the first of them arrived. */
const char *vehicle_pause_tag(const Vehicle *v) {
    return (v == NULL) ? "" : v->pauseTag;
}

#ifdef HAVE_PTHREADS
/* One half of the rendezvous: the last member through resets the counter and
 * bumps the generation, which is what releases the rest.  The generation --
 * rather than the counter -- is the release condition, so the reset cannot
 * strand a member that had not yet woken.  False means the deadline passed;
 * the caller then abandons rather than waiting further.
 *
 * Called with pauseLock held. */
static bool pause_rendezvous(Vehicle *v, int *count, unsigned *gen, double t0) {
    unsigned mine = *gen;
    if (++*count >= v->pauseGroup) {
        *count = 0;
        (*gen)++;
        pthread_cond_broadcast(&v->pauseCond);
        return true;
    }
    while (*gen == mine) {
        if (yagpc_monotonic_seconds() - t0 > PAUSE_MAX_WAIT_SEC) {
            /* Undo this member's arrival so the NEXT request starts from a
             * clean count -- an abandoned save must not poison the one after
             * it. */
            if (*count > 0) (*count)--;
            return false;
        }
        struct timespec ts;
        clock_gettime(CLOCK_REALTIME, &ts);
        long ns = ts.tv_nsec + (long)(PAUSE_SLEEP_SEC * 1e9);
        ts.tv_sec += ns / 1000000000L;
        ts.tv_nsec = ns % 1000000000L;
        pthread_cond_timedwait(&v->pauseCond, &v->pauseLock, &ts);
    }
    return true;
}
#endif

bool vehicle_pause_enter(Vehicle *v, int gpcId) {
    /* THE HOT PATH, and the only cost when no snapshot is pending: one
     * relaxed load.  Everything below happens at most once per save. */
    if (v == NULL || !v->pauseRequest) return false;
    if (gpcId < 1 || gpcId > 5 || !v->pauseMember[gpcId]) return false;
#ifdef HAVE_PTHREADS
    double t0 = yagpc_monotonic_seconds();
    pthread_mutex_lock(&v->pauseLock);
    bool ok = pause_rendezvous(v, &v->pauseArrived, &v->pauseArriveGen, t0);
    if (!ok) {
        v->pauseAbandoned++;
        /* Clear the request so the machines that DID arrive are not left
         * parking again immediately on a request nobody can satisfy. */
        v->pauseRequest = 0;
        pthread_cond_broadcast(&v->pauseCond);
        fprintf(stderr, "vehicle: snapshot ABANDONED -- GPC%d waited %.1f s "
                        "for %d machine(s) and one never arrived; nothing was "
                        "written\n", gpcId, PAUSE_MAX_WAIT_SEC, v->pauseGroup);
    }
    pthread_mutex_unlock(&v->pauseLock);
    return ok;
#else
    /* Without threads there is one machine, and it is already stopped. */
    return true;
#endif
}

void vehicle_pause_exit(Vehicle *v, int gpcId) {
    if (v == NULL || gpcId < 1 || gpcId > 5) return;
#ifdef HAVE_PTHREADS
    double t0 = yagpc_monotonic_seconds();
    pthread_mutex_lock(&v->pauseLock);
    if (pause_rendezvous(v, &v->pauseFinished, &v->pauseFinishGen, t0)) {
        /* Everyone has written.  Clearing the request here, inside the
         * lock and after the second rendezvous, is what stops a machine
         * that resumes early from parking again on the same request. */
        if (v->pauseRequest) { v->pauseTaken++; v->pauseRequest = 0; }
    } else {
        v->pauseAbandoned++;
        v->pauseRequest = 0;
    }
    pthread_cond_broadcast(&v->pauseCond);
    pthread_mutex_unlock(&v->pauseLock);
#else
    v->pauseRequest = 0;
    v->pauseTaken++;
#endif
}

bool vehicle_multi(const Vehicle *v) {
    if (v == NULL) return false;
    /* nExpected is right from the start; nMachines only once everybody has
     * been built.  Either one being above 1 settles it. */
    return v->nExpected > 1 || v->nMachines > 1;
}

void vehicle_expect_machines(Vehicle *v, int n) {
    if (v != NULL) v->nExpected = n;
}

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
    /* YAGPC_SYNCORDER: every change of a computer's 3-bit sync code, stamped
     * with that computer's time IN THE SHARED FRAME -- the barrier's
     * barPubUs, which is the only clock on which two machines' instants can
     * be compared.  YAGPC_SYNCTRACE stamps wall time from two threads, and
     * each machine's own elapsedTimeUs counts from its own start; lining
     * those up by assuming two events were simultaneous is circular, and the
     * question this answers is exactly WHICH came first.
     *
     * This runs on the source machine's own thread at the instant its
     * output register changes, and barPubUs[sourceGpc] is refreshed once
     * per instruction, so the stamp is good to one instruction.  Only the
     * source writes lastCode[sourceGpc], so it needs no lock. */
    {
        static int soInit = 0, soOn = 0;
        static int lastCode[6] = {-1, -1, -1, -1, -1, -1};
        if (!soInit) { soInit = 1; soOn = yagpc_getenv("YAGPC_SYNCORDER") != NULL; }
        if (soOn && v->barDeltaUs > 0.0) {
            /* Bits 20/24/28 (MSB = bit 0) are A/B/C. */
            int code = ((after & 0x800u) ? 4 : 0) | ((after & 0x080u) ? 2 : 0) |
                       ((after & 0x008u) ? 1 : 0);
            if (code != lastCode[sourceGpc]) {
                lastCode[sourceGpc] = code;
                /* EVERY active machine's shared-frame clock at this instant,
                 * not just the source's.  The code reaches the neighbours at
                 * once in WALL time, but a neighbour may be up to the barrier
                 * delta ahead of or behind the source in SIMULATED time -- so
                 * what a reader sees depends on who is behind, and that skew
                 * at the handshake that fails is the thing to measure. */
                char pubs[96]; int n = 0; pubs[0] = '\0';
                for (int m = 1; m <= 5 && n < (int)sizeof pubs - 24; m++)
                    if (v->barActive[m])
                        n += snprintf(pubs + n, sizeof pubs - (size_t)n,
                                      " pub%d=%.1f", m, v->barPubUs[m]);
                fprintf(stderr, "SYNCORDER gpc=%d code=%d%d%d tshared=%.1f%s\n",
                        sourceGpc, (code >> 2) & 1, (code >> 1) & 1, code & 1,
                        v->barPubUs[sourceGpc], pubs);
            }
        }
    }
    for (int m = 1; m <= 5; m++) {
        if (m == sourceGpc || v->lines[m] == NULL) continue;
        uint32_t set = discretes_rotate_out(sourceGpc, m, changed & after);
        uint32_t clr = discretes_rotate_out(sourceGpc, m, changed & ~after);
        /* IN PROCESS, DIRECTLY -- the sync lines have a 3.85 ms budget and the
         * socket cannot meet it (see discretes_apply_external).  The datagram
         * still goes out, because it is the only thing an external monitor
         * can see; it is no longer what the neighbour depends on. */
        /* Both halves of the code in ONE indivisible step -- see
         * discretes_apply_external_pair.  The datagrams follow, separately,
         * because they are only for monitors. */
        discretes_apply_external_pair(v->lines[m], DISCRETES_REG_A, set, clr);
        if (set) discretes_publish_to(from, m, DISCRETES_REG_A, set, true);
        if (clr) discretes_publish_to(from, m, DISCRETES_REG_A, clr, false);
    }
}

void vehicle_refresh_lines(Vehicle *v, int gpcId, uint32_t outValue) {
    if (v == NULL || !vehicle_multi(v) || gpcId < 1 || gpcId > 5) return;
    for (int m = 1; m <= 5; m++) {
        if (m == gpcId || v->lines[m] == NULL) continue;
        /* The WHOLE code, set and clear together -- a half-applied code is a
         * different code, which is why this does not just re-send the set
         * bits.  No datagram: the wire carries changes for the monitors,
         * this is the level the neighbour must keep seeing. */
        uint32_t on = discretes_rotate_out(gpcId, m, outValue);
        uint32_t off = discretes_rotate_out(gpcId, m, ~outValue);
        discretes_apply_external_pair(v->lines[m], DISCRETES_REG_A, on, off);
    }
}

/* A computer m's fail discrete 0x10 >> k votes against the computer k places
 * along, k = 1..4 (see DISCRETES_REG_FAILVOTE); 0x10 inhibits all four.
 * Read without a lock from other machines' threads: a value at most one
 * publish old, which is all a lamp needs. */
int vehicle_votes_against(const Vehicle *v, int gpcId) {
    if (v == NULL || gpcId < 1 || gpcId > 5) return 0;
    int votes = 0;
    for (int m = 1; m <= 5; m++) {
        if (m == gpcId || v->lines[m] == NULL) continue;
        uint32_t fd = discretes_value(v->lines[m], DISCRETES_REG_FAILVOTE);
        if (fd & 0x10u) continue;
        int k = ((gpcId - m) % 5 + 5) % 5;
        if (fd & (0x10u >> k)) votes++;
    }
    return votes;
}

void vehicle_add_machine(Vehicle *v, int gpcId, struct Discretes *d) {
    if (v == NULL || d == NULL || gpcId < 1 || gpcId > 5) return;
    v->lines[gpcId] = d;
    discretes_set_out_hook(d, vehicle_route_out, v);
    /* EVERY machine's in-process lines, again: the one joining now is a new
     * neighbour for each of the others.  What vehicle_route_out writes into
     * reader m is exactly discretes_rotate_out(s, m, ...) of source s's
     * outputs, so the union over the other machines here is the set of m's
     * input bits whose datagrams are only late copies. */
    for (int m = 1; m <= 5; m++) {
        if (v->lines[m] == NULL) continue;
        uint32_t wired = 0u;
        for (int s = 1; s <= 5; s++)
            if (s != m && v->lines[s] != NULL)
                wired |= discretes_rotate_out(s, m, 0xffffffffu);
        discretes_set_local_wired(v->lines[m], DISCRETES_REG_A, wired);
    }
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
    if (yagpc_getenv("YAGPC_BUSCENSUS") != NULL) {
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
                        "%.3f s total, %lu abandoned (delta %.0f us); "
                        "%lu released while spinning, %lu sleeps\n",
                v->barHolds, v->barHeldSec, v->barAbandoned, v->barDeltaUs,
                v->barSpinReleases, v->barSleeps);
    /* REPORTED EVEN WHEN ZERO IF ANY WAS ASKED FOR, because "abandoned" is
     * the answer that matters and a silent absence reads like success. */
    if (v->pauseTaken > 0 || v->pauseAbandoned > 0)
        fprintf(stderr, "vehicle: stop-the-world -- %lu snapshot(s) taken with "
                        "every machine parked, %lu abandoned\n",
                v->pauseTaken, v->pauseAbandoned);
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
    pthread_cond_destroy(&v->barCond);
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

/* ---------------------------------------------------------------------
 * THE VEHICLE'S DEVICES IN A CAPTURE -- see vehicle.h.
 * ------------------------------------------------------------------- */

/* ONE WRITER, NAMED BY RULE RATHER THAN BY RACE.  Every machine reaches the
 * rendezvous and writes its own pair; the devices belong to the vehicle and
 * must be written exactly once, so the lowest-numbered machine present does
 * it.  A rule beats "whoever gets there first" because it is the same
 * machine every time, which is what makes two captures comparable. */
bool vehicle_capture_writer(const Vehicle *v, int gpcId) {
    if (v == NULL) return false;
    for (int m = 1; m < gpcId; m++)
        if (v->lines[m] != NULL) return false;
    return v->lines[gpcId] != NULL || gpcId == 1;
}

void vehicle_dump_devices(const Vehicle *v, const char *dir) {
    if (v == NULL || dir == NULL) return;
    char path[512];
    if (v->icc != NULL) {
        snprintf(path, sizeof path, "%s/icc.json", dir);
        unsigned present = 0u;
        for (int m = 1; m <= 5; m++)
            if (v->lines[m] != NULL) present |= 1u << m;
        if (iccmodel_dump(v->icc, path, v->clockUs, present))
            fprintf(stderr, "vehicle: intercomputer bus captured\n");
    }
    /* AND EACH MASS MEMORY: where its head is, and every block the flight
     * software wrote -- which exist nowhere else, the .mmv being read only
     * (mmumodel.h). */
    for (int u = 0; u < 2; u++)
        if (v->mmu[u] != NULL) mmumodel_dump(v->mmu[u], dir, v->clockUs);
    if (v->mtu != NULL) {
        snprintf(path, sizeof path, "%s/mtu.json", dir);
        mtumodel_dump(v->mtu, path);
    }
}

void vehicle_load_devices(Vehicle *v, const char *dir) {
    if (v == NULL || dir == NULL) return;
    char path[512];
    if (v->icc != NULL) {
        snprintf(path, sizeof path, "%s/icc.json", dir);
        FILE *probe = fopen(path, "rb");
        if (probe == NULL) {
            /* NOT FATAL, AND SAID OUT LOUD.  Captures taken before the
             * devices were part of one have no such file; they restore as
             * they always did, and the difference is not silent. */
            fprintf(stderr, "vehicle: no icc.json in this capture -- the "
                            "intercomputer bus starts empty, as it did "
                            "before captures carried it\n");
            return;
        }
        fclose(probe);
        if (iccmodel_load(v->icc, path, v->clockUs))
            fprintf(stderr, "vehicle: intercomputer bus restored\n");
    }
}

/* The mass memories are made later than the ICC -- they need their volumes
 * -- so they are restored on their own, from the same directory. */
void vehicle_load_mmu(Vehicle *v, const char *dir) {
    if (v == NULL || dir == NULL) return;
    /* ONCE FOR THE VEHICLE, not once per machine.  Every machine's set-up
     * runs before veh->built is set, so a !built test let the second
     * computer load the units again over the first's copy. */
    if (v->devicesLoaded) return;
    v->devicesLoaded = true;
    char path[512];
    for (int u = 0; u < 2; u++)
        if (v->mmu[u] != NULL) mmumodel_load(v->mmu[u], dir, v->clockUs);
    if (v->mtu != NULL) {
        snprintf(path, sizeof path, "%s/mtu.json", dir);
        mtumodel_load(v->mtu, path);
    }
}
