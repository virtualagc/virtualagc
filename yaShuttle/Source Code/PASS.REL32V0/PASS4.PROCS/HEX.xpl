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
/*          PAGE_DUMP                                                      */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00131500
 /* SUBROUTINE TO CONVERT INTEGER TO EXTERNAL HEX NOTATION  */                  00131600
HEX:                                                                            00131700
   PROCEDURE(HVAL, N) CHARACTER;                                                00131800
      DECLARE STRING CHARACTER, (HVAL, N) FIXED;                                00131900
      DECLARE ZEROS CHARACTER INITIAL('00000000');                              00132000
      STRING = '';                                                              00132100
H_LOOP:STRING = SUBSTR(HEXCODES, HVAL&"F", 1)|| STRING;                         00132200
      HVAL = SHR(HVAL, 4);                                                      00132300
      IF HVAL ^= 0 THEN GO TO H_LOOP;                                           00132400
      IF LENGTH(STRING) >= N THEN RETURN STRING;                                00132500
      RETURN SUBSTR(ZEROS, 0, N-LENGTH(STRING)) || STRING;                      00132600
   END HEX;                                                                     00132700
