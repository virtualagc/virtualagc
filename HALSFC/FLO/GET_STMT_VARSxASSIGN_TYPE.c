/*
  File GET_STMT_VARSxASSIGN_TYPE.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

descriptor_t *
GET_STMT_VARSxASSIGN_TYPE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GET_STMT_VARSxASSIGN_TYPE");
  // IF CLASS > 0 & CLASS < 7 THEN (2356)
  if (1
      & (xAND (xGT (COREHALFWORD (mCLASS), 0),
               xLT (COREHALFWORD (mCLASS), 7))))
    // IF (OPCODE &  255) =  1 THEN (2357)
    if (1 & (xEQ (xAND (COREHALFWORD (mOPCODE), 255), 1)))
      // RETURN TRUE; (2358)
      {
        reentryGuard = 0;
        return fixedToBit (32, (int32_t)(1));
      }
  // IF OPCODE = TASN THEN (2359)
  if (1 & (xEQ (COREHALFWORD (mOPCODE), COREHALFWORD (mTASN))))
    // RETURN TRUE; (2360)
    {
      reentryGuard = 0;
      return fixedToBit (32, (int32_t)(1));
    }
  // IF OPCODE = NASN THEN (2361)
  if (1 & (xEQ (COREHALFWORD (mOPCODE), COREHALFWORD (mNASN))))
    // DO; (2362)
    {
    rs1:;
      // NAME_ASSIGN = TRUE; (2363)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGET_STMT_VARSxNAME_ASSIGN, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN TRUE; (2364)
      {
        reentryGuard = 0;
        return fixedToBit (32, (int32_t)(1));
      }
    es1:;
    } // End of DO block
  // RETURN FALSE; (2365)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
