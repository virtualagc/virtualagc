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

int main(void) {
    setenv("YAGPC_MDM_DEVICES", "1", 1);
    /* Before anything reads it: the switch is cached on first use. */
    setenv("YAGPC_VEHDYN", "1", 1);
    m = mtumodel_create();
    uint16_t w[64];

    /* AFT, AT REST: FA1 (bus 14), FIOHI1C1. */
    check(read_words(14, FA(0x0836Eu), 54, w) == 54, "fa1 hfe length");
    check(w[2] == 16000 && w[17] == 16000, "fa1 injector temperatures warm");
    check(w[20] == 0xA000u, "fa1 right manifolds 1-4 open");
    check(w[25] == 0xA00Cu, "fa1 left manifolds 1-4 and 5 open");
    check(w[21] == 0x00E0u, "fa1 no chamber pressure, rate gyros spinning");
    check(w[22] == 0x0000u, "fa1 no jet driver on");
    check(read_words(15, FA(0x0836Eu), 54, w) == 54 && w[20] == 0xA00Cu,
          "fa2 right manifold 5 open");

    /* FIRE L1A (FA1 bit 1) and L5L (bit 8): B is card 10 channel 0, the
     * reset word then the set word, channel 1 alongside. */
    {
        uint16_t reset[2] = { 0x7EFFu, 0xFFFFu }, set[2] = { 0x8100u, 0x0000u };
        write_words(14, FA(0x22801u), reset, 2);
        write_words(14, FA(0x22A01u), set, 2);
        read_words(14, FA(0x0836Eu), 54, w);
        check(w[21] == 0x81E0u, "fa1 chamber pressure follows the fire command");
        check(w[22] == 0x8100u, "fa1 jet drivers follow the fire command");
        uint16_t off[2] = { 0x0000u, 0x0000u }, none[2] = { 0xFFFFu, 0xFFFFu };
        write_words(14, FA(0x22801u), none, 2);
        write_words(14, FA(0x22A01u), off, 2);
        read_words(14, FA(0x0836Eu), 54, w);
        check(w[21] == 0x00E0u && w[22] == 0, "fa1 jets off again");
    }

    /* FORWARD, AT REST: FF3 (bus 22) carries manifold 5 and IMU 3. */
    check(read_words(22, FF(0x082E8u), 36, w) == 36, "ff3 hfe length");
    check(w[0] == 0x0110u && w[8] == 0x0110u, "ff3 manifolds 3 and 5 open");
    check(w[11] == 0xFC00u, "ff3 imu discretes good");
    check(w[13] == 16000 && w[20] == 16000, "ff3 injector temperatures warm");
    check(read_words(23, FF(0x082E8u), 36, w) == 36 && w[11] == 0,
          "ff4 has no imu");
    /* The MFE read: eight analog words, then the same thirteen discretes. */
    check(read_words(20, FF(0x082C5u), 21, w) == 21, "ff1 mfe length");
    check(w[8] == 0x0100u && w[16] == 0x0100u && w[19] == 0xFC00u,
          "ff1 mfe discretes match the hfe");

    /* FIRE F1F (FF1 bit 1): card 13 channel 0. */
    {
        uint16_t reset = 0x7FFFu, set = 0x8040u;     /* with IMU 1 operate */
        write_words(20, FF(0x23400u), &reset, 1);
        write_words(20, FF(0x23600u), &set, 1);
        read_words(20, FF(0x082E8u), 36, w);
        check(w[3] == 0x8000u && w[5] == 0x8000u,
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
         * negated first -- must give back the true delta-V: 2 F t / m along X
         * and nothing along Y or Z. */
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
        double truth[3] = { 2.0 * 3870.0 * 4.0 / m0 / 0.3048, 0.0, 0.0 };
        for (int ax = 0; ax < 3; ax++) {
            int d = (int16_t)(uint16_t)(w[9 + ax] - c0[ax]);
            if (ax == 2) d = -d;
            double comp = d * (1.0 + SF[ax] * 1e-6) * 0.00344488 - BI[ax] * 1e-6 * 32.174 * 4.0;
            if (fabs(comp - truth[ax]) > 0.01)
                printf("axis %d: compensated %.4f ft/s, truth %.4f\n", ax, comp, truth[ax]);
            check(fabs(comp - truth[ax]) <= 0.01, "PASS-compensated accelerometer delta-V equals the truth");
        }
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
    }

    mtumodel_free(m);
    printf("mdmdev: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
