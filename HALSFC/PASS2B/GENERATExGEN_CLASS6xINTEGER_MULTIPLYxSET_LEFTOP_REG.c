/*
  File GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REG.c generated by
  XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REG (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (
      reentryGuard, "GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REG");
  // IF REG(OP) THEN (13205)
  if (1
      & (bitToFixed (getBIT (
          16,
          getFIXED (mIND_STACK)
              + 73
                    * (COREHALFWORD (
                        mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP))
              + 46 + 2 * (0)))))
    // DO; (13206)
    {
    rs1:;
      // IF OPTYPE = INTEGER THEN (13207)
      if (1 & (xEQ (COREHALFWORD (mOPTYPE), BYTE0 (mINTEGER))))
        // RETURN; (13208)
        {
          reentryGuard = 0;
          return 0;
        }
      // CALL MOVEREG(REG(OP), REG(OP)-1, TYPE(OP), 1); (13209)
      {
        putBITp (
            16, mGENERATExMOVEREGxRF,
            getBIT (
                16,
                getFIXED (mIND_STACK)
                    + 73
                          * (COREHALFWORD (
                              mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP))
                    + 46 + 2 * (0)));
        putBITp (
            16, mGENERATExMOVEREGxRT,
            fixedToBit (
                32,
                (int32_t)(xsubtract (
                    COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73
                              * (COREHALFWORD (
                                  mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP))
                        + 46 + 2 * (0)),
                    1))));
        putBITp (
            16, mGENERATExMOVEREGxRTYPE,
            getBIT (
                16,
                getFIXED (mIND_STACK)
                    + 73
                          * (COREHALFWORD (
                              mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP))
                    + 50 + 2 * (0)));
        putBITp (1, mGENERATExMOVEREGxUSED, fixedToBit (32, (int32_t)(1)));
        GENERATExMOVEREG (0);
      }
      // REG(OP) = REG(OP) - 1; (13210)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            COREHALFWORD (
                getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP))
                + 46 + 2 * (0)),
            1));
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP))
                + 46 + 2 * (0),
            fixedToBit (16, numberRHS));
      }
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
