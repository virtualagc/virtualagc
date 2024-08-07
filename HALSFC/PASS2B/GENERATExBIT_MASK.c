/*
  File GENERATExBIT_MASK.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExBIT_MASK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExBIT_MASK");
  // IF SHIFT ~= 0 THEN (5361)
  if (1 & (xNEQ (COREHALFWORD (mGENERATExBIT_MASKxSHIFT), 0)))
    // DO; (5362)
    {
    rs1:;
      // IF FORM(SHIFT) = LIT THEN (5363)
      if (1
          & (xEQ (
              COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExBIT_MASKxSHIFT))
                            + 32 + 2 * (0)),
              BYTE0 (mLIT))))
        // DO; (5364)
        {
        rs1s1:;
          // MASK = SHL(XITAB(XSIZE), VAL(SHIFT)); (5365)
          {
            int32_t numberRHS = (int32_t)(SHL (
                getFIXED (mGENERATExXITAB
                          + 4 * COREHALFWORD (mGENERATExBIT_MASKxXSIZE)),
                getFIXED (getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExBIT_MASKxSHIFT)) + 12
                          + 4 * (0))));
            putFIXED (mGENERATExBIT_MASKxMASK, numberRHS);
          }
          // SHIFT = 0; (5366)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExBIT_MASKxSHIFT, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s1:;
        } // End of DO block
      // ELSE (5367)
      else
        // MASK = XITAB(XSIZE); (5368)
        {
          int32_t numberRHS = (int32_t)(getFIXED (
              mGENERATExXITAB + 4 * COREHALFWORD (mGENERATExBIT_MASKxXSIZE)));
          putFIXED (mGENERATExBIT_MASKxMASK, numberRHS);
        }
    es1:;
    } // End of DO block
  // ELSE (5369)
  else
    // MASK = XITAB(XSIZE); (5370)
    {
      int32_t numberRHS = (int32_t)(getFIXED (
          mGENERATExXITAB + 4 * COREHALFWORD (mGENERATExBIT_MASKxXSIZE)));
      putFIXED (mGENERATExBIT_MASKxMASK, numberRHS);
    }
  // PTR = GET_INTEGER_LITERAL(MASK); (5371)
  {
    descriptor_t *bitRHS = (putFIXED (mGENERATExGET_INTEGER_LITERALxVALUE,
                                      getFIXED (mGENERATExBIT_MASKxMASK)),
                            GENERATExGET_INTEGER_LITERAL (0));
    putBIT (16, mGENERATExBIT_MASKxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // TYPE(PTR) = INTEGER | (TYPE(OP) & 8); (5372)
  {
    int32_t numberRHS = (int32_t)(xOR (
        BYTE0 (mINTEGER),
        xAND (COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExBIT_MASKxOP)) + 50
                            + 2 * (0)),
              8)));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExBIT_MASKxPTR)) + 50 + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // IF SHIFT ~= 0 THEN (5373)
  if (1 & (xNEQ (COREHALFWORD (mGENERATExBIT_MASKxSHIFT), 0)))
    // DO; (5374)
    {
    rs2:;
      // RM = GET_VAC(-1, FULLBIT); (5375)
      {
        descriptor_t *bitRHS
            = (putBITp (16, mGENERATExGET_VACxR,
                        fixedToBit (32, (int32_t)(-1))),
               putBITp (16, mGENERATExGET_VACxTYP, getBIT (8, mFULLBIT)),
               GENERATExGET_VAC (0));
        putBIT (16, mGENERATExBIT_MASKxRM, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF FORM(RM) = VAC THEN (5376)
      if (1
          & (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExBIT_MASKxRM))
                                + 32 + 2 * (0)),
                  BYTE0 (mVAC))))
        // NOT_THIS_REGISTER2 = REG(RM); (5377)
        {
          descriptor_t *bitRHS
              = getBIT (16, getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mGENERATExBIT_MASKxRM))
                                + 46 + 2 * (0));
          putBIT (16, mNOT_THIS_REGISTER2, bitRHS);
          bitRHS->inUse = 0;
        }
      // CALL INCR_REG(RM); (5378)
      {
        putBITp (16, mGENERATExINCR_REGxOP,
                 getBIT (16, mGENERATExBIT_MASKxRM));
        GENERATExINCR_REG (0);
      }
      // CALL LOAD_NUM(REG(RM), VAL(PTR), TYPE(PTR) & 8 | 1); (5379)
      {
        putBITp (16, mGENERATExLOAD_NUMxR,
                 getBIT (16, getFIXED (mIND_STACK)
                                 + 73 * (COREHALFWORD (mGENERATExBIT_MASKxRM))
                                 + 46 + 2 * (0)));
        putFIXED (mGENERATExLOAD_NUMxNUM,
                  getFIXED (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExBIT_MASKxPTR)) + 12
                            + 4 * (0)));
        putBITp (
            1, mGENERATExLOAD_NUMxFLAG,
            fixedToBit (
                32,
                (int32_t)(xOR (
                    xAND (COREHALFWORD (
                              getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mGENERATExBIT_MASKxPTR))
                              + 50 + 2 * (0)),
                          8),
                    1))));
        GENERATExLOAD_NUM (0);
      }
      // CALL BIT_SHIFT(SLL, RM, SHIFT); (5380)
      {
        putBITp (16, mGENERATExBIT_SHIFTxOPCODE, getBIT (8, mSLL));
        putBITp (16, mGENERATExBIT_SHIFTxR,
                 getBIT (16, mGENERATExBIT_MASKxRM));
        putBITp (16, mGENERATExBIT_SHIFTxOP,
                 getBIT (16, mGENERATExBIT_MASKxSHIFT));
        GENERATExBIT_SHIFT (0);
      }
      // CALL CHECK_VAC(OP); (5381)
      {
        putBITp (16, mGENERATExCHECK_VACxOP,
                 getBIT (16, mGENERATExBIT_MASKxOP));
        GENERATExCHECK_VAC (0);
      }
      // CALL ARITH_BY_MODE(OPCODE, OP, RM, TYPE(RM)); (5382)
      {
        putBITp (16, mGENERATExARITH_BY_MODExOP,
                 getBIT (16, mGENERATExBIT_MASKxOPCODE));
        putBITp (16, mGENERATExARITH_BY_MODExOP1,
                 getBIT (16, mGENERATExBIT_MASKxOP));
        putBITp (16, mGENERATExARITH_BY_MODExOP2,
                 getBIT (16, mGENERATExBIT_MASKxRM));
        putBITp (16, mGENERATExARITH_BY_MODExOPTYPE,
                 getBIT (16, getFIXED (mIND_STACK)
                                 + 73 * (COREHALFWORD (mGENERATExBIT_MASKxRM))
                                 + 50 + 2 * (0)));
        GENERATExARITH_BY_MODE (0);
      }
      // NOT_THIS_REGISTER2 = -1; (5383)
      {
        int32_t numberRHS = (int32_t)(-1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mNOT_THIS_REGISTER2, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL DROP_VAC(RM); (5384)
      {
        putBITp (16, mGENERATExDROP_VACxPTR,
                 getBIT (16, mGENERATExBIT_MASKxRM));
        GENERATExDROP_VAC (0);
      }
    es2:;
    } // End of DO block
  // ELSE (5385)
  else
    // CALL ARITH_BY_MODE(OPCODE, OP, PTR, TYPE(PTR)); (5386)
    {
      putBITp (16, mGENERATExARITH_BY_MODExOP,
               getBIT (16, mGENERATExBIT_MASKxOPCODE));
      putBITp (16, mGENERATExARITH_BY_MODExOP1,
               getBIT (16, mGENERATExBIT_MASKxOP));
      putBITp (16, mGENERATExARITH_BY_MODExOP2,
               getBIT (16, mGENERATExBIT_MASKxPTR));
      putBITp (16, mGENERATExARITH_BY_MODExOPTYPE,
               getBIT (16, getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mGENERATExBIT_MASKxPTR))
                               + 50 + 2 * (0)));
      GENERATExARITH_BY_MODE (0);
    }
  // CALL RETURN_STACK_ENTRY(PTR); (5387)
  {
    putBITp (16, mGENERATExRETURN_STACK_ENTRYxP,
             getBIT (16, mGENERATExBIT_MASKxPTR));
    GENERATExRETURN_STACK_ENTRY (0);
  }
  // SHIFT = 0; (5388)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExBIT_MASKxSHIFT, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
