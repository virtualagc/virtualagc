/* Receiving side of the GPC discrete-input bus; see discretes.h. */
#define _DEFAULT_SOURCE /* struct ip_mreq under -std=c11's strict mode */
#if defined(__linux__)
#define _GNU_SOURCE     /* recvmmsg() -- see discretes_poll()'s drain */
#define DISCRETES_HAVE_RECVMMSG 1
/* 32 datagrams: more than a four-GPC set puts on the wire between two
 * polls, so the common drain is one syscall, and small enough that the
 * descriptor arrays stay in cache. */
#define DISCRETES_RECV_BATCH 32
#endif

#include "discretes.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "compat.h"

#include "envcache.h"
#define DISCRETES_GROUP "239.255.1.1"
/* One base for every bus socket in the process; see discretes.h.  Read
 * from NSTS_BUS_PORT_BASE if --port-base was not given, so a shell that
 * exports it once configures the whole instance. */
static int g_portBase = -1;

void yagpc_set_port_base(int base) { g_portBase = base; }

int yagpc_port_base(void) {
    if (g_portBase < 0) {
        const char *w = yagpc_getenv("NSTS_BUS_PORT_BASE");
        char *end = NULL;
        long v = (w != NULL && *w != '\0') ? strtol(w, &end, 10) : -1;
        g_portBase = (end != NULL && *end == '\0' && v > 0 && v < 65536 - 100)
                         ? (int)v : YAGPC_PORT_BASE_DEFAULT;
    }
    return g_portBase;
}

/* Which of the five GPCs this process is.  Only the intercomputer bus
 * (BCE 24) needs it: every other bus has one port shared by all GPCs,
 * but IP is per-GPC, so the BCE number alone does not name a port. */
static int g_gpcId = -1;

void yagpc_set_gpc_id(int id) { g_gpcId = (id >= 1 && id <= 5) ? id : 1; }

int yagpc_gpc_id(void) {
    if (g_gpcId < 0) {
        const char *w = yagpc_getenv("NSTS_GPC_ID");
        char *end = NULL;
        long v = (w != NULL && *w != '\0') ? strtol(w, &end, 10) : -1;
        g_gpcId = (end != NULL && *end == '\0' && v >= 1 && v <= 5) ? (int)v : 1;
    }
    return g_gpcId;
}

/* A CHANNEL PER COMPUTER, port 6980 + GPC ID (nsts-sim-gpc 7946bc1), so
 * all five GPCs can run at once without hearing each other's switches.  A
 * device wired to every computer -- a mass memory's READY -- drives them
 * all by publishing on each. */
#define DISCRETES_PORT_FOR(gpc) \
    (yagpc_port_base() + YAGPC_DISCRETES_OFFSET + (gpc))

#define OP_SET     1
#define OP_RESET   2
/* nsts-sim-gpc 7946bc1: anyone may ask the GPC for a register's whole
 * current value, and the GPC -- which holds it -- is the only sender of
 * the answer.  This replaces re-broadcasting on a timer: a process that
 * attaches late asks instead of waiting to overhear. */
#define OP_REQUEST 3
#define OP_VALUE   4

#define WORDS 4

/* One bus, so one instance.  Kept here rather than in IOP because it is a
 * property of the process's connection to the outside world, not of the
 * emulated machine -- the same reason the bus transport keeps its own. */
/* Names for the bits, so YAGPC_DISCRETETRACE reads as something a person
 * can follow rather than a hex mask.  From the IOP Principles of
 * Operation, as laid out in iop.c's own discrete-input comment. */
static const char *bit_name(int reg, int bit) {
    if (reg == DISCRETES_REG_FAILVOTE) {
        /* One row of the GPC STATUS matrix, five bits wide, and ROTATED --
         * "N+k" is the computer k places along from this one, not GPC k.
         * See DISCRETES_REG_FAILVOTE in discretes.h. */
        switch (bit) {
            case 27: return "inhibit fail discrete outputs";
            case 28: return "fail vote N+1"; case 29: return "fail vote N+2";
            case 30: return "fail vote N+3"; case 31: return "fail vote N+4";
            default: return NULL;
        }
    }
    if (reg == DISCRETES_REG_CFAIL)
        return (bit == 31) ? "computer fail (CAM diagonal)" : NULL;
    if (reg == DISCRETES_REG_OUT) {
        switch (bit) {
            case 7: return "I/O active tb"; case 9: return "READY tb";
            case 12: return "MM1 reset";    case 13: return "MM2 reset";
            case 20: return "STBY out";     case 22: return "BFS RUN out";
            case 24: return "RUN out";      case 28: return "SYNC out";
            case 30: return "ID source";    case 31: return "IPL out";
            default: return NULL;
        }
    }
    if (reg == DISCRETES_REG_A) {
        switch (bit) {
            case 0: return "HALT";        case 1: return "STANDBY";
            case 2: return "RUN";         case 3: return "IPL";
            case 4: return "MM1 IPL src"; case 5: return "MM2 IPL src";
            case 6: return "MM1 READY";   case 7: return "MM2 READY";
            /* THE INTER-GPC LINES, numbered N+1..N+4 relative to THIS
             * computer: "the wiring rotates, so N+1 at gpc 1 is gpc 2 and
             * N+1 at gpc 5 is gpc 1" (BILDNEW5.asm's own table, and
             * nsts-sim-gpc com/discretes.coffee).  The STBY/RUN/SYNC groups
             * are not three signals but one 3-bit code per neighbour -- see
             * discretes_rotate_out. */
            case 8: return "BFS RUN N+1";  case 9: return "BFS RUN N+2";
            case 10: return "BFS RUN N+3"; case 11: return "BFS RUN N+4";
            case 12: return "IOP term A"; case 13: return "IOP term B";
            case 15: return "dump request";
            case 20: return "STBY N+1";   case 21: return "STBY N+2";
            case 22: return "STBY N+3";   case 23: return "STBY N+4";
            case 24: return "RUN N+1";    case 25: return "RUN N+2";
            case 26: return "RUN N+3";    case 27: return "RUN N+4";
            case 28: return "SYNC N+1";   case 29: return "SYNC N+2";
            case 30: return "SYNC N+3";   case 31: return "SYNC N+4";
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

struct Discretes {
    int gpcId;
    int fd;
    bool open;
    bool trace;
    unsigned long messages;
    double staleSec;
    /* Index 0 is register A, 1 is B, 2 the output register, 3 the fail
     * discretes and 4 the computer fail lamp -- see reg_index(). */
    uint32_t value[5];
    /* What this GPC believes each register's whole value to be, which is
     * what a REQUEST is answered with.  For A and B that is the combination
     * of locally derived and published bits, which only iop.c can form. */
    uint32_t canonical[5];
    /* INPUT BITS WIRED IN PROCESS, per register: a neighbour in this same
     * vehicle writes them directly (vehicle_route_out), so a datagram for
     * them is a late copy of something already applied.  See apply(). */
    uint32_t localWired[5];
    /* When each bit was last published.  Per BIT, not per register: a
     * crew panel republishing the switches must not make a departed mass
     * memory's READY look fresh. */
    double lastSeen[5][32];
    /* Bits this process drives itself, which it must not then treat as
     * externally driven -- see discretes.h. */
    uint32_t selfDriven[5];
    struct sockaddr_in group;
    unsigned generation;  /* see discretes_generation() */
    unsigned pollCalls;   /* the poll rate-limiter, per machine */
    /* THE ATTENTIVE CLOCK -- see attend().  Staleness is measured in this,
     * not in wall time. */
    double attentive;
    unsigned attendCalls;   /* see attend() */
    double lastAttendSec;
#ifdef HAVE_PTHREADS
    /* Held only around a register update.  The owning machine writes these
     * from its own thread; discretes_apply_external lets ANOTHER machine's
     * thread do it too, which is what the inter-GPC lines need. */
    pthread_mutex_t lock;
#endif
    DiscretesOutFn outHook;
    void *outHookCtx;
    double lastPollSec;
    double simUs;                /* this machine's clock, noted per instruction */
    /* YAGPC_SYNCTRACE: the last code seen going out, and the last seen
     * arriving from each of the four neighbours.  8 is "nothing yet", which
     * no real code is, so the first of each always prints. */
    unsigned syncOutLast;
    unsigned syncInLast[5];
    /* THE CONVERSATION, KEPT BUT NOT PRINTED.  A full YAGPC_SYNCTRACE is
     * 2.4 million lines for a ten-minute run and slows the vehicle enough
     * that the race in #190 stops happening -- the instrument destroys what
     * it measures.  These are the same events, recorded into a ring at a
     * few stores each and printed only when a computer actually declares a
     * failure, which is the one moment the history is wanted. */
    struct SyncEvent {
        double t;
        /* AND THE SIMULATED TIME, because the deadline the flight software
         * measures is in ITS clock, not the host's.  A wall stamp orders
         * events; only this one can say whether a wait outran a timeout. */
        double sim;
        unsigned char kind;      /* 0 = this machine speaking, 1 = hearing */
        unsigned char who;       /* the neighbour's GPC id, for kind 1 */
        unsigned char code;
        uint32_t a;
        uint32_t driven;
        uint32_t x;              /* kind 4: parameter-list halfwords */
    } *hist;
    size_t histSize, histHead, histCount;
};

static int reg_index(int reg) {
    if (reg == DISCRETES_REG_B) return 1;
    if (reg == DISCRETES_REG_OUT) return 2;
    if (reg == DISCRETES_REG_FAILVOTE) return 3;
    if (reg == DISCRETES_REG_CFAIL) return 4;
    return 0;
}

static bool reg_known(int reg) {
    return reg == DISCRETES_REG_A || reg == DISCRETES_REG_B ||
           reg == DISCRETES_REG_OUT || reg == DISCRETES_REG_FAILVOTE ||
           reg == DISCRETES_REG_CFAIL;
}

bool discretes_enabled(const Discretes *d) { return d != NULL && d->open; }
unsigned long discretes_message_count(const Discretes *d) { return d ? d->messages : 0; }

/* Bumped whenever a datagram changes the bus state, or this process drives a
 * line.  Lets a caller cache what it derived from the bus instead of
 * re-deriving it on every read -- see iop_discrete_overlay(). */
unsigned discretes_generation(const Discretes *d) { return d ? d->generation : 0; }

Discretes *discretes_create(int gpcId) {
    Discretes *d = (Discretes *)calloc(1, sizeof *d);
    if (d == NULL) return NULL;
    d->gpcId = gpcId;
    d->fd = -1;
    /* NOT what the zeroing leaves: 000 is a real sync code (dead/halt/
     * standby), and the very first thing a computer says is usually exactly
     * that, so a "last seen" of 0 would swallow it. */
    d->syncOutLast = 8u;
    for (int k = 0; k < 5; k++) d->syncInLast[k] = 8u;
    {
        /* YAGPC_SYNC_HISTORY=N keeps the last N sync events per computer.
         * Off by default: a run that is not investigating #190 should carry
         * nothing, and 4096 events is about a second of conversation, which
         * is ample either side of a 3.85 ms timeout. */
        const char *e = yagpc_getenv("YAGPC_SYNC_HISTORY");
        long n = (e != NULL && *e != '\0') ? atol(e) : 0;
        if (n > 0) {
            if (n > 1000000L) n = 1000000L;
            d->hist = calloc((size_t)n, sizeof *d->hist);
            d->histSize = d->hist != NULL ? (size_t)n : 0;
        }
    }
    /* THE ATTENTIVE CLOCK STARTS AT ONE, not at zero.  lastSeen uses 0.0 to
     * mean "this bit has never been published", so a clock that began at 0
     * would stamp the very first datagram with the never-seen sentinel and
     * the bit would not count as driven until the clock had moved on. */
    d->attentive = 1.0;
#ifdef HAVE_PTHREADS
    pthread_mutex_init(&d->lock, NULL);
#endif

    /* Publishers repeat themselves several times a second, so tracing
     * every message would be noise: only a message that actually CHANGES
     * a register prints. */
    d->trace = yagpc_getenv("YAGPC_DISCRETETRACE") != NULL;

    d->staleSec = DISCRETES_STALE_SEC;
    const char *s = yagpc_getenv("YAGPC_DISCRETES_STALE_SEC");
    if (s != NULL) {
        double v = atof(s);
        if (v > 0.0) d->staleSec = v;
    }

    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        fprintf(stderr, "discretes: socket failed: %s\n", strerror(errno));
        free(d);
        return NULL;
    }

    int reuse = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse) < 0) {
        fprintf(stderr, "discretes: SO_REUSEADDR failed: %s\n", strerror(errno));
        close(fd);
        free(d);
        return NULL;
    }

    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)DISCRETES_PORT_FOR(d->gpcId));
    if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0) {
        fprintf(stderr, "discretes: bind(port %d) failed: %s\n",
                DISCRETES_PORT_FOR(d->gpcId), strerror(errno));
        close(fd);
        free(d);
        return NULL;
    }

    /* Pin the interface, for the same reason bcenet_transport.c does:
     * joining without naming one can have the host deliver every datagram
     * twice.  Every LRU is a process on this machine, so loopback by
     * default; NSTS_BUS_IFACE runs the bus across a real network, exactly
     * as the reference's Bus.IFACE does. */
    const char *ifaceStr = yagpc_getenv("NSTS_BUS_IFACE");
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
        free(d);
        return NULL;
    }

    int loop = 1;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof loop);
    int ttl = 128;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof ttl);

    /* Where discretes_publish sends.  Same socket: it is already pinned to
     * the interface and in the group, and a device driving a line is a peer
     * on this bus like any other. */
    d->group.sin_family = AF_INET;
    d->group.sin_addr.s_addr = inet_addr(DISCRETES_GROUP);
    d->group.sin_port = htons((uint16_t)DISCRETES_PORT_FOR(d->gpcId));

    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);

    d->fd = fd;
    d->open = true;
    return d;
}

void discretes_free(Discretes *d) {
#ifdef HAVE_PTHREADS
    if (d != NULL) pthread_mutex_destroy(&d->lock);
#endif
    if (d == NULL) return;
    if (d->open) close(d->fd);
    free(d);
}

int discretes_gpc_id(const Discretes *d) { return d ? d->gpcId : 0; }

/* See discretes.h.  The four output lines and where each lands, given the
 * neighbour index k: the group's base bit plus (k - 1). */
uint32_t discretes_rotate_out(int sourceGpc, int readerGpc, uint32_t outMask) {
    static const struct { int outBit, inBase; } WIRE[] = {
        { 20, 20 },   /* STBY    -> STBY N+k    */
        { 22,  8 },   /* BFS RUN -> BFS RUN N+k */
        { 24, 24 },   /* RUN     -> RUN N+k     */
        { 28, 28 },   /* SYNC    -> SYNC N+k    */
    };
    if (sourceGpc < 1 || sourceGpc > 5 || readerGpc < 1 || readerGpc > 5)
        return 0u;
    int k = (sourceGpc - readerGpc + 5) % 5;
    if (k == 0) return 0u;            /* a computer is not its own neighbour */
    uint32_t in = 0u;
    for (size_t i = 0; i < sizeof WIRE / sizeof WIRE[0]; i++) {
        if (outMask & (0x80000000u >> WIRE[i].outBit))
            in |= 0x80000000u >> (WIRE[i].inBase + (k - 1));
    }
    return in;
}

/* ---------------------------------------------------------------------
 * YAGPC_SYNCTRACE -- what the computers are saying to each other
 *
 * The inter-GPC lines are not four signals but a THREE-BIT CODE, driven on
 * output bits 20, 24 and 28, which the flight software calls A, B and C.
 * Idle is all three set -- TCVTNULS, X'00000888' in MLIB80/TFCVT.asm -- and
 * every sync is issued by RESETTING bits out of that null pattern.  TFCVT
 * names the masks of bits to reset "code-inverse sending patterns", and
 * they are exactly:
 *
 *     TCVTSIPI  X'00000008'   reset C        -> 110  SSIP (common set)
 *     TCVTTIMI  X'00000080'   reset B        -> 101  timer
 *     TCVTSVCI  X'00000088'   reset B and C  -> 100  SVC
 *     TCVTIPRI  X'00000808'   reset A and C  -> 010  input problem report
 *     TCVTIOCI  X'00000880'   reset A and B  -> 001  I/O complete
 *
 * with 111 the null and 000 halt/standby/dead.  Five FCOS programs spin on
 * this waiting for the neighbours to agree, each with a 3.85 ms timeout, and
 * a timeout votes the offending computer out of the set.  So when a
 * redundant set fails to form, what it looks like from outside is a hang
 * with no explanation; this turns it into a conversation one can read.
 * ------------------------------------------------------------------- */

static bool synctrace_on(void) {
    static int init = 0, on = 0;
    if (!init) { init = 1; on = yagpc_getenv("YAGPC_SYNCTRACE") != NULL; }
    return on != 0;
}

/* A=bit 20, B=bit 24, C=bit 28 of whichever register, at the given offset
 * within each group (0 for the output register, k-1 for neighbour k). */
static unsigned sync_code(uint32_t reg, int aBase, int bBase, int cBase, int off) {
    unsigned code = 0;
    if (reg & (0x80000000u >> (aBase + off))) code |= 4u;
    if (reg & (0x80000000u >> (bBase + off))) code |= 2u;
    if (reg & (0x80000000u >> (cBase + off))) code |= 1u;
    return code;
}

static void sync_record(Discretes *d, unsigned char kind, unsigned char who,
                        unsigned char code, uint32_t a, uint32_t driven);
static void sync_record_x(Discretes *d, unsigned char kind, unsigned char who,
                          unsigned char code, uint32_t a, uint32_t driven,
                          uint32_t x);

void discretes_note_io_done(Discretes *d, int bce, bool error) {
    /* WHICH TRANSFER FINISHED WHEN, beside the sync codes.  The 3-CRT vote
     * is one computer reaching an I/O-complete sync after the others have
     * already held and dropped theirs (#190), and the sync codes alone
     * cannot say which transfer was the late one.  Kind 2 is a normal end
     * (the BCE's WAIT), kind 3 an error termination; 'who' is the BCE. */
    if (d == NULL || bce < 0 || bce > 255) return;
    sync_record(d, error ? 3 : 2, (unsigned char)bce, 0, 0u, 0u);
}

void discretes_note_svc(void *ctx, uint32_t psw1, uint32_t ea, uint32_t pl) {
    /* WHICH SVC, AND FROM WHERE.  In every 3-CRT vote so far one computer
     * raised 100 SVC when its three peers raised nothing (#190), so the
     * software on that machine took a path the others did not.  Kind 4
     * records psw1 (the caller, expanded as for FCMSFAIL's R7), the
     * parameter list's address and its first two halfwords. */
    Discretes *d = ctx;
    if (d == NULL || d->hist == NULL) return;
    sync_record_x(d, 4, 0, 0, psw1, ea, pl);
}

void discretes_note_sim_us(Discretes *d, double us) {
    if (d != NULL) d->simUs = us;     /* one store; no lock, no reader races */
}

unsigned discretes_sync_code_out(Discretes *d) {
    if (d == NULL) return 8u;   /* 8 is "no code", as syncOutLast uses it */
    return sync_code(d->value[reg_index(DISCRETES_REG_OUT)], 20, 24, 28, 0);
}

const char *discretes_sync_code_name(unsigned code) {
    switch (code & 7u) {
        case 7: return "null";
        case 6: return "SSIP";
        case 5: return "timer";
        case 4: return "SVC";
        case 3: return "(unassigned)";
        case 2: return "IPR";
        case 1: return "I/O complete";
        default: return "dead/halt/standby";
    }
}

/* Which computer group N+k carries, seen from this one: the wiring rotates,
 * so the inverse of discretes_rotate_out's k = (source - reader) mod 5. */
static int sync_neighbour_gpc(int readerGpc, int k) {
    if (readerGpc < 1 || readerGpc > 5) return 0;
    return ((readerGpc - 1 + k) % 5) + 1;
}

static void sync_record(Discretes *d, unsigned char kind, unsigned char who,
                        unsigned char code, uint32_t a, uint32_t driven) {
    sync_record_x(d, kind, who, code, a, driven, 0u);
}

static void sync_record_x(Discretes *d, unsigned char kind, unsigned char who,
                          unsigned char code, uint32_t a, uint32_t driven,
                          uint32_t x) {
    if (d->hist == NULL || d->histSize == 0) return;
    /* UNDER THE LOCK, because the writers are not one thread.  A neighbour's
     * code is applied to THIS object by the SOURCE machine's thread
     * (vehicle_route_out -> discretes_apply_external_pair), while this
     * machine's own outgoing codes are recorded by its own -- and the trace
     * runs after the register mutex is released, so without this the ring's
     * head is advanced by several threads at once and the record that gets
     * dumped is not the conversation that happened. */
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&d->lock);
#endif
    struct SyncEvent *e = &d->hist[d->histHead];
    e->t = yagpc_monotonic_seconds();
    e->sim = d->simUs;
    e->kind = kind;
    e->who = who;
    e->code = code;
    e->a = a;
    e->driven = driven;
    e->x = x;
    d->histHead = (d->histHead + 1) % d->histSize;
    if (d->histCount < d->histSize) d->histCount++;
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&d->lock);
#endif
}

void discretes_dump_history(Discretes *d, const char *why) {
    if (d == NULL || d->hist == NULL) return;
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&d->lock);
#endif
    if (d->histCount == 0) {
#ifdef HAVE_PTHREADS
        pthread_mutex_unlock(&d->lock);
#endif
        return;
    }
    fprintf(stderr, "SYNCHIST GPC%d %s -- last %zu events, oldest first\n",
            d->gpcId, why != NULL ? why : "", d->histCount);
    size_t start = (d->histHead + d->histSize - d->histCount) % d->histSize;
    for (size_t i = 0; i < d->histCount; i++) {
        const struct SyncEvent *e = &d->hist[(start + i) % d->histSize];
        if (e->kind == 4) {
            /* As FCMSFAIL's R7 is expanded: the NIA is psw1's HIGH
             * halfword, the BSR its bits 24-27 (IBM numbering). */
            uint32_t n = e->a >> 16, caller = (n & 0x8000u)
                ? (((e->a >> 4) & 0xfu) << 15) | (n & 0x7fffu) : n;
            fprintf(stderr, "SYNCHIST GPC%d t=%.6f sim=%.6f svc nia=%05x "
                            "psw1=%08x ea=%05x pl=%04x %04x\n",
                    d->gpcId, e->t, e->sim / 1e6, (unsigned)caller,
                    (unsigned)e->a, (unsigned)e->driven,
                    (unsigned)(e->x >> 16), (unsigned)(e->x & 0xffffu));
        } else if (e->kind == 2 || e->kind == 3)
            fprintf(stderr, "SYNCHIST GPC%d t=%.6f sim=%.6f io BCE%u %s\n",
                    d->gpcId, e->t, e->sim / 1e6, (unsigned)e->who,
                    e->kind == 3 ? "ERROR-TERMINATED" : "done");
        else if (e->kind == 0)
            fprintf(stderr, "SYNCHIST GPC%d t=%.6f sim=%.6f out %u%u%u %s\n",
                    d->gpcId, e->t, e->sim / 1e6,
                    (e->code >> 2) & 1u, (e->code >> 1) & 1u,
                    e->code & 1u, discretes_sync_code_name(e->code));
        else
            fprintf(stderr, "SYNCHIST GPC%d t=%.6f sim=%.6f <- GPC%u %u%u%u %s "
                            "A=%08x driven=%08x\n",
                    d->gpcId, e->t, e->sim / 1e6, (unsigned)e->who,
                    (e->code >> 2) & 1u, (e->code >> 1) & 1u, e->code & 1u,
                    discretes_sync_code_name(e->code),
                    (unsigned)e->a, (unsigned)e->driven);
    }
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&d->lock);
#endif
}

void discretes_synctrace(Discretes *d) {
    if (d == NULL) return;
    bool say = synctrace_on();
    if (!say && d->hist == NULL) return;

    unsigned out = sync_code(d->value[reg_index(DISCRETES_REG_OUT)], 20, 24, 28, 0);
    if (out != d->syncOutLast) {
        d->syncOutLast = out;
        sync_record(d, 0, 0, (unsigned char)out, 0u, 0u);
        if (say)
        fprintf(stderr, "SYNC t=%.6f GPC%d out  %u%u%u %s\n",
                yagpc_monotonic_seconds(), d->gpcId,
                (out >> 2) & 1u, (out >> 1) & 1u, out & 1u,
                discretes_sync_code_name(out));
    }

    uint32_t in = d->value[reg_index(DISCRETES_REG_A)];
    for (int k = 1; k <= 4; k++) {
        unsigned code = sync_code(in, 20, 24, 28, k - 1);
        if (code == d->syncInLast[k]) continue;
        d->syncInLast[k] = code;
        int from = sync_neighbour_gpc(d->gpcId, k);
        sync_record(d, 1, (unsigned char)from, (unsigned char)code, in,
                    discretes_driven_mask(d, DISCRETES_REG_A));
        if (!say) continue;
        /* THE DRIVEN MASK IS PRINTED WITH IT.  The value alone proves only
         * that the bits reached this object; what the CPU reads is the
         * overlay, which passes a bit ONLY if it is also currently driven.
         * A neighbour whose code is in `value` but not in `driven` is
         * invisible to FCMASYNC, and that is not a distinction the decoded
         * code can show. */
        fprintf(stderr, "SYNC t=%.6f GPC%d  <- N+%d (GPC%d)  %u%u%u %s "
                        "A=%08x driven=%08x\n",
                yagpc_monotonic_seconds(), d->gpcId, k,
                from, (code >> 2) & 1u, (code >> 1) & 1u, code & 1u,
                discretes_sync_code_name(code), in,
                discretes_driven_mask(d, DISCRETES_REG_A));
    }
}

void discretes_apply_external(Discretes *d, int reg, uint32_t mask, bool on) {
    if (d == NULL || !d->open || mask == 0u || !reg_known(reg)) return;
    int r = reg_index(reg);
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&d->lock);
#endif
    if (on) d->value[r] |= mask;
    else    d->value[r] &= ~mask;
    for (int bit = 0; bit < 32; bit++)
        if (mask & (0x80000000u >> bit)) d->lastSeen[r][bit] = d->attentive;
    d->messages++;
    d->generation++;
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&d->lock);
#endif
    /* Trace it HERE, where the bits actually land.  The receive-side trace
     * used to run only from this machine's own poll, so it reported the
     * delivery whenever the machine next got round to looking -- which is
     * what made the first measurement of this path look like the path's own
     * latency when it was the instrument's. */
    discretes_synctrace(d);
}

void discretes_apply_external_pair(Discretes *d, int reg, uint32_t setMask,
                                   uint32_t clrMask) {
    if (d == NULL || !d->open || !reg_known(reg)) return;
    if ((setMask | clrMask) == 0u) return;
    int r = reg_index(reg);
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&d->lock);
#endif
    d->value[r] = (d->value[r] | setMask) & ~clrMask;
    uint32_t touched = setMask | clrMask;
    for (int bit = 0; bit < 32; bit++)
        if (touched & (0x80000000u >> bit)) d->lastSeen[r][bit] = d->attentive;
    d->messages++;
    d->generation++;
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&d->lock);
#endif
    discretes_synctrace(d);
}

static void send_msg(Discretes *d, unsigned op, int reg, uint32_t mask);

/* Apply one well-formed message.  Anything else is ignored rather than
 * guessed at, so unrelated traffic on the group cannot corrupt a
 * register. */
static void apply(Discretes *d, const uint8_t *b, size_t n) {
    if (n < WORDS * 2) return;
    unsigned op  = (unsigned)((b[0] << 8) | b[1]);
    unsigned reg = (unsigned)((b[2] << 8) | b[3]);
    if (!reg_known((int)reg)) return;

    uint32_t mask = ((uint32_t)b[4] << 24) | ((uint32_t)b[5] << 16) |
                    ((uint32_t)b[6] << 8) | (uint32_t)b[7];

    /* REQUEST: somebody attached late and is asking what the register
     * holds.  This GPC holds it, and is the only thing that may answer --
     * which is what lets the protocol drop the re-broadcast timer. */
    if (op == OP_REQUEST) {
        send_msg(d, OP_VALUE, (int)reg, d->canonical[reg_index((int)reg)]);
        d->messages++;
        return;
    }
    /* VALUE: only a GPC sends one, and this IS the GPC, so any that
     * arrives is another computer's answer on a channel we should not be
     * hearing.  Ignored rather than applied. */
    if (op == OP_VALUE) return;
    if (op != OP_SET && op != OP_RESET) return;
    int r = reg_index((int)reg);
    /* NOT A LINE THIS PROCESS WIRES DIRECTLY.  A neighbour in the same
     * vehicle writes its code into this register at once, both halves in one
     * step (discretes_apply_external_pair), and ALSO sends the datagram for
     * the benefit of monitors -- which this socket receives too.  Applied
     * here it rewrote the register a second time, late, as two separate
     * halves: an old code, then a half-code, arriving after the neighbour had
     * moved on.  While the socket was drained on every instruction the window
     * was a few instructions wide.  47efdb3f3 gated that drain to every 64th
     * call, the window grew to hundreds of microseconds, and a 4-GPC set
     * began failing to sync at the OPS 2 transition -- every computer voting
     * against GPC1, and GPC1 left commanding both CRTs (bisected 2026-09-19).
     * Datagrams from computers in OTHER processes, and the crew panel's, are
     * unaffected: only bits a neighbour here drives are dropped. */
    mask &= ~d->localWired[r];
    if (mask == 0) return;

    /* UNDER THE LOCK, because this register has more than one writer.  The
     * mask above keeps a datagram off the bits a neighbour drives, but the
     * update is a read-modify-write of the WHOLE word, and the neighbours
     * write that word from their own threads (discretes_apply_external_pair,
     * which does lock).  Unlocked, a datagram for some unrelated bit of input
     * A -- a mass memory's READY -- could read the register just before a
     * neighbour raised its sync code and write the old word back after, and
     * the code was gone.  Losing the raising edge loses the whole pulse, since
     * the lowering edge then changes nothing.  That is the 3-CRT vote (#190):
     * GPC4 never saw GPC3's 200 us 100 SVC, matched its own SVC sync to
     * GPC3's NEXT one, and ran one SVC behind the set until it issued one
     * nobody answered (svc7500-1, 2026-09-21). */
#ifdef HAVE_PTHREADS
    pthread_mutex_lock(&d->lock);
#endif
    uint32_t before = d->value[r];
    if (op == OP_SET) d->value[r] |= mask;
    else              d->value[r] &= ~mask;

    /* Stamped in attentive time, and read back in it -- see attend(). */
    for (int bit = 0; bit < 32; bit++) {
        if (mask & (0x80000000u >> bit)) d->lastSeen[r][bit] = d->attentive;
    }
    d->messages++;
    uint32_t after = d->value[r];
#ifdef HAVE_PTHREADS
    pthread_mutex_unlock(&d->lock);
#endif

    if (d->trace && after != before) {
        /* WHOSE discretes.  With one computer the answer was obvious and the
         * line left it out; with four, a trace of the crew panel's bits is
         * unreadable without it. */
        fprintf(stderr, "DISCRETE GPC%d %-5s %c  %08x  ->  %08x   ", d->gpcId,
                (op == OP_SET) ? "SET" : "RESET",
                (reg == DISCRETES_REG_B) ? 'B' : 'A', mask, after);
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

/* The crew panel's switches move at human speed, but the flight software
 * reads the discrete inputs in tight polling loops -- iop_discrete_overlay()
 * drained this socket on EVERY read, about 11 million recvfrom() calls in a
 * 170 s run.  Draining at most this often still takes several thousand
 * datagrams a second, which is far faster than anything on that bus
 * changes, and costs one clock read instead of a syscall. */
#define DISCRETES_POLL_MIN_SECONDS 250e-6

/* THE MOST ONE GAP MAY AGE THE BUS.
 *
 * "Nobody is driving this bit any more" is a judgement only a listener can
 * make, and this machine does not listen continuously: a firmware IPL fills
 * memory and reads seventy-odd blocks off a tape without once touching the
 * discrete socket, and with two computers sharing a mass memory that takes
 * seconds.  Aged against the wall clock, EVERY bit the crew panel was
 * driving went stale during it -- not because the panel stopped talking but
 * because we stopped listening -- and the backlog then refreshed them a
 * datagram at a time, rebuilding the driven mask in pieces.  The mode switch
 * is read after each of those datagrams (it has to be: a pushbutton is a
 * pulse and draining the whole queue before looking loses it), so it saw
 * incoherent half-states.  One of them was "HALT and IPL, with no source
 * bit driven yet" -- a fresh IPL edge, from a button nobody pressed, reading
 * the default mass memory.  That is gpc-causes #93.
 *
 * So the staleness clock advances by real time while we are listening and
 * by at most this much across a gap when we were not.  It is the same
 * principle the pacer uses for a debugger stall: time spent not running is
 * not time the world may hold against you. */
#define DISCRETES_ATTEND_MAX_STEP 0.05
/* Must be a power of two: attend() masks with ATTEND_SAMPLE-1. */
#define ATTEND_SAMPLE 32u

/* Advance the attentive clock.  Called wherever this machine actually looks
 * at its socket, and nowhere else -- the whole point is that it stops when
 * the machine stops looking. */
static void attend(Discretes *d) {
    /* SAMPLE THE CLOCK, DO NOT READ IT EVERY CALL.
     *
     * discretes_poll_one() is called from mode_switch_held() on the step
     * loop, and it called this unconditionally -- so every pass took a
     * wall-clock reading.  That is cheap where clock_gettime is a vDSO read
     * of the TSC, and ruinous where it is not: on a host whose kernel has
     * fallen back to the hpet clocksource every reading is a full syscall
     * into a memory-mapped timer, and a profile of a one-GPC run put
     * read_hpet at 31% of all cycles with 30% of that arriving through this
     * one line -- against 12% for emulating the AP-101S itself.
     *
     * Sampling every ATTEND_SAMPLE calls does not make `attentive` wrong.
     * It accumulates the GAP between readings, so a gap measured across 32
     * calls is the same elapsed time those 32 calls actually took; only the
     * resolution changes, and the quantity is compared against staleSec,
     * which is seconds.  The existing DISCRETES_ATTEND_MAX_STEP cap still
     * bounds each step, so a genuinely inattentive stretch is still not
     * counted as attention.
     *
     * discretes_poll() already gates itself this way, for the same reason;
     * discretes_poll_one() never did. */
    if ((++d->attendCalls & (ATTEND_SAMPLE - 1u)) != 0u) return;
    double now = yagpc_monotonic_seconds();
    if (d->lastAttendSec > 0.0) {
        double gap = now - d->lastAttendSec;
        if (gap > 0.0)
            d->attentive += (gap < DISCRETES_ATTEND_MAX_STEP)
                                ? gap : DISCRETES_ATTEND_MAX_STEP;
    }
    d->lastAttendSec = now;
}

/* Apply AT MOST ONE pending datagram; true if there was one.
 *
 * A drain that applies everything waiting collapses a pulse.  The crew
 * panel presses IPL by publishing the bit set and, a few hundred
 * milliseconds later, clear; if both datagrams are in the socket when the
 * reader runs, a caller that looks at the result once sees only the final
 * state and the press never happened.  A caller that cares about EDGES --
 * mode_switch_held, which is the whole of the IPL pushbutton and the
 * HALT->STBY release -- steps through them one at a time instead. */
bool discretes_poll_one(Discretes *d) {
    if (d == NULL || !d->open) return false;
    attend(d);
    uint8_t buf[64];
    ssize_t n = recv(d->fd, buf, sizeof buf, 0);
    if (n <= 0) return false;
    apply(d, buf, (size_t)n);
    d->generation++;
    discretes_synctrace(d);
    return true;
}

void discretes_poll(Discretes *d) {
    if (d == NULL || !d->open) return;
    {
        /* Called once per instruction; count first (an increment and a test)
         * and ask the clock only every 32nd call.  The time gate still bounds
         * how stale the bus may get.
         *
         * PER MACHINE, not per process.  These were file statics, which was
         * the same thing while one computer ran but is not now: with two,
         * each machine's call advanced the OTHER's counter and refreshed the
         * OTHER's time gate, so each polled its own socket about half as
         * often as it asked to, and every inter-GPC line took twice as long
         * to arrive.  That matters directly -- FCOS's sync timeout is
         * 3.85 ms, and this is on the path (gpc-causes #91). */
        if ((++d->pollCalls & 31u) != 0u) return;
        double now = yagpc_monotonic_seconds();
        if (now - d->lastPollSec < DISCRETES_POLL_MIN_SECONDS &&
            now >= d->lastPollSec) return;
        d->lastPollSec = now;
    }
    attend(d);
#ifdef DISCRETES_HAVE_RECVMMSG
    /* ONE SYSCALL PER BATCH, NOT PER DATAGRAM.
     *
     * With four computers in a set this socket is busy: every SSIP, every
     * PC2 timer interrupt, every synchronising SVC and every I/O completion
     * puts a sync code on the wire, and each machine hears the other three.
     * Draining that one recv() at a time cost a syscall per datagram plus
     * one more for the EAGAIN that ended the loop, and a saturated
     * four-GPC profile put __libc_recv at 4.4% of cycles with the kernel's
     * per-syscall overhead -- __fdget, the AppArmor socket check, the
     * return path -- stacked behind it.
     *
     * recvmmsg() answers with up to DISCRETES_RECV_BATCH datagrams at once.
     * They arrive in the order they were sent, exactly as the loop below
     * used to read them, and are applied in that order, so a sequence of
     * codes still reads as a sequence.  A short batch means the socket is
     * empty and ends the drain without the extra EAGAIN syscall.
     *
     * NOT used by discretes_poll_one(), deliberately: that one exists to
     * apply a SINGLE datagram so a pulse is not collapsed, and batching is
     * the opposite of what it is for. */
    static _Thread_local uint8_t bufs[DISCRETES_RECV_BATCH][64];
    static _Thread_local struct mmsghdr msgs[DISCRETES_RECV_BATCH];
    static _Thread_local struct iovec iov[DISCRETES_RECV_BATCH];
    for (;;) {
        for (int i = 0; i < DISCRETES_RECV_BATCH; i++) {
            iov[i].iov_base = bufs[i];
            iov[i].iov_len = sizeof bufs[i];
            msgs[i].msg_hdr.msg_name = NULL;
            msgs[i].msg_hdr.msg_namelen = 0;
            msgs[i].msg_hdr.msg_iov = &iov[i];
            msgs[i].msg_hdr.msg_iovlen = 1;
            msgs[i].msg_hdr.msg_control = NULL;
            msgs[i].msg_hdr.msg_controllen = 0;
            msgs[i].msg_hdr.msg_flags = 0;
            msgs[i].msg_len = 0;
        }
        int got = recvmmsg(d->fd, msgs, DISCRETES_RECV_BATCH, 0, NULL);
        if (got <= 0) break;         /* EAGAIN/EWOULDBLOCK: nothing waiting */
        for (int i = 0; i < got; i++) {
            if (msgs[i].msg_len == 0) continue;
            apply(d, bufs[i], (size_t)msgs[i].msg_len);
            d->generation++;
        }
        if (got < DISCRETES_RECV_BATCH) break;   /* the socket ran dry */
    }
#else
    uint8_t buf[64];
    for (;;) {
        ssize_t n = recv(d->fd, buf, sizeof buf, 0);
        if (n <= 0) {
            /* EAGAIN/EWOULDBLOCK: nothing more waiting. */
            break;
        }
        apply(d, buf, (size_t)n);
        d->generation++;
    }
#endif
    discretes_synctrace(d);
}

static void send_msg(Discretes *d, unsigned op, int reg, uint32_t mask) {
    if (d == NULL || !d->open) return;
    uint8_t b[WORDS * 2];
    b[0] = (uint8_t)(op >> 8);    b[1] = (uint8_t)op;
    b[2] = (uint8_t)(reg >> 8);   b[3] = (uint8_t)reg;
    b[4] = (uint8_t)(mask >> 24); b[5] = (uint8_t)(mask >> 16);
    b[6] = (uint8_t)(mask >> 8);  b[7] = (uint8_t)mask;
    (void)sendto(d->fd, b, sizeof b, 0,
                 (struct sockaddr *)&d->group, sizeof d->group);
}

void discretes_set_canonical(Discretes *d, int reg, uint32_t value) {
    if (d == NULL || !d->open || !reg_known(reg)) return;
    d->canonical[reg_index(reg)] = value;
}

/* The output register is entirely this GPC's own, so every change to it is
 * published as the SET and RESET of the bits that moved -- nothing else
 * drives it and nothing else can contradict it. */
void discretes_set_local_wired(Discretes *d, int reg, uint32_t mask) {
    if (d == NULL || !reg_known(reg)) return;
    d->localWired[reg_index(reg)] = mask;
}

void discretes_set_out_hook(Discretes *d, DiscretesOutFn fn, void *ctx) {
    if (d == NULL) return;
    d->outHook = fn;
    d->outHookCtx = ctx;
}

void discretes_publish_to(Discretes *from, int destGpc, int reg, uint32_t mask,
                          bool on) {
    if (from == NULL || !from->open || mask == 0u) return;
    struct sockaddr_in dest = from->group;
    dest.sin_port = htons((uint16_t)DISCRETES_PORT_FOR(destGpc));
    uint8_t b[WORDS * 2];
    unsigned op = on ? OP_SET : OP_RESET;
    b[0] = (uint8_t)(op >> 8);    b[1] = (uint8_t)op;
    b[2] = (uint8_t)(reg >> 8);   b[3] = (uint8_t)reg;
    b[4] = (uint8_t)(mask >> 24); b[5] = (uint8_t)(mask >> 16);
    b[6] = (uint8_t)(mask >> 8);  b[7] = (uint8_t)mask;
    (void)sendto(from->fd, b, sizeof b, 0,
                 (struct sockaddr *)&dest, sizeof dest);
}

void discretes_publish_out(Discretes *d, uint32_t before, uint32_t after) {
    if (d == NULL || !d->open) return;
    uint32_t changed = before ^ after;
    d->value[reg_index(DISCRETES_REG_OUT)] = after;
    d->canonical[reg_index(DISCRETES_REG_OUT)] = after;
    if (changed == 0) return;
    if (changed & after)  send_msg(d, OP_SET, DISCRETES_REG_OUT, changed & after);
    if (changed & ~after) send_msg(d, OP_RESET, DISCRETES_REG_OUT, changed & ~after);
    d->generation++;
    /* And onward to the other computers: these four lines are wired to them
     * (see discretes_rotate_out). */
    if (d->outHook != NULL) d->outHook(d->outHookCtx, d->gpcId, before, after);
    discretes_synctrace(d);
}

/* See discretes.h.  The same shape as the output register: this computer
 * owns every bit, publishes its own changes, and is the only sender of a
 * VALUE for it. */
void discretes_publish_failvote(Discretes *d, uint32_t value) {
    if (d == NULL || !d->open) return;
    int r = reg_index(DISCRETES_REG_FAILVOTE);
    uint32_t before = d->value[r];
    value &= 0x1fu;                       /* five bits, and only five */
    if (value == before) return;
    d->value[r] = value;
    d->canonical[r] = value;
    uint32_t changed = before ^ value;
    if (changed & value)  send_msg(d, OP_SET, DISCRETES_REG_FAILVOTE, changed & value);
    if (changed & ~value) send_msg(d, OP_RESET, DISCRETES_REG_FAILVOTE, changed & ~value);
    d->generation++;
    if (yagpc_getenv("YAGPC_SYNCTRACE") != NULL)
        fprintf(stderr, "SYNC GPC%d fail-vote %08x -> %08x  (rotated; see "
                        "discretes.h)\n", d->gpcId, before, value);
}

void discretes_publish_cfail(Discretes *d, bool lit) {
    if (d == NULL || !d->open) return;
    int r = reg_index(DISCRETES_REG_CFAIL);
    uint32_t value = lit ? 1u : 0u, before = d->value[r];
    if (value == before) return;
    d->value[r] = value;
    d->canonical[r] = value;
    send_msg(d, lit ? OP_SET : OP_RESET, DISCRETES_REG_CFAIL, 1u);
    d->generation++;
    if (yagpc_getenv("YAGPC_SYNCTRACE") != NULL)
        fprintf(stderr, "SYNC GPC%d computer fail lamp %s\n", d->gpcId,
                lit ? "ON" : "OFF");
}

void discretes_publish(Discretes *d, int reg, uint32_t mask, bool on) {
    if (d == NULL || !d->open || mask == 0u) return;
    int r = reg_index(reg);
    d->selfDriven[r] |= mask;
    d->generation++;
    send_msg(d, on ? OP_SET : OP_RESET, reg, mask);
}

uint32_t discretes_driven_mask(const Discretes *d, int reg) {
    if (d == NULL || !d->open) return 0u;
    int r = reg_index(reg);
    double now = d->attentive;
    uint32_t m = 0u;
    for (int bit = 0; bit < 32; bit++) {
        double t = d->lastSeen[r][bit];
        if (t > 0.0 && (now - t) <= d->staleSec) m |= (0x80000000u >> bit);
    }
    /* Our own multicast comes back to us, being a member of the group.
     * Honouring it would replace a device's in-process state with the
     * same state a socket round trip later -- worse in every way, and
     * nondeterministic besides. */
    return m & ~d->selfDriven[r];
}

double discretes_bit_age(const Discretes *d, int reg, int bit) {
    if (d == NULL || !d->open || bit < 0 || bit > 31) return -1.0;
    double t = d->lastSeen[reg_index(reg)][bit];
    return (t > 0.0) ? d->attentive - t : -1.0;
}

uint32_t discretes_value(const Discretes *d, int reg) {
    if (d == NULL) return 0u;
    if (!d->open) return 0u;
    return d->value[reg_index(reg)];
}
