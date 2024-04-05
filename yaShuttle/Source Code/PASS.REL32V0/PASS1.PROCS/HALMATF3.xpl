 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATF3.xpl
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
 /* PROCEDURE NAME:  HALMAT_FIX_PIPTAGS                                     */
 /* MEMBER NAME:     HALMATF3                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PIP_LOC           FIXED                                        */
 /*          TAG1              BIT(8)                                       */
 /*          TAG2              BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          ICQ_OUTPUT                                                     */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00808700
HALMAT_FIX_PIPTAGS:                                                             00808800
   PROCEDURE (PIP_LOC,TAG1,TAG2);                                               00808900
      DECLARE PIP_LOC FIXED,                                                    00809000
         (TAG1,TAG2) BIT(8);                                                    00809100
      IF HALMAT_OK THEN ATOMS(PIP_LOC)=(ATOMS(PIP_LOC)&"FFFF00F1")|             00809200
         SHL(TAG1,8)|SHL(TAG2 & "7",1);                                         00809300
   END HALMAT_FIX_PIPTAGS;                                                      00809400
