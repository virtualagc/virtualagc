/*
  File REDUCE_SUBSCRIPTxSTEPPER.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
REDUCE_SUBSCRIPTxSTEPPER (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "REDUCE_SUBSCRIPTxSTEPPER");
  // NEXT_SUB=NEXT_SUB+1; (8378)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mNEXT_SUB), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mNEXT_SUB, bitRHS);
    bitRHS->inUse = 0;
  }
  // PSEUDO_LENGTH(IND_LINK),IND_LINK=NEXT_SUB; (8379)
  {
    descriptor_t *bitRHS = getBIT (16, mNEXT_SUB);
    putBIT (16, mPSEUDO_LENGTH + 2 * (COREHALFWORD (mIND_LINK)), bitRHS);
    putBIT (16, mIND_LINK, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF INX(NEXT_SUB)~=1 THEN (8380)
  if (1 & (xNEQ (COREHALFWORD (mINX + 2 * COREHALFWORD (mNEXT_SUB)), 1)))
    // DO; (8381)
    {
    rs1:;
      // IF MODE= 8 THEN (8382)
      if (1 & (xEQ (COREHALFWORD (mREDUCE_SUBSCRIPTxMODE), 8)))
        // VAL_P(PTR(MP))=VAL_P(PTR(MP))| 8192; (8383)
        {
          int32_t numberRHS = (int32_t)(xOR (
              COREHALFWORD (mVAL_P
                            + 2 * COREHALFWORD (mPTR + 2 * getFIXED (mMP))),
              8192));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mVAL_P + 2 * (COREHALFWORD (mPTR + 2 * getFIXED (mMP))),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (8384)
      else
        // VAL_P(PTR(MP))=VAL_P(PTR(MP))| 16; (8385)
        {
          int32_t numberRHS = (int32_t)(xOR (
              COREHALFWORD (mVAL_P
                            + 2 * COREHALFWORD (mPTR + 2 * getFIXED (mMP))),
              16));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mVAL_P + 2 * (COREHALFWORD (mPTR + 2 * getFIXED (mMP))),
                  bitRHS);
          bitRHS->inUse = 0;
        }
    es1:;
    } // End of DO block
  // INX(NEXT_SUB)=INX(NEXT_SUB)|MODE; (8386)
  {
    int32_t numberRHS
        = (int32_t)(xOR (COREHALFWORD (mINX + 2 * COREHALFWORD (mNEXT_SUB)),
                         COREHALFWORD (mREDUCE_SUBSCRIPTxMODE)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mINX + 2 * (COREHALFWORD (mNEXT_SUB)), bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN INX(NEXT_SUB)& 3; (8387)
  {
    reentryGuard = 0;
    return xAND (COREHALFWORD (mINX + 2 * COREHALFWORD (mNEXT_SUB)), 3);
  }
}
