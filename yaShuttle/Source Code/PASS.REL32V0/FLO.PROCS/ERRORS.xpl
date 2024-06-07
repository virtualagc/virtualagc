 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORS.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  ERRORS                                                 */
 /* MEMBER NAME:     ERRORS                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /*          TEXT              CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SEVERITY          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          STMT#                                                          */
 /*          BOMB_OUT                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMMON_RETURN_CODE                                             */
 /*          ERROR_COUNT                                                    */
 /*          MAX_SEVERITY                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMMON_ERRORS                                                  */
 /* CALLED BY:                                                              */
 /*          CREATE_STMT                                                    */
 /*          DESCENDENT                                                     */
 /*          FORMAT_NAME_TERM_CELLS                                         */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          GET_SYT_VPTR                                                   */
 /*          INTEGER_LIT                                                    */
 /*          PROCESS_DECL_SMRK                                              */
 /*          PROCESS_EXTN                                                   */
 /*          SCAN_INITIAL_LIST                                              */
 /*          SEARCH_EXPRESSION                                              */
 /*          STACK_PTR                                                      */
 /*          TRAVERSE_INIT_LIST                                             */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ERRORS <==                                                          */
 /*     ==> COMMON_ERRORS                                                   */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
 /*  INCLUDE TABLE FOR DOWNGRADES:       $%DWNTABLE */                          00127760
 /*  INCLUDE DOWNGRADE SUMMARY:          $%DOWNSUM  */                          00127770
 /*  INCLUDE COMMON ERROR HANDLER:       $%CERRORS  */                          00127780
 /*PRINTS ERROR MESSAGES */                                                     00127790
ERRORS:                                                                         00127800
   PROCEDURE (CLASS, NUM, TEXT);                                                00127810
      DECLARE (CLASS, SEVERITY, NUM) BIT(16);                                   00127820
      DECLARE (TEXT) CHARACTER;                                                 00127830
      ERROR_COUNT = ERROR_COUNT + 1;                                            00127850
      SEVERITY = COMMON_ERRORS(CLASS, NUM, TEXT, ERROR_COUNT,STMT#);            00127860
      IF SEVERITY > MAX_SEVERITY THEN                                           00127870
         MAX_SEVERITY = SEVERITY;                                               00127880
      COMMON_RETURN_CODE = SHL(MAX_SEVERITY,2);                                 00127890
      IF SEVERITY > 1 THEN GO TO BOMB_OUT;                                      00127900
      RETURN;                                                                   00127910
   END ERRORS;                                                                  00127920
