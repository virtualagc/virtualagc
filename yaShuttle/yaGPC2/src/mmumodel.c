/* In-process mass memory unit; see mmumodel.h. */
#include "mmumodel.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
#define BLOCK_GAP_WORDS 256          /* FCMBOOT's 128 is HALF a block gap */
#define SLOT_UNPACED 0xffffffffu

struct MmuModel {
    int unit;
    int busID;
    bool verbose;

    /* Tape image.  blocks[i] is NULL for a block the volume never
     * recorded; volume.coffee reads those back as zeros. */
    uint16_t **blocks;
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

    struct {
        long commands, blocksRead, blocksWritten, wordsOut, wordsIn;
    } stats;
};

static int block_index(int track, int file, int subfile, int block) {
    return (((file & 7) * TRACKS + (track & 7)) * SUBFILES + (subfile & 7))
               * BLOCKS_PER_SUBFILE + (block & 0x1f);
}

static void mm_log(MmuModel *m, const char *fmt, ...) {
    if (!m->verbose) return;
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "mmu%d: ", m->unit);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n");
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
    if (m->queueHead >= m->queueCount) {
        m->burstStartUs = mm_now(m);
        m->nextSlot = 0;
    }
    for (size_t i = 0; i < n; i++) {
        m->slot[m->queueCount + i] = paced ? m->nextSlot++ : SLOT_UNPACED;
    }
    memcpy(m->queue + m->queueCount, w, n * sizeof w[0]);
    m->queueCount += n;
    m->stats.wordsOut += (long)n;
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
    if (m->queueHead >= m->queueCount) return false;
    uint32_t s = m->slot[m->queueHead];
    if (s != SLOT_UNPACED && m->clockUs &&
        mm_now(m) < m->burstStartUs + (double)s * BUS_WORD_US)
        return false;
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
    m->verbose = getenv("YAGPC_MMUTRACE") != NULL;
    m->writeEnabledTrack = -1;
    m->extendedCount = -1;
    m->bof = 1;                            /* beginning of tape at power up */
    m->blocks = calloc(BLOCKS_TOTAL, sizeof(uint16_t *));
    if (!m->blocks) { free(m); return NULL; }

    if (volumePath && *volumePath) {
        if (!load_volume(m, volumePath)) { mmumodel_free(m); return NULL; }
    } else {
        fprintf(stderr, "mmu%d: blank tape\n", m->unit);
    }
    return m;
}

int mmumodel_bus(const MmuModel *m) { return m ? m->busID : -1; }

void mmumodel_free(MmuModel *m) {
    if (!m) return;
    if (m->blocks) {
        for (int i = 0; i < BLOCKS_TOTAL; i++) free(m->blocks[i]);
        free(m->blocks);
    }
    free(m);
}

void mmumodel_set_clock(MmuModel *m, const double *clockUs) {
    if (m) m->clockUs = clockUs;
}

void mmumodel_report(const MmuModel *m) {
    if (!m) return;
    fprintf(stderr,
            "mmu%d: {\"commands\":%ld,\"blocksRead\":%ld,\"blocksWritten\":%ld,"
            "\"wordsOut\":%ld,\"wordsIn\":%ld,\"position\":\"%d/%d/%d\"}\n",
            m->unit, m->stats.commands, m->stats.blocksRead,
            m->stats.blocksWritten, m->stats.wordsOut, m->stats.wordsIn,
            m->track, m->file, m->subfile);
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
