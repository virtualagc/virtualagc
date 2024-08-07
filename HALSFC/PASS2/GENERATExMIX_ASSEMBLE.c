/*
  File GENERATExMIX_ASSEMBLE.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExMIX_ASSEMBLE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExMIX_ASSEMBLE");
  // LEFTOP = GET_OPERAND(1); (7284)
  {
    descriptor_t *bitRHS = (putBITp (16, mGENERATExGET_OPERANDxOP,
                                     fixedToBit (32, (int32_t)(1))),
                            GENERATExGET_OPERAND (0));
    putBIT (16, mLEFTOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // LITTYPE = TYPE(LEFTOP)&8 | SCALAR; (7285)
  {
    int32_t numberRHS = (int32_t)(xOR (
        xAND (COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mLEFTOP)) + 50 + 2 * (0)),
              8),
        BYTE0 (mSCALAR)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLITTYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // RIGHTOP = GET_OPERAND(2); (7286)
  {
    descriptor_t *bitRHS = (putBITp (16, mGENERATExGET_OPERANDxOP,
                                     fixedToBit (32, (int32_t)(2))),
                            GENERATExGET_OPERAND (0));
    putBIT (16, mRIGHTOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // LEFTMODE = OPMODE(TYPE(LEFTOP)); (7287)
  {
    descriptor_t *bitRHS
        = getBIT (8, mOPMODE
                         + 1
                               * COREHALFWORD (getFIXED (mIND_STACK)
                                               + 73 * (COREHALFWORD (mLEFTOP))
                                               + 50 + 2 * (0)));
    putBIT (16, mGENERATExMIX_ASSEMBLExLEFTMODE, bitRHS);
    bitRHS->inUse = 0;
  }
  // RIGHTMODE = OPMODE(TYPE(RIGHTOP)); (7288)
  {
    descriptor_t *bitRHS
        = getBIT (8, mOPMODE
                         + 1
                               * COREHALFWORD (getFIXED (mIND_STACK)
                                               + 73 * (COREHALFWORD (mRIGHTOP))
                                               + 50 + 2 * (0)));
    putBIT (16, mGENERATExMIX_ASSEMBLExRIGHTMODE, bitRHS);
    bitRHS->inUse = 0;
  }
  // RIGHTTYPE = TYPE(RIGHTOP); (7289)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP))
                          + 50 + 2 * (0));
    putBIT (16, mGENERATExMIX_ASSEMBLExRIGHTTYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // STMT_PREC=(TYPE(LEFTOP) & 8)|(TYPE(RIGHTOP) & 8); (7290)
  {
    int32_t numberRHS = (int32_t)(xOR (
        xAND (COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mLEFTOP)) + 50 + 2 * (0)),
              8),
        xAND (COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mRIGHTOP)) + 50 + 2 * (0)),
              8)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExSTMT_PREC, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF ~VDLP_ACTIVE THEN (7291)
  if (1 & (xNOT (BYTE0 (mVDLP_ACTIVE))))
    // DO; (7292)
    {
    rs1:;
      // IF LEFTMODE ~= RIGHTMODE THEN (7293)
      if (1
          & (xNEQ (COREHALFWORD (mGENERATExMIX_ASSEMBLExLEFTMODE),
                   COREHALFWORD (mGENERATExMIX_ASSEMBLExRIGHTMODE))))
        // DO; (7294)
        {
        rs1s1:;
          // IF LEFTMODE < RIGHTMODE THEN (7295)
          if (1
              & (xLT (COREHALFWORD (mGENERATExMIX_ASSEMBLExLEFTMODE),
                      COREHALFWORD (mGENERATExMIX_ASSEMBLExRIGHTMODE))))
            // LEFTOP = VECMAT_CONVERT(LEFTOP, 8); (7296)
            {
              int32_t numberRHS
                  = (int32_t)((putBITp (16, mGENERATExVECMAT_CONVERTxOP,
                                        getBIT (16, mLEFTOP)),
                               putBITp (16, mGENERATExVECMAT_CONVERTxPREC_SPEC,
                                        fixedToBit (32, (int32_t)(8))),
                               GENERATExVECMAT_CONVERT (0)));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mLEFTOP, bitRHS);
              bitRHS->inUse = 0;
            }
          // ELSE (7297)
          else
            // RIGHTTYPE = RIGHTTYPE | 8; (7298)
            {
              int32_t numberRHS = (int32_t)(xOR (
                  COREHALFWORD (mGENERATExMIX_ASSEMBLExRIGHTTYPE), 8));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mGENERATExMIX_ASSEMBLExRIGHTTYPE, bitRHS);
              bitRHS->inUse = 0;
            }
        es1s1:;
        } // End of DO block
      // IF CHECK_REMOTE(LEFTOP) | DEL(LEFTOP) > 0 THEN (7299)
      if (1
          & (xOR (bitToFixed ((putBITp (16, mGENERATExCHECK_REMOTExOP,
                                        getBIT (16, mLEFTOP)),
                               GENERATExCHECK_REMOTE (0))),
                  xGT (COREHALFWORD (getFIXED (mIND_STACK)
                                     + 73 * (COREHALFWORD (mLEFTOP)) + 28
                                     + 2 * (0)),
                       0))))
        // LEFTOP = VECMAT_CONVERT(LEFTOP); (7300)
        {
          int32_t numberRHS = (int32_t)((
              putBITp (16, mGENERATExVECMAT_CONVERTxOP, getBIT (16, mLEFTOP)),
              GENERATExVECMAT_CONVERT (0)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mLEFTOP, bitRHS);
          bitRHS->inUse = 0;
        }
      // IF DATA_REMOTE & (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D) THEN (7301)
      if (1
          & (xAND (
              BYTE0 (mDATA_REMOTE),
              xEQ (bitToFixed ((
                       putBITp (16, mCSECT_TYPExPTR,
                                getBIT (16, getFIXED (mIND_STACK)
                                                + 73 * (COREHALFWORD (mLEFTOP))
                                                + 40 + 2 * (0))),
                       putBITp (16, mCSECT_TYPExOP, getBIT (16, mLEFTOP)),
                       CSECT_TYPE (0))),
                   6))))
        // LEFTOP = VECMAT_CONVERT(LEFTOP); (7302)
        {
          int32_t numberRHS = (int32_t)((
              putBITp (16, mGENERATExVECMAT_CONVERTxOP, getBIT (16, mLEFTOP)),
              GENERATExVECMAT_CONVERT (0)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mLEFTOP, bitRHS);
          bitRHS->inUse = 0;
        }
      // CALL DROPSAVE(LEFTOP); (7303)
      {
        putBITp (16, mGENERATExDROPSAVExENTRY, getBIT (16, mLEFTOP));
        GENERATExDROPSAVE (0);
      }
      // TARGET_REGISTER = FR0; (7304)
      {
        descriptor_t *bitRHS = getBIT (8, mFR0);
        putBIT (16, mTARGET_REGISTER, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL FORCE_ACCUMULATOR(RIGHTOP, RIGHTTYPE); (7305)
      {
        putBITp (16, mGENERATExFORCE_ACCUMULATORxOP, getBIT (16, mRIGHTOP));
        putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
                 getBIT (16, mGENERATExMIX_ASSEMBLExRIGHTTYPE));
        GENERATExFORCE_ACCUMULATOR (0);
      }
      // CALL STACK_TARGET(RIGHTOP); (7306)
      {
        putBITp (16, mGENERATExSTACK_TARGETxOP, getBIT (16, mRIGHTOP));
        GENERATExSTACK_TARGET (0);
      }
      // RIGHTOP =0; (7307)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mRIGHTOP, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // OPTYPE = TYPE(LEFTOP) | STMT_PREC; (7308)
  {
    int32_t numberRHS = (int32_t)(xOR (
        COREHALFWORD (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                      + 50 + 2 * (0)),
        COREHALFWORD (mGENERATExSTMT_PREC)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOPTYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // ROW(0) = ROW(LEFTOP); (7309)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                          + 48 + 2 * (0));
    putBIT (16, getFIXED (mIND_STACK) + 73 * (0) + 48 + 2 * (0), bitRHS);
    bitRHS->inUse = 0;
  }
  // COLUMN(0) = COLUMN(LEFTOP); (7310)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                          + 24 + 2 * (0));
    putBIT (16, getFIXED (mIND_STACK) + 73 * (0) + 24 + 2 * (0), bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
