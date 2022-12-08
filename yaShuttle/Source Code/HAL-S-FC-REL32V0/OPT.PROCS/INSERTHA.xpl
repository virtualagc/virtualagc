 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INSERTHA.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  INSERT_HALMAT_TRIPLE                                   */
 /* MEMBER NAME:     INSERTHA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /*          PTR_WORD          FIXED                                        */
 /*          CONST_PTR         FIXED                                        */
 /*          TAG               BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB_LOC                                                       */
 /*          SUB_TRACE                                                      */
 /*          XNOP                                                           */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DSUB_HOLE                                                      */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          VU                                                             */
 /*          PUSH_HALMAT                                                    */
 /* CALLED BY:                                                              */
 /*          GENERATE_DSUB_COMPUTATION                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INSERT_HALMAT_TRIPLE <==                                            */
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
                                                                                01597190
 /* INSERTS HALMAT TRIPLE OF OP OPERATING ON PTR_WORD AND CONST_PTR.            01597200
      RETURNS OPERAND WORD POINTING TO OPERATOR*/                               01597210
                                                                                01597220
INSERT_HALMAT_TRIPLE:                                                           01597230
   PROCEDURE(OP,PTR_WORD,CONST_PTR,TAG);                                        01597240
      DECLARE TAG BIT(8);                                                       01597250
      DECLARE (PTR_WORD,CONST_PTR) FIXED;                                       01597260
      DECLARE (OP,TEMP) BIT(16);                                                01597270
      IF DSUB_LOC - DSUB_HOLE < 3 THEN                                          01597280
         CALL PUSH_HALMAT(DSUB_LOC,3);                                          01597290
      OPR(DSUB_HOLE) = "2 000 0" | SHL(OP,4) | SHL(TAG,24);                     01597300
      TAG = 0;                                                                  01597310
      OPR(DSUB_HOLE + 1) = PTR_WORD;                                            01597320
      OPR(DSUB_HOLE + 2) = CONST_PTR;                                           01597330
      IF SUB_TRACE THEN CALL VU(DSUB_HOLE,2);                                   01597340
      TEMP = DSUB_HOLE;                                                         01597350
      DSUB_HOLE = DSUB_HOLE + 3;                                                01597360
      IF DSUB_HOLE < DSUB_LOC THEN                                              01597370
         OPR(DSUB_HOLE) = XNOP | SHL(DSUB_LOC - DSUB_HOLE - 1, 16);             01597380
 /* RESET NOP*/                                                                 01597390
      RETURN XVAC | SHL(TEMP,16);                                               01597400
   END INSERT_HALMAT_TRIPLE;                                                    01597410
