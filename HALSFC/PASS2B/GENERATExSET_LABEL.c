/*
  File GENERATExSET_LABEL.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExSET_LABEL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSET_LABEL");
  // IF ~FLAG1 THEN (3325)
  if (1 & (xNOT (BYTE0 (mGENERATExSET_LABELxFLAG1))))
    // CALL CLEAR_REGS; (3326)
    CLEAR_REGS (0);
  // STOPPERFLAG = FALSE; (3327)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mSTOPPERFLAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // CCREG = 0; (3328)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCCREG, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO ; (3329)
  {
  rs1:;
    // IF COREWORD ( ADDR ( LAB_LOC ) + 12 ) >= COREWORD ( ADDR ( LAB_LOC ) + 8
    // ) THEN (3330)
    if (1
        & (xGE (COREWORD (xadd (ADDR ("LAB_LOC", 0x80000000, NULL, 0), 12)),
                COREWORD (xadd (ADDR ("LAB_LOC", 0x80000000, NULL, 0), 8)))))
      // CALL _NEEDMORE_SPACE ( ADDR ( LAB_LOC )  ) ; (3331)
      {
        putFIXED (m_NEEDMORE_SPACExDOPE,
                  ADDR ("LAB_LOC", 0x80000000, NULL, 0));
        _NEEDMORE_SPACE (0);
      }
    // COREWORD ( ADDR ( LAB_LOC ) + 12 ) = COREWORD ( ADDR ( LAB_LOC ) + 12 )
    // + 1 ; (3332)
    {
      int32_t numberRHS = (int32_t)(xadd (
          COREWORD (xadd (ADDR ("LAB_LOC", 0x80000000, NULL, 0), 12)), 1));
      COREWORD2 (xadd (ADDR ("LAB_LOC", 0x80000000, NULL, 0), 12), numberRHS);
    }
  es1:;
  } // End of DO block
  // LOCATION(STMTNO) = LOCCTR(INDEXNEST); (3333)
  {
    int32_t numberRHS
        = (int32_t)(getFIXED (mLOCCTR + 4 * COREHALFWORD (mINDEXNEST)));
    putFIXED (getFIXED (mLAB_LOC)
                  + 8 * (COREHALFWORD (mGENERATExSET_LABELxSTMTNO)) + 0
                  + 4 * (0),
              numberRHS);
  }
  // LOCATION_LINK(STMTNO) = LASTLABEL(INDEXNEST); (3334)
  {
    descriptor_t *bitRHS
        = getBIT (16, mLASTLABEL + 2 * COREHALFWORD (mINDEXNEST));
    putBIT (16,
            getFIXED (mLAB_LOC)
                + 8 * (COREHALFWORD (mGENERATExSET_LABELxSTMTNO)) + 6
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // LASTLABEL(INDEXNEST) = STMTNO; (3335)
  {
    descriptor_t *bitRHS = getBIT (16, mGENERATExSET_LABELxSTMTNO);
    putBIT (16, mLASTLABEL + 2 * (COREHALFWORD (mINDEXNEST)), bitRHS);
    bitRHS->inUse = 0;
  }
  // IF LOCATION_ST#(STMTNO) = 0 THEN (3336)
  if (1
      & (xEQ (COREHALFWORD (getFIXED (mLAB_LOC)
                            + 8 * (COREHALFWORD (mGENERATExSET_LABELxSTMTNO))
                            + 4 + 2 * (0)),
              0)))
    // LOCATION_ST#(STMTNO) = LINE#; (3337)
    {
      int32_t numberRHS = (int32_t)(getFIXED (mLINEp));
      putBIT (16,
              getFIXED (mLAB_LOC)
                  + 8 * (COREHALFWORD (mGENERATExSET_LABELxSTMTNO)) + 4
                  + 2 * (0),
              fixedToBit (16, numberRHS));
    }
  // IF ~FLAG2 THEN (3338)
  if (1 & (xNOT (BYTE0 (mGENERATExSET_LABELxFLAG2))))
    // DO; (3339)
    {
    rs2:;
      // IF ASSEMBLER_CODE THEN (3340)
      if (1 & (bitToFixed (getBIT (1, mASSEMBLER_CODE))))
        // OUTPUT = HEX_LOCCTR||'P#'||STMTNO||' EQU *'; (3341)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              xsCAT (xsCAT (HEX_LOCCTR (0), cToDescriptor (NULL, "P#")),
                     bitToCharacter (getBIT (16, mGENERATExSET_LABELxSTMTNO))),
              cToDescriptor (NULL, " EQU *"));
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
      // CALL EMITC(PLBL, STMTNO); (3342)
      {
        putBITp (16, mEMITCxTYPE, getBIT (8, mPLBL));
        putBITp (16, mEMITCxINST, getBIT (16, mGENERATExSET_LABELxSTMTNO));
        EMITC (0);
      }
    es2:;
    } // End of DO block
  // FLAG1, FLAG2 = FALSE; (3343)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExSET_LABELxFLAG1, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExSET_LABELxFLAG2, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
