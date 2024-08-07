/*
  File BOUNDARY_ALIGN.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
BOUNDARY_ALIGN (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "BOUNDARY_ALIGN");
  // IF (LOCCTR(INDEXNEST)&PLUS(TYPE))=0 THEN (1106)
  if (1
      & (xEQ (xAND (getFIXED (mLOCCTR + 4 * COREHALFWORD (mINDEXNEST)),
                    getFIXED (mBOUNDARY_ALIGNxPLUS
                              + 4 * COREHALFWORD (mBOUNDARY_ALIGNxTYPE))),
              0)))
    // RETURN; (1107)
    {
      reentryGuard = 0;
      return 0;
    }
  // LOCCTR(INDEXNEST) = (LOCCTR(INDEXNEST) + PLUS(TYPE)) & MASK(TYPE); (1108)
  {
    int32_t numberRHS = (int32_t)(xAND (
        xadd (getFIXED (mLOCCTR + 4 * COREHALFWORD (mINDEXNEST)),
              getFIXED (mBOUNDARY_ALIGNxPLUS
                        + 4 * COREHALFWORD (mBOUNDARY_ALIGNxTYPE))),
        getFIXED (mBOUNDARY_ALIGNxMASK
                  + 4 * COREHALFWORD (mBOUNDARY_ALIGNxTYPE))));
    putFIXED (mLOCCTR + 4 * (COREHALFWORD (mINDEXNEST)), numberRHS);
  }
  // CALL EMITC(CNOP, PLUS(TYPE)); (1109)
  {
    putBITp (16, mEMITCxTYPE, getBIT (8, mCNOP));
    putBITp (16, mEMITCxINST,
             fixedToBit (32, (int32_t)(getFIXED (
                                 mBOUNDARY_ALIGNxPLUS
                                 + 4 * COREHALFWORD (mBOUNDARY_ALIGNxTYPE)))));
    EMITC (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
