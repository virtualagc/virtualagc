/*
  File BUILD_SDFxBAD_SRN.c generated by XCOM-I, 2024-08-08 04:35:09.
*/

#include "runtimeC.h"

int32_t
BUILD_SDFxBAD_SRN (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "BUILD_SDFxBAD_SRN");
  // SRN_FLAG1 = TRUE; (3960)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mSRN_FLAG1, bitRHS);
    bitRHS->inUse = 0;
  }
  // OUTPUT = '*** BAD SRN DETECTED AT STMT ' || STMT# || X4 || 'SRN/COUNT: '
  // || THIS_SRN || X2 || THIS_CNT; (3961)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        xsCAT (
            xsCAT (xsCAT (xsCAT (xsCAT (cToDescriptor (
                                            NULL,
                                            "*** BAD SRN DETECTED AT STMT "),
                                        bitToCharacter (
                                            getBIT (16, mBUILD_SDFxSTMTp))),
                                 getCHARACTER (mX4)),
                          cToDescriptor (NULL, "SRN/COUNT:       ")),
                   getCHARACTER (mBUILD_SDFxTHIS_SRN)),
            getCHARACTER (mX2)),
        bitToCharacter (getBIT (16, mBUILD_SDFxTHIS_CNT)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // RETURN; (3962)
  {
    reentryGuard = 0;
    return 0;
  }
}
