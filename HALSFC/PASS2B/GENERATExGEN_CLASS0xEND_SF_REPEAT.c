/*
  File GENERATExGEN_CLASS0xEND_SF_REPEAT.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xEND_SF_REPEAT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xEND_SF_REPEAT");
  // IF CT <= 1 THEN (11487)
  if (1 & (xLE (COREHALFWORD (mGENERATExGEN_CLASS0xEND_SF_REPEATxCT), 1)))
    // RETURN; (11488)
    {
      reentryGuard = 0;
      return 0;
    }
  // CALL CHECK_VAC(LEFTOP, XVAL(INDEX)); (11489)
  {
    putBITp (16, mGENERATExCHECK_VACxOP, getBIT (16, mLEFTOP));
    putBITp (16, mGENERATExCHECK_VACxR,
             fixedToBit (32, (int32_t)(getFIXED (getFIXED (mIND_STACK)
                                                 + 73 * (COREHALFWORD (mINDEX))
                                                 + 16 + 4 * (0)))));
    GENERATExCHECK_VAC (0);
  }
  // CALL CHECK_VAC(INDEX, VAL(INDEX)); (11490)
  {
    putBITp (16, mGENERATExCHECK_VACxOP, getBIT (16, mINDEX));
    putBITp (16, mGENERATExCHECK_VACxR,
             fixedToBit (32, (int32_t)(getFIXED (getFIXED (mIND_STACK)
                                                 + 73 * (COREHALFWORD (mINDEX))
                                                 + 12 + 4 * (0)))));
    GENERATExCHECK_VAC (0);
  }
  // IF SELF_ALIGNING THEN (11491)
  if (1 & (bitToFixed (getBIT (1, mSELF_ALIGNING))))
    // CALL EMITP(AHI, REG(LEFTOP), 0, 0, AREA/SF_DISP); (11492)
    {
      putBITp (16, mGENERATExEMITPxINST, getBIT (8, mAHI));
      putBITp (16, mGENERATExEMITPxXREG,
               getBIT (16, getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mLEFTOP)) + 46
                               + 2 * (0)));
      putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
      putBITp (16, mGENERATExEMITPxFLAG, fixedToBit (32, (int32_t)(0)));
      putBITp (16, mGENERATExEMITPxPTR,
               fixedToBit (32, (int32_t)(xdivide (getFIXED (mAREA),
                                                  COREHALFWORD (mSF_DISP)))));
      GENERATExEMITP (0);
    }
  // ELSE (11493)
  else
    // CALL EMITP(AHI, REG(LEFTOP), 0, 0, AREA); (11494)
    {
      putBITp (16, mGENERATExEMITPxINST, getBIT (8, mAHI));
      putBITp (16, mGENERATExEMITPxXREG,
               getBIT (16, getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mLEFTOP)) + 46
                               + 2 * (0)));
      putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
      putBITp (16, mGENERATExEMITPxFLAG, fixedToBit (32, (int32_t)(0)));
      putBITp (16, mGENERATExEMITPxPTR,
               fixedToBit (32, (int32_t)(getFIXED (mAREA))));
      GENERATExEMITP (0);
    }
  // CALL EMITPFW(BCT, REG(INDEX), GETSTMTLBL(FIRSTLABEL)); (11495)
  {
    putBITp (16, mGENERATExEMITPFWxINST, getBIT (8, mBCT));
    putBITp (16, mGENERATExEMITPFWxXREG,
             getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mINDEX))
                             + 46 + 2 * (0)));
    putBITp (
        16, mGENERATExEMITPFWxPTR,
        (putFIXED (mGENERATExGETSTMTLBLxSTATNO, COREHALFWORD (mFIRSTLABEL)),
         GENERATExGETSTMTLBL (0)));
    GENERATExEMITPFW (0);
  }
  // CALL DROP_VAC(INDEX); (11496)
  {
    putBITp (16, mGENERATExDROP_VACxPTR, getBIT (16, mINDEX));
    GENERATExDROP_VAC (0);
  }
  // CALL DROP_VAC(LEFTOP); (11497)
  {
    putBITp (16, mGENERATExDROP_VACxPTR, getBIT (16, mLEFTOP));
    GENERATExDROP_VAC (0);
  }
  // INX(RESULT) = 0; (11498)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRESULT)) + 34
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
