/* THE AIR DATA TRANSDUCER ASSEMBLIES: four ADTAs, one behind each forward
 * MDM on card 11 channel 0 (FIOHI1C2, X'26C05', six words at 25 Hz;
 * BCEEQU.asm:229-230), ADTAs 1 and 3 on the LEFT probe and 2 and 4 on the
 * RIGHT (GRXADT.hal:233-240).  Sources: ~/workspace/pass-run/entry/
 * landing-devices-findings.md section 4.
 *
 * THE WORDS (GRXADT.hal:205-211, scale factors CGYS_ADTA_SF, CGYFL1.hal
 * 193-194), pressures in INCHES OF MERCURY as signed counts -- not psi: PASS's
 * qbar is 49.5083 Psc M^2 = 0.7 (2116.2/29.921) Psc M^2 (GYGADT.hal), its
 * pressure altitude is zero at 29.92, and the counts' limits are 36 and 52:
 *   w1 status, 0x8000 good    w2 Ps, static, 1.0987e-3 inHg a count
 *   w3 Pac, the centre alpha port (near total), 1.5870e-3
 *   w4 total temperature -- unused by GN&C (GRXADT.hal:301), sent as 0
 *   w5 Pal, the lower alpha port; w6 Pau, the upper; both 1.5870e-3
 *
 * WHAT IS SENT is what PASS's own arithmetic (GYEADT.hal) turns back into the
 * vehicle's true alpha, Mach and free-stream pressure, with PASS's own tables
 * (src/adtatables.h, generated from that file by tools/adtatables.py):
 *   PASS: Psc = Ps - Cps (Pac - Ps), Ptc = Pac - Cpt (Pac - Ps),
 *         M = sqrt(5 ((Ptc/Psc)^(2/7) - 1)), alpha = cubic in
 *         R = (Pal - Pau) / (Pac - (Pal + Pau)/2), Cps and Cpt quartics in
 *         alpha, all three interpolated between Mach segments, each with a
 *         gear-down increment once CGRB_GEAR_DOWN is set (latched by PASS at
 *         5,000 ft wheel altitude, GP8HYD.hal:311-313 -- taken here the same
 *         way).
 *   here: Ptc* = p (1 + 0.2 M^2)^3.5; D = (Ptc* - p) / (1 + Cps - Cpt);
 *         Ps = p + Cps D, Pac = Ps + D; the R that PASS's cubic maps to the
 *         true alpha, by bisection; a spread d well above PASS's 0.002 inHg
 *         floor; Pal = Pac - d + R d/2, Pau = Pac - d - R d/2.
 * Mach is held to PASS's table range (0.1-3.5) and alpha to its limits
 * (-4..20 deg), where PASS clamps them anyway.  All four ADTAs send the same
 * values: healthy probes agree, and PASS's FDI passes them. */
#include <math.h>
#include <string.h>

#include "adtaair.h"
#include "adtatables.h"
#include "vehdyn.h"

#define PSF_INHG (29.921 / 2116.2)
#define SF_PS   1.0987e-3
#define SF_PA   1.5870e-3

/* GYE_MACH_RANGE: the segment index (0-based) and the ratio within it. */
static int seg(const double *b, int n, double m, double *ratio) {
    if (m < b[0]) m = b[0];
    if (m > b[n - 1]) m = b[n - 1];
    int i = 0;
    while (i < n - 2 && m > b[i + 1]) i++;
    *ratio = (m - b[i]) / (b[i + 1] - b[i]);
    return i;
}

static double quartic(const double k[5], double a) {
    return k[0] + a * (k[1] + a * (k[2] + a * (k[3] + a * k[4])));
}

/* GYE_PRESS_C: Cps (rows ADT_KS, gear row 19) or Cpt (ADT_KP, gear row 16) */
static double press_c(const double (*K)[5], int gearRow, const double *b, int nb,
                      double m, double alpha, int gear) {
    double r;
    int i = seg(b, nb, m, &r);
    double c = quartic(K[i], alpha) + r * (quartic(K[i + 1], alpha) - quartic(K[i], alpha));
    if (gear) c += quartic(K[gearRow], alpha);
    return c;
}

static double alpha_of_r(double R, double m, int gear) {
    double r;
    int i = seg(ADT_MB_AOA, 11, m, &r);
    const double *a = ADT_KA[i], *b = ADT_KA[i + 1];
    double ai = a[0] + R * (a[1] + R * (a[2] + R * a[3]));
    double aj = b[0] + R * (b[1] + R * (b[2] + R * b[3]));
    double al = ai + r * (aj - ai);
    if (gear) al += ADT_KA[11][0] + R * (ADT_KA[11][1] + R * (ADT_KA[11][2] + R * ADT_KA[11][3]));
    return al;
}

static uint16_t cnt(double v, double sf) {
    double c = floor(v / sf + 0.5);
    if (c > 32767.0) c = 32767.0;
    if (c < -32768.0) c = -32768.0;
    return (uint16_t)(int16_t)c;
}

void adta_words(int unit, uint16_t w[6]) {
    (void)unit;
    memset(w, 0, 6 * sizeof w[0]);
    double pPsf, mach, alpha, beta, q;
    if (!vehdyn_enabled() || !vehdyn_air_data(&pPsf, &mach, &alpha, &beta, &q)) return;
    double wheel = 1e9;
    vehdyn_ground_state(&wheel, NULL);
    int gear = wheel <= 5000.0;
    if (mach < 0.1) mach = 0.1;
    if (mach > 3.5) mach = 3.5;
    if (alpha < -4.0) alpha = -4.0;
    if (alpha > 20.0) alpha = 20.0;
    double p = pPsf * PSF_INHG;
    double ptc = p * pow(1.0 + 0.2 * mach * mach, 3.5);
    double cps = press_c(ADT_KS, 18, ADT_MB_SP, 18, mach, alpha, gear);
    double cpt = press_c(ADT_KP, 15, ADT_MB_PT, 15, mach, alpha, gear);
    double D = (ptc - p) / (1.0 + cps - cpt);
    double ps = p + cps * D, pac = ps + D;
    /* the port ratio PASS's cubic maps to this alpha: increasing in R */
    double lo = -2.25, hi = 1.75;
    for (int k = 0; k < 60; k++) {
        double mid = 0.5 * (lo + hi);
        if (alpha_of_r(mid, mach, gear) < alpha) lo = mid; else hi = mid;
    }
    double R = 0.5 * (lo + hi);
    double d = 0.1 * D;
    if (d < 0.02) d = 0.02;
    double pal = pac - d + R * d / 2.0, pau = pac - d - R * d / 2.0;
    w[0] = 0x8000u;
    w[1] = cnt(ps, SF_PS);
    w[2] = cnt(pac, SF_PA);
    w[3] = 0;
    w[4] = cnt(pal, SF_PA);
    w[5] = cnt(pau, SF_PA);
}

/* FF n's DSCRT8 (word 7): 0x0020 its side's probe deployed, 0x0010 stowed
 * (CGBIH1.hal:2689-2690) -- the probe's limit switches. */
uint16_t adta_probe_bits(int unit) {
    double pos[2];
    vehdyn_probes(pos);
    double p = pos[(unit == 2 || unit == 4) ? 1 : 0];
    return p >= 1.0 ? 0x0020u : p <= 0.0 ? 0x0010u : 0u;
}
