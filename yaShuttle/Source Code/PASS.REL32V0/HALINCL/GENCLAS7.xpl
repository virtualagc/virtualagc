 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS7.xpl
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
 
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*03/05/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
/*                                                                         */
/*06/27/91 TEV    7V0  CR11114 MERGE BFS/PASS COMPILERS WITH CR/DR FIXES   */
/*         PMA                                                             */
/*                                                                         */
/*07/29/92 TEV    7V0  CR11114M MERGE BFS/PASS COMPILERS WITH CR/DR FIXES  */
/*                                                                         */
/*02/09/98 JAC   29V0  DR109053 STACK ENTRIES NOT RETURNED FOR PROGRAM/TASK*/
/*               14V0           IN BFS                                     */
/*                                                                         */
/*01/28/00 TKN   30V0  CR13211  GENERATE ADVISORY MSG WHEN BIT STRING      */
/*               15V0           ASSIGNED TO SHORTER STRING                 */
/*                                                                         */
/*04/01/04 TKN   32V0  CR13670  ENHANCE & UPDATE INFORMATION ON THE USAGE  */
/*               16V0           OF TYPE 2 OPTIONS                          *
/*                                                                         */
/*09/04/02 DCP   32V0  CR13616  IMPROVE READABILITY AND ADD COMMENTS FOR   */
/*               17V0           NAME DEREFERENCES                          */
/*                                                                         */
/***************************************************************************/
   /* CLASS 7 OPERATORS - LOGICAL OPERATIONS */                                 06689500
GEN_CLASS7:                                                                     06690000
   PROCEDURE;                                                                   06690500
   DECLARE CHECK_FOR_INITIAL_ENTRY_H720 BIT(1) INITIAL(FALSE); /* CR11114M */
                                                                                06691000
   /* ROUTINE TO RE-DEFINE THE DESTINATION OF A STATEMENT NUMBER */             06691500
FIX_LABEL:                                                                      06692000
   PROCEDURE(LAB1, LAB2);                                                       06692500
      DECLARE (LAB1, LAB2) BIT(16);                                             06693000
      IF ASSEMBLER_CODE THEN                                                    06693500
         OUTPUT = HEX_LOCCTR||'P#'||LAB1||' EQU P#'||LAB2;                      06694000
      NEXT_ELEMENT(LAB_LOC);  /*CR13670*/
      LOCATION(LAB1) = -LAB2;                                                   06694500
   END FIX_LABEL;                                                               06695000
                                                                                06695500
   /* ROUTINE TO SET UP STACKS TO GENERATE CONDITIONAL BRANCH  */               06696000
SETUP_RELATIONAL:                                                               06696500
   PROCEDURE(COND);                                                             06697000
      DECLARE COND BIT(16);                                                     06697500
      IF PACKTYPE(TYPE(LEFTOP)) THEN                                            06698000
        IF REG(LEFTOP) >= 0 THEN                                                06698500
         CALL DROP_REG(LEFTOP);                                                 06699000
      REG(LEFTOP) = CONDITION(COND);                                            06699500
      TYPE(LEFTOP) = RELATIONAL;                                                06700000
      FORM(LEFTOP) = 0;                                                         06700500
   END SETUP_RELATIONAL;                                                        06701000
   CLASS7:  DO;   /* CLASS 7 OPS  */                                            06701500
               LITTYPE = SUBCODE;                                               06702000
               ARRAY_FLAG = DOCOPY(CALL_LEVEL) > 0;                             06702500
               DO CASE SUBCODE;                                                 06703000
                  ;                                                             06703500
                  DO;  /* BIT  */                                               06704000
                     IF OPCODE = 0 THEN DO;  /* BTRU */                         06704500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; INITIAL ENTRY */
                        LEFTOP = GET_OPERAND(1);                                06705000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHECK FOR INITIAL ENTRY */
      /*CR13616*/       LEFTOP = GET_OPERAND(1, 0, BY_NAME_FALSE, 0, 1);
/********************** CR11114M - TEV - 7/29/92 *********************/
/* THE OLD CHECK FOR INITIAL ENTRY (BFS 6V0) PRODUCED AN OC4 ABEND   */
/* WHEN INTRODUCED INTO THE BFS 7V0 (MERGED) COMPILER. WHAT CAUSED   */
/* THIS ABEND TO BECOME APPARENT WAS THE SWITCH FROM LINKLIB MEMORY  */
/* MANAGEMENT TO SPACELIB MEMORY MANAGEMENT. THE CODE TO PRODUCE THE */
/* OC4 ABEND HAS BEEN INSIDE THE BFS SYSTEM BUT HAS NOT BECOME       */
/* VISIBLE UNTIL THE CHANGE OF MEMORY MANAGEMENT OCCURED.            */
/*                                                                   */
/* THE OC4 ABEND TOOK PLACE WHEN THE ITEM BEING REFERENCED WAS A     */
/* VIRTUAL ACCUMULATOR (VAC) WHICH RESIDED IN THE HALMAT AND WHOSE   */
/* ADDRESS WAS LOC2(LEFTOP). THIS ADDRESS WAS ERRONEOUSLY USED AS A  */
/* POINTER INTO THE SYMBOL TABLE, AS IF THE VAC WAS A SYMBOL. THIS   */
/* ADDRESS WAS OUTSIDE THE BOUNDS OF THE SYMBOL TABLE (AND PROBABLY  */
/* OUTSIDE THE PROGRAM BOUNDS) AND AN OC4 ABEND WAS ISSUED BY THE    */
/* OPERATING SYSTEM.                                                 */
/*                                                                   */
                        IF FORM(LEFTOP)= SYM THEN DO;
                           IF SYT_TYPE(LOC2(LEFTOP)) >= TASK_LABEL THEN
                              CHECK_FOR_INITIAL_ENTRY_H720 = TRUE;
                        END;
                        ELSE CHECK_FOR_INITIAL_ENTRY_H720 = FALSE;
                        IF CHECK_FOR_INITIAL_ENTRY_H720 = TRUE THEN DO;
                           CHECK_FOR_INITIAL_ENTRY_H720 = FALSE;
/**************************** END CR11114M ***************************/
                           IF SYT_NAME(LOC2(LEFTOP)) =
                              SYT_NAME(PROC_LEVEL(INDEXNEST)) THEN DO;
                              IF ^FIRST_TIME THEN
                                 GO TO UNIMPLEMENTED;
                              ELSE DO;
                                 REG(LEFTOP) = "6" & ^(SHL(BNOT_FLAG, 2));
                                 TYPE(LEFTOP) = INITIAL_ENTRY;
                              END;
                           END;
                           ELSE
                              GO TO UNIMPLEMENTED;
                           CALL RETURN_STACK_ENTRY(COLUMN(LEFTOP)); /*DR109053*/
                           COLUMN(LEFTOP) = 0;                      /*DR109053*/
                           BNOT_FLAG = FALSE;                       /*DR109053*/
                        END;
                        ELSE
 ?/
                        IF FORM(LEFTOP) = LIT THEN                              06705500
                           CALL SETUP_RELATIONAL(VAL(LEFTOP)&1);                06706000
                        ELSE DO;                                                06706500
                     DO_BTRU:                                                   06707000
                           IF FORM(LEFTOP) ^= VAC & DEL(LEFTOP) = 0 THEN DO;    06707500
                              IF SEARCH_REGS(LEFTOP)>=0 THEN GO TO REG_BTRU;    06708000
                               IF OPMODE(TYPE(LEFTOP))=1 & SIZE(LEFTOP) = 1 THEN06708500
                                  DO CASE COLUMN(LEFTOP) ^= 0;                  06709000
                                     DO;  /* UNSUBSCRIPTED */                   06709500
                                        IF USAGE(BESTAC(FIXED_ACC)) = 0 THEN    06710000
                                           GO TO REG_BTRU;                      06710500
                                        CALL GENSI(TH, LEFTOP);                 06711000
                                     END;                                       06711500
                                     DO;  /* SUBSCRIPTED */                     06712000
                                        TMP = COLUMN(LEFTOP);                   06712500
                                        IF FORM(TMP) ^= LIT THEN GO TO REG_BTRU;06713000
                                        IF ^GENSI(TB, LEFTOP, SHL(1, VAL(TMP))) 06713500
                                           THEN GO TO REG_BTRU;                 06714000
                                     END;                                       06715000
                                  END;  /* CASE COLUMN */                       06715500
                              ELSE GO TO REG_BTRU;                              06716000
                           END;                                                 06716500
                          ELSE DO;                                              06717000
                        REG_BTRU:                                               06717500
                           IF COLUMN(LEFTOP) > 0 THEN                           06718000
                              IF FORM(COLUMN(LEFTOP)) = LIT THEN                06718500
                                 TO_BE_INCORPORATED = DEL(LEFTOP) ^= 0;         06719000
                           CALL FORCE_ACCUMULATOR(LEFTOP);                      06721500
                           IF SIZE(LEFTOP) = 1 & COLUMN(LEFTOP) = 0 THEN DO;    06722000
                             IF REG(LEFTOP) ^= ABS(CCREG) THEN                  06722500
                              CALL ARITH_BY_MODE(TEST, LEFTOP, LEFTOP,          06723000
                                                 TYPE(LEFTOP));                 06723500
                           END;                                                 06724000
                           ELSE CALL BIT_MASK(AND, LEFTOP, 1, COLUMN(LEFTOP));  06724500
                          END;                                                  06725000
                           CALL RETURN_STACK_ENTRY(COLUMN(LEFTOP));             06725500
                           COLUMN(LEFTOP) = 0;                                  06726000
                           IF ARRAY_FLAG THEN                                   06730000
                              CALL SETUP_BOOLEAN(5 + BNOT_FLAG, 0);             06730500
                           ELSE CALL SETUP_RELATIONAL(5 + BNOT_FLAG);           06731000
                           BNOT_FLAG = FALSE;                                   06731500
                        END;                                                    06732000
                     END;                                                       06732500
                     ELSE DO;                                                   06733000
                        CALL GET_OPERANDS;                                      06733500
                        IF DATATYPE(TYPE(LEFTOP)) = BITS THEN   /*CR13211*/
                           IF SIZE(LEFTOP)^=SIZE(RIGHTOP) THEN  /*CR13211*/
                              CALL ERRORS(CLASS_YC,100);        /*CR13211*/
                        IF FORM(LEFTOP) = LIT THEN CALL COMMUTEM;               06734000
                        IF FORM(RIGHTOP) ^= LIT THEN GO TO SETUP_CONDITIONAL;   06734500
                        IF OPCODE=XEQU & DEL(LEFTOP) = 0 THEN                   06735000
                           IF SIZE(LEFTOP) = 1 & SIZE(RIGHTOP) = 1 THEN DO;     06735500
                              BNOT_FLAG = VAL(RIGHTOP) = 0;                     06736000
                              ARRAY_FLAG = ARRAY_FLAG | ^TAG;                   06736500
                              CALL RETURN_STACK_ENTRY(RIGHTOP);                 06737000
                              GO TO DO_BTRU;                                    06737500
                           END;                                                 06738000
                        IF DEL(LEFTOP) ^= AND THEN GO TO SETUP_CONDITIONAL;     06738500
                        IF VAL(RIGHTOP) = 0 | VAL(RIGHTOP) = CONST(LEFTOP) THEN 06739000
                           DO;                                                  06739500
                              TMP = FALSE;                                      06740000
                              IF FORM(LEFTOP) ^= VAC THEN                       06740500
                                IF SEARCH_REGS(LEFTOP)<0 THEN                   06741000
                                 IF OPMODE(TYPE(LEFTOP)) = 1 THEN               06741500
                                    IF COLUMN(LEFTOP) = 0 THEN                  06742000
                                       TMP = GENSI(TB, LEFTOP, CONST(LEFTOP));  06742500
                                    ELSE IF FORM(COLUMN(LEFTOP)) = LIT THEN     06743000
                                       TMP = GENSI(TB,LEFTOP,SHL(CONST(LEFTOP), 06743500
                                             VAL(COLUMN(LEFTOP))));             06744000
                              IF ^TMP THEN DO;                                  06744500
                                 IF VAL(RIGHTOP) ^= 0 THEN                      06745000
                                    IF OPMODE(TYPE(LEFTOP)) ^= 1 THEN           06745500
                                       GO TO SETUP_CONDITIONAL;                 06746000
                                 IF COLUMN(LEFTOP) > 0 THEN                     06746500
                                    IF FORM(COLUMN(LEFTOP)) ^= LIT THEN         06747000
                                       GO TO SETUP_CONDITIONAL;                 06747500
                                 TO_BE_INCORPORATED = FALSE;                    06748000
                                 CALL FORCE_ACCUMULATOR(LEFTOP);                06748500
                                 EXTOP=MAKE_BIT_LIT(TEST,CONST(LEFTOP),LEFTOP); 06749000
                                 IF VAL(RIGHTOP) = 0 THEN                       06749500
                                    CALL ARITH_BY_MODE(AND, LEFTOP, EXTOP,      06750000
                                       TYPE(LEFTOP));                           06750500
                                 ELSE                                           06751000
                                    CALL EMITP(TRB,REG(LEFTOP),0,0,VAL(EXTOP)); 06751500
                                 CALL RETURN_STACK_ENTRY(EXTOP);                06752000
                              END;                                              06752500
                              IF VAL(RIGHTOP) ^= 0 THEN OPCODE = OPCODE + 2;    06753000
                              CALL RETURN_STACK_ENTRIES(COLUMN(LEFTOP),RIGHTOP);06753500
                              COLUMN(LEFTOP) = 0;                               06754000
                              IF ^TAG | ARRAY_FLAG THEN                         06754500
                                 CALL SETUP_BOOLEAN(OPCODE, OPCODE&ARRAY_FLAG); 06755000
                              ELSE CALL SETUP_RELATIONAL(OPCODE);               06755500
                           END;                                                 06756000
                        ELSE GO TO SETUP_CONDITIONAL;                           06756500
                     END;                                                       06757000
                  END;                                                          06757500
                  DO;  /* CHARACTER  */                                         06758000
                     CALL GET_CHAR_OPERANDS;                                    06758500
                     IF OPCODE = REVERSE(OPCODE) THEN TMP = 0;                  06759000
                     ELSE TMP = 11;                                             06759500
                     CALL CHAR_CALL(TMP, 0, LEFTOP, RIGHTOP);                   06760000
                     GO TO SETAG_CONDITIONAL;                                   06760500
                  END;                                                          06761000
                  DO;  /* MAT  */                                               06761500
VECMAT_CONDITIONAL:  CALL ARG_ASSEMBLE;                                         06762000
                     TEMPSPACE = ROW(0) * COLUMN(0);                            06762500
                     CALL VMCALL(0,(OPTYPE&8)^=0,0,LEFTOP,RIGHTOP,0);           06763000
 SETAG_CONDITIONAL:  CALL RETURN_STACK_ENTRY(RIGHTOP);                          06763500
                     IF ^TAG | ARRAY_FLAG THEN                                  06764000
                        CALL SETUP_BOOLEAN(OPCODE, OPCODE&1);                   06764500
                     ELSE CALL SETUP_RELATIONAL(OPCODE);                        06765000
                  END;                                                          06765500
                  GO TO VECMAT_CONDITIONAL;  /* VEC  */                         06766000
                  DO;   /* SCALAR  */                                           06766500
                     CALL GET_OPERANDS;                                         06767000
                     IF SHOULD_COMMUTE(OPCODE) THEN DO;                         06767500
                        CALL COMMUTEM;                                          06768000
                        OPCODE = REVERSE(OPCODE);                               06768500
                     END;                                                       06769000
 SETUP_CONDITIONAL:  IF FORM(LEFTOP) = LIT & VAL(LEFTOP) = 0 THEN DO;
                        CALL COMMUTEM;                                          06770000
                        OPCODE = REVERSE(OPCODE);                               06770500
            ZERO_TEST:  CALL FORCE_ACCUMULATOR(LEFTOP);                         06771000
                        IF REG(LEFTOP) ^= CCREG THEN                            06771500
                          IF REG(LEFTOP)^=-CCREG | OPCODE^=REVERSE(OPCODE) THEN 06772000
                           CALL ARITH_BY_MODE(TEST, LEFTOP, LEFTOP, OPTYPE);    06773000
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       06773500
                     END;                                                       06774000
                     ELSE IF FORM(RIGHTOP) = LIT & VAL(RIGHTOP) = 0 THEN        06774500
                        GO TO ZERO_TEST;                                        06775000
                     ELSE CALL EXPRESSION(OPCODE);                              06775500
                     IF ^TAG | ARRAY_FLAG THEN                                  06776000
                        CALL SETUP_BOOLEAN(OPCODE, OPCODE & ARRAY_FLAG);        06776500
                     ELSE CALL SETUP_RELATIONAL(OPCODE);                        06777000
                  END;                                                          06777500
                  DO;   /* INTEGER  */                                          06778000
                     CALL GET_OPERANDS;                                         06778500
                     IF SHOULD_COMMUTE(OPCODE) THEN DO;                         06779000
                        CALL COMMUTEM;                                          06779500
                        OPCODE = REVERSE(OPCODE);                               06780000
                     END;                                                       06780500
                     IF FORM(LEFTOP) = LIT THEN DO;                             06781000
                        VAL(LEFTOP) = VAL(LEFTOP) - CONST(RIGHTOP);             06781500
                        LOC(LEFTOP) = -1;                                       06781600
                        CONST(RIGHTOP) = 0;                                     06782000
                     END;                                                       06782500
                     ELSE IF FORM(RIGHTOP) = LIT THEN DO;                       06783000
                        VAL(RIGHTOP) = VAL(RIGHTOP) - CONST(LEFTOP);            06783500
                        LOC(RIGHTOP) = -1;                                      06783600
                        CONST(LEFTOP) = 0;                                      06784000
                     END;                                                       06784500
                     ELSE DO;                                                   06785000
                        CONST(LEFTOP) = CONST(LEFTOP) - CONST(RIGHTOP);         06785500
                        CONST(RIGHTOP) = 0;                                     06786000
                     END;                                                       06786500
                     GO TO SETUP_CONDITIONAL;                                   06787000
                  END;                                                          06787500
                  DO;  /* LOGICAL  */                                           06788000
                     CALL GET_OPERANDS;                                         06788500
                     IF OPCODE = XNOT THEN DO;                                  06789000
                        TMP = VAL(LEFTOP);                                      06789500
                        VAL(LEFTOP) = XVAL(LEFTOP);                             06790000
                        XVAL(LEFTOP) = TMP;                                     06790500
                     END;                                                       06791000
                     ELSE DO;  /* AND | OR */                                   06791500
                        IF CONST(LEFTOP) < CONST(RIGHTOP) THEN                  06792000
                           CALL COMMUTEM;                                       06792500
                        DO CASE OPCODE & 1;                                     06793000
                           DO;  /* AND  */                                      06793500
                              CALL FIX_LABEL(VAL(RIGHTOP), VAL(LEFTOP));        06794000
                              CALL FIX_LABEL(XVAL(RIGHTOP), CONST(RIGHTOP));    06794500
                           END;                                                 06795000
                           DO;  /* OR  */                                       06795500
                              CALL FIX_LABEL(VAL(RIGHTOP), CONST(RIGHTOP));     06796000
                              CALL FIX_LABEL(XVAL(RIGHTOP), XVAL(LEFTOP));      06796500
                           END;                                                 06797000
                        END;                                                    06797500
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       06798000
                     END;                                                       06798500
                     CALL REGISTER_STATUS;                                      06799000
                  END;                                                          06799500
               END;  /* DO CASE SUBCODE  */                                     06800000
               ARRAY_FLAG, TAG = FALSE;                                          6800500
               CALL SETUP_VAC(LEFTOP);                                           6800600
            END CLASS7;                                                         06801000
   END GEN_CLASS7;                                                              06801500
