/*
  File GENERATExSYT_COPIES.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExSYT_COPIES (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSYT_COPIES");
  // IF (COPY(PTR) + VMCOPY(PTR)) = 0 THEN (6207)
  if (1
      & (xEQ (
          xadd (COREHALFWORD (getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR))
                              + 26 + 2 * (0)),
                BYTE0 (getFIXED (mIND_STACK)
                       + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 67
                       + 1 * (0))),
          0)))
    // RETURN; (6208)
    {
      reentryGuard = 0;
      return 0;
    }
  // CPY = SET_DOPTRS(PTR, ~FLAG & 1) - (STRUCT_INX(PTR) & 1); (6209)
  {
    int32_t numberRHS = (int32_t)(xsubtract (
        bitToFixed (
            (putBITp (16, mGENERATExSET_DOPTRSxPTR,
                      getBIT (16, mGENERATExSYT_COPIESxPTR)),
             putBITp (
                 8, mGENERATExSET_DOPTRSxFLAG,
                 fixedToBit (
                     32, (int32_t)(xAND (
                             xNOT (BYTE0 (mGENERATExSYT_COPIESxFLAG)), 1)))),
             GENERATExSET_DOPTRS (0))),
        xAND (BYTE0 (getFIXED (mIND_STACK)
                     + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 66
                     + 1 * (0)),
              1)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExSYT_COPIESxCPY, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO I = 1 TO COPY(PTR); (6210)
  {
    int32_t from81, to81, by81;
    from81 = 1;
    to81 = bitToFixed (
        getBIT (16, getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 26
                        + 2 * (0)));
    by81 = 1;
    for (putBIT (16, mGENERATExSYT_COPIESxI, fixedToBit (16, from81));
         bitToFixed (getBIT (16, mGENERATExSYT_COPIESxI)) <= to81; putBIT (
             16, mGENERATExSYT_COPIESxI,
             fixedToBit (16, bitToFixed (getBIT (16, mGENERATExSYT_COPIESxI))
                                 + by81)))
      {
        // J=STACK#+I; (6211)
        {
          int32_t numberRHS = (int32_t)(xadd (
              COREHALFWORD (mSTACKp), COREHALFWORD (mGENERATExSYT_COPIESxI)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mGENERATExSYT_COPIESxJ, bitRHS);
          bitRHS->inUse = 0;
        }
        // IF SYT_TYPE(OP)=STRUCTURE  THEN (6212)
        if (1
            & (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                           + 34 * (COREHALFWORD (mGENERATExSYT_COPIESxOP)) + 32
                           + 1 * (0)),
                    BYTE0 (mSTRUCTURE))))
          // SUBRANGE(J)=AREASAVE; (6213)
          {
            int32_t numberRHS = (int32_t)(getFIXED (mAREASAVE));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16,
                    mGENERATExSUBRANGE
                        + 2 * (COREHALFWORD (mGENERATExSYT_COPIESxJ)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
        // ELSE (6214)
        else
          // SUBRANGE(J)=GETARRAYDIM(I,OP); (6215)
          {
            descriptor_t *bitRHS
                = (putBITp (8, mGETARRAYDIMxIX,
                            getBIT (16, mGENERATExSYT_COPIESxI)),
                   putBITp (16, mGETARRAYDIMxOP1,
                            getBIT (16, mGENERATExSYT_COPIESxOP)),
                   GETARRAYDIM (0));
            putBIT (16,
                    mGENERATExSUBRANGE
                        + 2 * (COREHALFWORD (mGENERATExSYT_COPIESxJ)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
        // SUBLIMIT(J-1) = SUBRANGE(J); (6216)
        {
          descriptor_t *bitRHS
              = getBIT (16, mGENERATExSUBRANGE
                                + 2 * COREHALFWORD (mGENERATExSYT_COPIESxJ));
          putBIT (
              16,
              mGENERATExSUBLIMIT
                  + 2 * (xsubtract (COREHALFWORD (mGENERATExSYT_COPIESxJ), 1)),
              bitRHS);
          bitRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // COPY(PTR) = COPY(PTR) + VMCOPY(PTR); (6217)
  {
    int32_t numberRHS = (int32_t)(xadd (
        COREHALFWORD (getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 26
                      + 2 * (0)),
        BYTE0 (getFIXED (mIND_STACK)
               + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 67
               + 1 * (0))));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 26
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // NESTED = VMCOPY(PTR) & DOPUSH(CALL_LEVEL); (6218)
  {
    int32_t numberRHS = (int32_t)(xAND (
        BYTE0 (getFIXED (mIND_STACK)
               + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 67
               + 1 * (0)),
        BYTE0 (mGENERATExDOPUSH + 1 * COREHALFWORD (mCALL_LEVEL))));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExSYT_COPIESxNESTED, bitRHS);
    bitRHS->inUse = 0;
  }
  // VMCOPY(PTR) = 0; (6219)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (8,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 67
                + 1 * (0),
            fixedToBit (8, numberRHS));
  }
  // IF FLAG~=0 THEN (6220)
  if (1 & (xNEQ (BYTE0 (mGENERATExSYT_COPIESxFLAG), 0)))
    // RETURN; (6221)
    {
      reentryGuard = 0;
      return 0;
    }
  // IF DOFORM(CALL_LEVEL) = 0 THEN (6222)
  if (1
      & (xEQ (COREHALFWORD (mGENERATExDOFORM + 2 * COREHALFWORD (mCALL_LEVEL)),
              0)))
    // IF CPY > 0 THEN (6223)
    if (1 & (xGT (COREHALFWORD (mGENERATExSYT_COPIESxCPY), 0)))
      // IF CPY < COPY(PTR) THEN (6224)
      if (1
          & (xLT (
              COREHALFWORD (mGENERATExSYT_COPIESxCPY),
              COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR))
                            + 26 + 2 * (0)))))
        // DO; (6225)
        {
        rs2:;
          // K = DOPTR(CALL_LEVEL) + (STRUCT_INX(PTR) & 1) - STACK#; (6226)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                xadd (
                    COREHALFWORD (mGENERATExDOPTR
                                  + 2 * COREHALFWORD (mCALL_LEVEL)),
                    xAND (
                        BYTE0 (getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR))
                               + 66 + 1 * (0)),
                        1)),
                COREHALFWORD (mSTACKp)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExSYT_COPIESxK, bitRHS);
            bitRHS->inUse = 0;
          }
          // DO I = STACK#+1 TO STACK#+CPY; (6227)
          {
            int32_t from82, to82, by82;
            from82 = xadd (COREHALFWORD (mSTACKp), 1);
            to82 = xadd (COREHALFWORD (mSTACKp),
                         COREHALFWORD (mGENERATExSYT_COPIESxCPY));
            by82 = 1;
            for (putBIT (16, mGENERATExSYT_COPIESxI, fixedToBit (16, from82));
                 bitToFixed (getBIT (16, mGENERATExSYT_COPIESxI)) <= to82;
                 putBIT (16, mGENERATExSYT_COPIESxI,
                         fixedToBit (16, bitToFixed (getBIT (
                                             16, mGENERATExSYT_COPIESxI))
                                             + by82)))
              {
                // IF DOFLAG(K+I) THEN (6228)
                if (1
                    & (bitToFixed (getBIT (
                        1, mGENERATExDOFLAG
                               + 1
                                     * xadd (
                                         COREHALFWORD (mGENERATExSYT_COPIESxK),
                                         COREHALFWORD (
                                             mGENERATExSYT_COPIESxI))))))
                  // DO; (6229)
                  {
                  rs2s1s1:;
                    // L = STACK#+COPY(PTR)-NESTED; (6230)
                    {
                      int32_t numberRHS = (int32_t)(xsubtract (
                          xadd (COREHALFWORD (mSTACKp),
                                COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExSYT_COPIESxPTR))
                                    + 26 + 2 * (0))),
                          BYTE0 (mGENERATExSYT_COPIESxNESTED)));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mGENERATExSYT_COPIESxL, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    // AREA = 0; (6231)
                    {
                      int32_t numberRHS = (int32_t)(0);
                      putFIXED (mAREA, numberRHS);
                    }
                    // DO J = I TO L; (6232)
                    {
                      int32_t from83, to83, by83;
                      from83
                          = bitToFixed (getBIT (16, mGENERATExSYT_COPIESxI));
                      to83 = bitToFixed (getBIT (16, mGENERATExSYT_COPIESxL));
                      by83 = 1;
                      for (putBIT (16, mGENERATExSYT_COPIESxJ,
                                   fixedToBit (16, from83));
                           bitToFixed (getBIT (16, mGENERATExSYT_COPIESxJ))
                           <= to83;
                           putBIT (
                               16, mGENERATExSYT_COPIESxJ,
                               fixedToBit (16, bitToFixed (getBIT (
                                                   16, mGENERATExSYT_COPIESxJ))
                                                   + by83)))
                        {
                          // IF J < L THEN (6233)
                          if (1
                              & (xLT (COREHALFWORD (mGENERATExSYT_COPIESxJ),
                                      COREHALFWORD (mGENERATExSYT_COPIESxL))))
                            // DO; (6234)
                            {
                            rs2s1s1s1s1:;
                              // SUBLIMIT(I-1) = SUBLIMIT(J) * SUBLIMIT(I-1);
                              // (6235)
                              {
                                int32_t numberRHS = (int32_t)(xmultiply (
                                    COREHALFWORD (
                                        mGENERATExSUBLIMIT
                                        + 2
                                              * COREHALFWORD (
                                                  mGENERATExSYT_COPIESxJ)),
                                    COREHALFWORD (
                                        mGENERATExSUBLIMIT
                                        + 2
                                              * xsubtract (
                                                  COREHALFWORD (
                                                      mGENERATExSYT_COPIESxI),
                                                  1))));
                                descriptor_t *bitRHS;
                                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                                putBIT (
                                    16,
                                    mGENERATExSUBLIMIT
                                        + 2
                                              * (xsubtract (
                                                  COREHALFWORD (
                                                      mGENERATExSYT_COPIESxI),
                                                  1)),
                                    bitRHS);
                                bitRHS->inUse = 0;
                              }
                              // AREA = (AREA+1) * SUBLIMIT(J); (6236)
                              {
                                int32_t numberRHS = (int32_t)(xmultiply (
                                    xadd (getFIXED (mAREA), 1),
                                    COREHALFWORD (
                                        mGENERATExSUBLIMIT
                                        + 2
                                              * COREHALFWORD (
                                                  mGENERATExSYT_COPIESxJ))));
                                putFIXED (mAREA, numberRHS);
                              }
                            es2s1s1s1s1:;
                            } // End of DO block
                          // ELSE (6237)
                          else
                            // AREA = AREA * SUBLIMIT(J); (6238)
                            {
                              int32_t numberRHS = (int32_t)(xmultiply (
                                  getFIXED (mAREA),
                                  COREHALFWORD (
                                      mGENERATExSUBLIMIT
                                      + 2
                                            * COREHALFWORD (
                                                mGENERATExSYT_COPIESxJ))));
                              putFIXED (mAREA, numberRHS);
                            }
                        }
                    } // End of DO for-loop block
                    // SUBLIMIT(I) = SUBLIMIT(L); (6239)
                    {
                      descriptor_t *bitRHS = getBIT (
                          16, mGENERATExSUBLIMIT
                                  + 2 * COREHALFWORD (mGENERATExSYT_COPIESxL));
                      putBIT (
                          16,
                          mGENERATExSUBLIMIT
                              + 2 * (COREHALFWORD (mGENERATExSYT_COPIESxI)),
                          bitRHS);
                      bitRHS->inUse = 0;
                    }
                    // IF NESTED THEN (6240)
                    if (1
                        & (bitToFixed (
                            getBIT (1, mGENERATExSYT_COPIESxNESTED))))
                      // SUBLIMIT(I+1) = SUBLIMIT(L+1); (6241)
                      {
                        descriptor_t *bitRHS = getBIT (
                            16, mGENERATExSUBLIMIT
                                    + 2
                                          * xadd (COREHALFWORD (
                                                      mGENERATExSYT_COPIESxL),
                                                  1));
                        putBIT (16,
                                mGENERATExSUBLIMIT
                                    + 2
                                          * (xadd (COREHALFWORD (
                                                       mGENERATExSYT_COPIESxI),
                                                   1)),
                                bitRHS);
                        bitRHS->inUse = 0;
                      }
                    // AREA = AREA * BIGHTS(TYPE(PTR)); (6242)
                    {
                      int32_t numberRHS = (int32_t)(xmultiply (
                          getFIXED (mAREA),
                          BYTE0 (mBIGHTS
                                 + 1
                                       * COREHALFWORD (
                                           getFIXED (mIND_STACK)
                                           + 73
                                                 * (COREHALFWORD (
                                                     mGENERATExSYT_COPIESxPTR))
                                           + 50 + 2 * (0)))));
                      putFIXED (mAREA, numberRHS);
                    }
                    // INX_CON(PTR) = INX_CON(PTR) + AREA; (6243)
                    {
                      int32_t numberRHS = (int32_t)(xadd (
                          getFIXED (
                              getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR))
                              + 4 + 4 * (0)),
                          getFIXED (mAREA)));
                      putFIXED (
                          getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR))
                              + 4 + 4 * (0),
                          numberRHS);
                    }
                  es2s1s1:;
                  } // End of DO block
              }
          } // End of DO for-loop block
          // COPY(PTR) = CPY; (6244)
          {
            descriptor_t *bitRHS = getBIT (16, mGENERATExSYT_COPIESxCPY);
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExSYT_COPIESxPTR)) + 26
                        + 2 * (0),
                    bitRHS);
            bitRHS->inUse = 0;
          }
        es2:;
        } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
