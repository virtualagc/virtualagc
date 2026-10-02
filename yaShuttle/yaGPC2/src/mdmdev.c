#define _DEFAULT_SOURCE /* struct ip_mreq under -std=c11's strict mode */
#include "mdmdev.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <sys/socket.h>
#include <unistd.h>

#include "compat.h"
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
#define CREW_AID_NCH 8
static int16_t crewAid[CREW_NFF + 1][CREW_NCARD][CREW_AID_NCH];
static bool crewAidHeard;
static int crewFd[CREW_NUNIT + 1] = { -1, -1, -1, -1, -1, -1, -1, -1, -1 };
static bool crewOpen, crewHeard, crewTrace;
static int crewPortBase;
static long crewMsgs;

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
}

static void crew_apply(int k, const uint8_t *buf, int len) {
    if (len < 8) return;
    unsigned op = ((unsigned)buf[0] << 8) | buf[1];
    unsigned type = ((unsigned)buf[2] << 8) | buf[3];
    unsigned card = buf[4], ch = buf[5];
    int cnt = ((int)buf[6] << 8) | buf[7];
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
 *            is inferred, not documented -- and 0 otherwise.
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
    d[3] = ff_jets_b(k);
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
    /* the OMS gimbal positions, words 0-1: FA1/FA2 the left engine's
     * controllers, FA3/FA4 the right's */
    if (vehdyn_enabled()) {
        int e = (k <= 2) ? 0 : 1;
        b[0] = oms_feedback(e, 0);
        b[1] = oms_feedback(e, 1);
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
        if (vehdyn_oms_burning(k == 3 ? 0 : 1)) SEG2(11) = OMS_PC_BURNING;
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

bool mdmdev_capturing(void) { return mdmdev_enabled() || crewOpen; }

void mdmdev_output(int busID, uint32_t cmd, const uint16_t *words, int n,
                   double sharedUs) {
    if (n <= 0) return;
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
        if (f == IMU_WRITE && u <= 3) {
            imu[u].cmd1 = words[0];
            imu[u].cmd2 = (n > 1) ? words[1] : imu[u].cmd2;
            imu[u].haveCmd = true;
            imu[u].writes++;
            return;
        }
        if (CMD_MODE(cmd) == 8u) {
            discrete_write(ffOut, ffOutSeen, u, cmd, words, n);
            crew_publish_out(u, cmd, n);
            if (CMD_CARD(cmd) == 13u) push_fire(sharedUs);
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
            discrete_write(faOut, NULL, fa_unit(busID), cmd, words, n);
            if (CMD_CARD(cmd) == 10u) push_fire(sharedUs);
            if (CMD_CARD(cmd) == 7u || CMD_CARD(cmd) == 15u) push_oms(sharedUs);
        }
    }
}

bool mdmdev_reply(int busID, uint32_t cmd, int n, uint16_t *out, double sharedUs) {
    if (n <= 0) return false;
    crew_poll();
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
        if (u >= 1 && u <= 3 && f == GPS_READ) {
            uint16_t w[32];
            gps[u].reads++;
            if (!gps_words(u, w)) return false;
            for (int i = 0; i < n; i++) out[i] = (i < 32) ? w[i] : 0;
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
            out[0] = vehdyn_oms_burning(u == 3 ? 0 : 1) ? OMS_PC_BURNING : 0;
            for (int i = 1; i < n; i++) out[i] = 0;
            faReads++;
            return true;
        }
    }
    return false;
}

void mdmdev_report(void) {
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
