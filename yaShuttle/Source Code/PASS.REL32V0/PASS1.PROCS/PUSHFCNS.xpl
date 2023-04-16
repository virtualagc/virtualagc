 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHFCNS.xpl
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
 /* PROCEDURE NAME:  PUSH_FCN_STACK                                         */
 /* MEMBER NAME:     PUSHFCNS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_BS                                                       */
 /*          FCN_LV_MAX                                                     */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FCN_LV                                                         */
 /*          FCN_ARG                                                        */
 /*          FCN_MODE                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_FCN_STACK <==                                                  */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00841400
PUSH_FCN_STACK:                                                                 00841500
   PROCEDURE (MODE);                                                            00841600
      DECLARE MODE BIT(16);                                                     00841700
      FCN_LV=FCN_LV+1;                                                          00841800
      IF FCN_LV>FCN_LV_MAX THEN DO;                                             00841900
         CALL ERROR(CLASS_BS,5);                                                00842000
         RETURN FALSE;                                                          00842100
      END;                                                                      00842200
      FCN_ARG(FCN_LV)=0;                                                        00842300
      FCN_MODE(FCN_LV)=MODE;                                                    00842400
      RETURN TRUE;                                                              00842500
   END PUSH_FCN_STACK;                                                          00842600
