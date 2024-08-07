/*
  File PRINT2.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
PRINT2 (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PRINT2");
  // LISTING2_COUNT = LISTING2_COUNT + SPACE; (1139)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mLISTING2_COUNT),
                                        COREHALFWORD (mPRINT2xSPACE)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLISTING2_COUNT, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF LISTING2_COUNT > LINE_LIM THEN (1140)
  if (1 & (xGT (COREHALFWORD (mLISTING2_COUNT), COREHALFWORD (mLINE_LIM))))
    // DO; (1141)
    {
    rs1:;
      // PAGE_NUM = PAGE_NUM + 1; (1142)
      {
        int32_t numberRHS
            = (int32_t)(xadd (COREHALFWORD (mPRINT2xPAGE_NUM), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPRINT2xPAGE_NUM, bitRHS);
        bitRHS->inUse = 0;
      }
      // OUTPUT(2) = '1  H A L   C O M P I L A T I O N   --   P H A S E   1 --
      // U N F O R M A T T E D   S O U R C E   L I S T I N G             PAGE '
      // || PAGE_NUM; (1143)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (cToDescriptor (
                         NULL, "1  H A L   C O M P I L A T I O N   --   P H A "
                               "S E   1   --   U N F O R M A T T E D   S O U "
                               "R C E   L I S T I N G             PAGE "),
                     bitToCharacter (getBIT (16, mPRINT2xPAGE_NUM)));
        OUTPUT (2, stringRHS);
        stringRHS->inUse = 0;
      }
      // BYTE(LINE) = BYTE('-'); (1144)
      {
        int32_t numberRHS = (int32_t)(BYTE1 (cToDescriptor (NULL, "-")));
        lBYTEb (ADDR (NULL, 0, "PRINT2xLINE", 0), 0,
                BYTE1 (cToDescriptor (NULL, "-")));
      }
      // LISTING2_COUNT = 4; (1145)
      {
        int32_t numberRHS = (int32_t)(4);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mLISTING2_COUNT, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // OUTPUT(2) = LINE; (1146)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mPRINT2xLINE);
    OUTPUT (2, stringRHS);
    stringRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
