 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   IDENTIFY.xpl
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
 /* PROCEDURE NAME:  IDENTIFY                                               */
 /* MEMBER NAME:     IDENTIFY                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          BCD               CHARACTER;                                   */
 /*          CENT_IDENTIFY     BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_DEFAULT(1540) LABEL                                        */
 /*          ALL_TPLS(1519)    LABEL                                        */
 /*          ASSIGN_TOO(1553)  LABEL                                        */
 /*          BAD_LAB_DEF(1502) LABEL                                        */
 /*          BUILT_IN(1575)    LABEL                                        */
 /*          DCLJOIN(1510)     LABEL                                        */
 /*          DO_LAB(1536)      LABEL                                        */
 /*          DONT_ENTER        BIT(16)                                      */
 /*          DUPL_LABEL(1508)  LABEL                                        */
 /*          END_FUNC_CHECK(1571)  LABEL                                    */
 /*          FLAG              FIXED                                        */
 /*          FUNC_CHECK(1496)  LABEL                                        */
 /*          FUNC_TOKEN_ZERO(1570)  LABEL                                   */
 /*          I                 FIXED                                        */
 /*          IDENTIFY_EXIT(1509)  LABEL                                     */
 /*          J                 FIXED                                        */
 /*          K                 FIXED                                        */
 /*          L                 FIXED                                        */
 /*          LAB_OP_CHECK(1532)  LABEL                                      */
 /*          LABELJOIN(1544)   LABEL                                        */
 /*          LOOKUP(1499)      LABEL                                        */
 /*          MAKE_DEFAULT(1541)  LABEL                                      */
 /*          MAKE_TOKEN(1537)  LABEL                                        */
 /*          MAYBE_FOUND(1574) LABEL                                        */
 /*          NO_ARG_FUNC(1567) LABEL                                        */
 /*          NO_OVERPUNCH(1518)  LABEL                                      */
 /*          NOT_FOUND(1497)   LABEL                                        */
 /*          NOT_FOUND_YET(1562)  LABEL                                     */
 /*          OP_TYPE_MISMATCH(1503)  LABEL                                  */
 /*          OVERRIDE_ERR(1546)  LABEL                                      */
 /*          PARMJOIN(1522)    LABEL                                        */
 /*          Q_TRAP(1506)      LABEL                                        */
 /*          REPL_OP_CHECK(1501)  LABEL                                     */
 /*          SET_DEF_BC(1549)  LABEL                                        */
 /*          SET_INITIAL_FLAGS(1552)  LABEL                                 */
 /*          TEMPL_BRANCH(1526)  LABEL                                      */
 /*          TEMPL_FIXUP(1517) LABEL                                        */
 /*          YES_ARG(1521)     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARITH_FUNC_TOKEN                                               */
 /*          ARITH_TOKEN                                                    */
 /*          ASSIGN_PARM                                                    */
 /*          BI_INDEX                                                       */
 /*          BI_INFO                                                        */
 /*          BI_LIMIT                                                       */
 /*          BI_NAME                                                        */
 /*          BIT_FUNC_TOKEN                                                 */
 /*          BIT_TOKEN                                                      */
 /*          BIT_TYPE                                                       */
 /*          BUILDING_TEMPLATE                                              */
 /*          CHAR_FUNC_TOKEN                                                */
 /*          CHAR_TOKEN                                                     */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_BX                                                       */
 /*          CLASS_DI                                                       */
 /*          CLASS_DT                                                       */
 /*          CLASS_DU                                                       */
 /*          CLASS_FN                                                       */
 /*          CLASS_IR                                                       */
 /*          CLASS_IS                                                       */
 /*          CLASS_MC                                                       */
 /*          CLASS_MO                                                       */
 /*          CLASS_P                                                        */
 /*          CLASS_PL                                                       */
 /*          CLASS_PM                                                       */
 /*          DECLARE_CONTEXT                                                */
 /*          DEF_BIT_LENGTH                                                 */
 /*          DEF_CHAR_LENGTH                                                */
 /*          DEF_MAT_LENGTH                                                 */
 /*          DEF_VEC_LENGTH                                                 */
 /*          DEFAULT_ATTR                                                   */
 /*          DEFAULT_TYPE                                                   */
 /*          DEFINED_LABEL                                                  */
 /*          DUPL_FLAG                                                      */
 /*          EQUATE_CONTEXT                                                 */
 /*          EQUATE_LABEL                                                   */
 /*          EVENT_TOKEN                                                    */
 /*          EVIL_FLAG                                                      */
 /*          EXPRESSION_CONTEXT                                             */
 /*          FALSE                                                          */
 /*          ID_TOKEN                                                       */
 /*          IMP_DECL                                                       */
 /*          INACTIVE_FLAG                                                  */
 /*          IND_CALL_LAB                                                   */
 /*          INPUT_PARM                                                     */
 /*          INT_TYPE                                                       */
 /*          LAB_TOKEN                                                      */
 /*          LABEL_CLASS                                                    */
 /*          LABEL_IMPLIED                                                  */
 /*          LINK_SORT                                                      */
 /*          LOOKUP_ONLY                                                    */
 /*          MAJ_STRUC                                                      */
 /*          MAT_TYPE                                                       */
 /*          NEXT_CHAR                                                      */
 /*          NO_ARG_ARITH_FUNC                                              */
 /*          NO_ARG_BIT_FUNC                                                */
 /*          NO_ARG_CHAR_FUNC                                               */
 /*          NO_ARG_STRUCT_FUNC                                             */
 /*          NONHAL_FLAG                                                    */
 /*          PROC_LABEL                                                     */
 /*          PROCMARK                                                       */
 /*          REF_ID_LOC                                                     */
 /*          REPL_ARG_CLASS                                                 */
 /*          REPL_CLASS                                                     */
 /*          REPL_CONTEXT                                                   */
 /*          REPLACE_PARM_CONTEXT                                           */
 /*          SCALAR_TYPE                                                    */
 /*          STMT_LABEL                                                     */
 /*          STRUC_TOKEN                                                    */
 /*          STRUCT_FUNC_TOKEN                                              */
 /*          STRUCT_TEMPLATE                                                */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_HASHLINK                                                   */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_HASHLINK                                                   */
 /*          SYT_HASHSIZE                                                   */
 /*          SYT_HASHSTART                                                  */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_MAX                                                        */
 /*          SYT_NAME                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          TASK_LABEL                                                     */
 /*          TEMPL_NAME                                                     */
 /*          TEMPLATE_CLASS                                                 */
 /*          TEMPLATE_IMPLIED                                               */
 /*          TEMPORARY_FLAG                                                 */
 /*          TRUE                                                           */
 /*          UNSPEC_LABEL                                                   */
 /*          VAR_CLASS                                                      */
 /*          VAR_LENGTH                                                     */
 /*          VEC_TYPE                                                       */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CONTEXT                                                        */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          EQUATE_IMPLIED                                                 */
 /*          FACTORING                                                      */
 /*          FIXING                                                         */
 /*          IDENT_COUNT                                                    */
 /*          IMPLICIT_T                                                     */
 /*          IMPLIED_TYPE                                                   */
 /*          KIN                                                            */
 /*          MACRO_NAME                                                     */
 /*          NAME_HASH                                                      */
 /*          NAMING                                                         */
 /*          QUALIFICATION                                                  */
 /*          SYM_TAB                                                        */
 /*          SYT_INDEX                                                      */
 /*          TEMPORARY_IMPLIED                                              */
 /*          TOKEN                                                          */
 /*          VALUE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER                                                          */
 /*          BUFFER_MACRO_XREF                                              */
 /*          ERROR                                                          */
 /*          HASH                                                           */
 /*          SET_DUPL_FLAG                                                  */
 /*          SET_XREF                                                       */
 /* CALLED BY:                                                              */
 /*          SCAN                                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> IDENTIFY <==                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> HASH                                                            */
 /*     ==> ENTER                                                           */
 /*     ==> SET_DUPL_FLAG                                                   */
 /*     ==> SET_XREF                                                        */
 /*         ==> ENTER_XREF                                                  */
 /*         ==> SET_OUTER_REF                                               */
 /*             ==> COMPRESS_OUTER_REF                                      */
 /*                 ==> MAX                                                 */
 /*     ==> BUFFER_MACRO_XREF                                               */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /* 04/05/94 JAC  26V0  DR108643 INCORRECTLY LISTS 'NONHAL INSTEAD OF       */
 /*               10V0           'INCREM' IN SDFLIST                        */
 /*                                                                         */
 /* 04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS         */
 /*               16V0           IN HAL/S COMPILER                          */
 /*                                                                         */
 /* 03/15/01 DCP  31V0  DR111365 CROSS REFERENCE INFORMATION MISSING        */
 /*               16V0           FOR FUNCTION                               */
 /*                                                                         */
 /* 10/17/00 TKN  31V0  DR111350 COMPILER PHASE3 LISTING INCORRECT          */
 /*               16V0                                                      */
 /***************************************************************************/
                                                                                00161800
IDENTIFY:                                                                       00557900
   PROCEDURE(BCD,CENT_IDENTIFY);                                                00558000
      DECLARE (I, J, K, L) FIXED, FLAG FIXED;                                   00558100
      DECLARE BCD CHARACTER;                                                    00558200
      DECLARE DONT_ENTER BIT(16);                                               00558300
      DECLARE CENT_IDENTIFY BIT(1);                                             00558400
      FLAG=0;                                                                   00558500
      IDENT_COUNT = IDENT_COUNT + 1;                                            00558600
      IF CONTEXT = REPLACE_PARM_CONTEXT THEN GO TO NOT_FOUND;                   00558700
      IF CENT_IDENTIFY THEN GO TO LOOKUP;                                       00558800
      L = LENGTH(BCD);                                                          00558900
      IF TEMPLATE_IMPLIED THEN                                                  00559000
         DO;                                                                    00559100
         BCD = X1 || BCD;                                                       00559200
         L = L + 1;                                                             00559300
         GO TO LOOKUP;  /* CAN'T BE A BUILT-IN */                               00559400
      END;                                                                      00559500
      IF EQUATE_IMPLIED THEN DO;                                                00559600
         BCD = '@' || BCD;                                                      00559700
         L = L + 1;                                                             00559800
         EQUATE_IMPLIED = FALSE;                                                00559900
         GO TO LOOKUP;                                                          00560000
      END;                                                                      00560100
      IF L>1 THEN IF L<=BI_LIMIT THEN DO J=BI_INDEX(L-1) TO BI_INDEX(L)-1;      00560200
/*13335*/IF PAD(BCD,10) = SUBSTR(BI_NAME(BI_INDX(J)),BI_LOC(J),10) THEN DO;     00560300
            SYT_TYPE(RECORD_TOP(SYM_TAB))=SHR(BI_INFO(J),24);                   00560400
            I=RECORD_TOP(SYM_TAB);                                              00560500
            SYT_INDEX=J+SYT_MAX-I;                                              00560600
            IF IMPLIED_TYPE^=0 THEN DO;                                         00560700
               IMPLIED_TYPE=0;                                                  00560800
               CALL ERROR(CLASS_MC,2);                                          00560900
            END;                                                                00561000
            IF QUALIFICATION>0 THEN GO TO Q_TRAP;                               00561100
            IF (BI_INFO(J)&"FF0000")=0 THEN GO TO BUILT_IN;                     00561200
            ELSE GO TO YES_ARG;                                                 00561300
         END;                                                                   00561400
      END;                                                                      00561500
LOOKUP:                                                                         00561600
      NAME_HASH = HASH(BCD, SYT_HASHSIZE);                                      00561700
      I = SYT_HASHSTART(NAME_HASH);                                             00561800
      DO WHILE I > 0;                                                           00561900
         IF BCD = SYT_NAME(I) THEN                                              00562000
            GO TO MAYBE_FOUND;                                                  00562100
NOT_FOUND_YET:                                                                  00562200
         I = SYT_HASHLINK(I);                                                   00562300
      END;                                                                      00562400
Q_TRAP:                                                                         00562500
 /*  SPECIAL TRAP FOR QUALIFIED STRUCTURE NAMES  */                             00562600
      IF QUALIFICATION>0 THEN DO;                                               00562700
         QUALIFICATION,IMPLIED_TYPE,SYT_INDEX=0;                                00562800
         TOKEN=ID_TOKEN;                                                        00562900
         CALL ERROR(CLASS_IS,1);                                                00563000
         RETURN;                                                                00563100
      END;                                                                      00563200
 /*  COME TO HERE FOR ALL UNQUALIFIED UNKNOWN NAMES  */                         00563300
NOT_FOUND:                                                                      00563400
      IF CENT_IDENTIFY THEN DO;                                                 00563500
         TOKEN=0;                                                               00563600
         RETURN;                                                                00563700
      END;                                                                      00563800
                                                                                00563900
      DO CASE CONTEXT;                                                          00564000
                                                                                00564100
         DO;            /*  ORDINARY  */                          /*  CASE 0  */00564200
            IF LABEL_IMPLIED THEN                                               00564300
DO_LAB:                                                                         00564400
            DO;                                                                 00564500
               I = ENTER(BCD, LABEL_CLASS);                                     00564600
               SYT_TYPE(I) = UNSPEC_LABEL;                                      00564700
               SYT_FLAGS(I) = SYT_FLAGS(I) | DEFINED_LABEL;                     00564800
               GO TO LAB_OP_CHECK;                                              00564900
            END;                                                                00565000
            IF BCD = 'T' THEN                                                   00565100
               IMPLICIT_T = TRUE;                                               00565200
            ELSE                                                                00565300
               CALL ERROR(CLASS_DU, 1, BCD);                                    00565400
MAKE_DEFAULT:                                                                   00565500
            I = ENTER(BCD, VAR_CLASS);                                          00565600
            SYT_FLAGS(I) = SYT_FLAGS(I) | IMP_DECL;                             00565700
            IF BUILDING_TEMPLATE THEN                                           00565710
               SYT_FLAGS(REF_ID_LOC) = SYT_FLAGS(REF_ID_LOC) | EVIL_FLAG;       00565720
ADD_DEFAULT:                                                                    00565800
            IF IMPLIED_TYPE = 0 THEN SYT_TYPE(I) = DEFAULT_TYPE;                00565900
            ELSE SYT_TYPE(I) = IMPLIED_TYPE;                                    00566000
            IF SYT_TYPE(I) > INT_TYPE THEN GO TO SET_INITIAL_FLAGS;             00566100
            IF SYT_TYPE(I) <= CHAR_TYPE THEN GO TO SET_DEF_BC;                  00566200
 /* INTEGER SCALAR VECTOR OR MATRIX */                                          00566300
            IF SYT_TYPE(I) >= SCALAR_TYPE THEN GO TO SET_INITIAL_FLAGS;         00566400
            IF SYT_TYPE(I) = VEC_TYPE THEN                                      00566500
               VAR_LENGTH(I) = DEF_VEC_LENGTH;                                  00566600
            ELSE VAR_LENGTH(I) = DEF_MAT_LENGTH;                                00566700
            GO TO SET_INITIAL_FLAGS;                                            00566800
SET_DEF_BC:                                                                     00566900
            IF SYT_TYPE(I) = CHAR_TYPE THEN                                     00567000
               VAR_LENGTH(I) = DEF_CHAR_LENGTH;                                 00567100
            ELSE VAR_LENGTH(I) = DEF_BIT_LENGTH;                                00567200
SET_INITIAL_FLAGS:                                                              00567300
            IF SYT_TYPE(I) <= INT_TYPE THEN                                     00567400
               SYT_FLAGS(I) = SYT_FLAGS(I) | DEFAULT_ATTR;                      00567500
            DO CASE SYT_TYPE(I);                                                00567600
                                                                                00567700
               CALL ERROR(CLASS_BX, 2); /* COMPILER_ERROR IF TYPE = 0 */        00567800
                                                                                00567900
               TOKEN = BIT_TOKEN;                                               00568000
                                                                                00568100
               TOKEN = CHAR_TOKEN;                                              00568200
                                                                                00568300
               TOKEN = ARITH_TOKEN;                                             00568400
                                                                                00568500
               TOKEN = ARITH_TOKEN;                                             00568600
                                                                                00568700
               TOKEN = ARITH_TOKEN;                                             00568800
                                                                                00568900
               TOKEN = ARITH_TOKEN;                                             00569000
                                                                                00569100
               TOKEN = 0;                                                       00569200
                                                                                00569300
               TOKEN = 0;                                                       00569400
                                                                                00569500
               TOKEN = EVENT_TOKEN;  /* NOT POSSIBLE?? */                       00569600
                                                                                00569700
            END;  /* OF DO CASE SYT_TYPE(I) */                                  00569800
         END;  /* OF ORDINARY  CASE 0 */                                        00569900
         DO;            /* EXPRESSION CONTEXT */                  /*  CASE 1  */00570000
            CALL ERROR(CLASS_DI, 11, BCD);                                      00570100
            GO TO MAKE_DEFAULT;                                                 00570200
         END;                                                                   00570300
         DO;            /*  GO TO  */                             /*  CASE 2  */00570400
            FLAG = STMT_LABEL;                                                  00570500
LABELJOIN:                                                                      00570600
            I = ENTER(BCD, LABEL_CLASS);                                        00570700
            SYT_TYPE(I) = FLAG;                                                 00570800
LAB_OP_CHECK:                                                                   00570900
            TOKEN = LAB_TOKEN;                                                  00571000
            IF IMPLIED_TYPE ^= 0 THEN                                           00571200
               CALL ERROR(CLASS_MC,1,BCD);                                      00571300
         END;                                                                   00571400
                                                                                00571500
         DO;            /*  CALL  */                              /*  CASE 3  */00571600
            FLAG = PROC_LABEL;  /* ONLY PROCS MAY BE CALLED */                  00571700
            CONTEXT = 0;      /*  IN CASE PARAMETERS FOLLOW  */                 00571800
            FIXING=1;                                                           00571900
            GO TO LABELJOIN;                                                    00572000
         END;                                                                   00572100
                                                                                00572200
         DO;            /*  SCHEDULE  */                          /*  CASE 4  */00572300
            FLAG = TASK_LABEL;  /* ONLY TASKS CAN BE "NOT FOUND" */             00572400
            CONTEXT = 0;                                                        00572500
            GO TO LABELJOIN;                                                    00572600
         END;                                                                   00572700
                                                                                00572800
         DO;            /*  DECLARE  */                           /*  CASE 5  */00572900
            FACTORING = FALSE;                                                  00573000
            IF IMPLIED_TYPE^=0 THEN CALL ERROR(CLASS_MC,6,BCD);                 00573100
            IF TEMPORARY_IMPLIED THEN DO;                                       00573200
               FLAG=FLAG|TEMPORARY_FLAG;                                        00573300
               IF NEXT_CHAR=BYTE('=') THEN TEMPORARY_IMPLIED=FALSE;             00573400
            END;                                                                00573500
            IF DONT_ENTER>0 THEN DO;                                            00573600
               I=DONT_ENTER;                                                    00573700
               DONT_ENTER=0;                                                    00573800
               TOKEN=ID_TOKEN;                                                  00573900
               GO TO IDENTIFY_EXIT;                                             00574000
            END;                                                                00574100
            GO TO DCLJOIN;                                                      00574200
         END;                                                                   00574300
                                                                                00574400
         DO;            /* INPUT PARAMETER */                     /*  CASE 6  */00574500
            IF LOOKUP_ONLY THEN DO;                                             00574600
               TOKEN=STRUCT_TEMPLATE;                                           00574700
               GO TO IDENTIFY_EXIT;                                             00574800
            END;                                                                00574900
            FLAG = INPUT_PARM;                                                  00575000
PARMJOIN:                                                                       00575100
            IF IMPLIED_TYPE^=0 THEN CALL ERROR(CLASS_MC,5,BCD);                 00575200
            FLAG = FLAG | IMP_DECL;                                             00575300
DCLJOIN:                                                                        00575400
            I = ENTER(BCD, VAR_CLASS);                                          00575500
            SYT_FLAGS(I) = SYT_FLAGS(I) | FLAG;                                 00575600
            TOKEN = ID_TOKEN;                                                   00575700
         END;                                                                   00575800
                                                                                00575900
         DO;            /*  ASSIGN PARM  */                       /*  CASE 7  */00576000
            FLAG = ASSIGN_PARM;                                                 00576100
            GO TO PARMJOIN;                                                     00576200
         END;                                                                   00576300
                                                                                00576400
         DO;            /*  REPLACE  */                           /*  CASE 8  */00576500
            SYT_INDEX = ENTER(BCD, REPL_CLASS);                                 00576600
            TOKEN = ID_TOKEN;                                                   00576700
            MACRO_NAME = BCD;                                                   00576800
            CONTEXT = REPLACE_PARM_CONTEXT;                                     00576900
            GO TO REPL_OP_CHECK;                                                00577000
         END;                                                                   00577100
                                                                                00577200
         DO;            /*  CLOSE  */                             /*  CASE 9  */00577300
            I = - 1;    /*  SHOULD NEVER BE REFERRED TO  */                     00577400
            GO TO LAB_OP_CHECK;     /*  CLOSE PRODUCTION DOES THE WORK  */      00577500
         END;                                                                   00577600
         DO;        /*     REPLACE DEFINITION PARAMETERS */      /* CASE 10 */  00577700
            TOKEN = ID_TOKEN;                                                   00577800
            SYT_INDEX = ENTER(BCD,REPL_ARG_CLASS);                              00577900
            SYT_FLAGS(SYT_INDEX) = INACTIVE_FLAG;                               00578000
            GO TO REPL_OP_CHECK;                                                00578100
         END;                                                                   00578200
                                                                                00578300
         DO;  /* EQUATE */                                                      00578400
            IF IMPLIED_TYPE ^= 0 THEN                                           00578500
               CALL ERROR(CLASS_MC, 7, SUBSTR(BCD, 1));                         00578600
            TOKEN = ID_TOKEN;                                                   00578700
            I = ENTER(BCD, LABEL_CLASS);                                        00578800
            SYT_FLAGS(I) = INACTIVE_FLAG;  /* WILL BE LEFT IN HASH TABLE        00578900
                                                 FOREVER SINCE IT APPEARS TO    00579000
                                                 BE ALREADY DISCONNECTED BY     00579100
                                                 USE OF INACTIVE_FLAG */        00579200
            SYT_TYPE(I) = EQUATE_LABEL;                                         00579300
            CONTEXT = EXPRESSION_CONTEXT;                                       00579400
            NAMING, DELAY_CONTEXT_CHECK = TRUE;                                 00579410
         END;                                                                   00579500
                                                                                00579600
      END;        /*  OF DO CASE CONTEXT FOR NAME NOT FOUND  */                 00579700
                                                                                00579800
      GO TO IDENTIFY_EXIT;                                                      00579900
                                                                                00580000
 /***************************************************************************/  00580100
                                                                                00580200
 /*  HERE WHEN NAME IS ALREADY IN SYMBOL TABLE:  */                             00580300
                                                                                00580400
MAYBE_FOUND:                                                                    00580500
      IF SYT_CLASS(I) = REPL_CLASS THEN                                         00580600
         DO;                                                                    00580700
         IF CONTEXT ^= REPL_CONTEXT THEN                                        00580800
            DO;                                                                 00580900
            SYT_INDEX = I;                                                      00581000
            TOKEN = - 1;     /*  SPECIAL TOKEN FOR REPLACEMENT  */              00581100
            CALL BUFFER_MACRO_XREF(I);                                          00581200
REPL_OP_CHECK:                                                                  00581300
            IF IMPLIED_TYPE ^= 0 THEN                                           00581400
               DO;                                                              00581500
               CALL ERROR(CLASS_MC,3);                                          00581600
               IMPLIED_TYPE = 0;                                                00581700
            END;                                                                00581800
            RETURN;                                                             00581900
         END;                                                                   00582000
         ELSE IF I < PROCMARK THEN GO TO NOT_FOUND;                             00582100
         ELSE CALL ERROR(CLASS_IR,5,BCD);                                       00582200
      END;                                                                      00582300
      ELSE IF I < PROCMARK THEN                                                 00582400
         IF CONTEXT ^= EQUATE_CONTEXT THEN                                      00582500
         IF CONTEXT > DECLARE_CONTEXT THEN GO TO NOT_FOUND;                     00582600
      IF CENT_IDENTIFY THEN DO;                                                 00582700
         TOKEN=0;                                                               00582800
         RETURN;                                                                00582900
      END;                                                                      00583000
                                                                                00583100
      DO CASE CONTEXT;        /*****  NAME FOUND  *****/                        00583200
                                                                                00583300
MAKE_TOKEN:                                                                     00583400
         DO CASE SYT_CLASS(I);     /*  ORDINARY  */               /*  CASE 0  */00583500
                                                                                00583600
            CALL ERROR(CLASS_BX,1,BCD);                         /*  CASE 0.0  */00583700
                                                                                00583800
            DO;          /*  VARIABLE  */                       /*  CASE 0.1 */ 00583900
               IF QUALIFICATION>0 THEN GO TO NOT_FOUND_YET;                     00584000
 /*CR13335*/   IF SYT_TYPE(I)=MAJ_STRUC THEN IF NEXT_CHAR=BYTE(PERIOD) THEN DO; 00584100
                  QUALIFICATION=VAR_LENGTH(I);                                  00584200
                  IF (SYT_FLAGS(QUALIFICATION)&EVIL_FLAG)^=0 THEN GO TO Q_TRAP; 00584300
               END;                                                             00584400
TEMPL_FIXUP:                                                                    00584500
               IF LABEL_IMPLIED THEN                                            00584600
                  DO;                                                           00584700
                  IF I < PROCMARK THEN                                          00584900
                     DO;                                                        00585000
BAD_LAB_DEF:                                                                    00585100
                     CALL ERROR(CLASS_PM,3,BCD);                                00585200
                     GO TO DO_LAB;                                              00585300
                  END;                                                          00585400
                  CALL ERROR(CLASS_P,4,BCD);                                    00585500
               END;                                                             00585600
               DO CASE IMPLIED_TYPE;                                            00585700
NO_OVERPUNCH:                                                                   00585800
                  DO CASE SYT_TYPE(I);                     /*  CASE 0.1.0  */   00585900
                                                                                00586000
                     DO;                                 /*  CASE 0.1.0.0  */   00586100
                        CALL ERROR(CLASS_DU, 4, BCD);                           00586200
                        GO TO ADD_DEFAULT;                                      00586300
                     END;                                                       00586400
                                                                                00586500
                     TOKEN = BIT_TOKEN;                                         00586600
                                                                                00586700
                     TOKEN = CHAR_TOKEN;                                        00586800
                                                                                00586900
                     TOKEN = ARITH_TOKEN;     /*  UNMARKED MATRIX  */           00587000
                                                                                00587100
                     TOKEN = ARITH_TOKEN;     /*  UNMARKED VECTOR  */           00587200
                                                                                00587300
                     TOKEN = ARITH_TOKEN;                                       00587400
                                                                                00587500
                     TOKEN = ARITH_TOKEN;                /*  CASE 0.1.0.6  */   00587600
                                                                                00587700
                     TOKEN = 0;    /*  COMPILER ERROR  */                       00587800
                                                                                00587900
                     TOKEN = 0;    /*  COMPILER ERROR  */                       00588000
                                                                                00588100
                     TOKEN = EVENT_TOKEN;               /*  CASE 0.1.0.9  */    00588200
                                                                                00588300
                     TOKEN = STRUC_TOKEN;               /*  CASE 0.1.0.10 */    00588400
                  END;     /*  OF DO CASE SYT_TYPE(I)  */                       00588500
                                                                                00588600
                  IF SYT_TYPE(I) = BIT_TYPE THEN TOKEN = BIT_TOKEN; /*0.1.1*/   00588700
                  ELSE GO TO OP_TYPE_MISMATCH;                                  00588800
                                                                                00588900
                  IF SYT_TYPE(I) = CHAR_TYPE THEN TOKEN = CHAR_TOKEN;           00589000
                  ELSE GO TO OP_TYPE_MISMATCH;                                  00589100
                                                                                00589200
                  IF SYT_TYPE(I) = MAT_TYPE THEN TOKEN = ARITH_TOKEN;           00589300
                  ELSE GO TO OP_TYPE_MISMATCH;                                  00589400
                                                                                00589500
                  IF SYT_TYPE(I) = MAT_TYPE THEN TOKEN = ARITH_TOKEN;           00589600
                  ELSE IF SYT_TYPE(I) = VEC_TYPE THEN TOKEN = ARITH_TOKEN;      00589700
                  ELSE                                                          00589800
OP_TYPE_MISMATCH:                                                               00589900
                  DO;                                                           00590000
                     CALL ERROR(CLASS_MO,2,BCD);                                00590100
                     IMPLIED_TYPE = 0;                                          00590200
                     GO TO NO_OVERPUNCH;                                        00590300
                  END;                                                          00590400
                                                                                00590500
               END;     /*  OF DO CASE IMPLIED_TYPE  */                         00590600
            END;     /*  OF VARIABLE  (CASE 0.1)  */                            00590700
                                                                                00590800
            DO;                    /*  LABEL NAME  */           /*  CASE 0.2  */00590900
               IF LABEL_IMPLIED THEN                                            00591000
                  DO;     /*  LABEL DEFINITION  */                              00591100
 /* DR111350 - DUPLICATE NAME OF EXTERNAL LABEL THAT IS NOT GOING */
 /* DR111350 - INTO SDF. SO TREAT IT AS A NEW LABEL FOR THIS      */
 /* DR111350 - COMPILATION UNIT                                   */
                  IF SYT_TYPE(I) = 0 THEN GO TO DO_LAB; /*DR111350*/
                  IF I < PROCMARK THEN GO TO DO_LAB;                            00591200
                  ELSE IF (SYT_FLAGS(I) & DEFINED_LABEL) = 0 THEN               00591300
                     DO;                                                        00591400
                     SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL;                   00591500
                     CALL SET_XREF(I,0);                                        00591600
                  END;                                                          00591700
                  ELSE IF SYT_TYPE(I) ^= IND_CALL_LAB THEN                      00591800
DUPL_LABEL:                                                                     00591900
                  CALL ERROR(CLASS_PL,2,BCD);                                   00592000
               END;                                                             00592100
               GO TO LAB_OP_CHECK;                                              00592200
            END;                                                                00592300
                                                                                00592400
            IF LABEL_IMPLIED THEN     /*  FUNCTION NAME  */     /*  CASE 0.3  */00592500
               DO;                                                              00592600
               IF I < PROCMARK THEN GO TO BAD_LAB_DEF;                          00592700
               IF (SYT_FLAGS(I) & DEFINED_LABEL) ^= 0 THEN GO TO DUPL_LABEL;    00592800
               SYT_FLAGS(I) = SYT_FLAGS(I) | DEFINED_LABEL;                     00592900
               CALL SET_XREF(I,0);    /* DR111365 */
               GO TO LAB_OP_CHECK;                                              00593000
            END;                                                                00593100
            ELSE                                                                00593200
FUNC_CHECK:                                                                     00593300
            DO;                                                                 00593400
               IF IMPLIED_TYPE ^= 0 THEN                                        00593500
                  DO;                                                           00593600
                  CALL ERROR(CLASS_MC, 2);                                      00593700
                  IMPLIED_TYPE = 0;                                             00593800
               END;                                                             00593900
               IF (SYT_FLAGS2(I)&NONHAL_FLAG)^=0 THEN  /* DR108643 */           00594000
                  GO TO YES_ARG;                                                00594100
               IF (SYT_FLAGS(I)&DEFINED_LABEL)=0 THEN GO TO YES_ARG;            00594200
               IF SYT_PTR(I) = 0 THEN GO TO NO_ARG_FUNC;                        00594300
               IF (SYT_FLAGS(SYT_PTR(I)) & INPUT_PARM) = 0 THEN                 00594400
                  GO TO NO_ARG_FUNC;                                            00594500
YES_ARG:                                                                        00594600
               DO CASE SYT_TYPE(I);                                             00594700
FUNC_TOKEN_ZERO:                                                                00594800
                  CALL ERROR(CLASS_BX, 2);    /* COMPILER ERROR */              00594900
                                                                                00595000
                  TOKEN = BIT_FUNC_TOKEN;                                       00595100
                                                                                00595200
                  TOKEN = CHAR_FUNC_TOKEN;                                      00595300
                                                                                00595400
                  TOKEN = ARITH_FUNC_TOKEN;                                     00595500
                                                                                00595600
                  TOKEN = ARITH_FUNC_TOKEN;                                     00595700
                                                                                00595800
                  TOKEN = ARITH_FUNC_TOKEN;                                     00595900
                                                                                00596000
                  TOKEN = ARITH_FUNC_TOKEN;                                     00596100
                                                                                00596200
                  TOKEN = 0;    /* COMPILER ERROR */                            00596300
                                                                                00596400
                  TOKEN = ARITH_FUNC_TOKEN;                                     00596500
                                                                                00596600
                  TOKEN = 0;  /* EVENT = COMPILER ERROR */                      00596700
                                                                                00596800
                  TOKEN = STRUCT_FUNC_TOKEN;                                    00596900
               END;  /* OF DO CASE SYT_TYPE(I)  */                              00597000
               GO TO END_FUNC_CHECK;                                            00597100
NO_ARG_FUNC:                                                                    00597200
               IF ^NAMING THEN FIXING=2;                                        00597300
BUILT_IN:                                                                       00597400
               DO CASE SYT_TYPE(I);                                             00597500
                                                                                00597600
                  GO TO FUNC_TOKEN_ZERO;                                        00597700
                                                                                00597800
                  TOKEN = NO_ARG_BIT_FUNC;                                      00597900
                                                                                00598000
                  TOKEN = NO_ARG_CHAR_FUNC;                                     00598100
                                                                                00598200
                  TOKEN = NO_ARG_ARITH_FUNC;                                    00598300
                                                                                00598400
                  TOKEN = NO_ARG_ARITH_FUNC;                                    00598500
                                                                                00598600
                  TOKEN = NO_ARG_ARITH_FUNC;                                    00598700
                                                                                00598800
                  TOKEN = NO_ARG_ARITH_FUNC;                                    00598900
                                                                                00599000
                  TOKEN = 0;    /* COMPILER ERROR */                            00599100
                                                                                00599200
                  TOKEN = NO_ARG_ARITH_FUNC;                                    00599300
                                                                                00599400
                  TOKEN = 0;   /* EVENT = COMPILER ERROR */                     00599500
                                                                                00599600
                  TOKEN = NO_ARG_STRUCT_FUNC;                                   00599700
               END;                                                             00599800
END_FUNC_CHECK:                                                                 00599900
            END;  /* OF FUNC_CHECK */                                           00600000
            ;    /* NO MORE STRUCTURE CLASS */                                  00600100
                                                                                00600200
            ;        /*  REPL ARG CLASS  */                      /* CASE 0.5 */ 00600300
                                                                                00600400
            ;       /* REPL  CLASS */                           /*  CASE 0.6  */00600500
                                                                                00600600
 /*  TEMPLATE CLASS  */                              /*  CASE 0.7 */            00600700
ALL_TPLS:   IF QUALIFICATION>0 THEN DO;                                         00600800
               IF SYT_TYPE(QUALIFICATION)=MAJ_STRUC THEN                        00600900
                  IF VAR_LENGTH(QUALIFICATION)>0 THEN DO;                       00601000
                  QUALIFICATION=VAR_LENGTH(QUALIFICATION);                      00601100
                  IF (SYT_FLAGS(QUALIFICATION)&EVIL_FLAG)^=0 THEN GO TO Q_TRAP; 00601200
               END;                                                             00601300
               KIN=SYT_LINK1(QUALIFICATION);                                    00601400
               DO WHILE KIN>0;                                                  00601500
                  IF KIN=I THEN DO;                                             00601600
  /*CR13335*/        IF SYT_TYPE(I)^=MAJ_STRUC|NEXT_CHAR^=BYTE(PERIOD) THEN     00601700
                        QUALIFICATION=0;                                        00601800
                     ELSE QUALIFICATION=I;                                      00601900
                     GO TO TEMPL_BRANCH;                                        00602000
                  END;                                                          00602100
                  KIN=SYT_LINK2(KIN);                                           00602200
               END;                                                             00602300
               GO TO NOT_FOUND_YET;                                             00602400
            END;                                                                00602500
            ELSE DO;                                                            00602600
               KIN=I;                                                           00602700
               DO WHILE SYT_TYPE(KIN)^=TEMPL_NAME;                              00602800
                  KIN=KIN-1;                                                    00602900
               END;                                                             00603000
               IF SYT_PTR(KIN)=0 THEN GO TO NOT_FOUND_YET;                      00603100
               VALUE=SYT_PTR(KIN);                                              00603200
TEMPL_BRANCH:                                                                   00603300
               DO CASE SYT_CLASS(I)-TEMPLATE_CLASS;                             00603400
                  GO TO TEMPL_FIXUP;                                            00603500
                  GO TO LAB_OP_CHECK;                                           00603600
                  GO TO FUNC_CHECK;                                             00603700
               END;                                                             00603800
            END;                                                                00603900
 /*  TEMPLATE LABEL CLASS   */                      /* CASE 0.8 */              00604000
            GO TO ALL_TPLS;                                                     00604100
 /*  TEMPLATE FUNCTION CLASS */                       /* CASE 0.9 */            00604200
            GO TO ALL_TPLS;                                                     00604300
         END;  /* OF DO CASE SYT_CLASS(I) FOR ORDINARY */                       00604400
                                                                                00604500
 /* EXPRESSION CONTEXT */                                                       00604600
         GO TO MAKE_TOKEN;                                       /*  CASE 1  */ 00604700
                                                                                00604800
         DO;            /*  GO TO  */                             /*  CASE 2  */00604900
            K = SYT_TYPE(I);                                                    00605000
            IF I < PROCMARK THEN                                                00605100
               DO;                                                              00605200
               J = ENTER(BCD, LABEL_CLASS);                                     00605300
               SYT_TYPE(J) = STMT_LABEL;                                        00605400
               IF SYT_CLASS(I) ^= LABEL_CLASS THEN                              00605500
OVERRIDE_ERR:                                                                   00605600
               CALL ERROR(CLASS_PM, 4, BCD);                                    00605700
               I = J;                                                           00605800
            END;                                                                00605900
            ELSE IF SYT_CLASS(I) ^= LABEL_CLASS THEN GO TO MAKE_TOKEN;          00606000
            ELSE IF SYT_TYPE(I) = UNSPEC_LABEL THEN                             00606100
               SYT_TYPE(I) = STMT_LABEL;                                        00606200
            ELSE IF SYT_TYPE(I) > UNSPEC_LABEL THEN                             00606300
               CALL ERROR(CLASS_DT, 3, BCD);                                    00606500
            GO TO LAB_OP_CHECK;                                                 00606600
         END;                                                                   00606700
                                                                                00606800
         DO;            /*  CALL  */                              /*  CASE 3  */00606900
            CONTEXT = 0;     /*  IN CASE ARGUMENTS FOLLOW  */                   00607000
            FIXING=1;                                                           00607100
            K = SYT_TYPE(I);                                                    00607200
            IF SYT_CLASS(I)^=LABEL_CLASS THEN GO TO MAKE_TOKEN;                 00607300
            IF I < PROCMARK THEN                                                00607400
               DO;                                                              00607500
               J = ENTER(BCD, LABEL_CLASS);                                     00607600
               IF (K = IND_CALL_LAB) | (K = PROC_LABEL) THEN                    00607700
                  DO;                                                           00607800
                  SYT_TYPE(J) = IND_CALL_LAB;                                   00607900
                  SYT_PTR(J) = I;                                               00608000
                  SYT_FLAGS(J) = SYT_FLAGS(J) | DEFINED_LABEL;                  00608100
               END;                                                             00608200
               ELSE                                                             00608300
                  DO;                                                           00608400
                  SYT_TYPE(J) = PROC_LABEL;                                     00608500
                  GO TO OVERRIDE_ERR;                                           00608600
               END;                                                             00608700
               I = J;                                                           00608800
            END;                                                                00608900
            GO TO LAB_OP_CHECK;                                                 00609000
         END;                                                                   00609100
                                                                                00609200
         DO;            /*  SCHEDULE  */                          /*  CASE 4  */00609300
            CONTEXT = 0;                                                        00609400
            GO TO MAKE_TOKEN;                                                   00609500
         END;                                                                   00609600
                                                                                00609700
         DO;            /*  DECLARE  */                           /*  CASE 5  */00609800
            IF LOOKUP_ONLY THEN DO;                                             00609900
               TOKEN = STRUCT_TEMPLATE;                                         00610000
               GO TO IDENTIFY_EXIT;                                             00610100
            END;                                                                00610200
            IF I < PROCMARK THEN                                                00610300
               GO TO NOT_FOUND;                                                 00610400
            IF BUILDING_TEMPLATE THEN DO;                                       00610500
               SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)|DUPL_FLAG;           00610600
               IF SYT_CLASS(I)>=TEMPLATE_CLASS THEN DO;                         00610700
                  IF I<REF_ID_LOC THEN DO;                                      00610800
                     CALL SET_DUPL_FLAG(I);                                     00610900
                     GO TO NOT_FOUND_YET;                                       00611900
                  END;                                                          00612000
                  ELSE FLAG=DUPL_FLAG;                                          00612100
               END;                                                             00612200
            END;                                                                00612300
            ELSE IF TEMPORARY_IMPLIED THEN DO;                                  00612400
               CALL ERROR(CLASS_PM,1,BCD);                                      00612500
               GO TO NOT_FOUND;                                                 00612600
            END;                                                                00612700
            ELSE DO;                                                            00612800
               IF TEMPLATE_IMPLIED THEN DO;                                     00612900
                  CALL ERROR(CLASS_PM, 2, SUBSTR(BCD, 1));  /* DUPL TEMPLATE */ 00612910
                  GO TO NOT_FOUND;  /* ENTER ANYWAY */                          00612920
               END;                                                             00612930
               IF SYT_CLASS(I) >= TEMPLATE_CLASS THEN DO;                       00612940
                  CALL SET_DUPL_FLAG(I);                                        00612950
                  GO TO NOT_FOUND_YET;                                          00612960
               END;                                                             00612970
               IF (SYT_FLAGS(I)&IMP_DECL)^=0 THEN                               00613000
                  SYT_FLAGS(I)=SYT_FLAGS(I)&(^IMP_DECL);                        00613100
               ELSE CALL ERROR(CLASS_PM,1,BCD);                                 00613200
               CALL SET_XREF(I,0);                                              00613300
               DONT_ENTER=I;                                                    00613400
            END;                                                                00613500
            GO TO NOT_FOUND_YET;                                                00613600
         END;                                                                   00613700
                                                                                00613800
ASSIGN_TOO:                                                                     00613900
         DO;            /*  INPUT PARAMETER  */                   /*  CASE 6  */00614000
            IF LOOKUP_ONLY THEN DO;                                             00614010
               TOKEN=STRUCT_TEMPLATE;                                           00614020
               GO TO IDENTIFY_EXIT;                                             00614030
            END;                                                                00614040
            CALL ERROR(CLASS_FN,3,BCD);                                         00614100
            TOKEN = ID_TOKEN;                                                   00614200
         END;                                                                   00614300
                                                                                00614400
         GO TO ASSIGN_TOO;     /*  ASSIGN PARAMETER  */           /*  CASE 7  */00614500
                                                                                00614600
         DO;            /*  REPLACE  */                           /*  CASE 8  */00614700
            CALL ERROR(CLASS_IR,1,BCD);  /* REPLACING A PARAMETER */            00614800
            TOKEN = ID_TOKEN;                                                   00614900
            CONTEXT = 0;                                                        00615000
         END;                                                                   00615100
                                                                                00615200
         DO;            /*  CLOSE  */                             /*  CASE 9  */00615300
            I = - 1;    /*  SHOULD NEVER BE REFERRED TO  */                     00615400
            GO TO LAB_OP_CHECK;     /*  CLOSE PRODUCTION DOES THE WORK  */      00615500
         END;                                                                   00615600
                                                                                00615700
         ;  /* CASE 10 */                                                       00615800
                                                                                00615900
         DO;  /* EQUATE */                                                      00616000
            CALL ERROR(CLASS_DU, 6, SUBSTR(BCD, 1));                            00616100
            TOKEN = ID_TOKEN;                                                   00616200
            CONTEXT = EXPRESSION_CONTEXT;                                       00616300
            NAMING, DELAY_CONTEXT_CHECK = TRUE;                                 00616310
         END;                                                                   00616400
                                                                                00616500
      END;     /*  OF DO CASE CONTEXT WHEN NAME WAS FOUND  */                   00616600
                                                                                00616700
IDENTIFY_EXIT:                                                                  00616800
      SYT_INDEX=SYT_INDEX+I;                                                    00616900
      RETURN;                                                                   00617000
                                                                                00617100
   END IDENTIFY     /*  AT LAST  */     /*  $S  */  ;  /*  $S  */               00617200
