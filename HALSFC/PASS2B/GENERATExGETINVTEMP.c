/*
  File GENERATExGETINVTEMP.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGETINVTEMP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExGETINVTEMP");
  // IF (OPTYP&8) ~= 0 THEN (7199)
  if (1 & (xNEQ (xAND (COREHALFWORD (mGENERATExGETINVTEMPxOPTYP), 8), 0)))
    // SIZ = SIZ + 1; (7200)
    {
      int32_t numberRHS
          = (int32_t)(xadd (COREHALFWORD (mGENERATExGETINVTEMPxSIZ), 1));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mGENERATExGETINVTEMPxSIZ, bitRHS);
      bitRHS->inUse = 0;
    }
  // RETURN GETFREESPACE(SCALAR, SIZ+1); (7201)
  {
    reentryGuard = 0;
    return (putFIXED (mGENERATExGETFREESPACExOPTYPE, BYTE0 (mSCALAR)),
            putFIXED (mGENERATExGETFREESPACExTEMPSPACE,
                      xadd (COREHALFWORD (mGENERATExGETINVTEMPxSIZ), 1)),
            GENERATExGETFREESPACE (0));
  }
}
