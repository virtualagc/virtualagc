 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
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
 /* PROCEDURE NAME:  INITIALIZATION                                         */
 /* MEMBER NAME:     INITIALI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       AGAIN(4)          LABEL              PRO               FIXED      */
 /*       CON               FIXED              SORT1       ARRAY BIT(16)    */
 /*       ENDMFID           LABEL              SORT2       ARRAY BIT(16)    */
 /*       EQUALS            CHARACTER          STORAGE_INCREMENT FIXED      */
 /*       LOGHEAD           CHARACTER          STORAGE_MASK      FIXED      */
 /*       NO_CORE           LABEL              SUBHEAD           CHARACTER  */
 /*       NPVALS            FIXED              TYPE2             FIXED      */
 /*       NUM1_OPT          BIT(16)            TYPE2_TYPE(12)    BIT(8)     */
 /*       NUM2_OPT          BIT(16)            VALS              FIXED      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ATOM#_LIM                            LIT_NDX                      */
 /*       ATOMS                                LIT_PG                       */
 /*       BLOCK_SRN_DATA                       MACRO_TEXTS                  */
 /*       CLASS_B                              MODF                         */
 /*       CLASS_BI                             MOVEABLE                     */
 /*       CLASS_M                              NSY                          */
 /*       CONST_ATOMS                          NT                           */
 /*       CONST_DW                             NUM_DWNS                     */
 /*       CONTROL                              OPTIONS_CODE                 */
 /*       CROSS_REF                            OUTER_REF_TABLE              */
 /*       CSECT_LENGTHS                        PAGE                         */
 /*       DATE_OF_COMPILATION                  SRN_BLOCK_RECORD             */
 /*       DOUBLE                               STMT_NUM                     */
 /*       DOUBLE_SPACE                         SUBHEADING                   */
 /*       DOWN_INFO                            SYM_TAB                      */
 /*       DW_AD                                TIME_OF_COMPILATION          */
 /*       DW                                   TOKEN                        */
 /*       EJECT_PAGE                           TRUE                         */
 /*       FALSE                                UNMOVEABLE                   */
 /*       FL_NO                                VMEM_MAX_PAGE                */
 /*       IC_SIZE                              VMEMREC                      */
 /*       INCLUDE_LIST_HEAD                    VOCAB                        */
 /*       INPUT_DEV                            X1                           */
 /*       LINK_SORT                            X4                           */
 /*       LIT_BUF_SIZE                         X70                          */
 /*       LIT_CHAR_AD                          X8                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       ADDR_FIXED_LIMIT                     LRECL                        */
 /*       ADDR_FIXER                           MACRO_TEXT_LIM               */
 /*       ADDR_PRESENT                         NEXT                         */
 /*       ADDR_ROUNDER                         NEXT_ATOM#                   */
 /*       C                                    NT_PLUS_1                    */
 /*       CARD_COUNT                           ONE_BYTE                     */
 /*       CARD_TYPE                            OUTER_REF_LIM                */
 /*       CASE_LEVEL                           PAD1                         */
 /*       COMM                                 PAD2                         */
 /*       COMMENT_COUNT                        PARTIAL_PARSE                */
 /*       CUR_IC_BLK                           PROCMARK                     */
 /*       CURRENT_CARD                         S                            */
 /*       DATA_REMOTE                          SAVE_CARD                    */
 /*       FIRST_CARD                           SDL_OPTION                   */
 /*       FOR_ATOMS                            SIMULATING                   */
 /*       FOR_DW                               SP                           */
 /*       HMAT_OPT                             SREF_OPTION                  */
 /*       I                                    SRN_PRESENT                  */
 /*       IC_LIM                               STACK_DUMP_PTR               */
 /*       IC_MAX                               STATE                        */
 /*       IC_ORG                               STMT_PTR                     */
 /*       INDENT_INCR                          SYSIN_COMPRESSED             */
 /*       INPUT_REC                            SYTSIZE                      */
 /*       J                                    TABLE_ADDR                   */
 /*       K                                    TEMP1                        */
 /*       LAST                                 TEXT_LIMIT                   */
 /*       LAST_SPACE                           TPL_FLAG                     */
 /*       LINE_LIM                             TPL_LRECL                    */
 /*       LINE_MAX                             VMEM_PAD_ADDR                */
 /*       LISTING2_COUNT                       VMEM_PAD_PAGE                */
 /*       LISTING2                             VOCAB_INDEX                  */
 /*       LIT_CHAR_SIZE                        XREF_LIM                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       CHARDATE                             ORDER_OK                     */
 /*       CHARTIME                             PAD                          */
 /*       EMIT_ARRAYNESS                       PRINT_DATE_AND_TIME          */
 /*       ERRORS                               SCAN                         */
 /*       ERROR                                SET_T_LIMIT                  */
 /*       GET_CELL                             SOURCE_COMPARE               */
 /*       GET_SUBSET                           SRN_UPDATE                   */
 /*       LEFT_PAD                             STREAM                       */
 /*       MIN                                  UNSPEC                       */
 /*       NEXT_RECORD                          VMEM_INIT                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INITIALIZATION <==                                                  */
 /*     ==> PAD                                                             */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GET_CELL                                                        */
 /*     ==> VMEM_INIT                                                       */
 /*     ==> MIN                                                             */
 /*     ==> UNSPEC                                                          */
 /*     ==> LEFT_PAD                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SET_T_LIMIT                                                     */
 /*         ==> ERROR ****                                                  */
 /*     ==> SOURCE_COMPARE                                                  */
 /*         ==> LEFT_PAD                                                    */
 /*         ==> SRNCMP                                                      */
 /*     ==> NEXT_RECORD                                                     */
 /*         ==> DECOMPRESS                                                  */
 /*             ==> BLANK                                                   */
 /*     ==> ORDER_OK                                                        */
 /*         ==> ERROR ****                                                  */
 /*     ==> STREAM                                                          */
 /*         ==> PAD                                                         */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> ERRORS ****                                                 */
 /*         ==> MOVE                                                        */
 /*         ==> MIN                                                         */
 /*         ==> MAX                                                         */
 /*         ==> DESCORE                                                     */
 /*             ==> PAD                                                     */
 /*         ==> HEX                                                         */
 /*         ==> SAVE_INPUT                                                  */
 /*             ==> PAD                                                     */
 /*             ==> I_FORMAT                                                */
 /*         ==> PRINT2                                                      */
 /*         ==> OUTPUT_GROUP                                                */
 /*             ==> PRINT2                                                  */
 /*         ==> ERROR ****                                                  */
 /*         ==> HASH                                                        */
 /*         ==> ENTER_XREF                                                  */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> ICQ_TERM#                                                   */
 /*         ==> ICQ_ARRAY#                                                  */
 /*         ==> CHECK_STRUC_CONFLICTS                                       */
 /*         ==> ENTER                                                       */
 /*         ==> ENTER_DIMS                                                  */
 /*         ==> DISCONNECT                                                  */
 /*         ==> SET_DUPL_FLAG                                               */
 /*         ==> FINISH_MACRO_TEXT                                           */
 /*         ==> ENTER_LAYOUT                                                */
 /*         ==> MAKE_INCL_CELL                                              */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS ****                                             */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
 /*         ==> FINDER                                                      */
 /*         ==> INTERPRET_ACCESS_FILE                                       */
 /*             ==> ERROR ****                                              */
 /*             ==> HASH                                                    */
 /*             ==> OUTPUT_WRITER ****                                      */
 /*         ==> NEXT_RECORD ****                                            */
 /*         ==> ORDER_OK                                                    */
 /*             ==> ERROR ****                                              */
 /*     ==> SCAN                                                            */
 /*         ==> MIN                                                         */
 /*         ==> HEX                                                         */
 /*         ==> ERROR ****                                                  */
 /*         ==> FINISH_MACRO_TEXT                                           */
 /*         ==> SAVE_TOKEN                                                  */
 /*             ==> OUTPUT_WRITER ****                                      */
 /*         ==> STREAM ****                                                 */
 /*         ==> IDENTIFY                                                    */
 /*             ==> ERROR ****                                              */
 /*             ==> HASH                                                    */
 /*             ==> ENTER                                                   */
 /*             ==> SET_DUPL_FLAG                                           */
 /*             ==> SET_XREF                                                */
 /*                 ==> ENTER_XREF                                          */
 /*                 ==> SET_OUTER_REF                                       */
 /*                     ==> COMPRESS_OUTER_REF                              */
 /*                         ==> MAX                                         */
 /*             ==> BUFFER_MACRO_XREF                                       */
 /*         ==> PREP_LITERAL                                                */
 /*             ==> SAVE_LITERAL                                            */
 /*     ==> SRN_UPDATE                                                      */
 /*     ==> CHARTIME                                                        */
 /*     ==> CHARDATE                                                        */
 /*     ==> PRINT_DATE_AND_TIME                                             */
 /*         ==> CHARDATE                                                    */
 /*         ==> PRINT_TIME                                                  */
 /*             ==> CHARTIME                                                */
 /*     ==> EMIT_ARRAYNESS                                                  */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR ****                                          */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB ****                                */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT ****                                             */
 /*     ==> GET_SUBSET                                                      */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /***********************************************************/                  00006000
 /*                                                         */                  00007000
 /*  REVISION HISTORY                                       */                  00008000
 /*                                                         */                  00009000
 /*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                  00009100
 /*                                                         */                  00009200
 /*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                  00009300
 /*  12/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM    */
 /*                               COMPILER                  */
 /*  02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER      */
 /*                               SOURCE CODE               */
 /*  07/01/91 RSJ  24V0  CR11096F INITIALIZE THE DATE_REMOTE*/
 /*                               FLAG TO FALSE             */
 /*  06/20/91 TEV   7V0  CR11114  MERGE BFS/PASS COMPILERS  */
 /*                               WITH CR/DR FIXES          */
 /*                                                         */                  00009400
 /*  12/23/92 PMA   8V0  *        MERGED 7V0 AND 24V0       */
 /*                               COMPILERS.                */
 /*                               * REFERENCE 24V0 CR/DR    */
 /*                                                         */
 /*  07/13/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                         */
 /*  12/23/96 SMR   28V0 CR12713  ENHANCE COMPILER LISTING  */
 /*                 12V0                                    */
 /*                                                         */
 /*  04/07/98 DCP   29V0 DR109085 RECORD INDEX OUT OF RANGE */
 /*                 14V0                                    */
 /*                                                         */
 /*  03/24/99 JAC   30V0 DR111314 INCLUDE FAILS WITH SRN    */
 /*                 15V0          OPTION                    */
 /*                                                         */
 /*  04/26/01 DCP   31V0 CR13335  ALLEVIATE SOME DATA SPACE */
 /*                 16V0          PROBLEMS IN HAL/S COMPILER*/
 /*                                                         */
 /*  03/22/04 TKN   32V0 CR13670  ENHANCE & UPDATE INFORMATION   */
 /*                 17V0          ON THE USAGE OF TYPE 2 OPTIONS */
 /*                                                         */
 /*  03/06/02 TKN   32V0 CR13554  USE TITAN SYSTEMS CORP    */
 /*                 17V0          INSTEAD OF INTERMETRICS   */
 /*                                                         */
 /***********************************************************/                  00009500

                                                                                01054764
 /*           INITIALIZATION         */                                         01054766
                                                                                01054768
INITIALIZATION:                                                                 01055200
   PROCEDURE;                                                                   01055300
      DECLARE SUBHEAD CHARACTER INITIAL('STMT                                   01055400
               SOURCE                                                  CURRENT S01055500
COPE');                                                                         01055600
      BASED (PRO, CON, TYPE2, VALS, NPVALS) FIXED;                              01055700
      DECLARE EQUALS CHARACTER INITIAL(' = ');                                  01055800
      DECLARE TYPE2_TYPE(12) BIT(8) INITIAL(                                    01055900
         0,  /* TITLE */                                                        01056000
         1,  /* LINECT */                                                       01056100
         1,  /* PAGES */                                                        01056200
         1,  /* SYMBOLS */                                                      01056300
         1,  /* MACROSIZE */                                                    01056400
         1,  /* LITSTRINGS */                                                   01056500
         1,  /* COMPUNIT */                                                     01056600
         1,  /* XREFSIZE */                                                     01056700
         0,  /* CARDTYPE */                                                     01056800
         1,  /* LABELSIZE */                                                    01056900
         1,  /* DSR */                                                          01056910
         1,  /* BLOCKSUM */                                                     01056920
         0); /* MFID FOR PASS; OLDTPL FOR BFS */                                01056930
                                                                                01057000
                                                                                01058900
      DECLARE (STORAGE_INCREMENT, STORAGE_MASK) FIXED;                          01058910
   DECLARE LOGHEAD CHARACTER INITIAL('STMT                                      01058940
                            SOURCE                                              01058950
                    REVISION');                                                 01058960
   DECLARE TMP FIXED;                                              /*CR12713*/
 /?P DECLARE NUM1_OPT LITERALLY '19';                              /*CR12713*/
     ARRAY SORT1(NUM1_OPT) BIT(16) INITIAL(8,5,0,13,19,2,1,15,17,14,
     10,16,9,11,6,7,18,3,4,12);                                    /*CR12713*/
  ?/                                                               /*CR12713*/
 /?B DECLARE NUM1_OPT LITERALLY '20';                              /*CR12713*/
     ARRAY SORT1(NUM1_OPT) BIT(16) INITIAL(8,5,0,13,20,2,1,15,17,18,
     14,10,16,9,11,6,7,19,3,4,12);                                 /*CR12713*/
  ?/                                                               /*CR12713*/
   DECLARE NUM2_OPT LITERALLY '12';                                /*CR12713*/
   ARRAY SORT2(NUM2_OPT) BIT(16) INITIAL(11,8,6,10,9,1,5,
   4,12,2,3,0,7);                                                  /*CR12713*/

/*-RSJ----------------#DFLAG---CR11096F--------------------------*/
/* INITIALIZE DATA_REMOTE FLAG                                   */
      DATA_REMOTE=FALSE;
/*---------------------------------------------------------------*/
      STORAGE_INCREMENT = MONITOR(32);                                          01058970
      STORAGE_MASK = -STORAGE_INCREMENT & "FFFFFF";                             01058980
      I = MONITOR(13, 'COMPOPT ');  /* LOAD OPTION PROCESSOR AND GET OPTIONS */ 01059000
      OPTIONS_CODE = COREWORD(I);                                               01059100
      COREWORD(ADDR(CON)) = COREWORD(I + 4);                                    01059200
      COREWORD(ADDR(PRO)) = COREWORD(I + 8);                                    01059300
      COREWORD(ADDR(TYPE2)) = COREWORD(I + 12);                                 01059400
      COREWORD(ADDR(VALS)) = COREWORD(I + 16);                                  01059500
      COREWORD(ADDR(NPVALS)) = COREWORD(I + 20);                                01059600
      C = STRING(VALS);  /* GET THE TITLE OPTION (IF ANY) */                    01059700
      IF LENGTH(C) = 0 THEN                                                     01059800
         C = 'T I T A N  S Y S T E M S  C O R P .';  /*CR13554*/                01059900
      J = LENGTH(C);                                                            01060000
      J = ((61 - J) / 2) + J;                                                   01060100
      C = LEFT_PAD(C, J);                                                       01060200
      C = PAD(C, 61);  /* C CONTAINS CENTERED TITLE */                          01060300
      TIME_OF_COMPILATION = TIME;                                               01060400
      S = CHARTIME(TIME_OF_COMPILATION);                                        01060450
      DATE_OF_COMPILATION = DATE;                                               01060500
      S = CHARDATE(DATE_OF_COMPILATION) || X4 || S;                             01060550
      OUTPUT(1) = 'H  HAL/S ' || STRING(MONITOR(23)) || C || X4 || S;           01060600
      CALL PRINT_DATE_AND_TIME('   HAL/S COMPILER PHASE 1 -- VERSION'           01060610
         || ' OF ', DATE_OF_GENERATION, TIME_OF_GENERATION);                    01060900
      DOUBLE_SPACE;                                                             01061000
      CALL PRINT_DATE_AND_TIME ('TODAY IS ', DATE, TIME);                       01061100
      OUTPUT = X1;                                                              01061200
                                                                                01061300
      C = PARM_FIELD;                                                           01061400
      I = 0;                                                                    01061500
      S = ' PARM FIELD: ';                                                      01061600
      K = LENGTH(C);                                                            01061700
      DO WHILE I < K;                                                           01061800
         J = MIN(K - I, 119);  /* DON'T EXCEED LINE WIDTH OF PRINTER */         01061900
         OUTPUT = S || SUBSTR(C, I, J);  /* PRINT ALL OR PART */                01062000
         I = I + J;                                                             01062100
         S = SUBSTR(X70, 0, LENGTH(S));                                         01062200
      END;                                                                      01062300
      DOUBLE_SPACE;                                                             01062400
      OUTPUT = ' COMPLETE LIST OF COMPILE-TIME OPTIONS IN EFFECT';              01062500
      DOUBLE_SPACE;                                                             01062600
      OUTPUT = '       *** TYPE 1 OPTIONS ***';                                 01062700
      OUTPUT = X1;                                                              01062800
      /*CR12713 - PRINT THE TYPE 1 OPTIONS USING THE ORDER IN SORT1 ARRAY.*/
      /*SINCE QUASI & TRACE ARE 360 ONLY, DO NOT PRINT.  PRINT LFXI HERE  */
      /*EVEN THOUGH IT IS DEFINED AS A "NONPRINTABLE" OPTION IN COMPOPT.  */
      DO I = 0 TO NUM1_OPT;                                     /*CR12713*/
         /*MAKE SURE NOT QUASI OR TRACE*/
         IF (SORT1(I) ^= 17) & (SORT1(I) ^= 3) THEN DO;         /*CR12713*/
           IF (SORT1(I) = 2) THEN DO;  /*PRINT LFXI HERE*/      /*CR12713*/
             IF ((OPTIONS_CODE & "00200000")^=0) THEN           /*CR12713*/
               OUTPUT = X8||'  LFXI';                           /*CR12713*/
               ELSE OUTPUT = X8||'NOLFXI';                      /*CR12713*/
           END;                                                 /*CR12713*/
           IF SUBSTR(STRING(CON(SORT1(I))),0,2) = 'NO' THEN     /*CR12713*/
             OUTPUT = X8||STRING(CON(SORT1(I)));                /*CR12713*/
           ELSE                                                 /*CR12713*/
             OUTPUT = X8||'  '||STRING(CON(SORT1(I)));          /*CR12713*/
         END;                                                   /*CR12713*/
      END;                                                      /*CR12713*/
      DOUBLE_SPACE;                                                             01063600
      OUTPUT = '       *** TYPE 2 OPTIONS ***';                                 01063700
      OUTPUT = X1;                                                              01063800
      I = 0;                                                                    01063900

 /**********************************************/
 /* THE FOLLOWING BLOCKS OF CODE WERE EXCLUDED */
 /* DUE TO COMPILER FEATURE DIFFERENCES. PASS  */
 /* SYSTEM IMPLEMENTS MFID OPTION. BFS SYSTEM  */
 /* IMPLEMENTS OLDTPL OPTION.                  */
 /**********************************************/
      /*CR12713 - PRINT THE TYPE 2 OPTIONS USING THE ORDER IN SORT2 ARRAY*/
 /?P  /* CR11114 */
      DO I = 0 TO NUM2_OPT;                                     /*CR12713*/
         C = LEFT_PAD(STRING(TYPE2(SORT2(I))), 15);             /*CR12713*/     01064100
         IF TYPE2_TYPE(SORT2(I)) THEN                           /*CR12713*/     01064200
            S = VALS(SORT2(I)); /* DECIMAL VALUE */             /*CR12713*/     01064300
         ELSE                                                                   01064400
            S = STRING(VALS(SORT2(I))); /* DESCRIPTOR */        /*CR12713*/     01064500
         IF STRING(TYPE2(SORT2(I)))='MFID' THEN DO;             /*CR12713*/     01064510
            OUTPUT=C || EQUALS || S;                            /*CR12713*/     01064530
            IF LENGTH(S) > 0 THEN DO;                                           01064520
               VALS(SORT2(I))=0;                                /*CR12713*/     01064540
               DO J=0 TO LENGTH(S)-1;                                           01064541
                  IF (BYTE(S,J) < BYTE('0')) | (BYTE(S,J) > BYTE('9'))          01064542
                     THEN DO;                                                   01064543
                     CALL ERRORS (CLASS_BI, 103, X1||S);        /*CR13335*/
                     VALS(SORT2(I))=0;                          /*CR12713*/     01064545
                     GO TO ENDMFID;                                             01064546
                  END;                                                          01064547
                  ELSE DO;                                                      01064548
                     VALS(SORT2(I))=VALS(SORT2(I))*10;          /*CR12713*/     01064549
                     /*CR12713 - FOLLOWING TO AVOID 'USED ALL ACCUMULATORS'*/
                     TMP = VALS(SORT2(I));                      /*CR12713*/
                     VALS(SORT2(I))=TMP+(BYTE(S,J) & "0F");     /*CR12713*/     01064550
                  END;                                                          01064551
               END;                                                             01064552
ENDMFID:                                                                        01064553
            END;                                                                01064560
         END;                                                                   01064570
         ELSE                                                                   01064580
            OUTPUT = C || EQUALS || S;                                          01064600
      END;                                                                      01064800
 ?/
 /?B    /* CR11114 */
        /*************************************/
        /* MFID'S ARE NOT IMPLEMENTED IN BFS */
        /*************************************/
      DO I = 0 TO NUM2_OPT;                                     /*CR12713*/
         C = LEFT_PAD(STRING(TYPE2(SORT2(I))), 15);             /*CR12713*/     01064100
         IF TYPE2_TYPE(SORT2(I)) THEN                           /*CR12713*/     01064200
            S = VALS(SORT2(I));  /* DECIMAL VALUE */            /*CR12713*/     01064300
          ELSE DO;                                                              01064548
            S = STRING(VALS(SORT2(I)));  /* DESCRIPTER */       /*CR12713*/
            /*DR111314  OLD_TEMPLATE ASSIGNMENT DELETED*/
          END;                                                                  01064552
         IF SORT2(I) ^= 12 THEN OUTPUT = C || EQUALS || S;     /*DR111314*/     01064600
      END;                                                                      01064800
 ?/
      LISTING2 = (OPTIONS_CODE & "02") ^= 0;                                    01064900
      SREF_OPTION = (OPTIONS_CODE & "2000") ^= 0;                               01064910
      PARTIAL_PARSE = (OPTIONS_CODE & "010000") ^= 0;                           01065000
      LISTING2_COUNT, LINE_MAX, LINE_LIM = VALS(1);                             01065100
      SIMULATING=(OPTIONS_CODE&"800")^=0;                                       01065200
      IF (OPTIONS_CODE&"10") ="10" THEN TPL_FLAG=0;                             01065300
      SRN_PRESENT = (OPTIONS_CODE & "80000") ^= 0;                              01065400
      SDL_OPTION = (OPTIONS_CODE & "800000") ^= 0;                              01065500
      IF SDL_OPTION THEN SRN_PRESENT = TRUE;                                    01065600
      ADDR_PRESENT = (OPTIONS_CODE & "100000") ^= 0;                            01065700
      IF SRN_PRESENT THEN DO;                                                   01065800
         PAD1 = SUBSTR(X70, 0, 11);                                             01065900
         PAD2 = SUBSTR(X70, 0, 15);                                             01066000
         C = '   SRN ';                                                         01066100
      END;                                                                      01066200
      ELSE DO;                                                                  01066300
         PAD1 = X4;                                                             01066400
         PAD2 = X8;                                                             01066500
         C = '';                                                                01066600
      END;                                                                      01066700
      IF (OPTIONS_CODE & "00040000") ^= 0                                       01066702
         THEN HMAT_OPT = TRUE;                                                  01066704
      OUTPUT=X1;                                                                01066870
      IF GET_SUBSET('$$SUBSET',"1") THEN OUTPUT(1)=                             01066880
         '0 *** NO LANGUAGE SUBSET IN EFFECT ***';                              01066890
      OUTPUT(1)=SUBHEADING||C||LOGHEAD;                                         01066900
      EJECT_PAGE;                                                               01066910
      OUTPUT(1) = SUBHEADING || C || SUBHEAD;                                   01066920
      INDENT_INCR = 2;  /*CR12713 - CHANGE INDENTION INCREMENT FROM 3 TO 2*/    01067120
      CASE_LEVEL,CARD_COUNT,INCLUDE_LIST_HEAD = -1;                             01067130
      COMMENT_COUNT, LAST, NEXT, STMT_PTR, STACK_DUMP_PTR = -1;                 01067200
      LAST_SPACE = 2;                                                           01067300
      ONE_BYTE = '?';                                                           01067400
      STMT_NUM, PROCMARK, FL_NO = 1;                                            01067500
      NT_PLUS_1 = NT + 1;                                                       01067600
      IC_ORG, IC_MAX, CUR_IC_BLK = 0;                                           01067700
      IC_LIM = IC_SIZE;  /* UPPER LIMIT OF TABLE  */                            01067800
      CALL MONITOR(4, 3, IC_SIZE*8);                                            01067900
      SYTSIZE = VALS(3);                                                        01068000
      MACRO_TEXT_LIM = VALS(4);                                                 01068100
      LIT_CHAR_SIZE = VALS(5);                                                  01068200
      XREF_LIM = VALS(7);                                                       01068300
      OUTER_REF_LIM = VALS(11);                                                 01068310
      J = (FREELIMIT + 512) & STORAGE_MASK;  /* BOUNDARY NEAR TOP OF CORE */    01068400
      TEMP1=(J-(13000+2*1680+3*3458))&STORAGE_MASK;/*TO ALLOW ROOM FOR BUFFERS*/01068500
      IF TEMP1 - 512 <= FREEPOINT THEN CALL COMPACTIFY;                         01069200
      CALL MONITOR(7, ADDR(TEMP1), J - TEMP1);                                  01069300
      FREELIMIT = TEMP1 - 512;                                                  01069400
 /* INITIALIZE VMEM PAGING AND ALLOCATE SPACE FOR IN-CORE PAGES*/               01069500
      CALL VMEM_INIT;                                                           01069520
      RECORD_CONSTANT(VMEMREC,VMEM_MAX_PAGE,UNMOVEABLE);                        01069540
      RECORD_USED(VMEMREC) = RECORD_ALLOC(VMEMREC);                             01069560
      DO I=0 TO VMEM_MAX_PAGE;                                                  01069580
         VMEM_PAD_PAGE(I)= -1;                                                  01069600
         VMEM_PAD_ADDR(I) = ADDR(VMEMREC(I));                                   01069620
      END;                                                                      01069640
 /* GET AREA FOR SYM SRN TABLE */                                               01069660
      BLOCK_SRN_DATA=GET_CELL(2044,ADDR(SRN_BLOCK_RECORD),MODF);                01069680
      RECORD_CONSTANT(FOR_DW,13,UNMOVEABLE);                                    01069700
      RECORD_USED(FOR_DW) = RECORD_ALLOC(FOR_DW);                               01069720
      RECORD_CONSTANT(LIT_NDX,LIT_CHAR_SIZE-1,UNMOVEABLE);  /*CR13670*/         01069740
      RECORD_USED(LIT_NDX) = RECORD_ALLOC(LIT_NDX);                             01069760
      RECORD_CONSTANT(FOR_ATOMS,ATOM#_LIM,MOVEABLE);               /*DR109085*/ 01069780
      RECORD_USED(FOR_ATOMS) = RECORD_ALLOC(FOR_ATOMS);                         01069800
      ATOMS(0)= "00010050"; /*XPXRC OP CODE-ONE OPERAND*/                       01069820
      NEXT_ATOM# = 2;  /* SKIP FIRST 2 ENTRIES - ALWAYS XPXRC */                01069840
      CALL EMIT_ARRAYNESS;  /* DUMMY CALL TO INITIALIZE A PARM */               01069900
      ALLOCATE_SPACE(CROSS_REF,XREF_LIM);                                       01070000
      NEXT_ELEMENT(CROSS_REF);                                                  01070010
      I = LIT_BUF_SIZE * 12;                                                    01070100
      CALL MONITOR(4, 2, I);                                                    01070200
      RECORD_CONSTANT(LIT_PG,3,MOVEABLE);                                       01070300
      RECORD_USED(LIT_PG) = RECORD_ALLOC(LIT_PG);                               01070400
      CALL INLINE("58",1,0,LIT_NDX);                                            01071100
      CALL INLINE("50",1,0,LIT_CHAR_AD);           /* ST  1,LIT_CHAR_AD */      01071200
      CALL INLINE("58",1,0,FOR_DW);                                             01071400
      CALL INLINE("50",1,0,DW_AD);                   /* ST  1,DW_AD       */    01071500
      CALL MONITOR(5,DW_AD);                                                    01071600
      TABLE_ADDR = DW_AD + 24;                                                  01071700
      ADDR_FIXER = TABLE_ADDR + 8;                                              01071800
      DW(8) = "4E000000";                                                       01071900
      DW(9) = 0;                                                                01072000
      ADDR_FIXED_LIMIT = ADDR_FIXER + 8;                                        01072100
      DW(10) = "487FFFFF";                                                      01072200
      DW(11) = "FFFFFFFF";                                                      01072300
      ADDR_ROUNDER = ADDR_FIXED_LIMIT + 8;                                      01072400
      DW(12) = "407FFFFF";                                                      01072500
      DW(13) = "FFFFFFFF";                                                      01072600
      ALLOCATE_SPACE(SYM_TAB,SYTSIZE+1);                                        01072700
      NEXT_ELEMENT(SYM_TAB);                                                    01072800
      NEXT_ELEMENT(SYM_TAB);                                                    01072810
      ALLOCATE_SPACE(CSECT_LENGTHS,50);                                         01072820
      RECORD_USED(CSECT_LENGTHS) = 1;                                           01072830
      ALLOCATE_SPACE(DOWN_INFO, NUM_DWNS);                                      01072831
      NEXT_ELEMENT(DOWN_INFO);                                                  01072832
 /* CR11088 11/90 RAH - DELETED ONE NEXT_ELEMENT(DOWN_INFO) MACRO */            01072833
 /* NOW DO THE NON COMMON BASED VARIABLES */                                    01073100
      ALLOCATE_SPACE(OUTER_REF_TABLE,OUTER_REF_LIM+1);                          01073200
      NEXT_ELEMENT(OUTER_REF_TABLE);                                            01073300
      ALLOCATE_SPACE(MACRO_TEXTS,MACRO_TEXT_LIM);                               01073400
      NEXT_ELEMENT(MACRO_TEXTS);                                                01073410
      NEXT_ELEMENT(MACRO_TEXTS);                                                01073420
      ALLOCATE_SPACE(LINK_SORT,SYTSIZE+1);                                      01073500
      NEXT_ELEMENT(LINK_SORT);                                                  01073600
      NEXT_ELEMENT(LINK_SORT);                                                  01073610
      CARD_TYPE(BYTE('E')) = 1;                                                 01074700
      CARD_TYPE(BYTE('M')) = 2;                                                 01074800
      CARD_TYPE(BYTE('S')) = 3;                                                 01074900
      CARD_TYPE(BYTE('C')) = 4;                                                 01075000
      CARD_TYPE(BYTE('D')) = 5;                                                 01075100
      CARD_TYPE(BYTE(X1)) = 2;                                      /*CR13335*/ 01075300
      C = STRING(VALS(8));  /* PICK UP STRING (IF ANY) */                       01075400
      IF LENGTH(C) > 0 THEN DO I = 0 TO LENGTH(C) - 2 BY 2;                     01075500
         J = BYTE(C, I);                                                        01075600
         K = BYTE(C, I + 1);                                                    01075700
         IF CARD_TYPE(J) = 0 THEN                                               01075800
            CARD_TYPE(J) = CARD_TYPE(K);                                        01075900
      END;                                                                      01076000
      DO I = 1 TO NSY;                                                          01076010
         K = VOCAB_INDEX(I);                                                    01076020
         J = K & "FF";                                                          01076030
         C = SUBSTR(VOCAB(J), SHR(K, 8) & "FFFF", SHR(K, 24));                  01076040
         VOCAB_INDEX(I) = UNSPEC(C);                                            01076050
      END;                                                                      01076060
      CURRENT_CARD=INPUT(INPUT_DEV);                                            01076070
      LRECL=LENGTH(CURRENT_CARD)-1;                                             01076080
      TEXT_LIMIT=SET_T_LIMIT(LRECL);                                            01076090
      FIRST_CARD=TRUE;                                                          01076190
      /*DR111314  TPL_LRECL ASSIGNMENT DELETED FROM PASS AND BFS CODE*/
 /?B  /* BFS/PASS INTERFACE; TEMPLATE RECORD LENGTH */
      TEXT_LIMIT(1) = TEXT_LIMIT;
 ?/
      IF BYTE(CURRENT_CARD) = "00" THEN                                         01077000
         DO;  /* COMPRESSED SOURCE */                                           01077100
         SYSIN_COMPRESSED = TRUE;                                               01077200
         INPUT_REC = CURRENT_CARD;                                              01077300
         CALL NEXT_RECORD;  /* GET FIRST REAL RECORD */                         01077400
      END;                                                                      01077500
AGAIN:                                                                          01077600
      IF ^ORDER_OK(BYTE('C')) THEN DO;                                          01077700
         CALL ERROR(CLASS_M, 2);                                                01077800
         CALL NEXT_RECORD;                                                      01077900
         GO TO AGAIN;                                                           01078000
      END;                                                                      01078100
      IF LENGTH(CURRENT_CARD) > 88 THEN                                         01078200
         CURRENT_CARD = SUBSTR(CURRENT_CARD, 0, 88);                            01078300
      CARD_COUNT = CARD_COUNT + 1;                                              01078400
      SAVE_CARD = CURRENT_CARD;                                                 01078500
      CALL SOURCE_COMPARE;                                                      01078510
      CALL STREAM;                                                              01078600
      CALL SCAN;                                                                01078700
      IF CONTROL(4) THEN OUTPUT = 'SCANNER: ' || TOKEN;                         01078800
      CALL SRN_UPDATE;                                                          01078900
 /* INITIALIZE THE PARSE STACK */                                               01079000
      STATE = 1;   /* START-STATE  */                                           01079100
      SP = "FFFFFFFF";                                                          01079200
      RETURN;                                                                   01079900
NO_CORE:                                                                        01080000
      CALL ERROR(CLASS_B,1); /* CR12416 */                                      01080100
   END INITIALIZATION;                                                          01080200
