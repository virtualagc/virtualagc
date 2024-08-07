/*
  File _ATTACH_RECORD.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
_ATTACH_RECORD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_ATTACH_RECORD");
  // IF FIRSTRECORD = 0 THEN (233)
  if (1 & (xEQ (getFIXED (mFIRSTRECORD), 0)))
    // FIRSTRECORD=DOPE; (234)
    {
      int32_t numberRHS = (int32_t)(getFIXED (m_ATTACH_RECORDxDOPE));
      putFIXED (mFIRSTRECORD, numberRHS);
    }
  // ELSE (235)
  else
    // DO; (236)
    {
    rs1:;
      // PREV=0; (237)
      {
        int32_t numberRHS = (int32_t)(0);
        putFIXED (m_ATTACH_RECORDxPREV, numberRHS);
      }
      // CUR=FIRSTRECORD; (238)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mFIRSTRECORD));
        putFIXED (m_ATTACH_RECORDxCUR, numberRHS);
      }
      // LOC=_DOPE_POINTER(DOPE); (239)
      {
        int32_t numberRHS
            = (int32_t)(COREWORD (getFIXED (m_ATTACH_RECORDxDOPE)));
        putFIXED (m_ATTACH_RECORDxLOC, numberRHS);
      }
      // DO UNTIL CUR = 0; (240)
      do
        {
          // IF _DOPE_POINTER(CUR) < LOC THEN (241)
          if (1
              & (xLT (COREWORD (getFIXED (m_ATTACH_RECORDxCUR)),
                      getFIXED (m_ATTACH_RECORDxLOC))))
            // ESCAPE; (242)
            break;
          // PREV=CUR; (243)
          {
            int32_t numberRHS = (int32_t)(getFIXED (m_ATTACH_RECORDxCUR));
            putFIXED (m_ATTACH_RECORDxPREV, numberRHS);
          }
          // CUR=_DOPE_NEXT(CUR); (244)
          {
            int32_t numberRHS = (int32_t)(COREWORD (
                xadd (getFIXED (m_ATTACH_RECORDxCUR), 16)));
            putFIXED (m_ATTACH_RECORDxCUR, numberRHS);
          }
        }
      while (!(1
               & (xEQ (getFIXED (m_ATTACH_RECORDxCUR),
                       0)))); // End of DO UNTIL block
      // _DOPE_NEXT(DOPE)=CUR; (245)
      {
        int32_t numberRHS = (int32_t)(getFIXED (m_ATTACH_RECORDxCUR));
        COREWORD2 (xadd (getFIXED (m_ATTACH_RECORDxDOPE), 16), numberRHS);
      }
      // IF PREV=0 THEN (246)
      if (1 & (xEQ (getFIXED (m_ATTACH_RECORDxPREV), 0)))
        // FIRSTRECORD=DOPE; (247)
        {
          int32_t numberRHS = (int32_t)(getFIXED (m_ATTACH_RECORDxDOPE));
          putFIXED (mFIRSTRECORD, numberRHS);
        }
      // ELSE (248)
      else
        // _DOPE_NEXT(PREV) =DOPE; (249)
        {
          int32_t numberRHS = (int32_t)(getFIXED (m_ATTACH_RECORDxDOPE));
          COREWORD2 (xadd (getFIXED (m_ATTACH_RECORDxPREV), 16), numberRHS);
        }
    es1:;
    } // End of DO block
  // TOTAL_RDESC=TOTAL_RDESC+(_DOPE_#DESCRIPTORS(DOPE)*_DOPE_ALLOC(DOPE));
  // (250)
  {
    int32_t numberRHS = (int32_t)(xadd (
        getFIXED (mTOTAL_RDESC),
        xmultiply (COREHALFWORD (xadd (getFIXED (m_ATTACH_RECORDxDOPE), 6)),
                   COREWORD (xadd (getFIXED (m_ATTACH_RECORDxDOPE), 8)))));
    putFIXED (mTOTAL_RDESC, numberRHS);
  }
  // CALL _FREEBLOCK_CHECK; (251)
  _FREEBLOCK_CHECK (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
