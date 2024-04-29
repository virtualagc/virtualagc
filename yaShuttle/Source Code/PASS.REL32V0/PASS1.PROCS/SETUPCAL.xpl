 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPCAL.xpl
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
 /* PROCEDURE NAME:  SETUP_CALL_ARG                                         */
 /* MEMBER NAME:     SETUPCAL                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ARR_CHECKOUT      LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_TYPE                                                    */
 /*          BI_FLAGS                                                       */
 /*          CLASS_FD                                                       */
 /*          CLASS_FT                                                       */
 /*          CLASS_QX                                                       */
 /*          EXT_ARRAY                                                      */
 /*          FALSE                                                          */
 /*          FCN_LOC                                                        */
 /*          FCN_LV_MAX                                                     */
 /*          FCN_LV                                                         */
 /*          FCN_MODE                                                       */
 /*          INLINE_LEVEL                                                   */
 /*          INX                                                            */
 /*          LAST_POP#                                                      */
 /*          MAJ_STRUC                                                      */
 /*          MP                                                             */
 /*          NAME_PSEUDOS                                                   */
 /*          NEXT_ATOM#                                                     */
 /*          SP                                                             */
 /*          SYM_ARRAY                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_TYPE                                                       */
 /*          VAR                                                            */
 /*          VAR_LENGTH                                                     */
 /*          XCO_N                                                          */
 /*          XIMD                                                           */
 /*          XSFAR                                                          */
 /*          XXXAR                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          EXT_P                                                          */
 /*          FCN_ARG                                                        */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LOC_P                                                          */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          PTR_TOP                                                        */
 /*          TEMP                                                           */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHECK_ARRAYNESS                                                */
 /*          EMIT_ARRAYNESS                                                 */
 /*          ERROR                                                          */
 /*          GET_FCN_PARM                                                   */
 /*          HALMAT_FIX_PIP#                                                */
 /*          HALMAT_FIX_PIPTAGS                                             */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_TUPLE                                                   */
 /*          KILL_NAME                                                      */
 /*          MATRIX_COMPARE                                                 */
 /*          NAME_ARRAYNESS                                                 */
 /*          NAME_COMPARE                                                   */
 /*          RESET_ARRAYNESS                                                */
 /*          SAVE_ARRAYNESS                                                 */
 /*          STRUCTURE_COMPARE                                              */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SETUP_CALL_ARG <==                                                  */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
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
 /*     ==> HALMAT_FIX_PIPTAGS                                              */
 /*     ==> VECTOR_COMPARE                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> MATRIX_COMPARE                                                  */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /*     ==> STRUCTURE_COMPARE                                               */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> EMIT_ARRAYNESS                                                  */
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
 /*     ==> SAVE_ARRAYNESS                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> RESET_ARRAYNESS                                                 */
 /*     ==> NAME_COMPARE                                                    */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> RESET_ARRAYNESS                                             */
 /*     ==> KILL_NAME                                                       */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*         ==> RESET_ARRAYNESS                                             */
 /*     ==> NAME_ARRAYNESS                                                  */
 /*     ==> GET_FCN_PARM                                                    */
 /***************************************************************************/
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL     DR/CR NUMBER AND TITLE                            */
 /*                                                                         */
 /*04/28/04 DCP   32V0/   DR120264  AV5 ERROR FOR FORWARD FUNCTION CALL     */
 /*               17V0                                                      */
 /*                                                                         */
 /***************************************************************************/
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*   DATE   NAME   REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 08/23/02 DCP   32V0/   CR13571   COMBINE PROCEDURE/FUNCTION PARAMETER   */
 /*                17V0              CHECKING                               */
 /***************************************************************************/
                                                                                00904000
SETUP_CALL_ARG:                                                                 00904100
   PROCEDURE;                                                                   00904200
      DECLARE (I,J) BIT(16);                                                    00904300
      IF FCN_LV>FCN_LV_MAX THEN RETURN;                                         00904400
      I=PTR(SP);                                                                00904500
      IF FCN_MODE(FCN_LV)^=0 THEN IF KILL_NAME(SP) THEN CALL ERROR(CLASS_FT,10);00904600
      DO CASE FCN_MODE(FCN_LV);                                                 00904700
 /*  PROCS AND USER FUNCS  */                                                   00904800
         IF INLINE_LEVEL=0 THEN DO;                                             00904900
            CALL HALMAT_TUPLE(XXXAR,XCO_N,SP,0,FCN_LV);                         00905000
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(I)|                00905100
               SHL(NAME_PSEUDOS,7),0);                                          00905200
            PTR_TOP=I-1;                                                        00905300
            IF FCN_LV=0 THEN DO;                                                00905400
               FCN_ARG=FCN_ARG+1;                                               00905500
               IF NAME_PSEUDOS THEN DO;                                         00905600
                  CALL KILL_NAME(SP);                                           00905700
                  IF EXT_P(I)^=0 THEN CALL ERROR(CLASS_FD,7);                   00905800
               END;                                                             00905900
               CALL EMIT_ARRAYNESS;                             /*CR13571*/     00906000
            END;                                                                00906100
            ELSE IF FCN_ARG(FCN_LV)>=0 THEN DO;                 /*CR13571*/     00906200
 /*  ONLY IF FUNCTION DEFINED AND SOME PARMS LEFT  */                           00906300
               PTR=0;                                                           00906400
               LOC_P=GET_FCN_PARM;                                              00906500
               PSEUDO_LENGTH=VAR_LENGTH(LOC_P);                                 00906600
               IF NAME_PSEUDOS THEN DO;                         /*CR13571*/     00906800
                  IF SYT_TYPE(LOC_P)=MAJ_STRUC THEN DO;                         00906900
                     FIXV=LOC_P;                                                00907000
                     FIXL=VAR_LENGTH(LOC_P);                                    00907100
                     CURRENT_ARRAYNESS=SYT_ARRAY(LOC_P)^=0;                     00907200
                     CURRENT_ARRAYNESS(1)=SYT_ARRAY(LOC_P);                     00907300
                  END;                                                          00907400
                  ELSE DO;                                                      00907500
                     FIXL=LOC_P;                                                00907600
                     CURRENT_ARRAYNESS=EXT_ARRAY(SYT_ARRAY(LOC_P));             00907700
                     DO J=1 TO CURRENT_ARRAYNESS;                               00907800
                        CURRENT_ARRAYNESS(J)=EXT_ARRAY(SYT_ARRAY(LOC_P)+J);     00907900
                     END;                                                       00908000
                  END;                                                          00908100
                  PSEUDO_TYPE=SYT_TYPE(LOC_P);                                  00908200
                  EXT_P=0;                                                      00908300
  /* SEE NAME_COMPARE PROCEDURE FOR EXPLANATION OF BELOW STMT /*CR13571*/
                  J = (VAL_P(PTR(SP)) & "500") = "100";       /*CR13571*/
                  DO J = 1 TO J;                              /*CR13571*/
                     CALL RESET_ARRAYNESS;                    /*CR13571*/
                  END;                                        /*CR13571*/
                  CALL NAME_ARRAYNESS(SP);                                      00908500
                  GO TO ARR_CHECKOUT;                                           00908600
               END;                                                             00908700
               ELSE DO;                                                         00908800
                  PSEUDO_LENGTH=VAR_LENGTH(LOC_P);                              00908900
                  IF SYT_ARRAY(LOC_P)=0 THEN DO;                                00910000
ARR_CHECKOUT:                                                                   00910100
                     IF CURRENT_ARRAYNESS^=0 THEN PTR(MP)=0;                    00910200
 /* 1ST ARG, MP=SP AND PTR(SP)>0  */                                            00910300
                     IF RESET_ARRAYNESS THEN CALL ERROR(CLASS_FD,4);            00910400
                     CALL SAVE_ARRAYNESS;                                       00910500
                  END;                                                          00910600
                  ELSE IF SYT_TYPE(LOC_P)<MAJ_STRUC THEN DO;                    00910700
                     LOC_P=SYT_ARRAY(LOC_P);                                    00910800
                     CALL EMIT_ARRAYNESS;                                       00911700
                  END;                                                          00911800
                  ELSE                                                          00911900
                     CALL EMIT_ARRAYNESS;                        /*CR13571*/    00912400
               END;                                                             00912600
            END;                                                                00912700
 /*  FOR NONHAL FUNCTIONS  */                                                   00912900
            ELSE IF FCN_ARG(FCN_LV)=-2 THEN CALL EMIT_ARRAYNESS;                00912800
 /*  FOR FORWARD FUNCTION CALLS  */
            ELSE DO;                                              /*DR120264*/  00913000
               IF NAME_PSEUDOS THEN DO;                           /*DR120264*/
                  /*SEE NAME_COMPARE PROCEDURE FOR EXPLANATION OF BELOW STMT*/
                  IF ((VAL_P(PTR(SP)) & "500") = "100") THEN      /*DR120264*/
                     CALL RESET_ARRAYNESS;                        /*DR120264*/
                  CALL NAME_ARRAYNESS(SP);                        /*DR120264*/
               END;                                               /*DR120264*/
               IF CURRENT_ARRAYNESS^=0 THEN PTR(MP)=0;            /*DR120264*/
               IF RESET_ARRAYNESS THEN CALL ERROR(CLASS_FD,4);    /*DR120264*/
               CALL SAVE_ARRAYNESS;                               /*DR120264*/
            END;                                                  /*DR120264*/
         END;                                                                   00913100
 /*  NORMAL BUILT-IN FUNCTIONS  */                                              00913200
         DO;                                                                    00913300
            FCN_ARG(FCN_LV)=FCN_ARG(FCN_LV)+1;                                  00913400
         END;                                                                   00913500
 /*  ARITHMETIC SHAPERS  */                                                     00913600
         DO;                                                                    00913700
            IF FCN_ARG(FCN_LV)=0 THEN DO;                                       00913800
               FIXV(MP)=INX(I)=0;                                               00913900
               FIXL(MP)=0;                                                      00914000
               IF FCN_LOC(FCN_LV)>1 THEN CALL SAVE_ARRAYNESS(FALSE);            00914100
            END;                                                                00914200
            ELSE DO;                                                            00914300
               FIXV(MP)=FALSE;                                                  00914400
               PTR_TOP=I-1;                                                     00914500
            END;                                                                00914600
            TEMP=1;                                                             00914700
            DO CASE PSEUDO_TYPE(I);                                             00914800
               ;                                                                00914900
               IF FCN_LOC(FCN_LV)<2 THEN CALL ERROR(CLASS_QX,2);                00915000
               IF FCN_LOC(FCN_LV)<2 THEN CALL ERROR(CLASS_QX,3);                00915100
               DO;                                                              00915200
                  TEMP=SHR(PSEUDO_LENGTH(I),8)*TEMP;                            00915300
                  TEMP=(PSEUDO_LENGTH(I)&"FF")*TEMP;                            00915400
               END;                                                             00915500
               TEMP=PSEUDO_LENGTH(I)*TEMP;                                      00915600
               ; ; ; ; ;                                                        00915700
                  DO;                                                           00915800
                  TEMP=-1;                                                      00915900
                  CALL ERROR(CLASS_QX,1);                                       00916000
               END;                                                             00916100
            END;                                                                00916200
            CALL HALMAT_TUPLE(XSFAR,XCO_N,SP,0,FCN_LV);                         00916300
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(I),0);             00916400
            IF TEMP^=1 THEN FIXV(MP)=FALSE;                                     00916500
            IF INX(I)>0 THEN DO;                                                00916600
               TEMP=INX(I)*TEMP;                                                00916700
               CALL HALMAT_PIP(INX(I),XIMD,0,0);                                00916800
               CALL HALMAT_FIX_PIP#(LAST_POP#,2);                               00916900
            END;                                                                00917000
            VAL_P(I)=LAST_POP#;                                                 00917100
            DO I=1 TO CURRENT_ARRAYNESS;                                        00917200
               TEMP=CURRENT_ARRAYNESS(I)*TEMP;                                  00917300
            END;                                                                00917400
            IF TEMP<=0 THEN FIXL(MP)=TEMP; ELSE                                 00917500
               IF FIXL(MP)>=0 THEN FIXL(MP)=FIXL(MP)+TEMP;                      00917600
            CALL EMIT_ARRAYNESS;                                                00917700
            FCN_ARG(FCN_LV)=FCN_ARG(FCN_LV)+1;                                  00917800
         END;                                                                   00917900
 /*  STRING SHAPERS  */                                                         00918000
         DO;                                                                    00918100
            FCN_ARG(FCN_LV)=FCN_ARG(FCN_LV)+1;                                  00918200
         END;                                                                   00918300
 /*   L-FUNC BUILT-INS  */                                                      00918400
         DO;                                                                    00918500
            IF FCN_ARG(FCN_LV)>0 THEN DO;                                       00918600
               CALL CHECK_ARRAYNESS;                                            00918700
               PTR_TOP=I-1;                                                     00918800
            END;                                                                00918900
            ELSE DO;                                                            00919000
               CALL HALMAT_TUPLE(XSFAR,XCO_N,SP,0,FCN_LV,PSEUDO_TYPE(I),        00919100
                  SHR(BI_FLAGS(FCN_LOC(FCN_LV)),4)&"1");                        00919200
               CALL EMIT_ARRAYNESS;                                             00919300
            END;                                                                00919400
            FCN_ARG(FCN_LV)=FCN_ARG(FCN_LV)+1;                                  00919500
         END;                                                                   00919600
      END;                                                                      00919700
   END SETUP_CALL_ARG;                                                          00919800
