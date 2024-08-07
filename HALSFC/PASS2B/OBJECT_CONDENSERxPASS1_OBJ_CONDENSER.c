/*
  File OBJECT_CONDENSERxPASS1_OBJ_CONDENSER.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
OBJECT_CONDENSERxPASS1_OBJ_CONDENSER (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "OBJECT_CONDENSERxPASS1_OBJ_CONDENSER");
  // MAX_CODE_LINE=CODE_LINE; (14638)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mCODE_LINE));
    putFIXED (mMAX_CODE_LINE, numberRHS);
  }
  // CODE_LINE = 0; (14639)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mCODE_LINE, numberRHS);
  }
  // GENERATING, EMITTING = TRUE; (14640)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATING, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mEMITTING, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE GENERATING; (14641)
  while (1 & (bitToFixed (getBIT (1, mGENERATING))))
    {
      // CURRENT_LINE = CODE_LINE; (14642)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mCODE_LINE));
        putFIXED (mOBJECT_CONDENSERxCURRENT_LINE, numberRHS);
      }
      // CALL NEXT_REC(0); (14643)
      {
        putBITp (16, mNEXT_RECxI, fixedToBit (32, (int32_t)(0)));
        NEXT_REC (0);
      }
      // IF LHS = 0 THEN (14644)
      if (1 & (xEQ (COREHALFWORD (mLHS), 0)))
        // CALL UPLOC(2); (14645)
        {
          putBITp (16, mOBJECT_CONDENSERxUPLOCxN,
                   fixedToBit (32, (int32_t)(2)));
          OBJECT_CONDENSERxUPLOC (0);
        }
      // ELSE (14646)
      else
        // IF LHS < 32 THEN (14647)
        if (1 & (xLT (COREHALFWORD (mLHS), 32)))
          // CALL ERRORS(CLASS_BI,506,' '||LHS); (14648)
          {
            putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_BI));
            putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(506)));
            putCHARACTERp (mERRORSxTEXT,
                           xsCAT (cToDescriptor (NULL, " "),
                                  bitToCharacter (getBIT (16, mLHS))));
            ERRORS (0);
          }
        // ELSE (14649)
        else
          // DO CASE LHS-32; (14650)
          {
          rs1s1:
            switch (xsubtract (COREHALFWORD (mLHS), 32))
              {
              case 0:
                // CALL UPLOC(2); (14652)
                {
                  putBITp (16, mOBJECT_CONDENSERxUPLOCxN,
                           fixedToBit (32, (int32_t)(2)));
                  OBJECT_CONDENSERxUPLOC (0);
                }
                break;
              case 1:
                // CALL CONDENSE; (14653)
                OBJECT_CONDENSERxCONDENSE (0);
                break;
              case 2:
                // DO; (14654)
                {
                rs1s1s1:;
                  // CALL UPLOC(4); (14654)
                  {
                    putBITp (16, mOBJECT_CONDENSERxUPLOCxN,
                             fixedToBit (32, (int32_t)(4)));
                    OBJECT_CONDENSERxUPLOC (0);
                  }
                  // CALL SKIP_ADDR; (14655)
                  SKIP_ADDR (0);
                  // CALL SKIP(1); (14656)
                  {
                    putBITp (16, mSKIPxN, fixedToBit (32, (int32_t)(1)));
                    SKIP (0);
                  }
                es1s1s1:;
                } // End of DO block
                break;
              case 3:
                // DELTA = DELTA + RHS; (14658)
                {
                  int32_t numberRHS
                      = (int32_t)(xadd (getFIXED (mOBJECT_CONDENSERxDELTA),
                                        COREHALFWORD (mRHS)));
                  putFIXED (mOBJECT_CONDENSERxDELTA, numberRHS);
                }
                break;
              case 4:
                // CALL VERIFY(SYT_LABEL(RHS)); (14659)
                {
                  putBITp (16, mOBJECT_CONDENSERxVERIFYxLBL,
                           getBIT (16, getFIXED (mSYM_TAB)
                                           + 34 * (COREHALFWORD (mRHS)) + 26
                                           + 2 * (0)));
                  OBJECT_CONDENSERxVERIFY (0);
                }
                break;
              case 5:
                // CALL VERIFY(LABEL_ARRAY(RHS)); (14660)
                {
                  putBITp (16, mOBJECT_CONDENSERxVERIFYxLBL,
                           getBIT (16, getFIXED (mSTMTNUM)
                                           + 2 * (COREHALFWORD (mRHS)) + 0
                                           + 2 * (0)));
                  OBJECT_CONDENSERxVERIFY (0);
                }
                break;
              case 6:
                // DO; (14661)
                {
                rs1s1s2:;
                  // CURRENT_ESDID = RHS; (14661)
                  {
                    descriptor_t *bitRHS = getBIT (16, mRHS);
                    int32_t numberRHS;
                    numberRHS = bitToFixed (bitRHS);
                    putFIXED (mCURRENT_ESDID, numberRHS);
                    bitRHS->inUse = 0;
                  }
                  // IF CURRENT_ESDID = FSIMBASE THEN (14662)
                  if (1
                      & (xEQ (getFIXED (mCURRENT_ESDID),
                              COREHALFWORD (mFSIMBASE))))
                    // CURRENT_ESDID = DATABASE; (14663)
                    {
                      descriptor_t *bitRHS = getBIT (16, mDATABASE);
                      int32_t numberRHS;
                      numberRHS = bitToFixed (bitRHS);
                      putFIXED (mCURRENT_ESDID, numberRHS);
                      bitRHS->inUse = 0;
                    }
                  // CALL NEXT_REC(1); (14664)
                  {
                    putBITp (16, mNEXT_RECxI, fixedToBit (32, (int32_t)(1)));
                    NEXT_REC (0);
                  }
                  // IF TEMP < 0 THEN (14665)
                  if (1 & (xLT (getFIXED (mTEMP), 0)))
                    // DO; (14666)
                    {
                    rs1s1s2s1:;
                      // IF RHS = DATABASE THEN (14667)
                      if (1
                          & (xEQ (COREHALFWORD (mRHS),
                                  COREHALFWORD (mDATABASE))))
                        // DO; (14668)
                        {
                        rs1s1s2s1s1:;
                          // TEMP = TEMP + PROGDELTA; (14669)
                          {
                            int32_t numberRHS = (int32_t)(xadd (
                                getFIXED (mTEMP), COREHALFWORD (mPROGDELTA)));
                            putFIXED (mTEMP, numberRHS);
                          }
                          // CODE(GET_CODE(CODE_LINE-1)) = TEMP; (14670)
                          {
                            int32_t numberRHS = (int32_t)(getFIXED (mTEMP));
                            putFIXED (
                                mCODE
                                    + 4
                                          * ((putFIXED (
                                                  mGET_CODExCTR,
                                                  xsubtract (
                                                      getFIXED (mCODE_LINE),
                                                      1)),
                                              GET_CODE (0))),
                                numberRHS);
                          }
                        es1s1s2s1s1:;
                        } // End of DO block
                      // CURRENT_ADDRESS = TEMP & POSMAX; (14671)
                      {
                        int32_t numberRHS = (int32_t)(xAND (
                            getFIXED (mTEMP), getFIXED (mPOSMAX)));
                        putFIXED (mWORKSEG + 4 * (getFIXED (mCURRENT_ESDID)),
                                  numberRHS);
                      }
                    es1s1s2s1:;
                    } // End of DO block
                es1s1s2:;
                } // End of DO block
                break;
              case 7:
                // DO; (14673)
                {
                rs1s1s3:;
                  // CALL UPLOC(SHL(RHS,2)); (14673)
                  {
                    putBITp (16, mOBJECT_CONDENSERxUPLOCxN,
                             fixedToBit (
                                 32, (int32_t)(SHL (COREHALFWORD (mRHS), 2))));
                    OBJECT_CONDENSERxUPLOC (0);
                  }
                  // CALL SKIP(RHS); (14674)
                  {
                    putBITp (16, mSKIPxN, getBIT (16, mRHS));
                    SKIP (0);
                  }
                es1s1s3:;
                } // End of DO block
                break;
              case 8:
              // ADCON_PROC: (14676)
              ADCON_PROC:
                {
                rs1s1s4:;
                  // CALL UPLOC(4); (14677)
                  {
                    putBITp (16, mOBJECT_CONDENSERxUPLOCxN,
                             fixedToBit (32, (int32_t)(4)));
                    OBJECT_CONDENSERxUPLOC (0);
                  }
                  // IF RHS = DATABASE THEN (14678)
                  if (1
                      & (xEQ (COREHALFWORD (mRHS), COREHALFWORD (mDATABASE))))
                    // DO; (14679)
                    {
                    rs1s1s4s1:;
                      // CALL NEXT_REC; (14680)
                      NEXT_REC (0);
                      // IF RLD_FLAG THEN (14681)
                      if (1
                          & (bitToFixed (
                              getBIT (1, mOBJECT_CONDENSERxRLD_FLAG))))
                        // LHS = LHS - PROGDELTA; (14682)
                        {
                          int32_t numberRHS = (int32_t)(xsubtract (
                              COREHALFWORD (mLHS), COREHALFWORD (mPROGDELTA)));
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (16, mLHS, bitRHS);
                          bitRHS->inUse = 0;
                        }
                      // ELSE (14683)
                      else
                        // LHS = LHS + PROGDELTA; (14684)
                        {
                          int32_t numberRHS = (int32_t)(xadd (
                              COREHALFWORD (mLHS), COREHALFWORD (mPROGDELTA)));
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (16, mLHS, bitRHS);
                          bitRHS->inUse = 0;
                        }
                      // CODE(GET_CODE(CODE_LINE-1)) = SHL(LHS,16) + (RHS&
                      // 65535); (14685)
                      {
                        int32_t numberRHS = (int32_t)(xadd (
                            SHL (COREHALFWORD (mLHS), 16),
                            xAND (COREHALFWORD (mRHS), 65535)));
                        putFIXED (
                            mCODE
                                + 4
                                      * ((putFIXED (
                                              mGET_CODExCTR,
                                              xsubtract (getFIXED (mCODE_LINE),
                                                         1)),
                                          GET_CODE (0))),
                            numberRHS);
                      }
                    es1s1s4s1:;
                    } // End of DO block
                  // ELSE (14686)
                  else
                    // CALL SKIP(1); (14687)
                    {
                      putBITp (16, mSKIPxN, fixedToBit (32, (int32_t)(1)));
                      SKIP (0);
                    }
                es1s1s4:;
                } // End of DO block
                break;
              case 9:
                // GO TO HADCON_PROC; (14689)
                goto HADCON_PROC;
                break;
              case 10:
                // GO TO ADCON_PROC; (14690)
                goto ADCON_PROC;
                break;
              case 11:
                // RLD_FLAG = SHR(RHS, 15); (14691)
                {
                  int32_t numberRHS = (int32_t)(SHR (COREHALFWORD (mRHS), 15));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (1, mOBJECT_CONDENSERxRLD_FLAG, bitRHS);
                  bitRHS->inUse = 0;
                }
                break;
              case 12:
                // LAST_SMRK_PRCSD = RHS; (14692)
                {
                  descriptor_t *bitRHS = getBIT (16, mRHS);
                  putBIT (16, mOBJECT_CONDENSERxLAST_SMRK_PRCSD, bitRHS);
                  bitRHS->inUse = 0;
                }
                break;
              case 13:
                // DELTA = MAXTEMP(RHS); (14693)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      mMAXTEMP + 4 * COREHALFWORD (mRHS)));
                  putFIXED (mOBJECT_CONDENSERxDELTA, numberRHS);
                }
                break;
              case 14:
                // DO; (14694)
                {
                rs1s1s5:;
                  // CALL UPLOC(RHS); (14694)
                  {
                    putBITp (16, mOBJECT_CONDENSERxUPLOCxN, getBIT (16, mRHS));
                    OBJECT_CONDENSERxUPLOC (0);
                  }
                  // CALL SKIP(SHR(RHS+3,2)); (14695)
                  {
                    putBITp (16, mSKIPxN,
                             fixedToBit (
                                 32, (int32_t)(SHR (
                                         xadd (COREHALFWORD (mRHS), 3), 2))));
                    SKIP (0);
                  }
                es1s1s5:;
                } // End of DO block
                break;
              case 15:
                // DO; (14697)
                {
                rs1s1s6:;
                  // GENERATING = FALSE; (14697)
                  {
                    int32_t numberRHS = (int32_t)(0);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (1, mGENERATING, bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s1s6:;
                } // End of DO block
                break;
              case 16:
                // CALL VERIFY(RHS); (14699)
                {
                  putBITp (16, mOBJECT_CONDENSERxVERIFYxLBL,
                           getBIT (16, mRHS));
                  OBJECT_CONDENSERxVERIFY (0);
                }
                break;
              case 17:
                  // ; (14700)
                  ;
                break;
              case 18:
                // DO; (14701)
                {
                rs1s1s7:;
                  // CALL SHIFT_CONDENSE; (14701)
                  OBJECT_CONDENSERxSHIFT_CONDENSE (0);
                es1s1s7:;
                } // End of DO block
                break;
              case 19:
                // CURRENT_ADDRESS = CURRENT_ADDRESS + RHS & (~RHS); (14703)
                {
                  int32_t numberRHS = (int32_t)(xAND (
                      xadd (
                          getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)),
                          COREHALFWORD (mRHS)),
                      xNOT (COREHALFWORD (mRHS))));
                  putFIXED (mWORKSEG + 4 * (getFIXED (mCURRENT_ESDID)),
                            numberRHS);
                }
                break;
              case 20:
                // CALL SKIP_ADDR; (14704)
                SKIP_ADDR (0);
                break;
              case 21:
              // HADCON_PROC: (14705)
              HADCON_PROC:
                {
                rs1s1s8:;
                  // CALL UPLOC(2); (14706)
                  {
                    putBITp (16, mOBJECT_CONDENSERxUPLOCxN,
                             fixedToBit (32, (int32_t)(2)));
                    OBJECT_CONDENSERxUPLOC (0);
                  }
                  // IF RHS = DATABASE THEN (14707)
                  if (1
                      & (xEQ (COREHALFWORD (mRHS), COREHALFWORD (mDATABASE))))
                    // DO; (14708)
                    {
                    rs1s1s8s1:;
                      // CALL NEXT_REC; (14709)
                      NEXT_REC (0);
                      // IF RLD_FLAG THEN (14710)
                      if (1
                          & (bitToFixed (
                              getBIT (1, mOBJECT_CONDENSERxRLD_FLAG))))
                        // TEMP = TEMP - PROGDELTA; (14711)
                        {
                          int32_t numberRHS = (int32_t)(xsubtract (
                              getFIXED (mTEMP), COREHALFWORD (mPROGDELTA)));
                          putFIXED (mTEMP, numberRHS);
                        }
                      // ELSE (14712)
                      else
                        // TEMP = TEMP + PROGDELTA; (14713)
                        {
                          int32_t numberRHS = (int32_t)(xadd (
                              getFIXED (mTEMP), COREHALFWORD (mPROGDELTA)));
                          putFIXED (mTEMP, numberRHS);
                        }
                      // CODE(GET_CODE(CODE_LINE-1)) = TEMP; (14714)
                      {
                        int32_t numberRHS = (int32_t)(getFIXED (mTEMP));
                        putFIXED (
                            mCODE
                                + 4
                                      * ((putFIXED (
                                              mGET_CODExCTR,
                                              xsubtract (getFIXED (mCODE_LINE),
                                                         1)),
                                          GET_CODE (0))),
                            numberRHS);
                      }
                    es1s1s8s1:;
                    } // End of DO block
                  // ELSE (14715)
                  else
                    // CALL SKIP(1); (14716)
                    {
                      putBITp (16, mSKIPxN, fixedToBit (32, (int32_t)(1)));
                      SKIP (0);
                    }
                es1s1s8:;
                } // End of DO block
                break;
              case 22:
                // LOOKING_AHEAD = RHS; (14718)
                {
                  descriptor_t *bitRHS = getBIT (16, mRHS);
                  putBIT (1, mOBJECT_CONDENSERxLOOKING_AHEAD, bitRHS);
                  bitRHS->inUse = 0;
                }
                break;
              case 23:
                // GOTO ADCON_PROC; (14719)
                goto ADCON_PROC;
                break;
              case 24:
                  // ; (14720)
                  ;
                break;
              case 25:
                  // ; (14721)
                  ;
                break;
              case 26:
                // DO; (14722)
                {
                rs1s1s9:;
                  // CALL LABEL_UPDATE(RHS); (14722)
                  {
                    putBITp (16, mOBJECT_CONDENSERxLABEL_UPDATExLEN,
                             getBIT (16, mRHS));
                    OBJECT_CONDENSERxLABEL_UPDATE (0);
                  }
                  // CALL NEXT_REC; (14723)
                  NEXT_REC (0);
                  // CODE_LINE = TEMP; (14724)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (mTEMP));
                    putFIXED (mCODE_LINE, numberRHS);
                  }
                es1s1s9:;
                } // End of DO block
                break;
              case 27:
                // DO; (14726)
                {
                rs1s1s10:;
                  // TEMP1=CODE_LINE; (14726)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (mCODE_LINE));
                    putFIXED (mOBJECT_CONDENSERxTEMP1, numberRHS);
                  }
                  // CODE_LINE=MAX_CODE_LINE; (14727)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (mMAX_CODE_LINE));
                    putFIXED (mCODE_LINE, numberRHS);
                  }
                es1s1s10:;
                } // End of DO block
                break;
              case 28:
                // DO; (14729)
                {
                rs1s1s11:;
                  // MAX_CODE_LINE=CODE_LINE; (14729)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (mCODE_LINE));
                    putFIXED (mMAX_CODE_LINE, numberRHS);
                  }
                  // CODE_LINE=TEMP1+RHS-1; (14730)
                  {
                    int32_t numberRHS = (int32_t)(xsubtract (
                        xadd (getFIXED (mOBJECT_CONDENSERxTEMP1),
                              COREHALFWORD (mRHS)),
                        1));
                    putFIXED (mCODE_LINE, numberRHS);
                  }
                es1s1s11:;
                } // End of DO block
                break;
              case 29:
                // DO; (14732)
                {
                rs1s1s12:;
                  // SPLIT_DELTA = RHS; (14732)
                  {
                    descriptor_t *bitRHS = getBIT (16, mRHS);
                    putBIT (16, mSPLIT_DELTA, bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s1s12:;
                } // End of DO block
                break;
              case 30:
                // DO; (14734)
                {
                rs1s1s13:;
                  // CURRENT_ESDID = RHS; (14734)
                  {
                    descriptor_t *bitRHS = getBIT (16, mRHS);
                    int32_t numberRHS;
                    numberRHS = bitToFixed (bitRHS);
                    putFIXED (mCURRENT_ESDID, numberRHS);
                    bitRHS->inUse = 0;
                  }
                  // CALL NEXT_REC(1); (14735)
                  {
                    putBITp (16, mNEXT_RECxI, fixedToBit (32, (int32_t)(1)));
                    NEXT_REC (0);
                  }
                  // CURRENT_ADDRESS = TEMP& POSMAX; (14736)
                  {
                    int32_t numberRHS = (int32_t)(xAND (getFIXED (mTEMP),
                                                        getFIXED (mPOSMAX)));
                    putFIXED (mWORKSEG + 4 * (getFIXED (mCURRENT_ESDID)),
                              numberRHS);
                  }
                  // CODE(GET_CODE(CODE_LINE-2))=SHL(CSECT,16)|CURRENT_ESDID;
                  // (14737)
                  {
                    int32_t numberRHS = (int32_t)(xOR (
                        SHL (BYTE0 (mCSECT), 16), getFIXED (mCURRENT_ESDID)));
                    putFIXED (
                        mCODE
                            + 4
                                  * ((putFIXED (mGET_CODExCTR,
                                                xsubtract (
                                                    getFIXED (mCODE_LINE), 2)),
                                      GET_CODE (0))),
                        numberRHS);
                  }
                es1s1s13:;
                } // End of DO block
                break;
              case 31:
                  // ; (14739)
                  ;
                break;
              case 32:
                // DO; (14740)
                {
                rs1s1s14:;
                  // CALL NEXT_REC; (14740)
                  NEXT_REC (0);
                  // PUSHED_LOCCTR(CURRENT_ESDID) = CURRENT_ADDRESS; (14741)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (
                        mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)));
                    putFIXED (mPUSHED_LOCCTR + 4 * (getFIXED (mCURRENT_ESDID)),
                              numberRHS);
                  }
                  // CURRENT_ADDRESS = TEMP &  16777215; (14742)
                  {
                    int32_t numberRHS
                        = (int32_t)(xAND (getFIXED (mTEMP), 16777215));
                    putFIXED (mWORKSEG + 4 * (getFIXED (mCURRENT_ESDID)),
                              numberRHS);
                  }
                es1s1s14:;
                } // End of DO block
                break;
              case 33:
                // CURRENT_ADDRESS = PUSHED_LOCCTR(CURRENT_ESDID); (14744)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      mPUSHED_LOCCTR + 4 * getFIXED (mCURRENT_ESDID)));
                  putFIXED (mWORKSEG + 4 * (getFIXED (mCURRENT_ESDID)),
                            numberRHS);
                }
                break;
              }
          } // End of DO CASE block
    }       // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
