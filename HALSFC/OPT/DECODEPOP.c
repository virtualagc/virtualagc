/*
  File DECODEPOP.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
DECODEPOP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DECODEPOP");
  // CLASS=SHR(OPR(CTR),12)& 15; (669)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 12), 15));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCLASS, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF CLASS=0 THEN (670)
  if (1 & (xEQ (COREHALFWORD (mCLASS), 0)))
    // DO; (671)
    {
    rs1:;
      // OPCODE=SHR(OPR(CTR),4)& 255; (672)
      {
        int32_t numberRHS = (int32_t)(xAND (
            SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 4),
            255));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOPCODE, bitRHS);
        bitRHS->inUse = 0;
      }
      // SUBCODE=0; (673)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mSUBCODE, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (674)
  else
    // DO; (675)
    {
    rs2:;
      // OPCODE=SHR(OPR(CTR),4)& 31; (676)
      {
        int32_t numberRHS = (int32_t)(xAND (
            SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 4), 31));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOPCODE, bitRHS);
        bitRHS->inUse = 0;
      }
      // SUBCODE=SHR(OPR(CTR),9)& 7; (677)
      {
        int32_t numberRHS = (int32_t)(xAND (
            SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 9), 7));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mSUBCODE, bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  // SUBCODE2 = SHR(OPR(CTR),4) &  255; (678)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 4), 255));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mSUBCODE2, bitRHS);
    bitRHS->inUse = 0;
  }
  // TAG=SHR(OPR(CTR),24)& 255; (679)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 24), 255));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mTAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // NUMOP=SHR(OPR(CTR),16)& 255; (680)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)), 16), 255));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mNUMOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF HALMAT_REQUESTED THEN (681)
  if (1 & (bitToFixed (getBIT (8, mHALMAT_REQUESTED))))
    // DO; (682)
    {
    rs3:;
      // MESSAGE = FORMAT(TAG,3) ||','|| (SHR(OPR(CTR),1) &  7)|| ':' ||
      // CURCBLK-1||'.'||CTR; (683)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (
            xsCAT (
                xsCAT (
                    xsCAT (
                        xsCAT (
                            xsCAT (
                                (putFIXED (mFORMATxIVAL, COREHALFWORD (mTAG)),
                                 putFIXED (mFORMATxN, 3), FORMAT (0)),
                                cToDescriptor (NULL, ",")),
                            fixedToCharacter (xAND (
                                SHR (getFIXED (
                                         mOPR
                                         + 4 * COREHALFWORD (mDECODEPOPxCTR)),
                                     1),
                                7))),
                        cToDescriptor (NULL, ":")),
                    fixedToCharacter (xsubtract (BYTE0 (mCURCBLK), 1))),
                cToDescriptor (NULL, ".")),
            bitToCharacter (getBIT (16, mDECODEPOPxCTR)));
        putCHARACTER (mMESSAGE, stringRHS);
        stringRHS->inUse = 0;
      }
      // MESSAGE=FORMAT(NUMOP,3)||'),'||MESSAGE; (684)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (xsCAT ((putFIXED (mFORMATxIVAL, COREHALFWORD (mNUMOP)),
                             putFIXED (mFORMATxN, 3), FORMAT (0)),
                            cToDescriptor (NULL, "),")),
                     getCHARACTER (mMESSAGE));
        putCHARACTER (mMESSAGE, stringRHS);
        stringRHS->inUse = 0;
      }
      // MESSAGE=HEX(SHR(OPR(CTR),4)& 4095,3)||LEFTBRACKET||MESSAGE; (685)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (
            xsCAT (
                (putFIXED (
                     mHEXxHVAL,
                     xAND (SHR (getFIXED (mOPR
                                          + 4 * COREHALFWORD (mDECODEPOPxCTR)),
                                4),
                           4095)),
                 putFIXED (mHEXxN, 3), HEX (0)),
                getCHARACTER (mLEFTBRACKET)),
            getCHARACTER (mMESSAGE));
        putCHARACTER (mMESSAGE, stringRHS);
        stringRHS->inUse = 0;
      }
      // OUTPUT='         HALMAT: '||MESSAGE; (686)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (cToDescriptor (NULL, "         HALMAT: "),
                           getCHARACTER (mMESSAGE));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // IF (OPR(CTR) &  65521) = XSMRK THEN (687)
      if (1
          & (xEQ (xAND (getFIXED (mOPR + 4 * COREHALFWORD (mDECODEPOPxCTR)),
                        65521),
                  COREHALFWORD (mXSMRK))))
        // OUTPUT = '                                        STATEMENT# ' ||
        // SHR(OPR(CTR+1),16); (688)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              cToDescriptor (
                  NULL, "                                        STATEMENT# "),
              fixedToCharacter (
                  SHR (getFIXED (
                           mOPR + 4 * xadd (COREHALFWORD (mDECODEPOPxCTR), 1)),
                       16)));
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
    es3:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
