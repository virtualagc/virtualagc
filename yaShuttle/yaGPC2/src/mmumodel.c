/* In-process mass memory unit; see mmumodel.h. */
#include "mmumodel.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"
#include "discretes.h"
#include "busword.h"
#include "json.h"

#include "envcache.h"
/* MM1 is register A bit 6, MM2 bit 7 -- the same bits iop.c computes for
 * the machine's own READ DISCRETE INPUT A. */
#define DISCRETE_A_MM1_READY 0x02000000u
#define DISCRETE_A_MM2_READY 0x01000000u

/* Tape geometry (mmuConf.coffee).  8 files x 8 tracks x 8 subfiles x 32
 * blocks of 512 halfwords -- 8,388,608 halfwords in all. */
#define TRACKS 8
#define FILES 8
#define SUBFILES 8
#define BLOCKS_PER_SUBFILE 32
#define HALFWORDS_PER_BLOCK 512
#define BLOCKS_PER_TRACK (SUBFILES * BLOCKS_PER_SUBFILE)
#define BLOCKS_PER_FILE (TRACKS * BLOCKS_PER_TRACK)
#define BLOCKS_TOTAL (FILES * BLOCKS_PER_FILE)

#define IUA 11                       /* this unit's interface address */

/* Opcodes, from decodeCommand's switch. */
#define OP_POSITION 0x0
#define OP_BITE_STATUS 0x1
#define OP_POSITION_REQ 0x2
#define OP_EXTENDED_BLOCK 0x3
#define OP_WRITE 0x8
#define OP_READ 0x9
#define OP_WRITE_ENABLE 0xA

/* Status bits actually raised here (STAT_A / STAT_B). */
#define STAT_A_WRITE_PROTECT 0x1000
#define STAT_A_INVALID_COMMAND 0x0800
#define STAT_B_NOT_READY 0x8000
#define STAT_B_EOF_BLOCK_COUNT 0x2000
#define STAT_B_DATA_DROPOUT 0x4000

/* The largest transfer EXTENDED_BLOCK can ask for is an 8-bit count of
 * blocks, so the reply queue is sized to hold one outright: a whole
 * transfer is queued in the call that commanded it and drained as the bus
 * controller reads it. */
#define QUEUE_HW (256 * HALFWORDS_PER_BLOCK)

/* ---------------------------------------------------------------------
 * Pacing
 *
 * A queue that never loses anything is the wrong model of a wire, and the
 * flight software is built around the difference.  FCMBOOT reads a load
 * block whose length is not a whole number of mass memory blocks, takes
 * the halfwords it wants, and then simply DELAYS while the rest of the
 * last block goes past unread -- #DLYI, whose count it computes at
 * FCMBBLDR+0x25 as 2*(639 - partial), i.e. two counts per halfword for
 * the tail of the block plus 128 halfwords of the block gap.  The BCE
 * book's own programming note for #DLYI fixes both numbers: "Each count
 * of 1 represents a delay of 16.5 microseconds... Each count of 2
 * represents a delay of 33 microseconds, the minimum time for a word
 * transmission over a serial bus", and FCMBOOT's source names 128 as
 * "HWS IN ONE HALF OF A MASS MEMORY BLOCK GAP".
 *
 * So a word reaches the bus at its own word time and not before, and the
 * blocks have 256 word times of gap between them.  That is all this does;
 * losing a word is not its business.  A receive the bus controller has
 * armed is a hardware transfer that loses nothing, and our BCE gets a
 * slice only every 33 CPU instructions, so a model that expired words on
 * its own threw away live data at about two words in five.  The words
 * that go past unread are the ones nobody is listening for, and the
 * listener is the one that knows: iop_bce_delay discards them.
 *
 * Queueing the whole transfer up front and handing it over word by word
 * on this schedule is deliberate.  Once a receive is armed the BCE drains
 * whatever has arrived each time it runs, so it stays caught up without
 * having to be scheduled at bus rate.
 *
 * Only a read is paced.  A status or position reply is a word the unit
 * puts up in answer to a command and the sequence collects when it gets
 * to it; nothing in the software races it, and delaying it would only
 * invent a failure.
 * ------------------------------------------------------------------- */
#define BUS_WORD_US 33.0             /* one word time on the serial bus */
/* THE ADDRESS A GPC-TO-GPC OVERLAY USES on a mass-memory bus.  FCMMGBOV
 * builds the transmitter and receiver bus programs for it, and every
 * transfer seen -- GPC1 and GPC3 commanding buses 18 and 19 during an OPS
 * transition whose source is a GPC -- addresses 5.  Overridable while that
 * rests on observation rather than on a document. */
#define GTG_IUA (gtg_iua())

static int gtg_iua(void) {
    static int v = -1;
    if (v < 0) {
        const char *e = yagpc_getenv("YAGPC_GTG_IUA");
        v = (e != NULL && *e != '\0') ? atoi(e) : 5;
        if (v < 0 || v > 31) v = 5;
    }
    return v;
}

/* OFF UNTIL IT IS RIGHT.  Carrying the words does get an OPS 3 transition
 * whose source is a GPC to complete -- all three CRTs reach DEORB MNVR
 * COAST, where without it the vehicle stays in OPS 0 -- but the set then
 * fails: every computer lights its own fail lamp, and the receivers leave
 * most of the words unread (554,421 past unread against 359,378 carried, on
 * bus 18 alone).  Something about what the receiving bus programs expect,
 * or when, is still wrong.  YAGPC_GTG=1 turns it on to work on it; the
 * default leaves the bus exactly as it was, where ITEM 10 on DPS UTILITY
 * (force the MMU as the overlay source) is the way round it.  Ledger #199. */
static bool gtg_on(void) {
    static int v = -1;
    if (v < 0) {
        const char *e = yagpc_getenv("YAGPC_GTG");
        v = (e != NULL && *e != '\0' && *e != '0') ? 1 : 0;
    }
    return v != 0;
}
#define BLOCK_GAP_WORDS_DEFAULT 256  /* FCMBOOT's 128 is HALF a block gap */

/* YAGPC_MMU_BLOCK_GAP overrides the inter-block gap, in word times.
 *
 * WHY IT IS TUNABLE.  The gap is ~30% of a long transfer's duration, and
 * the System Software Loader checksums a load block after a wait it sizes
 * itself: FCMINSSL reads the block back out of memory, sums it, compares
 * against the block's own trailing checksum, and on three failures enters
 * a wait state on purpose (FCMINSSL.asm, label FCMSSLEX).  So a transfer
 * the model paces more slowly than the hardware did shows up NOT as a
 * timeout but as a phase that will not load.  Measured on our OI340700
 * volume: phase 13's second load block is 2698 halfwords, needing about
 * 131 ms at 33 us/word plus five 256-word gaps, while the loader
 * checksummed it at about 123 ms -- 594 halfwords still undelivered.  The
 * reference tape's equivalent block is 2012 halfwords and comfortably
 * inside the window.
 *
 * This exists to SEPARATE two causes, not to paper over one: if a smaller
 * gap loads the phase, the model's pacing is implicated; if it does not,
 * the fault is elsewhere and this changes nothing.  The default is
 * unchanged, and FCMBOOT's block-gap timing is load-bearing (see note 71
 * on YAGPC_MMU_WORD_US), so anything but the default needs FCMBOOT
 * re-verified before it is believed. */
static uint32_t block_gap_words(void) {
    static int inited = 0;
    static uint32_t v = BLOCK_GAP_WORDS_DEFAULT;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MMU_BLOCK_GAP");
        if (e != NULL && *e != '\0') {
            long n = strtol(e, NULL, 0);
            if (n >= 0 && n < 100000) v = (uint32_t)n;
        }
    }
    return v;
}
#define BLOCK_GAP_WORDS (block_gap_words())
#define SLOT_UNPACED 0xffffffffu

/* A READ's first data word does not follow the command at once: the unit
 * has to find the block first.  Streaming from the command's own word
 * time put the head of every read on the wire while the listening
 * computers were still in the delay FIOMMUPG gives them, and a delaying
 * BCE throws away what arrives -- so each listener's copy of an overlay
 * block began a dozen words in, failed FIOMGCV's load-block checksum
 * (FIOMGSNC error 0080), and ARCGPC dropped that computer from the
 * redundant set (ledger #139).
 *
 * The flight software states the constraint.  FIOMMUPG: 'COMMANDER DELAY
 * = 1814 FOR TAPE REVERSAL.  LISTENER DELAY = 1833 = TAPE REVERSAL + 19
 * FOR 2 CMDR'S CMD AND 17 FOR SYNC SKEW, PC1 ROLL-OVER, MSC AVAILABILITY,
 * IOP ALIGNMENT SKEW, AND DISCRETE NOISE'.  At 16.5 us a tick the listener
 * arms up to 17 + 17 ticks, about 560 us, after the commander's READ, and
 * the design only works if no data word is on the wire before then.  The
 * search time is not modelled; 1 ms is past that bound with margin and
 * small against the receive's 1.96 s timeout.  YAGPC_MMU_READ_LATENCY_US
 * overrides it, 0 restoring the old behaviour. */
static uint32_t read_latency_words(void) {
    static int inited = 0;
    static uint32_t v = 31;          /* 31 x 33 us, just over 1 ms */
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_MMU_READ_LATENCY_US");
        if (e != NULL && *e != '\0') {
            double us = strtod(e, NULL);
            if (us >= 0.0 && us < 1e7) v = (uint32_t)((us + BUS_WORD_US - 1.0) / BUS_WORD_US);
        }
    }
    return v;
}

struct MmuModel {
    int unit;
    int busID;
    bool verbose;

    /* Tape image.  blocks[i] is NULL for a block the volume never
     * recorded; volume.coffee reads those back as zeros. */
    uint16_t **blocks;
    /* WHICH BLOCKS THE FLIGHT SOFTWARE WROTE.  A write lands in `blocks`
     * and never reaches the .mmv, so these are the only copy -- and a
     * capture that leaves them out restores a vehicle whose mass memory has
     * forgotten everything PASS put there.  One byte per block. */
    unsigned char *dirty;
    bool writeProtect;

    /* Transport state, mirroring mmu.coffee's own fields. */
    int track, file, subfile, bof, eof;
    uint16_t statusA, statusB;
    int writeEnabledTrack;            /* -1 when nothing is armed */
    int extendedCount;                /* -1 when none pending */

    /* Pending write transfer. */
    bool writeActive;
    int writeFirst, writeDone, writeTotal, writeN;
    int writeStartTrack, writeStartFile, writeStartSubfile, writeStartBlock;
    uint16_t writeBuf[HALFWORDS_PER_BLOCK];

    uint16_t queue[QUEUE_HW];
    size_t queueHead, queueCount;

    /* Pacing (see above).  slot[i] is the word time queue[i] occupies,
     * counted from burstStartUs, or SLOT_UNPACED for a reply that is not
     * part of a read.  nextSlot is where the next queued word goes. */
    const double *clockUs;
    uint32_t slot[QUEUE_HW];
    double burstStartUs;
    uint32_t nextSlot;
    bool burstPrimed;                 /* do_read has set burstStartUs/nextSlot */

    /* The READY discrete this unit drives; see mmumodel_publish_ready. */
    /* The discrete channel this unit drives READY on.  A mass memory is
     * wired to every computer, so with several GPCs this becomes several
     * channels; one is enough while one machine runs. */
    struct Discretes *lines;
    bool readyPublished, lastReady;
    double lastReadyPublishSec;
    /* EVERY COMPUTER'S CHANNEL.  A mass memory is wired to all of them, and a
     * crew panel listens on one: publishing only on the channel of whichever
     * computer was set up last (GPC4 of four) left the panel's MM1 ACTIVITY
     * lamp dark through an IPL that read the bootstrap perfectly well.  Filled
     * by mmumodel_set_discretes, one entry per computer, before any machine
     * thread starts; each entry keeps its own republish timing. */
    struct { struct Discretes *d; bool published, last; double lastSec; } readyOut[6];
    int nReadyOut;


    struct {
        long commands, blocksRead, blocksWritten, wordsOut, wordsIn, wordsTaken, wordsLost;
    } stats;

    /* LISTENING COMPUTERS (ledger #136).  In a redundant set every member
     * issues the same mass-memory I/O; the one whose MIA transmitter is
     * enabled commands the unit and the others listen, and on the wire each
     * receives its own copy of the unit's words.  The queue above is the
     * COMMANDER's -- untouched, so a single computer sees exactly what it did
     * -- and each other computer that has been on this bus gets a tap: the
     * commander's command word marked command sync (what a Listen-Mode BCE
     * waits for), then every word the unit puts out, each due at the same
     * moment it is due for the commander.  That moment is kept on the SHARED
     * clock, since the computers' own clocks differ by however far apart they
     * started; with no shared clock there are no taps and nothing changes. */
    struct MmuTap {
        uint32_t *w;            /* NULL until this computer is seen here */
        double *due;            /* shared us the word is on the wire */
        unsigned char *paced;   /* 1 for a streamed block word */
        size_t head, count;
    } tap[6];
    int owner;                  /* GPC id of the commander, 0 = none yet */
    /* A GPC-TO-GPC OVERLAY IS IN PROGRESS ON THIS BUS.  PASS's default
     * overlay source is another GPC when one already holds the software
     * (DPS Overview Workbook, DPS UTILITY ITEM 9 GPC/MMU): FCMMGBOV builds
     * a transmitter bus program for the source and a receiver one for each
     * target, and they run on the MM bus with the mass memory not involved
     * at all -- the source commands some IUA of its own (5 in every run
     * seen) and sends the words, the targets listen on that IUAR.  This
     * unit is the only object every computer on the bus shares, so it also
     * plays the WIRE for those words; see mmumodel_service_as. */
    bool gtg;                   /* the commander is addressing another GPC */
    long gtgWords;              /* words carried between GPCs, for the report */
    double ownerOffsetUs;       /* shared minus the commander's own clock */
    double replyWireUs;         /* shared time the last reply/command word ends */
    bool haveOffset;
    long listenerWords, listenerLost;
};

static int block_index(int track, int file, int subfile, int block) {
    return (((file & 7) * TRACKS + (track & 7)) * SUBFILES + (subfile & 7))
               * BLOCKS_PER_SUBFILE + (block & 0x1f);
}

static double mm_now(const MmuModel *m);

static void mm_log(MmuModel *m, const char *fmt, ...) {
    if (!m->verbose) return;
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "mmu%d: ", m->unit);
    vfprintf(stderr, fmt, ap);
    /* Timestamped: every question about this unit has turned out to be a
     * question about WHEN, and an untimed log cannot answer one. */
    fprintf(stderr, "  t=%.1f\n", mm_now(m));
    va_end(ap);
}

/* An error the GPC sees the next time it asks for status.  The bits are
 * latched and cleared by the read, which is why a GPC asks after every
 * transaction. */
static void fault(MmuModel *m, char reg, uint16_t bit, const char *why) {
    if (reg == 'A') m->statusA |= bit;
    else m->statusB |= bit;
    mm_log(m, "fault %c 0x%04x: %s", reg, bit, why);
}

static double mm_now(const MmuModel *m) {
    return m->clockUs ? *m->clockUs : 0.0;
}

static void tap_push(MmuModel *m, int r, uint32_t w, double due, bool paced) {
    struct MmuTap *t = &m->tap[r];
    if (t->w == NULL) return;
    if (t->head > 0 && t->count + 1 > QUEUE_HW) {
        memmove(t->w, t->w + t->head, (t->count - t->head) * sizeof t->w[0]);
        memmove(t->due, t->due + t->head, (t->count - t->head) * sizeof t->due[0]);
        memmove(t->paced, t->paced + t->head, (t->count - t->head) * sizeof t->paced[0]);
        t->count -= t->head;
        t->head = 0;
    }
    if (t->count >= QUEUE_HW) { m->listenerLost++; return; }
    t->w[t->count] = w;
    t->due[t->count] = due;
    t->paced[t->count] = paced ? 1 : 0;
    t->count++;
}

/* A new command ends a stream: the unit stops sending, so streamed words
 * that are not yet on the wire never will be -- the commander's queue drops
 * them in on_command.  Words already due, and replies, stay in wire order. */
static void tap_end_stream(MmuModel *m, int r, double nowShared) {
    struct MmuTap *t = &m->tap[r];
    size_t j = t->head;
    for (size_t i = t->head; i < t->count; i++) {
        if (t->paced[i] && t->due[i] > nowShared) { m->listenerLost++; continue; }
        t->w[j] = t->w[i]; t->due[j] = t->due[i]; t->paced[j] = t->paced[i]; j++;
    }
    t->count = j;
}

/* bus_word() for a listener, on the shared clock, with the same grace. */
static bool tap_word(MmuModel *m, int r, double nowShared, uint32_t *out) {
    struct MmuTap *t = &m->tap[r];
    if (t->w == NULL) return false;
    while (t->head < t->count) {
        double d = t->due[t->head];
        if (d < 0.0) break;
        if (nowShared < d) return false;
        if (nowShared <= d + (double)BLOCK_GAP_WORDS * BUS_WORD_US) break;
        t->head++;
        m->listenerLost++;
    }
    if (t->head >= t->count) { t->head = t->count = 0; return false; }
    *out = t->w[t->head];
    return true;
}

static void queue_words_paced(MmuModel *m, const uint16_t *w, size_t n, bool paced) {
    /* Compact first if the head has run on, exactly as the framer does. */
    if (m->queueHead > 0 && m->queueCount + n > QUEUE_HW) {
        memmove(m->queue, m->queue + m->queueHead,
                (m->queueCount - m->queueHead) * sizeof m->queue[0]);
        memmove(m->slot, m->slot + m->queueHead,
                (m->queueCount - m->queueHead) * sizeof m->slot[0]);
        m->queueCount -= m->queueHead;
        m->queueHead = 0;
    }
    if (m->queueCount + n > QUEUE_HW) {
        fprintf(stderr, "mmu%d: reply queue full, dropping %zu words\n",
                m->unit, n);
        return;
    }
    /* An idle bus starts the clock again: word times are counted from the
     * first word of a burst, not from some transfer long finished. */
    if (m->queueHead >= m->queueCount && !m->burstPrimed) {
        m->burstStartUs = mm_now(m);
        m->nextSlot = 0;
    }
    m->burstPrimed = false;
    for (size_t i = 0; i < n; i++) {
        m->slot[m->queueCount + i] = paced ? m->nextSlot++ : SLOT_UNPACED;
    }
    memcpy(m->queue + m->queueCount, w, n * sizeof w[0]);
    size_t first = m->queueCount;
    m->queueCount += n;
    m->stats.wordsOut += (long)n;
    if (m->owner >= 1 && m->haveOffset) {
        /* EACH WORD AT ITS WIRE TIME.  A streamed word is due at its slot;
         * a reply follows the command, and each word the one before it, a
         * word time apart.  Releasing replies the moment the command was
         * issued put them into a listener before it had reached its receive:
         * FIOMMUPG's listener entries begin '#DLYI 0 *ALIGNMENT FOR LISTENER
         * PROGRAM', the delay drained the echo and the first status word,
         * the '#RDLI' took the second as its first, and the commander's next
         * command echo then error-terminated it with one word left -- an
         * overlay error on that computer alone, and ARCGPC dropped it from
         * the redundant set (ledger #139). */
        double nowShared = mm_now(m) + m->ownerOffsetUs;
        for (size_t i = 0; i < n; i++) {
            uint32_t sl = m->slot[first + i];
            bool paced = (sl != SLOT_UNPACED);
            double due;
            if (!paced) {
                due = (m->replyWireUs > nowShared ? m->replyWireUs : nowShared) + BUS_WORD_US;
                m->replyWireUs = due;
            } else {
                due = m->burstStartUs + (double)sl * BUS_WORD_US + m->ownerOffsetUs;
            }
            for (int r = 1; r <= 5; r++) {
                if (r == m->owner || m->tap[r].w == NULL) continue;
                tap_push(m, r, w[i], due, paced);
            }
        }
    }
}

static void queue_words(MmuModel *m, const uint16_t *w, size_t n) {
    queue_words_paced(m, w, n, false);
}

/* True with *out set if the word at the head of the queue has reached its
 * word time, i.e. is on the bus now.  Nothing is dropped here: a receive
 * the bus controller has armed is a hardware transfer and loses nothing,
 * however few slices the BCE happens to get.  Words are lost only where
 * the software arranges to lose them, by delaying -- iop_bce_delay is
 * what throws those away. */
static bool bus_word(MmuModel *m, uint16_t *out) {
    double now = mm_now(m);
    while (m->queueHead < m->queueCount) {
        uint32_t s = m->slot[m->queueHead];
        if (s == SLOT_UNPACED || !m->clockUs) break;
        double due = m->burstStartUs + (double)s * BUS_WORD_US;
        if (now < due) return false;            /* not on the bus yet */
        /* Long overdue, so nobody was listening.  A streamed word is gone
         * once it has gone past, and the bus program does not have to
         * account for every word a transfer puts on the wire: it takes
         * what it wants and stops, and GPCIPL's loader does exactly that,
         * leaving 360 of a 4096-word transfer unread.  Keeping them made
         * every later reply that many words late -- BSL1 read a leftover
         * tape word as the transport position and called ERROR 116.
         *
         * A whole block gap of grace, against a bus controller that drains
         * everything available each time it runs and gets a slice every 33
         * instructions: 8.4 ms of margin against about 50 us of exposure,
         * so this cannot reach a word an armed receive was going to take.
         * That margin is the whole reason the rule is safe, and it is why
         * the discard lives here and not in the receive, which cannot tell
         * "finished" from "between two receives of one transfer". */
        if (now <= due + (double)BLOCK_GAP_WORDS * BUS_WORD_US) break;
        m->queueHead++;
        m->stats.wordsLost++;
    }
    if (m->queueHead >= m->queueCount) return false;
    *out = m->queue[m->queueHead];
    return true;
}

static uint16_t pack_position(const MmuModel *m) {
    uint16_t w = (uint16_t)(((m->track & 7) << 11) | ((m->file & 7) << 8) |
                            ((m->subfile & 7) << 5));
    if (m->bof) w |= 0x0010;
    if (m->eof) w |= 0x0008;
    return w;
}

/* The block count that applies to this transfer: an EXTENDED BLOCK command
 * overrides the four bits in the transfer command itself, and is consumed
 * by the transfer it preceded.  Both are counts less one. */
static int transfer_blocks(MmuModel *m, int cmdCount) {
    int n = (m->extendedCount >= 0 ? m->extendedCount : cmdCount) + 1;
    m->extendedCount = -1;
    return n;
}

/* A position names a GAP, so a transfer ending in subfile S leaves the
 * transport reporting S+1 -- and when that would be 8, the end-of-file
 * bit instead. */
static void position_after(MmuModel *m, int startTrack, int startFile,
                           int startSubfile, int startBlock, int nBlocks) {
    int endIdx = block_index(startTrack, startFile, startSubfile, startBlock)
                 + nBlocks - 1;
    int endSubfile = (endIdx / BLOCKS_PER_SUBFILE) % SUBFILES;
    int subfile = endSubfile + 1;
    m->track = startTrack;
    /* file is wherever the transport was last positioned, not the
     * transfer command's -- a transfer command carries no file. */
    m->subfile = (subfile >= SUBFILES) ? 0 : subfile;
    m->bof = 0;
    m->eof = (subfile >= SUBFILES) ? 1 : 0;
}

static void do_read(MmuModel *m, int track, int subfile, int block, int count) {
    int n = transfer_blocks(m, count);
    int first = block_index(track, m->file, subfile, block);

    /* A transfer may run on through subfiles but not off the end of the
     * file it started in. */
    int fileEnd = (first / BLOCKS_PER_TRACK + 1) * BLOCKS_PER_TRACK;
    if (first + n > fileEnd) {
        fault(m, 'B', STAT_B_EOF_BLOCK_COUNT, "blocks run past the file");
        n = fileEnd - first;
        if (n <= 0) return;
    }

    mm_log(m, "read %d block(s) from %d/%d/%d/%d", n, track, m->file, subfile, block);
    /* The first word waits out the search (read_latency_words), counted
     * from now whether or not an unread reply keeps the burst open. */
    if (m->queueHead >= m->queueCount) {
        m->burstStartUs = mm_now(m);
        m->nextSlot = 0;
    }
    {
        double sinceUs = mm_now(m) - m->burstStartUs;
        uint32_t nowSlot = sinceUs > 0.0
            ? (uint32_t)((sinceUs + BUS_WORD_US - 1.0) / BUS_WORD_US) : 0;
        if (m->nextSlot < nowSlot + read_latency_words())
            m->nextSlot = nowSlot + read_latency_words();
        m->burstPrimed = true;
    }
    static uint16_t zero[HALFWORDS_PER_BLOCK];
    for (int i = 0; i < n; i++) {
        int idx = first + i;
        const uint16_t *b = (idx >= 0 && idx < BLOCKS_TOTAL && m->blocks[idx])
                                ? m->blocks[idx] : zero;
        queue_words_paced(m, b, HALFWORDS_PER_BLOCK, true);
        /* The gap to the next block: no words, just word times nothing
         * arrives in.  A delay that ends inside one is why the MIA still
         * holds the last word of the block when the next load block's
         * receive sequence starts, which is the word FCMBOOT emits an
         * extra one-halfword #RDLI to throw away. */
        if (i + 1 < n) m->nextSlot += BLOCK_GAP_WORDS;
        m->stats.blocksRead++;
    }
    position_after(m, track, m->file, subfile, block, n);
}

static void write_block_done(MmuModel *m) {
    int idx = m->writeFirst + m->writeDone;
    if (m->writeProtect) {
        fault(m, 'A', STAT_A_WRITE_PROTECT, "volume is write protected");
        m->writeActive = false;
        return;
    }
    if (idx >= 0 && idx < BLOCKS_TOTAL) {
        if (!m->blocks[idx]) {
            m->blocks[idx] = calloc(HALFWORDS_PER_BLOCK, sizeof(uint16_t));
            if (!m->blocks[idx]) { m->writeActive = false; return; }
        }
        memcpy(m->blocks[idx], m->writeBuf, sizeof m->writeBuf);
        if (m->dirty != NULL) m->dirty[idx] = 1;
    }
    m->stats.blocksWritten++;
    m->writeDone++;
    m->writeN = 0;
    position_after(m, m->writeStartTrack, m->writeStartFile,
                   m->writeStartSubfile, m->writeStartBlock, m->writeDone);
    uint16_t pos = pack_position(m);
    if (m->writeDone >= m->writeTotal) {
        m->writeActive = false;
        queue_words(m, &pos, 1);
    } else {
        /* Block complete, then the search complete word for the next. */
        queue_words(m, &pos, 1);
        queue_words(m, &pos, 1);
    }
}

static void on_command(MmuModel *m, uint32_t cmd24) {
    uint32_t cmd = cmd24 & 0xffffffu;
    int iua = (int)((cmd >> 19) & 0x1f);
    if (iua != IUA) return;                  /* not ours */
    int opcode = (int)((cmd >> 15) & 0x0f);
    m->stats.commands++;

    /* Every command, not just the ones with something to say.  Chasing a
     * status error the flight software reported and this unit had not
     * raised meant knowing what it had been ASKED, and only POSITION and
     * READ said anything at all -- twelve of sixteen commands passed
     * without a trace of them. */
    static const char *const opName[16] = {
        "POSITION", "BITE STATUS", "POSITION REQ", "EXTENDED BLOCK",
        "?4", "?5", "?6", "?7", "WRITE", "READ", "WRITE ENABLE",
        "?B", "?C", "?D", "?E", "?F"
    };
    /* A new command ends the last transfer, and whatever it was still
     * streaming is gone -- the unit stops sending and starts answering.
     * Ageing those words out on the clock alone was not enough: the grace
     * a streamed word gets is a whole block gap, and the loader issues its
     * next command sooner than that, so 360 unread words of an 8-block
     * transfer were still queued when the following BITE STATUS arrived.
     * Once the sequence slips it never recovers, because a REPLY is not
     * paced and so never ages out at all: two orphaned status words sat at
     * the head of the queue for the rest of the run and every later reply
     * was read two words late.
     *
     * Only streamed words go.  A reply the bus program has not collected
     * yet is not something this unit would have thrown away, and nothing
     * in the software races one. */
    while (m->queueHead < m->queueCount && m->slot[m->queueHead] != SLOT_UNPACED) {
        m->queueHead++;
        m->stats.wordsLost++;
    }

    /* The pending count is the thing to watch.  A reply is only read for
     * the command that asked for it while the queue is empty when it is
     * queued; anything left over puts every later reply that many places
     * late, which is how a POSITION word ends up read as a status word. */
    mm_log(m, "cmd %06x  %-14s  pending %zu", cmd, opName[opcode],
           m->queueCount - m->queueHead);

    /* A command arriving mid-transfer is an error in its own right, and
     * the transfer it interrupted is abandoned. */
    if (m->writeActive) {
        fault(m, 'B', STAT_B_NOT_READY, "command during a write transfer");
        m->writeActive = false;
    }

    switch (opcode) {
    case OP_POSITION:
        m->track = (int)((cmd >> 12) & 7);
        m->subfile = (int)((cmd >> 9) & 7);
        m->bof = (int)((cmd >> 7) & 1);
        m->eof = (int)((cmd >> 6) & 1);
        m->file = (int)((cmd >> 1) & 7);
        mm_log(m, "position -> %d/%d/%d", m->track, m->file, m->subfile);
        break;
    case OP_BITE_STATUS: {
        uint16_t w[2] = {m->statusA, m->statusB};
        m->statusA = 0;
        m->statusB = 0;                      /* the read clears the latch */
        queue_words(m, w, 2);
        break;
    }
    case OP_POSITION_REQ: {
        uint16_t w = pack_position(m);
        queue_words(m, &w, 1);
        break;
    }
    case OP_EXTENDED_BLOCK:
        m->extendedCount = (int)(cmd & 0xff);
        break;
    case OP_WRITE_ENABLE:
        if (m->writeProtect) {
            fault(m, 'A', STAT_A_WRITE_PROTECT, "volume is write protected");
            break;
        }
        m->writeEnabledTrack = (int)((cmd >> 12) & 7);
        break;
    case OP_READ:
        do_read(m, (int)((cmd >> 12) & 7), (int)((cmd >> 9) & 7),
                (int)((cmd >> 4) & 0x1f), (int)(cmd & 0x0f));
        break;
    case OP_WRITE: {
        int track = (int)((cmd >> 12) & 7);
        int subfile = (int)((cmd >> 9) & 7);
        int block = (int)((cmd >> 4) & 0x1f);
        int n = transfer_blocks(m, (int)(cmd & 0x0f));
        if (m->writeProtect) {
            fault(m, 'A', STAT_A_WRITE_PROTECT, "volume is write protected");
            break;
        }
        if (m->writeEnabledTrack != track) {
            fault(m, 'A', STAT_A_WRITE_PROTECT, "track is not write enabled");
            break;
        }
        m->writeActive = true;
        m->writeFirst = block_index(track, m->file, subfile, block);
        m->writeStartTrack = track; m->writeStartFile = m->file;
        m->writeStartSubfile = subfile; m->writeStartBlock = block;
        m->writeDone = 0; m->writeTotal = n; m->writeN = 0;
        /* The search complete word: "the head is over the block". */
        uint16_t pos = pack_position(m);
        queue_words(m, &pos, 1);
        break;
    }
    default:
        fault(m, 'A', STAT_A_INVALID_COMMAND, "unknown opcode");
        break;
    }
}

static void on_data(MmuModel *m, uint16_t hw) {
    if (!m->writeActive) {
        fault(m, 'B', STAT_B_NOT_READY, "data word with no transfer in progress");
        return;
    }
    m->stats.wordsIn++;
    m->writeBuf[m->writeN++] = hw;
    if (m->writeN == HALFWORDS_PER_BLOCK) write_block_done(m);
}

/* ---------------------------------------------------------------------
 * Volume file (volume.coffee's own format)
 *
 *   0   magic "MMUVOL01"            8 bytes
 *   8   halfwords per block         u32
 *  12   number of directory entries u32
 *  16   flags                       u32   bit 0 = write protected
 *  20   reserved                    12 bytes
 *  32   directory                   entries x u32 block index, ascending
 *  ...  block data                  one block per entry, same order
 *
 * All big-endian.  A block absent from the directory reads back as zeros.
 * ------------------------------------------------------------------- */

static uint32_t be32(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) |
           ((uint32_t)p[2] << 8) | (uint32_t)p[3];
}

static bool load_volume(MmuModel *m, const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) { fprintf(stderr, "mmu: cannot open %s\n", path); return false; }
    uint8_t hdr[32];
    if (fread(hdr, 1, sizeof hdr, f) != sizeof hdr ||
        memcmp(hdr, "MMUVOL01", 8) != 0) {
        fprintf(stderr, "mmu: %s is not an MMUVOL01 volume\n", path);
        fclose(f);
        return false;
    }
    uint32_t hwPerBlock = be32(hdr + 8);
    uint32_t entries = be32(hdr + 12);
    uint32_t flags = be32(hdr + 16);
    if (hwPerBlock != HALFWORDS_PER_BLOCK) {
        fprintf(stderr, "mmu: %s has %u halfwords per block, expected %d\n",
                path, hwPerBlock, HALFWORDS_PER_BLOCK);
        fclose(f);
        return false;
    }
    m->writeProtect = (flags & 1u) != 0;

    uint32_t *dir = calloc(entries ? entries : 1, sizeof(uint32_t));
    if (!dir) { fclose(f); return false; }
    for (uint32_t i = 0; i < entries; i++) {
        uint8_t w[4];
        if (fread(w, 1, 4, f) != 4) {
            fprintf(stderr, "mmu: %s: short directory\n", path);
            free(dir); fclose(f); return false;
        }
        dir[i] = be32(w);
    }
    for (uint32_t i = 0; i < entries; i++) {
        uint32_t idx = dir[i];
        uint16_t *blk = calloc(HALFWORDS_PER_BLOCK, sizeof(uint16_t));
        if (!blk) { free(dir); fclose(f); return false; }
        for (int h = 0; h < HALFWORDS_PER_BLOCK; h++) {
            int hi = fgetc(f), lo = fgetc(f);
            if (hi == EOF || lo == EOF) {
                fprintf(stderr, "mmu: %s: short block data\n", path);
                free(blk); free(dir); fclose(f); return false;
            }
            blk[h] = (uint16_t)((hi << 8) | lo);
        }
        if (idx < BLOCKS_TOTAL) m->blocks[idx] = blk;
        else free(blk);
    }
    fprintf(stderr, "mmu%d: %u block(s) from %s%s\n", m->unit, entries, path,
            m->writeProtect ? " (write protected)" : "");
    free(dir);
    fclose(f);
    return true;
}

MmuModel *mmumodel_create(int unit, const char *volumePath) {
    if (unit != 1 && unit != 2) {
        fprintf(stderr, "mmu: unit must be 1 or 2\n");
        return NULL;
    }
    MmuModel *m = calloc(1, sizeof *m);
    if (!m) return NULL;
    m->unit = unit;
    m->busID = (unit == 1) ? 18 : 19;      /* MM1 is BCE 18, MM2 is BCE 19 */
    m->verbose = yagpc_getenv("YAGPC_MMUTRACE") != NULL;
    m->writeEnabledTrack = -1;
    m->extendedCount = -1;
    m->bof = 1;                            /* beginning of tape at power up */
    m->blocks = calloc(BLOCKS_TOTAL, sizeof(uint16_t *));
    if (!m->blocks) { free(m); return NULL; }
    m->dirty = calloc(BLOCKS_TOTAL, 1);
    if (!m->dirty) { free(m->blocks); free(m); return NULL; }

    if (volumePath && *volumePath) {
        if (!load_volume(m, volumePath)) { mmumodel_free(m); return NULL; }
    } else {
        fprintf(stderr, "mmu%d: blank tape\n", m->unit);
    }
    return m;
}

int mmumodel_bus(const MmuModel *m) { return m ? m->busID : -1; }

void mmumodel_set_discretes(MmuModel *m, struct Discretes *d) {
    if (m) m->lines = d;
    if (m && d) {
        bool have = false;
        for (int i = 0; i < m->nReadyOut; i++) have = have || m->readyOut[i].d == d;
        if (!have && m->nReadyOut < 6) m->readyOut[m->nReadyOut++].d = d;
    }
}

void mmumodel_free(MmuModel *m) {
    if (!m) return;
    for (int r = 0; r < 6; r++) { free(m->tap[r].w); free(m->tap[r].due); free(m->tap[r].paced); }
    if (m->blocks) {
        free(m->dirty);
        for (int i = 0; i < BLOCKS_TOTAL; i++) free(m->blocks[i]);
        free(m->blocks);
    }
    free(m);
}

void mmumodel_set_clock(MmuModel *m, const double *clockUs) {
    if (m) m->clockUs = clockUs;
}

/* Republish at least this often.  Comfortably inside the subscribers'
 * DISCRETES_STALE_SEC, and the same period the crew panel uses for its own
 * switches.  Wall time, not the emulated clock: what is watching this is a
 * person, and --time-scale must not change how often a level is refreshed. */
#define READY_REPUBLISH_SEC 0.25

/* Raise READY when the transfer has gone past on the wire, rather than when
 * the host has consumed it.  YAGPC_MMU_QUEUE_READY restores the older
 * consumed-the-queue rule, for comparing against it.
 *
 * WHY THIS EXISTS, AND WHY IT IS NOW THE DEFAULT.  READY here is a PROXY --
 * HANDOFF-FCMBOOT.md says so plainly: on real hardware it is a line driven by
 * the mass memory, while here it tracks whether our own bus controller is
 * still running.  That caveat predicted the proxy failing by raising READY
 * EARLY, if the MMU were still positioning after our BCE went idle.  The OPS 9
 * transition to G9 hits the OPPOSITE failure of the same approximation, and it
 * deadlocks: `ready` below is gated on the output queue draining, the queue
 * advances only in bus_word() when the BCE polls it, and the BCE has stopped
 * because the flight software is blocked waiting for READY.  Phase 3's 26
 * blocks are consumed before the wait begins and escape it; phase 8's 110
 * multi-track blocks are not, ~33000 words stay queued, READY never returns,
 * FCMMGPOV never reaches its signal point, ARC_OVL_EVT is never set, and
 * ARCGPC's overlay loop never advances to the slot that would request phase
 * 18.
 *
 * A synthetic busy-timer written for READY once before was removed as
 * "treating the symptom" when the transfer was made to go over the bus and be
 * paced to real time.  This is not that timer: it uses the pacing already
 * here, asking whether the LAST QUEUED WORD's slot time has passed, so it
 * cannot rise before the wire would have carried the data.
 *
 * It was opt-in while it was one candidate explanation among several.  It is
 * the default now because the alternative is not neutral: the consumed-the-
 * queue rule DEADLOCKS, as above, and a deadlock is not a more conservative
 * approximation than a timing estimate that is bounded below by the wire.
 * Both are approximations of a signal the MMU ought to report itself; proper
 * fidelity still needs MMU-side work and a protocol change, per the same
 * caveat.  YAGPC_MMU_TIMED_READY is still accepted, and is now a no-op. */
static bool timed_ready_enabled(void) {
    static int inited = 0, on = 0;
    if (!inited) { inited = 1; on = yagpc_getenv("YAGPC_MMU_QUEUE_READY") == NULL; }
    return on != 0;
}

/* Ready when it is not moving data: nothing left over from a read and no
 * write running (with the timed grace below). */
static bool mm_ready_now(MmuModel *m);

/* The unit's READY on one computer's channel -- see readyOut. */
void mmumodel_publish_ready_on(MmuModel *m, struct Discretes *d) {
    if (!m || !discretes_enabled(d)) return;
    int k = -1;
    for (int i = 0; i < m->nReadyOut; i++) if (m->readyOut[i].d == d) k = i;
    if (k < 0) return;
    bool ready = mm_ready_now(m);
    double now = yagpc_monotonic_seconds();
    if (m->readyOut[k].published && ready == m->readyOut[k].last &&
        now - m->readyOut[k].lastSec < READY_REPUBLISH_SEC)
        return;
    uint32_t bit = (m->unit == 2) ? DISCRETE_A_MM2_READY : DISCRETE_A_MM1_READY;
    discretes_publish(d, DISCRETES_REG_A, bit, ready);
    if (k == 0 && m->verbose && (!m->readyOut[k].published || ready != m->readyOut[k].last))
        mm_log(m, "READY -> %d", (int)ready);
    m->readyOut[k].last = ready;
    m->readyOut[k].published = true;
    m->readyOut[k].lastSec = now;
}

static bool mm_ready_now(MmuModel *m) {
    bool ready = (m->queueHead >= m->queueCount) && !m->writeActive;
    if (!ready && !m->writeActive && timed_ready_enabled() && m->clockUs &&
        m->nextSlot > 0) {
        double lastDue = m->burstStartUs +
                         (double)(m->nextSlot - 1) * BUS_WORD_US;
        if (mm_now(m) > lastDue + (double)BLOCK_GAP_WORDS * BUS_WORD_US)
            ready = true;
    }
    return ready;
}

void mmumodel_publish_ready(MmuModel *m) {
    if (!m || !discretes_enabled(m->lines)) return;
    /* Ready when it is not moving data: nothing left over from a read and
     * no write running. */
    bool ready = (m->queueHead >= m->queueCount) && !m->writeActive;
    if (!ready && !m->writeActive && timed_ready_enabled() && m->clockUs &&
        m->nextSlot > 0) {
        /* The last word this burst queued is due at its own slot time; give
         * it the same block-gap grace bus_word() uses before it calls a word
         * gone past. */
        double lastDue = m->burstStartUs +
                         (double)(m->nextSlot - 1) * BUS_WORD_US;
        if (mm_now(m) > lastDue + (double)BLOCK_GAP_WORDS * BUS_WORD_US)
            ready = true;
    }
    double now = yagpc_monotonic_seconds();
    if (m->readyPublished && ready == m->lastReady &&
        now - m->lastReadyPublishSec < READY_REPUBLISH_SEC)
        return;
    uint32_t bit = (m->unit == 2) ? DISCRETE_A_MM2_READY : DISCRETE_A_MM1_READY;
    discretes_publish(m->lines, DISCRETES_REG_A, bit, ready);
    if (m->verbose && (!m->readyPublished || ready != m->lastReady))
        mm_log(m, "READY -> %d", (int)ready);
    m->lastReady = ready;
    m->readyPublished = true;
    m->lastReadyPublishSec = now;
}

/* Mid-transfer: this unit still owes the computer that commanded it words
 * from the block it is reading.  See vehicle_bus_enter -- a second computer
 * commanding the unit here does not queue behind the first, it overwrites
 * the first's conversation, which is a finding rather than a condition to
 * handle. */
bool mmumodel_in_transfer(const MmuModel *m) {
    return m != NULL && m->queueCount > m->queueHead;
}

void mmumodel_report(const MmuModel *m) {
    if (!m) return;
    fprintf(stderr,
            "mmu%d: {\"commands\":%ld,\"blocksRead\":%ld,\"blocksWritten\":%ld,"
            "\"wordsOut\":%ld,\"wordsTaken\":%ld,\"wordsLost\":%ld,"
            "\"wordsIn\":%ld,\"position\":\"%d/%d/%d\"}\n",
            m->unit, m->stats.commands, m->stats.blocksRead,
            m->stats.blocksWritten, m->stats.wordsOut, m->stats.wordsTaken,
            m->stats.wordsLost, m->stats.wordsIn, m->track, m->file, m->subfile);
    if (m->listenerWords > 0 || m->listenerLost > 0)
        fprintf(stderr, "mmu%d listeners: %ld word(s) delivered, %ld gone past unread\n",
                m->unit, m->listenerWords, m->listenerLost);
    /* Words this bus carried BETWEEN COMPUTERS, which are nothing to do with
     * the unit itself -- see the `gtg` field. */
    if (m->gtgWords > 0)
        fprintf(stderr, "mmu%d bus: %ld word(s) carried GPC-to-GPC\n",
                m->unit, m->gtgWords);
}

void mmumodel_service(void *ctx, GpcServiceNumber serviceNumber,
                      const GpcServiceInput *input, GpcServiceOutput *output) {
    MmuModel *m = (MmuModel *)ctx;
    if (!m || !input || !output) return;

    if (input->busID != m->busID) {
        /* Another bus: nothing is listening, which is the truth. */
        switch (serviceNumber) {
        case GPC_SVC_XMIT_CMD:
        case GPC_SVC_XMIT_WORD: output->out.xmit.ok = true; break;
        case GPC_SVC_RECV_POLL: output->out.poll.available = false; break;
        case GPC_SVC_RECV_WORD: output->out.recv.available = false; break;
        default: break;
        }
        return;
    }

    switch (serviceNumber) {
    case GPC_SVC_XMIT_CMD:
        on_command(m, input->in.word);
        output->out.xmit.ok = true;
        break;
    case GPC_SVC_XMIT_WORD:
        on_data(m, (uint16_t)(input->in.word & 0xffff));
        output->out.xmit.ok = true;
        break;
    case GPC_SVC_RECV_POLL: {
        uint16_t w;
        output->out.poll.available = bus_word(m, &w);
        break;
    }
    case GPC_SVC_RECV_WORD: {
        uint16_t w;
        if (bus_word(m, &w)) {
            output->out.recv.word = w;
            output->out.recv.available = true;
            m->queueHead++;
            m->stats.wordsTaken++;
            if (m->queueHead == m->queueCount) m->queueHead = m->queueCount = 0;
        } else {
            output->out.recv.available = false;
        }
        break;
    }
    default:
        break;
    }
}

void mmumodel_service_as(MmuModel *m, int gpcId, double sharedUs,
                         GpcServiceNumber serviceNumber,
                         const GpcServiceInput *input, GpcServiceOutput *output) {
    if (!m || !input || !output) return;
    int g = (gpcId >= 1 && gpcId <= 5) ? gpcId : 0;
    if (g != 0 && sharedUs >= 0.0 && input->busID == m->busID) {
        struct MmuTap *t = &m->tap[g];
        if (t->w == NULL) {
            t->w = calloc(QUEUE_HW, sizeof t->w[0]);
            t->due = calloc(QUEUE_HW, sizeof t->due[0]);
            t->paced = calloc(QUEUE_HW, sizeof t->paced[0]);
            if (t->w == NULL || t->due == NULL || t->paced == NULL) {
                free(t->w); free(t->due); free(t->paced);
                t->w = NULL; t->due = NULL; t->paced = NULL;
            }
        }
        switch (serviceNumber) {
        case GPC_SVC_XMIT_CMD: {
            /* Only a computer whose transmitter is enabled gets here -- the
             * BCE instructions gate the command -- so this is the commander.
             * A different one taking over starts every listener afresh. */
            if (g != m->owner) {
                for (int r = 1; r <= 5; r++) m->tap[r].head = m->tap[r].count = 0;
                m->owner = g;
            }
            m->ownerOffsetUs = sharedUs - mm_now(m);
            m->haveOffset = true;
            uint32_t cmd = input->in.word & 0xffffffu;
            /* The command word goes on the wire after the reply words ahead
             * of it; a stream in progress simply stops. */
            double echoDue = (m->replyWireUs > sharedUs ? m->replyWireUs : sharedUs) + BUS_WORD_US;
            /* A command names this unit or the GPC overlay address; the
             * listeners are told of either, because a BCE in Listen Mode
             * starts on a command with a matching IUA (BCE Principles of
             * Operation section 4.1, and iop.c's own listen path).  ANY
             * OTHER address is left alone: echoing every command flooded
             * the listener queues -- half a million words past unread in a
             * five-minute run -- and cost the set its synchronisation. */
            int cmdIua = (int)((cmd >> 19) & 0x1f);
            m->gtg = gtg_on() && (cmdIua == GTG_IUA);
            if (cmdIua != IUA && !m->gtg) break;
            m->replyWireUs = echoDue;
            for (int r = 1; r <= 5; r++) {
                if (r == g || m->tap[r].w == NULL) continue;
                /* Wire order: the echo follows the replies already
                 * sent, and a word nobody takes ages out in tap_word. */
                tap_end_stream(m, r, sharedUs);
                tap_push(m, r, cmd | YAGPC_BUSWORD_CMD_SYNC, echoDue, false);
            }
            break;                      /* and on to the unit itself, below */
        }
        case GPC_SVC_XMIT_WORD:
            if (g == m->owner) { m->ownerOffsetUs = sharedUs - mm_now(m); m->haveOffset = true; }
            /* THE WORDS OF A GPC-TO-GPC TRANSFER.  Addressed to another
             * computer, they are nothing to this unit, but they are on the
             * wire and the other computers' receivers must have them -- one
             * word time apart, as everything else on this bus is.  Without
             * this an OPS transition whose overlay source is a GPC simply
             * never arrives: the targets all time out, ARC marks them failed
             * and gives up before trying mass memory, and the vehicle stays
             * in the OPS it was in (ledger #199). */
            if (m->gtg && g == m->owner) {
                uint32_t w = input->in.word & 0xffffu;
                for (int r = 1; r <= 5; r++) {
                    if (r == g || m->tap[r].w == NULL) continue;
                    double due = (m->replyWireUs > sharedUs ? m->replyWireUs
                                                            : sharedUs) + BUS_WORD_US;
                    tap_push(m, r, w, due, false);
                }
                m->replyWireUs = (m->replyWireUs > sharedUs ? m->replyWireUs
                                                            : sharedUs) + BUS_WORD_US;
                m->gtgWords++;
                return;                 /* not this unit's business */
            }
            break;
        case GPC_SVC_RECV_POLL:
            if (m->owner != 0 && g != m->owner) {
                uint32_t w;
                output->out.poll.available = tap_word(m, g, sharedUs, &w);
                return;
            }
            break;
        case GPC_SVC_RECV_WORD:
            if (m->owner != 0 && g != m->owner) {
                uint32_t w;
                if (tap_word(m, g, sharedUs, &w)) {
                    output->out.recv.word = w;
                    output->out.recv.available = true;
                    t->head++;
                    if (t->head == t->count) t->head = t->count = 0;
                    m->listenerWords++;
                } else {
                    output->out.recv.available = false;
                }
                return;
            }
            break;
        default:
            break;
        }
    }
    mmumodel_service(m, serviceNumber, input, output);
}

/* ---------------------------------------------------------------------
 * CAPTURE AND RESTORE -- see mmumodel.h.
 * ------------------------------------------------------------------- */

static void mmu_paths(const MmuModel *m, const char *dir,
                      char *js, size_t njs, char *bin, size_t nbin) {
    snprintf(js, njs, "%s/mmu%d.json", dir, m->unit);
    snprintf(bin, nbin, "%s/mmu%d.blocks.bin", dir, m->unit);
}

bool mmumodel_dump(const MmuModel *m, const char *dir, double nowUs) {
    if (m == NULL || dir == NULL) return false;
    char js[512], bin[512];
    mmu_paths(m, dir, js, sizeof js, bin, sizeof bin);

    /* THE WRITTEN BLOCKS FIRST, so the JSON is only written once their
     * count is known and a reader can trust the two agree. */
    uint32_t written = 0;
    for (int i = 0; i < BLOCKS_TOTAL; i++)
        if (m->dirty[i] && m->blocks[i]) written++;
    if (written > 0) {
        FILE *b = fopen(bin, "wb");
        if (b == NULL) {
            fprintf(stderr, "mmu%d: cannot write %s\n", m->unit, bin);
            return false;
        }
        for (int i = 0; i < BLOCKS_TOTAL; i++) {
            if (!m->dirty[i] || !m->blocks[i]) continue;
            uint8_t hdr[4] = { (uint8_t)(i >> 24), (uint8_t)(i >> 16),
                               (uint8_t)(i >> 8), (uint8_t)i };
            fwrite(hdr, 1, 4, b);
            for (int h = 0; h < HALFWORDS_PER_BLOCK; h++) {
                uint8_t w[2] = { (uint8_t)(m->blocks[i][h] >> 8),
                                 (uint8_t)m->blocks[i][h] };
                fwrite(w, 1, 2, b);
            }
        }
        if (fclose(b) != 0) {
            fprintf(stderr, "mmu%d: cannot finish %s\n", m->unit, bin);
            return false;
        }
    }

    FILE *f = fopen(js, "w");
    if (f == NULL) {
        fprintf(stderr, "mmu%d: cannot write %s\n", m->unit, js);
        return false;
    }
    fprintf(f, "{\n  \"unit\": %d,\n  \"writtenBlocks\": %u,\n",
            m->unit, (unsigned)written);
    fprintf(f, "  \"track\": %d,\n  \"file\": %d,\n  \"subfile\": %d,\n",
            m->track, m->file, m->subfile);
    fprintf(f, "  \"bof\": %d,\n  \"eof\": %d,\n", m->bof, m->eof);
    fprintf(f, "  \"statusA\": %u,\n  \"statusB\": %u,\n",
            (unsigned)m->statusA, (unsigned)m->statusB);
    fprintf(f, "  \"writeEnabledTrack\": %d,\n  \"extendedCount\": %d,\n",
            m->writeEnabledTrack, m->extendedCount);
    fprintf(f, "  \"owner\": %d,\n", m->owner);
    /* A TRANSFER STILL BEING HANDED OVER.  queue/slot are what the unit has
     * yet to put on the wire; without them a machine that was collecting a
     * read resumes waiting for words that no longer exist. */
    fprintf(f, "  \"queue\": [");
    for (size_t i = 0; i < m->queueCount; i++)
        fprintf(f, "%s%u", i ? "," : "",
                (unsigned)m->queue[(m->queueHead + i) % QUEUE_HW]);
    fprintf(f, "],\n  \"slots\": [");
    for (size_t i = 0; i < m->queueCount; i++)
        fprintf(f, "%s%u", i ? "," : "",
                (unsigned)m->slot[(m->queueHead + i) % QUEUE_HW]);
    fprintf(f, "],\n");
    fprintf(f, "  \"burstStart\": %.3f,\n  \"nextSlot\": %u,\n"
               "  \"burstPrimed\": %d,\n",
            m->burstPrimed ? m->burstStartUs - nowUs : 0.0,
            (unsigned)m->nextSlot, m->burstPrimed ? 1 : 0);
    fprintf(f, "  \"writeActive\": %d,\n  \"writeFirst\": %d,\n"
               "  \"writeDone\": %d,\n  \"writeTotal\": %d,\n  \"writeN\": %d,\n",
            m->writeActive ? 1 : 0, m->writeFirst, m->writeDone,
            m->writeTotal, m->writeN);
    fprintf(f, "  \"writeStart\": [%d,%d,%d,%d]\n}\n",
            m->writeStartTrack, m->writeStartFile, m->writeStartSubfile,
            m->writeStartBlock);
    if (fclose(f) != 0) {
        fprintf(stderr, "mmu%d: cannot finish %s\n", m->unit, js);
        return false;
    }
    fprintf(stderr, "mmu%d: captured at %d/%d/%d, %u written block(s)\n",
            m->unit, m->track, m->file, m->subfile, (unsigned)written);
    return true;
}

bool mmumodel_load(MmuModel *m, const char *dir, double nowUs) {
    if (m == NULL || dir == NULL) return false;
    char js[512], bin[512];
    mmu_paths(m, dir, js, sizeof js, bin, sizeof bin);
    FILE *f = fopen(js, "rb");
    if (f == NULL) return false;         /* a capture from before this */
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return false; }
    long n = ftell(f);
    if (n < 0 || fseek(f, 0, SEEK_SET) != 0) { fclose(f); return false; }
    char *text = (char *)malloc((size_t)n + 1);
    if (text == NULL || fread(text, 1, (size_t)n, f) != (size_t)n) {
        free(text); fclose(f);
        fprintf(stderr, "mmu%d: cannot read %s\n", m->unit, js);
        return false;
    }
    text[n] = '\0';
    fclose(f);
    JsonValue *root = json_parse(text);
    free(text);
    if (root == NULL) {
        fprintf(stderr, "mmu%d: %s is not JSON\n", m->unit, js);
        return false;
    }
    m->track = (int)json_as_number(json_obj_get(root, "track"), m->track);
    m->file = (int)json_as_number(json_obj_get(root, "file"), m->file);
    m->subfile = (int)json_as_number(json_obj_get(root, "subfile"), m->subfile);
    m->bof = (int)json_as_number(json_obj_get(root, "bof"), m->bof);
    m->eof = (int)json_as_number(json_obj_get(root, "eof"), m->eof);
    m->statusA = (uint16_t)json_as_number(json_obj_get(root, "statusA"), 0);
    m->statusB = (uint16_t)json_as_number(json_obj_get(root, "statusB"), 0);
    m->writeEnabledTrack =
        (int)json_as_number(json_obj_get(root, "writeEnabledTrack"), -1);
    m->extendedCount =
        (int)json_as_number(json_obj_get(root, "extendedCount"), -1);
    m->owner = (int)json_as_number(json_obj_get(root, "owner"), 0);
    m->haveOffset = false;               /* recomputed against the new clock */
    JsonValue *q = json_obj_get(root, "queue");
    JsonValue *sl = json_obj_get(root, "slots");
    int cnt = json_arr_count(q);
    if (cnt > (int)QUEUE_HW) cnt = (int)QUEUE_HW;
    m->queueHead = 0;
    m->queueCount = (size_t)(cnt < 0 ? 0 : cnt);
    for (int i = 0; i < cnt; i++) {
        m->queue[i] = (uint16_t)json_as_number(json_arr_get(q, i), 0);
        m->slot[i] = (uint32_t)json_as_number(json_arr_get(sl, i), 0);
    }
    m->burstPrimed = json_as_number(json_obj_get(root, "burstPrimed"), 0) != 0;
    m->burstStartUs = m->burstPrimed
        ? nowUs + json_as_number(json_obj_get(root, "burstStart"), 0.0) : 0.0;
    m->nextSlot = (uint32_t)json_as_number(json_obj_get(root, "nextSlot"), 0);
    m->writeActive =
        json_as_number(json_obj_get(root, "writeActive"), 0) != 0;
    m->writeFirst = (int)json_as_number(json_obj_get(root, "writeFirst"), 0);
    m->writeDone = (int)json_as_number(json_obj_get(root, "writeDone"), 0);
    m->writeTotal = (int)json_as_number(json_obj_get(root, "writeTotal"), 0);
    m->writeN = (int)json_as_number(json_obj_get(root, "writeN"), 0);
    JsonValue *ws = json_obj_get(root, "writeStart");
    if (json_arr_count(ws) == 4) {
        m->writeStartTrack = (int)json_as_number(json_arr_get(ws, 0), 0);
        m->writeStartFile = (int)json_as_number(json_arr_get(ws, 1), 0);
        m->writeStartSubfile = (int)json_as_number(json_arr_get(ws, 2), 0);
        m->writeStartBlock = (int)json_as_number(json_arr_get(ws, 3), 0);
    }
    uint32_t want = (uint32_t)json_as_number(json_obj_get(root, "writtenBlocks"), 0);
    json_free(root);

    uint32_t got = 0;
    if (want > 0) {
        FILE *b = fopen(bin, "rb");
        if (b == NULL) {
            fprintf(stderr, "mmu%d: %s says %u written block(s) but %s is "
                            "missing -- REFUSING, a mass memory missing what "
                            "the software wrote is not the one captured\n",
                    m->unit, js, (unsigned)want, bin);
            return false;
        }
        for (uint32_t k = 0; k < want; k++) {
            uint8_t hdr[4];
            if (fread(hdr, 1, 4, b) != 4) break;
            uint32_t idx = ((uint32_t)hdr[0] << 24) | ((uint32_t)hdr[1] << 16) |
                           ((uint32_t)hdr[2] << 8) | hdr[3];
            uint16_t buf[HALFWORDS_PER_BLOCK];
            bool shortRead = false;
            for (int h = 0; h < HALFWORDS_PER_BLOCK; h++) {
                int hi = fgetc(b), lo = fgetc(b);
                if (hi == EOF || lo == EOF) { shortRead = true; break; }
                buf[h] = (uint16_t)((hi << 8) | lo);
            }
            if (shortRead) break;
            if (idx >= BLOCKS_TOTAL) continue;
            if (!m->blocks[idx])
                m->blocks[idx] = calloc(HALFWORDS_PER_BLOCK, sizeof(uint16_t));
            if (!m->blocks[idx]) break;
            memcpy(m->blocks[idx], buf, sizeof buf);
            m->dirty[idx] = 1;
            got++;
        }
        fclose(b);
        if (got != want) {
            fprintf(stderr, "mmu%d: %s holds %u of the %u written block(s) it "
                            "should -- REFUSING\n",
                    m->unit, bin, (unsigned)got, (unsigned)want);
            return false;
        }
    }
    fprintf(stderr, "mmu%d: restored at %d/%d/%d, %u written block(s)\n",
            m->unit, m->track, m->file, m->subfile, (unsigned)got);
    return true;
}
