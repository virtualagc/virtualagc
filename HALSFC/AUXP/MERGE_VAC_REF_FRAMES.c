/*
  File MERGE_VAC_REF_FRAMES.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
MERGE_VAC_REF_FRAMES (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "MERGE_VAC_REF_FRAMES");
  // DO FOR WORK1 = SHR(FIRST_MERGE, 5) TO SHR(LAST_MERGE, 5) + 1; (1051)
  {
    int32_t from28, to28, by28;
    from28 = SHR (COREHALFWORD (mMERGE_VAC_REF_FRAMESxFIRST_MERGE), 5);
    to28 = xadd (SHR (COREHALFWORD (mMERGE_VAC_REF_FRAMESxLAST_MERGE), 5), 1);
    by28 = 1;
    for (putFIXED (mWORK1, from28); getFIXED (mWORK1) <= to28;
         putFIXED (mWORK1, getFIXED (mWORK1) + by28))
      {
        // VAC_REF_POOL(FRAME1 + WORK1) = VAC_REF_POOL(FRAME1 + WORK1) |
        // VAC_REF_POOL(FRAME2 + WORK1); (1052)
        {
          int32_t numberRHS = (int32_t)(xOR (
              COREWORD (
                  getFIXED (mV_POOL)
                  + 4
                        * (xadd (COREHALFWORD (mMERGE_VAC_REF_FRAMESxFRAME1),
                                 getFIXED (mWORK1)))
                  + 0 + 4 * (0)),
              COREWORD (
                  getFIXED (mV_POOL)
                  + 4
                        * (xadd (COREHALFWORD (mMERGE_VAC_REF_FRAMESxFRAME2),
                                 getFIXED (mWORK1)))
                  + 0 + 4 * (0))));
          putBIT (
              32,
              getFIXED (mV_POOL)
                  + 4
                        * (xadd (COREHALFWORD (mMERGE_VAC_REF_FRAMESxFRAME1),
                                 getFIXED (mWORK1)))
                  + 0 + 4 * (0),
              fixedToBit (32, numberRHS));
        }
      }
  } // End of DO for-loop block
  {
    reentryGuard = 0;
    return 0;
  }
}
