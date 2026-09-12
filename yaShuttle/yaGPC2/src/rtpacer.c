/* See rtpacer.h. */
#include "rtpacer.h"

#include "compat.h"
#include "cpu.h"

#include <stdio.h>
#include <stdlib.h>

/* The most simulated time one rtpacer_advance_idle step will carry the
 * wait state forward by.
 *
 * The wait state is paced by converting elapsed wall time into simulated
 * time, so whatever the host was doing instead of calling us comes back
 * as a lump advanced in a single call, with nothing servicing sockets
 * inside it.  A receive time out is measured in the simulated time that
 * lump just burned: an 85 ms refresh at factor 0.35 would land 30 ms of
 * simulated time at once, past the 20 ms floor a bus receive gets, so a
 * reply already at the socket would arrive to a transaction that had
 * been error-terminated.  Capping the lump is what keeps the two clocks
 * inside each other's tolerance.
 *
 * The cap no longer DROPS the remainder (it did, and that was one of the
 * ways the simulated clock lost time permanently): what is left over is
 * still owed and the next pass still sees it.  So the cap now only decides
 * how finely a deficit is repaid, and it stays well inside a bus receive
 * timeout -- the wait loop skips its sleep while behind, so successive
 * passes come back-to-back and 5 ms apiece is repaid quickly. */
#define IDLE_CATCHUP_MAX_NS 5000000.0   /* 5 ms of simulated time per pass */

/* WHEN A REBASE IS LEGITIMATE.
 *
 * Re-basing says: the machine was STOPPED, the world moved on, carry on
 * from here.  It is right for a host stall that has nothing to do with
 * the simulated machine -- a debugger breakpoint, a long single-step --
 * because repaying that as simulated time is actively harmful when a real
 * peripheral is on the other end of a UDP socket.  Datagrams the
 * peripheral sent while we were stopped are already gone (UDP has no
 * retransmission, and a receive buffer that fills drops what arrives
 * next), so the reply those milliseconds were owed to no longer exists.
 * Racing the simulated clock forward through them only runs every
 * outstanding transaction past its receive time out.
 *
 * rtpacer_resync() is the only caller that describes that situation.
 *
 * It is NOT right for merely running behind, and it used to be applied
 * there too -- on every wake from a wait state, on any deficit past 250 ms
 * while executing, and on a slow peer.  Those write-offs were the whole of
 * a measured 21% loss: 2858 rebases discarding 40.6 s of a 183 s run, on a
 * host using 15% of one core.  Behind is not stopped; behind is repaid. */

void rtpacer_init(RTPacer *p, struct CPU *cpu, double factor, double idleTimeoutMs) {
    p->cpu = cpu;
    p->factor = factor;
    p->idleTimeoutMs = idleTimeoutMs;
    p->wallStartSeconds = yagpc_monotonic_seconds();
    p->simStartUs = cpu->elapsedTimeUs;
    p->wallBirthSeconds = p->wallStartSeconds;
    p->idleStartWallSeconds = p->wallStartSeconds;
    p->idleStartSimUs = p->simStartUs;
    p->statLastReportSeconds = p->wallStartSeconds;
    p->statIdleWallSeconds = 0.0;
    p->statSleepSeconds = 0.0;
    p->statIdleCalls = 0;
    p->statCappedCalls = 0;
    p->statCappedLostMs = 0.0;
    p->statRebaseCalls = 0;
    p->statRebaseLostMs = 0.0;
    for (int i = 0; i < 4; i++) { p->statRebaseWhyCalls[i] = 0; p->statRebaseWhyMs[i] = 0.0; }
    p->statIdleLoopWallS = 0.0;
    p->statIdleLoopSimS = 0.0;
}

/* Every couple of seconds, say how the wall clock was spent and what
 * fraction of real time the simulation actually achieved. */
static void rtpacer_report(RTPacer *p) {
    static int on = -1;
    if (on < 0) on = getenv("YAGPC_PACETRACE") != NULL;
    if (!on) return;
    double now = yagpc_monotonic_seconds();
    if (now - p->statLastReportSeconds < 2.0) return;
    double wall = now - p->wallBirthSeconds;
    double sim = (p->cpu->elapsedTimeUs - 0.0) / 1e6;
    fprintf(stderr,
            "PACE wall=%8.2fs sim=%8.2fs rate=%.3f | idle: %ld calls %.2fs wall, "
            "capped %ld (%.0f ms sim dropped) | slept %.2fs | rebase %ld (%.1fs written off)\n",
            wall, sim, wall > 0 ? sim / wall : 0.0, p->statIdleCalls,
            p->statIdleWallSeconds, p->statCappedCalls, p->statCappedLostMs,
            p->statSleepSeconds, p->statRebaseCalls, p->statRebaseLostMs / 1000.0);
    fprintf(stderr,
            "     rebase by cause: pace %ld/%.1fs  wake %ld/%.1fs  peer %ld/%.1fs  resync %ld/%.1fs\n",
            p->statRebaseWhyCalls[0], p->statRebaseWhyMs[0] / 1000.0,
            p->statRebaseWhyCalls[1], p->statRebaseWhyMs[1] / 1000.0,
            p->statRebaseWhyCalls[2], p->statRebaseWhyMs[2] / 1000.0,
            p->statRebaseWhyCalls[3], p->statRebaseWhyMs[3] / 1000.0);
    fprintf(stderr, "     wait loop: %.2fs wall delivered %.2fs sim (%.3f)\n",
            p->statIdleLoopWallS, p->statIdleLoopSimS,
            p->statIdleLoopWallS > 0 ? p->statIdleLoopSimS / p->statIdleLoopWallS : 0.0);
    p->statLastReportSeconds = now;
}

double rtpacer_ahead_ms(const RTPacer *p) {
    double simMs = (p->cpu->elapsedTimeUs - p->simStartUs) / 1000.0 / p->factor;
    double wallMs = (yagpc_monotonic_seconds() - p->wallStartSeconds) * 1000.0;
    return simMs - wallMs;
}

void rtpacer_pace(RTPacer *p) {
    rtpacer_report(p);
    double ahead = rtpacer_ahead_ms(p);
    if (ahead > 2.0) {
        double t0 = yagpc_monotonic_seconds();
        yagpc_sleep_seconds(ahead / 1000.0);
        p->statSleepSeconds += yagpc_monotonic_seconds() - t0;
    }
    /* NO REBASE WHEN MERELY BEHIND.  Falling behind is not a stall: the
     * host has the headroom to make it up (a wait state closes the gap at
     * once, ordinary execution by not sleeping), and writing it off is the
     * one thing that makes the simulated clock permanently slow.  A rebase
     * is for wall time during which the machine was genuinely STOPPED --
     * a debugger pause -- and rtpacer_resync() is the only caller that
     * describes that. */
}

void rtpacer_rebase(RTPacer *p, RTPaceRebaseWhy why) {
    /* A rebase FORGETS whatever the simulation was behind by: the origin
     * moves to now and the deficit is never made up.  That is deliberate
     * (see STALL_REBASE_MS), but it is also the only way the simulated
     * clock can permanently run slow against the wall, so count what is
     * being written off -- a display clock losing a third of real time
     * shows up here and nowhere else. */
    double behindMs = -rtpacer_ahead_ms(p);
    if (behindMs > 0.0) {
        p->statRebaseCalls++;
        p->statRebaseLostMs += behindMs;
        p->statRebaseWhyCalls[why]++;
        p->statRebaseWhyMs[why] += behindMs;
    }
    p->wallStartSeconds = yagpc_monotonic_seconds();
    p->simStartUs = p->cpu->elapsedTimeUs;
}

void rtpacer_note_idle_loop(RTPacer *p, double wallSeconds, double simSeconds) {
    p->statIdleLoopWallS += wallSeconds;
    p->statIdleLoopSimS += simSeconds;
}

double rtpacer_wall_ms(const RTPacer *p) {
    return (yagpc_monotonic_seconds() - p->wallBirthSeconds) * 1000.0;
}

const char *rtpacer_result_name(RTPaceResult why) {
    switch (why) {
        case RTPACE_RESUMED: return "resumed";
        case RTPACE_MASKED:  return "masked";
        case RTPACE_TIMEOUT: return "timeout";
        default:             return "waiting";
    }
}

void rtpacer_enter_idle(RTPacer *p) {
    p->idleStartWallSeconds = yagpc_monotonic_seconds();
    p->idleStartSimUs = p->cpu->elapsedTimeUs;
}

/* Carry the wait state forward to the wall clock: advance simulated time
 * to cover the wall time elapsed since rtpacer_enter_idle(), servicing
 * interrupts as each step lands. */
RTPaceResult rtpacer_advance_idle(RTPacer *p) {
    rtpacer_report(p);
    double statT0 = yagpc_monotonic_seconds();
    p->statIdleCalls++;
    if (psw_get_wait_state(&p->cpu->psw)) {
        if (!cpu_can_wake(p->cpu)) return RTPACE_MASKED;

        /* MEASURED AGAINST THE RUN'S OWN ORIGIN, not against the moment
         * this wait began.  Anchoring on the wait's start made the loop
         * track the wall clock 1:1 from wherever it happened to be, so a
         * deficit accrued while executing was PRESERVED through the wait
         * and then thrown away by the rebase on wake -- while any lead was
         * slept off by rtpacer_pace().  Leads surrendered and deficits
         * destroyed: the simulated clock could only ever lose, and lost a
         * third of real time.
         *
         * The wait state is exactly where the time is won back.  The
         * machine is idle, nothing observable happens, and the next event
         * is already determined, so simulated time may run ahead of the
         * host as fast as it likes -- up to, and never past, the wall
         * clock.  cpu_advance_idle_ns() still stops at the next timer
         * expiry and the instant the wait clears, so no interrupt is taken
         * late or early. */
        double owedNs = -rtpacer_ahead_ms(p) * 1e6 * p->factor;
        if (owedNs > IDLE_CATCHUP_MAX_NS) {
            /* Bounded per call so a pathological gap is closed over
             * several passes rather than in one jump.  NOT dropped: the
             * remainder is still owed and the next call still sees it. */
            p->statCappedCalls++;
            owedNs = IDLE_CATCHUP_MAX_NS;
        }
        if (owedNs > 0.0) cpu_advance_idle_ns(p->cpu, owedNs);
    }
    if (!psw_get_wait_state(&p->cpu->psw)) {
        /* No rebase on wake either: the deficit is real and recoverable. */
        return RTPACE_RESUMED;
    }
    p->statIdleWallSeconds += yagpc_monotonic_seconds() - statT0;
    double idleMs = (yagpc_monotonic_seconds() - p->idleStartWallSeconds) * 1000.0;
    return idleMs > p->idleTimeoutMs ? RTPACE_TIMEOUT : RTPACE_WAITING;
}

/* Called when the machine starts running again after the HOST stopped it
 * -- a debugger halt, most obviously.  Forgets the wall time that passed
 * while it was stopped, for the reasons in STALL_REBASE_MS. */
void rtpacer_resync(RTPacer *p) {
    rtpacer_rebase(p, RTPACE_REBASE_RESYNC);
    p->idleStartWallSeconds = yagpc_monotonic_seconds();
    p->idleStartSimUs = p->cpu->elapsedTimeUs;
}

