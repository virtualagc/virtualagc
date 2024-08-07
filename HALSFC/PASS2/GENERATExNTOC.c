/*
  File GENERATExNTOC.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExNTOC (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExNTOC");
  // D_RTL_SETUP = TRUE; (7602)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mD_RTL_SETUP, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF FORM(OP) = LIT & TYPE(OP) = CHAR THEN (7603)
  if (1
      & (xAND (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                  + 73 * (COREHALFWORD (mGENERATExNTOCxOP))
                                  + 32 + 2 * (0)),
                    BYTE0 (mLIT)),
               xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                  + 73 * (COREHALFWORD (mGENERATExNTOCxOP))
                                  + 50 + 2 * (0)),
                    BYTE0 (mCHAR)))))
    // PTR = OP; (7604)
    {
      descriptor_t *bitRHS = getBIT (16, mGENERATExNTOCxOP);
      putBIT (16, mGENERATExNTOCxPTR, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (7605)
  else
    // DO; (7606)
    {
    rs1:;
      // RADIX = RADIX + CHARTYPE(TYPE(OP)); (7607)
      {
        int32_t numberRHS = (int32_t)(xadd (
            COREHALFWORD (mGENERATExNTOCxRADIX),
            BYTE0 (
                mCHARTYPE
                + 1
                      * COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mGENERATExNTOCxOP))
                                      + 50 + 2 * (0)))));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGENERATExNTOCxRADIX, bitRHS);
        bitRHS->inUse = 0;
      }
      // LEN = CVTLEN(RADIX); (7608)
      {
        descriptor_t *bitRHS
            = getBIT (16, mGENERATExNTOCxCVTLEN
                              + 2 * COREHALFWORD (mGENERATExNTOCxRADIX));
        putBIT (16, mGENERATExNTOCxLEN, bitRHS);
        bitRHS->inUse = 0;
      }
      // PTR = GETFREESPACE(CHAR, LEN+2); (7609)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (mGENERATExGETFREESPACExOPTYPE, BYTE0 (mCHAR)),
            putFIXED (mGENERATExGETFREESPACExTEMPSPACE,
                      xadd (COREHALFWORD (mGENERATExNTOCxLEN), 2)),
            GENERATExGETFREESPACE (0)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGENERATExNTOCxPTR, bitRHS);
        bitRHS->inUse = 0;
      }
      // SIZE(PTR) = LEN; (7610)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExNTOCxLEN);
        putBIT (16,
                getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExNTOCxPTR)) + 48 + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // TARGET_REGISTER = CVTREG(RADIX); (7611)
      {
        descriptor_t *bitRHS
            = getBIT (16, mGENERATExNTOCxCVTREG
                              + 2 * COREHALFWORD (mGENERATExNTOCxRADIX));
        putBIT (16, mTARGET_REGISTER, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF RADIX > 3 THEN (7612)
      if (1 & (xGT (COREHALFWORD (mGENERATExNTOCxRADIX), 3)))
        // CALL FORCE_ACCUMULATOR(OP, FULLBIT); (7613)
        {
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                   getBIT (16, mGENERATExNTOCxOP));
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
                   getBIT (8, mFULLBIT));
          GENERATExFORCE_ACCUMULATOR (0);
        }
      // ELSE (7614)
      else
        // CALL FORCE_ACCUMULATOR(OP); (7615)
        {
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                   getBIT (16, mGENERATExNTOCxOP));
          GENERATExFORCE_ACCUMULATOR (0);
        }
      // IF RFLAG THEN (7616)
      if (1 & (bitToFixed (getBIT (1, mGENERATExNTOCxRFLAG))))
        // TARGET_REGISTER = -1; (7617)
        {
          int32_t numberRHS = (int32_t)(-1);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mTARGET_REGISTER, bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (7618)
      else
        // CALL OFF_TARGET(OP); (7619)
        {
          putBITp (16, mGENERATExOFF_TARGETxOP,
                   getBIT (16, mGENERATExNTOCxOP));
          GENERATExOFF_TARGET (0);
        }
      // CALL FORCE_ADDRESS(PTRARG1, PTR); (7620)
      {
        putBITp (16, mGENERATExFORCE_ADDRESSxTR, getBIT (8, mPTRARG1));
        putBITp (16, mGENERATExFORCE_ADDRESSxOP,
                 getBIT (16, mGENERATExNTOCxPTR));
        GENERATExFORCE_ADDRESS (0);
      }
      // IF PACKTYPE(TYPE(OP)) = BITS THEN (7621)
      if (1
          & (xEQ (BYTE0 (mPACKTYPE
                         + 1
                               * COREHALFWORD (
                                   getFIXED (mIND_STACK)
                                   + 73 * (COREHALFWORD (mGENERATExNTOCxOP))
                                   + 50 + 2 * (0))),
                  BYTE0 (mBITS))))
        // CALL FORCE_NUM(FIXARG2, SIZE(OP)); (7622)
        {
          putBITp (16, mGENERATExFORCE_NUMxR, getBIT (8, mFIXARG2));
          putFIXED (mGENERATExFORCE_NUMxNUM,
                    COREHALFWORD (getFIXED (mIND_STACK)
                                  + 73 * (COREHALFWORD (mGENERATExNTOCxOP))
                                  + 48 + 2 * (0)));
          GENERATExFORCE_NUM (0);
        }
      // CALL GENLIBCALL(TYPES(RADIX) || 'TOC'); (7623)
      {
        putCHARACTERp (
            mGENERATExGENLIBCALLxNAME,
            xsCAT (getCHARACTER (mGENERATExTYPES
                                 + 4 * COREHALFWORD (mGENERATExNTOCxRADIX)),
                   cToDescriptor (NULL, "TOC")));
        GENERATExGENLIBCALL (0);
      }
      // IF ~FLAG THEN (7624)
      if (1 & (xNOT (BYTE0 (mGENERATExNTOCxFLAG))))
        // CALL RETURN_STACK_ENTRY(OP); (7625)
        {
          putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
                   getBIT (16, mGENERATExNTOCxOP));
          GENERATExRETURN_STACK_ENTRY (0);
        }
      // LASTRESULT = PTR; (7626)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExNTOCxPTR);
        putBIT (16, mLASTRESULT, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // RADIX, FLAG, RFLAG = 0; (7627)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExNTOCxRADIX, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExNTOCxFLAG, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExNTOCxRFLAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR; (7628)
  {
    reentryGuard = 0;
    return getBIT (16, mGENERATExNTOCxPTR);
  }
}
