/*
  File BLOCK_SUMMARYxISSUE_HEADER.c generated by XCOM-I, 2024-08-09 12:40:41.
*/

#include "runtimeC.h"

int32_t
BLOCK_SUMMARYxISSUE_HEADER (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "BLOCK_SUMMARYxISSUE_HEADER");
  // IF HEADER_ISSUED THEN (4742)
  if (1 & (bitToFixed (getBIT (1, mBLOCK_SUMMARYxHEADER_ISSUED))))
    // RETURN; (4743)
    {
      reentryGuard = 0;
      return 0;
    }
  // IF FIRST_TIME THEN (4744)
  if (1 & (bitToFixed (getBIT (1, mBLOCK_SUMMARYxFIRST_TIME))))
    // DO; (4745)
    {
    rs1:;
      // OUTPUT(1) = FIRST_HEADING; (4746)
      {
        descriptor_t *stringRHS;
        stringRHS = getCHARACTER (mBLOCK_SUMMARYxFIRST_HEADING);
        OUTPUT (1, stringRHS);
        stringRHS->inUse = 0;
      }
      // FIRST_TIME = FALSE; (4747)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mBLOCK_SUMMARYxFIRST_TIME, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // TEMP1 = SHR(I, 3); (4748)
  {
    int32_t numberRHS = (int32_t)(SHR (COREHALFWORD (mBLOCK_SUMMARYxI), 3));
    putFIXED (mTEMP1, numberRHS);
  }
  // TEMP2 = SHL(I - SHL(TEMP1, 3), 5); (4749)
  {
    int32_t numberRHS
        = (int32_t)(SHL (xsubtract (COREHALFWORD (mBLOCK_SUMMARYxI),
                                    SHL (getFIXED (mTEMP1), 3)),
                         5));
    putFIXED (mTEMP2, numberRHS);
  }
  // OUTPUT(1) = DOUBLE || SUBSTR(HEADING(TEMP1), TEMP2, 32); (4750)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        getCHARACTER (mDOUBLE),
        SUBSTR (getCHARACTER (mBLOCK_SUMMARYxHEADING + 4 * getFIXED (mTEMP1)),
                getFIXED (mTEMP2), 32));
    OUTPUT (1, stringRHS);
    stringRHS->inUse = 0;
  }
  // HEADER_ISSUED = TRUE; (4751)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mBLOCK_SUMMARYxHEADER_ISSUED, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}