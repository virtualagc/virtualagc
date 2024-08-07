/*
  File GENERATExVERIFY_INX_USAGE.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExVERIFY_INX_USAGE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExVERIFY_INX_USAGE");
  // IF USAGE(INX(OP)) < 4 THEN (4220)
  if (1
      & (xLT (
          COREHALFWORD (
              mUSAGE
              + 2
                    * COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExVERIFY_INX_USAGExOP))
                        + 34 + 2 * (0))),
          4)))
    // CALL UNRECOGNIZABLE(INX(OP)); (4221)
    {
      putBITp (
          16, mGENERATExUNRECOGNIZABLExR,
          getBIT (16, getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExVERIFY_INX_USAGExOP))
                          + 34 + 2 * (0)));
      GENERATExUNRECOGNIZABLE (0);
    }
  // ELSE (4222)
  else
    // DO; (4223)
    {
    rs1:;
      // R = FINDAC(INDEX_REG); (4224)
      {
        descriptor_t *bitRHS = (putBITp (16, mGENERATExFINDACxRCLASS,
                                         fixedToBit (32, (int32_t)(4))),
                                GENERATExFINDAC (0));
        putBIT (16, mGENERATExVERIFY_INX_USAGExR, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL EMITRR(LR, R, INX(OP)); (4225)
      {
        putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mLR));
        putBITp (16, mGENERATExEMITRRxREG1,
                 getBIT (16, mGENERATExVERIFY_INX_USAGExR));
        putBITp (
            16, mGENERATExEMITRRxREG2,
            getBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExVERIFY_INX_USAGExOP))
                        + 34 + 2 * (0)));
        GENERATExEMITRR (0);
      }
      // CALL DROP_INX(OP); (4226)
      {
        putBITp (16, mGENERATExDROP_INXxOP,
                 getBIT (16, mGENERATExVERIFY_INX_USAGExOP));
        GENERATExDROP_INX (0);
      }
      // INX(OP) = R; (4227)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExVERIFY_INX_USAGExR);
        putBIT (16,
                getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExVERIFY_INX_USAGExOP)) + 34
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
