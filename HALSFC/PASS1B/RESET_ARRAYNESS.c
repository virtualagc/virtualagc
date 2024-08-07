/*
  File RESET_ARRAYNESS.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
RESET_ARRAYNESS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "RESET_ARRAYNESS");
  // MISMATCH=0; (7690)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mRESET_ARRAYNESSxMISMATCH, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF ARRAYNESS_STACK(AS_PTR)>0 THEN (7691)
  if (1
      & (xGT (COREHALFWORD (mARRAYNESS_STACK + 2 * COREHALFWORD (mAS_PTR)),
              0)))
    // DO; (7692)
    {
    rs1:;
      // IF CURRENT_ARRAYNESS>0 THEN (7693)
      if (1 & (xGT (COREHALFWORD (mCURRENT_ARRAYNESS), 0)))
        // DO; (7694)
        {
        rs1s1:;
          // IF CURRENT_ARRAYNESS=ARRAYNESS_STACK(AS_PTR) THEN (7695)
          if (1
              & (xEQ (COREHALFWORD (mCURRENT_ARRAYNESS),
                      COREHALFWORD (mARRAYNESS_STACK
                                    + 2 * COREHALFWORD (mAS_PTR)))))
            // DO I=1 TO CURRENT_ARRAYNESS; (7696)
            {
              int32_t from121, to121, by121;
              from121 = 1;
              to121 = bitToFixed (getBIT (16, mCURRENT_ARRAYNESS));
              by121 = 1;
              for (putBIT (16, mRESET_ARRAYNESSxI, fixedToBit (16, from121));
                   bitToFixed (getBIT (16, mRESET_ARRAYNESSxI)) <= to121;
                   putBIT (16, mRESET_ARRAYNESSxI,
                           fixedToBit (
                               16, bitToFixed (getBIT (16, mRESET_ARRAYNESSxI))
                                       + by121)))
                {
                  // J=AS_PTR-I; (7697)
                  {
                    int32_t numberRHS = (int32_t)(xsubtract (
                        COREHALFWORD (mAS_PTR),
                        COREHALFWORD (mRESET_ARRAYNESSxI)));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mRESET_ARRAYNESSxJ, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // IF CURRENT_ARRAYNESS(I)>0 THEN (7698)
                  if (1
                      & (xGT (COREHALFWORD (
                                  mCURRENT_ARRAYNESS
                                  + 2 * COREHALFWORD (mRESET_ARRAYNESSxI)),
                              0)))
                    // IF ARRAYNESS_STACK(J)>0 THEN (7699)
                    if (1
                        & (xGT (COREHALFWORD (
                                    mARRAYNESS_STACK
                                    + 2 * COREHALFWORD (mRESET_ARRAYNESSxJ)),
                                0)))
                      // IF CURRENT_ARRAYNESS(I)~=ARRAYNESS_STACK(J) THEN
                      // (7700)
                      if (1
                          & (xNEQ (
                              COREHALFWORD (
                                  mCURRENT_ARRAYNESS
                                  + 2 * COREHALFWORD (mRESET_ARRAYNESSxI)),
                              COREHALFWORD (
                                  mARRAYNESS_STACK
                                  + 2 * COREHALFWORD (mRESET_ARRAYNESSxJ)))))
                        // MISMATCH=3; (7701)
                        {
                          int32_t numberRHS = (int32_t)(3);
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (8, mRESET_ARRAYNESSxMISMATCH, bitRHS);
                          bitRHS->inUse = 0;
                        }
                }
            } // End of DO for-loop block
          // ELSE (7702)
          else
            // MISMATCH=3; (7703)
            {
              int32_t numberRHS = (int32_t)(3);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (8, mRESET_ARRAYNESSxMISMATCH, bitRHS);
              bitRHS->inUse = 0;
            }
        es1s1:;
        } // End of DO block
      // ELSE (7704)
      else
        // MISMATCH=2; (7705)
        {
          int32_t numberRHS = (int32_t)(2);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (8, mRESET_ARRAYNESSxMISMATCH, bitRHS);
          bitRHS->inUse = 0;
        }
      // CURRENT_ARRAYNESS=ARRAYNESS_STACK(AS_PTR); (7706)
      {
        descriptor_t *bitRHS
            = getBIT (16, mARRAYNESS_STACK + 2 * COREHALFWORD (mAS_PTR));
        putBIT (16, mCURRENT_ARRAYNESS, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO I= 1 TO CURRENT_ARRAYNESS; (7707)
      {
        int32_t from122, to122, by122;
        from122 = 1;
        to122 = bitToFixed (getBIT (16, mCURRENT_ARRAYNESS));
        by122 = 1;
        for (putBIT (16, mRESET_ARRAYNESSxI, fixedToBit (16, from122));
             bitToFixed (getBIT (16, mRESET_ARRAYNESSxI)) <= to122; putBIT (
                 16, mRESET_ARRAYNESSxI,
                 fixedToBit (16, bitToFixed (getBIT (16, mRESET_ARRAYNESSxI))
                                     + by122)))
          {
            // J=AS_PTR-I; (7708)
            {
              int32_t numberRHS = (int32_t)(xsubtract (
                  COREHALFWORD (mAS_PTR), COREHALFWORD (mRESET_ARRAYNESSxI)));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mRESET_ARRAYNESSxJ, bitRHS);
              bitRHS->inUse = 0;
            }
            // CURRENT_ARRAYNESS(I)=ARRAYNESS_STACK(J); (7709)
            {
              descriptor_t *bitRHS
                  = getBIT (16, mARRAYNESS_STACK
                                    + 2 * COREHALFWORD (mRESET_ARRAYNESSxJ));
              putBIT (16,
                      mCURRENT_ARRAYNESS
                          + 2 * (COREHALFWORD (mRESET_ARRAYNESSxI)),
                      bitRHS);
              bitRHS->inUse = 0;
            }
          }
      } // End of DO for-loop block
      // AS_PTR=AS_PTR-CURRENT_ARRAYNESS; (7710)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            COREHALFWORD (mAS_PTR), COREHALFWORD (mCURRENT_ARRAYNESS)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mAS_PTR, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (7711)
  else
    // IF CURRENT_ARRAYNESS>0 THEN (7712)
    if (1 & (xGT (COREHALFWORD (mCURRENT_ARRAYNESS), 0)))
      // MISMATCH=4; (7713)
      {
        int32_t numberRHS = (int32_t)(4);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mRESET_ARRAYNESSxMISMATCH, bitRHS);
        bitRHS->inUse = 0;
      }
  // AS_PTR=AS_PTR-1; (7714)
  {
    int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mAS_PTR), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mAS_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN MISMATCH; (7715)
  {
    reentryGuard = 0;
    return BYTE0 (mRESET_ARRAYNESSxMISMATCH);
  }
}
