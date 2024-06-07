 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKVMC.xpl
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
 /* PROCEDURE NAME:  CHECK_VM_COMBINE                                       */
 /* MEMBER NAME:     CHECKVMC                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          AR_DIMS                                                        */
 /*          AR_SIZE                                                        */
 /*          ARRAYNESS_CONFLICT                                             */
 /*          ASSIGN                                                         */
 /*          REF_TO_DSUB                                                    */
 /*          STACKED_VDLPS                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          POP_LOOP_STACKS                                                */
 /*          COMBINE_LOOPS                                                  */
 /*          VM_DETAG                                                       */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_VM_COMBINE <==                                                */
 /*     ==> VM_DETAG                                                        */
 /*         ==> OPOP                                                        */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*         ==> LOOPY                                                       */
 /*             ==> GET_CLASS                                               */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*     ==> POP_LOOP_STACKS                                                 */
 /*         ==> MOVE_LOOP_STACK                                             */
 /*     ==> COMBINE_LOOPS                                                   */
 /*         ==> VU                                                          */
 /*             ==> HEX                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 07/19/99 DAS  30V0/ DR111333 BIX LOOP COMBINING CAUSES INCORRECT        */
 /*               15V0           OBJECT CODE                                */
 /*                                                                         */
 /***************************************************************************/
                                                                                01897370
                                                                                01897380
 /* CHECKS FOR LEGALITY OF COMBINING VECTOR-MATRIX LOOPS*/                      01897390
CHECK_VM_COMBINE:                                                               01897400
   PROCEDURE;                                                                   01897410
      IF AR_SIZE = AR_SIZE(1) THEN                                              01897420
         IF ^(STACKED_VDLPS = 1 AND AR_DIMS ^= 1) THEN                          01897430
         IF ^((ASSIGN|ASSIGN(1)) & (REF_TO_DSUB|REF_TO_DSUB(1)))                01897440
         THEN IF ^ARRAYNESS_CONFLICT                                            01897441
         THEN IF ^REF_TO_STRUC  /* DR111333 */
         THEN DO;                                                               01897450
                                                                                01897460
         CALL COMBINE_LOOPS;                                                    01897470
         CALL POP_LOOP_STACKS(1);                                               01897480
         CALL VM_DETAG;                                                         01897485
      END;                                                                      01897490
   END CHECK_VM_COMBINE;                                                        01897500
