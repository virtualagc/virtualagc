 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTTIM.xpl
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
 /* PROCEDURE NAME:  PRINT_TIME                                             */
 /* MEMBER NAME:     PRINTTIM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MESSAGE           CHARACTER;                                   */
 /*          T                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C                 CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PERIOD                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHARTIME                                                       */
 /* CALLED BY:                                                              */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINT_TIME <==                                                      */
 /*     ==> CHARTIME                                                        */
 /***************************************************************************/
                                                                                00780900
PRINT_TIME:                                                                     00781000
   PROCEDURE(MESSAGE, T);                                                       00781100
      DECLARE (MESSAGE, C) CHARACTER, T FIXED;                                  00781200
      C = CHARTIME(T);                                                          00781300
      OUTPUT = MESSAGE || C || PERIOD;                                          00781400
   END PRINT_TIME;                                                              00781500
