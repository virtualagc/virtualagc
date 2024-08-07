/*
  File ADD_SMRK_NODE.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
ADD_SMRK_NODE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ADD_SMRK_NODE");
  // IF START > STOP THEN (1080)
  if (1
      & (xGT (COREHALFWORD (mADD_SMRK_NODExSTART),
              COREHALFWORD (mADD_SMRK_NODExSTOP))))
    // RETURN; (1081)
    {
      reentryGuard = 0;
      return 0;
    }
  // CELL_COUNT,LIMIT =0; (1082)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mADD_SMRK_NODExCELL_COUNT, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mADD_SMRK_NODExLIMIT, bitRHS);
    bitRHS->inUse = 0;
  }
  // NEW_START,VAC_START = START; (1083)
  {
    descriptor_t *bitRHS = getBIT (16, mADD_SMRK_NODExSTART);
    putBIT (16, mADD_SMRK_NODExNEW_START, bitRHS);
    putBIT (16, mVAC_START, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE LIMIT<STOP; (1084)
  while (1
         & (xLT (COREHALFWORD (mADD_SMRK_NODExLIMIT),
                 COREHALFWORD (mADD_SMRK_NODExSTOP))))
    {
      // LIMIT=MIN(NEW_START+VMEM_LIM,STOP); (1085)
      {
        descriptor_t *bitRHS
            = (putBITp (16, mMINxA,
                        fixedToBit (
                            32, (int32_t)(xadd (
                                    COREHALFWORD (mADD_SMRK_NODExNEW_START),
                                    xsubtract (837, BYTE0 (mINITIAL_CASE)))))),
               putBITp (16, mMINxB, getBIT (16, mADD_SMRK_NODExSTOP)),
               MIN (0));
        putBIT (16, mADD_SMRK_NODExLIMIT, bitRHS);
        bitRHS->inUse = 0;
      }
      // NODE=GET_CELL(SMRK_NODE_SZ(NEW_START,LIMIT),ADDR(SMRK_NODE),RESV|MODF);
      // (1086)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (
                mGET_CELLxCELL_SIZE,
                xmultiply (
                    4,
                    xadd (xadd (xsubtract (
                                    COREHALFWORD (mADD_SMRK_NODExLIMIT),
                                    COREHALFWORD (mADD_SMRK_NODExNEW_START)),
                                3),
                          BYTE0 (mINITIAL_CASE)))),
            putFIXED (mGET_CELLxBVAR,
                      ADDR ("ADD_SMRK_NODExSMRK_NODE", 0x80000000, NULL, 0)),
            putBITp (8, mGET_CELLxFLAGS,
                     fixedToBit (
                         32, (int32_t)(xOR (BYTE0 (mRESV), BYTE0 (mMODF))))),
            GET_CELL (0)));
        putFIXED (mADD_SMRK_NODExNODE, numberRHS);
      }
      // IF INITIAL_CASE THEN (1087)
      if (1 & (bitToFixed (getBIT (1, mINITIAL_CASE))))
        // DO; (1088)
        {
        rs1s1:;
          // CELL = 1; (1089)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mADD_SMRK_NODExCELL, bitRHS);
            bitRHS->inUse = 0;
          }
          // INITIAL_CASE = FALSE; (1090)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mINITIAL_CASE, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s1:;
        } // End of DO block
      // ELSE (1091)
      else
        // CELL = 0; (1092)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mADD_SMRK_NODExCELL, bitRHS);
          bitRHS->inUse = 0;
        }
      // DO I = NEW_START TO LIMIT; (1093)
      {
        int32_t from23, to23, by23;
        from23 = bitToFixed (getBIT (16, mADD_SMRK_NODExNEW_START));
        to23 = bitToFixed (getBIT (16, mADD_SMRK_NODExLIMIT));
        by23 = 1;
        for (putBIT (16, mADD_SMRK_NODExI, fixedToBit (16, from23));
             bitToFixed (getBIT (16, mADD_SMRK_NODExI)) <= to23;
             putBIT (16, mADD_SMRK_NODExI,
                     fixedToBit (16, bitToFixed (getBIT (16, mADD_SMRK_NODExI))
                                         + by23)))
          {
            // IF SAVE_OP(I) THEN (1094)
            if (1
                & (xOR (getFIXED (mOPR + 4 * COREHALFWORD (mADD_SMRK_NODExI)),
                        xNOT (xOR (
                            xEQ (bitToFixed (
                                     (putBITp (16, mPOPCODExCTR,
                                               getBIT (16, mADD_SMRK_NODExI)),
                                      POPCODE (0))),
                                 COREHALFWORD (mEDCL)),
                            xEQ (bitToFixed (
                                     (putBITp (16, mPOPCODExCTR,
                                               getBIT (16, mADD_SMRK_NODExI)),
                                      POPCODE (0))),
                                 COREHALFWORD (mNOP)))))))
              // DO; (1095)
              {
              rs1s2s1:;
                // IF VAC_OPERAND(I) THEN (1096)
                if (1
                    & (xAND (
                        getFIXED (mOPR + 4 * COREHALFWORD (mADD_SMRK_NODExI)),
                        xEQ (bitToFixed (
                                 (putBITp (16, mTYPE_BITSxCTR,
                                           getBIT (16, mADD_SMRK_NODExI)),
                                  TYPE_BITS (0))),
                             COREHALFWORD (mVAC)))))
                  // SMRK_NODE(CELL) = CHANGE_VAC(OPR(I)); (1097)
                  {
                    int32_t numberRHS = (int32_t)((
                        putFIXED (
                            mADD_SMRK_NODExCHANGE_VACxCELL,
                            getFIXED (mOPR
                                      + 4 * COREHALFWORD (mADD_SMRK_NODExI))),
                        ADD_SMRK_NODExCHANGE_VAC (0)));
                    putFIXED (getFIXED (mADD_SMRK_NODExSMRK_NODE)
                                  + 4 * (COREHALFWORD (mADD_SMRK_NODExCELL)),
                              numberRHS);
                  }
                // ELSE (1098)
                else
                  // SMRK_NODE(CELL) = OPR(I); (1099)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (
                        mOPR + 4 * COREHALFWORD (mADD_SMRK_NODExI)));
                    putFIXED (getFIXED (mADD_SMRK_NODExSMRK_NODE)
                                  + 4 * (COREHALFWORD (mADD_SMRK_NODExCELL)),
                              numberRHS);
                  }
                // IF HAVE_SYT_PTR(I) THEN (1100)
                if (1
                    & (xAND (
                        getFIXED (mOPR + 4 * COREHALFWORD (mADD_SMRK_NODExI)),
                        xEQ (bitToFixed (
                                 (putBITp (16, mTYPE_BITSxCTR,
                                           getBIT (16, mADD_SMRK_NODExI)),
                                  TYPE_BITS (0))),
                             COREHALFWORD (mSYT)))))
                  // DO; (1101)
                  {
                  rs1s2s1s1:;
                    // BLOCK_SYT# = SHR(OPR(I), 16); (1102)
                    {
                      int32_t numberRHS = (int32_t)(SHR (
                          getFIXED (mOPR
                                    + 4 * COREHALFWORD (mADD_SMRK_NODExI)),
                          16));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mADD_SMRK_NODExBLOCK_SYTp, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    // IF SYT_TYPE(BLOCK_SYT#) = IND_CALL_LAB THEN (1103)
                    if (1
                        & (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                                       + 34
                                             * (COREHALFWORD (
                                                 mADD_SMRK_NODExBLOCK_SYTp))
                                       + 32 + 1 * (0)),
                                COREHALFWORD (mIND_CALL_LAB))))
                      // DO; (1104)
                      {
                      rs1s2s1s1s1:;
                        // BLOCK_SYT# = INDIRECT(BLOCK_SYT#); (1105)
                        {
                          descriptor_t *bitRHS
                              = (putBITp (
                                     16, mINDIRECTxOP,
                                     getBIT (16, mADD_SMRK_NODExBLOCK_SYTp)),
                                 INDIRECT (0));
                          putBIT (16, mADD_SMRK_NODExBLOCK_SYTp, bitRHS);
                          bitRHS->inUse = 0;
                        }
                        // SMRK_NODE(CELL) = SHL(BLOCK_SYT#, 16) |(OPR(I) &
                        // 65535); (1106)
                        {
                          int32_t numberRHS = (int32_t)(xOR (
                              SHL (COREHALFWORD (mADD_SMRK_NODExBLOCK_SYTp),
                                   16),
                              xAND (getFIXED (
                                        mOPR
                                        + 4 * COREHALFWORD (mADD_SMRK_NODExI)),
                                    65535)));
                          putFIXED (
                              getFIXED (mADD_SMRK_NODExSMRK_NODE)
                                  + 4 * (COREHALFWORD (mADD_SMRK_NODExCELL)),
                              numberRHS);
                        }
                      es1s2s1s1s1:;
                      } // End of DO block
                  es1s2s1s1:;
                  } // End of DO block
                // IF ~OPR(I) THEN (1107)
                if (1
                    & (xNOT (getFIXED (
                        mOPR + 4 * COREHALFWORD (mADD_SMRK_NODExI)))))
                  // FINAL_OP = #CELLS+CELL_COUNT+CELL; (1108)
                  {
                    int32_t numberRHS = (int32_t)(xadd (
                        xadd (COREHALFWORD (mpCELLS),
                              COREHALFWORD (mADD_SMRK_NODExCELL_COUNT)),
                        COREHALFWORD (mADD_SMRK_NODExCELL)));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mFINAL_OP, bitRHS);
                    bitRHS->inUse = 0;
                  }
                // CELL = CELL+1; (1109)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (mADD_SMRK_NODExCELL), 1));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mADD_SMRK_NODExCELL, bitRHS);
                  bitRHS->inUse = 0;
                }
              es1s2s1:;
              } // End of DO block
            // ELSE (1110)
            else
              // VAC_START = VAC_START+1; (1111)
              {
                int32_t numberRHS
                    = (int32_t)(xadd (COREHALFWORD (mVAC_START), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mVAC_START, bitRHS);
                bitRHS->inUse = 0;
              }
          }
      } // End of DO for-loop block
      // CALL PUSH_NODE; (1112)
      ADD_SMRK_NODExPUSH_NODE (0);
      // CELL_COUNT = CELL_COUNT+CELL; (1113)
      {
        int32_t numberRHS
            = (int32_t)(xadd (COREHALFWORD (mADD_SMRK_NODExCELL_COUNT),
                              COREHALFWORD (mADD_SMRK_NODExCELL)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mADD_SMRK_NODExCELL_COUNT, bitRHS);
        bitRHS->inUse = 0;
      }
      // NEW_START = LIMIT+1; (1114)
      {
        int32_t numberRHS
            = (int32_t)(xadd (COREHALFWORD (mADD_SMRK_NODExLIMIT), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mADD_SMRK_NODExNEW_START, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // #CELLS = #CELLS+CELL_COUNT; (1115)
  {
    int32_t numberRHS = (int32_t)(xadd (
        COREHALFWORD (mpCELLS), COREHALFWORD (mADD_SMRK_NODExCELL_COUNT)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mpCELLS, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
