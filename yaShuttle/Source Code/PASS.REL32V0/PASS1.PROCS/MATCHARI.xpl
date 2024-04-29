 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MATCHARI.xpl
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
 /* PROCEDURE NAME:  MATCH_ARITH                                            */
 /* MEMBER NAME:     MATCHARI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ARITH_VALID(3)    BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_E                                                        */
 /*          CLASS_EM                                                       */
 /*          CLASS_EV                                                       */
 /*          MAT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          MATCH_SIMPLES                                                  */
 /*          MATRIX_COMPARE                                                 */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MATCH_ARITH <==                                                     */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> VECTOR_COMPARE                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> MATRIX_COMPARE                                                  */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*     ==> MATCH_SIMPLES                                                   */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> SETUP_VAC                                                   */
 /***************************************************************************/
                                                                                00847400
MATCH_ARITH:                                                                    00847500
   PROCEDURE (LOC1,LOC2);                                                       00847600
      DECLARE (LOC1,LOC2) BIT(16);                                              00847700
      DECLARE ARITH_VALID(3) BIT(8) INITIAL(                                    00847800
         "(1) 0001 ",                                                           00847900
         "(1) 0010 ",                                                           00848000
         "(1) 1100 ",                                                           00848100
         "(1) 1100 ");                                                          00848200
      DECLARE I BIT(16);                                                        00848300
      I=PSEUDO_TYPE(PTR(LOC1))-MAT_TYPE;                                        00848400
      IF (SHL(1,PSEUDO_TYPE(PTR(LOC2))-MAT_TYPE)&ARITH_VALID(I))=0 THEN         00848500
         CALL ERROR(CLASS_E,6);                                                 00848600
      ELSE DO CASE I;                                                           00848700
         CALL MATRIX_COMPARE(LOC1,LOC2,CLASS_EM,1);                             00848800
         CALL VECTOR_COMPARE(LOC1,LOC2,CLASS_EV,1);                             00848900
         CALL MATCH_SIMPLES(LOC1,LOC2);                                         00849000
         CALL MATCH_SIMPLES(LOC1,LOC2);                                         00849100
      END;                                                                      00849200
   END MATCH_ARITH;                                                             00849300
