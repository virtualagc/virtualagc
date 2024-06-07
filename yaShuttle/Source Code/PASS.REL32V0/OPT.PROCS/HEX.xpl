 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
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
 /*          B                 FIXED                                        */
 /*          K                 FIXED                                        */
 /*          STRING            CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HEXCODES                                                       */
 /* CALLED BY:                                                              */
 /*          COMBINED_LITERALS                                              */
 /*          COMPARE_LITERALS                                               */
 /*          CSE_TAB_DUMP                                                   */
 /*          CSE_WORD_FORMAT                                                */
 /*          DECODEPOP                                                      */
 /*          EXTRACT_VAR                                                    */
 /*          FORM_OPERATOR                                                  */
 /*          INT_TO_SCALAR                                                  */
 /*          MESSAGE_FORMAT                                                 */
 /*          OPTIMISE                                                       */
 /*          PRINT_SENTENCE                                                 */
 /*          PUSH_HALMAT                                                    */
 /*          RELOCATE_HALMAT                                                */
 /*          SET_NONCOMMUTATIVE                                             */
 /*          STACK_DUMP                                                     */
 /*          VU                                                             */
 /***************************************************************************/
                                                                                00501000
 /* SUBROUTINE TO CONVERT INTEGER TO EXTERNAL HEX NOTATION  */                  00502000
HEX:                                                                            00503000
   PROCEDURE(HVAL, N) CHARACTER;                                                00504000
      DECLARE (HVAL, N, K, B) FIXED, STRING CHARACTER INITIAL ('        ');     00505000
      K = 7;                                                                    00506000
      DO WHILE N > 0;                                                           00507000
         B = BYTE(HEXCODES, HVAL&"F");                                          00508000
         BYTE(STRING, K) = B;                                                   00509000
         K = K-1;                                                               00510000
         N = N-1;                                                               00511000
         HVAL = SHR(HVAL, 4);                                                   00512000
      END;                                                                      00513000
      RETURN SUBSTR(STRING, K+1);                                               00514000
   END HEX;                                                                     00515000
