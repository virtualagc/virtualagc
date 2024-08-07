/*
  File EXPAND_DSUB.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

descriptor_t *
EXPAND_DSUB (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "EXPAND_DSUB");
  // DSUB_LOC = PTR; (3711)
  {
    descriptor_t *bitRHS = getBIT (16, mEXPAND_DSUBxPTR);
    putBIT (16, mDSUB_LOC, bitRHS);
    bitRHS->inUse = 0;
  }
  // DSUB_HOLE = LAST_OP(PTR - 1); (3712)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mLAST_OPxPTR,
                 fixedToBit (32, (int32_t)(xsubtract (
                                     COREHALFWORD (mEXPAND_DSUBxPTR), 1)))),
        LAST_OP (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mDSUB_HOLE, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF OPOP(DSUB_HOLE) ~= NOP | DSUB_HOLE < 0 THEN (3713)
  if (1
      & (xOR (
          xNEQ (bitToFixed ((putBITp (16, mOPOPxPTR, getBIT (16, mDSUB_HOLE)),
                             OPOP (0))),
                COREHALFWORD (mNOP)),
          xLT (COREHALFWORD (mDSUB_HOLE), 0))))
    // DSUB_HOLE = PTR; (3714)
    {
      descriptor_t *bitRHS = getBIT (16, mEXPAND_DSUBxPTR);
      putBIT (16, mDSUB_HOLE, bitRHS);
      bitRHS->inUse = 0;
    }
  // TEMP = PTR + 1; (3715)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mEXPAND_DSUBxPTR), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEXPAND_DSUBxTEMP, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SHR(OPR(TEMP),4) &  15) = LIT THEN (3716)
  if (1
      & (xEQ (
          xAND (
              SHR (getFIXED (mOPR + 4 * COREHALFWORD (mEXPAND_DSUBxTEMP)), 4),
              15),
          COREHALFWORD (mLIT))))
    // RETURN; (3717)
    {
      reentryGuard = 0;
      return fixedToBit (32, 0);
    }
  // IF (OPR(TEMP+1)& 65535) =  2385 THEN (3718)
  if (1
      & (xEQ (xAND (getFIXED (
                        mOPR + 4 * xadd (COREHALFWORD (mEXPAND_DSUBxTEMP), 1)),
                    65535),
              2385)))
    // RETURN; (3719)
    {
      reentryGuard = 0;
      return fixedToBit (32, 0);
    }
  // TSUB_SUB = OPOP(DSUB_LOC) = TSUB; (3720)
  {
    int32_t numberRHS = (int32_t)(xEQ (
        bitToFixed (
            (putBITp (16, mOPOPxPTR, getBIT (16, mDSUB_LOC)), OPOP (0))),
        COREHALFWORD (mTSUB)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mTSUB_SUB, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL SET_VAR(TEMP); (3721)
  {
    putBITp (16, mSET_VARxPTR, getBIT (16, mEXPAND_DSUBxTEMP));
    SET_VAR (0);
  }
  // IF VAR_TYPE = CHAR_VAR THEN (3722)
  if (1 & (xEQ (COREHALFWORD (mVAR_TYPE), BYTE0 (mCHAR_VAR))))
    // RETURN; (3723)
    {
      reentryGuard = 0;
      return fixedToBit (32, 0);
    }
  // PREVIOUS_COMPUTATION = FALSE; (3724)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mPREVIOUS_COMPUTATION, bitRHS);
    bitRHS->inUse = 0;
  }
  // PRESENT_DIMENSION = 0; (3725)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPRESENT_DIMENSION, bitRHS);
    bitRHS->inUse = 0;
  }
  // NUMOP = NO_OPERANDS(DSUB_LOC); (3726)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mNO_OPERANDSxPTR, getBIT (16, mDSUB_LOC)),
           NO_OPERANDS (0));
    putBIT (16, mEXPAND_DSUBxNUMOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // DSUB_INX = PTR + 2; (3727)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mEXPAND_DSUBxPTR), 2));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mDSUB_INX, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE DSUB_INX <= DSUB_LOC + NUMOP; (3728)
  while (1
         & (xLE (COREHALFWORD (mDSUB_INX),
                 xadd (COREHALFWORD (mDSUB_LOC),
                       COREHALFWORD (mEXPAND_DSUBxNUMOP)))))
    {
      // DO CASE ALPHA; (3729)
      {
      rs1s1:
        switch (
            xAND (SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDSUB_INX)), 8), 3))
          {
          case 0:
            // PRESENT_DIMENSION = PRESENT_DIMENSION + 1; (3731)
            {
              int32_t numberRHS
                  = (int32_t)(xadd (COREHALFWORD (mPRESENT_DIMENSION), 1));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mPRESENT_DIMENSION, bitRHS);
              bitRHS->inUse = 0;
            }
            break;
          case 1:
            // CALL CHECK_COMPONENT; (3732)
            CHECK_COMPONENT (0);
            break;
          case 2:
            // IF BETA THEN (3733)
            if (1 & (SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDSUB_INX)), 1)))
              {
                int32_t numberRHS
                    = (int32_t)(xadd (COREHALFWORD (mPRESENT_DIMENSION), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mPRESENT_DIMENSION, bitRHS);
                bitRHS->inUse = 0;
              }
            break;
          case 3:
            // IF ~BETA THEN (3735)
            if (1
                & (xNOT (
                    SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDSUB_INX)), 1))))
              CHECK_COMPONENT (0);
            break;
          }
      } // End of DO CASE block
      // DSUB_INX = DSUB_INX + 1; (3736)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mDSUB_INX), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mDSUB_INX, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // IF PREVIOUS_COMPUTATION THEN (3737)
  if (1 & (bitToFixed (getBIT (8, mPREVIOUS_COMPUTATION))))
    // CALL SET_SAV; (3738)
    SET_SAV (0);
  // TSUB_SUB = FALSE; (3739)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mTSUB_SUB, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
