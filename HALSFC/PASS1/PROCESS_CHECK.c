/*
  File PROCESS_CHECK.c generated by XCOM-I, 2024-08-09 12:38:15.
*/

#include "runtimeC.h"

int32_t
PROCESS_CHECK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PROCESS_CHECK");
  // IF CHECK_ARRAYNESS THEN (7330)
  if (1 & (CHECK_ARRAYNESS (0)))
    // CALL ERROR(CLASS_RT,11,VAR(LOC)); (7331)
    {
      putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_RT));
      putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(11)));
      putCHARACTERp (
          mERRORxTEXT,
          getCHARACTER (mVAR + 4 * COREHALFWORD (mPROCESS_CHECKxLOC)));
      ERROR (0);
    }
  // IF SYT_TYPE(FIXL(LOC))~=PROG_LABEL&SYT_TYPE(FIXL(LOC))~=TASK_LABEL THEN
  // (7332)
  if (1
      & (xAND (xNEQ (BYTE0 (getFIXED (mSYM_TAB)
                            + 34
                                  * (getFIXED (
                                      mFIXL
                                      + 4 * COREHALFWORD (mPROCESS_CHECKxLOC)))
                            + 32 + 1 * (0)),
                     73),
               xNEQ (BYTE0 (getFIXED (mSYM_TAB)
                            + 34
                                  * (getFIXED (
                                      mFIXL
                                      + 4 * COREHALFWORD (mPROCESS_CHECKxLOC)))
                            + 32 + 1 * (0)),
                     72))))
    // CALL ERROR(CLASS_RT,9,VAR(LOC)); (7333)
    {
      putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_RT));
      putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(9)));
      putCHARACTERp (
          mERRORxTEXT,
          getCHARACTER (mVAR + 4 * COREHALFWORD (mPROCESS_CHECKxLOC)));
      ERROR (0);
    }
  {
    reentryGuard = 0;
    return 0;
  }
}