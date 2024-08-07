/*
  File PTR_LOCATExBAD_PTR.c generated by XCOM-I, 2024-08-08 04:35:09.
*/

#include "runtimeC.h"

int32_t
PTR_LOCATExBAD_PTR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PTR_LOCATExBAD_PTR");
  // OUTPUT = '*** BAD POINTER '||HEX8(PTR)||' DETECTED BY PTR_LOCATE ***';
  // (960)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        xsCAT (cToDescriptor (NULL, "*** BAD POINTER "),
               (putFIXED (mHEX8xHVAL, getFIXED (mPTR_LOCATExPTR)), HEX8 (0))),
        cToDescriptor (NULL, " DETECTED BY PTR_LOCATE ***"));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // CALL DUMP_VMEM_STATUS; (961)
  DUMP_VMEM_STATUS (0);
  // GO TO PHASE3_ERROR; (962)
  {
    resetAllReentryGuards ();
    longjmp (jbPHASE3_ERROR, 1);
  }
  // CALL EXIT; (963)
  EXIT ();
  {
    reentryGuard = 0;
    return 0;
  }
}
