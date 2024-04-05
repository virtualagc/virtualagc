 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITARRA.xpl
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
 /* PROCEDURE NAME:  EMIT_ARRAYNESS                                         */
 /* MEMBER NAME:     EMITARRA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ACODE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FCN_LV                                                         */
 /*          XADLP                                                          */
 /*          XASZ                                                           */
 /*          XCO_D                                                          */
 /*          XCO_N                                                          */
 /*          XDLPE                                                          */
 /*          XIMD                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          ARRAYNESS_FLAG                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMIT_ARRAYNESS <==                                                  */
 /*     ==> HALMAT_POP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /***************************************************************************/
                                                                                00862700
                                                                                00862800
                                                                                00862900
                                                                                00863000
                                                                                00863100
                                                                                00863200
EMIT_ARRAYNESS:                                                                 00863300
   PROCEDURE (ACODE);                                                           00863400
      DECLARE (ACODE,I) BIT(16);                                                00863500
      IF CURRENT_ARRAYNESS>0 THEN DO;                                           00863600
         CALL HALMAT_POP(ACODE,CURRENT_ARRAYNESS,XCO_D,FCN_LV);                 00863700
         DO I=1 TO CURRENT_ARRAYNESS;                                           00863800
            IF CURRENT_ARRAYNESS(I)<0 THEN                                      00863900
               CALL HALMAT_PIP(-CURRENT_ARRAYNESS(I),XASZ,0,0);                 00864000
            ELSE CALL HALMAT_PIP(CURRENT_ARRAYNESS(I),XIMD,0,0);                00864100
         END;                                                                   00864200
         CALL HALMAT_POP(XDLPE,0,XCO_N,FCN_LV);                                 00864300
         CURRENT_ARRAYNESS=0;                                                   00864400
      END;                                                                      00864500
      ARRAYNESS_FLAG=0;                                                         00864600
      ACODE=XADLP;                                                              00864700
   END EMIT_ARRAYNESS;                                                          00864800
