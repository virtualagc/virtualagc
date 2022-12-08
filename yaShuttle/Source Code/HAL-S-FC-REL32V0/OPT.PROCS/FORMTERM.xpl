 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMTERM.xpl
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
 /* PROCEDURE NAME:  FORM_TERM                                              */
 /* MEMBER NAME:     FORMTERM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          CONTROL           BIT(8)                                       */
 /*          OMIT_CHECK        BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FORMIT            LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DUMMY_NODE                                                     */
 /*          OPR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          TMP                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          NAME_OR_PARM                                                   */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORM_TERM <==                                                       */
 /*     ==> NAME_OR_PARM                                                    */
 /***************************************************************************/
                                                                                01724000
 /* PUTS TERMINAL NODE INTO CSE_LIST FORM*/                                     01725000
FORM_TERM:                                                                      01726000
   PROCEDURE(PTR,CONTROL,OMIT_CHECK);                                           01727000
      DECLARE OMIT_CHECK BIT(8);                                                01727010
      DECLARE PTR BIT(16),                                                      01728000
         CONTROL BIT(8);                                                        01729000
      IF OMIT_CHECK THEN GO TO FORMIT;                                          01729010
      IF NAME_OR_PARM(PTR) THEN                                                 01730000
         TMP = DUMMY_NODE | SHL(CONTROL,20);   /* NO NAME CSE'S */              01731000
      ELSE                                                                      01732000
FORMIT:                                                                         01732010
      TMP = SHL(SHL(CONTROL,4) |(SHR(OPR(PTR),4) & "F"),16) | SHR(OPR(PTR),16); 01733000
      OMIT_CHECK,                                                               01733010
         CONTROL = 0;                                                           01734000
      RETURN TMP;                                                               01735000
   END FORM_TERM;                                                               01736000
