 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHINDI.xpl
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
 /* PROCEDURE NAME:  PUSH_INDIRECT                                          */
 /* MEMBER NAME:     PUSHINDI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR_MAX                                                        */
 /*          CLASS_BS                                                       */
 /*          STACKSIZE                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXT_P                                                          */
 /*          MAX_PTR_TOP                                                    */
 /*          PTR_TOP                                                        */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          AST_STACKER                                                    */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_INDIRECT <==                                                   */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*    DATE   NAME  REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 07/13/95  DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                                         */
 /***************************************************************************/
                                                                                00813900
                                                                                00814000
PUSH_INDIRECT:                                                                  00814100
   PROCEDURE(I);                                                                00814200
      DECLARE I BIT(16);                                                        00814300
      PTR_TOP=PTR_TOP+I;                                                        00814400
      IF PTR_TOP>PTR_MAX THEN CALL ERROR(CLASS_BS,2); /* CR12416 */             00814500
      ELSE IF PTR_TOP>MAX_PTR_TOP THEN MAX_PTR_TOP=PTR_TOP;                     00814600
      VAL_P(PTR_TOP),EXT_P(PTR_TOP)=0;                                          00814700
      RETURN PTR_TOP;                                                           00814800
   END PUSH_INDIRECT;                                                           00814900
