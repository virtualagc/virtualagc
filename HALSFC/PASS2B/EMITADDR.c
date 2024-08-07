/*
  File EMITADDR.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
EMITADDR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "EMITADDR");
  // FLAG = 0; (1120)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEMITADDRxFLAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF VAL < 0 THEN (1121)
  if (1 & (xLT (getFIXED (mEMITADDRxVAL), 0)))
    // DO; (1122)
    {
    rs1:;
      // IF OP ~= DADDR THEN (1123)
      if (1 & (xNEQ (COREHALFWORD (mEMITADDRxOP), BYTE0 (mDADDR))))
        // VAL = -VAL; (1124)
        {
          int32_t numberRHS = (int32_t)(xminus (getFIXED (mEMITADDRxVAL)));
          putFIXED (mEMITADDRxVAL, numberRHS);
        }
      // ELSE (1125)
      else
        // VAL = (-VAL& 4294901760)|(VAL& 65535); (1126)
        {
          int32_t numberRHS = (int32_t)(xOR (
              xAND (xminus (getFIXED (mEMITADDRxVAL)), 4294901760),
              xAND (getFIXED (mEMITADDRxVAL), 65535)));
          putFIXED (mEMITADDRxVAL, numberRHS);
        }
      // FLAG = 8; (1127)
      {
        int32_t numberRHS = (int32_t)(8);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mEMITADDRxFLAG, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // CALL EMITC(RLD, CTR + SHL(FLAG,12)); (1128)
  {
    putBITp (16, mEMITCxTYPE, getBIT (8, mRLD));
    putBITp (16, mEMITCxINST,
             fixedToBit (32, (int32_t)(xadd (
                                 COREHALFWORD (mEMITADDRxCTR),
                                 SHL (COREHALFWORD (mEMITADDRxFLAG), 12)))));
    EMITC (0);
  }
  // CTR = CTR &  4095; (1129)
  {
    int32_t numberRHS = (int32_t)(xAND (COREHALFWORD (mEMITADDRxCTR), 4095));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEMITADDRxCTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF OP ~= 0 THEN (1130)
  if (1 & (xNEQ (COREHALFWORD (mEMITADDRxOP), 0)))
    // CALL EMITC(OP, CTR); (1131)
    {
      putBITp (16, mEMITCxTYPE, getBIT (16, mEMITADDRxOP));
      putBITp (16, mEMITCxINST, getBIT (16, mEMITADDRxCTR));
      EMITC (0);
    }
  // ELSE (1132)
  else
    // CALL EMITC(HADDR, CTR); (1133)
    {
      putBITp (16, mEMITCxTYPE, getBIT (8, mHADDR));
      putBITp (16, mEMITCxINST, getBIT (16, mEMITADDRxCTR));
      EMITC (0);
    }
  // CALL EMITW(VAL, 1); (1134)
  {
    putFIXED (mEMITWxDATA, getFIXED (mEMITADDRxVAL));
    putBITp (1, mEMITWxMODIFIER, fixedToBit (32, (int32_t)(1)));
    EMITW (0);
  }
  // IF OP ~= DADDR THEN (1135)
  if (1 & (xNEQ (COREHALFWORD (mEMITADDRxOP), BYTE0 (mDADDR))))
    // LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 1; (1136)
    {
      int32_t numberRHS = (int32_t)(xadd (
          getFIXED (mLOCCTR + 4 * COREHALFWORD (mINDEXNEST)), 1));
      putFIXED (mLOCCTR + 4 * (COREHALFWORD (mINDEXNEST)), numberRHS);
    }
  // ELSE (1137)
  else
    // LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 2; (1138)
    {
      int32_t numberRHS = (int32_t)(xadd (
          getFIXED (mLOCCTR + 4 * COREHALFWORD (mINDEXNEST)), 2));
      putFIXED (mLOCCTR + 4 * (COREHALFWORD (mINDEXNEST)), numberRHS);
    }
  // VAL, OP = 0; (1139)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mEMITADDRxVAL, numberRHS);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEMITADDRxOP, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
