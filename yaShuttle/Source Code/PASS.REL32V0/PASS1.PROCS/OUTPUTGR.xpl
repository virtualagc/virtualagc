 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OUTPUTGR.xpl
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
 /* PROCEDURE NAME:  OUTPUT_GROUP                                           */
 /* MEMBER NAME:     OUTPUTGR                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CURRENT_SCOPE                                                  */
 /*          DOUBLE                                                         */
 /*          FALSE                                                          */
 /*          LINE_LIM                                                       */
 /*          SAVE_GROUP                                                     */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /*          LISTING2_COUNT                                                 */
 /*          NEXT                                                           */
 /*          TOO_MANY_LINES                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PRINT2                                                         */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> OUTPUT_GROUP <==                                                    */
 /*     ==> PRINT2                                                          */
 /***************************************************************************/
                                                                                00278800
OUTPUT_GROUP:                                                                   00278900
   PROCEDURE;                                                                   00279000
      IF NEXT < 0 THEN                                                          00279100
         RETURN;                                                                00279200
      IF LISTING2_COUNT + NEXT + 2 > LINE_LIM THEN                              00279300
         LISTING2_COUNT = LINE_LIM;                                             00279400
      CALL PRINT2(DOUBLE || SAVE_GROUP || X1 || CURRENT_SCOPE, 2);              00279500
      DO I = 1 TO NEXT;                                                         00279600
         CALL PRINT2(X1 || SAVE_GROUP(I) || X1 || CURRENT_SCOPE, 1);            00279700
      END;                                                                      00279800
      IF TOO_MANY_LINES THEN                                                    00279900
         CALL PRINT2(' *** WARNING *** INPUT BUFFER FILLED; NOT ALL SOURCE LINES00280000
 ARE PRINTED.', 1);                                                             00280100
      NEXT = -1;                                                                00280200
      TOO_MANY_LINES = FALSE;                                                   00280300
   END OUTPUT_GROUP;                                                            00280400
