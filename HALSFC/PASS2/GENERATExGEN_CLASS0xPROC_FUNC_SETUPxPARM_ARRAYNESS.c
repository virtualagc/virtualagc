/*
  File GENERATExGEN_CLASS0xPROC_FUNC_SETUPxPARM_ARRAYNESS.c generated by
  XCOM-I, 2024-08-09 12:39:31.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExGEN_CLASS0xPROC_FUNC_SETUPxPARM_ARRAYNESS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (
      reentryGuard, "GENERATExGEN_CLASS0xPROC_FUNC_SETUPxPARM_ARRAYNESS");
  // IF SYMFORM(FORM(RIGHTOP)) THEN (11659)
  if (1
      & (bitToFixed (
          getBIT (1, mSYMFORM
                         + 1
                               * COREHALFWORD (getFIXED (mIND_STACK)
                                               + 73 * (COREHALFWORD (mRIGHTOP))
                                               + 32 + 2 * (0))))))
    // IF TYPE(RIGHTOP) = STRUCTURE THEN (11660)
    if (1
        & (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mRIGHTOP)) + 50 + 2 * (0)),
                BYTE0 (mSTRUCTURE))))
      // RETURN SYT_ARRAY(LOC(RIGHTOP)); (11661)
      {
        reentryGuard = 0;
        return getBIT (
            16, getFIXED (mSYM_TAB)
                    + 34
                          * (COREHALFWORD (getFIXED (mIND_STACK)
                                           + 73 * (COREHALFWORD (mRIGHTOP))
                                           + 40 + 2 * (0)))
                    + 20 + 2 * (0));
      }
    // ELSE (11662)
    else
      // RETURN GETARRAYDIM(1, LOC2(RIGHTOP)); (11663)
      {
        reentryGuard = 0;
        return (putBITp (8, mGETARRAYDIMxIX, fixedToBit (32, (int32_t)(1))),
                putBITp (16, mGETARRAYDIMxOP1,
                         getBIT (16, getFIXED (mIND_STACK)
                                         + 73 * (COREHALFWORD (mRIGHTOP)) + 42
                                         + 2 * (0))),
                GETARRAYDIM (0));
      }
  // RETURN SF_RANGE(VAL(RIGHTOP)); (11664)
  {
    reentryGuard = 0;
    return getBIT (16, mGENERATExSF_RANGE
                           + 2
                                 * getFIXED (getFIXED (mIND_STACK)
                                             + 73 * (COREHALFWORD (mRIGHTOP))
                                             + 12 + 4 * (0)));
  }
}