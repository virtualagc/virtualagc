/*
  File OBJECT_GENERATORxGET_RLD.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
OBJECT_GENERATORxGET_RLD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "OBJECT_GENERATORxGET_RLD");
  // RETURN GET_LITERAL(PTR + LIT_TOP, FLAG); (15761)
  {
    reentryGuard = 0;
    return (putFIXED (mGET_LITERALxPTR,
                      xadd (getFIXED (mOBJECT_GENERATORxGET_RLDxPTR),
                            getFIXED (mCOMM + 4 * 2))),
            putBITp (1, mGET_LITERALxFLAG,
                     getBIT (8, mOBJECT_GENERATORxGET_RLDxFLAG)),
            GET_LITERAL (0));
  }
}
