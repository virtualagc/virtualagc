 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MATCHSIM.xpl
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
 /* PROCEDURE NAME:  MATCH_SIMPLES                                          */
 /* MEMBER NAME:     MATCHSIM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          T1                BIT(16)                                      */
 /*          T2                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          XITOS                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_TUPLE                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /*          MATCH_ARITH                                                    */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MATCH_SIMPLES <==                                                   */
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
 /***************************************************************************/
                                                                                00834000
MATCH_SIMPLES:                                                                  00834100
   PROCEDURE (LOC1,LOC2);                                                       00834200
      DECLARE (LOC1,LOC2) BIT(16);                                              00834300
      DECLARE (T1,T2) BIT(16);                                                  00834400
      T1=PSEUDO_TYPE(PTR(LOC1));                                                00834500
      T2=PSEUDO_TYPE(PTR(LOC2));                                                00834600
      IF T1^=T2 THEN DO;                                                        00834700
         IF T2=INT_TYPE THEN LOC1=LOC2;                                         00834800
         CALL HALMAT_TUPLE(XITOS,0,LOC1,0,0);                                   00834900
         CALL SETUP_VAC(LOC1,SCALAR_TYPE);                                      00835000
      END;                                                                      00835100
   END MATCH_SIMPLES;                                                           00835200
