/* THE MAIN ENGINES BEHIND THEIR EIUs (eiumodel.c): an engine failure.
 *
 * YAGPC_SSME_FAIL=2@10 must take engine 2 -- and only engine 2 -- to the
 * shutdown phase 10 s after SRB ignition (the first engine's start plus
 * 6.6 s), as a SHUTDOWN command would: status phase 5, the time word
 * restarting near 0 and counting on (PASS's GPTSSM wants phase 5 with the
 * time under 74 counts on three consecutive reads), the chamber pressure
 * decaying from where it was, post-shutdown (phase 6) at 2 s.  The other
 * two engines run on.  The engines are started through their commands,
 * START ENABLE then START, 120 ms apart as the launch sequence does. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "../src/eiumodel.h"

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (!ok) failures++;
    printf("%s [eiumodel] %s: %.3f (want %.3f)\n", ok ? "ok  " : "FAIL", what, got, want);
}

static const unsigned IUA[4] = { 0, 17, 23, 24 };

static uint32_t command_word(int e) { return ((uint32_t)IUA[e] << 19) | 0x4C001u; }
static uint32_t read_word(int e) { return ((uint32_t)IUA[e] << 19) | 0x04005u; }

static void command(int e, uint16_t c, double t) {
    uint16_t w[2] = { c, 0 };
    eiu_command(13 + e, command_word(e), w, 2, t);
    uint16_t z[2] = { 0, 0 };                 /* the word cleared, as PASS does */
    eiu_command(13 + e, command_word(e), z, 2, t);
}

/* phase and time word from a primary-path read */
static void status(int e, double t, int *phase, int *tc) {
    uint16_t out[6];
    eiu_reply(13 + e, read_word(e), 6, out, t);
    *phase = (out[2] >> 5) & 7;
    *tc = out[3];
}

int main(void) {
    setenv("YAGPC_SSME_FAIL", "2@10", 1);
    /* the launch sequence: engine 3, then 2, then 1, 120 ms apart */
    double tStart[4] = { 0, 0.24, 0.12, 0.0 };
    for (int e = 3; e >= 1; e--) {
        command(e, 0x8F00, tStart[e]);
        command(e, 0x8100, tStart[e]);
    }
    double tIgn = 0.0 + 6.6;                  /* first start + 6.6 s */
    int ph, tc;

    /* at 9.9 s after ignition every engine is in mainstage near 100% */
    double t = tIgn + 9.9;
    for (int e = 1; e <= 3; e++) {
        status(e, t, &ph, &tc);
        check(ph == 4, e == 2 ? "ME2 still mainstage before its failure (phase)" : "mainstage (phase)", ph, 4);
    }
    double pcBefore = eiu_pc_percent(2, t);
    check(fabs(pcBefore - 100.0) < 0.5, "ME2 at 100% before the failure (%)", pcBefore, 100.0);

    /* 10.04 s: ME2 has failed -- phase 5, the time word just restarted */
    t = tIgn + 10.04;
    status(2, t, &ph, &tc);
    check(ph == 5, "ME2 in the shutdown phase just after its failure time (phase)", ph, 5);
    check(tc <= 3, "ME2's time word restarted at the failure (20 ms counts)", tc, 0);
    int tc1 = tc;
    /* three consecutive 25 Hz reads, the time word changing and under 74 */
    int okReads = 1;
    for (int i = 1; i <= 3; i++) {
        int tcn;
        status(2, t + 0.04 * i, &ph, &tcn);
        if (ph != 5 || tcn <= tc1 || tcn >= 74) okReads = 0;
        tc1 = tcn;
    }
    check(okReads, "three more reads: phase 5, time word rising and under 74 (1 = yes)", okReads, 1);
    for (int e = 1; e <= 3; e += 2) {
        status(e, t, &ph, &tc);
        check(ph == 4, "the other engines still in mainstage (phase)", ph, 4);
        double pc = eiu_pc_percent(e, t);
        check(fabs(pc - 100.0) < 0.5, "the other engines still at 100% (%)", pc, 100.0);
    }

    /* 1 s on: decaying with the 0.958 s time constant */
    double pc1 = eiu_pc_percent(2, tIgn + 11.0);
    double want = pcBefore * exp(-(11.0 - 10.0) / 0.958);
    check(fabs(pc1 - want) < 5.0, "ME2's chamber pressure decaying 1 s after (%)", pc1, want);

    /* 2.5 s on: post-shutdown */
    status(2, tIgn + 12.6, &ph, &tc);
    check(ph == 6, "ME2 post-shutdown 2.5 s after its failure (phase)", ph, 6);
    status(1, tIgn + 12.6, &ph, &tc);
    check(ph == 4, "ME1 still mainstage (phase)", ph, 4);

    printf("eiumodel: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
