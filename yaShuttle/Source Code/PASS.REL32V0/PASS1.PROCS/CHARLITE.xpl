 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARLITE.xpl
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
 /* PROCEDURE NAME:  CHAR_LITERAL                                           */
 /* MEMBER NAME:     CHARLITE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LIT2                                                           */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          TRUE                                                           */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHAR_LITERAL <==                                                    */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*                         DR/CR                                           */
 /*  DATE     NAME  REL     NUMBER    TITLE                                 */
 /*                                                                         */
 /*  01/25/01 DCP   31V0/   CR13336   DON'T ALLOW ARITHMETIC EXPRESSIONS    */
 /*                 16V0              IN CHARACTER INITIAL CLAUSES          */
 /*                                                                         */
 /***************************************************************************/
                                                                                00846100
CHAR_LITERAL:                                                                   00846200
   PROCEDURE (LOC1,LOC2) BIT(1);                                                00846300
      DECLARE (LOC1,LOC2) BIT(16);                                              00846400
      IF PSEUDO_FORM(PTR(LOC1))^=XLIT THEN RETURN FALSE;                        00846500
      IF LOC_P(PTR(LOC1))=0 THEN VAR(LOC1)='';                                  00846600
      ELSE IF LIT1(GET_LITERAL(LOC_P(PTR(LOC1)))) = 0 THEN        /*CR13336*/
        VAR(LOC1)=STRING(LIT2(GET_LITERAL(LOC_P(PTR(LOC1)))));                  00846700
      IF LOC2=0 THEN RETURN TRUE;                                               00846800
      IF PSEUDO_FORM(PTR(LOC2))^=XLIT THEN RETURN FALSE;                        00846900
      IF LOC_P(PTR(LOC2))=0 THEN VAR(LOC2)='';                                  00847000
      ELSE IF LIT1(GET_LITERAL(LOC_P(PTR(LOC2)))) = 0 THEN        /*CR13336*/
        VAR(LOC2)=STRING(LIT2(GET_LITERAL(LOC_P(PTR(LOC2)))));                  00847100
      RETURN TRUE;                                                              00847200
   END CHAR_LITERAL;                                                            00847300
