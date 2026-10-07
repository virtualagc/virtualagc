/* The landing aids (src/landaids.c) seen from a vehicle on final approach to
 * KSC 15: the MSBLS words decode to the azimuth, elevation and range that the
 * site's own geometry predicts, and the radar altimeter reads the antenna's
 * height with odd parity.  The site is tools/sites/ksc-navaids.txt, the same
 * file a run reads. */
#define _POSIX_C_SOURCE 200809L
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "../src/landaids.h"
#include "../src/adtaair.h"
#include "../src/adtatables.h"
#include "../src/vehdyn.h"

#define PI 3.14159265358979323846
#define FT 0.3048

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [landaids/%s] got %.6g want %.6g\n", what, got, want);
}

/* PASS's GNKGEO, ft */
static void geo_ef(double lat, double lon, double alt, double r[3]) {
    double f = 1.0 / 298.3, d = (1 - f) * (1 - f), c = cos(lat), s = sin(lat);
    double n = 20925646.3255 / sqrt(c * c + s * s * d);
    r[0] = (n + alt) * c * cos(lon);
    r[1] = (n + alt) * c * sin(lon);
    r[2] = (d * n + alt) * s;
}

int main(void) {
    setenv("YAGPC_VEHDYN", "1", 1);
    setenv("YAGPC_NAVAIDS", "tools/sites/ksc-navaids.txt", 1);
    /* KSC 15's threshold and landing azimuth, as the navaids file has them */
    double lat0 = 0.49973583221435547, lon0 = -1.4085865020751953, az = 2.6178817749023438;
    double alt0 = 8.3, back = 30380.0, hgt = 1500.0;   /* 5 n.mi. short, 1500 ft up */
    /* the point on the extended centreline, by the local north/east */
    double A = 20925646.3255, f = 1.0 / 298.3, e2 = f * (2 - f), s0 = sin(lat0);
    double N = A / sqrt(1 - e2 * s0 * s0), M = A * (1 - e2) / pow(1 - e2 * s0 * s0, 1.5);
    double lat = lat0 - back * cos(az) / M, lon = lon0 - back * sin(az) / (N * cos(lat0));
    double rEf[3];
    geo_ef(lat, lon, alt0 + hgt, rEf);
    for (int i = 0; i < 3; i++) rEf[i] *= FT;

    vehdyn_reset(0.0);
    double Me[3][3], pole[3], r[3], v[3], we = phys_earth_rate();
    phys_inertial_to_earth(0.0, Me);
    phys_earth_pole(pole);
    for (int i = 0; i < 3; i++) r[i] = Me[0][i] * rEf[0] + Me[1][i] * rEf[1] + Me[2][i] * rEf[2];
    v[0] = we * (pole[1] * r[2] - pole[2] * r[1]);
    v[1] = we * (pole[2] * r[0] - pole[0] * r[2]);
    v[2] = we * (pole[0] * r[1] - pole[1] * r[0]);
    vehdyn_set_rv(r, v);
    /* level, nose along the landing azimuth */
    double sl = sin(lat), cl = cos(lat), so = sin(lon), co = cos(lon);
    double Nf[3] = { -sl * co, -sl * so, cl }, Ef[3] = { -so, co, 0 }, Df[3] = { -cl * co, -cl * so, -sl };
    double X[3], Y[3], R[3][3];
    for (int i = 0; i < 3; i++) {
        X[i] = cos(az) * Nf[i] + sin(az) * Ef[i];
        Y[i] = -sin(az) * Nf[i] + cos(az) * Ef[i];
    }
    for (int i = 0; i < 3; i++) {
        double xi = Me[0][i] * X[0] + Me[1][i] * X[1] + Me[2][i] * X[2];
        double yi = Me[0][i] * Y[0] + Me[1][i] * Y[1] + Me[2][i] * Y[2];
        double zi = Me[0][i] * Df[0] + Me[1][i] * Df[1] + Me[2][i] * Df[2];
        R[i][0] = xi; R[i][1] = yi; R[i][2] = zi;
    }
    double qw = 0.5 * sqrt(1.0 + R[0][0] + R[1][1] + R[2][2]);
    double q[4] = { qw, (R[2][1] - R[1][2]) / (4 * qw), (R[0][2] - R[2][0]) / (4 * qw),
                    (R[1][0] - R[0][1]) / (4 * qw) };
    double w0[3] = { 0, 0, 0 };
    vehdyn_set_attitude(q, w0);

    /* MSBLS: the KSC 15 range/azimuth station sits 13,114 ft down the runway
     * and 903 ft right of it, the elevation station 1,354 ft along and 949 ft
     * left (tools/sites/ksc.json) -- so from here, on the centreline:
     * azimuth atan(-903 / 43,494) = -1.19 deg (Y is LEFT in the scanner's
     * frame, which looks back up the approach), range 43,500 ft, elevation
     * about atan(1,500 / 31,750) = 2.7 deg. */
    uint16_t w[7];
    landaids_mls(1, w);
    check((w[0] & 1) == 0 && (w[1] & 1) == 0 && (w[2] & 1) == 0, "all three MLS words valid", w[0] & 1, 0);
    double azd = ((w[0] >> 2) & 0x1FFF) * 16.0 / 4096.0 * ((w[0] & 0x8000) ? -1 : 1);
    double eld = ((w[1] >> 2) & 0x1FFF) * 16.0 / 4096.0;
    double rng = ((w[2] >> 2) & 0x1FFF) * 10.36 / 4096.0 * 6076.1155;
    check(fabs(azd + 1.19) < 0.15, "azimuth from the far-end scanner", azd, -1.19);
    check(fabs(eld - 2.7) < 0.3, "elevation from the threshold scanner", eld, 2.7);
    check(fabs(rng - 43500.0) < 200.0, "range to the DME", rng, 43500.0);

    /* the radar altimeter: power on, valid, odd parity, the antenna's height
     * (the nav base ~4 ft above the c.g., the antenna 11.7 ft below it) */
    landaids_tacan_ra(1, w);
    unsigned ones = 0;
    for (uint16_t t = w[4]; t; t &= (uint16_t)(t - 1)) ones++;
    double ra = (w[4] >> 2) & 0x1FFF;
    check((w[5] & 0x0400u) && (w[4] & 0x0002u), "radar altimeter powered and valid", w[4], 2);
    check((ones & 1u) == 1u, "radar altimeter word has odd parity", ones, 1);
    check(fabs(ra - 1492.0) < 15.0, "radar altimeter reads the antenna's height", ra, 1492.0);

    /* out of coverage: far behind the runway -- every MLS word invalid */
    double far[3];
    for (int i = 0; i < 3; i++) far[i] = r[i] * 1.01;
    vehdyn_set_rv(far, v);
    landaids_mls(1, w);
    check(w[0] == 1 && w[1] == 1 && w[2] == 1, "out of coverage the words read invalid", w[0], 1);

    /* THE ADTAs: PASS's own arithmetic (GYEADT.hal, written out again here
     * from the HAL, not from adtaair.c) turns the words back into the
     * vehicle's Mach, alpha and pressure -- at a few points through TAEM and
     * approach, flown at them by setting the state. */
    {
        static const double pts[][3] = { { 2.4, 14.0, 60000.0 }, { 1.3, 9.0, 45000.0 },
                                         { 0.9, 6.0, 30000.0 }, { 0.5, 8.0, 8000.0 } };
        for (int k = 0; k < 4; k++) {
            double M = pts[k][0], A = pts[k][1], H = pts[k][2];
            /* climb straight up the local vertical at speed M, alpha A in pitch */
            double up[3], rn = sqrt(r[0] * r[0] + r[1] * r[1] + r[2] * r[2]);
            for (int i = 0; i < 3; i++) up[i] = r[i] / rn;
            double rr[3];
            for (int i = 0; i < 3; i++) rr[i] = r[i] + up[i] * (H - hgt) * FT;
            /* air velocity along the body X axis rotated by alpha: nose X,
             * down Z; velocity = cosA X + sinA Z, at the speed of sound there */
            double ap, am, aa, ab, aq;
            vehdyn_set_rv(rr, v);
            vehdyn_air_data(&ap, &am, &aa, &ab, &aq);
            double a0 = 0.0;                                      /* speed of sound */
            { double vv[3] = { v[0] + R[0][0] * 300, v[1] + R[1][0] * 300, v[2] + R[2][0] * 300 };
              vehdyn_set_rv(rr, vv); vehdyn_air_data(NULL, &am, NULL, NULL, NULL); a0 = 300.0 / am; }
            double sp = M * a0, ca = cos(A * PI / 180), sa = sin(A * PI / 180), vv[3];
            for (int i = 0; i < 3; i++) vv[i] = v[i] + sp * (ca * R[i][0] + sa * R[i][2]);
            vehdyn_set_rv(rr, vv);
            vehdyn_air_data(&ap, &am, &aa, &ab, &aq);
            uint16_t aw[6];
            adta_words(1, aw);
            double ps = (int16_t)aw[1] * 1.0987e-3, pac = (int16_t)aw[2] * 1.5870e-3;
            double pal = (int16_t)aw[4] * 1.5870e-3, pau = (int16_t)aw[5] * 1.5870e-3;
            /* PASS, forward: alpha first (Mach from the last cycle: the true one) */
            double dr = pac - 0.5 * (pal + pau), Rr = (pal - pau) / dr;
            int i = 0;
            while (i < 9 && am > ADT_MB_AOA[i + 1]) i++;
            double rt = (am - ADT_MB_AOA[i]) / (ADT_MB_AOA[i + 1] - ADT_MB_AOA[i]);
            const double *ka = ADT_KA[i], *kb = ADT_KA[i + 1];
            double al = ka[0] + Rr * (ka[1] + Rr * (ka[2] + Rr * ka[3]));
            al += rt * (kb[0] + Rr * (kb[1] + Rr * (kb[2] + Rr * kb[3])) - al);
            int j = 0;
            while (j < 16 && am > ADT_MB_SP[j + 1]) j++;
            double rs = (am - ADT_MB_SP[j]) / (ADT_MB_SP[j + 1] - ADT_MB_SP[j]);
            #define Q4(K, x) ((K)[0] + (x) * ((K)[1] + (x) * ((K)[2] + (x) * ((K)[3] + (x) * (K)[4]))))
            double cps = Q4(ADT_KS[j], al) + rs * (Q4(ADT_KS[j + 1], al) - Q4(ADT_KS[j], al));
            int m = 0;
            while (m < 13 && am > ADT_MB_PT[m + 1]) m++;
            double rp = (am - ADT_MB_PT[m]) / (ADT_MB_PT[m + 1] - ADT_MB_PT[m]);
            double cpt = Q4(ADT_KP[m], al) + rp * (Q4(ADT_KP[m + 1], al) - Q4(ADT_KP[m], al));
            double psc = ps - cps * (pac - ps), ptc = pac - cpt * (pac - ps);
            double mach = sqrt(5.0 * (pow(ptc / psc, 2.0 / 7.0) - 1.0));
            char what[80];
            snprintf(what, sizeof what, "ADTA Mach back at M %.1f", M);
            check(fabs(mach - am) < 0.01, what, mach, am);
            snprintf(what, sizeof what, "ADTA alpha back at M %.1f", M);
            check(fabs(al - aa) < 0.1, what, al, aa);
            snprintf(what, sizeof what, "ADTA static pressure back at M %.1f", M);
            check(fabs(psc - ap / 144.0) < 0.005 * ap / 144.0 + 0.002, what, psc, ap / 144.0);
        }
    }

    printf("landaids: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
