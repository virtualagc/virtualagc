/* The GPC discrete-input bus, receiving side.
 *
 * A GPC's discrete inputs are hardware lines rather than bus traffic: the
 * crew panel drives HALT/STANDBY/RUN, a mass memory drives its own READY,
 * the orbiter drives BFS engage.  This emulator held them as a fixed
 * constant, which is fine for software that samples a discrete once and
 * fatal for software that HANDSHAKES on one -- see iop.c's
 * iop_discrete_in_a() for what FCMBOOT does with MASS MEMORY READY.
 *
 * iop.c can derive that one bit locally, from whether this GPC's own bus
 * controller is running, and does; that is enough to get the bootstrap
 * through its handshake with nothing else attached.  It is not the real
 * signal, though.  The real one comes from the mass memory, and when a
 * mass memory is actually present it should be the thing that says so.
 *
 * This subscribes to the bus those devices publish on -- the same
 * multicast transport as every other inter-process signal here, group
 * 239.255.1.1, port 6980, one datagram per set/reset.  Four 16-bit words
 * in network order:
 *
 *     0   operation   SET = 1, RESET = 2
 *     1   register    A = 1 (inputs 1-32), B = 2 (inputs 33-40)
 *     2   mask, high half    IBM bit 0 is 0x8000 of this word
 *     3   mask, low half
 *
 * Set/reset of a MASK rather than a whole word is what lets a mass memory
 * and a crew panel drive different bits of register A without either
 * overwriting the other's.  yaShuttle/discretePanel/ has the same protocol
 * in Python, with the reasoning written out, plus a panel and a monitor.
 *
 * WHAT WINS
 *
 * A bit somebody is actually publishing overrides whatever iop.c would
 * derive for it; a bit nobody is publishing keeps the derived or
 * configured value.  So attaching a real mass memory takes over READY,
 * and running with nothing attached still works.
 *
 * A discrete is a level, and publishers repeat themselves precisely
 * because this transport can drop a datagram and has no replay for a late
 * joiner.  A bit therefore counts as externally driven only while its
 * publisher is still being heard from: go quiet for DISCRETES_STALE_SEC
 * and it reverts to the local value, rather than latching whatever was
 * last seen.  Without that, a publisher killed mid-transfer would leave
 * READY stuck low and hang the flight software with nothing to show why.
 */
#ifndef YAGPC_DISCRETES_H
#define YAGPC_DISCRETES_H

#include <stdbool.h>
#include <stdint.h>

/* ONE PER COMPUTER, not one per process.  Five GPCs run in one process and
 * each has its own discrete channel (port base+80+gpcId), its own register
 * A/B/OUT, and its own view of who is driving what.  The bus really is per
 * computer -- see the channel-per-GPC note on DISCRETES_PORT_FOR -- so this
 * is the machine's connection to it, held by the BatchRunner that owns the
 * machine and reachable from its IOP. */
typedef struct Discretes Discretes;

#define DISCRETES_REG_A 1
#define DISCRETES_REG_B 2
/* The discrete OUTPUT register, added with REQUEST/VALUE in
 * nsts-sim-gpc 7946bc1.  The GPC owns every bit of it and publishes its
 * own writes; nothing else drives it. */
#define DISCRETES_REG_OUT 3

/* How long a bit stays "externally driven" after its last message.
 * Publishers republish every 250 ms, so this is several periods -- long
 * enough not to flap on a dropped datagram, short enough that a departed
 * publisher does not strand the machine.  YAGPC_DISCRETES_STALE_SEC
 * overrides it. */
#define DISCRETES_STALE_SEC 1.5

/* Join the bus as the named computer (1-5, or 0 for a standalone GPC).
 * NULL (with a message on stderr) if the socket cannot be opened; the caller
 * carries on without it, and every function below is a safe no-op on NULL. */
Discretes *discretes_create(int gpcId);
void discretes_free(Discretes *d);
bool discretes_enabled(const Discretes *d);

/* Take in whatever has arrived.  Cheap, non-blocking, and safe to call on
 * every read of the discrete registers -- which is what iop.c does, so the
 * value a PCI returns is as fresh as the wire. */
void discretes_poll(Discretes *d);

/* Bits of `reg` currently being published by somebody, and their values.
 * Call discretes_poll() first.  The mask is empty when disabled, so
 * callers need no special case. */
uint32_t discretes_driven_mask(const Discretes *d, int reg);
uint32_t discretes_value(const Discretes *d, int reg);

/* Datagrams applied since open, for the run summary. */
unsigned long discretes_message_count(const Discretes *d);

/* Changes whenever the discrete bus state does; lets a caller cache what it
 * derived from discretes_driven_mask()/discretes_value(). */
unsigned discretes_generation(const Discretes *d);

/* The whole value of a register as this GPC believes it -- what a REQUEST
 * is answered with.  iop.c keeps A and B current here because only it can
 * combine the locally derived bits with the published ones; the OUT
 * register is this process's own and is published on every change. */
void discretes_set_canonical(Discretes *d, int reg, uint32_t value);
void discretes_publish_out(Discretes *d, uint32_t before, uint32_t after);

/* Drive a level onto the bus, for a device modelled in this process that
 * a real vehicle would have wired to a discrete line -- the mass memory's
 * READY, to begin with.  Publishing it is what lets a crew panel or any
 * other listener SEE the signal; without it the line exists only inside
 * this process and the panel's "observed" pane stays blank whether the
 * emulator is running or not.
 *
 * A discrete is a level, so this must be repeated: subscribers drop a bit
 * they have not heard about for DISCRETES_STALE_SEC.  Call it whenever the
 * level changes and periodically regardless.  Cheap and non-blocking; a
 * no-op when the bus was never opened.
 *
 * What we publish, we do NOT then read back as though somebody else had
 * driven it: see discretes_driven_mask.  The model that drove the line is
 * in this process and already authoritative, and routing its own signal
 * out through a socket and back would put UDP delivery -- the very thing
 * --mmu-model exists to keep out of the tape path -- between a device and
 * the machine reading it. */
void discretes_publish(Discretes *d, int reg, uint32_t mask, bool on);


/* ALL bus ports derive from one base, so a second emulation can be run
 * alongside the first without fighting over sockets.  Bus n listens on
 * base+n (IC1-5 = 1-5, DK1-4 = 6-9, ... FC1-4 = 20-23) and the discrete
 * bus on base+80, matching nsts-sim-gpc's busConfig at the default base
 * of 6900.  Set once, before any socket is opened, from --port-base or
 * NSTS_BUS_PORT_BASE. */
#define YAGPC_PORT_BASE_DEFAULT 6900
#define YAGPC_DISCRETES_OFFSET  80
void yagpc_set_port_base(int base);
int  yagpc_port_base(void);
/* The port base stays process-wide: the five computers share one port range
 * by design.  The GPC IDENTITY does not -- it is a property of a machine, is
 * now carried by its Discretes, and selects both that machine's discrete
 * channel and its intercomputer (bus 24) port. */
int  discretes_gpc_id(const Discretes *d);

#endif
