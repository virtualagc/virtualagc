/*
  File GENERATExLIBNAME.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExLIBNAME (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExLIBNAME");
  // IF ~Z_LINKAGE THEN (3774)
  if (1 & (xNOT (BYTE0 (mZ_LINKAGE))))
    // RETURN NAME; (3775)
    {
      reentryGuard = 0;
      return getCHARACTER (mGENERATExLIBNAMExNAME);
    }
  // IF SHR(INTRINSIC(NAME),1) THEN (3776)
  if (1
      & (SHR (
          bitToFixed ((putCHARACTERp (mINTRINSICxNAME,
                                      getCHARACTER (mGENERATExLIBNAMExNAME)),
                       INTRINSIC (0))),
          1)))
    // RETURN NAME; (3777)
    {
      reentryGuard = 0;
      return getCHARACTER (mGENERATExLIBNAMExNAME);
    }
  // RETURN '#Q' || NAME; (3778)
  {
    reentryGuard = 0;
    return xsCAT (cToDescriptor (NULL, "#Q"),
                  getCHARACTER (mGENERATExLIBNAMExNAME));
  }
}
