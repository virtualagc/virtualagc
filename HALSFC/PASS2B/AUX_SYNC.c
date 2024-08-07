/*
  File AUX_SYNC.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
AUX_SYNC (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "AUX_SYNC");
  // DO WHILE AUX(GET_AUX(AUX_CTR)); (984)
  while (1
         & (getFIXED (
             mAUX
             + 4
                   * bitToFixed ((putFIXED (mGET_AUXxCTR, getFIXED (mAUX_CTR)),
                                  GET_AUX (0))))))
    {
      // AUX_CTR = AUX_CTR + 1; (985)
      {
        int32_t numberRHS = (int32_t)(xadd (getFIXED (mAUX_CTR), 1));
        putFIXED (mAUX_CTR, numberRHS);
      }
    } // End of DO WHILE block
  // IF AUX_OP(AUX_CTR) ~= 6 THEN (986)
  if (1
      & (xNEQ ((putFIXED (mAUX_OPxCTR, getFIXED (mAUX_CTR)), AUX_OP (0)), 6)))
    // DO WHILE AUX_LINE(AUX_CTR) < CTR; (987)
    while (1
           & (xLT (bitToFixed ((putFIXED (mAUX_LINExCTR, getFIXED (mAUX_CTR)),
                                AUX_LINE (0))),
                   COREHALFWORD (mAUX_SYNCxCTR))))
      {
        // AUX_CTR = AUX_CTR + 2; (988)
        {
          int32_t numberRHS = (int32_t)(xadd (getFIXED (mAUX_CTR), 2));
          putFIXED (mAUX_CTR, numberRHS);
        }
      } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
