/*
  File PASS1xSET_RAND_NOOSExRET_MIN_NOOSE.c generated by XCOM-I, 2024-08-08
  04:32:08.
*/

#include "../AUXP/runtimeC.h"

descriptor_t *
PASS1xSET_RAND_NOOSExRET_MIN_NOOSE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "PASS1xSET_RAND_NOOSExRET_MIN_NOOSE");
  // IF NOOSE1 = 0 THEN (1390)
  if (1 & (xEQ (COREHALFWORD (mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE1), 0)))
    // RETURN NOOSE2; (1391)
    {
      reentryGuard = 0;
      return getBIT (16, mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE2);
    }
  // ELSE (1392)
  else
    // IF NOOSE2 = 0 THEN (1393)
    if (1
        & (xEQ (COREHALFWORD (mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE2), 0)))
      // RETURN NOOSE1; (1394)
      {
        reentryGuard = 0;
        return getBIT (16, mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE1);
      }
    // ELSE (1395)
    else
      // IF NOOSE1 < NOOSE2 THEN (1396)
      if (1
          & (xLT (COREHALFWORD (mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE1),
                  COREHALFWORD (mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE2))))
        // RETURN NOOSE1; (1397)
        {
          reentryGuard = 0;
          return getBIT (16, mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE1);
        }
      // ELSE (1398)
      else
        // RETURN NOOSE2; (1399)
        {
          reentryGuard = 0;
          return getBIT (16, mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE2);
        }
}
