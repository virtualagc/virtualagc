/*
  File GENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATION.c generated by XCOM-I,
  2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATION (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard,
                               "GENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATION");
  // IF NUMOP = 1 THEN (12665)
  if (1 & (xEQ (COREHALFWORD (mNUMOP), 1)))
    // DO; (12666)
    {
    rs1:;
      // CALL DECODEPIP(1); (12667)
      {
        putBITp (16, mGENERATExDECODEPIPxOP, fixedToBit (32, (int32_t)(1)));
        GENERATExDECODEPIP (0);
      }
      // IF OP1 = 3 THEN (12668)
      if (1 & (xEQ (COREHALFWORD (mOP1), 3)))
        // DO; (12669)
        {
        rs1s1:;
          // PTR = SKIP_NOP(CTR); (12670)
          {
            descriptor_t *bitRHS
                = (putBITp (16, mGENERATExSKIP_NOPxPTR, getBIT (16, mCTR)),
                   GENERATExSKIP_NOP (0));
            putBIT (16, mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR,
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // IF (OPR(SKIP_NOP(PTR)) &  65529) = XVDLE THEN (12671)
          if (1
              & (xEQ (
                  xAND (
                      getFIXED (
                          getFIXED (mFOR_ATOMS)
                          + 4
                                * (bitToFixed ((
                                    putBITp (
                                        16, mGENERATExSKIP_NOPxPTR,
                                        getBIT (
                                            16,
                                            mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR)),
                                    GENERATExSKIP_NOP (0))))
                          + 0 + 4 * (0)),
                      65529),
                  COREHALFWORD (mXVDLE))))
            // RETURN TRUE; (12672)
            {
              reentryGuard = 0;
              return 1;
            }
          // ELSE (12673)
          else
            // IF (SHR(OPR(PTR),1)& 4) = 0 THEN (12674)
            if (1
                & (xEQ (
                    xAND (
                        SHR (
                            getFIXED (
                                getFIXED (mFOR_ATOMS)
                                + 4
                                      * (COREHALFWORD (
                                          mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR))
                                + 0 + 4 * (0)),
                            1),
                        4),
                    0)))
              // DO; (12675)
              {
              rs1s1s1:;
                // PTR = VECMAT_ASN(PTR); (12676)
                {
                  descriptor_t *bitRHS
                      = (putBITp (
                             16, mGENERATExVECMAT_ASNxCTR,
                             getBIT (
                                 16,
                                 mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR)),
                         GENERATExVECMAT_ASN (0));
                  putBIT (16,
                          mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR,
                          bitRHS);
                  bitRHS->inUse = 0;
                }
                // IF PTR > 0 THEN (12677)
                if (1
                    & (xGT (
                        COREHALFWORD (
                            mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR),
                        0)))
                  // IF (OPR(SKIP_NOP(PTR)) &  65529) = XVDLE THEN (12678)
                  if (1
                      & (xEQ (
                          xAND (
                              getFIXED (
                                  getFIXED (mFOR_ATOMS)
                                  + 4
                                        * (bitToFixed ((
                                            putBITp (
                                                16, mGENERATExSKIP_NOPxPTR,
                                                getBIT (
                                                    16,
                                                    mGENERATExGEN_CLASS0xSINGLE_3VECTOR_OPERATIONxPTR)),
                                            GENERATExSKIP_NOP (0))))
                                  + 0 + 4 * (0)),
                              65529),
                          COREHALFWORD (mXVDLE))))
                    // RETURN TRUE; (12679)
                    {
                      reentryGuard = 0;
                      return 1;
                    }
              es1s1s1:;
              } // End of DO block
        es1s1:;
        } // End of DO block
    es1:;
    } // End of DO block
  // RETURN FALSE; (12680)
  {
    reentryGuard = 0;
    return 0;
  }
}
