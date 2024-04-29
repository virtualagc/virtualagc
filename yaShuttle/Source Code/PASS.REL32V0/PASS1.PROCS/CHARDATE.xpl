 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARDATE.xpl
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
 /* PROCEDURE NAME:  CHARDATE                                               */
 /* MEMBER NAME:     CHARDATE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          D                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DAY               FIXED                                        */
 /*          DAYS(12)          BIT(16)                                      */
 /*          M                 FIXED                                        */
 /*          MONTH(11)         CHARACTER;                                   */
 /*          YEAR              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X1                                                             */
 /* CALLED BY:                                                              */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
                                                                                00778900
CHARDATE:                                                                       00779000
   PROCEDURE(D) CHARACTER;                                                      00779100
      DECLARE (D, YEAR, DAY, M) FIXED;                                          00779200
      DECLARE MONTH(11) CHARACTER INITIAL('JANUARY', 'FEBRUARY', 'MARCH',       00779300
         'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER',                 00779400
         'OCTOBER', 'NOVEMBER', 'DECEMBER'),                                    00779500
         DAYS(12) BIT(16) INITIAL(0, 31, 60, 91, 121, 152, 182, 213, 244, 274,  00779600
         305, 335, 366);                                                        00779700
      YEAR = D / 1000 + 1900;                                                   00779800
      DAY = D MOD 1000;                                                         00779900
      IF (YEAR & "3") ^= 0 THEN                                                 00780000
         IF DAY > 59 THEN                                                       00780100
         DAY = DAY + 1;  /* NOT LEAP YEAR */                                    00780200
      M = 1;                                                                    00780300
      DO WHILE DAY > DAYS(M);                                                   00780400
         M = M + 1;                                                             00780500
      END;                                                                      00780600
      RETURN MONTH(M - 1) || X1 || DAY - DAYS(M - 1) || ', ' || YEAR;           00780700
   END CHARDATE;                                                                00780800
