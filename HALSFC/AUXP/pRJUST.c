/*
  File pRJUST.c generated by XCOM-I, 2024-08-09 12:39:13.
*/

#include "runtimeC.h"

descriptor_t *
pRJUST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "pRJUST");
  // STRING = NUMBER; (637)
  {
    descriptor_t *bitRHS = getBIT (16, mpRJUSTxNUMBER);
    descriptor_t *stringRHS;
    stringRHS = bitToCharacter (bitRHS);
    putCHARACTER (mpRJUSTxSTRING, stringRHS);
    bitRHS->inUse = 0;
    stringRHS->inUse = 0;
  }
  // IF LENGTH(STRING) >= TOTAL_LENGTH THEN (638)
  if (1
      & (xGE (LENGTH (getCHARACTER (mpRJUSTxSTRING)),
              COREHALFWORD (mpRJUSTxTOTAL_LENGTH))))
    // RETURN STRING; (639)
    {
      reentryGuard = 0;
      return getCHARACTER (mpRJUSTxSTRING);
    }
  // ELSE (640)
  else
    // RETURN SUBSTR(BLANKS, 0, TOTAL_LENGTH - LENGTH(STRING)) || STRING; (641)
    {
      reentryGuard = 0;
      return xsCAT (
          SUBSTR (getCHARACTER (mBLANKS), 0,
                  xsubtract (COREHALFWORD (mpRJUSTxTOTAL_LENGTH),
                             LENGTH (getCHARACTER (mpRJUSTxSTRING)))),
          getCHARACTER (mpRJUSTxSTRING));
    }
}