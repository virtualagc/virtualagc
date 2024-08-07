/*
  File P3_PTR_LOCATE.c generated by XCOM-I, 2024-08-08 04:33:10.
*/

#include "runtimeC.h"

int32_t
P3_PTR_LOCATE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "P3_PTR_LOCATE");
  // PAGE = SHR(PTR,16) &  65535; (1162)
  {
    int32_t numberRHS
        = (int32_t)(xAND (SHR (getFIXED (mP3_PTR_LOCATExPTR), 16), 65535));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mP3_PTR_LOCATExPAGE, bitRHS);
    bitRHS->inUse = 0;
  }
  // OFFSET = PTR &  65535; (1163)
  {
    int32_t numberRHS = (int32_t)(xAND (getFIXED (mP3_PTR_LOCATExPTR), 65535));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mP3_PTR_LOCATExOFFSET, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (PAGE < 0) | (PAGE > LAST_PAGE + 1) | (OFFSET < 0) | (OFFSET >
  // PAGE_SIZE - 1) THEN (1164)
  if (1
      & (xOR (xOR (xOR (xLT (COREHALFWORD (mP3_PTR_LOCATExPAGE), 0),
                        xGT (COREHALFWORD (mP3_PTR_LOCATExPAGE),
                             xadd (COREHALFWORD (mLAST_PAGE), 1))),
                   xLT (COREHALFWORD (mP3_PTR_LOCATExOFFSET), 0)),
              xGT (COREHALFWORD (mP3_PTR_LOCATExOFFSET), 1679))))
    // DO; (1165)
    {
    rs1:;
      // TS = HEX8(PTR); (1166)
      {
        descriptor_t *stringRHS;
        stringRHS
            = (putFIXED (mHEX8xHVAL, getFIXED (mP3_PTR_LOCATExPTR)), HEX8 (0));
        putCHARACTER (mP3_PTR_LOCATExTS, stringRHS);
        stringRHS->inUse = 0;
      }
      // OUTPUT = X1; (1167)
      {
        descriptor_t *stringRHS;
        stringRHS = getCHARACTER (mX1);
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // OUTPUT = P3ERR || 'BAD PTR (' || TS || ') DETECTED BY P3_PTR_LOCATE
      // ROUTINE ***'; (1168)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (
            xsCAT (xsCAT (getCHARACTER (mP3ERR),
                          cToDescriptor (NULL, "BAD PTR (")),
                   getCHARACTER (mP3_PTR_LOCATExTS)),
            cToDescriptor (NULL, ") DETECTED BY P3_PTR_LOCATE ROUTINE ***"));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // GO TO PHASE3_ERROR; (1169)
      {
        resetAllReentryGuards ();
        longjmp (jbPHASE3_ERROR, 1);
      }
    es1:;
    } // End of DO block
  // LOC_CNT = LOC_CNT + 1; (1170)
  {
    int32_t numberRHS = (int32_t)(xadd (getFIXED (mLOC_CNT), 1));
    putFIXED (mLOC_CNT, numberRHS);
  }
  // IF OLD_NDX >= 0 THEN (1171)
  if (1 & (xGE (COREHALFWORD (mOLD_NDX), 0)))
    // PAD_DISP(OLD_NDX) = PAD_DISP(OLD_NDX) - 1; (1172)
    {
      int32_t numberRHS = (int32_t)(xsubtract (
          COREHALFWORD (mPAD_DISP + 2 * COREHALFWORD (mOLD_NDX)), 1));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mPAD_DISP + 2 * (COREHALFWORD (mOLD_NDX)), bitRHS);
      bitRHS->inUse = 0;
    }
  // IF PAGE > LAST_PAGE THEN (1173)
  if (1
      & (xGT (COREHALFWORD (mP3_PTR_LOCATExPAGE), COREHALFWORD (mLAST_PAGE))))
    // DO; (1174)
    {
    rs2:;
      // LAST_PAGE = LAST_PAGE + 1; (1175)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mLAST_PAGE), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mLAST_PAGE, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF LAST_PAGE <= MAX_PAGE THEN (1176)
      if (1 & (xLE (COREHALFWORD (mLAST_PAGE), COREHALFWORD (mMAX_PAGE))))
        // DO; (1177)
        {
        rs2s1:;
          // CUR_NDX = LAST_PAGE; (1178)
          {
            descriptor_t *bitRHS = getBIT (16, mLAST_PAGE);
            putBIT (16, mP3_PTR_LOCATExCUR_NDX, bitRHS);
            bitRHS->inUse = 0;
          }
        es2s1:;
        } // End of DO block
      // ELSE (1179)
      else
        // DO; (1180)
        {
        rs2s2:;
          // CUR_NDX = NEW_NDX; (1181)
          {
            descriptor_t *bitRHS = getBIT (16, mNEW_NDX);
            putBIT (16, mP3_PTR_LOCATExCUR_NDX, bitRHS);
            bitRHS->inUse = 0;
          }
          // PAGE_TO_NDX(PAD_PAGE(CUR_NDX)) = -1; (1182)
          {
            int32_t numberRHS = (int32_t)(-1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (
                16,
                mPAGE_TO_NDX
                    + 2
                          * (COREHALFWORD (
                              mPAD_PAGE
                              + 2 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX))),
                bitRHS);
            bitRHS->inUse = 0;
          }
        es2s2:;
        } // End of DO block
      // PAGE_TO_NDX(PAGE) = CUR_NDX; (1183)
      {
        descriptor_t *bitRHS = getBIT (16, mP3_PTR_LOCATExCUR_NDX);
        putBIT (16, mPAGE_TO_NDX + 2 * (COREHALFWORD (mP3_PTR_LOCATExPAGE)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // PAD_PAGE(CUR_NDX) = LAST_PAGE; (1184)
      {
        descriptor_t *bitRHS = getBIT (16, mLAST_PAGE);
        putBIT (16, mPAD_PAGE + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // PAD_DISP(CUR_NDX) = 0; (1185)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPAD_DISP + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // PAD_CNT(CUR_NDX) = LOC_CNT; (1186)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mLOC_CNT));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPAD_CNT + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // FLAGS = FLAGS|MODF; (1187)
      {
        int32_t numberRHS
            = (int32_t)(xOR (BYTE0 (mP3_PTR_LOCATExFLAGS), BYTE0 (mMODF)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mP3_PTR_LOCATExFLAGS, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL ZERO_CORE(PAD_ADDR(CUR_NDX),PAGE_SIZE); (1188)
      {
        putFIXED (
            mZERO_CORExCORE_ADDR,
            getFIXED (mPAD_ADDR + 4 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)));
        putFIXED (mZERO_CORExCOUNT, 1680);
        ZERO_CORE (0);
      }
      // COREWORD(ADDR(PAGE_TEMP1)) = PAD_ADDR(CUR_NDX); (1189)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            mPAD_ADDR + 4 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)));
        COREWORD2 (ADDR ("P3_PTR_LOCATExPAGE_TEMP1", 0x80000000, NULL, 0),
                   numberRHS);
      }
      // PAGE_TEMP1(0) = PAGE_SIZE; (1190)
      {
        int32_t numberRHS = (int32_t)(1680);
        putFIXED (getFIXED (mP3_PTR_LOCATExPAGE_TEMP1) + 4 * (0), numberRHS);
      }
      // PAGE_TEMP1(1) = SHL(LAST_PAGE + 1,16); (1191)
      {
        int32_t numberRHS
            = (int32_t)(SHL (xadd (COREHALFWORD (mLAST_PAGE), 1), 16));
        putFIXED (getFIXED (mP3_PTR_LOCATExPAGE_TEMP1) + 4 * (1), numberRHS);
      }
    es2:;
    } // End of DO block
  // ELSE (1192)
  else
    // DO; (1193)
    {
    rs3:;
      // CUR_NDX = PAGE_TO_NDX(PAGE); (1194)
      {
        descriptor_t *bitRHS = getBIT (
            16, mPAGE_TO_NDX + 2 * COREHALFWORD (mP3_PTR_LOCATExPAGE));
        putBIT (16, mP3_PTR_LOCATExCUR_NDX, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF CUR_NDX = -1 THEN (1195)
      if (1 & (xEQ (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX), -1)))
        // DO; (1196)
        {
        rs3s1:;
          // CUR_NDX = NEW_NDX; (1197)
          {
            descriptor_t *bitRHS = getBIT (16, mNEW_NDX);
            putBIT (16, mP3_PTR_LOCATExCUR_NDX, bitRHS);
            bitRHS->inUse = 0;
          }
          // PAGE_TO_NDX(PAD_PAGE(CUR_NDX)) = -1; (1198)
          {
            int32_t numberRHS = (int32_t)(-1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (
                16,
                mPAGE_TO_NDX
                    + 2
                          * (COREHALFWORD (
                              mPAD_PAGE
                              + 2 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX))),
                bitRHS);
            bitRHS->inUse = 0;
          }
          // PAGE_TO_NDX(PAGE) = CUR_NDX; (1199)
          {
            descriptor_t *bitRHS = getBIT (16, mP3_PTR_LOCATExCUR_NDX);
            putBIT (16,
                    mPAGE_TO_NDX + 2 * (COREHALFWORD (mP3_PTR_LOCATExPAGE)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // LREC# = PAGE_TO_LREC(PAGE); (1200)
          {
            descriptor_t *bitRHS = getBIT (
                16, mPAGE_TO_LREC + 2 * COREHALFWORD (mP3_PTR_LOCATExPAGE));
            putBIT (16, mP3_PTR_LOCATExLRECp, bitRHS);
            bitRHS->inUse = 0;
          }
          // COREWORD(ADDR(PAGE_TEMP)) = PAD_ADDR(CUR_NDX); (1201)
          {
            int32_t numberRHS = (int32_t)(getFIXED (
                mPAD_ADDR + 4 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)));
            COREWORD2 (ADDR ("P3_PTR_LOCATExPAGE_TEMP", 0x80000000, NULL, 0),
                       numberRHS);
          }
          // PAGE_TEMP = FILE(5,LREC#); (1202)
          {
            rFILE (ADDR ("P3_PTR_LOCATExPAGE_TEMP", 0, NULL, 0), 5,
                   COREHALFWORD (mP3_PTR_LOCATExLRECp));
          }
          // PAD_PAGE(CUR_NDX) = PAGE; (1203)
          {
            descriptor_t *bitRHS = getBIT (16, mP3_PTR_LOCATExPAGE);
            putBIT (16,
                    mPAD_PAGE + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // PAD_DISP(CUR_NDX) = 0; (1204)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16,
                    mPAD_DISP + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // READ_CNT = READ_CNT + 1; (1205)
          {
            int32_t numberRHS = (int32_t)(xadd (getFIXED (mREAD_CNT), 1));
            putFIXED (mREAD_CNT, numberRHS);
          }
        es3s1:;
        } // End of DO block
      // PAD_CNT(CUR_NDX) = LOC_CNT; (1206)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mLOC_CNT));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPAD_CNT + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
                bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // PAD_DISP(CUR_NDX) = PAD_DISP(CUR_NDX) + 1; (1207)
  {
    int32_t numberRHS = (int32_t)(xadd (
        COREHALFWORD (mPAD_DISP + 2 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
        1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPAD_DISP + 2 * (COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // OLD_NDX = CUR_NDX; (1208)
  {
    descriptor_t *bitRHS = getBIT (16, mP3_PTR_LOCATExCUR_NDX);
    putBIT (16, mOLD_NDX, bitRHS);
    bitRHS->inUse = 0;
  }
  // LOC_PTR = PTR; (1209)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mP3_PTR_LOCATExPTR));
    putFIXED (mLOC_PTR, numberRHS);
  }
  // LOC_ADDR = PAD_ADDR(CUR_NDX) + OFFSET; (1210)
  {
    int32_t numberRHS = (int32_t)(xadd (
        getFIXED (mPAD_ADDR + 4 * COREHALFWORD (mP3_PTR_LOCATExCUR_NDX)),
        COREHALFWORD (mP3_PTR_LOCATExOFFSET)));
    putFIXED (mLOC_ADDR, numberRHS);
  }
  // IF FLAGS ~= 0 THEN (1211)
  if (1 & (xNEQ (BYTE0 (mP3_PTR_LOCATExFLAGS), 0)))
    // CALL P3_DISP(FLAGS); (1212)
    {
      putBITp (8, mP3_DISPxFLAGS, getBIT (8, mP3_PTR_LOCATExFLAGS));
      P3_DISP (0);
    }
  // IF LAST_PAGE >= MAX_PAGE THEN (1213)
  if (1 & (xGE (COREHALFWORD (mLAST_PAGE), COREHALFWORD (mMAX_PAGE))))
    // CALL PAGING_STRATEGY; (1214)
    PAGING_STRATEGY (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
