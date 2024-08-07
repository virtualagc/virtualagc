/*
  File OPTIMISExOPDECODE.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
OPTIMISExOPDECODE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "OPTIMISExOPDECODE");
  // OPRTR = POPCODE(CTR); (2659)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mPOPCODExCTR, getBIT (16, mOPTIMISExOPDECODExCTR)),
        POPCODE (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOPTIMISExOPRTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // OPNUM = POPNUM(CTR); (2660)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mPOPNUMxCTR, getBIT (16, mOPTIMISExOPDECODExCTR)),
        POPNUM (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOPTIMISExOPNUM, bitRHS);
    bitRHS->inUse = 0;
  }
  // OPTAG = POPTAG(CTR); (2661)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mPOPTAGxCTR, getBIT (16, mOPTIMISExOPDECODExCTR)),
        POPTAG (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOPTIMISExOPTAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // OPCOPT = SHR(OPR(CTR), 1) &  7; (2662)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (getFIXED (mFOR_ATOMS)
                       + 4 * (COREHALFWORD (mOPTIMISExOPDECODExCTR)) + 0
                       + 4 * (0)),
             1),
        7));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOPTIMISExOPCOPT, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
