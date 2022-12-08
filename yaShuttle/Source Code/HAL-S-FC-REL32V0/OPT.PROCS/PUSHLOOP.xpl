 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHLOOP.xpl
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
 /* PROCEDURE NAME:  PUSH_LOOP_STACKS                                       */
 /* MEMBER NAME:     PUSHLOOP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          VM                BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          C_TRACE                                                        */
 /*          IN_AR                                                          */
 /*          OR                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADJACENT                                                       */
 /*          ASSIGN                                                         */
 /*          LOOP_HEAD                                                      */
 /*          REF_TO_DSUB                                                    */
 /*          STACKED_VDLPS                                                  */
 /*          ST                                                             */
 /*          ST1                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHECK_ADJACENT_LOOPS                                           */
 /*          BUMP_LOOPSTACK                                                 */
 /*          INIT_ARCONFS                                                   */
 /*          MOVE_LOOP_STACK                                                */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_LOOP_STACKS <==                                                */
 /*     ==> INIT_ARCONFS                                                    */
 /*     ==> CHECK_ADJACENT_LOOPS                                            */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OP                                                     */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> MOVE_LOOP_STACK                                                 */
 /*     ==> BUMP_LOOPSTACK                                                  */
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
                                                                                01894830
PUSH_LOOP_STACKS:                                                               01894840
   PROCEDURE(PTR,VM);                                                           01894850
      DECLARE PTR BIT(16),                                                      01894860
         VM BIT(8);                                                             01894870
      IF C_TRACE THEN OUTPUT = 'PUSH_LOOP_STACKS(' ||PTR||','||VM||'):';        01894880
                                                                                01894890
      IF STACKED_VDLPS >= 2 AND VM THEN ST = 1;                                 01894900
      ELSE ST = 3;                                                              01894910
                                                                                01894920
      IF VM THEN DO;                                                            01894930
         STACKED_VDLPS = STACKED_VDLPS + 1;                                     01894940
         IF STACKED_VDLPS > 2 THEN STACKED_VDLPS = 2;                           01894950
      END;                                                                      01894960
      ELSE STACKED_VDLPS = 0;                                                   01894970
                                                                                01894980
      DO WHILE ST >= 1;                                                         01894990
         ST1 = ST-1;                                                            01895000
         CALL MOVE_LOOP_STACK;                                                  01895010
         ST = ST -1;                                                            01895020
      END;                                                                      01895030
                                                                                01895040
      CALL BUMP_LOOPSTACK(SHL(PTR,16),VM);                                      01895050
                                                                                01895060
      LOOP_HEAD = PTR;                                                          01895070
      ADJACENT = CHECK_ADJACENT_LOOPS(PTR);                                     01895080
      IF ^ADJACENT THEN                                                         01895081
         IF (VM AND ^IN_AR) OR ^VM THEN DO; /* DR111333 */ /* REINITIALIZE */   01895082
         CALL INIT_ARCONFS;                                                     01895082
         STRUC_TEMPL, REF_TO_STRUC = 0; /* DR111333 */
      END;                              /* DR111333 */
      VM,REF_TO_DSUB,ASSIGN = 0;                                                01895090
   END PUSH_LOOP_STACKS;                                                        01895100
