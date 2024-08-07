/*
  File GENERATExLUMP_ARRAYSIZE.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExLUMP_ARRAYSIZE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExLUMP_ARRAYSIZE");
  // ACC=1; (5070)
  {
    int32_t numberRHS = (int32_t)(1);
    putFIXED (mGENERATExLUMP_ARRAYSIZExACC, numberRHS);
  }
  // IF SYT_ARRAY(OP) > 0 THEN (5071)
  if (1
      & (xGT (COREHALFWORD (getFIXED (mSYM_TAB)
                            + 34 * (COREHALFWORD (mGENERATExLUMP_ARRAYSIZExOP))
                            + 20 + 2 * (0)),
              0)))
    // DO J=SYT_ARRAY(OP)+1 TO EXT_ARRAY(SYT_ARRAY(OP))+SYT_ARRAY(OP); (5072)
    {
      int32_t from63, to63, by63;
      from63 = xadd (
          COREHALFWORD (getFIXED (mSYM_TAB)
                        + 34 * (COREHALFWORD (mGENERATExLUMP_ARRAYSIZExOP))
                        + 20 + 2 * (0)),
          1);
      to63 = xadd (
          COREHALFWORD (
              mEXT_ARRAY
              + 2
                    * COREHALFWORD (
                        getFIXED (mSYM_TAB)
                        + 34 * (COREHALFWORD (mGENERATExLUMP_ARRAYSIZExOP))
                        + 20 + 2 * (0))),
          COREHALFWORD (getFIXED (mSYM_TAB)
                        + 34 * (COREHALFWORD (mGENERATExLUMP_ARRAYSIZExOP))
                        + 20 + 2 * (0)));
      by63 = 1;
      for (putBIT (16, mGENERATExLUMP_ARRAYSIZExJ, fixedToBit (16, from63));
           bitToFixed (getBIT (16, mGENERATExLUMP_ARRAYSIZExJ)) <= to63;
           putBIT (16, mGENERATExLUMP_ARRAYSIZExJ,
                   fixedToBit (
                       16, bitToFixed (getBIT (16, mGENERATExLUMP_ARRAYSIZExJ))
                               + by63)))
        {
          // ACC=EXT_ARRAY(J)*ACC; (5073)
          {
            int32_t numberRHS = (int32_t)(xmultiply (
                COREHALFWORD (mEXT_ARRAY
                              + 2 * COREHALFWORD (mGENERATExLUMP_ARRAYSIZExJ)),
                getFIXED (mGENERATExLUMP_ARRAYSIZExACC)));
            putFIXED (mGENERATExLUMP_ARRAYSIZExACC, numberRHS);
          }
        }
    } // End of DO for-loop block
  // RETURN ACC; (5074)
  {
    reentryGuard = 0;
    return getFIXED (mGENERATExLUMP_ARRAYSIZExACC);
  }
}
