/*
  File _ATTACH_BLOCKxJOIN.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
_ATTACH_BLOCKxJOIN (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_ATTACH_BLOCKxJOIN");
  // IF B1~=0 THEN (222)
  if (1 & (xNEQ (getFIXED (m_ATTACH_BLOCKxJOINxB1), 0)))
    // DO; (223)
    {
    rs1:;
      // _FREEBLOCK_NEXT(B1)=B2; (224)
      {
        int32_t numberRHS = (int32_t)(getFIXED (m_ATTACH_BLOCKxJOINxB2));
        COREWORD2 (getFIXED (m_ATTACH_BLOCKxJOINxB1), numberRHS);
      }
      // IF (B1-_FREEBLOCK_SIZE(B1)) = B2 THEN (225)
      if (1
          & (xEQ (xsubtract (getFIXED (m_ATTACH_BLOCKxJOINxB1),
                             COREWORD (xsubtract (
                                 getFIXED (m_ATTACH_BLOCKxJOINxB1), 4))),
                  getFIXED (m_ATTACH_BLOCKxJOINxB2))))
        // DO; (226)
        {
        rs1s1:;
          // _FREEBLOCK_NEXT(B1)=_FREEBLOCK_NEXT(B2); (227)
          {
            int32_t numberRHS
                = (int32_t)(COREWORD (getFIXED (m_ATTACH_BLOCKxJOINxB2)));
            COREWORD2 (getFIXED (m_ATTACH_BLOCKxJOINxB1), numberRHS);
          }
          // _FREEBLOCK_SIZE(B1)=_FREEBLOCK_SIZE(B1)+_FREEBLOCK_SIZE(B2); (228)
          {
            int32_t numberRHS = (int32_t)(xadd (
                COREWORD (xsubtract (getFIXED (m_ATTACH_BLOCKxJOINxB1), 4)),
                COREWORD (xsubtract (getFIXED (m_ATTACH_BLOCKxJOINxB2), 4))));
            COREWORD2 (xsubtract (getFIXED (m_ATTACH_BLOCKxJOINxB1), 4),
                       numberRHS);
          }
        es1s1:;
        } // End of DO block
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
