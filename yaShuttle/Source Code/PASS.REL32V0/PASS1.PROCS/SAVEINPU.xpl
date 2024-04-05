 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVEINPU.xpl
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
 /* PROCEDURE NAME:  SAVE_INPUT                                             */
 /* MEMBER NAME:     SAVEINPU                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CARD_COUNT                                                     */
 /*          CARD_TYPE                                                      */
 /*          COMM                                                           */
 /*          INCLUDE_END                                                    */
 /*          INCLUDE_LIST2                                                  */
 /*          INCLUDE_OFFSET                                                 */
 /*          INCLUDING                                                      */
 /*          PLUS                                                           */
 /*          SAVE_CARD                                                      */
 /*          SAVE#                                                          */
 /*          STMT_NUM                                                       */
 /*          TRUE                                                           */
 /*          VBAR                                                           */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INCLUDE_CHAR                                                   */
 /*          NEXT                                                           */
 /*          S                                                              */
 /*          SAVE_GROUP                                                     */
 /*          TOO_MANY_LINES                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PAD                                                            */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SAVE_INPUT <==                                                      */
 /*     ==> PAD                                                             */
 /*     ==> I_FORMAT                                                        */
 /***************************************************************************/
                                                                                00274800
SAVE_INPUT:                                                                     00274900
   PROCEDURE;                                                                   00275000
      IF ^INCLUDE_LIST2 THEN RETURN;                                            00275100
      IF CARD_TYPE(BYTE(SAVE_CARD)) >= 4 THEN                                   00275200
         IF NEXT < 0 THEN                                                       00275300
         RETURN; /* A LEGITIMATE COMMENT ALREADY PRINTED */                     00275400
      NEXT = NEXT + 1;  /* NEXT AVAILABLE LINE */                               00275500
      IF NEXT > SAVE# THEN                                                      00275600
         DO;                                                                    00275700
         TOO_MANY_LINES = TRUE;                                                 00275800
         NEXT = SAVE#;                                                          00275900
         RETURN;                                                                00276000
      END;                                                                      00276100
      S = CARD_COUNT - INCLUDE_OFFSET;                                          00276200
      S = PAD(S, 4);                                                            00276300
      IF (INCLUDING | INCLUDE_END) THEN                                         00276400
         INCLUDE_CHAR = PLUS;                                                   00276500
      ELSE                                                                      00276600
         INCLUDE_CHAR = X1;                                                     00276700
      SAVE_GROUP(NEXT) = I_FORMAT(STMT_NUM, 7) || INCLUDE_CHAR ||               00276800
         SUBSTR(SAVE_CARD, 0, 1) || VBAR || SUBSTR(SAVE_CARD, 1) || VBAR || S;  00276900
   END SAVE_INPUT;                                                              00277000
