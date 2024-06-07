 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPLOOPS.xpl
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
 /* PROCEDURE NAME:  POP_LOOP_STACKS                                        */
 /* MEMBER NAME:     POPLOOPS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          VM                BIT(8)                                       */
 /*          NO_VDLPS          BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          C_TRACE                                                        */
 /*          FOR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          STACKED_VDLPS                                                  */
 /*          LOOP_HEAD                                                      */
 /*          ST                                                             */
 /*          ST1                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MOVE_LOOP_STACK                                                */
 /* CALLED BY:                                                              */
 /*          CHECK_VM_COMBINE                                               */
 /*          DENEST                                                         */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> POP_LOOP_STACKS <==                                                 */
 /*     ==> MOVE_LOOP_STACK                                                 */
 /***************************************************************************/
                                                                                01895110
                                                                                01895120
 /* POPS LOOP STACKS*/                                                          01895130
POP_LOOP_STACKS:                                                                01895140
   PROCEDURE(VM,NO_VDLPS);                                                      01895150
      DECLARE (VM,NO_VDLPS) BIT(8);                                             01895160
      DECLARE TEMP BIT(16);                                                     01895170
      IF C_TRACE THEN OUTPUT = 'POP_LOOP_STACKS('||VM||','||NO_VDLPS||'):';     01895180
                                                                                01895190
      TEMP = NO_VDLPS AND STACKED_VDLPS = 2;                                    01895200
                                                                                01895210
      DO FOR ST = 0 TO 2 - TEMP;                                                01895220
         ST1 = ST + 1 + TEMP;                                                   01895230
         CALL MOVE_LOOP_STACK;                                                  01895240
      END;                                                                      01895250
                                                                                01895260
      LOOP_HEAD(3) = 0;                                                         01895270
      IF NO_VDLPS THEN STACKED_VDLPS = 0;                                       01895280
      ELSE STACKED_VDLPS = STACKED_VDLPS - VM;                                  01895290
      NO_VDLPS,VM = 0;                                                          01895300
   END POP_LOOP_STACKS;                                                         01895310
