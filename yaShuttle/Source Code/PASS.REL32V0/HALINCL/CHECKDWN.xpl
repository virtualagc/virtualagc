 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKDWN.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/************************************************************/                  00001000
/*                                                          */                  00002000
/*  FUNCTION:                                               */                  00003000
/*  ERROR ROUTINE TO DETERMINE DOWNGRADES FOR SYNTAX ERRORS */                  00004000
/*                                                          */                  00005000
/*  INCLUDED BY: PASS1                                      */                  00005100
/*                                                          */                  00005200
/************************************************************/                  00006000
/*                                                          */                  00007000
/*  REVISION HISTORY                                        */                  00008000
/*                                                          */                  00009000
/*  DATE     WHO  RLS   DR/CR #  DESCRIPTION                */                  00009100
/*                                                          */                  00009200
/*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT   */                  00009300
/*                                                          */                  00009400
/*  11/05/96 LJK  28V0  DR105393 EXTRANEOUS ERRORS WHEN     */                  00009500
/*                12V0           DOWNGRADING XR3 WARNING    */                  00009600
/*  12/02/97 JAC  29V0  DR109074 DOWNGRADE OF DI21 ERROR    */                  00009700
/*                14V0           FAILS WHEN INCLUDING A     */                  00009800
/*                               REMOTELY INCLUDED COMPOOL  */                  00009900
/************************************************************/                  00010000
                                                                                00011000
CHECK_DOWN:                                                                     00020000
   PROCEDURE(ERRORCODE,SEVERITY);                                               00021000
   DECLARE (SEVERITY, K) BIT(16), IMBED BIT(1);                                 00040000
   DECLARE (C, S, CLS_COMPARE, TMP_CLS, TEMP_STMT) CHARACTER;                   00050000
   DECLARE (TEMP1, TEMP2, TEMP3, TEMP4, ERRORCODE) CHARACTER;                   00051000
   DECLARE AST CHARACTER INITIAL('***** ');                                     00060000
   DECLARE (COUNT,DOWN_COUNT) BIT(16);                                          00071000
   DECLARE FOUND BIT(1);                                                        00090000
   DECLARE TFOUND BIT(1);                                                       00100000
   FOUND = 0;                                                                   00102000
   DOWN_COUNT = RECORD_TOP(DOWN_INFO);               /* DR105393 */             00103000
   /* FOR 'INCLUDE TEMPLATE' AND 'INCLUDE SDF' USE SAVED STMT NUM */            00104000
   IF INCLUDE_STMT ^= -1 THEN DO;                       /*DR109074*/            00105000
      TEMP_STMT = INCLUDE_STMT;                         /*DR109074*/            00106000
      SAVE_LINE_#(ERROR_COUNT) = INCLUDE_STMT;          /*DR109074*/            00107000
   END;                                                 /*DR109074*/            00108000
   ELSE DO;                                             /*DR109074*/            00109000
      TEMP_STMT = STMT_NUM;                             /*DR109074*/            00110000
      IF DWN_VER(DOWN_COUNT) = 1 THEN DOWN_COUNT = 0;   /*DR109074*/            00120000
   END;                                                 /*DR109074*/            00130000
   /*  DETERMINE IF THERE IS A DOWNGRADE FOR THIS STMT  */                      00220000
   /*  CR 11088  CHANGE HARDCODED 10 TO RECORD_TOP(DOWN_INFO) */                00221000
   DO WHILE FOUND = 0 & DOWN_COUNT > 0;              /* DR105393 */             00230000
    IF TEMP_STMT = DWN_STMT(DOWN_COUNT) THEN DO;     /* DR105393 */             00231000
     TFOUND = 0;                                                                00240000
     COUNT = 0;                                                                 00241000
     DO WHILE TFOUND = 0 & COUNT < NUM_ERR;          /* DR105393 */             00242000
        IF DWN_CLS(DOWN_COUNT) = ERR_VALUE(COUNT) THEN DO;                      00243000
           TMP_CLS = SUBSTR(ERROR_INDEX(COUNT),6,2);                            00244000
           TFOUND = 1;                                                          00245000
        END;                                                                    00246000
        ELSE DO;                                                                00247000
           COUNT = COUNT + 1;                                                   00248000
        END;                                                                    00249000
     END;                                                                       00249100
     TEMP1 =  SUBSTR(TMP_CLS,0,1);                                              00249300
     TEMP2 =  SUBSTR(TMP_CLS,1,1);                                              00249500
     IF TEMP2 = ' 'THEN                                                         00249700
        CLS_COMPARE = TEMP1 || DWN_ERR(DOWN_COUNT);                             00249800
      ELSE                                                                      00250100
        CLS_COMPARE = TMP_CLS || DWN_ERR(DOWN_COUNT);                           00250200
      TEMP3 = PAD(ERRORCODE,10);                                                00250500
      TEMP4 = PAD(CLS_COMPARE,10);                                              00250600
      IF TEMP3 = TEMP4 THEN DO;                                                 00250900
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
      END;                                                                      00264000
    END;                                             /* DR105393 */             00264300
    ELSE DO;                                         /* DR105393 */             00264400
         /* DOWN_COUNT FROM HERE ON POINTS TO THE PREVIOUS                      00264500
            STATEMENT. THE STATEMENT DOES NOT HAVE A DOWNGRADE                  00264600
            DIRECTIVE FOR THE PROCESSING ERROR.      -- DR105393 */             00264700
         FOUND = 1;                                  /* DR105393 */             00264900
    END;                                             /* DR105393 */             00265200
    DOWN_COUNT = DOWN_COUNT - 1;                     /* DR105393 */             00265300
   END; /* DO WHILE */                                                          00266000
   RETURN SEVERITY;                                                             00440000
END CHECK_DOWN;                                                                 00561000
                                                                                00570000
