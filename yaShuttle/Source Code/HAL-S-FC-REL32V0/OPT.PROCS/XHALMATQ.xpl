 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   XHALMATQ.xpl
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
 /* PROCEDURE NAME:  XHALMAT_QUAL                                           */
 /* MEMBER NAME:     XHALMATQ                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          CHECK_COMPONENT                                                */
 /*          CHICKEN_OUT                                                    */
 /*          EXIT_CHECK                                                     */
 /*          EXTN_CHECK                                                     */
 /*          EXTRACT_VAR                                                    */
 /*          FINAL_PASS                                                     */
 /*          GROW_TREE                                                      */
 /*          LOOPY                                                          */
 /*          POP_COMPARE                                                    */
 /*          PREPASS                                                        */
 /*          PREVENT_PULLS                                                  */
 /*          PROCESS_LABEL                                                  */
 /*          PUT_VM_INLINE                                                  */
 /*          QUICK_RELOCATE                                                 */
 /*          SEARCH_DIMENSION                                               */
 /*          SET_VAR                                                        */
 /***************************************************************************/
                                                                                01385010
 /* RETURNS UNSHIFTED QUAL BITS FOR HALMAT OPERAND*/                            01385020
XHALMAT_QUAL:                                                                   01385030
   PROCEDURE(PTR) BIT(16);                                                      01385040
      DECLARE PTR BIT(16);                                                      01385050
      RETURN OPR(PTR) & "F1";                                                   01385060
   END XHALMAT_QUAL;                                                            01385070
