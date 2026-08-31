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
 * `t.curPE` (used throughout for a "2 * BCE#" addressing offset) is the
 * processor whose slice is running -- iop.c sets it from the local-store
 * page at each slice, as the reference now does.  This comment used to
 * say it was "always 0 in the source", which was true of the reference
 * at the time and is not any more.
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
    /* A BCE short-format address -- updated PC plus the signed
     * displacement, plus 2 x BCENO when M is set -- with "the least
     * significant bit of EA (the halfword address) ignored".  This used
     * the raw displacement as an absolute address, so every BCE stored
     * its status into the PSA at 2c + 2*BCENO, walking straight through
     * the interrupt vectors; the SVC new PSW at 005c went to zero and the
     * next SVC took the CPU to address 0. */
    uint32_t ea = iop_bce_ea(t, df_get(v, 'd'), df_get(v, 'm') != 0) & ~1u;
    iop_s_eaf(t, ea, iopls_getBST(&t->ls));
    iopls_setBST(&t->ls, 0);
    iop_proc_set(&t->regProgExcept, t->curPE, 1);
    iop_incr_nia(t, 1);
}

static void exec_SST(IOP *t, DInstr *v) {
    uint32_t raw = iop_bce_ea(t, df_get(v, 'd'), df_get(v, 'm') != 0);
    uint32_t ea = raw & ~1u;
    if (getenv("YAGPC_SSTTRACE")) {
        /* Capped at 10 for years, which silently truncated the trace and
         * made a still-running BCE look like it had stopped signalling.
         * YAGPC_SSTTRACE=N sets the cap; any non-numeric value means all. */
        static int n = 0;
        static int cap = -2;
        if (cap == -2) {
            const char *w = getenv("YAGPC_SSTTRACE");
            char *end = NULL;
            long v = (w != NULL) ? strtol(w, &end, 10) : 0;
            cap = (w != NULL && end != w && *end == '\0' && v > 0)
                      ? (int)v : -1;
        }
        if (cap < 0 || n++ < cap)
            fprintf(stderr, "SST #%d bce=%u raw=%05x ea=%05x bst=%08x t=%.1f\n",
                    n, (unsigned)t->curPE, raw, ea,
                    (unsigned)iopls_getBST(&t->ls),
                    iop_now_us(t));
    }
    iop_s_eaf(t, ea, iopls_getBST(&t->ls));
    iop_incr_nia(t, 1);
}

static void exec_LBR(IOP *t, DInstr *v) {
    register_set32(iopls_BASE(&t->ls), df_get(v, 'a'));
    iop_incr_nia(t, 2);
}

static void exec_LBR_at(IOP *t, DInstr *v) {
    /* The @ family is uniform: operand + 2*BCE# addresses a per-bus table
     * ENTRY, and the entry holds the value -- see exec_BU_at, which fetches
     * through exactly the same bias.  #LBR@ was the one member that did not
     * fetch, taking the entry's ADDRESS as the base register instead.
     *
     * FCMINSSL settles it, because both forms are applied to THE SAME TABLE
     * at THE SAME BIAS.  FCMBCEBT is `EQU *-36` over
     *
     *      DC A(FCMIBLK1)      BUS 18
     *      DC A(FCMIBLK1)      BUS 19
     *
     * and the two fixed BCE programs use it thus:
     *
     *      FCMINMMP  07362  fa00 72a8   #LBR@ 72a8
     *                07366  f300 0001   #RDLI 1
     *      FCMBCMMR  07372  f800 72a8   #BU@  72a8
     *
     * If #BU@ dereferences and #LBR@ does not, then BCE 18's base becomes
     * 072cc -- the branch-table entry itself -- and the #RDLI two halfwords
     * later writes its received word straight over the A(FCMIBLK1) that the
     * #BU@ at 07372 is about to read.  A table cannot be both the operand
     * and the target of the transfer it directs.
     *
     * Observed, and the reason this surfaced at all: that write is refused
     * by store protection (072cc lies below FCMDATA, so the SSL's own
     * unprotect sweep never reaches it), which quietly preserved the entry
     * and hid the defect.  Unprotecting those four halfwords without this
     * fix lets the write land, and BCE 18 then branches to 00000. */
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    register_set32(iopls_BASE(&t->ls), iop_g_eaf(t, addr) & 0x3ffffu);
    iop_incr_nia(t, 2);
}

/* ---------------------------------------------------------------------
 * 3.2 BCE BRANCHING
 * ------------------------------------------------------------------- */

static void exec_BU(IOP *t, DInstr *v) {
    iop_set_nia(t, df_get(v, 'a'));
}

static void exec_BU_at(IOP *t, DInstr *v) {
    /* operand + 2*BCE# addresses a per-bus table ENTRY, and the entry
     * holds the branch ADDRESS -- so the target is the word there, not
     * the entry itself.
     *
     * The flight software says so outright.  FIOMGDSP.asm calls FIOBBM a
     * "MM BRANCH ADDRESS TABLE" and fills it in at run time:
     *
     *      L   R7,FIOMMMUE-*-2(R0,R0)  MM UTL WRT PGM ENDING ADDR
     *      SR  R7,R5                   CALCULATE NEXT XMIT SEQ ADDR
     *      LA  R2,FIOBBM+2             GET MM BRANCH TABLE ADDRESS
     *      ST  R7,0(R3,R2)             STORE ADDRESS IN BCE ENTRY
     *
     * and FIOCBLKS.asm declares that table as `DC 2F'0'` -- two fullwords
     * of zero, with the same EQU *-36 bias -- so an entry cannot be a
     * static instruction; it is a slot for a computed address.
     * FCMINSSL's FCMBCEBT is built the same way, except its addresses are
     * known at assembly time and so appear as `DC A(FCMIBLK1)`.
     *
     * Without the fetch, BCE 18 branched onto the table itself, decoded
     * A(FCMIBLK1)'s leading 0000 as an unknown opcode, never advanced its
     * PC, and spun there while every halfword of the transfer it had just
     * commanded streamed past uncollected.
     *
     * NOTE: 300 #BU@ fixtures in test_iop_bce_exec fail -- but they fail
     * WITH THE DEREFERENCE AND WITHOUT IT ALIKE, measured 2026-08-27 with
     * the control verified functionally (wordsTaken 98,820 with the fetch,
     * 28,164 without, so the rebuild demonstrably took).  They encode a
     * THIRD behaviour, NIA = a with no bus offset at all, which neither
     * this code nor gpc produces, so they cannot arbitrate between them.
     * Nor could they exercise a fetch in principle: their memory image is
     * 4096 halfwords and the addresses involved sit far above it.
     *
     * An earlier revision of this comment said they "fail with this",
     * implying they pass without it.  They do not.  gpc is direct here,
     * but yaGPC2 was ported from gpc, so that agreement is inheritance
     * rather than confirmation -- the flight software above is the
     * evidence, not either implementation. */
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    if (getenv("YAGPC_BUATTRACE")) {
        static int n = 0;
        if (n++ < 12)
            fprintf(stderr, "BU@ #%d bce=%u table=%05x entry->%05x "
                    "(gpc would go to %05x)\n",
                    n, (unsigned)t->curPE, addr,
                    (unsigned)(iop_g_eaf(t, addr) & 0x3ffff),
                    (unsigned)(addr & 0x3ffff));
    }
    iop_set_nia(t, iop_g_eaf(t, addr) & 0x3ffffu);
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
    /* The per-bus table is an array of A() FULLWORDS at a 2*BCE# bias --
     * the same shape #BU@, #LBR@ and #CMD@ already fetch through, and the
     * one the `EQU *-36` bias implies (two halfwords, i.e. one fullword,
     * per BCE).  A HALFWORD read at an even entry address therefore
     * returns the fullword's HIGH half, which is always zero for a count,
     * so every #TDL transmitted exactly one word regardless of what was
     * asked for.
     *
     * Measured in PASS's own display path: the DK2 table at 0x08c94 holds
     * `0000 0016` for BCE 7, and the DEU's display fill is a 2-word header
     * from the #TDS at 0x199ae followed by this #TDL's data.  With the
     * halfword read the count was 1 every time -- so a fill commanded as
     * 5 halfwords sent 3 ("transfer abandoned, 2 halfwords short"), and
     * one commanded as 360 against real MEDS also sent 3, leaving the
     * screen unpainted while the 7-halfword time fill, which uses #MOUT
     * and needs no table, kept the clock running. */
    uint32_t count = (iop_g_eaf(t, addr) & 0xffffu) + 1;
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
    if (!iop_proc_get(&t->regXmitEna, t->curPE)) {
        if (getenv("YAGPC_DISPTRACE"))
            fprintf(stderr, "MIOCMD proc%-3d pc=%05x GATED (xmit disabled)\n",
                    t->curPE, (unsigned)pc);
        return;
    }
    /* The PC is an 18-bit register, so the companion command's address
     * wraps with it: the reference fetches from
     * (PC + 2) & LS_WORD_MASK.  Without the mask a PC carrying anything
     * above bit 17 sent the fetch outside main storage, which read as
     * zero and left the IUA register at 0. */
    uint32_t cmdWord = iop_g_eaf(t, (pc + 2) & 0x3ffffu) & 0x00ffffffu;
    if (getenv("YAGPC_DISPTRACE"))
        fprintf(stderr, "MIOCMD proc%-3d pc=%05x cmd=%06x\n",
                t->curPE, (unsigned)pc, (unsigned)cmdWord);
    register_set32(iopls_IUAR(&t->ls), (cmdWord >> 19) & 0x1fu);
    BCE *bce = iop_cur_bce(t);
    if (bce) mia_xmit_cmd(t, &bce->mia, cmdWord);
}

static void exec_MOUT(IOP *t, DInstr *v) {
    /* Unconditionally, unlike #MIN below: a transmit advances its NIA on
     * the spot, so it never re-fetches itself and has no receive state to
     * consult.  The reference guards only #MIN for the same reason. */
    uint32_t pc = register_get32(iopls_PC(&t->ls));
    bce_process_mio_command(t, pc);
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t addr = base + df_get(v, 'd') + i;
        iop_queue_dma(t, addr, DMA_READ, bce);
    }
    /* YAGPC_DMATRACE: what a #MOUT ASKED for, against what the bus later
     * carries.  The instruction advances its NIA immediately, so a
     * transmit's real length is only observable here. */
    if (getenv("YAGPC_DMATRACE"))
        fprintf(stderr, "MOUT    bce=%d queued %u word(s) from %05x\n",
                t->curPE, (unsigned)count,
                (unsigned)(base + df_get(v, 'd')));
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
    /* Same fullword table as #TDL above (and as #BU@/#LBR@/#CMD@ already
     * fetch): a halfword read at an even entry returns the high half,
     * which is zero for a count. */
    uint32_t count = (iop_g_eaf(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    BCE *bce = iop_cur_bce(t);
    for (uint32_t i = 0; i < count; i++) iop_queue_dma(t, base + i, DMA_READ, bce);
    iop_incr_nia(t, 2);
}

/* ---------------------------------------------------------------------
 * 3.4 BCE RECEIVE DATA INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_RDS(IOP *t, DInstr *v) {
    /* A receive HOLDS the BCE at this instruction until the count is
     * satisfied (or the transfer times out): iop_bce_receive() returns
     * false to mean "still receiving", and the PC must be left alone so
     * the BCE re-fetches it next slice.  Queueing the words as DMA and
     * advancing regardless -- what this did -- ran the bus program past
     * a reply that had not arrived, and every transaction after it was
     * one step out of step with the subsystem. */
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    if (iop_bce_receive(t, base + df_get(v, 'd'), count)) iop_incr_nia(t, 1);
}

static void exec_RDLI(IOP *t, DInstr *v) {
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    if (iop_bce_receive(t, base, count)) iop_incr_nia(t, 2);
}

static void exec_RDL(IOP *t, DInstr *v) {
    /* Uses field 'c', not 'a' — matches the source's descriptor exactly
     * (d:'11111011000000cccccccccccccccccc'), unlike #TDL/#MOUT@/#MIN@
     * which use 'a'. */
    uint32_t addr = df_get(v, 'c') + 2u * (uint32_t)t->curPE;
    uint32_t count = (iop_g_eah(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    if (iop_bce_receive(t, base, count)) iop_incr_nia(t, 2);
}

static void exec_MIN(IOP *t, DInstr *v) {
    /* Only when the receive is STARTING: this instruction re-fetches
     * itself every slice while it waits, and issuing the companion
     * command again each time floods the bus.  Measured against the
     * reference on the display bus: 105,059 poll commands in 100 s
     * against its 176 in 60 -- about 440 times too many, which starved
     * the display fills and the clock. */
    if (iop_bce_receive_starting(t)) {
        uint32_t pc = register_get32(iopls_PC(&t->ls));
        bce_process_mio_command(t, pc);
    }
    uint32_t count = df_get(v, 'c') + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    if (iop_bce_receive(t, base + df_get(v, 'd'), count)) iop_incr_nia(t, 4);
}

static void exec_MIN_at(IOP *t, DInstr *v) {
    /* See exec_MOUT_at's comment: same NIA-increment fix, same evidence. */
    uint32_t addr = df_get(v, 'a') + 2u * (uint32_t)t->curPE;
    uint32_t count = (iop_g_eah(t, addr) & 0xffffu) + 1;
    uint32_t base = register_get32(iopls_BASE(&t->ls));
    if (iop_bce_receive(t, base, count)) iop_incr_nia(t, 2);
}

/* ---------------------------------------------------------------------
 * 3.5 SPECIAL INSTRUCTIONS
 * ------------------------------------------------------------------- */

/* #DLYI holds the BCE for its own immediate timeout count; #DLY reads the
 * count from the fullword its displacement addresses, the way #LTO reads
 * its own.  Both used to advance immediately, so every BCE skipped every
 * delay it was told to take and ran far ahead of the machine -- which the
 * software notices, since it polls STAT4 to see how far the BCEs have
 * got. */
static void exec_DLYI(IOP *t, DInstr *v) {
    if (iop_bce_delay(t, df_get(v, 'i'))) iop_incr_nia(t, 1);
}
static void exec_DLY(IOP *t, DInstr *v) {
    uint32_t count = iop_g_eaf(t, iop_bce_ea(t, df_get(v, 'd'), true) & ~1u) & 0x3ffffu;
    if (iop_bce_delay(t, count)) iop_incr_nia(t, 1);
}

/* #WAT stops the BCE and PARKS THE PC ONE PAST ITSELF.  BCE POO section
 * 2.2 (IBM-6246556A part 3):
 *
 *   "a BCE's Program Counter need not always be set before the MSC sets
 *    the BCE to busy, since the BCE Wait instruction (#WAT) when executed,
 *    leaves the PC pointing to the next sequential instruction.  This next
 *    instruction may be programmed as a simple branch to the beginning of
 *    the next BCE program segment.  In this case, the MSC need only
 *    execute an SIO instruction to restart the BCE at the next segment."
 *
 * So the increment is not bookkeeping, it is the defined behaviour, and it
 * is what makes that restart idiom possible.  Clearing the Busy/Wait bit
 * is what actually stops execution -- iop_exec_slice() refuses to step a
 * processor whose bit is clear -- and only the MSC's SIO can set it again
 * ("The CPU cannot, however, directly set a BCE's Busy/Wait bit").
 *
 * The SSL does NOT use the fall-through-to-a-branch idiom: the halfword
 * after its #WAT is 0000, and it reloads BCE 18's PC for each program
 * instead (measured: PC<-07362 = FCMINBCE and PC<-0736c, matching
 * FCMBCEAD's DC A(FCMBCMMR) / DC A(FCMINMMP) pair). */
static void exec_WAT(IOP *t, DInstr *v) {
    (void)v;
    iop_proc_set(&t->regBusyWait, t->curPE, 0);
    iop_incr_nia(t, 1);
}

/* SELF TEST - BCE.  The BCEs' own signature fullwords start here, one
 * per BCE: STP_BCE_BASE + 2*(n-1). */
#define STP_BCE_BASE 0x010a

static void exec_STP(IOP *t, DInstr *v) {
    if (df_get(v, 'I')) {
        if (iop_proc_get(&t->regXmitEna, t->curPE)) {
            /* Transmitter enabled: refuse.  "the BCE's Program Exception
             * bit is set to 0, bit 22 of the BCE Status Register is set
             * to 1 (Self Test failure)." */
            iop_proc_set(&t->regProgExcept, t->curPE, 0);
            iop_proc_set(&t->regBusyWait, t->curPE, 0);
            iopls_setBST(&t->ls, iopls_getBST(&t->ls) | (1u << (31 - 22)));
            iop_incr_nia(t, 1);
            return;
        }
        /* Otherwise the transmit that never reaches the bus -- but it
         * still puts a word on the bus out to the octal MIA pages, so
         * the C180 generator gets its chance at it. */
        iop_check_mia_parity(t);
        iop_incr_nia(t, 1);
        return;
    }
    /* "If an error is detected, the BCE's Program Exception bit is set to
     * 0, bit 22 of the BCE Status Register is set to 1 (Self Test
     * failure)."  The modelled hardware has no faults, so neither
     * happens.
     *
     * "Ability of BCE to read and write from memory" is one of the tests,
     * and like the MSC's it runs against a fixed PSA fullword -- this
     * BCE's.  The high halfword is the pattern to read, the low halfword
     * where it must land.  This whole instruction used to do nothing but
     * advance the PC. */
    uint32_t fw = STP_BCE_BASE + 2u * (uint32_t)(t->curPE - 1);
    iop_s_eah(t, fw + 1, iop_g_eah(t, fw));
    iop_incr_nia(t, 1);
}

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
    {"#STP", "0001I__________f", exec_STP},   /* the I bit selects the MIA-transmit form */
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
    /* Say WHICH processor and WHERE: an unknown opcode is almost always
     * a runaway PC rather than a genuinely missing instruction, and the
     * address is what tells the two apart. */
    fprintf(stderr, "BCE%d: unknown instruction %04x at %05x\n", iop->curPE,
            (unsigned)hw1, (unsigned)(register_get32(iopls_PC(&iop->ls)) & 0x3ffffu));
}
