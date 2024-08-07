/*
  File ZAP_VARS_BY_TYPE.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
ZAP_VARS_BY_TYPE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ZAP_VARS_BY_TYPE");
  // TYPE = SYT_TYPE(SYB_PTR); (3097)
  {
    descriptor_t *bitRHS
        = getBIT (8, getFIXED (mSYM_TAB)
                         + 34 * (COREHALFWORD (mZAP_VARS_BY_TYPExSYB_PTR)) + 32
                         + 1 * (0));
    putBIT (16, mZAP_VARS_BY_TYPExTYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF TYPE <= 0 OR TYPE > INT_VAR THEN (3098)
  if (1
      & (xOR (xLE (COREHALFWORD (mZAP_VARS_BY_TYPExTYPE), 0),
              xGT (COREHALFWORD (mZAP_VARS_BY_TYPExTYPE), BYTE0 (mINT_VAR)))))
    // CALL ZAP_TABLES; (3099)
    ZAP_TABLES (0);
  // ELSE (3100)
  else
    // DO; (3101)
    {
    rs1:;
      // BASE = TYPE - 1; (3102)
      {
        int32_t numberRHS
            = (int32_t)(xsubtract (COREHALFWORD (mZAP_VARS_BY_TYPExTYPE), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mZAP_VARS_BY_TYPExBASE, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO FOR K = 0 TO SYT_WORDS; (3103)
      {
        int32_t from74, to74, by74;
        from74 = 0;
        to74 = SHR (COREHALFWORD (mSYT_USED), 5);
        by74 = 1;
        for (putBIT (16, mZAP_VARS_BY_TYPExK, fixedToBit (16, from74));
             bitToFixed (getBIT (16, mZAP_VARS_BY_TYPExK)) <= to74; putBIT (
                 16, mZAP_VARS_BY_TYPExK,
                 fixedToBit (16, bitToFixed (getBIT (16, mZAP_VARS_BY_TYPExK))
                                     + by74)))
          {
            // VALIDITY_ARRAY(K) = VALIDITY_ARRAY(K) &
            // ~(ZAPIT(BASE).TYPE_ZAP(K)); (3104)
            {
              int32_t numberRHS = (int32_t)(xAND (
                  getFIXED (getFIXED (mVAL_TABLE) + 4 * (COREHALFWORD (mLEVEL))
                            + 0 + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExK))),
                  xNOT (getFIXED (
                      getFIXED (mZAPIT)
                      + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExBASE)) + 0
                      + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExK))))));
              putFIXED (getFIXED (mVAL_TABLE) + 4 * (COREHALFWORD (mLEVEL)) + 0
                            + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExK)),
                        numberRHS);
            }
            // ZAPS(K) = ZAPS(K) | ZAPIT(BASE).TYPE_ZAP(K); (3105)
            {
              int32_t numberRHS = (int32_t)(xOR (
                  getFIXED (getFIXED (mOBPS) + 4 * (COREHALFWORD (mZAP_LEVEL))
                            + 0 + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExK))),
                  getFIXED (getFIXED (mZAPIT)
                            + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExBASE)) + 0
                            + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExK)))));
              putFIXED (getFIXED (mOBPS) + 4 * (COREHALFWORD (mZAP_LEVEL)) + 0
                            + 4 * (COREHALFWORD (mZAP_VARS_BY_TYPExK)),
                        numberRHS);
            }
          }
      } // End of DO for-loop block
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
