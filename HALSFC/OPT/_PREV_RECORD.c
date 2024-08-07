/*
  File _PREV_RECORD.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
_PREV_RECORD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_PREV_RECORD");
  // PREV=0; (202)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (m_PREV_RECORDxPREV, numberRHS);
  }
  // CUR=FIRSTRECORD; (203)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mFIRSTRECORD));
    putFIXED (m_PREV_RECORDxCUR, numberRHS);
  }
  // DO WHILE (CUR > 0) & (CUR ~= DOPE); (204)
  while (1
         & (xAND (xGT (getFIXED (m_PREV_RECORDxCUR), 0),
                  xNEQ (getFIXED (m_PREV_RECORDxCUR),
                        getFIXED (m_PREV_RECORDxDOPE)))))
    {
      // PREV=CUR; (205)
      {
        int32_t numberRHS = (int32_t)(getFIXED (m_PREV_RECORDxCUR));
        putFIXED (m_PREV_RECORDxPREV, numberRHS);
      }
      // CUR=_DOPE_NEXT(CUR); (206)
      {
        int32_t numberRHS
            = (int32_t)(COREWORD (xadd (getFIXED (m_PREV_RECORDxCUR), 16)));
        putFIXED (m_PREV_RECORDxCUR, numberRHS);
      }
    } // End of DO WHILE block
  // RETURN PREV; (207)
  {
    reentryGuard = 0;
    return getFIXED (m_PREV_RECORDxPREV);
  }
}
