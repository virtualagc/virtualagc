/*
  File GENERATExSETUP_VAC.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExSETUP_VAC (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSETUP_VAC");
  // CALL SET_NEXT_USE(OP, CTR); (7901)
  {
    putBITp (16, mGENERATExSET_NEXT_USExPTR,
             getBIT (16, mGENERATExSETUP_VACxOP));
    putBITp (16, mGENERATExSET_NEXT_USExOP, getBIT (16, mCTR));
    GENERATExSET_NEXT_USE (0);
  }
  // IF (FORM(OP) = VAC) & (REG(OP) >= 0) THEN (7902)
  if (1
      & (xAND (
          xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP))
                             + 32 + 2 * (0)),
               BYTE0 (mVAC)),
          xGE (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP))
                             + 46 + 2 * (0)),
               0))))
    // DO; (7903)
    {
    rs1:;
      // CALL SET_REG_NEXT_USE(REG(OP), OP); (7904)
      {
        putBITp (16, mGENERATExSET_REG_NEXT_USExR,
                 getBIT (16, getFIXED (mIND_STACK)
                                 + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP))
                                 + 46 + 2 * (0)));
        putBITp (16, mGENERATExSET_REG_NEXT_USExOP,
                 getBIT (16, mGENERATExSETUP_VACxOP));
        GENERATExSET_REG_NEXT_USE (0);
      }
      // IF CSE_FLAG THEN (7905)
      if (1 & (bitToFixed (getBIT (1, mGENERATExCSE_FLAG))))
        // IF ~USAGE(REG(OP))|R_CONTENTS(REG(OP))~=VAC|R_VAR(REG(OP))~<-1 THEN
        // (7906)
        if (1
            & (xOR (
                xOR (xNOT (COREHALFWORD (
                         mUSAGE
                         + 2
                               * COREHALFWORD (
                                   getFIXED (mIND_STACK)
                                   + 73
                                         * (COREHALFWORD (
                                             mGENERATExSETUP_VACxOP))
                                   + 46 + 2 * (0)))),
                     xNEQ (BYTE0 (mR_CONTENTS
                                  + 1
                                        * COREHALFWORD (
                                            getFIXED (mIND_STACK)
                                            + 73
                                                  * (COREHALFWORD (
                                                      mGENERATExSETUP_VACxOP))
                                            + 46 + 2 * (0))),
                           BYTE0 (mVAC))),
                xGE (COREHALFWORD (mR_VAR
                                   + 2
                                         * COREHALFWORD (
                                             getFIXED (mIND_STACK)
                                             + 73
                                                   * (COREHALFWORD (
                                                       mGENERATExSETUP_VACxOP))
                                             + 46 + 2 * (0))),
                     -1))))
          // CALL SET_USAGE(REG(OP), VAC, CTR+N); (7907)
          {
            putBITp (
                16, mGENERATExSET_USAGExR,
                getBIT (16, getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP))
                                + 46 + 2 * (0)));
            putBITp (16, mGENERATExSET_USAGExRFORM, getBIT (8, mVAC));
            putFIXED (mGENERATExSET_USAGExRVAR,
                      xadd (COREHALFWORD (mCTR),
                            COREHALFWORD (mGENERATExSETUP_VACxN)));
            GENERATExSET_USAGE (0);
          }
    es1:;
    } // End of DO block
  // COPT_BITS = X_BITS(N); (7908)
  {
    descriptor_t *bitRHS = (putBITp (16, mGENERATExX_BITSxOP,
                                     getBIT (16, mGENERATExSETUP_VACxN)),
                            GENERATExX_BITS (0));
    putBIT (16, mGENERATExSETUP_VACxCOPT_BITS, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF ARRAY_FLAG & COPT_BITS | VDLP_ACTIVE & SHR(TAG,6) THEN (7909)
  if (1
      & (xOR (xAND (BYTE0 (mARRAY_FLAG),
                    COREHALFWORD (mGENERATExSETUP_VACxCOPT_BITS)),
              xAND (BYTE0 (mVDLP_ACTIVE), SHR (COREHALFWORD (mTAG), 6)))))
    // OP = VAC_ARRAY_TEMP(OP); (7910)
    {
      int32_t numberRHS
          = (int32_t)((putBITp (16, mGENERATExVAC_ARRAY_TEMPxOP,
                                getBIT (16, mGENERATExSETUP_VACxOP)),
                       GENERATExVAC_ARRAY_TEMP (0)));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mGENERATExSETUP_VACxOP, bitRHS);
      bitRHS->inUse = 0;
    }
  // COPT(OP) = COPT(OP) | COPT & 4; (7911)
  {
    int32_t numberRHS = (int32_t)(xOR (
        BYTE0 (mCOPT + 1 * COREHALFWORD (mGENERATExSETUP_VACxOP)),
        xAND (BYTE0 (mCOPT), 4)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mCOPT + 1 * (COREHALFWORD (mGENERATExSETUP_VACxOP)), bitRHS);
    bitRHS->inUse = 0;
  }
  // IF SHR(COPT_BITS, 1) THEN (7912)
  if (1 & (SHR (COREHALFWORD (mGENERATExSETUP_VACxCOPT_BITS), 1)))
    // DO; (7913)
    {
    rs2:;
      // OFF_PAGE_CTR(OFF_PAGE_NEXT) = OFF_PAGE_CTR(OFF_PAGE_NEXT) + 1; (7914)
      {
        int32_t numberRHS = (int32_t)(xadd (
            COREHALFWORD (mOFF_PAGE_CTR + 2 * COREHALFWORD (mOFF_PAGE_NEXT)),
            1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOFF_PAGE_CTR + 2 * (COREHALFWORD (mOFF_PAGE_NEXT)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // IF OFF_PAGE_CTR(OFF_PAGE_NEXT) > OFF_PAGE_MAX THEN (7915)
      if (1
          & (xGT (
              COREHALFWORD (mOFF_PAGE_CTR + 2 * COREHALFWORD (mOFF_PAGE_NEXT)),
              getFIXED (mCOMM + 4 * 19))))
        // CALL ERRORS(CLASS_BS, 131); (7916)
        {
          putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_BS));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(131)));
          ERRORS (0);
        }
      // P = OFF_PAGE_BASE(OFF_PAGE_NEXT) + OFF_PAGE_CTR(OFF_PAGE_NEXT) - 1;
      // (7917)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            xadd (COREHALFWORD (mOFF_PAGE_BASE
                                + 2 * COREHALFWORD (mOFF_PAGE_NEXT)),
                  COREHALFWORD (mOFF_PAGE_CTR
                                + 2 * COREHALFWORD (mOFF_PAGE_NEXT))),
            1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGENERATExSETUP_VACxP, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO WHILE P >= RECORD_TOP(PAGE_FIX); (7918)
      while (
          1
          & (xGE (COREHALFWORD (mGENERATExSETUP_VACxP),
                  xsubtract (COREWORD (xadd (
                                 ADDR ("PAGE_FIX", 0x80000000, NULL, 0), 12)),
                             1))))
        {
          // DO ; (7919)
          {
          rs2s1s1:;
            // IF COREWORD ( ADDR ( PAGE_FIX ) + 12 ) >= COREWORD ( ADDR (
            // PAGE_FIX ) + 8 ) THEN (7920)
            if (1
                & (xGE (COREWORD (
                            xadd (ADDR ("PAGE_FIX", 0x80000000, NULL, 0), 12)),
                        COREWORD (xadd (ADDR ("PAGE_FIX", 0x80000000, NULL, 0),
                                        8)))))
              // CALL _NEEDMORE_SPACE ( ADDR ( PAGE_FIX )  ) ; (7921)
              {
                putFIXED (m_NEEDMORE_SPACExDOPE,
                          ADDR ("PAGE_FIX", 0x80000000, NULL, 0));
                _NEEDMORE_SPACE (0);
              }
            // COREWORD ( ADDR ( PAGE_FIX ) + 12 ) = COREWORD ( ADDR ( PAGE_FIX
            // ) + 12 ) + 1 ; (7922)
            {
              int32_t numberRHS = (int32_t)(xadd (
                  COREWORD (xadd (ADDR ("PAGE_FIX", 0x80000000, NULL, 0), 12)),
                  1));
              COREWORD2 (xadd (ADDR ("PAGE_FIX", 0x80000000, NULL, 0), 12),
                         numberRHS);
            }
          es2s1s1:;
          } // End of DO block
        }   // End of DO WHILE block
      // OFF_PAGE_TAB(P) = OP | SHL(ARRAY_FLAG, 31); (7923)
      {
        int32_t numberRHS
            = (int32_t)(xOR (COREHALFWORD (mGENERATExSETUP_VACxOP),
                             SHL (BYTE0 (mARRAY_FLAG), 31)));
        putFIXED (getFIXED (mPAGE_FIX)
                      + 6 * (COREHALFWORD (mGENERATExSETUP_VACxP)) + 0
                      + 4 * (0),
                  numberRHS);
      }
      // OFF_PAGE_LINE(P) = CTR+N; (7924)
      {
        int32_t numberRHS = (int32_t)(xadd (
            COREHALFWORD (mCTR), COREHALFWORD (mGENERATExSETUP_VACxN)));
        putBIT (16,
                getFIXED (mPAGE_FIX)
                    + 6 * (COREHALFWORD (mGENERATExSETUP_VACxP)) + 4 + 2 * (0),
                fixedToBit (16, numberRHS));
      }
    es2:;
    } // End of DO block
  // VAC_VAL(CTR+N) = TRUE; (7925)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1,
            mVAC_VAL
                + 1
                      * (xadd (COREHALFWORD (mCTR),
                               COREHALFWORD (mGENERATExSETUP_VACxN))),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // OPR_VAL(CTR+N) = OPR(CTR+N); (7926)
  {
    int32_t numberRHS = (int32_t)(getFIXED (
        getFIXED (mFOR_ATOMS)
        + 4
              * (xadd (COREHALFWORD (mCTR),
                       COREHALFWORD (mGENERATExSETUP_VACxN)))
        + 0 + 4 * (0)));
    putFIXED (mOPR_VAL
                  + 4
                        * (xadd (COREHALFWORD (mCTR),
                                 COREHALFWORD (mGENERATExSETUP_VACxN))),
              numberRHS);
  }
  // OPR(CTR+N) = OP | SHL(ARRAY_FLAG, 31); (7927)
  {
    int32_t numberRHS = (int32_t)(xOR (COREHALFWORD (mGENERATExSETUP_VACxOP),
                                       SHL (BYTE0 (mARRAY_FLAG), 31)));
    putFIXED (getFIXED (mFOR_ATOMS)
                  + 4
                        * (xadd (COREHALFWORD (mCTR),
                                 COREHALFWORD (mGENERATExSETUP_VACxN)))
                  + 0 + 4 * (0),
              numberRHS);
  }
  // IF ~(NR_DEREF(OP) & (FORM(OP)=NRTEMP)) THEN (7928)
  if (1
      & (xNOT (xAND (
          BYTE0 (getFIXED (mIND_STACK)
                 + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP)) + 60
                 + 1 * (0)),
          xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP))
                             + 32 + 2 * (0)),
               BYTE0 (mWORK))))))
    // IF ~SYMFORM(FORM(OP)) THEN (7929)
    if (1
        & (xNOT (
            BYTE0 (mSYMFORM
                   + 1
                         * COREHALFWORD (
                             getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP))
                             + 32 + 2 * (0))))))
      // LOC2(OP) = CTR+N; (7930)
      {
        int32_t numberRHS = (int32_t)(xadd (
            COREHALFWORD (mCTR), COREHALFWORD (mGENERATExSETUP_VACxN)));
        putBIT (16,
                getFIXED (mIND_STACK)
                    + 73 * (COREHALFWORD (mGENERATExSETUP_VACxOP)) + 42
                    + 2 * (0),
                fixedToBit (16, numberRHS));
      }
  // N = 0; (7931)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExSETUP_VACxN, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
