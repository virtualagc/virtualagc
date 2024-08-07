/*
  File GENERATExSET_NEXT_USE.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExSET_NEXT_USE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSET_NEXT_USE");
  // CTR = AUX_LOCATE(AUX_CTR, OP, 1); (6156)
  {
    int32_t numberRHS = (int32_t)((
        putFIXED (mGENERATExAUX_LOCATExPTR, getFIXED (mAUX_CTR)),
        putFIXED (mGENERATExAUX_LOCATExLINE,
                  COREHALFWORD (mGENERATExSET_NEXT_USExOP)),
        putFIXED (mGENERATExAUX_LOCATExOP, 1), GENERATExAUX_LOCATE (0)));
    putFIXED (mGENERATExSET_NEXT_USExCTR, numberRHS);
  }
  // IF CTR >= 0 THEN (6157)
  if (1 & (xGE (getFIXED (mGENERATExSET_NEXT_USExCTR), 0)))
    // DO; (6158)
    {
    rs1:;
      // CALL AUX_DECODE(CTR); (6159)
      {
        putFIXED (mGENERATExAUX_DECODExCTR,
                  getFIXED (mGENERATExSET_NEXT_USExCTR));
        GENERATExAUX_DECODE (0);
      }
      // NEXT_USE(PTR) = AUX_NEXT; (6160)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExAUX_NEXT);
        putBIT (16,
                getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExSET_NEXT_USExPTR)) + 44
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (6161)
  else
    // NEXT_USE(PTR) = 0; (6162)
    {
      int32_t numberRHS = (int32_t)(0);
      putBIT (16,
              getFIXED (mIND_STACK)
                  + 73 * (COREHALFWORD (mGENERATExSET_NEXT_USExPTR)) + 44
                  + 2 * (0),
              fixedToBit (16, numberRHS));
    }
  {
    reentryGuard = 0;
    return 0;
  }
}
