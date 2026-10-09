/* THE DOCKING (vehdyn.c, THE DOCKING): the ODS ring meeting PMA-2.
 *
 * A run of its own, because the vehicles come from the environment, which
 * vehdyn reads once: the ISS from STS-134's targets file with PMA-2's port
 * ("port 15.66 0 5.48": axis +X, the Orbiter's +X to zenith when mated).
 * Each case puts the Orbiter in the mated attitude with its ring's face
 * 0.3 m out from the port's, moving with the ISS's LVLH frame plus a
 * closing rate and a lateral offset -- through a snapshot, as a restore
 * does -- and runs the clock on:
 *
 *   - INSIDE THE ENVELOPE (0.10 ft/s, 1 in off): CAPTURE, and the A7L
 *     lights the cue cards expect.  Nothing retracts by itself: still soft
 *     docked 8 minutes on.  Then the crew's part (CC 9-11/9-12): POWER ON
 *     (dampers off, RING ALIGNED), RING IN, READY TO HOOK at 3:15, the hooks
 *     closing by themselves, INTERF SEALED, HOOKS 1/2 CLOSED -- HARD MATE:
 *     the ring's retracted face (Zo 460) on the port's face to a
 *     millimetre, the axes aligned, the Orbiter turning with the ISS.  A
 *     snapshot taken while mated restores mated, and stays so.
 *   - THE APDS POWERED OFF (POWER OFF pressed): contact inside the envelope,
 *     and no capture.
 *   - LAMP TEST lights the whole STATUS block.
 *   - TOO FAST (0.30 ft/s, over the hardware's 0.20): no capture, and the
 *     ring does not pass through the port's face.
 *   - TOO FAR OFF THE AXIS (6 in, over the 4.2 in requirement): no capture.
 *
 * All of it after restoring a capture made before ports existed, whose ISS
 * takes its port from the targets file. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/vehdyn.h"

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [vehdyn_dock/%s] got %.9g want %.9g\n", what, got, want);
}

static const double FT = 0.3048, IN_M = 0.0254;
static const double PORT[3] = { 15.66, 0.0, 5.48 };

static void qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}

static void cross(const double a[3], const double b[3], double c[3]) {
    c[0] = a[1] * b[2] - a[2] * b[1];
    c[1] = a[2] * b[0] - a[0] * b[2];
    c[2] = a[0] * b[1] - a[1] * b[0];
}

static double dot(const double a[3], const double b[3]) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }

/* Body -> M50 quaternion from the matrix whose columns are the body axes. */
static void mat_quat(const double R[3][3], double q[4]) {
    double tr = R[0][0] + R[1][1] + R[2][2];
    if (tr > 0.0) {
        double s4 = sqrt(tr + 1.0) * 2.0;
        q[0] = 0.25 * s4; q[1] = (R[2][1] - R[1][2]) / s4;
        q[2] = (R[0][2] - R[2][0]) / s4; q[3] = (R[1][0] - R[0][1]) / s4;
    } else if (R[0][0] > R[1][1] && R[0][0] > R[2][2]) {
        double s4 = sqrt(1.0 + R[0][0] - R[1][1] - R[2][2]) * 2.0;
        q[0] = (R[2][1] - R[1][2]) / s4; q[1] = 0.25 * s4;
        q[2] = (R[0][1] + R[1][0]) / s4; q[3] = (R[0][2] + R[2][0]) / s4;
    } else if (R[1][1] > R[2][2]) {
        double s4 = sqrt(1.0 + R[1][1] - R[0][0] - R[2][2]) * 2.0;
        q[0] = (R[0][2] - R[2][0]) / s4; q[1] = (R[0][1] + R[1][0]) / s4;
        q[2] = 0.25 * s4; q[3] = (R[1][2] + R[2][1]) / s4;
    } else {
        double s4 = sqrt(1.0 + R[2][2] - R[0][0] - R[1][1]) * 2.0;
        q[0] = (R[1][0] - R[0][1]) / s4; q[1] = (R[0][2] + R[2][0]) / s4;
        q[2] = (R[1][2] + R[2][1]) / s4; q[3] = 0.25 * s4;
    }
}

/* The ISS now: position, velocity, body axes (columns), rate (M50). */
static void iss(double rt[3], double vt[3], double Rt[3][3], double wt[3]) {
    int id;
    double q[4];
    if (!vehdyn_target(0, &id, rt, vt, q)) { printf("FAIL [vehdyn_dock] no ISS\n"); exit(1); }
    qmat(q, Rt);
    double h[3];
    cross(rt, vt, h);
    double rr = dot(rt, rt);
    for (int i = 0; i < 3; i++) wt[i] = h[i] / rr;
}

/* The ring's face at Zo zo from the CG, body m. */
static void ring(double zo, double b[3]) {
    double cg[3];
    vehdyn_cg_offset(cg);
    b[0] = -(649.0 - 1100.0) * IN_M - cg[0];
    b[1] = -cg[1];
    b[2] = -(zo - 375.0) * IN_M - cg[2];
}

/* The port's face, its axis and its velocity, and the ring's face (Zo zo)
 * with its gap along the axis and its offset off it. */
static void geometry(double zo, double *gap, double *lat, double ringV[3], double portV[3]) {
    double rt[3], vt[3], Rt[3][3], wt[3], P[3], a[3], pm[3], tmp[3];
    iss(rt, vt, Rt, wt);
    for (int i = 0; i < 3; i++) {
        pm[i] = Rt[i][0] * PORT[0] + Rt[i][1] * PORT[1] + Rt[i][2] * PORT[2];
        P[i] = rt[i] + pm[i];
        a[i] = Rt[i][0];
    }
    cross(wt, pm, tmp);
    for (int i = 0; i < 3; i++) portV[i] = vt[i] + tmp[i];
    const PhysState *s = vehdyn_state();
    double Ro[3][3], b[3], bm[3], d[3];
    qmat(s->q, Ro);
    ring(zo, b);
    for (int i = 0; i < 3; i++) bm[i] = Ro[i][0] * b[0] + Ro[i][1] * b[1] + Ro[i][2] * b[2];
    double wb[3], wm[3];
    cross(s->w, b, wb);
    for (int i = 0; i < 3; i++) wm[i] = Ro[i][0] * wb[0] + Ro[i][1] * wb[1] + Ro[i][2] * wb[2];
    for (int i = 0; i < 3; i++) { d[i] = s->r[i] + bm[i] - P[i]; ringV[i] = s->v[i] + wm[i]; }
    *gap = dot(d, a);
    *lat = sqrt(fmax(0.0, dot(d, d) - *gap * *gap));
}

/* The Orbiter put in the mated attitude, its ring's face gap metres out
 * along PMA-2's axis and off metres to the side (ISS +Y), closing at fps
 * relative to the turning frame -- through a snapshot, as a restore does. */
static void place(double gap, double off, double fps) {
    double rt[3], vt[3], Rt[3][3], wt[3];
    iss(rt, vt, Rt, wt);
    double Ro[3][3], b[3], bm[3], P[3], a[3], cg[3], v[3], tmp[3], d[3], w[3];
    /* body +X = ISS -Z, +Y = ISS +Y, +Z = ISS +X */
    for (int i = 0; i < 3; i++) { Ro[i][0] = -Rt[i][2]; Ro[i][1] = Rt[i][1]; Ro[i][2] = Rt[i][0]; }
    ring(475.75, b);
    for (int i = 0; i < 3; i++) {
        bm[i] = Ro[i][0] * b[0] + Ro[i][1] * b[1] + Ro[i][2] * b[2];
        a[i] = Rt[i][0];
        P[i] = rt[i] + Rt[i][0] * PORT[0] + Rt[i][1] * PORT[1] + Rt[i][2] * PORT[2];
        cg[i] = P[i] + gap * a[i] + off * Rt[i][1] - bm[i];
        d[i] = cg[i] - rt[i];
    }
    cross(wt, d, tmp);
    for (int i = 0; i < 3; i++) v[i] = vt[i] + tmp[i] - fps * FT * a[i];
    for (int i = 0; i < 3; i++) w[i] = Ro[0][i] * wt[0] + Ro[1][i] * wt[1] + Ro[2][i] * wt[2];
    double q[4];
    mat_quat(Ro, q);
    static double sb[256], tb[512];
    int n = vehdyn_save(sb, 256), nt = vehdyn_targets_save(tb, 512);
    check(n <= 256 && nt > 0, "snapshot fits", n, 256);
    for (int i = 0; i < 3; i++) { sb[3 + i] = cg[i]; sb[6 + i] = v[i]; sb[13 + i] = w[i]; }
    for (int i = 0; i < 4; i++) sb[9 + i] = q[i];
    vehdyn_load(sb, n);
    vehdyn_targets_load(tb, nt);
}

/* A7L: hold a pushbutton for 1.5 s (it acts after a second), then let go. */
static double run(double *t, double until);
static void press(double *t, uint16_t pb) {
    vehdyn_apds_panel(0, pb);
    run(t, *t + 1.5);
    vehdyn_apds_panel(0, 0);
}

static bool lit(int word, uint16_t bit) {
    uint16_t w[2];
    vehdyn_apds_lights(w);
    return (w[word] & bit) != 0;
}

/* Run the clock on to t (s), in steps of 0.1 s; the least gap seen. */
static double run(double *t, double until) {
    double least = 1e9, gap, lat, rv[3], pv[3];
    while (*t < until - 1e-9) {
        *t += 0.1;
        vehdyn_advance(*t * 1e6);
        geometry(475.75, &gap, &lat, rv, pv);
        if (gap < least) least = gap;
    }
    return least;
}

int main(void) {
    const char *path = "vehdyn_dock_targets.tmp";
    FILE *f = fopen(path, "w");
    if (f == NULL) { printf("FAIL [vehdyn_dock] cannot write %s\n", path); return 1; }
    fprintf(f, "# NORAD 25544, state at 2011-05-18T10:14:00Z UTC; PMA-2\n"
               "target 25544 1305713640.000 2109180.064 -5654207.985 -2965963.140 "
               "5848.388583 -433.197860 4989.397766 lvlh bc 130 port 15.66 0 5.48\n");
    fclose(f);
    setenv("YAGPC_VEHDYN", "1", 1);
    setenv("YAGPC_VEHDYN_TARGETS", path, 1);
    vehdyn_reset(0.0);
    vehdyn_set_gmt_zero(1305713640.0);
    vehdyn_advance(1.0e6);
    check(vehdyn_target_count() == 1, "the ISS is read, port and all", vehdyn_target_count(), 1);
    /* A capture from before ports existed (the first format: 14 doubles a
     * vehicle, no marker) takes the port from the targets file -- every
     * case below depends on it. */
    {
        static double tb[512], old[512];
        int nt = vehdyn_targets_save(tb, 512);
        check(nt == 1 + 24 && tb[0] == -2.0, "targets saved in the second format", nt, 25);
        for (int i = 0; i < 14; i++) old[i] = tb[1 + i];
        vehdyn_targets_load(old, 14);
        vehdyn_advance(1.1e6);
        check(vehdyn_target_count() == 1, "a first-format capture restores", vehdyn_target_count(), 1);
    }

    /* TOO FAST: 0.30 ft/s. */
    double t = 0.0, gap, lat, rv[3], pv[3];
    place(0.3, 0.0, 0.30);
    double least = run(&t, 10.0);
    check(vehdyn_docked() == 0, "no capture at 0.30 ft/s", vehdyn_docked(), 0);
    check(least > -0.01, "the ring does not pass through the port's face (m)", least, 0.0);
    geometry(475.75, &gap, &lat, rv, pv);
    {
        double a[3], rt[3], vt[3], Rt[3][3], wt[3], d[3];
        iss(rt, vt, Rt, wt);
        for (int i = 0; i < 3; i++) { a[i] = Rt[i][0]; d[i] = rv[i] - pv[i]; }
        check(fabs(dot(d, a)) < 0.01 * FT, "the closing is taken by the contact (ft/s)", dot(d, a) / FT, 0.0);
    }

    /* TOO FAR OFF THE AXIS: 6 in. */
    t = 0.0;
    place(0.3, 6.0 * IN_M, 0.10);
    run(&t, 15.0);
    check(vehdyn_docked() == 0, "no capture 6 in off the axis", vehdyn_docked(), 0);

    /* THE APDS POWERED OFF: inside the envelope, no capture. */
    t = 0.0;
    place(0.3, 1.0 * IN_M, 0.10);
    press(&t, 0x2000);                                   /* POWER OFF */
    check(!lit(0, 0x8000), "POWER OFF: the POWER ON light out", 0, 0);
    run(&t, 15.0);
    check(vehdyn_docked() == 0, "no capture with the APDS powered off", vehdyn_docked(), 0);

    /* LAMP TEST, with the APDS back on (the snapshot place() goes through
     * carries the APDS too, so the POWER OFF above stands until undone) */
    t = 0.0;
    place(3.0, 0.0, 0.0);
    press(&t, 0x4000);                                   /* POWER ON */
    vehdyn_apds_panel(0, 0x8000);
    run(&t, 0.5);
    {
        uint16_t w[2];
        vehdyn_apds_lights(w);
        check(w[0] == 0xFFFF && (w[1] & 0xC000) == 0xC000, "LAMP TEST lights the STATUS block", w[0], 0xFFFF);
    }
    vehdyn_apds_panel(0, 0);
    run(&t, 1.0);
    check(lit(0, 0x8000) && lit(0, 0x2000) && lit(0, 0x1000) && lit(0, 0x0600) && lit(0, 0x0100) &&
          !lit(0, 0x0020), "docking prep: POWER ON, RING ALIGNED, INITIAL POSITION, HOOKS OPEN, LATCHES CLOSED", 0, 0);

    /* INSIDE THE ENVELOPE: 0.10 ft/s, 1 in off. */
    t = 0.0;
    place(0.3, 1.0 * IN_M, 0.10);
    run(&t, 15.0);
    check(vehdyn_docked() == 1, "CAPTURE at 0.10 ft/s, 1 in off", vehdyn_docked(), 1);
    check(lit(0, 0x0020) && !lit(0, 0x0040) && !lit(0, 0x1000),
          "the CAPTURE light; INITIAL CONTACT and RING INITIAL POSITION out", 0, 0);
    run(&t, 15.0 + 60.0);
    check(!lit(0, 0x2000), "the dampers on: RING ALIGNED not lit", 0, 0);
    run(&t, 15.0 + 480.0);
    check(vehdyn_docked() == 1, "still soft docked 8 min on: the retraction is the crew's", vehdyn_docked(), 1);
    press(&t, 0x4000);                                   /* POWER ON: dampers off */
    run(&t, t + 2.0);
    check(lit(0, 0x2000), "POWER ON (dampers off): RING ALIGNED", 0, 0);
    press(&t, 0x0800);                                   /* RING IN */
    double t0 = t;
    run(&t, t0 + 190.0);
    check(!lit(0, 0x0008), "no READY TO HOOK before 3:15", 0, 0);
    run(&t, t0 + 200.0);
    check(lit(0, 0x0008) && !lit(0, 0x0400), "READY TO HOOK at 3:15, the hooks starting", 0, 0);
    run(&t, t0 + 196.0 + 100.0);
    check(lit(0, 0x0004) && vehdyn_docked() == 1, "INTERF SEALED at 1:30, the hooks still closing", 0, 0);
    run(&t, t0 + 196.0 + 145.0);
    check(vehdyn_docked() == 2 && lit(0, 0x0003), "HARD MATE: HOOKS 1, 2 CLOSED at 2:20", vehdyn_docked(), 2);
    geometry(460.0, &gap, &lat, rv, pv);
    check(fabs(gap) < 1e-3, "retracted ring face on the port's face, along the axis (m)", gap, 0.0);
    check(lat < 1e-3, "and on its axis (m)", lat, 0.0);
    {
        double d[3];
        for (int i = 0; i < 3; i++) d[i] = rv[i] - pv[i];
        check(sqrt(dot(d, d)) < 1e-4, "the ring moves with the port (m/s)", sqrt(dot(d, d)), 0.0);
        const PhysState *s = vehdyn_state();
        double Ro[3][3], rt[3], vt[3], Rt[3][3], wt[3];
        qmat(s->q, Ro);
        iss(rt, vt, Rt, wt);
        double zx = Ro[0][2] * Rt[0][0] + Ro[1][2] * Rt[1][0] + Ro[2][2] * Rt[2][0];
        double xz = -(Ro[0][0] * Rt[0][2] + Ro[1][0] * Rt[1][2] + Ro[2][0] * Rt[2][2]);
        check(zx > cos(0.01 / 57.29578), "body +Z along PMA-2's axis", zx, 1.0);
        check(xz > cos(0.01 / 57.29578), "body +X to the ISS's zenith", xz, 1.0);
    }
    /* a snapshot while mated restores mated */
    {
        static double sb[256], tb[512];
        int n = vehdyn_save(sb, 256), nt = vehdyn_targets_save(tb, 512);
        vehdyn_load(sb, n);
        vehdyn_targets_load(tb, nt);
        t = 0.0;
        run(&t, 30.0);
        check(vehdyn_docked() == 2, "restored mated, and still mated", vehdyn_docked(), 2);
        geometry(460.0, &gap, &lat, rv, pv);
        check(fabs(gap) < 1e-3 && lat < 1e-3, "still on the port's face after the restore (m)", gap, 0.0);
    }

    remove(path);
    printf("vehdyn_dock: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
