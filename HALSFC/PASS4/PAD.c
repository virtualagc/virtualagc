/*
  File PAD.c generated by XCOM-I, 2024-08-08 04:33:20.
*/

#include "runtimeC.h"

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
  // L = LENGTH(STRING); (628)
  {
    int32_t numberRHS = (int32_t)(LENGTH (getCHARACTER (mPADxSTRING)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPADxL, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF L < MAX THEN (629)
  if (1 & (xLT (COREHALFWORD (mPADxL), COREHALFWORD (mPADxMAX))))
    // STRING = STRING||SUBSTR(X72,0,MAX-L); (630)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          getCHARACTER (mPADxSTRING),
          SUBSTR (getCHARACTER (mX72), 0,
                  xsubtract (COREHALFWORD (mPADxMAX), COREHALFWORD (mPADxL))));
      putCHARACTER (mPADxSTRING, stringRHS);
      stringRHS->inUse = 0;
    }
  // ELSE (631)
  else
    // IF L > MAX THEN (632)
    if (1 & (xGT (COREHALFWORD (mPADxL), COREHALFWORD (mPADxMAX))))
      // STRING = SUBSTR(STRING,0,MAX); (633)
      {
        descriptor_t *stringRHS;
        stringRHS
            = SUBSTR (getCHARACTER (mPADxSTRING), 0, COREHALFWORD (mPADxMAX));
        putCHARACTER (mPADxSTRING, stringRHS);
        stringRHS->inUse = 0;
      }
  // RETURN STRING; (634)
  {
    reentryGuard = 0;
    return getCHARACTER (mPADxSTRING);
  }
}
