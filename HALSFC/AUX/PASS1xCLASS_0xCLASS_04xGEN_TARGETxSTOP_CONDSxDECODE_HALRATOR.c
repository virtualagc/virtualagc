/*
  File PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATOR.c generated
  by XCOM-I, 2024-08-08 04:32:08.
*/

#include "runtimeC.h"

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATOR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (
      reentryGuard,
      "PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATOR");
  // TEMP_MAT = HALMAT(HALMAT_LINE); (2480)
  {
    int32_t numberRHS = (int32_t)(getFIXED (
        mHALMAT
        + 4
              * COREHALFWORD (
                  mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATORxHALMAT_LINE)));
    putFIXED (mTEMP_MAT, numberRHS);
  }
  // IF (TEMP_MAT & 1) ~= 0 THEN (2481)
  if (1 & (xNEQ (xAND (getFIXED (mTEMP_MAT), 1), 0)))
    // DO; (2482)
    {
    rs1:;
      // TEMP_MAT = HALMAT(HALMAT_LINE - 1); (2483)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            mHALMAT
            + 4
                  * xsubtract (
                      COREHALFWORD (
                          mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATORxHALMAT_LINE),
                      1)));
        putFIXED (mTEMP_MAT, numberRHS);
      }
      // IF ((TEMP_MAT & 1) ~= 0) | ( ((SHR(TEMP_MAT, 24) &  255) ~=  58) &
      // ((SHR(TEMP_MAT, 24) &  255) ~=  57) ) THEN (2484)
      if (1
          & (xOR (
              xNEQ (xAND (getFIXED (mTEMP_MAT), 1), 0),
              xAND (xNEQ (xAND (SHR (getFIXED (mTEMP_MAT), 24), 255), 58),
                    xNEQ (xAND (SHR (getFIXED (mTEMP_MAT), 24), 255), 57)))))
        // CALL ERRORS (CLASS_BI, 411); (2485)
        {
          putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_BI));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(411)));
          ERRORS (0);
        }
    es1:;
    } // End of DO block
  // HALRATOR = SHR(TEMP_MAT, 4) &  4095; (2486)
  {
    int32_t numberRHS = (int32_t)(xAND (SHR (getFIXED (mTEMP_MAT), 4), 4095));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRATOR,
            bitRHS);
    bitRHS->inUse = 0;
  }
  // HALRATOR_#RANDS = SHR(TEMP_MAT, 16) &  255; (2487)
  {
    int32_t numberRHS = (int32_t)(xAND (SHR (getFIXED (mTEMP_MAT), 16), 255));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRATOR_pRANDS,
            bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
