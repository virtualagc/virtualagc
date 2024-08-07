/*
  File GENERATExFORCE_BY_MODE.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExFORCE_BY_MODE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExFORCE_BY_MODE");
  // IF CVTTYPE(MODE) = CVTTYPE(TYPE(OP)) THEN (6802)
  if (1
      & (xEQ (
          BYTE0 (mCVTTYPE + 1 * COREHALFWORD (mGENERATExFORCE_BY_MODExMODE)),
          BYTE0 (mCVTTYPE
                 + 1
                       * COREHALFWORD (
                           getFIXED (mIND_STACK)
                           + 73 * (COREHALFWORD (mGENERATExFORCE_BY_MODExOP))
                           + 50 + 2 * (0))))))
    // CALL FORCE_ACCUMULATOR(OP, MODE, RTYPE); (6803)
    {
      putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
               getBIT (16, mGENERATExFORCE_BY_MODExOP));
      putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
               getBIT (16, mGENERATExFORCE_BY_MODExMODE));
      putBITp (16, mGENERATExFORCE_ACCUMULATORxACCLASS,
               getBIT (16, mGENERATExFORCE_BY_MODExRTYPE));
      GENERATExFORCE_ACCUMULATOR (0);
    }
  // ELSE (6804)
  else
    // IF OPMODE(TYPE(OP)) = 1 & DATATYPE(MODE) = SCALAR THEN (6805)
    if (1
        & (xAND (
            xEQ (BYTE0 (mOPMODE
                        + 1
                              * COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExFORCE_BY_MODExOP))
                                  + 50 + 2 * (0))),
                 1),
            xEQ (BYTE0 (mDATATYPE
                        + 1 * COREHALFWORD (mGENERATExFORCE_BY_MODExMODE)),
                 BYTE0 (mSCALAR)))))
      // DO; (6806)
      {
      rs1:;
        // TEMPR = TARGET_REGISTER; (6807)
        {
          descriptor_t *bitRHS = getBIT (16, mTARGET_REGISTER);
          putBIT (16, mGENERATExFORCE_BY_MODExTEMPR, bitRHS);
          bitRHS->inUse = 0;
        }
        // TARGET_REGISTER = -1; (6808)
        {
          int32_t numberRHS = (int32_t)(-1);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mTARGET_REGISTER, bitRHS);
          bitRHS->inUse = 0;
        }
        // CALL FORCE_ACCUMULATOR(OP); (6809)
        {
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                   getBIT (16, mGENERATExFORCE_BY_MODExOP));
          GENERATExFORCE_ACCUMULATOR (0);
        }
        // TARGET_REGISTER = TEMPR; (6810)
        {
          descriptor_t *bitRHS = getBIT (16, mGENERATExFORCE_BY_MODExTEMPR);
          putBIT (16, mTARGET_REGISTER, bitRHS);
          bitRHS->inUse = 0;
        }
        // TEMPR = FINDAC(RCLASS(MODE)); (6811)
        {
          descriptor_t *bitRHS
              = (putBITp (
                     16, mGENERATExFINDACxRCLASS,
                     getBIT (8, mRCLASS
                                    + 1
                                          * COREHALFWORD (
                                              mGENERATExFORCE_BY_MODExMODE))),
                 GENERATExFINDAC (0));
          putBIT (16, mGENERATExFORCE_BY_MODExTEMPR, bitRHS);
          bitRHS->inUse = 0;
        }
        // IF MODE = DSCALAR THEN (6812)
        if (1
            & (xEQ (COREHALFWORD (mGENERATExFORCE_BY_MODExMODE),
                    BYTE0 (mDSCALAR))))
          // CALL EMITRR(MAKE_INST(EXOR, SCALAR, RR), TEMPR+1, TEMPR+1); (6813)
          {
            putBITp (
                16, mGENERATExEMITRRxINST,
                (putBITp (16, mGENERATExMAKE_INSTxOPCODE,
                          getBIT (16, mGENERATExEXOR)),
                 putBITp (16, mGENERATExMAKE_INSTxOPTYPE, getBIT (8, mSCALAR)),
                 putBITp (16, mGENERATExMAKE_INSTxOPFORM,
                          getBIT (16, mGENERATExRR)),
                 GENERATExMAKE_INST (0)));
            putBITp (16, mGENERATExEMITRRxREG1,
                     fixedToBit (
                         32, (int32_t)(xadd (
                                 COREHALFWORD (mGENERATExFORCE_BY_MODExTEMPR),
                                 1))));
            putBITp (16, mGENERATExEMITRRxREG2,
                     fixedToBit (
                         32, (int32_t)(xadd (
                                 COREHALFWORD (mGENERATExFORCE_BY_MODExTEMPR),
                                 1))));
            GENERATExEMITRR (0);
          }
        // CALL EMITRR(CVFL, TEMPR, REG(OP)); (6814)
        {
          putBITp (16, mGENERATExEMITRRxINST, getBIT (8, mCVFL));
          putBITp (16, mGENERATExEMITRRxREG1,
                   getBIT (16, mGENERATExFORCE_BY_MODExTEMPR));
          putBITp (
              16, mGENERATExEMITRRxREG2,
              getBIT (16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExFORCE_BY_MODExOP))
                          + 46 + 2 * (0)));
          GENERATExEMITRR (0);
        }
        // CALL DROP_REG(OP); (6815)
        {
          putBITp (16, mGENERATExDROP_REGxOP,
                   getBIT (16, mGENERATExFORCE_BY_MODExOP));
          GENERATExDROP_REG (0);
        }
        // CALL SET_RESULT_REG(OP, MODE, TEMPR); (6816)
        {
          putBITp (16, mGENERATExSET_RESULT_REGxOP,
                   getBIT (16, mGENERATExFORCE_BY_MODExOP));
          putBITp (16, mGENERATExSET_RESULT_REGxOPTYPE,
                   getBIT (16, mGENERATExFORCE_BY_MODExMODE));
          putBITp (16, mGENERATExSET_RESULT_REGxOPMOD,
                   getBIT (16, mGENERATExFORCE_BY_MODExTEMPR));
          GENERATExSET_RESULT_REG (0);
        }
      es1:;
      } // End of DO block
    // ELSE (6817)
    else
      // DO; (6818)
      {
      rs2:;
        // MODEX = DATATYPE(MODE) ~= SCALAR; (6819)
        {
          int32_t numberRHS = (int32_t)(xNEQ (
              BYTE0 (mDATATYPE
                     + 1 * COREHALFWORD (mGENERATExFORCE_BY_MODExMODE)),
              BYTE0 (mSCALAR)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mGENERATExFORCE_BY_MODExMODEX, bitRHS);
          bitRHS->inUse = 0;
        }
        // TEMPR = TARGET_REGISTER; (6820)
        {
          descriptor_t *bitRHS = getBIT (16, mTARGET_REGISTER);
          putBIT (16, mGENERATExFORCE_BY_MODExTEMPR, bitRHS);
          bitRHS->inUse = 0;
        }
        // TARGET_REGISTER = FREG(MODEX); (6821)
        {
          descriptor_t *bitRHS = getBIT (
              16, mGENERATExFORCE_BY_MODExFREG
                      + 2 * COREHALFWORD (mGENERATExFORCE_BY_MODExMODEX));
          putBIT (16, mTARGET_REGISTER, bitRHS);
          bitRHS->inUse = 0;
        }
        // CALL FORCE_ACCUMULATOR(OP); (6822)
        {
          putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                   getBIT (16, mGENERATExFORCE_BY_MODExOP));
          GENERATExFORCE_ACCUMULATOR (0);
        }
        // CALL DROP_REG(OP); (6823)
        {
          putBITp (16, mGENERATExDROP_REGxOP,
                   getBIT (16, mGENERATExFORCE_BY_MODExOP));
          GENERATExDROP_REG (0);
        }
        // CALL UNRECOGNIZABLE(TARGET_REGISTER); (6824)
        {
          putBITp (16, mGENERATExUNRECOGNIZABLExR,
                   getBIT (16, mTARGET_REGISTER));
          GENERATExUNRECOGNIZABLE (0);
        }
        // TARGET_REGISTER = TEMPR; (6825)
        {
          descriptor_t *bitRHS = getBIT (16, mGENERATExFORCE_BY_MODExTEMPR);
          putBIT (16, mTARGET_REGISTER, bitRHS);
          bitRHS->inUse = 0;
        }
        // DO CASE MODEX; (6826)
        {
        rs2s1:
          switch (COREHALFWORD (mGENERATExFORCE_BY_MODExMODEX))
            {
            case 0:
              // CALL
              // GENLIBCALL(HORI((TYPE(OP)&8)~=0)||'TO'||EORD((MODE&8)~=0));
              // (6828)
              {
                putCHARACTERp (
                    mGENERATExGENLIBCALLxNAME,
                    xsCAT (
                        xsCAT (
                            getCHARACTER (
                                mGENERATExFORCE_BY_MODExHORI
                                + 4
                                      * xNEQ (
                                          xAND (
                                              COREHALFWORD (
                                                  getFIXED (mIND_STACK)
                                                  + 73
                                                        * (COREHALFWORD (
                                                            mGENERATExFORCE_BY_MODExOP))
                                                  + 50 + 2 * (0)),
                                              8),
                                          0)),
                            cToDescriptor (NULL, "TO")),
                        getCHARACTER (
                            mGENERATExFORCE_BY_MODExEORD
                            + 4
                                  * xNEQ (
                                      xAND (COREHALFWORD (
                                                mGENERATExFORCE_BY_MODExMODE),
                                            8),
                                      0))));
                GENERATExGENLIBCALL (0);
              }
              break;
            case 1:
              // CALL
              // GENLIBCALL(EORD((TYPE(OP)&8)~=0)||'TO'||HORI((MODE&8)~=0));
              // (6829)
              {
                putCHARACTERp (
                    mGENERATExGENLIBCALLxNAME,
                    xsCAT (
                        xsCAT (
                            getCHARACTER (
                                mGENERATExFORCE_BY_MODExEORD
                                + 4
                                      * xNEQ (
                                          xAND (
                                              COREHALFWORD (
                                                  getFIXED (mIND_STACK)
                                                  + 73
                                                        * (COREHALFWORD (
                                                            mGENERATExFORCE_BY_MODExOP))
                                                  + 50 + 2 * (0)),
                                              8),
                                          0)),
                            cToDescriptor (NULL, "TO")),
                        getCHARACTER (
                            mGENERATExFORCE_BY_MODExHORI
                            + 4
                                  * xNEQ (
                                      xAND (COREHALFWORD (
                                                mGENERATExFORCE_BY_MODExMODE),
                                            8),
                                      0))));
                GENERATExGENLIBCALL (0);
              }
              break;
            }
        } // End of DO CASE block
        // CALL SET_RESULT_REG(OP, MODE); (6829)
        {
          putBITp (16, mGENERATExSET_RESULT_REGxOP,
                   getBIT (16, mGENERATExFORCE_BY_MODExOP));
          putBITp (16, mGENERATExSET_RESULT_REGxOPTYPE,
                   getBIT (16, mGENERATExFORCE_BY_MODExMODE));
          GENERATExSET_RESULT_REG (0);
        }
        // IF TARGET_REGISTER >= 0 THEN (6830)
        if (1 & (xGE (COREHALFWORD (mTARGET_REGISTER), 0)))
          // CALL FORCE_ACCUMULATOR(OP, MODE, RTYPE); (6831)
          {
            putBITp (16, mGENERATExFORCE_ACCUMULATORxOP,
                     getBIT (16, mGENERATExFORCE_BY_MODExOP));
            putBITp (16, mGENERATExFORCE_ACCUMULATORxOPTYPE,
                     getBIT (16, mGENERATExFORCE_BY_MODExMODE));
            putBITp (16, mGENERATExFORCE_ACCUMULATORxACCLASS,
                     getBIT (16, mGENERATExFORCE_BY_MODExRTYPE));
            GENERATExFORCE_ACCUMULATOR (0);
          }
      es2:;
      } // End of DO block
  // RTYPE = 0; (6832)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExFORCE_BY_MODExRTYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN REG(OP); (6833)
  {
    reentryGuard = 0;
    return COREHALFWORD (getFIXED (mIND_STACK)
                         + 73 * (COREHALFWORD (mGENERATExFORCE_BY_MODExOP))
                         + 46 + 2 * (0));
  }
}
