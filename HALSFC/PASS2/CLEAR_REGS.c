/*
  File CLEAR_REGS.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
CLEAR_REGS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CLEAR_REGS");
  // DO I = 0 TO REG_NUM; (1068)
  {
    int32_t from23, to23, by23;
    from23 = 0;
    to23 = 15;
    by23 = 1;
    for (putBIT (16, mCLEAR_REGSxI, fixedToBit (16, from23));
         bitToFixed (getBIT (16, mCLEAR_REGSxI)) <= to23; putBIT (
             16, mCLEAR_REGSxI,
             fixedToBit (16, bitToFixed (getBIT (16, mCLEAR_REGSxI)) + by23)))
      {
        // IF ASSEMBLER_CODE THEN (1069)
        if (1 & (bitToFixed (getBIT (1, mASSEMBLER_CODE))))
          // IF (USAGE(I)&(~TRUE)) ~= 0 THEN (1070)
          if (1
              & (xNEQ (xAND (COREHALFWORD (mUSAGE
                                           + 2 * COREHALFWORD (mCLEAR_REGSxI)),
                             4294967294),
                       0)))
            // OUTPUT='*** WARNING - REGISTER '||I||' HAD OUTSTANDING USAGE';
            // (1071)
            {
              descriptor_t *stringRHS;
              stringRHS = xsCAT (
                  xsCAT (cToDescriptor (NULL, "*** WARNING - REGISTER "),
                         bitToCharacter (getBIT (16, mCLEAR_REGSxI))),
                  cToDescriptor (NULL, " HAD OUTSTANDING USAGE"));
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
        // USAGE(I) = 0; (1072)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mUSAGE + 2 * (COREHALFWORD (mCLEAR_REGSxI)), bitRHS);
          bitRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // CALL SET_LINKREG; (1073)
  SET_LINKREG (0);
  // LASTRESULT = 0; (1074)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLASTRESULT, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
