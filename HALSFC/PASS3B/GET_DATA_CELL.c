/*
  File GET_DATA_CELL.c generated by XCOM-I, 2024-08-08 04:35:09.
*/

#include "runtimeC.h"

int32_t
GET_DATA_CELL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GET_DATA_CELL");
  // CALL P3_GET_CELL(FREE_CHAIN,LENGTH,BVAR,FLAGS); (1310)
  {
    putFIXED (mP3_GET_CELLxPRED_PTR, getFIXED (mFREE_CHAIN));
    putFIXED (mP3_GET_CELLxLENGTH, getFIXED (mGET_DATA_CELLxLENGTH));
    putFIXED (mP3_GET_CELLxBVAR, getFIXED (mGET_DATA_CELLxBVAR));
    putBITp (8, mP3_GET_CELLxFLAGS, getBIT (8, mGET_DATA_CELLxFLAGS));
    P3_GET_CELL (0);
  }
  // RETURN LOC_PTR; (1311)
  {
    reentryGuard = 0;
    return getFIXED (mLOC_PTR);
  }
}
