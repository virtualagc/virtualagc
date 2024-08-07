/*
  File ELIMINATE_DIVIDES.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
ELIMINATE_DIVIDES (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ELIMINATE_DIVIDES");
  // MPARITY1# = FNPARITY1#; (4632)
  {
    descriptor_t *bitRHS = getBIT (16, mFNPARITY1p);
    putBIT (16, mMPARITY1p, bitRHS);
    bitRHS->inUse = 0;
  }
  // MPARITY0# = N_INX - EON_PTR - 1 + CSE_FOUND_INX - FNPARITY1#; (4633)
  {
    int32_t numberRHS = (int32_t)(xsubtract (
        xadd (
            xsubtract (
                xsubtract (COREHALFWORD (mN_INX), COREHALFWORD (mEON_PTR)), 1),
            COREHALFWORD (mCSE_FOUND_INX)),
        COREHALFWORD (mFNPARITY1p)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mMPARITY0p, bitRHS);
    bitRHS->inUse = 0;
  }
  // FORWARD,REVERSE = FALSE; (4634)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mFORWARD, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mREVERSE, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL COLLECT_MATCHES(NODE(EON_PTR - 1) &  65535,0,0,1); (4635)
  {
    putBITp (
        16, mCOLLECT_MATCHESxH_PTR,
        fixedToBit (
            32,
            (int32_t)(xAND (
                getFIXED (mNODE + 4 * xsubtract (COREHALFWORD (mEON_PTR), 1)),
                65535))));
    putBITp (16, mCOLLECT_MATCHESxNPARITY0p, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mCOLLECT_MATCHESxNPARITY1p, fixedToBit (32, (int32_t)(0)));
    putBITp (8, mCOLLECT_MATCHESxELIMINATE_DIVIDES,
             fixedToBit (32, (int32_t)(1)));
    COLLECT_MATCHES (0);
  }
  // IF WATCH THEN (4636)
  if (1 & (bitToFixed (getBIT (8, mWATCH))))
    // CALL PRINT_SENTENCE(HALMAT_NODE_START); (4637)
    {
      putBITp (16, mPRINT_SENTENCExPTR, getBIT (16, mHALMAT_NODE_START));
      PRINT_SENTENCE (0);
    }
  // DIVISION_ELIMINATIONS = DIVISION_ELIMINATIONS + 1; (4638)
  {
    int32_t numberRHS
        = (int32_t)(xadd (COREHALFWORD (mDIVISION_ELIMINATIONS), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mDIVISION_ELIMINATIONS, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF STATISTICS THEN (4639)
  if (1 & (bitToFixed (getBIT (16, mSTATISTICS))))
    // OUTPUT = 'DIVISION ELIMINATION FOUND IN HAL/S STATEMENT '||STT#; (4640)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (
                       NULL, "DIVISION ELIMINATION FOUND IN HAL/S STATEMENT "),
                   bitToCharacter (getBIT (16, mSTTp)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  {
    reentryGuard = 0;
    return 0;
  }
}
