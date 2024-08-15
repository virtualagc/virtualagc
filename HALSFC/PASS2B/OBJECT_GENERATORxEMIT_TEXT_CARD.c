/*
  File OBJECT_GENERATORxEMIT_TEXT_CARD.c generated by XCOM-I, 2024-08-09
  12:41:33.
*/

#include "runtimeC.h"

int32_t
OBJECT_GENERATORxEMIT_TEXT_CARD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "OBJECT_GENERATORxEMIT_TEXT_CARD");
  // IF (#TEXT_BYTES & 1) ~= 0 THEN (15402)
  if (1
      & (xNEQ (
          xAND (COREHALFWORD (mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES),
                1),
          0)))
    // DO; (15403)
    {
    rs1:;
      // #TEXT_HALFWORDS = SHR(#TEXT_BYTES + 1, 1); (15404)
      {
        int32_t numberRHS = (int32_t)(SHR (
            xadd (COREHALFWORD (mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES),
                  1),
            1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES, bitRHS);
        bitRHS->inUse = 0;
      }
      // RHS(#TEXT_HALFWORDS - 1) = RHS(#TEXT_HALFWORDS - 1) &  65280; (15405)
      {
        int32_t numberRHS = (int32_t)(xAND (
            COREHALFWORD (
                mRHS
                + 2
                      * xsubtract (
                          COREHALFWORD (
                              mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES),
                          1)),
            65280));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (
            16,
            mRHS
                + 2
                      * (xsubtract (
                          COREHALFWORD (
                              mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES),
                          1)),
            bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (15406)
  else
    // #TEXT_HALFWORDS = SHR(#TEXT_BYTES, 1); (15407)
    {
      int32_t numberRHS = (int32_t)(SHR (
          COREHALFWORD (mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES), 1));
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (16, mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES, bitRHS);
      bitRHS->inUse = 0;
    }
  // IF RECORD_ID = 0 THEN (15408)
  if (1 & (xEQ (COREHALFWORD (mOBJECT_GENERATORxCARD_IMAGE), 0)))
    // DO; (15409)
    {
    rs2:;
      // IF CURRENT_ESDID <= SYMBREAK THEN (15410)
      if (1 & (xLE (getFIXED (mCURRENT_ESDID), COREHALFWORD (mSYMBREAK))))
        // RECORD_ID = PTX_ID; (15411)
        {
          int32_t numberRHS = (int32_t)(1536);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (15412)
      else
        // IF ESD_CSECT_TYPE(CURRENT_ESDID) = ZCON_CSECT_TYPE THEN (15413)
        if (1
            & (xEQ (BYTE0 (mESD_CSECT_TYPE + 1 * getFIXED (mCURRENT_ESDID)),
                    96)))
          // RECORD_ID = PTX_ID; (15414)
          {
            int32_t numberRHS = (int32_t)(1536);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
            bitRHS->inUse = 0;
          }
        // ELSE (15415)
        else
          // IF CURRENT_ESDID = DATABASE THEN (15416)
          if (1 & (xEQ (getFIXED (mCURRENT_ESDID), COREHALFWORD (mDATABASE))))
            // DO; (15417)
            {
            rs2s1:;
              // IF CURRENT_ADDRESS >= GENED_LIT_START THEN (15418)
              if (1
                  & (xGE (getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)),
                          getFIXED (mGENED_LIT_START))))
                // RECORD_ID = PTX_ID; (15419)
                {
                  int32_t numberRHS = (int32_t)(1536);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
                  bitRHS->inUse = 0;
                }
              // ELSE (15420)
              else
                // IF CURRENT_ADDRESS < SYT_ADDR(PROC_LEVEL(PROGPOINT)) THEN
                // (15421)
                if (1
                    & (xLT (
                        getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)),
                        getFIXED (getFIXED (mSYM_TAB)
                                  + 34
                                        * (COREHALFWORD (
                                            mPROC_LEVEL
                                            + 2 * COREHALFWORD (mPROGPOINT)))
                                  + 4 + 4 * (0)))))
                  // RECORD_ID = PTX_ID; (15422)
                  {
                    int32_t numberRHS = (int32_t)(1536);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
                    bitRHS->inUse = 0;
                  }
                // ELSE (15423)
                else
                  // CALL CHECK_STORE_PROTECT; (15424)
                  OBJECT_GENERATORxEMIT_TEXT_CARDxCHECK_STORE_PROTECT (0);
            es2s1:;
            } // End of DO block
          // ELSE (15425)
          else
            // IF CURRENT_ESDID = REMOTE_LEVEL THEN (15426)
            if (1 & (xEQ (getFIXED (mCURRENT_ESDID), BYTE0 (mREMOTE_LEVEL))))
              // CALL CHECK_STORE_PROTECT; (15427)
              OBJECT_GENERATORxEMIT_TEXT_CARDxCHECK_STORE_PROTECT (0);
            // ELSE (15428)
            else
              // RECORD_ID = UTX_ID; (15429)
              {
                int32_t numberRHS = (int32_t)(1792);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
                bitRHS->inUse = 0;
              }
      // DISPLACEMENT = CURRENT_ADDRESS; (15430)
      {
        int32_t numberRHS
            = (int32_t)(getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxCARD_IMAGE + 2 * (1), bitRHS);
        bitRHS->inUse = 0;
      }
      // CSECT_ID = CURRENT_ESDID; (15431)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mCURRENT_ESDID));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxCARD_IMAGE + 2 * (2), bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  // IF (#TEXT_HALFWORDS + #TEXT_HALFWORDS_USED + 3) > 255 THEN (15432)
  if (1
      & (xGT (
          xadd (xadd (COREHALFWORD (
                          mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES),
                      COREHALFWORD (mOBJECT_GENERATORxpTEXT_HALFWORDS_USED)),
                3),
          255)))
    // DO; (15433)
    {
    rs3:;
      // RECORD_ID = RECORD_ID | (#TEXT_HALFWORDS_USED + 3); (15434)
      {
        int32_t numberRHS = (int32_t)(xOR (
            COREHALFWORD (mOBJECT_GENERATORxCARD_IMAGE),
            xadd (COREHALFWORD (mOBJECT_GENERATORxpTEXT_HALFWORDS_USED), 3)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
        bitRHS->inUse = 0;
      }
      // CALL EMIT_CARD; (15435)
      OBJECT_GENERATORxEMIT_CARD (0);
      // #TEXT_HALFWORDS_USED = 0; (15436)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxpTEXT_HALFWORDS_USED, bitRHS);
        bitRHS->inUse = 0;
      }
      // RECORD_ID = RECORD_ID &  65280; (15437)
      {
        int32_t numberRHS = (int32_t)(xAND (
            COREHALFWORD (mOBJECT_GENERATORxCARD_IMAGE), 65280));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxCARD_IMAGE, bitRHS);
        bitRHS->inUse = 0;
      }
      // DISPLACEMENT = CURRENT_ADDRESS; (15438)
      {
        int32_t numberRHS
            = (int32_t)(getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxCARD_IMAGE + 2 * (1), bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // DO FOR I = 1 TO #TEXT_HALFWORDS; (15439)
  {
    int32_t from145, to145, by145;
    from145 = 1;
    to145 = bitToFixed (
        getBIT (16, mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES));
    by145 = 1;
    for (putBIT (16, mOBJECT_GENERATORxEMIT_TEXT_CARDxI,
                 fixedToBit (16, from145));
         bitToFixed (getBIT (16, mOBJECT_GENERATORxEMIT_TEXT_CARDxI)) <= to145;
         putBIT (16, mOBJECT_GENERATORxEMIT_TEXT_CARDxI,
                 fixedToBit (16, bitToFixed (getBIT (
                                     16, mOBJECT_GENERATORxEMIT_TEXT_CARDxI))
                                     + by145)))
      {
        // CARD_IMAGE(TEXT_BASE + #TEXT_HALFWORDS_USED + I) = RHS(I - 1);
        // (15440)
        {
          descriptor_t *bitRHS = getBIT (
              16,
              mRHS
                  + 2
                        * xsubtract (
                            COREHALFWORD (mOBJECT_GENERATORxEMIT_TEXT_CARDxI),
                            1));
          putBIT (
              16,
              mOBJECT_GENERATORxCARD_IMAGE
                  + 2
                        * (xadd (
                            xadd (2,
                                  COREHALFWORD (
                                      mOBJECT_GENERATORxpTEXT_HALFWORDS_USED)),
                            COREHALFWORD (
                                mOBJECT_GENERATORxEMIT_TEXT_CARDxI))),
              bitRHS);
          bitRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // #TEXT_HALFWORDS_USED = #TEXT_HALFWORDS_USED + #TEXT_HALFWORDS; (15441)
  {
    int32_t numberRHS = (int32_t)(xadd (
        COREHALFWORD (mOBJECT_GENERATORxpTEXT_HALFWORDS_USED),
        COREHALFWORD (mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOBJECT_GENERATORxpTEXT_HALFWORDS_USED, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL PRINT_LINE(SHL(#TEXT_HALFWORDS, 1)); (15442)
  {
    putBITp (
        16, mOBJECT_GENERATORxPRINT_LINExI,
        fixedToBit (32, (int32_t)(SHL (
                            COREHALFWORD (
                                mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES),
                            1))));
    OBJECT_GENERATORxPRINT_LINE (0);
  }
  // CURRENT_ADDRESS = CURRENT_ADDRESS + #TEXT_HALFWORDS; (15443)
  {
    int32_t numberRHS = (int32_t)(xadd (
        getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)),
        COREHALFWORD (mOBJECT_GENERATORxEMIT_TEXT_CARDxpTEXT_BYTES)));
    putFIXED (mWORKSEG + 4 * (getFIXED (mCURRENT_ESDID)), numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}