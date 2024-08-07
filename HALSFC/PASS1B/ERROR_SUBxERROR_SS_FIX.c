/*
  File ERROR_SUBxERROR_SS_FIX.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

descriptor_t *
ERROR_SUBxERROR_SS_FIX (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ERROR_SUBxERROR_SS_FIX");
  // RUN_ERR_MAX=RUN_ERR_MAX(LOC); (7424)
  {
    descriptor_t *bitRHS
        = getBIT (16, mERROR_SUBxRUN_ERR_MAX
                          + 2 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC));
    putBIT (16, mERROR_SUBxRUN_ERR_MAX, bitRHS);
    bitRHS->inUse = 0;
  }
  // LOC=LOC+TEMP; (7425)
  {
    int32_t numberRHS = (int32_t)(xadd (getFIXED (mERROR_SUBxERROR_SS_FIXxLOC),
                                        getFIXED (mTEMP)));
    putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, numberRHS);
  }
  // IF VAL_P(LOC)~=0 THEN (7426)
  if (1
      & (xNEQ (
          COREHALFWORD (mVAL_P + 2 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC)),
          0)))
    // GO TO BAD_ERROR_SUB; (7427)
    {
      resetAllReentryGuards ();
      longjmp (jbERROR_SUBxBAD_ERROR_SUB, 1);
    }
  // IF INX(LOC)~=1 THEN (7428)
  if (1
      & (xNEQ (
          COREHALFWORD (mINX + 2 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC)),
          1)))
    // GO TO BAD_ERROR_SUB; (7429)
    {
      resetAllReentryGuards ();
      longjmp (jbERROR_SUBxBAD_ERROR_SUB, 1);
    }
  // IF PSEUDO_FORM(LOC)=XIMD THEN (7430)
  if (1
      & (xEQ (
          BYTE0 (mPSEUDO_FORM + 1 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC)),
          BYTE0 (mXIMD))))
    // LOC=LOC_P(LOC); (7431)
    {
      descriptor_t *bitRHS
          = getBIT (16, mLOC_P + 2 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC));
      int32_t numberRHS;
      numberRHS = bitToFixed (bitRHS);
      putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, numberRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (7432)
  else
    // IF PSEUDO_FORM(LOC)=XLIT THEN (7433)
    if (1
        & (xEQ (
            BYTE0 (mPSEUDO_FORM + 1 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC)),
            BYTE0 (mXLIT))))
      // LOC=MAKE_FIXED_LIT(LOC_P(LOC)); (7434)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (
                mMAKE_FIXED_LITxPTR,
                COREHALFWORD (mLOC_P
                              + 2 * getFIXED (mERROR_SUBxERROR_SS_FIXxLOC))),
            MAKE_FIXED_LIT (0)));
        putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, numberRHS);
      }
    // ELSE (7435)
    else
      // GO TO BAD_ERROR_SUB; (7436)
      {
        resetAllReentryGuards ();
        longjmp (jbERROR_SUBxBAD_ERROR_SUB, 1);
      }
  // IF (LOC<0)|(LOC>RUN_ERR_MAX) THEN (7437)
  if (1
      & (xOR (xLT (getFIXED (mERROR_SUBxERROR_SS_FIXxLOC), 0),
              xGT (getFIXED (mERROR_SUBxERROR_SS_FIXxLOC),
                   COREHALFWORD (mERROR_SUBxRUN_ERR_MAX)))))
    // GO TO BAD_ERROR_SUB; (7438)
    {
      resetAllReentryGuards ();
      longjmp (jbERROR_SUBxBAD_ERROR_SUB, 1);
    }
  // RETURN LOC; (7439)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(getFIXED (mERROR_SUBxERROR_SS_FIXxLOC)));
  }
}
