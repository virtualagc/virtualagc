 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENDSUBBI.xpl
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
 /* PROCEDURE NAME:  END_SUBBIT_FCN                                         */
 /* MEMBER NAME:     ENDSUBBI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          T                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BIT_LENGTH_LIM                                                 */
 /*          BIT_TYPE                                                       */
 /*          CLASS_QX                                                       */
 /*          CLASS_SR                                                       */
 /*          INT_TYPE                                                       */
 /*          LAST_POP#                                                      */
 /*          LOC_P                                                          */
 /*          MP                                                             */
 /*          MPP1                                                           */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          STRING_MASK                                                    */
 /*          VAL_P                                                          */
 /*          XBTOQ                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FIXL                                                           */
 /*          FIX_DIM                                                        */
 /*          FIXV                                                           */
 /*          IND_LINK                                                       */
 /*          INX                                                            */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR_TOP                                                        */
 /*          TEMP                                                           */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_FIX_PIP#                                                */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_TUPLE                                                   */
 /*          REDUCE_SUBSCRIPT                                               */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> END_SUBBIT_FCN <==                                                  */
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
 /*     ==> SETUP_VAC                                                       */
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
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*04/20/05  TKN  32V0  120269 INCORRECT QX9 ERROR FOR BIT IN SUBBIT        */
 /*               17V0                                                      */
 /***************************************************************************/
                                                                                00993200
END_SUBBIT_FCN:                                                                 00993300
   PROCEDURE (T);                                                               00993400
      DECLARE T BIT(16);                                                        00993500
      TEMP=PTR(MPP1);                                                           00993600
      IF (VAL_P(TEMP)^=-1)&(SHR(VAL_P(TEMP),8)) THEN  /*DR120269*/
          CALL ERROR(CLASS_QX,9);                                               00993700
      NEXT_SUB=PTR(MP);                                                         00993800
      IF (SHL(1,PSEUDO_TYPE(TEMP))&STRING_MASK)=0 THEN DO;                      00993900
         CALL ERROR(CLASS_QX,8);                                                00994000
         PSEUDO_TYPE(TEMP)=INT_TYPE;                                            00994100
      END;                                                                      00994200
      IND_LINK,PSEUDO_LENGTH=0;                                                 00994300
      IF INX(NEXT_SUB)=0 THEN FIX_DIM=BIT_LENGTH_LIM;                           00994400
      ELSE DO;                                                                  00994500
         CALL REDUCE_SUBSCRIPT(0,0);                                            00994600
         IF FIX_DIM>BIT_LENGTH_LIM THEN DO;                                     00994700
            FIX_DIM=BIT_LENGTH_LIM;                                             00994800
            CALL ERROR(CLASS_SR,2,VAR(MP));                                     00994900
         END;                                                                   00995000
         ELSE IF FIX_DIM<0 THEN DO;                                             00995100
            FIX_DIM=1;                                                          00995200
            CALL ERROR(CLASS_SR,6,VAR(MP));                                     00995300
         END;                                                                   00995400
      END;                                                                      00995500
      CALL HALMAT_TUPLE(XBTOQ(PSEUDO_TYPE(TEMP)-BIT_TYPE),0,MPP1,0,T);          00995600
      CALL SETUP_VAC(MP,BIT_TYPE,FIX_DIM);                                      00995700
      T=0;                                                                      00995800
      NEXT_SUB=1;                                                               00995900
      DO WHILE T^=IND_LINK;                                                     00996000
         T=PSEUDO_LENGTH(T);                                                    00996100
         CALL HALMAT_PIP(LOC_P(T),PSEUDO_FORM(T),INX(T),VAL_P(T));              00996200
         NEXT_SUB=NEXT_SUB+1;                                                   00996300
      END;                                                                      00996400
      CALL HALMAT_FIX_PIP#(LAST_POP#,NEXT_SUB);                                 00996500
      PTR_TOP=PTR(MP);                                                          00996600
      INX(PTR_TOP)=0;                                                           00996700
      FIXL(MP)=FIXL(MPP1);                                                      00996800
      FIXV(MP)=FIXV(MPP1);                                                      00996900
      VAR(MP)=VAR(MPP1);                                                        00997000
      T=0;                                                                      00997100
   END END_SUBBIT_FCN;                                                          00997200
