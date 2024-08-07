/*
  File SET_LOCCTR.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
SET_LOCCTR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SET_LOCCTR");
  // IF INDEXNEST=NEST THEN (1137)
  if (1 & (xEQ (COREHALFWORD (mINDEXNEST), COREHALFWORD (mSET_LOCCTRxNEST))))
    // IF LOCCTR(INDEXNEST)=VALUE THEN (1138)
    if (1
        & (xEQ (getFIXED (mLOCCTR + 4 * COREHALFWORD (mINDEXNEST)),
                getFIXED (mSET_LOCCTRxVALUE))))
      // RETURN; (1139)
      {
        reentryGuard = 0;
        return 0;
      }
  // INDEXNEST = NEST; (1140)
  {
    descriptor_t *bitRHS = getBIT (16, mSET_LOCCTRxNEST);
    putBIT (16, mINDEXNEST, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF DATA_REMOTE THEN (1141)
  if (1 & (bitToFixed (getBIT (1, mDATA_REMOTE))))
    // IF (INDEXNEST >= PROGPOINT) & (INDEXNEST <= PROCLIMIT) THEN (1142)
    if (1
        & (xAND (xGE (COREHALFWORD (mINDEXNEST), COREHALFWORD (mPROGPOINT)),
                 xLE (COREHALFWORD (mINDEXNEST), COREHALFWORD (mPROCLIMIT)))))
      // NOT_LEAF(INDEXNEST) = NOT_LEAF(INDEXNEST) | 2; (1143)
      {
        int32_t numberRHS = (int32_t)(xOR (
            BYTE0 (mNOT_LEAF + 1 * COREHALFWORD (mINDEXNEST)), 2));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mNOT_LEAF + 1 * (COREHALFWORD (mINDEXNEST)), bitRHS);
        bitRHS->inUse = 0;
      }
  // LOCCTR(NEST) = VALUE; (1144)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mSET_LOCCTRxVALUE));
    putFIXED (mLOCCTR + 4 * (COREHALFWORD (mSET_LOCCTRxNEST)), numberRHS);
  }
  // CALL EMITC(CSECT, NEST); (1145)
  {
    putBITp (16, mEMITCxTYPE, getBIT (8, mCSECT));
    putBITp (16, mEMITCxINST, getBIT (16, mSET_LOCCTRxNEST));
    EMITC (0);
  }
  // CALL EMITW(NEGMAX | VALUE, 1); (1146)
  {
    putFIXED (mEMITWxDATA,
              xOR (getFIXED (mNEGMAX), getFIXED (mSET_LOCCTRxVALUE)));
    putBITp (1, mEMITWxMODIFIER, fixedToBit (32, (int32_t)(1)));
    EMITW (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
