 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORCEMAT.xpl
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
 /* PROCEDURE NAME:  FORCE_MATCH                                            */
 /* MEMBER NAME:     FORCEMAT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          INVERSE           BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NEW               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          TRACE                                                          */
 /*          FLAG                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          NEXT_FLAG                                                      */
 /*          SWITCH                                                         */
 /* CALLED BY:                                                              */
 /*          SET_WORDS                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORCE_MATCH <==                                                     */
 /*     ==> NEXT_FLAG                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*     ==> SWITCH                                                          */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*         ==> NEXT_FLAG                                                   */
 /*             ==> NO_OPERANDS                                             */
 /***************************************************************************/
                                                                                02910000
                                                                                02911000
 /* FORCES OPR(PTR) TO CONTAIN MATCHED OPERAND */                               02912000
FORCE_MATCH:                                                                    02913000
   PROCEDURE(PTR,INVERSE);                                                      02914000
      DECLARE INVERSE BIT(8);                                                   02915000
      DECLARE (PTR,NEW) BIT(16);                                                02916000
      IF TRACE THEN OUTPUT = 'FORCE_MATCH: ' || PTR ||','||INVERSE;             02917000
      NEW = NEXT_FLAG(PTR,1);                                                   02918000
      DO WHILE (SHR(FLAG(NEW),2) & "1") ^= INVERSE;                             02919000
         NEW = NEW + 1;                                                         02920000
         NEW = NEXT_FLAG(NEW,1);                                                02921000
      END;                                                                      02922000
      IF PTR ^= NEW THEN CALL SWITCH(PTR,NEW);                                  02923000
      INVERSE = 0;                                                              02924000
   END FORCE_MATCH;                                                             02925000
