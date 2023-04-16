 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARDATE.xpl
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
/* PROCEDURE NAME:  CHARDATE                                               */
/* MEMBER NAME:     CHARDATE                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          D                 FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          DAY               FIXED                                        */
/*          DAYS(12)          FIXED                                        */
/*          M                 FIXED                                        */
/*          MONTH(11)         CHARACTER;                                   */
/*          YEAR              FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          X1                                                             */
/* CALLED BY:                                                              */
/*          PRINT_DATE_AND_TIME                                            */
/*          INITIALIZE                                                     */
/***************************************************************************/
                                                                                00135900
CHARDATE:                                                                       00136000
   PROCEDURE (D) CHARACTER;                                                     00136100
      DECLARE (D,YEAR,DAY,M) FIXED;                                             00136200
      DECLARE MONTH(11) CHARACTER INITIAL('JANUARY','FEBRUARY','MARCH',         00136300
         'APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER',            00136400
         'NOVEMBER','DECEMBER'),                                                00136500
         DAYS(12) FIXED INITIAL(0,31,60,91,121,152,182,213,244,274,305,         00136600
         335,366);                                                              00136700
      YEAR=D/1000+1900;                                                         00136800
      DAY=D MOD 1000;                                                           00136900
      IF (YEAR&"3")^=0 THEN IF DAY>59 THEN DAY=DAY+1;                           00137000
      M=1;                                                                      00137100
      DO WHILE DAY>DAYS(M);                                                     00137200
         M=M+1;                                                                 00137300
      END;                                                                      00137400
      RETURN MONTH(M-1)||X1||DAY-DAYS(M-1)||', '||YEAR;                         00137500
   END CHARDATE;                                                                00137600
