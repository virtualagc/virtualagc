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
 * computer sees the whole sequence in order.  The queue is per RECEIVER, so
 * one slow reader cannot lose another's traffic.
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
    } q[6];                       /* indexed by receiving GPC id 1-5 */
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
    fprintf(stderr, "icc: intercomputer bus %d wired between the computers\n",
            YAGPC_ICC_BUS);
    return m;
}

void iccmodel_free(IccModel *m) {
    if (m == NULL) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_destroy(&m->lock);
#endif
    free(m);
}

/* To everyone but the sender: that is what a bus is. */
static void icc_broadcast(IccModel *m, int from, uint32_t word) {
    for (int g = 1; g <= 5; g++) {
        if (g == from) continue;
        if (m->q[g].count >= ICC_QUEUE) { m->q[g].dropped++; continue; }
        size_t at = (m->q[g].head + m->q[g].count) % ICC_QUEUE;
        m->q[g].w[at] = word;
        m->q[g].count++;
    }
}

void iccmodel_service(IccModel *m, int gpcId, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out) {
    if (m == NULL || in == NULL || out == NULL) return;
    if (gpcId < 1 || gpcId > 5) return;
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
            fprintf(stderr, "ICCCMD t=%.1f gpc=%d cmd=%08x\n",
                    yagpc_monotonic_seconds(), gpcId,
                    (unsigned)in->in.word);
        }
        icc_broadcast(m, gpcId, in->in.word);
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_XMIT_WORD:
        m->xmitWords++;
        icc_broadcast(m, gpcId, in->in.word);
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL:
        m->recvPolls++;
        out->out.poll.available = (m->q[gpcId].count > 0);
        break;
    case GPC_SVC_RECV_WORD:
        m->recvCalls++;
        if (m->q[gpcId].count > 0) {
            out->out.recv.available = true;
            out->out.recv.word = m->q[gpcId].w[m->q[gpcId].head];
            m->q[gpcId].head = (m->q[gpcId].head + 1) % ICC_QUEUE;
            m->q[gpcId].count--;
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
    for (int g = 1; g <= 5; g++) { dropped += m->q[g].dropped; pending += m->q[g].count; }
    fprintf(stderr, "icc: {\"xmitCmds\":%lu,\"xmitWords\":%lu,\"recvPolls\":%lu,"
                    "\"recvCalls\":%lu,\"recvWords\":%lu,\"pending\":%lu,"
                    "\"dropped\":%lu}\n",
            m->xmitCmds, m->xmitWords, m->recvPolls, m->recvCalls,
            m->recvWords, pending, dropped);
}
