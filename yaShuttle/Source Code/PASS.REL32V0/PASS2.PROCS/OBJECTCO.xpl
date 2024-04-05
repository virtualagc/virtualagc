 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OBJECTCO.xpl
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
 /* PROCEDURE NAME:  OBJECT_CONDENSER                                       */
 /* MEMBER NAME:     OBJECTCO                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       BRANCH_ADDR(1)    MACRO              CONDENSED         BIT(8)     */
 /*       BRANCH_BLINK(1)   MACRO              CURRENT_LINE      FIXED      */
 /*       BRANCH_CONDENSE   LABEL              DELTA             FIXED      */
 /*       BRANCH_DELETE(1527)  LABEL           LABEL_UPDATE      LABEL      */
 /*       BRANCH_FLINK(1)   MACRO              LOOKING_AHEAD     BIT(8)     */
 /*       BRANCH_INCODE(1)  MACRO              PASS1_OBJ_CONDENSER  LABEL   */
 /*       BRANCH_INSRT(1677)  LABEL            RLD_FLAG          BIT(8)     */
 /*       BRANCH_NUM        BIT(16)            SHIFT_CONDENSE    LABEL      */
 /*       BRANCH_TARG(1)    MACRO              TARGET_LBL        BIT(16)    */
 /*       BRANCH_UPDATE(1813)  LABEL           TEMP1             FIXED      */
 /*       CONDENSE(1832)    LABEL              UPLOC             LABEL      */
 /*       CONDENSE_A_BRANCH LABEL              VERIFY(1519)      LABEL      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ADCON                                NOT_LEAF                     */
 /*       ADDR                                 OLD_LINKAGE                  */
 /*       ARRAY_LABEL                          POSMAX                       */
 /*       B_ADDR                               PRELBASE                     */
 /*       B_BLINK                              PROCLIMIT                    */
 /*       B_FLINK                              PROGBASE                     */
 /*       BAL                                  PROGDELTA                    */
 /*       BASE_REGS                            PROGPOINT                    */
 /*       BC                                   PROLOG                       */
 /*       BCT                                  P2SYMS                       */
 /*       BR_ARND                              R_ADDR                       */
 /*       CLASS_BI                             RM                           */
 /*       CLBL                                 RXTYPE                       */
 /*       CONSTANT_PTR                         R                            */
 /*       CSECT                                SCAL                         */
 /*       CSECT_BOUND                          SHCOUNT                      */
 /*       CSYM                                 SLL                          */
 /*       CURRENT_ADDRESS                      SRA                          */
 /*       DATA_REMOTE                          SRL                          */
 /*       DATABASE                             SRSTYPE                      */
 /*       EXTSYM                               SSTYPE                       */
 /*       FALSE                                STMTNUM                      */
 /*       FSIMBASE                             STNO                         */
 /*       IA                                   SYM                          */
 /*       IHL                                  SYM_BASE                     */
 /*       IMD                                  SYM_DISP                     */
 /*       INT_CODELINE                         SYM_LINK2                    */
 /*       IX                                   SYM_SCOPE                    */
 /*       LA                                   SYM_TAB                      */
 /*       LABEL_ARRAY                          SYT_BASE                     */
 /*       LASTLABEL                            SYT_DISP                     */
 /*       LBL                                  SYT_LABEL                    */
 /*       LH                                   SYT_LINK2                    */
 /*       LINK_LOCATION                        SYT_SCOPE                    */
 /*       LOCAT                                TARGET                       */
 /*       LOCATION                             TEMPBASE                     */
 /*       LOCATION_LINK                        TRUE                         */
 /*       MAXTEMP                              XPT                          */
 /*       NOP                                                               */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       BRANCH_TBL                           LHS                          */
 /*       CODE_LINE                            LOCCTR                       */
 /*       CODE                                 MAX_CODE_LINE                */
 /*       CURRENT_ESDID                        MAX_SEVERITY                 */
 /*       EMITTING                             OPCOUNT                      */
 /*       ERROR#                               RHS                          */
 /*       FIRSTBRANCH                          SPLIT_DELTA                  */
 /*       GENERATING                           TEMP                         */
 /*       INST                                 WORKSEG                      */
 /*       LAB_LOC                              XLEN                         */
 /*       LASTBRANCH                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       CHECK_SRS                                                         */
 /*       ERRORS                                                            */
 /*       GET_CODE                                                          */
 /*       GET_INST_R_X                                                      */
 /*       NEXT_REC                                                          */
 /*       REAL_LABEL                                                        */
 /*       SKIP                                                              */
 /*       SKIP_ADDR                                                         */
 /* CALLED BY:                                                              */
 /*       TERMINATE                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> OBJECT_CONDENSER <==                                                */
 /*     ==> GET_CODE                                                        */
 /*     ==> CHECK_SRS                                                       */
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
 /*     ==> NEXT_REC                                                        */
 /*         ==> GET_CODE                                                    */
 /*     ==> SKIP                                                            */
 /*     ==> SKIP_ADDR                                                       */
 /*         ==> GET_CODE                                                    */
 /*         ==> NEXT_REC ****                                               */
 /*         ==> SKIP                                                        */
 /*     ==> REAL_LABEL                                                      */
 /*     ==> GET_INST_R_X                                                    */
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
 /* 07/15/91 DAS  24V0  CR11096 #DREG - NEW #D REGISTER ALLOCATION:         */  14680006
 /*                             R1 OR R3 FOR #D, R2 OTHERWISE               */  14690006
 /*                                                                         */  00771000
 /* 05/05/92 JAC   7V0  CR11114  MERGE BFS/PASS COMPILERS                   */
 /*                                                                         */
 /* 12/23/92 PMA   8V0  *        MERGED 7V0 AND 24V0 COMPILERS.             */
 /*                              * REFERENCE 24V0 CR/DRS                    */
 /*                                                                         */
 /* 10/7/93  RSJ   26V0/ 106757 INSTRUCTION COUNT FREQUENCIES INCORRECT     */
 /*                10V0                                                     */
 /*                                                                         */
 /* 05/18/95 DAS   27V0/ 107880 BI506 ERROR WITH TEMPORARY LOOP COUNTER     */
 /*                11V0                                                     */
 /*                                                                         */
 /*                                                                         */
 /* 11/22/94 TEV   27V0/ 102964 INCORRECT CODE GENERATED FOR NAME           */
 /*                11V0         DEREFERENCE                                 */
 /*                                                                         */
 /*                                                                        */
 /* 12/05/94 DAS   27V0/ 107698 ILLEGAL DISPLACEMENT VALUE IN INDEXED      */
 /*                11V0         RS INSTUCTION (DO CASE)                    */
 /*                                                                        */
 /* 11/03/98 SMR   29V0  111317 NAME REMOTE DEREFERENCE OF STRUCTURE       */
 /*                14V0         NODE FAILS                                 */
 /*                                                                        */
 /* 08/03/04 JAC   32V0  120266 SLL AND SRL INSTRUCTION INCORRECTLY        */
 /*                17V0         COMBINED                                   */
 /***************************************************************************/
                                                                                07162000
 /* PROCEDURE TO CONDENSE OBJECT CODE, ELIMINATING OR SHORTENING INSTRUCTIONS   07162500
   */                                                                           07163000
OBJECT_CONDENSER:                                                               07163500
   PROCEDURE;                                                                   07164000
      DECLARE CURRENT_LINE FIXED,                                               07164500
         DELTA FIXED;                                                           07165000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DEBUG INFO FOR LABEL VER ERROR */
      DECLARE  LAST_SMRK_PRCSD BIT(16);
 ?/
      DECLARE (LOOKING_AHEAD, RLD_FLAG) BIT(1);                                 07165100
      DECLARE TEMP1 FIXED;                                                      07165110

 /?P  /* SSCR 8348 -- BRANCH CONDENSING   */
      DECLARE (TARGET_LBL,BRANCH_NUM) BIT(16),                                  07165210
         CONDENSED BIT(1);                                                      07165310
                                                                                07165410
      DECLARE BRANCH_FLINK(1)   LITERALLY 'BRANCH_TBL(%1%).B_FLINK',            07165510
         BRANCH_BLINK(1)   LITERALLY 'BRANCH_TBL(%1%).B_BLINK',                 07165610
         BRANCH_ADDR(1)    LITERALLY 'BRANCH_TBL(%1%).B_ADDR',                  07165710
         BRANCH_TARG(1)    LITERALLY 'BRANCH_TBL(%1%).TARGET',                  07165810
         BRANCH_INCODE(1)  LITERALLY 'BRANCH_TBL(%1%).INT_CODELINE';            07165910
 ?/                                                                             07166010
                                                                                07169500
 /* ROUTINE TO VERIFY THAT LABEL DEFINITIONS HAVE BEEN PROPERLY UPDATED  */     07170000
VERIFY:                                                                         07170500
      PROCEDURE(LBL);                                                           07171000
         DECLARE LBL BIT(16);                                                   07171500
         IF LOCATION(LBL) ^= CURRENT_ADDRESS THEN                               07172000
            DO;                                                                 07172500
            CALL ERRORS(CLASS_BI,509,' '||LBL);                                 07172510
            IF MAX_SEVERITY = 0 THEN                                            07172520
               MAX_SEVERITY = 1;                                                07172530
         END;                                                                   07172540
      END VERIFY;                                                               07173000

 /?P  /* SSCR 8348 -- BRANCH CONDENSING   */

      /* INSERT AT END OF QUEUE */                                              07173190
BRANCH_INSRT:                                                                   07173240
      PROCEDURE;                                                                07173290
         NEXT_ELEMENT(BRANCH_TBL);                                              07173340
         BRANCH_NUM = RECORD_TOP(BRANCH_TBL);                                   07173390
         IF FIRSTBRANCH(CURRENT_ESDID) = 0 THEN DO;                             07173440
            FIRSTBRANCH(CURRENT_ESDID), LASTBRANCH(CURRENT_ESDID) = BRANCH_NUM; 07173490
            BRANCH_BLINK(BRANCH_NUM) = 0;                                       07173540
         END;                                                                   07173590
         ELSE DO;                                                               07173640
            BRANCH_FLINK(LASTBRANCH(CURRENT_ESDID)) = BRANCH_NUM;               07173690
            BRANCH_BLINK(BRANCH_NUM) = LASTBRANCH(CURRENT_ESDID);               07173740
            LASTBRANCH(CURRENT_ESDID) = BRANCH_NUM;                             07173790
         END;                                                                   07173840
         BRANCH_FLINK(BRANCH_NUM) = 0;                                          07173890
         BRANCH_ADDR(BRANCH_NUM) = CURRENT_ADDRESS;                             07173940
         BRANCH_TARG(BRANCH_NUM) = TARGET_LBL;                                  07173990
         BRANCH_INCODE(BRANCH_NUM) = CURRENT_LINE;                              07174040
      END BRANCH_INSRT;                                                         07174090
                                                                                07174140
BRANCH_DELETE:                                                                  07174190
      PROCEDURE(BRANCH_DEL);                                                    07174240
         DECLARE BRANCH_DEL BIT(16);                                            07174290
         IF BRANCH_DEL = FIRSTBRANCH(CURRENT_ESDID) THEN DO;                    07174340
            FIRSTBRANCH(CURRENT_ESDID) = BRANCH_FLINK(BRANCH_DEL);              07174390
            BRANCH_BLINK(BRANCH_FLINK(BRANCH_DEL))= 0;                          07174440
            IF BRANCH_DEL = LASTBRANCH(CURRENT_ESDID)                           07174490
               THEN LASTBRANCH(CURRENT_ESDID) = 0;                              07174540
         END;                                                                   07174590
         ELSE IF BRANCH_DEL = LASTBRANCH(CURRENT_ESDID) THEN DO;                07174640
            LASTBRANCH(CURRENT_ESDID) = BRANCH_BLINK(BRANCH_DEL);               07174690
            BRANCH_FLINK(BRANCH_BLINK(BRANCH_DEL)) = 0;                         07174740
         END;                                                                   07174790
         ELSE DO;                                                               07174840
            BRANCH_FLINK(BRANCH_BLINK(BRANCH_DEL)) = BRANCH_FLINK(BRANCH_DEL);  07174890
            BRANCH_BLINK(BRANCH_FLINK(BRANCH_DEL)) = BRANCH_BLINK(BRANCH_DEL);  07174940
         END;                                                                   07174990
      END BRANCH_DELETE;                                                        07175040
                                                                                07175090
 /* UPDATE ADDRESSES WHERE BRANCHES ARE SUPPOSEDLY LOCATED */                   07175140
BRANCH_UPDATE:                                                                  07175190
      PROCEDURE(N);                                                             07175240
         DECLARE N BIT(16);                                                     07175290
         DECLARE PTR BIT(16);                                                   07175340
         PTR = LASTBRANCH(CURRENT_ESDID);                                       07175390
         DO WHILE (PTR > 0) & (BRANCH_ADDR(PTR) > CURRENT_ADDRESS);             07175440
            BRANCH_ADDR(PTR) = BRANCH_ADDR(PTR) - N;                            07175490
            PTR = BRANCH_BLINK(PTR);                                            07175540
         END;                                                                   07175590
      END BRANCH_UPDATE;                                                        07175640
 ?/                                                                             07175690
                                                                                07177000
 /* ROUTINE TO BACK OFF LABEL DEFINITIONS BY SPECIFIED AMOUNT  */               07177500
LABEL_UPDATE:                                                                   07178000
      PROCEDURE(LEN);                                                           07178500
         DECLARE (LEN, PTR) BIT(16);                                            07179000
         LOCCTR(CURRENT_ESDID) = LOCCTR(CURRENT_ESDID) - LEN;                   07179500
         PTR = LASTLABEL(CURRENT_ESDID);                                        07180000
         DO WHILE PTR > 0;                                                      07180500
            IF LOCATION(PTR) > CURRENT_ADDRESS THEN                             07181000
               LOCATION(PTR) = LOCATION(PTR) - LEN;                             07181500

 /?P  /* SSCR 8348 -- BRANCH CONDENSING */
            ELSE IF LOCATION(PTR) >= 0 THEN RETURN;                             07182000
 ?/
 /?B  /* SSCR 8348 -- BRANCH CONDENSING */
            ELSE RETURN;
 ?/
            PTR = LOCATION_LINK(PTR);                                           07182500
         END;                                                                   07183000
      END LABEL_UPDATE;                                                         07183500
                                                                                07184000
 /* ROUTINE TO STEP CURRENT ADDRESS BY SPECIFIED AMOUNT */                      07184500
UPLOC:                                                                          07185000
      PROCEDURE(N);                                                             07185500
         DECLARE N BIT(16);                                                     07186000
         N = SHR(N+1, 1);                                                       07186500
         IF EMITTING THEN                                                       07187000
            CURRENT_ADDRESS = CURRENT_ADDRESS + N;                              07187500
         ELSE CALL LABEL_UPDATE(N);                                             07188000
         DELTA = 0;                                                             07188500
      END UPLOC;                                                                07189000
                                                                                07189710
 /* CONDENSE ALGORITHM : AP101 VERSION  */                                      07190000
CONDENSE:                                                                       07190500
      PROCEDURE;                                                                07191000
         DECLARE DEST FIXED;                                                    07191500
         DECLARE XX BIT(8);                                                     07191510
         CALL NEXT_REC(1);                                                      07192000
         CALL GET_INST_R_X;                                                     07192500
         IF ^EMITTING THEN DO;                                                  07193000
            CALL UPLOC(4);                                                      07193500
            IF LHS(1) = CSYM THEN CALL SKIP(1);                                 07194000
         END;                                                                   07194500
         ELSE IF LHS(1) >= CSYM & LHS(1) < ADCON THEN DO;                       07195000
            IF LHS(1) = CSYM THEN DO;                                           07195500
               CALL NEXT_REC(2);                                                07196000
               TEMP = RHS(2) & "FFFF";                                          07196010
               IF RHS(1) = PRELBASE THEN DO;                                    07196020
                  TEMP = TEMP + PROGDELTA;                                      07196030
                  CODE(GET_CODE(CODE_LINE-1)) = SHL(LHS(2),16) + TEMP;          07196040
               END;                                                             07196050
            END;                                                                07197000
            ELSE IF LHS(1) = CLBL THEN DO;                                      07197500
               TEMP = LABEL_ARRAY(RHS(1)) + PROGDELTA;                          07197550
               /* D107698: FIXUP FOR WHEN CASE TABLE ADDRESS WILL FIT */
               /* (<=2047) IN INDEXED LH: MAKE BFS CODE COMMON TO    */
               /* ELIMINATE AHI AND PUT CASE TABLE DISP INTO LH. */
               IF TEMP < 2048 THEN DO;
                  CALL NEXT_REC(2);
                  IF (SHR(RHS(2),8) & "FF") = LH THEN DO;
                     CODE(GET_CODE(CURRENT_LINE)) = SHL(RXTYPE,16) | RHS(2);
                     CODE(GET_CODE(CODE_LINE-1)) = SHL(NOP,16);
                     CALL UPLOC(4);
                     CALL LABEL_UPDATE(2);
                     CALL SKIP_ADDR;
                     RETURN;
                  END;
                  ELSE CODE_LINE = CODE_LINE - 1;
                  /* D107698: TEMP WAS CLOBBERED BY NEXT_REC */                 07197550
                  TEMP = LABEL_ARRAY(RHS(1)) + PROGDELTA; /*D107698*/           07197550
               END;                                                             07198200
            END;                                                                07198250
            ELSE TEMP = CONSTANT_PTR(ABS(RHS(1)));                              07198300
PRESS_ADDR:                                                                     07198500
            IF CHECK_SRS(INST, IX | IA, 0, TEMP + DELTA) = SRSTYPE THEN DO;     07199000
               IF LOOKING_AHEAD & INST = LA THEN DO;                            07199010
                  DEST = CODE_LINE;                                             07199020
                  CALL NEXT_REC(1);                                             07199030
                  IF LHS(1) = PROLOG THEN DO;                                   07199040
                     CALL NEXT_REC(1);                                          07199050
                     CALL NEXT_REC(2);                                          07199060
                     CALL NEXT_REC(3);                                          07199070
                  END;                                                          07199080
                  CODE_LINE = DEST;                                             07199090
                  IF LHS(1) = SSTYPE THEN IF                                    07199100
                     LHS(2) = CSYM THEN IF                                      07199110
                     RHS(2) = R THEN IF RHS(3) = 0 THEN DO;                     07199120
                     CODE(GET_CODE(CURRENT_LINE))=SHL(SSTYPE,16)+(RHS(1)&"FFFF")07199130
                        ;                                                       07199140
                     TEMP = CODE(GET_CODE(DEST+4));                             07199150
                     CODE(GET_CODE(DEST)) = TEMP;                               07199160
                     CODE(GET_CODE(DEST+1))=SHL(BR_ARND,16)+2;                  07199170
                     XLEN = DEST+1;                                             07199172
                     CODE(GET_CODE(DEST+2))=DEST+5;                             07199180
                     CALL UPLOC(4);                                             07199190
                     CALL LABEL_UPDATE(2);                                      07199210
                     CODE_LINE = DEST + 5;                                      07199220
/*------------------------------ #DREG ------------------------------*/         03511034
/* IF LA R3 ELIMINATED, THEN WE MUST ALSO ELIMINATE THE R3 RESTORE   */         03512034
                     IF DATA_REMOTE & (R = 3) THEN DO;                          03513037
                        /* DR107880: WE DONT RESTORE BEFORE CHECKPOINT*/        03514040
                        /* SO SKIP OVER IT IF A CHECKPOINT IS HERE.   */        03514040
           /*DR107880*/ DO WHILE                                                03514040
           /*DR107880*/ (SHR(CODE(GET_CODE(CODE_LINE)),16) = NOP) |             03514040
           /*DR107880*/ (SHR(CODE(GET_CODE(CODE_LINE)),16) = BR_ARND);          03514040
           /*DR107880*/    IF SHR(CODE(GET_CODE(CODE_LINE)),16)^=BR_ARND        03514040
           /*DR107880*/    THEN DO;                                             03517040
           /*DR107880*/       IF SHR(CODE(GET_CODE(CODE_LINE+2)),16)=           03514040
           /*DR107880*/          SRSTYPE                                        03514040
           /*DR107880*/          THEN CALL UPLOC(2);                            03517040
           /*DR107880*/          ELSE CALL UPLOC(4); /*RXTYPE*/                 03517040
           /*DR107880*/    END;                                                 03514040
           /*DR107880*/    CODE_LINE = CODE_LINE + 5;                           03514040
           /*DR107880*/ END;                                                    03514040
                        IF SHR(CODE(GET_CODE(CODE_LINE)),16) = RXTYPE           03514040
                        THEN DO; /* IHL,SLL RESTORE */                          03514140
           /*DR107880*/    CODE(GET_CODE(CODE_LINE))=SHL(BR_ARND,16)+3;         07199170
           /*DR107880*/    CODE(GET_CODE(CODE_LINE+1))=CODE_LINE+5;             07199170
           /*DR107880*/    CODE_LINE = CODE_LINE + 5;                           03514740
                           CALL LABEL_UPDATE(3);                                03514640
                        END;                                                    03514840
                        ELSE DO; /* LH RESTORE */                               03514940
           /*DR107880*/    CODE(GET_CODE(CODE_LINE))=SHL(BR_ARND,16)+1;         07199170
           /*DR107880*/    CODE(GET_CODE(CODE_LINE+1))=CODE_LINE+3;             07199170
           /*DR107880*/    CODE_LINE = CODE_LINE + 3;                           03518040
                           CALL LABEL_UPDATE(1);                                03517040
                        END;                                                    03518140
                     END;                                                       03519037
/*-------------------------------------------------------------------*/         03519134
                     LOOKING_AHEAD = FALSE;                                     07199230
                     RETURN;                                                    07199240
                  END;                                                          07199250
               END;                                                             07199260
               CALL UPLOC(2);                                                   07199500
               CODE(GET_CODE(CURRENT_LINE)) = SHL(SRSTYPE, 16) + (RHS & "FFFF");07200000
               CALL LABEL_UPDATE(1);                                            07200500
            END;                                                                07201000
            ELSE CALL UPLOC(4);                                                 07201500
         END;  /* LITERAL COMPRESSION  */                                       07202000
         ELSE IF LHS(1) = XPT THEN DO;                                          07202500
 /?P  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */
            TEMP = R_ADDR(RHS(1));                                              07203100
 ?/
 /?B  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */
            TEMP = R_INX(RHS(1));
 ?/
            GOTO PRESS_ADDR;                                                    07203150
         END;                                                                   07204000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
         ELSE IF LHS(1) >= LBL & LHS(1) <= STNO THEN DO;                        07204500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
         ELSE IF LHS(1) >= LBL & LHS(1) <= STNO & CURRENT_ADDRESS > 0 THEN DO;
            /* TEST FOR CURRENT_ADDRESS IS NECESSARY IN ORDER TO KEEP THE BFW
               GENERATED FOR ALTERNATE ENTRIES AS A FULLWORD INSTRUCTION */
 ?/
            DO CASE LHS(1) - LBL;                                               07205000
               TEMP = SYT_LABEL(RHS(1));                                        07205500
               TEMP = LABEL_ARRAY(RHS(1));                                      07206000
               TEMP = RHS(1);                                                   07206500
            END;                                                                07207000

 /?P        /*  SSCR 8348 -- BRANCH CONDENSING  */
            TARGET_LBL = REAL_LABEL(TEMP);                                      07207100
 ?/
            DEST = CURRENT_ADDRESS + 1 - LOCATION(REAL_LABEL(TEMP));            07207500
            IF CSECT_BOUND(CURRENT_ESDID) = 0 THEN XX = 0;                      07207510
            IF INST = BC & DEST = -1 THEN DO;                                   07208000
               CODE(GET_CODE(CURRENT_LINE)) = SHL(NOP, 16);                     07208500
               CALL LABEL_UPDATE(2);                                            07209500
            END;                                                                07210000
            ELSE IF INST = BC & DEST = -3 THEN DO;                              07210010
               DECLARE NEXT_LINE FIXED;                                         07210020
               NEXT_LINE = CODE_LINE;                                           07210030
               CALL NEXT_REC(2);                                                07210040
               CALL NEXT_REC(3);                                                07210050
               CODE_LINE = NEXT_LINE;                                           07210060
               IF LHS(2)=RXTYPE THEN IF (SHR(RHS(2),4)&"FFF")=SHL(BC,4)+RM THEN 07210070
                  IF LHS(3) >= LBL THEN IF LHS(3) <= STNO THEN DO;              07210080
                  CODE(GET_CODE(CURRENT_LINE)) = SHL(NOP, 16);                  07210090
                  CALL LABEL_UPDATE(2);                                         07210110
                  CODE(GET_CODE(NEXT_LINE)) = SHL(LHS(2),16) +                  07210120
                     (RHS(2) & "FFFF") - SHL(R,4);                              07210130
                  RETURN;                                                       07210140
               END;                                                             07210150
 /?P  /* SSCR 8348 -- BRANCH CONDENSING */
               CALL BRANCH_INSRT;                                               07210160
               CALL UPLOC(4);                                                   07210165
            END;                                                                07210170
            ELSE IF INST = BC | (INST = BCT & DEST >= 0) THEN DO;               07210500
               CALL BRANCH_INSRT;                                               07211000
               CALL UPLOC(4);                                                   07211500
            END;                                                                07212000
 ?/
 /?B  /* SSCR 8348 -- BRANCH CONDENSING */
               GO TO PRESS_BC;
            END;                                                                07210170
            ELSE IF INST = BC & ABS(DEST) <= 55 THEN DO;
      PRESS_BC:
               CALL UPLOC(2);
               CODE(GET_CODE(CURRENT_LINE)) = SHL(SRSTYPE, 16) +
                  (RHS & "FFFF") + "4000";
               CALL LABEL_UPDATE(1);
            END;
            ELSE IF INST=BCT & DEST>=0 & DEST <= 55 THEN GO TO PRESS_BC;
            ELSE IF (INST=BVC) & (DEST<=0) & (DEST>=-55) THEN GO TO PRESS_BC;
 ?/
            ELSE CALL UPLOC(4);                                                 07214500
         END;  /* LABEL COMPRESSION  */                                         07215000
         ELSE IF LHS(1) = EXTSYM THEN DO;                                       07215500
            IF RHS(1) > PROGPOINT THEN IF RHS(1) <= PROCLIMIT THEN              07216000
               IF ^OLD_LINKAGE THEN IF NOT_LEAF(RHS(1)) THEN IF INST = BAL THEN 07216500
               CODE(GET_CODE(CURRENT_LINE)) = SHL(LHS,16) + SHL(SCAL,8) +       07217000
               SHL(TEMPBASE,4) + (RHS&"F");                                     07217500
            CALL UPLOC(4);                                                      07218000
         END;                                                                   07218500
         ELSE IF LHS(1) = SYM THEN DO;                                           7218510
/*---------------------------- #DREG -------------------------------*/          07218520
/* IF BASE = R1,DONT CHANGE IT TO R3.(SEE CHECK_LOCAL_SYM)          */          07218520
            IF ^(DATA_REMOTE & (SYT_BASE(RHS(1)) = 1)) THEN                     07218520
/*------------------------------------------------------------------*/          07218520
            IF CURRENT_ESDID = SYT_SCOPE(RHS(1)) THEN IF                        07218520
               SYT_BASE(RHS(1)) ^= TEMPBASE THEN IF                             07218530
               SYT_LINK2(RHS(1)) > 0 THEN IF                                    07218540
               NOT_LEAF(CURRENT_ESDID) = 3 THEN IF                              07218550
               /* CHECK IF VARIABLE IS NOT A NAME BEFORE CHANGING */
               /* THE INSTRUCTION. WE DO NOT WANT TO USE THE WRONG*/
               /* BASE REGISTER IF DEREFERENCING A NAME VARIABLE. */
               (SYT_FLAGS(RHS(1)) & NAME_FLAG) = 0 THEN IF /*DR102964*/
               CHECK_SRS(INST,IX|IA,0,SYT_LINK2(RHS(1))+DELTA)=SRSTYPE THEN DO; 07218560
               CALL UPLOC(2);                                                    7218580
               CODE(GET_CODE(CURRENT_LINE)) = SHL(SRSTYPE,16) + (RHS & "FFFF");  7218590
               CODE(GET_CODE(CURRENT_LINE+1)) = SHL(IMD,16) + (RHS(1) & "FFFF"); 7218600
               CALL LABEL_UPDATE(1);                                             7218610
               RETURN;                                                          07218615
            END;                                                                 7218620
            IF SYT_BASE(RHS(1))=PROGBASE | SYT_BASE(RHS(1))=TEMPBASE THEN DO;   07218622
               TEMP = SYT_DISP(RHS(1));                                         07218624
               GO TO PRESS_ADDR;                                                07218626
            END;                                                                07218628
            ELSE CALL UPLOC(4);                                                  7218630
         END;                                                                    7218640
         ELSE CALL UPLOC(4);                                                    07227000
      END CONDENSE;                                                             07227500
                                                                                07227508
 /* ROUINE TO COMBINE REDUNDANT SHIFT INSTRUCTIONS */                           07227516
SHIFT_CONDENSE:                                                                 07227524
      PROCEDURE;                                                                07227532
         DECLARE NEXT_LINE FIXED, INST2 BIT(16);                                07227540
         CALL NEXT_REC(1);                                                      07227548
         IF LHS(1) ^= SHCOUNT THEN DO;                                          07227556
            CALL UPLOC(2);                                                      07227564
            IF LHS(1) = CSYM THEN CALL SKIP(1);                                 07227572
         END;                                                                   07227580
         ELSE DO;                                                               07227588
            CALL GET_INST_R_X;                                                  07227596
            IF (INST ^= SRL & INST ^= SLL & INST ^= SRA) THEN                   07227604
               CALL UPLOC(2);                                                   07227612
            ELSE DO;                                                            07227620
               NEXT_LINE = CODE_LINE;                                           07227628
               CALL NEXT_REC(2);                                                07227636
               INST2 = SHR(RHS(2),8) & "FF";                                    07227644
               CALL NEXT_REC(3);                                                07227652
               IF LHS(2) ^= SRSTYPE | LHS(3) ^= SHCOUNT THEN DO;                07227660
NORMAL_SRS:                                                                     07227668
                  CALL UPLOC(2);                                                07227676
                  CODE_LINE = NEXT_LINE;                                        07227684
                  RETURN;                                                       07227692
               END;                                                             07227700
               ELSE IF (RHS&"FF") ^= (RHS(2)&"FF") THEN                         07227708
                  GO TO NORMAL_SRS;                                             07227716
               ELSE IF INST2 ^= SLL & INST2 ^= SRL THEN                         07227724
                  GO TO NORMAL_SRS;                                             07227732
               ELSE IF INST2 = INST THEN                                        07227740
                  RHS(1) = RHS(1) + RHS(3);                                     07227748
               ELSE IF INST = SRA & INST2 ^= SLL THEN                           07227750
                  GO TO NORMAL_SRS;                                             07227752
               ELSE IF INST = SLL & INST2 = SRL THEN  /*DR120266*/
                  GO TO NORMAL_SRS;                   /*DR120266*/
               ELSE IF RHS(1) > RHS(3) THEN                                     07227756
                  RHS(1) = RHS(1) - RHS(3);                                     07227764
               ELSE DO;                                                         07227772
                  RHS(1) = RHS(3) - RHS(1);                                     07227780
                  RHS = RHS(2);                                                 07227788
                  INST2 = INST;                                                 07227796
               END;                                                             07227804
               INST = SHR(RHS,8) & "FF";                                        07227820
               CODE(GET_CODE(CURRENT_LINE)) = SHL(NOP, 16);                     07227828
               IF RHS(1) = 0 THEN DO;                                           07227836
                  CODE(GET_CODE(NEXT_LINE)) = SHL(NOP, 16);                     07227844
                  CALL LABEL_UPDATE(2);                                         07227852
               END;                                                             07227868
               ELSE DO;                                                         07227876
                  CALL UPLOC(2);                                                07227880
                  CODE(GET_CODE(NEXT_LINE)) = SHL(LHS,16) | (RHS&"FFFF");       07227884
                  CODE(GET_CODE(NEXT_LINE+1)) = SHL(LHS(1),16)| (RHS(1)&"FFFF");07227892
                  CALL LABEL_UPDATE(1);                                         07227900
               END;                                                             07227908
            END;                                                                07227916
         END;                                                                   07227924
      END SHIFT_CONDENSE;                                                       07227932

/?P  /* SSCR 8348 -- BRANCH CONDENSING */                                       07228600

CONDENSE_A_BRANCH:PROCEDURE(BRANCH_COND);                                       07228650
         DECLARE BRANCH_COND BIT(16);                                           07228700
         CODE_LINE = BRANCH_INCODE(BRANCH_COND);                                07228750
         CALL NEXT_REC(0);                                                      07228800
         CALL GET_INST_R_X;                                                     07228850

         IF ^(INST = BC | INST = BCT)  THEN DO;                                 07228900

/* IF BRANCH CONDENSING IS IMPLEMENTED FOR BFS, THIS NEXT LINE WOULD */
/*       BE BFS SPECIFIC, AND THE LINE PREVIOUS WOULD BE PASS        */
/*       SPECIFIC.                                                   */
/*                                                                   */
/******* IF ^(INST = BC | INST = BCT | INST = BVC)  THEN DO; *********/         07228900

            CALL ERRORS(CLASS_BI,505);                                          07228950
            ERROR# = ERROR# + 1;                                                07229000
            CALL BRANCH_DELETE(BRANCH_COND);                                    07229050
         END;                                                                   07229100
         ELSE DO;                                                               07229150
            CONDENSED = TRUE;                                                   07229200
            CURRENT_ADDRESS = BRANCH_ADDR(BRANCH_COND);                         07229250
            CODE(GET_CODE(CODE_LINE - 1)) =                                     07229300
               SHL(SRSTYPE,16) + (RHS & "FFFF") + "4000";                       07229350
            CALL LABEL_UPDATE(1);                                               07229400
            CALL BRANCH_UPDATE(1);                                              07229450
            CALL BRANCH_DELETE(BRANCH_COND);                                    07229500
         END; /* ELSE */                                                        07229550
      END CONDENSE_A_BRANCH;                                                    07229600
                                                                                07229650
                                                                                07229700
                                                                                07229750
 /* TRIES TO CONDENSE ALL BRANCHES FOR A CSECT.  GOES THROUGH                   07229800
      LOOP UNTIL NO MORE BRANCHES CAN BE CONDENSED. */                          07229850
BRANCH_CONDENSE:                                                                07229900
      PROCEDURE;                                                                07229950
         DECLARE STABLE  BIT(1),                                                07230000
            DEST   FIXED;                                                       07230050
         CONDENSED = FALSE;                                                     07230100
         DO UNTIL STABLE;                                                       07230150
            STABLE = TRUE;                                                      07230200
            BRANCH_NUM = FIRSTBRANCH(CURRENT_ESDID);                            07230250
            DO WHILE BRANCH_NUM > 0;                                            07230300
               DEST = BRANCH_ADDR(BRANCH_NUM) + 1 -                             07230350
                  LOCATION(BRANCH_TARG(BRANCH_NUM));                            07230400
               IF  DEST <= 55 & DEST >= -56 THEN DO;                            07230450
 /* LOCATION - 2 SINCE  1) BRANCH IS CONDENSED AND 2) LABELS                    07230510
                     REMAIN AT THE END OF THE PRIMARY CSECT */                  07230520
                  CALL CONDENSE_A_BRANCH(BRANCH_NUM);                           07230700
                  STABLE = FALSE;                                               07230750
               END; /* IF */                                                    07230800
               BRANCH_NUM = BRANCH_FLINK(BRANCH_NUM);                           07230850
            END; /* WHILE */                                                    07230900
         END; /* UNTIL */                                                       07230950
         BRANCH_NUM = 0;                                                        07231000
      END BRANCH_CONDENSE;                                                      07231050
 ?/                                                                             07231100

 /* MAKES FIRST PASS THROUGH THE INTERMEDIATE CODE, CONDENSING EVERYTHING       07233450
      EXCEPT BRANCHES */                                                        07233500
PASS1_OBJ_CONDENSER:                                                            07233550
      PROCEDURE;                                                                07233600
         MAX_CODE_LINE=CODE_LINE;                                               07233650
         CODE_LINE = 0;                                                         07233700
         GENERATING, EMITTING = TRUE;                                           07233750
         DO WHILE GENERATING;                                                   07233800
            CURRENT_LINE = CODE_LINE;                                           07233850
            CALL NEXT_REC(0);                                                   07233900
            IF LHS = 0 THEN CALL UPLOC(2);                                      07233950
            ELSE IF LHS < 32 THEN CALL ERRORS(CLASS_BI,506,' '||LHS);           07234000
            ELSE DO CASE LHS-32;                                                07234050
 /* 32 = RR INST  */                                                            07234100
               CALL UPLOC(2);                                                   07234150
 /* 33 = RX / RS / SI INST  */                                                  07234200
               CALL CONDENSE;  /* ONLY CANDIDATES FOR POSSIBLE CONDENSATION  */ 07234250
 /* 34 = SS INST  */                                                            07234300
               DO;                                                              07234350
                  CALL UPLOC(4);                                                07234400
                  CALL SKIP_ADDR;                                               07234450
                  CALL SKIP(1);                                                 07234500
               END;                                                             07234550
 /* 35 = DELTA  */                                                              07234600
               DELTA = DELTA + RHS;                                             07234650
 /* 36 = SYMBOLIC LABEL  */                                                     07234700
               CALL VERIFY(SYT_LABEL(RHS));                                     07234750
 /* 37 = FLOW LABEL  */                                                         07234800
               CALL VERIFY(LABEL_ARRAY(RHS));                                   07234850
 /* 38 = CSECT  */                                                              07234900
               DO;                                                              07234950
                  CURRENT_ESDID = RHS;                                          07235000
                  IF CURRENT_ESDID = FSIMBASE THEN                              07235050
                     CURRENT_ESDID = DATABASE;                                  07235100
                  CALL NEXT_REC(1);                                             07235150
                  IF TEMP < 0 THEN DO;                                          07235200
                     IF RHS = DATABASE THEN DO;                                 07235250
                        TEMP = TEMP + PROGDELTA;                                07235300
                        CODE(GET_CODE(CODE_LINE-1)) = TEMP;                     07235350
                     END;                                                       07235400
                     CURRENT_ADDRESS = TEMP & POSMAX;                           07235450
                  END;                                                          07235500
               END;                                                             07235550
 /* 39 = DATA BLOCK  */                                                         07235600
               DO;                                                              07235650
                  CALL UPLOC(SHL(RHS,2));                                       07235700
                  CALL SKIP(RHS);                                               07235750
               END;                                                             07235800
 /* 40 = NORMAL ADCON */                                                        07235850
ADCON_PROC:                                                                     07235900
               DO;                                                              07235950
                  CALL UPLOC(4);                                                07236000
                  IF RHS = DATABASE THEN DO;                                    07236050
                     CALL NEXT_REC;                                             07236100
                     IF RLD_FLAG THEN              /*DR111317*/
                        LHS = LHS - PROGDELTA;     /*DR111317*/
                     ELSE LHS = LHS + PROGDELTA;   /*DR111317*/                 07236150
                     CODE(GET_CODE(CODE_LINE-1)) = SHL(LHS,16) + (RHS&"FFFF");  07236200
                  END;                                                          07236250
                  ELSE CALL SKIP(1);                                            07236300
               END;                                                             07236350
 /* 41 = LABEL ADCON */                                                         07236400
               GO TO HADCON_PROC;                                               07236450
 /* 42 = LITERAL ADCON */                                                       07236500
               GO TO ADCON_PROC;                                                07236550
 /* 43 = RLD ENTRY */                                                           07236600
               RLD_FLAG = SHR(RHS, 15);                                         07236650
 /* 44 = STATEMENT MARK */                                                      07236700
 /?P  /* CR11114 -- BFS/PASS INTERFACE; DEBUG INFO FOR LABEL VER ERROR*/
               ;                                                                07236750
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DEBUG INFO FOR LABEL VER ERROR*/
            LAST_SMRK_PRCSD = RHS;
 ?/
 /* 45 = TEMP DELTA */                                                          07236800
               DELTA = MAXTEMP(RHS);                                            07236850
 /* 46 = CHARACTER STRING */                                                    07236900
               DO;                                                              07236950
                  CALL UPLOC(RHS);                                              07237000
                  CALL SKIP(SHR(RHS+3,2));                                      07237050
               END;                                                             07237100
 /* 47 = CODE END */                                                            07237150
               DO;                                                              07237200
                  GENERATING = FALSE;                                           07237250
               END;                                                             07237300
 /* 48 = INTERNAL LABEL */                                                      07237350
               CALL VERIFY(RHS);                                                07237400
 /* 49 = OPTIONAL LIST */                                                       07237450
               ;                                                                07237500
 /* 50 = SRS INST  */                                                           07237550
               DO;                                                              07237600
                  CALL SHIFT_CONDENSE;                                          07237650
               END;                                                             07237700
 /* 51 = CNOP */                                                                07237750
               CURRENT_ADDRESS = CURRENT_ADDRESS + RHS & (^RHS);                07237800
 /* 52 = NOP */                                                                 07237850
               CALL SKIP_ADDR;                                                  07237900
 /* 53 = HALFWORD ADDR */                                                       07237950
HADCON_PROC:                                                                    07238000
               DO;                                                              07238050
                  CALL UPLOC(2);                                                07238100
                  IF RHS = DATABASE THEN DO;                                    07238150
                     CALL NEXT_REC;                                             07238200
                     IF RLD_FLAG THEN                                           07238250
                        TEMP = TEMP - PROGDELTA;                                07238300
                     ELSE TEMP = TEMP + PROGDELTA;                              07238350
                     CODE(GET_CODE(CODE_LINE-1)) = TEMP;                        07238400
                  END;                                                          07238450
                  ELSE CALL SKIP(1);                                            07238500
               END;                                                             07238550
 /* 54 = PROC/FUNC PROLOG */                                                    07238600
               LOOKING_AHEAD = RHS;                                             07238650
 /* 55 = Z-TYPE ADCON */                                                        07238700
               GOTO ADCON_PROC;                                                 07238750
 /* 56 = ADDRESS CHECK */                                                       07238800
               ;                                                                07238850
 /* 57 = ADDRESS START */                                                       07238900
               ;                                                                07238950
 /* 58 = BRANCH AROUND */                                                       07239000
               DO;                                                              07239050
                  CALL LABEL_UPDATE(RHS);                                       07239100
                  CALL NEXT_REC;                                                07239150
                  CODE_LINE = TEMP;                                             07239200
               END;                                                             07239250
 /*59 REDIRECT INSTRUCTION STREAM TO AUXILLIARY */                              07239300
               DO;                                                              07239350
                  TEMP1=CODE_LINE;                                              07239400
                  CODE_LINE=MAX_CODE_LINE;                                      07239450
               END;
 /* 60 REDIRECTS THE INSTRUCTION STREAM TO MAIN */                              07239550
               DO;                                                              07239600
                  MAX_CODE_LINE=CODE_LINE;                                      07239650
                  CODE_LINE=TEMP1+RHS-1;                                        07239700
               END;                                                             07239750
 /* 61 PREVENTS THE SPLITTING OF INDIVISIBLE CODE SEQUENCES */                  07239800
               DO;                                                              07239850
                  SPLIT_DELTA = RHS;                                            07239900
               END;                                                             07239950
 /*62 = CSECT HEADER FOR INITIALIZING DATA AREAS*/                              07240000
               DO;                                                              07240050
                  CURRENT_ESDID = RHS;                                          07240100
                  CALL NEXT_REC(1);                                             07240150
                  CURRENT_ADDRESS = TEMP& POSMAX;                               07240200
                  CODE(GET_CODE(CODE_LINE-2))=SHL(CSECT,16)|CURRENT_ESDID;      07240250
               END;                                                             07240300
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NEW INTERMEDIATE OPCODES */
            /*--- 63 = STORE PROTECT SET (SPSET) ---*/
            ;
            /*--- 64 = PUSH LOCATION COUNTER (LPUSH) ---*/
               DO;
               CALL NEXT_REC;
               PUSHED_LOCCTR(CURRENT_ESDID) = CURRENT_ADDRESS;
               CURRENT_ADDRESS = TEMP & "FFFFFF";
               END;                                                             07239500
            /*--- 65 = POP LOCATION COUNTER (LPOP) ---*/
            CURRENT_ADDRESS = PUSHED_LOCCTR(CURRENT_ESDID);
 ?/
            END; /* CASE LHS */                                                 07240350
         END;  /* WHILE GENERATING  */                                          07240400
      END PASS1_OBJ_CONDENSER;                                                  07240450
                                                                                07240500
                                                                                07249050
                                                                                07251750
                                                                                07251800
 /* MAIN LINE OF OBJECT_CONDENSER */                                            07251850
      CALL PASS1_OBJ_CONDENSER;                                                 07251900
                                                                                07251950
 /?P  /* SSCR 8348 -- BRANCH CONDENSING */
      DO CURRENT_ESDID = PROGPOINT TO PROCLIMIT;                                07252000
         CALL BRANCH_CONDENSE;                                                  07252050
      END;                                                                      07252100
 ?/
                                                                                07252150
   END OBJECT_CONDENSER /* $S */;  /* $S */                                     07253500
