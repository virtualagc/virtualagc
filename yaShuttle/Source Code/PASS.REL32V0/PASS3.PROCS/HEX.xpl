 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX.xpl
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
 /* PROCEDURE NAME:  HEX                                                    */
 /* MEMBER NAME:     HEX                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          HVAL              FIXED                                        */
 /*          N                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          STRING            CHARACTER;                                   */
 /*          H_LOOP            LABEL                                        */
 /*          ZEROS             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HEXCODES                                                       */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          BUILD_SDF                                                      */
 /*          INITIALIZE                                                     */
 /*          PAGE_DUMP                                                      */
 /***************************************************************************/
                                                                                00137464
 /* SUBROUTINE TO CONVERT INTEGER TO EXTERNAL HEX NOTATION  */                  00137500
HEX:                                                                            00137600
   PROCEDURE(HVAL, N) CHARACTER;                                                00137700
      DECLARE STRING CHARACTER, (HVAL, N) FIXED;                                00137800
      DECLARE ZEROS CHARACTER INITIAL('00000000');                              00137900
      STRING = '';                                                              00138000
H_LOOP:STRING = SUBSTR(HEXCODES, HVAL&"F", 1)|| STRING;                         00138100
      HVAL = SHR(HVAL, 4);                                                      00138200
      IF HVAL ^= 0 THEN GO TO H_LOOP;                                           00138300
      IF LENGTH(STRING) >= N THEN RETURN STRING;                                00138400
      RETURN SUBSTR(ZEROS, 0, N-LENGTH(STRING)) || STRING;                      00138500
   END HEX;                                                                     00138600
