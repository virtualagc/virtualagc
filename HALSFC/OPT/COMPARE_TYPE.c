/*
  File COMPARE_TYPE.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

descriptor_t *
COMPARE_TYPE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "COMPARE_TYPE");
  // PTR = OPR(PTR) &  65521; (3549)
  {
    int32_t numberRHS = (int32_t)(xAND (
        getFIXED (mOPR + 4 * COREHALFWORD (mCOMPARE_TYPExPTR)), 65521));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCOMPARE_TYPExPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR >= XBNEQ AND PTR <= XILT; (3550)
  {
    reentryGuard = 0;
    return fixedToBit (
        32,
        (int32_t)(xAND (
            xGE (COREHALFWORD (mCOMPARE_TYPExPTR), COREHALFWORD (mXBNEQ)),
            xLE (COREHALFWORD (mCOMPARE_TYPExPTR), COREHALFWORD (mXILT)))));
  }
}
