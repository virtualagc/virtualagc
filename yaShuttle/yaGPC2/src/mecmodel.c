/* THE MASTER EVENTS CONTROLLERS -- see mecmodel.h.
 *
 * SOURCES.  The bus program FIOHFODA (MLIB80/FIOHFBCE:1320-1453; on buses
 * 14-17 from the HFE output PC table), the equates (BCEEQU:329-338, 638-639),
 * the MEC SOP that fills the buffer (APPLSRC GPYMEC.hal), the launch
 * sequence and the separation sequences (GSRRSL, GSESRB, GSTETS), and STS
 * 83-0026-34 Sequencers 4.8.1 (pp. 471-480) for the command table.
 *
 * EVERY 40 ms, to each MEC on each of its four ports: a non-critical SET
 * (X'22C00', one word), a CRITICAL write (X'60003', four words: slots 1-4),
 * and a non-critical RESET (X'21C00', the SET's complement).  A master reset
 * is a command with no words (X'2C000').
 *
 * AN EVENT IS ARMED when its ARM word stands in a critical slot, and FIRES
 * when its FIRE1 and FIRE2 words stand there together with its FIRE3
 * non-critical bit -- the pyro initiator controllers need all three.  The
 * MEC's own decoding and its port vote are not documented locally (they are
 * in CPDS SS-P-0002-170); this takes any port, which for one GPC or for a
 * redundant set sending identical words is the same thing.
 * ------------------------------------------------------------------- */
#include "mecmodel.h"

#include <stdio.h>
#include <string.h>

#define MEC_CRIT  0x60003u
#define MEC_NCSET 0x22C00u
#define MEC_NCRST 0x21C00u
#define MEC_MRST  0x2C000u

static const struct {
    const char *name;
    uint16_t arm, fire1, fire2, fire3;
} EV[MEC_NEVENTS] = {
    { "T-0 UMBILICAL",       0xCEDC, 0xCE6A, 0xCE9A, 0x0800 },
    { "SRM IGNITION",        0x3EAC, 0x3E6A, 0x3E42, 0x1000 },
    { "SRB SEPARATION",      0x3154, 0x316A, 0x319B, 0x0100 },
    { "ET UMBILICAL UNLATCH",0xC121, 0xC162, 0xC193, 0x0080 },
    { "ET SEPARATION",       0xE117, 0xE168, 0xE199, 0x0001 },
};

static uint16_t slot[3][4];        /* [MEC 1-2][slot] */
static uint16_t ncset[3];
static bool armed[MEC_NEVENTS];
static double fired[MEC_NEVENTS] = { -1, -1, -1, -1, -1 };
static long writes, resets;

bool mec_owns(int busID, uint32_t cmd) {
    unsigned iua = (cmd >> 19) & 0x1fu;
    return busID >= 14 && busID <= 17 && (iua == 18u || iua == 20u);
}

int mec_words(uint32_t cmd) {
    uint32_t f = cmd & 0x7ffffu;
    return f == MEC_CRIT ? 4 : (f == MEC_NCSET || f == MEC_NCRST) ? 1 : 0;
}

static int mec_no(uint32_t cmd) { return ((cmd >> 19) & 0x1fu) == 18u ? 1 : 2; }

static bool in_slots(int m, uint16_t v) {
    for (int i = 0; i < 4; i++) if (slot[m][i] == v) return true;
    return false;
}

static void evaluate(int m, double t) {
    for (int e = 0; e < MEC_NEVENTS; e++) {
        if (!armed[e] && in_slots(m, EV[e].arm)) {
            armed[e] = true;
            fprintf(stderr, "mec: %s ARMED (MEC%d) at t=%.3f\n", EV[e].name, m, t);
        }
        if (fired[e] < 0.0 && in_slots(m, EV[e].fire1) && in_slots(m, EV[e].fire2) &&
            (ncset[m] & EV[e].fire3)) {
            fired[e] = t;
            fprintf(stderr, "mec: %s FIRED (MEC%d) at t=%.3f%s\n", EV[e].name, m, t,
                    armed[e] ? "" : " -- WITHOUT ARM");
        }
    }
}

void mec_note_command(int busID, uint32_t cmd, double t) {
    if (!mec_owns(busID, cmd) || (cmd & 0x7ffffu) != MEC_MRST) return;
    int m = mec_no(cmd);
    memset(slot[m], 0, sizeof slot[m]);
    resets++;
    /* a master reset leaves nothing armed */
    bool any = false;
    for (int e = 0; e < MEC_NEVENTS; e++) if (armed[e]) any = true;
    if (any) {
        for (int e = 0; e < MEC_NEVENTS; e++) armed[e] = false;
        fprintf(stderr, "mec: MASTER RESET (MEC%d) at t=%.3f\n", m, t);
    }
}

void mec_command(int busID, uint32_t cmd, const uint16_t *w, int n, double t) {
    if (!mec_owns(busID, cmd)) return;
    int m = mec_no(cmd);
    uint32_t f = cmd & 0x7ffffu;
    writes++;
    if (f == MEC_CRIT) {
        for (int i = 0; i < 4 && i < n; i++) slot[m][i] = w[i];
        evaluate(m, t);
    } else if (f == MEC_NCSET && n >= 1) {
        ncset[m] = w[0];
    }
}

bool mec_armed(enum MecEvent e) { return e < MEC_NEVENTS && armed[e]; }
double mec_fired_at(enum MecEvent e) { return e < MEC_NEVENTS ? fired[e] : -1.0; }

int mec_save(double *b, int max) {
    int n = 0;
    for (int e = 0; e < MEC_NEVENTS; e++) {
        if (n < max) b[n] = armed[e];
        n++;                        /* counted past max: the size a caller needs */
        if (n < max) b[n] = fired[e];
        n++;
    }
    return n;
}

void mec_load(const double *b, int n, double tCap) {
    if (n != 2 * MEC_NEVENTS) return;
    for (int e = 0, j = 0; e < MEC_NEVENTS; e++) {
        armed[e] = b[j++] != 0;
        double f = b[j++];
        fired[e] = f < 0.0 ? -1.0 : f - tCap;
    }
}

void mec_report(void) {
    if (writes == 0 && resets == 0) return;
    fprintf(stderr, "mec: %ld write(s), %ld master reset(s);", writes, resets);
    for (int e = 0; e < MEC_NEVENTS; e++)
        if (armed[e] || fired[e] >= 0.0)
            fprintf(stderr, " %s %s%s;", EV[e].name, armed[e] ? "armed" : "",
                    fired[e] >= 0.0 ? " fired" : "");
    fprintf(stderr, "\n");
}
