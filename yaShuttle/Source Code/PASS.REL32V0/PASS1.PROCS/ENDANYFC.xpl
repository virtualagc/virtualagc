 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENDANYFC.xpl
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
 /* PROCEDURE NAME:  END_ANY_FCN                                            */
 /* MEMBER NAME:     ENDANYFC                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ARG#              BIT(16)                                      */
 /*          ARGPTR            BIT(16)                                      */
 /*          BI_COMPILE_TIME   LABEL                                        */
 /*          BI_FUNCS_DONE     LABEL                                        */
 /*          BI_FUNCS_EXIT     LABEL                                        */
 /*          END_ARITH_SHAPERS LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          MAXPTR            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_TYPE                                                    */
 /*          BI_ARG_TYPE                                                    */
 /*          BI_MULT                                                        */
 /*          BI_NAME                                                        */
 /*          BIT_LENGTH_LIM                                                 */
 /*          BIT_TYPE                                                       */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_FD                                                       */
 /*          CLASS_FN                                                       */
 /*          CLASS_FT                                                       */
 /*          CLASS_QA                                                       */
 /*          CLASS_QD                                                       */
 /*          CLASS_QX                                                       */
 /*          CLASS_VF                                                       */
 /*          CLASS_XS                                                       */
 /*          COMM                                                           */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          FALSE                                                          */
 /*          FCN_ARG                                                        */
 /*          FCN_LOC                                                        */
 /*          FCN_LV_MAX                                                     */
 /*          FCN_MODE                                                       */
 /*          FIX_DIM                                                        */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          FUNC_FLAG                                                      */
 /*          INLINE_LEVEL                                                   */
 /*          INT_TYPE                                                       */
 /*          INX                                                            */
 /*          IORS_TYPE                                                      */
 /*          LAST_POP#                                                      */
 /*          MP                                                             */
 /*          NEXTIME_LOC                                                    */
 /*          OPTIONS_CODE                                                   */
 /*          SCALAR_TYPE                                                    */
 /*          SP                                                             */
 /*          STACK_PTR                                                      */
 /*          STRING_MASK                                                    */
 /*          VAR                                                            */
 /*          XBFNC                                                          */
 /*          XBTOB                                                          */
 /*          XBTOC                                                          */
 /*          XBTOI                                                          */
 /*          XBTOS                                                          */
 /*          XCO_N                                                          */
 /*          XFCAL                                                          */
 /*          XIMD                                                           */
 /*          XITOS                                                          */
 /*          XLFNC                                                          */
 /*          XLIT                                                           */
 /*          XMSHP                                                          */
 /*          XPCAL                                                          */
 /*          XSFND                                                          */
 /*          XSTOI                                                          */
 /*          XXXND                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ASSIGN_ARG_LIST                                                */
 /*          BI_FLAGS                                                       */
 /*          BI_INFO                                                        */
 /*          CURRENT_ARRAYNESS                                              */
 /*          FCN_LV                                                         */
 /*          FIXF                                                           */
 /*          FOR_DW                                                         */
 /*          GRAMMAR_FLAGS                                                  */
 /*          IND_LINK                                                       */
 /*          LOC_P                                                          */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          PTR_TOP                                                        */
 /*          TEMP2                                                          */
 /*          TEMP                                                           */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARITH_LITERAL                                                  */
 /*          ERROR                                                          */
 /*          GET_FCN_PARM                                                   */
 /*          HALMAT_BACKUP                                                  */
 /*          HALMAT_FIX_PIP#                                                */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_TUPLE                                                   */
 /*          HALMAT_XNOP                                                    */
 /*          MATCH_SIMPLES                                                  */
 /*          MAX                                                            */
 /*          REDUCE_SUBSCRIPT                                               */
 /*          RESET_ARRAYNESS                                                */
 /*          SAVE_LITERAL                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> END_ANY_FCN <==                                                     */
 /*     ==> MAX                                                             */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SAVE_LITERAL                                                    */
 /*     ==> HALMAT_XNOP                                                     */
 /*     ==> HALMAT_BACKUP                                                   */
 /*     ==> HALMAT_POP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_TUPLE                                                    */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*     ==> HALMAT_FIX_PIP#                                                 */
 /*     ==> SETUP_VAC                                                       */
 /*     ==> MATCH_SIMPLES                                                   */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> SETUP_VAC                                                   */
 /*     ==> ARITH_LITERAL                                                   */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> RESET_ARRAYNESS                                                 */
 /*     ==> GET_FCN_PARM                                                    */
 /*     ==> REDUCE_SUBSCRIPT                                                */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> CHECK_SUBSCRIPT                                             */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> MAKE_FIXED_LIT                                          */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /***************************************************************************/
 /*    REVISION HISTORY :                                                   */
 /*    ------------------                                                   */
 /*   DATE    NAME  REL   DR NUMBER AND TITLE                               */
 /* --------  ---- -----  ------------------------------------------------- */
 /* 02/21/96  TEV  27V1/  CR12623  CLARIFY IMPLICIT CONVERSION REQUIREMENTS */
 /*                11V1                                                     */
 /*                                                                         */
 /* 06/12/01  TKN  31V0/  111376   NO SR3 ERROR GENERATED FOR CHARACTER     */
 /*                16V0            SHAPING FUNCTION                         */
 /*                                                                         */
 /* 04/26/01  DCP  31V0/  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS IN    */
 /*                16V0            HAL/S COMPILER                           */
 /*                                                                         */
 /* 04/20/04  DCP  32V0/  CR13832  REMOVE UNPRINTED TYPE 1 HAL/S COMPILER   */
 /*                17V0            OPTIONS                                  */
 /*                                                                         */
 /* 09/29/03  JAC  32V0/  DR120223 NO FT101 ERROR FOR LITERAL ARGUMENT      */
 /*                17V0                                                     */
 /*                                                                         */
 /* 08/23/02  DCP  32V0/  CR13571  COMBINE PROCEDURE/FUNCTION PARAMETER     */
 /*                17V0            CHECKING                                 */
 /*                                                                         */
 /***************************************************************************/
                                                                                00964800
END_ANY_FCN:                                                                    00964900
   PROCEDURE;                                                                   00965000
      DECLARE (ARG#,I,MAXPTR) BIT(16);                                          00965100
      DECLARE ARGPTR BIT(16);                                                   00965200
      DECLARE BI_FUNCS_DONE LABEL;                                              00965300
      DECLARE BI_FUNCS_EXIT LABEL;                                              00965310
                                                                                00965400
BI_COMPILE_TIME:                                                                00965500
      PROCEDURE;                                                                00965600
                                                                                00965755
         IF (SHR(BI_INFO,8)&"F")=0 THEN RETURN;                                 00965760
         IF ARITH_LITERAL(SP-1,0) THEN DO;                                      00965800
            IF MONITOR(9,SHR(BI_INFO,8)&"F") THEN DO;                           00965930
               CALL ERROR(CLASS_VF,1,VAR(MP));                                  00966000
               RETURN;                                                          00966100
            END;                                                                00966200
            LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);                               00966300
            PSEUDO_FORM(PTR(MP))=XLIT;                                          00966400
            GO TO BI_FUNCS_EXIT;                                                00966500
         END;                                                                   00966600
      END BI_COMPILE_TIME;                                                      00966700
                                                                                00966800
      GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|FUNC_FLAG;      00966900
      MAXPTR=PTR(SP-1);                                                         00967000
      PTR_TOP=PTR(MP)-(FCN_LV=0);                                               00967100
      IF FCN_LV>FCN_LV_MAX THEN DO;                                             00967200
         FCN_LV=FCN_LV-1;                                                       00967300
         RETURN;                                                                00967400
      END;                                                                      00967500
      DO CASE FCN_MODE(FCN_LV);                                                 00967600
 /*  PROCS AND USER FUNCS  */                                                   00967700
         DO;                                                                    00967800
            ASSIGN_ARG_LIST=FALSE;                                              00967900
            IF INLINE_LEVEL>0 THEN RETURN;                                      00968000
            IF FCN_LV=0 THEN                             /*CR13571*/            00968100
               CALL HALMAT_TUPLE(XPCAL,0,MP,0,0);                               00968400
            ELSE DO;                                                            00968600
               CALL RESET_ARRAYNESS;                                            00968900
               CALL HALMAT_TUPLE(XFCAL,0,MP,0,FCN_LV);                          00969000
               CALL SETUP_VAC(MP,PSEUDO_TYPE(PTR(MP)));                         00969100
            END;                                                                00969200
            IF MAXPTR>0 THEN MAXPTR=XCO_N;                                      00969300
            CALL HALMAT_POP(XXXND,0,MAXPTR,FCN_LV);                             00969400
         END;                                                                   00969500
 /*  NORMAL BUILT-IN FUNCS  */                                                  00969600
         DO;                                                                    00969700
            PTR(SP) = MAXPTR + 1;  /* TEMP PTR TO SECOND ARG */                 00969800
            PTR(SP - 2) = MAXPTR + 2;  /* DITTO FOR THIRD ARG */                00969900
            BI_FLAGS=BI_FLAGS(FCN_LOC(FCN_LV));                                 00970000
            BI_INFO=BI_INFO(FCN_LOC(FCN_LV));                                   00970100
            ARG#=SHR(BI_INFO,16)&"FF";                                          00970200
            ARGPTR=BI_INFO&"FF";                                                00970300
            IF ARG#^=FCN_ARG(FCN_LV) THEN CALL ERROR(CLASS_FN,4,VAR(MP));       00970400
            ELSE IF (SHL(1,PSEUDO_TYPE(MAXPTR)) &                               00970500
               ASSIGN_TYPE(BI_ARG_TYPE(ARGPTR))) = 0                            00970600
               THEN CALL ERROR(CLASS_FT,2,VAR(MP));                             00970700
            ELSE DO;                                                            00970800
               IF ARG#>=2 THEN IF (SHL(1,PSEUDO_TYPE(MAXPTR+1)) &               00970900
                  ASSIGN_TYPE(BI_ARG_TYPE(ARGPTR+1)))=0 THEN DO;                00971000
                  CALL ERROR(CLASS_FT,2,VAR(MP));                               00971100
                  GO TO BI_FUNCS_DONE;                                          00971200
               END;                                                             00971300
               IF ARG#=3 THEN IF (SHL(1,PSEUDO_TYPE(MAXPTR+2)) &                00971400
                  ASSIGN_TYPE(BI_ARG_TYPE(ARGPTR+2)))=0 THEN DO;                00971500
                  CALL ERROR(CLASS_FT, 2, VAR(MP));                             00971600
                  GO TO BI_FUNCS_DONE;                                          00971700
               END;                                                             00971800
               DO CASE BI_ARG_TYPE(ARGPTR);                                     00971900
                  ;  /* THIS CASE NOT USED  */                                  00972000
                  DO; /* BIT TYPE */                                            00972100
                     IF FCN_LOC(FCN_LV) = NEXTIME_LOC THEN DO; /* NEXTIME ARG */00972200
                        IF INX(MAXPTR) ^= 2 THEN  /* MUST BE PROCESS */         00972300
                           CALL ERROR(CLASS_FT, 2, VAR(MP));                    00972400
                     END;                                                       00972500
                     ELSE PSEUDO_LENGTH(PTR(MP)) =                              00972600
                        MAX(PSEUDO_LENGTH(MAXPTR), PSEUDO_LENGTH(MAXPTR + 1));  00972700
                  END;                                                          00972800
 /*  CHARACTER TYPE  */                                                         00972900
                  DO;                                                           00973000
                     IF PSEUDO_TYPE(MAXPTR)^=CHAR_TYPE THEN DO;                 00973100
                        CALL HALMAT_TUPLE(XBTOC(PSEUDO_TYPE(MAXPTR)-BIT_TYPE),  00973200
                           0,SP-1,0,0);                                         00973300
                        CALL SETUP_VAC(SP-1,CHAR_TYPE);                         00973400
                     END;                                                       00973500
                     IF ARG#=2 THEN DO;                                         00973600
                        IF BI_ARG_TYPE(ARGPTR + 1) = CHAR_TYPE THEN DO;         00973700
                           IF PSEUDO_TYPE(MAXPTR+1)^=CHAR_TYPE THEN DO;         00973800
                         CALL HALMAT_TUPLE(XBTOC(PSEUDO_TYPE(MAXPTR+1)-BIT_TYPE)00973900
                                 ,0,SP,0,0);                                    00974000
                              CALL SETUP_VAC(SP,CHAR_TYPE);                     00974100
                           END;                                                 00974200
                        END;                                                    00974300
                        ELSE IF PSEUDO_TYPE(MAXPTR+1)=SCALAR_TYPE THEN DO;      00974400
                           CALL HALMAT_TUPLE(XSTOI,0,SP,0,0);                   00974500
                           CALL SETUP_VAC(SP,INT_TYPE);                         00974600
                        END;                                                    00974700
                     END;                                                       00974800
                  END;                                                          00974900
 /* MATRIX TYPE  */                                                             00975000
                  DO;                                                           00975100
                     IF (BI_FLAGS&"80")^=0 THEN PSEUDO_LENGTH(PTR(MP))=         00975200
                        SHL(PSEUDO_LENGTH(MAXPTR),8)|                           00975300
                        SHR(PSEUDO_LENGTH(MAXPTR),8);                           00975400
                     ELSE PSEUDO_LENGTH(PTR(MP))=PSEUDO_LENGTH(MAXPTR);         00975500
                     IF (BI_FLAGS&"40")^=0 THEN DO;                             00975600
                        IF (PSEUDO_LENGTH(MAXPTR)&"FF")^=                       00975700
                           SHR(PSEUDO_LENGTH(MAXPTR),8) THEN                    00975800
                           CALL ERROR(CLASS_FD,6,VAR(MP));                      00975900
                     END;                                                       00976000
                  END;                                                          00976100
 /*  VECTOR TYPE  */                                                            00976200
                  PSEUDO_LENGTH(PTR(MP))=PSEUDO_LENGTH(MAXPTR);                 00976300
 /*  SCALAR TYPE  */                                                            00976400
                  DO;                                                           00976500
                     CALL BI_COMPILE_TIME;                                      00976600
                     IF PSEUDO_TYPE(MAXPTR)=INT_TYPE THEN DO;                   00976700
                        CALL HALMAT_TUPLE(XITOS,0,SP-1,0,0);                    00976800
                        CALL SETUP_VAC(SP-1,SCALAR_TYPE);                       00976900
                     END;                                                       00977000
                     IF ARG#>=2 THEN IF PSEUDO_TYPE(MAXPTR+1)=INT_TYPE THEN DO; 00977100
                        CALL HALMAT_TUPLE(XITOS, 0, SP, 0, 0);                  00977200
                        CALL SETUP_VAC(SP, SCALAR_TYPE);                        00977300
                     END;                                                       00977400
                     IF ARG#=3 THEN IF PSEUDO_TYPE(MAXPTR+2)=INT_TYPE THEN DO;  00977500
                        CALL HALMAT_TUPLE(XITOS, 0, SP-2, 0, 0);                00977600
                        CALL SETUP_VAC(SP-2, SCALAR_TYPE);                      00977700
                     END;                                                       00977800
                  END;                                                          00977900
 /*  INTEGER TYPE  */                                                           00978000
                  DO;                                                           00978100
                     CALL BI_COMPILE_TIME;                                      00978200
                     IF PSEUDO_TYPE(MAXPTR)=SCALAR_TYPE THEN DO;                00978300
                        CALL HALMAT_TUPLE(XSTOI,0,SP-1,0,0);                    00978400
                        CALL SETUP_VAC(SP-1,INT_TYPE);                          00978500
                     END;                                                       00978600
                    IF ARG#=2 THEN IF PSEUDO_TYPE(MAXPTR+1)=SCALAR_TYPE THEN DO;00978700
                        CALL HALMAT_TUPLE(XSTOI,0,SP,0,0);                      00978800
                        CALL SETUP_VAC(SP,INT_TYPE);                            00978900
                     END;                                                       00979000
                     PSEUDO_LENGTH(PTR(MP))=1;                                  00979100
                  END;                                                          00979200
                  ;  /* THIS CASE NOT USED  */                                  00979300
 /*  IORS TYPE  */                                                              00979400
                  DO;                                                           00979500
                     IF ARG#=2 THEN CALL MATCH_SIMPLES(SP-1,SP);                00979600
                     IF SHR(BI_INFO,24)=IORS_TYPE THEN                          00979700
                        PSEUDO_TYPE(PTR(MP))=PSEUDO_TYPE(MAXPTR);               00979800
                     IF ARG#=1 THEN CALL BI_COMPILE_TIME;                       00979900
                  END;                                                          00980000
               END;                                                             00980100
               CALL HALMAT_POP(XBFNC,ARG#,0,FCN_LOC(FCN_LV));                   00980200
               DO I = MAXPTR TO MAXPTR + ARG# - 1;                              00980300
                  CALL HALMAT_PIP(LOC_P(I), PSEUDO_FORM(I), PSEUDO_TYPE(I), 0); 00980400
               END;                                                             00980500
               CALL SETUP_VAC(MP,PSEUDO_TYPE(PTR(MP)));                         00980600
            END;                                                                00980700
BI_FUNCS_DONE:                                                                  00980800
            IF BI_FLAGS THEN                                        /*CR13335*/ 00980810
               CALL ERROR( CLASS_XS, 1,                             /*CR13335*/
                           SUBSTR( BI_NAME(BI_INDX(FCN_LOC(FCN_LV))),/*C13335*/
                                   BI_LOC(FCN_LOC(FCN_LV)), 10 ) ); /*CR13335*/
BI_FUNCS_EXIT:                                                                  00980820
         END;                                                                   00980900
 /*  ARITHMETIC SHAPERS  */                                                     00981000
         DO;                                                                    00981100
            ARG#=PTR(MP);                                                       00981200
            TEMP2=XMSHP(FCN_LOC(FCN_LV));                                       00981300
            IF FCN_LOC(FCN_LV)>=2 THEN DO;  /*  INTEGER AND SCALAR */           00981400
               CALL RESET_ARRAYNESS;                                            00981500
               IF INX(ARG#)=0 THEN DO;                                          00981600
                  IF FIXV(SP-1) THEN DO;                                        00981700
                     CALL HALMAT_XNOP(VAL_P(ARG#));                             00981800
                     CALL HALMAT_BACKUP(VAL_P(MAXPTR));                         00981900
                     IF RESET_ARRAYNESS=3 THEN CALL ERROR(CLASS_QA,1);          00982000
                     DO CASE FCN_LOC(FCN_LV)-2;                                 00982100
                        TEMP=XBTOS(PSEUDO_TYPE(MAXPTR)-BIT_TYPE);               00982200
                        TEMP=XBTOI(PSEUDO_TYPE(MAXPTR)-BIT_TYPE);               00982300
                     END;                                                       00982400
                     /* CR12623 FIX -- TEV -- 2/14/96                */
                     /* IF THERE WAS NO PRECISION SPECIFIED ON THE   */
                     /* ARITHMETIC CONVERSION (PSEUDO_FORM=0) AND    */
                     /* THE CONVERSION IS INTEGER TO SCALAR ("5C1"), */
                     /* FORCE THE PRECISION TO SINGLE (PSEUDO_FORM=1)*/
                     /* TO PREVENT THIS CR'S FIX IN GENCLAS5 FROM    */
                     /* GENERATING A DOUBLE PRECISION RESULT.        */
    /*DR120223 - ALSO SET PRECISION TO SINGLE FOR SCALAR TO SCALAR ("5A1"),*/
    /*DR120223 - SCALAR TO INTEGER ("6A1"), AND INTEGER TO INTEGER ("6C1").*/
    /* CR12623 */    IF PSEUDO_FORM(ARG#) = 0 & (TEMP="5C1"
    /*DR120223*/     | TEMP="5A1" | TEMP="6C1" | TEMP="6A1") THEN
    /* CR12623 */       PSEUDO_FORM(ARG#) = 1;
                     CALL HALMAT_TUPLE(TEMP,0,SP-1,0,PSEUDO_FORM(ARG#));        00982500
                     CALL SETUP_VAC(MP,PSEUDO_TYPE(ARG#));                      00982600
                     GO TO END_ARITH_SHAPERS;                                   00982700
                  END;                                                          00982800
                  ELSE DO;                                                      00982900
                     CURRENT_ARRAYNESS=1;                                       00983000
                     CURRENT_ARRAYNESS(1)=FIXL(SP-1);                           00983100
                     IF CURRENT_ARRAYNESS(1)<2 THEN CALL ERROR(CLASS_QA,2);     00983200
                  END;                                                          00983300
               END;                                                             00983400
               ELSE DO;                                                         00983500
                  CURRENT_ARRAYNESS=INX(ARG#);                                  00983600
                  DO I=1 TO CURRENT_ARRAYNESS;                                  00983700
                     CURRENT_ARRAYNESS(I)=LOC_P(ARG#+I);                        00983800
                  END;                                                          00983900
                  IF FIXL(SP-1)<=0 THEN CALL ERROR(CLASS_QA,2);                 00984000
                  ELSE IF FIXL(SP-1)^=PSEUDO_LENGTH(ARG#) THEN                  00984100
                     CALL ERROR(CLASS_QA,3);                                    00984200
               END;                                                             00984300
               CALL HALMAT_POP(TEMP2,CURRENT_ARRAYNESS,0,FCN_LV);               00984400
               CALL HALMAT_PIP(CURRENT_ARRAYNESS(1),XIMD,PSEUDO_FORM(ARG#),     00984500
                  0);                                                           00984600
               DO I=2 TO CURRENT_ARRAYNESS;                                     00984700
                  CALL HALMAT_PIP(CURRENT_ARRAYNESS(I),XIMD,0,0);               00984800
               END;                                                             00984900
               IF RESET_ARRAYNESS=3 THEN CALL ERROR(CLASS_QA,4);                00985000
            END;                                                                00985100
            ELSE DO;   /*  VECTOR AND MATRIX  */                                00985200
               CALL RESET_ARRAYNESS;                                            00985300
               IF INX(ARG#)^=FIXL(SP-1) THEN CALL ERROR(CLASS_QD,1);            00985400
               CALL HALMAT_POP(TEMP2,1,0,FCN_LV);                               00985500
               CALL HALMAT_PIP(PSEUDO_LENGTH(ARG#),XIMD,PSEUDO_FORM(ARG#),      00985600
                  0);                                                           00985700
            END;                                                                00985800
            CALL SETUP_VAC(MP,PSEUDO_TYPE(ARG#));                               00985900
            CALL HALMAT_POP(XSFND,0,XCO_N,FCN_LV);                              00986000
END_ARITH_SHAPERS:                                                              00986100
            VAL_P(ARG#)=0;                                                      00986200
         END;                                                                   00986300
 /*  STRING  SHAPERS  */                                                        00986400
         DO;                                                                    00986500
            NEXT_SUB=PTR(MP);                                                   00986600
            IND_LINK,PSEUDO_LENGTH=0;                                           00986700
            IF FCN_ARG(FCN_LV)>1 THEN CALL ERROR(CLASS_QD,2);                   00986800
            IF (SHL(1,PSEUDO_TYPE(MAXPTR))&STRING_MASK)=0 THEN DO;              00986900
               CALL ERROR(CLASS_QX,4);                                          00987000
               IF FCN_LOC(FCN_LV)=0 THEN PSEUDO_TYPE(MAXPTR)=BIT_TYPE;          00987100
               ELSE PSEUDO_TYPE(MAXPTR)=CHAR_TYPE;                              00987200
            END;                                                                00987300
            DO CASE FCN_LOC(FCN_LV);                                            00987400
 /*  CHARACTER  */                                                              00987500
               DO;                                                              00987600
                  IF PSEUDO_FORM(NEXT_SUB)^=0 THEN                              00987700
                     IF PSEUDO_TYPE(MAXPTR)^=BIT_TYPE THEN                      00987800
                     CALL ERROR(CLASS_QX,5);                                    00987900
                  IF INX(NEXT_SUB)>0 THEN DO;  /*DR111376*/
                   IF (PSEUDO_TYPE(MAXPTR)=BIT_TYPE) |   /*DR111376*/
                      (PSEUDO_TYPE(MAXPTR)=CHAR_TYPE &   /*DR111376*/
                       PSEUDO_FORM(MAXPTR)^=XVAC) THEN   /*DR111376*/
 /*DR111376*/         CALL REDUCE_SUBSCRIPT(0,PSEUDO_LENGTH(MAXPTR),1);
                   ELSE CALL REDUCE_SUBSCRIPT(0,-1,1);   /*DR111376*/
                  END;                                   /*DR111376*/
                  ARG#=XBTOC(PSEUDO_TYPE(MAXPTR)-BIT_TYPE);                     00988100
               END;                                                             00988200
 /*  BIT  */                                                                    00988300
               DO;                                                              00988400
                  IF PSEUDO_FORM(NEXT_SUB)^=0 THEN                              00988500
                     IF PSEUDO_TYPE(MAXPTR)^= CHAR_TYPE THEN                    00988600
                     CALL ERROR(CLASS_QX,6);                                    00988700
                  IF INX(NEXT_SUB)>0 THEN DO;                                   00988800
                     CALL REDUCE_SUBSCRIPT(0,BIT_LENGTH_LIM);                   00988900
                     PSEUDO_LENGTH(PTR_TOP)=FIX_DIM;                            00989000
                  END;                                                          00989100
                  ELSE PSEUDO_LENGTH(PTR_TOP)=BIT_LENGTH_LIM;                   00989200
                  ARG#=XBTOB(PSEUDO_TYPE(MAXPTR)-BIT_TYPE);                     00989300
               END;                                                             00989400
            END;                                                                00989500
            CALL HALMAT_TUPLE(ARG#,0,SP-1,0,PSEUDO_FORM(PTR_TOP));              00989600
            CALL SETUP_VAC(MP,PSEUDO_TYPE(PTR_TOP));                            00989700
            ARG#=1;                                                             00989800
            I=0;                                                                00989900
            DO WHILE I^=IND_LINK;                                               00990000
               I=PSEUDO_LENGTH(I);                                              00990100
               IF PSEUDO_TYPE(I)^=0 THEN DO;                                    00990200
                  CALL HALMAT_PIP(SHR(PSEUDO_TYPE(I),4),PSEUDO_TYPE(I)&"F",     00990300
                     INX(I),VAL_P(I));                                          00990400
                  CALL HALMAT_PIP(LOC_P(I),PSEUDO_FORM(I),0,0);                 00990500
                  ARG#=ARG#+1;                                                  00990600
               END;                                                             00990700
               ELSE CALL HALMAT_PIP(LOC_P(I),PSEUDO_FORM(I),INX(I),VAL_P(I));   00990800
               ARG#=ARG#+1;                                                     00990900
            END;                                                                00991000
            CALL HALMAT_FIX_PIP#(LAST_POP#,ARG#);                               00991100
         END;                                                                   00991200
 /*  L-FUNC  BUILT-INS  */                                                      00991300
         DO;                                                                    00991400
            I=PSEUDO_TYPE(MAXPTR);                                              00991500
            BI_INFO=BI_INFO(FCN_LOC(FCN_LV));                                   00991600
            BI_FLAGS=BI_FLAGS(FCN_LOC(FCN_LV));                                 00991700
            IF BI_FLAGS THEN                                        /*CR13335*/ 00991800
               CALL ERROR( CLASS_XS, 1,                             /*CR13335*/
                           SUBSTR( BI_NAME(BI_INDX(FCN_LOC(FCN_LV))),/*C13335*/
                                   BI_LOC(FCN_LOC(FCN_LV)), 10 ) ); /*CR13335*/
            IF (SHL(1,I)&ASSIGN_TYPE(BI_ARG_TYPE(BI_INFO&"FF")))=0 THEN         00991810
               CALL ERROR(CLASS_FT,2,VAR(MP));                                  00991900
            IF FCN_ARG(FCN_LV)>1 THEN CALL ERROR(CLASS_FN,4,VAR(MP));           00992000
            CALL HALMAT_POP(XLFNC,1,0,FCN_LV);                                  00992100
            CALL HALMAT_PIP(FCN_LOC(FCN_LV),XIMD,I,0);                          00992200
            IF SHR(BI_FLAGS,4) THEN I=SHR(BI_INFO,24);                          00992300
            CALL SETUP_VAC(MP,I);                                               00992400
            CALL HALMAT_POP(XSFND,0,XCO_N,FCN_LV);                              00992500
            CALL RESET_ARRAYNESS;                                               00992600
         END;                                                                   00992700
      END;                                                                      00992800
      IF FCN_LV>0 THEN FCN_LV=FCN_LV-1;                                         00992900
      FIXF(MP)=0;                                                               00993000
   END END_ANY_FCN;                                                             00993100
