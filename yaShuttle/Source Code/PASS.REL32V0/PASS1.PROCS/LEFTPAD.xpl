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
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          OUTPUT_WRITER                                                  */
 /*          INITIALIZATION                                                 */
 /*          SOURCE_COMPARE                                                 */
 /***************************************************************************/
                                                                                00268500
                                                                                00268600
                                                                                00269500
LEFT_PAD:                                                                       00269600
   PROCEDURE(STRING, WIDTH) CHARACTER;                                          00269700
      DECLARE STRING CHARACTER, (WIDTH, L) FIXED;                               00269800
      L = LENGTH(STRING);                                                       00269900
      IF L >= WIDTH THEN RETURN STRING;                                         00270000
      ELSE RETURN SUBSTR(X256, 0, WIDTH - L) || STRING;                         00270100
   END LEFT_PAD;                                                                00270200
