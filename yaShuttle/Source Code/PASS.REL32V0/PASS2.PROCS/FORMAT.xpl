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
/*          STRING            CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          X72                                                            */
/* CALLED BY:                                                              */
/*          DECODEPOP                                                      */
/*          EMITC                                                          */
/*          GENERATE                                                       */
/*          PRINTSUMMARY                                                   */
/***************************************************************************/
                                                                                00574000
 /*  SUBROUTINE FOR FORMATTING FIXED NUMBERS TO N-STRINGS  */                   00574500
FORMAT:                                                                         00575000
   PROCEDURE (IVAL,N) CHARACTER;                                                00575500
      DECLARE STRING CHARACTER, (IVAL,N) FIXED;                                 00576000
      STRING = IVAL;                                                            00576500
      IF LENGTH(STRING)>=N THEN RETURN STRING;                                  00577000
      RETURN SUBSTR(X72,0,N-LENGTH(STRING))||STRING;                            00577500
   END FORMAT;                                                                  00578000
