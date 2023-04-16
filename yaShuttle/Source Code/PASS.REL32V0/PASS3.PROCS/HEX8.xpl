 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX8.xpl
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
 /* PROCEDURE NAME:  HEX8                                                   */
 /* MEMBER NAME:     HEX8                                                   */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          HVAL              FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          T                 CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HEXCODES                                                       */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          INITIALIZE                                                     */
 /*          PAGE_DUMP                                                      */
 /*          P3_PTR_LOCATE                                                  */
 /***************************************************************************/
                                                                                00138700
 /* SUBROUTINE TO CONVERT AN INTEGER INTO 8 HEX DIGITS */                       00138800
HEX8:                                                                           00138900
   PROCEDURE (HVAL) CHARACTER;                                                  00139000
      DECLARE (HVAL, I) FIXED, T CHARACTER;                                     00139100
      T = '';                                                                   00139200
      DO I = 0 TO 7;                                                            00139300
         T = T || SUBSTR(HEXCODES, SHR(HVAL, SHL(7-I,2))&"F", 1);               00139400
      END;                                                                      00139500
      RETURN T;                                                                 00139600
   END HEX8;                                                                    00139700
