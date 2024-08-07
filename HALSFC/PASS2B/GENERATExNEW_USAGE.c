/*
  File GENERATExNEW_USAGE.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExNEW_USAGE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExNEW_USAGE");
  // DO I = 0 TO REG_NUM; (3376)
  {
    int32_t from48, to48, by48;
    from48 = 0;
    to48 = 15;
    by48 = 1;
    for (putBIT (16, mGENERATExNEW_USAGExI, fixedToBit (16, from48));
         bitToFixed (getBIT (16, mGENERATExNEW_USAGExI)) <= to48; putBIT (
             16, mGENERATExNEW_USAGExI,
             fixedToBit (16, bitToFixed (getBIT (16, mGENERATExNEW_USAGExI))
                                 + by48)))
      {
        // IF USAGE(I) THEN (3377)
        if (1
            & (bitToFixed (getBIT (
                16, mUSAGE + 2 * COREHALFWORD (mGENERATExNEW_USAGExI)))))
          // DO CASE BY_NAME; (3378)
          {
          rs1s1:
            switch (BYTE0 (mGENERATExNEW_USAGExBY_NAME))
              {
              case 0:
                // DO; (3380)
                {
                rs1s1s1:;
                  // IF SYMFORM(FORM(OP)) THEN (3380)
                  if (1
                      & (bitToFixed (getBIT (
                          1, mSYMFORM
                                 + 1
                                       * COREHALFWORD (
                                           getFIXED (mIND_STACK)
                                           + 73
                                                 * (COREHALFWORD (
                                                     mGENERATExNEW_USAGExOP))
                                           + 32 + 2 * (0))))))
                    // DO; (3381)
                    {
                    rs1s1s1s1:;
                      // IF R_CONTENTS(I) = SYM | R_CONTENTS(I) = SYM2 THEN
                      // (3382)
                      if (1
                          & (xOR (
                              xEQ (BYTE0 (mR_CONTENTS
                                          + 1
                                                * COREHALFWORD (
                                                    mGENERATExNEW_USAGExI)),
                                   BYTE0 (mSYM)),
                              xEQ (BYTE0 (mR_CONTENTS
                                          + 1
                                                * COREHALFWORD (
                                                    mGENERATExNEW_USAGExI)),
                                   BYTE0 (mSYM2)))))
                        // IF R_VAR(I) = LOC(OP) THEN (3383)
                        if (1
                            & (xEQ (COREHALFWORD (
                                        mR_VAR
                                        + 2
                                              * COREHALFWORD (
                                                  mGENERATExNEW_USAGExI)),
                                    COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExNEW_USAGExOP))
                                        + 40 + 2 * (0)))))
                          // IF FLAG | R_INX(I)>0 | R_INX_CON(I)=INX_CON(OP) |
                          // (OPMODE(SYT_TYPE(LOC2(OP)))=4 &
                          // INX_CON(OP)=R_INX_CON(I)+2)  THEN (3384)
                          if (1
                              & (xOR (
                                  xOR (
                                      xOR (
                                          COREHALFWORD (
                                              mGENERATExNEW_USAGExFLAG),
                                          xGT (
                                              COREHALFWORD (
                                                  mR_INX
                                                  + 2
                                                        * COREHALFWORD (
                                                            mGENERATExNEW_USAGExI)),
                                              0)),
                                      xEQ (
                                          getFIXED (
                                              mR_INX_CON
                                              + 4
                                                    * COREHALFWORD (
                                                        mGENERATExNEW_USAGExI)),
                                          getFIXED (
                                              getFIXED (mIND_STACK)
                                              + 73
                                                    * (COREHALFWORD (
                                                        mGENERATExNEW_USAGExOP))
                                              + 4 + 4 * (0)))),
                                  xAND (
                                      xEQ (
                                          BYTE0 (
                                              mOPMODE
                                              + 1
                                                    * BYTE0 (
                                                        getFIXED (mSYM_TAB)
                                                        + 34
                                                              * (COREHALFWORD (
                                                                  getFIXED (
                                                                      mIND_STACK)
                                                                  + 73
                                                                        * (COREHALFWORD (
                                                                            mGENERATExNEW_USAGExOP))
                                                                  + 42
                                                                  + 2 * (0)))
                                                        + 32 + 1 * (0))),
                                          4),
                                      xEQ (
                                          getFIXED (
                                              getFIXED (mIND_STACK)
                                              + 73
                                                    * (COREHALFWORD (
                                                        mGENERATExNEW_USAGExOP))
                                              + 4 + 4 * (0)),
                                          xadd (
                                              getFIXED (
                                                  mR_INX_CON
                                                  + 4
                                                        * COREHALFWORD (
                                                            mGENERATExNEW_USAGExI)),
                                              2))))))
                            // CALL UNRECOGNIZABLE(I); (3385)
                            {
                              putBITp (16, mGENERATExUNRECOGNIZABLExR,
                                       getBIT (16, mGENERATExNEW_USAGExI));
                              GENERATExUNRECOGNIZABLE (0);
                            }
                      // IF R_CONTENTS(I) = SYM2 THEN (3386)
                      if (1
                          & (xEQ (
                              BYTE0 (
                                  mR_CONTENTS
                                  + 1 * COREHALFWORD (mGENERATExNEW_USAGExI)),
                              BYTE0 (mSYM2))))
                        // IF R_VAR2(I) = LOC(OP) THEN (3387)
                        if (1
                            & (xEQ (COREHALFWORD (
                                        mR_VAR2
                                        + 2
                                              * COREHALFWORD (
                                                  mGENERATExNEW_USAGExI)),
                                    COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExNEW_USAGExOP))
                                        + 40 + 2 * (0)))))
                          // IF FLAG | R_XCON(I) = INX_CON(OP) THEN (3388)
                          if (1
                              & (xOR (
                                  COREHALFWORD (mGENERATExNEW_USAGExFLAG),
                                  xEQ (getFIXED (
                                           mR_XCON
                                           + 4
                                                 * COREHALFWORD (
                                                     mGENERATExNEW_USAGExI)),
                                       getFIXED (
                                           getFIXED (mIND_STACK)
                                           + 73
                                                 * (COREHALFWORD (
                                                     mGENERATExNEW_USAGExOP))
                                           + 4 + 4 * (0))))))
                            // CALL UNRECOGNIZABLE(I); (3389)
                            {
                              putBITp (16, mGENERATExUNRECOGNIZABLExR,
                                       getBIT (16, mGENERATExNEW_USAGExI));
                              GENERATExUNRECOGNIZABLE (0);
                            }
                    es1s1s1s1:;
                    } // End of DO block
                es1s1s1:;
                } // End of DO block
                break;
              case 1:
                // IF SYMFORM(FORM(OP)) THEN (3391)
                if (1
                    & (bitToFixed (getBIT (
                        1, mSYMFORM
                               + 1
                                     * COREHALFWORD (
                                         getFIXED (mIND_STACK)
                                         + 73
                                               * (COREHALFWORD (
                                                   mGENERATExNEW_USAGExOP))
                                         + 32 + 2 * (0))))))
                  if (1
                      & (xEQ (
                          BYTE0 (mR_CONTENTS
                                 + 1 * COREHALFWORD (mGENERATExNEW_USAGExI)),
                          BYTE0 (mAPOINTER))))
                    if (1
                        & (xEQ (
                            COREHALFWORD (
                                mR_VAR
                                + 2 * COREHALFWORD (mGENERATExNEW_USAGExI)),
                            COREHALFWORD (
                                getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExNEW_USAGExOP))
                                + 40 + 2 * (0)))))
                      {
                        putBITp (16, mGENERATExUNRECOGNIZABLExR,
                                 getBIT (16, mGENERATExNEW_USAGExI));
                        GENERATExUNRECOGNIZABLE (0);
                      }
                break;
              }
          } // End of DO CASE block
      }
  } // End of DO for-loop block
  // BY_NAME = FALSE; (3394)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExNEW_USAGExBY_NAME, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
