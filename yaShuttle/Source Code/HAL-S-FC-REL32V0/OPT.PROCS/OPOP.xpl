 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OPOP.xpl
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
 /* PROCEDURE NAME:  OPOP                                                   */
 /* MEMBER NAME:     OPOP                                                   */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          CHECK_ADJACENT_LOOPS                                           */
 /*          CHECK_LIST                                                     */
 /*          EMPTY_ARRAY                                                    */
 /*          EXPAND_DSUB                                                    */
 /*          EXTRACT_VAR                                                    */
 /*          FINAL_PASS                                                     */
 /*          GET_ADLP                                                       */
 /*          GROW_TREE                                                      */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_SHAPING_ARGS                                               */
 /*          PUT_VM_INLINE                                                  */
 /*          RELOCATE_HALMAT                                                */
 /*          SEARCH_DIMENSION                                               */
 /*          SET_SAV                                                        */
 /*          SET_VAC_REF                                                    */
 /*          SHAPING_FN                                                     */
 /*          VM_DETAG                                                       */
 /***************************************************************************/
                                                                                00561070
                                                                                00561080
 /* RETURNS FOR AN OPERATOR WORD THE OPERATOR*/                                 00562000
OPOP:                                                                           00563000
   PROCEDURE(PTR) BIT(16);                                                      00564000
      DECLARE PTR BIT(16);                                                      00565000
      RETURN SHR(OPR(PTR),4) & "FFF";                                           00566000
   END OPOP;                                                                    00567000
