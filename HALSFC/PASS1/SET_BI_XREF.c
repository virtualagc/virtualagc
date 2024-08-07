/*
  File SET_BI_XREF.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
SET_BI_XREF (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SET_BI_XREF");
  // IF SUBSCRIPT_LEVEL>0 THEN (4821)
  if (1 & (xGT (COREHALFWORD (mSUBSCRIPT_LEVEL), 0)))
    // TAG=XREF_SUBSCR; (4822)
    {
      int32_t numberRHS = (int32_t)(getFIXED (mXREF_SUBSCR));
      putFIXED (mSET_BI_XREFxTAG, numberRHS);
    }
  // ELSE (4823)
  else
    // IF (SHR(ATOMS(LAST_POP#),24) = 1) & (LOC = SBIT_NDX)  THEN (4824)
    if (1
        & (xAND (
            xEQ (SHR (getFIXED (getFIXED (mFOR_ATOMS)
                                + 4 * (getFIXED (mLAST_POPp)) + 0 + 4 * (0)),
                      24),
                 1),
            xEQ (COREHALFWORD (mSET_BI_XREFxLOC), 58))))
      // TAG=XREF_ASSIGN; (4825)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mXREF_ASSIGN));
        putFIXED (mSET_BI_XREFxTAG, numberRHS);
      }
    // ELSE (4826)
    else
      // TAG=XREF_REF; (4827)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mXREF_REF));
        putFIXED (mSET_BI_XREFxTAG, numberRHS);
      }
  // IF NEW_XREF THEN (4828)
  if (1
      & (xNEQ (
          xAND (getFIXED (
                    getFIXED (mCROSS_REF)
                    + 4
                          * (COREHALFWORD (
                              mBI_XREF + 2 * COREHALFWORD (mSET_BI_XREFxLOC)))
                    + 0 + 4 * (0)),
                getFIXED (mXREF_MASK)),
          getFIXED (mCOMM + 4 * 3))))
    // BI_XREF#(LOC) = BI_XREF#(LOC)+1; (4829)
    {
      int32_t numberRHS = (int32_t)(xadd (
          COREHALFWORD (mBI_XREFp + 2 * COREHALFWORD (mSET_BI_XREFxLOC)), 1));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mBI_XREFp + 2 * (COREHALFWORD (mSET_BI_XREFxLOC)), bitRHS);
      bitRHS->inUse = 0;
    }
  // BI_XREF(LOC)=ENTER_XREF(BI_XREF(LOC),TAG); (4830)
  {
    descriptor_t *bitRHS
        = (putFIXED (
               mENTER_XREFxROOT,
               COREHALFWORD (mBI_XREF + 2 * COREHALFWORD (mSET_BI_XREFxLOC))),
           putFIXED (mENTER_XREFxFLAG, getFIXED (mSET_BI_XREFxTAG)),
           ENTER_XREF (0));
    putBIT (16, mBI_XREF + 2 * (COREHALFWORD (mSET_BI_XREFxLOC)), bitRHS);
    bitRHS->inUse = 0;
  }
  // BI_XREF=TRUE; (4831)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mBI_XREF, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
