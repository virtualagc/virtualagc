/*
  File GENERATExGEN_CLASS0xSET_IO_LIST.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xSET_IO_LIST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xSET_IO_LIST");
  // PTR = ARG_STACK(ARG); (12117)
  {
    descriptor_t *bitRHS = getBIT (
        16, mGENERATExARG_STACK
                + 2 * COREHALFWORD (mGENERATExGEN_CLASS0xSET_IO_LISTxARG));
    putBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL DROPSAVE(PTR); (12118)
  {
    putBITp (16, mGENERATExDROPSAVExENTRY,
             getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
    GENERATExDROPSAVE (0);
  }
  // IF ARG_TYPE(ARG) = 0 THEN (12119)
  if (1
      & (xEQ (COREHALFWORD (
                  mGENERATExARG_TYPE
                  + 2 * COREHALFWORD (mGENERATExGEN_CLASS0xSET_IO_LISTxARG)),
              0)))
    // DO; (12120)
    {
    rs1:;
      // IF ~IOMODE THEN (12121)
      if (1 & (xNOT (BYTE0 (mIOMODE))))
        // CALL ASSIGN_CLEAR(PTR, 1); (12122)
        {
          putBITp (16, mGENERATExASSIGN_CLEARxOP,
                   getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
          putBITp (1, mGENERATExASSIGN_CLEARxFLAG,
                   fixedToBit (32, (int32_t)(1)));
          GENERATExASSIGN_CLEAR (0);
        }
      // IF TYPE(PTR) = STRUCTURE THEN (12123)
      if (1
          & (xEQ (
              COREHALFWORD (
                  getFIXED (mIND_STACK)
                  + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                  + 50 + 2 * (0)),
              BYTE0 (mSTRUCTURE))))
        // DO; (12124)
        {
        rs1s1:;
          // IF (DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)) |
          // CHECK_REMOTE(PTR) THEN (12125)
          if (1
              & (xOR (
                  xAND (
                      BYTE0 (mDATA_REMOTE),
                      xEQ (
                          bitToFixed ((
                              putBITp (
                                  16, mCSECT_TYPExPTR,
                                  getBIT (
                                      16,
                                      getFIXED (mIND_STACK)
                                          + 73
                                                * (COREHALFWORD (
                                                    mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                          + 40 + 2 * (0))),
                              putBITp (
                                  16, mCSECT_TYPExOP,
                                  getBIT (
                                      16,
                                      mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                              CSECT_TYPE (0))),
                          6)),
                  bitToFixed (
                      (putBITp (
                           16, mGENERATExCHECK_REMOTExOP,
                           getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                       GENERATExCHECK_REMOTE (0))))))
            // DO; (12126)
            {
            rs1s1s1:;
              // PTR = STRUC_CONVERT(PTR); (12127)
              {
                descriptor_t *bitRHS
                    = (putBITp (
                           16, mGENERATExGEN_CLASS0xSTRUC_CONVERTxOP,
                           getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                       GENERATExGEN_CLASS0xSTRUC_CONVERT (0));
                putBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL DROPSAVE(PTR); (12128)
              {
                putBITp (16, mGENERATExDROPSAVExENTRY,
                         getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                GENERATExDROPSAVE (0);
              }
            es1s1s1:;
            } // End of DO block
          // CALL SETUP_STRUCTURE(PTR); (12129)
          {
            putBITp (16, mGENERATExGEN_CLASS0xSETUP_STRUCTURExOP,
                     getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
            GENERATExGEN_CLASS0xSETUP_STRUCTURE (0);
          }
          // WORK1 = STRUCTURE_ADVANCE; (12130)
          {
            descriptor_t *bitRHS = GENERATExSTRUCTURE_ADVANCE (0);
            int32_t numberRHS;
            numberRHS = bitToFixed (bitRHS);
            putFIXED (mWORK1, numberRHS);
            bitRHS->inUse = 0;
          }
          // IOSTRUCT = 1; (12131)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s1:;
        } // End of DO block
      // ELSE (12132)
      else
        // IOSTRUCT = 0; (12133)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT, bitRHS);
          bitRHS->inUse = 0;
        }
      // IOREPEAT = TRUE; (12134)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOREPEAT, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO WHILE IOREPEAT; (12135)
      while (1
             & (bitToFixed (
                 getBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOREPEAT))))
        {
          // IF IOSTRUCT THEN (12136)
          if (1
              & (bitToFixed (
                  getBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT))))
            // CALL REF_STRUCTURE(PTR, WORK1); (12137)
            {
              putBITp (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR,
                       getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
              putBITp (16, mGENERATExGEN_CLASS0xREF_STRUCTURExOP,
                       fixedToBit (32, (int32_t)(getFIXED (mWORK1))));
              GENERATExGEN_CLASS0xREF_STRUCTURE (0);
            }
          // DO CASE PACKTYPE(TYPE(PTR)); (12138)
          {
          rs1s2s1:
            switch (BYTE0 (
                mPACKTYPE
                + 1
                      * COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                          + 50 + 2 * (0))))
              {
              case 0:
                // DO; (12140)
                {
                rs1s2s1s1:;
                  // IF (DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)) |
                  // (CHECK_REMOTE(PTR) & ~IOSTRUCT) THEN (12140)
                  if (1
                      & (xOR (
                          xAND (
                              BYTE0 (mDATA_REMOTE),
                              xEQ (
                                  bitToFixed ((
                                      putBITp (
                                          16, mCSECT_TYPExPTR,
                                          getBIT (
                                              16,
                                              getFIXED (mIND_STACK)
                                                  + 73
                                                        * (COREHALFWORD (
                                                            mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                                  + 40 + 2 * (0))),
                                      putBITp (
                                          16, mCSECT_TYPExOP,
                                          getBIT (
                                              16,
                                              mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                                      CSECT_TYPE (0))),
                                  6)),
                          xAND (
                              bitToFixed ((
                                  putBITp (
                                      16, mGENERATExCHECK_REMOTExOP,
                                      getBIT (
                                          16,
                                          mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                                  GENERATExCHECK_REMOTE (0))),
                              xNOT (BYTE0 (
                                  mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT))))))
                    // DO; (12141)
                    {
                    rs1s2s1s1s1:;
                      // PTR = VECMAT_CONVERT(PTR); (12142)
                      {
                        int32_t numberRHS = (int32_t)((
                            putBITp (
                                16, mGENERATExVECMAT_CONVERTxOP,
                                getBIT (16,
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                            GENERATExVECMAT_CONVERT (0)));
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR,
                                bitRHS);
                        bitRHS->inUse = 0;
                      }
                      // CALL DROPSAVE(PTR); (12143)
                      {
                        putBITp (
                            16, mGENERATExDROPSAVExENTRY,
                            getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                        GENERATExDROPSAVE (0);
                      }
                    es1s2s1s1s1:;
                    } // End of DO block
                  // IF DEL(PTR) = 0 THEN (12144)
                  if (1
                      & (xEQ (
                          COREHALFWORD (
                              getFIXED (mIND_STACK)
                              + 73
                                    * (COREHALFWORD (
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                              + 28 + 2 * (0)),
                          0)))
                    // DEL(PTR) = -1; (12145)
                    {
                      int32_t numberRHS = (int32_t)(-1);
                      putBIT (
                          16,
                          getFIXED (mIND_STACK)
                              + 73
                                    * (COREHALFWORD (
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                              + 28 + 2 * (0),
                          fixedToBit (16, numberRHS));
                    }
                  // CALL
                  // VMCALL(XVMIO+IOMODE,(TYPE(PTR)&8)~=0,0,PTR,0,DEL(PTR));
                  // (12146)
                  {
                    putBITp (
                        16, mGENERATExVMCALLxOPCODE,
                        fixedToBit (32, (int32_t)(xadd (BYTE0 (mXVMIO),
                                                        BYTE0 (mIOMODE)))));
                    putBITp (
                        8, mGENERATExVMCALLxOPTYPE,
                        fixedToBit (
                            32,
                            (int32_t)(xNEQ (
                                xAND (
                                    COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                        + 50 + 2 * (0)),
                                    8),
                                0))));
                    putBITp (16, mGENERATExVMCALLxOP0,
                             fixedToBit (32, (int32_t)(0)));
                    putBITp (
                        16, mGENERATExVMCALLxOP1,
                        getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                    putBITp (16, mGENERATExVMCALLxOP2,
                             fixedToBit (32, (int32_t)(0)));
                    putFIXED (
                        mGENERATExVMCALLxPART,
                        COREHALFWORD (
                            getFIXED (mIND_STACK)
                            + 73
                                  * (COREHALFWORD (
                                      mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                            + 28 + 2 * (0)));
                    GENERATExVMCALL (0);
                  }
                es1s2s1s1:;
                } // End of DO block
                break;
              case 1:
                // DO; (12148)
                {
                rs1s2s1s2:;
                  // DO CASE IOMODE; (12148)
                  {
                  rs1s2s1s2s1:
                    switch (BYTE0 (mIOMODE))
                      {
                      case 0:
                        // DO; (12150)
                        {
                        rs1s2s1s2s1s1:;
                          // CALL FORCE_NUM(FIXARG2, SIZE(PTR)); (12150)
                          {
                            putBITp (16, mGENERATExFORCE_NUMxR,
                                     getBIT (8, mFIXARG2));
                            putFIXED (
                                mGENERATExFORCE_NUMxNUM,
                                COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                    + 48 + 2 * (0)));
                            GENERATExFORCE_NUM (0);
                          }
                          // CALL GENLIBCALL('BIN'); (12151)
                          {
                            putCHARACTERp (mGENERATExGENLIBCALLxNAME,
                                           cToDescriptor (NULL, "BIN"));
                            GENERATExGENLIBCALL (0);
                          }
                          // AROUND = GETSTATNO; (12152)
                          {
                            descriptor_t *bitRHS = GETSTATNO (0);
                            putBIT (16,
                                    mGENERATExGEN_CLASS0xSET_IO_LISTxAROUND,
                                    bitRHS);
                            bitRHS->inUse = 0;
                          }
                          // CALL EMITBFW(EZ, GETSTMTLBL(AROUND)); (12153)
                          {
                            putBITp (16, mGENERATExEMITBFWxCOND,
                                     getBIT (8, mEZ));
                            putBITp (
                                16, mGENERATExEMITBFWxPTR,
                                (putFIXED (
                                     mGENERATExGETSTMTLBLxSTATNO,
                                     COREHALFWORD (
                                         mGENERATExGEN_CLASS0xSET_IO_LISTxAROUND)),
                                 GENERATExGETSTMTLBL (0)));
                            GENERATExEMITBFW (0);
                          }
                          // RESULT = GET_VAC(FIXARG2); (12154)
                          {
                            descriptor_t *bitRHS
                                = (putBITp (16, mGENERATExGET_VACxR,
                                            getBIT (8, mFIXARG2)),
                                   GENERATExGET_VAC (0));
                            putBIT (16, mRESULT, bitRHS);
                            bitRHS->inUse = 0;
                          }
                          // RIGHTOP, SIZE(0) = 0; (12155)
                          {
                            int32_t numberRHS = (int32_t)(0);
                            descriptor_t *bitRHS;
                            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                            putBIT (16, mRIGHTOP, bitRHS);
                            putBIT (16,
                                    getFIXED (mIND_STACK) + 73 * (0) + 48
                                        + 2 * (0),
                                    fixedToBit (16, numberRHS));
                            bitRHS->inUse = 0;
                          }
                          // CALL BIT_STORE(RESULT, PTR); (12156)
                          {
                            putBITp (16, mGENERATExBIT_STORExROP,
                                     getBIT (16, mRESULT));
                            putBITp (
                                16, mGENERATExBIT_STORExOP,
                                getBIT (16,
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                            GENERATExBIT_STORE (0);
                          }
                          // CALL SET_LABEL(AROUND, 1); (12157)
                          {
                            putBITp (
                                16, mGENERATExSET_LABELxSTMTNO,
                                getBIT (
                                    16,
                                    mGENERATExGEN_CLASS0xSET_IO_LISTxAROUND));
                            putBITp (1, mGENERATExSET_LABELxFLAG1,
                                     fixedToBit (32, (int32_t)(1)));
                            GENERATExSET_LABEL (0);
                          }
                          // CALL DROP_VAC(RESULT); (12158)
                          {
                            putBITp (16, mGENERATExDROP_VACxPTR,
                                     getBIT (16, mRESULT));
                            GENERATExDROP_VAC (0);
                          }
                          // CALL UNRECOGNIZABLE(FIXARG2); (12159)
                          {
                            putBITp (16, mGENERATExUNRECOGNIZABLExR,
                                     getBIT (8, mFIXARG2));
                            GENERATExUNRECOGNIZABLE (0);
                          }
                        es1s2s1s2s1s1:;
                        } // End of DO block
                        break;
                      case 1:
                        // DO; (12161)
                        {
                        rs1s2s1s2s1s2:;
                          // D_RTL_SETUP = TRUE; (12161)
                          {
                            int32_t numberRHS = (int32_t)(1);
                            descriptor_t *bitRHS;
                            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                            putBIT (8, mD_RTL_SETUP, bitRHS);
                            bitRHS->inUse = 0;
                          }
                          // TARGET_REGISTER = FIXARG1; (12162)
                          {
                            descriptor_t *bitRHS = getBIT (8, mFIXARG1);
                            putBIT (16, mTARGET_REGISTER, bitRHS);
                            bitRHS->inUse = 0;
                          }
                          // CALL FORCE_ACCUMULATOR(PTR, FULLBIT); (12163)
                          {
                            putBITp (
                                16, mGENERATExFORCE_ACCUMULATORxOP,
                                getBIT (16,
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                            putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
                                     getBIT (8, mFULLBIT));
                            GENERATExFORCE_ACCUMULATOR (0);
                          }
                          // CALL OFF_TARGET(PTR); (12164)
                          {
                            putBITp (
                                16, mGENERATExOFF_TARGETxOP,
                                getBIT (16,
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                            GENERATExOFF_TARGET (0);
                          }
                          // CALL FORCE_NUM(FIXARG2, SIZE(PTR)); (12165)
                          {
                            putBITp (16, mGENERATExFORCE_NUMxR,
                                     getBIT (8, mFIXARG2));
                            putFIXED (
                                mGENERATExFORCE_NUMxNUM,
                                COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                    + 48 + 2 * (0)));
                            GENERATExFORCE_NUM (0);
                          }
                          // CALL GENLIBCALL('BOUT'); (12166)
                          {
                            putCHARACTERp (mGENERATExGENLIBCALLxNAME,
                                           cToDescriptor (NULL, "BOUT"));
                            GENERATExGENLIBCALL (0);
                          }
                        es1s2s1s2s1s2:;
                        } // End of DO block
                        break;
                      }
                  } // End of DO CASE block
                es1s2s1s2:;
                } // End of DO block
                break;
              case 2:
                // DO; (12168)
                {
                rs1s2s1s3:;
                  // IF (DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)) |
                  // (CHECK_REMOTE(PTR) & ~IOSTRUCT) THEN (12168)
                  if (1
                      & (xOR (
                          xAND (
                              BYTE0 (mDATA_REMOTE),
                              xEQ (
                                  bitToFixed ((
                                      putBITp (
                                          16, mCSECT_TYPExPTR,
                                          getBIT (
                                              16,
                                              getFIXED (mIND_STACK)
                                                  + 73
                                                        * (COREHALFWORD (
                                                            mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                                  + 40 + 2 * (0))),
                                      putBITp (
                                          16, mCSECT_TYPExOP,
                                          getBIT (
                                              16,
                                              mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                                      CSECT_TYPE (0))),
                                  6)),
                          xAND (
                              bitToFixed ((
                                  putBITp (
                                      16, mGENERATExCHECK_REMOTExOP,
                                      getBIT (
                                          16,
                                          mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                                  GENERATExCHECK_REMOTE (0))),
                              xNOT (BYTE0 (
                                  mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT))))))
                    // DO; (12169)
                    {
                    rs1s2s1s3s1:;
                      // PTR = CHAR_CONVERT(PTR); (12170)
                      {
                        descriptor_t *bitRHS
                            = (putBITp (
                                   16, mGENERATExCHAR_CONVERTxOP,
                                   getBIT (
                                       16,
                                       mGENERATExGEN_CLASS0xSET_IO_LISTxPTR)),
                               GENERATExCHAR_CONVERT (0));
                        putBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR,
                                bitRHS);
                        bitRHS->inUse = 0;
                      }
                      // CALL DROPSAVE(PTR); (12171)
                      {
                        putBITp (
                            16, mGENERATExDROPSAVExENTRY,
                            getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                        GENERATExDROPSAVE (0);
                      }
                    es1s2s1s3s1:;
                    } // End of DO block
                  // CALL CHAR_CALL(XCSIO+IOMODE, 0, PTR, 0); (12172)
                  {
                    putBITp (
                        16, mGENERATExCHAR_CALLxOPCODE,
                        fixedToBit (32, (int32_t)(xadd (BYTE0 (mXCSIO),
                                                        BYTE0 (mIOMODE)))));
                    putBITp (16, mGENERATExCHAR_CALLxOP0,
                             fixedToBit (32, (int32_t)(0)));
                    putBITp (
                        16, mGENERATExCHAR_CALLxOP1,
                        getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                    putBITp (16, mGENERATExCHAR_CALLxOP2,
                             fixedToBit (32, (int32_t)(0)));
                    GENERATExCHAR_CALL (0);
                  }
                es1s2s1s3:;
                } // End of DO block
                break;
              case 3:
                // DO CASE IOMODE; (12174)
                {
                rs1s2s1s4:
                  switch (BYTE0 (mIOMODE))
                    {
                    case 0:
                      // DO; (12175)
                      {
                      rs1s2s1s4s1:;
                        // D_RTL_SETUP = TRUE; (12175)
                        {
                          int32_t numberRHS = (int32_t)(1);
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (8, mD_RTL_SETUP, bitRHS);
                          bitRHS->inUse = 0;
                        }
                        // CALL FORCE_ADDRESS(PTRARG1, PTR); (12176)
                        {
                          putBITp (16, mGENERATExFORCE_ADDRESSxTR,
                                   getBIT (8, mPTRARG1));
                          putBITp (
                              16, mGENERATExFORCE_ADDRESSxOP,
                              getBIT (16,
                                      mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                          GENERATExFORCE_ADDRESS (0);
                        }
                        // CALL GENLIBCALL(ITYPES(OPMODE(TYPE(PTR))) || 'IN');
                        // (12177)
                        {
                          putCHARACTERp (
                              mGENERATExGENLIBCALLxNAME,
                              xsCAT (
                                  getCHARACTER (
                                      mGENERATExITYPES
                                      + 4
                                            * BYTE0 (
                                                mOPMODE
                                                + 1
                                                      * COREHALFWORD (
                                                          getFIXED (mIND_STACK)
                                                          + 73
                                                                * (COREHALFWORD (
                                                                    mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                                          + 50 + 2 * (0)))),
                                  cToDescriptor (NULL, "IN")));
                          GENERATExGENLIBCALL (0);
                        }
                        // CALL NEW_USAGE(PTR, 1); (12178)
                        {
                          putBITp (
                              16, mGENERATExNEW_USAGExOP,
                              getBIT (16,
                                      mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                          putBITp (16, mGENERATExNEW_USAGExFLAG,
                                   fixedToBit (32, (int32_t)(1)));
                          GENERATExNEW_USAGE (0);
                        }
                      es1s2s1s4s1:;
                      } // End of DO block
                      break;
                    case 1:
                      // DO; (12180)
                      {
                      rs1s2s1s4s2:;
                        // D_RTL_SETUP = TRUE; (12180)
                        {
                          int32_t numberRHS = (int32_t)(1);
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (8, mD_RTL_SETUP, bitRHS);
                          bitRHS->inUse = 0;
                        }
                        // IF DATATYPE(TYPE(PTR))=SCALAR THEN (12181)
                        if (1
                            & (xEQ (
                                BYTE0 (
                                    mDATATYPE
                                    + 1
                                          * COREHALFWORD (
                                              getFIXED (mIND_STACK)
                                              + 73
                                                    * (COREHALFWORD (
                                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                              + 50 + 2 * (0))),
                                BYTE0 (mSCALAR))))
                          // TARGET_REGISTER = FR0; (12182)
                          {
                            descriptor_t *bitRHS = getBIT (8, mFR0);
                            putBIT (16, mTARGET_REGISTER, bitRHS);
                            bitRHS->inUse = 0;
                          }
                        // ELSE (12183)
                        else
                          // TARGET_REGISTER = FIXARG1; (12184)
                          {
                            descriptor_t *bitRHS = getBIT (8, mFIXARG1);
                            putBIT (16, mTARGET_REGISTER, bitRHS);
                            bitRHS->inUse = 0;
                          }
                        // CALL FORCE_ACCUMULATOR(PTR); (12185)
                        {
                          putBITp (
                              16, mGENERATExFORCE_ACCUMULATORxOP,
                              getBIT (16,
                                      mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                          GENERATExFORCE_ACCUMULATOR (0);
                        }
                        // CALL OFF_TARGET(PTR); (12186)
                        {
                          putBITp (
                              16, mGENERATExOFF_TARGETxOP,
                              getBIT (16,
                                      mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
                          GENERATExOFF_TARGET (0);
                        }
                        // CALL GENLIBCALL(TYPES(SELECTYPE(TYPE(PTR))) ||
                        // 'OUT'); (12187)
                        {
                          putCHARACTERp (
                              mGENERATExGENLIBCALLxNAME,
                              xsCAT (
                                  getCHARACTER (
                                      mGENERATExTYPES
                                      + 4
                                            * BYTE0 (
                                                mSELECTYPE
                                                + 1
                                                      * COREHALFWORD (
                                                          getFIXED (mIND_STACK)
                                                          + 73
                                                                * (COREHALFWORD (
                                                                    mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                                                          + 50 + 2 * (0)))),
                                  cToDescriptor (NULL, "OUT")));
                          GENERATExGENLIBCALL (0);
                        }
                      es1s2s1s4s2:;
                      } // End of DO block
                      break;
                    }
                } // End of DO CASE block
                break;
              case 4:
                  // ; (12189)
                  ;
                break;
              }
          } // End of DO CASE block
          // IF IOSTRUCT THEN (12189)
          if (1
              & (bitToFixed (
                  getBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT))))
            // DO; (12190)
            {
            rs1s2s2:;
              // IF ARRAYNESS > 0 THEN (12191)
              if (1 & (xGT (COREHALFWORD (mGENERATExARRAYNESS), 0)))
                // DO; (12192)
                {
                rs1s2s2s1:;
                  // CALL DOCLOSE; (12193)
                  GENERATExDOCLOSE (0);
                  // CALL_LEVEL = CALL_LEVEL - 1; (12194)
                  {
                    int32_t numberRHS
                        = (int32_t)(xsubtract (COREHALFWORD (mCALL_LEVEL), 1));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mCALL_LEVEL, bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s2s2s1:;
                } // End of DO block
              // WORK1 = STRUCTURE_ADVANCE; (12195)
              {
                descriptor_t *bitRHS = GENERATExSTRUCTURE_ADVANCE (0);
                int32_t numberRHS;
                numberRHS = bitToFixed (bitRHS);
                putFIXED (mWORK1, numberRHS);
                bitRHS->inUse = 0;
              }
              // IOREPEAT = WORK1 ~= 0; (12196)
              {
                int32_t numberRHS = (int32_t)(xNEQ (getFIXED (mWORK1), 0));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOREPEAT, bitRHS);
                bitRHS->inUse = 0;
              }
              // LASTRESULT = 0; (12197)
              {
                int32_t numberRHS = (int32_t)(0);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mLASTRESULT, bitRHS);
                bitRHS->inUse = 0;
              }
            es1s2s2:;
            } // End of DO block
          // ELSE (12198)
          else
            // IOREPEAT = FALSE; (12199)
            {
              int32_t numberRHS = (int32_t)(0);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOREPEAT, bitRHS);
              bitRHS->inUse = 0;
            }
        } // End of DO WHILE block
      // IF IOSTRUCT THEN (12200)
      if (1
          & (bitToFixed (
              getBIT (1, mGENERATExGEN_CLASS0xSET_IO_LISTxIOSTRUCT))))
        // CALL OFF_INX(BACKUP_REG(PTR)); (12201)
        {
          putBITp (
              16, mGENERATExOFF_INXxR,
              getBIT (16, getFIXED (mIND_STACK)
                              + 73
                                    * (COREHALFWORD (
                                        mGENERATExGEN_CLASS0xSET_IO_LISTxPTR))
                              + 20 + 2 * (0)));
          GENERATExOFF_INX (0);
        }
    es1:;
    } // End of DO block
  // ELSE (12202)
  else
    // DO; (12203)
    {
    rs2:;
      // TARGET_REGISTER = FIXARG1; (12204)
      {
        descriptor_t *bitRHS = getBIT (8, mFIXARG1);
        putBIT (16, mTARGET_REGISTER, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL FORCE_BY_MODE(PTR, INTEGER); (12205)
      {
        putBITp (16, mGENERATExFORCE_BY_MODExOP,
                 getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
        putBITp (16, mGENERATExFORCE_BY_MODExMODE, getBIT (8, mINTEGER));
        GENERATExFORCE_BY_MODE (0);
      }
      // CALL OFF_TARGET(PTR); (12206)
      {
        putBITp (16, mGENERATExOFF_TARGETxOP,
                 getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
        GENERATExOFF_TARGET (0);
      }
      // CALL GENLIBCALL(IOCONTROL(ARG_TYPE(ARG))); (12207)
      {
        putCHARACTERp (
            mGENERATExGENLIBCALLxNAME,
            getCHARACTER (
                mGENERATExIOCONTROL
                + 4
                      * COREHALFWORD (
                          mGENERATExARG_TYPE
                          + 2
                                * COREHALFWORD (
                                    mGENERATExGEN_CLASS0xSET_IO_LISTxARG))));
        GENERATExGENLIBCALL (0);
      }
    es2:;
    } // End of DO block
  // CALL RETURN_STACK_ENTRY(PTR); (12208)
  {
    putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
             getBIT (16, mGENERATExGEN_CLASS0xSET_IO_LISTxPTR));
    GENERATExRETURN_STACK_ENTRY (0);
  }
  // CALL DROPFREESPACE; (12209)
  GENERATExDROPFREESPACE (0);
  // CALL CLEAR_STMT_REGS; (12210)
  GENERATExGEN_CLASS0xCLEAR_STMT_REGS (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
