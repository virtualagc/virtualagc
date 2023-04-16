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
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          DESCORE                                                        */
 /*          EMIT_EXTERNAL                                                  */
 /*          ERROR                                                          */
 /*          INITIALIZATION                                                 */
 /*          SAVE_INPUT                                                     */
 /*          STREAM                                                         */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
                                                                                00261583
PAD:                                                                            00261584
   PROCEDURE (STRING, WIDTH) CHARACTER;                                         00261585
      DECLARE STRING CHARACTER, (WIDTH, L) FIXED;                               00261586
                                                                                00261587
      L = LENGTH(STRING);                                                       00261588
      IF L >= WIDTH THEN RETURN STRING;                                         00261589
      ELSE RETURN STRING || SUBSTR(X256, 0, WIDTH - L);                         00261590
   END PAD;                                                                     00261591
