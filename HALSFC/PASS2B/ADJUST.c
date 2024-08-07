/*
  File ADJUST.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
ADJUST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ADJUST");
  // TEMP = BIGHT - 1; (1059)
  {
    int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mADJUSTxBIGHT), 1));
    putFIXED (mADJUSTxTEMP, numberRHS);
  }
  // RETURN ADDRESS + TEMP & (~TEMP); (1060)
  {
    reentryGuard = 0;
    return xAND (xadd (getFIXED (mADJUSTxADDRESS), getFIXED (mADJUSTxTEMP)),
                 xNOT (getFIXED (mADJUSTxTEMP)));
  }
}
