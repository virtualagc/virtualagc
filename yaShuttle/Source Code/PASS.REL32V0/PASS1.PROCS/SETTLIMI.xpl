 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETTLIMI.xpl
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
 /* PROCEDURE NAME:  SET_T_LIMIT                                            */
 /* MEMBER NAME:     SETTLIMI                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          LRECL             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          T_LIMIT           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SDL_OPTION                                                     */
 /*          CLASS_B                                                        */
 /*          SRN_PRESENT                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_T_LIMIT <==                                                     */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*    DATE   NAME  REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 07/13/95  DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                                         */
 /***************************************************************************/
                                                                                00289400
 /* $%ENTERXRE - ENTER_XREF */                                                  00289410
 /* $%SAVELITE - SAVE_LITERAL */                                                00289420
 /* $%ICQTERM# - ICQ_TERM# */                                                   00289430
 /* $%ICQARRAY - ICQ_ARRAY# */                                                  00289440
 /* $%CHECKSTR - CHECK_STRUC_CONFLICTS */                                       00289450
 /* $%ENTER    - ENTER */                                                       00289460
 /* $%ENTERDIM - ENTER_DIMS */                                                  00289470
 /* $%STORAGEM - STORAGE_MGT */                                                 00289480
 /* $%DISCONNE - DISCONNECT */                                                  00289490
 /* $%SETDUPLF - SET_DUPL_FLAG */                                               00289500
 /* $%FINISHMA - FINISH_MACRO_TEXT */                                           00289510
 /* $%ENTERLAY - ENTER_LAYOUT */                                                00289520
 /* $%MAKEINCL - MAKE_INCL_CELL */                                              00289530
SET_T_LIMIT:                                                                    00289540
   PROCEDURE(LRECL) BIT(16);                                                    00289550
      DECLARE LRECL BIT(16);                                                    00289560
      DECLARE T_LIMIT BIT(16);                                                  00289570
      IF LRECL<0 THEN CALL ERROR(CLASS_B,3); /* CR12416 */                      00289580
      IF SDL_OPTION THEN T_LIMIT=71;                                            00289590
      ELSE DO;                                                                  00289600
         T_LIMIT=LRECL;                                                         00289610
         IF SRN_PRESENT THEN T_LIMIT=T_LIMIT-8;                                 00289620
      END;                                                                      00289630
      RETURN T_LIMIT;                                                           00289640
   END SET_T_LIMIT;                                                             00289650
