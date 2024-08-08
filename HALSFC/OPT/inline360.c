/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    inline360.c
 * Purpose:     Global variables and functions for mimicking behavior of
 *              CALL INLINE statements in XCOM-I framework.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-06-30 RSB  Split off from runtimeC.c.
 */

#include "runtimeC.h"

int32_t GR[16] = { 0 }; // General registers.
double FR[16] = { 0.0 };   // Floating-point registers.
uint8_t unnormFR[16] = { 0 };  // Tracks whether to unnormalize FR[n].
uint8_t CC;      // Condition codes.
int64_t scratch, dummy360; // Holds temporary results of IBM 360 operations.
double scratchd, dummy360d, epsilon360 = 1.0e-6;
int32_t address360A, address360B, msw360, lsw360, mask360, i360, i360A;

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

void
aw(int regnum, uint32_t address) {
  /*
   * Note that this is a real hack.  Since XCOM-I does its runtime floating-
   * point computations in C floating-point rather than IBM hexadecimal
   * floating point, it has no way to do actual "unnormalized" floating-point
   * computations as the AW function demands.  Rather, it just sets
   * `unnormFR` to tell downstream consumers of the register that the data
   * is unnormalized.  This lets a later STD instruction know that it's
   * supposed to save a binary integer rather than a floating-point number.
   * But it's highly-dependent on the usage pattern I've see in actual CALL
   * INLINE statements.  So it works for all of the XPL code I know about
   * right now, but there's no guarantee that it will be an adequate hack if
   * different usage patterns for unnormalized floating-point values are
   * observed in the future.
   */
  scratchd = FR[regnum];
  scratchd += fromFloatIBM(COREWORD(address), COREWORD(address + 4));
  setCCd();
  if (modf(scratchd, &dummy360d) <= epsilon360)
    CC = 0;
  FR[regnum] = scratchd;
  unnormFR[regnum] = 1;
}

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
std(int regnum, uint32_t address) {
  // Mimics the operation of the IBM 360 STD instruction, with the additional
  // hack of tracking "unnormalized" values representing integers produced
  // by the IBM 360 AW instruction.
  if (regnum < 0 || regnum > 15)
    abend("Bad register number %d in STD", regnum);
  if (unnormFR[regnum])
    {
      int sign = 0;
      unnormFR[regnum] = 0;
      dummy360d = FR[regnum];
      if (dummy360d < 0)
        {
          sign = 0x80000000;
          dummy360d = -dummy360d;
        }
      dummy360 = dummy360d;
      msw360 = ((dummy360 >> 32) & 0x00FFFFFF) | 0x4E000000 | sign;
      lsw360 = dummy360 & 0xFFFFFFFF;
    }
  else
    toFloatIBM(&msw360, &lsw360, FR[regnum]);
  COREWORD2(address360B, msw360);
  COREWORD2(address360B + 4, lsw360);
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

