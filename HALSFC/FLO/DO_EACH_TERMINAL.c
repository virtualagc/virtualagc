/*
  File DO_EACH_TERMINAL.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
DO_EACH_TERMINAL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DO_EACH_TERMINAL");
  // IF PROC_TRACE THEN (1974)
  if (1 & (bitToFixed (getBIT (8, mPROC_TRACE))))
    // OUTPUT='DO_EACH_TERMINAL'; (1975)
    {
      descriptor_t *stringRHS;
      stringRHS = cToDescriptor (NULL, "DO_EACH_TERMINAL");
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // DO WHILE TERM_LIST_HEAD ~= 0; (1976)
  while (1 & (xNEQ (getFIXED (mTERM_LIST_HEAD), 0)))
    {
      // CALL LOCATE(TERM_LIST_HEAD,ADDR(NODE_H),RESV); (1977)
      {
        putFIXED (mLOCATExPTR, getFIXED (mTERM_LIST_HEAD));
        putFIXED (mLOCATExBVAR,
                  ADDR ("DO_EACH_TERMINALxNODE_H", 0x80000000, NULL, 0));
        putBITp (8, mLOCATExFLAGS, getBIT (8, mRESV));
        LOCATE (0);
      }
      // OFFSET = NODE_H(0); (1978)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mDO_EACH_TERMINALxNODE_H) + 2 * 0);
        putBIT (16, mDO_EACH_TERMINALxOFFSET, bitRHS);
        bitRHS->inUse = 0;
      }
      // #SYTS = NODE_H(1); (1979)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mDO_EACH_TERMINALxNODE_H) + 2 * 1);
        putBIT (16, mDO_EACH_TERMINALxpSYTS, bitRHS);
        bitRHS->inUse = 0;
      }
      // SAVE_ADDR = VMEM_LOC_ADDR; (1980)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mVMEM_LOC_ADDR));
        putFIXED (mSAVE_ADDR, numberRHS);
      }
      // WORD_INX = 0; (1981)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mWORD_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL TRAVERSE_INIT_LIST(CTR,OFFSET); (1982)
      {
        putBITp (16, mTRAVERSE_INIT_LISTxSTRI_LOC,
                 getBIT (16, mDO_EACH_TERMINALxCTR));
        putBITp (16, mTRAVERSE_INIT_LISTxTERM_OFFSET,
                 getBIT (16, mDO_EACH_TERMINALxOFFSET));
        TRAVERSE_INIT_LIST (0);
      }
      // WORD_INX = WORD_INX + 1; (1983)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mWORD_INX), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mWORD_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // WORD_STACK(WORD_INX) = END_OF_LIST_OP; (1984)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mEND_OF_LIST_OP));
        putFIXED (mWORD_STACK + 4 * (COREHALFWORD (mWORD_INX)), numberRHS);
      }
      // INIT_WORD_START = SHR(#SYTS+5,1); (1985)
      {
        int32_t numberRHS = (int32_t)(SHR (
            xadd (COREHALFWORD (mDO_EACH_TERMINALxpSYTS), 5), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mINIT_WORD_START, bitRHS);
        bitRHS->inUse = 0;
      }
      // CELLSIZE = SHL(INIT_WORD_START + WORD_INX,2); (1986)
      {
        int32_t numberRHS = (int32_t)(SHL (
            xadd (COREHALFWORD (mINIT_WORD_START), COREHALFWORD (mWORD_INX)),
            2));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mCELLSIZE, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO WHILE CELLSIZE > SDF_PAGE_BYTES; (1987)
      while (1
             & (xGT (COREHALFWORD (mCELLSIZE),
                     COREHALFWORD (mDO_EACH_TERMINALxSDF_PAGE_BYTES))))
        {
          // CTR = WORD_INX - SDF_PAGE_WORDS + 1; (1988)
          {
            int32_t numberRHS = (int32_t)(xadd (
                xsubtract (COREHALFWORD (mWORD_INX),
                           COREHALFWORD (mDO_EACH_TERMINALxSDF_PAGE_WORDS)),
                1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mDO_EACH_TERMINALxCTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // J = 1; (1989)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mDO_EACH_TERMINALxJ, bitRHS);
            bitRHS->inUse = 0;
          }
          // DO WHILE J <= CTR; (1990)
          while (1
                 & (xLE (COREHALFWORD (mDO_EACH_TERMINALxJ),
                         COREHALFWORD (mDO_EACH_TERMINALxCTR))))
            {
              // DO CASE SHR(WORD_STACK(J),16); (1991)
              {
              rs1s1s1s1:
                switch (
                    SHR (getFIXED (mWORD_STACK
                                   + 4 * COREHALFWORD (mDO_EACH_TERMINALxJ)),
                         16))
                  {
                  case 0:
                    // J = J + 2; (1993)
                    {
                      int32_t numberRHS = (int32_t)(xadd (
                          COREHALFWORD (mDO_EACH_TERMINALxJ), 2));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mDO_EACH_TERMINALxJ, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    break;
                  case 1:
                    // J = J + 2; (1994)
                    {
                      int32_t numberRHS = (int32_t)(xadd (
                          COREHALFWORD (mDO_EACH_TERMINALxJ), 2));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mDO_EACH_TERMINALxJ, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    break;
                  case 2:
                    // J = J + 1; (1995)
                    {
                      int32_t numberRHS = (int32_t)(xadd (
                          COREHALFWORD (mDO_EACH_TERMINALxJ), 1));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mDO_EACH_TERMINALxJ, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    break;
                  case 3:
                    // J = J + 1; (1996)
                    {
                      int32_t numberRHS = (int32_t)(xadd (
                          COREHALFWORD (mDO_EACH_TERMINALxJ), 1));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mDO_EACH_TERMINALxJ, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    break;
                  }
              } // End of DO CASE block
            }   // End of DO WHILE block
          // CELLSIZE = SHL(WORD_INX-J+2,2); (1996)
          {
            int32_t numberRHS = (int32_t)(SHL (
                xadd (xsubtract (COREHALFWORD (mWORD_INX),
                                 COREHALFWORD (mDO_EACH_TERMINALxJ)),
                      2),
                2));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mCELLSIZE, bitRHS);
            bitRHS->inUse = 0;
          }
          // INIT_CELL = GET_CELL(CELLSIZE,ADDR(VMEM_F),MODF); (1997)
          {
            int32_t numberRHS = (int32_t)((
                putFIXED (mGET_CELLxCELL_SIZE, COREHALFWORD (mCELLSIZE)),
                putFIXED (mGET_CELLxBVAR,
                          ADDR ("VMEM_F", 0x80000000, NULL, 0)),
                putBITp (8, mGET_CELLxFLAGS, getBIT (8, mMODF)),
                GET_CELL (0)));
            putFIXED (mDO_EACH_TERMINALxINIT_CELL, numberRHS);
          }
          // VMEM_F(0) = SHL(CELLSIZE,16); (1998)
          {
            int32_t numberRHS = (int32_t)(SHL (COREHALFWORD (mCELLSIZE), 16));
            putFIXED (getFIXED (mVMEM_F) + 4 * (0), numberRHS);
          }
          // CALL MOVE(CELLSIZE-4,ADDR(WORD_STACK(J)),VMEM_LOC_ADDR+4); (1999)
          {
            putBITp (16, mMOVExLEGNTH,
                     fixedToBit (32, (int32_t)(xsubtract (
                                         COREHALFWORD (mCELLSIZE), 4))));
            putFIXED (mMOVExFROM, ADDR (NULL, 0, "WORD_STACK",
                                        COREHALFWORD (mDO_EACH_TERMINALxJ)));
            putFIXED (mMOVExINTO, xadd (getFIXED (mVMEM_LOC_ADDR), 4));
            MOVE (0);
          }
          // WORD_STACK(J) = END_OF_LIST_OP + 1; (2000)
          {
            int32_t numberRHS
                = (int32_t)(xadd (getFIXED (mEND_OF_LIST_OP), 1));
            putFIXED (mWORD_STACK + 4 * (COREHALFWORD (mDO_EACH_TERMINALxJ)),
                      numberRHS);
          }
          // WORD_INX = J+1; (2001)
          {
            int32_t numberRHS
                = (int32_t)(xadd (COREHALFWORD (mDO_EACH_TERMINALxJ), 1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mWORD_INX, bitRHS);
            bitRHS->inUse = 0;
          }
          // WORD_STACK(WORD_INX) = INIT_CELL; (2002)
          {
            int32_t numberRHS
                = (int32_t)(getFIXED (mDO_EACH_TERMINALxINIT_CELL));
            putFIXED (mWORD_STACK + 4 * (COREHALFWORD (mWORD_INX)), numberRHS);
          }
          // CELLSIZE = SHL(INIT_WORD_START + WORD_INX,2); (2003)
          {
            int32_t numberRHS
                = (int32_t)(SHL (xadd (COREHALFWORD (mINIT_WORD_START),
                                       COREHALFWORD (mWORD_INX)),
                                 2));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mCELLSIZE, bitRHS);
            bitRHS->inUse = 0;
          }
        } // End of DO WHILE block
      // INIT_CELL = GET_CELL(CELLSIZE,ADDR(VMEM_F),MODF); (2004)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (mGET_CELLxCELL_SIZE, COREHALFWORD (mCELLSIZE)),
            putFIXED (mGET_CELLxBVAR, ADDR ("VMEM_F", 0x80000000, NULL, 0)),
            putBITp (8, mGET_CELLxFLAGS, getBIT (8, mMODF)), GET_CELL (0)));
        putFIXED (mDO_EACH_TERMINALxINIT_CELL, numberRHS);
      }
      // CALL MOVE(SHL(INIT_WORD_START,2),SAVE_ADDR,VMEM_LOC_ADDR); (2005)
      {
        putBITp (16, mMOVExLEGNTH,
                 fixedToBit (
                     32, (int32_t)(SHL (COREHALFWORD (mINIT_WORD_START), 2))));
        putFIXED (mMOVExFROM, getFIXED (mSAVE_ADDR));
        putFIXED (mMOVExINTO, getFIXED (mVMEM_LOC_ADDR));
        MOVE (0);
      }
      // INIT_WORD_START = INIT_WORD_START - 1; (2006)
      {
        int32_t numberRHS
            = (int32_t)(xsubtract (COREHALFWORD (mINIT_WORD_START), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mINIT_WORD_START, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO J = 1 TO WORD_INX; (2007)
      {
        int32_t from46, to46, by46;
        from46 = 1;
        to46 = bitToFixed (getBIT (16, mWORD_INX));
        by46 = 1;
        for (putBIT (16, mDO_EACH_TERMINALxJ, fixedToBit (16, from46));
             bitToFixed (getBIT (16, mDO_EACH_TERMINALxJ)) <= to46; putBIT (
                 16, mDO_EACH_TERMINALxJ,
                 fixedToBit (16, bitToFixed (getBIT (16, mDO_EACH_TERMINALxJ))
                                     + by46)))
          {
            // VMEM_F(INIT_WORD_START + J) = WORD_STACK(J); (2008)
            {
              int32_t numberRHS = (int32_t)(getFIXED (
                  mWORD_STACK + 4 * COREHALFWORD (mDO_EACH_TERMINALxJ)));
              putFIXED (
                  getFIXED (mVMEM_F)
                      + 4
                            * (xadd (COREHALFWORD (mINIT_WORD_START),
                                     COREHALFWORD (mDO_EACH_TERMINALxJ))),
                  numberRHS);
            }
          }
      } // End of DO for-loop block
      // COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR; (2009)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mVMEM_LOC_ADDR));
        COREWORD2 (ADDR ("VMEM_H", 0x80000000, NULL, 0), numberRHS);
      }
      // VMEM_H(0) = CELLSIZE; (2010)
      {
        descriptor_t *bitRHS = getBIT (16, mCELLSIZE);
        putBIT (16, getFIXED (mVMEM_H) + 2 * (0), bitRHS);
        bitRHS->inUse = 0;
      }
      // VMEM_F(1) = INIT_LIST_HEAD; (2011)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mINIT_LIST_HEAD));
        putFIXED (getFIXED (mVMEM_F) + 4 * (1), numberRHS);
      }
      // INIT_LIST_HEAD = INIT_CELL; (2012)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mDO_EACH_TERMINALxINIT_CELL));
        putFIXED (mINIT_LIST_HEAD, numberRHS);
      }
      // CALL LOCATE(TERM_LIST_HEAD,ADDR(VMEM_F),RELS); (2013)
      {
        putFIXED (mLOCATExPTR, getFIXED (mTERM_LIST_HEAD));
        putFIXED (mLOCATExBVAR, ADDR ("VMEM_F", 0x80000000, NULL, 0));
        putBITp (8, mLOCATExFLAGS, getBIT (8, mRELS));
        LOCATE (0);
      }
      // TERM_LIST_HEAD = VMEM_F(1); (2014)
      {
        int32_t numberRHS = (int32_t)(getFIXED (getFIXED (mVMEM_F) + 4 * 1));
        putFIXED (mTERM_LIST_HEAD, numberRHS);
      }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
