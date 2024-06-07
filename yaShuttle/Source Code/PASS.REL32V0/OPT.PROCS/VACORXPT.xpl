 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VACORXPT.xpl
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
 /* PROCEDURE NAME:  VAC_OR_XPT                                             */
 /* MEMBER NAME:     VACORXPT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          TRUE                                                           */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* CALLED BY:                                                              */
 /*          FLAG_VAC_OR_LIT                                                */
 /*          GROW_TREE                                                      */
 /*          HALMAT_FLAG                                                    */
 /*          PREPARE_HALMAT                                                 */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_SHAPING_ARGS                                               */
 /*          QUICK_RELOCATE                                                 */
 /*          RELOCATE_HALMAT                                                */
 /*          SWITCH                                                         */
 /*          TERMINAL                                                       */
 /***************************************************************************/
                                                                                00568140
 /* RETURNS TRUE IF VAC OR XPT */                                               00569000
VAC_OR_XPT:                                                                     00570000
   PROCEDURE(PTR) BIT(8);                                                       00571000
      DECLARE PTR BIT(16);                                                      00572000
      PTR = OPR(PTR) & "F1";                                                    00573000
      IF PTR = XVAC OR PTR = XXPT THEN RETURN TRUE;                             00574000
      RETURN FALSE;                                                             00575000
   END VAC_OR_XPT;                                                              00576000
