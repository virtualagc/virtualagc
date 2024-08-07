/*
  File GENERATExGET_VM_TEMP.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExGET_VM_TEMP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExGET_VM_TEMP");
  // IF N = 0 THEN (7192)
  if (1 & (xEQ (COREHALFWORD (mGENERATExGET_VM_TEMPxN), 0)))
    // OPTYP = OPTYPE; (7193)
    {
      descriptor_t *bitRHS = getBIT (16, mOPTYPE);
      putBIT (16, mGENERATExGET_VM_TEMPxOPTYP, bitRHS);
      bitRHS->inUse = 0;
    }
  // PTR = GETFREESPACE(OPTYP, TEMPSPACE); (7194)
  {
    int32_t numberRHS = (int32_t)((
        putFIXED (mGENERATExGETFREESPACExOPTYPE,
                  COREHALFWORD (mGENERATExGET_VM_TEMPxOPTYP)),
        putFIXED (mGENERATExGETFREESPACExTEMPSPACE, getFIXED (mTEMPSPACE)),
        GENERATExGETFREESPACE (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExGET_VM_TEMPxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // ROW(PTR) = ROW(N); (7195)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExGET_VM_TEMPxN)) + 48
                          + 2 * (0));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGET_VM_TEMPxPTR)) + 48
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // COLUMN(PTR) = COLUMN(N); (7196)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExGET_VM_TEMPxN)) + 24
                          + 2 * (0));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGET_VM_TEMPxPTR)) + 24
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // N = 0; (7197)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExGET_VM_TEMPxN, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR; (7198)
  {
    reentryGuard = 0;
    return getBIT (16, mGENERATExGET_VM_TEMPxPTR);
  }
}
