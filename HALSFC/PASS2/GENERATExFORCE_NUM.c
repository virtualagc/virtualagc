/*
  File GENERATExFORCE_NUM.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExFORCE_NUM (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExFORCE_NUM");
  // IF USAGE(R) > 1 THEN (5089)
  if (1
      & (xGT (COREHALFWORD (mUSAGE + 2 * COREHALFWORD (mGENERATExFORCE_NUMxR)),
              1)))
    // CALL CHECKPOINT_REG(R); (5090)
    {
      putBITp (16, mGENERATExCHECKPOINT_REGxR,
               getBIT (16, mGENERATExFORCE_NUMxR));
      GENERATExCHECKPOINT_REG (0);
    }
  // CALL LOAD_NUM(R, NUM, FLAG); (5091)
  {
    putBITp (16, mGENERATExLOAD_NUMxR, getBIT (16, mGENERATExFORCE_NUMxR));
    putFIXED (mGENERATExLOAD_NUMxNUM, getFIXED (mGENERATExFORCE_NUMxNUM));
    putBITp (1, mGENERATExLOAD_NUMxFLAG, getBIT (1, mGENERATExFORCE_NUMxFLAG));
    GENERATExLOAD_NUM (0);
  }
  // FLAG = FALSE; (5092)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExFORCE_NUMxFLAG, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
