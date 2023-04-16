 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LITDUMP.xpl
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
 /* PROCEDURE NAME:  LIT_DUMP                                               */
 /* MEMBER NAME:     LITDUMP                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          S                 CHARACTER;                                   */
 /*          T                 CHARACTER;                                   */
 /*          TEMP              FIXED                                        */
 /*          ZEROS             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          LIT_PG                                                         */
 /*          LIT_TOP                                                        */
 /*          LITERAL1                                                       */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT1                                                           */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /*          HEX                                                            */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> LIT_DUMP <==                                                        */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> HEX                                                             */
 /*     ==> I_FORMAT                                                        */
 /***************************************************************************/
 /***************************************************************************/
 /* REVISION HISTORY                                                        */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/15/98 DCP  29V0/ DR109083 CONSTANT DOUBLE SCALAR CONVERTED TO        */
 /*               14V0           CHARACTER AS SINGLE PRECISION              */
 /***************************************************************************/
                                                                                00662100
                                                                                00662200
LIT_DUMP:                                                                       00663800
   PROCEDURE;                                                                   00663900
      DECLARE TEMP FIXED;                                                       00664000
      DECLARE S CHARACTER, T CHARACTER INITIAL('  CHAR   ARITH    BIT    '),    00664100
         ZEROS CHARACTER INITIAL ('00000000');                                  00664200
      IF LIT_TOP = 0 THEN RETURN;                                               00664300
      OUTPUT(1) = '0L I T E R A L   T A B L E   D U M P:';                      00664400
      OUTPUT(1)='0 LOC  TYPE          LITERAL';                                 00664500
      OUTPUT = X1;                                                              00664600
      DO I = 1 TO LIT_TOP;                                                      00664700
         TEMP = GET_LITERAL(I);                                                 00664800
         DO CASE (LIT1(TEMP) & "3");                         /*DR109083*/       00664900
 /* CHARACTER */                                                                00665000
            DO;                                                                 00665100
               S=STRING(LIT2(TEMP));                                            00665200
               IF LENGTH(S)>100 THEN S=SUBSTR(S,0,100);                         00665300
            END;                                                                00665400
 /* ARITHMETIC */                                                               00665500
            DO;                                                                 00665600
               S=HEX(LIT3(TEMP));                                               00665700
               IF LENGTH(S)<8 THEN S=SUBSTR(ZEROS,LENGTH(S))||S;                00665800
               S=HEX(LIT2(TEMP))||S;                                            00665900
               IF LENGTH(S)<16 THEN S=SUBSTR(ZEROS,LENGTH(S)-8)||S;             00666000
            END;                                                                00666100
 /* BIT */                                                                      00666200
            DO;                                                                 00666300
               S=HEX(LIT2(TEMP));                                               00666400
               IF LENGTH(S)<8 THEN S=SUBSTR(ZEROS,LENGTH(S))||S;                00666500
               S=S||' ('||LIT3(TEMP)||')';                                      00666600
            END;                                                                00666700
         END;                                                                   00666800
         OUTPUT=I_FORMAT(I,4)||SUBSTR(T,SHL(LIT1(TEMP),3),8)||S;                00666900
      END;                                                                      00667000
      DOUBLE_SPACE;                                                             00667100
   END LIT_DUMP;                                                                00667200
