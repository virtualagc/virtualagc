/*
  File OUTPUT_WRITERxATTACHxADD.c generated by XCOM-I, 2024-08-09 12:40:41.
*/

#include "runtimeC.h"

int32_t
OUTPUT_WRITERxATTACHxADD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "OUTPUT_WRITERxATTACHxADD");
  // IF LENGTH(C(K)) + LENGTH(STRING) > 256 THEN (2249)
  if (1
      & (xGT (xadd (LENGTH (getCHARACTER (mC + 4 * getFIXED (mK))),
                    LENGTH (getCHARACTER (mOUTPUT_WRITERxATTACHxADDxSTRING))),
              256)))
    // DO; (2250)
    {
    rs1:;
      // TEMP = 256 - LENGTH(C(K)); (2251)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            256, LENGTH (getCHARACTER (mC + 4 * getFIXED (mK)))));
        putFIXED (mOUTPUT_WRITERxTEMP, numberRHS);
      }
      // T = SUBSTR(STRING, 0, TEMP); (2252)
      {
        descriptor_t *stringRHS;
        stringRHS = SUBSTR (getCHARACTER (mOUTPUT_WRITERxATTACHxADDxSTRING), 0,
                            getFIXED (mOUTPUT_WRITERxTEMP));
        putCHARACTER (mOUTPUT_WRITERxATTACHxADDxT, stringRHS);
        stringRHS->inUse = 0;
      }
      // C(K) = C(K) || T; (2253)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (getCHARACTER (mC + 4 * getFIXED (mK)),
                           getCHARACTER (mOUTPUT_WRITERxATTACHxADDxT));
        putCHARACTER (mC + 4 * (getFIXED (mK)), stringRHS);
        stringRHS->inUse = 0;
      }
      // K = K + 1; (2254)
      {
        int32_t numberRHS = (int32_t)(xadd (getFIXED (mK), 1));
        putFIXED (mK, numberRHS);
      }
      // C(K) = SUBSTR(STRING, TEMP); (2255)
      {
        descriptor_t *stringRHS;
        stringRHS = SUBSTR2 (getCHARACTER (mOUTPUT_WRITERxATTACHxADDxSTRING),
                             getFIXED (mOUTPUT_WRITERxTEMP));
        putCHARACTER (mC + 4 * (getFIXED (mK)), stringRHS);
        stringRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (2256)
  else
    // C(K) = C(K) || STRING; (2257)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (getCHARACTER (mC + 4 * getFIXED (mK)),
                         getCHARACTER (mOUTPUT_WRITERxATTACHxADDxSTRING));
      putCHARACTER (mC + 4 * (getFIXED (mK)), stringRHS);
      stringRHS->inUse = 0;
    }
  {
    reentryGuard = 0;
    return 0;
  }
}