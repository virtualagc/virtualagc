/* THE MAIN PROPULSION VALVES AND THE VENT DOORS -- see valvemodel.h.
 *
 * Each valve or door moves as the GPCs' own discrete OUTPUTS drive it and
 * reports its position on the discrete INPUTS, as the hardware does.  The
 * command and indication bits are the flight software's (CGBOBF.hal and
 * CGBIH1.hal REPLACE names; the launch sequence GSRRSL.hal, the vent door
 * sequencer GSQASC.hal through INCL80/GSOVEN.hal, the separation sequence
 * GSTETS.hal, MPS SOP GSSSSM.hal); valve types and pad states from SCOM 2.16
 * and 2.17 and STS 83-0026-34 Sequencers.
 *
 * Commands are LEVELS: a valve is driven open while any of its open
 * commands is set in an MDM's output channel, closed while any close command
 * is.  A spring-loaded "normally open" valve opens when no close command
 * holds it.  The words come from mdmdev.c's record of the outputs (faOut,
 * ffOut: a reset word then a set word, kept as the net state).
 *
 * WHAT THE LAUNCH SEQUENCE CHECKS (and why this model exists):
 *   - LO2 POGO recirculation valves PV20/21 OPEN at T-6.5 s (FA3/FA4 HFE
 *     word 22, 0x0200), else RS hold 10.  Spring-open; the GROUND holds them
 *     closed during loading and the onboard sequence lets go at T-9.5 s --
 *     here the ground's hold ends when the Launch Processing System sends GO
 *     FOR AUTO SEQUENCE (lpsmodel.c), at T-31 s.
 *   - LH2 prevalves OPEN from T-4 s (PASS opens them at T-6.5 s), else an
 *     engine hold.
 *   - LO2 overboard bleed valve CLOSED from T-4 s (PASS closes it from
 *     T-5 s), else RS hold 14.  Spring-open.
 *   - Every vent door OPEN within 6.4 s of its group's open command --
 *     the vent sequencer samples the feedback only that long (GSQASC) -- or
 *     RS hold 6 at T-4 s.  Doors take 5 s with both motors (SCOM 2.17).
 * And for the separations: the LO2 prevalves, the 17-inch feedline
 * disconnect valves and the ET umbilical latches (GSTETS), whose indications
 * read zero otherwise -- SEP INH at MECO.
 * ------------------------------------------------------------------- */
#include "valvemodel.h"

#include <stdio.h>
#include <string.h>

#include "lpsmodel.h"

/* An output bit: MDM ('F' forward, 'A' aft), units as a bit set (1<<k),
 * DOH card, channel, mask. */
typedef struct { char mdm; unsigned units; unsigned card, ch; uint16_t mask; } Out;
/* An input bit: MDM, units, word (FA: the HFE read's word; FF: DSCRT n-1),
 * mask. */
typedef struct { char mdm; unsigned units; int word; uint16_t mask; } In;

#define U(a) (1u << (a))
#define MAXO 6
#define MAXI 4

typedef struct {
    const char *name;
    Out open[MAXO];
    Out close[MAXO];
    bool springOpen;            /* opens with no close command */
    bool groundHeld;            /* the ground holds it closed until GO FOR AUTO SEQUENCE */
    double stroke;              /* s, end to end */
    double padPos;              /* 0 closed .. 1 open */
    In openInd[MAXI];           /* ON when fully open */
    In closedInd[MAXI];         /* ON when fully closed */
} Valve;

/* The tables.  Unknown A/B/C assignment of a command copy to an MDM is no
 * matter: any copy set drives the valve. */
static const Valve V[] = {
    { "LO2 POGO RECIRC PV20", {{0}}, { { 'A', U(1)|U(2)|U(3)|U(4), 12, 0, 0x8000 } },
      true, true, 1.0, 0.0, { { 'A', U(3), 22, 0x0200 } }, {{0}} },
    { "LO2 POGO RECIRC PV21", {{0}}, { { 'A', U(1)|U(2)|U(3)|U(4), 12, 0, 0x8000 } },
      true, true, 1.0, 0.0, { { 'A', U(4), 22, 0x0200 } }, {{0}} },
    { "E1 LH2 PREVALVE PV4", { { 'A', U(1)|U(2)|U(3), 7, 0, 0x0040 } },
      { { 'A', U(1)|U(2)|U(3), 7, 0, 0x0020 } }, false, false, 1.0, 0.0,
      { { 'A', U(1)|U(3), 18, 0x0010 } }, {{0}} },
    { "E2 LH2 PREVALVE PV5", { { 'A', U(1)|U(2)|U(4), 15, 0, 0x0040 } },
      { { 'A', U(1)|U(2)|U(4), 15, 0, 0x0020 } }, false, false, 1.0, 0.0,
      { { 'A', U(2)|U(4), 18, 0x0010 } }, {{0}} },
    { "E3 LH2 PREVALVE PV6", { { 'A', U(1)|U(2)|U(4), 12, 0, 0x0040 } },
      { { 'A', U(1)|U(2)|U(4), 12, 0, 0x0020 } }, false, false, 1.0, 0.0,
      { { 'A', U(3)|U(4), 22, 0x0100 } }, {{0}} },
    { "LO2 OVERBOARD BLEED PV19", {{0}}, { { 'A', U(2)|U(3)|U(4), 12, 0, 0x4000 } },
      true, false, 0.5, 1.0, {{0}}, { { 'A', U(2)|U(3), 23, 0x0008 } } },
    { "E1 LO2 PREVALVE", { { 'A', U(1)|U(2)|U(3), 7, 0, 0x0100 }, { 'A', U(4), 7, 1, 0x0080 } },
      { { 'A', U(1)|U(2)|U(3), 7, 0, 0x0080 }, { 'A', U(4), 7, 1, 0x0040 } }, false, false,
      1.0, 1.0, { { 'A', U(1), 23, 0x0040 } }, {{0}} },
    { "E2 LO2 PREVALVE", { { 'A', U(1)|U(2)|U(3), 15, 0, 0x0100 }, { 'A', U(4), 7, 1, 0x0010 } },
      { { 'A', U(1)|U(2)|U(3), 15, 0, 0x0080 }, { 'A', U(4), 7, 1, 0x0008 } }, false, false,
      1.0, 1.0, { { 'A', U(2), 23, 0x0040 } }, {{0}} },
    { "E3 LO2 PREVALVE", { { 'A', U(1)|U(2)|U(4), 12, 0, 0x0100 }, { 'A', U(3), 7, 1, 0x0080 } },
      { { 'A', U(1)|U(2)|U(4), 12, 0, 0x0080 }, { 'A', U(3), 7, 1, 0x0040 } }, false, false,
      1.0, 1.0, { { 'A', U(4), 23, 0x0040 } }, {{0}} },
    { "LO2 17-IN FEEDLINE DISCONNECT", { { 'A', U(2)|U(3)|U(4), 15, 0, 0x0004 } },
      { { 'A', U(2)|U(3)|U(4), 15, 0, 0x0008 } }, false, false, 1.0, 1.0,
      {{0}}, { { 'A', U(2)|U(3), 23, 0x0020 } } },
    { "LH2 17-IN FEEDLINE DISCONNECT", { { 'A', U(2)|U(3)|U(4), 7, 0, 0x0004 } },
      { { 'A', U(2)|U(3)|U(4), 7, 0, 0x0008 } }, false, false, 1.0, 1.0,
      { { 'A', U(2)|U(4), 18, 0x0004 } }, { { 'A', U(2)|U(4), 18, 0x0008 } } },
    /* The ET umbilical disconnect latches, LO2 and LH2 together: "open" is
     * UNLOCKED.  FA1/FA2 report LOCKED, FA3/FA4 UNLOCKED. */
    { "ET UMBILICAL LATCHES", { { 'A', U(2)|U(3)|U(4), 12, 1, 0x0600 } }, {{0}}, false, false,
      0.5, 0.0, { { 'A', U(3)|U(4), 24, 0x000C } }, { { 'A', U(1)|U(2), 24, 0x000C } } },
    /* THE VENT DOORS, by sequencer group (GSQASC/GSOVEN; FSSR Table 4.1-1).
     * Feedback ON = OPEN.  On the pad they stand at PURGE: not open. */
    { "VENT DOORS GRP 1 (FWD 1&2)", { { 'F', U(1)|U(2)|U(3)|U(4), 2, 0, 0x4000 },
                                     { 'F', U(1)|U(2)|U(3)|U(4), 10, 0, 0x4000 } },
      { { 'F', U(1)|U(2)|U(3)|U(4), 10, 0, 0x8000 }, { 'F', U(1)|U(2), 2, 0, 0x8000 },
        { 'F', U(3)|U(4), 2, 2, 0x0100 } }, false, false, 5.0, 0.3,
      { { 'F', U(1)|U(2)|U(3)|U(4), 2, 0x0100 } }, {{0}} },
    { "VENT DOORS GRP 2 (PB 3,4,7)", { { 'F', U(1), 2, 2, 0x0040 }, { 'F', U(1), 10, 2, 0x0040 },
                                      { 'F', U(2), 2, 2, 0x0100 }, { 'F', U(2), 10, 2, 0x0100 },
                                      { 'F', U(3)|U(4), 2, 0, 0x8000 },
                                      { 'F', U(3)|U(4), 10, 0, 0x2000 } },
      { { 'F', U(2)|U(3)|U(4), 2, 2, 0x0200 }, { 'F', U(2)|U(3)|U(4), 10, 2, 0x0200 },
        { 'F', U(1), 2, 2, 0x0080 }, { 'F', U(1), 10, 2, 0x0080 } }, false, false, 5.0, 0.3,
      { { 'F', U(2)|U(3)|U(4), 2, 0x0400 }, { 'F', U(1), 2, 0x0004 } }, {{0}} },
    { "VENT DOORS GRP 3 (PB 5)", { { 'F', U(1)|U(2)|U(3)|U(4), 2, 2, 0x0001 },
                                  { 'F', U(1)|U(2)|U(3)|U(4), 10, 2, 0x0001 } },
      { { 'F', U(1)|U(3), 2, 2, 0x0002 }, { 'F', U(1)|U(2)|U(3)|U(4), 10, 2, 0x0002 },
        { 'F', U(2)|U(4), 2, 1, 0x0200 } }, false, false, 5.0, 0.3,
      { { 'F', U(1)|U(2)|U(3)|U(4), 2, 0x0001 } }, {{0}} },
    { "VENT DOORS GRP 5 (PB 6)", { { 'F', U(1)|U(2)|U(3)|U(4), 2, 2, 0x0010 },
                                  { 'F', U(1)|U(2)|U(3)|U(4), 10, 2, 0x0010 } },
      { { 'F', U(1)|U(2)|U(3)|U(4), 2, 2, 0x0020 }, { 'F', U(1)|U(2)|U(3)|U(4), 10, 2, 0x0020 } },
      false, false, 5.0, 0.3, { { 'F', U(1)|U(2)|U(3)|U(4), 2, 0x0020 } }, {{0}} },
    { "VENT DOORS GRP 6 (AFT 8&9)", { { 'A', U(1)|U(2)|U(3)|U(4), 7, 0, 0x0400 },
                                     { 'A', U(1)|U(2)|U(3)|U(4), 15, 0, 0x0800 } },
      { { 'A', U(1)|U(2)|U(3)|U(4), 7, 0, 0x0800 }, { 'A', U(1)|U(2)|U(3)|U(4), 15, 0, 0x1000 } },
      false, false, 5.0, 0.3, { { 'A', U(1)|U(2)|U(3)|U(4), 23, 0x0002 } }, {{0}} },
};
#define NV (int)(sizeof V / sizeof V[0])

static double pos[sizeof V / sizeof V[0]];
static double lastT = -1.0;
static bool started;
static uint16_t (*outWord)(char mdm, int unit, unsigned card, unsigned ch);

void valve_set_output_source(uint16_t (*fn)(char mdm, int unit, unsigned card, unsigned ch)) {
    outWord = fn;
}

static void start(void) {
    if (started) return;
    started = true;
    for (int i = 0; i < NV; i++) pos[i] = V[i].padPos;
}

static bool any_set(const Out *o) {
    if (outWord == NULL) return false;
    for (int j = 0; j < MAXO && o[j].mdm; j++)
        for (int u = 1; u <= 4; u++)
            if ((o[j].units & U(u)) && (outWord(o[j].mdm, u, o[j].card, o[j].ch) & o[j].mask))
                return true;
    return false;
}

void valve_update(double t) {
    start();
    if (lastT < 0.0) { lastT = t; return; }
    double dt = t - lastT;
    if (dt <= 0.0) return;
    lastT = t;
    for (int i = 0; i < NV; i++) {
        const Valve *v = &V[i];
        bool op = any_set(v->open), cl = any_set(v->close);
        int drive = 0;
        if (cl && !op) drive = -1;
        else if (op && !cl) drive = 1;
        else if (!op && !cl && v->springOpen) drive = 1;
        if (v->groundHeld && !lps_auto_sequence_given()) drive = -1;
        double was = pos[i];
        pos[i] += drive * dt / v->stroke;
        if (pos[i] > 1.0) pos[i] = 1.0;
        if (pos[i] < 0.0) pos[i] = 0.0;
        if ((was < 1.0 && pos[i] >= 1.0) || (was > 0.0 && pos[i] <= 0.0))
            fprintf(stderr, "valve: %s %s at t=%.3f\n", v->name, pos[i] >= 1.0 ? "OPEN" : "CLOSED", t);
    }
}

static void put(const In *in, char mdm, int unit, uint16_t *w, int nw, bool on) {
    for (int j = 0; j < MAXI && in[j].mdm; j++)
        if (on && in[j].mdm == mdm && (in[j].units & U(unit)) && in[j].word < nw)
            w[in[j].word] |= in[j].mask;
}

void valve_inputs(char mdm, int unit, uint16_t *w, int nw) {
    start();
    for (int i = 0; i < NV; i++) {
        put(V[i].openInd, mdm, unit, w, nw, pos[i] >= 1.0);
        put(V[i].closedInd, mdm, unit, w, nw, pos[i] <= 0.0);
    }
}

int valve_save(double *b, int max) {
    start();
    int n = 0;
    for (int i = 0; i < NV; i++) { if (n < max) b[n] = pos[i]; n++; }
    return n;
}

void valve_load(const double *b, int n) {
    if (n != NV) return;
    started = true;
    for (int i = 0; i < NV; i++) pos[i] = b[i];
    lastT = -1.0;
}

void valve_report(void) {
    if (!started) return;
    fprintf(stderr, "valve:");
    for (int i = 0; i < NV; i++)
        fprintf(stderr, " %s %s;", V[i].name, pos[i] >= 1.0 ? "open" : pos[i] <= 0.0 ? "closed"
                                                                       : "moving");
    fprintf(stderr, "\n");
}
