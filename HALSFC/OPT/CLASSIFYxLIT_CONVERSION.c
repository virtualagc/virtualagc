/*
  File CLASSIFYxLIT_CONVERSION.c generated by XCOM-I, 2024-08-09 12:38:53.
*/

#include "runtimeC.h"

descriptor_t *
CLASSIFYxLIT_CONVERSION (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CLASSIFYxLIT_CONVERSION");
  // RETURN (SHR(OPR(PTR + 1),4) &  15) = LIT; (2163)
  {
    reentryGuard = 0;
    return fixedToBit (
        32,
        (int32_t)(xEQ (
            xAND (SHR (getFIXED (mOPR
                                 + 4 * xadd (COREHALFWORD (mCLASSIFYxPTR), 1)),
                       4),
                  15),
            COREHALFWORD (mLIT))));
  }
}