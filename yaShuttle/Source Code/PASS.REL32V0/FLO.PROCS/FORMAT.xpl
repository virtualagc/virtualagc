 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMAT.xpl
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
 /* PROCEDURE NAME:  FORMAT                                                 */
 /* MEMBER NAME:     FORMAT                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          IVAL              FIXED                                        */
 /*          N                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR              CHARACTER;                                   */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          STRING1           CHARACTER;                                   */
 /*          STRING2           CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X1                                                             */
 /*          X70                                                            */
 /* CALLED BY:                                                              */
 /*          SCAN_INITIAL_LIST                                              */
 /*          TRAVERSE_INIT_LIST                                             */
 /***************************************************************************/
                                                                                00130100
                                                                                00131118
 /*  SUBROUTINE FOR FORMATTING FIXED NUMBERS TO N-STRINGS  */                   00131120
FORMAT:                                                                         00131122
   PROCEDURE (IVAL,N) CHARACTER;                                                00131124
      DECLARE (STRING1,STRING2,CHAR) CHARACTER, (I,J,IVAL,N) FIXED;             00131126
      STRING1 = IVAL;                                                           00131128
      STRING2 = '';                                                             00131130
      J = LENGTH(STRING1) - 1;                                                  00131132
      DO I = 0 TO J;                                                            00131134
         CHAR = SUBSTR(STRING1,I,1);                                            00131136
         IF CHAR ^= X1 THEN STRING2 = STRING2||CHAR;                            00131138
      END;                                                                      00131140
      J = LENGTH(STRING2);                                                      00131142
      IF J < N THEN STRING2 = SUBSTR(X70,0,N-J)||STRING2;                       00131144
      RETURN STRING2;                                                           00131146
   END FORMAT;                                                                  00131148
