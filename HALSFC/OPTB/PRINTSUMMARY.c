/*
  File PRINTSUMMARY.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
PRINTSUMMARY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PRINTSUMMARY");
  // OUTPUT = ''; (5695)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'CSE''S FOUND                   = '||CSE#; (5696)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "CSE'S FOUND                   = "),
                 bitToCharacter (getBIT (16, mCSEp)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF COMPLEX_MATCHES ~= 0 THEN (5697)
  if (1 & (xNEQ (COREHALFWORD (mCOMPLEX_MATCHES), 0)))
    // OUTPUT = 'COMPLEX CSE''S                 = '||COMPLEX_MATCHES; (5698)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "COMPLEX CSE'S                 = "),
                   bitToCharacter (getBIT (16, mCOMPLEX_MATCHES)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF TSUB_CSES ~= 0 THEN (5699)
  if (1 & (xNEQ (COREHALFWORD (mTSUB_CSES), 0)))
    // OUTPUT = 'TSUB CSE''S                    = '||TSUB_CSES; (5700)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "TSUB CSE'S                    = "),
                   bitToCharacter (getBIT (16, mTSUB_CSES)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF EXTN_CSES ~= 0 THEN (5701)
  if (1 & (xNEQ (COREHALFWORD (mEXTN_CSES), 0)))
    // OUTPUT = 'EXTN CSE''S                    = '||EXTN_CSES; (5702)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "EXTN CSE'S                    = "),
                   bitToCharacter (getBIT (16, mEXTN_CSES)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF TRANSPOSE_ELIMINATIONS ~= 0 THEN (5703)
  if (1 & (xNEQ (COREHALFWORD (mTRANSPOSE_ELIMINATIONS), 0)))
    // OUTPUT = 'MATRIX TRANSPOSE ELIMINATIONS = '||TRANSPOSE_ELIMINATIONS;
    // (5704)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "MATRIX TRANSPOSE ELIMINATIONS = "),
                   bitToCharacter (getBIT (16, mTRANSPOSE_ELIMINATIONS)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF DIVISION_ELIMINATIONS ~= 0 THEN (5705)
  if (1 & (xNEQ (COREHALFWORD (mDIVISION_ELIMINATIONS), 0)))
    // OUTPUT = 'DIVISION ELIMINATIONS         = '||DIVISION_ELIMINATIONS;
    // (5706)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "DIVISION ELIMINATIONS         = "),
                   bitToCharacter (getBIT (16, mDIVISION_ELIMINATIONS)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF LITERAL_FOLDS ~= 0 THEN (5707)
  if (1 & (xNEQ (COREHALFWORD (mLITERAL_FOLDS), 0)))
    // OUTPUT = 'LITERAL FOLDS                 = '||LITERAL_FOLDS; (5708)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "LITERAL FOLDS                 = "),
                   bitToCharacter (getBIT (16, mLITERAL_FOLDS)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // OUTPUT = ''; (5709)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF VDLP# ~= 0 THEN (5710)
  if (1 & (xNEQ (BYTE0 (mVDLPp), 0)))
    // OUTPUT = 'MAT/VEC INLINE LOOPS CREATED  = '||VDLP#; (5711)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "MAT/VEC INLINE LOOPS CREATED  = "),
                   bitToCharacter (getBIT (8, mVDLPp)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF DENEST# ~= 0 THEN (5712)
  if (1 & (xNEQ (COREHALFWORD (mDENESTp), 0)))
    // OUTPUT = 'LOOPS DENESTED                = '||DENEST#; (5713)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "LOOPS DENESTED                = "),
                   bitToCharacter (getBIT (16, mDENESTp)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF COMBINE# ~= 0 THEN (5714)
  if (1 & (xNEQ (COREHALFWORD (mCOMBINEp), 0)))
    // OUTPUT = 'LOOPS COMBINED                = '||COMBINE#; (5715)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "LOOPS COMBINED                = "),
                   bitToCharacter (getBIT (16, mCOMBINEp)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF INVAR# ~= 0 THEN (5716)
  if (1 & (xNEQ (COREHALFWORD (mINVARp), 0)))
    // OUTPUT = 'INVARIANTS PULLED FROM LOOPS  = '||INVAR#; (5717)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, "INVARIANTS PULLED FROM LOOPS  = "),
                   bitToCharacter (getBIT (16, mINVARp)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // OUTPUT = ''; (5718)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT= 'COMPARE CALLS                 = '||COMPARE_CALLS; (5719)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "COMPARE CALLS                 = "),
                 bitToCharacter (getBIT (16, mCOMPARE_CALLS)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'SCANS                         = '||SCANS; (5720)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "SCANS                         = "),
                 bitToCharacter (getBIT (16, mSCANS)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'MAX_NODE_LIST                 = '||MAXNODE; (5721)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "MAX_NODE_LIST                 = "),
                 bitToCharacter (getBIT (16, mMAXNODE)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'MAX_CSE_TAB                   = ' ||MAX_CSE_TAB; (5722)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "MAX_CSE_TAB                   = "),
                 bitToCharacter (getBIT (16, mMAX_CSE_TAB)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF PUSH# ~= 0 THEN (5723)
  if (1 & (xNEQ (COREHALFWORD (mPUSHp), 0)))
    // DO; (5724)
    {
    rs1:;
      // OUTPUT = 'CALLS TO PUSH HALMAT          = '||PUSH#; (5725)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (cToDescriptor (NULL, "CALLS TO PUSH HALMAT          = "),
                     bitToCharacter (getBIT (16, mPUSHp)));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // OUTPUT = 'HALMAT WORDS MOVED            = '||PUSH_SIZE; (5726)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (cToDescriptor (NULL, "HALMAT WORDS MOVED            = "),
                     fixedToCharacter (getFIXED (mPUSH_SIZE)));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // OUTPUT = 'MINOR COMPACTIFIES            = '||COMPACTIFIES; (5727)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "MINOR COMPACTIFIES            = "),
                 bitToCharacter (getBIT (16, mCOMPACTIFIES)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'MAJOR COMPACTIFIES            = '||COMPACTIFIES(1); (5728)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "MAJOR COMPACTIFIES            = "),
                 bitToCharacter (getBIT (16, mCOMPACTIFIES + 2 * 1)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'FREE STRING AREA              = '||FREELIMIT - FREEBASE; (5729)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "FREE STRING AREA              = "),
                 fixedToCharacter (xsubtract (FREELIMIT (), FREEBASE ())));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (5730)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (5731)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // DO FOR TEMP = 1 TO COMM(10); (5732)
  {
    int32_t from124, to124, by124;
    from124 = 1;
    to124 = getFIXED (mCOMM + 4 * 10);
    by124 = 1;
    for (putBIT (16, mPRINTSUMMARYxTEMP, fixedToBit (16, from124));
         bitToFixed (getBIT (16, mPRINTSUMMARYxTEMP)) <= to124;
         putBIT (16, mPRINTSUMMARYxTEMP,
                 fixedToBit (16, bitToFixed (getBIT (16, mPRINTSUMMARYxTEMP))
                                     + by124)))
      {
        // IF LEAFPROC THEN (5733)
        if (1 & (bitToFixed (PRINTSUMMARYxLEAFPROC (0))))
          // DO; (5734)
          {
          rs2s1:;
            // OUTPUT = 'PROCEDURES STILL ELIGIBLE FOR LEAF PROCEDURES:';
            // (5735)
            {
              descriptor_t *stringRHS;
              stringRHS = cToDescriptor (
                  NULL, "PROCEDURES STILL ELIGIBLE FOR LEAF PROCEDURES:");
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
            // DO FOR TEMP = TEMP TO COMM(10); (5736)
            {
              int32_t from125, to125, by125;
              from125 = bitToFixed (getBIT (16, mPRINTSUMMARYxTEMP));
              to125 = getFIXED (mCOMM + 4 * 10);
              by125 = 1;
              for (putBIT (16, mPRINTSUMMARYxTEMP, fixedToBit (16, from125));
                   bitToFixed (getBIT (16, mPRINTSUMMARYxTEMP)) <= to125;
                   putBIT (16, mPRINTSUMMARYxTEMP,
                           fixedToBit (
                               16, bitToFixed (getBIT (16, mPRINTSUMMARYxTEMP))
                                       + by125)))
                {
                  // IF LEAFPROC THEN (5737)
                  if (1 & (bitToFixed (PRINTSUMMARYxLEAFPROC (0))))
                    // OUTPUT = '     ' || SYT_NAME(TEMP); (5738)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = xsCAT (
                          cToDescriptor (NULL, "     "),
                          getCHARACTER (
                              getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mPRINTSUMMARYxTEMP)) + 0
                              + 4 * (0)));
                      OUTPUT (0, stringRHS);
                      stringRHS->inUse = 0;
                    }
                }
            } // End of DO for-loop block
            // OUTPUT = ''; (5739)
            {
              descriptor_t *stringRHS;
              stringRHS = cToDescriptor (NULL, "");
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
            // OUTPUT = ''; (5740)
            {
              descriptor_t *stringRHS;
              stringRHS = cToDescriptor (NULL, "");
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
            // GO TO EXITT; (5741)
            goto EXITT;
          es2s1:;
          } // End of DO block
      }
  } // End of DO for-loop block
// EXITT: (5742)
EXITT:
  // CALL PRINT_DATE_AND_TIME('END OF HAL/S OPTIMIZER ', DATE,TIME); (5743)
  {
    putCHARACTERp (mPRINT_DATE_AND_TIMExMESSAGE,
                   cToDescriptor (NULL, "END OF HAL/S OPTIMIZER "));
    putFIXED (mPRINT_DATE_AND_TIMExD, DATE ());
    putFIXED (mPRINT_DATE_AND_TIMExT, TIME ());
    PRINT_DATE_AND_TIME (0);
  }
  // OUTPUT = ''; (5744)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (5745)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // T = MONITOR(18); (5746)
  {
    int32_t numberRHS = (int32_t)(MONITOR18 ());
    putFIXED (mPRINTSUMMARYxT, numberRHS);
  }
  // CALL PRINT_TIME('TOTAL CPU TIME FOR OPTIMIZER     ',T - CLOCK); (5747)
  {
    putCHARACTERp (mPRINT_TIMExMESSAGE,
                   cToDescriptor (NULL, "TOTAL CPU TIME FOR OPTIMIZER     "));
    putFIXED (mPRINT_TIMExT,
              xsubtract (getFIXED (mPRINTSUMMARYxT), getFIXED (mCLOCK)));
    PRINT_TIME (0);
  }
  // CALL PRINT_TIME('CPU TIME FOR OPTIMIZER SETUP     ', CLOCK(1)-CLOCK);
  // (5748)
  {
    putCHARACTERp (mPRINT_TIMExMESSAGE,
                   cToDescriptor (NULL, "CPU TIME FOR OPTIMIZER SETUP     "));
    putFIXED (mPRINT_TIMExT,
              xsubtract (getFIXED (mCLOCK + 4 * 1), getFIXED (mCLOCK)));
    PRINT_TIME (0);
  }
  // CALL PRINT_TIME('CPU TIME FOR OPTIMIZER CRUNCHING ' ,CLOCK(2) - CLOCK(1));
  // (5749)
  {
    putCHARACTERp (mPRINT_TIMExMESSAGE,
                   cToDescriptor (NULL, "CPU TIME FOR OPTIMIZER CRUNCHING "));
    putFIXED (mPRINT_TIMExT, xsubtract (getFIXED (mCLOCK + 4 * 2),
                                        getFIXED (mCLOCK + 4 * 1)));
    PRINT_TIME (0);
  }
  // CALL PRINT_TIME('CPU TIME FOR OPTIMIZER CLEAN UP  ' ,T - CLOCK(2)); (5750)
  {
    putCHARACTERp (mPRINT_TIMExMESSAGE,
                   cToDescriptor (NULL, "CPU TIME FOR OPTIMIZER CLEAN UP  "));
    putFIXED (mPRINT_TIMExT, xsubtract (getFIXED (mPRINTSUMMARYxT),
                                        getFIXED (mCLOCK + 4 * 2)));
    PRINT_TIME (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
