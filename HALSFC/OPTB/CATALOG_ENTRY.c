/*
  File CATALOG_ENTRY.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
CATALOG_ENTRY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CATALOG_ENTRY");
  // NODE_PTR,CSE_TAB(TEMP) = GET_FREE_SPACE(NODE_ENTRY_SIZE); (3194)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mGET_FREE_SPACExSPACE, fixedToBit (32, (int32_t)(3))),
           GET_FREE_SPACE (0));
    putBIT (16, mCATALOG_ENTRYxNODE_PTR, bitRHS);
    putBIT (16, mCSE_TAB + 2 * (COREHALFWORD (mCATALOG_ENTRYxTEMP)), bitRHS);
    bitRHS->inUse = 0;
  }
  // CSE_TAB(TEMP + 1) = OPTYPE; (3195)
  {
    descriptor_t *bitRHS = getBIT (16, mOPTYPE);
    putBIT (16, mCSE_TAB + 2 * (xadd (COREHALFWORD (mCATALOG_ENTRYxTEMP), 1)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CSE_TAB(TEMP + 2),CSE_TAB(NODE_PTR + 1) = 0; (3196)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCSE_TAB + 2 * (xadd (COREHALFWORD (mCATALOG_ENTRYxTEMP), 2)),
            bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16,
            mCSE_TAB + 2 * (xadd (COREHALFWORD (mCATALOG_ENTRYxNODE_PTR), 1)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CSE_TAB(NODE_PTR) = NODE_BEGINNING; (3197)
  {
    descriptor_t *bitRHS = getBIT (16, mCATALOG_ENTRYxNODE_BEGINNING);
    putBIT (16, mCSE_TAB + 2 * (COREHALFWORD (mCATALOG_ENTRYxNODE_PTR)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // IF PREVIOUS_LEVEL THEN (3198)
  if (1 & (bitToFixed (getBIT (8, mCATALOG_ENTRYxPREVIOUS_LEVEL))))
    // CSE_TAB(NODE_PTR + 2) = NODE2(GET_EON(NODE_BEGINNING,1)); (3199)
    {
      descriptor_t *bitRHS = getBIT (
          16,
          mNODE2
              + 2
                    * (putBITp (16, mGET_EONxPTR,
                                getBIT (16, mCATALOG_ENTRYxNODE_BEGINNING)),
                       putBITp (8, mGET_EONxGET_EOL,
                                fixedToBit (32, (int32_t)(1))),
                       GET_EON (0)));
      putBIT (16,
              mCSE_TAB
                  + 2 * (xadd (COREHALFWORD (mCATALOG_ENTRYxNODE_PTR), 2)),
              bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (3200)
  else
    // CSE_TAB(NODE_PTR + 2) = SHL(LEVEL,11) | BLOCK#; (3201)
    {
      int32_t numberRHS = (int32_t)(xOR (SHL (COREHALFWORD (mLEVEL), 11),
                                         COREHALFWORD (mBLOCKp)));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16,
              mCSE_TAB
                  + 2 * (xadd (COREHALFWORD (mCATALOG_ENTRYxNODE_PTR), 2)),
              bitRHS);
      bitRHS->inUse = 0;
    }
  // PREVIOUS_LEVEL = FALSE; (3202)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mCATALOG_ENTRYxPREVIOUS_LEVEL, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
