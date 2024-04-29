 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPMACRO.xpl
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
 /* PROCEDURE NAME:  POP_MACRO_XREF                                         */
 /* MEMBER NAME:     POPMACRO                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MAC_XREF                                                       */
 /*          XREF_REF                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          MAC_CTR                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SET_XREF                                                       */
 /* CALLED BY:                                                              */
 /*          COMPILATION_LOOP                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> POP_MACRO_XREF <==                                                  */
 /*     ==> SET_XREF                                                        */
 /*         ==> ENTER_XREF                                                  */
 /*         ==> SET_OUTER_REF                                               */
 /*             ==> COMPRESS_OUTER_REF                                      */
 /*                 ==> MAX                                                 */
 /***************************************************************************/
POP_MACRO_XREF:PROCEDURE;                                                       00555980
      DECLARE I BIT(16);                                                        00555990
      DO I=0 TO MAC_CTR;                                                        00556000
         CALL SET_XREF(MAC_XREF(I),XREF_REF);                                   00556010
      END;                                                                      00556020
      MAC_CTR=-1;                                                               00556030
      RETURN;                                                                   00556040
   END;                                                                         00556050
