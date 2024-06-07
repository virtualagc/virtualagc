 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTCOM.xpl
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
 
/***************************************************************************/
/*                                                                         */
/* REVISION HISTORY:                                                       */
/*                                                                         */
/* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
/*                                                                         */
/* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
/*                                                                         */
/* 12/20/96 SMR  28V0  CR12713  ENHANCE COMPILER LISTING                   */
/*               12V0                                                      */
/* 03/03/98 LJK  29V0  DR109076 REPLACE MACRO SPLIT ON TWO LINES           */
/*               14V0                                                      */
/* 09/09/99 JAC  30V0  DR111341 DO CASE STATEMENT PRINTED INCORRECTLY      */
/*               15V0           (PRINT_FLUSH REMOVED)                      */
/*                                                                         */
/* 04/20/99 DCP  30V0  DR111329 NESTED IF-THEN STATEMENTS INCORRECTLY      */
/*               15V0           PRINTED                                    */
/*                                                                         */
/* 09/20/03 DCP  32V0  DR120227 INCLUDE COUNT INCORRECT IN COMPILATION     */
/*               17V0           LISTING                                    */
/***************************************************************************/
PRINT_COMMENT:                                                                  00000100
   PROCEDURE(PRINT,CURRENT_DIR);                                 /*CR12713*/    00000110
   DECLARE PRINT BIT(1);  /* WHETHER OR NOT TO PRINT ON SYSPRINT */             00000120
   DECLARE CURRENT_DIR CHARACTER;                                /*CR12713*/
   DECLARE FORMAT_CHAR CHARACTER;                                               00000130
   DECLARE (C, T, R) CHARACTER;                                                 00000140
      FORMAT_CHAR='|';                                                          00000182
      IF ^INCLUDE_LIST2 THEN                                                    00000190
         RETURN;                                                                00000200
      I = 1;                                                                    00000210
      IF COMMENTING THEN                                                        00000220
         C = X1;                                                                00000230
      ELSE                                                                      00000240
         DO;                                                                    00000250
            SQUEEZING = FALSE;                                  /*DR111329*/
            I = 2;                                                              00000260
            C = DOUBLE;
            IF IF_FLAG THEN DO;                                 /*CR12713*/
              STMT_NUM = STMT_NUM - 1;                          /*CR12713*/
              SAVE_SRN2 = SRN(2);                               /*CR12713*/
              SRN(2) = SAVE_SRN1;                               /*CR12713*/
              SAVE_SRN_COUNT2 = SRN_COUNT(2);                  /*DR120227*/
              SRN_COUNT(2) = SAVE_SRN_COUNT1;                  /*DR120227*/
              IF_FLAG = FALSE;                                  /*CR12713*/
              CALL OUTPUT_WRITER(SAVE1,SAVE2);                  /*CR12713*/
              INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;            /*CR12713*/
              IF STMT_PTR > -1 THEN LAST_WRITE = SAVE2+1;       /*CR12713*/
              STMT_NUM = STMT_NUM + 1;                          /*CR12713*/
              SRN(2) = SAVE_SRN2;                               /*CR12713*/
              SRN_COUNT(2) = SAVE_SRN_COUNT2;                  /*DR120227*/
            END;                                                /*CR12713*/
            ELSE DO;                                            /*CR12713*/     00000280
               ELSE_FLAG = FALSE;                               /*CR12713*/     00000280
               CALL OUTPUT_WRITER(LAST_WRITE, STMT_PTR);        /*CR12713*/     00000280
            END;                                                /*CR12713*/     00000280
         END;                                                                   00000290
      S = CARD_COUNT + 1 - INCLUDE_OFFSET;                                      00000300
      S = PAD(S, 4);                                                            00000310
      /*CR12713 - PRINT THE STATEMENT NUMBER FOR D INCLUDE, PRINT BLANKS */
      /*FOR OTHER DIRECTIVES AND COMMENTS.                               */
      IF (CARD_TYPE(BYTE(CURRENT_CARD)) = CARD_TYPE(BYTE('D'))) /*CR12713*/
         & (CURRENT_DIR = 'INCLUDE') THEN                       /*CR12713*/
         R = I_FORMAT(STMT_NUM,4);                              /*CR12713*/
      ELSE R = X4;                                              /*CR12713*/     00000320
      IF INCLUDING THEN DO;                                                     00000330
         INCLUDE_CHAR = PLUS;                                                   00000340
         T = PAD1;                                              /*CR12713*/
         IF SRN_PRESENT THEN                                                    00000350
            R = PAD1;                                                           00000360
      END;                                                                      00000370
      ELSE DO;                                                                  00000380
         INCLUDE_CHAR = X1;                                                     00000390
         IF SRN_PRESENT THEN                                                    00000400
            /*CR12713 - PRINT THE STATEMENT NUMBER FOR D INCLUDE.           */
            /*IF PRINTING SRNS, ADD THE STATEMENT NUMBER TO THE SRN IN R.   */
            R = PAD(SUBSTR(CURRENT_CARD, TEXT_LIMIT + 1, 6), 7)||R;/*CR12713*/
         IF SDL_OPTION THEN DO;                                                 00000420
            T = SUBSTR(CURRENT_CARD, TEXT_LIMIT + 7, 2);                        00000430
            IF LENGTH(CURRENT_CARD) >= TEXT_LIMIT + 17 THEN                     00000440
               T = T || X1 || SUBSTR(CURRENT_CARD, TEXT_LIMIT + 9, 8);          00000450
            ELSE T = T || SUBSTR(X70, 0, 9);                                    00000460
         END;                                                                   00000470
      END;                                                                      00000480
      IF LISTING2 THEN                                                          00000490
         CALL PRINT2(C || SUBSTR(X8, 1) || INCLUDE_CHAR ||                      00000500
            SUBSTR(CURRENT_CARD, 0, 1) || VBAR ||                               00000510
            SUBSTR(CURRENT_CARD, 1) || VBAR || S || X1 || CURRENT_SCOPE, I);    00000520
      IF PRINT THEN DO;                                                         00000530
         IF LINE_MAX = 0 THEN DO;                                               00000540
            LINE_MAX = LINE_LIM;                                                00000550
            C = PAGE;                                                           00000560
         END;                                                                   00000570
         I=100-TEXT_LIMIT;                                                      00000580
         /*CR12713 - MOVE THE REVISION LEVEL TO THE FIRST 2 COLUMNS OF   */
         /*THE CURRENT SCOPE FIELD WHEN SDL_OPTION IS TRUE.          .   */
         IF SDL_OPTION THEN                                        /*CR12713*/
            S=FORMAT_CHAR||SUBSTR(T,0,2)||FORMAT_CHAR||SAVE_SCOPE; /*CR12713*/
         ELSE S=FORMAT_CHAR||SAVE_SCOPE;                           /*CR12713*/
         S=SUBSTR(CURRENT_CARD,1,TEXT_LIMIT)||SUBSTR(X70,0,I)||S;  /*CR12713*/  00000600
         OUTPUT(1)=C||R||INCLUDE_CHAR||SUBSTR(CURRENT_CARD,0,1)||               00000610
                        VBAR||S;                                                00000620
      END;                                                                      00000650
      NEXT_CC = ' ';                                               /*CR12713*/
      CURRENT_DIR = '';                                            /*CR12713*/  00000590
      PREV_ELINE = FALSE;                                          /*CR12713*/  00000590
   END PRINT_COMMENT;                                                           00000660
