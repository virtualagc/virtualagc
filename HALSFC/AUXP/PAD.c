/*
  File PAD.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

descriptor_t *
PAD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PAD");
  // L = LENGTH(STRING); (821)
  {
    int32_t numberRHS = (int32_t)(LENGTH (getCHARACTER (mPADxSTRING)));
    putFIXED (mPADxL, numberRHS);
  }
  // IF L >= WIDTH THEN (822)
  if (1 & (xGE (getFIXED (mPADxL), getFIXED (mPADxWIDTH))))
    // RETURN STRING; (823)
    {
      reentryGuard = 0;
      return getCHARACTER (mPADxSTRING);
    }
  // ELSE (824)
  else
    // RETURN STRING || SUBSTR(X72, 72 + L - WIDTH); (825)
    {
      reentryGuard = 0;
      return xsCAT (getCHARACTER (mPADxSTRING),
                    SUBSTR2 (getCHARACTER (mPADxX72),
                             xsubtract (xadd (72, getFIXED (mPADxL)),
                                        getFIXED (mPADxWIDTH))));
    }
}
