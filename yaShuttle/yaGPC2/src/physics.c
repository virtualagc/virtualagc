#include "physics.h"

#include <math.h>
#include <string.h>

static void cross(const double a[3], const double b[3], double o[3]) {
    o[0] = a[1] * b[2] - a[2] * b[1];
    o[1] = a[2] * b[0] - a[0] * b[2];
    o[2] = a[0] * b[1] - a[1] * b[0];
}

static double dot(const double a[3], const double b[3]) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

static void matvec(const double m[3][3], const double v[3], double o[3]) {
    for (int i = 0; i < 3; i++) o[i] = m[i][0] * v[0] + m[i][1] * v[1] + m[i][2] * v[2];
}

/* Solve I x = b by Cramer's rule; the inertia tensor is small and well
 * conditioned, and this avoids keeping an inverse that must be refreshed
 * whenever the mass properties change. */
static void solve3(const double m[3][3], const double b[3], double x[3]) {
    double det = m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
               - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
               + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
    if (det == 0.0) { x[0] = x[1] = x[2] = 0.0; return; }
    for (int c = 0; c < 3; c++) {
        double t[3][3];
        memcpy(t, m, sizeof t);
        for (int r = 0; r < 3; r++) t[r][c] = b[r];
        x[c] = (t[0][0] * (t[1][1] * t[2][2] - t[1][2] * t[2][1])
              - t[0][1] * (t[1][0] * t[2][2] - t[1][2] * t[2][0])
              + t[0][2] * (t[1][0] * t[2][1] - t[1][1] * t[2][0])) / det;
    }
}

/* q * v * q^-1 for a unit quaternion q = [w x y z]. */
static void qrot(const double q[4], const double v[3], double o[3]) {
    double u[3] = { q[1], q[2], q[3] }, t[3], c[3];
    cross(u, v, t);
    for (int i = 0; i < 3; i++) t[i] *= 2.0;
    cross(u, t, c);
    for (int i = 0; i < 3; i++) o[i] = v[i] + q[0] * t[i] + c[i];
}

void phys_body_to_inertial(const PhysState *s, const double b[3], double out[3]) {
    qrot(s->q, b, out);
}

/* The 13-element derivative: r' = v; v' = -mu r / |r|^3 + R(q) f / m;
 * q' = q (x) [0, w] / 2; w' = I^-1 (tau - w x I w). */
typedef struct { double r[3], v[3], q[4], w[3]; } Deriv;

static void deriv(const PhysState *s, const double r[3], const double v[3],
                  const double q[4], const double w[3],
                  const double f[3], const double tau[3], Deriv *d) {
    double rr = sqrt(dot(r, r));
    double g = (rr > 0.0) ? -PHYS_MU_EARTH / (rr * rr * rr) : 0.0;
    double fi[3] = { 0, 0, 0 };
    if (f != NULL && s->mass > 0.0) {
        qrot(q, f, fi);
        for (int i = 0; i < 3; i++) fi[i] /= s->mass;
    }
    for (int i = 0; i < 3; i++) {
        d->r[i] = v[i];
        d->v[i] = g * r[i] + fi[i];
    }
    d->q[0] = 0.5 * (-q[1] * w[0] - q[2] * w[1] - q[3] * w[2]);
    d->q[1] = 0.5 * ( q[0] * w[0] + q[2] * w[2] - q[3] * w[1]);
    d->q[2] = 0.5 * ( q[0] * w[1] + q[3] * w[0] - q[1] * w[2]);
    d->q[3] = 0.5 * ( q[0] * w[2] + q[1] * w[1] - q[2] * w[0]);
    double Iw[3], wxIw[3], rhs[3];
    matvec(s->I, w, Iw);
    cross(w, Iw, wxIw);
    for (int i = 0; i < 3; i++) rhs[i] = (tau ? tau[i] : 0.0) - wxIw[i];
    solve3(s->I, rhs, d->w);
}

void phys_step(PhysState *s, double dt, const double fBody[3], const double tBody[3]) {
    Deriv k[4];
    double r[3], v[3], q[4], w[3];
    const double c[4] = { 0.0, 0.5, 0.5, 1.0 };
    for (int n = 0; n < 4; n++) {
        for (int i = 0; i < 3; i++) {
            double h = (n == 0) ? 0.0 : c[n] * dt;
            r[i] = s->r[i] + (n ? h * k[n - 1].r[i] : 0.0);
            v[i] = s->v[i] + (n ? h * k[n - 1].v[i] : 0.0);
            w[i] = s->w[i] + (n ? h * k[n - 1].w[i] : 0.0);
        }
        for (int i = 0; i < 4; i++)
            q[i] = s->q[i] + (n ? c[n] * dt * k[n - 1].q[i] : 0.0);
        deriv(s, r, v, q, w, fBody, tBody, &k[n]);
    }
    for (int i = 0; i < 3; i++) {
        s->r[i] += dt / 6.0 * (k[0].r[i] + 2 * k[1].r[i] + 2 * k[2].r[i] + k[3].r[i]);
        s->v[i] += dt / 6.0 * (k[0].v[i] + 2 * k[1].v[i] + 2 * k[2].v[i] + k[3].v[i]);
        s->w[i] += dt / 6.0 * (k[0].w[i] + 2 * k[1].w[i] + 2 * k[2].w[i] + k[3].w[i]);
    }
    double qn = 0.0;
    for (int i = 0; i < 4; i++) {
        s->q[i] += dt / 6.0 * (k[0].q[i] + 2 * k[1].q[i] + 2 * k[2].q[i] + k[3].q[i]);
        qn += s->q[i] * s->q[i];
    }
    qn = sqrt(qn);                       /* keep it a rotation */
    if (qn > 0.0) for (int i = 0; i < 4; i++) s->q[i] /= qn;
    s->t += dt;
}

void phys_advance_to(PhysState *s, double t, double maxDt,
                     const double fBody[3], const double tBody[3]) {
    if (maxDt <= 0.0) maxDt = 0.01;
    while (s->t < t) {
        double dt = t - s->t;
        if (dt > maxDt) dt = maxDt;
        if (dt < 1e-12) { s->t = t; break; }
        phys_step(s, dt, fBody, tBody);
    }
}

void phys_init_circular(PhysState *s, double re, double alt, double incl,
                        double raan, double arglat, double t) {
    double a = re + alt;
    double vc = sqrt(PHYS_MU_EARTH / a);
    /* In the orbit plane, then rotated by argument of latitude, inclination
     * and node. */
    double cu = cos(arglat), su = sin(arglat), ci = cos(incl), si = sin(incl),
           cO = cos(raan), sO = sin(raan);
    double rp[3] = { cO * cu - sO * su * ci, sO * cu + cO * su * ci, su * si };
    double vp[3] = { -cO * su - sO * cu * ci, -sO * su + cO * cu * ci, cu * si };
    for (int i = 0; i < 3; i++) { s->r[i] = a * rp[i]; s->v[i] = vc * vp[i]; }
    s->q[0] = 1.0; s->q[1] = s->q[2] = s->q[3] = 0.0;
    s->w[0] = s->w[1] = s->w[2] = 0.0;
    s->t = t;
}

double phys_orbit_energy(const PhysState *s) {
    return 0.5 * dot(s->v, s->v) - PHYS_MU_EARTH / sqrt(dot(s->r, s->r));
}

void phys_orbit_h(const PhysState *s, double h[3]) { cross(s->r, s->v, h); }

double phys_spin_energy(const PhysState *s) {
    double Iw[3];
    matvec(s->I, s->w, Iw);
    return 0.5 * dot(s->w, Iw);
}
