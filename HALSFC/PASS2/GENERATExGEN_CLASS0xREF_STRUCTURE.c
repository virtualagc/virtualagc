/*
  File GENERATExGEN_CLASS0xREF_STRUCTURE.c generated by XCOM-I, 2024-08-08
  04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xREF_STRUCTURE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xREF_STRUCTURE");
  // FORM(PTR) = CSYM; (12319)
  {
    descriptor_t *bitRHS = getBIT (8, mCSYM);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 32 + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // TYPE(PTR) = SYT_TYPE(OP); (12320)
  {
    descriptor_t *bitRHS = getBIT (
        8, getFIXED (mSYM_TAB)
               + 34 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExOP))
               + 32 + 1 * (0));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 50 + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // COLUMN(PTR), DEL(PTR) = 0; (12321)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 24 + 2 * (0),
            fixedToBit (16, numberRHS));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 28 + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // INX_CON(PTR), STRUCT_CON(PTR), INX(PTR) = 0; (12322)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (
        getFIXED (mIND_STACK)
            + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)) + 4
            + 4 * (0),
        numberRHS);
    putFIXED (
        getFIXED (mIND_STACK)
            + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)) + 8
            + 4 * (0),
        numberRHS);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 34 + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // REG(PTR) = BACKUP_REG(PTR); (12323)
  {
    descriptor_t *bitRHS = getBIT (
        16, getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 20 + 2 * (0));
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 46 + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL SIZEFIX(PTR, OP); (12324)
  {
    putBITp (16, mGENERATExSIZEFIXxPTR,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR));
    putBITp (16, mGENERATExSIZEFIXxOP1,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExOP));
    GENERATExSIZEFIX (0);
  }
  // IF (SYT_FLAGS(OP) & NAME_FLAG) ~= 0 THEN (12325)
  if (1
      & (xNEQ (
          xAND (
              getFIXED (
                  getFIXED (mSYM_TAB)
                  + 34 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExOP))
                  + 8 + 4 * (0)),
              getFIXED (mNAME_FLAG)),
          0)))
    // DO; (12326)
    {
    rs1:;
      // TYPE(PTR) = STRUCTURE; (12327)
      {
        descriptor_t *bitRHS = getBIT (8, mSTRUCTURE);
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 50 + 2 * (0),
            bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN; (12328)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
  // CALL DIMFIX(PTR, OP); (12329)
  {
    putBITp (16, mGENERATExDIMFIXxPTR,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR));
    putBITp (16, mGENERATExDIMFIXxOP1,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExOP));
    GENERATExDIMFIX (0);
  }
  // IF COPY(PTR) > 0 THEN (12330)
  if (1
      & (xGT (
          COREHALFWORD (
              getFIXED (mIND_STACK)
              + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
              + 26 + 2 * (0)),
          0)))
    // DO; (12331)
    {
    rs2:;
      // CALL SAVE_REGS(FIXARG3, 3); (12332)
      {
        putBITp (16, mGENERATExSAVE_REGSxN1, getBIT (8, mFIXARG3));
        putBITp (1, mGENERATExSAVE_REGSxFLT, fixedToBit (32, (int32_t)(3)));
        GENERATExSAVE_REGS (0);
      }
      // CALL PUSH_ADOLEVEL(1); (12333)
      {
        putBITp (16, mGENERATExGEN_CLASS0xPUSH_ADOLEVELxNCOPIES,
                 fixedToBit (32, (int32_t)(1)));
        GENERATExGEN_CLASS0xPUSH_ADOLEVEL (0);
      }
      // COPY(PTR) = 1; (12334)
      {
        int32_t numberRHS = (int32_t)(1);
        putBIT (
            16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                + 26 + 2 * (0),
            fixedToBit (16, numberRHS));
      }
      // SUBLIMIT(STACK#+1) = AREASAVE; (12335)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mAREASAVE));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16,
                mGENERATExSUBLIMIT + 2 * (xadd (COREHALFWORD (mSTACKp), 1)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // SUBLIMIT(STACK#) = LUMP_ARRAYSIZE(OP); (12336)
      {
        int32_t numberRHS = (int32_t)((
            putBITp (16, mGENERATExLUMP_ARRAYSIZExOP,
                     getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExOP)),
            GENERATExLUMP_ARRAYSIZE (0)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGENERATExSUBLIMIT + 2 * (COREHALFWORD (mSTACKp)), bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL DOOPEN(1, 1, SUBLIMIT(STACK#)); (12337)
      {
        putFIXED (mGENERATExDOOPENxSTART, 1);
        putFIXED (mGENERATExDOOPENxSTEP, 1);
        putFIXED (
            mGENERATExDOOPENxSTOP,
            COREHALFWORD (mGENERATExSUBLIMIT + 2 * COREHALFWORD (mSTACKp)));
        GENERATExDOOPEN (0);
      }
      // CALL FREE_ARRAYNESS(PTR); (12338)
      {
        putBITp (16, mGENERATExFREE_ARRAYNESSxOP,
                 getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR));
        GENERATExFREE_ARRAYNESS (0);
      }
    es2:;
    } // End of DO block
  // ELSE (12339)
  else
    // AREASAVE = 0; (12340)
    {
      int32_t numberRHS = (int32_t)(0);
      putFIXED (mAREASAVE, numberRHS);
    }
  // IF PACKTYPE(TYPE(PTR)) = VECMAT THEN (12341)
  if (1
      & (xEQ (
          BYTE0 (mPACKTYPE
                 + 1
                       * COREHALFWORD (
                           getFIXED (mIND_STACK)
                           + 73
                                 * (COREHALFWORD (
                                     mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                           + 50 + 2 * (0))),
          BYTE0 (mVECMAT))))
    // AREASAVE = AREASAVE + 1; (12342)
    {
      int32_t numberRHS = (int32_t)(xadd (getFIXED (mAREASAVE), 1));
      putFIXED (mAREASAVE, numberRHS);
    }
  // INX_CON(PTR) = STRUCT_CON(PTR); (12343)
  {
    int32_t numberRHS = (int32_t)(getFIXED (
        getFIXED (mIND_STACK)
        + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)) + 8
        + 4 * (0)));
    putFIXED (
        getFIXED (mIND_STACK)
            + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)) + 4
            + 4 * (0),
        numberRHS);
  }
  // INX_CON(PTR) = INX_CON(PTR) - (BIGHTS(TYPE(PTR)) * AREASAVE); (12344)
  {
    int32_t numberRHS = (int32_t)(xsubtract (
        getFIXED (
            getFIXED (mIND_STACK)
            + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)) + 4
            + 4 * (0)),
        xmultiply (
            BYTE0 (mBIGHTS
                   + 1
                         * COREHALFWORD (
                             getFIXED (mIND_STACK)
                             + 73
                                   * (COREHALFWORD (
                                       mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                             + 50 + 2 * (0))),
            getFIXED (mAREASAVE))));
    putFIXED (
        getFIXED (mIND_STACK)
            + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)) + 4
            + 4 * (0),
        numberRHS);
  }
  // IF PACKTYPE(TYPE(PTR)) | INX(PTR) = PTRARG1 THEN (12345)
  if (1
      & (xOR (
          BYTE0 (mPACKTYPE
                 + 1
                       * COREHALFWORD (
                           getFIXED (mIND_STACK)
                           + 73
                                 * (COREHALFWORD (
                                     mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                           + 50 + 2 * (0))),
          xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73
                                   * (COREHALFWORD (
                                       mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                             + 34 + 2 * (0)),
               BYTE0 (mPTRARG1)))))
    // TREG, LASTRESULT = 0; (12346)
    {
      int32_t numberRHS = (int32_t)(0);
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExTREG, bitRHS);
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mLASTRESULT, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (12347)
  else
    // DO; (12348)
    {
    rs3:;
      // TREG = PTRARG1; (12349)
      {
        descriptor_t *bitRHS = getBIT (8, mPTRARG1);
        putBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExTREG, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF DATA_REMOTE THEN (12350)
      if (1 & (bitToFixed (getBIT (1, mDATA_REMOTE))))
        // TREG = REG_STAT(PTR,TREG,LOADADDR); (12351)
        {
          descriptor_t *bitRHS
              = (putBITp (16, mGENERATExREG_STATxOP,
                          getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR)),
                 putBITp (
                     16, mGENERATExREG_STATxR,
                     getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExTREG)),
                 putBITp (8, mGENERATExREG_STATxTYPE_LOAD,
                          fixedToBit (32, (int32_t)(3))),
                 GENERATExREG_STAT (0));
          putBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExTREG, bitRHS);
          bitRHS->inUse = 0;
        }
      // CALL CHECKPOINT_REG(TREG); (12352)
      {
        putBITp (16, mGENERATExCHECKPOINT_REGxR,
                 getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExTREG));
        GENERATExCHECKPOINT_REG (0);
      }
      // LASTRESULT = PTR; (12353)
      {
        descriptor_t *bitRHS
            = getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR);
        putBIT (16, mLASTRESULT, bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // CALL ADDRESS_STRUCTURE(PTR, OP, 0, TREG); (12354)
  {
    putBITp (16, mGENERATExGEN_CLASS0xADDRESS_STRUCTURExPTR,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExPTR));
    putBITp (16, mGENERATExGEN_CLASS0xADDRESS_STRUCTURExOP,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExOP));
    putBITp (16, mGENERATExGEN_CLASS0xADDRESS_STRUCTURExREF,
             fixedToBit (32, (int32_t)(0)));
    putBITp (16, mGENERATExGEN_CLASS0xADDRESS_STRUCTURExTBASE,
             getBIT (16, mGENERATExGEN_CLASS0xREF_STRUCTURExTREG));
    GENERATExGEN_CLASS0xADDRESS_STRUCTURE (0);
  }
  // CALL INCR_USAGE(BASE(PTR)); (12355)
  {
    putBITp (16, mGENERATExINCR_USAGExR,
             getBIT (16, getFIXED (mIND_STACK)
                             + 73
                                   * (COREHALFWORD (
                                       mGENERATExGEN_CLASS0xREF_STRUCTURExPTR))
                             + 22 + 2 * (0)));
    GENERATExINCR_USAGE (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
