 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTDAT.xpl
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
 /*          BLANK                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PRINT_TIME                                                     */
 /* CALLED BY:                                                              */
 /*          PRINTSUMMARY                                                   */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINT_DATE_AND_TIME <==                                             */
 /*     ==> PRINT_TIME                                                      */
 /***************************************************************************/
                                                                                00839000
 /* SUBROUTINE TO OUTPUT DATE AND TIME OF DAY   */                              00840000
PRINT_DATE_AND_TIME:                                                            00841000
   PROCEDURE (MESSAGE,D,T);                                                     00842000
      DECLARE MESSAGE CHARACTER,(D,T,YEAR,DAY,M) FIXED;                         00843000
      DECLARE MONTH(11) CHARACTER INITIAL('JANUARY','FEBRUARY','MARCH',         00844000
         'APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER',            00845000
         'NOVEMBER','DECEMBER'),                                                00846000
         DAYS(12) FIXED INITIAL(0,31,60,91,121,152,182,213,244,274,305,         00847000
         335,366);                                                              00848000
      YEAR=D/1000+1900;                                                         00849000
      DAY=D MOD 1000;                                                           00850000
      IF (YEAR&"3")^=0 THEN IF DAY>59 THEN DAY=DAY+1;                           00851000
      M=1;                                                                      00852000
      DO WHILE DAY>DAYS(M);                                                     00853000
         M=M+1;                                                                 00854000
      END;                                                                      00855000
      CALL PRINT_TIME(MESSAGE||MONTH(M-1)||BLANK||DAY-DAYS(M-1)||', '||         00856000
         YEAR||'.  CLOCK TIME = ',T);                                           00857000
   END PRINT_DATE_AND_TIME;                                                     00858000
