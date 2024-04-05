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
/*                                                                         */
/* REVISION HISTORY:                                                       */
/*                                                                         */
/* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
/*                                                                         */
/* 06/27/91 ADM  7V0   CR11114  MERGE PASS/BFS COMPILERS WITH DR FIXES     */
/*                                                                         */
/* 04/08/98 DCP  29V0/ CR12975  HAL/S-FC COMPILER YR2K LISTING UPDATE      */
/*               14V0                                                      */
/***************************************************************************/
                                                                                00838500
 /* SUBROUTINE TO OUTPUT DATE AND TIME OF DAY   */                              00839000
PRINT_DATE_AND_TIME:                                                            00839500
   PROCEDURE (MESSAGE,D,T);                                                     00840000
      /* THE BFS SPECIFIC CODE WAS REMOVED AND THE CODE THAT  /*CR12975*/
      /* WAS PASS SPECIFIC WILL NOW BE USED BY BOTH SYSTEMS.  /*CR12975*/
      DECLARE MESSAGE CHARACTER,(D,T,YEAR,DAY,M) FIXED;                         00840500
      DECLARE MONTH(11) CHARACTER INITIAL('JANUARY','FEBRUARY','MARCH',         00841000
         'APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER',            00841500
         'NOVEMBER','DECEMBER'),                                                00842000
         DAYS(12) FIXED INITIAL(0,31,60,91,121,152,182,213,244,274,305,         00842500
         335,366);                                                              00843000
      YEAR=D/1000+1900;                                                         00843500
      DAY=D MOD 1000;                                                           00844000
      IF (YEAR&"3")^=0 THEN IF DAY>59 THEN DAY=DAY+1;                           00844500
      M=1;                                                                      00845000
      DO WHILE DAY>DAYS(M);                                                     00845500
         M=M+1;                                                                 00846000
      END;                                                                      00846500
      CALL PRINT_TIME(MESSAGE||MONTH(M-1)||BLANK||DAY-DAYS(M-1)||', '||         00847000
         YEAR||'.  CLOCK TIME = ',T);                                           00847500
   END PRINT_DATE_AND_TIME;                                                     00848000
