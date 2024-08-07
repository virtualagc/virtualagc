/*
  File PASS1xSET_ASN_NOOSE.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS1xSET_ASN_NOOSE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PASS1xSET_ASN_NOOSE");
  // CALL SET_RAND_NOOSE(1); (1634)
  {
    putBITp (16, mPASS1xSET_RAND_NOOSExRANDp, fixedToBit (32, (int32_t)(1)));
    PASS1xSET_RAND_NOOSE (0);
  }
  // DO FOR NUMOP = 2 TO HALRATOR_#RANDS; (1635)
  {
    int32_t from38, to38, by38;
    from38 = 2;
    to38 = bitToFixed (getBIT (8, mHALRATOR_pRANDS));
    by38 = 1;
    for (putBIT (16, mPASS1xNUMOP, fixedToBit (16, from38));
         bitToFixed (getBIT (16, mPASS1xNUMOP)) <= to38; putBIT (
             16, mPASS1xNUMOP,
             fixedToBit (16, bitToFixed (getBIT (16, mPASS1xNUMOP)) + by38)))
      {
        // CALL SET_RAND_NOOSE(NUMOP, 1); (1636)
        {
          putBITp (16, mPASS1xSET_RAND_NOOSExRANDp, getBIT (16, mPASS1xNUMOP));
          putBITp (8, mPASS1xSET_RAND_NOOSExVAL_CHANGE,
                   fixedToBit (32, (int32_t)(1)));
          PASS1xSET_RAND_NOOSE (0);
        }
      }
  } // End of DO for-loop block
  {
    reentryGuard = 0;
    return 0;
  }
}
