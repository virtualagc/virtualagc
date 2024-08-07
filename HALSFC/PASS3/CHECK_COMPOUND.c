/*
  File CHECK_COMPOUND.c generated by XCOM-I, 2024-08-08 04:33:10.
*/

#include "runtimeC.h"

int32_t
CHECK_COMPOUND (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CHECK_COMPOUND");
  // IF TZCOUNT > 0 THEN (1306)
  if (1 & (xGT (COREHALFWORD (mTZCOUNT), 0)))
    // DO; (1307)
    {
    rs1:;
      // LHS_TAB(LHSSAVE) = -TZCOUNT; (1308)
      {
        int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (mTZCOUNT)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mLHS_TAB + 2 * (COREHALFWORD (mLHSSAVE)), bitRHS);
        bitRHS->inUse = 0;
      }
      // TZCOUNT = 0; (1309)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mTZCOUNT, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
