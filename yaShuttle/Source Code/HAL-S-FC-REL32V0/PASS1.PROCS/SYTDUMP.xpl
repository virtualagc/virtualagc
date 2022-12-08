 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYTDUMP.xpl
    Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC 
                compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-07 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
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
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SYT_DUMP <==                                                        */
 /*     ==> PAD                                                             */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GET_CELL                                                        */
 /*     ==> BLANK                                                           */
 /*     ==> HEX                                                             */
 /*     ==> I_FORMAT                                                        */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*11/19/90 LWW   23V1  103658 VARIABLE XREF ATTRIBUTE NONHAL IS INCORRECT  */
 /*02/22/91 TKK   23V2  CR11109 CLEAN UP OF COMPILER SOURCE CODE            */
 /*04/05/94 JAC   26V0  108643  INCORRECTLY LISTS 'NONHAL' INSTEAD OF       */
 /*               10V0          'INCREM' IN SDFLIST                         */
 /*                                                                         */
 /*02/18/98 SMR   28V0 CR12940  ENHANCE COMPILER LISTING                    */
 /*               14V0                                                      */
 /*                                                                         */
 /*01/28/98 DCP   29V0  109052  ARITHMETIC EXPRESSION IN CONSTANT/          */
 /*               14V0          INITIAL VALUE GETS ERROR                    */
 /*                                                                         */
 /*04/26/01 DCP   31V0 CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS          */
 /*               16V0          IN HAL/S COMPILER                           */
 /*                                                                         */
 /*03/28/01 DCP   31V0  111366  CROSS REFERENCE INFORMATION IS INACCURATE   */
 /*               16V0          FOR DO GROUP LABEL                          */
 /*                                                                         */
 /*01/23/01 DCP   31V0  CR13336 DON'T ALLOW ARITHMETIC EXPRESSIONS IN       */
 /*               16V0          CHARACTER INITIAL CLAUSES                   */
 /*                                                                         */
 /*07/25/03 DCP   32V0  120220  MISSING SUBBIT CROSS-REFERENCE              */
 /*               17V0                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SYT_DUMP <==                                                        */
 /*     ==> PAD                                                             */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GET_CELL                                                        */
 /*     ==> BLANK                                                           */
 /*     ==> HEX                                                             */
 /*     ==> I_FORMAT                                                        */
 /***************************************************************************/
                                                                                00618500
SYT_DUMP:                                                                       00618600
   PROCEDURE;                                                                   00618700
      DECLARE HEADER_PRINTED BIT(1) INITIAL(FALSE);          /*CR12940*/
      DECLARE (R,S,T,V_LEN,V_ARRAY) CHARACTER, (T_LEVEL,T_CASE) BIT(16),        00618800
         (I, J, K) FIXED;                                                       00618900
      DECLARE (L, M, JI, KI, JL, KL) FIXED;                                     00619000
      DECLARE (SORT_COUNT, MAX_LENGTH) BIT(16);                                 00619010
      DECLARE ATTR_START BIT(16);                                               00619100
      DECLARE EXCHANGES BIT(1);                                                 00619200
      /* CHANGED VAR_NAME FROM A CHARACTER ARRAY OF 10 TO A SINGLE  /*CR13335*/
      /* STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.           /*CR13335*/
      /* 11 CHARACTER SPACES FOR EACH VARIABLE NAME.                /*CR13335*/
      DECLARE VAR_NAME CHARACTER INITIAL( '? DATA TYPEBIT        CHARACTER  MATR00619300
IX     VECTOR     SCALAR     INTEGER    <BORC>     <IORS>     EVENT      STRUCTU00619400
RE  ');                                                                         00619500
      /* CHANGED LABEL_NAME FROM A CHARACTER ARRAY OF 13 TO A SINGLE/*CR13335*/
      /* STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.           /*CR13335*/
      /* 18 CHARACTER SPACES FOR EACH LABEL NAME.                   /*CR13335*/
      DECLARE LABEL_NAME     CHARACTER INITIAL('STRUCTURE TEMPLATETEMPLATE REFER00619600
ENCE<MB STMT LAB>     <IND STMT LAB>    STATEMENT LABEL   ? LABEL           <MB 00619700
CALL LABEL>   <IND CALL LABEL>  <CALLED LABEL>    PROCEDURE         TASK        00619800
      PROGRAM           COMPOOL           EQUATE LABEL      ');                 00619900
      /* CHANGED CUSS FROM CHARACTER ARRAY OF 7 TO A SINGLE STRING  /*CR13335*/
      /* TO REDUCE THE NUMBER OF STRINGS IN PASS1. 23 CHARACTER     /*CR13335*/
      /* SPACES FOR EACH CUSS PHRASE. THERE ARE BLANK PHRASES       /*CR13335*/
      /* STARTING AT LOCATIONS 92 & 184.                            /*CR13335*/
      DECLARE CUSS CHARACTER INITIAL ('NOT USED               NOT ASSIGNED      00620000
     NOT REFERENCED                                POSSIBLY NOT USED      POSSIB00620100
LY NOT ASSIGNED  POSSIBLY NOT REFERENCED                       ');              00620200
      DECLARE LABEL_TYPES CHARACTER INITIAL(                                    00620300
         'FUNCTION; UPDATE;   PROCEDURE;TASK;     PROGRAM;  COMPOOL;  ');       00620400
      DECLARE FLAG_MASK(19) FIXED INITIAL(0,                                    00620500
         "00800000",     /* SINGLE      */                                      00620600
         "00400000",    /* DOUBLE      */                                       00620700
         "08000000",    /* TEMPORARY  */                                        00620800
         "04000000",    /* RIGID  (AS MODIFIED IN CHECK_AND_ENTER) */           00620900
         "00000004",     /* DENSE       */                                      00621000
         "00000008",     /* ALIGNED     */                                      00621100
         "00000020",     /* ASSIGN      */                                      00621200
         "00000400",     /* INPUT       */                                      00621300
         "00000100",     /* AUTOMATIC   */                                      00621400
         "00000200",     /* STATIC      */                                      00621500
         "00000800",     /* INITIAL     */                                      00621600
         "00001000",     /* CONSTANT    */                                      00621700
         "00010000",     /* ACCESS      */                                      00621800
         "00000002",     /* REENTRANT   */                                      00621900
         "00080000",     /* EXCLUSIVE   */                                      00622000
         "00100000",     /*  EXTERNAL   */                                      00622100
         "00000080",     /*  REMOTE  */                                         00622200
         "02000000");    /*  INCLUDED_REMOTE */    /* DR108643 */               00622300
      /* CHANGED CHAR_ATTR FROM A CHARACTER ARRAY OF 19 TO A SINGLE /*CR13335*/
      /* STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.           /*CR13335*/
      /* 11 CHARACTER SPACES FOR EACH CHARACTER ATTRIBUTE.          /*CR13335*/
      DECLARE CHAR_ATTR CHARACTER INITIAL('LOCK=*     SINGLE     DOUBLE     TEMP00622400
ORARY  RIGID      DENSE      ALIGNED    ASSIGN-PARMINPUT-PARM AUTOMATIC  STATIC 00622500
    INITIAL    CONSTANT   ACCESS     REENTRANT  EXCLUSIVE  EXTERNAL   REMOTE    00622600
 INCREM     ');                                                                 00622700
      DECLARE NAMER CHARACTER INITIAL ('NAME ');                                00622800
      DECLARE LABEL_ON_END BIT(1) INITIAL(FALSE);  /*DR111366*/
/*CR12940 - PRINTS THE SYMBOL TABLE HEADER.*/
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

ENTER_SORT:                                                                     00622802
      PROCEDURE(LOC);                                                           00622804
         DECLARE LOC BIT(16);                                                   00622806
         SORT_COUNT = SORT_COUNT + 1;                                           00622808
         SYT_SORT(SORT_COUNT) = LOC;                                            00622810
         IF LENGTH(SYT_NAME(LOC)) > MAX_LENGTH THEN                             00622812
            MAX_LENGTH = LENGTH(SYT_NAME(LOC));                                 00622814
      END ENTER_SORT;                                                           00622816
                                                                                00622818
CHECK_AND_ENTER:                                                                00622820
      PROCEDURE(LOC, ALWAYS) BIT(1);                                            00622822
         DECLARE LOC BIT(16), ALWAYS BIT(1);                                    00622824
         DECLARE (I, J) FIXED;                                                  00622826
         I = SYT_XREF(LOC);  /* PTR TO LAST ENTRY */                            00622828
         J = SYT_FLAGS(LOC);                                                    00622830
         IF TOKEN = EOFILE THEN DO;                                             00622832
            IF (J & RIGID_FLAG) ^= 0 THEN                                       00622834
               SYT_FLAGS(LOC) = (J & (^RIGID_FLAG)) | DUPL_FLAG;                00622836
            ELSE SYT_FLAGS(LOC) = J & (^DUPL_FLAG);                             00622838
            IF I > 0 THEN DO;                                                   00622839
               SYT_XREF(LOC) = SHR(XREF(I), 16);                                00622840
               XREF(I) = XREF(I) & "FFFF";                                      00622842
            END;  ELSE SYT_XREF(LOC) = 0;                                       00622843
            END;                                                                00622844
         IF ALWAYS THEN DO;  /* ENTRY BEING FORCED INTO SORT ARRAY */           00622846
            CALL ENTER_SORT(LOC);                                               00622848
            ALWAYS = FALSE;  /* FOR NEXT TIME */                                00622850
            RETURN TRUE;                                                        00622852
         END;                                                                   00622854
         IF (XREF(I) & XREF_MASK) > FIRST_STMT THEN DO;                         00622856
            CALL ENTER_SORT(LOC);                                               00622858
            RETURN TRUE;                                                        00622860
         END;                                                                   00622862
         RETURN FALSE;                                                          00622864
      END CHECK_AND_ENTER;                                                      00622866
                                                                                00622868
ADD_ATTR:                                                                       00622900
      PROCEDURE(ATTR);                                                          00623000
         DECLARE ATTR CHARACTER;                                                00623100
         IF LENGTH(S) + LENGTH(ATTR) + 2 > 132 THEN                             00623200
            DO;                                                                 00623300
            OUTPUT = S;                                                         00623400
            S = SUBSTR(X70, 0, ATTR_START);                                     00623500
         END;                                                                   00623600
         S = S || ATTR || ', ';                                                 00623700
      END ADD_ATTR;                                                             00623800
                                                                                00623900
MACRO_TEXT_RESET:                                                               00623910
      PROCEDURE;                                                                00623920
         OUTPUT = S;                                                            00623930
         CALL BLANK(S, 0, 132);                                                 00623940
         JL = ATTR_START;                                                       00623950
      END;                                                                      00623960
                                                                                00623970
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
ADD_XREFS:                                                                      00624000
      PROCEDURE(PTR,PROCESSING_BI) BIT(32);                  /*DR120220*/       00624100
         DECLARE PTR BIT(16), A FIXED, PROCESSING_BI BIT(1); /*DR120220*/       00624110
         DECLARE TMP_PTR BIT(16);                            /*DR111366*/
         T = '';                                                                00624120
         A = 0;                                                                 00624130
         LABEL_ON_END = FALSE;                               /*DR111366*/
         DO FOREVER;                                                            00624140
            TMP_PTR = PTR;                                   /*DR111366*/
            A = A | XREF(PTR);  /* COLLECT FLAGS */                             00624150
            T = T || (SHR(XREF(PTR), 13) & 7) || X1 ||                          00624160
               SUBSTR(10000 + (XREF(PTR) & XREF_MASK), 1, 4) || X2;             00624170
            IF LENGTH(S)+LENGTH(T)+6>132 THEN DO;                               00625000
               OUTPUT=S||T;                                                     00625100
               S=SUBSTR(X70,0,ATTR_START);                                      00625200
               T='';                                                            00625300
            END;                                                                00625400
            PTR = SHR(XREF(PTR), 16);                                           00625500
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
            IF PTR = 0 THEN RETURN A;                                           00625510
         END;                                                                   00625600
      END ADD_XREFS;                                                            00625700
                                                                                00625705
 /* PROCEDURE TO STORE BI_XREF ARRAYS IN VMEM */                                00625710
STORE_BI_XREF:                                                                  00625715
      PROCEDURE;                                                                00625720
         DECLARE (I,PTR) BIT(16);                                               00625725
         BASED NODE_H BIT(16);                                                  00625730
         BI_XREF_CELL = GET_CELL((BI#+1)*4,ADDR(NODE_H),MODF);                  00625735
         PTR = 0;                                                               00625740
         DO I = 0 TO BI#;                                                       00625745
            NODE_H(PTR) = BI_XREF#(I);                                          00625750
            NODE_H(PTR+1) = BI_XREF(I);                                         00625755
            PTR = PTR+2;                                                        00625760
         END;                                                                   00625765
      END STORE_BI_XREF;                                                        00625770
                                                                                00625775
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
                                                                                00625780
                                                                                00625800
      KI=0;                                                                     00625900
      CONTROL(7) = 0;     /*  ONE SHOT ONLY  */                                 00626000
      IF TOKEN = EOFILE THEN                                                    00626100
         DO;                                                                    00626200
         OUTPUT(1)='0**** C O M P I L A T I O N   L A Y O U T ****';            00626300
         DO M = 1 TO PROGRAM_LAYOUT_INDEX;                                      00626400
            I = PROGRAM_LAYOUT(M);                                              00626500
            S=SYT_NAME(I);                                                      00626600
            DO J=M+1 TO PROGRAM_LAYOUT_INDEX;                                   00626700
               IF SYT_NAME(PROGRAM_LAYOUT(J))=S THEN KI=1;                      00626800
            END;                                                                00626900
            S=S||': ';                                                          00627000
            J = SYT_CLASS(I);                                                   00627100
            K = SYT_TYPE(I);                                                    00627200
            IF (SYT_FLAGS(I) & EXTERNAL_FLAG) ^= 0 THEN                         00627300
               S = S || 'EXTERNAL ';                                            00627400
            IF J = FUNC_CLASS THEN                                              00627500
               S = S || SUBSTR(LABEL_TYPES, 0, 10);                             00627600
            ELSE IF K = STMT_LABEL THEN                                         00627700
               S = S || SUBSTR(LABEL_TYPES, 10, 10);                            00627800
            ELSE DO;                                                            00627900
               K = K - PROC_LABEL + 2;                                          00628000
               K = K * 10;                                                      00628100
               S = S || SUBSTR(LABEL_TYPES, K, 10);                             00628200
            END;                                                                00628300
            K = SYT_NEST(I) * 3;                                                00628400
            OUTPUT(1) = DOUBLE || SUBSTR(X70, 0, K+1) || S;                     00628500
         END;                                                                   00628600
         IF KI THEN DO;                                                         00628700
            IF MAX_SEVERITY<1 THEN MAX_SEVERITY=1;                              00628800
            ERROR_COUNT=ERROR_COUNT+1;                                          00628900
            SAVE_SEVERITY(ERROR_COUNT)=1;                                       00629000
            SAVE_LINE_#(ERROR_COUNT)=-2;                                        00629100
            CALL ERRORS (CLASS_BI, 104);                                        00629200
         END;                                                                   00629400
         EJECT_PAGE;                                                            00629500
      END;                                                                      00629600
                                                                                00630100
      MAX_LENGTH = 0;                                                           00630200
      I = 1;  /* DEFAULT START OF SORT_COUNT */                                 00630210
      IF SREF_OPTION THEN DO;                                                   00630220
         IF XREF_FULL THEN DO;                                                  00630230
            OUTPUT(1) = '0*****SREF OPTION WILL BE IGNORED DUE TO CROSS REFERENC00630240
E TABLE OVERFLOW*****';                                                         00630250
            GO TO NO_SREF;                                                      00630260
         END;                                                                   00630270
         DO WHILE I < BLOCK_SYTREF(1);                                          00630280
            IF SYT_TYPE(I) = TEMPL_NAME THEN DO; /* STRUCTURE TEMPLATE */       00630290
               K = I + 1;  /* FIRST ELEMENT */                                  00630300
               M = FALSE;  /* SET TRUE IF ANY ELEMENTS OF STR ARE USED */       00630310
               DO WHILE SYT_CLASS(K) = TEMPLATE_CLASS                           00630320
                     & SYT_TYPE(K) ^= TEMPL_NAME;                               00630330
                  M = M | CHECK_AND_ENTER(K);                                   00630340
                  K = K + 1;                                                    00630350
               END;                                                             00630360
               IF M THEN  /* ENTER TPL NAME IF ANY TERMINALS USED */            00630370
                  CALL CHECK_AND_ENTER(I, TRUE);  /* FORCE ENTRY */             00630380
               ELSE  /* CONDITIONALLY ENTER TEMPLATE NAME */                    00630390
                  CALL CHECK_AND_ENTER(I);                                      00630400
               I = K;  /* JUMP OVER BODY OF TEMPLATE */                         00630410
            END;                                                                00630420
            ELSE IF (SYT_TYPE(I) = PROC_LABEL)                                  00630430
               | (SYT_TYPE(I) = PROG_LABEL)                                     00630440
               | (SYT_CLASS(I) = FUNC_CLASS) THEN DO;                           00630450
               CALL CHECK_AND_ENTER(I, TRUE);  /* PRINT ALL NON-CPL TEMPLATES */00630460
               I = I + 1;  /* FIRST PARM (OR ANOTHER BLOCK) */                  00630470
               DO WHILE (SYT_FLAGS(I) & PARM_FLAGS) ^= 0;                       00630480
                  CALL CHECK_AND_ENTER(I, TRUE);  /* ENTER PARMS TOO */         00630490
                  I = I + 1;                                                    00630500
               END;                                                             00630510
            END;                                                                00630520
            ELSE DO;  /* NONE OF ABOVE */                                       00630530
               CALL CHECK_AND_ENTER(I);                                         00630540
               IF SYT_TYPE(I) = EQUATE_LABEL THEN                               00630550
                  IF TOKEN = EOFILE THEN                                        00630560
                  SYT_NAME(I) = SUBSTR(SYT_NAME(I), 1); /* NO @ */              00630570
               I = I + 1;                                                       00630580
            END;                                                                00630590
         END;  /* OF WHILE I < BLOCK_SYTREF(1) */                               00630600
      END;  /* OF SREF PROCESSING */                                            00630610
NO_SREF:                                                                        00630620
      DO I = I TO NDECSY;                                                       00630630
         CALL CHECK_AND_ENTER(I, TRUE);                                         00630640
         IF SYT_TYPE(I) = EQUATE_LABEL THEN                                     00630650
            IF TOKEN = EOFILE THEN                                              00630660
            SYT_NAME(I) = SUBSTR(SYT_NAME(I), 1);  /* NO @ */                   00630670
      END;                                                                      00630680
      IF MAX_LENGTH < 4 THEN J = 4;                                             00631100
      ELSE J = MAX_LENGTH;                                                      00631110
      ATTR_START=J+44;                                                          00631700
      EXCHANGES = TRUE;                                                         00631800
                                                                                00631900
      IF ^CONTROL("F") THEN DO;                                                 00632000
         M = SHR(SORT_COUNT, 1);                                                00632100
         DO WHILE M > 0;                                                        00632200
            DO J = 1 TO SORT_COUNT - M;                                         00632300
               I = J;                                                           00632400
             DO WHILE STRING_GT(SYT_NAME(SYT_SORT(I)), SYT_NAME(SYT_SORT(I+M)));00632500
                  L = SYT_SORT(I);                                              00632600
                  SYT_SORT(I) = SYT_SORT(I + M);                                00632700
                  SYT_SORT(I + M) = L;                                          00632800
                  I = I - M;                                                    00632900
                  IF I < 1 THEN GO TO LM;                                       00633000
               END;  /* DO WHILE STRING_GT */                                   00633100
LM:                                                                             00633200
            END;  /* DO J */                                                    00633300
            M = SHR(M, 1);                                                      00633400
         END;  /* DO WHILE M */                                                 00633500
      END;  /* OF SORTING IF NOT CONTROL(F) */                                  00633510
                                                                                00633600
      T_CASE,T_LEVEL=0;                                                         00633700
      M=1;                                                                      00633800
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
               CALL PRINT_SYMBOL_HEADER(FALSE,TRUE);     /*CR12940*/            00633900
         DO CASE T_CASE;                                                        00634000
            I=SYT_SORT(M);                                                      00634100
            IF SYT_LINK1(I)>0 THEN DO;                                          00634200
               T_LEVEL=T_LEVEL+1;                                               00634300
               I=SYT_LINK1(I);                                                  00634400
            END;                                                                00634500
            ELSE DO;                                                            00634600
               DO WHILE SYT_LINK2(I)<0;                                         00634700
                  I=-SYT_LINK2(I);                                              00634800
                  T_LEVEL=T_LEVEL-1;                                            00634900
               END;                                                             00635000
               IF SYT_LINK2(I)=0 THEN DO;                                       00635100
                  T_CASE,T_LEVEL=0;                                             00635200
                  GO TO NO_INDIRECT;                                            00635300
               END;                                                             00635400
               ELSE I=SYT_LINK2(I);                                             00635500
            END;                                                                00635600
            I=I+1;                                                              00635700
         END;                                                                   00635800
         J=SYT_TYPE(I);                                                         00635900
         K=SYT_CLASS(I);                                                        00636000
         L=SYT_FLAGS(I);                                                        00636100
         IF (L&IMPL_T_FLAG)^=0 THEN GO TO NO_INDIRECT;                          00636200
         IF K>=TEMPLATE_CLASS THEN DO;                                          00636300
            IF J=TEMPL_NAME THEN IF (L&EVIL_FLAG)=0 THEN T_CASE=1;              00636400
         END;                                                                   00636500
         ELSE IF K=REPL_CLASS THEN DO;                                          00636600
            IF VAR_LENGTH(I)>0 THEN DO;                                         00636700
               T_CASE=2;                                                        00636800
               T_LEVEL=-VAR_LENGTH(I);                                          00636900
            END;                                                                00637000
         END;                                                                   00637100
         ELSE IF K=REPL_ARG_CLASS THEN DO;                                      00637200
            IF T_CASE=0 THEN GO TO NO_INDIRECT;                                 00637300
            T_LEVEL=T_LEVEL+1;                                                  00637400
            IF T_LEVEL=0 THEN T_CASE=0;                                         00637500
         END;                                                                   00637600
         IF J=IND_CALL_LAB THEN IF ^CONTROL("F") THEN GO TO NO_INDIRECT;        00637700
         T = PAD(SYT_NAME(I), ATTR_START - 44);                                 00637800
         IF K>=TEMPLATE_CLASS THEN DO;                                          00637900
            IF J=TEMPL_NAME THEN                 /*MOD-CR13336*/                00638000
               T=SUBSTR(T,1)||X4;                                               00638000
            ELSE IF T_CASE=0 THEN T=T||SUBSTR(X4,1);                            00638100
            ELSE T=X1||T||X2;                                                   00638200
         END;                                                                   00638300
         ELSE IF K=REPL_ARG_CLASS THEN T=X1||T||X2;                             00638400
         ELSE T=T||SUBSTR(X4,1);                                                00638500
         IF (L&IMP_DECL)^=0 THEN T=' *'||T;                                     00638600
         ELSE T=X2||T;                                                          00638700
         JL,JI=SYT_XREF(I);                                                     00638800
         IF TOKEN ^= EOFILE THEN                                                00638900
            JI = SHR(XREF(JI), 16);                                             00638910
         ELSE IF JI <= 0 THEN                                                   00638920
            JI = 0;                                                             00638930
         ELSE DO FOREVER;                                                       00638940
            IF (SHR(XREF(JI),13)&7)=0 THEN GO TO DEFINITION_FOUND;              00639000
            JI=SHR(XREF(JI),16);                                                00639100
            IF JI = 0 THEN DO;                                                  00639200
               JI = JL;                                                         00639210
               GO TO DEFINITION_FOUND;                                          00639400
            END;                                                                00639500
         END;                                                                   00639600
DEFINITION_FOUND:                                                               00639700
         KI=XREF(JI)&XREF_MASK;                                                 00639800
         V_ARRAY='';                                                            00639900
         T=I_FORMAT(KI,4)||T;                                                   00640000
         IF K = REPL_CLASS THEN                                                 00640100
            S = 'REPLACE MACRO';                                                00640110
         ELSE IF K=REPL_ARG_CLASS THEN DO;                                      00640500
            S='MACRO ARG';                                                      00640600
         END;                                                                   00640700
         ELSE IF J<TEMPL_NAME THEN DO;                                          00640800
            S=TRUNCATE( SUBSTR(VAR_NAME,J*11,11) );                 /*CR13335*/ 00640900
            IF J<MAT_TYPE THEN DO;                                              00641000
               IF VAR_LENGTH(I)=-1 THEN V_LEN='*';                              00641100
               ELSE V_LEN=VAR_LENGTH(I);                                        00641200
               S=S||'('||V_LEN||')';                                            00641300
            END;                                                                00641400
            ELSE IF J=VEC_TYPE THEN S=VAR_LENGTH(I)||' - '||S;                  00641500
            ELSE IF J=MAT_TYPE THEN DO;                                         00641600
               V_LEN=SHR(VAR_LENGTH(I),8)||' X ';                               00641700
               V_LEN=V_LEN||(VAR_LENGTH(I)&"FF");                               00641800
               S=V_LEN||X1||S;                                                  00641900
            END;                                                                00642000
            IF K=FUNC_CLASS|K=TPL_FUNC_CLASS THEN S=S||' FUNCTION';             00642100
            ELSE IF SYT_ARRAY(I)^=0 THEN DO;                                    00642200
               IF J=MAJ_STRUC THEN DO;                                          00642300
                  IF  SYT_ARRAY(I)<0 THEN V_LEN='*';                            00642400
                  ELSE V_LEN=SYT_ARRAY(I);                                      00642500
                  S=S||'('||V_LEN||')';                                         00642600
               END;                                                             00642700
               ELSE DO;                                                         00642800
                  S=S||' ARRAY';                                                00642900
                  V_ARRAY='ARRAY(';                                             00643000
                  DO KL=1 TO EXT_ARRAY(SYT_ARRAY(I));                           00643100
                     IF EXT_ARRAY(SYT_ARRAY(I)+KL)<0 THEN V_ARRAY=V_ARRAY||'*,';00643200
                     ELSE V_ARRAY=V_ARRAY||EXT_ARRAY(SYT_ARRAY(I)+KL)||',';     00643300
                  END;                                                          00643400
                  V_ARRAY=SUBSTR(V_ARRAY,0,LENGTH(V_ARRAY)-1)||')';             00643500
               END;                                                             00643600
            END;                                                                00643700
            IF J=MAJ_STRUC THEN DO;                                             00643800
               IF K^=TEMPLATE_CLASS THEN DO;                                    00643900
T_REFS:           V_ARRAY=SUBSTR(SYT_NAME(VAR_LENGTH(I)),1)||'-STRUCTURE';      00644000
               END;                                                             00644100
               ELSE IF VAR_LENGTH(I)>0 THEN GO TO T_REFS;                       00644200
               ELSE S='MINOR NODE';                                             00644300
            END;                                                                00644400
N_FIX:                                                                          00644500
            IF (L&NAME_FLAG)^=0 THEN S=NAMER||S;                                00644600
            IF T_LEVEL>0 THEN DO;                                               00644700
               S=SUBSTR(X70,0,MAX_STRUC_LEVEL+1)||S;                            00644800
               IF T_LEVEL<=MAX_STRUC_LEVEL THEN BYTE(S,T_LEVEL-1)=T_LEVEL|"F0"; 00644900
            END;                                                                00645000
         END;                                                                   00645100
         ELSE DO;                                                               00645200
            S=TRUNCATE( SUBSTR(LABEL_NAME,(J-TEMPL_NAME)*18,18) );  /*CR13335*/ 00645300
            IF (L&NAME_FLAG)^=0 THEN GO TO N_FIX;                               00645400
            L = L & SDF_INCL_OFF;                                               00645450
            IF J = STMT_LABEL THEN                                              00645500
               IF (VAR_LENGTH(I)>0)&(VAR_LENGTH(I)<3) THEN                      00645600
               S = 'UPDATE LABEL';                                              00645700
         END;                                                                   00645800
         S=PAD(T||S,ATTR_START);                                                00645900
         IF K>=TEMPLATE_CLASS THEN IF T_CASE=0 THEN IF J^=TEMPL_NAME THEN DO;   00646000
            KI=I;                                                               00646100
            DO WHILE SYT_TYPE(KI)^=TEMPL_NAME;                                  00646200
               KI=KI-1;                                                         00646300
            END;                                                                00646400
            R=' **** SEE STRUCTURE TEMPLATE'||SYT_NAME(KI);                     00646500
            T='';                                                               00646600
            IF (SYT_FLAGS(KI)&EVIL_FLAG)=0 THEN GO TO NO_XREF;                  00646700
         END;                                                                   00646800
         IF LENGTH(V_ARRAY)>0 THEN CALL ADD_ATTR(V_ARRAY);                      00646900
         IF (L&LATCHED_FLAG)^=0 THEN DO;                                        00647000
            IF J=EVENT_TYPE THEN CALL ADD_ATTR('LATCHED');                      00647100
         END;                                                                   00647200
         DO KL=1 TO 19;                                                         00647300
            IF (L&FLAG_MASK(KL))^=0 THEN                            /*CR13335*/ 00647400
               CALL ADD_ATTR(TRUNCATE(SUBSTR(CHAR_ATTR,KL*11,11))); /*CR13335*/ 00647400
         END;                                                                   00647500
         IF ^SDL_OPTION THEN                                                    00647600
            IF (L & EXTERNAL_FLAG) ^= 0 THEN                                    00647700
            CALL ADD_ATTR('VERSION=' || SYT_LOCK#(I));                          00647800
         IF (L&LOCK_FLAG)^=0 THEN DO;                                           00647900
/*CR13335*/ IF SYT_LOCK#(I)="FF"  THEN CALL ADD_ATTR(SUBSTR(CHAR_ATTR,0,6));    00648000
/*CR13335*/ ELSE CALL ADD_ATTR(SUBSTR(CHAR_ATTR,0,5)||SYT_LOCK#(I));            00648100
         END;                                                                   00648300
         IF CONTROL("F") THEN                                                   00648400
            DO;  /* EXTRA SYMBOL TABLE DUMP REQUESTED */                        00648500
            T = HEX(L);                                                         00648600
            CALL ADD_ATTR('FLAGS=' || T);                                       00648700
            CALL ADD_ATTR('NEST=' || SYT_NEST(I));                              00648800
            CALL ADD_ATTR('SCOPE=' || SYT_SCOPE(I));                            00648900
            CALL ADD_ATTR('PTR=' || SYT_PTR(I));                                00649000
            CALL ADD_ATTR('LENGTH='||VAR_LENGTH(I));                            00649100
            CALL ADD_ATTR('LINK1=' || SYT_LINK1(I));                            00649200
            CALL ADD_ATTR('LINK2=' || SYT_LINK2(I));                            00649300
            CALL ADD_ATTR('SYT_NO=' || I);                                      00649400
            CALL ADD_ATTR('ARRAY='||SYT_ARRAY(I));                              00649500
            CALL ADD_ATTR('ADDR='||SYT_ADDR(I));                                00649600
            CALL ADD_ATTR('CLASS='||SYT_CLASS(I));                              00649610
            CALL ADD_ATTR('TYPE='||SYT_TYPE(I));                                00649620
         END;                                                                   00649700
         IF K = REPL_CLASS THEN DO;                                             00649800
            CALL ADD_ATTR('MACRO TEXT="');                                      00649802
            S = SUBSTR(S, 0, LENGTH(S) - 2);                                    00649804
            JL = LENGTH(S);                                                     00649806
            S = S || SUBSTR(X256, 0, 132 - JL);  /* MAKE S 132 CHARS */         00649808
            KL = SYT_ADDR(I);  /* PTR TO TEXT */                                00649810
            JI = MACRO_TEXT(KL);  /* FIRST CHARACTER */                         00649812
MACRO_LOOP:                                                                     00649814
            DO WHILE JI ^= "EF" & JL < 132;                                     00649816
               IF JI = "EE" THEN DO;  /* MULTIPLE BLANKS */                     00649818
                  KL = KL + 1;                                                  00649820
                  JI = MACRO_TEXT(KL);                                          00649822
                  IF JI = 0 THEN GO TO MACRO_END;                               00649824
NEWLINE:                                                                        00649826
                  IF (JI + JL) > 132 THEN DO;                                   00649828
                     JI = JI - 132 + JL;                                        00649830
                     CALL MACRO_TEXT_RESET;                                     00649832
                     GO TO NEWLINE;                                             00649834
                  END;                                                          00649836
                  ELSE JL = JL + JI;                                            00649838
               END;  /* OF JI = "EE" */                                         00649840
               ELSE IF JI = BYTE('"') THEN DO;  /* DOUBLE ANY " */              00649842
                  BYTE(S, JL) = JI;                                             00649844
                  JL = JL + 1;                                                  00649846
                  IF JL < 132 THEN                                              00649848
DOUBLE_QUOTE:                                                                   00649850
                  BYTE(S, JL) = JI;                                             00649852
                  ELSE DO;                                                      00649854
                     CALL MACRO_TEXT_RESET;                                     00649856
                     GO TO DOUBLE_QUOTE;                                        00649858
                  END;                                                          00649860
               END;  /* OF JI = BYTE('"') */                                    00649862
               ELSE BYTE(S, JL) = JI;                                           00649864
               JL = JL + 1;                                                     00649866
               KL = KL + 1;                                                     00649868
               JI = MACRO_TEXT(KL);                                             00649870
            END;  /* OF WHILE JI ^= "EF" ETC */                                 00649872
            IF JI ^= "EF" THEN DO;  /* JUST RAN OUT OF ROOM */                  00649874
               CALL MACRO_TEXT_RESET;                                           00649876
               GO TO MACRO_LOOP;                                                00649878
            END;                                                                00649880
            ELSE DO;  /* END OF MACRO TEXT */                                   00649882
MACRO_END:                                                                      00649884
               IF JL < 132 THEN                                                 00649886
ADD_QUOTE:                                                                      00649888
               BYTE(S, JL) = BYTE('"');                                         00649890
               ELSE DO;                                                         00649892
                  CALL MACRO_TEXT_RESET;                                        00649894
                  GO TO ADD_QUOTE;                                              00649896
               END;                                                             00649898
               S = SUBSTR(S, 0, JL + 1);                                        00649900
            END;                                                                00649902
         END;  /* OF K = REPL_CLASS */                                          00649904
         ELSE S = SUBSTR(S, 0, LENGTH(S) - 2);                                  00649906
         T,R='';                                                                00650000
         KL=SYT_XREF(I);                                                        00650400
         IF TOKEN^=EOFILE|KL<=0 THEN                                            00650500
            DO;                                                                 00650600
            OUTPUT = S;                                                         00650700
            GO TO NO_INDIRECT;                                                  00650800
         END;                                                                   00650900
                                                                                00651000
                                                                                00651100
         KI=(LENGTH(S)-ATTR_START+7)/8;                                         00651300
         KI=(KI*8)+ATTR_START-LENGTH(S);                                        00651400
         IF KI>0 THEN S=S||SUBSTR(X70,0,KI);                                    00651500
         CALL ADD_ATTR('  XREF:     ');                                         00651600
         S=SUBSTR(S,0,LENGTH(S)-6);                                             00651700
         KI = 1;                                                                00651750
         JL = SHR(ADD_XREFS(SYT_XREF(I),FALSE), 13) & 7;            /*DR120220*/00651800
         IF JL THEN JL=JL|2;  /* MERGE SUBSCR & REF FLAGS  */                   00652300
         IF J=COMPOOL_LABEL THEN JL=JL|6;                                       00652400
         ELSE IF J=PROG_LABEL&(L&EXTERNAL_FLAG)=0 THEN JL=JL|6;                 00652500
         ELSE IF SYT_NEST(I)=0 THEN KI=0;                                       00652600
         ELSE IF SYT_SCOPE(I)<MAIN_SCOPE THEN JL=JL|6;                          00652700
         IF K>=TEMPLATE_CLASS THEN DO;                                          00652800
            IF J=TEMPL_NAME THEN JL=JL|4;                                       00652900
            ELSE JL=JL|8;                                                       00653000
         END;                                                                   00653100
         ELSE IF K=REPL_ARG_CLASS THEN JL=JL|6;                                 00653200
         ELSE IF (L&NAME_FLAG)^=0 THEN ;                                        00653300
         ELSE IF K^=VAR_CLASS THEN JL=JL|4;                                     00653400
         ELSE IF J=EVENT_TYPE THEN JL=JL|4;                                     00653500
         IF (L&INIT_CONST)^=0 THEN JL=JL|4;                                     00653600
         IF (L&INP_OR_CONST)^=0 THEN JL=JL|4;                                   00653700
         IF (L&ASSIGN_PARM)^=0 THEN KI=0;                                       00653800
         IF (L&MISC_NAME_FLAG)^=0 THEN IF J^=TEMPL_NAME THEN JL=JL|8;           00653900
         IF LABEL_ON_END THEN JL = JL|6;                /*DR111366*/
         JL=SHR(JL,1);                                                          00654000
         R=TRUNCATE(SUBSTR(CUSS,JL*23,23));                         /*CR13335*/ 00654100
         IF (JL=1)&KI THEN DO;                                                  00654200
            NOT_ASSIGNED_FLAG="FF";                                             00654300
            R='***** ERROR ***** REFERENCED BUT '||R;                           00654400
            OUTPUT = S || T;                                                    00654500
            OUTPUT = SUBSTR(X70,0,ATTR_START - 3) || R;  /* MAKE IT STICK OUT */00654600
            GO TO NO_INDIRECT;  /* SKIP OTHER PRINT LOGIC */                    00654700
         END;                                                                   00654800
NO_XREF:                                                                        00654900
         IF LENGTH(S)+LENGTH(T)+LENGTH(R)<=132 THEN DO;                         00655000
            S=S||T||R;                                                          00655100
            IF LENGTH(S)>ATTR_START THEN OUTPUT=S;                              00655200
         END;                                                                   00655300
         ELSE                                                                   00655400
            DO;                                                                 00655500
            OUTPUT = S || T;                                                    00655600
            OUTPUT = SUBSTR(X70, 0, ATTR_START) || R;                           00655700
         END;                                                                   00655800
NO_INDIRECT:                                                                    00655900
         /*THE LOGIC TO GO THROUGH STRUCTURES STARTS AT THE ROOT NODE AND  */
         /*ENDS AT THE ROOT NODE.  TO PREVENT VARIABLES FROM BEING PRINTED */
         /*TWICE, CHECK FOR T_CASE^=0 BECAUSE T_CASE=0 AT THE SECOND       */
         /*VISIT TO THE ROOT NODE BUT NOT THE FIRST.                       */
         IF (SYT_TYPE(I)=TEMPL_NAME) THEN               /*CR12940*/
            IF (T_CASE^=0) THEN CALL PRINT_VAR_NAMES(I);/*CR12940*/
         IF T_CASE=0 THEN M=M+1;                                                00656000
      END;                                                                      00656100
      IF XREF_FULL THEN DO;                                                     00656200
         CALL ERRORS (CLASS_BI, 102);                                           00656300
         NOT_ASSIGNED_FLAG = FALSE;                                             00656500
      END;                                                                      00656600
      ELSE IF NOT_ASSIGNED_FLAG THEN DO;                                        00656700
         IF MAX_SEVERITY<1 THEN MAX_SEVERITY=1;                                 00656800
         ERROR_COUNT=ERROR_COUNT+1;                                             00656900
         SAVE_SEVERITY(ERROR_COUNT)=1;                                          00657000
         SAVE_LINE_#(ERROR_COUNT)=-1;                                           00657100
         CALL ERRORS (CLASS_BI, 105);                                           00657200
      END;                                                                      00657400
      OUTPUT(1) = SUBHEADING;                                                   00657500
      DOUBLE_SPACE;                                                             00657600
      IF BI_XREF THEN IF TOKEN=EOFILE THEN DO;                                  00657700
         EJECT_PAGE;                                                            00657800
         OUTPUT(1)='0B U I L T - I N   F U N C T I O N   C R O S S   R E F E R E00657900
 N C E';                                                                        00658000
         OUTPUT(1)='0   (CROSS REFERENCE FLAG KEY:  4 = ASSIGNMENT, 2 = REFERENC00658100
E, 1 = SUBSCRIPT USE)';                                             /*DR120220*/00658200
         S='  NAME      CROSS REFERENCE';                                       00658300
         OUTPUT(1)=DOUBLE||S;                                                   00658400
         OUTPUT(1)=SUBHEADING||S;                                               00658500
         KI=BI_LIMIT+1;                                                         00658600
         ATTR_START=KI+6;                                                       00658700
         DO J = 1 TO BI#;                                                       00658800
            S = SUBSTR(BI_NAME(BI_INDX(J)),BI_LOC(J),10);           /*CR13335*/ 00658900
            IF BI_XREF(J)>0 THEN DO;                                            00659000
 /* KEEP TRACK OF THE USED XREF CELLS */                                        00659010
               BI_XREF#(0) = BI_XREF#(0)+1;                                     00659020
               S=S||'XREF: ';                                                   00659100
               KL=BI_XREF(J);                                                   00659200
               BI_XREF(J) = SHR(XREF(KL), 16);                                  00659300
               XREF(KL) = XREF(KL) & "FFFF";                                    00659310
               CALL ADD_XREFS(BI_XREF(J),TRUE);                     /*DR120220*/00659320
               IF LENGTH(T)>0 THEN OUTPUT=S||T;                                 00659400
            END;                                                                00659500
         END;                                                                   00659600
         CALL STORE_BI_XREF;                                                    00659610
         OUTPUT(1)=SUBHEADING;                                                  00659700
         DOUBLE_SPACE;                                                          00659800
      END;                                                                      00659900
   END SYT_DUMP;                                                                00660000
