 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPDN.xpl
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
 /* PROCEDURE NAME:  BUMP_D_N                                               */
 /* MEMBER NAME:     BUMPDN                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          D_PTR             BIT(16)                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          D_N_INX                                                        */
 /*          DIFF_NODE                                                      */
 /*          DIFF_PTR                                                       */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /*          GROW_TREE                                                      */
 /*          PREPASS                                                        */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_SHAPING_ARGS                                               */
 /*          PUT_VM_INLINE                                                  */
 /*          TAG_CONDITIONALS                                               */
 /***************************************************************************/
                                                                                00620000
                                                                                00620010
 /* ADDS TO DIFF_NODE STACK*/                                                   00620020
BUMP_D_N:                                                                       00620030
   PROCEDURE(PTR,D_PTR);                                                        00620040
      DECLARE D_PTR BIT(16);                                                    00620050
      DECLARE PTR BIT(16);                                                      00620060
      D_N_INX = D_N_INX + 1;                                                    00620070
      DIFF_NODE(D_N_INX) = PTR;                                                 00620080
      DIFF_PTR(D_N_INX) = D_PTR;                                                00620090
      D_PTR = 0;                                                                00620100
   END BUMP_D_N;                                                                00620110
