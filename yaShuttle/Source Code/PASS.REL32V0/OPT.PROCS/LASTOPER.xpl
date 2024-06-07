 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LASTOPER.xpl
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
 /* PROCEDURE NAME:  LAST_OPERAND                                           */
 /* MEMBER NAME:     LASTOPER                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          CHECK_ADJACENT_LOOPS                                           */
 /*          EJECT_INVARS                                                   */
 /*          EMPTY_ARRAY                                                    */
 /*          FINAL_PASS                                                     */
 /*          GET_LOOP_DIMENSION                                             */
 /*          GROUP_CSE                                                      */
 /*          GROW_TREE                                                      */
 /*          LOOP_OPERANDS                                                  */
 /*          NONCONSEC                                                      */
 /*          PREVENT_PULLS                                                  */
 /*          PUT_VDLP                                                       */
 /*          PUT_VM_INLINE                                                  */
 /*          SEARCH_DIMENSION                                               */
 /*          SET_ARRAYNESS                                                  */
 /*          SET_SAV                                                        */
 /*          SET_V_M_TAGS                                                   */
 /*          SET_VAR                                                        */
 /*          TERM_CHECK                                                     */
 /***************************************************************************/
                                                                                01404010
 /* RETURNS PTR + NO_OPERANDS(PTR), I.E. LAST OPERAND OF OPERATOR AT PTR*/      01404020
LAST_OPERAND:                                                                   01404030
   PROCEDURE(PTR) BIT(16);                                                      01404040
      DECLARE PTR BIT(16);                                                      01404050
      RETURN PTR + (SHR(OPR(PTR),16) & "FF");                                   01404060
   END LAST_OPERAND;                                                            01404070
