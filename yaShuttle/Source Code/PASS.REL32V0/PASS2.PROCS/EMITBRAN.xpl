 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITBRAN.xpl
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
/* PROCEDURE NAME:  EMIT_BRANCH_AROUND                                     */
/* MEMBER NAME:     EMITBRAN                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* LOCAL DECLARATIONS:                                                     */
/*          SAVE_LINE         FIXED                                        */
/*          DELTA             FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BR_ARND                                                        */
/*          INDEXNEST                                                      */
/*          LOCCTR                                                         */
/*          SAVE_LOCCTR                                                    */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_LINE                                                      */
/*          SAVE_CODE_LINE                                                 */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMITC                                                          */
/*          EMITW                                                          */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMIT_BRANCH_AROUND <==                                              */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/*     ==> EMITW                                                           */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/***************************************************************************/
                                                                                00786615
 /* ROUTINE TO EMIT BRANCH AROUND FROM PREVIOUSLY SAVED CHECKPOINT */           00786620
EMIT_BRANCH_AROUND:                                                             00786625
   PROCEDURE FIXED;                                                             00786630
      DECLARE (SAVE_LINE, DELTA) FIXED;                                         00786635
      IF SAVE_CODE_LINE > 0 THEN DO;                                            00786640
         DELTA = LOCCTR(INDEXNEST) - SAVE_LOCCTR;                               00786645
         SAVE_LINE = CODE_LINE;  CODE_LINE = SAVE_CODE_LINE;                    00786650
            CALL EMITC(BR_ARND, DELTA);                                         00786655
         CALL EMITW(SAVE_LINE, 1);                                              00786660
         CODE_LINE = SAVE_LINE; SAVE_LINE = SAVE_CODE_LINE; SAVE_CODE_LINE = 0; 00786665
            RETURN SAVE_LINE;                                                   00786670
      END;                                                                      00786675
      RETURN 0;                                                                 00786680
   END EMIT_BRANCH_AROUND;                                                      00786685
