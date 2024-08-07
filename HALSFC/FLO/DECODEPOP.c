/*
  File DECODEPOP.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
DECODEPOP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DECODEPOP");
  // NUMOP = SHR(OPR(CTR),16) &  255; (1065)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 16), 255));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mNUMOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // CLASS = SHR(OPR(CTR),12) &  15; (1066)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 12), 15));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCLASS, bitRHS);
    bitRHS->inUse = 0;
  }
  // OPCODE = SHR(OPR(CTR),4) &  4095; (1067)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 4), 4095));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOPCODE, bitRHS);
    bitRHS->inUse = 0;
  }
  // SUBCODE = SHR(OPR(CTR),9) &  7; (1068)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 9), 7));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mSUBCODE, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
