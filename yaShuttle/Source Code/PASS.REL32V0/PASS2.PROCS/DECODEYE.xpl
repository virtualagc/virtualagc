 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECODEYE.xpl
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
 /* PROCEDURE NAME:  DECODE_YEAR_DAY_AND_MONTH                              */
 /* MEMBER NAME:     DECODEYE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*       FIXED                                                             */
 /* INPUT PARAMETERS:                                                       */
 /*       DATE_VALUE        FIXED                                           */
 /* LOCAL DECLARATIONS:                                                     */
 /*       DAY               BIT(16)                                         */
 /*       DAYS(12)          BIT(16)                                         */
 /*       MONTH             BIT(16)                                         */
 /*       YEAR              BIT(16)                                         */
 /* CALLED BY:                                                              */
 /*                                                                         */
 /*       OBJECT_GENERATOR                                                  */
 /*       PRINT_DATE_AND_TIME                                               */
 /***************************************************************************/
 /*     REVISION HISTORY                                                    */
 /*                                                                         */
 /*  DATE    NAME  RLS   CR/DR #   DESCRIPTION                              */
 /*                                                                         */
 /* 02/18/92 ADM    7V0  CR11114   MERGE BFS/PASS COMPILERS                 */
 /*                                                                         */
 /***************************************************************************/
                                                                                00838025
   /* SUBROUTINE TO DECODE DATE TO YEAR || DATE || MONTH */                     00838050
DECODE_YEAR_DAY_AND_MONTH:                                                      00838075
   PROCEDURE(DATE_VALUE) FIXED;                                                 00838100
      DECLARE DATE_VALUE FIXED, (YEAR, DAY, MONTH) BIT(16),                     00838125
         DAYS(12) BIT(16)                                                       00838150
            INITIAL(0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);00838175
      YEAR = DATE_VALUE / 1000;                                                 00838200
      DAY = DATE_VALUE MOD 1000;                                                00838225
      IF (YEAR & "3") ^= 0 THEN                                                 00838250
         IF DAY > 59 THEN                                                       00838275
            DAY = DAY + 1;                                                      00838300
      MONTH = 1;                                                                00838325
      DO WHILE DAY > DAYS(MONTH);                                               00838350
         MONTH = MONTH + 1;                                                     00838375
      END;                                                                      00838400
      RETURN SHL(YEAR, 16) | SHL(DAY - DAYS(MONTH - 1), 8) | MONTH;             00838425
   END DECODE_YEAR_DAY_AND_MONTH;                                               00838450
