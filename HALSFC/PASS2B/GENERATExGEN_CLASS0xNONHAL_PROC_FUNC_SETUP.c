/*
  File GENERATExGEN_CLASS0xNONHAL_PROC_FUNC_SETUP.c generated by XCOM-I,
  2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xNONHAL_PROC_FUNC_SETUP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard,
                               "GENERATExGEN_CLASS0xNONHAL_PROC_FUNC_SETUP");
  // ; (11587)
  ;
  {
    reentryGuard = 0;
    return 0;
  }
}
