 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NOOPERAN.xpl
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
 /* PROCEDURE NAME:  NO_OPERANDS                                            */
 /* MEMBER NAME:     NOOPERAN                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          ASSIGNMENT                                                     */
 /*          BOTTOM                                                         */
 /*          CHICKEN_OUT                                                    */
 /*          EJECT_INVARS                                                   */
 /*          EXPAND_DSUB                                                    */
 /*          FINAL_PASS                                                     */
 /*          FLAG_NODE                                                      */
 /*          FLAG_V_N                                                       */
 /*          FLAG_VAC_OR_LIT                                                */
 /*          GROW_TREE                                                      */
 /*          LOOPY                                                          */
 /*          NEXT_FLAG                                                      */
 /*          POP_COMPARE                                                    */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_NOP                                                        */
 /*          PUT_VM_INLINE                                                  */
 /*          REARRANGE_HALMAT                                               */
 /*          REFERENCE                                                      */
 /*          RELOCATE_HALMAT                                                */
 /*          SET_SAV                                                        */
 /*          SWITCH                                                         */
 /*          TAG_CONDITIONALS                                               */
 /*          VM_DETAG                                                       */
 /***************************************************************************/
                                                                                01398000
 /* FIND NUMBER OF OPERANDS*/                                                   01399000
NO_OPERANDS:                                                                    01400000
   PROCEDURE(PTR) BIT(8);                                                       01401000
      DECLARE PTR BIT(16);                                                      01402000
      RETURN SHR(OPR(PTR),16) & "FF";                                           01403000
   END NO_OPERANDS;                                                             01404000
