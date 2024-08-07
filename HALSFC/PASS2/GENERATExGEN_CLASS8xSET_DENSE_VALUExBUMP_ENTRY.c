/*
  File GENERATExGEN_CLASS8xSET_DENSE_VALUExBUMP_ENTRY.c generated by XCOM-I,
  2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS8xSET_DENSE_VALUExBUMP_ENTRY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (
      reentryGuard, "GENERATExGEN_CLASS8xSET_DENSE_VALUExBUMP_ENTRY");
  // DENSE_INX = DENSE_INX + 1; (14198)
  {
    int32_t numberRHS
        = (int32_t)(xadd (COREHALFWORD (mGENERATExDENSE_INX), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExDENSE_INX, bitRHS);
    bitRHS->inUse = 0;
  }
  // DENSEADDR(DENSE_INX) = DENSEADDR(0); (14199)
  {
    int32_t numberRHS
        = (int32_t)(getFIXED (getFIXED (mDNS) + 8 * (0) + 0 + 4 * (0)));
    putFIXED (getFIXED (mDNS) + 8 * (COREHALFWORD (mGENERATExDENSE_INX)) + 0
                  + 4 * (0),
              numberRHS);
  }
  // DENSEVAL(DENSE_INX) = DENSEVAL(0); (14200)
  {
    int32_t numberRHS
        = (int32_t)(getFIXED (getFIXED (mDNS) + 8 * (0) + 4 + 4 * (0)));
    putFIXED (getFIXED (mDNS) + 8 * (COREHALFWORD (mGENERATExDENSE_INX)) + 4
                  + 4 * (0),
              numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
