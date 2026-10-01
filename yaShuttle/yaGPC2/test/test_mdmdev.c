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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/mtumodel.h"
#include "../src/busword.h"

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

int main(void) {
    setenv("YAGPC_MDM_DEVICES", "1", 1);
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

    mtumodel_free(m);
    printf("mdmdev: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
