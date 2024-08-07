/*
  File GENERATExEMIT_ARRAY_DO.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExEMIT_ARRAY_DO (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExEMIT_ARRAY_DO");
  // SAVCTR = CTR; (6083)
  {
    descriptor_t *bitRHS = getBIT (16, mCTR);
    putBIT (16, mGENERATExEMIT_ARRAY_DOxSAVCTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // CTR = DOCTR(LEVEL); (6084)
  {
    descriptor_t *bitRHS
        = getBIT (16, mGENERATExDOCTR
                          + 2 * COREHALFWORD (mGENERATExEMIT_ARRAY_DOxLEVEL));
    putBIT (16, mCTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // TMP = 0; (6085)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mTMP, numberRHS);
  }
  // CALL SAVE_REGS(RM, 3); (6086)
  {
    putBITp (16, mGENERATExSAVE_REGSxN1,
             fixedToBit (32, (int32_t)(getFIXED (mRM))));
    putBITp (1, mGENERATExSAVE_REGSxFLT, fixedToBit (32, (int32_t)(3)));
    GENERATExSAVE_REGS (0);
  }
  // DO SUBOP = 1 TO DOCOPY(LEVEL); (6087)
  {
    int32_t from79, to79, by79;
    from79 = 1;
    to79 = bitToFixed (getBIT (
        16, mDOCOPY + 2 * COREHALFWORD (mGENERATExEMIT_ARRAY_DOxLEVEL)));
    by79 = 1;
    for (putBIT (16, mGENERATExSUBOP, fixedToBit (16, from79));
         bitToFixed (getBIT (16, mGENERATExSUBOP)) <= to79;
         putBIT (16, mGENERATExSUBOP,
                 fixedToBit (16, bitToFixed (getBIT (16, mGENERATExSUBOP))
                                     + by79)))
      {
        // CALL CHECKPOINT_REG(TMP); (6088)
        {
          putBITp (16, mGENERATExCHECKPOINT_REGxR,
                   fixedToBit (32, (int32_t)(getFIXED (mTMP))));
          GENERATExCHECKPOINT_REG (0);
        }
        // CALL DECODEPIP(SUBOP, 2); (6089)
        {
          putBITp (16, mGENERATExDECODEPIPxOP, getBIT (16, mGENERATExSUBOP));
          putBITp (16, mGENERATExDECODEPIPxN, fixedToBit (32, (int32_t)(2)));
          GENERATExDECODEPIP (0);
        }
        // IF TAG1 = ASIZ THEN (6090)
        if (1 & (xEQ (COREHALFWORD (mTAG1), BYTE0 (mASIZ))))
          // OP1 = -OP1; (6091)
          {
            int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (mOP1)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mOP1, bitRHS);
            bitRHS->inUse = 0;
          }
        // CALL DOOPEN(1, 1, OP1); (6092)
        {
          putFIXED (mGENERATExDOOPENxSTART, 1);
          putFIXED (mGENERATExDOOPENxSTEP, 1);
          putFIXED (mGENERATExDOOPENxSTOP, COREHALFWORD (mOP1));
          GENERATExDOOPEN (0);
        }
        // DOFLAG(ADOPTR) = SHR(TAG3(2), 2); (6093)
        {
          int32_t numberRHS = (int32_t)(SHR (COREHALFWORD (mTAG3 + 2 * 2), 2));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (1, mGENERATExDOFLAG + 1 * (COREHALFWORD (mGENERATExADOPTR)),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // DOFORM(LEVEL) = 0; (6094)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16,
            mGENERATExDOFORM
                + 2 * (COREHALFWORD (mGENERATExEMIT_ARRAY_DOxLEVEL)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CTR = SAVCTR; (6095)
  {
    descriptor_t *bitRHS = getBIT (16, mGENERATExEMIT_ARRAY_DOxSAVCTR);
    putBIT (16, mCTR, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
