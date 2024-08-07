/*
  File GENERATExRETURN_STACK_ENTRY.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExRETURN_STACK_ENTRY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExRETURN_STACK_ENTRY");
  // IF (NR_BASE(P)>0)&(STACK_PTR(NR_BASE(P))<0) THEN (2851)
  if (1
      & (xAND (xGT (COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExRETURN_STACK_ENTRYxP))
                        + 62 + 2 * (0)),
                    0),
               xLT (COREHALFWORD (
                        mSTACK_PTR
                        + 2
                              * COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExRETURN_STACK_ENTRYxP))
                                  + 62 + 2 * (0))),
                    0))))
    // DO; (2852)
    {
    rs1:;
      // SAVEPTR = SAVEPTR + 1; (2853)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mSAVEPTR), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mSAVEPTR, bitRHS);
        bitRHS->inUse = 0;
      }
      // SAVEPOINT(SAVEPTR) = LOC(NR_BASE(P)); (2854)
      {
        descriptor_t *bitRHS = getBIT (
            16, getFIXED (mIND_STACK)
                    + 73
                          * (COREHALFWORD (
                              getFIXED (mIND_STACK)
                              + 73
                                    * (COREHALFWORD (
                                        mGENERATExRETURN_STACK_ENTRYxP))
                              + 62 + 2 * (0)))
                    + 40 + 2 * (0));
        putBIT (16, mSAVEPOINT + 2 * (COREHALFWORD (mSAVEPTR)), bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL RETURN_ENTRY(NR_BASE(P)); (2855)
      {
        putBITp (
            16, mGENERATExRETURN_STACK_ENTRYxRETURN_ENTRYxPTR,
            getBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExRETURN_STACK_ENTRYxP))
                        + 62 + 2 * (0)));
        GENERATExRETURN_STACK_ENTRYxRETURN_ENTRY (0);
      }
    es1:;
    } // End of DO block
  // IF FORM(P) = CSYM THEN (2856)
  if (1
      & (xEQ (
          COREHALFWORD (getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExRETURN_STACK_ENTRYxP))
                        + 32 + 2 * (0)),
          BYTE0 (mCSYM))))
    // DO; (2857)
    {
    rs2:;
      // IF (BASE(P) < 0) & (STACK_PTR(-BASE(P))< 0) THEN (2858)
      if (1
          & (xAND (
              xLT (COREHALFWORD (
                       getFIXED (mIND_STACK)
                       + 73 * (COREHALFWORD (mGENERATExRETURN_STACK_ENTRYxP))
                       + 22 + 2 * (0)),
                   0),
              xLT (COREHALFWORD (
                       mSTACK_PTR
                       + 2
                             * xminus (COREHALFWORD (
                                 getFIXED (mIND_STACK)
                                 + 73
                                       * (COREHALFWORD (
                                           mGENERATExRETURN_STACK_ENTRYxP))
                                 + 22 + 2 * (0)))),
                   0))))
        // DO; (2859)
        {
        rs2s1:;
          // WORK_USAGE(LOC(-BASE(P)))=WORK_USAGE(LOC(-BASE(P)))-1; (2860)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                COREHALFWORD (
                    mWORK_USAGE
                    + 2
                          * COREHALFWORD (
                              getFIXED (mIND_STACK)
                              + 73
                                    * (xminus (COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExRETURN_STACK_ENTRYxP))
                                        + 22 + 2 * (0))))
                              + 40 + 2 * (0))),
                1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (
                16,
                mWORK_USAGE
                    + 2
                          * (COREHALFWORD (
                              getFIXED (mIND_STACK)
                              + 73
                                    * (xminus (COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExRETURN_STACK_ENTRYxP))
                                        + 22 + 2 * (0))))
                              + 40 + 2 * (0))),
                bitRHS);
            bitRHS->inUse = 0;
          }
          // IF WORK_USAGE(LOC(-BASE(P)))=0 THEN (2861)
          if (1
              & (xEQ (
                  COREHALFWORD (
                      mWORK_USAGE
                      + 2
                            * COREHALFWORD (
                                getFIXED (mIND_STACK)
                                + 73
                                      * (xminus (COREHALFWORD (
                                          getFIXED (mIND_STACK)
                                          + 73
                                                * (COREHALFWORD (
                                                    mGENERATExRETURN_STACK_ENTRYxP))
                                          + 22 + 2 * (0))))
                                + 40 + 2 * (0))),
                  0)))
            // DO; (2862)
            {
            rs2s1s1:;
              // SAVEPTR = SAVEPTR + 1; (2863)
              {
                int32_t numberRHS
                    = (int32_t)(xadd (COREHALFWORD (mSAVEPTR), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mSAVEPTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // SAVEPOINT(SAVEPTR) = LOC(-BASE(P)); (2864)
              {
                descriptor_t *bitRHS = getBIT (
                    16,
                    getFIXED (mIND_STACK)
                        + 73
                              * (xminus (COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExRETURN_STACK_ENTRYxP))
                                  + 22 + 2 * (0))))
                        + 40 + 2 * (0));
                putBIT (16, mSAVEPOINT + 2 * (COREHALFWORD (mSAVEPTR)),
                        bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL RETURN_ENTRY(-BASE(P)); (2865)
              {
                putBITp (16, mGENERATExRETURN_STACK_ENTRYxRETURN_ENTRYxPTR,
                         fixedToBit (
                             32, (int32_t)(xminus (COREHALFWORD (
                                     getFIXED (mIND_STACK)
                                     + 73
                                           * (COREHALFWORD (
                                               mGENERATExRETURN_STACK_ENTRYxP))
                                     + 22 + 2 * (0))))));
                GENERATExRETURN_STACK_ENTRYxRETURN_ENTRY (0);
              }
            es2s1s1:;
            } // End of DO block
        es2s1:;
        } // End of DO block
    es2:;
    } // End of DO block
  // CALL RETURN_ENTRY(P); (2866)
  {
    putBITp (16, mGENERATExRETURN_STACK_ENTRYxRETURN_ENTRYxPTR,
             getBIT (16, mGENERATExRETURN_STACK_ENTRYxP));
    GENERATExRETURN_STACK_ENTRYxRETURN_ENTRY (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
