 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ATTACHS4.xpl
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
 /* PROCEDURE NAME:  ATTACH_SUBSCRIPT                                       */
 /* MEMBER NAME:     ATTACHS4                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          SS_FUNNIES        LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_AA                                                       */
 /*          CLASS_FT                                                       */
 /*          CLASS_SQ                                                       */
 /*          CLASS_SV                                                       */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          INT_TYPE                                                       */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          NAME_BIT                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SAVE_ARRAYNESS_FLAG                                            */
 /*          SCALAR_TYPE                                                    */
 /*          SP                                                             */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_ARRAY                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          SYT_CLASS                                                      */
 /*          SYT_PTR                                                        */
 /*          TEMPLATE_CLASS                                                 */
 /*          VAR_CLASS                                                      */
 /*          VAR                                                            */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYNESS_FLAG                                                 */
 /*          IND_LINK                                                       */
 /*          INX                                                            */
 /*          LOC_P                                                          */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          TEMP                                                           */
 /*          VAL_P                                                          */
 /*          VAR_ARRAYNESS                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /*          CHECK_ARRAYNESS                                                */
 /*          ERROR                                                          */
 /*          GET_ARRAYNESS                                                  */
 /*          MATCH_ARRAYNESS                                                */
 /*          RESET_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ATTACH_SUBSCRIPT <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /*     ==> RESET_ARRAYNESS                                                 */
 /*     ==> GET_ARRAYNESS                                                   */
 /*     ==> MATCH_ARRAYNESS                                                 */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> ATTACH_SUB_COMPONENT                                            */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> REDUCE_SUBSCRIPT                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> CHECK_SUBSCRIPT                                         */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> MAKE_FIXED_LIT                                      */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*         ==> AST_STACKER                                                 */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> PUSH_INDIRECT                                           */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> SLIP_SUBSCRIPT                                              */
 /*     ==> ATTACH_SUB_ARRAY                                                */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> REDUCE_SUBSCRIPT                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> CHECK_SUBSCRIPT                                         */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> MAKE_FIXED_LIT                                      */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*         ==> AST_STACKER                                                 */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> PUSH_INDIRECT                                           */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> SLIP_SUBSCRIPT                                              */
 /*     ==> ATTACH_SUB_STRUCTURE                                            */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> REDUCE_SUBSCRIPT                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> CHECK_SUBSCRIPT                                         */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> MAKE_FIXED_LIT                                      */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*         ==> AST_STACKER                                                 */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> PUSH_INDIRECT                                           */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> SLIP_SUBSCRIPT                                              */
 /***************************************************************************/
                                                                                00955600
ATTACH_SUBSCRIPT:                                                               00955700
   PROCEDURE;                                                                   00955800
      DECLARE (I,J) BIT(16);                                                    00955900
      INX=PTR(SP);                                                              00956000
      I=2;                                                                      00956100
      IND_LINK=0;                                                               00956200
      IF ^GET_ARRAYNESS THEN IF FIXL(SP)=3 THEN DO;                             00956300
         CALL ERROR(CLASS_FT,8,VAR(MP));                                        00956400
         INX(INX)=0;                                                            00956500
      END;                                                                      00956600
      IF INX(INX)>0 THEN DO;                                                    00956700
         IF PSEUDO_FORM(INX)^=0 THEN DO;                                        00956800
            CALL ERROR(CLASS_SQ,2,VAR(MP));                                     00956900
            PSEUDO_FORM(INX)=0;                                                 00957000
         END;                                                                   00957100
         NEXT_SUB=INX;                                                          00957200
         PSEUDO_LENGTH=0;                                                       00957300
         I=ATTACH_SUB_STRUCTURE(PSEUDO_LENGTH(INX));                            00957400
         J=ATTACH_SUB_ARRAY(VAL_P(INX));                                        00957500
         IF SYT_CLASS(FIXL(MP))^=VAR_CLASS THEN                                 00957600
            IF SYT_CLASS(FIXL(MP))^=TEMPLATE_CLASS THEN GO TO SS_FUNNIES;       00957700
         IF PSEUDO_TYPE(PTR(MP))<SCALAR_TYPE THEN DO;                           00957800
            IF I THEN I=ATTACH_SUB_STRUCTURE(0);                                00957900
            IF (I^=2) & J & (INX(INX)=0) THEN ESCAPE;                           00957910
            IF J THEN CALL ATTACH_SUB_ARRAY(0);                                 00958000
            CALL ATTACH_SUB_COMPONENT(INX(INX));                                00958100
         END;                                                                   00958200
         ELSE IF J&(SYT_ARRAY(FIXL(MP))>0) THEN DO;                             00958300
            IF I THEN I=ATTACH_SUB_STRUCTURE(0);                                00958400
            IF (I^=2) & (INX(INX)=0) THEN ESCAPE;                               00958410
            CALL ATTACH_SUB_ARRAY(INX(INX));                                    00958500
         END;                                                                   00958600
         ELSE                                                                   00958700
SS_FUNNIES:                                                                     00958800
         IF I&(SYT_ARRAY(FIXV(MP))^=0) THEN                                     00958900
            I=ATTACH_SUB_STRUCTURE(INX(INX));                                   00959000
         ELSE IF INX(INX)>0 THEN CALL ERROR(CLASS_SV,3,VAR(MP));                00959100
         IF VAR_ARRAYNESS>0 THEN DO;  /* RESIDUAL ARRAYNESS COMPACTIFICATION */ 00959200
            J=1;                                                                00959300
            DO VAR_ARRAYNESS=1 TO VAR_ARRAYNESS;                                00959400
               IF VAR_ARRAYNESS(VAR_ARRAYNESS)^=1 THEN DO;                      00959500
                  VAR_ARRAYNESS(J)=VAR_ARRAYNESS(VAR_ARRAYNESS);                00959600
                  J=J+1;                                                        00959700
               END;                                                             00959800
            END;                                                                00959900
            VAR_ARRAYNESS=J-1;                                                  00960000
         END;                                                                   00960100
      END;                                                                      00960200
      ELSE IF PSEUDO_FORM(INX)>0 THEN DO;                                       00960300
         TEMP=PSEUDO_TYPE(PTR(MP));                                             00960400
         IF TEMP<MAT_TYPE|TEMP>INT_TYPE THEN DO;                                00960500
            CALL ERROR(CLASS_SQ,1,VAR(MP));                                     00960600
            PSEUDO_FORM(INX)=0;                                                 00960700
         END;                                                                   00960800
      END;                                                                      00960900
      IF SYT_PTR(FIXL(MP))<0 THEN IF NAME_BIT=0 THEN DO;                        00961000
         LOC_P(PTR(MP))=-SYT_PTR(FIXL(MP));                                     00961100
         PSEUDO_FORM(PTR(MP))=XLIT;                                             00961200
      END;                                                                      00961300
      IF NAME_BIT^=0 THEN IF CHECK_ARRAYNESS THEN                               00961400
         VAL_P(PTR(MP))=VAL_P(PTR(MP))|"10";                                    00961500
      IF SUBSCRIPT_LEVEL=0 THEN ARRAYNESS_FLAG=SAVE_ARRAYNESS_FLAG;             00961600
      CALL MATCH_ARRAYNESS;                                                     00961700
      IF ARRAYNESS_FLAG THEN IF RESET_ARRAYNESS>0 THEN CALL ERROR(CLASS_AA,2,   00961800
         VAR(MP));                                                              00961900
      RETURN I^=2;                                                              00962000
   END ATTACH_SUBSCRIPT;                                                        00962100
