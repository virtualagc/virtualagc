/*
  File COMMON_ERRORS.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
COMMON_ERRORS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "COMMON_ERRORS");
  // FOUND = 0; (911)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mCOMMON_ERRORSxFOUND, bitRHS);
    bitRHS->inUse = 0;
  }
  // NUMIT = NUM; (912)
  {
    descriptor_t *bitRHS = getBIT (16, mCOMMON_ERRORSxNUM);
    descriptor_t *stringRHS;
    stringRHS = bitToCharacter (bitRHS);
    putCHARACTER (mCOMMON_ERRORSxNUMIT, stringRHS);
    bitRHS->inUse = 0;
    stringRHS->inUse = 0;
  }
  // TEMP_STMT = STMT#; (913)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mCOMMON_ERRORSxSTMTp));
    descriptor_t *stringRHS;
    stringRHS = fixedToCharacter (numberRHS);
    putCHARACTER (mCOMMON_ERRORSxTEMP_STMT, stringRHS);
    stringRHS->inUse = 0;
  }
  // DOWN_COUNT = 1; (914)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCOMMON_ERRORSxDOWN_COUNT, bitRHS);
    bitRHS->inUse = 0;
  }
// AGAIN: (915)
AGAIN:
  // C=SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2); (916)
  {
    descriptor_t *stringRHS;
    stringRHS = SUBSTR (
        getCHARACTER (mERROR_CLASSES),
        SHL (xsubtract (COREHALFWORD (mCOMMON_ERRORSxCLASS), 1), 1), 2);
    putCHARACTER (mCOMMON_ERRORSxC, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF BYTE(C,1)=BYTE(' ') THEN (917)
  if (1
      & (xEQ (BYTE (getCHARACTER (mCOMMON_ERRORSxC), 1),
              BYTE1 (cToDescriptor (NULL, " ")))))
    // C=SUBSTR(C,0,1); (918)
    {
      descriptor_t *stringRHS;
      stringRHS = SUBSTR (getCHARACTER (mCOMMON_ERRORSxC), 0, 1);
      putCHARACTER (mCOMMON_ERRORSxC, stringRHS);
      stringRHS->inUse = 0;
    }
  // C=PAD(C||NUM,8); (919)
  {
    descriptor_t *stringRHS;
    stringRHS = (putCHARACTERp (
                     mPADxSTRING,
                     xsCAT (getCHARACTER (mCOMMON_ERRORSxC),
                            bitToCharacter (getBIT (16, mCOMMON_ERRORSxNUM)))),
                 putFIXED (mPADxWIDTH, 8), PAD (0));
    putCHARACTER (mCOMMON_ERRORSxC, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF MONITOR(2,5,C) THEN (920)
  if (1 & (MONITOR2 (5, getCHARACTER (mCOMMON_ERRORSxC))))
    // DO; (921)
    {
    rs1:;
      // CLASS=CLASS_BX; (922)
      {
        descriptor_t *bitRHS = getBIT (16, mCLASS_BX);
        putBIT (16, mCOMMON_ERRORSxCLASS, bitRHS);
        bitRHS->inUse = 0;
      }
      // NUM=113; (923)
      {
        int32_t numberRHS = (int32_t)(113);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mCOMMON_ERRORSxNUM, bitRHS);
        bitRHS->inUse = 0;
      }
      // TEXT = C; (924)
      {
        descriptor_t *stringRHS;
        stringRHS = getCHARACTER (mCOMMON_ERRORSxC);
        putCHARACTER (mCOMMON_ERRORSxTEXT, stringRHS);
        stringRHS->inUse = 0;
      }
      // GO TO AGAIN; (925)
      goto AGAIN;
    es1:;
    } // End of DO block
  // CLS_COMPARE = CLASS; (926)
  {
    descriptor_t *bitRHS = getBIT (16, mCOMMON_ERRORSxCLASS);
    descriptor_t *stringRHS;
    stringRHS = bitToCharacter (bitRHS);
    putCHARACTER (mCOMMON_ERRORSxCLS_COMPARE, stringRHS);
    bitRHS->inUse = 0;
    stringRHS->inUse = 0;
  }
  // S = INPUT(ERRORFILE); (927)
  {
    descriptor_t *stringRHS;
    stringRHS = INPUT (5);
    putCHARACTER (mCOMMON_ERRORSxS, stringRHS);
    stringRHS->inUse = 0;
  }
  // SEVERITY = BYTE(S) - BYTE('0'); (928)
  {
    int32_t numberRHS
        = (int32_t)(xsubtract (BYTE1 (getCHARACTER (mCOMMON_ERRORSxS)),
                               BYTE1 (cToDescriptor (NULL, "0"))));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mCOMMON_ERRORSxSEVERITY, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE FOUND = 0 & DOWN_COUNT < = RECORD_TOP(DOWN_INFO); (929)
  while (1
         & (xAND (
             xEQ (BYTE0 (mCOMMON_ERRORSxFOUND), 0),
             xLE (COREHALFWORD (mCOMMON_ERRORSxDOWN_COUNT),
                  xsubtract (COREWORD (xadd (
                                 ADDR ("DOWN_INFO", 0x80000000, NULL, 0), 12)),
                             1)))))
    {
      // IF NUMIT = DWN_ERR(DOWN_COUNT) & CLS_COMPARE =DWN_CLS(DOWN_COUNT) THEN
      // (930)
      if (1
          & (xAND (xsEQ (getCHARACTER (mCOMMON_ERRORSxNUMIT),
                         getCHARACTER (
                             getFIXED (mDOWN_INFO)
                             + 20 * (COREHALFWORD (mCOMMON_ERRORSxDOWN_COUNT))
                             + 4 + 4 * (0))),
                   xsEQ (getCHARACTER (mCOMMON_ERRORSxCLS_COMPARE),
                         getCHARACTER (
                             getFIXED (mDOWN_INFO)
                             + 20 * (COREHALFWORD (mCOMMON_ERRORSxDOWN_COUNT))
                             + 8 + 4 * (0))))))
        // DO; (931)
        {
        rs2s1:;
          // IF TEMP_STMT = DWN_STMT(DOWN_COUNT) THEN (932)
          if (1
              & (xsEQ (getCHARACTER (mCOMMON_ERRORSxTEMP_STMT),
                       getCHARACTER (
                           getFIXED (mDOWN_INFO)
                           + 20 * (COREHALFWORD (mCOMMON_ERRORSxDOWN_COUNT))
                           + 0 + 4 * (0)))))
            // DO; (933)
            {
            rs2s1s1:;
              // IF SEVERITY = 1 THEN (934)
              if (1 & (xEQ (COREHALFWORD (mCOMMON_ERRORSxSEVERITY), 1)))
                // DO; (935)
                {
                rs2s1s1s1:;
                  // SEVERITY = 0; (936)
                  {
                    int32_t numberRHS = (int32_t)(0);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mCOMMON_ERRORSxSEVERITY, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // OUTPUT = AST || ' THE FOLLOWING ERROR WAS DOWNGRADED FROM
                  // A '|| 'SEVERITY ONE ERROR TO A SEVERITY ZERO ERROR '||AST;
                  // (937)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        xsCAT (xsCAT (getCHARACTER (mCOMMON_ERRORSxAST),
                                      cToDescriptor (
                                          NULL, " THE FOLLOWING ERROR WAS "
                                                "DOWNGRADED FROM A ")),
                               cToDescriptor (NULL, "SEVERITY ONE ERROR TO A "
                                                    "SEVERITY ZERO ERROR ")),
                        getCHARACTER (mCOMMON_ERRORSxAST));
                    OUTPUT (0, stringRHS);
                    stringRHS->inUse = 0;
                  }
                  // FOUND = 1; (938)
                  {
                    int32_t numberRHS = (int32_t)(1);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (1, mCOMMON_ERRORSxFOUND, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // DWN_VER(DOWN_COUNT) = 1; (939)
                  {
                    int32_t numberRHS = (int32_t)(1);
                    putCHARACTER (
                        getFIXED (mDOWN_INFO)
                            + 20 * (COREHALFWORD (mCOMMON_ERRORSxDOWN_COUNT))
                            + 16 + 4 * (0),
                        fixedToCharacter (numberRHS));
                  }
                es2s1s1s1:;
                } // End of DO block
              // ELSE (940)
              else
                // DO; (941)
                {
                rs2s1s1s2:;
                  // OUTPUT = AST || ' AN ATTEMPT WAS MADE TO DOWNGRADE AN ' ||
                  // 'ERROR OTHER THAN A SEVERITY ONE ERROR ' || 'REMOVE
                  // DOWNGRADE DIRECTIVE AND RECOMPILE ' || AST; (942)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        xsCAT (
                            xsCAT (
                                xsCAT (getCHARACTER (mCOMMON_ERRORSxAST),
                                       cToDescriptor (NULL,
                                                      " AN ATTEMPT WAS MADE "
                                                      "TO DOWNGRADE AN ")),
                                cToDescriptor (
                                    NULL,
                                    "ERROR OTHER THAN A SEVERITY ONE ERROR ")),
                            cToDescriptor (
                                NULL,
                                "REMOVE DOWNGRADE DIRECTIVE AND RECOMPILE ")),
                        getCHARACTER (mCOMMON_ERRORSxAST));
                    OUTPUT (0, stringRHS);
                    stringRHS->inUse = 0;
                  }
                  // SEVERITY = 2; (943)
                  {
                    int32_t numberRHS = (int32_t)(2);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mCOMMON_ERRORSxSEVERITY, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // FOUND = 1; (944)
                  {
                    int32_t numberRHS = (int32_t)(1);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (1, mCOMMON_ERRORSxFOUND, bitRHS);
                    bitRHS->inUse = 0;
                  }
                es2s1s1s2:;
                } // End of DO block
            es2s1s1:;
            } // End of DO block
        es2s1:;
        } // End of DO block
      // DOWN_COUNT = DOWN_COUNT + 1; (945)
      {
        int32_t numberRHS
            = (int32_t)(xadd (COREHALFWORD (mCOMMON_ERRORSxDOWN_COUNT), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mCOMMON_ERRORSxDOWN_COUNT, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // OUTPUT(1) = '0' || AST || C || ' ERROR #' || ERROR# || ' OF SEVERITY ' ||
  // SEVERITY || ' OCCURRED ' || AST; (946)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        xsCAT (
            xsCAT (
                xsCAT (xsCAT (xsCAT (xsCAT (xsCAT (cToDescriptor (NULL, "0"),
                                                   getCHARACTER (
                                                       mCOMMON_ERRORSxAST)),
                                            getCHARACTER (mCOMMON_ERRORSxC)),
                                     cToDescriptor (NULL, " ERROR #")),
                              bitToCharacter (
                                  getBIT (16, mCOMMON_ERRORSxERRORp))),
                       cToDescriptor (NULL, " OF SEVERITY ")),
                bitToCharacter (getBIT (16, mCOMMON_ERRORSxSEVERITY))),
            cToDescriptor (NULL, " OCCURRED ")),
        getCHARACTER (mCOMMON_ERRORSxAST));
    OUTPUT (1, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = AST || ' DURING CONVERSION OF HAL/S STATEMENT ' || STMT# || '.'
  // || AST; (947)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        xsCAT (
            xsCAT (xsCAT (getCHARACTER (mCOMMON_ERRORSxAST),
                          cToDescriptor (
                              NULL, " DURING CONVERSION OF HAL/S STATEMENT ")),
                   fixedToCharacter (getFIXED (mCOMMON_ERRORSxSTMTp))),
            cToDescriptor (NULL, ".")),
        getCHARACTER (mCOMMON_ERRORSxAST));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // S = INPUT(ERRORFILE); (948)
  {
    descriptor_t *stringRHS;
    stringRHS = INPUT (5);
    putCHARACTER (mCOMMON_ERRORSxS, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF LENGTH(TEXT) > 0 THEN (949)
  if (1 & (xGT (LENGTH (getCHARACTER (mCOMMON_ERRORSxTEXT)), 0)))
    // IMBED=TRUE; (950)
    {
      int32_t numberRHS = (int32_t)(1);
      descriptor_t *bitRHS;
      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
      putBIT (1, mCOMMON_ERRORSxIMBED, bitRHS);
      bitRHS->inUse = 0;
    }
  // DO WHILE LENGTH(S)>0; (951)
  while (1 & (xGT (LENGTH (getCHARACTER (mCOMMON_ERRORSxS)), 0)))
    {
      // IF IMBED THEN (952)
      if (1 & (bitToFixed (getBIT (1, mCOMMON_ERRORSxIMBED))))
        // DO; (953)
        {
        rs3s1:;
          // K = CHAR_INDEX(S,'??'); (954)
          {
            int32_t numberRHS
                = (int32_t)((putCHARACTERp (mCHAR_INDEXxSTRING1,
                                            getCHARACTER (mCOMMON_ERRORSxS)),
                             putCHARACTERp (mCHAR_INDEXxSTRING2,
                                            cToDescriptor (NULL, "??")),
                             CHAR_INDEX (0)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mCOMMON_ERRORSxK, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF K >= 0 THEN (955)
          if (1 & (xGE (COREHALFWORD (mCOMMON_ERRORSxK), 0)))
            // DO; (956)
            {
            rs3s1s1:;
              // IF K = 0 THEN (957)
              if (1 & (xEQ (COREHALFWORD (mCOMMON_ERRORSxK), 0)))
                // S = TEXT || SUBSTR(S,2); (958)
                {
                  descriptor_t *stringRHS;
                  stringRHS
                      = xsCAT (getCHARACTER (mCOMMON_ERRORSxTEXT),
                               SUBSTR2 (getCHARACTER (mCOMMON_ERRORSxS), 2));
                  putCHARACTER (mCOMMON_ERRORSxS, stringRHS);
                  stringRHS->inUse = 0;
                }
              // ELSE (959)
              else
                // S = SUBSTR(S,0,K) || TEXT || SUBSTR(S,K+2); (960)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      xsCAT (SUBSTR (getCHARACTER (mCOMMON_ERRORSxS), 0,
                                     COREHALFWORD (mCOMMON_ERRORSxK)),
                             getCHARACTER (mCOMMON_ERRORSxTEXT)),
                      SUBSTR2 (getCHARACTER (mCOMMON_ERRORSxS),
                               xadd (COREHALFWORD (mCOMMON_ERRORSxK), 2)));
                  putCHARACTER (mCOMMON_ERRORSxS, stringRHS);
                  stringRHS->inUse = 0;
                }
              // IMBED = FALSE; (961)
              {
                int32_t numberRHS = (int32_t)(0);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mCOMMON_ERRORSxIMBED, bitRHS);
                bitRHS->inUse = 0;
              }
            es3s1s1:;
            } // End of DO block
        es3s1:;
        } // End of DO block
      // OUTPUT = AST || S; (962)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (getCHARACTER (mCOMMON_ERRORSxAST),
                           getCHARACTER (mCOMMON_ERRORSxS));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // S = INPUT(ERRORFILE); (963)
      {
        descriptor_t *stringRHS;
        stringRHS = INPUT (5);
        putCHARACTER (mCOMMON_ERRORSxS, stringRHS);
        stringRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // TEXT = ''; (964)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    putCHARACTER (mCOMMON_ERRORSxTEXT, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF SEVERITY = 1 THEN (965)
  if (1 & (xEQ (COREHALFWORD (mCOMMON_ERRORSxSEVERITY), 1)))
    // DO; (966)
    {
    rs4:;
      // SEVERITY_ONE = TRUE; (967)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mSEVERITY_ONE, bitRHS);
        bitRHS->inUse = 0;
      }
      // SEVERITY = 0; (968)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mCOMMON_ERRORSxSEVERITY, bitRHS);
        bitRHS->inUse = 0;
      }
    es4:;
    } // End of DO block
  // RETURN SEVERITY; (969)
  {
    reentryGuard = 0;
    return COREHALFWORD (mCOMMON_ERRORSxSEVERITY);
  }
}
