#include "mdmdev.h"

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>

#include "envcache.h"
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
 * THE PLATFORM IS HELD FIXED.  In orbit PASS torques each platform at
 * -GYREST to cancel that IMU's expected gyro drift (GMKGYO, GO2ORB.hal:629);
 * a modelled drift of +GYREST would make the two cancel, and leaving out
 * both is the same thing.  Alignment slews and torquing are not yet applied.
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

static void imu_dynamic(int n, uint16_t w[14]) {
    const PhysState *s = vehdyn_state();
    double R[3][3], M1[3][3];
    qmat(s->q, R);
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            M1[i][j] = R[i][0] * TNBBODY[0][j] + R[i][1] * TNBBODY[1][j] + R[i][2] * TNBBODY[2][j];
    double sp = -M1[2][0];
    if (sp > 1.0) sp = 1.0;
    if (sp < -1.0) sp = -1.0;
    const double D = 180.0 / 3.14159265358979323846;
    double P = asin(sp) * D;
    double OR = atan2(M1[2][1], M1[2][2]) * D;
    double AZ = atan2(M1[1][0], M1[0][0]) * D;
    w[2] = 0;                                      /* inner roll 8X: null */
    resolver_words(OR, &w[3], &w[4]);
    resolver_words(P, &w[5], &w[6]);
    resolver_words(AZ, &w[7], &w[8]);
    /* the velocity counters */
    ImuAcc *a = &imuAcc[n];
    double dv[3];
    vehdyn_sensed_dv(dv);
    double dt = a->started ? s->t - a->t : 0.0;
    if (dt < 0.0) dt = 0.0;
    double k = (imu[n].cmd2 & IMU_CMD2_HIGAIN) ? IMU_FT_PER_PULSE / 10.0 : IMU_FT_PER_PULSE;
    for (int i = 0; i < 3; i++) {
        double ft = dv[i] / FT_M;
        if (!a->started) { a->dvFt[i] = ft; continue; }
        double weight = (1.0 + ACC_SF_PPM[n - 1][i] * 1e-6) * k;
        double bias = ACC_BIAS_UG[n - 1][i] * 1e-6 * G0_FTS2;
        double pulses = (ft - a->dvFt[i] + bias * dt) / weight + a->carry[i];
        double whole = floor(pulses);
        a->carry[i] = pulses - whole;
        a->dvFt[i] = ft;
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

/* 2.5 V, as the A/D reports it: 6400 counts a volt (the leak limits are
 * written 6400 x volts, GRRRCS.hal:142-149).  The only check on an injector
 * temperature is a LOW one -- a leak -- at 0.625 V oxidizer and 0.425 V fuel
 * for the primaries and up to 1.3 V for a vernier in orbit; there is no high
 * limit and no rate check.  2.5 V clears every one. */
#define INJ_WARM 16000u

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
    d[3] = ff_jets_b(k);
    d[5] = ff_jets_b(k);
    /* The IMU discretes (DIL card 15 ch 0) come in here too, for the IMU
     * behind this MDM. */
    if (k <= 3) d[11] = IMU_DSCRT_ALL_GOOD;
}

static void ff_hfe(int k, uint16_t *w, int n) {
    uint16_t d[13], b[36];
    memset(b, 0, sizeof b);
    ff_discretes(k, d);
    memcpy(b, d, sizeof d);
    /* Words 13-20: the four jets' oxidizer then fuel injector temperatures
     * (GRRRCS.hal:184-215). */
    for (int i = 13; i <= 20; i++) b[i] = INJ_WARM;
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
    b[21] = (uint16_t)(fa_jets_b(k) | 0x00E0u);
    b[22] = fa_jets_b(k);
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
        SEG2(10) = 16000u;                       /* OMS; SEG2(11), Pc, stays 0 */
    }
#undef SEG2
    for (int i = 0; i < n; i++) w[i] = (i < 34) ? b[i] : 0;
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

void mdmdev_output(int busID, uint32_t cmd, const uint16_t *words, int n,
                   double sharedUs) {
    if (!mdmdev_enabled() || n <= 0) return;
    unsigned iua = CMD_IUA(cmd);
    uint32_t f = cmd & 0x3ffffu;
    if (iua == IUA_FF && ff_unit(busID) > 0) {
        int u = ff_unit(busID);
        ffWrites++;
        if (f == IMU_WRITE && u <= 3) {
            imu[u].cmd1 = words[0];
            imu[u].cmd2 = (n > 1) ? words[1] : imu[u].cmd2;
            imu[u].haveCmd = true;
            imu[u].writes++;
            return;
        }
        if (CMD_MODE(cmd) == 8u) {
            discrete_write(ffOut, ffOutSeen, u, cmd, words, n);
            if (CMD_CARD(cmd) == 13u) push_fire(sharedUs);
        }
    } else if (iua == IUA_FA && fa_unit(busID) > 0) {
        faWrites++;
        if (CMD_MODE(cmd) == 8u) {
            discrete_write(faOut, NULL, fa_unit(busID), cmd, words, n);
            if (CMD_CARD(cmd) == 10u) push_fire(sharedUs);
        }
    }
}

bool mdmdev_reply(int busID, uint32_t cmd, int n, uint16_t *out, double sharedUs) {
    if (!mdmdev_enabled() || n <= 0) return false;
    if (vehdyn_enabled()) vehdyn_advance(sharedUs);   /* time passes for the vehicle */
    unsigned iua = CMD_IUA(cmd);
    uint32_t f = cmd & 0x3ffffu;
    if (iua == IUA_FF) {
        int u = ff_unit(busID);
        if (u >= 1 && u <= 3 && f == IMU_READ) {
            imu_read(u, out, n);
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
    }
    return false;
}

void mdmdev_report(void) {
    if (!mdmdev_enabled()) return;
    vehdyn_report();
    fprintf(stderr, "mdmdev: healthy vehicle at rest -- %ld forward and %ld aft MDM "
                    "read(s) answered, %ld and %ld write(s) taken; IMU reads %ld/%ld/%ld, "
                    "commands %ld/%ld/%ld\n",
            ffReads, faReads, ffWrites, faWrites,
            imu[1].reads, imu[2].reads, imu[3].reads,
            imu[1].writes, imu[2].writes, imu[3].writes);
}
