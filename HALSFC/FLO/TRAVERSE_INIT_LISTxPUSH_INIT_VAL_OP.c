/*
  File TRAVERSE_INIT_LISTxPUSH_INIT_VAL_OP.c generated by XCOM-I, 2024-08-08
  04:31:35.
*/

#include "runtimeC.h"

int32_t
TRAVERSE_INIT_LISTxPUSH_INIT_VAL_OP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "TRAVERSE_INIT_LISTxPUSH_INIT_VAL_OP");
  // WORD_INX = WORD_INX + 2; (1958)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mWORD_INX), 2));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mWORD_INX, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF WORD_INX > WORD_STACK_SIZE THEN (1959)
  if (1 & (xGT (COREHALFWORD (mWORD_INX), 500)))
    // CALL ERRORS (CLASS_BI, 221); (1960)
    {
      putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_BI));
      putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(221)));
      ERRORS (0);
    }
  // WORD_STACK(WORD_INX-1) = STRUCT_COPY#; (1961)
  {
    descriptor_t *bitRHS = getBIT (16, mSTRUCT_COPYp);
    int32_t numberRHS;
    numberRHS = bitToFixed (bitRHS);
    putFIXED (mWORD_STACK + 4 * (xsubtract (COREHALFWORD (mWORD_INX), 1)),
              numberRHS);
    bitRHS->inUse = 0;
  }
  // WORD_STACK(WORD_INX) = VAR_REF_CELL; (1962)
  {
    int32_t numberRHS = (int32_t)(getFIXED (
        mTRAVERSE_INIT_LISTxPUSH_INIT_VAL_OPxVAR_REF_CELL));
    putFIXED (mWORD_STACK + 4 * (COREHALFWORD (mWORD_INX)), numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
