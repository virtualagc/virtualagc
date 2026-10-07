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

/* ---------------------------------------------------------------------
 * THE EARTH: its orientation, its gravity field and its atmosphere.
 *
 * Orientation.  The field is fixed in the Earth, which turns under the
 * inertial frame: inertial -> Earth-fixed is Rz(theta) P, where P is constant
 * (the precession and nutation from M50 to the equator of date, held for the
 * session) and theta = theta0 + omega (t - t0) is the Earth rotation angle.
 * The defaults -- P the identity, theta0 zero at t = 0 -- put the pole on M50
 * Z and Greenwich on M50 X at the start of time, which is self-consistent
 * but not the real sky; phys_set_earth() replaces them, and vehdyn.c sets
 * them to the flight software's own (vehdyn_set_gmt_zero).
 *
 * Gravity.  A spherical-harmonic field to degree and order PHYS_GRAV_NMAX,
 * EGM96 to 4x4: the same size of field as the onboard navigation's coasting
 * model (4x4, with its own I-loaded coefficients, so a small real difference
 * between the truth and the navigation's model of it remains, as on the
 * vehicle).  The zonal terms J2 = 1.0826e-3 (the equatorial bulge, about a
 * thousand times the rest), J3 and J4 depend on latitude only; the tesseral
 * terms C22, S22 ... on longitude too.  The coefficients below are EGM96's
 * fully normalised values, to the precision they are usually quoted; the
 * zonal ones reproduce the textbook J2 1.08263e-3, J3 -2.5327e-6,
 * J4 -1.6196e-6 (test_physics.c checks that).  The acceleration is
 * Cunningham's V/W recursion (Montenbruck & Gill, Satellite Orbits, 3.2).
 *
 * Atmosphere.  Exponential, piecewise by altitude: Vallado's table 8-4
 * (Fundamentals of Astrodynamics), a standard static model -- no solar
 * activity, no day/night bulge, so drag is right to within a factor of a few
 * at orbital altitude, which is how well anyone knows it without a forecast.
 * At 400 km it is about 2e-7 m/s^2 on the Orbiter: ten-odd metres of
 * altitude a day, too small to fly by but real for a navigation that
 * propagates for hours.  The air turns with the Earth; the area presented to
 * it follows the attitude, a projection of three body-axis areas. */

#define PHYS_RE_GRAV 6378136.3            /* m, EGM96 reference radius */
#define PHYS_OMEGA_EARTH 7.2921158553e-5  /* rad/s, sidereal */

static const double CBAR[PHYS_GRAV_NMAX + 1][PHYS_GRAV_NMAX + 1] = {
    { 1.0 },
    { 0.0, 0.0 },
    { -4.84165371736e-4, -1.86987635955e-10, 2.43914352398e-6 },
    { 9.57254173792e-7, 2.02998882184e-6, 9.04627768605e-7, 7.21072657057e-7 },
    { 5.39873863789e-7, -5.36321616971e-7, 3.50694105785e-7, 9.90771803829e-7,
      -1.88560802735e-7 },
};
static const double SBAR[PHYS_GRAV_NMAX + 1][PHYS_GRAV_NMAX + 1] = {
    { 0.0 },
    { 0.0, 0.0 },
    { 0.0, 1.19528012031e-9, -1.40016683654e-6 },
    { 0.0, 2.48513158716e-7, -6.19025944205e-7, 1.41435626958e-6 },
    { 0.0, -4.73440265853e-7, 6.62671572540e-7, -2.00928369177e-7,
      3.08853169333e-7 },
};

static struct {
    double C[PHYS_GRAV_NMAX + 1][PHYS_GRAV_NMAX + 1];    /* unnormalised */
    double S[PHYS_GRAV_NMAX + 1][PHYS_GRAV_NMAX + 1];
    int n, m;                     /* degree and order in use */
    int ready;
    double P[3][3];               /* M50 -> equator of date */
    double theta0, t0, rate;      /* Earth rotation angle theta0 at t0, rad/s */
    double cd, area[3];           /* drag coefficient, body-axis areas m^2 */
} E = { .n = PHYS_GRAV_NMAX, .m = PHYS_GRAV_NMAX,
        .P = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } }, .rate = PHYS_OMEGA_EARTH,
        /* The Orbiter, roughly: seen nose-on (fuselage, wings edge-on, fin),
         * from the side (fuselage and fin), from above (wings and body). */
        .cd = 2.2, .area = { 40.0, 220.0, 360.0 } };

static void env_ready(void) {
    if (E.ready) return;
    for (int n = 0; n <= PHYS_GRAV_NMAX; n++)
        for (int m = 0; m <= n; m++) {
            /* Cbar = C / N, N = sqrt((n+m)! / ((2 - d0m)(2n+1)(n-m)!)) */
            double f = (m == 0 ? 1.0 : 2.0) * (2 * n + 1);
            for (int k = n - m + 1; k <= n + m; k++) f /= k;
            E.C[n][m] = CBAR[n][m] * sqrt(f);
            E.S[n][m] = SBAR[n][m] * sqrt(f);
        }
    E.ready = 1;
}

void phys_set_gravity(int degree, int order) {
    if (degree < 0) degree = 0;
    if (degree > PHYS_GRAV_NMAX) degree = PHYS_GRAV_NMAX;
    if (order < 0) order = 0;
    if (order > degree) order = degree;
    E.n = degree; E.m = order;
}

void phys_set_drag(double cd, double ax, double ay, double az) {
    E.cd = cd; E.area[0] = ax; E.area[1] = ay; E.area[2] = az;
}

void phys_set_earth(const double P[3][3], double theta0, double t0, double rate) {
    memcpy(E.P, P, sizeof E.P);
    E.theta0 = theta0; E.t0 = t0;
    E.rate = (rate > 0.0) ? rate : PHYS_OMEGA_EARTH;
}

double phys_earth_angle(double t) {
    return E.theta0 + E.rate * (t - E.t0);
}

double phys_earth_rate(void) { return E.rate; }

void phys_earth_pole(double p[3]) { p[0] = E.P[2][0]; p[1] = E.P[2][1]; p[2] = E.P[2][2]; }

void phys_inertial_to_earth(double t, double M[3][3]) {
    double th = phys_earth_angle(t), c = cos(th), s = sin(th);
    for (int j = 0; j < 3; j++) {
        M[0][j] = c * E.P[0][j] + s * E.P[1][j];
        M[1][j] = -s * E.P[0][j] + c * E.P[1][j];
        M[2][j] = E.P[2][j];
    }
}

double phys_jn(int n) {
    env_ready();
    return (n >= 0 && n <= PHYS_GRAV_NMAX) ? -E.C[n][0] : 0.0;
}

/* V and W, the solid harmonics, to degree n+1 at the Earth-fixed point x. */
#define VW_N (PHYS_GRAV_NMAX + 2)
static void harmonics(const double x[3], int nmax, double V[VW_N][VW_N], double W[VW_N][VW_N]) {
    double r2 = dot(x, x), R = PHYS_RE_GRAV;
    double x0 = R * x[0] / r2, y0 = R * x[1] / r2, z0 = R * x[2] / r2, rho = R * R / r2;
    V[0][0] = R / sqrt(r2); W[0][0] = 0.0;
    V[1][0] = z0 * V[0][0]; W[1][0] = 0.0;
    for (int n = 2; n <= nmax + 1; n++) {
        V[n][0] = ((2 * n - 1) * z0 * V[n - 1][0] - (n - 1) * rho * V[n - 2][0]) / n;
        W[n][0] = 0.0;
    }
    for (int m = 1; m <= nmax + 1; m++) {
        V[m][m] = (2 * m - 1) * (x0 * V[m - 1][m - 1] - y0 * W[m - 1][m - 1]);
        W[m][m] = (2 * m - 1) * (x0 * W[m - 1][m - 1] + y0 * V[m - 1][m - 1]);
        if (m <= nmax) {
            V[m + 1][m] = (2 * m + 1) * z0 * V[m][m];
            W[m + 1][m] = (2 * m + 1) * z0 * W[m][m];
        }
        for (int n = m + 2; n <= nmax + 1; n++) {
            V[n][m] = ((2 * n - 1) * z0 * V[n - 1][m] - (n + m - 1) * rho * V[n - 2][m]) / (n - m);
            W[n][m] = ((2 * n - 1) * z0 * W[n - 1][m] - (n + m - 1) * rho * W[n - 2][m]) / (n - m);
        }
    }
}

/* Gravitational acceleration at inertial r and time t. */
static void gravity(double t, const double r[3], double a[3]) {
    double rr = sqrt(dot(r, r));
    if (rr <= 0.0) { a[0] = a[1] = a[2] = 0.0; return; }
    if (E.n < 2) {                       /* a point mass: the closed form */
        double g = -PHYS_MU_EARTH / (rr * rr * rr);
        for (int i = 0; i < 3; i++) a[i] = g * r[i];
        return;
    }
    env_ready();
    double M[3][3], x[3], V[VW_N][VW_N], W[VW_N][VW_N];
    phys_inertial_to_earth(t, M);
    matvec(M, r, x);
    harmonics(x, E.n, V, W);
    double ax = 0, ay = 0, az = 0;
    for (int m = 0; m <= E.m; m++)
        for (int n = m; n <= E.n; n++) {
            double C = E.C[n][m], S = E.S[n][m];
            if (m == 0) {
                ax -= C * V[n + 1][1];
                ay -= C * W[n + 1][1];
                az -= (n + 1) * C * V[n + 1][0];
            } else {
                double fac = 0.5 * (n - m + 1) * (n - m + 2);
                ax += 0.5 * (-C * V[n + 1][m + 1] - S * W[n + 1][m + 1])
                    + fac * (C * V[n + 1][m - 1] + S * W[n + 1][m - 1]);
                ay += 0.5 * (-C * W[n + 1][m + 1] + S * V[n + 1][m + 1])
                    + fac * (-C * W[n + 1][m - 1] + S * V[n + 1][m - 1]);
                az += (n - m + 1) * (-C * V[n + 1][m] - S * W[n + 1][m]);
            }
        }
    double k = PHYS_MU_EARTH / (PHYS_RE_GRAV * PHYS_RE_GRAV);
    double ae[3] = { k * ax, k * ay, k * az };
    for (int i = 0; i < 3; i++)            /* back to inertial: M transposed */
        a[i] = M[0][i] * ae[0] + M[1][i] * ae[1] + M[2][i] * ae[2];
}

double phys_potential(double t, const double r[3]) {
    double rr = sqrt(dot(r, r));
    if (rr <= 0.0) return 0.0;
    if (E.n < 2) return PHYS_MU_EARTH / rr;
    env_ready();
    double M[3][3], x[3], V[VW_N][VW_N], W[VW_N][VW_N];
    phys_inertial_to_earth(t, M);
    matvec(M, r, x);
    harmonics(x, E.n, V, W);
    double u = 0.0;
    for (int n = 0; n <= E.n; n++)
        for (int m = 0; m <= n && m <= E.m; m++)
            u += E.C[n][m] * V[n][m] + E.S[n][m] * W[n][m];
    return PHYS_MU_EARTH / PHYS_RE_GRAV * u;
}

void phys_gravity(double t, const double r[3], double a[3]) { gravity(t, r, a); }

/* Vallado table 8-4: base altitude km, density kg/m^3, scale height km. */
static const double ATMOS[][3] = {
    {    0, 1.225,     7.249 }, {   25, 3.899e-2,  6.349 }, {   30, 1.774e-2,  6.682 },
    {   40, 3.972e-3,  7.554 }, {   50, 1.057e-3,  8.382 }, {   60, 3.206e-4,  7.714 },
    {   70, 8.770e-5,  6.549 }, {   80, 1.905e-5,  5.799 }, {   90, 3.396e-6,  5.382 },
    {  100, 5.297e-7,  5.877 }, {  110, 9.661e-8,  7.263 }, {  120, 2.438e-8,  9.473 },
    {  130, 8.484e-9, 12.636 }, {  140, 3.845e-9, 16.149 }, {  150, 2.070e-9, 22.523 },
    {  180, 5.464e-10, 29.740 }, { 200, 2.789e-10, 37.105 }, { 250, 7.248e-11, 45.546 },
    {  300, 2.418e-11, 53.628 }, { 350, 9.518e-12, 53.298 }, { 400, 3.725e-12, 58.515 },
    {  450, 1.585e-12, 60.828 }, { 500, 6.967e-13, 63.822 }, { 600, 1.454e-13, 71.835 },
    {  700, 3.614e-14, 88.667 }, { 800, 1.170e-14, 124.64 }, { 900, 5.245e-15, 181.05 },
    { 1000, 3.019e-15, 268.00 },
};

double phys_air_density(double altM) {
    double h = altM / 1000.0;
    if (h < 0.0) h = 0.0;
    int k = (int)(sizeof ATMOS / sizeof ATMOS[0]) - 1;
    while (k > 0 && h < ATMOS[k][0]) k--;
    return ATMOS[k][1] * exp(-(h - ATMOS[k][0]) / ATMOS[k][2]);
}

/* Height above the WGS-84 ellipsoid, to first order in the flattening --
 * metres of error, nothing beside the density's own uncertainty. */
static double altitude(double t, const double r[3]) {
    double M[3][3], x[3];
    phys_inertial_to_earth(t, M);
    matvec(M, r, x);
    double rr = sqrt(dot(x, x)), sl = x[2] / rr;
    return rr - 6378137.0 * (1.0 - (1.0 / 298.257223563) * sl * sl);
}

/* Drag acceleration, inertial, on a body of attitude q and mass m. */
static void drag(const PhysState *s, double t, const double r[3], const double v[3],
                 const double q[4], double a[3]) {
    a[0] = a[1] = a[2] = 0.0;
    if (E.cd <= 0.0 || s->mass <= 0.0) return;
    double rho = phys_air_density(altitude(t, r));
    if (rho < 1e-18) return;
    /* the air turns with the Earth, about the pole of date */
    double pole[3] = { E.P[2][0], E.P[2][1], E.P[2][2] }, wxr[3], vr[3];
    cross(pole, r, wxr);
    for (int i = 0; i < 3; i++) vr[i] = v[i] - E.rate * wxr[i];
    double sp = sqrt(dot(vr, vr));
    if (sp <= 0.0) return;
    double qc[4] = { q[0], -q[1], -q[2], -q[3] }, vb[3];
    qrot(qc, vr, vb);                    /* the wind's direction in the body */
    double A = (E.area[0] * fabs(vb[0]) + E.area[1] * fabs(vb[1]) + E.area[2] * fabs(vb[2])) / sp;
    double k = -0.5 * rho * E.cd * A * sp / s->mass;
    for (int i = 0; i < 3; i++) a[i] = k * vr[i];
}

void phys_drag_accel(const PhysState *s, double a[3]) { drag(s, s->t, s->r, s->v, s->q, a); }

/* The 13-element derivative: r' = v; v' = g(t, r) + drag + R(q) f / m;
 * q' = q (x) [0, w] / 2; w' = I^-1 (tau - w x I w). */
typedef struct { double r[3], v[3], q[4], w[3]; } Deriv;

static void deriv(const PhysState *s, double t, const double r[3], const double v[3],
                  const double q[4], const double w[3],
                  const double f[3], const double tau[3], Deriv *d) {
    double g[3], ad[3];
    gravity(t, r, g);
    drag(s, t, r, v, q, ad);
    double fi[3] = { 0, 0, 0 };
    if (f != NULL && s->mass > 0.0) {
        qrot(q, f, fi);
        for (int i = 0; i < 3; i++) fi[i] /= s->mass;
    }
    for (int i = 0; i < 3; i++) {
        d->r[i] = v[i];
        d->v[i] = g[i] + ad[i] + fi[i];
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
        deriv(s, s->t + c[n] * dt, r, v, q, w, fBody, tBody, &k[n]);
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

void phys_init_elements(PhysState *s, double re, double ha, double hp, double incl,
                        double raan, double argp, double nu, double t) {
    double ra = re + ha, rp = re + hp;
    if (ra < rp) { double x = ra; ra = rp; rp = x; }
    double a = 0.5 * (ra + rp), e = (ra - rp) / (ra + rp);
    double p = a * (1.0 - e * e), mu = PHYS_MU_EARTH;
    double r = p / (1.0 + e * cos(nu));
    /* perifocal position and velocity, then into the inertial frame by the
     * argument of perigee, inclination and node */
    double xp = r * cos(nu), yp = r * sin(nu);
    double vxp = -sqrt(mu / p) * sin(nu), vyp = sqrt(mu / p) * (e + cos(nu));
    double cO = cos(raan), sO = sin(raan), ci = cos(incl), si = sin(incl),
           cw = cos(argp), sw = sin(argp);
    double P[3] = { cO * cw - sO * sw * ci, sO * cw + cO * sw * ci, sw * si };
    double Q[3] = { -cO * sw - sO * cw * ci, -sO * sw + cO * cw * ci, cw * si };
    for (int i = 0; i < 3; i++) {
        s->r[i] = xp * P[i] + yp * Q[i];
        s->v[i] = vxp * P[i] + vyp * Q[i];
    }
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
