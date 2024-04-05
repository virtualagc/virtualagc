 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKEVE.xpl
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
 /* PROCEDURE NAME:  CHECK_EVENT_EXP                                        */
 /* MEMBER NAME:     CHECKEVE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INX                                                            */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          XVAC                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_FIX_POPTAG                                              */
 /*          CHECK_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_EVENT_EXP <==                                                 */
 /*     ==> HALMAT_FIX_POPTAG                                               */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /***************************************************************************/
                                                                                00823200
CHECK_EVENT_EXP:                                                                00823300
   PROCEDURE (LOC);                                                             00823400
      DECLARE LOC BIT(16);                                                      00823500
      IF PSEUDO_FORM(PTR(LOC))=XVAC THEN                                        00823600
         CALL HALMAT_FIX_POPTAG(LOC_P(PTR(LOC)),5);                             00823700
      RETURN CHECK_ARRAYNESS|(INX(PTR(LOC))=0);                                 00823800
   END CHECK_EVENT_EXP;                                                         00823900
