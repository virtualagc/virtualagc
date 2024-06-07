 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   #RJUST.xpl
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
/* PROCEDURE NAME:  #RJUST                                                 */
/* MEMBER NAME:     #RJUST                                                 */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          NUMBER            BIT(16)                                      */
/*          TOTAL_LENGTH      BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          STRING            CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          BLANKS                                                         */
/* CALLED BY:                                                              */
/*          FORMAT_AUXMAT                                                  */
/*          FORMAT_HALMAT                                                  */
/*          OUTPUT_LIST                                                    */
/*          PASS1                                                          */
/***************************************************************************/
 /* ROUTINE TO RIGHT JUSTIFY DECIMAL NUMBERS IN A CHARACTER STRING */           00820000
                                                                                00822000
#RJUST:PROCEDURE(NUMBER, TOTAL_LENGTH) CHARACTER;                               00824000
                                                                                00826000
      DECLARE (NUMBER, TOTAL_LENGTH) BIT(16);                                   00828000
      DECLARE STRING CHARACTER;                                                 00830000
                                                                                00832000
      STRING = NUMBER;                                                          00834000
      IF LENGTH(STRING) >= TOTAL_LENGTH THEN RETURN STRING;                     00836000
      ELSE RETURN SUBSTR(BLANKS, 0, TOTAL_LENGTH - LENGTH(STRING)) || STRING;   00838000
                                                                                00840000
      CLOSE #RJUST;                                                             00842000
