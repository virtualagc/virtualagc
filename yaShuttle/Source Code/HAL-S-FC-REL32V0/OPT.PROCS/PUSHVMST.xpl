 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHVMST.xpl
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
 /* PROCEDURE NAME:  PUSH_VM_STACK                                          */
 /* MEMBER NAME:     PUSHVMST                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOOP_STACKSIZE                                                 */
 /*          C_TRACE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ST                                                             */
 /*          ST1                                                            */
 /*          V_STACK_INX                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MOVE_LOOP_STACK                                                */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_VM_STACK <==                                                   */
 /*     ==> MOVE_LOOP_STACK                                                 */
 /***************************************************************************/
                                                                                01897210
                                                                                01897220
 /* PUSHES VM ENTRIES ON LOOP STACK*/                                           01897230
PUSH_VM_STACK:                                                                  01897240
   PROCEDURE;                                                                   01897250
      IF C_TRACE THEN OUTPUT = 'PUSH_VM_STACK ';                                01897260
      ST = LOOP_STACKSIZE - (V_STACK_INX = 0);                                  01897270
      DO WHILE ST >= LOOP_STACKSIZE - 1;                                        01897280
         IF ST = LOOP_STACKSIZE THEN ST1 = LOOP_STACKSIZE -1;                   01897290
         ELSE ST1 = 0;                                                          01897300
         CALL MOVE_LOOP_STACK;                                                  01897310
         ST = ST - 1;                                                           01897320
      END;                                                                      01897330
      IF V_STACK_INX = 0 THEN V_STACK_INX = 1;                                  01897340
      ELSE V_STACK_INX = 2;                                                     01897350
   END PUSH_VM_STACK;                                                           01897360
