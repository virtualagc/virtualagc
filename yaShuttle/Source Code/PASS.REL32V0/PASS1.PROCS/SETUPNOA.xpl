 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPNOA.xpl
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
 /* PROCEDURE NAME:  SETUP_NO_ARG_FCN                                       */
 /* MEMBER NAME:     SETUPNOA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PSEUDO_PREC       BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACCESS_FLAG                                                    */
 /*          BI_FUNC_FLAG                                                   */
 /*          BI_NAME                                                        */
 /*          CLASS_PL                                                       */
 /*          CLASS_PP                                                       */
 /*          CLASS_PS                                                       */
 /*          CLASS_XS                                                       */
 /*          COMM                                                           */
 /*          CONST_DW                                                       */
 /*          DO_LEVEL                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          FCN_LV                                                         */
 /*          INLINE_LEVEL                                                   */
 /*          INT_TYPE                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          PTR_TOP                                                        */
 /*          SCALAR_TYPE                                                    */
 /*          STMT_NUM                                                       */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LINK1                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_MAX                                                        */
 /*          VAR                                                            */
 /*          XBFNC                                                          */
 /*          XFCAL                                                          */
 /*          XLIT                                                           */
 /*          XXXND                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BI_INFO                                                        */
 /*          BI_FLAGS                                                       */
 /*          FIXF                                                           */
 /*          FIXL                                                           */
 /*          FOR_DW                                                         */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_TYPE                                                    */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          FLOATING                                                       */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_TUPLE                                                   */
 /*          PREC_SCALE                                                     */
 /*          SAVE_LITERAL                                                   */
 /*          SET_BI_XREF                                                    */
 /*          SET_XREF_RORS                                                  */
 /*          SETUP_VAC                                                      */
 /*          STRUCTURE_FCN                                                  */
 /*          UPDATE_BLOCK_CHECK                                             */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SETUP_NO_ARG_FCN <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> FLOATING                                                        */
 /*     ==> SAVE_LITERAL                                                    */
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
 /*     ==> SETUP_VAC                                                       */
 /*     ==> UPDATE_BLOCK_CHECK                                              */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> PREC_SCALE                                                      */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> MAKE_FIXED_LIT                                              */
 /*             ==> GET_LITERAL                                             */
 /*         ==> FLOATING                                                    */
 /*         ==> SAVE_LITERAL                                                */
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
 /*         ==> ARITH_LITERAL                                               */
 /*             ==> GET_LITERAL                                             */
 /*     ==> STRUCTURE_FCN                                                   */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  REVISION HISTORY                                                       */
 /*                                                                         */
 /*  DATE      WHO  RLS       DR/CR #   DESCRIPTION                         */
 /*                                                                         */
 /*  04/26/01  DCP  31V0/     CR13335   ALLEVIATE SOME DATA SPACE PROBLEMS  */
 /*                 16V0                IN HAL/S COMPILER                   */
 /*                                                                         */
 /***************************************************************************/
                                                                                00890800
                                                                                00890900
SETUP_NO_ARG_FCN:                                                               00891000
   PROCEDURE (PSEUDO_PREC);                                                     00891100
      DECLARE (PSEUDO_PREC, I) BIT(16);                                         00891200
      IF FIXL(MP)>SYT_MAX THEN DO;                                              00891300
         FIXL(MP)=FIXL(MP)-SYT_MAX;                                             00891400
         CALL SET_BI_XREF(FIXL(MP));                                            00891500
         BI_INFO=BI_INFO(FIXL(MP));                                             00891600
         BI_FLAGS=BI_FLAGS(FIXL(MP));                                           00891700
         IF ((BI_FLAGS&"10")^=0)&BI_FUNC_FLAG THEN DO;                          00891800
            DO CASE SHR(BI_INFO,8)&"0F";                                        00891900
               ;                                                                00892000
 /* DATE  */                                                                    00892100
               DO;                                                              00892200
                  PSEUDO_TYPE(PTR(MP))=INT_TYPE;                                00892300
                  CALL FLOATING(DATE);                                          00892400
               END;                                                             00892500
 /* CLOCKTIME */                                                                00892600
               DO;                                                              00892700
                  PSEUDO_TYPE(PTR(MP))=SCALAR_TYPE;                             00892800
                  CALL FLOATING(TIME);                                          00892900
                  DW(2)="42640000";                                             00893000
                  DW(3)=0;                                                      00893100
                  CALL MONITOR(9,4);  /* CHANGE TO SECONDS */                   00893200
               END;                                                             00893300
            END;                                                                00893400
            LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);                               00893500
            PSEUDO_FORM(PTR(MP))=XLIT;                                          00893600
         END;                                                                   00893700
         ELSE DO;                                                               00893800
            IF BI_FLAGS THEN                                        /*CR13335*/ 00893810
              CALL ERROR( CLASS_XS, 1,                              /*CR13335*/
                          SUBSTR( BI_NAME(BI_INDX(FIXL(MP))),       /*CR13335*/
                                  BI_LOC(FIXL(MP)),10 ) );          /*CR13335*/
            CALL HALMAT_POP(XBFNC,0,0,FIXL(MP));                                00893900
            CALL SETUP_VAC(MP,SHR(BI_INFO,24));                                 00894000
         END;                                                                   00894100
      END;                                                                      00894200
      ELSE DO;                                                                  00894300
         IF (SYT_FLAGS(FIXL(MP)) & ACCESS_FLAG) ^= 0 THEN                       00894400
            CALL ERROR(CLASS_PS, 7, VAR(MP));                                   00894500
         I = FIXL(MP);                                                          00894510
         IF SYT_LINK1(I) < 0 THEN DO;                                           00894520
            IF DO_LEVEL < (-SYT_LINK1(I)) THEN CALL ERROR(CLASS_PL, 9, VAR(MP));00894530
         END;                                                                   00894540
         ELSE IF SYT_LINK1(I) = 0 THEN SYT_LINK1(I) = STMT_NUM;                 00894550
         CALL UPDATE_BLOCK_CHECK(MP);                                           00894600
         CALL STRUCTURE_FCN;                                                    00894700
         CALL HALMAT_TUPLE(XFCAL,0,MP,0,FCN_LV+1);                              00894800
         CALL SETUP_VAC(MP,PSEUDO_TYPE(PTR_TOP));                               00894900
         CALL HALMAT_POP(XXXND,0,0,FCN_LV+1);                                   00895000
         IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,8);                         00895100
         CALL SET_XREF_RORS(MP,"6000");                                         00895200
      END;                                                                      00895300
      IF PSEUDO_PREC>0 THEN DO;                                                 00895400
         CALL PREC_SCALE(PSEUDO_PREC,PSEUDO_TYPE(PTR_TOP));                     00895500
         PSEUDO_PREC=0;                                                         00895800
      END;                                                                      00895900
      FIXF(MP)=0;                                                               00896000
   END SETUP_NO_ARG_FCN;                                                        00896100
