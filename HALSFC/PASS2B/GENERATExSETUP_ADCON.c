/*
  File GENERATExSETUP_ADCON.c generated by XCOM-I, 2024-08-09 12:41:32.
*/

#include "runtimeC.h"

int32_t
GENERATExSETUP_ADCON (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSETUP_ADCON");
  // IF ~(FORM(OP) = SYM | FORM(OP) = LBL) THEN (3832)
  if (1
      & (xNOT (xOR (
          xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSETUP_ADCONxOP))
                             + 32 + 2 * (0)),
               BYTE0 (mSYM)),
          xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSETUP_ADCONxOP))
                             + 32 + 2 * (0)),
               BYTE0 (mLBL))))))
    // RETURN; (3833)
    {
      reentryGuard = 0;
      return 0;
    }
  // SY = LOC2(OP); (3834)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExSETUP_ADCONxOP)) + 42
                          + 2 * (0));
    putBIT (16, mGENERATExSETUP_ADCONxSY, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SYT_FLAGS(SY) & NAME_FLAG) ~= 0 THEN (3835)
  if (1
      & (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                               + 34 * (COREHALFWORD (mGENERATExSETUP_ADCONxSY))
                               + 8 + 4 * (0)),
                     getFIXED (mNAME_FLAG)),
               0)))
    // DO; (3836)
    {
    rs1:;
      // FORM(OP) = SYM; (3837)
      {
        descriptor_t *bitRHS = getBIT (8, mSYM);
        putBIT (16,
                getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExSETUP_ADCONxOP)) + 32
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN; (3838)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
  // FORM(OP) = EXTSYM; (3839)
  {
    descriptor_t *bitRHS = getBIT (8, mEXTSYM);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExSETUP_ADCONxOP)) + 32
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // LOC(OP) = SYT_SCOPE(SY); (3840)
  {
    descriptor_t *bitRHS = getBIT (
        8, getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mGENERATExSETUP_ADCONxSY))
               + 29 + 1 * (0));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExSETUP_ADCONxOP)) + 40
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}