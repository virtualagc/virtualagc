/*
  File CHAR_INDEX.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
CHAR_INDEX (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CHAR_INDEX");
  // L1 = LENGTH(STRING1); (722)
  {
    int32_t numberRHS = (int32_t)(LENGTH (getCHARACTER (mCHAR_INDEXxSTRING1)));
    putFIXED (mCHAR_INDEXxL1, numberRHS);
  }
  // L2 = LENGTH(STRING2); (723)
  {
    int32_t numberRHS = (int32_t)(LENGTH (getCHARACTER (mCHAR_INDEXxSTRING2)));
    putFIXED (mCHAR_INDEXxL2, numberRHS);
  }
  // IF L2 > L1 THEN (724)
  if (1 & (xGT (getFIXED (mCHAR_INDEXxL2), getFIXED (mCHAR_INDEXxL1))))
    // RETURN -1; (725)
    {
      reentryGuard = 0;
      return -1;
    }
  // DO I = 0 TO L1 - L2; (726)
  {
    int32_t from17, to17, by17;
    from17 = 0;
    to17 = xsubtract (getFIXED (mCHAR_INDEXxL1), getFIXED (mCHAR_INDEXxL2));
    by17 = 1;
    for (putFIXED (mCHAR_INDEXxI, from17); getFIXED (mCHAR_INDEXxI) <= to17;
         putFIXED (mCHAR_INDEXxI, getFIXED (mCHAR_INDEXxI) + by17))
      {
        // IF SUBSTR(STRING1, I, L2) = STRING2 THEN (727)
        if (1
            & (xsEQ (SUBSTR (getCHARACTER (mCHAR_INDEXxSTRING1),
                             getFIXED (mCHAR_INDEXxI),
                             getFIXED (mCHAR_INDEXxL2)),
                     getCHARACTER (mCHAR_INDEXxSTRING2))))
          // RETURN I; (728)
          {
            reentryGuard = 0;
            return getFIXED (mCHAR_INDEXxI);
          }
      }
  } // End of DO for-loop block
  // RETURN -1; (729)
  {
    reentryGuard = 0;
    return -1;
  }
}
