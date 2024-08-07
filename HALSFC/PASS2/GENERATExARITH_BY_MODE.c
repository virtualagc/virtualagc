/*
  File GENERATExARITH_BY_MODE.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExARITH_BY_MODE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExARITH_BY_MODE");
  // R_TYPE(REG(OP1)) = OPTYPE; (5263)
  {
    descriptor_t *bitRHS = getBIT (16, mGENERATExARITH_BY_MODExOPTYPE);
    putBIT (8,
            mR_TYPE
                + 1
                      * (COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                          + 46 + 2 * (0))),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // IF PACKTYPE(OPTYPE) = VECMAT THEN (5264)
  if (1
      & (xEQ (BYTE0 (mPACKTYPE
                     + 1 * COREHALFWORD (mGENERATExARITH_BY_MODExOPTYPE)),
              BYTE0 (mVECMAT))))
    // OPTYPE = OPTYPE&8 | SCALAR; (5265)
    {
      int32_t numberRHS = (int32_t)(xOR (
          xAND (COREHALFWORD (mGENERATExARITH_BY_MODExOPTYPE), 8),
          BYTE0 (mSCALAR)));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mGENERATExARITH_BY_MODExOPTYPE, bitRHS);
      bitRHS->inUse = 0;
    }
  // IF OPTYPE = DSCALAR THEN (5266)
  if (1
      & (xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOPTYPE),
              BYTE0 (mDSCALAR))))
    // IF OP=PREFIXMINUS | OP=20 | OP=BIFOPCODE(1) THEN (5267)
    if (1
        & (xOR (xOR (xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP),
                          BYTE0 (mGENERATExPREFIXMINUS)),
                     xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP), 20)),
                xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP),
                     COREHALFWORD (mGENERATExBIFOPCODE + 2 * 1)))))
      // OPTYPE = SCALAR; (5268)
      {
        descriptor_t *bitRHS = getBIT (8, mSCALAR);
        putBIT (16, mGENERATExARITH_BY_MODExOPTYPE, bitRHS);
        bitRHS->inUse = 0;
      }
  // IF BIAS = 0 THEN (5269)
  if (1 & (xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExBIAS), 0)))
    // IF FORM(OP2) = VAC THEN (5270)
    if (1
        & (xEQ (
            COREHALFWORD (getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 32 + 2 * (0)),
            BYTE0 (mVAC))))
      // BIAS = RR; (5271)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExRR);
        putBIT (16, mGENERATExARITH_BY_MODExBIAS, bitRHS);
        bitRHS->inUse = 0;
      }
    // ELSE (5272)
    else
      // BIAS = RX; (5273)
      {
        descriptor_t *bitRHS = getBIT (16, mGENERATExRX);
        putBIT (16, mGENERATExARITH_BY_MODExBIAS, bitRHS);
        bitRHS->inUse = 0;
      }
  // INST = MAKE_INST(OP, OPTYPE, BIAS); (5274)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mGENERATExMAKE_INSTxOPCODE,
                    getBIT (16, mGENERATExARITH_BY_MODExOP)),
           putBITp (16, mGENERATExMAKE_INSTxOPTYPE,
                    getBIT (16, mGENERATExARITH_BY_MODExOPTYPE)),
           putBITp (16, mGENERATExMAKE_INSTxOPFORM,
                    getBIT (16, mGENERATExARITH_BY_MODExBIAS)),
           GENERATExMAKE_INST (0));
    putBIT (16, mGENERATExARITH_BY_MODExINST, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF OP = XDIV & OPMODE(OPTYPE) = 4 & NEW_INSTRUCTIONS THEN (5275)
  if (1
      & (xAND (
          xAND (
              xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP), BYTE0 (mXDIV)),
              xEQ (BYTE0 (mOPMODE
                          + 1 * COREHALFWORD (mGENERATExARITH_BY_MODExOPTYPE)),
                   4)),
          BYTE0 (mNEW_INSTRUCTIONS))))
    // DO; (5276)
    {
    rs1:;
      // IF REG(OP1) = REG(OP2) THEN (5277)
      if (1
          & (xEQ (
              COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)),
              COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 46 + 2 * (0)))))
        // DO; (5278)
        {
        rs1s1:;
          // CALL EMITRR(LFLI, REG(OP1), 1); (5279)
          {
            putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mLFLI));
            putBITp (
                16, mGENERATExEMITRRxREG1,
                getBIT (16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
            putBITp (16, mGENERATExEMITRRxREG2, fixedToBit (32, (int32_t)(1)));
            GENERATExEMITRR (0);
          }
          // CALL EMITRR(LFLI, REG(OP1)+1, 0); (5280)
          {
            putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mLFLI));
            putBITp (
                16, mGENERATExEMITRRxREG1,
                fixedToBit (
                    32,
                    (int32_t)(xadd (
                        COREHALFWORD (
                            getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)),
                        1))));
            putBITp (16, mGENERATExEMITRRxREG2, fixedToBit (32, (int32_t)(0)));
            GENERATExEMITRR (0);
          }
          // CALL DROP_REG(OP2); (5281)
          {
            putBITp (16, mGENERATExDROP_REGxOP,
                     getBIT (16, mGENERATExARITH_BY_MODExOP2));
            GENERATExDROP_REG (0);
          }
        es1s1:;
        } // End of DO block
      // ELSE (5282)
      else
        // DO; (5283)
        {
        rs1s2:;
          // TEMP1 = GET_VAC(FINDAC(DOUBLE_FACC), OPTYPE); (5284)
          {
            descriptor_t *bitRHS
                = (putBITp (16, mGENERATExGET_VACxR,
                            (putBITp (16, mGENERATExFINDACxRCLASS,
                                      fixedToBit (32, (int32_t)(0))),
                             GENERATExFINDAC (0))),
                   putBITp (16, mGENERATExGET_VACxTYP,
                            getBIT (16, mGENERATExARITH_BY_MODExOPTYPE)),
                   GENERATExGET_VAC (0));
            putBIT (16, mGENERATExARITH_BY_MODExTEMP1, bitRHS);
            bitRHS->inUse = 0;
          }
          // CALL MOVEREG(REG(OP1), REG(TEMP1), OPTYPE, 0); (5285)
          {
            putBITp (
                16, mGENERATExMOVEREGxRF,
                getBIT (16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
            putBITp (16, mGENERATExMOVEREGxRT,
                     getBIT (16, getFIXED (mIND_STACK)
                                     + 73
                                           * (COREHALFWORD (
                                               mGENERATExARITH_BY_MODExTEMP1))
                                     + 46 + 2 * (0)));
            putBITp (16, mGENERATExMOVEREGxRTYPE,
                     getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
            putBITp (1, mGENERATExMOVEREGxUSED, fixedToBit (32, (int32_t)(0)));
            GENERATExMOVEREG (0);
          }
          // TEMP2 = FINDAC(DOUBLE_FACC); (5286)
          {
            descriptor_t *bitRHS = (putBITp (16, mGENERATExFINDACxRCLASS,
                                             fixedToBit (32, (int32_t)(0))),
                                    GENERATExFINDAC (0));
            putBIT (16, mGENERATExARITH_BY_MODExTEMP2, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF FORM(OP2) = VAC THEN (5287)
          if (1
              & (xEQ (COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 32 + 2 * (0)),
                      BYTE0 (mVAC))))
            // DO; (5288)
            {
            rs1s2s1:;
              // INST = MAKE_INST(OP, SCALAR, RR); (5289)
              {
                descriptor_t *bitRHS
                    = (putBITp (16, mGENERATExMAKE_INSTxOPCODE,
                                getBIT (16, mGENERATExARITH_BY_MODExOP)),
                       putBITp (16, mGENERATExMAKE_INSTxOPTYPE,
                                getBIT (8, mSCALAR)),
                       putBITp (16, mGENERATExMAKE_INSTxOPFORM,
                                getBIT (16, mGENERATExRR)),
                       GENERATExMAKE_INST (0));
                putBIT (16, mGENERATExARITH_BY_MODExINST, bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL EMITRR(INST, REG(OP1), REG(OP2)); (5290)
              {
                putBITp (16, mGENERATExEMITRRxINST,
                         getBIT (16, mGENERATExARITH_BY_MODExINST));
                putBITp (
                    16, mGENERATExEMITRRxREG1,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
                putBITp (
                    16, mGENERATExEMITRRxREG2,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 46 + 2 * (0)));
                GENERATExEMITRR (0);
              }
              // CALL MOVEREG(REG(OP1), TEMP2, OPTYPE, 0); (5291)
              {
                putBITp (
                    16, mGENERATExMOVEREGxRF,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
                putBITp (16, mGENERATExMOVEREGxRT,
                         getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                putBITp (16, mGENERATExMOVEREGxRTYPE,
                         getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                putBITp (1, mGENERATExMOVEREGxUSED,
                         fixedToBit (32, (int32_t)(0)));
                GENERATExMOVEREG (0);
              }
              // CALL EMITRR(MAKE_INST(XEXP, OPTYPE, RR), TEMP2, REG(OP2));
              // (5292)
              {
                putBITp (
                    16, mGENERATExEMITRRxINST,
                    (putBITp (16, mGENERATExMAKE_INSTxOPCODE,
                              getBIT (8, mXEXP)),
                     putBITp (16, mGENERATExMAKE_INSTxOPTYPE,
                              getBIT (16, mGENERATExARITH_BY_MODExOPTYPE)),
                     putBITp (16, mGENERATExMAKE_INSTxOPFORM,
                              getBIT (16, mGENERATExRR)),
                     GENERATExMAKE_INST (0)));
                putBITp (16, mGENERATExEMITRRxREG1,
                         getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                putBITp (
                    16, mGENERATExEMITRRxREG2,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 46 + 2 * (0)));
                GENERATExEMITRR (0);
              }
              // IF FORM(TEMP1) = VAC THEN (5293)
              if (1
                  & (xEQ (
                      COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExTEMP1))
                          + 32 + 2 * (0)),
                      BYTE0 (mVAC))))
                // CALL EMITRR(SDR, TEMP2, REG(TEMP1)); (5294)
                {
                  putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mSDR));
                  putBITp (16, mGENERATExEMITRRxREG1,
                           getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                  putBITp (
                      16, mGENERATExEMITRRxREG2,
                      getBIT (16, getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                mGENERATExARITH_BY_MODExTEMP1))
                                      + 46 + 2 * (0)));
                  GENERATExEMITRR (0);
                }
              // ELSE (5295)
              else
                // CALL EMIT_BY_MODE(MINUS, TEMP2, TEMP1, OPTYPE); (5296)
                {
                  putBITp (16, mGENERATExEMIT_BY_MODExOP,
                           getBIT (8, mGENERATExMINUS));
                  putBITp (16, mGENERATExEMIT_BY_MODExR,
                           getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                  putBITp (16, mGENERATExEMIT_BY_MODExOP2,
                           getBIT (16, mGENERATExARITH_BY_MODExTEMP1));
                  putBITp (16, mGENERATExEMIT_BY_MODExMODE,
                           getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                  GENERATExEMIT_BY_MODE (0);
                }
              // CALL EMITRR(INST, TEMP2, REG(OP2)); (5297)
              {
                putBITp (16, mGENERATExEMITRRxINST,
                         getBIT (16, mGENERATExARITH_BY_MODExINST));
                putBITp (16, mGENERATExEMITRRxREG1,
                         getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                putBITp (
                    16, mGENERATExEMITRRxREG2,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 46 + 2 * (0)));
                GENERATExEMITRR (0);
              }
              // CALL DROP_REG(OP2); (5298)
              {
                putBITp (16, mGENERATExDROP_REGxOP,
                         getBIT (16, mGENERATExARITH_BY_MODExOP2));
                GENERATExDROP_REG (0);
              }
            es1s2s1:;
            } // End of DO block
          // ELSE (5299)
          else
            // DO; (5300)
            {
            rs1s2s2:;
              // IF FORM(OP2) = LIT THEN (5301)
              if (1
                  & (xEQ (
                      COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 32 + 2 * (0)),
                      BYTE0 (mLIT))))
                // CALL SAVE_LITERAL(OP2, OPTYPE); (5302)
                {
                  putBITp (16, mGENERATExSAVE_LITERALxOP,
                           getBIT (16, mGENERATExARITH_BY_MODExOP2));
                  putBITp (16, mGENERATExSAVE_LITERALxOPTYPE,
                           getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                  GENERATExSAVE_LITERAL (0);
                }
              // ELSE (5303)
              else
                // CALL GUARANTEE_ADDRESSABLE(OP2, INST); (5304)
                {
                  putBITp (16, mGENERATExGUARANTEE_ADDRESSABLExOP,
                           getBIT (16, mGENERATExARITH_BY_MODExOP2));
                  putBITp (16, mGENERATExGUARANTEE_ADDRESSABLExINST,
                           getBIT (16, mGENERATExARITH_BY_MODExINST));
                  GENERATExGUARANTEE_ADDRESSABLE (0);
                }
              // CALL DROPSAVE(OP2); (5305)
              {
                putBITp (16, mGENERATExDROPSAVExENTRY,
                         getBIT (16, mGENERATExARITH_BY_MODExOP2));
                GENERATExDROPSAVE (0);
              }
              // IF INX(OP2) ~= 0 THEN (5306)
              if (1
                  & (xNEQ (
                      COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 34 + 2 * (0)),
                      0)))
                // DO; (5307)
                {
                rs1s2s2s1:;
                  // CALL FORCE_ADDRESS(-1, OP2, 1); (5308)
                  {
                    putBITp (16, mGENERATExFORCE_ADDRESSxTR,
                             fixedToBit (32, (int32_t)(-1)));
                    putBITp (16, mGENERATExFORCE_ADDRESSxOP,
                             getBIT (16, mGENERATExARITH_BY_MODExOP2));
                    putBITp (1, mGENERATExFORCE_ADDRESSxFLAG,
                             fixedToBit (32, (int32_t)(1)));
                    GENERATExFORCE_ADDRESS (0);
                  }
                  // FORM(OP2) = CSYM; (5309)
                  {
                    descriptor_t *bitRHS = getBIT (8, mCSYM);
                    putBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 32 + 2 * (0),
                        bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // BASE(OP2), BACKUP_REG(OP2) = REG(OP2); (5310)
                  {
                    descriptor_t *bitRHS = getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 46 + 2 * (0));
                    putBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 22 + 2 * (0),
                        bitRHS);
                    putBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 20 + 2 * (0),
                        bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // DISP(OP2), STRUCT_CON(OP2), INX_CON(OP2) = 0; (5311)
                  {
                    int32_t numberRHS = (int32_t)(0);
                    putBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 30 + 2 * (0),
                        fixedToBit (16, numberRHS));
                    putFIXED (
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 8 + 4 * (0),
                        numberRHS);
                    putFIXED (
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                            + 4 + 4 * (0),
                        numberRHS);
                  }
                es1s2s2s1:;
                } // End of DO block
              // IF FORM(OP2) = CSYM THEN (5312)
              if (1
                  & (xEQ (
                      COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 32 + 2 * (0)),
                      BYTE0 (mCSYM))))
                // USAGE(BASE(OP2)) = USAGE(BASE(OP2)) + 4; (5313)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (
                          mUSAGE
                          + 2
                                * COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExARITH_BY_MODExOP2))
                                    + 22 + 2 * (0))),
                      4));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16,
                          mUSAGE
                              + 2
                                    * (COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExARITH_BY_MODExOP2))
                                        + 22 + 2 * (0))),
                          bitRHS);
                  bitRHS->inUse = 0;
                }
              // INST = MAKE_INST(OP, SCALAR, RX); (5314)
              {
                descriptor_t *bitRHS
                    = (putBITp (16, mGENERATExMAKE_INSTxOPCODE,
                                getBIT (16, mGENERATExARITH_BY_MODExOP)),
                       putBITp (16, mGENERATExMAKE_INSTxOPTYPE,
                                getBIT (8, mSCALAR)),
                       putBITp (16, mGENERATExMAKE_INSTxOPFORM,
                                getBIT (16, mGENERATExRX)),
                       GENERATExMAKE_INST (0));
                putBIT (16, mGENERATExARITH_BY_MODExINST, bitRHS);
                bitRHS->inUse = 0;
              }
              // CALL EMITOP(INST, REG(OP1), OP2); (5315)
              {
                putBITp (16, mGENERATExEMITOPxINST,
                         getBIT (16, mGENERATExARITH_BY_MODExINST));
                putBITp (
                    16, mGENERATExEMITOPxXREG,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
                putBITp (16, mGENERATExEMITOPxOP,
                         getBIT (16, mGENERATExARITH_BY_MODExOP2));
                GENERATExEMITOP (0);
              }
              // CALL MOVEREG(REG(OP1), TEMP2, OPTYPE, 0); (5316)
              {
                putBITp (
                    16, mGENERATExMOVEREGxRF,
                    getBIT (
                        16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
                putBITp (16, mGENERATExMOVEREGxRT,
                         getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                putBITp (16, mGENERATExMOVEREGxRTYPE,
                         getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                putBITp (1, mGENERATExMOVEREGxUSED,
                         fixedToBit (32, (int32_t)(0)));
                GENERATExMOVEREG (0);
              }
              // CALL EMIT_BY_MODE(XEXP, TEMP2, OP2, OPTYPE); (5317)
              {
                putBITp (16, mGENERATExEMIT_BY_MODExOP, getBIT (8, mXEXP));
                putBITp (16, mGENERATExEMIT_BY_MODExR,
                         getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                putBITp (16, mGENERATExEMIT_BY_MODExOP2,
                         getBIT (16, mGENERATExARITH_BY_MODExOP2));
                putBITp (16, mGENERATExEMIT_BY_MODExMODE,
                         getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                GENERATExEMIT_BY_MODE (0);
              }
              // IF FORM(TEMP1) = VAC THEN (5318)
              if (1
                  & (xEQ (
                      COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExTEMP1))
                          + 32 + 2 * (0)),
                      BYTE0 (mVAC))))
                // CALL EMITRR(SDR, TEMP2, REG(TEMP1)); (5319)
                {
                  putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mSDR));
                  putBITp (16, mGENERATExEMITRRxREG1,
                           getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                  putBITp (
                      16, mGENERATExEMITRRxREG2,
                      getBIT (16, getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                mGENERATExARITH_BY_MODExTEMP1))
                                      + 46 + 2 * (0)));
                  GENERATExEMITRR (0);
                }
              // ELSE (5320)
              else
                // CALL EMIT_BY_MODE(MINUS, TEMP2, TEMP1, OPTYPE); (5321)
                {
                  putBITp (16, mGENERATExEMIT_BY_MODExOP,
                           getBIT (8, mGENERATExMINUS));
                  putBITp (16, mGENERATExEMIT_BY_MODExR,
                           getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                  putBITp (16, mGENERATExEMIT_BY_MODExOP2,
                           getBIT (16, mGENERATExARITH_BY_MODExTEMP1));
                  putBITp (16, mGENERATExEMIT_BY_MODExMODE,
                           getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                  GENERATExEMIT_BY_MODE (0);
                }
              // CALL EMITOP(INST, TEMP2, OP2); (5322)
              {
                putBITp (16, mGENERATExEMITOPxINST,
                         getBIT (16, mGENERATExARITH_BY_MODExINST));
                putBITp (16, mGENERATExEMITOPxXREG,
                         getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
                putBITp (16, mGENERATExEMITOPxOP,
                         getBIT (16, mGENERATExARITH_BY_MODExOP2));
                GENERATExEMITOP (0);
              }
            es1s2s2:;
            } // End of DO block
          // CALL EMITRR(SDR, REG(OP1), TEMP2); (5323)
          {
            putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mSDR));
            putBITp (
                16, mGENERATExEMITRRxREG1,
                getBIT (16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
            putBITp (16, mGENERATExEMITRRxREG2,
                     getBIT (16, mGENERATExARITH_BY_MODExTEMP2));
            GENERATExEMITRR (0);
          }
          // CALL DROPSAVE(TEMP1); (5324)
          {
            putBITp (16, mGENERATExDROPSAVExENTRY,
                     getBIT (16, mGENERATExARITH_BY_MODExTEMP1));
            GENERATExDROPSAVE (0);
          }
          // CALL DROP_VAC(TEMP1); (5325)
          {
            putBITp (16, mGENERATExDROP_VACxPTR,
                     getBIT (16, mGENERATExARITH_BY_MODExTEMP1));
            GENERATExDROP_VAC (0);
          }
          // USAGE(TEMP2) = 0; (5326)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16,
                    mUSAGE
                        + 2 * (COREHALFWORD (mGENERATExARITH_BY_MODExTEMP2)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
        es1s2:;
        } // End of DO block
    es1:;
    } // End of DO block
  // ELSE (5327)
  else
    // IF BIAS = RR THEN (5328)
    if (1
        & (xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExBIAS),
                COREHALFWORD (mGENERATExRR))))
      // DO; (5329)
      {
      rs2:;
        // IF OP = PREFIXMINUS & OPMODE(OPTYPE) = 3 THEN (5330)
        if (1
            & (xAND (
                xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP),
                     BYTE0 (mGENERATExPREFIXMINUS)),
                xEQ (BYTE0 (
                         mOPMODE
                         + 1 * COREHALFWORD (mGENERATExARITH_BY_MODExOPTYPE)),
                     3))))
          // CALL ZERO_TEST(REG(OP1), 2); (5331)
          {
            putBITp (
                16, mGENERATExARITH_BY_MODExZERO_TESTxR,
                getBIT (16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
            putBITp (16, mGENERATExARITH_BY_MODExZERO_TESTxN,
                     fixedToBit (32, (int32_t)(2)));
            GENERATExARITH_BY_MODExZERO_TEST (0);
          }
        // ELSE (5332)
        else
          // IF OP = XDIV & OPMODE(OPTYPE) = 4 THEN (5333)
          if (1
              & (xAND (xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP),
                            BYTE0 (mXDIV)),
                       xEQ (BYTE0 (mOPMODE
                                   + 1
                                         * COREHALFWORD (
                                             mGENERATExARITH_BY_MODExOPTYPE)),
                            4))))
            // CALL ZERO_TEST(REG(OP1), 2); (5334)
            {
              putBITp (16, mGENERATExARITH_BY_MODExZERO_TESTxR,
                       getBIT (16, getFIXED (mIND_STACK)
                                       + 73
                                             * (COREHALFWORD (
                                                 mGENERATExARITH_BY_MODExOP1))
                                       + 46 + 2 * (0)));
              putBITp (16, mGENERATExARITH_BY_MODExZERO_TESTxN,
                       fixedToBit (32, (int32_t)(2)));
              GENERATExARITH_BY_MODExZERO_TEST (0);
            }
        // CALL EMITRR(INST, REG(OP1), REG(OP2)); (5335)
        {
          putBITp (16, mGENERATExEMITRRxINST,
                   getBIT (16, mGENERATExARITH_BY_MODExINST));
          putBITp (
              16, mGENERATExEMITRRxREG1,
              getBIT (16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                          + 46 + 2 * (0)));
          putBITp (
              16, mGENERATExEMITRRxREG2,
              getBIT (16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 46 + 2 * (0)));
          GENERATExEMITRR (0);
        }
        // IF ~UNARY(OP) THEN (5336)
        if (1
            & (xNOT (BYTE0 (mGENERATExUNARY
                            + 1 * COREHALFWORD (mGENERATExARITH_BY_MODExOP)))))
          // IF OP1 ~= OP2 THEN (5337)
          if (1
              & (xNEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP1),
                       COREHALFWORD (mGENERATExARITH_BY_MODExOP2))))
            // CALL DROP_REG(OP2); (5338)
            {
              putBITp (16, mGENERATExDROP_REGxOP,
                       getBIT (16, mGENERATExARITH_BY_MODExOP2));
              GENERATExDROP_REG (0);
            }
      es2:;
      } // End of DO block
    // ELSE (5339)
    else
      // DO; (5340)
      {
      rs3:;
        // IF FORM(OP2) = LIT THEN (5341)
        if (1
            & (xEQ (COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                        + 32 + 2 * (0)),
                    BYTE0 (mLIT))))
          // DO; (5342)
          {
          rs3s1:;
            // IF OPMODE(OPTYPE) = 1 & AP101INST(INST+ 96) ~= 0 THEN (5343)
            if (1
                & (xAND (
                    xEQ (BYTE0 (mOPMODE
                                + 1
                                      * COREHALFWORD (
                                          mGENERATExARITH_BY_MODExOPTYPE)),
                         1),
                    xNEQ (COREHALFWORD (
                              mAP101INST
                              + 2
                                    * xadd (COREHALFWORD (
                                                mGENERATExARITH_BY_MODExINST),
                                            96)),
                          0))))
              // DO; (5344)
              {
              rs3s1s1:;
                // INST = INST +  96; (5345)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (mGENERATExARITH_BY_MODExINST), 96));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mGENERATExARITH_BY_MODExINST, bitRHS);
                  bitRHS->inUse = 0;
                }
                // FORM(OP2) = 0; (5346)
                {
                  int32_t numberRHS = (int32_t)(0);
                  putBIT (
                      16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 32 + 2 * (0),
                      fixedToBit (16, numberRHS));
                }
                // LOC(OP2) = VAL(OP2); (5347)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2)) + 12
                      + 4 * (0)));
                  putBIT (
                      16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP2))
                          + 40 + 2 * (0),
                      fixedToBit (16, numberRHS));
                }
              es3s1s1:;
              } // End of DO block
            // ELSE (5348)
            else
              // CALL SAVE_LITERAL(OP2, OPTYPE); (5349)
              {
                putBITp (16, mGENERATExSAVE_LITERALxOP,
                         getBIT (16, mGENERATExARITH_BY_MODExOP2));
                putBITp (16, mGENERATExSAVE_LITERALxOPTYPE,
                         getBIT (16, mGENERATExARITH_BY_MODExOPTYPE));
                GENERATExSAVE_LITERAL (0);
              }
          es3s1:;
          } // End of DO block
        // ELSE (5350)
        else
          // CALL GUARANTEE_ADDRESSABLE(OP2, INST); (5351)
          {
            putBITp (16, mGENERATExGUARANTEE_ADDRESSABLExOP,
                     getBIT (16, mGENERATExARITH_BY_MODExOP2));
            putBITp (16, mGENERATExGUARANTEE_ADDRESSABLExINST,
                     getBIT (16, mGENERATExARITH_BY_MODExINST));
            GENERATExGUARANTEE_ADDRESSABLE (0);
          }
        // IF OP = XDIV & OPMODE(OPTYPE) = 4 THEN (5352)
        if (1
            & (xAND (
                xEQ (COREHALFWORD (mGENERATExARITH_BY_MODExOP), BYTE0 (mXDIV)),
                xEQ (BYTE0 (
                         mOPMODE
                         + 1 * COREHALFWORD (mGENERATExARITH_BY_MODExOPTYPE)),
                     4))))
          // CALL ZERO_TEST(REG(OP1), 3); (5353)
          {
            putBITp (
                16, mGENERATExARITH_BY_MODExZERO_TESTxR,
                getBIT (16,
                        getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                            + 46 + 2 * (0)));
            putBITp (16, mGENERATExARITH_BY_MODExZERO_TESTxN,
                     fixedToBit (32, (int32_t)(3)));
            GENERATExARITH_BY_MODExZERO_TEST (0);
          }
        // CALL EMITOP(INST, REG(OP1), OP2); (5354)
        {
          putBITp (16, mGENERATExEMITOPxINST,
                   getBIT (16, mGENERATExARITH_BY_MODExINST));
          putBITp (
              16, mGENERATExEMITOPxXREG,
              getBIT (16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                          + 46 + 2 * (0)));
          putBITp (16, mGENERATExEMITOPxOP,
                   getBIT (16, mGENERATExARITH_BY_MODExOP2));
          GENERATExEMITOP (0);
        }
        // CALL DROP_INX(OP2); (5355)
        {
          putBITp (16, mGENERATExDROP_INXxOP,
                   getBIT (16, mGENERATExARITH_BY_MODExOP2));
          GENERATExDROP_INX (0);
        }
        // CALL DROPSAVE(OP2); (5356)
        {
          putBITp (16, mGENERATExDROPSAVExENTRY,
                   getBIT (16, mGENERATExARITH_BY_MODExOP2));
          GENERATExDROPSAVE (0);
        }
      es3:;
      } // End of DO block
  // IF DESTRUCTIVE(OP) THEN (5357)
  if (1
      & (bitToFixed (
          getBIT (8, mGENERATExDESTRUCTIVE
                         + 1 * COREHALFWORD (mGENERATExARITH_BY_MODExOP)))))
    // CALL UNRECOGNIZABLE(REG(OP1)); (5358)
    {
      putBITp (
          16, mGENERATExUNRECOGNIZABLExR,
          getBIT (16, getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExARITH_BY_MODExOP1))
                          + 46 + 2 * (0)));
      GENERATExUNRECOGNIZABLE (0);
    }
  // BIAS = 0; (5359)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExARITH_BY_MODExBIAS, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
