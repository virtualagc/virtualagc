/*
  File GENERATExDUPLICATE_OPERANDS.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExDUPLICATE_OPERANDS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExDUPLICATE_OPERANDS");
  // IF COPT(OP2) = 0 THEN (3636)
  if (1
      & (xEQ (
          BYTE0 (mCOPT + 1 * COREHALFWORD (mGENERATExDUPLICATE_OPERANDSxOP2)),
          0)))
    // IF KNOWN_SYM(OP1) THEN (3637)
    if (1
        & (bitToFixed (
            (putBITp (16, mGENERATExKNOWN_SYMxOP,
                      getBIT (16, mGENERATExDUPLICATE_OPERANDSxOP1)),
             GENERATExKNOWN_SYM (0)))))
      // IF KNOWN_SYM(OP2) THEN (3638)
      if (1
          & (bitToFixed (
              (putBITp (16, mGENERATExKNOWN_SYMxOP,
                        getBIT (16, mGENERATExDUPLICATE_OPERANDSxOP2)),
               GENERATExKNOWN_SYM (0)))))
        // IF LOC(OP1) = LOC(OP2) THEN (3639)
        if (1
            & (xEQ (
                COREHALFWORD (
                    getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExDUPLICATE_OPERANDSxOP1))
                    + 40 + 2 * (0)),
                COREHALFWORD (
                    getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExDUPLICATE_OPERANDSxOP2))
                    + 40 + 2 * (0)))))
          // IF INX_CON(OP1) = INX_CON(OP2) THEN (3640)
          if (1
              & (xEQ (
                  getFIXED (
                      getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExDUPLICATE_OPERANDSxOP1))
                      + 4 + 4 * (0)),
                  getFIXED (
                      getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExDUPLICATE_OPERANDSxOP2))
                      + 4 + 4 * (0)))))
            // IF INX(OP1) = INX(OP2) THEN (3641)
            if (1
                & (xEQ (
                    COREHALFWORD (getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExDUPLICATE_OPERANDSxOP1))
                                  + 34 + 2 * (0)),
                    COREHALFWORD (getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExDUPLICATE_OPERANDSxOP2))
                                  + 34 + 2 * (0)))))
              // IF DATATYPE(TYPE(OP1)) = BITS THEN (3642)
              if (1
                  & (xEQ (
                      BYTE0 (
                          mDATATYPE
                          + 1
                                * COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExDUPLICATE_OPERANDSxOP1))
                                    + 50 + 2 * (0))),
                      BYTE0 (mBITS))))
                // DO; (3643)
                {
                rs1:;
                  // IF SIZE(OP1) = SIZE(OP2) THEN (3644)
                  if (1
                      & (xEQ (COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExDUPLICATE_OPERANDSxOP1))
                                  + 48 + 2 * (0)),
                              COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExDUPLICATE_OPERANDSxOP2))
                                  + 48 + 2 * (0)))))
                    // IF COLUMN(OP1) = COLUMN(OP2) THEN (3645)
                    if (1
                        & (xEQ (
                            COREHALFWORD (
                                getFIXED (mIND_STACK)
                                + 73
                                      * (COREHALFWORD (
                                          mGENERATExDUPLICATE_OPERANDSxOP1))
                                + 24 + 2 * (0)),
                            COREHALFWORD (
                                getFIXED (mIND_STACK)
                                + 73
                                      * (COREHALFWORD (
                                          mGENERATExDUPLICATE_OPERANDSxOP2))
                                + 24 + 2 * (0)))))
                      // RETURN TRUE; (3646)
                      {
                        reentryGuard = 0;
                        return fixedToBit (32, (int32_t)(1));
                      }
                    // ELSE (3647)
                    else
                      // IF COLUMN(OP1)>0 THEN (3648)
                      if (1
                          & (xGT (
                              COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExDUPLICATE_OPERANDSxOP1))
                                  + 24 + 2 * (0)),
                              0)))
                        // IF COLUMN(OP2)>0 THEN (3649)
                        if (1
                            & (xGT (
                                COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExDUPLICATE_OPERANDSxOP2))
                                    + 24 + 2 * (0)),
                                0)))
                          // IF FORM(COLUMN(OP1))=LIT THEN (3650)
                          if (1
                              & (xEQ (
                                  COREHALFWORD (
                                      getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                getFIXED (mIND_STACK)
                                                + 73
                                                      * (COREHALFWORD (
                                                          mGENERATExDUPLICATE_OPERANDSxOP1))
                                                + 24 + 2 * (0)))
                                      + 32 + 2 * (0)),
                                  BYTE0 (mLIT))))
                            // IF FORM(COLUMN(OP2))=LIT THEN (3651)
                            if (1
                                & (xEQ (
                                    COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  getFIXED (mIND_STACK)
                                                  + 73
                                                        * (COREHALFWORD (
                                                            mGENERATExDUPLICATE_OPERANDSxOP2))
                                                  + 24 + 2 * (0)))
                                        + 32 + 2 * (0)),
                                    BYTE0 (mLIT))))
                              // RETURN VAL(COLUMN(OP1))=VAL(COLUMN(OP2));
                              // (3652)
                              {
                                reentryGuard = 0;
                                return fixedToBit (
                                    32,
                                    (int32_t)(xEQ (
                                        getFIXED (
                                            getFIXED (mIND_STACK)
                                            + 73
                                                  * (COREHALFWORD (
                                                      getFIXED (mIND_STACK)
                                                      + 73
                                                            * (COREHALFWORD (
                                                                mGENERATExDUPLICATE_OPERANDSxOP1))
                                                      + 24 + 2 * (0)))
                                            + 12 + 4 * (0)),
                                        getFIXED (
                                            getFIXED (mIND_STACK)
                                            + 73
                                                  * (COREHALFWORD (
                                                      getFIXED (mIND_STACK)
                                                      + 73
                                                            * (COREHALFWORD (
                                                                mGENERATExDUPLICATE_OPERANDSxOP2))
                                                      + 24 + 2 * (0)))
                                            + 12 + 4 * (0)))));
                              }
                es1:;
                } // End of DO block
              // ELSE (3653)
              else
                // RETURN TRUE; (3654)
                {
                  reentryGuard = 0;
                  return fixedToBit (32, (int32_t)(1));
                }
  // RETURN FALSE; (3655)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
