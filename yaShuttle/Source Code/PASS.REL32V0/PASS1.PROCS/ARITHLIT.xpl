 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ARITHLIT.xpl
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
 /* PROCEDURE NAME:  ARITH_LITERAL                                          */
 /* MEMBER NAME:     ARITHLIT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /*          FALSE                                                          */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          TRUE                                                           */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /*          LIT_PTR                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          END_ANY_FCN                                                    */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          PREC_SCALE                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ARITH_LITERAL <==                                                   */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
 /***************************************************************************/
 /* REVISION HISTORY                                                        */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/15/98 DCP  29V0/ DR109083 CONSTANT DOUBLE SCALAR CONVERTED TO        */
 /*               14V0           CHARACTER AS SINGLE PRECISION              */
 /*                                                                         */
 /* 03/03/98 DCP  29V0/ DR109052 ARITHMETIC EXPRESSION IN CONSTANT/         */
 /*               14V0           INITIAL VALUE GETS ERROR                   */
 /*                                                                         */
 /* 01/23/01 DCP  31V0/ CR13336  DON'T ALLOW ARITHMETIC EXPRESSIONS         */
 /*               16V0           IN CHARACTER INITIAL CLAUSES               */
 /***************************************************************************/
                                                                                00843500
ARITH_LITERAL:                                                                  00843600
   PROCEDURE (LOC1,LOC2,PWR_MODE) BIT(1);                      /*MOD-DR109083*/ 00843700
      DECLARE (LOC1,LOC2) BIT(16), PWR_MODE BIT(1);                /*DR109083*/ 00843800
      IF PSEUDO_FORM(PTR(LOC1))^=XLIT THEN RETURN FALSE;                        00843900
      LIT_PTR=GET_LITERAL(LOC_P(PTR(LOC1)));                                    00844000
      /* IF EITHER LITERAL IS A DOUBLE THEN SET DOUBLELIT = TRUE   /*DR109083*/
      /* SO THE COMPILER WILL KNOW TO CHANGE LIT1 (OF THE RESULT)  /*DR109083*/
      /* TO 5 LATER ON.  THE EXCEPTION IS WHEN THE CALCULATION IS  /*DR109083*/
      /* AN EXPONENTIAL (PWR_MODE=TRUE).  IN THIS CASE, IF THE     /*DR109083*/
      /* EXPONENT IS AN INTEGER THEN THE BASE DETERMINES THE       /*DR109083*/
      /* PRECISION.  BUT IF THE EXPONENT IS A SCALAR THEN EITHER   /*DR109083*/
      /* MAY DETERMINE THE PRECISION.                              /*DR109083*/
      IF ((TYPE=0)&(FACTORED_TYPE=0)) & (LIT1(LIT_PTR)=5) THEN /*13336 & """ */
        DOUBLELIT = TRUE;                                          /*DR109083*/
      DW(0)=LIT2(LIT_PTR);                                                      00844100
      DW(1)=LIT3(LIT_PTR);                                                      00844200
      IF LOC2=0 THEN RETURN TRUE;                                               00844300
      IF PSEUDO_FORM(PTR(LOC2))^=XLIT THEN RETURN FALSE;                        00844400
      LIT_PTR=GET_LITERAL(LOC_P(PTR(LOC2)));                                    00844500
      IF ((TYPE=0)&(FACTORED_TYPE=0)) & (LIT1(LIT_PTR)=5) THEN /*13336 & """ */
        IF (PWR_MODE & (PSEUDO_TYPE(PTR(SP))^=INT_TYPE)) | ^PWR_MODE THEN /*"*/
          DOUBLELIT = TRUE;                                        /*DR109083*/
      DW(2)=LIT2(LIT_PTR);                                                      00844600
      DW(3)=LIT3(LIT_PTR);                                                      00844700
      PWR_MODE = FALSE;                                            /*DR109083*/
      RETURN TRUE;                                                              00844800
   END ARITH_LITERAL;                                                           00844900
