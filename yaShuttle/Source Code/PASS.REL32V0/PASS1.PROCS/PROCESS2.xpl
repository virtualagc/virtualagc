 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PROCESS2.xpl
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
 /* PROCEDURE NAME:  PROCESS_CHECK                                          */
 /* MEMBER NAME:     PROCESS2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXL                                                           */
 /*          CLASS_RT                                                       */
 /*          PROG_LABEL                                                     */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TASK_LABEL                                                     */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          CHECK_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PROCESS_CHECK <==                                                   */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /***************************************************************************/
                                                                                00824000
PROCESS_CHECK:                                                                  00824100
   PROCEDURE (LOC);                                                             00824200
      DECLARE LOC BIT(16);                                                      00824300
      IF CHECK_ARRAYNESS THEN CALL ERROR(CLASS_RT,11,VAR(LOC));                 00824400
      IF SYT_TYPE(FIXL(LOC))^=PROG_LABEL&SYT_TYPE(FIXL(LOC))^=TASK_LABEL        00824500
         THEN CALL ERROR(CLASS_RT,9,VAR(LOC));                                  00824600
   END PROCESS_CHECK;                                                           00824700
