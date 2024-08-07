/*
  File PASS2xGEN_CASE_LIST.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS2xGEN_CASE_LIST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PASS2xGEN_CASE_LIST");
  // TEMP_PTR = AUXMAT1(HALMAT#); (2548)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mWORK_VARS)
                          + 11 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxHALMATp))
                          + 2 + 2 * (0));
    putBIT (16, mPASS2xGEN_CASE_LISTxTEMP_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // TEMP# = HALMAT# MOD 1800; (2549)
  {
    int32_t numberRHS
        = (int32_t)(xmod (COREHALFWORD (mPASS2xGEN_CASE_LISTxHALMATp), 1800));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPASS2xGEN_CASE_LISTxTEMPp, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF TARGET(HALMAT#) ~= 0 THEN (2550)
  if (1
      & (xNEQ (
          COREHALFWORD (getFIXED (mWORK_VARS)
                        + 11 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxHALMATp))
                        + 6 + 2 * (0)),
          0)))
    // DO; (2551)
    {
    rs1:;
      // CALL GEN_AUXRATOR(TEMP#, 0, 0, NEST_OPCODE); (2552)
      {
        putBITp (16, mPASS2xGEN_AUXRATORxHALMATp,
                 getBIT (16, mPASS2xGEN_CASE_LISTxTEMPp));
        putBITp (5, mPASS2xGEN_AUXRATORxPTR_TYPE_VALUE,
                 fixedToBit (32, (int32_t)(0)));
        putBITp (6, mPASS2xGEN_AUXRATORxTAGS_VALUE,
                 fixedToBit (32, (int32_t)(0)));
        putBITp (4, mPASS2xGEN_AUXRATORxOPCODE, fixedToBit (32, (int32_t)(7)));
        PASS2xGEN_AUXRATOR (0);
      }
      // CALL GEN_AUXRAND(TARGET(HALMAT#), 0); (2553)
      {
        putBITp (
            16, mPASS2xGEN_AUXRANDxNOOSE_VALUE,
            getBIT (16,
                    getFIXED (mWORK_VARS)
                        + 11 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxHALMATp))
                        + 6 + 2 * (0)));
        putBITp (16, mPASS2xGEN_AUXRANDxPTR_VALUE,
                 fixedToBit (32, (int32_t)(0)));
        PASS2xGEN_AUXRAND (0);
      }
      // TARGET(HALMAT#) = 0; (2554)
      {
        int32_t numberRHS = (int32_t)(0);
        putBIT (16,
                getFIXED (mWORK_VARS)
                    + 11 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxHALMATp)) + 6
                    + 2 * (0),
                fixedToBit (16, numberRHS));
      }
    es1:;
    } // End of DO block
  // DO WHILE TRUE; (2555)
  while (1 & (1))
    {
      // IF (CELL1(TEMP_PTR) = -1) | (CDR_CELL(TEMP_PTR) = 0) THEN (2556)
      if (1
          & (xOR (xEQ (COREHALFWORD (
                           getFIXED (mLIST_STRUX)
                           + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR))
                           + 0 + 2 * (0)),
                       -1),
                  xEQ (COREHALFWORD (
                           getFIXED (mLIST_STRUX)
                           + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR))
                           + 4 + 2 * (0)),
                       0))))
        // GO TO EXIT_GEN_LOOP; (2557)
        goto EXIT_GEN_LOOP;
      // CALL GEN_AUXRATOR(TEMP#, CELL1_FLAGS(TEMP_PTR) &  63,
      // CELL2_FLAGS(TEMP_PTR) &  63, NOOSE_OPCODE); (2558)
      {
        putBITp (16, mPASS2xGEN_AUXRATORxHALMATp,
                 getBIT (16, mPASS2xGEN_CASE_LISTxTEMPp));
        putBITp (
            5, mPASS2xGEN_AUXRATORxPTR_TYPE_VALUE,
            fixedToBit (
                32,
                (int32_t)(xAND (
                    BYTE0 (getFIXED (mLIST_STRUX)
                           + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR))
                           + 6 + 1 * (0)),
                    63))));
        putBITp (
            6, mPASS2xGEN_AUXRATORxTAGS_VALUE,
            fixedToBit (
                32,
                (int32_t)(xAND (
                    BYTE0 (getFIXED (mLIST_STRUX)
                           + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR))
                           + 7 + 1 * (0)),
                    63))));
        putBITp (4, mPASS2xGEN_AUXRATORxOPCODE, fixedToBit (32, (int32_t)(1)));
        PASS2xGEN_AUXRATOR (0);
      }
      // CALL GEN_AUXRAND(CELL2(TEMP_PTR), CELL1(TEMP_PTR)); (2559)
      {
        putBITp (
            16, mPASS2xGEN_AUXRANDxNOOSE_VALUE,
            getBIT (16,
                    getFIXED (mLIST_STRUX)
                        + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR))
                        + 2 + 2 * (0)));
        putBITp (
            16, mPASS2xGEN_AUXRANDxPTR_VALUE,
            getBIT (16,
                    getFIXED (mLIST_STRUX)
                        + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR))
                        + 0 + 2 * (0)));
        PASS2xGEN_AUXRAND (0);
      }
      // TEMP_PTR = CDR_CELL(TEMP_PTR); (2560)
      {
        descriptor_t *bitRHS = getBIT (
            16, getFIXED (mLIST_STRUX)
                    + 8 * (COREHALFWORD (mPASS2xGEN_CASE_LISTxTEMP_PTR)) + 4
                    + 2 * (0));
        putBIT (16, mPASS2xGEN_CASE_LISTxTEMP_PTR, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
// EXIT_GEN_LOOP: (2561)
EXIT_GEN_LOOP:;
  {
    reentryGuard = 0;
    return 0;
  }
}
