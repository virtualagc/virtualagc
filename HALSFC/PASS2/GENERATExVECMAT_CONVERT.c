/*
  File GENERATExVECMAT_CONVERT.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExVECMAT_CONVERT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExVECMAT_CONVERT");
  // TEMPSPACE = ROW(OP) * COLUMN(OP); (7238)
  {
    int32_t numberRHS = (int32_t)(xmultiply (
        COREHALFWORD (getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExVECMAT_CONVERTxOP)) + 48
                      + 2 * (0)),
        COREHALFWORD (getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExVECMAT_CONVERTxOP)) + 24
                      + 2 * (0))));
    putFIXED (mTEMPSPACE, numberRHS);
  }
  // IF PREC_SPEC > 0 THEN (7239)
  if (1 & (xGT (COREHALFWORD (mGENERATExVECMAT_CONVERTxPREC_SPEC), 0)))
    // OPTYPE = PREC_SPEC&8 | TYPE(OP)& 247; (7240)
    {
      int32_t numberRHS = (int32_t)(xOR (
          xAND (COREHALFWORD (mGENERATExVECMAT_CONVERTxPREC_SPEC), 8),
          xAND (
              COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExVECMAT_CONVERTxOP))
                            + 50 + 2 * (0)),
              247)));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mGENERATExVECMAT_CONVERTxOPTYPE, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (7241)
  else
    // OPTYPE = TYPE(OP); (7242)
    {
      descriptor_t *bitRHS
          = getBIT (16, getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExVECMAT_CONVERTxOP))
                            + 50 + 2 * (0));
      putBIT (16, mGENERATExVECMAT_CONVERTxOPTYPE, bitRHS);
      bitRHS->inUse = 0;
    }
  // PTR = GET_VM_TEMP(OP, OPTYPE); (7243)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mGENERATExGET_VM_TEMPxN,
                    getBIT (16, mGENERATExVECMAT_CONVERTxOP)),
           putBITp (16, mGENERATExGET_VM_TEMPxOPTYP,
                    getBIT (16, mGENERATExVECMAT_CONVERTxOPTYPE)),
           GENERATExGET_VM_TEMP (0));
    putBIT (16, mGENERATExVECMAT_CONVERTxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL VECMAT_ASSIGN(PTR, OP); (7244)
  {
    putBITp (16, mGENERATExVECMAT_ASSIGNxOP0,
             getBIT (16, mGENERATExVECMAT_CONVERTxPTR));
    putBITp (16, mGENERATExVECMAT_ASSIGNxOP1,
             getBIT (16, mGENERATExVECMAT_CONVERTxOP));
    GENERATExVECMAT_ASSIGN (0);
  }
  // CALL DROPSAVE(OP); (7245)
  {
    putBITp (16, mGENERATExDROPSAVExENTRY,
             getBIT (16, mGENERATExVECMAT_CONVERTxOP));
    GENERATExDROPSAVE (0);
  }
  // CALL RETURN_STACK_ENTRY(OP); (7246)
  {
    putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
             getBIT (16, mGENERATExVECMAT_CONVERTxOP));
    GENERATExRETURN_STACK_ENTRY (0);
  }
  // PREC_SPEC = 0; (7247)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExVECMAT_CONVERTxPREC_SPEC, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR; (7248)
  {
    reentryGuard = 0;
    return COREHALFWORD (mGENERATExVECMAT_CONVERTxPTR);
  }
}
