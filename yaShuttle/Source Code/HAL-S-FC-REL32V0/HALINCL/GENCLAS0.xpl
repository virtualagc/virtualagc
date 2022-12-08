 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS0.xpl
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
 
/***********************************************************************   */
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*07/26/90 RPC   23V1  102954 NAME REMOTE COMPARISON INCORRECT OBJ CODE    */
/*                                                                         */
/*08/03/90 RPC   23V1  102972 ZCON TO REMOTE NAME                          */
/*                                                                         */
/*08/17/90 RPC   23V1  102971 %COPY OF A REMOTE NAME                       */
/*                                                                         */
/*10/12/90 RAH   23V1  102965 %NAMECOPY FAILS TO GENERATE FT111 ERROR MSG  */
/*                                                                         */
/*10/14/90 RAH   23V1  103761 INVALID XQ102 ERROR GENERATED FOR REMOTE     */
/*                            NAME ASSIGNMENT                              */
/*                                                                         */
/*01/21/91 DKB   23V2  CR11098 DELETE SPILL CODE FROM COMPILER             */
/*                                                                         */
/*03/05/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
/*                                                                         */
/*07/09/91 RSJ   24V0  CR11096 #DMVH - CHANGE SETUP FOR THE MVH            */
/*                             INSTRUCTION TO SUPPORT THE #D COMPILER      */
/*                                                                         */
/*07/15/91 DAS   24V0  CR11096 #DDSE - SET UP DSES AT PROLOG, CLEAR        */
/*                             DSES AT EPILOG OF COMSUB                    */
/*                                                                         */
/*07/15/91 DAS   24V0  CR11096 #DNAME - DO YCON TO ZCON CONVERT WHEN       */
/*                             LOADING NAME OF #D DATA                     */
/*                                                                         */
/*07/15/91 DAS   24V0  CR11096 #DPARM - RESTRICT #D PASS-BY-REFERENCE      */
/*                             PARAMETERS, & CONVERT #D ADDRESS TO ZCON    */
/*                             OR COPY TO STACK WHEN PASSED TO RTL         */
/*                                                                         */
/*07/15/91 DAS   24V0  CR11096 #DREG - NEW #D REGISTER ALLOCATION:         */   00390000
/*                             R1 OR R3 FOR #D, R2 OTHERWISE               */   00400000
/*                                                                         */   00410000
/*07/15/91 DAS   24V0  103775 #DWRITE - WRITE REMOTE AGGREGATES            */   00420000
/*                            OF TYPE CHARACTER AND STRUCTURE              */   00430000
/*                                                                         */   00430001
/*09/23/91 DAS   24V0  103783 #DWRITE - WRITE REMOTE AGGREGATES            */   00430002
/*                            OF TYPE VECTOR/MATRIX                        */   00430003
/*                                                                         */   00430004
/*06/27/91 TEV    7V0  CR11114 MERGE BFS/PASS COMPILERS WITH DR/CR FIXES   */
/*         PMA                                                             */
/*         JAC                                                             */
/*                                                                         */
/*12/10/92 JAC    8V0  *      MERGE 7V0 AND 24V0 COMPILERS                 */
/*                            * SAME AS IN 24V0                            */
/*                                                                         */
/*04/02/93 NLM   25V0  CR11139 ADD XR4 ERROR MESSAGE FOR FCOS              */
/*                             RESTRICTIONS                                */
/*                                                                         */
/*04/16/93 NLM   25V0/ 108621 R1 USED AS DESTINATION REGISTER FOR MVH      */
/*                9V0                                                      */
/*                                                                         */
/*05/18/93 LJK   25V0  104835 %NAMEADD WITH THE 3RD ARGUMENT A LITERAL     */
/*                9V0         STILL FAILS                                  */
/*                                                                         */
/*06/02/93 RPC   25V0  108616 R2 USED AS A BASE REGISTER WITH INCORRECT    */
/*               9V0          VALUE                                        */
/*                                                                         */
/*06/12/92 NLM   25V0/ 102956 INCORRECT DATA ADDRESSES PASSED TO           */
/*                9V0         RTL ROUTINES FOR MAX, MIN, PROD AND SUM      */
/*                            FUNCTIONS WITH REMOTE ARGUMENTS              */
/*                                                                         */
/*01/27/94 DAS   26V0/ 107273 INCORRECT SETUP FOR MVH                      */
/*               10V0                                                      */
/*                                                                         */
/*02/01/94 JAC   26V0/ 108602 COMPILER FAILS TO EMIT FT108 ERROR MESSAGE   */
/*               10V0                                                      */
/*                                                                         */
/*02/01/94 DAS   26V0/ 102945 INCORRECT CHECK FOR EXIT CONDITION IN        */
/*               10V0         DO FOR LOOP                                  */
/*                                                                         */
/*12/21/93 JAC   26V0/ 103767 %COPY GENERATES INVALID FN106                */
/*               10V0  103771 %COPY GENERATES INVALID FN107                */
/*                                                                         */
/*03/08/94 DAS   26V0/ 102957 VALID CLOSE STATEMENT GETS BI506 ERROR       */
/*               10V0         BECAUSE OF INCORRECT INDEX ADDITION          */
/*                                                                         */
/*03/11/94 RSJ   26V0/ 108638 R4 USED AS A BASE REGISTER                   */
/*               10V0                                                      */
/*                                                                         */
/*03/11/94 RSJ   26V0/ 103794 INCORRECT REGISTER SETUP FOR CPR             */
/*               10V0                                                      */
/*                                                                         */
/*03/22/94 RSJ   26V0/ 109014 REGISTERS NOT MARKED DESTROYED BY CPR        */
/*               10V0                                                      */
/*                                                                         */
/*03/31/94 DAS   26V0/ 109012 BAD STRUCTURE COMPARE WITH CHARACTER         */
/*               10V0         TERMINAL                                     */
/*                                                                         */
/*04/06/94 JAC   26V0/ 108643 INCORRECTLY LISTS 'NONHAL' INSTEAD OF        */
/*               10V0         'INCREM' IN SDFLIST                          */
/*                                                                         */
/*02/07/94 TEV   26V0/ 109017 INCORRECT INDEXING OF NAME VARIABLE          */
/*               10V0                                                      */
/*                                                                         */
/*06/07/95 HFG   27V0/ 109023 WRITE OF STRUCTURE CONTAINING ARRAY          */
/*               11V0         IS INCORRECT                                 */
/*                                                                         */
/*04/21/95 DAS   27V0/ 109010 INCORRECT AMOUNT OF RUN-TIME STACK SPACE     */
/*               11V0         RESERVED FOR CHARACTER ARRAYS                */
/*                                                                         */
/*03/23/95 RSJ   27V0/ 109033 INDEX REGISTER NOT INVALIDATED AFTER         */
/*               11V0         A %NAMEADD MACRO                             */
/*                                                                         */
/*02/28/95 BAF   27V0/ 107694 INCORRECT INITIALIZATION OF CHARACTER        */
/*               11V0                                                      */
/*                                                                         */
/*01/31/95 DAS   27V0/ 109030 WRONG VALUE LOADED FROM REGISTER AFTER       */
/*               11V0         %COPY OR DSST                                */
/*                                                                         */
/*03/06/95 RSJ   27V0/ 109019 COMPILER INCORRECTLY ADJUSTS FOR AUTO        */
/*               11V0         INDEX ALIGNMENT                              */
/*                                                                         */
/*02/28/95 TEV   27V0/ 107697 INCORRECT LENGTH ON COPY CHARACTER(*)        */
/*               11V0                                                      */
/*                                                                         */
/*12/05/94 DAS   27V0/ 107698 ILLEGAL DISPLACEMENT VALUE IN INDEXED        */
/*               11V0         RS INSTUCTION (DO CASE)                      */
/*                                                                         */
/*11/16/94 RSJ   27V0/ 109022 WRONG REGISTER USED FOR CSTR WITH            */
/*               11V0         DATA_REMOTE                                  */
/*                                                                         */
/*11/02/94 DAS   27V0/ 107705 RLD WRITTEN TO WRONG ADDRESS                 */
/*               11V0                                                      */
/*                                                                         */
/*10/21/94 RSJ   27V0/ 107714 CSE CLOBBERED AFTER STRUCTURE COMPARE        */
/*               11V0                                                      */
/*                                                                         */
/*02/08/96 RCK   27V1/ 103759 ASSIGNMENT OF NULL TO NAME REMOTE            */
/*               11V1         GETS XQ102 ERROR                             */
/*                                                                         */
/*12/01/95 DAS   27V1/ 109037 ZH INSTRUCTION MISSING FROM DROP 2 TEST      */
/*               11V1                                                      */
/*                                                                         */
/*12/19/95 TEV   27V1/ 107691 EXTRANEOUS FN106 FOR AGGREGATE ASSIGN        */
/*               11V1                                                      */
/*                                                                         */
/*06/11/97 TEV   28V0/ 109046 NAME REMOTE PARAMETER SETUP IS BAD           */
/*               12V0                                                      */
/*                                                                         */
/*04/08/97 DAS   28V0/ CR12432 ALLOW DEREFERENCING OF NAME REMOTE          */
/*               12V0                                                      */
/*                                                                         */
/*10/09/96 TEV   28V0/ 110232 MISSING INITIALIZATION FOR BIT STRINGS ON    */
/*               12V0         STACK                                        */
/*                                                                         */
/*04/16/98 DWM   29V0/ 109063 SHIFTING MORE THAN 55 SPACES DOES NOT LOAD   */
/*               14V0         SHIFT AMOUNT INTO A REGISTER                 */
/*                                                                         */
/*04/07/98 DAS   29V0/ CR12935 ALLOW REMOTE PASS BY REFERENCE              */
/*               14V0          PARAMETERS                                  */
/*                                                                         */
/*02/17/98 DCP   29V0/ 109069 INDIRECT STACK ENTRY NOT RETURNED FOR        */
/*               14V0         REMOTE STRUCTURE                             */
/*                                                                         */
/*10/03/97 SMR   29V0/ 109067 INDIRECT STACK ENTRY NOT RETURNED FOR        */
/*               14V0         STRUCTURE INITIALIZATION.                    */
/*                                                                         */
/*09/25/97 SMR   29V0/ 109059 INDIRECT STACK ENTRY FOR EVENT NOT RETURNED  */
/*               14V0                                                      */
/*                                                                         */
/*09/25/97 SMR   29V0/ 109064 INDIRECT STACK ENTRY NOT RETURNED FOR %COPY  */
/*               14V0                                                      */
/*                                                                         */
/*01/05/00 TKN   30V0/ 13211  GENERATE ADVISORY MSG WHEN BIT STRING        */
/*               15V0         ASSIGNED TO SHORTER STRING                   */
/*                                                                         */
/*11/03/99 DCP   30V0/ 111345 BI511 ERROR GENERATED FOR PARAMETER          */
/*               15V0                                                      */
/*                                                                         */
/*12/02/99 DAS   30V0/ 111346 NAME REMOTE INPUT PARAMETER ON STACK FAILS   */
/*               15V0                                                      */
/*                                                                         */
/*12/09/99 DAS   30V0  CR13212 ALLOW NAME REMOTE VARIABLES IN THE          */
/*               15V0           RUNTIME STACK                              */
/*                                                                         */
/*12/14/99 JAC   30V0/ 111347 NO REMOTE ATTRIBUTE ERROR CHECKING FOR       */
/*               15V0         INPUT PARAMETER                              */
/*                                                                         */
/*07/19/99 TKN   30V0/ 111337 %COPY USING ASTERISK (*) SUBSCRIPTED         */
/*               15V0         ARGUMENT DOES NOT GET AN ERROR               */
/*                                                                         */
/*07/14/99 DCP   30V0/ 12214  USE THE SAFEST %MACRO THAT WORKS             */
/*               15V0                                                      */
/*                                                                         */
/*01/22/99 TKN   30V0/ 111325 INCORRECT FN106 ERROR GENERATED FOR %COPY    */
/*               15V0         STATEMENT                                    */
/*                                                                         */
/*05/14/99 TKN   30V0/ 111308 COMPILER INCORRECTLY ADJUSTS FOR AUTO INDEX  */
/*               15V0         ALIGNMENT                                    */
/*                                                                         */
/*05/03/01 JAC   31V0/ 111362 UNNECESSARY STACK WALKBACK                   */
/*               16V0                                                      */
/*                                                                         */
/*08/08/01 JAC   31V0/ 111370 OC4 ERROR FOR LARGE LITSTRING VALUE          */
/*               16V0                                                      */
/*                                                                         */
/*03/15/01 DAS   31V0/ 111373 OC4 ABEND FOR REMOTE %NAMEADD                */
/*               16V0                                                      */
/*                                                                         */
/*12/01/00 TKN   31V0/ 111351 NAME REMOTE PARAMETER PASSING FAILS          */
/*               16V0                                                      */
/*                                                                         */
/*12/14/00 KHP   31V0/ 111359 INCORRECT ZCON XC BIT IN %NAMEADD OF NAME    */
/*               16V0         REMOTE                                       */
/*                                                                         */
/*06/16/03 JAC   31V1/ 120221 BIT PARAMETER NOT TRUNCATED                  */
/*               16V1                                                      */
/*                                                                         */
/*08/23/02 DCP   32V0/ CR13571 COMBINE PROCEDURE/FUNCTION PARAMETER        */
/*               17V0          CHECKING                                    */
/*                                                                         */
/*09/13/02 JAC   32V0/ CR13570 CREATE NEW %MACRO TO PERFORM ZEROTH         */
/*               17V0          ELEMENT CALCULATIONS                        */
/*                                                                         */
/*09/04/02 DCP   32V0/ 13616  IMPROVE READABILITY AND ADD COMMENTS FOR     */
/*               17V0         NAME DEREFERENCES                            */
/*                                                                         */
/*07/12/02 JAC   32V0/ CR13538 ALLOW MIXING OF REMOTE AND NON-REMOTE       */
/*               17V0          POINTERS                                    */
/*                                                                         */
/*06/25/02 TKN   32V0/ 111396 POSSIBLE ABEND FOR %COPY STATEMENT           */
/*               17V0                                                      */
/*                                                                         */
/*05/10/02 DCP   32V0/ 111390 %NAMEADD INCORRECT FOR NAME REMOTE COUNT     */
/*               17V0         FIELD                                        */
/*                                                                         */
/*06/05/02 DCP   32V0/ 111393 FT112 ERROR NOT GENERATED FOR REMOTELY       */
/*               17V0         INCLUDED NAME VARIABLE                       */
/*                                                                         */
/*04/12/02 DCP   32V0/ 111381 COMPARISON FAILS FOR AUTOMATIC REMOTE        */
/*               17V0         VARIABLES                                    */
/*                                                                         */
/*02/26/02 JAC   32V0/ 111377 INCORRECT RESULTS FROM UNVERIFIED LIBRARY    */
/*               17V0         ROUTINE                                      */
/*                                                                         */
/*01/02/02 JAC   32V0/ 111387 REMOTE ARRAY INCORRECTLY PASSED TO SHAPING   */
/*               17V0         FUNCTION                                     */
/*                                                                         */
/*11/04/03 DCP   32V0/ 120230 INCORRECT FD100 ERROR FOR NAME INPUT         */
/*               17V0         PARAMETER                                    */
/*                                                                         */
/*03/02/04 DCP   32V0 CR13811 ELIMINATE STACK WALKBACK CAPABILITY          */
/*               17V0                                                      */
/*                                                                         */
/*09/10/03 JAC   32V0/ 120223 NO FT101 ERROR FOR LITERAL ARGUMENT          */
/*               17V0                                                      */
/*                                                                         */
/*08/03/04 JAC   32V0/ 120266 SLL AND SRL INSTRUCTION INCORRECTLY          */
/*               17V0         COMBINED                                     */
/*                                                                         */
/***************************************************************************/
   /* CLASS 0 OPERATORS - SYSTEM, CONTROL, REAL TIME, ETC. */                   04527500
GEN_CLASS0:                                                                     04528000
   PROCEDURE;                                                                   04528500
                                                                                04529000
/*CR12214 - ROUTINE TO DETERMINE IF PARAMETERS IN %NAMEADD MATCH*/
CHECK_NAMEADD:
   PROCEDURE;
      DECLARE (ARGLOC1, ARGLOC2, ARRNESS1, ARRNESS2, I, J, K) BIT(16);

      /* SETUP SYMBOL TABLE POINTER */
      /* DR111373 - REMOVE UNNECESSARY SHAPING FUNCTION CODE */
      ARGLOC1 = LOC2(RESULT);
      ARGLOC2 = LOC2(LEFTOP);

      /* CHECK IF ATTRIBUTES MATCH */
      IF (SYT_FLAGS(ARGLOC1) & NI_FLAGS) ^=
      (SYT_FLAGS(ARGLOC2) & NI_FLAGS) THEN DO;
        MISMATCH = TRUE; RETURN;
      END;
      ELSE IF (SYT_FLAGS(ARGLOC1) & LOCK_BITS) ^=
      (SYT_FLAGS(ARGLOC2) & LOCK_BITS) THEN DO;
        MISMATCH = TRUE; RETURN;
      END;

      /* CHECK IF DECLARED TYPES MATCH */
      IF SYT_TYPE(ARGLOC1) ^= SYT_TYPE(ARGLOC2) THEN DO;
        MISMATCH = TRUE; RETURN;
      END;

      /* ARRAYNESS MATCHING */
      IF COPY(LEFTOP) ^= COPY(RESULT) THEN DO;
        MISMATCH = TRUE; RETURN;
      END;

      /* DIMENSION MATCHING */
      ARRNESS1 = GETARRAY#(LOC(RESULT));
      ARRNESS2 = GETARRAY#(LOC(LEFTOP));
      IF (ARRNESS1 > 0) & (ARRNESS2 > 0) THEN
        DO I = 1 TO ARRNESS2;
        /* DR111373 - REMOVE UNNECESSARY SHAPING FUNCTION CODE */
          J = GETARRAYDIM(I, ARGLOC1);
          K = GETARRAYDIM(I, ARGLOC2);
          IF K ^< 0 THEN
            IF K ^= J THEN DO;
              MISMATCH = TRUE; RETURN;
            END;
      END;

      /* VECTOR/MATRIX MATCHING */
      IF SYT_TYPE(ARGLOC2) = VECMAT THEN DO;
        IF ROW(RESULT) ^= (SHR(SYT_DIMS(ARGLOC2),8)&"FF") |
        COLUMN(RESULT) ^= (SYT_DIMS(ARGLOC2)&"FF") THEN DO;
          MISMATCH = TRUE; RETURN;
        END;
      END;
      /* BIT LENGTH MATCHING */
      ELSE IF SYT_TYPE(ARGLOC2) = BITS THEN DO;
        IF SIZE(RESULT) ^= (SYT_DIMS(ARGLOC2) & "FF") THEN DO;
          MISMATCH = TRUE; RETURN;
        END;
      END;
      /* CHAR LENGTH MATCHING */
      ELSE IF SYT_TYPE(ARGLOC2) = CHAR THEN DO;
        IF (SIZE(RESULT) ^= -1) & (SYT_DIMS(ARGLOC2) ^= 1) THEN
          IF SIZE(RESULT) ^= (SYT_DIMS(ARGLOC2) & "FF") THEN DO;
            MISMATCH = TRUE; RETURN;
          END;
      END;
END CHECK_NAMEADD;

/*DR109067 - ROUTINE TO RETURN STACK ENTRIES FOR CERTAIN CASES OF */
/*NAME STRUCTURE INITIALIZATION.                                  */
RETURN_STRUCTURE_STACK:
   PROCEDURE;
      DECLARE I BIT(16);
      SAVE_STACK = FALSE;
      DO FOR I = 1 TO STACK_SIZE;
         IF SAVE_STACK(I) = TRUE THEN DO;
            CALL RETURN_STACK_ENTRY(I);
            SAVE_STACK(I) = FALSE;
         END;
      END;
   END RETURN_STRUCTURE_STACK;

   /* ROUTINE TO OUTPUT STACK MODIFIER CODE  */                                 04529500
EMITPDELTA:                                                                     04530000
   PROCEDURE;                                                                   04530500
      CALL EMITC(PDELTA, INDEXNEST);                                            04531000
      IF ASSEMBLER_CODE THEN                                                    04531500
      INFO = '+DELTA.'||SYT_NAME(PROC_LEVEL(INDEXNEST))||INFO;                  04534000
      INSMOD = 112 + INSMOD;  /* TO FORCE RS INSTRUCTION IN ALL CASES  */       04534500
   END EMITPDELTA;                                                              04535000
                                                                                04535500
   /* ROUTINE TO DEFINE THE VALUE OF A GENERATED STATEMENT LABEL */             04536000
DEFINE_LABEL:                                                                   04536500
   PROCEDURE(PTR, FLAG);                                                        04537000
      DECLARE (CODE, PTR) BIT(16);                                              04537500
      DECLARE FLAG BIT(1);                                                      04538000
      IF FORM(PTR) = LBL THEN IF SYT_TYPE(LOC(PTR)) = STMT_LABEL THEN           04538500
         FLAG = SYT_DIMS(LOC(PTR)) > 3 | SYT_DIMS(LOC(PTR)) < 1;                04539000
      CALL SET_LABEL(VAL(PTR), FLAG, 1);                                        04539500
      CODE = ULBL + FORM(PTR) - LBL;                                            04540000
      IF ASSEMBLER_CODE THEN DO;                                                04540500
         IF CODE = ULBL THEN CHARSTRING = SYT_NAME(LOC(PTR));                   04541000
         ELSE CHARSTRING = 'L#' || LOC(PTR);                                    04541500
         OUTPUT = HEX_LOCCTR||CHARSTRING||' EQU *';                             04542000
      END;                                                                      04542500
      CALL EMITC(CODE, LOC(PTR));                                               04543000
      CALL RETURN_STACK_ENTRY(PTR);                                             04543500
      LAST_FLOW_BLK = CURCBLK;                                                  04543600
      LAST_FLOW_CTR = CTR;                                                      04543610
      FLAG = FALSE;                                                             04544000
   END DEFINE_LABEL;                                                            04544500
 /?P  /* CR11114 -- BFS/PASS INTERFACE */
                                                                                04548500
   /* ROUTINE TO ALLOCATE STACK DISPLACEMENT FOR ERROR NUMBER */                04549000
SET_ERRLOC:                                                                     04549500
   PROCEDURE(OP, ERRNUM);                                                       04550000
      DECLARE (OP, ERRNUM, I) BIT(16);                                          04550500
      IF VAL(OP) = "FF" THEN DO;                                                04551500
         VAL(OP) = "3F";                                                        04552000
         I = MAXERR(INDEXNEST) - 1;                                             04552500
         GO TO FOUND_ERRSETA;                                                   04553000
      END;                                                                      04553500
    ELSE DO;                                                                    04554000
      VAL(OP) = SHL(ERRNUM, 6) + VAL(OP);                                       04555000
      DO I = ERRPTR(INDEXNEST) TO ERRPTR-1;                                     04555500
         IF ERR_STACK(I) = VAL(OP) THEN                                         04556000
            GO TO FOUND_ERRSET;                                                 04556500
      END;                                                                      04557000
      IF I > ARG_STACK# THEN                                                    04557500
         CALL ERRORS(CLASS_BS,111);                                             04558000
      ERR_STACK(I) = VAL(OP);                                                   04558500
      IF ERRNUM = "3F" THEN DO;                                                 04559000
         ERRALL(INDEXNEST) = ERRALL(INDEXNEST) + 1;                             04559500
         ERR_DISP(I)=MAXERR(INDEXNEST)-ERRALL(INDEXNEST)-ERRALLGRP(INDEXNEST);  04560000
      END;                                                                      04560500
      ELSE ERR_DISP(I) = I - ERRALL(INDEXNEST) - ERRPTR(INDEXNEST);             04561000
      ERRPTR = ERRPTR + 1;                                                      04561500
   FOUND_ERRSET:                                                                04562000
      I = ERR_DISP(I);                                                          04562500
    END;                                                                        04563000
   FOUND_ERRSETA:                                                               04563500
      FORM(OP) = WORK;                                                          04564000
      BASE(OP) = TEMPBASE;                                                      04564500
      DISP(OP) = SHL(I, 1) + ERRSEG(INDEXNEST);                                 04565000
      TYPE(OP) = INTEGER;                                                       04565500
   END SET_ERRLOC;                                                              04566000
 ?/
                                                                                04574000
   /* ROUTINE TO RETURN NUMBER OF COPIES OF A STRUCTURE  */                     04574500
GETSTRUCT#:                                                                     04575000
   PROCEDURE(OP) BIT(16);                                                       04575500
      DECLARE OP BIT(16);                                                       04576000
      IF SYT_ARRAY(OP) = 0 THEN RETURN 1;                                       04576500
      RETURN SYT_ARRAY(OP);                                                     04577000
   END GETSTRUCT#;                                                              04577500
                                                                                04578000
   /* ROUTINE TO PICK UP THE AGGREGATE ARRAY SIZE OF A STACK ENTRY */           04578500
GET_ARRAYSIZE:                                                                  04579000
   PROCEDURE(OP) BIT(16);                                                       04579500
      DECLARE (OP, COP, I) BIT(16);                                             04580000
      IF COPY(OP) = 0 THEN RETURN 1;                                            04580500
      IF SYMFORM(FORM(OP))                            /*DR111308*/              04581000
         | (NR_DEREF(OP) & FORM(OP) = NRTEMP) THEN    /*DR111308*/
           IF MAJOR_STRUCTURE(OP) THEN RETURN GETSTRUCT#(LOC(OP));              04581500
           ELSE RETURN LUMP_ARRAYSIZE(LOC2(OP));                                04582000
      COP = 1;                                                                  04582500
      DO I = VAL(OP) TO VAL(OP) + COPY(OP) - 1;                                 04583000
         COP = COP * SF_RANGE(I);                                               04583500
      END;                                                                      04584000
      RETURN COP;                                                               04584500
   END GET_ARRAYSIZE;                                                           04585000
                                                                                04585500
   /* ROUTINE TO FORCE NON-RECOGNITION OF VARIABLES POSSIBLY AFFECTED BY CALL */04586000
CLEAR_SCOPED_REGS:                                                              04586500
   PROCEDURE(NEST, BLOCK);                                                      04587000
      DECLARE (NEST, BLOCK, I) BIT(16);                                         04587500
      DO I = 0 TO REG_NUM;                                                      04588000
         IF USAGE(I) THEN                                                       04588500
            IF R_CONTENTS(I)=SYM|R_CONTENTS(I)=SYM2|R_CONTENTS(I)=APOINTER THEN  4589000
               IF SYT_NEST(R_VAR(I)) < NEST THEN                                04589500
                  IF BLOCK = 0 THEN                                             04590000
                     CALL UNRECOGNIZABLE(I);                                    04590010
                  ELSE IF R_CONTENTS(I) = APOINTER THEN DO;                     04590020
                     IF (SYT_FLAGS(R_VAR(I))&POINTER_OR_NAME)^=POINTER_FLAG THEN04590030
                        CALL UNRECOGNIZABLE(I);                                 04590040
                  END;                                                          04590050
                  ELSE IF (SYT_FLAGS(R_VAR(I)) & TEMPORARY_FLAG) = 0 THEN       04590060
                     CALL UNRECOGNIZABLE(I);                                    04590070
                  ELSE IF R_VAR(I) < BLOCK THEN                                 04590080
                     CALL UNRECOGNIZABLE(I);                                    04590090
      END;  /* DO I  */                                                         04590500
      BLOCK = 0;                                                                04590600
   END CLEAR_SCOPED_REGS;                                                       04591000
                                                                                04591500
   /* ROUTINE TO RELEASE 'HELD' REGISTERS FOR A STATEMENT */                    04592000
CLEAR_STMT_REGS:                                                                04592500
   PROCEDURE;                                                                   04593000
      DECLARE I BIT(16);                                                        04593500
      DO I = 0 TO REG_NUM;                                                      04594000
         IF USAGE(I) THEN                                                       04594500
            IF R_CONTENTS(I) = IMD THEN                                          4595000
               CALL UNRECOGNIZABLE(I);                                          04595500
      END;                                                                      04596000
   END CLEAR_STMT_REGS;                                                         04596500
                                                                                04597000
   /* ROUTINE TO SET UP THE INDIRECT STACK IN PREPARATION FOR A STRUCTURE SUB */04597500
GET_STRUCTOP:                                                                   04598000
   PROCEDURE(OP) BIT(16);                                                       04598500
      DECLARE OP BIT(16);                                                       04599000
      CALL DECODEPIP(OP);                                                       04599500
      RETURN STRUCTFIX(OP1, 1);                                                 04600000
   END GET_STRUCTOP;                                                            04600500
                                                                                04601000
   /* ROUTINE TO SET UP STACKS FOR A FUNCTION CALL  */                          04601500
GET_FUNC_RESULT:                                                                04602000
   PROCEDURE(OP) BIT(16);                                                       04602500
      DECLARE (OP, PTR) BIT(16);                                                04603000
      DO CASE PACKTYPE(TYPE(OP));                                               04603500
         DO;  /* VECTOR - MATRIX */                                             04604000
            PTR = GETFREESPACE(TYPE(OP), ROW(OP) * COLUMN(OP));                 04604500
            ROW(PTR) = ROW(OP);                                                 04605000
            COLUMN(PTR) = COLUMN(OP);                                           04605500
         END;                                                                   04606000
         DO;  /* BIT  */                                                        04606500
            PTR = GET_STACK_ENTRY;                                              04607000
            SIZE(PTR) = SIZE(OP);                                               04607500
         END;                                                                   04608000
         DO;  /* CHARACTER  */                                                  04608500
            PTR = GETFREESPACE(TYPE(OP), SIZE(OP)+2);                           04609000
            SIZE(PTR) = SIZE(OP);                                               04609500
         END;                                                                   04610000
         PTR = GET_STACK_ENTRY;                                                 04610500
         DO;  /* STRUCTURE  */                                                  04611000
            PTR = GETFREESPACE(STRUCTURE, SIZE(OP));                            04611500
            DEL(PTR) = DEL(OP);                                                 04612000
            SIZE(PTR) = SIZE(OP);                                               04612500
         END;                                                                   04613000
      END;                                                                      04613500
      IF SYT_PARM(LOC2(OP)) >= 0 THEN                                           04614000
         CALL FORCE_ADDRESS(SYT_PARM(LOC2(OP)), PTR);                           04614500
      TYPE(PTR) = TYPE(OP);                                                     04615000
      RETURN PTR;                                                               04615500
   END GET_FUNC_RESULT;                                                         04616000
                                                                                04616500
   /* ROUTINE TO SET UP TEMPLATES AND ADDRESSING FOR A WALK THROUGH A STRUCTURE 04617000
   */                                                                           04617500
SETUP_STRUCTURE:                                                                04618000
   PROCEDURE(OP, REF);                                                          04618500
      DECLARE (OP, REF, R) BIT(16);                                             04619000
      IF REF THEN R = SYSARG2(1-REMOTE_ADDRS);                                  04619500
      ELSE R = SYSARG1(1-REMOTE_ADDRS);                                         04620000
      CALL FORCE_ADDRESS(R, OP, 1);                                             04620500
      STRUCT_TEMPL(REF) = DEL(OP);                                              04621000
      STRUCT_REF(REF), STRUCT_MOD(REF) = 0;                                     04621500
      XVAL(OP) = -SYT_ADDR(DEL(OP));                                            04622000
      FORM(OP) = CSYM;                                                          04622500
      BASE(OP), BACKUP_REG(OP) = REG(OP);                                       04623000
      INX(OP), DISP(OP) = 0;                                                    04623500
      STRUCT_CON(OP), INX_CON(OP), REF = 0;                                     04624000
      STRUCT_INX(OP) = 0;                                                       04624500
   END SETUP_STRUCTURE;                                                         04625000
                                                                                04625500
   /* ROUTINE TO ADDRESS A TERMINAL ELEMENT OF A STRUCTURE  */                  04626000
ADDRESS_STRUCTURE:                                                              04626500
   PROCEDURE(PTR, OP, REF, TBASE);                                              04627000
      DECLARE (PTR, OP, REF, TBASE, TPTR) BIT(16);                              04627500
      DECLARE SHIFT_AMOUNT                BIT(8);  /* DR109023 */
      DECLARE IREG                        BIT(16); /* DR109023 */
      TMP = SYT_ADDR(OP) + STRUCT_MOD(REF) + INX_CON(PTR) + XVAL(PTR);          04628000
      IF TBASE > 0 | INX(PTR) ^= 0 | BACKUP_REG(PTR) < 0                        04628500
       THEN DO;                                                                 04629000
         IF TBASE = 0 THEN                                                      04629500
            BASE(PTR) = GET_R(PTR,LOADADDR); /*#DREG*/                          04630000
         /*------------------------- #DREG -------------------------*/          02160071
         /*ADDRESS WILL BE LOADED INTO BASE(PTR), SO RESTRICT IT.   */          02160071
         ELSE IF DATA_REMOTE THEN                                               02111078
                 BASE(PTR) = REG_STAT(PTR,TBASE,LOADADDR);                      02112078
         /*---------------------------------------------------------*/          02160071
         ELSE BASE(PTR) = TBASE;                                                04630500

         /* DR109023 FIX ---------------------------------- DR109023 */
         /* SINCE THE INDEX IS INCORPORATED INTO THE BASE ADDRESS,   */
         /* NO AUTO-INDEX-ALIGNMENT WILL OCCUR. ADJUST THE INDEX     */
         /* IF NECESSARY BEFORE IT IS INCORPORATED INTO THE BASE.    */
         IF INX(PTR) > 0 THEN DO;
            SHIFT_AMOUNT = SHIFT(TYPE(PTR));
            IF SHIFT_AMOUNT > 0 THEN DO;
               IF R_TYPE(INX(PTR)) = DINTEGER THEN DO;
               /* GET A NEW INDEX REG SO THE INDEX/COUNT     */
               /* WON'T BE CORRUPTED BY THE ALIGNMENT SHIFT. */
                  IREG = FINDAC(INDEX_REG);
                  /* FINDAC SETS R_TYPE(IREG) = INTEGER  */
                  CALL EMITRR(MAKE_INST(LOAD,R_TYPE(IREG),RR),
                              IREG,INX(PTR));
                  INX(PTR) = IREG;
               END;
               CALL EMITP(SLA, INX(PTR), 0, SHCOUNT, SHIFT_AMOUNT);
            END;
         END;
         /* --------------- END OF DR109023 FIX --------------- */

            /*---------------------------------------------*/
            /* DR103794/DR108638                           */
            /* WE MUST LOAD BASE(PTR) WITH REG(PTR)        */
            /* INCREMENTED BY TMP.                         */
            /* THIS IS THE FIRST ATTEMPT TO OPTIMIZE THIS  */
            /* WITH AN LA INSTRUCTION.                     */
            /* HOWEVER, WE CAN ONLY OPTIMIZE IF BASE <=3   */
            /* AND IT IS NOT A ZCON                        */
            /* ELSE OPTIMIZATION CANNOT BE DONE            */
            /*---------------------------------------------*/
         IF TMP > 0 & TMP < 2048 & INX(PTR) >= 0 &                              04631000
            BACKUP_REG(PTR) >= 0 &
            REG(PTR) <=3 &^REMOTE_ADDRS &
            ^(TMP > 55 & REG(PTR) = 3) THEN /* DAS DR109012 - AVOID LHI */

               CALL EMITRX(LA, BASE(PTR), INX(PTR), REG(PTR), TMP);             02150000

         ELSE DO;                                                               04632000
            IF BACKUP_REG(PTR) < 0 THEN                                         04632500
               CALL EMIT_BY_MODE(LOAD, BASE(PTR), -BACKUP_REG(PTR),             04633000
                  TYPE(-BACKUP_REG(PTR)));                                      04633500
            ELSE CALL EMITRR(LR, BASE(PTR), REG(PTR));                          04634000
            CALL CHECK_CSYM_INX(PTR, BASE(PTR));                                04634500
               /*---------------------------------------------*/
               /* DR103794/DR108638                           */
               /* THIS IS A SECOND ATTEMPT TO OPTIMIZE THE    */
               /* INCREMENTING OF BASE(PTR) BY TMP WITH  AN   */
               /* LA INSTRUCTION.                             */
               /* HOWEVER, WE CAN ONLY OPTIMIZE IF BASE <=3   */
               /* AND IT IS NOT A ZCON                        */
               /* ELSE WE HAVE TO CALL INCORPORATE            */
               /*---------------------------------------------*/
            IF TMP > 0 & TMP < 2048 & INX(PTR) >= 0 &                           04635000
               BASE(PTR) <=3 &^REMOTE_ADDRS &
               ^(TMP > 55 & BASE(PTR) = 3) THEN /* DAS DR109012 - AVOID LHI */

                  CALL EMITRX(LA, BASE(PTR), INX(PTR), BASE(PTR), TMP);         02150000

            ELSE DO;                                                            04636000
               TPTR = GET_STACK_ENTRY;                                          04636500
               /* DAS - DR102957: TYPE NEVER SET --- MUST BE INTEGER */         04636500
               TYPE(TPTR) = INTEGER;                                            04636500
               /* END   DR102957 ------------------------------------*/         04636500
               REG(TPTR) = BASE(PTR);                                           04637000
               CONST(TPTR) = TMP;                                               04637500
               IF INX(PTR) > 0 THEN                                             04638000
                  CALL EMITRR(AR, REG(TPTR), INX(PTR));                         04638500
               CALL INCORPORATE(TPTR);                                          04639000
               CALL RETURN_STACK_ENTRY(TPTR);                                   04639500
            END;                                                                04640000
         END;                                                                   04640500
         CALL DROP_INX(PTR);                                                    04641000
         DISP(PTR) = 0;                                                         04641500
      END;                                                                      04642000
      ELSE DO;                                                                  04642500
         BASE(PTR) = REG(PTR);                                                  04643000
         DISP(PTR) = TMP;                                                       04643500
      END;                                                                      04644000
      INX_CON(PTR), REF, TBASE = 0;                                             04644500
   END ADDRESS_STRUCTURE;                                                       04645000
                                                                                04645500
   /* ROUTINE TO PUSH OUT DYNAMIC ADDRESSING, USING LITERALS WHERE POSSIBLE */  04646000
FORCE_ADDR_LIT:                                                                 04646500
   PROCEDURE(TR, OP, MODIFIER, FLAG);                                           04647000
      DECLARE (TR, R, OP, MODIFIER) BIT(16), FLAG BIT(1);                       04647500
      R = TR;                                                                   04648000
      /*------------------------ #DREG ----------------------*/                 02601078
      /* R IS USED AS A BASE REGISTER, SO RESTRICT IT.       */                 02601078
      IF DATA_REMOTE THEN                                                       02601078
         R = REG_STAT(OP,TR,LOADBASE);                                          02602078
      /*-----------------------------------------------------*/                 02601078
      IF FORM(OP) = EXTSYM THEN DO;                                             04651000
         XVAL(OP) = LOC(OP);                                                    04651500
         VAL(OP) = 0;                                                           04652000
      END;                                                                      04652500
      ELSE DO;                                                                  04653000
         XVAL(OP) = DATABASE(SYT_SCOPE(LOC(OP)));                                4653500
         VAL(OP) = R_BASE(ABS(SYT_BASE(LOC(OP)))) + SYT_DISP(LOC(OP));          04655000
      END;                                                                      04655500
     IF FLAG THEN DO;                                                            4655510
      VAL(OP) = SHL(VAL(OP)+INX_CON(OP), 16) + MODIFIER;                        04656000
      XVAL(OP) = SHL(XVAL(OP), 16) + DADDR;                                     04656500
     END;                                                                        4656510
     ELSE DO;                                                                    4656520
      VAL(OP) = SHL(VAL(OP) + INX_CON(OP), 16);                                  4656530
      XVAL(OP) = SHL(XVAL(OP) + MODIFIER, 16) + DADDR;                           4656540
     END;                                                                        4656550
      INX_CON(OP) = 0;                                                          04657000
      CALL SAVE_LITERAL(OP, ADCON);                                             04657500
      IF R<0 THEN DO;                                                           04657520
         R=GET_R(OP,LOADBASE); /*#DREG*/                                        04657530
         USAGE(R)=0;                                                            04657540
      END;                                                                      04657550
      ELSE CALL CHECKPOINT_REG(R,1);                                            04657560
      CALL EMITOP(L, R, OP);                                                    04658000
      CALL UNRECOGNIZABLE(R);                                                   04658500
      IF FLAG THEN USAGE(R) = 2;                                                04659000
      REG(OP) = R;                                                              04659500
      FLAG = FALSE;                                                             04660000
   END FORCE_ADDR_LIT;                                                          04660500
                                                                                04661000
   /* ROUTINE TO MOVE A STRUCTURE BETWEEN TWO OPERANDS  */                      04661500
MOVE_STRUCTURE:                                                                 04662000
   PROCEDURE(LEFTOP, RIGHTOP, SAVE_RIGHTOP, EXTOP);                             04662500
      DECLARE (LEFTOP, RIGHTOP, EXTOP) BIT(16), SAVE_RIGHTOP BIT(1);            04663000
      DECLARE MSTRUC(1) CHARACTER INITIAL ('MSTRUC', 'MSTR');                   04663500
      DECLARE BOUNDARY(1) BIT(16), RANGE BIT(16);                                4664000
                                                                                 4664200
      /* ROUTINE TO DETERMINE UNKNOWN, HALFWORD, OR FULLWORD ALIGNMENT */        4664400
   ALIGNMENT:                                                                    4664600
      PROCEDURE(OP) BIT(16);                                                     4664800
         DECLARE OP BIT(16);                                                     4665000
         IF INX(OP) ^= 0 THEN RETURN 0;                                          4665200
         ELSE IF FORM(OP) = CSYM THEN RETURN 0;                                  4665400
         ELSE IF SYMFORM(FORM(OP)) & (SYT_FLAGS(LOC(OP))&POINTER_OR_NAME)^=0    04665410
            THEN RETURN 0;                                                      04665420
         ELSE IF BIGHTS(TYPE(OP)) > 1 THEN RETURN 2;                             4665600
         ELSE IF FORM(OP) = WORK THEN DO;                                        4665800
            IF INX_CON(OP) + DISP(OP) THEN RETURN 1;                             4666000
            ELSE RETURN 2;                                                       4666200
         END;                                                                    4666400
         ELSE IF INX_CON(OP) + SYT_DISP(LOC(OP)) +                               4666600
            R_BASE(ABS(SYT_BASE(LOC(OP)))) THEN                                  4666800
               RETURN 1;                                                         4667000
         ELSE RETURN 2;                                                          4667200
      END ALIGNMENT;                                                             4667400
                                                                                 4667600
      /* ROUTINE TO PERFORM DATA MOVES VIA LOAD/STORE SEQUENCES */               4667800
   MOVER:                                                                        4668000
      PROCEDURE(BOUNDARY, N, MORE);                                              4668200
         DECLARE (BOUNDARY, N, R) BIT(16), MORE BIT(1);                          4668400
                                                                                 4668600
      /* ROUTINE TO DO SERIES OF LOAD/STORE OPERATIONS FOR SPECIFIED DATA TYPE*/ 4668800
      LOAD_STORE:                                                                4669000
         PROCEDURE(N, TYP) BIT(16);                                              4669200
            DECLARE (N, TYP, R, LEN) BIT(16);                                    4669400
            LEN = BIGHTS(TYP);                                                   4669600
            IF N < LEN THEN RETURN N;                                            4669800
            R = FINDAC(RCLASS(TYP));                                             4670000
            DO WHILE N >= LEN;                                                   4670200
               IF FORM(RIGHTOP) = CSYM THEN                                      4670400
                  USAGE(BASE(RIGHTOP)) = USAGE(BASE(RIGHTOP)) + 2;               4670600
               CALL EMIT_BY_MODE(LOAD, R, RIGHTOP, TYP);                         4670800
               CALL EMIT_BY_MODE(STORE, R, LEFTOP, TYP);                         4671000
               INX_CON(RIGHTOP) = INX_CON(RIGHTOP) + LEN;                        4671200
               INX_CON(LEFTOP) = INX_CON(LEFTOP) + LEN;                          4671400
               N = N - LEN;                                                      4671600
            END;                                                                 4671800
            USAGE(R) = USAGE(R) - 2;                                             4672000
            IF TYP = DSCALAR THEN USAGE(R+1) = 0;                                4672200
            RETURN N;                                                            4672400
         END LOAD_STORE;                                                         4672600
                                                                                 4672800
         CALL GUARANTEE_ADDRESSABLE(RIGHTOP, LA, BY_NAME_FALSE, 2); /*CR13616*/  4673000
         IF BOUNDARY > 1 THEN DO;                                                4673200
            IF N >= BIGHTS(DSCALAR) THEN DO;                                     4673400
               R = BESTAC(DOUBLE_FACC);                                          4673600
               IF (USAGE(R) | USAGE(R+1)) < 2 THEN                               4673800
                  N = LOAD_STORE(N, DSCALAR);                                    4674000
            END;                                                                 4674200
            N = LOAD_STORE(N, DINTEGER);                                         4674400
         END;                                                                    4674600
         N = LOAD_STORE(N, INTEGER);                                             4674800
         IF N > 0 THEN CALL ERRORS(CLASS_BX, 150);                               4675000
         CALL RETURN_STACK_ENTRY(EXTOP);                                         4675200
         IF ^MORE THEN IF FORM(RIGHTOP) = CSYM THEN                              4675400
            CALL DROP_BASE(RIGHTOP);                                             4675600
         EXTOP, MORE = 0;                                                        4675800
      END MOVER;                                                                 4676000
                                                                                 4676200
      /* ROUTINE TO DO DATA MOVES VIA THE MVH INSTRUCTION */                     4676400
   USE_MVH:                                                                      4676600
      PROCEDURE;                                                                 4676800
         DECLARE TEMP BIT(16);                                                  04676810
         CALL GUARANTEE_ADDRESSABLE(LEFTOP, LA, BY_NAME_FALSE, 2); /*CR13616*/   4677000
   /*-RSJ---CR11096E---------- #DMVH --------------------------------*/         03607518
   /* USE R3 FOR DEST REGISTER WHEN DEST IS A #D VARIABLE.           */         03607518
   /* (NOT WHEN IT'S A NAME VARIABLE -- NAMES ARE DEREFERENCED, AND  */         03607518
   /*  THE NAME VARIABLE SHOULD BE POINTING TO A COMPOOL VARIABLE    */         03607518
   /*  SINCE IT'S A RESTRICTION TO POINT TO A #D VARIABLE.)          */         03607518
   /* NOTE: YOU MUST RESTORE R3 AFTER MVH WHEN IT IS NEEDED.         */         03607518
         IF DATA_REMOTE &                                                       03561001
            (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D) &                          03561001
            ^NAME_VAR(LEFTOP) THEN DO;   /* DR108621 ADDED "DO"  NLM */
   /* -DR108621  NLM ------INCORRECT USE OF R1 FOR MVH --------------*/
   /*    WITH DATA REMOTE IN EFFECT, INITIALIZE TARGET_R TO -1       */
   /*    BEFORE MAKING CALL TO GET_R TO ENSURE R3 IS RETURNED AS     */
   /*    DESTINATION REGISTER                                        */
             TARGET_R = -1;
   /* -END OF DR108621  NLM -----------------------------------------*/
             TARGET_R = GET_R(LEFTOP,LOADBASE); /*TARGET_R BECOMES R3*/         03561001
                                       /*D_R3_CHANGED IS SET TO TRUE*/
         END;        /*  ADDED FOR DR108621  NLM                     */
         ELSE                                                                   03561001
   /*----------------------------------------------------------------*/         03607518
         TARGET_R = BESTAC(FIXED_ACC);                                           4677200
         IF FORM(EXTOP) = LIT & FORM(LEFTOP) ^= CSYM & FORM(LEFTOP) ^= WORK &    4677400
            INX(LEFTOP) = 0 & SYT_BASE(LOC(LEFTOP)) ^= TEMPBASE THEN             4677600
            CALL FORCE_ADDR_LIT(TARGET_R,LEFTOP,VAL(EXTOP),1);                   4677800
         ELSE DO;                                                                4678000
            CALL FORCE_ADDRESS(TARGET_R, LEFTOP, 1);                             4678200
            IF TYPE(EXTOP)=DINTEGER THEN CALL FORCE_ACCUMULATOR(EXTOP, INTEGER); 4678400
            IF FORM(EXTOP) = LIT THEN                                            4678600
               CALL EMITP(IAL, REG(LEFTOP), 0, 0, VAL(EXTOP));                   4678800
            ELSE IF FORM(EXTOP) = VAC THEN DO;                                   4679000
               CALL EMITP(IAL, REG(LEFTOP), REG(EXTOP), 0, 0);                   4679200
               CALL DROP_REG(EXTOP);                                             4679400
            END;                                                                 4679600
            ELSE DO;                                                             4679800
               CALL DROPSAVE(EXTOP);                                             4680000
               CALL GUARANTEE_ADDRESSABLE(EXTOP, IHL);                           4680200
               CALL EMITOP(IHL, REG(LEFTOP), EXTOP);                             4680400
               CALL DROP_INX(EXTOP);                                             4680600
            END;                                                                 4680800
         END;                                                                    4681000
/*-RSJ-CR11096------------ #DMVH ---------------------------------*/            05160000
/* CLEAR MOST SIGNIFICANT BIT OF DEST REGISTER (R3) SO DSE IS USED*/            05160000
         IF REG(LEFTOP) = 3 THEN                                                05160000
            CALL EMITP(ZRB, R3, 0, 0, "8000");                                  04269500
         D_MVH_SOURCE = TRUE; /* INDICATE WE'RE SETTING UP SOURCE REG*/         04269500
                              /* SO GET_R WON'T RETURN R3 FOR IT. */            04269500
/*----------------------------------------------------------------*/            05160000
         TARGET_R = -1;                                                          4681200
/* MODIFIED DR107273 FIX TO WORK FOR NAME REMOTE DEREFERENCE:     /* CR12432 */
/* LOAD ZCON SOURCE WHEN REMOTE; AVOID STRUCT REFERENCE WHOSE     /* CR12432 */
/* LAST NAME NODE POINTS LOCAL, & NAME STRUCT INCLUDED REMOTE.    /* CR12432 */
         IF CHECK_REMOTE(RIGHTOP) & ^(NAME_VAR(RIGHTOP) &         /* CR12432 */
            ^STRUCT_WALK(RIGHTOP) & ^POINTS_REMOTE(RIGHTOP)) THEN  /* CR12432 */
            CALL FORCE_ADDRESS(-1, RIGHTOP);                                     4681600
         ELSE DO;                                                                4681800
            CALL GUARANTEE_ADDRESSABLE(RIGHTOP,LA,BY_NAME_FALSE,2); /*CR13616*/  4682000
            IF FORM(RIGHTOP) ^= CSYM & FORM(RIGHTOP) ^= WORK &                   4682200
               INX(RIGHTOP) = 0 & SYT_BASE(LOC(RIGHTOP)) ^= TEMPBASE THEN        4682400
               CALL FORCE_ADDR_LIT(-1, RIGHTOP, "5000");                         4682600
            ELSE DO;                                                             4682800
               IF KNOWN_SYM(RIGHTOP) & SYT_BASE(LOC(RIGHTOP))^=TEMPBASE THEN DO; 4683000
                  CALL FORCE_ADDRESS(PTRARG1, RIGHTOP);                         04683010
                  TEMP = DATABASE(SYT_SCOPE(LOC(RIGHTOP)));                     04683026
                   CALL EMITC(RLD, "4000" + TEMP);                              04683028
                  CALL EMITP(IAL, REG(RIGHTOP), 0, 0, 0);                        4683030
               END;                                                              4683040
               ELSE DO;                                                          4683050
                  CALL FORCE_ADDRESS(PTRARG1, RIGHTOP);                         04683060
                  CALL EMITP(IAL, REG(RIGHTOP), 0, 0, DSR);                      4683070
               END;                                                              4683080
         /*------------------------ #DMVH -------------------------*/            4681200
         /* IF SOURCE IS #D DATA THAT WAS LOADED USING LA, WE MUST */           04320078
         /* SET ITS MSB SO THAT THE DSV IS USED TO EXPAND ADDRESS. */           04330078
 /*DR107705 IF NAME_VAR, DONT SET MSB (NAME'S MSB WORKS AS IT IS)  */           04330078
 /*DR107705*/  IF DATA_REMOTE & ^NAME_VAR(RIGHTOP) &                            04350079
                  (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP) = LOCAL#D) THEN             04360078
                  CALL EMITP(OHI,REG(RIGHTOP),0,0,"8000"); /* SET MSB */        04370078
         /*--------------------------------------------------------*/            4681200
            END;                                                                 4683400
         END;                                                                    4683600
         CALL EMITRR(MVH, REG(LEFTOP), REG(RIGHTOP));                            4683800
         CALL DROP_REG(LEFTOP);                                                  4684000
         D_MVH_SOURCE = 0; /*#DMVH - RESET FLAG*/                               02440500
         CALL RETURN_STACK_ENTRY(EXTOP);                                         4684200
      END USE_MVH;                                                               4684400
                                                                                 4684600
      /* ROUTINE TO DO DATA MOVES VIA LIBRARY CALL */                            4684800
   USE_MSTRUC:                                                                   4685000
      PROCEDURE;                                                                 4685200
   /*------------------------- #DREG --------------------------------*/         04340018
         D_RTL_SETUP = TRUE;                                                    04350001
   /*----------------------------------------------------------------*/         04360018
         OPCODE, REMOTE_ADDRS = CHECK_REMOTE(RIGHTOP) | REMOTE_ADDRS;            4685400
         INTCALL = 2 + INTRINSIC(MSTRUC(OPCODE));                                4685600
         CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG1(INTCALL), RIGHTOP, 1));       4685800
         TARGET_REGISTER = FIXARG1;                                              4686000
         CALL FORCE_ACCUMULATOR(EXTOP, INTEGER);                                 4686200
         CALL STACK_TARGET(EXTOP);                                               4686400
         CALL FORCE_ADDRESS(SYSARG0(INTCALL),LEFTOP);                            4686600
         CALL DROP_PARM_STACK;                                                   4686800
         CALL GENLIBCALL(MSTRUC(OPCODE));                                        4687000
      END USE_MSTRUC;                                                            4687200
                                                                                 4687400
      /* ROUTINE TO MOVE VIA MVH IF AVAILABLE, MSTRUC OTHERWISE  */              4687600
   USE_MOVE:                                                                     4687800
      PROCEDURE;                                                                 4688000
         IF NEW_INSTRUCTIONS THEN                                                4688200
            CALL USE_MVH;                                                        4688400
         ELSE CALL USE_MSTRUC;                                                   4688600
      END USE_MOVE;                                                              4688800
                                                                                 4689000
      IF EXTOP = 0 THEN                                                          4689200
         IF SIZE(LEFTOP) ^= SIZE(RIGHTOP) THEN                                   4689400
            CALL ERRORS(CLASS_DQ,102);                                           4689600
         ELSE EXTOP = GET_INTEGER_LITERAL(SIZE(LEFTOP));                         4689800
      IF SAVE_RIGHTOP THEN                                                       4690000
         RIGHTOP = COPY_STACK_ENTRY(RIGHTOP);                                    4690200
  /* MODIFIED DR102971 FIX TO WORK FOR NAME REMOTE DEREFERENCE:  /* CR12432 */
  /* ZCON DESTINATION WHEN REMOTE; AVOID STRUCT REFERENCE WHOSE  /* CR12432 */
  /* LAST NAME NODE POINTS LOCAL, & NAME STRUCT INCLUDED REMOTE. /* CR12432 */
      REMOTE_ADDRS = CHECK_REMOTE(LEFTOP) & ^(NAME_VAR(LEFTOP) & /* CR12432 */
         ^STRUCT_WALK(LEFTOP) & ^POINTS_REMOTE(LEFTOP));         /* CR12432 */
      IF REMOTE_ADDRS THEN                                                       4690600
         CALL USE_MSTRUC;                                                        4690800
      ELSE IF FORM(EXTOP) ^= LIT THEN                                            4691000
         CALL USE_MOVE;                                                          4691200
      ELSE DO;                                                                   4691400
         RANGE = VAL(EXTOP);                                                     4691600
         CALL GUARANTEE_ADDRESSABLE(LEFTOP, LA, BY_NAME_FALSE, 2); /*CR13616*/   4691800
         BOUNDARY(0) = ALIGNMENT(LEFTOP);                                        4692200
         BOUNDARY(1) = ALIGNMENT(RIGHTOP);                                       4692400
         IF BOUNDARY(0)=0 | BOUNDARY(1)=0 | CHECK_REMOTE(RIGHTOP) THEN          04692600
            CALL USE_MOVE;                                                       4692800
         ELSE IF BOUNDARY(0) ^= BOUNDARY(1) THEN DO;                             4693000
            IF RANGE > 2 THEN                                                    4693200
               CALL USE_MOVE;                                                    4693400
            ELSE CALL MOVER(1, RANGE);                                           4693600
         END;                                                                    4693800
         ELSE IF BOUNDARY(0) THEN DO;                                            4694000
            IF RANGE > 7 THEN                                                    4694200
               CALL USE_MOVE;                                                    4694400
            ELSE DO;                                                             4694600
               CALL MOVER(1, 1, 1);                                              4694800
               CALL MOVER(2, RANGE-1);                                           4695000
            END;                                                                 4695200
         END;                                                                    4695400
         ELSE IF RANGE > 8 THEN                                                  4695600
            CALL USE_MOVE;                                                       4695800
         ELSE CALL MOVER(2, RANGE);                                              4696000
      END;                                                                       4696200
      IF SAVE_RIGHTOP THEN                                                       4707600
         CALL RETURN_STACK_ENTRY(RIGHTOP);                                       4707700
      EXTOP, SAVE_RIGHTOP, REMOTE_ADDRS = FALSE;                                04708000
   END MOVE_STRUCTURE;                                                          04716500
                                                                                05060000
/*--  DR103775 -------- #DWRITE ------------------------------------*/          05060000
 /* ROUTINE TO COPY A STRUCTURE TO TEMPORARY AREA */                            05070000
STRUC_CONVERT:                                                                  05080000
      PROCEDURE(OP) BIT(16);                                                    05090000
         DECLARE (OP, PTR) BIT(16);                                             05100000
         IF SIZE(OP) < 0 THEN                                                   05110000
            SIZE(OP) = 255;                                                     05120000
         PTR = GETFREESPACE(STRUCTURE, SIZE(OP));                               05130000
         SIZE(PTR) = SIZE(OP);                                                  05140000
         DEL(PTR) = DEL(OP);                                                    05150000
         CALL MOVE_STRUCTURE(PTR, OP);                                          05160000
         INX_CON(PTR) = 0;                                                      05170000
         CALL DROPSAVE(OP);                                                     05180000
         CALL RETURN_STACK_ENTRY(OP);                                           05190000
         RETURN PTR;                                                            05200000
      END STRUC_CONVERT;                                                        05210000
/*------------------------------------------------------------------*/          05220000
                                                                                04717000
   /* ROUTINE TO DETERMINE WHETHER A STRUCTURE NODE CONTAINS A CHARACTER */     04717500
CHARACTER_TERMINAL:                                                             04718000
   PROCEDURE BIT(1);                                                            04718500
      DECLARE (PTR, RET) BIT(16);                                               04719000
      RET = FALSE;                                                              04719500
      PTR = STRUCTURE_ADVANCE;                                                  04720000
      DO WHILE PTR > 0;                                                         04720500
         IF SYT_TYPE(PTR) = CHAR THEN                                           04721000
            IF (SYT_FLAGS(PTR) & NAME_FLAG) = 0 THEN                            04721500
               RET = TRUE;                                                      04722000
         PTR = STRUCTURE_ADVANCE;                                               04722500
      END;                                                                      04723000
      RETURN RET;                                                               04723500
   END CHARACTER_TERMINAL;                                                      04724000
                                                                                04724500
   /*  SUBROUTINE FOR HANDLING INDIRECT CALL LABELS  */                         04725000
INDIRECT:                                                                       04725500
   PROCEDURE (OP) BIT(16);                                                      04726000
      DECLARE OP BIT(16);                                                       04726500
      DO WHILE SYT_TYPE(OP) = IND_CALL_LAB;                                     04727000
         OP=SYT_PTR(OP);                                                        04727500
      END;                                                                      04728000
      RETURN OP;                                                                04728500
   END INDIRECT;                                                                04729000
                                                                                04729500
   /* SUBROUTINE FOR FINDING A STORED STATEMENT NUMBER  */                      04730000
GETLABEL:                                                                       04730500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ACCEPT PROCESS_OK FOR BFS */
   PROCEDURE(OP) BIT(16);                                                       04731000
      DECLARE (OP, PTR) BIT(16);                                                04731500
      PTR = GET_OPERAND(OP, 0, 2);                                               4732000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ACCEPT PROCESS_OK FOR BFS */
   PROCEDURE(OP, PROCESS_OK) BIT(16);
      DECLARE (OP, PTR) BIT(16), PROCESS_OK BIT(1);
      PTR = GET_OPERAND(OP, 0, BY_NAME_TRUE, 0, PROCESS_OK); /*CR13616*/
 ?/
      DO CASE TAG1 = INL;                                                       04732500
         /* EXTERNAL HAL LABEL */                                               04733000
         DO;                                                                    04733500
           IF FORM(PTR) = SYM THEN DO;                                          04734000
            LOC(PTR) = INDIRECT(LOC(PTR));                                      04734500
            VAL(PTR) = SYT_LABEL(LOC(PTR));                                     04735000
            FORM(PTR) = LBL;                                                    04735500
           END;                                                                 04738000
         END;                                                                   04738500
         /* INTERNAL FLOW NUMBER  */                                            04739000
         DO;                                                                    04739500
            PTR = GET_STACK_ENTRY;                                              04740000
            DO WHILE OP1 >= RECORD_TOP(STMTNUM);                                04740500
               NEXT_ELEMENT(STMTNUM);                                           04740600
            END;                                                                04740700
            IF LABEL_ARRAY(OP1) = 0 THEN LABEL_ARRAY(OP1) = GETSTATNO;          04741500
            VAL(PTR) = LABEL_ARRAY(OP1);                                        04742000
            LOC(PTR) = OP1;                                                     04742500
            FORM(PTR) = FLNO;                                                   04743000
         END;                                                                   04743500
      END;                                                                      04744000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; RESET PROCESS_OK FOR BFS */
      PROCESS_OK = 0;
 ?/
      RETURN PTR;                                                               04744500
   END GETLABEL;                                                                04745000
                                                                                04745500
   /* ROUTINE TO GET INTERNAL STATEMENT NUMBERS FOR INTERNALLY GENERATED LABELS 04746000
   */                                                                           04746500
GETINTLBL:                                                                      04747000
   PROCEDURE(LABEL#);                                                           04747500
      DECLARE (LABEL#, PTR) BIT(16);                                            04748000
      PTR = GET_STACK_ENTRY;                                                    04748500
       DO WHILE LABEL# >= RECORD_TOP(STMTNUM);                                  04749000
         NEXT_ELEMENT(STMTNUM);                                                 04749010
      END;                                                                      04749020
      IF LABEL_ARRAY(LABEL#) = 0 THEN LABEL_ARRAY(LABEL#) = GETSTATNO;          04750000
      VAL(PTR) = LABEL_ARRAY(LABEL#);                                           04750500
      LOC(PTR) = LABEL#;                                                        04751000
      FORM(PTR) = FLNO;                                                         04751500
      RETURN PTR;                                                               04752000
   END GETINTLBL;                                                               04752500
                                                                                04753000
   /* ROUTINE TO SET FLOW LABEL TO PRE-DETERMINED STATEMENT NUMBER */           04753500
FIX_INTLBL:                                                                     04754000
   PROCEDURE(LBL, STATNO);                                                      04754500
      DECLARE (LBL, STATNO) BIT(16);                                            04755000
      DO WHILE LBL >= RECORD_TOP(STMTNUM);                                      04755500
         NEXT_ELEMENT(STMTNUM);                                                 04755510
      END;                                                                      04755520
      IF LABEL_ARRAY(LBL) ^= 0 THEN DO;                                         04756500
         CALL SET_LABEL(STATNO);                                                04757000
         CALL EMITBFW(ALWAYS, GETINTLBL(LBL));                                  04757500
      END;                                                                      04758000
      ELSE DO;                                                                  04758500
         IF ASSEMBLER_CODE THEN                                                 04759000
            OUTPUT=HEX_LOCCTR||'P#'||STATNO||' EQU L#'||LBL;                    04759500
         LABEL_ARRAY(LBL) = STATNO;                                             04760000
      END;                                                                      04760500
   END FIX_INTLBL;                                                              04761000
                                                                                04761500
   /* PROCEDURE TO ESTABLISH THE TOTAL STORAGE REQUIRED FOR A GIVEN OPERAND */  04762000
SETUP_TOTAL_SIZE:                                                               04762500
   PROCEDURE(OP) BIT(16);                                                       04763000
      DECLARE (OP, PTR) BIT(16);                                                04763500
      TEMPSPACE = GET_ARRAYSIZE(OP);                                            04764000
      CALL SET_AREA(OP);                                                        04764500
      IF TEMPSPACE > 0 & AREASAVE > 0 THEN DO;                                  04765000
         IF TYPE(OP) ^= STRUCTURE THEN                                          04765500
            AREASAVE = AREASAVE * BIGHTS(TYPE(OP));                             04766000
         TEMPSPACE = TEMPSPACE * AREASAVE;                                      04766500
         IF TYPE(OP)=STRUCTURE THEN                                             04766510
           TEMPSPACE = TEMPSPACE-SYT_DISP(DEL(OP));                             04766520
         PTR = GET_INTEGER_LITERAL(TEMPSPACE);                                  04767000
      END;                                                                      04767500
      ELSE DO;                                                                  04768000
         PTR = FORCE_ARRAY_SIZE(TARGET_REGISTER, TEMPSPACE);                    04768500
         IF AREASAVE > 0 THEN IF TYPE(OP) ^= STRUCTURE THEN                     04769000
            AREASAVE = AREASAVE * BIGHTS(TYPE(OP));                             04769500
         CALL SUBSCRIPT_MULT(PTR, AREASAVE);                                    04770000
      END;                                                                      04770500
      RETURN PTR;                                                               04771000
   END SETUP_TOTAL_SIZE;                                                        04771500
                                                                                04772000
   /* ROUTINE TO GENERATE ARRAY TEMPORARIES FOR ARGUMENT PASSAGE. */            04772500
GEN_ARRAY_TEMP:                                                                 04773000
   PROCEDURE(OP, LTYPE, CONTEXT) BIT(16);                                       04773500
      DECLARE (OP, LTYPE, CONTEXT, PTR, ARGNO) BIT(16);                          4774000
      ARGNO = ARG_STACK_PTR + 1 - SAVE_ARG_STACK_PTR(CALL_LEVEL);               04774500
      IF CONTEXT > 0 THEN LTYPE = TYPE(OP);                                     04775000
      PTR = GET_ARRAY_TEMP(OP, LTYPE);                                           4775500
      DO CASE PACKTYPE(LTYPE);                                                  04793000
         DO;  /* VECTOR MATRIX  */                                              04793500
            IF DATATYPE(LTYPE) ^= DATATYPE(TYPE(OP)) THEN                       04794000
               CALL ERRORS(CLASS_FT,101,''||ARGNO);                             04794500
            TEMPSPACE = ROW(OP) * COLUMN(OP);                                   04795000
            CALL VECMAT_ASSIGN(PTR, OP);                                        04795500
         END;                                                                   04796000
         DO;  /* BITS  */                                                       04796500
            IF DATATYPE(LTYPE) ^= DATATYPE(TYPE(OP)) THEN                       04797000
               CALL ERRORS(CLASS_FT,101,''||ARGNO);                             04797500
            GO TO INTSCA_TEMP;                                                  04798000
         END;                                                                   04798500
         DO;  /* CHARACTER  */                                                  04799000
            IF LTYPE ^= TYPE(OP) THEN                                           04799500
               CALL ERRORS(CLASS_FT,101,''||ARGNO);                             04800000
            CALL CHAR_CALL(XXASN, PTR, OP, 0);                                  04800500
         END;                                                                   04801000
         DO;  /* INTEGER SCALAR  */                                             04801500
            IF PACKTYPE(TYPE(OP)) ^= INTSCA THEN                                04802000
               CALL ERRORS(CLASS_FT,101,''||ARGNO);                             04802500
      INTSCA_TEMP:                                                              04803000
            CALL FORCE_BY_MODE(OP, LTYPE);                                      04803500
            IF INX(PTR) < 0 THEN                           /*DR111345*/
              IF RELOAD_ADDRESSING(-1,PTR,0) THEN          /*DR111345*/
                CALL ERRORS(CLASS_BX,103);                 /*DR111345*/
            CALL EMIT_BY_MODE(STORE, REG(OP), PTR, LTYPE);                      04804000
            CALL DROP_INX(PTR);                                                 04804500
            CALL DROP_REG(OP);                                                  04805000
         END;                                                                   04805500
         DO;  /* STRUCTURE  */                                                  04806000
            IF LTYPE ^= TYPE(OP) THEN                                           04806500
               CALL ERRORS(CLASS_FT,101,''||ARGNO);                             04807000
            CALL MOVE_STRUCTURE(PTR, OP);                                       04807500
         END;                                                                   04809500
      END;                                                                      04810000
      CALL DROPSAVE(OP);                                                        04810500
      CALL RETURN_STACK_ENTRY(OP);                                              04811000
      CALL DOCLOSE;                                                             04811500
      INX_CON(PTR) = ARRCONST;                                                   4812000
      CONTEXT = 0;                                                              04812500
      RETURN PTR;                                                               04813000
   END GEN_ARRAY_TEMP;                                                          04813500
                                                                                04814000
   /* ROUTINE TO SET UP ARGUMENTS FOR NONHAL AND FILE I/O CALLS  */             04814500
SETUP_NONHAL_ARG:                                                               04815000
   PROCEDURE(OP) BIT(16);                                                       04815500
      DECLARE OP BIT(16);                                                       04816000
      IF COPY(OP) = 0 THEN DO CASE PACKTYPE(TYPE(OP));                          04816500
         DO;  /* VECTOR - MATRIX  */                                            04817000
            IF CHECK_REMOTE(OP) | DEL(OP) > 0 THEN                              04817500
               OP = VECMAT_CONVERT(OP);                                         04818000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         06910010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         06911073
            IF DATA_REMOTE & (CSECT_TYPE(LOC(OP),OP)=LOCAL#D)                   06920071
               THEN OP = VECMAT_CONVERT(OP);                                    06930000
   /*----------------------------------------------------------------*/         06940018
            INX_CON(OP) = INX_CON(OP) + BIGHTS(TYPE(OP));                       04818500
         END;                                                                   04819000
         IF COLUMN(OP)>0 | DEL(OP)^=0 | PACKFORM(FORM(OP))=2 THEN /* BITS */    04819500
            GO TO FORCE_NONHAL_TEMP;                                            04820000
         IF CHECK_REMOTE(OP) | COLUMN(OP) > 0 THEN  /* CHARACTER */             04820500
            OP = CHAR_CONVERT(OP);                                              04821000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         07030010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         07031073
         ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(OP),OP)=LOCAL#D)                 07040071
            THEN OP = CHAR_CONVERT(OP);                                         07050000
   /*----------------------------------------------------------------*/         07060018
         IF CONST(OP) ^= 0 | PACKFORM(FORM(OP)) = 2 THEN DO;  /* INT - SCALAR */04821500
      FORCE_NONHAL_TEMP:                                                        04822000
            CALL FORCE_ACCUMULATOR(OP);                                         04822500
            CALL CHECKPOINT_REG(REG(OP), TRUE);                                  4823000
         END;                                                                   04823500
         ;  /* STRUCTURE  */                                                    04824000
      END;  /* CASE PACKTYPE  */                                                04824500
      ELSE CALL TRUE_INX(OP);                                                   04825000
      RETURN OP;                                                                04825500
   END SETUP_NONHAL_ARG;                                                        04826000
                                                                                04826500
   /* ROUTINE TO SET UP CALLS TO HAL PROCEDURES AND FUNCTIONS  */               04827000
PROC_FUNC_SETUP:                                                                04827500
   PROCEDURE;                                                                   04828000
      DECLARE (ARGSTART, ARGSTOP) BIT(16),                                      04828500
              (ASSIGN_PARM, NAME_PARM, CONFLICT) BIT(1);                        04829000
                                                                                04829500
      /* ROUTINE TO SET UP AUXILIARY PARAMETERS FOR * SIZES  */                 04830000
   EMIT_SIZE_PARMS:                                                             04830500
      PROCEDURE(WHICH, REFSIZ, ADDON);                                          04831000
         DECLARE (WHICH, REFSIZ, ADDON) BIT(16);                                04831500
         TARGET_REGISTER = SYT_PARM(ARGPOINT);                                  04832000
         IF TARGET_REGISTER < 0 THEN                                            04832500
            REG(0) = FINDAC(INDEX_REG);                                         04833000
         ELSE DO;                                                               04833500
            REG(0) = TARGET_REGISTER + WHICH;                                   04834000
            CALL CHECKPOINT_REG(REG(0));                                        04834500
            USAGE(REG(0)) = 2;                                                  04835000
         END;                                                                   04835500
         IF REFSIZ < 0 THEN DO;                                                 04836000
            EXTOP = SET_ARRAY_SIZE(-REFSIZ, SHL(WHICH, 1));                     04836500
            CALL CHECK_ADDR_NEST(REG(0), EXTOP);                                04837000
            CALL EMITOP(L, REG(0), EXTOP);                                      04837500
            CALL RETURN_STACK_ENTRY(EXTOP);                                     04838000
         END;                                                                   04838500
         ELSE IF ADDON ^= 0 THEN                                                04839000
            CALL LOAD_NUM(REG(0), CS(REFSIZ+ADDON));                            04839500
         ELSE CALL LOAD_NUM(REG(0), REFSIZ);                                    04840000
         IF TARGET_REGISTER < 0 THEN DO;                                        04840500
            CALL EMITPDELTA;                                                    04841000
            CALL EMITDELTA(SHL(WHICH, 1));                                      04841500
            CALL EMITP(ST, REG(0), 0, SYM, ARGPOINT);                           04842000
            CALL DROP_REG(0);                                                    4842500
         END;                                                                   04843000
         ELSE DO;                                                               04843500
            CALL STACK_REG_PARM(REG(0), DINTEGER);                              04844000
            TARGET_REGISTER = -1;                                               04844500
         END;                                                                   04845000
         ADDON = 0;                                                             04845500
      END EMIT_SIZE_PARMS;                                                      04846000
                                                                                04846500
      /* ROUTINE TO GET ARRAYNESS OF LINEAR ARRAY PARAMETER  */                 04847000
   PARM_ARRAYNESS:                                                              04847500
      PROCEDURE BIT(16);                                                        04848000
         IF SYMFORM(FORM(RIGHTOP)) THEN                                         04848500
            IF TYPE(RIGHTOP) = STRUCTURE THEN                                   04849000
               RETURN SYT_ARRAY(LOC(RIGHTOP));                                  04849500
            ELSE RETURN GETARRAYDIM(1, LOC2(RIGHTOP));                          04850000
         RETURN SF_RANGE(VAL(RIGHTOP));                                         04850500
      END PARM_ARRAYNESS;                                                       04851000
                                                                                04851500
      ARGSTART = SAVE_ARG_STACK_PTR(CALL_LEVEL);                                04852000
      ARGSTOP = ARG_STACK_PTR - 1;                                              04852500
      IF (SYT_FLAGS(LOC2(LEFTOP)) & DEFINED_LABEL) = 0 THEN                     04853000
         CALL ERRORS(CLASS_DU,100);                                             04853500
      ARGPOINT = SYT_PTR(LOC(LEFTOP));                                          04854000
      IF ARG_STACK_PTR-ARGSTART ^= NARGS(SYT_SCOPE(LOC(LEFTOP))) THEN /*C13571*/04856500
         CALL ERRORS(CLASS_FN,102,SYT_NAME(LOC(LEFTOP)));                       04857000
      DO ARG# = ARGSTART TO ARGSTOP;                                            04857500
         ARGNO = ARG# + 1 - ARGSTART;                                           04858000
         ASSIGN_PARM = (SYT_FLAGS(ARGPOINT) & ASSIGN_FLAG) ^= 0;                04858500
         ARGTYPE = SYT_TYPE(ARGPOINT);                                          04859000
         RIGHTOP = ARG_STACK(ARG#);                                             04859500
         IF ASSIGN_PARM ^= ARG_TYPE(ARG#) THEN                                  04860000
            CALL ERRORS(CLASS_FT,105);                                          04860500
         NAME_PARM = (SYT_FLAGS(ARGPOINT) & NAME_FLAG) ^= 0;                    04861000
         IF NAME_PARM ^= ARG_NAME(ARG#) THEN                                    04861500
            CALL ERRORS(CLASS_FT,106);                                          04862000
         DO CASE ASSIGN_PARM;                                                   04862500
            DO;  /* INPUT PARM */                                               04863000
               IF NAME_PARM THEN DO;                                            04863500
                  CALL CHECK_NAME_PARM(0);                                      04864000
   /*DR111347,CR13538-CHECK FOR REMOTE ARG PASSED TO NON-REMOTE PARAMETER*/
   /*DR111347*/   IF ((SYT_FLAGS(ARGPOINT)&REMOTE_FLAG)=0) &    /*CR13538*/
   /*DR111347*/      (POINTS_REMOTE(RIGHTOP) |
   /*DR111347*/      (LIVES_REMOTE(RIGHTOP) & ^NAME_VAR(RIGHTOP))) THEN
   /*DR111347*/      CALL ERRORS(CLASS_FT,113);
               END;                                                             04864500
               ELSE IF ARGTYPE = STRUCTURE THEN DO;                             04865000
                  CALL CHECK_STRUCTURE_PARM(0);                                 04865500
                  CALL DROPSAVE(RIGHTOP);                                       04866000
               END;                                                             04866500
               ELSE IF SYT_ARRAY(ARGPOINT) ^= 0 THEN DO;                        04867000
                  CALL CHECK_ASSIGN_PARM(0);                                    04867500
                  CALL DROPSAVE(RIGHTOP);                                       04868000
               END;                                                             04868500
               ELSE DO;                                                         04869000
                  IF COPY(RIGHTOP) ^= 0 THEN                                    04869500
                     CALL ERRORS(CLASS_FD,100);                                 04870000
                  IF FORM(RIGHTOP) = LIT THEN                                   04870500
 /*DR120223*/      IF (PACKTYPE(ARGTYPE)&PACKTYPE(TYPE(RIGHTOP)))=INTSCA THEN   04870600
                     CALL LITERAL(LOC(RIGHTOP), ARGTYPE, RIGHTOP);              04871000
                  DO CASE PACKTYPE(ARGTYPE);                                    04871500
                     DO;  /* VECTOR - MATRIX */                                 04872000
                        IF DATATYPE(ARGTYPE) ^= DATATYPE(TYPE(RIGHTOP)) THEN    04872500
                           CALL ERRORS(CLASS_FT,101,''||ARGNO);                 04873000
                        CALL CHECK_VM_ARG_DIMS;                                 04873500
                        CONFLICT = TYPE(RIGHTOP) ^= ARGTYPE;                    04874000
                        IF CONFLICT | CHECK_REMOTE(RIGHTOP)|DEL(RIGHTOP)>0 THEN 04874500
                           RIGHTOP = VECMAT_CONVERT(RIGHTOP,ARGTYPE&8|CONFLICT);04875000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO PROC ---*/         08340010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         08350073
                        IF DATA_REMOTE &                                        08360071
                           (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)           08370071
                           THEN RIGHTOP = VECMAT_CONVERT(RIGHTOP);              08380000
   /*----------------------------------------------------------------*/         08390018
                        CALL DROPSAVE(RIGHTOP);                                 04875500
                     END;                                                       04876000
                     DO;  /* BITS */                                            04876500
                        IF DATATYPE(ARGTYPE) ^= DATATYPE(TYPE(RIGHTOP)) THEN    04877000
                           CALL ERRORS(CLASS_FT,101,''||ARGNO);                 04877500
                        IF SYT_DIMS(ARGPOINT) ^= SIZE(RIGHTOP) THEN /*CR13211*/
                           CALL ERRORS(CLASS_YF,103);               /*CR13211*/
   /*DR120221*/         IF FORM(RIGHTOP)=LIT & BIT_PICK(RIGHTOP)=0 THEN
   /*DR120221*/            IF SIZE(RIGHTOP) > SYT_DIMS(ARGPOINT) THEN DO;
   /*DR120221*/                VAL(RIGHTOP) = VAL(RIGHTOP)
   /*DR120221*/                               & XITAB(SYT_DIMS(ARGPOINT));
   /*DR120221*/                SIZE(RIGHTOP) = SYT_DIMS(ARGPOINT);
   /*DR120221*/                LOC(RIGHTOP) = -1;
   /*DR120221*/            END;
                     END;                                                       04878000
                     DO;  /* CHARACTER  */                                      04878500
                       IF PACKTYPE(TYPE(RIGHTOP))<2|TYPE(RIGHTOP)=STRUCTURE THEN04879000
                           CALL ERRORS(CLASS_FT,101,''||ARGNO);                 04879500
                        IF TYPE(RIGHTOP) ^= ARGTYPE THEN                        04880000
                           RIGHTOP = NTOC(RIGHTOP);                             04880500
                        ELSE IF CHECK_REMOTE(RIGHTOP) | COLUMN(RIGHTOP) > 0 THEN04881000
                           RIGHTOP = CHAR_CONVERT(RIGHTOP);                     04881500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO PROC ---*/         08580010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         08590073
                       IF DATA_REMOTE &                                         08600071
                          (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)            08610071
                          THEN RIGHTOP = CHAR_CONVERT(RIGHTOP);                 08620000
   /*----------------------------------------------------------------*/         08630018
                        CALL DROPSAVE(RIGHTOP);                                 04882000
                     END;                                                       04882500
                     DO;  /* INTEGER - SCALAR  */                               04883000
                        IF PACKTYPE(TYPE(RIGHTOP)) ^= INTSCA THEN               04883500
                           CALL ERRORS(CLASS_FT,101,''||ARGNO);                 04884000
                        IF DATATYPE(TYPE(RIGHTOP)) ^= DATATYPE(ARGTYPE) THEN    04884500
                           CALL FORCE_BY_MODE(RIGHTOP, ARGTYPE);                04885000
                     END;                                                       04885500
                  END;  /* CASE PACKTYPE  */                                    04886000
               END;                                                             04886500
            END;  /* INPUT CASE  */                                             04887000
            IF NAME_PARM THEN                                                   04887500
               CALL CHECK_NAME_PARM(1);                                         04888000
            ELSE IF ARGTYPE = STRUCTURE THEN CALL CHECK_STRUCTURE_PARM(1);      04888500
            ELSE CALL CHECK_ASSIGN_PARM(1);                                     04889000
         END;  /* CASE ASSIGN_PARM */                                           04889500
         ARG_STACK(ARG#) = RIGHTOP;                                             04890000
         ARGPOINT = ARGPOINT + 1;                                               04890500
      END;  /* DO ARG#  */                                                      04891000
      ARGPOINT = SYT_PTR(LOC(LEFTOP)) + ARGSTOP - ARGSTART;                     04891500
      ARG# = ARGSTOP;                                                           04892000
      DO WHILE ARG# >= ARGSTART;                                                04892500
         ARGTYPE = SYT_TYPE(ARGPOINT);                                          04893000
         RIGHTOP = ARG_STACK(ARG#);                                             04893500
         TARGET_REGISTER = SYT_PARM(ARGPOINT);                                  04894000
         IF (SYT_FLAGS(ARGPOINT) & POINTER_FLAG) ^= 0 THEN DO;                  04894500
            /* FT108 ERROR NO LONGER EMITTED FOR REMOTE PASS-BY-REF CR12935*/
            /* PARAMETERS. REDEFINE FT112 ERROR TO RESTRICT PASSING CR12935*/
            /* NAME(NAMEVAR) BY-REF IF NAMEVAR LIVES REMOTE. THIS   CR12935*/
            /* IS BECAUSE REMOTE ON NAME MEANS POINTS REMOTE; NO    CR12935*/
            /* CURRENT WAY TO DECLARE FORMAL PARAMETER AS BOTH      CR12935*/
            /* LIVING AND POINTING REMOTE.                          CR12935*/
            IF ((SYT_FLAGS(ARGPOINT) & ASSIGN_OR_NAME)            /*CR12935*/
                  = ASSIGN_OR_NAME) &                        /*CR12935,111393*/
 /*DR111390*/     NAME_FUNCTION(RIGHTOP) THEN DO;            /*CR12935,111393*/
               /* IF PASSING THE NODE OF A NAME STRUCTURE THEN THE /*DR111393*/
               /* VARIABLE LIVES_REMOTE SHOULD ONLY BE CHECKED TO  /*DR111393*/
               /* DETERMINE IF THE NAME LIVES REMOTELY.            /*DR111393*/
               IF (SYT_TYPE(LOC(RIGHTOP)) = STRUCTURE) &           /*DR111393*/
                  ((SYT_FLAGS(LOC(RIGHTOP)) & NAME_FLAG) ^= 0) &   /*DR111393*/
                  ^MAJOR_STRUCTURE(RIGHTOP) THEN DO;               /*DR111393*/
                 IF LIVES_REMOTE(RIGHTOP) THEN                     /*DR111393*/
                   CALL ERRORS(CLASS_FT, 112, ''||ARG#+1-ARGSTART); /*CR12935*/
               END;                                                /*DR111393*/
               /* OTHERWISE, IN ADDITION TO CHECKING THE           /*DR111393*/
               /* LIVES_REMOTE VALUE, CHECK IF THE NAME VARIABLE   /*DR111393*/
               /* LIVES IN THE REMOTE #D CSECT OR IF IT WAS        /*DR111393*/
               /* DECLARED IN A REMOTELY INCLUDED COMPOOL.         /*DR111393*/
               ELSE IF LIVES_REMOTE(RIGHTOP) | (DATA_REMOTE &      /*DR111393*/
                 (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)) |     /*DR111393*/
                 (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=INCREM#P)       /*DR111393*/
               THEN CALL ERRORS(CLASS_FT, 112, ''||ARG#+1-ARGSTART); /*111393*/
            END;                                                   /*DR111393*/
            /* INDICATE THAT WE'RE PASSING A PARAMETER SO THAT      CR12935*/
            /* FORCE_ADDRESS WILL KNOW TO HANDLE REMOTE #D ADDR.    CR12935*/
            D_RTL_SETUP = 3;                             /*CR13538, CR12935*/
            /* CR13538-FORCE A YCON->ZCON CONVERSION IF PASSING A          */
            /* NON-REMOTE ARGUMENT BY REFERENCE INTO A REMOTE PARAMETER.   */
            /* REMOTE_ADDRS IS FALSE FOR NAME ASSIGN PARAMETERS.           */
            REMOTE_ADDRS = ((SYT_FLAGS(ARGPOINT)&REMOTE_FLAG)^=0)&/*CR13538*/
               ((SYT_FLAGS(ARGPOINT)&ASSIGN_OR_NAME)^=ASSIGN_OR_NAME);/*538*/
            CALL FORCE_ADDRESS(TARGET_REGISTER, RIGHTOP, 1, ARG_NAME(ARG#),     04895000
                      (SYT_FLAGS(ARGPOINT) & ASSIGN_OR_NAME) = ASSIGN_OR_NAME); 04895500
            IF (SYT_FLAGS(ARGPOINT) & NAME_FLAG) ^= 0 THEN                      04896000
            DO;                                                   /*DR111346*/
               IF ((SYT_FLAGS(ARGPOINT) & REMOTE_FLAG) ^= 0) &    /*DR111346*/
                  ((SYT_FLAGS(ARGPOINT) & ASSIGN_FLAG)  = 0) THEN /*DR111346*/
                  ARGTYPE = RPOINTER;                             /*DR111346*/
               ELSE                                               /*DR111346*/
               ARGTYPE = APOINTER;                                               4896500
            END;                                                  /*DR111346*/
            ELSE ARGTYPE = DINTEGER;                                            04897000
         END;                                                                   04897500
         ELSE CALL FORCE_BY_MODE(RIGHTOP, ARGTYPE);                             04898000
         D_RTL_SETUP = FALSE;                                     /*CR12935*/
         REMOTE_ADDRS = FALSE;                                    /*CR13538*/
         IF DATATYPE(SYT_TYPE(ARGPOINT)) = BITS THEN              /*DR120221*/
            IF SIZE(RIGHTOP) > (SYT_DIMS(ARGPOINT)&"FF") THEN     /*DR120221*/
               CALL BIT_MASK(AND,RIGHTOP,SYT_DIMS(ARGPOINT)&"FF");/*DR120221*/
         IF TARGET_REGISTER < 0 THEN DO;                                        04898500
            CALL EMITPDELTA;                                                    04899000
            CALL EMITP(MAKE_INST(STORE,ARGTYPE,RX),REG(RIGHTOP),0,SYM,ARGPOINT);04899500
            CALL DROP_REG(RIGHTOP);                                             04900500
         END;                                                                   04901000
         ELSE DO;                                                               04901500
            CALL STACK_REG_PARM(TARGET_REGISTER, ARGTYPE);                      04902000
            TARGET_REGISTER = -1;                                               04902500
         END;                                                                   04903000
         IF SYT_TYPE(ARGPOINT) = CHAR THEN                                      04903500
            IF SYT_DIMS(ARGPOINT) < 0 & SYT_ARRAY(ARGPOINT) > 0 THEN            04904000
               CALL EMIT_SIZE_PARMS(1, SIZE(RIGHTOP), 2);                       04904500
         IF SYT_ARRAY(ARGPOINT) ^= 0 THEN                                       04905000
            IF GETARRAYDIM(1, ARGPOINT) < 0 THEN                                04905500
               CALL EMIT_SIZE_PARMS(SYT_LEVEL(ARGPOINT), PARM_ARRAYNESS);       04906000
         IF ^ARG_TYPE(ARG#) THEN                                                04906500
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   04907000
         ARGPOINT = ARGPOINT - 1;                                               04907500
         ARG# = ARG# - 1;                                                       04908000
      END;                                                                      04908500
      ARGPOINT = SYT_PTR(LOC(LEFTOP));                                          04909000
      DO ARG# = ARGSTART TO ARGSTOP;                                            04909500
         IF ARG_TYPE(ARG#) THEN DO;                                             04910000
            RIGHTOP = ARG_STACK(ARG#);                                          04910500
            CALL NEW_USAGE(RIGHTOP, 1, ARG_NAME(ARG#));                         04911500
            CALL RETURN_COLUMN_STACK(RIGHTOP);   /*DR109059*/
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   04912000
         END;                                                                   04912500
         ARGPOINT = ARGPOINT + 1;                                               04913000
      END;                                                                      04913500
      CALL DROP_PARM_STACK;                                                     04914000
   END PROC_FUNC_SETUP;                                                         04914500
                                                                                04915000
   /* ROUTINE TO GENERATE CALL TO ALL HAL PROC/FUNC/PROG  */                    04915500
PROC_FUNC_CALL:                                                                 04916000
   PROCEDURE(OP);                                                               04916500
      DECLARE (OP, SCOPE, MAXARG) BIT(16);                                      04917000
      SCOPE = SYT_SCOPE(LOC(OP));                                               04919000
      IF NOT_LEAF(SCOPE) THEN MAXARG = FIXARG1;                                 04919500
      ELSE MAXARG = FIXARG3;                                                    04920000
      CALL SAVE_REGS(MAXARG, 1);                                                04920500
      CALL EMIT_CALL(SCOPE, ^NOT_LEAF(SCOPE));                                  04921000
      CALL CLEAR_CALL_REGS(MAXARG, ^NOT_LEAF(SCOPE));                           04921500
      CALL CLEAR_SCOPED_REGS(SYT_NEST(LOC(OP)), LOC(OP));                       04927000
      CALL RETURN_STACK_ENTRY(OP);                                              04927500
      LASTRESULT = 0;                                                           04928000
   END PROC_FUNC_CALL;                                                          04928500
                                                                                04929000
   /* ROUTINE TO EMIT REPEAT HEADS FOR SHAPING FUNCTIONS  */                    04929500
BEGIN_SF_REPEAT:                                                                04930000
   PROCEDURE(CT, FLAG, START);                                                  04930500
      DECLARE (CT, START) BIT(16), FLAG BIT(1);                                 04930510
      IF CT <= 1 THEN DO; FLAG = FALSE; RETURN; END;                            04931500
      IF ^FLAG THEN CALL SAVE_REGS(RM, 3);                                      04932000
      LEFTOP = GET_VAC(-1);                                                     04932500
      INX(RESULT) = REG(LEFTOP);                                                04933000
      INDEX = GET_VAC(-1);                                                      04933500
      CALL LOAD_NUM(INX(RESULT), START);                                        04934000
      USAGE(INX(RESULT)) = 4;                                                   04934500
      INX_NEXT_USE(RESULT) = 1;                                                  4934600
      CALL LOAD_NUM(REG(INDEX), CT, 1);                                         04935000
      VAL(INDEX) = REG(INDEX);                                                  04935500
      XVAL(INDEX) = INX(RESULT);                                                04936000
      FIRSTLABEL = GETSTATNO;                                                   04936500
      CALL SET_LABEL(FIRSTLABEL, 1);                                            04937500
      START, FLAG = 0;                                                          04938000
   END BEGIN_SF_REPEAT;                                                         04938500
                                                                                04939000
   /* ROUEINT TO EMIT REPEAT TAILS FOR SHAPING FUNCTIONS  */                    04939500
END_SF_REPEAT:                                                                  04940000
   PROCEDURE(CT);                                                               04940500
      DECLARE CT BIT(16);                                                       04941000
      IF CT <= 1 THEN RETURN;                                                   04941500
      CALL CHECK_VAC(LEFTOP, XVAL(INDEX));                                      04942000
      CALL CHECK_VAC(INDEX, VAL(INDEX));                                        04942500
      IF SELF_ALIGNING THEN                                                     04943000
         CALL EMITP(AHI, REG(LEFTOP), 0, 0, AREA/SF_DISP);                      04943500
      ELSE CALL EMITP(AHI, REG(LEFTOP), 0, 0, AREA);                            04944000
      CALL EMITPFW(BCT, REG(INDEX), GETSTMTLBL(FIRSTLABEL));                    04944500
      CALL DROP_VAC(INDEX);                                                     04945000
      CALL DROP_VAC(LEFTOP);                                                    04945500
      INX(RESULT) = 0;                                                          04946500
   END END_SF_REPEAT;                                                           04947000
                                                                                04947500
   /* ROUTINE TO EMIT CALLS TO OUT OF LINE SHAPING FUNCTIONS  */                04948000
SHAPING_CALL:                                                                   04948500
   PROCEDURE(OP);                                                               04949000
      DECLARE (OP, SIZOP, SF_FLAG) BIT(16), CHAROP BIT(1),                      04949500
              NAME(1) CHARACTER INITIAL ('QSHAPQ', 'CSHAPQ');                   04950000
   /*------------------------- #DREG --------------------------------*/         04340018
      D_RTL_SETUP = TRUE;                                                       04350001
   /*----------------------------------------------------------------*/         04360018
      CHAROP = TYPE(OP) = CHAR;                                                 04950500
      CALL TRUE_INX(OP);                                                        04951000
      INTCALL = 2 + INTRINSIC(NAME(CHAROP));                                    04951500
      CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG1(INTCALL), OP, 1));              04952500
      CALL FORCE_ADDRESS(SYSARG0(INTCALL), RESULT);                             04953000
      COPY(0) = GET_ARRAYSIZE(OP);                                              04953500
      CALL SET_AREA(OP);                                                        04954000
      IF CHAROP THEN DO;                                                        04954500
         IF AREASAVE > 0 THEN                                                   04955000
            CALL FORCE_NUM(FIXARG3, AREASAVE);                                  04955500
         ELSE DO;                                                               04956000
            CALL CHECKPOINT_REG(FIXARG3);                                       04956500
            SIZOP = SET_ARRAY_SIZE(-AREASAVE, 2);                               04957000
            CALL CHECK_ADDR_NEST(FIXARG3, SIZOP);                               04957500
            CALL EMITOP(L, FIXARG3, SIZOP);                                     04958000
            CALL RETURN_STACK_ENTRY(SIZOP);                                     04958500
         END;                                                                   04959000
         AREASAVE = 1;                                                          04959500
         SF_FLAG = OPMODE(OPTYPE)-1;                                            04960000
      END;                                                                      04960500
      ELSE DO;                                                                  04961000
         SF_FLAG = SHL(OPMODE(TYPE(OP))-1, 8) + OPMODE(OPTYPE)-1;               04961500
      END;                                                                      04962000
      CALL FORCE_NUM(FIXARG2, SF_FLAG);                                         04962500
      CALL FORCE_NUM(FIXARG1, COPY(0) * AREASAVE);                              04963000
      CALL DROP_PARM_STACK;                                                     04963500
      CALL GENLIBCALL(NAME(CHAROP));                                            04964000
      AREA = COPY(0) * AREASAVE * SF_DISP;                                      04964500
      LASTRESULT = 0;                                                           04964600
   END SHAPING_CALL;                                                            04965000
                                                                                04965500
   /* ROUTINE TO PROCESS SHAPING FUNCTION ARGUMENTS  */                         04966000
SHAPING_FUNCTIONS:                                                              04966500
   PROCEDURE(ARG);                                                              04967000
      DECLARE (ARG, REPETITION, LDTYPE) BIT(16);                                 4967500
      RIGHTOP = ARG_STACK(ARG);                                                 04968000
      REPETITION = ARG_TYPE(ARG);                                                4968500
      IF FORM(RIGHTOP) = LIT THEN                                               04969000
         IF PACKTYPE(TYPE(RIGHTOP)) = INTSCA THEN                               04969500
            CALL LITERAL(LOC(RIGHTOP), OPTYPE, RIGHTOP);                        04970000
      IF COPY(RIGHTOP) = 0 THEN DO;                                             04970500
         DO CASE PACKTYPE(TYPE(RIGHTOP));                                       04971000
            IF DATATYPE(OPTYPE) ^= INTEGER THEN                                 04971500
               DO;                                                              04972000
                  AREA, TEMPSPACE = ROW(RIGHTOP) * COLUMN(RIGHTOP);             04972500
                  CALL BEGIN_SF_REPEAT(REPETITION);                              4973000
                  INX_CON(RESULT) = INX_CON(RESULT) - SF_DISP;                  04973500
                  CALL VECMAT_ASSIGN(RESULT, RIGHTOP);                          04974000
                  INX_CON(RESULT) = INX_CON(RESULT) + SF_DISP;                  04974500
                  AREA = AREA * SF_DISP;                                        04975000
               END;                                                             04975500
            ELSE                                                                04976000
               DO;                                                              04976500
                  IF CHECK_REMOTE(RIGHTOP) | DEL(RIGHTOP) > 0 THEN              04977000
                     RIGHTOP = VECMAT_CONVERT(RIGHTOP);                         04977500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO PROC ---*/         10550010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         10560073
                  IF DATA_REMOTE & (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)   10570071
                    THEN RIGHTOP = VECMAT_CONVERT(RIGHTOP);                     10580000
   /*----------------------------------------------------------------*/         10590018
                  CALL BEGIN_SF_REPEAT(REPETITION);                              4978000
                  CALL SHAPING_CALL(RIGHTOP);                                   04978500
               END;                                                             04979000
            GO TO DO_ISSHP;                                                     04979500
            DO;                                                                 04980000
               RIGHTOP = CTON(RIGHTOP, OPTYPE);                                 04980500
               GO TO DO_ISSHPS;                                                 04981000
            END;                                                                04981500
            DO;                                                                 04982000
         DO_ISSHP:                                                              04982500
               IF PACKTYPE(OPTYPE) = VECMAT THEN LDTYPE = OPTYPE&8 | SCALAR;    04983000
               ELSE LDTYPE = OPTYPE;                                            04983500
               CALL FORCE_BY_MODE(RIGHTOP, LDTYPE);                             04984000
         DO_ISSHPS:                                                             04984500
               IF REPETITION > 4 THEN DO;                                        4985000
                  CALL BEGIN_SF_REPEAT(REPETITION, 1);                           4985500
                  CALL EMIT_BY_MODE(STORE, REG(RIGHTOP), RESULT, OPTYPE);       04986000
                  CALL DROP_INX(RESULT);                                        04986500
               END;                                                             04987000
               ELSE DO;                                                         04987500
                  DO OP2 = 1 TO REPETITION;                                      4988000
                     CALL EMIT_BY_MODE(STORE, REG(RIGHTOP), RESULT, OPTYPE);    04988500
                     INX_CON(RESULT) = INX_CON(RESULT) + SF_DISP;               04989000
                  END;                                                          04989500
                  REPETITION = 0;                                                4990000
               END;                                                             04990500
               CALL DROP_REG(RIGHTOP);                                          04991000
               AREA = SF_DISP;                                                  04991500
            END;                                                                04992000
         END;  /* CASE PACKTYPE  */                                             04992500
         CALL END_SF_REPEAT(REPETITION);                                         4993000
      END;  /* NON ARRAYED  */                                                  04993500
      ELSE DO;  /* ARRAYED  */                                                  04994000
         CALL BEGIN_SF_REPEAT(REPETITION);                                       4994500
         CALL SHAPING_CALL(RIGHTOP);                                            04995000
         CALL END_SF_REPEAT(REPETITION);                                         4995500
      END;                                                                      04996000
      INX_CON(RESULT) = AREA * REPETITION + INX_CON(RESULT);                     4996500
      CALL DROPSAVE(RIGHTOP);                                                   04997000
      CALL RETURN_STACK_ENTRY(RIGHTOP);                                         04997500
   END SHAPING_FUNCTIONS;                                                       04998000
                                                                                04998500
   /* ROUTINE TO SET UP ARGUMENT LIST FOR NONHAL CALL  */                       04999000
NONHAL_PROC_FUNC_SETUP:                                                         04999500
   PROCEDURE;                                                                   05000000
      ;                                                                         05000500
   END NONHAL_PROC_FUNC_SETUP;                                                  05014500
                                                                                05015000
   /* ROUTINE TO ISSUE CALL TO NONHAL PROC/FUNC  */                             05015500
NONHAL_PROC_FUNC_CALL:                                                          05016000
   PROCEDURE;                                                                   05016500
      GO TO UNIMPLEMENTED;                                                      05017500
   END NONHAL_PROC_FUNC_CALL;                                                   05026000
                                                                                05026500
   /* ROUTINE TO SET UP IMPLIED INITIALIZATION FOR AUTOMATIC VARIABLES */       05027000
SET_AUTO_IMPLIED:                                                               05027500
   PROCEDURE(CPTR);                                        /*DR107694*/         05028000
      DECLARE (CPTR, SPTR, I, J) BIT(16);                                       05028500
      DECLARE K BIT(16);                                   /*DR107694*/         05028600
                                                                                05029000
      /* INTERNAL ROUTINE TO SET MAX CHAR BYTES FOR AUTOMATIC STRINGS */        05029500
   SET_AUTO_CHAR_MAX:                                                           05030000
      PROCEDURE(PTR1, PTR2, CON);                                               05030500
         DECLARE (PTR1, PTR2) BIT(16), CON FIXED;                               05031000
         RESULT = SET_OPERAND(PTR1);                                            05031500
         SIZE(RESULT) = SYT_DIMS(PTR2);                                         05032000
         INX_CON(RESULT) = CON;                                                 05032500
         J = FINDAC(FIXED_ACC);                                                 05033000
         CALL LOAD_NUM(J, SHL(SIZE(RESULT), 8));                                05033500
         I = LUMP_ARRAYSIZE(PTR2);                                              05034000
         IF I > 1 THEN DO;                                                      05034500
            CALL FORCE_ADDRESS(-1, RESULT, 1);                                  05035000
            INDEX = FINDAC(INDEX_REG);                                          05035500
            BASE(RESULT) = REG(RESULT);                                         05036000
            DISP(RESULT), INX_CON(RESULT) = 0;                                  05036500
            FORM(RESULT) = CSYM;                                                05037000
            CALL LOAD_NUM(INDEX, I, 1);                                         05037500
            FIRSTLABEL = GETSTATNO;                                             05038000
            CALL SET_LABEL(FIRSTLABEL, 1);                                      05038500
            CALL EMITOP(STH, J, RESULT);                                        05039000
            CALL EMITP(AHI, BASE(RESULT), 0, 0, CS(SIZE(RESULT) + 2));          05039500
            CALL EMITPFW(BCT, INDEX, GETSTMTLBL(FIRSTLABEL));                   05040000
            USAGE(INDEX), USAGE(REG(RESULT)) = 0;                               05040500
         END;                                                                   05041000
         ELSE DO;                                                               05041500
            CALL GUARANTEE_ADDRESSABLE(RESULT, STH);                            05042000
            CALL EMITOP(STH, J, RESULT);                                        05042500
         END;                                                                   05043000
         USAGE(J) = USAGE(J) - 2;                                               05043500
         CALL RETURN_STACK_ENTRY(RESULT);                                       05044000
      END SET_AUTO_CHAR_MAX;                                                    05044500
                                                                                05045000
      /* LOCAL ROUTINE TO AUTOMATICALLY SET NAMES NULL  */                      05045500
   SET_AUTO_NAME_NULL:                                                          05046000
      PROCEDURE(PTR1, PTR2, CON);                                               05046500
         DECLARE (PTR1, PTR2) BIT(16), CON FIXED;                               05047000
         RESULT = SET_OPERAND(PTR1);                                            05047500
         INX_CON(RESULT) = CON;                                                 05048000
         IF (SYT_FLAGS(PTR2) & REMOTE_FLAG) ^= 0 THEN I = ST;                    5048100
         ELSE I = STH;                                                           5048200
         PTR2 = GET_INTEGER_LITERAL(NULL_ADDR);                                 05048500
         CALL FORCE_ACCUMULATOR(PTR2, DINTEGER, INDEX_REG);                     05049000
         CALL GUARANTEE_ADDRESSABLE(RESULT, I, BY_NAME_TRUE); /*CR13616*/        5049500
         CALL EMITOP(I, REG(PTR2), RESULT);                                      5050000
         CALL DROP_REG(PTR2);                                                    5050500
         CALL RETURN_STACK_ENTRIES(RESULT, PTR2);                               05051000
      END SET_AUTO_NAME_NULL;                                                   05051500
                                                                                05051510
      /* LOCAL ROUTINE TO ZERO TEMPORARY BIT STRINGS */                         05051520
   SET_TEMP_BITS_ZERO:                                                          05051530
      PROCEDURE (PTR1, PTR2, CON);                                              05051540
      DECLARE (PTR1, PTR2, OP) BIT(16), HW BIT(8), CON FIXED;                   05051550
      /* LASTLOC TO MAKE SURE REDUNDANT ZH INSTR. ARE NOT GENERATED */
      DECLARE LASTLOC BIT(16) INITIAL(0);                   /*DR107694*/
      DECLARE LASTADDR BIT(16) INITIAL(0);                  /*DR110232*/
                                                                                05051560
      RESULT = SET_OPERAND(PTR1);                                               05051570
      HW = SYT_TYPE(PTR2) = BITS;                                               05051580
      INX_CON(RESULT) = CON;                                                    05051590
      IF HW THEN DO;                                                            05051600
         OP = ZH;                                                               05051610
         K = 0;                                                                 05051620
      END;                                                                      05051630
      ELSE DO;                                                                  05051640
         OP = ST;                                                               05051650
         K = LOAD_NUM(-1,0,8);                                                  05051660
      END;                                                                      05051670
      I = LUMP_ARRAYSIZE(PTR2);                                                 05051680
      CALL GUARANTEE_ADDRESSABLE(RESULT, OP);                                   05051690
      IF I>1 THEN DO;                                                           05051700
         INDEX = FINDAC(INDEX_REG);                                             05051710
         INX(RESULT) = INDEX;                                                   05051720
         CALL LOAD_NUM(INDEX, I-1, 9);                                          05051730
         FIRSTLABEL = GETSTATNO;                                                05051740
         CALL SET_LABEL(FIRSTLABEL, 1);                                         05051750
         CALL EMITOP(OP,K,RESULT);                                                 05051
         CALL EMITPFW(BIX, INDEX, GETSTMTLBL(FIRSTLABEL));                      05051780
         USAGE(INDEX) = 0;                                                      05051790
      END;                                                                      05051800
      ELSE DO;                                                                  05051810
         /* THE FOLLOWING CODE ADDED FOR DR107694 KEEPS */
         /*   THE COMPILER FROM ISSUING MULTIPLE ZH/ST  */
         /*   INSTRUCTIONS TO INITIALIZE THE SAME       */
         /*   HALFWORD WHICH MIGHT BE STORING MULTIPLE  */
         /*   BIT VARIABLES.                            */
         /* DR109037 -- KEEP TRACK OF LOC(RESULT)+CON IN LASTLOC.    */
         /* DR110232 -- CHANGED HOW LASTLOC IS TRACKED. IT NOW KEEPS */
         /* TRACK OF LOC(RESULT), NOT LOC(RESULT)+CON. ALSO ADDED    */
         /* CODE TO KEEP TRACK OF THE STACK ADDRESS IN LASTADDR.     */
         /* KEEPING TRACK OF SYMBOL TABLE # AND STACK ADDRESS INFO   */
         /* IS NECESSARY SO WHEN TWO DO GROUPS CONTAIN BIT A VARIABLE*/
         /* LOCATED IN THE SAME STACK ADDRESS, THE BIT VARAIBLE IN   */
         /* THE SECOND DO GROUP WILL GET INITIALIZED.                */
         IF ( (LASTADDR ^= SYT_ADDR(LOC(RESULT))+CON) |  /* DR110232 */
              (LASTLOC ^= LOC(RESULT)) ) THEN DO;        /* DR110232 */
            LASTADDR = SYT_ADDR(LOC(RESULT))+CON;        /* DR110232 */
            LASTLOC  = LOC(RESULT);                      /* DR110232 */
            CALL EMITOP(OP, K, RESULT);                                          0505181
         END;                                            /* DR110232 */
      END;                                     /*DR107694*/
      IF ^HW THEN USAGE(K) = USAGE(K) - 2;                                      05051820
      CALL RETURN_STACK_ENTRY(RESULT);                                          05051830
   END SET_TEMP_BITS_ZERO;                                                      05051840
                                                                                05052000
      IF (SYT_FLAGS(CPTR) & NAME_FLAG) ^= 0 THEN                                05052500
         CALL SET_AUTO_NAME_NULL(CPTR, CPTR, 0);                                05053000
      ELSE IF SYT_TYPE(CPTR) = CHAR THEN                                        05053500
         CALL SET_AUTO_CHAR_MAX(CPTR, CPTR, -SYT_CONST(CPTR));                  05054000
      ELSE IF SYT_TYPE(CPTR) = STRUCTURE THEN DO;                               05054500
         STRUCT_TEMPL = SYT_DIMS(CPTR);                                         05055000
         STRUCT_MOD, STRUCT_REF, J = 0;                                         05055500
         SPTR = STRUCTURE_ADVANCE;                                              05056000
         DO WHILE SPTR > 0;                                                     05056500
            IF (SYT_FLAGS(SPTR) & NAME_FLAG) ^= 0 THEN DO;                      05057000
               CALL SET_AUTO_NAME_NULL(CPTR, SPTR, -SYT_CONST(CPTR) +           05057500
                    STRUCT_MOD + SYT_ADDR(SPTR));                               05058000
               J = 1;                                                           05058010
            END;                                                                05058020
            ELSE IF SYT_TYPE(SPTR) = CHAR THEN DO;                              05058500
               CALL SET_AUTO_CHAR_MAX(CPTR, SPTR, -SYT_CONST(CPTR) +            05059000
                    STRUCT_MOD + SYT_ADDR(SPTR));                               05059500
               J = 1;                                                           05060000
            END;                                                                05060500
            ELSE IF (SYT_TYPE(SPTR)&"F7") = BITS THEN DO;  /*DR107694*/         05060600
               CALL SET_TEMP_BITS_ZERO(CPTR,SPTR,-SYT_CONST(CPTR)+STRUCT_MOD+   05060700
                  SYT_ADDR(SPTR));                                              05060800
               J = 1;                                                           05060900
            END;                                                                05061000
            SPTR = STRUCTURE_ADVANCE;                                           05061100
         END;                                                                   05061500
         IF SYT_ARRAY(CPTR) ^= 0 & J THEN DO;                                   05062000
            RESULT = SET_OPERAND(CPTR);                                         05062100
            INX_CON(RESULT) = -SYT_CONST(CPTR);                                 05062200
            RIGHTOP = COPY_STACK_ENTRY(RESULT);                                 05062300
            AREA = INX_CON(RESULT);                        /*DR107694*/         05062400
            SF_DISP = 1;                                                        05062500
            IF SYT_ARRAY(CPTR)=2 THEN INX_CON(RESULT) = INX_CON(RESULT)+AREA;   05062600
            CALL BEGIN_SF_REPEAT(SYT_ARRAY(CPTR)-1, 1, AREA);                   05062700
            CALL MOVE_STRUCTURE(RESULT, RIGHTOP, 1);                            05062800
            CALL END_SF_REPEAT(SYT_ARRAY(CPTR)-1);                              05062900
            CALL RETURN_STACK_ENTRIES(RIGHTOP,RESULT);     /*DR109067*/
         END;                                                                   05063000
      END;                                                                      05063500
      ELSE IF (SYT_TYPE(CPTR)&"F7")=BITS THEN DO;          /*DR107694*/         05063600
         CALL SET_TEMP_BITS_ZERO(CPTR,CPTR,-SYT_CONST(CPTR));                   05063700
      END;                                                                      05063800
   END SET_AUTO_IMPLIED;                                                        05064000
                                                                                05078500
   /* ROUTINE TO EMIT STANDARD ENTRY SEQUENCE FOR PROCEDURES  */                05079000
EMIT_ENTRY:                                                                     05079500
   PROCEDURE;                                                                   05080000
      CALL EMITRX(STM, 0, 8, TEMPBASE, NEW_STACK_LOC);                          05080500
      CALL EMITRX(LH, TEMPBASE, 0, TEMPBASE, NEW_STACK_LOC);                    05081000
   END EMIT_ENTRY;                                                              05081500
                                                                                05082000
   /* ROUTINE TO SET UP FOR BLOCK DEFINITIONS  */                               05082500
BLOCK_OPEN:                                                                     05083000
   PROCEDURE(DATA);                                                             05083500
      DECLARE DATA BIT(1), (BLOCK, PTR, CPTR, SPTR, I, J) BIT(16);              05084000
      DECLARE BLOCK_FUNCTION CHARACTER INITIAL('ADGRPSV');                      05084500
      ARRAY BLOCK_FUNCTION_ARRAY(6) BIT(8) INITIAL(1,2,3,5,5,5,6);              05084550
                                                                                05085000
      /* INTERNAL ROUTINE TO SET MAX CHAR BYTES */                              05085500
   SET_CHAR_MAX:                                                                05086000
      PROCEDURE(PTR, IADDR);                                                    05086500
         DECLARE PTR BIT(16), IADDR FIXED;                                      05087000
         DO I = 1 TO LUMP_ARRAYSIZE(PTR);                                       05087500
            CALL SET_LOCCTR(INITBASE, IADDR);                                   05088000
            CALL EMITC(CSTRING, 2);                                             05088500
            CALL EMITW(SHL(SYT_DIMS(PTR), 24), 1);                              05089000
            IADDR = IADDR + CS(SYT_DIMS(PTR) + 2);                              05089500
            LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 1;                          05089600
         END;                                                                   05090000
      END SET_CHAR_MAX;                                                         05090500
                                                                                05091000
      /* INTERNAL ROUTINE TO SET EVENTS INITIALLY OFF */                        05091500
   SET_EVENT_OFF:                                                               05092000
      PROCEDURE(PTR, IADDR);                                                    05092500
         DECLARE PTR BIT(16), IADDR FIXED;                                      05093000
         I = SHR(SYT_DIMS(PTR),8) & "FF";                                       05093500
         IF I ^= 0 THEN IF I ^= "FF" THEN RETURN;  /* DENSE */                  05094000
         CALL SET_LOCCTR(INITBASE, IADDR);                                       5094500
        DO CASE OPMODE(SYT_TYPE(PTR));                                          05095000
         ;                                                                      05095500
         DO I = 1 TO LUMP_ARRAYSIZE(PTR);                                       05096000
            CALL EMITC(0, 0);                                                   05097500
         END;                                                                   05099000
         DO;                                                                    05099500
            I = LUMP_ARRAYSIZE(PTR);                                            05100000
            CALL EMITC(DATABLK, I);                                             05100500
            DO I = 1 TO I;                                                      05101000
               CALL EMITW(0);                                                   05101500
            END;                                                                05102000
         END;                                                                   05102500
        END;                                                                    05103000
      END SET_EVENT_OFF;                                                        05104500
                                                                                05105000
      /* LOCAL ROUTINE TO SET NAMES IMPLICITLY NULL  */                         05105500
   SET_NAME_NULL:                                                               05106000
      PROCEDURE(PTR, IADDR);                                                    05106500
         DECLARE PTR BIT(16), IADDR FIXED;                                      05107000
            CALL SET_LOCCTR(INITBASE, IADDR);                                    5107500
            CALL EMITC(0, NULL_ADDR);                                           05108000
            IF (SYT_FLAGS(PTR) & REMOTE_FLAG) ^= 0 THEN                          5108010
               CALL EMITC(0, 0);                                                 5108020
         END SET_NAME_NULL;                                                     05109000
                                                                                05109500
      CALL SAVE_REGS(RM, 3);                                                    05109600
 /?P  /* CR11114 -- BFS/PASS INTERFACE; PASS PROCESS_OK FOR BFS */
      LEFTOP = GETLABEL(1);                                                     05110000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; PASS PROCESS_OK FOR BFS */
      LEFTOP = GETLABEL(1, 1);
 ?/
      BLOCK = LOC(LEFTOP);                                                      05110500
      NARGINDEX = SYT_SCOPE(BLOCK);                                             05111000
      PTR = SYT_PTR(BLOCK);                                                     05111500
      INDEXNEST(NARGINDEX) = INDEXNEST;                                         05112000
      ERRPTR(NARGINDEX) = ERRPTR;                                               05112500

 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVC STATEMENTS   */
      FIRST_TIME(NARGINDEX) = FIRST_TIME;
      LAST_SVCI(NARGINDEX) = LAST_SVCI;
      LAST_LOGICAL_STMT(NARGINDEX) = LAST_LOGICAL_STMT;
 ?/
      IF ESD_TYPE(NARGINDEX) ^= 2 THEN DO;                                      05113000
         CALL EMITC(DATA_LIST, 1);                                              05113500
         IF ^DATA THEN DO;                                                      05114000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; CHANGE #Z TO SEPARATE OBJECT, */
      /*            DELETED PDE EMISSION FOR BFS                      */
            IF NARGINDEX = PROGPOINT THEN DO;                                    5114500
               DO I = 0 TO EXCLUSIVE#-1;                                         5114550
                  CALL SET_LOCCTR(EXCLBASE, SHL(I,1));                           5114600
                  CALL EMITC(0, 0);  CALL EMITC(0, 0);                           5114650
               END;                                                              5114700
               IF SYT_TYPE(BLOCK) ^= PROG_LABEL THEN DO;                        05115000
                  CALL SET_LOCCTR(PCEBASE, 0);                                  05115500
                  CALL EMIT_Z_CON(NARGINDEX, 1, 0, 0, NARGINDEX, 0, "E");       05116000
               END;                                                             05116500
            END;                                                                 5116600
            IF SYT_TYPE(BLOCK) >= TASK_LABEL THEN DO;                           05117000
               CALL SET_LOCCTR(PCEBASE, SYT_PARM(BLOCK) * 6);                   05117500
               CALL EMITC(0, 0);   CALL EMITC(0, 0);                            05118000
               CALL EMIT_Z_CON(NARGINDEX, 1, DATABASE, 4, NARGINDEX, 0, "7");   05118500
               CALL EMITC(0, 0);                                                05119000
         IF VALS(12) = 0 THEN DO;                                               05119500
            I = CHAR_INDEX(BLOCK_FUNCTION,SUBSTR(SYT_NAME(BLOCK),0,1));         05119600
            IF I = -1 THEN I = 0;                                               05119700
            ELSE I = BLOCK_FUNCTION_ARRAY(I);                                   05119800
         END;                                                                   05119900
         ELSE I = VALS(12);                                                     05120000
         CALL EMITC(0 , I);                                                     05120100
            END;                                                                05120500
 ?/
            CALL SET_LOCCTR(DATABASE, SYT_ADDR(BLOCK));                         05121020
 /?B  /* CR11114 -- BFS/PASS BFS INTERFACE; CONSTANT PROTECTION  */
            CALL EMIT_STORE_PROTECT(TRUE);
 ?/
            IF NARGINDEX = PROGPOINT & SYT_TYPE(BLOCK) ^= PROG_LABEL THEN       05121500
               CALL EMITC(0, SHL(CMPUNIT_ID, 7));                               05122000
            ELSE CALL EMITC(0, SHL(CMPUNIT_ID, 7) + SYT_SCOPE(BLOCK));          05122500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; DELETE SETTING OF MAX ERROR  */
      /*            HALFWORD FOR BFS                                 */
            CALL EMITC(0, SHL(CALL#(NARGINDEX)=4, 15)                           05123000
               + SHL(MAXERR(NARGINDEX), 9) + ERRSEG(NARGINDEX));                05123500
 ?/
            IF NARGINDEX = PROGPOINT THEN DO;                                   05124000
               CPTR = FIRSTREMOTE;                                              05124500
               DO WHILE CPTR > 0;                                               05125000
                IF SYT_DISP(CPTR) >= 0 THEN DO;                                  5125100
                  CALL SET_LOCCTR(DATABASE, SYT_DISP(CPTR));                    05125500
                  I = SYT_SCOPE(CPTR);                                          05126000
   /* ------------------ DANNY STRAUSS DR100579 ---------------------*/         05126100
   /* SET J TO ESD OF REMOTE CSECT ONLY IF VARIABLE WAS DECLARED     */         05126101
   /* REMOTE; OTHERWISE J IS SET TO ESD OF DATA CSECT IF VARIABLE    */         05126102
   /* WAS LOCAL, EVEN IF IT WAS INCLUDED IN A REMTOTE COMPOOL        */         05126103
   IF ((SYT_FLAGS(CPTR) & NAME_OR_REMOTE) = REMOTE_FLAG) &                      05126104
      ((SYT_FLAGS(CPTR) & INCLUDED_REMOTE) = 0) THEN DO;                        05126105
   /* ---------------------------------------------------------------*/         05126106
                  J = REMOTE_LEVEL(I);                                           5126500
                 END;                                                            5127600
                 ELSE J = DATABASE(I);                                           5127700
  /*    IF IT'S A NAME VARIABLE THAT LIVES REMOTE, AND ITS POINTING */
  /*    TO AN AGGREGATE, THE ZCON TO THE NAME VARIABLE MUST POINT    */
  /*    DIRECTLY AT THE NAME VARIABLE, OTHERWISE IT POINTS TO THE    */
  /*    ZEROTH ELEMENT  */
                  DECLARE ZEROTH_ELEM  FIXED;                                   05109500
                  IF ((SYT_FLAGS(CPTR) & NAME_FLAG) ^= 0) &
                     ((SYT_FLAGS(CPTR) & INCLUDED_REMOTE) ^= 0) &
                     (SYT_CONST(CPTR) < 0)
                        THEN ZEROTH_ELEM = 0;
                        ELSE ZEROTH_ELEM = SYT_CONST(CPTR);
                  CALL EMIT_Z_CON(0,0,J,5,J,SYT_ADDR(CPTR)+ZEROTH_ELEM,
                                 SYT_BASE(CPTR) - REMOTE_BASE);                  5128010
                 END;                                                            5128100
                  CPTR = SYT_LINK1(CPTR);                                       05128500
               END;                                                             05129000
            END;                                                                05129500
 /?B  /* CR11114 --  BFS/PASS INTERFACE; CONSTANT PROTECTION  */
            CALL EMIT_STORE_PROTECT(FALSE);
 ?/
         END;                                                                   05130000
         CPTR = SYT_LEVEL(BLOCK);                                               05130500
         DO WHILE CPTR > 0;                                                     05131000
           IF (SYT_FLAGS(CPTR) & TEMPORARY_FLAG) = 0 THEN                       05131500
            IF SYT_BASE(CPTR) ^= TEMPBASE THEN DO;                              05132000
   /* ------------------ DANNY STRAUSS DR100579 ---------------------*/         05132500
   /* SET INITBASE TO ESD OF REMOTE CSECT ONLY IF VARIABLE WAS       */         05132501
   /* DECLARED REMOTE; OTHERWISE INITBASE IS SET TO ESD OF DATA      */         05132502
   /* CSECT IF VARIABLE WAS LOCAL, EVEN IF IT WAS INCLUDED IN A      */         05132503
   /* REMOTE COMPOOL                                                 */         05132504
   IF ((SYT_FLAGS(CPTR) & NAME_OR_REMOTE) = REMOTE_FLAG) &                      05132505
      ((SYT_FLAGS(CPTR) & INCLUDED_REMOTE) = 0) THEN DO;                        05132506
   /* ---------------------------------------------------------------*/         05132507
                     INITBASE = REMOTE_LEVEL;                                   05132520
               END;                                                             05132540
               ELSE INITBASE = DATABASE;                                        05132570
               IF (SYT_FLAGS(CPTR) & NAME_FLAG) ^= 0 THEN                       05133000
                  CALL SET_NAME_NULL(CPTR, SYT_ADDR(CPTR));                     05133500
               ELSE IF SYT_TYPE(CPTR) = CHAR THEN                               05134000
                  CALL SET_CHAR_MAX(CPTR, SYT_ADDR(CPTR));                      05134500
               ELSE IF DATATYPE(SYT_TYPE(CPTR)) = BITS THEN                     05135000
                  CALL SET_EVENT_OFF(CPTR, SYT_ADDR(CPTR));                     05135500
               ELSE IF SYT_TYPE(CPTR) = STRUCTURE THEN DO;                      05136000
                  STRUCT_TEMPL = SYT_DIMS(CPTR);                                05136500
                  INITMOD = EXTENT(STRUCT_TEMPL) + SYT_DISP(STRUCT_TEMPL);      05137000
                  STRUCT_MOD, STRUCT_REF = 0;                                   05137500
                  DO FOR J = 1 TO GETSTRUCT#(CPTR);                             05138000
                     SPTR = STRUCTURE_ADVANCE;                                  05138500
                     DO WHILE SPTR > 0;                                         05139000
                        IF (SYT_FLAGS(SPTR) & NAME_FLAG) ^= 0 THEN              05139500
                           CALL SET_NAME_NULL(SPTR, SYT_ADDR(CPTR) + STRUCT_MOD 05140000
                                                  + SYT_ADDR(SPTR));            05140500
                        ELSE IF SYT_TYPE(SPTR) = CHAR THEN                      05141000
                           CALL SET_CHAR_MAX(SPTR, SYT_ADDR(CPTR) + STRUCT_MOD  05141500
                                                 + SYT_ADDR(SPTR));             05142000
                        ELSE IF DATATYPE(SYT_TYPE(SPTR)) = BITS THEN            05142500
                           CALL SET_EVENT_OFF(SPTR, SYT_ADDR(CPTR) + STRUCT_MOD 05143000
                                                  + SYT_ADDR(SPTR));            05143500
                        SPTR = STRUCTURE_ADVANCE;                               05144000
                     END;                                                       05144500
                     STRUCT_MOD = STRUCT_MOD + INITMOD;                         05145000
                  END;                                                          05145500
               END;                                                             05146000
            END;                                                                05146500
            CPTR = SYT_LEVEL(CPTR);                                             05147000
         END;                                                                   05147500
         CALL EMITC(DATA_LIST, 0);                                              05148000
      END;                                                                      05148500
      IF DATA = 2 THEN DO;  /* UPDATE OR INLINE FUNCTION BLOCK  */              05149000
         CALL RESUME_LOCCTR(INDEXNEST(NARGINDEX));                              05149500
         CALL DEFINE_LABEL(LEFTOP);                                             05150000
         CALL EMIT_CALL(NARGINDEX, ^NOT_LEAF(NARGINDEX));                       05150500
         CALL SET_LOCCTR(NARGINDEX, 0);                                         05151500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENT */
         IF SYT_TYPE(BLOCK) = STMT_LABEL THEN DO;                               05152000
            UPDATING = BLOCK;                                                   05152500
            SYT_CONST(BLOCK) = 0;                                               05153000
         END;                                                                   05153500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENT */
         IF SYT_TYPE(BLOCK) = STMT_LABEL THEN
            GO TO UNIMPLEMENTED;
 ?/
      END;                                                                      05154000
      ELSE DO;                                                                  05154500
         CALL SET_LOCCTR(NARGINDEX, 0);                                         05155000
         CALL DEFINE_LABEL(LEFTOP);                                             05155500
      END;                                                                      05156000
      IF ^(DATA | ESD_TYPE(NARGINDEX)=2) THEN DO;                               05156500
         IF INDEXNEST = PROGPOINT | SYT_TYPE(BLOCK) = TASK_LABEL THEN DO;       05157000
            IF SYT_TYPE(BLOCK) >= TASK_LABEL THEN DO;                           05157500
               IF ^SDL THEN                                                     05158000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; GENERATE SVC(-1) */
                  CALL EMITP(LHI,TEMPBASE,0,EXTSYM,STACKPOINT+SYT_PARM(BLOCK)); 05158500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; GENERATE SVC(15) */
                  CALL EMITRX(SVC, 0, 0, 3, 15);
 ?/
            END;                                                                05159000
            ELSE IF OLD_LINKAGE THEN CALL EMIT_ENTRY;                           05159500
            CALL EMITP(LHI, PROGBASE, 0, EXTSYM, FSIMBASE);                     05160000
/*------------------------- #DDSE - PROLOG -----------------------*/            05160000
/* CLEAR MOST SIGNIFICANT BIT OF R1 FOR PROPER DSE OPERATION.     */            05160000
            IF DATA_REMOTE THEN                                                 04865020
               CALL EMITP(NHI,PROGBASE,0,0,"7FFF");                             05160000
/*----------------------------------------------------------------*/            05160000
            CALL EMITRX(STH, PROGBASE, 0, TEMPBASE, NEW_GLOBAL_BASE);           05160500
         END;                                                                   05161000
         ELSE IF OLD_LINKAGE THEN CALL EMIT_ENTRY;                              05161500
         ELSE DO;                                                               05162000
            IF ^NOT_LEAF(NARGINDEX) THEN                                        05162500
               CALL SAVE_BRANCH_AROUND;                                         05162510
            CALL EMITRX(STH, PROGBASE, 0, TEMPBASE, NEW_GLOBAL_BASE);           05163000
         END;                                                                   05163500
         CALL EMITPDELTA;                                                       05164000
        IF OLD_LINKAGE THEN DO;                                                 05164500
         CALL EMITRX(LA, PROCBASE, 0, TEMPBASE, 0);                             05165000
         CALL EMITRX(STH, PROCBASE, 0, TEMPBASE, NEW_STACK_LOC);                05165500
        END;                                                                    05166000
        ELSE CALL EMITP(IAL, TEMPBASE, 0, 0, 0);                                05166500
         CALL EMITRX(LA, PROCBASE, 0, PRELBASE, SYT_ADDR(BLOCK));               05167040
/*------------------------- #DDSE - PROLOG -----------------------*/            05160000
/* INITIALIZE R1 AND R3 DSES FOR COMPILATION UNIT.                */            05160000
         IF DATA_REMOTE & (INDEXNEST = PROGPOINT)                               05160000
            THEN CALL EMITP(LDM, 0, 0, EXTSYM, DSESET   , RXTYPE);              05160000
/*----------------------------------------------------------------*/            05160000
         CALL EMITRX(STH, PROCBASE, 0, TEMPBASE, NEW_LOCAL_BASE);               05167500
         ORIGIN(NARGINDEX) = EMIT_BRANCH_AROUND;                                05168000
         USAGE_LINE(R3) = -1;                                                   05168100
         IF CALL#(INDEXNEST) = 4 THEN                                           05168500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; EXCLUSIVE */
            CALL EMITRX(SVC, 0, 0, PRELBASE, SYT_ADDR(BLOCK)+2);                05169020
         IF MAXERR(NARGINDEX) > 0 THEN                                          05169500
            DO FOR J = 0 TO MAXERR(NARGINDEX) - 1;                              05170000
               CALL EMITRX(ZH, 0, 0, TEMPBASE, ERRSEG(NARGINDEX) + SHL(J, 1));  05170500
            END;                                                                05171000
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; MAKE EXCLUSIVE AN ERROR */
            GO TO UNIMPLEMENTED;
 ?/
         IF SYT_TYPE(BLOCK) = CHAR THEN DO;                                     05171500
            CALL LOAD_NUM(LINKREG, SHL(SYT_DIMS(BLOCK), 8));                    05172000
            CALL EMITRX(STH, LINKREG, 0, PTRARG1, 0);                           05172500
         END;                                                                   05173000
         DO WHILE PTR > 0 & (SYT_FLAGS(PTR) & PARM_FLAGS) ^= 0;                 05194000
            IF SYT_PARM(PTR) >= 0 THEN DO;                                      05194500
               IF (SYT_FLAGS(PTR) & POINTER_FLAG) ^= 0 THEN DO;                 05195500
                  R_TYPE(SYT_PARM(PTR)) = APOINTER;                             05195600
                  CALL SET_USAGE(SYT_PARM(PTR), APOINTER, PTR);                 05195700
               END;                                                             05195800
               ELSE DO;                                                         05195900
                  R_TYPE(SYT_PARM(PTR)) = SYT_TYPE(PTR);                        05196000
                  CALL SET_USAGE(SYT_PARM(PTR), SYM, PTR);                      05196100
               END;                                                             05196200
               IF SYT_PARM(PTR) >= FR0 THEN                                     05197500
                  CALL EMITP(MAKE_INST(STORE, SYT_TYPE(PTR), RX),               05198000
                     SYT_PARM(PTR), 0, SYM, PTR);                               05198500
            END;                                                                05199000
            IF (SYT_FLAGS(PTR)&ENDSCOPE_FLAG)>0 THEN PTR = 0;                   05199500
            ELSE PTR = PTR + 1;                                                 05200000
         END;                                                                   05200500
         CALL EMITC(DATA_LIST, 1);                                              05201000
         CPTR = SYT_LEVEL(BLOCK);                                               05201500
         DO WHILE CPTR > 0;                                                     05202000
           IF (SYT_FLAGS(CPTR) & TEMPORARY_FLAG) = 0 THEN                       05202500
            IF SYT_BASE(CPTR) = TEMPBASE THEN DO;                               05203000
               CALL SET_AUTO_IMPLIED(CPTR);                                     05203500
            END;                                                                05204000
            CPTR = SYT_LEVEL(CPTR);                                             05204500
         END;                                                                   05205000
         CALL EMITC(DATA_LIST, 0);                                              05205500
      END;                                                                      05206000
      I, PROC_LINK(NARGINDEX) = GETFREETEMP;                                    05206010
      UPPER(I) = 1; LOWER(I) = BIGNUMBER; POINT(I) = I;                         05206020
      DATA, ALCOP = 0;                                                          05206500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVCI SUPPORT */
      IF (SYT_TYPE(BLOCK) = TASK_LABEL) | (SYT_TYPE(BLOCK) = PROG_LABEL) THEN
         FIRST_TIME = 1;
      ELSE
         FIRST_TIME = 0;
      LAST_SVCI = 0;
 ?/
      DECLMODE = TRUE;                                                          05207000
   END BLOCK_OPEN;                                                              05207500
                                                                                05208000
   /* ROUTINE TO EMIT RETURNS BASED ON BLOCK TYPE  */                           05208500
EMIT_RETURN:                                                                    05209000
   PROCEDURE;                                                                   05209500
      IF SYT_TYPE(INDEX) < TASK_LABEL THEN DO;                                  05210000
/*------------------------- #DDSE - EPILOG -----------------------*/            05160000
/* SET DSES TO ZERO BEFORE EXIT FROM COMSUB COMPILATION UNIT.     */            05160000
         IF DATA_REMOTE  & (SYT_SCOPE(INDEX) = PROGPOINT) THEN                  05160000
            CALL EMITP(LDM, 0, 0, EXTSYM, DSECLR   , RXTYPE);                   05160000
/*----------------------------------------------------------------*/            05160000
        IF OLD_LINKAGE THEN DO;                                                 05210500
         CALL EMITRX(LM, 0, 0, TEMPBASE, REGISTER_SAVE_AREA);                   05211000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; DELETE OLD REFERENCE TO */
         /*            MAXERR FOR BFS                              */
         IF MAXERR(SYT_SCOPE(INDEX)) > 0 THEN CALL EMITRR(SPM, 0, LINKREG);     05211500
 ?/
         IF SYT_SCOPE(INDEX) = PROGPOINT THEN DO;                               05212000
            CALL EMITRX(LH, PROGBASE, 0, TEMPBASE, NEW_GLOBAL_BASE);            05212500
            CALL EMITRR(BCRE, ALWAYS, LINKREG);                                 05213000
         END;                                                                   05213500
         ELSE CALL EMITRR(BCR, ALWAYS, LINKREG);                                05214000
        END;                                                                    05214500
        ELSE IF NOT_LEAF(INDEXNEST) THEN                                        05215000
           CALL EMITRR(SRET, ALWAYS, TEMPBASE);                                 05215500
        ELSE DO;                                                                05216000
            IF USAGE_LINE(R3) ^= -1 THEN                                        05216010
               CALL EMITRX(LH, R3, 0, TEMPBASE, NEW_LOCAL_BASE);                05216020
 /?P  /* SSCR 8301 -- SUPPORT FOR CSECT PLACEMENT  */
            CALL EMITRR(BCRE,ALWAYS,LINKREG);                                   05216030
 ?/
 /?B  /* SSCR 8301 -- SUPPORT FOR CSECT PLACEMENT  */
            CALL EMITRR(BCR,ALWAYS,LINKREG);                                    05216030
 ?/
        END;                                                                    05216040
      END;                                                                      05216500
      ELSE DO;                                                                  05217000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; SVCI SUPPORT */
         VAL(0) = 21;  INX(0), INX_CON(0) = 0;                                  05217500
         CALL SAVE_LITERAL(0, INTEGER);                                         05218000
         CALL EMITOP(SVC, 0, 0);                                                05218500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVCI SUPPORT */
         IF LAST_SVCI ^= (LINE# - 1) THEN DO;
            IF LAST_SVCI ^= LAST_LOGICAL_STMT THEN DO;
               IF LAST_SVCI ^= 0 THEN
                  CALL ERRORS(CLASS_PR, 1,'');
               ELSE
                  CALL ERRORS(CLASS_PR, 2,'');
            END;
         END;
 ?/
      END;                                                                      05219000
   END EMIT_RETURN;                                                             05219500
                                                                                05220000
   /* ROUTINE TO FINISH OUT BLOCK DEFINITIONS  */                               05220500
BLOCK_CLOSE:                                                                    05221000
   PROCEDURE;                                                                   05221500
      INDEX = PROC_LEVEL(INDEXNEST);                                            05222000
      TYPE(0) = SYT_TYPE(INDEX);                                                05222500
      IF ^STOPPERFLAG THEN                                                      05223000
         IF TYPE(0) < ANY_LABEL THEN                                            05223500
            CALL ERRCALL(14, 'CLOSE REACHED IN FUNCTION');                      05224000
      IF TYPE(0) ^= COMPOOL_LABEL THEN DO;                                      05224500
         CALL SET_LABEL(SYT_LABEL(INDEX)+1);                                    05225000
         CALL MARKER;                                                           05228500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; EXCLUSIVE */
         IF CALL#(INDEXNEST) = 4 THEN DO;                                       05229000
            CALL EMITRX(SVC, 0, 0, PRELBASE, SYT_ADDR(INDEX)+3);                05229540
            IF TYPE(0) = STMT_LABEL THEN                                        05230000
               UPDATING = 0;                                                    05230500
         END;                                                                   05231000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; EXCLUSIVE */
         IF CALL#(INDEXNEST) = 4 THEN
            GO TO UNIMPLEMENTED;
 ?/
         CALL EMIT_RETURN;                                                      05231500
      END;                                                                      05232000
      CALL EMITC(SMADDR, LINE#);                                                05233000
      ADDRS_ISSUED = TRUE;                                                      05233500
      MARKER_ISSUED = TRUE;                                                     05234000
      UPPER(PROC_LINK(INDEXNEST)) = -1;                                         05234100
      ERRPTR = ERRPTR(INDEXNEST);                                               05234500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; EXCLUSIVE */
      IF CALL#(INDEXNEST) = 4 THEN DO;                                          05235000
         CALL SET_LOCCTR(DATABASE, SYT_ADDR(INDEX)+2);                          05235520
         IF SYT_TYPE(INDEX) = STMT_LABEL THEN DO;                               05236000
            CALL EMITC(0, SHL(SYT_CONST(INDEX)^<0, 15) + 16);                   05236500
            CALL EMITC(0, 18);                                                  05237000
            CALL EMITC(0, SYT_CONST(INDEX) & "7FFF");                           05237500
         END;                                                                   05238000
         ELSE DO;                                                               05238500
            CALL EMITC(0, 15);                                                  05239000
            CALL EMITC(0, 17);                                                  05239500
            CALL EMITADDR(EXCLBASE, SHL(SYT_LINK1(INDEX), 1), HADDR);           05240000
         END;                                                                   05240500
      END;                                                                      05241000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; EXCLUSIVE IS AN ERROR; SVCI */
      FIRST_TIME = FIRST_TIME(INDEXNEST);
      LAST_SVCI = LAST_SVCI(INDEXNEST);
      LAST_LOGICAL_STMT= LAST_LOGICAL_STMT(INDEXNEST);
      IF CALL#(INDEXNEST) = 4 THEN
         GO TO UNIMPLEMENTED;
 ?/
      CALL RESUME_LOCCTR(INDEXNEST(NARGINDEX));                                 05241500
      NARGINDEX = INDEXNEST;                                                    05242000
      CALL CLEAR_REGS;                                                          05242500
   END BLOCK_CLOSE;                                                             05243000
                                                                                 5243050
   /* ROUTINE TO SET UP STACKS FOR TEMPORARIES HELD ACROSS DO GROUPS */          5243100
INIT_TEMPORARY:                                                                  5243150
   PROCEDURE;                                                                    5243200
      DOTEMP(DOLEVEL) = 0;                                                       5243250
      DOTEMPBLK(DOLEVEL) = CURCBLK;                                              5243300
      DOTEMPCTR(DOLEVEL) = CTR;                                                  5243350
   END INIT_TEMPORARY;                                                           5243400
                                                                                05243500
   /* ROUTINE TO SET UP THE TEMPORARY ALLOCATION FOR A DO BLOCK  */             05244000
ALLOCATE_TEMPORARY:                                                             05244500
   PROCEDURE(PTR, INREG);                                                        5245000
      DECLARE (PTR, TEMP, TYP) BIT(16), INREG BIT(1);                            5245050
                                                                                 5245100
   LAST_ASSIGN_LINE:                                                             5245150
      PROCEDURE(PTR) BIT(16);                                                    5245200
         DECLARE (PTR, LINE) BIT(16);                                            5245250
         LINE = 0;                                                               5245300
         IF MAX_SEVERITY > 0 THEN RETURN LINE;                                   5245350
         PTR = SYT_XREF(PTR);                                                    5245400
         DO WHILE PTR > 0;                                                       5245450
            IF (XREF(PTR) & "8000") ^= 0 THEN                                    5245500
               LINE = XREF(PTR) & "1FFF";                                        5245550
            PTR = SHR(XREF(PTR), 16);                                            5245600
         END;                                                                    5245650
         RETURN LINE;                                                            5245700
      END LAST_ASSIGN_LINE;                                                      5245750
      IF DOTEMP(DOLEVEL) ^= 0 THEN RETURN;                                      05246000
      IF INREG THEN DO;                                                          5246050
         INREG = FALSE;                                                          5246100
         IF LAST_ASSIGN_LINE(PTR) = LINE# THEN DO;                               5246150
            SYT_BASE(PTR) = TEMPBASE;                                            5246200
            SYT_DISP(PTR) = 0;                                                   5246250
            PTR = SYT_LINK1(PTR);                                                5246300
            DOTEMP(DOLEVEL) = -1;  /* INDICATES TEMPORARIES ALREADY ALLOCATED */05246310
         END;                                                                    5246350
      END;                                                                       5246400
      DO WHILE PTR ^= 0;                                                        05246500
        IF SYT_DISP(PTR) >= 0 THEN DO;                                           5246600
         TYP = SYT_TYPE(PTR);                                                   05247000
        IF (SYT_FLAGS(PTR)&NAME_FLAG) ^= 0 THEN DO;   /*CR13212*/
           IF (SYT_FLAGS(PTR)&REMOTE_FLAG) ^= 0 THEN  /*CR13212*/
              TEMP = GETFREESPACE(DINTEGER,1);        /*CR13212*/
           ELSE TEMP = GETFREESPACE(INTEGER, 1);      /*CR13212*/
        END;                                          /*CR13212*/
        ELSE                                          /*CR13212*/
         IF TYP = STRUCTURE THEN                                                05247500
            TEMP = GETFREESPACE(STRUCTURE, EXTENT(PTR));                        05248000
         ELSE IF TYP = CHAR THEN                                                05248500
         /* DR109010: MUST USE CS TO GET #HALFWORDS FOR EACH CHAR */            05248500
         /* STRING, THEN MUST ADJUST BACK TO BYTES (*2) BECAUSE   */            05248500
         /* GETFREESPACE EXPECTS BYTES FOR CHARACTER DATA.        */            05248500
            TEMP = GETFREESPACE(CHAR, LUMP_ARRAYSIZE(PTR) *                     05249000
                                  (CS(SYT_DIMS(PTR)+2)*2)); /*DR109010*/        05249500
         ELSE TEMP = GETFREESPACE(TYP, LUMP_ARRAYSIZE(PTR) *                    05250000
                                       LUMP_TERMINALSIZE(PTR));                 05250500
         IF PACKTYPE(TYP) = VECMAT THEN                                         05251000
  /* DO NOT CALCULATE THE ZEROTH ELEMENT FOR NAME TEMPORARY VARS /*DR111381*/
            IF ( (SYT_FLAGS(PTR) & TEMPORARY_FLAG) = 0 ) |       /*DR111381*/
               ( (SYT_FLAGS(PTR) & NAME_FLAG) = 0 )              /*DR111381*/
            THEN                                                 /*DR111381*/
               DISP(TEMP) = DISP(TEMP) + BIGHTS(TYP);                           05251500
         SYT_ADDR(PTR) = DISP(TEMP);                                            05252000
         SYT_BASE(PTR) = BASE(TEMP);                                            05252500
  /* DO NOT CALCULATE THE ZEROTH ELEMENT FOR NAME TEMPORARY VARS /*DR111381*/
         IF ( (SYT_FLAGS(PTR) & TEMPORARY_FLAG) ^= 0 ) &         /*DR111381*/
            ( (SYT_FLAGS(PTR) & NAME_FLAG) ^= 0 )                /*DR111381*/
         THEN                                                    /*DR111381*/
            SYT_DISP(PTR) = DISP(TEMP);                          /*DR111381*/
         ELSE                                                    /*DR111381*/
            SYT_DISP(PTR) = DISP(TEMP) + SYT_CONST(PTR);                        05253000
         IF SYT_DISP(PTR) < 0 THEN                                              05253500
            CALL ERRORS(CLASS_BS,117,SYT_NAME(PTR));                            05254000
         CALL SET_AUTO_IMPLIED(PTR);                       /*DR107694*/         05254500
         ARRAYPOINT(LOC(TEMP)) = DOTEMP(DOLEVEL);                               05255000
         DOTEMP(DOLEVEL) = LOC(TEMP);                                           05255500
         CALL RETURN_STACK_ENTRY(TEMP);                                         05256000
        END;                                                                     5256100
         PTR = SYT_LINK1(PTR);                                                  05256500
      END;  /* WHILE PTR  */                                                    05257000
   END ALLOCATE_TEMPORARY;                                                      05257500
                                                                                05258000
   /* ROUTINE TO RETURN TEMPORARY AREA TO FREE LIST  */                         05258500
FREE_TEMPORARY:                                                                 05259000
   PROCEDURE;                                                                   05259500
      DECLARE PTR BIT(16);                                                      05260000
      DO WHILE DOTEMP(DOLEVEL) > 0;                                             05260500
         PTR = DOTEMP(DOLEVEL);                                                 05261000
         DOTEMP(DOLEVEL) = ARRAYPOINT(PTR);                                     05261500
         CALL DROPTEMP(PTR);                                                    05262000
      END;                                                                      05262500
   END FREE_TEMPORARY;                                                          05263000
                                                                                05263500
   /* ROUTINE TO LOCATE THE CURRENT LINE # FROM THE HALMAT  */                  05264000
STEP_LINE#:                                                                     05264500
   PROCEDURE;                                                                   05265000
      DECLARE (IMRK_CTR, OPRTR, OPNUM, OPTAG) BIT(16);                          05265500
                                                                                05266000
      /* LOCAL ROUTINE TO BREAK DOWN OPCODES  */                                05266500
   OPDECODE:                                                                    05267000
      PROCEDURE(CTR);                                                           05267500
         DECLARE CTR BIT(16);                                                   05268000
         OPRTR = POPCODE(CTR);                                                   5268500
         OPNUM = POPNUM(CTR);                                                    5269000
         OPTAG = POPTAG(CTR);                                                    5269500
      END OPDECODE;                                                             05270000
                                                                                05270500
      IMRK_CTR = CTR + NUMOP + 1;                                               05271000
      CALL OPDECODE(IMRK_CTR);                                                  05271500
      DO WHILE OPRTR ^= XSMRK & OPRTR ^= XIMRK;                                 05272000
         IMRK_CTR = IMRK_CTR + OPNUM + 1;                                       05272500
         CALL OPDECODE(IMRK_CTR);                                               05273000
      END;                                                                      05273500
      LINE# = SHR(OPR(IMRK_CTR+1), 16);                                         05274000
      IF ASSEMBLER_CODE THEN OUTPUT = '*** HAL/S STATEMENT ' || LINE#;          05274500
      CALL EMITC(STMTNO, LINE#);                                                05275000
      IF OPTAG > 0 THEN CALL ERRORS(CLASS_B,100);                               05275500
   END STEP_LINE#;                                                              05276000
                                                                                05276500
   /* ROUTINE TO MOVE DOFOR STACKS  */                                          05277000
DOMOVE:                                                                         05277500
   PROCEDURE(F, T);                                                             05278000
      DECLARE (F, T) BIT(16);                                                   05278500
      DOTYPE(T) = DOTYPE(F);                                                    05279000
      DOFOROP(T) = DOFOROP(F);                                                  05279500
      DOFORREG(T) = DOFORREG(F);                                                05280000
      DOLBL(T) = DOLBL(F);                                                      05280500
      DOUNTIL(T) = DOUNTIL(F);                                                  05281000
      DOFORFINAL(T) = DOFORFINAL(F);                                            05281500
      DOFORINCR(T) = DOFORINCR(F);                                              05282000
   END DOMOVE;                                                                  05282500
                                                                                05283000
   /* ROUTINE TO SET UP CONSTANT INCREMENT AND TEST VALUES FOR DO FOR  */       05283500
DOFORSETUP:                                                                     05284000
   PROCEDURE(PTR) BIT(16);                                                      05284500
      DECLARE (PTR, TEMP) BIT(16);                                              05285000
      IF FORM(PTR) = LIT THEN ;                                                 05285500
      ELSE DO;                                                                  05286000
         CALL FORCE_BY_MODE(PTR, OPTYPE);                                       05286500
         TEMP = GETFREESPACE(OPTYPE, 1);                                        05287000
         CALL EMIT_BY_MODE(STORE, REG(PTR), TEMP, OPTYPE);                      05287500
         CALL DROP_REG(PTR);                                                    05288000
         CALL RETURN_STACK_ENTRY(PTR);                                          05288500
         PTR = TEMP;                                                            05289000
      END;                                                                      05289500
      RETURN PTR;                                                               05290000
   END DOFORSETUP;                                                              05290500
                                                                                05291000
   /* ROUTINE TO EMIT WHILE OR UNTIL TERMINATION TESTS  */                      05291500
EMIT_WHILE_TEST:                                                                05292000
   PROCEDURE(OP, LBL);                                                          05292500
      DECLARE (OP, LBL, COND) BIT(16);                                          05293000
      IF TYPE(OP) = RELATIONAL THEN DO;                                         05293500
         IF TAG THEN COND = ALWAYS - REG(OP);                                   05294000
         ELSE COND = REG(OP);                                                   05294500
         CALL EMITBFW(COND, GETINTLBL(LBL));                                    05295000
      END;                                                                      05295500
      ELSE DO;                                                                  05296000
         IF TAG THEN DO;                                                        05296500
            TMP = VAL(OP);                                                      05297000
            VAL(OP) = XVAL(OP);                                                 05297500
            XVAL(OP) = TMP;                                                     05298000
         END;                                                                   05298500
         CALL FIX_INTLBL(LBL, VAL(OP));                                         05299000
         CALL SET_LABEL(XVAL(OP), LAST_TAG);                                    05299500
      END;                                                                      05300000
      CALL RETURN_STACK_ENTRY(OP);                                              05300500
   END EMIT_WHILE_TEST;                                                         05301000
                                                                                05301500
   /* ROUTINE TO SET UP IO CALLS */                                             05302000
IOINIT:                                                                         05302500
   PROCEDURE(MODE);                                                             05303000
      DECLARE (MODE, CHAN) BIT(16);                                             05303500
      CHAN = GET_OPERAND(1);                                                    05304000
      CALL FORCE_NUM(FIXARG2, VAL(CHAN));                                       05304500
      CALL FORCE_NUM(FIXARG1, MODE+(SHR(IODEV(VAL(CHAN)),2)&1));                05305000
      CALL GENLIBCALL('IOINIT');                                                05306500
      IOMODE = SHR(MODE, 1);                                                    05307000
      CALL RETURN_STACK_ENTRY(CHAN);                                            05307500
   END IOINIT;                                                                  05308000
                                                                                05308500
   /* ROUTINE TO SET UP FOR AN INTERNALLY GENERATED ARRAY DO LOOP */            05309000
PUSH_ADOLEVEL:                                                                  05309500
   PROCEDURE(NCOPIES);                                                          05310000
      DECLARE NCOPIES BIT(16);                                                  05310500
      CALL_LEVEL = CALL_LEVEL + 1;                                              05311000
      IF CALL_LEVEL > DONEST THEN                                               05311500
         CALL ERRORS(CLASS_BS,115);                                             05312000
      DOCOPY(CALL_LEVEL) = NCOPIES;                                              5312500
      DOFORM(CALL_LEVEL) = 0;                                                   05313000
      DOPTR(CALL_LEVEL), SDOPTR(CALL_LEVEL) = ADOPTR;                           05313500
      DOTOT(CALL_LEVEL) = ADOPTR + NCOPIES;                                     05314000
   END PUSH_ADOLEVEL;                                                           05314500
                                                                                05315000
   /* ROUTINE TO SET UP FOR TERMINAL ELEMENT SELECTION OF A STRUCTURE */        05315500
REF_STRUCTURE:                                                                  05316000
   PROCEDURE(PTR, OP);                                                          05316500
      DECLARE (PTR, OP, TREG) BIT(16);                                          05317000
      FORM(PTR) = CSYM;                                                         05317500
      TYPE(PTR) = SYT_TYPE(OP);                                                 05318000
      COLUMN(PTR), DEL(PTR) = 0;                                                05318500
      INX_CON(PTR), STRUCT_CON(PTR), INX(PTR) = 0;                               5319000
      REG(PTR) = BACKUP_REG(PTR);                                               05319500
      CALL SIZEFIX(PTR, OP);                                                    05320000
      IF (SYT_FLAGS(OP) & NAME_FLAG) ^= 0 THEN DO;                              05320500
         TYPE(PTR) = STRUCTURE;  /* NULL CASE  */                               05321000
         RETURN;                                                                05321500
      END;                                                                      05322000
      CALL DIMFIX(PTR, OP);                                                     05322500
      IF COPY(PTR) > 0 THEN DO;                                                  5323000
         /* CHANGE FLAG FROM 1 TO 3 SO BASE REG IS SAVED - DR109023 */
         CALL SAVE_REGS(FIXARG3, 3);                    /* DR109023 */          05323500
         CALL PUSH_ADOLEVEL(1);                                                 05324000
         COPY(PTR) = 1;                                                          5324500
         SUBLIMIT(STACK#+1) = AREASAVE;                                         05325000
         SUBLIMIT(STACK#) = LUMP_ARRAYSIZE(OP);                                 05325500
         CALL DOOPEN(1, 1, SUBLIMIT(STACK#));                                   05326000
         CALL FREE_ARRAYNESS(PTR);                                              05326500
      END;                                                                      05327000
      ELSE AREASAVE = 0;                                                        05327500
      IF PACKTYPE(TYPE(PTR)) = VECMAT THEN                                      05328000
         AREASAVE = AREASAVE + 1;                                               05328500
     INX_CON(PTR) = STRUCT_CON(PTR);  /* XPL COMPILER OUT OF REGISTERS */       05329000
     INX_CON(PTR) = INX_CON(PTR) - (BIGHTS(TYPE(PTR)) * AREASAVE);              05329001
      IF PACKTYPE(TYPE(PTR)) | INX(PTR) = PTRARG1 THEN TREG, LASTRESULT = 0;    05329500
      ELSE DO;                                                                  05330000
         TREG = PTRARG1;                                                        05330500
/*----------------------- #DREG -------------------------*/                     17930071
/* ASSIGN REGISTER FOR ADDRESS_STRUCTURE TO USE TO LA INTO.  */                 17940071
         IF DATA_REMOTE THEN                                                    17950071
            TREG = REG_STAT(PTR,TREG,LOADADDR);                                 17960071
/*-------------------------------------------------------*/                     17970071
         CALL CHECKPOINT_REG(TREG);                                             05331000
         LASTRESULT = PTR;                                                      05331500
      END;                                                                      05332000
      CALL ADDRESS_STRUCTURE(PTR, OP, 0, TREG);                                 05332500
      CALL INCR_USAGE(BASE(PTR));                                                5333000
   END REF_STRUCTURE;                                                           05333500
                                                                                05334000
   /* ROUTINE TO EMIT CALLS TO IO ROUTINES */                                   05334500
SET_IO_LIST:                                                                    05335000
   PROCEDURE(ARG);                                                              05335500
      DECLARE (ARG, PTR, AROUND) BIT(16), (IOSTRUCT, IOREPEAT) BIT(1);          05336000
      PTR = ARG_STACK(ARG);                                                     05336500
      CALL DROPSAVE(PTR);                                                       05337000
      IF ARG_TYPE(ARG) = 0 THEN DO;                                             05337500
         IF ^IOMODE THEN                                                        05338000
            CALL ASSIGN_CLEAR(PTR, 1);                                          05338500
         IF TYPE(PTR) = STRUCTURE THEN DO;                                      05339000
   /*-- DR103775 ------------- #DWRITE ------------------------------*/         18150018
   /* WRITE REMOTE STRUCTURE -- COPY TO STACK FIRST.                 */         18160001
            IF (DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)) |             18170001
            /* CHANGED FROM LIVES_REMOTE FOR NAME REMOTE DEREFS - CR12432 */
               CHECK_REMOTE(PTR) THEN DO; /* CR12432 */
               PTR = STRUC_CONVERT(PTR);                                        18190001
               CALL DROPSAVE(PTR);                                              18200001
            END;                                                                18210001
   /*----------------------------------------------------------------*/         18220018
            CALL SETUP_STRUCTURE(PTR);                                          05339500
            WORK1 = STRUCTURE_ADVANCE;                                          05340000
            IOSTRUCT = 1;                                                       05340500
         END;                                                                   05341000
         ELSE IOSTRUCT = 0;                                                     05341500
         IOREPEAT = TRUE;                                                       05342000
         DO WHILE IOREPEAT;                                                     05342500
            IF IOSTRUCT THEN                                                    05343000
               CALL REF_STRUCTURE(PTR, WORK1);                                  05343500
            DO CASE PACKTYPE(TYPE(PTR));                                        05344000
               DO;  /* VECTOR-MATRIX */                                         05344500
   /*-- DR103783 ------------- #DWRITE ------------------------------*/         18340018
   /* WRITE REMOTE VECTOR -- COPY TO STACK FIRST.                    */         18350001
                  IF (DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)) |       18360001
            /* CHANGED FROM LIVES_REMOTE FOR NAME REMOTE DEREFS - CR12432 */
                     (CHECK_REMOTE(PTR) & ^IOSTRUCT) THEN DO; /* CR12432 */
                     PTR = VECMAT_CONVERT(PTR);                                 18380001
                     CALL DROPSAVE(PTR);                                        18390001
                  END;                                                          18400001
   /*----------------------------------------------------------------*/         18410018
                  IF DEL(PTR) = 0 THEN DEL(PTR) = -1;                           05345000
                  CALL VMCALL(XVMIO+IOMODE,(TYPE(PTR)&8)^=0,0,PTR,0,DEL(PTR));  05345500
               END;                                                             05346000
               DO;  /* BITS  */                                                 05346500
                  DO CASE IOMODE;                                               05347000
                     DO;  /* INPUT  */                                          05347500
                        CALL FORCE_NUM(FIXARG2, SIZE(PTR));                     05348000
                        CALL GENLIBCALL('BIN');                                 05348500
                        AROUND = GETSTATNO;                                     05349000
                        CALL EMITBFW(EZ, GETSTMTLBL(AROUND));                   05349500
                        RESULT = GET_VAC(FIXARG2);                              05350000
                        RIGHTOP, SIZE(0) = 0;                                   05351500
                        CALL BIT_STORE(RESULT, PTR);                            05352000
                        CALL SET_LABEL(AROUND, 1);                              05352500
                        CALL DROP_VAC(RESULT);                                  05353000
                        CALL UNRECOGNIZABLE(FIXARG2);                           05353500
                     END;                                                       05354000
                     DO;  /* OUTPUT  */                                         05354500
   /*------------------------- #DREG --------------------------------*/         18600018
                        D_RTL_SETUP = TRUE;                                     18610001
   /*----------------------------------------------------------------*/         18620018
                        TARGET_REGISTER = FIXARG1;                              05355000
                        CALL FORCE_ACCUMULATOR(PTR, FULLBIT);                   05355500
                        CALL OFF_TARGET(PTR);                                   05356000
                        CALL FORCE_NUM(FIXARG2, SIZE(PTR));                     05356500
                        CALL GENLIBCALL('BOUT');                                05357500
                     END;                                                       05358000
                  END; /* CASE IOMODE  */                                       05358500
               END;                                                             05359000
/*#DWRITE*/    DO; /* CHARACTERS */                                             18710000
   /*-- DR103775 ------------- #DWRITE ------------------------------*/         18720018
   /* WRITE REMOTE CHARACTER -- COPY TO STACK FIRST.                 */         18730001
                  IF (DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)) |       18740001
            /* CHANGED FROM LIVES_REMOTE FOR NAME REMOTE DEREFS - CR12432 */
                     (CHECK_REMOTE(PTR) & ^IOSTRUCT) THEN DO; /* CR12432 */
                     PTR = CHAR_CONVERT(PTR);                                   18760001
                     CALL DROPSAVE(PTR);                                        18770001
                  END;                                                          18780001
   /*----------------------------------------------------------------*/         18790018
                  CALL CHAR_CALL(XCSIO+IOMODE, 0, PTR, 0);                      18800000
/*#DWRITE*/    END;                                                             18810000
               DO CASE IOMODE;  /* INTEGER SCALAR  */                           05360000
                  DO;  /* INPUT  */                                             05360500
   /*------------------------- #DREG --------------------------------*/         18600018
                     D_RTL_SETUP = TRUE;                                        18610001
   /*----------------------------------------------------------------*/         18620018
                     CALL FORCE_ADDRESS(PTRARG1, PTR);                          05361000
                     CALL GENLIBCALL(ITYPES(OPMODE(TYPE(PTR))) || 'IN');        05361500
                     CALL NEW_USAGE(PTR, 1);                                    05362000
                  END;                                                          05362500
                  DO;  /* OUTPUT */                                             05363000
   /*------------------------- #DREG --------------------------------*/         18600018
                     D_RTL_SETUP = TRUE;                                        18610001
   /*----------------------------------------------------------------*/         18620018
                     IF DATATYPE(TYPE(PTR))=SCALAR THEN                         05363500
                        TARGET_REGISTER = FR0;                                  05364000
                     ELSE TARGET_REGISTER = FIXARG1;                            05364500
                     CALL FORCE_ACCUMULATOR(PTR);                               05365000
                     CALL OFF_TARGET(PTR);                                      05365500
                     CALL GENLIBCALL(TYPES(SELECTYPE(TYPE(PTR))) || 'OUT');     05366000
                  END;                                                          05366500
               END;  /* CASE IOMODE */                                          05367000
               ;  /* IGNORE NAMES  */                                           05367500
            END;  /* CASE PACKTYPE */                                           05368000
            IF IOSTRUCT THEN DO;                                                05368500
               IF ARRAYNESS > 0 THEN DO;                                        05369000
                  CALL DOCLOSE;                                                 05369500
                  CALL_LEVEL = CALL_LEVEL - 1;                                  05370000
               END;                                                             05370500
               WORK1 = STRUCTURE_ADVANCE;                                       05371000
               IOREPEAT = WORK1 ^= 0;                                           05371500
               LASTRESULT = 0;                                                  05372000
            END;                                                                05372500
            ELSE IOREPEAT = FALSE;                                              05373000
         END;  /* WHILE IOREPEAT  */                                            05373500
         IF IOSTRUCT THEN                                                       05374000
            CALL OFF_INX(BACKUP_REG(PTR));                                      05374500
      END;  /* ARG TYPE = 0  */                                                 05375000
      ELSE DO;                                                                  05375500
         TARGET_REGISTER = FIXARG1;                                             05376000
         CALL FORCE_BY_MODE(PTR, INTEGER);                                      05376500
         CALL OFF_TARGET(PTR);                                                  05377000
         CALL GENLIBCALL(IOCONTROL(ARG_TYPE(ARG)));                             05377500
      END;                                                                      05378000
      CALL RETURN_STACK_ENTRY(PTR);                                             05378500
      CALL DROPFREESPACE;                                                       05379000
      CALL CLEAR_STMT_REGS;                                                     05379500
   END SET_IO_LIST;                                                             05380000
                                                                                05380500
 /?P /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS */
   /* ROUTINE TO SET UP PRIORITY EXPRESSIONS IN REAL TIME STATEMENTS */         05381000
SETUP_PRIORITY:                                                                 05381500
   PROCEDURE(N);                                                                05382000
      DECLARE N BIT(16);                                                        05382500
      LITTYPE = INTEGER;                                                        05383000
      RIGHTOP = GET_OPERAND(N);                                                 05383500
      IF FORM(RIGHTOP) = LIT THEN                                               05384000
         WORK2 = SHL(VAL(RIGHTOP), 8) + WORK2;                                  05384500
      ELSE DO;                                                                  05385000
         TO_BE_MODIFIED = TRUE;                                                 05385500
         N = FORCE_ACCUMULATOR(RIGHTOP, INTEGER);                               05386000
         CALL EMITP(SLL, N, 0, SHCOUNT, 8);                                     05386500
         CALL EMITP(AHI, N, 0, 0, WORK2);                                       05387000
         IF STATIC_BLOCK THEN                                                   05387500
            CALL EMITRX(STH, N, 0, PRELBASE, WORK1);                            05388000
         ELSE CALL EMITRX(STH, N, 0, TEMPBASE, WORK1);                          05388500
         WORK2 = 0;                                                             05389000
         USAGE(N) = 0;                                                          05389500
      END;                                                                      05390000
      CALL RETURN_STACK_ENTRY(RIGHTOP);                                         05390500
   END SETUP_PRIORITY;                                                          05391000
                                                                                05391500
   /* ROUTINE TO SET UP EVENT EXPRESSION POINTER FOR CALL */                    05392000
SETUP_EVENT:                                                                    05392500
   PROCEDURE(R, OP);                                                            05393000
      DECLARE (R, OP) BIT(16);                                                  05393500
      IF ^(FORM(OP) <= 0 | FORM(OP) = WORK) THEN DO;                            05394000
         CALL SET_EVENT_OPERAND(OP);                                            05394200
         CALL EMIT_EVENT_EXPRESSION;                                            05394400
         OP = LEFTOP;                                                           05394600
      END;                                                                      05394800
     IF FORM(OP) <= 0 THEN DO;                                                  05395000
        CALL SET_LOCCTR(DATABASE, R);                                           05395400
        IF FORM(OP) = 0 THEN CALL EMITADDR(DATABASE, DISP(OP), HADDR);          05395600
        CALL RESUME_LOCCTR(NARGINDEX);                                          05396000
     END;                                                                       05396200
     ELSE DO;                                                                   05399000
      CALL DROPSAVE(OP);                                                        05399500
      CALL FORCE_ADDRESS(PTRARG1, OP);                                          05400000
      CALL EMITRX(STH, PTRARG1, 0, TEMPBASE, R);                                05400500
     END;                                                                       05401000
      CALL RETURN_STACK_ENTRY(OP);                                              05402000
   END SETUP_EVENT;                                                             05402500
                                                                                05403000
   /* ROUTINE TO SET UP TIME OR EVENT EXPRESSION FOR REAL TIME STATEMENTS */    05403500
SETUP_TIME_OR_EVENT:                                                            05404000
   PROCEDURE(LTYPE, NREG, EVENTF, EREG);                                        05404500
      DECLARE (LTYPE, NREG, EREG) BIT(16), EVENTF BIT(1);                       05405000
      DECLARE XWAIT BIT(8) INITIAL("34");   /* CR11139    NLM */
      DECLARE XSCHD BIT(8) INITIAL("39");   /* CR11139    NLM */
      LHSPTR = LHSPTR + 1;                                                      05405500
      LITTYPE = LTYPE;                                                          05406000
      RIGHTOP = GET_OPERAND(LHSPTR, 0, 2);                                       5406500
      IF EVENTF THEN                                                            05407000
         DO;    /* IMPLEMENTATION OF CR11139       NLM  */
         IF DATA_REMOTE & STATIC_BLOCK THEN
            DO;
            IF OPCODE = XSCHD THEN
               CALL ERRORS(CLASS_XR,4,
              'SCHEDULE ON/WHILE/UNTIL EVENT IN NON-REENTRANT MODULE');
            IF OPCODE = XWAIT THEN
               CALL ERRORS(CLASS_XR,4,
              'WAIT FOR IN NON-REENTRANT MODULE');
         END;    /* END OF IMPLEMENTATION OF CR11139    NLM */
         CALL SETUP_EVENT(EREG, RIGHTOP);                                       05407500
      END;    /* CR11139    NLM */
      ELSE DO;                                                                  05408000
         TARGET_REGISTER = NREG;                                                05408500
         CALL FORCE_BY_MODE(RIGHTOP, LTYPE);                                    05409000
         CALL STACK_TARGET(RIGHTOP);                                            05409500
      END;                                                                      05410000
   END SETUP_TIME_OR_EVENT;                                                     05410500
                                                                                05416000
   /* ROUTINE TO SET UP CALLS FOR CANCEL OR TERMINATE LISTS  */                 05416500
SETUP_CANC_OR_TERM:                                                             05417000
   PROCEDURE(NAME);                                                             05417500
      DECLARE (NAME, SELECT) BIT(16);                                           05418000
      CALL MARKER;                                                              05418500
      SELECT = NUMOP > 0;                                                       05419000
     IF STATIC_BLOCK THEN DO;                                                   05419500
           CALL SET_LOCCTR(DATABASE, PROGDATA);                                 05420500
        CALL EMITC(0, SHL(NUMOP, 8) + NAME + SELECT);                           05420800
        DO LHSPTR = 1 TO NUMOP;                                                 05420900
           CALL RESUME_LOCCTR(NARGINDEX);                                       05420910
           CALL GENEVENTADDR(GETLABEL(LHSPTR));                                 05421000
        END;                                                                    05421100
        CALL RESUME_LOCCTR(NARGINDEX);                                          05421200
           CALL EMITRX(SVC, 0, 0, PRELBASE, PROGDATA);                          05422000
           PROGDATA=LOCCTR(DATABASE);                                           05422100
     END;                                                                       05424000
     ELSE DO;                                                                   05424500
      EXTOP = GETFREESPACE(INTEGER, NUMOP+1);                                   05425000
      DO LHSPTR = 1 TO NUMOP;                                                   05425500
         CALL GENSVCADDR(GETLABEL(LHSPTR), EXTOP, LHSPTR);                      05426000
      END;                                                                      05426500
      CALL GENSVC(SHL(NUMOP, 8) + NAME + SELECT, EXTOP);                        05427000
     END;                                                                       05427500
   END SETUP_CANC_OR_TERM;                                                      05431500
 ?/                                                                             05431510
   /* COPY_CHECK CHECKS %COPYS FOR CROSSING CERTAIN "NATURAL"                   05431520
      HAL ELEMENT BOUNDARIES FOR NON-REMOTE LOCALLY DECLARED DATA.  THE         05431530
      CHECK IS MORE COMPLICATED THAN NECESSARY TO LIMIT THE NUMBER OF           05431550
      ERROR MESSAGES TO BE GENERATED IN THE FLIGHT SOFTWARE.                    05431560
      THE PRINCIPAL THAT WAS USED WAS THAT AN ERROR WOULD BE RETURNED           05431570
      IF THE %COPY WAS KNOWN TO BE BAD AND A WARNING WOULD BE RETURNED          05431580
      IF AN ERROR COULD HAVE BEEN RETURNED IF THE REQUISITE INFORMATION         05431590
      HAD BEEN AVAILABLE.  RETURNS ERROR MESSAGE NUMBER (0 INDICATES NO         05431600
      PROBLEMS) */                                                              05431610
                                                                                05431620
COPY_CHECK: PROCEDURE(CHECKEE,LENGTH) BIT(16);                                  05431630
   DECLARE  CHECKEE BIT(16), /* POINTER TO VAR TO BE CHECKED */                 05431640
            LENGTH BIT(16), /* POINTER TO LENGTH */                             05431650
            LOCAL BIT(16), /* INDICATES WHETHER VAR IS LOCAL */                 05431660
            BOUND BIT(16), /* BOUND TO BE CHECKED AGAINST */                    05431670
            FLAGS FIXED,   /* LOCAL COPY OF SYT_FLAGS(LOC(CHECKEE)) */          05431680
            SCOPE BIT(16), /* LOCAL COPY OF SYT_SCOPE(LOC(CHECKEE)) */          05431690
            START BIT(16); /* PUTATIVE START ADDRESS OF COPY */                 05431700
                                                                                05431710
   DECLARE  NAME_VAR_DEREF LITERALLY '105',                                     05431720
            OKAY LITERALLY '0',                                                 05431730
            BOUND_EXCEEDED LITERALLY '106',                                     05431740
            BOUND_NOT_CHECKED LITERALLY '107';                                  05431750
   DECLARE  PARAMETER_DEREF LITERALLY '108'; /* DR107691 */
                                                                                05431760
   IF ^KNOWN_SYM(CHECKEE) THEN /* NAME VARIABLE DEREFED CHECKING NOT */         05431770
      RETURN NAME_VAR_DEREF; /* POSSIBLE */                                     05431780
                                                                                05431790
   IF DIAGNOSTICS THEN                                                          05431800
      OUTPUT = '%COPY_CHECK FOR A KNOWN SYMBOL ';                               05431810
                                                                                05431820
   FLAGS = SYT_FLAGS(LOC(CHECKEE)); /* A SOP TO EFFICIENCY */                   05431830

   /* DR111325 -- CHECK IF ARGUMENT IS A STRUCTURE NODE &  */
   /*             NAME DEREFERENCED                        */
    IF SYT_TYPE(LOC(CHECKEE)) = STRUCTURE THEN              /*DR111325*/
      IF ^MAJOR_STRUCTURE(CHECKEE) THEN              /*DR111325,111396*/
        IF (SYT_FLAGS(LOC2(CHECKEE)) & NAME_FLAG) ^= 0 THEN /*DR111325*/
              RETURN NAME_VAR_DEREF;                        /*DR111325*/

   IF (FLAGS & NAME_FLAG) ^= 0 THEN /* NAME VARIABLE */                         05431840
      RETURN NAME_VAR_DEREF;                                                    05431850

   /* DR107691 -- CHECK IF CHECKEE IS A PARAMETER PASSED-BY-REFERENCE */
   IF (FLAGS & POINTER_FLAG) ^= 0 THEN   /* DR107691 */
      RETURN PARAMETER_DEREF;            /* DR107691 */

 /*****  DR103767/DR103771 **************/
   LOCAL = (LOC(CHECKEE) >= SELFNAMELOC) & ((FLAGS & REMOTE_FLAG) = 0);         05431870
   IF ^(LOCAL) THEN RETURN OKAY;
 /****** END DR103767/103771 ************/

   SCOPE = SYT_SCOPE(LOC(CHECKEE)); /* A SOP TO EFFICIENCY */                   05431880
                                                                                05431890
   /* BOUND POINTS TO THE ADDRESS OF THE WORD AFTER THE LIMIT                   05431900
      E.G. LENGTH(CSECT) */                                                     05431910
   BOUND = SYT_ADDR(LOC(CHECKEE)) + EXTENT(LOC(CHECKEE));                       05431920
                                                                                05432070
   IF INX(CHECKEE) = 0 THEN /* COMPILE TIME ADDRESS USE ACTUAL ADDRESS */       05432080
      START = SYT_DISP(LOC(CHECKEE)) + INX_CON(CHECKEE)                         05432090
      + R_BASE(ABS(SYT_BASE(LOC(CHECKEE))));                                    05432100
   ELSE /* CHECK FOR ERROR AGAINST START OF ELEMENT, START OF STRUCTURE */      05432110
      START = SYT_ADDR(LOC(CHECKEE)); /* FOR SIMPLICITY */                      05432120
                                                                                05432130
   IF DIAGNOSTICS THEN DO;                                                      05432140
      OUTPUT = 'BOUND = ' || HEX(BOUND,4) || ', LOCAL = ' || LOCAL ||           05432150
         ', FLAGS = ' || HEX(FLAGS,8) || ', START = ' || HEX(START,4);          05432160
      OUTPUT = 'CHECKEE';                                                       05432170
      CALL DUMP_STACK(CHECKEE);                                                 05432180
      OUTPUT = 'LENGTH';                                                        05432190
      CALL DUMP_STACK(LENGTH);                                                  05432200
   END;                                                                         05432210
                                                                                05432220
   IF (START + VAL(LENGTH)) > BOUND THEN DO;                                    05432230
       RETURN BOUND_EXCEEDED;                /* DR103767/103771 */              05432240
   END; /* CHECKING FINISHED */                                                 05432280
                                                                                05432290
   IF INX(CHECKEE) ^= 0 THEN /* RUNTIME INDEXING */                             05432300
      RETURN BOUND_NOT_CHECKED;              /* DR103767/103771 */              05432310
                                                                                05432340
   RETURN OKAY;                                                                 05432350
                                                                                05432360
END COPY_CHECK;                                                                 05432370

/**************** DR107697 FIX ****************************************/
/* EXTRACT A CHARACTER STRING SIZE FROM DESCRIPTOR AND COMPUTE THE */
/* NUMBER OF HALFWORDS THAT THE STRING TAKES UP IN MEMORY.         */
EXTRACT_SIZE_FROM_DESCRIPTOR:
   PROCEDURE(SECOND_ARG) BIT(16);
      DECLARE SECOND_ARG BIT(16);
      DECLARE PTR BIT(16);
      DECLARE RESET_TARGET_FLAG BIT(1);

      RESET_TARGET_FLAG = FALSE; /* RESET FLAGS */

      /* LOGIC:                                             */
      /*   IF A STRUCTURE NODE THEN DO:                     */
      /*   NOTE: A STRUCTURE NODE CAN ONLY GET DECLARED AS  */
      /*         A NAME CHARACTER(*), NOT AS A CHARACTER(*).*/
      /*      1) THE STRUCTURE NODE HAS ALREADY BEEN LOADED */
      /*           INTO R2 SO ALL THAT HAS TO BE DONE IS TO */
      /*           DEREFERENCE THE CHARACTER ADDRESS TO GET */
      /*           TO THE STRING DESCRIPTOR                 */
      /*   END;                                             */
      /*   ELSE DO:                                         */
      /*      1) IF NECESSARY, PRESERVE R2                  */
      /*      2) LOAD CHARACTER(*) ADDRESS INTO R2          */
      /*      3) DEREFERENCE CHARACTER(*) ADDRESS TO GET    */
      /*           TO THE STRING DESCRIPTOR                 */
      /*   END;                                             */
      /*   SHIFT DESCRIPTOR RIGHT LOGICALLY 8 BITS TO GET   */
      /*     THE DESCRIPTOR MAX COUNT INTO LOWER HALF OF    */
      /*     THE REGISTER FOR SOME ARITHMETIC               */
      /*   ADD 3 TO THE MAX COUNT TO ACCOUNT FOR AN ODD     */
      /*     SIZE CHARACTER STRING LENGTH (1 BYTE) AND THE  */
      /*     STRING DESCRIPTOR (2 BYTES)                    */
      /*   SHIFT THE COUNT LOGICALLY RIGHT 1 BIT TO CONVERT */
      /*     THE SIZE FROM BYTES TO HALFWORDS               */
      /*                                                    */

      /* CREATE A WORKING COPY OF 2ND ARG. */
      PTR = GET_STACK_ENTRY;
      FORM(PTR) = SYM;
      LOC(PTR) = LOC(SECOND_ARG);
      LOC2(PTR) = LOC2(SECOND_ARG);
      TYPE(PTR) = INTEGER;  /* FORCE HALFWORD INSTRUCTIONS */
      REG(PTR) = PTRARG1; /* R2 */

      /* CHECK IF CHARACTER(*) IS A STRUCTURE NODE. IF SO,  */
      /* IT HAS ALREADY BEEN LOADED IN A R2 BY STRUCTURE_   */
      /* DECODE ROUTINE ... WE DON'T HAVE TO LOAD IT HERE!  */
      IF (SYT_TYPE(LOC(SECOND_ARG)) = STRUCTURE) THEN DO;
         /* COPY SOME MORE INFO FROM THE STRUCTURE */
         BASE(PTR) = BASE(SECOND_ARG);
         FORM(PTR) = FORM(SECOND_ARG);
         TYPE(PTR) = TYPE(SECOND_ARG);
      END; /* IF STRUCTURE ... */
      ELSE DO;
         /* PRESERVE R2 IF NECESSARY */
         CALL CHECKPOINT_REG(REG(PTR));

         CALL EMITOP(LH, REG(PTR),PTR);                     /* LH 2,CHAR(*) */
         BASE(PTR) = PTRARG1;
      END; /* OF NON-STRUCTURE PROCESSING */

      IF TARGET_REGISTER < 0 THEN DO;
         TARGET_REGISTER = FINDAC(INDEX_REG);               /* FETCH TR */
          RESET_TARGET_FLAG = TRUE;
      END;
      REG(PTR) = TARGET_REGISTER;

      /* DEREFERENCE R2 TO GET TO THE DATA...       */
      CALL EMITRX(LH,REG(PTR),INX(PTR),BASE(PTR),0);        /* LH TR,0(2) */

      BASE(PTR) = 0;           /* CLEAR BASE REG...IT IS NO LONGER NEEDED */

      /* EXTRACT THE MAX SIZE AND CONVERT TO HWS...*/
      CALL EMITP(SRL,REG(PTR),0,SHCOUNT,8);                 /* SRL TR,8 */
      CALL EMITP(AHI,REG(PTR),0,0,3);                       /* AHI TR,3 */
      CALL EMITP(SRL,REG(PTR),0,SHCOUNT,1);                 /* SRL TR,1 */

      IF RESET_TARGET_FLAG THEN TARGET_REGISTER=-1;
      FORM(PTR) = VAC;
      RETURN PTR;
END EXTRACT_SIZE_FROM_DESCRIPTOR;
/**************** END DR107697 FIX ************************************/

   /* ROUTINE TO DETERMINE WHETHER HALMAT FOLLOWING ARRAY IS NOT AN EXPRESSION*/05432500
SIMPLE_ARRAY_PARAMETER:                                                         05433000
   PROCEDURE BIT(1);                                                            05433500
      DECLARE OPC BIT(16);                                                      05434000
      OPC = POPCODE(SKIP_NOP(CTR));                                              5434500
      IF OPC = XXXAR | OPC = XSFAR | OPC = XFILE THEN RETURN TRUE;              05435000
      RETURN FALSE;                                                             05437500
   END SIMPLE_ARRAY_PARAMETER;                                                  05438000
                                                                                 5438005
   /* ROUTINE TO CATCH VECTOR/MATRIX/ARRAYED ASSIGNMENTS TO BE                   5438010
      PERFORMED VIA STRAIGHT DATA MOVEMENT */                                    5438015
SIMPLE_ARRAYED_ASSIGNMENT:                                                       5438020
   PROCEDURE BIT(1);                                                             5438025
      DECLARE (ARRNESS, PTR, CODE, CLASS, HOLDCTR, MSIZE) BIT(16),               5438030
              STYPE(2) BIT(16), SFLAG(2) BIT(1), OK BIT(1);                      5438035
                                                                                 5438040
   CONTIGUOUS:                                                                   5438045
      PROCEDURE(N) BIT(1);                                                       5438050
         DECLARE (N, OP) BIT(16), ITIS BIT(1);                                   5438055
         ITIS = FALSE;                                                           5438060
         OP = MOD_GET_OPERAND(N);                                                5438065
         IF OP = 0 THEN RETURN FALSE;                                            5438070
         SFLAG(N) = ARRAY_FLAG;                                                  5438075
         ARRAY_FLAG = FALSE;                                                     5438080
         STYPE(N) = TYPE(OP);                                                    5438085
/*--------------------------- #DPARM -----------------------------*/            21141074
/* ASSIGNMENTS TO REMOTE #D CAN STILL BE PERFORMED VIA STRAIGHT   */            21142074
/* DATA MOVEMENT, SO RESET REMOTE_RECVR FOR #D DATA HERE.         */            21143074
         IF (CSECT_TYPE(LOC(OP),OP) = LOCAL#D)                                  21144074
            THEN REMOTE_RECVR = FALSE;                                          21145074
/*----------------------------------------------------------------*/            21146074
         IF ^(NAME_OP_FLAG | REMOTE_RECVR | SUBSTRUCT_FLAG) THEN                 5438090
            IF FORM(OP) = WORK THEN ITIS = DEL(OP) = 0;                          5438095
            ELSE IF SYMFORM(FORM(OP)) THEN                                       5438100
               IF MAJOR_STRUCTURE(OP) THEN ITIS = TRUE;                          5438105
               ELSE IF DEL(OP) = 0 THEN                                          5438107
                  IF LOC(OP) = LOC2(OP) THEN ITIS = TRUE;                        5438110
                  ELSE IF SYT_ARRAY(LOC(OP)) = 0 THEN ITIS = TRUE;               5438115
         IF ^VAC_FLAG THEN CALL RETURN_STACK_ENTRY(OP);                          5438120
         RETURN ITIS;                                                            5438125
      END CONTIGUOUS;                                                            5438130
                                                                                 5438135
      OK = FALSE;                                                                5438140
      IF DOCOPY(CALL_LEVEL) = 1 THEN DO;                                         5438145
         CALL DECODEPIP(1);                                                      5438150
         IF TAG1 ^= ASIZ THEN DO;                                                5438155
            ARRNESS = OP1;                                                       5438160
            PTR = SKIP_NOP(CTR);                                                 5438165
            IF POPNUM(PTR) = 2 THEN DO;                                          5438170
               CODE = SHR(POPCODE(PTR),4);                                       5438175
               CLASS = SHR(CODE, 8);                                             5438180
               IF (CLASS>=3 & CLASS<=6 & (CODE&"FF")=XXASN) | CODE=XTASN THEN    5438185
                  IF POPCODE(SKIP_NOP(PTR)) = XDLPE THEN DO;                     5438190
                  HOLDCTR = CTR;                                                 5438195
                  CTR = PTR;                                                     5438200
                  IF CONTIGUOUS(2) THEN                                          5438205
                      IF CONTIGUOUS(1) THEN                                      5438210
                         IF STYPE(2) = STYPE(1) THEN                             5438215
                            OK = SFLAG(2) = SFLAG(1);                            5438220
                  IF OK THEN DO;                                                 5438225
                     CALL AUX_SYNC(CTR);                                         5438230
                     IF DOPUSH(CALL_LEVEL) THEN DO;                             05438235
                        CALL_LEVEL = CALL_LEVEL - 1;                            05438236
                        VDLP_ACTIVE, VDLP_IN_EFFECT = FALSE;  ARRNESS = 1;      05438237
                     END;                                                       05438238
                     ELSE DOFORM(CALL_LEVEL) = 2;                               05438239
                     RIGHTOP = GET_OPERAND(1);                                   5438240
                     LEFTOP = GET_OPERAND(2);                                    5438245
                     CALL ASSIGN_CLEAR(LEFTOP, 1);                              05438250
                     CALL TRUE_INX(RIGHTOP);                                     5438255
                     CALL TRUE_INX(LEFTOP);                                      5438260
                     IF TYPE(LEFTOP) = STRUCTURE THEN                            5438265
                        MSIZE = XVAL(LEFTOP);                                    5438267
                     ELSE IF PACKTYPE(TYPE(LEFTOP))=VECMAT&^VDLP_IN_EFFECT THEN 05438269
                        MSIZE = ROW(LEFTOP)*COLUMN(LEFTOP)*BIGHTS(TYPE(LEFTOP));05438270
                     ELSE MSIZE = BIGHTS(TYPE(LEFTOP));                         05438275
                     MSIZE = GET_INTEGER_LITERAL(MSIZE * ARRNESS);              05438280
                     CALL MOVE_STRUCTURE(LEFTOP, RIGHTOP, 0, MSIZE);             5438290
                     CALL DROPSAVE(RIGHTOP);                                     5438295
                     CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);                 5438300
                  END;                                                           5438305
                  ELSE CTR = HOLDCTR;                                            5438310
               END;                                                              5438315
            END;                                                                 5438320
         END;                                                                    5438325
      END;                                                                       5438330
      RETURN OK;                                                                 5438335
   END SIMPLE_ARRAYED_ASSIGNMENT;                                                5438340
                                                                                05438385
   /* ROUTINE TO DETERMINE IF AN INLINE VECTOR OPERATION IS TO                  05438390
      BE PERFORMED ON A SINGLE OPERATION FOR A 3 VECTOR */                      05438395
SINGLE_3VECTOR_OPERATION:                                                       05438400
   PROCEDURE;                                                                   05438405
      DECLARE PTR BIT(16);                                                      05438410
      IF NUMOP = 1 THEN DO;                                                     05438415
         CALL DECODEPIP(1);                                                     05438420
         IF OP1 = 3 THEN DO;                                                    05438425
            PTR = SKIP_NOP(CTR);                                                05438430
            IF (OPR(SKIP_NOP(PTR)) & "FFF9") = XVDLE THEN                       05438435
               RETURN TRUE;                                                     05438440
            ELSE IF (SHR(OPR(PTR),1)&"4") = 0 THEN DO;                          05438445
               PTR = VECMAT_ASN(PTR);                                           05438450
               IF PTR > 0 THEN                                                  05438455
                  IF (OPR(SKIP_NOP(PTR)) & "FFF9") = XVDLE THEN                 05438460
                     RETURN TRUE;                                               05438465
            END;                                                                05438470
         END;                                                                   05438475
      END;                                                                      05438480
      RETURN FALSE;                                                             05438485
   END SINGLE_3VECTOR_OPERATION;                                                05438490
                                                                                05438500
   /* ROUTINE TO PASS ARRAYNESS FROM OUTER LEVEL TO INNER LEVEL  */             05439000
PUSH_ARRAYNESS:                                                                 05439500
   PROCEDURE(LEVEL);                                                            05440000
      DECLARE (LEVEL, FLEVEL) BIT(16);                                          05440500
      IF LEVEL > 0 & CALL_CONTEXT(LEVEL) = 4 THEN DO;                           05441000
         FLEVEL = SAVE_CALL_LEVEL(LEVEL);                                       05441500
         DOCTR(LEVEL) = DOCTR(FLEVEL);                                          05442000
         DOCOPY(LEVEL) = DOCOPY(FLEVEL);                                        05442500
         DOFORM(LEVEL) = DOFORM(FLEVEL);                                        05443000
         SDOPTR(LEVEL) = SDOPTR(FLEVEL);                                        05443500
         SDOLEVEL(LEVEL) = FLEVEL;                                              05444000
      END;                                                                      05444500
      ELSE DOCOPY(LEVEL), DOFORM(LEVEL) = 0;                                    05445000
      SDOTEMP(LEVEL) = 0;                                                       05445500
   END PUSH_ARRAYNESS;                                                          05446000
                                                                                 5446005
   /* ROUTINE TO PUSH REGISTER ENVIRONMENT ONTO STACK */                         5446010
PUSH_ENVIRONMENT:                                                                5446015
   PROCEDURE(LBL, FBRA);                                                         5446020
      DECLARE PTR FIXED, (LBL, I) BIT(16), (FBRA, DEFAULT, NEST_OK) BIT(1);      5446025
      PTR = AUX_LOCATE(AUX_CTR, CTR, 7);                                         5446027
      CALL CLEAR_STMT_REGS;                                                      5446030
      ENV_PTR = (ENV_PTR + 1) MOD (ENV_NUM+1);                                   5446035
      ENV_LBL(ENV_PTR) = LBL;                                                    5446040
      IF PTR >= 0 THEN DO;                                                       5446041
         CALL AUX_DECODE(PTR);  NEST_OK = AUX_NEXT <= (ENV_NUM+1);               5446042
      END;                                                                       5446043
      ELSE NEST_OK = FALSE;                                                      5446044
      DO I = 0 TO REG_NUM;                                                       5446045
         DEFAULT = TRUE;                                                         5446050
         IF USAGE(I) THEN DO;                                                    5446055
            PTR = AUX_SEARCH(I, 1);                                              5446060
            IF PTR >= 0 THEN DO;                                                 5446065
               CALL AUX_DECODE(PTR);                                             5446070
               IF USAGE(I)>1 & USAGE(I)<4 & R_CONTENTS(I)=VAC & FBRA            05446075
                & ^SHR(AUX_TAG,1) THEN                                          05446076
                  DO;                                                            5446080
                     IF AUX_TAG THEN DO;                                         5446085
                        USAGE(ENV_BASE(ENV_PTR)+I) = 0;                          5446090
                        DEFAULT = FALSE;                                         5446095
                     END;                                                        5446100
                     ELSE IF AUX_NEXT = 0 & NEST_OK THEN DO;                     5446105
                        CALL COPY_REG_INFO(I, ENV_BASE(ENV_PTR)+I, USAGE(I));    5446110
                        USAGE(I) = 0;                                            5446115
                        DEFAULT = FALSE;                                         5446120
                        STACK_PTR(FETCH_VAC(AUX_LOC,-1)) = 0;                    5446122
                     END;                                                        5446125
                  END;                                                           5446130
               USAGE_LINE(I) = AUX_NEXT;                                         5446135
            END;                                                                 5446140
         END;                                                                    5446145
         IF DEFAULT THEN DO;                                                     5446150
            CALL CHECKPOINT_REG(I, TRUE);                                        5446155
            CALL COPY_REG_INFO(I, ENV_BASE(ENV_PTR)+I, 0);                       5446160
         END;                                                                    5446165
      END;                                                                       5446170
      LAST_FLOW_BLK = CURCBLK;                                                  05446175
      LAST_FLOW_CTR = CTR;                                                      05446176
      FBRA = FALSE;                                                              5446180
   END PUSH_ENVIRONMENT;                                                         5446185
                                                                                 5446190
   /* ROUTINE TO RESTORE REGISTER ENVIRONMENT TO PREVIOUS CONTENTS */            5446195
RESTORE_ENVIRONMENT:                                                             5446200
   PROCEDURE(LBL, LBL2);                                                        05446205
      DECLARE PTR FIXED, (LBL, LBL2, I) BIT(16);                                05446210
      IF ENV_LBL(ENV_PTR) = LBL THEN DO;                                        05446215
         DO I = 0 TO REG_NUM;                                                    5446220
            IF LBL2 > 0 THEN                                                    05446225
               CALL SWAP_REG_INFO(ENV_BASE(ENV_PTR) + I, I,                     05446227
                  USAGE(ENV_BASE(ENV_PTR) + I));                                05446229
            ELSE CALL COPY_REG_INFO(ENV_BASE(ENV_PTR) + I, I,                   05446231
                  USAGE(ENV_BASE(ENV_PTR) + I));                                05446233
            IF USAGE(I) THEN DO;                                                 5446235
               PTR = AUX_SEARCH(I, 1);                                           5446240
               IF PTR >= 0 THEN DO;                                              5446245
                  CALL AUX_DECODE(PTR);                                          5446250
                  USAGE_LINE(I) = AUX_NEXT;                                      5446255
                  IF AUX_NEXT > 0 THEN                                           5446256
                     IF R_CONTENTS(I) = VAC THEN                                 5446257
                        STACK_PTR(FETCH_VAC(AUX_LOC,-1)) = -1;                   5446258
               END;                                                              5446260
            END;                                                                 5446265
         END;                                                                    5446270
         IF LBL2 > 0 THEN                                                       05446271
            ENV_LBL(ENV_PTR) = LBL2;                                            05446272
      END;  ELSE CALL CLEAR_REGS;                                               05446273
      LBL2 = 0;                                                                 05446274
   END RESTORE_ENVIRONMENT;                                                      5446275
                                                                                 5446280
   /* ROUTINE TO DELETE PREVIOUSLY STACKED REGISTER ENVIRONMENT */               5446285
POP_ENVIRONMENT:                                                                 5446290
   PROCEDURE;                                                                    5446295
      ENV_LBL(ENV_PTR) = 0;                                                      5446300
      ENV_PTR = (ENV_PTR + ENV_NUM) MOD (ENV_NUM+1);                             5446305
   END POP_ENVIRONMENT;                                                          5446310
                                                                                05446320
   /* ROUTINE TO CREATE INTERSECTION OF REGISTER ENVIRONMENTS */                05446330
MERGE_ENVIRONMENT:                                                              05446340
   PROCEDURE(LBL);                                                              05446350
      DECLARE (LBL, I) BIT(16);                                                 05446360
      IF ENV_LBL(ENV_PTR) = LBL THEN                                            05446370
         DO I = 0 TO REG_NUM;                                                   05446380
            IF ^SAME_REG_INFO(I, ENV_BASE(ENV_PTR) + I) THEN                    05446390
               USAGE(I) = 0;                                                    05446400
         END;                                                                   05446410
      ELSE CALL CLEAR_REGS;                                                     05446420
   END MERGE_ENVIRONMENT;                                                       05446430
            /* CLASS 0 OPERATIONS  */                                           05446500

   DECLARE (I, INDEX_INHIBIT) BIT(1); /* CR12432 */

CLASS0:     DO CASE OPCODE;                                                     05447000
               ;  /* 0 = NOP  */                                                05447500
               ;  /* 1 = EXTN  */                                               05448000
               DO;  /* 2 = XREC  */                                             05448500
                  IF AUX_OP(AUX_CTR) = 3 THEN                                    5448600
                     AUX_CTR = AUX_CTR + 2;                                      5448700
                  IF ^CSE_FLAG THEN LAST_FLOW_CTR = 0;                          05448800
                  IF TAG THEN GENERATING = FALSE;                               05449000
                  RETURN TRUE;                                                   5449500
               END;                                                             05450000
               DO;  /* 3 = IMRK  */                                             05450500
                  GO TO DO_SMRK;                                                05451000
               END;                                                             05451500
               DO;  /* 4 = SMRK  */                                             05452000
            DO_SMRK:                                                            05452500
                  IF SAVE_STACK THEN CALL RETURN_STRUCTURE_STACK;/*DR109067*/
                 /*----------------------- #DREG -------------------*/          05452500
                 /* IF R1/R3 CHANGED, RESTORE BEFORE NEXT STATEMENT */          05452500
                  IF DATA_REMOTE & (D_R1_CHANGE | D_R3_CHANGE) THEN             05452500
                     CALL CHECK_RESTORE_R1R3(0,0,0,0);                          05452500
                 /*-------------------------------------------------*/          05452500
                  CALL DECODEPIP(1);                                            05453000
                  IF TAG2 THEN IF ^STOPPERFLAG THEN                             05453500
                     CALL MARKER;                                               05454000
                  IF TAG2 THEN                                                  05454500
                     IF ^ADDRS_ISSUED THEN                                      05455000
                        CALL EMITC(SMADDR, LINE#);                              05455500
                  ADDRS_ISSUED = FALSE;                                         05456000
                  CALL REGISTER_STATUS;                                         05456500
                  CALL DROPFREESPACE;                                           05457000
                  SF_RANGE_PTR, BOOL_COUNT, LAST_TAG = 0;                       05457500
                  CALL CLEAR_STMT_REGS;                                         05458000
                  MARKER_ISSUED = FALSE;                                        05458500
                  SSTAR_FLAG = FALSE;   /*DR111337*/
 /?B /* CR11114 -- BFS/PASS INTERFACE; SVCI SUPPORT */
                  IF ^CLOSE_STMT THEN
                     LAST_LOGICAL_STMT = LINE#;
                  CLOSE_STMT = 0;
 ?/
                  IF OPCODE = 4 THEN CALL OPTIMISE(0);                          05459000
                  ELSE CALL STEP_LINE#;                                         05459500
               END;                                                             05460000
               ;  /* 5  */                                                      05460500
               ;  /* 6  */                                                      05461000
               DO;  /* 7 = IFHD  */                                             05461500
                  CALL MARKER;                                                  05462000
               END;                                                             05462500
               DO;  /* 8 = LBL  */                                              05463000
                  IF TAG THEN DO;                                               05463500
                     CALL DECODEPIP(1);                                         05464000
                     IF LABEL_ARRAY(OP1) ^= 0 THEN DO;                          05464500
                        LAST_TAG = STOPPERFLAG;                                 05464550
                        CALL DEFINE_LABEL(GETLABEL(1), 1);                      05464600
                        IF LAST_TAG THEN CALL RESTORE_ENVIRONMENT(OP1);         05464700
                        ELSE CALL MERGE_ENVIRONMENT(OP1);                       05464710
                     END;                                                       05464800
                     CALL POP_ENVIRONMENT;                                       5465100
                  END;                                                          05465500
                  ELSE DO;                                                       5466000
                     CALL DEFINE_LABEL(GETLABEL(1), LAST_TAG);                  05466050
                     IF LAST_TAG THEN DO;                                        5466100
                        CALL RESTORE_ENVIRONMENT(OP1, OP2);                     05466150
                        CALL EMITC(STADDR, LINE#);                               5466200
                     END;                                                        5466250
                  END;                                                           5466300
                  IF TAG | LAST_TAG THEN CALL REGISTER_STATUS;                  05466310
                  LAST_TAG = FALSE;                                              5466350
 /?B  /* CR11114 -- BFS/PASS INTERFACE; TURN OFF FIRST_TIME FLAG */
                  FIRST_TIME = FALSE;
 ?/
               END;                                                             05466500
               DO;  /* 9 = BRA  */                                              05467000
                  IF ^STOPPERFLAG THEN DO;                                      05467500
                     IF ^TAG THEN CALL MARKER;                                  05468000
                     CALL EMITBFW(ALWAYS, GETLABEL(1));                         05468500
                     OP2 = OP1;                                                 05468600
                  END;                                                          05469000
                  ELSE OP2 = 0;                                                 05469010
                  LAST_TAG = TAG;                                                5469100
               END;                                                             05469500
               DO;  /* A = FBRA  */                                             05470000
                  RIGHTOP = GET_OPERAND(2);                                     05470500
                  CALL DECODEPIP(1);                                             5470600
                  CALL PUSH_ENVIRONMENT(OP1, 1);                                 5470700
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHANGE FBRA PROCESSING OF   */
      /*            BRANCH CONDTIONS; INITIAL ENTRY                 */
                  IF TYPE(RIGHTOP) = INITIAL_ENTRY THEN
                     CALL EMITBFW(REG(RIGHTOP), GETLABEL(1), 1);
                  ELSE
 ?/
                  IF TYPE(RIGHTOP) = RELATIONAL THEN                            05471000
                     CALL EMITBFW(REG(RIGHTOP), GETLABEL(1));                   05471500
                  ELSE DO;                                                      05472000
                     CALL FIX_INTLBL(OP1, VAL(RIGHTOP));                        05473000
                     CALL SET_LABEL(XVAL(RIGHTOP), LAST_TAG);                   05473500
                     ENV_LBL(ENV_PTR) = 0;                                       5473600
                  END;                                                          05474000
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             05474500
               END;                                                             05475000
               DO;  /* B = DCAS  */                                             05475500
                  DOLEVEL = DOLEVEL + 1;                                        05476000
                  IF DOLEVEL > DOSIZE THEN                                      05476500
                     CALL ERRORS(CLASS_BS,100);                                 05477000
                  CALL INIT_TEMPORARY;                                           5477500
                  CALL DECODEPIP(1);                                            05478000
                  DOLBL, DOLBL(DOLEVEL) = OP1;                                  05478500
                  OPTYPE, LITTYPE = INTEGER;                                    05479000
                  RIGHTOP = GET_OPERAND(2);                                     05479500
                  CALL FORCE_BY_MODE(RIGHTOP, OPTYPE);                          05480000
                  IF REG(RIGHTOP) = 0 THEN DO;                                  05480500
                     CALL NEW_REG(RIGHTOP, 1);                                  05481000
                  END;                                                          05481500
                  CALL MARKER;                                                  05482000
                  CALL DROP_REG(RIGHTOP);                                       05482010
                 IF TAG THEN DO;                                                05482500
                  TMP = GET_R(0,LOADLABEL); /*#DREG LOAD DOCASE LABEL*/         23970000
                  IF REG(RIGHTOP) ^= CCREG THEN                                 05483000
                     CALL ARITH_BY_MODE(TEST, RIGHTOP, RIGHTOP, OPTYPE);        05483500
                  FORM(RIGHTOP) = 0;                                            05483510
/*---------------------  RPC  DR108616  -------------------------------*/
                  IF DATA_REMOTE THEN
                     USAGE(2) = 0;   /* R2 WILL BE CHANGED, DON'T PUSH */       05483510
/*---------------------  RPC  DR108616  END  --------------------------*/
                  CALL PUSH_ENVIRONMENT(DOLBL);                                 05483520
                  CALL EMITBFW(LQ, GETINTLBL(DOLBL+3));                         05484000
                  CALL EMITP(LA, TMP, 0, CLBL, DOLBL+2);                        05486000
                  CALL EMITRX(CH, REG(RIGHTOP), 0, TMP, 0);                     05486500
                  CALL EMITBFW(GT, GETINTLBL(DOLBL+3));                         05488000
/*------------------------- #DREG ---------------------------------*/           24051074
/* CANNOT USE R3 IN A RS TYPE INSTRUCTION, SO USE R1 INSTEAD, THEN */           24052074
/* RESTORE R1 AFTERWARD. SET TMP BACK TO R2-TMP NOT NEEDED AS BASE.*/           24053074
                  IF TMP = R3 THEN DO;                                          24054074
                     TMP = GET_R(0,LOADBASE);                                   24143076
                     CALL EMITP(LA, R1, 0, CLBL, DOLBL+2);                      24144076
                     CALL EMITRX(LH, TMP, REG(RIGHTOP), R1, 0);                 24056074
                     CALL EMITRX(LH, R1, 0, TEMPBASE, NEW_GLOBAL_BASE);         24057074
                  END;                                                          24058074
                  ELSE                                                          24059074
/*-----------------------------------------------------------------*/           24059174
                  CALL EMITRX(LH, TMP, REG(RIGHTOP), TMP, 0);                   05490500
                 END;                                                           05491000
                 ELSE DO;                                                       05491500
                  NOT_THIS_REGISTER = REG(RIGHTOP);                             05491510
                  TMP = FINDAC(FIXED_ACC);                                      05491520
                  NOT_THIS_REGISTER = -1;                                       05491530
                  /* D107698: EMIT AN AHI TO ADD CASE TABLE ADDRESS */
                  /* TO THE INDEX REG SO LH WILL WORK WHEN ADDRESS  */          05491540
                  /* IS >2047; CONDENSE WILL ELIMINATE AHI IF <=2047.*/         05491540
                  /* (USE AHI INSTEAD OF LA SO BASE REGISTER USAGE   */         05491540
                  /*  DOES NOT CHANGE).                              */         05491540
                  CALL EMITP(AHI, REG(RIGHTOP), 0, CLBL, DOLBL+2); /*D107698*/  05491540
                  CALL EMITRX(LH,TMP,REG(RIGHTOP),R1,0);           /*D107698*/  05491540
                  CALL OFF_INX(TMP);                                            05491580
                  FORM(RIGHTOP) = 0;                                            05491590
                  CALL PUSH_ENVIRONMENT(DOLBL);                                 05491600
                 END;                                                           05491610
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             05492000
                  CALL EMITRR(BCR, ALWAYS, TMP);                                05492500
                  IF TAG THEN DO;                                               05493000
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL+3));                     05493010
                     CALL RESTORE_ENVIRONMENT(DOLBL);                           05493020
                  END;                                                          05493030
                  ELSE STOPPERFLAG = TRUE;                                      05494000
               END;                                                             05494500
               DO;  /* C = ECAS  */                                             05495000
                  CALL DECODEPIP(1);                                            05495500
                  IF OP1 ^= DOLBL THEN                                          05496000
                     CALL ERRORS(CLASS_BX,105);                                 05496500
                  DOCASECTR = 0;                                                05499000
                  WORK1 = LABEL_ARRAY(DOLBL+1);                                 05499500
                  WORK2 = 0;                                                    05500000
                  DO WHILE WORK1 ^= 0;                                          05500500
                     DOCASECTR = DOCASECTR + 1;                                 05501000
                     TMP = LABEL_ARRAY(WORK1+1);                                05501500
                     LABEL_ARRAY(WORK1+1) = WORK2;                              05502000
                     WORK2 = WORK1;                                             05502500
                     WORK1 = TMP;                                               05503000
                  END;                                                          05503500
                  LABEL_ARRAY(DOLBL+1) = WORK2;                                 05504000
        LABEL_ARRAY(DOLBL+2)=PROGDATA;                                          05504610
        CALL SET_LOCCTR(DATABASE , PROGDATA);                                   05504620
        /* BASE REG IS NOT LOADED */                                            05504633
 /?P  /*SSCR 8348 -- BASE REG ALLOCATION (ADCON)    */
        R_BASE_USED(SDINDEX) = R_BASE_USED(SDINDEX) - 1;                        05504636
 ?/
 /?B  /*CR11114 -- BFS/PASS INTERFACE; CONSTANT PROTECTION */
                  CALL EMIT_STORE_PROTECT(TRUE);
 ?/
                  CALL EMITC(0, DOCASECTR);                                     05505000
                  DO WHILE WORK2 ^= 0;                                          05506000
                     CALL EMITADDR(NARGINDEX, LABEL_ARRAY(WORK2), PADDR);       05506500
                     WORK2 = LABEL_ARRAY(WORK2+1);                              05507000
                  END;                                                          05507500
     PROGDATA = LOCCTR(DATABASE);                                               05508020
 /?B /*CR11114 -- BFS/PASS INTERFACE; CONSTANT PROTECTION  */
                  CALL EMIT_STORE_PROTECT(FALSE);
 ?/
                  CALL RESUME_LOCCTR(NARGINDEX);                                05508500
                  CALL DEFINE_LABEL(GETINTLBL(DOLBL));                          05509000
                  CALL POP_ENVIRONMENT;                                          5509100
                  CALL FREE_TEMPORARY;                                           5509200
                  DOLEVEL = DOLEVEL - 1;                                        05509500
                  CALL DOMOVE(DOLEVEL, 0);                                      05510000
               END;                                                             05510500
               DO;  /* D = CLBL  */                                             05511000
                  CALL DECODEPIP(1);                                            05511500
                  IF OP1 ^= DOLBL THEN                                          05512000
                     CALL ERRORS(CLASS_BX,106);                                 05512500
                  IF ^STOPPERFLAG THEN                                          05513000
                     CALL EMITBFW(ALWAYS, GETINTLBL(DOLBL));                    05513500
                 IF ^TAG THEN DO;                                               05514000
                  CALL DEFINE_LABEL(GETLABEL(2));                               05514500
                  LABEL_ARRAY(OP1+1) = LABEL_ARRAY(DOLBL+1);                    05515000
                  LABEL_ARRAY(DOLBL+1) = OP1;                                   05515500
                  CALL RESTORE_ENVIRONMENT(DOLBL);                               5515600
                  CALL EMITC(STADDR, LINE#);                                     5515700
                 END;                                                           05516000
               END;                                                             05516500
               DO;  /* E = DTST  */                                             05517000
                  DOLEVEL = DOLEVEL + 1;                                        05517500
                  IF DOLEVEL > DOSIZE THEN                                      05518000
                     CALL ERRORS(CLASS_BS,100);                                 05518500
                  CALL INIT_TEMPORARY;                                           5519000
                  CALL DECODEPIP(1);                                            05519500
                  DOLBL, DOLBL(DOLEVEL) = OP1;                                  05520000
                  CALL SAVE_REGS(RM, 3);                                         5520100
                  IF TAG THEN CALL EMITBFW(ALWAYS, GETINTLBL(DOLBL+2));         05520500
                  CALL DEFINE_LABEL(GETINTLBL(DOLBL+1));                        05521000
                  IF ^TAG THEN CALL MARKER;                                     05521500
               END;                                                             05522000
               DO;  /* F = ETST  */                                             05522500
                  CALL DECODEPIP(1);                                            05523000
                  IF OP1 ^= DOLBL THEN                                          05523500
                     CALL ERRORS(CLASS_BX,107);                                 05524000
                  CALL EMITBFW(ALWAYS, GETINTLBL(DOLBL+1));                     05524500
                  CALL DEFINE_LABEL(GETINTLBL(DOLBL));                          05525000
                  CALL FREE_TEMPORARY;                                          05525500
                  DOLEVEL = DOLEVEL - 1;                                        05526000
                  CALL DOMOVE(DOLEVEL, 0);                                      05526500
               END;                                                             05527000
               DO;  /* 10 = DFOR  */                                            05527500
                  DOLEVEL = DOLEVEL + 1;                                        05528000
                  IF DOLEVEL > DOSIZE THEN                                      05528500
                     CALL ERRORS(CLASS_BS,100);                                 05529000
                  CALL INIT_TEMPORARY;                                           5529500
                  DOTYPE = TAG & "3";                                           05530000
                  DOFOROP = GET_OPERAND(2);                                     05530500
                  CALL DECODEPIP(1);                                            05531000
                  DOLBL = OP1;                                                  05531500
                  DOFORCLBL = OP1+4;                                            05532000
                  DO WHILE DOFORCLBL >= RECORD_TOP(STMTNUM);                    05532500
                     NEXT_ELEMENT(STMTNUM);                                     05532600
                  END;                                                          05532700
                  IF SHR(TAG, 4) THEN DO;                                       05534000
                     DOUNTIL = GETFREESPACE(BOOLEAN, 1);                        05534500
                     CALL EMITOP(ZH, 0, DOUNTIL);                               05535000
                  END;                                                          05535500
                  ELSE DOUNTIL = 0;                                             05536000
                  OPTYPE, LITTYPE = TYPE(DOFOROP);                              05536500
                  IF SHR(TAG,3) THEN                                            05537000
                     CALL ALLOCATE_TEMPORARY(LOC(DOFOROP),DOTYPE^=0&DOUNTIL=0); 05537500
                  DO CASE DOTYPE=0;                                             05538000
                     DO;  /* ITERATIVE CASE  */                                 05538500
                        DOFORFINAL = GET_OPERAND(4);                            05539000
                     IF FORM(DOFORFINAL) = LIT THEN DO;                         05539500
                        IF LITTYPE = INTEGER THEN DO;                           05540000
                           FORM(DOFORFINAL) = 0;                                05540500
                           LOC(DOFORFINAL) = VAL(DOFORFINAL);                   05541000
                        END;                                                    05541500
                        ELSE CALL SAVE_LITERAL(DOFORFINAL, LITTYPE);            05542000
                     END;                                                       05542500
                        ELSE DOFORFINAL = DOFORSETUP(DOFORFINAL);               05543500
                        IF DOTYPE THEN                                          05544000
                           DOFORINCR = GET_LIT_ONE(LITTYPE);                    05544500
                        ELSE DOFORINCR = GET_OPERAND(5);                        05545000
                        DOFORINCR = DOFORSETUP(DOFORINCR);                      05545500
                        RIGHTOP = GET_OPERAND(3);                               05546000
                        IF DATATYPE(OPTYPE)=INTEGER THEN TMP = INDEX_REG;       05546500
                        ELSE TMP = 0;                                           05547000
                        DOFORREG = FORCE_BY_MODE(RIGHTOP, OPTYPE, TMP);         05547500
                        CALL GUARANTEE_ADDRESSABLE(DOFOROP,                     05548000
                           MAKE_INST(STORE, OPTYPE, RX));                       05548500
                        DOBASE = BASE(DOFOROP);                                 05549000
                        IF FORM(DOFOROP) = CSYM THEN DO;                        05549500
                           CALL CHECKPOINT_REG(DOBASE);                         05550000
                           BACKUP_REG(-BASE(DOFOROP)) = DOBASE;                 05550500
                        END;                                                    05551500
                        DOINX = INX(DOFOROP);                                   05552000
                        IF DOINX > 0 THEN DO;                                   05552500
                           CALL CHECKPOINT_REG(DOINX);                          05553000
                           BACKUP_REG(-INX(DOFOROP)) = DOINX;                   05553500
                        END;                                                    05554500
                        CALL DROP_REG(RIGHTOP);                                  5554600
                        CALL SAVE_REGS(RM, 3);                                   5554700
                        CALL EMITBFW(ALWAYS, GETINTLBL(DOLBL+4));               05555000
                        CALL DEFINE_LABEL(GETINTLBL(DOLBL+2));                  05555500
                        /*===== DAS DR102945 FIX 2/1/94 ==================*/
                        /* SED WILL REPLACE BROKEN CED FOR DOUBLE COMPARE */
                        /* NEED TO RELOAD DOFOROP BECAUSE SED DESTROYS IT */
                        IF OPMODE(OPTYPE) = 4 THEN
                           CALL EMIT_BY_MODE(LOAD, DOFORREG, DOFOROP, OPTYPE);
                        /*================================================*/
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       05558500
                        IF KNOWN_SYM(DOFOROP) THEN DO;                          05559000
                           IF SAFE_INX(DOFOROP) THEN                             5559500
                              CALL SET_USAGE(DOFORREG, SYM, LOC(DOFOROP),        5560000
                                 INX_CON(DOFOROP), INX(DOFOROP));                5560500
                           R_TYPE(DOFORREG) = OPTYPE;                           05562000
                        END;                                                    05563000
                        IF DOUNTIL > 0 THEN DO;                                 05571500
                           CALL EMITOP(TS, 0, DOUNTIL);                         05572000
                           CALL EMITBFW(EZ, GETINTLBL(DOLBL+3));                05572500
                        END;                                                    05573000
                        IF SHR(TAG, 3) & SYT_DISP(LOC(DOFOROP)) = 0 THEN DO;     5573500
                           REG(DOFOROP) = DOFORREG;                              5573550
                           FORM(DOFOROP) = VAC;                                  5573600
                           LOC2(DOFOROP) = -CTR;                                05573650
                           CALL SET_USAGE(DOFORREG, VAC, -CTR);                 05573700
                           CALL INCR_REG(DOFOROP);                               5573750
                           SYT_DISP(LOC(DOFOROP)) = -DOFOROP;                    5573800
                        END;                                                     5573850
                        ELSE REG(DOFOROP) = -1;                                  5573900
                        CALL SET_REG_NEXT_USE(DOFORREG, DOFOROP);                5573950
                     END;                                                       05574000
                     DO;  /* DISCREET CASE  */                                  05574500
                        DOFORINCR = GETFREESPACE(NAMETYPE, 1);                  05575000
                        DOFORFINAL = 0;                                         05575500
                        DOFORREG = -1;                                          05576000
                        IF FORM(DOFOROP) = CSYM THEN                            05576500
                           CALL CHECKPOINT_REG(BASE(DOFOROP));                  05577000
                        IF INX(DOFOROP) > 0 THEN                                05577500
                           CALL CHECKPOINT_REG(INX(DOFOROP));                   05578000
                        CALL SAVE_REGS(RM, 3, TRUE);                             5578100
                     END;                                                       05578500
                  END;  /* OF DO CASE  */                                       05579000
                  CALL DOMOVE(0, DOLEVEL);                                      05579500
               END;                                                             05580000
               DO;  /* 11 = EFOR  */                                            05580500
                  CALL DECODEPIP(1);                                            05581000
                  IF OP1 ^= DOLBL THEN                                          05581500
                     CALL ERRORS(CLASS_BX,108);                                 05582000
                  IF LABEL_ARRAY(DOLBL+1) ^= 0 THEN                             05582500
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL+1));                     05583000
                  IF DOTYPE ^= "FF" THEN DO;                                    05583500
                     CALL DROPSAVE(DOFORINCR);                                  05584000
                     IF DOTYPE=0 THEN DO;  /* DISCREET  */                      05584500
                        /**********  DR102954  BOB CHEREWATY  *****************/
                        /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
                        /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
                        /******************************************************/
                        CALL EMITOP(LH, LINKREG, DOFORINCR);                    05585000
                        /**********  DR102954  END  ***************************/
                        CALL EMITRR(BCR, ALWAYS, LINKREG);                      05585500
                     END;                                                       05586000
                     ELSE DO;  /* ITERATIVE  */                                 05586500
                        OPTYPE = TYPE(DOFOROP);                                 05587000
                        TARGET_REGISTER = DOFORREG;                             05587500
                        IF FORM(DOFOROP) = VAC THEN                              5587600
                           CALL DROP_REG(DOFOROP);                               5587700
                        IF FORM(DOFOROP) = CSYM THEN DO;                        05589000
                           TMP = -BASE(DOFOROP);                                05589500
                           BASE(DOFOROP) = BACKUP_REG(TMP);                     05590000
                           CALL LOAD_TEMP(BASE(DOFOROP), TMP);                  05590500
                        END;                                                    05591000
                        IF INX(DOFOROP) < 0 THEN DO;                            05591500
                           TMP = -INX(DOFOROP);                                 05592000
                           INX(DOFOROP) = BACKUP_REG(TMP);                      05592500
                           CALL LOAD_TEMP(INX(DOFOROP), TMP);                   05593000
                        END;                                                    05593500
                        RIGHTOP = DO_EXPRESSION(SUM,COPY_STACK_ENTRY(DOFORINCR),05594000
                           COPY_STACK_ENTRY(DOFOROP));                          05594500
                        CALL DEFINE_LABEL(GETINTLBL(DOLBL+4), 1);               05595000
                        IF SYMFORM(FORM(DOFOROP)) THEN                           5595500
                           CALL GEN_STORE(RIGHTOP, DOFOROP);                     5595600
                        ELSE CALL DROP_REG(RIGHTOP);                             5595700
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       05596000
                        TARGET_REGISTER = -1;                                   05596500
                        /*===== DAS DR102945 FIX 2/1/94 ==================*/
                        /* USE SED INSTEAD OF BROKEN CED FOR DOUBLE COMPARE */
                        IF OPMODE(OPTYPE) = 4 THEN COMPARE = MINUS;
                        /*================================================*/
                        IF FORM(DOFORINCR) = LIT THEN DO;                       05597000
                           CALL EMIT_BY_MODE(COMPARE, DOFORREG, DOFORFINAL,     05597500
                               OPTYPE);                                         05598000
                           IF VAL(DOFORINCR) < 0 THEN TMP = GQ;                 05598500
                           ELSE TMP = LQ;                                       05599000
                           CALL EMITBFW(TMP, GETINTLBL(DOLBL+2));               05599500
                        END;                                                    05600000
                        ELSE DO;                                                05600500
                           TMP = FINDAC(FIXED_ACC);                             05601000
                           CALL EMITOP(LH, TMP, DOFORINCR);                     05601500
                           CALL EMITPFW(LA, TMP, GETINTLBL(DOLBL+2));           05602000
                           FIRSTLABEL = GETSTATNO;                              05602500
                           CALL EMITBFW(GQ, GETSTMTLBL(FIRSTLABEL));            05603000
                           CALL EMIT_BY_MODE(COMPARE, DOFORREG, DOFORFINAL,     05603500
                              OPTYPE);                                          05604000
                           CALL EMITRR(BCR, GQ, TMP);                           05604500
                           CALL EMITBFW(ALWAYS, GETINTLBL(DOLBL));              05605000
                           CALL SET_LABEL(FIRSTLABEL, 1);                       05605500
                           CALL EMIT_BY_MODE(COMPARE, DOFORREG, DOFORFINAL,     05606000
                              OPTYPE);                                          05606500
                           CALL EMITRR(BCR, LQ, TMP);                           05607000
                           USAGE(TMP) = 0;                                      05607500
                        END;                                                    05608000
                        /*===== DAS DR102945 FIX 2/1/94 ==================*/
                        /* RESTORE COMPARE TO ORIGINAL VALUE (FROM MINUS) */
                        COMPARE = 5;
                        /*================================================*/
                     END;                                                       05609000
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL));                       05609500
                     CALL DROPSAVE(DOUNTIL);                                    05610000
                     CALL RETURN_STACK_ENTRY(DOUNTIL);                          05610500
                     CALL RETURN_STACK_ENTRY(DOFORINCR);                        05611000
                     CALL DROPSAVE(DOFORFINAL);                                 05611500
                     CALL RETURN_STACK_ENTRY(DOFORFINAL);                       05612000
                     CALL DROPSAVE(DOFOROP);                                     5612100
                     CALL RETURN_STACK_ENTRY(DOFOROP);                          05612500
                     CALL FREE_TEMPORARY;                                       05613000
                     DOLEVEL = DOLEVEL - 1;                                     05613500
                     CALL DOMOVE(DOLEVEL, 0);                                   05614000
                  END;                                                          05614500
                  ELSE DO;                                                      05615000
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL));                       05615500
                     DOLEVEL = DOLEVEL - 1;                                     05616000
                     CALL DOMOVE(DOLEVEL, 0);                                   05616500
                     CALL ERRORS(CLASS_BX,109);                                 05617000
                  END;                                                          05617500
               END;                                                             05618000
               DO;  /* 12 = CFOR  */                                            05618500
                  CALL EMIT_WHILE_TEST(GET_OPERAND(1), DOLBL);                  05619000
                  IF DOUNTIL > 0 THEN                                           05619500
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL+3));                     05620000
               END;                                                             05620500
               DO;  /* 13 = DSMP  */                                            05621000
                  DOLEVEL = DOLEVEL + 1;                                        05621500
                  IF DOLEVEL > DOSIZE THEN                                      05622000
                     CALL ERRORS(CLASS_BS,100);                                 05622500
                  CALL INIT_TEMPORARY;                                           5623000
               END;                                                             05623500
               DO;  /* 14 = ESMP  */                                            05624000
                  CALL DECODEPIP(1);                                            05624500
                  IF LABEL_ARRAY(OP1) ^= 0 THEN                                 05625000
                     CALL DEFINE_LABEL(GETINTLBL(OP1));                         05625500
                  CALL FREE_TEMPORARY;                                          05626000
                  DOLEVEL = DOLEVEL - 1;                                        05626500
                  CALL DOMOVE(DOLEVEL, 0);                                      05627000
               END;                                                             05627500
               DO;  /* 15 = AFOR  */                                            05628000
                  LITTYPE, OPTYPE = TYPE(DOFOROP);                              05628500
                  DOFORCLBL = DOFORCLBL + 1;                                    05629000
                  TARGET_REGISTER = DOFORREG;                                   05629500
                  RIGHTOP = GET_OPERAND(1);                                     05630000
                  IF DATATYPE(OPTYPE)=INTEGER THEN TMP = INDEX_REG;             05630500
                  ELSE TMP = 0;                                                 05631000
                  CALL FORCE_BY_MODE(RIGHTOP, OPTYPE, TMP);                     05631500
                  IF TARGET_REGISTER < 0 THEN                                   05632000
                     IF REG(RIGHTOP) = LINKREG THEN DO;                         05632500
                        CALL NEW_REG(RIGHTOP, 1);                               05633000
                     END;                                                       05633500
                     DOFORREG = REG(RIGHTOP);                                   05634000
                  CALL DROP_REG(RIGHTOP);                                       05634100
                  TARGET_REGISTER = -1;                                         05634500
                  IF ^TAG THEN DO;                                              05635000
                     CALL EMITPFW(BAL, LINKREG, GETINTLBL(DOLBL+2));            05635500
                     CALL DEFINE_LABEL(GETINTLBL(DOFORCLBL));                   05636000
                  END;                                                          05636500
                  ELSE DO;                                                      05637000
                     CALL EMITPFW(LA, LINKREG, GETINTLBL(DOLBL));               05637500
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL+2));                     05638000
                     CALL EMITOP(NAMESTORE, LINKREG, DOFORINCR);                05638500
                     CALL NEED_STACK(INDEXNEST);                                05639000
                     CALL INCR_REG(RIGHTOP);                                    05639500
                     CALL GEN_STORE(RIGHTOP, DOFOROP, 0);                       05639510
                     CALL MARKER;                                               05640000
                     IF DOUNTIL > 0 THEN DO;                                    05640500
                        CALL EMITOP(TS, 0, DOUNTIL);                            05641000
                        CALL EMITBFW(EZ, GETINTLBL(DOLBL+3));                   05641500
                     END;                                                       05642000
                     REG(DOFOROP) = -1;                                         05642500
                  END;                                                          05643000
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             05643500
               END;                                                             05644000
               DO;  /* 16 = CTST  */                                            05644500
                  CALL EMIT_WHILE_TEST(GET_OPERAND(1), DOLBL);                  05645000
                  IF TAG THEN DO;                                               05645500
                     CALL DEFINE_LABEL(GETINTLBL(DOLBL+2));                     05646000
                     CALL MARKER;                                               05646500
                  END;                                                          05647000
               END;                                                             05647500
               DO;  /* 17 = ADLP  */                                            05648000
                  IF TAG ^= CALL_LEVEL THEN                                     05648500
                     CALL ERRORS(CLASS_BX,102);                                 05649000
                  CALL_LEVEL = CALL_LEVEL + CSE_FLAG;                            5649100
                  DOBLK(CALL_LEVEL) = CURCBLK;                                  05649200
                  DOCTR(CALL_LEVEL) = CTR;                                      05649500
                  DOCOPY(CALL_LEVEL) = NUMOP;                                   05650000
                  SDOPTR(CALL_LEVEL) = ADOPTR;                                  05650500
                  SDOLEVEL(CALL_LEVEL) = CALL_LEVEL;                            05651000
                  DOVDLP(CALL_LEVEL), VDLP_IN_EFFECT = TYPE_BITS(NUMOP);        05651040
                  DOPUSH(CALL_LEVEL) = CSE_FLAG;                                 5651080
                 IF SIMPLE_ARRAYED_ASSIGNMENT THEN                               5651120
                    ;                                                            5651160
                 ELSE IF CSE_FLAG THEN DO;                                       5651200
                  CALL_CONTEXT(CALL_LEVEL) = TYPE_BITS(1) & 2;                   5651240
                  IF (OPR(SKIP_NOP(CTR)) & "FFF9") = XVDLE THEN                  5651280
                     DOFORM(CALL_LEVEL) = 2;                                     5651320
                  ELSE IF SINGLE_3VECTOR_OPERATION THEN DO;                     05651330
                     CALL_LEVEL = CALL_LEVEL - 1;  VDLP_IN_EFFECT = FALSE;      05651340
                  END;                                                          05651350
                  ELSE CALL EMIT_ARRAY_DO(CALL_LEVEL);                           5651360
                 END;                                                            5651400
                 ELSE DO;                                                        5651440
                  IF SIMPLE_ARRAY_PARAMETER & ^CALL_CONTEXT(TAG) THEN           05651500
                     DOFORM(CALL_LEVEL) = 2;                                    05652000
                  ELSE IF POPCODE(SKIP_NOP(CTR)) = XDLPE THEN                   05652100
                     DOFORM(CALL_LEVEL) = 2;                                    05652200
                  ELSE CALL EMIT_ARRAY_DO(CALL_LEVEL);                          05652500
                 END;                                                            5652600
               END;                                                             05653000
               DO;  /* 18 = DLPE  */                                            05653500
                  IF CSE_FLAG THEN IF CALL_LEVEL = TAG THEN                     05654000
                     GO TO VDLP_ALREADY_GONE;                                   05654010
                  IF CALL_LEVEL ^= TAG+CSE_FLAG THEN                             5654100
                     CALL ERRORS(CLASS_BX,110);                                 05654500
                  CALL DOCLOSE;                                                 05655000
                  CALL DROPLIST(CALL_LEVEL);                                    05655500
                  CALL PUSH_ARRAYNESS(CALL_LEVEL);                              05656000
                  CALL_LEVEL = CALL_LEVEL - CSE_FLAG;                            5656100
               VDLP_ALREADY_GONE:                                               05656200
                  IF CSE_FLAG THEN                                              05656210
                     VDLP_IN_EFFECT = DOVDLP(CALL_LEVEL);                       05656220
                  ELSE VDLP_IN_EFFECT, DOVDLP(CALL_LEVEL) = FALSE;              05656230
                  DOPUSH(CALL_LEVEL) = FALSE;                                    5656300
               END;                                                             05656500
               DO;  /* 19 = DSUB  */                                            05657000
                  NAME_SUB = SHR(TAG, 7);                                       05657500
                  LITTYPE, TAG = TAG & "3F";                                     5658000
                  TMP = NAME_SUB & X_BITS(1);                                   05658500
                  ALCOP = GET_OPERAND(1, 1, TMP);                               05659000
                  CALL DO_DSUB(X_BITS(1));                                       5659500
               END;                                                             05660000
               DO;  /* 1A = IDLP  */                                            05660500
                  IF TAG ^= CALL_LEVEL THEN                                     05661000
                     CALL ERRORS(CLASS_BX,102);                                 05661500
                  SDOPTR(CALL_LEVEL) = ADOPTR;                                  05662000
                  DO SUBOP = 1 TO NUMOP;                                        05662500
                     ADOPTR = ADOPTR + 1;                                       05663000
                     CALL DECODEPIP(SUBOP);                                     05663500
                     DORANGE(ADOPTR) = OP1-1;                                   05664000
                     DOINDEX(ADOPTR) = 0;                                       05664500
                     DOLABEL(ADOPTR) = CTR;                                     05665000
                     DOSTEP(ADOPTR) = CURCBLK;                                  05665500
                     DOAUX(ADOPTR) = AUX_CTR;                                    5665600
                  END;                                                          05666000
                  DOCOPY(CALL_LEVEL) = NUMOP;                                   05666500
                  DOFORM(CALL_LEVEL) = 1;                                       05667000
               END;                                                             05667500
               DO;  /* 1B = TSUB  */                                            05668000
                  ALCOP = GET_STRUCTOP(1);                                      05668500
                  STRUCTOP = 0;                                                 05669000
                  STACK# = COPY(ALCOP) + 1;                                     05669500
                  DOPTR# = DOPTR(CALL_LEVEL);                                   05670000
                  SUB# = 1;                                                     05670500
                  ARRAY_FLAG = 0;                                               05671000
                 DO SUBOP = 2 TO NUMOP;                                         05671100
                  CALL GET_SUBSCRIPT;                                           05671500
                  INXMOD = 0;                                                   05672000
                  VALMUL = SUBLIMIT(SUB#-1);                                    05672100
                  DO CASE TAG3 & 3;                                             05672200
                     DO;  /* SSTAR  */                                          05673000
                        SSTAR_FLAG = TRUE;  /*DR111337*/
                        DOPTR# = DOPTR# + 1;                                    05673500
                        INXMOD = DOINDEX(DOPTR#);                               05674000
                        RIGHTOP = GET_INTEGER_LITERAL(0);                       05674500
                        VALMOD = 0;                                             05675000
                        GO TO SET_SINDX;                                        05675500
                     END;                                                       05676000
                     DO;  /* SINDX  */                                          05676500
                       IF TAG2 THEN                                             05676600
                        VALMUL = 1;                                             05676700
                       ELSE DO;                                                 05676800
                        COPY(ALCOP) = COPY(ALCOP) - 1;                          05677000
                        STRUCT(ALCOP) = 0;                                      05677500
                        SUBRANGE(SUB#) = 1;                                     05678000
                       END;                                                     05678100
                        VALMOD = 0;                                             05678500
                  SET_SINDX:                                                    05679000
                        IF FORM(RIGHTOP) = LIT THEN DO;                         05680000
                           STRUCT_CON(ALCOP) = VALMUL * (VAL(RIGHTOP)-VALMOD)   05680500
                              + STRUCT_CON(ALCOP);                              05681000
                           CALL RETURN_STACK_ENTRY(RIGHTOP);                    05681500
                        END;                                                    05682000
                        ELSE DO;                                                05682500
                           STRUCT_CON(ALCOP) = VALMUL * (CONST(RIGHTOP)-VALMOD) 05683000
                              + STRUCT_CON(ALCOP);                              05683500
                           CONST(RIGHTOP) = 0;                                  05684000
                        OPTYPE = TYPE(RIGHTOP);                                 05684010
                      IF STRUCTOP = 0 THEN DO;                                  05684020
                         IF FORM(RIGHTOP)^=SYM|(INX(RIGHTOP)|INXMOD)^=0 THEN DO;05684500
                           TO_BE_MODIFIED = VALMUL ^= 1;                        05685000
                           CALL FORCE_ACCUMULATOR(RIGHTOP, INTEGER, INDEX_REG); 05685500
                         END;                                                   05686000
                           STRUCTOP = RIGHTOP;                                  05686500
                      END;                                                      05686510
                      ELSE CALL EXPRESSION(XADD);                               05686520
                        END;                                                    05687000
                       IF STRUCTOP = 0 & INXMOD ^= 0 THEN                       05687010
                        STRUCTOP = ARRAY2_INDEX_MOD(STRUCTOP,INXMOD,0,VALMUL,0);05687020
                       ELSE DO;                                                 05687030
                        TO_BE_MODIFIED = TRUE;                                  05687500
                        STRUCTOP = ARRAY_INDEX_MOD(STRUCTOP, INXMOD);           05688000
                        RIGHTOP = GET_INTEGER_LITERAL(0);                       05688500
                        CALL SUBSCRIPT2_MULT(VALMUL);                           05689000
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       05689500
                       END;                                                     05689600
                        IF INXMOD > 0 THEN ARRAY_FLAG = TRUE;                   05690000
                        STRUCT_INX(ALCOP) = ARRAY_FLAG + 4;                      5690100
                     END;                                                       05690500
                     DO;  /* STSUB  */                                          05691000
                        DOPTR# = DOPTR# + 1;                                    05691500
                        SUBRANGE(SUB#) = VAL(EXTOP) - VAL(RIGHTOP) + 1;         05692000
                        IF SUBRANGE(SUB#) ^= VAL(DORANGE(DOPTR#)) THEN          05692500
                           CALL ERRORS(CLASS_EA,102);                           05693000
                        CALL RETURN_STACK_ENTRY(EXTOP);                         05693500
                        VALMOD = 1;                                             05694000
                        INXMOD = DOINDEX(DOPTR#);                               05694500
                        GO TO SET_SINDX;                                        05695000
                     END;                                                       05695500
                     DO;  /* SASUB  */                                          05696000
                        DOPTR# = DOPTR# + 1;                                    05696500
                        SUBRANGE(SUB#) = VAL(RIGHTOP);                          05697000
                        IF VAL(RIGHTOP) ^= VAL(DORANGE(DOPTR#)) THEN            05697500
                           CALL ERRORS(CLASS_EA,102);                           05698000
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       05698500
                        RIGHTOP = EXTOP;                                        05699000
                        VALMOD = 1;                                             05699500
                        INXMOD = DOINDEX(DOPTR#);                               05700000
                        GO TO SET_SINDX;                                        05700500
                     END;                                                       05701000
                  END;  /* CASE TAG3  */                                        05701500
                 END;  /* SUBOP */                                              05701600
                  STACK# = 0;                                                   05702000
                  IF STRUCTOP ^= 0 THEN DO;                                     05702500
                     IF FORM(STRUCTOP) ^= VAC THEN                              05703000
                        CALL FORCE_ACCUMULATOR(STRUCTOP, INTEGER, INDEX_REG);   05703500
                     IF REG(STRUCTOP) = 0 THEN                                  05704000
                        CALL NEW_REG(STRUCTOP, 1);                              05704500
                     INX(ALCOP) = REG(STRUCTOP);                                05705000
                     INX_NEXT_USE(ALCOP) = NEXT_USE(STRUCTOP);                   5705100
                     CALL RETURN_STACK_ENTRY(STRUCTOP);                         05705500
                  END;                                                          05706000
                  COPY(ALCOP), STRUCT(ALCOP) = 0;                               05706500
                  IF SUBSCRIPT_TRACE THEN OUTPUT =                              05707000
                     'STRUCT_CON='||STRUCT_CON(ALCOP)||',SIZE='||SIZE(ALCOP);   05707500
                  CALL SETUP_VAC(ALCOP);                                        05708000
               END;                                                             05708500
               ;  /* 1C  */                                                     05709000
               DO;  /* 1D = PCAL  */                                            05709500
                  IF TAG ^= CALL_LEVEL THEN                                     05710000
                     CALL ERRORS(CLASS_BX,101);                                 05710500
                  LEFTOP = GETLABEL(1);                                         05711000
                  IF CALL_CONTEXT(CALL_LEVEL) = 4 THEN DO;                      05711500
                     CALL PROC_FUNC_SETUP;                                      05712000
                     CALL PROC_FUNC_CALL(LEFTOP);                               05712500
                  END;                                                          05713000
                  ELSE DO;  /* NONHAL  */                                       05713500
                     CALL NONHAL_PROC_FUNC_SETUP;                               05714000
                     CALL NONHAL_PROC_FUNC_CALL;                                05714500
                  END;                                                          05715000
               END;                                                             05715500
               DO;  /* 1E = FCAL  */                                            05716000
                  IF TAG ^= CALL_LEVEL THEN                                     05716500
                     CALL ERRORS(CLASS_BX,101);                                 05717000
                  LEFTOP = GETLABEL(1);                                         05717500
                  IF CALL_CONTEXT(CALL_LEVEL) = 4 THEN DO;                      05718000
                     CALL PROC_FUNC_SETUP;                                      05718500
                     OPTYPE = TYPE(LEFTOP);                                     05719000
                     IF PACKTYPE(OPTYPE)=VECMAT THEN DO;                        05719500
                      IF RETURN_EXP_OR_FN(CTR+NUMOP+1) THEN                     05720000
                       CALL FORCE_ADDRESS(SYT_PARM(LOC2(LEFTOP)),RESULT);       05720500
                      ELSE                                                      05721000
                       RESULT=GET_FUNC_RESULT(LEFTOP);                          05721500
                     END;                                                       05722000
                     ELSE                                                       05722500
                      RESULT=GET_FUNC_RESULT(LEFTOP);                           05723000
                     CALL PROC_FUNC_CALL(LEFTOP);                               05723500
                     IF PACKTYPE(TYPE(RESULT)) THEN                             05724000
                        CALL SET_RESULT_REG(RESULT, TYPE(RESULT));              05724500
                  END;                                                          05725000
                  ELSE DO;  /* NONHAL  */                                       05725500
                     CALL NONHAL_PROC_FUNC_SETUP;                               05726000
                     RESULT = GET_STACK_ENTRY;                                  05726500
                     TYPE(RESULT) = TYPE(LEFTOP);                               05727000
                     SIZE(RESULT) = SIZE(LEFTOP);                               05727500
                     CALL NONHAL_PROC_FUNC_CALL;                                05728000
                     IF TYPE(RESULT) = ANY_LABEL THEN                           05728500
                        CALL ERRORS(CLASS_PE,101);                              05729000
                     CALL SET_RESULT_REG(RESULT, TYPE(RESULT), 1);              05729500
                  END;                                                          05730000
                  CALL SETUP_VAC(RESULT);                                        5730500
               END;                                                             05731000
               ;  /* 1F = READ  */                                              05731500
               ;  /* 20 = RDAL  */                                              05732000
               DO;  /* 21 = WRIT  */                                            05732500
                /*CALL IOINIT(2);                                               05733000
                  DO ARG#=SAVE_ARG_STACK_PTR(CALL_LEVEL) TO ARG_STACK_PTR-1;    05733500
                     CALL SET_IO_LIST(ARG#);                                    05734000
                  END;*/                                                        05734500
               END;                                                             05735000
               DO;  /* 22 = FILE  */                                            05735500
   /*------------------------- #DREG --------------------------------*/         29480018
                  D_RTL_SETUP = TRUE;                                           29490001
   /*----------------------------------------------------------------*/         29500018
                  LITTYPE = INTEGER;                                            05736000
                  LEFTOP = GET_OPERAND(1);                                      05736500
                  LITTYPE = TYPE_BITS(2);                                       05737000
                  RIGHTOP = GET_OPERAND(2);                                     05737500
                  IF ^TAG2 THEN                                                 05738000
                     CALL ASSIGN_CLEAR(RIGHTOP, 1);                             05738500
                  IF DOCOPY > 0 THEN                                            05739000
                     IF DOFORM = 0 THEN DO;                                     05739500
                        RIGHTOP = GEN_ARRAY_TEMP(RIGHTOP, TYPE(RIGHTOP));       05740000
                     END;                                                       05740500
                  RIGHTOP = SETUP_NONHAL_ARG(RIGHTOP);                          05741000
                  CALL DROPSAVE(RIGHTOP);                                       05741500
                  CALL STACK_REG_PARM(FORCE_ADDRESS(PTRARG1, RIGHTOP, 1));      05742000
                  TARGET_REGISTER = FIXARG1;                                    05742500
                  EXTOP = SETUP_TOTAL_SIZE(RIGHTOP);                            05743000
                  CALL FORCE_ACCUMULATOR(EXTOP);                                05743500
                  CALL STACK_TARGET(EXTOP);                                     05744000
                  TARGET_REGISTER = FIXARG2;                                    05744500
                  CALL FORCE_ACCUMULATOR(LEFTOP);                               05745000
                  CALL OFF_TARGET(LEFTOP);                                      05745500
                  CALL DROP_PARM_STACK;                                         05746000
                  CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);                   05746500
                  CALL FORCE_NUM(FIXARG3, TAG);                                 05747000
                  CALL GENLIBCALL(FILECONTROL(TAG2));                           05748000
               END;                                                             05748500
               ;   ;  /* 23 - 24  */                                            05749000
               DO;  /* 25 = XXST  */                                            05749500
                  IF TAG > CALL_LEVEL# THEN                                     05750000
                     CALL ERRORS(CLASS_BS,101);                                 05750500
                  SAVE_CALL_LEVEL(TAG) = CALL_LEVEL;                            05751000
                  SAVE_ARG_STACK_PTR(TAG) = ARG_STACK_PTR;                      05751500
                  CALL_LEVEL = TAG;                                             05752000
                  IF TAG_BITS(1) = IMD THEN DO;                                 05752500
                     CALL DECODEPIP(1);                                         05753000
                     CALL_CONTEXT(CALL_LEVEL) = 1 /*+ (OP1 >= 2)*/;             05753500
                   /*IF OP1 < 2 THEN*/ DO;                                      05754000
                        RESET = CTR;                                            05754500
                        CTR = READCTR;                                          05755000
                        CALL IOINIT(OP1);                                       05755500
                        CTR = RESET;                                            05756000
                     END;                                                       05756500
                  END;                                                          05757000
                  ELSE DO;                                                      05757500
                     LEFTOP = GETLABEL(1);                                      05758000
                     /*** DR108643 ***/
                     IF (SYT_FLAGS2(LOC(LEFTOP)) & NONHAL_FLAG) = 0 THEN DO;    05758500
                     /*** END DR108643 ***/
                        CALL_CONTEXT(CALL_LEVEL) = 4;                           05759000
                        IF (SYT_FLAGS(LOC2(LEFTOP)) & DEFINED_LABEL) = 0 THEN   05759500
                           CALL ERRORS(CLASS_DU,100);                           05760000
                        ARG_COUNTER(CALL_LEVEL) = NARGS(SYT_SCOPE(LOC(LEFTOP)));05760500
                        ARG_POINTER(CALL_LEVEL) = SYT_PTR(LOC(LEFTOP));         05761000
                     END;                                                       05761500
                     ELSE CALL_CONTEXT(CALL_LEVEL) = 2;                         05762000
                     CALL RETURN_STACK_ENTRY(LEFTOP);                           05762500
                     CALL PUSH_ARRAYNESS(CALL_LEVEL);                           05763000
                  END;                                                          05763500
               END;                                                             05764000
               DO;  /* 26 = XXND  */                                            05764500
                  CALL_CONTEXT(CALL_LEVEL) = 0;                                 05765000
                  CALL_LEVEL = SAVE_CALL_LEVEL(TAG);                            05765500
                  ARG_STACK_PTR = SAVE_ARG_STACK_PTR(TAG);                      05766000
               END;                                                             05766500
               DO;  /* 27 = XXAR  */                                            05767000
                  IF TAG ^= CALL_LEVEL THEN                                     05767500
                     CALL ERRORS(CLASS_BX,111);                                 05768000
                  IF ARG_STACK_PTR > ARG_STACK# THEN                            05768500
                     CALL ERRORS(CLASS_BS,103);                                 05769000
                  IF CALL_CONTEXT(CALL_LEVEL)=4 & ARG_COUNTER(CALL_LEVEL)>0 THEN05769500
                     LITTYPE = SYT_TYPE(ARG_POINTER(CALL_LEVEL));               05770000
                  ELSE LITTYPE = TYPE_BITS(1);                                  05770500
                  TMP, ARG_NAME(ARG_STACK_PTR) = SHR(TYPE_BITS(1),7);           05771000
                  TMP = TMP & X_BITS(1);                                        05771500
                  LITTYPE = LITTYPE & "7F";                                     05772000
/*DR120230*/      IF ARG_NAME(ARG_STACK_PTR) THEN
/*DR120230*/        RIGHTOP, ARG_STACK(ARG_STACK_PTR) = GET_OPERAND(1, 4, TMP); 05772500
/*DR120230*/      ELSE
                    RIGHTOP, ARG_STACK(ARG_STACK_PTR) = GET_OPERAND(1, 0, TMP); 05772500
                  ARG_TYPE(ARG_STACK_PTR) = TAG2;                               05773000
                  DO CASE CALL_CONTEXT(CALL_LEVEL) = 1;                         05773500
                     DO;  /* PROC, FUNC  */                                     05774000
          /*DR120223 - EMIT ERRORS FOR INCORRECT LITERAL ARGUMENT TYPE*/
          /*DR120223*/  IF TAG1=LIT THEN
          /*DR120223*/  DO CASE PACKTYPE(LITTYPE);
          /*DR120223*/     CALL ERRORS(CLASS_FT,101,''||
          /*DR120223*/        ARG_STACK_PTR+1-SAVE_ARG_STACK_PTR(CALL_LEVEL));
          /*DR120223*/     IF LIT1(GET_LITERAL(LOC(RIGHTOP)))^=2 THEN
          /*DR120223*/        CALL ERRORS(CLASS_FT,101,''||
          /*DR120223*/        ARG_STACK_PTR+1-SAVE_ARG_STACK_PTR(CALL_LEVEL));
          /*DR120223*/     IF LIT1(GET_LITERAL(LOC(RIGHTOP))) =2 THEN
          /*DR120223*/        CALL ERRORS(CLASS_FT,101,''||
          /*DR120223*/        ARG_STACK_PTR+1-SAVE_ARG_STACK_PTR(CALL_LEVEL));
          /*DR120223*/     IF (LIT1(GET_LITERAL(LOC(RIGHTOP)))&"3")^=1 THEN
          /*DR120223*/        CALL ERRORS(CLASS_FT,101,''||
          /*DR120223*/        ARG_STACK_PTR+1-SAVE_ARG_STACK_PTR(CALL_LEVEL));
          /*DR120223*/     CALL ERRORS(CLASS_FT,101,''||
          /*DR120223*/        ARG_STACK_PTR+1-SAVE_ARG_STACK_PTR(CALL_LEVEL));
          /*DR120223*/  END;
                        IF CALL_CONTEXT(CALL_LEVEL) ^= 4 THEN                   05774500
                           LITTYPE = TYPE(RIGHTOP);                             05775000
                        IF TAG2 THEN                                            05775500
                           CALL UPDATE_ASSIGN_CHECK(RIGHTOP);                   05776000
                        IF DOCOPY(CALL_LEVEL) > 0 THEN                          05776500
                           IF SDOLEVEL(CALL_LEVEL) = CALL_LEVEL THEN            05777000
                              DO CASE DOFORM(CALL_LEVEL);                       05777500
                                 RIGHTOP = GEN_ARRAY_TEMP(RIGHTOP, LITTYPE);    05778000
                                 ;                                              05778500
                  /*CR12935   REMOTE AGGREGATE DATA BEING PASSED AS INPUT    */
                  /*CR12935   PARAMETER MUST BE COPIED TO THE STACK - ALSO   */
                  /*CR12935   DO THIS FOR REMOTE #D DATA.                    */
                  /*CR12935*/   IF CHECK_REMOTE(RIGHTOP) | (DATA_REMOTE &
                  /*CR23935*/   (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)) |
                                 TYPE(RIGHTOP)^=LITTYPE|
                                    COPY(RIGHTOP) ^= DOCOPY(CALL_LEVEL) THEN DO;05779500
                                    CALL EMIT_ARRAY_DO(CALL_LEVEL);             05780000
                                    CALL FREE_ARRAYNESS(RIGHTOP);               05780500
                                    RIGHTOP = GEN_ARRAY_TEMP(RIGHTOP, LITTYPE); 05781000
                                 END;                                           05781500
                              END;                                              05782000
                  /* THE ABOVE CODE DOES NOT HANDLE COPYING REMOTE   CR12935*/
                  /* INPUT STRUCTURES TO THE STACK, SO DO IT HERE.   CR12935*/
                        IF (TYPE(RIGHTOP)=STRUCTURE) & ^TAG2 &     /*CR12935*/
 /*DR111390*/           ^NAME_FUNCTION(RIGHTOP) THEN               /*CR12935*/
                        IF CHECK_REMOTE(RIGHTOP) | (DATA_REMOTE &  /*CR12935*/
                        (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D))/*CR12935*/
                        THEN                                       /*CR12935*/
                           /* DR111351 - SIZE(RIGHTOP) ASSIGN WAS REMOVED   */
                           /* SINCE IT WAS CORRECTLY SET IN AN EARLIER CALL */
                           /* TO SIZEFIX (VIA GET_OPERAND)                  */
                           RIGHTOP = STRUC_CONVERT(RIGHTOP);       /*CR12935*/
                        CALL SUBSCRIPT_RANGE_CHECK(RIGHTOP);                    05782500
                        ARG_STACK(ARG_STACK_PTR) = RIGHTOP;                     05783000
                        ARG_STACK_PTR = ARG_STACK_PTR + 1;                      05783500
                        ARG_COUNTER(CALL_LEVEL) = ARG_COUNTER(CALL_LEVEL) - 1;  05784000
                        ARG_POINTER(CALL_LEVEL) = ARG_POINTER(CALL_LEVEL) + 1;  05784500
                     END;                                                       05785000
                     DO;  /* READ, READALL, WRITE  */                           05785500
                        CALL SET_IO_LIST(ARG_STACK_PTR);                        05786000
                     END;                                                       05786500
                  END;                                                          05787000
               END;                                                             05787500
               ;   ;  /* 28 - 29  */                                            05788000
               DO;  /* 2A = TDEF  */                                            05788500
                  CALL BLOCK_OPEN;                                              05789000
               END;                                                             05789500
               DO;  /* 2B = MDEF  */                                            05790000
                  CALL BLOCK_OPEN;                                              05790500
               END;                                                             05791000
               DO;  /* 2C = FDEF  */                                            05791500
                  CALL BLOCK_OPEN;                                              05792000
               END;                                                             05792500
               DO;  /* 2D = PDEF  */                                            05793000
                  CALL BLOCK_OPEN;                                              05793500
               END;                                                             05794000
               DO;  /* 2E = UDEF  */                                            05794500
                  CALL BLOCK_OPEN(2);                                           05795000
               END;                                                             05795500
               DO;  /* 2F = CDEF  */                                            05796000
                  CALL BLOCK_OPEN(TRUE);                                        05796500
               END;                                                             05797000
               DO;  /* 30 = CLOS  */                                            05797500
                  CALL DECODEPIP(1);                                            05798000
 /?B /* CR11114 -- BFS/PASS INTERFACE; SVC PROCESSING   */
                  CLOSE_STMT = 1;
 ?/
                  IF OP1 ^= PROC_LEVEL(INDEXNEST) THEN                          05798500
                     CALL ERRORS(CLASS_BX,112);                                 05799000
                  CALL BLOCK_CLOSE;                                             05799500
               END;                                                             05800000
               DO;  /* 31 = EDCL  */                                            05800500
                  CALL RESUME_LOCCTR(NARGINDEX);                                05801000
                  CALL EMITC(STADDR, LINE#);                                     5801100
                  DECLMODE = FALSE;                                             05801500
 /?B /* CR11114 -- BFS/PASS INTERFACE; CONSTANT PROTECTION */
                  CALL EMIT_STORE_PROTECT(FALSE);
 ?/
               END;                                                             05802000
               DO;  /* 32 = RTRN  */                                            05802500
                  INDEX = PROC_LEVEL(INDEXNEST);                                05803000
                  IF NUMOP > 0 THEN DO;                                         05803500
                     OPTYPE, LITTYPE = SYT_TYPE(INDEX);                         05804000
                     IF OPTYPE ^< ANY_LABEL THEN                                05804500
                        CALL ERRORS(CLASS_PF,100);                              05805000
                     IF RETURN_FLAG THEN                                        05805500
                      GO TO EMIT_BRANCH;                                        05806000
                     RIGHTOP = GET_OPERAND(1);                                  05806500
                     DO CASE PACKTYPE(OPTYPE);                                  05807000
                        DO;  /* VECTOR - MATRIX  */                             05807500
                           LEFTOP = SET_OPERAND(INDEX);                         05808000
                           TEMPSPACE = ROW(LEFTOP) * COLUMN(LEFTOP);            05808500
                           CALL VECMAT_ASSIGN(LEFTOP, RIGHTOP);                 05809000
                           CALL RETURN_STACK_ENTRY(LEFTOP);                     05809500
                        END;                                                    05810000
                        DO;  /* BITS  */                                        05810500
                           IF SIZE(RIGHTOP) ^= SYT_DIMS(INDEX) THEN /*CR13211*/
                              CALL ERRORS(CLASS_YF,103);            /*CR13211*/
                           CALL FORCE_ACCUMULATOR(RIGHTOP, OPTYPE);             05811500
                           CALL DROP_REG(RIGHTOP);                              05812000
                           IF SIZE(RIGHTOP) > SYT_DIMS(INDEX) THEN              05812500
                              CALL BIT_MASK(AND, RIGHTOP, SYT_DIMS(INDEX));     05813000
                           CALL EMITRX(ST, REG(RIGHTOP), 0, TEMPBASE,           05813500
                              SHL(FIXARG1,1) + REGISTER_SAVE_AREA);             05814000
                        END;                                                    05814500
                        DO;  /* CHARACTER  */                                   05815000
                           LEFTOP = SET_OPERAND(INDEX);                         05815500
                           IF TYPE(RIGHTOP) ^= CHAR THEN                        05816000
                              RIGHTOP = NTOC(RIGHTOP);                          05816500
                           CALL CHAR_CALL(XXASN, LEFTOP, RIGHTOP, 0);           05817000
                           CALL RETURN_STACK_ENTRY(LEFTOP);                     05817500
                        END;                                                    05818000
                        DO;                                                     05818500
                           IF DATATYPE(OPTYPE)=SCALAR THEN                      05819000
                              TARGET_REGISTER = FR0;                            05819500
                           ELSE TARGET_REGISTER = -1;                           05820000
                           CALL FORCE_BY_MODE(RIGHTOP, OPTYPE);                 05820500
                           TARGET_REGISTER = REG(RIGHTOP);                      05821000
                           CALL OFF_TARGET(RIGHTOP);                            05821500
                           IF REG(RIGHTOP) ^= FR0 THEN                          05822000
                              CALL EMITRX(ST, REG(RIGHTOP), 0, TEMPBASE,        05822500
                                 SHL(FIXARG1,1)+REGISTER_SAVE_AREA);            05823000
                        END;                                                    05823500
                        DO;                                                     05824000
                           LEFTOP = SET_OPERAND(INDEX);                         05824500
                           CALL MOVE_STRUCTURE(LEFTOP, RIGHTOP);                05825000
                           CALL RETURN_STACK_ENTRY(LEFTOP);                     05827000
                        END;                                                    05827500
                     END;                                                       05828000
                     CALL DROPSAVE(RIGHTOP);                                    05828500
                     CALL RETURN_STACK_ENTRY(RIGHTOP);                          05829000
                  END;                                                          05829500
    EMIT_BRANCH:  RETURN_FLAG=FALSE;                                            05830000
                  CALL MARKER;                                                  05830500
                     CALL EMITBFW(ALWAYS, GETSTMTLBL(SYT_LABEL(INDEX)+1));      05831500
                  STOPPERFLAG = TRUE;                                           05832500
               END;                                                             05833000
               DO;  /* 33 = TDCL  */                                            05833500
                  CALL DECODEPIP(1);                                            05834000
                  CALL ALLOCATE_TEMPORARY(OP1);                                 05834500
               END;                                                             05835000
               DO;  /* 34 = WAIT  */                                            05835500

 /?P /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS  */
                 IF STATIC_BLOCK THEN DO;                                       05836000
                        WORK1 = PROGDATA ;                                      05837200
                        PROGDATA = PROGDATA + 2;                                05837250
                 END;/* STATIC BLOCK */                                         05837400
                 ELSE DO;                                                       05838000
                  EXTOP = GETFREESPACE(INTEGER, 2);                             05838500
                  WORK1 = DISP(EXTOP);                                          05839000
                 END;                                                           05839500
                  IF TAG > 0 THEN DO;                                           05840000
                     LHSPTR = 0;                                                05840500
                     CALL SETUP_TIME_OR_EVENT(DSCALAR, FR0, TAG=3, WORK1+1);    05841000
                  END;                                                          05841500
                  CALL DROP_PARM_STACK;                                         05842000
                  CALL MARKER;                                                  05842500
                 IF STATIC_BLOCK THEN DO;                                       05843000
                CALL SET_LOCCTR(DATABASE, WORK1);                               05843150
                   CALL EMITC(0,WAITNAME(TAG));                                 05843250
                   CALL RESUME_LOCCTR(NARGINDEX);                               05843350
                      CALL EMITRX(SVC, 0, 0, PRELBASE, WORK1);                  05843950
                 END;                                                           05844050
                  ELSE CALL GENSVC(WAITNAME(TAG), EXTOP);                       05846000
                  CALL CLEAR_SCOPED_REGS(2);                                    05846500
 ?/
 /?B /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS  */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05847000
               DO;  /* 35 = SGNL  */                                            05847500

 /?P /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  LEFTOP = GET_OPERAND(1, 0, 2);                                 5848000
                  CALL MARKER;                                                  05848500
                 IF STATIC_BLOCK THEN DO;                                       05849000
                        CALL SET_LOCCTR(DATABASE , PROGDATA);                   05850000
                     CALL EMITC(0, SGNLNAME(TAG));                              05850300
                     CALL GENEVENTADDR(LEFTOP);                                 05850400
                     CALL RESUME_LOCCTR(NARGINDEX);                             05850500
                        CALL EMITRX(SVC , 0, 0, PRELBASE, PROGDATA);            05851300
                        PROGDATA = LOCCTR(DATABASE);                            05851400
                 END;                                                           05851600
                 ELSE DO;                                                       05853000
                  EXTOP = GETFREESPACE(INTEGER, 2);                             05853500
                  CALL GENSVCADDR(LEFTOP, EXTOP, 1);                            05854000
                  CALL GENSVC(SGNLNAME(TAG), EXTOP);                            05854500
                 END;                                                           05855000
 ?/
 /?B /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05857000
               DO;  /* 36 = CANC  */                                            05857500
                   /* BFS BOS INTERFACE DIFFERENCE */
 /?P  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  CALL SETUP_CANC_OR_TERM(4);                                   05858000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05858500
               DO;  /* 37 = TERM  */                                            05859000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  CALL SETUP_CANC_OR_TERM(2);                                   05859500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05860000
               DO;  /* 38 = PRIO  */                                            05860500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  WORK2 = 10 + (NUMOP>1);                                       05861000
                  IF STATIC_BLOCK THEN                                          05861500
                           WORK1 = PROGDATA;                                    05862120
                 ELSE DO;                                                       05862200
                     EXTOP = GETFREESPACE(INTEGER, 1 + (NUMOP>1));              05863000
                     WORK1 = DISP(EXTOP);                                       05863500
                  END;                                                          05864000
                  CALL SETUP_PRIORITY(1);                                       05864500
                  LEFTOP = GETLABEL(2);                                         05864510
                  CALL MARKER;                                                  05865000
                 IF STATIC_BLOCK THEN DO;                                       05865500
                   CALL SET_LOCCTR(DATABASE, WORK1);                            05865710
                   CALL EMITC(0,WORK2);                                         05865810
                   IF NUMOP > 1 THEN                                            05865910
                     CALL GENEVENTADDR(LEFTOP);                                 05866010
                   CALL RESUME_LOCCTR(NARGINDEX);                               05866110
                      CALL EMITRX(SVC,0,0,PRELBASE,WORK1);                      05866910
                      PROGDATA = LOCCTR(DATABASE);                              05867010
                 END;                                                           05869500
                 ELSE DO;                                                       05870000
                  IF NUMOP > 1 THEN                                             05870500
                     CALL GENSVCADDR(LEFTOP,EXTOP,1);                           05871000
                  CALL GENSVC(WORK2, EXTOP);                                    05871500
                 END;                                                           05872000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS  */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05876500
               DO;  /* 39 = SCHD  */                                            05877000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS   */
                  LHSPTR = 1;                                                   05877500
                  TAGS = TAG & 3;                                               05878000
                  WORK2 = 1;                                                    05878500
                 IF STATIC_BLOCK THEN DO;                                       05879000
                     WORK1 = (PROGDATA + 1) & (^1);                             05879850
                     PROGDATA = WORK1 + 5;                                      05879900
                 END;                                                           05880500
                 ELSE DO;                                                       05881000
                  EXTOP = GETFREESPACE(INTEGER, 5);                             05881500
                  WORK1 = DISP(EXTOP);                                          05882000
                 END;                                                           05882500
                  IF (TAG&4) ^= 0 THEN                                          05883000
                     CALL SETUP_PRIORITY(2+(TAGS>0));                           05883500
                  IF TAGS > 0 THEN                                              05884000
                     CALL SETUP_TIME_OR_EVENT(DSCALAR, FR0, TAGS=3, WORK1+3);   05884500
                  IF (TAG & 4) ^= 0 THEN                                        05885000
                     LHSPTR = LHSPTR + 1;                                       05885500
                  TAGS = SHR(TAG, 4) & 3;                                       05886000
                  IF TAGS > 1 THEN                                              05886500
                     CALL SETUP_TIME_OR_EVENT(DSCALAR, FR2, 0);                 05887000
                  TAGS = SHR(TAG, 6) & 3;                                       05887500
                  IF TAGS > 0 THEN                                              05888000
                     CALL SETUP_TIME_OR_EVENT(DSCALAR, FR4, TAGS>1, WORK1+4);   05888500
                  LEFTOP = GETLABEL(1);                                         05889000
                  TMP = LOC2(LEFTOP);                                           05889500
                  TAGS = SHL((SYT_FLAGS(TMP)&LATCH_FLAG)^=0, 1) |               05890000
                     SYT_TYPE(TMP) = TASK_LABEL;                                05890500
                  CALL DROP_PARM_STACK;                                         05891000
                  CALL MARKER;                                                  05891500
                 IF STATIC_BLOCK THEN DO;                                       05892000
                       CALL SET_LOCCTR(DATABASE, WORK1);                        05892210
                    CALL EMITC(0, WORK2);                                       05892310
                    CALL EMITC(0, (SHL(TAG, 2) + TAGS) & "3ED");                05892410
                    CALL GENEVENTADDR(LEFTOP);                                  05892510
                    CALL RESUME_LOCCTR(NARGINDEX);                              05892610
                        CALL EMITRX(SVC, 0, 0, PRELBASE, WORK1);                05893210
                 END;                                                           05895500
                 ELSE DO;                                                       05896000
                  CALL FORCE_NUM(LINKREG, (SHL(TAG, 2) + TAGS) & "3ED");        05896500
                  INX_CON(EXTOP) = 1;                                           05897000
                  CALL EMITOP(STH, LINKREG, EXTOP);                             05897500
                  CALL GENSVCADDR(LEFTOP, EXTOP, 2);                            05898000
                  CALL GENSVC(WORK2, EXTOP);                                    05898500
                 END;                                                           05899000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05902000
               ;  ;  /* 3A - 3B  */                                             05902500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY     */
               DO;  /* 3C = ERON  */                                            05903000
                  HARDWARE_INTERRUPT:                                           05903500
                     PROCEDURE BIT(1);                                          05904000
                        IF (VAL(LEFTOP) & "3F") ^= 3 THEN RETURN FALSE;         05904500
                        TAG3 = SHR(VAL(LEFTOP), 6) & "3F";                      05905000
                        IF TAG3 = 4 THEN WORK1 = "800";                         05905500
                        ELSE IF TAG3 = 5 THEN WORK1 = "100";                    05906000
                        ELSE IF TAG3 = 9 THEN WORK1 = "200";                    05906500
                        ELSE RETURN FALSE;                                      05907000
                        RETURN TRUE;                                            05907500
                     END HARDWARE_INTERRUPT;                                    05908000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
               DO;   /*# 3C = ERON #*/
                  WORK1 = SYT_TYPE(PROC_LEVEL(INDEXNEST));
                  IF (WORK1 ^= PROG_LABEL) & (WORK1 ^= TASK_LABEL) THEN
                     CALL ERRORS(CLASS_PR, 3, '');
                     /* ON ERROR IS ONLY LEGAL IN PROGRAM OR TASKS BLOCKS */
                  IF (TAG > 0) | (NUMOP = 3) THEN
                     CALL ERRORS(CLASS_PR, 4, '');
                     /* ONLY ON ERROR <STATEMENT> FORM IS LEGAL */
 ?/
                  LITTYPE = INTEGER;                                            05908500
                  LEFTOP = GET_OPERAND(1);                                      05909000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
                  CALL SET_ERRLOC(LEFTOP, TAG3);                                05909500
                 IF TAG ^= 3 THEN DO;                                           05910000
                  CALL CHECKPOINT_REG(LINKREG);                                 05911500
                  INX_CON(LEFTOP) = 1;                                          05912000
                  IF TAG = 0 THEN DO;                                           05912500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
                  IF (VAL(LEFTOP) ^= 255) | (TAG3 ^= 63) THEN
                     CALL ERRORS(CLASS_PR, 4, '');
                     /* ONLY ON ERROR(*:*), ON ERROR IS LEGAL */
                  IF MAXERR(INDEXNEST) THEN   /* MAKE SURE ONLY ONE ON ERROR */
                     CALL ERRORS(CLASS_PR, 5, '');
                  ELSE
                     MAXERR(INDEXNEST) = 1;
               /* EMIT BRANCH AT START OF PROGRAM OR TASK CSECT */
 ?/
                     FIRSTLABEL = GETSTATNO;                                    05913000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY  */
                     CALL EMITPFW(LA, LINKREG, GETSTMTLBL(FIRSTLABEL));         05913500
                     CALL EMITOP(STH, LINKREG, LEFTOP);                         05914000
                  END;                                                          05914500
                  ELSE DO;                                                      05915000
                     TAG = TAG | 1;                                             05915500
                     IF NUMOP = 2 THEN DO;                                      05916000
                        RIGHTOP = GET_OPERAND(2);                               05916500
                        IF TAG2 = 0 THEN TAG2 = 3;                              05917000
                        TAG = SHL(TAG2, 2) + TAG;                               05917500
                        CALL FORCE_ADDRESS(LINKREG, RIGHTOP);                   05918000
                        CALL EMITOP(STH, LINKREG, LEFTOP);                      05918500
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       05919000
                     END;                                                       05919500
                  END;                                                          05920000
                  INX_CON(LEFTOP) = 0;                                          05920500
                  CALL LOAD_NUM(LINKREG, SHL(TAG, 12) + VAL(LEFTOP));           05921000
                  CALL EMITOP(STH, LINKREG, LEFTOP);                            05921500
                  IF HARDWARE_INTERRUPT THEN DO;                                05922000
                     USAGE(LINKREG) = 0;                                        05922500
                     CALL EMITRR(BALR, LINKREG, 0);                             05923000
                     IF (TAG&3) = 3 THEN DO;                                    05923500
                        WORK1 = ^WORK1;                                         05924000
                        OPCODE = AND;                                           05924500
                     END;                                                       05925000
                     ELSE OPCODE = XOR;                                         05925500
                     RIGHTOP = GET_INTEGER_LITERAL(WORK1);                      05926000
                     CALL SAVE_LITERAL(RIGHTOP, DINTEGER);                      05926500
                     CALL EMIT_BY_MODE(OPCODE, LINKREG, RIGHTOP, DINTEGER);     05927000
                     CALL RETURN_STACK_ENTRY(RIGHTOP);                          05927500
                     CALL EMITRR(SPM, 0, LINKREG);                              05928000
                  END;                                                          05928500
                  IF (TAG&3) = 0 THEN DO;                                       05929000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY  */
                  CALL PUSH_LOCCTR(0);
                  CALL EMITBFW(ALWAYS, GETSTMTLBL(FIRSTLABEL));
                  CALL POP_LOCCTR;
               /* EMIT BRANCH AROUND ON ERROR STATEMENT */
 ?/
                     CALL MARKER;                                               05939500
                     CALL EMITBFW(ALWAYS, GETLABEL(2));                         05940000
                     CALL SET_LABEL(FIRSTLABEL);                                05940500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
                  END;                                                          05941000
                 END;                                                           05941500
                 ELSE DO;                                                       05942000
                  CALL EMITOP(ZH, 0, LEFTOP);                                   05942500
                  IF HARDWARE_INTERRUPT THEN DO;                                05943000
                     USAGE(LINKREG), USAGE(FIXARG1) = 0;                        05943500
                     CALL EMITRR(BALR, LINKREG, 0);                             05944000
                     IF OLD_LINKAGE THEN                                        05944500
                        WORK2 = SHL(LINKREG, 1) + REGISTER_SAVE_AREA;           05945000
                     ELSE WORK2 = NEW_STACK_LOC;                                05945500
                     CALL EMITRX(L, FIXARG1, 0, TEMPBASE, WORK2);               05946000
                     CALL EMITRR(XR, FIXARG1, LINKREG);                         05946500
                     RIGHTOP = GET_INTEGER_LITERAL(WORK1);                      05947000
                     CALL SAVE_LITERAL(RIGHTOP, DINTEGER);                      05947500
                     CALL EMIT_BY_MODE(AND, FIXARG1, RIGHTOP, DINTEGER);        05948000
                     CALL RETURN_STACK_ENTRY(RIGHTOP);                          05948500
                     CALL EMITRR(XR, FIXARG1, LINKREG);                         05949000
                     CALL EMITRR(SPM, 0, FIXARG1);                              05949500
                  END;                                                          05950000
                 END;                                                           05950500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY  */
               /* EMIT PROLOGUE SANS SVC -1 */
                  CALL EMITP(LHI, PROGBASE, 0, EXTSYM, DATABASE);
                  CALL EMITRX(STH, PROGBASE, 0, TEMPBASE, NEW_GLOBAL_BASE);
                  CALL EMITPDELTA;
                  CALL EMITP(IAL, TEMPBASE, 0, 0, 0);
                  CALL EMITRX(LA, PROCBASE, 0, PROGBASE, SYT_ADDR(PROC_LEVEL(
                     INDEXNEST)) );
                  CALL EMITRX(STH, PROCBASE, 0, TEMPBASE, NEW_LOCAL_BASE);
                  CALL EMITC(PROLOG, 1);
 ?/
                  CALL RETURN_STACK_ENTRY(LEFTOP);                              05951000
               END;                                                             05951500
               DO;  /* 3D = ERSE  */                                            05952000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS  */
                  LITTYPE = INTEGER;                                            05952500
                  LEFTOP = GET_OPERAND(1);                                      05953000
                  CALL MARKER;                                                  05953500
                  VAL(LEFTOP) = SHL(20, 16) + SHL(VAL(LEFTOP), 8) + TAG3;       05954000
                  CALL SAVE_LITERAL(LEFTOP, DINTEGER);                          05954500
                  CALL EMITOP(SVC, 0, LEFTOP);                                  05955000
                  CALL RETURN_STACK_ENTRY(LEFTOP);                              05957000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; REAL-TIME STATEMENTS  */
                  GO TO UNIMPLEMENTED;
 ?/
               END;                                                             05957500
               ;  ;  /* 3E - 3F  */                                             05958000
               DO;  /* 40 = MSHP  */                                            05958500
                  CALL DECODEPIP(1);                                            05959000
                  ROW(0) = SHR(OP1, 8) & "FF";                                  05959500
                  COLUMN(0) = OP1 & "FF";                                       05960000
                  OPTYPE = MATRIX;                                              05960500
            VMSHP_COM:                                                          05961000
                  OPTYPE = NEWPREC(TAG3) | OPTYPE;                              05961500
                  TEMPSPACE = ROW(0) * COLUMN(0);                               05962000
                  RESULT = GET_VM_TEMP;                                         05962500
                  SF_DISP = BIGHTS(OPTYPE);                                     05963000
                  INX_CON(RESULT) = SF_DISP;                                    05963500
                  DO ARG# = SAVE_ARG_STACK_PTR(TAG) TO ARG_STACK_PTR - 1;       05964000
                     CALL SHAPING_FUNCTIONS(ARG#);                              05964500
                  END;  /* DO ARG# */                                           05965000
                  INX_CON(RESULT) = 0;                                          05965500
                  CALL SETUP_VAC(RESULT);                                        5966000
               END;                                                             05966500
               DO;  /* 41 = VSHP  */                                            05967000
                  CALL DECODEPIP(1);                                            05967500
                  ROW(0) = 1;                                                   05968000
                  COLUMN(0) = OP1;                                              05968500
                  OPTYPE = VECTOR;                                              05969000
                  GO TO VMSHP_COM;                                              05969500
               END;                                                             05970000
               DO;  /* 42 = SSHP  */                                            05970500
                  OPTYPE = SCALAR;                                              05971000
            ISSHP_COM:                                                          05971500
                  ARG_POINTER(CALL_LEVEL) = SF_RANGE_PTR;                       05972000
                  AREA = 1;                                                     05972500
                  DO OP2 = 1 TO NUMOP;                                          05973000
                     CALL DECODEPIP(OP2);                                       05973500
                     IF OP2 = 1 THEN DO;                                        05974000
                        OPTYPE = NEWPREC(TAG3) | OPTYPE;                        05974500
                        ARRCONST = -1;                                          05975000
                     END;                                                       05975500
                     ELSE ARRCONST = ARRCONST * OP1 - 1;                        05976000
                     IF SF_RANGE_PTR > CALL_LEVEL# THEN                         05976500
                        CALL ERRORS(CLASS_BS,118);                              05977000
                     SF_RANGE(SF_RANGE_PTR) = OP1;                              05977500
                     SF_RANGE_PTR = SF_RANGE_PTR + 1;                           05978000
                     AREA = AREA * OP1;                                         05978500
                  END;                                                          05979000
                  RESULT = GETFREESPACE(OPTYPE, AREA);                          05979500
                  SF_DISP = BIGHTS(OPTYPE);                                     05980000
                  DO ARG# = SAVE_ARG_STACK_PTR(TAG) TO ARG_STACK_PTR - 1;       05980500
                     CALL SHAPING_FUNCTIONS(ARG#);                              05981000
                  END;  /* DO ARG#  */                                          05981500
                  INX_CON(RESULT) = ARRCONST * SF_DISP;                         05982000
                  VAL(RESULT) = ARG_POINTER(CALL_LEVEL);                        05982500
                  COPY(RESULT) = NUMOP;                                         05983000
                  CALL SETUP_VAC(RESULT);                                        5983500
               END;                                                             05984000
               DO;  /* 43 = ISHP  */                                            05984500
                  OPTYPE = INTEGER;                                             05985000
                  GO TO ISSHP_COM;                                              05985500
               END;                                                             05986000
               ;  /* 44  */                                                     05986500
               DO;  /* 45 = SFST  */                                            05987000
                  IF TAG > CALL_LEVEL# THEN                                     05987500
                     CALL ERRORS(CLASS_BS,101);                                 05988000
                  SAVE_CALL_LEVEL(TAG) = CALL_LEVEL;                            05988500
                  SAVE_ARG_STACK_PTR(TAG) = ARG_STACK_PTR;                      05989000
                  CALL_LEVEL = TAG;                                             05989500
                  CALL_CONTEXT(CALL_LEVEL) = 2;                                 05990000
                  DOCOPY(CALL_LEVEL), DOFORM(CALL_LEVEL) = 0;                   05990500
               END;                                                             05991000
               DO;  /* 46 = SFND  */                                            05991500
                  CALL_CONTEXT(CALL_LEVEL) = 0;                                 05992000
                  CALL_LEVEL = SAVE_CALL_LEVEL(TAG);                            05992500
                  ARG_STACK_PTR = SAVE_ARG_STACK_PTR(TAG);                      05993000
               END;                                                             05993500
               DO;  /* 47 = SFAR  */                                            05994000
                  IF TAG ^= CALL_LEVEL THEN                                     05994500
                     CALL ERRORS(CLASS_QD,100);                                 05995000
                  IF ARG_STACK_PTR > ARG_STACK# THEN                            05995500
                     CALL ERRORS(CLASS_BS,103);                                 05996000
                  LITTYPE = TYPE_BITS(1);                                       05996500
                  IF X_BITS(1) THEN                                             05997000
                     RIGHTOP = GET_OPERAND(1, 3, BY_NAME_TRUE); /*CR13616*/     05997500
                  ELSE RIGHTOP = GET_OPERAND(1);                                05998000
 /*DR111387*/     IF DOCOPY(CALL_LEVEL) > 0 THEN DO;                            05998500
                     IF DOFORM(CALL_LEVEL) ^= 2 THEN                            05999000
                        RIGHTOP = GEN_ARRAY_TEMP(RIGHTOP, TYPE(RIGHTOP));       05999500
 /* HANDLE REMOTE PASS-BY-REF FOR QSHAPQ AND LFNC (NOT SIZE): COPY TO STACK*/
 /*DR111387*/        ELSE IF ^TAG2 THEN                     /*RESTRICT SIZE*/
 /*DR111387*/        IF CHECK_REMOTE(RIGHTOP) | (DATA_REMOTE &
 /*DR111387*/           (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)) THEN DO;
 /*DR111387*/           CALL EMIT_ARRAY_DO(CALL_LEVEL);
 /*DR111387*/           CALL FREE_ARRAYNESS(RIGHTOP);
 /*DR111387*/           RIGHTOP = GEN_ARRAY_TEMP(RIGHTOP, TYPE(RIGHTOP));
 /*DR111387*/        END;
 /*DR111387*/     END;
                  CALL SUBSCRIPT_RANGE_CHECK(RIGHTOP);                          06000000
                  ARG_STACK(ARG_STACK_PTR) = RIGHTOP;                           06000500
                  IF NUMOP = 2 THEN DO;                                         06001000
                     CALL DECODEPIP(2);                                         06001500
                     ARG_TYPE(ARG_STACK_PTR) = OP1;                             06002000
                  END;                                                          06002500
                  ELSE ARG_TYPE(ARG_STACK_PTR) = 1;                             06003000
                  ARG_STACK_PTR = ARG_STACK_PTR + 1;                            06003500
               END;                                                             06004000
               ;  ;  /* 48 - 49 */                                              06004500
               DO;  /* 4A = BFNC  */                                            06005000
                  IF NUMOP > 0 THEN LITTYPE = TYPE_BITS(1);                     06005500
                  OPCODE = BIFOPCODE(TAG);                                      06006000
                  DO CASE BIFCLASS(TAG);                                        06006500
                     DO CASE BIFTYPE(TAG); /* ARITHMETIC FUNCTIONS */           06007000
                        DO; /* NUMBER CONVERSION */                             06007500
                           RESULT = GET_OPERAND(1);                             06008000
                           IF TYPE(RESULT)=SCALAR & TAG=29 /* FLOOR */ THEN DO; 06008010
                              CALL FORCE_ACCUMULATOR(RESULT);                   06008020
                              TMP = FINDAC(RCLASS(INTEGER));                    06008030
                              CALL EMITRR(CVFX, TMP, REG(RESULT));              06008040
                              CALL DROP_REG(RESULT);                            06008050
                              CALL SET_RESULT_REG(RESULT, INTEGER, TMP);        06008060
                              CALL BIT_MASK(AND, RESULT, HALFWORDSIZE);         06008070
                           END;                                                 06008080
                           ELSE                                                 06008090
                           IF DATATYPE(TYPE(RESULT)) = SCALAR THEN DO;          06008500
                              OPTYPE = TYPE(RESULT);                            06009000
                              TARGET_REGISTER = FR0;                            06009500
                              CALL FORCE_ACCUMULATOR(RESULT);                   06010500
                              CALL OFF_TARGET(RESULT);                          06011000
                              CALL GENLIBCALL(SORD((OPTYPE&8)^=0) ||            06011500
                                    BIFNAMES(OPCODE));                          06013000
                              CALL SET_RESULT_REG(RESULT, DINTEGER);            06014000
                           END;                                                 06015000
                        END;                                                    06015500
                        DO; /* INTEGER ARITHMETIC */                            06016000
                           LITTYPE = INTEGER;                                   06016500
                           CALL INTEGER_DIVIDE;                                 06017000
                           RESULT = LEFTOP;                                     06017500
                        END;                                                    06018000
                        DO;  /* BINARY OPERATORS */                             06018500
                           CALL GET_OPERANDS;                                   06019000
                           TMP = SHL(DATATYPE(OPTYPE) ^= SCALAR, 1);            06019500
                           TARGET_REGISTER = BIFREG(TMP);                       06020000
                           CALL FORCE_ACCUMULATOR(LEFTOP, OPTYPE);              06020500
                           CALL STACK_TARGET(LEFTOP);                            6021000
                           TARGET_REGISTER = BIFREG(TMP+1);                     06021500
                           CALL FORCE_ACCUMULATOR(RIGHTOP, OPTYPE);             06022000
                           CALL STACK_TARGET(RIGHTOP);                           6022500
                           CALL DROP_PARM_STACK;                                 6023000
                           CALL GENLIBCALL(TYPES(SELECTYPE(OPTYPE)) ||          06023500
                              BIFNAMES(OPCODE));                                06024000
                           RESULT = GET_STACK_ENTRY;                            06024500
                           CALL SET_RESULT_REG(RESULT, OPTYPE);                 06025000
                        END;                                                    06025500
                        DO;  /* INLINE OPERATORS  */                            06026000
                           IF TAG = 1 /* ABS */ THEN DO;                        06026500
                              CALL GET_OPERANDS;                                06026510
                              TO_BE_MODIFIED = TRUE;                            06026520
                              CALL FORCE_ACCUMULATOR(LEFTOP);                   06026530
                              IF REG(LEFTOP) ^= CCREG THEN                      06026540
                                 CALL ARITH_BY_MODE(TEST,LEFTOP,LEFTOP,OPTYPE); 06026550
                              CALL EMITLFW(GQ, 2);                              06026580
                              CALL ARITH_BY_MODE(OPCODE,LEFTOP,LEFTOP,OPTYPE);  06026590
                           END;                                                 06026600
                           ELSE CALL EVALUATE(OPCODE);                          06026610
                           RESULT = LEFTOP;                                     06027500
                        END;                                                    06028000
                        DO; /* TEST FUNCS */                                    06028500
                           LEFTOP = GET_OPERAND(1);                             06029000
                           OPTYPE = TYPE(LEFTOP);                               06029500
                           TO_BE_MODIFIED = TRUE;                               06030000
                           CALL FORCE_ACCUMULATOR(LEFTOP);                      06030500
                           DO CASE SHR(OPCODE, 1);                              06031000
                              DO;  /* ODD  */                                   06031500
                                 RESULT = LEFTOP;                               06032000
                                 CALL BIT_MASK(AND, RESULT, 1);                 06032500
                                 TYPE(RESULT) = BOOLEAN | (TYPE(RESULT)&8);     06033000
                                 SIZE(RESULT) = 1;                              06033500
                              END;                                              06034000
                              DO;  /* SIGN, SIGNUM  */                          06034500
                                 RESULT = GET_LIT_ONE(OPTYPE);                  06035000
                                 CALL FORCE_ACCUMULATOR(RESULT);                06035500
                                IF REG(LEFTOP) ^= CCREG THEN                     6035600
                                 CALL ARITH_BY_MODE(TEST, LEFTOP, LEFTOP,       06036000
                                      OPTYPE);                                  06036500
                                 CALL DROP_REG(LEFTOP);                         06037000
                                 CALL RETURN_STACK_ENTRY(LEFTOP);               06037500
                                 FIRSTLABEL = GETSTATNO;                        06039000
                                 DO CASE OPCODE & 1;                            06039500
                                    DO;  /* SIGN  */                            06040000
                                       CALL EMITBFW(GQ, GETSTMTLBL(FIRSTLABEL));06040500
                                       CALL ARITH_BY_MODE(BIFOPCODE(1), RESULT, 06041000
                                            RESULT, OPTYPE);                    06041500
                                    END;                                        06042000
                                    DO;                                         06042500
                                       CALL EMITBFW(GT, GETSTMTLBL(FIRSTLABEL));06043000
                                       SECONDLABEL = GETSTATNO;                 06043500
                                       CALL EMITBFW(EQ,GETSTMTLBL(SECONDLABEL));06044000
                                       CALL ARITH_BY_MODE(BIFOPCODE(1), RESULT, 06044500
                                            RESULT, OPTYPE);                    06045000
                                       CALL EMITBFW(ALWAYS,                     06045500
                                            GETSTMTLBL(FIRSTLABEL));            06046000
                                       CALL SET_LABEL(SECONDLABEL, 1);          06046500
                                       CALL ARITH_BY_MODE(MINUS, RESULT,        06047000
                                            RESULT, OPTYPE);                    06047500
                                    END;                                        06048000
                                 END;                                           06048500
                                 CALL SET_LABEL(FIRSTLABEL, 1);                 06049000
                              END;                                              06049500
                           END;                                                 06050000
                        END;                                                    06050500
                        DO;  /* SHIFT FUNCTIONS */                              06051000
                           LITTYPE = INTEGER;                                   06051500
                           CALL GET_OPERANDS;                                   06052000
                           TO_BE_MODIFIED = TRUE;                               06052500
                           CALL FORCE_ACCUMULATOR(LEFTOP);                      06053000
    /*DR109063*/           IF FORM(RIGHTOP) = LIT THEN DO;
    /*DR109063*/             IF (VAL(RIGHTOP) < 1) | (VAL(RIGHTOP) > 63) THEN
    /*DR109063*/               CALL ERRORS(CLASS_F,103);
    /*DR109063*/           END;
    /*DR109063*/           IF (FORM(RIGHTOP) = LIT) &                           06053500
    /*DR109063*/              ((VAL(RIGHTOP) & "3F") < 56)
    /*DR109063*/           THEN
                              CALL EMITP(SHIFTOP(OPCODE), REG(LEFTOP),          06054000
                                 0, SHCOUNT, VAL(RIGHTOP)&"3F");                06054500
                           ELSE DO;                                             06055000
                              CALL FORCE_ACCUMULATOR(RIGHTOP, INTEGER);         06055500
                              CALL EMITP(SHIFTOP(OPCODE), REG(LEFTOP),          06056000
                                 REG(RIGHTOP), SHCOUNT, 0);                     06056500
                              CALL DROP_REG(RIGHTOP);                           06057000
                           END;                                                 06057500
                           IF OPCODE=0 & TYPE(LEFTOP)=INTEGER THEN              06057510
                              CALL BIT_MASK(AND,LEFTOP,HALFWORDSIZE);           06057520
                           /*ADD A NOP INTERMEDIATE WORD AFTER THE SRA THAT */
                           /*IS EMITTED FOR THE SHR BUILT-IN FUNCTION       */
                           /*TO PREVENT THE COMPILER FROM COMBINING IT WITH */
                           /*ANY SLL INSTRUCTION THAT MIGHT FOLLOW.         */
                           ELSE IF OPCODE=0 THEN CALL EMIT_NOP;   /*DR120266*/
                           CALL RETURN_STACK_ENTRY(RIGHTOP);                    06058000
                           CALL UNRECOGNIZABLE(REG(LEFTOP));                    06058500
                           RESULT = LEFTOP;                                     06059000
                        END;                                                    06059500
                        DO;  /* 3-ARGUMENT FUNCTIONS */                         06060000
                           LITTYPE = SCALAR;                                    06060500
                           LEFTOP = GET_OPERAND(1);                             06061000
                           RIGHTOP = GET_OPERAND(2);                            06061500
                           EXTOP = GET_OPERAND(3);                              06062000
                           OPTYPE = TYPE(LEFTOP) | TYPE(RIGHTOP) | TYPE(EXTOP); 06062500
                          IF NEW_INSTRUCTIONS & OPTYPE = SCALAR THEN DO;        06063000
                           TARGET_REGISTER = BESTAC(DOUBLE_FACC);               06063500
                           TO_BE_MODIFIED = TRUE;                               06064000
                           CALL FORCE_ACCUMULATOR(LEFTOP, OPTYPE);              06064500
                           TARGET_REGISTER = TARGET_REGISTER | 1;               06065000
                           CALL FORCE_ACCUMULATOR(RIGHTOP, OPTYPE);             06065500
                           CALL OFF_TARGET(RIGHTOP);                            06066000
                           IF FORM(EXTOP) = VAC THEN                            06066500
                              CALL CHECKPOINT_REG(REG(EXTOP), TRUE);             6067000
                           CALL ARITH_BY_MODE(MIDVAL, LEFTOP, EXTOP, OPTYPE);   06067500
                           CALL RETURN_STACK_ENTRIES(RIGHTOP, EXTOP);           06068000
                           RESULT = LEFTOP;                                     06068500
                          END;                                                  06069000
                          ELSE DO;                                              06069500
                           TARGET_REGISTER = FR0;                               06070000
                           CALL FORCE_ACCUMULATOR(LEFTOP, OPTYPE);              06070500
                           TARGET_REGISTER = FR2;                               06071000
                           CALL FORCE_ACCUMULATOR(RIGHTOP, OPTYPE);             06071500
                           TARGET_REGISTER = FR4;                               06072000
                           CALL FORCE_ACCUMULATOR(EXTOP, OPTYPE);               06072500
                           CALL DROP_VAC(LEFTOP);                               06073000
                           CALL DROP_VAC(RIGHTOP);                              06073500
                           CALL DROP_VAC(EXTOP);                                06074000
                           TARGET_REGISTER = -1;                                06074500
                           CALL GENLIBCALL(SORD((OPTYPE&8)^=0) ||               06075000
                              BIFNAMES(OPCODE));                                06075500
                           RESULT = GET_STACK_ENTRY;                            06076000
                           CALL SET_RESULT_REG(RESULT, OPTYPE);                 06076500
                          END;                                                  06077000
                        END;                                                    06077500
                     END;  /* ARITHMETIC FUNCTIONS */                           06078500
                     DO; /* ALGEBRAIC FUNCTIONS */                              06079000
                        IF NUMOP > 0 THEN DO;                                   06079500
                           RIGHTOP = GET_OPERAND(1);                            06080000
                           TARGET_REGISTER = FR0;                               06080500
                           CALL FORCE_ACCUMULATOR(RIGHTOP);                     06081000
                           CALL OFF_TARGET(RIGHTOP);                            06081500
                           OPTYPE = TYPE(RIGHTOP);                              06082000
                           CALL RETURN_STACK_ENTRY(RIGHTOP);                    06082500
                        END;                                                    06083000
                        ELSE OPTYPE = BIFTYPE(TAG);                             06083500
                        CALL GENLIBCALL(SORD((OPTYPE&8)^=0)||                   06084000
                              BIFNAMES(OPCODE));                                06084500
                        IF BIFTYPE(TAG) < 32 THEN                               06085000
                           RESULT = GET_VAC(FR0, OPTYPE);                       06085500
                        ELSE DO CASE BIFTYPE(TAG) - 32;                         06086000
                           DO;                                                  06086500
                              CALL SETUP_VAC(GET_VAC(FR2, OPTYPE), 1);          06087000
                              RESULT = GET_VAC(FR0, OPTYPE);                    06087500
                           END;                                                 06088000
                           DO;  /* OPERANDS REVERSED */                         06088500
                              CALL SETUP_VAC(GET_VAC(FR0, OPTYPE), 1);          06089000
                              RESULT = GET_VAC(FR2, OPTYPE);                    06089500
                           END;                                                 06090000
                        END;                                                    06090500
                        IF NUMOP = 0 THEN                                       06091000
                           R_TYPE(REG(RESULT)) = OPTYPE | 8;                    06091500
                     END;  /* ALGEBRAIC FUNCTIONS */                            06092000
                     DO;  /* VECTOR-MATRIX FUNCTIONS */                         06092500
                        CALL ARG_ASSEMBLE;                                      06093000
                        IF PACKTYPE(BIFTYPE(TAG)) = VECMAT THEN DO;             06093500
                           IF OPCODE = XMTRA THEN DO;                           06094000
                              ROW(0) = COLUMN(LEFTOP);                          06094500
                              COLUMN(0) = ROW(LEFTOP);                          06095000
                           END;                                                 06095500
                           ELSE IF OPCODE = XMINV THEN DO;                      06096000
                              RIGHTOP = GETINVTEMP(OPTYPE, ROW(0));             06096500
                              CALL DROPSAVE(RIGHTOP);                           06097000
                           END;                                                 06097500
                           TEMPSPACE = ROW(0) * COLUMN(0);                      06098000
                           CALL MAT_TEMP;                                       06098500
                        END;                                                    06099000
                        ELSE DO;                                                06099500
                           TEMPSPACE = ROW(0) * COLUMN(0);                      06100000
                           IF OPCODE = XMDET THEN DO;                           06100500
                              RIGHTOP = GETFREESPACE(OPTYPE, TEMPSPACE);        06101000
                              CALL DROPSAVE(RIGHTOP);                           06101500
                           END;                                                 06102000
                           RESULT = GET_STACK_ENTRY;                            06102500
                           CALL VMCALL(OPCODE, (OPTYPE&8) ^= 0, 0, LEFTOP,      06103000
                              RIGHTOP,0);                                       06103500
                           CALL SET_RESULT_REG(RESULT, OPTYPE&8 | SCALAR);      06104000
                           CALL RETURN_STACK_ENTRIES(LEFTOP,RIGHTOP);           06104500
                        END;                                                    06105000
                     END;                                                       06105500
                     DO;  /* CHARACTER FUNCTIONS */                             06106000
                        CALL GET_CHAR_OPERANDS;                                 06106500
                        IF BIFTYPE(TAG) = CHAR THEN DO;                         06107000
                           RESULT = GETFREESPACE(CHAR, 257);                    06107500
                           CALL CHAR_CALL(OPCODE, RESULT, LEFTOP, RIGHTOP);     06108000
                           SIZE(RESULT) = 255;                                  06108500
                           LASTRESULT = RESULT;                                 06109000
                        END;                                                    06109500
                        ELSE DO;                                                06110000
                           RESULT = GET_STACK_ENTRY;                            06110500
                           IF OPCODE = 0 THEN DO;  /* LENGTH  */                06111000
                              IF FORM(LEFTOP) = LIT THEN DO;                    06111500
                                 FORM(RESULT) = LIT;                            06112000
                                 TYPE(RESULT) = INTEGER;                        06112500
                                 VAL(RESULT) = LENGTH(DESC(VAL(LEFTOP)));       06113000
                                 LOC(RESULT) = -1;                              06113500
                              END;                                              06114000
                              ELSE DO;                                          06114500
                                 CALL RETURN_STACK_ENTRY(RESULT);               06115000
                                 RESULT = GET_VAC(-1);                          06115010
                                 CALL GUARANTEE_ADDRESSABLE(LEFTOP, LH);        06116000
                                 CALL EMITOP(LH, REG(RESULT), LEFTOP);          06116500
                                 CALL EMITP(NHI, REG(RESULT), 0, 0, "FF");      06117500
                                 CALL DROP_INX(LEFTOP);                         06118000
                              END;                                              06119500
                           END;                                                 06120000
                           ELSE DO;                                             06120500
                              CALL CHAR_CALL(OPCODE, 0, LEFTOP, RIGHTOP);       06121000
                              CALL SET_RESULT_REG(RESULT, INTEGER);             06121500
                           END;                                                 06122000
                        END;                                                    06122500
                        CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);             06123000
                     END;                                                       06123500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; SUPERVISOR BUILT-INS */
                     DO;  /* SUPERVISOR BUILT IN FUNCTIONS  */                  06124000
                        RESULT = GET_INTEGER_LITERAL(SHL(OPCODE&"FE",7) + 22 +  06124500
                           (OPCODE&1));                                         06125000
                        CALL SAVE_LITERAL(RESULT, INTEGER);                     06125500
                        CALL SAVE_REGS(FIXARG1, 1);                             06126000
                        CALL EMITOP(SVC, 0, RESULT);                            06126500
                        OPTYPE = BIFTYPE(TAG);                                  06127000
                        CALL SET_RESULT_REG(RESULT, OPTYPE);                    06127500
                     END;                                                       06128500
                     DO;  /* PARAMETERIZED SUPERVISOR BUILT IN FUNCTIONS */     06129000
                        CALL SAVE_REGS(FIXARG1, 1);                             06129500
                        LEFTOP = GETLABEL(1);                                   06129510
                        IF STATIC_BLOCK THEN DO;                                06130000
                              CALL SET_LOCCTR(DATABASE,PROGDATA);               06130260
                           CALL EMITC(0, SHL(OPCODE&"FE",7)+22+(OPCODE&1));     06131000
                           CALL GENEVENTADDR(LEFTOP);                           06131500
                           CALL RESUME_LOCCTR(NARGINDEX);                       06132000
                               CALL EMITRX(SVC,0,0,PRELBASE,PROGDATA);          06132810
                               PROGDATA = LOCCTR(DATABASE);                     06132910
                        END;                                                    06133110
                        ELSE DO;                                                06134000
                           EXTOP = GETFREESPACE(INTEGER, 2);                    06134500
                           CALL GENSVCADDR(LEFTOP,EXTOP,1);                     06135000
                           CALL GENSVC(SHL(OPCODE&"FE",7)+22+(OPCODE&1),EXTOP); 06135500
                        END;                                                    06136000
                        OPTYPE = BIFTYPE(TAG);                                  06136500
                        RESULT = GET_STACK_ENTRY;                               06137000
                        CALL SET_RESULT_REG(RESULT, OPTYPE);                    06137500
                     END;                                                       06138000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SUPERVISOR BUILD-INS */
                     GO TO UNIMPLEMENTED;   /* SUPERVISOR BUILT-INS */
                     GO TO UNIMPLEMENTED;   /* SUPERVISOR BUILT-INS
                                                 WITH PARAMETERS */
 ?/
                  END;                                                          06138500
                  CALL SETUP_VAC(RESULT);                                       06139000
               END;                                                             06139500
               DO;  /* 4B = LFNC  */                                            06140000
                  CALL DECODEPIP(1);                                            06140500
                  OPCODE = BIFOPCODE(OP1);                                      06141000
                  RIGHTOP = ARG_STACK(SAVE_ARG_STACK_PTR(TAG));                 06141500
                  OPTYPE = TYPE(RIGHTOP);                                       06142000
                  IF COPY(RIGHTOP) = 0 THEN                                     06142500
                     CALL ERRORS(CLASS_EA,103);                                 06143000
                  IF OPCODE ^= 0 THEN DO;  /* ^ SIZE  */                        06143500
   /*------------------------- #DREG --------------------------------*/         29480018
                     D_RTL_SETUP = TRUE;                                        29490001
   /*----------------------------------------------------------------*/         29500018
                     IF PACKTYPE(OPTYPE) ^= INTSCA THEN                         06144000
                        CALL ERRORS(CLASS_FT,107);                              06144500
                     TEMPSPACE = GET_ARRAYSIZE(RIGHTOP);                        06145000
                     CALL TRUE_INX(RIGHTOP, -BIGHTS(OPTYPE));                   06145500
                     CALL STACK_REG_PARM(FORCE_ADDRESS(PTRARG1, RIGHTOP, 1));   06146000
                     CALL DROPSAVE(RIGHTOP);                                    06146500
                     TARGET_REGISTER = FIXARG1;                                 06147000
                     RESULT = FORCE_ARRAY_SIZE(TARGET_REGISTER, TEMPSPACE);     06147500
                     CALL OFF_TARGET(RESULT);                                   06148000
                     CALL DROP_PARM_STACK;                                      06148500
                     CALL GENLIBCALL(ITYPES(OPMODE(OPTYPE))||BIFNAMES(OPCODE)); 06149000
                     CALL SET_RESULT_REG(RESULT, OPTYPE);                       06151000
                  END;                                                          06151500
                  ELSE DO;  /* SIZE  */                                         06152000
                     IF FORM(RIGHTOP) ^= SYM THEN                               06152500
                        CALL ERRORS(CLASS_FT,100);                              06153000
                     IF COPY(RIGHTOP) ^= 1 THEN                                 06153500
                      IF ^(SYT_TYPE(LOC(RIGHTOP))=STRUCTURE &                   06154000
                         SYT_ARRAY(LOC(RIGHTOP))^=0 & COPY(RIGHTOP) = 2) THEN   06154500
                        CALL ERRORS(CLASS_FT,100);                              06155000
                     TEMPSPACE = GET_ARRAYSIZE(RIGHTOP);                        06155500
                     IF TEMPSPACE > 0 THEN                                      06156000
                        RESULT = GET_INTEGER_LITERAL(TEMPSPACE);                06156500
                     ELSE RESULT = FORCE_ARRAY_SIZE(-1, TEMPSPACE);             06157000
                  END;                                                          06157500
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             06158000
                  ARRAY_FLAG = FALSE;                                            6158500
                  CALL SETUP_VAC(RESULT);                                        6158600
               END;                                                             06159000
               ;  /* 4C  */                                                     06159500
               DO;  /* 4D = TNEQ  */                                            06160000
         STRUCT_CONDITIONAL:                                                    06160500

                     /*-----------------------------------*/
                     /* DECLARES FOR DR103794             */
                     /* USED TO GET TEMPORARY STACK SPACE */
                     /*-----------------------------------*/
                  DECLARE (TMP1,TMP2) BIT(16);

   /*------------------------- #DREG --------------------------------*/         29480018
                  D_RTL_SETUP = TRUE;                                           29490001
   /*----------------------------------------------------------------*/         29500018
                  CALL GET_OPERANDS;                                            06161000
                  REMOTE_ADDRS = CHECK_REMOTE(LEFTOP);                          06161500
                  REMOTE_ADDRS = CHECK_REMOTE(RIGHTOP) | REMOTE_ADDRS;          06162000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         37810010
   /* FORCE CONVERT #D DATA ADDRESS FROM YCON TO ZCON.               */         37820073
                  IF DATA_REMOTE &                                              37830001
                     ( (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D) |               37840071
                       (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D) )             37850071
                     THEN REMOTE_ADDRS = TRUE;                                  37860001
   /*----------------------------------------------------------------*/         37870018
                  R0 = SYSARG1(1-REMOTE_ADDRS);                                 06162500
                  R1 = SYSARG2(1-REMOTE_ADDRS);                                 06163000
                  CALL DROPSAVE(RIGHTOP);                                       06164500
                  CALL SETUP_STRUCTURE(RIGHTOP, 1);                             06165000
                  CALL DROPSAVE(LEFTOP);                                        06165100
                  CALL SETUP_STRUCTURE(LEFTOP);                                 06165200
                  RESULT = GET_STACK_ENTRY;                                     06165500
                  IF OPCODE THEN DO;                                            06166000
                     FIRSTLABEL, VAL(RESULT) = GETSTATNO;                       06166500
                     SECONDLABEL, XVAL(RESULT) = GETSTATNO;                     06167000
                  END;                                                          06167500
                  ELSE DO;                                                      06168000
                     SECONDLABEL, VAL(RESULT) = GETSTATNO;                      06168500
                     FIRSTLABEL, XVAL(RESULT) = GETSTATNO;                      06169000
                  END;                                                          06169500
                  CALL SAVE_REGS(RM,3,TRUE);  /* DR107714 */
                 IF CHARACTER_TERMINAL THEN DO;                                 06170000
                  CALL CHECKPOINT_REG(R0);                                      06170500
                  CALL CHECKPOINT_REG(R1);                                      06171000
                  WORK1 = STRUCTURE_ADVANCE;                                    06171500
                  DO WHILE WORK1 > 0;                                           06172000
                     WORK2 = STRUCTURE_ADVANCE(1);                              06172500
                     IF (SYT_FLAGS(WORK1) & NAME_FLAG) ^= 0 |                   06173000
                        SYT_TYPE(WORK1) ^= CHAR THEN DO;                        06173500
                        IF PACKTYPE(SYT_TYPE(WORK1)) = BITS &                   06173510
                           (SHR(SYT_DIMS(WORK1),8)&"FF") ^= 0 &                 06173520
                           (SHR(SYT_DIMS(WORK1),8)&"FF") ^= "FF" THEN           06173530
                              ESCAPE;  /* SKIP INTERMEDIATE DENSE TERMINALS */  06173540
                        D_RTL_SETUP=TRUE; /* DR109022 */
                        CALL ADDRESS_STRUCTURE(RIGHTOP, WORK2, 1, R1);          06174000
                        CALL ADDRESS_STRUCTURE(LEFTOP, WORK1, 0, R0);           06174500
                        IF (SYT_FLAGS(WORK1) & NAME_FLAG) ^= 0 THEN             06176500
                           SIZE(0) = NAMESIZE(WORK1);                           06177000
                        ELSE SIZE(0) = EXTENT(WORK1);                           06177500
                        CALL COMPARE_STRUCTURE(SIZE(0));
                     END;                                                       06188000
                     ELSE DO;                                                   06188500

                        /*****************************************/
                        /* IF ITS A CHARACTER TERMINAL, THEN CPR */
                        /* OR CPRA MUST BE CALLED INSTEAD OF     */
                        /* COMPARE_STRUCTURE.                    */
                        /*****************************************/
                        SIZE(0) = CS(SYT_DIMS(WORK1) + 2);                      06190500
                        TEMPSPACE = LUMP_ARRAYSIZE(WORK1);                      06191000

                        /*===================================*/
                        /* IF IT HAS ARRAYNESS, THEN WE MUST */
                        /* CALL CPRA.                        */
                        /*===================================*/
                        IF TEMPSPACE > 1 THEN DO;                               06191500
                           D_RTL_SETUP=TRUE; /* DR109022 */

                              /*----------------------------------*/
                              /* DR103794: LOAD ADDRESS OF        */
                              /* CHARACTER NODES INTO  REGISTER 4 */
                              /* AND REGISTER 2 (R0)              */
                              /*----------------------------------*/
                           CALL ADDRESS_STRUCTURE(RIGHTOP,WORK2,1,4);           06189500
                           CALL ADDRESS_STRUCTURE(LEFTOP,WORK1,1,R0);           06189500
                           CALL FORCE_NUM(FIXARG3, TEMPSPACE, 1);               06192000
                           CALL FORCE_NUM(FIXARG2, SIZE(0), 1);                 06192500
                           CALL GENLIBCALL('CPRA');  /*DR109014 */              06193000
                           CALL EMITBFW(NEQ, GETSTMTLBL(SECONDLABEL));          06195500
                        END;                                                    06198000

                        /*==================================*/
                        /* IF IT HAS NO ARRAYNESS, THEN WE  */
                        /* MUST CALL CPR.                   */
                        /*==================================*/

                        ELSE DO;                                                06198500

                           /*========================================*/
                           /* DR103794:                              */
                           /* IF STRUCURE ADDRESSES WERE LOADED AS   */
                           /* A ZCON BY SETUP_STRUCTURE, THEN WE     */
                           /* MUST COPY BOTH CHARACTERS STRINGS TO   */
                           /* THE STACK BEFORE TH COMPARISON IS MADE */
                           /*========================================*/

                           IF REMOTE_ADDRS THEN DO;

                                /*------------------------------*/
                                /* GET ADDRESS OF NODE OF FIRST */
                                /* OPERAND INTO REGISTER 4      */
                                /*------------------------------*/
                             D_RTL_SETUP=TRUE; /* DR109022 */
                             CALL ADDRESS_STRUCTURE(RIGHTOP,WORK2,1,4);         06189500

                                 /*-----------------------------*/
                                 /* RESERVE ENOUGH SPACE ON THE */
                                 /* STACK TO SAVE THE CHARACTER */
                                 /* STRING PLUS ITS DESCRIPTOR  */
                                 /*-----------------------------*/
                             TMP2=GETFREESPACE(CHAR,SYT_DIMS(WORK2)+2);

                                 /*-----------------------------*/
                                 /* LOAD ADDRESS OF STACK SPACE */
                                 /* INTO REGISTER 2             */
                                 /*-----------------------------*/
                             CALL FORCE_ADDRESS(2,TMP2);

                                 /*-------------------------------*/
                                 /* EMIT RTL CALL CASRV TO COPY   */
                                 /* THE STRING TO THE STACK       */
                                 /*-------------------------------*/
                             CALL GENLIBCALL('CASRV');                          06199000

                                /*------------------------------*/
                                /* GET ADDRESS OF NODE OF 2ND   */
                                /* OPERAND INTO REGISTER 4      */
                                /*------------------------------*/
                             D_RTL_SETUP=TRUE; /* DR109022 */
                             CALL ADDRESS_STRUCTURE(LEFTOP,WORK1,0,4);          06190000

                                 /*-----------------------------*/
                                 /* RESERVE ENOUGH SPACE ON THE */
                                 /* STACK TO SAVE THE CHARACTER */
                                 /* STRING PLUS ITS DESCRIPTOR  */
                                 /*-----------------------------*/
                             TMP1=GETFREESPACE(CHAR,SYT_DIMS(WORK1)+2);

                                 /*-----------------------------*/
                                 /* LOAD ADDRESS OF STACK SPACE */
                                 /* INTO REGISTER 2             */
                                 /*-----------------------------*/
                             CALL FORCE_ADDRESS(2,TMP1);

                                 /*-------------------------------*/
                                 /* EMIT RTL CALL CASRV TO COPY   */
                                 /* THE STRING TO THE STACK       */
                                 /*-------------------------------*/
                             CALL GENLIBCALL('CASRV');                          06199000

                                 /*--------------------------------*/
                                 /* NOW THAT WE HAVE THE DATA ONTO */
                                 /* THE STACK AT TMP1 AND TMP2, WE */
                                 /* MUST PREPARE FOR THE STRING    */
                                 /* COMPARE ROUTINE (CPR).  IT     */
                                 /* NEEDS THE ADDRESS OF TMP1 AND  */
                                 /* TMP2 IN R2 AND R3              */
                                 /*--------------------------------*/
                             CALL EMITRX(LA,3,0,BASE(TMP2),DISP(TMP2));
                             CALL EMITRX(LA,2,0,BASE(TMP1),DISP(TMP1));
                           END;

                           /*======================================*/
                           /* IF THE ADDRESS OF THE BOTH STRUCURES */
                           /* ARE LOCAL YCONS, THEN WE SIMPLY NEED */
                           /* TO SETUP FOR THE CALL TO CPR         */
                           /*======================================*/

                           ELSE DO;

                                  /*---------------------------*/
                                  /* DR103794:                 */
                                  /* ADDRESS NODE OF THE FIRST */
                                  /* OPERAND INTO REGISTER 3   */
                                  /*---------------------------*/
                              D_RTL_SETUP=TRUE; /* DR109022 */
                              CALL ADDRESS_STRUCTURE(RIGHTOP,WORK2,1,3);        06189500

                                  /*----------------------------*/
                                  /* ADDRESS NODE OF THE 2ND    */
                                  /* OPERAND INT REGISTER 4(R0) */
                                  /*----------------------------*/
                              CALL ADDRESS_STRUCTURE(LEFTOP,WORK1,0,R0);        06190000
                           END;

                           /*=============================*/
                           /* AT LONG LAST, WE INVOKE THE */
                           /* COMPARE ROUTINE             */
                           /*=============================*/
                           CALL GENLIBCALL('CPR');  /* DR109014 */              06199000

                              /*--------------------------------------*/
                              /* RECYCLE THE STACK AREA FOR LATER USE */
                              /*--------------------------------------*/
                           IF REMOTE_ADDRS THEN DO;
                              CALL DROPSAVE(TMP1);
                              CALL DROPSAVE(TMP2);
                              CALL RETURN_STACK_ENTRIES(TMP1,TMP2); /*DR109069*/
                           END;

                              /*-------------------------------------*/
                              /* EMIT THE CONDITION BRANCH OPERATION */
                              /*-------------------------------------*/
                           CALL EMITBFW(NEQ, GETSTMTLBL(SECONDLABEL));          06199500
                        END;                                                    06200000
                     END;                                                       06200500
                     WORK1 = STRUCTURE_ADVANCE;                                 06201000
                  END;                                                          06201500
                 END;                                                           06202000
                  ELSE CALL COMPARE_STRUCTURE(SIZE(LEFTOP));
                  CALL DOCLOSE;                                                 06203000
                  CALL EMITBFW(ALWAYS, GETSTMTLBL(FIRSTLABEL));                 06203500
                  CALL OFF_INX(BACKUP_REG(LEFTOP));                             06204000
                  CALL OFF_INX(BACKUP_REG(RIGHTOP));                            06204500
                  CONST(RESULT) = GETSTATNO;                                    06205000
                  CALL SET_LABEL(CONST(RESULT));                                06205500
                  TYPE(RESULT) = LOGICAL;                                       06206000
                  FORM(RESULT) = 0;                                             06206500
                  CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);                   06207000
                  REMOTE_ADDRS = FALSE;                                         06207500
                  CALL SETUP_VAC(RESULT);                                        6208000
               END;                                                             06208500
               GO TO STRUCT_CONDITIONAL;  /* 4E = TEQU  */                      06209000
               DO;  /* 4F = TASN  */                                            06209500
                  RIGHTOP = GET_OPERAND(1);                                     06210000
                  DO LHSPTR = 2 TO NUMOP;                                       06211000
                     LEFTOP = GET_OPERAND(LHSPTR);                              06211500
                     CALL ASSIGN_CLEAR(LEFTOP, 1);                              06212000
                     CALL MOVE_STRUCTURE(LEFTOP, RIGHTOP, LHSPTR ^= NUMOP);     06212500
                     CALL RETURN_STACK_ENTRY(LEFTOP);                           06214000
                  END;                                                          06214500
                  CALL DROPSAVE(RIGHTOP);                                       06215500
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             06216000
               END;                                                             06216500
               ;  /* 50  */                                                     06217000
               DO;  /* 51 = IDEF  */                                            06217500
                  LEFTOP = GETLABEL(1);                                         06218500
                  INLINE_RESULT = GET_FUNC_RESULT(LEFTOP);                      06219000
                  CALL RETURN_STACK_ENTRY(LEFTOP);                              06219500
                  CALL BLOCK_OPEN(2);                                           06220000
                  CALL SETUP_VAC(INLINE_RESULT);                                 6220500
               END;                                                             06221000
               DO;  /* 52 = ICLS  */                                            06221500
                  CALL BLOCK_CLOSE;                                             06222000
                  IF PACKTYPE(TYPE(INLINE_RESULT)) THEN                         06222500
                     CALL SET_RESULT_REG(INLINE_RESULT, TYPE(INLINE_RESULT));   06223000
               END;                                                             06223500
               ;  ;  /* 53 - 54  */                                             06224000
               DO;  /* 55 = NNEQ  */                                            06224500
         NAME_CONDITIONAL:                                                      06225000
                  LEFTOP = GET_OPERAND(1, 2);                                   06225500
                  RIGHTOP = GET_OPERAND(2, 2);                                  06226000
            /*-------------- CR13538 & #DNAME -----------------------*/         38780000
            /* FORCE A YCON->ZCON CONVERSION IF COMPARING REMOTE #D  */         38790000
            /* OR NON-REMOTE ADDRESS WITH A REMOTE ADDRESS.          */         38800000
                 REMOTE_ADDRS = POINTS_REMOTE(LEFTOP) |     /*CR13538*/         38810001
                    POINTS_REMOTE(RIGHTOP) |                /*CR13538*/         38820071
                    (LIVES_REMOTE(LEFTOP) & ^NAME_VAR(LEFTOP)) |                38830071
                    (LIVES_REMOTE(RIGHTOP) & ^NAME_VAR(RIGHTOP));
            /*-------------------------------------------------------*/         38850000
    /*CR13616*/   CALL FORCE_ADDRESS(BESTAC(FIXED_ACC),LEFTOP,0,FOR_NAME_TRUE); 06226500
                  TYPE(LEFTOP) = STRUCTURE;                                     06227000
    /*CR13616*/   CALL FORCE_ADDRESS(-1, RIGHTOP, 0, FOR_NAME_TRUE);            06227500
               /* FIXUP FOR INDEX INHIBIT BIT - ALLOW FOR AN       CR12432 */
               /* AGGREGATE NAME REMOTE POINTING TO A SINGLE       CR12432 */
               /* TYPE VIA %NAMEADD. IGNORE INDEX INHIBIT BIT.     CR12432 */
                  IF POINTS_REMOTE(LEFTOP) |                    /* CR12432 */
                  POINTS_REMOTE(RIGHTOP) THEN DO;               /* CR12432 */
               /* USAGE KEEPS REGISTERS LOADED SO THAT FINDAC     -CR12432 */
               /* WONT CHOOSE ONE OF THEM AS SCRATCH              -CR12432 */
                     USAGE(REG(LEFTOP)) = 2;                    /* CR12432 */
                     USAGE(REG(RIGHTOP)) = 2;                   /* CR12432 */
                     I = FINDAC(INDEX_REG);                     /* CR12432 */
                     CALL EMITP(LHI, I, 0, 0, -1);  /*FFFF0000  /* CR12432 */
                     CALL EMITP(IAL, I,0,0,"F7FF"); /*FFFFF7FF  /* CR12432 */
                     CALL EMITRR(NR, REG(LEFTOP), I);           /* CR12432 */
                     CALL EMITRR(NR, REG(RIGHTOP),I);           /* CR12432 */
               /* NOW FREE REGISTERS SO THEY CAN BE REUSED        -CR12432 */
                     USAGE(REG(LEFTOP)) = 0;                    /* CR12432 */
                     USAGE(REG(RIGHTOP)) = 0;                   /* CR12432 */
                     USAGE(I) = 0;                              /* CR12432 */
                  END;                                          /* CR12432 */
                  CALL EMITRR(ARITH_OP(COMPARE), REG(LEFTOP), REG(RIGHTOP));    06228000
                  CALL RETURN_COLUMN_STACK(LEFTOP);      /*DR109059*/
                  CALL RETURN_COLUMN_STACK(RIGHTOP);      /*DR109059*/
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             06229000
                  CALL SETUP_BOOLEAN(OPCODE&"F",OPCODE&(DOCOPY(CALL_LEVEL)>0)); 06229500
                  ARRAY_FLAG = FALSE;                                            6230000
                  REMOTE_ADDRS = FALSE; /*#DNAME -- RESET FLAG*/                38930000
                  CALL SETUP_VAC(LEFTOP);                                        6230100
               END;                                                             06230500
               GO TO NAME_CONDITIONAL;  /* 56 = NEQU  */                        06231000
               DO;  /* 57 = NASN  */                                            06231500
                  RIGHTOP = GET_OPERAND(1, 2);                                  06232000
                  CALL UPDATE_ASSIGN_CHECK(RIGHTOP);                            06232500
                  /************ DR103761  R. HANDLEY ************************/
                  IF POINTS_REMOTE(RIGHTOP) |
                       (LIVES_REMOTE(RIGHTOP) & ^NAME_VAR(RIGHTOP)) THEN
                    REMOTE_ADDRS = TRUE ;                                       06232670
                  ELSE                                                          06232680
                    REMOTE_ADDRS = FALSE ;                                      06232690
                  /************ END DR103761 ********************************/
     /*CR13616*/  CALL FORCE_ADDRESS(LINKREG, RIGHTOP, 1, FOR_NAME_TRUE);       06233000
                  CALL RETURN_COLUMN_STACK(RIGHTOP);  /*DR109059*/
                  FORM(RIGHTOP) = VAC;                                          06233500
                  DO LHSPTR = 2 TO NUMOP;                                       06234000
     /*CR13616*/     LEFTOP = GET_OPERAND(LHSPTR, 2, BY_NAME_TRUE);             06234500
                     /*******************************************************/  06234570
                     /* DR101335  - CHECK TO SEE IF THE LEFT HAND SIDE OF   */  06234640
                     /* NASN IS NAME REMOTE. THEN SET THE TYPE ACCORDINGLY. */  06234710
                     /* USE THE NEW INDIRECT STACK ENTRY FOR THIS.          */  06234780
                     /* CR13538 - PERFORM YCON->ZCON IF RIGHT HAND SIDE IS  */
                     /* NON-REMOTE AND NON-NULL (FORM=IMD & VALUE=0).       */
                     /* REMOTE_ADDRS=TRUE FOR MULTIPLE LEFT-HAND VARIABLES. */
                     /*******************************************************/  06234850
                     IF POINTS_REMOTE(LEFTOP) THEN DO;                          06234920
                        TYPE(LEFTOP) = RPOINTER;                                 6235010
        /*CR13538*/     IF ^((SHR(OPR(CTR+1),4)&"F")=IMD &      /*DR103759*/     6235020
        /*CR13538*/        (SHR(OPR(CTR+1),16)=0)) &
                           ^REMOTE_ADDRS THEN DO;                                6235020
        /*CR13538*/           CALL YCON_TO_ZCON(REG(RIGHTOP),RIGHTOP);
        /*CR13538*/           REMOTE_ADDRS = TRUE;
                        END;
                     END;                                                        6235030
                     ELSE TYPE(LEFTOP) = APOINTER;                               6235040
                     /*********** DR103761  R. HANDLEY **********************/
                     /* IF LEFT HAND SIDE IS A 16 BIT NAME VAR THEN ISSUE   */
                     /* AN XQ102 IF THE RIGHT HAND SIDE IS REMOTE.          */
                     /* CR13538-IF RIGHT HAND SIDE WAS ORIGINALLY NON-REMOTE*/
                     /* BUT WAS CONVERTED TO A ZCON ABOVE THEN DO ZCON->YCON*/
                     /*******************************************************/
                     IF ^POINTS_REMOTE(LEFTOP) THEN DO;
        /*CR13538*/     IF POINTS_REMOTE(RIGHTOP) |
        /*CR13538*/        (LIVES_REMOTE(RIGHTOP) & ^NAME_VAR(RIGHTOP)) THEN
        /*CR13538*/        CALL ERRORS(CLASS_XQ,102);
        /*CR13538*/     ELSE IF REMOTE_ADDRS THEN DO;  /*ZCON TO YCON*/
        /*CR13538*/        I = FINDAC(INDEX_REG);
        /*CR13538*/        CALL EMITRR(LR, I, REG(RIGHTOP));
        /*CR13538*/        CALL EMITP(SLL, I, 0, SHCOUNT, 31);
        /*CR13538*/        CALL EMITP(OHI, I, 0, 0, "7FFF");
        /*CR13538*/        CALL EMITRR(NR, REG(RIGHTOP), I);
        /*CR13538*/        USAGE(I) = 0;
        /*CR13538*/        REMOTE_ADDRS = FALSE;
        /*CR13538*/     END;
                     /*********** END DR103761 ******************************/
                     END;
      /*CR13616*/    CALL GEN_STORE(RIGHTOP,LEFTOP,LHSPTR^=NUMOP,BY_NAME_TRUE); 06235500
                     CALL RETURN_STACK_ENTRY(LEFTOP);                           06236000
                  END;                                                          06236500
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                              6237000
                  REMOTE_ADDRS = FALSE;                                          6237100
               END;                                                             06237500
               ;  /* 58  */                                                     06238000
               DO;  /* 59 = PMHD  */                                            06238500
                  IF PMINDEX ^= 0 THEN CALL ERRORS(CLASS_F,102);                06239000
                  SAVE_CALL_LEVEL = CALL_LEVEL;                                 06239500
                  SAVE_ARG_STACK_PTR = ARG_STACK_PTR;                           06240000
                  CALL_LEVEL = 0;                                               06240500
                  PMINDEX = TAG;                                                06241000
               END;                                                             06241500
               DO;  /* 5A = PMAR  */                                            06242000
                  IF ARG_STACK_PTR > ARG_STACK# THEN                            06242500
                     CALL ERRORS(CLASS_BS,103);                                 06243000
                  LITTYPE = TYPE_BITS(1);                                       06243500
                  DO CASE PMINDEX;                                              06244000
                     CALL ERRORS(CLASS_FN,103);                                 06244500
    /*CR13570-%NAMEBIAS:FLAG=3 PREVENTS GET_OPERAND FROM LOADING VALUES FOR */
    /*CR13570-THE SOURCE (SUCH AS INDEXING OR PARENT STRUCTURES), BY_NAME=1 */
    /*CR13570-PREVENTS SIZEFIX FROM LOADING AN UNNECESSARY STACK ENTRY.     */
    /*CR13570*/      DO CASE ARG_STACK_PTR - SAVE_ARG_STACK_PTR;
    /*CR13570*/         RIGHTOP = GET_OPERAND(1);
    /*CR13570*/         RIGHTOP = GET_OPERAND(1, 3, BY_NAME_TRUE);
    /*CR13570*/      END;
                     RIGHTOP = GET_OPERAND(1);                                  06245000
                     DO CASE ARG_STACK_PTR - SAVE_ARG_STACK_PTR;                06245500
                        RIGHTOP = GET_OPERAND(1, 2, BY_NAME_TRUE); /*CR13616*/  06246000
                        RIGHTOP = GET_OPERAND(1, 2);                            06246500
                     END;                                                       06247000
                     DO;                                                        06247500
                        LITTYPE = INTEGER;                                      06248000
                        RIGHTOP = GET_OPERAND(1);                               06248500
                     END;                                                       06249000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; SVCI */
                     ;  /* %SVCI  */                                             6249010
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVCI */
                      DO;
                         LITTYPE = INTEGER;
                         RIGHTOP = GET_OPERAND(1);
                      END;
 ?/
                     DO CASE ARG_STACK_PTR - SAVE_ARG_STACK_PTR;                 6249020
                        RIGHTOP = GET_OPERAND(1,2,BY_NAME_TRUE);   /*CR13616*/   6249030
                        RIGHTOP = GET_OPERAND(1,2);                              6249040
                        DO;                                                      6249050
                           LITTYPE = INTEGER;                                    6249060
                           RIGHTOP = GET_OPERAND(1);                             6249070
                        END;                                                     6249080
                     END;                                                        6249090
                  END;                                                          06249500
                  ARG_STACK(ARG_STACK_PTR) = RIGHTOP;                           06250500
                  ARG_STACK_PTR = ARG_STACK_PTR + 1;                            06251000
               END;                                                             06251500
               DO;  /* 5B = PMIN  */                                            06252000
                  IF TAG ^= PMINDEX THEN                                        06252500
                     CALL ERRORS(CLASS_F,101);                                  06253000
                  INDEX = ARG_STACK_PTR - SAVE_ARG_STACK_PTR;                   06253500
                  DO CASE TAG;                                                  06254000
                     ;                                                          06254500
   /*CR13570*/       DO;  /* %NAMEBIAS */
   /*CR13570*/          IF INDEX ^= 2 THEN CALL ERRORS(CLASS_FN, 100);
   /*CR13570*/          LEFTOP = ARG_STACK(SAVE_ARG_STACK_PTR);
   /*CR13570*/          RIGHTOP = ARG_STACK(SAVE_ARG_STACK_PTR+1);
   /*CR13570*/          CALL ASSIGN_CLEAR(LEFTOP, 1);
   /*CR13570*/          CALL CLEAR_NAME_SAFE(LEFTOP);
   /*CR13570-FOR ARRAYED CHAR(*) VARIABLES, SYT_CONST IS THE BIAS DUE TO THE*/
   /*CR13570-ARRAY'S DIMENSIONS. THIS NEEDS TO BE MULTIPLIED BY THE CHAR'S  */
   /*CR13570-SIZE DURING EXECUTION. THIS VALUE IS THEN SHIFTED (/2) BASED ON*/
   /*CR13570-THE PRECISION OF THE DESTINATION VARIABLE.  FORM=VAC TO PREVENT*/
   /*CR13570-GEN_STORE FROM CALLING FORCE_ACCUMULATOR.                      */
   /*CR13570*/          IF TYPE(RIGHTOP)=CHAR & SYT_DIMS(LOC(RIGHTOP))<-1
   /*CR13570*/          THEN DO;
   /*CR13570*/             I = FINDAC(INDEX_REG);
   /*CR13570*/             CALL EMITP(LHI,I,0,0,-SYT_CONST(LOC(RIGHTOP)));
   /*CR13570*/             RESULT=SET_ARRAY_SIZE(-SYT_DIMS(LOC(RIGHTOP)),2);
   /*CR13570*/             CALL CHECK_ADDR_NEST(-1,RESULT);
   /*CR13570*/             CALL EMITOP(MH,I,RESULT);
   /*CR13570*/             IF TYPE(LEFTOP)=DINTEGER THEN
   /*CR13570*/                CALL EMITP(SRA,I,0,SHCOUNT,1);
   /*CR13570*/             ELSE
   /*CR13570*/                CALL EMITP(SLL,I,0,SHCOUNT,15);
   /*CR13570*/             FORM(RESULT) = VAC;
   /*CR13570*/             REG(RESULT) = I;
   /*CR13570*/          END;
   /*CR13570*/          ELSE DO;
   /*CR13570*/             IF MAJOR_STRUCTURE(RIGHTOP) THEN RESULT=
   /*CR13570*/                GET_INTEGER_LITERAL(-SYT_CONST(LOC(RIGHTOP)));
   /*CR13570*/             ELSE RESULT=
   /*CR13570*/                GET_INTEGER_LITERAL(-SYT_CONST(LOC2(RIGHTOP)));
   /*CR13570*/          END;
   /*CR13570*/          CALL GEN_STORE(RESULT,LEFTOP);
   /*CR13570*/          USAGE(REG(RESULT)) = 0;
   /*CR13570*/          CALL RETURN_STACK_ENTRY(RIGHTOP);
   /*CR13570*/          CALL RETURN_STACK_ENTRIES(RESULT,LEFTOP);
   /*CR13570*/       END;  /* %NAMEBIAS */
                     DO;  /* %SVC  */                                           06255000
                        IF INDEX ^= 1 THEN CALL ERRORS(CLASS_FN,100);           06255500
                        RIGHTOP = ARG_STACK(SAVE_ARG_STACK_PTR);                06256000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHANGE %SVC TO DO <CHAR LIT> */
                        IF TYPE(RIGHTOP) = CHAR & FORM(RIGHTOP) = LIT THEN DO;
                           ESD_MAX = ESD_MAX + 1;
                           CALL ENTER_ESD(' ', ESD_MAX, LEC, 0);
                           ESD_LINK(ESD_MAX) = LOC(RIGHTOP);
                           CALL EMITP(SVC, 0, 0, EXTSYM, ESD_MAX);
                        END;
                        ELSE DO;
 ?/
                        CALL SETUP_NONHAL_ARG(RIGHTOP);                         06256500
                        CALL GUARANTEE_ADDRESSABLE(RIGHTOP, SVC);               06257000
                        CALL EMITOP(SVC, 0, RIGHTOP);                           06257500
                        CALL CLEAR_SCOPED_REGS(2);                              06258000
                        CALL DROPSAVE(RIGHTOP);                                 06258500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVCI */
                        END;
 ?/
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       06259000
                     END;                                                       06259500
                     DO;  /* %NAMECOPY  */                                      06260000
                        IF INDEX ^= 2 THEN CALL ERRORS(CLASS_FN,100);           06260500
                        RIGHTOP = ARG_STACK(ARG_STACK_PTR - 1);                 06261000
                        LEFTOP = ARG_STACK(SAVE_ARG_STACK_PTR);                 06261500
                  /*----------- CR13538 & #DNAME ---------------------------*/  39900071
                  /* FORCE A YCON->ZCON CONVERSION IF COPYING REMOTE #D     */  38790000
                  /* OR NON-REMOTE ADDRESS TO A NAME REMOTE ADDRESS.        */  38800000
          /*CR13538*/   REMOTE_ADDRS = POINTS_REMOTE(LEFTOP);
                  /*--------------------------------------------------------*/  39950071
                        WORK1, WORK2 = 0;                                       06262000
                        IF MAJOR_STRUCTURE(RIGHTOP) THEN                        06262500
                           IF STRUCT_INX(RIGHTOP) = 0 THEN                      06263000
                              WORK1 = -SYT_CONST(LOC(RIGHTOP));                 06263500
                        IF MAJOR_STRUCTURE(LEFTOP) THEN                         06264000
                           WORK2 = SYT_CONST(LOC(LEFTOP));                      06264500
                        INX_CON(RIGHTOP) = INX_CON(RIGHTOP) + WORK1 + WORK2;    06265000
                        CALL SUBSCRIPT_RANGE_CHECK(RIGHTOP);                    06265500
        /*CR13616*/     CALL FORCE_ADDRESS(LINKREG,RIGHTOP,1,FOR_NAME_TRUE);    06266000
                        FORM(RIGHTOP) = VAC;                                    06266500
                        /************* DR102965 RAH **************************/ 06266510
                        CALL SET_NAME_TYPE(LEFTOP);
                        CALL SET_NAME_TYPE(RIGHTOP);
          /*CR13538*/   IF TYPE(LEFTOP)=APOINTER & TYPE(RIGHTOP)=RPOINTER THEN
                           CALL ERRORS(CLASS_FT,111);
                        /************* END DR102965 **************************/ 06267010
        /*CR13616*/     CALL GEN_STORE(RIGHTOP, LEFTOP, 0, BY_NAME_TRUE);       06267620
                        USAGE(REG(RIGHTOP)) = 0;                                06268000
        /*CR12214*/     MISMATCH = FALSE;
        /*CR12214*/     CALL STRUCTURE_COMPARE(DEL(RIGHTOP),DEL(LEFTOP),1);
        /*CR12214*/     IF ^MISMATCH THEN
        /*CR12214*/       CALL ERRORS(CLASS_YF, 100);
                        CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);             06268500
                        REMOTE_ADDRS = FALSE; /*#DNAME -- RESET FLAG*/          40150000
                     END;                                                       06269000
                     DO;  /* %COPY */                                           06269500
                        IF INDEX = 2 THEN DO;                                   06270000
                           INDEX = INDEX + 1;                                   06270500
                           /***** DR107697 FIX ********************************/
                           /* IF PROCESSING AN UNARRAYED CHARACTER(*), FETCH  */
                           /* THE MAX LENGTH FROM THE STRING DESCRIPTOR.      */
                           IF ( (SYT_TYPE(LOC2(ARG_STACK(ARG_STACK_PTR-1))) =
                             CHAR) & (SIZE(ARG_STACK(ARG_STACK_PTR-1)) < 0) &
                             (SYT_ARRAY(LOC2(ARG_STACK(ARG_STACK_PTR-1))) = 0) )
                              THEN ARG_STACK(ARG_STACK_PTR) =
                       EXTRACT_SIZE_FROM_DESCRIPTOR(ARG_STACK(ARG_STACK_PTR-1));
                           ELSE /* PROCESS NORMALLY... */
                           /***** END DR107697 FIX ****************************/
                           ARG_STACK(ARG_STACK_PTR) =                           06271000
                              SETUP_TOTAL_SIZE(ARG_STACK(ARG_STACK_PTR-1));     06271500
                        END;                                                    06272000
                        ELSE IF INDEX ^= 3 THEN                                 06272500
                           CALL ERRORS(CLASS_FN, 100);                          06273000
                        LEFTOP = ARG_STACK(SAVE_ARG_STACK_PTR);                 06273500
                        RIGHTOP = ARG_STACK(SAVE_ARG_STACK_PTR+1);              06274000
                        EXTOP = ARG_STACK(SAVE_ARG_STACK_PTR+2);                06274500
                        CALL ASSIGN_CLEAR(LEFTOP, 1);                           06275000
                        /* DR109030: CLEAR POSSIBLY AFFECTED REGISTERS */       06275000
                        CALL CLEAR_NAME_SAFE(LEFTOP); /*DR109030*/              06275000
                        CALL TRUE_INX(RIGHTOP);                                 06275500
                        CALL TRUE_INX(LEFTOP);                                  06276000
                        IF FORM(EXTOP) = LIT THEN DO;                           06276010
                           DECLARE COPY_TEMP BIT(16);                           06276020
                           COPY_TEMP = COPY_CHECK(RIGHTOP,EXTOP);               06276030
                           IF COPY_TEMP ^= 0 THEN CALL ERRORS(CLASS_FN,         06276040
                              COPY_TEMP,'SOURCE');                              06276050
                           COPY_TEMP = COPY_CHECK(LEFTOP,EXTOP);                06276060
                           IF COPY_TEMP ^= 0 THEN CALL ERRORS(CLASS_FN,         06276070
                              COPY_TEMP,'DESTINATION');                         06276080
                        END;                                                    06276090
                        CALL RETURN_COLUMN_STACK(RIGHTOP,TRUE); /*DR109064*/
                        CALL RETURN_COLUMN_STACK(LEFTOP,TRUE);  /*DR109064*/
                        CALL MOVE_STRUCTURE(LEFTOP, RIGHTOP, 0, EXTOP);         06276500
                        CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);             06281500
                     END;                                                       06282000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; SVCI */
                     GO TO UNIMPLEMENTED;  /* %SVCI  */                          6282020
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVCI */
                      DO;   /* %SVCI */
                         IF INDEX ^= 1 THEN
                            CALL ERRORS(CLASS_FN, 100);
                         RIGHTOP = ARG_STACK(SAVE_ARG_STACK_PTR);
                         IF FORM(RIGHTOP) = LIT THEN
                            CALL EMITRX(SVC, 0, 0, 3, VAL(RIGHTOP));
                         ELSE DO;
                            WORK1 = FORCE_BY_MODE(RIGHTOP, INTEGER);
                            CALL EMITRX(SVC, 0, WORK1, 3, 0);
                            CALL DROP_REG(WORK1);
                         END;
                         LAST_SVCI = LINE#;
                         CALL RETURN_STACK_ENTRY(RIGHTOP);
                      END;
 ?/
                     DO;  /* %NAMEADD  */                                        6282040
                        IF INDEX ^= 3 THEN CALL ERRORS(CLASS_FN, 100);           6282060
                        LEFTOP = ARG_STACK(SAVE_ARG_STACK_PTR + 1);              6282080
                        RIGHTOP = ARG_STACK(SAVE_ARG_STACK_PTR + 2);             6282100
                        RESULT = ARG_STACK(SAVE_ARG_STACK_PTR);                  6282120
                  /*----------- CR13538 & #DNAME ---------------------------*/  39900071
                  /* FORCE A YCON->ZCON CONVERSION IF COPYING REMOTE #D     */  38790000
                  /* OR NON-REMOTE ADDRESS TO A NAME REMOTE ADDRESS.        */  38800000
          /*CR13538*/   REMOTE_ADDRS = POINTS_REMOTE(RESULT);
                  /*--------------------------------------------------------*/  40530071
                        /************* DR102965 RAH **************************/ 06266510
                        CALL SET_NAME_TYPE(RESULT);
                        CALL SET_NAME_TYPE(LEFTOP);
          /*CR13538*/   IF TYPE(RESULT)=APOINTER & TYPE(LEFTOP)=RPOINTER THEN
                           CALL ERRORS(CLASS_FT,110);
                        /************* END DR102965 **************************/ 06267010
                        /*----- DR104835  LJK  05/18/93 --------------*/
                        /* FOR %NAMEADD WITH 3RD ARGUMENT A LITERAL,  */
                        /* IF AUTOINDEXING IS NOT PERFORMED, A SLL IS */
                        /* NEEDED TO SHIFT THE INDEX FOR THE 2ND      */
                        /* ARGUMENT BEFORE ADDING THE 3RD ARGUMENT    */
                        /* (LITERAL COUNT) TO IT.                     */
                        /*--------------------------------------------*/
                        CALL RETURN_COLUMN_STACK(LEFTOP); /*DR109064*/
                        IF FORM(RIGHTOP) = LIT THEN DO;                         06282166
                           DECLARE SHIFT_AMOUNT BIT(8);
                           DECLARE SHIFT_REG BIT(8);           /* DR109033 */
                           SHIFT_AMOUNT = 0;                   /* DR109033 */
            /*CR12214*/    MISMATCH = FALSE;
            /*CR12214*/    IF LIT2(GET_LITERAL(LOC(RIGHTOP))) = 0 THEN DO;
            /*CR12214*/     IF (SYT_TYPE(LOC2(LEFTOP)) = STRUCTURE) &
            /*CR12214*/     (SYT_TYPE(LOC2(RESULT)) = STRUCTURE) THEN DO;
            /*CR12214*/       CALL STRUCTURE_COMPARE(DEL(RESULT),DEL(LEFTOP),1);
            /*CR12214*/       IF ^MISMATCH THEN
            /*CR12214*/         CALL ERRORS(CLASS_YF, 102);
            /*CR12214*/       ELSE
            /*CR12214*/         CALL ERRORS(CLASS_YF, 101);
            /*CR12214*/     END;
            /*CR12214*/      ELSE DO;
            /*CR12214*/        CALL CHECK_NAMEADD;
            /*CR12214*/        IF ^MISMATCH THEN
            /*CR12214*/          CALL ERRORS(CLASS_YF, 102);
            /*CR12214*/      END;
            /*CR12214*/    END;
                           IF SELF_ALIGNING THEN
                           IF (STRUCT_INX(LEFTOP)<4) | CHECK_REMOTE(LEFTOP) THEN
                           IF INX(LEFTOP) > 0 THEN
                           DO;
                           IF (TYPE(LEFTOP)=APOINTER) | (TYPE(LEFTOP)=RPOINTER)
                              THEN SHIFT_AMOUNT = SHIFT(SYT_TYPE(LOC2(LEFTOP)));
                              ELSE SHIFT_AMOUNT = SHIFT(TYPE(LEFTOP));
                           SHIFT_REG = INX(LEFTOP);              /*DR109033*/
                           /*--DR109019-------------------------------------*/
                           /* IF SHIFT_AMOUNT WAS SAVED, THEN USE THE SAVED */
                           /* VALUE INSTEAD.  (SAVED AS 2*AIA_ADJUSTED)     */
                           /*-----------------------------------------------*/
                           IF (AIA_ADJUSTED(LEFTOP)) THEN DO;
                              SHIFT_AMOUNT= AIA_ADJUSTED(LEFTOP)/2;
                              AIA_ADJUSTED(LEFTOP)=FALSE;
                           END;
                           IF SHIFT_AMOUNT > 0 THEN
                             CALL EMITP(SLA,INX(LEFTOP),0,SHCOUNT,SHIFT_AMOUNT);
                           END;
                           INX_CON(LEFTOP) = INX_CON(LEFTOP) + VAL(RIGHTOP);    06282168
                                                                                06282170
                           CALL SUBSCRIPT_RANGE_CHECK(LEFTOP);                   6282200
             /*CR13616*/   CALL FORCE_ADDRESS(LINKREG,LEFTOP,1,FOR_NAME_TRUE);   6282220
                           /*---------------------------------------------*/
                           /* DR109033: IF THE INDEX REGISTER WAS SHIFTED */
                           /* THEN SHIFT IT BACK OR MARK IT AS UNKNOWN.   */
                           /*---------------------------------------------*/
                           IF SHIFT_AMOUNT > 0 THEN DO;
                              IF ((USAGE(SHIFT_REG) > 1) &
                                 (SHIFT_REG ^= REG(LEFTOP))) THEN
                                 CALL EMITP(SRA,SHIFT_REG,0,SHCOUNT,
                                            SHIFT_AMOUNT);
                              ELSE CALL UNRECOGNIZABLE(SHIFT_REG);
                           END;
                           /********* DR109017 - TEV - 2/7/94 ***************/
                           /* RETURN RIGHTOP STACK ENTRY NOW. FORCE_ADDRESS */
                           /* NEEDED RIGHTOP STACK ENTRY TO DETERMINE SHIFT */
                           /* AMOUNTS.                                      */
                           /*************************************************/
                           CALL RETURN_STACK_ENTRY(RIGHTOP);                     6282180
                           FORM(LEFTOP) = VAC;                                   6282240
                        END;                                                     6282260
                        ELSE DO;                                                 6282280
                           INX_CON(LEFTOP) = INX_CON(LEFTOP) + CONST(RIGHTOP);   6282300
                           CONST(RIGHTOP) = 0;                                   6282320
                           CALL SUBSCRIPT_RANGE_CHECK(LEFTOP);                   6282340
             /*CR13616*/   CALL FORCE_ADDRESS(LINKREG,LEFTOP,1,FOR_NAME_TRUE);   6282360
                           FORM(LEFTOP) = VAC;                                   6282380
                           OPTYPE, TYPE(LEFTOP) = NAMETYPE;                      6282400
                           CALL EXPRESSION(XADD);                                6282420
                        END;                                                     6282440
   /* SPECIAL CASE FOR %NAMEADD:     CLEAR INDEX INHIBIT IF           CR12432 */
   /* AGGREGATE NAME --> SINGLE. IN CASE SOURCE IS STRUCTURE,         CR12432 */
   /* LOOK AT LOC2 IF NAME VARIABLE TO REFLECT NAME'S ARRAYNESS       CR12432 */
   /* DR111377 - THE CHECK FOR NAME_FLAG WILL ALWAYS BE FALSE FOR MAJOR */
   /*            STRUCTURES SINCE LOC2 POINTS AT THE TEMPLATE.          */
                        IF POINTS_REMOTE(RESULT) THEN DO;          /* CR12432 */
                           IF (SYT_FLAGS(LOC2(LEFTOP))             /* CR12432 */
                              & NAME_FLAG) ^= 0 THEN /* NAME */    /* CR12432 */
                           INDEX_INHIBIT=                          /* CR12432 */
                              ^(PACKTYPE(SYT_TYPE(LOC2(LEFTOP)))   /* CR12432 */
                              & (SYT_ARRAY(LOC2(LEFTOP))=0));      /* CR12432 */
                           ELSE /* NONNAME */                      /* CR12432 */
                           INDEX_INHIBIT=                          /* CR12432 */
                              ^(PACKTYPE(SYT_TYPE(LOC(LEFTOP)))    /* CR12432 */
                              & (SYT_ARRAY(LOC(LEFTOP))=0));       /* CR12432 */
                           IF ^(PACKTYPE(SYT_TYPE(LOC2(RESULT)))   /* CR12432 */
                              & (SYT_ARRAY(LOC2(RESULT))=0))       /* CR12432 */
                           THEN DO; /* RESULT IS AGGREGATE NAME */ /* CR12432 */
                              IF ^INDEX_INHIBIT THEN DO;           /* CR12432 */
                                 I = BESTAC(FIXED_ACC);            /* CR12432 */
   /* DR111359 */                CALL EMITRR(LFXI, I, 1); /*FFFF*/ /* CR12432 */
   /* DR111359 */                CALL EMITP(IAL, I, 0, 0, "F7FF"); /* CR12432 */
   /* DR111359 */                CALL EMITRR(NR, LINKREG, I);      /* CR12432 */
                              END;                                 /* CR12432 */
                           END;                                    /* CR12432 */
                        END;                                       /* CR12432 */
   /*CR13616*/          CALL GEN_STORE(LEFTOP, RESULT, 0, BY_NAME_TRUE);         6282480
                        USAGE(REG(LEFTOP)) = 0;                                  6282500
                        CALL RETURN_STACK_ENTRIES(LEFTOP, RESULT);               6282520
                        REMOTE_ADDRS = FALSE; /*#DNAME -- RESET FLAG*/          40810000
                     END;                                                        6282540
                  END;                                                          06292000
                  CALL_LEVEL = SAVE_CALL_LEVEL;                                 06292500
                  ARG_STACK_PTR = SAVE_ARG_STACK_PTR;                           06293000
                  PMINDEX = 0;                                                  06293500
               END;                                                             06294000
               ;;;;;   /* INSURANCE  */                                         06294500
            END CLASS0;  /* CLASS 0 OPS  */                                     06295000
            RETURN FALSE;                                                        6295100
   END GEN_CLASS0  /* $S  */  ;  /*  $S  */                                     06295500
