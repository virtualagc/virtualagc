/*
  File DETAG.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
DETAG (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DETAG");
  // IF WATCH THEN (1623)
  if (1 & (bitToFixed (getBIT (8, mWATCH))))
    // OUTPUT = 'DETAG: '||PTR; (1624)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (cToDescriptor (NULL, "DETAG: "),
                         bitToCharacter (getBIT (16, mDETAGxPTR)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // OPR(PTR) = OPR(PTR) &  4294967287; (1625)
  {
    int32_t numberRHS = (int32_t)(xAND (
        getFIXED (mOPR + 4 * COREHALFWORD (mDETAGxPTR)), 4294967287));
    putFIXED (mOPR + 4 * (COREHALFWORD (mDETAGxPTR)), numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
