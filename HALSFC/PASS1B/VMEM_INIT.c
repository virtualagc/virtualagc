/*
  File VMEM_INIT.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
VMEM_INIT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "VMEM_INIT");
  // VMEM_MAX_PAGE = VMEM_LIM_PAGES; (1047)
  {
    int32_t numberRHS = (int32_t)(2);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVMEM_MAX_PAGE, bitRHS);
    bitRHS->inUse = 0;
  }
  // VMEM_PRIOR_PAGE,VMEM_LAST_PAGE,VMEM_LOOK_AHEAD_PAGE = -1; (1048)
  {
    int32_t numberRHS = (int32_t)(-1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVMEM_PRIOR_PAGE, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVMEM_LAST_PAGE, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVMEM_LOOK_AHEAD_PAGE, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL MONITOR(4,VMEM_FILE#,VMEM_PAGE_SIZE); (1049)
  MONITOR4 (6, 3360);
  // CALL MONITOR(31,VMEM_FILE#,-1); (1050)
  MONITOR31 (6, -1);
  {
    reentryGuard = 0;
    return 0;
  }
}
