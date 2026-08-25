/* Receiving side of the GPC discrete-input bus; see discretes.h. */
#define _DEFAULT_SOURCE /* struct ip_mreq under -std=c11's strict mode */

#include "discretes.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "compat.h"

#define DISCRETES_GROUP "239.255.1.1"
#define DISCRETES_PORT  6980

#define OP_SET   1
#define OP_RESET 2

#define WORDS 4

/* One bus, so one instance.  Kept here rather than in IOP because it is a
 * property of the process's connection to the outside world, not of the
 * emulated machine -- the same reason the bus transport keeps its own. */
/* Names for the bits, so YAGPC_DISCRETETRACE reads as something a person
 * can follow rather than a hex mask.  From the IOP Principles of
 * Operation, as laid out in iop.c's own discrete-input comment. */
static const char *bit_name(int reg, int bit) {
    if (reg == DISCRETES_REG_A) {
        switch (bit) {
            case 0: return "HALT";        case 1: return "STANDBY";
            case 2: return "RUN";         case 3: return "IPL";
            case 4: return "MM1 IPL src"; case 5: return "MM2 IPL src";
            case 6: return "MM1 READY";   case 7: return "MM2 READY";
            case 12: return "IOP term A"; case 13: return "IOP term B";
            default: return NULL;
        }
    }
    switch (bit) {
        case 0: case 1: case 2: return "GPC ID";
        case 3: return "BFS engage 1";    case 4: return "BFS engage 2";
        case 5: return "BFS engage 3";    case 6: return "CRT select A";
        case 7: return "CRT select B";
        default: return NULL;
    }
}

static struct {
    int fd;
    bool open;
    bool trace;
    unsigned long messages;
    double staleSec;
    /* Index 0 is register A, 1 is register B. */
    uint32_t value[2];
    /* When each bit was last published.  Per BIT, not per register: a
     * crew panel republishing the switches must not make a departed mass
     * memory's READY look fresh. */
    double lastSeen[2][32];
    /* Bits this process drives itself, which it must not then treat as
     * externally driven -- see discretes.h. */
    uint32_t selfDriven[2];
    struct sockaddr_in group;
} g;

static int reg_index(int reg) {
    return (reg == DISCRETES_REG_B) ? 1 : 0;
}

bool discretes_enabled(void) { return g.open; }
unsigned long discretes_message_count(void) { return g.messages; }

bool discretes_open(void) {
    if (g.open) return true;
    memset(&g, 0, sizeof g);

    /* Publishers repeat themselves several times a second, so tracing
     * every message would be noise: only a message that actually CHANGES
     * a register prints. */
    g.trace = getenv("YAGPC_DISCRETETRACE") != NULL;

    g.staleSec = DISCRETES_STALE_SEC;
    const char *s = getenv("YAGPC_DISCRETES_STALE_SEC");
    if (s != NULL) {
        double v = atof(s);
        if (v > 0.0) g.staleSec = v;
    }

    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        fprintf(stderr, "discretes: socket failed: %s\n", strerror(errno));
        return false;
    }

    int reuse = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse) < 0) {
        fprintf(stderr, "discretes: SO_REUSEADDR failed: %s\n", strerror(errno));
        close(fd);
        return false;
    }

    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)DISCRETES_PORT);
    if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0) {
        fprintf(stderr, "discretes: bind(port %d) failed: %s\n",
                DISCRETES_PORT, strerror(errno));
        close(fd);
        return false;
    }

    /* Pin the interface, for the same reason bcenet_transport.c does:
     * joining without naming one can have the host deliver every datagram
     * twice.  Every LRU is a process on this machine, so loopback by
     * default; NSTS_BUS_IFACE runs the bus across a real network, exactly
     * as the reference's Bus.IFACE does. */
    const char *ifaceStr = getenv("NSTS_BUS_IFACE");
    if (ifaceStr == NULL) ifaceStr = "127.0.0.1";
    struct in_addr iface;
    iface.s_addr = inet_addr(ifaceStr);
    if (iface.s_addr == INADDR_NONE) iface.s_addr = htonl(INADDR_ANY);
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_IF, &iface, sizeof iface);

    struct ip_mreq mreq = {0};
    mreq.imr_multiaddr.s_addr = inet_addr(DISCRETES_GROUP);
    mreq.imr_interface.s_addr = iface.s_addr;
    if (setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof mreq) < 0) {
        fprintf(stderr, "discretes: IP_ADD_MEMBERSHIP failed: %s\n", strerror(errno));
        close(fd);
        return false;
    }

    int loop = 1;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof loop);
    int ttl = 128;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof ttl);

    /* Where discretes_publish sends.  Same socket: it is already pinned to
     * the interface and in the group, and a device driving a line is a peer
     * on this bus like any other. */
    g.group.sin_family = AF_INET;
    g.group.sin_addr.s_addr = inet_addr(DISCRETES_GROUP);
    g.group.sin_port = htons((uint16_t)DISCRETES_PORT);

    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);

    g.fd = fd;
    g.open = true;
    return true;
}

void discretes_close(void) {
    if (!g.open) return;
    close(g.fd);
    g.open = false;
    g.fd = -1;
}

/* Apply one well-formed message.  Anything else is ignored rather than
 * guessed at, so unrelated traffic on the group cannot corrupt a
 * register. */
static void apply(const uint8_t *b, size_t n) {
    if (n < WORDS * 2) return;
    unsigned op  = (unsigned)((b[0] << 8) | b[1]);
    unsigned reg = (unsigned)((b[2] << 8) | b[3]);
    if (op != OP_SET && op != OP_RESET) return;
    if (reg != DISCRETES_REG_A && reg != DISCRETES_REG_B) return;

    uint32_t mask = ((uint32_t)b[4] << 24) | ((uint32_t)b[5] << 16) |
                    ((uint32_t)b[6] << 8) | (uint32_t)b[7];
    if (mask == 0) return;

    int r = reg_index((int)reg);
    uint32_t before = g.value[r];
    if (op == OP_SET) g.value[r] |= mask;
    else              g.value[r] &= ~mask;

    double now = yagpc_monotonic_seconds();
    for (int bit = 0; bit < 32; bit++) {
        if (mask & (0x80000000u >> bit)) g.lastSeen[r][bit] = now;
    }
    g.messages++;

    if (g.trace && g.value[r] != before) {
        fprintf(stderr, "DISCRETE %-5s %c  %08x  ->  %08x   ",
                (op == OP_SET) ? "SET" : "RESET",
                (reg == DISCRETES_REG_B) ? 'B' : 'A', mask, g.value[r]);
        const char *sep = "";
        for (int bit = 0; bit < 32; bit++) {
            if (!(mask & (0x80000000u >> bit))) continue;
            const char *nm = bit_name((int)reg, bit);
            if (nm) fprintf(stderr, "%s%s", sep, nm);
            else    fprintf(stderr, "%sbit %d", sep, bit);
            sep = ", ";
        }
        fprintf(stderr, "\n");
    }
}

void discretes_poll(void) {
    if (!g.open) return;
    uint8_t buf[64];
    for (;;) {
        ssize_t n = recv(g.fd, buf, sizeof buf, 0);
        if (n <= 0) {
            /* EAGAIN/EWOULDBLOCK: nothing more waiting. */
            break;
        }
        apply(buf, (size_t)n);
    }
}

void discretes_publish(int reg, uint32_t mask, bool on) {
    if (!g.open || mask == 0u) return;
    int r = reg_index(reg);
    g.selfDriven[r] |= mask;

    uint8_t b[WORDS * 2];
    unsigned op = on ? OP_SET : OP_RESET;
    b[0] = (uint8_t)(op >> 8);   b[1] = (uint8_t)op;
    b[2] = (uint8_t)(reg >> 8);  b[3] = (uint8_t)reg;
    b[4] = (uint8_t)(mask >> 24); b[5] = (uint8_t)(mask >> 16);
    b[6] = (uint8_t)(mask >> 8);  b[7] = (uint8_t)mask;
    (void)sendto(g.fd, b, sizeof b, 0,
                 (struct sockaddr *)&g.group, sizeof g.group);
}

uint32_t discretes_driven_mask(int reg) {
    if (!g.open) return 0u;
    int r = reg_index(reg);
    double now = yagpc_monotonic_seconds();
    uint32_t m = 0u;
    for (int bit = 0; bit < 32; bit++) {
        double t = g.lastSeen[r][bit];
        if (t > 0.0 && (now - t) <= g.staleSec) m |= (0x80000000u >> bit);
    }
    /* Our own multicast comes back to us, being a member of the group.
     * Honouring it would replace a device's in-process state with the
     * same state a socket round trip later -- worse in every way, and
     * nondeterministic besides. */
    return m & ~g.selfDriven[r];
}

uint32_t discretes_value(int reg) {
    if (!g.open) return 0u;
    return g.value[reg_index(reg)];
}
