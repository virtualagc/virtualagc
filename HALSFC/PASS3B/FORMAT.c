/*
  File FORMAT.c generated by XCOM-I, 2024-08-08 04:35:09.
*/

#include "runtimeC.h"

descriptor_t *
FORMAT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "FORMAT");
  // STRING1 = IVAL; (720)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mFORMATxIVAL));
    descriptor_t *stringRHS;
    stringRHS = fixedToCharacter (numberRHS);
    putCHARACTER (mFORMATxSTRING1, stringRHS);
    stringRHS->inUse = 0;
  }
  // STRING2 = ''; (721)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    putCHARACTER (mFORMATxSTRING2, stringRHS);
    stringRHS->inUse = 0;
  }
  // J = LENGTH(STRING1) - 1; (722)
  {
    int32_t numberRHS
        = (int32_t)(xsubtract (LENGTH (getCHARACTER (mFORMATxSTRING1)), 1));
    putFIXED (mFORMATxJ, numberRHS);
  }
  // DO I = 0 TO J; (723)
  {
    int32_t from21, to21, by21;
    from21 = 0;
    to21 = getFIXED (mFORMATxJ);
    by21 = 1;
    for (putFIXED (mFORMATxI, from21); getFIXED (mFORMATxI) <= to21;
         putFIXED (mFORMATxI, getFIXED (mFORMATxI) + by21))
      {
        // CHAR = SUBSTR(STRING1,I,1); (724)
        {
          descriptor_t *stringRHS;
          stringRHS = SUBSTR (getCHARACTER (mFORMATxSTRING1),
                              getFIXED (mFORMATxI), 1);
          putCHARACTER (mFORMATxCHAR, stringRHS);
          stringRHS->inUse = 0;
        }
        // IF CHAR ~= ' ' THEN (725)
        if (1
            & (xsNEQ (getCHARACTER (mFORMATxCHAR), cToDescriptor (NULL, " "))))
          // STRING2 = STRING2||CHAR; (726)
          {
            descriptor_t *stringRHS;
            stringRHS = xsCAT (getCHARACTER (mFORMATxSTRING2),
                               getCHARACTER (mFORMATxCHAR));
            putCHARACTER (mFORMATxSTRING2, stringRHS);
            stringRHS->inUse = 0;
          }
      }
  } // End of DO for-loop block
  // J = LENGTH(STRING2); (727)
  {
    int32_t numberRHS = (int32_t)(LENGTH (getCHARACTER (mFORMATxSTRING2)));
    putFIXED (mFORMATxJ, numberRHS);
  }
  // IF J < N THEN (728)
  if (1 & (xLT (getFIXED (mFORMATxJ), getFIXED (mFORMATxN))))
    // STRING2 = SUBSTR(X72,0,N-J)||STRING2; (729)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          SUBSTR (getCHARACTER (mX72), 0,
                  xsubtract (getFIXED (mFORMATxN), getFIXED (mFORMATxJ))),
          getCHARACTER (mFORMATxSTRING2));
      putCHARACTER (mFORMATxSTRING2, stringRHS);
      stringRHS->inUse = 0;
    }
  // RETURN STRING2; (730)
  {
    reentryGuard = 0;
    return getCHARACTER (mFORMATxSTRING2);
  }
}
