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

    printf("landaids: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
