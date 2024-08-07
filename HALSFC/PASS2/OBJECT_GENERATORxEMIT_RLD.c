/*
  File OBJECT_GENERATORxEMIT_RLD.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

descriptor_t *
OBJECT_GENERATORxEMIT_RLD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "OBJECT_GENERATORxEMIT_RLD");
  // RLD# = RLD# + 1; (15762)
  {
    int32_t numberRHS
        = (int32_t)(xadd (COREHALFWORD (mOBJECT_GENERATORxRLDp), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOBJECT_GENERATORxRLDp, bitRHS);
    bitRHS->inUse = 0;
  }
  // TMP = GET_RLD(RLD#, 1); (15763)
  {
    int32_t numberRHS
        = (int32_t)((putFIXED (mOBJECT_GENERATORxGET_RLDxPTR,
                               COREHALFWORD (mOBJECT_GENERATORxRLDp)),
                     putBITp (8, mOBJECT_GENERATORxGET_RLDxFLAG,
                              fixedToBit (32, (int32_t)(1))),
                     OBJECT_GENERATORxGET_RLD (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOBJECT_GENERATORxEMIT_RLDxTMP, bitRHS);
    bitRHS->inUse = 0;
  }
  // RLD_ADDR(TMP) = ADR; (15764)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mOBJECT_GENERATORxEMIT_RLDxADR));
    putFIXED (getFIXED (mLIT_PG) + 1560 * (0) + 520
                  + 4 * (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxTMP)),
              numberRHS);
  }
  // IF REL = FSIMBASE THEN (15765)
  if (1
      & (xEQ (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxREL),
              COREHALFWORD (mFSIMBASE))))
    // DO; (15766)
    {
    rs1:;
      // REL = DATABASE; (15767)
      {
        descriptor_t *bitRHS = getBIT (16, mDATABASE);
        putBIT (16, mOBJECT_GENERATORxEMIT_RLDxREL, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // RLD_REF(TMP) = SHL(REL &  61440,16) | REL & FTHREE; (15768)
  {
    int32_t numberRHS = (int32_t)(xOR (
        SHL (xAND (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxREL), 61440), 16),
        xAND (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxREL),
              getFIXED (mOBJECT_GENERATORxFTHREE))));
    putFIXED (getFIXED (mLIT_PG) + 1560 * (0) + 0
                  + 4 * (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxTMP)),
              numberRHS);
  }
  // RLD_LINK(TMP) = 0; (15769)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (getFIXED (mLIT_PG) + 1560 * (0) + 1040
                  + 4 * (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxTMP)),
              numberRHS);
  }
  // IF RLD_POS_HEAD(CURRENT_ESDID) = 0 THEN (15770)
  if (1 & (xEQ (COREHALFWORD (mLASTBASE + 2 * getFIXED (mCURRENT_ESDID)), 0)))
    // RLD_POS_HEAD(CURRENT_ESDID) = RLD#; (15771)
    {
      descriptor_t *bitRHS = getBIT (16, mOBJECT_GENERATORxRLDp);
      putBIT (16, mLASTBASE + 2 * (getFIXED (mCURRENT_ESDID)), bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (15772)
  else
    // RLD_LINK(GET_RLD(RLD_POS_LINK(CURRENT_ESDID),1)) = RLD#; (15773)
    {
      descriptor_t *bitRHS = getBIT (16, mOBJECT_GENERATORxRLDp);
      putFIXED (getFIXED (mLIT_PG) + 1560 * (0) + 1040
                    + 4
                          * ((putFIXED (mOBJECT_GENERATORxGET_RLDxPTR,
                                        COREHALFWORD (
                                            mINDEXNEST
                                            + 2 * getFIXED (mCURRENT_ESDID))),
                              putBITp (8, mOBJECT_GENERATORxGET_RLDxFLAG,
                                       fixedToBit (32, (int32_t)(1))),
                              OBJECT_GENERATORxGET_RLD (0))),
                bitToFixed (bitRHS));
      bitRHS->inUse = 0;
    }
  // RLD_POS_LINK(CURRENT_ESDID) = RLD#; (15774)
  {
    descriptor_t *bitRHS = getBIT (16, mOBJECT_GENERATORxRLDp);
    putBIT (16, mINDEXNEST + 2 * (getFIXED (mCURRENT_ESDID)), bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN REL & FTHREE; (15775)
  {
    reentryGuard = 0;
    return fixedToBit (
        32, (int32_t)(xAND (COREHALFWORD (mOBJECT_GENERATORxEMIT_RLDxREL),
                            getFIXED (mOBJECT_GENERATORxFTHREE))));
  }
}
