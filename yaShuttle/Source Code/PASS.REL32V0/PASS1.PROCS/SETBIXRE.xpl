 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETBIXRE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  SET_BI_XREF                                            */
 /* MEMBER NAME:     SETBIXRE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TAG               BIT(16)                                      */
 /*          NEW_XREF          MACRO                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          CR_REF                                                         */
 /*          CROSS_REF                                                      */
 /*          STMT_NUM                                                       */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          TRUE                                                           */
 /*          XREF_MASK                                                      */
 /*          XREF_REF                                                       */
 /*          XREF_SUBSCR                                                    */
 /*          XREF                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BI_XREF                                                        */
 /*          BI_XREF#                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER_XREF                                                     */
 /* CALLED BY:                                                              */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_BI_XREF <==                                                     */
 /*     ==> ENTER_XREF                                                      */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*   DATE    NAME  REL     DR NUMBER   TITLE                               */
 /*                                                                         */
 /* 07/25/03  DCP   32V0/   DR120220    MISSING SUBBIT CROSS-REFERENCE      */
 /*                 17V0                                                    */
 /***************************************************************************/
                                                                                00549300
                                                                                00551200
SET_BI_XREF:                                                                    00551300
   PROCEDURE (LOC);                                                             00551400
      DECLARE LOC BIT(16);                                                      00551500
      DECLARE TAG FIXED;                                            /*DR120220*/00551600
      DECLARE NEW_XREF LITERALLY                                    /*DR120220*/00551610
                       '(XREF(BI_XREF(LOC))&XREF_MASK)^=STMT_NUM';  /*DR120220*/00551610
      IF SUBSCRIPT_LEVEL>0 THEN TAG=XREF_SUBSCR;                                00551700
      ELSE IF (SHR(ATOMS(LAST_POP#),24) = 1) & (LOC = SBIT_NDX)     /*DR120220*/
      THEN TAG=XREF_ASSIGN;                                         /*DR120220*/
      ELSE TAG=XREF_REF;                                                        00551800
      IF NEW_XREF THEN BI_XREF#(LOC) = BI_XREF#(LOC)+1;                         00551810
      BI_XREF(LOC)=ENTER_XREF(BI_XREF(LOC),TAG);                                00551900
      BI_XREF=TRUE;                                                             00552000
   END SET_BI_XREF;                                                             00552100
