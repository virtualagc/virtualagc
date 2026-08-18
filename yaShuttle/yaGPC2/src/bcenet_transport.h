/* Layer 3 of the real-peripheral servicer bridge (see plan-mode discussion
 * history, 2026-08-19): raw send/receive of 16-bit-word bus messages over
 * multicast UDP, matching Don Schmidt's nsts-sim-gpc real wire protocol
 * exactly (com/bus.civet: one UDP socket per bus, bound to that bus's own
 * port, joined to multicast group 239.255.1.1; "shuttle bus" messages are
 * IUA-prefixed, 16-bit words big-endian/network order).
 *
 * Deliberately the ONLY layer that knows anything about UDP/multicast --
 * this exists so a future TCP or shared-memory transport is a second,
 * independent implementation of the same four functions below, not a
 * rewrite of bcenet_framer.c (which only calls these, never touches a
 * socket itself). Nothing here is emulator-specific; it's just "send/
 * receive words for a given bus number."
 *
 * POSIX sockets only for now (this project's actual test environment);
 * see bcenet_transport.c's own header comment for the Windows situation. */
#ifndef YAGPC_BCENET_TRANSPORT_H
#define YAGPC_BCENET_TRANSPORT_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct BceNetTransport BceNetTransport;

BceNetTransport *bcenet_transport_create(void);
void bcenet_transport_free(BceNetTransport *t);

/* Opens (if not already open) the UDP multicast socket for busID, per the
 * built-in busID->port table mirroring nsts-sim-gpc's com/bus.civet
 * busConfig (see bcenet_transport.c). Returns false if busID has no known
 * port mapping, or if the socket couldn't be created/bound/joined
 * (details logged to stderr). Safe to call repeatedly for the same
 * busID -- a no-op once open. */
bool bcenet_transport_open_bus(BceNetTransport *t, int busID);

/* Sends one message: `wordCount` 16-bit words, each byte-swapped to
 * network order individually, on busID's socket. If isShuttleBus, a
 * 2-byte header (byte 0 = iua, byte 1 = 0 -- see bcenet_transport.c's
 * own comment on why byte 1 is a don't-care reserved byte, not
 * meaningfully "0" on the real wire) precedes the word data, matching
 * Bus#sendMsg's own layout exactly. Returns false if the bus isn't open
 * (call bcenet_transport_open_bus first) or the send itself failed. */
bool bcenet_transport_send(BceNetTransport *t, int busID, int iua, bool isShuttleBus, const uint16_t *words,
                            size_t wordCount);

/* Non-blocking: attempts to receive one whole datagram already queued on
 * busID's socket (a single recvfrom() with no wait -- called this way
 * because packets arrive asynchronously from the emulator's own
 * synchronous step loop, and this project's actual call pattern polls
 * this once per RECV_POLL/RECV_WORD service call rather than running a
 * separate receive thread). If isShuttleBus, strips and checks the
 * 2-byte IUA header (byte 0 must equal iua, matching Bus#_recvMessage's
 * own filter -- a message for a different IUA is silently discarded, not
 * queued, exactly like the real Bus class); byte 1 is ignored either way.
 * On success, fills outWords (caller-owned, capacity maxWords) and
 * *outCount, both already byte-swapped back to host order, and returns
 * true. Returns false if nothing was available, the message didn't match
 * this IUA, or it wouldn't fit in maxWords (logged, not fatal). */
bool bcenet_transport_recv(BceNetTransport *t, int busID, int iua, bool isShuttleBus, uint16_t *outWords,
                            size_t maxWords, size_t *outCount);

#endif
