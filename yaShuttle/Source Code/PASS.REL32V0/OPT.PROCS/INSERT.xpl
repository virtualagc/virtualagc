 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INSERT.xpl
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
 /* PROCEDURE NAME:  INSERT                                                 */
 /* MEMBER NAME:     INSERT                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          HIGH              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOOP_START                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MOVE_LIMB                                                      */
 /* CALLED BY:                                                              */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INSERT <==                                                          */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /***************************************************************************/
                                                                                02373040
 /* INSERTS V/M OP AT POINTER AND RESETS LOOP_START.  ALL OF DIFF_NODE AND ADD  02373050
      STARTING WITH INDEX 0 MUST ALSO BE RELOCATED*/                            02373060
INSERT:                                                                         02373070
   PROCEDURE(PTR,HIGH);                                                         02373080
      DECLARE (PTR,HIGH) BIT(16);                                               02373090
      CALL MOVE_LIMB(PTR, HIGH, LOOP_START - HIGH,0,1);                         02373100
   END INSERT;                                                                  02373110
