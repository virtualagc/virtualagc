/* THE TRUTH STATE AGAINST CLOSED-FORM ANSWERS (physics.c).
 *
 * Every check here compares the integrator with something worked out by
 * hand: the period of a circular orbit, the conservation laws of a free
 * body, and what a constant torque or force does in a known time.  Numbers
 * are the Orbiter's own order of magnitude -- 100 t, principal inertias of
 * about 1.3e6, 9.7e6 and 1.0e7 kg m^2, an 870 lbf (3870 N) primary jet. */
#include <math.h>
#include <stdio.h>
#include <string.h>

#include "../src/physics.h"

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [physics/%s] got %.9g want %.9g\n", what, got, want);
}

static double norm(const double a[3]) { return sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]); }

static void orbiter(PhysState *s) {
    memset(s, 0, sizeof *s);
    s->mass = 100000.0;
    s->I[0][0] = 1.29e6; s->I[1][1] = 9.68e6; s->I[2][2] = 1.01e7;
}

int main(void) {
    const double RE = 6378137.0, PI = 3.14159265358979323846;
    PhysState s;

    /* ONE CIRCULAR ORBIT AT 400 km, 51.6 deg: back where it began after one
     * period 2 pi sqrt(a^3 / mu), at constant radius, with energy and
     * angular momentum unchanged. */
    {
        orbiter(&s);
        phys_init_circular(&s, RE, 400e3, 51.6 * PI / 180, 0.3, 0.7, 0.0);
        double a = RE + 400e3, T = 2 * PI * sqrt(a * a * a / PHYS_MU_EARTH);
        double r0[3], v0[3], h0[3], h1[3];
        memcpy(r0, s.r, sizeof r0); memcpy(v0, s.v, sizeof v0);
        double e0 = phys_orbit_energy(&s);
        phys_orbit_h(&s, h0);
        check(fabs(norm(s.v) - sqrt(PHYS_MU_EARTH / a)) < 1e-6, "circular speed",
              norm(s.v), sqrt(PHYS_MU_EARTH / a));
        double worst = 0.0;
        for (int i = 0; i < 100; i++) {
            phys_advance_to(&s, T * (i + 1) / 100.0, 0.5, NULL, NULL);
            double dr = fabs(norm(s.r) - a);
            if (dr > worst) worst = dr;
        }
        double back[3] = { s.r[0] - r0[0], s.r[1] - r0[1], s.r[2] - r0[2] };
        check(norm(back) < 0.01, "closes after one period (m)", norm(back), 0.0);
        check(worst < 0.01, "radius constant (m)", worst, 0.0);
        check(fabs(phys_orbit_energy(&s) - e0) / fabs(e0) < 1e-10, "energy",
              phys_orbit_energy(&s), e0);
        phys_orbit_h(&s, h1);
        double dh[3] = { h1[0] - h0[0], h1[1] - h0[1], h1[2] - h0[2] };
        check(norm(dh) / norm(h0) < 1e-10, "angular momentum", norm(h1), norm(h0));
        check(fabs(T - 5553.6) < 1.0, "period at 400 km (s)", T, 5553.6);
    }

    /* A CONSTANT TORQUE FROM REST about Z: w = tau t / Izz, and the angle
     * turned is tau t^2 / (2 Izz).  Two primary jets on a ~10 m arm. */
    {
        orbiter(&s);
        phys_init_circular(&s, RE, 400e3, 0.0, 0.0, 0.0, 0.0);
        double tau[3] = { 0.0, 0.0, 2 * 3870.0 * 10.0 }, t = 10.0;
        phys_advance_to(&s, t, 0.01, NULL, tau);
        double wz = tau[2] * t / s.I[2][2];
        double ang = tau[2] * t * t / (2.0 * s.I[2][2]);
        check(fabs(s.w[2] - wz) < 1e-12, "rate under constant torque", s.w[2], wz);
        check(fabs(s.w[0]) < 1e-15 && fabs(s.w[1]) < 1e-15, "no cross-coupling about a principal axis",
              s.w[0] + s.w[1], 0.0);
        /* angle about Z from the quaternion: 2 atan2(qz, qw) */
        double got = 2.0 * atan2(s.q[3], s.q[0]);
        check(fabs(got - ang) < 1e-9, "angle turned", got, ang);
    }

    /* A FREE BODY TUMBLING about no principal axis: rotational energy and
     * the INERTIAL angular momentum are both conserved, while the body rates
     * themselves wander. */
    {
        orbiter(&s);
        phys_init_circular(&s, RE, 400e3, 0.0, 0.0, 0.0, 0.0);
        s.w[0] = 0.02; s.w[1] = 0.01; s.w[2] = -0.015;
        double e0 = phys_spin_energy(&s), Iw[3], L0[3], L1[3];
        Iw[0] = s.I[0][0] * s.w[0]; Iw[1] = s.I[1][1] * s.w[1]; Iw[2] = s.I[2][2] * s.w[2];
        phys_body_to_inertial(&s, Iw, L0);
        double w0x = s.w[0];
        phys_advance_to(&s, 600.0, 0.01, NULL, NULL);
        Iw[0] = s.I[0][0] * s.w[0]; Iw[1] = s.I[1][1] * s.w[1]; Iw[2] = s.I[2][2] * s.w[2];
        phys_body_to_inertial(&s, Iw, L1);
        double dL[3] = { L1[0] - L0[0], L1[1] - L0[1], L1[2] - L0[2] };
        check(fabs(phys_spin_energy(&s) - e0) / e0 < 1e-9, "spin energy", phys_spin_energy(&s), e0);
        check(norm(dL) / norm(L0) < 1e-8, "inertial angular momentum", norm(L1), norm(L0));
        check(fabs(s.w[0] - w0x) > 1e-4, "body rates do wander (the test is not trivial)",
              s.w[0], w0x);
        double qn = s.q[0] * s.q[0] + s.q[1] * s.q[1] + s.q[2] * s.q[2] + s.q[3] * s.q[3];
        check(fabs(qn - 1.0) < 1e-12, "quaternion stays unit", qn, 1.0);
    }

    /* A CONSTANT BODY FORCE: one jet firing forward for 10 s changes the
     * velocity by F t / m beyond what gravity alone does. */
    {
        PhysState ref;
        orbiter(&s);
        phys_init_circular(&s, RE, 400e3, 0.4, 0.2, 1.1, 0.0);
        ref = s;
        double f[3] = { 3870.0, 0.0, 0.0 };
        phys_advance_to(&s, 10.0, 0.01, f, NULL);
        phys_advance_to(&ref, 10.0, 0.01, NULL, NULL);
        double dv[3] = { s.v[0] - ref.v[0], s.v[1] - ref.v[1], s.v[2] - ref.v[2] };
        double want = 3870.0 * 10.0 / s.mass;
        check(fabs(norm(dv) - want) < 1e-4, "delta-v from a jet (m/s)", norm(dv), want);
        double xb[3] = { 1, 0, 0 }, xi[3];
        phys_body_to_inertial(&s, xb, xi);
        check(fabs((dv[0] * xi[0] + dv[1] * xi[1] + dv[2] * xi[2]) / norm(dv) - 1.0) < 1e-6,
              "along the body X axis", norm(dv), want);
    }

    printf("physics: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
