 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STACKDUM.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  STACK_DUMP                                             */
 /* MEMBER NAME:     STACKDUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LINE              CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SP                                                             */
 /*          PARTIAL_PARSE                                                  */
 /*          STATE_NAME                                                     */
 /*          STATE_STACK                                                    */
 /*          TRUE                                                           */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /*          X4                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /*          STACK_DUMPED                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_DUMP                                                      */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STACK_DUMP <==                                                      */
 /*     ==> SAVE_DUMP                                                       */
 /***************************************************************************/
                                                                                01087100
                                                                                01087200
STACK_DUMP:                                                                     01087300
   PROCEDURE;                                                                   01087400
      DECLARE LINE CHARACTER;                                                   01087500
      IF ^PARTIAL_PARSE THEN                                                    01087600
         RETURN;  /* NO PARTIAL PARSE UNLESS ASKED FOR IN PARM FIELD */         01087700
      STACK_DUMPED = TRUE;                                                      01087800
      LINE = '***** PARTIAL PARSE TO THIS POINT IS: ';                          01087900
      DO I = 1 TO SP;                                                           01088000
         IF LENGTH(LINE) > 105 THEN                                             01088100
            DO;                                                                 01088200
            CALL SAVE_DUMP(LINE);                                               01088300
            LINE = X4;                                                          01088400
         END;                                                                   01088500
         LINE = LINE || X1 || STRING(VOCAB_INDEX(STATE_NAME(STATE_STACK(I))));  01088600
      END;                                                                      01088700
      CALL SAVE_DUMP(LINE);                                                     01088800
   END STACK_DUMP;                                                              01088900
