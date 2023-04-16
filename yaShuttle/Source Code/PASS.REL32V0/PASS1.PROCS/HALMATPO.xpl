 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATPO.xpl
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
 /* PROCEDURE NAME:  HALMAT_POP                                             */
 /* MEMBER NAME:     HALMATPO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POPCODE           BIT(16)                                      */
 /*          PIP#              BIT(8)                                       */
 /*          COPT              BIT(8)                                       */
 /*          TAG               BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NEXT_ATOM#                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LAST_POP#                                                      */
 /*          CURRENT_ATOM                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT                                                         */
 /* CALLED BY:                                                              */
 /*          CHECK_SUBSCRIPT                                                */
 /*          EMIT_ARRAYNESS                                                 */
 /*          EMIT_SMRK                                                      */
 /*          END_ANY_FCN                                                    */
 /*          HALMAT_INIT_CONST                                              */
 /*          HALMAT_TUPLE                                                   */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          ICQ_OUTPUT                                                     */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_POP <==                                                      */
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
                                                                                00803900
HALMAT_POP:                                                                     00804000
   PROCEDURE(POPCODE,PIP#,COPT,TAG);                                            00804100
      DECLARE POPCODE BIT(16),                                                  00804200
         (PIP#,COPT,TAG) BIT(8);                                                00804300
      CURRENT_ATOM=SHL(TAG,24)|SHL(PIP#,16)|SHL(POPCODE&"FFF",4)|               00804400
         SHL(COPT&"7",1);                                                       00804500
      CALL HALMAT;                                                              00804600
      LAST_POP#=NEXT_ATOM#-1;                                                   00804700
   END HALMAT_POP;                                                              00804800
