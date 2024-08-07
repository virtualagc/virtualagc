/*
  File ERRORS.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
ERRORS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ERRORS");
  // ERROR_COUNT = ERROR_COUNT + 1; (778)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mERROR_COUNT), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mERROR_COUNT, bitRHS);
    bitRHS->inUse = 0;
  }
  // SEVERITY = COMMON_ERRORS(CLASS, NUM, TEXT, ERROR_COUNT,STMT#); (779)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mCOMMON_ERRORSxCLASS, getBIT (16, mERRORSxCLASS)),
        putBITp (16, mCOMMON_ERRORSxNUM, getBIT (16, mERRORSxNUM)),
        putCHARACTERp (mCOMMON_ERRORSxTEXT, getCHARACTER (mERRORSxTEXT)),
        putBITp (16, mCOMMON_ERRORSxERRORp, getBIT (16, mERROR_COUNT)),
        putFIXED (mCOMMON_ERRORSxSTMTp, COREHALFWORD (mSTMTp)),
        COMMON_ERRORS (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mERRORSxSEVERITY, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF SEVERITY > MAX_SEVERITY THEN (780)
  if (1
      & (xGT (COREHALFWORD (mERRORSxSEVERITY), COREHALFWORD (mMAX_SEVERITY))))
    // MAX_SEVERITY = SEVERITY; (781)
    {
      descriptor_t *bitRHS = getBIT (16, mERRORSxSEVERITY);
      putBIT (16, mMAX_SEVERITY, bitRHS);
      bitRHS->inUse = 0;
    }
  // COMMON_RETURN_CODE = SHL(MAX_SEVERITY,2); (782)
  {
    int32_t numberRHS = (int32_t)(SHL (COREHALFWORD (mMAX_SEVERITY), 2));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCOMMON_RETURN_CODE, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF SEVERITY > 1 THEN (783)
  if (1 & (xGT (COREHALFWORD (mERRORSxSEVERITY), 1)))
    // GO TO BOMB_OUT; (784)
    {
      resetAllReentryGuards ();
      longjmp (jbBOMB_OUT, 1);
    }
  // RETURN; (785)
  {
    reentryGuard = 0;
    return 0;
  }
}
