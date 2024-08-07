/*
  File GENERATExGEN_CLASS0xEMITPDELTA.c generated by XCOM-I, 2024-08-08
  04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xEMITPDELTA (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xEMITPDELTA");
  // CALL EMITC(PDELTA, INDEXNEST); (10955)
  {
    putBITp (16, mEMITCxTYPE, getBIT (8, mPDELTA));
    putBITp (16, mEMITCxINST, getBIT (16, mINDEXNEST));
    EMITC (0);
  }
  // IF ASSEMBLER_CODE THEN (10956)
  if (1 & (bitToFixed (getBIT (1, mASSEMBLER_CODE))))
    // INFO = '+DELTA.'||SYT_NAME(PROC_LEVEL(INDEXNEST))||INFO; (10957)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          xsCAT (cToDescriptor (NULL, "+DELTA."),
                 getCHARACTER (
                     getFIXED (mSYM_TAB)
                     + 34
                           * (COREHALFWORD (mPROC_LEVEL
                                            + 2 * COREHALFWORD (mINDEXNEST)))
                     + 0 + 4 * (0))),
          getCHARACTER (mINFO));
      putCHARACTER (mINFO, stringRHS);
      stringRHS->inUse = 0;
    }
  // INSMOD = 112 + INSMOD; (10958)
  {
    int32_t numberRHS = (int32_t)(xadd (112, getFIXED (mINSMOD)));
    putFIXED (mINSMOD, numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
