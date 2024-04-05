 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKARR.xpl
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
 /* PROCEDURE NAME:  CHECK_ARRAYNESS                                        */
 /* MEMBER NAME:     CHECKARR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          ARRAYNESS_FLAG                                                 */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /*          CHECK_EVENT_EXP                                                */
 /*          KILL_NAME                                                      */
 /*          PROCESS_CHECK                                                  */
 /*          RECOVER                                                        */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /*          UNARRAYED_INTEGER                                              */
 /*          UNARRAYED_SCALAR                                               */
 /*          UNARRAYED_SIMPLE                                               */
 /***************************************************************************/
                                                                                00819700
CHECK_ARRAYNESS:                                                                00819800
   PROCEDURE;                                                                   00819900
      DECLARE I BIT(16);                                                        00820000
      I=CURRENT_ARRAYNESS>0;                                                    00820100
      CURRENT_ARRAYNESS,ARRAYNESS_FLAG=0;                                       00820200
      RETURN I;                                                                 00820300
   END CHECK_ARRAYNESS;                                                         00820400
