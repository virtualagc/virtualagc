/*
  File GENERATExVECMAT_ASN.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExVECMAT_ASN (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExVECMAT_ASN");
  // CTR = SKIP_NOP(CTR); (7829)
  {
    descriptor_t *bitRHS = (putBITp (16, mGENERATExSKIP_NOPxPTR,
                                     getBIT (16, mGENERATExVECMAT_ASNxCTR)),
                            GENERATExSKIP_NOP (0));
    putBIT (16, mGENERATExVECMAT_ASNxCTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (OPR(CTR) &  65529) = XVDLP THEN (7830)
  if (1
      & (xEQ (xAND (getFIXED (getFIXED (mFOR_ATOMS)
                              + 4 * (COREHALFWORD (mGENERATExVECMAT_ASNxCTR))
                              + 0 + 4 * (0)),
                    65529),
              COREHALFWORD (mXVDLP))))
    // DO; (7831)
    {
    rs1:;
      // CTR = SKIP_NOP(CTR); (7832)
      {
        descriptor_t *bitRHS
            = (putBITp (16, mGENERATExSKIP_NOPxPTR,
                        getBIT (16, mGENERATExVECMAT_ASNxCTR)),
               GENERATExSKIP_NOP (0));
        putBIT (16, mGENERATExVECMAT_ASNxCTR, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF (OPR(SKIP_NOP(CTR)) &  65529) ~= XVDLE THEN (7833)
      if (1
          & (xNEQ (
              xAND (getFIXED (
                        getFIXED (mFOR_ATOMS)
                        + 4
                              * (bitToFixed (
                                  (putBITp (
                                       16, mGENERATExSKIP_NOPxPTR,
                                       getBIT (16, mGENERATExVECMAT_ASNxCTR)),
                                   GENERATExSKIP_NOP (0))))
                        + 0 + 4 * (0)),
                    65529),
              COREHALFWORD (mXVDLE))))
        // RETURN -1; (7834)
        {
          reentryGuard = 0;
          return fixedToBit (32, (int32_t)(-1));
        }
    es1:;
    } // End of DO block
  // ELSE (7835)
  else
    // IF (OPR(CTR) &  65529) = XVDLE & ~VDLP_IN_EFFECT THEN (7836)
    if (1
        & (xAND (xEQ (xAND (getFIXED (
                                getFIXED (mFOR_ATOMS)
                                + 4 * (COREHALFWORD (mGENERATExVECMAT_ASNxCTR))
                                + 0 + 4 * (0)),
                            65529),
                      COREHALFWORD (mXVDLE)),
                 xNOT (BYTE0 (mVDLP_IN_EFFECT)))))
      // CTR = SKIP_NOP(CTR); (7837)
      {
        descriptor_t *bitRHS
            = (putBITp (16, mGENERATExSKIP_NOPxPTR,
                        getBIT (16, mGENERATExVECMAT_ASNxCTR)),
               GENERATExSKIP_NOP (0));
        putBIT (16, mGENERATExVECMAT_ASNxCTR, bitRHS);
        bitRHS->inUse = 0;
      }
  // IF POPNUM(CTR) = 2 THEN (7838)
  if (1
      & (xEQ (
          (putBITp (16, mPOPNUMxCTR, getBIT (16, mGENERATExVECMAT_ASNxCTR)),
           POPNUM (0)),
          2)))
    // DO; (7839)
    {
    rs2:;
      // OPCODE = POPCODE(CTR); (7840)
      {
        int32_t numberRHS = (int32_t)((
            putBITp (16, mPOPCODExCTR, getBIT (16, mGENERATExVECMAT_ASNxCTR)),
            POPCODE (0)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGENERATExVECMAT_ASNxOPCODE, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF OPCODE = MATASN | OPCODE = VECASN THEN (7841)
      if (1
          & (xOR (xEQ (COREHALFWORD (mGENERATExVECMAT_ASNxOPCODE),
                       COREHALFWORD (mGENERATExVECMAT_ASNxMATASN)),
                  xEQ (COREHALFWORD (mGENERATExVECMAT_ASNxOPCODE),
                       COREHALFWORD (mGENERATExVECMAT_ASNxVECASN)))))
        // RETURN CTR; (7842)
        {
          reentryGuard = 0;
          return getBIT (16, mGENERATExVECMAT_ASNxCTR);
        }
    es2:;
    } // End of DO block
  // RETURN -1; (7843)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(-1));
  }
}
