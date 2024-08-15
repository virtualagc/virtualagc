/*
  File GENERATExCOMMUTEM.c generated by XCOM-I, 2024-08-09 12:39:31.
*/

#include "runtimeC.h"

int32_t
GENERATExCOMMUTEM (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExCOMMUTEM");
  // TEMP = LEFTOP; (6957)
  {
    descriptor_t *bitRHS = getBIT (16, mLEFTOP);
    putBIT (16, mGENERATExCOMMUTEMxTEMP, bitRHS);
    bitRHS->inUse = 0;
  }
  // LEFTOP = RIGHTOP; (6958)
  {
    descriptor_t *bitRHS = getBIT (16, mRIGHTOP);
    putBIT (16, mLEFTOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // RIGHTOP = TEMP; (6959)
  {
    descriptor_t *bitRHS = getBIT (16, mGENERATExCOMMUTEMxTEMP);
    putBIT (16, mRIGHTOP, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}