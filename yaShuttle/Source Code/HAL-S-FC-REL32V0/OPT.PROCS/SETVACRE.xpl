 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETVACRE.xpl
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
 /* PROCEDURE NAME:  SET_VAC_REF                                            */
 /* MEMBER NAME:     SETVACRE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          HALMAT_PTR        BIT(16)                                      */
 /*          PREVIOUS_HALMAT   BIT(16)                                      */
 /*          TAG               BIT(16)                                      */
 /*          NOTYPE            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PREV_PTR          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NODE                                                           */
 /*          EXTN                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          OPOP                                                           */
 /*          ENTER                                                          */
 /* CALLED BY:                                                              */
 /*          SET_WORDS                                                      */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_VAC_REF <==                                                     */
 /*     ==> OPOP                                                            */
 /*     ==> ENTER                                                           */
 /***************************************************************************/
                                                                                02658000
 /* CREATE A VAC REFERENCE HALMAT OPERAND*/                                     02659000
SET_VAC_REF:                                                                    02660000
   PROCEDURE(HALMAT_PTR,PREVIOUS_HALMAT,TAG,NOTYPE);                            02661000
      DECLARE (HALMAT_PTR,PREVIOUS_HALMAT,TAG) BIT(16),                         02662000
         (NOTYPE) BIT(8);                                                       02663000
      DECLARE PREV_PTR BIT(16);  /* POINTS TO ACTUAL OPERATOR*/                 02664000
                                                                                02665000
      IF TAG THEN DO;                                                           02666000
         CALL ENTER(HALMAT_PTR);                                                02667000
         TAG = "C";                                                             02668000
         IF ^NOTYPE THEN TAG = TAG | OPR(HALMAT_PTR) & "FF02";                  02669000
                                                                                02670000
 /* OR IN ALPHA, BETA, TYPE*/                                                   02671000
                                                                                02672000
         PREV_PTR = NODE(PREVIOUS_HALMAT) & "FFFF";                             02673000
      END;                                                                      02674000
      ELSE PREV_PTR = PREVIOUS_HALMAT;                                          02675000
                                                                                02676000
      IF OPOP(PREV_PTR) = EXTN THEN TAG = TAG | "41";   /* XPT NEEDED*/         02677000
      ELSE TAG = TAG | "31";                                                    02678000
      OPR(HALMAT_PTR) = SHL(PREVIOUS_HALMAT,16) | TAG;                          02679000
 /* (FLAGED) VAC PTR*/                                                          02680000
      TAG,NOTYPE = 0;                                                           02681000
   END SET_VAC_REF;                                                             02682000
