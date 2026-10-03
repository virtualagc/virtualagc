/* THE LAUNCH PROCESSING SYSTEM ON THE LAUNCH DATA BUS -- see lpsmodel.h.
 *
 * SOURCES: the flight software's side of the protocol, APPLSRC
 * DGILDBIO.hal and its INCL80 includes (DGIINTER, DGIGOAHE, DGISTATU,
 * DGIINTWD, DGIHEREC, DGISTATR), DGRGSERO.hal, CDVCOMPO; the bus programs,
 * SSSRC FIOLDBPG and FIOPDISP:1349-1450; the launch sequence's own decode,
 * GSRRSL.hal:399-487 and VJ1LSRES.hal; the countdown, the Ground Launch
 * Sequencer description (KLO-82-0071 App A) and STS 83-0026-34 Sequencers.
 *
 * THE GPC IS THE BUS COMMANDER; the ground answers like a device at IUA 17.
 * One poll every 40 ms.  The 24-bit command word: address (bits 0-4), command
 * code (5-8), GPC ID (9-11), and a 12-bit word count or status mask (12-23):
 *
 *   0011 INTERROGATE            read 1: 0x3000 "no need for the bus", or
 *                               0x6000 | (n - 1) "the ground has n words"
 *   0101 GO-AHEAD               read the n words
 *   1101 INTERROGATE WITH DATA  read 1: 0xB000 "send your data"
 *   1001 TRANSMISSION ENABLE    the GPC writes its words
 *   0010 STATUS REQUEST         read 1 (its content is not checked)
 *   1010 STATUS / WAVE-OFF      command only; the mask is the low 12 bits
 *
 * A GROUND MESSAGE is word 1 = functional destination (5 bits) and an
 * 11-bit transaction ID, which must differ from the last one accepted and is
 * never 0; then its data; then a 16-bit sumcheck, the words added with the
 * carries thrown away.  Destination 6 is the launch sequence: word 2 is the
 * code, and for GMT OF PREDICTED LIFTOFF words 3 and 4 are a 32-bit integer
 * of GMT seconds on the GPC's own clock.  PASS answers every launch-sequence
 * message with five words of its own (an echo, the time, accepted or not),
 * which it sends through INTERROGATE WITH DATA and TRANSMISSION ENABLE --
 * and THE GROUND MUST TAKE THEM, or PASS's coordinator waits for ever and
 * rejects every later command as "destination busy".
 * ------------------------------------------------------------------- */
#define _DEFAULT_SOURCE
#include "lpsmodel.h"

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

#define LDB_IUA 17u
#define CW_IUA(c)   (((c) >> 19) & 0x1fu)
#define CW_CODE(c)  (((c) >> 15) & 0xfu)
#define CW_COUNT(c) ((c) & 0xfffu)

enum { OP_STATUS_REQ = 0x2, OP_INTERROGATE = 0x3, OP_GO_AHEAD = 0x5,
       OP_TRANSMIT = 0x9, OP_STATUS = 0xA, OP_INT_DATA = 0xD };

#define LS_DEST 6u
#define MAXMSG 32
#define MAXQ 16

typedef struct { uint16_t w[MAXMSG]; int n; char what[48]; } Msg;
static Msg queue[MAXQ];
static int qHead, qLen;
static unsigned txid = 0;
static double (*gmtNow)(void) = NULL;
static int sockFd = -1;
static long polls, interrogates, delivered, responses, rejects, statuses, badStatus;

void lps_set_gmt_source(double (*now)(void)) { gmtNow = now; }

bool lps_owns(int busID, uint32_t cmd) {
    return (busID == 12 || busID == 13) && CW_IUA(cmd) == LDB_IUA;
}

/* ---- building the ground's messages ---------------------------------- */

static void enqueue_ls(unsigned code, const uint16_t *data, int nd, const char *what) {
    if (qLen >= MAXQ) {
        fprintf(stderr, "lps: queue full -- '%s' dropped\n", what);
        return;
    }
    Msg *m = &queue[(qHead + qLen) % MAXQ];
    txid = (txid % 0x7ffu) + 1u;                  /* 1..2047, never 0 */
    m->n = 0;
    m->w[m->n++] = (uint16_t)((LS_DEST << 11) | txid);
    m->w[m->n++] = (uint16_t)code;
    for (int i = 0; i < nd && m->n < MAXMSG - 1; i++) m->w[m->n++] = data[i];
    unsigned sum = 0;
    for (int i = 0; i < m->n; i++) sum += m->w[i];
    m->w[m->n++] = (uint16_t)(sum & 0xffffu);
    snprintf(m->what, sizeof m->what, "%s", what);
    qLen++;
    fprintf(stderr, "lps: queued %s (code %u, transaction %u, %d words)\n", what, code, txid, m->n);
}

/* A command line: hold, resume, recycle, go_auto, go_engine, gmtlo +N,
 * gmtlo =S, bypass_a, bypass_b, pogo, or 'code N [word ...]' (hex words). */
void lps_command_line(const char *line) {
    char word[32] = "";
    double v = 0.0;
    if (sscanf(line, "%31s", word) != 1) return;
    if (!strcasecmp(word, "hold")) enqueue_ls(2, NULL, 0, "HOLD");
    else if (!strcasecmp(word, "resume")) enqueue_ls(4, NULL, 0, "RESUME");
    else if (!strcasecmp(word, "recycle")) enqueue_ls(3, NULL, 0, "RECYCLE");
    else if (!strcasecmp(word, "go_auto")) enqueue_ls(1, NULL, 0, "GO FOR AUTO SEQUENCE");
    else if (!strcasecmp(word, "go_engine")) enqueue_ls(8, NULL, 0, "GO FOR ENGINE START");
    else if (!strcasecmp(word, "bypass_a")) enqueue_ls(12, NULL, 0, "LO2 BLEED BYPASS A");
    else if (!strcasecmp(word, "bypass_b")) enqueue_ls(13, NULL, 0, "LO2 BLEED BYPASS B");
    else if (!strcasecmp(word, "pogo")) enqueue_ls(14, NULL, 0, "LO2 POGO RECIRC BYPASS");
    else if (!strcasecmp(word, "gmtlo")) {
        const char *a = line + strlen(word);
        while (*a == ' ' || *a == '\t') a++;
        double g;
        if (*a == '+' && sscanf(a + 1, "%lf", &v) == 1) {
            double now = gmtNow ? gmtNow() : -1.0;
            if (now < 0.0) {
                fprintf(stderr, "lps: 'gmtlo +%g' -- the GPC's GMT is not known yet; "
                                "use 'gmtlo =SECONDS'\n", v);
                return;
            }
            g = floor(now) + v;
        } else if (*a == '=' && sscanf(a + 1, "%lf", &v) == 1) {
            g = v;
        } else {
            fprintf(stderr, "lps: 'gmtlo' wants +SECONDS or =SECONDS\n");
            return;
        }
        uint32_t s = (uint32_t)g;
        uint16_t d[2] = { (uint16_t)(s >> 16), (uint16_t)s };
        char what[48];
        snprintf(what, sizeof what, "GMTLO %03u/%02u:%02u:%02u", s / 86400u, s % 86400u / 3600u,
                 s % 3600u / 60u, s % 60u);
        enqueue_ls(9, d, 2, what);
    } else if (!strcasecmp(word, "code")) {
        unsigned code = 0;
        uint16_t d[MAXMSG];
        int nd = 0, used = 0;
        const char *a = line + strlen(word);
        if (sscanf(a, "%u%n", &code, &used) != 1) return;
        a += used;
        unsigned x;
        while (nd < MAXMSG - 3 && sscanf(a, "%x%n", &x, &used) == 1) { d[nd++] = (uint16_t)x; a += used; }
        char what[48];
        snprintf(what, sizeof what, "code %u", code);
        enqueue_ls(code, d, nd, what);
    } else {
        fprintf(stderr, "lps: unknown command '%s'\n", word);
    }
}

/* ---- the countdown commands' socket ---------------------------------- */

void lps_open(int portBase) {
    if (sockFd >= 0 || portBase <= 0) return;
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) return;
    int reuse = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse);
#if defined(SO_REUSEPORT) && !defined(__linux__)
    setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &reuse, sizeof reuse);
#endif
    const char *ifaceStr = yagpc_getenv("NSTS_BUS_IFACE");
    struct in_addr iface;
    iface.s_addr = inet_addr(ifaceStr ? ifaceStr : "127.0.0.1");
    if (iface.s_addr == INADDR_NONE) iface.s_addr = htonl(INADDR_ANY);
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)(portBase + LPS_OFFSET));
    struct ip_mreq mreq = {0};
    mreq.imr_multiaddr.s_addr = inet_addr("239.255.1.1");
    mreq.imr_interface.s_addr = iface.s_addr;
    if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0 ||
        setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof mreq) < 0) {
        fprintf(stderr, "lps: no countdown commands (port %d): %s\n", portBase + LPS_OFFSET,
                strerror(errno));
        close(fd);
        return;
    }
    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);
    sockFd = fd;
    fprintf(stderr, "lps: countdown commands on port %d\n", portBase + LPS_OFFSET);
}

static void lps_poll(void) {
    if (sockFd < 0) return;
    char buf[256];
    for (;;) {
        ssize_t n = recv(sockFd, buf, sizeof buf - 1, 0);
        if (n <= 0) break;
        buf[n] = '\0';
        /* "LPS1 " then the command line */
        if (n > 5 && !strncmp(buf, "LPS1 ", 5)) lps_command_line(buf + 5);
    }
}

/* ---- the bus side ----------------------------------------------------- */

static const char *op_name(unsigned op) {
    switch (op) {
    case OP_STATUS_REQ: return "STATUS REQUEST";
    case OP_INTERROGATE: return "INTERROGATE";
    case OP_GO_AHEAD: return "GO-AHEAD";
    case OP_TRANSMIT: return "TRANSMISSION ENABLE";
    case OP_STATUS: return "STATUS";
    case OP_INT_DATA: return "INTERROGATE WITH DATA";
    default: return "?";
    }
}

static bool trace(void) {
    static int t = -1;
    if (t < 0) t = yagpc_getenv("YAGPC_LPSTRACE") != NULL;
    return t != 0;
}

void lps_note_command(uint32_t cmd) {
    unsigned op = CW_CODE(cmd);
    polls++;
    if (trace() && op != OP_INTERROGATE)
        fprintf(stderr, "lps: %s cw=%06x count/mask=%03x gpc=%u\n", op_name(op),
                (unsigned)(cmd & 0xffffffu), CW_COUNT(cmd), (unsigned)((cmd >> 12) & 7u));
    if (op == OP_STATUS) {
        unsigned mask = CW_COUNT(cmd);
        statuses++;
        /* 0x080 wave-off is the normal "working on it"; the others are the
         * flight software refusing what the ground sent. */
        if (mask & ~0x080u) {
            badStatus++;
            fprintf(stderr, "lps: GPC status %03x:%s%s%s%s%s%s%s\n", mask,
                    (mask & 0x800) ? " I/O-error" : "", (mask & 0x400) ? " TCS-busy" : "",
                    (mask & 0x200) ? " invalid-data" : "", (mask & 0x100) ? " destination-busy" : "",
                    (mask & 0x040) ? " duplicate" : "", (mask & 0x020) ? " bad-sumcheck" : "",
                    (mask & 0x008) ? " bad-op" : "");
        }
    }
}

int lps_read_words(uint32_t cmd, int armed) {
    unsigned op = CW_CODE(cmd);
    lps_poll();
    switch (op) {
    case OP_INTERROGATE: case OP_INT_DATA: case OP_STATUS_REQ: return 1;
    case OP_GO_AHEAD: {
        int n = qLen > 0 ? queue[qHead].n : 0;
        /* the GPC arms what our INTERROGATE answer told it to */
        if (armed > 0 && armed != n)
            fprintf(stderr, "lps: GO-AHEAD armed for %d word(s), message has %d\n", armed, n);
        return armed > 0 ? armed : n;
    }
    default: return 0;
    }
}

bool lps_reply(uint32_t cmd, int n, uint16_t *out) {
    unsigned op = CW_CODE(cmd);
    for (int i = 0; i < n; i++) out[i] = 0;
    switch (op) {
    case OP_INTERROGATE:
        interrogates++;
        out[0] = qLen > 0 ? (uint16_t)(0x6000u | (unsigned)(queue[qHead].n - 1)) : 0x3000u;
        return true;
    case OP_INT_DATA:
        out[0] = 0xB000u;
        return true;
    case OP_STATUS_REQ:
        out[0] = 0x0000u;
        return true;
    case OP_GO_AHEAD:
        if (qLen <= 0) return true;
        {
            Msg *m = &queue[qHead];
            for (int i = 0; i < n && i < m->n; i++) out[i] = m->w[i];
            fprintf(stderr, "lps: sent %s\n", m->what);
            qHead = (qHead + 1) % MAXQ;
            qLen--;
            delivered++;
        }
        return true;
    default:
        return false;
    }
}

bool lps_is_transmit(uint32_t cmd) { return CW_CODE(cmd) == OP_TRANSMIT; }

int lps_transmit_words(uint32_t cmd) { return (int)CW_COUNT(cmd) + 1; }

void lps_write(uint32_t cmd, const uint16_t *w, int n) {
    (void)cmd;
    responses++;
    /* A launch-sequence response: RW1 the echo of our word 1, RW2 the code,
     * RW3-4 milliseconds of the day, RW5 0 accepted / 1 rejected, then the
     * sumcheck. */
    unsigned sum = 0;
    for (int i = 0; i < n - 1; i++) sum += w[i];
    bool sumOk = n >= 2 && (uint16_t)sum == w[n - 1];
    if (n >= 5 && ((w[0] >> 11) & 0x1fu) == LS_DEST) {
        uint32_t ms = ((uint32_t)w[2] << 16) | w[3];
        if (w[4] != 0) rejects++;
        fprintf(stderr, "lps: GPC response to transaction %u, code %u: %s at %02u:%02u:%06.3f%s\n",
                (unsigned)(w[0] & 0x7ffu), (unsigned)w[1], w[4] ? "REJECTED" : "accepted",
                ms / 3600000u, ms / 60000u % 60u, (ms % 60000u) / 1000.0,
                sumOk ? "" : " (sumcheck wrong)");
    } else {
        fprintf(stderr, "lps: GPC message, %d word(s):", n);
        for (int i = 0; i < n && i < 12; i++) fprintf(stderr, " %04x", w[i]);
        fprintf(stderr, "%s\n", sumOk ? "" : " (sumcheck wrong)");
    }
}

void lps_report(void) {
    if (polls == 0) return;
    fprintf(stderr, "lps: %ld launch-data-bus command(s) to the ground, %ld interrogate(s); "
                    "%ld message(s) sent, %d still queued; %ld response(s) taken, %ld rejected; "
                    "%ld status(es), %ld with errors\n",
            polls, interrogates, delivered, qLen, responses, rejects, statuses, badStatus);
}
