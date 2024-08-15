/*
  File TERMINATE.c generated by XCOM-I, 2024-08-09 12:41:33.
*/

#include "runtimeC.h"

int32_t
TERMINATE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "TERMINATE");
  // TEMPSPACE, TMP = 0; (15991)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mTEMPSPACE, numberRHS);
    putFIXED (mTMP, numberRHS);
  }
  // STACKSPACE, MAXTEMP(PROGPOINT) = (MAXTEMP(PROGPOINT)+3) &  16777212;
  // (15992)
  {
    int32_t numberRHS = (int32_t)(xAND (
        xadd (getFIXED (mMAXTEMP + 4 * COREHALFWORD (mPROGPOINT)), 3),
        16777212));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mSTACKSPACE, bitRHS);
    putFIXED (mMAXTEMP + 4 * (COREHALFWORD (mPROGPOINT)), numberRHS);
    bitRHS->inUse = 0;
  }
  // DO OP1 = PROGPOINT+1 TO PROCLIMIT; (15993)
  {
    int32_t from149, to149, by149;
    from149 = xadd (COREHALFWORD (mPROGPOINT), 1);
    to149 = bitToFixed (getBIT (16, mPROCLIMIT));
    by149 = 1;
    for (putBIT (16, mOP1, fixedToBit (16, from149));
         bitToFixed (getBIT (16, mOP1)) <= to149;
         putBIT (16, mOP1,
                 fixedToBit (16, bitToFixed (getBIT (16, mOP1)) + by149)))
      {
        // MAXTEMP(OP1) = (MAXTEMP(OP1)+3) &  16777212; (15994)
        {
          int32_t numberRHS = (int32_t)(xAND (
              xadd (getFIXED (mMAXTEMP + 4 * COREHALFWORD (mOP1)), 3),
              16777212));
          putFIXED (mMAXTEMP + 4 * (COREHALFWORD (mOP1)), numberRHS);
        }
        // IF SYT_TYPE(PROC_LEVEL(OP1)) >= TASK_LABEL THEN (15995)
        if (1
            & (xGE (BYTE0 (getFIXED (mSYM_TAB)
                           + 34
                                 * (COREHALFWORD (mPROC_LEVEL
                                                  + 2 * COREHALFWORD (mOP1)))
                           + 32 + 1 * (0)),
                    BYTE0 (mTASK_LABEL))))
          // STACKSPACE(SYT_PARM(PROC_LEVEL(OP1))) = MAXTEMP(OP1); (15996)
          {
            int32_t numberRHS
                = (int32_t)(getFIXED (mMAXTEMP + 4 * COREHALFWORD (mOP1)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (
                16,
                mSTACKSPACE
                    + 2
                          * (COREHALFWORD (
                              getFIXED (mP2SYMS)
                              + 12
                                    * (COREHALFWORD (
                                        mPROC_LEVEL + 2 * COREHALFWORD (mOP1)))
                              + 8 + 2 * (0))),
                bitRHS);
            bitRHS->inUse = 0;
          }
        // ELSE (15997)
        else
          // TMP = TMP + MAXTEMP(OP1); (15998)
          {
            int32_t numberRHS = (int32_t)(xadd (
                getFIXED (mTMP),
                getFIXED (mMAXTEMP + 4 * COREHALFWORD (mOP1))));
            putFIXED (mTMP, numberRHS);
          }
      }
  } // End of DO for-loop block
  // DO OP1 = 0 TO TASK#; (15999)
  {
    int32_t from150, to150, by150;
    from150 = 0;
    to150 = bitToFixed (getBIT (16, mTASKp));
    by150 = 1;
    for (putBIT (16, mOP1, fixedToBit (16, from150));
         bitToFixed (getBIT (16, mOP1)) <= to150;
         putBIT (16, mOP1,
                 fixedToBit (16, bitToFixed (getBIT (16, mOP1)) + by150)))
      {
        // STACKSPACE(OP1) = STACKSPACE(OP1) + TMP + 1024; (16000)
        {
          int32_t numberRHS = (int32_t)(xadd (
              xadd (COREHALFWORD (mSTACKSPACE + 2 * COREHALFWORD (mOP1)),
                    getFIXED (mTMP)),
              1024));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mSTACKSPACE + 2 * (COREHALFWORD (mOP1)), bitRHS);
          bitRHS->inUse = 0;
        }
        // TEMPSPACE = TEMPSPACE + STACKSPACE(OP1); (16001)
        {
          int32_t numberRHS = (int32_t)(xadd (
              getFIXED (mTEMPSPACE),
              COREHALFWORD (mSTACKSPACE + 2 * COREHALFWORD (mOP1))));
          putFIXED (mTEMPSPACE, numberRHS);
        }
      }
  } // End of DO for-loop block
  // CALL GENERATE_CONSTANTS; (16002)
  GENERATE_CONSTANTS (0);
  // CALL EMITC(CODE_END, 0); (16003)
  {
    putBITp (16, mEMITCxTYPE, getBIT (8, mCODE_END));
    putBITp (16, mEMITCxINST, fixedToBit (32, (int32_t)(0)));
    EMITC (0);
  }
  // CALL OBJECT_CONDENSER; (16004)
  OBJECT_CONDENSER (0);
  // DATA_HWM,REMOTE_HWM=0; (16005)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mCOMM + 4 * (23), numberRHS);
    putFIXED (mCOMM + 4 * (24), numberRHS);
  }
  // RLD_POS_HEAD(PROGPOINT), ORIGIN(PROGPOINT) = 0; (16006)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLASTBASE + 2 * (COREHALFWORD (mPROGPOINT)), bitRHS);
    putFIXED (mORIGIN + 4 * (COREHALFWORD (mPROGPOINT)), numberRHS);
    bitRHS->inUse = 0;
  }
  // WORKSEG(PROGPOINT) = 0; (16007)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mWORKSEG + 4 * (COREHALFWORD (mPROGPOINT)), numberRHS);
  }
  // IF PROGPOINT ~= DATABASE THEN (16008)
  if (1 & (xNEQ (COREHALFWORD (mPROGPOINT), COREHALFWORD (mDATABASE))))
    // PROGCODE = LOCCTR(PROGPOINT); (16009)
    {
      int32_t numberRHS
          = (int32_t)(getFIXED (mLOCCTR + 4 * COREHALFWORD (mPROGPOINT)));
      putFIXED (mPROGCODE, numberRHS);
    }
  // DO OP1 = PROGPOINT+1 TO DATABASE-1; (16010)
  {
    int32_t from151, to151, by151;
    from151 = xadd (COREHALFWORD (mPROGPOINT), 1);
    to151 = xsubtract (COREHALFWORD (mDATABASE), 1);
    by151 = 1;
    for (putBIT (16, mOP1, fixedToBit (16, from151));
         bitToFixed (getBIT (16, mOP1)) <= to151;
         putBIT (16, mOP1,
                 fixedToBit (16, bitToFixed (getBIT (16, mOP1)) + by151)))
      {
        // RLD_POS_HEAD(OP1), ORIGIN(OP1) = 0; (16011)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mLASTBASE + 2 * (COREHALFWORD (mOP1)), bitRHS);
          putFIXED (mORIGIN + 4 * (COREHALFWORD (mOP1)), numberRHS);
          bitRHS->inUse = 0;
        }
        // WORKSEG(OP1) = ORIGIN(OP1); (16012)
        {
          int32_t numberRHS
              = (int32_t)(getFIXED (mORIGIN + 4 * COREHALFWORD (mOP1)));
          putFIXED (mWORKSEG + 4 * (COREHALFWORD (mOP1)), numberRHS);
        }
        // PROGCODE = PROGCODE + LOCCTR(OP1); (16013)
        {
          int32_t numberRHS
              = (int32_t)(xadd (getFIXED (mPROGCODE),
                                getFIXED (mLOCCTR + 4 * COREHALFWORD (mOP1))));
          putFIXED (mPROGCODE, numberRHS);
        }
      }
  } // End of DO for-loop block
  // RLD_POS_HEAD(DATABASE) = 0; (16014)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLASTBASE + 2 * (COREHALFWORD (mDATABASE)), bitRHS);
    bitRHS->inUse = 0;
  }
  // WORKSEG(DATABASE) = 0; (16015)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mWORKSEG + 4 * (COREHALFWORD (mDATABASE)), numberRHS);
  }
  // LOCCTR(DATABASE) = PROGDATA; (16016)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mPROGDATA));
    putFIXED (mLOCCTR + 4 * (COREHALFWORD (mDATABASE)), numberRHS);
  }
  // LOCCTR(REMOTE_LEVEL) = PROGDATA(1); (16017)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mPROGDATA + 4 * 1));
    putFIXED (mLOCCTR + 4 * (BYTE0 (mREMOTE_LEVEL)), numberRHS);
  }
  // CURRENT_ESDID, WORKSEG = 0; (16018)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mCURRENT_ESDID, numberRHS);
    putFIXED (mWORKSEG, numberRHS);
  }
  // CALL OBJECT_GENERATOR; (16019)
  OBJECT_GENERATOR (0);
  // CALL EMIT_ADDRS(0); (16020)
  {
    putBITp (16, mEMIT_ADDRSxSTMT_NO, fixedToBit (32, (int32_t)(0)));
    EMIT_ADDRS (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}