 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS1.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***********************************************************/                   00006000
/*                                                         */                   00007000
/*  REVISION HISTORY                                       */                   00008000
/*                                                         */                   00009000
/*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                   00009100
/*                                                         */                   00009200
/*  07/15/91 DAS   24V0 CR11096  #DPARM - RESTRICT #D PASS-BY-REFERENCE    */
/*                               PARAMETER TO DSLD RTL ROUTINE.            */
/*                                                                         */
/*  07/15/91 DAS   24V0 CR11096  #DREG - NEW #D REGISTER ALLOCATION:       */
/*                               R1 OR R3 FOR #D, R2 OTHERWISE             */
/*  06/27/91 PMA   7V0  CR11114  MERGE BFS/PASS COMPILERS  */
/*           JAC                 WITH CR/DR FIXES          */
/*                                                         */
/*  07/29/92 TEV   7V0  CR11114M MERGE BFS/PASS COMPILERS  */
/*                               WITH CR/DR FIXES          */
/*                                                         */
/*  12/08/92 PMA   8V0  *        MERGED 24V0 CR/DR FIXES WITH 7V0          */
/*                               * REFERENCE 24V0 CRS/DRS                  */
/*                                                         */
/*  01/28/00 TKN   30V0/ 13211   GENERATE ADVISORY MSG WHEN*/
/*                 15V0          BIT STRING ASSIGNED TO    */
/*                               SHORTER STRING            */
/*                                                         */
/*  04/26/01 DCP   31V0/ 13335   ALLEVIATE SOME DATA SPACE */
/*                 16V0          PROBLEMS IN HAL/S COMPILER*/
/*                                                         */
/*  09/01/04 DCP/  32V0/ 120224  INCORRECT SUBBIT FOR      */
/*           JAC   17V0          DOUBLE LISTERAL           */
/*                                                         */
/*  10/02/03 DCP   32V0/ 120225  INCONSISTENT PROPAGATION  */
/*                 17V0          OF SIGN BIT FOR BIT FUNC  */
/***********************************************************/                   00009500
   /* CLASS 1 OPERATORS - BIT MANIPULATION */                                   06296500
GEN_CLASS1:                                                                     06297000
   PROCEDURE;                                                                   06297500
   DECLARE CHECK_FOR_INITIAL_ENTRY_H104 BIT(1) INITIAL(FALSE); /* CR11114M */
                                                                                06298000
   /* ROUTINE TO ATTEMPT POSTPONEMENT OF LITERAL BIT OPERATIONS */              06298500
BIT_EVALUATE:                                                                   06299000
   PROCEDURE(OPCODE);                                                           06299500
      DECLARE OPCODE BIT(16);                                                   06300000
                                                                                06300500
   LIT_EXPRESS:                                                                 06301000
      PROCEDURE(OPC, NUM, PTR);                                                 06301500
         DECLARE (OPC, PTR) BIT(16), (NUM,VALUE) FIXED;                         06302000
         VALUE = VAL(PTR);                                                      06302500
         CALL RETURN_STACK_ENTRY(PTR);                                          06303000
         DO CASE OPC-2;                                                         06303500
            RETURN NUM & VALUE;                                                 06304000
            RETURN NUM | VALUE;                                                 06304500
         END;                                                                   06305000
      END LIT_EXPRESS;                                                          06305500
                                                                                06306000
      CALL GET_OPERANDS;                                                        06306500
      IF SIZE(LEFTOP) ^= SIZE(RIGHTOP) THEN       /*CR13211*/
         CALL ERRORS(CLASS_YE,100);               /*CR13211*/
      IF FORM(LEFTOP) = LIT THEN CALL COMMUTEM;                                 06307000
      IF (COPT(LEFTOP)|COPT(RIGHTOP)) ^= 0 THEN                                 06307500
         CALL EXPRESSION(OPCODE);                                               06308000
      ELSE IF FORM(RIGHTOP) ^= LIT THEN                                         06308500
         CALL EXPRESSION(OPCODE);                                               06309000
      ELSE IF FORM(LEFTOP) = LIT THEN DO;                                       06309500
         SIZE(LEFTOP) = MAX(SIZE(LEFTOP), SIZE(RIGHTOP));                       06310000
         VAL(LEFTOP) = LIT_EXPRESS(OPCODE, VAL(LEFTOP), RIGHTOP);               06310500
         LOC(LEFTOP) = -1;                                                      06310600
      END;                                                                      06311000
      ELSE IF SIZE(RIGHTOP) > SIZE(LEFTOP) THEN                                 06311500
         CALL EXPRESSION(OPCODE);                                               06312000
      ELSE DO;                                                                  06312500
         IF VAL(RIGHTOP) = 0 & OPCODE = XOR THEN                                06313000
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   06313500
         ELSE IF VAL(RIGHTOP) = XITAB(SIZE(LEFTOP)) & OPCODE = AND THEN         06314000
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   06314500
         ELSE IF DEL(LEFTOP) ^= 0 THEN DO;                                      06315000
            IF DEL(LEFTOP) = OPCODE THEN                                        06315500
               CONST(LEFTOP) = LIT_EXPRESS(OPCODE, CONST(LEFTOP), RIGHTOP);     06316000
            ELSE CALL EXPRESSION(OPCODE);                                       06316500
         END;                                                                   06317000
         ELSE DO;                                                               06317500
            DEL(LEFTOP) = OPCODE;                                               06318000
            CONST(LEFTOP) = VAL(RIGHTOP);                                       06318500
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   06319000
         END;                                                                   06319500
      END;                                                                      06320000
   END BIT_EVALUATE;                                                            06320500
                                                                                06321000
   /* ROUTINE TO ENTER OPERATOR INTO EVENT EXPRESSION  */                       06321500
EVENT_OPERATOR:                                                                 06322000
   PROCEDURE(OPCODE);                                                           06322500
      DECLARE OPCODE BIT(16);                              /*CR13335*/          06323000
      ARRAY OPTRANS(5) BIT(16) INITIAL (0, 0, 3, 1, 2);    /*CR13335*/
      CALL STACK_EVENT(OPTRANS(OPCODE));                                        06323500
   END EVENT_OPERATOR;                                                          06324000
                                                                                06324500
   /* ROUTINE TO CO.LECT EVENT OPERANDS  */                                     06325000
GET_EVENT_OPERANDS:                                                             06325500
   PROCEDURE;                                                                   06326000
      DECLARE (I, PTR) BIT(16);                                                 06326500
      DO I = 1 TO NUMOP;                                                        06327000
         PTR = GET_OPERAND(I, 0, 2);                                             6327500
         IF FORM(PTR) ^= VAC THEN                                               06328000
            CALL SET_EVENT_OPERAND(PTR);                                        06328500
         ELSE CALL RETURN_STACK_ENTRY(PTR);                                     06329000
      END;                                                                      06329500
   END GET_EVENT_OPERANDS;                                                      06330000
    CLASS1: DO;  /* CLASS 1 OPS  */                                             06330500
               DO CASE SUBCODE;                                                 06331000
                  IF TAG THEN DO;                                               06331500
                     CALL GET_EVENT_OPERANDS;                                   06332000
                     CALL EVENT_OPERATOR(OPCODE);                               06332500
                     IF SHR(TAG, 2) THEN                                        06333000
                        CALL EMIT_EVENT_EXPRESSION;                             06333500
                     ELSE DO;                                                   06334000
                        LEFTOP = GET_STACK_ENTRY;                               06334500
                        FORM(LEFTOP) = VAC;                                     06335000
                     END;                                                       06335500
                  END;                                                          06336000
                  ELSE DO CASE OPCODE;                                          06336500
                     ;                                                          06337000
                     DO;  /* BIT ASSIGNMENT  */                                 06337500
                        CALL DO_ASSIGNMENT;                                     06338000
                     END;                                                       06338500
                     CALL BIT_EVALUATE(OPCODE);  /* BAND */                     06339000
                     CALL BIT_EVALUATE(OPCODE);  /* BOR */                      06339500
                     IF NEXTPOPCODE(CTR) = XBTRU & COPT = 0 THEN DO;             6340000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; CHANGE BNOT FOR BFS  */
                        CALL GET_OPERANDS;                                      06340500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHANGE BNOT TO TEST ON    */
      /*            BOOLEAN EXPRESSION */
                        CALL GET_OPERANDS(1);
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
                         IF FORM(LEFTOP) = SYM THEN DO;
                            IF SYT_TYPE(LOC2(LEFTOP)) >= TASK_LABEL THEN
                               CHECK_FOR_INITIAL_ENTRY_H104 = TRUE;
                         END;
                         ELSE CHECK_FOR_INITIAL_ENTRY_H104 = FALSE;
                         IF CHECK_FOR_INITIAL_ENTRY_H104 = TRUE THEN DO;
                           CHECK_FOR_INITIAL_ENTRY_H104 = FALSE;
/************************** END CR11114M *****************************/
                           IF SYT_NAME(LOC2(LEFTOP)) =
                              SYT_NAME(PROC_LEVEL(INDEXNEST)) THEN DO;
                              IF ^FIRST_TIME THEN
                                 GO TO UNIMPLEMENTED;
                           END;
                           ELSE
                              GO TO UNIMPLEMENTED;
                        END;
 ?/
                        IF FORM(LEFTOP) = LIT THEN                              06341000
                           VAL(LEFTOP) = ^VAL(LEFTOP);                          06341500
                        ELSE BNOT_FLAG = TRUE;                                  06342000
                     END;                                                       06342500
                     ELSE CALL EVALUATE(OPCODE);  /* BNOT */                    06343000
                     DO;  /* BCAT  */                                           06343500
                        CALL GET_OPERANDS;                                      06344000
                        IF OPTYPE = BITS THEN                                   06345000
                           IF SIZE(LEFTOP) + SIZE(RIGHTOP) > HALFWORDSIZE THEN  06345500
                              OPTYPE = FULLBIT;                                 06346000
                        TO_BE_MODIFIED = TRUE;                                  06346500
                        CALL FORCE_ACCUMULATOR(LEFTOP, OPTYPE);                 06347000
                        CALL EMITP(SLL, REG(LEFTOP), 0, SHCOUNT, SIZE(RIGHTOP));06347500
                        CALL UNRECOGNIZABLE(REG(LEFTOP));                       06348000
                        SIZE(LEFTOP)=MIN(SIZE(LEFTOP)+SIZE(RIGHTOP), WORDSIZE); 06348500
                        CALL EXPRESSION(XOR);                                   06349000
                     END;                                                       06349500
                  END;                                                          06350000
                  DO CASE OPCODE;                                               06350500
                     ;                                                          06351000
                     DO;  /* BTOB  */                                           06351500
                        LEFTOP = GET_OPERAND(1);                                06352000
                       IF NUMOP > 1 THEN DO;                                    06352100
                        CALL FORCE_ACCUMULATOR(LEFTOP, FULLBIT);                06352500
                        SIZE(LEFTOP) = WORDSIZE;                                06353500
                       END;                                                     06353600
                     END;                                                       06354000
                     DO;  /* BTOQ  */                                           06354500
                        LEFTOP = GET_OPERAND(1);                                06355000
                     END;                                                       06355500
                  END;                                                          06356000
                  DO CASE OPCODE;                                               06356500
                     ;                                                          06357000
                     DO;  /* CTOB  */                                           06357500
                        LITTYPE = CHAR;                                         06358000
                        LEFTOP = CTON(GET_OPERAND(1), FULLBIT, TAG);            06358500
                        SIZE(LEFTOP) = WORDSIZE;                                06359000
                     END;                                                       06359500
                     DO;  /* CTOQ  */                                           06360000
                        LITTYPE = CHAR;                                         06360500
                        LEFTOP = GET_OPERAND(1);                                06361000
   IF SHL(SIZE(LEFTOP),3) < WORDSIZE THEN DO;                                   06361001
  /* OUTPUT =' BAD LENGTH CALCULATED FOR SUBBIT AT LINE ' || LINE#; */          06361002
     CALL ERRORS(CLASS_ZS,1,''||LINE#);  /* ISSUE ZS1 */                        06361003
   END;                                                                         06361004
                        TYPE(LEFTOP) = CHARSUBBIT;                              06361500
                        SIZE(LEFTOP) = WORDSIZE;                                06362000
                        IF NUMOP > 1 THEN DO;                                   06362500
                           XVAL(LEFTOP), ALCOP = GET_STACK_ENTRY;               06363000
                           FORM(ALCOP) = VAC;                                   06363500
                           SUBOP = 2;                                           06364000
                           SUBCODE = 0;                                         06364500
                           CALL GET_SUBSCRIPT;                                  06365000
                           SIZE(ALCOP) = WORDSIZE;                              06365500
                           CALL CHAR_SUBSCRIPT;                                 06366000
                           SIZE(LEFTOP) = SIZE(ALCOP);                          06366500
                        END;                                                    06367000
                        ELSE XVAL(LEFTOP) = 0;                                  06367500
                        IF ^TAG THEN DO;                                        06368000
                           CALL CHAR_CALL(XCSLD, XVAL(LEFTOP), LEFTOP, 0);      06368500
   /*-------------------- DANNY #DPARM --- RTL CSLD ROUTINE ---------*/         06412010
   /* RESTRICT REMOTE #D PASS BY REFERENCE PARAMETERS.               */         06412010
                           IF DATA_REMOTE THEN                                  06193020
                              CALL PARM_STAT(LEFTOP,'CSLD');                    06412040
   /*----------------------------------------------------------------*/         06412060
                           CALL RETURN_STACK_ENTRY(XVAL(LEFTOP));               06369000
                           CALL SET_RESULT_REG(LEFTOP, FULLBIT);                06369500
                           COLUMN(LEFTOP), DEL(LEFTOP) = 0;                     06370000
                        END;                                                    06370500
                     END;                                                       06371000
                  END;                                                          06371500
                  ;                                                             06372000
                  ;                                                             06372500
                  DO CASE OPCODE;                                               06373000
                     ;                                                          06373500
                     DO;  /* STOB  */                                           06374000
                        LITTYPE = INTEGER;                                      06374500
                        LEFTOP = GET_OPERAND(1);                                06375000
                        IF FORM(LEFTOP) ^= LIT | LOC(LEFTOP) < 0 THEN           06375500
                           CALL FORCE_BY_MODE(LEFTOP, DINTEGER);                06376000
                        ELSE IF TAG1 ^= LIT THEN                                06376500
                           CALL LITERAL(LOC(LEFTOP), DINTEGER, LEFTOP);         06377000
                        TYPE(LEFTOP) = FULLBIT;                                 06377500
                        SIZE(LEFTOP) = WORDSIZE;                                06378000
                     END;                                                       06378500
                     DO;  /* STOQ  */                                           06379000
  /*DR120224*/          LITTYPE = DSCALAR;                                      06379500
                        LEFTOP = GET_OPERAND(1);                                06380000
                        IF FORM(LEFTOP) = VAC THEN                              06380500
                           CALL CHECKPOINT_REG(REG(LEFTOP), TRUE);               6381000
            /* ARGUMENT IS SINGLE PRECISION OR SUBBIT IS NOT SUBSCRIPTED */
                        IF (TYPE(LEFTOP)&8) = 0 | NUMOP = 1 THEN DO;            06381500
                           TYPE(LEFTOP) = FULLBIT;                              06382000
                           SIZE(LEFTOP) = WORDSIZE;                             06382500
  /*DR120224   IF ARG IS A LIT, THEN SET LOC TO -1 SO IT CANNOT BE ALTERED */
  /*DR120224*/             IF FORM(LEFTOP)=LIT THEN LOC(LEFTOP) = -1;
                        END;                                                    06383000
            /* ARGUMENT IS DOUBLE PRECISION AND SUBBIT IS SUBSCRIPTED */
                        ELSE DO;                                                06383500
                           ALCOP = LEFTOP;                                      06384000
                           SUBOP = 2;                                           06384500
                           SUBCODE = 0;                                         06385000
                           CALL GET_SUBSCRIPT;                                  06385500
                           TYPE(LEFTOP) = EXTRABIT;                             06386000
                           SIZE(LEFTOP) = WORDSIZE;                             06386500
                           DO CASE TAG3;                                        06387000
                              DO;  /* TSTAR  */                                 06387500
                                 TYPE(LEFTOP) = FULLBIT;                        06388000
  /*DR120224   IF ARG IS A LIT, THEN SET LOC TO -1 SO IT CANNOT BE ALTERED */
  /*DR120224*/                   IF FORM(LEFTOP) = LIT THEN LOC(LEFTOP) = -1;
                              END;                                              06388500
                              DO;  /* TINDEX  */                                06389000
                                 /* SUBSCRIPT IS A LITERAL */
                                 IF FORM(RIGHTOP) = LIT THEN DO;                06389500
                                    TYPE(LEFTOP) = FULLBIT;                     06390000
                                    /* SUBSCRIPT IS IN BITS 33-64 */
                                    IF VAL(RIGHTOP) > WORDSIZE THEN DO;         06390500
                                      INX_CON(LEFTOP) = INX_CON(LEFTOP) + 2;    06391000
                                      VAL(RIGHTOP) = VAL(RIGHTOP) - WORDSIZE;   06391500
  /*DR120224   IF ARG IS A LIT THEN SET VAL EQUAL TO THE 2ND HALF OF THE   */
  /*DR120224   FLOATING POINT VALUE.                                       */
  /*DR120224*/                        IF FORM(LEFTOP) = LIT THEN
  /*DR120224*/                          VAL(LEFTOP) = XVAL(LEFTOP);
                                    END;                                        06392000
                                    CALL BIT_SUBSCRIPT;                         06392500
                                 END;                                           06393000
                                 /* SUBSCRIPT IS UNKNOWN AT COMPILE TIME */
                                 ELSE CALL CHAR_SUBSCRIPT;                      06393500
                              END;                                              06394000
                              DO;  /* TTSUB */                                  06394500
                  /* THE PARTITION IS COMPLETELY IN BITS 1-32 OR BITS 33-64. */
                                 IF VAL(RIGHTOP)<=WORDSIZE&VAL(EXTOP)<=WORDSIZE 06395000
                                  | VAL(RIGHTOP) > WORDSIZE THEN DO;            06395500
                                    TYPE(LEFTOP) = FULLBIT;                     06396000
                                    /* PARTITION IS IN BITS 33-64 */
                                    IF VAL(RIGHTOP) > WORDSIZE THEN DO;         06396500
                                       INX_CON(LEFTOP) = INX_CON(LEFTOP) + 2;   06397000
                                       VAL(RIGHTOP) = VAL(RIGHTOP) - WORDSIZE;  06397500
                                       VAL(EXTOP) = VAL(EXTOP) - WORDSIZE;      06398000
  /*DR120224   IF ARG IS A LIT THEN SET VAL EQUAL TO THE 2ND HALF OF THE   */
  /*DR120224   FLOATING POINT VALUE.                                       */
  /*DR120224*/                         IF FORM(LEFTOP) = LIT THEN
  /*DR120224*/                            VAL(LEFTOP) = XVAL(LEFTOP);
                                    END;                                        06398500
                                    CALL BIT_SUBSCRIPT;                         06399000
                                 END;                                           06399500
                     /* PARTITION STARTS IN BITS 1-32 BUT ENDS IN BITS 33-64 */
                                 ELSE CALL CHAR_SUBSCRIPT;                      06400000
                              END;                                              06400500
                              DO;  /* TASUB  */                                 06401000
                           /* LOCATION OF PARTITION IS KNOWN AT COMPILE TIME */
                                 IF FORM(EXTOP) = LIT THEN DO;                  06401500
                                    TMP = VAL(EXTOP) + VAL(RIGHTOP) - 1;        06402000
                       /* PARTITION IS COMPLETELY IN BITS 1-32 OR BITS 33-64 */
                                    IF VAL(EXTOP) <= WORDSIZE & TMP <= WORDSIZE 06402500
                                     | VAL(EXTOP) > WORDSIZE THEN DO;           06403000
                                       TYPE(LEFTOP) = FULLBIT;                  06403500
                                       /* PARTITION IN BITS 33-64 */
                                       IF TMP > WORDSIZE THEN DO;               06404000
                                          INX_CON(LEFTOP) = INX_CON(LEFTOP) + 2;06404500
                                          VAL(EXTOP) = VAL(EXTOP) - WORDSIZE;   06405000
  /*DR120224   IF ARG IS A LIT THEN SET VAL EQUAL TO THE 2ND HALF OF THE   */
  /*DR120224   FLOATING POINT VALUE.                                       */
  /*DR120224*/                            IF FORM(LEFTOP) = LIT THEN
  /*DR120224*/                              VAL(LEFTOP) = XVAL(LEFTOP);
                                       END;                                     06405500
                                       CALL BIT_SUBSCRIPT;                      06406000
                                    END;                                        06406500
                    /* PARTITION STARTS IN BITS 1-32 BUT ENDS IN BITS 33-64. */
                                    ELSE CALL CHAR_SUBSCRIPT;                   06407000
                                 END;                                           06407500
                        /* LOCATION OF PARTITION IS UNKNOWN AT COMPILE TIME. */
                                 ELSE CALL CHAR_SUBSCRIPT;                      06408000
                              END;                                              06408500
                           END;  /* CASE TAG3  */                               06409000
  /*DR120224   IF ARGUMENT IS A LITERAL AND PARTITION CAN BE FOUND DURING   */
  /*DR120224   COMPILE TIME THEN SHIFT AND MASK IT NOW.                     */
  /*DR120224*/             IF FORM(LEFTOP)=LIT & TYPE(LEFTOP)=FULLBIT THEN
  /*DR120224*/               IF BIT_PICK(LEFTOP)>0 THEN DO;
  /*DR120224*/                 CALL BIT_SHIFT(SRL,LEFTOP,COLUMN(LEFTOP));
  /*DR120224*/                 VAL(LEFTOP)=VAL(LEFTOP) & XITAB(SIZE(LEFTOP));
  /*DR120224*/                 CALL RETURN_STACK_ENTRY(COLUMN(LEFTOP));
  /*DR120224*/                 INX_CON(LEFTOP), COLUMN(LEFTOP) = 0;
  /*DR120224*/                 LOC(LEFTOP) = -1;
  /*DR120224*/               END;
                           IF SELF_ALIGNING THEN IF TYPE(LEFTOP) = FULLBIT THEN 06409010
                           IF INX(LEFTOP) ^= 0 THEN DO;                         06409020
                              IF INX(LEFTOP) < 0 THEN                           06409030
                                 CALL RELOAD_ADDRESSING(FINDAC(INDEX_REG),      06409040
                                    LEFTOP, 0);                                 06409050
                              CALL VERIFY_INX_USAGE(LEFTOP);                    06409060
                              CALL EMITRR(AR, INX(LEFTOP), INX(LEFTOP));        06409070
                           END;                                                 06409080
               /* PARTITION MUST BE FOUND WITH A RUN-TIME LIBRARY ROUTINE.  */
                           IF TYPE(LEFTOP) = EXTRABIT THEN IF ^TAG THEN DO;     06409500
   /*------------------------- #DREG --------------------------------*/         03607518
                              D_RTL_SETUP = TRUE;                               03561001
   /*----------------------------------------------------------------*/         03607518
  /*DR120224  THE PARTITION MUST BE FOUND DURING EXECUTION, THEREFORE THE LIT */
  /*DR120224  IS LOADED INTO MEMORY.  HOWEVER, XVAL IS NOT LOADED WITH TYPE=  */
  /*DR120224  EXTRABIT.  SO, TEMPORARILY CHANGE THE TYPE TO DOUBLE SCALAR.    */
  /*DR120224  THIS WILL FORCE THE FULL DOUBLE PRECISION SCALAR INTO MEMORY.   */
  /*DR120224*/                IF FORM(LEFTOP)=LIT THEN
  /*DR120224*/                   TYPE(LEFTOP) = DSCALAR;
                              CALL STACK_REG_PARM(FORCE_ADDRESS(PTRARG1,LEFTOP, 06410000
                                 1));                                           06410500
  /*DR120224*/                TYPE(LEFTOP) = EXTRABIT;
                              CALL SET_CHAR_DESC(LEFTOP, FIXARG1, FIXARG2);     06411000
                              CALL DROP_PARM_STACK;                             06411500
                              CALL GENLIBCALL('DSLD');                          06412000
   /*-------------------- DANNY #DPARM --- RTL DSLD ROUTINE ---------*/         06412010
   /* RESTRICT REMOTE #D PASS BY REFERENCE PARAMETERS.               */         06412010
                              IF DATA_REMOTE                                    06193020
                                 THEN CALL PARM_STAT(LEFTOP,'DSLD');            06412040
   /*----------------------------------------------------------------*/         06412060
                              CALL SET_RESULT_REG(LEFTOP, FULLBIT);             06412500
                              COLUMN(LEFTOP), DEL(LEFTOP) = 0;                  06413000
                           END;                                                 06413500
                        END;                                                    06414000
                     END;                                                       06414500
                  END;                                                          06415000
                  DO CASE OPCODE;                                               06415500
                     ;                                                          06416000
                     DO;  /* ITOB  */                                           06416500
                        LITTYPE = INTEGER;                                      06417000
                        LEFTOP = GET_OPERAND(1);                                06417500
                        IF NUMOP = 1 THEN                                       06417510
                           GO TO INTEGER_SUBBIT;                                06417520
                        IF TYPE(LEFTOP) = INTEGER THEN              /*DR120225*/
                           TYPE(LEFTOP) = BITS;                     /*DR120225*/
                        ELSE TYPE(LEFTOP) = FULLBIT;                /*DR120225*/
  /*DR120224*/          IF FORM(LEFTOP) ^= LIT THEN DO;                         06418000
                           CALL FORCE_ACCUMULATOR(LEFTOP, FULLBIT);             06418500
                           TYPE(LEFTOP) = FULLBIT;                              06419000
  /*DR120224*/          END;
  /*DR120224   LOC NEEDS TO BE SET TO -1 SO WHEN THE INTEGER IS LOADED   */
  /*DR120224   INTO THE REGISTER THE SIGN BIT WILL NOT BE PROPAGATED.    */
  /*DR120224*/          ELSE IF TYPE(LEFTOP) = BITS THEN LOC(LEFTOP) = -1;
                        SIZE(LEFTOP) = WORDSIZE;                                06419500
                     END;                                                       06420000
                     DO;  /* ITOQ  */                                           06420500
                        LITTYPE = INTEGER;                                      06421000
                        LEFTOP = GET_OPERAND(1);                                06421500
                     INTEGER_SUBBIT:                                            06421505
                        IF CONST(LEFTOP)^=0 THEN CALL FORCE_ACCUMULATOR(LEFTOP); 6421510
                        DO CASE (TYPE(LEFTOP)&8)^=0;                            06422000
                           DO;                                                  06422500
                              TYPE(LEFTOP) = BITS;                              06423000
                              SIZE(LEFTOP) = HALFWORDSIZE;                      06423500
  /*DR120224   LOC NEEDS TO BE SET TO -1 SO WHEN THE INTEGER IS LOADED   */
  /*DR120224   INTO THE REGISTER THE SIGN BIT WILL NOT BE PROPAGATED.    */
  /*DR120224*/                IF FORM(LEFTOP) = LIT THEN LOC(LEFTOP) = -1;
                           END;                                                 06424000
                           DO;                                                  06424500
                              TYPE(LEFTOP) = FULLBIT;                           06425000
                              SIZE(LEFTOP) = WORDSIZE;                          06425500
                           END;                                                 06426000
                        END;                                                    06426500
                     END;                                                       06427000
                  END;                                                          06427500
               END;                                                             06428000
               TAG = CLASS;                                                     06428500
               IF SUBCODE > 0 & NUMOP > 1 THEN DO;                              06429000
                  IF DEL(LEFTOP) ^= 0 THEN CALL FORCE_ACCUMULATOR(LEFTOP);       6429010
                  ALCOP = LEFTOP;                                               06429500
                  CALL DO_DSUB;                                                 06430000
  /*DR120224   ARGUMENT IS A LITERAL AND MAY NEED TO BE SHIFTED.         */
  /*DR120224*/    IF BIT_PICK(ALCOP) > 0 & FORM(ALCOP) = LIT THEN DO;
  /*DR120224   THE SHIFTING AMOUNT IS KNOWN AT COMPILE TIME.             */
  /*DR120224*/       IF FORM(COLUMN(ALCOP)) = LIT THEN DO;
  /*DR120224   THIS IS CHECKING FOR A SINGLE PRECISION INTEGER ARGUMENT  */
  /*DR120224   IN THE BIT FUNCTION AND THE PARTITION IS IN BITS 1-16.    */
  /*DR120224   SINCE THE SIGN BIT IS NOT SUPPOSED TO BE PROPAGATED WHEN  */
  /*DR120224   THE SINGLE PRECISION INTEGER IS CONVERTED TO 32-BIT       */
  /*DR120224   FORMAT, THE RESULT MUST BE ZERO.                          */
  /*DR120224*/          IF (SUBCODE=6) & (OPCODE=1) & (TYPE(ALCOP)=BITS) &
  /*DR120224*/             (VAL(COLUMN(ALCOP)) > 15)
  /*DR120224*/          THEN DO;
  /*DR120224*/            VAL(ALCOP) = 0;
  /*DR120224*/            TYPE(ALCOP) = FULLBIT;
  /*DR120224*/          END;
  /*DR120224*/          ELSE DO;
  /*DR120224   THIS IS CHECKING FOR A SINGLE PRECISION INTEGER ARGUMENT  */
  /*DR120224   IN THE BIT FUNCTION AND THE PARTITION STARTS IN BITS 1-16 */
  /*DR120224   BUT ENDS IN BITS 17-32. CHANGE THE SIZE OF THE PARTITION  */
  /*DR120224   SO IT ONLY RETRIEVES THE BITS IN THE LOWER HALF (17-32)  .*/
  /*DR120224   THIS IS NEEDED SO THE SIGN BIT IS NOT PROPAGATED.         */
  /*DR120224*/            IF (SUBCODE=6) & (OPCODE=1) & (TYPE(ALCOP)=BITS) &
  /*DR120224*/               (VAL(COLUMN(ALCOP)) + SIZE(ALCOP) > 16)
  /*DR120224*/            THEN SIZE(ALCOP) = 16 - VAL(COLUMN(ALCOP));
  /*DR120224   SHIFT AND MASK LITERAL ARGUMENTS WITH PARTITIONS KNOWN AT */
  /*DR120224   COMPILE TIME.                                             */
  /*DR120224*/            CALL BIT_SHIFT(SRL,ALCOP,COLUMN(ALCOP));
  /*DR120224*/            VAL(ALCOP) = VAL(ALCOP) & XITAB(SIZE(ALCOP));
  /*DR120224*/          END;
  /*DR120224*/          CALL RETURN_STACK_ENTRY(COLUMN(ALCOP));
  /*DR120224*/          COLUMN(ALCOP) = 0;
  /*DR120224*/       END;
  /*DR120224   FOR SINGLE PRECISION INTEGER LITERAL ARGUMENTS IN THE BIT   */
  /*DR120224   FUNCTION AND THE LOCATION OF THE PARTITION IS NOT KNOWN AT  */
  /*DR120224   COMPILE TIME, LOAD THEM NOW IN 16-BIT FORMAT AND SHIFT THEM */
  /*DR120224   INTO 32-BIT FORMAT.  SET TYPE TO FULLBIT SO THE COMPILER    */
  /*DR120224   CAN TELL IT IS LOADED IN THE REG IN 32-BIT FORMAT.  THIS IS */
  /*DR120224   NEEDED TO AVOID THE SIGN BIT FROM PROPAGATING.              */
  /*DR120224*/       ELSE IF (SUBCODE=6) & (OPCODE=1) & (TYPE(ALCOP)=BITS)
  /*DR120224*/       THEN DO;
  /*DR120224*/          CALL FORCE_ACCUMULATOR(ALCOP, FULLBIT);
  /*DR120224*/          TYPE(ALCOP) = FULLBIT;
  /*DR120224*/       END;
  /*DR120224*/       LOC(ALCOP) = -1;
  /*DR120224*/    END;
               END;                                                             06430500
               ELSE CALL SETUP_VAC(LEFTOP);                                     06431000
            END CLASS1;                                                         06431500
   END GEN_CLASS1;                                                              06432000
