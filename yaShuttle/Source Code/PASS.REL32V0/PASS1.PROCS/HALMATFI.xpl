 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATFI.xpl
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
 /* PROCEDURE NAME:  HALMAT_FIX_PIP#                                        */
 /* MEMBER NAME:     HALMATFI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POP_LOC           FIXED                                        */
 /*          PIP#              BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00807100
HALMAT_FIX_PIP#:                                                                00807200
   PROCEDURE(POP_LOC,PIP#);                                                     00807300
      DECLARE POP_LOC FIXED,                                                    00807400
         PIP# BIT(8);                                                           00807500
      IF HALMAT_OK THEN ATOMS(POP_LOC)=(ATOMS(POP_LOC)&"FF00FFFF")|             00807600
         SHL(PIP#,16);                                                          00807700
   END HALMAT_FIX_PIP#;                                                         00807800
