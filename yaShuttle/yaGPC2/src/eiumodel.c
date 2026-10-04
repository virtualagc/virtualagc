/* THE MAIN ENGINES BEHIND THEIR EIUs -- see eiumodel.h.
 *
 * SOURCES.  The bus programs: FIOHFBCE:569-760 (the 6-word HFE reads,
 * FIOHI1EI X'4005', 25 Hz) and 1360-1425 (the 2-word commands, FIOHO107
 * X'4C001', on all four of FC5-8), FIOMFBCE:851-960 (the 32-word MFE read,
 * FIOFAIC5 X'401F', 6.25 Hz); the SSME SOP, APPLSRC GPTSSM.hal, and the
 * launch sequence, GSRRSL.hal; STS 83-0026-34 Sequencers 4.8.2 (pp. 495-510)
 * and JSC-12770 Vol 8A (MPS) 3-110 to 3-121 for the words; SCOM 2.16 for the
 * EIUs' wiring.
 *
 * THE WIRING.  Each EIU has four ports, one on each of FC5-8.  It sends its
 * controller's PRIMARY data (VDT words 1-32) only through its first port --
 * EIU1 on bus 14, EIU2 on 15, EIU3 on 16 -- and its SECONDARY data (words
 * 1-6) only through its fourth, all three on bus 17.  Commands come in on
 * all four; the controller votes them.
 *
 * THE WORDS (VDT; bit 0 is the most significant):
 *   1  an identification word        2  its complement -- else CHANNEL FAIL
 *   3  status: command status (bits 1-2: 11 accepted, 01 rejected for
 *      BCH/vote, 10 not allowed now), channel errors (3-5), limit control
 *      (7), phase (0x00E0: 2 start prep, 3 start, 4 mainstage, 5 shutdown,
 *      6 post-shutdown), mode (0x001C), self-test (14-15: 01 good)
 *   4  time reference, 20 ms a count -- must change from read to read, or
 *      the data is stale; here, counted from the last phase change, which
 *      is what PASS's "shutdown phase with time < 1.48 s" test implies
 *   5  hard-failure identification   6  chamber pressure, % = counts x
 *      CGPS_CPRESS (about 24,111 counts at 100%)
 *   7-32  flows, pump speeds: downlist only, zero here
 *
 * WHAT PASS HOLDS THE ENGINES TO (GPTSSM, GSRRSL, GSSSSM):
 *   - COMMAND ACCEPTED IS REPORTED ONLY FOR A NEW COMMAND, on the next read
 *     of each path: after SRB ignition the last command is re-sent every
 *     cycle, and "accepted" with nothing new, or nothing within 3 cycles of
 *     something new, is a COMMAND PATH FAIL.
 *   - ENGINE READY (phase 2 mode 6) on all three by T-6.5 s, or a hold.
 *   - START: >= 90% chamber pressure 4.6 s after the start command, or that
 *     engine is shut down; SRB ignition 6.6 s after the first start.
 *   - Nothing in phase 5 or 6 before MECO, or the engine is declared failed.
 *   - MECO: SHUTDOWN ENABLE and SHUTDOWN, then all three below 30%.
 * ------------------------------------------------------------------- */
#include "eiumodel.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

#define EIU_READ_HFE  0x04005u     /* FIOHI1EI: 6 words  */
#define EIU_READ_MFE  0x0401Fu     /* FIOFAIC5: 32 words */
#define EIU_COMMAND   0x4C001u     /* FIOHO107: 2 words  */

enum { PH_PREP = 2, PH_START = 3, PH_MAIN = 4, PH_SHUT = 5, PH_POST = 6 };

/* CGPS_CPRESS, % per count (CGCUN1.hal:945-963), engines 1-3 */
static const double CPRESS[4] = { 0, .0041474997, .0041537471, .0041524991 };

typedef struct {
    int phase, mode;
    double phaseT;               /* when the phase began: the time word's zero */
    double pc, pcAt;             /* chamber pressure (%) and when it was last brought up */
    double target;               /* commanded throttle (%) */
    double startT, shutT, shutPc;
    bool limitOn, startEn, shutEn, started;
    uint32_t lastCmd;            /* the last command word heard (0 = none) */
    int pend[2];                 /* command status owed to the primary / secondary path */
    long cmds, accepted, rejected, reads;
} Eng;

static Eng eng[4];
static bool inited;

static void init(void) {
    if (inited) return;
    inited = true;
    for (int e = 1; e <= 3; e++) {
        memset(&eng[e], 0, sizeof eng[e]);
        eng[e].phase = PH_PREP;
        eng[e].mode = 6;             /* ENGINE READY: the purges are the ground's */
        eng[e].target = 100.0;
    }
}

static int engine_of_iua(unsigned iua) { return iua == 17 ? 1 : iua == 23 ? 2 : iua == 24 ? 3 : 0; }
static int primary_bus(int e) { return 13 + e; }       /* 14, 15, 16 */

int eiu_engine(int busID, uint32_t cmd) {
    if (busID < 14 || busID > 17) return 0;
    return engine_of_iua((cmd >> 19) & 0x1fu);
}

bool eiu_is_command(uint32_t cmd) { return (cmd & 0x7ffffu) == EIU_COMMAND; }

static void set_phase(Eng *s, int phase, int mode, double t) {
    if (phase != s->phase) s->phaseT = t;
    s->phase = phase;
    s->mode = mode;
}

/* Bring engine e up to time t. */
static void update(int e, double t) {
    Eng *s = &eng[e];
    if (s->phase == PH_START || s->phase == PH_MAIN) {
        double tau = t - s->startT;
        if (s->phase == PH_START) {
            if (tau >= 2.4) set_phase(s, PH_MAIN, 1, s->startT + 2.4);
            else if (tau >= 1.5) s->mode = 2;            /* thrust buildup */
        }
        if (tau < 3.5) {
            /* START: nothing for half a second, then a smooth rise to the
             * commanded level by 3.5 s -- well inside the 4.6 s at which
             * PASS wants 90%. */
            double f = tau < 0.5 ? 0.0 : 0.5 - 0.5 * cos(3.14159265358979 * (tau - 0.5) / 3.0);
            s->pc = s->target * f;
        } else {
            /* MAINSTAGE: slew toward the commanded throttle at 10%/s */
            double dt = t - s->pcAt;
            if (dt < 0.0) dt = 0.0;
            double step = 10.0 * dt;
            if (s->pc < s->target) s->pc = fmin(s->target, s->pc + step);
            else s->pc = fmax(s->target, s->pc - step);
        }
    } else if (s->phase == PH_SHUT || s->phase == PH_POST) {
        /* SHUTDOWN: the thrust decays with the time constant PASS itself
         * assumes -- its MECO cutoff leads by a tail-off of 0.958 s at the
         * engines' current thrust (CGGS_T_TAILOFF, three engines; GG42ND
         * step 87).  At 0.25 s the vehicle cut off 63 ft/s short of the
         * targeted velocity.  The status words still go to post-shutdown
         * at 2 s. */
        double tau = t - s->shutT;
        s->pc = s->shutPc * exp(-tau / 0.958);
        if (s->pc < 0.5) s->pc = 0.0;
        if (s->phase == PH_SHUT) {
            s->mode = tau < 0.1 ? 1 : tau < 0.8 ? 2 : 3;
            if (tau >= 2.0) set_phase(s, PH_POST, 1, s->shutT + 2.0);
        }
    } else {
        s->pc = 0.0;
    }
    s->pcAt = t;
}

int eiu_read_words(int busID, uint32_t cmd, int armed) {
    int e = eiu_engine(busID, cmd);
    if (e == 0) return 0;
    uint32_t f = cmd & 0x7ffffu;
    if (f == EIU_READ_HFE && (busID == primary_bus(e) || busID == 17)) return armed > 0 ? armed : 6;
    if (f == EIU_READ_MFE && busID == primary_bus(e)) return armed > 0 ? armed : 32;
    return 0;
}

bool eiu_reply(int busID, uint32_t cmd, int n, uint16_t *out, double t) {
    int e = eiu_engine(busID, cmd);
    if (e == 0) return false;
    init();
    Eng *s = &eng[e];
    update(e, t);
    s->reads++;
    int path = (busID == 17) ? 1 : 0;
    for (int i = 0; i < n; i++) out[i] = 0;
    uint16_t id = (uint16_t)(0x0E00u | (unsigned)e);
    unsigned stat = (unsigned)s->pend[path] << 13;
    s->pend[path] = 0;
    stat |= (s->limitOn ? 0x0100u : 0) | ((unsigned)(s->phase & 7) << 5) |
            ((unsigned)(s->mode & 7) << 2) | 0x0001u;
    double tc = (t - s->phaseT) / 0.020;
    if (tc < 0.0) tc = 0.0;
    int pcc = (int)lround(s->pc / CPRESS[e]);
    if (pcc > 32767) pcc = 32767;
    uint16_t w[6] = { id, (uint16_t)~id, (uint16_t)stat, (uint16_t)((unsigned long)tc & 0xffffu),
                      0, (uint16_t)pcc };
    for (int i = 0; i < n && i < 6; i++) out[i] = w[i];
    return true;
}

static void status_for(Eng *s, int st) { s->pend[0] = s->pend[1] = st; }

void eiu_command(int busID, uint32_t cmd, const uint16_t *w, int n, double t) {
    int e = eiu_engine(busID, cmd);
    if (e == 0 || n < 1) return;
    init();
    Eng *s = &eng[e];
    uint32_t word = ((uint32_t)w[0] << 16) | (n > 1 ? w[1] : 0);
    /* THE SAME COMMAND ON THE OTHER PORTS, or again next cycle: not new.  A
     * zero word is no command at all, but it ends the last one, so the same
     * command after it is new again (before SRB ignition PASS clears the
     * word every cycle after sending it). */
    if (word == s->lastCmd) return;
    s->lastCmd = word;
    if (w[0] == 0) return;
    update(e, t);
    s->cmds++;
    unsigned c = w[0] & 0xff00u;
    int ok = 3;                                /* 11 accepted; 2 = 10 not allowed now */
    if (c >= 0x4700u && c <= 0x7300u) {        /* throttle: (K + 6) << 8, K 65..109 */
        s->target = (double)((c >> 8) - 6);
    } else switch (c) {
    case 0x8F00: s->startEn = true; break;                              /* start enable */
    case 0x8100:                                                        /* start */
        if (s->startEn && s->phase == PH_PREP) {
            s->started = true;
            s->startT = t;
            set_phase(s, PH_START, 1, t);
        } else ok = 2;
        break;
    case 0x8A00: s->shutEn = true; break;                               /* shutdown enable */
    case 0x9C00:                                                        /* shutdown */
        if (s->phase == PH_SHUT || s->phase == PH_POST) break;          /* again: fine */
        if (s->shutEn && (s->phase == PH_START || s->phase == PH_MAIN)) {
            s->shutT = t;
            s->shutPc = s->pc;
            set_phase(s, PH_SHUT, 1, t);
        } else if (!s->shutEn) ok = 2;
        break;
    case 0x8900: s->limitOn = true; break;                              /* limit enable */
    case 0x8800: s->limitOn = false; break;                             /* limit inhibit */
    case 0x9B00: break;                                                 /* DCU switch */
    case 0x9100: if (s->phase == PH_POST) s->mode = 2; else ok = 2; break;   /* LO2 dump */
    case 0x9200: if (s->phase == PH_POST) s->mode = 3; else ok = 2; break;   /* LH2 dump */
    case 0x9000: if (s->phase == PH_POST) s->mode = 7; break;           /* terminate sequence */
    default: ok = 2; break;
    }
    if (ok == 3) s->accepted++; else s->rejected++;
    status_for(s, ok);
    fprintf(stderr, "eiu: ME%d %04x%04x %s at t=%.3f -- phase %d mode %d, %.1f%%\n", e, w[0],
            n > 1 ? w[1] : 0, ok == 3 ? "accepted" : "REJECTED", t, s->phase, s->mode, s->pc);
}

double eiu_pc_percent(int e, double t) {
    if (e < 1 || e > 3) return 0.0;
    init();
    update(e, t);
    return eng[e].pc;
}

#define SAVE_PER 16
int eiu_save(double *b, int max) {
    init();
    int n = 0;
    for (int e = 1; e <= 3; e++) {
        Eng *s = &eng[e];
        double v[SAVE_PER] = { s->phase, s->mode, s->phaseT, s->pc, s->pcAt, s->target, s->startT,
                               s->shutT, s->shutPc, s->limitOn, s->startEn, s->shutEn, s->started,
                               (double)s->lastCmd, s->pend[0], s->pend[1] };
        for (int i = 0; i < SAVE_PER; i++) { if (n < max) b[n] = v[i]; n++; }
    }
    return n;
}

void eiu_load(const double *b, int n, double tCap) {
    if (n != 3 * SAVE_PER) return;
    init();
    for (int e = 1, j = 0; e <= 3; e++) {
        Eng *s = &eng[e];
        s->phase = (int)b[j++]; s->mode = (int)b[j++]; s->phaseT = b[j++] - tCap;
        s->pc = b[j++]; s->pcAt = b[j++] - tCap; s->target = b[j++];
        s->startT = b[j++] - tCap; s->shutT = b[j++] - tCap; s->shutPc = b[j++];
        s->limitOn = b[j++] != 0; s->startEn = b[j++] != 0; s->shutEn = b[j++] != 0;
        s->started = b[j++] != 0; s->lastCmd = (uint32_t)b[j++];
        s->pend[0] = (int)b[j++]; s->pend[1] = (int)b[j++];
    }
}

void eiu_report(void) {
    if (!inited) return;
    for (int e = 1; e <= 3; e++) {
        Eng *s = &eng[e];
        if (s->reads == 0 && s->cmds == 0) continue;
        fprintf(stderr, "eiu: ME%d %ld read(s), %ld command(s) (%ld accepted, %ld rejected); "
                        "phase %d mode %d, %.1f%%%s\n", e, s->reads, s->cmds, s->accepted,
                s->rejected, s->phase, s->mode, s->pc, s->started ? ", started" : "");
    }
}
