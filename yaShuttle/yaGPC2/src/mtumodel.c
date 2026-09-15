#include "mtumodel.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "busword.h"

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
/* ...and IUA 10 is the FORWARD MDM, not the timing unit alone: FIONSPPG
 * reads NSP 1 and 2 through the same MDM at the same IUA ('#MINC FIOFFIUA,
 * FIONSP1P', FIONSPDR, FIONSP2P, FIONSPRD; FIOFFIUA EQU 10).  Only the
 * command's remaining 19 bits say which card and channel is meant, and the
 * timing unit is one of them -- FIOPRMPG's
 *
 *     FIOMTURD EQU X'00024C26'   MTU READ - MDM FF01 CARD=03 CHANNEL=01
 *
 * Treating every IUA-10 command as a timing-unit read refilled the reply,
 * and reset every reader, on each of the NSP's three commands; a listener
 * whose one-word NSP power-discrete read straddled a refill came up empty
 * while the others picked up timing-unit words, FIOERRLC counted an error
 * only that computer had, and at the second it failed itself out of the
 * redundant set (ledger #145: eve1 GPC2, eve3 GPC3, 'ERRTERM bce=20
 * pc=1cc2e left=1', FIONSPPG FIOBYNC3+4). */
#define MTU_READ_CMD   0x024C26u
#define MTU_BUS_FIRST  20
#define MTU_BUS_LAST   22

/* The command word's IUA field, the same extraction iop.c's mia_xmit_cmd
 * uses. */
#define CMD_IUA(c)     (((c) >> 19) & 0x1fu)
/* Everything below the IUA: the MDM card, channel and word count. */
#define CMD_FIELD(c)   ((c) & 0x7ffffu)

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
 * The extra word goes on the END, after GMT (0,1,2) and MET (3,4,5). */
#define MTU_WORDS 7

/* EVERY COMPUTER ON A BUS HEARS THE REPLY; NONE OF THEM USES IT UP.
 *
 * In a redundant set every member issues the same read: the one whose MIA
 * transmitter is enabled sends the command and the others listen
 * (FIOPRMPG's '#RDLI 6').  On the wire each receives its own copy of the
 * unit's words.  This model had one reply cursor, so a listener's receive
 * took the commander's words: the commander got a short read, FIOERRLC
 * counted an error that only it had, and at the second one it failed itself
 * out of the set (ledger #136).
 *
 * So each BUS keeps its own reply (the unit answers on the bus it was asked
 * on) and each READER -- GPC id 0-5, 0 for a caller that does not say --
 * its own cursor over it.  A listener is first handed the commander's
 * command word marked COMMAND SYNC, which a transmitter-disabled BCE in
 * Listen Mode waits for (busword.h).  The commander is not echoed, so a
 * single computer sees exactly what it saw before. */
#define MTU_READERS 6
#define MTU_NBUS (MTU_BUS_LAST - MTU_BUS_FIRST + 1)
struct MtuModel {
    const double *clockUs;
    const double *epochSec;      /* see mtumodel_set_epoch; NULL = elapsed only */
    const double *offsetUs;      /* see mtumodel_set_clock_offset */
    uint16_t reply[MTU_NBUS][MTU_WORDS];
    int head[MTU_NBUS][MTU_READERS], count[MTU_NBUS][MTU_READERS];
    bool echoPending[MTU_NBUS][MTU_READERS];
    uint32_t echoCmd[MTU_NBUS];
    int commander[MTU_NBUS];
    int lastBus;                 /* the bus last filled, for the report */
    long commands, reads, wordsOut, listenerWords;
};

struct MtuModel *mtumodel_create(void) {
    struct MtuModel *m = (struct MtuModel *)calloc(1, sizeof *m);
    return m;
}

void mtumodel_free(struct MtuModel *m) { free(m); }

void mtumodel_set_clock(struct MtuModel *m, const double *clockUs) {
    if (m) m->clockUs = clockUs;
}

void mtumodel_set_epoch(struct MtuModel *m, const double *epochSec) {
    if (m) m->epochSec = epochSec;
}

void mtumodel_set_clock_offset(struct MtuModel *m, const double *offsetUs) {
    if (m) m->offsetUs = offsetUs;
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

static void mtu_fill_time(struct MtuModel *m, int b) {
    double us = m->clockUs ? *m->clockUs : 0.0;
    if (us < 0.0) us = 0.0;
    unsigned ms, sec, min, hr, days;
    if (m->epochSec != NULL && *m->epochSec > 0.0) {
        /* THE TIME OF DAY, not seconds since start-up.  The unit is a clock:
         * PASS initialises GMT from it (FPMMTURM) and shows it on every
         * display's top line.  Reporting elapsed time made every session
         * begin on day 0 at whatever hour the run had reached.  Local time,
         * day of year counted from 001, as --date-time-epoch documents. */
        /* Plus the time the computer spent not running -- held in HALT
         * while the crew set up the IPL, most of all.  Without it PASS's
         * GMT ran behind the real time of day by exactly that long. */
        double t = *m->epochSec +
                   (us + (m->offsetUs != NULL ? *m->offsetUs : 0.0)) / 1e6;
        time_t whole = (time_t)floor(t);
        struct tm lt;
        localtime_r(&whole, &lt);
        ms = (unsigned)((t - (double)whole) * 1000.0) % 1000u;
        sec = (unsigned)lt.tm_sec % 60u;     /* a leap second reads as :59 */
        min = (unsigned)lt.tm_min;
        hr = (unsigned)lt.tm_hour;
        days = (unsigned)(lt.tm_yday + 1);
    } else {
        unsigned long long totalMs = (unsigned long long)(us / 1000.0);
        ms   = (unsigned)(totalMs % 1000ull);
        unsigned long long totalSec = totalMs / 1000ull;
        sec  = (unsigned)(totalSec % 60ull);
        unsigned long long totalMin = totalSec / 60ull;
        min  = (unsigned)(totalMin % 60ull);
        unsigned long long totalHr = totalMin / 60ull;
        hr   = (unsigned)(totalHr % 24ull);
        days = (unsigned)((totalHr / 24ull) % 400ull);
    }

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

    /* The six transferred halfwords are GMT at 0,1,2 and MET at 3,4,5 --
     * the buffer's very start, not offset 2.  FIOPRMPG's commander points
     * the buffer register AT the buffer (`#LBR TFCMMTU1`) and then reads
     * `#MIN 0,6`; DCD14201 takes `%COPY(DL(19),TFCMMTU1$(1:), 6)`; and
     * FPMMTURM walks the result from the base:
     *     LH  R2,0(R0)   GET GMT DAYS/HRS      (FPMLIMCK)
     *     LH  R2,1(R0)   GET GMT MIN/SEC
     *     LH  R2,3(R0)   GET MET DAYS/HRS
     *     AHI R0,3       POINT TO MET TIME
     * The `TFCMMTU1+2` this model was built on is the PCMMU branch (lines
     * 265-365), where +2 is the MILLISECONDS word, read repeatedly to
     * detect the PCMMU clock ticking -- not a header offset, and not the
     * MTU's own layout.
     *
     * MET is left zero: this simulator has no launch to count from, and
     * FPMLIMCK's MET tests have no lower bound (days < X'365', hours
     * <= X'23', min <= X'59', sec <= X'164'), so all-zero passes. */
    memset(m->reply[b], 0, sizeof m->reply[b]);
    m->reply[b][0] = (uint16_t)dyhr;
    m->reply[b][1] = (uint16_t)mnsc;
    m->reply[b][2] = (uint16_t)msec;
    for (int r = 0; r < MTU_READERS; r++) {
        m->head[b][r] = 0;
        m->count[b][r] = MTU_WORDS;
    }
    m->lastBus = b;
    m->reads++;
}

void mtumodel_service(void *ctx, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out) {
    mtumodel_service_as((struct MtuModel *)ctx, 0, svc, in, out);
}

void mtumodel_service_as(struct MtuModel *m, int gpcId, GpcServiceNumber svc,
                         const GpcServiceInput *in, GpcServiceOutput *out) {
    if (!m || !in || !out) return;
    int g = (gpcId >= 0 && gpcId < MTU_READERS) ? gpcId : 0;
    int b = in->busID - MTU_BUS_FIRST;
    if (b < 0 || b >= MTU_NBUS) b = 0;

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
        if (CMD_IUA(cmd) != MTU_IUA || CMD_FIELD(cmd) != MTU_READ_CMD) {
            /* A command for ANOTHER device on this bus -- the flight-critical
             * buses carry several, and only this one is modelled; a command
             * to another card or channel of the same MDM is another device
             * too (see MTU_READ_CMD).  That
             * device is absent, so nothing answers: every computer on the bus
             * gets the same silence.  Leaving this unit's last reply readable
             * handed seven stale words to 32-word receives meant for the
             * other device, which then timed out with seven taken -- and with
             * a cursor per computer, not necessarily the same seven for each
             * (ledger #137). */
            for (int r = 0; r < MTU_READERS; r++)
                m->count[b][r] = 0;
        } else {
            mtu_fill_time(m, b);
        }
        /* BUT THE COMMAND ITSELF IS ON THE WIRE, whoever it is for.  A
         * listener's Listen-Mode receive waits, with no time-out, for a
         * command at its own IUA (iop.c); echoing only the timing unit's read
         * left the NSP's listeners (FIONSPPG, IUA 10, buses 20 and 22) waiting
         * through every transfer, so the MSC's single look found them busy on
         * every computer -- thousands of FIOMSCTO a run -- and at the 12 s
         * phase where that look is decided differently on different
         * computers, one failed itself out of the set (ledger #145, eve13 and
         * eve15).  A command for another IUA, such as the listen command, is
         * ignored by a waiting listener, so echoing it costs nothing.  Only
         * named computers listen; reader 0 is a caller that does not say who
         * it is, which is the single-machine case. */
        m->commander[b] = g;
        m->echoCmd[b] = cmd;
        for (int r = 0; r < MTU_READERS; r++)
            m->echoPending[b][r] = (g >= 1 && r >= 1 && r != g);
        out->out.xmit.ok = true;
        break;
    }
    case GPC_SVC_XMIT_WORD:
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL:
        out->out.poll.available = m->echoPending[b][g] || (m->count[b][g] > 0);
        break;
    case GPC_SVC_RECV_WORD:
        if (m->echoPending[b][g]) {
            m->echoPending[b][g] = false;
            out->out.recv.available = true;
            out->out.recv.word = m->echoCmd[b] | YAGPC_BUSWORD_CMD_SYNC;
        } else if (m->count[b][g] > 0) {
            out->out.recv.available = true;
            out->out.recv.word = m->reply[b][m->head[b][g]++];
            m->count[b][g]--;
            if (g == m->commander[b] || g == 0) m->wordsOut++;
            else m->listenerWords++;
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
            m->reply[m->lastBus][0], m->reply[m->lastBus][1],
            m->reply[m->lastBus][2]);
    if (m->listenerWords > 0)
        fprintf(stderr, "mtu: %ld word(s) delivered to listening computers\n",
                m->listenerWords);
}
