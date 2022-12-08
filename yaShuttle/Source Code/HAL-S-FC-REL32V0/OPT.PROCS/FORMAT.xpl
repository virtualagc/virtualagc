 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMAT.xpl
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
 /*          C_STACK_DUMP                                                   */
 /*          CHECK_LIST                                                     */
 /*          CSE_TAB_DUMP                                                   */
 /*          DECODEPIP                                                      */
 /*          DECODEPOP                                                      */
 /*          DUMP_VALIDS                                                    */
 /*          PRINT_SENTENCE                                                 */
 /*          STACK_DUMP                                                     */
 /***************************************************************************/
 /*  SUBROUTINE FOR FORMATTING FIXED NUMBERS TO N-STRINGS  */                   00493000
FORMAT:                                                                         00494000
   PROCEDURE (IVAL,N) CHARACTER;                                                00495000
      DECLARE STRING CHARACTER, (IVAL,N) FIXED;                                 00496000
      STRING = IVAL;                                                            00497000
      IF LENGTH(STRING)>=N THEN RETURN STRING;                                  00498000
      RETURN SUBSTR(X72,0,N-LENGTH(STRING))||STRING;                            00499000
   END FORMAT;                                                                  00500000
