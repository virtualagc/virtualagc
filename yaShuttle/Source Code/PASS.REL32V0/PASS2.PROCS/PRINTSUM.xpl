 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSUM.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  PRINTSUMMARY                                           */
/* MEMBER NAME:     PRINTSUM                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          STACK_DUMP        LABEL                                        */
/*          FORM_UP           CHARACTER                                    */
/*          SYT_DUMP          LABEL                                        */
/*          T                 FIXED                                        */
/*          TEMPLATE_DUMP     LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BLANK                                                          */
/*          CLASS_BI                                                       */
/*          CODE_LISTING_REQUESTED                                         */
/*          ERROR#                                                         */
/*          EXTENT                                                         */
/*          FOR                                                            */
/*          FULLTEMP                                                       */
/*          LIT_CHAR_SIZE                                                  */
/*          LIT_CHAR_USED                                                  */
/*          MAXTEMP                                                        */
/*          NAME_FLAG                                                      */
/*          OBJECT_INSTRUCTIONS                                            */
/*          OBJECT_MACHINE                                                 */
/*          OPCOUNT                                                        */
/*          OPMAX                                                          */
/*          PP                                                             */
/*          PROC_LEVEL                                                     */
/*          PROCLIMIT                                                      */
/*          PROGCODE                                                       */
/*          PROGDATA                                                       */
/*          PROGPOINT                                                      */
/*          P2SYMS                                                         */
/*          SREF                                                           */
/*          STACK_MAX                                                      */
/*          STACK_SIZE                                                     */
/*          STATNOLIMIT                                                    */
/*          STATNO                                                         */
/*          STRUCT_START                                                   */
/*          SYM_ADDR                                                       */
/*          SYM_BASE                                                       */
/*          SYM_DISP                                                       */
/*          SYM_FLAGS                                                      */
/*          SYM_LEVEL                                                      */
/*          SYM_LINK1                                                      */
/*          SYM_LINK2                                                      */
/*          SYM_NAME                                                       */
/*          SYM_TAB                                                        */
/*          SYT_ADDR                                                       */
/*          SYT_BASE                                                       */
/*          SYT_DISP                                                       */
/*          SYT_FLAGS                                                      */
/*          SYT_LEVEL                                                      */
/*          SYT_LINK1                                                      */
/*          SYT_LINK2                                                      */
/*          SYT_NAME                                                       */
/*          TOGGLE                                                         */
/*          UPPER                                                          */
/*          VALS                                                           */
/*          XTNT                                                           */
/*          X2                                                             */
/*          X3                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CLOCK                                                          */
/*          COMMON_RETURN_CODE                                             */
/*          COMM                                                           */
/*          MAX_SEVERITY                                                   */
/*          OP2                                                            */
/*          SEVERITY                                                       */
/*          STACK_PTR                                                      */
/*          STRUCT_LINK                                                    */
/*          TMP                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          DOWNGRADE_SUMMARY                                              */
/*          ERRORS                                                         */
/*          FORMAT                                                         */
/*          HEX                                                            */
/*          INSTRUCTION                                                    */
/*          PRINT_DATE_AND_TIME                                            */
/*          PRINT_TIME                                                     */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINTSUMMARY <==                                                    */
/*     ==> FORMAT                                                          */
/*     ==> HEX                                                             */
/*     ==> INSTRUCTION                                                     */
/*         ==> CHAR_INDEX                                                  */
/*         ==> PAD                                                         */
/*     ==> DOWNGRADE_SUMMARY                                               */
/*     ==> ERRORS                                                          */
/*         ==> NEXTCODE                                                    */
/*             ==> DECODEPOP                                               */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> POPCODE                                             */
/*                 ==> POPNUM                                              */
/*                 ==> POPTAG                                              */
/*             ==> AUX_SYNC                                                */
/*                 ==> GET_AUX                                             */
/*                 ==> AUX_LINE                                            */
/*                     ==> GET_AUX                                         */
/*                 ==> AUX_OP                                              */
/*                     ==> GET_AUX                                         */
/*         ==> RELEASETEMP                                                 */
/*             ==> SETUP_STACK                                             */
/*             ==> CLEAR_REGS                                              */
/*                 ==> SET_LINKREG                                         */
/*         ==> COMMON_ERRORS                                               */
/*     ==> PRINT_TIME                                                      */
/*     ==> PRINT_DATE_AND_TIME                                             */
/*         ==> PRINT_TIME                                                  */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 03/04/91 RAH  23V2  CR11109  CLEANUP OF COMPILER SOURCE CODE            */
 /*                                                                         */
 /* 05/07/92 JAC   7V0  CR11114  MERGE BFS/PASS COMPILERS                   */
 /*                                                                         */
 /* 06/28/95 DAS  26V0  CR12416  IMPROVE COMPILER ERROR PROCESSING          */
 /*               11V0                                                      */
 /*                                                                         */
 /* 06/09/97 DCP  28V0  DR107716 MULTIPLE ENTRIES FOR SAME MNEMONIC         */
 /*               12V0           IN INSTRUCTION COUNT                       */
 /*                                                                         */
 /* 02/11/96 SMR  28V0  CR12713  ENHANCE COMPILER LISTING                   */
 /*               12V0                                                      */
 /*                                                                         */
 /* 10/15/96 KHP  28V0  105070   DATA COUNT IN LISTING MISSING #R           */
 /*               12V0                                                      */
 /*                                                                         */
 /* 01/05/98 DCP  29V0  CR12940  ENHANCE COMPILER LISTING                   */
 /*               14V0                                                      */
 /* 03/05/98 HFG  29V0  109082   PASS2 STRUCTURE TEMPLATE INCORRECT         */
 /*               14V0           IN LISTING                                 */
 /*                                                                         */
 /* 04/03/00 DCP  30V0  CR13273  PRODUCE SDF MEMBER WHEN OBJECT MODULE      */
 /*               15V0           CREATED                                    */
 /*                                                                         */
 /* 03/22/04 TKN  32V0  CR13670  ENHANCE & UPDATE INFORMATION ON THE USAGE  */
 /*               17V0           OF TYPE 2 OPTIONS                          */
 /*                                                                         */
 /* 09/10/02 JAC  32V0  CR13570  CREATE NEW %MACRO TO PERFORM ZEROTH        */
 /*               17V0           ELEMENT CALCULATIONS                       */
 /*                                                                         */
 /***************************************************************************/
                                                                                07066500
 /* SUBROUTINE FOR PRINTING AN ACTIVITY SUMMARY */                              07067000
PRINTSUMMARY:                                                                   07067500
   PROCEDURE;                                                                   07068000
      DECLARE T FIXED;                                                          07068500
      BASED SORT_TAB RECORD DYNAMIC: PTR BIT(16), HDR BIT(4),  /*MOD-CR12940*/
                                     T_PTR BIT(16), END;           /*CR12940*/
      DECLARE SORT1(1) LITERALLY 'SORT_TAB(%1%).PTR';  /*CR12713*/
      DECLARE HDR1(1) LITERALLY 'SORT_TAB(%1%).HDR';   /*CR12713*/
      DECLARE (SORT_COUNT,BIGV) BIT(16);               /*CR12713*/
      DECLARE T_SORT(1) LITERALLY 'SORT_TAB(%1%).T_PTR';           /*CR12940*/

 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHANGE #Z TO SEPARATE OBJECT MODULE */
      DECLARE REPLACED CHARACTER INITIAL('REPLACED'),
              CREATED  CHARACTER INITIAL('CREATED') ;
 ?/
                                                                                07069000
 /* LOCAL ROUTINE TO DUMP SYMBOL TABLE  */                                      07069500
SYT_DUMP:                                                                       07070000
      PROCEDURE;                                                                07070500
         DECLARE (PTR, I) BIT(16), MSG CHARACTER;                               07071000
         DECLARE HDG CHARACTER                              /*CR13570,CR12713*/ 07071500
           INITIAL('-  LOC    B DISP     LENGTH    BIAS   NAME');/*70,CR12713*/ 07071500
         DECLARE LENGTHI BIT(16);                                   /*CR12713*/ 07071500
/*CR12713 - LOCAL ROUTINE TO PUT PTR VALUES INTO TABLE THAT*/
/*IS SORTED BY SYT_ADDR LATER. THE TABLE WILL BE USED TO PRINT*/
/*ALIGNMENT GAP INFORMATION*/
INSERT_ELEMENT:
      PROCEDURE(BLOCK_DATA);
         DECLARE BLOCK_DATA BIT(1);
         IF (I>= PROGPOINT) THEN DO;
           IF BLOCK_DATA THEN DO;
             IF CALL#(I) ^= 2 THEN DO;
                NEXT_ELEMENT(SORT_TAB);
                IF CALL#(I) =  4 THEN HDR1(SORT_COUNT) = 5;
                ELSE HDR1(SORT_COUNT) = 2;
                SORT1(SORT_COUNT) = PTR;
                SORT_COUNT = SORT_COUNT + 1;
              END;
            END;
            ELSE DO;
              IF (CSECT_TYPE(PTR)=LOCAL#D)|(CSECT_TYPE(PTR)=COMPOOL#P) THEN DO;
                 NEXT_ELEMENT(SORT_TAB);
                 HDR1(SORT_COUNT) =  0;
                 SORT1(SORT_COUNT) = PTR;
                 BIGV=MAX(LENGTH(SYT_NAME(PTR)),BIGV);
                 SORT_COUNT = SORT_COUNT + 1;
              END;
            END;
          END;
END INSERT_ELEMENT;

         /*CR12713 - PRINT TITLE AND COLUMN DESCRIPTIONS OF TABLE.          */
         OUTPUT(1) = '  VARIABLE OFFSET TABLE';                    /*CR12713*/
         OUTPUT(1) = '     LOC IS THE CSECT-RELATIVE ADDRESS IN'   /*CR12713*/
            ||' HEX OF THE DECLARED VARIABLE.';                    /*CR12713*/
         OUTPUT(1) = '     B IS THE BASE REGISTER USED FOR ADDRESS'/*CR12713*/
            ||'ING THE DECLARED VARIABLE.  IF B IS NEGATIVE, THIS' /*CR12713*/
            ||' IS A VIRTUAL REGISTER AND CODE';                   /*CR12713*/
         OUTPUT(1) = '           MUST BE GENERATED TO LOAD A REAL '/*CR12713*/
            ||'REGISTER.';                                         /*CR12713*/
         OUTPUT(1) = '     DISP IS THE DISPLACEMENT USED FOR GENER'/*CR12713*/
            ||'ATING BASE-DISPLACEMENT ADDRESSES FOR ACCESSING THE'/*CR12713*/
            ||' DATA ITEMS.';                                      /*CR12713*/
         OUTPUT(1) = '     LENGTH IS THE SIZE IN DECIMAL HALFWORDS'/*CR12713*/
            ||' OF THE VARIABLE.';                                 /*CR12713*/
         OUTPUT(1) = '     BIAS IS THE AMOUNT OF THE ZEROTH ELEMEN'/*CR13570*/
            ||'T OFFSET.';                                         /*CR13570*/
         OUTPUT(1) = '     NAME IS THE NAME OF THE VARIABLE.';     /*CR12713*/
                                                                                07072000
         OUTPUT(1) = HDG;                                                       07072000
         ALLOCATE_SPACE(SORT_TAB, 10);                             /*CR12713*/
         NEXT_ELEMENT(SORT_TAB);                                   /*CR12713*/
         SORT_COUNT = 1; BIGV = 20;                                /*CR12713*/
         DO I = 1 TO PROCLIMIT;                                                 07072500
            PTR = PROC_LEVEL(I);                                                07073000
            CALL INSERT_ELEMENT(TRUE);                             /*CR12713*/
            IF I < PROGPOINT THEN MSG = '';                                     07073500
            ELSE MSG = '     STACK='||MAXTEMP(I);                               07074000
            OUTPUT(1) = '0         UNDER '||SYT_NAME(PTR)||MSG;                 07074500
            PTR = SYT_LEVEL(PTR);                                               07075000
            DO WHILE PTR > 0;
               IF (SYT_FLAGS(PTR) & NAME_FLAG) ^= 0 THEN DO;         /*CR12713*/
                  IF (SYT_FLAGS(PTR) & REMOTE_FLAG) ^= 0 THEN        /*CR12713*/
                     LENGTHI = 2;                                    /*CR12713*/
                  ELSE LENGTHI = 1;                                  /*CR12713*/
               END;                                                  /*CR12713*/
               ELSE LENGTHI = EXTENT(PTR);                           /*CR12713*/
               IF SYT_DISP(PTR) >= 0 THEN DO;
                  CALL INSERT_ELEMENT(FALSE);                        /*CR12713*/
                  MSG = HEX(SYT_DISP(PTR), 3);
                  MSG = FORMAT(SYT_BASE(PTR), 3) || BLANK || MSG;
                  MSG=MSG||X3;                                                  07077010
                  OUTPUT=HEX(SYT_ADDR(PTR),6)||BLANK||MSG||          /*CR12713*/
                    FORMAT(LENGTHI,8)||FORMAT(-SYT_CONST(PTR),8)||   /*CR13570*/
                    X4||SYT_NAME(PTR);                               /*CR12713*/
               END;                                                              7077100
               ELSE IF ^SREF THEN                                                7077200
                  OUTPUT = HEX(SYT_ADDR(PTR), 6)||'           '||    /*CR12713*/
                    FORMAT(LENGTHI,8)||FORMAT(-SYT_CONST(PTR),8)||   /*CR13570*/
                    X4||SYT_NAME(PTR);                               /*CR12713*/
               PTR = SYT_LEVEL(PTR);
            END;                                                                07078000
         END;                                                                   07078500
         SORT_COUNT = SORT_COUNT - 1;                                /*CR12713*/
      END SYT_DUMP;                                                             07079000
/* CR12713 - LOCAL ROUTINE TO PRINT ALIGNMENT GAP INFORMATION*/
/* FOR LOCAL DATA*/
ALIGN_DUMP:
    PROCEDURE;
        DECLARE (GAP,BEGIN_GAP,TOTAL_GAP) FIXED;
        DECLARE S1 CHARACTER;
        DECLARE (I,M,L,LENGTHI) BIT(16);                             /*CR12713*/
        DECLARE LM LABEL;
        OUTPUT = ' ';
/*SORT TABLE*/
        M = SHR(SORT_COUNT, 1);
        DO WHILE M > 0;
          DO L = 1 TO SORT_COUNT - M;
             I = L;
             DO WHILE (SYT_ADDR(SORT1(I)) > SYT_ADDR(SORT1(I+M)));
                L = SORT1(I);
                SORT1(I) = SORT1(I + M);
                SORT1(I + M) = L;
                L = HDR1(I);
                HDR1(I) = HDR1(I + M);
                HDR1(I + M) = L;
                I = I - M;
                IF I < 1 THEN GO TO LM;
             END;  /*DO WHILE STRING_GT */
LM:
          END;  /* DO L */
          M = SHR(M, 1);
        END;   /* DO WHILE M */
        /*PRINT TABLE*/
        TOTAL_GAP = 0;
        S1 = PAD('NAME',BIGV)||'  LEN(DEC)  OFFSET(DEC)   B  DISP(HEX)  SCOPE';
        OUTPUT(1) = '1';
        OUTPUT(1) = '0MEMORY MAP FOR DATA CSECT '||ESD_TABLE(DATABASE);
        OUTPUT(1) = '0'||S1;
        OUTPUT(1) = '';
        OUTPUT(1) = '2'||S1;
        DO I = 1 TO SORT_COUNT;
           IF (SYT_FLAGS(SORT1(I)) & NAME_FLAG) ^= 0 THEN DO;        /*CR12713*/
              IF (SYT_FLAGS(SORT1(I)) & REMOTE_FLAG) ^= 0 THEN LENGTHI = 2;/*"*/
              ELSE LENGTHI = 1;                                      /*CR12713*/
           END;                                                      /*CR12713*/
           ELSE LENGTHI = EXTENT(SORT1(I));                          /*CR12713*/
           IF HDR1(I)^=0 THEN DO;
              S1 = PAD('**LOCAL BLOCK DATA**',BIGV)||X2;
              S1 = S1||FORMAT(HDR1(I),7)||X3;
              S1 = S1||FORMAT(SYT_ADDR(SORT1(I)),7)||PAD(X3,21);
              S1 = S1||SYT_NAME(PROC_LEVEL(SYT_SCOPE(SORT1(I))));
           END;
           ELSE DO;
              S1 = PAD(SYT_NAME(SORT1(I)),BIGV);
              S1 = S1||X2||FORMAT(LENGTHI,7)||X3;                   /*CR12713*/
              S1 = S1||FORMAT(SYT_ADDR(SORT1(I)),7)||X2||X3;
              S1 = S1||FORMAT(SYT_BASE(SORT1(I)),3)||X4;
              S1 = S1||HEX(SYT_DISP(SORT1(I)),4)||X3||X2;
              S1 = S1||SYT_NAME(PROC_LEVEL(SYT_SCOPE(SORT1(I))));
           END;
           OUTPUT = S1;
           /*PRINT ALIGNMENT GAP INFORMATION*/
           IF I<SORT_COUNT THEN DO;
              BEGIN_GAP=SYT_ADDR(SORT1(I))+LENGTHI+HDR1(I);         /*CR12713*/
              GAP = SYT_ADDR(SORT1(I+1))-BEGIN_GAP;
              IF GAP > 0 THEN DO;
                 TOTAL_GAP = TOTAL_GAP + GAP;
                 OUTPUT = PAD('**ALIGNMENT GAP**',BIGV)||X2||FORMAT(GAP,7)||X3
                          ||FORMAT(BEGIN_GAP,7);
              END;
           END;
        END;
        OUTPUT = '';
        OUTPUT ='TOTAL SIZE OF ALIGNMENT GAPS FOR CSECT: '||TOTAL_GAP||' HW';
        OUTPUT = '';
        OUTPUT(1) = '2 ';
        RECORD_FREE(SORT_TAB);
END ALIGN_DUMP;

/* LOCAL ROUTINE TO PRINT STACK SIZES ONLY */
STACK_DUMP:                                                                     07080500
      PROCEDURE;                                                                07081000
         DECLARE I BIT(16);                                                     07081500
         OUTPUT(1) = '- STACK   NAME';                                          07082000
         DO I = PROGPOINT TO PROCLIMIT;                                         07082500
            OUTPUT = FORMAT(MAXTEMP(I),6)||X2||SYT_NAME(PROC_LEVEL(I));         07083000
         END;                                                                   07083500
         DO I = 0 TO OPMAX;                                                     07084000
            OBJECT_INSTRUCTIONS = OBJECT_INSTRUCTIONS + OPCOUNT(I);             07084500
         END;                                                                   07085000
      END STACK_DUMP;                                                           07085500
                                                                                07086000
 /* LOCAL ROUTINE TO DUMP STRUCTURE TEMPLATE LAYOUTS AND SIZES */               07086500
TEMPLATE_DUMP:                                                                  07087000
      PROCEDURE;                                                                07087500
         DECLARE HDG CHARACTER                                                  07088000
            INITIAL ('-  LOC     SIZE     BIAS  NAME'),            /*CR13570*/  07088000
            MSG CHARACTER;                                                      07088500
         DECLARE LENGTHI BIT(16);                                  /*CR12940*/

 /* ROUTINE TO CALCULATE THE TEMPLATE'S ACTUAL LENGTH.             /*CR12940*/
CALC_TEMPL_LENGTH:
      PROCEDURE;
         DECLARE NUM BIT(16);
         DECLARE (L, INDX, I, TEMP) BIT(16);
         NUM = SYT_LINK1(OP2);
         L = 0;
         DO WHILE NUM ^= 0;
           IF SYT_LINK1(NUM) ^= 0 THEN
             NUM = SYT_LINK1(NUM);
           ELSE DO;
             L = L + 1;
             NEXT_ELEMENT(SORT_TAB);
             T_SORT(L) = NUM;
             NUM = SYT_LINK2(NUM);
           END;
           DO WHILE NUM < 0;
             NUM = SYT_LINK2(-NUM);
           END;
         END;
         /* IF TEMPLATE IS NOT RIGID THEN SORT TERMINALS */
         IF (SYT_FLAGS(OP2) & RIGID_FLAG) = 0 THEN DO;
           DO INDX = 1 TO (L-1);
             DO I = 1 TO (L-INDX);
               IF SYT_ADDR(T_SORT(INDX)) > SYT_ADDR(T_SORT(INDX+I)) THEN DO;
                 TEMP = T_SORT(INDX);
                 T_SORT(INDX) = T_SORT(INDX+I);
                 T_SORT(INDX+I) = TEMP;
               END;
             END; /* DO INDX */
           END; /* DO I */
         END;
         IF (SYT_FLAGS(T_SORT(1)) & NAME_FLAG) ^= 0 THEN DO;
           IF (SYT_FLAGS(T_SORT(1)) & REMOTE_FLAG) ^= 0 THEN
             LENGTHI = 2;
           ELSE LENGTHI = 1;
         END;
         ELSE LENGTHI = EXTENT(T_SORT(1));
         DO INDX = 1 TO (L-1);
           IF (SYT_FLAGS(T_SORT(INDX+1)) & NAME_FLAG) ^= 0 THEN DO;
             IF (SYT_FLAGS(T_SORT(INDX+1)) & REMOTE_FLAG) ^= 0 THEN
               LENGTHI = LENGTHI + 2;
             ELSE LENGTHI = LENGTHI + 1;
           END;
           ELSE IF SYT_ADDR(T_SORT(INDX)) ^= SYT_ADDR(T_SORT(INDX+1)) THEN
               LENGTHI = LENGTHI + EXTENT(T_SORT(INDX+1));
         END;
       END CALC_TEMPL_LENGTH;

         IF STRUCT_START > 0 THEN DO;                                           07089000
            STRUCT_LINK = STRUCT_START;                                         07089500
            OUTPUT(1) = '0 STRUCTURE TEMPLATE LAYOUT';             /*CR12940*/
            OUTPUT(1) = HDG;                                                    07090000
            DO WHILE STRUCT_LINK > 0;                                           07090500
               OP2 = STRUCT_LINK;                                               07091000
               SYT_LINK2(OP2) = 0; /* EXIT PNT FOR STR. WALK, DR109082*/        07091000
               OUTPUT(1) = '0         STRUCTURE' || SYT_NAME(OP2);              07091500
               LENGTHI = 0;                                        /*CR12940*/
               CALL CALC_TEMPL_LENGTH;                             /*CR12940*/
               DO WHILE OP2 > 0;                                                07092000
                  IF (SYT_FLAGS(OP2) & NAME_FLAG) ^= 0 THEN MSG = '    NAME';   07092500
                  ELSE MSG = FORMAT(EXTENT(OP2), 8);                            07093000
     /*CR13570 -  ONLY PRINT THE BIAS FOR THE NODES (NOT THE TEMPLATE) */
     /*CR13570*/  IF OP2 = STRUCT_LINK THEN MSG = MSG||'        ';
     /*CR13570*/  ELSE MSG = MSG||FORMAT(-SYT_CONST(OP2),8);
                  OUTPUT = HEX(SYT_ADDR(OP2), 6) || MSG || X3 || SYT_NAME(OP2); 07093500
                  IF SYT_LINK1(OP2) > 0 THEN                                    07094000
                     OP2 = SYT_LINK1(OP2);                                      07094500
                  ELSE OP2 = SYT_LINK2(OP2);                                    07095000
                  DO WHILE OP2 < 0;                                             07095500
                     OP2 = SYT_LINK2(-OP2);                                     07096000
                  END;                                                          07096500
               END;                                                             07097000
               OUTPUT = 'TOTAL SIZE OF ALIGNMENT GAPS FOR' ||      /*CR12940*/
                        SYT_NAME(STRUCT_LINK) || ': ' ||           /*CR12940*/
                        EXTENT(STRUCT_LINK) - LENGTHI || ' HW';    /*CR12940*/
               STRUCT_LINK = SYT_LEVEL(STRUCT_LINK);                            07097500
            END;                                                                07098000
         END;                                                                   07098500
      END TEMPLATE_DUMP;                                                        07099000
FORM_UP:                                                                        07099010
      PROCEDURE(MSG, VAL1, VAL2) CHARACTER;                                     07099020
         DECLARE (MSG, S) CHARACTER, (VAL1, VAL2) FIXED;                        07099030
         IF VAL2 > VAL1 THEN S = ' <-<-<- ';  /*CR13670*/                       07099060
         ELSE S = '';                                                           07099070
         S = FORMAT(VAL2, 8) || S;                                              07099090
         S = FORMAT(VAL1, 10) || S;                                             07099100
         RETURN MSG || S;                                                       07099110
      END FORM_UP;                                                              07099120
                                                                                07099500
      CALL MONITOR(0, 3);  /* CLOSE(3)  */                                      07100000
      IF MAX_SEVERITY < 2 THEN DO;                                              07100500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; 'AB' AND 'L' INDEPENDENT */
         IF CODE_LISTING_REQUESTED THEN DO;                                     07101000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; 'AB' AND 'L' INDEPENDENT */
      IF CODE_LISTING THEN DO;
 ?/
            CALL SYT_DUMP;                                                      07101500
            CALL TEMPLATE_DUMP;                                                 07102000
            CALL ALIGN_DUMP;                                       /*CR12713*/
            OUTPUT(1) = '-INSTRUCTION FREQUENCIES';                             07102500
            OUTPUT(1) = '0INSN  COUNT';                                         07103000
            DO T = 0 TO OPMAX;                                                  07103500
     /******************CHANGES FOR DR107716**************************/
     /* CODE IS MODIFIED SO THAT MNEMONICS ARE NOT DUPLICATED IN THE */
     /* INSTRUCTION FREQUENCY TABLE IN THE COMPILED LISTING.  SEDR & */
     /* SER APPEAR TWICE IN THE TABLE. BC AND BVC ALSO APPEAR TWICE  */
     /* IN THE TABLE, BUT THEY SHOULD BECAUSE ONE INSTRUCTION IS A   */
     /* RELATIVE BRANCH AND THE OTHER IS AN ABSOLUTE BRANCH.         */
     /* CR12940 - WHEN THE RELATIVE BC OPCODE IS GENERATED, THE BCB  */
     /* OR BCF MNEMONIC WILL BE PRINTED.  WHEN THE RELATIVE BVC      */
     /* OPCODE IS GENERATED, THE BVCF MNEMONIC WILL BE PRINTED.      */
     /****************************************************************/
               IF OPCOUNT(T) > 0 THEN DO;                           /*DR107716*/07104500
                 IF T = 39 | T = 55 THEN                            /*DR107716*/
                   OPCOUNT(T+4)= OPCOUNT(T) + OPCOUNT(T+4);         /*DR107716*/
                 ELSE IF T = 135 THEN DO;                           /*DR107716*/
                   IF BCB_COUNT > 0 THEN                            /*CR12940*/
                     OUTPUT = 'BCB   '||X2||BCB_COUNT;              /*CR12940*/
                   IF (OPCOUNT(T)-BCB_COUNT) > 0 THEN               /*CR12940*/
                     OUTPUT = 'BCF   '||X2||(OPCOUNT(T)-BCB_COUNT); /*CR12940*/
                   OBJECT_INSTRUCTIONS = OBJECT_INSTRUCTIONS + OPCOUNT(T); /*"*/
                 END;                                               /*DR107716*/
                 ELSE DO;                                           /*DR107716*/
                   OUTPUT = INSTRUCTION(T) || X2 || OPCOUNT(T);                 07105000
                   OBJECT_INSTRUCTIONS = OBJECT_INSTRUCTIONS + OPCOUNT(T); /*"*/
                 END;                                               /*DR107716*/
               END;                                                 /*DR107716*/
            END;                                                                07105500
         END;                                                                   07106000
         ELSE CALL STACK_DUMP;                                                  07106500
      END;                                                                      07107000
      OBJECT_MACHINE = 1;  /* INDICATE FC CODE GENERATOR */                     07107500
                                                                                07108000
      OUTPUT(1) = '-       OPTIONAL TABLE SIZES';                               07108010
      OUTPUT(1) = '0NAME       REQUESTED    USED';                              07108020
      OUTPUT(1) = '+____       _________    ____';                              07108030
      OUTPUT = BLANK;                                                           07108040
      OUTPUT = FORM_UP('LITSTRINGS' ,LIT_CHAR_SIZE,LIT_CHAR_USED);              07108050
      OUTPUT = FORM_UP('LABELSIZE ', STATNOLIMIT, STATNO);                      07108060
      OUTPUT=BLANK;                                                             07108500
      IF ERROR# > 0 THEN                                                        07109000
         OUTPUT='***  '||ERROR#||' ERROR(S) DETECTED IN PHASE 2';               07109500
      IF (TOGGLE&"80")=0 THEN DO;                                               07110000
         IF MAX_SEVERITY^=0 THEN OUTPUT=                                        07110500
            '***  CONVERSION ERRORS INHIBITED OBJECT MODULE GENERATION';
      END;                                                                      07111500
      ELSE DO;                                                                  07112000
         MAX_SEVERITY=3;                                                        07112500
         OUTPUT='***  PHASE 1 INHIBITED EXECUTION';                             07113000
      END;                                                                      07113500
      IF MAX_SEVERITY = 0 THEN DO;
         OUTPUT=BLANK;                                                          07114000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OUTPUT OBJECT MODULE */
         OBJECT_MODULE_NAME = 'OBJECT MODULE MEMBER ' || OBJECT_MODULE_NAME ||
        ' HAS BEEN ';
         IF (OBJECT_MODULE_STATUS & 1) ^= 0 THEN
            OBJECT_MODULE_NAME = OBJECT_MODULE_NAME || REPLACED ;
         ELSE
            OBJECT_MODULE_NAME = OBJECT_MODULE_NAME || 'CREATED';
         OUTPUT = BLANK;
         IF PCEBASE THEN DO;
         OUTPUT = OBJECT_MODULE_NAME;
         OBJECT_MODULE_NAME = SUBSTR(OBJECT_MODULE_NAME, 0, 21) ||POUND_Z||
         SUBSTR(OBJECT_MODULE_NAME,23,16);
         IF (OBJECT_MODULE_STATUS & 2) ^= 0 THEN
         OBJECT_MODULE_NAME = OBJECT_MODULE_NAME|| REPLACED;
         ELSE
         OBJECT_MODULE_NAME = OBJECT_MODULE_NAME || CREATED;
         END;
         OUTPUT = OBJECT_MODULE_NAME;
         OUTPUT = BLANK;
 ?/
         OUTPUT=PP||' HALMAT OPERATORS CONVERTED';                              07114500
         OUTPUT = BLANK;                                                        07115000
         OUTPUT = OBJECT_INSTRUCTIONS || ' INSTRUCTIONS GENERATED';             07115500
         OUTPUT=BLANK;                                                          07116000
         OUTPUT = PROGCODE || ' HALFWORDS OF PROGRAM, ' ||                      07116500
            PROGDATA+PROGDATA(1)||' HALFWORDS OF DATA.'; /* DR105070 */         07117000
      END;
      OUTPUT = BLANK;                                                           07119500
      OUTPUT='MAX. OPERAND STACK SIZE            ='||STACK_MAX;                 07120000
      T=0;                                                                      07120500
      DO WHILE STACK_PTR^=0;                                                    07121000
         STACK_PTR = STACK_PTR(STACK_PTR);                                      07121500
         T=T+1;                                                                 07122000
         IF T > STACK_SIZE THEN DO;                                             07122500
            CALL ERRORS(CLASS_BI,504);                                          07123000
            STACK_PTR = 0;                                                      07123500
         END;                                                                   07124000
      END;                                                                      07124500
      OUTPUT='END  OPERAND STACK SIZE            ='||STACK_SIZE-T;              07125000
      OUTPUT='MAX. STORAGE DESCRIPTOR STACK SIZE ='||FULLTEMP;                  07125500
      T = 0;                                                                    07126000
      DO FOR TMP = 0 TO FULLTEMP;                                               07126500
         IF UPPER(TMP) > 0 THEN                                                 07127000
            T = T + 1;                                                          07127500
      END;                                                                      07128000
 /* CALL DOWNGRADE SUMMARY */                                                   07128010
      CALL DOWNGRADE_SUMMARY;                              /* CR13273 */
      OUTPUT='END  STORAGE DESCRIPTOR STACK SIZE ='||T;                         07128500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; LISTING DIFFERENCE */
      OUTPUT='EXTERNAL SYMBOL DICTIONARY MAXIMUM ='||ESD_MAX;
 ?/
      OUTPUT='NUMBER OF MINOR COMPACTIFIES       ='||COMPACTIFIES;              07129000
      OUTPUT='NUMBER OF MAJOR COMPACTIFIES       ='||COMPACTIFIES(1);           07129500
      OUTPUT = 'NUMBER OF REALLOCATIONS            ='||REALLOCATIONS;           07129510
      OUTPUT='FREE STRING AREA                   ='||FREELIMIT-FREEBASE;        07130000
      OUTPUT=BLANK;                                                             07131000
      T = MONITOR(18);                                                          07131500
      IF CLOCK(1) = 0 THEN CLOCK(1), CLOCK(2) = T;                              07132000
      ELSE IF CLOCK(2) = 0 THEN CLOCK(2) = T;                                   07132500
      CALL PRINT_DATE_AND_TIME('END OF HAL/S PHASE 2 ',DATE,TIME);              07133000
      CALL PRINT_TIME('TOTAL CPU TIME FOR PHASE 2       ', T-CLOCK);            07133500
      CALL PRINT_TIME('CPU TIME FOR PHASE 2 SET UP      ', CLOCK(1)-CLOCK);     07134000
      CALL PRINT_TIME('CPU TIME FOR PHASE 2 GENERATION  ', CLOCK(2)-CLOCK(1));  07134500
      CALL PRINT_TIME('CPU TIME FOR PHASE 2 CLEAN UP    ', T-CLOCK(2));         07135000
   END PRINTSUMMARY;                                                            07135500
