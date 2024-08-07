/*
  File HALMAT_INIT_CONST.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
HALMAT_INIT_CONST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "HALMAT_INIT_CONST");
  // IF IC_FOUND = 0 THEN (9053)
  if (1 & (xEQ (COREHALFWORD (mIC_FOUND), 0)))
    // RETURN; (9054)
    {
      reentryGuard = 0;
      return 0;
    }
  // IF IC_FOUND > 1 THEN (9055)
  if (1 & (xGT (COREHALFWORD (mIC_FOUND), 1)))
    // DO; (9056)
    {
    rs1:;
      // ICQ = IC_PTR2; (9057)
      {
        descriptor_t *bitRHS = getBIT (16, mIC_PTR2);
        int32_t numberRHS;
        numberRHS = bitToFixed (bitRHS);
        putFIXED (mICQ, numberRHS);
        bitRHS->inUse = 0;
      }
      // IC_FOUND = IC_FOUND - 2; (9058)
      {
        int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mIC_FOUND), 2));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mIC_FOUND, bitRHS);
        bitRHS->inUse = 0;
      }
      // IC_LINE = INX(IC_PTR2); (9059)
      {
        descriptor_t *bitRHS = getBIT (16, mINX + 2 * COREHALFWORD (mIC_PTR2));
        int32_t numberRHS;
        numberRHS = bitToFixed (bitRHS);
        putFIXED (mIC_LINE, numberRHS);
        bitRHS->inUse = 0;
      }
      // PTR_TOP = IC_PTR2 - 1; (9060)
      {
        int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mIC_PTR2), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPTR_TOP, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (9061)
  else
    // ICQ = IC_PTR1; (9062)
    {
      descriptor_t *bitRHS = getBIT (16, mIC_PTR1);
      int32_t numberRHS;
      numberRHS = bitToFixed (bitRHS);
      putFIXED (mICQ, numberRHS);
      bitRHS->inUse = 0;
    }
  // IF DO_INIT THEN (9063)
  if (1 & (bitToFixed (getBIT (1, mDO_INIT))))
    // DO_INIT=FALSE; (9064)
    {
      int32_t numberRHS = (int32_t)(0);
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (1, mDO_INIT, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (9065)
  else
    // RETURN; (9066)
    {
      reentryGuard = 0;
      return 0;
    }
  // DO CASE HOW_TO_INIT_ARGS(LOC_P(ICQ)); (9067)
  {
  rs2:
    switch ((putFIXED (mHOW_TO_INIT_ARGSxNA,
                       COREHALFWORD (mLOC_P + 2 * getFIXED (mICQ))),
             HOW_TO_INIT_ARGS (0)))
      {
      case 0:
        // DO; (9069)
        {
        rs2s1:;
          // IF PSEUDO_TYPE(ICQ)=0 THEN (9069)
          if (1 & (xEQ (BYTE0 (mPSEUDO_TYPE + 1 * getFIXED (mICQ)), 0)))
            // CALL ERROR(CLASS_DI,5,VAR(MP)); (9070)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DI));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(5)));
              putCHARACTERp (mERRORxTEXT,
                             getCHARACTER (mVAR + 4 * getFIXED (mMP)));
              ERROR (0);
            }
          // CALL ICQ_OUTPUT; (9071)
          ICQ_OUTPUT (0);
        es2s1:;
        } // End of DO block
        break;
      case 1:
        // IF PSEUDO_TYPE(ICQ)~=0 THEN (9073)
        if (1 & (xNEQ (BYTE0 (mPSEUDO_TYPE + 1 * getFIXED (mICQ)), 0)))
          {
          rs2s2:;
            // IF ~MULTI_VALUED THEN (9074)
            if (1 & (xNOT (bitToFixed (HALMAT_INIT_CONSTxMULTI_VALUED (0)))))
              // CALL ERROR(CLASS_DI,4,VAR(MP)); (9075)
              {
                putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DI));
                putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(4)));
                putCHARACTERp (mERRORxTEXT,
                               getCHARACTER (mVAR + 4 * getFIXED (mMP)));
                ERROR (0);
              }
            // CALL ICQ_OUTPUT; (9076)
            ICQ_OUTPUT (0);
          es2s2:;
          } // End of DO block
        else
          {
          rs2s3:;
            // I=GET_ICQ(INX(ICQ)+1); (9079)
            {
              int32_t numberRHS = (int32_t)((
                  putFIXED (
                      mGET_ICQxPTR,
                      xadd (COREHALFWORD (mINX + 2 * getFIXED (mICQ)), 1)),
                  GET_ICQ (0)));
              putFIXED (mHALMAT_INIT_CONSTxI, numberRHS);
            }
            // DO WHILE IC_FORM(I)~=2; (9080)
            while (1
                   & (xNEQ (
                       BYTE0 (mIC_FORM + 1 * getFIXED (mHALMAT_INIT_CONSTxI)),
                       2)))
              {
                // INX(ICQ)=INX(ICQ)+1; (9081)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (mINX + 2 * getFIXED (mICQ)), 1));
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (16, mINX + 2 * (getFIXED (mICQ)), bitRHS);
                  bitRHS->inUse = 0;
                }
                // I=GET_ICQ(INX(ICQ)+1); (9082)
                {
                  int32_t numberRHS = (int32_t)((
                      putFIXED (
                          mGET_ICQxPTR,
                          xadd (COREHALFWORD (mINX + 2 * getFIXED (mICQ)), 1)),
                      GET_ICQ (0)));
                  putFIXED (mHALMAT_INIT_CONSTxI, numberRHS);
                }
              } // End of DO WHILE block
            // IF MULTI_VALUED > 0 THEN (9083)
            if (1 & (xGT (bitToFixed (HALMAT_INIT_CONSTxMULTI_VALUED (0)), 0)))
              // GO TO NON_EVALUABLE; (9084)
              goto NON_EVALUABLE;
            // IF (SYT_FLAGS(ID_LOC)&CONSTANT_FLAG)~=0 THEN (9085)
            if (1
                & (xNEQ (
                    xAND (getFIXED (getFIXED (mSYM_TAB)
                                    + 34 * (getFIXED (mID_LOC)) + 8 + 4 * (0)),
                          4096),
                    0)))
              // DO; (9086)
              {
              rs2s3s2:;
                // IF IC_LEN(I)~=XLIT THEN (9087)
                if (1
                    & (xNEQ (
                        COREHALFWORD (mIC_LEN
                                      + 2 * getFIXED (mHALMAT_INIT_CONSTxI)),
                        BYTE0 (mXLIT))))
                  // GO TO NON_EVALUABLE; (9088)
                  goto NON_EVALUABLE;
                // CALL ICQ_CHECK_TYPE(I); (9089)
                {
                  putBITp (16, mICQ_CHECK_TYPExJ,
                           fixedToBit (32, (int32_t)(getFIXED (
                                               mHALMAT_INIT_CONSTxI))));
                  ICQ_CHECK_TYPE (0);
                }
                // CONSTLIT = GET_LITERAL(IC_LOC(I)); (9090)
                {
                  int32_t numberRHS = (int32_t)((
                      putFIXED (
                          mGET_LITERALxPTR,
                          COREHALFWORD (
                              mIC_LOC + 2 * getFIXED (mHALMAT_INIT_CONSTxI))),
                      GET_LITERAL (0)));
                  putFIXED (mHALMAT_INIT_CONSTxCONSTLIT, numberRHS);
                }
                // IF SYT_TYPE(ID_LOC) = INT_TYPE THEN (9091)
                if (1
                    & (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                                   + 34 * (getFIXED (mID_LOC)) + 32 + 1 * (0)),
                            6)))
                  // IF ROUND_SCALAR(IC_LOC(I)) THEN (9092)
                  if (1
                      & ((putFIXED (
                              mHALMAT_INIT_CONSTxROUND_SCALARxPTR,
                              COREHALFWORD (
                                  mIC_LOC
                                  + 2 * getFIXED (mHALMAT_INIT_CONSTxI))),
                          HALMAT_INIT_CONSTxROUND_SCALAR (0))))
                    // DO; (9093)
                    {
                    rs2s3s2s1:;
                      // IF IC_TYPE(I) = SCALAR_TYPE THEN (9094)
                      if (1
                          & (xEQ (
                              BYTE0 (mIC_TYPE
                                     + 1 * getFIXED (mHALMAT_INIT_CONSTxI)),
                              5)))
                        // IC_LOC(I) = SAVE_LITERAL(1,DW_AD); (9095)
                        {
                          int32_t numberRHS = (int32_t)((
                              putBITp (16, mSAVE_LITERALxTYPE,
                                       fixedToBit (32, (int32_t)(1))),
                              putFIXED (mSAVE_LITERALxVAL, getFIXED (mDW_AD)),
                              SAVE_LITERAL (0)));
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (16,
                                  mIC_LOC
                                      + 2 * (getFIXED (mHALMAT_INIT_CONSTxI)),
                                  bitRHS);
                          bitRHS->inUse = 0;
                        }
                    es2s3s2s1:;
                    } // End of DO block
                  // ELSE (9096)
                  else
                    // CALL ERRORS(CLASS_DI,17); (9097)
                    {
                      putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_DI));
                      putBITp (16, mERRORSxNUM,
                               fixedToBit (32, (int32_t)(17)));
                      ERRORS (0);
                    }
                // IF (SYT_TYPE(ID_LOC) = CHAR_TYPE) &   (LIT1(CONSTLIT) = 0)
                // THEN (9098)
                if (1
                    & (xAND (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                                         + 34 * (getFIXED (mID_LOC)) + 32
                                         + 1 * (0)),
                                  2),
                             xEQ (getFIXED (
                                      getFIXED (mLIT_PG) + 1560 * (0) + 0
                                      + 4
                                            * (getFIXED (
                                                mHALMAT_INIT_CONSTxCONSTLIT))),
                                  0))))
                  // DO; (9099)
                  {
                  rs2s3s2s2:;
                    // TEMP = STRING(LIT2(CONSTLIT)); (9100)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = getCHARACTER (
                          getFIXED (mLIT_PG) + 1560 * (0) + 520
                          + 4 * (getFIXED (mHALMAT_INIT_CONSTxCONSTLIT)));
                      putCHARACTER (mHALMAT_INIT_CONSTxTEMP, stringRHS);
                      stringRHS->inUse = 0;
                    }
                    // IF (LENGTH(TEMP) > VAR_LENGTH(ID_LOC))  THEN (9101)
                    if (1
                        & (xGT (
                            LENGTH (getCHARACTER (mHALMAT_INIT_CONSTxTEMP)),
                            COREHALFWORD (getFIXED (mSYM_TAB)
                                          + 34 * (getFIXED (mID_LOC)) + 18
                                          + 2 * (0)))))
                      // DO; (9102)
                      {
                      rs2s3s2s2s1:;
                        // CALL ERROR(CLASS_DI,18,SYT_NAME(ID_LOC)); (9103)
                        {
                          putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DI));
                          putBITp (8, mERRORxNUM,
                                   fixedToBit (32, (int32_t)(18)));
                          putCHARACTERp (
                              mERRORxTEXT,
                              getCHARACTER (getFIXED (mSYM_TAB)
                                            + 34 * (getFIXED (mID_LOC)) + 0
                                            + 4 * (0)));
                          ERROR (0);
                        }
                        // TEMP = SUBSTR(TEMP,0,VAR_LENGTH(ID_LOC)); (9104)
                        {
                          descriptor_t *stringRHS;
                          stringRHS = SUBSTR (
                              getCHARACTER (mHALMAT_INIT_CONSTxTEMP), 0,
                              COREHALFWORD (getFIXED (mSYM_TAB)
                                            + 34 * (getFIXED (mID_LOC)) + 18
                                            + 2 * (0)));
                          putCHARACTER (mHALMAT_INIT_CONSTxTEMP, stringRHS);
                          stringRHS->inUse = 0;
                        }
                        // SYT_PTR(ID_LOC) = -SAVE_LITERAL(0,TEMP); (9105)
                        {
                          int32_t numberRHS = (int32_t)(xminus (
                              (putBITp (16, mSAVE_LITERALxTYPE,
                                        fixedToBit (32, (int32_t)(0))),
                               putFIXED (mSAVE_LITERALxVAL,
                                         getFIXED (mHALMAT_INIT_CONSTxTEMP)),
                               SAVE_LITERAL (0))));
                          putBIT (16,
                                  getFIXED (mSYM_TAB)
                                      + 34 * (getFIXED (mID_LOC)) + 22
                                      + 2 * (0),
                                  fixedToBit (16, numberRHS));
                        }
                      es2s3s2s2s1:;
                      } // End of DO block
                    // ELSE (9106)
                    else
                      // SYT_PTR(ID_LOC)=-IC_LOC(I); (9107)
                      {
                        int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (
                            mIC_LOC + 2 * getFIXED (mHALMAT_INIT_CONSTxI))));
                        putBIT (16,
                                getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC))
                                    + 22 + 2 * (0),
                                fixedToBit (16, numberRHS));
                      }
                  es2s3s2s2:;
                  } // End of DO block
                // ELSE (9108)
                else
                  // SYT_PTR(ID_LOC)=-IC_LOC(I); (9109)
                  {
                    int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (
                        mIC_LOC + 2 * getFIXED (mHALMAT_INIT_CONSTxI))));
                    putBIT (16,
                            getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC))
                                + 22 + 2 * (0),
                            fixedToBit (16, numberRHS));
                  }
              es2s3s2:;
              } // End of DO block
            // ELSE (9110)
            else
              // DO; (9111)
              {
              rs2s3s3:;
              // NON_EVALUABLE: (9112)
              NON_EVALUABLE:
                // CALL HALMAT_POP(ICQ_CHECK_TYPE(I,1),2,0,IC_TYPE(I)); (9113)
                {
                  putBITp (
                      16, mHALMAT_POPxPOPCODE,
                      (putBITp (16, mICQ_CHECK_TYPExJ,
                                fixedToBit (32, (int32_t)(getFIXED (
                                                    mHALMAT_INIT_CONSTxI)))),
                       putBITp (1, mICQ_CHECK_TYPExK,
                                fixedToBit (32, (int32_t)(1))),
                       ICQ_CHECK_TYPE (0)));
                  putBITp (8, mHALMAT_POPxPIPp, fixedToBit (32, (int32_t)(2)));
                  putBITp (8, mHALMAT_POPxCOPT, fixedToBit (32, (int32_t)(0)));
                  putBITp (
                      8, mHALMAT_POPxTAG,
                      getBIT (8,
                              mIC_TYPE + 1 * getFIXED (mHALMAT_INIT_CONSTxI)));
                  HALMAT_POP (0);
                }
                // CALL HALMAT_PIP(ID_LOC,XSYT,0,0); (9114)
                {
                  putBITp (16, mHALMAT_PIPxOPERAND,
                           fixedToBit (32, (int32_t)(getFIXED (mID_LOC))));
                  putBITp (8, mHALMAT_PIPxQUAL, getBIT (8, mXSYT));
                  putBITp (8, mHALMAT_PIPxTAG1, fixedToBit (32, (int32_t)(0)));
                  putBITp (8, mHALMAT_PIPxTAG2, fixedToBit (32, (int32_t)(0)));
                  HALMAT_PIP (0);
                }
                // CALL HALMAT_PIP(IC_LOC(I),IC_LEN(I),0,0); (9115)
                {
                  putBITp (
                      16, mHALMAT_PIPxOPERAND,
                      getBIT (16,
                              mIC_LOC + 2 * getFIXED (mHALMAT_INIT_CONSTxI)));
                  putBITp (
                      8, mHALMAT_PIPxQUAL,
                      getBIT (16,
                              mIC_LEN + 2 * getFIXED (mHALMAT_INIT_CONSTxI)));
                  putBITp (8, mHALMAT_PIPxTAG1, fixedToBit (32, (int32_t)(0)));
                  putBITp (8, mHALMAT_PIPxTAG2, fixedToBit (32, (int32_t)(0)));
                  HALMAT_PIP (0);
                }
                // CALL ICQ_ARRAYNESS_OUTPUT; (9116)
                ICQ_ARRAYNESS_OUTPUT (0);
              es2s3s3:;
              } // End of DO block
          es2s3:;
          } // End of DO block
        break;
      case 2:
        // DO; (9118)
        {
        rs2s4:;
          // CALL ICQ_OUTPUT; (9118)
          ICQ_OUTPUT (0);
          // IF PSEUDO_TYPE(ICQ)=0 THEN (9119)
          if (1 & (xEQ (BYTE0 (mPSEUDO_TYPE + 1 * getFIXED (mICQ)), 0)))
            // CALL ICQ_ARRAYNESS_OUTPUT; (9120)
            ICQ_ARRAYNESS_OUTPUT (0);
        es2s4:;
        } // End of DO block
        break;
      case 3:
        // DO; (9122)
        {
        rs2s5:;
          // IF PSEUDO_TYPE(ICQ)~=0 THEN (9122)
          if (1 & (xNEQ (BYTE0 (mPSEUDO_TYPE + 1 * getFIXED (mICQ)), 0)))
            // CALL ERROR(CLASS_DI,4,VAR(MP)); (9123)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DI));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(4)));
              putCHARACTERp (mERRORxTEXT,
                             getCHARACTER (mVAR + 4 * getFIXED (mMP)));
              ERROR (0);
            }
          // CALL ICQ_OUTPUT; (9124)
          ICQ_OUTPUT (0);
        es2s5:;
        } // End of DO block
        break;
      case 4:
        // DO; (9126)
        {
        rs2s6:;
          // CALL ERROR(CLASS_DI,10,VAR(MP)); (9126)
          {
            putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DI));
            putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(10)));
            putCHARACTERp (mERRORxTEXT,
                           getCHARACTER (mVAR + 4 * getFIXED (mMP)));
            ERROR (0);
          }
          // CALL ICQ_OUTPUT; (9127)
          ICQ_OUTPUT (0);
        es2s6:;
        } // End of DO block
        break;
      }
  } // End of DO CASE block
  // INIT_EMISSION=TRUE; (9128)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mINIT_EMISSION, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
