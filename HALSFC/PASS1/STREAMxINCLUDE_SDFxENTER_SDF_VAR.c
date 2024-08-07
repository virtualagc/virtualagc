/*
  File STREAMxINCLUDE_SDFxENTER_SDF_VAR.c generated by XCOM-I, 2024-08-08
  04:31:11.
*/

#include "runtimeC.h"

int32_t
STREAMxINCLUDE_SDFxENTER_SDF_VAR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "STREAMxINCLUDE_SDFxENTER_SDF_VAR");
  // IF DUPLICATE_NAME(BCD) THEN (3681)
  if (1
      & (bitToFixed ((putCHARACTERp (mSTREAMxINCLUDE_SDFxDUPLICATE_NAMExNAME,
                                     getCHARACTER (mBCD)),
                      STREAMxINCLUDE_SDFxDUPLICATE_NAME (0)))))
    // DO; (3682)
    {
    rs1:;
      // CALL ERROR(CLASS_PM, 1, BCD); (3683)
      {
        putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_PM));
        putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(1)));
        putCHARACTERp (mERRORxTEXT, getCHARACTER (mBCD));
        ERROR (0);
      }
      // RETURN; (3684)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
  // ID_LOC = ENTER(BCD, CLASS); (3685)
  {
    int32_t numberRHS = (int32_t)((
        putCHARACTERp (mENTERxNAME, getCHARACTER (mBCD)),
        putFIXED (mENTERxCLASS,
                  COREHALFWORD (mSTREAMxINCLUDE_SDFxENTER_SDF_VARxCLASS)),
        ENTER (0)));
    putFIXED (mID_LOC, numberRHS);
  }
  // IF CONTROL( 3) THEN (3686)
  if (1 & (bitToFixed (getBIT (1, mCONTROL + 1 * 3))))
    // OUTPUT = 'ENTER_SDF_VAR: ID_LOC = ' || ID_LOC || ', NAME = ' || BCD ||
    // ', CLASS = ' || CLASS; (3687)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          xsCAT (xsCAT (xsCAT (xsCAT (cToDescriptor (
                                          NULL, "ENTER_SDF_VAR: ID_LOC = "),
                                      fixedToCharacter (getFIXED (mID_LOC))),
                               cToDescriptor (NULL, ", NAME = ")),
                        getCHARACTER (mBCD)),
                 cToDescriptor (NULL, ", CLASS = ")),
          bitToCharacter (
              getBIT (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxCLASS)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // CALL SET_SYT_FLAGS(ID_LOC); (3688)
  {
    putBITp (16, mSTREAMxINCLUDE_SDFxSET_SYT_FLAGSxNDX,
             fixedToBit (32, (int32_t)(getFIXED (mID_LOC))));
    STREAMxINCLUDE_SDFxSET_SYT_FLAGS (0);
  }
  // CALL SET_TYPE_AND_LEN(ID_LOC); (3689)
  {
    putBITp (16, mSTREAMxINCLUDE_SDFxSET_TYPE_AND_LENxNDX,
             fixedToBit (32, (int32_t)(getFIXED (mID_LOC))));
    STREAMxINCLUDE_SDFxSET_TYPE_AND_LEN (0);
  }
  // SYT_ADDR(ID_LOC) = SDF_SYMB_ADDR; (3690)
  {
    int32_t numberRHS = (int32_t)(xAND (
        getFIXED (getFIXED (mSTREAMxINCLUDE_SDFxSDF_F) + 4 * 3), 16777215));
    putFIXED (getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 4 + 4 * (0),
              numberRHS);
  }
  // SYT_LOCK#(ID_LOC) = SDF_SYMB_LOCK#; (3691)
  {
    descriptor_t *bitRHS
        = getBIT (8, getFIXED (mSTREAMxINCLUDE_SDFxSDF_B) + 1 * 20);
    putBIT (8, getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 31 + 1 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // IF SDF_SYMB_ARRAY_OFF = 0 THEN (3692)
  if (1 & (xEQ (BYTE0 (getFIXED (mSTREAMxINCLUDE_SDFxSDF_B) + 1 * 4), 0)))
    // SYT_ARRAY(ID_LOC) = 0; (3693)
    {
      int32_t numberRHS = (int32_t)(0);
      putBIT (16,
              getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 20 + 2 * (0),
              fixedToBit (16, numberRHS));
    }
  // ELSE (3694)
  else
    // IF SYT_TYPE(ID_LOC) = MAJ_STRUC THEN (3695)
    if (1
        & (xEQ (BYTE0 (getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 32
                       + 1 * (0)),
                10)))
      // DO; (3696)
      {
      rs2:;
        // I = SDF_SYMB_ARRAY(0); (3697)
        {
          descriptor_t *bitRHS = getBIT (
              16,
              getFIXED (mSTREAMxINCLUDE_SDFxSDF_H)
                  + 2
                        * xadd (
                            xadd (SHR (BYTE0 (
                                           getFIXED (mSTREAMxINCLUDE_SDFxSDF_B)
                                           + 1 * 4),
                                       1),
                                  1),
                            0));
          putBIT (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI, bitRHS);
          bitRHS->inUse = 0;
        }
        // IF I < 0 THEN (3698)
        if (1 & (xLT (COREHALFWORD (mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI), 0)))
          // SYT_ARRAY(ID_LOC) = -ID_LOC; (3699)
          {
            int32_t numberRHS = (int32_t)(xminus (getFIXED (mID_LOC)));
            putBIT (16,
                    getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 20
                        + 2 * (0),
                    fixedToBit (16, numberRHS));
          }
        // ELSE (3700)
        else
          // IF I = 1 THEN (3701)
          if (1
              & (xEQ (COREHALFWORD (mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI), 1)))
            // SYT_ARRAY(ID_LOC) = 0; (3702)
            {
              int32_t numberRHS = (int32_t)(0);
              putBIT (16,
                      getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 20
                          + 2 * (0),
                      fixedToBit (16, numberRHS));
            }
          // ELSE (3703)
          else
            // SYT_ARRAY(ID_LOC) = I; (3704)
            {
              descriptor_t *bitRHS
                  = getBIT (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI);
              putBIT (16,
                      getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 20
                          + 2 * (0),
                      bitRHS);
              bitRHS->inUse = 0;
            }
      es2:;
      } // End of DO block
    // ELSE (3705)
    else
      // DO; (3706)
      {
      rs3:;
        // N_DIM = SDF_SYMB_NDIM; (3707)
        {
          descriptor_t *bitRHS = getBIT (
              16, getFIXED (mSTREAMxINCLUDE_SDFxSDF_H)
                      + 2
                            * SHR (BYTE0 (getFIXED (mSTREAMxINCLUDE_SDFxSDF_B)
                                          + 1 * 4),
                                   1));
          int32_t numberRHS;
          numberRHS = bitToFixed (bitRHS);
          putFIXED (mN_DIM, numberRHS);
          bitRHS->inUse = 0;
        }
        // DO I = 0 TO N_DIM - 1; (3708)
        {
          int32_t from69, to69, by69;
          from69 = 0;
          to69 = xsubtract (getFIXED (mN_DIM), 1);
          by69 = 1;
          for (putBIT (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI,
                       fixedToBit (16, from69));
               bitToFixed (getBIT (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI))
               <= to69;
               putBIT (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI,
                       fixedToBit (
                           16, bitToFixed (getBIT (
                                   16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI))
                                   + by69)))
            {
              // S_ARRAY(I) = SDF_SYMB_ARRAY(I); (3709)
              {
                descriptor_t *bitRHS = getBIT (
                    16,
                    getFIXED (mSTREAMxINCLUDE_SDFxSDF_H)
                        + 2
                              * xadd (
                                  xadd (SHR (BYTE0 (
                                                 getFIXED (
                                                     mSTREAMxINCLUDE_SDFxSDF_B)
                                                 + 1 * 4),
                                             1),
                                        1),
                                  COREHALFWORD (
                                      mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI)));
                int32_t numberRHS;
                numberRHS = bitToFixed (bitRHS);
                putFIXED (mS_ARRAY
                              + 4
                                    * (COREHALFWORD (
                                        mSTREAMxINCLUDE_SDFxENTER_SDF_VARxI)),
                          numberRHS);
                bitRHS->inUse = 0;
              }
            }
        } // End of DO for-loop block
        // IF S_ARRAY(0) < 0 THEN (3710)
        if (1 & (xLT (getFIXED (mS_ARRAY + 4 * 0), 0)))
          // S_ARRAY(0) = -ID_LOC; (3711)
          {
            int32_t numberRHS = (int32_t)(xminus (getFIXED (mID_LOC)));
            putFIXED (mS_ARRAY + 4 * (0), numberRHS);
          }
        // CALL ENTER_DIMS; (3712)
        ENTER_DIMS (0);
        // SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | ARRAY_FLAG; (3713)
        {
          int32_t numberRHS = (int32_t)(xOR (
              getFIXED (getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 8
                        + 4 * (0)),
              8192));
          putFIXED (getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 8
                        + 4 * (0),
                    numberRHS);
        }
      es3:;
      } // End of DO block
  // IF (SDF_SYMB_FLAGS & SDF_LIT_FLAG) ~= 0 THEN (3714)
  if (1
      & (xNEQ (
          xAND (getFIXED (getFIXED (mSTREAMxINCLUDE_SDFxSDF_F) + 4 * 2), 4096),
          0)))
    // DO; (3715)
    {
    rs4:;
      // TEMP_PTR = SDFPKG_LOC_PTR; (3716)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD) + 4 * 6));
        putFIXED (mSTREAMxINCLUDE_SDFxTEMP_PTR, numberRHS);
      }
      // DO ; (3717)
      {
      rs4s1:;
        // COMMTABL_FULLWORD ( 6 ) = SDF_F ( 5 ) ; (3718)
        {
          int32_t numberRHS = (int32_t)(getFIXED (
              getFIXED (mSTREAMxINCLUDE_SDFxSDF_F) + 4 * 5));
          putFIXED (getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD) + 4 * (6),
                    numberRHS);
        }
        // CALL MONITOR ( 22 , 5 ) ; (3719)
        MONITOR22 (5);
        // COREWORD ( ADDR ( SDF_B ) ) , COREWORD ( ADDR ( SDF_H ) ) , COREWORD
        // ( ADDR ( SDF_F ) ) = COMMTABL_FULLWORD(7) ; (3720)
        {
          int32_t numberRHS = (int32_t)(getFIXED (
              getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD) + 4 * 7));
          COREWORD2 (ADDR ("STREAMxINCLUDE_SDFxSDF_B", 0x80000000, NULL, 0),
                     numberRHS);
          COREWORD2 (ADDR ("STREAMxINCLUDE_SDFxSDF_H", 0x80000000, NULL, 0),
                     numberRHS);
          COREWORD2 (ADDR ("STREAMxINCLUDE_SDFxSDF_F", 0x80000000, NULL, 0),
                     numberRHS);
        }
        // ; (3721)
        ;
      es4s1:;
      } // End of DO block
      // ; (3722)
      ;
      // IF SYT_TYPE(ID_LOC) = CHAR_TYPE THEN (3723)
      if (1
          & (xEQ (BYTE0 (getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 32
                         + 1 * (0)),
                  2)))
        // CALL SAVE_LITERAL(0,MAKESTRING(SDF_B + 1, SDFPKG_LOC_ADDR + 1));
        // (3724)
        {
          putBITp (16, mSAVE_LITERALxTYPE, fixedToBit (32, (int32_t)(0)));
          putFIXED (
              mSAVE_LITERALxVAL,
              xadd (
                  xadd (SHL (xsubtract (xadd (BYTE0 (getFIXED (
                                                  mSTREAMxINCLUDE_SDFxSDF_B)),
                                              1),
                                        1),
                             24),
                        getFIXED (
                            getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD)
                            + 4 * 7)),
                  1));
          SAVE_LITERAL (0);
        }
      // ELSE (3725)
      else
        // CALL SAVE_LITERAL(1, SDFPKG_LOC_ADDR,0,1); (3726)
        {
          putBITp (16, mSAVE_LITERALxTYPE, fixedToBit (32, (int32_t)(1)));
          putFIXED (mSAVE_LITERALxVAL,
                    getFIXED (getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD)
                              + 4 * 7));
          putFIXED (mSAVE_LITERALxSIZE, 0);
          putBITp (1, mSAVE_LITERALxCMPOOL, fixedToBit (32, (int32_t)(1)));
          SAVE_LITERAL (0);
        }
      // SYT_PTR(ID_LOC) = -LIT_TOP; (3727)
      {
        int32_t numberRHS = (int32_t)(xminus (getFIXED (mCOMM + 4 * 2)));
        putBIT (16,
                getFIXED (mSYM_TAB) + 34 * (getFIXED (mID_LOC)) + 22 + 2 * (0),
                fixedToBit (16, numberRHS));
      }
      // DO ; (3728)
      {
      rs4s2:;
        // COMMTABL_FULLWORD ( 6 ) = TEMP_PTR ; (3729)
        {
          int32_t numberRHS
              = (int32_t)(getFIXED (mSTREAMxINCLUDE_SDFxTEMP_PTR));
          putFIXED (getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD) + 4 * (6),
                    numberRHS);
        }
        // CALL MONITOR ( 22 , 5 ) ; (3730)
        MONITOR22 (5);
        // COREWORD ( ADDR ( SDF_B ) ) , COREWORD ( ADDR ( SDF_H ) ) , COREWORD
        // ( ADDR ( SDF_F ) ) = COMMTABL_FULLWORD(7) ; (3731)
        {
          int32_t numberRHS = (int32_t)(getFIXED (
              getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_FULLWORD) + 4 * 7));
          COREWORD2 (ADDR ("STREAMxINCLUDE_SDFxSDF_B", 0x80000000, NULL, 0),
                     numberRHS);
          COREWORD2 (ADDR ("STREAMxINCLUDE_SDFxSDF_H", 0x80000000, NULL, 0),
                     numberRHS);
          COREWORD2 (ADDR ("STREAMxINCLUDE_SDFxSDF_F", 0x80000000, NULL, 0),
                     numberRHS);
        }
        // ; (3732)
        ;
      es4s2:;
      } // End of DO block
      // ; (3733)
      ;
    es4:;
    } // End of DO block
  // RETURN; (3734)
  {
    reentryGuard = 0;
    return 0;
  }
}
