 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMAT.xpl
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
/*          X72                                                            */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00129900
 /*  SUBROUTINE FOR FORMATTING FIXED NUMBERS TO N-STRINGS  */                   00130000
FORMAT:                                                                         00130100
   PROCEDURE (IVAL,N) CHARACTER;                                                00130200
      DECLARE (STRING1,STRING2,CHAR) CHARACTER, (I,J,IVAL,N) FIXED;             00130300
      STRING1 = IVAL;                                                           00130400
      STRING2 = '';                                                             00130500
      J = LENGTH(STRING1) - 1;                                                  00130600
      DO I = 0 TO J;                                                            00130700
         CHAR = SUBSTR(STRING1,I,1);                                            00130800
         IF CHAR ^= X1 THEN STRING2 = STRING2||CHAR;                            00130900
      END;                                                                      00131000
      J = LENGTH(STRING2);                                                      00131100
      IF J < N THEN STRING2 = SUBSTR(X72,0,N-J)||STRING2;                       00131200
      RETURN STRING2;                                                           00131300
   END FORMAT;                                                                  00131400
