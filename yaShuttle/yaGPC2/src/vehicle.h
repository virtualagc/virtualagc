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
} Vehicle;

void vehicle_init(Vehicle *v);
void vehicle_free(Vehicle *v);

/* True when more than one computer is running on this vehicle. */
bool vehicle_multi(const Vehicle *v);

/* Carry the vehicle's clock forward to this machine's simulated time. */
void vehicle_note_time(Vehicle *v, double machineUs);

#endif
