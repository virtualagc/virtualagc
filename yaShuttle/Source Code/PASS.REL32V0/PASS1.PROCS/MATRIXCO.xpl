 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MATRIXCO.xpl
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
 /* PROCEDURE NAME:  MATRIX_COMPARE                                         */
 /* MEMBER NAME:     MATRIXCO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          MATCH_ARITH                                                    */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MATRIX_COMPARE <==                                                  */
 /*     ==> VECTOR_COMPARE                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /***************************************************************************/
                                                                                00819100
MATRIX_COMPARE:                                                                 00819200
   PROCEDURE(I,J,CLASS,NUM);                                                    00819300
      DECLARE (I,J,CLASS,NUM) BIT(16);                                          00819400
      CALL VECTOR_COMPARE(I,J,CLASS,NUM);                                       00819500
   END MATRIX_COMPARE;                                                          00819600
