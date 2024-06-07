 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
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
/*          NUMBER            BIT(16)                                      */
/*          TOTAL_LENGTH      BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          B                 BIT(16)                                      */
/*          HEXCODES          CHARACTER;                                   */
/*          K                 BIT(16)                                      */
/*          STRING            CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          BLANK                                                          */
/* CALLED BY:                                                              */
/*          FORMAT_AUXMAT                                                  */
/*          FORMAT_HALMAT                                                  */
/*          OUTPUT_LIST                                                    */
/*          OUTPUT_SYT_MAP                                                 */
/*          OUTPUT_VAC_MAP                                                 */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                00844000
                                                                                00846000
 /* ROUTINE TO RIGHT JUSTIFY HEXADECIMAL NUMBERS IN A CHARACTER STRING */       00848000
                                                                                00850000
HEX:PROCEDURE(NUMBER, TOTAL_LENGTH) CHARACTER;                                  00852000
                                                                                00854000
      DECLARE (NUMBER, TOTAL_LENGTH) BIT(16);                                   00856000
      DECLARE STRING CHARACTER, (K, B) BIT(16);                                 00858000
      DECLARE HEXCODES CHARACTER INITIAL('0123456789ABCDEF');                   00860000
                                                                                00862000
      STRING = SUBSTR(BLANK || '0000', 1);                                      00864000
      K = 3;                                                                    00866000
      DO WHILE NUMBER > 0;                                                      00868000
         B = BYTE(HEXCODES, NUMBER & "F");                                      00870000
         BYTE(STRING, K) = B;                                                   00872000
         K = K - 1;                                                             00874000
         NUMBER = SHR(NUMBER, 4);                                               00876000
      END;                                                                      00878000
      RETURN SUBSTR(STRING, 4 - TOTAL_LENGTH);                                  00880000
                                                                                00882000
      CLOSE HEX;                                                                00884000
