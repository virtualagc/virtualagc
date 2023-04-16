 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LEFTPAD.xpl
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
/* PROCEDURE NAME:  LEFT_PAD                                               */
/* MEMBER NAME:     LEFTPAD                                                */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          STRING            CHARACTER;                                   */
/*          WIDTH             FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          L                 FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          X72                                                            */
/* CALLED BY:                                                              */
/*          INITIALIZE                                                     */
/***************************************************************************/
                                                                                00128200
 /* SUBROUTINE TO PAD A CHARACTER STRING ON THE LEFT WITH BLANKS */             00128300
LEFT_PAD:                                                                       00128400
   PROCEDURE (STRING,WIDTH) CHARACTER;                                          00128500
      DECLARE STRING CHARACTER, (WIDTH,L) FIXED;                                00128600
      L = LENGTH(STRING);                                                       00128700
      IF L >= WIDTH THEN RETURN STRING;                                         00128800
      ELSE RETURN SUBSTR(X72,0,WIDTH-L)||STRING;                                00128900
   END LEFT_PAD;                                                                00129000
