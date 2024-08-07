/*
  File PTR_LOCATExPAGING_STRATEGY.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
PTR_LOCATExPAGING_STRATEGY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PTR_LOCATExPAGING_STRATEGY");
  // CUR_NDX = -1; (771)
  {
    int32_t numberRHS = (int32_t)(-1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPTR_LOCATExCUR_NDX, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO I = 0 TO VMEM_MAX_PAGE; (772)
  {
    int32_t from16, to16, by16;
    from16 = 0;
    to16 = bitToFixed (getBIT (16, mVMEM_MAX_PAGE));
    by16 = 1;
    for (putBIT (16, mPTR_LOCATExI, fixedToBit (16, from16));
         bitToFixed (getBIT (16, mPTR_LOCATExI)) <= to16; putBIT (
             16, mPTR_LOCATExI,
             fixedToBit (16, bitToFixed (getBIT (16, mPTR_LOCATExI)) + by16)))
      {
        // IF (VMEM_PAD_DISP(I) &  16383) = 0 THEN (773)
        if (1
            & (xEQ (xAND (COREHALFWORD (mVMEM_PAD_DISP
                                        + 2 * COREHALFWORD (mPTR_LOCATExI)),
                          16383),
                    0)))
          // DO; (774)
          {
          rs1s1:;
            // IF CUR_NDX < 0 THEN (775)
            if (1 & (xLT (COREHALFWORD (mPTR_LOCATExCUR_NDX), 0)))
              // DO; (776)
              {
              rs1s1s1:;
                // CUR_NDX=I; (777)
                {
                  descriptor_t *bitRHS = getBIT (16, mPTR_LOCATExI);
                  putBIT (16, mPTR_LOCATExCUR_NDX, bitRHS);
                  bitRHS->inUse = 0;
                }
                // PREV_CNT=VMEM_PAD_CNT(I); (778)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      mVMEM_PAD_CNT + 4 * COREHALFWORD (mPTR_LOCATExI)));
                  putFIXED (mPTR_LOCATExPREV_CNT, numberRHS);
                }
              es1s1s1:;
              } // End of DO block
            // ELSE (779)
            else
              // IF (VMEM_PAD_CNT(I) < PREV_CNT) THEN (780)
              if (1
                  & (xLT (getFIXED (mVMEM_PAD_CNT
                                    + 4 * COREHALFWORD (mPTR_LOCATExI)),
                          getFIXED (mPTR_LOCATExPREV_CNT))))
                // DO; (781)
                {
                rs1s1s2:;
                  // CUR_NDX=I; (782)
                  {
                    descriptor_t *bitRHS = getBIT (16, mPTR_LOCATExI);
                    putBIT (16, mPTR_LOCATExCUR_NDX, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // PREV_CNT=VMEM_PAD_CNT(I); (783)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (
                        mVMEM_PAD_CNT + 4 * COREHALFWORD (mPTR_LOCATExI)));
                    putFIXED (mPTR_LOCATExPREV_CNT, numberRHS);
                  }
                es1s1s2:;
                } // End of DO block
          es1s1:;
          } // End of DO block
      }
  } // End of DO for-loop block
  // IF CUR_NDX < 0 THEN (784)
  if (1 & (xLT (COREHALFWORD (mPTR_LOCATExCUR_NDX), 0)))
    // DO; (785)
    {
    rs2:;
      // OUTPUT = '*** VIRTUAL MEMORY PAGING AREA DEPLETED ***'; (786)
      {
        descriptor_t *stringRHS;
        stringRHS = cToDescriptor (
            NULL, "*** VIRTUAL MEMORY PAGING AREA DEPLETED ***");
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // CALL EXIT; (787)
      EXIT ();
    es2:;
    } // End of DO block
  // PAGE_TMP = VMEM_PAD_PAGE(CUR_NDX); (788)
  {
    descriptor_t *bitRHS
        = getBIT (16, mVMEM_PAD_PAGE + 2 * COREHALFWORD (mPTR_LOCATExCUR_NDX));
    putBIT (16, mPTR_LOCATExPAGE_TMP, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF PAGE_TMP ~= -1 THEN (789)
  if (1 & (xNEQ (COREHALFWORD (mPTR_LOCATExPAGE_TMP), -1)))
    // DO; (790)
    {
    rs3:;
      // VMEM_PAGE_TO_NDX(PAGE_TMP) = -1; (791)
      {
        int32_t numberRHS = (int32_t)(-1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16,
                mVMEM_PAGE_TO_NDX + 2 * (COREHALFWORD (mPTR_LOCATExPAGE_TMP)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // IF PAGE_TMP = VMEM_LOOK_AHEAD_PAGE THEN (792)
      if (1
          & (xEQ (COREHALFWORD (mPTR_LOCATExPAGE_TMP),
                  COREHALFWORD (mVMEM_LOOK_AHEAD_PAGE))))
        // DO; (793)
        {
        rs3s1:;
          // CALL MONITOR(31,0,-1); (794)
          MONITOR31 (0, -1);
          // VMEM_LOOK_AHEAD_PAGE = -1; (795)
          {
            int32_t numberRHS = (int32_t)(-1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mVMEM_LOOK_AHEAD_PAGE, bitRHS);
            bitRHS->inUse = 0;
          }
        es3s1:;
        } // End of DO block
    es3:;
    } // End of DO block
  // IF (VMEM_PAD_DISP(CUR_NDX)& 16384) ~= 0 THEN (796)
  if (1
      & (xNEQ (xAND (COREHALFWORD (mVMEM_PAD_DISP
                                   + 2 * COREHALFWORD (mPTR_LOCATExCUR_NDX)),
                     16384),
               0)))
    // DO; (797)
    {
    rs4:;
      // IF VMEM_LOOK_AHEAD_PAGE >= 0 THEN (798)
      if (1 & (xGE (COREHALFWORD (mVMEM_LOOK_AHEAD_PAGE), 0)))
        // DO; (799)
        {
        rs4s1:;
          // CALL MONITOR(31,0,-1); (800)
          MONITOR31 (0, -1);
          // VMEM_LOOK_AHEAD_PAGE = -1; (801)
          {
            int32_t numberRHS = (int32_t)(-1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mVMEM_LOOK_AHEAD_PAGE, bitRHS);
            bitRHS->inUse = 0;
          }
        es4s1:;
        } // End of DO block
      // COREWORD(ADDR(VMEM_PAGE)) = VMEM_PAD_ADDR(CUR_NDX); (802)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            mVMEM_PAD_ADDR + 4 * COREHALFWORD (mPTR_LOCATExCUR_NDX)));
        COREWORD2 (ADDR ("PTR_LOCATExVMEM_PAGE", 0x80000000, NULL, 0),
                   numberRHS);
      }
      // FILE(VMEM_FILE#,PAGE_TMP) = VMEM_PAGE; (803)
      {
        lFILE (6, COREHALFWORD (mPTR_LOCATExPAGE_TMP),
               ADDR ("PTR_LOCATExVMEM_PAGE", 0, NULL, 0));
      }
      // VMEM_WRITE_CNT = VMEM_WRITE_CNT + 1; (804)
      {
        int32_t numberRHS = (int32_t)(xadd (getFIXED (mVMEM_WRITE_CNT), 1));
        putFIXED (mVMEM_WRITE_CNT, numberRHS);
      }
    es4:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
