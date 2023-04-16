 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTDAT.xpl
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
 /* PROCEDURE NAME:  PRINT_DATE_AND_TIME                                    */
 /* MEMBER NAME:     PRINTDAT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MESSAGE           CHARACTER;                                   */
 /*          D                 FIXED                                        */
 /*          T                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C                 CHARACTER;                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHARDATE                                                       */
 /*          PRINT_TIME                                                     */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINT_DATE_AND_TIME <==                                             */
 /*     ==> CHARDATE                                                        */
 /*     ==> PRINT_TIME                                                      */
 /*         ==> CHARTIME                                                    */
 /***************************************************************************/
                                                                                00781600
PRINT_DATE_AND_TIME:                                                            00781700
   PROCEDURE(MESSAGE, D, T);                                                    00781800
      DECLARE (MESSAGE, C) CHARACTER, (D, T) FIXED;                             00781900
      C = CHARDATE(D);                                                          00782000
      CALL PRINT_TIME(MESSAGE || C || '.  CLOCK TIME = ', T);                   00782100
   END PRINT_DATE_AND_TIME;                                                     00782200
