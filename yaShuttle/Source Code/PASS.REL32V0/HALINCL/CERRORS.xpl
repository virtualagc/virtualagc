 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CERRORS.xpl
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
 
/***********************************************************/                   00010100
/*                                                         */                   00010200
/*  FUNCTION:                                              */                   00010300
/*  ERROR ROUTINE FOR COMMON ERROR HANDLING FUNCTIONS      */                   00010400
/*                                                         */                   00010600
/*  INCLUDED BY: PASS1, PASS2, AUX, FLO, OPT               */                   00010700
/*                                                         */                   00010900
/***********************************************************/                   00011000
/*                                                         */                   00011100
/*  REVISION HISTORY                                       */                   00011200
/*                                                         */                   00011300
/*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                   00011400
/*                                                         */                   00011500
/*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                   00011600
/*  12/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM    */                   00011700
/*                               COMPILER                  */                   00011800
/*                                                         */                   00011900
/*  06/22/95 DAS  26V0  CR12416  IMPROVE COMPILER ERROR    */                   00012000
/*                11V0           PROCESSING                */                   00012100
/*                                                         */                   00012200
/***********************************************************/                   00012300
                                                                                00013000
COMMON_ERRORS:                                                                  00020000
   PROCEDURE(CLASS, NUM, TEXT, ERROR#, STMT#);                                  00021000
   DECLARE ERRORFILE LITERALLY '5';                                             00030000
   DECLARE (SEVERITY, K, CLASS, NUM) BIT(16), IMBED BIT(1);                     00040000
   DECLARE (TEXT, C, S, CLS_COMPARE, NUMIT,TEMP_STMT) CHARACTER;                00050000
   DECLARE AST CHARACTER INITIAL('***** ');                                     00060000
   DECLARE ERROR# BIT(16);                                                      00070000
   DECLARE DOWN_COUNT BIT(16);                                                  00071000
   DECLARE STMT# FIXED;                                                         00080000
   DECLARE FOUND BIT(1);                                                        00090000
   FOUND = 0;                                                                   00102000
   NUMIT = NUM;                                                                 00102100
   TEMP_STMT = STMT#;                                                           00102200
   DOWN_COUNT = 1;                                                              00103000
   AGAIN:C=SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2);                              00110000
   IF BYTE(C,1)=BYTE(' ') THEN C=SUBSTR(C,0,1);                                 00120000
   C=PAD(C||NUM,8);                                                             00130000
   IF MONITOR(2,5,C) THEN DO;                                                   00140000
      CLASS=CLASS_BX;                                                           00150000
      NUM=113;                                                                  00160000
      TEXT = C;                                                                 00170000
      GO TO AGAIN;                                                              00180000
   END;                                                                         00190000
   CLS_COMPARE = CLASS;                                                         00191100
   S = INPUT(ERRORFILE);                                                        00200000
   SEVERITY = BYTE(S) - BYTE('0');                                              00210000
   /*  DETERMINE IF THERE IS A DOWNGRADE FOR THIS STMT  */                      00220000
   /*  CR11088 CHANGED HARDCODED 10 TO RECORD_TOP(DOWN_INFO) */                 00221000
   DO WHILE FOUND = 0  & DOWN_COUNT < = RECORD_TOP(DOWN_INFO);                  00230000
      IF NUMIT = DWN_ERR(DOWN_COUNT) & CLS_COMPARE =DWN_CLS(DOWN_COUNT) THEN DO;00250000
         IF TEMP_STMT = DWN_STMT(DOWN_COUNT) THEN DO;                           00251000
            IF SEVERITY = 1 THEN DO;                                            00260000
               SEVERITY = 0;                                                    00261000
               OUTPUT = AST || ' THE FOLLOWING ERROR WAS DOWNGRADED FROM A '||  00262000
                        'SEVERITY ONE ERROR TO A SEVERITY ZERO ERROR '||AST;    00262100
               FOUND = 1;                                                       00262200
               /* NOTE THAT THE ERROR WAS DOWNGRADED SUCCESSFULLY  */           00262300
               DWN_VER(DOWN_COUNT) = 1;                                         00262400
            END;                                                                00262500
            ELSE DO;                                                            00263300
                 OUTPUT = AST || ' AN ATTEMPT WAS MADE TO DOWNGRADE AN ' ||     00263400
                          'ERROR OTHER THAN A SEVERITY ONE ERROR ' ||           00263500
                          'REMOVE DOWNGRADE DIRECTIVE AND RECOMPILE ' || AST;   00263600
                 SEVERITY = 2;                                                  00263700
                 FOUND = 1;                                                     00263800
            END;                                                                00263900
         END;                                                                   00264000
      END;                                                                      00264800
      DOWN_COUNT = DOWN_COUNT + 1;                                              00264900
   END;                                                                         00265000
   OUTPUT(1) = '0' || AST || C || ' ERROR #' || ERROR# || ' OF SEVERITY ' ||    00265100
                 SEVERITY || ' OCCURRED ' || AST;                               00265200
   OUTPUT = AST || ' DURING CONVERSION OF HAL/S STATEMENT ' ||                  00265300
               STMT# || '.' || AST;                                             00266000
   S = INPUT(ERRORFILE);                                                        00270000
   IF LENGTH(TEXT) > 0 THEN IMBED=TRUE;                                         00280000
   DO WHILE LENGTH(S)>0;                                                        00290000
      IF IMBED THEN DO;                                                         00300000
         K = CHAR_INDEX(S,'??');                                                00310000
         IF K >= 0 THEN DO;                                                     00320000
            IF K = 0 THEN S = TEXT || SUBSTR(S,2);                              00330000
            ELSE S = SUBSTR(S,0,K) || TEXT || SUBSTR(S,K+2);                    00340000
            IMBED = FALSE;                                                      00350000
         END;                                                                   00360000
      END;                                                                      00370000
      OUTPUT = AST || S;                                                        00380000
      S = INPUT(ERRORFILE);                                                     00390000
   END;                                                                         00400000
   TEXT = '';                                                                   00410000
   /* CR12416: TREAT SEVERITY 1 ERRORS AS WARNINGS */                           00420000
   IF SEVERITY = 1 THEN DO;               /* CR12416 */                         00440000
      SEVERITY_ONE = TRUE;                /* CR12416 */                         00441000
      SEVERITY = 0;                       /* CR12416 */                         00442000
   END;                                   /* CR12416 */                         00443000
   RETURN SEVERITY;                                                             00450000
END COMMON_ERRORS;                                                              00561000
                                                                                00570000
