 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MOVELOOP.xpl
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
 /* PROCEDURE NAME:  MOVE_LOOP_STACK                                        */
 /* MEMBER NAME:     MOVELOOP                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ST                                                             */
 /*          ST1                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADJACENT                                                       */
 /*          AR_SIZE                                                        */
 /*          ASSIGN                                                         */
 /*          LOOP_END                                                       */
 /*          LOOP_HEAD                                                      */
 /*          REF_TO_DSUB                                                    */
 /* CALLED BY:                                                              */
 /*          POP_LOOP_STACKS                                                */
 /*          PUSH_LOOP_STACKS                                               */
 /*          PUSH_VM_STACK                                                  */
 /***************************************************************************/
                                                                                01894570
                                                                                01894580
 /* MOVES LOOP STACK*/                                                          01894590
MOVE_LOOP_STACK:                                                                01894600
   PROCEDURE;                                                                   01894610
      LOOP_HEAD(ST) = LOOP_HEAD(ST1);                                           01894620
      LOOP_END(ST) = LOOP_END(ST1);                                             01894630
      AR_SIZE(ST) = AR_SIZE(ST1);                                               01894640
      ADJACENT(ST) = ADJACENT(ST1);                                             01894650
      REF_TO_DSUB(ST) = REF_TO_DSUB(ST1);                                       01894660
      ASSIGN(ST) = ASSIGN(ST1);                                                 01894670
   END MOVE_LOOP_STACK;                                                         01894680
