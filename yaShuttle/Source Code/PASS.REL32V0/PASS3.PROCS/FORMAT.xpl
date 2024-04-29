 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMAT.xpl
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
 /*          X72                                                            */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
                                                                                00135800
 /*  SUBROUTINE FOR FORMATTING FIXED NUMBERS TO N-STRINGS  */                   00135900
FORMAT:                                                                         00136000
   PROCEDURE (IVAL,N) CHARACTER;                                                00136100
      DECLARE (STRING1,STRING2,CHAR) CHARACTER, (I,J,IVAL,N) FIXED;             00136200
      STRING1 = IVAL;                                                           00136300
      STRING2 = '';                                                             00136400
      J = LENGTH(STRING1) - 1;                                                  00136500
      DO I = 0 TO J;                                                            00136600
         CHAR = SUBSTR(STRING1,I,1);                                            00136700
         IF CHAR ^= ' ' THEN STRING2 = STRING2||CHAR;                           00136800
      END;                                                                      00136900
      J = LENGTH(STRING2);                                                      00137000
      IF J < N THEN STRING2 = SUBSTR(X72,0,N-J)||STRING2;                       00137100
      RETURN STRING2;                                                           00137200
   END FORMAT;                                                                  00137300
