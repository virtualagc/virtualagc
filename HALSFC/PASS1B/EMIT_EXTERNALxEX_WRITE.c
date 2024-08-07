/*
  File EMIT_EXTERNALxEX_WRITE.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
EMIT_EXTERNALxEX_WRITE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "EMIT_EXTERNALxEX_WRITE");
  // OUTPUT(6)=NEWBUFF; (6988)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mEMIT_EXTERNALxNEWBUFF);
    OUTPUT (6, stringRHS);
    stringRHS->inUse = 0;
  }
  // DO CASE TPL_FLAG; (6989)
  {
  rs1:
    switch (COREHALFWORD (mTPL_FLAG))
      {
      case 0:
          // ; (6991)
          ;
        break;
      case 1:
        // DO; (6992)
        {
        rs1s1:;
          // IF NEWBUFF~=SUBSTR(OLDBUFF,0,TPL_LRECL) THEN (6992)
          if (1
              & (xsNEQ (getCHARACTER (mEMIT_EXTERNALxNEWBUFF),
                        SUBSTR (getCHARACTER (mEMIT_EXTERNALxOLDBUFF), 0,
                                COREHALFWORD (mTPL_LRECL)))))
            // TPL_FLAG=2; (6993)
            {
              int32_t numberRHS = (int32_t)(2);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mTPL_FLAG, bitRHS);
              bitRHS->inUse = 0;
            }
          // ELSE (6994)
          else
            // OLDBUFF=INPUT(7); (6995)
            {
              descriptor_t *stringRHS;
              stringRHS = INPUT (7);
              putCHARACTER (mEMIT_EXTERNALxOLDBUFF, stringRHS);
              stringRHS->inUse = 0;
            }
        es1s1:;
        } // End of DO block
        break;
      case 2:
          // ; (6997)
          ;
        break;
      case 3:
          // ; (6998)
          ;
        break;
      }
  } // End of DO CASE block
  {
    reentryGuard = 0;
    return 0;
  }
}
