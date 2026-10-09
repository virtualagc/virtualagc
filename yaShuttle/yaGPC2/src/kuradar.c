/* THE KU-BAND RENDEZVOUS RADAR (RR), as the GNC computers see it.
 *
 * THE INTERFACE.  The Ku-band signal processor hands the radar's output to
 * forward MDM 3, card 3 channel 3, and PASS reads ten words there in FF3's
 * MFE sequence (MLIB80/FIOMFBCE.asm 537-549: #MINC FIOFFIUA,FIOFFIC3 with
 * a count of 9; BCEEQU.asm FIOFFIC3 X'00024C69' = card 3, channel 3, ten
 * words) into CGBV_RNDZ_RDR (CGBIM1.hal 731-774; the source's "CD 5 CH 5"
 * comment is stale).  GYNRRP (the RR SOP, FSSR Part E 4.229) decodes them;
 * HAL bit 1 is a word's top bit:
 *
 *   word 1  bit 1 RADAR ON (else the display's 'COMM'), 2 AUTO TRACK
 *           ('ATRK'), 3 GPC DESIGNATE ('GDSG'), 4 GPC ACQUISITION ('GPC '),
 *           neither 'MSLW'; 8-9 the angle data-good code A - 1 (A = 4: angles
 *           and angle rates good, GYN_DG_MASK1 / GYN_ANG_RNG_STAT); 10
 *           SELF-TEST ('STST')
 *   word 2  bit 3 TRACK (watched in GPC mode: losing it sets the RR alarm);
 *           15-16 the range data-good code R - 1 (R = 4: range and range
 *           rate good)
 *   word 3  roll: sign, bits 2-13 x 0.0878906 deg
 *   word 4  pitch: sign, bits 2-12 x 0.0878906 deg
 *   word 5  range rate: sign, bits 2-16 x 0.05 ft/s
 *   words 7-8  range: word 7's 16 bits then word 8's top 7, x 0.005/16 kft
 *           (GELORB makes it feet: CGYV_RR_RNG_LFE = MFE x 1000)
 *   words 9-10  roll and pitch rates: sign, bits 2-15 x CGIK_DEG_RAD, which
 *           SPEC 33 shows as mrad/s (CG0330.dfg, FMT 5.1)
 *
 * WHAT PASS MAKES OF THE ANGLES (GLBRRA, FSSR Part C 4.2.8.2): with
 * CGNS_K_ANG 1.1693706 rad (c = 0.3907311, s = 0.9205048), trunnion =
 * asin(-c sin P + s sin R cos P) and shaft = atan2(-s sin P - c sin R cos P,
 * cos R cos P), against its prediction from the line of sight u in sensor
 * axes, u = CGNS_M_BODY_TO_RR . M50->body . (target - antenna): trunnion
 * asin(-u1), shaft atan2(u2, -u3).  Those are one rotation, so this radar
 * inverts it exactly: w = (-u1, u2, -u3), sin P = -(c w1 + s w2), and
 * tan R = (s w1 - c w2) / w3.  The antenna is GLRREN's GLR_R_OFFSET_BODY
 * (-12.2211, 11.1971, -1.82292 ft from the c.g., body axes), the same point
 * PASS predicts from, taken from the truth c.g.  CGNS_M_BODY_TO_RR is the
 * source's INITIAL (CGNMC2.hal 399-401): a turn of 67 deg about body Z.
 *
 * THE MODEL -- an estimate, not a specification.  There is no SM computer
 * here to point the antenna from GNC's line of sight (SM antenna
 * management), so the radar stands in for it: powered ON in a RADAR mode
 * and steered GPC, GPC DESIG or AUTO TRACK, it searches and locks when
 * vehdyn's first target is within its reach and not behind the Orbiter's
 * body; MAN SLEW never locks (there is no slew here).
 *   - Reach: skin track (RDR PASSIVE; RDR COOP finds no transponder on the
 *     ISS and skin-tracks too) to YAGPC_KU_ACQ_KFT, default 150 kft -- the
 *     ISS is big; the checklist starts RR NAVIGATION [13B] at 135 kft and
 *     the KU OPS cue card at NAV RNG < 150 kft.  Lock is lost beyond 1.1
 *     times that, or with the target behind the body (LOS more than 30 deg
 *     below the body's X-Y plane).
 *   - Search: 8 to 20 s from the designation to lock.
 *   - Noise: range 1 sigma sqrt(15^2 + (0.0015 R)^2) ft, range rate 0.3
 *     ft/s, each angle 0.08 deg, white; inside 3 kft the return wanders
 *     over the station's structure, a Gauss-Markov angle wander of
 *     atan(3 m / R) with a 30 s time constant -- the first try, 15 m and
 *     10 s, wandered fast enough that PASS's filter read it as 5 ft/s of
 *     lateral motion inside 1.5 kft (rr-run2) (PASS's own allowances:
 *     0.003 R with a 26.7 ft floor, 1 ft/s, 0.19 deg; CGNMC2.hal 392-397).
 *   - RADAR OUTPUT HIGH saturates the receiver inside 300 ft: range and
 *     range rate are then not good (the checklist goes LOW at ~700 ft). */
#define _POSIX_C_SOURCE 200809L
#include "kuradar.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vehdyn.h"

#define PI 3.14159265358979323846
#define D2R (PI / 180.0)
#define R2D (180.0 / PI)
#define FT 0.3048
#define ANG_LSB_DEG 0.0878906
#define RATE_LSB 0.017453293            /* CGIK_DEG_RAD: mrad/s a count */
#define RNG_LSB_KFT (0.005 / 16.0)
#define RDOT_LSB 0.05
#define K_COS 0.3907311
#define K_SIN 0.9205048

static const double M_BODY_TO_RR[3][3] = {
    { 0.3907311, 0.9205048, 0.0 },
    { -0.9205048, 0.3907311, 0.0 },
    { 0.0, 0.0, 1.0 },
};
static const double ANT_BODY_FT[3] = { -12.2211, 11.1971, -1.82292 };

typedef struct {
    uint16_t panel;
    bool panelHeard;
    bool locked;
    double searchStart, searchNeed;      /* vehicle time; < 0 not searching */
    double wander[2], wanderT;           /* the close-range angle wander, deg */
    double lastT, lastRoll, lastPitch;
    bool haveLast;
    unsigned long long rng;
    long reads, locks, losses;
    KuTruth truth;
} Radar;

static Radar rr = { .searchStart = -1.0, .rng = 0x9E3779B97F4A7C15ull };
static bool noiseless;
static double acqFt = -1.0;

static double acq_ft(void) {
    if (acqFt < 0.0) {
        const char *e = getenv("YAGPC_KU_ACQ_KFT");
        double k = e ? atof(e) : 0.0;
        acqFt = (k > 0.0 ? k : 150.0) * 1000.0;
    }
    return acqFt;
}

static double uniform(void) {
    rr.rng ^= rr.rng << 13;
    rr.rng ^= rr.rng >> 7;
    rr.rng ^= rr.rng << 17;
    return ((rr.rng >> 11) + 0.5) / 9007199254740992.0;
}
static double gauss(void) {
    if (noiseless) return 0.0;
    double a = uniform(), b = uniform();
    return sqrt(-2.0 * log(a)) * cos(2.0 * PI * b);
}

static void qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}

void kuradar_panel(uint16_t word, double t) {
    if (!rr.panelHeard || word != rr.panel)
        fprintf(stderr, "kuradar: panel %04x: power %s, mode %s, %s, output %s%s\n", word,
                (word & KU_PWR_ON) ? "ON" : "STBY/OFF",
                (word & KU_MODE_MASK) == KU_MODE_PASSIVE ? "RDR PASSIVE"
                : (word & KU_MODE_MASK) == KU_MODE_COOP ? "RDR COOP" : "COMM",
                (word & KU_SEL_MASK) == KU_SEL_GPC ? "GPC" : (word & KU_SEL_MASK) == KU_SEL_DESIG ? "GPC DESIG"
                : (word & KU_SEL_MASK) == KU_SEL_AUTO ? "AUTO TRACK" : "MAN SLEW",
                (word & KU_OUT_HIGH) ? "HIGH" : "LOW", (word & KU_SELF_TEST) ? ", SELF-TEST" : "");
    uint16_t was = rr.panel;
    rr.panel = word;
    rr.panelHeard = true;
    /* a change of power, mode or steering starts the acquisition over */
    if ((was ^ word) & (KU_PWR_ON | KU_MODE_MASK | KU_SEL_MASK)) {
        if (rr.locked) rr.losses++;
        rr.locked = false;
        rr.searchStart = -1.0;
    }
    (void)t;
}

static bool radar_on(void) {
    return (rr.panel & KU_PWR_ON) && (rr.panel & KU_MODE_MASK) != KU_MODE_COMM;
}

/* The geometry at the current vehicle state: false without a target. */
static bool geometry(KuTruth *o) {
    if (!vehdyn_enabled() || vehdyn_target_count() < 1) return false;
    int id;
    double rt[3], vt[3], qt[4];
    if (!vehdyn_target(0, &id, rt, vt, qt)) return false;
    const PhysState *s = vehdyn_state();
    double R[3][3], d[3], pa[3], va[3], wxd[3];
    qmat(s->q, R);                  /* body -> M50; the state is the centre of mass's, as PASS's */
    for (int i = 0; i < 3; i++) d[i] = ANT_BODY_FT[i] * FT;
    wxd[0] = s->w[1] * d[2] - s->w[2] * d[1];
    wxd[1] = s->w[2] * d[0] - s->w[0] * d[2];
    wxd[2] = s->w[0] * d[1] - s->w[1] * d[0];
    for (int i = 0; i < 3; i++) {
        pa[i] = s->r[i] + R[i][0] * d[0] + R[i][1] * d[1] + R[i][2] * d[2];
        va[i] = s->v[i] + R[i][0] * wxd[0] + R[i][1] * wxd[1] + R[i][2] * wxd[2];
    }
    double rel[3], vrel[3];
    for (int i = 0; i < 3; i++) { rel[i] = rt[i] - pa[i]; vrel[i] = vt[i] - va[i]; }
    double rn = sqrt(rel[0] * rel[0] + rel[1] * rel[1] + rel[2] * rel[2]);
    if (rn < 1.0) return false;
    double ub[3];
    for (int i = 0; i < 3; i++) ub[i] = (R[0][i] * rel[0] + R[1][i] * rel[1] + R[2][i] * rel[2]) / rn;
    for (int i = 0; i < 3; i++)
        o->u[i] = M_BODY_TO_RR[i][0] * ub[0] + M_BODY_TO_RR[i][1] * ub[1] + M_BODY_TO_RR[i][2] * ub[2];
    o->rangeFt = rn / FT;
    o->rdotFps = (rel[0] * vrel[0] + rel[1] * vrel[1] + rel[2] * vrel[2]) / rn / FT;
    /* behind the body: more than 30 deg below the X-Y plane (+Z down) */
    o->visible = ub[2] < sin(30.0 * D2R);
    return true;
}

/* Roll and pitch (deg) for a line of sight in sensor axes: GLBRRA inverted. */
static void roll_pitch(const double u[3], double *roll, double *pitch) {
    double w1 = -u[0], w2 = u[1], w3 = -u[2];
    double a = -(K_COS * w1 + K_SIN * w2), b = K_SIN * w1 - K_COS * w2;
    a = a > 1 ? 1 : a < -1 ? -1 : a;
    *pitch = asin(a) * R2D;
    *roll = atan2(b, w3) * R2D;
}

static uint16_t sign_mag(double x, double lsb, unsigned bits, unsigned shift) {
    double m = floor(fabs(x) / lsb + 0.5);
    double mx = (double)((1u << bits) - 1u);
    if (m > mx) m = mx;
    return (uint16_t)((x < 0 ? 0x8000u : 0u) | ((unsigned)m << shift));
}

void kuradar_read(uint16_t w[10], double t) {
    memset(w, 0, 10 * sizeof w[0]);
    rr.reads++;
    KuTruth g = { 0 };
    bool have = geometry(&g);
    g.locked = false;
    if (!radar_on()) {
        rr.locked = false;
        rr.searchStart = -1.0;
        rr.haveLast = false;
        rr.truth = g;
        return;
    }
    unsigned sel = rr.panel & KU_SEL_MASK;
    w[0] = 0x8000u;
    if (sel == KU_SEL_AUTO) w[0] |= 0x4000u;
    else if (sel == KU_SEL_DESIG) w[0] |= 0x2000u;
    else if (sel == KU_SEL_GPC) w[0] |= 0x1000u;
    if (rr.panel & KU_SELF_TEST) {
        w[0] |= 0x0040u;
        rr.truth = g;
        return;
    }
    double acq = acq_ft();
    bool reach = have && g.visible && g.rangeFt >= 30.0;
    if (rr.locked && !(reach && g.rangeFt <= 1.1 * acq)) {
        rr.locked = false;
        rr.losses++;
        rr.searchStart = -1.0;
        fprintf(stderr, "kuradar: track lost at t %.1f (range %.0f ft%s)\n", t, g.rangeFt,
                have && !g.visible ? ", behind the body" : "");
    }
    if (!rr.locked && sel != KU_SEL_SLEW && reach && g.rangeFt <= acq) {
        if (rr.searchStart < 0.0 || t < rr.searchStart) {
            rr.searchStart = t;
            rr.searchNeed = 8.0 + 12.0 * uniform();
        } else if (t - rr.searchStart >= rr.searchNeed) {
            rr.locked = true;
            rr.locks++;
            rr.haveLast = false;
            rr.wander[0] = rr.wander[1] = 0.0;
            rr.wanderT = t;
            fprintf(stderr, "kuradar: lock at t %.1f, range %.0f ft, range rate %+.2f ft/s\n", t, g.rangeFt,
                    g.rdotFps);
        }
    } else if (!rr.locked) {
        rr.searchStart = -1.0;
    }
    g.locked = rr.locked;
    rr.truth = g;
    if (!rr.locked) return;

    /* the measurements */
    double R = g.rangeFt;
    double roll, pitch;
    roll_pitch(g.u, &roll, &pitch);
    if (R < 3000.0) {
        double dt = t - rr.wanderT, tau = 30.0;
        double sg = atan(3.0 / (R * FT)) * R2D;
        double k = dt > 0 ? exp(-dt / tau) : 1.0;
        for (int i = 0; i < 2; i++)
            rr.wander[i] = rr.wander[i] * k + sg * sqrt(1.0 - k * k) * gauss();
        roll += rr.wander[0];
        pitch += rr.wander[1];
    }
    rr.wanderT = t;
    roll += 0.08 * gauss();
    pitch += 0.08 * gauss();
    double rm = R + sqrt(15.0 * 15.0 + (0.0015 * R) * (0.0015 * R)) * gauss();
    double rdm = g.rdotFps + 0.3 * gauss();
    bool rngGood = !((rr.panel & KU_OUT_HIGH) && R < 300.0);
    w[0] |= (uint16_t)(3u << 7);                       /* A = 4: angles and their rates good */
    w[1] = 0x2000u | (rngGood ? 3u : 0u);              /* TRACK; R = 4 or 1 */
    w[2] = sign_mag(roll, ANG_LSB_DEG, 12, 3);
    w[3] = sign_mag(pitch, ANG_LSB_DEG, 11, 4);
    if (rngGood) {
        w[4] = sign_mag(rdm, RDOT_LSB, 15, 0);
        double c = floor((rm < 0 ? 0 : rm) / 1000.0 / RNG_LSB_KFT + 0.5);
        if (c > 8388607.0) c = 8388607.0;
        unsigned long n = (unsigned long)c;
        w[6] = (uint16_t)(n >> 7);
        w[7] = (uint16_t)((n & 0x7Fu) << 9);
    }
    if (rr.haveLast && t > rr.lastT) {
        double dr = roll - rr.lastRoll;
        if (dr > 180.0) dr -= 360.0;
        if (dr < -180.0) dr += 360.0;
        w[8] = sign_mag(dr * D2R * 1000.0 / (t - rr.lastT), RATE_LSB, 14, 1);
        w[9] = sign_mag((pitch - rr.lastPitch) * D2R * 1000.0 / (t - rr.lastT), RATE_LSB, 14, 1);
    }
    rr.lastT = t;
    rr.lastRoll = roll;
    rr.lastPitch = pitch;
    rr.haveLast = true;
}

int kuradar_save(double *b, int max) {
    if (max < 6) return 0;
    b[0] = 1.0;                                          /* format */
    b[1] = rr.panelHeard ? (double)rr.panel : -1.0;
    b[2] = rr.locked ? 1.0 : 0.0;
    b[3] = rr.searchStart;
    b[4] = rr.searchNeed;
    b[5] = (double)(rr.rng & 0xFFFFFFFFFFFFull);
    return 6;
}

void kuradar_load(const double *b, int n, double tCap) {
    if (n < 6 || b[0] != 1.0) return;
    rr.panelHeard = b[1] >= 0.0;
    rr.panel = rr.panelHeard ? (uint16_t)b[1] : 0;
    rr.locked = b[2] != 0.0;
    rr.searchStart = b[3] >= 0.0 ? b[3] - tCap : -1.0;
    rr.searchNeed = b[4];
    unsigned long long s = (unsigned long long)b[5];
    rr.rng = s ? s : 0x9E3779B97F4A7C15ull;
    rr.haveLast = false;
}

void kuradar_report(void) {
    if (rr.reads == 0) return;
    fprintf(stderr, "kuradar: %ld reads, panel %04x, %ld locks, %ld losses, %s\n", rr.reads, rr.panel,
            rr.locks, rr.losses, rr.locked ? "locked" : "not locked");
}

void kuradar_test_truth(KuTruth *o) { *o = rr.truth; }
void kuradar_test_noiseless(bool off) { noiseless = off; }
