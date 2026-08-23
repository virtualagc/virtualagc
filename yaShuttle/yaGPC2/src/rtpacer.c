/* See rtpacer.h. */
#include "rtpacer.h"

#include "compat.h"
#include "cpu.h"

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
 * inside each other's tolerance. */
#define IDLE_CATCHUP_MAX_NS 5000000.0   /* 5 ms of simulated time */

/* How far BEHIND the wall clock the simulation may fall before the pacer
 * gives up on the gap and re-bases instead of trying to repay it.
 *
 * The host stalls for reasons that have nothing to do with the simulated
 * machine: a debugger breakpoint, a long single-step, the scheduler
 * taking the CPU away.  Repaying that as simulated time is actively
 * harmful when a real peripheral is on the other end of a UDP socket.
 * Datagrams the peripheral sent while we were stopped are already gone --
 * UDP has no retransmission, and a socket receive buffer that fills just
 * drops what arrives next -- so the reply those milliseconds were owed to
 * no longer exists.  Racing the simulated clock forward through them only
 * runs every outstanding transaction past its receive time out, turning a
 * host-side pause into a storm of bus errors.
 *
 * Re-basing instead says: the machine was stopped, the world moved on,
 * carry on from here.  That is also what keeps the two clocks tied rather
 * than merely scaled -- debt is never allowed to accumulate. */
#define STALL_REBASE_MS 250.0

void rtpacer_init(RTPacer *p, struct CPU *cpu, double factor, double idleTimeoutMs) {
    p->cpu = cpu;
    p->factor = factor;
    p->idleTimeoutMs = idleTimeoutMs;
    p->wallStartSeconds = yagpc_monotonic_seconds();
    p->simStartUs = cpu->elapsedTimeUs;
    p->wallBirthSeconds = p->wallStartSeconds;
    p->idleStartWallSeconds = p->wallStartSeconds;
    p->idleStartSimUs = p->simStartUs;
}

double rtpacer_ahead_ms(const RTPacer *p) {
    double simMs = (p->cpu->elapsedTimeUs - p->simStartUs) / 1000.0 / p->factor;
    double wallMs = (yagpc_monotonic_seconds() - p->wallStartSeconds) * 1000.0;
    return simMs - wallMs;
}

void rtpacer_pace(RTPacer *p) {
    double ahead = rtpacer_ahead_ms(p);
    if (ahead > 2.0) {
        yagpc_sleep_seconds(ahead / 1000.0);
    } else if (ahead < -STALL_REBASE_MS) {
        /* The host stalled -- see STALL_REBASE_MS.  Drop the gap. */
        rtpacer_rebase(p);
    }
}

void rtpacer_rebase(RTPacer *p) {
    p->wallStartSeconds = yagpc_monotonic_seconds();
    p->simStartUs = p->cpu->elapsedTimeUs;
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
    if (psw_get_wait_state(&p->cpu->psw)) {
        if (!cpu_can_wake(p->cpu)) return RTPACE_MASKED;

        double targetNs = (yagpc_monotonic_seconds() - p->idleStartWallSeconds)
                          * 1e9 * p->factor;
        double owedNs = targetNs - (p->cpu->elapsedTimeUs - p->idleStartSimUs) * 1000.0;
        bool capped = owedNs > IDLE_CATCHUP_MAX_NS;
        if (capped) owedNs = IDLE_CATCHUP_MAX_NS;
        if (owedNs > 0.0) cpu_advance_idle_ns(p->cpu, owedNs);
        if (capped) {
            p->idleStartWallSeconds = yagpc_monotonic_seconds();
            p->idleStartSimUs = p->cpu->elapsedTimeUs;
        }
    }
    if (!psw_get_wait_state(&p->cpu->psw)) {
        rtpacer_rebase(p);   /* post-wake execution paces at the normal rate */
        return RTPACE_RESUMED;
    }
    double idleMs = (yagpc_monotonic_seconds() - p->idleStartWallSeconds) * 1000.0;
    return idleMs > p->idleTimeoutMs ? RTPACE_TIMEOUT : RTPACE_WAITING;
}

/* Called when the machine starts running again after the HOST stopped it
 * -- a debugger halt, most obviously.  Forgets the wall time that passed
 * while it was stopped, for the reasons in STALL_REBASE_MS. */
void rtpacer_resync(RTPacer *p) {
    rtpacer_rebase(p);
    p->idleStartWallSeconds = yagpc_monotonic_seconds();
    p->idleStartSimUs = p->cpu->elapsedTimeUs;
}

