/*
  File HALMAT_RELOCATExMOVE_BLOCK.c generated by XCOM-I, 2024-08-09 12:38:15.
*/

#include "runtimeC.h"

int32_t
HALMAT_RELOCATExMOVE_BLOCK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "HALMAT_RELOCATExMOVE_BLOCK");
  // DO I=1-STOP TO -START; (7176)
  {
    int32_t from116, to116, by116;
    from116 = xsubtract (1, COREHALFWORD (mHALMAT_RELOCATExMOVE_BLOCKxSTOP));
    to116 = xminus (COREHALFWORD (mHALMAT_RELOCATExMOVE_BLOCKxSTART));
    by116 = 1;
    for (putFIXED (mHALMAT_RELOCATExI, from116);
         getFIXED (mHALMAT_RELOCATExI) <= to116;
         putFIXED (mHALMAT_RELOCATExI, getFIXED (mHALMAT_RELOCATExI) + by116))
      {
        // ATOMS(DELTA-I)=ATOMS(-I); (7177)
        {
          int32_t numberRHS = (int32_t)(getFIXED (
              getFIXED (mFOR_ATOMS)
              + 4 * (xminus (getFIXED (mHALMAT_RELOCATExI))) + 0 + 4 * (0)));
          putFIXED (
              getFIXED (mFOR_ATOMS)
                  + 4
                        * (xsubtract (
                            COREHALFWORD (mHALMAT_RELOCATExMOVE_BLOCKxDELTA),
                            getFIXED (mHALMAT_RELOCATExI)))
                  + 0 + 4 * (0),
              numberRHS);
        }
      }
  } // End of DO for-loop block
  {
    reentryGuard = 0;
    return 0;
  }
}