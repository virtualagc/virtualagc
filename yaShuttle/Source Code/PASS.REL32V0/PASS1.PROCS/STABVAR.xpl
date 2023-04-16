 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STABVAR.xpl
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
 /* PROCEDURE NAME:  STAB_VAR                                               */
 /* MEMBER NAME:     STABVAR                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          STAB_STACKER(1534)  LABEL                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXF                                                           */
 /*          CLASS_BT                                                       */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LOC_P                                                          */
 /*          PTR                                                            */
 /*          STAB_STACKLIM                                                  */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          STAB_STACK                                                     */
 /*          STAB_STACKTOP                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STAB_VAR <==                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00782300
STAB_VAR:                                                                       00782400
   PROCEDURE(LOC);                                                              00782410
      DECLARE (LOC,I) BIT(16);                                                  00782420
                                                                                00783600
STAB_STACKER:                                                                   00783700
      PROCEDURE (ENTRY);                                                        00783800
         DECLARE ENTRY BIT(16);                                                 00783900
         IF STAB_STACKTOP=STAB_STACKLIM THEN CALL ERROR(CLASS_BT,2);            00784000
         ELSE DO;                                                               00784100
            STAB_STACKTOP=STAB_STACKTOP+1;                                      00784200
            STAB_STACK(STAB_STACKTOP)=ENTRY;                                    00784300
         END;                                                                   00784400
      END STAB_STACKER;                                                         00784500
                                                                                00784600
      IF FIXV(LOC)>0 THEN DO;                                                   00785000
         CALL STAB_STACKER((FIXV(LOC) & "7FFF") | "8000");                      00785100
         DO I=PTR(LOC)+1 TO FIXF(LOC);                                          00785200
            CALL STAB_STACKER(LOC_P(I) & "7FFF");                               00785300
         END;                                                                   00785400
         IF SYT_TYPE(FIXL(LOC))=TEMPL_NAME THEN RETURN;                         00785500
         I=0;                                                                   00785600
      END;                                                                      00785700
      ELSE I = "8000";                                                          00785800
      CALL STAB_STACKER((FIXL(LOC) & "7FFF") | I);                              00785810
   END STAB_VAR;                                                                00786000
