/*
  File POP_STACK.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
POP_STACK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "POP_STACK");
  // IF STACK_TRACE THEN (3327)
  if (1 & (bitToFixed (getBIT (8, mSTACK_TRACE))))
    // OUTPUT = 'POP_STACK(' || ALTER_VALIDITY || '):  ' || STT#; (3328)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (xsCAT (xsCAT (cToDescriptor (NULL, "POP_STACK("),
                                       bitToCharacter (getBIT (
                                           8, mPOP_STACKxALTER_VALIDITY))),
                                cToDescriptor (NULL, "):  ")),
                         bitToCharacter (getBIT (16, mSTTp)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // STACK_TAGS(LEVEL) = STACK_TAGS(LEVEL) &  1; (3329)
  {
    int32_t numberRHS = (int32_t)(xAND (BYTE0 (getFIXED (mLEVEL_STACK_VARS)
                                               + 11 * (COREHALFWORD (mLEVEL))
                                               + 10 + 1 * (0)),
                                        1));
    putBIT (8,
            getFIXED (mLEVEL_STACK_VARS) + 11 * (COREHALFWORD (mLEVEL)) + 10
                + 1 * (0),
            fixedToBit (8, numberRHS));
  }
  // IF LEVEL = 0 THEN (3330)
  if (1 & (xEQ (COREHALFWORD (mLEVEL), 0)))
    // DO; (3331)
    {
    rs1:;
      // CALL ZAP_TABLES; (3332)
      ZAP_TABLES (0);
      // RETURN; (3333)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
  // LEVEL = LEVEL - 1; (3334)
  {
    int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mLEVEL), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLEVEL, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF ALTER_VALIDITY THEN (3335)
  if (1 & (bitToFixed (getBIT (8, mPOP_STACKxALTER_VALIDITY))))
    // DO; (3336)
    {
    rs2:;
      // CALL MODIFY_VALIDITY; (3337)
      MODIFY_VALIDITY (0);
    es2:;
    } // End of DO block
  // IF CD THEN (3338)
  if (1 & (bitToFixed (getBIT (8, mPOP_STACKxCD))))
    // DO; (3339)
    {
    rs3:;
      // CALL COPY_DOWN; (3340)
      COPY_DOWN (0);
      // LEVEL = LEVEL + 1; (3341)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mLEVEL), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mLEVEL, bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // ELSE (3342)
  else
    // DO; (3343)
    {
    rs4:;
      // LEVEL = LEVEL + 1; (3344)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mLEVEL), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mLEVEL, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO FOR TEMP=LEVEL TO MAX_STACK_LEVEL-1; (3345)
      {
        int32_t from84, to84, by84;
        from84 = bitToFixed (getBIT (16, mLEVEL));
        to84 = 31;
        by84 = 1;
        for (putBIT (16, mPOP_STACKxTEMP, fixedToBit (16, from84));
             bitToFixed (getBIT (16, mPOP_STACKxTEMP)) <= to84;
             putBIT (16, mPOP_STACKxTEMP,
                     fixedToBit (16, bitToFixed (getBIT (16, mPOP_STACKxTEMP))
                                         + by84)))
          {
            // IF STACKED_BLOCK#(TEMP)>0 THEN (3346)
            if (1
                & (xGT (COREHALFWORD (getFIXED (mLEVEL_STACK_VARS)
                                      + 11 * (COREHALFWORD (mPOP_STACKxTEMP))
                                      + 8 + 2 * (0)),
                        0)))
              // STACKED_BLOCK#(TEMP) = -1; (3347)
              {
                int32_t numberRHS = (int32_t)(-1);
                putBIT (16,
                        getFIXED (mLEVEL_STACK_VARS)
                            + 11 * (COREHALFWORD (mPOP_STACKxTEMP)) + 8
                            + 2 * (0),
                        fixedToBit (16, numberRHS));
              }
            // ELSE (3348)
            else
              // GO TO EXITT; (3349)
              goto EXITT;
          }
      } // End of DO for-loop block
    es4:;
    } // End of DO block
// EXITT: (3350)
EXITT:
  // LEVEL = LEVEL - 1; (3351)
  {
    int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mLEVEL), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLEVEL, bitRHS);
    bitRHS->inUse = 0;
  }
  // LOOP_ZAPS_LEVEL = ZAP_BASE(LEVEL); (3352)
  {
    int32_t numberRHS
        = (int32_t)(getFIXED (getFIXED (mLEVEL_STACK_VARS)
                              + 11 * (COREHALFWORD (mLEVEL)) + 0 + 4 * (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLOOP_ZAPS_LEVEL, bitRHS);
    bitRHS->inUse = 0;
  }
  // BLOCK# = STACKED_BLOCK#(LEVEL); (3353)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mLEVEL_STACK_VARS)
                          + 11 * (COREHALFWORD (mLEVEL)) + 8 + 2 * (0));
    putBIT (16, mBLOCKp, bitRHS);
    bitRHS->inUse = 0;
  }
  // CD,ALTER_VALIDITY = FALSE; (3354)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mPOP_STACKxCD, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mPOP_STACKxALTER_VALIDITY, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF TRACE THEN (3355)
  if (1 & (bitToFixed (getBIT (8, mTRACE))))
    // CALL STACK_DUMP; (3356)
    STACK_DUMP (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
