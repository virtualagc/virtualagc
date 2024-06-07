 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPAREL.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  COMPARE_LITERALS                                       */
 /* MEMBER NAME:     COMPAREL                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR1              BIT(16)                                      */
 /*          PTR2              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LPTR1             BIT(16)                                      */
 /*          LPTR2             BIT(16)                                      */
 /*          T1                FIXED                                        */
 /*          T2                FIXED                                        */
 /*          T3                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          LIT_PG                                                         */
 /*          LITERAL1                                                       */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT1                                                           */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          TRUE                                                           */
 /*          WATCH                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          CSE_MATCH_FOUND                                                */
 /*          FLAG_VAC_OR_LIT                                                */
 /*          STRIP_NODES                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMPARE_LITERALS <==                                                */
 /*     ==> HEX                                                             */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                00694000
 /* COMPARE TWO LITERALS, RETURN EQUAL/NOT EQUAL */                             00695000
COMPARE_LITERALS:                                                               00696000
   PROCEDURE(PTR1,PTR2) BIT(8);                                                 00697000
      DECLARE (PTR1,PTR2,LPTR1,LPTR2) BIT(16);                                  00698000
      DECLARE T1 FIXED;                                                         00698010
      DECLARE (T2,T3) FIXED;                                                    00699000
      IF PTR1 = PTR2 THEN RETURN TRUE;                                          00701000
      LPTR1=GET_LITERAL(PTR1);                                                  00702000
      T1 = LIT1(LPTR1);                                                         00702010
      T2 = LIT2(LPTR1);                                                         00703000
      T3 = LIT3(LPTR1);                                                         00704000
      LPTR2=GET_LITERAL(PTR2);                                                  00705000
      IF WATCH THEN DO;                                                         00706000
         OUTPUT = 'COMPARE_LITERALS(' || PTR1 || ',' || PTR2 || ')';            00707000
         OUTPUT = '   '||HEX(T2,8) || HEX(T3,8);                                00708000
         OUTPUT = '   ' || HEX(LIT2(LPTR2),8) || HEX(LIT3(LPTR2),8);            00709000
      END;                                                                      00710000
      IF T2=LIT2(LPTR2) THEN DO;                                                00711000
         IF T1 = LIT1(LPTR2) THEN                                               00711010
            IF T3=LIT3(LPTR2) THEN RETURN TRUE;                                 00712000
      END;                                                                      00713000
      RETURN FALSE;                                                             00714000
   END COMPARE_LITERALS;                                                        00715000
