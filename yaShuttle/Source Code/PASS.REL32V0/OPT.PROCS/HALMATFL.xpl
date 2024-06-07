 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATFL.xpl
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
 /* PROCEDURE NAME:  HALMAT_FLAG                                            */
 /* MEMBER NAME:     HALMATFL                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          VAC_OR_XPT                                                     */
 /* CALLED BY:                                                              */
 /*          BOTTOM                                                         */
 /*          FLAG_NODE                                                      */
 /*          FLAG_VAC_OR_LIT                                                */
 /*          PUSH_OPERAND                                                   */
 /*          REARRANGE_HALMAT                                               */
 /*          ST_CHECK                                                       */
 /*          SWITCH                                                         */
 /*          TERMINAL                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_FLAG <==                                                     */
 /*     ==> VAC_OR_XPT                                                      */
 /***************************************************************************/
                                                                                01460120
                                                                                01461000
 /* RETURN HALMAT FLAG*/                                                        01462000
HALMAT_FLAG:                                                                    01463000
   PROCEDURE(PTR) BIT(8);                                                       01464000
      DECLARE PTR BIT(16);                                                      01465000
      IF ^OPR(PTR) THEN                                                         01466000
         RETURN SHR(OPR(PTR),3) & "1";                                          01467000
      IF VAC_OR_XPT(PTR) THEN RETURN (OPR(PTR) & "C") = "C";                    01468000
      RETURN FALSE;                                                             01469000
   END HALMAT_FLAG;                                                             01470000
