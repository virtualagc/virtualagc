 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATAU.xpl
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
/* PROCEDURE NAME:  FORMAT_AUXMAT                                          */
/* MEMBER NAME:     FORMATAU                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          AUXMAT#           BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_MAT1         FIXED                                        */
/*          MESSAGE           CHARACTER;                                   */
/*          TEMP_MAT2         FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          ASTERISK                                                       */
/*          AUXMAT                                                         */
/*          BLANK_COLON_BLANK                                              */
/*          CLOSE                                                          */
/*          COMMA                                                          */
/*          CURR_AUXMAT_BLOCK                                              */
/*          LEFT_PAREN                                                     */
/*          PERIOD                                                         */
/*          RIGHT_PAREN                                                    */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          #RJUST                                                         */
/*          HEX                                                            */
/* CALLED BY:                                                              */
/*          PRETTY_PRINT_MAT                                               */
/*          PASS2                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> FORMAT_AUXMAT <==                                                   */
/*     ==> #RJUST                                                          */
/*     ==> HEX                                                             */
/***************************************************************************/
                                                                                00998000
                                                                                01000000
 /* ROUTINE TO FORMAT AUXILIARY HALMAT PAIRS */                                 01002000
                                                                                01004000
FORMAT_AUXMAT:PROCEDURE(AUXMAT#) CHARACTER;                                     01006000
                                                                                01008000
      DECLARE AUXMAT# BIT(16);                                                  01010000
      DECLARE (TEMP_MAT1, TEMP_MAT2) FIXED, MESSAGE CHARACTER;                  01012000
                                                                                01014000
      TEMP_MAT1 = AUXMAT(AUXMAT# - 1);                                          01016000
      TEMP_MAT2 = AUXMAT(AUXMAT#);                                              01018000
      MESSAGE =                                                                 01020000
         #RJUST(CURR_AUXMAT_BLOCK, 3) ||                                        01022000
         PERIOD ||                                                              01024000
         #RJUST(AUXMAT# - 1, 4) ||                                              01026000
         BLANK_COLON_BLANK ||                                                   01028000
         #RJUST(SHR(TEMP_MAT1, 16) & "FFFF", 5) ||                              01030000
         COMMA ||                                                               01032000
         HEX(SHR(TEMP_MAT1, 1) & "F", 1) ||                                     01034000
         LEFT_PAREN ||                                                          01036000
         HEX(SHR(TEMP_MAT1, 5) & "3F", 2) ||                                    01038000
         RIGHT_PAREN ||                                                         01040000
         COMMA ||                                                               01042000
         #RJUST(SHR(TEMP_MAT2, 1) & "7FFF", 5) ||                               01044000
         COMMA ||                                                               01046000
         #RJUST(SHR(TEMP_MAT2, 16) & "7FFF", 5) ||                              01048000
         LEFT_PAREN ||                                                          01050000
         HEX(SHR(TEMP_MAT1, 11) & "1F", 2) ||                                   01052000
         RIGHT_PAREN;                                                           01054000
      IF (TEMP_MAT2 & "80000000") ^= 0 THEN                                     01056000
         MESSAGE = MESSAGE || ASTERISK;                                         01058000
      RETURN MESSAGE;                                                           01060000
                                                                                01062000
      CLOSE FORMAT_AUXMAT;                                                      01064000
