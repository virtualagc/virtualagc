/*
  File END_SUBBIT_FCN.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
END_SUBBIT_FCN (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "END_SUBBIT_FCN");
  // TEMP=PTR(MPP1); (8895)
  {
    descriptor_t *bitRHS = getBIT (16, mPTR + 2 * getFIXED (mMPP1));
    int32_t numberRHS;
    numberRHS = bitToFixed (bitRHS);
    putFIXED (mTEMP, numberRHS);
    bitRHS->inUse = 0;
  }
  // IF (VAL_P(TEMP)~=-1)&(SHR(VAL_P(TEMP),8)) THEN (8896)
  if (1
      & (xAND (xNEQ (COREHALFWORD (mVAL_P + 2 * getFIXED (mTEMP)), -1),
               SHR (COREHALFWORD (mVAL_P + 2 * getFIXED (mTEMP)), 8))))
    // CALL ERROR(CLASS_QX,9); (8897)
    {
      putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_QX));
      putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(9)));
      ERROR (0);
    }
  // NEXT_SUB=PTR(MP); (8898)
  {
    descriptor_t *bitRHS = getBIT (16, mPTR + 2 * getFIXED (mMP));
    putBIT (16, mNEXT_SUB, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SHL(1,PSEUDO_TYPE(TEMP))&STRING_MASK)=0 THEN (8899)
  if (1
      & (xEQ (xAND (SHL (1, BYTE0 (mPSEUDO_TYPE + 1 * getFIXED (mTEMP))),
                    COREHALFWORD (mSTRING_MASK)),
              0)))
    // DO; (8900)
    {
    rs1:;
      // CALL ERROR(CLASS_QX,8); (8901)
      {
        putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_QX));
        putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(8)));
        ERROR (0);
      }
      // PSEUDO_TYPE(TEMP)=INT_TYPE; (8902)
      {
        int32_t numberRHS = (int32_t)(6);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mPSEUDO_TYPE + 1 * (getFIXED (mTEMP)), bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // IND_LINK,PSEUDO_LENGTH=0; (8903)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mIND_LINK, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPSEUDO_LENGTH, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF INX(NEXT_SUB)=0 THEN (8904)
  if (1 & (xEQ (COREHALFWORD (mINX + 2 * COREHALFWORD (mNEXT_SUB)), 0)))
    // FIX_DIM=BIT_LENGTH_LIM; (8905)
    {
      descriptor_t *bitRHS = getBIT (16, mBIT_LENGTH_LIM);
      putBIT (16, mFIX_DIM, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (8906)
  else
    // DO; (8907)
    {
    rs2:;
      // CALL REDUCE_SUBSCRIPT(0,0); (8908)
      {
        putBITp (16, mREDUCE_SUBSCRIPTxMODE, fixedToBit (32, (int32_t)(0)));
        putBITp (16, mREDUCE_SUBSCRIPTxSIZE, fixedToBit (32, (int32_t)(0)));
        REDUCE_SUBSCRIPT (0);
      }
      // IF FIX_DIM>BIT_LENGTH_LIM THEN (8909)
      if (1 & (xGT (COREHALFWORD (mFIX_DIM), COREHALFWORD (mBIT_LENGTH_LIM))))
        // DO; (8910)
        {
        rs2s1:;
          // FIX_DIM=BIT_LENGTH_LIM; (8911)
          {
            descriptor_t *bitRHS = getBIT (16, mBIT_LENGTH_LIM);
            putBIT (16, mFIX_DIM, bitRHS);
            bitRHS->inUse = 0;
          }
          // CALL ERROR(CLASS_SR,2,VAR(MP)); (8912)
          {
            putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_SR));
            putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(2)));
            putCHARACTERp (mERRORxTEXT,
                           getCHARACTER (mVAR + 4 * getFIXED (mMP)));
            ERROR (0);
          }
        es2s1:;
        } // End of DO block
      // ELSE (8913)
      else
        // IF FIX_DIM<0 THEN (8914)
        if (1 & (xLT (COREHALFWORD (mFIX_DIM), 0)))
          // DO; (8915)
          {
          rs2s2:;
            // FIX_DIM=1; (8916)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mFIX_DIM, bitRHS);
              bitRHS->inUse = 0;
            }
            // CALL ERROR(CLASS_SR,6,VAR(MP)); (8917)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_SR));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(6)));
              putCHARACTERp (mERRORxTEXT,
                             getCHARACTER (mVAR + 4 * getFIXED (mMP)));
              ERROR (0);
            }
          es2s2:;
          } // End of DO block
    es2:;
    } // End of DO block
  // CALL HALMAT_TUPLE(XBTOQ(PSEUDO_TYPE(TEMP)-BIT_TYPE),0,MPP1,0,T); (8918)
  {
    putBITp (16, mHALMAT_TUPLExPOPCODE,
             getBIT (16, mXBTOQ
                             + 2
                                   * xsubtract (BYTE0 (mPSEUDO_TYPE
                                                       + 1 * getFIXED (mTEMP)),
                                                1)));
    putBITp (8, mHALMAT_TUPLExCOPT, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mHALMAT_TUPLExOP1,
             fixedToBit (32, (int32_t)(getFIXED (mMPP1))));
    putBITp (16, mHALMAT_TUPLExOP2, fixedToBit (32, (int32_t)(0)));
    putBITp (8, mHALMAT_TUPLExTAG, getBIT (16, mEND_SUBBIT_FCNxT));
    HALMAT_TUPLE (0);
  }
  // CALL SETUP_VAC(MP,BIT_TYPE,FIX_DIM); (8919)
  {
    putBITp (16, mSETUP_VACxLOC, fixedToBit (32, (int32_t)(getFIXED (mMP))));
    putBITp (16, mSETUP_VACxTYPE, fixedToBit (32, (int32_t)(1)));
    putBITp (16, mSETUP_VACxSIZE, getBIT (16, mFIX_DIM));
    SETUP_VAC (0);
  }
  // T=0; (8920)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEND_SUBBIT_FCNxT, bitRHS);
    bitRHS->inUse = 0;
  }
  // NEXT_SUB=1; (8921)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mNEXT_SUB, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE T~=IND_LINK; (8922)
  while (1
         & (xNEQ (COREHALFWORD (mEND_SUBBIT_FCNxT), COREHALFWORD (mIND_LINK))))
    {
      // T=PSEUDO_LENGTH(T); (8923)
      {
        descriptor_t *bitRHS = getBIT (
            16, mPSEUDO_LENGTH + 2 * COREHALFWORD (mEND_SUBBIT_FCNxT));
        putBIT (16, mEND_SUBBIT_FCNxT, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL HALMAT_PIP(LOC_P(T),PSEUDO_FORM(T),INX(T),VAL_P(T)); (8924)
      {
        putBITp (16, mHALMAT_PIPxOPERAND,
                 getBIT (16, mLOC_P + 2 * COREHALFWORD (mEND_SUBBIT_FCNxT)));
        putBITp (
            8, mHALMAT_PIPxQUAL,
            getBIT (8, mPSEUDO_FORM + 1 * COREHALFWORD (mEND_SUBBIT_FCNxT)));
        putBITp (8, mHALMAT_PIPxTAG1,
                 getBIT (16, mINX + 2 * COREHALFWORD (mEND_SUBBIT_FCNxT)));
        putBITp (8, mHALMAT_PIPxTAG2,
                 getBIT (16, mVAL_P + 2 * COREHALFWORD (mEND_SUBBIT_FCNxT)));
        HALMAT_PIP (0);
      }
      // NEXT_SUB=NEXT_SUB+1; (8925)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mNEXT_SUB), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mNEXT_SUB, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // CALL HALMAT_FIX_PIP#(LAST_POP#,NEXT_SUB); (8926)
  {
    putFIXED (mHALMAT_FIX_PIPpxPOP_LOC, getFIXED (mLAST_POPp));
    putBITp (8, mHALMAT_FIX_PIPpxPIPp, getBIT (16, mNEXT_SUB));
    HALMAT_FIX_PIPp (0);
  }
  // PTR_TOP=PTR(MP); (8927)
  {
    descriptor_t *bitRHS = getBIT (16, mPTR + 2 * getFIXED (mMP));
    putBIT (16, mPTR_TOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // INX(PTR_TOP)=0; (8928)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mINX + 2 * (COREHALFWORD (mPTR_TOP)), bitRHS);
    bitRHS->inUse = 0;
  }
  // FIXL(MP)=FIXL(MPP1); (8929)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mFIXL + 4 * getFIXED (mMPP1)));
    putFIXED (mFIXL + 4 * (getFIXED (mMP)), numberRHS);
  }
  // FIXV(MP)=FIXV(MPP1); (8930)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mFIXV + 4 * getFIXED (mMPP1)));
    putFIXED (mFIXV + 4 * (getFIXED (mMP)), numberRHS);
  }
  // VAR(MP)=VAR(MPP1); (8931)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mVAR + 4 * getFIXED (mMPP1));
    putCHARACTER (mVAR + 4 * (getFIXED (mMP)), stringRHS);
    stringRHS->inUse = 0;
  }
  // T=0; (8932)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEND_SUBBIT_FCNxT, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
