/* THE DEVICES BEHIND THE FORWARD AND AFT MDMs (mdmdev.c), THROUGH THE BUS.
 *
 * Driven through mtumodel's service calls exactly as a BCE drives them -- a
 * command, then its data words or a receive -- so what is checked is what a
 * computer would read, not only what mdmdev.c computes.  A single machine
 * (reader 0, no shared clock), which is the path every word takes when it is
 * not paced.
 *
 * What it pins down: the RCS words a healthy vehicle at rest reports (every
 * manifold open, every injector warm), that a jet's chamber pressure and
 * driver output follow the fire command the computers wrote, and that the
 * IMU reports GOOD, the gain it was commanded and both command words back.
 */
/* setenv, which -std=c11 alone does not declare. */
#define _POSIX_C_SOURCE 200809L
#define _DARWIN_C_SOURCE   /* macOS: IP_MULTICAST_* hidden under _POSIX_C_SOURCE alone */

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

#include "../src/mtumodel.h"
#include "../src/busword.h"
#include "../src/vehdyn.h"
#include "../src/mdmdev.h"
#include "../src/startrk.h"
#include "../src/startable.h"
#include <math.h>

static struct MtuModel *m;
static int failures, checks;

static void check(bool ok, const char *what) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [mdmdev/%s]\n", what);
}

static void call(GpcServiceNumber svc, int bus, uint32_t word, GpcServiceOutput *out) {
    GpcServiceInput in;
    memset(&in, 0, sizeof in);
    memset(out, 0, sizeof *out);
    in.busID = bus;
    in.in.word = word;
    mtumodel_service_as(m, 0, svc, &in, out);
}

/* A read: the command with `n` words armed, then every word it brings. */
static int read_words(int bus, uint32_t cmd, int n, uint16_t *w) {
    GpcServiceOutput out;
    mtumodel_set_armed_words(m, n);
    call(GPC_SVC_XMIT_CMD, bus, cmd, &out);
    int got = 0;
    while (got < n) {
        call(GPC_SVC_RECV_POLL, bus, 0, &out);
        if (!out.out.poll.available) break;
        call(GPC_SVC_RECV_WORD, bus, 0, &out);
        if (!out.out.recv.available) break;
        if (out.out.recv.word & YAGPC_BUSWORD_CMD_SYNC) continue;
        w[got++] = (uint16_t)out.out.recv.word;
    }
    return got;
}

/* A write: the command, no receive armed, then its data words. */
static void write_words(int bus, uint32_t cmd, const uint16_t *w, int n) {
    GpcServiceOutput out;
    mtumodel_set_armed_words(m, -1);
    call(GPC_SVC_XMIT_CMD, bus, cmd, &out);
    for (int i = 0; i < n; i++) call(GPC_SVC_XMIT_WORD, bus, w[i], &out);
}

#define FA(c) ((12u << 19) | (c))
#define FF(c) ((10u << 19) | (c))

/* A crew contact, as panelO6 drives it: one datagram on FFk's hardware-side
 * bus (CREW_BASE + 100 + k - 1), halfwords op, type, card<<8|channel, count,
 * word -- big-endian. */
#define CREW_BASE 39400
static void crew_send(int k, int op, int card, int ch, uint16_t word) {
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    struct in_addr lo; lo.s_addr = inet_addr("127.0.0.1");
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_IF, (const char *)&lo, sizeof lo);
    int on = 1;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, (const char *)&on, sizeof on);
    uint8_t b[10] = { 0, (uint8_t)op, 0, 2, (uint8_t)card, (uint8_t)ch, 0, 1,
                      (uint8_t)(word >> 8), (uint8_t)word };
    struct sockaddr_in to = {0};
    to.sin_family = AF_INET;
    to.sin_addr.s_addr = inet_addr("239.255.1.1");
    to.sin_port = htons((uint16_t)(CREW_BASE + 100 + k - 1));
    sendto(fd, (const char *)b, sizeof b, 0, (struct sockaddr *)&to, sizeof to);
    close(fd);
}

/* THE STAR TRACKERS' GEOMETRY, as the flight software applies it: tracker
 * words -> line of sight in the tracker's axes (GY8DAT.hal:194-197, 431-434)
 * -> nav base (CGYS_TNBST^T) -> body (TNBBODY) -> M50 (the truth attitude). */
static const double T_NBST[3][3][3] = {
    { { 0 } },
    { { -0.00651344657, 0.999492586, -0.0311769098 }, { 0.989126801, 0.00185892172, -0.147052646 },
      { -0.146920085, -0.0314957425, -0.98863709 } },
    { { -0.965746284, -0.184594095, 0.182370245 }, { -0.186074317, 0.00279755401, -0.982531488 },
      { 0.180859327, -0.982810736, -0.0370500423 } },
};
static const double T_NBBODY[3][3] = { { 0.98293535, 0.0, -0.18395135 }, { 0, 1, 0 },
                                       { 0.18395135, 0.0, 0.98293535 } };
static void st_qmat(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}
/* PASS's decode of a tracker's words to an M50 line of sight. */
static void st_decode(int k, const uint16_t w[3], double u[3]) {
    const double LSB = 0.0025390625 * 3.14159265358979323846 / 180.0;
    double H = (double)((int16_t)(w[1] & 0xFFF0u) >> 4) * LSB;
    double V = (double)((int16_t)(w[2] & 0xFFF0u) >> 4) * LSB;
    double D = sqrt(tan(H) * tan(H) + tan(V) * tan(V) + 1.0);
    double st[3] = { -tan(V) / D, tan(H) / D, 1.0 / D }, nb[3], b[3], R[3][3];
    for (int i = 0; i < 3; i++) nb[i] = T_NBST[k][0][i] * st[0] + T_NBST[k][1][i] * st[1] + T_NBST[k][2][i] * st[2];
    for (int i = 0; i < 3; i++) b[i] = T_NBBODY[i][0] * nb[0] + T_NBBODY[i][1] * nb[1] + T_NBBODY[i][2] * nb[2];
    st_qmat(vehdyn_state()->q, R);
    for (int i = 0; i < 3; i++) u[i] = R[i][0] * b[0] + R[i][1] * b[1] + R[i][2] * b[2];
}
/* Point tracker k's boresight at the M50 direction d (the shortest turn). */
static void st_point(int k, const double d[3]) {
    double b[3];
    for (int i = 0; i < 3; i++)
        b[i] = T_NBBODY[i][0] * T_NBST[k][2][0] + T_NBBODY[i][1] * T_NBST[k][2][1] + T_NBBODY[i][2] * T_NBST[k][2][2];
    double ax[3] = { b[1] * d[2] - b[2] * d[1], b[2] * d[0] - b[0] * d[2], b[0] * d[1] - b[1] * d[0] };
    double sn = sqrt(ax[0] * ax[0] + ax[1] * ax[1] + ax[2] * ax[2]);
    double cs = b[0] * d[0] + b[1] * d[1] + b[2] * d[2];
    double a = atan2(sn, cs), q[4] = { cos(a / 2), 0, 0, 0 }, zero[3] = { 0, 0, 0 };
    for (int i = 0; i < 3; i++) q[i + 1] = (sn > 0 ? ax[i] / sn : 0) * sin(a / 2);
    vehdyn_set_attitude(q, zero);
}
static double st_ang(const double a[3], const double b[3]) {
    double c = (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]) /
               sqrt((a[0] * a[0] + a[1] * a[1] + a[2] * a[2]) * (b[0] * b[0] + b[1] * b[1] + b[2] * b[2]));
    return acos(c > 1 ? 1 : c < -1 ? -1 : c) * 180.0 / 3.14159265358979323846;
}

int main(void) {
    setenv("YAGPC_MDM_DEVICES", "1", 1);
    /* Before anything reads it: the switch is cached on first use. */
    setenv("YAGPC_VEHDYN", "1", 1);
    m = mtumodel_create();
    uint16_t w[64];

    /* AFT, AT REST: FA1 (bus 14), FIOHI1C1. */
    check(read_words(14, FA(0x0836Eu), 54, w) == 54, "fa1 hfe length");
    /* a primary (word 2, R1A fuel) at 2.5 V; a vernier (word 17, L5D
     * oxidizer) at 3.3 V, above STS-134's flown 2.6 V (16640) leak limit */
    check(w[2] == 16000 && w[17] == 21120 && w[17] > 16640, "fa1 injector temperatures warm");
    /* the ET's low-level sensors read WET with the tank full (PASS disables
     * any already dry when it arms them) */
    check((w[18] & 0x0040u) == 0 && (w[23] & 0x0080u) == 0, "fa1 ET low-level sensors wet");
    check(w[20] == 0xA000u, "fa1 right manifolds 1-4 open");
    /* the manifold bits only: the same words carry the interconnect valves'
     * indications (valvemodel.c), checked next */
    check((w[25] & 0xF00Fu) == 0xA00Cu, "fa1 left manifolds 1-4 and 5 open");
    check((w[25] & 0x0F00u) == 0x0A00u, "fa1 L RCS TK ISOL 1/2 reads OPEN (interconnect valves at rest)");
    check((w[24] & 0x03C0u) == 0x0140u && (w[19] & 0x00F0u) == 0x0050u,
          "fa1 L and R OMS XFEED A read CLOSED");
    check(w[21] == 0x00E0u, "fa1 no chamber pressure, rate gyros spinning");
    check(w[22] == 0x0000u, "fa1 no jet driver on");
    check(read_words(15, FA(0x0836Eu), 54, w) == 54 && (w[20] & 0xF00Fu) == 0xA00Cu,
          "fa2 right manifold 5 open");

    /* FIRE L1A (FA1 bit 1) and L5L (bit 8): B is card 10 channel 0, the
     * reset word then the set word, channel 1 alongside.  The driver follows
     * the command at once; chamber pressure lags it both ways -- up after
     * 20 ms, down 40 ms after the off command -- on the shared clock
     * (ledger #272: GRORCS reads Pc 27 ms after an even pass's write). */
    {
        uint16_t reset[2] = { 0x7EFFu, 0xFFFFu }, set[2] = { 0x8100u, 0x0000u };
        mdmdev_test_clock_us(1000.0);
        write_words(14, FA(0x22801u), reset, 2);
        write_words(14, FA(0x22A01u), set, 2);
        mdmdev_test_clock_us(1000.0 + 10000.0);
        read_words(14, FA(0x0836Eu), 54, w);
        check(w[21] == 0x00E0u, "fa1 chamber pressure not up 10 ms after the fire command");
        check(w[22] == 0x8100u, "fa1 jet drivers follow the fire command");
        mdmdev_test_clock_us(1000.0 + 25000.0);
        read_words(14, FA(0x0836Eu), 54, w);
        check(w[21] == 0x81E0u, "fa1 chamber pressure up 25 ms after the fire command");
        uint16_t off[2] = { 0x0000u, 0x0000u }, none[2] = { 0xFFFFu, 0xFFFFu };
        mdmdev_test_clock_us(100000.0);
        write_words(14, FA(0x22801u), none, 2);
        write_words(14, FA(0x22A01u), off, 2);
        mdmdev_test_clock_us(100000.0 + 27000.0);
        read_words(14, FA(0x0836Eu), 54, w);
        check(w[21] == 0x81E0u && w[22] == 0,
              "fa1 drivers off at once, chamber pressure still up 27 ms later");
        mdmdev_test_clock_us(100000.0 + 67000.0);
        read_words(14, FA(0x0836Eu), 54, w);
        check(w[21] == 0x00E0u && w[22] == 0, "fa1 jets off again 67 ms later");
    }

    /* FORWARD, AT REST: FF3 (bus 22) carries manifold 5 and IMU 3. */
    check(read_words(22, FF(0x082E8u), 36, w) == 36, "ff3 hfe length");
    /* (and in DSCRT9, 0x0006: the nose gear's no-WOW #1 and its door up-locked
     * -- the gear stowed, gear_discretes) */
    check(w[0] == 0x0110u && w[8] == (0x0110u | 0x0006u), "ff3 manifolds 3 and 5 open");
    check(w[11] == 0xFC00u, "ff3 imu discretes good");
    /* word 13 a primary (F3F oxidizer), word 20 a vernier (F5R fuel) */
    check(w[13] == 16000 && w[20] == 21120 && w[20] > 16640, "ff3 injector temperatures warm");
    check(read_words(23, FF(0x082E8u), 36, w) == 36 && w[11] == 0,
          "ff4 has no imu");
    /* The MFE read: eight analog words, then the same thirteen discretes. */
    check(read_words(20, FF(0x082C5u), 21, w) == 21, "ff1 mfe length");
    check(w[8] == 0x0100u && w[16] == 0x0100u && w[19] == 0xFC00u,
          "ff1 mfe discretes match the hfe");

    /* FIRE F1F (FF1 bit 1): card 13 channel 0. */
    {
        uint16_t reset = 0x7FFFu, set = 0x8040u;     /* with IMU 1 operate */
        mdmdev_test_clock_us(200000.0);
        write_words(20, FF(0x23400u), &reset, 1);
        write_words(20, FF(0x23600u), &set, 1);
        mdmdev_test_clock_us(200000.0 + 30000.0);
        read_words(20, FF(0x082E8u), 36, w);
        /* DSCRT6 also carries main wheel 3's no-WOW sensor and its
         * null-fail (0x0003, the gear stowed and airborne) */
        check(w[3] == 0x8000u && w[5] == (0x8000u | 0x0003u),
              "ff1 chamber pressure and driver follow F1F only");
    }
    
    /* IMU 2 (bus 21): command words in, BITE and echoes out. */
    {
        uint16_t cmd[2] = { 0x1234u, 0x8000u };      /* high gain */
        write_words(21, FF(0x20C01u), cmd, 2);
        check(read_words(21, FF(0x24C0Du), 14, w) == 14, "imu2 length");
        check(w[0] == 0x8010u, "imu2 GOOD, and the high gain it was told");
        check(w[12] == 0x1234u && w[13] == 0x8000u, "imu2 echoes both command words");
        check(read_words(21, FF(0x27C00u), 1, w) == 1 && w[0] == 0xFC00u,
              "imu2 discretes good");
    }

    /* THE PLATFORM MOVES AS PASS COMMANDS IT (IMU 1, bus 20).  Each check
     * compares C(cluster after <- cluster before) = P0^T P1 with the rotation
     * that should have happened; for small angles its (3,2), (1,3) and (2,1)
     * elements are the X, Y and Z angles. */
    {
        const double KTN = -0.5 * 0.48481361e-5, D = 3.14159265358979323846 / 180.0;
        double P0[3][3], P1[3][3], Q[3][3];
        #define REL() do { mdmdev_test_platform(1, P1); \
            for (int i_ = 0; i_ < 3; i_++) for (int k_ = 0; k_ < 3; k_++) \
                Q[i_][k_] = P0[0][i_] * P1[0][k_] + P0[1][i_] * P1[1][k_] + P0[2][i_] * P1[2][k_]; } while (0)
        vehdyn_reset(0.0);
        uint16_t c[2] = { 0x0000u, 0x0000u };
        write_words(20, FF(0x20C01u), c, 2);                /* starts the platform */
        mdmdev_test_platform(1, P0);
        check(P0[0][0] == 1.0 && P0[1][1] == 1.0 && P0[2][2] == 1.0, "imu1 platform starts at M50");

        /* TORQUE: X +15, Y -16, Z +1 pulses, no time passing */
        c[0] = (uint16_t)((15u << 11) | (0x10u << 6) | (1u << 1));
        write_words(20, FF(0x20C01u), c, 2);
        REL();
        double ex = fabs(Q[2][1] - 15 * KTN) + fabs(Q[0][2] - (-16) * KTN) + fabs(Q[1][0] - 1 * KTN);
        if (ex > 1e-8) printf("torque: %.4g %.4g %.4g rad\n", Q[2][1], Q[0][2], Q[1][0]);
        check(ex < 1e-8, "imu1 torque pulses turn the cluster -0.5 arcsec each, per axis");

        /* SLEW: SX+ for one second turns the cluster -1.2 deg about X */
        mdmdev_test_platform(1, P0);
        c[0] = 0; c[1] = 0x4000u;
        write_words(20, FF(0x20C01u), c, 2);
        vehdyn_advance(1e6);
        c[1] = 0x0000u;
        write_words(20, FF(0x20C01u), c, 2);                /* stops it */
        REL();
        double ax = atan2(Q[2][1], Q[1][1]) / D;
        if (fabs(ax + 1.2) > 1e-3) printf("slew: %.6f deg about X\n", ax);
        check(fabs(ax + 1.2) < 1e-3, "imu1 SX+ slews the cluster -1.2 deg/s about X");

        /* DRIFT, CANCELLED THE WAY PASS CANCELS IT: every 0.16 s, GMFGYO's
         * pulses for a rate of -GYREST (GMKGYO), the residual carried.  Five
         * minutes of it must leave the platform within a few pulses of where
         * it began; uncompensated, it would have gone 1e-3 rad. */
        {
            const double GY1[3] = { -1.31239e-6, 3.04123e-6, -1.96834e-6 };
            double res[3] = { 0, 0, 0 };
            mdmdev_test_platform(1, P0);
            for (int cyc = 0; cyc < 1875; cyc++) {
                int p[3];
                for (int i = 0; i < 3; i++) {
                    double want = -GY1[i] * 0.16 / KTN + res[i];
                    p[i] = (int)lround(want);
                    if (p[i] > 15) p[i] = 15;
                    if (p[i] < -16) p[i] = -16;
                    res[i] = want - p[i];
                }
                c[0] = (uint16_t)(((p[0] & 0x1f) << 11) | ((p[1] & 0x1f) << 6) | ((p[2] & 0x1f) << 1));
                c[1] = 0;
                vehdyn_advance(1e6 + (cyc + 1) * 0.16e6);   /* a time, not a step */
                write_words(20, FF(0x20C01u), c, 2);
            }
            REL();
            double e = fabs(Q[2][1]) + fabs(Q[0][2]) + fabs(Q[1][0]);
            if (e > 4 * fabs(KTN)) printf("drift left %.3g rad after 300 s\n", e);
            check(e < 4 * fabs(KTN), "imu1 gyro drift is cancelled by PASS's -GYREST torquing");
        }
        #undef REL
    }

    /* THE STAR TRACKERS: -Z on FF1 (bus 20), -Y on FF3 (bus 22).  A star
     * well away from the Earth, the Sun and the Moon, for the -Z tracker. */
    {
        /* a date on which the test orbit's start is in sunlight: the Sun
         * moves round M50 in a year, and the vehicle starts where it starts */
        const PhysState *ps = vehdyn_state();
        double nadir[3], sun[3];
        for (int d = 0; d < 12; d++) {
            vehdyn_set_gmt_zero(1790000000.0 + d * 30.0 * 86400.0);
            vehdyn_reset(0.0);
            double rn = sqrt(ps->r[0] * ps->r[0] + ps->r[1] * ps->r[1] + ps->r[2] * ps->r[2]);
            for (int i = 0; i < 3; i++) nadir[i] = -ps->r[i] / rn;
            startrk_test_sun(0.0, sun);
            if (st_ang(sun, nadir) > 100.0) break;
        }
        check(sun[0] != 0 || sun[1] != 0, "startrk: the Sun is known once the clock is");
        int pick = -1;
        for (int i = 0; i < STAR_TABLE_N && pick < 0; i++)
            if (STAR_TABLE[i].id != 11 && st_ang(STAR_TABLE[i].u, nadir) > 110.0 &&
                st_ang(STAR_TABLE[i].u, sun) > 60.0 && STAR_TABLE[i].mag < 2.0)
                pick = i;
        check(pick >= 0, "startrk: a star to point at");
        if (pick >= 0) {
            st_point(1, STAR_TABLE[pick].u);
            /* FULL-FIELD SCAN, the power-on default: some star within 12 s */
            uint16_t cmd0[1] = { 0x0000u };
            write_words(20, FF(0x20C40u), cmd0, 1);
            double t = 0.0;
            int got = 0;
            for (int n = 0; n < 80 && !got; n++) {
                t += 0.16;
                vehdyn_advance(t * 1e6);
                read_words(20, FF(0x24C42u), 3, w);
                if (w[0] & 0x0400u) got = startrk_test_locked(1);
            }
            check(got > 0, "startrk: -Z full-field scan acquires a catalog star");
            check((w[0] & 0xA200u) == 0xA200u && (w[2] & 0x0003u) == 0x0003u && !(w[0] & 0x1000u),
                  "startrk: good, word good, power good, no alert, shutter open");
            if (got > 0) {
                /* PASS's decode gives the star's apparent direction: within
                 * the noise (20 arcsec) and a count (9 arcsec), plus the
                 * aberration it removes (<= 25 arcsec) */
                double u[3], worst = 0;
                int idx = -1;
                for (int i = 0; i < STAR_TABLE_N; i++) if (STAR_TABLE[i].id == got) idx = i;
                for (int n = 0; n < 20; n++) {
                    t += 0.16;
                    vehdyn_advance(t * 1e6);
                    read_words(20, FF(0x24C42u), 3, w);
                    st_decode(1, w, u);
                    double e = st_ang(u, STAR_TABLE[idx].u) * 3600.0;
                    if (e > worst) worst = e;
                }
                if (worst > 120.0) printf("startrk: decoded LOS %.1f arcsec from star %d\n", worst, got);
                check(worst < 120.0, "startrk: PASS's decode of the words gives the star's direction");
            }
            /* OFFSET SCAN onto the star we pointed at (H = V = 0 is offset
             * code 15.5 -- use 16, +0.15 deg), after a break track */
            uint16_t brk[1] = { 0x2000u }, off[1] = { (uint16_t)(0x8000u | (16u << 5) | 16u) };
            write_words(20, FF(0x20C40u), brk, 1);
            t += 0.04; vehdyn_advance(t * 1e6);
            write_words(20, FF(0x20C40u), off, 1);
            int got2 = 0;
            for (int n = 0; n < 10 && !got2; n++) {
                t += 0.16;
                vehdyn_advance(t * 1e6);
                read_words(20, FF(0x24C42u), 3, w);
                if (w[0] & 0x0400u) got2 = startrk_test_locked(1);
            }
            check(got2 == STAR_TABLE[pick].id, "startrk: offset scan acquires the star in its box within 1.6 s");
            int16_t hcount = (int16_t)(w[1] & 0xFFF0u) >> 4, vcount = (int16_t)(w[2] & 0xFFF0u) >> 4;
            check(abs(hcount) < 15 && abs(vcount) < 15, "startrk: it is on the boresight");
            /* BREAK TRACK in the offset box: nothing else there */
            uint16_t offbrk[1] = { (uint16_t)(off[0] | 0x2000u) };
            write_words(20, FF(0x20C40u), offbrk, 1);
            t += 0.16; vehdyn_advance(t * 1e6);
            read_words(20, FF(0x24C42u), 3, w);
            check(!(w[0] & 0x0400u), "startrk: break track drops the star and does not reacquire it");

            /* THE SELF-TEST as GY1STS runs it: offset to the light (H code
             * 29, V code 2), then with H reversed (code 2), then off */
            uint16_t st1[1] = { (uint16_t)(0xC000u | (29u << 5) | 2u) };
            write_words(20, FF(0x20C40u), st1, 1);
            bool pass1 = false;
            for (int n = 0; n < 19 && !pass1; n++) {
                t += 0.16; vehdyn_advance(t * 1e6);
                read_words(20, FF(0x24C42u), 3, w);
                pass1 = (w[0] & 0x1C00u) == 0x1C00u && (w[2] & 0x000Du) == 0 && (w[0] & 0x8000u);
            }
            check(pass1, "startrk: self-test pass 1 -- shutter closed, engaged, light present, alert, no errors");
            uint16_t st2[1] = { (uint16_t)(0xC000u | (2u << 5) | 2u) };
            write_words(20, FF(0x20C40u), st2, 1);
            bool pass2 = false;
            for (int n = 0; n < 19 && !pass2; n++) {
                t += 0.16; vehdyn_advance(t * 1e6);
                read_words(20, FF(0x24C42u), 3, w);
                pass2 = !(w[0] & 0x8000u);
            }
            check(pass2, "startrk: self-test pass 2 (H reversed) -- tracker good goes 0 within 3 s");
            write_words(20, FF(0x20C40u), cmd0, 1);
            t += 0.16; vehdyn_advance(t * 1e6);
            read_words(20, FF(0x24C42u), 3, w);
            check(!(w[0] & 0x0800u) && (w[0] & 0x8000u) && (w[0] & 0x1000u),
                  "startrk: self-test off -- disengaged, good again, shutter latched closed");
            uint16_t unl[1] = { 0x1000u };
            write_words(20, FF(0x20C40u), unl, 1);
            write_words(20, FF(0x20C40u), cmd0, 1);
            t += 0.16; vehdyn_advance(t * 1e6);
            read_words(20, FF(0x24C42u), 3, w);
            check(!(w[0] & 0x1000u), "startrk: the unlatch pulse opens the shutter");

            /* THE SUN in the field: alert, shutter closed, no star */
            st_point(1, sun);
            t += 0.16; vehdyn_advance(t * 1e6);
            read_words(20, FF(0x24C42u), 3, w);
            check(!(w[2] & 0x0001u) && (w[0] & 0x1000u) && !(w[0] & 0x0400u),
                  "startrk: the Sun at the boresight -- bright object alert, shutter closed");
            st_point(1, STAR_TABLE[pick].u);
            t += 0.16; vehdyn_advance(t * 1e6);
            read_words(20, FF(0x24C42u), 3, w);
            check((w[2] & 0x0001u) && (w[0] & 0x1000u), "startrk: Sun gone -- alert off, shutter stays latched");

            /* POWER AND DOOR (the panel's side) */
            startrk_hardware(1, false, true, t);
            read_words(20, FF(0x24C42u), 3, w);
            check(w[0] == 0 && w[1] == 0 && w[2] == 0, "startrk: switched off -- all zeros (BITE)");
            startrk_hardware(1, true, false, t);
            write_words(20, FF(0x20C40u), unl, 1);
            write_words(20, FF(0x20C40u), cmd0, 1);
            for (int n = 0; n < 80; n++) { t += 0.16; vehdyn_advance(t * 1e6); read_words(20, FF(0x24C42u), 3, w); }
            check((w[0] & 0x8000u) && !(w[0] & 0x0400u), "startrk: door closed -- good, but no star in 12 s");
            startrk_hardware(1, true, true, t);
            got = 0;
            for (int n = 0; n < 80 && !got; n++) {
                t += 0.16; vehdyn_advance(t * 1e6);
                read_words(20, FF(0x24C42u), 3, w);
                if (w[0] & 0x0400u) got = startrk_test_locked(1);
            }
            check(got > 0, "startrk: door open -- stars again");
            /* the -Y tracker answers on FF3 and nowhere else */
            check(read_words(22, FF(0x24C42u), 3, w) == 3 && (w[0] & 0x2200u) == 0x2200u,
                  "startrk: -Y tracker answers on FF3");
        }
    }

    /* THE RETURN-WORD PATTERN CHECK (ledger #262): the pattern in the
     * command's low fourteen bits comes back shifted left two. */
    check(read_words(14, FA(0x32AAAu), 1, w) == 1 && w[0] == 0xAAA8u,
          "fa1 return word echoes 2AAA as AAA8");
    check(read_words(20, FF(0x31555u), 1, w) == 1 && w[0] == 0x5554u,
          "ff1 return word echoes 1555 as 5554");

    /* THE IMU AS PASS READS IT, round trip: for random attitudes, decode the
     * resolver words the way GMDRES does, rebuild C(body <- M50) with the
     * flight software's own chain (GNWATT: TNBBODY . M1^T, TCM50 = I) and
     * compare with the truth.  The 8X resolution is 0.0055 deg (9.6e-5 rad),
     * so every matrix element must agree to 2e-4. */
    {
        vehdyn_reset(0.0);
        const double D = 3.14159265358979323846 / 180.0;
        const double NB[3][3] = { { 0.98293535, 0.0, -0.18395135 }, { 0, 1, 0 },
                                  { 0.18395135, 0.0, 0.98293535 } };
        double worst = 0.0;
        unsigned seed = 12345;
        for (int trial = 0; trial < 200; trial++) {
            double q[4];
            for (int i = 0; i < 4; i++) {
                seed = seed * 1103515245u + 12345u;
                q[i] = ((double)(seed >> 8) / 16777216.0) - 0.5;
            }
            vehdyn_set_attitude(q, NULL);
            const PhysState *st = vehdyn_state();
            if (read_words(21, FF(0x24C0Du), 14, w) != 14) { check(0, "imu read"); break; }
            double ang[3];
            for (int j = 0; j < 3; j++) {      /* OR, P, AZ */
                unsigned c1 = w[3 + 2 * j] >> 3, c8 = w[4 + 2 * j] >> 3;
                double x1 = c1 * 360.0 / 8192.0;
                double a = ((c1 >> 10) * 8192.0 + c8) * 360.0 / 65536.0;
                if (x1 - a > 22.5) a += 45.0; else if (a - x1 > 22.5) a -= 45.0;
                ang[j] = a * D;
            }
            double cO = cos(ang[0]), sO = sin(ang[0]), cP = cos(ang[1]), sP = sin(ang[1]),
                   cA = cos(ang[2]), sA = sin(ang[2]);
            double Rx[3][3] = { { 1, 0, 0 }, { 0, cO, -sO }, { 0, sO, cO } };
            double Ry[3][3] = { { cP, 0, sP }, { 0, 1, 0 }, { -sP, 0, cP } };
            double Rz[3][3] = { { cA, -sA, 0 }, { sA, cA, 0 }, { 0, 0, 1 } };
            double T[3][3], M1[3][3], C[3][3];
            for (int i = 0; i < 3; i++) for (int k = 0; k < 3; k++)
                T[i][k] = Ry[i][0] * Rx[0][k] + Ry[i][1] * Rx[1][k] + Ry[i][2] * Rx[2][k];
            for (int i = 0; i < 3; i++) for (int k = 0; k < 3; k++)
                M1[i][k] = Rz[i][0] * T[0][k] + Rz[i][1] * T[1][k] + Rz[i][2] * T[2][k];
            for (int i = 0; i < 3; i++) for (int k = 0; k < 3; k++)
                C[i][k] = NB[i][0] * M1[k][0] + NB[i][1] * M1[k][1] + NB[i][2] * M1[k][2];
            /* truth: C(body <- M50) = R(q)^T */
            double a0 = st->q[0], x = st->q[1], y = st->q[2], z = st->q[3];
            double R[3][3] = {
                { 1 - 2 * (y * y + z * z), 2 * (x * y - a0 * z), 2 * (x * z + a0 * y) },
                { 2 * (x * y + a0 * z), 1 - 2 * (x * x + z * z), 2 * (y * z - a0 * x) },
                { 2 * (x * z - a0 * y), 2 * (y * z + a0 * x), 1 - 2 * (x * x + y * y) } };
            for (int i = 0; i < 3; i++) for (int k = 0; k < 3; k++) {
                double e = fabs(C[i][k] - R[k][i]);
                if (e > worst) worst = e;
            }
        }
        if (worst >= 2e-4) printf("imu round trip worst element error %.3g\n", worst);
        check(worst < 2e-4, "imu attitude round trip through PASS's decoding");

        /* AND ITS ACCELEROMETERS, AS PASS COMPENSATES THEM: L1A + R1A (+X)
         * for 4 s, attitude identity so body X is platform X.  IMU 2 is in
         * high gain (commanded above), so a pulse weighs a tenth of
         * 0.0344488 ft/s times (1 + SFLO 1e-6), and each axis has its BILO
         * bias.  GMHACP's compensation -- counts x weight - bias x dt, Z
         * negated first -- must give back the true delta-V: 2 F t / m along the
         * jets' canted line, X and +Z, nothing along Y -- once GRWIMU has taken out the
         * navigation base's motion about the CG, w x r carried to the
         * platform (the aft pair also starts the vehicle turning, and the
         * accelerometers sit 58 ft forward of the CG: ledger #274). */
        double ident[4] = { 1, 0, 0, 0 };
        vehdyn_reset(0.0);
        vehdyn_set_attitude(ident, NULL);
        read_words(21, FF(0x24C0Du), 14, w);
        uint16_t c0[3] = { w[9], w[10], w[11] };
        double m0 = vehdyn_state()->mass;
        uint16_t ffw[5] = { 0 }, faw[5] = { 0 };
        faw[1] = 0x8000 | 0x1000;
        vehdyn_set_fire_words(ffw, faw, 0.0);
        faw[1] = 0;
        vehdyn_set_fire_words(ffw, faw, 4e6);
        read_words(21, FF(0x24C0Du), 14, w);
        const double SF[3] = { -35780.0, -34250.0, -48240.0 };   /* IMU 2 */
        const double BI[3] = { -17842.0, -13376.0, -32666.0 };
        /* L1A and R1A are canted 10 deg toward +Z (PASS's GCQORB REF_FORCE,
         * vehdyn.c JETS): each 856.78 lbf along X and 151.12 lbf along +Z. */
        const double LBF = 4.4482216152605;
        double truth[3] = { 2.0 * 856.78 * LBF * 4.0 / m0 / 0.3048, 0.0,
                            2.0 * 151.12 * LBF * 4.0 / m0 / 0.3048 };
        const PhysState *ps = vehdyn_state();
        const double RNB[3] = { 57.959, -0.067, -3.967 };
        double wr[3] = { ps->w[1] * RNB[2] - ps->w[2] * RNB[1], ps->w[2] * RNB[0] - ps->w[0] * RNB[2],
                         ps->w[0] * RNB[1] - ps->w[1] * RNB[0] };
        double qa = ps->q[0], qx = ps->q[1], qy = ps->q[2], qz = ps->q[3];
        double Q[3][3] = {
            { 1 - 2 * (qy * qy + qz * qz), 2 * (qx * qy - qa * qz), 2 * (qx * qz + qa * qy) },
            { 2 * (qx * qy + qa * qz), 1 - 2 * (qx * qx + qz * qz), 2 * (qy * qz - qa * qx) },
            { 2 * (qx * qz - qa * qy), 2 * (qy * qz + qa * qx), 1 - 2 * (qx * qx + qy * qy) } };
        double vnb[3];
        for (int i = 0; i < 3; i++) vnb[i] = Q[i][0] * wr[0] + Q[i][1] * wr[1] + Q[i][2] * wr[2];
        check(fabs(vnb[0]) + fabs(vnb[1]) + fabs(vnb[2]) > 0.001,
              "the aft pair turns the vehicle, so the lever arm is exercised");
        for (int ax = 0; ax < 3; ax++) {
            int d = (int16_t)(uint16_t)(w[9 + ax] - c0[ax]);
            if (ax == 2) d = -d;
            double comp = d * (1.0 + SF[ax] * 1e-6) * 0.00344488 - BI[ax] * 1e-6 * 32.174 * 4.0
                          - vnb[ax];
            if (fabs(comp - truth[ax]) > 0.01)
                printf("axis %d: compensated %.4f ft/s, truth %.4f\n", ax, comp, truth[ax]);
            check(fabs(comp - truth[ax]) <= 0.01, "PASS-compensated accelerometer delta-V equals the truth");
        }
    }

    /* NO PHANTOM ACCELERATION OVER A LONG COAST WHILE THE VEHICLE TURNS
     * (the rendezvous M1 runs, RENDEZVOUS_PLAN.md 5a: was the Orbiter's PROP
     * drift an accelerometer residual?).  Half an hour of coasting while
     * the vehicle pitches at the orbital rate, as it does in LVLH hold and
     * in -Z target track; IMUs 1 and 3, low gain, read every 0.16 s as the
     * HFE reads them, and compensated every sixth read (the 0.96 s MFE
     * cycle) the way PASS does it: GMHACP's counts x weight - bias x dt in
     * the cluster, GMLACP's TCM50 (here the platform's own orientation --
     * nobody torques it in this test, so it drifts by GYREST and the
     * compensation must follow it), and GRWIMU's navigation-base correction
     * (the change of Q (w x r)).  Each IMU's compensated total must stay
     * within a pulse of the truth's sensed delta-V for the whole half hour:
     * a residual of the 19 micro-g size the M1 runs suggested would have
     * reached 1 ft/s.  (It was not the IMUs: PASS discards each attitude
     * maneuver's sensed delta-V below 0.9 ft/s, GL5NAV steps 9A-9C, and the
     * jets' real translation goes with it.) */
    {
        const double SFL[4][3] = { { 0 }, { 45890.0, -42360.0, 54480.0 }, { 0 },
                                   { 39680.0, 30080.0, -58080.0 } };
        const double BIL[4][3] = { { 0 }, { 18280.0, -16789.0, 37444.0 }, { 0 },
                                   { 14332.0, 12666.0, -39545.0 } };
        const int BUS[4] = { 0, 20, 0, 22 };
        const double RNB[3] = { 57.959, -0.067, -3.967 }, n_orb = 1.13e-3;
        double q0[4] = { 1, 0, 0, 0 }, w0[3] = { 0.0, -n_orb, 0.0 };
        vehdyn_reset(0.0);
        vehdyn_set_attitude(q0, w0);
        uint16_t cprev[4][3];
        double tot[4][3] = { { 0 } }, tprev = 0.0, worst = 0.0, s0[3] = { 0, 0, 0 }, vnb0[3] = { 0, 0, 0 };
        double t = 0.0;
        for (int step = 0; step <= 11250; step++) {        /* 1800 s */
            t = step * 0.16;
            vehdyn_advance(t * 1e6);
            uint16_t cnt[4][3];
            memset(cnt, 0, sizeof cnt);
            for (int k = 1; k <= 3; k += 2) {
                read_words(BUS[k], FF(0x24C0Du), 14, w);
                for (int a = 0; a < 3; a++) cnt[k][a] = w[9 + a];
            }
            if (step % 6) continue;
            /* the navigation base's velocity about the CG, M50 ft/s */
            const PhysState *ps = vehdyn_state();
            double wr[3] = { ps->w[1] * RNB[2] - ps->w[2] * RNB[1], ps->w[2] * RNB[0] - ps->w[0] * RNB[2],
                             ps->w[0] * RNB[1] - ps->w[1] * RNB[0] }, Rq[3][3], vnb[3], sd[3];
            st_qmat(ps->q, Rq);
            for (int i = 0; i < 3; i++) vnb[i] = Rq[i][0] * wr[0] + Rq[i][1] * wr[1] + Rq[i][2] * wr[2];
            vehdyn_sensed_dv(sd);
            if (step == 0) {
                memcpy(cprev, cnt, sizeof cprev);
                memcpy(vnb0, vnb, sizeof vnb0);
                for (int i = 0; i < 3; i++) s0[i] = sd[i] / 0.3048;
                tprev = t;
                continue;
            }
            for (int k = 1; k <= 3; k += 2) {
                double P[3][3], dc[3];
                mdmdev_test_platform(k, P);
                for (int a = 0; a < 3; a++) {
                    int d = (int16_t)(uint16_t)(cnt[k][a] - cprev[k][a]);
                    if (a == 2) d = -d;                      /* GMCACP */
                    dc[a] = d * (1.0 + SFL[k][a] * 1e-6) * 0.0344488 - BIL[k][a] * 1e-6 * 32.174 * (t - tprev);
                }
                for (int i = 0; i < 3; i++) tot[k][i] += P[i][0] * dc[0] + P[i][1] * dc[1] + P[i][2] * dc[2];
                for (int i = 0; i < 3; i++) {
                    double e = fabs(tot[k][i] - (vnb[i] - vnb0[i]) - (sd[i] / 0.3048 - s0[i]));
                    if (e > worst) worst = e;
                }
            }
            memcpy(cprev, cnt, sizeof cprev);
            tprev = t;
        }
        double c0 = vehdyn_state()->q[0];
        double turned = 2.0 * acos(fabs(c0) > 1.0 ? 1.0 : fabs(c0)) * 180.0 / 3.14159265358979323846;
        if (turned < 100.0) printf("coasting IMUs: the vehicle turned only %.1f deg\n", turned);
        check(turned > 100.0, "the vehicle turned through the half hour (lever arm and frames exercised)");
        /* one pulse of the heaviest weight here, IMU 1's Z: 0.0344488 x 1.05448 */
        if (worst > 0.0364) printf("coasting IMUs: worst compensated error %.4f ft/s over %.0f s\n", worst, t);
        check(worst <= 0.0364, "coasting, turning IMUs: PASS-compensated delta-V within a pulse of the truth for 30 min");
    }

    /* GPS, FF1 CARD 11 CHANNEL 2.  Silent until commanded; then, in NAV,
     * a message PASS decodes -- by GPBGPS.hal's arithmetic and GLJRCV.hal's
     * frame change, done here independently -- back to the truth state at
     * the solution's time, to the receiver's own resolution (1/16 ft,
     * 1/512 ft/s); and that time is GPS_LAG_S before the read, in PASS GMT. */
    {
        vehdyn_set_gmt_zero(1790000000.0);     /* 2026-09-21; turns the field */
        vehdyn_reset(0.0);
        vehdyn_advance(99.95e6);
        double rTrue[3], vTrue[3];
        memcpy(rTrue, vehdyn_state()->r, sizeof rTrue);
        memcpy(vTrue, vehdyn_state()->v, sizeof vTrue);
        vehdyn_reset(0.0);
        vehdyn_advance(100e6);
        double ri[3], vi[3];
        check(vehdyn_state_at(99.95, ri, vi), "state history covers the solution time");
        double dr = 0, dv = 0;
        for (int i = 0; i < 3; i++) { dr += (ri[i] - rTrue[i]) * (ri[i] - rTrue[i]); dv += (vi[i] - vTrue[i]) * (vi[i] - vTrue[i]); }
        if (sqrt(dr) > 1e-3 || sqrt(dv) > 1e-5) printf("history: %.3g m, %.3g m/s off\n", sqrt(dr), sqrt(dv));
        check(sqrt(dr) < 1e-3 && sqrt(dv) < 1e-5, "interpolated history is the propagated state");

        check(read_words(20, FF(0x26C5Fu), 32, w) == 32 && w[0] == 0, "gps1 silent before a command");
        uint16_t msg1[32] = { 0xAAAAu, 0x8000u, 0x0651u }, msg3[32] = { 0xBBBBu };
        write_words(20, FF(0x22C5Fu), msg1, 32);
        write_words(20, FF(0x22C5Fu), msg3, 32);
        check(read_words(20, FF(0x26C5Fu), 32, w) == 32, "gps1 length");
        check(w[0] == 0xFFFFu, "gps1 NAV header");
        check((w[1] & 0xE000u) == 0xC000u && (w[2] & 3u) == 1u, "gps1 valid, NAV, complement 01");
        check(((w[19] >> 1) & 0xFu) == 1u, "gps1 FOM 1");
        int tracking = 0;
        const int CHW[5] = { 21, 23, 25, 27, 28 };
        for (int c = 0; c < 5; c++) {
            unsigned b57 = (w[CHW[c]] >> 9) & 7u;
            if (b57 == 5u || b57 == 3u) tracking++;
        }
        check(tracking == 5, "gps1 five channels tracking");
        /* GPBGPS.hal:926-932 */
        double sec = ((double)w[4] * 4294967296.0 + (double)w[5] * 65536.0 + (double)w[6]) * 1e-8;
        double gmt = sec + w[3] * 604800.0 - 11.0 - 504403200.0;
        double tv = gmt - vehdyn_gmt(0.0);
        if (fabs(tv - 99.95) > 1e-6) printf("gps time of validity %.9f\n", tv);
        check(fabs(tv - 99.95) < 1e-6, "gps time is PASS GMT, GPS_LAG_S before the read");
        double re[3], ve[3];
        for (int i = 0; i < 3; i++) {
            int32_t pr = (int32_t)(((uint32_t)w[7 + 2 * i] << 16) | w[8 + 2 * i]);
            int32_t vr = (int32_t)(((uint32_t)w[13 + 2 * i] << 16) | w[14 + 2 * i]);
            re[i] = pr * 0.0625 * 0.3048;
            ve[i] = vr * 0.001953125 * 0.3048;
        }
        /* GLJRCV.hal:520-531: R = M re, V = M ve + omega x R, M = EF -> M50 */
        double M[3][3], R[3], V[3], rate = 0.729211514646E-4;
        phys_inertial_to_earth(tv, M);
        for (int i = 0; i < 3; i++) {
            R[i] = M[0][i] * re[0] + M[1][i] * re[1] + M[2][i] * re[2];
            V[i] = M[0][i] * ve[0] + M[1][i] * ve[1] + M[2][i] * ve[2];
        }
        double om[3] = { rate * M[2][0], rate * M[2][1], rate * M[2][2] };
        V[0] += om[1] * R[2] - om[2] * R[1];
        V[1] += om[2] * R[0] - om[0] * R[2];
        V[2] += om[0] * R[1] - om[1] * R[0];
        /* THE NAVIGATION BASE, not the c.g.: the vehicle is at rest, so the
         * lever arm is the same at the read and at the solution time */
        {
            double rnb[3], vnb[3], C[3][3], M1[3][3];
            vehdyn_navbase_ef(rnb, vnb, C);
            phys_inertial_to_earth(vehdyn_state()->t, M1);
            for (int i = 0; i < 3; i++)
                rTrue[i] += M1[0][i] * rnb[0] + M1[1][i] * rnb[1] + M1[2][i] * rnb[2] - vehdyn_state()->r[i];
        }
        dr = dv = 0;
        for (int i = 0; i < 3; i++) { dr += (R[i] - rTrue[i]) * (R[i] - rTrue[i]); dv += (V[i] - vTrue[i]) * (V[i] - vTrue[i]); }
        if (sqrt(dr) > 0.02 || sqrt(dv) > 0.001) printf("gps decoded: %.4g m, %.4g m/s off\n", sqrt(dr), sqrt(dv));
        check(sqrt(dr) < 0.02, "gps position decodes to the truth (1/16 ft)");
        check(sqrt(dv) < 0.001, "gps velocity decodes to the truth (1/512 ft/s)");
        /* a second read later carries a newer time: not static data */
        vehdyn_advance(100.96e6);
        uint16_t w2[32];
        read_words(20, FF(0x26C5Fu), 32, w2);
        check(w2[6] != w[6] || w2[5] != w[5], "gps time advances between reads");
        /* INIT and TEST answer in their own formats */
        msg1[1] = 0x4000u;
        write_words(20, FF(0x22C5Fu), msg1, 32);
        read_words(20, FF(0x26C5Fu), 32, w2);
        check(w2[0] == 0xEEEEu && (w2[1] & 0xE000u) == 0x2000u && (w2[2] & 3u) == 2u, "gps1 INIT");
        msg1[1] = 0x0000u;
        write_words(20, FF(0x22C5Fu), msg1, 32);
        read_words(20, FF(0x26C5Fu), 32, w2);
        check(w2[0] == 0xDDDDu && (w2[1] & 0xE000u) == 0 && (w2[2] & 3u) == 3u, "gps1 TEST");
    }

    /* CREW CONTACTS: the panel's ADI switches on FF1 DSCRT2 (DIH card 4
     * ch 1) and the SENSE switch on FF2 DSCRT7 (DIH card 9 ch 1), sent as
     * real datagrams, appear in the HFE read's words 1 and 6 and the MFE
     * read's 9 and 14 -- ORed with what the device model puts there. */
    {
        mdmdev_crew_open(CREW_BASE);
        crew_send(1, 4, 4, 1, 0x4900u);   /* VALUE: LVLH, rate MED, error MED */
        crew_send(2, 1, 9, 1, 0x4000u);   /* SET: SENSE -Z */
        uint16_t h1[36], h2[36], m2[21];
        bool ok = false;
        for (int tries = 0; tries < 200 && !ok; tries++) {
            read_words(20, FF(0x082E8u), 36, h1);
            read_words(21, FF(0x082E8u), 36, h2);
            ok = h1[1] == 0x4900u && (h2[6] & 0x4000u);
            if (!ok) { struct timespec ts = { 0, 2000000 }; nanosleep(&ts, NULL); }
        }
        check(h1[1] == 0x4900u, "crew ADI switches reach FF1 DSCRT2 (HFE word 1)");
        check((h2[6] & 0x4000u) != 0, "crew SENSE -Z reaches FF2 DSCRT7 (HFE word 6)");
        check(read_words(21, FF(0x082C5u), 21, m2) == 21 && (m2[14] & 0x4000u),
              "the same contact in the MFE read (word 14)");
        crew_send(2, 2, 9, 1, 0x4000u);   /* RESET it */
        ok = false;
        for (int tries = 0; tries < 200 && !ok; tries++) {
            read_words(21, FF(0x082E8u), 36, h2);
            ok = (h2[6] & 0x4000u) == 0;
            if (!ok) { struct timespec ts = { 0, 2000000 }; nanosleep(&ts, NULL); }
        }
        check(ok, "a RESET clears the contact");
        /* A contact on a word the device model also writes -- DSCRT4, the
         * forward THC's +X, beside the model's chamber-pressure bits -- must
         * survive it (it was wiped, the model's words being assigned after
         * the contacts were ORed in). */
        crew_send(1, 1, 6, 0, 0x0100u);     /* SET: THC +X on FF1 DSCRT4 */
        ok = false;
        for (int tries = 0; tries < 200 && !ok; tries++) {
            read_words(20, FF(0x082E8u), 36, h1);
            ok = (h1[3] & 0x0100u) != 0;
            if (!ok) { struct timespec ts = { 0, 2000000 }; nanosleep(&ts, NULL); }
        }
        check(ok, "a THC contact on DSCRT4 survives the device model's words");
        crew_send(1, 2, 6, 0, 0x0100u);
        /* THE AFT MDMs: crew units 5-8 are FA1-4.  OMS ENG L ARM (FA1 DSCRT2
         * bit 8, DIH card 3 ch 1) reaches the FA HFE read's word 19; a
         * contact on DSCRT3 (card 3 ch 2) is ORed with the device model's
         * manifold-open bits in word 20, not over them. */
        uint16_t a1[54];
        crew_send(5, 1, 3, 1, 0x0100u);
        crew_send(5, 1, 3, 2, 0x0001u);
        ok = false;
        for (int tries = 0; tries < 200 && !ok; tries++) {
            read_words(14, FA(0x0836Eu), 54, a1);
            ok = (a1[19] & 0x0300u) == 0x0100u && a1[20] == 0xA001u;
            if (!ok) { struct timespec ts = { 0, 2000000 }; nanosleep(&ts, NULL); }
        }
        check((a1[19] & 0x0300u) == 0x0100u, "crew OMS ENG ARM reaches FA1 DSCRT2 (HFE word 19)");
        check(a1[20] == 0xA001u, "an FA contact is ORed with the manifold bits");
        crew_send(5, 2, 3, 1, 0x0100u);
        crew_send(5, 2, 3, 2, 0x0001u);
        ok = false;
        for (int tries = 0; tries < 200 && !ok; tries++) {
            read_words(14, FA(0x0836Eu), 54, a1);
            ok = (a1[19] & 0x0300u) == 0 && a1[20] == 0xA000u;
            if (!ok) { struct timespec ts = { 0, 2000000 }; nanosleep(&ts, NULL); }
        }
        check(ok, "and RESET clears the FA contacts");

        /* THE LEFT OMS ENGINE, through the bus as PASS drives it: power to
         * the left primary actuator controller (FF1 DOH card 2 ch 2), the
         * gimbal command on FA1's AOD card 4 ch 7-8 (FIOHO106, X'210E1') at
         * the two-engine trim, and the control-valve coil on FA1 card 15
         * ch 1 (FIOHOS05, X'23E02').  Disarmed, nothing burns however the
         * coils are set; the actuators still follow, and every FA's feedback
         * reads them back as the command, in PASS's feedback scaling.
         * Armed from the panel (FA1 DSCRT2 ARM), the engine burns and FA3
         * reports chamber pressure, in both the MFE word and the one-word
         * HFE read; the right engine stays cold. */
        vehdyn_reset(0.0);
        uint16_t pwr = 0x6000u;
        write_words(20, FF(0x20A40u), &pwr, 1);
        int16_t pc = (int16_t)floor(0.4 * 3902.08 - 286.72), yc = (int16_t)floor(-5.75 * 3912.96 - 1660.80);
        uint16_t aod[2] = { (uint16_t)pc, (uint16_t)yc };
        write_words(14, FA(0x210E1u), aod, 2);
        uint16_t coil[3] = { 0, 0x4000u, 0 };
        write_words(14, FA(0x23E02u), coil, 3);
        vehdyn_advance(3e6);
        check(!vehdyn_oms_burning(0), "OMS: disarmed, the coils alone fire nothing");
        read_words(14, FA(0x0836Eu), 54, a1);
        /* GPLOMS.hal:63-70's scaling: within 0.01 deg of what was commanded */
        double fbP = (int16_t)a1[0] * 0.00025625 + 0.0735, fbY = (int16_t)a1[1] * 0.00025562 + 0.4244;
        if (fabs(fbP - 0.4) > 0.01 || fabs(fbY + 5.75) > 0.01) printf("feedback %.4f %.4f deg\n", fbP, fbY);
        check(fabs(fbP - 0.4) < 0.01 && fabs(fbY + 5.75) < 0.01,
              "OMS: gimbal feedback, as PASS scales it, is the commanded trim");
        crew_send(5, 1, 3, 1, 0x0100u);           /* L ARM */
        ok = false;
        for (int tries = 0; tries < 200 && !ok; tries++) {
            read_words(14, FA(0x0836Eu), 54, a1);
            ok = a1[19] == 0x0100u;
            if (!ok) { struct timespec ts = { 0, 2000000 }; nanosleep(&ts, NULL); }
        }
        write_words(14, FA(0x23E02u), coil, 3);
        check(vehdyn_oms_burning(0) && !vehdyn_oms_burning(1), "OMS: armed, the left engine burns");
        uint16_t mf[34], one[1];
        read_words(16, FA(0x082A5u), 34, mf);
        check(mf[15] == 20000u, "OMS: FA3 MFE SEG2(11) chamber pressure while burning");
        read_words(17, FA(0x082A5u), 34, mf);
        check(mf[15] == 0u, "OMS: FA4 (right) chamber pressure zero");
        check(read_words(16, FA(0x25A40u), 1, one) == 1 && one[0] == 20000u, "OMS: FA3 one-word Pc read");
        uint16_t nocoil[3] = { 0xFFFFu, 0xFFFFu, 0xFFFFu };
        write_words(14, FA(0x23C02u), nocoil, 3);   /* the RESET word, card 15 ch 0-2 */
        check(!vehdyn_oms_burning(0), "OMS: coils reset, the engine stops");
        crew_send(5, 2, 3, 1, 0x0100u);
    }

    /* A SESSION CAPTURE: vehdyn.json round trip.  The truth state, OMS
     * propellant and actuator, and an IMU's running counts survive, with the
     * time rebased so the restored clock's zero is the captured instant --
     * and the vehicle then moves on from there exactly as the original
     * would have. */
    {
        char dir[512];
        const char *tmp = getenv("TMPDIR");
        if (tmp == NULL) tmp = getenv("TEMP");
        if (tmp == NULL) tmp = "/tmp";
        snprintf(dir, sizeof dir, "%s/test_mdmdev_capXXXXXX", tmp);
        check(mkdtemp(dir) != NULL, "capture: temporary directory");
        vehdyn_reset(0.0);
        vehdyn_set_oms(1, false, true, 1.5, -2.0, 0.0);
        vehdyn_advance(120e6);
        read_words(21, FF(0x24C0Du), 14, w);               /* IMU 2 counting */
        vehdyn_set_propellant(4, 4000.0);
        double r0[3], v0[3], rFut[3];
        memcpy(r0, vehdyn_state()->r, sizeof r0);
        memcpy(v0, vehdyn_state()->v, sizeof v0);
        double gim = vehdyn_oms_gimbal(1, 0);
        double Pcap[3][3];
        mdmdev_test_platform(1, Pcap);
        int lockCap = startrk_test_locked(1);
        check(mdmdev_dump(dir), "capture: vehdyn.json written");
        vehdyn_advance(150e6);
        memcpy(rFut, vehdyn_state()->r, sizeof rFut);       /* where it goes next */
        vehdyn_reset(0.0);                                  /* a fresh process */
        check(mdmdev_load(dir), "capture: vehdyn.json read");
        const PhysState *st = vehdyn_state();
        double dr = 0, dv = 0;
        for (int i = 0; i < 3; i++) { dr += fabs(st->r[i] - r0[i]); dv += fabs(st->v[i] - v0[i]); }
        check(dr == 0.0 && dv == 0.0 && st->t == 0.0, "capture: state restored, time rebased to 0");
        check(vehdyn_propellant(4) == 4000.0 && vehdyn_oms_gimbal(1, 0) == gim, "capture: OMS restored");
        {
            double Pl[3][3];
            mdmdev_test_platform(1, Pl);
            check(memcmp(Pl, Pcap, sizeof Pl) == 0, "capture: IMU1's platform orientation restored");
            check(startrk_test_locked(1) == lockCap && lockCap != 0,
                  "capture: the -Z star tracker is still locked on the same star");
        }
        vehdyn_advance(30e6);                               /* 30 s on the restored clock */
        double d = 0;
        for (int i = 0; i < 3; i++) d += (vehdyn_state()->r[i] - rFut[i]) * (vehdyn_state()->r[i] - rFut[i]);
        if (sqrt(d) > 0.01) printf("restored vehicle %.4g m from the original\n", sqrt(d));
        check(sqrt(d) < 0.01, "capture: the restored vehicle flies on as the original did");
        char file[600];
        snprintf(file, sizeof file, "%s/vehdyn.json", dir);
        if (remove(file) != 0 || rmdir(dir) != 0) printf("could not remove %s\n", dir);
    }

    mtumodel_free(m);
    printf("mdmdev: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
