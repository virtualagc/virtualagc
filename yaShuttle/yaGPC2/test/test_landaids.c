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
    setenv("YAGPC_NAVAIDS", "tools/sites/ksc-navaids-tacan.txt", 1);   /* the same runways and MLS, plus TTS and COF */
    setenv("YAGPC_TACAN_ACQ_S", "0", 1);
    setenv("YAGPC_TACAN_GLITCH_PER_S", "0", 1);
    setenv("YAGPC_TACAN_BRG_SIGMA_DEG", "0", 1);
    setenv("YAGPC_TACAN_RNG_SIGMA_NMI", "0", 1);
    setenv("YAGPC_TACAN_BRG_BIAS_DEG", "0", 1);
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


    /* THE TACAN: 250 n.mi. due east of TTS (59Y, 28-37-34.2N 80-41-45.0W, variation 0) at 100,000 ft, tuned the way
     * PASS tunes it (control word 0x8800 | 0x2134).  The words decode, as PASS decodes them (GYTTAC.hal:110-184), to
     * the magnetic bearing to the station (270 deg) and the range the test's own geometry gives; an untuned unit and a
     * point past 400 n.mi. read no data; COF (97X) is a different station. */
    {
        double slat = 0.49962085485458374, slon = -1.4084081649780273, salt = 57.0;
        double A = 20925646.3255, f_ = 1.0 / 298.3, e2_ = f_ * (2 - f_), sn = sin(slat);
        double Nr = A / sqrt(1 - e2_ * sn * sn);
        double vlat = slat, vlon = slon + 250.0 * 6076.1155 / (Nr * cos(slat)), vh = 100000.0;
        double sEf[3], vEf[3], rr[3], vv[3];
        geo_ef(slat, slon, salt, sEf);
        geo_ef(vlat, vlon, vh, vEf);
        double we_ = phys_earth_rate(), pl[3];
        phys_earth_pole(pl);
        for (int i = 0; i < 3; i++) rr[i] = (Me[0][i] * vEf[0] + Me[1][i] * vEf[1] + Me[2][i] * vEf[2]) * FT;
        vv[0] = we_ * (pl[1] * rr[2] - pl[2] * rr[1]);
        vv[1] = we_ * (pl[2] * rr[0] - pl[0] * rr[2]);
        vv[2] = we_ * (pl[0] * rr[1] - pl[1] * rr[0]);
        vehdyn_set_rv(rr, vv);
        uint16_t t[7];
        landaids_tacan_ra(1, t);
        check(t[0] == 0x4000 && t[2] == 0x8000, "an untuned TACAN reads no data", t[0], 0x4000);
        check((t[5] & 0x4000u) && (t[5] & 0x1000u), "TACAN power and test status in word 6", t[5], 0x5000);
        landaids_tacan_command(1, 0x8800 | 0x2134, 0);
        landaids_tacan_ra(1, t);
        check((t[6] & 0x21FE) == 0x2134, "word 7 reads back the channel (59Y = 0x2134)", t[6] & 0x21FE, 0x2134);
        int bst = (t[0] >> 13) & 3;
        check(bst == 0 || bst == 3, "bearing status valid", bst, 0);
        double bear = (((t[0] >> 1) & 0xFFF) + (bst == 3 ? 4096 : 0)) * 90.0 / 2048.0;
        double dd[3], nn_ = 0, ee_ = 0;
        double cs = cos(slat), ss = sin(slat), co_ = cos(slon), so_ = sin(slon);
        for (int i = 0; i < 3; i++) dd[i] = vEf[i] - sEf[i];
        nn_ = -ss * co_ * dd[0] - ss * so_ * dd[1] + cs * dd[2];
        ee_ = -so_ * dd[0] + co_ * dd[1];
        double bwant = fmod(atan2(ee_, nn_) * 180.0 / PI + 180.0 + 360.0, 360.0);
        check(fabs(bear - bwant) < 0.1, "magnetic bearing to TTS (variation 0)", bear, bwant);
        check((t[2] & 0xC000) == 0, "range status valid", t[2], 0);
        double rn = ((t[2] >> 12) & 3) * 100 + ((t[2] >> 8) & 15) * 10 + ((t[2] >> 4) & 15) + (t[2] & 15) * 0.1 + ((t[3] >> 12) & 15) * 0.01;
        double d[3];
        for (int i = 0; i < 3; i++) d[i] = vEf[i] - sEf[i];
        double want = sqrt(d[0] * d[0] + d[1] * d[1] + d[2] * d[2]) / 6076.1155;
        check(fabs(rn - want) < 0.15, "range to TTS, n.mi.", rn, want);   /* 29 ms of the Earth's rotation: ~0.03 */
        check((t[3] & 0xFF) == 0x89 && t[1] == 1, "range B label and bearing B", t[3], 0x89);
        landaids_tacan_ra(3, t);                                   /* unit 3 is untuned */
        check(t[0] == 0x4000 && t[2] == 0x8000, "unit 3, never commanded, reads no data", t[0], 0x4000);
        landaids_tacan_command(3, 0x8800 | 0x01D2, 0);             /* COF 97X, about 26 n.mi. farther south */
        landaids_tacan_ra(3, t);
        double rn3 = ((t[2] >> 12) & 3) * 100 + ((t[2] >> 8) & 15) * 10 + ((t[2] >> 4) & 15) + (t[2] & 15) * 0.1 + ((t[3] >> 12) & 15) * 0.01;
        double cEf[3];
        geo_ef(0.49284052848815918, -1.4069404602050781, 5.0, cEf);
        for (int i = 0; i < 3; i++) dd[i] = vEf[i] - cEf[i];
        double cwant = sqrt(dd[0] * dd[0] + dd[1] * dd[1] + dd[2] * dd[2]) / 6076.1155;
        check((t[2] & 0xC000) == 0 && fabs(rn3 - cwant) < 0.15 && fabs(cwant - rn) > 1.0, "COF is a different station", rn3, cwant);
        landaids_tacan_command(2, 0x8800 | 0x2134, 0);
        double far2[3];
        geo_ef(vlat, slon + 450.0 * 6076.1155 / (Nr * cos(slat)), 100000.0, far2);
        for (int i = 0; i < 3; i++) rr[i] = (Me[0][i] * far2[0] + Me[1][i] * far2[1] + Me[2][i] * far2[2]) * FT;
        vehdyn_set_rv(rr, vv);
        landaids_tacan_ra(2, t);
        check(t[0] == 0x4000 && t[2] == 0x8000, "past 400 n.mi. the TACAN reads no data", t[2], 0x8000);
        /* back to the 250 n.mi. point (rr was the 450 n.mi. one) */
        for (int i = 0; i < 3; i++) rr[i] = (Me[0][i] * vEf[0] + Me[1][i] * vEf[1] + Me[2][i] * vEf[2]) * FT;
        vehdyn_set_rv(rr, vv);
        landaids_tacan_ra(1, t);
        check((t[2] & 0xC000) == 0, "locked again at 250 n.mi.", t[2], 0);
        /* the O7 rotary out of GPC: the unit reads unpowered (PASS then skips it) */
        landaids_tacan_command(1, 0x8800 | 0x2134, 0);
        landaids_tacan_gpc(1, 0);
        landaids_tacan_ra(1, t);
        check((t[5] & 0x4000u) == 0 && t[2] == 0 && t[0] == 0, "rotary not in GPC: TACAN unpowered, no words", t[5], 0);
        landaids_tacan_gpc(1, 1);
        /* the plasma blackout: past Mach 9.6 no lock */
        {
            double vh[3] = { vv[0] + 3100.0, vv[1], vv[2] };
            vehdyn_set_rv(rr, vh);
            landaids_tacan_ra(1, t);
            check(t[0] == 0x4000 && t[2] == 0x8000, "in the blackout (Mach > 9.6) no data", t[2], 0x8000);
            vehdyn_set_rv(rr, vv);
            landaids_tacan_ra(1, t);
            check((t[2] & 0xC000) == 0, "and locked again at rest", t[2], 0);
            vehdyn_set_rv(rr, vv);
        }
        /* straight over the station: the cone of silence -- range valid, bearing no data */
        {
            double ov[3], ovr[3];
            geo_ef(slat, slon, 60000.0, ov);
            for (int i = 0; i < 3; i++) ovr[i] = (Me[0][i] * ov[0] + Me[1][i] * ov[1] + Me[2][i] * ov[2]) * FT;
            vehdyn_set_rv(ovr, vv);
            landaids_tacan_ra(1, t);
            check((t[2] & 0xC000) == 0 && t[0] == 0x4000, "over the station: range valid, bearing no data", t[0], 0x4000);
        }
        /* the 40 degree glitch, forced: the unit's bearing moves by +40 deg until its end */
        {
            vehdyn_set_rv(rr, vv);
            landaids_tacan_command(2, 0x8800 | 0x2134, 0);
            landaids_tacan_ra(2, t);
            int st0 = (t[0] >> 13) & 3;
            double b0 = (((t[0] >> 1) & 0xFFF) + (st0 == 3 ? 4096 : 0)) * 90.0 / 2048.0;
            landaids_tacan_glitch(2, 40.0, 1.0e9);
            landaids_tacan_ra(2, t);
            int sk = (t[0] >> 13) & 3;
            double bk = (((t[0] >> 1) & 0xFFF) + (sk == 3 ? 4096 : 0)) * 90.0 / 2048.0;
            double dd = fmod(bk - b0 + 540.0, 360.0) - 180.0;
            check(fabs(dd - 40.0) < 1.0, "a forced glitch moves the bearing by 40 deg", dd, 40.0);
            landaids_tacan_glitch(2, 0.0, 0.0);
            vehdyn_reset(0.0);                                     /* the clock ran: start the approach again */
            vehdyn_set_attitude(q, w0);
        }
        vehdyn_set_rv(r, v);                                       /* back to the approach, for the ADTAs below */
    }

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
            check(fabs(psc - ap * 29.921 / 2116.2) < 0.005 * ap * 29.921 / 2116.2 + 0.002, what, psc, ap * 29.921 / 2116.2);
        }
    }

    printf("landaids: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
