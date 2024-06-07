 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTDAT.xpl
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
/* PROCEDURE NAME:  PRINT_DATE_AND_TIME                                    */
/* MEMBER NAME:     PRINTDAT                                               */
/* INPUT PARAMETERS:                                                       */
/*          MESSAGE           CHARACTER;                                   */
/*          D                 FIXED                                        */
/*          T                 FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          DAY               FIXED                                        */
/*          DAYS(12)          FIXED                                        */
/*          M                 FIXED                                        */
/*          MONTH(11)         CHARACTER;                                   */
/*          YEAR              FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          BLANK                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PRINT_TIME                                                     */
/* CALLED BY:                                                              */
/*          PRINT_PHASE_HEADER                                             */
/*          PRINT_SUMMARY                                                  */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINT_DATE_AND_TIME <==                                             */
/*     ==> PRINT_TIME                                                      */
/***************************************************************************/
                                                                                01102000
                                                                                01104000
 /* SUBROUTINE TO OUTPUT DATE AND TIME OF DAY */                                01106000
                                                                                01108000
PRINT_DATE_AND_TIME:PROCEDURE(MESSAGE, D, T);                                   01110000
                                                                                01112000
      DECLARE MESSAGE CHARACTER, (D, T, YEAR, DAY, M) FIXED;                    01114000
      DECLARE MONTH(11) CHARACTER INITIAL(                                      01116000
         'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',                01118000
         'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER');     01120000
      DECLARE DAYS(12) FIXED INITIAL(                                           01122000
         0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);           01124000
                                                                                01126000
      YEAR = D / 1000 + 1900;                                                   01128000
      DAY = D MOD 1000;                                                         01130000
      IF (YEAR & "3") ^= 0 THEN IF DAY > 59 THEN DAY = DAY + 1;                 01132000
      M = 1;                                                                    01134000
      DO WHILE DAY > DAYS(M);                                                   01136000
         M = M + 1;                                                             01138000
      END;                                                                      01140000
      CALL PRINT_TIME(MESSAGE || MONTH(M - 1) || BLANK || DAY - DAYS(M - 1) ||  01142000
         ', ' || YEAR || '.  CLOCK TIME = ', T);                                01144000
                                                                                01146000
      CLOSE PRINT_DATE_AND_TIME;                                                01148000
