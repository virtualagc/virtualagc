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
        uint32_t tag[ICC_QUEUE];  /* ICC_TAG(transfer, position) -- see below */
        size_t head, count;
        unsigned long dropped;
        uint32_t lastTag;         /* the last word this receiver took off it */
        int haveLast;
    } q[YAGPC_ICC_BUS_LAST + 1][6];   /* [bus 1-5][receiving GPC id 1-5] */
    unsigned long busXmit[YAGPC_ICC_BUS_LAST + 1];
    unsigned long busRecv[YAGPC_ICC_BUS_LAST + 1];

    /* EVERY WORD KNOWS WHICH TRANSFER IT BELONGS TO, AND WHERE IN IT.
     *
     * The ICC fails its checksum intermittently (ledger #128) and this wire
     * is entirely ours, so the first question is whether a listener is
     * handed the words its commander sent, in order, and nothing else.  A
     * word is tagged with its transfer's sequence number on that bus and its
     * position: 0 for the command word, 1..n for data.  A receiver that
     * takes a COMMAND word, skips a position, or moves on to a new transfer
     * before finishing the last is counted and, under YAGPC_ICCSEQ, shown.
     * The transfer's length comes from its own command word. */
    uint32_t seqNow[YAGPC_ICC_BUS_LAST + 1];
    uint32_t posNow[YAGPC_ICC_BUS_LAST + 1];
    uint32_t lenOf[YAGPC_ICC_BUS_LAST + 1][64];   /* data words, by seq & 63 */
    unsigned long cmdAsData[YAGPC_ICC_BUS_LAST + 1][6];
    unsigned long skipped[YAGPC_ICC_BUS_LAST + 1][6];
    unsigned long leftEarly[YAGPC_ICC_BUS_LAST + 1][6];
    int seqShown;
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

#define ICC_TAG(seq, pos)  (((seq) << 10) | ((pos) & 0x3ffu))
#define ICC_SEQ(tag)       ((tag) >> 10)
#define ICC_POS(tag)       ((tag) & 0x3ffu)

/* To everyone else ON THAT BUS: that is what a bus is. */
static void icc_broadcast(IccModel *m, int bus, int from, uint32_t word,
                          uint32_t tag) {
    for (int g = 1; g <= 5; g++) {
        if (g == from) continue;
        if (m->q[bus][g].count >= ICC_QUEUE) { m->q[bus][g].dropped++; continue; }
        size_t at = (m->q[bus][g].head + m->q[bus][g].count) % ICC_QUEUE;
        m->q[bus][g].w[at] = word;
        m->q[bus][g].tag[at] = tag;
        m->q[bus][g].count++;
    }
}

/* Judge the word a receiver just took against the one before it. */
static void icc_check_order(IccModel *m, int bus, int rx, uint32_t tag,
                            uint32_t word) {
    const char *what = NULL;
    uint32_t seq = ICC_SEQ(tag), pos = ICC_POS(tag);
    if (pos == 0) {
        m->cmdAsData[bus][rx]++;
        what = "took the COMMAND word as data";
    } else if (m->q[bus][rx].haveLast) {
        uint32_t lseq = ICC_SEQ(m->q[bus][rx].lastTag);
        uint32_t lpos = ICC_POS(m->q[bus][rx].lastTag);
        if (seq == lseq && pos != lpos + 1) {
            m->skipped[bus][rx]++;
            what = "skipped a position";
        } else if (seq != lseq && lpos != 0 && lpos < m->lenOf[bus][lseq & 63u]) {
            m->leftEarly[bus][rx]++;
            what = "moved to a new transfer before finishing the last";
        }
    }
    if (what != NULL && m->seqShown < 60 && getenv("YAGPC_ICCSEQ") != NULL) {
        m->seqShown++;
        fprintf(stderr, "ICCSEQ t=%.6f bus=%d rx=GPC%d %s: transfer %u pos %u "
                        "(of %u) word=%06x, previous transfer %u pos %u\n",
                yagpc_monotonic_seconds(), bus, rx, what, (unsigned)seq,
                (unsigned)pos, (unsigned)m->lenOf[bus][seq & 63u],
                (unsigned)(word & 0xffffffu),
                (unsigned)ICC_SEQ(m->q[bus][rx].lastTag),
                (unsigned)ICC_POS(m->q[bus][rx].lastTag));
    }
    m->q[bus][rx].lastTag = tag;
    m->q[bus][rx].haveLast = 1;
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
        m->seqNow[bus]++;
        m->posNow[bus] = 0;
        m->lenOf[bus][m->seqNow[bus] & 63u] = (in->in.word & 0x1ffu) + 1u;
        /* THE COMMAND WORD IS NOT DELIVERED TO THE LISTENERS.
         *
         * An intercomputer transfer is a command word and then the data
         * words, and a listener's bus program (FIOSICLS) is a bare #RDLI of
         * SIPICCNT words -- data only.  A real receiver tells a command word
         * from a data word by its sync pattern and a listening BCE does not
         * store one; this model's receive path carries no sync type, so it
         * used to queue the command word like any other and the listener
         * took it as its first data word.  Measured with every word tagged by
         * transfer and position: listeners took the command word as data on
         * 15 of 16 transfers in one run and 256 of 260 in another, never
         * skipped a position and never left a transfer early -- so each
         * 124-word read left the 124th data word behind for the next, and
         * the copy of the partner's ICC buffer slid one word further out of
         * register with every transfer.  The flight software checksums that
         * buffer only when its first word reads SSIP phase 1, which on
         * shifted data is chance, so the result was an intermittent checksum
         * failure, a failed retry, an input problem report on one computer
         * and not the other, and the pair voted apart (ledger #128). */
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_XMIT_WORD:
        m->xmitWords++;
        m->posNow[bus]++;
        icc_broadcast(m, bus, gpcId, in->in.word,
                      ICC_TAG(m->seqNow[bus], m->posNow[bus]));
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
            icc_check_order(m, bus, gpcId,
                            m->q[bus][gpcId].tag[m->q[bus][gpcId].head],
                            out->out.recv.word);
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
        for (int g = 1; g <= 5; g++) {
            if (m->cmdAsData[b][g] == 0 && m->skipped[b][g] == 0 &&
                m->leftEarly[b][g] == 0)
                continue;
            fprintf(stderr, "icc: bus %d read by GPC%d: %lu command word(s) "
                            "taken as data, %lu position(s) skipped, %lu "
                            "transfer(s) left before finishing\n",
                    b, g, m->cmdAsData[b][g], m->skipped[b][g],
                    m->leftEarly[b][g]);
        }
    }
}
