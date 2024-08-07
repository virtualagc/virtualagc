/*
  File TERMINAL.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

descriptor_t *
TERMINAL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "TERMINAL");
  // IF HALMAT_FLAG(PTR) THEN (2165)
  if (1
      & (bitToFixed (
          (putBITp (16, mHALMAT_FLAGxPTR, getBIT (16, mTERMINALxPTR)),
           HALMAT_FLAG (0)))))
    // DO; (2166)
    {
    rs1:;
      // TAG = 0; (2167)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mTERMINALxTAG, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN 1; (2168)
      {
        reentryGuard = 0;
        return fixedToBit (32, (int32_t)(1));
      }
    es1:;
    } // End of DO block
  // IF ~VAC_OR_XPT(PTR) THEN (2169)
  if (1
      & (xNOT (bitToFixed (
          (putBITp (16, mVAC_OR_XPTxPTR, getBIT (16, mTERMINALxPTR)),
           VAC_OR_XPT (0))))))
    // DO; (2170)
    {
    rs2:;
      // TAG = 0; (2171)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mTERMINALxTAG, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN 1; (2172)
      {
        reentryGuard = 0;
        return fixedToBit (32, (int32_t)(1));
      }
    es2:;
    } // End of DO block
  // IF TAG THEN (2173)
  if (1 & (bitToFixed (getBIT (8, mTERMINALxTAG))))
    // DO; (2174)
    {
    rs3:;
      // TAG = 0; (2175)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mTERMINALxTAG, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF OPTYPE ~= CLASSIFY(SHR(OPR(PTR),16)) THEN (2176)
      if (1
          & (xNEQ (
              COREHALFWORD (mOPTYPE),
              bitToFixed ((
                  putBITp (
                      16, mCLASSIFYxPTR,
                      fixedToBit (
                          32, (int32_t)(SHR (
                                  getFIXED (
                                      mOPR + 4 * COREHALFWORD (mTERMINALxPTR)),
                                  16)))),
                  CLASSIFY (0))))))
        // RETURN 1; (2177)
        {
          reentryGuard = 0;
          return fixedToBit (32, (int32_t)(1));
        }
    es3:;
    } // End of DO block
  // RETURN 0; (2178)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
