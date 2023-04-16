 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPADD.xpl
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
 /* PROCEDURE NAME:  BUMP_ADD                                               */
 /* MEMBER NAME:     BUMPADD                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADD                                                            */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /*          GROUP_CSE                                                      */
 /*          PREVENT_PULLS                                                  */
 /*          PUT_VM_INLINE                                                  */
 /*          TAG_CONDITIONALS                                               */
 /***************************************************************************/
                                                                                01748000
                                                                                01748010
 /* ADDS TO ADD STACK*/                                                         01748020
BUMP_ADD:                                                                       01748030
   PROCEDURE(PTR);                                                              01748040
      DECLARE PTR BIT(16);                                                      01748050
      A_INX = A_INX + 1;                                                        01748060
      ADD(A_INX) = PTR;                                                         01748070
   END BUMP_ADD;                                                                01748080
