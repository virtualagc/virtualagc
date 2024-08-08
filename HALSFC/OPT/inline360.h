/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    inline360.h
 * Purpose:     Header for inline360.c.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-06-30 RSB  Split off from runtimeC.h.
 */

#ifndef INLINE360_H
#define INLINE360_H

extern int32_t GR[16]; // General registers.
extern double FR[16];   // Floating-point registers.
extern uint8_t unnormFR[16];  // Tracks whether to unnormalize FR[n].
extern uint8_t CC;      // Condition codes.
extern int64_t scratch, dummy360; // Holds temporary results of IBM 360 operations.
extern double scratchd, dummy360d, epsilon360;
extern int32_t address360A, address360B, msw360, lsw360, mask360, i360, i360A;

void
setCC(void);

void
setCCd(void);

// Some functions to mimic the more-complex IBM 360 instructions.

void
aw(int regnum, uint32_t address);

void
mvc(uint32_t dest, uint32_t src, int32_t countMinus1);

void
std(int regnum, uint32_t address);

void
trt(uint32_t source, uint32_t table, int length);

#endif // INLINE360_H
