/*
  File EMIT_EXTERNALxADD_CHAR.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
EMIT_EXTERNALxADD_CHAR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "EMIT_EXTERNALxADD_CHAR");
  // BYTE(NEWBUFF, BINX) = VAL; (6985)
  {
    descriptor_t *bitRHS = getBIT (16, mEMIT_EXTERNALxADD_CHARxVAL);
    lBYTEb (ADDR (NULL, 0, "EMIT_EXTERNALxNEWBUFF", 0),
            COREHALFWORD (mEMIT_EXTERNALxBINX),
            COREHALFWORD (mEMIT_EXTERNALxADD_CHARxVAL));
    bitRHS->inUse = 0;
  }
  // BINX = BINX + 1; (6986)
  {
    int32_t numberRHS
        = (int32_t)(xadd (COREHALFWORD (mEMIT_EXTERNALxBINX), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEMIT_EXTERNALxBINX, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF BINX = TPL_LRECL THEN (6987)
  if (1
      & (xEQ (COREHALFWORD (mEMIT_EXTERNALxBINX), COREHALFWORD (mTPL_LRECL))))
    // DO; (6988)
    {
    rs1:;
      // CALL EX_WRITE; (6989)
      EMIT_EXTERNALxEX_WRITE (0);
      // CALL BLANK(NEWBUFF, 0, TPL_LRECL); (6990)
      {
        putCHARACTERp (mBLANKxSTRING, getCHARACTER (mEMIT_EXTERNALxNEWBUFF));
        putBITp (16, mBLANKxSTART, fixedToBit (32, (int32_t)(0)));
        putBITp (16, mBLANKxCOUNT, getBIT (16, mTPL_LRECL));
        BLANK (0);
      }
      // BINX = 1; (6991)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mEMIT_EXTERNALxBINX, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
