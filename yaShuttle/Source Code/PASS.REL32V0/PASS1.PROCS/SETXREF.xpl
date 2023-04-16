 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETXREF.xpl
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
 /* PROCEDURE NAME:  SET_XREF                                               */
 /* MEMBER NAME:     SETXREF                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /*          FLAG              FIXED                                        */
 /*          FLAG2             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ENTER_OUTER_REF(17)  LABEL                                     */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CALLED_LABEL                                                   */
 /*          IND_CALL_LAB                                                   */
 /*          NEST                                                           */
 /*          SYM_NEST                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYM_XREF                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_TYPE                                                       */
 /*          SYT_XREF                                                       */
 /*          XREF_REF                                                       */
 /*          XREF_SUBSCR                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER_XREF                                                     */
 /*          SET_OUTER_REF                                                  */
 /* CALLED BY:                                                              */
 /*          IDENTIFY                                                       */
 /*          POP_MACRO_XREF                                                 */
 /*          SET_XREF_RORS                                                  */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_XREF <==                                                        */
 /*     ==> ENTER_XREF                                                      */
 /*     ==> SET_OUTER_REF                                                   */
 /*         ==> COMPRESS_OUTER_REF                                          */
 /*             ==> MAX                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /* 07/23/01 TKN  31V0/ DR111356 XREF INCORRECT FOR STRUCTURE TEMPLATE      */
 /*               16V0           DECLARATION                                */
 /*                                                                         */
 /***************************************************************************/
                                                                                00552200
SET_XREF:                                                                       00552300
   PROCEDURE (LOC, FLAG, FLAG2);                                                00552400
      DECLARE (LOC, FLAG, FLAG2) FIXED;                                         00552500
      IF LOC>0 THEN DO;     /* FILTERS FIXV OF NON-STRUCTS */                   00552600
         IF FLAG2=0 THEN DO;                                                    00552700
            IF FLAG=XREF_SUBSCR THEN FLAG2=XREF_REF;                            00552800
            ELSE FLAG2=FLAG;                                                    00552900
         END;                                                                   00553000
         IF (SYT_TYPE(LOC)=IND_CALL_LAB) |          /*DR111356*/
/*DR111356*/((SYT_TYPE(LOC)=PROC_LABEL | SYT_TYPE(LOC)=STMT_LABEL |
/*DR111356*/  SYT_TYPE(LOC)=TASK_LABEL) & SYT_FLAGS(LOC)^=DEFINED_LABEL)
/*DR111356*/  THEN NO_NEW_XREF = TRUE;
         SYT_XREF(LOC)=ENTER_XREF(SYT_XREF(LOC),FLAG);                          00553100
         IF NO_NEW_XREF THEN NO_NEW_XREF = FALSE;   /*DR111356*/
         IF SYT_TYPE(LOC) = IND_CALL_LAB |                                      00553200
            SYT_TYPE(LOC) = CALLED_LABEL THEN                                   00553300
            GO TO ENTER_OUTER_REF;                                              00553400
         IF SYT_NEST(LOC) < NEST THEN DO;                                       00553500
ENTER_OUTER_REF:                                                                00553600
            IF FLAG2 ^= 0 THEN                                                  00553700
               CALL SET_OUTER_REF(LOC, FLAG2);                                  00553800
         END;                                                                   00553900
      END;                                                                      00554000
      FLAG2=0;                                                                  00554100
   END SET_XREF;                                                                00554200
