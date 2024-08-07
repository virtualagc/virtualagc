/*
  File FORMAT_SYT_VPTRS.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
FORMAT_SYT_VPTRS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "FORMAT_SYT_VPTRS");
  // DO J = 1 TO VPTR_INX; (2732)
  {
    int32_t from58, to58, by58;
    from58 = 1;
    to58 = bitToFixed (getBIT (16, mVPTR_INX));
    by58 = 1;
    for (putBIT (16, mFORMAT_SYT_VPTRSxJ, fixedToBit (16, from58));
         bitToFixed (getBIT (16, mFORMAT_SYT_VPTRSxJ)) <= to58;
         putBIT (16, mFORMAT_SYT_VPTRSxJ,
                 fixedToBit (16, bitToFixed (getBIT (16, mFORMAT_SYT_VPTRSxJ))
                                     + by58)))
      {
        // LEVEL = 0; (2733)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mLEVEL, bitRHS);
          bitRHS->inUse = 0;
        }
        // IF SYT_CLASS(SYT_NUM(J))=FUNC_CLASS|SYT_TYPE(SYT_NUM(J))=PROC_LABEL
        // THEN (2734)
        if (1
            & (xOR (
                xEQ (
                    BYTE0 (getFIXED (mSYM_TAB)
                           + 34
                                 * (COREHALFWORD (
                                     getFIXED (mSYM_ADD)
                                     + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                     + 4 + 2 * (0)))
                           + 30 + 1 * (0)),
                    COREHALFWORD (mFUNC_CLASS)),
                xEQ (
                    BYTE0 (getFIXED (mSYM_TAB)
                           + 34
                                 * (COREHALFWORD (
                                     getFIXED (mSYM_ADD)
                                     + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                     + 4 + 2 * (0)))
                           + 32 + 1 * (0)),
                    COREHALFWORD (mPROC_LABEL)))))
          // CALL FORMAT_FORM_PARM_CELL(SYT_NUM(J),SYT_VPTR(J)); (2735)
          {
            putBITp (16, mFORMAT_FORM_PARM_CELLxSYMBp,
                     getBIT (16, getFIXED (mSYM_ADD)
                                     + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                     + 4 + 2 * (0)));
            putFIXED (mFORMAT_FORM_PARM_CELLxPTR,
                      getFIXED (getFIXED (mSYM_ADD)
                                + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ)) + 0
                                + 4 * (0)));
            FORMAT_FORM_PARM_CELL (0);
          }
        // ELSE (2736)
        else
          // IF (SYT_FLAGS(SYT_NUM(J)) & NAME_FLAG) ~= 0 | SYT_TYPE(SYT_NUM(J))
          // = EQUATE_LABEL THEN (2737)
          if (1
              & (xOR (
                  xNEQ (
                      xAND (getFIXED (getFIXED (mSYM_TAB)
                                      + 34
                                            * (COREHALFWORD (
                                                getFIXED (mSYM_ADD)
                                                + 6
                                                      * (COREHALFWORD (
                                                          mFORMAT_SYT_VPTRSxJ))
                                                + 4 + 2 * (0)))
                                      + 8 + 4 * (0)),
                            getFIXED (mNAME_FLAG)),
                      0),
                  xEQ (BYTE0 (
                           getFIXED (mSYM_TAB)
                           + 34
                                 * (COREHALFWORD (
                                     getFIXED (mSYM_ADD)
                                     + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                     + 4 + 2 * (0)))
                           + 32 + 1 * (0)),
                       COREHALFWORD (mEQUATE_LABEL)))))
            // CALL FORMAT_VAR_REF_CELL(SYT_VPTR(J)); (2738)
            {
              putFIXED (mFORMAT_VAR_REF_CELLxPTR,
                        getFIXED (getFIXED (mSYM_ADD)
                                  + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                  + 0 + 4 * (0)));
              FORMAT_VAR_REF_CELL (0);
            }
          // ELSE (2739)
          else
            // IF SYT_TYPE(SYT_NUM(J)) = STRUCTURE THEN (2740)
            if (1
                & (xEQ (
                    BYTE0 (getFIXED (mSYM_TAB)
                           + 34
                                 * (COREHALFWORD (
                                     getFIXED (mSYM_ADD)
                                     + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                     + 4 + 2 * (0)))
                           + 32 + 1 * (0)),
                    COREHALFWORD (mSTRUCTURE))))
              // CALL FORMAT_NAME_TERM_CELLS(SYT_NUM(J),SYT_VPTR(J)); (2741)
              {
                putBITp (
                    16, mFORMAT_NAME_TERM_CELLSxSYMBp,
                    getBIT (16, getFIXED (mSYM_ADD)
                                    + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                    + 4 + 2 * (0)));
                putFIXED (mFORMAT_NAME_TERM_CELLSxPTR,
                          getFIXED (getFIXED (mSYM_ADD)
                                    + 6 * (COREHALFWORD (mFORMAT_SYT_VPTRSxJ))
                                    + 0 + 4 * (0)));
                FORMAT_NAME_TERM_CELLS (0);
              }
      }
  } // End of DO for-loop block
  {
    reentryGuard = 0;
    return 0;
  }
}
