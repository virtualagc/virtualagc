 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX.xpl
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
/*          DECODEPOP                                                      */
/*          EMITC                                                          */
/*          EMITW                                                          */
/*          GENERATE                                                       */
/*          HEX_LOCCTR                                                     */
/*          INITIALISE                                                     */
/*          PRINTSUMMARY                                                   */
/***************************************************************************/
                                                                                00578500
 /* SUBROUTINE TO CONVERT INTEGER TO EXTERNAL HEX NOTATION  */                  00579000
HEX:                                                                            00579500
   PROCEDURE(HVAL, N) CHARACTER;                                                00580000
      DECLARE (HVAL, N, K, B) FIXED, STRING CHARACTER INITIAL ('        ');     00580500
      K = 7;                                                                    00581000
      DO WHILE N > 0;                                                           00581500
         B = BYTE(HEXCODES, HVAL&"F");                                          00582000
         BYTE(STRING, K) = B;                                                   00582500
         K = K-1;                                                               00583000
         N = N-1;                                                               00583500
         HVAL = SHR(HVAL, 4);                                                   00584000
      END;                                                                      00584500
      RETURN SUBSTR(STRING, K+1);                                               00585000
   END HEX;                                                                     00585500
