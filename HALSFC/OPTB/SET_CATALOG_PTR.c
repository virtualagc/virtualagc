/*
  File SET_CATALOG_PTR.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
SET_CATALOG_PTR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SET_CATALOG_PTR");
  // CATALOG_ARRAY(REL(PTR)) = VAL; (956)
  {
    descriptor_t *bitRHS = getBIT (16, mSET_CATALOG_PTRxVAL);
    putBIT (
        16,
        getFIXED (mPAR_SYM) + 2 * (COREHALFWORD (mLEVEL)) + 0
            + 2
                  * (COREHALFWORD (getFIXED (mSYM_SHRINK)
                                   + 2 * (COREHALFWORD (mSET_CATALOG_PTRxPTR))
                                   + 0 + 2 * (0))),
        bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
