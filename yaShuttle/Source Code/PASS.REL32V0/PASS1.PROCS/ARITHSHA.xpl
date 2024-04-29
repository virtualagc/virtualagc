 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ARITHSHA.xpl
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
 /* PROCEDURE NAME:  ARITH_SHAPER_SUB                                       */
 /* MEMBER NAME:     ARITHSHA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          SIZE              FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DEF_SIZE          FIXED                                        */
 /*          TRY_VAL_SUB       LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INX                                                            */
 /*          CLASS_QS                                                       */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          VAL_P                                                          */
 /*          XIMD                                                           */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NEXT_SUB                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          MAKE_FIXED_LIT                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ARITH_SHAPER_SUB <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> MAKE_FIXED_LIT                                                  */
 /*         ==> GET_LITERAL                                                 */
 /***************************************************************************/
                                                                                00919900
ARITH_SHAPER_SUB:                                                               00920000
   PROCEDURE (SIZE) FIXED;                                                      00920100
      DECLARE (SIZE,DEF_SIZE) FIXED;                                            00920200
      DEF_SIZE=2;                                                               00920300
      NEXT_SUB=NEXT_SUB+1;                                                      00920400
      IF INX(NEXT_SUB)^=1 THEN DO;                                              00920500
         CALL ERROR(CLASS_QS,5);                                                00920600
         IF INX(NEXT_SUB)>1 THEN NEXT_SUB=NEXT_SUB+1;                           00920700
      END;                                                                      00920800
      ELSE IF VAL_P(NEXT_SUB)>0 THEN CALL ERROR(CLASS_QS,6);                    00920900
      ELSE IF PSEUDO_FORM(NEXT_SUB)=XIMD THEN DO;                               00921000
         DEF_SIZE=LOC_P(NEXT_SUB);                                              00921100
         GO TO TRY_VAL_SUB;                                                     00921200
      END;                                                                      00921300
      ELSE IF PSEUDO_FORM(NEXT_SUB)^=XLIT THEN CALL ERROR(CLASS_QS,7);          00921400
      ELSE DO;                                                                  00921500
         DEF_SIZE=MAKE_FIXED_LIT(LOC_P(NEXT_SUB));                              00921600
TRY_VAL_SUB:                                                                    00921700
         IF (DEF_SIZE<2)|(DEF_SIZE>SIZE) THEN DO;                               00921800
            CALL ERROR(CLASS_QS,8);                                             00921900
            IF DEF_SIZE<2 THEN RETURN 2;                                        00922000
            RETURN SIZE;                                                        00922100
         END;                                                                   00922200
      END;                                                                      00922300
      RETURN DEF_SIZE;                                                          00922400
   END ARITH_SHAPER_SUB;                                                        00922500
