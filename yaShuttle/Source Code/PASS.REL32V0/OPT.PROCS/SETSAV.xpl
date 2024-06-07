 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETSAV.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_SAV                                                */
 /* MEMBER NAME:     SETSAV                                                 */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB_LOC                                                       */
 /*          LAST_DSUB_HALMAT                                               */
 /*          NOP                                                            */
 /*          SAV_BITS                                                       */
 /*          SUB_TRACE                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /*          NO_OPERANDS                                                    */
 /*          OPOP                                                           */
 /*          PUSH_HALMAT                                                    */
 /*          VU                                                             */
 /* CALLED BY:                                                              */
 /*          EXPAND_DSUB                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_SAV <==                                                         */
 /*     ==> OPOP                                                            */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> VU                                                              */
 /*         ==> HEX                                                         */
 /*     ==> PUSH_HALMAT                                                     */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /***************************************************************************/
                                                                                02369020
                                                                                02369030
                                                                                02369040
 /*   THESE ROUTINES ARE FOR SUBSCRIPT COMMON EXPRESSIONS  */                   02369050
                                                                                02369060
 /* FIXES SUBSCRIPT ADDITIVE VAC OPERATOR FOR DSUB*/                            02369070
SET_SAV:                                                                        02369080
   PROCEDURE;                                                                   02369090
      DECLARE TEMP BIT(16);                                                     02369100
      TEMP = LAST_OPERAND(DSUB_LOC) + 1;    /* NEXT OP*/                        02369110
      IF OPOP(TEMP) ^= NOP THEN                                                 02369120
         CALL PUSH_HALMAT(TEMP,1);                                              02369130
      OPR(TEMP) = SAV_BITS | LAST_DSUB_HALMAT;                                  02369140
      OPR(DSUB_LOC) = OPR(DSUB_LOC) + "1 000 0"; /* BUMP NUMOP*/                02369150
      IF SUB_TRACE THEN                                                         02369160
         CALL VU(DSUB_LOC,NO_OPERANDS(DSUB_LOC));                               02369170
   END SET_SAV;                                                                 02369180
