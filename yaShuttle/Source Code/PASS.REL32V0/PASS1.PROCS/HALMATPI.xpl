 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATPI.xpl
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
 /* PROCEDURE NAME:  HALMAT_PIP                                             */
 /* MEMBER NAME:     HALMATPI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OPERAND           BIT(16)                                      */
 /*          QUAL              BIT(8)                                       */
 /*          TAG1              BIT(8)                                       */
 /*          TAG2              BIT(8)                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ATOM                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT                                                         */
 /* CALLED BY:                                                              */
 /*          CHECK_SUBSCRIPT                                                */
 /*          EMIT_ARRAYNESS                                                 */
 /*          EMIT_PUSH_DO                                                   */
 /*          EMIT_SMRK                                                      */
 /*          EMIT_SUBSCRIPT                                                 */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          HALMAT_INIT_CONST                                              */
 /*          HALMAT_TUPLE                                                   */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          ICQ_OUTPUT                                                     */
 /*          SETUP_CALL_ARG                                                 */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_PIP <==                                                      */
 /*     ==> HALMAT                                                          */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> HALMAT_BLAB                                                 */
 /*             ==> HEX                                                     */
 /*             ==> I_FORMAT                                                */
 /*         ==> HALMAT_OUT                                                  */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /***************************************************************************/
                                                                                00804900
HALMAT_PIP:                                                                     00805000
   PROCEDURE(OPERAND,QUAL,TAG1,TAG2);                                           00805100
      DECLARE OPERAND BIT(16),                                                  00805200
         (QUAL,TAG1,TAG2) BIT(8);                                               00805300
      CURRENT_ATOM=SHL(OPERAND,16)|SHL(TAG1,8)|SHL(QUAL&"F",4)                  00805400
         |SHL(TAG2&"7",1)|"1";                                                  00805500
      CALL HALMAT;                                                              00805600
   END HALMAT_PIP;                                                              00805700
