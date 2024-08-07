/*
  File GENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTOR.c generated by XCOM-I,
  2024-08-08 04:32:26.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTOR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (
      reentryGuard, "GENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTOR");
  // RESET_TARGET_FLAG = FALSE; (12554)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (
        1, mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxRESET_TARGET_FLAG,
        bitRHS);
    bitRHS->inUse = 0;
  }
  // PTR = GET_STACK_ENTRY; (12555)
  {
    int32_t numberRHS = (int32_t)(GENERATExGET_STACK_ENTRY (0));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // FORM(PTR) = SYM; (12556)
  {
    descriptor_t *bitRHS = getBIT (8, mSYM);
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 32 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // LOC(PTR) = LOC(SECOND_ARG); (12557)
  {
    descriptor_t *bitRHS = getBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxSECOND_ARG))
            + 40 + 2 * (0));
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 40 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // LOC2(PTR) = LOC2(SECOND_ARG); (12558)
  {
    descriptor_t *bitRHS = getBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxSECOND_ARG))
            + 42 + 2 * (0));
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 42 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // TYPE(PTR) = INTEGER; (12559)
  {
    descriptor_t *bitRHS = getBIT (8, mINTEGER);
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 50 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // REG(PTR) = PTRARG1; (12560)
  {
    descriptor_t *bitRHS = getBIT (8, mPTRARG1);
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 46 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SYT_TYPE(LOC(SECOND_ARG)) = STRUCTURE) THEN (12561)
  if (1
      & (xEQ (
          BYTE0 (
              getFIXED (mSYM_TAB)
              + 34
                    * (COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73
                              * (COREHALFWORD (
                                  mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxSECOND_ARG))
                        + 40 + 2 * (0)))
              + 32 + 1 * (0)),
          BYTE0 (mSTRUCTURE))))
    // DO; (12562)
    {
    rs1:;
      // BASE(PTR) = BASE(SECOND_ARG); (12563)
      {
        descriptor_t *bitRHS = getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxSECOND_ARG))
                + 22 + 2 * (0));
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 22 + 2 * (0),
            bitRHS);
        bitRHS->inUse = 0;
      }
      // FORM(PTR) = FORM(SECOND_ARG); (12564)
      {
        descriptor_t *bitRHS = getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxSECOND_ARG))
                + 32 + 2 * (0));
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 32 + 2 * (0),
            bitRHS);
        bitRHS->inUse = 0;
      }
      // TYPE(PTR) = TYPE(SECOND_ARG); (12565)
      {
        descriptor_t *bitRHS = getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxSECOND_ARG))
                + 50 + 2 * (0));
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 50 + 2 * (0),
            bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (12566)
  else
    // DO; (12567)
    {
    rs2:;
      // CALL CHECKPOINT_REG(REG(PTR)); (12568)
      {
        putBITp (
            16, mGENERATExCHECKPOINT_REGxR,
            getBIT (
                16,
                getFIXED (mIND_STACK)
                    + 73
                          * (COREHALFWORD (
                              mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                    + 46 + 2 * (0)));
        GENERATExCHECKPOINT_REG (0);
      }
      // CALL EMITOP(LH, REG(PTR),PTR); (12569)
      {
        putBITp (16, mGENERATExEMITOPxINST, getBIT (8, mLH));
        putBITp (
            16, mGENERATExEMITOPxXREG,
            getBIT (
                16,
                getFIXED (mIND_STACK)
                    + 73
                          * (COREHALFWORD (
                              mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                    + 46 + 2 * (0)));
        putBITp (
            16, mGENERATExEMITOPxOP,
            getBIT (16,
                    mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR));
        GENERATExEMITOP (0);
      }
      // BASE(PTR) = PTRARG1; (12570)
      {
        descriptor_t *bitRHS = getBIT (8, mPTRARG1);
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 22 + 2 * (0),
            bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  // IF TARGET_REGISTER < 0 THEN (12571)
  if (1 & (xLT (COREHALFWORD (mTARGET_REGISTER), 0)))
    // DO; (12572)
    {
    rs3:;
      // TARGET_REGISTER = FINDAC(INDEX_REG); (12573)
      {
        descriptor_t *bitRHS = (putBITp (16, mGENERATExFINDACxRCLASS,
                                         fixedToBit (32, (int32_t)(4))),
                                GENERATExFINDAC (0));
        putBIT (16, mTARGET_REGISTER, bitRHS);
        bitRHS->inUse = 0;
      }
      // RESET_TARGET_FLAG = TRUE; (12574)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (
            1,
            mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxRESET_TARGET_FLAG,
            bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // REG(PTR) = TARGET_REGISTER; (12575)
  {
    descriptor_t *bitRHS = getBIT (16, mTARGET_REGISTER);
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 46 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL EMITRX(LH,REG(PTR),INX(PTR),BASE(PTR),0); (12576)
  {
    putBITp (16, mGENERATExEMITRXxINST, getBIT (8, mLH));
    putBITp (
        16, mGENERATExEMITRXxXREG,
        getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 46 + 2 * (0)));
    putBITp (
        16, mGENERATExEMITRXxINDEX,
        getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 34 + 2 * (0)));
    putBITp (
        16, mGENERATExEMITRXxXBASE,
        getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 22 + 2 * (0)));
    putBITp (16, mGENERATExEMITRXxXDISP, fixedToBit (32, (int32_t)(0)));
    GENERATExEMITRX (0);
  }
  // BASE(PTR) = 0; (12577)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 22 + 2 * (0),
        fixedToBit (16, numberRHS));
  }
  // CALL EMITP(SRL,REG(PTR),0,SHCOUNT,8); (12578)
  {
    putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSRL));
    putBITp (
        16, mGENERATExEMITPxXREG,
        getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 46 + 2 * (0)));
    putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
    putBITp (16, mGENERATExEMITPxPTR, fixedToBit (32, (int32_t)(8)));
    GENERATExEMITP (0);
  }
  // CALL EMITP(AHI,REG(PTR),0,0,3); (12579)
  {
    putBITp (16, mGENERATExEMITPxINST, getBIT (8, mAHI));
    putBITp (
        16, mGENERATExEMITPxXREG,
        getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 46 + 2 * (0)));
    putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mGENERATExEMITPxFLAG, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mGENERATExEMITPxPTR, fixedToBit (32, (int32_t)(3)));
    GENERATExEMITP (0);
  }
  // CALL EMITP(SRL,REG(PTR),0,SHCOUNT,1); (12580)
  {
    putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSRL));
    putBITp (
        16, mGENERATExEMITPxXREG,
        getBIT (
            16,
            getFIXED (mIND_STACK)
                + 73
                      * (COREHALFWORD (
                          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
                + 46 + 2 * (0)));
    putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
    putBITp (16, mGENERATExEMITPxPTR, fixedToBit (32, (int32_t)(1)));
    GENERATExEMITP (0);
  }
  // IF RESET_TARGET_FLAG THEN (12581)
  if (1
      & (bitToFixed (getBIT (
          1,
          mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxRESET_TARGET_FLAG))))
    // TARGET_REGISTER=-1; (12582)
    {
      int32_t numberRHS = (int32_t)(-1);
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mTARGET_REGISTER, bitRHS);
      bitRHS->inUse = 0;
    }
  // FORM(PTR) = VAC; (12583)
  {
    descriptor_t *bitRHS = getBIT (8, mVAC);
    putBIT (
        16,
        getFIXED (mIND_STACK)
            + 73
                  * (COREHALFWORD (
                      mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR))
            + 32 + 2 * (0),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR; (12584)
  {
    reentryGuard = 0;
    return getBIT (16, mGENERATExGEN_CLASS0xEXTRACT_SIZE_FROM_DESCRIPTORxPTR);
  }
}
