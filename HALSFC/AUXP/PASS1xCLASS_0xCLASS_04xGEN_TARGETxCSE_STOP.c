/*
  File PASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOP.c generated by XCOM-I,
  2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard,
                               "PASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOP");
  // TEMP_PTR = SHR(HALMAT_LINE, 5); (2371)
  {
    int32_t numberRHS = (int32_t)(SHR (
        COREHALFWORD (mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxHALMAT_LINE),
        5));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxTEMP_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF ( ((VAC_REF_POOL(FRAME_VAC_REF(STACK_PTR) + TEMP_PTR) |
  // VAC_REF_POOL(FRAME_VAC_PREV_REF(STACK_PTR) + TEMP_PTR)) &
  // MAP_INDICES(HALMAT_LINE &  31)) ~= 0) & ((HALMAT(HALMAT_LINE) &
  // RATOR_CSE_FLAG) ~= 0) THEN (2372)
  if (1
      & (xAND (
          xNEQ (
              xAND (
                  xOR (
                      COREWORD (
                          getFIXED (mV_POOL)
                          + 4
                                * (xadd (
                                    COREHALFWORD (
                                        getFIXED (mSTACK_FRAME)
                                        + 32 * (COREHALFWORD (mSTACK_PTR)) + 12
                                        + 2 * (0)),
                                    COREHALFWORD (
                                        mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxTEMP_PTR)))
                          + 0 + 4 * (0)),
                      COREWORD (
                          getFIXED (mV_POOL)
                          + 4
                                * (xadd (
                                    COREHALFWORD (
                                        getFIXED (mSTACK_FRAME)
                                        + 32 * (COREHALFWORD (mSTACK_PTR)) + 16
                                        + 2 * (0)),
                                    COREHALFWORD (
                                        mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxTEMP_PTR)))
                          + 0 + 4 * (0))),
                  getFIXED (
                      mMAP_INDICES
                      + 4
                            * xAND (
                                COREHALFWORD (
                                    mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxHALMAT_LINE),
                                31))),
              0),
          xNEQ (
              xAND (
                  getFIXED (
                      mHALMAT
                      + 4
                            * COREHALFWORD (
                                mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxHALMAT_LINE)),
                  8),
              0))))
    // RETURN TRUE; (2373)
    {
      reentryGuard = 0;
      return fixedToBit (32, (int32_t)(1));
    }
  // ELSE (2374)
  else
    // RETURN FALSE; (2375)
    {
      reentryGuard = 0;
      return fixedToBit (32, (int32_t)(0));
    }
}
