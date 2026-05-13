/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    inline360.c
 * Purpose:     Global variables and functions for mimicking behavior of
 *              CALL INLINE statements in XCOM-I framework.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-06-30 RSB  Split off from runtimeC.c.
 *              2026-05-01 DS   Alterations related to HFP-native arithmetic.
 *              2026-05-12 RSB  Added `swr` function.
 */

#include "runtimeC.h"

int32_t GR[16] = { 0 }; // General registers.
// Floating-point registers, holding IBM hex DP packed (msw<<32 | lsw).
// See inline360.h for rationale.
uint64_t FR[16] = { 0 };
uint8_t CC;      // Condition codes.
int64_t scratch; // Holds temporary results of IBM 360 operations.
double scratchd, dummy360d, epsilon360 = 1.0e-6;
int32_t address360A, address360B, mask360, i360, i360A;
uint32_t msw360, lsw360;

void
setCC(void) {
  if (scratch > 0x7FFFFFFF || scratch < -0x7FFFFFFF) CC = 3;
  else if (scratch > 0) CC = 2;
  else if (scratch < 0) CC = 1;
  else CC = 0;
}

void
setCCd(void) {
  if (scratchd > 0) CC = 2;
  else if (scratchd < 0) CC = 1;
  else CC = 0;
}

// ---------------------------------------------------------------------------
// Floating point instructions

// LPDR — Load Positive (Double)
// FR[r1] := |FR[r2]|; CC := 0 if zero else 2.
void
lpdr(int r1, int r2) {
  FR[r1] = FR[r2] & IBM_DP_MAGNITUDE_MASK;
  setCCi(FR[r1]);
}

// LDR — Load (Double)
//  FR[r1] := FR[r2]; No CC
void
ldr(int r1, int r2) {
  FR[r1] = FR[r2];
}

// CDR — Compare (Double)
//  CC := sign(FR[r1] - FR[r2])
void
cdr(int r1, int r2) {
  setCCi(ibm_dp_sub(FR[r1], FR[r2]));
}

// ADR — Add (Double)
//  FR[r1] := FR[r1] + FR[r2]; CC.
void
adr(int r1, int r2) {
  FR[r1] = ibm_dp_add(FR[r1], FR[r2]);
  setCCi(FR[r1]);
}

// SDR — Subtract (Double)
//  FR[r1] := FR[r1] - FR[r2]; CC.
void
sdr(int r1, int r2) {
  FR[r1] = ibm_dp_sub(FR[r1], FR[r2]);
  setCCi(FR[r1]);
}

void
swr(int r1, int r2) {
  FR[r1] = ibm_dp_addsub(FR[r1], FR[r2], 1, 0);
  setCCi(FR[r1]);
}

// LD — Load (Double) (Memory).  
//  FR[r1] := mem[address]; No CC.
void
ld(int r1, uint32_t address) {
  FR_setbits(r1, COREWORD(address), COREWORD(address + 4));
}

// LE — Load (Single).  
// FR[r1] = (mem[address] << 32 | 0); No CC.
void
le(int r1, uint32_t address) {
  FR_setbits(r1, COREWORD(address), 0);
}

// CD — Compare (Double) (memory).  
//  CC := sign(FR[r1] - mem).
void
cd(int r1, uint32_t address) {
  setCCi(ibm_dp_sub(FR[r1], ibm_dp_load(address)));
}

// AD — Add Double (memory).  FR[r1] := FR[r1] + mem; CC.
void
ad(int r1, uint32_t address) {
  FR[r1] = ibm_dp_add(FR[r1], ibm_dp_load(address));
  setCCi(FR[r1]);
}

// SD — Subtract Double (memory).  FR[r1] := FR[r1] - mem; CC.
void
sd(int r1, uint32_t address) {
  FR[r1] = ibm_dp_sub(FR[r1], ibm_dp_load(address));
  setCCi(FR[r1]);
}

// STD — Store Double.  Memory := FR[r1] (8 bytes, byte-exact).
void
std(int r1, uint32_t address) {
  COREWORD2(address,     FR_msw(r1));
  COREWORD2(address + 4, FR_lsw(r1));
}

// STE — Store Single (msw of FR[r1] only).
void
ste(int r1, uint32_t address) {
  COREWORD2(address, FR_msw(r1));
}

// AW — Add Unnormalized.  Adds two IBM DP floats without normalizing the
// result; the result's exponent is the larger input exponent regardless of
// leading zeros in the result mantissa.  Delegates to ibm_dp_addsub with
// normalize=0 (a direct port of Hyperion's add_lf, including the 4-bit
// guard digit through alignment).
//
// HAL/S-FC's PREP_LITERAL/MAKE_FIXED_LIT/INTEGERIZABLE/ROUND_SCALAR/
// HALMAT_INIT_CONST all use AW with the FIXER constant
// (0x4E000000_00000000): aligning a normalized value to exp 0x4E shifts
// its fractional bits past the right edge, leaving lsw = trunc(|v|).  STD
// then writes those bytes (the integer is read back as the lsw); a
// subsequent ADR with FR[zero] normalizes the bit pattern into a real IBM
// DP float for the SDR residual check.
void
aw(int regnum, uint32_t address) {
  FR[regnum] = ibm_dp_addsub(FR[regnum], ibm_dp_load(address), 0, 0);
  setCCi(FR[regnum]);
}

// ---------------------------------------------------------------------------
// Non-FP block ops.

void
mvc(uint32_t dest, uint32_t src, int32_t countMinus1) {
  // Mimics the operation of the IBM 360 MVC instruction.  I originally used
  // `memmove` for this, but the problems is that the action of MVC has a
  // defined behavior if the memory areas overlap, and `memmove` does not
  // behave the same way in that case.  Moreover, `memcopy`, which probably
  // *does* match the desired behavior, isn't guaranteed to do so in all
  // implementations. Specifically, overlapping memory areas are sometimes
  // exploited to produce an action like `memset`.
  int i;
  dest = dest & 0xFFFFFF;
  src = src & 0xFFFFFF;
  for (i = 0; i <= countMinus1; i++)
    memory[dest + i] = memory[src + i];
}

void
trt(uint32_t source, uint32_t table, int lengthMinus1) {
  source &= 0xFFFFFF;
  table &= 0xFFFFFF;
  for (i360 = 0; i360 <= lengthMinus1; i360++)
    if (memory[table + memory[source + i360]])
      break;
  if (i360 > lengthMinus1)
    CC = 0;
  else {
    GR[2] = (GR[2] & 0xFFFFFF00) | memory[table + memory[source + i360]];
    GR[1] = (GR[1] & 0xFF000000) | ((source + i360) & 0x00FFFFFF);
    if (i360 < lengthMinus1) CC = 1;
    else CC = 2;
  }
}

