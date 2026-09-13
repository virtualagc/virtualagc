/* See iccmodel.h. */
#include "iccmodel.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"

#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif

/* A computer transmits a command word and then data words; every other
 * computer sees the whole sequence in order.  The queue is per BUS and per
 * RECEIVER, so one slow reader cannot lose another's traffic AND the five
 * intercomputer buses do not run into one another -- each computer commands
 * its own and listens on the other four, so at any moment there may be
 * several independent conversations on the wire set.  See iccmodel.h.
 *
 * Deep enough for a redundancy-management pass to sit unread for a while --
 * FCMDSCRM moves a few dozen words per cycle -- and bounded, because a
 * computer that never reads must not grow the vehicle without limit. */
#define ICC_QUEUE 2048

struct IccModel {
    struct {
        uint32_t w[ICC_QUEUE];
        size_t head, count;
        unsigned long dropped;
    } q[YAGPC_ICC_BUS_LAST + 1][6];   /* [bus 1-5][receiving GPC id 1-5] */
    unsigned long busXmit[YAGPC_ICC_BUS_LAST + 1];
    unsigned long busRecv[YAGPC_ICC_BUS_LAST + 1];
    unsigned long xmitCmds, xmitWords, recvWords;
    unsigned long recvPolls, recvCalls;   /* does anybody even ask? */
    int traced;
#ifdef HAVE_PTHREADS
    pthread_mutex_t lock;
#endif
};

static void icc_lock(IccModel *m) {
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&m->lock);
#else
    (void)m;
#endif
}
static void icc_unlock(IccModel *m) {
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&m->lock);
#else
    (void)m;
#endif
}

IccModel *iccmodel_create(void) {
    IccModel *m = (IccModel *)calloc(1, sizeof *m);
    if (m == NULL) return NULL;
#ifdef HAVE_PTHREADS
    pthread_mutex_init(&m->lock, NULL);
#endif
    fprintf(stderr, "icc: intercomputer buses %d-%d wired between the "
                    "computers, each commanding its own\n",
            YAGPC_ICC_BUS_FIRST, YAGPC_ICC_BUS_LAST);
    return m;
}

void iccmodel_free(IccModel *m) {
    if (m == NULL) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_destroy(&m->lock);
#endif
    free(m);
}

/* To everyone else ON THAT BUS: that is what a bus is. */
static void icc_broadcast(IccModel *m, int bus, int from, uint32_t word) {
    for (int g = 1; g <= 5; g++) {
        if (g == from) continue;
        if (m->q[bus][g].count >= ICC_QUEUE) { m->q[bus][g].dropped++; continue; }
        size_t at = (m->q[bus][g].head + m->q[bus][g].count) % ICC_QUEUE;
        m->q[bus][g].w[at] = word;
        m->q[bus][g].count++;
    }
}

void iccmodel_service(IccModel *m, int gpcId, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out) {
    if (m == NULL || in == NULL || out == NULL) return;
    if (gpcId < 1 || gpcId > 5) return;
    int bus = in->busID;
    if (!YAGPC_ICC_IS_BUS(bus)) return;
    icc_lock(m);
    switch (svc) {
    case GPC_SVC_XMIT_CMD:
        m->xmitCmds++;
        /* YAGPC_ICCTRACE: the first commands each computer issues on the
         * bus, raw.  The question they answer is whether the software ever
         * asks to READ another computer, which the counters say it does
         * not -- and a command word says what kind it is. */
        if (m->traced < 24 && getenv("YAGPC_ICCTRACE") != NULL) {
            m->traced++;
            fprintf(stderr, "ICCCMD t=%.1f gpc=%d bus=%d cmd=%08x\n",
                    yagpc_monotonic_seconds(), gpcId, bus,
                    (unsigned)in->in.word);
        }
        m->busXmit[bus]++;
        icc_broadcast(m, bus, gpcId, in->in.word);
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_XMIT_WORD:
        m->xmitWords++;
        icc_broadcast(m, bus, gpcId, in->in.word);
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL:
        m->recvPolls++;
        out->out.poll.available = (m->q[bus][gpcId].count > 0);
        break;
    case GPC_SVC_RECV_WORD:
        m->recvCalls++;
        if (m->q[bus][gpcId].count > 0) {
            out->out.recv.available = true;
            out->out.recv.word = m->q[bus][gpcId].w[m->q[bus][gpcId].head];
            m->q[bus][gpcId].head = (m->q[bus][gpcId].head + 1) % ICC_QUEUE;
            m->q[bus][gpcId].count--;
            m->busRecv[bus]++;
            m->recvWords++;
        } else {
            out->out.recv.available = false;
        }
        break;
    default:
        break;
    }
    icc_unlock(m);
}

void iccmodel_report(const IccModel *m) {
    if (m == NULL) return;
    unsigned long dropped = 0, pending = 0;
    for (int b = YAGPC_ICC_BUS_FIRST; b <= YAGPC_ICC_BUS_LAST; b++)
        for (int g = 1; g <= 5; g++) {
            dropped += m->q[b][g].dropped;
            pending += m->q[b][g].count;
        }
    fprintf(stderr, "icc: {\"xmitCmds\":%lu,\"xmitWords\":%lu,\"recvPolls\":%lu,"
                    "\"recvCalls\":%lu,\"recvWords\":%lu,\"pending\":%lu,"
                    "\"dropped\":%lu}\n",
            m->xmitCmds, m->xmitWords, m->recvPolls, m->recvCalls,
            m->recvWords, pending, dropped);
    /* PER BUS, because "the ICC works" is not one question but five: each
     * computer commands its own bus, so a bus with transmits and no reads
     * names exactly which computer nobody is listening to. */
    for (int b = YAGPC_ICC_BUS_FIRST; b <= YAGPC_ICC_BUS_LAST; b++) {
        unsigned long pend = 0, drop = 0;
        for (int g = 1; g <= 5; g++) { pend += m->q[b][g].count; drop += m->q[b][g].dropped; }
        if (m->busXmit[b] == 0 && m->busRecv[b] == 0 && pend == 0) continue;
        fprintf(stderr, "icc: bus %d (GPC%d's): %lu commands out, %lu words "
                        "read, %lu pending, %lu dropped\n",
                b, b, m->busXmit[b], m->busRecv[b], pend, drop);
    }
}
