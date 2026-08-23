/* Ported from OBJECTGE.xpl's EXECUTION_TIMES(M) (see timing.h). The
 * historical procedure is indexed by a compiler-internal `INST` value
 * (0-205, a row number into several parallel compiler-private tables --
 * NOT the hardware opcode byte) and its three per-INST arrays --
 * NORMAL_TIMES/INDIRECT_TIMES/INDEX_TIMES -- each hold an index into a
 * 95-entry TIMES() string table (mostly bare numbers, plus a handful of
 * parametric formulas). This port drops the INST-index scheme entirely
 * (yaGPC2 has no equivalent of it) and instead keys the same three
 * arrays by mnemonic (matching InstrDesc.nm), reconstructed by cross-
 * referencing OBJECTGE.xpl's tables against ##DRIVER.xpl's AP101INST/
 * OPNAMES/OPER tables and yaGPC2's own src/cpu_instr.c OPS[] table.
 *
 * A few historical INST slots don't appear here at all: pure "unused"
 * table entries, plus two BFS-build-only mnemonics (INST 66 `BVC`,
 * INST 130 `BVCF`) that the PASS-build HAL/S-FC compiler this project
 * targets never named/emitted -- see the porting research for detail.
 * `LACR` (the compiler's own internal name for what yaGPC2 calls `LCR`
 * -- same instruction, confirmed by matching hardware bit pattern) is
 * carried over here as `LCR`. Any mnemonic instr_time_us() doesn't
 * recognize (because HAL/S-FC's own compiler never emitted it, e.g.
 * `SRDR`, or the BFS-only branches above) returns 0.0.
 *
 * "(SEE POO)" in the historical listing text just meant "consult the
 * AP-101S Principles of Operation manual for why" -- for every case
 * except MVH's, the number itself was already concrete (computed from
 * the object code's own IA/II addressing-mode bits, which are exactly
 * yaGPC2's DInstr.ia/DInstr.ii), so no runtime ambiguity exists there.
 * MVH is the one genuine parametric case: the static compiler could
 * only resolve its formula when a directly-preceding IAL instruction
 * gave it the count (historical MVH_COUNT/MVH_CNT_KNOWN compiler
 * state); an emulator always knows the real count directly from the
 * register at execution time, so this port resolves it unconditionally
 * (see the idx==84 case below) rather than reproducing that compile-
 * time tracking.
 *
 * One narrow, deliberately-accepted gap: ME's historical special case
 * fires on "(R MOD 2 ^= 0) | (LHS=SRSTYPE)" -- the LHS=SRSTYPE half is
 * a HAL/S-FC compile-time bookkeeping condition about the destination
 * operand's source-level storage class, with no encoding anywhere in
 * the emitted object code, so it cannot be reconstructed at runtime.
 * This port checks only the R-odd half; the small remaining case (even
 * R, LHS=SRSTYPE true) falls through to ME's ordinary indexed-lookup
 * timing instead of its special fixed value -- a real but unrecoverable
 * and narrow discrepancy against the historical compiler's own numbers.
 */
#include "timing.h"

#include <string.h>

#include "regmem.h"

/* TIMES() indices 0-83: plain numbers, verbatim from OBJECTGE.xpl. */
static const double PLAIN_TIMES[84] = {
    0,     0.25,  0.5,   0.75,  1.0,   1.2,   1.35,  1.5,   1.7,   1.75,  2.0,   2.15,  2.25,  2.4,
    2.5,   3.0,   3.25,  3.75,  4.0,   4.25,  4.5,   4.675, 4.75,  4.925, 5.0,   5.23,  5.25,  5.5,
    5.58,  5.75,  6.0,   6.03,  6.25,  6.28,  6.5,   6.75,  7.0,   7.25,  7.5,   7.55,  7.75,  7.98,
    8.0,   8.025, 8.25,  8.5,   8.75,  8.8,   9.0,   9.5,   9.75,  10.0,  10.05, 10.25, 10.28, 10.5,
    10.53, 11.5,  11.75, 11.8,  12.0,  12.5,  12.75, 13.25, 13.5,  14.25, 15.25, 16.25, 17.5,  18.125,
    18.5,  19.0,  20.25, 22.25, 22.5,  22.75, 23.0,  24.0,  24.5,  25.0,  25.75, 26.75, 27.75, 29.75,
};

/* TIMES() indices 85-90: "BT=x, BNT=y" branch-taken/not-taken pairs. */
static const double BRANCH_TAKEN[6] = {5.75, 3.50, 1.75, 1.25, 2.5, 1.25};
static const double BRANCH_NOT_TAKEN[6] = {0.50, 4.50, 0.750, 0.50, 1.5, 0.250};

/* TIMES() indices 91-94: "base+(perUnit*N)" shift-count formulas. */
static const double SHIFT_BASE[4] = {0.650, 1.0, 0.675, 1.0};
static const double SHIFT_PER_UNIT[4] = {0.1, 0.25, 0.1, 0.1};

typedef struct {
    const char *nm;
    unsigned char normal, indirect, index;
} TimingEntry;

/* mnemonic -> (NORMAL_TIMES, INDIRECT_TIMES, INDEX_TIMES) index, ported
 * verbatim from OBJECTGE.xpl:620-654 via the mnemonic reconstruction
 * described above. 0 in indirect/index means "this mnemonic has no
 * indexed-addressing form" (matches the historical all-zero entries). */
static const TimingEntry TIMING_TABLE[] = {
    {"LFXI", 3, 0, 0},   {"LFLI", 3, 0, 0},   {"SPM", 26, 0, 0},   {"BALR", 86, 0, 0},  {"BCTR", 87, 0, 0},
    {"BCR", 1, 0, 0},    {"SRET", 68, 0, 0},  {"MVH", 84, 0, 0},   {"BCRE", 85, 0, 0},  {"LCR", 2, 0, 0},
    {"NR", 1, 0, 0},     {"OR", 1, 0, 0},     {"XR", 1, 0, 0},     {"LR", 1, 0, 0},     {"CR", 1, 0, 0},
    {"AR", 1, 0, 0},     {"SR", 1, 0, 0},     {"MR", 13, 0, 0},    {"DR", 23, 0, 0},    {"CVFX", 12, 0, 0},
    {"SEDR", 32, 0, 0},  {"CEDR", 7, 0, 0},   {"AEDR", 32, 0, 0},  {"MEDR", 70, 0, 0},  {"DEDR", 75, 0, 0},
    {"LECR", 4, 0, 0},   {"SER", 12, 0, 0},   {"LER", 4, 0, 0},    {"CER", 7, 0, 0},    {"AER", 12, 0, 0},
    {"MER", 30, 0, 0},   {"DER", 37, 0, 0},   {"CVFL", 9, 0, 0},

    {"STH", 2, 19, 45},  {"LA", 1, 17, 42},   {"IHL", 2, 20, 37},  {"BIX", 89, 27, 44}, {"BAL", 17, 51, 49},
    {"BCT", 87, 19, 36}, {"BC", 90, 18, 32},  {"LH", 1, 19, 36},   {"CH", 1, 19, 36},   {"AH", 1, 19, 36},
    {"SH", 1, 19, 37},   {"MH", 6, 25, 41},   {"SCAL", 69, 78, 77}, {"MIH", 8, 28, 43}, {"IAL", 2, 17, 42},
    {"ST", 2, 20, 48},

    {"N", 1, 20, 34},    {"O", 1, 20, 34},    {"X", 1, 20, 38},    {"L", 1, 19, 37},    {"C", 1, 19, 37},
    {"A", 1, 19, 37},    {"S", 1, 19, 37},    {"M", 13, 33, 56},   {"D", 23, 47, 59},

    {"STED", 4, 24, 38}, {"LED", 7, 24, 46},  {"CED", 29, 49, 61}, {"AED", 34, 53, 63}, {"SED", 34, 55, 64},
    {"MED", 71, 73, 80}, {"DED", 76, 82, 83},

    {"STE", 2, 20, 38},  {"LE", 5, 22, 45},   {"CE", 9, 29, 45},   {"AE", 14, 34, 48},  {"SE", 14, 20, 49},
    {"ME", 32, 53, 63},  {"DE", 38, 57, 66},  {"MVS", 22, 48, 58},

    {"BCTB", 87, 0, 0},  {"BCF", 1, 0, 0},    {"SRL", 91, 0, 0},   {"SLL", 93, 0, 0},   {"SRA", 91, 0, 0},
    {"SRDL", 94, 0, 0},  {"SLDL", 92, 0, 0},  {"SRDA", 92, 0, 0},

    {"STM", 37, 51, 65}, {"TH", 9, 24, 40},   {"TS", 17, 32, 48},  {"SHW", 7, 19, 45},  {"LM", 45, 60, 67},
    {"SVC", 72, 74, 81}, {"TD", 15, 27, 44},  {"ZH", 7, 19, 45},

    {"TRB", 4, 0, 0},    {"NHI", 1, 0, 0},    {"OHI", 1, 0, 0},    {"XHI", 1, 0, 0},    {"LHI", 1, 0, 0},
    {"CHI", 1, 0, 0},    {"AHI", 1, 0, 0},    {"MHI", 6, 0, 0},    {"ZRB", 1, 0, 0},    {"TB", 10, 0, 0},
    {"TSB", 15, 0, 0},   {"NIST", 15, 0, 0},  {"SB", 15, 0, 0},    {"XIST", 15, 0, 0},  {"CIST", 7, 0, 0},
    {"MSTH", 15, 0, 0},  {"ZB", 16, 0, 0},

    {"NST", 3, 29, 53},  {"OST", 3, 29, 53},  {"XST", 3, 29, 53},  {"AST", 3, 29, 53},  {"SST", 4, 0, 0},
    {"LDM", 35, 51, 53}, {"SRR", 91, 0, 0},
};
#define TIMING_TABLE_COUNT (sizeof(TIMING_TABLE) / sizeof(TIMING_TABLE[0]))

/* ---------------------------------------------------------------------
 * Section 17 fallback table
 *
 * TIMING_TABLE above is a verbatim port of the HAL/S-FC PASS2 compiler's
 * own EXECUTION_TIMES, so it only covers instructions that compiler ever
 * emitted.  Hand-written assembler -- GPCIPL above all -- uses plenty it
 * never did, and those used to return 0.0 here, which is not "unknown"
 * but "took no time": with the interval timers now advancing off
 * execution time (see cpu_advance_time_us), a spin loop built out of
 * untimed instructions never let the clock run at all.
 *
 * These values come from the manual's own table instead --
 * AP-101S-instruction-set.txt section 17, "AP-101S INSTRUCTION EXECUTION
 * TIMES", headed "INSTRUCTION EXECUTION TIME IN US" (which also settles
 * timing.h's note that the units were never independently confirmed as
 * microseconds: the table says so).  Citations below give the PRINTED
 * page first and the line in the OCR'd text second; the page markers in
 * that text are FOOTERS (page 17-1 is the section's assumptions, and the
 * table itself occupies printed pages 17-2, 17-3 and 17-4), so a row
 * belongs to the first marker at or below it.  PASS2 WINS wherever both have an
 * entry -- this table is consulted only when find_entry() comes back
 * empty -- so nothing here can perturb a HAL/S-compiled workload.
 *
 * The seven columns are the manual's own: NORMAL ADDRESSING MODES, then
 * DOUBLE INDIRECTION in its four XC/C combinations, then AUTO STORAGE
 * MODIFICATION and AUTO INDEXING.  A negative entry is the manual's "--",
 * i.e. the form has no such addressing mode, and falls back to normal.
 *
 * Every value below was read from the manual and then cross-checked
 * against gpc/cpu_instr.coffee's `xts:` arrays, an independent
 * transcription of the same table; they agree except where noted in the
 * per-entry comments.
 *
 * TWO GREPPABLE MARKERS APPEAR BELOW, both meaning "a human still needs
 * to look at the printed document"; an unmarked row was read cleanly and
 * needs nothing.
 *
 *   PROVISIONAL:   the figure itself could not be read.  The OCR text is
 *                  destroyed or the row is missing outright, and the
 *                  value here is a stand-in.
 *   RECONSTRUCTED: the figure was read cleanly, but the OCR dropped the
 *                  INSTRUCTION column from the last pages of the table,
 *                  so which mnemonic the row belongs to was recovered
 *                  from the table's alphabetical order rather than read.
 *                  Corroborated -- every row on those pages that also
 *                  appears in the PASS2 table above carries the matching
 *                  time (OST .750, SVC 20.25, SRET 17.50, TS 3.75, ...),
 *                  and gpc independently assigns the same mnemonics --
 *                  but not directly attested.
 * ------------------------------------------------------------------- */

#define NA (-1.0)

typedef struct {
    const char *nm;
    double t[7];
} PooTimingEntry;

static const PooTimingEntry POO_TIMING_TABLE[] = {
    /* Branch instructions: t[0] is the branch-TAKEN time; the not-taken
     * time is in POO_BRANCH_NOT_TAKEN below. */
    {"BVC",   {1.25, 4.0,   7.0,   3.75,  7.0,   5.0,   6.5}},  /* p.17-2 L13545 */
    {"BVCF",  {1.25, NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-2 L13546 */
    {"BVCR",  {1.25, NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-2 L13547 */

    {"BCB",   {0.25, NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-2 L13537 */
    {"CBL",   {5.0,  NA,    NA,    NA,    NA,    NA,    NA}},   /* "AVG. = 5.0"; p.17-2 L13550 */
    {"LFLR",  {0.75, NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-3 L13607 */
    {"LFXR",  {0.75, NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-3 L13609 */
    {"LPS",   {10.25,13.25, 14.25, 13.0,  14.25, 15.5,  17.25}}, /* p.17-3 L13613 */
    {"LXA",   {3.5,  6.5,   6.25,  6.25,  6.25,  6.5,   5.25}}, /* p.17-3 L13616 (RS); -1.25 early out not modelled */
    {"LXAR",  {3.5,  NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-3 L13615 (RR); -1.25 early out not modelled */
    {"STDM",  {2.25, 5.25,  6.75,  5.0,   5.25,  7.0,   7.5}},  /* RECONSTRUCTED: mnemonic from alphabetical position; p.17-4 L13715 */
    {"STXA",  {2.5,  6.5,   8.0,   6.25,  8.0,   8.25,  8.75}}, /* RECONSTRUCTED: mnemonic from alphabetical position; p.17-4 L13726 */
    {"STXAR", {2.5,  NA,    NA,    NA,    NA,    NA,    NA}},   /* RECONSTRUCTED: mnemonic from alphabetical position; p.17-4 L13724-25 */
    {"XUL",   {1.0,  NA,    NA,    NA,    NA,    NA,    NA}},   /* RECONSTRUCTED: mnemonic from alphabetical position; p.17-4 L13759-60 */

    /* PROVISIONAL: SSM normal-addressing figure, line 13709 -- and
     * RECONSTRUCTED: mnemonic from alphabetical position on the same
     * line.  Pending a human read of the printed manual.  SSM's
     * normal-mode figure is the one number on these pages the OCR lost
     * outright -- printed page 17-4 (L13709) renders it "704".  7.75 is gpc's reading and
     * the only multiple of .125 that fits, every other figure in the row
     * being one (the manual prints those rounded to two decimals,
     * 10.63/11.63/10.38, for 10.625/11.625/10.375, which is what is used
     * here).  The columns are certain; only the first figure is not. */
    {"SSM",   {7.75, 10.625, 11.625, 10.375, 11.625, 12.875, 14.625}},

    /* Parametric and non-numeric rows.  t[0] is the base; see
     * instr_time_us() for the per-instruction arithmetic. */
    /* PROVISIONAL: ISPB M1 = 4 only -- that row is absent from the text
     * (page break between printed pages 17-2 and 17-3); M1 = 0-3
     * (5.625, p.17-2 L13578-81) and M1 = 5-7 (.125, p.17-3 L13592-94)
     * are read directly.  See the M1 cutoff in instr_time_us(). */
    {"ISPB",  {5.625, 8.0,  9.0,   7.75,  9.0,   10.25, 12.0}}, /* M1 >= 4: 0.125 */
    {"NCT",   {1.05, NA,    NA,    NA,    NA,    NA,    NA}},   /* + .075 * N; p.17-3 L13644 */
    {"SRDR",  {2.0,  NA,    NA,    NA,    NA,    NA,    NA}},   /* + .5 * N (N mod 32); RECONSTRUCTED: mnemonic; p.17-4 L13700,13702 */
    {"SUM",   {2.5,  NA,    NA,    NA,    NA,    NA,    NA}},   /* * elements tested; RECONSTRUCTED: mnemonic; p.17-4 L13727-28 */

    /* The manual gives no single number for these three.  Each value is a
     * representative stand-in, chosen so the instruction costs SOMETHING
     * rather than nothing, and each matches gpc's own choice:
     *   DIAG "SEE POO"            -- per-function times live in POO s.15
     *   ICR  "COMMAND DEPENDENT"  -- varies by the command in R2
     *   PC   ">4.25 BUT <22.5 (NO CUR DMA)" -- a range, not a value;
     *        4.5 is the low end of it, the no-DMA typical case */
    {"DIAG",  {1.0,  NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-2 L13571 */
    {"ICR",   {1.0,  NA,    NA,    NA,    NA,    NA,    NA}},   /* p.17-2 L13576 */
    {"PC",    {4.5,  NA,    NA,    NA,    NA,    NA,    NA}},   /* RECONSTRUCTED: mnemonic from alphabetical position; p.17-4 L13668 */
};
#define POO_TIMING_COUNT (sizeof(POO_TIMING_TABLE) / sizeof(POO_TIMING_TABLE[0]))

/* Branch-not-taken times for the section-17 branches, "BT=x; BNT=y". */
typedef struct { const char *nm; double notTaken; } PooBranchEntry;
static const PooBranchEntry POO_BRANCH_NOT_TAKEN[] = {
    {"BVC", 0.50}, {"BVCF", 0.50}, {"BVCR", 0.50},
};
#define POO_BRANCH_COUNT (sizeof(POO_BRANCH_NOT_TAKEN) / sizeof(POO_BRANCH_NOT_TAKEN[0]))

static const PooTimingEntry *find_poo_entry(const char *nm) {
    for (size_t i = 0; i < POO_TIMING_COUNT; i++) {
        if (strcmp(POO_TIMING_TABLE[i].nm, nm) == 0) return &POO_TIMING_TABLE[i];
    }
    return NULL;
}

static const TimingEntry *find_entry(const char *nm) {
    for (size_t i = 0; i < TIMING_TABLE_COUNT; i++) {
        if (strcmp(TIMING_TABLE[i].nm, nm) == 0) return &TIMING_TABLE[i];
    }
    return NULL;
}

static bool is_indexed(const DInstr *v) { return df_has(v, 'i') && df_get(v, 'i') != 0; }

/* Historical "(SHL(F,1)+IA) > 0": F is DInstr.ii (bit 11), IA is
 * DInstr.ia (bit 12) -- see timing.h/porting notes. */
static bool is_extended_indirect(const DInstr *v) {
    return v->hasIa && v->hasIi && ((v->ia | v->ii) != 0);
}

uint32_t instr_time_pre_n(CPU *cpu, const InstrDesc *desc, const DInstr *v, uint32_t hw1) {
    if (desc->opType == OPTYPE_SHFT) return cpu_g_shift_cnt(cpu, hw1);
    if (strcmp(desc->nm, "MVH") == 0) return register_get32(cpu_r(cpu, (int)df_get(v, 'x'))) & 0xffff;
    /* Section-17 parametric instructions whose N is not a shift count.
     * Both are read BEFORE execution because both overwrite the register
     * the count comes from. */
    if (strcmp(desc->nm, "NCT") == 0) {
        /* NCT's N is what it is about to count: the run of leading bits
         * that match their neighbour, exactly as exec_NCT walks it. */
        uint32_t v2 = register_get32(cpu_r(cpu, (int)df_get(v, 'y')));
        if (v2 == 0) return 0;
        uint32_t n = 0;
        while (n < 32 && (((v2 >> 31) & 1) == ((v2 >> 30) & 1))) { v2 <<= 1; n++; }
        return n;
    }
    if (strcmp(desc->nm, "SUM") == 0) {
        return (register_get32(cpu_r(cpu, (int)df_get(v, 'y'))) >> 16) & 0xffff;
    }
    return 0;
}

/* Resolves a TIMES() index (0-94) to a concrete number, given the
 * pre-execution operand (preN) and post-execution branch outcome. */
static double resolve_times_index(int idx, uint32_t preN, bool branchTaken) {
    if (idx <= 0) return 0.0; /* 0 = "no time recorded" (historical unused slot) */
    if (idx < 84) return PLAIN_TIMES[idx];
    if (idx == 84) {
        /* MVH: '12.0+.875(N-1) (SEE POO)', the compile-time-unresolved
         * fallback -- always resolvable at runtime via the actual count
         * (see timing.h), so this port applies the historical
         * MVH_CNT_KNOWN(R)=true rules unconditionally instead. */
        int16_t n = (int16_t)(preN & 0xffff);
        if (n == 1) return 11.25;
        if (n == 0) return 7.75;
        if (n < 0) return 7.5;
        if (n % 2 == 0) return 10.25 + 0.875 * n;
        return 12.0 + 0.875 * (n - 1);
    }
    if (idx <= 90) return branchTaken ? BRANCH_TAKEN[idx - 85] : BRANCH_NOT_TAKEN[idx - 85];
    if (idx <= 94) return SHIFT_BASE[idx - 91] + SHIFT_PER_UNIT[idx - 91] * (double)preN;
    return 0.0;
}

double instr_time_us(const InstrDesc *desc, const DInstr *v, uint32_t preN, bool branchTaken) {
    const char *nm = desc->nm;
    bool oddR = (df_get(v, 'x') & 1) != 0;
    bool indexed = is_indexed(v);
    bool seePoo = is_extended_indirect(v);

    /* MR/DR/MER: odd destination register uses a fixed, higher time
     * (double-precision register-pair complication); even R falls
     * through to the ordinary table lookup below. */
    if (oddR && strcmp(nm, "MR") == 0) return PLAIN_TIMES[11];
    if (oddR && strcmp(nm, "DR") == 0) return PLAIN_TIMES[21];
    if (oddR && strcmp(nm, "MER") == 0) return PLAIN_TIMES[27];

    /* M/D/ME: odd destination register uses a fixed value selected by
     * indexing mode (not the mnemonic's own INDIRECT/INDEX_TIMES
     * entry); even R falls through to the ordinary table lookup below,
     * same as MR/DR/MER. See the ME/LHS=SRSTYPE gap noted in the file
     * header comment. */
    if (oddR && strcmp(nm, "M") == 0) return indexed ? (seePoo ? PLAIN_TIMES[31] : PLAIN_TIMES[54]) : PLAIN_TIMES[21];
    if (oddR && strcmp(nm, "D") == 0) return indexed ? (seePoo ? PLAIN_TIMES[39] : PLAIN_TIMES[52]) : PLAIN_TIMES[21];
    if (oddR && strcmp(nm, "ME") == 0) return indexed ? (seePoo ? PLAIN_TIMES[50] : PLAIN_TIMES[62]) : PLAIN_TIMES[29];

    const TimingEntry *e = find_entry(nm);
    if (!e) {
        /* HAL/S-FC never named/timed this mnemonic -- fall back to the
         * manual's own section-17 table (see POO_TIMING_TABLE). */
        const PooTimingEntry *p = find_poo_entry(nm);
        if (!p) return 0.0;

        /* Column choice mirrors the PASS2 path directly above: an
         * indexed operand with extended indirection takes the double-
         * indirection figure, an indexed operand without it takes the
         * auto-indexing figure, everything else takes normal addressing.
         * yaGPC2 does not surface the indirect word's own XC/C bits to
         * this layer (cpu_g_ea consumes them internally), so the four
         * double-indirection sub-columns are not distinguished and the
         * XC=0,C=0 one stands for them. */
        int col = 0;
        if (indexed) col = seePoo ? 1 : 6;
        double t = p->t[col];
        if (t < 0.0) t = p->t[0];

        /* ISPB: the manual tabulates it per M1, 5.625 for M1 = 0-3 and
         * .125 for M1 = 5-7.  The M1 = 4 row fell in the page break
         * between printed pages 17-2 and 17-3 and is not in the text at
         * all, so the cutoff below is PROVISIONAL: it follows gpc,
         * which takes the
         * .125 branch for the whole illegal-M1 group (100-111, i.e.
         * M1 >= 4).  Only M1 = 4 is in doubt; 0-3 and 5-7 are read
         * directly from the table. */
        if (strcmp(nm, "ISPB") == 0 && df_get(v, 'x') >= 4) return 0.125;

        /* Parametric rows. */
        if (strcmp(nm, "NCT") == 0) return t + 0.075 * (double)preN;
        if (strcmp(nm, "SRDR") == 0) {
            uint32_t n = preN;
            return t + 0.5 * (double)(n < 32 ? n : n - 32);
        }
        if (strcmp(nm, "SUM") == 0) {
            /* "2.5 * (# ELEMENTS TESTED)".  How many get tested depends
             * on where the scan stops, which is not knowable before the
             * instruction runs, so this is the all-elements case -- an
             * over-estimate whenever SUM exits early. */
            uint32_t n = preN ? preN : 1;
            return t * (double)n;
        }

        /* Branches tabulated as "BT=x; BNT=y" -- the pair applies to
         * normal addressing only; the indirection/indexing columns are
         * single figures. */
        if (col == 0) {
            for (size_t i = 0; i < POO_BRANCH_COUNT; i++) {
                if (strcmp(POO_BRANCH_NOT_TAKEN[i].nm, nm) == 0) {
                    return branchTaken ? t : POO_BRANCH_NOT_TAKEN[i].notTaken;
                }
            }
        }
        return t;
    }

    int idx;
    if ((e->indirect || e->index) && indexed) {
        idx = seePoo ? e->indirect : e->index;
    } else {
        idx = e->normal;
    }
    return resolve_times_index(idx, preN, branchTaken);
}
