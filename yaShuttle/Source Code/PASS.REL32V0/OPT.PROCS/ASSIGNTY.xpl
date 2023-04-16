 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ASSIGNTY.xpl
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
 /* PROCEDURE NAME:  ASSIGN_TYPE                                            */
 /* MEMBER NAME:     ASSIGNTY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          OP                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          OPR                                                            */
 /*          TASN                                                           */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          FINAL_PASS                                                     */
 /*          GROW_TREE                                                      */
 /*          LOOPY                                                          */
 /*          PUT_VDLP                                                       */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
                                                                                01386070
 /* RETURNS TRUE IF ASSIGNMENT OPERATOR*/                                       01387000
ASSIGN_TYPE:                                                                    01388000
   PROCEDURE(PTR) BIT(8);                                                       01389000
      DECLARE (OP,PTR) BIT(16);                                                 01390000
      OP = SHR(OPR(PTR),4) & "FFF";                                             01391000
      IF (OP & "F00") = 0 THEN          /* CLASS 0*/                            01392000
         RETURN OP = TASN;                                                      01393000
                                                                                01394000
      IF (OP & "FF") ^= "01" THEN RETURN FALSE;                                 01395000
      RETURN (OP & "F00") ^= "800";                                             01396000
   END ASSIGN_TYPE;                                                             01397000
