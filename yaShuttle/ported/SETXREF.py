#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SYTDUMP.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-11 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SYT_DUMP                                               */
 /* MEMBER NAME:     SYTDUMP                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_ATTR          LABEL                                        */
 /*          ADD_QUOTE(1534)   LABEL                                        */
 /*          ADD_XREFS(1541)   LABEL                                        */
 /*          ATTR_START        BIT(16)                                      */
 /*          CHAR_ATTR(19)     CHARACTER;                                   */
 /*          CHECK_AND_ENTER(1538)  LABEL                                   */
 /*          CUSS(7)           CHARACTER;                                   */
 /*          DEFINITION_FOUND(1524)  LABEL                                  */
 /*          DOUBLE_QUOTE(1535)  LABEL                                      */
 /*          ENTER_SORT(1544)  LABEL                                        */
 /*          EXCHANGES         BIT(8)                                       */
 /*          FLAG_MASK(19)     FIXED                                        */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          JI                FIXED                                        */
 /*          JL                FIXED                                        */
 /*          K                 FIXED                                        */
 /*          KI                FIXED                                        */
 /*          KL                FIXED                                        */
 /*          L                 FIXED                                        */
 /*          LABEL_NAME(13)    CHARACTER;                                   */
 /*          LABEL_TYPES       CHARACTER;                                   */
 /*          LM                LABEL                                        */
 /*          M                 FIXED                                        */
 /*          MACRO_END(1498)   LABEL                                        */
 /*          MACRO_LOOP(1514)  LABEL                                        */
 /*          MACRO_TEXT_RESET(1551)  LABEL                                  */
 /*          MAX_LENGTH        BIT(16)                                      */
 /*          N_FIX(1516)       LABEL                                        */
 /*          NAMER             CHARACTER;                                   */
 /*          NEWLINE(1500)     LABEL                                        */
 /*          NO_INDIRECT       LABEL                                        */
 /*          NO_SREF           LABEL                                        */
 /*          NO_XREF(1512)     LABEL                                        */
 /*          R                 CHARACTER;                                   */
 /*          S                 CHARACTER;                                   */
 /*          SORT_COUNT        BIT(16)                                      */
 /*          STORE_BI_XREF     LABEL                                        */
 /*          T                 CHARACTER;                                   */
 /*          T_CASE            BIT(16)                                      */
 /*          T_LEVEL           BIT(16)                                      */
 /*          T_REFS(1505)      LABEL                                        */
 /*          V_ARRAY           CHARACTER;                                   */
 /*          V_LEN             CHARACTER;                                   */
 /*          VAR_NAME(10)      CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_PARM                                                    */
 /*          BI_LIMIT                                                       */
 /*          BI_NAME                                                        */
 /*          BI_XREF_CELL                                                   */
 /*          BI#                                                            */
 /*          BLOCK_SYTREF                                                   */
 /*          CLASS_BI                                                       */
 /*          COMPOOL_LABEL                                                  */
 /*          CR_REF                                                         */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          DUPL_FLAG                                                      */
 /*          EJECT_PAGE                                                     */
 /*          EOFILE                                                         */
 /*          EQUATE_LABEL                                                   */
 /*          EVENT_TYPE                                                     */
 /*          EVIL_FLAG                                                      */
 /*          EXT_ARRAY                                                      */
 /*          EXTERNAL_FLAG                                                  */
 /*          FALSE                                                          */
 /*          FIRST_STMT                                                     */
 /*          FOREVER                                                        */
 /*          FUNC_CLASS                                                     */
 /*          IMP_DECL                                                       */
 /*          IMPL_T_FLAG                                                    */
 /*          IND_CALL_LAB                                                   */
 /*          INIT_CONST                                                     */
 /*          INP_OR_CONST                                                   */
 /*          LATCHED_FLAG                                                   */
 /*          LOCK_FLAG                                                      */
 /*          MAC_TXT                                                        */
 /*          MACRO_TEXTS                                                    */
 /*          MACRO_TEXT                                                     */
 /*          MAIN_SCOPE                                                     */
 /*          MAJ_STRUC                                                      */
 /*          MAT_TYPE                                                       */
 /*          MAX_STRUC_LEVEL                                                */
 /*          MISC_NAME_FLAG                                                 */
 /*          MODF                                                           */
 /*          NAME_FLAG                                                      */
 /*          NDECSY                                                         */
 /*          PAGE                                                           */
 /*          PARM_FLAGS                                                     */
 /*          PROC_LABEL                                                     */
 /*          PROG_LABEL                                                     */
 /*          PROGRAM_LAYOUT_INDEX                                           */
 /*          PROGRAM_LAYOUT                                                 */
 /*          REPL_ARG_CLASS                                                 */
 /*          REPL_CLASS                                                     */
 /*          RIGID_FLAG                                                     */
 /*          SDF_INCL_OFF                                                   */
 /*          SDL_OPTION                                                     */
 /*          SREF_OPTION                                                    */
 /*          STMT_LABEL                                                     */
 /*          SUBHEADING                                                     */
 /*          SYM_ADDR                                                       */
 /*          SYM_ARRAY                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_LOCK#                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_SCOPE                                                      */
 /*          SYM_SORT                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYM_XREF                                                       */
 /*          SYT_ADDR                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_LOCK#                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_SCOPE                                                      */
 /*          SYT_SORT                                                       */
 /*          SYT_TYPE                                                       */
 /*          SYT_XREF                                                       */
 /*          TEMPL_NAME                                                     */
 /*          TEMPLATE_CLASS                                                 */
 /*          TOKEN                                                          */
 /*          TPL_FUNC_CLASS                                                 */
 /*          TRUE                                                           */
 /*          VAR_CLASS                                                      */
 /*          VAR_LENGTH                                                     */
 /*          VEC_TYPE                                                       */
 /*          XREF_FULL                                                      */
 /*          XREF_MASK                                                      */
 /*          XREF                                                           */
 /*          X1                                                             */
 /*          X256                                                           */
 /*          X2                                                             */
 /*          X4                                                             */
 /*          X70                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BI_XREF                                                        */
 /*          BI_XREF#                                                       */
 /*          COMM                                                           */
 /*          CONTROL                                                        */
 /*          CROSS_REF                                                      */
 /*          ERROR_COUNT                                                    */
 /*          LINK_SORT                                                      */
 /*          MAX_SEVERITY                                                   */
 /*          NOT_ASSIGNED_FLAG                                              */
 /*          SAVE_LINE_#                                                    */
 /*          SAVE_SEVERITY                                                  */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /*          ERRORS                                                         */
 /*          GET_CELL                                                       */
 /*          HEX                                                            */
 /*          I_FORMAT                                                       */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          COMPILATION_LOOP                                               */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''

class cSYT_DUMP: # Local variables for SYT_DUMP().
    def __init__(self):
        self.HEADER_PRINTED = g.FALSE
        self.R = ''
        self.S = ''
        self.T = ''
        self.V_LEN = ''
        self.V_ARRAY = ''
        self.T_LEVEL = 0
        self.T_CASE = 0
        self.I = 0
        self.J = 0
        self.K = 0
        self.L = 0
        self.M = 0
        self.JI = 0
        self.KI = 0
        self.JL = 0
        self.KL = 0
        self.SORT_COUNT = 0
        self.MAX_LENGTH = 0
        self.ATTR_START = 0
        self.EXCHANGES = 0
        '''
        CHANGED VAR_NAME FROM A CHARACTER ARRAY OF 10 TO A SINGLE
        STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.
        11 CHARACTER SPACES FOR EACH VARIABLE NAME.
        '''
        self.VAR_NAME = '? DATA TYPEBIT        CHARACTER  MATRIX     ' + \
                        'VECTOR     SCALAR     INTEGER    <BORC>     ' + \
                        '<IORS>     EVENT      STRUCTURE  '
        '''
        CHANGED LABEL_NAME FROM A CHARACTER ARRAY OF 13 TO A SINGLE
        STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.
        18 CHARACTER SPACES FOR EACH LABEL NAME.
        '''
        self.LABEL_NAME = 'STRUCTURE TEMPLATETEMPLATE REFERENCE' + \
                          '<MB STMT LAB>     <IND STMT LAB>    ' + \
                          'STATEMENT LABEL   ? LABEL           ' + \
                          '<MBCALL LABEL>    <IND CALL LABEL>  ' + \
                          '<CALLED LABEL>    PROCEDURE         ' + \
                          'TASK              PROGRAM           ' + \
                          'COMPOOL           EQUATE LABEL      '
        '''
        CHANGED CUSS FROM CHARACTER ARRAY OF 7 TO A SINGLE STRING
        TO REDUCE THE NUMBER OF STRINGS IN PASS1. 23 CHARACTER
        SPACES FOR EACH CUSS PHRASE. THERE ARE BLANK PHRASES
        STARTING AT LOCATIONS 92 & 184.
        '''
        self.CUSS = 'NOT USED               ' + \
                    'NOT ASSIGNED           ' + \
                    'NOT REFERENCED         ' + \
                    '                       ' + \
                    'POSSIBLY NOT USED      ' + \
                    'POSSIBLY NOT ASSIGNED  ' + \
                    'POSSIBLY NOT REFERENCED' + \
                    '                       '
        self.LABEL_TYPES = \
            'FUNCTION; UPDATE;   PROCEDURE;TASK;     PROGRAM;  COMPOOL;  '
        self.FLAG_MASK = (
            0,
            0x00800000,     # SINGLE
            0x00400000,     # DOUBLE
            0x08000000,     # TEMPORARY
            0x04000000,     # RIGID  (AS MODIFIED IN CHECK_AND_ENTER)
            0x00000004,     # DENSE
            0x00000008,     # ALIGNED
            0x00000020,     # ASSIGN
            0x00000400,     # INPUT
            0x00000100,     # AUTOMATIC
            0x00000200,     # STATIC
            0x00000800,     # INITIAL
            0x00001000,     # CONSTANT
            0x00010000,     # ACCESS
            0x00000002,     # REENTRANT
            0x00080000,     # EXCLUSIVE
            0x00100000,     # EXTERNAL
            0x00000080,     # REMOTE
            0x02000000      # INCLUDED_REMOTE
            )
        '''
        CHANGED CHAR_ATTR FROM A CHARACTER ARRAY OF 19 TO A SINGLE
        STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.
        11 CHARACTER SPACES FOR EACH CHARACTER ATTRIBUTE.
        '''
        self.CHAR_ATTR = 'LOCK=*     SINGLE     DOUBLE     TEMPORARY  ' + \
                         'RIGID      DENSE      ALIGNED    ASSIGN-PARM' + \
                         'INPUT-PARM AUTOMATIC  STATIC     INITIAL    ' + \
                         'CONSTANT   ACCESS     REENTRANT  EXCLUSIVE  ' + \
                         'EXTERNAL   REMOTE     INCREM     '
        self.NAMER = 'NAME'
        self.LABEL_ON_END = g.FALSE
lSYT_DUMP = cSYT_DUMP()

def SYT_DUMP():
    # PRINTS THE SYMBOL TABLE HEADER.
    PRINT_SYMBOL_HEADER:
    PROCEDURE(STRUC,NEW_PAGE);
       DECLARE STRUC BIT(1);
       DECLARE NEW_PAGE BIT(1);
       DECLARE J BIT(16);
       IF STRUC THEN
          OUTPUT(1)='0S T R U C T U R E   T E M P L A T E   S Y M B O L  &  C
    R O S S   R E F E R E N C E   T A B L E   L I S T I N G :';
       ELSE DO;
          HEADER_PRINTED=TRUE;
          IF NEW_PAGE THEN DO;
             OUTPUT(1)=SUBHEADING;
             EJECT_PAGE;
          END;
          OUTPUT(1) = '0S Y M B O L  &  C R O S S   R E F E R E N C E   T A B
    L E   L I S T I N G :';
       END;
       IF MAX_LENGTH < 4 THEN J = 4;
       ELSE J = MAX_LENGTH;
       OUTPUT(1) = '0         (CROSS REFERENCE FLAG KEY:  4 = ASSIGNMENT, 2 =
    REFERENCE, 1 = SUBSCRIPT USE, 0 = DEFINITION)';
       S = ' DCL  NAME'||SUBSTR(X70,0,J-3)||'        TYPE
    ATTRIBUTES & CROSS REFERENCE';
       OUTPUT(1) = DOUBLE || S;
       OUTPUT(1) = SUBHEADING || S;
       OUTPUT = X1;
    END;
    
    /*CR12940 - PRINTS THE STRUCTURES THAT ARE DECLARED USING THE CURRENT TEMPLATE*/
    PRINT_VAR_NAMES:
    PROCEDURE(SYT_NO,M);
       DECLARE SYT_NO FIXED;/*SYMBOL TABLE ENTRY FOR THE STRUCTURE TEMPLATE.*/
       DECLARE M FIXED;/*INDEX INTO SORTED SYMBOL TABLE TO START LOOKING FOR*/
                       /*STRUCTURES USING THE CURRENT STRUCTURE TEMPLTE.   */
       DECLARE IDX FIXED;
       DECLARE USED CHARACTER INITIAL('USED BY: ');
       DECLARE STR_OUT CHARACTER;
       STR_OUT = SUBSTR(X70,0,ATTR_START)||USED;
       DO IDX = M TO SORT_COUNT;
            IF (SYT_TYPE(SYT_SORT(IDX))=MAJ_STRUC) &
            (VAR_LENGTH(SYT_SORT(IDX)) = SYT_NO) THEN DO;
               IF (LENGTH(STR_OUT)+LENGTH(SYT_NAME(SYT_SORT(IDX)))>132)
               THEN DO;
                  OUTPUT = SUBSTR(STR_OUT,0,LENGTH(STR_OUT));
                  STR_OUT = SUBSTR(X70,0,ATTR_START);
               END;
               STR_OUT = STR_OUT||SYT_NAME(SYT_SORT(IDX))||',';
            END;
         END;
         IF LENGTH(STR_OUT) = ATTR_START + LENGTH(USED) THEN
            STR_OUT = STR_OUT || '** '||SUBSTR(CUSS,46,14)||' ** ';/*CR13335*/
         OUTPUT = SUBSTR(STR_OUT,0,LENGTH(STR_OUT)-1);
    END PRINT_VAR_NAMES;
    
    ENTER_SORT:
    PROCEDURE(LOC);
       DECLARE LOC BIT(16);
       SORT_COUNT = SORT_COUNT + 1;
       SYT_SORT(SORT_COUNT) = LOC;
       IF LENGTH(SYT_NAME(LOC)) > MAX_LENGTH THEN
          MAX_LENGTH = LENGTH(SYT_NAME(LOC));
    END ENTER_SORT;
    
    CHECK_AND_ENTER:
    PROCEDURE(LOC, ALWAYS) BIT(1);
       DECLARE LOC BIT(16), ALWAYS BIT(1);
       DECLARE (I, J) FIXED;
       I = SYT_XREF(LOC);  /* PTR TO LAST ENTRY */
       J = SYT_FLAGS(LOC);
       IF TOKEN = EOFILE THEN DO;
          IF (J & RIGID_FLAG) ^= 0 THEN
             SYT_FLAGS(LOC) = (J & (^RIGID_FLAG)) | DUPL_FLAG;
          ELSE SYT_FLAGS(LOC) = J & (^DUPL_FLAG);
          IF I > 0 THEN DO;
             SYT_XREF(LOC) = SHR(XREF(I), 16);
             XREF(I) = XREF(I) & "FFFF";
          END;  ELSE SYT_XREF(LOC) = 0;
          END;
       IF ALWAYS THEN DO;  /* ENTRY BEING FORCED INTO SORT ARRAY */
          CALL ENTER_SORT(LOC);
          ALWAYS = FALSE;  /* FOR NEXT TIME */
          RETURN TRUE;
       END;
       IF (XREF(I) & XREF_MASK) > FIRST_STMT THEN DO;
          CALL ENTER_SORT(LOC);
          RETURN TRUE;
       END;
       RETURN FALSE;
    END CHECK_AND_ENTER;
    
    ADD_ATTR:
    PROCEDURE(ATTR);
       DECLARE ATTR CHARACTER;
       IF LENGTH(S) + LENGTH(ATTR) + 2 > 132 THEN
          DO;
          OUTPUT = S;
          S = SUBSTR(X70, 0, ATTR_START);
       END;
       S = S || ATTR || ', ';
    END ADD_ATTR;
    
    MACRO_TEXT_RESET:
    PROCEDURE;
       OUTPUT = S;
       CALL BLANK(S, 0, 132);
       JL = ATTR_START;
    END;
    
    /***********************************************************************/
    /* FINDS THE CROSS-REFERENCES FOR EACH SYMBOL AND/OR BUILT-IN FUNCTION */
    /* AND FORMATS THE CROSS-REFERENCES FOR REPORTING IN THE COMPILATION   */
    /* LISTING.                                                            */
    /* INPUT PARAMETERS:                                                   */
    /* PTR - THE INDEX IN THE XREFS ARRAY FOR THE FIRST CROSS-REFERENCE    */
    /*       OF THE SYMBOL/BUILT-IN FUNCTION BEING PROCESSED.              */
    /* PROCESSING_BI- EQUAL TO 1 WHEN PROCESSING A BUILT-IN      /*DR120220*/
    /*                FUNCTION, OTHERWISE IT IS EQUAL TO 0.      /*DR120220*/
    /***********************************************************************/
    ADD_XREFS:
    PROCEDURE(PTR,PROCESSING_BI) BIT(32);                  /*DR120220*/
       DECLARE PTR BIT(16), A FIXED, PROCESSING_BI BIT(1); /*DR120220*/
       DECLARE TMP_PTR BIT(16);                            /*DR111366*/
       T = '';
       A = 0;
       LABEL_ON_END = FALSE;                               /*DR111366*/
       DO FOREVER;
          TMP_PTR = PTR;                                   /*DR111366*/
          A = A | XREF(PTR);  /* COLLECT FLAGS */
          T = T || (SHR(XREF(PTR), 13) & 7) || X1 ||
             SUBSTR(10000 + (XREF(PTR) & XREF_MASK), 1, 4) || X2;
          IF LENGTH(S)+LENGTH(T)+6>132 THEN DO;
             OUTPUT=S||T;
             S=SUBSTR(X70,0,ATTR_START);
             T='';
          END;
          PTR = SHR(XREF(PTR), 16);
          /* IF THE XREF ENTRY IS AN ASSIGN XREF & THE     /*DR111366*/
          /* SYMBOL IS A STATEMENT LABEL THEN THE LABEL    /*DR111366*/
          /* IS BEING USED ON AN END STATEMENT. SO THE     /*DR111366*/
          /* ASSIGN XREF ENTRY NEEDS TO BE REMOVED AND     /*DR111366*/
          /* LABEL_ON_END IS SET TO TRUE SO THE INACCURATE /*DR111366*/
          /* "NOT REFERENCED" MESSAGE WILL NOT BE PRINTED. /*DR111366*/
          IF ((SYT_TYPE(I) & STMT_LABEL) = STMT_LABEL) &   /*DR111366*/
             ((SHR(XREF(PTR),13) & 7) = 4)                 /*DR111366*/
             & ^PROCESSING_BI                              /*DR120220*/
          THEN DO;                                         /*DR111366*/
             LABEL_ON_END = TRUE;                          /*DR111366*/
             XREF(TMP_PTR) = (XREF(TMP_PTR) & "FFFF") |    /*DR111366*/
                             (XREF(PTR) & "FFFF0000");     /*DR111366*/
             PTR = SHR(XREF(PTR), 16);                     /*DR111366*/
          END;                                             /*DR111366*/
          IF PTR = 0 THEN RETURN A;
       END;
    END ADD_XREFS;
    
    /* PROCEDURE TO STORE BI_XREF ARRAYS IN VMEM */
    STORE_BI_XREF:
    PROCEDURE;
       DECLARE (I,PTR) BIT(16);
       BASED NODE_H BIT(16);
       BI_XREF_CELL = GET_CELL((BI#+1)*4,ADDR(NODE_H),MODF);
       PTR = 0;
       DO I = 0 TO BI#;
          NODE_H(PTR) = BI_XREF#(I);
          NODE_H(PTR+1) = BI_XREF(I);
          PTR = PTR+2;
       END;
    END STORE_BI_XREF;
    
    /* TRUNCATE PROCEDURE ADDED TO STRIP THE BLANK SPACES FROM A /*CR13335*/
    /* CHARACTER STRING.                                         /*CR13335*/
    TRUNCATE : PROCEDURE(STRING) CHARACTER;
      DECLARE STRING CHARACTER, L FIXED;
    
      L = LENGTH(STRING);
      DO WHILE SUBSTR(STRING,L-1,1) = X1;
         L = L-1;
      END;
    
      RETURN SUBSTR(STRING,0,L);
    END TRUNCATE;
    
    
    KI=0;
    CONTROL(7) = 0;     /*  ONE SHOT ONLY  */
    IF TOKEN = EOFILE THEN
       DO;
       OUTPUT(1)='0**** C O M P I L A T I O N   L A Y O U T ****';
       DO M = 1 TO PROGRAM_LAYOUT_INDEX;
          I = PROGRAM_LAYOUT(M);
          S=SYT_NAME(I);
          DO J=M+1 TO PROGRAM_LAYOUT_INDEX;
             IF SYT_NAME(PROGRAM_LAYOUT(J))=S THEN KI=1;
          END;
          S=S||': ';
          J = SYT_CLASS(I);
          K = SYT_TYPE(I);
          IF (SYT_FLAGS(I) & EXTERNAL_FLAG) ^= 0 THEN
             S = S || 'EXTERNAL ';
          IF J = FUNC_CLASS THEN
             S = S || SUBSTR(LABEL_TYPES, 0, 10);
          ELSE IF K = STMT_LABEL THEN
             S = S || SUBSTR(LABEL_TYPES, 10, 10);
          ELSE DO;
             K = K - PROC_LABEL + 2;
             K = K * 10;
             S = S || SUBSTR(LABEL_TYPES, K, 10);
          END;
          K = SYT_NEST(I) * 3;
          OUTPUT(1) = DOUBLE || SUBSTR(X70, 0, K+1) || S;
       END;
       IF KI THEN DO;
          IF MAX_SEVERITY<1 THEN MAX_SEVERITY=1;
          ERROR_COUNT=ERROR_COUNT+1;
          SAVE_SEVERITY(ERROR_COUNT)=1;
          SAVE_LINE_#(ERROR_COUNT)=-2;
          CALL ERRORS (CLASS_BI, 104);
       END;
       EJECT_PAGE;
    END;
    
    MAX_LENGTH = 0;
    I = 1;  /* DEFAULT START OF SORT_COUNT */
    IF SREF_OPTION THEN DO;
       IF XREF_FULL THEN DO;
          OUTPUT(1) = '0*****SREF OPTION WILL BE IGNORED DUE TO CROSS REFERENC
    E TABLE OVERFLOW*****';
          GO TO NO_SREF;
       END;
       DO WHILE I < BLOCK_SYTREF(1);
          IF SYT_TYPE(I) = TEMPL_NAME THEN DO; /* STRUCTURE TEMPLATE */
             K = I + 1;  /* FIRST ELEMENT */
             M = FALSE;  /* SET TRUE IF ANY ELEMENTS OF STR ARE USED */
             DO WHILE SYT_CLASS(K) = TEMPLATE_CLASS
                   & SYT_TYPE(K) ^= TEMPL_NAME;
                M = M | CHECK_AND_ENTER(K);
                K = K + 1;
             END;
             IF M THEN  /* ENTER TPL NAME IF ANY TERMINALS USED */
                CALL CHECK_AND_ENTER(I, TRUE);  /* FORCE ENTRY */
             ELSE  /* CONDITIONALLY ENTER TEMPLATE NAME */
                CALL CHECK_AND_ENTER(I);
             I = K;  /* JUMP OVER BODY OF TEMPLATE */
          END;
          ELSE IF (SYT_TYPE(I) = PROC_LABEL)
             | (SYT_TYPE(I) = PROG_LABEL)
             | (SYT_CLASS(I) = FUNC_CLASS) THEN DO;
             CALL CHECK_AND_ENTER(I, TRUE);  /* PRINT ALL NON-CPL TEMPLATES */
             I = I + 1;  /* FIRST PARM (OR ANOTHER BLOCK) */
             DO WHILE (SYT_FLAGS(I) & PARM_FLAGS) ^= 0;
                CALL CHECK_AND_ENTER(I, TRUE);  /* ENTER PARMS TOO */
                I = I + 1;
             END;
          END;
          ELSE DO;  /* NONE OF ABOVE */
             CALL CHECK_AND_ENTER(I);
             IF SYT_TYPE(I) = EQUATE_LABEL THEN
                IF TOKEN = EOFILE THEN
                SYT_NAME(I) = SUBSTR(SYT_NAME(I), 1); /* NO @ */
             I = I + 1;
          END;
       END;  /* OF WHILE I < BLOCK_SYTREF(1) */
    END;  /* OF SREF PROCESSING */
    NO_SREF:
    DO I = I TO NDECSY;
       CALL CHECK_AND_ENTER(I, TRUE);
       IF SYT_TYPE(I) = EQUATE_LABEL THEN
          IF TOKEN = EOFILE THEN
          SYT_NAME(I) = SUBSTR(SYT_NAME(I), 1);  /* NO @ */
    END;
    IF MAX_LENGTH < 4 THEN J = 4;
    ELSE J = MAX_LENGTH;
    ATTR_START=J+44;
    EXCHANGES = TRUE;
    
    IF ^CONTROL("F") THEN DO;
       M = SHR(SORT_COUNT, 1);
       DO WHILE M > 0;
          DO J = 1 TO SORT_COUNT - M;
             I = J;
           DO WHILE STRING_GT(SYT_NAME(SYT_SORT(I)), SYT_NAME(SYT_SORT(I+M)));
                L = SYT_SORT(I);
                SYT_SORT(I) = SYT_SORT(I + M);
                SYT_SORT(I + M) = L;
                I = I - M;
                IF I < 1 THEN GO TO LM;
             END;  /* DO WHILE STRING_GT */
    LM:
          END;  /* DO J */
          M = SHR(M, 1);
       END;  /* DO WHILE M */
    END;  /* OF SORTING IF NOT CONTROL(F) */
    
    T_CASE,T_LEVEL=0;
    M=1;
    /*IF 1ST SYMBOL IN SORTED LIST IS A STRUCTURE TEMPLATE */
    /*THEN PRINT THE HEADER FOR STRUCTURES.                */
    IF SYT_TYPE(SYT_SORT(1))=TEMPL_NAME THEN    /*CR12940*/
       CALL PRINT_SYMBOL_HEADER(TRUE,FALSE);    /*CR12940*/
    ELSE DO;                                    /*CR12940*/
       CALL PRINT_SYMBOL_HEADER(FALSE,FALSE);   /*CR12940*/
    END;                                        /*CR12940*/
    DO WHILE M <= SORT_COUNT;
       IF ^HEADER_PRINTED THEN                         /*CR12940*/
          IF (SYT_TYPE(SYT_SORT(M))^=TEMPL_NAME) THEN  /*CR12940*/
             CALL PRINT_SYMBOL_HEADER(FALSE,TRUE);     /*CR12940*/
       DO CASE T_CASE;
          I=SYT_SORT(M);
          IF SYT_LINK1(I)>0 THEN DO;
             T_LEVEL=T_LEVEL+1;
             I=SYT_LINK1(I);
          END;
          ELSE DO;
             DO WHILE SYT_LINK2(I)<0;
                I=-SYT_LINK2(I);
                T_LEVEL=T_LEVEL-1;
             END;
             IF SYT_LINK2(I)=0 THEN DO;
                T_CASE,T_LEVEL=0;
                GO TO NO_INDIRECT;
             END;
             ELSE I=SYT_LINK2(I);
          END;
          I=I+1;
       END;
       J=SYT_TYPE(I);
       K=SYT_CLASS(I);
       L=SYT_FLAGS(I);
       IF (L&IMPL_T_FLAG)^=0 THEN GO TO NO_INDIRECT;
       IF K>=TEMPLATE_CLASS THEN DO;
          IF J=TEMPL_NAME THEN IF (L&EVIL_FLAG)=0 THEN T_CASE=1;
       END;
       ELSE IF K=REPL_CLASS THEN DO;
          IF VAR_LENGTH(I)>0 THEN DO;
             T_CASE=2;
             T_LEVEL=-VAR_LENGTH(I);
          END;
       END;
       ELSE IF K=REPL_ARG_CLASS THEN DO;
          IF T_CASE=0 THEN GO TO NO_INDIRECT;
          T_LEVEL=T_LEVEL+1;
          IF T_LEVEL=0 THEN T_CASE=0;
       END;
       IF J=IND_CALL_LAB THEN IF ^CONTROL("F") THEN GO TO NO_INDIRECT;
       T = PAD(SYT_NAME(I), ATTR_START - 44);
       IF K>=TEMPLATE_CLASS THEN DO;
          IF J=TEMPL_NAME THEN                 /*MOD-CR13336*/
             T=SUBSTR(T,1)||X4;
          ELSE IF T_CASE=0 THEN T=T||SUBSTR(X4,1);
          ELSE T=X1||T||X2;
       END;
       ELSE IF K=REPL_ARG_CLASS THEN T=X1||T||X2;
       ELSE T=T||SUBSTR(X4,1);
       IF (L&IMP_DECL)^=0 THEN T=' *'||T;
       ELSE T=X2||T;
       JL,JI=SYT_XREF(I);
       IF TOKEN ^= EOFILE THEN
          JI = SHR(XREF(JI), 16);
       ELSE IF JI <= 0 THEN
          JI = 0;
       ELSE DO FOREVER;
          IF (SHR(XREF(JI),13)&7)=0 THEN GO TO DEFINITION_FOUND;
          JI=SHR(XREF(JI),16);
          IF JI = 0 THEN DO;
             JI = JL;
             GO TO DEFINITION_FOUND;
          END;
       END;
    DEFINITION_FOUND:
       KI=XREF(JI)&XREF_MASK;
       V_ARRAY='';
       T=I_FORMAT(KI,4)||T;
       IF K = REPL_CLASS THEN
          S = 'REPLACE MACRO';
       ELSE IF K=REPL_ARG_CLASS THEN DO;
          S='MACRO ARG';
       END;
       ELSE IF J<TEMPL_NAME THEN DO;
          S=TRUNCATE( SUBSTR(VAR_NAME,J*11,11) );                 /*CR13335*/
          IF J<MAT_TYPE THEN DO;
             IF VAR_LENGTH(I)=-1 THEN V_LEN='*';
             ELSE V_LEN=VAR_LENGTH(I);
             S=S||'('||V_LEN||')';
          END;
          ELSE IF J=VEC_TYPE THEN S=VAR_LENGTH(I)||' - '||S;
          ELSE IF J=MAT_TYPE THEN DO;
             V_LEN=SHR(VAR_LENGTH(I),8)||' X ';
             V_LEN=V_LEN||(VAR_LENGTH(I)&"FF");
             S=V_LEN||X1||S;
          END;
          IF K=FUNC_CLASS|K=TPL_FUNC_CLASS THEN S=S||' FUNCTION';
          ELSE IF SYT_ARRAY(I)^=0 THEN DO;
             IF J=MAJ_STRUC THEN DO;
                IF  SYT_ARRAY(I)<0 THEN V_LEN='*';
                ELSE V_LEN=SYT_ARRAY(I);
                S=S||'('||V_LEN||')';
             END;
             ELSE DO;
                S=S||' ARRAY';
                V_ARRAY='ARRAY(';
                DO KL=1 TO EXT_ARRAY(SYT_ARRAY(I));
                   IF EXT_ARRAY(SYT_ARRAY(I)+KL)<0 THEN V_ARRAY=V_ARRAY||'*,';
                   ELSE V_ARRAY=V_ARRAY||EXT_ARRAY(SYT_ARRAY(I)+KL)||',';
                END;
                V_ARRAY=SUBSTR(V_ARRAY,0,LENGTH(V_ARRAY)-1)||')';
             END;
          END;
          IF J=MAJ_STRUC THEN DO;
             IF K^=TEMPLATE_CLASS THEN DO;
    T_REFS:           V_ARRAY=SUBSTR(SYT_NAME(VAR_LENGTH(I)),1)||'-STRUCTURE';
             END;
             ELSE IF VAR_LENGTH(I)>0 THEN GO TO T_REFS;
             ELSE S='MINOR NODE';
          END;
    N_FIX:
          IF (L&NAME_FLAG)^=0 THEN S=NAMER||S;
          IF T_LEVEL>0 THEN DO;
             S=SUBSTR(X70,0,MAX_STRUC_LEVEL+1)||S;
             IF T_LEVEL<=MAX_STRUC_LEVEL THEN BYTE(S,T_LEVEL-1)=T_LEVEL|"F0";
          END;
       END;
       ELSE DO;
          S=TRUNCATE( SUBSTR(LABEL_NAME,(J-TEMPL_NAME)*18,18) );  /*CR13335*/
          IF (L&NAME_FLAG)^=0 THEN GO TO N_FIX;
          L = L & SDF_INCL_OFF;
          IF J = STMT_LABEL THEN
             IF (VAR_LENGTH(I)>0)&(VAR_LENGTH(I)<3) THEN
             S = 'UPDATE LABEL';
       END;
       S=PAD(T||S,ATTR_START);
       IF K>=TEMPLATE_CLASS THEN IF T_CASE=0 THEN IF J^=TEMPL_NAME THEN DO;
          KI=I;
          DO WHILE SYT_TYPE(KI)^=TEMPL_NAME;
             KI=KI-1;
          END;
          R=' **** SEE STRUCTURE TEMPLATE'||SYT_NAME(KI);
          T='';
          IF (SYT_FLAGS(KI)&EVIL_FLAG)=0 THEN GO TO NO_XREF;
       END;
       IF LENGTH(V_ARRAY)>0 THEN CALL ADD_ATTR(V_ARRAY);
       IF (L&LATCHED_FLAG)^=0 THEN DO;
          IF J=EVENT_TYPE THEN CALL ADD_ATTR('LATCHED');
       END;
       DO KL=1 TO 19;
          IF (L&FLAG_MASK(KL))^=0 THEN                            /*CR13335*/
             CALL ADD_ATTR(TRUNCATE(SUBSTR(CHAR_ATTR,KL*11,11))); /*CR13335*/
       END;
       IF ^SDL_OPTION THEN
          IF (L & EXTERNAL_FLAG) ^= 0 THEN
          CALL ADD_ATTR('VERSION=' || SYT_LOCK#(I));
       IF (L&LOCK_FLAG)^=0 THEN DO;
    /*CR13335*/ IF SYT_LOCK#(I)="FF"  THEN CALL ADD_ATTR(SUBSTR(CHAR_ATTR,0,6));
    /*CR13335*/ ELSE CALL ADD_ATTR(SUBSTR(CHAR_ATTR,0,5)||SYT_LOCK#(I));
       END;
       IF CONTROL("F") THEN
          DO;  /* EXTRA SYMBOL TABLE DUMP REQUESTED */
          T = HEX(L);
          CALL ADD_ATTR('FLAGS=' || T);
          CALL ADD_ATTR('NEST=' || SYT_NEST(I));
          CALL ADD_ATTR('SCOPE=' || SYT_SCOPE(I));
          CALL ADD_ATTR('PTR=' || SYT_PTR(I));
          CALL ADD_ATTR('LENGTH='||VAR_LENGTH(I));
          CALL ADD_ATTR('LINK1=' || SYT_LINK1(I));
          CALL ADD_ATTR('LINK2=' || SYT_LINK2(I));
          CALL ADD_ATTR('SYT_NO=' || I);
          CALL ADD_ATTR('ARRAY='||SYT_ARRAY(I));
          CALL ADD_ATTR('ADDR='||SYT_ADDR(I));
          CALL ADD_ATTR('CLASS='||SYT_CLASS(I));
          CALL ADD_ATTR('TYPE='||SYT_TYPE(I));
       END;
       IF K = REPL_CLASS THEN DO;
          CALL ADD_ATTR('MACRO TEXT="');
          S = SUBSTR(S, 0, LENGTH(S) - 2);
          JL = LENGTH(S);
          S = S || SUBSTR(X256, 0, 132 - JL);  /* MAKE S 132 CHARS */
          KL = SYT_ADDR(I);  /* PTR TO TEXT */
          JI = MACRO_TEXT(KL);  /* FIRST CHARACTER */
    MACRO_LOOP:
          DO WHILE JI ^= "EF" & JL < 132;
             IF JI = "EE" THEN DO;  /* MULTIPLE BLANKS */
                KL = KL + 1;
                JI = MACRO_TEXT(KL);
                IF JI = 0 THEN GO TO MACRO_END;
    NEWLINE:
                IF (JI + JL) > 132 THEN DO;
                   JI = JI - 132 + JL;
                   CALL MACRO_TEXT_RESET;
                   GO TO NEWLINE;
                END;
                ELSE JL = JL + JI;
             END;  /* OF JI = "EE" */
             ELSE IF JI = BYTE('"') THEN DO;  /* DOUBLE ANY " */
                BYTE(S, JL) = JI;
                JL = JL + 1;
                IF JL < 132 THEN
    DOUBLE_QUOTE:
                BYTE(S, JL) = JI;
                ELSE DO;
                   CALL MACRO_TEXT_RESET;
                   GO TO DOUBLE_QUOTE;
                END;
             END;  /* OF JI = BYTE('"') */
             ELSE BYTE(S, JL) = JI;
             JL = JL + 1;
             KL = KL + 1;
             JI = MACRO_TEXT(KL);
          END;  /* OF WHILE JI ^= "EF" ETC */
          IF JI ^= "EF" THEN DO;  /* JUST RAN OUT OF ROOM */
             CALL MACRO_TEXT_RESET;
             GO TO MACRO_LOOP;
          END;
          ELSE DO;  /* END OF MACRO TEXT */
    MACRO_END:
             IF JL < 132 THEN
    ADD_QUOTE:
             BYTE(S, JL) = BYTE('"');
             ELSE DO;
                CALL MACRO_TEXT_RESET;
                GO TO ADD_QUOTE;
             END;
             S = SUBSTR(S, 0, JL + 1);
          END;
       END;  /* OF K = REPL_CLASS */
       ELSE S = SUBSTR(S, 0, LENGTH(S) - 2);
       T,R='';
       KL=SYT_XREF(I);
       IF TOKEN^=EOFILE|KL<=0 THEN
          DO;
          OUTPUT = S;
          GO TO NO_INDIRECT;
       END;
    
    
       KI=(LENGTH(S)-ATTR_START+7)/8;
       KI=(KI*8)+ATTR_START-LENGTH(S);
       IF KI>0 THEN S=S||SUBSTR(X70,0,KI);
       CALL ADD_ATTR('  XREF:     ');
       S=SUBSTR(S,0,LENGTH(S)-6);
       KI = 1;
       JL = SHR(ADD_XREFS(SYT_XREF(I),FALSE), 13) & 7;            /*DR120220*/
       IF JL THEN JL=JL|2;  /* MERGE SUBSCR & REF FLAGS  */
       IF J=COMPOOL_LABEL THEN JL=JL|6;
       ELSE IF J=PROG_LABEL&(L&EXTERNAL_FLAG)=0 THEN JL=JL|6;
       ELSE IF SYT_NEST(I)=0 THEN KI=0;
       ELSE IF SYT_SCOPE(I)<MAIN_SCOPE THEN JL=JL|6;
       IF K>=TEMPLATE_CLASS THEN DO;
          IF J=TEMPL_NAME THEN JL=JL|4;
          ELSE JL=JL|8;
       END;
       ELSE IF K=REPL_ARG_CLASS THEN JL=JL|6;
       ELSE IF (L&NAME_FLAG)^=0 THEN ;
       ELSE IF K^=VAR_CLASS THEN JL=JL|4;
       ELSE IF J=EVENT_TYPE THEN JL=JL|4;
       IF (L&INIT_CONST)^=0 THEN JL=JL|4;
       IF (L&INP_OR_CONST)^=0 THEN JL=JL|4;
       IF (L&ASSIGN_PARM)^=0 THEN KI=0;
       IF (L&MISC_NAME_FLAG)^=0 THEN IF J^=TEMPL_NAME THEN JL=JL|8;
       IF LABEL_ON_END THEN JL = JL|6;                /*DR111366*/
       JL=SHR(JL,1);
       R=TRUNCATE(SUBSTR(CUSS,JL*23,23));                         /*CR13335*/
       IF (JL=1)&KI THEN DO;
          NOT_ASSIGNED_FLAG="FF";
          R='***** ERROR ***** REFERENCED BUT '||R;
          OUTPUT = S || T;
          OUTPUT = SUBSTR(X70,0,ATTR_START - 3) || R;  /* MAKE IT STICK OUT */
          GO TO NO_INDIRECT;  /* SKIP OTHER PRINT LOGIC */
       END;
    NO_XREF:
       IF LENGTH(S)+LENGTH(T)+LENGTH(R)<=132 THEN DO;
          S=S||T||R;
          IF LENGTH(S)>ATTR_START THEN OUTPUT=S;
       END;
       ELSE
          DO;
          OUTPUT = S || T;
          OUTPUT = SUBSTR(X70, 0, ATTR_START) || R;
       END;
    NO_INDIRECT:
       /*THE LOGIC TO GO THROUGH STRUCTURES STARTS AT THE ROOT NODE AND  */
       /*ENDS AT THE ROOT NODE.  TO PREVENT VARIABLES FROM BEING PRINTED */
       /*TWICE, CHECK FOR T_CASE^=0 BECAUSE T_CASE=0 AT THE SECOND       */
       /*VISIT TO THE ROOT NODE BUT NOT THE FIRST.                       */
       IF (SYT_TYPE(I)=TEMPL_NAME) THEN               /*CR12940*/
          IF (T_CASE^=0) THEN CALL PRINT_VAR_NAMES(I);/*CR12940*/
       IF T_CASE=0 THEN M=M+1;
    END;
    IF XREF_FULL THEN DO;
       CALL ERRORS (CLASS_BI, 102);
       NOT_ASSIGNED_FLAG = FALSE;
    END;
    ELSE IF NOT_ASSIGNED_FLAG THEN DO;
       IF MAX_SEVERITY<1 THEN MAX_SEVERITY=1;
       ERROR_COUNT=ERROR_COUNT+1;
       SAVE_SEVERITY(ERROR_COUNT)=1;
       SAVE_LINE_#(ERROR_COUNT)=-1;
       CALL ERRORS (CLASS_BI, 105);
    END;
    OUTPUT(1) = SUBHEADING;
    DOUBLE_SPACE;
    IF BI_XREF THEN IF TOKEN=EOFILE THEN DO;
       EJECT_PAGE;
       OUTPUT(1)='0B U I L T - I N   F U N C T I O N   C R O S S   R E F E R E
    N C E';
       OUTPUT(1)='0   (CROSS REFERENCE FLAG KEY:  4 = ASSIGNMENT, 2 = REFERENC
    E, 1 = SUBSCRIPT USE)';                                             /*DR120220*/
       S='  NAME      CROSS REFERENCE';
       OUTPUT(1)=DOUBLE||S;
       OUTPUT(1)=SUBHEADING||S;
       KI=BI_LIMIT+1;
       ATTR_START=KI+6;
       DO J = 1 TO BI#;
          S = SUBSTR(BI_NAME(BI_INDX(J)),BI_LOC(J),10);           /*CR13335*/
          IF BI_XREF(J)>0 THEN DO;
    /* KEEP TRACK OF THE USED XREF CELLS */
             BI_XREF#(0) = BI_XREF#(0)+1;
             S=S||'XREF: ';
             KL=BI_XREF(J);
             BI_XREF(J) = SHR(XREF(KL), 16);
             XREF(KL) = XREF(KL) & "FFFF";
             CALL ADD_XREFS(BI_XREF(J),TRUE);                     /*DR120220*/
             IF LENGTH(T)>0 THEN OUTPUT=S||T;
          END;
       END;
       CALL STORE_BI_XREF;
       OUTPUT(1)=SUBHEADING;
       DOUBLE_SPACE;
    END;
