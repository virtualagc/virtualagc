 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITSMRK.xpl
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
 /* PROCEDURE NAME:  EMIT_SMRK                                              */
 /* MEMBER NAME:     EMITSMRK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          T                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HALMAT_RELOCATE_FLAG                                           */
 /*          INLINE_LEVEL                                                   */
 /*          NEXT_ATOM#                                                     */
 /*          SIMULATING                                                     */
 /*          SRN_PRESENT                                                    */
 /*          STMT_NUM                                                       */
 /*          TRUE                                                           */
 /*          XCO_N                                                          */
 /*          XIMRK                                                          */
 /*          XSMRK                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATOM#_FAULT                                                    */
 /*          COMM                                                           */
 /*          INLINE_STMT_RESET                                              */
 /*          SMRK_FLAG                                                      */
 /*          SRN_FLAG                                                       */
 /*          STATEMENT_SEVERITY                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_RELOCATE                                                */
 /*          STAB_HDR                                                       */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /*          RECOVER                                                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMIT_SMRK <==                                                       */
 /*     ==> STAB_HDR                                                        */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*     ==> HALMAT_RELOCATE                                                 */
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
 /***************************************************************************/
 /* REVISION HISTORY                                                        */
 /*                                                                         */
 /* DATE      WHO  RLS     DR/CR#    DESCRIPTION                            */
 /*                                                                         */
 /* 03/03/98  LJK  29V0/   DR109076  REPLACE MACRO SPLIT ON TWO LINES       */
 /*                14V0                                                     */
 /* 09/09/99  JAC  30V0/   DR111341  DO CASE STATEMENT PRINTED INCORRECTLY  */
 /*                15V0              (PRINT_FLUSH DELETED)                  */
 /***************************************************************************/
                                                                                00809500
EMIT_SMRK:                                                                      00809600
   PROCEDURE (T);                                                               00809700
      DECLARE T BIT(16) INITIAL(3);                                             00809800
      IF INLINE_LEVEL=0 THEN DO;                                                00809900
         CALL HALMAT_POP(XSMRK,1,XCO_N,STATEMENT_SEVERITY);                     00810000
         CALL HALMAT_PIP(STMT_NUM, 0, SMRK_FLAG, T>1);                          00810100
         IF HALMAT_RELOCATE_FLAG THEN CALL HALMAT_RELOCATE;                     00810200
         ATOM#_FAULT=NEXT_ATOM#;                                                00810300
      END;                                                                      00810400
      ELSE IF T<5 THEN DO;                                                      00810500
         CALL HALMAT_POP(XIMRK,1,XCO_N,STATEMENT_SEVERITY);                     00810600
         CALL HALMAT_PIP(STMT_NUM, 0, SMRK_FLAG, T>1);                          00810700
      END;                                                                      00810800
      STATEMENT_SEVERITY=0;                                                     00810900
      IF SIMULATING THEN IF T=3 THEN CALL STAB_HDR;                             00811000
      IF SRN_PRESENT THEN IF T THEN SRN_FLAG=TRUE;                              00811100
      IF INLINE_STMT_RESET>0 THEN DO;                                           00811200
         STMT_NUM=INLINE_STMT_RESET;                                            00811300
         INLINE_STMT_RESET=0;                                                   00811400
      END;                                                                      00811500
      ELSE IF T THEN STMT_NUM=STMT_NUM+1;                                       00811600
      T=3;                                                                      00811700
      SMRK_FLAG = 0;                                                            00811800
   END EMIT_SMRK;                                                               00811900
