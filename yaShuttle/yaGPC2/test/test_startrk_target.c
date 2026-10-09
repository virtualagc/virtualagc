/* THE STAR TRACKERS' TARGET TRACK (startrk.c, TARGET TRACK).
 *
 * A run of its own, because the other vehicle comes from the environment,
 * which vehdyn reads once: the ISS from STS-134's targets file (its state at
 * docking, 2011-05-18 10:14 UTC), and the Orbiter placed as
 * fly_rndz134.py's start puts it -- 237.5 kft behind and 20.8 kft below,
 * closing at 35 ft/s -- at 06:30:00 UTC.  The tracker is driven through its
 * device interface (startrk_command/startrk_read) exactly as the flight
 * software's GY3_ST_TARGET_TRK drives it, and its words are decoded as
 * GY8DAT does.  Checked:
 *
 *   - THE LIGHT.  A Lambert sphere's light centroid: 0 at full phase,
 *     3 pi / 16 of a radius at 90 deg, growing with the phase.
 *   - THE GEOMETRY.  With the -Z tracker's boresight put on the station,
 *     where the tracker sees it is the line of sight from the NAVIGATION
 *     BASE (where the trackers are), not from the c.g. 57.9 ft aft, to the
 *     station's centre moved toward the Sun by the centroid -- worked out
 *     here from scratch, to a hundredth of an arcsecond.  The c.g.'s line
 *     of sight is not that (the lever arm is well over the noise).
 *   - ITS BRIGHTNESS: magnitude -7 to -9 at 40 nmi, far over THOLD 3.
 *   - THE OFFSET SCAN as GY3STT commands it (break track, then the box at
 *     GY3_CMD_OUT's codes, threshold 3): STAR PRESENT within 1.6 s, the
 *     lock on the station, and PASS's decode of the words within the noise
 *     of where it is.
 *   - BREAK TRACK drops it and the box stays empty; a new search finds it.
 *   - A BODY RATE over 0.5 deg/s loses it.
 *   - A CAPTURE keeps the lock and the break-track marks; an older capture,
 *     without them, still loads.
 *   - THE EARTH'S SHADOW: on a date whose Sun puts the station in it, the
 *     tracker sees nothing, and finds nothing in 20 s of full-field scan. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/startrk.h"
#include "../src/vehdyn.h"

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [startrk_target/%s] got %.9g want %.9g\n", what, got, want);
}

#define PI 3.14159265358979323846
#define D2R (PI / 180.0)
#define R2D (180.0 / PI)
#define FT 0.3048
#define LSB_DEG 0.0025390625

/* CGYS_TNBST (nav base -> tracker; 1 -Z, 2 -Y) and CGMS_TNBBODY, the
 * I-loads on this tape, as test_mdmdev.c has them. */
static const double T_NBST[3][3][3] = {
    { { 0 } },
    { { -0.00651344657, 0.999492586, -0.0311769098 }, { 0.989126801, 0.00185892172, -0.147052646 },
      { -0.146920085, -0.0314957425, -0.98863709 } },
    { { -0.965746284, -0.184594095, 0.182370245 }, { -0.186074317, 0.00279755401, -0.982531488 },
      { 0.180859327, -0.982810736, -0.0370500423 } },
};
static const double T_NBBODY[3][3] = { { 0.98293535, 0.0, -0.18395135 }, { 0, 1, 0 },
                                       { 0.18395135, 0.0, 0.98293535 } };

static double dot(const double a[3], const double b[3]) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }
static double norm(const double a[3]) { return sqrt(dot(a, a)); }
static double ang_deg(const double a[3], const double b[3]) {
    double c = dot(a, b) / (norm(a) * norm(b));
    return acos(c > 1 ? 1 : c < -1 ? -1 : c) * R2D;
}
static void qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}
/* tracker k's boresight in body axes: row 3 of TNBST, nav base -> body */
static void boresight_body(int k, double b[3]) {
    for (int i = 0; i < 3; i++)
        b[i] = T_NBBODY[i][0] * T_NBST[k][2][0] + T_NBBODY[i][1] * T_NBST[k][2][1] + T_NBBODY[i][2] * T_NBST[k][2][2];
}
/* Point tracker k's boresight along the M50 direction d (the shortest turn). */
static void point(int k, const double d[3]) {
    double b[3], dn[3], n = norm(d);
    boresight_body(k, b);
    for (int i = 0; i < 3; i++) dn[i] = d[i] / n;
    double ax[3] = { b[1] * dn[2] - b[2] * dn[1], b[2] * dn[0] - b[0] * dn[2], b[0] * dn[1] - b[1] * dn[0] };
    double sn = norm(ax), cs = dot(b, dn);
    double a = atan2(sn, cs), q[4] = { cos(a / 2), 0, 0, 0 }, zero[3] = { 0, 0, 0 };
    for (int i = 0; i < 3; i++) q[i + 1] = (sn > 0 ? ax[i] / sn : 0) * sin(a / 2);
    vehdyn_set_attitude(q, zero);
}
/* M50 -> tracker k at the truth attitude: TNBST TNBBODY^T R^T. */
static void to_tracker(int k, const double u[3], double o[3]) {
    double R[3][3], b[3], nb[3];
    qmat(vehdyn_state()->q, R);
    for (int i = 0; i < 3; i++) b[i] = R[0][i] * u[0] + R[1][i] * u[1] + R[2][i] * u[2];
    for (int i = 0; i < 3; i++) nb[i] = T_NBBODY[0][i] * b[0] + T_NBBODY[1][i] * b[1] + T_NBBODY[2][i] * b[2];
    for (int i = 0; i < 3; i++) o[i] = T_NBST[k][i][0] * nb[0] + T_NBST[k][i][1] * nb[1] + T_NBST[k][i][2] * nb[2];
}
/* PASS's decode (GY8DAT.hal:194-197, 431-434) of the words to the line of
 * sight in the tracker's axes. */
static void decode(const uint16_t w[3], double st[3], double hv[2]) {
    double H = (double)((int16_t)(w[1] & 0xFFF0u) >> 4) * LSB_DEG * D2R;
    double V = (double)((int16_t)(w[2] & 0xFFF0u) >> 4) * LSB_DEG * D2R;
    double D = sqrt(tan(H) * tan(H) + tan(V) * tan(V) + 1.0);
    st[0] = -tan(V) / D; st[1] = tan(H) / D; st[2] = 1.0 / D;
    hv[0] = H * R2D; hv[1] = V * R2D;
}
/* The navigation base, M50, from the truth c.g.: Xo 404.5, Yo -0.8, Zo
 * 422.6 against the dry c.g. Xo 1100, Zo 375 (+X forward = -Xo, +Z down =
 * -Zo), less the c.g.'s own offset. */
static void navbase(double p[3]) {
    const PhysState *s = vehdyn_state();
    double cg[3], d[3], R[3][3];
    vehdyn_cg_offset(cg);
    d[0] = -(404.5 - 1100.0) * 0.0254 - cg[0];
    d[1] = -0.8 * 0.0254 - cg[1];
    d[2] = -(422.6 - 375.0) * 0.0254 - cg[2];
    qmat(s->q, R);
    for (int i = 0; i < 3; i++) p[i] = s->r[i] + R[i][0] * d[0] + R[i][1] * d[1] + R[i][2] * d[2];
}
/* GY3_CMD_OUT: MIDVAL(0, 31, 15.5 + 15.5 deg / 4.75), to an INTEGER. */
static unsigned cmd_out(double deg) {
    double x = 15.5 + 15.5 * deg / 4.75;
    x = x < 0 ? 0 : x > 31 ? 31 : x;
    return (unsigned)floor(x + 0.5);
}

static double t;
static uint16_t w[3];
static void step(double dt) {
    t += dt;
    vehdyn_advance(t * 1e6);
    startrk_read(1, w, t);
}
static int lock_within(double secs) {
    for (double s = 0; s < secs; s += 0.16) {
        step(0.16);
        if ((w[0] & 0x0400u) && startrk_test_locked(1) == STARTRK_LOCKED_TARGET) return 1;
    }
    return 0;
}

int main(void) {
    const char *path = "startrk_target_targets.tmp";
    FILE *f = fopen(path, "w");
    if (f == NULL) { printf("FAIL [startrk_target] cannot write %s\n", path); return 1; }
    fprintf(f, "# NORAD 25544, state at 2011-05-18T10:14:00Z UTC (tools/tle_target.py)\n"
               "target 25544 1305713640.000 2109180.064 -5654207.985 -2965963.140 "
               "5848.388583 -433.197860 4989.397766 lvlh bc 130\n");
    fclose(f);
    const double T0 = 1305700200.0;                    /* 2011-05-18 06:30:00 UTC */
    char spec[256];
    snprintf(spec, sizeof spec, "25544,%.3f,0,%.3f,%.4f,0,0,%.3f", -237500 * FT, 20800 * FT, 35.0 * FT, T0);
    setenv("YAGPC_VEHDYN", "1", 1);
    setenv("YAGPC_VEHDYN_TARGETS", path, 1);
    setenv("YAGPC_VEHDYN_START_REL", spec, 1);
    vehdyn_reset(0.0);
    vehdyn_set_gmt_zero(T0);
    t = 1.0;
    vehdyn_advance(t * 1e6);
    int id;
    double rt[3], vt[3], qt[4];
    check(vehdyn_target(0, &id, rt, vt, qt) && id == 25544, "the ISS is placed", id, 25544);

    /* THE LIGHT */
    check(fabs(startrk_test_centroid(0.0)) < 1e-9, "full phase: centroid at the centre", startrk_test_centroid(0), 0);
    check(fabs(startrk_test_centroid(90.0) - 3.0 * PI / 16.0) < 0.005, "90 deg: 3 pi / 16 of a radius",
          startrk_test_centroid(90.0), 3.0 * PI / 16.0);
    check(startrk_test_centroid(30.0) < startrk_test_centroid(60.0) &&
          startrk_test_centroid(60.0) < startrk_test_centroid(120.0), "and it grows with the phase",
          startrk_test_centroid(60.0), 0.4);

    /* A DATE WHOSE SUN LIGHTS THE STATION, away from the boresight (the
     * vehicles stay where they are; only the calendar, so the Sun, moves). */
    double nb[3], los[3], sun[3], hv[2], mag, rng, ph;
    int lit = -1, dark = -1;
    for (int d = 0; d < 366 && (lit < 0 || dark < 0); d++) {
        vehdyn_set_gmt_zero(T0 + d * 86400.0);
        navbase(nb);
        for (int i = 0; i < 3; i++) los[i] = rt[i] - nb[i];
        point(1, los);
        startrk_test_sun(t, sun);
        double rn = norm(rt), e[3] = { -rt[0] / rn, -rt[1] / rn, -rt[2] / rn };
        double shade = ang_deg(sun, e) - asin(6378137.0 / rn) * R2D;
        int seen = startrk_test_target(1, t, hv, &mag, &rng, &ph);
        if (lit < 0 && seen && ang_deg(sun, los) > 60.0 && ph < 120.0 && shade > 5.0) lit = d;
        if (dark < 0 && !seen && shade < -5.0) dark = d;
    }
    check(lit >= 0, "a date with the station sunlit", lit, 0);
    check(dark >= 0, "a date with the station in the Earth's shadow", dark, 0);
    if (lit < 0) goto done;
    vehdyn_set_gmt_zero(T0 + lit * 86400.0);
    navbase(nb);
    for (int i = 0; i < 3; i++) los[i] = rt[i] - nb[i];
    point(1, los);

    /* THE GEOMETRY, from scratch: the station's centre moved toward the Sun
     * by the light's centroid, seen from the navigation base. */
    {
        int seen = startrk_test_target(1, t, hv, &mag, &rng, &ph);
        check(seen == 25544, "the -Z tracker sees the station", seen, 25544);
        startrk_test_sun(t, sun);
        double R = norm(los), u[3], sp[3], c[3], st[3];
        for (int i = 0; i < 3; i++) u[i] = los[i] / R;
        double back[3] = { -los[0], -los[1], -los[2] }, a = ang_deg(sun, back), su = dot(sun, u);
        for (int i = 0; i < 3; i++) sp[i] = sun[i] - su * u[i];
        double spn = norm(sp), shift = 44.6 * startrk_test_centroid(a);
        for (int i = 0; i < 3; i++) c[i] = los[i] + shift * sp[i] / spn;
        to_tracker(1, c, st);
        double H = atan2(st[1], st[2]) * R2D, V = atan2(-st[0], st[2]) * R2D;
        check(fabs(H - hv[0]) * 3600.0 < 0.01 && fabs(V - hv[1]) * 3600.0 < 0.01,
              "H and V: the light's centroid from the navigation base (arcsec)",
              3600.0 * hypot(H - hv[0], V - hv[1]), 0.0);
        check(fabs(rng - R) < 1e-6, "range from the navigation base (m)", rng, R);
        check(fabs(ph - a) < 1e-6, "phase angle (deg)", ph, a);
        /* the c.g.'s line of sight is another one: 57.9 ft of lever arm */
        double cgl[3], stc[3];
        const PhysState *s = vehdyn_state();
        for (int i = 0; i < 3; i++) cgl[i] = c[i] + nb[i] - s->r[i];
        to_tracker(1, cgl, stc);
        double Hc = atan2(stc[1], stc[2]) * R2D, Vc = atan2(-stc[0], stc[2]) * R2D;
        /* -Z on the station, ahead and a little above: the lever arm, along
         * body X, is almost square to the sight line -- 57.9 ft over R */
        double arm = 57.9 * FT / R * R2D * 3600.0, off = 3600.0 * hypot(Hc - hv[0], Vc - hv[1]);
        check(off > 0.8 * arm && off < 1.05 * arm, "the c.g.'s line of sight is 57.9 ft / R off (arcsec)", off, arm);
        check(mag < -6.5 && mag > -9.5, "magnitude -7 to -9 at 40 nmi", mag, -8.0);
        check(R / FT > 200000.0 && R / FT < 260000.0, "40 nmi out (ft)", R / FT, 238000.0);
    }

    /* THE OFFSET SCAN, as GY3STT commands it: break track with offset scan
     * off (case 2), then the box at the predicted angles, threshold 3. */
    {
        startrk_test_target(1, t, hv, &mag, &rng, &ph);
        unsigned hcode = cmd_out(hv[0]), vcode = cmd_out(hv[1]);
        uint16_t brk = 0x2000u, box = (uint16_t)(0x8000u | (3u << 10) | (hcode << 5) | vcode);
        startrk_command(1, brk, t);
        step(0.16);
        startrk_command(1, box, t);
        check(lock_within(1.6), "offset scan: STAR PRESENT, on the station, within 1.6 s", startrk_test_locked(1),
              STARTRK_LOCKED_TARGET);
        check((w[0] & 0xA200u) == 0xA200u && !(w[0] & 0x1000u) && (w[2] & 0x0003u) == 0x0003u,
              "good, word good, shutter open, power good, no bright object alert", w[0], 0xA600);
        /* PASS's decode against where it is: 20 arcsec of noise, 9 a count */
        double worst = 0, sumH = 0, sumV = 0;
        for (int n = 0; n < 21; n++) {
            double st[3], dh[2];
            step(0.16);
            decode(w, st, dh);
            startrk_test_target(1, t, hv, &mag, &rng, &ph);
            double e = 3600.0 * hypot(dh[0] - hv[0], dh[1] - hv[1]);
            if (e > worst) worst = e;
            sumH += dh[0] - hv[0]; sumV += dh[1] - hv[1];
        }
        check(worst < 100.0, "each sample within the noise (arcsec)", worst, 30.0);
        check(3600.0 * hypot(sumH / 21, sumV / 21) < 15.0, "the 21-sample mean on it (arcsec)",
              3600.0 * hypot(sumH / 21, sumV / 21), 0.0);
        check((w[0] & 0x00FFu) == 0x00FFu, "intensity count at its top: a very bright object", w[0] & 0xFF, 255);

        /* A CAPTURE, locked on: the lock and the marks come back */
        static double cap[1024];
        int n = startrk_save(cap, 1024);
        check(n == 2 * (21 + 100) + 2, "capture length", n, 2 * 121 + 2);
        /* BREAK TRACK (an edge, the box unchanged): gone, and not found again */
        startrk_command(1, (uint16_t)(box | 0x2000u), t);
        check(!lock_within(2.0), "break track: dropped, and the box stays empty", startrk_test_locked(1), 0);
        static double cap2[1024];
        int n2 = startrk_save(cap2, 1024);
        startrk_load(cap, n, 0.0);
        check(startrk_test_locked(1) == STARTRK_LOCKED_TARGET, "a capture restores the lock",
              startrk_test_locked(1), STARTRK_LOCKED_TARGET);
        startrk_load(cap2, n2, 0.0);
        check(cap2[n2 - 2] == 1.0, "and the break-track mark", cap2[n2 - 2], 1.0);
        startrk_load(cap, n - 2, 0.0);
        check(startrk_test_locked(1) == STARTRK_LOCKED_TARGET, "an older capture (no target marks) loads",
              startrk_test_locked(1), STARTRK_LOCKED_TARGET);
        startrk_load(cap2, n2, 0.0);
        /* a new search (the box moved a code) finds it again */
        startrk_command(1, (uint16_t)(0x8000u | (3u << 10) | (hcode << 5) | (vcode ^ 1u)), t);
        startrk_command(1, box, t);
        check(lock_within(1.6), "a new search finds it again", startrk_test_locked(1), STARTRK_LOCKED_TARGET);

        /* A BODY RATE over 0.5 deg/s loses it */
        double wr[3] = { 0.0, 0.6 * D2R, 0.0 };
        vehdyn_set_attitude(vehdyn_state()->q, wr);
        step(0.16);
        check(!(w[0] & 0x0400u) && startrk_test_locked(1) == 0, "0.6 deg/s: lost", startrk_test_locked(1), 0);
        double w0[3] = { 0, 0, 0 };
        vehdyn_set_attitude(vehdyn_state()->q, w0);
    }

    /* THE EARTH'S SHADOW: nothing, offset or full field */
    if (dark >= 0) {
        vehdyn_set_gmt_zero(T0 + dark * 86400.0);
        startrk_command(1, 0x2000u, t);
        step(0.16);
        startrk_command(1, (uint16_t)(0x8000u | (3u << 10) | (16u << 5) | 16u), t);
        check(!lock_within(4.0), "in the shadow: no target in the 4 s offset search", startrk_test_locked(1), 0);
        startrk_command(1, (uint16_t)(3u << 10), t);
        int found = 0;
        for (double s = 0; s < 20.0; s += 0.16) {
            step(0.16);
            if (startrk_test_locked(1) == STARTRK_LOCKED_TARGET) found = 1;
        }
        check(!found, "nor in 20 s of full-field scan (a star may be)", found, 0);
    }

done:
    remove(path);
    printf("startrk_target: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
