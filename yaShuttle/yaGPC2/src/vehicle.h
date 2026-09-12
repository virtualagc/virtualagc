/* The hardware the computers SHARE.
 *
 * An orbiter has one set of peripherals and up to five General Purpose
 * Computers hanging off it: two mass memory units, one master timing unit,
 * the display units on the DK buses, one crew panel.  yaGPC2 emulated one
 * computer per process, so "the vehicle" and "the machine" were the same
 * object and every model could live in the BatchRunner that drove it.
 *
 * With several machines in one process that stops being true.  A device
 * model must be ONE instance answering whichever computer commands it -- five
 * private copies of the mass memory is not a vehicle, it is five vehicles --
 * and the bus sockets must be opened once, not once per machine, or each
 * machine's transmissions arrive at the others looking like a peripheral's
 * reply.
 *
 * So the models and the bus transport move here, and a BatchRunner borrows
 * them.  The Vehicle owns them and outlives every machine.
 *
 * WHAT IS NOT HERE: anything a computer has one of.  Its discrete channel,
 * its identity, its pacer, its framer and its own view of the buses stay in
 * the BatchRunner -- see run.h.
 */
#ifndef YAGPC_VEHICLE_H
#define YAGPC_VEHICLE_H

#include <stdbool.h>

#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif

#include "run.h"


typedef struct Vehicle {
    /* Built on the first machine's init and shared by the rest. */
    bool built;

    /* Two mass memory units, MM1 on bus 18 and MM2 on bus 19.  Two, for the
     * whole vehicle -- see the note on --mmu-model. */
    struct MmuModel *mmu[2];
    int mmuBus[2];

    struct MtuModel *mtu;                        /* buses 20-22 */
    struct DeuModel *deu;                        /* the built-in DK1 unit */
    struct DeuModel *deuExtra[DEU_EXTRA_MAX];    /* --deu-bus */
    int deuExtraBus[DEU_EXTRA_MAX];
    int nDeuExtra;

    /* One set of bus sockets for the process.  Per machine they would each
     * bind the same ports for buses 1-23 and mistake one another's
     * transmissions for peripheral replies. */
    struct BceNetTransport *transport;

    /* How many computers are running on this vehicle.  Only used to decide
     * whether stderr lines need a "GPC n: " prefix -- a single-computer run
     * should look exactly as it always has. */
    int nMachines;

    /* THE VEHICLE'S CLOCK, in simulated microseconds.  The shared device
     * models pace against simulated time -- the mass memory releases a word
     * per word time as the tape turns -- and they used to watch ONE machine's
     * elapsedTimeUs, which was the same thing when there was one machine.
     * With several it is not: whichever machine initialised last owned the
     * pointer, so a mass memory would sit still while a DIFFERENT computer
     * tried to IPL from it, hand over one word and stop.  The tape turns
     * whoever is watching, so this follows the furthest-advanced machine. */
    double clockUs;

    /* Every running computer's discrete channel, so the inter-GPC lines can
     * be routed between them.  Indexed by GPC id 1-5; NULL where a computer
     * is not running, which is exactly right -- a machine that is not there
     * drives nothing, its neighbours' bits stay clear, and all-zero already
     * means "halt/standby/dead" to the flight software. */
    struct Discretes *lines[6];

    /* THE SIMULATED-TIME BARRIER.
     *
     * Each machine paces itself to the WALL clock, which keeps the group
     * roughly together but says nothing about how far apart they may drift
     * in SIMULATED time -- a thread descheduled for one time slice is
     * milliseconds of simulated GPC time behind the others by the time it
     * runs again.  That is fatal once the computers wait for each other:
     * every one of the five FCOS sync programs spins on the inter-GPC
     * discretes with a 3.85 ms timeout measured in the GPC's own time, and
     * a miss votes the offending computer out of the set.  A spurious
     * fail-to-sync caused by the host's scheduler is indistinguishable
     * from a flight-software defect, which is the worst kind of artefact
     * to leave in.
     *
     * So no machine may run more than barDeltaUs of simulated time ahead of
     * the slowest; one that would waits.  It composes with the pacer rather
     * than replacing it -- the barrier holds the machines together, the
     * pacer holds the group to the wall clock.
     *
     * WHY THE PUBLISHED TIME IS NOT elapsedTimeUs ITSELF.  A CPU's clock
     * counts from ITS OWN start, so two machines that came up a minute
     * apart -- or one that has been sitting in HALT executing nothing while
     * the other ran -- read a minute apart while being perfectly
     * simultaneous in the vehicle.  Compared raw, the later one would look
     * like the slowest machine on board and drag the whole vehicle back to
     * meet it.  barOffsetUs re-bases a machine onto the group's frame as it
     * joins or rejoins, so the comparison measures drift and nothing else,
     * and no CPU's own time base is rewritten to get it.
     *
     * The doubles are written by their owning machine and read by the
     * others, unlocked, exactly as clockUs above is -- a stale read costs
     * one pass of the check.  barLock covers only join and leave, which
     * happen when a mode switch moves. */
    double barDeltaUs;        /* 0 disables; YAGPC_BARRIER_US overrides */
    bool barOn;
    double barPubUs[6];       /* each machine's time in the shared frame */
    double barOffsetUs[6];
    bool barActive[6];        /* false while a machine is held in reset */
    unsigned long barHolds;   /* how often the barrier actually bound */
    double barHeldSec;
#ifdef HAVE_PTHREADS
    pthread_mutex_t barLock;
#endif
} Vehicle;

void vehicle_init(Vehicle *v);
void vehicle_free(Vehicle *v);

/* True when more than one computer is running on this vehicle. */
bool vehicle_multi(const Vehicle *v);

/* Carry the vehicle's clock forward to this machine's simulated time. */
void vehicle_note_time(Vehicle *v, double machineUs);

/* Register a computer's discrete channel and wire its output register to the
 * other computers' inputs. */
void vehicle_add_machine(Vehicle *v, int gpcId, struct Discretes *d);

/* Hold this machine until it is no more than the barrier's delta of
 * simulated time ahead of the slowest running one.  Cheap and returning at
 * once in the ordinary case; call it once per instruction. */
void vehicle_barrier_wait(Vehicle *v, int gpcId, double machineUs);

/* Take this machine out of the barrier -- it is held in reset, or done --
 * so the others do not wait for a clock that has stopped. */
void vehicle_barrier_leave(Vehicle *v, int gpcId);

#endif
