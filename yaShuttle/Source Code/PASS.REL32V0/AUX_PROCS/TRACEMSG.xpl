 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TRACEMSG.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  TRACE_MSG                                              */
/* MEMBER NAME:     TRACEMSG                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          MSG               CHARACTER;                                   */
/*          HALMAT#           BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          HALMAT_BLOCK      BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BLANK                                                          */
/*          CLOSE                                                          */
/*          COMMA                                                          */
/*          CURR_HALMAT_BLOCK                                              */
/*          HALMAT_PTR                                                     */
/*          LEFT_PAREN                                                     */
/*          RIGHT_PAREN                                                    */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                01718000
                                                                                01720000
 /* ROUTINE TO OUTPUT A MESSAGE AND HALMAT LINE INDICATOR */                    01722000
                                                                                01724000
TRACE_MSG:FUNCTION(MSG, HALMAT#) CHARACTER;                                     01726000
                                                                                01728000
   DECLARE                                                                      01730000
      MSG                            CHARACTER,                                 01732000
      HALMAT#                        BIT(16),                                   01734000
      HALMAT_BLOCK                   BIT(16);                                   01736000
                                                                                01738000
   HALMAT_BLOCK = CURR_HALMAT_BLOCK - 1;                                        01740000
   IF (HALMAT_PTR >= 1800) & (HALMAT# < 1800) THEN                              01742000
      HALMAT_BLOCK = HALMAT_BLOCK - 1;                                          01744000
                                                                                01746000
   RETURN                                                                       01748000
      MSG ||                                                                    01750000
      BLANK ||                                                                  01752000
      LEFT_PAREN ||                                                             01754000
      HALMAT_BLOCK ||                                                           01756000
      COMMA ||                                                                  01758000
      HALMAT# ||                                                                01760000
      RIGHT_PAREN;                                                              01762000
                                                                                01764000
   CLOSE TRACE_MSG;                                                             01766000
