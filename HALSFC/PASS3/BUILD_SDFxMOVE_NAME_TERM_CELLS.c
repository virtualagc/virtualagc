/*
  File BUILD_SDFxMOVE_NAME_TERM_CELLS.c generated by XCOM-I, 2024-08-08
  04:33:10.
*/

#include "runtimeC.h"

int32_t
BUILD_SDFxMOVE_NAME_TERM_CELLS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "BUILD_SDFxMOVE_NAME_TERM_CELLS");
  // PREV_PTR = 0; (3839)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mBUILD_SDFxPREV_PTR, numberRHS);
  }
  // DO WHILE VPTR ~= 0; (3840)
  while (1 & (xNEQ (getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxVPTR), 0)))
    {
      // CALL LOCATE(VPTR,ADDR(NODE_H),0); (3841)
      {
        putFIXED (mLOCATExPTR,
                  getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxVPTR));
        putFIXED (mLOCATExBVAR, ADDR ("BUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H",
                                      0x80000000, NULL, 0));
        putBITp (8, mLOCATExFLAGS, fixedToBit (32, (int32_t)(0)));
        LOCATE (0);
      }
      // LEN = NODE_H(0); (3842)
      {
        descriptor_t *bitRHS = getBIT (
            16, getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H) + 2 * 0);
        putBIT (16, mBUILD_SDFxLEN, bitRHS);
        bitRHS->inUse = 0;
      }
      // PTR = GET_DATA_CELL(LEN,ADDR(NODE_F),0); (3843)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (mGET_DATA_CELLxLENGTH, COREHALFWORD (mBUILD_SDFxLEN)),
            putFIXED (mGET_DATA_CELLxBVAR,
                      ADDR ("BUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F",
                            0x80000000, NULL, 0)),
            putBITp (8, mGET_DATA_CELLxFLAGS, fixedToBit (32, (int32_t)(0))),
            GET_DATA_CELL (0)));
        putFIXED (mBUILD_SDFxPTR, numberRHS);
      }
      // CALL MOVE(LEN,VMEM_LOC_ADDR,LOC_ADDR); (3844)
      {
        putBITp (16, mMOVExLEGNTH, getBIT (16, mBUILD_SDFxLEN));
        putFIXED (mMOVExFROM, getFIXED (mVMEM_LOC_ADDR));
        putFIXED (mMOVExINTO, getFIXED (mLOC_ADDR));
        MOVE (0);
      }
      // VPTR = NODE_F(1); (3845)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F) + 4 * 1));
        putFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxVPTR, numberRHS);
      }
      // NODE_F(1) = PREV_PTR; (3846)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mBUILD_SDFxPREV_PTR));
        putFIXED (getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F) + 4 * (1),
                  numberRHS);
      }
      // PREV_PTR = PTR; (3847)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mBUILD_SDFxPTR));
        putFIXED (mBUILD_SDFxPREV_PTR, numberRHS);
      }
      // COREWORD(ADDR(NODE_H)) = LOC_ADDR; (3848)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mLOC_ADDR));
        COREWORD2 (ADDR ("BUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H", 0x80000000,
                         NULL, 0),
                   numberRHS);
      }
      // DO J = 4 TO NODE_H(1) + 3; (3849)
      {
        int32_t from108, to108, by108;
        from108 = 4;
        to108 = xadd (
            COREHALFWORD (getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                          + 2 * 1),
            3);
        by108 = 1;
        for (putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ,
                     fixedToBit (16, from108));
             bitToFixed (getBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ))
             <= to108;
             putBIT (
                 16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ,
                 fixedToBit (16, bitToFixed (getBIT (
                                     16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ))
                                     + by108)))
          {
            // NODE_H(J) = SYT_SORT1(NODE_H(J)); (3850)
            {
              descriptor_t *bitRHS = getBIT (
                  16,
                  getFIXED (mSORTING)
                      + 12
                            * (COREHALFWORD (
                                getFIXED (
                                    mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                                + 2
                                      * COREHALFWORD (
                                          mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ)))
                      + 0 + 2 * (0));
              putBIT (
                  16,
                  getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                      + 2 * (COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ)),
                  bitRHS);
              bitRHS->inUse = 0;
            }
          }
      } // End of DO for-loop block
      // J = (NODE_H(1)+5) &  65534; (3851)
      {
        int32_t numberRHS = (int32_t)(xAND (
            xadd (
                COREHALFWORD (getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                              + 2 * 1),
                5),
            65534));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ, bitRHS);
        bitRHS->inUse = 0;
      }
    // DO_EXTENSION_CELL: (3852)
    DO_EXTENSION_CELL:
      // PTR_INX, VR_INX = 0; (3853)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mBUILD_SDFxPTR_INX, bitRHS);
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxVR_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO WHILE J < SHR(NODE_H(0),1); (3854)
      while (1
             & (xLT (COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                     SHR (COREHALFWORD (
                              getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                              + 2 * 0),
                          1))))
        {
          // IF (NODE_H(J) &  65532) ~= 0 THEN (3855)
          if (1
              & (xNEQ (
                  xAND (COREHALFWORD (
                            getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                            + 2
                                  * COREHALFWORD (
                                      mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ)),
                        65532),
                  0)))
            // DO; (3856)
            {
            rs1s2s1:;
              // OUTPUT = P3ERR ||'MALFORMED NAME TERM
              // CELL:'||HEX(VMEM_LOC_PTR); (3857)
              {
                descriptor_t *stringRHS;
                stringRHS = xsCAT (
                    xsCAT (getCHARACTER (mP3ERR),
                           cToDescriptor (NULL, "MALFORMED NAME TERM CELL:")),
                    (putFIXED (mHEXxHVAL, getFIXED (mVMEM_LOC_PTR)), HEX (0)));
                OUTPUT (0, stringRHS);
                stringRHS->inUse = 0;
              }
              // PREV_PTR = NODE_F(1); (3858)
              {
                int32_t numberRHS = (int32_t)(getFIXED (
                    getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F)
                    + 4 * 1));
                putFIXED (mBUILD_SDFxPREV_PTR, numberRHS);
              }
              // GO TO SKIP_THIS_CELL; (3859)
              goto SKIP_THIS_CELL;
            es1s2s1:;
            } // End of DO block
          // DO CASE NODE_H(J); (3860)
          {
          rs1s2s2:
            switch (COREHALFWORD (
                getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                + 2 * COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ)))
              {
              case 0:
                // DO; (3862)
                {
                rs1s2s2s1:;
                  // CELL_PTR = NODE_F(SHR(J+2,1)); (3862)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (
                        getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F)
                        + 4
                              * SHR (
                                  xadd (COREHALFWORD (
                                            mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                        2),
                                  1)));
                    putFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxCELL_PTR,
                              numberRHS);
                  }
                  // IF CELL_PTR > 0 THEN (3863)
                  if (1
                      & (xGT (
                          getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxCELL_PTR),
                          0)))
                    // DO; (3864)
                    {
                    rs1s2s2s1s1:;
                      // DO K = 1 TO VR_INX; (3865)
                      {
                        int32_t from109, to109, by109;
                        from109 = 1;
                        to109 = bitToFixed (getBIT (
                            16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxVR_INX));
                        by109 = 1;
                        for (putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxK,
                                     fixedToBit (16, from109));
                             bitToFixed (getBIT (
                                 16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxK))
                             <= to109;
                             putBIT (
                                 16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxK,
                                 fixedToBit (
                                     16,
                                     bitToFixed (getBIT (
                                         16,
                                         mBUILD_SDFxMOVE_NAME_TERM_CELLSxK))
                                         + by109)))
                          {
                            // IF VAR_REF_CELL(K) = CELL_PTR THEN (3866)
                            if (1
                                & (xEQ (
                                    getFIXED (
                                        mBUILD_SDFxMOVE_NAME_TERM_CELLSxVAR_REF_CELL
                                        + 4
                                              * COREHALFWORD (
                                                  mBUILD_SDFxMOVE_NAME_TERM_CELLSxK)),
                                    getFIXED (
                                        mBUILD_SDFxMOVE_NAME_TERM_CELLSxCELL_PTR))))
                              // DO; (3867)
                              {
                              rs1s2s2s1s1s1s1:;
                                // NODE_F(SHR(J+2,1)) = PTRS(K); (3868)
                                {
                                  int32_t numberRHS = (int32_t)(getFIXED (
                                      mBUILD_SDFxPTRS
                                      + 4
                                            * COREHALFWORD (
                                                mBUILD_SDFxMOVE_NAME_TERM_CELLSxK)));
                                  putFIXED (
                                      getFIXED (
                                          mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F)
                                          + 4
                                                * (SHR (
                                                    xadd (
                                                        COREHALFWORD (
                                                            mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                                        2),
                                                    1)),
                                      numberRHS);
                                }
                                // GO TO PTR_FOUND; (3869)
                                goto PTR_FOUND;
                              es1s2s2s1s1s1s1:;
                              } // End of DO block
                          }
                      } // End of DO for-loop block
                      // NODE_F(SHR(J+2,1)) = GET_SDF_CELL(CELL_PTR); (3870)
                      {
                        int32_t numberRHS = (int32_t)((
                            putFIXED (
                                mBUILD_SDFxGET_SDF_CELLxVMEM_PTR,
                                getFIXED (
                                    mBUILD_SDFxMOVE_NAME_TERM_CELLSxCELL_PTR)),
                            BUILD_SDFxGET_SDF_CELL (0)));
                        putFIXED (
                            getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F)
                                + 4
                                      * (SHR (
                                          xadd (
                                              COREHALFWORD (
                                                  mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                              2),
                                          1)),
                            numberRHS);
                      }
                      // VR_INX = PTR_INX; (3871)
                      {
                        descriptor_t *bitRHS = getBIT (16, mBUILD_SDFxPTR_INX);
                        putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxVR_INX,
                                bitRHS);
                        bitRHS->inUse = 0;
                      }
                      // VAR_REF_CELL(VR_INX) = CELL_PTR; (3872)
                      {
                        int32_t numberRHS = (int32_t)(getFIXED (
                            mBUILD_SDFxMOVE_NAME_TERM_CELLSxCELL_PTR));
                        putFIXED (
                            mBUILD_SDFxMOVE_NAME_TERM_CELLSxVAR_REF_CELL
                                + 4
                                      * (COREHALFWORD (
                                          mBUILD_SDFxMOVE_NAME_TERM_CELLSxVR_INX)),
                            numberRHS);
                      }
                    es1s2s2s1s1:;
                    } // End of DO block
                  // ELSE (3873)
                  else
                    // NODE_H(J+3) = SYT_SORT1(NODE_H(J+3)); (3874)
                    {
                      descriptor_t *bitRHS = getBIT (
                          16,
                          getFIXED (mSORTING)
                              + 12
                                    * (COREHALFWORD (
                                        getFIXED (
                                            mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                                        + 2
                                              * xadd (
                                                  COREHALFWORD (
                                                      mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                                  3)))
                              + 0 + 2 * (0));
                      putBIT (
                          16,
                          getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                              + 2
                                    * (xadd (
                                        COREHALFWORD (
                                            mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                        3)),
                          bitRHS);
                      bitRHS->inUse = 0;
                    }
                // PTR_FOUND: (3875)
                PTR_FOUND:
                  // J = J + 4; (3876)
                  {
                    int32_t numberRHS = (int32_t)(xadd (
                        COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ), 4));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ, bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s2s2s1:;
                } // End of DO block
                break;
              case 1:
                // J = J + 4; (3878)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ), 4));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ, bitRHS);
                  bitRHS->inUse = 0;
                }
                break;
              case 2:
                // J = J + 2; (3879)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ), 2));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ, bitRHS);
                  bitRHS->inUse = 0;
                }
                break;
              case 3:
                // IF NODE_H(J+1)=0 THEN (3880)
                if (1
                    & (xEQ (
                        COREHALFWORD (
                            getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H)
                            + 2
                                  * xadd (
                                      COREHALFWORD (
                                          mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                      1)),
                        0)))
                  {
                    int32_t numberRHS = (int32_t)(xadd (
                        COREHALFWORD (mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ), 2));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ, bitRHS);
                    bitRHS->inUse = 0;
                  }
                else
                  {
                  rs1s2s2s2:;
                    // CALL MOVE_CELL_TREE(0,1); (3883)
                    {
                      putFIXED (mBUILD_SDFxMOVE_CELL_TREExPTR, 0);
                      putBITp (16, mBUILD_SDFxMOVE_CELL_TREExDOING_NAMETERMS,
                               fixedToBit (32, (int32_t)(1)));
                      BUILD_SDFxMOVE_CELL_TREE (0);
                    }
                    // NODE_F(SHR(J+2,1)) = GET_SDF_CELL(NODE_F(SHR(J+2,1)));
                    // (3884)
                    {
                      int32_t numberRHS = (int32_t)((
                          putFIXED (
                              mBUILD_SDFxGET_SDF_CELLxVMEM_PTR,
                              getFIXED (
                                  getFIXED (
                                      mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F)
                                  + 4
                                        * SHR (
                                            xadd (
                                                COREHALFWORD (
                                                    mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                                2),
                                            1))),
                          BUILD_SDFxGET_SDF_CELL (0)));
                      putFIXED (
                          getFIXED (mBUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F)
                              + 4
                                    * (SHR (
                                        xadd (
                                            COREHALFWORD (
                                                mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ),
                                            2),
                                        1)),
                          numberRHS);
                    }
                    // COREWORD(ADDR(NODE_H)), COREWORD(ADDR(NODE_F)) =
                    // LOC_ADDR; (3885)
                    {
                      int32_t numberRHS = (int32_t)(getFIXED (mLOC_ADDR));
                      COREWORD2 (ADDR ("BUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_H",
                                       0x80000000, NULL, 0),
                                 numberRHS);
                      COREWORD2 (ADDR ("BUILD_SDFxMOVE_NAME_TERM_CELLSxNODE_F",
                                       0x80000000, NULL, 0),
                                 numberRHS);
                    }
                    // J = 2; (3886)
                    {
                      int32_t numberRHS = (int32_t)(2);
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mBUILD_SDFxMOVE_NAME_TERM_CELLSxJ, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    // GO TO DO_EXTENSION_CELL; (3887)
                    goto DO_EXTENSION_CELL;
                  es1s2s2s2:;
                  } // End of DO block
                break;
              }
          } // End of DO CASE block
        }   // End of DO WHILE block
      // CALL MOVE_CELL_TREE(0,1); (3888)
      {
        putFIXED (mBUILD_SDFxMOVE_CELL_TREExPTR, 0);
        putBITp (16, mBUILD_SDFxMOVE_CELL_TREExDOING_NAMETERMS,
                 fixedToBit (32, (int32_t)(1)));
        BUILD_SDFxMOVE_CELL_TREE (0);
      }
    // SKIP_THIS_CELL: (3889)
    SKIP_THIS_CELL:;
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
