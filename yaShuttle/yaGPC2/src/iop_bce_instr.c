/* BCE (Bus Control Element) instruction set, ported from
 * gpc/iop_bce_instr.coffee. See that file's extensive doc comments
 * (IBM-6246556A) for the hardware semantics; kept here only as brief
 * per-instruction notes.
 *
 * BCEInstruction extends the real PackedBits class (gpc/util.coffee), so
 * decode reuses pb_make_desc()/pb_get_field() verbatim exactly like
 * cpu_instr.c — no separate mask/field parser needed here. Decode/dispatch
 * differs from cpu_instr.c's single-pass scan: BCEInstruction#exec tries
 * *all* masks > 0xffff first against the 32-bit (hw1<<16|hw2) combined
 * value (for long-format instructions), then falls back to trying all
 * masks <= 0xffff against hw1 alone (short format) — two separate
 * descending-by-mask passes over two different candidate words. Ported as
 * two separately-sorted arrays (SORTED_LONG/SORTED_SHORT) rather than one
 * combined list with a runtime filter, since it's equivalent and avoids
 * re-filtering on every call.
 *
 * `t.curPE` (used throughout for a "2 * BCE#" addressing offset) is
 * always 0 in the source — see iop.h's IOP.curPE comment — replicated
 * verbatim rather than "fixed".
 *
 * Sort order: JS's default `Array#sort()` (used for orderedMasks) is
 * *lexicographic* string comparison, not numeric — cmp_mask_lex_desc
 * replicates that exactly rather than assuming numeric order coincides
 * (as cpu_instr.c's comment notes was empirically true for the CPU's 135
 * instructions; not re-verified here, so this stays exact-by-construction
 * instead of exact-by-luck). */
#include "iop.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "instr.h"
#include "util.h"

typedef struct {
    const char *nm;
    const char *pattern;
    IopInstrExecFn e;
} BceOpEntry;

/* ---------------------------------------------------------------------
 * 3.1 BCE REGISTER INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_LTOI(IOP *t, DInstr *v) {
    register_set32(iopls_MTO(&t->ls), df_get(v, 'd'));
    iop_incr_nia(t, 1);
}

static void exec_LTO(IOP *t, DInstr *v) {
    /* Through iop_bce_ea(): the displacement is signed and relative to
     * the UPDATED PC, and the result is forced even.  This computed it
     * from the raw PC with an unsigned displacement and no alignment. */
    uint32_t ea = iop_bce_ea(t, df_get(v, 'd'), true) & ~1u;
    register_set32(iopls_MTO(&t->ls), iop_g_eaf(t, ea) & 0x3ffffu);
    iop_incr_nia(t, 1);
}

static void exec_RIB(IOP *t, DInstr *v) {
    (void)v;
    iop_proc_set(&t->regIndicator, t->curPE, 0);
    iop_incr_nia(t, 1);
}

static void exec_SIB(IOP *t, DInstr *v) {
    (void)v;
    iop_proc_set(&t->regIndicator, t->curPE, 1);
    iop_incr_nia(t, 1);
}

static void exec_SSC(IOP *t, DInstr *v) {
    uint32_t disp = df_get(v, 'd') + 2u * df_get(v, 'm') * (uint32_t)t->curPE;
    iop_s_eaf(t, disp, iopls_getBST(&t->ls));
    iopls_setBST(&t->ls, 0);
    iop_proc_set(&t->regProgExcept, t->curPE, 1);
    iop_incr_nia(t, 1);
}

static void exec_SST(IOP *t, DInstr *v) {
    uint32_t disp = df_get(v, 'd') + 2u * df_get(v, 'm') * (uint32_t)t->curPE;
    iop_s_eaf(t, disp, iopls_getBST(&t->ls));
    iop_incr_nia(t, 1);
}

static void exec_LBR(IOP *t, DInstr *v) {
    register_set32(iopls_BASE(&t->ls), df_get(v, 'a'));
    iop_incr_nia(t, 2);
}

static void exec_LBR_at(IOP *t, DInstr *v) {
    register_set32(iopls_BASE(&t->ls), df_get(v, 'a') + 2u * (uint32_t)t->curPE);
    iop_incr_nia(t, 2);
}

/* ---------------------------------------------------------------------
 * 3.2 BCE BRANCHING
 * ------------------------------------------------------------------- */

static void exec_BU(IOP *t, DInstr *v) {
    iop_set_nia(t, df_get(v, 'a'));
}

static void exec_BU_at(IOP *t, DInstr *v) {
    iop_set_nia(t, df_get(v, 'a') + 2u * (uint32_t)t->curPE);
}

static void exec_WIX(IOP *t, DInstr *v) {
    Register *a00 = iopls_ls(&t->ls, 0, 0);
    if (register_get32(a00) == 0) {
        uint32_t table = register_get32(iopls_PC(&t->ls)) + 1 + df_get(v, 'd');
        if (table & 1) table += 1;
        register_set32(a00, table);
    }
    if (iop_proc_get(&t->regXmitEna, t->curPE)) {
        register_set32(a00, 0);
        iop_incr_nia(t, 1);
        iop_proc_set(&t->regBusyWait, t->curPE, 0);
    } else {
        BCE *bce = iop_cur_bce(t);
        if (bce && mia_data_available(t, &bce->mia)) {
            uint32_t data = mia_get_data(t, &bce->mia);
            uint32_t listenCmd = (data & 0x01f00000u) >> 20;
            if (listenCmd == 0x8) {
                uint32_t iua = (data & 0x00003e00u) >> 9;
                register_set32(iopls_IUAR(&t->ls), iua);
                uint32_t index = (data & 0x000001feu) >> 1;
                uint32_t table = register_get32(a00);
                table += index;
                uint32_t v1 = iop_g_eaf(t, table);
                iop_set_nia(t, v1);
            }
        }
    }
}

/* ---------------------------------------------------------------------
 * 3.3 BCE TRANSMISSION INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_CMDI(IOP *t, DInstr *v) {
    if (iop_proc_get(&t->regXmitEna, t->curPE)) {
        uint32_t cmd = (df_get(v, 'u') << 19) | df_get(v, 'i');
        register_set32(iopls_IUAR(&t->ls), df_get(v, 'u'));
        BCE *bce = iop_cur_bce(t);
        if (bce) mia_xmit_cmd(t, &bce->mia, cmd);
    }
    iop_incr_nia(t, 2);
}

static void exec_CMD(IOP *t, DInstr *v) {
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    uint32_t cmd = iop_g_eaf(t, addr) & 0x00ffffffu;
    if (iop_proc_get(&t->regXmitEna, t->curPE)) {
        register_set32(iopls_IUAR(&t->ls), (cmd >> 19) & 0x1f);
        BCE *bce = iop_cur_bce(t);
        if (bce) mia_xmit_cmd(t, &bce->mia, cmd);
    }
    iop_incr_nia(t, 2);
}

static void exec_TDS(IOP *t, DInstr *v) {
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t addr = base + df_get(v, 'd') + i;
        iop_queue_dma(t, addr, DMA_READ, bce);
    }
    iop_incr_nia(t, 1);
}

static void exec_TDLI(IOP *t, DInstr *v) {
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_READ, bce);
    iop_incr_nia(t, 2);
}

static void exec_TDL(IOP *t, DInstr *v) {
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    uint32_t count = (iop_g_eah(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_READ, bce);
    iop_incr_nia(t, 2);
}

/* #MOUT/#MIN's 2nd instruction word (IBM-74-A31-016 Fig 2-6/Table 2-10:
 * BCE Long Format 3's "COMMAND" word) is never independently fetched or
 * dispatched — real object code (confirmed against assembled Shuttle
 * flight software) shows it's always 8 zero bits + a 5-bit IUA + a
 * 19-bit command, immediately following #MOUT/#MIN's own word, with no
 * opcode bits distinguishing an "#MOUTC" from an "#MINC" — the two
 * mnemonics are indistinguishable at the bit level and only ever meant
 * to be decoded in the context of their parent instruction. */
static void bce_process_mio_command(IOP *t, uint32_t pc) {
    if (!iop_proc_get(&t->regXmitEna, t->curPE)) return;
    uint32_t cmdWord = iop_g_eaf(t, pc + 2) & 0x00ffffffu;
    register_set32(iopls_IUAR(&t->ls), (cmdWord >> 19) & 0x1fu);
    BCE *bce = iop_cur_bce(t);
    if (bce) mia_xmit_cmd(t, &bce->mia, cmdWord);
}

static void exec_MOUT(IOP *t, DInstr *v) {
    uint32_t pc = register_get32(iopls_PC(&t->ls));
    bce_process_mio_command(t, pc);
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t addr = base + df_get(v, 'd') + i;
        iop_queue_dma(t, addr, DMA_READ, bce);
    }
    iop_incr_nia(t, 4);
}

static void exec_MOUT_at(IOP *t, DInstr *v) {
    /* Fixes problems.md's #MOUT@/#MIN@ NIA-increment discrepancy (found
     * while fixing 1.3): both are single-word (Long Format 1)
     * instructions like #LBR/#CMD/#TDL, which correctly use incrNIA(2) —
     * confirmed against real flight-code address deltas (#MOUT@/#MIN@
     * each span exactly 2 halfwords between the surrounding
     * instructions in workspace/PFS/BFS.SRC as received/COMPILED/BCE),
     * not 3. */
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    uint32_t count = (iop_g_eah(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_READ, bce);
    iop_incr_nia(t, 2);
}

/* ---------------------------------------------------------------------
 * 3.4 BCE RECEIVE DATA INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_RDS(IOP *t, DInstr *v) {
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t addr = base + df_get(v, 'd') + i;
        iop_queue_dma(t, addr, DMA_WRITE, bce);
    }
    iop_incr_nia(t, 1);
}

static void exec_RDLI(IOP *t, DInstr *v) {
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_WRITE, bce);
    iop_incr_nia(t, 2);
}

static void exec_RDL(IOP *t, DInstr *v) {
    /* Uses field 'c', not 'a' — matches the source's descriptor exactly
     * (d:'11111011000000cccccccccccccccccc'), unlike #TDL/#MOUT@/#MIN@
     * which use 'a'. */
    uint32_t addr = df_get(v, 'c') + 2u * (uint32_t)t->curPE;
    uint32_t count = (iop_g_eah(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_WRITE, bce);
    iop_incr_nia(t, 2);
}

static void exec_MIN(IOP *t, DInstr *v) {
    uint32_t pc = register_get32(iopls_PC(&t->ls));
    bce_process_mio_command(t, pc);
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t addr = base + df_get(v, 'd') + i;
        iop_queue_dma(t, addr, DMA_WRITE, bce);
    }
    iop_incr_nia(t, 4);
}

static void exec_MIN_at(IOP *t, DInstr *v) {
    /* See exec_MOUT_at's comment: same NIA-increment fix, same evidence. */
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    uint32_t count = (iop_g_eah(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_WRITE, bce);
    iop_incr_nia(t, 2);
}

/* ---------------------------------------------------------------------
 * 3.5 SPECIAL INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_DLYI(IOP *t, DInstr *v) { (void)v; iop_incr_nia(t, 1); }
static void exec_DLY(IOP *t, DInstr *v) { (void)v; iop_incr_nia(t, 1); }

static void exec_WAT(IOP *t, DInstr *v) {
    (void)v;
    iop_proc_set(&t->regBusyWait, t->curPE, 0);
    iop_incr_nia(t, 1);
}

static void exec_STP(IOP *t, DInstr *v) { (void)v; iop_incr_nia(t, 1); }

/* ---------------------------------------------------------------------
 * Op table / decode / dispatch
 * ------------------------------------------------------------------- */

static const BceOpEntry OPS[] = {
    {"#LTOI", "10110ddddddddddd", exec_LTOI},
    {"#LTO", "10111ddddddddddd", exec_LTO},
    {"#RIB", "11100___________", exec_RIB},
    {"#SIB", "11101___________", exec_SIB},
    {"#SSC", "0100mddddddddddd", exec_SSC},
    {"#SST", "0101mddddddddddd", exec_SST},
    {"#LBR", "11110010000000aaaaaaaaaaaaaaaaaa", exec_LBR},
    {"#LBR@", "11111010000000aaaaaaaaaaaaaaaaaa", exec_LBR_at},
    {"#BU", "11110000000000aaaaaaaaaaaaaaaaaa", exec_BU},
    {"#BU@", "11111000000000aaaaaaaaaaaaaaaaaa", exec_BU_at},
    {"#WIX", "00100ddddddddddd", exec_WIX},
    {"#CMDI", "11110110uuuuuiiiiiiiiiiiiiiiiiii", exec_CMDI},
    {"#CMD", "11111110000000aaaaaaaaaaaaaaaaaa", exec_CMD},
    {"#TDS", "100cccccdddddddd", exec_TDS},
    {"#TDLI", "11110100000000cccccccccccccccccc", exec_TDLI},
    {"#TDL", "11111100000000aaaaaaaaaaaaaaaaaa", exec_TDL},
    {"#MOUT", "11110101ddddddddcccccccccccccccc", exec_MOUT},
    {"#MOUT@", "11111101000000aaaaaaaaaaaaaaaaaa", exec_MOUT_at},
    {"#RDS", "011cccccdddddddd", exec_RDS},
    {"#RDLI", "11110011000000cccccccccccccccccc", exec_RDLI},
    {"#RDL", "11111011000000cccccccccccccccccc", exec_RDL},
    {"#MIN", "11110001ddddddddcccccccccccccccc", exec_MIN},
    {"#MIN@", "11111001000000aaaaaaaaaaaaaaaaaa", exec_MIN_at},
    {"#DLYI", "11000iiiiiiiiiii", exec_DLYI},
    {"#DLY", "11001ddddddddddd", exec_DLY},
    {"#WAT", "00001___________", exec_WAT},
    {"#STP", "0001___________f", exec_STP},
};

#define OPS_COUNT (int)(sizeof(OPS) / sizeof(OPS[0]))

typedef struct {
    const char *nm;
    PBDesc pb;
    IopInstrExecFn e;
} BceInstrDesc;

static BceInstrDesc DESCS[OPS_COUNT];
static const BceInstrDesc *SORTED_LONG[OPS_COUNT];
static const BceInstrDesc *SORTED_SHORT[OPS_COUNT];
static int nLong = 0, nShort = 0;
static bool g_tableInit = false;

/* Replicates JS's default Array#sort() (lexicographic string compare on
 * the decimal representation), then .reverse() — see file header. */
static int cmp_mask_lex_desc(const void *a, const void *b) {
    const BceInstrDesc *da = *(const BceInstrDesc **)a;
    const BceInstrDesc *db = *(const BceInstrDesc **)b;
    char sa[16], sb[16];
    snprintf(sa, sizeof sa, "%u", da->pb.mask);
    snprintf(sb, sizeof sb, "%u", db->pb.mask);
    return strcmp(sb, sa);
}

void bce_instr_table_init(void) {
    if (g_tableInit) return;
    nLong = 0;
    nShort = 0;
    for (int i = 0; i < OPS_COUNT; i++) {
        DESCS[i].nm = OPS[i].nm;
        DESCS[i].pb = pb_make_desc(OPS[i].pattern);
        DESCS[i].e = OPS[i].e;
    }
    /* JS builds a single `opByMask[mask][maskedVal] = desc` dict, so if
     * two instructions ever shared an identical (mask, maskedVal) pair,
     * the later one would silently overwrite the dict entry, permanently
     * shadowing the earlier one. This used to genuinely happen (#MOUTC
     * and #MINC both parsed to mask=0/maskedVal=0, since neither had a
     * literal '0'/'1' bit anywhere) until both were removed from OPS[]
     * above — they were never independently-dispatched opcodes to begin
     * with (see bce_process_mio_command()'s comment). Kept as a general
     * defensive check, since a plain per-instruction linear scan
     * wouldn't otherwise reproduce JS's overwrite-shadowing semantics if
     * a real collision were ever (re)introduced. */
    bool shadowed[OPS_COUNT] = {false};
    for (int i = 0; i < OPS_COUNT; i++) {
        for (int j = i + 1; j < OPS_COUNT; j++) {
            if (DESCS[j].pb.mask == DESCS[i].pb.mask && DESCS[j].pb.maskedVal == DESCS[i].pb.maskedVal) {
                shadowed[i] = true;
                break;
            }
        }
    }
    for (int i = 0; i < OPS_COUNT; i++) {
        if (shadowed[i]) continue;
        if (DESCS[i].pb.mask > 0xffffu) {
            SORTED_LONG[nLong++] = &DESCS[i];
        } else {
            SORTED_SHORT[nShort++] = &DESCS[i];
        }
    }
    qsort(SORTED_LONG, (size_t)nLong, sizeof(SORTED_LONG[0]), cmp_mask_lex_desc);
    qsort(SORTED_SHORT, (size_t)nShort, sizeof(SORTED_SHORT[0]), cmp_mask_lex_desc);
    g_tableInit = true;
}

static void bce_decode(uint32_t word, const BceInstrDesc *d, DInstr *v) {
    memset(v, 0, sizeof(*v));
    v->nm = d->nm;
    for (int c = 0; c < DINSTR_FIELD_TABLE_SIZE; c++) {
        if (d->pb.field[c].present) {
            df_set(v, (char)c, pb_get_field(word, &d->pb.field[c]));
        }
    }
}

void bce_instr_exec(IOP *iop, uint32_t hw1, uint32_t hw2) {
    bce_instr_table_init();
    uint32_t combined = ((hw1 & 0xffffu) << 16) | (hw2 & 0xffffu);

    for (int i = 0; i < nLong; i++) {
        const BceInstrDesc *d = SORTED_LONG[i];
        if ((combined & d->pb.mask) == d->pb.maskedVal) {
            DInstr v;
            bce_decode(combined, d, &v);
            if (d->e) d->e(iop, &v);
            return;
        }
    }

    uint32_t h1 = hw1 & 0xffffu;
    for (int i = 0; i < nShort; i++) {
        const BceInstrDesc *d = SORTED_SHORT[i];
        if ((h1 & d->pb.mask) == d->pb.maskedVal) {
            DInstr v;
            bce_decode(h1, d, &v);
            if (d->e) d->e(iop, &v);
            return;
        }
    }

    /* Unrecognized instruction: matches the source exactly — logs to
     * stdout (observable in `run`'s captured output) and does NOT
     * advance NIA (unlike MSC's unrecognized-instruction path). */
    printf("BCE: unknown instruction %x\n", hw1);
}
