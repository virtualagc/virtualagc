/*
  File TRAVERSE_INIT_LISTxGET_TERM_INIT_CELL.c generated by XCOM-I, 2024-08-08
  04:31:35.
*/

#include "runtimeC.h"

int32_t
TRAVERSE_INIT_LISTxGET_TERM_INIT_CELL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "TRAVERSE_INIT_LISTxGET_TERM_INIT_CELL");
  // WORD_INX = WORD_INX + 5; (1963)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mWORD_INX), 5));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mWORD_INX, bitRHS);
    bitRHS->inUse = 0;
  }
  // WORD_STACK(WORD_INX-4) = LOOP_START_OP | 1; (1964)
  {
    int32_t numberRHS = (int32_t)(xOR (getFIXED (mLOOP_START_OP), 1));
    putFIXED (mWORD_STACK + 4 * (xsubtract (COREHALFWORD (mWORD_INX), 4)),
              numberRHS);
  }
  // WORD_STACK(WORD_INX-3) = SHL(STRUCT_COPIES,16) | 1; (1965)
  {
    int32_t numberRHS
        = (int32_t)(xOR (SHL (COREHALFWORD (mSTRUCT_COPIES), 16), 1));
    putFIXED (mWORD_STACK + 4 * (xsubtract (COREHALFWORD (mWORD_INX), 3)),
              numberRHS);
  }
  // WORD_STACK(WORD_INX-2) = SINGLE_COPY; (1966)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mSINGLE_COPY));
    putFIXED (mWORD_STACK + 4 * (xsubtract (COREHALFWORD (mWORD_INX), 2)),
              numberRHS);
  }
  // WORD_STACK(WORD_INX-1) = VAR_REF_CELL; (1967)
  {
    int32_t numberRHS = (int32_t)(getFIXED (
        mTRAVERSE_INIT_LISTxGET_TERM_INIT_CELLxVAR_REF_CELL));
    putFIXED (mWORD_STACK + 4 * (xsubtract (COREHALFWORD (mWORD_INX), 1)),
              numberRHS);
  }
  // WORD_STACK(WORD_INX) = LOOP_END_OP | 1; (1968)
  {
    int32_t numberRHS = (int32_t)(xOR (getFIXED (mLOOP_END_OP), 1));
    putFIXED (mWORD_STACK + 4 * (COREHALFWORD (mWORD_INX)), numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
