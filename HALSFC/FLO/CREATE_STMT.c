/*
  File CREATE_STMT.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
CREATE_STMT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CREATE_STMT");
  // IF SMRK_LIST = NILL THEN (1127)
  if (1 & (xEQ (getFIXED (mSMRK_LIST), -1)))
    // RETURN; (1128)
    {
      reentryGuard = 0;
      return 0;
    }
  // CALL LOCATE(SMRK_LIST,ADDR(NODE),MODF); (1129)
  {
    putFIXED (mLOCATExPTR, getFIXED (mSMRK_LIST));
    putFIXED (mLOCATExBVAR, ADDR ("CREATE_STMTxNODE", 0x80000000, NULL, 0));
    putBITp (8, mLOCATExFLAGS, getBIT (8, mMODF));
    LOCATE (0);
  }
  // IF NO_OP_LST THEN (1130)
  if (1
      & (xAND (xEQ (getFIXED (getFIXED (mCREATE_STMTxNODE) + 4 * 1), 32),
               xEQ (getFIXED (getFIXED (mCREATE_STMTxNODE) + 4 * 2), -1))))
    // RETURN; (1131)
    {
      reentryGuard = 0;
      return 0;
    }
  // TOTAL_HMAT_BYTES = TOTAL_HMAT_BYTES + (#CELLS*4); (1132)
  {
    int32_t numberRHS = (int32_t)(xadd (
        getFIXED (mCOMM + 4 * 31), xmultiply (COREHALFWORD (mpCELLS), 4)));
    putFIXED (mCOMM + 4 * (31), numberRHS);
  }
  // NODE(0) = HCELL_HEADER; (1133)
  {
    int32_t numberRHS
        = (int32_t)(xOR (SHL (xsubtract (COREHALFWORD (mpCELLS), 1), 16),
                         COREHALFWORD (mFINAL_OP)));
    putFIXED (getFIXED (mCREATE_STMTxNODE) + 4 * (0), numberRHS);
  }
  // DO FOREVER; (1134)
  while (1 & (1))
    {
      // IF STMT_DATA_CELL = NILL THEN (1135)
      if (1 & (xEQ (getFIXED (mSTMT_DATA_CELL), -1)))
        // CALL ERRORS (CLASS_BI, 222, ' '||STMT#); (1136)
        {
          putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_BI));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(222)));
          putCHARACTERp (mERRORSxTEXT,
                         xsCAT (cToDescriptor (NULL, " "),
                                bitToCharacter (getBIT (16, mSTMTp))));
          ERRORS (0);
        }
      // CALL LOCATE(STMT_DATA_CELL,ADDR(NODE),0); (1137)
      {
        putFIXED (mLOCATExPTR, getFIXED (mSTMT_DATA_CELL));
        putFIXED (mLOCATExBVAR,
                  ADDR ("CREATE_STMTxNODE", 0x80000000, NULL, 0));
        putBITp (8, mLOCATExFLAGS, fixedToBit (32, (int32_t)(0)));
        LOCATE (0);
      }
      // CELL_STMT# = SHR(NODE(7),16); (1138)
      {
        int32_t numberRHS = (int32_t)(SHR (
            getFIXED (getFIXED (mCREATE_STMTxNODE) + 4 * 7), 16));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mCREATE_STMTxCELL_STMTp, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF CELL_STMT# = OLD_STMT# THEN (1139)
      if (1
          & (xEQ (COREHALFWORD (mCREATE_STMTxCELL_STMTp),
                  COREHALFWORD (mOLD_STMTp))))
        // DO; (1140)
        {
        rs1s1:;
          // CALL DISP(MODF); (1141)
          {
            putBITp (8, mDISPxFLAGS, getBIT (8, mMODF));
            DISP (0);
          }
          // NODE(HMAT_PTR) = SMRK_LIST; (1142)
          {
            int32_t numberRHS = (int32_t)(getFIXED (mSMRK_LIST));
            putFIXED (getFIXED (mCREATE_STMTxNODE) + 4 * (-1), numberRHS);
          }
          // RETURN; (1143)
          {
            reentryGuard = 0;
            return 0;
          }
        es1s1:;
        } // End of DO block
      // STMT_DATA_CELL = NODE(0); (1144)
      {
        int32_t numberRHS
            = (int32_t)(getFIXED (getFIXED (mCREATE_STMTxNODE) + 4 * 0));
        putFIXED (mSTMT_DATA_CELL, numberRHS);
      }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
