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


/* Buses 1-24.  The intercomputer buses are 1-5, one per computer -- NOT
 * bus 24, which is the IP bus and carries something else entirely; see
 * iccmodel.h for the command words that settle it. */
#define YAGPC_BUS_MAX 24

typedef struct Vehicle {
    /* Built on the first machine's init and shared by the rest. */
    bool built;

    /* Two mass memory units, MM1 on bus 18 and MM2 on bus 19.  Two, for the
     * whole vehicle -- see the note on --mmu-model. */
    struct MmuModel *mmu[2];
    int mmuBus[2];

    struct MtuModel *mtu;                        /* buses 20-22 */
    /* Buses 1-5, the wires between the computers -- see iccmodel.h.  Built
     * only when more than one is running; with one there is nobody to talk
     * to. */
    struct IccModel *icc;
    struct IOP *iops[6];         /* per machine, for vehicle_io_agrees */
    bool devicesLoaded;          /* vehicle_load_mmu: once, not per machine */
    /* The spread a capture recorded, waiting for each machine's FIRST join
     * -- see vehicle_dump_devices.  Not applied directly to barOffsetUs,
     * because a resumed machine is held until its panel is heard and a held
     * machine leaves the barrier; it rejoins afterwards, and the join is
     * where the offset is decided. */
    double resumeOffsetUs[6];
    bool haveResumeOffset[6];
    struct DeuModel *deu;                        /* the built-in DK1 unit */
    struct DeuModel *deuExtra[DEU_EXTRA_MAX];    /* --deu-bus */
    int deuExtraBus[DEU_EXTRA_MAX];
    int nDeuExtra;

    /* WHICH COMPUTER EACH DISPLAY UNIT BELONGS TO.
     *
     * Two GPCs cannot drive the same display unit.  A display-keyboard bus
     * has a single commander and a unit hangs off one bus, so a unit is one
     * computer's -- measured, two machines told to drive the built-in DK1
     * unit abandoned 477 transfers between them and no keystroke ever
     * reached the flight software.
     *
     * The built-in unit goes to the first computer named; the rest are
     * named on the command line, `--deu-bus <gpc>:<bus>`.  0 means "no
     * particular computer", which is what one machine wants and what every
     * command line before --gpcs meant.  A computer with no unit attached
     * sees nothing on the display buses, which is the truth about a GPC
     * with no MEDS on it. */
    int deuOwner;
    int deuExtraOwner[DEU_EXTRA_MAX];

    /* One set of bus sockets for the process.  Per machine they would each
     * bind the same ports for buses 1-23 and mistake one another's
     * transmissions for peripheral replies. */
    struct BceNetTransport *transport;

    /* How many computers are running on this vehicle.  Only used to decide
     * whether stderr lines need a "GPC n: " prefix -- a single-computer run
     * should look exactly as it always has. */
    int nMachines;

    /* HOW MANY COMPUTERS WILL RUN, declared before any of them is built.
     *
     * nMachines counts the ones CONSTRUCTED SO FAR and is incremented at the
     * top of batchrunner_init, so while the FIRST machine is being built it
     * reads 1 even in a five-computer run.  Every "is this a multi-GPC
     * vehicle?" question asked during that machine's construction therefore
     * gets the wrong answer, and it has now cost two defects in that one
     * function.  The display unit ended up owned by nobody (fixed in place;
     * see the comment there).  Worse, the intercomputer bus was never wired
     * to GPC 1 AT ALL -- `veh->icc == NULL && veh->nMachines > 1` is false
     * while GPC 1 is being built, so the wire was created by GPC 2 and only
     * GPC 2's router ever held a pointer to it.  GPC 1 does all the
     * intercomputer traffic, so measured, the ICC model went through an
     * entire 900 s two-computer run untouched: 0 transmits, 0 receives, 0
     * polls, while the census recorded two million bus-24 transactions
     * falling through to a display that declined every one.
     *
     * main() knows the answer before it builds anything, so it says so, and
     * vehicle_multi() prefers it. */
    int nExpected;

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
    unsigned long barAbandoned; /* ... and gave up on a clock that had stopped */
    double barHeldSec;

    /* WAKE ON PROGRESS, NOT ON A TIMER.
     *
     * A held machine used to sleep 50 us of wall time at a stretch and look
     * again.  The OS rounds that up -- measured at a 25 us delta, 9.5
     * million holds cost 1,000 s, 106 us each -- and a delta tight enough to
     * keep the two computers' views of each other's sync lines honest is
     * exactly the delta that holds millions of times.  Measured, tightening
     * the delta from 200 us to 25 us delayed the first fail-to-sync tenfold
     * and removed the handshake failure it was aimed at (1 in 713 against 8
     * in 124), so the tight delta is worth having and the cost is the
     * sleep's.
     *
     * So a held machine first re-checks for barSpinUs of wall time, which is
     * where nearly every hold ends, and only then sleeps on barCond -- and
     * the machine it is waiting for WAKES it the moment its published time
     * reaches barWakeAtUs, rather than the sleeper finding out on its next
     * timer tick.  The waker pays one integer compare per instruction while
     * nobody is asleep, and a compare and a double while somebody is. */
    int barWaiters;             /* machines asleep in the barrier */
    double barWakeAtUs;         /* shared time that releases the earliest one */
    double barSpinUs;           /* YAGPC_BARRIER_SPIN_US; 0 = never spin */
    unsigned long barSpinReleases, barSleeps;
#ifdef HAVE_PTHREADS
    pthread_mutex_t barLock;
    pthread_cond_t barCond;
#endif

    /* THE STOP-THE-WORLD, WHICH THE BARRIER ABOVE DELIBERATELY IS NOT.
     *
     * vehicle_barrier_wait is a LEASH: it blocks only a machine that is
     * AHEAD, and barrier_slowest() returns the caller's own time when the
     * caller is the slowest, so the slowest machine never waits at all.
     * That is the right design for keeping the computers together, and it
     * means there is no instant when every thread is stopped -- there is
     * only a guarantee that they are within barDeltaUs of one another.
     *
     * A snapshot needs the other thing.  Writing one machine's registers
     * while another is still executing produces a vehicle that never
     * existed, and the two would not even be wrong by a bounded amount:
     * whichever machine wrote second would have run for however long the
     * first one's file took to reach the disk.
     *
     * So this is a separate, two-phase rendezvous, on its own lock: every
     * member parks, and only when ALL of them have parked does any of them
     * write anything; then they all resume together.  It costs one relaxed
     * load of pauseRequest per instruction while no snapshot is pending,
     * which is the same price the barrier's own barWaiters check pays.
     *
     * MEMBERSHIP IS NOT barActive.  A computer held in HALT has LEFT the
     * barrier (vehicle_barrier_leave), and a machine whose run has ended is
     * still barActive until its thread tidies up -- waiting for either would
     * hang the save forever.  Machines join this group when their run starts
     * and leave when it ends, and a halted one parks from its mode-switch
     * loop, where it is not executing instructions but is very much alive.
     *
     * THE DEADLINE IS WALL TIME, and has to be.  A parked machine's
     * simulated clock is stopped by definition, so a simulated-time deadline
     * could never expire; and what is being waited for -- a thread reaching
     * its next check -- is a wall-clock event. It is sized for the slowest
     * legitimate case by a wide margin: the longest single instruction is an
     * MVH moving 7,654 halfwords, 6.7 ms of simulated time, and a display
     * peer hold can freeze a thread 200 ms of wall time (iop.c). Two seconds
     * is about ten times the worst of those, and expiry ABANDONS the
     * snapshot rather than writing a partial one. */
    /* ON ITS OWN CACHE LINE, because it is read once per instruction by
     * every thread and written once per snapshot.  Measured offsets before
     * this alignment: pauseRequest at 456, barCond at 408..455 -- the last
     * eight bytes of the condition variable shared line 7 with it, so every
     * barrier broadcast (and they happen on every hold) invalidated the line
     * the hot path reads.  A read-mostly flag next to a contended lock is
     * the textbook false-sharing mistake and costs nothing to avoid. */
    _Alignas(64) volatile int pauseRequest;  /* somebody wants the vehicle still */
    int pauseGroup;             /* machines that will honour that */
    bool pauseMember[6];
    int pauseArrived, pauseFinished;
    unsigned pauseArriveGen, pauseFinishGen;
    /* HOW MANY COMPUTERS ARE READING THEIR BOOTSTRAP OFF THE TAPE.
     *
     * That loop lives outside batchrunner_step and has no pause point, so a
     * machine in it cannot reach the rendezvous for the whole transfer --
     * "on the order of two seconds of tape motion", against a 2 s deadline.
     * A snapshot asked for then would simply be abandoned.
     *
     * And parking it there instead would be worse than refusing.  The
     * bootstrap's half-filled image buffer and its cursor are locals of that
     * loop; no snapshot captures them, so a machine caught mid-bootstrap
     * would come back into a transfer it has no record of.  A capture that
     * cannot be restored is not a capture, so the request is refused up
     * front, with the reason. */
    int bootstrapping;
    unsigned long pauseTaken;     /* rendezvous completed */
    unsigned long pauseAbandoned; /* ... and gave up waiting for a machine */
    /* WHAT THE CAPTURE IS CALLED, set by whoever asked for it and read by
     * every machine, so that one instant's files share one name across the
     * whole vehicle and cannot be mistaken for two different captures. */
    char pauseTag[96];
#ifdef HAVE_PTHREADS
    pthread_mutex_t pauseLock;
    pthread_cond_t pauseCond;
#endif

    /* PER-BUS SERIALISATION, AND WHAT IT IS AND IS NOT FOR.
     *
     * The device models are single-conversation state machines, faithfully:
     * a mass memory latches its status and clears it on the read, holds one
     * queue cursor, and serves ONE computer at a time.  On the real vehicle
     * nobody arbitrates a queue for a busy mass memory -- the crew waits for
     * it, and two GPCs commanding the same unit at once is a situation that
     * should not arise.
     *
     * So this lock exists to stop a model corrupting its own state machine
     * when it does arise, and NOT to make it work.  What makes it visible is
     * busClash: a count of the times a DIFFERENT computer commanded a unit
     * that still owed words to the last one.  Smoothing that over with a
     * transparent queue would hide exactly the finding worth having --
     * measured, two computers IPLing from MM1 at the same moment split one
     * 72-block bootstrap read into 37 blocks and 36, and each machine then
     * ran on half an image with nothing to say why. */
    /* WHICH COMPUTER CURRENTLY COMMANDS THE DISPLAY-KEYBOARD BUSES.
     *
     * Not a static wiring question.  Every GPC's bootstrap talks to DK1, and
     * measured, two computers IPLing at once BOTH command bus 6 -- GPC1 531
     * commands and GPC2 340 in the same 100 s.  On the vehicle the crew IPLs
     * them one at a time and the BFC CRT SELECT switch is what hands the
     * buses over, so command follows that switch rather than the command
     * line: a computer claims the DK buses while its switch is off zero and
     * releases them when it returns to zero.  Last claimant wins, and a
     * second claimant arriving while another holds them is REPORTED, because
     * USA005350 3.2.15.1 says dual commanders on a CRT "can result in PASS
     * GPCs failing-to-sync" and that is a finding, not a thing to smooth.
     *
     * 0 means nobody has claimed them, and then the static --deu-bus owner
     * applies -- which is what a single-computer run has always done. */
    int dkClaimant;
    unsigned long dkHandovers, dkDualClaims;

    /* YAGPC_BUSCENSUS: how many transactions each computer put on each bus.
     * The I/O-complete sync is a barrier every set member must reach, so a
     * set holds only if its members do comparable I/O -- and measured, ours
     * differ by seventy to one.  This says WHICH BUS the difference is on,
     * which is what separates a real asymmetry from an emulator artefact. */
    unsigned long busCount[6][YAGPC_BUS_MAX + 1];

    int busOwner[YAGPC_BUS_MAX + 1];          /* last commanding GPC, 0 none */
    unsigned long busClash[YAGPC_BUS_MAX + 1];
#ifdef HAVE_PTHREADS
    pthread_mutex_t busLock[YAGPC_BUS_MAX + 1];
#endif
} Vehicle;

void vehicle_init(Vehicle *v);
void vehicle_free(Vehicle *v);

/* True when more than one computer is running on this vehicle.  Correct
 * DURING construction as well as after it -- see nExpected. */
bool vehicle_multi(const Vehicle *v);

/* Say how many computers will run, before any of them is constructed. */
void vehicle_expect_machines(Vehicle *v, int n);

/* Carry the vehicle's clock forward to this machine's simulated time. */
void vehicle_note_time(Vehicle *v, double machineUs);

/* THE VEHICLE'S OWN DEVICES, CAPTURED AND PUT BACK.  A snapshot of the
 * computers alone restores a vehicle whose peripherals have forgotten
 * everything that was in flight -- see iccmodel.h.  Written once per
 * capture, by the machine vehicle_capture_writer() names, while every
 * machine is parked at the rendezvous. */
bool vehicle_capture_writer(const Vehicle *v, int gpcId);

/* WHETHER THE SET AGREES ABOUT ITS I/O, which is what decides whether a
 * capture can be resumed.  The computers of a redundant set run the same
 * bus programs, so at a resumable instant their outstanding receives match;
 * where they do not, the capture has caught them at different points of the
 * same transfer.  On a restore the peripheral PROCESSES start fresh and
 * whatever was in flight is gone -- lost by both machines, they raise IPR
 * together and carry on; lost by one, each declares the other failed to
 * sync within ten milliseconds (ledger #180).  `why` is filled with the
 * first disagreement found. */
bool vehicle_io_agrees(const Vehicle *v, char *why, size_t n);
void vehicle_set_iop(Vehicle *v, int gpcId, struct IOP *iop);
void vehicle_dump_devices(const Vehicle *v, const char *dir);
void vehicle_load_devices(Vehicle *v, const char *dir);
void vehicle_load_mmu(Vehicle *v, const char *dir);

/* Register a computer's discrete channel and wire its output register to the
 * other computers' inputs. */
void vehicle_add_machine(Vehicle *v, int gpcId, struct Discretes *d);

/* RE-ASSERT one computer's inter-GPC lines to its neighbours.
 *
 * They are LEVELS, not pulses.  A computer holds STBY and RUN set for as
 * long as it is running and toggles only SYNC, so routing on CHANGE alone
 * refreshes the toggling bit and lets the steady ones age out of the
 * neighbour's driven mask -- after which they fall back to the neighbour's
 * locally derived value, which is zero, and a null code of 111 is read as
 * 001.  A GPC that is still running is still driving those lines even
 * though the level has not moved, so they have to be re-asserted.  Cheap
 * and idempotent; call it on the same schedule as the discrete poll. */
void vehicle_refresh_lines(Vehicle *v, int gpcId, uint32_t outValue);
/* How many of the other computers' fail discretes -- as last published,
 * outputs not inhibited -- vote against this one.  For the CAM's diagonal
 * only; see DISCRETES_REG_CFAIL. */
int vehicle_votes_against(const Vehicle *v, int gpcId);

/* Hold this machine until it is no more than the barrier's delta of
 * simulated time ahead of the slowest running one.  Cheap and returning at
 * once in the ordinary case; call it once per instruction. */
void vehicle_barrier_wait(Vehicle *v, int gpcId, double machineUs);

/* THE STOP-THE-WORLD.  See the pause fields in Vehicle.
 *
 * A machine joins the group when its run begins and leaves when it ends;
 * outside that window it is not waited for.  vehicle_pause_request asks for
 * the vehicle to be brought to a stand; every member then parks in
 * vehicle_pause_enter, which returns true to ALL of them at the same
 * instant, or false to all of them if one did not arrive in time.  Each
 * member does its own work -- writing its own files -- and calls
 * vehicle_pause_exit, which releases them together.
 *
 * vehicle_pause_enter is the one on the per-instruction path and returns
 * false immediately when nothing is pending. */
void vehicle_join_pause_group(Vehicle *v, int gpcId);
void vehicle_leave_pause_group(Vehicle *v, int gpcId);
bool vehicle_pause_request(Vehicle *v, const char *tag);
/* A computer is reading its bootstrap; see Vehicle::bootstrapping. */
void vehicle_bootstrap_enter(Vehicle *v);
void vehicle_bootstrap_leave(Vehicle *v);
const char *vehicle_pause_tag(const Vehicle *v);
bool vehicle_pause_enter(Vehicle *v, int gpcId);
void vehicle_pause_exit(Vehicle *v, int gpcId);

/* Take this machine out of the barrier -- it is held in reset, or done --
 * so the others do not wait for a clock that has stopped. */
void vehicle_barrier_leave(Vehicle *v, int gpcId);

/* Serialise one service call on a shared device, and notice if a computer
 * has walked into another's conversation.  `inTransfer` says whether the
 * device still owes the last commander words; pass false for a device that
 * has no such notion.  Every enter must be matched by a leave. */
/* A computer's BFC CRT SELECT switch moved: non-zero claims the display
 * buses for it, zero releases them.  Safe to call on every poll. */
void vehicle_dk_claim(Vehicle *v, int gpcId, bool claiming);

/* True if this computer may command a display unit on this bus.
 *
 * The CLAIM governs only the bootstrap's bus.  Every GPC's GPCIPL talks to
 * DK1 and nothing else, so that is the one bus two computers contend for,
 * and the BFC CRT switch is how the crew hands it over.  Once a computer has
 * loaded, the bus it drives is its NBAT assignment, which here is the static
 * --deu-bus owner -- so a claim on DK1 must NOT also take away a display
 * that belongs to somebody else on another bus.  It used to, and that left
 * the second computer commanding nothing at all: it then reached no I/O
 * completion when its neighbour did, and the I/O-complete sync voted it out
 * of the set 4.33 ms after it was admitted. */
bool vehicle_dk_commands(const Vehicle *v, int gpcId, int staticOwner,
                         int busID);

void vehicle_bus_enter(Vehicle *v, int busID, int gpcId, bool inTransfer);
void vehicle_bus_leave(Vehicle *v, int busID);

#endif
