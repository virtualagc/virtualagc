/*
  File HEX6.c generated by XCOM-I, 2024-08-08 04:33:20.
*/

#include "runtimeC.h"

descriptor_t *
HEX6 (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "HEX6");
  // T = ''; (664)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    putCHARACTER (mHEX6xT, stringRHS);
    stringRHS->inUse = 0;
  }
  // DO I = 0 TO 5; (665)
  {
    int32_t from18, to18, by18;
    from18 = 0;
    to18 = 5;
    by18 = 1;
    for (putFIXED (mHEX6xI, from18); getFIXED (mHEX6xI) <= to18;
         putFIXED (mHEX6xI, getFIXED (mHEX6xI) + by18))
      {
        // T = T||SUBSTR(HEXCODES,SHR(HVAL,SHL(5-I,2))& 15,1); (666)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              getCHARACTER (mHEX6xT),
              SUBSTR (getCHARACTER (mHEXCODES),
                      xAND (SHR (getFIXED (mHEX6xHVAL),
                                 SHL (xsubtract (5, getFIXED (mHEX6xI)), 2)),
                            15),
                      1));
          putCHARACTER (mHEX6xT, stringRHS);
          stringRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // RETURN T; (667)
  {
    reentryGuard = 0;
    return getCHARACTER (mHEX6xT);
  }
}
