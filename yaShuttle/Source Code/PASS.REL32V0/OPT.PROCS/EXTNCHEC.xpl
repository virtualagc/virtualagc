 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EXTNCHEC.xpl
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
 /* PROCEDURE NAME:  EXTN_CHECK                                             */
 /* MEMBER NAME:     EXTNCHEC                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          TRUE                                                           */
 /*          OPR                                                            */
 /*          XVAC                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          XHALMAT_QUAL                                                   */
 /*          NAME_OR_PARM                                                   */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EXTN_CHECK <==                                                      */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> NAME_OR_PARM                                                    */
 /***************************************************************************/
                                                                                01736010
 /* RETURNS TRUE IF NAME OR PARM INVOLVED IN EXTN.  SHR(OPR(PTR,16) IS EXTN*/   01736020
EXTN_CHECK:                                                                     01736030
   PROCEDURE(PTR) BIT(8);                                                       01736040
      DECLARE PTR BIT(16);                                                      01736050
      PTR = SHR(OPR(PTR),16);   /*EXTN*/                                        01736060
      IF SHR(OPR(PTR),24) THEN RETURN TRUE;   /* EXTN TAG => NAME*/             01736070
      PTR = PTR + 1;                                                            01736080
      IF XHALMAT_QUAL(PTR) = XVAC THEN                                          01736090
         PTR = SHR(OPR(PTR),16) + 1;                                            01736100
      RETURN NAME_OR_PARM(PTR);                                                 01736110
   END EXTN_CHECK;                                                              01736120
