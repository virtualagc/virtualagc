/*
  File COPINESS.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

descriptor_t *
COPINESS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "COPINESS");
  // L=EXT_P(PTR(L)); (7792)
  {
    descriptor_t *bitRHS = getBIT (
        16, mEXT_P + 2 * COREHALFWORD (mPTR + 2 * COREHALFWORD (mCOPINESSxL)));
    putBIT (16, mCOPINESSxL, bitRHS);
    bitRHS->inUse = 0;
  }
  // T=EXT_P(PTR(R)); (7793)
  {
    descriptor_t *bitRHS = getBIT (
        16, mEXT_P + 2 * COREHALFWORD (mPTR + 2 * COREHALFWORD (mCOPINESSxR)));
    putBIT (16, mCOPINESSxT, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF T=0 THEN (7794)
  if (1 & (xEQ (COREHALFWORD (mCOPINESSxT), 0)))
    // DO; (7795)
    {
    rs1:;
      // IF L=0 THEN (7796)
      if (1 & (xEQ (COREHALFWORD (mCOPINESSxL), 0)))
        // RETURN 0; (7797)
        {
          reentryGuard = 0;
          return fixedToBit (32, (int32_t)(0));
        }
      // ELSE (7798)
      else
        // DO; (7799)
        {
        rs1s1:;
          // EXT_P(PTR(R))=L; (7800)
          {
            descriptor_t *bitRHS = getBIT (16, mCOPINESSxL);
            putBIT (16,
                    mEXT_P
                        + 2
                              * (COREHALFWORD (
                                  mPTR + 2 * COREHALFWORD (mCOPINESSxR))),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // RETURN 2; (7801)
          {
            reentryGuard = 0;
            return fixedToBit (32, (int32_t)(2));
          }
        es1s1:;
        } // End of DO block
    es1:;
    } // End of DO block
  // IF L=0 THEN (7802)
  if (1 & (xEQ (COREHALFWORD (mCOPINESSxL), 0)))
    // RETURN 4; (7803)
    {
      reentryGuard = 0;
      return fixedToBit (32, (int32_t)(4));
    }
  // IF L~=T THEN (7804)
  if (1 & (xNEQ (COREHALFWORD (mCOPINESSxL), COREHALFWORD (mCOPINESSxT))))
    // DO; (7805)
    {
    rs2:;
      // EXT_P(PTR(R))=L; (7806)
      {
        descriptor_t *bitRHS = getBIT (16, mCOPINESSxL);
        putBIT (
            16,
            mEXT_P
                + 2 * (COREHALFWORD (mPTR + 2 * COREHALFWORD (mCOPINESSxR))),
            bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN 3; (7807)
      {
        reentryGuard = 0;
        return fixedToBit (32, (int32_t)(3));
      }
    es2:;
    } // End of DO block
  // RETURN 0; (7808)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
