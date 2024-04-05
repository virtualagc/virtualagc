 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETXREFR.xpl
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
 /* PROCEDURE NAME:  SET_XREF_RORS                                          */
 /* MEMBER NAME:     SETXREFR                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          K                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXF                                                           */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LOC_P                                                          */
 /*          PTR                                                            */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /*          XREF_REF                                                       */
 /*          XREF_SUBSCR                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PTR_TOP                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SET_XREF                                                       */
 /* CALLED BY:                                                              */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          CHECK_NAMING                                                   */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_XREF_RORS <==                                                   */
 /*     ==> SET_XREF                                                        */
 /*         ==> ENTER_XREF                                                  */
 /*         ==> SET_OUTER_REF                                               */
 /*             ==> COMPRESS_OUTER_REF                                      */
 /*                 ==> MAX                                                 */
 /***************************************************************************/
                                                                                00554300
SET_XREF_RORS:                                                                  00554400
   PROCEDURE (I,J,K);                                                           00554500
      DECLARE (I,J,L) FIXED,                                                    00554600
         K FIXED INITIAL("4000"  /* XREF_REF  */ );                             00554700
      IF SUBSCRIPT_LEVEL>0 THEN K=XREF_SUBSCR;                                  00554800
      IF FIXV(I)>0 THEN DO;                                                     00554900
         CALL SET_XREF(FIXV(I),K);                                              00555000
         DO L=PTR(I)+1 TO FIXF(I);                                              00555100
            CALL SET_XREF(LOC_P(L),K);                                          00555200
         END;                                                                   00555300
         PTR_TOP=PTR(I);    /* NOW GET RID OF EXTN STACK - ASSUMED AT TOP */    00555400
      END;                                                                      00555500
      IF SYT_TYPE(FIXL(I))^=TEMPL_NAME THEN CALL SET_XREF(FIXL(I),K,J);         00555600
      K=XREF_REF;                                                               00555700
      J=0;                                                                      00555800
   END SET_XREF_RORS;                                                           00555900
