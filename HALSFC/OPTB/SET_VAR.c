/*
  File SET_VAR.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

descriptor_t *
SET_VAR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SET_VAR");
  // IF XHALMAT_QUAL(PTR) = XXPT THEN (1681)
  if (1
      & (xEQ (bitToFixed (
                  (putBITp (16, mXHALMAT_QUALxPTR, getBIT (16, mSET_VARxPTR)),
                   XHALMAT_QUAL (0))),
              COREHALFWORD (mXXPT))))
    // PTR = LAST_OPERAND(SHR(OPR(PTR),16)); (1682)
    {
      descriptor_t *bitRHS
          = (putBITp (
                 16, mLAST_OPERANDxPTR,
                 fixedToBit (
                     32, (int32_t)(SHR (
                             getFIXED (mOPR + 4 * COREHALFWORD (mSET_VARxPTR)),
                             16)))),
             LAST_OPERAND (0));
      putBIT (16, mSET_VARxPTR, bitRHS);
      bitRHS->inUse = 0;
    }
  // VAR = SHR(OPR(PTR),16); (1683)
  {
    int32_t numberRHS = (int32_t)(SHR (
        getFIXED (mOPR + 4 * COREHALFWORD (mSET_VARxPTR)), 16));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVAR, bitRHS);
    bitRHS->inUse = 0;
  }
  // VAR_TYPE = SYT_TYPE(VAR); (1684)
  {
    descriptor_t *bitRHS = getBIT (
        8, getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mVAR)) + 32 + 1 * (0));
    putBIT (16, mVAR_TYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
