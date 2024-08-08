/*
  File PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRAND.c generated
  by XCOM-I, 2024-08-08 04:32:08.
*/

#include "runtimeC.h"

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRAND (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (
      reentryGuard,
      "PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRAND");
  // TEMP_MAT = HALMAT(HALMAT_LINE); (2469)
  {
    int32_t numberRHS = (int32_t)(getFIXED (
        mHALMAT
        + 4
              * COREHALFWORD (
                  mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRANDxHALMAT_LINE)));
    putFIXED (mTEMP_MAT, numberRHS);
  }
  // IF (TEMP_MAT & 1) = 0 THEN (2470)
  if (1 & (xEQ (xAND (getFIXED (mTEMP_MAT), 1), 0)))
    // CALL ERRORS (CLASS_BI, 410); (2471)
    {
      putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_BI));
      putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(410)));
      ERRORS (0);
    }
  // HALRAND_QUALIFIER = SHR(TEMP_MAT, 4) &  15; (2472)
  {
    int32_t numberRHS = (int32_t)(xAND (SHR (getFIXED (mTEMP_MAT), 4), 15));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (4, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND_QUALIFIER,
            bitRHS);
    bitRHS->inUse = 0;
  }
  // HALRAND = SHR(TEMP_MAT, 16) &  65535; (2473)
  {
    int32_t numberRHS
        = (int32_t)(xAND (SHR (getFIXED (mTEMP_MAT), 16), 65535));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (HALMAT_LINE >= 1800) & (HALRAND_QUALIFIER = VAC) THEN (2474)
  if (1
      & (xAND (
          xGE (
              COREHALFWORD (
                  mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRANDxHALMAT_LINE),
              1800),
          xEQ (
              BYTE0 (
                  mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND_QUALIFIER),
              3))))
    // DO; (2475)
    {
    rs1:;
      // IF (HALRAND &  32768) ~= 0 THEN (2476)
      if (1
          & (xNEQ (
              xAND (COREHALFWORD (
                        mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND),
                    32768),
              0)))
        // HALRAND = HALRAND &  32767; (2477)
        {
          int32_t numberRHS = (int32_t)(xAND (
              COREHALFWORD (
                  mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND),
              32767));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND,
                  bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (2478)
      else
        // HALRAND = HALRAND + 1800; (2479)
        {
          int32_t numberRHS = (int32_t)(xadd (
              COREHALFWORD (
                  mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND),
              1800));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND,
                  bitRHS);
          bitRHS->inUse = 0;
        }
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
