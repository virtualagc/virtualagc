/*
  File GENERATExEMITXOP.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExEMITXOP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExEMITXOP");
  // IF DATA_REMOTE THEN (3216)
  if (1 & (bitToFixed (getBIT (1, mDATA_REMOTE))))
    // IF (INST = LA) THEN (3217)
    if (1 & (xEQ (COREHALFWORD (mGENERATExEMITXOPxINST), BYTE0 (mLA))))
      // CALL REG_STAT(OP,XREG,LOADADDR); (3218)
      {
        putBITp (16, mGENERATExREG_STATxOP, getBIT (16, mGENERATExEMITXOPxOP));
        putBITp (16, mGENERATExREG_STATxR,
                 getBIT (16, mGENERATExEMITXOPxXREG));
        putBITp (8, mGENERATExREG_STATxTYPE_LOAD,
                 fixedToBit (32, (int32_t)(3)));
        GENERATExREG_STAT (0);
      }
  // DO CASE PACKFORM(FORM(OP)); (3219)
  {
  rs1:
    switch (BYTE0 (
        mPACKFORM
        + 1
              * COREHALFWORD (getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP)) + 32
                              + 2 * (0))))
      {
      case 0:
        // CALL EMITP(INST, XREG, 0, FORM(OP), LOC(OP), 0, NR_DEREF(OP) );
        // (3221)
        {
          putBITp (16, mGENERATExEMITPxINST,
                   getBIT (16, mGENERATExEMITXOPxINST));
          putBITp (16, mGENERATExEMITPxXREG,
                   getBIT (16, mGENERATExEMITXOPxXREG));
          putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
          putBITp (16, mGENERATExEMITPxFLAG,
                   getBIT (16, getFIXED (mIND_STACK)
                                   + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                                   + 32 + 2 * (0)));
          putBITp (16, mGENERATExEMITPxPTR,
                   getBIT (16, getFIXED (mIND_STACK)
                                   + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                                   + 40 + 2 * (0)));
          putBITp (16, mGENERATExEMITPxINSTYPE, fixedToBit (32, (int32_t)(0)));
          putBITp (1, mGENERATExEMITPxNRDEREF,
                   getBIT (8, getFIXED (mIND_STACK)
                                  + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                                  + 60 + 1 * (0)));
          GENERATExEMITP (0);
        }
        break;
      case 1:
        // DO; (3222)
        {
        rs1s1:;
          // CALL EMITRX(INST, XREG, 0, BASE(OP), DISP(OP), NR_DEREF(OP) );
          // (3222)
          {
            putBITp (16, mGENERATExEMITRXxINST,
                     getBIT (16, mGENERATExEMITXOPxINST));
            putBITp (16, mGENERATExEMITRXxXREG,
                     getBIT (16, mGENERATExEMITXOPxXREG));
            putBITp (16, mGENERATExEMITRXxINDEX,
                     fixedToBit (32, (int32_t)(0)));
            putBITp (
                16, mGENERATExEMITRXxXBASE,
                getBIT (16, getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                                + 22 + 2 * (0)));
            putBITp (
                16, mGENERATExEMITRXxXDISP,
                getBIT (16, getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                                + 30 + 2 * (0)));
            putBITp (
                1, mGENERATExEMITRXxNRDEREF,
                getBIT (8, getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                               + 60 + 1 * (0)));
            GENERATExEMITRX (0);
          }
          // IF BASE(OP) ~= TEMPBASE THEN (3223)
          if (1
              & (xNEQ (
                  COREHALFWORD (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExEMITXOPxOP))
                                + 22 + 2 * (0)),
                  BYTE0 (mTEMPBASE))))
            // CALL DROP_BASE(OP); (3224)
            {
              putBITp (16, mGENERATExDROP_BASExOP,
                       getBIT (16, mGENERATExEMITXOPxOP));
              GENERATExDROP_BASE (0);
            }
        es1s1:;
        } // End of DO block
        break;
      case 2:
        // CALL ERRORS(CLASS_ZO,2); (3226)
        {
          putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_ZO));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(2)));
          ERRORS (0);
        }
        break;
      }
  } // End of DO CASE block
  // IF (DOUBLE_TYPE(XREG) > 0) & (XREG >= FR0) & ( (INST= 121) | (INST= 112) )
  // THEN (3226)
  if (1
      & (xAND (
          xAND (xGT (BYTE0 (mDOUBLE_TYPE
                            + 1 * COREHALFWORD (mGENERATExEMITXOPxXREG)),
                     0),
                xGE (COREHALFWORD (mGENERATExEMITXOPxXREG), BYTE0 (mFR0))),
          xOR (xEQ (COREHALFWORD (mGENERATExEMITXOPxINST), 121),
               xEQ (COREHALFWORD (mGENERATExEMITXOPxINST), 112)))))
    // R_TYPE(XREG)=DOUBLE_TYPE(XREG); (3227)
    {
      descriptor_t *bitRHS = getBIT (
          8, mDOUBLE_TYPE + 1 * COREHALFWORD (mGENERATExEMITXOPxXREG));
      putBIT (8, mR_TYPE + 1 * (COREHALFWORD (mGENERATExEMITXOPxXREG)),
              bitRHS);
      bitRHS->inUse = 0;
    }
  {
    reentryGuard = 0;
    return 0;
  }
}
