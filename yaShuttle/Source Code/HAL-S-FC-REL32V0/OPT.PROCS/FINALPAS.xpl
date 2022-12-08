 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FINALPAS.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  FINAL_PASS                                             */
 /* MEMBER NAME:     FINALPAS                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BUMP_N2           LABEL                                        */
 /*          ARRAYED_CSE       LABEL                                        */
 /*          CSE_PTR           BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          INX               BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          LOOPY#            BIT(16)                                      */
 /*          N2_INX            BIT(16)                                      */
 /*          OLD_COMBINE#      BIT(16)                                      */
 /*          OLD_DENEST#       BIT(16)                                      */
 /*          OP                BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /*          WHILE_END         BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADD                                                            */
 /*          ADLP                                                           */
 /*          AND                                                            */
 /*          AR_ALPHA_MASK                                                  */
 /*          BFNC                                                           */
 /*          C_TRACE                                                        */
 /*          COMBINE#                                                       */
 /*          CSE_TAG                                                        */
 /*          CTR                                                            */
 /*          DENEST#                                                        */
 /*          DLPE                                                           */
 /*          DSUB                                                           */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          IASN                                                           */
 /*          LAST_SMRK                                                      */
 /*          LOOP_HEAD                                                      */
 /*          OR                                                             */
 /*          PHASE1_ERROR                                                   */
 /*          SFAR                                                           */
 /*          SMRK                                                           */
 /*          STACKED_VDLPS                                                  */
 /*          STATISTICS                                                     */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /*          VDOT                                                           */
 /*          VM_LOOP_TAG                                                    */
 /*          XIMD                                                           */
 /*          XSYT                                                           */
 /*          XVAC                                                           */
 /*          XXAR                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADJACENT                                                       */
 /*          AR_DENESTABLE                                                  */
 /*          AR_DIMS                                                        */
 /*          AR_SIZE                                                        */
 /*          ARRAYNESS_CONFLICT                                             */
 /*          ASSIGN_OP                                                      */
 /*          ASSIGN                                                         */
 /*          D_N_INX                                                        */
 /*          IN_AR                                                          */
 /*          IN_VM                                                          */
 /*          LAST_ZAP                                                       */
 /*          LOOP_END                                                       */
 /*          N_INX                                                          */
 /*          NESTED_VM                                                      */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          OPR                                                            */
 /*          REF_TO_DSUB                                                    */
 /*          STRUCTURE_COPIES                                               */
 /*          V_STACK_INX                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGN_TYPE                                                    */
 /*          BUMP_ADD                                                       */
 /*          BUMP_D_N                                                       */
 /*          C_STACK_DUMP                                                   */
 /*          CHECK_ADJACENT_LOOPS                                           */
 /*          CHECK_ARRAYNESS                                                */
 /*          CHECK_LIST                                                     */
 /*          CHECK_VM_COMBINE                                               */
 /*          COMBINE_LOOPS                                                  */
 /*          DENEST                                                         */
 /*          EMPTY_ARRAY                                                    */
 /*          EXTN_CHECK                                                     */
 /*          GET_CLASS                                                      */
 /*          INIT_ARCONFS                                                   */
 /*          LAST_OPERAND                                                   */
 /*          LOOP_OPERANDS                                                  */
 /*          LOOPY                                                          */
 /*          NAME_OR_PARM                                                   */
 /*          NO_OPERANDS                                                    */
 /*          OPOP                                                           */
 /*          POP_LOOP_STACKS                                                */
 /*          PUSH_LOOP_STACKS                                               */
 /*          PUSH_VM_STACK                                                  */
 /*          S                                                              */
 /*          SET_LOOP_END                                                   */
 /*          VM_DETAG                                                       */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          ZAP_TABLES                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FINAL_PASS <==                                                      */
 /*     ==> GET_CLASS                                                       */
 /*     ==> OPOP                                                            */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> S                                                               */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> NAME_OR_PARM                                                    */
 /*     ==> ASSIGN_TYPE                                                     */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> LOOP_OPERANDS                                                   */
 /*         ==> GET_CLASS                                                   */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> EXTN_CHECK                                                      */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> NAME_OR_PARM                                                */
 /*     ==> BUMP_ADD                                                        */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /*     ==> VM_DETAG                                                        */
 /*         ==> OPOP                                                        */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*         ==> LOOPY                                                       */
 /*             ==> GET_CLASS                                               */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*     ==> INIT_ARCONFS                                                    */
 /*     ==> C_STACK_DUMP                                                    */
 /*         ==> FORMAT                                                      */
 /*     ==> CHECK_ADJACENT_LOOPS                                            */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OP                                                     */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> PUSH_LOOP_STACKS                                                */
 /*         ==> INIT_ARCONFS                                                */
 /*         ==> CHECK_ADJACENT_LOOPS                                        */
 /*             ==> OPOP                                                    */
 /*             ==> LAST_OP                                                 */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> MOVE_LOOP_STACK                                             */
 /*         ==> BUMP_LOOPSTACK                                              */
 /*     ==> POP_LOOP_STACKS                                                 */
 /*         ==> MOVE_LOOP_STACK                                             */
 /*     ==> COMBINE_LOOPS                                                   */
 /*         ==> VU                                                          */
 /*             ==> HEX                                                     */
 /*     ==> DENEST                                                          */
 /*         ==> VU                                                          */
 /*             ==> HEX                                                     */
 /*         ==> POP_LOOP_STACKS                                             */
 /*             ==> MOVE_LOOP_STACK                                         */
 /*         ==> MULTIPLY_DIMS                                               */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /*         ==> SET_VAR                                                     */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> LOOPY                                                       */
 /*             ==> GET_CLASS                                               */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> BUMP_REF_OPS                                                */
 /*             ==> POP_COMPARE                                             */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> NO_OPERANDS                                         */
 /*     ==> SET_LOOP_END                                                    */
 /*     ==> PUSH_VM_STACK                                                   */
 /*         ==> MOVE_LOOP_STACK                                             */
 /*     ==> CHECK_VM_COMBINE                                                */
 /*         ==> VM_DETAG                                                    */
 /*             ==> OPOP                                                    */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*             ==> LOOPY                                                   */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*         ==> POP_LOOP_STACKS                                             */
 /*             ==> MOVE_LOOP_STACK                                         */
 /*         ==> COMBINE_LOOPS                                               */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
 /*     ==> CHECK_LIST                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> OPOP                                                        */
 /*         ==> SET_V_M_TAGS                                                */
 /*             ==> LAST_OPERAND                                            */
 /*     ==> EMPTY_ARRAY                                                     */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OPERAND                                                */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /* 05/07/92 JAC   7V0  CR11114  MERGE BFS/PASS COMPILERS                   */
 /*                                                                         */
 /* 05/24/93 LWW  25V0  DR108607 MATRIX COMPARE BETWEEN DOUBLE AND          */
 /*                9V0  SINGLE PRECISION MATRICES FAIL.                     */
 /*                                                                         */
 /* 07/19/99 DAS  30V0/ DR111333 BIX LOOP COMBINING CAUSES INCORRECT        */
 /*               15V0           OBJECT CODE                                */
 /*                                                                         */
 /***************************************************************************/
                                                                                01898593
                                                                                01898594
                                                                                01898600
                                                                                01898610
                                                                                01898620
 /* STACKS FOR FINAL PASS:                                                      01898630
      ADD--CONTAINS ARRAYED LOOPY CSE'S FROM ZAP TO ZAP                         01898640
      DIFF_NODE--CONTAINS POSSIBLE REFERENCES TO CSE'S IN PREVIOUS ARRAYS.      01898650
                 GOES FROM ARRAY LOOP START TO ARRAY LOOP END.                  01898660
                 REFERENCES ARE LISTED.                                         01898670
      NODE2--CONTAINS POSSIBLE REFERENCE TO LOOPY CSE'S IN PREVIOUS VDLPS       01898680
             SHR(OPR(PTR),16) IS THE REFERENCE.                                 01898690
      NODE--CONTAINS START & END OF LOOPS.  A_PARITY = 1 IF ONLY VM_LOOP.       01898700
            BOTH ARE INDEXED BY N_INX*/                                         01898710
                                                                                01898720
                                                                                01898730
                                                                                01898740
                                                                                01898750
 /* FINAL PASS OVER OPTIMIZER HALMAT WHICH DENESTS AND COMBINES LOOPS*/         01898760
FINAL_PASS:                                                                     01898770
   PROCEDURE;                                                                   01898780
      DECLARE (I,OP,TEMP,K,INX,CSE_PTR,WHILE_END,LOOPY#) BIT(16);               01898790
      DECLARE (N2_INX) BIT(16);                                                 01898800
      DECLARE (OLD_COMBINE#,OLD_DENEST#) BIT(16);                               01898810
      IF TRACE THEN OUTPUT = 'FINAL_PASS:  ' || LAST_ZAP;                       01898820
      CALL INIT_ARCONFS;                                                        01898821
      I = LAST_ZAP;                                                             01898830
      A_INX = 0;                                                                01898840
      N_INX = 0;                                                                01898850
      N2_INX = 0;                                                               01898860
                                                                                01898870
      IF PHASE1_ERROR THEN WHILE_END = LAST_SMRK;                               01898880
      ELSE WHILE_END = CTR;                                                     01898890
                                                                                01898900
      DO WHILE I < WHILE_END;                                                   01898910
                                                                                01898920
         OP = OPOP(I);                                                          01898930
                                                                                01898940
         DO CASE GET_CLASS(I);                                                  01898950
                                                                                01898960
            DO;                     /* CLASS 0*/                                01898970
                                                                                01898980
               IF OP = ADLP THEN DO;                                            01898990
 /*ADLP*/        IF ^SHR(OPR(I + 1),8) THEN DO;   /* ADLP*/                     01899000
                     IF ^EMPTY_ARRAY(I) THEN DO;                                01899003
                                                                                01899010
                        D_N_INX = 0;                                            01899020
                        NESTED_VM = TRUE;                                       01899030
                                                                                01899040
                        IN_AR = TRUE;                                           01899050
                        CALL PUSH_LOOP_STACKS(I);                               01899060
                        AR_DIMS = NO_OPERANDS(I);                               01899070
                        AR_DENESTABLE = AR_DIMS > 1;                            01899080
                        AR_SIZE = 1;                                            01899090
                                                                                01899100
                        DO FOR K = I + 1 TO I + AR_DIMS;                        01899110
                                                                                01899120
                           IF XHALMAT_QUAL(K) = XIMD THEN                       01899130
                              AR_SIZE = AR_SIZE * SHR(OPR(K),16);               01899140
                         ELSE AR_SIZE, AR_DENESTABLE, ADJACENT, NESTED_VM=FALSE;01899150
                                                                                01899160
 /* ASTERISK STOPS ALL*/                                                        01899170
 /?P   /* BIX LOOP COMBINING (FOR PASS) */
                           IF SHR(AR_SIZE,15) ^= 0 THEN                         01899180
 ?/
 /?B   /* NO BIX LOOP COMBINING (FOR BFS) */
                           IF SHR(AR_SIZE,15) = 0 THEN                          01899180
 ?/
                            AR_SIZE, AR_DENESTABLE, ADJACENT, NESTED_VM = FALSE;01899185
                        END;                                                    01899190
                        STRUCTURE_COPIES = FALSE;                               01899200
                        IF C_TRACE THEN CALL C_STACK_DUMP;                      01899210
                     END;                                                       01899213
                  END;                                                          01899220
                                                                                01899230
 /*VDLP*/        ELSE DO;                                      /* VDLP*/        01899240
                                                                                01899250
                     IN_VM = TRUE;                                              01899260
                     IF NESTED_VM THEN                                          01899270
                        NESTED_VM = CHECK_ADJACENT_LOOPS(I,1);                  01899280
                     CALL PUSH_LOOP_STACKS(I,1);                                01899290
                     AR_SIZE = SHR(OPR(I + 1),16);                              01899300
                     IF NESTED_VM THEN                                          01899302
                        IF SHR(AR_SIZE * AR_SIZE(1),15) ^= 0 THEN               01899304
                        NESTED_VM = FALSE;                                      01899306
                     IF C_TRACE THEN CALL C_STACK_DUMP;                         01899310
                                                                                01899320
                  END;                                                          01899330
                                                                                01899340
               END;                                                             01899350
                                                                                01899360
               ELSE IF OP = DLPE THEN DO;    /* V/M LOOP ALREADY DENESTED, IF   01899370
                                                 PRESENT*/                      01899380
 /*DLPE*/           IF ^IN_VM THEN DO;                          /* DLPE*/       01899390
                                                                                01899400
                                                                                01899410
                     IF STACKED_VDLPS > 0 THEN DO;                              01899420
                        CALL PUSH_VM_STACK;                                     01899430
                        CALL POP_LOOP_STACKS(0,1);                              01899440
                     END;                                                       01899450
                     ELSE V_STACK_INX = 0;                                      01899460
                     LOOP_END = I;                                              01899470
                     CALL SET_LOOP_END(I);                                      01899480
                     IF AR_DENESTABLE THEN CALL DENEST(I);                      01899490
                     IF ADJACENT THEN IF AR_SIZE = AR_SIZE(1) AND               01899500
                        ^((REF_TO_DSUB | REF_TO_DSUB(1)) &                      01899510
                        (ASSIGN | ASSIGN(1))) THEN DO;                          01899520
                                                                                01899530
                        TEMP = TRUE;                                            01899540
                                                                                01899550
                        DO FOR K = 1 TO AR_DIMS;                                01899560
                                                                                01899570
                           IF (OPR(LOOP_HEAD + K) & AR_ALPHA_MASK) ^=           01899580
                              (OPR(LOOP_HEAD(1) + K) & AR_ALPHA_MASK) THEN      01899590
                              TEMP = FALSE;                                     01899600
                                                                                01899610
                        END;                                                    01899620
                        IF ARRAYNESS_CONFLICT THEN TEMP = FALSE;                01899621
                        IF REF_TO_STRUC THEN TEMP = FALSE; /* DR111333 */
                                                                                01899630
                        IF TEMP THEN DO;                                        01899640
                           CALL COMBINE_LOOPS;                                  01899650
                           CALL POP_LOOP_STACKS;                                01899660
                           CALL VM_DETAG;                                       01899665
                        END;                                                    01899700
                                                                                01899710
                     END;                                                       01899720
                                                                                01899730
                                                                                01899740
                     CALL CHECK_LIST(1,D_N_INX);                                01899750
                                                                                01899760
 /* TAG CSE'S IN ARRAY LOOPS REFERENCED FROM OTHER ARRAY LOOPS*/                01899770
                                                                                01899780
                     NESTED_VM,IN_AR = FALSE;                                   01899790
                     IF C_TRACE THEN CALL C_STACK_DUMP;                         01899800
                                                                                01899810
                  END;                                                          01899820
                                                                                01899830
 /*VDLE*/          ELSE DO;                                            /* VDLE*/01899840
                                                                                01899850
                     LOOP_END = I;                                              01899860
                     NODE(N_INX) = NODE(N_INX) | I;   /* END OF LOOP*/          01899870
                     IF IN_VM AND IN_AR AND NESTED_VM THEN DO;                  01899880
                                                                                01899890
                        IF CHECK_ADJACENT_LOOPS(I,2) THEN DO;                   01899900
                           CALL DENEST(I,1);                                    01899910
                        END;                                                    01899920
 /* LET DLPE DO THE REST*/                                                      01899930
                                                                                01899940
                                                                                01899950
                     END;                                                       01899960
                                                                                01899970
                     ELSE IF ADJACENT THEN CALL CHECK_VM_COMBINE;               01899980
                                                                                01899990
                                                                                01900000
                     IF IN_AR THEN DO;                                          01900010
                        REF_TO_DSUB(STACKED_VDLPS) =                            01900020
                           REF_TO_DSUB(STACKED_VDLPS) | REF_TO_DSUB;            01900030
                        ASSIGN(STACKED_VDLPS) = ASSIGN(STACKED_VDLPS) | ASSIGN; 01900040
                     END;                                                       01900050
                                                                                01900060
                     IN_VM = FALSE;                                             01900070
                     NESTED_VM = FALSE;                                         01900080
                     IF C_TRACE THEN CALL C_STACK_DUMP;                         01900090
                                                                                01900100
                  END;                                                          01900110
                                                                                01900120
               END;                                                             01900130
                                                                                01900140
               ELSE IF OP=DSUB OR OP=TSUB OR OP=XXAR OR OP=SFAR THEN            01900150
                  DO;                                                           01900160
                                                                                01900170
                  AR_DENESTABLE,ADJACENT,ADJACENT(1) = FALSE;                   01900180
                                                                                01900190
               END;                                                             01900200
                                                                                01900210
               ELSE IF OP = EXTN THEN DO;                                       01900220
                                                                                01900230
                  K = SHR(OPR(I+1),16);                                         01900240
                  IF XHALMAT_QUAL(I + 1) = XVAC THEN  /* TSUB*/                 01900250
                     K = SHR(OPR(K + 1),16);                                    01900260
                  IF SYT_ARRAY(K) ^= 0 THEN STRUCTURE_COPIES = TRUE;            01900270
                                                                                01900280
               END;                                                             01900290
                                                                                01900300
               ELSE IF OP = SMRK THEN DO;                                       01900310
                                                                                01900320
                  IF C_TRACE THEN OUTPUT = '**********STATEMENT '||             01900330
                     SHR(OPR(I + 1),16);                                        01900340
                                                                                01900350
                  IF STATISTICS THEN DO;                                        01900360
                                                                                01900370
                     TEMP = SHR(OPR(I + 1),16);                                 01900380
                     K = DENEST# - OLD_DENEST#;                                 01900390
                     IF K ^= 0 THEN DO;                                         01900400
                        OUTPUT = K ||                                           01900410
                           ' LOOP'||S(K)||' DENESTED IN HAL/S STATEMENT '||TEMP;01900420
                        OLD_DENEST# = DENEST#;                                  01900430
                     END;                                                       01900440
                                                                                01900450
                     K = COMBINE# - OLD_COMBINE#;                               01900460
                     IF K ^= 0 THEN DO;                                         01900470
                        OUTPUT = K ||                                           01900480
                           ' LOOP'||S(K)||' COMBINED IN HAL/S STATEMENT '||TEMP;01900490
                        OLD_COMBINE# = COMBINE#;                                01900500
                     END;                                                       01900510
                                                                                01900520
                  END;   /* STATISTICS*/                                        01900530
                                                                                01900540
               END;    /* SMRK*/                                                01900550
                                                                                01900560
               ELSE IF OP = BFNC THEN DO;                                       01900561
                  K = SHR(OPR(I),24);                                           01900562
                  IF K=3 | K=27 | K=28 | K=34 | K=49 | K=56 THEN DO;            01900563
                     CSE_PTR = SHR(OPR(I+1),16);                                01900564
                     IF XHALMAT_QUAL(I+1) = XVAC THEN                           01900565
                    IF (OPR(CSE_PTR) & CSE_TAG) ^= 0 AND LOOPY(CSE_PTR) THEN DO;01900566
                        N2_INX = N2_INX + 1;                                    01900567
                        NODE2(N2_INX) = I+1;                                    01900568
                     END;                                                       01900569
                  END;                                                          01900570
               END;                                                             01900571
                                                                                01900572
            END;   /* CLASS 0*/                                                 01900580
                                                                                01900590
            ;;                                                                  01900600
BUMP_N2:                                                                        01900604
            DO FOR K = I+1 TO LAST_OPERAND(I);                                  01900606
               CSE_PTR = SHR(OPR(K),16);                                        01900608
               IF XHALMAT_QUAL(K) = XVAC THEN                                   01900610
                  IF (OPR(CSE_PTR) & CSE_TAG) ^= 0 AND LOOPY(CSE_PTR) THEN DO;  01900612
                  N2_INX = N2_INX + 1;                                          01900614
                  NODE2(N2_INX) = K;                                            01900616
               END;                                                             01900618
            END;   /* CLASS 3 */                                                01900620
                                                                                01900622
            GO TO BUMP_N2;       /* CLASS 4 */                                  01900624
                                                                                01900626
            IF OPOP(I) = VDOT THEN GO TO BUMP_N2;   /* CLASS 5 */               01900628
                                                                                01900630
            ;                                                                   01900632
               /* CLASS 7, NO COMBINING OF ARRAYED COMPARISONS */               01900636
 /* DR 108607 - LARRY WINGO             *****/
            DO;
 /* DR 108607                           *****/
               ADJACENT = FALSE;                                                01900634
 /* DR 108607                           *****/
                  /* FOR V/M COMPARISON */
               IF OPOP(I) >= MNEQ & OPOP(I) <= VEQU THEN
                 GO TO BUMP_N2;
            END;
 /* END DR 108607                       *****/
            ;;                                                                  01900638
                                                                                01900640
            END;   /* DO CASE CLASS */                                          01900642
                                                                                01900644
                                                                                01900646
                                                                                01900648
                                                                                01900660
         ASSIGN_OP = ASSIGN_TYPE(I);                                            01900670
         IF ASSIGN_OP THEN ASSIGN = TRUE;                                       01900680
                                                                                01900690
         IF IN_VM THEN LOOPY# = LOOP_OPERANDS(I);                               01900700
                                                                                01900710
         IF IN_AR | IN_VM THEN IF OP ^= ADLP THEN                               01900720
            DO FOR K = I + 1 TO LAST_OPERAND(I);                                01900730
                                                                                01900740
            TEMP = XHALMAT_QUAL(K);                                             01900750
                                                                                01900760
            IF TEMP = XVAC THEN DO;                                             01900770
                                                                                01900780
                                                                                01900790
               CSE_PTR = SHR(OPR(K),16);                                        01900800
                                                                                01900810
               TEMP = OPOP(CSE_PTR);                                            01900820
               IF TEMP = DSUB OR TEMP = TSUB THEN DO;                           01900830
                  REF_TO_DSUB = TRUE;                                           01900840
                  IF ASSIGN_OP THEN AR_DENESTABLE = FALSE;                      01900850
                                                                                01900860
               END;                                                             01900870
                                                                                01900880
               IF CSE_PTR < LOOP_HEAD THEN DO;                                  01900890
                  IF IN_VM THEN                                                 01900900
                     IF (OPR(CSE_PTR) & CSE_TAG) ^= 0 THEN DO;                  01900910
                     N2_INX = N2_INX + 1;                                       01900920
                     NODE2(N2_INX) = K;                                         01900930
                  END;                                                          01900940
                                                                                01900942
                  IF IN_VM & IN_AR & ^ARRAYNESS_CONFLICT THEN                   01900944
                     IF CSE_PTR>LOOP_HEAD(2) & CSE_PTR<LOOP_END(2) THEN         01900946
                     IF ADJACENT(1) & SHR(OPR(LOOP_HEAD(2)+1),8) THEN           01900948
                     ARRAYNESS_CONFLICT = TRUE;                                 01900950
                                                                                01900952
                  IF NESTED_VM THEN DO;                                         01900960
                     DO FOR INX = 1 TO A_INX;                                   01900970
                        IF ADD(INX) = CSE_PTR THEN GO TO ARRAYED_CSE;           01900980
                     END;                                                       01900990
                     NESTED_VM = FALSE;    /* UNARRAYED CSE, SO NO DENEST*/     01901000
                  END;                                                          01901010
ARRAYED_CSE:                                                                    01901020
                                                                                01901030
                  IF IN_AR THEN                                                 01901040
                     IF CSE_PTR < LOOP_HEAD(STACKED_VDLPS) THEN                 01901050
                     CALL BUMP_D_N(CSE_PTR);                                    01901060
                                                                                01901070
 /* POSSIBLE OUT OF ARRAY REFERENCE*/                                           01901080
                                                                                01901090
                                                                                01901100
               END;                                                             01901110
                                                                                01901120
            END;   /* XVAC*/                                                    01901130
                                                                                01901140
            ELSE IF TEMP = XSYT THEN DO;                                        01901150
               IF NAME_OR_PARM(K) THEN REF_TO_DSUB = TRUE;                      01901160
               IF IN_VM OR IN_AR THEN CALL CHECK_ARRAYNESS(K,I);                01901170
            END;                                                                01901180
                                                                                01901190
            ELSE IF TEMP = XXPT THEN DO;                                        01901200
               IF IN_VM OR IN_AR THEN CALL CHECK_ARRAYNESS(K,I);                01901210
               IF EXTN_CHECK(K) THEN REF_TO_DSUB = TRUE;                        01901220
            END;                                                                01901230
                                                                                01901240
                                                                                01901250
            IF IN_VM THEN IF K <= LOOPY# THEN                                   01901260
               IF ^(OP = IASN & K < LOOPY#) THEN   /* FOR M=0 CASE*/            01901270
               OPR(K) = OPR(K) | VM_LOOP_TAG;                                   01901280
                                                                                01901290
         END;   /* DO FOR K*/                                                   01901300
                                                                                01901310
         IF NESTED_VM THEN IF IN_VM THEN IF SHR(OPR(I),3)    /* CSE*/           01901320
            THEN CALL BUMP_ADD(I);                                              01901330
                                                                                01901340
 /* KEEP LIST OF MIXED DENESTABLE CSE'S ON ADD STACK*/                          01901350
                                                                                01901360
                                                                                01901370
         I = LAST_OPERAND(I) + 1;                                               01901380
                                                                                01901390
      END;   /* DO WHILE I*/                                                    01901400
                                                                                01901410
      CALL CHECK_LIST(0,N2_INX);                                                01901420
      LAST_ZAP = CTR;                                                           01901430
      N_INX = 1;                                                                01901440
                                                                                01901450
   END FINAL_PASS;                                                              01901460
