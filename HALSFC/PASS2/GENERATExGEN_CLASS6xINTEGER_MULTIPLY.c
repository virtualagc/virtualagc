/*
  File GENERATExGEN_CLASS6xINTEGER_MULTIPLY.c generated by XCOM-I, 2024-08-09
  12:39:31.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS6xINTEGER_MULTIPLY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS6xINTEGER_MULTIPLY");
  // CALL GET_OPERANDS; (13428)
  GENERATExGET_OPERANDS (0);
  // IF TAG & FORM(RIGHTOP) = LIT THEN (13429)
  if (1
      & (xAND (
          COREHALFWORD (mTAG),
          xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mRIGHTOP)) + 32 + 2 * (0)),
               BYTE0 (mLIT)))))
    // DO; (13430)
    {
    rs1:;
      // TO_BE_INCORPORATED = FALSE; (13431)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mGENERATExTO_BE_INCORPORATED, bitRHS);
        bitRHS->inUse = 0;
      }
      // TO_BE_MODIFIED = TRUE; (13432)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF FORM(LEFTOP) ~= SYM | INX(LEFTOP) ~= 0 THEN (13433)
      if (1
          & (xOR (xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mLEFTOP)) + 32
                                      + 2 * (0)),
                        BYTE0 (mSYM)),
                  xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mLEFTOP)) + 34
                                      + 2 * (0)),
                        0))))
        // CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG); (13434)
        {
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOP, getBIT (16, mLEFTOP));
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
                   getBIT (8, mINTEGER));
          putBITp (16, mGENERATExFORCE_ACCUMULATORxACCLASS,
                   fixedToBit (32, (int32_t)(4)));
          GENERATExFORCE_ACCUMULATOR (0);
        }
      // TMP = CONST(LEFTOP) * VAL(RIGHTOP); (13435)
      {
        int32_t numberRHS = (int32_t)(xmultiply (
            getFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 0
                      + 4 * (0)),
            getFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP))
                      + 12 + 4 * (0))));
        putFIXED (mTMP, numberRHS);
      }
      // CALL SUBSCRIPT2_MULT(VAL(RIGHTOP)); (13436)
      {
        putBITp (16, mGENERATExSUBSCRIPT2_MULTxMULT,
                 fixedToBit (
                     32, (int32_t)(getFIXED (getFIXED (mIND_STACK)
                                             + 73 * (COREHALFWORD (mRIGHTOP))
                                             + 12 + 4 * (0)))));
        GENERATExSUBSCRIPT2_MULT (0);
      }
      // CONST(LEFTOP) = TMP; (13437)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mTMP));
        putFIXED (getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 0
                      + 4 * (0),
                  numberRHS);
      }
      // CALL RETURN_STACK_ENTRY(RIGHTOP); (13438)
      {
        putBITp (16, mGENERATExRETURN_STACK_ENTRYxP, getBIT (16, mRIGHTOP));
        GENERATExRETURN_STACK_ENTRY (0);
      }
    es1:;
    } // End of DO block
  // ELSE (13439)
  else
    // DO; (13440)
    {
    rs2:;
      // IF FORM(LEFTOP) = VAC & FORM(RIGHTOP) = VAC THEN (13441)
      if (1
          & (xAND (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mLEFTOP)) + 32
                                      + 2 * (0)),
                        BYTE0 (mVAC)),
                   xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                      + 2 * (0)),
                        BYTE0 (mVAC)))))
        // DO; (13442)
        {
        rs2s1:;
          // IF USAGE(REG(LEFTOP))<4 & USAGE(REG(RIGHTOP))<4 THEN (13443)
          if (1
              & (xAND (
                  xLT (COREHALFWORD (mUSAGE
                                     + 2
                                           * COREHALFWORD (
                                               getFIXED (mIND_STACK)
                                               + 73 * (COREHALFWORD (mLEFTOP))
                                               + 46 + 2 * (0))),
                       4),
                  xLT (COREHALFWORD (mUSAGE
                                     + 2
                                           * COREHALFWORD (
                                               getFIXED (mIND_STACK)
                                               + 73 * (COREHALFWORD (mRIGHTOP))
                                               + 46 + 2 * (0))),
                       4))))
            // DO; (13444)
            {
            rs2s1s1:;
              // CALL INCORPORATE(LEFTOP); (13445)
              {
                putBITp (16, mGENERATExINCORPORATExOP, getBIT (16, mLEFTOP));
                GENERATExINCORPORATE (0);
              }
              // CALL INCORPORATE(RIGHTOP); (13446)
              {
                putBITp (16, mGENERATExINCORPORATExOP, getBIT (16, mRIGHTOP));
                GENERATExINCORPORATE (0);
              }
              // IF REG(RIGHTOP)-REG(LEFTOP) = 1 & REG(RIGHTOP) |
              // PAIRED(LEFTOP) THEN (13447)
              if (1
                  & (xOR (
                      xAND (
                          xEQ (xsubtract (COREHALFWORD (
                                              getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mRIGHTOP))
                                              + 46 + 2 * (0)),
                                          COREHALFWORD (
                                              getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mLEFTOP))
                                              + 46 + 2 * (0))),
                               1),
                          COREHALFWORD (getFIXED (mIND_STACK)
                                        + 73 * (COREHALFWORD (mRIGHTOP)) + 46
                                        + 2 * (0))),
                      bitToFixed (
                          (putBITp (
                               16,
                               mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxPAIREDxOP,
                               getBIT (16, mLEFTOP)),
                           GENERATExGEN_CLASS6xINTEGER_MULTIPLYxPAIRED (0))))))
                // DO; (13448)
                {
                rs2s1s1s1:;
                  // CALL DO_MR(LEFTOP, RIGHTOP); (13449)
                  {
                    putBITp (16,
                             mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MRxOP1,
                             getBIT (16, mLEFTOP));
                    putBITp (16,
                             mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MRxOP2,
                             getBIT (16, mRIGHTOP));
                    GENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MR (0);
                  }
                es2s1s1s1:;
                } // End of DO block
              // ELSE (13450)
              else
                // IF REG(LEFTOP)-REG(RIGHTOP) = 1 & REG(LEFTOP) |
                // PAIRED(RIGHTOP) THEN (13451)
                if (1
                    & (xOR (
                        xAND (xEQ (xsubtract (
                                       COREHALFWORD (
                                           getFIXED (mIND_STACK)
                                           + 73 * (COREHALFWORD (mLEFTOP)) + 46
                                           + 2 * (0)),
                                       COREHALFWORD (
                                           getFIXED (mIND_STACK)
                                           + 73 * (COREHALFWORD (mRIGHTOP))
                                           + 46 + 2 * (0))),
                                   1),
                              COREHALFWORD (getFIXED (mIND_STACK)
                                            + 73 * (COREHALFWORD (mLEFTOP))
                                            + 46 + 2 * (0))),
                        bitToFixed ((
                            putBITp (
                                16,
                                mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxPAIREDxOP,
                                getBIT (16, mRIGHTOP)),
                            GENERATExGEN_CLASS6xINTEGER_MULTIPLYxPAIRED (
                                0))))))
                  // DO; (13452)
                  {
                  rs2s1s1s2:;
                    // CALL DO_MR(RIGHTOP, LEFTOP); (13453)
                    {
                      putBITp (16,
                               mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MRxOP1,
                               getBIT (16, mRIGHTOP));
                      putBITp (16,
                               mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MRxOP2,
                               getBIT (16, mLEFTOP));
                      GENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MR (0);
                    }
                    // CALL COMMUTEM; (13454)
                    GENERATExCOMMUTEM (0);
                  es2s1s1s2:;
                  } // End of DO block
                // ELSE (13455)
                else
                  // GO TO NEW_RR; (13456)
                  goto NEW_RR;
            es2s1s1:;
            } // End of DO block
          // ELSE (13457)
          else
            // DO; (13458)
            {
            rs2s1s2:;
              // IF USAGE(REG(LEFTOP))>USAGE(REG(RIGHTOP)) THEN (13459)
              if (1
                  & (xGT (
                      COREHALFWORD (
                          mUSAGE
                          + 2
                                * COREHALFWORD (getFIXED (mIND_STACK)
                                                + 73 * (COREHALFWORD (mLEFTOP))
                                                + 46 + 2 * (0))),
                      COREHALFWORD (mUSAGE
                                    + 2
                                          * COREHALFWORD (
                                              getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mRIGHTOP))
                                              + 46 + 2 * (0))))))
                // CALL COMMUTEM; (13460)
                GENERATExCOMMUTEM (0);
            // NEW_RR: (13461)
            NEW_RR:
              // CALL GET_TARGET; (13462)
              GENERATExGEN_CLASS6xINTEGER_MULTIPLYxGET_TARGET (0);
              // TO_BE_MODIFIED = TRUE; (13463)
              {
                int32_t numberRHS = (int32_t)(1);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL FORCE_ACCUMULATOR(LEFTOP); (13464)
              {
                putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                         getBIT (16, mLEFTOP));
                GENERATExFORCE_ACCUMULATOR (0);
              }
              // TARGET_REGISTER = -1; (13465)
              {
                int32_t numberRHS = (int32_t)(-1);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mTARGET_REGISTER, bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL FORCE_ACCUMULATOR(RIGHTOP); (13466)
              {
                putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                         getBIT (16, mRIGHTOP));
                GENERATExFORCE_ACCUMULATOR (0);
              }
              // CALL DO_MR(LEFTOP, RIGHTOP); (13467)
              {
                putBITp (16, mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MRxOP1,
                         getBIT (16, mLEFTOP));
                putBITp (16, mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MRxOP2,
                         getBIT (16, mRIGHTOP));
                GENERATExGEN_CLASS6xINTEGER_MULTIPLYxDO_MR (0);
              }
            es2s1s2:;
            } // End of DO block
          // CALL RETURN_STACK_ENTRY(RIGHTOP); (13468)
          {
            putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
                     getBIT (16, mRIGHTOP));
            GENERATExRETURN_STACK_ENTRY (0);
          }
        es2s1:;
        } // End of DO block
      // ELSE (13469)
      else
        // DO; (13470)
        {
        rs2s2:;
          // IF SHOULD_COMMUTE(OPCODE) THEN (13471)
          if (1
              & ((putBITp (
                      16, mGENERATExSHOULD_COMMUTExOPCODE,
                      getBIT (16,
                              mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxOPCODE)),
                  GENERATExSHOULD_COMMUTE (0))))
            // CALL COMMUTEM; (13472)
            GENERATExCOMMUTEM (0);
          // LEFTR = SEARCH_REGS(LEFTOP); (13473)
          {
            int32_t numberRHS = (int32_t)((
                putBITp (16, mGENERATExSEARCH_REGSxOP, getBIT (16, mLEFTOP)),
                GENERATExSEARCH_REGS (0)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxLEFTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // RIGHTR = SEARCH_REGS(RIGHTOP); (13474)
          {
            int32_t numberRHS = (int32_t)((
                putBITp (16, mGENERATExSEARCH_REGSxOP, getBIT (16, mRIGHTOP)),
                GENERATExSEARCH_REGS (0)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRIGHTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF LEFTR >= 0 THEN (13475)
          if (1
              & (xGE (
                  COREHALFWORD (mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxLEFTR),
                  0)))
            // TYPE(LEFTOP) = R_TYPE(LEFTR); (13476)
            {
              descriptor_t *bitRHS = getBIT (
                  8,
                  mR_TYPE
                      + 1
                            * COREHALFWORD (
                                mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxLEFTR));
              putBIT (16,
                      getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                          + 50 + 2 * (0),
                      bitRHS);
              bitRHS->inUse = 0;
            }
          // IF RIGHTR >= 0 THEN (13477)
          if (1
              & (xGE (
                  COREHALFWORD (mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRIGHTR),
                  0)))
            // TYPE(RIGHTOP) = R_TYPE(RIGHTR); (13478)
            {
              descriptor_t *bitRHS = getBIT (
                  8,
                  mR_TYPE
                      + 1
                            * COREHALFWORD (
                                mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRIGHTR));
              putBIT (16,
                      getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP))
                          + 50 + 2 * (0),
                      bitRHS);
              bitRHS->inUse = 0;
            }
          // LREG = LEFTR>=0 | FORM(LEFTOP) = VAC; (13479)
          {
            int32_t numberRHS = (int32_t)(xOR (
                xGE (
                    COREHALFWORD (mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxLEFTR),
                    0),
                xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                   + 73 * (COREHALFWORD (mLEFTOP)) + 32
                                   + 2 * (0)),
                     BYTE0 (mVAC))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxLREG, bitRHS);
            bitRHS->inUse = 0;
          }
          // RREG = RIGHTR>=0 | FORM(RIGHTOP) = VAC; (13480)
          {
            int32_t numberRHS = (int32_t)(xOR (
                xGE (COREHALFWORD (
                         mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRIGHTR),
                     0),
                xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                   + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                   + 2 * (0)),
                     BYTE0 (mVAC))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRREG, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF LREG & RREG THEN (13481)
          if (1
              & (xAND (BYTE0 (mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxLREG),
                       BYTE0 (mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRREG))))
            // GO TO NEW_RR; (13482)
            goto NEW_RR;
          // IF FORM(LEFTOP)=FORM(RIGHTOP) & LOC(LEFTOP)=LOC(RIGHTOP) THEN
          // (13483)
          if (1
              & (xAND (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                          + 73 * (COREHALFWORD (mLEFTOP)) + 32
                                          + 2 * (0)),
                            COREHALFWORD (getFIXED (mIND_STACK)
                                          + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                          + 2 * (0))),
                       xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                          + 73 * (COREHALFWORD (mLEFTOP)) + 40
                                          + 2 * (0)),
                            COREHALFWORD (getFIXED (mIND_STACK)
                                          + 73 * (COREHALFWORD (mRIGHTOP)) + 40
                                          + 2 * (0))))))
            // GO TO NEW_RR; (13484)
            goto NEW_RR;
          // IF POWER_OF_TWO(RIGHTOP) THEN (13485)
          if (1
              & (bitToFixed ((putBITp (16, mGENERATExPOWER_OF_TWOxOP,
                                       getBIT (16, mRIGHTOP)),
                              GENERATExPOWER_OF_TWO (0)))))
            // DO; (13486)
            {
            rs2s2s1:;
              // TO_BE_MODIFIED = INX_SHIFT(0) > 0; (13487)
              {
                int32_t numberRHS = (int32_t)(xGT (
                    BYTE0 (getFIXED (mIND_STACK) + 73 * (0) + 64 + 1 * (0)),
                    0));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL FORCE_ACCUMULATOR(LEFTOP); (13488)
              {
                putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                         getBIT (16, mLEFTOP));
                GENERATExFORCE_ACCUMULATOR (0);
              }
              // IF INX_SHIFT(0) > 0 THEN (13489)
              if (1
                  & (xGT (
                      BYTE0 (getFIXED (mIND_STACK) + 73 * (0) + 64 + 1 * (0)),
                      0)))
                // DO; (13490)
                {
                rs2s2s1s1:;
                  // DO CASE INX_SHIFT(0) ~= 1; (13491)
                  {
                  rs2s2s1s1s1:
                    switch (xNEQ (BYTE0 (getFIXED (mIND_STACK) + 73 * (0) + 64
                                         + 1 * (0)),
                                  1))
                      {
                      case 0:
                        // CALL EMITRR(AR, REG(LEFTOP), REG(LEFTOP)); (13493)
                        {
                          putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mAR));
                          putBITp (
                              16, mGENERATExEMITRRxREG1,
                              getBIT (16, getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mLEFTOP))
                                              + 46 + 2 * (0)));
                          putBITp (
                              16, mGENERATExEMITRRxREG2,
                              getBIT (16, getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mLEFTOP))
                                              + 46 + 2 * (0)));
                          GENERATExEMITRR (0);
                        }
                        break;
                      case 1:
                        // CALL EMITP(SLA, REG(LEFTOP), 0, SHCOUNT,
                        // INX_SHIFT(0)); (13494)
                        {
                          putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSLL));
                          putBITp (
                              16, mGENERATExEMITPxXREG,
                              getBIT (16, getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mLEFTOP))
                                              + 46 + 2 * (0)));
                          putBITp (16, mGENERATExEMITPxINDEX,
                                   fixedToBit (32, (int32_t)(0)));
                          putBITp (16, mGENERATExEMITPxFLAG,
                                   getBIT (8, mSHCOUNT));
                          putBITp (16, mGENERATExEMITPxPTR,
                                   getBIT (8, getFIXED (mIND_STACK) + 73 * (0)
                                                  + 64 + 1 * (0)));
                          GENERATExEMITP (0);
                        }
                        break;
                      }
                  } // End of DO CASE block
                  // CALL UNRECOGNIZABLE(REG(LEFTOP)); (13494)
                  {
                    putBITp (16, mGENERATExUNRECOGNIZABLExR,
                             getBIT (16, getFIXED (mIND_STACK)
                                             + 73 * (COREHALFWORD (mLEFTOP))
                                             + 46 + 2 * (0)));
                    GENERATExUNRECOGNIZABLE (0);
                  }
                es2s2s1s1:;
                } // End of DO block
              // CALL RETURN_STACK_ENTRY(RIGHTOP); (13495)
              {
                putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
                         getBIT (16, mRIGHTOP));
                GENERATExRETURN_STACK_ENTRY (0);
              }
            es2s2s1:;
            } // End of DO block
          // ELSE (13496)
          else
            // IF OPTYPE = INTEGER & CONST(RIGHTOP) = 0 & ~RREG THEN (13497)
            if (1
                & (xAND (xAND (xEQ (COREHALFWORD (mOPTYPE), BYTE0 (mINTEGER)),
                               xEQ (getFIXED (getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mRIGHTOP))
                                              + 0 + 4 * (0)),
                                    0)),
                         xNOT (BYTE0 (
                             mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxRREG)))))
              // DO; (13498)
              {
              rs2s2s2:;
                // CALL EXPRESSION(XEXP); (13499)
                {
                  putBITp (16, mGENERATExEXPRESSIONxOPCODE, getBIT (8, mXEXP));
                  GENERATExEXPRESSION (0);
                }
                // CALL EMITP(SLL, REG(LEFTOP), 0, SHCOUNT, 15); (13500)
                {
                  putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSLL));
                  putBITp (16, mGENERATExEMITPxXREG,
                           getBIT (16, getFIXED (mIND_STACK)
                                           + 73 * (COREHALFWORD (mLEFTOP)) + 46
                                           + 2 * (0)));
                  putBITp (16, mGENERATExEMITPxINDEX,
                           fixedToBit (32, (int32_t)(0)));
                  putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
                  putBITp (16, mGENERATExEMITPxPTR,
                           fixedToBit (32, (int32_t)(15)));
                  GENERATExEMITP (0);
                }
              es2s2s2:;
              } // End of DO block
            // ELSE (13501)
            else
              // DO; (13502)
              {
              rs2s2s3:;
                // CALL GET_TARGET; (13503)
                GENERATExGEN_CLASS6xINTEGER_MULTIPLYxGET_TARGET (0);
                // TO_BE_MODIFIED = TRUE; (13504)
                {
                  int32_t numberRHS = (int32_t)(1);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (1, mGENERATExTO_BE_MODIFIED, bitRHS);
                  bitRHS->inUse = 0;
                }
                // CALL FORCE_ACCUMULATOR(LEFTOP); (13505)
                {
                  putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                           getBIT (16, mLEFTOP));
                  GENERATExFORCE_ACCUMULATOR (0);
                }
                // TARGET_REGISTER = -1; (13506)
                {
                  int32_t numberRHS = (int32_t)(-1);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mTARGET_REGISTER, bitRHS);
                  bitRHS->inUse = 0;
                }
                // CALL SET_LEFTOP_REG(LEFTOP); (13507)
                {
                  putBITp (
                      16,
                      mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REGxOP,
                      getBIT (16, mLEFTOP));
                  GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_LEFTOP_REG (0);
                }
                // CALL EXPRESSION(XEXP); (13508)
                {
                  putBITp (16, mGENERATExEXPRESSIONxOPCODE, getBIT (8, mXEXP));
                  GENERATExEXPRESSION (0);
                }
                // CALL SET_RESULT_REG(LEFTOP, RIGHTOP); (13509)
                {
                  putBITp (
                      16,
                      mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1,
                      getBIT (16, mLEFTOP));
                  putBITp (
                      16,
                      mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP2,
                      getBIT (16, mRIGHTOP));
                  GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REG (0);
                }
              es2s2s3:;
              } // End of DO block
        es2s2:;
        } // End of DO block
      // TYPE(LEFTOP), R_TYPE(REG(LEFTOP)) = OPTYPE; (13510)
      {
        descriptor_t *bitRHS = getBIT (16, mOPTYPE);
        putBIT (16,
                getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP)) + 50
                    + 2 * (0),
                bitRHS);
        putBIT (8,
                mR_TYPE
                    + 1
                          * (COREHALFWORD (getFIXED (mIND_STACK)
                                           + 73 * (COREHALFWORD (mLEFTOP)) + 46
                                           + 2 * (0))),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL UNRECOGNIZABLE(REG(LEFTOP)); (13511)
      {
        putBITp (16, mGENERATExUNRECOGNIZABLExR,
                 getBIT (16, getFIXED (mIND_STACK)
                                 + 73 * (COREHALFWORD (mLEFTOP)) + 46
                                 + 2 * (0)));
        GENERATExUNRECOGNIZABLE (0);
      }
    es2:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}