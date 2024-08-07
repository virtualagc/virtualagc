/*
  File UNARRAYED_SIMPLE.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
UNARRAYED_SIMPLE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "UNARRAYED_SIMPLE");
  // LOC=PSEUDO_TYPE(PTR(LOC)); (7338)
  {
    descriptor_t *bitRHS = getBIT (
        8, mPSEUDO_TYPE
               + 1
                     * COREHALFWORD (
                         mPTR + 2 * COREHALFWORD (mUNARRAYED_SIMPLExLOC)));
    putBIT (16, mUNARRAYED_SIMPLExLOC, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN CHECK_ARRAYNESS|((LOC~=INT_TYPE)&(LOC~=SCALAR_TYPE)); (7339)
  {
    reentryGuard = 0;
    return xOR (CHECK_ARRAYNESS (0),
                xAND (xNEQ (COREHALFWORD (mUNARRAYED_SIMPLExLOC), 6),
                      xNEQ (COREHALFWORD (mUNARRAYED_SIMPLExLOC), 5)));
  }
}
