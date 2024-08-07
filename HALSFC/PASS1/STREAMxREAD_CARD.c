/*
  File STREAMxREAD_CARD.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
STREAMxREAD_CARD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "STREAMxREAD_CARD");
  // IF END_OF_INPUT THEN (4469)
  if (1 & (bitToFixed (getBIT (1, mEND_OF_INPUT))))
    // DO; (4470)
    {
    rs1:;
      // CURRENT_CARD = INPUT_PAD || X70; (4471)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (getCHARACTER (mSTREAMxINPUT_PAD), getCHARACTER (mX70));
        putCHARACTER (mCURRENT_CARD, stringRHS);
        stringRHS->inUse = 0;
      }
      // RETURN; (4472)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
// READ: (4473)
READ:
  // CALL NEXT_RECORD; (4474)
  NEXT_RECORD (0);
  // IF LENGTH(CURRENT_CARD) > 88 THEN (4475)
  if (1 & (xGT (LENGTH (getCHARACTER (mCURRENT_CARD)), 88)))
    // CURRENT_CARD = SUBSTR(CURRENT_CARD, 0, 88); (4476)
    {
      descriptor_t *stringRHS;
      stringRHS = SUBSTR (getCHARACTER (mCURRENT_CARD), 0, 88);
      putCHARACTER (mCURRENT_CARD, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF LENGTH(CURRENT_CARD) = 0 THEN (4477)
  if (1 & (xEQ (LENGTH (getCHARACTER (mCURRENT_CARD)), 0)))
    // DO; (4478)
    {
    rs2:;
      // IF INCLUDING THEN (4479)
      if (1 & (bitToFixed (getBIT (1, mINCLUDING))))
        // DO; (4480)
        {
        rs2s1:;
          // INPUT_DEV=0; (4481)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mINPUT_DEV, bitRHS);
            bitRHS->inUse = 0;
          }
          // INCLUDE_COMPRESSED,INCLUDING=FALSE; (4482)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mINCLUDE_COMPRESSED, bitRHS);
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mINCLUDING, bitRHS);
            bitRHS->inUse = 0;
          }
          // INCLUDE_STMT = -1; (4483)
          {
            int32_t numberRHS = (int32_t)(-1);
            putFIXED (mINCLUDE_STMT, numberRHS);
          }
          // INCLUDE_END=TRUE; (4484)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mINCLUDE_END, bitRHS);
            bitRHS->inUse = 0;
          }
          // GOTO READ; (4485)
          goto READ;
        es2s1:;
        } // End of DO block
      // ELSE (4486)
      else
        // DO; (4487)
        {
        rs2s2:;
          // END_OF_INPUT = TRUE; (4488)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mEND_OF_INPUT, bitRHS);
            bitRHS->inUse = 0;
          }
          // CURRENT_CARD = INPUT_PAD || X70; (4489)
          {
            descriptor_t *stringRHS;
            stringRHS = xsCAT (getCHARACTER (mSTREAMxINPUT_PAD),
                               getCHARACTER (mX70));
            putCHARACTER (mCURRENT_CARD, stringRHS);
            stringRHS->inUse = 0;
          }
        es2s2:;
        } // End of DO block
    es2:;
    } // End of DO block
  // CARD_COUNT = CARD_COUNT + 1; (4490)
  {
    int32_t numberRHS = (int32_t)(xadd (getFIXED (mCARD_COUNT), 1));
    putFIXED (mCARD_COUNT, numberRHS);
  }
  // IF LISTING2 THEN (4491)
  if (1 & (bitToFixed (getBIT (1, mLISTING2))))
    // IF CARD_COUNT ~= 0 THEN (4492)
    if (1 & (xNEQ (getFIXED (mCARD_COUNT), 0)))
      // CALL SAVE_INPUT; (4493)
      SAVE_INPUT (0);
  // IF INCLUDE_END THEN (4494)
  if (1 & (bitToFixed (getBIT (1, mINCLUDE_END))))
    // DO; (4495)
    {
    rs3:;
      // INCLUDE_LIST2 = TRUE; (4496)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mINCLUDE_LIST2, bitRHS);
        bitRHS->inUse = 0;
      }
      // INCLUDE_OFFSET, INCLUDE_COUNT = INCLUDE_COUNT + CARD_COUNT -
      // INCLUDE_OFFSET; (4497)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            xadd (COREHALFWORD (mINCLUDE_COUNT), getFIXED (mCARD_COUNT)),
            COREHALFWORD (mINCLUDE_OFFSET)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mINCLUDE_OFFSET, bitRHS);
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mINCLUDE_COUNT, bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // SAVE_CARD = CURRENT_CARD; (4498)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mCURRENT_CARD);
    putCHARACTER (mSAVE_CARD, stringRHS);
    stringRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
