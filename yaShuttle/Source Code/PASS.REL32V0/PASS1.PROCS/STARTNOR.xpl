 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STARTNOR.xpl
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
 /* PROCEDURE NAME:  START_NORMAL_FCN                                       */
 /* MEMBER NAME:     STARTNOR                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MODE              BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACCESS_FLAG                                                    */
 /*          BI_FLAGS                                                       */
 /*          BI_INFO                                                        */
 /*          CLASS_PL                                                       */
 /*          CLASS_PP                                                       */
 /*          CLASS_PS                                                       */
 /*          COMM                                                           */
 /*          DEFINED_LABEL                                                  */
 /*          DO_LEVEL                                                       */
 /*          INLINE_LEVEL                                                   */
 /*          INT_TYPE                                                       */
 /*          IORS_TYPE                                                      */
 /*          MP                                                             */
 /*          NONHAL_FLAG                                                    */
 /*          PTR_TOP                                                        */
 /*          STACK_PTR                                                      */
 /*          STMT_NUM                                                       */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_TYPE                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_MAX                                                        */
 /*          SYT_TYPE                                                       */
 /*          VAR                                                            */
 /*          VAR_LENGTH                                                     */
 /*          XCO_N                                                          */
 /*          XSFST                                                          */
 /*          XSYT                                                           */
 /*          XXXST                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXT_P                                                          */
 /*          FCN_ARG                                                        */
 /*          FCN_LOC                                                        */
 /*          FCN_LV                                                         */
 /*          FIXL                                                           */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SYM_TAB                                                        */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          PUSH_FCN_STACK                                                 */
 /*          PUSH_INDIRECT                                                  */
 /*          SAVE_ARRAYNESS                                                 */
 /*          SET_BI_XREF                                                    */
 /*          SET_XREF_RORS                                                  */
 /*          STRUCTURE_FCN                                                  */
 /*          UPDATE_BLOCK_CHECK                                             */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> START_NORMAL_FCN <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SET_BI_XREF                                                     */
 /*         ==> ENTER_XREF                                                  */
 /*     ==> SET_XREF_RORS                                                   */
 /*         ==> SET_XREF                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SET_OUTER_REF                                           */
 /*                 ==> COMPRESS_OUTER_REF                                  */
 /*                     ==> MAX                                             */
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
 /*     ==> PUSH_INDIRECT                                                   */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> PUSH_FCN_STACK                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> UPDATE_BLOCK_CHECK                                              */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> SAVE_ARRAYNESS                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> STRUCTURE_FCN                                                   */
 /**********************************************************************
 /*                                                                   */
 /* REVISION HISTORY :                                                */
 /* ------------------                                                */
 /* DATE     NAME  REL   DR/CR#  DESCRIPTION                          */
 /*                                                                   */
 /* 04/05/94 JAC   26V0  108643  INCORRECTLY LISTS 'NONHAL INSTEAD OF */
 /*                10V0          'INCREM' IN SDFLIST                  */
 /*                                                                   */
 /***************************************************************************/
                                                                                00896200
START_NORMAL_FCN:                                                               00896300
   PROCEDURE BIT(16);                                                           00896400
      DECLARE MODE BIT(8), TEMP BIT(16);                                        00896500
      PTR(MP)=PUSH_INDIRECT(1);                                                 00896600
      IF FIXL(MP)>SYT_MAX THEN DO;                                              00896700
         FIXL(MP)=FIXL(MP)-SYT_MAX;                                             00896800
         CALL SET_BI_XREF(FIXL(MP));                                            00896900
         PSEUDO_TYPE(PTR_TOP)=SHR(BI_INFO(FIXL(MP)),24);                        00897000
         IF PSEUDO_TYPE(PTR_TOP)=IORS_TYPE THEN PSEUDO_TYPE(PTR_TOP)=INT_TYPE;  00897100
         IF (BI_FLAGS(FIXL(MP))&"20")=0 THEN MODE=1;                            00897200
         ELSE MODE=4;                                                           00897300
         LOC_P(PTR_TOP)=FIXL(MP);                                               00897400
         PSEUDO_FORM(PTR_TOP)=XSYT;                                             00897500
      END;                                                                      00897600
      ELSE DO;                                                                  00897700
         IF (SYT_FLAGS(FIXL(MP)) & ACCESS_FLAG) ^= 0 THEN                       00897800
            CALL ERROR(CLASS_PS,7,VAR(MP));                                     00897900
         TEMP = FIXL(MP);                                                       00897910
         IF SYT_LINK1(TEMP) < 0 THEN DO;                                        00897920
            IF DO_LEVEL<(-SYT_LINK1(TEMP)) THEN CALL ERROR(CLASS_PL,9,VAR(MP)); 00897930
         END;                                                                   00897940
         ELSE IF SYT_LINK1(TEMP) = 0 THEN SYT_LINK1(TEMP) = STMT_NUM;           00897950
         MODE=0;                                                                00898000
         VAL_P(PTR_TOP)=0;                                                      00898100
         EXT_P(PTR_TOP)=STACK_PTR(MP);                                          00898200
         PSEUDO_TYPE(PTR_TOP)=SYT_TYPE(FIXL(MP));                               00898300
         PSEUDO_LENGTH(PTR_TOP)=VAR_LENGTH(FIXL(MP));                           00898400
      END;                                                                      00898500
      IF PUSH_FCN_STACK(MODE) THEN DO;                                          00898600
         FCN_LOC(FCN_LV)=FIXL(MP);                                              00898700
         DO CASE MODE;                                                          00898800
            IF INLINE_LEVEL=0 THEN DO;                                          00898900
               CALL SAVE_ARRAYNESS;                                             00899000
               CALL HALMAT_POP(XXXST,1,XCO_N,FCN_LV);                           00899100
               CALL HALMAT_PIP(FIXL(MP),XSYT,0,0);                              00899200
               CALL UPDATE_BLOCK_CHECK(MP);                                     00899300
               IF (SYT_FLAGS(FIXL(MP))&DEFINED_LABEL)=0 THEN                    00899400
                  FCN_ARG(FCN_LV)=-1;                                           00899500
               /*** DR108643 ***/
               ELSE IF (SYT_FLAGS2(FIXL(MP))&NONHAL_FLAG)^=0 THEN               00899600
               /*** END DR108643 ***/
                  FCN_ARG(FCN_LV)=-2;                                           00899700
               LOC_P(PTR_TOP)=FIXL(MP);                                         00899800
               PSEUDO_FORM(PTR_TOP)=XSYT;                                       00899900
               CALL STRUCTURE_FCN;                                              00900000
               CALL SET_XREF_RORS(MP,"6000");                                   00900100
            END;                                                                00900200
            ELSE DO;                                                            00900300
               CALL ERROR(CLASS_PP,8);                                          00900400
               FCN_LV=FCN_LV-1;                                                 00900500
            END;                                                                00900600
            ;                                                                   00900700
            ;                                                                   00900800
            ;                                                                   00900900
            DO;                                                                 00901000
               CALL SAVE_ARRAYNESS;                                             00901100
               CALL HALMAT_POP(XSFST,0,XCO_N,FCN_LV);                           00901200
            END;                                                                00901300
         END;                                                                   00901400
      END;                                                                      00901500
      RETURN MODE=0;                                                            00901600
   END START_NORMAL_FCN;                                                        00901700
