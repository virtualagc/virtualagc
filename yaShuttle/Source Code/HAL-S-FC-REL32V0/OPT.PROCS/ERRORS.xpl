 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORS.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
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
 /*          ERROR#            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          STT#                                                           */
 /*          DISASTER                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMMON_RETURN_CODE                                             */
 /*          MAX_SEVERITY                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMMON_ERRORS                                                  */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          COMBINED_LITERALS                                              */
 /*          CSE_MATCH_FOUND                                                */
 /*          GET_FREE_SPACE                                                 */
 /*          LIT_ARITHMETIC                                                 */
 /*          MOVE_LIMB                                                      */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_HALMAT_BLOCK                                               */
 /*          SAVE_LITERAL                                                   */
 /*          TEMPLATE_LIT                                                   */
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
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /*                                                                         */
 /* 07/11/95 DAS  27V0  CR12416  CLEANUP COMPILER ERROR PROCESSING          */
 /*               11V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00637210
 /* INCLUDE COMMON ERROR DECLERATIONS:  $%CERRDECL */                           00637220
 /* INCLUDE TABLE FOR DOWNGRADES:       $%DWNTABLE */                           00637230
 /* INCLUDE COMMON_ERRORS:              $%CERRORS  */                           00637240
 /* INCLUDE DOWNGRADE SUMMARY:          $%DOWNSUM  */                           00637250
ERRORS:                                                                         00637260
   PROCEDURE (CLASS, NUM, TEXT);                                                00637270
      DECLARE (CLASS, SEVERITY, NUM, ERROR#) BIT(16);                           00637280
      DECLARE (TEXT) CHARACTER;                                                 00637290
      ERROR# = ERROR# + 1;                                                      00637310
      SEVERITY = COMMON_ERRORS (CLASS, NUM, TEXT, ERROR#, STT#);                00637320
      IF SEVERITY > MAX_SEVERITY THEN                                           00637330
         MAX_SEVERITY = SEVERITY;                                               00637340
      COMMON_RETURN_CODE = SHL(MAX_SEVERITY,2);                                 00637350
      /* CR12416: INHIBIT OBJECT CODE GENERATION */                             00637360
      IF SEVERITY > 1 THEN GO TO DISASTER;  /* CR12416 */                       00637360
   END ERRORS;                                                                  00637370
