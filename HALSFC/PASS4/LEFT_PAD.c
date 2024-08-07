/*
  File LEFT_PAD.c generated by XCOM-I, 2024-08-08 04:33:20.
*/

#include "runtimeC.h"

descriptor_t *
LEFT_PAD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "LEFT_PAD");
  // L = LENGTH(STRING); (635)
  {
    int32_t numberRHS = (int32_t)(LENGTH (getCHARACTER (mLEFT_PADxSTRING)));
    putFIXED (mLEFT_PADxL, numberRHS);
  }
  // IF L >= WIDTH THEN (636)
  if (1 & (xGE (getFIXED (mLEFT_PADxL), getFIXED (mLEFT_PADxWIDTH))))
    // RETURN STRING; (637)
    {
      reentryGuard = 0;
      return getCHARACTER (mLEFT_PADxSTRING);
    }
  // ELSE (638)
  else
    // RETURN SUBSTR(X72,0,WIDTH-L)||STRING; (639)
    {
      reentryGuard = 0;
      return xsCAT (SUBSTR (getCHARACTER (mX72), 0,
                            xsubtract (getFIXED (mLEFT_PADxWIDTH),
                                       getFIXED (mLEFT_PADxL))),
                    getCHARACTER (mLEFT_PADxSTRING));
    }
}
