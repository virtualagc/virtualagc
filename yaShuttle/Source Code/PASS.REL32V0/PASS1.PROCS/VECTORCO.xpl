 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VECTORCO.xpl
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
 /* PROCEDURE NAME:  VECTOR_COMPARE                                         */
 /* MEMBER NAME:     VECTORCO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR                                                            */
 /*          PSEUDO_LENGTH                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          MATCH_ARITH                                                    */
 /*          MATRIX_COMPARE                                                 */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> VECTOR_COMPARE <==                                                  */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00818400
VECTOR_COMPARE:                                                                 00818500
   PROCEDURE(I,J,CLASS,NUM);                                                    00818600
      DECLARE (I,J,CLASS,NUM) BIT(16);                                          00818700
      IF PSEUDO_LENGTH(PTR(I))^=PSEUDO_LENGTH(PTR(J)) THEN                      00818800
         CALL ERROR(CLASS,NUM);                                                 00818900
   END VECTOR_COMPARE;                                                          00819000
