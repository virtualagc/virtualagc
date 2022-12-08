 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STRIPNOD.xpl
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
 /* PROCEDURE NAME:  STRIP_NODES                                            */
 /* MEMBER NAME:     STRIPNOD                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOOP_PULL         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          AVOID_PITFALL     LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          MASK              FIXED                                        */
 /*          PRES_REF_OF_VAC   BIT(16)                                      */
 /*          PREV_REF          BIT(16)                                      */
 /*          PREV_REF_OF_VAC   BIT(16)                                      */
 /*          PREV_TREE_TOP     BIT(8)                                       */
 /*          SET_PROV          BIT(8)                                       */
 /*          SORT1             BIT(8)                                       */
 /*          STRIP             LABEL                                        */
 /*          TEMP2             BIT(16)                                      */
 /*          VAC_CAT_PTR       BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          CSE2                                                           */
 /*          DUMMY_NODE                                                     */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FNPARITY0#                                                     */
 /*          FOR                                                            */
 /*          LITERAL                                                        */
 /*          MATCHED_TAG                                                    */
 /*          MPARITY0#                                                      */
 /*          MPARITY1#                                                      */
 /*          MULTIPLE_MATCH                                                 */
 /*          NEW_NODE_PTR                                                   */
 /*          NODE_BEGINNING                                                 */
 /*          NONCOMMUTATIVE                                                 */
 /*          OLD_BLOCK#                                                     */
 /*          OLD_LEVEL                                                      */
 /*          OPTYPE                                                         */
 /*          OUTER_TERMINAL_VAC                                             */
 /*          PRESENT_NODE_PTR                                               */
 /*          PREVIOUS_NODE_OPERAND                                          */
 /*          PREVIOUS_NODE_PTR                                              */
 /*          PREVIOUS_NODE                                                  */
 /*          REVERSE                                                        */
 /*          TERMINAL_VAC                                                   */
 /*          TOTAL_MATCH_PRES                                               */
 /*          TOTAL_MATCH_PREV                                               */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          TWIN_MATCH                                                     */
 /*          TWIN_OP                                                        */
 /*          TYPE_MASK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADD                                                            */
 /*          COMPLEX_MATCHES                                                */
 /*          COMPLEX_MATCH                                                  */
 /*          CSE_INX                                                        */
 /*          CSE_TAB                                                        */
 /*          GET_INX                                                        */
 /*          N_INX                                                          */
 /*          NEW_NODE_OP                                                    */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          STILL_NODES                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_SRCH                                                   */
 /*          CATALOG_VAC                                                    */
 /*          COMPARE_LITERALS                                               */
 /*          CSE_TAB_DUMP                                                   */
 /*          GET_LIT_ONE                                                    */
 /*          REVERSE_PARITY                                                 */
 /*          SET_ARRAYNESS                                                  */
 /*          SET_NONCOMMUTATIVE                                             */
 /*          SET_O_T_V                                                      */
 /*          SORTER                                                         */
 /*          TYPE                                                           */
 /* CALLED BY:                                                              */
 /*          PULL_INVARS                                                    */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STRIP_NODES <==                                                     */
 /*     ==> COMPARE_LITERALS                                                */
 /*         ==> HEX                                                         */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> GET_LIT_ONE                                                     */
 /*         ==> SAVE_LITERAL                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*     ==> SORTER                                                          */
 /*     ==> CSE_TAB_DUMP                                                    */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> CATALOG_PTR                                                 */
 /*         ==> VALIDITY                                                    */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*     ==> REVERSE_PARITY                                                  */
 /*     ==> SET_NONCOMMUTATIVE                                              */
 /*         ==> HEX                                                         */
 /*     ==> TYPE                                                            */
 /*     ==> SET_ARRAYNESS                                                   */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> TYPE                                                        */
 /*         ==> ARRAYED_ELT                                                 */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*     ==> CATALOG_SRCH                                                    */
 /*     ==> CATALOG_VAC                                                     */
 /*         ==> GET_FREE_SPACE                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*         ==> CATALOG_ENTRY                                               */
 /*             ==> GET_EON                                                 */
 /*             ==> GET_FREE_SPACE                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*     ==> SET_O_T_V                                                       */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS        DR/CR #  DESCRIPTION                           */
 /*                                                                         */
 /* 03/15/91 DKB  23V2       CR11109  CLEANUP COMPILER SOURCE CODE          */
 /* 12/12/94 JMP  27V0/11V0  DR108646 FIX CSE TABLE CORRUPTION PROBLEM      */
 /* 09/30/99 JAC  30V0/15V0  DR111343 DQ102 ERROR FOR MULTI-COPIED          */
 /*                                   STRUCTURE ASSIGNMENT                  */
 /***************************************************************************/
                                                                                03926000
 /* CLEANS UP TO PREVENT FALSE MATCHES*/                                        03927000
STRIP_NODES:                                                                    03928000
   PROCEDURE(LOOP_PULL);          /* MUST BE CALLED WITH ALL OPERANDS*/         03929000
      DECLARE LOOP_PULL BIT(8);                                                 03929010
      DECLARE (PREV_REF,VAC_CAT_PTR,TEMP2) BIT(16);                             03930000
      DECLARE PREV_TREE_TOP BIT(8);                                             03931000
      DECLARE SET_PROV BIT(8);                                                  03932000
      DECLARE (PREV_REF_OF_VAC,PRES_REF_OF_VAC) BIT(16);                        03933000
      DECLARE I BIT(16);                                                        03934000
      DECLARE (SORT1) BIT(8);                                                   03935000
      DECLARE MASK FIXED;                                                       03936000
      IF TRACE THEN OUTPUT = 'STRIP_NODES';                                     03937000
      IF ^TOTAL_MATCH_PREV & ^TOTAL_MATCH_PRES THEN DO;                         03938000
         I = CSE_FOUND_INX - 1;                                                 03939000
         NODE2(N_INX - 1) = 0;                                                  03940000
         NODE(N_INX) = END_OF_NODE;                                             03941000
         N_INX = N_INX + 1;                                                     03942000
         MASK = SHL(MPARITY0# ^= 0,20) | "FF E F FFFF";                         03943000
         DO WHILE I > 0;                                                        03944000
            NODE(N_INX) = CSE(I) & MASK;                                        03945000
            NODE2(N_INX) = CSE2(I);                                             03946000
            N_INX = N_INX + 1;                                                  03947000
            I = I - 1;                                                          03948000
         END; /* DO WHILE*/                                                     03949000
         NODE(N_INX) = OPTYPE;                                                  03950000
         NODE2(N_INX) = 0;                                                      03951000
         NODE2(NEW_NODE_PTR + 1) = N_INX;                                       03952000
         CALL SET_ARRAYNESS(N_INX);                                             03952010
         N_INX = N_INX + 1;                                                     03953000
      END;                                                                      03954000
                                                                                03955000
 /* NEW NODE ENTRY HAS NOW BEEN SET UP*/                                        03956000
                                                                                03957000
      NEW_NODE_OP = NODE2(NEW_NODE_PTR + 1);                                    03958000
      PREV_TREE_TOP = TOTAL_MATCH_PREV & NODE2(PREVIOUS_NODE) = 0;              03959000
      IF PREV_TREE_TOP & (NODE(PREVIOUS_NODE) = TSUB) &   /*DR111343*/
         NODE(NODE2(NODE2(NODE_BEGINNING)))=EXTN THEN     /*DR111343*/
         PREV_TREE_TOP = 0;                               /*DR111343*/
 /* TRUE IF ASSIGNMENT INPUT*/                                                  03960000
                                                                                03961000
      IF TWIN_OP THEN IF ^ TWIN_MATCH THEN NODE(PREVIOUS_NODE) =                03962000
         NODE(PREVIOUS_NODE) | MATCHED_TAG;                                     03963000
                                                                                03964000
      IF TOTAL_MATCH_PREV & NODE2(PREVIOUS_NODE_PTR) = 0                        03965000
         & ^TWIN_MATCH                                                          03966000
         & ^PREV_TREE_TOP THEN DO;                                              03967000
                                                                                03968000
         PREV_REF_OF_VAC = SET_O_T_V(PREVIOUS_NODE,PREVIOUS_NODE_PTR);          03969000
         PREV_REF = NODE2(NODE2(PREVIOUS_NODE));     /* POINTS TO OPERATOR*/    03970000
         SET_PROV = TRUE;                                                       03971000
      END;                                                                      03972000
      ELSE DO;                                                                  03973000
         PREV_REF = PREVIOUS_NODE;                                              03974000
         SET_PROV = FALSE;                                                      03975000
      END;                                                                      03976000
                                                                                03977000
      IF TOTAL_MATCH_PRES & ^ REVERSE & ^TWIN_MATCH THEN DO;                    03978000
                                                                                03978010
         IF LOOP_PULL THEN PRES_REF_OF_VAC = PREV_REF_OF_VAC;                   03978020
         ELSE                                                                   03978030
            PRES_REF_OF_VAC = SET_O_T_V(NODE_BEGINNING,PRESENT_NODE_PTR         03979000
            ,PREV_TREE_TOP);                                                    03980000
      END;                                                                      03981000
      IF TWIN_MATCH THEN VAC_CAT_PTR = 0;                                       03982000
      ELSE DO;                                                                  03983000
         IF NODE2(NEW_NODE_PTR) ^= 0 THEN VAC_CAT_PTR = NODE2(NEW_NODE_PTR);    03984000
         ELSE IF ^ PREV_TREE_TOP & ^(REVERSE & TOTAL_MATCH_PRES) THEN           03985000
            NODE2(NEW_NODE_PTR), VAC_CAT_PTR = CATALOG_VAC(PREV_REF);           03986000
                                                                                03987000
         ELSE VAC_CAT_PTR = 0;                                                  03988000
      END;   /* ^ TWIN_MATCH*/                                                  03989000
                                                                                03990000
      GO TO AVOID_PITFALL;                                                      03991000
 /* INTERNAL PROCEDURE TO REMOVE NODE ENTRIES FROM NODE LIST*/                  03992000
STRIP:                                                                          03993000
      PROCEDURE(PTR,REVERSE,FORWARD,NO_OTV) ;                                   03994000
         DECLARE TMP FIXED;                                                     03995000
         DECLARE (REVERSE,FORWARD,NO_OTV,FIRST) BIT(8);                         03996000
         DECLARE (PTR,I,N_INX,A_INX) BIT(16);                                   03997000
         DECLARE CTL FIXED;                                                     03998000
                                                                                03999000
 /* FIXES STRIPED NODES WHEN NEGATE OR RECIPROCAL WAS GENERATED*/               04000000
FIX_NODES:                                                                      04001000
         PROCEDURE;                                                             04002000
            IF OPTYPE = "5AD" THEN DO;                                          04003000
               NODE(N_INX) = LITERAL;                                           04004000
               NODE2(N_INX) = GET_LIT_ONE;                                      04005000
               NODE(ADD(1)) = OUTER_TERMINAL_VAC | NEW_NODE_PTR | "1 0 0000";   04006000
               NODE2(ADD(1)) = VAC_CAT_PTR;                                     04007000
            END;                                                                04008000
            ELSE NODE(N_INX) = DUMMY_NODE;                                      04009000
         END FIX_NODES;                                                         04010000
                                                                                04011000
         IF TRACE THEN OUTPUT = '  STRIP: '||PTR||','||REVERSE;                 04012000
         A_INX = 0;                                                             04013000
         FIRST = TRUE;                                                          04014000
         DO FOR I = 1 TO CSE_FOUND_INX - 1;                                     04015000
            TMP = CSE(I);                                                       04016000
            IF (TMP & TYPE_MASK) = OUTER_TERMINAL_VAC THEN                      04017000
               COMPLEX_MATCH = TRUE;                                            04018000
                                                                                04019000
            IF NONCOMMUTATIVE THEN NODE(PTR-I+1),NODE2(PTR-I+1) = 0;            04020000
                                                                                04021000
            ELSE DO;           /* ^ NONCOMMUTATIVE*/                            04022000
               IF REVERSE THEN TMP = REVERSE_PARITY(TMP);                       04023000
               N_INX = PTR + 1;                                                 04024000
LOOK:          N_INX = N_INX - 1;                                               04025000
               DO WHILE NODE(N_INX) ^= TMP & NODE(N_INX) ^= END_OF_NODE;        04026000
                  N_INX = N_INX - 1;                                            04027000
               END;                                                             04028000
               IF (TMP & "FFEF FFFF") = LITERAL THEN                            04029000
                  IF ^COMPARE_LITERALS(CSE2(I),NODE2(N_INX)) THEN               04030000
                  GO TO LOOK;                                                   04031000
               A_INX = A_INX + 1;     /* REMEMBER ZEROED NODES*/                04032000
               ADD(A_INX) = N_INX;                                              04033000
               NODE(N_INX) = 0;                                                 04034000
               NODE2(N_INX) = 0;                                                04035000
               IF ^FORWARD THEN DO CASE TYPE(CSE(I));                           04036000
                  ;;;;;                                                         04036010
 /* RECATALOG NODES*/                                                           04037000
                     ;                                                          04038000
                  ;;;;;DO;   /* B = VALUE_NO*/                                  04039000
                        TEMP2 = CSE(I) & "FFFF";                                04040000
CHANGE_REF:          CALL CATALOG_SRCH(TEMP2);                                  04041000


                     DO WHILE CSE_INX ^= 0 & CSE_TAB(CSE_INX) ^= PTR + 1;       04042000
                        CSE_INX = CSE_TAB(CSE_INX + 1);                         04043000
                     END;                                                       04044000

                     IF CSE_INX > 0 THEN DO;    /* DR108646 FIX */
                        CSE_TAB(CSE_INX) = NEW_NODE_OP;/*CHANGE POINTER*/
                        CSE_TAB(CSE_INX + 2) = SHL(OLD_LEVEL,11) | OLD_BLOCK#;
                     END;                       /* DR108646 FIX */
                  END;                                                          04046000
                                                                                04047000
                  DO;   /* C = OUTER TERMINAL VAC*/                             04048000
                     TEMP2 = CSE2(I);                                           04049000
                     GO TO CHANGE_REF;                                          04050000
                  END;;  /* SKIP LITERALS */;;                                  04051000
                  END;/* DO CASE*/                                              04052000
            END;      /* COMMUTATIVE*/                                          04053000
                                                                                04054000
         END; /* DO FOR*/                                                       04055000
                                                                                04056000
         IF NONCOMMUTATIVE THEN RETURN;                                         04057000
                                                                                04058000
         IF ^ NO_OTV THEN DO;                                                   04059000
            IF FORWARD & REVERSE THEN CTL = SHL(MPARITY0# ^= 0,20);             04060000
            ELSE CTL = SHL(MPARITY0# = 0,20);                                   04061000
            IF FORWARD & REVERSE & FNPARITY0# = MPARITY1# THEN                  04062000
               CALL FIX_NODES;                                                  04063000
            ELSE DO;                                                            04064000
               IF ^PREV_TREE_TOP | MULTIPLE_MATCH THEN                          04065000
                  NODE(N_INX) = CTL|NEW_NODE_PTR | OUTER_TERMINAL_VAC;          04066000
               ELSE NODE(N_INX) = CTL | NEW_NODE_PTR | TERMINAL_VAC;            04067000
               NODE2(N_INX) = VAC_CAT_PTR;                                      04068000
            END;                                                                04069000
         END;                                                                   04070000
         DO WHILE NODE(N_INX) ^= END_OF_NODE;                                   04071000
            N_INX = N_INX - 1;                                                  04072000
         END;                                                                   04073000
         IF ^FORWARD THEN CALL SORTER(N_INX + 1,PTR);                           04074000
         CALL SET_ARRAYNESS(PTR + 1);                                           04074010
      END STRIP /* $S */ ;                                                      04075000
AVOID_PITFALL:                                                                  04076000
                                                                                04077000
      COMPLEX_MATCH = FALSE;                                                    04078000
                                                                                04079000
      IF TWIN_MATCH THEN NODE(NEW_NODE_PTR) = NODE(PREVIOUS_NODE_PTR) + 1;      04080000
 /* POINTS TO FIRST OPERAND RATHER THAN OPERATOR*/                              04081000
      ELSE DO;                                                                  04082000
                                                                                04083000
         IF ^TOTAL_MATCH_PREV THEN CALL STRIP(PREVIOUS_NODE_OPERAND,0,0,0);     04084000
                                                                                04084010
         IF ^ LOOP_PULL THEN DO;                                                04084020
       IF ^ TOTAL_MATCH_PRES | TOTAL_MATCH_PREV THEN CALL STRIP(NODE_BEGINNING -04085000
               1,REVERSE,1,TOTAL_MATCH_PRES);                                   04086000
            COMPLEX_MATCHES = COMPLEX_MATCHES + COMPLEX_MATCH;                  04087000
            IF ^TOTAL_MATCH_PRES THEN DO;                                       04088000
               GET_INX = NODE_BEGINNING;    /* TRY FOR MORE MATCHES*/           04089000
               STILL_NODES = TRUE;                                              04090000
            END;                                                                04091000
         END;                                                                   04091010
                                                                                04091020
                                                                                04092000
         SORT1 = FALSE;                        /* FIX OUTER TERMINAL            04093000
                  VAC'S NODE2'S AND SORT NODES IF NEEDED*/                      04094000
         IF ^PREV_TREE_TOP THEN DO;                                             04095000
            IF SET_PROV THEN DO;                                                04096000
               NODE2(PREV_REF_OF_VAC) = VAC_CAT_PTR;                            04097000
               SORT1 = TRUE;                                                    04098000
            END;                                                                04099000
            IF TOTAL_MATCH_PRES AND NODE2(NODE_BEGINNING) ^= 0 AND ^REVERSE     04100000
               AND ^(LOOP_PULL & (SET_PROV = FALSE))                            04100010
               THEN DO;                                                         04101000
            NODE2(PRES_REF_OF_VAC) = VAC_CAT_PTR;    /*FILL IN PTRS TO CSE_TAB*/04102000
            END;                                                                04103000
         END;                                                                   04104000
                                                                                04105000
         IF SORT1 THEN IF PREV_REF ^= 0 THEN DO;                                04106000
            IF ^ SET_NONCOMMUTATIVE(NODE(PREV_REF)) THEN                        04107000
               CALL SORTER(NODE2(PREVIOUS_NODE)+1,PREV_REF-1);                  04108000
         END;                                                                   04109000
                                                                                04110000
         IF PREV_TREE_TOP THEN DO;                                              04111000
            IF TOTAL_MATCH_PRES THEN DO;                                        04112000
               IF ^REVERSE THEN NODE2(PREVIOUS_NODE) = NODE2(NODE_BEGINNING);   04113000
            END;                                                                04114000
            ELSE NODE2(PREVIOUS_NODE) = PRESENT_NODE_PTR + 1;                   04115000
         END;                                                                   04116000
         IF TOTAL_MATCH_PRES & NODE2(NODE_BEGINNING) = 0 THEN DO;               04117000
            IF TOTAL_MATCH_PREV THEN DO;                                        04118000
               IF ^REVERSE THEN NODE2(NODE_BEGINNING) = NODE2(PREVIOUS_NODE);   04119000
            END;                                                                04120000
            ELSE NODE2(NODE_BEGINNING) = PREVIOUS_NODE_PTR + 1;                 04121000
         END;                                                                   04122000
         IF TOTAL_MATCH_PRES & ^TOTAL_MATCH_PREV THEN DO;                       04123000
            IF REVERSE & MPARITY0# ^= 0 THEN DO;   /* CHANGE PARITIES*/         04124000
               DO FOR I = PRESENT_NODE_PTR + 2 TO NODE_BEGINNING - 1;           04125000
                  NODE(I) = (NODE(I) & "FFEF FFFF") |                           04126000
                     ((NODE(I) + "10 0000") & "10 0000");                       04127000
               END;                                                             04128000
               CALL SORTER(PRESENT_NODE_PTR + 2,NODE_BEGINNING - 1);            04129000
            END;                                                                04130000
         END;                                                                   04131000
                                                                                04132000
      END;    /* ^ TWIN_MATCH*/                                                 04133000
                                                                                04134000
      IF TRACE THEN CALL CSE_TAB_DUMP;                                          04135000
   END STRIP_NODES;  /* $S */                                                   04136000
