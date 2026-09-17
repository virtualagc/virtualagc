/* See bcenet_framer.h. */
#include "bcenet_framer.h"
#include "busword.h"

#include "envcache.h"
#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

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
    uint32_t recvQueue[FRAMER_RECV_QUEUE_WORDS];   /* may carry YAGPC_BUSWORD_CMD_SYNC */
    size_t recvHead, recvCount;

    /* For bcenet_framer_peer_wait(): whether a reply is owed, and whether
     * anything is there to owe it.  Wall seconds (CLOCK_MONOTONIC). */
    double lastPeerWall;    /* last datagram from the peer; 0 = never */
    bool cmdPending;        /* a command has gone out since the last hold budget */
    double heldSinceCmd;    /* wall seconds already spent holding for it */
} BceNetBusState;

static double wall_now(void);

struct BceNetFramer {
    BceNetTransport *transport; /* not owned: one for the whole vehicle */
    /* WHICH COMPUTER this framer belongs to.  Only bus 24 (IP, the
     * intercomputer bus) depends on it -- buses 1-23 are one shared wire
     * each -- but the transport needs it to pick the right socket. */
    int gpcId;
    BceNetBusState buses[FRAMER_MAX_BUS_ID + 1];
};

/* EVERY COMPUTER ON A WIRE HEARS WHAT IS ON IT.  With several machines in
 * one process there is one transport, and so one socket per bus, and each
 * machine's framer reads that socket: a display unit's reply went to
 * whichever computer's thread happened to read first, and a listener lost
 * words at random.  And the transport drops everything from its own transmit
 * socket as an echo, so no computer ever saw another's command word -- which
 * a Listen Mode receive waits for (busword.h).
 *
 * So with more than one framer every datagram read from a bus is appended to
 * the queue of EVERY framer using that bus, whoever read it; and a command a
 * computer sends is shown to the others as a command-sync word, after
 * clearing what they had queued (a new command ends the last transaction on
 * the wire), exactly as the in-process device models show their listeners
 * the commander's command (#136, #137).  A computer's DATA words are not
 * copied: a listener's receiver is not armed for them, and a word it never
 * reads would only sit in its queue.  Bus 24 is per computer and excluded.
 * With one framer none of this happens and nothing changes. */
#define FAN_SLOTS 6
static BceNetFramer *g_framers[FAN_SLOTS];
static int g_nFramers;
#ifdef HAVE_PTHREADS
static pthread_mutex_t g_fanLock = PTHREAD_MUTEX_INITIALIZER;
#endif

static bool fanout_bus(int busID) { return g_nFramers > 1 && busID >= 1 && busID <= 23; }
static void fan_lock(int busID) {
#ifdef HAVE_PTHREADS
    if (fanout_bus(busID)) pthread_mutex_lock(&g_fanLock);
#else
    (void)busID;
#endif
}
static void fan_unlock(int busID) {
#ifdef HAVE_PTHREADS
    if (fanout_bus(busID)) pthread_mutex_unlock(&g_fanLock);
#else
    (void)busID;
#endif
}

BceNetFramer *bcenet_framer_create(BceNetTransport *transport, int gpcId) {
    BceNetFramer *f = malloc(sizeof(BceNetFramer));
    f->transport = transport;
    f->gpcId = gpcId;
    memset(f->buses, 0, sizeof f->buses);
    if (gpcId >= 1 && gpcId < FAN_SLOTS && g_framers[gpcId] == NULL) {
        g_framers[gpcId] = f;
        g_nFramers++;
    }
    return f;
}

void bcenet_framer_free(BceNetFramer *f) {
    if (f != NULL && f->gpcId >= 1 && f->gpcId < FAN_SLOTS && g_framers[f->gpcId] == f) {
        g_framers[f->gpcId] = NULL;
        g_nFramers--;
    }
    free(f);
}

/* Append to one framer's queue for a bus.  `quiet` for another computer's
 * copy: a queue it never drains is simply restarted rather than reported. */
static void queue_push(BceNetBusState *b, int busID, const uint32_t *w, size_t count, bool quiet) {
    if (b->recvHead > 0 && b->recvCount + count > FRAMER_RECV_QUEUE_WORDS) {
        memmove(b->recvQueue, b->recvQueue + b->recvHead,
                (b->recvCount - b->recvHead) * sizeof b->recvQueue[0]);
        b->recvCount -= b->recvHead;
        b->recvHead = 0;
    }
    if (b->recvCount + count > FRAMER_RECV_QUEUE_WORDS) {
        if (quiet) { b->recvHead = b->recvCount = 0; }
        else {
            fprintf(stderr, "bcenet: bus %d: receive queue full, dropping %zu words\n",
                    busID, count);
            return;
        }
    }
    memcpy(b->recvQueue + b->recvCount, w, count * sizeof w[0]);
    b->recvCount += count;
}

static BceNetBusState *ensure_bus(BceNetFramer *f, int busID) {
    if (busID < 0 || busID > FRAMER_MAX_BUS_ID) return NULL;
    BceNetBusState *b = &f->buses[busID];
    if (!b->used) {
        bcenet_transport_open_bus(f->transport, busID, f->gpcId); /* logs its own failure; harmless to keep trying */
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
    bcenet_transport_send(f->transport, busID, f->gpcId, iua, FRAMER_IS_SHUTTLE_BUS,
                          b->xmitBuf, b->xmitCount);
    b->xmitCount = 0;
}

/* Take every datagram the socket currently holds and append its words to
 * this bus's FIFO. */
static void drain_bus(BceNetFramer *f, int busID, BceNetBusState *b) {
    int iua = b->haveLastIua ? b->lastIua : 0;
    for (;;) {
        uint16_t words[FRAMER_MAX_WORDS];
        uint32_t w32[FRAMER_MAX_WORDS];
        size_t count = 0;
        if (!bcenet_transport_recv(f->transport, busID, f->gpcId, iua, FRAMER_IS_SHUTTLE_BUS, words,
                                   FRAMER_MAX_WORDS, &count)) {
            return;   /* nothing left, or a datagram the filters dropped */
        }
        for (size_t i = 0; i < count; i++) w32[i] = words[i];
        double now = (count > 0) ? wall_now() : 0.0;
        if (fanout_bus(busID)) {
            /* To every computer using this wire -- see g_framers. */
            fan_lock(busID);
            for (int g = 1; g < FAN_SLOTS; g++) {
                BceNetFramer *o = g_framers[g];
                if (o == NULL || !o->buses[busID].used) continue;
                queue_push(&o->buses[busID], busID, w32, count, o != f);
                if (count > 0) o->buses[busID].lastPeerWall = now;
            }
            fan_unlock(busID);
            continue;
        }
        queue_push(b, busID, w32, count, false);
        if (count > 0) b->lastPeerWall = now;
    }
}

static double wall_now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
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
            fan_lock(input->busID);
            b->recvHead = 0;
            b->recvCount = 0;
            fan_unlock(input->busID);
            b->cmdPending = true;
            b->heldSinceCmd = 0.0;

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
            bcenet_transport_send(f->transport, input->busID, f->gpcId, input->address,
                                  FRAMER_IS_SHUTTLE_BUS, words, 2);
            /* And onto the wire for the other computers on it. */
            if (fanout_bus(input->busID)) {
                uint32_t marked = cmd24 | YAGPC_BUSWORD_CMD_SYNC;
                fan_lock(input->busID);
                for (int g = 1; g < FAN_SLOTS; g++) {
                    BceNetFramer *o = g_framers[g];
                    if (o == NULL || o == f || !o->buses[input->busID].used) continue;
                    BceNetBusState *ob = &o->buses[input->busID];
                    ob->recvHead = ob->recvCount = 0;
                    queue_push(ob, input->busID, &marked, 1, true);
                }
                fan_unlock(input->busID);
            }
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
            bcenet_transport_send(f->transport, input->busID, f->gpcId, iua,
                                  FRAMER_IS_SHUTTLE_BUS, &word, 1);
            output->out.xmit.ok = true;
            break;
        }

        case GPC_SVC_RECV_POLL:
            refill_recv_queue(f, input->busID, b);
            fan_lock(input->busID);
            output->out.poll.available = (b->recvHead < b->recvCount);
            fan_unlock(input->busID);
            break;

        case GPC_SVC_RECV_WORD:
            refill_recv_queue(f, input->busID, b);
            fan_lock(input->busID);
            if (b->recvHead < b->recvCount) {
                output->out.recv.available = true;
                output->out.recv.word = b->recvQueue[b->recvHead++];
            } else {
                output->out.recv.available = false;
            }
            fan_unlock(input->busID);
            break;
    }
}

void bcenet_framer_flush_tick(BceNetFramer *f) {
    /* Let the transport put out whatever the bus has had time for. */
    bcenet_transport_pump(f->transport);
    /* One poll() for every bus, so the drains below cost a syscall only on
     * the buses that actually have a datagram waiting. */
    bcenet_transport_poll_ready(f->transport);
    for (int i = 0; i <= FRAMER_MAX_BUS_ID; i++) {
        if (!f->buses[i].used) continue;
        flush_bus(f, i, &f->buses[i]);
        if (!bcenet_transport_bus_ready(f->transport, i, f->gpcId)) continue;
        /* Drain every tick, not only when a receive instruction asks:
         * the transport's self-echo record is bounded, and leaving
         * datagrams in the socket long enough for it to turn over is
         * exactly what let our own transmissions come back as replies. */
        drain_bus(f, i, &f->buses[i]);
    }
}

/* HOLDING THE MACHINE FOR A PEER IN ANOTHER PROCESS.
 *
 * A real display unit answers a poll in tens of microseconds, and the flight
 * software's windows assume it: GPCIPL gives the DK bus a message time out of
 * 5.0 ms, and the MSC that services the bus gives up on the BCE sooner than
 * that.  A display unit that is a Python process on the same host usually
 * answers in a few hundred microseconds of WALL time -- but not always.  Its
 * event loop also draws the MDU, and a redraw, a garbage collection or the
 * scheduler can keep it from reading the socket for tens of milliseconds.
 * The simulated clock does not wait, so the reply lands after the window has
 * closed: the BCE error-terminates, GPCIPL counts a failed transaction
 * (ERROR 44, BCE TIME-OUT N RETRY FAIL-DEUIPL; 96, REAL TIME MSC TIME OUT),
 * re-IPLs the unit, and after a second failure gives up on it -- which is
 * the "clock but no menu" screen: the time fills still flow, the one-shot
 * menu fill is never sent.  Measured with MEDS2.py in a private namespace:
 * 46 to 60 BCE6 receive time outs per run, three runs of three failed.
 *
 * Lengthening the time out does not help and was tried (iop.c,
 * RECV_TIMEOUT_FLOOR_US): a window longer in SIMULATED time puts the MSC's
 * service loop out of phase.  What does help is the other way round -- let no
 * simulated time pass while the reply is on its way.  This blocks the
 * emulation thread, in wall time, until a word arrives or the budget is
 * spent, and the reply then lands inside the software's own window exactly
 * as a real unit's would.
 *
 * Only when a reply is actually owed: a command has gone out on this bus
 * since the budget was last spent, and the peer has been heard from within
 * PEER_LIVE_SECONDS -- so a bus with nothing on it, or a unit that has gone
 * away, still times out at full speed, and GPCIPL's polling of empty DK buses
 * costs nothing.  The budget is per command: PEER_HOLD_SECONDS while nothing
 * has arrived, PEER_HOLD_PARTIAL_SECONDS once part of the reply is in, since
 * a unit being loaded answers a sixteen-word read with its header alone and
 * that is not lateness (deumodel.c, FUNC_POLL).  YAGPC_PEER_HOLD_MS sets the
 * first; 0 turns the hold off. */
#define PEER_LIVE_SECONDS 3.0
#define PEER_HOLD_SECONDS 0.200
#define PEER_HOLD_PARTIAL_SECONDS 0.005
#define PEER_HOLD_TICK_NS 50000L   /* 50 us between looks at the socket */

static double peer_hold_seconds(void) {
    static double cached = -1.0;
    if (cached < 0.0) {
        const char *e = yagpc_getenv("YAGPC_PEER_HOLD_MS");
        cached = (e != NULL && *e != '\0') ? atof(e) / 1000.0 : PEER_HOLD_SECONDS;
        if (cached < 0.0) cached = 0.0;
    }
    return cached;
}

bool bcenet_framer_peer_wait(BceNetFramer *f, int busID, bool gotAny, double *heldMs) {
    if (heldMs) *heldMs = 0.0;
    if (f == NULL || busID < 0 || busID > FRAMER_MAX_BUS_ID) return false;
    BceNetBusState *b = &f->buses[busID];
    if (!b->used) return false;
    fan_lock(busID);
    bool already = (b->recvHead < b->recvCount);
    fan_unlock(busID);
    if (already) return true;   /* already here */
    double hold = peer_hold_seconds();
    if (hold <= 0.0 || !b->cmdPending) return false;
    double t0 = wall_now();
    if (b->lastPeerWall <= 0.0 || t0 - b->lastPeerWall > PEER_LIVE_SECONDS) return false;
    double budget = (gotAny ? PEER_HOLD_PARTIAL_SECONDS : hold) - b->heldSinceCmd;
    if (budget <= 0.0) {
        b->cmdPending = false;   /* spent: time out normally from here */
        return false;
    }
    bool got = false;
    double t = t0;
    for (;;) {
        /* Our own transmit queue may still hold the command the peer is to
         * answer; without a transmit thread only this pump sends it. */
        bcenet_transport_pump(f->transport);
        drain_bus(f, busID, b);
        t = wall_now();
        fan_lock(busID);
        got = (b->recvHead < b->recvCount);
        fan_unlock(busID);
        if (got) break;
        if (t - t0 >= budget) break;
        struct timespec ts = {0, PEER_HOLD_TICK_NS};
        nanosleep(&ts, NULL);
    }
    b->heldSinceCmd += t - t0;
    if (!got && b->heldSinceCmd >= (gotAny ? PEER_HOLD_PARTIAL_SECONDS : hold))
        b->cmdPending = false;
    if (heldMs) *heldMs = (t - t0) * 1000.0;
    return got;
}
