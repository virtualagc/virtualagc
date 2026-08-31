#include "mtumodel.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* FIOCBLKS names the MTU device 22 -- FIO22020/1/2 -- but that is FCOS's
 * own device number, not the bus address: the NSP beside it is device 24.
 * The BUS address comes from the BCE program that reads it, FIOPRMPG:
 *
 *     #MIN  0,6                 *READ MTU
 *     #MINC FIOFFIUA,FIOMTURD
 *
 * a six-word Message In, and the only six-word command seen on buses 20-22
 * is 524c26 -- IUA 10, count 6.  (IUA 8's is twelve words.) */
#define MTU_IUA        10
#define MTU_BUS_FIRST  20
#define MTU_BUS_LAST   22

/* The command word's IUA field, the same extraction iop.c's mia_xmit_cmd
 * uses. */
#define CMD_IUA(c)     (((c) >> 19) & 0x1fu)

/* The reply is TFMTU, three halfwords (FPMMTUFX's own DSECT):
 *     TMTUDYHR  H   DAYS/HOURS
 *     TMTUMNSC  H   MIN/SEC
 *     TMTUMSEC  H   MILLISECONDS (0.125 MS UNITS)
 * packed BCD, the field widths taken from the shifts FPMMTUFX performs on
 * each word in turn -- SLDL 2/4/4/2/4 across DYHR, SLDL 3/4/3/4 across
 * MNSC, and `NHI R4,X'1FFF'  ZERO SPARE BITS 0-2` on MSEC. */
/* The transfer is six halfwords; TFMTU's three time words lead it. */
/* SEVEN, not six.  FIOPRMPG's commander reads the MTU with `#MIN 0,6`
 * and its listener with `#RDLI 6`, and the Principles of Operation is
 * explicit that the field is one less than the transfer: "The number of
 * bus words actually sent is 1 more than the number in the Count Field.
 * Thus a Count of 0 causes one memory halfword to be transmitted; a
 * count of 31 corresponds to 32 half words."  So the BCE arms a
 * SEVEN-word receive -- observed directly, "BCE20 RECV ARM count=7" --
 * and a six-word reply leaves it one short, whereupon it times out with
 * left=1 and error terminates the BCE onto its NO-GO path.
 *
 * The extra word goes on the END so the three time halfwords stay at
 * offset 2, where FPMMTURM reads them (LA R3,TFCMMTU1+2). */
#define MTU_WORDS 7

struct MtuModel {
    const double *clockUs;
    uint16_t reply[MTU_WORDS];
    int replyHead, replyCount;
    long commands, reads, wordsOut;
};

struct MtuModel *mtumodel_create(void) {
    struct MtuModel *m = (struct MtuModel *)calloc(1, sizeof *m);
    return m;
}

void mtumodel_free(struct MtuModel *m) { free(m); }

void mtumodel_set_clock(struct MtuModel *m, const double *clockUs) {
    if (m) m->clockUs = clockUs;
}

bool mtumodel_owns_bus(int busID) {
    return busID >= MTU_BUS_FIRST && busID <= MTU_BUS_LAST;
}

/* Two BCD digits, high nibble first, into `bits` bits. */
static unsigned bcd_pack(unsigned value, unsigned tensBits, unsigned onesBits,
                         unsigned *shift) {
    unsigned tens = (value / 10u) & ((1u << tensBits) - 1u);
    unsigned ones = (value % 10u) & ((1u << onesBits) - 1u);
    *shift -= tensBits;
    unsigned out = tens << *shift;
    *shift -= onesBits;
    out |= ones << *shift;
    return out;
}

static void mtu_fill_time(struct MtuModel *m) {
    double us = m->clockUs ? *m->clockUs : 0.0;
    if (us < 0.0) us = 0.0;
    unsigned long long totalMs = (unsigned long long)(us / 1000.0);

    unsigned ms   = (unsigned)(totalMs % 1000ull);
    unsigned long long totalSec = totalMs / 1000ull;
    unsigned sec  = (unsigned)(totalSec % 60ull);
    unsigned long long totalMin = totalSec / 60ull;
    unsigned min  = (unsigned)(totalMin % 60ull);
    unsigned long long totalHr = totalMin / 60ull;
    unsigned hr   = (unsigned)(totalHr % 24ull);
    unsigned days = (unsigned)((totalHr / 24ull) % 400ull);

    /* DAYS/HOURS: 2 bits day-hundreds, 4 day-tens, 4 day-units,
     * 2 hour-tens, 4 hour-units. */
    unsigned shift = 16, dyhr = 0;
    shift -= 2; dyhr |= ((days / 100u) & 0x3u) << shift;
    shift -= 4; dyhr |= (((days / 10u) % 10u) & 0xfu) << shift;
    shift -= 4; dyhr |= ((days % 10u) & 0xfu) << shift;
    shift -= 2; dyhr |= ((hr / 10u) & 0x3u) << shift;
    shift -= 4; dyhr |= ((hr % 10u) & 0xfu) << shift;

    /* MIN/SEC: 3 bits minute-tens, 4 minute-units, 3 second-tens,
     * 4 second-units, then two spare in the low bits. */
    unsigned s2 = 16, mnsc = 0;
    mnsc |= bcd_pack(min, 3, 4, &s2);
    mnsc |= bcd_pack(sec, 3, 4, &s2);

    /* MILLISECONDS in 0.125 ms units, thirteen bits. */
    unsigned msec = (ms * 8u) & 0x1fffu;

    /* TFMTU's three time halfwords sit at OFFSET 2 of the six-word
     * transfer, not at its start.  FPMMTURM says so itself:
     *     LA  R3,TFCMMTU1+2      POINT TO FIRST TIME READ
     *     LH  R4,TFCMMTU2+2      LOAD ACTUAL TIME FROM BUFF 2
     * The first two words are the unit's header, which this model leaves
     * zero. */
    memset(m->reply, 0, sizeof m->reply);
    m->reply[2] = (uint16_t)dyhr;
    m->reply[3] = (uint16_t)mnsc;
    m->reply[4] = (uint16_t)msec;
    m->replyHead = 0;
    m->replyCount = MTU_WORDS;
    m->reads++;
}

void mtumodel_service(void *ctx, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out) {
    struct MtuModel *m = (struct MtuModel *)ctx;
    if (!m || !in || !out) return;

    switch (svc) {
    case GPC_SVC_XMIT_CMD: {
        uint32_t cmd = in->in.word & 0x00ffffffu;
        m->commands++;
        /* YAGPC_MTUTRACE: every command reaching these buses, with the IUA
         * it names.  This is what showed the MTU is IUA 10 rather than the
         * device number 22 FIOCBLKS calls it. */
        if (getenv("YAGPC_MTUTRACE")) {
            static long n = 0;
            if (n++ < 40)
                fprintf(stderr, "MTUCMD t=%.3f bus=%d cmd=%06x iua=%u\n",
                        m->clockUs ? *m->clockUs / 1e6 : 0.0,
                        in->busID, (unsigned)cmd, (unsigned)CMD_IUA(cmd));
        }
        if (CMD_IUA(cmd) == MTU_IUA) mtu_fill_time(m);
        out->out.xmit.ok = true;
        break;
    }
    case GPC_SVC_XMIT_WORD:
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL:
        out->out.poll.available = (m->replyCount > 0);
        break;
    case GPC_SVC_RECV_WORD:
        if (m->replyCount > 0) {
            out->out.recv.available = true;
            out->out.recv.word = m->reply[m->replyHead++];
            m->replyCount--;
            m->wordsOut++;
        } else {
            out->out.recv.available = false;
            out->out.recv.word = 0;
        }
        break;
    default:
        break;
    }
}

void mtumodel_report(struct MtuModel *m) {
    if (!m) return;
    fprintf(stderr, "mtu: {\"commands\":%ld,\"timeReads\":%ld,\"wordsOut\":%ld,"
            "\"lastTime\":\"%04x %04x %04x\"}\n",
            m->commands, m->reads, m->wordsOut,
            m->reply[2], m->reply[3], m->reply[4]);
}
