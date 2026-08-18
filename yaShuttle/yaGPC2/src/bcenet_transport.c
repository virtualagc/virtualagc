/* See bcenet_transport.h. POSIX sockets only -- this project's Makefile
 * targets Linux for `gpc run`'s own test environment, and this is a new,
 * optional (`--bce-network`-gated) feature, not something any existing
 * fixture or Windows build path depends on. A Windows (Winsock2) port is
 * real future work (see NMakefile's own existing HAVE_POSIX_TIMERS-style
 * precedent for how this project handles a POSIX-only feature: fail
 * loudly at the call site that would need it, not silently do nothing --
 * bcenet_transport_open_bus() below follows the same discipline via the
 * #else branch's hard error). */
#ifndef _WIN32
#define _DEFAULT_SOURCE /* struct ip_mreq under -std=c11's strict mode */
#endif

#include "bcenet_transport.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef _WIN32
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#define BCENET_HAVE_POSIX_SOCKETS 1
#endif

#define BCENET_MULTICAST_GROUP "239.255.1.1"
#define BCENET_MAX_BUS_ID 24

/* Mirrors nsts-sim-gpc/com/bus.civet's busConfig table -- only the
 * gpcBceNum-mapped entries (the ones a real BCE number can address).
 * IC1-5=1-5, DK1-4=6-9 (MEDS/IDP -- this bridge's own initial target),
 * PL1-2=10-11, LB1-2=12-13, FC5-8=14-17, MM1-2=18-19, FC1-4=20-23.
 * BCE 24 ("IP") is deliberately NOT included here: bus.civet gives it a
 * DIFFERENT port per GPC instance (IP1..IP5, ports 6924-6927), which
 * needs a GPC-identity parameter this table doesn't have -- out of scope
 * until something actually needs BCE 24; bcenet_transport_open_bus()
 * fails (logged, not fatal) for it rather than guessing a port. */
static const int BCENET_BUS_PORT[BCENET_MAX_BUS_ID + 1] = {
    [1] = 6901,  [2] = 6902,  [3] = 6903,  [4] = 6904,  [5] = 6905,  /* IC1-5 */
    [6] = 6906,  [7] = 6907,  [8] = 6908,  [9] = 6909,               /* DK1-4 */
    [10] = 6910, [11] = 6911,                                        /* PL1-2 */
    [12] = 6912, [13] = 6913,                                        /* LB1-2 */
    [14] = 6914, [15] = 6915, [16] = 6916, [17] = 6917,               /* FC5-8 */
    [18] = 6918, [19] = 6919,                                        /* MM1-2 */
    [20] = 6920, [21] = 6921, [22] = 6922, [23] = 6923,               /* FC1-4 */
};

typedef struct {
    int busID;
    int fd; /* -1 = closed */
} BceNetBusSocket;

struct BceNetTransport {
    BceNetBusSocket buses[BCENET_MAX_BUS_ID + 1];
};

BceNetTransport *bcenet_transport_create(void) {
    BceNetTransport *t = malloc(sizeof(BceNetTransport));
    for (int i = 0; i <= BCENET_MAX_BUS_ID; i++) {
        t->buses[i].busID = i;
        t->buses[i].fd = -1;
    }
    return t;
}

void bcenet_transport_free(BceNetTransport *t) {
    if (!t) return;
#ifdef BCENET_HAVE_POSIX_SOCKETS
    for (int i = 0; i <= BCENET_MAX_BUS_ID; i++) {
        if (t->buses[i].fd >= 0) close(t->buses[i].fd);
    }
#endif
    free(t);
}

static BceNetBusSocket *find_bus(BceNetTransport *t, int busID) {
    if (busID < 0 || busID > BCENET_MAX_BUS_ID) return NULL;
    return &t->buses[busID];
}

bool bcenet_transport_open_bus(BceNetTransport *t, int busID) {
    BceNetBusSocket *b = find_bus(t, busID);
    if (!b) {
        fprintf(stderr, "bcenet: bus %d out of range (1-%d)\n", busID, BCENET_MAX_BUS_ID);
        return false;
    }
    if (b->fd >= 0) return true; /* already open */

    int port = BCENET_BUS_PORT[busID];
    if (port == 0) {
        fprintf(stderr, "bcenet: bus %d has no known port mapping (see BCENET_BUS_PORT)\n", busID);
        return false;
    }

#ifndef BCENET_HAVE_POSIX_SOCKETS
    (void)port;
    fprintf(stderr, "bcenet: --bce-network requires POSIX sockets, not available in this build\n");
    return false;
#else
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        fprintf(stderr, "bcenet: bus %d: socket() failed: %s\n", busID, strerror(errno));
        return false;
    }

    int reuse = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse) < 0) {
        fprintf(stderr, "bcenet: bus %d: SO_REUSEADDR failed: %s\n", busID, strerror(errno));
        close(fd);
        return false;
    }

    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)port);
    if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0) {
        fprintf(stderr, "bcenet: bus %d: bind(port %d) failed: %s\n", busID, port, strerror(errno));
        close(fd);
        return false;
    }

    struct ip_mreq mreq = {0};
    mreq.imr_multiaddr.s_addr = inet_addr(BCENET_MULTICAST_GROUP);
    mreq.imr_interface.s_addr = htonl(INADDR_ANY);
    if (setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof mreq) < 0) {
        fprintf(stderr, "bcenet: bus %d: IP_ADD_MEMBERSHIP failed: %s\n", busID, strerror(errno));
        close(fd);
        return false;
    }

    /* Loopback so a same-host peer (e.g. a test harness, or nsts-sim-gpc
     * running locally) sees our own sends -- matches Bus's own
     * setMulticastLoopback(true). */
    int loop = 1;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof loop);

    unsigned char ttl = 128; /* matches Bus's own setMulticastTTL(128) */
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof ttl);

    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);

    b->fd = fd;
    return true;
#endif
}

#ifdef BCENET_HAVE_POSIX_SOCKETS
static struct sockaddr_in bcenet_group_addr(int port) {
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(BCENET_MULTICAST_GROUP);
    addr.sin_port = htons((uint16_t)port);
    return addr;
}
#endif

bool bcenet_transport_send(BceNetTransport *t, int busID, int iua, bool isShuttleBus, const uint16_t *words,
                            size_t wordCount) {
    BceNetBusSocket *b = find_bus(t, busID);
    if (!b || b->fd < 0) return false;
#ifndef BCENET_HAVE_POSIX_SOCKETS
    (void)iua;
    (void)isShuttleBus;
    (void)words;
    (void)wordCount;
    return false;
#else
    size_t headerLen = isShuttleBus ? 2 : 0;
    size_t len = headerLen + wordCount * 2;
    unsigned char *buf = malloc(len);
    if (isShuttleBus) {
        buf[0] = (unsigned char)iua;
        buf[1] = 0; /* reserved; the real Bus class leaves this uninitialized and
                     * receivers never look at it -- see bcenet_transport.h. */
    }
    for (size_t i = 0; i < wordCount; i++) {
        uint16_t w = words[i];
        buf[headerLen + i * 2] = (unsigned char)(w >> 8);
        buf[headerLen + i * 2 + 1] = (unsigned char)(w & 0xff);
    }
    struct sockaddr_in dest = bcenet_group_addr(BCENET_BUS_PORT[busID]);
    ssize_t sent = sendto(b->fd, buf, len, 0, (struct sockaddr *)&dest, sizeof dest);
    free(buf);
    if (sent < 0 || (size_t)sent != len) {
        fprintf(stderr, "bcenet: bus %d: sendto failed: %s\n", busID, strerror(errno));
        return false;
    }
    return true;
#endif
}

bool bcenet_transport_recv(BceNetTransport *t, int busID, int iua, bool isShuttleBus, uint16_t *outWords,
                            size_t maxWords, size_t *outCount) {
    BceNetBusSocket *b = find_bus(t, busID);
    if (!b || b->fd < 0) return false;
#ifndef BCENET_HAVE_POSIX_SOCKETS
    (void)iua;
    (void)isShuttleBus;
    (void)outWords;
    (void)maxWords;
    (void)outCount;
    return false;
#else
    /* 2-byte header + up to 1024 words -- was 64 ("32 words max per the
     * 5-bit count field convention, room to spare"), wrong: a real
     * DK-bus DATA FILL message relays a whole display frame buffer,
     * hundreds of words (#TDLI's own count field is 18 bits, not 5 --
     * see bcenet_framer.h's own updated comment). Matches
     * FRAMER_MAX_WORDS in bcenet_framer.c. */
    unsigned char buf[2 + 1024 * 2];
    ssize_t n = recv(b->fd, buf, sizeof buf, 0);
    if (n < 0) {
        if (errno != EAGAIN && errno != EWOULDBLOCK) {
            fprintf(stderr, "bcenet: bus %d: recv failed: %s\n", busID, strerror(errno));
        }
        return false;
    }
    size_t headerLen = isShuttleBus ? 2 : 0;
    if ((size_t)n < headerLen) return false;
    if (isShuttleBus && buf[0] != (unsigned char)iua) {
        return false; /* not addressed to us -- matches Bus#_recvMessage's own filter */
    }
    size_t dataLen = (size_t)n - headerLen;
    size_t wordCount = dataLen / 2;
    if (wordCount > maxWords) {
        fprintf(stderr, "bcenet: bus %d: received %zu words, only room for %zu -- truncated\n", busID, wordCount,
                maxWords);
        wordCount = maxWords;
    }
    for (size_t i = 0; i < wordCount; i++) {
        outWords[i] = (uint16_t)((buf[headerLen + i * 2] << 8) | buf[headerLen + i * 2 + 1]);
    }
    *outCount = wordCount;
    return true;
#endif
}
