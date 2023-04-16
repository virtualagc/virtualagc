 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ADDANDSU.xpl
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
 /* PROCEDURE NAME:  ADD_AND_SUBTRACT                                       */
 /* MEMBER NAME:     ADDANDSU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          AS_FAIL(1613)     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DW_AD                                                          */
 /*          CLASS_VA                                                       */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SP                                                             */
 /*          XMADD                                                          */
 /*          XMSUB                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR_TOP                                                        */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARITH_LITERAL                                                  */
 /*          ERROR                                                          */
 /*          HALMAT_TUPLE                                                   */
 /*          LIT_RESULT_TYPE                                                */
 /*          MATCH_ARITH                                                    */
 /*          SAVE_LITERAL                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ADD_AND_SUBTRACT <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SAVE_LITERAL                                                    */
 /*     ==> HALMAT_TUPLE                                                    */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*     ==> SETUP_VAC                                                       */
 /*     ==> ARITH_LITERAL                                                   */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> MATCH_ARITH                                                     */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> MATRIX_COMPARE                                              */
 /*             ==> VECTOR_COMPARE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> MATCH_SIMPLES                                               */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*     ==> LIT_RESULT_TYPE                                                 */
 /***************************************************************************/
                                                                                00850900
ADD_AND_SUBTRACT:                                                               00851000
   PROCEDURE (MODE);                                                            00851100
      DECLARE MODE BIT(16);                                                     00851200
      IF ARITH_LITERAL(MP,SP) THEN DO;                                          00851300
         IF MONITOR(9,MODE+1) THEN DO;                                          00851400
            CALL ERROR(CLASS_VA,MODE+1);                                        00851500
            GO TO AS_FAIL;                                                      00851600
         END;                                                                   00851700
         LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);                                  00851800
         PSEUDO_TYPE(PTR(MP))=LIT_RESULT_TYPE(MP,SP);                           00851900
      END;                                                                      00852000
      ELSE DO;                                                                  00852100
AS_FAIL:                                                                        00852200
         CALL MATCH_ARITH(MP,SP);                                               00852300
         TEMP=PSEUDO_TYPE(PTR(MP));                                             00852400
         DO CASE MODE;                                                          00852500
            MODE=XMADD(TEMP-MAT_TYPE);                                          00852600
            MODE=XMSUB(TEMP-MAT_TYPE);                                          00852700
         END;                                                                   00852800
         CALL HALMAT_TUPLE(MODE,0,MP,SP,0);                                     00852900
         CALL SETUP_VAC(MP,TEMP);                                               00853000
      END;                                                                      00853100
      PTR_TOP=PTR(MP);                                                          00853200
   END ADD_AND_SUBTRACT;                                                        00853300
