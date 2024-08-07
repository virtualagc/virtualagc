/*
  File GENERATExSET_DOPTRS.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExSET_DOPTRS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSET_DOPTRS");
  // IF VDLP_ACTIVE THEN (5829)
  if (1 & (bitToFixed (getBIT (1, mVDLP_ACTIVE))))
    // DO; (5830)
    {
    rs1:;
      // IF COPY(PTR) = 0 THEN (5831)
      if (1
          & (xEQ (
              COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR))
                            + 26 + 2 * (0)),
              0)))
        // DO; (5832)
        {
        rs1s1:;
          // I = CALL_LEVEL; (5833)
          {
            descriptor_t *bitRHS = getBIT (16, mCALL_LEVEL);
            putBIT (16, mGENERATExSET_DOPTRSxI, bitRHS);
            bitRHS->inUse = 0;
          }
          // J = VMCOPY(PTR); (5834)
          {
            descriptor_t *bitRHS = getBIT (
                8, getFIXED (mIND_STACK)
                       + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR)) + 67
                       + 1 * (0));
            putBIT (16, mGENERATExSET_DOPTRSxJ, bitRHS);
            bitRHS->inUse = 0;
          }
          // STRUCT_INX(PTR) = STRUCT_INX(PTR) & ~1; (5835)
          {
            int32_t numberRHS = (int32_t)(xAND (
                BYTE0 (getFIXED (mIND_STACK)
                       + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR)) + 66
                       + 1 * (0)),
                4294967294));
            putBIT (8,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR)) + 66
                        + 1 * (0),
                    fixedToBit (8, numberRHS));
          }
        es1s1:;
        } // End of DO block
      // ELSE (5836)
      else
        // DO; (5837)
        {
        rs1s2:;
          // I = CALL_LEVEL - DOPUSH(CALL_LEVEL); (5838)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                COREHALFWORD (mCALL_LEVEL),
                BYTE0 (mGENERATExDOPUSH + 1 * COREHALFWORD (mCALL_LEVEL))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExSET_DOPTRSxI, bitRHS);
            bitRHS->inUse = 0;
          }
          // J = (VMCOPY(PTR)&DOPUSH(CALL_LEVEL)) + DOCOPY(I); (5839)
          {
            int32_t numberRHS = (int32_t)(xadd (
                xAND (
                    BYTE0 (getFIXED (mIND_STACK)
                           + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR))
                           + 67 + 1 * (0)),
                    BYTE0 (mGENERATExDOPUSH + 1 * COREHALFWORD (mCALL_LEVEL))),
                COREHALFWORD (mDOCOPY
                              + 2 * COREHALFWORD (mGENERATExSET_DOPTRSxI))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExSET_DOPTRSxJ, bitRHS);
            bitRHS->inUse = 0;
          }
          // ARRAY_FLAG = ARRAY_FLAG | FLAG; (5840)
          {
            int32_t numberRHS = (int32_t)(xOR (
                BYTE0 (mARRAY_FLAG), BYTE0 (mGENERATExSET_DOPTRSxFLAG)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mARRAY_FLAG, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s2:;
        } // End of DO block
    es1:;
    } // End of DO block
  // ELSE (5841)
  else
    // DO; (5842)
    {
    rs2:;
      // I = CALL_LEVEL; (5843)
      {
        descriptor_t *bitRHS = getBIT (16, mCALL_LEVEL);
        putBIT (16, mGENERATExSET_DOPTRSxI, bitRHS);
        bitRHS->inUse = 0;
      }
      // J = DOCOPY(I); (5844)
      {
        descriptor_t *bitRHS
            = getBIT (16, mDOCOPY + 2 * COREHALFWORD (mGENERATExSET_DOPTRSxI));
        putBIT (16, mGENERATExSET_DOPTRSxJ, bitRHS);
        bitRHS->inUse = 0;
      }
      // ARRAY_FLAG = ARRAY_FLAG | FLAG; (5845)
      {
        int32_t numberRHS = (int32_t)(xOR (BYTE0 (mARRAY_FLAG),
                                           BYTE0 (mGENERATExSET_DOPTRSxFLAG)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mARRAY_FLAG, bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  // DOPTR(CALL_LEVEL) = SDOPTR(I); (5846)
  {
    descriptor_t *bitRHS = getBIT (
        16, mGENERATExSDOPTR + 2 * COREHALFWORD (mGENERATExSET_DOPTRSxI));
    putBIT (16, mGENERATExDOPTR + 2 * (COREHALFWORD (mCALL_LEVEL)), bitRHS);
    bitRHS->inUse = 0;
  }
  // DOTOT(CALL_LEVEL) = DOPTR(CALL_LEVEL) + J; (5847)
  {
    int32_t numberRHS = (int32_t)(xadd (
        COREHALFWORD (mGENERATExDOPTR + 2 * COREHALFWORD (mCALL_LEVEL)),
        COREHALFWORD (mGENERATExSET_DOPTRSxJ)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExDOTOT + 2 * (COREHALFWORD (mCALL_LEVEL)), bitRHS);
    bitRHS->inUse = 0;
  }
  // SUBLIMIT(STACK#+COPY(PTR)+VMCOPY(PTR)) = 1; (5848)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (
        16,
        mGENERATExSUBLIMIT
            + 2
                  * (xadd (
                      xadd (
                          COREHALFWORD (mSTACKp),
                          COREHALFWORD (
                              getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR))
                              + 26 + 2 * (0))),
                      BYTE0 (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR))
                             + 67 + 1 * (0)))),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // SUBLIMIT(STACK#+COPY(PTR)) = AREASAVE; (5849)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mAREASAVE));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (
        16,
        mGENERATExSUBLIMIT
            + 2
                  * (xadd (COREHALFWORD (mSTACKp),
                           COREHALFWORD (
                               getFIXED (mIND_STACK)
                               + 73 * (COREHALFWORD (mGENERATExSET_DOPTRSxPTR))
                               + 26 + 2 * (0)))),
        bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN J; (5850)
  {
    reentryGuard = 0;
    return getBIT (16, mGENERATExSET_DOPTRSxJ);
  }
}
