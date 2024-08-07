/*
  File GENERATExGEN_CLASS0xMERGE_ENVIRONMENT.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xMERGE_ENVIRONMENT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xMERGE_ENVIRONMENT");
  // IF ENV_LBL(ENV_PTR) = LBL THEN (12447)
  if (1
      & (xEQ (COREHALFWORD (mENV_LBL + 2 * COREHALFWORD (mENV_PTR)),
              COREHALFWORD (mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxLBL))))
    // DO I = 0 TO REG_NUM; (12448)
    {
      int32_t from120, to120, by120;
      from120 = 0;
      to120 = 15;
      by120 = 1;
      for (putBIT (16, mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI,
                   fixedToBit (16, from120));
           bitToFixed (getBIT (16, mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI))
           <= to120;
           putBIT (16, mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI,
                   fixedToBit (
                       16, bitToFixed (getBIT (
                               16, mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI))
                               + by120)))
        {
          // IF ~SAME_REG_INFO(I, ENV_BASE(ENV_PTR) + I) THEN (12449)
          if (1
              & (xNOT (bitToFixed ((
                  putBITp (
                      16, mGENERATExSAME_REG_INFOxRF,
                      getBIT (16, mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI)),
                  putBITp (
                      16, mGENERATExSAME_REG_INFOxRT,
                      fixedToBit (
                          32,
                          (int32_t)(xadd (
                              COREHALFWORD (mENV_BASE
                                            + 2 * COREHALFWORD (mENV_PTR)),
                              COREHALFWORD (
                                  mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI))))),
                  GENERATExSAME_REG_INFO (0))))))
            // USAGE(I) = 0; (12450)
            {
              int32_t numberRHS = (int32_t)(0);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16,
                      mUSAGE
                          + 2
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS0xMERGE_ENVIRONMENTxI)),
                      bitRHS);
              bitRHS->inUse = 0;
            }
        }
    } // End of DO for-loop block
  // ELSE (12451)
  else
    // CALL CLEAR_REGS; (12452)
    CLEAR_REGS (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
