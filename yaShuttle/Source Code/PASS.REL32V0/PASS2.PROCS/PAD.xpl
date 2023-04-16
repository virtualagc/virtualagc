 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAD.xpl
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
/* PROCEDURE NAME:  PAD                                                    */
/* MEMBER NAME:     PAD                                                    */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          STRING            CHARACTER;                                   */
/*          WIDTH             FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          X72                                                            */
/* CALLED BY:                                                              */
/*          ENTER_ESD                                                      */
/*          INSTRUCTION                                                    */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
                                                                                00586000
 /* ROUTINE TO PAD STRINGS WITH BLANKS TO A FIXED LENGTH */                     00586500
PAD:                                                                            00587000
   PROCEDURE(STRING, WIDTH) CHARACTER;                                          00587500
      DECLARE STRING CHARACTER, WIDTH FIXED;                                    00588000
      RETURN STRING || SUBSTR(X72, 72+LENGTH(STRING)-WIDTH);                    00588500
   END PAD;                                                                     00589000
