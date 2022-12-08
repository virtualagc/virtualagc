 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAD.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
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
 /***************************************************************************/
                                                                                00637140
 /* ROUTINE TO PAD STRINGS WITH BLANKS TO A FIXED LENGTH */                     00637150
PAD:                                                                            00637160
   PROCEDURE(STRING, WIDTH) CHARACTER;                                          00637170
      DECLARE STRING CHARACTER, WIDTH FIXED;                                    00637180
      RETURN STRING || SUBSTR(X72, 72+LENGTH(STRING)-WIDTH);                    00637190
   END PAD;                                                                     00637200
