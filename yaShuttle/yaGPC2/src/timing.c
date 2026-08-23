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
 * PROVENANCE, WHICH IS NOT UNIFORM ACROSS THIS TABLE.  It began as the
 * twenty-two rows section 17 gives for instructions HAL/S-FC's own
 * compiler never emitted, and every figure in those twenty-two WAS READ
 * FROM THE PRINTED DOCUMENT -- three of these pages reached us as OCR
 * bad enough to lose figures and, on p.17-4, the whole INSTRUCTION
 * column, and a human read the printed pages to resolve them.  Those
 * rows still carry their page/line citations below.
 *
 * The remaining rows come from gpc/cpu_instr.coffee's `xts:`/`xtbs:`
 * arrays -- Don Schmidt's own transcription of the same section-17
 * table, taken wholesale so this port would stop guessing timings for
 * the ~110 instructions it had no manual reading of.  They are NOT
 * independently verified here.  Where the two sources overlap they were
 * compared row by row and agree exactly, with one 5 ns exception (SSM,
 * noted at its entry), which is the main reason for trusting the rest.
 * Spot checks against the printed pages (L, LA, AH, LM) also agreed.
 *
 * Four things are inference rather than reading, each marked at its own
 * entry:
 *
 *   - SSM's four middle columns, printed to two decimals, read as the
 *     .125 multiples they round to.
 *   - ISPB's M1 = 4, which the original document does not list --
 *     though the instruction's own M1 decode puts it with the illegal
 *     encodings whose times ARE listed, so the value is not in doubt.
 *   - DIAG, ICR and PC, where the manual gives a phrase or a range
 *     instead of a number.
 *   - SUM and LXA/LXAR's early-out cases, which are runtime-dependent
 *     and modelled at their worst case.
 *
 * A NOTE ON THE RR FORMS.  This table prints the BASE mnemonic and lets
 * the form column separate the variants, so p.17-3 carries two rows both
 * labelled LXA -- one RR, one RS -- and p.17-4 two both labelled STXA.
 * The assembler spells the RR forms differently: section 10 lists one
 * entry "Load Extended Address LXA RR,RS" whose RR form is written
 * LXAR R1,R2 and whose RS form is LXA R1,D2(B2), and model101tables.py
 * gives them distinct opcodes.  So the LXA/STXA RR rows are this port's
 * LXAR/STXAR, and are keyed that way below; they were not misread.
 * ------------------------------------------------------------------- */

#define NA (-1.0)

/* SSM (p.17-4 L13709).  The OCR had destroyed the normal-addressing
 * figure, rendering it "704"; the printed page says 7.75.  Its four
 * middle columns are printed to two decimals where the last two are
 * printed to three, so 10.63/11.63/10.38 are read here as
 * 10.625/11.625/10.375 -- the table's figures are multiples of .125
 * throughout and no two-decimal value in it is exact.  That reading is
 * inference; gpc keeps the printed 10.63/11.63/10.38, and this is the
 * one row where the two sources differ.  The difference is 5 ns.
 *
 * ISPB is listed one row per M1 value: M1 = 0-3 at 5.625 (p.17-2
 * L13578-81) and M1 = 5-7 at .125 (p.17-3 L13592-94).  THERE IS NO
 * M1 = 4 ROW -- confirmed by reading the printed pages, so this is an
 * omission in the original document rather than something the OCR or
 * the page break lost.
 *
 * .125 is nonetheless the right value for it, and the instruction's own
 * definition says why.  M1 selects what ISPB does, and the four
 * encodings divide exactly the way the two timing groups do (p.9-4):
 * 000/001 reset the protection bits for the halfword or fullword
 * second operand, 010/011 set them -- the four real operations, at
 * 5.625 -- while "100 Illegal, 101 Illegal, 110 Illegal, 111
 * Illegal".  M1 = 4 is 100, one of the four illegal encodings, whose
 * other three are the attested .125 rows.  An illegal M1 does no
 * storage work at all; it raises the illegal-operation interrupt.
 * gpc puts the cutoff at M1 >= 5, i.e. it charges an illegal M1 = 4
 * the full 5.625; this port charges .125.  See poo_override().
 *
 * DIAG, ICR and PC are the three rows the manual gives no single number
 * for -- "SEE POO" (per-function times in POO s.15), "COMMAND
 * DEPENDENT" (ICR's real per-command times are applied in
 * poo_override(), from 85-C67-001 p.10-3), and ">4.25 BUT <22.5 (NO CUR
 * DMA)", a range whose low end is taken as the no-DMA typical case. */

typedef struct {
    const char *nm;
    double t[7];   /* the seven addressing-mode columns; NA = "--" */
    double bt[2];  /* branch [taken, not-taken]; NA if not a branch */
} PooTimingEntry;

/* Rows carrying a page/line citation were read from the printed manual;
 * the rest are gpc's transcription of the same table (see the header
 * comment above).  Sorted by mnemonic so a row is findable by eye. */
static const PooTimingEntry POO_TIMING_TABLE[] = {
    {"A",       {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,   7.25}, {NA, NA}},
    {"AE",      {   2.5,   6.75,    6.5,    6.5,    6.5,    7.5,      9}, {NA, NA}},
    {"AED",     {   6.5,   10.5,  10.25,  10.25,  10.25,   11.5,  13.25}, {NA, NA}},
    {"AEDR",    {  6.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"AER",     {  2.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"AH",      {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,      7}, {NA, NA}},
    {"AHI",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"AR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"AST",     {  0.75,      6,      7,   5.75,      7,   8.25,  10.25}, {NA, NA}},
    {"BAL",     {  3.75,      7,     10,   6.75,     10,      8,    9.5}, {NA, NA}},
    {"BALR",    {    NA,     NA,     NA,     NA,     NA,     NA,     NA}, {3.5, 4.5}},
    {"BC",      {  1.25,   4.25,   7.25,      4,   7.25,   5.25,   6.25}, {1.25, 0.25}},
    {"BCB",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* p.17-2 L13537 */
    {"BCF",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"BCR",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"BCRE",    {    NA,     NA,     NA,     NA,     NA,     NA,     NA}, {5.75, 0.5}},
    {"BCT",     {  1.75,    4.5,    7.5,   4.25,    7.5,    5.5,      7}, {1.75, 0.75}},
    {"BCTB",    {    NA,     NA,     NA,     NA,     NA,     NA,     NA}, {1.75, 0.75}},
    {"BCTR",    {    NA,     NA,     NA,     NA,     NA,     NA,     NA}, {1.75, 0.75}},
    {"BIX",     {   2.5,   5.75,   8.75,    5.5,   8.75,   6.75,   8.25}, {2.5, 1.5}},
    {"BVC",     {  1.25,      4,      7,   3.75,      7,      5,    6.5}, {1.25, 0.5}},  /* p.17-2 L13545; BT/BNT */
    {"BVCF",    {  1.25,     NA,     NA,     NA,     NA,     NA,     NA}, {1.25, 0.5}},  /* p.17-2 L13546; BT/BNT */
    {"BVCR",    {  1.25,     NA,     NA,     NA,     NA,     NA,     NA}, {1.25, 0.5}},  /* p.17-2 L13547; BT/BNT */
    {"C",       {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,   7.25}, {NA, NA}},
    {"CBL",     {     5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* "AVG. = 5.0"; p.17-2 L13550 */
    {"CE",      {  1.75,      6,   5.75,   5.75,   5.75,   6.75,    8.5}, {NA, NA}},
    {"CED",     {  5.75,   9.75,    9.5,    9.5,    9.5,  10.75,   12.5}, {NA, NA}},
    {"CEDR",    {   5.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"CER",     {   1.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"CH",      {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,      7}, {NA, NA}},
    {"CHI",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"CIST",    {   1.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"CR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"CVFL",    {  1.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"CVFX",    {  2.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"D",       { 4.925,   9.05,    8.8,    8.8,    8.8,  10.05,   11.8}, {NA, NA}},
    {"DE",      {   7.5,     12,   11.5,   11.5,   11.5,  12.75,  15.25}, {NA, NA}},
    {"DED",     {    23,  27.75,  27.75,  27.75,  27.75,  28.75,  29.75}, {NA, NA}},
    {"DEDR",    { 22.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"DER",     {  7.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"DIAG",    {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* "SEE POO" -- stand-in; p.17-2 L13571 */
    {"DR",      { 4.925,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"IAL",     {   0.5,      4,      5,   3.75,      5,   6.25,      8}, {NA, NA}},
    {"ICR",     {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* "COMMAND DEPENDENT" -- per-command below; p.17-2 L13576 */
    {"IHL",     {   0.5,   4.75,    4.5,    4.5,    4.5,   5.75,   7.25}, {NA, NA}},
    {"ISPB",    { 5.625,      8,      9,   7.75,      9,  10.25,     12}, {NA, NA}},  /* p.17-2 L13578-81 / 17-3 L13592-94; M1>=4 -> 0.125 */
    {"L",       {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,   7.25}, {NA, NA}},
    {"LA",      {  0.25,      4,      5,   3.75,      5,   6.25,      8}, {NA, NA}},
    {"LCR",     {   0.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LDM",     {  6.75,     10,     10,     10,     10,  10.25,  10.25}, {NA, NA}},
    {"LE",      {   1.2,      5,   4.75,   4.75,   4.75,   5.75,    8.5}, {NA, NA}},
    {"LECR",    {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LED",     {   1.5,    5.5,      5,      5,      5,   6.25,   8.75}, {NA, NA}},
    {"LER",     {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LFLI",    {  0.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LFLR",    {  0.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* p.17-3 L13607 */
    {"LFXI",    {  0.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LFXR",    {  0.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* p.17-3 L13609 */
    {"LH",      {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,      7}, {NA, NA}},
    {"LHI",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LM",      {   8.5,  12.25,  13.25,     12,  13.25,   14.5,  16.25}, {NA, NA}},
    {"LPS",     { 10.25,  13.25,  14.25,     13,  14.25,   15.5,  17.25}, {NA, NA}},  /* p.17-3 L13613 */
    {"LR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"LXA",     {   3.5,    6.5,   6.25,   6.25,   6.25,    6.5,   5.25}, {NA, NA}},  /* p.17-3 L13616 (RS); -1.25 early out below */
    {"LXAR",    {   3.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* p.17-3 L13615 (RR); -1.25 early out below */
    {"M",       {   2.4,   6.53,   7.53,   6.28,   7.53,   8.78,  10.53}, {NA, NA}},
    {"ME",      {  6.25,   10.5,  10.25,  10.25,  10.25,   11.5,  13.25}, {NA, NA}},
    {"MED",     {    19,   22.5,  22.25,  22.25,  22.25,  24.25,  25.75}, {NA, NA}},
    {"MEDR",    {  18.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"MER",     {     6,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"MH",      {  1.35,   5.48,   5.23,   5.23,   5.23,   6.48,   7.98}, {NA, NA}},
    {"MHI",     {  1.35,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"MIH",     {   1.7,   5.83,   5.58,   5.58,   5.58,  6.825,  8.025}, {NA, NA}},
    {"MR",      {   2.4,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"MSTH",    {     3,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"MVH",     {  7.75,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"N",       {  0.25,   4.75,    4.5,    4.5,    4.5,   5.75,    6.5}, {NA, NA}},
    {"NCT",     {  1.05,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* base; + .075*N; p.17-3 L13644 */
    {"NHI",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"NIST",    {     3,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"NR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"NST",     {  0.75,      6,      7,   5.75,      7,   8.25,  10.25}, {NA, NA}},
    {"O",       {  0.25,   4.75,    4.5,    4.5,    4.5,   5.75,    6.5}, {NA, NA}},
    {"OHI",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"OR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"OST",     {  0.75,      6,      7,   5.75,      7,   8.25,  10.25}, {NA, NA}},
    {"PC",      {   4.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* ">4.25 BUT <22.5 (NO CUR DMA)" -- low end; p.17-4 L13668 */
    {"S",       {  0.25,    4.5,   4.25,   4.25,   4.25,    5.5,   7.25}, {NA, NA}},
    {"SB",      {     3,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SCAL",    {18.125,   21.5,   24.5,  21.25,   24.5,   22.5,     24}, {NA, NA}},
    {"SE",      {   2.5,   4.75,    4.5,    4.5,    4.5,    4.5,    9.5}, {NA, NA}},
    {"SED",     {   6.5,  10.75,   10.5,   10.5,   10.5,   11.5,   13.5}, {NA, NA}},
    {"SEDR",    {  6.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SER",     {  2.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SH",      {  0.25,    4.5,   4.25,   4.25,   4.25,   5.75,   7.25}, {NA, NA}},
    {"SHW",     {   1.5,    4.5,    5.5,   4.25,    5.5,   6.75,    8.5}, {NA, NA}},
    {"SLDL",    {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SLL",     { 0.675,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SPM",     {  5.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SRA",     {  0.65,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SRDA",    {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SRDL",    {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SRDR",    {     2,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* base; + .5*(N mod 32); p.17-4 L13700,13702 */
    {"SRET",    {  17.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SRL",     {  0.65,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SRR",     {  0.65,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"SSM",     {  7.75, 10.625, 11.625, 10.375, 11.625, 12.875, 14.625}, {NA, NA}},  /* p.17-4 L13709; see note */
    {"SST",     {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"ST",      {   0.5,   4.75,   5.75,    4.5,   5.75,      7,      9}, {NA, NA}},
    {"STDM",    {  2.25,   5.25,   6.75,      5,   5.25,      7,    7.5}, {NA, NA}},  /* p.17-4 L13715 */
    {"STE",     {   0.5,   4.75,    4.5,    4.5,    4.5,    4.5,    7.5}, {NA, NA}},
    {"STED",    {     1,   5.25,      5,      5,      5,      5,    7.5}, {NA, NA}},
    {"STH",     {   0.5,    4.5,    5.5,   4.25,    5.5,   6.75,    8.5}, {NA, NA}},
    {"STM",     {  7.25,  10.25,  11.25,     10,  11.25,   12.5,  14.25}, {NA, NA}},
    {"STXA",    {   2.5,    6.5,      8,   6.25,      8,   8.25,   8.75}, {NA, NA}},  /* p.17-4 L13726 (RS) */
    {"STXAR",   {   2.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* p.17-4 L13724-25 (RR) */
    {"SUM",     {   2.5,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* base; * elements tested; p.17-4 L13727-28 */
    {"SVC",     { 20.25,  22.75,  23.75,   22.5,  23.75,     25,  26.75}, {NA, NA}},
    {"TB",      {     2,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"TD",      {     3,   5.75,    5.5,    5.5,    5.5,   6.75,   8.25}, {NA, NA}},
    {"TH",      {  1.75,   5.25,      5,      5,      5,   6.25,   7.75}, {NA, NA}},
    {"TRB",     {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"TS",      {  3.75,    6.5,   6.25,   6.25,   6.25,    7.5,      9}, {NA, NA}},
    {"TSB",     {     3,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"X",       {  0.25,   4.75,    4.5,    4.5,    4.5,   5.75,    7.5}, {NA, NA}},
    {"XHI",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"XIST",    {     3,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"XR",      {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"XST",     {  0.75,      6,      7,   5.75,      7,   8.25,  10.25}, {NA, NA}},
    {"XUL",     {     1,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},  /* p.17-4 L13759-60 */
    {"ZB",      {  3.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
    {"ZH",      {   1.5,    4.5,    5.5,   4.25,    5.5,   6.75,    8.5}, {NA, NA}},
    {"ZRB",     {  0.25,     NA,     NA,     NA,     NA,     NA,     NA}, {NA, NA}},
};
#define POO_TIMING_COUNT (sizeof(POO_TIMING_TABLE) / sizeof(POO_TIMING_TABLE[0]))

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
    cpu->timePooOverrideUs = -1.0;

    if (desc->opType == OPTYPE_SHFT) return cpu_g_shift_cnt(cpu, hw1);

    if (strcmp(desc->nm, "MVH") == 0) {
        /* MVH is the one instruction whose section-17 figure cannot be
         * reconstructed after execution at all: it overwrites its own
         * count register, and the "source immediately follows
         * destination" case needs both operands' expanded addresses.
         * So the whole POO figure is computed here, ahead of the move,
         * exactly as gpc's own MVH body computes it.  The PASS2 model
         * needs only the count, which is what this still returns. */
        uint32_t r1val = register_get32(cpu_r(cpu, (int)df_get(v, 'x')));
        uint32_t r2val = register_get32(cpu_r(cpu, (int)df_get(v, 'y')));
        uint32_t destAddr = (r1val >> 16) & 0xffff;
        uint32_t count = r1val & 0xffff;
        if (count & 0x8000) {
            /* A negative count is a no-op; the PSW-DSR destination path
             * still runs 2.25 us faster. */
            cpu->timePooOverrideUs = (destAddr & 0x8000) ? (7.5 - 2.25) : 7.5;
            return count;
        }
        uint32_t srcAddr = (r2val >> 16) & 0x7fff;
        if (r2val & 0x80000000u) srcAddr = ((r2val & 0xf) << 15) | srcAddr;
        /* Destination sector: R1 bit 0 = 1 selects the PSW's DSR, bit
         * 0 = 0 selects R1's own DSE register (POO section 9). */
        bool destUsesDSR = (destAddr & 0x8000) != 0;
        if (destUsesDSR) {
            destAddr = (psw_get_dsr(&cpu->psw) << 15) | (destAddr & 0x7fff);
        } else {
            uint32_t dse = registerfile_get_dse(
                &cpu->regFiles[psw_get_reg_set(&cpu->psw)], (int)df_get(v, 'x'));
            destAddr = (dse << 15) | (destAddr & 0x7fff);
        }
        double t;
        if (count == 0)                        t = 7.75;
        else if (srcAddr - destAddr == 1)      t = 9.5 + 1.75 * (double)count;
        else if (count % 2 == 0)               t = 10.25 + 0.875 * (double)count;
        else                                   t = 12.0 + 0.875 * (double)(count - 1);
        if (destUsesDSR) t -= 2.25;
        cpu->timePooOverrideUs = t;
        return count;
    }

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
    if (strcmp(desc->nm, "LXA") == 0 || strcmp(desc->nm, "LXAR") == 0) {
        /* LXA/LXAR run 1.25 us faster when the DSE they are loading is
         * the one R1 already holds -- a microcode early out.  Both
         * halves of that comparison are gone by the time the
         * instruction finishes, since the new DSE has been stored; but
         * the new value always equals what was loaded, so comparing the
         * DSE captured here against the DSE afterwards answers the same
         * question.  See poo_override(). */
        return registerfile_get_dse(
            &cpu->regFiles[psw_get_reg_set(&cpu->psw)], (int)df_get(v, 'x'));
    }
    if (strcmp(desc->nm, "ICR") == 0) {
        /* ICR's time depends on the command in R2 (bits 0-4). */
        return (register_get32(cpu_r(cpu, (int)df_get(v, 'y'))) >> 27) & 0x1f;
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

/* Picks the addressing-mode column, falling back to normal addressing
 * for a form the manual marks "--".  Mirrors gpc's xtPick(). */
static double xt_pick(const double t[7], int xtCase) {
    double x = (xtCase >= 0 && xtCase < 7) ? t[xtCase] : t[0];
    return (x < 0.0) ? t[0] : x;
}

/* The section-17 rows the manual states as a formula or a condition
 * rather than a number.  Returns a time in us, or a negative value for
 * "no override; use the table row".  Every case here is gpc's, and the
 * few places this port deliberately differs are called out.
 *
 * `preN` carries whatever instr_time_pre_n() captured for this
 * mnemonic; `cpu` is read for LXA/LXAR's post-execution DSE only. */
static double poo_override(CPU *cpu, const char *nm, const DInstr *v,
                           uint32_t preN, int xtCase) {
    bool oddR = (df_get(v, 'x') & 1) != 0;

    /* MVH: computed in full before execution (see instr_time_pre_n). */
    if (cpu->timePooOverrideUs >= 0.0) return cpu->timePooOverrideUs;

    /* Multiply/divide with an ODD R1 keep only the high half of the
     * product (or take the short divide path) and are correspondingly
     * cheaper; the manual gives them their own rows. */
    if (oddR) {
        static const double D_ODD[7]  = {4.675, 8.8, 7.55, 7.55, 7.55, 9.8, 10.05};
        static const double M_ODD[7]  = {2.15, 6.28, 7.28, 6.03, 7.28, 8.53, 10.28};
        static const double ME_ODD[7] = {5.75, 10.0, 9.75, 9.75, 9.75, 11.0, 12.75};
        if (strcmp(nm, "DR") == 0)  return 4.675;
        if (strcmp(nm, "MR") == 0)  return 2.15;
        if (strcmp(nm, "MER") == 0) return 5.5;
        if (strcmp(nm, "D") == 0)   return xt_pick(D_ODD, xtCase);
        if (strcmp(nm, "M") == 0)   return xt_pick(M_ODD, xtCase);
        if (strcmp(nm, "ME") == 0)  return xt_pick(ME_ODD, xtCase);
    } else if (strcmp(nm, "ME") == 0 && v->niaIncr == 1) {
        return 5.75;   /* the short (SRS) form is 5.75 either parity */
    }

    /* Shifts: "base + perUnit * (shift count)". */
    if (strcmp(nm, "SLL") == 0)  return 0.675 + 0.1  * (double)preN;
    if (strcmp(nm, "SRA") == 0)  return 0.65  + 0.1  * (double)preN;
    if (strcmp(nm, "SRL") == 0)  return 0.65  + 0.1  * (double)preN;
    if (strcmp(nm, "SRR") == 0)  return 0.65  + 0.1  * (double)(preN % 32);
    if (strcmp(nm, "SLDL") == 0) return 1.0   + 0.25 * (double)preN;
    if (strcmp(nm, "SRDA") == 0) return 1.0   + 0.25 * (double)preN;
    if (strcmp(nm, "SRDL") == 0) return 1.0   + 0.1  * (double)preN;
    if (strcmp(nm, "SRDR") == 0) return 2.0   + 0.5  * (double)(preN < 32 ? preN : preN - 32);

    if (strcmp(nm, "NCT") == 0) return 1.05 + 0.075 * (double)preN;

    if (strcmp(nm, "SUM") == 0) {
        /* "2.5 * (# ELEMENTS TESTED)".  gpc knows the real figure
         * because it sets the time from inside the scan loop; this port
         * charges the whole array, which over-estimates whenever SUM
         * stops early.  It is the one section-17 formula here that is
         * not exact. */
        uint32_t n = preN ? preN : 1;
        return 2.5 * (double)n;
    }

    if (strcmp(nm, "LXA") == 0 || strcmp(nm, "LXAR") == 0) {
        /* -1.25 microcode early out when the DSE being loaded is
         * already there.  preN is the DSE captured before execution;
         * the DSE now holds what was loaded, so equality still answers
         * the question (see instr_time_pre_n). */
        uint32_t dseNow = registerfile_get_dse(
            &cpu->regFiles[psw_get_reg_set(&cpu->psw)], (int)df_get(v, 'x'));
        if (dseNow != preN) return -1.0;
        const PooTimingEntry *p = find_poo_entry(nm);
        return p ? xt_pick(p->t, xtCase) - 1.25 : -1.0;
    }

    if (strcmp(nm, "ISPB") == 0) {
        /* Illegal M1 does no storage work at all.  gpc's cutoff is
         * M1 >= 5; this port's is M1 >= 4, because M1 = 4 is the first
         * of the four encodings p.9-4 calls Illegal and the manual
         * simply has no row for it.  See the note above the table. */
        if (df_get(v, 'x') >= 4) return 0.125;
        return -1.0;
    }

    if (strcmp(nm, "ICR") == 0) {
        /* Per-command typical times, 85-C67-001 p.10-3 (via gpc, whose
         * comment records that the read-counter figures are tuned so the
         * GPC self-test does not report CLOCK OUT OF TOLERANCE).  preN
         * is the command field of R2. */
        switch (preN) {
            case 0x00: return 5.5;    /* read counter 1  */
            case 0x01: return 5.75;   /* read counter 2  */
            case 0x08: return 3.5;    /* load counter 1  */
            case 0x09: return 3.75;   /* load counter 2  */
            case 0x05: return 20.25;  /* read AGE        */
            case 0x0d: return 20.0;   /* load AGE        */
            default:   return -1.0;   /* undocumented: table row */
        }
    }

    return -1.0;
}

/* The AP-101S Principles of Operation section-17 model -- the default.
 * Dispatch order is gpc's: a formula row wins; then, for normal
 * addressing only, a branch's taken/not-taken pair; then the
 * addressing-mode column; then the untabulated-instruction floor. */
static double instr_time_poo(CPU *cpu, const InstrDesc *desc, const DInstr *v,
                             uint32_t preN, bool branchTaken) {
    const char *nm = desc->nm;
    int xtCase = cpu->xtCase;

    double ovr = poo_override(cpu, nm, v, preN, xtCase);
    if (ovr >= 0.0) return ovr;

    const PooTimingEntry *p = find_poo_entry(nm);
    if (!p) return INSTR_TIME_UNKNOWN_US;

    /* "BT=x; BNT=y" applies to normal addressing; the indirection and
     * indexing columns are single figures. */
    if (xtCase == 0 && p->bt[0] >= 0.0) return branchTaken ? p->bt[0] : p->bt[1];

    double t = xt_pick(p->t, xtCase);
    return (t < 0.0) ? INSTR_TIME_UNKNOWN_US : t;
}

/* The HAL/S-FC PASS2 compiler's own estimate -- --timing=pass2 only.
 * Kept for comparison against the hardware model above; see timing.h.
 * Unchanged from when it was the default, except that a mnemonic the
 * compiler never named now falls through to the section-17 model
 * rather than costing nothing. */
static double instr_time_pass2(CPU *cpu, const InstrDesc *desc, const DInstr *v,
                               uint32_t preN, bool branchTaken) {
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
    if (!e) return instr_time_poo(cpu, desc, v, preN, branchTaken);

    int idx;
    if ((e->indirect || e->index) && indexed) {
        idx = seePoo ? e->indirect : e->index;
    } else {
        idx = e->normal;
    }
    double t = resolve_times_index(idx, preN, branchTaken);
    return (t > 0.0) ? t : INSTR_TIME_UNKNOWN_US;
}

double instr_time_us(CPU *cpu, const InstrDesc *desc, const DInstr *v,
                     uint32_t preN, bool branchTaken) {
    if (cpu->timingPass2) return instr_time_pass2(cpu, desc, v, preN, branchTaken);
    return instr_time_poo(cpu, desc, v, preN, branchTaken);
}
