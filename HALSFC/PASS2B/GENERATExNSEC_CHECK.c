/*
  File GENERATExNSEC_CHECK.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExNSEC_CHECK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExNSEC_CHECK");
  // LEFT_NSEC=LEFTOP=0|FORM(LEFTOP)=WORK; (8898)
  {
    int32_t numberRHS = (int32_t)(xOR (
        xEQ (COREHALFWORD (mLEFTOP), 0),
        xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                           + 73 * (COREHALFWORD (mLEFTOP)) + 32 + 2 * (0)),
             BYTE0 (mWORK))));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExLEFT_NSEC, bitRHS);
    bitRHS->inUse = 0;
  }
  // RIGHT_NSEC=RIGHTOP=0|FORM(RIGHTOP)=WORK; (8899)
  {
    int32_t numberRHS = (int32_t)(xOR (
        xEQ (COREHALFWORD (mRIGHTOP), 0),
        xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                           + 73 * (COREHALFWORD (mRIGHTOP)) + 32 + 2 * (0)),
             BYTE0 (mWORK))));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExRIGHT_NSEC, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
