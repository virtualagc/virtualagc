#include "mtumodel.h"
#include "json.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <time.h>
#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif

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

/* One word time on the serial bus, as mmumodel.c has it -- the same wire.
 *
 * 33 US IS THE RATE FOR A WORD THE BCE TRANSMITS, AND A REPLY IS NOT THAT.
 * The BCE Principles of Operation (IBM-6246556A part 3, 3.3.3) gives a bus
 * word as 28 bits at 1 MHz and says that "for a Message Out instruction this
 * gap is fixed at 5 microseconds" -- 28 + 5 = 33, and that fixed 5 us is the
 * gap a BCE itself produces between words IT sends.  For words it RECEIVES
 * the same book allows "a gap of at most 20 microseconds to occur between
 * data words" before it raises its own error 21 - GAP, so a reply's word
 * period is anywhere in 28..48 us depending on how fast the answering box
 * is.  33 is one point in that range and this model charges it for both
 * directions.
 *
 * THAT IS NOT A FREE CHOICE, because the flight software's own cadence
 * bounds it: ledger #217 measured 27,122 command-to-command intervals and
 * found that for a receive armed for 21 words the MEDIAN gap is 561 us,
 * where 21 words at 33 us needs 693 -- so half of all 21-word reads have the
 * bus reclaimed before the reply could physically have passed, and the
 * receive is cut off by the next command's sync.  PASS flew, so the real
 * hardware delivered those 21 words inside 561 us; our wire cannot, and the
 * Sync Errors that follow are ours, not the software's.
 *
 * YAGPC_MTU_WORD_US sets it, so the rate is a measurement rather than a
 * rebuild.  #217 named two possible remedies -- hold the BCE, or correct the
 * rate -- and recorded the first as tried and WORSE (it holds the BCE after
 * what it TRANSMITS, which is one command word, not after the reply it is
 * waiting to receive).  This is the second. */
#define MTU_BUS_WORD_US_DEFAULT 33.0

/* YAGPC_MTU_ATOMIC=1: release a reply whole, at the instant the message
 * would have finished on the wire, instead of word by word. */
static bool mtu_atomic(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_MTU_ATOMIC") != NULL; }
    return on != 0;
}

static double mtu_bus_word_us(void) {
    static int inited = 0;
    static double us = MTU_BUS_WORD_US_DEFAULT;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MTU_WORD_US");
        if (e != NULL && *e != '\0') {
            double v = atof(e);
            if (v > 0.0) us = v;
        }
    }
    return us;
}

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
/* YAGPC_FC_SENSORS: answer EVERY surveyed read at these two units, including
 * the ones fc_ours() declines because they are sensors rather than interface
 * state.  Separate from YAGPC_FC_MDM; ON by default since 2026-09-26 (see
 * env_default_on), =0 to turn it off.
 *
 * WHY IT IS WORTH TRYING NOW AND WAS NOT BEFORE.  Ledger #210 records that
 * answering channel data cost the redundant set every time, and concluded a
 * model may report an unpowered box but may not invent sensor readings.  That
 * was measured when the answering was ASYMMETRIC: each computer held errors
 * its peers did not, FIOGPCWE was 1, and FIOERRLC self-failed it.  With the
 * pacing index fixed the errors that remain are UNIVERSAL -- GPC2, GPC3 and
 * GPC4 error at the same vehicle instant -- which is the commfault path, and
 * the set holds.  Every computer is handed the same words by the same model
 * at the same paced instant, so the divergence that argument rests on has to
 * be demonstrated again rather than assumed.
 *
 * It still never answers FIOHIBAD: that is in the no-receive table, so its
 * surveyed length is 0 and the caller declines it before reaching here. */
/* ON UNLESS SET TO 0.  The five switches below began as opt-in experiments
 * and were made the default on 2026-09-26 after the validation recorded in
 * the ledger (#249, #250 and the entries they cite): the timing unit kept
 * live and the redundant set held on the flown four-computer, three-CRT
 * vehicle, the five-computer acid test, and the owner's watched run.  Each
 * still reads its variable, so YAGPC_xxx=0 (or off, no, false) restores the
 * old behaviour for a measurement. */
static bool env_default_on(const char *name) {
    const char *e = yagpc_getenv(name);
    if (e == NULL) return true;
    return !(strcmp(e, "0") == 0 || strcasecmp(e, "off") == 0 ||
             strcasecmp(e, "no") == 0 || strcasecmp(e, "false") == 0);
}

static bool ff_sensors(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = env_default_on("YAGPC_FC_SENSORS"); }
    return on != 0;
}

static bool fc_ours(const char *sym) {
    if (ff_sensors()) return true;
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
/* ON BY DEFAULT SINCE 2026-09-26; YAGPC_FC_MDM=0 turns the forward and aft
 * MDMs off.  The history below is why it was held back, and it is kept
 * because it is the case that had to be answered.  It was answered: with
 * the stale-echo and race fixes beside it, the five-computer acid test ran
 * clean in every trial (ledger #252) -- zero votes, the timing unit live on
 * all five -- as did the flown four-computer three-CRT vehicle and the
 * four-computer OPS 201 vehicle.  The acid-test loss described next came
 * from the stale command echo (#247), not from answering as such.
 *
 * WHAT WAS HELD AGAINST IT.
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
    if (!inited) { inited = 1; off = !env_default_on("YAGPC_FC_MDM"); }
    return off != 0;
}

static bool fc_any_iua(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = env_default_on("YAGPC_FC_ANY_IUA"); }
    return on != 0;
}

static bool fc_answer_unnamed(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = env_default_on("YAGPC_FC_ANSWER_UNNAMED"); }
    return on != 0;
}

/* Every read a BCE has ARMED a receive for that the model then answers with
 * nothing, once per code and reason.  The five-computer acid test still has
 * universal left=1/6/32 errors in G9 (FIOHFE89, FIOMFEG9) that none of the
 * UNANSWERED lines account for, so the other ways of declining have to be
 * seen: the IUA gate in the caller, the survey calling the code a command
 * with no receive, and a zero length at the end. */
/* YAGPC_MTU_DIAG: the model's live diagnostics -- DECLINED, UNANSWERED and
 * ECHOX lines as they happen.  OFF BY DEFAULT, like every debugging aid; a
 * run of 25 minutes wrote 172,707 ECHOX lines with it on. */
static int mtu_diag(void) {
    static int inited = 0, on = 0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MTU_DIAG");
        on = e != NULL && *e != '\0' && strcmp(e, "0") != 0 && strcmp(e, "off") != 0;
    }
    return on;
}

static void mtu_declined(uint32_t cmd, int armed, const char *why) {
    static uint32_t seen[128]; static int n = 0;
    if (armed <= 0 || !mtu_diag()) return;
    uint32_t key = (cmd & 0xffffffu) ^ ((uint32_t)(why[0]) << 24);
    for (int k = 0; k < n; k++) if (seen[k] == key) return;
    if (n < 128) seen[n++] = key;
    int sv = -1; const char *sym = fc_sym(cmd, &sv);
    fprintf(stderr, "DECLINED cmd=%06x iua=%u armed=%d sym=%s surveyed=%d -- %s\n",
            (unsigned)(cmd & 0xffffffu), (unsigned)CMD_IUA(cmd), armed,
            sym ? sym : "-", sv, why);
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
        if (iua != MTU_IUA && iua != 12u && !fc_any_iua()) return 0;
        /* BY NAME.  A read the survey has never seen, or one that belongs to
         * a box this vehicle does not have, is not ours to answer. */
        int surveyed = -1;
        const char *sym = fc_sym(cmd, &surveyed);
        /* A READ THE SURVEY NEVER SAW, BUILT AT RUN TIME.  Commands 532aaa
         * and 632aaa reach these two units twice a run, once per string,
         * with a one-word receive armed on the commander AND every listener
         * -- and no equate in the build carries that value, so the static
         * survey cannot name them and this line answered nobody.  All four
         * computers then error on every string at the same instant (trials
         * exl-a..h: left=1 at FIOHFE38+01fe on the commander and +021a on
         * the listeners, all eight buses); that is universal, so nobody
         * fails to sync, but the flight software commfaults every string
         * and the timing unit is bypassed with its string (FCMRTBLE).  On
         * the vehicle the MDM plainly answers, or the orbiter would lose
         * every string twice a run.  YAGPC_FC_ANSWER_ALL answers any read
         * addressed to these two units that a BCE has armed a receive for,
         * named or not; the length is the armed count, as below. */
        if (sym == NULL && m_armed > 0) {
            static uint32_t said[64]; static int nSaid = 0;
            int k; for (k = 0; k < nSaid; k++) if (said[k] == (cmd & 0xffffffu)) break;
            /* ONLY THE MESSAGE is a diagnostic.  The rest of this block is
             * the answer, and gating the block on YAGPC_MTU_DIAG stopped
             * the unnamed reads being answered: every computer bypassed the
             * timing unit at the OPS 2 transition (runs fin1, fin2). */
            if (mtu_diag() && k == nSaid && nSaid < 64) {
                said[nSaid++] = cmd & 0xffffffu;
                fprintf(stderr, "UNANSWERED cmd=%06x iua=%u armed=%d -- no survey "
                        "name\n", (unsigned)(cmd & 0xffffffu), iua, m_armed);
            }
            /* YAGPC_FC_ANSWER_UNNAMED=1: answer it with the armed length.
             * Seen from both ends in trial ringerr: commander GPC3 armed a
             * one-word receive and issued 532aaa on bus 22, the three
             * listeners took its echo as their sync and waited for one
             * word, the model queued NOTHING, and exactly 2.0 ms later all
             * four timed out together -- universal, so a commfault of the
             * string, and the timing unit is bypassed with it.  An earlier
             * trial of answering (aa-a) ran WITHOUT echo expiry, so its
             * listener errors were the stale-echo kind and it could not
             * test this; it must be judged together with echo expiry. */
            if (fc_answer_unnamed() && (iua == MTU_IUA || iua == 12u)) return m_armed;
        }
        /* FIOMDMRT: THE ARMED COUNT DECIDES, NOT THE SURVEY.  fcbustable.h
         * says so itself -- "531c20 (FIOMDMRT) is a one-word read in
         * FIOIMUPG and a command with no receive at all in twelve other bus
         * programs.  Only the run-time state tells those apart" -- and the
         * survey lists 631c20 only as a command, so this line declined it
         * even when a BCE had armed a one-word receive.  Seen in the acid
         * test: every remaining error (32 of 32 in acid-ai1) was a one-word
         * receive on buses 14-17 that the commander (FIOHFE89+01fe) and all
         * three listeners (+021a) waited for together.  ONLY this code: the
         * survey's no-receive verdict still stands for everything else, and
         * FIOHIBAD in particular is a read PASS sends on purpose to a
         * channel that is not there, to stop a BCE -- answering it would
         * defeat that.  Part of YAGPC_FC_ANY_IUA. */
        if (fc_any_iua() && surveyed == 0 && m_armed > 0 && sym != NULL &&
            strcmp(sym, "FIOMDMRT") == 0)
            return (m_armed > FF_REPLY_MAX) ? FF_REPLY_MAX : m_armed;
        if (sym == NULL || surveyed == 0 || !fc_ours(sym)) {
            mtu_declined(cmd, m_armed, sym == NULL ? "no survey name"
                         : surveyed == 0 ? "survey says no receive" : "not ours");
            return 0;
        }
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
        if (n <= 0) { mtu_declined(cmd, m_armed, "zero length"); return 0; }
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
    /* WORDS THIS READER HAS TAKEN OF THE CURRENT TRANSACTION, and nothing
     * else -- the wire pacing's index.  It used to pace on `head`, which is
     * the cursor into `reply` and is reset ONLY by mtu_fill_time, so after a
     * seven-word timing-unit reply it sat at 7: an MDM answer that followed
     * on the same bus was then withheld for 8 * 33 us instead of 33, and the
     * commander's next command -- about 100 us later in FIONSPPG's chain --
     * arrived first and cleared it.  The listener was handed a command sync
     * where its data should have been, which is Table 1.2's Sync Error, and
     * error-terminated with one word still wanted.  Measured: 2,240 command
     * syncs against 8 data words at FIOBYNC3+4. */
    int sent[MTU_NBUS][MTU_READERS];
    /* ONE TRANSFER OF BACKLOG PER READER, and exactly one.
     *
     * A listener takes the command sync, and before it can come back for the
     * data the commander issues its NEXT command -- 198 us apart at the
     * median on these buses.  "Clear always" then hands it that command's
     * sync in the middle of its receive, which is Table 1.2's Sync Error, and
     * it error-terminates with every data word still wanted.  Measured on
     * buses 14-17: pc=1dcbc took 48 words, ALL command sync, and failed 48
     * times with left=6, while the COMMANDERS on those same buses took data
     * normally (#218).
     *
     * On a real wire the words of the old transfer have already gone past
     * before the new command does, so a listener that is ONE transfer behind
     * has them.  That is what this is: when a new command arrives and a
     * reader is MID-TRANSFER -- it has taken its sync and still wants words --
     * whatever it still wants is moved here and delivered BEFORE the new
     * command's sync.  A reader that has not yet taken its sync never began
     * that transfer, so its words are dropped exactly as before.
     *
     * BOUNDED AT ONE, deliberately.  An unbounded queue was tried and buried
     * a listener in backlog: 158,169 runaway BCE lines (#210).  A reader two
     * transfers behind loses the older one, which is what it does today. */
    /* AND THE COMMAND ITSELF, FOR A LISTENER THAT WAS LISTENING.  The wire
     * here holds ONE command per bus, so a listener that had not yet looked
     * when the next command was issued never saw the first.  A real BCE is
     * hardware and cannot miss a word while its receive is armed; ours looks
     * when its computer's thread next runs it, and measured gaps between
     * looks reach 365 us.  FIOMTUPG issues 526420, 525000 and 526c7f within
     * 297 us and its listeners take them with #RDLI 1, #RDLI 1, #RDLI 32 --
     * so a listener that misses the first takes the second in its place, is
     * left waiting in the 32-word receive with no time-out, takes the NEXT
     * cycle's 526420 as that receive's command, and is given a command sync
     * where it expected data: one error, alone, and it fails itself (run
     * e2u, GPC4, ledger #254).  So the untaken command is carried too, in
     * front of its words, for a reader that has looked at this bus within
     * MTU_LISTENING_US -- one that is not listening gets nothing, as before.
     *
     * STILL BOUNDED, by size and now by age: what is carried is dropped
     * MTU_ECHO_STALE after the last of it was put there, so a listener
     * cannot be buried the way #210's was. */
#define MTU_CARRY_MAX (2 * FF_REPLY_MAX + 8)
#define MTU_LISTENING_US 1000.0
    uint32_t carry[MTU_NBUS][MTU_READERS][MTU_CARRY_MAX];
    int carryLeft[MTU_NBUS][MTU_READERS], carryHead[MTU_NBUS][MTU_READERS];
    double carryUs[MTU_NBUS][MTU_READERS];     /* when the last was added */
    double lastLookUs[MTU_NBUS][MTU_READERS];  /* reader's last poll or take */
    int issuer;                                /* who is issuing, for carry */
    /* THE WIRE LOG -- YAGPC_MTU_WIRELOG.
     *
     * Everything above decides who is handed a word by the ORDER IN WHICH
     * THE COMPUTERS' THREADS HAPPEN TO CALL: one command per bus, replaced by
     * the next; a reader that has not yet looked has not heard.  But the
     * computers' simulated clocks differ by up to the barrier delta at any
     * wall instant, so that order is not the order on the wire.  Run y400
     * (barrier 400 us): GPC3 armed its receive at 343233939.5 on its own
     * clock, 241 us BEFORE GPC1 issued 526420 on its own -- and never saw
     * it, because in wall time its first look came after GPC1, 226 us ahead,
     * had already issued that command and the next.
     *
     * So the wire is kept as what it is: a sequence of words, each with the
     * simulated time it is on the bus, command syncs included.  Each reader
     * has a place in it.  A word is there for a reader when the reader's OWN
     * clock reaches the word's time -- never before -- and stays there until
     * taken, however late the reader looks.  A receive armed by a listener
     * that was not already receiving starts at the words on the wire at or
     * after the arm; one armed straight after another carries on from the
     * last word taken, because that is what the BCE's program does and the
     * reader's clock at that moment may be late.  Nothing is withdrawn,
     * carried or expired: there is nothing a reader was not listening for
     * left in front of it, and nothing it was listening for is lost. */
#define MTU_WL 2048
#define MTU_WL_CONTINUE_US 100.0
    struct MtuWire { double us; uint32_t word; int issuer; } wl[MTU_NBUS][MTU_WL];
    unsigned long wlN[MTU_NBUS];                 /* words ever put on the bus */
    unsigned long wlCur[MTU_NBUS][MTU_READERS];  /* the next one for a reader */
    double wlArmUs[MTU_NBUS][MTU_READERS];
    double wlTakenUs[MTU_NBUS][MTU_READERS];
    double wlLookUs[MTU_NBUS][MTU_READERS];
    long wlPut, wlTaken, wlBeforeArm, wlOverrun, wlCut, wlFresh, wlContinued;
    double wlLateMaxUs;
    long carried, carryDropped, carriedCmds, carryExpired;
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
    int xferWords[MTU_NBUS];   /* words this transfer puts on the wire */
    /* WHO IS CUT OFF WHEN A NEW COMMAND ARRIVES, the commander or a listener?
     * This is the question that decides the fix and nothing measured so far
     * answers it.  FIOGPCWE is counted PER BCE and FIOERRLC force-fails only
     * on a count of exactly ONE, so an error that hits all three listeners
     * together is harmless -- the count is 3 -- while one that hits the
     * commander alone, or one listener alone, is fatal.  Cutting the total
     * number of errors does not help if the survivors are the asymmetric
     * ones, which is exactly what three runs now show: 151, 85 and 17 error
     * terminations all cost precisely one computer. */
    unsigned long cutCmdr[MTU_NBUS];       /* commander still owed words */
    unsigned long cutListeners[MTU_NBUS];  /* a listener still owed words */
    unsigned long cutBoth[MTU_NBUS];       /* both, in the same command */
    unsigned long cutHist[MTU_NBUS][6];    /* how many readers at once */
    int commander[MTU_NBUS];
    int lastBus;                 /* the bus last filled, for the report */
    long commands, reads, wordsOut, listenerWords, nspReads, biteReads;
    /* ONE MODEL, FIVE THREADS, AND NO LOCK OF ITS OWN.  run.c sets sharedUs
     * and armedWords -- two scalars shared by every computer and every bus --
     * and then calls mtumodel_service_as, holding only busLock[busID].  A
     * computer on a DIFFERENT bus holds a different lock, so it can overwrite
     * either scalar in between: a command then gets another bus's reply
     * length, and a reader's readiness is judged against another machine's
     * clock.  The second is a per-reader, per-poll error that lands on one
     * computer at random -- the exact shape of the asymmetric fault that
     * FIOERRLC punishes (#240) and that three runs showed does not scale
     * with the error count (#243).  These count the collisions as seen at
     * entry; one that lands mid-service is not counted, so they are a
     * FLOOR. */
    unsigned long raceShared, raceArmed, raceChecks;
    unsigned long iuarLocal;    /* IUAR-setting #CMDIs kept off the wire */
    unsigned long echoExpired;  /* stale command echoes withdrawn */
    /* Every distinct command code reaching the model, whole run: the MDM
     * RETURN WORD read (#MINC FIOxxIUA,FIOMDMRT) is what every computer
     * fails on every string just after the OPS transition, and the
     * FIOMDMRT histogram says no FIOMDMRT ever arrives -- this says what
     * does. */
    uint32_t cmdSeen[1024]; unsigned long cmdCount[1024]; int cmdN;
    /* Every FIOMDMRT command, by what the issuing BCE had armed: the IUAR
     * test above matched NOTHING in its first trial, so what it actually
     * sees has to be looked at rather than assumed.  [0]=unset, [1]=0,
     * [2]=1, [3]=2-7, [4]=8+, [5]=negative. */
    unsigned long mdmrtArmed[6];
    unsigned long mdmrtUnnamed;  /* ...and IUA-8 LISTEN commands, for scale */
#ifdef HAVE_PTHREADS
    pthread_mutex_t lock;        /* used only with YAGPC_MTU_LOCKED */
#endif
};

/* YAGPC_MTU_RING: the last MTU_RING events on each bus -- every command and
 * every word handed to every reader -- dumped once, at the first FCMSFAIL.
 *
 * WHY.  Run whocut separated the fatal errors from the harmless ones: of 58
 * error clusters, 47 caught three or four computers together (which FIOERRLC
 * tolerates) and 10 caught ONE, and every one-computer error in the second
 * before the death was the same transaction -- a 34-word receive at
 * FIOMFE02+017c/+01a0/+01c4/+01e8, one instruction per bus 14-17, which is
 * FIOFAIC1, the aft MDM channel read.  The lone computer got NONE of the 34
 * words (left=34) while its peers got all of them.  Only a record of who was
 * handed what, and when, can say why.  Memory only, so unlike
 * YAGPC_RECVWORD_TRACE (proved to change the outcome) it prints nothing
 * until the failure has already happened. */
#define MTU_RING 16384
typedef struct {
    double t;          /* the CALLER's own shared time -- see raceShared */
    uint32_t word;
    int8_t g;          /* the computer involved */
    char kind;         /* C command, e echo, d data, c carry, b bite, m mdm, 0 nothing */
    uint8_t owed;      /* on C: mask of readers still owed words, bit r */
    int16_t sent, count;
} MtuEv;
static MtuEv mtuRing[MTU_NBUS][MTU_RING];
static unsigned mtuRingN[MTU_NBUS];
/* OFF BY DEFAULT, like every debugging aid: a production run keeps and writes
 * nothing it was not asked for.  The variable itself turns it on or off;
 * unset, YAGPC_FAILURE_RECORD decides for the whole failure record at once
 * (see batchrunner_failure_record in run.c). */
static int switch_on(const char *e) {
    return e != NULL && *e != '\0' &&
           !(!strcmp(e, "0") || !strcmp(e, "off") || !strcmp(e, "no") ||
             !strcmp(e, "false"));
}
static int ring_default_on(const char *name) {
    const char *e = yagpc_getenv(name);
    if (e != NULL) return switch_on(e);
    return switch_on(yagpc_getenv("YAGPC_FAILURE_RECORD"));
}
static int mtu_ring_on(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = ring_default_on("YAGPC_MTU_RING"); }
    return on;
}

/* YAGPC_MTU_ECHO_EXPIRE=1: a command echo is deliverable only while its
 * transfer is still on the wire -- see mtu_expire_echo. */
static bool mtu_echo_expire(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = env_default_on("YAGPC_MTU_ECHO_EXPIRE"); }
    return on != 0;
}

static bool mtu_census_on(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_MTU_CENSUS") != NULL; }
    return on != 0;
}

static bool mtu_iuar_local(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_MTU_IUAR") != NULL; }
    return on != 0;
}

/* What THIS thread asked for, so a collision can be recognised. */
static __thread double tlShared = -2.0;
static __thread int tlArmed = -2;
static __thread int tlSet = 0;

static void mtu_ring_put(int b, char kind, int g, uint32_t word, int sent,
                         int count, unsigned owed) {
    if (!mtu_ring_on() || b < 0 || b >= MTU_NBUS) return;
    MtuEv *e = &mtuRing[b][mtuRingN[b]++ % MTU_RING];
    e->t = tlShared; e->word = word; e->g = (int8_t)g; e->kind = kind;
    e->owed = (uint8_t)owed; e->sent = (int16_t)sent; e->count = (int16_t)count;
}

void mtumodel_dump_ring(double sinceUs) {
    static int done = 0;
    if (!mtu_ring_on() || done) return;
    done = 1;
    for (int b = 0; b < MTU_NBUS; b++) {
        unsigned n = mtuRingN[b], lo = (n > MTU_RING) ? n - MTU_RING : 0;
        for (unsigned i = lo; i < n; i++) {
            const MtuEv *e = &mtuRing[b][i % MTU_RING];
            if (e->t < sinceUs) continue;
            fprintf(stderr, "MTURING bus=%d t=%.1f gpc=%d %c word=%06x sent=%d "
                    "count=%d owed=%02x\n", b + MTU_BUS_FIRST, e->t, e->g,
                    e->kind, (unsigned)e->word, e->sent, e->count, e->owed);
        }
    }
}

static struct MtuModel *mtuTheModel;

struct MtuModel *mtumodel_create(void) {
    struct MtuModel *m = (struct MtuModel *)calloc(1, sizeof *m);
    if (m != NULL) m->armedWords = -1;
    /* NEGATIVE MEANS "NO SHARED CLOCK", and calloc gives zero -- which is a
     * perfectly good shared time meaning "the start of the run", so a unit
     * nobody had told about the vehicle would report that time for ever. */
    if (m != NULL) {
        mtuTheModel = m;
        m->sharedUs = -1.0;
        for (int b = 0; b < MTU_NBUS; b++) m->wireUs[b] = -1.0;
#ifdef HAVE_PTHREADS
        pthread_mutex_init(&m->lock, NULL);
#endif
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
    tlShared = sharedUs; tlSet |= 1;
}

void mtumodel_set_armed_words(struct MtuModel *m, int words) {
    if (m) m->armedWords = words;
    tlArmed = words; tlSet |= 2;
}

/* YAGPC_MTU_LOCKED=1: set the caller's clock and armed count and serve the
 * call as ONE step under the model's own lock, so no other computer can
 * change either in between.  ON by default since 2026-09-26: measured, the
 * unlocked model saw another computer's clock under 4% of calls (#244); the
 * lock is a leaf lock and cannot deadlock (#250).  =0 turns it off. */
bool mtumodel_locked_mode(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = env_default_on("YAGPC_MTU_LOCKED"); }
    return on != 0;
}

void mtumodel_service_locked(struct MtuModel *m, int gpcId, double sharedUs,
                             int armedWords, GpcServiceNumber svc,
                             const GpcServiceInput *in, GpcServiceOutput *out) {
    if (m == NULL) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&m->lock);
#endif
    m->sharedUs = sharedUs;
    m->armedWords = armedWords;
    tlShared = sharedUs; tlArmed = armedWords; tlSet = 3;
    mtumodel_service_as(m, gpcId, svc, in, out);
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&m->lock);
#endif
}

uint32_t mtumodel_bus_mask(void) {
    uint32_t mask = 0;
    /* WITH THE ANSWERING OFF, ONLY THE BUSES IT ACTUALLY ANSWERS ON.
     *
     * Marking 14-17 as well is the correct thing for the configuration that
     * answers the MDMs -- it takes a listener there from one word every 40 ms
     * to one every 33 us (#219) -- but in the DEFAULT build it costs the
     * redundant set: the gate took four votes against GPC1 at t=821.4, where
     * the same gate with 20-22 alone has none, and bus traffic fell from
     * about 11,000,000 commands to 3,160,776.  So it travels with the switch,
     * like the echo rule, the pacing, the shared clock and the backlog.
     *
     * AND THAT LEAVES A CONTRADICTION WORTH WRITING DOWN: with the answering
     * off this model still ECHOES a commander's command on 14-17, because its
     * echo condition there (count == 0) is always true -- so it marks command
     * sync on buses whose listeners are told not to expect one.  Making the
     * echo match the mask is the other way to resolve it and has not been
     * measured; see #219. */
    int first = ff_mdm_off() ? 20 : MTU_BUS_FIRST;
    int last  = ff_mdm_off() ? 22 : MTU_BUS_LAST;
    for (int b = first; b <= last && b < 32; b++)
        mask |= 1u << b;
    return mask;
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

static double mtu_echo_stale_us(void);

static struct MtuModel *mtuTheModel = NULL;     /* for mtumodel_note_arm */

/* THE WIRE MODEL -- see wl[] in struct MtuModel.  ON BY DEFAULT since
 * 2026-09-27: 5 of 5 full runs clean at the normal barrier and 10 of 12 at
 * 200 us, where the delivery it replaces lost a computer at 400 us.  It is
 * not logging, whatever its name: it is how the words are delivered.
 * YAGPC_MTU_WIRELOG=0 restores the old per-transaction delivery. */
static int mtu_wirelog(void) {
    static int inited = 0, on = 0;
    if (!inited) {
        inited = 1;
        on = env_default_on("YAGPC_MTU_WIRELOG");
    }
    return on;
}

/* Move what this reader still wants of the CURRENT transfer into its backlog,
 * so the next command does not cut it off.  Only when it is mid-transfer: a
 * reader still holding its command sync never started, and keeping its words
 * would deliver data with no sync in front of it. */
static void mtu_carry_take(struct MtuModel *m, int b, int r) {
    /* LISTENERS ONLY.  A commander that has just issued a command has
     * finished the receive before it -- a real BCE does not issue one while
     * it is still receiving -- so carrying its leftovers would push stale
     * words into the read it just asked for.  m->commander[b] is still the
     * PREVIOUS commander here, which is the one those words belonged to;
     * reader 0 is the single-machine caller and is its own commander. */
    /* WITH THE ANSWERING OFF, EXACTLY AS BEFORE.  This changes what a
     * listener of the timing unit's OWN read receives, and that read is
     * answered in every configuration -- so without this guard the backlog
     * would be live in the default build, which is the one validated clean.
     * It travels with the switch like the echo rule, the pacing and the
     * shared clock (#213). */
    if (ff_mdm_off()) return;
    if (r == 0 || r == m->commander[b] || r == m->issuer) return;
    /* What is already there stays in front; see MTU_CARRY_MAX. */
    int n = 0;
    if (m->carryLeft[b][r] > 0) {
        if (m->carryHead[b][r] > 0)
            memmove(m->carry[b][r], m->carry[b][r] + m->carryHead[b][r],
                    (size_t)m->carryLeft[b][r] * sizeof m->carry[b][r][0]);
        n = m->carryLeft[b][r];
    }
    int had = n;
    int want = (m->echoPending[b][r] ? 1 : 0) + m->count[b][r]
             + m->biteLeft[b][r] + m->mdm[b][r];
    if (m->echoPending[b][r]) {
        /* NEVER BEGAN THIS TRANSFER -- and keeps it only if it was listening
         * when the command was issued, and the command is not itself stale. */
        bool listening = m->sharedUs >= 0.0 && m->wireUs[b] >= 0.0 &&
                         m->lastLookUs[b][r] > 0.0 &&
                         m->wireUs[b] - m->lastLookUs[b][r] <= MTU_LISTENING_US &&
                         m->sharedUs - m->wireUs[b] <= mtu_echo_stale_us();
        if (!listening) return;
    }
    if (want <= 0) return;
    if (n + want > MTU_CARRY_MAX) {
        /* No room: it loses what it had, as a reader two behind always did. */
        m->carryDropped++;
        n = 0; had = 0;
    }
    if (m->echoPending[b][r]) {
        m->carry[b][r][n++] = m->echoCmd[b] | YAGPC_BUSWORD_CMD_SYNC;
        m->echoPending[b][r] = false;
        m->carriedCmds++;
    }
    while (m->count[b][r] > 0 && n < MTU_CARRY_MAX) {
        m->carry[b][r][n++] = m->reply[b][r][m->head[b][r]++];
        m->count[b][r]--;
    }
    while (m->biteLeft[b][r] > 0 && n < MTU_CARRY_MAX) {
        m->carry[b][r][n++] = m->bite[b][r][FF_BITE_WORDS - m->biteLeft[b][r]];
        m->biteLeft[b][r]--;
    }
    while (m->mdm[b][r] > 0 && n < MTU_CARRY_MAX) {
        m->carry[b][r][n++] = 0;
        m->mdm[b][r]--;
    }
    if (n == had) return;
    m->carryUs[b][r] = m->sharedUs;
    m->carryLeft[b][r] = n;
    m->carryHead[b][r] = 0;
    m->carried++;
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
    unsigned eighths, sec, min, hr, days;   /* eighths: 0.125 ms units */
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
        eighths = (unsigned)((t - (double)whole) * 8000.0) % 8000u;
        sec = (unsigned)lt.tm_sec % 60u;     /* a leap second reads as :59 */
        min = (unsigned)lt.tm_min;
        hr = (unsigned)lt.tm_hour;
        days = (unsigned)(lt.tm_yday + 1);
    } else {
        unsigned long long totalEighths = (unsigned long long)(us / 125.0);
        eighths = (unsigned)(totalEighths % 8000ull);
        unsigned long long totalSec = totalEighths / 8000ull;
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

    /* MILLISECONDS in 0.125 ms units, thirteen bits -- and all thirteen are
     * used.  FPMMTUFX multiplies the whole field by 125 us ('MH R4,FPM125'),
     * so the unit's resolution is an eighth of a millisecond.  This used to
     * truncate to whole milliseconds and multiply by eight, which threw away
     * up to 1 ms on every read.  PASS re-derives its clock from the unit every
     * 960 ms (FPMMTURM), so the discarded fraction became a step in the
     * vehicle's clock: the set's minor-cycle grid walked +1/3, +1/3, -2/3 ms
     * in shared time with a period of 2.88 s.  A computer joining the set
     * zeroes its clock on the set's SSIP and schedules its first SIP 2.33 ms
     * ahead of a boundary (AIBGPCLO '.31767 - RUNTIME'); a step of that size
     * inside the join put the SCHEDULE AT on the wrong side of the boundary,
     * and the new member took one SIP too many (ledger #259). */
    unsigned msec = eighths & 0x1fffu;

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
    for (int r = 0; r < MTU_READERS; r++) mtu_carry_take(m, b, r);
    for (int r = 0; r < MTU_READERS; r++) {
        m->reply[b][r][0] = (uint16_t)dyhr;
        m->reply[b][r][1] = (uint16_t)mnsc;
        m->reply[b][r][2] = (uint16_t)msec;
        m->head[b][r] = 0;
        m->sent[b][r] = 0;
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

/* A COMMAND WORD PASSES ONCE.  echoPending never used to expire: a
 * listener that was NOT listening when a command went by kept that command
 * pending, and received it whenever it next polled -- milliseconds later,
 * as though it were fresh.  If its IUA matched the listener's IUAR, the BCE
 * took it as the start of the message it had just armed for, got no data,
 * and was cut off by the next real command: Table 1.2's Sync Error, alone.
 *
 * Seen directly in the event ring of trial fix-a, bus 15, GPC2 commanding:
 * 620040 issued at 55.916662 while GPC1 was not listening on that bus;
 * 11 ms later GPC1 armed #RDLI 33 for FIOFAIC1 (FIOMFE38+01a0), polled, and
 * was handed the STALE 620040 -- IUA 12, its own -- then nothing, then
 * 400c0a's sync: left=34 at 55.928066, and GPC1 self-failed from FIOERRLC
 * 10 ms later.  GPC3 and GPC4 had taken that old echo in time and received
 * all 34 words.  Whether a listener gets ambushed depends only on whether
 * it happened to poll in a window, which is the asymmetry FIOERRLC punishes
 * (FIOGPCWE == 1).
 *
 * On a wire a command a computer was not listening for is simply gone --
 * the same rule iccmodel.c applies to the ICC ("A BUS HOLDS NOTHING").  So
 * a reader that never began a transfer loses its echo, and that transfer's
 * data, once the transfer would have left the wire: the command word and
 * every reply word at the wire rate, plus a margin for poll granularity and
 * the barrier's clock spread.  A reader that has begun is untouched. */
#define MTU_ECHO_MARGIN_US 200.0
static double mtu_echo_stale_us(void) {
    static int inited = 0;
    static double us = 5000.0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MTU_ECHO_STALE_US");
        if (e != NULL && *e != '\0') { double v = atof(e); if (v >= 0.0) us = v; }
    }
    return us;
}
static void mtu_expire_echo(struct MtuModel *m, int b, int g) {
    if (!mtu_echo_expire() || ff_mdm_off()) return;
    if (!m->echoPending[b][g] || m->wireUs[b] < 0.0 || !(tlSet & 1) || tlShared < 0.0)
        return;
    double gone = m->wireUs[b]
                + (double)(1 + (m->xferWords[b] > 0 ? m->xferWords[b] : 0)) * mtu_bus_word_us()
                + MTU_ECHO_MARGIN_US;
    /* BUT NEVER SOONER THAN A WHOLE TRANSACTION AGO.  The wire-time window
     * alone was too tight: measured in run s201-all1, the listen command
     * 401100 on bus 17 was withdrawn from GPCs 1, 2 and 3 every 40 ms, each
     * 250-340 us late -- ordinary listener latency here (BCE wheel slices,
     * the barrier's spread, the listener finishing the instruction before
     * its #RDLI), which a listener already armed on the vehicle would never
     * see as late.  The fatal stale echoes this exists for were 10.8 ms (the
     * FA read, trial fix-a) and 960 ms (the timing unit's own read) old.  So
     * an echo is stale only past a floor well clear of both: 5 ms, fifteen
     * times the routine lateness and half the youngest fatal one.  A window
     * that also caught the routine case is the likely source of the parked
     * listener (#247) and of s201-all1's FCMISYNC loss, where all three
     * peers failed to complete one I/O together.  YAGPC_MTU_ECHO_STALE_US
     * overrides it. */
    if (gone < m->wireUs[b] + mtu_echo_stale_us()) gone = m->wireUs[b] + mtu_echo_stale_us();
    if (tlShared <= gone) return;
    m->echoPending[b][g] = false;
    m->count[b][g] = 0;
    m->biteLeft[b][g] = 0;
    m->mdm[b][g] = 0;
    __atomic_fetch_add(&m->echoExpired, 1, __ATOMIC_RELAXED);
    mtu_ring_put(b, 'x', g, m->echoCmd[b], 0, 0, 0);
    /* Each one, live: rare enough (a few hundred a run) not to perturb, and
     * the only way to tie a later death to a withdrawal a whole cycle
     * earlier, which is further back than either ring reaches. */
    if (mtu_diag())
    fprintf(stderr, "ECHOX gpc=%d bus=%d cmd=%06x late=%.1f us t=%.1f\n", g,
            b + MTU_BUS_FIRST, (unsigned)m->echoCmd[b], tlShared - m->wireUs[b],
            tlShared);
}

/* This reader is looking at this bus NOW, which is the nearest thing the model
 * has to knowing its receive is armed; and what was carried for it too long
 * ago to be part of any transfer it could still be in is dropped first. */
static void mtu_note_look(struct MtuModel *m, int b, int g) {
    if (ff_mdm_off() || !(tlSet & 1) || tlShared < 0.0) return;
    if (m->carryLeft[b][g] > 0 &&
        tlShared - m->carryUs[b][g] > mtu_echo_stale_us()) {
        m->carryLeft[b][g] = 0;
        m->carryHead[b][g] = 0;
        __atomic_fetch_add(&m->carryExpired, 1, __ATOMIC_RELAXED);
    }
    m->lastLookUs[b][g] = tlShared;
}

static bool wl_active(const struct MtuModel *m, int g) {
    return mtu_wirelog() && !ff_mdm_off() && g >= 1 && m->sharedUs >= 0.0 &&
           (tlSet & 1) && tlShared >= 0.0;
}

static void wl_put(struct MtuModel *m, int b, double us, uint32_t word, int issuer) {
    struct MtuWire *e = &m->wl[b][m->wlN[b] % MTU_WL];
    e->us = us; e->word = word; e->issuer = issuer;
    m->wlN[b]++;
    m->wlPut++;
}

/* The next word on bus b that reader g is to be given, or NULL.  Its own
 * commands are not echoed to it, and what passed before it armed is not its. */
static struct MtuWire *wl_next(struct MtuModel *m, int b, int g) {
    unsigned long *cur = &m->wlCur[b][g];
    if (*cur > m->wlN[b]) *cur = m->wlN[b];
    if (m->wlN[b] - *cur > MTU_WL) {
        /* The log has wrapped past this reader.  Say who, how far, and
         * whether anything it could have WANTED went: the words that went
         * are all older than the oldest one kept, so if that is still before
         * this reader armed, none of them was for it. */
        unsigned long skip = m->wlN[b] - MTU_WL - *cur;
        double oldest = m->wl[b][(m->wlN[b] - MTU_WL) % MTU_WL].us;
        fprintf(stderr, "WLOVERRUN bus=%d gpc=%d skipped=%lu cur=%lu lastlook=%.1f "
                        "arm=%.1f oldest-kept=%.1f now=%.1f -- %s\n",
                b + MTU_BUS_FIRST, g, skip, *cur, m->wlLookUs[b][g],
                m->wlArmUs[b][g], oldest, tlShared,
                (m->wlArmUs[b][g] > oldest) ? "none of it was for this reader"
                                             : "SOME MAY HAVE BEEN WANTED");
        *cur = m->wlN[b] - MTU_WL; m->wlOverrun++;
    }
    while (*cur < m->wlN[b]) {
        struct MtuWire *e = &m->wl[b][*cur % MTU_WL];
        if (e->issuer == g) { (*cur)++; continue; }
        if (e->us < m->wlArmUs[b][g]) { (*cur)++; m->wlBeforeArm++; continue; }
        return e;
    }
    return NULL;
}

void mtumodel_note_arm(int gpcId, int busID, bool listen, double sharedUs) {
    struct MtuModel *m = mtuTheModel;
    if (m == NULL || !mtu_wirelog() || !mtumodel_owns_bus(busID)) return;
    if (gpcId < 1 || gpcId >= MTU_READERS || !listen) return;
    int b = busID - MTU_BUS_FIRST;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&m->lock);
#endif
    if (m->wlLookUs[b][gpcId] > 0.0 &&
        sharedUs - m->wlLookUs[b][gpcId] <= MTU_WL_CONTINUE_US) {
        m->wlContinued++;            /* the next receive of the same program */
    } else {
        m->wlArmUs[b][gpcId] = sharedUs;
        m->wlFresh++;
        /* A FRESH ARM TAKES ITS PLACE AT THE WIRE AS IT IS NOW.  A computer
         * that was not executing -- in HALT, or not yet IPLed -- held no
         * place in the log, as a real one holds nothing but its MIA latch:
         * its place was left at word 0 and the ring wrapped past it, which
         * the log counted as an overrun although none of the words was ever
         * for it (run ov1: GPCs 2, 3 and 4, first look at buses 20 and 22 at
         * the OPS 2 transition, 13,521 and 92,391 words behind).  So the
         * place moves to the first word at or after this arm, keeping any
         * that a computer ahead of this one in simulated time has already
         * put there; it never moves back. */
        unsigned long c = m->wlN[b];
        unsigned long lo = (c > MTU_WL) ? c - MTU_WL : 0;
        while (c > lo && m->wl[b][(c - 1) % MTU_WL].us >= sharedUs) c--;
        if (m->wlCur[b][gpcId] < c) m->wlCur[b][gpcId] = c;
    }
    m->wlLookUs[b][gpcId] = sharedUs;
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&m->lock);
#endif
}

void mtumodel_service_as(struct MtuModel *m, int gpcId, GpcServiceNumber svc,
                         const GpcServiceInput *in, GpcServiceOutput *out) {
    if (!m || !in || !out) return;
    int g = (gpcId >= 0 && gpcId < MTU_READERS) ? gpcId : 0;
    int b = in->busID - MTU_BUS_FIRST;
    if (g >= 1 && tlSet == 3) {
        __atomic_fetch_add(&m->raceChecks, 1, __ATOMIC_RELAXED);
        if (m->sharedUs != tlShared) __atomic_fetch_add(&m->raceShared, 1, __ATOMIC_RELAXED);
        if (svc == GPC_SVC_XMIT_CMD && m->armedWords != tlArmed)
            __atomic_fetch_add(&m->raceArmed, 1, __ATOMIC_RELAXED);
    }
    if (b < 0 || b >= MTU_NBUS) b = 0;

    switch (svc) {
    case GPC_SVC_XMIT_CMD: {
        uint32_t cmd = in->in.word & 0x00ffffffu;
        m->commands++;
        m->issuer = g;
        /* OFF unless YAGPC_MTU_CENSUS: it writes shared arrays, and only the
         * locked path serialises this model. */
        if (mtu_census_on()) {
            int n = m->cmdN < 1024 ? m->cmdN : 1024, k;
            for (k = 0; k < n; k++) if (m->cmdSeen[k] == cmd) break;
            if (k == n && n < 1024) { m->cmdSeen[n] = cmd; m->cmdN = n + 1; }
            if (k < 1024) m->cmdCount[k]++;
        }
        /* A LISTENER SETTING ITS OWN IUA REGISTER IS NOT A BUS TRANSACTION.
         * The flight-critical listen entry points all begin
         *     #CMDI FIOxxIUA,FIOMDMRT   SET IUAR FOR LISTENER
         *     #RDLI n
         * (FIOMFE02 FIOEL23L..., FIOHFEPG FIOELLR6...): a command instruction
         * executed only to load the IUA register before listening.  This model
         * treats every command as a transaction -- it makes the issuer the
         * commander, clears every reader's pending reply, restarts the wire
         * clock and echoes the command to everyone -- so a listener whose
         * #CMDI lands AFTER the real commander's read destroys its own copy of
         * the reply and then waits in #RDLI for a sync that has already gone
         * by, and the stray echo lands on the real commander as a command sync
         * in the middle of ITS receive.  The first is exactly the fatal
         * signature measured in run whocut: one computer, alone, receiving
         * NONE of FIOFAIC1's 34 words (left=34) at FIOMFE02+017c/+01a0/+01c4/
         * +01e8 while its peers received all of them.
         *
         * NOT #224 AGAIN.  That blocked the servicer call for ANY command
         * from a BCE whose transmit-enable was off, and judged the result by
         * total error counts on single runs -- a metric today's runs show
         * cannot see the fault (151, 85 and 17 errors each cost exactly one
         * computer).  This recognises only the idiom: FIOMDMRT, named by the
         * survey, with NO receive armed by the issuing BCE (armed <= 0) -- the same test
         * that already tells this command apart from FIOIMUPG's one-word read
         * of the same code.  The armed count is this thread's own (tlArmed),
         * not the shared scalar another computer may have overwritten (#244).
         * YAGPC_MTU_IUAR=1 turns it on; off, nothing changes. */
        if (mtu_census_on()) {
            int sv = -1;
            const char *sy = fc_sym(cmd, &sv);
            if (sy != NULL && strcmp(sy, "FIOMDMRT") == 0) {
                int k = !(tlSet & 2) ? 0 : tlArmed == 0 ? 1 : tlArmed == 1 ? 2
                      : (tlArmed >= 2 && tlArmed <= 7) ? 3 : tlArmed >= 8 ? 4 : 5;
                __atomic_fetch_add(&m->mdmrtArmed[k], 1, __ATOMIC_RELAXED);
            } else if (CMD_IUA(cmd) == 8u) {
                __atomic_fetch_add(&m->mdmrtUnnamed, 1, __ATOMIC_RELAXED);
            }
        }
        /* "NO RECEIVE ARMED" IS -1, NOT 0: iop_bce_armed_words returns -1
         * when the BCE has neither a stashed length nor an active receive,
         * which is exactly the state before a listener's #RDLI.  The first
         * version of this tested == 0 and matched nothing at all in its
         * first trial (iuar-a), which therefore measured the baseline. */
        if (mtu_iuar_local() && (tlSet & 2) && tlArmed <= 0) {
            int surveyed = -1;
            const char *sym = fc_sym(cmd, &surveyed);
            if (sym != NULL && strcmp(sym, "FIOMDMRT") == 0) {
                m->iuarLocal++;
                mtu_ring_put(b, 'I', g, cmd, 0, 0, 0);
                out->out.xmit.ok = true;
                break;
            }
        }
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
            /* YAGPC_FC_ANY_IUA: surveyed reads at the OTHER flight-critical
             * units too.  Run hk1a (five computers, every fix on) lost GPC2
             * after two rounds in which ALL FOUR set members waited for
             * b8401f -- FIOFAIC5, a surveyed 32-word read at IUA 23 in
             * FIOMFEG9 -- and nobody answered it, because only IUAs 10 and
             * 12 were ever answered.  #241 tried lifting this gate and was
             * refuted, but it ran without echo expiry and without the lock,
             * so its deaths were the stale-echo kind and it could not test
             * the answering itself (the same confound as aa-a, #249).  Here
             * only a read NAMED in the survey WITH a receive length, that a
             * BCE has ARMED a receive for, is answered -- ff_nsp_words'
             * by-name tests still decide it. */
            int nsp = (cu == MTU_IUA || cu == 12u || fc_any_iua())
                          ? ff_nsp_words(cmd, m->armedWords) : 0;
            if (cu != MTU_IUA && cu != 12u && !ff_mdm_off() && !fc_any_iua())
                mtu_declined(cmd, m->armedWords, "IUA not 10 or 12");
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
            for (int r = 0; r < MTU_READERS; r++) mtu_carry_take(m, b, r);
            for (int r = 0; r < MTU_READERS; r++) {
                m->count[b][r] = 0;
                m->head[b][r] = 0;      /* a new transaction starts at word 0 */
                m->sent[b][r] = 0;
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
            m->xferWords[b] = nsp;
            if (nsp > 0) m->nspReads++;
            if (bite) m->biteReads++;
        } else {
            mtu_fill_time(m, b);
            m->xferWords[b] = MTU_WORDS;
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
        {
            /* Count who still has words the wire never got to them, BEFORE
             * this command's sync lands on them.  m->commander[b] is still
             * the PREVIOUS commander here, which is the point. */
            int nCut = 0; bool cmdrCut = false, lisCut = false;
            for (int r = 1; r < MTU_READERS; r++) {
                if (m->count[b][r] + m->biteLeft[b][r] + m->mdm[b][r]
                    + m->carryLeft[b][r] <= 0) continue;
                nCut++;
                if (r == m->commander[b]) cmdrCut = true; else lisCut = true;
            }
            {
                unsigned owed = 0;
                for (int r = 1; r < MTU_READERS; r++)
                    if (m->count[b][r] + m->biteLeft[b][r] + m->mdm[b][r]
                        + m->carryLeft[b][r] > 0) owed |= 1u << r;
                mtu_ring_put(b, 'C', g, cmd, m->commander[b], 0, owed);
            }
            if (nCut > 0) {
                if (cmdrCut && lisCut) m->cutBoth[b]++;
                else if (cmdrCut) m->cutCmdr[b]++;
                else m->cutListeners[b]++;
                m->cutHist[b][nCut < 6 ? nCut : 5]++;
            }
        }
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
             * answering (on by default since 2026-09-26; YAGPC_FC_MDM=0
             * restores the configuration the owner had validated clean over
             * an hour, and this rule with it).  Measured 2026-09-25: leaving the new echo rule, the
             * wire pacing and the shared clock active with the answering OFF
             * cost that configuration four fail votes at t=1914 where it had
             * none.  A correctness fix that perturbs a validated build is
             * still a regression, so it travels with the switch. */
            m->echoPending[b][r] = ff_mdm_off()
                ? (g >= 1 && r >= 1 && r != g && m->count[b][r] == 0)
                : (g >= 1 && r >= 1 && r != g);
        if (wl_active(m, g)) {
            /* ONTO THE WIRE, ONCE, FOR EVERYBODY.  What was composed above
             * for each reader separately is the same transfer; the
             * commander's copy of it goes into the log and the rest is
             * cleared, so that nothing is served from two places. */
            double T = m->sharedUs, w = mtu_bus_word_us();
            /* A command ends the transfer before it: what the device had not
             * yet put on the wire by now it never does. */
            while (m->wlN[b] > 0) {
                struct MtuWire *last = &m->wl[b][(m->wlN[b] - 1) % MTU_WL];
                if (last->issuer >= 0 || last->us <= T) break;
                m->wlN[b]--;
                m->wlCut++;
            }
            wl_put(m, b, T, cmd | YAGPC_BUSWORD_CMD_SYNC, g);
            unsigned long first = m->wlN[b];
            int k = 0;
            for (int i = 0; i < m->count[b][g]; i++)
                wl_put(m, b, T + (double)(++k) * w,
                       m->reply[b][g][m->head[b][g] + i], -1);
            for (int i = FF_BITE_WORDS - m->biteLeft[b][g]; i < FF_BITE_WORDS; i++)
                wl_put(m, b, T + (double)(++k) * w, m->bite[b][g][i], -1);
            for (int i = 0; i < m->mdm[b][g]; i++)
                wl_put(m, b, T + (double)(++k) * w, 0u, -1);
            for (int r = 0; r < MTU_READERS; r++) {
                m->count[b][r] = 0; m->biteLeft[b][r] = 0; m->mdm[b][r] = 0;
                m->echoPending[b][r] = false;
                m->carryLeft[b][r] = 0; m->carryHead[b][r] = 0;
            }
            /* The commander reads the answer to THIS command. */
            m->wlCur[b][g] = first;
            m->wlArmUs[b][g] = T;
            m->wlLookUs[b][g] = T;
        }
        out->out.xmit.ok = true;
        break;
    }
    case GPC_SVC_XMIT_WORD:
        out->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL:
        if (wl_active(m, g)) {
            struct MtuWire *e = wl_next(m, b, g);
            m->wlLookUs[b][g] = tlShared;
            out->out.poll.available = (e != NULL && e->us <= tlShared);
            break;
        }
        mtu_note_look(m, b, g);
        mtu_expire_echo(m, b, g);
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
                /* A MESSAGE IS ATOMIC, AND WORD-AT-A-TIME IS WHAT SPLITS THE
                 * SET.  Pacing each word separately lets a reader sit HALF
                 * WAY THROUGH a reply, and half way through is the only
                 * state from which the next command's sync can raise Table
                 * 1.2's Sync Error.  Worse, which readers are half way
                 * through depends on how often each happened to poll, so the
                 * error lands on some computers and not others -- and
                 * FIOERRLC force-fails the computer that holds an error its
                 * peers do not (FIOGPCWE == 1, counted per BCE).  That
                 * asymmetry is the whole loss of sync, ledger #240.
                 *
                 * On the wire a receive completes when the MESSAGE completes;
                 * a BCE does not release a half-received message to its
                 * program.  So the whole reply becomes available at one
                 * instant -- the same instant for every computer on the bus,
                 * which is what makes the duration observer-independent --
                 * and no reader can be caught in between.
                 *
                 * The RATE is unchanged and still the documented 33 us
                 * (IBM-6246556A part 3): this moves WHEN the words are
                 * released, not how long the wire is busy.  Measured at 10 us
                 * per word the word-at-a-time scheme dropped the error
                 * terminations from 151 to 17 -- so the partially drained
                 * reader is confirmed as the source -- but 10 us is below the
                 * 28-bit word time and not a rate the hardware can have.
                 * This gets the same effect at a legal rate. */
                int k;
                if (mtu_atomic()) {
                    k = m->echoPending[b][g] ? 0 : (m->xferWords[b] > 0
                                                    ? m->xferWords[b] : 1);
                } else {
                    k = m->echoPending[b][g] ? 0 : (m->sent[b][g] + 1);
                }
                ready = (m->sharedUs >= m->wireUs[b] + (double)k * mtu_bus_word_us());
            }
            /* THE BACKLOG IS ALWAYS READY.  Its words belong to a transfer
             * whose wire time is already past -- that is the whole reason it
             * exists -- so the pacing has nothing left to say about them. */
            out->out.poll.available = (m->carryLeft[b][g] > 0) ||
                                      (ready &&
                                       (m->echoPending[b][g] ||
                                        (m->count[b][g] > 0) ||
                                        (m->biteLeft[b][g] > 0) ||
                                        (m->mdm[b][g] > 0)));
        }
        break;
    case GPC_SVC_RECV_WORD:
        if (wl_active(m, g)) {
            struct MtuWire *e = wl_next(m, b, g);
            m->wlLookUs[b][g] = tlShared;
            if (e == NULL || e->us > tlShared) {
                out->out.recv.available = false;
                out->out.recv.word = 0;
                break;
            }
            out->out.recv.available = true;
            out->out.recv.word = e->word;
            m->wlCur[b][g]++;
            m->wlTakenUs[b][g] = e->us;
            m->wlTaken++;
            if (tlShared - e->us > m->wlLateMaxUs) m->wlLateMaxUs = tlShared - e->us;
            mtu_ring_put(b, (e->word & YAGPC_BUSWORD_CMD_SYNC) ? 'e' : 'd', g,
                         e->word & 0x00ffffffu, 0, 0, 0);
            if (e->issuer < 0) {
                if (g == m->commander[b]) m->wordsOut++;
                else m->listenerWords++;
            }
            break;
        }
        mtu_note_look(m, b, g);
        mtu_expire_echo(m, b, g);
        if (m->carryLeft[b][g] > 0) {
            /* What it still wanted of the PREVIOUS transfer, ahead of this
             * one's command word, which is the order the wire had them in.
             * Not counted into `sent`: these are not this transaction's. */
            out->out.recv.available = true;
            out->out.recv.word = m->carry[b][g][m->carryHead[b][g]++];
            m->carryLeft[b][g]--;
            mtu_ring_put(b, (out->out.recv.word & YAGPC_BUSWORD_CMD_SYNC) ? 'k' : 'c',
                         g, out->out.recv.word & 0x00ffffffu, m->sent[b][g],
                         m->carryLeft[b][g], 0);
            if (g == m->commander[b] || g == 0) m->wordsOut++;
            else m->listenerWords++;
        } else if (m->echoPending[b][g]) {
            m->echoPending[b][g] = false;
            out->out.recv.available = true;
            out->out.recv.word = m->echoCmd[b] | YAGPC_BUSWORD_CMD_SYNC;
            mtu_ring_put(b, 'e', g, m->echoCmd[b], m->sent[b][g], m->count[b][g], 0);
        } else if (m->count[b][g] > 0) {
            out->out.recv.available = true;
            out->out.recv.word = m->reply[b][g][m->head[b][g]++];
            m->count[b][g]--;
            m->sent[b][g]++;
            mtu_ring_put(b, 'd', g, out->out.recv.word, m->sent[b][g], m->count[b][g], 0);
            if (g == m->commander[b] || g == 0) m->wordsOut++;
            else m->listenerWords++;
        } else if (m->biteLeft[b][g] > 0) {
            int idx = FF_BITE_WORDS - m->biteLeft[b][g];
            m->biteLeft[b][g]--;
            m->sent[b][g]++;
            out->out.recv.available = true;
            out->out.recv.word = m->bite[b][g][idx];
            mtu_ring_put(b, 'b', g, out->out.recv.word, m->sent[b][g], m->biteLeft[b][g], 0);
        } else if (m->mdm[b][g] > 0) {
            m->mdm[b][g]--;                 /* a box with nothing wired to it */
            m->sent[b][g]++;
            mtu_ring_put(b, 'm', g, 0, m->sent[b][g], m->mdm[b][g], 0);
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
    if (m->wlPut > 0)
        fprintf(stderr, "mtu: wire log -- %ld word(s) put on the buses, %ld "
                        "taken (the latest %.1f us after its time), %ld passed "
                        "before the reader armed, %ld cut off by a following "
                        "command, %ld lost to a reader more than %d behind; "
                        "%ld fresh arm(s), %ld continued\n",
                m->wlPut, m->wlTaken, m->wlLateMaxUs, m->wlBeforeArm, m->wlCut,
                m->wlOverrun, MTU_WL, m->wlFresh, m->wlContinued);
    if (m->carried > 0)
        fprintf(stderr, "mtu: %ld transfer(s) carried over a following command"
                        " for a reader still taking them, %ld dropped as a"
                        " second; %ld untaken command(s) carried with them for a"
                        " listener that had not yet looked, %ld backlog(s)"
                        " dropped as stale\n", m->carried, m->carryDropped,
                m->carriedCmds, m->carryExpired);
    {
        unsigned long tc = 0, tl = 0, tb = 0, th[6] = {0,0,0,0,0,0};
        for (int b = 0; b < MTU_NBUS; b++) {
            tc += m->cutCmdr[b]; tl += m->cutListeners[b]; tb += m->cutBoth[b];
            for (int k = 0; k < 6; k++) th[k] += m->cutHist[b][k];
        }
        if (tc + tl + tb > 0)
            fprintf(stderr, "mtu: a new command landed on a reader still owed "
                    "words %lu time(s): the COMMANDER alone %lu, LISTENERS only "
                    "%lu, both %lu; readers at once 1=%lu 2=%lu 3=%lu 4=%lu "
                    "5+=%lu -- only a count of ONE is fatal (FIOGPCWE)\n",
                    tc + tl + tb, tc, tl, tb, th[1], th[2], th[3], th[4], th[5]);
    }
    if (mtu_census_on())
    fprintf(stderr, "mtu: FIOMDMRT commands by the issuer's armed count: "
            "unset %lu, 0 %lu, 1 %lu, 2-7 %lu, 8+ %lu, negative %lu; IUA-8 "
            "listen commands %lu\n", m->mdmrtArmed[0], m->mdmrtArmed[1],
            m->mdmrtArmed[2], m->mdmrtArmed[3], m->mdmrtArmed[4],
            m->mdmrtArmed[5], m->mdmrtUnnamed);
        if (m->cmdN > 0) {
        int n = m->cmdN < 1024 ? m->cmdN : 1024;
        fprintf(stderr, "mtu: %d distinct command code(s); IUA 10/12 ones:", n);
        for (int k = 0; k < n; k++) {
            unsigned iua = CMD_IUA(m->cmdSeen[k]);
            if (iua == 10u || iua == 12u) {
                int sv = -1; const char *sy = fc_sym(m->cmdSeen[k], &sv);
                fprintf(stderr, " %06x%s%s=%lu", (unsigned)m->cmdSeen[k],
                        sy ? ":" : "", sy ? sy : "", m->cmdCount[k]);
            }
        }
        fprintf(stderr, "\n");
    }
        if (m->echoExpired > 0)
        fprintf(stderr, "mtu: %lu stale command echo(es) withdrawn from readers "
                "that were not listening when the command passed "
                "(YAGPC_MTU_ECHO_EXPIRE)\n", m->echoExpired);
        if (m->iuarLocal > 0)
        fprintf(stderr, "mtu: %lu listener IUAR-setting command(s) kept off the "
                "wire (YAGPC_MTU_IUAR)\n", m->iuarLocal);
    if (m->raceChecks > 0)
        fprintf(stderr, "mtu: %lu call(s) checked; another computer had changed "
                "the shared clock underneath %lu of them and the armed count "
                "under %lu command(s) -- a floor, collisions mid-call are not "
                "seen%s\n", m->raceChecks, m->raceShared, m->raceArmed,
                mtumodel_locked_mode() ? " (YAGPC_MTU_LOCKED: should be 0)" : "");
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

size_t mtumodel_clear_input(struct MtuModel *m, int gpcId) {
    if (m == NULL || gpcId < 1 || gpcId >= MTU_READERS) return 0;
    size_t n = 0;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&m->lock);
#endif
    for (int b = 0; b < MTU_NBUS; b++) {
        n += (size_t)(m->count[b][gpcId] + m->biteLeft[b][gpcId] + m->mdm[b][gpcId]
                      + m->carryLeft[b][gpcId] + (m->echoPending[b][gpcId] ? 1 : 0));
        if (m->wlN[b] > m->wlCur[b][gpcId]) n += m->wlN[b] - m->wlCur[b][gpcId];
        m->count[b][gpcId] = 0; m->biteLeft[b][gpcId] = 0; m->mdm[b][gpcId] = 0;
        m->carryLeft[b][gpcId] = 0; m->carryHead[b][gpcId] = 0;
        m->echoPending[b][gpcId] = false; m->sent[b][gpcId] = 0;
        m->wlCur[b][gpcId] = m->wlN[b];
        m->wlLookUs[b][gpcId] = 0.0;
    }
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&m->lock);
#endif
    return n;
}
