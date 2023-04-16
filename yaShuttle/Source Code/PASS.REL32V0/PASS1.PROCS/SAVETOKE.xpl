 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVETOKE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  SAVE_TOKEN                                             */
 /* MEMBER NAME:     SAVETOKE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          TOKEN             BIT(16)                                      */
 /*          CHAR              CHARACTER;                                   */
 /*          TYPE              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ACTUAL_PRINTING_ENABLED  BIT(16)                               */
 /*          BCD_PTR_CHECK(1528)  LABEL                                     */
 /*          OUTPUT_STACK_RELOCATE(1542)  LABEL                             */
 /*          STMT_PTR_CHECK    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          INCLUDE_LIST                                                   */
 /*          OUTPUT_STACK_MAX                                               */
 /*          PRINTING_ENABLED                                               */
 /*          RESERVED_WORD                                                  */
 /*          SAVE_BCD_MAX                                                   */
 /*          SP                                                             */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTR_LOC                                                       */
 /*          BCD_PTR                                                        */
 /*          COMMENT_COUNT                                                  */
 /*          ELSEIF_PTR                                                     */
 /*          ERROR_PTR                                                      */
 /*          GRAMMAR_FLAGS                                                  */
 /*          I                                                              */
 /*          LAST_WRITE                                                     */
 /*          SAVE_BCD                                                       */
 /*          SQUEEZING                                                      */
 /*          STACK_PTR                                                      */
 /*          STMT_PTR                                                       */
 /*          STMT_STACK                                                     */
 /*          SUPPRESS_THIS_TOKEN_ONLY                                       */
 /*          TOKEN_FLAGS                                                    */
 /*          WAIT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          OUTPUT_WRITER                                                  */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          SCAN                                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SAVE_TOKEN <==                                                      */
 /*     ==> OUTPUT_WRITER                                                   */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MIN                                                         */
 /*         ==> MAX                                                         */
 /*         ==> BLANK                                                       */
 /*         ==> LEFT_PAD                                                    */
 /*         ==> I_FORMAT                                                    */
 /*         ==> CHECK_DOWN                                                  */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 11/22/96 LJK  28V0,  109035  NESTED REPLACE MACROS ARE NOT PRINTED      */
 /*               12V0           CORRECTLY                                  */
 /*                                                                         */
 /* 04/22/98 SMR  29V0, CR12940  ENHANCE THE COMPILER LISTING               */
 /*               14V0                                                      */
 /* 03/03/98 LJK  29V0,  109076  REPLACE MACRO SPLIT ON TWO LINES           */
 /*               14V0                                                      */
 /*                                                                         */
 /* 10/15/97 JAC  29V0,  109065  OVERPUNCH CHARACTER IS MISSING             */
 /*               14V0           POINTER EXT_P REPOSITIONED                 */
 /*                                                                         */
 /* 11/22/99 JAC  30V0,  111326  STATEMENTS PRINTED INCORRECTLY AFTER       */
 /*               15V0           REPLACE MACRO                              */
 /*                                                                         */
 /* 04/08/99 JAC  30V0,  111320  INCORRECTLY PRINTED EXPONENT IN            */
 /*               15V0           OUTPUT LISTING                             */
 /*                                                                         */
 /* 04/20/99 DCP  30V0,  111319  LONG IF-THEN STATEMENTS INCORRECTLY        */
 /*               15V0           PRINTED IN OUTPUT LISTING                  */
 /*                                                                         */
 /* 04/20/99 DCP  30V0,  111329  NESTED IF-THEN STATEMENTS INCORRECTLY      */
 /*               15V0           PRINTED                                    */
 /*                                                                         */
 /* 09/20/03 DCP  32V0,  120227  INCORRECT INCLUDE COUNT IN COMPILATION     */
 /*               17V0           LISTING                                    */
 /***************************************************************************/
SAVE_TOKEN:                                                                     00399705
   PROCEDURE(TOKEN, CHAR, TYPE, MACRO_ARG);        /* DR109076 */               00399800
      DECLARE (TOKEN, TYPE) BIT(16), CHAR CHARACTER;                            00399900
      DECLARE ACTUAL_PRINTING_ENABLED BIT(16);                                  00400000
      DECLARE MACRO_ARG BIT(1);                    /* DR109076 */               00400000
      IF ^INCLUDE_LIST THEN DO;                                                 00400100
         COMMENT_COUNT, STACK_PTR(SP) = -1;  /* DR 144, DR 364 */               00400200
         RETURN;                                                                00400300
      END;                                                                      00400400
OUTPUT_STACK_RELOCATE:                                                          00400500
      PROCEDURE;                                                                00400600
         DECLARE PTR BIT(16);                                                   00400700
         IF STMT_PTR < 0 THEN                                                   00400800
            RETURN;                                                             00400900
         IF LAST_WRITE > 0 THEN                                                 00401000
            DO;                                                                 00401100
            PTR = LAST_WRITE;                                                   00401200
            IF IF_FLAG THEN DO;                                   /*DR111329*/
               SAVE1 = 0;                                         /*DR111329*/
               SAVE2 = SAVE2 - PTR;                               /*DR111329*/
            END;                                                  /*DR111329*/
            LAST_WRITE = 0;                                                     00401300
         END;                                                                   00401400
         ELSE IF IF_FLAG THEN DO;                                  /*DR111319*/
            SAVE_SRN2 = SRN(2);                                    /*DR111319*/
            SRN(2) = SAVE_SRN1;                                    /*DR111319*/
            SAVE_SRN_COUNT2 = SRN_COUNT(2);                        /*DR120227*/
            SRN_COUNT(2) = SAVE_SRN_COUNT1;                        /*DR120227*/
            STMT_NUM = STMT_NUM - 1;                               /*DR111319*/
            IF_FLAG = FALSE;                                       /*DR111319*/
            PTR = OUTPUT_WRITER(SAVE1,SAVE2);                      /*DR111319*/
            STMT_NUM = STMT_NUM + 1;                               /*DR111319*/
            SRN(2) = SAVE_SRN2;                                    /*DR111319*/
            SRN_COUNT(2) = SAVE_SRN_COUNT2;                        /*DR120227*/
         /* IF SAVE2 > PTR THEN THE ENTIRE IF STATEMENT HAS NOT    /*DR111319*/
         /* BEEN PRINTED YET.                                      /*DR111319*/
            IF (SAVE2 > PTR) THEN DO;                              /*DR111319*/
               IF_FLAG = TRUE;                                     /*DR111319*/
               SAVE1 = 0;                                          /*DR111319*/
               SAVE2 = SAVE2 - PTR;                                /*DR111319*/
            END;                                                   /*DR111319*/
            ELSE INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;        /*DR111319*/
         END;                                                      /*DR111319*/
         ELSE PTR = OUTPUT_WRITER;                                              00401500
         BCD_PTR = 0;                                                           00401600
         DO STMT_PTR = 0 TO STMT_PTR - PTR;                                     00401700
            I = STMT_PTR + PTR;                                                 00401800
            STMT_STACK(STMT_PTR) = STMT_STACK(I);                               00401900
            RVL_STACK1(STMT_PTR) = RVL_STACK1(I);      /*CR12940*/
            RVL_STACK2(STMT_PTR) = RVL_STACK2(I);      /*CR12940*/
            GRAMMAR_FLAGS(STMT_PTR) = GRAMMAR_FLAGS(I);                         00402000
            TOKEN_FLAGS(STMT_PTR) = TOKEN_FLAGS(I);                             00402100
            ERROR_PTR(STMT_PTR) = ERROR_PTR(I);                                 00402110
            IF SHR(TOKEN_FLAGS(STMT_PTR), 6) ^= 0 THEN                          00402200
               DO;                                                              00402300
               BCD_PTR = BCD_PTR + 1;                                           00402400
               SAVE_BCD(BCD_PTR) = SAVE_BCD(SHR(TOKEN_FLAGS(STMT_PTR),6));      00402500
               TOKEN_FLAGS(STMT_PTR) = (TOKEN_FLAGS(STMT_PTR) & "3F") |         00402600
                  SHL(BCD_PTR, 6);                                              00402700
            END;                                                                00402800
         END;                                                                   00402900
         IF FACTOR_FOUND THEN                                      /*DR111320*/
            GRAMMAR_FLAGS(1)=GRAMMAR_FLAGS(1) | ATTR_BEGIN_FLAG;   /*DR111320*/
         DO I = 0 TO SP - 1;                                                    00403000
            IF STACK_PTR(I) < PTR THEN                                          00403100
            DO;                                                    /*DR111320*/
               IF  ^(FACTORING & STACK_PTR(I)=1) THEN              /*DR111320*/
               STACK_PTR(I) = -1;                                               00403200
            END;                                                   /*DR111320*/
            ELSE                                                                00403300
               STACK_PTR(I) = STACK_PTR(I) - PTR;                               00403400
         END;                                                                   00403500
         IF ELSEIF_PTR < PTR THEN                                               00403510
            ELSEIF_PTR = -1;                                                    00403520
         ELSE ELSEIF_PTR = ELSEIF_PTR - PTR;                                    00403530
         DO I = 2 TO PTR_TOP;                /*DR109065*/
            IF EXT_P(I) ^= 0 THEN            /*DR109065*/
               EXT_P(I) = EXT_P(I) - PTR;    /*DR109065*/
         END;                                /*DR109065*/
      END OUTPUT_STACK_RELOCATE;                                                00403600
      STMT_PTR = STMT_PTR + 1;                                                  00403700
STMT_PTR_CHECK:                                                                 00403800
      IF STMT_PTR > OUTPUT_STACK_MAX THEN                                       00403900
         DO;                                                                    00404000
         STMT_PTR = OUTPUT_STACK_MAX;                                           00404100
         SQUEEZING = TRUE;                                                      00404200
         CALL OUTPUT_STACK_RELOCATE;                                            00404300
         IF ATTR_LOC > 0 THEN ATTR_LOC = 0;               /*DR111320*/          00404400
         GO TO STMT_PTR_CHECK;                                                  00404600
      END;                                                                      00404700
      TOKEN_FLAGS(STMT_PTR) = TYPE;                                             00404800
      IF ^RESERVED_WORD THEN                                                    00404900
         IF PRINTING_ENABLED > 0 THEN         /*DR111326*/
         DO; /* NOT IN V TABLE, SO SAVE IT */                                   00405000
BCD_PTR_CHECK:                                                                  00405100
         BCD_PTR = BCD_PTR + 1;                                                 00405200
         IF BCD_PTR > SAVE_BCD_MAX THEN                                         00405300
            DO;                                                                 00405400
            SQUEEZING = TRUE;                                                   00405500
            STMT_PTR = STMT_PTR - 1;                                            00405510
            CALL OUTPUT_STACK_RELOCATE;                                         00405600
            IF ATTR_LOC > 0 THEN ATTR_LOC = 0;            /*DR111320*/          00405700
            GO TO BCD_PTR_CHECK;                                                00405900
         END;                                                                   00406000
         SAVE_BCD(BCD_PTR) = CHAR;                                              00406100
         TOKEN_FLAGS(STMT_PTR) = TYPE | SHL(BCD_PTR, 6);                        00406110
         TOKEN_FLAGS(STMT_PTR) = TOKEN_FLAGS(STMT_PTR) | SHL(BCD_PTR, 6);       00406200
      END;                                                                      00406300
      STMT_STACK(STMT_PTR) = TOKEN;                                             00406400
      IF ^INCLUDING THEN DO;                                /*CR12940*/
      /*SAVE EACH BYTE OF RVL INTO CORRESPONDING ARRAY.  THIS ALLOWS */
      /*EACH TOKEN TO HAVE AN RVL ASSOCIATED WITH IT.  THESE ARRAYS  */
      /*ARE USED IN OUTPUT_WRITER TO PRINT THE MOST RECENT RVL.      */
        RVL_STACK1(STMT_PTR) = BYTE(RVL,0);                 /*CR12940*/
        RVL_STACK2(STMT_PTR) = BYTE(RVL,1);                 /*CR12940*/
      /*ASSIGN RVL THE RVL ASSOCIATED WITH THE FIRST CHARACTER OF THE*/
      /*NEXT LINE.                                                   */
        RVL = NEXT_CHAR_RVL;                                /*CR12940*/
      END;                                                  /*CR12940*/
      ERROR_PTR(STMT_PTR) = -1;                                                 00406410
      IF WAIT THEN DO;                                 /* DR109035 */           00406500
         WAIT = FALSE;                                 /* DR109035 */
         ACTUAL_PRINTING_ENABLED = 0;                  /* DR109035 */
      END;                                             /* DR109035 */
      ELSE ACTUAL_PRINTING_ENABLED = PRINTING_ENABLED;                          00406600
      IF SUPPRESS_THIS_TOKEN_ONLY THEN DO;                                      00406700
         SUPPRESS_THIS_TOKEN_ONLY, GRAMMAR_FLAGS(STMT_PTR) = 0;                 00406800
      END;                                                                      00406900
      ELSE                                                                      00407000
         GRAMMAR_FLAGS(STMT_PTR) = ACTUAL_PRINTING_ENABLED;                     00407100
      IF TYPE ^= 7 THEN  /* DON'T POINT AT REPLACES */                          00407200
         IF ^MACRO_ARG THEN  /* DON'T POINT AT REPLACE ARG *DR109076*/          00407100
            STACK_PTR(SP) = STMT_PTR;                                           00407210
      MACRO_ARG = FALSE;                                  /*DR109076*/
   END SAVE_TOKEN;                                                              00407300
