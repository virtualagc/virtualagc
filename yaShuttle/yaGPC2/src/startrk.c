/* THE STAR TRACKERS -- see startrk.h.
 *
 * SOURCES.  FSSR STS 83-0014V2-34 (Star Tracker SOP, OI-34): the word and
 * command formats (4.66.1.1.4, printed pp. 13-17), the hardware behaviour
 * (pp. 9-12) and the catalog (Table 5.2-1).  The flight source: the decode
 * (GY8DAT.hal:194-197, 431-434), the field-of-view test (GY5FOV.hal:83-91),
 * the self-test (GY1STS.hal), the aberration PASS removes (GY8DAT.hal:
 * 466-470).  TD0216 (Star Tracker/COAS workbook) pp. 4-1 to 4-6 and
 * JSC-12770 Vol 6 pp. 5-2 and B-34 for the hardware: field, scan times,
 * bright object sensor, doors and power.
 *
 * WHAT THE COMPUTERS SEE.  FSSR bit 0 is the most significant.
 *   word 1: b0 tracker good, b2 transmission word good, b3 shutter closed,
 *           b4 self-test engaged, b5 STAR PRESENT, b6 always 1, b8-15 an
 *           intensity count (PASS does not use it)
 *   word 2: H in bits 0-11, two's complement, 0.0025390625 deg a count;
 *           b12-15 transmission errors, all clear here
 *   word 3: V likewise; b12 self-test angle error, b13 self-test magnitude
 *           error, b14 POWER SUPPLY GOOD, b15 bright object alert OFF
 *   command: b0 offset scan, b1 self-test, b2 break track (0 -> 1 edge),
 *           b3 shutter open (held: manual, the bright object sensor
 *           disabled; a pulse: unlatch), b4-5 threshold, b6-10 H and b11-15
 *           V offset codes, (n - 15.5) x 0.306452 deg.
 * A tracker that is switched off answers nothing of its own, so its words
 * are zeros -- which PASS shows as BITE on SPEC 22.
 *
 * GEOMETRY.  The flight software's own chain, run forwards with the TRUTH
 * attitude where PASS uses its IMU's: v_ST = TNBST . TNBBODY^T . R(q)^T . u,
 * H = atan2(v2, v3), V = atan2(-v1, v3) (GY5FOV), TNBST and TNBBODY the
 * I-loads in memory on this tape.  A star sighting therefore measures
 * exactly how far the IMU's idea of the attitude is from the truth, which
 * is what an alignment is for.  The stars are the catalog PASS holds
 * (startable.h, tools/startable.py), displaced by aberration as PASS
 * expects to find them: + v/c of the vehicle, + the Earth's orbital
 * velocity (20.5 arcsec at the Sun's longitude), the term GY8DAT removes.
 *
 * THE HARDWARE MODEL (FSSR pp. 9-12; TD0216 4-3 to 4-6).
 *   - Full-field scan (command b0 = 0): a 10 deg square raster in 10 s;
 *     locks on the first catalog star above threshold the raster crosses.
 *   - Offset scan (b0 = 1): a 1 deg square around the commanded offset, in
 *     1 s.  A change of offset or of scan mode starts a new search.
 *   - Track: the star's H and V with 20 arcsec of noise (the tracker is
 *     specified to 1 arcmin; PASS averages 21 samples and wants consecutive
 *     ones within 0.15 deg), more above 0.2 deg/s of body rate; lost above
 *     0.5 deg/s, out of the field, behind the Earth, or behind a closed
 *     shutter or door.  Losing it resumes the search.
 *   - Break track (0 -> 1): drop the star and search on without it, until
 *     a new search.
 *   - Self-test (b1): the shutter closes and an LED star appears at H +4.25,
 *     V -4.25 deg; in the commanded search area it is found and reported
 *     with the alert present, as GY1STS's first pass requires; if the area
 *     misses it -- GY1STS's second pass reverses H on purpose -- the tracker
 *     latches FAIL (tracker good 0, angle error).  The latch clears when the
 *     self-test command does (the FSSR does not say when; this is the
 *     simplest reading).
 *   - Threshold: magnitudes on the image-dissector scale of the catalog.
 *     Thresholds 1-3 are the documented 2.4, 2.0 and 1.0.  Threshold 0 is
 *     documented as "+3.0, about 150 stars", yet 21 of the catalog's own 100
 *     stars are fainter than 3.0 on that scale, and a catalog of stars the
 *     tracker cannot see at its default setting makes no sense: so
 *     threshold 0 takes the whole catalog (to 3.5).
 *   - Bright object sensor: the shutter closes when the Sun is within 23
 *     deg of the boresight (opens again at 29), the sunlit Earth limb within
 *     16 (19), or a Moon past first quarter within 9 (11, not documented).
 *     It stays closed, latched, until the shutter command pulses -- which
 *     the SOP does when it sees it closed with no alert (FSSR pp. 42, 51).
 *     A spring closes it without power.
 *   - Power (O6 STAR TRACKER POWER) and door (DOOR CONTROL, hardwired) come
 *     from the panel.  Power off: no words; on again: shutter closed, full
 *     field, no star.  Door not fully open: no stars and no bright objects;
 *     the self-test light is inside and still works.  The 15 minute warm-up
 *     is a checklist wait; nothing here changes during it.
 * ------------------------------------------------------------------- */
#include "startrk.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

#include "vehdyn.h"
#include "startable.h"

#define D2R (3.14159265358979323846 / 180.0)
#define R2D (180.0 / 3.14159265358979323846)
#define LSB_DEG 0.0025390625
#define OFFSET_STEP_DEG 0.306452
#define FIELD_DEG 5.0
#define FULL_RASTER_S 10.0
#define OFFSET_RASTER_S 1.0
#define OFFSET_HALF_DEG 0.5
#define LED_H_DEG 4.25
#define LED_V_DEG (-4.25)
#define NOISE_ARCSEC 20.0
#define RATE_DEGRADE_DEGS 0.2
#define RATE_LOSE_DEGS 0.5
#define RE_M 6378137.0
#define ATMOS_M 50000.0
#define C_MS 299792458.0
#define ABER_RAD 9.935105e-5

static const double THRESHOLD_MAG[4] = { 3.5, 2.4, 2.0, 1.0 };

/* CGYS_TNBST (nav base -> tracker), 1 = -Z, 2 = -Y, and CGMS_TNBBODY (nav
 * base -> body), as in memory on this tape (tools/pasvar.py). */
static const double TNBST[3][3][3] = {
    { { 0 } },
    { { -0.00651344657, 0.999492586, -0.0311769098 },
      { 0.989126801, 0.00185892172, -0.147052646 },
      { -0.146920085, -0.0314957425, -0.98863709 } },
    { { -0.965746284, -0.184594095, 0.182370245 },
      { -0.186074317, 0.00279755401, -0.982531488 },
      { 0.180859327, -0.982810736, -0.0370500423 } },
};
static const double TNBBODY[3][3] = {
    { 0.98293535, 0.0, -0.18395135 },
    { 0.0,        1.0,  0.0        },
    { 0.18395135, 0.0,  0.98293535 },
};

enum { MODE_FULL = 0, MODE_OFFSET = 1, MODE_SELFTEST = 2 };

typedef struct {
    bool started, powered, doorOpen;
    uint16_t cmd;
    int mode;
    double t0, lastT, pPrev;     /* the search's start, the last update, the raster's place */
    int locked;                  /* catalog index + 1, -1 the self-test light, 0 none */
    unsigned char excl[STAR_TABLE_N];
    bool shutterClosed, sunA, horA, moonA, alert;
    bool stFail, stAngErr;
    double stStart;
    unsigned rng;
    double H, V;
    long reads, acquisitions, breaks, closes;
} Trk;

static Trk trk[3];

int startrk_unit(int ffUnit) { return ffUnit == 1 ? 1 : ffUnit == 3 ? 2 : 0; }

/* ------------------------------------------------------------------ */

static double dot(const double a[3], const double b[3]) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }
static double norm(const double a[3]) { return sqrt(dot(a, a)); }
static void unit(double a[3]) { double n = norm(a); if (n > 0) { a[0] /= n; a[1] /= n; a[2] /= n; } }
static double angle_deg(const double a[3], const double b[3]) {
    double c = dot(a, b) / (norm(a) * norm(b));
    return acos(c > 1 ? 1 : c < -1 ? -1 : c) * R2D;
}

static void qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}

/* C(tracker k <- M50) at the truth attitude. */
static void c_st_m50(int k, double M[3][3]) {
    double R[3][3], A[3][3];
    qmat(vehdyn_state()->q, R);                    /* body -> M50 */
    for (int i = 0; i < 3; i++)                    /* A = TNBST TNBBODY^T */
        for (int j = 0; j < 3; j++)
            A[i][j] = TNBST[k][i][0] * TNBBODY[j][0] + TNBST[k][i][1] * TNBBODY[j][1] +
                      TNBST[k][i][2] * TNBBODY[j][2];
    for (int i = 0; i < 3; i++)                    /* M = A R^T */
        for (int j = 0; j < 3; j++)
            M[i][j] = A[i][0] * R[j][0] + A[i][1] * R[j][1] + A[i][2] * R[j][2];
}

/* THE SUN AND THE MOON, low precision (the Astronomical Almanac's formulae:
 * the Sun to 0.01 deg, the Moon to about 0.3), in the equator and equinox of
 * date, then into M50 with the J2000 -> B1950 rotation -- 0.7 deg of
 * precession, which a 23 deg cone hardly notices but costs nothing. */
static const double J2000_TO_B1950[3][3] = {
    {  0.9999256782,  0.0111820610,  0.0048579479 },
    { -0.0111820611,  0.9999374784, -0.0000271474 },
    { -0.0048579477, -0.0000271765,  0.9999881997 },
};
static void to_m50(double v[3]) {
    double o[3];
    for (int i = 0; i < 3; i++)
        o[i] = J2000_TO_B1950[i][0] * v[0] + J2000_TO_B1950[i][1] * v[1] + J2000_TO_B1950[i][2] * v[2];
    memcpy(v, o, sizeof o);
}

/* The Sun's direction, and its ecliptic longitude and the obliquity (rad). */
static void sun_dir(double unixT, double u[3], double *lam, double *eps) {
    double n = unixT / 86400.0 + 2440587.5 - 2451545.0;
    double L = fmod(280.460 + 0.9856474 * n, 360.0) * D2R;
    double g = fmod(357.528 + 0.9856003 * n, 360.0) * D2R;
    *lam = L + (1.915 * sin(g) + 0.020 * sin(2 * g)) * D2R;
    *eps = (23.439 - 0.0000004 * n) * D2R;
    u[0] = cos(*lam);
    u[1] = cos(*eps) * sin(*lam);
    u[2] = sin(*eps) * sin(*lam);
    to_m50(u);
}

/* The Moon's geocentric position, m. */
static void moon_pos(double unixT, double r[3]) {
    double T = (unixT / 86400.0 + 2440587.5 - 2451545.0) / 36525.0;
#define S(a, b) sin((a + b * T) * D2R)
#define C(a, b) cos((a + b * T) * D2R)
    double lam = 218.32 + 481267.881 * T + 6.29 * S(134.9, 477198.85) - 1.27 * S(259.2, -413335.38)
               + 0.66 * S(235.7, 890534.23) + 0.21 * S(269.9, 954397.70) - 0.19 * S(357.5, 35999.05)
               - 0.11 * S(186.6, 966404.05);
    double bet = 5.13 * S(93.3, 483202.03) + 0.28 * S(228.2, 960400.87) - 0.28 * S(318.3, 6003.18)
               - 0.17 * S(217.6, -407332.20);
    double par = 0.9508 + 0.0518 * C(134.9, 477198.85) + 0.0095 * C(259.2, -413335.38)
               + 0.0078 * C(235.7, 890534.23) + 0.0028 * C(269.9, 954397.70);
#undef S
#undef C
    double dist = RE_M / sin(par * D2R), eps = 23.439 * D2R;
    double l = lam * D2R, b = bet * D2R;
    double x = cos(b) * cos(l), y = cos(b) * sin(l), z = sin(b);
    r[0] = dist * x;
    r[1] = dist * (cos(eps) * y - sin(eps) * z);
    r[2] = dist * (sin(eps) * y + cos(eps) * z);
    to_m50(r);
}

/* ------------------------------------------------------------------ */

static double gauss(Trk *s) {
    double u1, u2;
    s->rng = s->rng * 1103515245u + 12345u; u1 = ((s->rng >> 8) + 1.0) / 16777217.0;
    s->rng = s->rng * 1103515245u + 12345u; u2 = (s->rng >> 8) / 16777216.0;
    return sqrt(-2.0 * log(u1)) * cos(2.0 * 3.14159265358979323846 * u2);
}

/* Where catalog star i appears to tracker k: H, V (deg); false when it is
 * not in front of the tracker, behind the Earth or too faint. */
typedef struct {
    bool ok;
    double M[3][3];
    double r[3], v[3], e[3], rho, rhoAtm;
    double corr[3];
    double limit;
} Sky;

static void sky_setup(int k, Sky *sk, double t) {
    memset(sk, 0, sizeof *sk);
    if (!vehdyn_enabled()) return;
    const PhysState *s = vehdyn_state();
    c_st_m50(k, sk->M);
    memcpy(sk->r, s->r, sizeof sk->r);
    memcpy(sk->v, s->v, sizeof sk->v);
    double rn = norm(sk->r);
    for (int i = 0; i < 3; i++) sk->e[i] = -sk->r[i] / rn;
    sk->rho = asin(RE_M / rn > 1 ? 1 : RE_M / rn) * R2D;
    sk->rhoAtm = asin((RE_M + ATMOS_M) / rn > 1 ? 1 : (RE_M + ATMOS_M) / rn) * R2D;
    for (int i = 0; i < 3; i++) sk->corr[i] = sk->v[i] / C_MS;
    double ux = vehdyn_unix(t);
    if (ux > 0) {
        double su[3], lam, eps;
        sun_dir(ux, su, &lam, &eps);
        double a[3] = { sin(lam), -cos(eps) * cos(lam), -sin(eps) * cos(lam) };
        to_m50(a);
        for (int i = 0; i < 3; i++) sk->corr[i] += ABER_RAD * a[i];
    }
    sk->limit = THRESHOLD_MAG[(trk[k].cmd >> 10) & 3];
    sk->ok = true;
}

static bool star_hv(const Sky *sk, int i, double *H, double *V) {
    double u[3];
    for (int j = 0; j < 3; j++) u[j] = STAR_TABLE[i].u[j] + sk->corr[j];
    unit(u);
    if (angle_deg(u, sk->e) < sk->rhoAtm) return false;            /* behind the Earth */
    double v0 = dot(sk->M[0], u), v1 = dot(sk->M[1], u), v2 = dot(sk->M[2], u);
    if (v2 <= 0.0) return false;
    *H = atan2(v1, v2) * R2D;
    *V = atan2(-v0, v2) * R2D;
    return true;
}

/* The bright object sensor, with its hysteresis. */
static void bos(int k, const Sky *sk, double t) {
    Trk *s = &trk[k];
    double ux = vehdyn_unix(t);
    if (!sk->ok || ux <= 0 || !s->doorOpen) { s->sunA = s->horA = s->moonA = false; s->alert = false; return; }
    const double *b = sk->M[2];                    /* the boresight, M50 */
    double sun[3], lam, eps;
    sun_dir(ux, sun, &lam, &eps);
    /* the Sun, unless the Earth hides it */
    bool sunUp = angle_deg(sun, sk->e) > sk->rho;
    double as = angle_deg(b, sun);
    s->sunA = sunUp && (s->sunA ? as < 29.0 : as < 23.0);
    /* the sunlit Earth: the point of it nearest the boresight */
    double rn = norm(sk->r), th = angle_deg(b, sk->e), P[3];
    if (th < sk->rho) {
        double rb = dot(sk->r, b), d = -rb - sqrt(rb * rb - (rn * rn - RE_M * RE_M));
        for (int i = 0; i < 3; i++) P[i] = sk->r[i] + d * b[i];
        s->horA = dot(P, sun) > 0.0;
    } else {
        double n[3], be = dot(b, sk->e), L = sqrt(rn * rn - RE_M * RE_M);
        for (int i = 0; i < 3; i++) n[i] = b[i] - be * sk->e[i];
        unit(n);
        double cr = cos(sk->rho * D2R), sr = sin(sk->rho * D2R);
        for (int i = 0; i < 3; i++) P[i] = sk->r[i] + L * (cr * sk->e[i] + sr * n[i]);
        double dl = th - sk->rho;
        s->horA = dot(P, sun) > 0.0 && (s->horA ? dl < 19.0 : dl < 16.0);
    }
    /* a Moon past first quarter */
    double rm[3], dm[3];
    moon_pos(ux, rm);
    for (int i = 0; i < 3; i++) dm[i] = rm[i] - sk->r[i];
    bool bright = angle_deg(rm, sun) > 90.0 && angle_deg(dm, sk->e) > sk->rho;
    double am = angle_deg(b, dm);
    s->moonA = bright && (s->moonA ? am < 11.0 : am < 9.0);
    s->alert = s->sunA || s->horA || s->moonA;
}

static void new_search(Trk *s, double t) {
    s->locked = 0;
    memset(s->excl, 0, sizeof s->excl);
    s->t0 = t;
    s->pPrev = 0.0;
}

static void power_on(Trk *s, double t) {
    s->cmd = 0;
    s->mode = MODE_FULL;
    s->shutterClosed = true;                       /* the spring closed it */
    s->stFail = s->stAngErr = false;
    s->sunA = s->horA = s->moonA = s->alert = false;
    new_search(s, t);
}

static void start(int k, double t) {
    Trk *s = &trk[k];
    if (s->started) return;
    s->started = true;
    s->powered = true;
    s->doorOpen = true;
    power_on(s, t);
    s->shutterClosed = false;                      /* a tracker that has been running */
    s->lastT = t;
    s->rng = 0x5A17u + (unsigned)k;
}

static bool manual_open(const Trk *s) { return (s->cmd & 0x1000u) != 0; }

/* Bring tracker k up to vehicle time t: the shutter, the search, the track. */
static void update(int k, double t) {
    Trk *s = &trk[k];
    start(k, t);
    if (!s->powered) { s->lastT = t; return; }
    Sky sk;
    sky_setup(k, &sk, t);
    bos(k, &sk, t);
    if (manual_open(s)) s->shutterClosed = false;
    else if (s->alert) {
        if (!s->shutterClosed) s->closes++;
        s->shutterClosed = true;
    }
    double rate = 0.0;
    if (sk.ok) rate = norm(vehdyn_state()->w) * R2D;

    if (s->mode == MODE_SELFTEST) {
        bool offset = (s->cmd & 0x8000u) != 0;
        double hc = (((s->cmd >> 5) & 31) - 15.5) * OFFSET_STEP_DEG;
        double vc = ((s->cmd & 31) - 15.5) * OFFSET_STEP_DEG;
        bool inArea = !offset || (fabs(LED_H_DEG - hc) <= OFFSET_HALF_DEG + 0.25 &&
                                  fabs(LED_V_DEG - vc) <= OFFSET_HALF_DEG + 0.25);
        double findT = offset ? 0.5 : 3.0, failT = offset ? 2.0 : FULL_RASTER_S + 1.0;
        if (s->locked == 0 && !s->stFail) {
            if (inArea && t - s->stStart >= findT) { s->locked = -1; s->acquisitions++; }
            else if (!inArea && t - s->stStart >= failT) { s->stFail = true; s->stAngErr = true; }
        }
        s->lastT = t;
        return;
    }

    bool canSee = sk.ok && s->doorOpen && !s->shutterClosed && rate <= RATE_LOSE_DEGS;
    /* THE TRACK */
    if (s->locked > 0) {
        double H, V;
        int i = s->locked - 1;
        if (!canSee || !star_hv(&sk, i, &H, &V) || fabs(H) > FIELD_DEG || fabs(V) > FIELD_DEG ||
            STAR_TABLE[i].mag > sk.limit) {
            s->locked = 0;                         /* lost: search on from here */
            s->pPrev = fmod((t - s->t0) / (s->mode == MODE_OFFSET ? OFFSET_RASTER_S : FULL_RASTER_S), 1.0);
        }
    }
    /* THE SEARCH: the raster sweeps the area top to bottom; the first star
     * it crosses is the one it locks. */
    if (s->locked == 0 && canSee) {
        bool offset = s->mode == MODE_OFFSET;
        double raster = offset ? OFFSET_RASTER_S : FULL_RASTER_S;
        double hc = 0, vc = 0, half = FIELD_DEG;
        if (offset) {
            half = OFFSET_HALF_DEG;
            hc = (((s->cmd >> 5) & 31) - 15.5) * OFFSET_STEP_DEG;
            vc = ((s->cmd & 31) - 15.5) * OFFSET_STEP_DEG;
            double lim = FIELD_DEG - OFFSET_HALF_DEG;
            hc = hc > lim ? lim : hc < -lim ? -lim : hc;
            vc = vc > lim ? lim : vc < -lim ? -lim : vc;
        }
        double swept = (t - s->t0) / raster;
        double p = fmod(swept, 1.0), from = s->pPrev;
        bool whole = (t - s->lastT) >= raster;
        int best = -1;
        double bestKey = 2.0;
        for (int i = 0; i < STAR_TABLE_N; i++) {
            double H, V;
            if (s->excl[i] || STAR_TABLE[i].mag > sk.limit || !star_hv(&sk, i, &H, &V)) continue;
            if (fabs(H - hc) > half || fabs(V - vc) > half) continue;
            double f = (vc + half - V) / (2.0 * half);          /* 0 at the top */
            double key;
            if (whole) key = f;
            else if (p >= from) { if (f <= from || f > p) continue; key = f - from; }
            else { if (f > p && f <= from) continue; key = (f > from) ? f - from : f + 1.0 - from; }
            if (key < bestKey) { bestKey = key; best = i; }
        }
        if (best >= 0) { s->locked = best + 1; s->acquisitions++; }
        s->pPrev = p;
    }
    s->lastT = t;
}

void startrk_read(int k, uint16_t w[3], double t) {
    w[0] = w[1] = w[2] = 0;
    if (k < 1 || k > 2) return;
    Trk *s = &trk[k];
    update(k, t);
    s->reads++;
    if (!s->powered) return;                        /* nothing of its own: zeros */
    bool st = s->mode == MODE_SELFTEST;
    double H = 0, V = 0, mag = 9.0;
    bool present = false;
    if (s->locked == -1) {
        double n = NOISE_ARCSEC / 3600.0;
        H = LED_H_DEG + n * gauss(s); V = LED_V_DEG + n * gauss(s); mag = 2.0; present = true;
    } else if (s->locked > 0) {
        Sky sk;
        sky_setup(k, &sk, t);
        if (star_hv(&sk, s->locked - 1, &H, &V)) {
            double rate = norm(vehdyn_state()->w) * R2D;
            double n = NOISE_ARCSEC / 3600.0 *
                       (rate > RATE_DEGRADE_DEGS ? 1.0 + 4.0 * (rate - RATE_DEGRADE_DEGS) / 0.3 : 1.0);
            H += n * gauss(s); V += n * gauss(s);
            mag = STAR_TABLE[s->locked - 1].mag; present = true;
        }
    }
    s->H = H; s->V = V;
    int hc = (int)lround(H / LSB_DEG), vc = (int)lround(V / LSB_DEG);
    hc = hc > 2047 ? 2047 : hc < -2048 ? -2048 : hc;
    vc = vc > 2047 ? 2047 : vc < -2048 ? -2048 : vc;
    int inten = present ? (int)lround(120.0 - 20.0 * mag) : 0;
    inten = inten < 0 ? 0 : inten > 255 ? 255 : inten;
    bool shutter = st || s->shutterClosed;
    bool alertShown = st ? true : manual_open(s) ? false : s->alert;
    w[0] = (uint16_t)((s->stFail ? 0 : 0x8000u) | 0x2000u | (shutter ? 0x1000u : 0) |
                      (st ? 0x0800u : 0) | (present ? 0x0400u : 0) | 0x0200u | (unsigned)inten);
    w[1] = (uint16_t)(((unsigned)hc & 0xFFFu) << 4);
    w[2] = (uint16_t)((((unsigned)vc & 0xFFFu) << 4) | (s->stAngErr ? 0x0008u : 0) | 0x0002u |
                      (alertShown ? 0 : 0x0001u));
}

void startrk_command(int k, uint16_t cmd, double t) {
    if (k < 1 || k > 2) return;
    Trk *s = &trk[k];
    update(k, t);                                   /* what ran until now ran under the old word */
    uint16_t old = s->cmd;
    s->cmd = cmd;
    if (!s->powered) return;
    bool stNew = (cmd & 0x4000u) != 0, stOld = (old & 0x4000u) != 0;
    if (stNew && !stOld) {
        s->mode = MODE_SELFTEST;
        s->locked = 0;
        s->stFail = s->stAngErr = false;
        s->stStart = t;
    } else if (stOld && !stNew) {
        s->stFail = s->stAngErr = false;
        s->shutterClosed = true;                    /* latched, as the test left it */
        s->mode = (cmd & 0x8000u) ? MODE_OFFSET : MODE_FULL;
        new_search(s, t);
    } else if (stNew) {
        /* a new offset during the test starts it looking again */
        if ((cmd & 0x83FFu) != (old & 0x83FFu)) { s->locked = 0; s->stFail = s->stAngErr = false; s->stStart = t; }
    } else {
        int mode = (cmd & 0x8000u) ? MODE_OFFSET : MODE_FULL;
        if (mode != s->mode || (mode == MODE_OFFSET && (cmd & 0x03FFu) != (old & 0x03FFu))) {
            s->mode = mode;
            new_search(s, t);
        }
        if ((cmd & 0x2000u) && !(old & 0x2000u)) {  /* break track */
            if (s->locked > 0) s->excl[s->locked - 1] = 1;
            s->locked = 0;
            s->breaks++;
        }
    }
    if ((cmd & 0x1000u) && !(old & 0x1000u)) s->shutterClosed = false;   /* the unlatch pulse */
}

void startrk_hardware(int k, bool powered, bool doorOpen, double t) {
    if (k < 1 || k > 2) return;
    Trk *s = &trk[k];
    update(k, t);
    if (powered && !s->powered) power_on(s, t);
    if (!powered && s->powered) { s->locked = 0; s->shutterClosed = true; }
    s->powered = powered;
    s->doorOpen = doorOpen;
}

/* ------------------------------------------------------------------ */

#define SAVE_PER (21 + STAR_TABLE_N)
int startrk_save(double *b, int max) {
    int n = 0;
    for (int k = 1; k <= 2; k++) {
        Trk *s = &trk[k];
        double v[21] = { s->started, s->powered, s->doorOpen, s->cmd, s->mode, s->t0, s->lastT,
                         s->pPrev, s->locked, s->shutterClosed, s->sunA, s->horA, s->moonA,
                         s->alert, s->stFail, s->stAngErr, s->stStart, s->rng, s->H, s->V,
                         (double)s->acquisitions };
        for (int i = 0; i < 21; i++) if (n < max) b[n++] = v[i]; else n++;
        for (int i = 0; i < STAR_TABLE_N; i++) if (n < max) b[n++] = s->excl[i]; else n++;
    }
    return n;
}

void startrk_load(const double *b, int n, double tCap) {
    if (n != 2 * SAVE_PER) return;
    for (int k = 1, j = 0; k <= 2; k++) {
        Trk *s = &trk[k];
        s->started = b[j++] != 0; s->powered = b[j++] != 0; s->doorOpen = b[j++] != 0;
        s->cmd = (uint16_t)b[j++]; s->mode = (int)b[j++];
        s->t0 = b[j++] - tCap; s->lastT = b[j++] - tCap; s->pPrev = b[j++];
        s->locked = (int)b[j++]; s->shutterClosed = b[j++] != 0;
        s->sunA = b[j++] != 0; s->horA = b[j++] != 0; s->moonA = b[j++] != 0; s->alert = b[j++] != 0;
        s->stFail = b[j++] != 0; s->stAngErr = b[j++] != 0; s->stStart = b[j++] - tCap;
        s->rng = (unsigned)b[j++]; s->H = b[j++]; s->V = b[j++]; s->acquisitions = (long)b[j++];
        for (int i = 0; i < STAR_TABLE_N; i++) s->excl[i] = (unsigned char)(b[j++] != 0);
    }
}

void startrk_report(void) {
    static const char *NAME[3] = { "", "-Z", "-Y" };
    for (int k = 1; k <= 2; k++) {
        Trk *s = &trk[k];
        if (!s->started || s->reads == 0) continue;
        fprintf(stderr, "startrk: %s tracker %s, door %s; %ld read(s), %ld acquisition(s), "
                        "%ld break track(s), shutter closed by bright objects %ld time(s); now %s\n",
                NAME[k], s->powered ? "on" : "OFF", s->doorOpen ? "open" : "NOT OPEN", s->reads,
                s->acquisitions, s->breaks, s->closes,
                s->locked > 0 ? STAR_TABLE[s->locked - 1].name : s->locked < 0 ? "on the self-test light"
                                                                           : "searching");
    }
}

int startrk_test_locked(int k) {
    if (k < 1 || k > 2) return 0;
    int l = trk[k].locked;
    return l > 0 ? STAR_TABLE[l - 1].id : l;
}

void startrk_test_sun(double t, double u[3]) {
    double lam, eps;
    double ux = vehdyn_unix(t);
    if (ux <= 0) { u[0] = u[1] = u[2] = 0; return; }
    sun_dir(ux, u, &lam, &eps);
}
