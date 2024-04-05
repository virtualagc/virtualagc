 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MULTIPLY.xpl
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
 /* PROCEDURE NAME:  MULTIPLY_SYNTHESIZE                                    */
 /* MEMBER NAME:     MULTIPLY                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          DOCASE            BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MUL_FAIL(1638)    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_EC                                                       */
 /*          CLASS_EM                                                       */
 /*          CLASS_EV                                                       */
 /*          CLASS_VA                                                       */
 /*          DW_AD                                                          */
 /*          MAT_TYPE                                                       */
 /*          PSEUDO_LENGTH                                                  */
 /*          SCALAR_TYPE                                                    */
 /*          VEC_TYPE                                                       */
 /*          XMMPR                                                          */
 /*          XMSPR                                                          */
 /*          XMVPR                                                          */
 /*          XSSPR                                                          */
 /*          XVCRS                                                          */
 /*          XVDOT                                                          */
 /*          XVMPR                                                          */
 /*          XVSPR                                                          */
 /*          XVVPR                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          TEMP2                                                          */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARITH_LITERAL                                                  */
 /*          ERROR                                                          */
 /*          HALMAT_TUPLE                                                   */
 /*          LIT_RESULT_TYPE                                                */
 /*          MATCH_SIMPLES                                                  */
 /*          SAVE_LITERAL                                                   */
 /*          SETUP_VAC                                                      */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MULTIPLY_SYNTHESIZE <==                                             */
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
 /*     ==> VECTOR_COMPARE                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
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
 /*     ==> ARITH_LITERAL                                                   */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> LIT_RESULT_TYPE                                                 */
 /***************************************************************************/
                                                                                00853400
MULTIPLY_SYNTHESIZE :                                                           00853500
   PROCEDURE (I,J,K,DOCASE) ;                                                   00853600
      DECLARE (I,J,K,DOCASE) BIT(16) ;                                          00853700
      DO CASE (DOCASE) ;                                                        00853800
 /* CASE 0 : SCLAR AND/OR INTEGER MULT. */                                      00853900
         IF ARITH_LITERAL(I,J) THEN DO;                                         00854000
            IF MONITOR(9,3) THEN DO;                                            00854100
               CALL ERROR(CLASS_VA,3);                                          00854200
               GO TO MUL_FAIL;                                                  00854300
            END;                                                                00854400
            LOC_P(PTR(K))=SAVE_LITERAL(1,DW_AD);                                00854500
            PSEUDO_TYPE(PTR(K))=LIT_RESULT_TYPE(I,J);                           00854600
         END;                                                                   00854700
         ELSE DO;                                                               00854800
MUL_FAIL:                                                                       00854900
            CALL MATCH_SIMPLES(I,J);                                            00855000
            CALL HALMAT_TUPLE(XSSPR(PSEUDO_TYPE(PTR(I))-SCALAR_TYPE),0,I,J,0);  00855100
            CALL SETUP_VAC(K,PSEUDO_TYPE(PTR(I)));                              00855200
         END ;                                                                  00855300
 /* CASE 1:  VECTOR   (SCALAR OR INTEGER)     */                                00855400
         DO ;                                                                   00855500
            PTR=0;                                                              00855600
            PSEUDO_TYPE=SCALAR_TYPE;                                            00855700
            CALL MATCH_SIMPLES(0,J);                                            00855800
            CALL HALMAT_TUPLE(XVSPR,0,I,J,0);                                   00855900
            CALL SETUP_VAC(K,VEC_TYPE,PSEUDO_LENGTH(PTR(I)));                   00856000
         END ;                                                                  00856100
 /* CASE 2 : MATRIX (OP) (SCALAR OR INTEGER) */                                 00856200
         DO ;                                                                   00856300
            PTR=0;                                                              00856400
            PSEUDO_TYPE=SCALAR_TYPE;                                            00856500
            CALL MATCH_SIMPLES(0,J);                                            00856600
            CALL HALMAT_TUPLE(XMSPR,0,I,J,0);                                   00856700
            CALL SETUP_VAC(K,MAT_TYPE,PSEUDO_LENGTH(PTR(I)));                   00856800
         END ;                                                                  00856900
 /* CASE 3, VECTOR DOT VECTOR */                                                00857000
         DO ;                                                                   00857100
            CALL VECTOR_COMPARE(I,J,CLASS_EV,1);                                00857200
            CALL HALMAT_TUPLE(XVDOT,0,I,J,0);                                   00857300
            CALL SETUP_VAC(K,SCALAR_TYPE);                                      00857400
         END ;                                                                  00857500
 /* CASE 4, VECTOR CROSS VECTOR */                                              00857600
         DO ;                                                                   00857700
            CALL HALMAT_TUPLE(XVCRS,0,I,J,0);                                   00857800
            CALL SETUP_VAC(K,VEC_TYPE,3);                                       00857900
            IF (PSEUDO_LENGTH(PTR(I)) ^= 3) |                                   00858000
               (PSEUDO_LENGTH(PTR(J)) ^= 3) THEN                                00858100
               CALL ERROR(CLASS_EC,1);                                          00858200
         END ;                                                                  00858300
 /* CASE 5,VECTOR  VECTOR */                                                    00858400
         DO ;                                                                   00858500
            CALL HALMAT_TUPLE(XVVPR,0,I,J,0);                                   00858600
            CALL SETUP_VAC(K,MAT_TYPE,SHL(PSEUDO_LENGTH(PTR(I)),8)+             00858700
               (PSEUDO_LENGTH(PTR(J))&"FF"));                                   00858800
         END ;                                                                  00858900
 /* CASE 6 : VECTOR MATRIX */                                                   00859000
         DO ;                                                                   00859100
            TEMP=SHR(PSEUDO_LENGTH(PTR(J)),8);                                  00859200
            IF TEMP^=PSEUDO_LENGTH(PTR(I)) THEN CALL ERROR(CLASS_EV,3);         00859300
            CALL HALMAT_TUPLE(XVMPR,0,I,J,0);                                   00859400
            CALL SETUP_VAC(K,VEC_TYPE,PSEUDO_LENGTH(PTR(J))&"FF");              00859500
         END ;                                                                  00859600
 /* CASE 7 : MATRIX VECTOR */                                                   00859700
         DO ;                                                                   00859800
            TEMP=PSEUDO_LENGTH(PTR(I))&"FF";                                    00859900
            IF TEMP^=PSEUDO_LENGTH(PTR(J)) THEN CALL ERROR(CLASS_EV,2);         00860000
            CALL HALMAT_TUPLE(XMVPR,0,I,J,0);                                   00860100
            CALL SETUP_VAC(K,VEC_TYPE,SHR(PSEUDO_LENGTH(PTR(I)),8));            00860200
         END ;                                                                  00860300
 /* CASE 8 : MATRIX MATRIX */                                                   00860400
         DO ;                                                                   00860500
            TEMP=PSEUDO_LENGTH(PTR(I))&"FF";                                    00860600
            TEMP2=SHR(PSEUDO_LENGTH(PTR(J)),8);                                 00860700
            IF TEMP^=TEMP2 THEN CALL ERROR(CLASS_EM,3);                         00860800
            CALL HALMAT_TUPLE(XMMPR,0,I,J,0);                                   00860900
            CALL SETUP_VAC(K,MAT_TYPE,(PSEUDO_LENGTH(PTR(I))&"FF00")|           00861000
               (PSEUDO_LENGTH(PTR(J))&"00FF"));                                 00861100
         END ;                                                                  00861200
      END; /* OF DO CASE */                                                     00861300
   END MULTIPLY_SYNTHESIZE;                                                     00861400
