/*
  File GENERATExDROP_UNUSED.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExDROP_UNUSED (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExDROP_UNUSED");
  // CALL DROP_INX(OP); (6060)
  {
    putBITp (16, mGENERATExDROP_INXxOP, getBIT (16, mGENERATExDROP_UNUSEDxOP));
    GENERATExDROP_INX (0);
  }
  // IF FORM(OP) = CSYM THEN (6061)
  if (1
      & (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExDROP_UNUSEDxOP))
                            + 32 + 2 * (0)),
              BYTE0 (mCSYM))))
    // CALL OFF_INX(BASE(OP)); (6062)
    {
      putBITp (16, mGENERATExOFF_INXxR,
               getBIT (16, getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mGENERATExDROP_UNUSEDxOP))
                               + 22 + 2 * (0)));
      GENERATExOFF_INX (0);
    }
  // CALL RETURN_STACK_ENTRY(BIT_PICK(OP)); (6063)
  {
    putBITp (
        16, mGENERATExRETURN_STACK_ENTRYxP,
        fixedToBit (32,
                    (int32_t)((putBITp (16, mGENERATExBIT_PICKxOP,
                                        getBIT (16, mGENERATExDROP_UNUSEDxOP)),
                               GENERATExBIT_PICK (0)))));
    GENERATExRETURN_STACK_ENTRY (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
