/* THE KU-BAND RENDEZVOUS RADAR (kuradar.c).
 *
 * The ISS from STS-134's targets file, as test_startrk_target.c has it; the
 * Orbiter 152 kft behind and 1.2 kft below it, closing at 100 ft/s, so that
 * it crosses the radar's 150 kft reach early in the run.  The words are
 * decoded exactly as GYNRRP decodes them, and the angles taken through
 * GLBRRA's transform to shaft and trunnion and set against PASS's own
 * prediction from the line of sight (GLNREN, GLRREN's antenna offset,
 * CGNS_M_BODY_TO_RR), worked out here from scratch.  Checked:
 *
 *   - OFF, and ON in COMM: word 1 has no RADAR ON bit (PASS shows 'COMM').
 *   - ON, RDR PASSIVE, GPC, beyond 150 kft: searching, no data good.
 *   - Inside it: lock within 20 s; 'GPC ' (word 1 bit 4), TRACK, the data
 *     good codes A = 4 and R = 4.
 *   - The decode: range and range rate to their LSBs (noise off), and to
 *     a few sigma with it on; shaft and trunnion within the angle LSB of
 *     PASS's prediction; the range rate negative (closing).
 *   - MAN SLEW never locks; GPC DESIG and AUTO TRACK show their bits.
 *   - The station behind the Orbiter's body breaks the lock.
 *   - SELF-TEST shows 'STST'.
 *   - A capture keeps the panel and the lock. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/kuradar.h"
#include "../src/vehdyn.h"

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [kuradar/%s] got %.9g want %.9g\n", what, got, want);
}

#define PI 3.14159265358979323846
#define D2R (PI / 180.0)
#define R2D (180.0 / PI)
#define FT 0.3048

static double dot(const double a[3], const double b[3]) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }
static double norm(const double a[3]) { return sqrt(dot(a, a)); }
static void qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}
/* Point the body axis b along the M50 direction d (the shortest turn). */
static void point(const double b[3], const double d[3]) {
    double dn[3], n = norm(d);
    for (int i = 0; i < 3; i++) dn[i] = d[i] / n;
    double ax[3] = { b[1] * dn[2] - b[2] * dn[1], b[2] * dn[0] - b[0] * dn[2], b[0] * dn[1] - b[1] * dn[0] };
    double sn = norm(ax), cs = dot(b, dn);
    double a = atan2(sn, cs), q[4] = { cos(a / 2), 0, 0, 0 }, zero[3] = { 0, 0, 0 };
    for (int i = 0; i < 3; i++) q[i + 1] = (sn > 0 ? ax[i] / sn : 0) * sin(a / 2);
    vehdyn_set_attitude(q, zero);
}
static void point_at_target(const double b[3]) {
    int id;
    double rt[3], vt[3], qt[4], d[3];
    vehdyn_target(0, &id, rt, vt, qt);
    for (int i = 0; i < 3; i++) d[i] = rt[i] - vehdyn_state()->r[i];
    point(b, d);
}

/* GYNRRP's decode */
typedef struct { double rngFt, rdot, roll, pitch; int A, R, on, atrk, gdsg, gpc, st, trk; } Dec;
static double sm(uint16_t w, unsigned bits, unsigned shift, double lsb) {
    double m = (double)((w >> shift) & ((1u << bits) - 1u)) * lsb;
    return (w & 0x8000u) ? -m : m;
}
static Dec decode(const uint16_t w[10]) {
    Dec d;
    unsigned long n = ((unsigned long)w[6] << 7) | (w[7] >> 9);
    d.rngFt = (double)n * (0.005 / 16.0) * 1000.0;
    d.pitch = sm(w[3], 11, 4, 0.0878906);
    d.roll = sm(w[2], 12, 3, 0.0878906);
    d.rdot = sm(w[4], 15, 0, 0.05);
    d.on = (w[0] & 0x8000u) != 0;
    d.atrk = (w[0] & 0x4000u) != 0;
    d.gdsg = (w[0] & 0x2000u) != 0;
    d.gpc = (w[0] & 0x1000u) != 0;
    d.st = (w[0] & 0x0040u) != 0;
    d.A = (int)((w[0] >> 7) & 3u) + 1;
    d.trk = (w[1] & 0x2000u) != 0;
    d.R = (int)(w[1] & 3u) + 1;
    return d;
}
/* GLBRRA: roll, pitch (deg) -> shaft, trunnion (rad) */
static void shaft_trun(double rollDeg, double pitchDeg, double *shaft, double *trun) {
    const double c = 0.3907311, s = 0.9205048;
    double R = rollDeg * D2R, P = pitchDeg * D2R;
    double tr = -c * sin(P) + s * sin(R) * cos(P);
    *trun = asin(tr > 1 ? 1 : tr < -1 ? -1 : tr);
    *shaft = atan2(-s * sin(P) - c * sin(R) * cos(P), cos(R) * cos(P));
}
/* PASS's prediction: the antenna (GLR_R_OFFSET_BODY, ft) to the station, in
 * CGNS_M_BODY_TO_RR axes; shaft atan2(u2, -u3), trunnion asin(-u1). */
static void predict(double *shaft, double *trun, double *rangeFt, double *rdot) {
    static const double off[3] = { -12.2211, 11.1971, -1.82292 };
    static const double M[3][3] = { { 0.3907311, 0.9205048, 0 }, { -0.9205048, 0.3907311, 0 }, { 0, 0, 1 } };
    const PhysState *s = vehdyn_state();
    int id;
    double rt[3], vt[3], qt[4], R[3][3], p[3], rel[3], ub[3], u[3];
    vehdyn_target(0, &id, rt, vt, qt);
    qmat(s->q, R);
    for (int i = 0; i < 3; i++)
        p[i] = s->r[i] + (R[i][0] * off[0] + R[i][1] * off[1] + R[i][2] * off[2]) * FT;
    for (int i = 0; i < 3; i++) rel[i] = rt[i] - p[i];
    double rn = norm(rel);
    for (int i = 0; i < 3; i++) ub[i] = (R[0][i] * rel[0] + R[1][i] * rel[1] + R[2][i] * rel[2]) / rn;
    for (int i = 0; i < 3; i++) u[i] = M[i][0] * ub[0] + M[i][1] * ub[1] + M[i][2] * ub[2];
    *shaft = atan2(u[1], -u[2]);
    *trun = asin(-u[0]);
    *rangeFt = rn / FT;
    double vrel[3];
    for (int i = 0; i < 3; i++) vrel[i] = vt[i] - s->v[i];
    *rdot = dot(rel, vrel) / rn / FT;
}

static double t;
static uint16_t w[10];
static void step(double dt) {
    t += dt;
    vehdyn_advance(t * 1e6);
    kuradar_read(w, t);
}
static int lock_within(double secs) {
    for (double s = 0; s < secs; s += 0.96) {
        step(0.96);
        KuTruth k;
        kuradar_test_truth(&k);
        if (k.locked) return 1;
    }
    return 0;
}

int main(void) {
    const char *path = "kuradar_targets.tmp";
    FILE *f = fopen(path, "w");
    if (f == NULL) { printf("FAIL [kuradar] cannot write %s\n", path); return 1; }
    fprintf(f, "# NORAD 25544, state at 2011-05-18T10:14:00Z UTC (tools/tle_target.py)\n"
               "target 25544 1305713640.000 2109180.064 -5654207.985 -2965963.140 "
               "5848.388583 -433.197860 4989.397766 lvlh bc 130\n");
    fclose(f);
    const double T0 = 1305700200.0;
    char spec[256];
    snprintf(spec, sizeof spec, "25544,%.3f,0,%.3f,%.4f,0,0,%.3f", -152000 * FT, 1200 * FT, 100.0 * FT, T0);
    setenv("YAGPC_VEHDYN", "1", 1);
    setenv("YAGPC_VEHDYN_TARGETS", path, 1);
    setenv("YAGPC_VEHDYN_START_REL", spec, 1);
    unsetenv("YAGPC_KU_ACQ_KFT");
    vehdyn_reset(0.0);
    vehdyn_set_gmt_zero(T0);
    t = 1.0;
    vehdyn_advance(t * 1e6);
    const double minusZ[3] = { 0, 0, -1 }, plusZ[3] = { 0, 0, 1 };
    point_at_target(minusZ);
    kuradar_test_noiseless(true);
    Dec d;

    /* OFF, then ON in COMM */
    step(0.96);
    d = decode(w);
    check(!d.on && w[1] == 0, "off: no RADAR ON (COMM)", w[0], 0);
    kuradar_panel(KU_PWR_ON | KU_MODE_COMM | KU_SEL_GPC | KU_OUT_HIGH, t);
    step(0.96);
    check(!decode(w).on, "ON in COMM: no RADAR ON", w[0], 0);

    /* ON, RDR PASSIVE, GPC, beyond reach */
    kuradar_panel(KU_PWR_ON | KU_MODE_PASSIVE | KU_SEL_GPC | KU_OUT_HIGH, t);
    step(0.96);
    d = decode(w);
    KuTruth k;
    kuradar_test_truth(&k);
    check(k.rangeFt > 150000.0, "the run starts beyond 150 kft", k.rangeFt, 151000);
    check(d.on && d.gpc && !d.trk && d.A == 1 && d.R == 1, "beyond reach: GPC, no track, nothing good",
          w[0], 0x9000);
    for (int i = 0; i < 40 && k.rangeFt > 150000.0; i++) {
        point_at_target(minusZ);
        step(0.96);
        kuradar_test_truth(&k);
        check(!k.locked, "no lock beyond 150 kft", k.rangeFt, 150000);
    }
    check(k.rangeFt <= 150000.0, "closing inside 150 kft", k.rangeFt, 150000);
    point_at_target(minusZ);
    check(lock_within(21.0), "lock within 20 s inside reach", 0, 1);
    d = decode(w);
    check(d.on && d.gpc && d.trk && d.A == 4 && d.R == 4, "locked: GPC, TRACK, A = 4, R = 4", w[0], 0);

    /* THE DECODE, noise off */
    double sh, tr, rf, rd, msh, mtr;
    predict(&sh, &tr, &rf, &rd);
    shaft_trun(d.roll, d.pitch, &msh, &mtr);
    check(fabs(d.rngFt - rf) < 0.5, "range to its LSB (0.3125 ft)", d.rngFt, rf);
    check(fabs(d.rdot - rd) < 0.05, "range rate to its LSB (0.05 ft/s)", d.rdot, rd);
    check(d.rdot < -50.0, "closing: range rate negative", d.rdot, -100);
    check(fabs(msh - sh) * R2D < 0.07, "shaft: PASS's prediction, within the angle LSB", msh * R2D, sh * R2D);
    check(fabs(mtr - tr) * R2D < 0.07, "trunnion: PASS's prediction, within the angle LSB", mtr * R2D, tr * R2D);
    /* off the boresight too: turn the body 20 deg about its X axis, still in view */
    {
        double q0[4];
        memcpy(q0, vehdyn_state()->q, sizeof q0);
        double c = cos(10.0 * D2R), s = sin(10.0 * D2R), qr[4] = { c, s, 0, 0 }, q[4], zero[3] = { 0, 0, 0 };
        q[0] = q0[0] * qr[0] - q0[1] * qr[1] - q0[2] * qr[2] - q0[3] * qr[3];
        q[1] = q0[0] * qr[1] + q0[1] * qr[0] + q0[2] * qr[3] - q0[3] * qr[2];
        q[2] = q0[0] * qr[2] - q0[1] * qr[3] + q0[2] * qr[0] + q0[3] * qr[1];
        q[3] = q0[0] * qr[3] + q0[1] * qr[2] - q0[2] * qr[1] + q0[3] * qr[0];
        vehdyn_set_attitude(q, zero);
        step(0.96);
        d = decode(w);
        predict(&sh, &tr, &rf, &rd);
        shaft_trun(d.roll, d.pitch, &msh, &mtr);
        check(fabs(msh - sh) * R2D < 0.07 && fabs(mtr - tr) * R2D < 0.07, "20 deg off: shaft and trunnion",
              (fabs(msh - sh) + fabs(mtr - tr)) * R2D, 0);
        check(fabs(sh) * R2D > 5.0 || fabs(tr) * R2D > 5.0, "20 deg off: the angles are not near zero",
              (fabs(sh) + fabs(tr)) * R2D, 20);
    }

    /* NOISE ON: a hundred reads within a few sigma */
    kuradar_test_noiseless(false);
    point_at_target(minusZ);
    double er = 0, erd = 0, ea = 0;
    for (int i = 0; i < 100; i++) {
        step(0.96);
        d = decode(w);
        predict(&sh, &tr, &rf, &rd);
        shaft_trun(d.roll, d.pitch, &msh, &mtr);
        er += (d.rngFt - rf) * (d.rngFt - rf);
        erd += (d.rdot - rd) * (d.rdot - rd);
        ea += ((msh - sh) * (msh - sh) + (mtr - tr) * (mtr - tr)) * R2D * R2D / 2;
    }
    er = sqrt(er / 100), erd = sqrt(erd / 100), ea = sqrt(ea / 100);
    double sr = sqrt(15.0 * 15.0 + 0.0015 * rf * 0.0015 * rf);
    check(er > 0.5 * sr && er < 1.6 * sr, "range noise near its sigma", er, sr);
    check(erd > 0.15 && erd < 0.5, "range rate noise near 0.3 ft/s", erd, 0.3);
    check(ea > 0.04 && ea < 0.2, "angle noise near 0.08 deg (shaft/trunnion mix)", ea, 0.08);
    kuradar_test_noiseless(true);

    /* A CAPTURE keeps the panel and the lock */
    double b[16];
    int n = kuradar_save(b, 16);
    check(n == 6, "a capture's size", n, 6);
    kuradar_panel(KU_PWR_ON | KU_MODE_PASSIVE | KU_SEL_SLEW | KU_OUT_HIGH, t);
    step(0.96);
    kuradar_test_truth(&k);
    check(!k.locked, "MAN SLEW drops the GPC lock", k.locked, 0);
    kuradar_load(b, n, 0.0);
    step(0.96);
    kuradar_test_truth(&k);
    check(k.locked && decode(w).gpc, "restored: GPC and the lock", k.locked, 1);

    /* MAN SLEW never locks */
    kuradar_panel(KU_PWR_ON | KU_MODE_PASSIVE | KU_SEL_SLEW | KU_OUT_HIGH, t);
    check(!lock_within(40.0), "MAN SLEW: no lock in 40 s", 1, 0);
    d = decode(w);
    check(d.on && !d.gpc && !d.gdsg && !d.atrk, "MAN SLEW: none of the steering bits ('MSLW')", w[0], 0x8000);
    kuradar_panel(KU_PWR_ON | KU_MODE_COOP | KU_SEL_DESIG | KU_OUT_HIGH, t);
    check(lock_within(21.0) && decode(w).gdsg, "GPC DESIG (RDR COOP): lock, 'GDSG'", w[0], 0xA000);
    kuradar_panel(KU_PWR_ON | KU_MODE_PASSIVE | KU_SEL_AUTO | KU_OUT_HIGH, t);
    check(lock_within(21.0) && decode(w).atrk, "AUTO TRACK: lock, 'ATRK'", w[0], 0xC000);

    /* BEHIND THE BODY */
    point_at_target(plusZ);
    step(0.96);
    kuradar_test_truth(&k);
    check(!k.locked && decode(w).R == 1 && !decode(w).trk, "the station behind the body: no track", k.locked, 0);
    point_at_target(minusZ);
    check(lock_within(21.0), "back in view: lock again", 0, 1);

    /* SELF-TEST */
    kuradar_panel(KU_PWR_ON | KU_MODE_PASSIVE | KU_SEL_GPC | KU_OUT_HIGH | KU_SELF_TEST, t);
    step(0.96);
    check(decode(w).st, "SELF-TEST: 'STST'", w[0], 0x9040);

    remove(path);
    printf("test_kuradar: %d checks, %d failures\n", checks, failures);
    return failures ? 1 : 0;
}
