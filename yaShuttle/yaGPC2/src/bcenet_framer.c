/* See bcenet_framer.h. */
#include "bcenet_framer.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FRAMER_MAX_BUS_ID 24
/* Was 64 ("generous headroom over any real BCE long-form transfer") --
 * wrong, confirmed empirically: a real DK-bus DATA FILL message (op=1,
 * see nsts-sim-gpc's meds/idp.coffee recvDK) relays a whole display
 * frame buffer, hundreds of words (a real TEST-9011-GPC_MEMORY.dfb
 * fixture there is 541 words). 1024 comfortably covers that with room
 * to spare. */
#define FRAMER_MAX_WORDS 1024
#define FRAMER_RECV_QUEUE_WORDS 16384

/* Was `true` ("every real BCE-numbered bus is IUA-addressed, matching
 * com/bus.civet's own Bus class usage") -- WRONG, confirmed empirically
 * against a live MEDS session (2026-08-19): nsts-sim-gpc's own
 * com/lru.civet _setupBuses() constructs every one of its own Bus
 * instances (DK1 included) with only 2 constructor arguments --
 * `new Bus(busName, busConfig[busName])` -- so `isShuttleBus` defaults
 * to false there, meaning NO 2-byte IUA-prefix header at all on the
 * wire. Sending shuttle-bus-framed messages (this code's own earlier
 * assumption) put an extra word (the IUA+reserved header, byte-swapped
 * into a real data word by the receiver) in front of every real message
 * MEDS parsed -- confirmed directly: a real MEDS-style Bus construction
 * receiving this code's old output saw [0x0100, 0xbeef] instead of
 * [0xbeef], i.e. everything shifted by one word. The real Shuttle 1553B
 * wire protocol *does* use IUA addressing in principle (bus.civet's own
 * Bus class fully supports it), but nsts-sim-gpc's actual runtime
 * construction of its own LRUs doesn't exercise that path -- match what
 * MEDS actually does, not what the wire format could in principle
 * support. Revisit if nsts-sim-gpc's own bus construction ever changes.
 * All real BCE-numbered buses (1-23 in the port table -- see
 * bcenet_transport.c), formerly assumed IUA-addressed, matching
 * gpcBceNum-mapped entries in com/bus.civet's busConfig (as opposed
 * to the underscore-prefixed private/point-to-point buses, which have no
 * gpcBceNum at all and aren't reachable through this table). Hardcoded
 * true rather than made configurable per-bus since nothing in this
 * table's scope is ever NOT a shuttle bus -- flagged here as an
 * assumption to confirm once this is actually exchanging real traffic
 * with nsts-sim-gpc (see the plan's own wire-protocol test step). */
#define FRAMER_IS_SHUTTLE_BUS false

typedef struct {
    bool used;
    int lastIua;
    bool haveLastIua;

    uint16_t xmitBuf[FRAMER_MAX_WORDS];
    size_t xmitCount;

    /* A FIFO, not a one-datagram buffer.  Every pending datagram is
     * drained into it once per tick, the way the reference's socket
     * callback delivers them, so the transport's self-echo filter is
     * consulted while its record of what we sent is still current.
     * Reading the socket only when a receive instruction happened to be
     * running let that record -- a bounded ring -- turn over long before
     * the matching echoes were read, and the leftovers then arrived as
     * if they were the peripheral's replies.  Sized for a burst of
     * mass-memory blocks (512 halfwords each) landing between ticks. */
    uint16_t recvQueue[FRAMER_RECV_QUEUE_WORDS];
    size_t recvHead, recvCount;
} BceNetBusState;

struct BceNetFramer {
    BceNetTransport *transport; /* not owned */
    BceNetBusState buses[FRAMER_MAX_BUS_ID + 1];
};

BceNetFramer *bcenet_framer_create(BceNetTransport *transport) {
    BceNetFramer *f = malloc(sizeof(BceNetFramer));
    f->transport = transport;
    memset(f->buses, 0, sizeof f->buses);
    return f;
}

void bcenet_framer_free(BceNetFramer *f) { free(f); }

static BceNetBusState *ensure_bus(BceNetFramer *f, int busID) {
    if (busID < 0 || busID > FRAMER_MAX_BUS_ID) return NULL;
    BceNetBusState *b = &f->buses[busID];
    if (!b->used) {
        bcenet_transport_open_bus(f->transport, busID); /* logs its own failure; harmless to keep trying */
        b->used = true;
    }
    return b;
}

/* Sends whatever's accumulated for busID as one message and clears the
 * buffer. No-op if nothing's pending. Destination IUA is whatever the
 * most recent GPC_SVC_XMIT_CMD for this bus specified -- if none has
 * arrived yet (shouldn't normally happen; a transmit burst is always
 * preceded by a command in real usage), falls back to IUA 0. */
static void flush_bus(BceNetFramer *f, int busID, BceNetBusState *b) {
    if (b->xmitCount == 0) return;
    int iua = b->haveLastIua ? b->lastIua : 0;
    bcenet_transport_send(f->transport, busID, iua, FRAMER_IS_SHUTTLE_BUS, b->xmitBuf, b->xmitCount);
    b->xmitCount = 0;
}

/* Take every datagram the socket currently holds and append its words to
 * this bus's FIFO. */
static void drain_bus(BceNetFramer *f, int busID, BceNetBusState *b) {
    int iua = b->haveLastIua ? b->lastIua : 0;
    for (;;) {
        uint16_t words[FRAMER_MAX_WORDS];
        size_t count = 0;
        if (!bcenet_transport_recv(f->transport, busID, iua, FRAMER_IS_SHUTTLE_BUS, words,
                                   FRAMER_MAX_WORDS, &count)) {
            return;   /* nothing left, or a datagram the filters dropped */
        }
        /* Compact first: the queue is consumed from the head, so once the
         * head has advanced the space in front of it is free. */
        if (b->recvHead > 0 && b->recvCount + count > FRAMER_RECV_QUEUE_WORDS) {
            memmove(b->recvQueue, b->recvQueue + b->recvHead,
                    (b->recvCount - b->recvHead) * sizeof b->recvQueue[0]);
            b->recvCount -= b->recvHead;
            b->recvHead = 0;
        }
        if (b->recvCount + count > FRAMER_RECV_QUEUE_WORDS) {
            fprintf(stderr, "bcenet: bus %d: receive queue full, dropping %zu words\n",
                    busID, count);
            return;
        }
        memcpy(b->recvQueue + b->recvCount, words, count * sizeof words[0]);
        b->recvCount += count;
    }
}

static void refill_recv_queue(BceNetFramer *f, int busID, BceNetBusState *b) {
    drain_bus(f, busID, b);
}

void bcenet_framer_service(void *ctx, GpcServiceNumber serviceNumber, const GpcServiceInput *input,
                            GpcServiceOutput *output) {
    BceNetFramer *f = ctx;
    memset(output, 0, sizeof *output);
    BceNetBusState *b = ensure_bus(f, input->busID);
    if (!b) return; /* out-of-range busID: all-false/zero output, same as no servicer installed */

    switch (serviceNumber) {
        case GPC_SVC_XMIT_CMD: {
            /* A new command starts a new transaction. Flush any prior
             * transmit burst first -- normally already empty (the
             * per-tick flush should have cleared it), but defensive
             * against a command arriving before this tick's flush ran. */
            flush_bus(f, input->busID, b);
            b->lastIua = input->address;
            b->haveLastIua = true;

            /* Anything still queued from the LAST transaction is stale and
             * must not lead this one.  A subsystem cannot always know how
             * many words the bus program will read -- a display unit
             * answers a status request with its whole status block, and
             * software reads either one halfword of it or sixteen from the
             * same command word -- so a leftover word is normal, and the
             * hardware, whose receiver is inhibited outside a commanded
             * transfer, never captures it.  Discarded here rather than at
             * receive completion, which would also throw away words that
             * legitimately arrive later in a transfer. */
            b->recvHead = 0;
            b->recvCount = 0;

            /* And then SEND the command.  This is the whole point of the
             * call and it was missing: the IUA was recorded, any pending
             * data flushed, ok reported -- and the command word itself
             * silently dropped, so a real peripheral never heard from us
             * at all.  It goes out as its own two-word message, the
             * 24-bit command left-justified across them, exactly as the
             * reference's MIA does. */
            uint32_t cmd24 = input->in.word & 0x00ffffffu;
            uint16_t words[2];
            words[0] = (uint16_t)((cmd24 >> 8) & 0xffffu);
            words[1] = (uint16_t)((cmd24 & 0xffu) << 8);
            bcenet_transport_send(f->transport, input->busID, input->address,
                                  FRAMER_IS_SHUTTLE_BUS, words, 2);
            output->out.xmit.ok = true;
            break;
        }

        case GPC_SVC_XMIT_WORD: {
            /* Each data word goes out as its OWN one-word message, which
             * is what the reference's MIA does and what a peripheral
             * parses.  Batching a transmit burst into a single datagram
             * -- what this used to do, flushed once a tick -- produced a
             * multi-word message the subsystem on the other end had no
             * reason to expect: it reads a datagram as one bus word, so a
             * burst arrived as one garbled word and the rest vanished.
             * That is why a bare command (POSITION) got through while
             * anything carrying data behind it did not. */
            uint16_t word = (uint16_t)input->in.word;
            int iua = b->haveLastIua ? b->lastIua : 0;
            bcenet_transport_send(f->transport, input->busID, iua,
                                  FRAMER_IS_SHUTTLE_BUS, &word, 1);
            output->out.xmit.ok = true;
            break;
        }

        case GPC_SVC_RECV_POLL:
            refill_recv_queue(f, input->busID, b);
            output->out.poll.available = (b->recvHead < b->recvCount);
            break;

        case GPC_SVC_RECV_WORD:
            refill_recv_queue(f, input->busID, b);
            if (b->recvHead < b->recvCount) {
                output->out.recv.available = true;
                output->out.recv.word = b->recvQueue[b->recvHead++];
            } else {
                output->out.recv.available = false;
            }
            break;
    }
}

void bcenet_framer_flush_tick(BceNetFramer *f) {
    /* Let the transport put out whatever the bus has had time for. */
    bcenet_transport_pump(f->transport);
    for (int i = 0; i <= FRAMER_MAX_BUS_ID; i++) {
        if (!f->buses[i].used) continue;
        flush_bus(f, i, &f->buses[i]);
        /* Drain every tick, not only when a receive instruction asks:
         * the transport's self-echo record is bounded, and leaving
         * datagrams in the socket long enough for it to turn over is
         * exactly what let our own transmissions come back as replies. */
        drain_bus(f, i, &f->buses[i]);
    }
}
