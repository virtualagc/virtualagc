/* See iccmodel.h. */
#include "iccmodel.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"
#include "busword.h"

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
        double at[ICC_QUEUE];     /* sender's shared time; <0 unknown */
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
    /* YAGPC_ICCMSG: the MESSAGE part of each SSIP ICC transfer.  The 124
     * words are a TFICC buffer; TICCVBLG, the variable-buffer length, is
     * word 7 and TICCBUFF, the messages themselves, words 73-122 -- so
     * data positions 8 and 74-123 here.  PASS passes its reconfiguration
     * handshake (ARC_ICC_MSG types 1 and 2, handled by AIESIP's special
     * cases) through that buffer, and which computer sent what, and when,
     * is the question at the OPS transition (ledger #129). */
    uint16_t msgBuf[YAGPC_ICC_BUS_LAST + 1][64];
    uint16_t msgLen[YAGPC_ICC_BUS_LAST + 1];
    uint16_t msgLast[YAGPC_ICC_BUS_LAST + 1][64];
    uint16_t msgLastLen[YAGPC_ICC_BUS_LAST + 1];
    int msgShown;
    double sharedUs[6];           /* per caller; see iccmodel_note_shared_us */

    /* HOW LATE EACH READER GETS EACH TRANSFER, on the shared clock.
     *
     * Measured at the OPS transition, GPC2 finished reading each of GPC1's
     * transfers ~160 ms -- one SSIP cycle -- after GPC1 sent it, so it
     * processes the PREVIOUS cycle's copy of its partner's buffer while the
     * partner acts on its own current one.  A queue that keeps unread words
     * until the next listen would do exactly that after a single missed
     * listen, forever.  So: the lag of every transfer per reader, and at
     * each new command how many words of older transfers a reader still
     * has queued -- a real bus holds none. */
    double sentAtUs[YAGPC_ICC_BUS_LAST + 1][64];
    unsigned long lagN[YAGPC_ICC_BUS_LAST + 1][6];
    unsigned long lagHist[YAGPC_ICC_BUS_LAST + 1][6][8];
    double lagMin[YAGPC_ICC_BUS_LAST + 1][6], lagMax[YAGPC_ICC_BUS_LAST + 1][6];
    unsigned long staleAtCmd[YAGPC_ICC_BUS_LAST + 1][6];
    unsigned long staleWords[YAGPC_ICC_BUS_LAST + 1][6];
    int lagShown;
    double expireUs;              /* YAGPC_ICC_EXPIRE_US; <=0 never */
    unsigned long expired[YAGPC_ICC_BUS_LAST + 1][6];
    /* Which transfers carried a wanted header, by sequence number, so a
     * receiver taking the LAST word of one can be reported: sending a
     * message and a partner reading it are separate facts. */
    uint32_t wantSeq[YAGPC_ICC_BUS_LAST + 1][64];
    int haveWant[YAGPC_ICC_BUS_LAST + 1][64];
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
    m->expireUs = 10000.0;
    {
        const char *e = getenv("YAGPC_ICC_EXPIRE_US");
        if (e != NULL && *e != '\0') m->expireUs = atof(e);
    }
    for (int g = 0; g < 6; g++) m->sharedUs[g] = -1.0;
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
        m->q[bus][g].at[at] = m->sharedUs[from];
        m->q[bus][g].count++;
    }
}

/* Judge the word a receiver just took against the one before it. */
static void icc_check_order(IccModel *m, int bus, int rx, uint32_t tag,
                            uint32_t word) {
    const char *what = NULL;
    uint32_t seq = ICC_SEQ(tag), pos = ICC_POS(tag);
    if (pos == 0) {
        /* A command word is expected now; whether it is stored as data is
         * the receiving BCE's business, and it marks it by sync type. */
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

void iccmodel_note_shared_us(IccModel *m, int gpcId, double sharedUs) {
    if (m != NULL && gpcId >= 1 && gpcId <= 5) m->sharedUs[gpcId] = sharedUs;
}

void iccmodel_service(IccModel *m, int gpcId, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out) {
    if (m == NULL || in == NULL || out == NULL) return;
    if (gpcId < 1 || gpcId > 5) return;
    int bus = in->busID;
    if (!YAGPC_ICC_IS_BUS(bus)) return;
    icc_lock(m);
    /* A BUS HOLDS NOTHING.  Words are on the wire only while they are being
     * sent, and a transfer that goes out while a computer is not listening
     * is lost to that computer.  This model queued them instead, and paid
     * for it: at common-set formation the commander sends two transfers
     * 1.9 ms apart, the listener has finished with the first and is not
     * listening for the second, the second waits in the queue -- and the
     * next cycle's listen takes it, and every listen after that takes the
     * PREVIOUS cycle's transfer.  Measured, 953 of 954 transfers were read
     * ~159.8 ms after they were sent, in both directions, where the first
     * was read in 1.65 ms.  PASS processes a partner's ICC buffer in the SSIP
     * phase after the exchange (AIESIP), so each computer acted on its
     * partner's buffer one cycle late -- which is why the OPS transition's
     * 'form the RS 20 ms from now' message reached the secondary after the
     * prime had already formed it and voted (ledger #129, #131).
     *
     * So a word not taken within expireUs of being sent, on the shared
     * clock, is gone before a receive can see it.  A live transfer is fully
     * read in ~1.6 ms, a stale one is a whole SSIP cycle old, and the default
     * 10 ms sits far from both.  Without a shared clock there is no age to
     * judge, and nothing expires. */
    if ((svc == GPC_SVC_RECV_POLL || svc == GPC_SVC_RECV_WORD) &&
        m->expireUs > 0.0 && m->sharedUs[gpcId] >= 0.0) {
        while (m->q[bus][gpcId].count > 0) {
            double at = m->q[bus][gpcId].at[m->q[bus][gpcId].head];
            if (at < 0.0 || m->sharedUs[gpcId] - at <= m->expireUs) break;
            m->q[bus][gpcId].head = (m->q[bus][gpcId].head + 1) % ICC_QUEUE;
            m->q[bus][gpcId].count--;
            m->expired[bus][gpcId]++;
        }
    }
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
        for (int g = 1; g <= 5; g++) {
            if (g == gpcId || m->q[bus][g].count == 0 || m->lagN[bus][g] == 0) continue;
            m->staleAtCmd[bus][g]++;
            m->staleWords[bus][g] += m->q[bus][g].count;
        }
        m->seqNow[bus]++;
        m->posNow[bus] = 0;
        m->lenOf[bus][m->seqNow[bus] & 63u] = (in->in.word & 0x1ffu) + 1u;
        /* THE COMMAND WORD GOES TO THE LISTENERS, MARKED AS COMMAND SYNC.
         *
         * It was first delivered like a data word, and listeners stored it
         * as their first data word (ledger #128); it was then withheld
         * altogether, which removed the one word a Listen-Mode receiver is
         * designed to wait for.  The BCE Principles of Operation (4.1) has a
         * transmitter-disabled BCE's receive wait indefinitely for a command
         * with a matching IUA and start timing out data only when it arrives
         * -- and FCMINIOP gives the intercomputer BCEs an IUAR of 5, the IUA
         * of the SSIP transfer's command 28007B, and an MTO of 33 us, which
         * only works that way.  So the word is delivered with its sync type
         * (busword.h) and the receiving BCE decides by its own mode. */
        icc_broadcast(m, bus, gpcId,
                      (in->in.word & 0x00ffffffu) | YAGPC_BUSWORD_CMD_SYNC,
                      ICC_TAG(m->seqNow[bus], 0u));
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_XMIT_WORD:
        m->xmitWords++;
        m->posNow[bus]++;
        if (m->posNow[bus] == m->lenOf[bus][m->seqNow[bus] & 63u])
            m->sentAtUs[bus][m->seqNow[bus] & 63u] = m->sharedUs[gpcId];
        {
            uint32_t pos = m->posNow[bus];
            uint16_t w = (uint16_t)(in->in.word & 0xffffu);
            if (pos == 8u) m->msgLen[bus] = w;
            if (pos >= 74u && pos <= 123u) m->msgBuf[bus][pos - 74u] = w;
            /* End of a full SSIP buffer.  YAGPC_ICCMSG=<hex>[,<hex>...] reports
             * only transfers whose message buffer contains one of those
             * headers -- the reconfiguration handshake is a handful of
             * transfers among thousands, and an unfiltered log with a line
             * cap spent its whole budget on routine traffic long before the
             * OPS request and showed nothing.  Given with no list, it reports
             * every change of message content, capped. */
            if (pos == 123u && getenv("YAGPC_ICCMSG") != NULL) {
                static int wInit = 0, nWant = 0;
                static uint16_t want[16];
                if (!wInit) {
                    wInit = 1;
                    const char *e = getenv("YAGPC_ICCMSG");
                    while (e != NULL && *e != '\0' && nWant < 16) {
                        char *end = NULL;
                        unsigned long h = strtoul(e, &end, 16);
                        if (end == e) break;
                        want[nWant++] = (uint16_t)h;
                        e = (*end == ',') ? end + 1 : NULL;
                    }
                }
                uint16_t n = m->msgLen[bus] > 50u ? 50u : m->msgLen[bus];
                int show = 0;
                if (nWant > 0) {
                    for (uint16_t k = 0; k < n && !show; k++)
                        for (int j = 0; j < nWant; j++)
                            if (m->msgBuf[bus][k] == want[j]) { show = 1; break; }
                    if (show) {
                        uint32_t sq = m->seqNow[bus];
                        m->wantSeq[bus][sq & 63u] = sq;
                        m->haveWant[bus][sq & 63u] = 1;
                    }
                } else if (n != m->msgLastLen[bus] ||
                           memcmp(m->msgBuf[bus], m->msgLast[bus], n * sizeof(uint16_t)) != 0) {
                    m->msgLastLen[bus] = n;
                    memcpy(m->msgLast[bus], m->msgBuf[bus], sizeof m->msgBuf[bus]);
                    show = (n > 0 && m->msgShown < 400);
                }
                if (show && m->msgShown < 4000) {
                    m->msgShown++;
                    fprintf(stderr, "ICCMSG t=%.6f tshared=%.1f bus=%d from GPC%d transfer %u len=%u:",
                            yagpc_monotonic_seconds(), m->sharedUs[gpcId], bus, gpcId,
                            (unsigned)m->seqNow[bus], (unsigned)m->msgLen[bus]);
                    for (uint16_t k = 0; k < n; k++)
                        fprintf(stderr, " %04x", m->msgBuf[bus][k]);
                    fprintf(stderr, "\n");
                }
            }
        }
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
            {
                uint32_t tg = m->q[bus][gpcId].tag[m->q[bus][gpcId].head];
                icc_check_order(m, bus, gpcId, tg, out->out.recv.word);
                if (ICC_POS(tg) != 0u && ICC_POS(tg) == m->lenOf[bus][ICC_SEQ(tg) & 63u]) {
                    double lag = m->sharedUs[gpcId] - m->sentAtUs[bus][ICC_SEQ(tg) & 63u];
                    static const double edge[7] = {1e3, 10e3, 100e3, 150e3, 170e3, 330e3, 1e6};
                    int b = 0;
                    while (b < 7 && lag >= edge[b]) b++;
                    m->lagHist[bus][gpcId][b]++;
                    if (m->lagN[bus][gpcId] == 0 || lag < m->lagMin[bus][gpcId]) m->lagMin[bus][gpcId] = lag;
                    if (m->lagN[bus][gpcId] == 0 || lag > m->lagMax[bus][gpcId]) m->lagMax[bus][gpcId] = lag;
                    m->lagN[bus][gpcId]++;
                    if (m->lagShown < 60 && getenv("YAGPC_ICCLAG") != NULL) {
                        m->lagShown++;
                        fprintf(stderr, "ICCLAG bus=%d rx=GPC%d transfer=%u sent=%.1f read=%.1f lag_us=%.1f queued_after=%lu\n",
                                bus, gpcId, (unsigned)ICC_SEQ(tg), m->sentAtUs[bus][ICC_SEQ(tg) & 63u],
                                m->sharedUs[gpcId], lag, (unsigned long)(m->q[bus][gpcId].count - 1));
                    }
                }
                /* The receiver has now taken the last word of a transfer that
                 * carried a wanted message: it has the whole of it. */
                if (ICC_POS(tg) == 123u && m->haveWant[bus][ICC_SEQ(tg) & 63u] &&
                    m->wantSeq[bus][ICC_SEQ(tg) & 63u] == ICC_SEQ(tg)) {
                    m->haveWant[bus][ICC_SEQ(tg) & 63u] = 0;
                    fprintf(stderr, "ICCMSG-READ t=%.6f tshared=%.1f bus=%d transfer %u read in full by GPC%d\n",
                            yagpc_monotonic_seconds(), m->sharedUs[gpcId], bus, (unsigned)ICC_SEQ(tg), gpcId);
                }
            }
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
            if (m->lagN[b][g] == 0) continue;
            fprintf(stderr, "icc: bus %d read by GPC%d: %lu transfers, lag us min %.0f max %.0f, "
                            "hist [<1ms %lu, <10ms %lu, <100ms %lu, <150ms %lu, <170ms %lu, <330ms %lu, <1s %lu, >=1s %lu]; "
                            "%lu new commands found older words still queued (%lu words)\n",
                    b, g, m->lagN[b][g], m->lagMin[b][g], m->lagMax[b][g],
                    m->lagHist[b][g][0], m->lagHist[b][g][1], m->lagHist[b][g][2], m->lagHist[b][g][3],
                    m->lagHist[b][g][4], m->lagHist[b][g][5], m->lagHist[b][g][6], m->lagHist[b][g][7],
                    m->staleAtCmd[b][g], m->staleWords[b][g]);
            if (m->expired[b][g] > 0)
                fprintf(stderr, "icc: bus %d read by GPC%d: %lu word(s) expired unread "
                                "(not taken within %.0f us of being sent)\n",
                        b, g, m->expired[b][g], m->expireUs);
        }
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
