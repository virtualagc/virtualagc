/*
  File INTRINSIC.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

descriptor_t *
INTRINSIC (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "INTRINSIC");
  // IF LIB_LOOK(NAME) > 0 THEN (1389)
  if (1
      & (xGT (bitToFixed ((putCHARACTERp (mLIB_LOOKxNAME,
                                          getCHARACTER (mINTRINSICxNAME)),
                           LIB_LOOK (0))),
              0)))
    // RETURN LIB_CALLTYPE(ABS(LIB_POINTER)); (1390)
    {
      reentryGuard = 0;
      return getBIT (8, mLIB_CALLTYPE + 1 * ABS (COREHALFWORD (mLIB_POINTER)));
    }
  // RETURN FALSE; (1391)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
