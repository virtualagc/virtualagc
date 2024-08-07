/*
  File PASS1xSTACK_ERROR.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS1xSTACK_ERROR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PASS1xSTACK_ERROR");
  // CALL ERRORS (CLASS_BI, 405); (1663)
  {
    putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_BI));
    putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(405)));
    ERRORS (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
