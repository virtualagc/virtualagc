 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATTU.xpl
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
 /* PROCEDURE NAME:  HALMAT_TUPLE                                           */
 /* MEMBER NAME:     HALMATTU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POPCODE           BIT(16)                                      */
 /*          COPT              BIT(8)                                       */
 /*          OP1               BIT(16)                                      */
 /*          OP2               BIT(16)                                      */
 /*          TAG               BIT(8)                                       */
 /*          OP1T1             BIT(8)                                       */
 /*          OP1T2             BIT(8)                                       */
 /*          OP2T1             BIT(8)                                       */
 /*          OP2T2             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          ARITH_TO_CHAR                                                  */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          MATCH_SIMPLES                                                  */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          PREC_SCALE                                                     */
 /*          SETUP_CALL_ARG                                                 */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /*          UNARRAYED_INTEGER                                              */
 /*          UNARRAYED_SCALAR                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_TUPLE <==                                                    */
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
                                                                                00805800
HALMAT_TUPLE:                                                                   00805900
   PROCEDURE (POPCODE,COPT,OP1,OP2,TAG,OP1T1,OP1T2,OP2T1,OP2T2);                00806000
      DECLARE (OP1T1,OP1T2,OP2T1,OP2T2) BIT(8);                                 00806100
      DECLARE(POPCODE,OP1,OP2) BIT(16),                                         00806200
         (COPT,TAG) BIT(8);                                                     00806300
      CALL HALMAT_POP(POPCODE,(OP1>0)+(OP2>0),COPT,TAG);                        00806400
      IF OP1>0 THEN CALL HALMAT_PIP(LOC_P(PTR(OP1)),PSEUDO_FORM(PTR(OP1)),      00806500
         OP1T1,OP1T2);                                                          00806600
      IF OP2>0 THEN CALL HALMAT_PIP(LOC_P(PTR(OP2)),PSEUDO_FORM(PTR(OP2)),      00806700
         OP2T1,OP2T2);                                                          00806800
      OP1T1,OP1T2,OP2T1,OP2T2=0;                                                00806900
   END HALMAT_TUPLE;                                                            00807000
