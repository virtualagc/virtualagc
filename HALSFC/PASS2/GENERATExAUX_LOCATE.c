/*
  File GENERATExAUX_LOCATE.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExAUX_LOCATE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExAUX_LOCATE");
  // DO WHILE AUX_LINE(PTR) < LINE; (2742)
  while (1
         & (xLT (bitToFixed ((putFIXED (mAUX_LINExCTR,
                                        getFIXED (mGENERATExAUX_LOCATExPTR)),
                              AUX_LINE (0))),
                 getFIXED (mGENERATExAUX_LOCATExLINE))))
    {
      // PTR = PTR + 2; (2743)
      {
        int32_t numberRHS
            = (int32_t)(xadd (getFIXED (mGENERATExAUX_LOCATExPTR), 2));
        putFIXED (mGENERATExAUX_LOCATExPTR, numberRHS);
      }
    } // End of DO WHILE block
  // DO FOREVER; (2744)
  while (1 & (1))
    {
      // IF AUX_OP(PTR) = 6 THEN (2745)
      if (1
          & (xEQ ((putFIXED (mAUX_OPxCTR, getFIXED (mGENERATExAUX_LOCATExPTR)),
                   AUX_OP (0)),
                  6)))
        // RETURN -1; (2746)
        {
          reentryGuard = 0;
          return -1;
        }
      // ELSE (2747)
      else
        // IF AUX_LINE(PTR) > LINE THEN (2748)
        if (1
            & (xGT (
                bitToFixed ((putFIXED (mAUX_LINExCTR,
                                       getFIXED (mGENERATExAUX_LOCATExPTR)),
                             AUX_LINE (0))),
                getFIXED (mGENERATExAUX_LOCATExLINE))))
          // RETURN -1; (2749)
          {
            reentryGuard = 0;
            return -1;
          }
        // ELSE (2750)
        else
          // IF AUX_OP(PTR) = OP THEN (2751)
          if (1
              & (xEQ (
                  (putFIXED (mAUX_OPxCTR, getFIXED (mGENERATExAUX_LOCATExPTR)),
                   AUX_OP (0)),
                  getFIXED (mGENERATExAUX_LOCATExOP))))
            // RETURN PTR; (2752)
            {
              reentryGuard = 0;
              return getFIXED (mGENERATExAUX_LOCATExPTR);
            }
      // PTR = PTR + 2; (2753)
      {
        int32_t numberRHS
            = (int32_t)(xadd (getFIXED (mGENERATExAUX_LOCATExPTR), 2));
        putFIXED (mGENERATExAUX_LOCATExPTR, numberRHS);
      }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
