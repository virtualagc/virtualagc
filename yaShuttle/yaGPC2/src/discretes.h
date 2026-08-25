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

#define DISCRETES_REG_A 1
#define DISCRETES_REG_B 2

/* How long a bit stays "externally driven" after its last message.
 * Publishers republish every 250 ms, so this is several periods -- long
 * enough not to flap on a dropped datagram, short enough that a departed
 * publisher does not strand the machine.  YAGPC_DISCRETES_STALE_SEC
 * overrides it. */
#define DISCRETES_STALE_SEC 1.5

/* Join the bus.  False (with a message on stderr) if the socket cannot be
 * opened; the caller carries on without it. */
bool discretes_open(void);
void discretes_close(void);
bool discretes_enabled(void);

/* Take in whatever has arrived.  Cheap, non-blocking, and safe to call on
 * every read of the discrete registers -- which is what iop.c does, so the
 * value a PCI returns is as fresh as the wire. */
void discretes_poll(void);

/* Bits of `reg` currently being published by somebody, and their values.
 * Call discretes_poll() first.  The mask is empty when disabled, so
 * callers need no special case. */
uint32_t discretes_driven_mask(int reg);
uint32_t discretes_value(int reg);

/* Datagrams applied since open, for the run summary. */
unsigned long discretes_message_count(void);

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
void discretes_publish(int reg, uint32_t mask, bool on);

#endif
