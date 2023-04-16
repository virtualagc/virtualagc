 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   KILLNAME.xpl
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
 /* PROCEDURE NAME:  KILL_NAME                                              */
 /* MEMBER NAME:     KILLNAME                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          PTR                                                            */
 /*          VAL_P                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NAME_PSEUDOS                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHECK_ARRAYNESS                                                */
 /*          RESET_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> KILL_NAME <==                                                       */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /*     ==> RESET_ARRAYNESS                                                 */
 /***************************************************************************/
                                                                                00878000
KILL_NAME:                                                                      00878100
   PROCEDURE (LOC) BIT(1);                                                      00878200
      DECLARE LOC BIT(16);                                                      00878300
      IF NAME_PSEUDOS THEN DO;                                                  00878400
         IF (VAL_P(PTR(LOC))&"400")=0 THEN CALL RESET_ARRAYNESS;                00878500
         CALL CHECK_ARRAYNESS;                                                  00878600
         NAME_PSEUDOS=FALSE;                                                    00878700
         RETURN 1;                                                              00878800
      END;                                                                      00878900
      RETURN 0;                                                                 00879000
   END KILL_NAME;                                                               00879100
