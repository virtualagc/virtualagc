/*
  File SCANxBUILD_BCD.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
SCANxBUILD_BCD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SCANxBUILD_BCD");
  // IF LENGTH(BCD) > 0 THEN (6624)
  if (1 & (xGT (LENGTH (getCHARACTER (mBCD)), 0)))
    // BCD = BCD || X1; (6625)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (getCHARACTER (mBCD), getCHARACTER (mX1));
      putCHARACTER (mBCD, stringRHS);
      stringRHS->inUse = 0;
    }
  // ELSE (6626)
  else
    // BCD = SUBSTR(X1 || X1, 1); (6627)
    {
      descriptor_t *stringRHS;
      stringRHS = SUBSTR2 (xsCAT (getCHARACTER (mX1), getCHARACTER (mX1)), 1);
      putCHARACTER (mBCD, stringRHS);
      stringRHS->inUse = 0;
    }
  // COREBYTE(FREEPOINT - 1) = NEXT_CHAR; (6628)
  {
    descriptor_t *bitRHS = getBIT (8, mNEXT_CHAR);
    COREBYTE2 (xsubtract (FREEPOINT (), 1), bitToFixed (bitRHS));
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
