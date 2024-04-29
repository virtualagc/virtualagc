 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAD.xpl
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
 /* PROCEDURE NAME:  PAD                                                    */
 /* MEMBER NAME:     PAD                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          STRING            CHARACTER;                                   */
 /*          MAX               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X72                                                            */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
                                                                                00150700
 /* SUBROUTINE FOR FORCING A CHARACTER STRING TO A SPECIFIED LENGTH */          00150800
                                                                                00150900
PAD:                                                                            00151000
   PROCEDURE (STRING,MAX) CHARACTER;                                            00151100
      DECLARE (STRING) CHARACTER, (MAX,L) BIT(16);                              00151200
      L = LENGTH(STRING);                                                       00151300
      IF L < MAX THEN STRING = STRING || SUBSTR(X72,0,MAX-L);                   00151400
      ELSE IF L > MAX THEN STRING = SUBSTR(STRING,0,MAX);                       00151500
      RETURN STRING;                                                            00151600
   END PAD;                                                                     00151700
