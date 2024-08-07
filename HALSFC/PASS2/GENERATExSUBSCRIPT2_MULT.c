/*
  File GENERATExSUBSCRIPT2_MULT.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExSUBSCRIPT2_MULT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSUBSCRIPT2_MULT");
  // IF LEFTOP = 0 THEN (8145)
  if (1 & (xEQ (COREHALFWORD (mLEFTOP), 0)))
    // RETURN; (8146)
    {
      reentryGuard = 0;
      return 0;
    }
  // IF MULT = 1 THEN (8147)
  if (1 & (xEQ (COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxMULT), 1)))
    // RETURN; (8148)
    {
      reentryGuard = 0;
      return 0;
    }
  // IF FORM(LEFTOP)~=SYM|FORM(RIGHTOP)~=SYM&FORM(RIGHTOP)~=LIT|INX(RIGHTOP)~=0
  // THEN (8149)
  if (1
      & (xOR (
          xOR (xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                   + 73 * (COREHALFWORD (mLEFTOP)) + 32
                                   + 2 * (0)),
                     BYTE0 (mSYM)),
               xAND (xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                         + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                         + 2 * (0)),
                           BYTE0 (mSYM)),
                     xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                         + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                         + 2 * (0)),
                           BYTE0 (mLIT)))),
          xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mRIGHTOP)) + 34 + 2 * (0)),
                0))))
    // DO; (8150)
    {
    rs1:;
      // IF FORM(LEFTOP) ~= VAC THEN (8151)
      if (1
          & (xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                 + 73 * (COREHALFWORD (mLEFTOP)) + 32
                                 + 2 * (0)),
                   BYTE0 (mVAC))))
        // DO; (8152)
        {
        rs1s1:;
          // TO_BE_MODIFIED = TRUE; (8153)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
            bitRHS->inUse = 0;
          }
          // CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG); (8154)
          {
            putBITp (16, mGENERATExFORCE_ACCUMULATORxOP, getBIT (16, mLEFTOP));
            putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
                     getBIT (8, mINTEGER));
            putBITp (16, mGENERATExFORCE_ACCUMULATORxACCLASS,
                     fixedToBit (32, (int32_t)(4)));
            GENERATExFORCE_ACCUMULATOR (0);
          }
        es1s1:;
        } // End of DO block
      // CALL SUBSCRIPT_MULT(LEFTOP, MULT); (8155)
      {
        putBITp (16, mGENERATExSUBSCRIPT_MULTxOP, getBIT (16, mLEFTOP));
        putFIXED (mGENERATExSUBSCRIPT_MULTxVALUE,
                  COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxMULT));
        GENERATExSUBSCRIPT_MULT (0);
      }
    es1:;
    } // End of DO block
  // ELSE (8156)
  else
    // DO; (8157)
    {
    rs2:;
      // IF FORM(RIGHTOP) = LIT THEN (8158)
      if (1
          & (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                + 2 * (0)),
                  BYTE0 (mLIT))))
        // LOC(RIGHTOP) = -1; (8159)
        {
          int32_t numberRHS = (int32_t)(-1);
          putBIT (16,
                  getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP)) + 40
                      + 2 * (0),
                  fixedToBit (16, numberRHS));
        }
      // INX(LEFTOP) = LOC(RIGHTOP); (8160)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mRIGHTOP)) + 40 + 2 * (0));
        putBIT (16,
                getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 34
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // CONST(LEFTOP) = INX_CON(RIGHTOP); (8161)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP)) + 4
            + 4 * (0)));
        putFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 0
                      + 4 * (0),
                  numberRHS);
      }
      // XVAL(LEFTOP) = MULT; (8162)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExSUBSCRIPT2_MULTxMULT);
        putFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 16
                      + 4 * (0),
                  bitToFixed (bitRHS));
        bitRHS->inUse = 0;
      }
      // IF LAST_SUBSCRIPT & INXMOD = 0 THEN (8163)
      if (1
          & (xAND (bitToFixed (GENERATExLAST_SUBSCRIPT (0)),
                   xEQ (COREHALFWORD (mGENERATExINXMOD), 0))))
        // INX_SHIFT(LEFTOP) = SHIFT(TYPE(ALCOP)); (8164)
        {
          descriptor_t *bitRHS = getBIT (
              8, mSHIFT
                     + 1
                           * COREHALFWORD (getFIXED (mIND_STACK)
                                           + 73 * (COREHALFWORD (mRESULT)) + 50
                                           + 2 * (0)));
          putBIT (8,
                  getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 64
                      + 1 * (0),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (8165)
      else
        // INX_SHIFT(LEFTOP) = 0; (8166)
        {
          int32_t numberRHS = (int32_t)(0);
          putBIT (8,
                  getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 64
                      + 1 * (0),
                  fixedToBit (8, numberRHS));
        }
      // DO I = 0 TO INX_SHIFT(LEFTOP) ~= 0; (8167)
      {
        int32_t from91, to91, by91;
        from91 = 0;
        to91 = xNEQ (BYTE0 (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mLEFTOP)) + 64 + 1 * (0)),
                     0);
        by91 = 1;
        for (putBIT (16, mGENERATExSUBSCRIPT2_MULTxI, fixedToBit (16, from91));
             bitToFixed (getBIT (16, mGENERATExSUBSCRIPT2_MULTxI)) <= to91;
             putBIT (16, mGENERATExSUBSCRIPT2_MULTxI,
                     fixedToBit (16, bitToFixed (getBIT (
                                         16, mGENERATExSUBSCRIPT2_MULTxI))
                                         + by91)))
          {
            // R = SEARCH_INDEX2(LEFTOP); (8168)
            {
              int32_t numberRHS
                  = (int32_t)((putBITp (16, mGENERATExSEARCH_INDEX2xOP,
                                        getBIT (16, mLEFTOP)),
                               GENERATExSEARCH_INDEX2 (0)));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mGENERATExSUBSCRIPT2_MULTxR, bitRHS);
              bitRHS->inUse = 0;
            }
            // IF R >= 0 THEN (8169)
            if (1 & (xGE (COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxR), 0)))
              // DO; (8170)
              {
              rs2s1s1:;
                // REG(LEFTOP) = R; (8171)
                {
                  descriptor_t *bitRHS
                      = getBIT (16, mGENERATExSUBSCRIPT2_MULTxR);
                  putBIT (16,
                          getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                              + 46 + 2 * (0),
                          bitRHS);
                  bitRHS->inUse = 0;
                }
                // TO_BE_MODIFIED = ~LAST_SUBSCRIPT | INXMOD ~= 0; (8172)
                {
                  int32_t numberRHS = (int32_t)(xOR (
                      xNOT (bitToFixed (GENERATExLAST_SUBSCRIPT (0))),
                      xNEQ (COREHALFWORD (mGENERATExINXMOD), 0)));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
                  bitRHS->inUse = 0;
                }
                // CALL UPDATE_INX_USAGE(LEFTOP); (8173)
                {
                  putBITp (16, mGENERATExUPDATE_INX_USAGExOP,
                           getBIT (16, mLEFTOP));
                  GENERATExUPDATE_INX_USAGE (0);
                }
                // FORM(LEFTOP) = VAC; (8174)
                {
                  descriptor_t *bitRHS = getBIT (8, mVAC);
                  putBIT (16,
                          getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                              + 32 + 2 * (0),
                          bitRHS);
                  bitRHS->inUse = 0;
                }
                // LOC2(LEFTOP) = -1; (8175)
                {
                  int32_t numberRHS = (int32_t)(-1);
                  putBIT (16,
                          getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                              + 42 + 2 * (0),
                          fixedToBit (16, numberRHS));
                }
                // CONST(LEFTOP) = 0; (8176)
                {
                  int32_t numberRHS = (int32_t)(0);
                  putFIXED (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mLEFTOP)) + 0 + 4 * (0),
                            numberRHS);
                }
                // INX_MUL(LEFTOP) = 1; (8177)
                {
                  int32_t numberRHS = (int32_t)(1);
                  putBIT (16,
                          getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                              + 36 + 2 * (0),
                          fixedToBit (16, numberRHS));
                }
                // CALL RETURN_STACK_ENTRY(RIGHTOP); (8178)
                {
                  putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
                           getBIT (16, mRIGHTOP));
                  GENERATExRETURN_STACK_ENTRY (0);
                }
                // RIGHTOP = 0; (8179)
                {
                  int32_t numberRHS = (int32_t)(0);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mRIGHTOP, bitRHS);
                  bitRHS->inUse = 0;
                }
                // RETURN; (8180)
                {
                  reentryGuard = 0;
                  return 0;
                }
              es2s1s1:;
              } // End of DO block
            // INX_SHIFT(LEFTOP) = 0; (8181)
            {
              int32_t numberRHS = (int32_t)(0);
              putBIT (8,
                      getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                          + 64 + 1 * (0),
                      fixedToBit (8, numberRHS));
            }
            // TO_BE_MODIFIED = TRUE; (8182)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
              bitRHS->inUse = 0;
            }
          }
      } // End of DO for-loop block
      // INX(LEFTOP), CONST(LEFTOP), CONST(RIGHTOP) = 0; (8183)
      {
        int32_t numberRHS = (int32_t)(0);
        putBIT (16,
                getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 34
                    + 2 * (0),
                fixedToBit (16, numberRHS));
        putFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 0
                      + 4 * (0),
                  numberRHS);
        putFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP)) + 0
                      + 4 * (0),
                  numberRHS);
      }
      // CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG); (8184)
      {
        putBITp (16, mGENERATExFORCE_ACCUMULATORxOP, getBIT (16, mLEFTOP));
        putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE, getBIT (8, mINTEGER));
        putBITp (16, mGENERATExFORCE_ACCUMULATORxACCLASS,
                 fixedToBit (32, (int32_t)(4)));
        GENERATExFORCE_ACCUMULATOR (0);
      }
      // CALL SUBSCRIPT_MULT(LEFTOP, MULT); (8185)
      {
        putBITp (16, mGENERATExSUBSCRIPT_MULTxOP, getBIT (16, mLEFTOP));
        putFIXED (mGENERATExSUBSCRIPT_MULTxVALUE,
                  COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxMULT));
        GENERATExSUBSCRIPT_MULT (0);
      }
      // IF FORM(RIGHTOP) = SYM THEN (8186)
      if (1
          & (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                + 2 * (0)),
                  BYTE0 (mSYM))))
        // CALL EXPRESSION(XADD); (8187)
        {
          putBITp (16, mGENERATExEXPRESSIONxOPCODE, getBIT (8, mXADD));
          GENERATExEXPRESSION (0);
        }
      // ELSE (8188)
      else
        // CALL RETURN_STACK_ENTRY(RIGHTOP); (8189)
        {
          putBITp (16, mGENERATExRETURN_STACK_ENTRYxP, getBIT (16, mRIGHTOP));
          GENERATExRETURN_STACK_ENTRY (0);
        }
      // IF BASE(LEFTOP) = 0 & BASE(RIGHTOP) = 0 THEN (8190)
      if (1
          & (xAND (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mLEFTOP)) + 22
                                      + 2 * (0)),
                        0),
                   xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mRIGHTOP)) + 22
                                      + 2 * (0)),
                        0))))
        // DO; (8191)
        {
        rs2s2:;
          // R = REG(LEFTOP); (8192)
          {
            descriptor_t *bitRHS = getBIT (
                16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 46
                        + 2 * (0));
            putBIT (16, mGENERATExSUBSCRIPT2_MULTxR, bitRHS);
            bitRHS->inUse = 0;
          }
          // CALL SET_USAGE(R, SYM2, LOC(LEFTOP), INX_CON(LEFTOP)); (8193)
          {
            putBITp (16, mGENERATExSET_USAGExR,
                     getBIT (16, mGENERATExSUBSCRIPT2_MULTxR));
            putBITp (16, mGENERATExSET_USAGExRFORM, getBIT (8, mSYM2));
            putFIXED (mGENERATExSET_USAGExRVAR,
                      COREHALFWORD (getFIXED (mIND_STACK)
                                    + 73 * (COREHALFWORD (mLEFTOP)) + 40
                                    + 2 * (0)));
            putFIXED (mGENERATExSET_USAGExRXCON,
                      getFIXED (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mLEFTOP)) + 4
                                + 4 * (0)));
            GENERATExSET_USAGE (0);
          }
          // R_VAR2(R) = LOC(RIGHTOP); (8194)
          {
            descriptor_t *bitRHS = getBIT (
                16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP)) + 40
                        + 2 * (0));
            putBIT (16,
                    mR_VAR2 + 2 * (COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxR)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // R_XCON(R) = INX_CON(RIGHTOP); (8195)
          {
            int32_t numberRHS = (int32_t)(getFIXED (
                getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP)) + 4
                + 4 * (0)));
            putFIXED (mR_XCON
                          + 4 * (COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxR)),
                      numberRHS);
          }
          // R_MULT(R) = MULT; (8196)
          {
            descriptor_t *bitRHS = getBIT (16, mGENERATExSUBSCRIPT2_MULTxMULT);
            putBIT (16,
                    mR_MULT + 2 * (COREHALFWORD (mGENERATExSUBSCRIPT2_MULTxR)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
        es2s2:;
        } // End of DO block
      // RIGHTOP = 0; (8197)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mRIGHTOP, bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
