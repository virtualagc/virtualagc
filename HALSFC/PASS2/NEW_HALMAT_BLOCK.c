/*
  File NEW_HALMAT_BLOCK.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
NEW_HALMAT_BLOCK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "NEW_HALMAT_BLOCK");
  // DO FOR I = 0 TO ATOM#_LIM; (1001)
  {
    int32_t from19, to19, by19;
    from19 = 0;
    to19 = 1799;
    by19 = 1;
    for (putBIT (16, mNEW_HALMAT_BLOCKxI, fixedToBit (16, from19));
         bitToFixed (getBIT (16, mNEW_HALMAT_BLOCKxI)) <= to19;
         putBIT (16, mNEW_HALMAT_BLOCKxI,
                 fixedToBit (16, bitToFixed (getBIT (16, mNEW_HALMAT_BLOCKxI))
                                     + by19)))
      {
        // VAC_VAL(I) = FALSE; (1002)
        {
          int32_t numberRHS = (int32_t)(0);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (1, mVAC_VAL + 1 * (COREHALFWORD (mNEW_HALMAT_BLOCKxI)),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // OPR(0)=FILE(CODEFILE,CURCBLK); (1003)
  {
    rFILE (ADDR ("FOR_ATOMS", 0, "CONST_ATOMS", 0), BYTE0 (mCODEFILE),
           BYTE0 (mCURCBLK));
  }
  // CURCBLK=CURCBLK+1; (1004)
  {
    int32_t numberRHS = (int32_t)(xadd (BYTE0 (mCURCBLK), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mCURCBLK, bitRHS);
    bitRHS->inUse = 0;
  }
  // CTR=0; (1005)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // OFF_PAGE_LAST = OFF_PAGE_NEXT; (1006)
  {
    descriptor_t *bitRHS = getBIT (16, mOFF_PAGE_NEXT);
    putBIT (16, mOFF_PAGE_LAST, bitRHS);
    bitRHS->inUse = 0;
  }
  // OFF_PAGE_NEXT = OFF_PAGE_NEXT + 1 & 1; (1007)
  {
    int32_t numberRHS
        = (int32_t)(xAND (xadd (COREHALFWORD (mOFF_PAGE_NEXT), 1), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOFF_PAGE_NEXT, bitRHS);
    bitRHS->inUse = 0;
  }
  // OFF_PAGE_CTR(OFF_PAGE_NEXT) = 0; (1008)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOFF_PAGE_CTR + 2 * (COREHALFWORD (mOFF_PAGE_NEXT)), bitRHS);
    bitRHS->inUse = 0;
  }
  // NUMOP = POPNUM(0); (1009)
  {
    int32_t numberRHS = (int32_t)((
        putBITp (16, mPOPNUMxCTR, fixedToBit (32, (int32_t)(0))), POPNUM (0)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mNUMOP, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
