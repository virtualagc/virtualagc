/*
  File HALMAT_XNOP.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
HALMAT_XNOP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "HALMAT_XNOP");
  // IF HALMAT_OK THEN (7214)
  if (1 & (bitToFixed (getBIT (1, mHALMAT_OK))))
    // ATOMS(FIX_ATOM)=ATOMS(FIX_ATOM)& 16711680; (7215)
    {
      int32_t numberRHS = (int32_t)(xAND (
          getFIXED (getFIXED (mFOR_ATOMS)
                    + 4 * (getFIXED (mHALMAT_XNOPxFIX_ATOM)) + 0 + 4 * (0)),
          16711680));
      putFIXED (getFIXED (mFOR_ATOMS) + 4 * (getFIXED (mHALMAT_XNOPxFIX_ATOM))
                    + 0 + 4 * (0),
                numberRHS);
    }
  {
    reentryGuard = 0;
    return 0;
  }
}
