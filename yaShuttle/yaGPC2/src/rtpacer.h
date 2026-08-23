/* Real-time pacer for the AP-101S simulator.
 *
 * Keeps accumulated simulated CPU time aligned with the WALL CLOCK, so
 * the simulator executes at approximately the speed of the real machine.
 * Ported from gpc/rtpacer.coffee.
 *
 * WHY THIS IS NOT THE SAME AS --time-scale.  Both throttle a simulation
 * that would otherwise run flat out, but they answer different questions.
 * --time-scale (run.c's batchrunner_pace) sleeps off a lead that a
 * program builds up by FAST-FORWARDING: a HAL/S task that WAITs consumes
 * no host time, so the CLI sleeps to stop the virtual clock outrunning
 * the wall clock.  It never makes simulated time advance on its own.
 *
 * A machine sitting in the AP-101S wait state needs the opposite.  There
 * are no instructions to pace; the thing that ends the wait is an
 * interrupt from somewhere else -- an interval timer, the IOP, or a
 * peripheral answering on a bus -- and the simulated clock has to keep
 * moving for any of them to happen.  Free-running it (the previous
 * behaviour) advances simulated time as fast as the host can manage,
 * which is precisely what breaks a real peripheral: a bus receive time
 * out is measured in SIMULATED time, so a reply that is a millisecond
 * away in wall-clock terms arrives to a transaction that timed out
 * "hours" ago.  Sharing a speed-up FACTOR is not enough; the two clocks
 * have to be re-tied to each other often enough to stay inside the
 * tolerance the protocol allows.
 *
 * So the wait state is paced the other way round: elapsed WALL time is
 * converted into simulated time and handed to cpu_advance_idle_ns(),
 * which spends it on the timers and the IOP's slices.  That is what
 * keeps this emulator's clock and an external peripheral's clock
 * together, and it is why driving a real MMU or MEDS needs --real-time
 * rather than just a --time-scale.
 */
#ifndef YAGPC_RTPACER_H
#define YAGPC_RTPACER_H

#include <stdbool.h>

struct CPU;

typedef struct {
    struct CPU *cpu;
    double factor;          /* speed multiplier; 2.0 = twice real speed */
    double idleTimeoutMs;   /* give up on a wait after this much wall time */

    double wallStartSeconds;  /* pacing baseline, re-based after idle */
    double simStartUs;
    double wallBirthSeconds;  /* fixed start, for reporting */

    double idleStartWallSeconds;
    double idleStartSimUs;
} RTPacer;

/* Why a paced wait ended. */
typedef enum {
    RTPACE_RESUMED,   /* an interrupt woke the CPU (pacing re-baselined) */
    RTPACE_MASKED,    /* all system interrupts masked; nothing can wake it */
    RTPACE_TIMEOUT,   /* no wakeup within idleTimeoutMs of wall time */
    RTPACE_WAITING,   /* still waiting; call again */
} RTPaceResult;

void rtpacer_init(RTPacer *p, struct CPU *cpu, double factor, double idleTimeoutMs);

/* Milliseconds of wall time the simulation is ahead of the wall clock
 * (negative when the simulation is behind). */
double rtpacer_ahead_ms(const RTPacer *p);

/* Called between instruction chunks: sleep off any lead over real time. */
void rtpacer_pace(RTPacer *p);

/* Restart the pacing baseline at "now". */
void rtpacer_rebase(RTPacer *p);

/* Called when the machine starts running again after the HOST stopped it
 * (a debugger halt).  Forgets the wall time that passed meanwhile: the
 * peripheral's datagrams from that window are already lost, and repaying
 * the gap as simulated time would only run every outstanding bus
 * transaction past its receive time out. */
void rtpacer_resync(RTPacer *p);

/* Sit in the wait state at the real-time rate until an interrupt clears
 * it, or until nothing can. */
RTPaceResult rtpacer_idle_wait(RTPacer *p);

/* Wall milliseconds since the pacer was created, for reporting. */
double rtpacer_wall_ms(const RTPacer *p);

/* Human-readable form of a result, for stop reasons. */
const char *rtpacer_result_name(RTPaceResult why);

#endif
