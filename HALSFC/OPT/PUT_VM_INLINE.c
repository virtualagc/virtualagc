/*
  File PUT_VM_INLINE.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
PUT_VM_INLINE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PUT_VM_INLINE");
  // D_N_INX = 0; (3829)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mD_N_INX, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL BUMP_D_N(CTR); (3830)
  {
    putBITp (16, mBUMP_D_NxPTR, getBIT (16, mCTR));
    BUMP_D_N (0);
  }
  // DO WHILE D_N_INX ~= 0; (3831)
  while (1 & (xNEQ (COREHALFWORD (mD_N_INX), 0)))
    {
      // IF TRACE THEN (3832)
      if (1 & (bitToFixed (getBIT (8, mTRACE))))
        // OUTPUT = 'PUT_VM_INLINE:  DIFF_NODE(' || D_N_INX|| ') = '||DIFF_NODE
        // (D_N_INX); (3833)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              xsCAT (xsCAT (cToDescriptor (NULL, "PUT_VM_INLINE:  DIFF_NODE("),
                            bitToCharacter (getBIT (16, mD_N_INX))),
                     cToDescriptor (NULL, ") = ")),
              bitToCharacter (
                  getBIT (16, mDIFF_NODE + 2 * COREHALFWORD (mD_N_INX))));
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
      // A_INX = 0; (3834)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mA_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // LOOP_START,LOOP_LAST = DIFF_NODE(D_N_INX); (3835)
      {
        descriptor_t *bitRHS
            = getBIT (16, mDIFF_NODE + 2 * COREHALFWORD (mD_N_INX));
        putBIT (16, mLOOP_START, bitRHS);
        putBIT (16, mLOOP_LAST, bitRHS);
        bitRHS->inUse = 0;
      }
      // D_N_INX = D_N_INX - 1; (3836)
      {
        int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mD_N_INX), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mD_N_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF ~ LOOPY(LOOP_LAST) THEN (3837)
      if (1
          & (xNOT (
              (putBITp (16, mLOOPYxPTR, getBIT (16, mLOOP_LAST)), LOOPY (0)))))
        // DO FOR TEMP = LOOP_LAST + 1 TO LAST_OPERAND(LOOP_LAST); (3838)
        {
          int32_t from94, to94, by94;
          from94 = xadd (COREHALFWORD (mLOOP_LAST), 1);
          to94 = bitToFixed (
              (putBITp (16, mLAST_OPERANDxPTR, getBIT (16, mLOOP_LAST)),
               LAST_OPERAND (0)));
          by94 = 1;
          for (putBIT (16, mPUT_VM_INLINExTEMP, fixedToBit (16, from94));
               bitToFixed (getBIT (16, mPUT_VM_INLINExTEMP)) <= to94;
               putBIT (16, mPUT_VM_INLINExTEMP,
                       fixedToBit (
                           16, bitToFixed (getBIT (16, mPUT_VM_INLINExTEMP))
                                   + by94)))
            {
              // IF XHALMAT_QUAL(TEMP) = XVAC THEN (3839)
              if (1
                  & (xEQ (
                      bitToFixed ((putBITp (16, mXHALMAT_QUALxPTR,
                                            getBIT (16, mPUT_VM_INLINExTEMP)),
                                   XHALMAT_QUAL (0))),
                      COREHALFWORD (mXVAC))))
                // CALL BUMP_D_N(SHR(OPR(TEMP),16)); (3840)
                {
                  putBITp (
                      16, mBUMP_D_NxPTR,
                      fixedToBit (
                          32,
                          (int32_t)(SHR (
                              getFIXED (
                                  mOPR
                                  + 4 * COREHALFWORD (mPUT_VM_INLINExTEMP)),
                              16))));
                  BUMP_D_N (0);
                }
            }
        } // End of DO for-loop block
      // ELSE (3841)
      else
        // DO; (3842)
        {
        rs1s2:;
          // CALL BUMP_ADD(LOOP_LAST); (3843)
          {
            putBITp (16, mBUMP_ADDxPTR, getBIT (16, mLOOP_LAST));
            BUMP_ADD (0);
          }
          // LOOPLESS_ASSIGN,DSUB_REF = FALSE; (3844)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (8, mLOOPLESS_ASSIGN, bitRHS);
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (8, mDSUB_REF, bitRHS);
            bitRHS->inUse = 0;
          }
          // ASSIGN_TOP = ASSIGN_TYPE(LOOP_LAST); (3845)
          {
            descriptor_t *bitRHS
                = (putBITp (16, mASSIGN_TYPExPTR, getBIT (16, mLOOP_LAST)),
                   ASSIGN_TYPE (0));
            putBIT (8, mASSIGN_TOP, bitRHS);
            bitRHS->inUse = 0;
          }
          // LOOP_DIMENSION = 0; (3846)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mLOOP_DIMENSION, bitRHS);
            bitRHS->inUse = 0;
          }
          // DO WHILE A_INX ~= 0; (3847)
          while (1 & (xNEQ (COREHALFWORD (mA_INX), 0)))
            {
              // IF TRACE THEN (3848)
              if (1 & (bitToFixed (getBIT (8, mTRACE))))
                // OUTPUT = '   ADD(' || A_INX || ') = ' || ADD(A_INX); (3849)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      xsCAT (xsCAT (cToDescriptor (NULL, "   ADD("),
                                    bitToCharacter (getBIT (16, mA_INX))),
                             cToDescriptor (NULL, ") = ")),
                      bitToCharacter (
                          getBIT (16, mADD + 2 * COREHALFWORD (mA_INX))));
                  OUTPUT (0, stringRHS);
                  stringRHS->inUse = 0;
                }
              // ADD = ADD(A_INX); (3850)
              {
                descriptor_t *bitRHS
                    = getBIT (16, mADD + 2 * COREHALFWORD (mA_INX));
                putBIT (16, mADD, bitRHS);
                bitRHS->inUse = 0;
              }
              // A_INX = A_INX - 1; (3851)
              {
                int32_t numberRHS
                    = (int32_t)(xsubtract (COREHALFWORD (mA_INX), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mA_INX, bitRHS);
                bitRHS->inUse = 0;
              }
              // TEMP = LAST_OPERAND(ADD) + 1; (3852)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    bitToFixed (
                        (putBITp (16, mLAST_OPERANDxPTR, getBIT (16, mADD)),
                         LAST_OPERAND (0))),
                    1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mPUT_VM_INLINExTEMP, bitRHS);
                bitRHS->inUse = 0;
              }
              // DIFF = TEMP - ADD; (3853)
              {
                int32_t numberRHS = (int32_t)(xsubtract (
                    COREHALFWORD (mPUT_VM_INLINExTEMP), COREHALFWORD (mADD)));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mPUT_VM_INLINExDIFF, bitRHS);
                bitRHS->inUse = 0;
              }
              // BUMP = ADD < LOOP_START; (3854)
              {
                int32_t numberRHS = (int32_t)(xLT (
                    COREHALFWORD (mADD), COREHALFWORD (mLOOP_START)));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (8, mPUT_VM_INLINExBUMP, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF TEMP < LOOP_START THEN (3855)
              if (1
                  & (xLT (COREHALFWORD (mPUT_VM_INLINExTEMP),
                          COREHALFWORD (mLOOP_START))))
                // CALL INSERT(ADD,TEMP); (3856)
                {
                  putBITp (16, mINSERTxPTR, getBIT (16, mADD));
                  putBITp (16, mINSERTxHIGH, getBIT (16, mPUT_VM_INLINExTEMP));
                  INSERT (0);
                }
              // IF BUMP THEN (3857)
              if (1 & (bitToFixed (getBIT (8, mPUT_VM_INLINExBUMP))))
                // LOOP_START = LOOP_START - DIFF; (3858)
                {
                  int32_t numberRHS = (int32_t)(xsubtract (
                      COREHALFWORD (mLOOP_START),
                      COREHALFWORD (mPUT_VM_INLINExDIFF)));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mLOOP_START, bitRHS);
                  bitRHS->inUse = 0;
                }
              // ASSIGN = ASSIGN_TYPE(ADD); (3859)
              {
                descriptor_t *bitRHS
                    = (putBITp (16, mASSIGN_TYPExPTR, getBIT (16, mADD)),
                       ASSIGN_TYPE (0));
                putBIT (8, mPUT_VM_INLINExASSIGN, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF ASSIGN THEN (3860)
              if (1 & (bitToFixed (getBIT (8, mPUT_VM_INLINExASSIGN))))
                // IF LOOPY_ASSIGN_ONLY THEN (3861)
                if (1 & (bitToFixed (getBIT (8, mLOOPY_ASSIGN_ONLY))))
                  // IF NO_OPERANDS(ADD) > 2 THEN (3862)
                  if (1
                      & (xGT (bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                                    getBIT (16, mADD)),
                                           NO_OPERANDS (0))),
                              2)))
                    // RETURN; (3863)
                    {
                      reentryGuard = 0;
                      return 0;
                    }
              // DO FOR TEMP = ADD + 1 TO LOOP_OPERANDS(ADD); (3864)
              {
                int32_t from95, to95, by95;
                from95 = xadd (COREHALFWORD (mADD), 1);
                to95 = bitToFixed (
                    (putBITp (16, mLOOP_OPERANDSxPTR, getBIT (16, mADD)),
                     LOOP_OPERANDS (0)));
                by95 = 1;
                for (putBIT (16, mPUT_VM_INLINExTEMP, fixedToBit (16, from95));
                     bitToFixed (getBIT (16, mPUT_VM_INLINExTEMP)) <= to95;
                     putBIT (16, mPUT_VM_INLINExTEMP,
                             fixedToBit (16, bitToFixed (getBIT (
                                                 16, mPUT_VM_INLINExTEMP))
                                                 + by95)))
                  {
                    // IF LOOP_DIMENSION = 0 THEN (3865)
                    if (1 & (xEQ (COREHALFWORD (mLOOP_DIMENSION), 0)))
                      // CALL SEARCH_DIMENSION(TEMP); (3866)
                      {
                        putBITp (16, mSEARCH_DIMENSIONxPTR,
                                 getBIT (16, mPUT_VM_INLINExTEMP));
                        SEARCH_DIMENSION (0);
                      }
                    // DO CASE SHR(OPR(TEMP),4) &  15; (3867)
                    {
                    rs1s2s1s1s1:
                      switch (xAND (
                          SHR (getFIXED (
                                   mOPR
                                   + 4 * COREHALFWORD (mPUT_VM_INLINExTEMP)),
                               4),
                          15))
                        {
                        case 0:
                            // ; (3869)
                            ;
                          break;
                        case 1:
                          // DO; (3870)
                          {
                          rs1s2s1s1s1s1:;
                            // IF TRACE THEN (3870)
                            if (1 & (bitToFixed (getBIT (8, mTRACE))))
                              // OUTPUT = '      NAME_OR_PARM:  '||TEMP; (3871)
                              {
                                descriptor_t *stringRHS;
                                stringRHS = xsCAT (
                                    cToDescriptor (NULL,
                                                   "      NAME_OR_PARM:  "),
                                    bitToCharacter (
                                        getBIT (16, mPUT_VM_INLINExTEMP)));
                                OUTPUT (0, stringRHS);
                                stringRHS->inUse = 0;
                              }
                            // IF NAME_OR_PARM(TEMP) THEN (3872)
                            if (1
                                & (bitToFixed ((
                                    putBITp (16, mNAME_OR_PARMxPTR,
                                             getBIT (16, mPUT_VM_INLINExTEMP)),
                                    NAME_OR_PARM (0)))))
                              // DO; (3873)
                              {
                              rs1s2s1s1s1s1s1:;
                                // DSUB_REF = TRUE; (3874)
                                {
                                  int32_t numberRHS = (int32_t)(1);
                                  descriptor_t *bitRHS;
                                  bitRHS
                                      = fixedToBit (32, (int32_t)(numberRHS));
                                  putBIT (8, mDSUB_REF, bitRHS);
                                  bitRHS->inUse = 0;
                                }
                                // IF ASSIGN THEN (3875)
                                if (1
                                    & (bitToFixed (
                                        getBIT (8, mPUT_VM_INLINExASSIGN))))
                                  // LOOPLESS_ASSIGN = TRUE; (3876)
                                  {
                                    int32_t numberRHS = (int32_t)(1);
                                    descriptor_t *bitRHS;
                                    bitRHS = fixedToBit (32,
                                                         (int32_t)(numberRHS));
                                    putBIT (8, mLOOPLESS_ASSIGN, bitRHS);
                                    bitRHS->inUse = 0;
                                  }
                              es1s2s1s1s1s1s1:;
                              } // End of DO block
                          es1s2s1s1s1s1:;
                          } // End of DO block
                          break;
                        case 2:
                            // ; (3878)
                            ;
                          break;
                        case 3:
                          // DO; (3879)
                          {
                          rs1s2s1s1s1s2:;
                            // REF = SHR(OPR(TEMP),16); (3879)
                            {
                              int32_t numberRHS = (int32_t)(SHR (
                                  getFIXED (mOPR
                                            + 4
                                                  * COREHALFWORD (
                                                      mPUT_VM_INLINExTEMP)),
                                  16));
                              descriptor_t *bitRHS;
                              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                              putBIT (16, mPUT_VM_INLINExREF, bitRHS);
                              bitRHS->inUse = 0;
                            }
                            // IF LOOPY(REF) THEN (3880)
                            if (1
                                & ((putBITp (16, mLOOPYxPTR,
                                             getBIT (16, mPUT_VM_INLINExREF)),
                                    LOOPY (0))))
                              // CALL BUMP_ADD(REF); (3881)
                              {
                                putBITp (16, mBUMP_ADDxPTR,
                                         getBIT (16, mPUT_VM_INLINExREF));
                                BUMP_ADD (0);
                              }
                            // ELSE (3882)
                            else
                              // IF ~LOOPY_ASSIGN_ONLY THEN (3883)
                              if (1 & (xNOT (BYTE0 (mLOOPY_ASSIGN_ONLY))))
                                // CALL BUMP_D_N(REF); (3884)
                                {
                                  putBITp (16, mBUMP_D_NxPTR,
                                           getBIT (16, mPUT_VM_INLINExREF));
                                  BUMP_D_N (0);
                                }
                            // IF OPOP(REF) = DSUB THEN (3885)
                            if (1
                                & (xEQ (
                                    bitToFixed (
                                        (putBITp (
                                             16, mOPOPxPTR,
                                             getBIT (16, mPUT_VM_INLINExREF)),
                                         OPOP (0))),
                                    COREHALFWORD (mDSUB))))
                              // DO; (3886)
                              {
                              rs1s2s1s1s1s2s1:;
                                // DSUB_REF = TRUE; (3887)
                                {
                                  int32_t numberRHS = (int32_t)(1);
                                  descriptor_t *bitRHS;
                                  bitRHS
                                      = fixedToBit (32, (int32_t)(numberRHS));
                                  putBIT (8, mDSUB_REF, bitRHS);
                                  bitRHS->inUse = 0;
                                }
                                // IF TEMP > ADD + 1 THEN (3888)
                                if (1
                                    & (xGT (COREHALFWORD (mPUT_VM_INLINExTEMP),
                                            xadd (COREHALFWORD (mADD), 1))))
                                  // IF ASSIGN THEN (3889)
                                  if (1
                                      & (bitToFixed (
                                          getBIT (8, mPUT_VM_INLINExASSIGN))))
                                    // DO; (3890)
                                    {
                                    rs1s2s1s1s1s2s1s1:;
                                      // LOOPLESS_ASSIGN = NONCONSEC(REF);
                                      // (3891)
                                      {
                                        descriptor_t *bitRHS
                                            = (putBITp (
                                                   16, mNONCONSECxPTR,
                                                   getBIT (
                                                       16,
                                                       mPUT_VM_INLINExREF)),
                                               NONCONSEC (0));
                                        putBIT (8, mLOOPLESS_ASSIGN, bitRHS);
                                        bitRHS->inUse = 0;
                                      }
                                    es1s2s1s1s1s2s1s1:;
                                    } // End of DO block
                              es1s2s1s1s1s2s1:;
                              } // End of DO block
                          es1s2s1s1s1s2:;
                          } // End of DO block
                          break;
                        case 4:
                          // DO; (3893)
                          {
                          rs1s2s1s1s1s3:;
                            // IF EXTN_CHECK(TEMP) THEN (3893)
                            if (1
                                & (bitToFixed ((
                                    putBITp (16, mEXTN_CHECKxPTR,
                                             getBIT (16, mPUT_VM_INLINExTEMP)),
                                    EXTN_CHECK (0)))))
                              // DO; (3894)
                              {
                              rs1s2s1s1s1s3s1:;
                                // DSUB_REF = TRUE; (3895)
                                {
                                  int32_t numberRHS = (int32_t)(1);
                                  descriptor_t *bitRHS;
                                  bitRHS
                                      = fixedToBit (32, (int32_t)(numberRHS));
                                  putBIT (8, mDSUB_REF, bitRHS);
                                  bitRHS->inUse = 0;
                                }
                                // IF ASSIGN THEN (3896)
                                if (1
                                    & (bitToFixed (
                                        getBIT (8, mPUT_VM_INLINExASSIGN))))
                                  // LOOPLESS_ASSIGN = TRUE; (3897)
                                  {
                                    int32_t numberRHS = (int32_t)(1);
                                    descriptor_t *bitRHS;
                                    bitRHS = fixedToBit (32,
                                                         (int32_t)(numberRHS));
                                    putBIT (8, mLOOPLESS_ASSIGN, bitRHS);
                                    bitRHS->inUse = 0;
                                  }
                              es1s2s1s1s1s3s1:;
                              } // End of DO block
                          es1s2s1s1s1s3:;
                          } // End of DO block
                          break;
                        case 5:
                            // ; (3899)
                            ;
                          break;
                        case 6:
                            // ; (3900)
                            ;
                          break;
                        case 7:
                            // ; (3901)
                            ;
                          break;
                        case 8:
                            // ; (3902)
                            ;
                          break;
                        case 9:
                            // ; (3903)
                            ;
                          break;
                        case 10:
                            // ; (3904)
                            ;
                          break;
                        }
                    } // End of DO CASE block
                  }
              } // End of DO for-loop block
            }   // End of DO WHILE block
          // IF LOOP_DIMENSION > 1 THEN (3904)
          if (1 & (xGT (COREHALFWORD (mLOOP_DIMENSION), 1)))
            // CALL PUT_VDLP; (3905)
            PUT_VDLP (0);
        es1s2:;
        } // End of DO block
    }     // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
