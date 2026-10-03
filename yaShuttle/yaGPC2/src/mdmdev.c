#define _DEFAULT_SOURCE /* struct ip_mreq under -std=c11's strict mode */
#include "mdmdev.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/socket.h>
#include <unistd.h>

#include "compat.h"
#include "envcache.h"
#include "json.h"
#include "startrk.h"
#include "lpsmodel.h"
#include "eiumodel.h"
#include "mecmodel.h"
#include "vehdyn.h"

/* THE COMMAND WORD, below the interface unit address (BCEEQU.asm:36-57):
 *     mode (4) | card (4) | channel (5) | word count - 1 (5)
 * mode 8 is a write and 9 a read; for a discrete output the top bit of the
 * channel field says SET (1) or RESET (0).  Checked against the equates:
 * FIOIMUC1 X'24C0D' = read, card 3, channel 0, 14 words; FIOHOS07 X'23600' =
 * write, card 13, channel 16 (set, channel 0), one word. */
#define CMD_IUA(c)    (((c) >> 19) & 0x1fu)
#define CMD_MODE(c)   (((c) >> 14) & 0xfu)
#define CMD_CARD(c)   (((c) >> 10) & 0xfu)
#define CMD_CHAN(c)   (((c) >> 5) & 0x1fu)
#define CMD_WORDS(c)  (((c) & 0x1fu) + 1u)

#define IUA_FF 10u
#define IUA_FA 12u

/* FC1-4 are BCEs 20-23 and carry FF1-4; FC5-8 are BCEs 14-17 and carry
 * FA1-4 (FIOADCMC's bus start of 14; MEDS2.py's BCE map). */
static int ff_unit(int busID) { return (busID >= 20 && busID <= 23) ? busID - 19 : 0; }
static int fa_unit(int busID) { return (busID >= 14 && busID <= 17) ? busID - 13 : 0; }

bool mdmdev_enabled(void) {
    static int inited = 0, on = 0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MDM_DEVICES");
        on = e != NULL && *e != '\0' && strcmp(e, "0") != 0 &&
             strcasecmp(e, "off") != 0 && strcasecmp(e, "no") != 0 &&
             strcasecmp(e, "false") != 0;
    }
    return on != 0;
}

/* ---------------------------------------------------------------------
 * DISCRETE OUTPUTS -- what the computers have commanded, per MDM, card and
 * channel.  The flight software writes RESET then SET (CGBOBF.hal:1718-1722)
 * and makes each reset word the complement of its set word (GO2ORB.hal:
 * 373-374), so the state after both is the set word; applying each as what
 * it says -- bits in a reset word go to 0, bits in a set word go to 1 --
 * gives that whatever the order.
 * ------------------------------------------------------------------- */
#define NCARD 16
#define NCHAN 16
static uint16_t ffOut[5][NCARD][NCHAN];    /* [unit 1-4][card][channel] */
static uint16_t faOut[5][NCARD][NCHAN];
static bool ffOutSeen[5][NCARD][NCHAN];

static void discrete_write(uint16_t (*out)[NCARD][NCHAN], bool (*seen)[NCARD][NCHAN],
                           int unit, uint32_t cmd, const uint16_t *w, int n) {
    unsigned card = CMD_CARD(cmd), ch = CMD_CHAN(cmd);
    bool set = (ch & 0x10u) != 0;
    ch &= 0x0fu;
    for (int i = 0; i < n && ch + (unsigned)i < NCHAN; i++) {
        uint16_t *s = &out[unit][card][ch + (unsigned)i];
        if (set) *s |= w[i]; else *s &= (uint16_t)~w[i];
        if (seen) seen[unit][card][ch + (unsigned)i] = true;
    }
}

/* ---------------------------------------------------------------------
 * THE INERTIAL MEASUREMENT UNITS.  IMU n sits behind FF MDM n (FIOIMUPG's
 * commander FIOIMUI1/2/3 on FC1/2/3; TD0303B pp. 2-13, 4-8).  Word formats
 * are the IMU SOP FSSR's, STS 83-0013-34 printed pp. 12-19, as the flight
 * software reads them (CGBIM1.hal:925-930, GMBIMU.hal, GMDRES.hal).
 * ------------------------------------------------------------------- */
#define IMU_READ   0x24C0Du   /* FIOIMUC1: card 3 ch 0, 14 data words      */
#define IMU_DSCRT  0x27C00u   /* FIOIMUC2: card 15 ch 0, the IMU discretes  */
#define IMU_WRITE  0x20C01u   /* FIOIMUC3: card 3 ch 0, command words 1, 2  */
#define STU_READ   0x24C42u   /* FIOFFIC5: card 3 ch 2, a star tracker's 3 words */
#define STU_WRITE  0x20C40u   /* FIOHO203: card 3 ch 2, its command word     */

typedef struct {
    uint16_t cmd1, cmd2;      /* the last two command words, echoed back */
    bool haveCmd;
    long reads, writes;
} Imu;
static Imu imu[4];            /* [1..3] */

/* Word 1, BITE.  Bit 0 GOOD; bits 1-8 hardware failures, 9-10 command-word
 * transmission failures, all clear; bit 11 (D1/D8) is the accelerometer gain
 * the IMU is in, and must equal command word 2's bit 0 (GMBIMU).  FSSR bit 0
 * is the most significant. */
#define IMU_BITE_GOOD   0x8000u
#define IMU_BITE_D1D8   0x0010u
#define IMU_CMD2_HIGAIN 0x8000u

/* ---------------------------------------------------------------------
 * THE IMU SEEING THE VEHICLE MOVE (YAGPC_VEHDYN).  The forward model the
 * flight software inverts (GNWATT.hal:241-242, GMPTNB.hal:66-80):
 *
 *     C(body <- M50) = TNBBODY . TNBRL^T . M1^T . TCM50^T
 *     M1 = Rz(AZ) . Rx(IR) . Ry(P) . Rx(OR)          gimbal angles
 *
 * TNBBODY is the IMU case's 10.6-degree pitch-down mounting (CGMCOM.hal:437),
 * TNBRL the identity by default, and TCM50 -- the stable member's alignment
 * to M50 -- the identity on a vehicle IPL'd straight to OPS 2 (CGMIPC.hal:
 * 106, 202-203).  So M1 = R(q) . TNBBODY, where R(q) is the truth state's
 * body-to-inertial rotation, and with inner roll held at null (outer roll
 * servos it there):  P = asin(-M1[2][0]), OR = atan2(M1[2][1], M1[2][2]),
 * AZ = atan2(M1[1][0], M1[0][0]).
 *
 * EACH PLATFORM HAS ITS OWN ORIENTATION, P = C(M50 <- cluster), the
 * identity at IPL as PASS assumes (CGMIPC's TCM50), and it moves three ways
 * -- see imu_platform below: its gyros drift, PASS torques it a pulse at a
 * time to cancel that drift and to align it, and PASS slews it at 1.2 deg/s
 * to reposition it.  So M1 = P^T . R(q) . TNBBODY in general.
 *
 * The accelerometers count the non-gravitational delta-v in the platform
 * frame (= M50 here) at 0.0344488 ft/s a pulse, low gain, Z negated
 * (GMCACP.hal:62, 100); the remainder is carried between reads.
 *
 * AND EACH ACCELEROMETER HAS THE ERRORS PASS CALIBRATES OUT.  The flight
 * software turns its I-loads into a pulse weight and a bias per IMU and axis
 * (GMRTRA.hal:205-220): weight = (1 + SFLO 1e-6) x 0.0344488 ft/s, bias =
 * BILO 1e-6 x 32.174 ft/s^2, and compensates delta-V = counts x weight -
 * bias x dt (GMHACP).  A real IMU's raw counts contain the bias and the
 * scale error that those numbers describe, so that the compensated result is
 * the true delta-V; an emulated one that counted ideal pulses showed PASS a
 * constant phantom acceleration of up to 1.4 ft/s^2 (SPEC 21 ACC -0.59 +0.54
 * -1.20 on a coasting vehicle).  So the counts here are
 *     n = (delta-V + bias x dt) / weight,
 * with the I-load values as compiled (CGMCOM.hal:440-456; the same values
 * are in memory on this tape -- read with tools/pasvar.py).  High gain
 * weights a pulse at a tenth of that (CGMMC9.hal:658), and carries the same
 * calibration (SFHI = SFLO, BIHI = BILO).
 * ------------------------------------------------------------------- */
static const double TNBBODY[3][3] = {
    { 0.98293535, 0.0, -0.18395135 },
    { 0.0,        1.0,  0.0        },
    { 0.18395135, 0.0,  0.98293535 },
};
#define IMU_FT_PER_PULSE 0.0344488

/* THE IMUs ARE NOT AT THE CENTRE OF GRAVITY.  They sit in the navigation
 * base, which PASS places at (57.959, -0.067, -3.967) ft from the CG in body
 * axes (GRWIMU.hal:72, GRW_R_NB_CG); an accelerometer there senses the CG's
 * motion plus the base's own about the CG, so its velocity is the CG's plus
 * w x r carried into the platform frame.  PASS takes that term back out
 * (GRWIMU.hal:81-87: CGMV_VEL_SEL_CG = CGMV_VEL_SEL - Q(w x r), with its
 * estimated body rates) before Average-G uses the velocity (GHCORB.hal).
 * Counted at the CG, as these were, every change of body rate left PASS a
 * phantom delta-V of -(delta w) x r -- 0.226 ft/s when the rates moved by
 * (0.09, 0, -0.23) deg/s just after an OMS cutoff, which powered-flight
 * navigation accepted and kept (ledger #274).  So the counts include it,
 * with the same lever arm PASS assumes. */
static const double R_NB_CG_FT[3] = { 57.959, -0.067, -3.967 };
#define FT_M 0.3048

static void qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}

static double wrap360(double deg) {
    deg = fmod(deg, 360.0);
    return (deg < 0.0) ? deg + 360.0 : deg;
}

/* A resolver angle as its 1X and 8X words: 13-bit counts in the top bits. */
static void resolver_words(double deg, uint16_t *w1x, uint16_t *w8x) {
    deg = wrap360(deg);
    unsigned c1 = (unsigned)floor(deg * 8192.0 / 360.0) & 0x1FFFu;
    unsigned c8 = (unsigned)floor(deg * 65536.0 / 360.0) & 0x1FFFu;
    *w1x = (uint16_t)(c1 << 3);
    *w8x = (uint16_t)(c8 << 3);
}

/* CGMS_ACC_SFLO and CGMS_ACC_BILO, (IMU, axis), ppm and micro-g. */
static const double ACC_SF_PPM[3][3] = {
    {  45890.0, -42360.0,  54480.0 },
    { -35780.0, -34250.0, -48240.0 },
    {  39680.0,  30080.0, -58080.0 },
};
static const double ACC_BIAS_UG[3][3] = {
    {  18280.0, -16789.0,  37444.0 },
    { -17842.0, -13376.0, -32666.0 },
    {  14332.0,  12666.0, -39545.0 },
};
#define G0_FTS2 32.174

typedef struct { double dvFt[3]; double carry[3]; uint16_t count[3]; bool started; double t; } ImuAcc;
static ImuAcc imuAcc[4];

/* ---------------------------------------------------------------------
 * THE PLATFORMS MOVE.  PASS's alignment is open-loop: it commands torque or
 * slew and, when the time it allowed is up, simply ASSUMES the cluster went
 * where it was sent -- it sets TCM50 to the desired orientation
 * (GMMLAT.hal step 20.2).  A platform that ignores its commands therefore
 * does not merely fail to align: after an alignment PASS's attitude is wrong
 * by however far it meant to move the cluster.  The IMU SOP FSSR (STS
 * 83-0013-34, printed pp. 11-13) and the flight software agree on:
 *
 *   TORQUE, command word 1: three 5-bit two's-complement pulse counts, X in
 *   bits 0-4, Y 5-9, Z 10-14 (FSSR bit 0 = MSB; GMFGYO.hal step 25).  One
 *   pulse turns the cluster by KTN = -0.5 arc-second about that axis
 *   (CGMCOM.hal:315, "positive pulses ... cause a negative rotation"), times
 *   TORSCFA, 1 on this tape.  The IMU pays them out at one per 5 ms, so a
 *   command's at most 16 have all gone before the next, 160 ms later; they
 *   are applied when the command arrives.
 *
 *   SLEW, command word 2: SX+ 0x4000, SX- 0x2000, SY+ 0x1000, SY- 0x0800,
 *   SZ+ 0x0400, SZ- 0x0200 (GMMLAT.hal:258-268; HEX'5400' all positive,
 *   HEX'2A00' all negative).  1.2 deg/s for as long as the bit is set, and
 *   a POSITIVE bit turns the cluster NEGATIVELY.
 *
 *   DRIFT: PASS torques every platform at -COMPGR, which on orbit is
 *   -GYREST (GMKGYO.hal step 3; GM9MAS.hal: the mass-unbalance terms are
 *   I-loaded zero), the gyro restraint drift it expects.  A real gyro drifts
 *   by the I-load and a little more; this one drifts by exactly the I-load
 *   (CGMCOM.hal:418, the same in memory on this tape -- tools/pasvar.py),
 *   so the two cancel to within a pulse, plus YAGPC_IMU_DRIFT (below), the
 *   "little more" an alignment is there to remove.
 *
 * A rate w about the cluster's own axes turns P as dP/dt = P [w]x, so each
 * step is P <- P . Rot(w dt).  The time is the vehicle's (vehdyn).
 * ------------------------------------------------------------------- */
static const double GYREST[3][3] = {           /* CGMS_GYREST (IMU, axis), rad/s */
    { -1.31239e-6,  3.04123e-6, -1.96834e-6 },
    { -6.1668e-7,   3.518292e-6, 5.502635e-6 },
    {  5.4250e-7,  -1.0055e-6,   3.77815e-6 },
};
#define IMU_KTN_RAD   (-0.5 * 0.48481361e-5)  /* CGMS_KTN, a pulse */
#define IMU_SLEW_RAD  (1.2 * 3.14159265358979323846 / 180.0)
#define DEGHR_RADSEC  0.48481361e-5

typedef struct { double P[3][3]; double t; bool started; long pulses; double slewSec; } ImuPlat;
static ImuPlat plat[4];

/* YAGPC_IMU_DRIFT=<deg/hr>: drift beyond what PASS compensates, so that the
 * platforms wander apart and away from M50 and an alignment has something to
 * correct.  Each IMU and axis gets that rate times a fixed pattern of signs
 * and sizes, so that no two IMUs drift alike.  Unset or 0: none. */
static double imu_extra_drift(int n, int i) {
    static int inited = 0;
    static double v = 0.0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_IMU_DRIFT");
        if (e != NULL) v = atof(e);
    }
    static const double PAT[3][3] = { { 1.0, -0.6, 0.3 }, { -0.4, 0.8, -1.0 }, { 0.7, 0.5, -0.5 } };
    return v * PAT[n - 1][i] * DEGHR_RADSEC;
}

/* P <- P . Rot(v), v a rotation vector in the cluster's axes (Rodrigues). */
static void plat_rotate(double P[3][3], const double v[3]) {
    double th = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (th == 0.0) return;
    double k[3] = { v[0] / th, v[1] / th, v[2] / th }, c = cos(th), s = sin(th), C = 1.0 - c;
    double Rm[3][3] = {
        { c + k[0] * k[0] * C,        k[0] * k[1] * C - k[2] * s, k[0] * k[2] * C + k[1] * s },
        { k[1] * k[0] * C + k[2] * s, c + k[1] * k[1] * C,        k[1] * k[2] * C - k[0] * s },
        { k[2] * k[0] * C - k[1] * s, k[2] * k[1] * C + k[0] * s, c + k[2] * k[2] * C        },
    };
    double N[3][3];
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            N[i][j] = P[i][0] * Rm[0][j] + P[i][1] * Rm[1][j] + P[i][2] * Rm[2][j];
    memcpy(P, N, sizeof N);
}

/* Bring IMU n's platform up to vehicle time t: drift, and any slew the last
 * command word 2 has running. */
static void imu_platform(int n, double t) {
    ImuPlat *p = &plat[n];
    if (!p->started) {
        if (p->P[0][0] == 0.0 && p->P[1][1] == 0.0 && p->P[2][2] == 0.0)
            for (int i = 0; i < 3; i++)
                for (int j = 0; j < 3; j++) p->P[i][j] = (i == j) ? 1.0 : 0.0;
        p->t = t;
        p->started = true;
        return;
    }
    double dt = t - p->t;
    if (dt <= 0.0) return;
    p->t = t;
    uint16_t c2 = imu[n].cmd2;
    static const uint16_t POS[3] = { 0x4000u, 0x1000u, 0x0400u }, NEG[3] = { 0x2000u, 0x0800u, 0x0200u };
    double v[3];
    bool slewing = false;
    for (int i = 0; i < 3; i++) {
        double w = GYREST[n - 1][i] + imu_extra_drift(n, i);
        if (c2 & POS[i]) { w -= IMU_SLEW_RAD; slewing = true; }
        else if (c2 & NEG[i]) { w += IMU_SLEW_RAD; slewing = true; }
        v[i] = w * dt;
    }
    if (slewing) p->slewSec += dt;
    plat_rotate(p->P, v);
}

/* Command word 1's torque pulses, applied when the word arrives. */
static void imu_torque(int n, uint16_t cmd1, double t) {
    imu_platform(n, t);
    double v[3];
    for (int i = 0; i < 3; i++) {
        int f = (cmd1 >> (11 - 5 * i)) & 0x1f;
        if (f & 0x10) f -= 32;
        v[i] = f * IMU_KTN_RAD;
        plat[n].pulses += (f < 0) ? -f : f;
    }
    plat_rotate(plat[n].P, v);
}

static void imu_dynamic(int n, uint16_t w[14]) {
    const PhysState *s = vehdyn_state();
    double R[3][3], CR[3][3], M1[3][3];
    qmat(s->q, R);
    imu_platform(n, s->t);
    const double (*P)[3] = (const double (*)[3])plat[n].P;
    for (int i = 0; i < 3; i++)                    /* C(cluster <- body) = P^T R */
        for (int j = 0; j < 3; j++)
            CR[i][j] = P[0][i] * R[0][j] + P[1][i] * R[1][j] + P[2][i] * R[2][j];
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            M1[i][j] = CR[i][0] * TNBBODY[0][j] + CR[i][1] * TNBBODY[1][j] + CR[i][2] * TNBBODY[2][j];
    double sp = -M1[2][0];
    if (sp > 1.0) sp = 1.0;
    if (sp < -1.0) sp = -1.0;
    const double D = 180.0 / 3.14159265358979323846;
    double PIT = asin(sp) * D;
    double OR = atan2(M1[2][1], M1[2][2]) * D;
    double AZ = atan2(M1[1][0], M1[0][0]) * D;
    w[2] = 0;                                      /* inner roll 8X: null */
    resolver_words(OR, &w[3], &w[4]);
    resolver_words(PIT, &w[5], &w[6]);
    resolver_words(AZ, &w[7], &w[8]);
    /* the velocity counters */
    ImuAcc *a = &imuAcc[n];
    double dv[3];
    vehdyn_sensed_dv(dv);
    /* the navigation base's velocity about the CG, inertial, ft/s */
    double wr[3] = {
        s->w[1] * R_NB_CG_FT[2] - s->w[2] * R_NB_CG_FT[1],
        s->w[2] * R_NB_CG_FT[0] - s->w[0] * R_NB_CG_FT[2],
        s->w[0] * R_NB_CG_FT[1] - s->w[1] * R_NB_CG_FT[0],
    };
    double vnb[3];
    for (int i = 0; i < 3; i++) vnb[i] = R[i][0] * wr[0] + R[i][1] * wr[1] + R[i][2] * wr[2];
    double dt = a->started ? s->t - a->t : 0.0;
    if (dt < 0.0) dt = 0.0;
    double k = (imu[n].cmd2 & IMU_CMD2_HIGAIN) ? IMU_FT_PER_PULSE / 10.0 : IMU_FT_PER_PULSE;
    /* the inertial increment since the last read, in the cluster's axes */
    double ft[3], inc[3], incC[3];
    for (int i = 0; i < 3; i++) { ft[i] = dv[i] / FT_M + vnb[i]; inc[i] = ft[i] - a->dvFt[i]; }
    for (int i = 0; i < 3; i++) incC[i] = P[0][i] * inc[0] + P[1][i] * inc[1] + P[2][i] * inc[2];
    for (int i = 0; i < 3; i++) {
        if (!a->started) { a->dvFt[i] = ft[i]; continue; }
        double weight = (1.0 + ACC_SF_PPM[n - 1][i] * 1e-6) * k;
        double bias = ACC_BIAS_UG[n - 1][i] * 1e-6 * G0_FTS2;
        double pulses = (incC[i] + bias * dt) / weight + a->carry[i];
        double whole = floor(pulses);
        a->carry[i] = pulses - whole;
        a->dvFt[i] = ft[i];
        int d = (int)whole;
        if (i == 2) d = -d;                        /* Z counts the other way */
        a->count[i] = (uint16_t)(a->count[i] + (unsigned)d);
    }
    a->started = true;
    a->t = s->t;
    w[9] = a->count[0]; w[10] = a->count[1]; w[11] = a->count[2];
}

static void imu_read(int n, uint16_t *out, int words) {
    Imu *u = &imu[n];
    uint16_t w[14];
    memset(w, 0, sizeof w);
    w[0] = (uint16_t)(IMU_BITE_GOOD | ((u->cmd2 & IMU_CMD2_HIGAIN) ? IMU_BITE_D1D8 : 0));
    if (vehdyn_enabled()) {
        w[1] = 0x8000u;                            /* redundant rate: zero, positive */
        imu_dynamic(n, w);
    }
    /* w[1] redundant-axis rate: zero, not saturated -- a platform at rest.
     * w[2..8] the resolvers, inner roll 8X then outer roll, pitch and
     * azimuth 1X/8X: all gimbals at zero, where the coarse and fine readings
     * agree trivially (GMDRES) and inner roll is inside its limits.
     * w[9..11] the velocity counters: an accelerometer that senses nothing
     * leaves them where they are -- correct in orbit, and a known limit on
     * the pad, where the real ones would count 1 g. */
    w[12] = u->cmd1;          /* echoes: GMBIMU compares both every cycle */
    w[13] = u->cmd2;
    for (int i = 0; i < words; i++) out[i] = (i < 14) ? w[i] : 0;
    u->reads++;
}

/* The IMU discretes, card 15 (CGBIH1.hal:2888-2898), HAL bits 1-6: in
 * operate, pressure good, platform temperature ready and safe, CAPRI
 * temperature ready and safe.  All good. */
#define IMU_DSCRT_ALL_GOOD 0xFC00u

/* ---------------------------------------------------------------------
 * THE REACTION CONTROL SYSTEM -- 44 jets, 16 manifolds, their injector
 * temperatures and the propellant system's pressures and temperatures, as
 * the flight software reads them in its HFE (25 Hz) and MFE (6.25 Hz) PROM
 * reads.  Word layouts are the declaration order of CGBV_HFE_INPUT1
 * (CGBIH1.hal:536-631: FA 54 words, FF 36) and CGBV_MFE_INPUT (CGBIM1.hal:
 * 167-214: FA 34, FF 21), each count equal to the read's; bit n of a HAL/S
 * BIT(16) is mask 0x8000 >> (n-1).
 * ------------------------------------------------------------------- */
#define HFE_FA_READ 0x0836Eu    /* FIOHI1C1, 54 words, IUA 12 */
#define HFE_FF_READ 0x082E8u    /* FIOHI1C3, 36 words, IUA 10 */
#define MFE_FA_READ 0x082A5u    /* FIOFAIC1, 34 words, IUA 12 */
#define MFE_FF_READ 0x082C5u    /* FIOFFIC1, 21 words, IUA 10 */

/* THE JET FIRE COMMAND IS "B": the SET word of FF card 13 and of FA card 10
 * channel 0, bits in the order of the Pc table below (GP1ORB.hal:183-224,
 * CGBOBF.hal:519-603).  A, on FF card 5 and FA card 2, toggles every other
 * pass while any jet fires and is the jet driver's own safeguard; the
 * redundancy management looks only at B (GRORCS.hal:319-329), and so does
 * this. */
static uint16_t ff_jets_b(int k) { return (uint16_t)(ffOut[k][13][0] & 0xF000u); }
static uint16_t fa_jet_mask(int k) { return (k <= 2) ? 0xFF00u : 0xFC00u; }
static uint16_t fa_jets_b(int k) { return (uint16_t)(faOut[k][10][0] & fa_jet_mask(k)); }

/* CHAMBER PRESSURE LAGS THE FIRE COMMAND, both ways.  A real jet's Pc
 * discrete (from its reaction jet driver) comes up only once the valves have
 * opened, < 10 ms, and thrust has built, ~20 ms; and it stays up after the
 * off command while the valves close, < 10 ms, and thrust tails off, ~20 ms
 * (CSDL-C-4576 sec. 2, "normal RCS jet firing"; transport to the driver adds
 * more, TBD there).
 *
 * The flight software depends on the OFF lag.  GRORCS runs on the odd HFE
 * passes only, assembling CGRB_JET_FIRE from the output buffer at the END of
 * a pass (GRORCS.hal:315-330) and testing it at the START of its next one,
 * 80 ms later, against the Pc read that began that pass (:134-161).  The RCS
 * command SOP refreshes the buffer every pass (GEIORB.hal: GP1 before the
 * dispatcher), so in between the even pass writes whatever the DAP decided --
 * 27 ms before the read.  A jet the DAP turned off there is still "fire" in
 * CGRB_JET_FIRE; a Pc that drops at once reads as a jet that failed to fire,
 * one fail-off pass at the END of every firing, and a run of short firings
 * never clears the count: three and the jet is failed OFF (ledger #272).
 * With the off lag the read 27 ms after the command still sees pressure, and
 * the one 67 ms after does not.  The driver-output discrete stays immediate:
 * it is the driver's own electrical state. */
#define PC_ON_LAG_US  20000.0
#define PC_OFF_LAG_US 40000.0
static double pcNowUs;
static double pcOnUs[2][5][16], pcOffUs[2][5][16];     /* [0 FF, 1 FA] */
static uint16_t pcPrevB[2][5];
static bool pcInited;

static void pc_init(void) {
    for (int m = 0; m < 2; m++)
        for (int k = 0; k < 5; k++)
            for (int b = 0; b < 16; b++) pcOnUs[m][k][b] = pcOffUs[m][k][b] = -1e30;
    pcInited = true;
}

static void pc_clock(double sharedUs) {
    if (sharedUs >= 0.0 && sharedUs > pcNowUs) pcNowUs = sharedUs;
}

/* For test_mdmdev, whose bus model runs without a shared clock. */
void mdmdev_test_clock_us(double us) { pc_clock(us); }

/* Note when each jet's B bit changed: after every write to a fire card. */
static void pc_track(void) {
    if (!pcInited) pc_init();
    for (int m = 0; m < 2; m++)
        for (int k = 1; k <= 4; k++) {
            uint16_t now = m ? fa_jets_b(k) : ff_jets_b(k);
            uint16_t chg = (uint16_t)(now ^ pcPrevB[m][k]);
            for (int b = 0; b < 16; b++) {
                uint16_t bit = (uint16_t)(0x8000u >> b);
                if (!(chg & bit)) continue;
                if (now & bit) pcOnUs[m][k][b] = pcNowUs;
                else pcOffUs[m][k][b] = pcNowUs;
            }
            pcPrevB[m][k] = now;
        }
}

static uint16_t pc_word(int m, int k) {
    if (!pcInited) pc_init();
    uint16_t cmd = m ? fa_jets_b(k) : ff_jets_b(k), pc = 0;
    for (int b = 0; b < 16; b++) {
        uint16_t bit = (uint16_t)(0x8000u >> b);
        if (cmd & bit) {
            if (pcNowUs - pcOnUs[m][k][b] >= PC_ON_LAG_US) pc |= bit;
        } else if (pcNowUs - pcOffUs[m][k][b] < PC_OFF_LAG_US) {
            pc |= bit;
        }
    }
    return pc;
}

/* 2.5 V, as the A/D reports it: 6400 counts a volt (the leak limits are
 * written 6400 x volts, GRRRCS.hal:142-149).  The only check on an injector
 * temperature is a LOW one -- a leak -- at 0.625 V oxidizer and 0.425 V fuel
 * for the primaries and up to 1.3 V for a vernier in orbit; there is no high
 * limit and no rate check.  2.5 V clears every one. */
#define INJ_WARM 16000u

/* ---------------------------------------------------------------------
 * CREW CONTACTS: the panel side of the forward MDMs' discrete input cards.
 *
 * A crew switch is a contact wired to a channel of a DIH or DIL card, and
 * PASS reads it as a bit of an FF DSCRT word.  The panel (panelO6.py) drives
 * them on each MDM's HARDWARE SIDE bus, nsts-sim-gpc's `_FFk_mdmIO` (port
 * base + 100 + k - 1), in that bus's datagram shape (lru/mdm/mdmConf.coffee):
 * halfwords op, card type, card << 8 | channel, count, then one halfword per
 * channel -- op 1 SET ORs those bits in, 2 RESET clears them, 4 VALUE
 * replaces the channel.  Halfwords are big-endian here, as on our discrete
 * bus; the reference sends a native Uint16Array, but nothing of its runs on
 * these ports in ours.
 *
 * Opened only for a run wired to a panel (mdmdev_crew_open, from run.c with
 * --discretes), and independent of YAGPC_MDM_DEVICES: with the device model
 * off a forward-MDM read is all zeros, and the contacts are ORed into those
 * zeros once the panel has driven any; until then reads are untouched.
 *
 * THE AFT MDMs TOO: FA1-4 are crew units 5-8, on `_FAk_mdmIO` (port base +
 * 104 + k - 1, nsts-sim-gpc src/com/bus.civet), for the OMS ENG switches on
 * panel C3 -- FA DSCRT2 bits 7-8, DIH card 3 ch 1 (CGBIH1.hal 2167-2174). */
#define CREW_NFF 4
#define CREW_NUNIT 8
#define CREW_NCARD 16
#define CREW_NCHAN 3
#define CREW_PORT_OFFSET 100
#define CREW_OP_SET 1
#define CREW_OP_RESET 2
#define CREW_OP_VALUE 4
static uint16_t crewIn[CREW_NUNIT + 1][CREW_NCARD][CREW_NCHAN];
/* The RHCs' analog inputs: AID card 1 channels 0-7 and card 14 channels 0-6,
 * in the HFE read at words 21-28 and 29-35 (CGBIH1.hal 555-594, 2950-2975).
 * Signed halfwords, 6400 counts a volt; 0 is in detent.  Sent by
 * handcontrollers.py as op 4 VALUE records of type 6 (AID). */
#define CREW_TYPE_AID 6
/* A STAR TRACKER'S HARDWIRED SIDE: its POWER switch and its door, which the
 * computers neither command nor read (panel O6; JSC-12770 Vol 6 Table B-XI),
 * from the panel on the MDM it hangs off -- FF1 for -Z, FF3 for -Y -- as op 4
 * VALUE, type 7, card 3 channel 2 (the tracker's serial channel), one word:
 * 0x8000 powered, 0x4000 door fully open. */
#define CREW_TYPE_STU 7
#define CREW_AID_NCH 8
static int16_t crewAid[CREW_NFF + 1][CREW_NCARD][CREW_AID_NCH];
static bool crewAidHeard;
static int crewFd[CREW_NUNIT + 1] = { -1, -1, -1, -1, -1, -1, -1, -1, -1 };
static bool crewOpen, crewHeard, crewTrace;
static int crewPortBase;
static long crewMsgs;

/* ---------------------------------------------------------------------
 * THE NETWORK SIGNAL PROCESSOR AND THE GROUND'S UPLINK.
 *
 * PASS reads NSP1 through FF MDM 1 (bus 20, IUA 10) every 160 ms
 * (SSSRC/FIONSPPG.asm, FIONSR11): the power discrete (FIONSP1P, card 9
 * ch 1), the two-stage 'A' block discrete (FIONSPDR, card 4 ch 0), and 32
 * words of data (FIONSPRD, card 11 ch 3) -- a status word, ten 48-bit
 * command words as 30 halfwords, and a validity word (CDULNK.hal:266-312).
 * AIESIP hands the buffer to DUP_NSP_MSG_PROC only when status bit 1, DATA
 * READY (0x8000), is set; unused command slots must be all zeros; the NSP
 * answers each buffer once (DUPNSP.hal; nsts-sim-gpc lru/nsp).
 *
 * The ground is a program (discretePanel/groundstation.py) that sends each
 * poll's buffer as one datagram on port base + UPLINK_OFFSET: "UPL1", a
 * halfword count of command words (1-10), then the words, three halfwords
 * each, big-endian.  The buffers are delivered one per NSP1 data read, in
 * order.  UNTIL A GROUND HAS SENT SOMETHING THE NSP IS UNPOWERED, exactly as
 * before (mtumodel.c: zeros), so a run without a ground station is
 * unchanged; after it, the power discrete reads on (0x8000) and the block
 * discrete off. */
#define UPLINK_OFFSET 99
#define UPLINK_QMAX 64
#define NSP_DATA_READ  0x26C7Fu   /* FIONSPRD: card 11 ch 3, 32 words */
#define NSP1_POWER     0x26420u   /* FIONSP1P: card 9 ch 1, 1 word */
#define NSP2_POWER     0x27020u   /* FIONSP2P: card 12 ch 1, 1 word */
#define NSP_DISCRETE   0x25000u   /* FIONSPDR: card 4 ch 0, 1 word */

static int uplinkFd = -1;
static bool uplinkHeard;
static uint16_t uplinkQ[UPLINK_QMAX][31];    /* 30 command halfwords + validity */
static int uplinkHead, uplinkCount;
static long uplinkBuffers, uplinkWords;

static void uplink_open(int portBase, struct in_addr iface) {
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) return;
    int reuse = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse);
#if defined(SO_REUSEPORT) && !defined(__linux__)
    setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &reuse, sizeof reuse);
#endif
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)(portBase + UPLINK_OFFSET));
    struct ip_mreq mreq = {0};
    mreq.imr_multiaddr.s_addr = inet_addr("239.255.1.1");
    mreq.imr_interface.s_addr = iface.s_addr;
    if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0 ||
        setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof mreq) < 0) {
        fprintf(stderr, "mdmdev: no uplink (port %d): %s\n", portBase + UPLINK_OFFSET,
                strerror(errno));
        close(fd);
        return;
    }
    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);
    uplinkFd = fd;
}

static void uplink_poll(void) {
    if (uplinkFd < 0) return;
    uint8_t b[8 + 6 * 10];
    for (;;) {
        ssize_t r = recvfrom(uplinkFd, (char *)b, sizeof b, 0, NULL, NULL);
        if (r <= 0) break;
        if (r < 6 || memcmp(b, "UPL1", 4) != 0) continue;
        int n = ((int)b[4] << 8) | b[5];
        if (n < 0 || n > 10 || r < 6 + 6 * n) continue;
        uplinkHeard = true;
        if (n == 0) continue;                      /* a ground saying hello */
        if (uplinkCount >= UPLINK_QMAX) {
            fprintf(stderr, "mdmdev: uplink queue full, buffer dropped\n");
            continue;
        }
        uint16_t *q = uplinkQ[(uplinkHead + uplinkCount) % UPLINK_QMAX];
        memset(q, 0, 31 * sizeof *q);
        for (int i = 0; i < 3 * n; i++) q[i] = (uint16_t)((b[6 + 2 * i] << 8) | b[7 + 2 * i]);
        for (int i = 0; i < n; i++) q[30] |= (uint16_t)(0x8000u >> i);
        uplinkCount++;
    }
}

/* The NSP's answer to one of PASS's reads, or false to leave the zeros. */
static bool nsp_reply(int busID, uint32_t cmd, int n, uint16_t *out) {
    if (CMD_IUA(cmd) != IUA_FF) return false;
    int u = ff_unit(busID);
    uint32_t f = cmd & 0x3ffffu;
    if (f != NSP_DATA_READ && f != NSP1_POWER && f != NSP2_POWER && f != NSP_DISCRETE)
        return false;
    uplink_poll();
    if (!uplinkHeard) return false;
    for (int i = 0; i < n; i++) out[i] = 0;
    if (f == NSP1_POWER) { if (u == 1) out[0] = 0x8000u; return true; }
    if (f == NSP2_POWER || f == NSP_DISCRETE) return true;     /* NSP2 off; no block */
    if (u != 1) return true;                                    /* NSP2: no data */
    if (uplinkCount > 0) {
        uint16_t *q = uplinkQ[uplinkHead];
        out[0] = 0x8000u;                                       /* DATA READY */
        for (int i = 0; i < 31 && 1 + i < n; i++) out[1 + i] = q[i];
        for (int i = 0; i < 10; i++) if (q[30] & (0x8000u >> i)) uplinkWords++;
        uplinkHead = (uplinkHead + 1) % UPLINK_QMAX;
        uplinkCount--;
        uplinkBuffers++;
    }
    return true;
}

void mdmdev_crew_open(int portBase) {
    if (crewOpen) return;              /* one vehicle, one set of sockets */
    crewOpen = true;
    crewPortBase = portBase;
    crewTrace = yagpc_getenv("YAGPC_CREWTRACE") != NULL;
    const char *ifaceStr = yagpc_getenv("NSTS_BUS_IFACE");
    if (ifaceStr == NULL) ifaceStr = "127.0.0.1";
    struct in_addr iface;
    iface.s_addr = inet_addr(ifaceStr);
    if (iface.s_addr == INADDR_NONE) iface.s_addr = htonl(INADDR_ANY);
    for (int k = 1; k <= CREW_NUNIT; k++) {
        int port = portBase + CREW_PORT_OFFSET + k - 1;
        int fd = socket(AF_INET, SOCK_DGRAM, 0);
        if (fd < 0) continue;
        int reuse = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse);
#if defined(SO_REUSEPORT) && !defined(__linux__)
        setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &reuse, sizeof reuse);
#endif
        struct sockaddr_in addr = {0};
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        addr.sin_port = htons((uint16_t)port);
        struct ip_mreq mreq = {0};
        mreq.imr_multiaddr.s_addr = inet_addr("239.255.1.1");
        mreq.imr_interface.s_addr = iface.s_addr;
        if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0 ||
            setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof mreq) < 0) {
            fprintf(stderr, "mdmdev: %s%d crew contacts unavailable (port %d): %s\n",
                    k <= CREW_NFF ? "FF" : "FA", (k - 1) % CREW_NFF + 1, port,
                    strerror(errno));
            close(fd);
            continue;
        }
        int flags = fcntl(fd, F_GETFL, 0);
        fcntl(fd, F_SETFL, flags | O_NONBLOCK);
        setsockopt(fd, IPPROTO_IP, IP_MULTICAST_IF, (const char *)&iface, sizeof iface);
        int loop = 1;
        setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, (const char *)&loop, sizeof loop);
        crewFd[k] = fd;
    }
    uplink_open(portBase, iface);
    lps_open(portBase);
}

static void crew_apply(int k, const uint8_t *buf, int len) {
    if (len < 8) return;
    unsigned op = ((unsigned)buf[0] << 8) | buf[1];
    unsigned type = ((unsigned)buf[2] << 8) | buf[3];
    unsigned card = buf[4], ch = buf[5];
    int cnt = ((int)buf[6] << 8) | buf[7];
    if (type == CREW_TYPE_STU) {
        int st = (k <= CREW_NFF) ? startrk_unit(k) : 0;
        if (op != CREW_OP_VALUE || st == 0 || cnt < 1 || len < 10) return;
        uint16_t w = (uint16_t)(((unsigned)buf[8] << 8) | buf[9]);
        startrk_hardware(st, (w & 0x8000u) != 0, (w & 0x4000u) != 0,
                         vehdyn_enabled() ? vehdyn_state()->t : 0.0);
        crewHeard = true;
        crewMsgs++;
        return;
    }
    if (type == CREW_TYPE_AID) {
        if (op != CREW_OP_VALUE || k > CREW_NFF) return;
        if (cnt > (len - 8) / 2) cnt = (len - 8) / 2;
        for (int i = 0; i < cnt; i++) {
            unsigned c = ch + (unsigned)i;
            if (card >= CREW_NCARD || c >= CREW_AID_NCH) break;
            int16_t v = (int16_t)(((unsigned)buf[8 + 2 * i] << 8) | buf[9 + 2 * i]);
            if (crewTrace && v != crewAid[k][card][c] &&
                (v == 0 || crewAid[k][card][c] == 0))
                fprintf(stderr, "mdmdev: FF%d AID card %u ch %u %s\n", k, card, c,
                        v ? "out of zero" : "back to zero");
            crewAid[k][card][c] = v;
        }
        crewAidHeard = true;
        crewHeard = true;
        crewMsgs++;
        return;
    }
    if (op != CREW_OP_SET && op != CREW_OP_RESET && op != CREW_OP_VALUE) return;
    /* Only INPUT cards are crew contacts: DIL (1) and DIH (2).  The output
     * VALUE records this module sends itself (DOH, 4) come back on the same
     * group, and were being filed here as contacts. */
    if (type != 1 && type != 2) return;
    if (cnt > (len - 8) / 2) cnt = (len - 8) / 2;
    for (int i = 0; i < cnt; i++) {
        unsigned c = ch + (unsigned)i;
        if (card >= CREW_NCARD || c >= CREW_NCHAN) break;
        uint16_t w = (uint16_t)(((unsigned)buf[8 + 2 * i] << 8) | buf[9 + 2 * i]);
        uint16_t was = crewIn[k][card][c];
        uint16_t now = (op == CREW_OP_SET) ? (uint16_t)(was | w)
                     : (op == CREW_OP_RESET) ? (uint16_t)(was & ~w) : w;
        crewIn[k][card][c] = now;
        if (crewTrace && now != was)
            fprintf(stderr, "mdmdev: %s%d card %u ch %u crew contacts %04x -> %04x\n",
                    k <= CREW_NFF ? "FF" : "FA", (k - 1) % CREW_NFF + 1, card, c, was, now);
    }
    crewHeard = true;
    crewMsgs++;
}

/* AND BACK: the forward MDMs' discrete OUTPUTS -- the lamps PASS lights on
 * the crew's panels, the orbital DAP's among them -- go out on the same
 * hardware-side buses as op 4 VALUE records, type 4 (DOH), one per channel,
 * the reference's "MDM mirrors a GPC write to an output card".  Sent when a
 * channel's word changes, and every CREW_REFRESH writes of that unit
 * regardless, for a panel that starts late. */
#define CREW_OP_VALUE_OUT 4
#define CREW_TYPE_DOH 4
#define CREW_REFRESH 64
static uint16_t crewOutSent[CREW_NUNIT + 1][CREW_NCARD][NCHAN];
static bool crewOutEver[CREW_NUNIT + 1][CREW_NCARD][NCHAN];
static long crewOutWrites[CREW_NUNIT + 1];

static void crew_send_out(int k, unsigned card, unsigned ch, uint16_t w) {
    if (crewFd[k] < 0 || crewPortBase <= 0) return;
    uint8_t b[10] = { 0, CREW_OP_VALUE_OUT, 0, CREW_TYPE_DOH, (uint8_t)card, (uint8_t)ch,
                      0, 1, (uint8_t)(w >> 8), (uint8_t)w };
    struct sockaddr_in to = {0};
    to.sin_family = AF_INET;
    to.sin_addr.s_addr = inet_addr("239.255.1.1");
    to.sin_port = htons((uint16_t)(crewPortBase + CREW_PORT_OFFSET + k - 1));
    sendto(crewFd[k], (const char *)b, sizeof b, 0, (struct sockaddr *)&to, sizeof to);
}

static void crew_publish_out(int k, uint32_t cmd, int n) {
    if (!crewOpen || k < 1 || k > CREW_NUNIT) return;
    unsigned card = CMD_CARD(cmd), ch0 = CMD_CHAN(cmd) & 0x0fu;
    bool refresh = (++crewOutWrites[k] % CREW_REFRESH) == 0;
    for (int i = 0; i < n && ch0 + (unsigned)i < NCHAN; i++) {
        unsigned ch = ch0 + (unsigned)i;
        uint16_t w = ffOut[k][card][ch];
        if (refresh || !crewOutEver[k][card][ch] || crewOutSent[k][card][ch] != w) {
            crew_send_out(k, card, ch, w);
            crewOutSent[k][card][ch] = w;
            crewOutEver[k][card][ch] = true;
        }
    }
}

static void crew_poll(void) {
    if (!crewOpen) return;
    uint8_t buf[256];
    for (int k = 1; k <= CREW_NUNIT; k++) {
        if (crewFd[k] < 0) continue;
        for (;;) {
            ssize_t r = recvfrom(crewFd[k], (char *)buf, sizeof buf, 0, NULL, NULL);
            if (r <= 0) break;
            crew_apply(k, buf, (int)r);
        }
    }
}

/* The crew contacts as DSCRT1-13 of FFk: DIH card 4 ch 0-2, DIL card 6 ch
 * 0-1, DIH card 9 ch 0-2, DIH card 12 ch 0-2, DIL card 15 ch 0-1. */
static void crew_dscrt(int k, uint16_t d[13]) {
    static const uint8_t CARD[13] = { 4, 4, 4, 6, 6, 9, 9, 9, 12, 12, 12, 15, 15 };
    static const uint8_t CHAN[13] = { 0, 1, 2, 0, 1, 0, 1, 2, 0, 1, 2, 0, 1 };
    if (k < 1 || k > CREW_NFF) return;
    for (int i = 0; i < 13; i++) d[i] |= crewIn[k][CARD[i]][CHAN[i]];
}

/* The aft contacts as the FA HFE read's discretes, words 18-25 (SEG5
 * DSCRT1-8, CGBIH1.hal 549-560): DIH card 3 ch 0-2, DIL card 5 ch 0, DIH
 * card 8 ch 0, DIH card 11 ch 0-2.  ORed, after the device model's words. */
static void crew_fa_hfe(int k, uint16_t *b, int nb) {
    static const uint8_t CARD[8] = { 3, 3, 3, 5, 8, 11, 11, 11 };
    static const uint8_t CHAN[8] = { 0, 1, 2, 0, 0, 0, 1, 2 };
    if (k < 1 || k > CREW_NFF) return;
    for (int i = 0; i < 8 && 18 + i < nb; i++)
        b[18 + i] |= crewIn[CREW_NFF + k][CARD[i]][CHAN[i]];
}

/* The RHC analogs into an HFE read's words 21-35. */
static void crew_aid_hfe(int k, uint16_t *b, int nb) {
    if (k < 1 || k > CREW_NFF || !crewAidHeard) return;
    for (int c = 0; c < 8 && 21 + c < nb; c++) b[21 + c] = (uint16_t)crewAid[k][1][c];
    for (int c = 0; c < 7 && 29 + c < nb; c++) b[29 + c] = (uint16_t)crewAid[k][14][c];
}

/* ---------------------------------------------------------------------
 * THE OMS ENGINES (vehdyn.c flies them).  What the computers command and
 * what the engines answer -- GSDFIR.hal, GPKOMS.hal, GR5OMS.hal, GRNOMS.hal
 * and the I/O tables CGBOBF/CGBIH1/CGBIM1:
 *
 *   VALVES   the GN2 control-valve coils, a DOH bit 2 (0x4000) on all four
 *            FAs: card 15 ch 1 left, card 7 ch 1 right.  The engine fires
 *            while ANY of its four is set -- either coil opens a valve --
 *            AND its OMS ENG switch on panel C3 is at ARM or ARM/PRESS,
 *            which is hardware: the coils have no power otherwise (SCOM
 *            2.18-8).  The switch is FA DIH card 3 ch 1 bits 7-8 (0x0300),
 *            left on FA1/FA3 and right on FA2/FA4, from the panel; or
 *            YAGPC_OMS_ARMED=1 for a run without one.
 *   GIMBALS  analog outputs, FA AOD card 4 ch 7 (pitch) and 8 (yaw) --
 *            VALUES, not set and reset masks -- in 6400 counts a volt:
 *            counts = deg x C + K, pitch C 3902.08 K -286.72, yaw C
 *            +/-3912.96 (left/right) K -1660.80 (GPKOMS.hal:145-152).  FA1
 *            drives the left primary controller, FA2 left secondary, FA4
 *            right primary, FA3 right secondary; the actuator follows the
 *            controller whose power PASS has selected, FF DOH card 2 ch 2
 *            bits 2-3 on FF1/FF2 (left primary/secondary) and FF4/FF3
 *            (right).
 *   FEEDBACK the actuator positions in every FA's HFE read words 0-1, the
 *            inverse scaling (GPLOMS.hal:63-70): deg = counts x C + K, pitch
 *            C 0.00025625 K 0.0735, yaw C +/-0.00025562 K +/-0.4244.
 *   Pc       chamber pressure on FA3 (left) and FA4 (right): MFE SEG2(11),
 *            which the fail logic compares with 16,000 counts
 *            (CGRS_PC_THRESH), and the 1-word HFE read FIOHI1C5.  20,000
 *            while burning -- 100%, if 0-5 V spans the meter's 0-160%, which
 *            is inferred, not documented -- falling with the thrust through
 *            the tail-off, and 0 otherwise.
 * ------------------------------------------------------------------- */
static int16_t faAod[5][NCARD][NCHAN];
#define PC_FA_READ 0x25A40u     /* FIOHI1C5: card 6 ch 18, 1 word */
#define OMS_PC_BURNING 20000u

static bool oms_armed(int e) {
    static int force = -1;
    if (force < 0) {
        const char *v = yagpc_getenv("YAGPC_OMS_ARMED");
        force = v != NULL && *v != '\0' && strcmp(v, "0") != 0;
    }
    if (force) return true;
    int a = (e == 0) ? 1 : 2, b = (e == 0) ? 3 : 4;
    return ((crewIn[CREW_NFF + a][3][1] | crewIn[CREW_NFF + b][3][1]) & 0x0300u) != 0;
}

static void push_oms(double sharedUs) {
    if (!vehdyn_enabled()) return;
    for (int e = 0; e < 2; e++) {
        int card = (e == 0) ? 15 : 7;
        bool coils = false;
        for (int k = 1; k <= 4; k++) coils = coils || (faOut[k][card][1] & 0x4000u);
        /* the powered controller, primary first, and the FA that drives it */
        int pri = (e == 0) ? 1 : 4, sec = (e == 0) ? 2 : 3, fa = 0;
        if (ffOut[pri][2][2] & 0x6000u) fa = pri;
        else if (ffOut[sec][2][2] & 0x6000u) fa = sec;
        double p = 0.0, y = 0.0;
        if (fa) {
            p = (faAod[fa][4][7] + 286.72) / 3902.08;
            y = (faAod[fa][4][8] + 1660.80) / ((e == 0) ? 3912.96 : -3912.96);
        }
        vehdyn_set_oms(e, coils && oms_armed(e), fa != 0, p, y, sharedUs);
    }
}

/* An actuator's position as its feedback counts. */
static uint16_t oms_feedback(int e, int axis) {
    double d = vehdyn_oms_gimbal(e, axis), c;
    if (axis == 0) c = (d - 0.0735) / 0.00025625;
    else if (e == 0) c = (d - 0.4244) / 0.00025562;
    else c = (d + 0.4244) / -0.00025562;
    c = floor(c + 0.5);
    if (c > 32767.0) c = 32767.0;
    if (c < -32768.0) c = -32768.0;
    return (uint16_t)(int16_t)c;
}

/* The FF discretes that the HFE and MFE reads share (DIH card 4, DIL card 6,
 * DIH card 9, DIH card 12, DIL card 15): HFE words 0-12 and MFE words 8-20. */
static void ff_discretes(int k, uint16_t d[13]) {
    memset(d, 0, 13 * sizeof d[0]);
    /* Manifold isolation valves, all OPEN: bit 8 open, bit 9 closed, fuel in
     * DSCRT1 and oxidizer in DSCRT9 (GR8RCS.hal:180-184); manifold 5 in FF3's
     * bits 12-13 (:200-203).  Neither-open-nor-closed is a power failure and
     * both is a dilemma (:324-356), and a manifold not open makes its jets
     * unavailable (:441-470). */
    d[0] = 0x0100u;
    d[8] = 0x0100u;
    if (k == 3) { d[0] |= 0x0010u; d[8] |= 0x0010u; }
    /* Chamber pressure (DIL card 6 ch 0, GRORCS.hal:138-142) and the jet
     * driver's output (DIH card 9 ch 0, GRRRCS.hal:458-470): both follow the
     * fire command -- a healthy jet makes pressure when it is fired and its
     * driver is on exactly then.  Fail-off is commanded with no pressure for
     * three passes, fail-on is a driver on with no command. */
    d[3] = pc_word(0, k);
    d[5] = ff_jets_b(k);
    /* The IMU discretes (DIL card 15 ch 0) come in here too, for the IMU
     * behind this MDM. */
    if (k <= 3) d[11] = IMU_DSCRT_ALL_GOOD;
    /* The crew's contacts LAST: the words above are assigned, not ORed, so
     * contacts added first were wiped -- DSCRT4's THC and DSCRT6's DAP
     * SELECT / AUTO / INRTL among them -- whenever the device model ran. */
    crew_dscrt(k, d);
}

static void ff_hfe(int k, uint16_t *w, int n) {
    uint16_t d[13], b[36];
    memset(b, 0, sizeof b);
    ff_discretes(k, d);
    memcpy(b, d, sizeof d);
    /* Words 13-20: the four jets' oxidizer then fuel injector temperatures
     * (GRRRCS.hal:184-215). */
    for (int i = 13; i <= 20; i++) b[i] = INJ_WARM;
    crew_aid_hfe(k, b, 36);
    for (int i = 0; i < n; i++) w[i] = (i < 36) ? b[i] : 0;
}

/* The forward propellant system in the MFE analog words 0-7, AIS card 7
 * channels 8-15, which differ by MDM.  Values: tank pressure 250 psi (80 psi
 * a volt), helium 3000 psi (800 a volt), propellant 70 F (32 F a volt),
 * helium tank 70 F ((counts x 250 / 32000) - 75) -- inside every limit the
 * OPS 2 annunciation table puts on them (CGA2MC.hal:763-1068, GAALIM.hal:
 * 231-262, GSUQUA.hal).  Word assignments are INFERRED from those checks. */
#define RCS_TANK_P   20000u    /* 250 psi  */
#define RCS_HE_P     24000u    /* 3000 psi */
#define RCS_PRP_T    14000u    /* 70 F     */
#define RCS_HE_T     18560u    /* 70 F     */

static void ff_mfe(int k, uint16_t *w, int n) {
    uint16_t b[21], d[13];
    memset(b, 0, sizeof b);
    switch (k) {
    case 1: b[0] = RCS_HE_T; b[1] = RCS_HE_P; b[2] = RCS_PRP_T; b[3] = RCS_HE_P;
            b[4] = RCS_TANK_P; b[5] = RCS_TANK_P; break;
    case 2: b[0] = RCS_HE_P; b[1] = RCS_HE_P; b[2] = RCS_HE_T; break;
    case 3: b[0] = RCS_PRP_T; b[1] = RCS_HE_P; b[2] = RCS_HE_T; b[3] = RCS_TANK_P;
            b[4] = RCS_TANK_P; b[5] = RCS_HE_P; break;
    case 4: b[0] = RCS_TANK_P; b[1] = RCS_TANK_P; b[2] = RCS_PRP_T; break;
    }
    ff_discretes(k, d);
    memcpy(b + 8, d, sizeof d);
    for (int i = 0; i < n; i++) w[i] = (i < 21) ? b[i] : 0;
}

/* YAGPC_MDM_TRACE_FA=<k>: every write to aft MDM k's card 10 (the jet fire
 * B words) and every change in what its HFE read reports as chamber pressure
 * and driver output, with the vehicle's time -- for ledger #272, a jet PASS
 * failed off. */
static int trace_fa(void) {
    static int k = -1;
    if (k < 0) {
        const char *e = yagpc_getenv("YAGPC_MDM_TRACE_FA");
        k = (e != NULL) ? atoi(e) : 0;
    }
    return k;
}

#define SRB_PC_AMBIENT 950u    /* about 14.7 psia */

static void fa_hfe(int k, uint16_t *w, int n) {
    uint16_t b[54];
    memset(b, 0, sizeof b);
    /* Words 2-17, injector temperatures (GRRRCS.hal:302-357).  On FA3 and
     * FA4 words 8-9 and 16-17 are not RCS channels and stay zero. */
    for (int i = 2; i <= 17; i++)
        if (k <= 2 || !(i == 8 || i == 9 || i == 16 || i == 17)) b[i] = INJ_WARM;
    /* Manifolds OPEN: right 1-4 in word 20 and left 1-4 in word 25, the top
     * nibble fuel-open, fuel-closed, oxidizer-open, oxidizer-closed = 1010;
     * manifold 5 in FA2's word 20 (right) and FA1's word 25 (left), bits 13
     * and 14 open (GR8RCS.hal:186-257). */
    b[20] = 0xA000u;
    b[25] = 0xA000u;
    if (k == 2) b[20] |= 0x000Cu;
    if (k == 1) b[25] |= 0x000Cu;
    /* Chamber pressure and driver output follow the fire command, as
     * forward; bits 9-11 of the Pc word are the rate gyros' spin-motor
     * rotation detectors, which must read running (GQRORB.hal:139-270). */
    b[21] = (uint16_t)(pc_word(1, k) | 0x00E0u);
    b[22] = fa_jets_b(k);
    if (trace_fa() == k) {
        static uint16_t last = 0xFFFFu;
        if (b[21] != last)
            fprintf(stderr, "mdmtrace: t=%.4f FA%d HFE read Pc/drv %04x\n",
                    vehdyn_state()->t, k, (unsigned)b[21]);
        last = b[21];
    }
    /* the OMS gimbal positions, words 0-1: FA1/FA2 the left engine's
     * controllers, FA3/FA4 the right's */
    if (vehdyn_enabled()) {
        int e = (k <= 2) ? 0 : 1;
        b[0] = oms_feedback(e, 0);
        b[1] = oms_feedback(e, 1);
    }
    /* SEGMENT 7, words 28-35 (CGBIH1.hal:528-541): the SRBs' chamber
     * pressures (32 right, 34 left; FA1-3) and the SRB ignition PIC
     * capacitor voltages (33 right, 35 left; FA1 cap A, FA2 cap B).
     *   - PIC: GSRRSL checks them >= 28032 counts (35.7 V, "438 x 64") from
     *     T-12 s, after it has armed SRM ignition at T-15 s; charged here
     *     once a MEC has that ARM, and not before.
     *   - SRB Pc: psia = counts x 0.0313211 + K, K about -9.5 to -15.5
     *     (CGCCOM.hal:279-290); zero counts read -15 psia, which the SRB
     *     separation cue takes for burn-out.  On the pad, ambient. */
    if (k <= 2) {
        uint16_t pic = (mec_armed(MEC_SRM_IGN) && mec_fired_at(MEC_SRM_IGN) < 0.0) ? 30000u : 0u;
        b[33] = pic;
        b[35] = pic;
    }
    if (k <= 3) {
        b[32] = SRB_PC_AMBIENT;
        b[34] = SRB_PC_AMBIENT;
    }
    crew_fa_hfe(k, b, 54);
    for (int i = 0; i < n; i++) w[i] = (i < 54) ? b[i] : 0;
}

/* The aft propellant systems in the MFE analog words: SEG1 (5) then SEG2
 * (29), SEG2(n) at word 4+n.  Assignments INFERRED from the annunciation
 * checks, as forward.  The OMS words are held inside their limits too. */
static void fa_mfe(int k, uint16_t *w, int n) {
    uint16_t b[34];
    memset(b, 0, sizeof b);
#define SEG2(nn) b[4 + (nn)]
    if (k <= 2) {
        SEG2(4) = RCS_TANK_P; SEG2(23) = RCS_TANK_P;
        SEG2(2) = RCS_HE_P;   SEG2(21) = RCS_HE_P;
        SEG2(3) = RCS_PRP_T;  SEG2(22) = RCS_PRP_T;
        SEG2(20) = RCS_HE_T;
        SEG2(11) = 20000u; SEG2(7) = 20000u;    /* OMS tank pressures */
        SEG2(16) = 23000u; SEG2(14) = 16000u;
    } else {
        SEG2(4) = RCS_TANK_P; SEG2(6) = RCS_TANK_P;
        SEG2(2) = RCS_HE_P;   SEG2(5) = RCS_HE_P;
        SEG2(3) = RCS_PRP_T;
        SEG2(1) = RCS_HE_T;
        SEG2(10) = 16000u;                       /* OMS */
        SEG2(11) = (uint16_t)(OMS_PC_BURNING * vehdyn_oms_thrust(k == 3 ? 0 : 1));
    }
#undef SEG2
    for (int i = 0; i < n; i++) w[i] = (i < 34) ? b[i] : 0;
}

/* ---------------------------------------------------------------------
 * THE GPS RECEIVERS, one behind each of FF1-3 on card 11 channel 2: a
 * 32-word read every 0.96 s (FIOGPSRD, X'26C5F') and two 32-word writes every
 * 0.16 s (FIOGPSWT, X'22C5F') -- BCEEQU.asm:618-620, FIOGPSPG.asm.  The
 * formats are the GPS SOP's (GPBGPS.hal) and the Nav Aids SOP FSSR's
 * (STS83-0014, 4.17.1.1.2 and 4.17.6.1); HAL bit 1 is the most significant.
 *
 * WHAT THE COMPUTERS SEND.  Message 1 (header AAAA) always, then Message 3
 * (BBBB, attitude and air data) in NAV or Message 2 (CCCC, lever arms) in
 * INIT.  Its word 2 commands the mode in bits 1-2 -- NAV 10, INIT 01, TEST 00
 * -- and asks, in bits 3, 9 and 16, for an announced reset, an init-state
 * set and a filter restart; the receiver answers each in its own status.
 * Nothing here waits: the receiver is in the commanded mode at once, its
 * almanac downloaded and its satellites already tracked -- a receiver that
 * has been on for a while, not one acquiring from cold.
 *
 * WHAT IT ANSWERS (VEHDYN only: it reports the truth state, so without one
 * there is nothing to say, and the read stays zeros -- mode blank on SPEC 55,
 * which nothing treats as a failure):
 *   w1     header: DDDD TEST, EEEE INIT, FFFF NAV (GPBGPS.hal:515)
 *   w2-3   NAV_MODE_WORD: valid, mode, almanac, UTC valid; the completions;
 *          the mode's complement in w3 bits 15-16, which must match
 *   w4     GPS week, full count
 *   w5-7   seconds of week, 48 bits, 1e-8 s
 *   w8-13  WGS-84 Earth-fixed position, 32-bit, 1/16 ft
 *   w14-19 Earth-relative velocity in that frame, 32-bit, 1/512 ft/s
 *   w20    FOM 1 (0-25 m) in bits 12-15, GDOP 2 in bits 8-11
 *   w22,24,26,28,29  five channels tracking (bits 5-7 101), PRN in 11-16
 *   w31    TFOM 1
 *
 * TIME.  PASS turns week and seconds into its GMT as
 * week x 604800 + sow - 11 (leap seconds, GPBS_LEAP_SEC_CORR) - 504403200
 * (CGNS_T_GPS_OFFSET_SECS, 1995-12-31 0h in GPS seconds) - the uplinkable
 * adjustments (zero) -- GPBGPS.hal:926-932 -- so this is the inverse, from
 * vehdyn_gmt(): the same arithmetic, not the real GPS-UTC relation, so that
 * the time PASS recovers is its own GMT exactly.  The solution is valid
 * GPS_LAG_S before the read: PASS takes a state only within 0.48 s of its MFE
 * time tag (:950-957) and only once an IMU sample is newer (GPJGPS.hal), so
 * it must be recent but in the past -- and every read's time is new, or PASS
 * sees the data as static (:935).
 *
 * FRAME.  PASS converts back with M50 = (Rz(lambda) A)^T ECEF and
 * V = M v_ecef + omega x R (GLJRCV.hal:520-531, GVMVRE.hal), with A and
 * lambda the GLWRNP/GNFEAR Earth that vehdyn.c gives the physics -- so the
 * position is phys_inertial_to_earth() applied to the truth, and the
 * velocity has the Earth's turning taken out, exactly. */
#define GPS_READ  0x26C5Fu    /* FIOGPSRD: mode 9, card 11 ch 2, 32 words */
#define GPS_WRITE 0x22C5Fu    /* FIOGPSWT: mode 8, card 11 ch 2, 32 words */
#define GPS_LAG_S 0.05
#define GPS_OFFSET_S (504403200.0 + 11.0)

typedef struct {
    bool haveCmd;
    unsigned mode;            /* 2 NAV, 1 INIT, 0 TEST: word 2 bits 1-2 */
    uint16_t done;            /* w3 completions owed: 8000 reset, 4000 init, 1000 restart */
    long reads, writes;
} Gps;
static Gps gps[4];            /* [1..3] */

static void gps_write(int u, const uint16_t *w, int n) {
    Gps *g = &gps[u];
    g->writes++;
    if (n < 2 || w[0] != 0xAAAAu) return;   /* Message 2 or 3: nothing to act on */
    g->haveCmd = true;
    g->mode = (w[1] >> 14) & 3u;
    g->done = 0;
    if (w[1] & 0x2000u) g->done |= 0x8000u;  /* announced reset -> reset complete */
    if (w[1] & 0x0080u) g->done |= 0x4000u;  /* init state set -> init states complete */
    if (w[1] & 0x0001u) g->done |= 0x1000u;  /* filter restart -> restart complete */
}

static void put32(uint16_t *w, double x) {
    double c = floor(x + 0.5);
    if (c > 2147483647.0) c = 2147483647.0;
    if (c < -2147483648.0) c = -2147483648.0;
    uint32_t u = (uint32_t)(int32_t)c;
    w[0] = (uint16_t)(u >> 16); w[1] = (uint16_t)u;
}

/* The words of a read; false when there is nothing to report. */
static bool gps_words(int u, uint16_t w[32]) {
    Gps *g = &gps[u];
    memset(w, 0, 32 * sizeof *w);
    if (!vehdyn_enabled() || !g->haveCmd) return false;
    const PhysState *s = vehdyn_state();
    double tv = s->t - GPS_LAG_S, gmt = vehdyn_gmt(tv);
    double r[3], v[3];
    if (gmt < 0.0 || !vehdyn_state_at(tv, r, v)) return false;
    static const uint16_t HDR[4] = { 0xDDDDu, 0xEEEEu, 0xFFFFu, 0xDDDDu };
    static const uint16_t COMPL[4] = { 0x0003u, 0x0002u, 0x0001u, 0x0003u };
    unsigned mode = (g->mode == 3u) ? 0u : g->mode;
    w[0] = HDR[mode];
    w[1] = (uint16_t)((mode << 13) | 0x0200u | 0x0080u);   /* mode, almanac, UTC valid */
    if (mode == 2u) w[1] |= 0x8000u;                        /* nav data valid */
    w[2] = (uint16_t)(g->done | COMPL[mode]);
    double total = gmt + GPS_OFFSET_S;
    double week = floor(total / 604800.0), sow = total - week * 604800.0;
    w[3] = (uint16_t)week;
    uint64_t ticks = (uint64_t)llround(sow * 1e8);
    w[4] = (uint16_t)(ticks >> 32); w[5] = (uint16_t)(ticks >> 16); w[6] = (uint16_t)ticks;
    if (mode == 1u) { w[7] = 0; w[8] = (uint16_t)week; return true; }   /* INIT */
    if (mode != 2u) return true;                                        /* TEST: no faults */
    double M[3][3], re[3], ve[3], rate = phys_earth_rate();
    phys_inertial_to_earth(tv, M);
    for (int i = 0; i < 3; i++) {
        re[i] = M[i][0] * r[0] + M[i][1] * r[1] + M[i][2] * r[2];
        ve[i] = M[i][0] * v[0] + M[i][1] * v[1] + M[i][2] * v[2];
    }
    ve[0] += rate * re[1];                   /* less the Earth's turning: omega z x r */
    ve[1] -= rate * re[0];
    for (int i = 0; i < 3; i++) {
        put32(&w[7 + 2 * i], re[i] / FT_M * 16.0);
        put32(&w[13 + 2 * i], ve[i] / FT_M * 512.0);
    }
    w[19] = (uint16_t)((2u << 5) | (1u << 1));             /* GDOP 2, FOM 1 */
    static const uint8_t PRN[5] = { 3, 7, 11, 19, 24 };
    static const int CHW[5] = { 21, 23, 25, 27, 28 };
    for (int c = 0; c < 5; c++) w[CHW[c]] = (uint16_t)(0x0A00u | PRN[c]);
    w[30] = 0x0001u;                                        /* TFOM 1 */
    return true;
}

/* ---------------------------------------------------------------------
 * The reads this module answers.
 * ------------------------------------------------------------------- */
static long ffReads, faReads, ffWrites, faWrites;

/* THE FIRE COMMANDS TO THE VEHICLE'S DYNAMICS, whenever a B word changes. */
static void push_fire(double sharedUs) {
    if (!vehdyn_enabled()) return;
    uint16_t ff[5] = { 0 }, fa[5] = { 0 };
    for (int k = 1; k <= 4; k++) { ff[k] = ff_jets_b(k); fa[k] = fa_jets_b(k); }
    vehdyn_set_fire_words(ff, fa, sharedUs);
}

/* ---------------------------------------------------------------------
 * THE FLIGHT INSTRUMENTS' DATA, to the displays.  Every 40 ms the HFE writes
 * each of FC1-4 (buses 20-23) the MEDS transfer (four messages to IUA 15)
 * and the DDU messages -- ADI to DDUs 1-3 (IUAs 6, 9, 15), HSI, AVVI and AMI
 * to DDUs 1 and 2 (nsts-sim-gpc lru/ddu/dduConf.coffee, from the OI30
 * listing's FIOHFEPG).  An IDP hears all four buses; its MDU's DATA BUS
 * edgekey picks the one the PFD follows.  These buses are modelled here,
 * not on the network, so each message goes to MEDS2 as one datagram on
 * port base + FC_INSTR_OFFSET, halfwords big-endian:
 *     FC_INSTR_MAGIC, FC bus 1-4, command high 8 bits, command low 16 bits,
 *     word count, the words
 * Sent when its words change, and at least every FC_INSTR_REFRESH_US so a
 * display can tell a quiet bus (its instruments go invalid) from a steady
 * one.  Only for a run wired to a panel -- the one that has displays.
 * ------------------------------------------------------------------- */
#define FC_INSTR_OFFSET 97
#define FC_INSTR_MAGIC 0xFC01u
#define FC_INSTR_REFRESH_US 500000.0
#define FC_INSTR_SLOTS 16

typedef struct {
    uint32_t cmd;
    int n;
    uint16_t w[32];
    double sentUs;
    long sentCalls;
} FcSlot;
static FcSlot fcLast[5][FC_INSTR_SLOTS];
static long fcCalls, fcSent;

static void fc_output(int busID, uint32_t cmd, const uint16_t *words, int n, double sharedUs) {
    int fc = busID - 19;
    if (fc < 1 || fc > 4 || n <= 0 || n > 32 || !crewOpen || crewFd[1] < 0) return;
    fcCalls++;
    /* a slot per message: IUA and select bits */
    int slot = -1;
    for (int i = 0; i < FC_INSTR_SLOTS; i++) {
        if (fcLast[fc][i].cmd == cmd) { slot = i; break; }
        if (fcLast[fc][i].cmd == 0u && slot < 0) slot = i;
    }
    if (slot < 0) return;
    FcSlot *e = &fcLast[fc][slot];
    bool same = e->cmd == cmd && e->n == n && memcmp(e->w, words, (size_t)n * sizeof *words) == 0;
    bool due = (sharedUs >= 0.0) ? (sharedUs - e->sentUs >= FC_INSTR_REFRESH_US)
                                 : (fcCalls - e->sentCalls >= 50);
    if (same && !due && e->cmd != 0u) return;
    e->cmd = cmd; e->n = n;
    memcpy(e->w, words, (size_t)n * sizeof *words);
    e->sentUs = sharedUs; e->sentCalls = fcCalls;
    uint8_t b[2 * (5 + 32)];
    uint16_t h[5] = { FC_INSTR_MAGIC, (uint16_t)fc, (uint16_t)((cmd >> 16) & 0xffu),
                      (uint16_t)(cmd & 0xffffu), (uint16_t)n };
    int k = 0;
    for (int i = 0; i < 5; i++) { b[k++] = (uint8_t)(h[i] >> 8); b[k++] = (uint8_t)h[i]; }
    for (int i = 0; i < n; i++) { b[k++] = (uint8_t)(words[i] >> 8); b[k++] = (uint8_t)words[i]; }
    struct sockaddr_in to = {0};
    to.sin_family = AF_INET;
    to.sin_addr.s_addr = inet_addr("239.255.1.1");
    to.sin_port = htons((uint16_t)(crewPortBase + FC_INSTR_OFFSET));
    sendto(crewFd[1], (const char *)b, (size_t)k, 0, (struct sockaddr *)&to, sizeof to);
    fcSent++;
}

/* ---------------------------------------------------------------------
 * THE TRUTH, for a debugging instrument (discretePanel/truthball.py): the
 * vehicle dynamics' own state -- not anything the flight software sees --
 * so that what PASS shows on its ADI can be set beside what the vehicle is
 * really doing.  One datagram per TRUTH_PERIOD_S of vehicle time on port
 * base + TRUTH_OFFSET: "TRU1", then big-endian IEEE doubles -- vehicle time
 * (s), PASS GMT (s), the attitude quaternion body -> M50 (w x y z), body
 * rates (rad/s), M50 position (m) and velocity (m/s).  Only with the
 * dynamics on and a panel wired. */
#define TRUTH_OFFSET 98
#define TRUTH_PERIOD_S 0.05

static void put_be_double(uint8_t *b, double v) {
    uint64_t u;
    memcpy(&u, &v, sizeof u);
    for (int i = 0; i < 8; i++) b[i] = (uint8_t)(u >> (56 - 8 * i));
}

static void truth_publish(void) {
    static double next = -1.0;
    if (!crewOpen || crewFd[1] < 0 || !vehdyn_enabled()) return;
    const PhysState *st = vehdyn_state();
    if (st->t < next && st->t > next - 10.0) return;
    next = st->t + TRUTH_PERIOD_S;
    double v[2 + 4 + 3 + 3 + 3];
    int n = 0;
    v[n++] = st->t;
    v[n++] = vehdyn_gmt(st->t);
    for (int i = 0; i < 4; i++) v[n++] = st->q[i];
    for (int i = 0; i < 3; i++) v[n++] = st->w[i];
    for (int i = 0; i < 3; i++) v[n++] = st->r[i];
    for (int i = 0; i < 3; i++) v[n++] = st->v[i];
    uint8_t b[4 + 8 * 15];
    memcpy(b, "TRU1", 4);
    for (int i = 0; i < n; i++) put_be_double(b + 4 + 8 * i, v[i]);
    struct sockaddr_in to = {0};
    to.sin_family = AF_INET;
    to.sin_addr.s_addr = inet_addr("239.255.1.1");
    to.sin_port = htons((uint16_t)(crewPortBase + TRUTH_OFFSET));
    sendto(crewFd[1], (const char *)b, (size_t)(4 + 8 * n), 0, (struct sockaddr *)&to, sizeof to);
}

/* ---------------------------------------------------------------------
 * THE DOWNLIST, to the ground.  Every 40 ms each GPC writes its downlist
 * frame to the PCM master unit on its own IP bus (BCE 24): 32-word "write
 * toggle buffer" commands, then an end-of-message command (FIOWCDAT,
 * SSSRC/FIOPRMPG.asm:177-195).  The command word is the PCMMU's: address
 * bits 23-21 (011 the PCMMU; anything else, the bit bucket that non-prime
 * members of a redundant set are pointed at -- FCMBUSCM.asm:645-701),
 * operation bits 20-17 (0101 write toggle buffer, 111x end of message), a
 * 12-bit field whose top three bits name the toggle buffer and low nine
 * the word offset, and the word count less one (JSC-18611 SB 29; the
 * values nsts-sim-gpc measured, lru/pcmmu/pcmmuConf.coffee).  PASS needs no
 * answer to either.
 *
 * Watched here, not answered: the router hands every bus-24 word to
 * mdmdev_downlist_tap, which assembles each computer's frame and, at the
 * end of message, sends it to the ground as one datagram on port base +
 * DOWNLINK_OFFSET -- "DNL1", the GPC, the toggle buffer, the word count
 * (halfwords), the simulated time in microseconds (an IEEE double), then
 * the words as PASS wrote them, big-endian.  The frame describes itself:
 * EB90, then frame number and format ID (CDWDOWNL.hal, DCDDOW.hal). */
#define DOWNLINK_OFFSET 88
#define DL_MAX 128

static struct {
    uint16_t w[DL_MAX];
    int at, left;         /* the write in progress */
    int tb;
    int hi;               /* highest word written this frame, +1 */
} dl[6];
static long dlFrames;

void mdmdev_downlist_tap(int gpcId, int svc, uint32_t word, double sharedUs) {
    if (!crewOpen || crewFd[1] < 0 || gpcId < 1 || gpcId > 5) return;
    if (svc == 1) {                                  /* GPC_SVC_XMIT_CMD */
        uint32_t c = word & 0xffffffu;
        dl[gpcId].left = 0;
        if (((c >> 21) & 7u) != 3u) return;         /* not the PCMMU */
        unsigned op = (c >> 17) & 0xfu, field = (c >> 5) & 0xfffu;
        int tb = (int)(field >> 9), off = (int)(field & 0x1ffu);
        if (op == 0x5u) {                            /* write toggle buffer */
            if (off == 0) dl[gpcId].hi = 0;
            dl[gpcId].tb = tb;
            dl[gpcId].at = off;
            dl[gpcId].left = (int)(c & 0x1fu) + 1;
        } else if ((op & 0xeu) == 0xeu) {            /* end of message */
            int n = off + 1;
            if (n > dl[gpcId].hi) n = dl[gpcId].hi;
            if (n <= 0 || n > DL_MAX) return;
            uint8_t b[4 + 6 + 8 + 2 * DL_MAX];
            memcpy(b, "DNL1", 4);
            uint16_t h[3] = { (uint16_t)gpcId, (uint16_t)tb, (uint16_t)n };
            for (int i = 0; i < 3; i++) { b[4 + 2 * i] = (uint8_t)(h[i] >> 8); b[5 + 2 * i] = (uint8_t)h[i]; }
            put_be_double(b + 10, sharedUs);
            for (int i = 0; i < n; i++) {
                b[18 + 2 * i] = (uint8_t)(dl[gpcId].w[i] >> 8);
                b[19 + 2 * i] = (uint8_t)dl[gpcId].w[i];
            }
            struct sockaddr_in to = {0};
            to.sin_family = AF_INET;
            to.sin_addr.s_addr = inet_addr("239.255.1.1");
            to.sin_port = htons((uint16_t)(crewPortBase + DOWNLINK_OFFSET));
            sendto(crewFd[1], (const char *)b, (size_t)(18 + 2 * n), 0,
                   (struct sockaddr *)&to, sizeof to);
            dlFrames++;
        }
    } else if (svc == 0 && dl[gpcId].left > 0) {    /* GPC_SVC_XMIT_WORD */
        if (dl[gpcId].at >= 0 && dl[gpcId].at < DL_MAX) {
            dl[gpcId].w[dl[gpcId].at] = (uint16_t)(word & 0xffffu);
            if (dl[gpcId].at + 1 > dl[gpcId].hi) dl[gpcId].hi = dl[gpcId].at + 1;
        }
        dl[gpcId].at++;
        dl[gpcId].left--;
    }
}

bool mdmdev_capturing(void) { return mdmdev_enabled() || crewOpen; }

/* Whether the flight instruments' messages are relayed (fc_output): on
 * unless YAGPC_FC_RELAY=0, so its cost can be measured by switching it off. */
bool mdmdev_fc_relay(void) {
    static int on = -1;
    if (on < 0) {
        const char *e = yagpc_getenv("YAGPC_FC_RELAY");
        on = !(e != NULL && strcmp(e, "0") == 0);
    }
    return crewOpen && on;
}

void mdmdev_output(int busID, uint32_t cmd, const uint16_t *words, int n,
                   double sharedUs) {
    if (n <= 0) return;
    if (lps_owns(busID, cmd)) { lps_write(cmd, words, n); return; }
    if (eiu_engine(busID, cmd) && eiu_is_command(cmd)) {
        eiu_command(busID, cmd, words, n, sharedUs / 1e6);
        return;
    }
    if (mec_owns(busID, cmd)) { mec_command(busID, cmd, words, n, sharedUs / 1e6); return; }
    pc_clock(sharedUs);
    if ((cmd & 0x40000u) && CMD_IUA(cmd) != IUA_FF && CMD_IUA(cmd) != IUA_FA) {
        fc_output(busID, cmd, words, n, sharedUs);       /* DDU and MEDS */
        return;
    }
    if (!mdmdev_enabled()) {
        /* No device model, but a panel: record the forward MDMs' discrete
         * outputs and send them to it -- its lamps -- and nothing else. */
        if (crewOpen && CMD_IUA(cmd) == IUA_FF && ff_unit(busID) > 0 &&
            CMD_MODE(cmd) == 8u) {
            discrete_write(ffOut, ffOutSeen, ff_unit(busID), cmd, words, n);
            crew_publish_out(ff_unit(busID), cmd, n);
        }
        return;
    }
    unsigned iua = CMD_IUA(cmd);
    uint32_t f = cmd & 0x3ffffu;
    if (iua == IUA_FF && ff_unit(busID) > 0) {
        int u = ff_unit(busID);
        ffWrites++;
        if (f == GPS_WRITE && u <= 3) { gps_write(u, words, n); return; }
        if (f == STU_WRITE && startrk_unit(u)) {
            startrk_command(startrk_unit(u), words[0], vehdyn_enabled() ? vehdyn_state()->t
                                                                         : sharedUs / 1e6);
            return;
        }
        if (f == IMU_WRITE && u <= 3) {
            /* the slew running until now ran under the OLD word 2 */
            if (vehdyn_enabled()) imu_torque(u, words[0], vehdyn_state()->t);
            imu[u].cmd1 = words[0];
            imu[u].cmd2 = (n > 1) ? words[1] : imu[u].cmd2;
            imu[u].haveCmd = true;
            imu[u].writes++;
            return;
        }
        if (CMD_MODE(cmd) == 8u) {
            discrete_write(ffOut, ffOutSeen, u, cmd, words, n);
            crew_publish_out(u, cmd, n);
            if (CMD_CARD(cmd) == 13u) { pc_track(); push_fire(sharedUs); }
            if (CMD_CARD(cmd) == 2u) push_oms(sharedUs);
        }
    } else if (iua == IUA_FA && fa_unit(busID) > 0) {
        faWrites++;
        if (CMD_MODE(cmd) == 8u && CMD_CARD(cmd) == 4u) {      /* AOD: values */
            unsigned ch = CMD_CHAN(cmd) & 0x0fu;
            for (int i = 0; i < n && ch + (unsigned)i < NCHAN; i++)
                faAod[fa_unit(busID)][4][ch + (unsigned)i] = (int16_t)words[i];
            push_oms(sharedUs);
        } else if (CMD_MODE(cmd) == 8u) {
            if (CMD_CARD(cmd) == 10u && trace_fa() == fa_unit(busID)) {
                fprintf(stderr, "mdmtrace: t=%.4f FA%d write card 10 ch %02x:", vehdyn_state()->t,
                        fa_unit(busID), (unsigned)CMD_CHAN(cmd));
                for (int i = 0; i < n; i++) fprintf(stderr, " %04x", (unsigned)words[i]);
                fprintf(stderr, "\n");
            }
            discrete_write(faOut, NULL, fa_unit(busID), cmd, words, n);
            if (CMD_CARD(cmd) == 10u) { pc_track(); push_fire(sharedUs); }
            if (CMD_CARD(cmd) == 7u || CMD_CARD(cmd) == 15u) push_oms(sharedUs);
        }
    }
}

bool mdmdev_reply(int busID, uint32_t cmd, int n, uint16_t *out, double sharedUs) {
    if (n <= 0) return false;
    if (lps_owns(busID, cmd)) return lps_reply(cmd, n, out);
    if (eiu_engine(busID, cmd)) return eiu_reply(busID, cmd, n, out, sharedUs / 1e6);
    pc_clock(sharedUs);
    crew_poll();
    if (nsp_reply(busID, cmd, n, out)) return true;
    if (!mdmdev_enabled()) {
        /* No device model: zeros, as ever, plus whatever crew contacts the
         * panel is driving -- and only once it has driven some. */
        if (!crewHeard) return false;
        uint32_t f = cmd & 0x3ffffu;
        if (CMD_IUA(cmd) == IUA_FA) {
            int u = fa_unit(busID);
            if (u < 1 || f != HFE_FA_READ) return false;
            uint16_t b[54] = {0};
            crew_fa_hfe(u, b, 54);
            for (int i = 0; i < n; i++) out[i] = (i < 54) ? b[i] : 0;
            return true;
        }
        if (CMD_IUA(cmd) != IUA_FF) return false;
        int u = ff_unit(busID);
        int at = (f == HFE_FF_READ) ? 0 : (f == MFE_FF_READ) ? 8 : -1;
        if (u < 1 || at < 0) return false;
        uint16_t d[13] = {0};
        crew_dscrt(u, d);
        for (int i = 0; i < n; i++) out[i] = (i >= at && i < at + 13) ? d[i - at] : 0;
        if (at == 0) {
            uint16_t b[36] = {0};
            crew_aid_hfe(u, b, 36);
            for (int i = 21; i < n && i < 36; i++) out[i] = b[i];
        }
        return true;
    }
    if (vehdyn_enabled()) {
        vehdyn_advance(sharedUs);                      /* time passes for the vehicle */
        truth_publish();
    }
    unsigned iua = CMD_IUA(cmd);
    uint32_t f = cmd & 0x3ffffu;
    if (iua == IUA_FF) {
        int u = ff_unit(busID);
        if (u >= 1 && u <= 3 && f == IMU_READ) {
            imu_read(u, out, n);
            ffReads++;
            return true;
        }
        if (u >= 1 && u <= 3 && f == GPS_READ) {
            uint16_t w[32];
            gps[u].reads++;
            if (!gps_words(u, w)) return false;
            for (int i = 0; i < n; i++) out[i] = (i < 32) ? w[i] : 0;
            ffReads++;
            return true;
        }
        if (f == STU_READ && startrk_unit(u) && n >= 3) {
            uint16_t sw[3];
            startrk_read(startrk_unit(u), sw, vehdyn_enabled() ? vehdyn_state()->t : sharedUs / 1e6);
            for (int i = 0; i < n; i++) out[i] = (i < 3) ? sw[i] : 0;
            ffReads++;
            return true;
        }
        if (u >= 1 && u <= 3 && f == IMU_DSCRT) {
            for (int i = 0; i < n; i++) out[i] = (i == 0) ? IMU_DSCRT_ALL_GOOD : 0;
            ffReads++;
            return true;
        }
        if (u >= 1 && f == HFE_FF_READ) { ff_hfe(u, out, n); ffReads++; return true; }
        if (u >= 1 && f == MFE_FF_READ) { ff_mfe(u, out, n); ffReads++; return true; }
    } else if (iua == IUA_FA) {
        int u = fa_unit(busID);
        if (u >= 1 && f == HFE_FA_READ) { fa_hfe(u, out, n); faReads++; return true; }
        if (u >= 1 && f == MFE_FA_READ) { fa_mfe(u, out, n); faReads++; return true; }
        if (u >= 3 && f == PC_FA_READ) {
            out[0] = (uint16_t)(OMS_PC_BURNING * vehdyn_oms_thrust(u == 3 ? 0 : 1));
            for (int i = 1; i < n; i++) out[i] = 0;
            faReads++;
            return true;
        }
    }
    return false;
}

/* ---------------------------------------------------------------------
 * IN A SESSION CAPTURE: vehdyn.json beside the computers' own files -- the
 * truth state (vehdyn_save) and what the devices remember between reads:
 * each IMU's command words and its accelerometers' running counts, each GPS
 * receiver's mode, and every discrete and analog output the computers have
 * written.  Without it a restored run started the truth vehicle over in its
 * default orbit while the flight software carried on in the captured one,
 * and the IMU velocity counters restarted at zero under a flight software
 * that differences them.
 * ------------------------------------------------------------------- */
static void put_list(FILE *f, const char *key, const double *b, int n, bool more) {
    fprintf(f, "  \"%s\": [", key);
    for (int i = 0; i < n; i++) fprintf(f, "%s%.17g", i ? "," : "", b[i]);
    fprintf(f, "]%s\n", more ? "," : "");
}

bool mdmdev_dump(const char *dir) {
    if (!mdmdev_enabled() || dir == NULL) return false;
    char path[600];
    snprintf(path, sizeof path, "%s/vehdyn.json", dir);
    FILE *f = fopen(path, "w");
    if (f == NULL) { fprintf(stderr, "mdmdev: cannot write %s\n", path); return false; }
    fprintf(f, "{\n");
    double vb[256];
    int nv = vehdyn_save(vb, 256);
    put_list(f, "vehdyn", vb, nv, true);
    double ib[4 * 13];
    int ni = 0;
    for (int k = 1; k <= 3; k++) {
        ib[ni++] = imu[k].cmd1; ib[ni++] = imu[k].cmd2; ib[ni++] = imu[k].haveCmd;
        for (int i = 0; i < 3; i++) ib[ni++] = imuAcc[k].dvFt[i];
        for (int i = 0; i < 3; i++) ib[ni++] = imuAcc[k].carry[i];
        for (int i = 0; i < 3; i++) ib[ni++] = imuAcc[k].count[i];
        ib[ni++] = imuAcc[k].started;
    }
    put_list(f, "imu", ib, ni, true);
    double tb[3];
    for (int k = 1; k <= 3; k++) tb[k - 1] = imuAcc[k].t;
    put_list(f, "imuTime", tb, 3, true);
    double pb[3 * 11];
    int np = 0;
    for (int k = 1; k <= 3; k++) {
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++) pb[np++] = plat[k].P[i][j];
        pb[np++] = plat[k].started;
        pb[np++] = plat[k].t;
    }
    put_list(f, "imuPlatform", pb, np, true);
    {
        double sb[512];
        int ns = startrk_save(sb, 512);
        put_list(f, "starTrackers", sb, ns < 512 ? ns : 512, true);
        ns = eiu_save(sb, 512);
        put_list(f, "engines", sb, ns < 512 ? ns : 512, true);
        ns = mec_save(sb, 512);
        put_list(f, "mecs", sb, ns < 512 ? ns : 512, true);
    }
    double gb[9];
    for (int k = 1; k <= 3; k++) {
        gb[3 * (k - 1)] = gps[k].haveCmd; gb[3 * (k - 1) + 1] = gps[k].mode;
        gb[3 * (k - 1) + 2] = gps[k].done;
    }
    put_list(f, "gps", gb, 9, true);
    static double ob[3 * 5 * NCARD * NCHAN];
    int no = 0;
    for (int u = 0; u < 5; u++)
        for (int c = 0; c < NCARD; c++)
            for (int h = 0; h < NCHAN; h++) {
                ob[no++] = ffOut[u][c][h]; ob[no++] = faOut[u][c][h]; ob[no++] = faAod[u][c][h];
            }
    put_list(f, "outputs", ob, no, false);
    fprintf(f, "}\n");
    bool ok = fclose(f) == 0;
    if (ok) fprintf(stderr, "mdmdev: vehicle dynamics and device state captured\n");
    return ok;
}

static int get_list(const JsonValue *root, const char *key, double *b, int max) {
    const JsonValue *a = json_obj_get(root, key);
    int n = json_arr_count(a);
    for (int i = 0; i < n && i < max; i++) b[i] = json_as_number(json_arr_get(a, i), 0.0);
    return n < max ? n : max;
}

bool mdmdev_load(const char *dir) {
    if (!mdmdev_enabled() || dir == NULL) return false;
    char path[600];
    snprintf(path, sizeof path, "%s/vehdyn.json", dir);
    FILE *f = fopen(path, "rb");
    if (f == NULL) {
        fprintf(stderr, "mdmdev: no vehdyn.json in this capture -- the vehicle "
                        "starts over in its default orbit\n");
        return false;
    }
    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *text = (char *)malloc((size_t)len + 1);
    if (text == NULL || fread(text, 1, (size_t)len, f) != (size_t)len) {
        free(text); fclose(f); return false;
    }
    text[len] = '\0';
    fclose(f);
    JsonValue *root = json_parse(text);
    free(text);
    if (root == NULL) { fprintf(stderr, "mdmdev: %s is not JSON\n", path); return false; }
    double vb[256];
    int nv = get_list(root, "vehdyn", vb, 256);
    double tCap = vehdyn_load(vb, nv);
    if (tCap < 0.0) {
        fprintf(stderr, "mdmdev: vehdyn.json's vehicle record is unreadable -- default orbit\n");
        json_free(root);
        return false;
    }
    double ib[4 * 13], tb[3], gb[9];
    static double ob[3 * 5 * NCARD * NCHAN];
    int ni = get_list(root, "imu", ib, 39), nt = get_list(root, "imuTime", tb, 3);
    int ng = get_list(root, "gps", gb, 9), no = get_list(root, "outputs", ob, 3 * 5 * NCARD * NCHAN);
    if (ni == 39 && nt == 3)
        for (int k = 1, i = 0; k <= 3; k++) {
            imu[k].cmd1 = (uint16_t)ib[i++]; imu[k].cmd2 = (uint16_t)ib[i++];
            imu[k].haveCmd = ib[i++] != 0.0;
            for (int j = 0; j < 3; j++) imuAcc[k].dvFt[j] = ib[i++];
            for (int j = 0; j < 3; j++) imuAcc[k].carry[j] = ib[i++];
            for (int j = 0; j < 3; j++) imuAcc[k].count[j] = (uint16_t)ib[i++];
            imuAcc[k].started = ib[i++] != 0.0;
            imuAcc[k].t = tb[k - 1] - tCap;              /* rebased with the vehicle */
        }
    /* THE PLATFORMS' ORIENTATIONS: a capture made before they could move
     * has none, and its platforms are where they always were, at M50. */
    double pb[3 * 11];
    if (get_list(root, "imuPlatform", pb, 33) == 33)
        for (int k = 1, i = 0; k <= 3; k++) {
            for (int r = 0; r < 3; r++)
                for (int c = 0; c < 3; c++) plat[k].P[r][c] = pb[i++];
            plat[k].started = pb[i++] != 0.0;
            plat[k].t = pb[i++] - tCap;                 /* rebased with the vehicle */
        }
    {
        double sb[512];
        int ns = get_list(root, "starTrackers", sb, 512);
        if (ns > 0) startrk_load(sb, ns, tCap);
        ns = get_list(root, "engines", sb, 512);
        if (ns > 0) eiu_load(sb, ns, tCap);
        ns = get_list(root, "mecs", sb, 512);
        if (ns > 0) mec_load(sb, ns, tCap);
    }
    if (ng == 9)
        for (int k = 1; k <= 3; k++) {
            gps[k].haveCmd = gb[3 * (k - 1)] != 0.0; gps[k].mode = (unsigned)gb[3 * (k - 1) + 1];
            gps[k].done = (uint16_t)gb[3 * (k - 1) + 2];
        }
    if (no == 3 * 5 * NCARD * NCHAN)
        for (int u = 0, i = 0; u < 5; u++)
            for (int c = 0; c < NCARD; c++)
                for (int h = 0; h < NCHAN; h++) {
                    ffOut[u][c][h] = (uint16_t)ob[i++]; faOut[u][c][h] = (uint16_t)ob[i++];
                    faAod[u][c][h] = (int16_t)ob[i++];
                }
    json_free(root);
    fprintf(stderr, "mdmdev: vehicle dynamics and device state restored (captured at t=%.3f s)\n", tCap);
    return true;
}

/* The angle, degrees, through which IMU n's cluster has turned from M50. */
static double plat_angle_deg(int n) {
    const double (*P)[3] = (const double (*)[3])plat[n].P;
    double c = (P[0][0] + P[1][1] + P[2][2] - 1.0) / 2.0;
    if (c > 1.0) c = 1.0;
    if (c < -1.0) c = -1.0;
    return acos(c) * 180.0 / 3.14159265358979323846;
}

void mdmdev_test_platform(int n, double P[3][3]) {
    if (n >= 1 && n <= 3) memcpy(P, plat[n].P, sizeof plat[n].P);
}

void mdmdev_report(void) {
    startrk_report();
    lps_report();
    eiu_report();
    mec_report();
    for (int k = 1; k <= 3; k++)
        if (plat[k].started)
            fprintf(stderr, "mdmdev: IMU%d platform %.4f deg from M50; %ld torque "
                            "pulse(s), %.2f s slewing\n", k, plat_angle_deg(k),
                    plat[k].pulses, plat[k].slewSec);
    if (dlFrames > 0)
        fprintf(stderr, "mdmdev: %ld downlist frame(s) sent to the ground\n", dlFrames);
    if (uplinkHeard)
        fprintf(stderr, "mdmdev: NSP1 uplink -- %ld buffer(s), %ld command word(s) delivered, "
                        "%d still queued\n", uplinkBuffers, uplinkWords, uplinkCount);
    if (fcCalls > 0)
        fprintf(stderr, "mdmdev: %ld flight-instrument message(s) heard on FC1-4, %ld sent "
                        "to the displays\n", fcCalls, fcSent);
    if (!mdmdev_enabled()) return;
    vehdyn_report();
    fprintf(stderr, "mdmdev: healthy vehicle at rest -- %ld forward and %ld aft MDM "
                    "read(s) answered, %ld and %ld write(s) taken; IMU reads %ld/%ld/%ld, "
                    "commands %ld/%ld/%ld; GPS reads %ld/%ld/%ld, writes %ld/%ld/%ld\n",
            ffReads, faReads, ffWrites, faWrites,
            imu[1].reads, imu[2].reads, imu[3].reads,
            imu[1].writes, imu[2].writes, imu[3].writes,
            gps[1].reads, gps[2].reads, gps[3].reads, gps[1].writes, gps[2].writes, gps[3].writes);
}
