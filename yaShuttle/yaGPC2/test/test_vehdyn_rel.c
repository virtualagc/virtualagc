/* THE ORBITER STARTED OFF ITS TARGET (vehdyn.c, YAGPC_VEHDYN_START_REL).
 *
 * A run of its own, because the start is configured from the environment,
 * which vehdyn reads once: the ISS from STS-134's targets file (its state at
 * docking, 2011-05-18 10:14 UTC), and the Orbiter put 48.6 kft behind and
 * 1.2 kft below it, closing at 2 ft/s -- the rendezvous checklist's Ti point
 * (JSC-48072-134, TGT 9) -- at 06:29:01 UTC, the state's own time, a minute
 * before the calendar is known at 06:30:01, so that it is coasted there.
 * Checked:
 *
 *   - THE ROUND TRIP.  The relative state is read back from the two M50
 *     states with orbit targeting's own forward transform, the INER_TO_LVC
 *     branch of GWJ_ORB_TGT_REL_COMP (GWJORB.hal steps 60-80), written out
 *     here independently of vehdyn's inverse; it must give back what was
 *     asked carried a minute on by Clohessy-Wiltshire -- to a metre and
 *     5 mm/s, because the Earth is not a point: a minute of the J2-J4 field
 *     moves the two vehicles 15 km apart by half a metre out of plane and a
 *     tenth in height relative to each other (tools/rndz_start.py's own J2-J4
 *     propagation of the same states gives Y +0.514 m, Z 365.676 m, within
 *     a centimetre of vehdyn's), against CW's 6 cm from two-body motion.
 *   - THE FRAME.  For an offset small enough that the curvilinear and the
 *     rectangular frames agree, the M50 offset projected on the target's
 *     LVLH axes built from scratch (x along the track, y = -(orbit normal),
 *     z down) is the one asked for.  Here: Z, and the arc's chord.
 *   - THE ATTITUDE.  +XVV -ZLV: body +Z down the radius, +X along the
 *     velocity's horizontal part, and the pitch rate the orbital rate.
 *   - ONCE ONLY, and never after a restore: a capture loaded and the clock
 *     run on, the Orbiter is where the dynamics carried it. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/vehdyn.h"

static int checks, failures;

/* Clohessy-Wiltshire for t seconds, x along (+ ahead), z down: the textbook
 * solution with R = -z, S = x (the y motion is not used here). */
static void cw(const double in[6], double n, double t, double out[6]) {
    double R0 = -in[2], Rd0 = -in[5], S0 = in[0], Sd0 = in[3], s = sin(n * t), c = cos(n * t);
    double R = (4 - 3 * c) * R0 + s / n * Rd0 + 2 / n * (1 - c) * Sd0;
    double S = 6 * (s - n * t) * R0 + S0 - 2 / n * (1 - c) * Rd0 + (4 * s - 3 * n * t) / n * Sd0;
    double Rd = 3 * n * s * R0 + c * Rd0 + 2 * s * Sd0;
    double Sd = -6 * n * (1 - c) * R0 - 2 * s * Rd0 + (4 * c - 3) * Sd0;
    out[0] = S; out[2] = -R; out[3] = Sd; out[5] = -Rd;
    out[1] = in[1] * c + in[4] / n * s;
    out[4] = -in[1] * n * s + in[4] * c;
}

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [vehdyn_rel/%s] got %.9g want %.9g\n", what, got, want);
}

static double dot(const double a[3], const double b[3]) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }
static void cross(const double a[3], const double b[3], double c[3]) {
    c[0] = a[1] * b[2] - a[2] * b[1];
    c[1] = a[2] * b[0] - a[0] * b[2];
    c[2] = a[0] * b[1] - a[1] * b[0];
}

/* GWJ_ORB_TGT_REL_COMP with INER_TO_LVC on: the shuttle's state relative to
 * the target's, in target-centred curvilinear coordinates. */
static void gwj_to_lvc(const double rt[3], const double vt[3], const double rs[3], const double vs[3],
                       double rel[6]) {
    double rtm = sqrt(dot(rt, rt)), vxr[3], a[3], L[3][3];
    cross(vt, rt, vxr);
    double h = sqrt(dot(vxr, vxr));
    cross(rt, vxr, a);
    double an = sqrt(dot(a, a));
    for (int i = 0; i < 3; i++) { L[0][i] = a[i] / an; L[1][i] = vxr[i] / h; L[2][i] = -rt[i] / rtm; }
    double w = h / (rtm * rtm), dr[3], dv[3], R[3], V[3];
    for (int i = 0; i < 3; i++) { dr[i] = rs[i] - rt[i]; dv[i] = vs[i] - vt[i]; }
    for (int k = 0; k < 3; k++) { R[k] = dot(L[k], dr); V[k] = dot(L[k], dv); }
    /* - OMEGA x R, OMEGA = (0, -w, 0) */
    V[0] -= -w * R[2];
    V[2] -= w * R[0];
    double zcon = rtm - R[2], th = atan(R[0] / zcon);
    rel[0] = rtm * th;
    rel[1] = R[1];
    rel[2] = rtm - zcon / cos(th);
    double thd = pow(cos(th) / zcon, 2) * (V[0] * zcon + R[0] * V[2]);
    rel[5] = (V[2] - thd * R[0]) / cos(th);
    rel[3] = rtm * thd;
    rel[4] = V[1];
}

int main(void) {
    const char *path = "vehdyn_rel_targets.tmp";
    FILE *f = fopen(path, "w");
    if (f == NULL) { printf("FAIL [vehdyn_rel] cannot write %s\n", path); return 1; }
    /* tools/tle_target.py from the ISS's TLE 11138.51317551 */
    fprintf(f, "# NORAD 25544, state at 2011-05-18T10:14:00Z UTC\n"
               "target 25544 1305713640.000 2109180.064 -5654207.985 -2965963.140 "
               "5848.388583 -433.197860 4989.397766 lvlh bc 130\n"
               /* not to be taken: a word that is not a number, a position
                * at the Earth's centre, an epoch of 0 (1970) -- and one
                * that reads but is 100 days from the run's date, dropped
                * when the calendar is known */
               "target 99001 1305713640.000 2109180.064 -5654207.98x -2965963.140 1 2 3\n"
               "target 99002 1305713640.000 0 0 0 7000 0 0\n"
               "target 99003 0 2109180.064 -5654207.985 -2965963.140 5848.4 -433.2 4989.4\n"
               "target 99004 1314353640.000 2109180.064 -5654207.985 -2965963.140 "
               "5848.388583 -433.197860 4989.397766\n");
    fclose(f);
    const double FT = 0.3048;
    const double want[6] = { -48600 * FT, 0.0, 1200 * FT, 2.04 * FT, 0.0, 0.0 };
    char spec[256];
    snprintf(spec, sizeof spec, "25544,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.3f",
             want[0], want[1], want[2], want[3], want[4], want[5], 1305700200.0 + 1.0 - 60.0);
    setenv("YAGPC_VEHDYN", "1", 1);
    setenv("YAGPC_VEHDYN_TARGETS", path, 1);
    setenv("YAGPC_VEHDYN_START_REL", spec, 1);

    vehdyn_reset(0.0);
    vehdyn_advance(0.5e6);                       /* no calendar yet: nothing moves */
    int id;
    double rt[3], vt[3], qt[4];
    check(!vehdyn_target(0, &id, rt, vt, qt), "no target before the calendar is known", 1, 0);
    vehdyn_set_gmt_zero(1305700200.0);           /* t = 0 is 2011-05-18 06:30:00 UTC */
    vehdyn_advance(1.0e6);
    check(vehdyn_target(0, &id, rt, vt, qt) && id == 25544, "the ISS is placed", id, 25544);
    check(vehdyn_target_count() == 1, "the bad lines and the far epoch are not taken",
          vehdyn_target_count(), 1);
    const PhysState *s = vehdyn_state();
    double rel[6], now[6];
    gwj_to_lvc(rt, vt, s->r, s->v, rel);
    {
        double h[3];
        cross(rt, vt, h);
        cw(want, sqrt(dot(h, h)) / dot(rt, rt), 60.0, now);
    }
    const char *name[6] = { "X a minute on (m)", "Y (m)", "Z (m)", "XD (m/s)", "YD (m/s)", "ZD (m/s)" };
    for (int k = 0; k < 6; k++)
        check(fabs(rel[k] - now[k]) < (k < 3 ? 1.0 : 5e-3), name[k], rel[k], now[k]);
    check(now[0] - want[0] > 37.0 && now[0] - want[0] < 38.0, "and it did move on (m)", now[0] - want[0], 37.3);

    /* The frame, from scratch: z down, y = -(r x v)/|r x v|, x = y x z. */
    {
        double rn = sqrt(dot(rt, rt)), z[3], h[3], y[3], x[3], d[3];
        for (int i = 0; i < 3; i++) z[i] = -rt[i] / rn;
        cross(rt, vt, h);
        double hn = sqrt(dot(h, h));
        for (int i = 0; i < 3; i++) y[i] = -h[i] / hn;
        cross(y, z, x);
        for (int i = 0; i < 3; i++) d[i] = s->r[i] - rt[i];
        double th = rel[0] / rn, zc = rn - rel[2];
        /* the arc X at radius |rt| - Z is a chord sin(th) zcon ahead and
         * rn - cos(th) zcon down */
        check(fabs(dot(d, x) - sin(th) * zc) < 1e-3, "along the track, as the arc says (m)", dot(d, x), sin(th) * zc);
        check(fabs(dot(d, z) - (rn - cos(th) * zc)) < 1e-3, "below, as the arc says (m)", dot(d, z), rn - cos(th) * zc);
        check(fabs(dot(d, y) - rel[1]) < 1e-6, "out of the plane by Y", dot(d, y), rel[1]);
        check(dot(d, x) < 0.0 && dot(d, z) > 0.0, "behind and below", dot(d, x), -1.0);
    }

    /* +XVV -ZLV: body axes in M50 from the quaternion. */
    {
        double w = s->q[0], a = s->q[1], b = s->q[2], c = s->q[3];
        double bx[3] = { 1 - 2 * (b * b + c * c), 2 * (a * b + w * c), 2 * (a * c - w * b) };
        double bz[3] = { 2 * (a * c + w * b), 2 * (b * c - w * a), 1 - 2 * (a * a + b * b) };
        double rn = sqrt(dot(s->r, s->r)), vn = sqrt(dot(s->v, s->v));
        check(fabs(dot(bz, s->r) / rn + 1.0) < 1e-9, "body +Z is nadir", dot(bz, s->r) / rn, -1.0);
        check(dot(bx, s->v) / vn > 0.9999, "body +X along the velocity", dot(bx, s->v) / vn, 1.0);
        double hv[3];
        cross(s->r, s->v, hv);
        double n = sqrt(dot(hv, hv)) / (rn * rn);
        check(fabs(s->w[1] + n) < 1e-12 && s->w[0] == 0.0 && s->w[2] == 0.0,
              "pitching at the orbital rate", s->w[1], -n);
    }

    /* Once only; and a restore keeps the vehicle where it was. */
    {
        static double rec[4096];
        int n = vehdyn_save(rec, 4096);
        double r0[3];
        memcpy(r0, s->r, sizeof r0);
        vehdyn_advance(61.0e6);
        vehdyn_target(0, &id, rt, vt, qt);
        gwj_to_lvc(rt, vt, s->r, s->v, rel);
        /* closing at 2.04 ft/s for another minute: X grows ~37 m, no reset */
        check(rel[0] - now[0] > 30.0 && rel[0] - now[0] < 45.0, "another minute on, closing (m)",
              rel[0] - now[0], 37.0);
        vehdyn_load(rec, n);
        vehdyn_set_gmt_zero(1305700200.0 + 1.0);   /* the restored clock's zero */
        vehdyn_advance(0.01e6);
        double d = 0;
        for (int i = 0; i < 3; i++) d += (s->r[i] - r0[i]) * (s->r[i] - r0[i]);
        check(sqrt(d) < 100.0, "restored: where the capture left it, not placed again (m)", sqrt(d), 77.0);
    }

    remove(path);
    printf("vehdyn_rel: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
