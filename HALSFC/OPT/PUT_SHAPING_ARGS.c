/*
  File PUT_SHAPING_ARGS.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
PUT_SHAPING_ARGS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PUT_SHAPING_ARGS");
  // IF TRACE THEN (4674)
  if (1 & (bitToFixed (getBIT (8, mTRACE))))
    // OUTPUT = 'PUT_SHAPING_ARGS:  ' || PTR; (4675)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (cToDescriptor (NULL, "PUT_SHAPING_ARGS:  "),
                         bitToCharacter (getBIT (16, mPUT_SHAPING_ARGSxPTR)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // XN = XNEST(PTR); (4676)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mXNESTxPTR, getBIT (16, mPUT_SHAPING_ARGSxPTR)),
        XNEST (0)));
    putFIXED (mPUT_SHAPING_ARGSxXN, numberRHS);
  }
  // DO WHILE OPOP(PTR) ~= SFST OR XNEST(PTR) ~= XN; (4677)
  while (
      1
      & (xOR (
          xNEQ (bitToFixed ((putBITp (16, mOPOPxPTR,
                                      getBIT (16, mPUT_SHAPING_ARGSxPTR)),
                             OPOP (0))),
                COREHALFWORD (mSFST)),
          xNEQ ((putBITp (16, mXNESTxPTR, getBIT (16, mPUT_SHAPING_ARGSxPTR)),
                 XNEST (0)),
                getFIXED (mPUT_SHAPING_ARGSxXN)))))
    {
      // IF OPOP(PTR) = SFAR AND XNEST(PTR) = XN THEN (4678)
      if (1
          & (xAND (
              xEQ (bitToFixed ((putBITp (16, mOPOPxPTR,
                                         getBIT (16, mPUT_SHAPING_ARGSxPTR)),
                                OPOP (0))),
                   COREHALFWORD (mSFAR)),
              xEQ ((putBITp (16, mXNESTxPTR,
                             getBIT (16, mPUT_SHAPING_ARGSxPTR)),
                    XNEST (0)),
                   getFIXED (mPUT_SHAPING_ARGSxXN)))))
        // IF VAC_OR_XPT(PTR + 1) THEN (4679)
        if (1
            & (bitToFixed (
                (putBITp (
                     16, mVAC_OR_XPTxPTR,
                     fixedToBit (
                         32, (int32_t)(xadd (
                                 COREHALFWORD (mPUT_SHAPING_ARGSxPTR), 1)))),
                 VAC_OR_XPT (0)))))
          // CALL BUMP_D_N(SHR(OPR(PTR + 1),16)); (4680)
          {
            putBITp (
                16, mBUMP_D_NxPTR,
                fixedToBit (
                    32, (int32_t)(SHR (
                            getFIXED (mOPR
                                      + 4
                                            * xadd (COREHALFWORD (
                                                        mPUT_SHAPING_ARGSxPTR),
                                                    1)),
                            16))));
            BUMP_D_N (0);
          }
      // PTR = LAST_OP(PTR - 1); (4681)
      {
        int32_t numberRHS = (int32_t)((
            putBITp (16, mLAST_OPxPTR,
                     fixedToBit (
                         32, (int32_t)(xsubtract (
                                 COREHALFWORD (mPUT_SHAPING_ARGSxPTR), 1)))),
            LAST_OP (0)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPUT_SHAPING_ARGSxPTR, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // IF TRACE THEN (4682)
  if (1 & (bitToFixed (getBIT (8, mTRACE))))
    // OUTPUT = '   END PUT_SHAPING_ARGS.'; (4683)
    {
      descriptor_t *stringRHS;
      stringRHS = cToDescriptor (NULL, "   END PUT_SHAPING_ARGS.");
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  {
    reentryGuard = 0;
    return 0;
  }
}
