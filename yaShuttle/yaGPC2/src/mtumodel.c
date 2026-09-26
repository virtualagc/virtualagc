#include "mtumodel.h"
#include "json.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "busword.h"
/* The bus programs' own (command, length) pairs and command names; see
 * fc-bus-survey.py.  Used to NAME what goes past and to check the run-time
 * armed count against what the flight source says, never as the answer. */
#include "fcbustable.h"

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

/* One word time on the serial bus, as mmumodel.c has it -- the same wire. */
#define MTU_BUS_WORD_US 33.0

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

/* BITE TEST 4: THE ONE MDM READ WHOSE ANSWER MAY NOT BE ZERO.
 *
 * Every other channel of an MDM with nothing wired to it reads zero, and that
 * is a true statement about this vehicle.  These four words are not a channel
 * reading -- they are the A/D converter measuring its OWN reference voltages.
 * FPMIHPC2 forms REF = RW1 - RW2/2 over the two words of each channel, keeps
 * the top five bits (NHI R6,X'F800'), and compares with FIOCDATG's table:
 *
 *   * MASKS FOR MDM A/D BITE RM REFERENCE VOLTAGE COMPARISONS
 *   * WHERE:  - 2 REF = 1100 1XXX XXXX XXXX / + 2 REF = 0011 0XXX XXXX XXXX
 *   FIOREFVT EQU *-1 / DC X'C800' MINUS 2 VOLT / DC X'3000' PLUS 2 VOLT
 *
 * THE ENCODING.  No scaling is documented in the flight software, but the
 * hardware manual gives the range and that is enough to pin it down.  JSC-
 * 12770 Vol. 5 (Shuttle Flight Operations Manual, Data Processing System,
 * 1978-11, pdf p.32) on the MDM: the "analog input module conditions +5.11
 * Vdc to -5.12 Vdc analog inputs ... for digital conversion by A/D", and the
 * analog OUTPUT module "converts 10-bit digital commands into +5.11 Vdc to
 * -5.12 Vdc analog outputs".
 *
 * +5.11 against -5.12 is the signature of a TWO'S COMPLEMENT field: one more
 * step below zero than above it.  Full scale is 5.12 V, and the reading is
 * LEFT-JUSTIFIED in the halfword, so a voltage is a signed fraction of full
 * scale:
 *
 *     2.00 / 5.12 = 0.390625;  0.390625 x 32768 = 12800 = 0x3200
 *                              and its negation        = 0xCE00
 *
 * and the five bits the comparison keeps are 00110 and 11001 -- FIOREFVT's
 * two masks, exactly.  Right-justifying instead gives 00000 for +2 V, so
 * left-justified it is.
 *
 * WHAT THIS DOES *NOT* ESTABLISH, and must not be read as establishing: the
 * A/D's RESOLUTION.  JSC-12770 gives a bit count for the analog OUTPUT module
 * only, and A/D and D/A were different technologies at the time with
 * different achievable resolutions -- there is no reason to assume the
 * converter matched the 10 bits of the D/A, even if encoding both the same
 * way would have been sensible.  It does not matter here: a left-justified
 * reading has the same high bits whatever its resolution, resolution changes
 * only what lies below, and everything below the top five bits is discarded
 * before the comparison.  So the values this model returns are right for an
 * A/D of any width.
 *
 * (The masks are also one's complements of each other, which is a real
 * coincidence rather than the format: 11001 is 824 >> 5, truncating toward
 * zero, where a five-bit negation of 00110 would give 11010.)
 *
 * So `NHI X'F800'` is not a tolerance; it keeps the top five bits of a
 * ten-bit reading and discards the rest, and the comparison is exact on
 * those five -- a window of 32 counts, 0.32 V, about the nominal.
 *
 * WHICH IS WHY ZEROS WERE FATAL.  Zero is not neutral filler on these four
 * words -- it is a reading, and it says the reference sits at 0 V, which for
 * a +-2 V reference is a dead converter.  That is what this model told PASS
 * about every forward and aft MDM, and PASS did what it is built to do:
 * counted card failures and, at two per card, stored stopping instructions
 * into the MFE and HFE bus programs to comfault that unit's PROM reads
 * (FPMIHPC2, `ZH@# 0(R7,R2)  STORE ZERO INSTR IN BCE PROGRAM`).  Measured:
 * 115,128 such stores in one five-computer run.
 *
 * The first word of each channel is therefore the NOMINAL reading for its
 * reference -- +-2.00 V as a left-justified signed fraction -- and the second
 * a zero offset,
 * so REF reduces to the reading itself.  (The second word cannot be another
 * reading of the same reference: two conversions of +2 V would give
 * REF = 0x3200 - 0x1900 = 0x1900, top five bits 00011, which fails.)  Both
 * bus programs arm exactly four words for this
 * (FIOHFEPG "#MIN 0,3 ... 2 WDS FROM CH 12, 2 WDS FROM CH 13", FIOMFEPG
 * "CHANS 15 & 16, READ 4 RESPONSE WORDS"), so four is the length. */
#define FF_BITE_WORDS 4
static const uint16_t FF_BITE_REPLY[FF_BITE_WORDS] = {
    0x3200u, 0x0000u,     /* channel A: +2.00 V of 5.12 V full scale, no offset */
    0xCE00u, 0x0000u,     /* channel B: -2.00 V of 5.12 V full scale, no offset */
};

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
/* The BITE 4 commands, by the names BCEEQU gives them; the bus program
 * prepends the interface unit address (FIOFFIUA 10, FIOFAIUA 12):
 *     FIOBFC01 X'0001C581'   FIOBFC14 X'0001F981'   (forward)
 *     FIOBAC06 X'0001D9E1'   FIOBAC14 X'0001F9E1'   (aft)
 * A four-word read of either unit is this test whatever a build calls it;
 * the names carry the ones that can be proved. */
static bool ff_bite4_named(uint32_t cmd) {
    static const uint32_t NAMED[] = {
        (10u << 19) | 0x1C581u, (10u << 19) | 0x1F981u,
        (12u << 19) | 0x1D9E1u, (12u << 19) | 0x1F9E1u,
    };
    for (size_t i = 0; i < sizeof NAMED / sizeof NAMED[0]; i++)
        if (NAMED[i] == (cmd & 0xffffffu)) return true;
    return false;
}

/* What the bus programs call this command, and how long they arm for it.
 * NULL/-1 when the survey has never seen it. */
static const char *fc_sym(uint32_t cmd, int *words) {
    cmd &= 0xffffffu;
    for (size_t i = 0; i < sizeof FC_BUS_READS / sizeof FC_BUS_READS[0]; i++)
        if (FC_BUS_READS[i].cmd == cmd) {
            if (words) *words = FC_BUS_READS[i].words;
            return FC_BUS_READS[i].sym;
        }
    for (size_t i = 0; i < sizeof FC_BUS_COMMANDS / sizeof FC_BUS_COMMANDS[0]; i++)
        if (FC_BUS_COMMANDS[i].cmd == cmd) {
            if (words) *words = 0;      /* a command, not a read */
            return FC_BUS_COMMANDS[i].sym;
        }
    if (words) *words = -1;
    return NULL;
}

/* YAGPC_FC_CHECK: where the length the commander armed for differs from the
 * one the flight source arms in its bus program.  They should agree, and a
 * disagreement means either that this build's equates differ from the surveyed
 * tree or that the run-time count is being read at the wrong moment -- both
 * worth knowing and neither visible any other way. */
static void fc_check(uint32_t cmd, int armed) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_FC_CHECK") != NULL; }
    if (!on || armed < 0) return;
    int want = -1;
    const char *sym = fc_sym(cmd, &want);
    if (sym == NULL || want < 0 || want == armed) return;
    static long said = 0;
    if (said++ < 40)
        fprintf(stderr, "mtu: FCCHECK cmd=%06x %-9s armed %d, bus program arms %d\n",
                (unsigned)(cmd & 0xffffffu), sym, armed, want);
}

/* WHICH READS THIS VEHICLE CAN HONESTLY ANSWER, by the names the bus programs
 * give them (fc-bus-survey.py).
 *
 * The old rule was "anything addressed to IUA 10 or 12", which answered for
 * every box reached THROUGH the forward and aft MDMs as well as for the MDMs
 * themselves -- the inertial measurement units, the GPS receiver, the payload
 * signal processor.  Answering those with zeros says "the box is there and
 * reading zero", which is the same lie as telling PASS an A/D converter's
 * reference sits at 0 V, and that lie cost this project a day.  A read we
 * cannot speak for is better left unanswered: every computer then fails it
 * together, which commfaults the string -- a universal condition the flight
 * software is built for -- instead of some computers succeeding and others
 * not, which is what breaks a redundant set.
 *
 * So:
 *   FIOMTURD            the timing unit itself, answered with the time.
 *   FIOBFC01/14,        the MDM's own A/D BITE 4 reference voltages, which
 *   FIOBAC06/14         must not be zero -- see FF_BITE_REPLY.
 *   FIOMDMRT            the MDM's return word: protocol, one word.
 *   FIOHI1Cn, FIOFFICn, the MDMs' own channel reads.  Zero here is TRUE: it
 *   FIOFAICn, FIOINP0n  is what a channel with nothing wired to it reads, and
 *                       this vehicle has nothing wired to them.
 *   FIONSP1P/2P/DR/RD   the network signal processor, which this vehicle does
 *                       not have and which reports itself unpowered -- a
 *                       state the flight software is built to handle.
 *
 * Everything else at those addresses is a box we do not model, and is left to
 * time out exactly as it did before any of this. */
static bool fc_ours(const char *sym) {
    static const char *const EXACT[] = {
        "FIOMTURD", "FIOMDMRT",
        "FIOBFC01", "FIOBFC14", "FIOBAC06", "FIOBAC14",
        "FIONSP1P", "FIONSP2P", "FIONSPDR", "FIONSPRD",
    };
    static const char *const PREFIX[] = { "FIOHI1C", "FIOFFIC", "FIOFAIC", "FIOINP" };
    for (size_t i = 0; i < sizeof EXACT / sizeof EXACT[0]; i++)
        if (strcmp(sym, EXACT[i]) == 0) return true;
    for (size_t i = 0; i < sizeof PREFIX / sizeof PREFIX[0]; i++)
        if (strncmp(sym, PREFIX[i], strlen(PREFIX[i])) == 0) return true;
    return false;
}

static bool ff_is_bite4(uint32_t cmd, int words) {
    (void)words;
    return ff_bite4_named(cmd);
}

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
/* OFF UNTIL A FIVE-COMPUTER ACID TEST CLEARS IT.  YAGPC_FC_MDM turns the
 * forward and aft MDMs on.
 *
 * It does fix the timing unit -- measured twice on a two-computer OPS 201
 * vehicle, six bypasses to none and the unit read for the whole run instead
 * of stopping at t=253 -- and on that fixture it costs no votes.  But the
 * owner's five-computer acid test, which looked well before this work, now
 * loses the whole redundant set four seconds after the OPS 901 transition:
 * GPC1 to GPC4 all self-fail at once (the CAM diagonal 11, 22, 33, 44) and
 * GPC5, which runs PASS as a stand-in for BFS and so is in the common set,
 * votes against 1, 2 and 3.  Whether this is the cause has NOT been
 * established -- the acid-test measurements taken so far were made with the
 * switch broken, so both arms ran the same binary -- and until it has, the
 * default must not be the thing that breaks a vehicle that was working. */
static bool ff_mdm_off(void) {
    static int inited = 0, off = 0;
    if (!inited) { inited = 1; off = yagpc_getenv("YAGPC_FC_MDM") == NULL; }
    return off != 0;
}

static int ff_nsp_words(uint32_t cmd, int m_armed) {
    if (ff_mdm_off()) return 0;
    for (size_t i = 0; i < sizeof FF_MDM_READS / sizeof FF_MDM_READS[0]; i++)
        if (FF_MDM_READS[i].cmd == (cmd & 0xffffffu))
            return FF_MDM_READS[i].words;
    /* THE FUNCTION-CODE SWITCH THAT USED TO BE HERE IS GONE.  It matched on
     * (cmd >> 9) & 0x3ff, which is coarser than a command: FIOGPSRD and
     * FIONSPRD share a function code, so answering "the NSP's data read" by
     * function also answered the GPS receiver -- a box this vehicle does not
     * have -- with thirty-two words of zero.  Measured directly.  The survey
     * names all four NSP reads (FIONSP1P, FIONSP2P, FIONSPDR, FIONSPRD) and
     * gives each its own length, so the coarse test has nothing left to do
     * and one thing it got wrong. */
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
    if (ff_bite4_named(cmd)) return FF_BITE_WORDS;
    {
        unsigned iua = CMD_IUA(cmd);
        if (iua != MTU_IUA && iua != 12u) return 0;
        /* BY NAME.  A read the survey has never seen, or one that belongs to
         * a box this vehicle does not have, is not ours to answer. */
        int surveyed = -1;
        const char *sym = fc_sym(cmd, &surveyed);
        if (sym == NULL || surveyed == 0 || !fc_ours(sym)) return 0;
        /* THE LENGTH THE COMMANDER ARMED FOR, not a guess.  This used to
         * return sixty-four for anything unrecognised -- "generous", because
         * the true length was believed unknowable here.  It is not: a bus
         * program arms its receive before it issues the command, so the count
         * is in the BCE (iop_bce_armed_words).  Answering exactly that means
         * nothing is ever left over for the next transfer and nothing ever
         * falls short.
         *
         * AND NO RECEIVE ARMED MEANS NO ANSWER.  A '#CMDI' that only sets a
         * listener's IUAR is not a read, and neither is the deliberately-bad
         * one PASS branches to in order to stop a BCE -- FIOHFEPG: "THE
         * INSTRUCTIONS ARE LEGAL BUT WILL CAUSE AN INITIAL TIMEOUT I/O ERROR
         * WHICH WILL STOP THE BCE".  Answering by IUA alone answered both and
         * so defeated the flight software's own isolation. */
        fc_check(cmd, m_armed);
        /* THE LENGTH THE COMMANDER ARMED FOR, with the bus program's own as
         * the fallback for the moment a listener asks before any commander on
         * this machine has.  No receive armed and nothing surveyed means this
         * is not a read at all -- a '#CMDI' that only sets a listener's IUAR,
         * or the deliberately-bad one PASS uses to stop a BCE. */
        int n = (m_armed >= 0) ? m_armed : surveyed;
        if (n <= 0) return 0;
        return (n > FF_REPLY_MAX) ? FF_REPLY_MAX : n;
    }
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
    /* The vehicle's shared clock as of this call, or negative when there is
     * none -- see mtumodel_set_shared_us.  ONE oscillator for all three
     * accumulators; the calling computer's own clock is not one. */
    double sharedUs;
    /* And the time base latched the first time this unit is read, so that the
     * per-computer HALT offset of whoever happened to ask first does not make
     * accumulator 1 and accumulator 2 disagree by it ever after. */
    double baseUs;
    bool haveBase;
    /* Words the commanding BCE armed for, -1 for none; see
     * mtumodel_set_armed_words.  A generic reply is exactly this long, so
     * nothing is left over and nothing falls short. */
    int armedWords;
    uint16_t reply[MTU_NBUS][MTU_READERS][FF_REPLY_MAX];
    int head[MTU_NBUS][MTU_READERS], count[MTU_NBUS][MTU_READERS];
    int mdm[MTU_NBUS][MTU_READERS];   /* pending zero words; see the note */
    /* THE FOUR BITE WORDS THAT ARE NOT ZERO, kept apart from `reply` for the
     * same reason `mdm` is: the timing unit's words and an MDM's share these
     * buses, and writing one into the other's buffer is what made a commander
     * and a listener disagree about the clock. */
    uint16_t bite[MTU_NBUS][MTU_READERS][FF_BITE_WORDS];
    int biteLeft[MTU_NBUS][MTU_READERS];
    bool echoPending[MTU_NBUS][MTU_READERS];
    uint32_t echoCmd[MTU_NBUS];
    /* WHEN THIS TRANSACTION WENT ON THE WIRE, on the VEHICLE'S shared clock --
     * see GPC_SVC_RECV_POLL.  Negative when there is no shared clock, where it
     * does not matter because there is nobody to agree with. */
    double wireUs[MTU_NBUS];
    int commander[MTU_NBUS];
    int lastBus;                 /* the bus last filled, for the report */
    long commands, reads, wordsOut, listenerWords, nspReads, biteReads;
};

struct MtuModel *mtumodel_create(void) {
    struct MtuModel *m = (struct MtuModel *)calloc(1, sizeof *m);
    if (m != NULL) m->armedWords = -1;
    /* NEGATIVE MEANS "NO SHARED CLOCK", and calloc gives zero -- which is a
     * perfectly good shared time meaning "the start of the run", so a unit
     * nobody had told about the vehicle would report that time for ever. */
    if (m != NULL) {
        m->sharedUs = -1.0;
        for (int b = 0; b < MTU_NBUS; b++) m->wireUs[b] = -1.0;
    }
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

void mtumodel_set_shared_us(struct MtuModel *m, double sharedUs) {
    if (m) m->sharedUs = sharedUs;
}

void mtumodel_set_armed_words(struct MtuModel *m, int words) {
    if (m) m->armedWords = words;
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

/* YAGPC_MTU_SKEW=<seconds>: report a time deliberately WRONG by that much.
 *
 * It answers a question the display cannot: whether PASS is really taking the
 * unit's reading into MTU ACCUM 1-3, or merely back-filling those fields from
 * the GPC's own clock.  On a healthy vehicle the accumulators and GPC time
 * agree to the millisecond, which is what you would see EITHER way -- so skew
 * the unit by a few seconds and look again.  Accumulators that move with the
 * skew are reading the unit; accumulators that stay with GPC time never were.
 *
 * Diagnostic only.  It makes the vehicle's clock wrong on purpose. */
static double mtu_skew_us(const struct MtuModel *m) {
    static int inited = 0;
    static double skew = 0.0, after = 0.0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MTU_SKEW");
        if (e != NULL) skew = atof(e) * 1.0e6;
        /* YAGPC_MTU_SKEW_AT=<seconds>: hold the skew off until then.
         *
         * WHY IT IS NEEDED.  PASS sets its OWN clock from this unit at
         * start-up -- AIBGPCLO reads it twice and calls TIME_MGT(INIT_CLK) --
         * so a skew applied from the beginning moves the GPC's clock along
         * with the accumulators and the two still agree.  Measured: a +1 h
         * skew put BOTH at 02:02, proving the unit is read and believed at
         * initialisation, and proving nothing about where the accumulator
         * fields come from afterwards.  Skewing only AFTER the clock is set
         * separates them: accumulators that jump are read from the unit,
         * accumulators that stay with GPC time are filled from the GPC. */
        const char *a = yagpc_getenv("YAGPC_MTU_SKEW_AT");
        if (a != NULL) after = atof(a) * 1.0e6;
    }
    if (skew == 0.0) return 0.0;
    double now = (m != NULL && m->sharedUs >= 0.0)
                 ? m->sharedUs : (m && m->clockUs ? *m->clockUs : 0.0);
    return (now >= after) ? skew : 0.0;
}

static void mtu_fill_time(struct MtuModel *m, int b) {
    /* THE UNIT'S OWN TIME, from the vehicle's shared clock where there is one
     * -- see mtumodel_set_shared_us.  Falling back to the caller's clock is
     * right for a single machine, where the two are the same thing. */
    /* TWO QUANTITIES, NOT ONE.  'us' drives the mission accumulators and
     * 'epochUs' the GMT the unit reports, and they are NOT the same: the
     * halt offset is time the computer spent stopped, which belongs in the
     * wall clock and not in an accumulator that counts only while running.
     * Folding it into both -- which an earlier draft of this did -- moves
     * every accumulator in the DEFAULT build, so the two are kept apart. */
    double us, epochUs;
    if (!ff_mdm_off() && m->sharedUs >= 0.0) {
        if (!m->haveBase) {
            /* Latch the offset ONCE.  It exists so the unit's time of day
             * includes the time a computer spent held in HALT, which the unit
             * itself ran through -- but each computer has its own, and taking
             * the caller's every time would give each accumulator a different
             * one.  A box has one time base. */
            m->baseUs = (m->offsetUs != NULL) ? *m->offsetUs : 0.0;
            m->haveBase = true;
        }
        us = m->sharedUs + m->baseUs;
        epochUs = us;
    } else {
        us = m->clockUs ? *m->clockUs : 0.0;
        epochUs = us + ((m->offsetUs != NULL) ? *m->offsetUs : 0.0);
    }
    double skewUs = mtu_skew_us(m);  /* diagnostic; see mtu_skew_us */
    us += skewUs;
    epochUs += skewUs;
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
        double t = *m->epochSec + epochUs / 1e6;
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
        m->mdm[b][r] = 0;            /* this transaction is the unit's own */
        m->biteLeft[b][r] = 0;
    }
    m->lastBus = b;
    m->reads++;
}

void mtumodel_service(void *ctx, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out) {
    /* An unnamed caller is a single machine, which has no shared clock and
     * whose own clock is the vehicle's. */
    struct MtuModel *m = (struct MtuModel *)ctx;
    if (m != NULL) m->sharedUs = -1.0;
    mtumodel_service_as(m, 0, svc, in, out);
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
        /* WHETHER EACH READER IS STILL DRAINING, ASKED BEFORE THIS COMMAND'S
         * REPLY IS BUILT.  The test below used to be made afterwards, and
         * building the timing unit's reply sets every reader's count to seven
         * -- so the condition was false for every listener on every MTU read
         * and NO listener was ever echoed one.  A Listen-Mode BCE discards
         * every word until it sees a command sync bearing its own IUA and
         * waits for it indefinitely (iop.c, BCE PoO 4.1), so every listener
         * threw the time away and waited for a command that never came, while
         * the commander read the unit perfectly.  Verified by direct call:
         * GPC2 and GPC3 took seven words and ZERO command syncs. */
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
            int nsp = (cu == MTU_IUA || cu == 12u)
                          ? ff_nsp_words(cmd, m->armedWords) : 0;
            /* THE MDM'S ANSWER LIVES APART FROM THE TIMING UNIT'S REPLY.  It
             * used to be written into `reply`, so an MDM read on one of these
             * buses memset the time words the unit had just put there -- and
             * a commander and a listener drain at different moments, so one
             * computer got the time and another got zeros.  Two computers
             * that disagree about the clock self-fail, which is exactly what
             * a five-computer acid test did four seconds after its OPS 901
             * transition, every member lighting its own diagonal cell.  The
             * answer is all zeros, so it needs a COUNT and no buffer.  The
             * unit's words are still DROPPED for a command that is not its
             * own, as they always were (ledger #137), but never overwritten. */
            bool bite = (nsp > 0 && ff_is_bite4(cmd, nsp));
            for (int r = 0; r < MTU_READERS; r++) {
                m->count[b][r] = 0;
                m->biteLeft[b][r] = 0;
                m->mdm[b][r] = nsp;
                if (bite) {
                    /* The converter's own reference readings lead the reply;
                     * see FF_BITE_REPLY for why they may not be zero. */
                    memcpy(m->bite[b][r], FF_BITE_REPLY, sizeof FF_BITE_REPLY);
                    m->biteLeft[b][r] = FF_BITE_WORDS;
                    m->mdm[b][r] = (nsp > FF_BITE_WORDS) ? nsp - FF_BITE_WORDS : 0;
                }
            }
            if (nsp > 0) m->nspReads++;
            if (bite) m->biteReads++;
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
        m->wireUs[b] = m->sharedUs;      /* this transaction's place in time */
        for (int r = 0; r < MTU_READERS; r++)
            /* NOT TO A READER THAT IS STILL TAKING THE LAST REPLY.  A
             * command-sync word arriving in the middle of a receive is Table
             * 1.2's Sync Error, and that is precisely what a listener gets
             * when the commander's next command is echoed to it before it has
             * drained the words from the previous one.  Measured: with the
             * flight-critical reads answered, EVERY error left on a
             * two-computer vehicle was one of these -- GPC1 on buses 15, 17
             * and 23, GPC2 on 14 and 16, two apiece, on exactly the buses the
             * other computer commands, and two is FIOERRLC's threshold.  Each
             * computer therefore held errors its peer did not, FIOGPCWE was 1
             * and the set broke.  A listener that is behind keeps its data and
             * simply does not see this command, which is what a real one
             * would do: it is still receiving. */
            /* CLEAR ALWAYS, ECHO ALWAYS -- bcenet_framer.c's rule on every
             * network bus, and the only listener delivery in this tree that
             * demonstrably works across several computers:
             *     ob->recvHead = ob->recvCount = 0;        (clear what they had)
             *     queue_push(ob, busID, &marked, 1, true); (then the command)
             * A new command ends the last transaction on the wire, so whatever
             * a listener had not taken is gone and it begins this one at the
             * command word -- with NO test of whether it was busy.
             *
             * Five designs here made that test conditional and all five
             * failed, two ways that are really one: withholding the echo from
             * a reader that still held words LATCHED it -- a Listen-Mode BCE
             * stores nothing until it sees a command sync bearing its own IUA,
             * so it could never drain, so it was draining for ever (proved: 0
             * echoes in ten reads against 10 with this rule) -- and not
             * clearing, to protect a part-taken transfer, buried it in a queue
             * to wade through (158,169 runaway BCE lines).  A listener that
             * loses the tail of one transfer loses one; a latched one loses
             * all of them. */
            /* WITH THE ANSWERING OFF, EXACTLY AS BEFORE.  Everything in this
             * model beyond the timing unit's own reply is part of the MDM
             * answering, which is experimental and off by default -- and the
             * default configuration is one the owner has validated clean over
             * an hour.  Measured 2026-09-25: leaving the new echo rule, the
             * wire pacing and the shared clock active with the answering OFF
             * cost that configuration four fail votes at t=1914 where it had
             * none.  A correctness fix that perturbs a validated build is
             * still a regression, so it travels with the switch. */
            m->echoPending[b][r] = ff_mdm_off()
                ? (g >= 1 && r >= 1 && r != g && m->count[b][r] == 0)
                : (g >= 1 && r >= 1 && r != g);
        out->out.xmit.ok = true;
        break;
    }
    case GPC_SVC_XMIT_WORD:
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL:
        /* A WORD IS NOT AVAILABLE UNTIL IT HAS HAD TIME TO GET HERE, measured
         * on the vehicle's shared clock.
         *
         * THIS IS WHAT MAKES ANSWERING SAFE AT ALL.  A read nobody answers
         * takes the SAME time on every computer -- its message time-out, a
         * fixed number -- so an unanswered bus keeps a redundant set in step
         * by accident.  An answered one used to complete whenever that
         * particular computer's BCE next polled, a different moment on each of
         * them, and I/O completion is one of the three points the set
         * synchronises on (FCMISYNC).  SIX ways of DELIVERING the words were
         * tried and all six lost the set, because the fault was never the
         * route: answering at all made the DURATION of a transfer depend on
         * the observer.
         *
         * So the unit puts its words on the wire at a wire rate from the
         * moment the command was issued, and every computer sees a given word
         * become available at the same simulated instant however often it
         * happens to look.  mmumodel.c has paced its listeners this way from
         * the start (tap_push's `due`); this model never did. */
        {
            bool ready = true;
            if (!ff_mdm_off() && m->wireUs[b] >= 0.0 && m->sharedUs >= 0.0) {
                int k = m->echoPending[b][g] ? 0 : (m->head[b][g] + 1);
                ready = (m->sharedUs >= m->wireUs[b] + (double)k * MTU_BUS_WORD_US);
            }
            out->out.poll.available = ready &&
                                      (m->echoPending[b][g] ||
                                       (m->count[b][g] > 0) ||
                                       (m->biteLeft[b][g] > 0) ||
                                       (m->mdm[b][g] > 0));
        }
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
        } else if (m->biteLeft[b][g] > 0) {
            int idx = FF_BITE_WORDS - m->biteLeft[b][g];
            m->biteLeft[b][g]--;
            out->out.recv.available = true;
            out->out.recv.word = m->bite[b][g][idx];
        } else if (m->mdm[b][g] > 0) {
            m->mdm[b][g]--;                 /* a box with nothing wired to it */
            out->out.recv.available = true;
            out->out.recv.word = 0;
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
    if (m->biteReads > 0)
        fprintf(stderr, "mtu: %ld MDM A/D BITE 4 read(s) answered with the "
                        "reference voltages (+2.00 V 3200, -2.00 V ce00)\n",
                m->biteReads);
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
