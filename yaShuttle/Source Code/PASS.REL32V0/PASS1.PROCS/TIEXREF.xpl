 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TIEXREF.xpl
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
 /* PROCEDURE NAME:  TIE_XREF                                               */
 /* MEMBER NAME:     TIEXREF                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          P                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          PP                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          CLASS_UP                                                       */
 /*          CR_REF                                                         */
 /*          SYM_PTR                                                        */
 /*          SYM_XREF                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_XREF                                                       */
 /*          UPDATE_BLOCK_LEVEL                                             */
 /*          XREF                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /*          CROSS_REF                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TIE_XREF <==                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00660100
                                                                                00660200
TIE_XREF:                                                                       00660300
   PROCEDURE(P);                                                                00660400
      DECLARE (I, J, P, PP) FIXED;                                              00660500
      IF UPDATE_BLOCK_LEVEL > 0 THEN                                            00660600
         CALL ERROR(CLASS_UP, 1, BCD);                                          00660700
      IF SYT_XREF(P)>0 THEN DO;                                                 00660800
         I=SYT_XREF(P);                                                         00660900
         SYT_XREF(P)=-1;                                                        00661000
         PP=SYT_PTR(P);                                                         00661100
         P=SYT_XREF(PP);                                                        00661200
         IF P>0 THEN DO;                                                        00661300
            J=XREF(I)&"FFFF0000";                                               00661400
            XREF(I)=(XREF(I)&"FFFF")|(XREF(P)&"FFFF0000");                      00661500
            XREF(P)=(XREF(P)&"FFFF")|J;                                         00661600
         END;                                                                   00661700
         SYT_XREF(PP)=I;                                                        00661800
      END;                                                                      00661900
   END TIE_XREF;                                                                00662000
