/*
  File PUSH_INDIRECT.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
PUSH_INDIRECT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PUSH_INDIRECT");
  // PTR_TOP=PTR_TOP+I; (7291)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mPTR_TOP),
                                        COREHALFWORD (mPUSH_INDIRECTxI)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPTR_TOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF PTR_TOP>PTR_MAX THEN (7292)
  if (1 & (xGT (COREHALFWORD (mPTR_TOP), 75)))
    // CALL ERROR(CLASS_BS,2); (7293)
    {
      putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_BS));
      putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(2)));
      ERROR (0);
    }
  // ELSE (7294)
  else
    // IF PTR_TOP>MAX_PTR_TOP THEN (7295)
    if (1 & (xGT (COREHALFWORD (mPTR_TOP), getFIXED (mMAX_PTR_TOP))))
      // MAX_PTR_TOP=PTR_TOP; (7296)
      {
        descriptor_t *bitRHS = getBIT (16, mPTR_TOP);
        int32_t numberRHS;
        numberRHS = bitToFixed (bitRHS);
        putFIXED (mMAX_PTR_TOP, numberRHS);
        bitRHS->inUse = 0;
      }
  // VAL_P(PTR_TOP),EXT_P(PTR_TOP)=0; (7297)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVAL_P + 2 * (COREHALFWORD (mPTR_TOP)), bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEXT_P + 2 * (COREHALFWORD (mPTR_TOP)), bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR_TOP; (7298)
  {
    reentryGuard = 0;
    return COREHALFWORD (mPTR_TOP);
  }
}
