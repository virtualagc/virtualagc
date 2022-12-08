 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DOWNSUM.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***********************************************************/                   00001000
/*                                                         */                   00002000
/*  FUNCTION:                                              */                   00003000
/*  ROUTINE TO SUMMARIZE DOWNGRADE ATTEMPTS AND RESULTS    */                   00003100
/*                                                         */                   00005000
/*  INCLUDED BY: PASS1, PASS2, AUX, FLO, OPT               */                   00005100
/*                                                         */                   00005200
/***********************************************************/                   00006000
/*                                                         */                   00007000
/*  REVISION HISTORY                                       */                   00008000
/*                                                         */                   00009000
/*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                   00009100
/*                                                         */                   00009200
/*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                   00009300
/*                                                         */                   00009400
/*  02/07/91 RAH  23V2  CR11098  REMOVE SPILL              */                   00009500
/*                                                         */
/*  10/29/93 TEV  26V0/ DR108630 0C4 ABEND OCCURS ON       */
/*                10V0           ILLEGAL DOWNGRADE         */
/*                                                         */                   00009600
/*  04/03/00 DCP  30V0/ CR13273  PRODUCE SDF MEMBER WHEN   */
/*                15V0           OBJECT MODULE CREATED     */
/*                                                         */                   00009600
/***********************************************************/                   00009900
DOWNGRADE_SUMMARY:  PROCEDURE;                                                  00020000
/****** CR11088 11/90 RAH **********************************/                   00030000
   DECLARE (I, COUNT, DOWN_COUNT) FIXED;                                        00031001
   DECLARE (TEMP_CLS, TEMP1, TEMP2, TEMP3) CHARACTER;                           00032200
   DECLARE (END_OF_LIST, SEARCH_FOR_CLS) BIT(1);              /* CR13273 */     00033000
/****** END CR11088 ****************************************/                   00033100
   END_OF_LIST = 0;                                                             00034500
   NOT_DOWNGRADED = 0;                                                          00034601
   /*  PRINT TITLE FOR DOWNGRADE SUMMARY     */                                 00040000
   DOWN_COUNT = 1;                                                              00103000
   /*  DETERMINE IF THERE ARE ANY DOWNGRADED MESSAGES     */                    00220000
/****** CR11098 RAH ****************************************/
   IF RECORD_TOP(DOWN_INFO) >= 1 THEN DO;
/****** END CR11098 ****************************************/
      /*  THERE ARE ATTEMPTS AT DOWNGRADE   */                                  00220200
      OUTPUT = ' ';                                                             00220300
      OUTPUT = ' ';                                                             00220500
      OUTPUT = ' ';                                                             00220600
      OUTPUT = ' **********  DOWNGRADE SUMMARY   *********************';        00222000
      OUTPUT = ' ';                                                             00223000
      OUTPUT = ' ';                                                             00223300
      /*  TRAVERSE THROUGH DOWNGRADE LIST LOOKING FOR DOWNGRADED ERRORS  */     00224000
      /*  CHANGED HARDCODED 10 TO RECORD_TOP(DOWN_INFO) FOR CR11088      */     00225001
      DO WHILE END_OF_LIST = 0 & DOWN_COUNT < = RECORD_TOP(DOWN_INFO);          00230001
         IF DWN_ERR(DOWN_COUNT) > ' ' THEN DO;                                  00240000
            IF DWN_VER(DOWN_COUNT) = 1 THEN DO;                                 00250000
               SEARCH_FOR_CLS = 1;                                              00250100
               COUNT = 0;                                                       00250200
               DO WHILE SEARCH_FOR_CLS = 1;                                     00250300
                  IF DWN_CLS(DOWN_COUNT) = ERR_VALUE(COUNT) THEN DO;            00250500
                     TEMP_CLS = SUBSTR(ERROR_INDEX(COUNT),6,2);                 00250600
                     SEARCH_FOR_CLS = 0;                                        00251400
                  END;                                                          00251500
                  ELSE DO;                                                      00251600
                     COUNT = COUNT + 1;                                         00251700
                  END;                                                          00251800
               END;                                                             00251900
               TEMP1 = SUBSTR(TEMP_CLS,0,1);                                    00252000
               TEMP2 = SUBSTR(TEMP_CLS,1,1);                                    00252100
               IF TEMP2 = ' ' THEN                                              00252200
                  TEMP3 = TEMP1 || DWN_ERR(DOWN_COUNT);                         00252300
               ELSE                                                             00252400
                  TEMP3 = TEMP_CLS || DWN_ERR(DOWN_COUNT);                      00252500
               OUTPUT = '*** ERROR NUMBER ' || TEMP3||' AT STATEMENT NUMBER '|| 00252600
                         DWN_STMT(DOWN_COUNT) || ' ***';                        00252800
               OUTPUT = '*** WAS DOWNGRADED FROM A SEVERITY ONE ERROR TO'       00252900
                         || ' A SEVERITY ZERO ERROR MESSAGE ***';               00253000
               OUTPUT = '  ';                                                   00253100
               OUTPUT = '  ';                                                   00253300
            END;    /*SUCCESSFUL DOWNGRADE   */                                 00254000
/****** CR11088 11/90 RAH **********************************/                   00255001
            ELSE                                                                00262201
               /* SET NOT_DOWNGRADED TO INDICATE THAT THERE WAS AT */           00262801
               /* LEAST ONE DOWNGRADE NOT USED.                    */           00262901
               NOT_DOWNGRADED = 1;                                              00263101
/****** END CR11088 ****************************************/                   00263201
         END;                                                                   00263300
         ELSE DO;                                                               00263400
            END_OF_LIST = 1;                                                    00263500
         END;                                                                   00263800
         DOWN_COUNT = DOWN_COUNT + 1;                                           00263900
      END; /*    OF WHILE   */                                                  00264000
   /*  CHECK FOR ATTEMPTED DOWNGRADES THAT WERE NOT ERRORS     */               00264300
                                                                                00264400
/****** CR11088 11/90 RAH **********************************/                   00264501
      IF NOT_DOWNGRADED THEN DO;                                                00264601
/****** END CR11088 ****************************************/                   00264801
         OUTPUT = '  ';                                                         00264901
         OUTPUT = '  ';                                                         00265001
         OUTPUT = '*****  DOWNGRADE DIRECTIVES THAT WERE NOT DOWNGRADED *****'; 00265101
         OUTPUT = '  ';                                                         00265201
         OUTPUT = '  ';                                                         00265301
/****** CR11088 11/90 RAH **********************************/                   00265401
         DO I = 1 TO RECORD_TOP(DOWN_INFO);                                     00267001
            IF DWN_VER(I) ^= 1 THEN DO;                                         00267101
/****** END CR11088 ****************************************/                   00267201
               DOWN_COUNT = I;                                                  00268001
               SEARCH_FOR_CLS = 1;                                              00269001
               COUNT = 0;                                                       00269101
/*********************** DR108630 - TEV - 10/29/93 ********************/
/* IF DWN_UNKN(I) IS SET, A BI107 ERROR HAS OCCURED AND DWN_CLS(I) IS */
/* EMPTY; DWN_UNKN(I) CONTAINS THE UNKNOWN ERROR. MOVE IT TO TEMP3    */
/* AND GO PRINT THE ERROR MESSAGE. DO *NOT* ATTEMPT TO EXTRACT THE    */
/* ERROR MESSAGE FROM THE DOWNGRADE TABLE (THIS CAUSED THE 0C4 ABEND).*/
               IF DWN_UNKN(I) ^= '' THEN DO;
                  TEMP3 = DWN_UNKN(I);
                  GOTO PRINT_ERR_MSG;
               END;
               ELSE
/*********************** END DR108630 *********************************/
               DO WHILE SEARCH_FOR_CLS = 1;                                     00269201
                  IF DWN_CLS(DOWN_COUNT) = ERR_VALUE(COUNT) THEN DO;            00269301
                     TEMP_CLS = SUBSTR(ERROR_INDEX(COUNT),6,2);                 00269401
                     SEARCH_FOR_CLS = 0;                                        00270201
                  END;                                                          00270301
                  ELSE DO;                                                      00270401
                     COUNT = COUNT + 1;                                         00270501
                  END;                                                          00270601
               END;                                                             00270701
               TEMP1 = SUBSTR(TEMP_CLS,0,1);                                    00270801
               TEMP2 = SUBSTR(TEMP_CLS,1,1);                                    00270901
               IF TEMP2 = ' ' THEN                                              00271001
                  TEMP3 = TEMP1 || DWN_ERR(DOWN_COUNT);                         00271101
               ELSE                                                             00271201
                  TEMP3 = TEMP_CLS || DWN_ERR(DOWN_COUNT);                      00271301
PRINT_ERR_MSG:      /* DR108630 - TEV - 10/29/93 */
               OUTPUT = '*** ERROR NUMBER ' || TEMP3 ||                         00271401
                        ' FOR STATEMENT NUMBER ' || DWN_STMT(DOWN_COUNT) ||     00272001
                        ' WAS NOT DOWNGRADED, REMOVE DOWNGRADE' ||              00280001
                        ' DIRECTIVE AND RECOMPILE *** ';                        00290001
               OUTPUT = '  ';                                                   00293001
            END;                                                                00310001
         END;  /* OF DO I = 1 TO RECORD_TOP(DOWN_INFO) */                       00330001
      END;                                                                      00341001
   END;  /* DOWNGRADE CHECK   */                                                00342001
END DOWNGRADE_SUMMARY;                                                          00561000
                                                                                00570000
