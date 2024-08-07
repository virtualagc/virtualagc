 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENERAT2.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
                2024-08-07 RSB  Line 07013590 has had the cast STRING(...)
                                added to the argument of EMITSTRING, 
                                conditionally on /?V ... ?/.  That's
                                because the argument is a FIXED, but
                                expects a string descriptor.  XCOM-I
                                does not understand this (without STRING)
                                and autoconverts the FIXED to CHARACTER.
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  GENERATE_CONSTANTS                                     */
 /* MEMBER NAME:     GENERAT2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       CTR               BIT(16)                                         */
 /*       EMIT_LITERAL(1720)  LABEL                                         */
 /*       I                 BIT(16)                                         */
 /*       LEN(5)            BIT(16)                                         */
 /*       MODE              BIT(16)                                         */
 /*       MODE_TAB(3)       BIT(16)                                         */
 /*       PTR               BIT(16)                                         */
 /*       SAVELINE          BIT(16)                                         */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ADDR                                 R_BASE_USED                  */
 /*       BASE_USED                            R_SECTION                    */
 /*       CALL#                                R_SORT                       */
 /*       CODE_LINE                            REMOTE_BASE                  */
 /*       CONSTANTS                            SECTION                      */
 /*       DATABASE                             SORT                         */
 /*       DATABLK                              SRS_REFS                     */
 /*       ENTRYPOINT                           SYM_ADDR                     */
 /*       FIRSTREMOTE                          SYM_BASE                     */
 /*       FSIMBASE                             SYM_DISP                     */
 /*       MAX_SRS_DISP                         SYM_FLAGS                    */
 /*       NEXTDECLREG                          SYM_LEVEL                    */
 /*       OFFSET                               SYM_LINK1                    */
 /*       PRIMARY_LIT_END                      SYT_ADDR                     */
 /*       PRIMARY_LIT_START                    SYT_BASE                     */
 /*       PROC_LEVEL                           SYT_DISP                     */
 /*       PROCLIMIT                            SYT_FLAGS                    */
 /*       PROGBASE                             SYT_LEVEL                    */
 /*       PROGPOINT                            SYT_LINK1                    */
 /*       R_ADDR                               TEMPBASE                     */
 /*       R_BASE                               TEMPORARY_FLAG               */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       BASE_REGS                            LOCCTR                       */
 /*       CODE                                 PASS1_ADCONS                 */
 /*       COMM                                 PROGDATA                     */
 /*       CONSTANT_HEAD                        PROGDELTA                    */
 /*       CONSTANT_PTR                         P2SYMS                       */
 /*       CONSTANT_REFS                        SYM_TAB                      */
 /*       INDEXNEST                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       BOUNDARY_ALIGN                                                    */
 /*       EMITADDR                                                          */
 /*       EMITC                                                             */
 /*       EMITSTRING                                                        */
 /*       EMITW                                                             */
 /*       GET_CODE                                                          */
 /*       SET_LOCCTR                                                        */
 /* CALLED BY:                                                              */
 /*       TERMINATE                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GENERATE_CONSTANTS <==                                              */
 /*     ==> GET_CODE                                                        */
 /*     ==> EMITC                                                           */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> HEX_LOCCTR                                                  */
 /*             ==> HEX                                                     */
 /*         ==> GET_CODE                                                    */
 /*     ==> EMITW                                                           */
 /*         ==> HEX                                                         */
 /*         ==> HEX_LOCCTR ****                                             */
 /*         ==> GET_CODE                                                    */
 /*     ==> EMITSTRING                                                      */
 /*         ==> CS                                                          */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> BOUNDARY_ALIGN                                                  */
 /*         ==> EMITC ****                                                  */
 /*     ==> SET_LOCCTR                                                      */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> EMITADDR                                                        */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
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
 /* 07/08/91 RSJ  24V0  CR11096F #DFLAG - SET REMOTE FLAG OF ALL #D         */
 /*                              VARIABLES AT THE END OF PHASE2.            */
 /* 08/23/91 DAS  24V0  CR11120  #DFLAG - REQUIREMENTS CHANGE: DON'T        */
 /*                              SET REMOTE FLAG OF #D VARIABLES            */
 /*                                                                         */
 /* 05/07/92 JAC   7V0  CR11114  MERGE BFS/PASS COMPILERS                   */
 /*                                                                         */
 /* 12/23/92 PMA   8V0  *        MERGED 7V0 AND 24V0 COMPILERS.             */
 /*                              * REFERENCE 24V0 CR/DRS                    */
 /*  2/26/94 RJN  26V0  DR106821 CORRECT SAVELINE DECLARATION               */
 /*                                                                         */
 /***************************************************************************/
                                                                                07011000
   DECLARE PROGDELTA BIT(16);                                                   07011100
 /* ROUTINE TO PUT THE CONSTANT TABLE ONTO THE CODE FILE  */                    07011500
GENERATE_CONSTANTS:                                                             07012000
   PROCEDURE;                                                                   07012500
      DECLARE (MODE, PTR, CTR, I) BIT(16);                                      07013000
      DECLARE MODE_TAB(3) BIT(16) INITIAL(1, 2, 3, 5);                          07013500
      DECLARE LEN(5) BIT(16) INITIAL(1,1,2,2,4,2);                              07013502
      DECLARE SAVELINE FIXED;  /* DR 106821 - RJN - CHANGED TO FIXED */         07013504
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CONSTANT PROTECTION */
      CALL SET_LOCCTR(DATABASE, PROGDATA);
      GENED_LIT_START = PROGDATA;
 ?/
EMIT_LITERAL:                                                                   07013510
      PROCEDURE(I) BIT(16);                                                     07013520
         DECLARE (I, PTR) BIT(16);                                              07013530
         PTR = I;                                                               07013540
         I = CONSTANT_PTR(I);                                                   07013550
         CONSTANT_PTR(PTR) = LOCCTR(INDEXNEST) + PROGDELTA;                     07013560
         DO CASE MODE;                                                          07013570
            DO;                                                                 07013580
               CALL EMITSTRING(/?VSTRING(?/CONSTANTS(PTR)/?V)?/);               07013590
            END;                                                                07013600
            CALL EMITC(0, CONSTANTS(PTR));                                      07013610
            CALL EMITW(CONSTANTS(PTR));                                         07013620
            CALL EMITW(CONSTANTS(PTR));                                         07013630
            DO;                                                                 07013640
               CALL EMITW(CONSTANTS(PTR));                                      07013650
               CALL EMITW(CONSTANTS(PTR+1));                                    07013660
            END;                                                                07013670
            CALL EMITADDR(SHR(CONSTANTS(PTR+1), 16), CONSTANTS(PTR),            07013680
               CONSTANTS(PTR+1) & "FFFF");                                      07013690
         END;  /* DO CASE MODE  */                                              07013700
         RETURN I;                                                              07013710
      END EMIT_LITERAL;                                                         07013720
      IF CALL#(PROGPOINT) = 2 THEN RETURN;  /* COMPOOL  */                      07014000

/?P  /* SSCR 8348 -- BASE REG. ALLOCATION (ADCON)  */

 /* EXTRACT ALL BASE REGISTERS FOR WHICH ADCONS MUST BE EMITTED */              07014500
      CTR = 0;                                                                  07014600
      DO PTR = PROGBASE + 1 TO NEXTDECLREG;                                     07014700
         IF R_BASE_USED(PTR) > 0 THEN DO;                                       07014800
            CTR = CTR + 1;                                                      07014900
            R_SORT(CTR) = PTR;                                                  07015000
         END;                                                                   07015100
      END;                                                                      07015200
      PASS1_ADCONS = CTR;                                                       07015300
 /* SORT VIRTUAL BASE REGISTERS IN ORDER OF NUMBER OF TIMES LOADED */           07015400
      DO I = 1 TO CTR - 1;                                                      07015500
         DO PTR = 1 TO CTR - I;                                                 07015600
            IF R_BASE_USED(R_SORT(PTR)) < R_BASE_USED(R_SORT(PTR+1)) THEN DO;   07015700
               MODE = R_SORT(PTR);   /* MODE USED AS TEMPORARY HERE */          07015800
               R_SORT(PTR) = R_SORT(PTR+1);                                     07015900
               R_SORT(PTR+1) = MODE;                                            07016000
            END;                                                                07016100
         END;                                                                   07016200
      END;                                                                      07016300
                                                                                07016400
 /* EMIT ADCONS */                                                              07016500
      INDEXNEST = -1;                                                           07016600
      LOCCTR(FSIMBASE) = 0;                                                     07016700
 /* SO THINGS WILL WORK IN CASE NOTHING IS PLACED AT THE END OF THE #D */       07016710
      LOCCTR(DATABASE) = PROGDATA;                                              07016720
 /* INITIALIZE BY CHOOSING PROPER CSECT */                                      07016800
      CALL SET_LOCCTR(FSIMBASE,0);                                              07017100
 /* FOR EACH ADCON: 1) EMIT ADCON, 2) FILL IN INFORMATION,                      07018300
          3) FIGURE OUT WHERE NEXT ADCON SHOULD BE PLACED */                    07018400
      DO I = 1 TO CTR;                                                          07018500
         PTR = R_SORT(I);                                                       07018600
         R_ADDR(PTR) = LOCCTR(INDEXNEST);                                       07018700
         IF R_SECTION(PTR) = 0 THEN CALL EMITADDR(DATABASE,R_BASE(PTR));        07018800
         ELSE CALL EMITADDR(R_SECTION(PTR), R_BASE(PTR));                       07018900
      END; /* DO FOR */
?/
/?B  /* SSCR 8348 -- BASE REG. ALLOCATION (ADCON)  */
      INDEXNEST = -1;
      CALL SET_LOCCTR(FSIMBASE,0);
      DO I = PROGBASE + 1 TO NEXTDECLREG;
         PTR = I;
         IF R_BASE_USED(PTR) THEN DO;
            R_INX(PTR) = LOCCTR(INDEXNEST);
            IF R_SECTION(PTR) = 0 THEN
               CALL EMITADDR(DATABASE,R_BASE(PTR));
            ELSE CALL EMITADDR(R_SECTION(PTR),R_BASE(PTR));
         END;
      END;
?/
      CONSTANT_REFS(2) = CONSTANT_REFS(2) + CONSTANT_REFS(3) + CONSTANT_REFS(5);07037010
 /* EMIT_FSIM */                                                                07037020
      PRIMARY_LIT_START = 0;                                                    07037022
      DO I = 0 TO 3;                                                            07037030
         MODE = MODE_TAB(I);                                                    07037040
         IF I = 0 THEN DO;                                                      07037050
            IF CONSTANT_REFS(1) > SRS_REFS THEN CTR = 55;                       07037060
            ELSE CTR = ((55 - MAX_SRS_DISP) & (-4)) - 1;                        07037070
         END;                                                                   07037080
         ELSE DO;                                                               07037090
            IF CONSTANT_REFS(2) > SRS_REFS+SRS_REFS(1) THEN CTR = 110;          07037100
            ELSE IF CONSTANT_REFS(2) < SRS_REFS THEN                            07037110
               CTR = ((55 - MAX_SRS_DISP) & (-4)) - 2;                          07037120
            ELSE CTR = ((110 - MAX_SRS_DISP(1)) & (-4)) - 2;                    07037130
         END;                                                                   07037140
         DO WHILE CONSTANT_HEAD(MODE) ^= 0;                                     07037150
            IF LOCCTR(INDEXNEST) > CTR THEN ESCAPE;                             07037160
            CALL BOUNDARY_ALIGN(MODE);                                          07037170
            IF (MODE & 2) ^= 0 THEN                                             07037180
               CALL EMITC(DATABLK, 1);                                          07037190
            CONSTANT_HEAD(MODE) = EMIT_LITERAL(CONSTANT_HEAD(MODE));            07037200
         END;                                                                   07037210
      END;                                                                      07037220
      PRIMARY_LIT_END=LOCCTR(FSIMBASE)-1;                                       07037222
      IF PRIMARY_LIT_END = (PRIMARY_LIT_START - 1)                              07037223
         THEN PRIMARY_LIT_START, PRIMARY_LIT_END = -1;                          07037224
      CALL BOUNDARY_ALIGN(4);                                                   07037230
      PROGDELTA = LOCCTR(FSIMBASE);                                             07037240
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CONSTANT PROTECTION */
      GENED_LIT_START, LOCCTR(FSIMBASE) = LOCCTR(DATABASE)+PROGDELTA;
 ?/
      CALL SET_LOCCTR(DATABASE, PROGDATA);                                      07037250
      MODE = 5;                                                                 07042000
      DO WHILE MODE >= 0;                                                       07042500

 /?P  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */

         IF CONSTANT_HEAD(MODE) ^= 0 THEN DO;                                   07042600
            PTR = CONSTANT_HEAD(MODE);                                          07042700
            CTR = 0;                                                            07042800
            CALL BOUNDARY_ALIGN(MODE);                                          07043100
            IF MODE >= 2 & MODE <= 4 THEN DO;                                   07043200
               CALL EMITC(DATABLK,0);                                           07043300
               SAVELINE = CODE_LINE - 1;                                        07043400
            END;                                                                07043500
                                                                                07043600
            DO WHILE PTR ^= 0;                                                  07043700
               PTR = EMIT_LITERAL(PTR);                                         07044000
               CTR = CTR + 1;                                                   07044100
            END;                                                                07044200
            CONSTANT_HEAD(MODE) = PTR;                                          07044300
                                                                                07044400
            IF MODE = 4 THEN                                                    07044500
               CODE(GET_CODE(SAVELINE)) = SHL(DATABLK,16) | SHL(CTR,1);         07044600
            ELSE IF MODE >= 2 & MODE < 4 THEN                                   07044700
               CODE(GET_CODE(SAVELINE)) = SHL(DATABLK,16) | CTR;                07044800
         END; /* IF CONSTANT_HEAD ^= 0 */                                       07045000
 ?/
 /?B  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */

         IF CONSTANT_HEAD(MODE) ^=0 THEN DO;
            CTR = 0;
            I, PTR = CONSTANT_HEAD(MODE);
            IF MODE > 1 THEN
               DO WHILE PTR ^= 0;
                  CTR = CTR + 1;
                  PTR = CONSTANT_PTR(PTR);
               END;
            CALL BOUNDARY_ALIGN(MODE);
            IF MODE = 4 THEN CALL EMITC(DATABLK, SHL(CTR,1));
            ELSE IF MODE>1 THEN IF MODE<4 THEN CALL EMITC(DATABLK,CTR);
            DO WHILE I ^= 0;
               I = EMIT_LITERAL(I);
            END;   /* DO WHILE I  */
         END;      /* IF */
 ?/
         MODE = MODE - 1;                                                       07045100
      END;  /* WHILE MODE >= 0 */                                               07045200
      PROGDATA = LOCCTR(DATABASE) + PROGDELTA;                                  07060010
      DO I = PROGPOINT TO PROCLIMIT;                                            07060020
         PTR = PROC_LEVEL(I);                                                   07060030
         SYT_ADDR(PTR) = SYT_ADDR(PTR) + PROGDELTA;                             07060040
         PTR = SYT_LEVEL(PTR);                                                  07060050
         DO WHILE PTR > 0;                                                      07060060
/*-DAS---CR11120 #DFLAG DELETED CODE THAT RESET #D DATA'S REMOTE FLAG*/
            IF (SYT_FLAGS(PTR) & TEMPORARY_FLAG) = 0 THEN                       07060070
               IF SYT_BASE(PTR) ^= TEMPBASE THEN                                07060080
               IF SYT_BASE(PTR) < REMOTE_BASE THEN DO;                          07060090
               SYT_ADDR(PTR) = SYT_ADDR(PTR) + PROGDELTA;                       07060100
               IF SYT_BASE(PTR) = PROGBASE THEN                                 07060110
                  SYT_DISP(PTR) = SYT_DISP(PTR) + PROGDELTA;                    07060120
            END;                                                                07060130
            PTR = SYT_LEVEL(PTR);                                               07060140
         END;                                                                   07060150
      END;                                                                      07060160
      PTR = ENTRYPOINT;                                                         07060170
      DO WHILE PTR > 0;                                                         07060180
         SYT_ADDR(PTR) = SYT_ADDR(PTR) + PROGDELTA;                             07060190
         PTR = SYT_LINK1(PTR);                                                  07060200
      END;                                                                      07060210
      PTR = FIRSTREMOTE;                                                        07060220
      DO WHILE PTR > 0;                                                         07060230
         IF SYT_DISP(PTR) >= 0 THEN                                             07060240
            SYT_DISP(PTR) = SYT_DISP(PTR) + PROGDELTA;                          07060250
         PTR = SYT_LINK1(PTR);                                                  07060260
      END;                                                                      07060270
      DO I = PROGBASE + 1 TO NEXTDECLREG;                                       07060280
         IF R_SECTION(I) = 0 THEN                                               07060290
            R_BASE(I) = R_BASE(I) + PROGDELTA;                                  07060300
      END;                                                                      07060310
   END GENERATE_CONSTANTS;                                                      07066000
