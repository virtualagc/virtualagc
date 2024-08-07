/*
  File GENERATExCHECK_ADDR_NEST.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExCHECK_ADDR_NEST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExCHECK_ADDR_NEST");
  // ALOC = LOC(OP); (4187)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxOP))
                          + 40 + 2 * (0));
    putBIT (16, mGENERATExCHECK_ADDR_NESTxALOC, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SYT_FLAGS(ALOC) & NAME_FLAG) = 0 THEN (4188)
  if (1
      & (xEQ (xAND (getFIXED (
                        getFIXED (mSYM_TAB)
                        + 34 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC))
                        + 8 + 4 * (0)),
                    getFIXED (mNAME_FLAG)),
              0)))
    // IF SYT_TYPE(ALOC) >= TASK_LABEL THEN (4189)
    if (1
        & (xGE (BYTE0 (getFIXED (mSYM_TAB)
                       + 34 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC))
                       + 32 + 1 * (0)),
                BYTE0 (mTASK_LABEL))))
      // DO; (4190)
      {
      rs1:;
        // CALL SETUP_ADCON(OP); (4191)
        {
          putBITp (16, mGENERATExSETUP_ADCONxOP,
                   getBIT (16, mGENERATExCHECK_ADDR_NESTxOP));
          GENERATExSETUP_ADCON (0);
        }
        // RETURN; (4192)
        {
          reentryGuard = 0;
          return 0;
        }
      es1:;
      } // End of DO block
  // IF SYT_BASE(ALOC) ~= TEMPBASE THEN (4193)
  if (1
      & (xNEQ (
          COREHALFWORD (getFIXED (mP2SYMS)
                        + 12 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC))
                        + 4 + 2 * (0)),
          BYTE0 (mTEMPBASE))))
    // RETURN; (4194)
    {
      reentryGuard = 0;
      return 0;
    }
  // SCOPE = SYT_SCOPE(ALOC); (4195)
  {
    descriptor_t *bitRHS
        = getBIT (8, getFIXED (mSYM_TAB)
                         + 34 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC))
                         + 29 + 1 * (0));
    putBIT (16, mGENERATExCHECK_ADDR_NESTxSCOPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF SCOPE = INDEXNEST THEN (4196)
  if (1
      & (xEQ (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxSCOPE),
              COREHALFWORD (mINDEXNEST))))
    // RETURN; (4197)
    {
      reentryGuard = 0;
      return 0;
    }
  // ELSE (4198)
  else
    // IF SCOPE = PROGPOINT THEN (4199)
    if (1
        & (xEQ (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxSCOPE),
                COREHALFWORD (mPROGPOINT))))
      // IF SYT_TYPE(PROC_LEVEL(SCOPE)) < TASK_LABEL THEN (4200)
      if (1
          & (xLT (BYTE0 (getFIXED (mSYM_TAB)
                         + 34
                               * (COREHALFWORD (
                                   mPROC_LEVEL
                                   + 2
                                         * COREHALFWORD (
                                             mGENERATExCHECK_ADDR_NESTxSCOPE)))
                         + 32 + 1 * (0)),
                  BYTE0 (mTASK_LABEL))))
        // SCOPE = 0; (4201)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mGENERATExCHECK_ADDR_NESTxSCOPE, bitRHS);
          bitRHS->inUse = 0;
        }
  // IF TR < 0 THEN (4202)
  if (1 & (xLT (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxTR), 0)))
    // DO; (4203)
    {
    rs2:;
      // IX = PTRARG1; (4204)
      {
        descriptor_t *bitRHS = getBIT (8, mPTRARG1);
        putBIT (16, mGENERATExCHECK_ADDR_NESTxIX, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF USAGE(IX) THEN (4205)
      if (1
          & (bitToFixed (getBIT (
              16, mUSAGE + 2 * COREHALFWORD (mGENERATExCHECK_ADDR_NESTxIX)))))
        // IF R_CONTENTS(IX) = LOCREL THEN (4206)
        if (1
            & (xEQ (BYTE0 (mR_CONTENTS
                           + 1 * COREHALFWORD (mGENERATExCHECK_ADDR_NESTxIX)),
                    BYTE0 (mLOCREL))))
          // IF R_VAR(IX) = SCOPE THEN (4207)
          if (1
              & (xEQ (COREHALFWORD (
                          mR_VAR
                          + 2 * COREHALFWORD (mGENERATExCHECK_ADDR_NESTxIX)),
                      COREHALFWORD (mGENERATExCHECK_ADDR_NESTxSCOPE))))
            // DO; (4208)
            {
            rs2s1:;
              // R = IX; (4209)
              {
                descriptor_t *bitRHS
                    = getBIT (16, mGENERATExCHECK_ADDR_NESTxIX);
                putBIT (16, mGENERATExCHECK_ADDR_NESTxR, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF DATA_REMOTE THEN (4210)
              if (1 & (bitToFixed (getBIT (1, mDATA_REMOTE))))
                // R = REG_STAT(OP,IX,LOADBASE); (4211)
                {
                  descriptor_t *bitRHS
                      = (putBITp (16, mGENERATExREG_STATxOP,
                                  getBIT (16, mGENERATExCHECK_ADDR_NESTxOP)),
                         putBITp (16, mGENERATExREG_STATxR,
                                  getBIT (16, mGENERATExCHECK_ADDR_NESTxIX)),
                         putBITp (8, mGENERATExREG_STATxTYPE_LOAD,
                                  fixedToBit (32, (int32_t)(0))),
                         GENERATExREG_STAT (0));
                  putBIT (16, mGENERATExCHECK_ADDR_NESTxR, bitRHS);
                  bitRHS->inUse = 0;
                }
              // GO TO SETUP_R; (4212)
              goto SETUP_R;
            es2s1:;
            } // End of DO block
      // R =GET_R(OP,LOADBASE); (4213)
      {
        descriptor_t *bitRHS
            = (putBITp (16, mGENERATExGET_RxOP,
                        getBIT (16, mGENERATExCHECK_ADDR_NESTxOP)),
               putBITp (8, mGENERATExGET_RxTYPE_LOAD,
                        fixedToBit (32, (int32_t)(0))),
               GENERATExGET_R (0));
        putBIT (16, mGENERATExCHECK_ADDR_NESTxR, bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  // ELSE (4214)
  else
    // IF TR = TEMPBASE | TR > R3 THEN (4215)
    if (1
        & (xOR (
            xEQ (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxTR),
                 BYTE0 (mTEMPBASE)),
            xGT (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxTR), BYTE0 (mR3)))))
      // R = GET_R(OP,LOADBASE); (4216)
      {
        descriptor_t *bitRHS
            = (putBITp (16, mGENERATExGET_RxOP,
                        getBIT (16, mGENERATExCHECK_ADDR_NESTxOP)),
               putBITp (8, mGENERATExGET_RxTYPE_LOAD,
                        fixedToBit (32, (int32_t)(0))),
               GENERATExGET_R (0));
        putBIT (16, mGENERATExCHECK_ADDR_NESTxR, bitRHS);
        bitRHS->inUse = 0;
      }
    // ELSE (4217)
    else
      // IF DATA_REMOTE THEN (4218)
      if (1 & (bitToFixed (getBIT (1, mDATA_REMOTE))))
        // R = REG_STAT(OP,TR,LOADBASE); (4219)
        {
          descriptor_t *bitRHS
              = (putBITp (16, mGENERATExREG_STATxOP,
                          getBIT (16, mGENERATExCHECK_ADDR_NESTxOP)),
                 putBITp (16, mGENERATExREG_STATxR,
                          getBIT (16, mGENERATExCHECK_ADDR_NESTxTR)),
                 putBITp (8, mGENERATExREG_STATxTYPE_LOAD,
                          fixedToBit (32, (int32_t)(0))),
                 GENERATExREG_STAT (0));
          putBIT (16, mGENERATExCHECK_ADDR_NESTxR, bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (4220)
      else
        // R = TR; (4221)
        {
          descriptor_t *bitRHS = getBIT (16, mGENERATExCHECK_ADDR_NESTxTR);
          putBIT (16, mGENERATExCHECK_ADDR_NESTxR, bitRHS);
          bitRHS->inUse = 0;
        }
  // IF SYT_TYPE(PROC_LEVEL(INDEXNEST)) = STMT_LABEL &
  // SYT_NEST(PROC_LEVEL(INDEXNEST)) = SYT_NEST(ALOC)+1 THEN (4222)
  if (1
      & (xAND (
          xEQ (BYTE0 (getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (mPROC_LEVEL
                                             + 2 * COREHALFWORD (mINDEXNEST)))
                      + 32 + 1 * (0)),
               BYTE0 (mSTMT_LABEL)),
          xEQ (BYTE0 (getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (mPROC_LEVEL
                                             + 2 * COREHALFWORD (mINDEXNEST)))
                      + 28 + 1 * (0)),
               xadd (BYTE0 (
                         getFIXED (mSYM_TAB)
                         + 34 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC))
                         + 28 + 1 * (0)),
                     1)))))
    // CALL EMITRX(L, R, 0, TEMPBASE, STACK_LINK); (4223)
    {
      putBITp (16, mGENERATExEMITRXxINST, getBIT (8, mL));
      putBITp (16, mGENERATExEMITRXxXREG,
               getBIT (16, mGENERATExCHECK_ADDR_NESTxR));
      putBITp (16, mGENERATExEMITRXxINDEX, fixedToBit (32, (int32_t)(0)));
      putBITp (16, mGENERATExEMITRXxXBASE, getBIT (8, mTEMPBASE));
      putBITp (16, mGENERATExEMITRXxXDISP, getBIT (8, mSTACK_LINK));
      GENERATExEMITRX (0);
    }
  // ELSE (4224)
  else
    // CALL ERRORS(CLASS_XQ, 101, SYT_NAME(ALOC)); (4225)
    {
      putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_XQ));
      putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(101)));
      putCHARACTERp (
          mERRORSxTEXT,
          getCHARACTER (getFIXED (mSYM_TAB)
                        + 34 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC))
                        + 0 + 4 * (0)));
      ERRORS (0);
    }
  // IF TR < 0 THEN (4226)
  if (1 & (xLT (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxTR), 0)))
    // CALL SET_USAGE(R, LOCREL, SCOPE); (4227)
    {
      putBITp (16, mGENERATExSET_USAGExR,
               getBIT (16, mGENERATExCHECK_ADDR_NESTxR));
      putBITp (16, mGENERATExSET_USAGExRFORM, getBIT (8, mLOCREL));
      putFIXED (mGENERATExSET_USAGExRVAR,
                COREHALFWORD (mGENERATExCHECK_ADDR_NESTxSCOPE));
      GENERATExSET_USAGE (0);
    }
  // ELSE (4228)
  else
    // USAGE(R) = 0; (4229)
    {
      int32_t numberRHS = (int32_t)(0);
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mUSAGE + 2 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxR)),
              bitRHS);
      bitRHS->inUse = 0;
    }
// SETUP_R: (4230)
SETUP_R:
  // BASE(OP), BACKUP_REG(OP) = R; (4231)
  {
    descriptor_t *bitRHS = getBIT (16, mGENERATExCHECK_ADDR_NESTxR);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxOP)) + 22
                + 2 * (0),
            bitRHS);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxOP)) + 20
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // DISP(OP) = SYT_DISP(ALOC); (4232)
  {
    descriptor_t *bitRHS = getBIT (
        16, getFIXED (mP2SYMS)
                + 12 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxALOC)) + 6
                + 2 * (0));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxOP)) + 30
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL INCR_USAGE(R); (4233)
  {
    putBITp (16, mGENERATExINCR_USAGExR,
             getBIT (16, mGENERATExCHECK_ADDR_NESTxR));
    GENERATExINCR_USAGE (0);
  }
  // FORM(OP) = CSYM; (4234)
  {
    descriptor_t *bitRHS = getBIT (8, mCSYM);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExCHECK_ADDR_NESTxOP)) + 32
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
