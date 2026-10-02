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

    /* The closed-form checks first, against a point mass in a vacuum. */
    phys_set_gravity(0, 0);
    phys_set_drag(0.0, 0.0, 0.0, 0.0);

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

    /* THE FIELD'S ZONAL COEFFICIENTS are the textbook J2, J3, J4. */
    check(fabs(phys_jn(2) / 1.08262668e-3 - 1.0) < 1e-6, "J2", phys_jn(2), 1.08262668e-3);
    check(fabs(phys_jn(3) / -2.53265649e-6 - 1.0) < 1e-5, "J3", phys_jn(3), -2.53265649e-6);
    check(fabs(phys_jn(4) / -1.61962159e-6 - 1.0) < 1e-5, "J4", phys_jn(4), -1.61962159e-6);

    /* J2 ALONE AGAINST ITS CLOSED FORM at an arbitrary point:
     * a = -mu r/r^3 [1 + 1.5 J2 (R/r)^2 (1 - 5 z^2/r^2)] in x, y and
     * [... (3 - 5 z^2/r^2)] in z. */
    {
        phys_set_gravity(2, 0);
        double r[3] = { 4.1e6, -3.3e6, 4.4e6 }, a[3];
        phys_gravity(0.0, r, a);
        double rr = norm(r), R = 6378136.3, j2 = phys_jn(2), z2 = r[2] * r[2] / (rr * rr);
        double k = -PHYS_MU_EARTH / (rr * rr * rr), c = 1.5 * j2 * (R / rr) * (R / rr);
        double want[3] = { k * r[0] * (1 + c * (1 - 5 * z2)), k * r[1] * (1 + c * (1 - 5 * z2)),
                           k * r[2] * (1 + c * (3 - 5 * z2)) };
        double d[3] = { a[0] - want[0], a[1] - want[1], a[2] - want[2] };
        check(norm(d) < 1e-12 * norm(want), "J2 acceleration, closed form", norm(a), norm(want));
    }

    /* THE FULL FIELD IS THE GRADIENT OF ITS POTENTIAL (central differences),
     * the tesseral terms included, with the Earth turned to some angle. */
    {
        phys_set_gravity(PHYS_GRAV_NMAX, PHYS_GRAV_NMAX);
        double r[3] = { -2.9e6, 5.1e6, 3.2e6 }, a[3], worst = 0.0, h = 1.0;
        phys_gravity(1234.5, r, a);
        for (int i = 0; i < 3; i++) {
            double rp[3], rm[3];
            memcpy(rp, r, sizeof rp); memcpy(rm, r, sizeof rm);
            rp[i] += h; rm[i] -= h;
            double g = (phys_potential(1234.5, rp) - phys_potential(1234.5, rm)) / (2 * h);
            if (fabs(g - a[i]) > worst) worst = fabs(g - a[i]);
        }
        check(worst < 1e-7, "4x4 field is the gradient of its potential (m/s^2)", worst, 0.0);
        /* and the non-central part is J2-sized: about 1e-3 of the whole */
        double pm = PHYS_MU_EARTH / (norm(r) * norm(r)), d[3];
        for (int i = 0; i < 3; i++) d[i] = a[i] + pm * r[i] / norm(r);
        check(norm(d) / pm > 3e-4 && norm(d) / pm < 3e-3, "the bulge's share of gravity",
              norm(d) / pm, 1e-3);
    }

    /* THE NODE REGRESSES under J2 at its secular rate,
     * -1.5 n J2 (R/a)^2 cos i: about 5 degrees a day at 400 km, 51.6 deg.
     * Measured over fifteen whole orbits, so the short-period swing of the
     * osculating node cancels. */
    {
        phys_set_gravity(2, 0);
        orbiter(&s);
        double inc = 51.6 * PI / 180, a = RE + 400e3, R = 6378136.3;
        phys_init_circular(&s, RE, 400e3, inc, 0.0, 0.0, 0.0);
        double n = sqrt(PHYS_MU_EARTH / (a * a * a));
        double T = 2 * PI / n * (1 - 1.5 * phys_jn(2) * (R / a) * (R / a) * (4 * cos(inc) * cos(inc) - 1));
        phys_advance_to(&s, 15 * T, 5.0, NULL, NULL);
        double h[3];
        phys_orbit_h(&s, h);
        double node = atan2(h[0], -h[1]);
        double want = -1.5 * n * phys_jn(2) * (R / a) * (R / a) * cos(inc) * 15 * T;
        check(fabs(node / want - 1.0) < 0.03, "nodal regression over 15 orbits (rad)", node, want);
        check(fabs(want * 180 / PI / (15 * T) * 86400 + 5.0) < 0.3, "about -5 deg/day",
              want * 180 / PI / (15 * T) * 86400, -5.0);
    }

    /* JACOBI'S INTEGRAL: in a field that turns uniformly about the pole,
     * v^2/2 - U - omega . (r x v) is conserved -- the energy check for the
     * full field, which is not static in the inertial frame. */
    {
        phys_set_gravity(PHYS_GRAV_NMAX, PHYS_GRAV_NMAX);
        orbiter(&s);
        phys_init_circular(&s, RE, 400e3, 51.6 * PI / 180, 0.3, 0.7, 0.0);
        double h[3];
        phys_orbit_h(&s, h);
        double j0 = 0.5 * (s.v[0] * s.v[0] + s.v[1] * s.v[1] + s.v[2] * s.v[2])
                  - phys_potential(s.t, s.r) - 7.2921158553e-5 * h[2];
        phys_advance_to(&s, 3 * 5560.0, 1.0, NULL, NULL);
        phys_orbit_h(&s, h);
        double j1 = 0.5 * (s.v[0] * s.v[0] + s.v[1] * s.v[1] + s.v[2] * s.v[2])
                  - phys_potential(s.t, s.r) - 7.2921158553e-5 * h[2];
        check(fabs(j1 - j0) / fabs(j0) < 1e-10, "Jacobi integral, 4x4 field, 3 orbits", j1, j0);
    }

    /* DRAG: the density at 400 km is the table's, and over one orbit the
     * orbit loses energy at rho Cd A v^3 / (2 m) -- the Orbiter nose-first,
     * 40 m^2, so the 2 e-7 m/s^2 the header promises, give or take. */
    {
        check(fabs(phys_air_density(400e3) - 3.725e-12) < 1e-16, "density at 400 km",
              phys_air_density(400e3), 3.725e-12);
        phys_set_gravity(0, 0);
        phys_set_drag(2.2, 40.0, 220.0, 360.0);
        orbiter(&s);
        phys_init_circular(&s, RE, 400e3, 0.0, 0.0, 0.0, 0.0);
        /* nose along the velocity: body X = inertial Y, a turn of 90 deg about Z */
        s.q[0] = cos(PI / 4); s.q[3] = sin(PI / 4);
        double ad[3];
        phys_drag_accel(&s, ad);
        double v = norm(s.v), vrel = v - 7.2921158553e-5 * (RE + 400e3);
        double want = 0.5 * 3.725e-12 * 2.2 * 40.0 * vrel * vrel / s.mass;
        check(fabs(norm(ad) / want - 1.0) < 0.01, "drag nose-first (m/s^2)", norm(ad), want);
        check(ad[1] < 0.0, "drag opposes the motion", ad[1], -want);
        /* side-on, five and a half times as much */
        s.q[0] = 1.0; s.q[3] = 0.0;
        double ad2[3];
        phys_drag_accel(&s, ad2);
        check(fabs(norm(ad2) / norm(ad) - 220.0 / 40.0) < 0.01, "drag follows the attitude",
              norm(ad2) / norm(ad), 5.5);
        /* an orbit's loss is the drag's power summed along it -- the area
         * changing as the wind goes round a body held fixed (a box shows
         * the wind sum A_i |u_i|, not a constant) */
        double e0 = phys_orbit_energy(&s), wantDe = 0.0;
        for (int i = 0; i < 556; i++) {
            double adp[3];
            phys_drag_accel(&s, adp);
            double p0 = adp[0] * s.v[0] + adp[1] * s.v[1] + adp[2] * s.v[2];
            phys_advance_to(&s, s.t + 10.0, 1.0, NULL, NULL);
            phys_drag_accel(&s, adp);
            wantDe += 5.0 * (p0 + adp[0] * s.v[0] + adp[1] * s.v[1] + adp[2] * s.v[2]);
        }
        double de = phys_orbit_energy(&s) - e0;
        check(fabs(de / wantDe - 1.0) < 0.002, "energy lost to drag in an orbit (J/kg)", de, wantDe);
        check(de < -5.0 && de > -50.0, "a few tens of J/kg an orbit at 400 km", de, -15.0);
        phys_set_drag(0.0, 0.0, 0.0, 0.0);
    }

    printf("physics: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
