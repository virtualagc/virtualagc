 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHZAPS.xpl
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
 /* PROCEDURE NAME:  PUSH_ZAP_STACK                                         */
 /* MEMBER NAME:     PUSHZAPS                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OBPS                                                           */
 /*          STACK_TRACE                                                    */
 /*          STT#                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ZAP_LEVEL                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERASE_ZAPS                                                     */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          EXIT_CHECK                                                     */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_ZAP_STACK <==                                                  */
 /*     ==> ERASE_ZAPS                                                      */
 /***************************************************************************/
                                                                                02206380
 /* PUSHES ZAP STACK*/                                                          02206390
PUSH_ZAP_STACK:                                                                 02206400
   PROCEDURE;                                                                   02206410
      IF STACK_TRACE THEN OUTPUT = 'PUSH_ZAP_STACK:  '||STT#;                   02206420
      ZAP_LEVEL = ZAP_LEVEL + 1;                                                02206430
      IF ZAP_LEVEL > RECORD_TOP(OBPS) THEN                                      02206431
         NEXT_ELEMENT(OBPS);                                                    02206432
                                                                                02206440
      CALL ERASE_ZAPS;                                                          02206450
   END PUSH_ZAP_STACK;                                                          02206460
