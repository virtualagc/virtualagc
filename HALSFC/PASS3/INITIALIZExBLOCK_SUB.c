/*
  File INITIALIZExBLOCK_SUB.c generated by XCOM-I, 2024-08-08 04:33:10.
*/

#include "runtimeC.h"

int32_t
INITIALIZExBLOCK_SUB (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "INITIALIZExBLOCK_SUB");
  // IF (SYT_FLAGS(OP1)&NAME_FLAG) ~= 0 THEN (2417)
  if (1
      & (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1))
                               + 8 + 4 * (0)),
                     getFIXED (mNAME_FLAG)),
               0)))
    // GO TO NO_BLOCK; (2418)
    goto NO_BLOCK;
  // IF (SYT_FLAGS(OP1)&EXTERNAL_FLAG)~=0 THEN (2419)
  if (1
      & (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1))
                               + 8 + 4 * (0)),
                     getFIXED (mEXTERNAL_FLAG)),
               0)))
    // #EXTERNALS = #EXTERNALS + 1; (2420)
    {
      int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mpEXTERNALS), 1));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mpEXTERNALS, bitRHS);
      bitRHS->inUse = 0;
    }
  // PROC_TAB1(PROCPOINT) = OP2; (2421)
  {
    descriptor_t *bitRHS = getBIT (16, mOP2);
    putBIT (16, mPROC_TAB1 + 2 * (COREHALFWORD (mINITIALIZExPROCPOINT)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // #PROCS = #PROCS + 1; (2422)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mpPROCS), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mpPROCS, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF #PROCS > PROC_MAX THEN (2423)
  if (1 & (xGT (COREHALFWORD (mpPROCS), 255)))
    // DO; (2424)
    {
    rs1:;
      // OUTPUT = X1; (2425)
      {
        descriptor_t *stringRHS;
        stringRHS = getCHARACTER (mX1);
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // OUTPUT = P3ERR || 'BLOCK TABLE LIMIT EXCEEDED ***'; (2426)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (getCHARACTER (mP3ERR),
                     cToDescriptor (NULL, "BLOCK TABLE LIMIT EXCEEDED ***"));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // GO TO COMMON_ERROR; (2427)
      {
        resetAllReentryGuards ();
        longjmp (jbCOMMON_ERROR, 1);
      }
    es1:;
    } // End of DO block
// NO_BLOCK: (2428)
NO_BLOCK:
  // CALL SYMB_SUB; (2429)
  INITIALIZExSYMB_SUB (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
