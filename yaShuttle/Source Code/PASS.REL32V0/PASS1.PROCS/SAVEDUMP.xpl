 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVEDUMP.xpl
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
 /* PROCEDURE NAME:  SAVE_DUMP                                              */
 /* MEMBER NAME:     SAVEDUMP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MSG               CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          STACK_DUMP_MAX                                                 */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SAVE_STACK_DUMP                                                */
 /*          STACK_DUMP_PTR                                                 */
 /* CALLED BY:                                                              */
 /*          CALL_SCAN                                                      */
 /*          STACK_DUMP                                                     */
 /***************************************************************************/
                                                                                00280500
SAVE_DUMP:                                                                      00280600
   PROCEDURE(MSG);                                                              00280700
      DECLARE MSG CHARACTER;                                                    00280800
      STACK_DUMP_PTR = STACK_DUMP_PTR + 1;                                      00280900
      IF STACK_DUMP_PTR >= STACK_DUMP_MAX THEN                                  00281000
         DO;                                                                    00281100
         SAVE_STACK_DUMP(STACK_DUMP_MAX) = '***** DUMP INCOMPLETE.';            00281200
         STACK_DUMP_PTR = STACK_DUMP_MAX;                                       00281300
      END;                                                                      00281400
      SAVE_STACK_DUMP(STACK_DUMP_PTR) = MSG;                                    00281500
   END SAVE_DUMP;                                                               00281600
