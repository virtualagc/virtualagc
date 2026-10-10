/* THE STAR TRACKERS' MOUNTING (startrk.c, YAGPC_STARTRK_MOUNT).
 *
 * With YAGPC_STARTRK_MOUNT=flown the trackers take STS-134's own CGYS_TNBST
 * (DASS_G2.ASC #PCGYSTA+0076) instead of the tape's: each tracker's frame
 * must stay orthonormal and turn from the tape's by the documented angles,
 * 0.347 deg (-Z) and 0.222 deg (-Y) (RENDEZVOUS_PLAN 5k), its boresight by
 * 0.238 and 0.218 deg.  The tape's matrices are repeated here so that the
 * flown ones are checked against them independently of startrk.c. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/startrk.h"

#define PI 3.14159265358979323846     /* as test_startrk_target.c: strict C11 has no M_PI */

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (!ok) failures++;
    printf("%s [startrk_mount] %s: %.6f (want %.6f)\n", ok ? "ok  " : "FAIL", what, got, want);
}

static const double TAPE[3][3][3] = {
    { { 0 } },
    { { -0.00651344657, 0.999492586, -0.0311769098 },
      { 0.989126801, 0.00185892172, -0.147052646 },
      { -0.146920085, -0.0314957425, -0.98863709 } },
    { { -0.965746284, -0.184594095, 0.182370245 },
      { -0.186074317, 0.00279755401, -0.982531488 },
      { 0.180859327, -0.982810736, -0.0370500423 } },
};
static const double NB[3][3] = {
    { 0.98293535, 0.0, -0.18395135 },
    { 0.0, 1.0, 0.0 },
    { 0.18395135, 0.0, 0.98293535 },
};

int main(void) {
    setenv("YAGPC_STARTRK_MOUNT", "flown", 1);
    const double want[3] = { 0, 0.3469, 0.2221 }, wantB[3] = { 0, 0.2375, 0.2181 };
    for (int k = 1; k <= 2; k++) {
        double F[3][3], T[3][3];
        startrk_test_mount(k, F);
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                T[i][j] = TAPE[k][i][0] * NB[j][0] + TAPE[k][i][1] * NB[j][1] + TAPE[k][i][2] * NB[j][2];
        double orth = 0, tr = 0;
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++) {
                double d = F[i][0] * F[j][0] + F[i][1] * F[j][1] + F[i][2] * F[j][2] - (i == j);
                if (fabs(d) > orth) orth = fabs(d);
                tr += F[i][j] * T[i][j];                   /* trace(F T^T) */
            }
        double ang = acos(fmin(1.0, (tr - 1.0) / 2.0)) * 180.0 / PI;
        /* (the tape's rows are unit only to ~1e-5, which near 1 moves an
         * unnormalised arccos by a tenth of a degree) */
        double nf = sqrt(F[2][0] * F[2][0] + F[2][1] * F[2][1] + F[2][2] * F[2][2]);
        double nt = sqrt(T[2][0] * T[2][0] + T[2][1] * T[2][1] + T[2][2] * T[2][2]);
        double b = acos(fmin(1.0, (F[2][0] * T[2][0] + F[2][1] * T[2][1] + F[2][2] * T[2][2]) / (nf * nt)))
                   * 180.0 / PI;
        char w[64];
        snprintf(w, sizeof w, "tracker %d orthonormal (max error)", k);
        check(orth < 1e-6, w, orth, 0.0);
        snprintf(w, sizeof w, "tracker %d turned from the tape's (deg)", k);
        check(fabs(ang - want[k]) < 0.002, w, ang, want[k]);
        snprintf(w, sizeof w, "tracker %d boresight moved (deg)", k);
        check(fabs(b - wantB[k]) < 0.002, w, b, wantB[k]);
    }
    printf("startrk_mount: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
