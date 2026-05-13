/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    inline360.h
 * Purpose:     Header for inline360.c.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-06-30 RSB  Split off from runtimeC.h.
 *              2026-05-01 DS   Alterations related to HFP-native arithmetic.
 *              2026-05-12 RSB  Added `swr` function.
 */

#ifndef INLINE360_H
#define INLINE360_H

#include <stdint.h>
#include "ibmFloat.h"

// Memory accessors live in runtimeC.{c,h}; runtimeC.h re-declares these
// after it pulls inline360.h in, so the redeclaration there is compatible.
extern uint32_t COREWORD(uint32_t address);
extern void     COREWORD2(uint32_t address, uint32_t value);

extern int32_t GR[16]; // General registers.
extern uint64_t FR[16]; // Floating-point registers.

// Read FR[r] as a C double (for arithmetic ops).
static inline double FR_d(int r) {
    return ibm_dp_to_double((uint32_t)(FR[r] >> 32), (uint32_t)FR[r]);
}
// Pack a C double into FR[r] (after arithmetic).
static inline void FR_setd(int r, double d) {
    uint32_t m, l;
    ibm_dp_from_double(&m, &l, d);
    FR[r] = ((uint64_t)m << 32) | l;
}
// Pack two halfwords directly (used by LD; bypasses double).
static inline void FR_setbits(int r, uint32_t msw, uint32_t lsw) {
    FR[r] = ((uint64_t)msw << 32) | lsw;
}
// Accessors for the two halves of FR[r].
static inline uint32_t FR_msw(int r) { return (uint32_t)(FR[r] >> 32); }
static inline uint32_t FR_lsw(int r) { return (uint32_t)FR[r]; }

extern uint8_t CC;      // Condition codes.
extern int64_t scratch; // Holds temporary results of IBM 360 operations.
extern double scratchd, dummy360d, epsilon360;
extern int32_t address360A, address360B, mask360, i360, i360A;
extern uint32_t msw360, lsw360;

void
setCC(void);

void
setCCd(void);

// Set CC from a packed IBM DP value, without converting to C double.
// Used by ops (e.g., CDR) that route through ibm_dp_add/ibm_dp_sub
// so we don't lose the LSB to a 53-bit C-double round-trip just to set flags.
static inline void setCCi(uint64_t a) {
    if ((a & IBM_DP_MANT_MASK) == 0) CC = 0;        // mantissa zero
    else if (a & IBM_DP_SIGN_BIT)  CC = 1;         // negative
    else                                  CC = 2;         // positive
}

// Load an IBM hex DP value (8 bytes) from memory, returned as a packed
// uint64 in FR[] format.  Companion to FR_setbits().
static inline uint64_t ibm_dp_load(uint32_t address) {
    return ((uint64_t)COREWORD(address) << 32) | COREWORD(address + 4);
}

// 360 instruction emulators:
void lpdr(int r1, int r2);              // LPDR - Load Positive (DR): |FR[r2]| → FR[r1]; CC.
void ldr (int r1, int r2);              // LDR  - Load DR: FR[r1] = FR[r2].  No CC.
void ld  (int r1, uint32_t address);    // LD   - Load (mem): FR[r1] = mem.  No CC.
void le  (int r1, uint32_t address);    // LE   - Load short: FR[r1].msw = mem, lsw = 0.
void cdr (int r1, int r2);              // CDR  - Compare DR: CC := sign(FR[r1] - FR[r2]).
void cd  (int r1, uint32_t address);    // CD   - Compare (mem): CC := sign(FR[r1] - mem).
void adr (int r1, int r2);              // ADR  - Add DR: FR[r1] += FR[r2]; CC.
void ad  (int r1, uint32_t address);    // AD   - Add (mem): FR[r1] += mem; CC.
void aw  (int r1, uint32_t address);    // AW   - Add Unnormalized; used by PREP_LITERAL
void sdr (int r1, int r2);              // SDR  - Sub DR: FR[r1] -= FR[r2]; CC.
void sd  (int r1, uint32_t address);    // SD   - Sub (mem): FR[r1] -= mem; CC.
void std (int r1, uint32_t address);    // STD  - Store DP: mem = FR[r1].
void ste (int r1, uint32_t address);    // STE  - Store SP: mem = msw(FR[r1]).
                                        //        with FIXER to extract integer part.
void swr (int r1, int r2);

// Non-FP block ops.
void mvc(uint32_t dest, uint32_t src, int32_t countMinus1);
void trt(uint32_t source, uint32_t table, int length);

#endif // INLINE360_H
