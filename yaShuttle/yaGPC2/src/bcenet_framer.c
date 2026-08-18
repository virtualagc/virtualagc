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

    uint16_t recvQueue[FRAMER_MAX_WORDS];
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

static void refill_recv_queue(BceNetFramer *f, int busID, BceNetBusState *b) {
    if (b->recvHead < b->recvCount) return; /* still have queued words */
    int iua = b->haveLastIua ? b->lastIua : 0;
    size_t count = 0;
    if (bcenet_transport_recv(f->transport, busID, iua, FRAMER_IS_SHUTTLE_BUS, b->recvQueue, FRAMER_MAX_WORDS,
                               &count)) {
        b->recvHead = 0;
        b->recvCount = count;
    }
}

void bcenet_framer_service(void *ctx, GpcServiceNumber serviceNumber, const GpcServiceInput *input,
                            GpcServiceOutput *output) {
    BceNetFramer *f = ctx;
    memset(output, 0, sizeof *output);
    BceNetBusState *b = ensure_bus(f, input->busID);
    if (!b) return; /* out-of-range busID: all-false/zero output, same as no servicer installed */

    switch (serviceNumber) {
        case GPC_SVC_XMIT_CMD:
            /* A new command starts a new transaction. Flush any prior
             * transmit burst first -- normally already empty (the
             * per-tick flush should have cleared it), but defensive
             * against a command arriving before this tick's flush ran. */
            flush_bus(f, input->busID, b);
            b->lastIua = input->address;
            b->haveLastIua = true;
            output->out.xmit.ok = true;
            break;

        case GPC_SVC_XMIT_WORD:
            if (b->xmitCount < FRAMER_MAX_WORDS) {
                b->xmitBuf[b->xmitCount++] = (uint16_t)input->in.word;
            } else {
                fprintf(stderr, "bcenet: bus %d: transmit burst exceeds %d words, dropping extra\n", input->busID,
                        FRAMER_MAX_WORDS);
            }
            output->out.xmit.ok = true;
            break;

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
    for (int i = 0; i <= FRAMER_MAX_BUS_ID; i++) {
        if (f->buses[i].used) flush_bus(f, i, &f->buses[i]);
    }
}
