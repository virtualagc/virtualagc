/*
  File SAVE_ARRAYNESS.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
SAVE_ARRAYNESS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SAVE_ARRAYNESS");
  // IF CURRENT_ARRAYNESS+AS_PTR>=AS_PTR_MAX THEN (7681)
  if (1
      & (xGE (xadd (COREHALFWORD (mCURRENT_ARRAYNESS), COREHALFWORD (mAS_PTR)),
              20)))
    // CALL ERROR(CLASS_BS,4); (7682)
    {
      putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_BS));
      putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(4)));
      ERROR (0);
    }
  // AS_PTR=AS_PTR+CURRENT_ARRAYNESS+1; (7683)
  {
    int32_t numberRHS = (int32_t)(xadd (
        xadd (COREHALFWORD (mAS_PTR), COREHALFWORD (mCURRENT_ARRAYNESS)), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mAS_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO I= 1 TO CURRENT_ARRAYNESS; (7684)
  {
    int32_t from120, to120, by120;
    from120 = 1;
    to120 = bitToFixed (getBIT (16, mCURRENT_ARRAYNESS));
    by120 = 1;
    for (putBIT (16, mSAVE_ARRAYNESSxI, fixedToBit (16, from120));
         bitToFixed (getBIT (16, mSAVE_ARRAYNESSxI)) <= to120;
         putBIT (16, mSAVE_ARRAYNESSxI,
                 fixedToBit (16, bitToFixed (getBIT (16, mSAVE_ARRAYNESSxI))
                                     + by120)))
      {
        // ARRAYNESS_STACK(AS_PTR-I)=CURRENT_ARRAYNESS(I); (7685)
        {
          descriptor_t *bitRHS = getBIT (
              16, mCURRENT_ARRAYNESS + 2 * COREHALFWORD (mSAVE_ARRAYNESSxI));
          putBIT (16,
                  mARRAYNESS_STACK
                      + 2
                            * (xsubtract (COREHALFWORD (mAS_PTR),
                                          COREHALFWORD (mSAVE_ARRAYNESSxI))),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // ARRAYNESS_STACK(AS_PTR)=CURRENT_ARRAYNESS; (7686)
  {
    descriptor_t *bitRHS = getBIT (16, mCURRENT_ARRAYNESS);
    putBIT (16, mARRAYNESS_STACK + 2 * (COREHALFWORD (mAS_PTR)), bitRHS);
    bitRHS->inUse = 0;
  }
  // IF RESET THEN (7687)
  if (1 & (bitToFixed (getBIT (1, mSAVE_ARRAYNESSxRESET))))
    // CURRENT_ARRAYNESS=0; (7688)
    {
      int32_t numberRHS = (int32_t)(0);
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mCURRENT_ARRAYNESS, bitRHS);
      bitRHS->inUse = 0;
    }
  // RESET=TRUE; (7689)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mSAVE_ARRAYNESSxRESET, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
