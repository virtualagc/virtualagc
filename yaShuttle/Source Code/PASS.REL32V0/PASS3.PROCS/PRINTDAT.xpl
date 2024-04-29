 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTDAT.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
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
 /*          X1                                                             */
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
                                                                                00141900
 /* SUBROUTINE TO OUTPUT DATE AND TIME OF DAY   */                              00142000
PRINT_DATE_AND_TIME:                                                            00142100
   PROCEDURE (MESSAGE,D,T);                                                     00142200
      DECLARE MESSAGE CHARACTER,(D,T,YEAR,DAY,M) FIXED;                         00142300
      DECLARE MONTH(11) CHARACTER INITIAL('JANUARY','FEBRUARY','MARCH',         00142400
         'APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER',            00142500
         'NOVEMBER','DECEMBER'),                                                00142600
         DAYS(12) FIXED INITIAL(0,31,60,91,121,152,182,213,244,274,305,         00142700
         335,366);                                                              00142800
      YEAR=D/1000+1900;                                                         00142900
      DAY=D MOD 1000;                                                           00143000
      IF (YEAR&"3")^=0 THEN IF DAY>59 THEN DAY=DAY+1;                           00143100
      M=1;                                                                      00143200
      DO WHILE DAY>DAYS(M);                                                     00143300
         M=M+1;                                                                 00143400
      END;                                                                      00143500
      CALL PRINT_TIME(MESSAGE||MONTH(M-1)||X1||DAY-DAYS(M-1)||', '||            00143600
         YEAR||'.  CLOCK TIME = ',T);                                           00143700
   END PRINT_DATE_AND_TIME;                                                     00143800
