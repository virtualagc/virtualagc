 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVEARRA.xpl
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
 /* PROCEDURE NAME:  SAVE_ARRAYNESS                                         */
 /* MEMBER NAME:     SAVEARRA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          RESET             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AS_PTR_MAX                                                     */
 /*          CLASS_BS                                                       */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          AS_PTR                                                         */
 /*          ARRAYNESS_STACK                                                */
 /*          CURRENT_ARRAYNESS                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          ASSOCIATE                                                      */
 /*          SETUP_CALL_ARG                                                 */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SAVE_ARRAYNESS <==                                                  */
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
                                                                                00864900
SAVE_ARRAYNESS:                                                                 00865000
   PROCEDURE (RESET);                                                           00865100
      DECLARE RESET BIT(1) INITIAL(TRUE);                                       00865200
 /* SAVE OLD CURRENT ARRAYNESS AND ZERO THE NEW */                              00865300
      DECLARE I BIT(16);                                      /* CR12416 */     00865400
      IF CURRENT_ARRAYNESS+AS_PTR>=AS_PTR_MAX THEN CALL ERROR(CLASS_BS,4);      00865500
      AS_PTR=AS_PTR+CURRENT_ARRAYNESS+1;                                        00865600
      DO I= 1 TO CURRENT_ARRAYNESS;                                             00865700
         ARRAYNESS_STACK(AS_PTR-I)=CURRENT_ARRAYNESS(I);                        00865800
      END;                                                                      00865900
      ARRAYNESS_STACK(AS_PTR)=CURRENT_ARRAYNESS;                                00866000
      IF RESET THEN CURRENT_ARRAYNESS=0;                                        00866100
      RESET=TRUE;                                                               00866200
   END SAVE_ARRAYNESS;                                                          00866300
