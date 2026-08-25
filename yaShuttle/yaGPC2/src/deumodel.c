/* See deumodel.h.  Ported from nsts-sim-gpc/meds/deuUnit.coffee and
 * meds/deuProto.coffee; the constants below are that protocol's, not
 * invented here, and are named the same so the two can be read side by
 * side. */
#include "deumodel.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* deuProto.coffee */
#define DEU_IUA             10
#define FUNC_SHIFT          9
#define COUNT_MASK          0x1ff
#define FUNC_POLL           0x010
#define FUNC_BITE           0x040
#define FUNC_RESET_SPL      0x080
#define FUNC_TIME_FILL      0x380
#define FUNC_DISPLAY_FILL   0x38c
#define FUNC_FORMAT_FILL    0x394
#define FUNC_MEDS_XFER      0x398
#define FUNC_DUMP           0x3a0
#define MEDS_XFER_WORDS     100
#define POLL_WORDS          16
#define LAST_FILL_WORDS     250
#define DEU_MEMORY_WORDS    8192
#define DEU_ID_ADDR         0x001d
#define KEY_COUNT_HIGH      0xff00
#define MAJOR_FUNC_SHIFT    6
#define HDR_MAJOR_FUNC      0x00c0
#define HDR_IPL_REQUIRED    0x0001
#define BITE1_ALWAYS_ONE    0x8000
#define BITE1_IPL_DONE      0x4000
#define SWSTATUS_HEALTHY    0x2000

/* A transfer is at most COUNT_MASK halfwords, the field's own limit. */
#define XFER_MAX            COUNT_MASK
#define REPLY_MAX           64

struct DeuModel {
    int busID;

    bool ipled;         /* the unit has been loaded */
    bool iplRunning;    /* a load is in progress */
    int majorFunc;
    uint16_t deuId;
    bool haveDeuId;

    uint16_t mem[DEU_MEMORY_WORDS];

    /* The transfer a fill command opened, filling up word by word. */
    bool xferActive;
    unsigned xferFunc;
    size_t xferLeft;
    size_t xferCount;
    uint16_t xferWords[XFER_MAX];

    /* What the unit has to say back, read out one word per RECV_WORD. */
    uint16_t reply[REPLY_MAX];
    size_t replyHead, replyCount;

    /* Counters, named as the real unit's harness names them. */
    long commands, fills, timeFills, displayFills, formatFills, headerless, polls, bite, dumps;
    long resets, unknown, abandoned, modeStatus;
    long wordsIn, wordsOut;
};

DeuModel *deumodel_create(int busID) {
    DeuModel *d = calloc(1, sizeof(DeuModel));
    if (!d) return NULL;
    d->busID = busID;
    fprintf(stderr, "deu: model installed on bus %d\n", busID);
    /* "asking for an IPL": the unit powers up unloaded, which is the
     * state the flight software is meant to notice and fix. */
    d->ipled = false;
    d->iplRunning = false;
    return d;
}

void deumodel_free(DeuModel *d) { free(d); }

static uint16_t deu_checksum(const uint16_t *w, size_t n) {
    unsigned s = 0;
    for (size_t i = 0; i < n; i++) s = (s + w[i]) & 0xffffu;
    return (uint16_t)((unsigned)(-(int)s) & 0xffffu);
}

/* deuUnit.coffee's header(): the major function switch, plus the bit that
 * says the unit still needs loading.  No keyboard here, so the MSG RESET,
 * ACK and KYBD MSG bits are never set. */
static uint16_t deu_header(const DeuModel *d) {
    uint16_t hdr = (uint16_t)(((unsigned)d->majorFunc << MAJOR_FUNC_SHIFT) & HDR_MAJOR_FUNC);
    if (!d->ipled) hdr |= HDR_IPL_REQUIRED;
    return hdr;
}

static uint16_t deu_bite1(const DeuModel *d) {
    uint16_t b = BITE1_ALWAYS_ONE;
    if (d->ipled) b |= BITE1_IPL_DONE;
    return b;
}

static void deu_queue_reply(DeuModel *d, const uint16_t *words, size_t n) {
    if (n > REPLY_MAX) n = REPLY_MAX;
    /* A reply supersedes anything unread: the real unit answers the poll
     * it was just given, and the bus program reads it before the next. */
    d->replyHead = 0;
    d->replyCount = n;
    memcpy(d->reply, words, n * sizeof words[0]);
    d->wordsOut += (long)n;
}

static void deu_poll_response(DeuModel *d) {
    uint16_t w[POLL_WORDS];
    memset(w, 0, sizeof w);
    w[0] = deu_header(d);
    w[1] = KEY_COUNT_HIGH;              /* no keys queued */
    w[12] = deu_bite1(d);
    w[13] = 0;
    w[14] = SWSTATUS_HEALTHY;
    w[15] = deu_checksum(w, 15);
    deu_queue_reply(d, w, POLL_WORDS);
}

static void deu_bite_response(DeuModel *d) {
    uint16_t w[5];
    w[0] = deu_bite1(d);
    w[1] = 0;
    w[2] = SWSTATUS_HEALTHY;
    w[3] = 0;
    w[4] = deu_checksum(w, 4);
    deu_queue_reply(d, w, 5);
}

/* deuUnit.coffee's _fill(): word 0 is the payload length, word 1 the DEU
 * address it loads at, and the transfer count is therefore the payload
 * plus two.  A load completes on the block whose payload is exactly
 * LAST_FILL_WORDS -- that rule, not the address, is what ends it. */
static void deu_complete_fill(DeuModel *d) {
    size_t n = d->xferCount;
    const uint16_t *w = d->xferWords;

    /* A TIME FILL is not a fill in the loading sense and has no length or
     * address word: it carries the mission time as 48-bit IBM extended
     * floats (deuProto's ibmFloat48).  Held to the fill rule it failed it
     * every time -- 2209 of 2224 "unheadered" rejections in an IPL were
     * just the clock, which the real display renders perfectly well, while
     * timeFills sat at 0 and said nothing had arrived. */
    if (d->xferFunc == FUNC_TIME_FILL) {
        d->timeFills++;
        d->xferActive = false;
        d->xferCount = 0;
        return;
    }

    if (n < 2 || (size_t)w[0] + 2 != n) {
        d->headerless++;
        /* The words too, not just the count.  "Unheadered" only says the
         * length word disagreed with what arrived; which is wrong -- the
         * software, or the way this model counts a transfer -- needs the
         * content to tell. */
        fprintf(stderr, "deu: unheadered fill of %zu halfwords, ignored:", n);
        for (size_t i = 0; i < n && i < 8; i++) fprintf(stderr, " %04x", w[i]);
        fprintf(stderr, "   (func %u)\n", d->xferFunc);
        d->xferActive = false;
        d->xferCount = 0;
        return;
    }
    d->fills++;
    if (d->xferFunc == FUNC_DISPLAY_FILL) d->displayFills++;
    else if (d->xferFunc == FUNC_FORMAT_FILL) d->formatFills++;

    unsigned count = w[0];
    unsigned addr = w[1];

    if (!d->ipled && !d->iplRunning) {
        d->iplRunning = true;
        fprintf(stderr, "deu: load started\n");
    }
    if (d->iplRunning && count == LAST_FILL_WORDS) {
        d->iplRunning = false;
        d->ipled = true;
        if (addr <= DEU_ID_ADDR && DEU_ID_ADDR < addr + count) {
            d->deuId = w[2 + (DEU_ID_ADDR - addr)];
            d->haveDeuId = true;
        }
        fprintf(stderr, "deu: load complete (%u halfwords at 0x%x), reporting initialized",
                count, addr);
        if (d->haveDeuId) fprintf(stderr, " as unit %u", (unsigned)d->deuId);
        fprintf(stderr, "\n");
    }
    for (unsigned i = 0; i < count; i++)
        d->mem[(addr + i) & (DEU_MEMORY_WORDS - 1)] = w[2 + i];

    d->xferActive = false;
    d->xferCount = 0;
}

static void deu_command(DeuModel *d, uint32_t cmd24) {
    unsigned iua = (cmd24 >> 19) & 0x1fu;
    unsigned func = (cmd24 >> FUNC_SHIFT) & 0x3ffu;
    unsigned count = cmd24 & COUNT_MASK;

    if (iua != DEU_IUA) return;   /* not addressed to a display unit */
    d->commands++;
    /* Reported as it goes, not only at teardown: a run of this is
     * normally ended by a timeout from outside, which never reaches the
     * free() that would otherwise be the only place the counters
     * appear. */
    if ((d->commands % 200) == 0) deumodel_report(d);

    /* A new command abandons whatever transfer was part way through,
     * exactly as the real unit does. */
    if (d->xferActive && d->xferCount < d->xferLeft) {
        d->abandoned++;
        fprintf(stderr, "deu: transfer abandoned, %zu halfwords short\n",
                d->xferLeft - d->xferCount);
    }
    d->xferActive = false;
    d->xferCount = 0;

    switch (func) {
    case FUNC_TIME_FILL:
    case FUNC_DISPLAY_FILL:
    case FUNC_FORMAT_FILL:
    case FUNC_DUMP:
        d->xferActive = true;
        d->xferFunc = func;
        d->xferLeft = count;
        break;
    case FUNC_MEDS_XFER:
        d->xferActive = true;
        d->xferFunc = func;
        d->xferLeft = MEDS_XFER_WORDS;
        break;
    case FUNC_POLL:
        d->polls++;
        /* While a load is running the unit answers a poll with the
         * header alone, not the whole poll response.  This is the rule
         * that starves a sixteen-word receive mid-IPL. */
        if (d->iplRunning) {
            uint16_t hdr = deu_header(d);
            d->modeStatus++;
            deu_queue_reply(d, &hdr, 1);
        } else {
            deu_poll_response(d);
        }
        break;
    case FUNC_BITE:
        d->bite++;
        deu_bite_response(d);
        break;
    case FUNC_RESET_SPL:
        d->resets++;
        break;
    default:
        d->unknown++;
        break;
    }
    if (d->xferActive && d->xferLeft == 0) d->xferActive = false;
}

void deumodel_service(void *ctx, GpcServiceNumber serviceNumber, const GpcServiceInput *input,
                      GpcServiceOutput *output) {
    DeuModel *d = (DeuModel *)ctx;
    if (!d || !input || !output) return;
    if (getenv("YAGPC_DEUTRACE")) {
        static int first = 1;
        if (first) { first = 0;
            fprintf(stderr, "deu: first service call, svc=%d bus=%d\n",
                    (int)serviceNumber, input->busID); }
    }
    { /* Every call, whatever bus: if the machine is doing bus I/O at all,
       * this says so and says where, which distinguishes "the model is
       * wrong" from "the machine never got there". */
      static long byBus[32]; static long total = 0;
      int b = input->busID; if (b >= 0 && b < 32) byBus[b]++;
      if (++total % 5000 == 0 && getenv("YAGPC_DEUTRACE")) {
          fprintf(stderr, "deu: %ld service calls; by bus:", total);
          for (int i = 0; i < 32; i++) if (byBus[i]) fprintf(stderr, " %d=%ld", i, byBus[i]);
          fprintf(stderr, "\n");
      } }
    if (input->busID != d->busID) {
        /* Another bus: nothing is listening, which is the truth. */
        switch (serviceNumber) {
        case GPC_SVC_XMIT_CMD:
        case GPC_SVC_XMIT_WORD: output->out.xmit.ok = true; break;
        case GPC_SVC_RECV_POLL: output->out.poll.available = false; break;
        case GPC_SVC_RECV_WORD: output->out.recv.available = false;
                                output->out.recv.word = 0; break;
        }
        return;
    }

    switch (serviceNumber) {
    case GPC_SVC_XMIT_CMD:
        deu_command(d, input->in.word & 0x00ffffffu);
        output->out.xmit.ok = true;
        break;

    case GPC_SVC_XMIT_WORD:
        d->wordsIn++;
        if (d->xferActive && d->xferCount < XFER_MAX) {
            d->xferWords[d->xferCount++] = (uint16_t)input->in.word;
            if (d->xferCount >= d->xferLeft) deu_complete_fill(d);
        }
        output->out.xmit.ok = true;
        break;

    case GPC_SVC_RECV_POLL:
        output->out.poll.available = (d->replyCount > 0);
        break;

    case GPC_SVC_RECV_WORD:
        if (d->replyCount > 0) {
            output->out.recv.available = true;
            output->out.recv.word = d->reply[d->replyHead++];
            d->replyCount--;
        } else {
            output->out.recv.available = false;
            output->out.recv.word = 0;
        }
        break;
    }
}

void deumodel_report(const DeuModel *d) {
    if (!d) return;
    fprintf(stderr,
            "deu: {\"commands\":%ld,\"fills\":%ld,\"timeFills\":%ld,\"displayFills\":%ld,\"formatFills\":%ld,\"headerless\":%ld,"
            "\"polls\":%ld,\"bite\":%ld,\"dumps\":%ld,\"resets\":%ld,\"unknown\":%ld,"
            "\"wordsIn\":%ld,\"wordsOut\":%ld,\"abandoned\":%ld,\"modeStatus\":%ld,"
            "\"ipled\":%s}\n",
            d->commands, d->fills, d->timeFills, d->displayFills, d->formatFills, d->headerless, d->polls, d->bite,
            d->dumps, d->resets, d->unknown, d->wordsIn, d->wordsOut, d->abandoned,
            d->modeStatus, d->ipled ? "true" : "false");
}
