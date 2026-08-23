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

/* Multicast loopback is ON (the reference's Bus turns it on too), so
 * every datagram this process sends comes straight back to its own
 * socket -- and for a shuttle bus it carries the very IUA byte the
 * receive filter accepts.  Read back as a peripheral's reply, it
 * desynchronises the bus program by one word and every transaction
 * after it, so our own copies have to be told apart from a peer's.
 *
 * They are told apart by WHO SENT THEM, not by what they contain:
 * sending from a separate socket on an ephemeral port makes every
 * datagram of ours arrive with that port as its source, which nothing
 * else on the host can be using.  Attribution is then exact.
 *
 * The reference instead matches the bytes, and this did too until the
 * DK bus showed why that cannot work here.  A display unit answers a
 * poll with ONE halfword -- 0x0009 -- while a display fill puts 511
 * halfwords on the bus as 511 separate datagrams, most of them 0x0000
 * and one of them, in the time fill, 0x0001.  A one-word reply is
 * therefore byte-identical to words we ourselves just sent, and the
 * filter ate it: measured over one run, 13 of 78 poll replies survived.
 * The receive at 035a2 then never completed, the BCE error-terminated
 * every cycle, and the display got one buffer of seven.  The bytes
 * simply do not carry enough information to attribute a short reply;
 * the source port does.
 *
 * The byte-exact list below is KEPT as a fallback for the case where
 * the transmit socket could not be created, where sends fall back to
 * the receive socket and our copies do come back on the bus port. */
#define SELF_ECHO_MAX 1024

typedef struct {
    unsigned char *bytes;
    size_t len;
} SelfEchoEntry;

typedef struct {
    int busID;
    int fd;     /* receive socket, bound to the bus port; -1 = closed */
    int txFd;   /* transmit socket, bound to an EPHEMERAL port; -1 = none */
    uint16_t txPort;   /* the port the kernel gave txFd, in host order */
    SelfEchoEntry selfEcho[SELF_ECHO_MAX];
    int selfEchoCount;
} BceNetBusSocket;

/* Remember a datagram we just sent, so the loopback copy can be dropped. */
static void self_echo_note_sent(BceNetBusSocket *b, const unsigned char *buf, size_t len) {
    unsigned char *copy = malloc(len ? len : 1);
    if (!copy) return;   /* out of memory: worst case we hear our own echo */
    memcpy(copy, buf, len);
    if (b->selfEchoCount == SELF_ECHO_MAX) {
        free(b->selfEcho[0].bytes);
        memmove(&b->selfEcho[0], &b->selfEcho[1],
                sizeof b->selfEcho[0] * (SELF_ECHO_MAX - 1));
        b->selfEchoCount--;
    }
    b->selfEcho[b->selfEchoCount].bytes = copy;
    b->selfEcho[b->selfEchoCount].len = len;
    b->selfEchoCount++;
}

/* Is this datagram one of ours coming back?  Consumes the match. */
static bool self_echo_is_ours(BceNetBusSocket *b, const unsigned char *buf, size_t len) {
    for (int i = 0; i < b->selfEchoCount; i++) {
        if (b->selfEcho[i].len == len && memcmp(b->selfEcho[i].bytes, buf, len) == 0) {
            free(b->selfEcho[i].bytes);
            memmove(&b->selfEcho[i], &b->selfEcho[i + 1],
                    sizeof b->selfEcho[0] * (size_t)(b->selfEchoCount - i - 1));
            b->selfEchoCount--;
            return true;
        }
    }
    return false;
}

static void self_echo_clear(BceNetBusSocket *b) {
    for (int i = 0; i < b->selfEchoCount; i++) free(b->selfEcho[i].bytes);
    b->selfEchoCount = 0;
}

struct BceNetTransport {
    BceNetBusSocket buses[BCENET_MAX_BUS_ID + 1];
};

BceNetTransport *bcenet_transport_create(void) {
    BceNetTransport *t = malloc(sizeof(BceNetTransport));
    for (int i = 0; i <= BCENET_MAX_BUS_ID; i++) {
        t->buses[i].busID = i;
        t->buses[i].fd = -1;
        t->buses[i].txFd = -1;
        t->buses[i].txPort = 0;
        t->buses[i].selfEchoCount = 0;
    }
    return t;
}

void bcenet_transport_free(BceNetTransport *t) {
    if (!t) return;
#ifdef BCENET_HAVE_POSIX_SOCKETS
    for (int i = 0; i <= BCENET_MAX_BUS_ID; i++) {
        if (t->buses[i].fd >= 0) close(t->buses[i].fd);
        if (t->buses[i].txFd >= 0) close(t->buses[i].txFd);
        self_echo_clear(&t->buses[i]);
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
    /* Ask for a generous receive buffer.  A datagram that arrives with
     * the buffer full is DROPPED -- UDP has no retransmission, so a
     * peripheral's reply sent while this process was not reading is gone
     * for good.  A big buffer absorbs ordinary jitter (a scheduling
     * hiccup, a slow trace write); it cannot absorb a debugger halt, and
     * nothing at this layer can.  That case is handled the only way it
     * can be, by not pretending the lost milliseconds still owe us
     * anything -- see rtpacer.h's STALL_REBASE_MS.  Advisory: the kernel
     * may cap this, and the call is deliberately not fatal. */
    int rcvbuf = 1 << 20;   /* 1 MiB */
    setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &rcvbuf, sizeof rcvbuf);

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

    /* The interface MUST be pinned, both for the join and for sends.
     * Joining the group without naming one can have the host deliver
     * every datagram TWICE -- and then the self-echo filter below
     * consumes one copy and passes the other, so this emulator reads its
     * own transmission back as if it were the peripheral's reply, which
     * desynchronises the bus program by one word and every transaction
     * after it.  That was observed here on the DK bus: 1- and 2-word
     * "receives" carrying our own TIME_FILL and DISPLAY_FILL command
     * words.  Every LRU is a process on this machine, so the default is
     * loopback; NSTS_BUS_IFACE takes a local address to run a bus across
     * a real network instead, exactly as the reference's own Bus.IFACE
     * does. */
    const char *ifaceStr = getenv("NSTS_BUS_IFACE");
    if (ifaceStr == NULL) ifaceStr = "127.0.0.1";
    struct in_addr iface;
    iface.s_addr = inet_addr(ifaceStr);
    if (iface.s_addr == INADDR_NONE) iface.s_addr = htonl(INADDR_ANY);
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_IF, &iface, sizeof iface);

    struct ip_mreq mreq = {0};
    mreq.imr_multiaddr.s_addr = inet_addr(BCENET_MULTICAST_GROUP);
    mreq.imr_interface.s_addr = iface.s_addr;
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

    /* A SEPARATE socket for transmitting, bound to an ephemeral port.
     * Its only purpose is to give our own datagrams a return address no
     * other process on this host shares, so the loopback copies can be
     * dropped on identity rather than on content -- see the self-echo
     * comment above.  The destination is unchanged, so peers receive
     * exactly what they did before; only the source port differs, and
     * nothing in the protocol looks at it.
     *
     * Not fatal if it fails: sends fall back to the receive socket and
     * the byte-exact filter, which is what this did before. */
    b->txFd = -1;
    b->txPort = 0;
    int txFd = socket(AF_INET, SOCK_DGRAM, 0);
    if (txFd >= 0) {
        struct sockaddr_in txAddr = {0};
        txAddr.sin_family = AF_INET;
        txAddr.sin_addr.s_addr = iface.s_addr;
        txAddr.sin_port = htons(0);   /* let the kernel choose */
        if (bind(txFd, (struct sockaddr *)&txAddr, sizeof txAddr) == 0) {
            struct sockaddr_in bound = {0};
            socklen_t boundLen = sizeof bound;
            if (getsockname(txFd, (struct sockaddr *)&bound, &boundLen) == 0) {
                setsockopt(txFd, IPPROTO_IP, IP_MULTICAST_IF, &iface, sizeof iface);
                setsockopt(txFd, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof loop);
                setsockopt(txFd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof ttl);
                b->txFd = txFd;
                b->txPort = ntohs(bound.sin_port);
            }
        }
        if (b->txFd < 0) close(txFd);
    }
    if (b->txFd < 0) {
        fprintf(stderr, "bcenet: bus %d: no separate transmit socket; "
                        "falling back to byte-exact self-echo filtering\n", busID);
    }
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
    /* Only the fallback path needs the byte-exact record: when we have a
     * transmit socket, the loopback copy is identified by its port. */
    int sendFd = (b->txFd >= 0) ? b->txFd : b->fd;
    if (b->txFd < 0) self_echo_note_sent(b, buf, len);
    ssize_t sent = sendto(sendFd, buf, len, 0, (struct sockaddr *)&dest, sizeof dest);
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
    struct sockaddr_in from;
    socklen_t fromLen = sizeof from;
    ssize_t n = recvfrom(b->fd, buf, sizeof buf, 0, (struct sockaddr *)&from, &fromLen);
    if (n < 0) {
        if (errno != EAGAIN && errno != EWOULDBLOCK) {
            fprintf(stderr, "bcenet: bus %d: recv failed: %s\n", busID, strerror(errno));
        }
        return false;
    }
    /* Ours if it came from our own transmit socket -- exact, and it
     * cannot mistake a peripheral's one-word reply for our own data. */
    bool mine = (b->txFd >= 0 && ntohs(from.sin_port) == b->txPort);
    if (!mine && b->txFd < 0) mine = self_echo_is_ours(b, buf, (size_t)n);
    /* One line per datagram, env-gated: which bus, whose it was, and the
     * leading words.  This is how the self-echo filter was caught eating
     * the display unit's poll replies, and the same view is what any
     * future "the peripheral never answered" question needs. */
    if (getenv("YAGPC_BUSTRACE")) {
        fprintf(stderr, "BUSRX bus%-3d %s from %s:%-5u  %2zd bytes ",
                busID, mine ? "ECHO" : "KEEP", inet_ntoa(from.sin_addr),
                (unsigned)ntohs(from.sin_port), n);
        for (ssize_t i = 0; i + 1 < n && i < 12; i += 2)
            fprintf(stderr, "%02x%02x ", buf[i], buf[i + 1]);
        fprintf(stderr, "\n");
    }
    if (mine) return false;
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
