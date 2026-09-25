#include "mtumodel.h"
#include "json.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "busword.h"

#include "envcache.h"
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
/* ALL EIGHT FLIGHT-CRITICAL BUSES.  The timing unit answers on three, but
 * the forward and aft MDMs this file also speaks for sit on all eight, and
 * coverage that stops short is WORSE than none: a computer listens on the
 * strings its peer commands, so answering only some buses leaves each machine
 * holding I/O errors its peer does not have, FIOGPCWE is 1, and FIOERRLC
 * self-fails it rather than commfaulting a string.  18 and 19 are mass
 * memory, whose device IS modelled, so they stay out and a time-out there
 * remains the real defect it is. */
#define MTU_BUS_FIRST  14
#define MTU_BUS_LAST   23

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

/* THE FORWARD MDM ANSWERS FOR THE NETWORK SIGNAL PROCESSOR, WHICH THIS
 * VEHICLE DOES NOT HAVE.
 *
 * IUA 10 is not the timing unit's own address: BCEEQU.asm has FIOFFIUA EQU
 * 10, "FF INTERFACE UNIT ADDRESS", and the timing unit is read THROUGH the
 * forward MDM -- "#MINC FIOFFIUA,FIOMTURD".  So this file has always been a
 * partial model of that MDM, answering one of its commands.  These are three
 * more of them, and they are the ones whose silence costs the timing unit.
 *
 * FIONSPPG reads the NSP through the same MDM: "#MIN 0,0 / #MINC
 * FIOFFIUA,FIONSP2P  READ NSP2 POWER DISCRETE", and the same for NSP1 and for
 * the two-stage 'A' discrete.  Measured with YAGPC_FC_LEARN over a whole
 * two-computer run to OPS 201, those single-word discrete reads are almost
 * the entire I/O failure on the flight-critical buses: func 132 ninety-three
 * times, func 138 ninety-three times, and 186 listener halves waiting for a
 * command that never came, against single digits for everything else.
 * FCMRTBLE is titled "NSP AND MTU RESTORE TABLES" and groups the two, so when
 * the NSP's errors cross FIOERRLC's threshold the timing unit is bypassed
 * with it -- which is why MTU ACCUM 1-3 freeze on SPEC 2 PRO.
 *
 * WHAT IS REPORTED IS TRUE: zero, the NSP is not powered.  That is not
 * invented telemetry and not a protocol lie.  The MDM is present -- it must
 * be, or the timing unit could not be read through it -- and it is saying
 * that the box behind it is off, which is a state the flight software is
 * built to handle.  A transfer that never completes is not: that is a dead
 * MDM, and FCOS responds by commfaulting the string.
 *
 * The lengths are the ones the BUS PROGRAM arms, not the count field of the
 * command: FIOMTURD's count field is 38 and its #MIN arms seven. */
#define FF_NSP1_PWR   0x132u    /* FIONSP1P, #MIN 0,0  -- one word  */
#define FF_NSP2_PWR   0x138u    /* FIONSP2P, #MIN 0,0  -- one word  */
#define FF_NSP_DISCR  0x128u    /* FIONSPDR, #MIN 1,0  -- one word  */
#define FF_NSP_DATA   0x136u    /* FIONSPRD, #MIN 0,31 -- 32 words  */
#define FF_REPLY_MAX  64
#define FF_FA_GENERIC 64

/* AND THE MDM'S OWN READS.  With the NSP answered, YAGPC_FC_LEARN's list of
 * unanswered transfers on the flight-critical buses fell from about 437 in a
 * run to 66, and what remained was the MDMs themselves at IUA 10 and 12: a
 * return word (func 18a, one word) and two channel reads (func 041 and 042),
 * eight of each.  Sixty-six is still well over FIOERRLC's threshold of two,
 * so the strings were still commfaulted and the timing unit still went with
 * them.
 *
 * The return word is protocol, and answering it is the same kind of statement
 * as the NSP discrete.  The channel reads are data, and zero is what an MDM
 * with nothing wired to its channels reads -- which is this vehicle.  The
 * lengths differ by unit, so the table is keyed by BOTH: func 041 is 21 words
 * at IUA 10 and 34 at IUA 12, func 042 is 4 and 6.  They come from the bus
 * programs' own #MIN, harvested rather than guessed. */

/* READS WHOSE LENGTH IS KNOWN EXACTLY, keyed on the WHOLE command word:
 * function 126 alone is the timing unit, the IMU, the rendezvous radar and
 * the STU, told apart only by the count field.  The lengths are what the bus
 * programs' #MIN and #RDLI arm, harvested with YAGPC_FC_LEARN and not
 * guessed -- the command's own count field is not the reply length,
 * FIOMTURD's is 38 and its #MIN arms seven. */
static const struct { uint32_t cmd; int words; } FF_MDM_READS[] = {
    { 0x5082c5u, 21 },   /* FF MDM (IUA 10) channel read */
    { 0x508543u,  4 },   /* FF MDM (IUA 10) channel read */
    { 0x531555u,  1 },   /* FF MDM (IUA 10) return word  */
    { 0x6082a5u, 34 },   /* FA MDM (IUA 12) channel read */
    { 0x608545u,  6 },   /* FA MDM (IUA 12) channel read */
    { 0x631555u,  1 },   /* FA MDM (IUA 12) return word  */
};

/* How many words this model answers the command with, or 0 if it does not
 * speak for it. */
static int ff_nsp_words(uint32_t cmd) {
    for (size_t i = 0; i < sizeof FF_MDM_READS / sizeof FF_MDM_READS[0]; i++)
        if (FF_MDM_READS[i].cmd == (cmd & 0xffffffu))
            return FF_MDM_READS[i].words;
    switch ((cmd >> 9) & 0x3ffu) {
    case FF_NSP1_PWR:  case FF_NSP2_PWR:  case FF_NSP_DISCR: return 1;
    case FF_NSP_DATA:  return 32;
    default: break;
    }
    /* ANYTHING ELSE ADDRESSED TO ONE OF THESE TWO UNITS.  Naming commands one
     * at a time does not converge: answering a batch lets the chains run
     * further and reveals the next, and six became seventeen in one round --
     * the IMU, the STU, the rendezvous radar and the PROM segments all
     * appearing behind the reads just answered.  They are reads of the same
     * two boxes, so this speaks for the BOX and not for a list of commands.
     *
     * NOT the listen command, and not any other unit.  FIOLMIUA is IUA 8 and
     * "#CMDI FIOLMIUA,..." is a broadcast that sets listeners up, not a read;
     * answering it puts words on the wire that the commander's own receive
     * then takes as its data, which wrecked the first attempt at this and
     * left the vehicle unable to leave OPS 0.
     *
     * The generous length is safe because every read here is preceded by that
     * listen command, and a command for another IUA clears every reader's
     * pending count, so nothing is left over when the next receive arms. */
    {
        unsigned iua = CMD_IUA(cmd);
        if (iua == MTU_IUA || iua == 12u) return FF_FA_GENERIC;
    }
    return 0;
}

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

/* AND EACH READER ITS OWN COPY OF THE WORDS, not only its own cursor.  With
 * one buffer per bus, a reply that arrived while another computer was partway
 * through the previous one handed that computer a MIXTURE of the two -- its
 * cursor pointed into words that had been overwritten.  Whether it happened
 * depended on when each machine polled, so the two saw different data and
 * disagreed, and the rate of it rose with the number of commands answered.
 * That is a divergence this model manufactured, and it is why answering more
 * of the forward MDM's functions used to cost the redundant set both
 * computers.  A refill now writes every reader's own copy and resets its own
 * cursor, so no computer can ever receive half of one reply and half of the
 * next. */
#define MTU_NBUS (MTU_BUS_LAST - MTU_BUS_FIRST + 1)
struct MtuModel {
    const double *clockUs;
    const double *epochSec;      /* see mtumodel_set_epoch; NULL = elapsed only */
    const double *offsetUs;      /* see mtumodel_set_clock_offset */
    uint16_t reply[MTU_NBUS][MTU_READERS][FF_REPLY_MAX];
    int head[MTU_NBUS][MTU_READERS], count[MTU_NBUS][MTU_READERS];
    bool echoPending[MTU_NBUS][MTU_READERS];
    uint32_t echoCmd[MTU_NBUS];
    int commander[MTU_NBUS];
    int lastBus;                 /* the bus last filled, for the report */
    long commands, reads, wordsOut, listenerWords, nspReads;
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
    if (busID == 18 || busID == 19) return false;      /* mass memory */
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
         * begin on day 0 at whatever hour the run had reached.
         *
         * AND IT IS GMT, NOT THE HOST'S LOCAL TIME.  The name in the flight
         * software is not decoration: the crew reads this as GMT and sets it
         * as GMT from SPEC 2 PRO, and nothing aboard an orbiter has a time
         * zone.  Local time put the vehicle's clock hours out, and could put
         * it on the wrong day of the year outright, since the day number
         * comes out of the same decomposition.  Day of year counted from
         * 001, as --date-time-epoch documents. */
        /* Plus the time the computer spent not running -- held in HALT
         * while the crew set up the IPL, most of all.  Without it PASS's
         * GMT ran behind the real time of day by exactly that long. */
        double t = *m->epochSec +
                   (us + (m->offsetUs != NULL ? *m->offsetUs : 0.0)) / 1e6;
        time_t whole = (time_t)floor(t);
        struct tm lt;
        gmtime_r(&whole, &lt);
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
    for (int r = 0; r < MTU_READERS; r++) {
        m->reply[b][r][0] = (uint16_t)dyhr;
        m->reply[b][r][1] = (uint16_t)mnsc;
        m->reply[b][r][2] = (uint16_t)msec;
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
        {
            /* YAGPC_MTUTRACE=<n> traces that many commands; any non-numeric
             * value traces all of them.  The cap was a hard 40, which is
             * thirty milliseconds of a flight-critical bus -- enough to show
             * WHICH devices share it, which is what it was written for, and
             * useless for asking whether a particular command ever comes
             * again.  Same convention as YAGPC_SSTTRACE. */
            static int inited = 0;
            static long cap = 40;
            static long n = 0;
            const char *w = yagpc_getenv("YAGPC_MTUTRACE");
            if (!inited) {
                inited = 1;
                if (w != NULL) {
                    char *end = NULL;
                    long v = strtol(w, &end, 10);
                    cap = (end != w && *end == '\0' && v > 0) ? v : -1;
                }
            }
            if (w != NULL && (cap < 0 || n++ < cap))
                fprintf(stderr, "MTUCMD t=%.3f bus=%d cmd=%06x iua=%u func=%03x words=%u\n",
                        m->clockUs ? *m->clockUs / 1e6 : 0.0,
                        in->busID, (unsigned)cmd, (unsigned)CMD_IUA(cmd),
                        (unsigned)((cmd >> 9) & 0x3ffu), (unsigned)((cmd & 0x1ffu) + 1u));
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
            unsigned cu = CMD_IUA(cmd);
            int nsp = (cu == MTU_IUA || cu == 12u) ? ff_nsp_words(cmd) : 0;
            if (nsp > 0) {
                /* The NSP is not powered: zero, the same word to every
                 * computer on the bus, through the same per-reader path the
                 * timing unit's own reply uses. */
                memset(m->reply[b], 0, sizeof m->reply[b]);
                for (int r = 0; r < MTU_READERS; r++) {
                    m->head[b][r] = 0;
                    m->count[b][r] = nsp;
                }
                m->nspReads++;
            } else {
                for (int r = 0; r < MTU_READERS; r++)
                    m->count[b][r] = 0;
            }
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
            out->out.recv.word = m->reply[b][g][m->head[b][g]++];
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
            m->reply[m->lastBus][0][0], m->reply[m->lastBus][0][1],
            m->reply[m->lastBus][0][2]);
    if (m->nspReads > 0)
        fprintf(stderr, "mtu: %ld NSP read(s) answered by the forward MDM "
                        "(the NSP is not powered in this vehicle)\n", m->nspReads);
    if (m->listenerWords > 0)
        fprintf(stderr, "mtu: %ld word(s) delivered to listening computers\n",
                m->listenerWords);
}

/* ---------------------------------------------------------------------
 * CAPTURE AND RESTORE -- see mtumodel.h.
 * ------------------------------------------------------------------- */

bool mtumodel_dump(const struct MtuModel *m, const char *path) {
    if (m == NULL || path == NULL) return false;
    FILE *f = fopen(path, "w");
    if (f == NULL) {
        fprintf(stderr, "mtu: cannot write %s\n", path);
        return false;
    }
    fprintf(f, "{\n  \"buses\": [\n");
    for (int b = 0; b < MTU_NBUS; b++) {
        fprintf(f, "%s    {\"bus\": %d, \"commander\": %d, \"echoCmd\": %u,\n",
                b ? ",\n" : "", MTU_BUS_FIRST + b, m->commander[b],
                (unsigned)m->echoCmd[b]);
        fprintf(f, "     \"reply\": [");
        for (int w = 0; w < MTU_WORDS; w++)
            fprintf(f, "%s%u", w ? "," : "", (unsigned)m->reply[b][0][w]);
        fprintf(f, "],\n     \"readers\": [");
        for (int r = 0; r < MTU_READERS; r++)
            fprintf(f, "%s[%d,%d,%d]", r ? "," : "",
                    m->head[b][r], m->count[b][r],
                    m->echoPending[b][r] ? 1 : 0);
        fprintf(f, "]}");
    }
    fprintf(f, "\n  ],\n  \"lastBus\": %d\n}\n", m->lastBus);
    if (fclose(f) != 0) {
        fprintf(stderr, "mtu: cannot finish %s\n", path);
        return false;
    }
    return true;
}

bool mtumodel_load(struct MtuModel *m, const char *path) {
    if (m == NULL || path == NULL) return false;
    FILE *f = fopen(path, "rb");
    if (f == NULL) return false;          /* a capture from before this */
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return false; }
    long n = ftell(f);
    if (n < 0 || fseek(f, 0, SEEK_SET) != 0) { fclose(f); return false; }
    char *text = (char *)malloc((size_t)n + 1);
    if (text == NULL || fread(text, 1, (size_t)n, f) != (size_t)n) {
        free(text); fclose(f);
        fprintf(stderr, "mtu: cannot read %s\n", path);
        return false;
    }
    text[n] = '\0';
    fclose(f);
    JsonValue *root = json_parse(text);
    free(text);
    if (root == NULL) {
        fprintf(stderr, "mtu: %s is not JSON\n", path);
        return false;
    }
    JsonValue *buses = json_obj_get(root, "buses");
    for (int i = 0; i < json_arr_count(buses); i++) {
        JsonValue *bv = json_arr_get(buses, i);
        int bus = (int)json_as_number(json_obj_get(bv, "bus"), -1);
        int b = bus - MTU_BUS_FIRST;
        if (b < 0 || b >= MTU_NBUS) continue;
        m->commander[b] = (int)json_as_number(json_obj_get(bv, "commander"), 0);
        m->echoCmd[b] = (uint32_t)json_as_number(json_obj_get(bv, "echoCmd"), 0);
        JsonValue *rep = json_obj_get(bv, "reply");
        /* One saved reply, restored to every reader: a capture is taken with
         * the vehicle quiet, so the copies agree. */
        for (int w = 0; w < MTU_WORDS && w < json_arr_count(rep); w++) {
            uint16_t v = (uint16_t)json_as_number(json_arr_get(rep, w), 0);
            for (int r = 0; r < MTU_READERS; r++) m->reply[b][r][w] = v;
        }
        JsonValue *rs = json_obj_get(bv, "readers");
        for (int r = 0; r < MTU_READERS && r < json_arr_count(rs); r++) {
            JsonValue *e = json_arr_get(rs, r);
            m->head[b][r] = (int)json_as_number(json_arr_get(e, 0), 0);
            m->count[b][r] = (int)json_as_number(json_arr_get(e, 1), 0);
            m->echoPending[b][r] =
                json_as_number(json_arr_get(e, 2), 0) != 0;
        }
    }
    m->lastBus = (int)json_as_number(json_obj_get(root, "lastBus"), m->lastBus);
    json_free(root);
    fprintf(stderr, "mtu: pending replies restored\n");
    return true;
}
