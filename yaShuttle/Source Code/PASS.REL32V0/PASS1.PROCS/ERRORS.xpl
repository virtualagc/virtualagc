 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORS.xpl
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
 /* PROCEDURE NAME:  ERRORS                                                 */
 /* MEMBER NAME:     ERRORS                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /*          TEXT              CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SEVERITY          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          ALMOST_DISASTER                                                */
 /*          FALSE                                                          */
 /*          STMT_NUM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMPILING                                                      */
 /*          ERROR_COUNT                                                    */
 /*          MAX_SEVERITY                                                   */
 /*          SAVE_SEVERITY                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMMON_ERRORS                                                  */
 /* CALLED BY:                                                              */
 /*          OUTPUT_WRITER                                                  */
 /*          INITIALIZATION                                                 */
 /*          STREAM                                                         */
 /*          SYT_DUMP                                                       */
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
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00261606
 /* INCLUDE COMMON ERROR HANDLER:  $%CERRORS  */                                00261607
                                                                                00261608
ERRORS:PROCEDURE(CLASS, NUM, TEXT);  /* HANDLES ONCE QUIET MESSAGES */          00261609
      DECLARE (CLASS, SEVERITY, NUM) BIT(16);                                   00261610
      DECLARE TEXT CHARACTER;                                                   00261611
      ERROR_COUNT = ERROR_COUNT + 1;                                            00261613
 /*  BI106 IS THE ERROR FOR TOO MANY ERRORS AND THEREFORE  */                   00261614
 /*  ERROR_COUNT NEEDS TO BE DECREMENTED THEN INCREMENTED  */                   00261615
      IF NUM = 106 THEN                                                         00261616
         ERROR_COUNT = ERROR_COUNT - 1;                                         00261617
      SEVERITY = COMMON_ERRORS(CLASS, NUM, TEXT, ERROR_COUNT, STMT_NUM);        00261618
      IF NUM = 106 THEN                                                         00261619
         ERROR_COUNT = ERROR_COUNT + 1;                                         00261620
      SAVE_SEVERITY(ERROR_COUNT) = SEVERITY;                                    00261621
      IF SEVERITY > MAX_SEVERITY THEN                                           00261622
         MAX_SEVERITY = SEVERITY;                                               00261623
      IF MAX_SEVERITY > 2 THEN DO;                                              00261624
         COMPILING = FALSE;                                                     00261625
         GO TO ALMOST_DISASTER;                                                 00261626
      END;                                                                      00261627
   END ERRORS;                                                                  00261628
